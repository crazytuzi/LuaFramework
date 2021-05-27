require("scripts/game/exchange/exchange_data")
require("scripts/game/exchange/exchange_view")

ExchangeCtrl = ExchangeCtrl or BaseClass(BaseController)
function ExchangeCtrl:__init()
	if ExchangeCtrl.Instance then
		ErrorLog("[ExchangeCtrl] Attemp to create a singleton twice !")
	end
	ExchangeCtrl.Instance = self

	self.view = ExchangeView.New(ViewDef.Exchange)
	self.data = ExchangeData.New()

	self:RegisterAllProtocols()
	self.alert_window = nil
end

function ExchangeCtrl:__delete()
	ExchangeCtrl.Instance = nil
	self.alert_window = nil
	self.view:DeleteMe()
	self.view = nil

	self.data:DeleteMe()
	self.data = nil
end

function ExchangeCtrl:RegisterAllProtocols()
	self:RegisterProtocol(SCSendExchangereq,"OnExchangereq")
	self:RegisterProtocol(SCExchangeRefuse,"OnExchangeRefuse")
	self:RegisterProtocol(SCBeginExchange,"OnBeginExchange")
	self:RegisterProtocol(SCSelfInputItemResult,"OnSelfInputItemResult")
	self:RegisterProtocol(SCOppositeInputItem,"OnOppositeInputItem")
	self:RegisterProtocol(SCMyChangeExchangeMoneyResult,"OnMyChangeExchangeMoneyResult")
	self:RegisterProtocol(SCOppositeChangeExchangeMoneyResult,"OnOppositeChangeExchangeMoneyResult")
	self:RegisterProtocol(SCExchanLockStateChangeResult,"OnExchanLockStateChangeResult")
	self:RegisterProtocol(SCCancleExchange,"OnCancleExchange")
	self:RegisterProtocol(SCExchangeNotLock,"OnExchangeNotLock")
	self:RegisterProtocol(SCExchangeComplete,"OnExchangeComplete")
end

--返回交易请求
function ExchangeCtrl:OnExchangereq(protocol)
	self.data:SetReturnExchange(protocol)
	if SettingData.Instance:GetOneSysSetting(SETTING_TYPE.TRADE_REQUEST) then
		ExchangeCtrl.ReplyExchangeReq(protocol.role_entity_id, 0)
		return
	end
	self:CheckExchangeInfo()
	-- =================
	-- self:CreateTip()
end

--交易被拒绝
function ExchangeCtrl:OnExchangeRefuse(protocol)
	self.data:SetRefuseExchange(protocol)
end

--开始交易
function ExchangeCtrl:OnBeginExchange(protocol)
	self.data:SetBeginExchange(protocol)
	
	local del_index = nil
	for k,v in pairs(self.data:GetExchangeApplyList()) do
		if v.my_name == protocol.opposite_name then
			del_index = k
		end
	end
	if del_index then
		table.remove(self.data:GetExchangeApplyList(), del_index)
	end
	self:CheckExchangeInfo()
	self.view:Open()
end

--返回自己投入交易物品结果
function ExchangeCtrl:OnSelfInputItemResult(protocol)
	self.data:SetInputItemResult(protocol)
end

--交易对方添加物品
function ExchangeCtrl:OnOppositeInputItem(protocol)
	self.data:SetOppositeInputItem(protocol)
end

--返回自己改变交易金钱数量结果(bool：改变成功否，INT：当前我交易的金钱数量)
function ExchangeCtrl:OnMyChangeExchangeMoneyResult(protocol)
	self.data:SetMyChangeExchangeMoneyResult(protocol)
end

--交易对方改变金钱数量
function ExchangeCtrl:OnOppositeChangeExchangeMoneyResult(protocol)
	self.data:SetOppositeChangeExchangeMoneyResult(protocol)
end

--交易锁定状态变更
function ExchangeCtrl:OnExchanLockStateChangeResult(protocol)
	self.data:SetExchanLockStateChangeResult(protocol)
end

--交易已被取消
function ExchangeCtrl:OnCancleExchange(protocol)
	self.data:EmptyExchangeInfo()
	if not Cancel_Exchange then
		SysMsgCtrl.Instance:FloatingTopRightText(Language.Exchange.ExchangeCanceled)
	end
	Cancel_Exchange = false
	self.view:Close()
end

--交易尚未锁定
function ExchangeCtrl:OnExchangeNotLock(protocol)
	self.data:SetExchangeNotLock(protocol)
	-- if protocol.locking_state == 1 then
	-- end
end

--交易完成
function ExchangeCtrl:OnExchangeComplete(protocol)
	SysMsgCtrl.Instance:FloatingTopRightText(Language.Exchange.ExchangCompleted)
	ExchangeCtrl.CancelExchangReq(0)
end

--申请交易
function ExchangeCtrl.ApplyExchange(role_name)
	local protocol = ProtocolPool.Instance:GetProtocol(CSExchangeReq)
	protocol.role_name = role_name
	protocol:EncodeAndSend()
end

--回复交易请求
function ExchangeCtrl.ReplyExchangeReq(role_id, bool_accept)
	local protocol = ProtocolPool.Instance:GetProtocol(CSRespondExchangeReq)
	protocol.role_id = role_id
	protocol.bool_accept = bool_accept
	protocol:EncodeAndSend()
end

--添加交易物品
function ExchangeCtrl.InputItemReq(serial)
	local protocol = ProtocolPool.Instance:GetProtocol(CSAddExchangeItemReq)
	protocol.serial = serial
	protocol:EncodeAndSend()
end

--改变交易金钱的数量
function ExchangeCtrl.ChangeExchangeMoneyReq(money_number, money_type)
	local protocol = ProtocolPool.Instance:GetProtocol(CSChangeExchangeMoneyNumberReq)
	protocol.money_number = money_number
	protocol.money_type = money_type
	protocol:EncodeAndSend()
end

--锁定交易
function ExchangeCtrl.ExchangeLockReq()
	local protocol = ProtocolPool.Instance:GetProtocol(CSLockingExchangeReq)
	protocol:EncodeAndSend()
end

Cancel_Exchange = false
--请求取消交易
function ExchangeCtrl.CancelExchangReq(bool_exchange)
	local protocol = ProtocolPool.Instance:GetProtocol(CSCancleExchangeReq)
	protocol.bool_exchange = bool_exchange
	if bool_exchange == 0 then
		Cancel_Exchange = true
	end
	protocol:EncodeAndSend()
end

--确定交易
function ExchangeCtrl.ConfirmExchangeReq()
	local protocol = ProtocolPool.Instance:GetProtocol(CSSureExchangeReq)
	protocol:EncodeAndSend()
end

--检测交易信息来到
function ExchangeCtrl:CheckExchangeInfo()
	local apply_list = self.data:GetExchangeApplyList()
	local num = #apply_list or 0
	MainuiCtrl.Instance:InvateTip(MAINUI_TIP_TYPE.EXCHANGE, num, function ()
		self:CreateTip()
	end)
end

function ExchangeCtrl:CreateTip()
	if nil == self.alert_window then
		self.alert_window = Alert.New()
	end
	local name_tab = self.data:GetExchangeApplyList()
	local name = name_tab[1].my_name
	local des = string.format(Language.Exchange.Desc, name)
	self.alert_window:SetLableString(des)
	self.alert_window:SetIsAnyClickClose(false)
	self.alert_window:SetOkFunc(BindTool.Bind(self.SendAgreeHandler, self))
	self.alert_window:SetCancelFunc(BindTool.Bind(self.SendUnAgreeHander, self))
	self.alert_window:Open()			
end

function ExchangeCtrl:SendAgreeHandler()
	local tab = self.data:GetExchangeApplyList()
	local entity_id = tab[1] and tab[1].role_entity_id
	if entity_id then
		ExchangeCtrl.ReplyExchangeReq(entity_id, 1) --答应交易请求
	end
end

function ExchangeCtrl:SendUnAgreeHander()
	local tab = self.data:GetExchangeApplyList()
	local entity_id = tab[1] and tab[1].role_entity_id
	if entity_id then
		ExchangeCtrl.ReplyExchangeReq(entity_id, 0) --拒绝交易
		local del_index = nil
		table.remove(tab, 1)
		self:CheckExchangeInfo()
	end
end