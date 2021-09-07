ExchangeData = ExchangeData or BaseClass()

EXCHANGE_CONVER_TYPE =
{
	DAO_JU = 2,
	XUN_BAO = 3,
	JING_LING = 5,
	HAPP_YTREE = 6,
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
	FATE = 8,				-- 气运         跟配置表根本对不上，怕改出问题将就着写吧
	DAILYSCORE = 9,			-- 积分
	LIUJIESCORE = 10,		-- 跨服	
	GOLD_INGOT = 11,		-- 金锭 
	-- Blue_lingzhi = 11,		-- 魂印積分
	Purple_lingzhi = 12,
	Orange_lingzhi = 13,

	-- RONGYAO = 8,			-- 不知道谁乱加的类型，和服务器都对不上的，但不好删除免得出BUG
}

REQUIRE_TYPE = {
	LEVEL = 1,
}

ExchangeData.EXCHANGE_COL_ITEM = 4

local RES_ENUM = {
	[1] = "ShengWang",
	[2] = "RongYu",
	[3] = "RongYao",
	[5] = "XunBao",
	[7] = "HunaLeShu",
	[8] = "RongYao",
	[9] = "QiYun",
	[10] = "JiFen",
	[11] = "DuiFen",
	[12] = "GoldIngot"
}

EQUIPMENTS_PER_SUIT = 8

function ExchangeData:__init()
	if ExchangeData.Instance then
		print_error("[ExchangeData] Attemp to create a singleton twice !")
	end
	ExchangeData.Instance = self
	self.convert_record_info = {}
	self.lifetime_record_list = {}
	self.score_list = {}
	self.other_config = ConfigManager.Instance:GetAutoConfig("convertshop_auto").other

	self.exchange_price_type = ListToMapList(self:GetAllExchangeCfg(), "price_type","item_id")
	self.exchange_conver_type = ListToMapList(self:GetAllExchangeCfg(), "conver_type")
	self.convert_shop_config = ConfigManager.Instance:GetAutoConfig("convertshop_auto").convert_shop
	self.multiple_cost_id = ListToMapList(ConfigManager.Instance:GetAutoConfig("convertshop_auto").multiple_cost_cfg, "multiple_cost_id")

end

function ExchangeData:__delete()
	if ExchangeData.Instance then
		ExchangeData.Instance = nil
	end 
	self.convert_record_info = {}
	self.score_list = {}
	UnityEngine.PlayerPrefs.DeleteKey("exchange_prop")
end

function ExchangeData:OnConvertRecordInfo(protocol)
	self.convert_record_info = protocol.convert_record
	self.lifetime_record_list = protocol.lifetime_record_list
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

-- 重写上面方法，用seq获取当前Item的兑换次数
function ExchangeData:GetCurConvertCount(seq,convert_type) 
	for k,v in pairs(self.convert_record_info) do
		if v.reserve == seq and v.convert_type == convert_type then
			return v.convert_count
		end
	end
	return 0
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


function ExchangeData:OnScoreInfo(protocol)
	self.score_list[EXCHANGE_PRICE_TYPE.MOJING] = protocol.chest_shop_mojing
	self.score_list[EXCHANGE_PRICE_TYPE.SHENGWANG] = protocol.chest_shop_shengwang
	self.score_list[EXCHANGE_PRICE_TYPE.GONGXUN] = protocol.chest_shop_gongxun
	self.score_list[EXCHANGE_PRICE_TYPE.WEI_WANG] = protocol.chest_shop_weiwang
	self.score_list[EXCHANGE_PRICE_TYPE.TREASURE] = protocol.chest_shop_treasure_credit
	self.score_list[EXCHANGE_PRICE_TYPE.JINGLING] = protocol.chest_shop_jingling_credit
	self.score_list[EXCHANGE_PRICE_TYPE.HAPPYTREE] = protocol.chest_shop_happytree_grow
	self.score_list[EXCHANGE_PRICE_TYPE.FATE] = protocol.chest_shop_guojiaqiyun
	self.score_list[EXCHANGE_PRICE_TYPE.DAILYSCORE] = protocol.chest_shop_dailyscore

	-- self.score_list[EXCHANGE_PRICE_TYPE.Blue_lingzhi] = protocol.chest_shop_blue_lingzhi
	self.score_list[EXCHANGE_PRICE_TYPE.Purple_lingzhi] = protocol.chest_shop_purple_lingzhi
	self.score_list[EXCHANGE_PRICE_TYPE.Orange_lingzhi] = protocol.chest_shop_orange_lingzhi
	self.score_list[EXCHANGE_PRICE_TYPE.LIUJIESCORE] = protocol.chest_shop_cross_guildbattle_score
	self.score_list[EXCHANGE_PRICE_TYPE.GOLD_INGOT] = protocol.chest_shop_server_gold
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

	local rebirth_lv = RebirthData.Instance:GetRebirthLevel() -- 金锭界面根据转生等级显示装备
	local suit_grade = self:GetTransmigrationSuitGrade(rebirth_lv) 
	for i = #useful_cfg, 1, -1 do
		if useful_cfg[i].price_type == 12 and (useful_cfg[i].seq ~= 0 and useful_cfg[i].seq ~= 1) then
			if suit_grade < 1 then
				table.remove(useful_cfg, i)
			elseif not (useful_cfg[i].seq >= 2 + (suit_grade - 1) * EQUIPMENTS_PER_SUIT and useful_cfg[i].seq <= 9 + (suit_grade - 1) * EQUIPMENTS_PER_SUIT) then
				table.remove(useful_cfg, i)
			end
		end
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
	local p_cfg = self.exchange_price_type[price_type] 
	if p_cfg and p_cfg[item_id] then
		return p_cfg[item_id][1]
	end
end

-- 获取兑换翻倍配置
function ExchangeData:GetMultipleCostCfg(convert_count, multiple_cost_id)
	if not convert_count or not multiple_cost_id then return end
	if 0 == multiple_cost_id then return end
	local result_cfg = self.multiple_cost_id[multiple_cost_id]
	if result_cfg then
		for k, v in pairs(result_cfg) do
			if v.times_min <= convert_count and v.times_max >= convert_count then
				return v
			end
		end
	end
	return nil
end

--根据类型获取配置
function ExchangeData:GetExchangeCfgByType(conver_type)
	local data = {}
	for k,v in pairs(self.exchange_conver_type[conver_type]) do
		table.insert(data,v)
	end
	return data
end

function ExchangeData:GetItemIdListByJobAndType(conver_type, price_type, job)
	local all_item_cfg = self:GetUsefulExchageCfg()
	local item_id_list = {}
	for k,v in pairs(all_item_cfg) do
		if v.conver_type == conver_type
			and v.price_type == price_type
			and (v.show_limit == job or v.show_limit == 5) then
			item_id_list[#item_id_list + 1] = v.item_id
		end
	end
	return item_id_list
end

function ExchangeData:GetAllLingzhi()
	local lingzhi_data = {}
	lingzhi_data["blue"] = 	self.score_list[EXCHANGE_PRICE_TYPE.Blue_lingzhi]
	-- lingzhi_data["purple"] = self.score_list[EXCHANGE_PRICE_TYPE.Purple_lingzhi]
	lingzhi_data["orange"] = self.score_list[EXCHANGE_PRICE_TYPE.Orange_lingzhi]
	return lingzhi_data
end

function ExchangeData:GetItemListByJobAndIndex(conver_type, price_type,job,index)
	local all_item_cfg = self:GetUsefulExchageCfg()
	local item_id_list = {}
	local item_seq_list = {}

	for k,v in pairs(all_item_cfg) do
		if v.conver_type == conver_type
			and v.price_type == price_type
			and v.conver_type == conver_type
			and (v.show_limit == job or v.show_limit == 5) then

			item_id_list[#item_id_list + 1] = v.item_id
			item_seq_list[#item_seq_list + 1] = v.seq
		end
	end

	local job_id_list = {}
	local job_seq_list = {}
	if index == 1 then
		for i = 1, 4 do
			job_id_list[#job_id_list + 1] = item_id_list[i] or 0
			job_seq_list[#job_seq_list + 1] = item_seq_list[i]
		end
		return job_id_list, job_seq_list
	end

	for i = 1, 4 do
		if item_id_list[(index - 1)*4 + i] == nil then
			item_id_list[(index - 1)*4 + i] = 0
		end
		job_id_list[#job_id_list + 1] = item_id_list[(index - 1)*4 + i]
		job_seq_list[#job_seq_list + 1] = item_seq_list[(index - 1)*4 + i]
	end

	return job_id_list, job_seq_list
end

--获取物品被动消耗类配置
function ExchangeData:GetItemOtherCfg(item_id)
	return ConfigManager.Instance:GetAutoItemConfig("other_auto")[item_id]
end

function ExchangeData:GetScoreList()
	return self.score_list
end

function ExchangeData:GetScoreByScoreType(score_type)
	return self.score_list[score_type] or 0
end

function ExchangeData:GetCurrentScore(price_type)
	local current_score = 0
	--if price_type == EXCHANGE_PRICE_TYPE.RONGYAO then
		--current_score = PlayerData.Instance.role_vo.cross_honor or 0
	--else
		current_score = ExchangeData.Instance:GetScoreByScoreType(price_type) or 0
	--end
	return current_score
end

function ExchangeData:GetLackScoreTis(price_type)
	return Language.Exchange.NotRemin[price_type] or ""
end

function ExchangeData:GetExchangeRes(price_type)
	return RES_ENUM[price_type] or ""
end

function ExchangeData:GetMultilePrice(item_id, price_type)
	local item_info = ExchangeData.Instance:GetExchangeCfg(item_id, price_type)
	local conver_value = ExchangeData.Instance:GetConvertCount(item_id, EXCHANGE_CONVER_TYPE.DAO_JU, price_type)
	local multiple_cfg = ExchangeData.Instance:GetMultipleCostCfg(conver_value + 1, item_info.multiple_cost_id)
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

-- 获取转生等级对应套装
function ExchangeData:GetTransmigrationSuitGrade(lv)
	local zhuansheng_cfg = ConfigManager.Instance:GetAutoConfig("new_zhuansheng_cfg_auto")	
	local suit_grade = 0
	if zhuansheng_cfg and lv then
		local suit_grade_cfg = zhuansheng_cfg.suit_grade_cfg
		for k,v in pairs(suit_grade_cfg) do
			if lv >= v.activate_need_level then
				suit_grade = v.suit_grade
			end
		end
	end
	return suit_grade
end

