local ServantMediator = classGc(mediator, function(self, _view)
    self.name = "ServantMediator"
    self.view = _view

    self:regSelf()
end)

ServantMediator.protocolsList={
    _G.Msg["ACK_MOIL_MOIL_DATA"],	 --身份信息
    _G.Msg["ACK_MOIL_PRESS_YDATA"],	 --苦工信息
    _G.Msg["ACK_MOIL_PLAYER_DATA"],	 --玩家信息列表
    _G.Msg["ACK_MOIL_TMOILS_BACK"],  --玩家拥有奴仆列表
    _G.Msg["ACK_MOIL_PRESS_RS"],     --提取压榨
    _G.Msg["ACK_MOIL_BUY_OK"],       --剩余抓捕次数
}

ServantMediator.commandsList=nil
function ServantMediator.processCommand(self, _command)
end

function ServantMediator.ACK_MOIL_MOIL_DATA(self, _ackMsg)
    print( "-- ACK_MOIL_MOIL_DATA")
    for i=1,_ackMsg.count do
    	print("name:",_ackMsg.data[i].name,"bname:",_ackMsg.data[i].bname)
    end
    self.view : updateMainView(_ackMsg)
end

function ServantMediator.ACK_MOIL_PRESS_YDATA(self, _ackMsg)
    print( "-- ACK_MOIL_PRESS_YDATA")
    self.view : updateLeftView(_ackMsg)
end

function ServantMediator.ACK_MOIL_PLAYER_DATA(self, _ackMsg)
    print( "-- ACK_MOIL_PLAYER_DATA")
    if     _ackMsg.type == 1 then
    	self.view : updateLoserUI(_ackMsg)
    elseif _ackMsg.type == 7 then
    	self.view : updateEnemyUI(_ackMsg)
    end
end

function ServantMediator.ACK_MOIL_TMOILS_BACK(self, _ackMsg)
    print( "-- ACK_MOIL_TMOILS_BACK")
    self.view : initServantMsg(_ackMsg)
end

function ServantMediator.ACK_MOIL_PRESS_RS(self, _ackMsg)
    print( "-- ACK_MOIL_PRESS_RS")
    self.view : initServantMsg(_ackMsg)
end

function ServantMediator.ACK_MOIL_PRESS_RS(self, _ackMsg)
    print( "-- ACK_MOIL_PRESS_RS")
    self.view : initServantMsg(_ackMsg)
end

function ServantMediator.ACK_MOIL_BUY_OK(self, _ackMsg)
    print( "-- ACK_MOIL_BUY_OK")
    self.view : updateCaptureCount(_ackMsg)
end

return ServantMediator