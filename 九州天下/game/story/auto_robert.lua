AutoRobert = AutoRobert or BaseClass(Role)
local PROF_SKILL_ID_LIST = {
	[1] = "121##5##131##141",
	[2] = "231##5##221##241",
	[3] = "341#331###5##341",
}

-- 机器人寻路的路径缓存(因为每一次使用A*算法效率比较低，会导致卡顿，所以这里把路径点存起来)
AutoRobert.path_cache = {}
-- 自动跑任务机器人(由于Robert大部分功能服务于配置表，故重新创建个机器人)
function AutoRobert:__init(vo)
	self.obj_type = SceneObjType.Role
	self.draw_obj:SetObjType(self.obj_type)

	self.arrive_func = nil							-- 到达处理
	self.move_oper_cache = nil						-- 移动操作缓存
	self.move_oper_cache2 = nil  					-- 跳跃操作缓存
	self.atk_oper_cache = {}
	self.skill_id_list = {}

	self.last_logic_pos_x = 0
	self.last_logic_pos_y = 0

	self.last_skill_id = 0
	self.last_skill_index = 0
	self.last_atk_end_time = 0

	self.path_pos_list = {}
	self.path_pos_index = 1

	self.is_specialskil = false
	self.is_special_jump = false

	self.jump_call_back = nil
	self.target_point = nil
	self.next_point = nil

	self.target_x = 0
	self.target_y = 0

	self.total_stand_time = 0

	self.now_time = 0
	self.goto_next_pos_time = 0

	self.cur_auto_post = {x = 0, y = 0}
	self.laset_auto_post = {x = 0, y = 0}
end

function AutoRobert:__delete()
	if self.material then
		MaterialPool.Instance:Free(self.material)
		self.material = nil
	end

	-- if self.jump_target_vo then
	-- 	self.jump_target_vo:DeleteMe()
	-- 	self.jump_target_vo = nil
	-- end
	self.jump_target_vo = nil

	-- if self.target_point and self.target_point.vo then
	-- 	self.target_point:DeleteMe()
	-- end
	self.target_point = nil

	-- if self.next_point and self.next_point.vo then
	-- 	self.next_point:DeleteMe()
	-- end
	self.next_point = nil
	-- self:HideJumpTrailRenderer()
end

function AutoRobert:Update(now_time, elapse_time)
	Role.Update(self, now_time, elapse_time)
	if self.last_logic_pos_x ~= self.logic_pos.x or self.last_logic_pos_y ~= self.logic_pos.y then
		self.last_logic_pos_x = self.logic_pos.x
		self.last_logic_pos_y = self.logic_pos.y
		self:CheckJump()
		-- 状态不一样
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

	self.now_time = now_time

	if 0 ~= self.goto_next_pos_time and self.now_time >= self.goto_next_pos_time then
		if self:IsJump() then
			self.goto_next_pos_time = self.now_time + math.random(0, 500) / 100
			return
		end
		self.goto_next_pos_time = 0
		if #self.target_pos_list > 0 then
			-- 主要用于跳跃后的执行
			local target_pos_x, target_pos_y = self.target_pos_list[1].x, self.target_pos_list[1].y
			-- 限制住同一个npc待太久的情况
			if self.laset_auto_post.x == target_pos_x and self.laset_auto_post.y == target_pos_y then
				self:MoveOneTargetComplete()
				return
			end
			self.laset_auto_post.x = target_pos_x
			self.laset_auto_post.y = target_pos_y

			-- 用于跳跃结束的情况
			self.cur_auto_post.x = target_pos_x
			self.cur_auto_post.y = target_pos_y

			self:DoMoveOperate(target_pos_x, target_pos_y, 10)
		end
	end
end

function AutoRobert:DoMoveOperate(x, y, range, arrive_func, is_guaji)
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
			self.move_oper_cache = {x = x, y = y, range = range, arrive_func = arrive_func}
		end
		return false
	end

	local move_x, move_y = x, y

	local key = self.logic_pos.x .. self.logic_pos.y .. x .. y
	local path = AutoRobert.path_cache[key]
	-- 如果已经有了缓存，直接取缓存的路线
	if path then
		self.path_pos_list = path
		move_x = self.path_pos_list[1].x
		move_y = self.path_pos_list[1].y
	else
		x, y = AStarFindWay:GetAroundVaildXY(x, y, 3)
		x, y = AStarFindWay:GetLineEndXY2(self.logic_pos.x, self.logic_pos.y, x, y)

		if not AStarFindWay:IsWayLine(self.logic_pos.x, self.logic_pos.y, x, y) then
			if not AStarFindWay:FindWay(self.logic_pos, u3d.vec2(x, y)) then
				return
			end
			self.path_pos_list = AStarFindWay:GenerateInflexPoint(range)

			if not self.path_pos_list or #self.path_pos_list == 0 then
				return
			end
			move_x = self.path_pos_list[1].x
			move_y = self.path_pos_list[1].y
		else
			self.path_pos_list = {{x = move_x, y = move_y}}
		end
		AutoRobert.path_cache[key] = self.path_pos_list
	end
	self.path_pos_index = 1
	if arrive_func then
		self.arrive_func = arrive_func
	end

	Role.DoMove(self, move_x, move_y)
end

local skill_can_move = false
function AutoRobert:CanDoMove()
	skill_can_move = SkillData.GetSkillCanMove(self.last_skill_id)
	if self:IsRealDead() or self:IsDead() or (self:IsAtk() and not skill_can_move) or self.is_special_move or self:IsJump() or self.vo.move_mode == MOVE_MODE.MOVE_MODE_JUMP2 or
		(self:IsAtkPlaying() and not skill_can_move) or CgManager.Instance:IsCgIng() then
		return false
	end

	-- Buff 效果判断
	if self:IsDingShen() or self:IsXuanYun() or self:IsBianxingFool() then
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
function AutoRobert:IsNeedChangeDirOnDoMove(pos_x, pos_y)
	if #self.path_pos_list > 1 then
		local now_pos = self.draw_obj:GetRootPosition()
		local dis = GameMath.GetDistance(self.logic_pos.x, self.logic_pos.y, pos_x, pos_y, false)
		if dis < 4 then
			return false
		end
	end

	return true
end

function AutoRobert:MoveEnd()
	local pos = self.path_pos_list[self.path_pos_index + 1]
	if nil ~= pos then
		self.path_pos_index = self.path_pos_index + 1
		Role.DoMove(self, pos.x, pos.y)

		return false
	end

	-- 移动结束后接近目的地才开始下一次移动
	local now_pos = self.draw_obj:GetRootPosition()
	local dis = GameMath.GetDistance(self.cur_auto_post.x, self.cur_auto_post.y, self.logic_pos.x, self.logic_pos.y, false)
	if dis <= 150 then
		self:MoveOneTargetComplete()
	end

	return true
end

function AutoRobert:EnterStateMove()
	Role.EnterStateMove(self)
	if self.vo.move_mode == MOVE_MODE.MOVE_MODE_JUMP2 and self.vo.move_mode_param > 0 then
		if self.target_x == nil or self.target_y == nil then
			return
		end

		Role.DoMove(self, self.target_x, self.target_y)
	end
end

function AutoRobert:QuitStateMove()
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
end

function AutoRobert:ClearPathInfo()
	self.path_pos_list = {}
	self.path_pos_index = 0
end

-- 跳跃
function AutoRobert:OnJumpStart()
	if self:IsDeleted() or self.target_point == nil then
		return
	end
	if self.target_x == nil or self.target_y == nil then
		return
	end

	self:RemoveModel(SceneObjPart.Mount)
	self:RemoveModel(SceneObjPart.FightMount)

	local x, y = self:GetLogicPos()
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
	Role.DoMove(self, self.target_x, self.target_y)

	if not self:IsSpecialJump() then

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
end

function AutoRobert:OnJumpEnd()
	Role.OnJumpEnd(self)
	if self.jump_call_back then
		self.jump_call_back()
		self.jump_call_back = nil
	end

	self:DoMoveOperate(self.cur_auto_post.x, self.cur_auto_post.y, 10)
end

function AutoRobert:JumpTo(point_vo, target_point, next_point, call_back)
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
	self.jump_target_vo = point_vo.target_vo

	if point_vo.jump_type == 0 then
		if point_vo.jump_tong_bu == 0 then
			self.is_special_jump = true
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
		self.vo.move_mode_param = point_vo.air_craft_id
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
	local part = self.draw_obj:GetPart(SceneObjPart.Main)
	if next_point then
		part:SetBool("jump_end", false)
	else
		part:SetBool("jump_end", true)
	end
end

-- 跳跃时的路线
function AutoRobert:ToJumpPath()
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

function AutoRobert:OnAttackPlayEnd()
	Role.OnAttackPlayEnd(self)
	table.remove(self.skill_id_list, 1)
	if #self.skill_id_list > 0 then

		self:DoAttack(self.skill_id_list[1], self.atk_oper_cache.x, self.atk_oper_cache.y, self.atk_oper_cache.obj_id, SceneObjType.Monster)
	elseif self.move_oper_cache ~= nil then
		local cache = self.move_oper_cache
		self.move_oper_cache = nil
		self:DoMoveOperate(cache.x, cache.y, cache.range, cache.arrive_func)
	else
		if self.mount_res_id and self.mount_res_id > 0 then
			self:ChangeModel(SceneObjPart.Mount, ResPath.GetMountModel(self.mount_res_id))
		elseif self.fight_mount_res_id and self.fight_mount_res_id > 0 then
			self:ChangeModel(SceneObjPart.FightMount, ResPath.GetFightMountModel(self.fight_mount_res_id))
		end

		self:MoveOneTargetComplete()
	end
end

function AutoRobert:DoAttack(skill_id, target_x, target_y, target_obj_id, target_type)
	self:RemoveModel(SceneObjPart.Mount)
	self:RemoveModel(SceneObjPart.FightMount)
	Role.DoAttack(self, tonumber(skill_id), target_x, target_y, target_obj_id, target_type)
end

function AutoRobert:CanAttack()
	if self:IsRealDead() or self:IsJump() or self.vo.move_mode == MOVE_MODE.MOVE_MODE_JUMP2 or self:IsBianxingFool() or self:IsXuanYun() or self:IsDingShen() or
		CgManager.Instance:IsCgIng()
		or self:IsBianxingFool() then
		return false
	end

	local scene_logic = Scene.Instance:GetSceneLogic()
	if scene_logic then
		return scene_logic:CanMove()
	end

	return true
end

function AutoRobert:EnterStateDead()
	Role.EnterStateDead(self)
	if self.vo.move_mode == MOVE_MODE.MOVE_MODE_JUMP2 then
		self.vo.move_mode = MOVE_MODE.MOVE_MODE_NORMAL
		self:ClearJumpCache()
	end
end

function AutoRobert:StopMove()
	self.arrive_func = nil
	self.move_oper_cache = nil
	self:ClearPathInfo()
	if self:IsMove() then
		self:ChangeToCommonState()
	end
end

function AutoRobert:ContinuePath()
	self.is_special_jump = false
	if self.move_oper_cache2 then
		local cache = self.move_oper_cache2
		self.move_oper_cache2 = nil
		self.jump_call_back = nil
		GlobalTimerQuest:AddDelayTimer(function() self:DoMoveOperate(cache.x, cache.y, cache.range, cache.arrive_func) end, 0.1)
	end
end

function AutoRobert:ClearJumpCache()
	self.jump_call_back = nil
	self.move_oper_cache2 = nil
end

function AutoRobert:IsSpecialJump()
	return self.is_special_jump
end

function AutoRobert:GetMoveSpeed()
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
		return speed
	end
end

function AutoRobert:StartMoveByTargetPosList(target_pos_list)
	self.target_pos_list = target_pos_list
	self.goto_next_pos_time = self.now_time + math.random(100, 200) / 100
end

function AutoRobert:MoveOneTargetComplete()

	-- 会去打怪
	if self.target_pos_list[1].is_monster_task then
		self.target_pos_list[1].is_monster_task = false

		local skill_id_list = PROF_SKILL_ID_LIST[self.vo.prof] or ""
		self.skill_id_list = Split(skill_id_list, "##")
		local target_obj = self:SelectAtkTarget()
		if target_obj then
			local target_pos_x, target_pos_y = target_obj:GetLogicPos()
			self.atk_oper_cache.x = target_pos_x
			self.atk_oper_cache.y = target_pos_y
			self.atk_oper_cache.obj_id = target_obj:GetVo().obj_id

			self:DoAttack(self.skill_id_list[1], target_pos_x, target_pos_y, target_obj:GetVo().obj_id, SceneObjType.Monster)
		else
			table.remove(self.target_pos_list, 1)
			self.goto_next_pos_time = self.now_time + math.random(0, 250) / 100
		end
	else
		table.remove(self.target_pos_list, 1)
		self.goto_next_pos_time = self.now_time + math.random(0, 250) / 100
	end
end

function AutoRobert:CheckJump()
	if self:IsJump() or self.vo.move_mode == MOVE_MODE.MOVE_MODE_JUMP2 then
		return false
	end

	local position = self:GetLuaPosition()

	local jumppoint_obj_list = Scene.Instance:FindJumpPoint(position.x, position.z)
	if #jumppoint_obj_list < 1 then
		return false
	end

	if jumppoint_obj_list[1].vo.id == self.jumping_id then
		return false
	end

	local target_point = Scene.Instance:GetObjByTypeAndKey(SceneObjType.JumpPoint, jumppoint_obj_list[1].vo.target_id)
	if not target_point then
		return false
	end

	self:SceneJumpTo(jumppoint_obj_list[1].vo, target_point)

	return true
end

-- 跳跃到目的地
function AutoRobert:SceneJumpTo(vo, to_point)
	local target_point = Scene.Instance:GetObjByTypeAndKey(SceneObjType.JumpPoint, to_point.vo.target_id)

	self:JumpTo(vo, to_point, target_point, function()
		if to_point.vo.target_id and to_point.vo.target_id ~= 0 then
			if target_point then
				-- 延迟到下一帧执行
				CountDown.Instance:AddCountDown(0.01, 0.01, function()
					self:SceneJumpTo(to_point.vo, target_point)
				end)
				return
			end
		end

		self:SetJump(false)
		self.vo.move_mode = MOVE_MODE.MOVE_MODE_NORMAL
		if self.mount_res_id and self.mount_res_id > 0 then
			self:ChangeModel(SceneObjPart.Mount, ResPath.GetMountModel(self.mount_res_id))
		elseif self.fight_mount_res_id and self.fight_mount_res_id > 0 then
			self:ChangeModel(SceneObjPart.FightMount, ResPath.GetFightMountModel(self.fight_mount_res_id))
		end
	end)
end

-- 选择（寻找）攻击目标
function AutoRobert:SelectAtkTarget()
		local target_obj = nil
		local scene = Scene.Instance

		local target_distance = scene:GetSceneLogic():GetGuajiSelectObjDistance()
		local x, y = self:GetLogicPos()

		target_obj, target_distance = Scene.Instance:SelectObjHelper(
			SceneObjType.Monster, x, y, target_distance, SelectType.Enemy)

	return target_obj
end