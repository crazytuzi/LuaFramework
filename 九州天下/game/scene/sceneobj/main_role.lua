MainRole = MainRole or BaseClass(Role)

function MainRole:__init(vo)
	self.obj_type = SceneObjType.MainRole
	self.draw_obj:SetObjType(self.obj_type)

	self.arrive_func = nil							-- 到达处理
	self.move_oper_cache = nil						-- 移动操作缓存
	self.move_oper_cache2 = nil  					-- 跳跃操作缓存
	self.move_cache_on_chongefeng_end = nil			-- 冲锋操作缓存
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
	self.is_auto_move = false					-- 是否自动寻路中

	self.is_specialskil = false
	self.is_special_jump = false

	self.jump_call_back = nil
	self.target_point = nil
	self.next_point = nil

	self.target_x = 0
	self.target_y = 0

	self.total_stand_time = 0
	self.is_inter_scene = false

	self.chongfeng_callback = nil
	self.chongfeng_req_time = 0
end

function MainRole:__delete()
	-- if self.timer_quest then
	-- 	GlobalTimerQuest:CancelQuest(self.timer_quest)
	-- 	self.timer_quest = nil
	-- end
	if not IsNil(MainCamera) then
		local camera_follow = MainCamera:GetComponentInParent(typeof(CameraFollow))
		if nil ~= camera_follow then
			camera_follow.Target = nil
		end
	end
	if not IsNil(MainCameraFollow) then
		MainCameraFollow.Target = nil
	end
	self.is_inter_scene = false
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
		self.total_stand_time = self.total_stand_time + elapse_time
	else
		self.total_stand_time = 0
	end

	-- 冲锋发起请求，服务器如不通过，一段时间后失效
	if self.chongfeng_req_time > 0 and now_time >= self.chongfeng_req_time + 1 then
		self.chongfeng_req_time = 0
		self.move_cache_on_chongefeng_end = nil
	end
end

function MainRole:OnEnterScene()
	Role.OnEnterScene(self)
	self.is_inter_scene = true
	self:UpdateCameraFollowTarget(true)

	self:GetFollowUi()
	-- self:UpdateMainRoleMoveSpeed()
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

	GuajiCtrl.Instance:DoMoveByClick(...)
	self:ClearPathInfo()
	self.attack_skill_id = 0
	GlobalEventSystem:Fire(OtherEventType.MOVE_BY_CLICK)
	return self:DoMoveOperate(...)
end

function MainRole:DoMoveOperate(x, y, range, arrive_func, is_auto_move)
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
		if self:IsAtkPlaying() then
			self.move_oper_cache = {x = x, y = y, range = range, arrive_func = arrive_func, is_auto_move = is_auto_move}
		end

		if self:IsChongfenging() then
			self.move_cache_on_chongefeng_end = {x = x, y = y, range = range, arrive_func = arrive_func, is_auto_move = is_auto_move}
		end
		return false
	end

	x, y = AStarFindWay:GetAroundVaildXY(x, y, 3)
	x, y = AStarFindWay:GetLineEndXY2(self.logic_pos.x, self.logic_pos.y, x, y)

	local move_x, move_y = x, y
	if not AStarFindWay:IsWayLine(self.logic_pos.x, self.logic_pos.y, x, y) then
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
	else
		self.path_pos_index = 1
		self.path_pos_list = {{x = move_x, y = move_y}}
	end

	self.is_auto_move = is_auto_move or false

	if arrive_func then
		self.arrive_func = arrive_func
	end

	--策划需求70之后，玩家操作不收起右上角Buttons
	local main_role_vo = GameVoManager.Instance:GetMainRoleVo()
	if main_role_vo.level < 70 then
		GlobalEventSystem:Fire(MainUIEventType.SHOW_OR_HIDE_SHRINK_BUTTON, false)
	end

	Role.DoMove(self, move_x, move_y)
	self:SendMoveReq()
end

local skill_can_move = false
function MainRole:CanDoMove()
	skill_can_move = SkillData.GetSkillCanMove(self.last_skill_id)
	if self:IsRealDead() or self:IsDead() or (self:IsAtk() and not skill_can_move) or self.is_special_move or self:IsJump() or self.vo.move_mode == MOVE_MODE.MOVE_MODE_JUMP2 or
		(self:IsAtkPlaying() and not skill_can_move) or CgManager.Instance:IsCgIng() or self:IsMultiMountPartner() then
		return false
	end

	local logic = Scene.Instance:GetSceneLogic()
	if logic and not logic:CanCancleAutoGuaji() then
		return false
	end

	-- Buff 效果判断
	if self:IsDingShen() or self:IsXuanYun() then
		-- print_log("定身或者眩晕中无法移动. ")
		return false
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
		Role.DoMove(self, pos.x, pos.y, self.path_pos_index)
		self:SendMoveReq()
		return false
	end

	self.is_auto_move = false
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

	if self.vo.multi_mount_res_id >= 0 then --双人坐骑跳跃时
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

		local real_end_time = self.jump_end_time or 0
		local jump_time = math.max(self.jump_time - real_end_time, 0.1)
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
end

function MainRole:OnJumpEnd()
	Role.OnJumpEnd(self)
	if self.jump_call_back then
		self.jump_call_back()
		self.jump_call_back = nil
	end
end

function MainRole:JumpTo(point_vo, target_point, next_point, call_back)
	if target_point == nil then
		print_error("target_point == nil")
		return
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
	self.vo.move_mode = MOVE_MODE.MOVE_MODE_JUMP2
	GlobalEventSystem:Fire(OtherEventType.JUMP_STATE_CHANGE, true)
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
		elseif jump_act == 1 then
			self.jump_end_time = 0.2
			self.jump_time = point_vo.jump_time + 0.8
			self.jump_animation_speed = 1.2 / point_vo.jump_time
		elseif jump_act == 2 then
			self.jump_end_time = 0.0
			self.jump_time = point_vo.jump_time + 0.5
			self.jump_animation_speed = 2.0 / point_vo.jump_time
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
	self:ToJumpPath()
	if self.move_oper_cache2 then
		for k,v in pairs(self.move_oper_cache2.jumppoint_obj_list) do
			if v.vo.id == point_vo.id then
				self.move_oper_cache2 = nil
				self:ClearPathInfo()
				break
			end
		end
	end
end

-- 跳跃时的路线
function MainRole:ToJumpPath()
	local path_count = #self.path_pos_list
	if path_count > 1 then
		local x = self.path_pos_list[path_count].x
		local y = self.path_pos_list[path_count].y
		local jumppoint_obj_list = Scene.Instance:FindJumpPoint(x, y)
		self.move_oper_cache2 = {x = x, y = y, range = 0, arrive_func = self.arrive_func, jumppoint_obj_list = jumppoint_obj_list, is_auto_move = self.is_auto_move}
		self.arrive_func = nil
		self:ClearPathInfo()
	end
end

function MainRole:OnAttackPlayEnd()
	Role.OnAttackPlayEnd(self)

	if self.move_oper_cache ~= nil then
		local cache = self.move_oper_cache
		self.move_oper_cache = nil
		self:DoMoveOperate(cache.x, cache.y, cache.range, cache.arrive_func, cache.is_auto_move)
	end
end

function MainRole:SendMoveReq(distance)
	if self.is_only_client_move then
		return
	end

	local dir = math.atan2(self.move_dir.y, self.move_dir.x)
	distance = distance or self.move_total_distance / Config.SCENE_TILE_WIDTH
	local is_speed_up = self:IsAutoMove() and 1 or 0

	Scene.SendMoveReq(dir, self.logic_pos.x, self.logic_pos.y, distance, is_speed_up)
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
	Role.DoAttack(self, skill_id, target_x, target_y, target_obj_id, target_type)
end

function MainRole:CanAttack()
	if self:IsRealDead() or self:IsJump() or self.vo.move_mode == MOVE_MODE.MOVE_MODE_JUMP2 or self:IsBianxingFool() or self:IsXuanYun() or self:IsDingShen() or
		CgManager.Instance:IsCgIng() or self:IsMultiMountPartner()  then
		return false
	end

	return true
end

function MainRole:OnAnimatorBegin()
	Role.OnAnimatorBegin(self)
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
			local is_team = RoleSkillData.Instance and RoleSkillData.Instance:CheckIsTeamSkill(self.attack_skill_id)
			local is_guild_fb = Scene.Instance:GetSceneType() == SceneType.GuideFb
			local target_robert = RobertManager.Instance:GetRobert(scene_obj:GetObjId())
			--组队技能是以自己为目标的，可是在一开始，会创建一个主角的机器人，在使用组队技能时会进入下面的逻辑，所以在不是假副本的情况下，组队技能不进入下面的逻辑
			if nil ~= target_robert and not (not is_guild_fb and is_team) then -- 与机器人的战斗不通过服务器
				local attack_robert = RobertManager.Instance:GetRobert(self:GetObjId())
				RobertManager.Instance:ReqFight(attack_robert, target_robert, self.attack_skill_id, self.attack_index)
				self.last_skill_index = self.attack_index
			else
				self.is_specialskill = self.is_specialskill or PlayerData.Instance.role_vo.special_appearance == SPECIAL_APPEARANCE_TYPE.SPECIAL_APPERANCE_TYPE_TERRITORYWAR
					self.last_skill_index = self.attack_index

					FightCtrl.SendPerformSkillReq(
						SkillData.Instance:GetRealSkillIndex(self.attack_skill_id, true),
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

function MainRole:OnSkillHandle(skill_id)
	local scene_obj = self.attack_target_obj
	if nil ~= scene_obj and scene_obj:IsCharacter() and not scene_obj:IsRealDead() then
		FightCtrl.SendPerformSkillReq(
		SkillData.Instance:GetRealSkillIndex(skill_id, true),
		self.attack_index,
		self.attack_target_pos_x,
		self.attack_target_pos_y,
		scene_obj:GetObjId(),
		self.is_specialskill,
		self.logic_pos.x,
		self.logic_pos.y)
	end
end

function MainRole:OnAnimatorHit()
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

	Role.OnAnimatorHit(self)
end

function MainRole:OnAnimatorEnd()
	if self:IsAtk() then
		self.last_atk_end_time = Status.NowTime
	end
	Role.OnAnimatorEnd(self)
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
	TipsCtrl.Instance:PauseBuffTimer()
	--ReviveCtrl.Instance:PauseTimer()
end

function MainRole:OnRealive()
	Role.OnRealive(self)
	Scene.Instance:GetSceneLogic():OnMainRoleRealive()
	GlobalEventSystem:Fire(ObjectEventType.MAIN_ROLE_REALIVE, self)
	TipsCtrl.Instance:FlushBuffView()
	--ReviveCtrl.Instance:FlushView()
end

local old_value = nil
function MainRole:SetAttr(key, value)
	old_value = self.vo[key]
	if nil ~= PlayerData.Instance then
		PlayerData.Instance:SetAttr(key, value)
	end
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
		GlobalEventSystem:Fire(ObjectEventType.LEVEL_CHANGE, self, value)
	end
	if key == "move_speed" then
		-- self:UpdateMainRoleMoveSpeed()
		if self:IsMove() then
			if self.path_pos_list and #self.path_pos_list > 0 then
				local pos = self.path_pos_list[self.path_pos_index]
				if nil ~= pos then
					Role.DoMove(self, pos.x, pos.y, self.path_pos_index)
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
	end
	if key == "hold_beauty_npcid" then
		if DayCounterCtrl.Instance:GetLockOpenTaskRewardPanel() then
			return
		end
		if PlayerData.Instance.role_vo.hold_beauty_npcid <= 0 then
			GlobalEventSystem:Fire(SettingEventType.MAIN_CAMERA_MODE_CHANGE)
		else
			GlobalEventSystem:Fire(SettingEventType.MAIN_CAMERA_MODE_CHANGE, nil, 3)
		end
		-- 抱花任务特殊处理
		-- GlobalEventSystem:Fire(SettingEventType.MAIN_CAMERA_MODE_CHANGE, nil, 3)
	end
end

-- 暂时屏蔽人物移动改变移动速度频率
function MainRole:UpdateMainRoleMoveSpeed()
	-- 设置人物模型移动速度
	local main_part = self.draw_obj:GetPart(SceneObjPart.Main)
	if main_part then
		local speed = Scene.ServerSpeedToClient(self.vo.move_speed)
		local move_speed_type = 1
		if (self.vo.mount_appeid and self.vo.mount_appeid > 0) or (self.vo.fight_mount_appeid and self.vo.fight_mount_appeid > 0) then
			move_speed_type = Config.SCENE_MOUNT_MOVE_SPEED
		else
			move_speed_type = Config.SCENE_ROLE_MOVE_SPEED
		end
		local role_move_speed = speed / Scene.ServerSpeedToClient(move_speed_type)
		main_part:SetFloat("speed", role_move_speed)
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
	if self.move_oper_cache2 then
		local cache = self.move_oper_cache2
		self.move_oper_cache2 = nil
		self.jump_call_back = nil
		GlobalTimerQuest:AddDelayTimer(function() self:DoMoveOperate(cache.x, cache.y, cache.range, cache.arrive_func, cache.is_auto_move) end, 0.1)
	-- else
	-- 	GuajiCtrl.Instance:ClearAllOperate()
	end
end

function MainRole:ClearJumpCache()
	self.jump_call_back = nil
	self.move_oper_cache2 = nil
end

function MainRole:ClearAutoMove()
	self.is_auto_move = false
end

function MainRole:IsSpecialJump()
	return self.is_special_jump
end

function MainRole:GetMoveSpeed()
	if self.vo.move_mode == MOVE_MODE.MOVE_MODE_JUMP2 and self.jump_tong_bu == 0 and self.jump_speed and self.jump_speed > 0 then
		return self.jump_speed
	else
		local speed = Scene.ServerSpeedToClient(self.vo.move_speed + self.special_speed)
		if self.is_jump or self.vo.move_mode == MOVE_MODE.MOVE_MODE_JUMP2 then
			if self.vo.jump_factor then
				speed = self.vo.jump_factor * speed
			else
				speed = 1.8 * speed
			end
		end
		return speed
	end
end

-- 是否自动寻路
function MainRole:IsAutoMove()
	return self.is_auto_move
end

function MainRole:GetLastSkillIndex()
	return self.last_skill_index
end

function MainRole:GetTotalStandTime()
	return self.total_stand_time
end

-- 修复MeshRenderer被隐藏的bug
function MainRole:FixMeshRendererBug()
	if self.draw_obj then
		-- 取到主角身上所有部件
		for k,v in pairs(SceneObjPart) do
			local part_obj = self.draw_obj:_TryGetPartObj(v)
			if part_obj then
				local mesh_renderer_list = part_obj.gameObject:GetComponentsInChildren(typeof(UnityEngine.SkinnedMeshRenderer))
				-- 把每个meshRenderer的Enabled强制设为true
				for i = 0, mesh_renderer_list.Length - 1 do
					local mesh_renderer = mesh_renderer_list[i]
					if mesh_renderer then
						mesh_renderer.enabled = true
					end
				end
			end
		end
	end
end


function MainRole:IsChongfenging()
	return self.chongfeng_req_time > 0 or self.is_special_move
end

-- 请求冲锋到目标
function MainRole:ReqChongfengToObj(target_obj, end_func)
	local is_on_chongfeng = self:GetIsSpecialMove()
	if is_on_chongfeng or self.chongfeng_req_time > 0 then
		return false
	end

	local real_end_pos = GameMapHelper.GetRealChongFengLogicPos(self.real_pos, target_obj.real_pos, 2)
	if nil == real_end_pos or self.logic_pos.x == real_end_pos.x and self.logic_pos.y == real_end_pos.y then
		return false
	end

	MountCtrl.Instance:SendGoonMountReq(0)
	self.move_cache_on_chongefeng_end = nil
	self.move_end_func = nil
	self:ClearPathInfo()
	self:SendMoveReq()
	self:ChangeToCommonState()

	self.chongfeng_req_time = Status.NowTime
	self.chongfeng_callback = end_func

	FightCtrl.Instance:SendChongfengReq(target_obj:GetObjId())

	return true
end

-- 冲锋到目标点
function MainRole:ChongfengToXY(logic_x, logic_y)
	if 0 == self.chongfeng_req_time then
		return
	end

	self.chongfeng_req_time = 0 -- 一返回就清理

	local world_x, world_y = GameMapHelper.LogicToWorld(logic_x, logic_y)
	local target_real_pos = Vector2(world_x, world_y)

	local real_end_pos = GameMapHelper.GetRealChongFengLogicPos(self.real_pos, target_real_pos, 2)
	if nil == real_end_pos or (self.logic_pos.x == real_end_pos.x and self.logic_pos.y == real_end_pos.y) then
		return
	end

	self.move_end_func = nil
	self:ClearPathInfo()
	self:ChangeToCommonState()

	self:SetStatusChongFeng()
	self:OnSkillResetPos(0, 0, real_end_pos.x, real_end_pos.y)
	self:SetSpeicalMoveSpeed(COMMON_CONSTS.CHONGFENG_SPEED)
	self:SetSpeicalMoveCallBack(self.chongfeng_callback)
	
end

function MainRole:OnSpecialMoveEnd()
	if nil ~= self.chongfeng_callback then
		self.chongfeng_callback(self)
		self.chongfeng_callback = nil
	end

	if self.move_cache_on_chongefeng_end ~= nil then
		self:DoMoveOperate(self.move_cache_on_chongefeng_end.x, self.move_cache_on_chongefeng_end.y, self.move_cache_on_chongefeng_end.range, 
			self.move_cache_on_chongefeng_end.arrive_func, self.move_cache_on_chongefeng_end.is_auto_move)
		self.move_cache_on_chongefeng_end = nil
	end
end

-- 名将挂机的时候如果在普攻连击的中间使用技能再使用普攻 会导致状态机状态切换有问题
-- 比如使用完技能之后 attack_index可能是3 那就无法直接进入普攻第三段 会导致名剑在那里傻站着 所以每次放完技能手动重置一下
function MainRole:ResetAttackIndex()
	self.attack_index = 1
end

-- function MainRole:SetMountOtherObjId(mount_other_objid)
-- 	--Role.SetMountOtherObjId(self, mount_other_objid)
-- 	self:UpdateCameraFollowTarget(true)
-- end

function MainRole:UpdateCameraFollowTarget(immediate)
	-- if self.is_inter_scene and not IsNil(MainCamera) then
	-- 	local camera_follow = MainCamera:GetComponentInParent(typeof(CameraFollow))
	-- 	if nil ~= camera_follow then
	-- 		camera_follow.Target = self:GetRoot().transform
	-- 		camera_follow:SyncImmediate()
	-- 	else
	-- 		print_log("The main camera does not have CameraFollow component.")
	-- 	end
	-- end

	if self.is_inter_scene then
		if not IsNil(MainCameraFollow) then
			Scheduler.Delay(function()
				-- local owner_role = self:GetMountOwnerRole()
				-- if owner_role then
				-- 	MainCameraFollow.Target = owner_role:GetRoot().transform
				-- else
					if self:GetRoot() and self:GetRoot().transform then
						MainCameraFollow.Target = self:GetRoot().transform
					end
				-- end
				if immediate then
					MainCameraFollow:SyncImmediate()
				end
			end)
		else
			print_log("The main camera does not have CameraFollow component.")
		end
	end
end

function MainRole:SetMountOtherObjId(mount_other_objid)
	Scene.Instance:OnShieldRoleChanged()
	Role.SetMountOtherObjId(self, mount_other_objid)
	if not IsNil(MainCameraFollow) then
		--local camera_follow = MainCamera:GetComponentInParent(typeof(CameraFollow))
		--if nil ~= camera_follow then
			local owner_role = self:GetMountOwnerRole()
			if owner_role then
				MainCameraFollow.Target = owner_role:GetRoot().transform
				MainCameraFollow:SyncImmediate()
			else
				self:UpdateCameraFollowTarget(true)
				--camera_follow.Target = self:GetRoot().transform
			end
			-- camera_follow:SyncImmediate()
		--else
			--print_log("The main camera does not have CameraFollow component.")
		--end
	else
		print_log("The main camera does not have CameraFollow component.")
	end
end