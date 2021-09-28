RollingBarrageData = RollingBarrageData or BaseClass()

local TOTAL_DES_NUM = 50

RollingTextLength = 30
-- CHEST_SHOP_TYPE ={
-- 	CHEST_SHOP_TYPE_INVALID = 0,
-- 	CHEST_SHOP_TYPE_EQUIP = 1,							-- 装备
-- 	CHEST_SHOP_TYPE_JINGLING = 2,						-- 精灵
-- }

function RollingBarrageData:__init()
	if nil ~= RollingBarrageData.Instance then
		return
	end

	RollingBarrageData.Instance = self

	self.random_name_cfg = ConfigManager.Instance:GetAutoConfig("randname_auto").random_name[1].female_last
	self.xun_bao_cfg = ConfigManager.Instance:GetAutoConfig("chestshop_auto")

	self.recod_list = {}
	self.now_check_type = CHEST_SHOP_TYPE.CHEST_SHOP_TYPE_EQUIP
	self.is_no_barrage_list ={}
	self.text_tab= {}
	self.new_text_tab = {}
	self.jump_index_tab = {}
	self.curr_index = 0
end

function RollingBarrageData:__delete()
	RollingBarrageData.Instance = nil
end

-- 打开面板前,记录当前是打开哪个寻宝界面
function RollingBarrageData:SetNowCheckType(check_type)
	self.now_check_type = check_type or 1
end

-- 记录是否点击屏蔽
function RollingBarrageData:RecordBarrageState(check_type, value)
	self.is_no_barrage_list[check_type] = value
end

function RollingBarrageData:GetRecordBarrageState(check_type)
	return self.is_no_barrage_list[check_type]
end

function RollingBarrageData:SetRecordList(protocol)
	local list = {}
	list = protocol.record_list
	self.recod_list[protocol.record_type] = list
end

function RollingBarrageData:GetDesList(check_type)
	check_type = check_type or self.now_check_type

	local list = {}
	local item_list = self:GetBroadcastItemList(check_type)
	local random_index = 1
	local item_cfg = nil
	local des_str, name = "", ""
	local recod_list = self.recod_list[check_type] or {}
	local random_type = 1

	for i = 1, 50 do
		if nil ~= recod_list[i] then
			item_cfg = ItemData.Instance:GetItemConfig(recod_list[i].item_id)
			name = recod_list[i].role_name
		else
			random_index = math.random(1, #item_list)
			item_cfg = ItemData.Instance:GetItemConfig(item_list[random_index].item_id)
			random_index = math.random(1, #self.random_name_cfg)
			name = self.random_name_cfg[random_index]
		end
		random_type = math.random(1, 3)
		if check_type == CHEST_SHOP_TYPE.CHEST_SHOP_TYPE_EQUIP then
			des_str = string.format(Language.Xunbao.DanMuEquipTypeList[random_type], name, BARRAGE_COLOR[item_cfg.color], item_cfg.name)
		else
			des_str = string.format(Language.Xunbao.DanMuSpiritTypeList[random_type], name, BARRAGE_COLOR[item_cfg.color], item_cfg.name)
		end
		table.insert(list, des_str)
	end

	return list
end

function RollingBarrageData:GetBroadcastItemList(check_type)
	local cur_day = TimeCtrl.Instance:GetCurOpenServerDay()
	local cfg = nil
	if cur_day < 8 then
		cfg = self.xun_bao_cfg.item_list1
	elseif cur_day >= 8 and cur_day < 15 then
		cfg = self.xun_bao_cfg.item_list2
	elseif cur_day >= 15 and cur_day < 30 then
		cfg = self.xun_bao_cfg.item_list3
	else
		cfg = self.xun_bao_cfg.item_list4
	end
	local list = {}
	if nil == cfg then return end

	list[CHEST_SHOP_TYPE.CHEST_SHOP_TYPE_EQUIP] = {}
	list[CHEST_SHOP_TYPE.CHEST_SHOP_TYPE_JINGLING] = {}

	local item_cfg = nil
	for k, v in pairs(cfg) do
		if v.is_broadcast == 1 then
			item_cfg = ItemData.Instance:GetItemConfig(v.item_id)
			if nil ~= item_cfg then
				if EquipData.IsJLType(item_cfg.sub_type) then
					table.insert(list[CHEST_SHOP_TYPE.CHEST_SHOP_TYPE_JINGLING], v)
				elseif (v.item_id == 26406 and RankData.Instance:GetIdByIndex(6) > 0) or v.item_id ~= 26406 then
					table.insert(list[CHEST_SHOP_TYPE.CHEST_SHOP_TYPE_EQUIP], v)
				end
			end
		end
	end
	return list[check_type]
end

function RollingBarrageData:SetTextData(text)
	self.curr_index = (self.curr_index >= RollingTextLength) and 1 or self.curr_index + 1
	self.text_tab[self.curr_index] = text

	self.new_text_tab[#self.new_text_tab + 1] = text
end

function RollingBarrageData:GetTextData()
	return self.text_tab
end
--新text列表，立即刷出弹幕
function RollingBarrageData:GetNewTextData()
	return self.new_text_tab
end