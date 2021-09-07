GoldHuntExchangeView = GoldHuntExchangeView or BaseClass(BaseView)

function GoldHuntExchangeView:__init()
	self.ui_config = {"uis/views/goldhuntview", "GoldHuntExchangeTips"}
	self:SetMaskBg(true)
	self.view_layer = UiLayer.Pop
	self.play_audio = true
end

function GoldHuntExchangeView:LoadCallBack()
	self.cell_list = {}
	self.list_view = self:FindObj("list_view")
	self.list_view_delegate = self.list_view.list_simple_delegate
	self.list_view_delegate.NumberOfCellsDel = BindTool.Bind(self.GetNumberOfCells, self)
	self.list_view_delegate.CellRefreshDel = BindTool.Bind(self.RefreshView, self)

	self:ListenEvent("close_click",BindTool.Bind(self.OnCloseClick, self))
end

function GoldHuntExchangeView:ReleaseCallBack()
	for k,v in pairs(self.cell_list) do
		v:DeleteMe()
	end

	self.list_view = nil
	self.list_view_delegate = nil
end

function GoldHuntExchangeView:OpenCallBack()
	self:Flush()
end

function GoldHuntExchangeView:OnFlush()
	self.list_view.scroller:RefreshAndReloadActiveCellViews(true)
end

function GoldHuntExchangeView:GetNumberOfCells()
	return GoldHuntData.Instance:GetHuntInfoCfgCount()
end

function GoldHuntExchangeView:RefreshView(cell, data_index)
	data_index = data_index + 1
	local the_cell = self.cell_list[cell]
	if the_cell == nil then
		the_cell = GoldHuntExchangeCell.New(cell.gameObject)
		the_cell.parent = self
		self.cell_list[cell] = the_cell
	end
	the_cell:SetIndex(data_index)
	the_cell:Flush()
end

function GoldHuntExchangeView:OnCloseClick()
	self:Close()
end

-------------------------------------------------------------------------
GoldHuntExchangeCell = GoldHuntExchangeCell or BaseClass(BaseCell)

function GoldHuntExchangeCell:__init()
	self.item_cell_2 = ItemCell.New()
	self.item_cell_2:SetInstanceParent(self:FindObj("item2"))

	self.name_text = self:FindVariable("name_text")
	self.remain_count_text = self:FindVariable("remain_count_text")
	self.animal = self:FindVariable("animal")
	self:ListenEvent("exchange_click", BindTool.Bind(self.ExchangeClick, self))
	self.is_show_red = self:FindVariable("is_show_redpoint")
end

function GoldHuntExchangeCell:__delete()
	self.item_cell_2:DeleteMe()
	self.parent = nil
	self.name_text = nil
	self.remain_count_text = nil
	self.animal = nil
end

function GoldHuntExchangeCell:ExchangeClick()
	-- local info_cfg = GoldHuntData.Instance:GetActivityCfg().mine_info
	local info_cfg = GoldHuntData.Instance:GetHuntInfoCfg()[self.index]
	GoldHuntCtrl.SendRandActivityOperaReq(GoldHuntData.GOLD_HUNT_ID, GOLD_HUNT_OPERA_TYPE.OPERA_EXCHANGE_REWARD, info_cfg.seq)
end

function GoldHuntExchangeCell:OnFlush()
	local gold_hunt_data = GoldHuntData.Instance
	local info_cfg = gold_hunt_data:GetHuntInfoCfg()[self.index]
	if not info_cfg then
		return
	end

	-- local is_over_open_day = gold_hunt_data:GetOpenDay() > info_cfg.opengame_day
	-- self.root_node.gameObject:SetActive(not is_over_open_day)
	-- if is_over_open_day then
	-- 	return
	-- end

	self["item_cell_2"]:SetData(info_cfg.exchange_item)

	self.name_text:SetValue(info_cfg.name)

	local info = GoldHuntData.Instance:GetHuntInfo().gather_count_list
	if not info then
		return
	end
	local my_count = info[self.index - 1] or 0
	self.is_show_red:SetValue(my_count >= info_cfg.exchange_need_num)
	local color = my_count >= info_cfg.exchange_need_num and TEXT_COLOR.GREEN or TEXT_COLOR.RED
	self.remain_count_text:SetValue(ToColorStr(my_count.."/"..info_cfg.exchange_need_num, color))
	local asset, name = ResPath.GetGoldHuntModelImg("head_" .. self.index, self.index)
	self.animal:SetAsset(asset, name)
end