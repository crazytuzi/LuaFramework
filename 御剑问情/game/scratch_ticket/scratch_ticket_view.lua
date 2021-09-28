ScratchTicketView= ScratchTicketView or BaseClass(BaseView)

local TOUCH_STATE =
{
	DOWN = "down",
	UP = "up"
}

function ScratchTicketView:__init()
	self.ui_config = {"uis/views/scratchticket_prefab", "ScratchTicketView"}
	self.is_send = false
	self.stop_update = false
end

function ScratchTicketView:__delete()

end

function ScratchTicketView:Update()
	if self.stop_update then
		return
	end
	--第一次按下
	if self:IsTouchDown() and self.old_touch_state ~= TOUCH_STATE.DOWN  then
		self:OnTouchBegin()
		return
	end

	if self.old_touch_state == TOUCH_STATE.DOWN then
		if self:IsTouchUp() then
			--松手
			self:OnTouchEnd()
		else
			--未松手
			if self.old_touch_state == TOUCH_STATE.DOWN then
				self:OnTouchMove()
				return
			end
		end
	end
end

function ScratchTicketView:IsTouchUp()
	return UnityEngine.Input.GetMouseButtonUp(0)
end

function ScratchTicketView:IsTouchDown()
	return UnityEngine.Input.GetMouseButtonDown(0) or UnityEngine.Input.touchCount > 0 --0是左键
end

function ScratchTicketView:IsInTouchArear()
	if nil == self.cur_uicamera then
		self.cur_uicamera = GameObject.Find("GameRoot/UICamera"):GetComponent(typeof(UnityEngine.Camera))
		self.image_mark_pos = UnityEngine.RectTransformUtility.WorldToScreenPoint(self.cur_uicamera, self.image_mark.transform.position)
	end

	local width = self.image_mark.transform.rect.width
	local height = self.image_mark.transform.rect.height

	local pos_x = self.image_mark_pos.x
	local pos_y = self.image_mark_pos.y

	local mouse_pos = UnityEngine.Input.mousePosition
	local is_in_arear = mouse_pos.x >= (pos_x - width / 2) and mouse_pos.x <= (pos_x + width / 2) 
							and mouse_pos.y >= (pos_y - height / 2) and mouse_pos.y <= (pos_y + height / 2)

	return is_in_arear
end

function ScratchTicketView:OnTouchBegin()
	self.old_touch_state = TOUCH_STATE.DOWN
	self.is_record = false
end

function ScratchTicketView:OnTouchEnd()
	self.old_touch_state = TOUCH_STATE.UP
	self.is_record = false
	--重置遮挡板alpha值
	
end

function ScratchTicketView:OnTouchMove()
	if self:IsInTouchArear() and self.image_mark.canvas_group.alpha > 0 then
		self.image_mark.canvas_group.alpha = self.image_mark.canvas_group.alpha - 0.02
        self.show_image:SetValue(false)
		if self.image_mark.canvas_group.alpha <= 0.5 and not self.is_send then
			local function call_back()
				self:ResetView()
			end
			TipsCtrl.Instance:SetTreasureViewCloseCallBack(call_back)
			ScratchTicketData.Instance:SetChestShopMode(CHEST_SHOP_MODE.CHEST_GuaGuaLe_MODE_1)
			KaifuActivityCtrl.Instance:SendGetKaifuActivityInfo(ACTIVITY_TYPE.RAND_ACTIVITY_DINGGUAGUA,
														RA_GUAGUA_OPERA_TYPE.RA_GUAGUA_OPERA_TYPE_PLAY_TIMES, RA_GUAGUA_PLAY_MULTI_TYPES.RA_GUAGUA_PLAY_ONE_TIME)
			self.is_send = true
			self.stop_update = true
		end
	end
		
end

function ScratchTicketView:ResetView()
	if self.image_mark then
		self.image_mark.canvas_group.alpha = 1
		self.show_image:SetValue(false)
		self.is_send = false
		self.stop_update = false
	end
end

function ScratchTicketView:FlushKey()
	local keynum = ScratchTicketData:GetThirtyKeyNum()

    if keynum > 0 then
    	self.is_show_key:SetValue(true)
    	self.show_red_point:SetValue(true)
    	self.guagua_thirtytimes_key_num:SetValue(keynum)
    else
    	self.is_show_key:SetValue(false)
    	self.show_red_point:SetValue(false)
    end
end


function ScratchTicketView:LoadCallBack()
	self.num = self:FindVariable("num")
	self.gold_num_list = {}
	self.image_list = {}
	self.ScratchTicket_item_list = {}
	self.ScratchTicket_show_list = {}
	self.index_list = {}

	for i = 1, 3 do
		self.gold_num_list[i] = self:FindVariable("gold_num_" .. i)
		self.image_list[i] = self:FindVariable("image_" .. i)
	end

	self.guagua_thirtytimes_key_num = self:FindVariable("GuaGuaItemNum")
	self.is_show_key = self:FindVariable("ShowThirtyKey")
	self.is_show_key:SetValue(false)
	local keynum = ScratchTicketData:GetThirtyKeyNum()

    if keynum > 0 then
    	self.is_show_key:SetValue(true)
    	self.guagua_thirtytimes_key_num:SetValue(keynum)
    end
	
	self.item_list = self:FindObj("ShowListView")
	local list_delegate = self.item_list.list_simple_delegate
	list_delegate.NumberOfCellsDel = BindTool.Bind(self.GetNumberOfCells, self)
	list_delegate.CellRefreshDel = BindTool.Bind(self.RefreshCell, self)

	self.show_list = self:FindObj("ItemListView")
	local list_delegatet_two = self.show_list.list_simple_delegate
	list_delegatet_two.NumberOfCellsDel = BindTool.Bind(self.GetNumberOfCellsTwo, self)
	list_delegatet_two.CellRefreshDel = BindTool.Bind(self.RefreshCellTwo, self)

	self.image_mark = self:FindObj("ImageMark")
 
	self.remain_time = self:FindVariable("timer")
	self.show_image = self:FindVariable("ShowImage")
	self.show_red_point = self:FindVariable("ShowRedPoint")
	self.show_red_point:SetValue(false)
	self.show_image:SetValue(false)


	--绑定按钮点击事件
	self:ListenEvent("onClickClose", BindTool.Bind(self.OnClickClose, self))
	self:ListenEvent("onClickCangKu", BindTool.Bind(self.onClickCangKu, self))
	self:ListenEvent("onClickTen", BindTool.Bind(self.onClickTen, self))
	self:ListenEvent("onClickFifty", BindTool.Bind(self.onClickFifty, self))
	self:ListenEvent("onClickLastButton", BindTool.Bind(self.OnClickLastButton, self))
	self:ListenEvent("onClickNextButton", BindTool.Bind(self.OnClickNextButton, self))
    self:ListenEvent("OnClickLog", BindTool.Bind(self.OnClickLog, self))
    
    if self.item_data_event == nil then
		self.item_data_event = BindTool.Bind1(self.ItemDataChangeCallback, self)
		ItemData.Instance:NotifyDataChangeCallBack(self.item_data_event)
	end

	self.old_touch_state = TOUCH_STATE.UP
end

--刷新活动剩余时间
function ScratchTicketView:FlushNextTime()
	local time = ActivityData.Instance:GetActivityResidueTime(ACTIVITY_TYPE.RAND_ACTIVITY_DINGGUAGUA)
	if time <= 0 then
		if self.time_quest then
			GlobalTimerQuest:CancelQuest(self.time_quest)
			self.time_quest = nil
		end
	end
	if time > 3600 * 24 then
		self.remain_time:SetValue("<color='#00ff00'>" .. TimeUtil.FormatSecond(time, 6) .. "</color>")
	elseif time > 3600 then
		self.remain_time:SetValue("<color='#00ff00'>" .. TimeUtil.FormatSecond(time, 1) .. "</color>")
	else
		self.remain_time:SetValue("<color='#00ff00'>" .. TimeUtil.FormatSecond(time, 2) .. "</color>")
	end
end

--获取展示格子的数量
function ScratchTicketView:GetNumberOfCells()
	return #ScratchTicketData.Instance:GetGuaGuaCfgByList()
end
--刷新展示格子
function ScratchTicketView:RefreshCell(cell, cell_index)
	local item_cell = self.ScratchTicket_show_list[cell]
	if nil == item_cell then
		item_cell = ScratchTicketViewShwoItem.New(cell.gameObject, self)
		self.ScratchTicket_show_list[cell] = item_cell
	end
	
	local data = ScratchTicketData.Instance:GetGuaGuaCfgByList()
	if data then 
		item_cell:SetData(data[cell_index + 1])
    end
end


--获取奖励格子的数量
function ScratchTicketView:GetNumberOfCellsTwo()
	return GetListNum(ScratchTicketData.Instance:GetGuaGuaRewardCfg())
end
--刷新奖励格子
function ScratchTicketView:RefreshCellTwo(cell, cell_index)
	local item_cell = self.ScratchTicket_item_list[cell]
	if nil == item_cell then
		item_cell = ScratchTicketViewItem.New(cell.gameObject, self)
		self.ScratchTicket_item_list[cell] = item_cell
	end
	local data = ScratchTicketData.Instance:GetGuaGuaRewardCfg()
	item_cell:SetIndex(cell_index + 1)
	item_cell:SetData(data[cell_index + 1])
end

--打开界面的回调
function ScratchTicketView:OpenCallBack()	
	KaifuActivityCtrl.Instance:SendGetKaifuActivityInfo(ACTIVITY_TYPE.RAND_ACTIVITY_DINGGUAGUA, RA_GUAGUA_OPERA_TYPE.RA_GUAGUA_OPERA_TYPE_QUERY_INFO)
	self:Flush()

	Runner.Instance:AddRunObj(self, 16)
end


--关闭界面的回调
function ScratchTicketView:CloseCallBack()
	Runner.Instance:RemoveRunObj(self)
end

--关闭界面释放回调
function ScratchTicketView:ReleaseCallBack()
	self.show_red_point = nil
	self.num = nil
	self.gold_num_list = {}
	self.image_list = {}
	self.ScratchTicket_item_list = {}
	self.ScratchTicket_show_list = {}
	self.index_list = {}
	self.item_list = nil
	self.show_list = nil
	self.remain_time = nil
	self.is_show_key = nil
	self.guagua_thirtytimes_key_num = nil
	if self.time_quest then
		GlobalTimerQuest:CancelQuest(self.time_quest)
		self.time_quest = nil
	end

	if self.item_data_event ~= nil then
		ItemData.Instance:UnNotifyDataChangeCallBack(self.item_data_event)
		self.item_data_event = nil
	end

	self.image_mark = nil
	self.show_image = nil
	self.cur_uicamera = nil
end

function ScratchTicketView:ItemDataChangeCallback()
	self:Flush()
end

--刷新
function ScratchTicketView:OnFlush(param_list)
	--刷新时间
	if self.time_quest == nil then
		self.time_quest = GlobalTimerQuest:AddRunQuest(BindTool.Bind(self.FlushNextTime, self), 1)
		self:FlushNextTime()
	end
	--读取配置表中的元宝数量
	if ScratchTicketData.Instance:GetGuaGuaLeCfg() then
		local gold_config = ScratchTicketData.Instance:GetGuaGuaLeCfg().other
		if gold_config then 
			self.gold_num_list[1]:SetValue(gold_config[1].guagua_once_gold or 0)
			self.gold_num_list[2]:SetValue(gold_config[2].guagua_tentimes_gold or 0)
			self.gold_num_list[3]:SetValue(gold_config[3].guagua_thirtytimes_gold or 0)
			self.num:SetValue(ScratchTicketData.Instance:GetGuaGuaCount() or 0)
		end
	end
	--刮奖面板-------------------------------------------------------------------------------------------------------
	self.index_list = ScratchTicketData.Instance:GetGuaGuaIndex()
	local guagua_config = ScratchTicketData.Instance:GetGuaGuaCfg()
	if guagua_config == nil then
        return 
    end
     
	local config_list = ListToMap(guagua_config,"seq") 
	if config_list == nil then
		return
	end

	if self.index_list then
		local aaa = {}
		for i=1,3 do
			aaa["bundle"..i],aaa["asset"..i] = ResPath.GetScratchTicketRes("wuxing_0" .. config_list[self.index_list[0]]["icon" .. i .. "_id"] + 1)
			self.image_list[i]:SetAsset(aaa["bundle"..i],aaa["asset"..i])			
		end
	end

	self:FlushKey()
	self.show_image:SetValue(true)
	--刷新
	self.show_list.scroller:RefreshAndReloadActiveCellViews(true)

end




function ScratchTicketView:OnClickClose()
	self:Close()
end

function ScratchTicketView:onClickCangKu()
	ViewManager.Instance:Open(ViewName.Treasure, TabIndex.treasure_warehouse)
end


function ScratchTicketView:onClickTen()
	ScratchTicketData.Instance:SetChestShopMode(CHEST_SHOP_MODE.CHEST_GuaGuaLe_MODE_10)
	KaifuActivityCtrl.Instance:SendGetKaifuActivityInfo(ACTIVITY_TYPE.RAND_ACTIVITY_DINGGUAGUA, RA_GUAGUA_OPERA_TYPE.RA_GUAGUA_OPERA_TYPE_PLAY_TIMES, RA_GUAGUA_PLAY_MULTI_TYPES.RA_GUAGUA_PLAY_TEN_TIMES)
	self:ResetView()
end

function ScratchTicketView:onClickFifty()
	ScratchTicketData.Instance:SetChestShopMode(CHEST_SHOP_MODE.CHEST_GuaGuaLe_MODE_50)
	KaifuActivityCtrl.Instance:SendGetKaifuActivityInfo(ACTIVITY_TYPE.RAND_ACTIVITY_DINGGUAGUA, RA_GUAGUA_OPERA_TYPE.RA_GUAGUA_OPERA_TYPE_PLAY_TIMES, RA_GUAGUA_PLAY_MULTI_TYPES.RA_GUAGUA_PLAY_THIRTY_TIMES)
	self:ResetView()
end

function ScratchTicketView:OnClickLastButton()
	self.show_list.scroll_rect.horizontalNormalizedPosition = 0
end

function ScratchTicketView:OnClickNextButton()
	self.show_list.scroll_rect.horizontalNormalizedPosition = 1
end

function ScratchTicketView:OnClickLog()
    ActivityCtrl.Instance:SendActivityLogSeq(ACTIVITY_TYPE.RAND_ACTIVITY_DINGGUAGUA)
end

---------------------------------ScratchTicketViewItem（奖励格子）----------------------------------
ScratchTicketViewItem = ScratchTicketViewItem or BaseClass(BaseCell)
--初始化
function ScratchTicketViewItem:__init()
	self.item_cell = ItemCell.New()
	self.item_cell:SetInstanceParent(self:FindObj("Item"))
	self.item_cell:ShowHighLight(false)
	self.num = self:FindVariable("num")
end
--奖励格子的界面关闭回调
function ScratchTicketViewItem:__delete()
	self.item_cell:DeleteMe()
	self.item_cell = nil
	self.num = nil
end

function ScratchTicketViewItem:SetIndex(index)
	self.index = index
end

function ScratchTicketViewItem:OnFlush()
	if self.data == nil  then return end

	self.item_cell:SetData(self.data.reward_item[0])
	self.num:SetValue(self.data.acc_count)
    
    local count = ScratchTicketData.Instance:GetGuaGuaCount() or 0
	if count >= self.data.acc_count and 
		not ScratchTicketData.Instance:GetCanFetchFlag(self.index) then
		self.item_cell:ShowGetEffect(true)
		self.item_cell:ListenClick(BindTool.Bind(self.OnClick, self))
	else
		self.item_cell:ShowGetEffect(false)
		self.item_cell:ListenClick()
	end

    local flag = ScratchTicketData.Instance:GetCanFetchFlag(self.index)
	if flag then
		self.item_cell:ShowHaseGet(true)
	else
		self.item_cell:ShowHaseGet(false)
	end

end
--点击奖励物品事件
function ScratchTicketViewItem:OnClick()
	KaifuActivityCtrl.Instance:SendGetKaifuActivityInfo(ACTIVITY_TYPE.RAND_ACTIVITY_DINGGUAGUA, RA_GUAGUA_OPERA_TYPE.RA_GUAGUA_OPREA_TYPE_FETCH_REWARD, self.index - 1)
end

---------------------------------ScratchTicketViewShwoItem（展示格子）----------------------------------
ScratchTicketViewShwoItem = ScratchTicketViewShwoItem or BaseClass(BaseCell)
function ScratchTicketViewShwoItem:__init()
	self.image_list = {}
	for i=1,3 do
		self.image_list[i] = self:FindVariable("image_" .. i)
	end
	self.item_cell = ItemCell.New()
	self.item_cell:SetInstanceParent(self:FindObj("itemCell"))
end

function ScratchTicketViewShwoItem:__delete()
	self.image_list = {}
	self.item_cell:DeleteMe()
	self.item_cell = nil
end

function ScratchTicketViewShwoItem:OnFlush()
	if self.data == nil  then return end
	if self.data.is_special == 1 then
		for i = 1, 3 do
			local bundle, asset = ResPath.GetScratchTicketRes("wuxing_0" .. self.data["icon" .. i .. "_id"] + 1)
			self.image_list[i]:SetAsset(bundle, asset)
		end
		self.item_cell:SetData(self.data.reward_item[0])
	end	
end