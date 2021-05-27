
Character = Character or BaseClass(SceneObj)

function Character:__init()
	self.fight_state_end_time = 0					-- 战斗状态结束时间

	self.is_select = false

	-- Move状态相关变量
	self.state_move_end_pos = cc.p(0, 0)			-- 结束位置
	self.state_move_dir = cc.p(0, 0)				-- 移动方向(单位向量)
	self.state_move_total_distance = 0.0			-- 移动总距离
	self.state_move_pass_distance = 0.0				-- 移动距离
	self.move_speed = 4								-- 移动速度(格/秒)
	self.is_special_move = false					-- 是否特殊移动
	self.special_move_speed = 0						-- 特殊移动附加速度
	self.move_speed_mul = 1							-- 速度倍数，跑步时为2

	self.hpmp_board = nil							-- 血条、魔条

	-- 动画播放相关
	self.action_name = ""							-- 动作
	self.delay_per_unit = 0.1						-- 每帧时长
	self.loops = COMMON_CONSTS.MAX_LOOPS			-- 循环次数
	self.is_pause_last_frame = false				-- 结束后是否停在最后一帧

	self.show_talk_time = 0
	self.talk_list = {}
	self.effect_list = {}
	self.float_attr_txt_list = {}

	self.action_list = {}							-- 动作列表{state_name, life_time, param}
	self.action_begin_time = Status.NowTime
	self.action_end_time = Status.NowTime
	self.action_param = nil

	self.state_machine = StateMachine.New(self)
	-- Stand
	self.state_machine:SetStateFunc(SceneObjState.Stand, self.EnterStateStand, self.UpdateStateStand, self.QuitStateStand)
	-- Move
	self.state_machine:SetStateFunc(SceneObjState.Move, self.EnterStateMove, self.UpdateStateMove, self.QuitStateMove)
	-- Attack
	self.state_machine:SetStateFunc(SceneObjState.Atk, self.EnterStateAttack, self.UpdateStateAttack, self.QuitStateAttack)
	-- Dead
	self.state_machine:SetStateFunc(SceneObjState.Dead, self.EnterStateDead, self.UpdateStateDead, self.QuitStateDead)
end

function Character:__delete()
	if self.state_machine then
		self.state_machine:DeleteMe()
		self.state_machine = nil
	end

	if self.hpmp_board ~= nil then
		self.hpmp_board:DeleteMe()
		self.hpmp_board = nil
	end

	self.effect_list = {}

	for k, v in pairs(self.float_attr_txt_list) do
		v:DeleteMe()
	end
	self.float_attr_txt_list = {}
end

function Character:Update(now_time, elapse_time)
	SceneObj.Update(self, now_time, elapse_time)
	self:UpdateTalk(now_time, elapse_time)
	self:UpdateActionLogic(now_time, elapse_time)

	if not self.is_init_effect then
		self.is_init_effect = true
		if nil ~= self.vo.effect_list then
			for i, v in pairs(self.vo.effect_list) do
				self:AddEffect(v.effect_id, v.effect_type, v.remain_time)
			end
		end
	end

	-- 离开战斗状态
	-- if self.fight_state_end_time > 0 and now_time >= self.fight_state_end_time then
	-- 	self:LeaveFightState()
	-- end
end

function Character:InitAnimation()
	self:CreateShadow()
	self:SetModelColor(self.vo[OBJ_ATTR.CREATURE_COLOR])

	if self:IsRealDead() then
		self:AddAction(SceneObjState.Dead, 0, true)
	end
end

function Character:IsCharacter()
	return true
end

function Character:SetHeight(height)
	if nil == self.name_board and nil ~= self.name and "" ~= self.name then
		local name_board = NameBoard.New()
		name_board:SetName(self.name)
		self:SetNameBoard(name_board)
	end

	SceneObj.SetHeight(self, height)

	if self.hpmp_board then
		self.hpmp_board:SetHeight(self:GetFixedHeight() + 5)
	end
end

-------------------<<血条 begin>>--------------------
function Character:UpdateHpBoardVisible()
	-- if (self.is_select or 0 ~= self.fight_state_end_time or self:IsMainRole()) then
	self:SetHpBoardVisible(true)
	-- else
	-- 	self:SetHpBoardVisible(false)
	-- end
end

function Character:SetHpBoardVisible(is_visible)
	if nil == self.hpmp_board and is_visible then
		self.hpmp_board = HpMpBoard.New()
		self:UpdateHpBoardPercent()
		self:UpdateInnerBoardPercent()
		self.model:AttachNode(self.hpmp_board:GetRootNode(), cc.p(0, self.height + 5), GRQ_SCENE_OBJ_HP, InnerLayerType.HpBoard)
	end
	if nil ~= self.hpmp_board then
		self.hpmp_board:SetVisible(is_visible)
	end
end

function Character:UpdateHpBoardPercent()
	if nil ~= self.hpmp_board then
		if self:GetMaxHp() <= 0 then
			self.hpmp_board:SetHpPercent(100)
		else
			self.hpmp_board:SetHpPercent(self:GetHp() / self:GetMaxHp())
		end
	end
end

function Character:UpdateInnerBoardPercent()
	if nil ~= self.hpmp_board then
		if self:GetMaxInner() <= 0 then
			self.hpmp_board:SetInnerPercent(100)
		else
			self.hpmp_board:SetInnerPercent(self:GetInner() / self:GetMaxInner())
		end
	end
end
-------------------<<血条 end>>----------------------

function Character:SetDirNumberByXY(x, y)
	if x ~= self.logic_pos.x or y ~= self.logic_pos.y then
		self:SetDirNumber(GameMath.GetDirectionNumber(x - self.logic_pos.x, y - self.logic_pos.y))
	end
end

-- 各方向的长度
local DIR_DISTANCE = {
	[GameMath.DirUp] = Config.SCENE_TILE_HEIGHT,						-- 上
	[GameMath.DirUpRight] = Config.SCENE_TILE_DIAGONAL,					-- 右上
	[GameMath.DirRight] = Config.SCENE_TILE_WIDTH,						-- 右
	[GameMath.DirDownRight] = Config.SCENE_TILE_DIAGONAL,				-- 右下
	[GameMath.DirDown] = Config.SCENE_TILE_HEIGHT,						-- 下
	[GameMath.DirDownLeft] = Config.SCENE_TILE_DIAGONAL,				-- 左下
	[GameMath.DirLeft] = Config.SCENE_TILE_WIDTH,						-- 左
	[GameMath.DirUpLeft] = Config.SCENE_TILE_DIAGONAL,					-- 左上
}
function Character:GetMoveSpeed()
	return self.move_speed_mul * (self.move_speed + self.special_move_speed) * (DIR_DISTANCE[self.vo.dir] or 1)
end

-- 服务器速度是移动一格需要的毫秒数，这边转成 格/秒
function Character:SetMoveSpeed(server_move_speed)
	server_move_speed = server_move_speed or 0
	if server_move_speed > 0 then
		self.move_speed = 1 / (server_move_speed / 1000)
	else
		self.move_speed = 0
	end
end

function Character:SetSpecialMoveSpeed(server_move_speed)
	server_move_speed = server_move_speed or 0
	if server_move_speed > 0 then
		self.special_move_speed = (1 / (server_move_speed / 1000))
	else
		self.special_move_speed = 0
	end
end

-- action_name 动画名
-- delay_per_unit 每帧时长 可为空，默认0.15
-- is_pause_last_frame 结束后是否停在最后一帧 可为空
function Character:PlayAnimation(action_name, delay_per_unit, loops, is_pause_last_frame)
	self.action_name = action_name
	self.delay_per_unit = delay_per_unit or 0.15
	self.loops = loops or COMMON_CONSTS.MAX_LOOPS
	self.is_pause_last_frame = is_pause_last_frame or false

	self:RefreshAnimation()
end

function Character:IsNeedCheckShadow()
	return not self:GetIsFlying()
end

function Character:CanClick()
	return not self:IsDead()
end

-- 被打
function Character:OnBeHit(atker_obj_id)
	self:EnterFight()
end

----------------<<操作函数Begin>>------------------
function Character:AddAction(state_name, life_time, param)
	table.insert(self.action_list, {state_name, life_time, param})
end

function Character:GetActionCount()
	return #self.action_list
end

function Character:ClearAction(is_stop_now)
	self.action_list = {}
	if is_stop_now then
		self:StopAction()
	end
end

function Character:StopAction()
	self.action_end_time = Status.NowTime
end

local temp_action = nil
function Character:UpdateActionLogic(now_time, elapse_time)

	if now_time >= self.action_end_time then
		if self:IsRealDead() then
			if not self:IsDead() then
				self.action_end_time = Status.NowTime
				self.action_param = nil
				self:ChangeState(SceneObjState.Dead)
				self.action_list = {}
			end
			return
		end

		temp_action = table.remove(self.action_list, 1)

		if nil ~= temp_action then
			if #self.action_list >= 3 then -- 不知道有什么用！
				temp_action = self.action_list[#self.action_list]
				for i = #self.action_list, 1, -1 do
					if self.action_list[i][1] == SceneObjState.Move then
						temp_action = self.action_list[i]
						break
					end
				end
				self.action_list = {}
			end
			self.action_end_time = Status.NowTime + temp_action[2]
			self.action_param = temp_action[3]
			self:ChangeState(temp_action[1])
		else
			if not self:IsStand() then
				self.action_end_time = Status.NowTime
				self.action_param = nil
				self:ChangeState(SceneObjState.Stand)
			end
		end
	end
	
	self.state_machine:UpdateState(elapse_time)
end

function Character:UpdateMoveLogic(elapse_time)
	if self.state_move_total_distance > 0 then
		-- 移动状态更新
		local distance = elapse_time * self:GetMoveSpeed()
		self.state_move_pass_distance = self.state_move_pass_distance + distance
		if self.state_move_pass_distance >= self.state_move_total_distance then -- 移动到目标位置了
			self.state_move_pass_distance = 0
			self.state_move_total_distance = 0
			self.is_special_move = false
			self:SetSpecialMoveSpeed(0)

			local real_x, real_y = HandleRenderUnit:LogicToWorldXY(self.state_move_end_pos.x, self.state_move_end_pos.y)
			self:SetRealPos(real_x, real_y)

			if self:IsMove() and self:MoveEnd() then -- 移动动作结束前，可在MoveEnd判断移动是否真的要停下来，如果不想停下，请继续 DoMove
				if self:GetActionCount() == 0 then
					if self:IsMainRole() then
						self.action_end_time = Status.NowTime + 0.02
					else
						self.action_end_time = Status.NowTime + 0.1
					end
				else
					self.action_end_time = Status.NowTime
				end
			end
		else
			local mov_dir = cc.pMul(self.state_move_dir, distance)
			self:SetRealPos(self.real_pos.x + mov_dir.x, self.real_pos.y + mov_dir.y)
		end
	end
end

function Character:ChangeState(state_name, ...)
	if self.state_machine:GetStateName() ~= SceneObjState.Move or state_name ~= SceneObjState.Move then
		self.action_begin_time = Status.NowTime
	end
	self.state_machine:ChangeState(state_name, ...)
end

-- 移动
function Character:DoMove(logic_x, logic_y)
	if self:IsDead() then
		return
	end

	if self:IsMove() and self:GetActionCount() == 0 then
		self:PlayMoveAnimation(logic_x, logic_y, false)
	else
		self:AddAction(SceneObjState.Move, 3, {
				logic_x = logic_x,
				logic_y = logic_y
			})
	end
end

function Character:PlayMoveAnimation(logic_x, logic_y, is_force)
	local old_move_speed_mul = self.move_speed_mul

	local self_x, self_y = HandleRenderUnit:WorldToLogicEx(self.real_pos.x, self.real_pos.y)
	self.move_speed_mul = math.max(math.abs(logic_x - self_x + 0.5), math.abs(logic_y - self_y + 0.5))
	if self.move_speed_mul <= 0 then
		self.move_speed_mul = 0.1
	end
	if self.move_speed_mul > 2 then
		self.move_speed_mul = 2
	end

	--计算移动基本信息
	local last_dir_number = self.vo.dir
	self:CalcMoveInfo(logic_x, logic_y)

	local life = self.state_move_total_distance / self:GetMoveSpeed()
	self.action_end_time = Status.NowTime + life + 0.02

	if is_force or old_move_speed_mul ~= self.move_speed_mul or last_dir_number ~= self.vo.dir then
		if self.move_speed_mul > 1.5 and
		-- if 
		 self:IsRole() or (self:GetType() == SceneObjType.Monster and self:IsHumanoid()) then
			self:PlayAnimation(SceneObjState.Run, FrameTime.Run)
		else
			self:PlayAnimation(SceneObjState.Move, FrameTime.Move)
		end		
	end
end

function Character:DoAttack(skill_id, skill_level, sound_id)
	self:EnterFight()
	local atk_time = Config.ATTACK_MOSTER_PALY_TIME
	if self.vo.entity_type == EntityType.Saparation then
		atk_time = Config.ATTACK_FENSHEN_MOSTER_PALY_TIME
	end 
	--获取除主角外 怪物的攻击时间
	local skill_cfg = SkillData.GetSkillLvCfg(skill_id, skill_level)
	if nil ~= skill_cfg and nil ~= skill_cfg.afterAtkWaitTime then
		atk_time = skill_cfg.afterAtkWaitTime / 1000
	end

	self:AddAction(SceneObjState.Atk, atk_time, {
		skill_id = skill_id,
		skill_level = skill_level,
		sound_id = sound_id,
	})

	return true, atk_time
end

function Character:GetMoveEndPos()
	return self.state_move_end_pos
end

-- 进入战斗
function Character:EnterFight()
	if 0 == self.fight_state_end_time then
		self.fight_state_end_time = Status.NowTime + COMMON_CONSTS.FIGHT_STATE_TIME
		self:EnterFightState()
	else
		self.fight_state_end_time = Status.NowTime + COMMON_CONSTS.FIGHT_STATE_TIME
	end
end

-- 进入战斗状态
function Character:EnterFightState()
	self:UpdateHpBoardVisible()
end

-- 离开战斗状态
function Character:LeaveFightState()
	self.fight_state_end_time = 0
	self:UpdateHpBoardVisible()
end

-- 是否在战斗状态
function Character:IsFightState()
	return self.fight_state_end_time > Status.NowTime
end

--获得战斗状态开始时间
function Character:GetFightStateStartTime()
	return self.fight_state_start_time
end

-- 是否在与role引起的战斗
function Character:IsFightStateByRole()
	return false
end

-- 是否在攻击主角状态
function Character:IsAtkMainRole()
	return false
end

function Character:DoStand()
	self:StopAction()
end

function Character:DoDead()
	self:StopAction()
end
----------------<<操作函数End>>------------------

function Character:IsStand()
	return self.state_machine:IsInState(SceneObjState.Stand)
end

function Character:IsMove()
	return self.state_machine:IsInState(SceneObjState.Move)
end

function Character:IsAtk()
	return self.state_machine:IsInState(SceneObjState.Atk)
end

function Character:IsDead()
	return self.state_machine:IsInState(SceneObjState.Dead)
end

function Character:IsRealDead()
	return(self.vo[OBJ_ATTR.CREATURE_HP] and self.vo[OBJ_ATTR.CREATURE_HP] or 1) <= 0
end

----------------<<状态函数Begin>>------------------
-- 站立
function Character:EnterStateStand()
	self:PlayAnimation(SceneObjState.Stand, FrameTime.Stand)
end

function Character:UpdateStateStand(elapse_time)
	if self.is_special_move then
		self:UpdateMoveLogic(elapse_time)
	end
end

function Character:QuitStateStand()
end

-- 移动
function Character:EnterStateMove()
	self:PlayMoveAnimation(self.action_param.logic_x, self.action_param.logic_y, true)
end

function Character:UpdateStateMove(elapse_time)
	self:UpdateMoveLogic(elapse_time)
end

function Character:QuitStateMove()
end

-- 根据目的地计算移动信息
function Character:CalcMoveInfo(end_x, end_y)
	self.state_move_end_pos.x, self.state_move_end_pos.y = end_x, end_y

	local delta_pos = cc.pSub(self.state_move_end_pos, self.logic_pos)
	delta_pos.x = delta_pos.x * Config.SCENE_TILE_WIDTH
	delta_pos.y = delta_pos.y * Config.SCENE_TILE_HEIGHT

	self.state_move_total_distance = cc.pGetLength(delta_pos)
	self.state_move_pass_distance = 0
	self.state_move_dir = cc.pNormalize(delta_pos)
	if delta_pos.x ~= 0 or delta_pos.y ~= 0 then
		self:SetDirNumber(GameMath.GetDirectionNumber(delta_pos.x, delta_pos.y))
	end
end

function Character:MoveEnd()
	return true
end

-- 攻击
function Character:EnterStateAttack()
	local action_id = 0
	local action_name = SceneObjState.Atk
	local sound_id = self.action_param.sound_id or 0
	local effect_id = 0
	local effect_delay = 0

	if self.action_param.skill_id > 0 and self.action_param.skill_level > 0 then
		local skill_cfg = SkillData.GetSkillLvCfg(self.action_param.skill_id, self.action_param.skill_level)
		if nil ~= skill_cfg and nil ~= skill_cfg.actions and nil ~= skill_cfg.actions[1] then
			action_id = skill_cfg.actions[1].act or 0
			sound_id = skill_cfg.actions[1].sound or 0
			effect_id = skill_cfg.actions[1].effect or 0
			effect_delay = skill_cfg.actions[1].delay or 0
		end
	end

	action_name, sound_id = self:GetAtkAction(action_id, sound_id)

	if sound_id > 0 and self:IsMainRole() then
		AudioManager.Instance:PlayEffect(ResPath.GetAudioEffectResPath(sound_id), AudioInterval.Attack)
	end

	self:PlayAnimation(action_name, FrameTime.Atk, 1, false)

	-- 技能特效
	if effect_id > 0 then
		if nil == self.skill_animate_sprite then
			self.skill_animate_sprite = AnimateSprite:create()
			self.model:AttachNode(self.skill_animate_sprite, nil, GRQ_SCENE_OBJ, InnerLayerType.AttackEffect)
		end

		if effect_id >= ResPath.DirEffectBegin then
			local dir_num, is_flip_x = self:GetResDirNumAndFlipFlag()
			if 10020 == effect_id then	-- 8个方向技能不翻转
				dir_num = self.vo.dir
				is_flip_x = false
			end
			local anim_path, anim_name = ResPath.GetEffectAnimPath(effect_id + dir_num)
			self.skill_animate_sprite:setAnimate(anim_path, anim_name, 1, FrameTime.Skill, is_flip_x)
		else
			local anim_path, anim_name = ResPath.GetEffectAnimPath(effect_id)
			self.skill_animate_sprite:setAnimate(anim_path, anim_name, 1, FrameTime.Skill, false)
		end
		if effect_delay > 0 then
			self.skill_animate_sprite:setElapsed(-effect_delay / 1000)
		end
	end
end

function Character:GetAtkAction(skill_id, sound_id)
	return SceneObjState.Atk, sound_id or 0
end

function Character:UpdateStateAttack(elapse_time)
	if self.is_special_move then
		self:UpdateMoveLogic(elapse_time)
	end
end

function Character:QuitStateAttack()
end

function Character:OnMainAnimateStart()
	SceneObj.OnMainAnimateStart(self)
	self.animate_state_name = self.state_machine:GetStateName()
end

function Character:OnMainAnimateStop()
	if self.loops == 1 and self.animate_state_name == self.state_machine:GetStateName() and self.animate_state_name ~= SceneObjState.Atk then
		self:StopAction()
	end
end

-- 死亡
function Character:EnterStateDead()
	if self.action_param then
		self.action_begin_time = Status.NowTime - 1
	else
		self.action_begin_time = Status.NowTime
	end

	self:PlayAnimation(SceneObjState.Dead, 0.001, 1, true)
	GlobalEventSystem:Fire(ObjectEventType.OBJ_DEAD, self)
end

function Character:UpdateStateDead(elapse_time)
	if self.is_special_move then
		self:UpdateMoveLogic(elapse_time)
	end
end

function Character:QuitStateDead()
	self:ReAlive()
end

function Character:DoSpecialMove(pos_x, pos_y, speed)
	self.is_special_move = true
	self:SetSpecialMoveSpeed(speed)
	self:SetServerPos(pos_x, pos_y)
	self:CalcMoveInfo(pos_x, pos_y)

	-- 丢弃所有移动动作
	local t = {}
	for k, v in pairs(self.action_list) do
		if v[1] ~= SceneObjState.Move then
			t[#t + 1] = v
		end
	end
	self.action_list = t

	if self.logic_pos.x == pos_x and self.logic_pos.y == pos_y then
		self.is_special_move = false
	end
end

function Character:SetServerPos(pos_x, pos_y)
end

----------------<<状态函数End>>------------------

function Character:ReAlive()
	-- override
end

function Character:GetResDirNumAndFlipFlag()
	if self.action_name == SceneObjState.Dead then
		return GameMath.DirUp, false
	end
	return GameMath.GetResDirNumAndFlipFlag(self.vo.dir)
end

-- 是否在安全区
function Character:IsInSafeArea()
	local zone_info = HandleGameMapHandler:GetGameMap():getZoneInfo(self.logic_pos.x, self.logic_pos.y)
	if zone_info == ZONE_TYPE_SAFE or zone_type == ZONE_TYPE_SAFE + ZoneType.ShadowDelta then
		return true
	end
	return false
end

function Character:OnClick()
	SceneObj.OnClick(self)
	self.is_select = true
	self:UpdateHpBoardVisible()
end

function Character:CancelSelect()
	SceneObj.CancelSelect(self)
	self.is_select = false
	self:UpdateHpBoardVisible()
end

function Character:SetAttr(index, value)
	if index == OBJ_ATTR.CREATURE_HP then
		self:SetHp(value)
		return

	elseif index == OBJ_ATTR.CREATURE_MAX_HP then
		self:SetMaxHp(value)
		return

	elseif index == OBJ_ATTR.ACTOR_INNER then
		self:SetInner(value)
		return

	elseif index == OBJ_ATTR.ACTOR_MAX_INNER then
		self:SetMaxInner(value)
		return

	elseif index == OBJ_ATTR.CREATURE_COLOR then
		self:SetModelColor(value)

	elseif index == OBJ_ATTR.CREATURE_MOVE_SPEED then
		self:SetMoveSpeed(value)

	end

	SceneObj.SetAttr(self, index, value)
end

function Character:GetHp()
	return self.vo[OBJ_ATTR.CREATURE_HP] or 0
end

function Character:SetHp(hp)
	if self.vo[OBJ_ATTR.CREATURE_HP] < hp then
		local chg_hp = hp - self.vo[OBJ_ATTR.CREATURE_HP]
		FightTextMgr:OnChangeHp(self.real_pos.x, self.real_pos.y + self.height, -chg_hp, -999, self:IsMainRole())
	end

	self.vo[OBJ_ATTR.CREATURE_HP] = hp

	self:UpdateHpBoardPercent()
end

-- 检测是否处于阴影下
function Character:CheckShadow()
	if self:IsNeedCheckShadow() and HandleGameMapHandler:GetGameMap() then
		local zone_info = HandleGameMapHandler:GetGameMap():getZoneInfo(self.logic_pos.x, self.logic_pos.y) or 0
		if zone_info >= ZoneType.ShadowBegin or self:HasBuffByGroup(BUFF_GROUP.HIDE) then
			self:ShadowChange(true)
		else
			self:ShadowChange(false)
		end
	end
end

function Character:GetMaxHp()
	return self.vo[OBJ_ATTR.CREATURE_MAX_HP] or 0
end

function Character:SetMaxHp(max_hp)
	self.vo[OBJ_ATTR.CREATURE_MAX_HP] = max_hp
	self:UpdateHpBoardPercent()
end

function Character:GetInner()
	return self.vo[OBJ_ATTR.ACTOR_INNER] or 0
end

function Character:SetInner(inner)
	self.vo[OBJ_ATTR.ACTOR_INNER] = inner
	self:UpdateInnerBoardPercent()
end

function Character:GetMaxInner()
	return self.vo[OBJ_ATTR.ACTOR_MAX_INNER] or 0
end

function Character:SetMaxInner(max_inner)
	self.vo[OBJ_ATTR.ACTOR_MAX_INNER] = max_inner
	self:UpdateInnerBoardPercent()
end

function Character:GetMp()
	return self.vo[OBJ_ATTR.CREATURE_MP] or 0
end

function Character:GetMaxMp()
	return self.vo[OBJ_ATTR.CREATURE_MAX_MP] or 0
end

function Character:GetIsFlying()
	return false
end

function Character:AddBuff(protocol)
	self.vo.buff_list = self.vo.buff_list or {}

	for i, v in ipairs(self.vo.buff_list) do
		if v.buff_type == protocol.buff_type and v.buff_group == protocol.buff_group then
			v.buff_id = protocol.buff_id
			v.buff_time = protocol.buff_time
			v.buff_name = protocol.buff_name
			v.buff_value = protocol.buff_value
			v.buff_cycle = protocol.buff_cycle
			v.buff_icon = protocol.buff_icon
			v.buff_attr_list = protocol.buff_attr_list
			return
		end
	end

	table.insert(self.vo.buff_list, {
			buff_id = protocol.buff_id,
			buff_type = protocol.buff_type,
			buff_group = protocol.buff_group,
			buff_time = protocol.buff_time,
			buff_name = protocol.buff_name,
			buff_value = protocol.buff_value,
			buff_cycle = protocol.buff_cycle,
			buff_icon = protocol.buff_icon,
			buff_attr_list = protocol.buff_attr_list
		})
	self:CheckShadow()
end

function Character:DelBuff(buff_type, buff_group)
	if nil == self.vo.buff_list then
		return
	end

	for k, v in pairs(self.vo.buff_list) do
		if v.buff_type == buff_type and v.buff_group == buff_group then
			table.remove(self.vo.buff_list, k)
			break
		end
	end
	self:CheckShadow()
end

function Character:DelBuffByType(buff_type)
	if nil == self.vo.buff_list then
		return
	end

	for i = #self.vo.buff_list, -1, 1 do
		if v.buff_type == buff_type then
			table.remove(self.vo.buff_list, i)
		end
	end
	self:CheckShadow()
end

function Character:UpdateBuff(protocol)
	if nil == self.vo.buff_list then
		return
	end

	for i, v in pairs(self.vo.buff_list) do
		if v.buff_type == protocol.buff_type and v.buff_group == protocol.buff_group then
			v.buff_time = protocol.buff_time
			return
		end
	end
end

function Character:HasBuffByGroup(buff_group)
	if nil == self.vo.buff_list then
		return false
	end

	for k, v in pairs(self.vo.buff_list) do
		if v.buff_group == buff_group then
			return true
		end
	end

	return false
end

function Character:AddEffect(effect_id, effect_type, remain_time)
	if 0 == effect_id then
		ErrorLog("AddEffect error")
		return
	end

	self:RemoveEffect(effect_id, effect_type)
	local real_effect_id, is_flip_x = effect_id, false
	if effect_id >= ResPath.DirEffectBegin then
		local dir_num = 0
		dir_num, is_flip_x = self:GetResDirNumAndFlipFlag()
		real_effect_id = effect_id + dir_num
	end

	local anim_path, anim_name = ResPath.GetEffectAnimPath(real_effect_id)
	local loops, callback_func, layer_id = COMMON_CONSTS.MAX_LOOPS, nil, InnerLayerType.BuffEffectUp

	if effect_type == EffectType.FootContinue then
		layer_id = InnerLayerType.BuffEffectDown
		if remain_time == 0 then loops = 1 end
	elseif effect_type == EffectType.Continue then
		if remain_time == 0 then loops = 1 end
	else
		loops = 1
	end

	if 1 == loops then
		callback_func = function() self:RemoveEffect(effect_id, effect_type) end
	end

	local effect_key = effect_id * 1000000 + effect_type
	self.effect_list[effect_key] = RenderUnit.CreateAnimSprite(anim_path, anim_name, FrameTime.Effect, loops, is_flip_x, callback_func)
	self.model:AttachNode(self.effect_list[effect_key], nil, GRQ_SCENE_OBJ, layer_id)

	self:UpdateHutiBuffLayerId()
end

function Character:GetEffectNodeByIdAndType(effect_id, effect_type)
	return self.effect_list[effect_id * 1000000 + effect_type]
end

function Character:UpdateHutiBuffLayerId()
	local effect_node = self:GetEffectNodeByIdAndType(8, 6)	--护体buff 持续播放特效
	if nil == effect_node then return end
	local layer_id = InnerLayerType.BuffEffectUp
	if self.vo.dir == GameMath.DirUp then
		layer_id = InnerLayerType.HuTiBuff
	end
	effect_node:setLocalZOrder(layer_id)
end

function Character:RemoveEffect(effect_id, effect_type)
	local effect_key = effect_id * 1000000 + effect_type
	if nil ~= self.effect_list[effect_key] then
		self.effect_list[effect_key]:removeFromParent()
		self.effect_list[effect_key] = nil
	end
end

-- 说话
function Character:CreateTalkData(data)
	self.talk_list[#self.talk_list + 1] = data
end

function Character:UpdateTalk(now_time, elapse_time)
	local node = self:GetModel():GetLayerNode(GRQ_SCENE_OBJ_FIGHT_TEXT, InnerLayerType.Talk)
	if node and node:isVisible() then
		if now_time - self.show_talk_time > 3 then
			node:setVisible(false)
		else
			return
		end
	end

	local talk_data = table.remove(self.talk_list, 1)
	if talk_data then
		if nil == node then
			local talk_node = cc.Node:create()
			node = talk_node
			self:GetModel():AttachNode(talk_node, cc.p(0, self:GetFixedHeight() + 50), GRQ_SCENE_OBJ_FIGHT_TEXT, InnerLayerType.Talk, true)
			local text_node = XUI.CreateRichText(-27, 45, 1, 1, true)
			talk_node:addChild(text_node, 10, 10)
			local bg_node = XUI.CreateImageViewScale9(-37, 0, 1, 1, ResPath.GetCommon("bg_171"), true, cc.rect(50, 30, 15, 30))
			talk_node:addChild(bg_node, 1, 1)
			bg_node:setAnchorPoint(0, 0)
		else
			node:setVisible(true)
		end
		
		local text_node = node:getChildByTag(10)
		RichTextUtil.ParseRichText(text_node, talk_data.content)
		text_node:refreshView()
		local text_width = text_node:getInnerContainerSize().width or 0
		node:getChildByTag(1):setContentWH(text_width + 20, 60)

		self.show_talk_time = Status.NowTime
	end
end

--浮动触发属性文字
function Character:FloatingAttrTxt(attr_type)
	local txt_info = FightText.TXT_INFO[attr_type]
	if nil == txt_info or nil == txt_info.word then
		return
	end

	local attr_txt_obj
	if #self.float_attr_txt_list >= 5 then
		attr_txt_obj = table.remove(self.float_attr_txt_list, 1)
	else
		attr_txt_obj = FloatingFightText.New(self.model)
	end

	attr_txt_obj:SetInfo(txt_info.word)
	attr_txt_obj:RunDisappear()
	table.insert(self.float_attr_txt_list, attr_txt_obj)

	for i, v in ipairs(self.float_attr_txt_list) do
		v:Float()
	end
end

----------------------------------------------------------------------------------------
FloatingFightText = FloatingFightText or BaseClass()
function FloatingFightText:__init(model)
	self.rich_text = XUI.CreateRichText(0, 0, 300, 22, true)
	self.rich_text:setHorizontalAlignment(RichHAlignment.HA_CENTER)
	self.rich_text:setVerticalAlignment(RichVAlignment.VA_CENTER)
	self.rich_text:setAnchorPoint(0.5, 0.5)
	model:AttachNode(self.rich_text, nil, GRQ_SCENE_OBJ_FIGHT_TEXT2, 1, false)

	-- self.bg = XUI.CreateImageView(0, 0, ResPath.GetFightResPath("fight_txt_bg"))
	-- model:AttachNode(self.bg, nil, GRQ_SCENE_OBJ_FIGHT_TEXT, 1, false)

	self.img_type = XUI.CreateImageView(0, 0, "")
	model:AttachNode(self.img_type, nil, GRQ_SCENE_OBJ_FIGHT_TEXT, 1, false)

	self.pos = cc.p(-96, 110)
	self.size = cc.size(116, 40)
end

function FloatingFightText:__delete()
end

function FloatingFightText:SetInfo(text)
	self.rich_text:stopAllActions()
	self.rich_text:setVisible(true)
	self.rich_text:setOpacity(255)
	self.rich_text:setPosition(self.pos.x, self.pos.y)
	RichTextUtil.ParseRichText(self.rich_text, "", 20, nil, nil, nil, 250, 0, nil, nil)

	-- self.bg:stopAllActions()
	-- self.bg:setVisible(true)
	-- self.bg:setOpacity(255)
	-- self.bg:setPosition(self.pos.x, self.pos.y)

	self.img_type:stopAllActions()
	self.img_type:setVisible(true)
	self.img_type:setOpacity(255)
	self.img_type:setPosition(self.pos.x, self.pos.y)
	self.img_type:loadTexture(ResPath.GetFightResPath(text))
end

function FloatingFightText:RunDisappear()
	local delay_time = cc.DelayTime:create(2.5)
	local fade_out = cc.FadeOut:create(0.5)
	local call_back = cc.CallFunc:create(function()
		self.rich_text:setVisible(false)
	end)
	local action = cc.Sequence:create(delay_time, fade_out, call_back)
	self.rich_text:runAction(action)

	local delay_time = cc.DelayTime:create(2.5)
	local fade_out = cc.FadeOut:create(0.5)
	local call_back = cc.CallFunc:create(function()
		self.img_type:setVisible(false)
	end)
	local action = cc.Sequence:create(delay_time, fade_out, call_back)
	self.img_type:runAction(action)
end

function FloatingFightText:Float()
	self.rich_text:runAction(cc.MoveBy:create(0.5, cc.p(0, self.size.height + 0)))
	self.img_type:runAction(cc.MoveBy:create(0.5, cc.p(0, self.size.height + 0)))
end
----------------------------------------------------------------------------------------
