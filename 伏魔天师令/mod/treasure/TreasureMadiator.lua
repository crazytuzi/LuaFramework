local TreasureMadiator = classGc(mediator, function(self, _view)
    self.name = "TreasureMadiator"
    self.view = _view

    self:regSelf()
end)

TreasureMadiator.protocolsList={
    _G.Msg["ACK_TREASURE_REQUEST_INFO"],	     --面板回复
    _G.Msg["ACK_TREASURE_SUCCESS_DZ"],
}

TreasureMadiator.commandsList=nil
function TreasureMadiator.processCommand(self, _command)
end

function TreasureMadiator.ACK_TREASURE_REQUEST_INFO(self, _ackMsg)
    print( "-- ACK_TREASURE_REQUEST_INFO")
    print("floor",_ackMsg.level_id)
    print("count",_ackMsg.count)
    for k,v in pairs(_ackMsg.goods_msg_no) do
    	print(k,v.goods_id,v.state)
    end
    self.view:updateLeft(_ackMsg)
end

function TreasureMadiator.ACK_TREASURE_SUCCESS_DZ(self, _ackMsg)
    print( "-- ACK_TREASURE_SUCCESS_DZ")
    self.view:showStrengthOkEffect()
end

return TreasureMadiator 