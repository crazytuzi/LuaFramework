--卡牌
CardInfoView = CardInfoView or BaseClass(BaseRender)

function CardInfoView:__init()
	self.cur_chapter = 0
	self.chapter_name = self:FindVariable("ChapterName")
	self.open_limit = self:FindVariable("OpenLimit")
	self.page_count = self:FindVariable("PageCount")
	self.chapter_dec = self:FindVariable("ChapterDec")

	self.card_cell = {}
	-- 获取控件
	self.card_list_view = self:FindObj("ListView")

	local list_delegate = self.card_list_view.page_simple_delegate
	list_delegate.NumberOfCellsDel = BindTool.Bind(self.CardGetNumberOfCells, self)
	list_delegate.CellRefreshDel = BindTool.Bind(self.CardRefreshCell, self)
	self.card_list_view.scroll_rect.onValueChanged:AddListener(BindTool.Bind(self.OnValueChanged, self))

	self:ListenEvent("OnClickHelp",BindTool.Bind(self.OnClickHelp, self))
	self:ListenEvent("OnClickGuaji",BindTool.Bind(self.OnClickGuaji, self))
end

function CardInfoView:__delete()
	if self.card_cell then
		for k,v in pairs(self.card_cell) do
			v:DeleteMe()
		end
		self.card_cell = {}
	end

end

function CardInfoView:OpenCallBack()
	self.need_jump = true
	self:Flush()
end

function CardInfoView:CloseCallBack()

end

function CardInfoView:OnValueChanged()
	local now_page = self.card_list_view.list_page_scroll2:GetNowPage()
	if now_page ~= self.cur_chapter then
		self.cur_chapter = now_page
		self:Flush()
	end
end

function CardInfoView:CardGetNumberOfCells()
	return #self.data_list
end

function CardInfoView:CardRefreshCell(index, cellObj)
	-- 构造Cell对象.
	local cell = self.card_cell[cellObj]
	if nil == cell then
		cell = OneCardCell.New(cellObj)
		-- cell:SetToggleGroup(self.root_node.toggle_group)
		self.card_cell[cellObj] = cell
	end
	cell.local_index = index
	cell:SetData(self.data_list[index + 1])
end

function CardInfoView:OnClickHelp()
	TipsCtrl.Instance:ShowHelpTipView(244)
end

function CardInfoView:OnClickGuaji()
	ViewManager.Instance:Open(ViewName.YewaiGuajiView)
end

function CardInfoView:OnFlush(param_t)
	self.data_list = CardData.Instance:GetCardDataList()
	local count = math.ceil(#self.data_list / 4)
	self.page_count:SetValue(count)
	self.card_list_view.list_page_scroll2:SetPageCount(count)
	if next(self.card_cell) ~= nil and not self.need_jump then
		self:FlushCardList()
	else
		self.card_list_view.list_view:Reload(function()
			self.card_list_view.list_page_scroll2:JumpToPageImmidate(0)
		end)
		self.card_list_view.list_view:JumpToIndex(0)
		self.need_jump = false
	end
	local chapter_cfg = CardData.Instance:GetCardChapterCfg(self.cur_chapter)
	self.chapter_dec:SetValue(chapter_cfg and chapter_cfg.page_plot or "")
	self.chapter_name:SetAsset(ResPath.GetCardRes("ChapterName" .. (self.cur_chapter + 1)))
	local n_chapter_cfg = CardData.Instance:GetCardChapterCfg(self.cur_chapter + 1)
	if n_chapter_cfg and n_chapter_cfg.card_level > CardData.Instance:GetCardLevel() then
		self.open_limit:SetValue(string.format(Language.Card.OpenChapterLimit, n_chapter_cfg.card_level))
	else
		self.open_limit:SetValue("")
	end
end

function CardInfoView:FlushCardList()
	for k,v in pairs(self.card_cell) do
		if v:GetActive() and k.transform.parent == self.card_list_view.scroll_rect.content then
			v:SetData(self.data_list[v.local_index + 1])
		end
	end
end


OneCardCell = OneCardCell or BaseClass(BaseCell)

function OneCardCell:__init()
	self.show_get_img = self:FindVariable("Cap")
	self.prof_img = self:FindVariable("ProfImg")
	self.show_prof_img = self:FindVariable("ShowProfImg")
	self.bg_img = self:FindVariable("BgImg")
	self.cap = self:FindVariable("Cap")
	self.card_text = self:FindVariable("CardText")
	self.card_name = self:FindVariable("CardName")

	self.card_t = {}
	self.star_t = {}
	self.card_act_t = {}
	self.card_obj_t = {}
	for i = 1, 4 do
		self.card_t[i] = self:FindVariable("Card" .. i)
		self.star_t[i] = self:FindVariable("Star" .. i)
		self.card_act_t[i] = self:FindVariable("CardActive" .. i)
		self.card_obj_t[i] = self:FindObj("CardObj" .. i)
		self:ListenEvent("OnClickCard" .. i,BindTool.Bind(self.OnClickCard, self, i))
	end
end

function OneCardCell:__delete()

end

function OneCardCell:GetActive()
	if self.root_node.gameObject and not IsNil(self.root_node.gameObject) then
		return self.root_node.gameObject.activeSelf
	end
	return false
end

function OneCardCell:OnClickCard(slot)
	local color, item_id = CardData.Instance:GetCardPieceColor(self.data.card_idx, slot - 1)
	local item = CardData.Instance:GetMaxCanEquipCard(self.data.card_idx, slot -  1, color)
	if item then
		CardCtrl.SendCardSlotPutOn(self.data.card_idx, slot -  1, item.index)
	else
		if item_id > 0 then
			TipsCtrl.Instance:OpenItem({item_id = item_id, num = 1, is_bind = 0}, TipsFormDef.FROM_CARD, nil, close_callback)
		else
			local cfg = CardData.Instance:GetCardCfg(self.data.card_idx, slot -  1, color + 1)
			if cfg then
				local prof = PlayerData.Instance:GetRoleBaseProf()
				if cfg["prof" .. prof .. "_stuff_id"] then
					GlobalEventSystem:Fire(KnapsackEventType.KNAPSACK_LECK_ITEM, cfg["prof" .. prof .. "_stuff_id"])
				end
			end
		end
	end
end

function OneCardCell:OnFlush()
	local cap = 0
	local name_color = 6
	for i = 1, 4 do
		local color = CardData.Instance:GetCardPieceColor(self.data.card_idx, i - 1)
		local star = 0
		local show_color = color
		if color > 6 then
			show_color = 6
		end
		if show_color < name_color then
			name_color = show_color
		end
		local bundle, asset = ResPath.GetCardRes("CardColor" .. show_color)
		self.card_t[i]:SetAsset(bundle, asset)
		self.star_t[i]:SetValue(star)
		local item = CardData.Instance:GetMaxCanEquipCard(self.data.card_idx, i -  1, color)
		self.card_act_t[i]:SetValue(color > 0 or item ~= nil)
		self.card_obj_t[i].animator:SetBool("fold", item ~= nil)
		local card_cfg = CardData.Instance:GetCardCfg(self.data.card_idx, i -  1, color)
		cap = cap + CommonDataManager.GetCapabilityCalculation(card_cfg or {})
	end
	self.cap:SetValue(cap)
	local prof = PlayerData.Instance:GetRoleBaseProf()
	self.card_text:SetValue(self.data["prof" .. prof .. "_plot"])
	self.bg_img:SetAsset(ResPath.GetCardBg(self.data["prof" .. prof .. "_pic"]))
	self.prof_img:SetAsset(ResPath.GetCardRes("ProfWord" .. prof))
	self.show_prof_img:SetValue(self.data.prof_only == 1)
	local name_color_str = SOUL_NAME_COLOR[name_color] or SOUL_NAME_COLOR[1]
	self.card_name:SetValue("<color=" .. name_color_str .. ">" .. self.data["prof" .. prof .. "_name"] .. "</color>")
end