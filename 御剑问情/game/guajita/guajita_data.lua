GuaJiTaData = GuaJiTaData or BaseClass()

GUAJI_TA_TIME_CARD_ITEM_ID = 23247		-- 离线时间卡ID
GuaJiTaData.SP_TYPE = {
	TYPE = 1,
	SLOT = 2,
	LV = 3,
}
function GuaJiTaData:__init()
	if GuaJiTaData.Instance then
		return
	end

	GuaJiTaData.Instance = self

	self.rune_info = {}
	self.rune_offline_info = {}
	self.rune_auto_cfg = ConfigManager.Instance:GetAutoConfig("rune_tower_cfg_auto") or {}
	self.rune_auto_layer_cfg = ListToMap(ConfigManager.Instance:GetAutoConfig("rune_tower_cfg_auto").layer, "fb_layer")

	self.auto_btn_state = false

	RemindManager.Instance:Register(RemindName.RuneTower, BindTool.Bind(self.GetRuneTowerRemind, self))
end

function GuaJiTaData:__delete()
	RemindManager.Instance:UnRegister(RemindName.RuneTower)

	if GuaJiTaData.Instance then
		GuaJiTaData.Instance = nil
	end
	self.rune_info = {}
	self.rune_auto_cfg = {}
	self.rune_offline_info = {}
end

-- 设置符文塔信息
function GuaJiTaData:SetRuneTowerInfo(protocol)
	local info = {}
	info.pass_layer = protocol.pass_layer
	info.fb_today_layer = protocol.fb_today_layer
	info.offline_time = protocol.offline_time
	info.fetch_time_count = protocol.fetch_time_count
	self.rune_info = info
end

function GuaJiTaData:GetRuneTowerInfo()
	return self.rune_info
end

-- 符文塔离线挂机信息
function GuaJiTaData:SetRuneTowerOfflineInfo(protocol)
	local info = {}
	info.fb_offline_time = protocol.fb_offline_time
	info.guaji_time = protocol.guaji_time
	info.kill_monster_num = protocol.kill_monster_num
	info.old_level = protocol.old_level
	info.new_level = protocol.new_level
	info.add_exp = protocol.add_exp
	info.add_jinghua = protocol.add_jinghua
	info.add_equip_blue = protocol.add_equip_blue
	info.add_equip_purple = protocol.add_equip_purple
	info.add_equip_orange = protocol.add_equip_orange
	info.add_mojing = protocol.add_mojing
	info.recycl_equip_blue = protocol.recycl_equip_blue
	info.recycl_equip_purple = protocol.recycl_equip_purple
	info.recycl_equip_orange = protocol.recycl_equip_orange

	self.rune_offline_info = info
end

function GuaJiTaData:GetRuneTowerOfflineInfo()
	return self.rune_offline_info
end

function GuaJiTaData:GetRuneTowerLayerCfgByLayer(layer)
	if not layer then return {} end

	for k, v in ipairs(self.rune_auto_cfg.layer) do
		if v.fb_layer == layer then
			return v
		end
	end

	return {}
end

-- 勇者之塔
function GuaJiTaData:GetRuneTowerFBLevelCfg()
	local list = {}

	if self.patafb_level_cfg then
		return self.patafb_level_cfg
	end

	for k, v in pairs(ConfigManager.Instance:GetAutoConfig("rune_tower_cfg_auto").layer) do
		list[v.fb_layer] = v
	end

	self.patafb_level_cfg = list

	return list
end

local NotShow = 0				--不展示
local RuneType = 1 				--开启的符文类型
local RuneSlot = 2 				--开启的符文槽
local RuneLevel = 3 			--开启的符文等级
--获取符文塔下一个开启信息
function GuaJiTaData:GetNextFunOpenInfo(layer)
	layer = layer or 1
	local next_fun_open_info = nil
	--不处理当前层
	local cfg = self:GetRuneTowerFBLevelCfg()
	for i = layer + 1, #cfg do
		local info = cfg[i]
		if info.sp_type and info.sp_type > NotShow then
			next_fun_open_info = info
			break
		end
	end
	return next_fun_open_info
end

function GuaJiTaData:GetSpecialRewardLevel(level)
	local level = level or self.rune_info.pass_layer
	if not level then return end
	for k, v in ipairs(self:GetRuneTowerFBLevelCfg()) do
		if v.sp_type > 0 and level < v.fb_layer then
			return v
		end
	end
	return nil
end

function GuaJiTaData:GetSpecialRewardCfg(level)
	local level = level or self.rune_info.pass_layer
	if not level then return end
	if self.rune_auto_layer_cfg[level] and self.rune_auto_layer_cfg[level].sp_type > 0 then
		return self.rune_auto_layer_cfg[level]
	end
	return nil
end

function GuaJiTaData:GetRuneMaxLayer()
	if self.max_layer == nil then
		local count = 0
		for k, v in pairs(self.rune_auto_cfg.layer) do
			count = count + 1
		end
		 self.max_layer = count
	end
	return self.max_layer
end

function GuaJiTaData:GetRuneOtherCfg()
	if next(self.rune_auto_cfg) then
		return self.rune_auto_cfg.other[1]
	end
	return {}
end

function GuaJiTaData:GetRuneMonsterPosCfg(index)
	if next(self.rune_auto_cfg) then
		return self.rune_auto_cfg.monster_pos[index]
	end
	return {}
end

function GuaJiTaData:GetRuneTowerRemind()
	return self:IsShowRedPoint() and 1 or 0
end

-- 显示活动界面红点
function GuaJiTaData:IsShowRedPoint()
	if not OpenFunData.Instance:CheckIsHide("rune") then
		return false
	end

	if next(self.rune_info) then
		if self.rune_info.pass_layer ~= self.rune_info.fb_today_layer then
			return true
		end
		if ClickOnceRemindList[RemindName.RuneTower] == 0 then
			return false
		end
		local cfg = self:GetRuneTowerLayerCfgByLayer(self.rune_info.pass_layer + 1)
		if next(cfg) then
			local capability = GameVoManager.Instance:GetMainRoleVo().capability
			if capability >= cfg.capability then
				return true
			end
		end
	end
	return false
end

-- 显示活动界面红点
function GuaJiTaData:RuneTowerCanChallange()
	if not OpenFunData.Instance:CheckIsHide("runetowerview") or self.rune_info.pass_layer == nil then
		return false
	end
	local layer = math.min(self.rune_info.pass_layer + 1, self:GetRuneMaxLayer())
	local capability = GameVoManager.Instance:GetMainRoleVo().capability
	for k, v in ipairs(self.rune_auto_cfg.layer) do
		if v.fb_layer == layer then
			return capability >= v.capability
		end
	end
	return false
end

function GuaJiTaData:SetAutoBtnState(value)
	self.auto_btn_state = value
end

function GuaJiTaData:GetAutoBtnState()
	return self.auto_btn_state
end

function GuaJiTaData:SetAutoRewardData(protocol)
	self.auto_rewar_data_list = protocol.item_list
	if protocol.reward_jinghua > 0 then
		table.insert(self.auto_rewar_data_list, {item_id = ResPath.CurrencyToIconId.rune_jinghua, num = protocol.reward_jinghua, is_bind = 0})
	end
end

function GuaJiTaData:GetAutoRewardData()
	return self.auto_rewar_data_list
end