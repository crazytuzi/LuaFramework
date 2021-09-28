FamousGeneralWakeUpData = FamousGeneralWakeUpData or BaseClass()

function FamousGeneralWakeUpData:__init(instance)
	if FamousGeneralWakeUpData.Instance then
		print_error("[ItemData] Attemp to creat a singleton twice!")
	end
	FamousGeneralWakeUpData.Instance = self

	local talent_cfg = ConfigManager.Instance:GetAutoConfig("greate_soldier_config_auto")

	self.talent_choujiang_stage_cfg = ListToMap(talent_cfg.choujiang_stage, "stage")
	self.talent_skill_cfg = ListToMap(talent_cfg.talent_skill, "skill_id", "skill_star")
	self.talent_skill_item_cfg = ListToMap(talent_cfg.talent_skill, "book_id", "skill_star")
	
	self.talent_other_cfg = talent_cfg.other[1]

	self.flush_cost_cfg = talent_cfg.flush_cost

	self.free_chou_count = self.talent_other_cfg.free_count

	self.free_chou_count = 0
	self.choujiang_times = 0
	self.choujiang_grid_skill = {}
end



function FamousGeneralWakeUpData:SetTalentChoujiangPageInfo(protocol)
	if self.init then
		FamousGeneralCtrl.Instance:FlushAnim()
	end
	self.free_chou_count = protocol.free_chou_count
	self.choujiang_times = protocol.cur_count
	self.choujiang_grid_skill = protocol.choujiang_grid_skill
	self.init = true
end

function FamousGeneralWakeUpData:GetTalentChoujiangPageInfo()
	if nil == self.choujiang_grid_skill then
		return
	end

	local choujiang_info_list = {}
	for i,v in ipairs(self.choujiang_grid_skill) do
		local info = {}
		info.seq = i - 1
		if self.talent_skill_item_cfg[v] then
			info.skill_id = self.talent_skill_item_cfg[v][0].skill_id
		else
			if v == 0 then
				info.skill_id = 0
			else
				info.item_id = v
			end
		end
		table.insert(choujiang_info_list, info)
	end

	return choujiang_info_list
end

function FamousGeneralWakeUpData:GetTalentStageConfigByTimes(choujiang_times)
	for k,v in pairs(self.talent_choujiang_stage_cfg) do
		if choujiang_times >= v.min_count and choujiang_times <= v.max_count then
			return v
		end
	end
end

function FamousGeneralWakeUpData:GetTalentChouJiangMaxtStageConfig()
	return self.talent_choujiang_stage_cfg[#self.talent_choujiang_stage_cfg]
end

function FamousGeneralWakeUpData:GetCurChouJiangTimes()
	return self.choujiang_times
end

function FamousGeneralWakeUpData:GetFreeChouJiangTimes()
	return self.talent_other_cfg.free_count - self.free_chou_count
end

function FamousGeneralWakeUpData:GetTalentSkillConfig(skill_id, skill_star)
	if nil == self.talent_skill_cfg[skill_id] then
		return
	end
	return self.talent_skill_cfg[skill_id][skill_star]
end

function FamousGeneralWakeUpData:GetTalentFlushCost(count)
	for k,v in pairs(self.flush_cost_cfg) do
		if v.count == count then
			return v. gold
		end
	end
end