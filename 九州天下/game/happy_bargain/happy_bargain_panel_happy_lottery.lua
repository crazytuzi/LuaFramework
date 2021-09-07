HappyLottery = HappyLottery or BaseClass(BaseRender)
function HappyLottery:__init(instance)
	-- 监听道具改变
	if self.item_data_event == nil then
		self.item_data_event = BindTool.Bind1(function(cfg, item_id, reason, put_reason, old_num, new_num)
			if item_id == HappyBargainData.Instance:GetConsumeInfo(self.cur_day).item_id then
				RemindManager.Instance:Fire(RemindName.HappyLottery)
				self:OnFlush()
				HappyBargainCtrl.Instance:FlushView()
			end
		end, self)
		ItemData.Instance:NotifyDataChangeCallBack(self.item_data_event)
	end
end

function HappyLottery:__delete()
	self.item_num = nil
	self.block_anim_flag = nil
	self.is_auto_buy = nil
	self.cur_day = nil

	self.no_record = nil
	self.one_reminder = nil
	self.ten_reminder = nil
	self.depot_reminder = nil
	self.is_block_anim = nil
	self.available_num = nil
	self.one_draw_consume = nil
	self.ten_draw_consume = nil
	self.one_draw_consume_num = nil
	self.ten_draw_consume_num = nil

	if self.preview_cell_list then
		for k,v in pairs(self.preview_cell_list) do
			v:DeleteMe()
		end
	end
	self.preview_cell_list = {}

	if self.record_cell_list then
		for k,v in pairs(self.record_cell_list) do
			v:DeleteMe()
		end
	end
	self.record_cell_list = {}

	if self.item_data_event ~= nil then
		ItemData.Instance:UnNotifyDataChangeCallBack(self.item_data_event)
		self.item_data_event = nil
	end

	if self.least_time_timer then
		CountDown.Instance:RemoveCountDown(self.least_time_timer)
		self.least_time_timer = nil
	end
end	

function HappyLottery:LoadCallBack()
	self.item_num = 0
	self.block_anim_flag = 0
	self.is_auto_buy = flase
	self.cur_day = HappyBargainData.Instance:GetCurServerOpenServerDay()
	-- print(self.cur_day)
	self:ListenEvent("ClickDrawOnce", BindTool.Bind(self.OnClickDrawOnce, self))
	self:ListenEvent("ClickDrawTen", BindTool.Bind(self.OnClickDrawTen, self))
	self:ListenEvent("ClickBlockAnim", BindTool.Bind(self.OnClickBlockAnim, self))
	self:ListenEvent("ClickDepot", BindTool.Bind(self.OnClickDepot, self))

	self.preview_cell_list = {}
	self.preview_list_view = self:FindObj("PreviewListView")
	local preview_list_delegate = self.preview_list_view.list_simple_delegate
	preview_list_delegate.NumberOfCellsDel = BindTool.Bind(self.GetNumberOfPreviewCells, self)
	preview_list_delegate.CellRefreshDel = BindTool.Bind(self.RefreshPreviewCell, self)

	self.record_cell_list = {}
	self.record_list_view = self:FindObj("RecordListView")
	local record_list_delegate = self.record_list_view.list_simple_delegate
	record_list_delegate.NumberOfCellsDel = BindTool.Bind(self.GetNumberOfRecordCells, self)
	record_list_delegate.CellRefreshDel = BindTool.Bind(self.RefreshRecordCell, self)

	self.no_record = self:FindVariable("no_record")
	self.one_reminder = self:FindVariable("one_reminder")
	self.ten_reminder = self:FindVariable("ten_reminder")
	self.depot_reminder = self:FindVariable("depot_reminder")
	self.is_block_anim = self:FindVariable("is_block_anim")
	self.available_num = self:FindVariable("available_num")
	self.one_draw_consume = self:FindVariable("one_draw_consume")
	self.ten_draw_consume = self:FindVariable("ten_draw_consume")
	self.one_draw_consume_num = HappyBargainData.Instance:GetConsumeInfo(self.cur_day,1).num
	self.ten_draw_consume_num = HappyBargainData.Instance:GetConsumeInfo(self.cur_day,10).num
	self.one_draw_consume:SetValue(self.one_draw_consume_num)
	self.ten_draw_consume:SetValue(self.ten_draw_consume_num)

	self.remaining_time = self:FindVariable("remaining_time")
	local remaining_second = HappyBargainData.Instance:GetActEndTime(2173)
	if self.least_time_timer then
		CountDown.Instance:RemoveCountDown(self.least_time_timer)
        self.least_time_timer = nil
	end
	self:SetTime(remaining_second)
	self.least_time_timer = CountDown.Instance:AddCountDown(remaining_second, 1, function ()
			remaining_second = remaining_second - 1
            self:SetTime(remaining_second)
        end)

end

function HappyLottery:SetTime(remaining_second)
 	local time_tab = TimeUtil.Format2TableDHMS(remaining_second)
  	local str = ""
 	if time_tab.day > 0 then
   		remaining_second = remaining_second - 24 * 60 * 60 * time_tab.day
   	end
	str = TimeUtil.FormatSecond(remaining_second)
	if self.remaining_time then
	    self.remaining_time:SetValue(str)
	end
end

function HappyLottery:GetNumberOfPreviewCells()
	return 4
end

function HappyLottery:RefreshPreviewCell(cell, cell_index)
	cell_index = cell_index + 1
	local preview_cell = self.preview_cell_list[cell]
	if preview_cell == nil then
		preview_cell = HappyLotteryPreviewCell.New(cell.gameObject,self)
		self.preview_cell_list[cell] = preview_cell
	end
	preview_cell:SetIndex(cell_index)
	preview_cell:Flush()
end

function HappyLottery:GetNumberOfRecordCells()
	local record_num = #HappyBargainData.Instance:GetRecordInfo()
	self.no_record:SetValue(record_num == 0)
	return record_num
end

function HappyLottery:RefreshRecordCell(cell, cell_index)
	cell_index = cell_index + 1
	local record_cell = self.record_cell_list[cell]
	if record_cell == nil then
		record_cell = HappyLotteryRecordInfo.New(cell.gameObject)
		self.record_cell_list[cell] = record_cell
	end
	local data = HappyBargainData.Instance:GetRecordInfo()[cell_index]
	record_cell:SetData(data)
end

function HappyLottery:CloseCallBack()
	if self.least_time_timer then
        CountDown.Instance:RemoveCountDown(self.least_time_timer)
        self.least_time_timer = nil
    end
end

function HappyLottery:OnFlush()
	local consume_id = HappyBargainData.Instance:GetConsumeInfo(self.cur_day).item_id
	self.item_num = ItemData.Instance:GetItemNumInBagById(consume_id)
	self.available_num:SetValue(self.item_num)
	if self.record_list_view.scroller.isActiveAndEnabled then
		self.record_list_view.scroller:RefreshAndReloadActiveCellViews(true)
	end
	self.one_reminder:SetValue(self.item_num >= self.one_draw_consume_num)
	self.ten_reminder:SetValue(self.item_num >= self.ten_draw_consume_num)
	HappyBargainData.Instance:SetHappyLotteryRemind(self.item_num >= self.one_draw_consume_num)
	self.depot_reminder:SetValue(TreasureData.Instance:GetChestCount() > 0)
end

function HappyLottery:OnClickDrawOnce()
	local consume_id = HappyBargainData.Instance:GetConsumeInfo(self.cur_day,1).item_id
	if self.item_num < self.one_draw_consume_num and not self.is_auto_buy then        
		local func = function(item_id, item_num, is_bind, is_use, is_auto_buy)
			MarketCtrl.Instance:SendShopBuy(item_id, item_num, is_bind, is_use)
			self.is_auto_buy = is_auto_buy
		end
		TipsCtrl.Instance:ShowCommonBuyView(func, consume_id, nil, (self.one_draw_consume_num - self.item_num))
		return
	end
	HappyBargainData.Instance:SetChestShopMode(CHEST_SHOP_MODE.CHEST_RAND_HAPPY_LOTTERY_1)
	local auto_buy = self.is_auto_buy and 1 or 0
	-- 2173; o_t:0请求珍稀榜，1抽奖；p1：是否十抽；p2：是否快速购买
	KaifuActivityCtrl.Instance:SendGetKaifuActivityInfo(ACTIVITY_TYPE.RAND_ACTIVITY_TYPE_HAPPY_LOTTERY, 1, 0, auto_buy) 
end

function HappyLottery:OnClickDrawTen()
	local consume_id = HappyBargainData.Instance:GetConsumeInfo(self.cur_day,10).item_id
	if self.item_num < self.ten_draw_consume_num and not self.is_auto_buy then              
		local func = function(item_id, item_num, is_bind, is_use, is_auto_buy)
			MarketCtrl.Instance:SendShopBuy(item_id, item_num, is_bind, is_use)
			self.is_auto_buy = is_auto_buy
		end
		TipsCtrl.Instance:ShowCommonBuyView(func, consume_id, nil, (self.ten_draw_consume_num - self.item_num))
		return
	end
	HappyBargainData.Instance:SetChestShopMode(CHEST_SHOP_MODE.CHEST_RAND_HAPPY_LOTTERY_10)
	local auto_buy = self.is_auto_buy and 1 or 0
	KaifuActivityCtrl.Instance:SendGetKaifuActivityInfo(ACTIVITY_TYPE.RAND_ACTIVITY_TYPE_HAPPY_LOTTERY, 1, 1, auto_buy)
end

function HappyLottery:OnClickBlockAnim()
	self.block_anim_flag = self.block_anim_flag == 0 and 1 or 0
	self.is_block_anim:SetValue(self.block_anim_flag > 0)
	HappyBargainData.Instance:SetAniState(self.block_anim_flag < 1)
end

function HappyLottery:OnClickDepot()
	HappyBargainCtrl.Instance:CloseView()
	ViewManager.Instance:Open(ViewName.Treasure, TabIndex.treasure_warehouse)
end

 -----------------------------HappyLotteryPreviewCell-----------------------------------------
HappyLotteryPreviewCell = HappyLotteryPreviewCell  or BaseClass(BaseCell)
function HappyLotteryPreviewCell:__init(instance,parent_view)
	self.parent_view = parent_view
	self.item_cells = {}
	for i=1,2 do
		self.item_cells[i] = {}
		self.item_cells[i] = ItemCell.New(self:FindObj("item_"..i))
	end
	self.show_cfg = HappyBargainData.Instance:GetPreviewItems(self.parent_view.cur_day)
end

function HappyLotteryPreviewCell:__delete()
	for i=1,2 do
		if self.item_cells[i] then
			self.item_cells[i]:DeleteMe()
		end
	end
end

function HappyLotteryPreviewCell:OnFlush()
	for i=1,2 do
		local index = CommonDataManager.GetCellIndexList(self.index, 4, 2)[i]
		self.item_cells[i]:SetData(self.show_cfg[index-1].reward_item)
		self.item_cells[i]:IsDestroyEffect(true)
		self.item_cells[i]:IsDestoryActivityEffect(self.show_cfg[index-1].is_rare ~= 1)
		self.item_cells[i]:SetActivityEffect()
	end
end

------------------------------------------HappyLotteryRecordInfo--------------------------------------------

HappyLotteryRecordInfo = HappyLotteryRecordInfo or BaseClass(BaseCell)

function HappyLotteryRecordInfo:__init()
	self.name = self:FindVariable("Name")
	self.item = self:FindVariable("Item")
end

function HappyLotteryRecordInfo:__delete()

end

function HappyLotteryRecordInfo:OnFlush()
	if self.data then
		self.name:SetValue(self.data.role_name)
		if ItemData.Instance:GetItemConfig(self.data.item_id) then
			local item_name = ItemData.Instance:GetItemConfig(self.data.item_id).name
			self.item:SetValue(item_name)
		end
		
	end
end
