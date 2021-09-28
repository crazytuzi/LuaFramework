--Boss图鉴
BossCardInfoView = BossCardInfoView or BaseClass(BaseRender)

local EFFECT_CD = 1

function BossCardInfoView:__init()
	self.cur_chapter = 0
	self.effect_cd = 0
	self.page_count = self:FindVariable("PageCount")
	self.chapter_dec = self:FindVariable("ChapterDec")
	self.effect_root = self:FindObj("EffectRoot")

	self.card_cell = {}
	-- 获取控件
	self.card_list_view = self:FindObj("ListView")

	local list_delegate = self.card_list_view.page_simple_delegate
	list_delegate.NumberOfCellsDel = BindTool.Bind(self.CardGetNumberOfCells, self)
	list_delegate.CellRefreshDel = BindTool.Bind(self.CardRefreshCell, self)
	self.card_list_view.scroll_rect.onValueChanged:AddListener(BindTool.Bind(self.OnValueChanged, self))

	self:ListenEvent("OnClickHelp",BindTool.Bind(self.OnClickHelp, self))
	self:ListenEvent("OnClickBoss",BindTool.Bind(self.OnClickBoss, self))
end

function BossCardInfoView:__delete()
	if self.card_cell then
		for k,v in pairs(self.card_cell) do
			v:DeleteMe()
		end
		self.card_cell = {}
	end

	self.page_count = nil
	self.chapter_dec = nil
	self.card_list_view = nil
	self.effect_root = nil
end

function BossCardInfoView:OpenCallBack()
	self.need_jump = true
	self:Flush()
end

function BossCardInfoView:CloseCallBack()

end

function BossCardInfoView:OnValueChanged()
	local now_page = self.card_list_view.list_page_scroll2:GetNowPage()
	if now_page ~= self.cur_chapter then
		self.cur_chapter = now_page
		self:Flush()
	end
end

function BossCardInfoView:CardGetNumberOfCells()
	return #self.data_list
end

function BossCardInfoView:CardRefreshCell(index, cellObj)
	-- 构造Cell对象.
	local cell = self.card_cell[cellObj]
	if nil == cell then
		cell = OneBossCardCell.New(cellObj)
		self.card_cell[cellObj] = cell
	end

	cell:SetIndex(index)
	cell:SetData(self.data_list[index + 1])
end

function BossCardInfoView:OnClickHelp()
	local id = 267
	TipsCtrl.Instance:ShowHelpTipView(id)
end

function BossCardInfoView:OnClickBoss()
	ViewManager.Instance:Open(ViewName.Boss, TabIndex.vip_boss)
end

function BossCardInfoView:OnFlush(param_t)
	self.data_list = IllustratedHandbookData.Instance:GetCardDataList()

	local count = math.ceil(#self.data_list / GameEnum.BOSS_HANDBOOK_SLOT_PER_CARD)
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

	local chapter_cfg = IllustratedHandbookData.Instance:GetCardChapterCfg(self.cur_chapter)
	self.chapter_dec:SetValue(chapter_cfg and chapter_cfg.page_plot or "")
end

function BossCardInfoView:FlushCardList()
	for k,v in pairs(self.card_cell) do
		if v:GetActive() and k.transform.parent == self.card_list_view.scroll_rect.content then
			v:SetData(self.data_list[v.index + 1])
		end
	end
end

-- 升级时刷新特效
function BossCardInfoView:FlushEffect()
	if self.effect_cd and self.effect_cd - Status.NowTime <= 0 and self.effect_root then
		EffectManager.Instance:PlayAtTransformCenter(
			"effects2/prefab/ui_x/ui_sjcg_prefab",
			"UI_sjcg",
			self.effect_root.transform,
			2.0)
		self.effect_cd = Status.NowTime + EFFECT_CD
	end
end

--------------------------------------------------------------------------------------------------
OneBossCardCell = OneBossCardCell or BaseClass(BaseCell)

function OneBossCardCell:__init()
	self.show_get_img = self:FindVariable("Cap")
	self.show_special_img = self:FindVariable("ShowSpecialImg")
	self.bg_img = self:FindVariable("BgImg")
	self.cap = self:FindVariable("Cap")
	self.level = self:FindVariable("level")
	self.has_enough_level = self:FindVariable("HasEnoughLevel")
	self.show_red_point = self:FindVariable("ShowRedPoint")
	self.card_name = self:FindVariable("CardName")

	self.card_t = {}
	self.num_t = {}
	self.card_act_t = {}
	for i = 1, GameEnum.BOSS_HANDBOOK_SLOT_PER_CARD do
		self.card_t[i] = self:FindVariable("Card" .. i)
		self.num_t[i] = self:FindVariable("num" .. i)
		self.card_act_t[i] = self:FindVariable("CardActive" .. i)
		self:ListenEvent("OnClickItem" .. i, BindTool.Bind(self.OnClickCard, self, i))
	end
	self:ListenEvent("OnClickUpLevel", BindTool.Bind(self.OnClickUpLevel, self))
end

function OneBossCardCell:__delete()

end

function OneBossCardCell:GetActive()
	if self.root_node.gameObject and not IsNil(self.root_node.gameObject) then
		return self.root_node.gameObject.activeSelf
	end
	return false
end

function OneBossCardCell:OnFlush()
	if nil == self.data or nil == self.index then return end

	local level = IllustratedHandbookData.Instance:GetCurCardlevel(self.index)
	local is_max_level = IllustratedHandbookData.Instance:IsCardMaxLevel(self.index)
	local is_show_red_point = IllustratedHandbookData.Instance:IsCanUpLevel(self.index)

	self.level:SetValue(level)
	self.has_enough_level:SetValue(is_max_level)
	self.show_red_point:SetValue(is_show_red_point)

	self.show_special_img:SetValue(self.data.is_rare == 1)
	self.bg_img:SetAsset(ResPath.GetBossCardBg(self.data.pic))

	local name_bundle, name_asset = ResPath.GetBossCardRes("boss_handbook_" .. self.index)
	self.card_name:SetAsset(name_bundle, name_asset)
	

	local cap = 0
	local cfg = IllustratedHandbookData.Instance:GetSingleCardCfg(self.index)
	if nil == next(cfg) then 
		self.cap:SetValue(cap)
		return 
	end

	for i = 1, GameEnum.BOSS_HANDBOOK_SLOT_PER_CARD do
		local need_num = cfg["stuff_num_" .. (i - 1)] or 0
		local need_item_id = cfg["stuff_id_" .. (i - 1)] or 0
		local has_num = IllustratedHandbookData.Instance:GetBagCardInfo(need_item_id)
		local color = has_num >= need_num and TEXT_COLOR.YELLOW1 or TEXT_COLOR.RED

		local show_num = is_max_level and "" or (ToColorStr(has_num, color) .. " / " .. need_num)
		local is_show_black = is_max_level and true or (has_num >= need_num)

		local show_color = is_show_black and self.data.card_color or 0
		local bundle, asset = ResPath.GetBossCardRes("CardColor" .. show_color)

		self.num_t[i]:SetValue(show_num)
		self.card_act_t[i]:SetValue(is_show_black)
		self.card_t[i]:SetAsset(bundle, asset)
	end
	
	cap = CommonDataManager.GetCapabilityCalculation(cfg or {})
	self.cap:SetValue(cap)
end

function OneBossCardCell:OnClickUpLevel()
	if nil == self.index then return end
	
	local is_can_up_level = IllustratedHandbookData.Instance:IsCanUpLevel(self.index)
	local is_max_level = IllustratedHandbookData.Instance:IsCardMaxLevel(self.index)

	if is_can_up_level and not is_max_level then
		IllustratedHandbookCtrl.Instance:SendBossHandBookPutOn(self.index)
	elseif not is_can_up_level then
		SysMsgCtrl.Instance:ErrorRemind(Language.IllustratedHandbook.NoEnough)
	end
end

function OneBossCardCell:OnClickCard(slot)
	local card_index = slot - 1 or 0
	local cfg = IllustratedHandbookData.Instance:GetSingleCardCfg(self.index)
	if nil == next(cfg) then return end

	local need_num = cfg["stuff_num_" .. card_index] or 0
	local need_item_id = cfg["stuff_id_" .. card_index] or 0
	local has_num = IllustratedHandbookData.Instance:GetBagCardInfo(need_item_id)
	
	if has_num >= need_num then
		local data = {item_id = need_item_id, num = 1, is_bind = 0}
		TipsCtrl.Instance:OpenItem(data)
	else
		TipsCtrl.Instance:ShowItemGetWayView(need_item_id)
	end
end