WakeUpFocusData = WakeUpFocusData or BaseClass()

TALENT_ATTENTION_SKILL_MAX_SAVE_NUM = 8
function WakeUpFocusData:__init()
	WakeUpFocusData.Instance = self
	local talent_cfg = ConfigManager.Instance:GetAutoConfig("greate_soldier_config_auto")
	self.talent_skill_cfg = ListToMap(talent_cfg.talent_skill, "skill_type", "skill_quality")
	-- 从0开始的技能类型表
	self.max_type = talent_cfg.talent_skill[#talent_cfg.talent_skill].skill_type
	self.max_num = 0
	local last_type = -1
	for k,v in pairs(talent_cfg.talent_skill) do
		if v.is_show_skill == 1 and last_type ~= v.skill_type then
			self.max_num = self.max_num + 1
			last_type = v.skill_type
		end
	end
	self.focus_num = 0
	self.show_list = {}
	for i = 0, self.max_type do
		if self.talent_skill_cfg[i][0].is_show_skill == 1 then
			table.insert(self.show_list, i)
		end
	end
end

function WakeUpFocusData:__delete()
	WakeUpFocusData.Instance = nil
end

function WakeUpFocusData:SetData(protocol)
	self.focus_list = protocol.save_skill_id
	self.correct_list = {}
	for k,v in pairs(self.focus_list) do
		self.correct_list[v] = true
	end
end

function WakeUpFocusData:GetCorrectIndex(cell_index)
	return self.show_list[cell_index]
end

function WakeUpFocusData:GetSkillListTypeNum()
	-- 每四个为一组
	return self.max_num
end

function WakeUpFocusData:GetSkillCfg()
	return self.talent_skill_cfg
end

function WakeUpFocusData:IsFocus(skill_id)
	if self.focus_list == nil then 
		return false
	end
	if self.correct_list[skill_id] then
		return true
	end
	return false
end

function WakeUpFocusData:IsMaxFocusNum()
	return self.focus_num == TALENT_ATTENTION_SKILL_MAX_SAVE_NUM
end

function WakeUpFocusData:AddFocus()
	self.focus_num = self.focus_num + 1
end

function WakeUpFocusData:DelFocus()
	self.focus_num = self.focus_num - 1
end

function WakeUpFocusData:IsFocusCorrect()
	local list = FamousGeneralWakeUpData.Instance:GetTalentChoujiangPageInfo()
	for i,v in pairs(list) do
		if v.skill_id then
			if self:IsFocus(v.skill_id) then
				return true
			end
		end
	end
	return false
end

function WakeUpFocusData:IsFirstFocusCorrect()
	local list = FamousGeneralWakeUpData.Instance:GetTalentChoujiangPageInfo()
	if list[1] and list[1].skill_id then
		return self:IsFocus(list[1].skill_id)
	end
	return false
end