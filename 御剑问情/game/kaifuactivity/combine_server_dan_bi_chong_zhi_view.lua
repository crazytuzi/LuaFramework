CombineServerDanBiChongZhi =  CombineServerDanBiChongZhi or BaseClass(BaseRender)

function CombineServerDanBiChongZhi:__init()
	self.contain_cell_list = {}
end

function CombineServerDanBiChongZhi:__delete()
	if self.least_time_timer then
		CountDown.Instance:RemoveCountDown(self.least_time_timer)
        self.least_time_timer = nil
	end
	
	self.list_view = nil
	self.rest_time = nil
	self.contain_cell_list = nil
end

function CombineServerDanBiChongZhi:OpenCallBack()
	HefuActivityCtrl.Instance:SendCSAQueryActivityInfo()
	HefuActivityCtrl.Instance:SendCSARoleOperaReq(COMBINE_SERVER_ACTIVITY_SUB_TYPE.CSA_SUB_TYPE_INVALID)
    
    self.list_view = self:FindObj("ListView")
	local list_delegate = self.list_view.list_simple_delegate
	list_delegate.NumberOfCellsDel = BindTool.Bind(self.GetNumberOfCells, self)
	list_delegate.CellRefreshDel = BindTool.Bind(self.RefreshCell, self)

	self.rest_time = self:FindVariable("rest_time")
	if self.least_time_timer then
		CountDown.Instance:RemoveCountDown(self.least_time_timer)
        self.least_time_timer = nil
	end
	local rest_time = HefuActivityData.Instance:GetCombineActTimeLeft(COMBINE_SERVER_ACTIVITY_SUB_TYPE.CSA_SUB_TYPE_SINGLE_CHARGE)
	self:SetTime(rest_time)
	self.least_time_timer = CountDown.Instance:AddCountDown(rest_time, 1, function ()
			rest_time = rest_time - 1
            self:SetTime(rest_time)
        end)

	self.reward_list = HefuActivityData.Instance:GetSingleChargeCfg()
end

function CombineServerDanBiChongZhi:CloseCallBack()
	if self.least_time_timer then
        CountDown.Instance:RemoveCountDown(self.least_time_timer)
        self.least_time_timer = nil
    end
end

function CombineServerDanBiChongZhi:OnFlush()
	-- self.reward_list = KaifuActivityData.Instance:GetOpenActCombineServerDanBiChongZhiRewardCfg()
	-- if self.list_view then
	-- 	self.list_view.scroller:ReloadData(0)
	-- end
end


function CombineServerDanBiChongZhi:SetTime(rest_time)
	local time_tab = TimeUtil.Format2TableDHMS(rest_time)
	local temp = {}
	for k,v in pairs(time_tab) do
		if k ~= "day" then
			if v < 10 then
				v = tostring('0'..v)
			end
		end
		temp[k] = v
	end
	local str = string.format(Language.Activity.ChongZhiRankRestTime, temp.day, temp.hour, temp.min, temp.s)
	self.rest_time:SetValue(str)
end

function CombineServerDanBiChongZhi:GetNumberOfCells()
	return #self.reward_list
end

function CombineServerDanBiChongZhi:RefreshCell(cell, cell_index)
	local contain_cell = self.contain_cell_list[cell]
	if contain_cell == nil then
		contain_cell = CombineServerDanBiChongZhiCell.New(cell.gameObject, self)
		self.contain_cell_list[cell] = contain_cell
	end

	cell_index = cell_index + 1
	contain_cell:SetData(self.reward_list[cell_index])
	contain_cell:Flush()
end

----------------------------CombineServerDanBiChongZhiCell---------------------------------
CombineServerDanBiChongZhiCell = CombineServerDanBiChongZhiCell or BaseClass(BaseCell)

function CombineServerDanBiChongZhiCell:__init()
	self.show_interactable = self:FindVariable("show_interactable")
	self.show_text = self:FindVariable("show_text")
	self.total_consume_tip = self:FindVariable("total_consume_tip")
	self.show_icon = self:FindVariable("show_icon")
	self.item_cell_obj_list = {}
	self.item_cell_list = {}

	self:ListenEvent("OnClickGet", BindTool.Bind(self.OnClickGet, self))

	for i = 1, 4 do
		self.item_cell_obj_list[i] = self:FindObj("item_"..i)
		local item_cell = ItemCell.New()
		self.item_cell_list[i] = item_cell
		item_cell:SetInstanceParent(self.item_cell_obj_list[i])
	end

end

function CombineServerDanBiChongZhiCell:__delete()
	self.show_text = nil
	self.show_interactable = nil
	self.total_consume_tip = nil
	self.can_lingqu = nil
	self.self.show_icon = nil
	self.item_cell_obj_list = {}
	for k,v in pairs(self.item_cell_list) do
		v:DeleteMe()
	end
	self.item_cell_list = {}
end

function CombineServerDanBiChongZhiCell:OnFlush()
	if self.data == nil then return end
	self.show_icon:SetValue(true)

	self.total_consume_tip:SetValue(string.format(Language.HefuActivity.DanBiChongZhiTips,self.data.charge_value))

	local item_list = ItemData.Instance:GetGiftItemList(self.data.reward_item.item_id)
	
	if #item_list == 0 then
		item_list[1] = self.data.reward_item
	end

	for i = 1, 4 do
		if item_list[i] then
			self.item_cell_list[i]:SetData(item_list[i])
			self.item_cell_obj_list[i]:SetActive(true)
		else
			self.item_cell_obj_list[i]:SetActive(false)
		end
	end

	self.show_text:SetValue(Language.Common.Recharge)
	self.show_interactable:SetValue(true)
end

function CombineServerDanBiChongZhiCell:OnClickGet()
	VipData.Instance:SetOpenType(OPEN_VIP_RECHARGE_TYPE.RECHANRGE)
  	ViewManager.Instance:Open(ViewName.VipView)
end