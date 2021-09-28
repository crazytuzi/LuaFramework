

local act_id = FESTIVAL_ACTIVITY_ID.RAND_ACTIVITY_TYPE_CRAZY_GIFT --活动类型
local opear_type_info = GameEnum.RA_CRAZY_GIFT_REQ_TYPE_INFO --操作类型 请求所有信息
local opear_type_buy = GameEnum.RA_CRAZY_GIFT_REQ_TYPE_BUY   --请求购买


CrazyGiftView = CrazyGiftView or BaseClass(BaseRender)

function CrazyGiftView:__init()
	self.list_view = self:FindObj("ListView")
    self.act_time = self:FindVariable("residue_time")
	self.list_view_delegate = self.list_view.list_simple_delegate
	self.list_view_delegate.NumberOfCellsDel = BindTool.Bind(self.GetNumberOfCells, self)
	self.list_view_delegate.CellRefreshDel = BindTool.Bind(self.RefreshView, self)

    self.cell_list = {}
    self.item_list = {}
end

function CrazyGiftView:__delete()
  if self.cell_list then
		for k,v in pairs(self.cell_list) do
			v:DeleteMe()
		end
		self.cell_list = {}
  end

  if self.time_quest then
		GlobalTimerQuest:CancelQuest(self.time_quest)
		self.time_quest = nil
  end

   self.item_list = {}
   self.list_view = nil
   self.act_time = nil
end

function CrazyGiftView:GetNumberOfCells()
     return #self.item_list
end

function CrazyGiftView:OpenCallBack()
	CrazyGiftCtrl.Instance:SendBuyGiftInfo(act_id,opear_type_info,0,0)  --发送请求所有信息的协议
end

function CrazyGiftView:RefreshView(cell,data_index)
	data_index = data_index +1
	local the_cell = self.cell_list[cell]
	if the_cell == nil then
		the_cell = CrazyGiftItemCell.New(cell.gameObject)
		the_cell.parent = self
		self.cell_list[cell] = the_cell
	end
	the_cell:SetIndex(data_index)
	the_cell:SetData(self.item_list[data_index])
end

function CrazyGiftView:OnFlush()
	self.item_list = CrazyGiftData.Instance:CrazyGiftInfo()
	if self.list_view.scroller.isActiveAndEnabled then
		self.list_view.scroller:RefreshAndReloadActiveCellViews(false)
	end
	if self.time_quest == nil then
		self.time_quest = GlobalTimerQuest:AddRunQuest(BindTool.Bind(self.SetTime, self), 1)
		self:SetTime()
	end
end

function CrazyGiftView:SetTime()
	local time = ActivityData.Instance:GetActivityResidueTime(FESTIVAL_ACTIVITY_ID.RAND_ACTIVITY_TYPE_CRAZY_GIFT)
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

function CrazyGiftView:LoadCallBack()
	
end

----------------------------CrazyGiftItemCell-------------------------
CrazyGiftItemCell = CrazyGiftItemCell or BaseClass(BaseCell)

function CrazyGiftItemCell:__init(instance,parent)

   self.parent = parent
   self.gift_name = self:FindVariable("GiftName")
   self.gift_price = self:FindVariable("Price")
   self.buy_count = self:FindVariable("BuyCount")
   self.can_show_sell_out = self:FindVariable("ShowSellOut")
   self.is_gray = self:FindVariable("is_gray")
   self.item_cell = {}

   for i=1,4 do 
   	 self.item_cell[i] = ItemCell.New()
   	 self.item_cell[i]:SetInstanceParent(self:FindObj("ItemCell" .. i))
   end
   
   self:ListenEvent("BuyButton", BindTool.Bind(self.ClickBuyButton, self)) 

end

function CrazyGiftItemCell:SetIndex(index)
	self.index = index
end

function CrazyGiftItemCell:__delete()

   if self.item_cell then
		for k,v in pairs(self.item_cell) do
			v:DeleteMe()
		end
		self.item_cell = {}
   end
  
   self.item_cell = {}
   self.parent = nil
   self.gift_name = nil
   self.gift_price =nil
   self.buy_count = nil
   self.can_show_sell_out = nil
   self.is_gray = nil
end

function CrazyGiftItemCell:ClickBuyButton()

    if not self.data.cfg then
		return
	end

	local func = function()
		CrazyGiftCtrl.Instance:SendBuyGiftInfo(act_id, opear_type_buy, self.data.cfg.gift_type, self.data.cfg.seq)
	end
	local str = string.format(Language.Activity.BuyGiftTip, self.data.cfg.need_gold)
	TipsCtrl.Instance:ShowCommonAutoView("crazy_gift", str, func)

end

function CrazyGiftItemCell:OnFlush()
	
	if not self.data then return end 
	local cfg = self.data.cfg
	local reward_data = ItemData.Instance:GetGiftItemList(cfg.reward_item[0].item_id) or {}
   for k,v in pairs (self.item_cell) do
   		if reward_data[k] then
     		v:SetData(reward_data[k])
     	end
     	self.item_cell[k]:SetActive(reward_data[k] ~= nil)
   end
   self.gift_name:SetValue(cfg.gift_name)
   self.gift_price:SetValue(cfg.need_gold)
   self.buy_count:SetValue(cfg.max_buy_times - self.data.buy_num)
   self.can_show_sell_out:SetValue(self.data.is_sell_out == 1)
   self.is_gray:SetValue(self.data.is_sell_out == 1)

   --售罄后把itemcell置灰 
   -- if self.data.is_sell_out == 1 then 
   --  	for k,v in pairs (self.item_cell) do
   --   		self.item_cell[k]:SetIconGrayVisible(true)
   --   	end
   -- end
    
end