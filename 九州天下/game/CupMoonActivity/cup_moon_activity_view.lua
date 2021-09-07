CupMoonActivityView = CupMoonActivityView or BaseClass(BaseView)
function CupMoonActivityView:__init()
	self.ui_config = {"uis/views/cupmoonactivityview", "CupMoonActivityView"} 
	self.contain_cell_list = {}
    self:SetMaskBg()
end  

function CupMoonActivityView:__delete()

end
                   
function CupMoonActivityView:LoadCallBack()
	self.list_view = self:FindObj("ListView")
    self.chongzhi_count = self:FindVariable("chongzhi_count")
    self.rest_time = self:FindVariable("rest_time")

    self.item_name = self:FindVariable("item_name")
    self.item_cap = self:FindVariable("item_cap")

    self.display = self:FindObj("Display")
	self.model = RoleModel.New()
	self.model:SetDisplay(self.display.ui3d_display)

    self:ListenEvent("ClickReChange", BindTool.Bind(self.ClickReChange, self))
	self:ListenEvent("ClickClosebtn", BindTool.Bind(self.Close, self))

	local list_delegate = self.list_view.list_simple_delegate
	list_delegate.NumberOfCellsDel = BindTool.Bind(self.GetNumberOfCells, self)
	list_delegate.CellRefreshDel = BindTool.Bind(self.RefreshCell, self)
end  
 
function CupMoonActivityView:OpenCallBack()   	
   	if self.least_time_timer then
		CountDown.Instance:RemoveCountDown(self.least_time_timer)
        self.least_time_timer = nil
	end
	local rest_time, next_time = ActivityData.Instance:GetActivityResidueTime(ACTIVITY_TYPE.RAND_ACTIVITY_TYPE_MIDAUTUMN_CUP_MOON)
	self.least_time_timer = CountDown.Instance:AddCountDown(rest_time, 1, function ()
			rest_time = rest_time - 1
            self:SetTime(rest_time)
        end)

	self:Flush()
end

function CupMoonActivityView:CloseCallBack()
	if self.least_time_timer then
        CountDown.Instance:RemoveCountDown(self.least_time_timer)
        self.least_time_timer = nil
    end
end

function CupMoonActivityView:OnFlush()
	local leiji_list = CupMoonActivityData.Instance:GetMidAutumnCupInfo()
	self.reward_list = CupMoonActivityData.Instance:GetOpenActTotalChongZhiReward() or {}
	
	if self.list_view and self.list_view.scroller.isActiveAndEnabled then
		self.list_view.scroller:ReloadData(0)
	end

	if self.chongzhi_count then
     	self.chongzhi_count:SetValue(tostring(leiji_list.total_charge_value) or 0)
	end

	if self.reward_list and next(self.reward_list) then
		local path = self.reward_list[1].path
		local scale = self.reward_list[1].scale
		local model_scale = Vector3(scale, scale, scale)
		local name = self.reward_list[1].name1
		self.model:SetMainAsset(path, name)
		self.model:SetModelScale(model_scale)
		self.item_name:SetValue(self.reward_list[1].prop_name)
		self.item_cap:SetValue(self.reward_list[1].prop_price)
	end
end

function CupMoonActivityView:SetTime(rest_time)
	local time_tab = TimeUtil.Format2TableDHMS(rest_time)
	local str = ""
	if time_tab.day > 0 then
		str = TimeUtil.FormatSecond2DHMS(rest_time, 1)
	else
		str = TimeUtil.FormatSecond(rest_time)
	end

	if self.rest_time ~= nil then
		self.rest_time:SetValue(str)
	end
end

function CupMoonActivityView:GetNumberOfCells()
	return self.reward_list and #self.reward_list or 0
end

function CupMoonActivityView:ClickReChange()
	ViewManager.Instance:Open(ViewName.RechargeView)
end

function CupMoonActivityView:ReleaseCallBack()
    self.list_view = nil
	self.rest_time = nil
	self.chongzhi_count = nil
	if self.contain_cell_list then
	    for k, v in pairs(self.contain_cell_list) do
			v:DeleteMe()
    	end
		self.contain_cell_list = {}
	end

	if self.model then
		self.model:DeleteMe()
		self.model = nil
	end
	self.display = nil
	self.item_name = nil
    self.item_cap = nil
end 

function CupMoonActivityView:RefreshCell(cell, cell_index)
	local contain_cell = self.contain_cell_list[cell]
	if contain_cell == nil then
		contain_cell = CupMoonActivityCell.New(cell.gameObject)
		self.contain_cell_list[cell] = contain_cell
	end

	cell_index = cell_index + 1
	contain_cell:SetData(self.reward_list[cell_index])
end
---------------------------- CupMoonActivityCell ---------------------------------
CupMoonActivityCell = CupMoonActivityCell or BaseClass(BaseCell)
function CupMoonActivityCell:__init()
	self.total_value = self:FindVariable("total_value")
	self.cur_value = self:FindVariable("cur_value")
	self.show_interactable = self:FindVariable("show_interactable")
	self.show_text = self:FindVariable("show_text")
	self.total_consume_tip = self:FindVariable("total_consume_tip")
	self.can_lingqu = self:FindVariable("can_lingqu")
	self.show_red = self:FindVariable("show_red")
	self.color = self:FindVariable("color")

	self.item_cell_obj_list = {}
	self.item_cell_list = {}

	self:ListenEvent("OnClickGet", BindTool.Bind(self.OnClickGet, self))

	for i = 1, 5 do
		self.item_cell_obj_list[i] = self:FindObj("item_"..i)
		local item_cell = ItemCell.New()
		self.item_cell_list[i] = item_cell
		item_cell:SetInstanceParent(self.item_cell_obj_list[i])
	end
end

function CupMoonActivityCell:__delete()
	self.total_value = nil
	self.cur_value = nil
	self.show_text = nil
	self.show_interactable = nil
	self.total_consume_tip = nil
	self.can_lingqu = nil
	self.color = nil
	self.item_cell_obj_list = {}

	if self.item_cell_list then
		for k,v in pairs(self.item_cell_list) do
			v:DeleteMe()
		end
		self.item_cell_list = {}
	end
end

function CupMoonActivityCell:OnFlush()
    if self.data == nil and next(self.data) == nil then return end
	local info = CupMoonActivityData.Instance:GetMidAutumnCupInfo() 
	local cur_value = info.total_charge_value
	if cur_value == nil then
		return
	end

	local color = cur_value >= self.data.need_chognzhi and COLOR.GREEN or COLOR.RED
	self.color:SetValue(color)
	self.total_value:SetValue(self.data.need_chognzhi or 0)
	self.cur_value:SetValue(cur_value)
	self.total_consume_tip:SetValue(string.format(Language.Activity.TotalChongZhiTip, self.data.need_chognzhi or 0))
	local reward_list = ServerActivityData.Instance:GetCurrentRandActivityRewardCfg(self.data.reward_item, true) or {}

	for i = 1, 5 do
		if reward_list[i] then
			if self.item_cell_list[i] ~= nil then
				self.item_cell_list[i]:SetData(reward_list[i])
			end
			self.item_cell_obj_list[i]:SetActive(true)
		else
			self.item_cell_obj_list[i]:SetActive(false)
		end
	end

	local reward_has_fetch_flag = self.data.reward_has_fetch_flag == 1
	local str = reward_has_fetch_flag == 1 and Language.Common.YiLingQu or 
	(cur_value >= self.data.need_chognzhi and Language.Common.LingQu or Language.Common.WEIDACHENG)

	self.show_text:SetValue(str)
	self.show_interactable:SetValue(not reward_has_fetch_flag)
	self.can_lingqu:SetValue(reward_has_fetch_flag)

	local red_flag = false
	if info ~= nil and info.total_charge_value ~= nil and self.data.need_chognzhi ~= nil then
		red_flag = info.total_charge_value >= self.data.need_chognzhi
	end
	self.show_red:SetValue(not reward_has_fetch_flag and red_flag)
end

function CupMoonActivityCell:OnClickGet()
	if self.data == nil or next(self.data) == nil then
		return
	end

	local info = CupMoonActivityData.Instance:GetMidAutumnCupInfo()
	local cur_value = info.total_charge_value or 0
	if cur_value >= self.data.need_chognzhi then
		 KaifuActivityCtrl.Instance:SendRandActivityOperaReq(ACTIVITY_TYPE.RAND_ACTIVITY_TYPE_MIDAUTUMN_CUP_MOON, RA_DAILY_TOTAL_CHONGZHI_OPERA_TYPE.RA_DAILY_TOTAL_CHONGZHI_OPERA_TYPE_FETCH_REWARD, self.data.seq)
	else
		TipsCtrl.Instance:ShowSystemMsg(Language.Activity.NewTotalChongZhiTip)
	end
end