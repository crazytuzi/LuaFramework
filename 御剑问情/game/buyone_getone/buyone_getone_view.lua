BuyOneGetOneView = BuyOneGetOneView or BaseClass(BaseView)
local PAGE_COUNT = 5

function BuyOneGetOneView:__init()
	self.ui_config = {"uis/views/buyonegetone_prefab", "BuyOneGetOneView"}
	self.play_audio = true
	self.bgone_cell_list = {}
	self.cur_day = 0
end

function BuyOneGetOneView:ReleaseCallBack()
	if self.time_quest then
		GlobalTimerQuest:CancelQuest(self.time_quest)
		self.time_quest = nil
	end

	for k,v in pairs(self.bgone_cell_list) do
		v:DeleteMe()
	end
	self.bgone_cell_list = {}

	--清理对象和变量
	self.list_view = nil
	self.act_time = nil
	self.last_num = nil
	self.data_count = nil
end

function BuyOneGetOneView:LoadCallBack()
	self.act_time = self:FindVariable("ActTime")
	self.last_num = self:FindVariable("LastNum")
	self.data_count = self:FindVariable("DataCount")

	self:ListenEvent("CloseWindow",BindTool.Bind(self.CloseWindow,self))

	self.list_view = self:FindObj("ListView")

	local list_delegate = self.list_view.page_simple_delegate

	list_delegate.NumberOfCellsDel = BindTool.Bind(self.NumberOfCellsDel,self)
	list_delegate.CellRefreshDel = BindTool.Bind(self.CellRefreshDel,self)
	self.list_view.list_view:JumpToIndex(0)
	self.list_view.list_view:Reload()
end

function BuyOneGetOneView:OpenCallBack()
	KaifuActivityCtrl.Instance:SendRandActivityOperaReq(ACTIVITY_TYPE.RAND_ACTIVITY_TYPE_BUYONE_GETONE, 
		RA_BUY_ONE_GET_ONE_FREE_OPERA_TYPE.RA_BUY_ONE_GET_ONE_FREE_OPERA_TYPE_INFO, 0, 0)
	self:Flush()
end


function BuyOneGetOneView:NumberOfCellsDel()
	local list = BuyOneGetOneData.Instance:GetBGOneData()
	if list == nil then return 0 end

	local count = math.ceil(GetListNum(list) / PAGE_COUNT)

	if self.data_count then
		self.data_count:SetValue(count)
		self.list_view.list_page_scroll2:SetPageCount(count)
	end

	return PAGE_COUNT * count
end

function BuyOneGetOneView:CellRefreshDel(index,cellobj)
	local cell = self.bgone_cell_list[cellobj]
	if nil == cell then
		cell = BGOneItem.New(cellobj)
		cell:SetToggleGroup(self.list_view.toggle_group)
		self.bgone_cell_list[cellobj] = cell
	end
	cell:SetIndex(index+1)
	cell:SetBuyCallBack(BindTool.Bind(self.OnBuyClick,self))
	cell:SetGetCallBack(BindTool.Bind(self.OnGetClick,self))
	cell:SetData(BuyOneGetOneData.Instance:GetBGOneData()[index+1])
end

function BuyOneGetOneView:OnFlush()
	if self.time_quest == nil then
		self.time_quest = GlobalTimerQuest:AddRunQuest(BindTool.Bind(self.FlushNextTime, self), 1)
		self:FlushNextTime()
	end

	self.list_view.list_view:Reload()

end

function BuyOneGetOneView:CloseWindow()
	self:Close()
end

function BuyOneGetOneView:FlushNextTime()
	local time = ActivityData.Instance:GetActivityResidueTime(ACTIVITY_TYPE.RAND_ACTIVITY_TYPE_BUYONE_GETONE)
	if time <= 0 then
		if self.time_quest then
			GlobalTimerQuest:CancelQuest(self.time_quest)
			self.time_quest = nil
		end
	end
	local time_type = 1
	if time > 3600 * 24 then
		time_type = 6
	elseif time > 3600 then
		time_type = 1
	else
		time_type = 2
	end

	self.act_time:SetValue(ToColorStr(TimeUtil.FormatSecond(time, time_type), TEXT_COLOR.GREEN))
end

function BuyOneGetOneView:OnBuyClick(cell)
	KaifuActivityCtrl.Instance:SendRandActivityOperaReq(ACTIVITY_TYPE.RAND_ACTIVITY_TYPE_BUYONE_GETONE,
		 RA_BUY_ONE_GET_ONE_FREE_OPERA_TYPE.RA_BUY_ONE_GET_ONE_FREE_OPERA_TYPE_BUY, cell.data.cfg.seq, 0)

end

function BuyOneGetOneView:OnGetClick(cell)
	KaifuActivityCtrl.Instance:SendRandActivityOperaReq(ACTIVITY_TYPE.RAND_ACTIVITY_TYPE_BUYONE_GETONE,
		 RA_BUY_ONE_GET_ONE_FREE_OPERA_TYPE.RA_BUY_ONE_GET_ONE_FREE_OPERA_TYPE_FETCH_REWARD, cell.data.cfg.seq, 0)

end

---------------------------物品滚动条格子-----------------------------
BGOneItem = BGOneItem or BaseClass(BaseCell)

function BGOneItem:__init()
	self.buy_item_cell = ItemCell.New()
	self.buy_item_cell:SetInstanceParent(self:FindObj("BuyItemCell"))
	self.get_item_cell = ItemCell.New()
	self.get_item_cell:SetInstanceParent(self:FindObj("GetItemCell"))

	self.buy_btn = self:FindObj("Buy_Btn")
	self.get_btn = self:FindObj("Get_Btn")
	self.buy_name_text = self:FindVariable("BuyName_Text")
	self.get_name_text = self:FindVariable("GetName_Text")
	self.buybtn_text = self:FindVariable("BuyBtn_Text")
	self.getbtn_text = self:FindVariable("GetBtn_Text")
	self.price_text = self:FindVariable("Price_Text")
	self.show = self:FindVariable("Show")
	self.can_lingqu = self:FindVariable("Can_LingQu")
	self:ListenEvent("BuyClick",BindTool.Bind(self.BuyClick,self))
	self:ListenEvent("GetClick",BindTool.Bind(self.GetClick,self))
end

function BGOneItem:__delete()
	if self.buy_item_cell then
		self.buy_item_cell:DeleteMe()
		self.buy_item_cell = nil
	end
	if self.get_item_cell then
		self.get_item_cell:DeleteMe()
		self.get_item_cell = nil
	end
	self.buy_btn = nil
	self.get_btn = nil
end

function BGOneItem:SetData(data)
	self:SetActive(data~=nil)
	if data == nil then
		return
	end
	self.data = data
	self:Flush()
end

function BGOneItem:OnFlush()
	self.buy_item_cell:SetData(self.data.cfg.buy_item)
	local buy_name_info = ItemData.Instance:GetItemConfig(self.data.cfg.buy_item.item_id)
	local buy_item_name = ToColorStr(buy_name_info.name, ITEM_COLOR[buy_name_info.color])
	self.buy_name_text:SetValue(buy_item_name)

	self.get_item_cell:SetData(self.data.cfg.free_reward_item)
	local get_name_info = ItemData.Instance:GetItemConfig(self.data.cfg.free_reward_item.item_id)
	local get_item_name = ToColorStr(get_name_info.name, ITEM_COLOR[get_name_info.color])
	self.get_name_text:SetValue(get_item_name)
	self.price_text:SetValue(self.data.cfg.price_gold)

	self:SetButtonGray()
end

function BGOneItem:SetBuyCallBack(callback)
	self.buy_callback = callback
end

function BGOneItem:SetGetCallBack(callback)
	self.get_callback = callback
end

function BGOneItem:BuyClick()
	if nil ~= self.buy_callback then
		self.buy_callback(self)
	end
end

function BGOneItem:GetClick()
	if nil ~= self.get_callback then
		self.get_callback(self)
	end
end

function BGOneItem:SetToggleGroup(toggle_group)
	if self.root_node.toggle and self:GetActive() then
		self.root_node.toggle.group = toggle_group
	end
end

function BGOneItem:SetActive(value)
	self.show:SetValue(value)
end

function BGOneItem:SetButtonGray()
	self.can_buy = self.data.buy_flag
	self.can_reward = self.data.free_reward_flag

	if self.can_buy == 1 then
		self.buy_btn.button.interactable = false
		self.buybtn_text:SetValue(Language.Common.AlreadyPurchase)
		if self.can_reward == 1 then
			self.get_btn.button.interactable = false
			self.getbtn_text:SetValue(Language.Common.YiLingQu)
			self.can_lingqu:SetValue(false)
		else
			self.get_btn.button.interactable = true
			self.getbtn_text:SetValue(Language.Common.LingQu)
			self.can_lingqu:SetValue(true)
		end
	else
		self.buy_btn.button.interactable = true
		self.buybtn_text:SetValue(Language.Common.CanPurchase)
		self.get_btn.button.interactable = false
		self.can_lingqu:SetValue(false)
		self.getbtn_text:SetValue(Language.Common.LingQu)
	end
end