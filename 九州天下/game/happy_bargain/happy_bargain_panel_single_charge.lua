HappyBargainPanelSingleCharge = HappyBargainPanelSingleCharge or BaseClass(BaseRender)

function HappyBargainPanelSingleCharge:__init()
	self.contain_cell_list = {}
	self.reward_list = {}
end

function HappyBargainPanelSingleCharge:__delete()
	for k, v in pairs(self.contain_cell_list) do
		v:DeleteMe()
		v = nil
	end
	self.contain_cell_list = {}
	self.reward_list = {}
end

function HappyBargainPanelSingleCharge:LoadCallBack()
	self:TableSort()
	self.list_view = self:FindObj("ListView")
	local list_delegate = self.list_view.list_simple_delegate
	list_delegate.NumberOfCellsDel = BindTool.Bind(self.GetNumberOfCells, self)
	list_delegate.CellRefreshDel = BindTool.Bind(self.RefreshCell, self)
	local rest_time = HappyBargainData.Instance:GetActEndTime(ACTIVITY_TYPE.RAND_ACTIVITY_TYPE_SINGLE_CHARGE_REWARD)
	self.rest_time = self:FindVariable("rest_time")
	if self.least_time_timer then
		CountDown.Instance:RemoveCountDown(self.least_time_timer)
        self.least_time_timer = nil
	end
	self:SetTime(rest_time)
	self.least_time_timer = CountDown.Instance:AddCountDown(rest_time, 1, function ()
			rest_time = rest_time - 1
            self:SetTime(rest_time)
        end)
	self:ListenEvent("ClickReChange", BindTool.Bind(self.ClickReChange, self))
end

function HappyBargainPanelSingleCharge:TableSort()
	local list = HappyBargainData.Instance:GetSingleRewardinfo(ACTIVITY_TYPE.RAND_ACTIVITY_TYPE_SINGLE_CHARGE_REWARD) 
	if list == nil then return end
	local danbi_reward_getnum = HappyBargainData.Instance:GetSingleChargeInfo()
	local shield = HappyBargainData.Instance:GetDrawResultLists()
	self.reward_list = {}
	for i,v in ipairs(list) do
		local data = TableCopy(v)
		data.sort = 1
		if data and danbi_reward_getnum[data.index + 1] and (shield ~= nil and v.charge_count < shield) then
			local reward_num = danbi_reward_getnum[data.index + 1]
			data.prize_times = danbi_reward_getnum[data.index + 1].prize_times
		    data.reward_run_out_flag = danbi_reward_getnum[data.index + 1].reward_run_out_flag
			if reward_num.reward_run_out_flag == 0 then 
				data.sort = 0
			elseif reward_num.prize_times == 0 then
				data.sort = 2
			else
				data.sort = 1
			end
		end
		table.insert(self.reward_list, data)
	end
	table.sort(self.reward_list, SortTools.KeyLowerSorters("sort", "index") )
end

function HappyBargainPanelSingleCharge:CloseCallBack()
	if self.least_time_timer then
        CountDown.Instance:RemoveCountDown(self.least_time_timer)
        self.least_time_timer = nil
    end
end

function HappyBargainPanelSingleCharge:ClickReChange()
	VipData.Instance:SetOpenType(OPEN_VIP_RECHARGE_TYPE.RECHANRGE)
	ViewManager.Instance:Open(ViewName.VipView)
end

function HappyBargainPanelSingleCharge:GetNumberOfCells()
	return #self.reward_list
end

function HappyBargainPanelSingleCharge:RefreshCell(cell, cell_index)
	local contain_cell = self.contain_cell_list[cell]
	if contain_cell == nil then
		contain_cell = SingleChargeCell.New(cell.gameObject, self)
		self.contain_cell_list[cell] = contain_cell
	end
	contain_cell:SetData(self.reward_list[cell_index + 1])
	contain_cell:Flush()
end

function HappyBargainPanelSingleCharge:SetTime(remaining_second)
 	local time_tab = TimeUtil.Format2TableDHMS(remaining_second)
  	local str = ""
 	if time_tab.day > 0 then
   		remaining_second = remaining_second - 24 * 60 * 60 * time_tab.day
   	end
	str = TimeUtil.FormatSecond(remaining_second)
	if self.rest_time then
	    self.rest_time:SetValue(str)
	end
end

function HappyBargainPanelSingleCharge:OnFlush() 
	if self.list_view then
		self:TableSort()
		self.list_view.scroller:ReloadData(0)
	end
end

------------------------------SingleChargeCell-------------------------------------
SingleChargeCell = SingleChargeCell or BaseClass(BaseCell)
function SingleChargeCell:__init()
	self.tips = self:FindVariable("tips")
	self.tips_2 = self:FindVariable("tips_2")
    self.button_name = self:FindVariable("button_zhongzhi") 
    self.reward_num = self:FindVariable("reward_num")
    self.button_red = self:FindVariable("show_redmind")
    self.button_enable = self:FindVariable("btn_enable")
    self.button_gray = self:FindVariable("btn_gray")

	self.item_cell_obj_list = {}
	self.item_cell_list = {}
	self.item_state_list = {}
	for i = 1, 4 do
		self.item_cell_obj_list[i] = self:FindObj("item_"..i)
		self.item_state_list[i] = self:FindVariable("is_show_"..i)
		self.item_cell_list[i] = ItemCell.New()
		self.item_cell_list[i]:SetInstanceParent(self.item_cell_obj_list[i])
	end

	self:ListenEvent("OnClickGet", BindTool.Bind(self.OnClickGet, self)) 
end

function SingleChargeCell:__delete()
	for k,v in pairs(self.item_cell_list) do
		v:DeleteMe()
	end
	self.item_cell_list = {}
	self.tips = nil
	self.tips_2 = nil
	self.item_cell_obj_list = {}
	self.item_state_list = {}
end

function SingleChargeCell:OnFlush()
	self.data = self:GetData()
	if self.data then
		local reward_gift_id = self.data.reward_item.item_id
		local reward = ItemData.Instance:GetGiftItemList(reward_gift_id)
		for i=1,#self.item_state_list do
			self.item_state_list[i]:SetValue(false)
		end

		local reward_item_list = {}
        for i=1,#reward do
        	reward_item_list[i] = {
            item_id = reward[i].item_id,
            num = reward[i].num,
            is_bind = reward[i].is_bind,
            }
            self.item_state_list[i]:SetValue(true)
        	self.item_cell_list[i]:SetData(reward_item_list[i])
        end
		local str = string.format(Language.Activity.DanBiChongZhiTips, self.data.charge_count)
	    self.tips:SetValue(str)
	    self.tips_2:SetValue(Language.Activity.SingleChargeTips)
	end
    
    if self.data.reward_run_out_flag and self.data.prize_times then
    	local temp_num = self.data.prize_times
        local can_getnum =  self.data.reward_run_out_flag
        local is_show = false
        local bnt_str = ""
        local is_red = false
        if can_getnum == 0 then
    	    bnt_str = Language.Common.LingQu
    	    is_red = true
            is_show = true
        elseif temp_num > 0 then
    	    bnt_str = Language.Activity.ChongZhi
    	    is_red = false
            is_show = true
        else
    	    bnt_str = Language.Common.LingQu
    	    is_red = false
            is_show = false
        end
        self.button_red:SetValue(is_red)
        self.button_name:SetValue(bnt_str)
        self.button_enable:SetValue(is_show)
        self.button_gray:SetValue(is_show)
        local str2 = string.format(Language.Activity.SingleChargeCount,temp_num)
	    self.reward_num:SetValue(str2)
    end  
end

function SingleChargeCell:OnClickGet()
	if self.data.reward_run_out_flag == 1 then
	    VipData.Instance:SetOpenType(OPEN_VIP_RECHARGE_TYPE.RECHANRGE)
	    ViewManager.Instance:Open(ViewName.VipView)
	else
		 KaifuActivityCtrl.Instance:SendGetKaifuActivityInfo(ACTIVITY_TYPE.RAND_ACTIVITY_TYPE_SINGLE_CHARGE_REWARD,RA_SINGLE_CHARGE_PRIZE_OPERA_TYPE.FETCH_REWARD, self.data.index)
	end
end

