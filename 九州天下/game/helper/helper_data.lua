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
	EQUIP = 1,									--装备	
	MOUNT = 2,									--坐骑
	WING = 3,									--羽翼	
	HALO = 4,									--光环（天罡）
	SHENYI = 5,									--披风
	BEAUTY_HALO = 6,							--美人光环
	FIGHT_MOUNT = 7,							--法印
	HALODOM = 8,								--圣物
	SHENGONG = 9,								--足迹								
}

HELPER_EXECUTE_TYPE ={
	TO_NPC = 1, 								--前往npc做相应任务
	OPEN_PANEL = 2,								--打开面板
	DO_TASK = 3,								--做任务
	OPEN_ACTIVITY = 4,							--打开活动面板
	MOVE_UPGRADE_PO = 5,						--野外杀怪
}

HelperData = HelperData or BaseClass()
function HelperData:__init()
	if HelperData.Instance then
		print_error("[HelperData] Attemp to create a singleton twice !")
	end
	self.capability_cal_cfg = ConfigManager.Instance:GetAutoConfig("helper_auto").capability_cal
	self.capability_helper_module_cfg = ListToMap(ConfigManager.Instance:GetAutoConfig("helper_auto").capability_cal, "module")

	HelperData.Instance = self
end

function HelperData:__delete()
	self.capability_cal_cfg = nil
	HelperData.Instance = nil
end

function HelperData:GetHelperListCfg()
	return ConfigManager.Instance:GetAutoConfig("helper_auto").helper_list
end

function HelperData:GetCapabilityCalCfg()
	return self.capability_cal_cfg
end

function HelperData:GetTypeCount()
	for k,v in pairs(self.capability_cal_cfg) do
		if v.type_count then 
			 return v.type_count
		end
	end
	return 0
end

--返回当前等级的所有推荐战力集合
function HelperData:GetSuggestCapList()
	local level = GameVoManager.Instance:GetMainRoleVo().level
	local capability_cal_cfg = self.capability_cal_cfg
	local suggest_cap_list = {}
	local highest_cap_list = {}
	-- for i=1,8 do
		for k,v in pairs(capability_cal_cfg) do
			if level >= v.min_level and level <= v.max_level then
				table.insert(suggest_cap_list, v.suggest_cap)
				table.insert(highest_cap_list, v.highest_cap)
			end
		end
	-- end
	local list = {}
	list.suggest_cap_list = suggest_cap_list
	list.highest_cap_list = highest_cap_list
	return list
end

--返回对应类型
function HelperData:GetHelperModule(module_type)
	return self.capability_helper_module_cfg[module_type] or nil 
	-- local cfg = self.capability_cal_cfg
	-- for k,v in pairs(cfg) do
	-- 	if module_type == v.module then
	-- 		return v
	-- 	end
	-- end
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
			table.insert(list, v)
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
		zhan_li = ShengongData.Instance:GetShenGongPower()
	elseif evaluate_type == HELPER_EVALUATE_TYPE.MOUNT then
		zhan_li = MountData.Instance:GetMountPower()
	elseif evaluate_type == HELPER_EVALUATE_TYPE.HALODOM then							--圣物
		zhan_li = HalidomData.Instance:GetHalidomPower()
	elseif evaluate_type == HELPER_EVALUATE_TYPE.WING then
		zhan_li = WingData.Instance:GetWingPower()
	elseif evaluate_type == HELPER_EVALUATE_TYPE.BEAUTY_HALO then						--芳华
		zhan_li = BeautyHaloData.Instance:GetBeautyHaloPower()
	elseif evaluate_type == HELPER_EVALUATE_TYPE.HALO then
		zhan_li = HaloData.Instance:GetHaloPower()
	elseif evaluate_type == HELPER_EVALUATE_TYPE.SHENYI then
		zhan_li = ShenyiData.Instance:GetShenYiPower()
	elseif evaluate_type == HELPER_EVALUATE_TYPE.FIGHT_MOUNT then
		attr = FaZhenData.Instance:GetMountAttrSum()
	end
	if attr == 0 then
		return zhan_li
	end
	if attr ~= nil and attr ~= 0 then
		zhan_li = CommonDataManager.GetCapability(attr)
		if skill_capability ~= 0 then
			zhan_li = zhan_li + skill_capability
		end
	end
	return zhan_li
end

function HelperData:GetRemainCount(module1)
	local count = 0
	if module1 == "day_activity" then
		count = TaskData.Instance:GetCompletedTaskCountByType(TASK_TYPE.RI)
	elseif module1 == "husong" then
	count = YunbiaoData.Instance:GetHusongRemainTimes()
	end
	return count
end

--获得当前等级适合的杀怪地点
function HelperData:GetUpgradePosByLevel()
	local level = GameVoManager.Instance:GetMainRoleVo().level
	local cfg = ConfigManager.Instance:GetAutoConfig("helper_auto").upgrade_pos
	local pos_cfg = {}
	for k, v in pairs(cfg) do
		if level > v.min_level and level <= v.max_level then
			pos_cfg = v
			break
		end
	end
	return pos_cfg
end