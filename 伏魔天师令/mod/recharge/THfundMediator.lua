THfundMediator = classGc( mediator, function( self, _view )
          self.name = "THfundMediator"
          self.view = _view
          self : regSelf()
end)

THfundMediator.protocolsList={
    -- _G.Msg.ACK_SYSTEM_PAY_STATE,  -- 是否可购买
    _G.Msg.ACK_YUEKA_REQUEST_CB,  -- 月卡信息
    -- _G.Msg.ACK_YUEKA_BUY_CB,-- 购买
    _G.Msg.ACK_YUEKA_GET_REWARDS_CB,    -- 领取
}

THfundMediator.commandsList=nil

function THfundMediator.ACK_YUEKA_REQUEST_CB( self, _ackMsg)
    print("[ACK_YUEKA_REQUEST_CB]",_ackMsg.isbuy,_ackMsg.count)
    self : getView() : pushdata(_ackMsg)
end

-- function THfundMediator.ACK_YUEKA_BUY_CB( self, _ackMsg )
--     print("[ACK_YUEKA_BUY_CB]-->",_ackMsg.type)
--     self : getView() : ReturnBuydata(_ackMsg)
-- end

function THfundMediator.ACK_YUEKA_GET_REWARDS_CB( self, _ackMsg )
    print("[ACK_YUEKA_GET_REWARDS_CB]-->",_ackMsg.type,_ackMsg.idx)
    self : getView() : RewardData(_ackMsg)
end

-- function THfundMediator.ACK_SYSTEM_PAY_STATE( self, _ackMsg )
--     print("[ACK_SYSTEM_PAY_STATE]-->",_ackMsg.state)
--     if _ackMsg.state ~= 0 then
--         print("可购买")
--         self : getView() : BuyCardMoney()
--     end
-- end

return THfundMediator