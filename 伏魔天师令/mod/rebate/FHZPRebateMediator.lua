local FHZPRebateMediator = classGc(mediator, function(self, _view)
    self.name = "FHZPRebateMediator"
    self.view = _view

    self:regSelf()
end)

FHZPRebateMediator.protocolsList={
    _G.Msg["ACK_ART_ZHUANPAN_GOOD"],     --转盘物品(回)
}

FHZPRebateMediator.commandsList=nil

function FHZPRebateMediator.processCommand(self, _command)
end

function FHZPRebateMediator.ACK_ART_ZHUANPAN_GOOD(self, _ackMsg)
    print( "-============- ACK_ART_ZHUANPAN_GOOD")
    for k,v in pairs(_ackMsg) do
    	print(k,v)
    end
    self.view : updateData(_ackMsg)
end

return FHZPRebateMediator