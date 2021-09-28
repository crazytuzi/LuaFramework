Robert = Robert or BaseClass()

function Robert:__init(character, robert_cfg)
	self.character = character
	self.robert_cfg = robert_cfg
	self.ai = self:CreateAi(robert_cfg.ai_type)

	self.next_can_attack_time = 0
	self.old_is_dead = false
	self.relive_time = 0
	self.delete_time = 0

	self.last_skill_id = 0
	self.attack_index = 0
	self.skill_id_list = Split(robert_cfg.skill_id_list, "##")
	self.aoe_range = robert_cfg.aoe_range
	self.min_gongji = robert_cfg.min_gongji
	self.max_gongji = robert_cfg.gongji
	self.skill_reading_timer = nil

	-- 主角被改属性后，在主角机器人结束后需恢复
	-- 这里有存在bug的可能性，因为如果期间服务器属性变了，恢复后将是错的
	-- 考虑到时间短，不处理这块先
	self.old_value_t = {}

	self:Rotate(robert_cfg.angle)
	self:PlayAction(robert_cfg.action)
	self:Say(robert_cfg.born_say, 3)
end

function Robert:__delete()
	if nil ~= self.skill_reading_timer then
		GlobalTimerQuest:CancelQuest(self.skill_reading_timer)
		self.skill_reading_timer = nil
	end

	self.ai:DeleteMe()

	if self:IsMainRole() then
		self:ResumeOldAttr()
		self.character:SetIsOnlyClintMove(false)
	else
		Scene.Instance:DeleteObj(self:GetObjId())
	end

	self.character = nil
end

function Robert:Update(now_time, elapse_time)
	if self.delete_time > 0 and now_time >= self.delete_time and not self:IsMainRole() then
		self.delete_time = 0
		RobertManager.Instance:DelRobert(self:GetObjId())
		return
	end

	if self.relive_time > 0 and now_time >= self.relive_time and not self:IsMainRole() then
		self.relive_time = 0
		self:Relive()
	end

	if not self.old_is_dead and self:IsDead() then
		self.old_is_dead = true
		self:OnDie()
	end

	if RobertManager.Instance:IsFighting() and not self:IsMainRole() then
		self.ai:Update(now_time, elapse_time)
	end
end

function Robert:CreateAi(ai_type)
	if "active_attack" == ai_type then
		return ActiveAttackRobertAi.New(self)
	else
		return BaseRobertAi.New(self)
	end
end

function Robert:GetObjId()
	return self.character:GetObjId()
end

function Robert:IsMainRole()
	return self.character:IsMainRole()
end

function Robert:IsMonster()
	return self.character:IsMonster()
end

function Robert:IsSkillReading()
	if self:IsMonster() then
		return self.character:IsSkillReading()
	end

	return false
end

function Robert:GetAi()
	return self.ai
end

function Robert:GetSide()
	return self.robert_cfg.side
end

function Robert:GetObj()
	return self.character
end

function Robert:GetGongji()
	return self.robert_cfg.gongji
end

function Robert:GetRobertId()
	return self.robert_cfg.id
end

function Robert:GetAtkRange()
	return self.robert_cfg.atk_range
end

function Robert:GetAoeRange()
	return self.aoe_range
end

function Robert:GetMinGongji()
	return self.min_gongji
end

function Robert:GetMaxGongji()
	return self.max_gongji
end

function Robert:SetLogicPos(pos_x, pos_y)
	self.character:SetLogicPos(pos_x, pos_y)
end

function Robert:GetLogicPos()
	return self.character:GetLogicPos()
end

function Robert:IsMove()
	return self.character:IsMove()
end

function Robert:IsStand()
	return self.character:IsStand()
end

function Robert:IsAtkPlaying()
	return self.character:IsAtkPlaying()
end

function Robert:IsDead()
	return self.character:IsDead()
end

function Robert:SetAtkTarget(target_robert)
	if nil == target_robert then
		return
	end

	if self:IsMainRole() then
		GuajiCache.target_obj = target_robert:GetObj()
		GuajiCache.target_obj_id = target_robert:GetObjId()
		GuajiCtrl.Instance:SetGuajiType(GuajiType.Auto)
	else
		self.ai:SetAtkTarget(target_robert)
	end
end

function Robert:DoAttackObj(target_robert)
	if Status.NowTime >= self.next_can_attack_time then
		self.next_can_attack_time = Status.NowTime + self.robert_cfg.skill_cd
		-- 停止采集
		if self:IsMainRole() and self.character:GetIsGatherState() then
			Scene.SendStopGatherReq()
		end

		-- 考虑连招
		if (self.attack_index > 0 and self.attack_index < 3) and
			(111 == self.last_skill_id or 211 == self.last_skill_id or 311 == self.last_skill_id or 411 == self.last_skill_id) then

			self.attack_index = self.attack_index + 1
			RobertManager.Instance:ReqFight(self, target_robert, self.last_skill_id, self.attack_index)
		else
			self.last_skill_id = tonumber(self.skill_id_list[GameMath.Rand(1, #self.skill_id_list)]) or 0
			self.attack_index = 0

			if 111 == self.last_skill_id or 211 == self.last_skill_id or 311 == self.last_skill_id or 411 == self.last_skill_id then
				self.attack_index = 1
			end

			local skill_cfg = SkillData.GetMonsterSkillConfig(self.last_skill_id)
			if nil ~= skill_cfg and self:IsMonster() and 
				("magic1" == skill_cfg.skill_action or "magic2" == skill_cfg.skill_action) then
				self:DoStartSkillReading(target_robert:GetRobertId(), self.last_skill_id, self.attack_index)
			else
				RobertManager.Instance:ReqFight(self, target_robert, self.last_skill_id, self.attack_index)
			end
		end
	end
end

function Robert:DoStartSkillReading(target_robert_id, skill_id, attack_index)
	GlobalTimerQuest:CancelQuest(self.skill_reading_timer)

	if not self.character:StartSkillReading(skill_id) then
		return
	end
	
	self.skill_reading_timer = GlobalTimerQuest:AddDelayTimer(function()
			local target_robert = RobertManager.Instance:GetRobertByRobertId(target_robert_id)
			if nil == target_robert or target_robert:IsDead() then   -- 目标不存在时另外找敌人
				target_robert = RobertManager.Instance:FindEnemy(self)
			end
			RobertManager.Instance:ReqFight(self, target_robert, skill_id, attack_index)
		end, 3)
end

function Robert:DoMove(pos_x, pos_y)
	if self:IsMainRole() then
		GuajiCtrl.Instance:SetGuajiType(GuajiType.None)
		self.character:DoMoveOperate(pos_x, pos_y, 0)
	else
		self.character:DoMove(pos_x, pos_y)
	end
end

function Robert:PlayAction(action_name)
	if nil == action_name or "" == action_name then
		return
	end

	local main_part = self.character:GetDrawObj():GetPart(SceneObjPart.Main)
	if nil ~= main_part then
		main_part:SetTrigger(action_name)
	end
end

function Robert:Say(content, say_time)
	if "" == content or say_time <= 0 then
		return
	end

	self.character:Say(content, say_time)
end

function Robert:Rotate(angle)
	self.character:RotateTo(angle)
end

function Robert:SetLocalRotationY(angle)
	local game_obj = self.character:GetDrawObj():GetRoot()
	game_obj.transform.localRotation = Quaternion.Euler(0, angle, 0)
end

function Robert:StartGather(scene_id, gather_id)
	local scene_cfg = ConfigManager.Instance:GetSceneConfig(scene_id)
	if nil == scene_cfg then
		return
	end

	local pos_x, pos_y = 0, 0
	local gather_obj = Scene.Instance:GetGatherByGatherId(gather_id)
	if nil ~= gather_obj then
		pos_x, pos_y = gather_obj:GetLogicPos()
	else
		for _, v in ipairs(scene_cfg.gathers) do
			if v.id == gather_id then
				pos_x = v.x
				pos_y = v.y
				break
			end
		end
	end

	if 0 == pos_x and 0 == pos_y then
		return
	end

	if self:IsMainRole() then
		GuajiCtrl.Instance:SetGuajiType(GuajiType.None)
		GuajiCtrl.Instance:ClearAllOperate()
		MoveCache.param1 = gather_id
		MoveCache.end_type = MoveEndType.GatherById
		GuajiCtrl.Instance:MoveToPos(scene_id, pos_x, pos_y, 4, 1)
	else
		print("Robert Start Gather", gather_id)
	end
end

function Robert:ChangeAppearance(appearnce_type, appearnce_value)
	local vo = self.character:GetVo()
	if nil == self.old_value_t["appearance"] then
		self.old_value_t["appearance"] = TableCopy(vo.appearance)
	end

	local vo = self.character:GetVo()
	if nil ~= vo and nil ~= vo.appearance and nil ~= vo.appearance[appearnce_type] then
		vo.appearance[appearnce_type] = appearnce_value
		self.character:SetAttr("appearance", vo.appearance)
	end
end

function Robert:ChangeTitle(title_id)
	local vo = self.character:GetVo()
	if nil == self.old_value_t["used_title_list"] then
		self.old_value_t["used_title_list"] = TableCopy(vo.used_title_list)
	end

	vo.used_title_list[1] = tonumber(title_id)
	self.character:SetAttr("used_title_list", vo.used_title_list)
end

function Robert:ChangeAttrValue(attr_key, attr_value)
	local vo = self.character:GetVo()
	if nil == self.old_value_t[attr_key] then
		self.old_value_t[attr_key] = vo[attr_key]
	end

	vo[attr_key] = attr_value
	self.character:SetAttr(attr_key, attr_value)

	if "move_speed" == attr_key and self:IsMainRole() then
		self.character:SetIsOnlyClintMove(true)
	end
end

function Robert:RefrehOldAttrValue(attr_key, attr_value)
	if nil ~= self.old_value_t[attr_key] then
		self.old_value_t[attr_key] = attr_value
		return true
	end

	return false
end

function Robert:ResumeOldAttr()
	for k,v in pairs(self.old_value_t) do
		self.character:SetAttr(k, v)
	end

	self.old_value_t = {}
end

function Robert:ChangeAoeRange(aoe_range)
	self.aoe_range = aoe_range
end

function Robert:ChangeMinGongji(min_gongji)
	self.min_gongji = min_gongji
end

function Robert:ChangeMaxGongji(max_gongji)
	self.max_gongji = max_gongji
end

function Robert:OnDie()
	if nil ~= self.skill_reading_timer then
		GlobalTimerQuest:CancelQuest(self.skill_reading_timer)
		self.skill_reading_timer = nil
	end

	self.last_skill_id = 0
	self.attack_index = 0

	if "" ~= self.robert_cfg.relive_x and "" ~= self.robert_cfg.relive_y and
		0 ~= self.robert_cfg.relive_x and 0 ~= self.robert_cfg.relive_y then
		self.relive_time = Status.NowTime + self.robert_cfg.relive_cd
	else
		if self.robert_cfg.monster_id == 10000 then
			self.delete_time = Status.NowTime + 2.8
		else
			self.delete_time = Status.NowTime + 2
		end
	end

	RobertManager.Instance:OnRobertDie(self)
end

function Robert:Relive()
	self.old_is_dead = false
	local vo = self.character:GetVo()
	vo.max_hp = self.robert_cfg.max_hp
	vo.hp = vo.max_hp
	self.character.show_hp = vo.max_hp
	self.character:ChangeToCommonState(true)

	self:SetLogicPos(self.robert_cfg.relive_x, self.robert_cfg.relive_y)
end

function Robert:OnBeHited()
	if self:IsMainRole() and self.character:GetIsGatherState() then
		Scene.SendStopGatherReq()
	end
end