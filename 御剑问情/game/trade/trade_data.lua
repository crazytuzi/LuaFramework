TradeData = TradeData or BaseClass()

TradeData.TradeState = {
		None = 0,											-- 空闲状态
		Trading = 1,										-- 交易中
		Luck = 2,											-- 锁定
		Affirm = 3,											-- 确认
		AffirmSuc = 4,										-- 确认成功 交易完成
		Cancel = 5,											-- 交易取消
}
TradeData.MaxTradeItem = 4

function TradeData:__init()
	if TradeData.Instance ~= nil then
		print_error("[TradeData] attempt to create singleton twice!")
		return
	end
	TradeData.Instance = self
	self.my_trade_item = {}
	self.other_trade_item = {}
	self.other_role_info = nil
end

function TradeData:__delete()
	self.my_trade_item = nil
	self.other_trade_item = nil
	self.trade_state = nil
	self.trade_item_info = nil
	self.trade_itemparam_info = nil
	TradeData.Instance = nil
end

function TradeData:SetSendTradeRoleInfo(protocol)
	self.send_trade_role_info = protocol
	AvatarManager.Instance:SetAvatarKey(protocol.req_uid, protocol.avatar_key_big, protocol.avatar_key_small)
end

function TradeData:GetSendTradeRoleInfo()
	return self.send_trade_role_info
end

function TradeData:SetTradeState(protocol)
	self.trade_state = protocol
	self.other_role_info = {}
	self.other_role_info.uid = protocol.other_uid
	self.other_role_info.name = protocol.other_name
	self.other_role_info.avatar_key_big = protocol.other_avatar_key_big
	self.other_role_info.avatar_key_small = protocol.other_avatar_key_small
	self.other_role_info.sex = protocol.other_sex
	self.other_role_info.prof = protocol.other_prof
end

function TradeData:GetTradeState()
	return self.trade_state
end

function TradeData:GetTradeOtherRoleInfo()
	return self.other_role_info
end

function TradeData:SetTradeItemInfo(protocol)
	self.trade_item_info = protocol
end

function TradeData:GetTradeItemInfo()
	return self.trade_item_info
end

function TradeData:SetTradeItemParamInfo(protocol)
	self.trade_itemparam_info = protocol
end

function TradeData:GetTradeItemParamInfo()
	return self.trade_itemparam_info
end

function TradeData:AddTradeItem(protocol)
	local vo = {}
	vo.knapsack_index = protocol.knapsack_index
	vo.index = protocol.trade_index
	vo.is_bind = 0
	vo.invalid_time = protocol.invalid_time
	if protocol.item_wrapper then
		vo.item_id = protocol.item_wrapper.item_id
		vo.num = protocol.item_wrapper.num
		vo.param = protocol.item_wrapper.param
		vo.has_param = 1
	else
		vo.item_id = protocol.item_id
		vo.num = protocol.num
		vo.has_param = 0
	end

	if 0 == protocol.is_me then
		self.my_trade_item[vo.index] = vo 		--自己交易物品表
	elseif 1 == protocol.is_me then
		self.other_trade_item[vo.index] = vo 	--对方交易物品表
	end
	TradeCtrl.Instance.trade_view:Flush("item_req", {is_me = protocol.is_me})
end

-- 删除交易物品
function TradeData:DeleteTradeItem(protocol)
	if nil == protocol.is_me or nil == protocol.trade_index then return end
	if 0 == protocol.is_me then
		self.my_trade_item[protocol.trade_index] = nil 		--自己交易物品表
	elseif 1 == protocol.is_me then
		self.other_trade_item[protocol.trade_index] = nil 	--对方交易物品表
	end
	TradeCtrl.Instance.trade_view:Flush("item_req", {is_me = protocol.is_me, knapsack_index = protocol.knapsack_index})
end

-- 获取自己交易架上的空格子
function TradeData:GetMyTradeItemLen()
	for i = 1, TradeData.MaxTradeItem do
		if nil == self.my_trade_item[i] then
			return i
		end
	end
	return -1
end

-- 获取自己要交易的所有物品
function TradeData:GetMyTradeItem()
	return self.my_trade_item
end

-- 获取对方要交易的所有物品
function TradeData:GetOtherTradeItem()
	return self.other_trade_item
end

function TradeData:ClearTradeItemData()
	self.my_trade_item = {}
	self.other_trade_item = {}
end