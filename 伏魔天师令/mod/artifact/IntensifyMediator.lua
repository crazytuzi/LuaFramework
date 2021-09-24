local IntensifyMediator = classGc(mediator, function(self, _view)
	self.name = "IntensifyMediator"
    self.view = _view

    self:regSelf()
end)

IntensifyMediator.protocolsList={
    _G.Msg["ACK_MAGIC_EQUIP_STRENG_BACK"],	     --面板回复
    _G.Msg["ACK_MAGIC_EQUIP_ENHANCED_REPLY"],
}

IntensifyMediator.commandsList=
{
	CArtifactCommand.TYPE,
}
function IntensifyMediator.processCommand(self, _command)
	local comType=_command:getType()
	-- if comType == CArtifactCommand.TYPE then
	-- 	print("切换了灵妖/主角")
	-- 	print("uid",_command.uid)
	-- 	self.view : updateView(_command.uid)
	-- end
end

function IntensifyMediator.ACK_MAGIC_EQUIP_STRENG_BACK(self, _ackMsg)
    print( "-- ACK_MAGIC_EQUIP_STRENG_BACK")
    self.view : updateMsg(_ackMsg)
end

function IntensifyMediator.ACK_MAGIC_EQUIP_ENHANCED_REPLY(self, _ackMsg)
    print( "-- ACK_MAGIC_EQUIP_ENHANCED_REPLY")
    self.view : updatePower(_ackMsg.result)
end

return IntensifyMediator