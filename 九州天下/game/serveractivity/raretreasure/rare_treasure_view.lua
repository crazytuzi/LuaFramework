RareTreasureView = RareTreasureView or BaseClass(BaseView)

function RareTreasureView:__init()
	self.ui_config = {"uis/views/serveractivity/raretreasure", "RareTreasureView"}
	self.word_cell = {}
	self.btn_cell = {}
	self.select_index = 0
	self:SetMaskBg()
end

function RareTreasureView:ReleaseCallBack()
	self.page_view = nil
	self.list_view = nil

	for k,v in pairs(self.word_cell) do
		v:DeleteMe()
	end
	self.word_cell = {}

	for k,v in pairs(self.btn_cell) do
		v:DeleteMe()
	end
	self.btn_cell = {}

	if self.money_bar then
		self.money_bar:DeleteMe()
		self.money_bar = nil
	end

	self.open_time = nil
	self.stage_text = nil
	self.totle_cost = nil
	self.need_recharge = nil
	self.btn_text = nil
	self.btn_enable= nil
	self.unlock_num = nil
	self.word_res = nil
	self.btn_red = nil
	self.now_charge = nil
end

function RareTreasureView:LoadCallBack()
	self:ListenEvent("CloseView", BindTool.Bind(self.Close, self))
	self:ListenEvent("ClickChange", BindTool.Bind(self.ClickChange, self))
	self:ListenEvent("ClickHelp", BindTool.Bind(self.ClickHelp, self))

	self.list_view = self:FindObj("ListView")
	local list_view_delegate = self.list_view.list_simple_delegate
	list_view_delegate.NumberOfCellsDel = BindTool.Bind(self.LeftBtnGetNumberOfCells, self)
	list_view_delegate.CellRefreshDel = BindTool.Bind(self.LeftBtnRefreshCell, self)

	self.page_view = self:FindObj("PageView")
	local page_view_delegate = self.page_view.page_simple_delegate
	page_view_delegate.NumberOfCellsDel = BindTool.Bind(self.WordGetNumberOfCells, self)
	page_view_delegate.CellRefreshDel = BindTool.Bind(self.WordRefreshCell, self)
	self.page_view.list_view:Reload()

	self.money_bar = MoneyBar.New()
	self.money_bar:SetInstanceParent(self:FindObj("MoneyBar"))

	self.open_time = self:FindVariable("OpenTime")
	self.stage_text = self:FindVariable("StageText")
	self.totle_cost = self:FindVariable("TotleNum")
	self.need_recharge = self:FindVariable("NeedRecharge")
	self.btn_text = self:FindVariable("BtnText")
	self.btn_enable = self:FindVariable("BtnEnable")
	self.unlock_num = self:FindVariable("UnLockNum")
	self.word_res = self:FindVariable("WordRes")
	self.btn_red = self:FindVariable("BtnRed")
	self.now_charge = self:FindVariable("NowCharge")
	self:Flush()
end

function RareTreasureView:OpenCallBack()
	HappyBargainCtrl.Instance:SendCrossRandActivityRequest(ACTIVITY_TYPE.CROSS_MI_BAO_RANK, RARE_TREASURE.RA_ZHEN_YAN_REQ_TYPE_INFO)
end

function RareTreasureView:ClickChange()
	local charge_num = RareTreasureData.Instance:GetTotleChongZhi()
	local cur_pool_config = RareTreasureData.Instance:GetConfigByPoolSeq(self.select_index)
	if not cur_pool_config then return end
	local unlock_cost = cur_pool_config.unlock_cost
	if charge_num < unlock_cost then
		ViewManager.Instance:Open(ViewName.RechargeView)
		return
	end

	local cur_word = RareTreasureData.Instance:GetMyWordBySeq(self.select_index)
	if cur_word == -1 then
		SysMsgCtrl.Instance:ErrorRemind(Language.Rare.PleaseSelect)
	else
		SysMsgCtrl.Instance:ErrorRemind(Language.Rare.PleaseChange)
	end
end

function RareTreasureView:SetSelectIndex(select_index)
	self.select_index = select_index
	self:Flush()
end

function RareTreasureView:GetSelectIndex()
	return self.select_index
end

function RareTreasureView:FlushBtnAllHL()
	for k,v in pairs(self.btn_cell) do
		v:FlushHL()
	end
end

----- 左边按钮列表
function RareTreasureView:LeftBtnGetNumberOfCells()
	return #RareTreasureData.Instance:GetAllConfig()
end

function RareTreasureView:LeftBtnRefreshCell(cellObj, index)
	local cell = self.btn_cell[cellObj]
	local cell_data = RareTreasureData.Instance:GetConfigByPoolSeq(index)
	if nil == cell then
		cell = LeftBtnItem.New(cellObj, self)
		self.btn_cell[cellObj] = cell
	end
	cell:SetIndex(cell_data and cell_data.pool_seq or index)
	cell:SetData(cell_data)
end

---- 中间9个字
function RareTreasureView:WordGetNumberOfCells()
	return #RareTreasureData.Instance:GetWordAllConfig()
end

function RareTreasureView:WordRefreshCell(index, cellObj)
	local cell = self.word_cell[cellObj]
	local cell_data = RareTreasureData.Instance:GetWordConfigBySeq(index)
	if nil == cell then
		cell = RareWordItem.New(cellObj, self)
		self.word_cell[cellObj] = cell
	end
	cell:SetIndex(index)
	cell:SetData(cell_data)
end

function RareTreasureView:OnFlush(param_t)
	for k,v in pairs(param_t) do
		if k == "flush_btn" then
			self.list_view.scroller:RefreshActiveCellViews()
		end
	end
	local cur_pool_config = RareTreasureData.Instance:GetConfigByPoolSeq(self.select_index)
	if not cur_pool_config then return end
	self.page_view.list_view:Reload()
	local totle_cost = RareTreasureData.Instance:GetLotteryCost()
	local pool_cost = math.ceil(totle_cost * (cur_pool_config.reward_rate or 0))
	self.totle_cost:SetValue(pool_cost)
	self.unlock_num:SetValue(cur_pool_config.unlock_cost or 0)

	local select_word = RareTreasureData.Instance:GetMyWordBySeq(self.select_index)
	local word_cfg = RareTreasureData.Instance:GetWordConfigBySeq(select_word)
	local word = Language.Rare.NoSelect
	local status = Language.Rare.Wait
	local true_word = RareTreasureData.Instance:GetTrueWordBySeq(self.select_index)
	if true_word ~= -1 then
		status = Language.Rare.Open
		self.word_res:SetAsset(ResPath.GetRareTreasureImage("word_" .. true_word))
	end
	if word_cfg then
		word = word_cfg.word
	end
	self.stage_text:SetValue(string.format(Language.Rare.SelectWord, status, word))
	local time_hour = string.sub(cur_pool_config.lottery_time, 1, 2)
	local time_min = string.sub(cur_pool_config.lottery_time, 3, 4)
	self.open_time:SetValue(string.format(Language.Rare.TimeStr, time_hour, time_min))
	self.need_recharge:SetValue(string.format(Language.Rare.NeedRecharge, cur_pool_config.unlock_cost))
	self.now_charge:SetValue(string.format(Language.Rare.TodayCharge, RareTreasureData.Instance:GetTotleChongZhi()))
	self:FLushButtonStage()
end

function RareTreasureView:FLushButtonStage()
	self.btn_red:SetValue(false)
	local charge_num = RareTreasureData.Instance:GetTotleChongZhi()
	local cur_pool_config = RareTreasureData.Instance:GetConfigByPoolSeq(self.select_index)
	if not cur_pool_config then return end
	local unlock_cost = cur_pool_config.unlock_cost
	if RareTreasureData.Instance:GetTrueWordBySeq(self.select_index) == -1 then
		self.btn_enable:SetValue(true)
	else
		self.btn_enable:SetValue(false)
	end

	if charge_num < unlock_cost then
		self.btn_text:SetValue(Language.Rare.GoRecharge)
		return
	end

	local true_word = RareTreasureData.Instance:GetTrueWordBySeq(self.select_index)
	if true_word ~= -1 then
		self.btn_text:SetValue(Language.Rare.Open)
		self.btn_red:SetValue(false)
		return
	end

	local cur_word = RareTreasureData.Instance:GetMyWordBySeq(self.select_index)
	if cur_word == -1 then
		self.btn_text:SetValue(Language.Rare.Chose)
		self.btn_red:SetValue(true)
		return
	else
		self.btn_text:SetValue(Language.Rare.Change)
		return
	end
end

function RareTreasureView:ClickHelp()
	local tips_id = 257						-- 真言秘宝玩法说明
	TipsCtrl.Instance:ShowHelpTipView(tips_id)
end

--------------------------LeftBtn---------------
LeftBtnItem = LeftBtnItem or BaseClass(BaseCell)
function LeftBtnItem:__init(instance, parent)
	self.parent = parent
	self.name = self:FindVariable("Name")
	self.show_hl = self:FindVariable("ShowHL")
	self.pool_is_open = self:FindVariable("IsOpen")
	self.show_red = self:FindVariable("ShowRed")
	self:ListenEvent("OnClick", BindTool.Bind(self.OnClickBtn, self))
end

function LeftBtnItem:__delete()
	self.parent = nil
end

function LeftBtnItem:OnClickBtn()
	self.parent:SetSelectIndex(self.index)
	self.parent:FlushBtnAllHL()
end

function LeftBtnItem:OnFlush()
	if not self.data then return end
	self.name:SetValue(string.format(Language.Rare.LeftName, CommonDataManager.GetDaXie(self.index + 1)))
	local true_word = RareTreasureData.Instance:GetTrueWordBySeq(self.index)
	self.pool_is_open:SetValue(true_word ~= -1)
	local cur_pool_config = RareTreasureData.Instance:GetConfigByPoolSeq(self.index)
	local is_show_red = false
	if true_word == -1 and cur_pool_config then
		local chatge_num = RareTreasureData.Instance:GetTotleChongZhi()
		local select_word = RareTreasureData.Instance:GetMyWordBySeq(self.index)
		if chatge_num >= cur_pool_config.unlock_cost and select_word == -1 then
			is_show_red = true
		end
	end
	self.show_red:SetValue(is_show_red)
	self:FlushHL()
end

function LeftBtnItem:FlushHL()
	if self.parent then
		local cur_select = self.parent:GetSelectIndex()
		self.show_hl:SetValue(self.index == cur_select)
	end
end

-------------------------WordItem----------------------
RareWordItem = RareWordItem or BaseClass(BaseCell)
function RareWordItem:__init(instance, parent)
	self.parent = parent
	self.word_res = self:FindVariable("WordRes")
	self.show_effect = self:FindVariable("ShoeEffect")
	self.is_select = self:FindVariable("IsSelect")
	self:ListenEvent("OnClick", BindTool.Bind(self.OnClickWord, self))
end

function RareWordItem:__delete()
	self.parent = nil
end

function RareWordItem:OnFlush()
	if not self.data then return end
	local bundle, asset = ResPath.GetRareTreasureImage("word_" .. self.index)
	self.word_res:SetAsset(bundle, asset)

	if self.parent then
		local select_pool_index = self.parent:GetSelectIndex()
		local pool_select_word = RareTreasureData.Instance:GetMyWordBySeq(select_pool_index)
		self.is_select:SetValue(self.index == pool_select_word)
	end
end

function RareWordItem:OnClickWord()
	RareTreasureCtrl.Instance:OpenSelectView(self.index)
end

function RareWordItem:ClearClick()
	self:ClearEvent("OnClick")
end

function RareWordItem:SetEffectHL(value)
	if self.show_effect then
		self.show_effect:SetValue(value)
	end
end