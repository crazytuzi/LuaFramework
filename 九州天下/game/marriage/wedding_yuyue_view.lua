WeddingYuYueView = WeddingYuYueView or BaseClass(BaseView)

function WeddingYuYueView:__init()
	self.ui_config = {"uis/views/marriageview","MarryAppointment"}
	self.marry_yuyue_list = {}
	self.select_index = 0

	self:SetMaskBg()
end

function WeddingYuYueView:ReleaseCallBack()
	self.role_name = nil
	self.time_list = nil
	self.lover_name = nil
	self.show_invite = nil
	self.wedding_type = nil
	self.wedding_count = nil

	if self.marry_yuyue_list then
		for k,v in pairs(self.marry_yuyue_list) do
			v:DeleteMe()
		end
	end
	self.marry_yuyue_list = {}

	if self.item_list then
		for k,v in pairs(self.item_list) do
			v:DeleteMe()
		end
		self.item_list = {}
	end
end

function WeddingYuYueView:LoadCallBack()
	self.role_name = self:FindVariable("role_name")
	self.lover_name = self:FindVariable("lover_name")
	self.show_invite = self:FindVariable("show_invite")
	self.wedding_type = self:FindVariable("wedding_type")
	self.wedding_count = self:FindVariable("wedding_count")

	self.time_list = self:FindObj("ListView")
	local list_delegate = self.time_list.list_simple_delegate
	list_delegate.NumberOfCellsDel = BindTool.Bind(self.GetNumberOfCells, self)
	list_delegate.CellRefreshDel = BindTool.Bind(self.RefreshTimeListView, self)

	self.item_list = {}
	for i = 1, 4 do
		local item = ItemCell.New()
		item:SetInstanceParent(self:FindObj("ItemCell_" .. i))
		item:SetData(nil)
		table.insert(self.item_list, item)
	end

	self:ListenEvent("Close",BindTool.Bind(self.OnClickClose, self))
	self:ListenEvent("OnClick",BindTool.Bind(self.OnClickYuYue, self))
	self:ListenEvent("OnInvite",BindTool.Bind(self.OnClickInvite, self))
	self:ListenEvent("OnDesc",BindTool.Bind(self.OnClickDesc, self))
	self:Flush()
end

function WeddingYuYueView:GetNumberOfCells()
	return #MarriageData.Instance:GetMarryYuYueCfg() or 0
end

--刷新ListView
function WeddingYuYueView:RefreshTimeListView(cell, data_index)
	data_index = data_index + 1
	local yuyue_cell = self.marry_yuyue_list[cell]
    if yuyue_cell == nil then
        yuyue_cell = AppointmentItemCell.New(cell.gameObject)
        yuyue_cell.root_node.toggle.group = self.time_list.toggle_group
        yuyue_cell:SetClickCallBack(BindTool.Bind(self.OnClickItemCallBack, self))
        self.marry_yuyue_list[cell] = yuyue_cell
    end

    self.item_data = MarriageData.Instance:GetMarryYuYueCfg()
    yuyue_cell:SetIndex(data_index)
    yuyue_cell:SetData(self.item_data[data_index])
end

function WeddingYuYueView:OpenCallBack()
	self:Flush()
end

function WeddingYuYueView:OnClickClose()
	self:Close()
end

function WeddingYuYueView:OnClickItemCallBack(cell, select_index)
	if cell == nil or cell.data == nil then return end
	self.select_index = cell.data.seq
	MarriageData.Instance:SetMarryTimeSeq(self.select_index)
	for k, v in pairs(self.marry_yuyue_list) do
		v:ChangeHightLight()
	end
end

function WeddingYuYueView:OnClickYuYue()
	local main_role_vo = GameVoManager.Instance:GetMainRoleVo()
	local is_online = ScoietyData.Instance:GetFriendIsOnlineById(main_role_vo.lover_uid)
	if 1 == is_online then
		SysMsgCtrl.Instance:ErrorRemind(Language.Marriage.WaitYuYue)
	end
	MarriageCtrl.Instance:SendQingYuanOperate(QINGYUAN_OPERA_TYPE.QINGYUAN_OPERA_TYPE_WEDDING_YUYUE, self.select_index, MarriageData.Instance:GetSelectYanHuiType())
end

function WeddingYuYueView:OnClickInvite()
	ViewManager.Instance:Open(ViewName.WeddingInviteView)
end

function WeddingYuYueView:OnClickDesc()
	local tips_id = 216
    TipsCtrl.Instance:ShowHelpTipView(tips_id)
end

function WeddingYuYueView:OnFlush(param_list)
	for k,v in pairs(param_list) do
		if k == "my_yuyue" and self.time_list then
			self.time_list.scroller:ReloadData(0)
		end
	end
	local my_name = PlayerData.Instance.role_vo
	local reward_item_list = MarriageData.Instance:GetRewardItemData(MarriageData.Instance:GetSelectYanHuiType())
	local role_msg_info = MarriageData.Instance:GetYuYueRoleInfo()

	if self.role_name and self.lover_name and self.wedding_count and my_name and self.show_invite and self.wedding_type then
		self.role_name:SetValue(my_name.name)
		self.lover_name:SetValue(my_name.lover_name)
		self.show_invite:SetValue(role_msg_info.param_ch4 >= 0)
		self.wedding_count:SetValue(role_msg_info.marry_count)
		self.wedding_type:SetValue(MarriageData.Instance:GetSelectYanHuiType())
	end

	if reward_item_list == nil or next(reward_item_list) == nil then return end
	for k, v in pairs(reward_item_list) do
		if self.item_list[k+1] then
			self.item_list[k+1]:SetData(v)
		end
	end
end


----------AppointmentItemCell	婚宴预约时间段
AppointmentItemCell = AppointmentItemCell or BaseClass(BaseCell)

function AppointmentItemCell:__init()
	self.time = self:FindVariable("time")
	self.cur_state = self:FindVariable("cur_state")
	self.is_show_heart = self:FindVariable("is_show_heart")
	self.is_show_light = self:FindVariable("IsShowLight")

	self:ListenEvent("ClickItem", BindTool.Bind(self.OnClickItem, self))
end

function AppointmentItemCell:OnClickItem()
	if nil ~= self.click_callback then
		self.click_callback(self)
	end
end

function AppointmentItemCell:__delete()
	self.time = nil
	self.cur_state = nil
	self.is_show_heart = nil
end

function AppointmentItemCell:OnFlush()
	if not self.data then return end

	self.is_show_heart:SetValue(false)
	local begin1, begin2 = math.modf(self.data.begin_time / 100)
	local end1, end2 = math.modf(self.data.end_time / 100)
	local begin_time = begin1 .. ":" .. begin2 * 100
	local end_time = end1 .. ":" .. end2 * 100
	self.time:SetValue(begin_time .. "0-" .. end_time)

	local time_table = os.date("*t", TimeCtrl.Instance:GetServerTime())
	local h = math.floor(self.data.apply_time / 100)
	local m = self.data.apply_time % 100
	local yuyue_time = os.time({year=time_table.year, month=time_table.month, day=time_table.day, hour=h, min=m, sec=0})

	local role_msg_info = MarriageData.Instance:GetYuYueRoleInfo()
	if self.data.is_yuyue == 1 then
		if TimeCtrl.Instance:GetServerTime() > yuyue_time then
			self.cur_state:SetValue(Language.Marriage.YuYueTips)
		else
			self.cur_state:SetValue(Language.Marriage.YiYuYue)
		end
		if self.data.seq == role_msg_info.param_ch4 then
			self.cur_state:SetValue(Language.Marriage.MyYuYueTips)
			self.is_show_heart:SetValue(true)
		end
	else
		if TimeCtrl.Instance:GetServerTime() > yuyue_time then
			self.cur_state:SetValue(Language.Marriage.YuYueTips)
		else
			self.cur_state:SetValue(Language.Marriage.CanYuYue)
		end
	end
	self:ChangeHightLight()
end

function AppointmentItemCell:ChangeHightLight()
	self.is_show_light:SetValue(self.data.seq == MarriageData.Instance:GetMarryTimeSeq())
end