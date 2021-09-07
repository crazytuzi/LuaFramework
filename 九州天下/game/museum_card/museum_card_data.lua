MuseumCardData = MuseumCardData or BaseClass()

MuseumCardData.CardState = {
	CARD_STATE_CAN_UNLOCK = 0,			-- 可激活
  	CARD_STATE_UNLOCKED = 1,			-- 已激活
 	CARD_STATE_UPGRADABLE = 2,			-- 可升星
}

MuseumCardData.CardQuality = {
	YELLOW = 0,							-- 黄
	BLUE = 1,							-- 蓝
	GOLD = 2,							-- 金
	PURPLE = 3,							-- 紫
}

function MuseumCardData:__init()
	if MuseumCardData.Instance ~= nil then
		print_error("[MuseumCardData] Attemp to create a singleton twice !")
		return
	end
	MuseumCardData.Instance = self

	self.card_info_list = {}
	self.suit_info_list = {}
end

function MuseumCardData:__delete()
	MuseumCardData.Instance = nil
end

function MuseumCardData:GetBoWuZhiCfg()
	return ConfigManager.Instance:GetAutoConfig("bowuzhi_cfg_auto") or {}
end

function MuseumCardData:GetFileCfgById(file_id)
	local cfg = self:GetBoWuZhiCfg()
	if nil == self.file_id_cfg then
		self.file_id_cfg = ListToMapList(cfg.chapter_config, "file_id")
	end
	return self.file_id_cfg[file_id] or {}
end

function MuseumCardData:GetFileCfgByIdAndChap(file_id, chapter_id)
	local cfg = self:GetBoWuZhiCfg()
	if nil == self.file_id_chap_cfg then
		self.file_id_chap_cfg = ListToMap(cfg.chapter_config, "file_id", "chapter_id")
	end
	return self.file_id_chap_cfg[file_id][chapter_id] or {}
end

function MuseumCardData:GetCardCfgByFileAndChap(file_id, chapter_id)
	local cfg = self:GetBoWuZhiCfg()
	if nil == self.card_file_chap_cfg then
		self.card_file_chap_cfg = ListToMapList(cfg.card_config, "file_id", "chapter_id")
	end
	return self.card_file_chap_cfg[file_id][chapter_id] or {}
end

function MuseumCardData:GetCardCfgById(card_id)
	local cfg = self:GetBoWuZhiCfg()
	if nil == self.card_id_cfg then
		self.card_id_cfg = ListToMap(cfg.card_config, "card_seq")
	end
	return self.card_id_cfg[card_id]or {}
end

function MuseumCardData:GetCardUpStarCfgByQualAndLv(quality, level)
	local cfg = self:GetBoWuZhiCfg()
	if nil == self.card_upstar_cfg then
		self.card_upstar_cfg = ListToMap(cfg.upgrade_config, "quality", "level")
	end
	return self.card_upstar_cfg[quality][level] or {}
end

function MuseumCardData:GetCardSuitCfg()
	local cfg = self:GetBoWuZhiCfg()
	
	return cfg.suit_config or {}
end

function MuseumCardData:GetCardSuitCfgById(suit_seq)
	local cfg = self:GetBoWuZhiCfg()
	if nil == self.card_suit_id_cfg then
		self.card_suit_id_cfg = ListToMapList(cfg.suit_config, "suit_seq")
	end
	return self.card_suit_id_cfg[suit_seq] or {}
end

function MuseumCardData:SetHoChiCardStateInfo(protocol)
	self.card_info_list = protocol.card_info_list
	self.suit_info_list = protocol.suit_info_list
end

function MuseumCardData:GetCardStateInfo()
	return self.card_info_list
end

function MuseumCardData:GetSuitInfo()
	return self.suit_info_list
end

function MuseumCardData:GetCardStateInfoBySeq(seq)
	for k, v in pairs(self.card_info_list) do
		if v.card_id == seq then
			return v
		end
	end

	return {}
end

function MuseumCardData:GetCardItemInBag(is_sort)
	local bag_data = ItemData.Instance:GetBagItemDataList()
	local cfg = self:GetBoWuZhiCfg()
	local card_cfg = cfg.card_config or {}
	local item_list = {}
	for _, v in pairs(bag_data) do
		for _, v2 in pairs(card_cfg) do
			if v.item_id == v2.active_item.item_id then
				v.quality = v2.quality
				table.insert(item_list, v)
			end
		end
	end

	if is_sort then
		table.sort(item_list, SortTools.KeyUpperSorter("quality"))
	end

	return item_list
end

function MuseumCardData:GetCardSuitByFileAndchap(file_id, chapter_id)
	local cfg = self:GetCardCfgByFileAndChap(file_id, chapter_id)
	if cfg and next(cfg) then
		return cfg[1].suit_seq or 0
	end

	return 0
end

function MuseumCardData:GetCardTotalAttr(cur_select_file, cur_select_chapter)
	local card_attr_info = {}
	card_attr_info.spec_fangyu = {0, 0, 0, 0}
	local chapter_cfg = self:GetFileCfgById(cur_select_file)

	for k, v in pairs(self.card_info_list) do
		if v.card_state ~= MuseumCardData.CardState.CARD_STATE_CAN_UNLOCK then
			local card_id_cfg = self:GetCardCfgById(v.card_id)
			if card_id_cfg.file_id == cur_select_file and card_id_cfg.chapter_id == cur_select_chapter then
				local upstar_info = self:GetCardUpStarCfgByQualAndLv(card_id_cfg.quality, v.card_level) or {}

				card_attr_info.gongji = card_id_cfg.gongji + (upstar_info.gongji or 0) + (card_attr_info.gongji or 0)
				card_attr_info.fangyu = card_id_cfg.fangyu + (upstar_info.fangyu or 0) + (card_attr_info.fangyu or 0)
				card_attr_info.maxhp = card_id_cfg.maxhp + (upstar_info.maxhp or 0) + (card_attr_info.maxhp or 0)
				card_attr_info.spec_gongji = card_id_cfg.special_gongji + (card_attr_info.spec_gongji or 0)
				for i = 1, 4 do
					if i == card_id_cfg.special_fangyu_type then
						card_attr_info.spec_fangyu[i] = (upstar_info.special_fangyu or 0) + (card_attr_info.spec_fangyu[i] or 0)
					end
				end
				card_attr_info.fight_power = card_id_cfg.capability + (upstar_info.extra_cap or 0) + (card_attr_info.fight_power or 0)
			end
		end
	end

	local suit_seq = self:GetCardSuitByFileAndchap(cur_select_file, cur_select_chapter)
	local suit_info = self:GetSuitInfo()
	local suit_cfg = self:GetCardSuitCfgById(suit_seq)
	for _, v in pairs(suit_info) do
		for _, v2 in pairs(suit_cfg) do
			if v.suit_id == v2.suit_seq and v.card_count >= v2.need_cards then
				card_attr_info.gongji = v2.gongji + (card_attr_info.gongji or 0)
				card_attr_info.fangyu = v2.fangyu + (card_attr_info.fangyu or 0)
				card_attr_info.maxhp = v2.maxhp + (card_attr_info.maxhp or 0)
				card_attr_info.baoji = v2.baoji + (card_attr_info.baoji or 0)
			end
		end
	end

	return card_attr_info
end

function MuseumCardData:GetCarHasUnLock(card_info)
	local cfg = self:GetBoWuZhiCfg()
	for _, v in pairs(card_info) do
		for _, v2 in pairs(cfg.card_config) do
			if v.item_id == v2.active_item.item_id then
				local card_data = self:GetCardStateInfoBySeq(v2.card_seq)
				if card_data then
					return card_data.card_state == MuseumCardData.CardState.CARD_STATE_CAN_UNLOCK
				end
			end
		end
	end

	return false
end

function MuseumCardData:GetCardSuitCfgByIdAndNum(suit_seq, card_num)
	local card_id_cfg = self:GetCardSuitCfgById(suit_seq)
	local card_suit_cfg = {}
	for k, v in pairs(card_id_cfg) do
		if card_num >= v.need_cards then
			card_suit_cfg = v
		end
	end

	return card_suit_cfg
end

function MuseumCardData:GetHasRemindByFileAndChap(file_id, chapter_id)
	local card_cfg = self:GetCardCfgByFileAndChap(file_id, chapter_id)
	for k, v in pairs(card_cfg) do
		local card_data = self:GetCardStateInfoBySeq(v.card_seq)
		if card_data and next(card_data) then
			if card_data.card_state == MuseumCardData.CardState.CARD_STATE_CAN_UNLOCK or 
				card_data.card_state == MuseumCardData.CardState.CARD_STATE_UPGRADABLE then
				return true
			end
		end
	end

	return false
end

function MuseumCardData:GetHasRemindByFile(file_id)
	local cfg = self:GetFileCfgById(file_id)
	for k, v in pairs(cfg) do
		local has_remind = self:GetHasRemindByFileAndChap(file_id, v.chapter_id)
		if has_remind then
			return true
		end
	end

	return false
end

function MuseumCardData:GetMuseumCardItemList()
	local item_list = {}
	local cfg = self:GetBoWuZhiCfg()
	for k, v in pairs(cfg.card_config) do
		table.insert(item_list, v.active_item.item_id)
	end
	table.insert(item_list, cfg.other_config[1].decompose_reward)

	return item_list
end