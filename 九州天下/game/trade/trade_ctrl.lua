require("game/trade/trade_data")
require("game/trade/trade_view")

TradeCtrl = TradeCtrl or BaseClass(BaseController)

function TradeCtrl:__init()
	if TradeCtrl.Instance ~= nil then
		print_error("[TradeCtrl] attempt to create singleton twice!")
		return
	end
	TradeCtrl.Instance = self
	self.trade_data = TradeData.New()
	self.trade_view = TradeView.New(ViewName.TradeView)
	self:RegisterAllProtocols()
end

function TradeCtrl:__delete()
	TradeCtrl.Instance = nil

	self.trade_data:DeleteMe()
	self.trade_data = nil

	self.trade_view:DeleteMe()
	self.trade_view = nil
end

function TradeCtrl:RegisterAllProtocols()
	self:RegisterProtocol(SCReqTradeRoute, "GetTradeRouteReq");
	self:RegisterProtocol(SCTradeState, "GetTradeStateReq");
	self:RegisterProtocol(SCTradeItemParam, "GetTradeItemParamReq");
	self:RegisterProtocol(SCTradeItem, "GetTradeItemReq");
end

-- 发送交易请求
function TradeCtrl:SendTradeRouteReq(uid)
	-- 暂时屏蔽交易(需要开启的时候把下面注释去掉就OK)
	local cmd = ProtocolPool.Instance:GetProtocol(CSReqTrade)
	cmd.uid = uid
	cmd:EncodeAndSend()
end

-- 对方收到交易请求
function TradeCtrl:GetTradeRouteReq(protocol)
	self.trade_data:SetSendTradeRoleInfo(protocol)
	MainUICtrl.Instance.view:Flush(MainUIViewChat.IconList.TRADE_REQ, {true})
end

-- 发送交易请求结果
function TradeCtrl:SendTradeStateReq(result, req_uid)
	local cmd = ProtocolPool.Instance:GetProtocol(CSReqTradeRet)
	cmd.result = result
	cmd.req_uid = req_uid
	cmd:EncodeAndSend()
end

-- 交易状态返回
function TradeCtrl:GetTradeStateReq(protocol)
	self.trade_data:SetTradeState(protocol)
	if ViewManager.Instance:IsOpen(ViewName.TradeView)
		and (protocol.trade_state == TradeData.TradeState.AffirmSuc or
		protocol.trade_state == TradeData.TradeState.Cancel or protocol.trade_state == TradeData.TradeState.None) then
		ViewManager.Instance:Close(ViewName.TradeView)
		self.trade_data:ClearTradeItemData()
		return
	elseif not ViewManager.Instance:IsOpen(ViewName.TradeView) and
		(protocol.trade_state ~= TradeData.TradeState.None and protocol.trade_state ~= TradeData.TradeState.Cancel
		and protocol.trade_state ~= TradeData.TradeState.AffirmSuc) then
		ViewManager.Instance:Open(ViewName.TradeView)
	end
	if self.trade_view:IsOpen() then
		self.trade_view:Flush("trade_state", protocol)
	end
	if protocol.trade_state == TradeData.TradeState.AffirmSuc then
		SysMsgCtrl.Instance:ErrorRemind(Language.Trade.ScucssTrade)
	end
end

-- 请求将物品放上交易架
function TradeCtrl:SendTradeItemReq(trade_index, knapsack_index, item_num)
	local cmd = ProtocolPool.Instance:GetProtocol(CSTradeItemReq)
	cmd.trade_index = trade_index
	cmd.knapsack_index = knapsack_index
	cmd.item_num = item_num
	cmd:EncodeAndSend()
end

-- 物品放上交易架返回
function TradeCtrl:GetTradeItemReq(protocol)
	if protocol.item_id > 0 then
		self.trade_data:AddTradeItem(protocol)
	else
		self.trade_data:DeleteTradeItem(protocol)
	end
	self.trade_data:SetTradeItemInfo(protocol)
	self.trade_view:Flush("item_req")
end

-- 物品放上交易架返回(带参数物品[装备])
function TradeCtrl:GetTradeItemParamReq(protocol)
	if protocol.item_wrapper.item_id > 0 then
		self.trade_data:AddTradeItem(protocol)
	else
		self.trade_data:DeleteTradeItem(protocol.is_me, protocol.trade_index)
	end
	self.trade_data:SetTradeItemParamInfo(protocol)
	self.trade_view:Flush("item_req")
end

-- 请求交易锁定
function TradeCtrl:SendTradeLockReq()
	local cmd = ProtocolPool.Instance:GetProtocol(CSTradeLockReq)
	cmd:EncodeAndSend()
end

-- 确定交易请求
function TradeCtrl:SendTradeAffirmReq()
	local cmd = ProtocolPool.Instance:GetProtocol(CSTradeAffirmReq)
	cmd:EncodeAndSend()
end

-- 取消交易请求
function TradeCtrl:SendTradeCancleReq()
	local cmd = ProtocolPool.Instance:GetProtocol(CSTradeCancle)
	cmd:EncodeAndSend()
end