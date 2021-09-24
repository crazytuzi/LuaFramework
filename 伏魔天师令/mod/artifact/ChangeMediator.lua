local ChangeMediator = classGc(mediator, function(self, _view)
	self.name = "ChangeMediator"
    self.view = _view

    self:regSelf()
end)

ChangeMediator.protocolsList={
    _G.Msg["ACK_MAGIC_EQUIP_WASH_BACK"],	     --面板回复
    _G.Msg["ACK_MAGIC_EQUIP_WASH_REPLY"],
}

ChangeMediator.commandsList=
{
	CArtifactCommand.TYPE,
}
function ChangeMediator.processCommand(self, _command)
	local comType=_command:getType()
	-- if comType == CArtifactCommand.TYPE then
	-- 	print("切换了灵妖/主角")
	-- 	print("uid",_command.uid)
	-- 	self.view : updateView(_command.uid)
	-- end
end

function ChangeMediator.ACK_MAGIC_EQUIP_WASH_BACK(self, _ackMsg)
    print( "-- ACK_MAGIC_EQUIP_WASH_BACK")
    self.view : updateMsg(_ackMsg)
end

function ChangeMediator.ACK_MAGIC_EQUIP_WASH_REPLY(self, _ackMsg)
    print( "-- ACK_MAGIC_EQUIP_WASH_REPLY")
    self.view : updatePower()
end

return ChangeMediator