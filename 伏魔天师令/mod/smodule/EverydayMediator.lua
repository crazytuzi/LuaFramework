local EverydayMediator = classGc(mediator, function(self, _view)
    self.name = "EverydayMediator"
    self.view = _view

    self:regSelf()
end)

EverydayMediator.protocolsList={
    _G.Msg["ACK_N_CHARGE_REQUEST_CB"],	     --面板回复
    _G.Msg["ACK_N_CHARGE_REQUEST_N_CB"],
    _G.Msg["ACK_N_CHARGE_GET_REPLY"],    --领取奖励成功
}

EverydayMediator.commandsList=nil
function EverydayMediator.processCommand(self, _command)
end

function EverydayMediator.ACK_N_CHARGE_REQUEST_CB(self, _ackMsg)
    print( "-- ACK_N_CHARGE_REQUEST_CB")
    print("day",_ackMsg.n_day,"state",_ackMsg.state)
    self.view : initView(_ackMsg)
end

function EverydayMediator.ACK_N_CHARGE_REQUEST_N_CB(self, _ackMsg)
    print( "-- ACK_N_CHARGE_REQUEST_N_CB")
    self.view : initView(_ackMsg)
end

function EverydayMediator.ACK_N_CHARGE_GET_REPLY(self)
    print( "-- ACK_N_CHARGE_GET_REPLY")
    self.view : Success()
end

return EverydayMediator