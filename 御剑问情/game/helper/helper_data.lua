HELPER_SCORE ={
	PERFECT = 1,								-- 完美
	GOOD = 2,									-- 良好
	PASS = 3,									-- 及格
	NO_PASS = 4									-- 不及格
}
HELPER_TYPE ={
	GET_EXP = 2,								-- 经验获取
	GET_EQUIP = 3,								-- 装备获取
	GET_MAT = 4,								-- 材料获取
	GET_PERSON = 5,								-- 个性获取
}

HELPER_EVALUATE_TYPE ={
	EQUIP = 1,
	MOUNT = 2,
	WING = 3,
	ACHIEVE = 4,
	SPIRIT = 5,
	HALO = 6,
	GODDESS = 7,
	SHENGONG = 8,
	SHENYI = 9,
	FIGHT_MOUNT = 10,
}

HELPER_EVALUATE_TYPE_COUNT = 10

HELPER_EXECUTE_TYPE ={
	TO_NPC = 1, 								--前往npc做相应任务
	OPEN_PANEL = 2,								--打开面板
	DO_TASK = 3,								--做任务
}

HelperData = HelperData or BaseClass()
function HelperData:__init()
	if HelperData.Instance then
		print_error("[HelperData] Attemp to create a singleton twice !")
	end
	HelperData.Instance = self
end

function HelperData:__delete()
	HelperData.Instance = nil
end

function HelperData:GetHelperListCfg()
	return ConfigManager.Instance:GetAutoConfig("helper_auto").helper_list
end

function HelperData:GetCapabilityCalCfg()
	return ConfigManager.Instance:GetAutoConfig("helper_auto").capability_cal
end

--返回当前等级的所有推荐战力集合
function HelperData:GetSuggestCapList()
	local level = GameVoManager.Instance:GetMainRoleVo().level
	local capability_cal_cfg = self:GetCapabilityCalCfg()
	local suggest_cap_list = {}
	local highest_cap_list = {}
	for i=1,8 do
		for k,v in pairs(capability_cal_cfg) do
			if level >= v.min_level and level <= v.max_level then
				suggest_cap_list[#suggest_cap_list + 1] = v.suggest_cap
				highest_cap_list[#highest_cap_list + 1] = v.highest_cap
			end
		end
	end
	local list = {}
	list.suggest_cap_list = suggest_cap_list
	list.highest_cap_list = highest_cap_list
	return list
end

--返回对应类型
function HelperData:GetHelperModule(module_type)
	local cfg = self:GetCapabilityCalCfg()
	for k,v in pairs(cfg) do
		if module_type == v.module then
			return v
		end
	end
end

--返回评分
function HelperData:GetHelperScore(current_score ,highest_cap)
	local score = current_score / highest_cap
	if score < 0.6 then
		return HELPER_SCORE.NO_PASS
	elseif 0.6 <= score and score < 0.75 then
		return HELPER_SCORE.PASS
	elseif 0.75 <= score and score < 0.9 then
		return HELPER_SCORE.GOOD
	elseif 0.9 <= score and score < 1 or score >= 1 then
		return HELPER_SCORE.PERFECT
	end
end

--获得配置
function HelperData:GetHelperListByType(the_type, grid_index)
	local cfg = self:GetHelperListCfg()
	local list = {}
	for k,v in pairs(cfg) do
		if v.type == the_type then
			list[#list + 1] = v
		end
	end
	return list
end

--返回对应类型的自身战力
function HelperData:GetCurrentScore(evaluate_type)
	local attr = nil
	local zhan_li = 0
	local skill_capability = 0
	if evaluate_type == HELPER_EVALUATE_TYPE.EQUIP then
		zhan_li = ForgeData.Instance:GetEquipZhanLi()
	elseif evaluate_type == HELPER_EVALUATE_TYPE.SHENGONG then
		local shengong_data = ShengongData.Instance
		attr = shengong_data:GetShengongAttrSum()
		for i = 0, 3 do
			if shengong_data:GetShengongSkillCfgById(i) then
				skill_capability = skill_capability + shengong_data:GetShengongSkillCfgById(i).capability
			end
		end
	elseif evaluate_type == HELPER_EVALUATE_TYPE.MOUNT then
		attr = MountData.Instance:GetMountAttrSum()
	elseif evaluate_type == HELPER_EVALUATE_TYPE.SPIRIT then
		zhan_li = SpiritData.Instance:GetAllSpiritPower()
	elseif evaluate_type == HELPER_EVALUATE_TYPE.WING then
		attr = WingData.Instance:GetWingAttrSum()
	elseif evaluate_type == HELPER_EVALUATE_TYPE.GODDESS then
		zhan_li = GoddessData.Instance:GetAllPower()
	elseif evaluate_type == HELPER_EVALUATE_TYPE.ACHIEVE then
		local current_title_level = AchieveData.Instance:GetTitleLevel()
		local currnet_title_data = AchieveData.Instance:GetAchieveTitleDataByLevel(current_title_level)
		if currnet_title_data ~= nil then
			zhan_li = CommonDataManager.GetCapability(currnet_title_data)
		end
	elseif evaluate_type == HELPER_EVALUATE_TYPE.HALO then
		attr = HaloData.Instance:GetHaloAttrSum()
	elseif evaluate_type == HELPER_EVALUATE_TYPE.SHENYI then
		local shenyi_data = ShenyiData.Instance
		attr = shenyi_data:GetShenyiAttrSum()
		for i = 0, 3 do
			if shenyi_data:GetShenyiSkillCfgById(i) then
				skill_capability = skill_capability + shenyi_data:GetShenyiSkillCfgById(i).capability
			end
		end
	elseif evaluate_type == HELPER_EVALUATE_TYPE.FIGHT_MOUNT then
		attr = FightMountData.Instance:GetMountAttrSum()
	end
	if attr == 0 then
		return zhan_li
	end
	if attr ~= 0 and attr ~= nil then
		zhan_li = CommonDataManager.GetCapability(attr)
		if skill_capability ~= 0 then
			zhan_li = zhan_li + skill_capability
		end
	end

	return zhan_li
end

function HelperData:GetRemainCount(module)
	local count = 0
	if module == "day_activity" then
		count = TaskData.Instance:GetCompletedTaskCountByType(TASK_TYPE.RI)
	elseif module == "husong" then
		count = YunbiaoData.Instance:GetHusongRemainTimes()
	end
	return count
end


