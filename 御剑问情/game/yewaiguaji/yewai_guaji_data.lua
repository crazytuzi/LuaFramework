YewaiGuajiData =YewaiGuajiData or BaseClass()

function YewaiGuajiData:__init()
	if YewaiGuajiData.Instance then
		print_error("YewaiGuajiData] Attemp to create a singleton twice !")
	end
	YewaiGuajiData.Instance = self
	self.guaji_info_cfg = ConfigManager.Instance:GetAutoConfig("guaji_pos_auto").pos_list_new
	self.fb_scene_config = ConfigManager.Instance:GetAutoConfig("guaji_pos_auto").show_scene
	self.boss_kill_cfg = ConfigManager.Instance:GetAutoConfig("guaji_pos_auto").other[1]
	self.role_safe_area = ListToMap(ConfigManager.Instance:GetAutoConfig("guaji_pos_auto").role_save_area, "scene_id")
	self.guaji_list = {}
	self.guaji_sceneid_list = {}
	self.cur_scene_boss = {}
	self.cur_scene_id = 0
	self.cur_has_kill_boss = 0
	self:GetGuaJiPosList()
end

function YewaiGuajiData:__delete()
	self.guaji_info_cfg = nil
	self.fb_scene_config = nil
	if YewaiGuajiData.Instance ~= nil then
		YewaiGuajiData.Instance = nil
	end
	UnityEngine.PlayerPrefs.DeleteKey("GuaJiBossView")
end

--通过每层的scene_id_数目，获得对应的场景数量
function YewaiGuajiData:GetGuaJiPosListNum(index)
	local num = 0
	for k,v in ipairs(self.guaji_info_cfg[index]) do
		if v["scene_id_" .. k] ~= nil then
			num = num + 1
		end
	end
	return num
end

-- 获取显示的挂机地图列表
function YewaiGuajiData:GetGuaJiPosList()
	local guaji_list_temp = {}
	local my_level = GameVoManager.Instance:GetMainRoleVo().level
	for k,v in ipairs(self.guaji_info_cfg) do
		table.insert(guaji_list_temp,v)
		if(my_level < v.level_limit and #guaji_list_temp > 2) then
			break
		end
	end
	self.guaji_list = {}
	local temp_length = #guaji_list_temp
	table.insert(self.guaji_list, guaji_list_temp[temp_length - 2])
	table.insert(self.guaji_list, guaji_list_temp[temp_length - 1])
	table.insert(self.guaji_list, guaji_list_temp[temp_length])
	return self.guaji_list
end

--获取所有挂机地图场景id
function YewaiGuajiData:GetGuaJiSceneIdList()
	self.guaji_sceneid_list = {}
	local list = self:GetGuaJiPosList()
	for i,v in ipairs(list) do
		table.insert(self.guaji_sceneid_list, v.scene_id_1)
	end
	return self.guaji_sceneid_list
end

--获取挂机场景id
function YewaiGuajiData:SetGuaJiSceneId(scene_id)
	self.cur_scene_id = scene_id
end

function YewaiGuajiData:GetGuaJiSceneId()
	return self.cur_scene_id
end

-- 获取地图等级限制
function YewaiGuajiData:GetMapLevelLimit(index)
	return self.guaji_list[index].level_limit
end

--获取怪物配置索引
function YewaiGuajiData:GetGuaiwuIndex(index)
	local guaiwu_temp = 1
	local guaji_item = self.guaji_list[index]
	local cur_level = 0
	local my_level = GameVoManager.Instance:GetMainRoleVo().level
	for i = 1, 99 do
		local level = guaji_item["level_"..i]
		if(level == nil or level == "") then
			break
		end
		if my_level >= level and level > cur_level then
			cur_level = level
			guaiwu_temp = i
		end
	end
	return guaiwu_temp
end

-- 获取场景名字
function YewaiGuajiData:GetGuaJiSceneName(index, guaiwu_temp)
	local guaji_item = self.guaji_list[index]
	local scene_id = guaji_item["scene_id_"..guaiwu_temp]
	return ConfigManager.Instance:GetSceneConfig(scene_id).name
end

--获取挂机地图位置
function YewaiGuajiData:GetGuajiPos(index, guaiwu_temp)
	local guaji_pos = {}
	local guaji_item = self.guaji_list[index]
	table.insert(guaji_pos,guaji_item.scene_id_1)
	table.insert(guaji_pos,guaji_item["x_"..guaiwu_temp])
	table.insert(guaji_pos,guaji_item["y_"..guaiwu_temp])
	return guaji_pos
end

--获取挂机标准经验
function YewaiGuajiData:GetStanderdExp(index, guaiwu_temp)
	local guaji_item = self.guaji_list[index]
	return guaji_item["standard_exp_"..guaiwu_temp]
end

--获取挂机装备数量
function YewaiGuajiData:GetEquipNum(index, guaiwu_temp)
	local guaji_item = self.guaji_list[index]
	return guaji_item["blue_num_"..guaiwu_temp] , guaji_item["purple_num_"..guaiwu_temp]
end

--获取挂机装备阶数
function YewaiGuajiData:GetEquipmentLevel(index, guaiwu_temp)
	local guaji_item = self.guaji_list[index]
	return guaji_item["equip_level_"..guaiwu_temp]
end

function YewaiGuajiData:GetMap(index)
	return self.guaji_list[index].map_res
end

function YewaiGuajiData:GetFlagShowIcon()
	local current_scene = GameVoManager.Instance:GetMainRoleVo().scene_id
	local flag = false
	for i,v in ipairs(self.fb_scene_config) do
		if v.scene_id == current_scene then
			flag = true
		end
	end
	return flag
end

function YewaiGuajiData:GetBossKillLimit()
	return self.boss_kill_cfg.kill_limit or 0
end

function YewaiGuajiData:SetCurHasKillBossCount(value)
	self.cur_has_kill_boss = value
	if self.cur_has_kill_boss == GameEnum.GUAJI_BOSS_NEED_COUNT then
		GlobalEventSystem:Fire(OtherEventType.VIRTUAL_TASK_CHANGE)
	end
end

function YewaiGuajiData:GetCurHasKillBossCount()
	return self.cur_has_kill_boss
end

function YewaiGuajiData:SetSceneBossInfo(protocol)
	self.cur_scene_boss = protocol.boss_count_list or {}
end

function YewaiGuajiData:GetSceneBossInfo()
	return self.cur_scene_boss or {}
end

function YewaiGuajiData:IsShowGuaJiBossTask()
	local is_open = OpenFunData.Instance:CheckIsHide("yewaiguaji")
	local num = self.cur_has_kill_boss < GameEnum.GUAJI_BOSS_NEED_COUNT
	return is_open and num and self:GetFlagShowIcon()
end

--是否挂机场景
function YewaiGuajiData:IsGuaJiScene(scene_id)
	local scene_list = self:GetGuaJiSceneIdList()
	for _, v in ipairs(scene_list) do
		if v == scene_id then
			return true
		end
	end
	return false
end

function YewaiGuajiData:GetBossPosition(scene_id, boss_id)
	local scene_config = ConfigManager.Instance:GetSceneConfig(scene_id)
	if scene_config then
		local boss_cfg_list = scene_config.monsters
		for k,v in pairs(boss_cfg_list) do
			if v.id == boss_id then
				return v.x, v.y
			end
		end
	end
	return nil, nil
end

function YewaiGuajiData:GetSafeAreaPosition(scene_id)
	return self.role_safe_area[scene_id]
end

-- 存放三倍挂机活动状态标志
function YewaiGuajiData:SetTripleExpFlag(status)
	self.triple_exp_flag = status
end

-- 取出三倍挂机活动状态标志
function YewaiGuajiData:GetTripleExpFlag()
	return self.triple_exp_flag or 0
end

function YewaiGuajiData:IsShowMainUIIcon()
	local cfg = ActivityData.Instance:GetClockActivityByID(ACTIVITY_TYPE.ACTIVITY_TYPE_TRIPLE_GUAJI)
	if nil == next(cfg) then
		return false
	end

	local role_level = GameVoManager.Instance:GetMainRoleVo().level
	if role_level >= cfg.min_level then
		return true
	end
	return false
end