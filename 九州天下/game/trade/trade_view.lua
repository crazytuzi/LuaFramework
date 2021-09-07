TradeView = TradeView or BaseClass(BaseView)

local MAX_NUM = 144
local COLUMN_NUM = 4
local ROW_NUM = 4

function TradeView:__init()
	self.ui_config = {"uis/views/tradeview", "TradeView"}
	self.play_audio = true
	self.me_items = {}
	self.other_items = {}
	self.my_trade_item = {}

	self.role_head = GlobalEventSystem:Bind(ObjectEventType.HEAD_CHANGE, BindTool.Bind(self.SetRoleHead, self))

	self.item_cell_list = {}
	self.can_trade_list = {}

end

function TradeView:__delete()
	if self.role_head ~= nil then
		GlobalEventSystem:UnBind(self.role_head)
		self.role_head = nil
	end

end

function TradeView:ReleaseCallBack()
	if self.item_data_event ~= nil then
		ItemData.Instance:UnNotifyDataChangeCallBack(self.item_data_event)
		self.item_data_event = nil
	end

	for k, v in pairs(self.me_items) do
		if v.item then
			v.item:DeleteMe()
		end
	end
	self.me_items = {}

	for k, v in pairs(self.other_items) do
		if v.item then
			v.item:DeleteMe()
		end
	end

	for k, v in pairs(self.item_cell_list) do
		v:DeleteMe()
	end
	self.item_cell_list = {}
	
	self.other_items = {}
	self.show_me_lock = nil
	self.show_other_lock = nil

	-- 清理变量
	self.list = nil
	self.me_raw_image = nil
	self.me_image = nil
	self.other_raw_image = nil
	self.other_image = nil
	self.suer_button = nil
	self.lock_button = nil
	self.me_role_name = nil
	self.me_portait = nil
	self.other_role_name = nil
	self.other_portait = nil
	self.show_me_lock = nil
	self.show_other_lock = nil
end

function TradeView:OpenCallBack()
	self.is_click_lock = false
	self.is_click_sure = false
	self.show_me_lock:SetValue(false)
	self.show_other_lock:SetValue(false)
	self:Flush()
end

function TradeView:CloseCallBack()
	self.is_click_lock = nil
	self.is_click_sure = nil
	self.me_path = nil
	self.other_path = nil
	self.my_trade_item = {}
	self.knapsack_index = nil
end

function TradeView:LoadCallBack()
	for i = 1, 4 do
		self.me_items[i] = {item = ItemCell.New(self:FindObj("MeItem"..i)), name = self:FindVariable("MeItemPropName" .. i)}
		self.other_items[i] = {item = ItemCell.New(self:FindObj("OtherItem" .. i)), name = self:FindVariable("OtherItemPropName" .. i)}
		self:ListenEvent("MeItemClick" .. i, BindTool.Bind(self.OnClickMeTradeItem, self, i))
	end
	self.me_raw_image = self:FindObj("MeRawImage")
	self.me_image = self:FindObj("MeImage")
	self.other_raw_image = self:FindObj("OtherRawImage")
	self.other_image = self:FindObj("OtherImage")
	self.suer_button = self:FindObj("SureButton")
	self.lock_button = self:FindObj("LockButton")

	self.me_role_name = self:FindVariable("MeRoleName")
	self.me_portait = self:FindVariable("MePortait")
	self.other_role_name = self:FindVariable("OtherRoleName")
	self.other_portait = self:FindVariable("OtherPortait")
	self.show_me_lock = self:FindVariable("ShowMeLock")
	self.show_other_lock = self:FindVariable("ShowOtherLock")


	self:ListenEvent("Close", BindTool.Bind(self.OnClickClose, self))
	self:ListenEvent("Sure", BindTool.Bind(self.OnClickSure, self))
	self:ListenEvent("Lock", BindTool.Bind(self.OnClickLock, self))

	self.list = self:FindObj("List")
	local list_delegate = self.list.list_simple_delegate
	list_delegate.NumberOfCellsDel = BindTool.Bind(self.GetNumberOfCells, self)
	list_delegate.CellRefreshDel = BindTool.Bind(self.RefreshCell, self)

	if self.item_data_event == nil then
		self.item_data_event = BindTool.Bind1(self.ItemDataChangeCallback, self)
		ItemData.Instance:NotifyDataChangeCallBack(self.item_data_event)
	end

	self:Flush("item_req")
end

function TradeView:ItemDataChangeCallback(change_item_id, change_item_index, change_reason, put_reason, old_num, new_num, old_data)
	if change_item_index ~= nil then
		local data = ItemData.Instance:GetGridData(change_item_index)
		if data ~= nil and data.is_bind ~= 1 then
			self:FlushTradeView()
		end
	end
end

function TradeView:FlushTradeView()
	self.can_trade_list = ItemData.Instance:GetCanTradeList()
	self.list.scroller:RefreshActiveCellViews()
end

function TradeView:GetNumberOfCells()
	return MAX_NUM / COLUMN_NUM
end

function TradeView:RefreshCell(cell, data_index)
	local group = self.item_cell_list[cell]
	if not group then
		group = TradeItemCellGroup.New(cell.gameObject)
		group:SetToggleGroup(self.list.toggle_group)
		self.item_cell_list[cell] = group
	end

	local page = math.floor(data_index / COLUMN_NUM)
	local column = data_index - page * COLUMN_NUM
	local grid_count = COLUMN_NUM * ROW_NUM
	for i = 1, ROW_NUM do
		local index = (i - 1) * COLUMN_NUM  + column + (page * grid_count)

		-- 获取数据信息
		local data = nil
		--data = ItemData.Instance:GetGridData(index)
		data = self.can_trade_list[index + 1]
		data = data or {}
		data.locked = index >= ItemData.Instance:GetMaxKnapsackValidNum()
		if data.index == nil then
			data.index = index
		end
		group:SetData(i, data)
		group:SetIconGrayVisible(i, data.is_bind == 1)
		group:SetIconGrayScale(i, data.is_bind == 1)
		group:ShowQuality(i, nil ~= data.item_id and data.is_bind ~= 1)
		-- group:ShowHighLight(i, false)
		-- group:SetHighLight(i, false)
		group:ListenClick(i, BindTool.Bind(self.HandleBagOnClick, self, data, group, i))
		group:SetInteractable(i, nil ~= data.item_id)
		if #self.my_trade_item > 0 then
			for k, v in pairs(self.my_trade_item) do
				if data ~= nil and v.knapsack_index == data.bag_index then
					group:SetIconGrayVisible(i, true)
					group:SetCellLock(i, true)
				else
					group:SetCellLock(i, false)
				end
			end
		end
		if self.knapsack_index then
			if data ~= nil ~= nil and self.knapsack_index == data.bag_index then
				group:SetInteractable(i, true)
				self.knapsack_index = nil
			end
		end
	end
end

function TradeView:HandleBagOnClick(data, group, group_index)
	if self.is_click_lock then
		SysMsgCtrl.Instance:ErrorRemind(Language.Trade.TradeLuck)
		return
	end
	if not data.item_id then return end

	self.cur_index = data.index
	-- group:SetHighLight(group_index, self.cur_index == index)
	if data.is_bind == 1 or data.num == nil or data.num == 0 then
		return
	end
	local func = function (item_num)
		TradeCtrl.Instance:SendTradeItemReq(TradeData.Instance:GetMyTradeItemLen(), data.index, item_num)
		group:SetInteractable(group_index, false)
	end
	if data.num <= 1 then
		func(data.num)
		return
	end
	TipsCtrl.Instance:OpenCommonInputView(data.num, func, nil, data.num)
end

function TradeView:OnClickClose()
	TradeCtrl.Instance:SendTradeCancleReq()
	TradeData.Instance:ClearTradeItemData()
	self:Close()
end

function TradeView:OnClickSure()
	if self.is_click_sure and not self.is_click_lock then
		return
	end
	TradeCtrl.Instance:SendTradeAffirmReq()
	self.is_click_sure = true
end

function TradeView:OnClickLock()
	if self.is_click_lock then
		return
	end
	TradeCtrl.Instance:SendTradeLockReq()
	self.is_click_lock = true
end

-- 取消交易架上面的物品
function TradeView:OnClickMeTradeItem(index)
	local me_item_data = TradeData.Instance:GetMyTradeItem()[index]
	if me_item_data and not self.is_click_lock then
		TradeCtrl.Instance:SendTradeItemReq(index, -1, me_item_data.num)
	end
end

function TradeView:SetTradeInfo(protocol)
	local other_role_info = TradeData.Instance:GetSendTradeRoleInfo() or ScoietyData.Instance:GetSelectRoleInfo()
	local me_role_info = GameVoManager.Instance:GetMainRoleVo()
	if self.me_path == nil then
		local func = function ()
			self:SetRoleHead()
		end
		AvatarManager.Instance:GetAvatar(me_role_info.role_id, true, func)
	end
	if self.other_path == nil then
		local func = function ()
			self:SetRoleHead()
		end
		AvatarManager.Instance:GetAvatar(other_role_info.req_uid or other_role_info.user_id or other_role_info.role_id, true, func)
	end
	if protocol.trade_state == TradeData.TradeState.Luck then
		self.show_me_lock:SetValue(true)
	end
	if protocol.other_trade_state == TradeData.TradeState.Luck then
		self.show_other_lock:SetValue(true)
	end

	if protocol.trade_state == TradeData.TradeState.Luck and
		protocol.other_trade_state == TradeData.TradeState.Luck or protocol.other_trade_state == TradeData.TradeState.Affirm then
		self.lock_button:SetActive(false)
		self.suer_button:SetActive(true)
		self.suer_button.button.interactable = true
	else
		self.suer_button.button.interactable = false
	end
end

function TradeView:SetTradeItemData()
	for k, v in pairs(self.me_items) do
		local me_item_data = TradeData.Instance:GetMyTradeItem()[k]
		local other_item_data = TradeData.Instance:GetOtherTradeItem()[k]
		v.item:SetData(me_item_data or {})
		v.item:ListenClick(BindTool.Bind(self.OnClickMeTradeItemCell, self, k, me_item_data))
		self.other_items[k].item:SetData(other_item_data or {})
		self.other_items[k].item:ListenClick(BindTool.Bind(self.OnClickOtherTradeItemCell, self, k, other_item_data))
		if me_item_data then
			local item_cfg = ItemData.Instance:GetItemConfig(me_item_data.item_id)
			v.name:SetValue(item_cfg.name)
		else
			v.name:SetValue("")
		end
		if other_item_data then
			local item_cfg = ItemData.Instance:GetItemConfig(other_item_data.item_id)
			self.other_items[k].name:SetValue(item_cfg.name)
		else
			self.other_items[k].name:SetValue("")
		end
	end
end

function TradeView:OnClickMeTradeItemCell(index, me_item_data)
	TipsCtrl.Instance:OpenItem(me_item_data, nil, nil)
end

function TradeView:OnClickOtherTradeItemCell(index, me_item_data)
	TipsCtrl.Instance:OpenItem(me_item_data, nil, nil)
end

function TradeView:SetRoleHead()
	if not self:IsOpen() then
		return
	end
	local other_role_info = TradeData.Instance:GetSendTradeRoleInfo() or ScoietyData.Instance:GetSelectRoleInfo()
	self.other_role_name:SetValue(other_role_info.req_name or other_role_info.gamename or other_role_info.role_name)
	local other_avatar_key_big = AvatarManager.Instance:GetAvatarKey(other_role_info.req_uid or other_role_info.user_id or other_role_info.role_id, true)
	self.other_raw_image:SetActive(other_avatar_key_big ~= 0)
	self.other_image:SetActive(other_avatar_key_big == 0)
	if  other_avatar_key_big == 0 then
		local bundle, asset = AvatarManager.GetDefAvatar(other_role_info.prof, false, other_role_info.sex)
		self.other_portait:SetAsset(bundle, asset)
	else
		self.other_raw_image.raw_image:LoadSprite(self.other_path or AvatarManager.GetFilePath(other_role_info.req_uid
			or other_role_info.user_id or other_role_info.role_id, true), function()
		end)
	end

	local me_role_info = GameVoManager.Instance:GetMainRoleVo()
	self.me_role_name:SetValue(me_role_info.name)
	local me_avatar_key_big = AvatarManager.Instance:GetAvatarKey(me_role_info.role_id, true)

	self.me_raw_image:SetActive(me_avatar_key_big ~= 0)
	self.me_image:SetActive(me_avatar_key_big == 0)
	if me_avatar_key_big == 0 then
		local bundle, asset = AvatarManager.GetDefAvatar(me_role_info.prof, true, me_role_info.sex)
		self.me_portait:SetAsset(bundle, asset)
	else
		self.me_raw_image.raw_image:LoadSprite(self.me_path or AvatarManager.GetFilePath(me_role_info.role_id, true), function()
		end)
	end
end

function TradeView:OnFlush(param_t)
	for k, v in pairs(param_t) do
		if k == "item_req" then
			if v.is_me == 0 then
				self.knapsack_index = v.knapsack_index
				self.my_trade_item = TradeData.Instance:GetMyTradeItem()
				self:FlushTradeView()
			end
			self:SetTradeItemData()
		elseif k == "trade_state" then
			if self:IsOpen() then
				self:SetTradeInfo(v)
				self:FlushTradeView()
				self.lock_button.button.interactable = not self.is_click_lock
			end
		end
	end
end


TradeItemCellGroup = TradeItemCellGroup or BaseClass(BaseRender)

function TradeItemCellGroup:__init()
	self.cells = {}
	for i = 1, 4 do
		local item = self:FindObj("Item"..i)
		local cell = ItemCell.New(item)
		-- self.cells[i] = {item = item, cell = cell}
		self.cells[i] = ItemCell.New(self:FindObj("Item" .. i))
	end
end

function TradeItemCellGroup:__delete()
	for k, v in pairs(self.cells) do
		v:DeleteMe()
	end
	self.cells = {}
end

function TradeItemCellGroup:SetData(i, data)
	self.cells[i]:SetData(data)
end

function TradeItemCellGroup:SetInteractable(i, value)
	self.cells[i]:SetInteractable(value)
end

function TradeItemCellGroup:SetIconGrayScale(i, is_gray)
	self.cells[i]:SetIconGrayScale(is_gray)
end

function TradeItemCellGroup:ListenClick(i, handler)
	self.cells[i]:ListenClick(handler)
end

function TradeItemCellGroup:ClearItemEvent(i)
	self.cells[i]:ClearItemEvent()
end

function TradeItemCellGroup:SetIconGrayVisible(i, value)
	self.cells[i]:SetIconGrayVisible(value)
end

function TradeItemCellGroup:SetToggleGroup(toggle_group)
	for k,v in pairs(self.cells) do
		v:SetToggleGroup(toggle_group)
	end
end

function TradeItemCellGroup:SetHighLight(i, enable)
	self.cells[i]:SetHighLight(enable)
end

function TradeItemCellGroup:ShowHighLight(i, enable)
	self.cells[i]:ShowHighLight(enable)
end

function TradeItemCellGroup:ShowQuality(i, enable)
	self.cells[i]:OnlyShowQuality(enable)
end

function TradeItemCellGroup:SetCellLock(i, enable)
	self.cells[i]:SetCellLock(enable)
end