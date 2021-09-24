local CardsMediator = classGc(mediator, function(self, _view)
    self.name = "CardsMediator"
    self.view = _view

    self:regSelf()
end)

CardsMediator.protocolsList={
    _G.Msg["ACK_MATCH_CARD_REPLY"],	     --面板回复
    _G.Msg["ACK_MATCH_CARD_CARD_MSG"],   --翻开一张
    _G.Msg["ACK_MATCH_CARD_MATCH_REPLY"],--对牌回复
    _G.Msg["ACK_MATCH_CARD_LOOK_REPLY"], --偷看一张
    _G.Msg["ACK_MATCH_CARD_LOOK_DOUBLE"],--偷看一对
}

CardsMediator.commandsList=nil
function CardsMediator.processCommand(self, _command)
end

function CardsMediator.ACK_MATCH_CARD_REPLY(self, _ackMsg)
    print( "-- ACK_MATCH_CARD_REPLY")
    self.view : initView(_ackMsg)
end

function CardsMediator.ACK_MATCH_CARD_CARD_MSG(self, _ackMsg)
    print( "-- ACK_MATCH_CARD_CARD_MSG")
    self.view : showOneIcon(_ackMsg)
end

function CardsMediator.ACK_MATCH_CARD_MATCH_REPLY(self, _ackMsg)
    print( "-- ACK_MATCH_CARD_MATCH_REPLY")
    self.view : showTwoIcon(_ackMsg)
end

function CardsMediator.ACK_MATCH_CARD_LOOK_REPLY(self, _ackMsg)
    print( "-- ACK_MATCH_CARD_LOOK_REPLY")
    self.view : lookOneIcon(_ackMsg)
end

function CardsMediator.ACK_MATCH_CARD_LOOK_DOUBLE(self, _ackMsg)
    print( "-- ACK_MATCH_CARD_LOOK_DOUBLE")
    self.view : lookTwoIcon(_ackMsg)
end
return CardsMediator