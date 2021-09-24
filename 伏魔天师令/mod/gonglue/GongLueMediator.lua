local GongLueMediator = classGc(mediator, function(self, _view)
    self.name = "GongLueMediator"
    self.view = _view

    self:regSelf()
end)

GongLueMediator.protocolsList={
    _G.Msg["ACK_GONGLUE_HY_DATA"],
    _G.Msg["ACK_GONGLUE_DAY_DATA"],
    _G.Msg["ACK_GONGLUE_STRONG_DATA"],
    _G.Msg["ACK_GONGLUE_SUCCESS"],
}

GongLueMediator.commandsList={
    CFunctionOpenCommand.TYPE
}


function GongLueMediator.getView(self)
    return self.view
end

function GongLueMediator.processCommand(self, _command)
    if _command:getType()==CFunctionOpenCommand.TYPE then
        if _command:getData()==CFunctionOpenCommand.TIMES_UPDATE then
            self.view:chuangIconNum(_command.sysId,_command.number)
        end
    end
    return false
end

function GongLueMediator.ACK_GONGLUE_HY_DATA(self, _ackMsg)
    self:getView():sethy(_ackMsg.hy_value, _ackMsg.box_count, _ackMsg.boxs, _ackMsg.hy_count, _ackMsg.hy)

end

function GongLueMediator.ACK_GONGLUE_DAY_DATA(self, _ackMsg)
    print("ACK_GONGLUE_DAY_DATA",_ackMsg.day,_ackMsg.activity_count)
    self:getView():setactivity( _ackMsg.day, _ackMsg.activity_count, _ackMsg.activitys )
end

function GongLueMediator.ACK_GONGLUE_STRONG_DATA(self, _ackMsg)
    print("ACK_GONGLUE_STRONG_DATA",_ackMsg.type,_ackMsg.strong_count, _ackMsg.strongs)
    self:getView() : setstrong(  _ackMsg.type, _ackMsg.strong_count, _ackMsg.strongs )
end

function GongLueMediator.ACK_GONGLUE_SUCCESS(self, _ackMsg)
    self:getView() : SUCCESS(_ackMsg)
end
return GongLueMediator