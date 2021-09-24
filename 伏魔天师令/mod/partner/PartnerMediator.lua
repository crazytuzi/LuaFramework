local PartNerMediator = classGc(mediator, function(self, _view)
    self.name = "PartNerMediator"
    self.view = _view

    self:regSelf()
end)

PartNerMediator.protocolsList={
    _G.Msg["ACK_LINGYAO_REPLY"],
    _G.Msg["ACK_LINGYAO_RENOWN"],
    _G.Msg["ACK_LINGYAO_ATTR_ALL_REPLY"],
    _G.Msg["ACK_LINGYAO_MSG_XXX"],
    _G.Msg["ACK_LINGYAO_COPY_OPEN"],
    _G.Msg["ACK_LINGYAO_SHENJIE_BACK"],
    _G.Msg["ACK_ROLE_SYS_POINTS_INN"],
}

PartNerMediator.commandsList={
    CProxyUpdataCommand.TYPE,
    CGuideNoticDel.TYPE
}

function PartNerMediator.processCommand(self, _command)
    if _command:getType()==CProxyUpdataCommand.TYPE then
        self.view:updateProxyData()
    elseif _command:getType()==CGuideNoticDel.TYPE then
        self.view:guideDelete(_command.guideId)
    end
end

function PartNerMediator.getView(self)
    return self.view
end


function PartNerMediator.ACK_LINGYAO_REPLY(self, _ackMsg)
    print("ACK_LINGYAO_REPLY==>>",_ackMsg.count)
    -- print("ACK_LINGYAO_REPLY==>>",_ackMsg.msg_xxx)
    for k,v in pairs(_ackMsg.msg_xxx) do
        print("k,v.class",k,v.class)
    end
    if _ackMsg.type~=1 then return end
    self:getView():updateData(_ackMsg.count,_ackMsg.msg_xxx)
end

function PartNerMediator.ACK_ROLE_SYS_POINTS_INN(self, _ackMsg)
    print("ACK_ROLE_SYS_POINTS_INN==>>",_ackMsg.count)
    self:getView():updatePointData(_ackMsg.count,_ackMsg.msg_xxx)
end

function PartNerMediator.ACK_LINGYAO_MSG_XXX(self, _ackMsg)
    self:getView():updateOneData(_ackMsg)
end

function PartNerMediator.ACK_LINGYAO_RENOWN(self, _ackMsg)
    self:getView():setRenown(_ackMsg.renown)
end

function PartNerMediator.ACK_LINGYAO_ATTR_ALL_REPLY(self, _ackMsg)
    print("ACK_LINGYAO_ATTR_ALL_REPLY===>>>",_ackMsg.attr_xxx.hp)
    self:getView():attrView(_ackMsg.attr_xxx)
end

function PartNerMediator.ACK_LINGYAO_COPY_OPEN(self, _ackMsg)
    print("ACK_LINGYAO_COPY_OPEN===>>>",_ackMsg.count)
    self:getView():updateCopyLab(_ackMsg)
end

function PartNerMediator.ACK_LINGYAO_SHENJIE_BACK(self)
    print("ACK_LINGYAO_SHENJIE_BACK===>>>")
    self:getView():SuccessUpMusic()
end

return PartNerMediator