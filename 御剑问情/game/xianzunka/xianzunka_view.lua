XianzunkaView = XianzunkaView or BaseClass(BaseView)

function XianzunkaView:__init()
	self.ui_config = {"uis/views/xianzunka_prefab","XianzunkaView"}
	self.play_audio = true
	self.cell_list = {}
	self.data_list = {}
end

function XianzunkaView:ReleaseCallBack()
	self.list_view = nil
	for k,v in pairs(self.cell_list) do
		v:DeleteMe()
	end
	self.cell_list = {}
end

function XianzunkaView:LoadCallBack()
	self:ListenEvent("CloseView",
		BindTool.Bind(self.Close, self))
	self.data_list = ConfigManager.Instance:GetAutoConfig("xianzunka_auto").xianzunka_base_cfg
	self.list_view = self:FindObj("ListView")
	self.list_view.scroll_rect.horizontal = false
	self.list_view.scroll_rect.vertical = false
	local list_delegate = self.list_view.list_simple_delegate
	list_delegate.NumberOfCellsDel = BindTool.Bind(self.GetNumberOfCells, self)
	list_delegate.CellRefreshDel = BindTool.Bind(self.CellRefresh, self)
end

function XianzunkaView:OpenCallBack()

end

--滚动条----------------------
function XianzunkaView:GetNumberOfCells()
	return #self.data_list
end

function XianzunkaView:CellRefresh(cell, data_index)
	data_index = data_index + 1
	local tmp_cell = self.cell_list[cell]
	if tmp_cell == nil then
		self.cell_list[cell] = XianzunkaCell.New(cell)
		tmp_cell = self.cell_list[cell]
	end
	tmp_cell:SetData(self.data_list[data_index])
end

function XianzunkaView:OnFlush(param_t)
	if self.list_view.scroller.isActiveAndEnabled then
		self.list_view.scroller:RefreshActiveCellViews()
	end
end


-------------------------------------------------------
XianzunkaCell = XianzunkaCell or BaseClass(BaseCell)

function XianzunkaCell:__init()
	self.bg = self:FindVariable("Bg")
	self.title_name = self:FindVariable("TitleName")
	self.title_image = self:FindVariable("Title")
	self.is_title = self:FindVariable("IsTitle")
	self.cap = self:FindVariable("Cap")
	self.time = self:FindVariable("Time")
	self.btn_txt = self:FindVariable("BtnTxt")
	self.can_act = self:FindVariable("CanAct")
	self.has_reward = self:FindVariable("HasReward")
	self.can_reward = self:FindVariable("CanReward")
	self.remind = self:FindVariable("Remind")
	self.display = self:FindObj("Display")
	local item_parent = self:FindObj("Rewards")
	self.end_timestamp = 0
	self.reward_items = {}
	self.cur_show_id = 0
	for i=1,3 do
		local item = ItemCell.New()
		item:SetInstanceParent(item_parent)
		self.reward_items[i] = item
	end

	self:ListenEvent("OnClick", BindTool.Bind(self.OnClick, self))
	self:ListenEvent("OnClickAct", BindTool.Bind(self.OnClickAct, self))
	self:ListenEvent("OnClickDailyReward", BindTool.Bind(self.OnClickDailyReward, self))
end

function XianzunkaCell:__delete()
	if self.model then
		self.model:DeleteMe()
		self.model = nil
	end
	for k,v in pairs(self.reward_items) do
		v:DeleteMe()
	end
	self.reward_items = {}
	self:CancleCardTimer()
	self.cur_show_id = 0
end

function XianzunkaCell:OnFlush()
	local card_type = self.data.card_type
	local is_act = XianzunkaData.Instance:IsActive(card_type) or XianzunkaData.Instance:IsActiveForever(card_type)
	if is_act and not XianzunkaData.Instance:IsActiveForever(card_type) then
		local num = ItemData.Instance:GetItemNumInBagById(self.data.active_item_id)
		self.remind:SetValue(num > 0)
	else
		self.remind:SetValue(false)
	end
	self.can_act:SetValue(not XianzunkaData.Instance:IsActiveForever(card_type))
	if not is_act then
		self.btn_txt:SetValue(self.data.need_gold .. Language.Common.Gold)
	else
		if XianzunkaData.Instance:IsActiveForever(card_type) then
			self.btn_txt:SetValue(Language.Common.YiActivate)
		else
			self.btn_txt:SetValue(Language.Xianzunka.ForeverAct)
		end
	end
	local has_reard = XianzunkaData.Instance:IsDailyReward(card_type)
	self.can_reward:SetValue(is_act and not has_reard)
	self.has_reward:SetValue(has_reard)
	self.bg:SetAsset("uis/rawimages/xianzunka_item_bg" .. self.data.card_type + 1, "xianzunka_item_bg" .. self.data.card_type + 1 .. ".png")
	self.title_name:SetAsset("uis/views/xianzunka/images_atlas", "title_" .. self.data.card_type + 1)
	local item_id = self.data.first_active_reward.item_id
	local item_cfg, big_type = ItemData.Instance:GetItemConfig(item_id)
	if item_cfg then
		self.is_title:SetValue(item_cfg.use_type == GameEnum.ITEM_OPEN_TITLE)
		if item_cfg.use_type == GameEnum.ITEM_OPEN_TITLE then
			local bundle, asset = ResPath.GetTitleIcon(item_cfg.param1)
			self.title_image:SetAsset(bundle, asset)
		else
			self:SetModel(item_id)
		end
	end
	self.reward_items[1]:SetData(self.data.first_active_reward)
	self.reward_items[1]:SetLeftTopImg(ResPath.GetImages("label_1"))
	local addition_cfg = XianzunkaData.Instance:GetAdditionCfg(card_type)
	if addition_cfg then
		self.reward_items[2]:SetData({item_id = addition_cfg.show_reward1, num = 1, is_bind = 0})
		self.reward_items[3]:SetData({item_id = addition_cfg.show_reward2, num = 1, is_bind = 0})
	end
	self.end_timestamp = XianzunkaData.Instance:GetCardEndTimestamp(card_type)
	if XianzunkaData.Instance:IsActiveForever(card_type) then
		self:CancleCardTimer()
		self.time:SetValue(Language.Common.ShengYuShiJian .. Language.Common.Forever)
	elseif self.end_timestamp - TimeCtrl.Instance:GetServerTime() > 0 then
		if self.card_timer == nil then
			self.card_timer = GlobalTimerQuest:AddRunQuest(BindTool.Bind(self.FlushNextTime, self), 1)
			self:FlushNextTime()
		end
	else
		self:CancleCardTimer()
		self.time:SetValue("")
	end
	self.cap:SetValue(ItemData.GetFightPower(item_id))
end

function XianzunkaCell:CancleCardTimer()
	if self.card_timer then
		GlobalTimerQuest:CancelQuest(self.card_timer)
		self.card_timer = nil
	end
end

function XianzunkaCell:FlushNextTime()
	local time = self.end_timestamp - TimeCtrl.Instance:GetServerTime()
	if time > 0 then
		if time > 3600 * 24 then
			self.time:SetValue(Language.Common.ShengYuShiJian .. TimeUtil.FormatSecond(time, 6))
		elseif time > 3600 then
			self.time:SetValue(Language.Common.ShengYuShiJian .. TimeUtil.FormatSecond(time, 1))
		else
			self.time:SetValue(Language.Common.ShengYuShiJian .. TimeUtil.FormatSecond(time, 2))
		end
	else
		self:CancleCardTimer()
		self.time:SetValue("")
	end
end

function XianzunkaCell:SetModel(item_id)
	if self.cur_show_id == item_id then
		return
	end

    if self.model == nil then
        self.model = RoleModel.New()
        self.model:SetDisplay(self.display.ui3d_display)
    end
    self.cur_show_id = item_id
  	ItemData.ChangeModel(self.model, item_id)
  	self.model:SetPanelName("xianzunka_panel_" .. self.data.card_type)
end

function XianzunkaCell:OnClick()
	XianzunkaCtrl.Instance:OpenXIanzunkaDecView(self.data)
end

function XianzunkaCell:OnClickAct()
	local card_type = self.data.card_type
	if XianzunkaData.Instance:IsActive(card_type) and not XianzunkaData.Instance:IsActiveForever(card_type) then
		local index = ItemData.Instance:GetItemIndex(self.data.active_item_id)
		if index >= 0 then
			PackageCtrl.Instance:SendUseItem(index, 1, 0, 0)
		else
			local str = Split(self.data.open_panel, "#")
			--Vip面板特殊处理
			if str[1] == ViewName.VipView then
				VipData.Instance:SetOpenType(OPEN_VIP_RECHARGE_TYPE.VIP)
				VipData.Instance:SetOpenParam(tonumber(str[3]))
			end
			ViewManager.Instance:OpenByCfg(self.data.open_panel)
		end
	else
		local func = function()
			XianzunkaCtrl.SendXianZunKaOperaBuyReq(card_type)
		end
		local str = string.format(Language.Xianzunka.BuyTips, self.data.need_gold, self.data.name)
		TipsCtrl.Instance:ShowCommonTip(func, nil, str)
	end
end

function XianzunkaCell:OnClickDailyReward()
	XianzunkaCtrl.SendXianZunKaOperaRewardReq(self.data.card_type)
end