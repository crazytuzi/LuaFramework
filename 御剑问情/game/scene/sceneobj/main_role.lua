MainRole = MainRole or BaseClass(Role)

local MATERIAL_ID_LIST = {
	[GameEnum.ROLE_PROF_1] = "8016_02",
	[GameEnum.ROLE_PROF_2] = "8016_02",
	[GameEnum.ROLE_PROF_3] = "8016_02",
}

function MainRole:__init(vo)
	self.obj_type = SceneObjType.MainRole
	self.draw_obj:SetObjType(self.obj_type)

	self.arrive_func = nil							-- 到达处理
	self.move_oper_cache = nil						-- 移动操作缓存
	self.move_oper_cache2 = nil  					-- 跳跃操作缓存
	self.is_only_client_move = false				-- 在某些玩法副本中, 全是机器人，又需要动态改变主角速度，移动设计成不通知服务器

	self.last_logic_pos_x = 0
	self.last_logic_pos_y = 0

	self.last_skill_id = 0
	self.last_skill_index = 0
	self.atk_is_hit = {}
	self.last_atk_end_time = 0

	self.path_pos_list = {}
	self.path_pos_index = 1

	self.last_in_safe = false					-- 上一刻是否在安全区

	self.is_specialskil = false
	self.is_special_jump = false

	self.jump_call_back = nil
	self.target_point = nil
	self.next_point = nil

	self.target_x = 0
	self.target_y = 0

	self.total_stand_time = 0
	self.is_inter_scene = false
	self.character_ghost = nil 					-- 残影组件
	self.ghost_time = 1 						-- 残影持续时间

	self.last_mount_state = 0

	self.jump_name = nil
	self.jump_normalized_time = nil

	self.next_check_camera_time = 0
end

function MainRole:__delete()
	-- if self.timer_quest then
	-- 	GlobalTimerQuest:CancelQuest(self.timer_quest)
	-- 	self.timer_quest = nil
	-- end
	if self.material then
		MaterialPool.Instance:Free(self.material)
		self.material = nil
	end
	self:HideJumpTrailRenderer()
	if not IsNil(MainCameraFollow) then
		MainCameraFollow.Target = nil
		if CAMERA_TYPE == CameraType.Free then
			MainCameraFollow.AutoRotation = false
		end
	end
	self:CancelJumpQuest()

	self.is_inter_scene = false
	self.character_ghost = nil
	self.jump_name = nil
	self.jump_normalized_time = nil
end

function MainRole:Update(now_time, elapse_time)
	Role.Update(self, now_time, elapse_time)
	if self.last_logic_pos_x ~= self.logic_pos.x or self.last_logic_pos_y ~= self.logic_pos.y then
		self.last_logic_pos_x = self.logic_pos.x
		self.last_logic_pos_y = self.logic_pos.y
		GlobalEventSystem:Fire(ObjectEventType.MAIN_ROLE_POS_CHANGE, self.last_logic_pos_x, self.last_logic_pos_y)

		-- 状态不一样
		if self.last_in_safe ~= self:IsInSafeArea() then
			self.last_in_safe = self:IsInSafeArea()
			local convertion = SceneConvertionArea.SAFE_TO_WAY
			if self.last_in_safe then
				convertion = SceneConvertionArea.WAY_TO_SAFE
			end
			GlobalEventSystem:Fire(ObjectEventType.MAIN_ROLE_CHANGE_AREA_TYPE, convertion)
		end
	end
	if self.add_level_eff_time and now_time - self.add_level_eff_time > 0.5 then
		self:RemoveBuff(BUFF_TYPE.UP_LEVEL)
		self.add_level_eff_time = nil
	end

	if self:IsStand() then
		if self.total_stand_time == 0 then
			GlobalEventSystem:Fire(ObjectEventType.MAIN_ROLE_ENTER_IDLE_STATE)
		end
		self.total_stand_time = self.total_stand_time + elapse_time
	else
		if self.total_stand_time ~= 0 then
			GlobalEventSystem:Fire(ObjectEventType.MAIN_ROLE_STOP_IDLE_STATE)
		end
		self.total_stand_time = 0
	end

	-- MainCamera在某些情况下会丢失Target，这里加个检查
	if self.next_check_camera_time <= Status.NowTime then
		self.next_check_camera_time = Status.NowTime + 2
		if not IsNil(MainCameraFollow) then
			if nil == MainCameraFollow.Target then
				self:UpdateCameraFollowTarget(true)
			end
		end
	end
end

function MainRole:OnEnterScene()
	Role.OnEnterScene(self)
	self.is_inter_scene = true
	self:UpdateCameraFollowTarget(true)
	self:GetFollowUi()
end

function MainRole:OnLoadSceneComplete()
	Role.OnLoadSceneComplete(self)
end

function MainRole:IsMainRole()
	return true
end

function MainRole:GetObjKey()
	return nil
end

function MainRole:HideFollowUi()
end

function MainRole:DoMoveByClick(...)
	if self.vo.move_mode == MOVE_MODE.MOVE_MODE_JUMP2 then
		SysMsgCtrl.Instance:ErrorRemind(Language.Common.CanNotMoveInJump)
		return
	end
	local logic = Scene.Instance:GetSceneLogic()
	if logic and not logic:CanCancleAutoGuaji() then
		return false
	end

	Scene.Instance:GetSceneLogic():StopAutoGather()
	GuajiCtrl.Instance:DoMoveByClick(...)
	self:ClearPathInfo()
	self.attack_skill_id = 0
	GlobalEventSystem:Fire(OtherEventType.MOVE_BY_CLICK)
	return self:DoMoveOperate(...)
end

function MainRole:DoMoveOperate(x, y, range, arrive_func, is_chongci)
	is_chongci = is_chongci and true or false
	local scene_logic = Scene.Instance:GetSceneLogic()
	local can_move = scene_logic:GetIsCanMove(x, y)
	if not can_move then
		return false
	end

	if self:IsJump() then
		return false
	end

	if x == self.logic_pos.x and y == self.logic_pos.y then
		return false
	end

	if not self:CanDoMove() then
		if self:IsAtk() or self:IsAtkPlaying() then
			self.move_oper_cache = {x = x, y = y, range = range, arrive_func = arrive_func}
		end
		return false
	end

	x, y = AStarFindWay:GetAroundVaildXY(x, y, 3)
	x, y = AStarFindWay:GetLineEndXY2(self.logic_pos.x, self.logic_pos.y, x, y)

	local move_x, move_y = x, y
	if not AStarFindWay:IsWayLine(self.logic_pos.x, self.logic_pos.y, x, y) then
		if is_chongci and not AStarFindWay:IsBlock(x, y) then
			--对方在非障碍区就冲过去
			self.path_pos_index = 1
			self.path_pos_list = {{x = move_x, y = move_y}}
		else
			if not AStarFindWay:FindWay(self.logic_pos, u3d.vec2(x, y)) then
				GlobalEventSystem:Fire(ObjectEventType.CAN_NOT_FIND_THE_WAY)
				return
			end
			self.path_pos_list = AStarFindWay:GenerateInflexPoint(range)
			self.path_pos_index = 1
			if not self.path_pos_list or #self.path_pos_list == 0 then
				GlobalEventSystem:Fire(ObjectEventType.CAN_NOT_FIND_THE_WAY)
				return
			end
			move_x = self.path_pos_list[1].x
			move_y = self.path_pos_list[1].y
		end

	else
		self.path_pos_index = 1
		self.path_pos_list = {{x = move_x, y = move_y}}
	end

	if arrive_func then
		self.arrive_func = arrive_func
	end
	self:ChangeChongCi(is_chongci)
	self.is_chongci = is_chongci
	Role.DoMove(self, move_x, move_y, is_chongci)
	self:SendMoveReq()
end

local skill_can_move = false
function MainRole:CanDoMove()
	skill_can_move = SkillData.GetSkillCanMove(self.last_skill_id)
	if self:IsRealDead() or self:IsDead() or (self:IsAtk() and not skill_can_move) or self.is_special_move or self:IsJump() or self.vo.move_mode == MOVE_MODE.MOVE_MODE_JUMP2 or
		(self:IsAtkPlaying() and not skill_can_move) or CgManager.Instance:IsCgIng() or self:IsMultiMountPartner() then
		return false
	end

	-- Buff 效果判断
	if self:IsDingShen() or self:IsXuanYun() or self:IsBingDong() then
		print_log("You can't move now. ")
		return false
	end
	local scene_logic = Scene.Instance:GetSceneLogic()
	if scene_logic then
		return scene_logic:CanMove()
	end

	return true
end

-- 主角在寻路出的路径如果拐点相距很短时，会出现人物“抖向”问题
function MainRole:IsNeedChangeDirOnDoMove(pos_x, pos_y)
	if #self.path_pos_list > 1 then
		local now_pos = self.draw_obj:GetRootPosition()
		local dis = GameMath.GetDistance(self.logic_pos.x, self.logic_pos.y, pos_x, pos_y, false)
		if dis < 4 then
			return false
		end
	end

	return true
end

function MainRole:MoveEnd()
	local pos = self.path_pos_list[self.path_pos_index + 1]
	if nil ~= pos then
		self.path_pos_index = self.path_pos_index + 1
		Role.DoMove(self, pos.x, pos.y)
		self:SendMoveReq()
		return false
	end

	return true
end

function MainRole:EnterStateMove()
	Role.EnterStateMove(self)
	if self.vo.move_mode == MOVE_MODE.MOVE_MODE_JUMP2 and self.vo.move_mode_param > 0 then
		if self.target_x == nil or self.target_y == nil then
			return
		end
		-- if self.timer_quest then
		-- 	GlobalTimerQuest:CancelQuest(self.timer_quest)
		-- 	self.timer_quest = nil
		-- end

		Role.DoMove(self, self.target_x, self.target_y)
		self:SendMoveReq()
	end
	GlobalEventSystem:Fire(ObjectEventType.MAIN_ROLE_MOVE_START)
end

function MainRole:QuitStateMove()
	if not self.is_special_move and not self:IsSpecialJump() then
		-- 如果停止点在阻挡里，前后一格找一个可以站立的点
		if AStarFindWay:IsBlock(self.logic_pos.x, self.logic_pos.y) then
			for _, v in pairs({1, -1}) do
				local mov_dir = u3d.v2Mul(self.move_dir, v)
				local x, y = GameMapHelper.WorldToLogic(self.real_pos.x + mov_dir.x, self.real_pos.y + mov_dir.y)
				if not AStarFindWay:IsBlock(x, y) then
					self:SetLogicPosData(x, y)
					break
				end
			end
		end
		self:SendMoveReq(0)
	end
	Role.QuitStateMove(self)
	self:ChangeChongCi(false)
	self.is_chongci = false
	if self.arrive_func then
		local arrive_func = self.arrive_func
		self.arrive_func = nil
		arrive_func()
	end
	if self.vo.move_mode == MOVE_MODE.MOVE_MODE_JUMP2 and self.vo.move_mode_param > 0 then
		if self.jump_call_back then
			self.jump_call_back()
			self.jump_call_back = nil
		end
	end
	GlobalEventSystem:Fire(ObjectEventType.MAIN_ROLE_MOVE_END)
end

function MainRole:ClearPathInfo()
	self.path_pos_list = {}
	self.path_pos_index = 0
end

-- 跳跃
function MainRole:OnJumpStart()
	if self:IsDeleted() or self.target_point == nil then
		return
	end
	if self.target_x == nil or self.target_y == nil then
		return
	end
	local interval = 0.1
	self:ShowGhost(0, self.ghost_time / interval, 7, interval)

	if self.vo.multi_mount_res_id > 0 then --双人坐骑跳跃时
		if self:IsMultiMountPartner() then
			self:MultiMountPartnerDismount()
		else
			local parnter = self:GetMountParnterRole()
			if parnter then
				parnter:MultiMountPartnerDismount()
			end
		end
	end

	self:RemoveModel(SceneObjPart.Mount)
	self:RemoveModel(SceneObjPart.FightMount)

	-- if self.timer_quest then
	-- 	GlobalTimerQuest:CancelQuest(self.timer_quest)
	-- 	self.timer_quest = nil
	-- end

	-- local root = self.draw_obj:GetRoot()
	-- local target_position = u3d.vec2(self.target_position.x, self.target_position.z)
	--local position = u3d.vec2(root.transform.position.x, root.transform.position.z)
	--local dir = u3d.v2Normalize()
	local x, y = self:GetLogicPos()
	-- local end_x, end_y = math.floor(x + dir.x * GameEnum.JUMP_RANGE), math.floor(y + dir.z * GameEnum.JUMP_RANGE)
	--local target_x, target_y = AStarFindWay:GetLineEndXY2(x, y, self.target_position.x, self.target_position.z)
	local jump_speed_factor = 1
	local distance = u3d.v2Length({x = self.target_x - x, y = self.target_y - y}, true)
	local jump_time = math.max(self.jump_time - self.jump_end_time, 0.1)
	if self.jump_tong_bu == 1 then
		local speed = self:GetMoveSpeed()
		if speed == 0 then
			speed = 0.01
		end
		local time = distance / speed * 0.7
		if time == 0 then
			time = 0.01
		end
		jump_speed_factor = 0.8 * 1 / time
	else
		if jump_time == nil or jump_time == 0 then
			jump_time = 1
		end
		self.jump_speed = distance / jump_time

		 -- 人物实际落地帧数在22帧（共30帧）0.7 = 22 / 30
		jump_speed_factor = self.jump_animation_speed
	end

	MoveCache.task_id = 0
	Role.DoMove(self, self.target_x, self.target_y)

	if not self:IsSpecialJump() then
		self:SendMoveReq()
	end

	local main_part = self.draw_obj:GetPart(SceneObjPart.Main)
	if self.vo.mount_appeid ~= nil and self.vo.mount_appeid > 0 then
		main_part:SetFloat("jump_speed", jump_speed_factor)
		local mount_part = self.draw_obj:GetPart(SceneObjPart.Mount)
		if mount_part then
			mount_part:SetFloat("jump_speed", jump_speed_factor)
		end
	else
		local value = 1
		-- 变身状态
		if self.vo.bianshen_param == BIANSHEN_EFEECT_APPEARANCE.APPEARANCE_DATI_XIAOTU then
			value = 2
		elseif self.vo.bianshen_param == BIANSHEN_EFEECT_APPEARANCE.APPEARANCE_DATI_XIAOZHU then
			value = 2.67
		elseif self.vo.bianshen_param == BIANSHEN_EFEECT_APPEARANCE.APPEARANCE_YIZHANDAODI then		-- 一战到底小树人
			value = 2.67
		end
		main_part:SetFloat("jump_speed", value * jump_speed_factor)
	end

	if CAMERA_TYPE == CameraType.Fixed then
		if not IsNil(MainCameraFollow) then
			if self.jump_camera_fov ~= nil and self.jump_camera_fov ~= 0 then
				local sequence = DG.Tweening.DOTween.Sequence()

				sequence:Append(MainCameraFollow:DOFieldOfView(self.jump_camera_fov, (jump_time - 0.5) / 2))
				sequence:Append(MainCameraFollow:DOFieldOfView(0, (jump_time - 0.5) / 2))
			end

			if self.jump_camera_rotation ~= nil and self.jump_camera_rotation ~= 0 then
				local sequence = DG.Tweening.DOTween.Sequence()

				if self.jump_target_vo ~= nil and self.jump_target_vo.target_vo ~= nil then
					sequence:Append(MainCameraFollow:DoRotation(self.jump_camera_rotation, jump_time - 0.5))
				else
					if self.jump_camera_rotation ~= 0 then
						sequence:Append(MainCameraFollow:DoRotation(self.jump_camera_rotation, (jump_time - 0.5) / 2))
						sequence:Append(MainCameraFollow:DoRotation(0, (jump_time - 0.5) / 2))
					else
						sequence:Append(MainCameraFollow:DoRotation(0, jump_time - 0.5))
					end
				end
			end
		end
	end

	self:ShowJumpTrailRenderer()
end

-- 跳跃
function MainRole:SetJump(state)
	Character.SetJump(self, state)
	if state then
		local part = self.draw_obj:GetPart(SceneObjPart.Main)
		part:SetInteger(ANIMATOR_PARAM.STATUS, ActionStatus.Idle)
		self:StopHug()
	end
end

-- 跳跃
function MainRole:DoJump(move_mode_param)
	Character.DoJump(self, move_mode_param)
	local part = self.draw_obj:GetPart(SceneObjPart.Main)
	part:SetInteger(ANIMATOR_PARAM.STATUS, ActionStatus.Idle)
	self:StopHug()

	self:CancelJumpQuest()
	self.jump_delay_time = GlobalTimerQuest:AddDelayTimer(function ()
		self:SetJump(false)
		self.vo.move_mode = MOVE_MODE.MOVE_MODE_NORMAL
	end, 3)
end

function MainRole:DoJump2(move_mode_param)
	Character.DoJump2(self, move_mode_param)
	local part = self.draw_obj:GetPart(SceneObjPart.Main)
	part:SetInteger(ANIMATOR_PARAM.STATUS, ActionStatus.Idle)
	self:StopHug()
end

function MainRole:CancelJumpQuest()
	if self.jump_delay_time then
		GlobalTimerQuest:CancelQuest(self.jump_delay_time)
		self.jump_delay_time = nil
	end
end

function MainRole:OnJumpEnd()
	self:CancelJumpQuest()
	Role.OnJumpEnd(self)
	if self.jump_call_back then
		self.jump_call_back()
		self.jump_call_back = nil
	end
	self:HideJumpTrailRenderer()
	if self:CanHug() then
		local part = self.draw_obj:GetPart(SceneObjPart.Main)
		part:SetInteger(ANIMATOR_PARAM.STATUS, ActionStatus.Hug)
		self:DoHug()
	end
end

function MainRole:JumpTo(point_vo, target_point, next_point, call_back)
	if target_point == nil then
		print_error("target_point == nil")
		return
	end

	self:ToJumpPath()
	self.vo.move_mode = MOVE_MODE.MOVE_MODE_JUMP2
	GlobalEventSystem:Fire(OtherEventType.JUMP_STATE_CHANGE, true)
	-- 播放CG
	if point_vo.play_cg and point_vo.play_cg == 1 and not IsLowMemSystem and not CgManager.Instance:IsCgIng() then
		for k,v in pairs(point_vo.cgs) do
			if v.prof == self.vo.prof then
				self:RemoveModel(SceneObjPart.Mount)
				self:RemoveModel(SceneObjPart.FightMount)
				CgManager.Instance:Play(BaseCg.New(v.bundle_name, v.asset_name), function()
					local scene_key = PlayerData.Instance:GetAttr("scene_key") or 0
					Scene.SendSyncJump(Scene.Instance:GetSceneId(), v.position.x, v.position.y, scene_key)
					self:SetLogicPos(v.position.x, v.position.y)
					local game_obj = self:GetDrawObj():GetRoot()
					game_obj.transform.localRotation = Quaternion.Euler(0, v.rotation, 0)

					if self.mount_res_id and self.mount_res_id > 0 then
						self:ChangeModel(SceneObjPart.Mount, ResPath.GetMountModel(self.mount_res_id))
					elseif self.fight_mount_res_id and self.fight_mount_res_id > 0 then
						self:ChangeModel(SceneObjPart.FightMount, ResPath.GetFightMountModel(self.fight_mount_res_id))
					end

					self:SetJump(false)
					self.vo.move_mode = MOVE_MODE.MOVE_MODE_NORMAL
					GlobalEventSystem:Fire(OtherEventType.JUMP_STATE_CHANGE, false)
				end, nil, true)

				return
			end
		end
	end
	self.vo.jump_factor = 1
	if point_vo.jump_speed and point_vo.jump_speed > 4 then
		point_vo.jump_speed = 4
	end
	self.vo.jump_factor = point_vo.jump_speed
	self.jump_call_back = call_back
	self.target_point = target_point
	self.next_point = next_point
	self.target_x = target_point.vo.pos_x
	self.target_y = target_point.vo.pos_y
	self.jump_tong_bu = point_vo.jump_tong_bu
	self.jump_time = point_vo.jump_time
	self.jump_camera_fov = point_vo.camera_fov
	self.jump_camera_rotation = point_vo.camera_rotation
	self.jump_target_vo = point_vo.target_vo

	self.ghost_time = point_vo.jump_time

	if point_vo.jump_type == 0 then
		if point_vo.jump_tong_bu == 0 then
			self.is_special_jump = true
		else
			Scene.SendMoveMode(MOVE_MODE.MOVE_MODE_JUMP2)
		end
		local jump_act = point_vo.jump_act
		if jump_act == 0 then
			if math.random() > 0.5 then
				jump_act = 1
			else
				jump_act = 2
			end
		end
		if jump_act == 1 then
			self.jump_end_time = 0.2
			self.jump_time = point_vo.jump_time + 0.8
			self.jump_animation_speed = 1.1 / point_vo.jump_time
		elseif jump_act == 2 then
			self.jump_end_time = 0.0
			self.jump_time = point_vo.jump_time + 1
			self.jump_animation_speed = 1.7 / point_vo.jump_time
		elseif jump_act == 3 then
			self.jump_end_time = 0.0
			self.jump_time = point_vo.jump_time + 0.5
			self.jump_animation_speed = 2.0 / point_vo.jump_time
		end
		self.vo.jump_act = jump_act
		self:DoJump()
	elseif point_vo.jump_type == 1 then
		Scene.SendMoveMode(MOVE_MODE.MOVE_MODE_JUMP2, point_vo.air_craft_id)
		self.vo.move_mode_param = point_vo.air_craft_id
		FightMountCtrl.Instance:SendGoonFightMountReq(0)
		MountCtrl.Instance:SendGoonMountReq(0)
		self:DoJump(point_vo.air_craft_id)
	end

	if self.move_oper_cache2 then
		for k,v in pairs(self.move_oper_cache2.jumppoint_obj_list) do
			if v.vo.id == point_vo.id then
				self.move_oper_cache2 = nil
				self:ClearPathInfo()
				break
			end
		end
	end
	local part = self.draw_obj:GetPart(SceneObjPart.Main)
	if next_point then
		part:SetBool("jump_end", false)
	else
		part:SetBool("jump_end", true)
	end
end

-- 跳跃时的路线
function MainRole:ToJumpPath()
	local path_count = #self.path_pos_list
	if path_count > 1 then
		local x = self.path_pos_list[path_count].x
		local y = self.path_pos_list[path_count].y
		local jumppoint_obj_list = Scene.Instance:FindJumpPoint(x, y)
		self.move_oper_cache2 = {x = x, y = y, range = 0, arrive_func = self.arrive_func, jumppoint_obj_list = jumppoint_obj_list}
		self.arrive_func = nil
		self:ClearPathInfo()
	end
end

function MainRole:OnAttackPlayEnd()
	Role.OnAttackPlayEnd(self)

	if self.move_oper_cache ~= nil then
		local cache = self.move_oper_cache
		self.move_oper_cache = nil
		self:DoMoveOperate(cache.x, cache.y, cache.range, cache.arrive_func)
	end
end

function MainRole:SendMoveReq(distance)
	if self.is_only_client_move then
		return
	end

	local dir = math.atan2(self.move_dir.y, self.move_dir.x)
	distance = distance or self.move_total_distance / Config.SCENE_TILE_WIDTH
	Scene.SendMoveReq(dir, self.logic_pos.x, self.logic_pos.y, distance, self.is_chongci and 1 or 0)
end

function MainRole:SetIsOnlyClintMove(is_only_client_move)
	self.is_only_client_move = is_only_client_move
end

function MainRole:SetAttackParam(is_specialskill)
	self.is_specialskill = is_specialskill
end

function MainRole:DoAttack(skill_id, target_x, target_y, target_obj_id, target_type)
	self.arrive_func = nil
	if not self:CanAttack() then return end
	Scene.Instance:GetSceneLogic():StopAutoGather()
	Role.DoAttack(self, skill_id, target_x, target_y, target_obj_id, target_type)
end

function MainRole:EnterStateAttack( ... )
	-- 伙伴技能不播放主角动作
	if GoddessData.Instance:IsGoddessSkill(self.attack_skill_id) then
		self:OnAnimatorBegin()
		self:OnAnimatorHit()
		self:OnAnimatorEnd()
	else
		Role.EnterStateAttack(self, ...)
	end
end

function MainRole:CanAttack()
	if self:IsRealDead() or self:IsJump() or self.vo.move_mode == MOVE_MODE.MOVE_MODE_JUMP2 or
		CgManager.Instance:IsCgIng() or self:IsMultiMountPartner()
		or self:IsBingDong() then
		return false
	end

	local scene_logic = Scene.Instance:GetSceneLogic()
	if scene_logic then
		return scene_logic:CanMove()
	end

	return true
end

local skill_obj = nil
function MainRole:OnAnimatorBegin(anim_name)
	Role.OnAnimatorBegin(self, anim_name)

	local main_view = MainUICtrl.Instance.view
	local transform = nil
	if main_view then
		local dazhao_effect = main_view:GetDaZhaoEffect()
		if dazhao_effect then
			transform = dazhao_effect.transform
		end
	end
	if transform then
		if anim_name == "attack4" then
			--播放大招2D特效
			UtilU3d.PrefabLoad("effects2/prefab/ui_x/ui_effect_bishaji_prefab", "UI_effect_bishaji",
				function(obj)
					if nil == obj then
						return
					end
					obj.transform:SetParent(transform, false)
					local animator = obj.gameObject:GetComponent(typeof(UnityEngine.Animator))
					if animator then
						animator:ListenEvent("exit", function ()
							GameObject.Destroy(obj)
						end)
					end
				end)
		elseif self.attack_skill_id ~= 111 and self.attack_skill_id ~= 211 and self.attack_skill_id ~= 311
			and self.attack_skill_id ~= 411 and not GoddessData.Instance:IsGoddessSkill(self.attack_skill_id)
			and not FamousGeneralData.Instance:CheckIsGeneralSkill(self.attack_skill_id) then
			local info = SkillData.GetSkillinfoConfig(self.attack_skill_id)
			if info then
				UtilU3d.PrefabLoad("effects2/prefab/ui_x/ui_effect_skill_prefab", "UI_effect_skill",
				function(obj)
					if nil ~= skill_obj and nil ~= skill_obj.gameObject and not IsNil(skill_obj.gameObject) then
						GameObject.Destroy(skill_obj)
					end
					if not obj then
						return
					end
					skill_obj = obj
					skill_obj.transform:SetParent(transform, false)
					local panel = skill_obj.transform:Find("GameObject")
					local text1 = panel.transform:Find("Text1"):GetComponent(typeof(UnityEngine.UI.Text))
					local text2 = panel.transform:Find("Text2"):GetComponent(typeof(UnityEngine.UI.Text))
					if text1 and text2 then
						local name_tbl = CommonDataManager.StringToTable(info.skill_name)
						if #name_tbl > 3 then
							text1.text = name_tbl[1] .. name_tbl[2]
							text2.text = name_tbl[3] .. name_tbl[4]
						end
					end
					local animator = skill_obj.gameObject:GetComponent(typeof(UnityEngine.Animator))
					if animator then
						animator:ListenEvent("exit", function ()
							skill_obj = nil
							GameObject.Destroy(obj)
						end)
					end
				end)
			end
		end
	end

	-- 温泉扔雪球不应该进来这段代码
	if Scene.Instance:GetSceneType() ~= SceneType.HotSpring then
		if self:IsAtk() then
			local scene_obj = self.attack_target_obj
			-- 如果对方有问题，则找个附近的攻击
			if not scene_obj or not scene_obj:IsCharacter() or scene_obj:IsRealDead() then
				-- 直接使用挂机的，会不会选择了太远的目标？
				scene_obj = GuajiCtrl.Instance:SelectAtkTarget(true)
			end

			if nil ~= scene_obj and scene_obj:IsCharacter() and not scene_obj:IsRealDead() then
				-- if self.attack_skill_id and self.attack_skill_id ~= 221 and self.attack_skill_id ~= 321 and self.attack_skill_id ~= 211 then
				-- 	SkillData.Instance:UseSkill(self.attack_skill_id)
				-- end
				self.last_skill_id = self.attack_skill_id
				self.atk_is_hit[self.attack_skill_id] = false

				local target_robert = nil
				if self ~= scene_obj then
					target_robert = RobertManager.Instance:GetRobert(scene_obj:GetObjId())
				end

				if nil ~= target_robert then -- 与机器人的战斗不通过服务器
					local attack_robert = RobertManager.Instance:GetRobert(self:GetObjId())
					self.last_skill_index = self.attack_index
					RobertManager.Instance:ReqFight(attack_robert, target_robert, self.attack_skill_id, self.attack_index)
				else
					self.is_specialskill = self.is_specialskill or PlayerData.Instance.role_vo.special_appearance == SPECIAL_APPEARANCE_TYPE.SPECIAL_APPERANCE_TYPE_TERRITORYWAR
					self.last_skill_index = self.attack_index
					FightCtrl.SendPerformSkillReq(
						SkillData.Instance:GetRealSkillIndex(self.attack_skill_id),
						self.attack_index,
						self.attack_target_pos_x,
						self.attack_target_pos_y,
						scene_obj:GetObjId(),
						self.is_specialskill,
						self.logic_pos.x,
						self.logic_pos.y)
				end
			end
		end
	end

	local part = self.draw_obj:GetPart(SceneObjPart.Main)
	if nil ~= part then
		if anim_name == "combo1_1" then
			part:SetBool(ANIMATOR_PARAM.COMBO1_1_BACK, false)
		elseif anim_name == "combo1_2" then
			part:SetBool(ANIMATOR_PARAM.COMBO1_2_BACK, false)
		end
	end
end

function MainRole:OnAnimatorHit(anim_name)
	if self:IsAtk() then
		self.atk_is_hit[self.attack_skill_id] = true

		if self:CanAttack() then
			local info_cfg = SkillData.GetSkillinfoConfig(self.attack_skill_id)
			if info_cfg ~= nil then
				if info_cfg.hit_count > 1 then
					self.attack_index = self.attack_index + 1
					if self.attack_index > info_cfg.hit_count then
						self.attack_index = 1
					end
				end
			end
		end
	end

	Role.OnAnimatorHit(self, anim_name)
end

function MainRole:OnAnimatorEnd(anim_name)
	if self:IsAtk() then
		self.last_atk_end_time = Status.NowTime
	end
	Role.OnAnimatorEnd(self, anim_name)

	if anim_name == "combo1_1" or anim_name == "combo1_2" then
		local part = self.draw_obj:GetPart(SceneObjPart.Main)
		GlobalTimerQuest:AddDelayTimer(function()
			if nil ~= part then
				if anim_name == "combo1_1" then
					part:SetBool(ANIMATOR_PARAM.COMBO1_1_BACK, true)
				elseif anim_name == "combo1_2" then
					part:SetBool(ANIMATOR_PARAM.COMBO1_2_BACK, true)
				end
			end
		end, 0.1)
	end
end

function MainRole:OnAttackHit(attack_skill_id, attack_target_obj)
	Role.OnAttackHit(self, attack_skill_id, attack_target_obj)

	local scene_obj = attack_target_obj
	if nil ~= scene_obj and scene_obj:IsCharacter() then
		local deliverer = Scene.Instance:GetObj(self.vo.obj_id)
		scene_obj:DoBeHitShow(
			deliverer, attack_skill_id, scene_obj:GetObjId())
	end
end

function MainRole:GetLastSkillId()
	return self.last_skill_id
end

function MainRole:AtkIsHit(skill_id)
	return self.atk_is_hit and self.atk_is_hit[skill_id]
end

function MainRole:GetLastAtkEndTime()
	return self.last_atk_end_time
end

function MainRole:EnterStateDead()
	Role.EnterStateDead(self)
	if self.vo.move_mode == MOVE_MODE.MOVE_MODE_JUMP2 then
		self.vo.move_mode = MOVE_MODE.MOVE_MODE_NORMAL
		GlobalEventSystem:Fire(OtherEventType.JUMP_STATE_CHANGE, false)
		self:ClearJumpCache()
	end
	MountCtrl.Instance:SendGoonMountReq(0)
	GlobalEventSystem:Fire(ObjectEventType.MAIN_ROLE_DEAD, self)
end

function MainRole:OnRealive()
	Role.OnRealive(self)
	if Scene.Instance then
		Scene.Instance:GetSceneLogic():OnMainRoleRealive()
	end
	GlobalEventSystem:Fire(ObjectEventType.MAIN_ROLE_REALIVE, self)
end

local old_value = nil
function MainRole:SetAttr(key, value)
	old_value = self.vo[key]
	PlayerData.Instance:SetAttr(key, value)
	Role.SetAttr(self, key, value)
	if key == "level" then
		if old_value == nil or value > old_value then
			self:AddBuff(BUFF_TYPE.UP_LEVEL)
			local audio_config = AudioData.Instance:GetAudioConfig()
			if audio_config then
				AudioManager.PlayAndForget(AssetID("audios/sfxs/other", audio_config.other[1].Level_up))
			end
			self.add_level_eff_time = Status.NowTime
		end
		GlobalEventSystem:Fire(ObjectEventType.LEVEL_CHANGE, self, value, old_value)
		if not IS_ON_CROSSSERVER then
			ReportManager:ReportRoleInfo(self.vo.server_id, self.vo.name, self.vo.role_id, value, "", "levelChange")
		end
	end
	if key == "move_speed" then
		if old_value ~= value and self:IsMove() then
			if self.path_pos_list and #self.path_pos_list > 0 then
				local pos = self.path_pos_list[self.path_pos_index]
				if nil ~= pos then
					Role.DoMove(self, pos.x, pos.y)
					self:SendMoveReq()
				end
			end
		end
	end
	if key == "bianshen_param" then
		if value > 0 then
			if self.vo.mount_appeid and self.vo.mount_appeid > 0 then
				MountCtrl.Instance:SendGoonMountReq(0)
			end
			if self.vo.fight_mount_appeid and self.vo.fight_mount_appeid > 0 then
				FightMountCtrl.Instance:SendGoonFightMountReq(0)
			end
		end
	elseif key == "task_appearn" then
		if self.vo.task_appearn > 0 then
			FightMountCtrl.Instance:SendGoonFightMountReq(0)
			MountCtrl.Instance:SendGoonMountReq(0)
		end
		if old_value <= 0 and self.vo.task_appearn > 0 then
			if self.vo.task_appearn == CHANGE_MODE_TASK_TYPE.TALK_TO_NPC then
				self:SetHugNpcActive(false)
			end
			if self.vo.task_appearn == CHANGE_MODE_TASK_TYPE.GATHER and self.vo.task_appearn_param_1 == TaskData.PIG_ID then --小猪猪写死id
				self:SetHugNpcActive(false)
			end
			-- 抱花任务特殊处理
			GlobalEventSystem:Fire(SettingEventType.MAIN_CAMERA_MODE_CHANGE, nil, 3)
		elseif old_value > 0 and self.vo.task_appearn <= 0 then
			if old_value == CHANGE_MODE_TASK_TYPE.TALK_TO_NPC then
				self:SetHugNpcActive(true)
			end
			if self.vo.task_appearn == CHANGE_MODE_TASK_TYPE.GATHER and self.vo.task_appearn_param_1 == TaskData.PIG_ID then --小猪猪写死id
				self:SetHugNpcActive(true)
			end
			GlobalEventSystem:Fire(SettingEventType.MAIN_CAMERA_MODE_CHANGE)
		end
	elseif key == "guild_id" then
		if value <= 0 then
			--退出了仙盟，清空所有仙盟相关的聊天消息
			ChatData.Instance:RemoveMsgToGuild()
		end
	end
end

--将场景上所抱隐藏或显示
function MainRole:SetHugNpcActive(value)
	if not CgManager.Instance:IsCgIng() then
		if self.vo.task_appearn == CHANGE_MODE_TASK_TYPE.TALK_TO_NPC then
			for k,v in pairs(Scene.Instance:GetNpcList()) do
				if v:GetNpcId() == self.vo.task_appearn_param_1 or value then
					v:GetDrawObj():SetVisible(value)
					if v.select_effect then
						v.select_effect:SetActive(value)
					end
					v:ReloadUIName()
					break
				end
			end
		elseif self.vo.task_appearn == CHANGE_MODE_TASK_TYPE.GATHER then
			for k,v in pairs(Scene.Instance:GetGatherList()) do
				if v:GetGatherId() == TaskData.PIG_ID or value then
					v:GetDrawObj():SetVisible(value)
					break
				end
			end
		end
	end
end


function MainRole:GetPathPosList()
	return self.path_pos_list
end

function MainRole:GetPathPosIndex()
	return self.path_pos_index
end

function MainRole:StopMove()
	self.arrive_func = nil
	self.move_oper_cache = nil
	self:ClearPathInfo()
	if self:IsMove() then
		self:ChangeToCommonState()
	end
end

function MainRole:ContinuePath()
	self.is_special_jump = false
	if MoveCache.task_id and MoveCache.task_id > 0 then
		GuajiCache.monster_id = 0
		TaskCtrl.Instance:DoTask(MoveCache.task_id)
		self:ClearJumpCache()
		return
	end
	if self.move_oper_cache2 then
		local cache = self.move_oper_cache2
		self:ClearJumpCache()
		GlobalTimerQuest:AddDelayTimer(function() self:DoMoveOperate(cache.x, cache.y, cache.range, cache.arrive_func) end, 0.1)
	end
end

function MainRole:ClearJumpCache()
	self.jump_call_back = nil
	self.move_oper_cache2 = nil
end

function MainRole:IsSpecialJump()
	return self.is_special_jump
end

function MainRole:GetMoveSpeed()
	if self.vo.move_mode == MOVE_MODE.MOVE_MODE_JUMP2 and self.jump_tong_bu == 0 and self.jump_speed and self.jump_speed > 0 then
		return self.jump_speed
	else
		local speed = Scene.ServerSpeedToClient(self.vo.move_speed) + self.special_speed
		if self.is_jump or self.vo.move_mode == MOVE_MODE.MOVE_MODE_JUMP2 then
			if self.vo.jump_factor then
				speed = self.vo.jump_factor * speed
			else
				speed = 1.8 * speed
			end
		end
		local main_part = self.draw_obj:GetPart(SceneObjPart.Main)
		local obj = main_part:GetObj()
		if obj and not IsNil(obj.gameObject) and obj.animator then
			if obj.animator:GetBool("fight") then
				speed = speed * 1.055
			end
			-- 冲刺状态
			if obj.animator:GetLayerWeight(ANIMATOR_PARAM.CHONGCI_LAYER) > 0 then
				speed = COMMON_CONSTS.CHONGCI_SPEED
			end
		end
		return speed
	end
end

function MainRole:GetLastSkillIndex()
	return self.last_skill_index
end

function MainRole:GetTotalStandTime()
	return self.total_stand_time
end

function MainRole:ShowJumpTrailRenderer()
	local renderer1, renderer2 = self:FindTrailRenderer()
	if nil == renderer1 or nil == renderer2 then
		return
	end

	local function StartShow()
		self.trail_renderer1 = renderer1.gameObject:AddComponent(typeof(UnityEngine.TrailRenderer))
		if self.trail_renderer1 then
			self.trail_renderer1.material = self.material
			self.trail_renderer1.time = 0.32
			self.trail_renderer1.startWidth = 1
			self.trail_renderer1.endWidth = 1
		end
		self.trail_renderer2 = renderer2.gameObject:AddComponent(typeof(UnityEngine.TrailRenderer))
		if self.trail_renderer2 then
			self.trail_renderer2.material = self.material
			self.trail_renderer2.time = 0.32
			self.trail_renderer2.startWidth = 1
			self.trail_renderer2.endWidth = 1
		end
	end

	if nil == self.material then
		MaterialPool.Instance:Load(AssetID("effects/materials", MATERIAL_ID_LIST[self.vo.prof]), function(material)
			if nil == material then
				return
			end

			self.material = material
			StartShow()
		end)
	else
		StartShow()
	end
end

function MainRole:HideJumpTrailRenderer()
	if self.trail_renderer1 then
		GameObject.Destroy(self.trail_renderer1)
		self.trail_renderer1 = nil
	end
	if self.trail_renderer2 then
		GameObject.Destroy(self.trail_renderer2)
		self.trail_renderer2 = nil
	end
end

function MainRole:FindTrailRenderer()
	local main_part = self.draw_obj:GetPart(SceneObjPart.Main)
	local obj = main_part:GetAttachPoint(AttachPoint.BuffMiddle)
	if nil ~= obj and not IsNil(obj.gameObject) then
		local renderer1 = obj.transform:Find("JumpTrailRenderer1")
		local renderer2 = obj.transform:Find("JumpTrailRenderer2")
		return renderer1, renderer2
	end
end

function MainRole:SetMountOtherObjId(mount_other_objid)
	Role.SetMountOtherObjId(self, mount_other_objid)
	self:UpdateCameraFollowTarget(true)
	local role = Scene.Instance:GetRoleByObjId(mount_other_objid)
	if role then
		role.draw_obj:SetVisible(true)
	end
end

function MainRole:UpdateCameraFollowTarget(immediate)
	if self.is_inter_scene then
		if not IsNil(MainCameraFollow) then
			Scheduler.Delay(function()
				if not IsNil(MainCameraFollow) and not self:IsDeleted() then
					local target_point = self:GetRoot() and self:GetRoot().transform or nil
					local owner_role = self:GetMountOwnerRole()
					if owner_role then
						target_point = owner_role:GetRoot().transform
					else
						if CAMERA_TYPE == CameraType.Free then
							local height = self:GetLookAtPointHeight()
							local point = self.draw_obj:GetLookAtPoint(height)
							target_point = point and point or target_point
						end
					end
					MainCameraFollow.Target = target_point
					if immediate then
						MainCameraFollow:SyncImmediate()
					end
				end
			end)
		else
			print_log("The main camera does not have CameraFollow component.")
		end
	end
end

function MainRole:OnModelLoaded(part, obj)
	Role.OnModelLoaded(self, part, obj)
	if part == SceneObjPart.Main then
		if nil ~= CharacterGhost then
			local scene_obj_layer = GameObject.Find("GameRoot/SceneObjLayer").transform
			self.character_ghost = CharacterGhost.Bind(obj.gameObject)
			if self.character_ghost then
				self.character_ghost.Root = scene_obj_layer
				local mesh_renderers = obj:GetComponentsInChildren(typeof(UnityEngine.SkinnedMeshRenderer))
				local material = ResPreload["role_ghost_" .. self.vo.prof]
				self.character_ghost.Material = material
				self.character_ghost:SetSpeedFactor(3)
			end
		end

		self:UpdateCameraFollowTarget()
		if self.vo.move_mode == MOVE_MODE.MOVE_MODE_JUMP2 then
			local main_part = self.draw_obj:GetPart(SceneObjPart.Main)
			if self.jump_name and self.jump_normalized_time then
				main_part:Play(self.jump_name, ANIMATOR_PARAM.BASE_LAYER, self.jump_normalized_time)
				self.jump_name = nil
				self.jump_normalized_time = nil
			end
		end
	end

	if part == SceneObjPart.Mount or part == SceneObjPart.FightMount then
		self:UpdateCameraFollowTarget()
	end
end

function MainRole:OnModelRemove(part, obj)
	Role.OnModelRemove(part, obj)
	if part == SceneObjPart.Mount or part == SceneObjPart.FightMount then
		self:UpdateCameraFollowTarget()
	end

	if part == SceneObjPart.Main then
		-- 如果在跳跃中换角色模型，会使Animator的状态丢失，导致卡在跳跃点
		-- 所以在切换模型时记录Animator的状态，等模型加载完成时还原回去
		if self.vo.move_mode == MOVE_MODE.MOVE_MODE_JUMP2 then
			local main_part = self.draw_obj:GetPart(SceneObjPart.Main)
			local animation_info = main_part:GetAnimationInfo(ANIMATOR_PARAM.BASE_LAYER)
			if animation_info then
				self.jump_name = animation_info.shortNameHash
				self.jump_normalized_time = animation_info.normalizedTime
			end
		end
	end
end

function MainRole:ShowGhost(_type, maxGhostNum, maxConcurrentGhostNum, timeInterval)
	_type = _type or 0
	maxGhostNum = maxGhostNum or 10
	maxConcurrentGhostNum = maxConcurrentGhostNum or 8
	timeInterval = timeInterval or 0.1
	if self.character_ghost then
		self.character_ghost:ShowGhost(_type, maxGhostNum, maxConcurrentGhostNum, timeInterval)
	end
end

function MainRole:StopGhost(time)
	time = time or 0
	if self.character_ghost then
		self.character_ghost:Stop(time)
	end
end

function MainRole:ChangeChongCi(state)
	Role.ChangeChongCi(self, state)
	if state then
		self:ShowGhost(1, 50, 5, 0.02)
	elseif self.is_chongci then
		self:StopGhost()
	end
end

function MainRole:EnterFightState()
	-- 记录进入战斗状态前的坐骑状态
	-- 1：普通坐骑 2：战斗坐骑
	if self.vo.mount_appeid and self.vo.mount_appeid > 0 then
		self.last_mount_state = 1
	elseif self.vo.fight_mount_appeid and self.vo.fight_mount_appeid > 0 then
		self.last_mount_state = 2
	else
		self.last_mount_state = 0
	end
	MountCtrl.Instance:SendGoonMountReq(0)
	if nil ~= self.vo.mount_appeid and self.vo.mount_appeid > 0 then
		FightMountCtrl.Instance:SendGoonFightMountReq(1)
	end
	Role.EnterFightState(self)
end

function MainRole:LeaveFightState()
	-- 脱战后恢复战斗前的坐骑状态
	if self.last_mount_state == 1 then
		FightMountCtrl.Instance:SendGoonFightMountReq(0)
		MountCtrl.Instance:SendGoonMountReq(1)
	elseif self.last_mount_state == 2 then
		MountCtrl.Instance:SendGoonMountReq(0)
		FightMountCtrl.Instance:SendGoonFightMountReq(1)
	end
	Role.LeaveFightState(self)
end

function MainRole:GetLookAtPointHeight()
	local height = 2
	local point = self.draw_obj:GetAttachPoint(AttachPoint.BuffMiddle)
	if point and not IsNil(point.gameObject) then
		local root = self.draw_obj:GetRoot()
		if root and not IsNil(root.gameObject) then
			height = point.transform.position.y - root.transform.position.y
		end
	end
	return height
end

function MainRole:EnterWater(is_in_water)
	Role.EnterWater(self, is_in_water)
	self:UpdateCameraFollowTarget()
end

function MainRole:IsMarriage()
	if self.vo.lover_uid ~= 0 then
		return true
	else
		return false
	end
end