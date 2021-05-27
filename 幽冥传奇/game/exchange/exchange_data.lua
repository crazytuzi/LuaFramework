ExchangeData = ExchangeData or BaseClass()

ExchangeData.EXCHANGE_BEGIN = "exchange_begin"
ExchangeData.EXCHANGE_MY_INFO = "exchange_my_info"
ExchangeData.EXCHANGE_OPPOSITE_INFO = "exchange_opposite_info"
ExchangeData.EXCHANGE_MY_MONEY = "exchange_my_money"
ExchangeData.EXCHANGE_OPPO_MONEY = "exchange_oppo_money"
ExchangeData.EXCHANGE_OWN_LOCKED = "exchange_own_locked"
ExchangeData.EXCHANGE_OTHER_LOCKED = "exchange_other_locked"

function ExchangeData:__init()
	if ExchangeData.Instance then
		ErrorLog("[ExchangeData] Attemp to create a singleton twice !")
	end
	ExchangeData.Instance = self
	self.role_entity_id = nil
	self.my_name = ""
	self.opposite_name = ""
	self.opposite_role_id = nil
	self.opposite_lev = nil
	self.is_add_succe = nil
	self.bool_success = nil
	self.my_money_number = 0
	self.oppo_money_number = 0
	self.money_type = 0
	self.myself_locking = 0
	self.opposite_locking = 0
	self.locking_state = 0
	self.exchange_req_list ={} 	--交易申请列表
	self.opposite_items_t = {}	--对方投入物品列表
	self.my_input_items_t = {}	--自己投入物品列表

	GameObject.Extend(self):AddComponent(EventProtocol):ExportMethods()
end

function ExchangeData:__delete()
	ExchangeData.Instance = nil	
end

--交易请求
function ExchangeData:SetReturnExchange(protocol)
	-- for k,v in pairs(self.exchange_req_list) do
	-- 	if v.my_name == protocol.my_name then
	-- 		return
	-- 	end
	-- end
	local data = {}
	data.role_entity_id = protocol.role_entity_id
	data.my_name = protocol.my_name
	table.insert(self.exchange_req_list, data)
	self:DispatchEvent(ExchangeData.EXCHANGE_BEGIN)
end

--交易被拒绝
function ExchangeData:SetRefuseExchange(protocol)
	-- for k,v in pairs(self.exchange_req_list) do
	-- 	if v.my_name == protocol.opposite_name then
	-- 	end
	-- end
end

function ExchangeData:GetExchangeApplyList()
	return self.exchange_req_list
end

function ExchangeData:EmptyExchangeInfo()
	self.my_input_items_t = {}
	self.opposite_items_t = {}
	self.oppo_money_number = 0
	self.my_money_number = 0
	self.money_type = 0
	self.locking_state = 0
	self.myself_locking = 0
	self.opposite_locking = 0
end

--开始交易
function ExchangeData:SetBeginExchange(protocol)
	self.opposite_role_id = protocol.opposite_role_id
	self.opposite_name = protocol.opposite_name 
	self.opposite_lev = protocol.opposite_lev
	self:DispatchEvent(ExchangeData.EXCHANGE_BEGIN)
end

--返回自己投入物品结果
function ExchangeData:SetInputItemResult(protocol)
	if protocol.is_add_succe == 1 then
		local item_data = BagData.Instance:GetItemInBagBySeries(protocol.serial)
		if not self.my_input_items_t[0] then
			self.my_input_items_t[0] = item_data
		else
			table.insert(self.my_input_items_t, item_data)
		end
		self:DispatchEvent(ExchangeData.EXCHANGE_MY_INFO)
	end
end

--得到自己要交易物品的列表
function ExchangeData:GetMyInputItemsList()
	return self.my_input_items_t
end

--交易对方投入物品
function ExchangeData:SetOppositeInputItem(protocol)
	if protocol.item == nil then return end
	if not self.opposite_items_t[0] then
		self.opposite_items_t[0] = protocol.item
	else
		table.insert(self.opposite_items_t, protocol.item)
	end
	self:DispatchEvent(ExchangeData.EXCHANGE_OPPOSITE_INFO)
end

--得到对方要交易的物品列表
function ExchangeData:GetOppoItemsList()
	return self.opposite_items_t
end

--返回改变交易金钱数量结果(bool：改变成功否，INT：当前我交易的金钱数量)
function ExchangeData:SetMyChangeExchangeMoneyResult(protocol)
	if protocol.bool_success == 1 then
		self.my_money_number = protocol.money_number
		self.money_type = protocol.money_type
	end
	self:DispatchEvent(ExchangeData.EXCHANGE_MY_MONEY)
end

function ExchangeData:GetMyExchangeMoney()
	return self.my_money_number
end

--交易对方改变交易金钱数量(INT：金钱数量)
function ExchangeData:SetOppositeChangeExchangeMoneyResult(protocol)
	self.oppo_money_number = protocol.money_number
	self.money_type = protocol.money_type
	self:DispatchEvent(ExchangeData.EXCHANGE_OPPO_MONEY)
end

function ExchangeData:GetOppositeExchangeMoney()
	return self.oppo_money_number
end

--交易锁定状态变更
function ExchangeData:SetExchanLockStateChangeResult(protocol)
	self.myself_locking = protocol.myself_locking 
	self.opposite_locking = protocol.opposite_locking
	if self.myself_locking == 1 then
		self:SetLockState(1)
		self:DispatchEvent(ExchangeData.EXCHANGE_OWN_LOCKED)
	end
	if self.opposite_locking == 1 then
		self:DispatchEvent(ExchangeData.EXCHANGE_OTHER_LOCKED)
	end
end

function ExchangeData:OppositeLocking()
	return self.opposite_locking == 1
end

--交易尚未锁定
function ExchangeData:SetExchangeNotLock(protocol)
	self.locking_state = protocol.locking_state
end

function ExchangeData:SetLockState(lock_state)
	self.locking_state = lock_state
end

function ExchangeData:GetLockState()
	return self.locking_state
end

--得到交易人的名字
function ExchangeData:GetTraderName()
	return self.opposite_name
end

--得到交易人的等级
function ExchangeData:GetTraderLevel()
	return self.opposite_lev
end

--获得背包中可用于交易的物品
function ExchangeData.GetCanExchangeItemsData()
	local bag_list = {}
	local index = 0
	for k, v in pairs(BagData.Instance:GetItemDataList()) do
		if v.is_bind == 0 then
			bag_list[index] = v
			index = index + 1
		end
	end
	return bag_list
end

