EmailMediator = classGc( mediator, function( self, _view )
          self.name = "EmailMediator"
          self.view = _view
          self : regSelf()
end)

EmailMediator.protocolsList={
    _G.Msg.ACK_MAIL_LIST,       -- 请求列表成功 [8512]
    _G.Msg.ACK_MAIL_OK_PICK,    -- 提取物品成功 [8552]
    _G.Msg.ACK_MAIL_OK_DEL,     -- 邮件移出 [8562]
    _G.Msg.ACK_MAIL_INFO,       -- 邮件内容
}

function EmailMediator.ACK_MAIL_LIST( self, _ackMsg )
    print("EmailMediator.ACK_MAIL_LIST", _ackMsg.boxtype,_ackMsg.count)
    self : getView() : pushData(_ackMsg)
end

function EmailMediator.ACK_MAIL_INFO( self, _ackMsg)
    print("进入协议") 
    self : getView() : SuccessContent(_ackMsg)   
end

function EmailMediator.ACK_MAIL_OK_PICK( self, _ackMsg)        
    print("EmailMediator.ACK_MAIL_OK_PICK", _ackMsg.count)
    if _ackMsg.count <= 0 then return end
    
    if _ackMsg == nil then
        local command = CErrorBoxCommand( 1540 )
        controller : sendCommand(command)
    end
    self : getView() : setLabel(_ackMsg)
end

function EmailMediator.ACK_MAIL_OK_DEL( self, _ackMsg)
    print("EmailMediator.ACK_MAIL_OK_DEL", _ackMsg.count)
    if _ackMsg.count > 0 then
        print("删除成功")
        self : getView() : setDelView(_ackMsg)
    end
end

return EmailMediator