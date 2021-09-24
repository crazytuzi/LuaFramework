local NFZPRebateMediator = classGc(mediator, function(self, _view)
    self.name = "NFZPRebateMediator"
    self.view = _view

    self:regSelf()
end)

NFZPRebateMediator.protocolsList={
    _G.Msg["ACK_ART_ZHUANPAN_GOOD"],     --转盘物品(回)
}

NFZPRebateMediator.commandsList=nil

function NFZPRebateMediator.processCommand(self, _command)
end

function NFZPRebateMediator.ACK_ART_ZHUANPAN_GOOD(self, _ackMsg)
    print( "-- ACK_ART_ZHUANPAN_GOOD")
    self.view : updateData(_ackMsg)
end

return NFZPRebateMediator