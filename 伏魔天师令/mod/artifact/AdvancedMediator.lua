local AdvancedMediator = classGc(mediator, function(self, _view)
	self.name = "AdvancedMediator"
    self.view = _view

    self:regSelf()
end)

AdvancedMediator.protocolsList={
    _G.Msg["ACK_MAGIC_EQUIP_ADVANCE_BACK"],	     --面板回复
    -- _G.Msg["ACK_SYSTEM_ERROR"],
    _G.Msg["ACK_MAGIC_EQUIP_ADVANCE_REPLY"],
}

AdvancedMediator.commandsList={
    CProxyUpdataCommand.TYPE,
}

function AdvancedMediator.processCommand(self, _command)
    print("processCommand======>>>>")
    if _command:getType()==CProxyUpdataCommand.TYPE then
        self.view:bagGoodsUpdate()
    end
    return false
end

function AdvancedMediator.ACK_MAGIC_EQUIP_ADVANCE_BACK(self, _ackMsg)
    print( "-- ACK_MAGIC_EQUIP_ADVANCE_BACK")
    self.view : updateMsg(_ackMsg)
end

function AdvancedMediator.ACK_MAGIC_EQUIP_ADVANCE_REPLY(self, _ackMsg)
    print( "-- ACK_MAGIC_EQUIP_ADVANCE_REPLY")
    self.view : updatePower()
end

-- function AdvancedMediator.ACK_SYSTEM_ERROR(self, _ackMsg)
--     print( "-- ACK_SYSTEM_ERROR",_ackMsg.error_code)
--     if  _ackMsg.error_code == 30620 then
--     	print("错了错了错了错了")
--     	self.view : __clearMsg()
--     end
-- end

return AdvancedMediator