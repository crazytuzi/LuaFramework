HappyBargainView = HappyBargainView or BaseClass(BaseView)

function HappyBargainView:__init()
	self.ui_config = {"uis/views/happybargainview", "HappyBargainView"}
	self.play_audio = true
	self:SetMaskBg()
	self.is_async_load = false
	self.is_check_reduce_mem = true
	self.cur_index = 1
	self.cell_list = {}
	self.panel_list = {}
	-- self.remind_change = BindTool.Bind(self.RemindChangeCallBack, self)
	self.cur_tab_list_length = 0
	self.chu_jun_info_data = {}
	self.list_percent = 0

end

function HappyBargainView:__delete()
end

function HappyBargainView:ReleaseCallBack()
	self.cur_type = nil
	self.cur_index = 1
	self.last_type = 0
	self.cur_day = nil
	self.right_combine_content = nil
	self.title_img = nil

	for k, v in pairs(self.panel_list) do
		v:DeleteMe()
	end
	self.panel_list = {}

	for k, v in pairs(self.cell_list) do
		v:DeleteMe()
	end

	self.cell_list = {}
	
	if RemindManager.Instance then
		RemindManager.Instance:UnBind(self.remind_change)
	end

	self.panel_obj_list = nil
	self.tab_list = nil
end

function HappyBargainView:LoadCallBack()
	self:ListenEvent("Close", BindTool.Bind(self.OnClickClose, self))

	self.panel_obj_list = {
		self:FindObj("PanelDayTarget"),
		self:FindObj("PanelSingleCharge"),
		self:FindObj("PanelHappyLottery"),
		self:FindObj("PanelRebate"),
		self:FindObj("PanelChongZhiRank"),
	}

	self.panel_list = {
		[1] = HappyBargainPanelDayTarget.New(),
		[2] = HappyBargainPanelSingleCharge.New(),
		[3] = HappyLottery.New(),
		[4] = HappyBargainPanelRebate.New(),
		[5] = HappyBargainChongZhiRankView.New(),

	}

	for k,v in pairs(self.panel_list) do
		local content_obj = self.panel_obj_list[k]
		content_obj.uiprefab_loader:Wait(function(obj)
			obj = U3DObject(obj)
			v:SetInstance(obj)
		end)
	end

	self.tab_list = self:FindObj("ToggleList")
	local list_delegate = self.tab_list.list_simple_delegate
	list_delegate.NumberOfCellsDel = BindTool.Bind(self.GetNumberOfCells, self)
	list_delegate.CellRefreshDel = BindTool.Bind(self.RefreshCell, self)
	self.title_img = self:FindVariable("title_asset")
	
	self:SetTitleImg()
	self:Flush()
end

function HappyBargainView:SetTitleImg()
	local img_name = "title_"
	local opengame_day = TimeCtrl.Instance:GetCurOpenServerDay()

	if opengame_day ~= nil and opengame_day >= 8 and opengame_day <= 14 then
		img_name = img_name .. opengame_day
	else
		return
	end

	self.title_img:SetAsset("uis/views/happybargainview/images_atlas", img_name)
end

function HappyBargainView:GetNumberOfCells()
	self.cur_tab_list_length = #HappyBargainData.Instance:GetOpenActivityList()
	return #HappyBargainData.Instance:GetOpenActivityList()
end

function HappyBargainView:RefreshCell(cell, data_index)
	local list = HappyBargainData.Instance:GetOpenActivityList()
	if not list or not next(list) then return end
	local activity_type = list[data_index + 1] and list[data_index + 1].activity_type or 0
	local activity_info = KaifuActivityData.Instance:GetActivityInfo(activity_type)
	local data = {}
	data.activity_type = activity_type
	local tab_btn = self.cell_list[cell]
	if tab_btn == nil then
		tab_btn = HappyLeftTableButton.New(cell.gameObject)
		self.cell_list[cell] = tab_btn
	end
	tab_btn:SetToggleGroup(self.tab_list.toggle_group)
	tab_btn:SetHighLight(self.cur_type == activity_type)
	tab_btn:ListenClick(BindTool.Bind(self.OnClickTabButton, self, activity_type, data_index + 1, tab_btn))

	data.is_show = false
	data.is_show_effect = false

	if activity_type == ACTIVITY_TYPE.RAND_ACTIVITY_TYPE_DAY_TARGET then
		data.is_show = HappyBargainData.Instance:DayTargetGetRemind() > 0
	end

	if activity_type == ACTIVITY_TYPE.RAND_ACTIVITY_TYPE_SINGLE_CHARGE_REWARD then
		data.is_show = HappyBargainData.Instance:GetSinglChargeRemind() > 0
	end

	if activity_type == ACTIVITY_TYPE.RAND_ACTIVITY_TYPE_HAPPY_LOTTERY then
		data.is_show = HappyBargainData.Instance:GetHappyLotteryRemind() > 0
	end

	if activity_type == ACTIVITY_TYPE.RAND_ACTIVITY_TYPE_REBATE_ACTIVITY then
		data.is_show = HappyBargainData.Instance:GetRebateActRedPoint() > 0
	end

	data.name = list[data_index + 1].act_name
	data.index = data_index
	tab_btn:SetData(data)
end

function HappyBargainView:OnClickClose()
	self:Close()
end

function HappyBargainView:OnClickTabButton(activity_type, index, tab_btn)
	tab_btn:SetHighLight(true)
	if self.cur_type == activity_type then
		return
	end
	self.last_type = self.cur_type
	self.cur_type = activity_type
	self.cur_index = index
	-- self:CloseChildPanel()
	self:Flush()
end

function HappyBargainView:ShowIndexCallBack(index)
	if index > 100000 then
		self.cur_type = index - 100000
		local list = HappyBargainData.Instance:GetOpenActivityList()
		for k,v in pairs(list) do
			if v.activity_type == self.cur_type then
				self.cur_index = k
			end
		end
	end
end

function HappyBargainView:OpenCallBack()
	local list = HappyBargainData.Instance:GetOpenActivityList()
	if list and next(list) then
		self.cur_type = self.cur_type or list[self.cur_index].activity_type
		for k, v in pairs(list) do
			KaifuActivityCtrl.Instance:SendGetKaifuActivityInfo(v.activity_type, RA_OPEN_SERVER_OPERA_TYPE.RA_OPEN_SERVER_OPERA_TYPE_REQ_INFO)
		end
	end
	self:Flush()
end

function HappyBargainView:CloseCallBack()
	self.last_type = self.cur_type
	self.cur_index = 1
	self.cur_type = nil
	self.cur_tab_list_length = 0
end

function HappyBargainView:OnFlush(param_t)
	for k,v in pairs(param_t) do
		if k == "all" then
			local list = HappyBargainData.Instance:GetOpenActivityList()
			if list and next(list) then
				self:FlushLeftTabListView(list)
			end
		end
		if k == "chongzhi" then
			if self.panel_list[5]:IsOpen() then
				self.panel_list[5]:FlushChongZhi()
			end
		end
	end
end

function HappyBargainView:FlushLeftTabListView(list)
	if list == nil or next(list) == nil then return end

	if self.tab_list.scroller.isActiveAndEnabled then
		if self.list_percent > 0 then
			self.tab_list.scroller:ReloadData(self.list_percent)
			self.list_percent = 0
		elseif self.cur_day ~= TimeCtrl.Instance:GetCurOpenServerDay() or self.cur_tab_list_length ~= #list then
			if not list[self.cur_index] or (self.cur_type ~= list[self.cur_index].activity_type) then
				self.cur_index = 1
				self.cur_type = nil
			end
			self.tab_list.scroller:ReloadData(0)
		else
			self.tab_list.scroller:RefreshActiveCellViews()
		end
	end
	self.cur_day = TimeCtrl.Instance:GetCurOpenServerDay()

	self:FlushPanel(list)
end

function HappyBargainView:FlushPanel(list)
	self.cur_type = self.cur_type or list[self.cur_index].activity_type

	local panel_index = HappyBargainData.Instance:GetPanelIndex(self.cur_type)
	for k, v in pairs(self.panel_obj_list) do
		v:SetActive(false)
		if panel_index and panel_index == k then
			v:SetActive(true)
		end
	end
	if self.panel_list[panel_index] then
		self.panel_list[panel_index]:Flush()
	end
end

HappyLeftTableButton = HappyLeftTableButton or BaseClass(BaseRender)

function HappyLeftTableButton:__init(instance)
	self.name = self:FindVariable("Name")
	self.show_red_point = self:FindVariable("ShowRedPoint")
	self.show_effect = self:FindVariable("ShowEffect")
	self.show_red_bg = self:FindVariable("ShowRedBG")
	self.select_path = self:FindVariable("select_path")
	self.normal_path = self:FindVariable("normal_path")
	self.normal_img = self:FindObj("normal_img")
	self.high_light_img = self:FindObj("high_light_img")
	self.data = nil
end

function HappyLeftTableButton:SetData(data)
	if not data then return end
	self.data = data
	self:Flush()
end

function HappyLeftTableButton:OnFlush()
	local data = self.data
	if data == nil then return end
	self.name:SetValue(data.name)
	self.show_red_point:SetValue(data.is_show)
	self.show_effect:SetValue(data.is_show_effect)
	self.show_red_bg:SetValue(data.is_show_effect)
	self.select_path:SetAsset(ResPath.GetHappyBargainActivityRes("tab_select_" .. data.activity_type))
	self.normal_path:SetAsset(ResPath.GetHappyBargainActivityRes("tab_" .. data.activity_type))

	if self.high_light_img ~= nil then
		local bundle, asset = ResPath.GetHappyBargainActivityRes("tab_select_" .. data.index)
	end

	if self.normal_img ~= nil then
		local bundle, asset = ResPath.GetHappyBargainActivityRes("tab_" .. data.index)
	end
end

function HappyLeftTableButton:SetToggleGroup(toggle_group)
	self.root_node.toggle.group = toggle_group
end

function HappyLeftTableButton:ListenClick(handler)
	self:ClearEvent("click")
	self:ListenEvent("click", handler)
end

function HappyLeftTableButton:SetHighLight(enable)
	self.root_node.toggle.isOn = enable

	self.high_light_img:SetActive(enable)
	self.normal_img:SetActive(not enable)
end
