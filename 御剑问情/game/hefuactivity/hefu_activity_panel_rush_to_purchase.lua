RushToPurchase = RushToPurchase or BaseClass(BaseRender)
function RushToPurchase:__init()
	self.list_view = self:FindObj("ListView")
	local page_simple_delegate = self.list_view.page_simple_delegate
    page_simple_delegate.NumberOfCellsDel = BindTool.Bind(self.NumberOfCellsDel, self)
    page_simple_delegate.CellRefreshDel = BindTool.Bind(self.CellRefreshDel, self)

    self.item_obj = self:FindObj("Item")
   	self.item_cell = ItemCell.New()
   	self.item_cell:SetInstanceParent(self.item_obj)

   	self.rest_time = self:FindVariable("rest_time")
   	self.buy_count = self:FindVariable("buy_count")
   	self.gold_count = self:FindVariable("gold_count")
   	self.rank_level = self:FindVariable("rank_level")
   	self.qianggou_tips = self:FindVariable("qianggou_tips")

   	self:ListenEvent("ClickReChange", BindTool.Bind(self.ClickReChange, self))

	self.qianggou_buy_num_list = {}
	self.qianggou_rank_list = {}
	self.reward_cell_list = {}
	self.item_cell_list = {}
	self.main_role_vo = GameVoManager.Instance:GetMainRoleVo()
end

function RushToPurchase:__delete()
	if self.least_time_timer then
		CountDown.Instance:RemoveCountDown(self.least_time_timer)
		self.least_time_timer = nil
	end

	for k,v in pairs(self.item_cell_list) do
		v:DeleteMe()
	end
	self.item_cell_list = {}

	if self.item_cell then
		self.item_cell:DeleteMe()
		self.item_cell = nil
	end
end

function RushToPurchase:OpenCallBack()
	self.first_reward = HefuActivityData:GetQiangGouFistReward()
	HefuActivityCtrl.Instance:SendCSAQueryActivityInfo()
	self.qianggou_list_info = HefuActivityData.Instance:GetQiangGouListInfo()

	if self.least_time_timer then
		CountDown.Instance:RemoveCountDown(self.least_time_timer)
        self.least_time_timer = nil
	end
	local rest_time = HefuActivityData.Instance:GetCombineActTimeLeft(COMBINE_SERVER_ACTIVITY_SUB_TYPE.CSA_SUB_TYPE_RANK_QIANGGOU)
	self:SetTime(rest_time)
	self.least_time_timer = CountDown.Instance:AddCountDown(rest_time, 1, function ()
			rest_time = rest_time - 1
            self:SetTime(rest_time)
        end)

    self.list_view.list_view:Reload()
    self.list_view.list_view:JumpToIndex(0)

   	self.item_cell:SetData(self.first_reward or {})

   	local rank_data = HefuActivityData.Instance:GetRankRewardCfgBySubType(COMBINE_SERVER_ACTIVITY_SUB_TYPE.CSA_SUB_TYPE_RANK_QIANGGOU)
   	self.qianggou_tips:SetValue(rank_data.rank_limit or 0)
end

function RushToPurchase:CloseCallBack()
	if self.least_time_timer then
        CountDown.Instance:RemoveCountDown(self.least_time_timer)
        self.least_time_timer = nil
    end
end

function RushToPurchase:NumberOfCellsDel()
	return #self.qianggou_list_info
end

function RushToPurchase:CellRefreshDel(cell_index, cell)
	local item_cell = self.reward_cell_list[cell]
	if nil == item_cell then
		item_cell = RushToPurchaseItem.New(cell.gameObject, self)
		self.reward_cell_list[cell] = item_cell
	end
	self.item_cell_list[cell_index + 1] = item_cell
	item_cell:SetIndex(cell_index)
	item_cell:SetData(self.qianggou_list_info[cell_index + 1])
end

function RushToPurchase:SetTime(rest_time)
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
	local str = ""
	if temp.day < 1 then
		str = string.format(Language.HefuActivity.RestTime, temp.day, temp.hour, temp.min)
	else
		str = string.format(Language.Activity.ChongZhiRankRestTime, temp.day, temp.hour, temp.min, temp.s)
	end
	self.rest_time:SetValue(str)
end

function RushToPurchase:OnFlush()
	self.all_qianggou_buy_num_list = HefuActivityData.Instance:GetQiangGouAllBuyNumList()
	self.qianggou_buy_num_list, self.qianggou_rank_list = HefuActivityData.Instance:GetQiangGouInfo()
	for k,v in pairs(self.item_cell_list) do
		if self.all_qianggou_buy_num_list ~= 0 then
			v:SetBuyNum(self.all_qianggou_buy_num_list[k] or 0)
			v:Flush()
		end
	end
	local count = 0
	for k,v in pairs(self.qianggou_buy_num_list) do
		count = count + v
	end
	self.buy_count:SetValue(count)
	self.gold_count:SetValue(CommonDataManager.ConverMoney(self.main_role_vo.gold))
	local is_in_rank = false
	local rank_level = 0
	for k,v in pairs(self.qianggou_rank_list) do
		if v.role_id == self.main_role_vo.role_id then
			is_in_rank = true
			rank_level = k
		end
	end
	if is_in_rank then
		self.rank_level:SetValue(rank_level)
	else
		self.rank_level:SetValue(Language.HefuActivity.NotInRank)
	end
end

function RushToPurchase:ClickReChange()
	VipData.Instance:SetOpenType(OPEN_VIP_RECHARGE_TYPE.RECHANRGE)
	ViewManager.Instance:Open(ViewName.VipView)
end

---------------------------------RushToPurchaseItem----------------------------------
RushToPurchaseItem = RushToPurchaseItem or BaseClass(BaseCell)
function RushToPurchaseItem:__init()
	self.item_cell_obj = self:FindObj("item_1")
	self.item_cell = ItemCell.New()
	self.item_cell:SetInstanceParent(self.item_cell_obj)
	self:ListenEvent("OnClickGet", BindTool.Bind(self.OnClickGet, self))
	self.cost_gold = self:FindVariable("cost_gold")
	self.left_count = self:FindVariable("text1")
	self.can_get = self:FindVariable("can_get")
	self.buy_num = 0
	self.rander_name = self:FindVariable("rander_name")
end

function RushToPurchaseItem:__delete()
	self.item_cell:DeleteMe()
end

function RushToPurchaseItem:OnFlush()
	self.data = self:GetData()
	if next(self.data) then
		self.cost_gold:SetValue(self.data.cost)
		self.left_count:SetValue(self.data.limit_num - self.buy_num)
		self.can_get:SetValue(self.data.limit_num > self.buy_num)
		self.item_cell:SetData(self.data.stuff_item)
		self.rander_name:SetValue(ItemData.Instance:GetItemConfig(self.data.stuff_item.item_id).name)
	end
end

function RushToPurchaseItem:SetBuyNum(num)
	self.buy_num = num
end

function RushToPurchaseItem:OnClickGet()
	HefuActivityCtrl.Instance:SendCSARoleOperaReq(COMBINE_SERVER_ACTIVITY_SUB_TYPE.CSA_SUB_TYPE_RANK_QIANGGOU, self:GetIndex())
end