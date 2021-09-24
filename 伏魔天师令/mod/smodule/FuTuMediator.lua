local FuTuMediator = classGc(mediator, function(self, _view)
    self.name = "FuTuMediator"
    self.view = _view

    self:regSelf()
end)

FuTuMediator.protocolsList={
    _G.Msg.ACK_FIGHTERS_CHAP_DATA,
    _G.Msg.ACK_FIGHTERS_UP_REPLY,
}

FuTuMediator.commandsList=nil

function FuTuMediator.ACK_FIGHTERS_CHAP_DATA(self,_ackMsg)
    for k,v in pairs(_ackMsg) do
        print(k,v)
    end
    for i=1,#_ackMsg.copyData do
        print("==============>>>",i)
        for k,v in pairs(_ackMsg.copyData[i]) do
            print(k,v)
        end
    end
    self.view:msgCallBack(_ackMsg)
end

function FuTuMediator.ACK_FIGHTERS_UP_REPLY(self,_ackMsg)
    for k,v in pairs(_ackMsg.goods) do
        for kk,vv in pairs(v) do
            print(kk,vv)
        end
    end
    self.view:showMopAction(_ackMsg)
end


return FuTuMediator