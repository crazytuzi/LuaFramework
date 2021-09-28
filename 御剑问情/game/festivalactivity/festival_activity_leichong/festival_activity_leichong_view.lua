FestivalLeiChongView = FestivalLeiChongView or BaseClass(BaseRender)

function FestivalLeiChongView:__init()
	self.display = self:FindObj("Display")
	self.model = RoleModel.New()
	self.model:SetDisplay(self.display.ui3d_display)
	self.item_id = 0
	self.jump_page = -1

	local page_count = #FestivalLeiChongData.Instance:GetVesTotalChargeCfg()

	self.cell_list = {}
	self.list_view = self:FindObj("ListView")
	self.list_view.list_page_scroll:SetPageCount(page_count)

	local list_delegate = self.list_view.list_simple_delegate
	list_delegate.NumberOfCellsDel = BindTool.Bind(self.GetNumberOfCells, self)
	list_delegate.CellRefreshDel = BindTool.Bind(self.RefreshCell, self)
	self.list_view.list_page_scroll.JumpToPageEvent = self.list_view.list_page_scroll.JumpToPageEvent + BindTool.Bind(self.FlushPage, self)

	self.left_button = self:FindVariable("show_left_button")
	self.right_button = self:FindVariable("show_right_button")
	self.can_rewards = self:FindVariable("get_prize")
	self.rare_received = self:FindVariable("ar_received")
	self.count_down = self:FindVariable("count_down")
	self.max_charge_value = self:FindVariable("max_recharge")
	self.charge_value = self:FindVariable("recharge")
	self.received = self:FindVariable("ar_received")
	self.ani_image = self:FindVariable("ani_image")
	self.image_name = self:FindVariable("image_name")
	self.fight_power = self:FindVariable("fight_power")
	self.show_image = self:FindVariable("show_image")
	self.act_time = self:FindVariable("count_down")

	self:ListenEvent("ClickButton", BindTool.Bind(self.ClickButton, self))
	self:ListenEvent("ClickLeftButton", BindTool.Bind(self.ClickChangePage, self, "left"))
	self:ListenEvent("ClickRightButton", BindTool.Bind(self.ClickChangePage, self, "right"))
	self:ListenEvent("ClickVip", BindTool.Bind(self.ClickVip, self))
	self:FlushPage()
end

function FestivalLeiChongView:__delete()
	for _, v in pairs(self.cell_list) do
		v:DeleteMe()
	end
	self.cell_list = {}

	if self.model then
		self.model:DeleteMe()
		self.model = nil
	end

	if self.time_quest then
		GlobalTimerQuest:CancelQuest(self.time_quest)
		self.time_quest = nil
	end

	self.jump_page = -1
	self.item_id = 0
end

function FestivalLeiChongView:OpenCallBack()
	self:Flush()

	KaifuActivityCtrl.Instance:SendGetKaifuActivityInfo(FESTIVAL_ACTIVITY_ID.RAND_ACTIVITY_TYPE_VERSIONS_GRAND_TOTAL_CHARGE,
	RA_VERSION_TOTAL_CHARGE_OPERA_TYPE.RA_VERSION_TOTAL_CHARGE_OPERA_TYPE_QUERY_INFO)
end

function FestivalLeiChongView:GetNumberOfCells()
	return #FestivalLeiChongData.Instance:GetVesTotalChargeCfg()
end

function FestivalLeiChongView:RefreshCell(cell, cell_index)
	self.scroller_load_complete = true
	if self.jump_page > 0 then
		self.list_view.list_page_scroll:JumpToPage(self.jump_page)
		self.jump_page = -1
	end
	local data = FestivalLeiChongData.Instance:GetVesTotalChargeCfg()

	local prize_cell = self.cell_list[cell]
	if nil == prize_cell then
		prize_cell = LeiChongItemGroup.New(cell)
		self.cell_list[cell] = prize_cell
	end

	local index = cell_index + 1

	prize_cell:SetIndex(index)
	prize_cell:SetData(data[index])
end

function FestivalLeiChongView:ClickButton()
	local page = self.list_view.list_page_scroll:GetNowPage() or 0
	local max_page = self:GetNumberOfCells()
	local charge_value = FestivalLeiChongData.Instance:GetChargeValue()
	local cfg = FestivalLeiChongData.Instance:GetVesTotalChargeCfg()

	if charge_value >= cfg[page + 1].need_chognzhi then
		KaifuActivityCtrl.Instance:SendGetKaifuActivityInfo(FESTIVAL_ACTIVITY_ID.RAND_ACTIVITY_TYPE_VERSIONS_GRAND_TOTAL_CHARGE,
		RA_VERSION_TOTAL_CHARGE_OPERA_TYPE.RA_VERSION_TOTAL_CHARGE_OPERA_TYPE_FETCH_REWARD, page)

		page = page + 1
		if page > max_page then
			return
		end
		self.list_view.list_page_scroll:JumpToPage(page)
	else
		 VipData.Instance:SetOpenType(OPEN_VIP_RECHARGE_TYPE.RECHANRGE)
		 ViewManager.Instance:Open(ViewName.VipView)
	end
end

function FestivalLeiChongView:ClickVip()
	VipData.Instance:SetOpenType(OPEN_VIP_RECHARGE_TYPE.RECHANRGE)
	ViewManager.Instance:Open(ViewName.VipView)
end

function FestivalLeiChongView:FlushPage()
	if not self.list_view.scroller.isActiveAndEnabled then
		return
	end
	self:FlushModule()
	local cfg = FestivalLeiChongData.Instance:GetVesTotalChargeCfg()
	if next(cfg) == nil then return end
	local page = self.list_view.list_page_scroll:GetNowPage() or 0
	local received = FestivalLeiChongData.Instance:GetFetchFlag(page)
	local charge_value = FestivalLeiChongData.Instance:GetChargeValue()
	local max_page = self:GetNumberOfCells()

	self.max_charge_value:SetValue(cfg[page + 1].need_chognzhi)

	self.can_rewards:SetValue(charge_value >= cfg[page + 1].need_chognzhi)
	self.received:SetValue(received == 1)

	self.left_button:SetValue(page > 0)
	self.right_button:SetValue(page < max_page - 1)
end

function FestivalLeiChongView:ClickChangePage(dir)
	local page = self.list_view.list_page_scroll:GetNowPage()

	if dir == "left" then
		page = page - 1
	else
		page = page + 1
	end

	self.list_view.list_page_scroll:JumpToPage(page)
end

function FestivalLeiChongView:OnFlush()
	local cfg = FestivalLeiChongData.Instance:GetVesTotalChargeCfg()
	if next(cfg) == nil then
		return
	end

	local page = self.list_view.list_page_scroll:GetNowPage()
	local received = FestivalLeiChongData.Instance:GetFetchFlag(page)
	local charge_value = FestivalLeiChongData.Instance:GetChargeValue()
	local jump_page = 0

	self.charge_value:SetValue(charge_value)
	self.can_rewards:SetValue(charge_value >= cfg[page + 1].need_chognzhi)
	self.received:SetValue(received == 1)

	for k, v in pairs(cfg) do
		if charge_value >= v.need_chognzhi and FestivalLeiChongData.Instance:GetFetchFlag(v.seq) == 0 then
			jump_page = v.seq or 0
			break
		elseif charge_value < v.need_chognzhi then
			jump_page = v.seq or 0
			break
		end
	end

	if self.list_view.scroller.isActiveAndEnabled and self.scroller_load_complete then
		self.list_view.list_page_scroll:JumpToPage(jump_page)
	else
		self.jump_page = jump_page
	end

	if self.list_view.scroller.isActiveAndEnabled then
		self.list_view.scroller:ReloadData(0)
	end

	if self.time_quest == nil then
		self.time_quest = GlobalTimerQuest:AddRunQuest(BindTool.Bind(self.SetTime, self), 1)
		self:SetTime()
	end
end

function FestivalLeiChongView:SetTime()
	local time = ActivityData.Instance:GetActivityResidueTime(FESTIVAL_ACTIVITY_ID.RAND_ACTIVITY_TYPE_VERSIONS_GRAND_TOTAL_CHARGE)
	if time <= 0 then
		if self.time_quest then
			GlobalTimerQuest:CancelQuest(self.time_quest)
			self.time_quest = nil
		end
	end
	if time > 3600 * 24 then
		self.act_time:SetValue(TimeUtil.FormatSecond(time, 7))
	elseif time > 3600 then
		self.act_time:SetValue(TimeUtil.FormatSecond(time, 1))
	else
		self.act_time:SetValue(TimeUtil.FormatSecond(time, 4))
	end
end

function FestivalLeiChongView:FlushModule()
	local page = self.list_view.list_page_scroll:GetNowPage()
	local cfg = FestivalLeiChongData.Instance:GetVesTotalChargeCfg()
	if self.item_id == cfg[page + 1].res_id then
		return
	end
	self.item_id = cfg[page + 1].res_id
	local index = HeadFrameData.Instance:GetPrefabByItemId(self.item_id)
	local item_cfg = ItemData.Instance:GetItemConfig(self.item_id)
	local name = ToColorStr(item_cfg.name, TEXT_COLOR.YELLOW)
	self.image_name:SetValue(name)
	if item_cfg.is_display_role == DISPLAY_TYPE.HEAD_FRAME then
		self.show_image:SetValue(true)

		self.ani_image:SetAsset(ResPath.GetHeadFrameIcon(index))
		self.fight_power:SetValue(cfg[page + 1].power)
	else
		self.show_image:SetValue(false)
		local res_id = ItemData.ChangeModel(self.model, self.item_id)
		self.fight_power:SetValue(cfg[page + 1].power)
		ItemData.SetModelName(self.model, item_cfg.is_display_role, res_id)
	end
end

-----------------------------LeiChongItemGroup--------------------------
LeiChongItemGroup = LeiChongItemGroup or BaseClass(BaseCell)

function LeiChongItemGroup:__init()
	self.cell_list = {}

	for i = 1, 4 do
		local item_cell = ItemCell.New()
		item_cell:SetInstanceParent(self:FindObj("Item"..i))
		self.cell_list[i] = item_cell
	end
end

function LeiChongItemGroup:__delete()
	for k, v in ipairs(self.cell_list) do
		v:DeleteMe()
	end
	self.cell_list = {}
end

function LeiChongItemGroup:OnFlush()
	local item_group = ItemData.Instance:GetGiftItemList(self.data.reward_item[0].item_id)

	for i = 1, #self.cell_list do
		self.cell_list[i]:SetData(item_group[i])
		self.cell_list[i]:SetItemActive(item_group[i] ~= nil)
	end
end