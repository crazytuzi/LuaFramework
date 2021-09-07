SwordArtOnlineData = SwordArtOnlineData or BaseClass()

function SwordArtOnlineData:__init()
	if SwordArtOnlineData.Instance ~= nil then
		print_error("[SwordArtOnlineData] Attemp to create a singleton twice !")
	end
	SwordArtOnlineData.Instance = self

	-- 客户端数据
	self.cur_lotto_type = 0
	-- 服务器数据
	self.old_lingli = 0
	self.lingli = 0
	self.change_zuhe_id = 0
	self.change_zuhe_level = 0
	self.change_card_count = 0
	self.today_coin_buy_card_times = {}
	self.today_gold_bind_buy_card_times = {}
	self.all_card_count_list = {}
	self.all_zuhe_level_list = {}
	self.change_card_list = {}

	-- 配置表数据
	self.other = ConfigManager.Instance:GetAutoConfig("cardzu_config_auto").other
	self.cardzu_info = ConfigManager.Instance:GetAutoConfig("cardzu_config_auto").cardzu_info
	self.card_info = ConfigManager.Instance:GetAutoConfig("cardzu_config_auto").card_info
	self.zuhe_info = ConfigManager.Instance:GetAutoConfig("cardzu_config_auto").zuhe_info
	self.cardzu_upgrade = ConfigManager.Instance:GetAutoConfig("cardzu_config_auto").cardzu_upgrade
end

function SwordArtOnlineData:__delete()
	SwordArtOnlineData.Instance = nil
end

function SwordArtOnlineData:SetCardzuAllInfo(data)
	self.lingli = data.lingli
	self.today_coin_buy_card_times = data.today_coin_buy_card_times
	self.today_gold_bind_buy_card_times = data.today_gold_bind_buy_card_times
	self.all_card_count_list = data.all_card_count_list
	self.all_zuhe_level_list = data.all_zuhe_level_list
	self:ShowSwordRedPt()
end

function SwordArtOnlineData:SetOldLingli(old_lingli)
	self.old_lingli = old_lingli
end

function SwordArtOnlineData:GetOldLingli()
	return self.old_lingli
end

function SwordArtOnlineData:SetCardzuChangeNotify(data)
	self.lingli = data.lingli
	self.change_zuhe_id = data.change_zuhe_id
	self.change_zuhe_level = data.change_zuhe_level
	self.change_card_count = data.change_card_count
	self.today_coin_buy_card_times = data.today_coin_buy_card_times
	self.today_gold_bind_buy_card_times = data.today_gold_bind_buy_card_times
	self.change_card_list = data.change_card_list

	self.ten_card_list = {}
	for k,v in pairs(self.change_card_list) do
		local num = v.count - self.all_card_count_list[v.card_id]
		for i=1,num do
			table.insert(self.ten_card_list,v)
		end
	end

	for k,v in pairs(self.change_card_list) do
		self.all_card_count_list[v.card_id] = v.count
	end

	if self.change_zuhe_level > 0 then
		self.all_zuhe_level_list[self.change_zuhe_id] = self.change_zuhe_level
	end
	self:ShowSwordRedPt()
end

function SwordArtOnlineData:SetCardzuChouCardResult(data)
	self.all_card_count_list = data.all_card_count_list
end

-- 红点
function SwordArtOnlineData:ShowSwordRedPt()
    for j=1,4 do
        for i=1,7 do
            local level = self:GetZhLevelById(i - 1)
            if level == nil then
            	return
            end
            if level < 1 then
                level = 1
            end
            local right_data = self:GetCellDataByIdAndLevel(j - 1,i - 1,level,true)
            cur_zh_level = self:GetZhLevelById(right_data.zuhe_idx)
            local have_num_list = {}
            have_num_list[1] = self:GetSwordNumById(right_data.need_card1_id)
            have_num_list[2] = self:GetSwordNumById(right_data.need_card2_id)
            have_num_list[3] = self:GetSwordNumById(right_data.need_card3_id)

            if cur_zh_level <= 0 then
                if have_num_list[1] >= right_data.need_card1_num and have_num_list[2] >= right_data.need_card2_num and have_num_list[3] >= right_data.need_card3_num then
                   MoLongData.Instance:SetSwrodArtOnlineRedpt(true)
                   return
                end
            end
        end
    end
    MoLongData.Instance:SetSwrodArtOnlineRedpt(false)
end

-- 配置表数据
function SwordArtOnlineData:GetChouCardInfo()
	return self.other[1]
end

function SwordArtOnlineData:GetCardZuInfoById(id)
	local card_data = {}
	for k,v in pairs(self.cardzu_info) do
		if v.cardzu_id == id then
			table.insert(card_data,v)
		end
	end

	return card_data[1]
end

-- 根据卡组id和索引获取背包数据
function SwordArtOnlineData:GetBagInfoByIdAndIndex(cardzu_id,index)
	local card_data = {}
	local cur_index = cardzu_id * 18 + index - 1
	card_data = self.card_info[cur_index]
	-- for k,v in pairs(self.card_info) do
	-- 	if v.card_idx == cur_index then
	-- 		table.insert(card_data,v)
	-- 	end
	-- end

	return card_data
end

-- 通过卡组id合组合id获取组合的属性 id 0 start
function SwordArtOnlineData:GetZuHeDataByCardId(card_id,zuhe_id,is_index)
	local zuhe_data = {}
	local id = zuhe_id
	if is_index then
		id = card_id * 7 + zuhe_id
	end

	for k,v in pairs(self.zuhe_info) do
		if v.cardzu_id == card_id and v.zuhe_idx == id then
			table.insert(zuhe_data,v)
		end
	end

	return zuhe_data[1]
end

-- 通过卡组id和组合id和组合level获取卡组属性 id 0 start
function SwordArtOnlineData:GetZuHeInfoByIdAndLevel(cardzu_id,zuhe_id,level,is_index)
	local zuhe_data = {}
	local id = zuhe_id
	if is_index then
		id = cardzu_id * 7 + zuhe_id
	end

	if level == 0 then
		zuhe_data.zuhe_idx=id
		zuhe_data.zuhe_level=0
		zuhe_data.upgrade_need_lingli=0
		zuhe_data.maxhp=0
		zuhe_data.gongji=0
		zuhe_data.fangyu=0
		zuhe_data.mingzhong=0
		zuhe_data.shanbi=0
		zuhe_data.baoji=0
		zuhe_data.jianren=0
		return zuhe_data
	end

	for k,v in pairs(self.cardzu_upgrade) do
		if v.zuhe_idx == id and level == v.zuhe_level then
			table.insert(zuhe_data,v)
		end
	end

	return zuhe_data[1]
end

-- 通过剑id和星级获取剑属性 id 1 start level 1 start
function SwordArtOnlineData:GetSwordInfoById(id,level)
	local sword_data = {}
	for k,v in pairs(self.card_info) do
		if v.res_id == id and v.star_count == level then
			table.insert(sword_data,v)
		end
	end

	return sword_data[1]
end

-- 通过卡组id和组合id获取剑属性 id 0 start
function SwordArtOnlineData:GetSwordInfoByZhId(zuhe_id)
	local sword_data = {}
	sword_data = self.card_info[zuhe_id]
	-- for k,v in pairs(self.card_info) do
	-- 	if v.card_idx == zuhe_id then
	-- 		table.insert(sword_data,v)
	-- 	end
	-- end

	return sword_data
end

-- 通过卡组id和组合id和组合level获取右格子属性 id 0 start
function SwordArtOnlineData:GetCellDataByIdAndLevel(cardzu_id,zuhe_id,level,is_index)
	local cell_data = {}
	local zuhe_data = {}
	local zuhe_attr = {}
	zuhe_data = self:GetZuHeDataByCardId(cardzu_id,zuhe_id,is_index)
	zuhe_attr = self:GetZuHeInfoByIdAndLevel(cardzu_id,zuhe_id,level,is_index)

	table.insert(cell_data,zuhe_data)
	cell_data[1].max_hp = zuhe_attr.maxhp
	cell_data[1].gong_ji = zuhe_attr.gongji
	cell_data[1].fang_yu = zuhe_attr.fangyu
	cell_data[1].ming_zhong = zuhe_attr.mingzhong
	cell_data[1].shan_bi = zuhe_attr.shanbi
	cell_data[1].bao_ji = zuhe_attr.baoji
	cell_data[1].jian_ren = zuhe_attr.jianren
	cell_data[1].upgrade_need_lingli = zuhe_attr.upgrade_need_lingli
	cell_data[1].zuhe_level = zuhe_attr.zuhe_level

	return cell_data[1]
end

-- 获取卡组战斗力通过卡组id
function SwordArtOnlineData:GetFightById(cardzu_id)
	local attr = {}
	attr = CommonStruct.Attribute()
	local data = {}

	for k,v in pairs(self.zuhe_info) do
		if cardzu_id == v.cardzu_id then
			local level = self:GetZhLevelById(v.zuhe_idx)
			data = self:GetCellDataByIdAndLevel(cardzu_id,v.zuhe_idx,level)
			attr.max_hp = attr.max_hp + data.max_hp
			attr.gong_ji = attr.gong_ji + data.gong_ji
			attr.fang_yu = attr.fang_yu + data.fang_yu
			attr.ming_zhong = attr.ming_zhong + data.ming_zhong
			attr.shan_bi = attr.shan_bi + data.shan_bi
			attr.bao_ji = attr.bao_ji + data.bao_ji
			attr.jian_ren = attr.jian_ren + data.jian_ren
		end
	end

	local fight = CommonDataManager.GetCapabilityCalculation(attr)
	return fight
end

-- 通过剑id获取剑升级需要的data id 0 start
function SwordArtOnlineData:GetInfoBySwordId(index,sword_id)
	local data = {}
	if self.zuhe_info[index].need_card1_id == sword_id then
		data.need_num = self.zuhe_info[index].need_card1_num
		data.zuhe_idx = self.zuhe_info[index].zuhe_idx
	elseif self.zuhe_info[index].need_card2_id == sword_id then
		data.need_num = self.zuhe_info[index].need_card2_num
		data.zuhe_idx = self.zuhe_info[index].zuhe_idx
	elseif self.zuhe_info[index].need_card3_id == sword_id then
		data.need_num = self.zuhe_info[index].need_card3_num
		data.zuhe_idx = self.zuhe_info[index].zuhe_idx
	end

	return data
end

-- 发服务器数据
function SwordArtOnlineData:GetSwordNumById(id)
	local have_num = 0
	for i = 0, #self.all_card_count_list do
		if id == i and self.all_card_count_list[i] then
			have_num = self.all_card_count_list[i]
			break
		end
	end

	return have_num
end

-- 通过组合id获取等级
function SwordArtOnlineData:GetZhLevelById(id)
	local level = 0
	for i = 0, #self.all_zuhe_level_list do
		if id == i then
			level = self.all_zuhe_level_list[i]
			break
		end
	end

	return level
end

-- 判断当前卡牌是否可以一键化灵
function SwordArtOnlineData:GetCanIsHuaLing(cardzu_id,card_idx)
	local index = cardzu_id*7
	for i=index,6+index do
		local level = self:GetZhLevelById(self.zuhe_info[i].zuhe_idx)
		if level <= 0 then
			if card_idx == self.zuhe_info[i].need_card1_id or card_idx == self.zuhe_info[i].need_card2_id
				or card_idx == self.zuhe_info[i].need_card3_id then
				return false
			end
		end
	end

	return true
end

-- 判断该卡组是否已激活
function SwordArtOnlineData:CardZuActiveById(id,is_need_num)
	local is_active = false
	local num = 0
	local need_num = self:GetCardZuInfoById(id).need_active_count
	if id == 0 then
		return true
	elseif id == 1 then
		for i=0,6 do
			if self:GetZhLevelById(i) > 0 then
				num = num + 1
			end
		end
		if num >= need_num then
			is_active = true
		end
	elseif id == 2 then
		for i=7,13 do
			if self:GetZhLevelById(i) > 0 then
				num = num + 1
			end
		end
		if num >= need_num then
			is_active = true
		end
	elseif id == 3 then
		for i=14,20 do
			if self:GetZhLevelById(i) > 0 then
				num = num + 1
			end
		end
		if num >= need_num then
			is_active = true
		end
	end

	if is_need_num then
		return num
	else
		return is_active
	end
end

-- 获取所有激活的卡组的数量
function SwordArtOnlineData:GetCzActiveNum()
	local num = 0

	for k,v in pairs(self.zuhe_info) do
		if self:GetZhLevelById(v.zuhe_idx) > 0 then
			num = num + 1
		end
	end

	return num
end

--获得灵力
function SwordArtOnlineData:GetLingLi()
	return self.lingli
end

-- 获得单次抽奖的数据
function SwordArtOnlineData:GetSwordNameByOneReceive()
	local data = {}
	for k,v in pairs(self.change_card_list) do
		data = self.card_info[v.card_id]
	end

	return data
end

-- 获得十次抽奖的数据
function SwordArtOnlineData:GetSwordNameByTenReceive(index)
	local data = {}
	for k,v in pairs(self.ten_card_list) do
		for n,m in pairs(self.card_info) do
			if v.card_id == m.card_idx then
				table.insert(data,m)
			end
		end
	end

	return data[index]
end

-- 获得当前抽奖的类型
function SwordArtOnlineData:SetCurBuyLottoType(lotto_type)
	self.cur_lotto_type = lotto_type
end

-- 获得抽奖奖品data
function SwordArtOnlineData:GetBuyLottoData()
	local data_list = {}
	if self.cur_lotto_type == 0 then
		table.insert(data_list,self:GetSwordNameByOneReceive(i))
	elseif self.cur_lotto_type == 1 then
		for i=1,10 do
			table.insert(data_list,self:GetSwordNameByTenReceive(i))
		end
	end

	return data_list
end

-- 获取当前卡组绑钻购买次数
function SwordArtOnlineData:GetCurCardZuBuyTimesById(id)
	return self.today_gold_bind_buy_card_times[id]
end