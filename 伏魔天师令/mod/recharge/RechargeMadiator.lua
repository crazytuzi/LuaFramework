RechargeMediator = classGc( mediator, function( self, _view )
          self.name = "RechargeMediator"
          self.view = _view
          self : regSelf()
end)

RechargeMediator.protocolsList={
    _G.Msg.ACK_SYSTEM_PAY_STATE,  -- 是否可充值
    _G.Msg.ACK_ART_PER_CHARGE,  -- 判断是否有首充
}

function RechargeMediator.ACK_ART_PER_CHARGE( self, _ackMsg )
    print("RechargeMediator.ACK_ART_PER_CHARGE",_ackMsg.count)
    if _ackMsg==nil then return end
    self : getView() : pushData(_ackMsg)
end

function RechargeMediator.ACK_SYSTEM_PAY_STATE( self, _ackMsg )
    print("[ACK_SYSTEM_PAY_STATE]-->",_ackMsg.state)
    if _ackMsg.state ~= 0 then
        print("可以充值")
        --1：可以充值   2：可以充值，而且之前没有充值过(首充)
        self : getView() : rechargeMoney()
    end
end

return RechargeMediator