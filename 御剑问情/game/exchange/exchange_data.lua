ExchangeData = ExchangeData or BaseClass()

EXCHANGE_CONVER_TYPE =
{
	DAO_JU = 2,
	XUN_BAO = 3,
	EQUIP = 4,
	JING_LING = 5,
	HAPP_YTREE = 6,
	BUILD = 10,
	SCORE_TO_ITEM_TYPE_RED_EQUIP = 11,			-- 红装兑换
}

EXCHANGE_PRICE_TYPE =
{
	MOJING = 1,
	SHENGWANG = 2,
	GONGXUN = 3,
	WEI_WANG = 4,
	TREASURE = 5,
	JINGLING = 6,
	HAPPYTREE = 7,
	RONGYAO = 8,
	GUANGHUI = 9,
	JIFEN = 10,
	Blue_lingzhi = 11,
	Purple_lingzhi = 12,
	Orange_lingzhi = 13,
	BOSSSCORE = 14,
	SCORE_TO_ITEM_PRICE_TYPE_ITEM_STUFF = 15,		-- 物品材料
}

REQUIRE_TYPE = {
	LEVEL = 1,
}
local RES_ENUM = {
	[1] = "ShengWang",
	[2] = "RongYu",
	[5] = "XunBao",
	[7] = "HunaLeShu",
	[8] = "RongYao",
	[9] = "GuangHui",
	[14] = "MiZang"
}

local SHOW_EXCHANGE_TAB =
{
	1,		 --MOJING
	2, 		--RONG_YU
	8,		--RONG_YAO
	9, 		--GUANGHUI
	14,      --XIANJING
}

function ExchangeData:__init()
	if ExchangeData.Instance then
		print_error("[ExchangeData] Attemp to create a singleton twice !")
	end
	ExchangeData.Instance = self
	self.convert_record_info = {}
	self.lifetime_record_list = {}
	self.gouyu_record = {}
	self.score_list = {}
	self.is_click = {}
	self:InitClickState(5)
	self.other_config = ConfigManager.Instance:GetAutoConfig("convertshop_auto").other
	self.convert_shop_config = ConfigManager.Instance:GetAutoConfig("convertshop_auto").convert_shop
	local convertshop_cfg = ConfigManager.Instance:GetAutoConfig("convertshop_auto")
	self.red_equip_convert_config = ListToMapList(convertshop_cfg.red_equip_convert, "conver_type", "price_type", "show_limit")
	self.equip_order_cfg = convertshop_cfg.equip_order
	self.remind_change = BindTool.Bind(self.RemindChangeCallBack, self)
	RemindManager.Instance:Register(RemindName.Echange, self.remind_change)
end

function ExchangeData:__delete()
	if ExchangeData.Instance then
		ExchangeData.Instance = nil
	end
	self.convert_record_info = {}
	self.score_list = {}
	UnityEngine.PlayerPrefs.DeleteKey("exchange_prop")
	RemindManager.Instance:UnRegister(RemindName.Echange)
end

function ExchangeData:OnConvertRecordInfo(protocol)
	self.convert_record_info = protocol.convert_record
	self.lifetime_record_list = protocol.lifetime_record_list
	self.gouyu_record = protocol.gouyu_record
end

function ExchangeData:InitClickState(index)
	for i=1,index do
		self.is_click[i] = {is_click = false}
	end
end

function ExchangeData:SetClickState(index)
	local main_role_id = GameVoManager.Instance:GetMainRoleVo().role_id
	local cur_day = TimeCtrl.Instance:GetCurOpenServerDay()
	UnityEngine.PlayerPrefs.SetInt(main_role_id .. "exchange_onclick" .. index, cur_day)
end

function ExchangeData:GetClickState(index)
	local main_role_id = GameVoManager.Instance:GetMainRoleVo().role_id
	local cur_day = TimeCtrl.Instance:GetCurOpenServerDay()
	if cur_day <= 7 then
		local click_state = UnityEngine.PlayerPrefs.GetInt(main_role_id .. "exchange_onclick" .. index)
		return cur_day == click_state
	else
		return true
	end
end

function ExchangeData:GetLifeTimeRecordCount()
	local count = 0
	if next(self.lifetime_record_list) then
		count = #self.lifetime_record_list
	end
	return count
end

function ExchangeData:GetConvertRecordInfo()
	return self.convert_record_info
end

function ExchangeData:GetConvertCount(seq, convert_type, price_type)
	for k,v in pairs(self.convert_record_info) do
		if v.seq == seq and v.convert_type == convert_type then
			return v.convert_count
		end
	end
	return 0
end

function ExchangeData:OnScoreInfo(protocol)
	self.score_list[EXCHANGE_PRICE_TYPE.MOJING] = protocol.chest_shop_mojing
	self.score_list[EXCHANGE_PRICE_TYPE.SHENGWANG] = protocol.chest_shop_shengwang
	self.score_list[EXCHANGE_PRICE_TYPE.GONGXUN] = protocol.chest_shop_gongxun
	self.score_list[EXCHANGE_PRICE_TYPE.WEI_WANG] = protocol.chest_shop_weiwang
	self.score_list[EXCHANGE_PRICE_TYPE.TREASURE] = protocol.chest_shop_treasure_credit
	self.score_list[EXCHANGE_PRICE_TYPE.JINGLING] = protocol.chest_shop_jingling_credit
	self.score_list[EXCHANGE_PRICE_TYPE.HAPPYTREE] = protocol.chest_shop_happytree_grow
	self.score_list[EXCHANGE_PRICE_TYPE.JIFEN] = protocol.chest_shop_jifen
	self.score_list[EXCHANGE_PRICE_TYPE.Blue_lingzhi] = protocol.chest_shop_blue_lingzhi
	self.score_list[EXCHANGE_PRICE_TYPE.Purple_lingzhi] = protocol.chest_shop_purple_lingzhi
	self.score_list[EXCHANGE_PRICE_TYPE.Orange_lingzhi] = protocol.chest_shop_orange_lingzhi
	self.score_list[EXCHANGE_PRICE_TYPE.GUANGHUI] = protocol.chest_shop_guanghui
	self.score_list[EXCHANGE_PRICE_TYPE.BOSSSCORE] = protocol.chest_shop_precious_boss_score
	PlayerData.Instance:SetAttr("guanghui", protocol.chest_shop_guanghui)
end

function ExchangeData:SetGuangHuiInfo(num)
	self.score_list[EXCHANGE_PRICE_TYPE.GUANGHUI] = num
end

--获取所有兑换配置
function ExchangeData:GetAllExchangeCfg()
	return ConfigManager.Instance:GetAutoConfig("convertshop_auto").convert_shop
end

function ExchangeData:GetUsefulExchageCfg()
	local useful_cfg = {}
	for k,v in pairs(ConfigManager.Instance:GetAutoConfig("convertshop_auto").convert_shop) do
		useful_cfg[#useful_cfg + 1] = v
	end
	if next(self.lifetime_record_list) then
		for i = #useful_cfg, 1, -1 do
			for k,v in pairs(self.lifetime_record_list) do
				if useful_cfg[i] and useful_cfg[i].seq == v.seq and useful_cfg[i].lifetime_convert_count ~= 0
					and useful_cfg[i].lifetime_convert_count <= v.convert_count
					and useful_cfg[i].conver_type == v.convert_type then
					table.remove(useful_cfg, i)
				end
			end
		end
	end
	return useful_cfg
end

--获取单个兑换配置
function ExchangeData:GetExchangeCfg(item_id, price_type)
	local item_list = ConfigManager.Instance:GetAutoConfig("convertshop_auto").convert_shop
	for k,v in pairs(item_list) do
		if v.item_id == item_id and v.price_type == price_type then
			return v
		end
	end
end

-- 获取兑换翻倍配置
function ExchangeData:GetMultipleCostCfg(convert_count, multiple_cost_id)
	if not convert_count or not multiple_cost_id then return end
	if 0 == multiple_cost_id then return end

	local item_list = ConfigManager.Instance:GetAutoConfig("convertshop_auto").multiple_cost_cfg
	for k, v in pairs(item_list) do
		if v.multiple_cost_id == multiple_cost_id and v.times_min <= convert_count and v.times_max >= convert_count then
			return v
		end
	end
	return nil
end

--根据类型获取配置
function ExchangeData:GetExchangeCfgByType(conver_type)
	local data = {}
	local item_list = ConfigManager.Instance:GetAutoConfig("convertshop_auto").convert_shop
	for k,v in pairs(item_list) do
		if v.conver_type == conver_type then
			table.insert(data,v)
		end
	end
	return data
end

--获取对应的兑换物品配置
function ExchangeData:GetConvertShopCfgList(conver_type, price_type, prof)
	if self.red_equip_convert_config[conver_type] and self.red_equip_convert_config[conver_type][price_type] then
		return self.red_equip_convert_config[conver_type][price_type][prof]
	end

	return nil
end

--获取对应阶数的装备兑换信息
function ExchangeData:GetExchangeEquipCfgListByOrder(conver_type, price_type, prof, order)
	order = order or 0
	order = tonumber(order)
	local list = {}

	--通用装备列表
	local common_equip_list = self:GetConvertShopCfgList(conver_type, price_type, 5)
	if common_equip_list then
		for _, v in ipairs(common_equip_list) do
			local item_cfg = ItemData.Instance:GetItemConfig(v.item_id)
			if item_cfg and item_cfg.order == order then
				table.insert(list, v)
			end
		end
	end

	local equip_list = self:GetConvertShopCfgList(conver_type, price_type, prof)
	if equip_list then
		for _, v in ipairs(equip_list) do
			local item_cfg = ItemData.Instance:GetItemConfig(v.item_id)
			if item_cfg and item_cfg.order == order then
				table.insert(list, v)
			end
		end
	end

	return list
end

--获取对应等级的阶数列表
function ExchangeData:GetOrderListByLevel(level)
	level = level or 0

	local order_str = ""
	for _, v in ipairs(self.equip_order_cfg) do
		order_str = v.order

		if level <= v.level then
			break
		end
	end
	return Split(order_str, ":")
end

function ExchangeData:GetXianShiNumByJobAndType(conver_type, price_type, job)
	local item_list = self:GetItemIdListByJobAndType(conver_type, price_type, job)
	local xianshi_num = 0
	for k, v in ipairs(item_list) do
		if v[2] == 1 then
			xianshi_num = xianshi_num + 1
		end
	end
	return xianshi_num
end

function ExchangeData:GetItemIdListByJobAndType(conver_type, price_type, job)
	local all_item_cfg = self:GetUsefulExchageCfg()
	local item_id_list = {}
	local has_jueban_count = 0
	for k,v in pairs(all_item_cfg) do
		if v.conver_type == conver_type and v.price_type == price_type and (v.show_limit == job or v.show_limit == 5) then
			local cfg = {v.item_id, v.is_jueban, v.need_stuff_id, v.need_stuff_count, v.seq}
			item_id_list[#item_id_list + 1] = cfg
			if v.is_jueban == 1 then
				has_jueban_count = has_jueban_count + 1
			end
		end
	end
	if conver_type == EXCHANGE_CONVER_TYPE.DAO_JU then --勾玉写死显示一个
		local gouyu = self:GetGouYuListByJobAndType(price_type, job)
		if gouyu then
			if #item_id_list > has_jueban_count + 1 then
				table.insert(item_id_list, has_jueban_count + 1, gouyu)
			else
				table.insert(item_id_list, gouyu)
			end
		end
	end

	local is_activity_open = ActivityData.Instance:GetActivityIsOpen(RA_OPEN_SERVER_ACTIVITY_TYPE.RAND_ACTIVITY_TYPE_RARE_CHANGE)
	if not is_activity_open then
		for i = #item_id_list, 1, -1 do
			local list = item_id_list[i]
			if list[2] == 1 then
				table.remove(item_id_list, i)
			end
		end
	end
	return item_id_list
end

--获取当前可兑换勾玉
function ExchangeData:GetGouYuListByJobAndType(price_type, job)
	local list = self:GetItemIdListByJobAndType(EXCHANGE_CONVER_TYPE.BUILD, price_type, job)
	local gouyu = nil
	for k,v in pairs(list) do
		local item_cfg = ItemData.Instance:GetItemConfig(v[1])
		if item_cfg and EquipData.IsGouYuEqType(item_cfg.sub_type) and self.gouyu_record[v[5]] ~= 1 then
			if gouyu == nil or gouyu[1] > v[1] then
				gouyu = v
			end
		end
	end
	return gouyu
end

function ExchangeData:IsExchangelimit(conver_type, seq)
	if conver_type == EXCHANGE_CONVER_TYPE.BUILD then
		return self.gouyu_record[seq] == 1
	end
	return false
end

function ExchangeData:GetItemListByJobAndIndex(conver_type, price_type, job, index)
	local item_id_list = self:GetItemIdListByJobAndType(conver_type, price_type, job)
	local job_id_list = {}
	if index == 1 then
		for i=1,8 do
			job_id_list[#job_id_list + 1] = item_id_list[i] or {0, 0}
		end
		return job_id_list
	end

	for i=1,8 do
		if item_id_list[(index - 1)*8 + i] == nil then
			item_id_list[(index - 1)*8 + i] = {0, 0}
		end
		job_id_list[#job_id_list + 1] = item_id_list[(index - 1)*8 + i]
	end
	return job_id_list
end

--获取物品被动消耗类配置
function ExchangeData:GetItemOtherCfg(item_id)
	return ConfigManager.Instance:GetAutoItemConfig("other_auto")[item_id]
end

function ExchangeData:GetScoreList()
	return self.score_list
end

function ExchangeData:GetCurrentScore(price_type)
	local current_score = 0
	if price_type == EXCHANGE_PRICE_TYPE.RONGYAO then
		current_score = PlayerData.Instance.role_vo.cross_honor or 0
	else
		current_score = self.score_list[price_type] or 0
	end
	return current_score
end

function ExchangeData:GetLackScoreTis(price_type)
	return Language.Exchange.NotRemin[price_type] or ""
end

function ExchangeData:GetExchangeRes(price_type)
	return RES_ENUM[price_type] or ""
end

function ExchangeData:GetMultilePrice(item_id, price_type)
	local item_info = self:GetExchangeCfg(item_id, price_type)
	local conver_value = self:GetConvertCount(item_info.seq, EXCHANGE_CONVER_TYPE.DAO_JU, price_type)
	local multiple_cfg = self:GetMultipleCostCfg(conver_value + 1, item_info.multiple_cost_id)
	local multiple_time = 1
	local price_multile = 0
	local price = 0
	if multiple_cfg then
		multiple_time = multiple_cfg.times_max - conver_value
		price_multile = multiple_cfg.price_multile
		price = item_info.price * (price_multile == 0 and 1 or price_multile)
	end
	return price
end

function ExchangeData:GetMultipleTime(item_id, price_type)
	local item_info = self:GetExchangeCfg(item_id, price_type)
	local conver_value = self:GetConvertCount(item_info.seq, EXCHANGE_CONVER_TYPE.DAO_JU, price_type)
	local multiple_cfg = self:GetMultipleCostCfg(conver_value + 1, item_info.multiple_cost_id)
	local multiple_time = 1

	if multiple_cfg then
		multiple_time = multiple_cfg.times_max - conver_value
	end

	return multiple_time
end

--是否强制显示特效
function ExchangeData:IsShowEffect(item_id)
	item_id = item_id or 0
	local flag = false
	if self.other_config then
		for k,v in pairs(self.other_config) do
			if v.item_special == item_id then
				flag = true
				break
			end
		end
	end
	return flag
end

--积分商城物品
function ExchangeData:GetItemListByConverType(conver_type)
	local cfg = ConfigManager.Instance:GetAutoConfig("convertshop_auto").convert_shop
	local list_cfg = {}

	for _, v in pairs(cfg) do
		if v.conver_type == conver_type then
			table.insert(list_cfg, v)
		end
	end

	return list_cfg
end

function ExchangeData:GetHunYinExchangeCfg()
	local hunyin_exchange_cfg = {}
	for k,v in pairs(self.convert_shop_config) do
		if 1 == v.conver_type then
			table.insert(hunyin_exchange_cfg, v)
		end
	end
	return hunyin_exchange_cfg
end

function ExchangeData:SetLingzhi(protocol)
	self.score_list[EXCHANGE_PRICE_TYPE.Blue_lingzhi] = self.score_list[EXCHANGE_PRICE_TYPE.Blue_lingzhi] + protocol.chest_shop_blue_lingzhi
	self.score_list[EXCHANGE_PRICE_TYPE.Purple_lingzhi] = self.score_list[EXCHANGE_PRICE_TYPE.Purple_lingzhi] + protocol.chest_shop_purple_lingzhi
	self.score_list[EXCHANGE_PRICE_TYPE.Orange_lingzhi] = self.score_list[EXCHANGE_PRICE_TYPE.Orange_lingzhi] + protocol.chest_shop_orange_lingzhi
end

function ExchangeData:GetAllLingzhi()
	local lingzhi_data = {}
	lingzhi_data["blue"] = 	self.score_list[EXCHANGE_PRICE_TYPE.Blue_lingzhi]
	lingzhi_data["purple"] = self.score_list[EXCHANGE_PRICE_TYPE.Purple_lingzhi]
	lingzhi_data["orange"] = self.score_list[EXCHANGE_PRICE_TYPE.Orange_lingzhi]
	return lingzhi_data
end

function ExchangeData:SetCurIndex(index)
	self.index = index
end

function ExchangeData:GetCurIndex()
	return self.index
end

function ExchangeData:RemindChangeCallBack()
	local main_role_id = GameVoManager.Instance:GetMainRoleVo().role_id
	local cur_day = TimeCtrl.Instance:GetCurOpenServerDay()
	if cur_day > 7 then
		return 0
	end
	local prof = GameVoManager.Instance:GetMainRoleVo().prof
	for k, v in ipairs(ExchangeView.SHOW_EXCHANGE_TAB) do
		local itemid_list = ExchangeData.Instance:GetItemIdListByJobAndType(2, v, prof)
		for _, v2 in ipairs(itemid_list) do
			if v2[2] == 1 and not self:GetClickState(k) then
				return 1
			end
		end
	end

	return 0
end