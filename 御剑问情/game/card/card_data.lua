CardData = CardData or BaseClass(BaseEvent)

CardData.CARD_MAX_COUNT = 32  		--一共多少张卡牌
CardData.SLOT_PER_CARD = 4   		-- 每张卡牌的四个部分

function CardData:__init()
	if CardData.Instance then
		print_error("[CardData] Attempt to create singleton twice!")
		return
	end
	CardData.Instance = self
	self.card_level = 0
	self.card_exp = 0
	self.card_color_list = {}
	for i = 0, CardData.CARD_MAX_COUNT - 1 do
		self.card_color_list[i] = {}
		for i1 = 0, CardData.SLOT_PER_CARD - 1 do
			self.card_color_list[i][i1] = 0
		end
	end
	self.card_cfg = ListToMap(ConfigManager.Instance:GetAutoConfig("cardcfg_auto").card_cfg, "card_idx", "slot_idx", "target_color")
	self.show_cfg = ConfigManager.Instance:GetAutoConfig("cardcfg_auto").show_cfg
	self.page_cfg = ListToMap(ConfigManager.Instance:GetAutoConfig("cardcfg_auto").page_cfg, "page_idx")
	self.card_level_cfg = ListToMap(ConfigManager.Instance:GetAutoConfig("cardcfg_auto").card_level_cfg, "card_level")
	self.card_item_cfg = {}
	for k,v in pairs(ConfigManager.Instance:GetAutoConfig("cardcfg_auto").card_cfg) do
		self.card_item_cfg[v.prof1_stuff_id] = v
		self.card_item_cfg[v.prof2_stuff_id] = v
		self.card_item_cfg[v.prof3_stuff_id] = v
		self.card_item_cfg[v.prof4_stuff_id] = v
	end
	self.card_item_list = nil
	RemindManager.Instance:Register(RemindName.CardActive, BindTool.Bind(self.GetCardActiveRemind, self))
	RemindManager.Instance:Register(RemindName.CardRecyle, BindTool.Bind(self.GetCardRecyleRemind, self))
end

function CardData:__delete()
	CardData.Instance = nil
	RemindManager.Instance:UnRegister(RemindName.CardActive)
    RemindManager.Instance:UnRegister(RemindName.CardRecyle)
end

function CardData:ClearCacheCardItemList()
	self.card_item_list = nil
end

--获取背包中的卡牌碎片列表
function CardData:GetAllCardList()
	if self.card_item_list then
		return self.card_item_list
	end
	self.card_item_list = {}
	local bag_list = ItemData.Instance:GetBagItemDataList()
	for k, v in pairs(bag_list) do
		if self:IsCardPiece(v.item_id) then
			table.insert(self.card_item_list, v)
		end
	end
	return self.card_item_list
end

function CardData:GetCardLevel()
	return self.card_level
end

function CardData:GetCardExp()
	return self.card_exp
end

function CardData:GetMaxCanEquipCard(index, slot, color)
	local item = nil
	local prof = PlayerData.Instance:GetRoleBaseProf()
	for k,v in pairs(self:GetAllCardList()) do
		local cfg = self.card_item_cfg[v.item_id]
		if cfg["prof" .. prof .. "_stuff_id"] == v.item_id and cfg.card_idx == index
			and cfg.slot_idx == slot and cfg.target_color > color then
			color = cfg.target_color
			item = v
		end
	end
	return item
end

function CardData:SetAllInfo(info)
	self.card_level = info.card_level
	self.card_exp = info.card_exp
	self.card_color_list = info.card_color_list
	self.max_chapter = nil
end

function CardData:SetExpInfo(info)
	self.card_level = info.card_level
	self.card_exp = info.card_exp
	self.max_chapter = nil
end

function CardData:SetCardItem(card_idx, slot_idx, item_id)
	self.card_color_list[card_idx] = self.card_color_list[card_idx] or {}
	self.card_color_list[card_idx][slot_idx] = item_id
end

function CardData:GetCardItem(item_id)
	local cfg = self.card_item_cfg[item_id]
	if self.card_color_list[cfg.card_idx] then
		return self.card_color_list[cfg.card_idx][cfg.slot_idx] or 0
	end
	return 0
end

--获取某卡牌碎片颜色
function CardData:GetCardPieceColor(card_idx, slot_idx)
	if self.card_color_list[card_idx] == nil then return 0 end
	local item_id = self.card_color_list[card_idx][slot_idx] or 0
	local color = self:GetCardColor(item_id)
	return color, item_id
end

--获取卡牌碎片颜色
function CardData:GetCardColor(item_id)
	local cfg = self.card_item_cfg[item_id]
	if cfg then
		return cfg.target_color
	end
	return 0
end

--获取卡牌碎片部位
function CardData:GetCardSlot(item_id)
	local cfg = self.card_item_cfg[item_id]
	if cfg then
		return cfg.slot_idx
	end
	return -1
end

--获取章的配置
function CardData:GetCardChapterCfg(chapter)
	return self.page_cfg[chapter]
end

function CardData:GetMaxOpenChapter()
	if self.max_chapter then
		return self.max_chapter
	end
	self.max_chapter = 0
	for k,v in pairs(self.page_cfg) do
		if self.card_level >= v.card_level and v.page_idx > self.max_chapter then
			self.max_chapter = v.page_idx
		end
	end
	return self.max_chapter
end

function CardData:GetItemFromChapter(item_id)
	local cfg = self.card_item_cfg[item_id]
	if cfg then
		return math.ceil((cfg.card_idx + 1) / 4) - 1
	end
	return 0
end

function CardData:GetCardDataList()
	local max_chapter = self:GetMaxOpenChapter()
	local max_index = (max_chapter + 1) * 4 - 1
	local list = {}
	for i,v in ipairs(self.show_cfg) do
		if v.card_idx <= max_index then
			table.insert(list, v)
		end
	end
	return list
end

--是否卡牌碎片
function CardData:GetCardCfg(card_idx, slot_idx, color)
	if self.card_cfg[card_idx] and self.card_cfg[card_idx][slot_idx] then
		return self.card_cfg[card_idx][slot_idx][color]
	end
	return nil
end

--是否卡牌碎片
function CardData:IsMaxCardLevel()
	return self.card_level_cfg[self.card_level + 1] == nil
end

--是否卡牌碎片
function CardData:GetCardLevelCfg(card_level)
	return self.card_level_cfg[card_level]
end

--是否更好的卡牌碎片
function CardData:IsBetterCardPiece(item_id)
	local cfg = self.card_item_cfg[item_id]
	if nil == cfg then return false, false, false end
	local cur_color = self:GetCardPieceColor(cfg.card_idx, cfg.slot_idx)
	local prof = PlayerData.Instance:GetRoleBaseProf()
	local chapter = math.ceil((cfg.card_idx + 1) / 4) - 1
	if cfg["prof" .. prof .. "_stuff_id"] == item_id and cfg.target_color > cur_color then
		return true, chapter <= self:GetMaxOpenChapter(), false
	elseif cfg["prof" .. prof .. "_stuff_id"] == item_id and cfg.target_color < cur_color then
		return false, chapter <= self:GetMaxOpenChapter(), true
	end

	return false, chapter <= self:GetMaxOpenChapter(), false
end

--是否卡牌碎片
function CardData:IsCardPiece(item_id)
	return self.card_item_cfg[item_id] ~= nil
end

--是否卡牌碎片
function CardData:GetCardPieceCfg(item_id)
	return self.card_item_cfg[item_id]
end

function CardData:GetCardActiveRemind()
	for k,v in pairs(self:GetAllCardList()) do
		local item_cfg = ItemData.Instance:GetItemConfig(v.item_id)
		local is_better, is_open = self:IsBetterCardPiece(v.item_id)
		if item_cfg and is_better and is_open then
			return 1
		end
	end
	return 0
end

function CardData:GetCardRecyleRemind()
	if DelayTimeRemindList[RemindName.CardRecyle] > 0 then
		return 0
	end
	for k,v in pairs(self:GetAllCardList()) do
		local item_cfg = ItemData.Instance:GetItemConfig(v.item_id)
		local is_better, is_open = self:IsBetterCardPiece(v.item_id)
		if is_better and not is_open then
			local color = self:GetCardColor(v.item_id)
			is_better = color > 2
		end
		if item_cfg and not is_better and not self:IsMaxCardLevel() then
			return 1
		end
	end
	return 0
end