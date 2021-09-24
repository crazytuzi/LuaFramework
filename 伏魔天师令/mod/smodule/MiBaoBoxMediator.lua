local MiBaoBoxMediator = classGc(mediator, function(self, _view)
    self.name = "MiBaoBoxMediator"
    self.view = _view

    self:regSelf()
end)

MiBaoBoxMediator.protocolsList={
    _G.Msg.ACK_MIBAO_REPLY,
}

MiBaoBoxMediator.commandsList=nil

function MiBaoBoxMediator.ACK_MIBAO_REPLY(self,_ackMsg)
    print("ACK_MIBAO_REPLY====>>>")
    for k,v in pairs(_ackMsg.msg_xxx) do
        print(k,v)
    end
    self:getView():msgCallBack(_ackMsg.msg_xxx)
end

return MiBaoBoxMediator