local RankingMediator = classGc(mediator, function(self, _view)
    self.name = "RankingMediator"
    self.view = _view

    self:regSelf()
end)

RankingMediator.protocolsList={
    _G.Msg.ACK_TOP_DATE_NEW2,
    _G.Msg.ACK_TOP_REPLY,
    _G.Msg.ACK_WAR_PK_REPLY_SELF,
}

RankingMediator.commandsList=nil

function RankingMediator.ACK_TOP_DATE_NEW2(self,_ackMsg)
    -- for k,v in pairs(_ackMsg) do
    --     print(k,v)
    -- end

    -- for k,v in pairs(_ackMsg.data) do
    --     print("==============>>>>>>>>",k)
    --     for kk,vv in pairs(v) do
    --         print(kk,vv)
    --     end
    -- end

    self.view:msgCallBack(_ackMsg)
end

function RankingMediator.ACK_WAR_PK_REPLY_SELF(self,_ackMsg)
    if _ackMsg.type==0 then
        self:getView():__showWaitPKView()
    else
        local command=CErrorBoxCommand(_ackMsg.type)
        controller:sendCommand(command)
    end
end

function RankingMediator.ACK_TOP_REPLY(self,_ackMsg)
    for k,v in pairs(_ackMsg.typeArray) do
        print("ACK_TOP_REPLY",k,v.type)
    end
    self.view:allTypeMsgBack(_ackMsg.typeArray)
end

return RankingMediator