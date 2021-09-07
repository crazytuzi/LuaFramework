MagicCardData = MagicCardData or BaseClass()

MagicCardData.LotteryType = {
	PurpleCard = 0,
	OrangeCard = 1,
	RedCard = 2,
}
local SUIT_TYPE = 4

function MagicCardData:__init()
	if MagicCardData.Instance ~= nil then
		print_error("[MagicCardData] Attemp to create a singleton twice !")
	end
	MagicCardData.Instance = self
	self.cur_lotto_type = 0
	self.is_no_ani = false

	-- 服务器数据
	self.today_purple_free_chou_card_times = 0
	self.all_card_has_exchange_flag = 0
	self.all_card_num_list = {}
	self.card_slot_list = {}
	self.all_reward_index_list = {}

	-- 配置表数据
	self.card_cfg = ConfigManager.Instance:GetAutoConfig("magic_card_auto")
	self.other_cfg = self.card_cfg.other[1]
	self.info_cfg = self.card_cfg.card_info
	self.strength_cfg = self.card_cfg.strength
	self.suit_cfg = self.card_cfg.card_suit
	self.purple_chou_card = self.card_cfg.purple_chou_card
	self.orange_chou_card = self.card_cfg.orange_chou_card
	self.red_chou_card = self.card_cfg.red_chou_card
	self.duihuan_sort = self.card_cfg.duihuan_sort

	self.info_index_cfg = ListToMap(self.info_cfg, "card_id")
end

function MagicCardData:__delete()
	MagicCardData.Instance = nil
end

function MagicCardData:GetIsNoAni()
	return self.is_no_ani
end

function MagicCardData:SetIsNoAni(is_no_ani)
	self.is_no_ani = is_no_ani
end

function MagicCardData:SetMagicCardAllInfo(data)
	self.today_purple_free_chou_card_times = data.today_purple_free_chou_card_times
	self.all_card_has_exchange_flag = data.all_card_has_exchange_flag
	self.all_card_num_list = data.all_card_num_list
	self.card_slot_list = data.card_slot_list
	if self:GetCardCanActive() then
		MoLongData.Instance:SetMagicCardRedpt(true)
	else
		MoLongData.Instance:SetMagicCardRedpt(false)
	end
end

function MagicCardData:SetMagicCardChouCardResult(data)
	self.all_reward_index_list = data.all_reward_index_list
end

function MagicCardData:GetTodayLottoTimes()
	return self.today_purple_free_chou_card_times
end

-- 获得今日是否可以免费抽, true 为可以抽
function MagicCardData:GetTodayIsCanFreeLotto()
	return self.other_cfg.day_free_times > self.today_purple_free_chou_card_times
end

-- 获取相关配置  魔卡类型分为 0卡牌、1魔魂、2经验
-- 获取其他
function MagicCardData:GetOtherCfg()
	return self.other_cfg
end

-- 获取所有魔卡
function MagicCardData:GetInfoCfg()
	return self.info_cfg
end

function MagicCardData:GetMoHunNameByColor(color)
	local name = ""
	if color == 0 then
		name = Language.MagicCard.BlueSoul
	elseif color == 1 then
		name = Language.MagicCard.PurpleSoul
	elseif color == 2 then
		name = Language.MagicCard.OrangeSoul
	else
		name = Language.MagicCard.RedSoul
	end

	return name
end

-- 根据魔卡颜色获取RGB
function MagicCardData:GetRgbByColor(color)
	local cur_color = "#000000"
	if color == 0 then
		cur_color = "#00ffff"
	elseif color == 1 then
		cur_color = "#ff00fd"
	elseif color == 2 then
		cur_color = "#FF9600"
	else
		cur_color = "#ff0000"
	end

	return cur_color
end

-- 通过id获得魔卡信息
function MagicCardData:GetInfoById(card_id)
	return self.info_index_cfg[card_id] or nil
end

-- 获取所有卡牌
function MagicCardData:GetCardInfoCfg()
	if not self.card_info_cfg then
		self.card_info_cfg = ListToMapList(self.info_cfg, "type")
	end
	return self.card_info_cfg[0] or {}
end

-- 获取所有魔魂
function MagicCardData:GetMagicInfoCfg()
	if not self.card_info_cfg then
		self.card_info_cfg = ListToMapList(self.info_cfg, "type")
	end
	return self.card_info_cfg[1] or {}
end

-- 获取所有经验
function MagicCardData:GetExpInfoCfg()
	if not self.card_info_cfg then
		self.card_info_cfg = ListToMapList(self.info_cfg, "type")
	end
	return self.card_info_cfg[2] or {}
end

-- 根据颜色获取魔魂数量获取
function MagicCardData:GetMagicNumByColor(color)
	local num = 0
	for k, v in pairs(self:GetMagicInfoCfg()) do
		if v.color == color then
			num = self:GetCardNumById(v.card_id)
			return num
		end
	end

	return num
end

-- 获取当前总属性
function MagicCardData:GetAllInfo()
	local attr_list = {}
	attr_list.max_hp = 0
	attr_list.gong_ji = 0
	attr_list.fang_yu = 0
	attr_list.ming_zhong = 0
	attr_list.shan_bi = 0

	local card_info = {}
	attr_list = CommonStruct.Attribute()

	for k, v in pairs(self:GetCardInfoCfg()) do
		local card_level = self:GetCardInfoListByIndex(v.card_id).strength_level
		-- if card_level then
		if not card_level then
			card_level = 0
		end
		card_info = self:GetCardInfoByIdAndLevel(v.card_id,card_level)
		if card_level > 0 then
			attr_list.max_hp = attr_list.max_hp + card_info.maxhp
			attr_list.gong_ji = attr_list.gong_ji + card_info.gongji
			attr_list.fang_yu = attr_list.fang_yu + card_info.fangyu
			attr_list.ming_zhong = attr_list.ming_zhong + card_info.mingzhong
			attr_list.shan_bi = attr_list.shan_bi + card_info.shanbi
		end
	end

	local suit_info = {}
	for k, v in pairs(self.suit_cfg) do
		if self:GetCardSuitIsActive(v.color) then
			suit_info = self:GetCardTaoZByColor(v.color)
			attr_list.max_hp = attr_list.max_hp + suit_info.maxhp
			attr_list.gong_ji = attr_list.gong_ji + suit_info.gongji
			attr_list.fang_yu = attr_list.fang_yu + suit_info.fangyu
			attr_list.ming_zhong = attr_list.ming_zhong + suit_info.mingzhong
			attr_list.shan_bi = attr_list.shan_bi + suit_info.shanbi
		end
	end

	return attr_list
end

-- 获得卡牌对应的下标 下标从1开始
function MagicCardData:GetCardIndex(card_id)
	local card_info = {}
	local index = -1
	card_info = self:GetCardInfoCfg()
	for k, v in pairs(card_info) do
		if card_id == v.card_id then
			index = v.color * SUIT_TYPE + v.slot_index + 1
		end
	end

	return index
end

-- 通过等级和卡牌id获取卡牌属性
function MagicCardData:GetCardInfoByIdAndLevel(id,level)
	local card_info = {}
	if level < 1 then
		level = 1
	end
	if level > 0 then
		for k, v in pairs(self.strength_cfg) do
			if id == v.card_id and level == v.strength_level then
				table.insert(card_info,v)
			end
		end

		return card_info[1]
	else
		card_info.id = id
		card_info.strength_level=0
		card_info.up_level_need_exp=0
		card_info.contain_exp=0
		card_info.maxhp=0
		card_info.gongji=0
		card_info.fangyu=0
		card_info.mingzhong=0
		card_info.shanbi=0
		return card_info
	end
end

-- 通过卡牌颜色获取卡牌所属套装
function MagicCardData:GetCardTaoZByColor(color)
	local card_suit = {}
	for k, v in pairs(self.suit_cfg) do
		if color == v.color then
			table.insert(card_suit,v)
		end
	end

	return card_suit[1]
end

-- 获得抽奖卡牌信息
function MagicCardData:GetCardLottoInfo()
	local card_lotto_list = {}
	local index = 1

	for i=1,10 do
		for k,v in pairs(self.info_cfg) do
			if self.purple_chou_card[i].card_id == v.card_id then
				card_lotto_list[index] = {}
				table.insert(card_lotto_list[index], v)
				index = index + 1
			end
		end
	end

	for i=1,10 do
		for k,v in pairs(self.info_cfg) do
			if self.orange_chou_card[i].card_id == v.card_id then
				card_lotto_list[index] = {}
				table.insert(card_lotto_list[index], v)
				index = index + 1
			end
		end
	end

	for i=1,10 do
		for k,v in pairs(self.info_cfg) do
			if self.red_chou_card[i].card_id == v.card_id then
				card_lotto_list[index] = {}
				table.insert(card_lotto_list[index], v)
				index = index + 1
			end
		end
	end

	return card_lotto_list
end

function MagicCardData:GetCardPurpleLottoData()
	local card_lotto_list = {}
	local index = 1
	for k, v in pairs(self.purple_chou_card) do
		for i,j in pairs(self.info_cfg) do
			if j.card_id == v.card_id then
				card_lotto_list[index] = {}
				table.insert(card_lotto_list[index], j)
				index = index + 1
			end
		end
	end

	return card_lotto_list
end

function MagicCardData:GetCardOrangeLottoData()
	local card_lotto_list = {}
	local index = 1
	for k, v in pairs(self.orange_chou_card) do
		for i,j in pairs(self.info_cfg) do
			if j.card_id == v.card_id then
				card_lotto_list[index] = {}
				table.insert(card_lotto_list[index], j)
				index = index + 1
			end
		end
	end

	return card_lotto_list
end

function MagicCardData:GetCardRedLottoData()
	local card_lotto_list = {}
	local index = 1
	for k, v in pairs(self.red_chou_card) do
		for i,j in pairs(self.info_cfg) do
			if j.card_id == v.card_id then
				card_lotto_list[index] = {}
				table.insert(card_lotto_list[index], j)
				index = index + 1
			end
		end
	end

	return card_lotto_list
end

-- 获得兑换魔卡信息
function MagicCardData:GetCardExchangeInfo()
	local card_exchange_list = {}
	local index = 1
	for n,m in pairs(self.duihuan_sort) do
		for k,v in pairs(self.info_cfg) do
			if v.card_id == m.card_id then
				card_exchange_list[index] = {}
				table.insert(card_exchange_list[index], v)
				index = index + 1
				break
			end
		end
	end
	-- for k,v in pairs(self:GetExpInfoCfg()) do
	-- 	card_exchange_list[index] = {}
	-- 	table.insert(card_exchange_list[index], v)
	-- 	index = index + 1
	-- end

	-- for k,v in pairs(self:GetCardInfoCfg()) do
	-- 	card_exchange_list[index] = {}
	-- 	table.insert(card_exchange_list[index], v)
	-- 	index = index + 1
	-- end

	return card_exchange_list
end

-- 根据item_id获取card_id
function MagicCardData:GetCardIdByItemId(item_id)
	for k,v in pairs(self.info_cfg) do
		if v.item_id == item_id then
			return v.card_id
		end
	end
	return 0
end

-- 根据card_id获取经验值
function MagicCardData:GetCardExpById(card_id)
	for k,v in pairs(self.strength_cfg) do
		if v.card_id == card_id and v.strength_level == 1 then
			return v.contain_exp
		end
	end
	return 0
end

-- 获得奖品data
function MagicCardData:GetLottoData()
	local data_list = {}
	local data = {}
	local index = 1
	if self.cur_lotto_type == 0 then
		for k,v in ipairs(self.all_reward_index_list) do
			for i,j in pairs(self.purple_chou_card) do
				if v == j.reward_seq then
					table.insert(data_list,j)
				end
			end
		end
	elseif	self.cur_lotto_type == 1 then
		for k,v in ipairs(self.all_reward_index_list) do
			for i,j in pairs(self.orange_chou_card) do
				if v == j.reward_seq then
					table.insert(data_list,j)
				end
			end
		end
	else
		for k,v in ipairs(self.all_reward_index_list) do
			for i,j in pairs(self.red_chou_card) do
				if v == j.reward_seq then
					table.insert(data_list,j)
				end
			end
		end
	end

	for k,v in pairs(data_list) do
		for i,j in pairs(self.info_cfg) do
			if v.card_id == j.card_id then
				local temp_list = {}
				temp_list.num = v.reward_count
				temp_list.is_bind = 0
				temp_list.item_id = j.item_id
				temp_list.card_name = j.card_name
				table.insert(data,temp_list)
			end
		end
	end

	return data
end

-- 获得当前抽奖的类型
function MagicCardData:SetCurLottoType(lotto_type)
	self.cur_lotto_type = lotto_type
end

-- 获取服务器相关数据
-- 获取所有卡牌相关数据
function MagicCardData:GetCardInfoList()
	return self.card_slot_list
end

-- 根据卡牌id获取卡牌的相关数据 id   1开始
function MagicCardData:GetCardInfoListByIndex(id)
	local card_info = {}
	card_info.card_id = 0
	card_info.strength_level = 0
	card_info.exp = 0
	for k,v in pairs(self.card_slot_list) do
		if v.card_id == id then
			card_info = v
		end
	end

	return card_info
end

-- 通过卡牌id判断卡牌是否激活
function MagicCardData:GetCardIsActive(id)
	local card_info = self:GetCardInfoListByIndex(id)

	if card_info.card_id > 0 then
		return true
	else
		return false
	end
end

-- 获取所有未激活的卡牌
function MagicCardData:GetCardNoActive()
	local card_info = {}

	for k,v in pairs(self:GetCardInfoCfg()) do
		if not self:GetCardIsActive(v.card_id) then
			table.insert(card_info,v)
		end
	end

	return card_info
end

-- 判断当前是否有卡牌可以激活
function MagicCardData:GetCardCanActive()
	local card_info = self:GetCardNoActive()
	local bag_list = self:GetMCBagCard()

	for k,v in pairs(card_info) do
		for n,m in pairs(bag_list) do
			if m.card_id == v.card_id then
				return true
			end
		end
	end
	return false
end

-- 通过卡牌id判断当前卡牌是否可以激活
function MagicCardData:GetIsActiveById(card_id)
	local bag_list = self:GetMCBagCard()

	for k,v in pairs(bag_list) do
		if card_id == v.card_id and not self:GetCardIsActive(card_id) then
			return true
		end
	end

	return false
end

-- 通过卡牌套装color判断卡牌套装是否激活 0 start
function MagicCardData:GetCardSuitIsActive(color)
	 local card_list = {}
	 local suit_list = {}
	 card_list = self:GetCardInfoCfg()
	 for k, v in pairs(card_list) do
		if v.color == color then
			table.insert(suit_list, v)
		end
	end

	for k, v in pairs(suit_list) do
		local level = self:GetCardInfoListByIndex(v.card_id).strength_level
		-- if level then
		if not level then
			level = 0
		end
		if level < 4 then
			return false
		end
	 end

	return true
end

-- 通过id获取魔卡数量
function MagicCardData:GetCardNumById(id)
	local num = 0
	num = self.all_card_num_list[id]

	return num
end

-- 和获取当前背包魔卡数量
function MagicCardData:GetBagCardNum()
	local num = 0
	for k,v in pairs(self.info_cfg) do
		if v.type == 0 or v.type == 2 then
			num = num + self:GetCardNumById(v.card_id)
		end
	end

	return num
end

-- 获取当前背包卡牌
function MagicCardData:GetMCBagCard()
	local bag_card = {}
	for k,v in pairs(self.info_cfg) do
		if self.all_card_num_list[v.card_id] > 0 and v.type == 0 then
			table.insert(bag_card,v)
		end
	end

	return bag_card
end

-- 获取当前魔卡背包物品
function MagicCardData:GetMCBagData()
	local bag_data = {}
	for k,v in pairs(self.info_cfg) do
		if self.all_card_num_list[v.card_id] > 0 and v.type ~= 1 then
			for i=1,self.all_card_num_list[v.card_id] do
				table.insert(bag_data,v)
			end
		end
	end

	return bag_data
end

-- 根据颜色获取所有经验卡
function MagicCardData:GetExpCardByColor(color)
	local exp_list = {}
	for k,v in pairs(self:GetExpInfoCfg()) do
		if self.all_card_num_list[v.card_id] > 0 and v.color == color then
			exp_list.num = self.all_card_num_list[v.card_id]
			exp_list.card_id = v.card_id
		end
	end

	return exp_list
end
