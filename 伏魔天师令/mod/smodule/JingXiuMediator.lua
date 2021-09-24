local JingXiuMediator = classGc(mediator, function(self, _view)
    self.name = "JingXiuMediator"
    self.view = _view

    self:regSelf()
end)

JingXiuMediator.protocolsList={
    _G.Msg["ACK_FUTU_LEFT_TIME"],	 --占领剩余时间
    _G.Msg["ACK_FUTU_REPLY"],       --浮屠静修数据
    _G.Msg["ACK_FUTU_HISTORY_REP"], --战报
    _G.Msg["ACK_FUTU_TIMES_REPLY"], --购买次数 
    _G.Msg["ACK_FUTU_MSG"],         --占领层的信息
    _G.Msg["ACK_FUTU_PLAYER_REP"],  --玩家信息
    _G.Msg["ACK_SYSTEM_ERROR"],
}

JingXiuMediator.commandsList=nil
function JingXiuMediator.processCommand(self, _command)
end

function JingXiuMediator.ACK_FUTU_LEFT_TIME(self, _ackMsg)
    print( "-- ACK_FUTU_LEFT_TIME")
    local remainingTime = _G.Const.CONST_FIGHTERS_MAX_TIME - _ackMsg.time2
    print(remainingTime,"   ",_ackMsg.time2,"  ",_ackMsg.time)
    self.view           : updateRemainingTime(remainingTime)
end

function JingXiuMediator.ACK_FUTU_REPLY(self, _ackMsg)
    print( "-- ACK_FUTU_REPLY")
    self.view : updateMainView(_ackMsg)
end

function JingXiuMediator.ACK_FUTU_HISTORY_REP(self, _ackMsg)
    print( "-- ACK_FUTU_HISTORY_REP")
    self.view : updateCombatMsg(_ackMsg)
end

function JingXiuMediator.ACK_FUTU_TIMES_REPLY(self, _ackMsg)
    print( "-- ACK_FUTU_TIMES_REPLY")
    self.view : updateCombatCount(_ackMsg)
end

function JingXiuMediator.ACK_FUTU_MSG(self, _ackMsg)
    print( "-- ACK_FUTU_MSG")
    --self.view : updateFloor(_ackMsg)
end

function JingXiuMediator.ACK_FUTU_PLAYER_REP(self, _ackMsg)
    print( "-- ACK_FUTU_PLAYER_REP")
    print("时间：",_ackMsg.time)
    self.view : initPersonMsg(_ackMsg)
end

function JingXiuMediator.ACK_SYSTEM_ERROR(self, _ackMsg)
    print( "-- ACK_SYSTEM_ERROR",_ackMsg.error_code)
    if  _ackMsg.error_code == 37425 then
    	self.view : errorReturn()
    end
end

return JingXiuMediator