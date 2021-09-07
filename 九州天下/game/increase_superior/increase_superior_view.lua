IncreaseSuperiorView = IncreaseSuperiorView or BaseClass(BaseView)

function IncreaseSuperiorView:__init()
	self.ui_config = {"uis/views/increasesuperior", "IncreaseSuperior"}
	self:SetMaskBg(true)
	self.contain_cell_list = {}
end

function IncreaseSuperiorView:__delete()
	-- body
end

function IncreaseSuperiorView:LoadCallBack()
	self:ListenEvent("CloseView", handler or BindTool.Bind(self.CloseView, self))

	self.list_view = self:FindObj("ListView")
	local list_delegate = self.list_view.list_simple_delegate
	list_delegate.NumberOfCellsDel = BindTool.Bind(self.GetNumberOfCells, self)
	list_delegate.CellRefreshDel = BindTool.Bind(self.RefreshCell, self)

	self.res_time = self:FindVariable("res_time")

	self.reward_list = IncreaseSuperiorData.Instance:GetRewardListDataByDay()
	self.coset_list =  IncreaseSuperiorData.Instance:GetCostListByDay()
end

-- 销毁前调用
function IncreaseSuperiorView:ReleaseCallBack()
	self.list_view = nil
	self.res_time = nil

	for k,v in pairs(self.contain_cell_list) do
		v:DeleteMe()
	end
	self.contain_cell_list = {}
end

function IncreaseSuperiorView:OpenCallBack()
	if self.least_time_timer then
        CountDown.Instance:RemoveCountDown(self.least_time_timer)
        self.least_time_timer = nil
    end
    local time = IncreaseSuperiorData.Instance:GetRestTime()
    if nil ~= time then
	    self:SetTime(time)
	    self.least_time_timer = CountDown.Instance:AddCountDown(time, 1, function ()
				time = time - 1
	            self:SetTime(time)
	        end)
	end
end

-- 关闭前调用
function IncreaseSuperiorView:CloseCallBack()
	if self.least_time_timer then
        CountDown.Instance:RemoveCountDown(self.least_time_timer)
        self.least_time_timer = nil
    end
end

function IncreaseSuperiorView:SetTime(time)
	time_tab = TimeUtil.Format2TableDHMS(time)
	local str = string.format(Language.LuckyDraw.LastTime, time_tab.day, time_tab.hour, time_tab.min)
	self.res_time:SetValue(str)
end

-- 刷新
function IncreaseSuperiorView:OnFlush(param_list)
	-- override
end

function IncreaseSuperiorView:GetNumberOfCells()
	return #self.reward_list
end

function IncreaseSuperiorView:RefreshCell(cell, cell_index)
	local contain_cell = self.contain_cell_list[cell]
	if contain_cell == nil then
		contain_cell = IncreaseSuperiorCell.New(cell.gameObject, self)
		self.contain_cell_list[cell] = contain_cell
	end
	cell_index = cell_index + 1
	contain_cell:SetItemData(self.reward_list[cell_index])
	contain_cell:SetCost(self.coset_list[cell_index])
	contain_cell:Flush()
end

function IncreaseSuperiorView:CloseView()
	self:Close()
end

----------------------------IncreaseSuperiorCell---------------------------------
IncreaseSuperiorCell = IncreaseSuperiorCell or BaseClass(BaseCell)

function IncreaseSuperiorCell:__init()
	self.reward_data = {}
	self.item_cell_list = {}
	self.tips_text = self:FindVariable("tips")
	self:ListenEvent("OnClickChongZhi", handler or BindTool.Bind(self.OnClickChongZhi, self))
	for i=1,4 do
		self.item_cell_list[i] = ItemCell.New()
		self.item_cell_list[i]:SetInstanceParent(self:FindObj("item_"..i))
	end
end

function IncreaseSuperiorCell:__delete()
	self.item_cell_obj = nil
	self.tips_text = nil

	for k,v in pairs(self.item_cell_list) do
		v:DeleteMe()
	end
	self.item_cell_list = {}
end

function IncreaseSuperiorCell:SetItemData(data)
	if data then
		local item_data_list = {}
		self.reward_data = data
		local item_data = ItemData.Instance:GetItemConfig(self.reward_data.item_id)
		for i=1,4 do
			item_data_list[i] = {}
			item_data_list[i].item_id = item_data["item_"..i.."_id"]
			item_data_list[i].num = item_data["item_"..i.."_num"]
			item_data_list[i].is_bind = item_data["is_bind_"..i]
			self.item_cell_list[i]:SetData(item_data_list[i])
			if not next(item_data_list[i]) then
				self.item_cell_list[i]:SetItemActive(false)
			else
				self.item_cell_list[i]:SetItemActive(true)
			end
		end
	end
end

function IncreaseSuperiorCell:SetCost(num)
	self.cost_count = num
end

function IncreaseSuperiorCell:OnFlush()
	local str = string.format(Language.IncreaseCapablity.Tips, self.cost_count)
	self.tips_text:SetValue(str)
end

function IncreaseSuperiorCell:OnClickChongZhi()
	VipData.Instance:SetOpenType(OPEN_VIP_RECHARGE_TYPE.RECHANRGE)
	ViewManager.Instance:Open(ViewName.VipView)
end
