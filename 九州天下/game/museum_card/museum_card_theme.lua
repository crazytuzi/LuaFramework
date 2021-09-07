MuseumCardTheme = MuseumCardTheme or BaseClass(BaseView)
-- 博物志
function MuseumCardTheme:__init()
	self.ui_config = {"uis/views/museumcardview","MuseumCardTheme"}
	self:SetMaskBg()
	self.full_screen = false
	self.play_audio = true

	self.cur_select_file = 1		-- 所选卷
	self.cur_select_chapter = 1		-- 所选章节
end

function MuseumCardTheme:__delete()
	self.full_screen = nil
	self.play_audio = nil
end

function MuseumCardTheme:ReleaseCallBack()
	if self.money_bar then
		self.money_bar:DeleteMe()
		self.money_bar = nil
	end
	self.title_name = nil
	self.card_list_view = nil 
	self.button_list_view = nil
	for k,v in pairs(self.card_cell_list) do
		v:DeleteMe()
	end
	for k,v in pairs(self.button_cell_list) do
		v:DeleteMe()
	end
end

function MuseumCardTheme:OpenCallBack()
	MuseumCardCtrl.Instance:SendCommonOperateReq(RA_MUSEUM_CARD_OPERA_TYPE.RA_MUSEUM_CARD_OPERA_TYPE_ALL_INFO)

	self:FlushTitleName()

	if self.card_list_view then
		self.card_list_view.scroller:ReloadData(0)
	end
end

function MuseumCardTheme:CloseCallBack()
	self:SetCurSelectCardId(0)
end

function MuseumCardTheme:LoadCallBack()
	self.money_bar = MoneyBar.New()
	self.money_bar:SetInstanceParent(self:FindObj("MoneyBar"))

	self.title_name = self:FindVariable("TitleName")

	self:ListenEvent("Close", BindTool.Bind(self.Close, self))
	self:ListenEvent("OnClickCardInfo", BindTool.Bind(self.OnClickCardInfo, self))
	self:ListenEvent("OnClickCardAttr", BindTool.Bind(self.OnClickCardAttr, self))

	self.card_cell_list = {}
	self.card_list_view = self:FindObj("CardListView")
	local card_list_delegate = self.card_list_view.list_simple_delegate
	card_list_delegate.NumberOfCellsDel = BindTool.Bind(self.GetCardNumOfCells, self)
	card_list_delegate.CellRefreshDel = BindTool.Bind(self.RefreshCardListView, self)

	self.button_cell_list = {}
	self.button_list_view = self:FindObj("ButtonListView")
	local button_list_delegate = self.button_list_view.list_simple_delegate
	button_list_delegate.NumberOfCellsDel = BindTool.Bind(self.GetButtonNumOfCells, self)
	button_list_delegate.CellRefreshDel = BindTool.Bind(self.RefreshButtonListView, self)
end

function MuseumCardTheme:SetData(file_id, chapter_id)
	self.cur_select_file = file_id
	self.cur_select_chapter = chapter_id
end

function MuseumCardTheme:GetCardNumOfCells()
	local data = MuseumCardData.Instance:GetCardCfgByFileAndChap(self.cur_select_file, self.cur_select_chapter)

	return math.ceil(#data / 4)
end

function MuseumCardTheme:RefreshCardListView(cell, cell_index)
	local card_cell = self.card_cell_list[cell]
	if card_cell == nil then
		card_cell = MuseumCardThemeItemContain.New(cell.gameObject, self)
		card_cell.parent = self
		self.card_cell_list[cell] = card_cell
	end
	card_cell:SetIndex(cell_index + 1)
	card_cell:SetData({})
end

function MuseumCardTheme:GetButtonNumOfCells()
	local data = MuseumCardData.Instance:GetFileCfgById(self.cur_select_file)

	return #data
end

function MuseumCardTheme:RefreshButtonListView(cell, cell_index)
	local button_cell = self.button_cell_list[cell]
	if button_cell == nil then
		button_cell = MuseumCardThemeButtonItem.New(cell.gameObject, self)
		button_cell.parent = self
		self.button_cell_list[cell] = button_cell
	end
	local data = MuseumCardData.Instance:GetFileCfgById(self.cur_select_file)
	
	button_cell:SetIndex(cell_index + 1)
	button_cell:SetData(data[cell_index + 1])
end

function MuseumCardTheme:GetCurSelectChapter()
	return self.cur_select_chapter
end

function MuseumCardTheme:GetCurSelectFile()
	return self.cur_select_file
end

function MuseumCardTheme:OnClickCardInfo()
	ViewManager.Instance:Open(ViewName.MuseumCardFenJie)
end

function MuseumCardTheme:OnClickCardAttr()
	MuseumCardCtrl.Instance:OpenAttrView(self.cur_select_file, self.cur_select_chapter)
end

function MuseumCardTheme:OnFlush()
	if self.button_list_view then
		self.button_list_view.scroller:ReloadData(0)
	end

	if self.card_list_view then
		self.card_list_view.scroller:RefreshActiveCellViews()
	end
end

function MuseumCardTheme:FlushListView()
	if self.button_list_view then
		self.button_list_view.scroller:ReloadData(0)
	end

	if self.card_list_view then
		self.card_list_view.scroller:ReloadData(0)
	end
end

function MuseumCardTheme:FlushTitleName()
	if self.title_name then
		local chapter_info = MuseumCardData.Instance:GetFileCfgByIdAndChap(self.cur_select_file, self.cur_select_chapter)
		self.title_name:SetValue(chapter_info.chapter_name)
	end
end

function MuseumCardTheme:SetCurSelectCardId(card_id)
	for k, v in pairs(self.card_cell_list) do
		v:SetCurSelectCardId(card_id)
	end
end

function MuseumCardTheme:FlushAllHL()
	for k, v in pairs(self.card_cell_list) do
		v:FlushAllHL()
	end
end

---------------------------------------------------------------
-- 4个item
MuseumCardThemeItemContain = MuseumCardThemeItemContain  or BaseClass(BaseCell)

function MuseumCardThemeItemContain:__init()
	self.card_id = 0
	self.card_contain_list = {}
	for i = 1, 4 do
		self.card_contain_list[i] = MuseumCardThemeItem.New(self:FindObj("item_" .. i))
		self.card_contain_list[i].parent = self
	end
end

function MuseumCardThemeItemContain:__delete()
	for i = 1, 4 do
		self.card_contain_list[i]:DeleteMe()
		self.card_contain_list[i] = nil
	end
	self.parent = nil
end

function MuseumCardThemeItemContain:OnFlush()
	for i = 1, 4 do
		self.card_contain_list[i]:SetIndex(i)
		self.card_contain_list[i].parent = self
		self.card_contain_list[i]:SetData({})
	end
end

function MuseumCardThemeItemContain:GetCurIndex()
	return self.index
end

function MuseumCardThemeItemContain:GetCurSelectFile()
	return self.parent:GetCurSelectFile()
end

function MuseumCardThemeItemContain:GetCurSelectChapter()
	return self.parent:GetCurSelectChapter()
end

function MuseumCardThemeItemContain:SetCurSelectCardId(card_id)
	self.card_id = card_id
end

function MuseumCardThemeItemContain:GetCurSelectCardId()
	return self.card_id
end

function MuseumCardThemeItemContain:FlushAllHL()
	for k,v in pairs(self.card_contain_list) do
		v:FlushHL()
	end
end

---------------------------------------------------------------------
-- 一个item
MuseumCardThemeItem = MuseumCardThemeItem or BaseClass(BaseCell)
function MuseumCardThemeItem:__init()
	self.name = self:FindVariable("Name")
	self.show_card_state = self:FindVariable("ShowCardState")
	self.card_img = self:FindVariable("CardImg")
	self.card_quality = self:FindVariable("CardQuality")
	self.show_hl = self:FindVariable("ShowHightLight")
	self.show_gray = self:FindVariable("ShowGray")
	self.card_state_img = self:FindVariable("CardStateImg")
	self.show_star = self:FindVariable("ShowStar")
	self.show_quality = self:FindVariable("ShowQuality")
	self.show_effect = self:FindVariable("ShowEffect")
	self.star_list = {}
	self.show_star_list = {}
	for i = 1, 5 do
		self.star_list[i] = self:FindVariable("Star" .. i)
		self.show_star_list[i] = self:FindVariable("ShowStar" .. i)
	end

	self:ListenEvent("OnClickToggle", BindTool.Bind(self.OnToggleClick, self))
end

function MuseumCardThemeItem:__delete()
	self.parent = nil
end

function MuseumCardThemeItem:OnFlush()
	if not self.data then
		return
	end

	local card_data = MuseumCardData.Instance:GetCardCfgByFileAndChap(self.parent:GetCurSelectFile(), self.parent:GetCurSelectChapter())
	local index = (self.parent:GetCurIndex() - 1) * 4 + self.index
	if nil == card_data[index] or nil == next(card_data[index]) then return end
	
	self.name:SetValue(card_data[index].card_name)

	self.card_img:SetAsset(ResPath.GetMuseumCardImage("card_" .. self.parent:GetCurSelectFile() .. "_" .. self.parent:GetCurSelectChapter() .. "_" .. index))
	self.card_quality:SetAsset(ResPath.GetMuseumCardImage("quality_" .. card_data[index].quality))

	self:FlushHL()

	local card_state = MuseumCardData.Instance:GetCardStateInfoBySeq(card_data[index].card_seq)
	if nil == next(card_state) then
		self.show_quality:SetValue(card_data[index].is_special ~= 1)
		self.show_gray:SetValue(card_data[index].is_special == 1)
		self.show_card_state:SetValue(false)
		self.show_star:SetValue(false)
		self.show_effect:SetValue(false)
	else
		self.show_quality:SetValue(true)
		self.show_gray:SetValue(card_state.card_state ~= MuseumCardData.CardState.CARD_STATE_CAN_UNLOCK)
		self.show_card_state:SetValue(card_state.card_state ~= MuseumCardData.CardState.CARD_STATE_UNLOCKED)

		if card_data[index].quality == MuseumCardData.CardQuality.PURPLE then
			self.show_effect:SetValue(card_state.card_state ~= MuseumCardData.CardState.CARD_STATE_CAN_UNLOCK)
		else
			self.show_effect:SetValue(false)
		end

		if card_state.card_state == MuseumCardData.CardState.CARD_STATE_CAN_UNLOCK then
			self.card_state_img:SetAsset(ResPath.GetMuseumCardImage("can_active"))
		elseif card_state.card_state == MuseumCardData.CardState.CARD_STATE_UPGRADABLE then
			self.card_state_img:SetAsset(ResPath.GetMuseumCardImage("can_upstar"))
		end

		if card_state.card_level == 0 then
			self.show_star:SetValue(false)
		else
			self.show_star:SetValue(true)
			local div_index = math.floor(card_state.card_level / 5)
			local rem_index = math.floor(card_state.card_level % 5)
			for i = 1, 5 do
				if div_index == 0 then
					self.show_star_list[i]:SetValue(card_state.card_level >= i)
					self.star_list[i]:SetAsset(ResPath.GetMuseumCardImage("img_star_" .. div_index))
				else
					self.show_star_list[i]:SetValue(true)
					if rem_index >= i then
						self.star_list[i]:SetAsset(ResPath.GetMuseumCardImage("img_star_" .. div_index))
					else
						self.star_list[i]:SetAsset(ResPath.GetMuseumCardImage("img_star_" .. div_index - 1))
					end
				end
			end 
		end
	end
end

function MuseumCardThemeItem:OnToggleClick()
	local file_id = self.parent:GetCurSelectFile()
	local chapter_id = self.parent:GetCurSelectChapter()
	local card_id = (self.parent:GetCurIndex() - 1) * 4 + self.index
	self.parent.parent:SetCurSelectCardId(card_id)
	self.parent.parent:FlushAllHL()

	local card_data = MuseumCardData.Instance:GetCardCfgByFileAndChap(self.parent:GetCurSelectFile(), self.parent:GetCurSelectChapter())
	local index = (self.parent:GetCurIndex() - 1) * 4 + self.index
	local card_state = MuseumCardData.Instance:GetCardStateInfoBySeq(card_data[index].card_seq)
	if nil == next(card_state) then
		if card_data[index].is_special == 1 then
			TipsCtrl.Instance:ShowCommonTip(nil, nil, Language.MuseumCard.JoinIng, nil, nil, false, false, nil, nil, nil, nil, true)
		else
			SysMsgCtrl.Instance:ErrorRemind(Language.MuseumCard.CardHasNotActive)
		end
		return
	end

	if card_state.card_state == MuseumCardData.CardState.CARD_STATE_CAN_UNLOCK then
		MuseumCardCtrl.Instance:SendCommonOperateReq(RA_MUSEUM_CARD_OPERA_TYPE.RA_MUSEUM_CARD_OPERA_TYPE_ACTIVE, card_data[index].card_seq)
	else
		MuseumCardCtrl.Instance:OpenCardInfoView(file_id, chapter_id, card_id)
	end
end

function MuseumCardThemeItem:FlushHL()
	local select_index = self.parent:GetCurSelectCardId()
	self.show_hl:SetValue(select_index == (self.parent:GetCurIndex() - 1) * 4 + self.index)
end

---------------------------------------------------------------------
-- button
MuseumCardThemeButtonItem = MuseumCardThemeButtonItem or BaseClass(BaseCell)
function MuseumCardThemeButtonItem:__init()
	self.name = self:FindVariable("Name")
	self.show_rp = self:FindVariable("ShowRp")

	self:ListenEvent("OnClick", BindTool.Bind(self.OnClick, self))
end

function MuseumCardThemeButtonItem:__delete()
	self.parent = nil
end

function MuseumCardThemeButtonItem:OnClick()
	self.parent.cur_select_chapter = self.index
	self.parent:FlushListView()
end

function MuseumCardThemeButtonItem:OnFlush()
	if not self.data then return end

	self.name:SetValue(self.data.chapter_name)
	self.root_node.toggle.isOn = self.index == self.parent:GetCurSelectChapter()

	local has_remind = MuseumCardData.Instance:GetHasRemindByFileAndChap(self.parent:GetCurSelectFile(), self.index)
	self.show_rp:SetValue(has_remind)
end