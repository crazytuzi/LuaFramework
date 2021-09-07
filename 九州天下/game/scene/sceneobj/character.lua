Character = Character or BaseClass(SceneObj)

function Character:__init()
	self.show_hp = 0								-- 表现hp

	-- 攻击相关
	self.attack_skill_id = 0
	self.next_skill_id = 0
	self.attack_target_pos_x = 0
	self.attack_target_pos_y = 0
	self.attack_target_obj = nil

	self.attack_is_playing = false					-- 攻击动作是否在播放中
	self.attack_is_playing_invalid_time = 0 		-- 一段时间后attack_is_playing恢复为false

	self.fight_state_end_time = 0					-- 战斗状态结束时间
	self.fight_by_role_end_time = 0					-- 由与人物战斗状态结束时间
	self.floating_data = nil						-- 当前正在播放的飘字
	self.floating_texts = {}						-- 飘字队列

	-- Move状态相关变量
	self.move_end_pos = u3d.vec2(0, 0)
	self.move_dir = u3d.vec2(0, 0)					-- 移动方向(单位向量)
	self.move_total_distance = 0.0					-- 移动总距离
	self.move_pass_distance = 0.0					-- 移动距离
	self.is_special_move = false					-- 是否特殊移动
	self.special_speed = 0							-- 特殊移动附加速度
	self.delay_end_move_time = 0					-- 延迟结束移动状态(防止摇杆贴边行走时快速切换移动、站立)

	self.is_jump = false

	self.flying_height = 0 							-- 当前飞行高度
	self.flying_process = 0 						-- 飞行过程（1,上升 2,最高处 3,下降）

	self.rotate_to_angle = nil 						-- 旋转到指定角度
	self.anim_name = ""								-- 当前的动作
	self.attack_index = 1							-- 当前攻击序列
	self.animator_handle_t = {}

	self.select_effect = nil
	self.buff_effect_list = {}
	self.buff_list = {}
	self.other_effect_list = {}

	self.last_bink_time = 0
	self.old_show_hp = nil
	self.last_hit_audio_time = 0

	self.last_attacker_pos_x = 0
	self.last_attacker_pos_y = 0


	-- 是否创建飞行器
	self.has_craft = false
	self.is_sit_mount = 0

	self.state_machine = StateMachine.New(self)
	--Stand
	self.state_machine:SetStateFunc(SceneObjState.Stand, self.EnterStateStand, self.UpdateStateStand, self.QuitStateStand)
	--Move
	self.state_machine:SetStateFunc(SceneObjState.Move, self.EnterStateMove, self.UpdateStateMove, self.QuitStateMove)
	--Attack
	self.state_machine:SetStateFunc(SceneObjState.Atk, self.EnterStateAttack, self.UpdateStateAttack, self.QuitStateAttack)
	--Dead
	self.state_machine:SetStateFunc(SceneObjState.Dead, self.EnterStateDead, self.UpdateStateDead, self.QuitStateDead)
end

function Character:__delete()
	self.state_machine:DeleteMe()

	for _, v in pairs(self.animator_handle_t) do
		v:Dispose()
	end
	self.animator_handle_t = {}

	if nil ~= self.select_effect then
		self.select_effect:DeleteMe()
		self.select_effect = nil
	end

	for k,v in pairs(self.buff_effect_list) do
		v:Destroy()
		v:DeleteMe()
	end
	self.buff_effect_list = {}
	self:RemoveDelayTime()
	GlobalTimerQuest:CancelQuest(self.dead_timer)
	GlobalTimerQuest:CancelQuest(self.say_end_timer)
	self:RemoveJumpDelayTime()
	self.uicamera = nil
	self.attack_target_obj = nil
	self.buff_list = {}
end

function Character:InitInfo()
	SceneObj.InitInfo(self)
	self.show_hp = self.vo.hp

	local main_part = self.draw_obj:GetPart(SceneObjPart.Main)
	local is_main_role = self:IsMainRole()
	main_part:SetMainRole(is_main_role)
	main_part:EnableHalt(is_main_role)
	main_part:EnableCameraShake(is_main_role)
	main_part:ListenEvent(
		"jump/start", BindTool.Bind(self.OnJumpStart, self))
	main_part:ListenEvent(
		"jump/end", BindTool.Bind(self.OnJumpEnd, self))
end

local reset_pos_time = 0
function Character:Update(now_time, elapse_time)
	SceneObj.Update(self, now_time, elapse_time)
	self.state_machine:UpdateState(elapse_time)

	if self.fight_state_end_time > 0 and now_time >= self.fight_state_end_time then
		self:LeaveFightState()
	end
	reset_pos_time = reset_pos_time + UnityEngine.Time.deltaTime
	if self.reset_x and self.reset_y and reset_pos_time > 0.05 then
		reset_pos_time = 0
		if self.logic_pos.x == self.reset_x and self.logic_pos.y == self.reset_y then
			self.reset_x = nil
			self.reset_y = nil
		else
			local reset_x, reset_y = 0, 0
			if self.logic_pos.x ~= self.reset_x then
				reset_x = self.logic_pos.x > self.reset_x and -1 or 1
			end
			if self.logic_pos.y ~= self.reset_y then
				reset_y = self.logic_pos.y > self.reset_y and -1 or 1
			end
			self:SetLogicPos(self.logic_pos.x + reset_x, self.logic_pos.y + reset_y)
		end
	end

	if self.attack_is_playing_invalid_time > 0 and now_time >= self.attack_is_playing_invalid_time then
		self.attack_is_playing_invalid_time = 0
		self.attack_is_playing = false
	end

	if ClientCmdCtrl.Instance.is_show_pos and self:GetFollowUi() then
		local name_str = string.format(self.vo.name .. "(%d,%d)",self.logic_pos.x, self.logic_pos.y)
		self:GetFollowUi():SetName(name_str)
	end

	for k,v in pairs(self.other_effect_list) do
		if v.time < now_time then
			v.eff:Destroy()
			v.eff:DeleteMe()
			self.other_effect_list[k] = nil
		end
	end
end

function Character:OnEnterScene()
	SceneObj.OnEnterScene(self)
	self:ChangeToCommonState(true)
end

function Character:IsCharacter()
	return true
end

function Character:OnAnimatorBegin()
	if self:IsAtk() then
		self:SetIsAtkPlaying(true)
	end
end

function Character:OnAnimatorHit()
	if self:IsDeleted() then
		self.attack_skill_id = 0
		return
	end
	if self:IsAtk() then
		local main_part = self.draw_obj:GetPart(SceneObjPart.Main)
		local obj = main_part:GetObj()
		if nil == obj or IsNil(obj.gameObject) then
			return
		end
		local actor_ctrl = obj.actor_ctrl
		if actor_ctrl ~= nil and
			self.attack_target_obj ~= nil and
			self.attack_target_obj.draw_obj ~= nil then
			local root = self.attack_target_obj.draw_obj:GetRoot().transform
			local hurt_point = self.attack_target_obj.draw_obj:GetAttachPoint(AttachPoint.Hurt)
			local attack_skill_id = self.attack_skill_id
			local attack_target_obj = self.attack_target_obj
			actor_ctrl:PlayProjectile(self.anim_name, root, hurt_point, function()
				if not self:IsDeleted() and attack_target_obj ~= nil then
					self:OnAttackHit(attack_skill_id, attack_target_obj)
				end
			end)
		end
	end

	if self.next_skill_id and self.attack_skill_id then
		if self.next_skill_id ~= 0 and self.attack_skill_id > 0 then
			self.attack_skill_id = 0
			self:DoAttack(
				self.next_skill_id,
				self.next_target_x,
				self.next_target_y,
				self.next_target_obj_id,
				self.next_target_type)
			self.next_skill_id = 0
		else
			self.next_skill_id = 0
			self.attack_skill_id = 0
		end
	end
end

function Character:OnAnimatorEnd()
	if self:IsAtk() then
		self:ChangeToCommonState()
	end
	self:SetIsAtkPlaying(false)
end

function Character:OnAttackHit(attack_skill_id, attack_target_obj)
	FightData.Instance:OnHitTrigger(self, attack_target_obj)
end

function Character:CreateFollowUi()
	local obj_type = 0
	if self.vo.beauty_used_seq then		-- 美人屏蔽followUI
		obj_type = SceneObjType.BeautyObj
		return
	end
	self.follow_ui = CharacterFollow.New(obj_type)
	self.follow_ui:Create()
	if self.draw_obj then
		self.follow_ui:SetFollowTarget(self.draw_obj.root.transform)
	end
	self:SyncShowHp()
end

function Character:GetMoveSpeed()
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

function Character:IsStand()
	return self.state_machine:IsInState(SceneObjState.Stand)
end

function Character:IsMove()
	return self.state_machine:IsInState(SceneObjState.Move)
end

function Character:IsAtk()
	return self.state_machine:IsInState(SceneObjState.Atk)
end

function Character:SetIsAtkPlaying(attack_is_playing)
	local old_attack_is_playing = self.attack_is_playing
	self.attack_is_playing = attack_is_playing

	if attack_is_playing then
		self.attack_is_playing_invalid_time = Status.NowTime + 4
	else
		self.attack_is_playing_invalid_time = 0
	end

	if true == old_attack_is_playing and false == attack_is_playing then
		self:OnAttackPlayEnd()
	end
end

function Character:IsAtkPlaying()
	return self.attack_is_playing
end

function Character:IsDead()
	return self.state_machine:IsInState(SceneObjState.Dead)
end

function Character:IsRealDead()
	return self.vo.hp <= 0
end

function Character:OnClick()
	SceneObj.OnClick(self)
	if self:IsDeleted() then
		return
	end

	if nil == self.select_effect then
		self.select_effect = AsyncLoader.New(self.draw_obj:GetRoot().transform)
		self.select_effect:Load(ResPath.GetSelectObjEffect(1))
	end
	self.select_effect:SetActive(true)
end

function Character:CancelSelect()
	SceneObj.CancelSelect(self)
	if nil ~= self.select_effect then
		self.select_effect:SetActive(false)
	end
end
----------------------------------------------------
-- 状态函数begin
----------------------------------------------------
-- 站立
function Character:DoStand()
	if self:IsDeleted() or self:IsStand() then
		return
	end

	self.state_machine:ChangeState(SceneObjState.Stand)
end

function Character:EnterStateStand()
	local part = self.draw_obj:GetPart(SceneObjPart.Main)
	local mantle_part = self.draw_obj:GetPart(SceneObjPart.Mantle)

	if self.is_gather_state then
		part:SetInteger("status", ActionStatus.Gather)
	else
		if self.vo.hold_beauty_npcid and self.vo.hold_beauty_npcid > 0 then
			part:SetInteger("status", ActionStatus.Hug)
			local holdbeauty_part = self.draw_obj:GetPart(SceneObjPart.HoldBeauty)
			if holdbeauty_part then
				holdbeauty_part:SetInteger("status", ActionStatus.Hug)
			end
		elseif self.vo.special_appearance == SPECIAL_APPEARANCE_TYPE.SPECIAL_APPEARANCE_TYPE_CAPTURE_CAPTIVE then
			part:SetInteger("status", ActionStatus.Carry)
			local bag_part = self.draw_obj:GetPart(SceneObjPart.Bag)
			if bag_part then
				bag_part:SetInteger("status", ActionStatus.Run)
			end
		else
			part:SetInteger("status", ActionStatus.Idle)
			if self:IsRole() and mantle_part then
				mantle_part:SetInteger("status", ActionStatus.Idle)
			end
		end
	end
	-- 温泉场景
	if Scene.Instance:GetSceneType() == SceneType.HotSpring then
		if self:IsWaterWay() then
			part:SetInteger("status", 4)
			local offset = Scene.Instance:GetSceneLogic():GetWaterWayOffset() or 0
			part:SetOffsetY(offset)
		else
			if self.is_gather_state then
				part:SetInteger("status", ActionStatus.Gather)
			else
				part:SetInteger("status", ActionStatus.Idle)
			end
			part:ReSetOffsetY()
		end
		local special_param = self.vo.special_param
		if self:IsMainRole() then
			special_param = HotStringChatData.Instance:GetpartnerObjId()
		end
		if special_param >= 0 and special_param < 65535 then
			part:SetInteger("status", ActionStatus.Die)
			part:ReSetOffsetY()
		end
	end

	-- local fight_mount_part = self.draw_obj:GetPart(SceneObjPart.FightMount)
	-- fight_mount_part:SetInteger("status", ActionStatus.Idle)
	-- local mount_part = self.draw_obj:GetPart(SceneObjPart.Mount)
	-- mount_part:SetInteger("status", ActionStatus.Idle)

	self:ChangeMountState(ActionStatus.Idle)
	if self:IsGoddess() then
		local weapon_part = self.draw_obj:GetPart(SceneObjPart.Weapon)
		if weapon_part then
			weapon_part:SetInteger("status", ActionStatus.Idle)
		end
	end
end

function Character:UpdateStateStand(elapse_time)
	if self.is_special_move then
		self:SpecialMoveUpdate(elapse_time)
	end
end

function Character:QuitStateStand()
end

-- 移动
function Character:DoMove(pos_x, pos_y)
	if self:IsDead() then
		return
	end

	self.delay_end_move_time = 0
	self.is_special_move = false
	self.special_speed = 0
	
	self:CalcMoveInfo(pos_x, pos_y)

	self.draw_obj:MoveTo(self.move_end_pos.x, self.move_end_pos.y, self:GetMoveSpeed())

	--如果当前不在移动状态则切换至移动状态
	if not self:IsMove() then
		self.state_machine:ChangeState(SceneObjState.Move)
	end
end

function Character:IsNeedChangeDirOnDoMove(pos_x, pos_y)
	return true
end

function Character:EnterStateMove()
	local part = self.draw_obj:GetPart(SceneObjPart.Main)
	local mantle_part = self.draw_obj:GetPart(SceneObjPart.Mantle)
	-- 抱美人
	if self.vo.hold_beauty_npcid and self.vo.hold_beauty_npcid > 0 then
		part:SetInteger("status", ActionStatus.HugRun)
		local holdbeauty_part = self.draw_obj:GetPart(SceneObjPart.HoldBeauty)
		if holdbeauty_part then
			holdbeauty_part:SetInteger("status", ActionStatus.HugRun)
		end
	elseif self.is_sit_mount == 1 then
		part:SetInteger("status", ActionStatus.Idle)
		if self:IsRole() and mantle_part then
			mantle_part:SetInteger("status", ActionStatus.Run)
		end
	elseif self.vo.special_appearance == SPECIAL_APPEARANCE_TYPE.SPECIAL_APPEARANCE_TYPE_CAPTURE_CAPTIVE then
		part:SetInteger("status", ActionStatus.CarryRun)
		local bag_part = self.draw_obj:GetPart(SceneObjPart.Bag)
		if bag_part then
			bag_part:SetInteger("status", ActionStatus.Run)
		end
	else
		part:SetInteger("status", ActionStatus.Run)
		if self:IsRole() and mantle_part then
			mantle_part:SetInteger("status", ActionStatus.Run)
		end
	end
	if Scene.Instance:GetSceneType() == SceneType.HotSpring then
		if self:IsWaterWay() then
			part:SetInteger("status", 3)
			local offset = Scene.Instance:GetSceneLogic():GetWaterWayOffset() or 0
			part:SetOffsetY(offset)
		else
			part:SetInteger("status", ActionStatus.Run)
			part:ReSetOffsetY()
		end
	end
	-- local mount_part = self.draw_obj:GetPart(SceneObjPart.Mount)
	-- mount_part:SetInteger("status", ActionStatus.Run)
	-- local fight_mount_part = self.draw_obj:GetPart(SceneObjPart.FightMount)
	-- fight_mount_part:SetInteger("status", ActionStatus.Run)
	self:ChangeMountState(ActionStatus.Run)

	if self:IsGoddess() then
		local weapon_part = self.draw_obj:GetPart(SceneObjPart.Weapon)
		if weapon_part then
			weapon_part:SetInteger("status", ActionStatus.Run)
		end
	end
end

--根据站立姿势判断对坐骑还是战斗坐骑进行动画设置
function Character:ChangeMountState(state)
	local mount_state = state or ActionStatus.Idle
	local mount_data 

	if self:IsRole() then
		if self.vo.multi_mount_res_id and self.vo.multi_mount_res_id >= 0 then
			mount_data = MultiMountData.Instance:GetImageCfgById(self.vo.multi_mount_res_id)
		else
			if self.mount_res_id and self.mount_res_id > 0 then
				if self.mount_res_id > GameEnum.MOUNT_SPECIAL_IMA_ID then
					local spec_id = self.mount_res_id - GameEnum.MOUNT_SPECIAL_IMA_ID
					mount_data = MountData.Instance:GetSpecialImageCfg(spec_id)
				else
					mount_data = MountData.Instance:GetMountImageCfg(self.mount_res_id)
				end
			end
		end
	end

	local is_mount = true
	if mount_data ~= nil and mount_data.sit_1 ~= nil and mount_data.sit_1 == 1 then
		is_mount = false
	end

	if mount_data ~= nil and mount_data.is_sit ~= nil and mount_data.is_sit == 1 then
		is_mount = false
	end

	if not is_mount then
		local fight_mount_part = self.draw_obj:GetPart(SceneObjPart.FightMount)
		fight_mount_part:SetInteger("status", mount_state)
	else
		local mount_part = self.draw_obj:GetPart(SceneObjPart.Mount)
		mount_part:SetInteger("status", mount_state)			
	end
end

function Character:UpdateStateMove(elapse_time)
	if self.delay_end_move_time > 0 then
		if Status.NowTime >= self.delay_end_move_time then
			self.delay_end_move_time = 0
			self:ChangeToCommonState()
		end
		return
	end

	if self.draw_obj then
		local part = self.draw_obj:GetPart(SceneObjPart.Main)
		if self.vo.hold_beauty_npcid and self.vo.hold_beauty_npcid > 0 then
			part:SetInteger("status", ActionStatus.HugRun)
			local holdbeauty_part = self.draw_obj:GetPart(SceneObjPart.HoldBeauty)
			if holdbeauty_part then
				holdbeauty_part:SetInteger("status", ActionStatus.HugRun)
			end
	 	elseif self.is_sit_mount == 1 then
	 		part:SetInteger("status", ActionStatus.Idle)
	 	elseif self.vo.special_appearance == SPECIAL_APPEARANCE_TYPE.SPECIAL_APPEARANCE_TYPE_CAPTURE_CAPTIVE then
			part:SetInteger("status", ActionStatus.CarryRun)
			local bag_part = self.draw_obj:GetPart(SceneObjPart.Bag)
			if bag_part then
				bag_part:SetInteger("status", ActionStatus.Run)
			end
		else
			part:SetInteger("status", ActionStatus.Run)
		end
		if Scene.Instance:GetSceneType() == SceneType.HotSpring then
			if self:IsWaterWay() then
				part:SetInteger("status", 3)
				local offset = Scene.Instance:GetSceneLogic():GetWaterWayOffset() or 0
				part:SetOffsetY(offset)
			else
				part:SetInteger("status", ActionStatus.Run)
				part:ReSetOffsetY()
			end
		end
		
		--移动状态更新
		local distance = elapse_time * self:GetMoveSpeed()
		self.move_pass_distance = self.move_pass_distance + distance

		if self.move_pass_distance >= self.move_total_distance then
			self.is_special_move = false
			self.special_speed = 0
			self:SetRealPos(self.move_end_pos.x, self.move_end_pos.y)

			if self:MoveEnd() then
				self.move_pass_distance = 0
				self.move_total_distance = 0
				if self:IsMainRole() then
					self.delay_end_move_time = Status.NowTime + 0.05
				elseif self:IsSpirit() then
					self.delay_end_move_time = Status.NowTime + 0.02
				else
					self.delay_end_move_time = Status.NowTime + 0.2
				end
			end
		else
			local mov_dir = u3d.v2Mul(self.move_dir, distance)
			self:SetRealPos(self.real_pos.x + mov_dir.x, self.real_pos.y + mov_dir.y)
		end
	end
end

function Character:QuitStateMove()
	self.draw_obj:StopMove()
	if self.has_craft then
		self.timer_quest = GlobalTimerQuest:AddDelayTimer(function() self:RemoveModel(SceneObjPart.FightMount)
		self:RemoveModel(SceneObjPart.Mount) self.has_craft = false end, 0.2)
	end
	self.is_jump = false
end

function Character:RemoveDelayTime()
	if self.timer_quest then
		GlobalTimerQuest:CancelQuest(self.timer_quest)
		self.timer_quest = nil
	end
end

function Character:MoveEnd()
	return true
end

-- 移动剩余距离
function Character:GetMoveRemainDistance()
	if not self:IsMove() then
		return 0
	end

	return self.move_total_distance - self.move_pass_distance
end

-- 攻击
function Character:DoAttack(skill_id, target_x, target_y, target_obj_id, target_type)
	if self.attack_skill_id ~= 0 and skill_id ~= self.attack_skill_id then
		self.next_skill_id = skill_id
		self.next_target_x = target_x
		self.next_target_y = target_y
		self.next_target_obj_id = target_obj_id
		self.next_target_type = target_type
		self:DoAttack(self.attack_skill_id, target_x, target_y, target_obj_id, target_type)
		return
	end

	self.attack_skill_id = skill_id
	self.attack_target_pos_x = target_x
	self.attack_target_pos_y = target_y
	self.attack_target_obj = Scene.Instance:GetObj(target_obj_id)
	if self.attack_target_obj ~= nil and nil ~= self.draw_obj then
		local target = self.attack_target_obj:GetRoot().transform
		if self.attack_skill_id == 80 or  self.attack_skill_id == 81 or self.attack_skill_id == 82 then
			target = self.attack_target_obj.draw_obj:GetAttachPoint(AttachPoint.UI)
		end
		local main_part = self.draw_obj:GetPart(SceneObjPart.Main)
		main_part:SetAttackTarget(target)
	end
	if not SkillData.IsBuffSkill(skill_id) and (self.vo.special_appearance ~= SPECIAL_APPEARANCE_TYPE.SPECIAL_APPERANCE_TYPE_TERRITORYWAR
		or SkillData.Instance:GetRealSkillIndex(skill_id) ~= 5) then

		if self:GetType() == SceneObjType.Monster and self.vo ~= nil and self.vo.monster_id ~= nil and self.vo.monster_id == 50268 then
		else
			self:SetDirectionByXY(target_x, target_y)
		end
	end

	self:EnterFight(target_type)
	self.state_machine:ChangeState(SceneObjState.Atk)

	if self:IsRole() then
		local goddess_obj = self:GetGoddessObj()
		if goddess_obj then
			goddess_obj:DoAttack(skill_id, target_x, target_y, target_obj_id, target_type)
		end
	end

	if self:IsRole() then
		local mingjiang_obj = self:GetMingjaingObj()
		if mingjiang_obj then
			mingjiang_obj:DoAttack(skill_id, target_x, target_y, target_obj_id, target_type)
		end
	end
end


function Character:EndSkillReading(skill_id)

end

function Character:EnterStateAttack(anim_name)
	if self.vo.special_appearance == SPECIAL_APPEARANCE_TYPE.SPECIAL_APPERANCE_TYPE_TERRITORYWAR then
		if SkillData.Instance:GetRealSkillIndex(self.attack_skill_id) > 3 then
			anim_name = "attack2"
		else
			anim_name = "attack1"
		end
	end

	if self.vo.special_appearance == SPECIAL_APPEARANCE_TYPE.SPECIAL_APPEARANCE_TYPE_BIANSHEN then
		local skill_index = SkillData.Instance:GetRealSkillIndex(self.attack_skill_id) + 1
		anim_name = "attack" .. skill_index
	end

	local part = self.draw_obj:GetPart(SceneObjPart.Main)
	local part_obj = part:GetObj()
	if part_obj == nil or IsNil(part_obj.gameObject) then
		return
	end

	local animator = part_obj.animator
	animator:SetTrigger(anim_name)

	if nil == self.animator_handle_t[anim_name.."/begin"] then
		self.animator_handle_t[anim_name.."/begin"] = animator:ListenEvent(anim_name.."/begin", BindTool.Bind(self.OnAnimatorBegin, self))
	end

	if nil == self.animator_handle_t[anim_name.."/hit"] then
		self.animator_handle_t[anim_name.."/hit"] = animator:ListenEvent(anim_name.."/hit", BindTool.Bind(self.OnAnimatorHit, self))
	end

	if nil == self.animator_handle_t[anim_name.."/end"] then
		self.animator_handle_t[anim_name.."/end"] = animator:ListenEvent(anim_name.."/end", BindTool.Bind(self.OnAnimatorEnd, self))
	end

	self.anim_name = anim_name
end

function Character:UpdateStateAttack(elapse_time)
	if self.is_special_move then
		self:SpecialMoveUpdate(elapse_time)
	end
end

function Character:QuitStateAttack(attack_skill_id)
	self.is_special_move = false
	self.special_speed = 0

	attack_skill_id = attack_skill_id or self.attack_skill_id
	local part = self.draw_obj:GetPart(SceneObjPart.Main)
	local part_obj = part:GetObj()
	local skill_cfg = SkillData.GetSkillinfoConfig(attack_skill_id)
	local anim_name = nil
	if nil ~= skill_cfg then
		anim_name = skill_cfg.skill_action
		if skill_cfg.hit_count > 1 then
			anim_name = anim_name.."_"..self.attack_index
		end
	end
	if self.vo.special_appearance == SPECIAL_APPEARANCE_TYPE.SPECIAL_APPERANCE_TYPE_TERRITORYWAR then
		if SkillData.Instance:GetRealSkillIndex(attack_skill_id) > 3 then
			anim_name = "attack2"
		else
			anim_name = "attack1"
		end
	end
	if part_obj then
		local animator = part_obj.animator
		if anim_name then
			animator:ResetTrigger(anim_name)
		end
	end
end

-- 攻击表现完成后做的事(退出攻击动作QuitStateAttack不可靠)
function Character:OnAttackPlayEnd()
	-- body
end

function Character:RemoveJumpDelayTime()
	if self.delay_time then
		GlobalTimerQuest:CancelQuest(self.delay_time)
		self.delay_time = nil
	end
end

-- 跳跃
function Character:DoJump(move_mode_param)
	if move_mode_param == nil or move_mode_param == 0 then
		-- local mount_part = nil
		-- if self.vo.mount_appeid ~= nil and self.vo.mount_appeid > 0 and 1 ~= self.is_sit_mount then
		-- 	mount_part = self.draw_obj:GetPart(SceneObjPart.Mount)
		-- end

		-- if nil ~= mount_part and nil ~= mount_part:GetObj() then
		-- 	mount_part:SetTrigger("jump")
		-- else
		-- 	local main_part = self.draw_obj:GetPart(SceneObjPart.Main)
		-- 	if self.vo.jump_act and self.vo.jump_act == 2 then
		-- 		main_part:SetTrigger("jump2")
		-- 	else
		-- 		main_part:SetTrigger("jump")
		-- 	end
		-- end
		local main_part = self.draw_obj:GetPart(SceneObjPart.Main)
		-- 如果跳跃之前是战斗状态，则强制切换到普通状态（战斗状态跳跃动作很奇怪），延迟0.5秒再进行跳跃
		local obj = main_part:GetObj()
		if obj and not IsNil(obj.gameObject) and obj.animator and obj.animator:GetBool("fight") then
			main_part:SetBool("fight", false)
			self:RemoveJumpDelayTime()
			self.delay_time = GlobalTimerQuest:AddDelayTimer(function() self:DoJump(move_mode_param) end, 0.5)
			return
		end

		if self.vo.jump_act and self.vo.jump_act == 3 then
			main_part:SetTrigger("jump3")
		elseif self.vo.jump_act and self.vo.jump_act == 2 then
			main_part:SetTrigger("jump2")
		else
			main_part:SetTrigger("jump")
		end
	else
		self:DoAirCraftMove(move_mode_param)
	end

	self.is_jump = true
end

-- 从一半开始播放
function Character:DoJump2(move_mode_param)
	if move_mode_param == nil or move_mode_param == 0 then
		local mount_part = nil
		local fight_mount_part = nil
		if self.vo.mount_appeid ~= nil and self.vo.mount_appeid > 0 then
			mount_part = self.draw_obj:GetPart(SceneObjPart.Mount)
		elseif self.vo.fight_mount_appeid ~= nil and self.vo.fight_mount_appeid > 0 then
			fight_mount_part = self.draw_obj:GetPart(SceneObjPart.FightMount)
		end
		if mount_part then
			mount_part:Play("jump", 0, 0.5)
		else
			local main_part = self.draw_obj:GetPart(SceneObjPart.Main)
			main_part:Play("jump", 0, 0.5)
		end
		if fight_mount_part then
			fight_mount_part:Play("jump", 0, 0.5)
		end
	else
		self:DoAirCraftMove(move_mode_param)
	end
	self.is_jump = true
end

-- 飞行器移动
function Character:DoAirCraftMove(craft_id)
	local craft_cfg = MountData.Instance:GetCraftCfgById(craft_id)
	if craft_cfg then
		local asset_bundle = tostring(craft_cfg.asset_bundle)
		local asset_name = tostring(craft_cfg.asset_name)
		if asset_bundle ~= "" and asset_name ~= "" then
			if craft_cfg.type == 1 then
				self:RemoveModel(SceneObjPart.FightMount)
				self:ChangeModel(SceneObjPart.Mount, asset_bundle, asset_name)
			else
				self:RemoveModel(SceneObjPart.Mount)
				self:ChangeModel(SceneObjPart.FightMount, asset_bundle, asset_name)
			end
			self.has_craft = true
			self:RemoveDelayTime()
		end
	end
	self:EnterStateMove()
end

function Character:OnJumpStart()
	self.is_jump = true
end

function Character:OnJumpEnd()
	self.is_jump = false
end

function Character:IsJump()
	return self.is_jump or false
end

function Character:SetJump(state)
	self.is_jump = state or false
end

-- 死亡
function Character:DoDead(is_init)
	if is_init then
		self.is_init_dead = true
	end
	self.state_machine:ChangeState(SceneObjState.Dead)

	self:OnDie()
end

function Character:EnterStateDead()
	self:RemoveModel(SceneObjPart.Mount)

	local main_part = self.draw_obj:GetPart(SceneObjPart.Main)
	main_part:SetInteger("status", ActionStatus.Die)
	if self.is_init_dead then
		self.is_init_dead = nil
		main_part:SetTrigger("dead_imm")
	else
		if self:IsMonster() and self.dietype == 1 then
		 	if math.random() > 0.5 then
		 		local delta_x = self.real_pos.x - self.last_attacker_pos_x
		 		local delta_y = self.real_pos.y - self.last_attacker_pos_y
		 		local delta_l = math.sqrt(delta_x * delta_x + delta_y * delta_y)
		 		delta_x = delta_x / delta_l
		 		delta_y = delta_y / delta_l
		 		local move_len = 5.0
		 		local target_x = self.real_pos.x + move_len * delta_x
		 		local target_y = self.real_pos.y + move_len * delta_y

		 		self.draw_obj:MoveTo(
		 			target_x,
		 			target_y,
		 			2 * self:GetMoveSpeed())
		 	end
		end
	end

	self:SetIsAtkPlaying(false)
	GlobalEventSystem:Fire(ObjectEventType.OBJ_DEAD, self)
	self:HideFollowUi()
end

function Character:UpdateStateDead(elapse_time)
	if self.is_special_move then
		self:SpecialMoveUpdate(elapse_time)
	end
end

function Character:QuitStateDead()
end

-- 特殊移动，冲锋、击退等
function Character:SpecialMoveUpdate(elapse_time)
	local distance = elapse_time * self:GetMoveSpeed()
	self.move_pass_distance = self.move_pass_distance + distance

	if self.move_pass_distance >= self.move_total_distance then
		self.move_pass_distance = 0
		self.move_total_distance = 0

		self.is_special_move = false
		self.special_speed = 0
		self:SetRealPos(self.move_end_pos.x, self.move_end_pos.y)

		if nil ~= self.special_move_end_callback then
			self.special_move_end_callback(self)
		end

		self:OnSpecialMoveEnd()
	else
		local mov_dir = u3d.v2Mul(self.move_dir, distance)
		local now_pos = u3d.v2Add(self.real_pos, mov_dir)
		self:SetRealPos(now_pos.x, now_pos.y)
	end
end

function Character:OnSpecialMoveEnd()
	-- body
end

function Character:SetStatusChongFeng()
	if self.draw_obj == nil then return end
	local part = self.draw_obj:GetPart(SceneObjPart.Main)
	if part then
		part:SetInteger("status", ActionStatus.ChongFeng)
	end
end

function Character:SetStatusIdle()
	if self.draw_obj == nil then return end
	local part = self.draw_obj:GetPart(SceneObjPart.Main)
	if part then
		part:SetInteger("status", ActionStatus.Idle)
	end
end

function Character:ChangeToCommonState(is_init)
	if (self.show_hp and self.show_hp > 0) or (self.vo and self.vo.hp > 0) then
		if not self:IsStand() then
			self:DoStand()
		end
	else
		if not self:IsDead() then
			if self:IsMainRole() then
				if self.dead_timer == nil then
					self.dead_timer = GlobalTimerQuest:AddDelayTimer(function ()
						if self.show_hp <= 0 and not self:IsDead() then
							self:DoDead()
						end
						self.dead_timer = nil
					end, 0.1)
				end
			else
				self:DoDead()
			end
		end
	end
end
----------------------------------------------------
-- 状态函数end
----------------------------------------------------

----------------------------------------------------
-- 战斗 begin
----------------------------------------------------
function Character:GetAttackSkillId()
	return self.attack_skill_id
end

-- 进入战斗
function Character:EnterFight(target_type)
	local system_event = false
	if 0 == self.fight_state_end_time then
		self:EnterFightState()
		system_event = true
	end
	self.fight_state_end_time = Status.NowTime + COMMON_CONSTS.FIGHT_STATE_TIME

	if system_event and self:IsMainRole() then
		GlobalEventSystem:Fire(ObjectEventType.ENTER_FIGHT)
	end

	if target_type == SceneObjType.Role then
		self.fight_by_role_end_time = Status.NowTime + COMMON_CONSTS.FIGHT_STATE_TIME
	end
end

-- 进入战斗状态
function Character:EnterFightState()
	if self.draw_obj == nil then
		return
	end
	self:ShowFollowUi()
	self:SyncShowHp()

	if self.draw_obj then
		local part = self.draw_obj:GetPart(SceneObjPart.Main)
		part:SetBool("fight", true)
	end
	

	-- if self:IsMainRole() then
	-- 	GlobalEventSystem:Fire(ObjectEventType.ENTER_FIGHT)
	-- end
end

-- 离开战斗状态
function Character:LeaveFightState()
	self.fight_state_end_time = 0
	self.fight_by_role_end_time = 0

	if self:CanHideFollowUi() then
		self:HideFollowUi()
	end

	if self.draw_obj then
		local part = self.draw_obj:GetPart(SceneObjPart.Main)
		part:SetBool("fight", false)
	end
	
	if self:IsMainRole() then
		GlobalEventSystem:Fire(ObjectEventType.EXIT_FIGHT)
	end
end

-- 是否在战斗状态
function Character:IsFightState()
	return self.fight_state_end_time > Status.NowTime
end

-- 是否在由人物引起的战斗
function Character:IsFightStateByRole()
	return self.fight_by_role_end_time > Status.NowTime
end

function Character:CanHideFollowUi()
	return not self:IsFightState() and not self.is_select
end

function Character:ShowFollowUi()
	local follow_ui = self:GetFollowUi()
	if follow_ui and not SettingData.Instance:IsShieldOtherRole(Scene.Instance:GetSceneId()) then
		follow_ui:Show()
	end
end

function Character:HideFollowUi()
	local follow_ui = self:GetFollowUi()
	if follow_ui then
		follow_ui:Hide()
	end
end

function Character:Say(content, say_time)
	if nil == self.follow_ui then
		return
	end

	self.follow_ui:HideBubble()
	GlobalTimerQuest:CancelQuest(self.say_end_timer)

	self.follow_ui:ChangeBubble(content)
	self.follow_ui:ShowBubble()
	self.say_end_timer = GlobalTimerQuest:AddDelayTimer(function ()
		self.say_end_timer = nil
		self.follow_ui:HideBubble()
	end, say_time)
end

-- 同步表现血量
function Character:SyncShowHp()
	--回血绿字
	if self.show_hp < self.vo.hp and self.show_hp ~= 0 then
		if self:IsMainRole() then
			local floating_point = self.draw_obj:GetAttachPoint(AttachPoint.UI)
			FightText.Instance:ShowRecover(self.vo.hp - self.show_hp, floating_point)
		end
	end

	self.show_hp = self.vo.hp

	if self.show_hp > 0 then
		if self:IsMainRole() then
			if self:IsDead() then
				self:DoStand()
			end
			if self.old_show_hp and self.old_show_hp <= 0 then
				GlobalTimerQuest:CancelQuest(self.dead_timer)
				self.dead_timer = nil
				self:OnRealive()
			end
		else
			-- self:DoStand()
			self:OnRealive()
		end
	elseif self.dead_timer == nil and self.show_hp <= 0 and not self:IsDead() then
		if self:IsMainRole() then
			self.dead_timer = GlobalTimerQuest:AddDelayTimer(function ()
				if self.show_hp <= 0 and not self:IsDead() then
					self:DoDead()
				end
				self.dead_timer = nil
			end, 0.1)
		else
			self:DoDead()
		end
	end

	if self.vo.max_hp and 0 ~= self.vo.max_hp then
		self:GetFollowUi():SetHpPercent(self.show_hp / self.vo.max_hp)
	end

	if self == GuajiCache.target_obj then
		GlobalEventSystem:Fire(ObjectEventType.TARGET_HP_CHANGE, self)
	end
	self.old_show_hp = self.show_hp
end

function Character:OnRealive()
end

function Character:OnDie()
	-- body
end

-- 被打(有数据)
function Character:DoBeHit(deliverer, skill_id, real_blood, blood, fighttype, text_type)
	--if self:IsMainRole() then
		-- 被打音效
		-- if blood < 0 and self.last_hit_audio_time + 3 <= Status.NowTime then
		-- 	self.last_hit_audio_time = Status.NowTime
		-- 	local audio_config = AudioData.Instance:GetAudioConfig()
		-- 	if audio_config then
		-- 		local cfg = audio_config.other[1]
		-- 		if cfg then
		-- 			local audio_name = cfg["Role" .. self.vo.prof .. "_" .. self.vo.sex .. "_Hit"]
		-- 			if audio_name then
		-- 				AudioManager.PlayAndForget(AssetID("audios/sfxs/other", audio_name))
		-- 			end
		-- 		end
		-- 	end
		-- end
	--end
	if nil ~= deliverer then
		self.last_attacker_pos_x, self.last_attacker_pos_y = deliverer:GetRealPos()
	else
		self.last_attacker_pos_x = 0
		self.last_attacker_pos_y = 0
	end

	-- 获取技能配置
	local skill_action = nil
	local skill_hit_interval = 0
	if nil ~= deliverer then
		if deliverer:IsRole() then
			local skill_cfg = SkillData.GetSkillinfoConfig(skill_id)
			if nil ~= skill_cfg then
				skill_action = skill_cfg.skill_action
				if skill_cfg.hit_count > 1 then
					skill_action = skill_action.."_"..self.attack_index
				end
			end
		end
	end

	-- 同步血量
	self:SyncShowHp()

	if skill_action == nil and deliverer then
		local real_blood_p = math.floor(real_blood)
		local blood_p = math.floor(blood)
		self:DoBeHitAction(deliverer, real_blood_p, blood_p, fighttype, text_type)
		return
	end

	--[[if skill_hit_count > 1 then
		local real_blood_per_hit = math.floor(real_blood / skill_hit_count)
		local blood_per_hit = math.floor(blood / skill_hit_count)
		GlobalTimerQuest:AddTimesTimer(function()
			self:DoBeHitAction(deliverer, real_blood_per_hit, blood_per_hit, fighttype)
		end, skill_hit_interval, skill_hit_count)
	else
		self:DoBeHitAction(deliverer, real_blood, blood, fighttype)
	end]]

	if deliverer and deliverer.draw_obj then
		local deliverer_main = deliverer.draw_obj:GetPart(SceneObjPart.Main)
		local deliverer_obj = deliverer_main:GetObj()
		if deliverer_obj == nil then
			if nil ~= deliverer then
				local real_blood_p = math.floor(real_blood * 1)
				local blood_p = math.floor(blood * 1)
				self:DoBeHitAction(deliverer, real_blood_p, blood_p, fighttype, text_type)
				self:OnBeHit(real_blood, deliverer, skill_id)
			end
			return
		end
		local attacker_obj = deliverer_obj.actor_ctrl
		attacker_obj:PlayHurt(skill_action, function(p)
			local real_blood_p = math.floor(real_blood * p)
			local blood_p = math.floor(blood * p)
			self:DoBeHitAction(deliverer, real_blood_p, blood_p, fighttype, text_type)
		end)
	end

	if nil ~= deliverer then
		self:OnBeHit(real_blood, deliverer, skill_id)
		if self.vo.hp <= 0 and self:IsMonster() and deliverer.IsMainRole() then
			TipsCtrl.Instance:UpdateDoubleHitNum()
		end
	end
end

-- 受击
function Character:OnBeHit(real_blood, deliverer, skill_id)
	-- override
end

function Character:DoBeHitAction(deliverer, real_blood, blood, fighttype, text_type)
	if self:IsDeleted() then
		return
	end

	-- 飘字
	local is_main_role = false
	local is_left = false
	local is_top = false
	if nil ~= deliverer  then
		is_main_role = deliverer:IsMainRole()
		local root = deliverer:GetRoot()
		if root ~= nil and not IsNil(root.gameObject) and not IsNil(MainCamera) then
			local attacker = root.transform
			local screen_pos_1 = UnityEngine.RectTransformUtility.WorldToScreenPoint(MainCamera, self:GetRoot().transform.position)
			local screen_pos_2 = UnityEngine.RectTransformUtility.WorldToScreenPoint(MainCamera, attacker.position)
			is_left = screen_pos_1.x > screen_pos_2.x
			is_top = screen_pos_1.y < screen_pos_2.y
		end
	end

	local floating_data = {
		is_main_role = is_main_role,
		blood = blood,
		fighttype = fighttype,
		pos = {is_left = is_left, is_top = is_top},
		text_type = text_type,
	}
	if self.floating_data ~= nil then
		if #self.floating_texts < 10 then
			table.insert(self.floating_texts, floating_data)
		end
	else
		self:PlayFloatingText(floating_data)
	end
end

function Character:PlayFloatingText(data)
	if self:IsDeleted() then
		return
	end
	self.floating_data = data
	if data.is_main_role then
		local floating_point = self.draw_obj:GetAttachPoint(AttachPoint.UI)
		local bottom_point = self.draw_obj:GetAttachPoint(AttachPoint.BuffBottom)

		if FIGHT_TYPE.NORMAL == data.fighttype then
			FightText.Instance:ShowHurt(data.blood, data.pos, bottom_point, data.text_type)

		elseif FIGHT_TYPE.BAOJI == data.fighttype then
			FightText.Instance:ShowCritical(data.blood, data.pos, bottom_point, data.text_type)

		elseif FIGHT_TYPE.SHANBI == data.fighttype then
			FightText.Instance:ShowDodge(data.pos, floating_point, true)

		elseif FIGHT_TYPE.GREATE_SOLDIER == data.fighttype then
			FightText.Instance:ShowGeneralHurt(data.blood, data.pos, bottom_point, data.text_type)

		elseif FIGHT_TYPE.CARD_PROF_ATK == data.fighttype then
			FightText.Instance:ShowCardHurt(data.blood, data.pos, bottom_point, data.text_type)

		else
			FightText.Instance:ShowBeHurt(data.blood, data.pos, bottom_point, data.text_type)
		end
	elseif self:IsMainRole() then
		local floating_point = self.draw_obj:GetAttachPoint(AttachPoint.UI)
		local bottom_point = self.draw_obj:GetAttachPoint(AttachPoint.BuffBottom)
		if FIGHT_TYPE.NORMAL == data.fighttype then
			FightText.Instance:ShowBeHurt(
				data.blood, data.pos, bottom_point)
		elseif FIGHT_TYPE.BAOJI == data.fighttype then
			FightText.Instance:ShowBeCritical(
				data.blood, data.pos, bottom_point)
		elseif FIGHT_TYPE.SHANBI == data.fighttype then
			FightText.Instance:ShowDodge(
				data.pos, floating_point, false)
		else
			FightText.Instance:ShowBeHurt(
				data.blood, data.pos, bottom_point)
		end
	end

	GlobalTimerQuest:AddDelayTimer(function()
		if #self.floating_texts > 0 then
			local text = self.floating_texts[1]
			table.remove(self.floating_texts, 1)
			self:PlayFloatingText(text)
		else
			self.floating_data = nil
		end
	end, 0.1)
end

-- 被打(客户端纯表现)
function Character:DoBeHitShow(deliverer, skill_id, target_obj_id)
	if nil == deliverer then return end
	if not self:IsRealDead() then
		self:EnterFight(deliverer:GetType())
	end

	-- 获取技能配置
	local skill_action = ""
	if deliverer:IsRole() then
		local skill_cfg = SkillData.GetSkillinfoConfig(skill_id)
		if nil ~= skill_cfg then
			skill_action = skill_cfg.skill_action
			if skill_cfg.hit_count > 1 then
				skill_action = skill_action.."_"..deliverer.attack_index
			end
		end
	elseif deliverer:IsMonster() then
		local skill_cfg = SkillData.GetMonsterSkillConfig(skill_id)
		if nil ~= skill_cfg then
			skill_action = skill_cfg.skill_action
		end
	end

	-- 主目标和其他目标之间的受击增加以下随机间隔
	if self.vo.obj_id == target_obj_id then
		self:DoBeHitShowImpl(skill_action, deliverer, skill_id)
	else
		local delay_time = 0.5 * math.random()
		GlobalTimerQuest:AddDelayTimer(function()
			self:DoBeHitShowImpl(skill_action, deliverer, skill_id)
		end, delay_time)
	end
end

function Character:DoBeHitShowImpl(skill_action, deliverer, skill_id)
	if self:IsDeleted() or nil == deliverer or deliverer:IsDeleted() or skill_action == "" then
		return
	end

	local deliverer_main = deliverer.draw_obj:GetPart(SceneObjPart.Main)
	local deliverer_obj = deliverer_main:GetObj()
	if deliverer_obj == nil then
		return
	end

	local attacker_obj = deliverer_obj.actor_ctrl
	local root = self.draw_obj:GetRoot()
	local hurt_point = self.draw_obj:GetAttachPoint(AttachPoint.Hurt)
	if nil ~= attacker_obj and nil ~= hurt_point then
		attacker_obj:PlayHurtShow(skill_action, root.transform, hurt_point, function()
			self:DoBeHitShowAction(deliverer, skill_action)
		end)
	end

	local self_main = self.draw_obj:GetPart(SceneObjPart.Main)
	local self_main_obj = self_main:GetObj()
	if self_main_obj ~= nil and self_main_obj.actor_ctrl ~= nil then
		self_main_obj.actor_ctrl:PlayBeHurt()
	end
end

function Character:DoBeHitShowAction(deliverer, skill_action)
	if self:IsDeleted() then
		return
	end

	-- 获取角色对象
	local part = self.draw_obj:GetPart(SceneObjPart.Main)
	if nil ~= part then
		-- 播放受击音效
		-- AudioManager.PlayAndForget("audios/sfxs/foley", "SFX Impact Iron", part.transform)
		-- 播放受击叫声
		AudioManager.PlayAndForget("audios/sfxs/voice/sfxvoicemonstergolemhit", "SFX Voice Monster Golem Hit", part.transform)

		-- 闪光
		if self.last_bink_time + 0.5 <= Status.NowTime then
			part:Blink()
			self.last_bink_time = Status.NowTime
		end
	end
end

-- buff_type_list是倒过来解析的
function Character:SetBuffList(buff_type_list)
	for k, v in pairs(buff_type_list) do
		if v == 0 then
			self:RemoveBuff(64 - k)
		else
			self:AddBuff(64 - k)
		end
	end
end

function Character:AddBuff(buff_type)
	if nil == self.buff_effect_list[buff_type] then
		local buff_param = ConfigManager.Instance:GetAutoConfig("buff_desc_auto").buff_param or {}
		if buff_param[buff_type] then
			if buff_param[buff_type].zoom_scale > 1 then
				self:CheckModleScale(buff_param[buff_type].zoom_scale, buff_param[buff_type].zoom_scale, buff_param[buff_type].zoom_scale)
			end
		end
		if BUFF_CONFIG[buff_type] then
			local draw_obj = self.draw_obj
			-- 女神buff则显示在女神身上
			if BUFF_CONFIG[buff_type].buff_character == BUFF_CHARACTER.GODDESS then
				if self:IsRole() then
					local goddess_obj = self:GetGoddessObj()
					if goddess_obj then
						draw_obj = goddess_obj:GetDrawObj()
					end
				end
			end
			local attach_obj = draw_obj:GetAttachPoint(BUFF_CONFIG[buff_type].attach_index)
			if buff_type == BUFF_TYPE.HPSTORE then
				attach_obj = draw_obj:GetTransfrom()
			end

			local is_hold_beauty = false
			if self.vo.hold_beauty_npcid and self.vo.hold_beauty_npcid > 0 then
				is_hold_beauty = true
			end

			if attach_obj and TaskData.Instance:GetTaskAcceptedIsBeauty() and not IS_HUN_BEAUTY and not IS_CARRY_BAG then -- 抱美人和抗麻袋的时候屏蔽了眩晕特效
				self.buff_effect_list[buff_type] = AsyncLoader.New(attach_obj)
				self.buff_effect_list[buff_type]:Load(ResPath.GetBuffEffect(BUFF_CONFIG[buff_type].effect_file, BUFF_CONFIG[buff_type].effect_id))
			else
				self.buff_list[buff_type] = true
			end
		else
			self.buff_effect_list[buff_type] = AsyncLoader.New()
		end
	else
		-- 重新加载buff
		if BUFF_CONFIG[buff_type] then
			self:RemoveBuff(buff_type)
			self:AddBuff(buff_type)
		end
	end

	if self:IsXuanYun() or self:IsDingShen() then
		self:ChangeToCommonState()
	end
end

function Character:RemoveBuff(buff_type)
	self.buff_list[buff_type] = nil
	if self:IsXuanYun() or self:IsDingShen() or self:IsBianxingFool() then
		if self:IsAtk() then
			self:DoStand()
		end
	end

	local buff_param = ConfigManager.Instance:GetAutoConfig("buff_desc_auto").buff_param or {}
	if buff_param[buff_type] then
		if buff_param[buff_type].zoom_scale > 1 then
			self:CheckModleScale(1, 1, 1)
		end
	end

	if nil ~= self.buff_effect_list[buff_type] then
		self.buff_effect_list[buff_type]:Destroy()
		self.buff_effect_list[buff_type]:DeleteMe()
		self.buff_effect_list[buff_type] = nil
	end
end

function Character:RotateTo(rotate_to_angle)
	self.rotate_to_angle = rotate_to_angle
	self:GetDrawObj():Rotate(0, rotate_to_angle, 0)
end

-- 根据目的地计算移动信息
function Character:CalcMoveInfo(pos_x, pos_y)
	if self:IsNeedChangeDirOnDoMove(pos_x, pos_y) then
		self:SetDirectionByXY(pos_x, pos_y)
	end

	self.move_end_pos.x, self.move_end_pos.y = GameMapHelper.LogicToWorld(pos_x, pos_y)
	local delta_pos = u3d.v2Sub(self.move_end_pos, self.real_pos)
	self.move_total_distance = u3d.v2Length(delta_pos)
	self.move_dir = u3d.v2Normalize(delta_pos)
	self.move_pass_distance = 0.0
end

-- 击退、冲锋、拉人等技能产生的效果
function Character:OnSkillResetPos(skill_id, reset_pos_type, pos_x, pos_y)
	if not self:IsAtk() and not self:IsDead() then
		self.is_special_move = true
		self:DoStand()
	end

	self:CalcMoveInfo(pos_x, pos_y)

	self.is_special_move = true
	-- self.special_speed = COMMON_CONSTS.CHONGFENG_SPEED
	self.special_speed = 1000

	----------------------------------------------------------------
	if self.logic_pos.x == pos_x and self.logic_pos.y == pos_y then
		return
	end
	self.reset_x = pos_x
	self.reset_y = pos_y
end

function Character:SetIsSpecialMove(is_special_move)
	self.is_special_move = is_special_move
end

function Character:GetIsSpecialMove()
	return self.is_special_move
end

function Character:SetSpeicalMoveSpeed(speed)
	self.special_speed = speed
end

function Character:SetSpeicalMoveCallBack(call_back)
	self.special_move_end_callback = call_back
end

-- 是否眩晕
function Character:IsXuanYun()
	return nil ~= self.buff_effect_list[BUFF_TYPE.XUANYUN];
end

-- 是否定身
function Character:IsDingShen()
	return nil ~= self.buff_effect_list[BUFF_TYPE.DINGSHEN];
end

-- 是否沉默
function Character:IsChenMo()
	return nil ~= self.buff_effect_list[BUFF_TYPE.CHENMO];
end

-- 是否变形不可攻击
function Character:IsBianxingFool()
	return nil ~= self.buff_effect_list[BUFF_TYPE.BIANXING_FOOL];
end

-- 是否迟缓
function Character:IsChiHuan()
	return nil ~= self.buff_effect_list[BUFF_TYPE.CHIHUAN];
end

-- 是否有护盾
function Character:IsHudun()
	return nil ~= self.buff_effect_list[BUFF_TYPE.HPSTORE];
end

function Character:GetFlyingProcess()
	return self.flying_process
end

function Character:GetIsFlying()
	return self.flying_process ~= FLYING_PROCESS_TYPE.NONE_FLYING
end

function Character:StartFlyingUp()
	if self.flying_process == FLYING_PROCESS_TYPE.FLYING_UP then return end
	-- self.model:SetZorderOffest(20000)
	self.flying_process = FLYING_PROCESS_TYPE.FLYING_UP
	-- self:ShadowChange(false)
	-- if self.jindouyun == nil then self:CreateJinDouYun(self.jindouyun_resid) end

end

function Character:AddEffect(res, attach_index)
	if self.other_effect_list[res] then return end
	attach_index = attach_index or 0
	local attach_obj = self.draw_obj:GetPart(SceneObjPart.Main):GetAttachPoint(attach_index)
	if attach_obj then
		self.other_effect_list[res] = {eff = AsyncLoader.New(attach_obj), time = Status.NowTime + 2}
		self.other_effect_list[res].eff:Load(ResPath.GetBuffEffect("buff_prefab", res))
	end
end

function Character:CheckModleScale(scale)
	self:GetDrawObj():SetScale(scale, scale, scale)		
end

----------------------------------------------------
-- 战斗 end
----------------------------------------------------

function Character:OnModelLoaded(part, obj)
	SceneObj.OnModelLoaded(self, part, obj)
	if part == SceneObjPart.Main then
		for k,v in pairs(self.buff_list) do
			if nil == self.buff_effect_list[k] then
				local attach_obj = self.draw_obj:GetPart(SceneObjPart.Main):GetAttachPoint(BUFF_CONFIG[k].attach_index)
				if attach_obj then
					self.buff_effect_list[k] = AsyncLoader.New(attach_obj)

					if BUFF_CONFIG[buff_type] ~= nil and BUFF_CONFIG[k] ~= nil then
						local effect_file = BUFF_CONFIG[buff_type].effect_file
						local effect_id = BUFF_CONFIG[k].effect_id
						if effect_file ~= nil and effect_id ~= nil then
							self.buff_effect_list[k]:Load(ResPath.GetBuffEffect(BUFF_CONFIG[buff_type].effect_file, BUFF_CONFIG[k].effect_id))
						end
					end
				end
			end
		end
		self.buff_list = {}
	end
end