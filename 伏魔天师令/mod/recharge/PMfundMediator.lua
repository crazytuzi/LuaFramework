PMfundMediator = classGc( mediator, function( self, _view )
          self.name = "PMfundMediator"
          self.view = _view
          self : regSelf()
end)

PMfundMediator.protocolsList={
    _G.Msg.ACK_PRIVILEGE_OPEN_CB,   -- 开启投资理财
    _G.Msg.ACK_PRIVILEGE_GET_REWARDS_CB, -- 领取 
    _G.Msg.ACK_PRIVILEGE_FUND_MSG,  -- 获取信息
}

PMfundMediator.commandsList=nil

function PMfundMediator.ACK_PRIVILEGE_OPEN_CB( self, _ackMsg )
    print("[ACK_PRIVILEGE_OPEN_CB]",_ackMsg.type)
    self : getView() : SUCC(_ackMsg)
end

function PMfundMediator.ACK_PRIVILEGE_GET_REWARDS_CB( self, _ackMsg )
    print("[ACK_PRIVILEGE_GET_REWARDS_CB]-->",_ackMsg.type)
    self : getView() : ReturnRewards(_ackMsg)
end

function PMfundMediator.ACK_PRIVILEGE_FUND_MSG( self, _ackMsg )
    print("[ACK_PRIVILEGE_FUND_MSG]-->",_ackMsg.seconds,_ackMsg.type,_ackMsg.is,_ackMsg.bool,_ackMsg.acc)
    self : getView() : msgData(_ackMsg)
end

return PMfundMediator