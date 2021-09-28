IllustratedHandbookData = IllustratedHandbookData or BaseClass(BaseEvent)

function IllustratedHandbookData:__init()
	if IllustratedHandbookData.Instance then
		print_error("[IllustratedHandbookData] Attempt to create singleton twice!")
		return
	end
	IllustratedHandbookData.Instance = self

	self.all_boss_card_list = {}
	self.click_index = -1

	self.cfg = ConfigManager.Instance:GetAutoConfig("boss_handbook_cfg_auto")

	self.show_cfg = self.cfg.show_cfg or {}
	self.card_cfg_list = self.cfg.card_cfg or {}
	self.page_cfg_list = self.cfg.page_cfg or {}

	self.card_cfg = ListToMapList(self.card_cfg_list, "card_idx")
	self.page_cfg = ListToMap(self.page_cfg_list, "page_idx")

	RemindManager.Instance:Register(RemindName.BossHandBook, BindTool.Bind(self.GetCardActiveRemind, self))
end

function IllustratedHandbookData:__delete()
	IllustratedHandbookData.Instance = nil
	RemindManager.Instance:UnRegister(RemindName.BossHandBook)
end

function IllustratedHandbookData:SetAllCardInfo(protocol)
	if protocol == nil then return end

	self.all_boss_card_list = protocol.handbook_level_list or {}
end

function IllustratedHandbookData:SetSingleCardInfo(protocol)
	if protocol == nil then return end

	local card_idx = protocol.card_idx or -1
	local level = protocol.level or -1
	if self.all_boss_card_list and self.all_boss_card_list[card_idx] then
		self.all_boss_card_list[card_idx] = level
	end
end

function IllustratedHandbookData:GetCardDataList()
	local max_chapter = self:GetMaxChapter()
	local num = GameEnum.BOSS_HANDBOOK_SLOT_PER_CARD
	local max_index = (max_chapter + 1) * num - 1
	local list = {}
	for i,v in ipairs(self.show_cfg) do
		if v.card_id <= max_index then
			table.insert(list, v)
		end
	end
	return list
end

--获取最大章节
function IllustratedHandbookData:GetMaxChapter()
	return #self.page_cfg or 0
end

--获取章的配置
function IllustratedHandbookData:GetCardChapterCfg(chapter)
	local chapter = chapter or 0
	return self.page_cfg[chapter]
end

--获取单个图鉴最大等级
function IllustratedHandbookData:GetCurCardMaxLevel(card_idx)
	local max_level = 0
	if nil == self.card_cfg or nil == self.card_cfg[card_idx] then
		return max_level 
	end

	local cfg = self.card_cfg[card_idx]
	max_level = cfg[#cfg] and cfg[#cfg].level or 0
	return max_level
end

--获取单个图鉴等级
function IllustratedHandbookData:GetCurCardlevel(card_idx)
	local level = 0
	if self.all_boss_card_list and self.all_boss_card_list[card_idx] then
		level = self.all_boss_card_list[card_idx] or 0
	end
	return level
end

--获取单个图鉴配置
function IllustratedHandbookData:GetSingleCardCfg(card_id)
	local cfg = {}
	if nil == self.card_cfg or nil == self.card_cfg[card_id] then
		return cfg
	end

	local level = self:GetCurCardlevel(card_id)
	cfg = self.card_cfg[card_id][level + 1] or {}
	return cfg
end

--获取背包中的数量
function IllustratedHandbookData:GetBagCardInfo(item_id)
	local num = 0
	num = ItemData.Instance:GetItemNumInBagById(item_id)
	return num
end

function IllustratedHandbookData:IsCanUpLevel(card_id)
	local can_level = false
	local level = self:GetCurCardlevel(card_id)

	if nil == self.card_cfg or nil == self.card_cfg[card_id] or nil == self.card_cfg[card_id][level + 1] then 
		return can_level
	end

	local cfg = self.card_cfg[card_id][level + 1]
	local has_card_num = 0
	for i = 0, GameEnum.BOSS_HANDBOOK_SLOT_PER_CARD - 1 do
		local item_id = cfg["stuff_id_" .. i]
		local need_num = cfg["stuff_num_" .. i]
		local bag_num = self:GetBagCardInfo(item_id)
		if bag_num >= need_num then
			has_card_num = has_card_num + 1
		end
	end

	can_level = has_card_num >= GameEnum.BOSS_HANDBOOK_SLOT_PER_CARD
	return can_level
end

function IllustratedHandbookData:IsCardMaxLevel(card_id)
	local max_level = self:GetCurCardMaxLevel(card_id)
	local cur_level = self:GetCurCardlevel(card_id)

	return max_level > 0 and cur_level >= max_level
end

function IllustratedHandbookData:GetCardActiveRemind()
	local remind = 0

	local data_list = self:GetCardDataList()
	for k,v in pairs(data_list) do
		local card_idx = k - 1
		local is_can_up_level = self:IsCanUpLevel(card_idx)
		local is_max_level = self:IsCardMaxLevel(card_idx)
		if is_can_up_level and not is_max_level then
			remind = 1
			break
		end
	end
	return remind
end

--获取单个图鉴需要的item_id
function IllustratedHandbookData:GetCurLevelNeedItemList(card_idx)
	local cfg = self:GetSingleCardCfg(card_idx)
	local need_item_list = {}
	if nil == next(cfg) then
		return need_item_list
	end

	for i = 0, GameEnum.BOSS_HANDBOOK_SLOT_PER_CARD - 1 do
		local item_id = cfg["stuff_id_" .. i] or 0
		table.insert(need_item_list, item_id)
	end
	return need_item_list
end

function IllustratedHandbookData:IsNeedItemByCardIndex(card_idx, item_id)
	local is_need = false
	local solt = -1
	local list = self:GetCurLevelNeedItemList(card_idx)

	for k,v in pairs(list) do
		if v == item_id then
			is_need = true
			solt = k - 1
			break
		end
	end
	return is_need, solt
end

function IllustratedHandbookData:IsNeedItem(item_id)
	local data_list = self:GetCardDataList()
	local is_need_item = false
	local need_solt = -1
	for k,v in pairs(data_list) do
		local card_idx = k - 1
		local item_id = item_id
		local is_need, solt = self:IsNeedItemByCardIndex(card_idx, item_id)
		if is_need then
			is_need_item = true
			need_solt = solt
			break
		end
	end

	return is_need_item, need_solt
end
