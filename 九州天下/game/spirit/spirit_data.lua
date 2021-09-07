SpiritData = SpiritData or BaseClass()

SpiritDataExchangeType = {
	Type = 5
}

SOUL_ATTR_NAME_LIST = {
	[0] = "gongji",
	[1] = "fangyu",
	[2] = "maxhp",
	[3] = "mingzhong",
	[4] = "shanbi",
	[5] = "baoji",
	[6] = "jianren",
}

-- 天赋属性图标
SPIRIT_TALENT_ICON_LIST = {
	[1] = "icon_info_gj",
	[2] = "icon_info_fy",
	[3] = "icon_info_hp",
	[4] = "icon_info_mz",
	[5] = "icon_info_sb",
	[6] = "icon_info_bj",
	[7] = "icon_info_kb",
}

SOUL_FROM_VIEW = {SOUL_POOL = 1, SOUL_BAG = 2}

function SpiritData:__init()
	if SpiritData.Instance ~= nil then
		print_error("[SpiritData]:Attempt to create singleton twice!")
		return
	end

	SpiritData.Instance = self
	self.spirit_info = {}
	self.item_list = {}
	self.warehouse_item_list = {}
	self.slot_soul_info = {}
	self.soul_bag_info = {}
	self.fazhen_info = {}
	self.halo_info = {}
	self.is_no_play_ani = false

	RemindManager.Instance:Register(RemindName.Spirit, BindTool.Bind(self.GetSpiritRemind, self))
end

function SpiritData:__delete()
	-- self.spirit_info = {}
	RemindManager.Instance:UnRegister(RemindName.Spirit)

	self.spirit_info = {}
	self.chest_shop_mode = nil
	self.free_time = nil
	self.warehouse_item_list = {}
	self.exchange_score = nil
	self.item_list = {}
	self.slot_soul_info = {}
	self.soul_bag_info = {}
	self.fazhen_info = {}
	self.halo_info = {}
	self.is_no_play_ani = nil

	UnityEngine.PlayerPrefs.DeleteKey("slotnewindex")
	UnityEngine.PlayerPrefs.DeleteKey("combinesoul")
	UnityEngine.PlayerPrefs.DeleteKey("onekeysale")
	UnityEngine.PlayerPrefs.DeleteKey("onekeysalepurple")
	UnityEngine.PlayerPrefs.DeleteKey("multiplecall")
	UnityEngine.PlayerPrefs.DeleteKey("changelife")
	UnityEngine.PlayerPrefs.DeleteKey("putbagonekey")
	UnityEngine.PlayerPrefs.DeleteKey("singlesale")

	SpiritData.Instance = nil
end

function SpiritData:ClearData()
	self.item_list = {}
end

-- 配置
function SpiritData:GetMaxSpiritGroup()
	return #ConfigManager.Instance:GetAutoConfig("jingling_auto").group
end

function SpiritData:GetSpiritGroup()
	return ConfigManager.Instance:GetAutoConfig("jingling_auto").group
end

function SpiritData:GetSpiritHuanImageConfig()
	return ConfigManager.Instance:GetAutoConfig("jingling_auto").phantom_image
end

function SpiritData:GetMaxSpiritHuanhuaImage()
	return #ConfigManager.Instance:GetAutoConfig("jingling_auto").phantom_image
end

function SpiritData:GetSpiritLevelConfig()
	return ConfigManager.Instance:GetAutoConfig("jingling_auto").uplevel
end

function SpiritData:GetSpiritHuanhuaLevelConfig()
	return ConfigManager.Instance:GetAutoConfig("jingling_auto").jingling_phantom
end

function SpiritData:GetSpiritImageConfig()
	return ConfigManager.Instance:GetAutoConfig("jingling_auto").jingling_image
end

function SpiritData:GetSpiritOtherCfg()
	return ConfigManager.Instance:GetAutoConfig("jingling_auto").other[1]
end


-- 精灵兑换
function SpiritData:GethuntSpiritPriceCfg()
	return ConfigManager.Instance:GetAutoConfig("chestshop_auto").other
end

function SpiritData:GetSpiritResourceCfg()
	return ConfigManager.Instance:GetAutoConfig("jingling_auto").soul_name
end

-- 获取精灵命魂配置
function SpiritData:GetSpiritSoulCfg(id)
	return ConfigManager.Instance:GetAutoConfig("lieming_auto").hunshou[id]
end

function SpiritData:GetAllSpiritSoulCfg()
	-- body
	return ConfigManager.Instance:GetAutoConfig("lieming_auto").hunshou
end

-- 获取精灵命魂经验配置
function SpiritData:GetSpiritSoulExpCfg()
	return ConfigManager.Instance:GetAutoConfig("lieming_auto").hunshou_exp
end

-- 获取抽取精灵命魂消耗魂力配置
function SpiritData:GetSpiritCallSoulCfg()
	return ConfigManager.Instance:GetAutoConfig("lieming_auto").chouhun
end

-- 获取精灵命魂槽开启配置
function SpiritData:GetSpiritSoulOpenCfg()
	return ConfigManager.Instance:GetAutoConfig("lieming_auto").hunge_activity_condition
end

-- 精灵法阵阶数配置
function SpiritData:GetSpiritFazhenGradeCfg()
	return ConfigManager.Instance:GetAutoConfig("jingling_fazhen_auto").grade
end

-- 精灵法阵最大阶数配置
function SpiritData:GetMaxSpiritFazhenGrade()
	return #ConfigManager.Instance:GetAutoConfig("jingling_fazhen_auto").grade
end

-- 精灵法阵形象配置
function SpiritData:GetSpiritFazhenImageCfg()
	return ConfigManager.Instance:GetAutoConfig("jingling_fazhen_auto").image_list
end

-- 精灵法阵特殊形象配置
function SpiritData:GetSpiritFazhenSpecialImageCfg()
	return ConfigManager.Instance:GetAutoConfig("jingling_fazhen_auto").special_img
end

-- 精灵法阵特殊形象个数
function SpiritData:GetMaxSpiritFazhenSpecialImage()
	return #ConfigManager.Instance:GetAutoConfig("jingling_fazhen_auto").special_img
end

-- 精灵法阵特殊形象进阶
function SpiritData:GetSpiritFazhenSpecialImageUpgrade()
	return ConfigManager.Instance:GetAutoConfig("jingling_fazhen_auto").special_image_upgrade
end


-- 精灵光环阶数配置
function SpiritData:GetSpiritHaloGradeCfg()
	return ConfigManager.Instance:GetAutoConfig("jingling_guanghuan_auto").grade
end

-- 精灵光环最大阶数配置
function SpiritData:GetMaxSpiritHaloGrade()
	return #ConfigManager.Instance:GetAutoConfig("jingling_guanghuan_auto").grade
end

-- 精灵光环形象配置
function SpiritData:GetSpiritHaloImageCfg()
	return ConfigManager.Instance:GetAutoConfig("jingling_guanghuan_auto").image_list
end

-- 精灵光环特殊形象配置
function SpiritData:GetSpiritHaloSpecialImageCfg()
	return ConfigManager.Instance:GetAutoConfig("jingling_guanghuan_auto").special_img
end

-- 精灵光环特殊形象配置
function SpiritData:GetMaxSpiritHaloSpecialImage()
	return #ConfigManager.Instance:GetAutoConfig("jingling_guanghuan_auto").special_img
end

-- 精灵光环特殊形象进阶
function SpiritData:GetSpiritHaloSpecialImageUpgrade()
	return ConfigManager.Instance:GetAutoConfig("jingling_guanghuan_auto").special_image_upgrade
end

-- 协议
function SpiritData:SetSpiritInfo(protocol)
	self.spirit_info.jingling_name = protocol.jingling_name
	self.spirit_info.use_jingling_id = protocol.use_jingling_id
	self.spirit_info.use_imageid = protocol.use_imageid
	self.spirit_info.m_active_image_flag = protocol.m_active_image_flag
	self.spirit_info.special_img_active_flag = protocol.special_img_active_flag
	self.spirit_info.phantom_imageid = protocol.phantom_imageid
	self.spirit_info.count = protocol.count

	self.spirit_info.jinglingcard_list = protocol.jinglingcard_list
	self.spirit_info.phantom_level_list = protocol.phantom_level_list
	self.spirit_info.phantom_level_list_new = protocol.phantom_level_list_new
	self.spirit_info.jingling_list = protocol.jingling_list
end

function SpiritData:GetSpiritInfo()
	return self.spirit_info
end

-- 设置上一次点击的类型，  1抽、 10连抽
function SpiritData:SetChestshopMode(chest_shop_mode)
	self.chest_shop_mode = chest_shop_mode
end

function SpiritData:SetHuntSpiritItemList(item_list)
	self.item_list = item_list
	SpiritCtrl.Instance.spirit_view:Flush("hunt")
	TipsCtrl.Instance:ShowTreasureView(self.chest_shop_mode)
	SpiritCtrl.Instance:SendGetSpiritScore()
end

function SpiritData:GetHuntSpiritItemList()
	return self.item_list or {}
end

-- 设置是否播放抽奖动画
function SpiritData:SetPlayAniState(value)
	self.is_no_play_ani = value or false
end

function SpiritData:IsNoPlayAni()
	return self.is_no_play_ani
end

function SpiritData:SetHuntSpiritFreeTime(time)
	self.free_time = time
	SpiritCtrl.Instance.spirit_view:Flush("hunt")
end

-- 获取猎取间隔时间
function SpiritData:GetHuntSpiritFreeTime()
	return self.free_time or 0
end

function SpiritData:SetHuntSpiritWarehouseList(item_list)
	-- self.warehouse_item_list = item_list
	self.warehouse_item_list = self:GetBagBestSpirit(item_list, true)
	SpiritCtrl.Instance.spirit_view:Flush("warehouse")
end

-- 获取仓库数据
function SpiritData:GetHuntSpiritWarehouseList()
	return self.warehouse_item_list or {}
end

-- 设置精灵命魂槽信息
function SpiritData:SetSpiritSlotSoulInfo(protocol)
	self.slot_soul_info.notify_reason = protocol.notify_reason
	self.slot_soul_info.slot_activity_flag = protocol.slot_activity_flag
	self.slot_soul_info.slot_list = protocol.slot_list
end

function SpiritData:GetSpiritSlotSoulInfo()
	return self.slot_soul_info
end

function SpiritData:SetSpiritSoulBagInfo(protocol)
	self.soul_bag_info.notify_reason = protocol.notify_reason
	self.soul_bag_info.hunshou_exp = protocol.hunshou_exp
	self.soul_bag_info.liehun_color = protocol.liehun_color
	self.soul_bag_info.hunli = protocol.hunli
	self.soul_bag_info.liehun_pool = protocol.liehun_pool
	self.soul_bag_info.grid_list = protocol.grid_list
end

function SpiritData:GetSpiritSoulBagInfo()
	return self.soul_bag_info
end

-- 设置精灵法阵信息
function SpiritData:SetSpiritFazhenInfo(protocol)
	self.fazhen_info.grade = protocol.grade
	self.fazhen_info.used_imageid = protocol.used_imageid
	self.fazhen_info.active_image_flag = protocol.active_image_flag
	self.fazhen_info.grade_bless_val = protocol.grade_bless_val
	self.fazhen_info.active_special_image_flag = protocol.active_special_image_flag
	self.fazhen_info.active_special_image_list = bit:d2b(self.fazhen_info.active_special_image_flag)
	self.fazhen_info.special_img_grade_list = protocol.special_img_grade_list
end

function SpiritData:GetSpiritFazhenInfo()
	return self.fazhen_info
end

-- 设置精灵光环信息
function SpiritData:SetSpiritHaloInfo(protocol)
	self.halo_info.grade = protocol.grade
	self.halo_info.used_imageid = protocol.used_imageid
	self.halo_info.active_image_flag = protocol.active_image_flag
	self.halo_info.grade_bless_val = protocol.grade_bless_val
	self.halo_info.active_special_image_flag = protocol.active_special_image_flag
	self.halo_info.active_special_image_list = bit:d2b(self.halo_info.active_special_image_flag)
	self.halo_info.special_img_grade_list = protocol.special_img_grade_list

	self.halo_info.equip_skill_level = protocol.equip_skill_level
	self.halo_info.equip_level_list = protocol.equip_level_list
end

function SpiritData:GetSpiritHaloInfo()
	return self.halo_info
end

-- 获取展示精灵列表
function SpiritData:GetDisplaySpiritList()
	local chest_cfg = ConfigManager.Instance:GetAutoConfig("chestshop_auto").rare_item_list
	local list = {}
	for k, v in pairs(chest_cfg) do
		if v.xunbao_type == XUNBAO_TYPE.JINGLING_TYPE then
			list[v.display_index] = {item_id = v.rare_item_id}
		end
	end
	return list
end

-- 获取兑换配置
function SpiritData:GetSpiritExchangeCfgList()
	local list = {}
	local convert_cfg = ConfigManager.Instance:GetAutoConfig("convertshop_auto").convert_shop
	for k, v in pairs(convert_cfg) do
		if v.conver_type == SpiritDataExchangeType.Type then
			-- local copy_table = TableCopy(v)
			-- copy_table.param = {strengthen_level = 1}
			table.insert(list, v)
		end
	end
	return list
end

-- 精灵积分
function SpiritData:SetSpiritExchangeScore(score)
	self.exchange_score = score
	SpiritCtrl.Instance.spirit_view:Flush("exchange")
end

function SpiritData:GetSpiritExchangeScore()
	return self.exchange_score or 0
end

-- 获取当前空的精灵格子
function SpiritData:HasNotSprite()
	return self.spirit_info.count == 0
end

-- 获取当前空的精灵格子
function SpiritData:GetSpiritItemIndex()
	if self.spirit_info.count == 0 then
		return 1
	end
	for i = 1, 4 do
		if self.spirit_info.jingling_list[i] == nil then
			return i
		end
	end
	return nil
end

-- 通过等级获取精灵配置
function SpiritData:GetSpiritLevelCfgByLevel(index, level)
	if self.spirit_info.jingling_list[index] == nil then
		return
	end
	local level = level or self.spirit_info.jingling_list[index].param.strengthen_level
	for k, v in pairs(self:GetSpiritLevelConfig()) do
		if level == v.level and self.spirit_info.jingling_list[index].item_id == v.item_id then
			return v
		end
	end
	return nil
end

-- 获取当前等级的精灵的回收总灵晶
function SpiritData:GetSpiritAllLingjingByLevel(item_id, level)
	if not item_id then return 0 end
	if level == 0 then
		level = 1
	end
	local all_lingjing = 0
	for k, v in pairs(self:GetSpiritLevelConfig()) do
		if item_id == v.item_id then
			if v.level < level then
				all_lingjing = all_lingjing + v.cost_lingjing
			end
		end
	end
	return all_lingjing * 0.8
end

-- 通过ID获取精灵配置
function SpiritData:GetSpiritLevelCfgById(item_id, level)
	if level == 0 then
		level = 1
	end
	for k, v in pairs(self:GetSpiritLevelConfig()) do
		if level == v.level and item_id == v.item_id then
			return v
		end
	end
	return nil
end

-- 获取精灵最大升级数
function SpiritData:GetMaxSpiritUplevel(item_id)
	local list = {}
	for k, v in pairs(self:GetSpiritLevelConfig()) do
		if v.item_id == item_id then
			table.insert(list, v)
		end
	end
	return #list
end

-- 获取已激活的法阵组合
-- function SpiritData:GetMaxShowFaZhen()
-- 	if self.spirit_info.jingling_list == nil then
-- 		return 0
-- 	end
-- 	local data_list = {self.spirit_info.jingling_list[0] or {}, self.spirit_info.jingling_list[1] or {},
-- 					self.spirit_info.jingling_list[2] or {}, self.spirit_info.jingling_list[3] or {}}
-- 	local list_1 = {}
-- 	local list_2 = {}
-- 	local list_3 = {}
-- 	local list_4 = {}
-- 	local group_2 = {}
-- 	local group_3 = {}
-- 	local group_4 = {}
-- 	local item_ids = {}
-- 	local all_list = {}
-- 	for k, v in pairs(self:GetSpiritGroup()) do
-- 		item_ids[v.id] = {}
-- 		for i = 1, 4 do
-- 			if v["itemid"..i] == data_list[1].item_id then
-- 				list_1[v.id] = v["itemid"..i]
-- 			end
-- 			if v["itemid"..i] == data_list[2].item_id then
-- 				list_2[v.id] = v["itemid"..i]
-- 			end
-- 			if v["itemid"..i] == data_list[3].item_id then
-- 				list_3[v.id] = v["itemid"..i]
-- 			end
-- 			if v["itemid"..i] == data_list[4].item_id then
-- 				list_4[v.id] = v["itemid"..i]
-- 			end
-- 			if v["itemid"..i] > 0 then
-- 				item_ids[v.id][#item_ids[v.id] + 1] = v["itemid"..i]
-- 			end
-- 		end
-- 	end
-- 	for k, v in pairs(self:GetSpiritGroup()) do
-- 		if list_1[v.id] ~= nil and list_2[v.id] ~= nil and list_3[v.id] ~= nil and list_4[v.id] ~= nil and #item_ids[v.id] >= 4 then
-- 			group_4[#group_4 + 1] = v
-- 		end
-- 		if #item_ids[v.id] == 2 then
-- 			if (list_1[v.id] ~= nil and list_2[v.id] ~= nil) or (list_1[v.id] ~= nil and list_3[v.id] ~= nil) or
-- 				(list_1[v.id] ~= nil and list_4[v.id] ~= nil) or (list_2[v.id] ~= nil and list_3[v.id] ~= nil) or
-- 				(list_2[v.id] ~= nil and list_4[v.id] ~= nil) or (list_3[v.id] ~= nil and list_4[v.id] ~= nil) then
-- 				group_2[#group_2 + 1] = v
-- 			end
-- 		end
-- 		if #item_ids[v.id] == 3 then
-- 			if (list_1[v.id] ~= nil and list_2[v.id] ~= nil and list_3[v.id] ~= nil) or
-- 				(list_1[v.id] ~= nil and list_2[v.id] ~= nil and list_4[v.id] ~= nil) or
-- 				(list_1[v.id] ~= nil and list_3[v.id] ~= nil and list_4[v.id] ~= nil) or
-- 				(list_2[v.id] ~= nil and list_3[v.id] ~= nil and list_4[v.id] ~= nil) then
-- 				group_3[#group_3 + 1] = v
-- 			end
-- 		end
-- 	end
-- 	return (#group_2 + #group_3 + #group_4), group_2, group_3, group_4
-- end

-- 通过等级、ID获取精灵幻化配置
function SpiritData:GetSpiritHuanhuaCfgById(image_id, level)
	for k, v in pairs(self:GetSpiritHuanhuaLevelConfig()) do
		if v.type == image_id and v.level == level then
			return v
		end
	end
	return nil
end

-- 获取精灵幻化升级上限
function SpiritData:GetMaxSpiritHuanhuaLevelById(image_id)
	local list = {}
	for k, v in pairs(self:GetSpiritHuanhuaLevelConfig()) do
		if v.type == image_id then
			list[#list + 1] = v
		end
	end
	return #list - 1
end

-- 获取精灵天赋属性
function SpiritData:GetSpiritTalentAttrCfgById(item_id)
	local talent_cfg = ConfigManager.Instance:GetAutoConfig("jingling_auto").talent_attr
	for k, v in pairs(talent_cfg) do
		if item_id == v.item_id then
			return v
		end
	end
end

-- 精灵总战力
function SpiritData:GetAllSpiritFightPower()
	local fight_power = 0
	for k, v in pairs(self.spirit_info.jingling_list) do
		 local attr = CommonDataManager.GetAttributteNoUnderline(self:GetSpiritLevelCfgByLevel(v.index), true)
		 fight_power = fight_power + CommonDataManager.GetCapability(attr)
	end
	return fight_power
end

-- 通过ID获取装备精灵信息
function SpiritData:GetDressSpiritInfoById(item_id)
	if nil == self.spirit_info or nil == self.spirit_info.jingling_list or nil == item_id then
		return
	end
	for k,v in pairs(self.spirit_info.jingling_list) do
		if v.item_id == item_id then
			return v
		end
	end
	return nil
end

-- 获取精灵幻化配置
function SpiritData:GetSpiritHuanConfigByItemId(item_id)
	if nil == item_id then return end
	for k, v in pairs(self:GetSpiritHuanhuaLevelConfig()) do
		if v.stuff_id == item_id then
			return v
		end
	end
	return nil
end

-- 精灵阵法组合排序
function SpiritData:GetSpiritGroupCfg()
	local list = {}
	local group = {}
	if nil == self.spirit_info or nil == next(self.spirit_info) or nil == self.spirit_info.jingling_list
		or nil == next(self.spirit_info.jingling_list) then
		return group
	end
	local jingling_list = {self.spirit_info.jingling_list[0], self.spirit_info.jingling_list[1],
					self.spirit_info.jingling_list[2], self.spirit_info.jingling_list[3]}

	for k, v in pairs(self:GetSpiritGroup()) do
		local num = 0
		for i = 1, 5 do
			for n, m in pairs(jingling_list) do
				if m.item_id == v["itemid"..i] then
					num = num + 1
					-- table.insert(list[v.id], v)
				end
			end
		end
		list[v.id] = {count = num, id = v.id}
	end

	for k, v in pairs(list) do
		if self:GetSpiritGroupLenghtById(k) <= list[k].count then
			list[k].had_active = 1
			list[k].diffe = 0
		else
			list[k].had_active = 0
			list[k].diffe = self:GetSpiritGroupLenghtById(k) - list[k].count
		end
		local count, pingfen = self:GetSpiritGroupLenghtById(k, true)
		list[k].pingfen = pingfen
	end
	for k, v in pairs(self:GetSpiritGroup()) do
		if list[v.id] then
			table.insert(group, list[v.id])
		end
	end

	table.sort(group, function (a, b)
		if not a.pingfen then
			a.pingfen = 0
		end
		if not b.pingfen then
			b.pingfen = 0
		end
		if a.had_active ~= b.had_active then
			return a.had_active > b.had_active
		end

		if a.diffe ~= b.diffe then
			return a.diffe < b.diffe
		end

		if a.pingfen ~= b.pingfen then
			return a.pingfen > b.pingfen
		end

		if a.pingfen == b.pingfen and a.count ~= b.count then
			return a.count > b.count
		end

		return a.id < b.id
	end)

	return group
end

-- 获取当前组合的长度
function SpiritData:GetSpiritGroupLenghtById(id, zuhe_pingfen)
	if nil == id then return end
	local group_cfg = self:GetSpiritGroup()[id]
	if nil == group_cfg then return end

	local count = 0
	for i = 1, 5 do
		if group_cfg["itemid"..i] > 0 then
			count = count + 1
		end
	end
	if zuhe_pingfen then
		return count, group_cfg.zuhe_pingfen
	end
	return count, 0
end

-- 精灵幻化红点
function SpiritData:ShowHuanhuaRedPoint()
	local list = {}
	if nil == self.spirit_info.phantom_level_list or nil == self.spirit_info.phantom_level_list_new then return list end

	for k, v in pairs(ItemData.Instance:GetBagItemDataList()) do
		for i, j in ipairs(self:GetSpiritHuanhuaLevelConfig()) do
			if j.type < GameEnum.JINGLING_PTHANTOM_MAX_TYPE and self.spirit_info.phantom_level_list[j.type] and
				self.spirit_info.phantom_level_list[j.type] == j.level
				and self.spirit_info.phantom_level_list[j.type] < self:GetMaxSpiritHuanhuaLevelById(j.type) then
				if v.item_id == j.stuff_id and ItemData.Instance:GetItemNumInBagById(v.item_id) >= j.stuff_num  then
					 list[j.type] = j
				end
			else
				if v.item_id == j.stuff_id and self.spirit_info.phantom_level_list_new[j.type - 9] and
					 self.spirit_info.phantom_level_list_new[j.type - 9] == j.level and
					 ItemData.Instance:GetItemNumInBagById(v.item_id) >= j.stuff_num
					 and self.spirit_info.phantom_level_list_new[j.type] < self:GetMaxSpiritHuanhuaLevelById(j.type) then
					 list[j.type] = j
				end
			end
		end
	end

	return list
end

-- 显示精灵-精灵标签红点
function SpiritData:ShowSonSpiritRedPoint()
	-- local vo = GameVoManager.Instance:GetMainRoleVo()
	-- local spirit_info = self.spirit_info and self.spirit_info.jingling_list or {}
	-- for k, v in pairs(spirit_info) do
	-- 	local spirit_level_cfg = self:GetSpiritLevelCfgByLevel(v.index)
	-- 	if vo.lingjing >= spirit_level_cfg.cost_lingjing then
	-- 		return true
	-- 	end
	-- end
	return false
end

-- 是否显示光环红点
function SpiritData:ShowHaloRedPoint()
	if not self.halo_info or not self.halo_info.grade or self.halo_info.grade <= 0 then
		return false
	end
	local grade_cfg = SpiritData.Instance:GetSpiritHaloGradeCfg()[self.halo_info.grade]
	local bag_num = ItemData.Instance:GetItemNumInBagById(grade_cfg.upgrade_stuff_id)
	if bag_num >= grade_cfg.upgrade_stuff_count then
		return true
	end
	return false
end

function SpiritData:GetSpiritRemind()
	return self:ShowMainUISpiritRedPoint() and 1 or 0
end

-- 主界面红点
function SpiritData:ShowMainUISpiritRedPoint()
	if not OpenFunData.Instance:CheckIsHide("spiritview") then
		return false
	end
	local diff_time = self:GetHuntSpiritFreeTime() - TimeCtrl.Instance:GetServerTime()
	if diff_time <= 0 then
		return true
	end

	if next(self:ShowHuanhuaRedPoint()) and OpenFunData.Instance:CheckIsHide("spirit_spirit") then
		return true
	end

	if self:ShowSonSpiritRedPoint() and OpenFunData.Instance:CheckIsHide("spirit_spirit") then
		return true
	end

	if self.warehouse_item_list and next(self.warehouse_item_list) and OpenFunData.Instance:CheckIsHide("spirit_warehouse") then
		return true
	end

	if self.slot_soul_info and self.slot_soul_info.slot_activity_flag and OpenFunData.Instance:CheckIsHide("spirit_soul") then
		local bit_list = bit:d2b(self.slot_soul_info.slot_activity_flag)
		if bit_list then
			local index = 0
			for k, v in pairs(bit_list) do
				if v == 1 then
					index = index + 1
				end
			end

			local old_index = UnityEngine.PlayerPrefs.GetInt("slotoldindex", 999)
			if old_index < index then
				return true
			end
		end
	end
	if self:ShowHaloRedPoint() and OpenFunData.Instance:CheckIsHide("spirit_halo") then
		return true
	end
	if nil ~= next(self:ShowFazhenHuanhuaRedPoint()) and OpenFunData.Instance:CheckIsHide("spirit_fazhen") then
		return true
	end
	if nil ~= next(self:ShowHaloHuanhuaRedPoint()) and OpenFunData.Instance:CheckIsHide("spirit_halo") then
		return true
	end
	return false
end

function SpiritData:GetBagSpiritDataList()
	local equip_list = ItemData.Instance:GetItemListByBigType(GameEnum.ITEM_BIGTYPE_EQUIPMENT)
	local spirit_list = {}

	for _, v in pairs(equip_list) do
		local item_cfg, big_type = ItemData.Instance:GetItemConfig(v.item_id)
		if nil ~= item_cfg
			and GameEnum.ITEM_BIGTYPE_EQUIPMENT == big_type
			and item_cfg.sub_type == GameEnum.EQUIP_TYPE_JINGLING then
			table.insert(spirit_list, v)
		end
	end

	return spirit_list
end

-- 精灵排序
function SpiritData:GetBagBestSpirit(data_list, is_no_bag)
	data_list = data_list or self:GetBagSpiritDataList()

	local list = {}
	local temp_list = {}
	local color = -1
	local temp_color = -1
	local list_lengh = 0
	local last_sort_list = {}
	for k, v in pairs(data_list) do
		table.insert(temp_list, v)
	end
	table.sort(temp_list, function (a, b)
		if not a then
			a = {item_id = 0}
			return a.item_id > b.item_id
		end
		if not b then
			b = {item_id = 0}
			return a.item_id > b.item_id
		end
		local item_cfg_a = ItemData.Instance:GetItemConfig(a.item_id)
		local item_cfg_b = ItemData.Instance:GetItemConfig(b.item_id)
		if item_cfg_a.click_use ~= item_cfg_b.click_use then
			return item_cfg_a.click_use > item_cfg_b.click_use
		end
		if item_cfg_a.color ~= item_cfg_b.color then
			return item_cfg_a.color > item_cfg_b.color
		end
		if a.param and b.param and a.param.strengthen_level ~= b.param.strengthen_level then
			return a.param.strengthen_level > b.param.strengthen_level
		end
		if a.param and b.param and #a.param.xianpin_type_list ~= #b.param.xianpin_type_list then
			return #a.param.xianpin_type_list > #b.param.xianpin_type_list
		end

		if item_cfg_a.bag_type ~= item_cfg_b.bag_type then
			return item_cfg_a.bag_type < item_cfg_b.bag_type
		end

		return a.item_id > b.item_id
	end)

	return temp_list
end

-- 获取精灵模型ID
function SpiritData:GetSpiritResIdByItemId(item_id)
	if nil == item_id then return end

	for k, v in pairs(self:GetSpiritResourceCfg()) do
		if v.id == item_id then
			return v
		end
	end
	return nil
end

-- 预览精灵从高到低排序
function SpiritData:GetDisPlaySpiritListFromHigh()
	local list = self:GetSpiritResourceCfg()

	local sort_list = {}
	for k, v in pairs(list) do
		local cfg = self:GetSpiritLevelCfgById(v.id, 1)
		local base_attr_list = CommonDataManager.GetAttributteNoUnderline(cfg, true)
		local fight_power = CommonDataManager.GetCapability(base_attr_list)
		local temp_data = {}
		temp_data.fight_power = fight_power
		temp_data.id = v.id
		table.insert(sort_list, temp_data)
	end

	table.sort(sort_list, function(a, b)
		return a.fight_power > b.fight_power
	end)

	return sort_list
end

-- 获取命魂属性配置
function SpiritData:GetSoulAttrCfg(id, level, is_sale_exp)
	level = level or 0
	if nil == id or nil == level then return end

	local soul_cfg = self:GetSpiritSoulCfg(id)
	if soul_cfg then
		local attr_cfg = self:GetSpiritSoulExpCfg()
		if not is_sale_exp then
			for k, v in pairs(attr_cfg) do
				if v.hunshou_color == soul_cfg.hunshou_color and v.hunshou_level == level then
					return v
				end
			end
		else
			local exp = 0
			for k, v in pairs(attr_cfg) do
				if v.hunshou_color == soul_cfg.hunshou_color and v.hunshou_level < level then
					exp = exp + v.exp
				end
			end
			return exp
		end
	end

	return nil
end

-- 判断命魂池里面是否有紫色以上品质的命魂
function SpiritData:IsHadMoreThenPurpleSoul()
	for k, v in pairs(self.soul_bag_info.liehun_pool) do
		if self:GetSoulAttrCfg(v.id) and self:GetSoulAttrCfg(v.id).hunshou_color > 2 then
			return true
		end
	end

	return false
end

-- 把命魂池所有类型不同的取出来
function SpiritData:GetSoulPoolHighQuality()
	local list = {}
	local id_list = {}
	local soul_type_list = {}
	local active_count = SpiritData.Instance:GetSlotSoulActiveCount()
	if 0 == active_count then return list end

	if self.soul_bag_info and next(self.soul_bag_info) then
		for k, v in pairs(self.soul_bag_info.liehun_pool) do
			if v.id > 0 and v.id < GameEnum.HUNSHOU_EXP_ID then
				local cfg = self:GetSpiritSoulCfg(v.id)
				if cfg then
					for i = 0, active_count - 1 do
						local slot_info = self.slot_soul_info.slot_list[i]
						id_list[v.id] = id_list[v.id] or {}
						if slot_info.id > 0 then
							local slot_cfg = self:GetSpiritSoulCfg(slot_info.id)
							soul_type_list[slot_cfg.hunshou_type] = soul_type_list[slot_cfg.hunshou_type] or {}
							soul_type_list[slot_cfg.hunshou_type] = slot_cfg.hunshou_color
							if cfg.hunshou_color > slot_cfg.hunshou_color and slot_cfg.hunshou_type == cfg.hunshou_type and not next(id_list[v.id]) then
								id_list[v.id] = {info = v, color = cfg.hunshou_color, soul_type = cfg.hunshou_type, change = 1, slot_index = i}
								table.insert(list, {info = v, color = cfg.hunshou_color, soul_type = cfg.hunshou_type, change = 1, slot_index = i})
							end
						else
							if not next(id_list[v.id]) and (not soul_type_list[cfg.hunshou_type] or
									(soul_type_list[cfg.hunshou_type] and soul_type_list[cfg.hunshou_type] < cfg.hunshou_color)) then

								soul_type_list[cfg.hunshou_type] = cfg.hunshou_color
								table.insert(list, {info = v, color = cfg.hunshou_color, soul_type = cfg.hunshou_type, change = 0, slot_index = i})
							end
						end
					end
				end
			end
		 end
	end
	for k, v in pairs(id_list) do
		if v.change == 1 then
			for m, n in pairs(list) do
				if v.soul_type == n.soul_type and n.color < v.color then
					table.remove(list, m)
				end
			end
		end
	end

	table.sort(list, function(a, b)
		if a.change ~= b.change then
			return a.change > b.change
		end
		if a.color ~= b.color then
			return a.color > b.color
		end
		return a.soul_type < b.soul_type
	end)
	return list
end

-- 获取命魂槽激活个数
function SpiritData:GetSlotSoulActiveCount()
	local count = 0
	if self.slot_soul_info and next(self.slot_soul_info) then
		local bit_list = bit:d2b(self.slot_soul_info.slot_activity_flag) or {}
		for k, v in pairs(self.slot_soul_info.slot_list) do
			if bit_list[32 - k - 1] == 1 then
				count = count + 1
			end
		end
	end
	return count
end

-- 获取可装备命魂槽个数
function SpiritData:GetSlotSoulEmptyCount()
	local count = 0
	if self.slot_soul_info and next(self.slot_soul_info) then
		local bit_list = bit:d2b(self.slot_soul_info.slot_activity_flag) or {}
		for k, v in pairs(self.slot_soul_info.slot_list) do
			if bit_list[32 - k - 1] == 1 and v.id <= 0 then
				count = count + 1
			end
		end
	end
	return count
end

-- 获取命魂槽命魂类型
function SpiritData:GetSlotSoulTypeList()
	local list = {}
	if self.slot_soul_info and next(self.slot_soul_info) then
		for k, v in pairs(self.slot_soul_info.slot_list) do
			if v.id > 0 then
				local slot_cfg = self:GetSpiritSoulCfg(v.id)
				table.insert(list, slot_cfg.hunshou_type)
			end
		end
	end
	return list
end

function SpiritData:GetSlotSoulEmptyCountList()
	local list = {}
	if self.slot_soul_info and next(self.slot_soul_info) then
		local bit_list = bit:d2b(self.slot_soul_info.slot_activity_flag) or {}
		for k, v in pairs(self.slot_soul_info.slot_list) do
			if bit_list[32 - k - 1] == 1 and v.id <= 0 then
				table.insert(list, k)
			end
		end
	end
	return list
end

-- 获取可装备命魂槽索引
function SpiritData:GetSlotSoulEmptyIndex()
	if self.slot_soul_info and next(self.slot_soul_info) then
		local bit_list = bit:d2b(self.slot_soul_info.slot_activity_flag) or {}
		for k, v in pairs(self.slot_soul_info.slot_list) do
			if bit_list[32 - k - 1] == 1 and v.id <= 0 then
				return k
			end
		end
	end
	return nil
end

function SpiritData:SpiritFazhenAttrSum(grade)
	grade = grade or self.fazhen_info.grade
	local attr = CommonStruct.AttributeNoUnderline()
	local star_attr_cfg = self:GetSpiritFazhenGradeCfg()[grade]
	if nil == star_attr_cfg then
		return attr
	end
	attr.gongji = attr.gongji + star_attr_cfg.gongji
	attr.fangyu = attr.fangyu + star_attr_cfg.fangyu
	attr.maxhp = attr.maxhp + star_attr_cfg.maxhp

	return attr
end

function SpiritData:GetFazhenSpecialImgUpgradeCfg(image_id, level)
	level = level or self.fazhen_info.special_img_grade_list[image_id]
	if not image_id then return end

	for k, v in pairs(self:GetSpiritFazhenSpecialImageUpgrade()) do
		if v.special_img_id == image_id and v.grade == level then
			return v
		end
	end
	return nil
end

function SpiritData:GetFazhenMaxUpgrade(image_id)
	local count = 0
	if not image_id then return count end

	for i, j in ipairs(self:GetSpiritFazhenSpecialImageUpgrade()) do
		if j.special_img_id == image_id then
			count = count + 1
		end
	end
	return count
end

-- 精灵幻化红点
function SpiritData:ShowFazhenHuanhuaRedPoint()
	local list = {}
	if nil == self.fazhen_info.special_img_grade_list then return list end
	for k, v in pairs(ItemData.Instance:GetBagItemDataList()) do
		for i, j in ipairs(self:GetSpiritFazhenSpecialImageCfg()) do
			local cfg = self:GetFazhenSpecialImgUpgradeCfg(j.image_id)
			if cfg then
				if cfg.stuff_id == v.item_id and cfg.stuff_num <= ItemData.Instance:GetItemNumInBagById(v.item_id)
					and self:GetFazhenMaxUpgrade(j.image_id) > self.fazhen_info.special_img_grade_list[j.image_id] + 1 then
					list[j.image_id] = cfg
				end
			end
		end
	end

	return list
end

function SpiritData:GetFazhenGradeByUseImageId(used_imageid)
	if not used_imageid then return 0 end
	local image_list = self:GetSpiritFazhenImageCfg()
	if not image_list then return 0 end
	if not image_list[used_imageid] then return 0 end

	local show_grade = image_list[used_imageid].show_grade
	for k, v in pairs(self:GetSpiritFazhenGradeCfg()) do
		if v.show_grade == show_grade then
			return v.grade
		end
	end
	return 0
end

function SpiritData:SpiritHaloAttrSum(grade)
	grade = grade or self.halo_info.grade
	local attr = CommonStruct.AttributeNoUnderline()
	local star_attr_cfg = self:GetSpiritHaloGradeCfg()[grade]
	if nil == star_attr_cfg then
		return attr
	end
	attr.gongji = attr.gongji + star_attr_cfg.gongji
	attr.fangyu = attr.fangyu + star_attr_cfg.fangyu
	attr.maxhp = attr.maxhp + star_attr_cfg.maxhp

	return attr
end

function SpiritData:GetHaloSpecialImgUpgradeCfg(image_id, level)
	level = level or self.halo_info.special_img_grade_list[image_id]
	if not image_id then return end

	for k, v in pairs(self:GetSpiritHaloSpecialImageUpgrade()) do
		if v.special_img_id == image_id and v.grade == level then
			return v
		end
	end
	return nil
end

function SpiritData:GetHaloMaxUpgrade(image_id)
	local count = 0
	if not image_id then return count end

	for i, j in ipairs(self:GetSpiritHaloSpecialImageUpgrade()) do
		if j.special_img_id == image_id then
			count = count + 1
		end
	end
	return count
end

-- 精灵幻化红点
function SpiritData:ShowHaloHuanhuaRedPoint()
	local list = {}
	if nil == self.halo_info.special_img_grade_list then return list end

	for k, v in pairs(ItemData.Instance:GetBagItemDataList()) do
		for i, j in ipairs(self:GetSpiritHaloSpecialImageCfg()) do
			local cfg = self:GetHaloSpecialImgUpgradeCfg(j.image_id)
			if cfg then
				if cfg.stuff_id == v.item_id and cfg.stuff_num <= ItemData.Instance:GetItemNumInBagById(v.item_id)
					and self:GetFazhenMaxUpgrade(j.image_id) > self.halo_info.special_img_grade_list[j.image_id] + 1 then
					list[j.image_id] = cfg
				end
			end
		end
	end

	return list
end

function SpiritData:GetTalentNameByIndex(index)
	local name_list = Language.JingLing.JingLingTalentName
	return name_list[index] or ""
end

function SpiritData:GetShowTalentList(spirit_id, spirit_all_info)
	local list = {}
	local talent_list = {}
	for k,v in pairs(spirit_all_info.jingling_item_list) do
		if v.jingling_id == spirit_id then
			talent_list = v.talent_list
			break
		end
	end
	for k,v in pairs(talent_list) do
		if v ~= 0 then
			table.insert(list, {name = self:GetTalentNameByIndex(v), value = self:GetSpiritTalentAttrCfgById(spirit_id)["type" .. v]/100})
		end
	end

	for i=1,3 do
		if i > #list then
			list[i] = {}
			list[i].name = ""
			list[i].value = 0
		end
	end
	return list
end

function SpiritData:GetSpiritUpLevelCfg(item_id, level)
	for k, v in pairs(self:GetSpiritLevelConfig()) do
		if level == v.level and v.item_id == item_id then
			return v
		end
	end
	return nil
end

function SpiritData:GetSpecialSpiritImageCfg(id)
	for k,v in pairs(self:GetSpiritHuanImageConfig()) do
		if v.active_image_id == id then
			return v
		end
	end
end

--出战 + 幻化
function SpiritData:ChuZhanPower()
	local data = nil
	--出战
	for k,v in pairs(self:GetSpiritInfo().jingling_list) do
		if v.item_id == self.spirit_info.use_jingling_id then
			data = v
		end
	end
	local power = 0
	if data then
		local spirit_level_cfg = self:GetSpiritLevelCfgByLevel(data.index)
		local attr = CommonDataManager.GetAttributteNoUnderline(spirit_level_cfg)
		power = CommonDataManager.GetCapability(CommonDataManager.GetAttributteNoUnderline(attr))
	end
	--幻化
	local huanhua_power = 0
	for k,v in pairs(self.spirit_info.phantom_level_list) do
		local data = SpiritData.Instance:GetSpiritHuanhuaCfgById(k, v)
		local attr_list = CommonDataManager.GetAttributteNoUnderline(data, true)
		huanhua_power = huanhua_power +CommonDataManager.GetCapability(attr_list)
	end
	return power + huanhua_power
end

--命魂战力
function SpiritData:MingHunPower()
	local power = 0
	local slot_soul_info = self:GetSpiritSlotSoulInfo()
	local temp_attr_list = CommonDataManager.GetAttributteNoUnderline()
	if slot_soul_info and next(slot_soul_info) then
		for k, v in pairs(slot_soul_info.slot_list) do
			if v.id > 0 then
				local cfg = SpiritData.Instance:GetSpiritSoulCfg(v.id)
				local attr_list = SpiritData.Instance:GetSoulAttrCfg(v.id, v.level) or {}
				if temp_attr_list[SOUL_ATTR_NAME_LIST[cfg.hunshou_type]] then
					temp_attr_list[SOUL_ATTR_NAME_LIST[cfg.hunshou_type]] = temp_attr_list[SOUL_ATTR_NAME_LIST[cfg.hunshou_type]] + attr_list[SOUL_ATTR_NAME_LIST[cfg.hunshou_type]]
				end
			end
		end
	end
	if temp_attr_list then
	   power = CommonDataManager.GetCapabilityCalculation(temp_attr_list)
	end
	return power
end

--法阵战力 + 幻化
function SpiritData:FaZhenPower()
	--法阵
	local power = 0
	local attr_list = SpiritData.Instance:SpiritFazhenAttrSum()
	power = CommonDataManager.GetCapability(attr_list)
	--幻化
	local huanhua_power = 0
	for i=1, self:GetMaxSpiritFazhenSpecialImage() do
		if self.fazhen_info.active_special_image_list[32 - i] > 0 then
			local data = SpiritData.Instance:GetFazhenSpecialImgUpgradeCfg(i)
			local attr_list = CommonDataManager.GetAttributteNoUnderline(data)
			huanhua_power = huanhua_power + CommonDataManager.GetCapability(attr_list)
		end
	end
	return power + huanhua_power
end

--光环 + 幻化
function SpiritData:HaloPower()
	--光环
	local power = 0
	local attr_list = SpiritData.Instance:SpiritHaloAttrSum()
	power = CommonDataManager.GetCapability(attr_list)
	--幻化
	local huanhua_power = 0
	for i=1, self:GetMaxSpiritHaloGrade() do
		if self.halo_info.active_special_image_list[32 - i] > 0 then
			local data = SpiritData.Instance:GetHaloSpecialImgUpgradeCfg(i)
			local attr_list = CommonDataManager.GetAttributteNoUnderline(data)
			huanhua_power = huanhua_power + CommonDataManager.GetCapability(attr_list)
		end
	end
	return power + huanhua_power
end

--获取精灵系统总战力
function SpiritData:GetAllSpiritPower()
	local all_power = 0
	all_power = all_power + self:ChuZhanPower() + self:MingHunPower() + self:FaZhenPower() + self:HaloPower()
	return all_power
end


