local ArtifactViewMediator = classGc(mediator, function(self, _view)
    self.name = "ArtifactViewMediator"
    self.view = _view

    self:regSelf()
end)

ArtifactViewMediator.protocolsList={
    -- _G.Msg["ACK_SYSTEM_ERROR"],
    _G.Msg["ACK_MAGIC_EQUIP_REPLY"],
    _G.Msg["ACK_MAGIC_EQUIP_ENHANCED_REPLY"],
    _G.Msg["ACK_MAGIC_EQUIP_ADVANCE_REPLY"],
    _G.Msg["ACK_GOODS_REMOVE"],                  --激活神兵返回
}

ArtifactViewMediator.commandsList=
{
	CArtifactCommand.TYPE,
}
function ArtifactViewMediator.processCommand(self, _command)
	local comType=_command:getType()
	-- if comType == CArtifactCommand.TYPE then
	-- 	print("切换了灵妖/主角")
	-- 	print("uid",_command.uid)
	-- 	self.view : updateCurUid(_command.uid)
	-- end
end

-- function ArtifactViewMediator.ACK_SYSTEM_ERROR(self, _ackMsg)
--     print( "-- ACK_SYSTEM_ERROR")
--     if _ackMsg.error_code == 30640 then
--     	self.view:goodsReturn()
--     end
-- end

function ArtifactViewMediator.ACK_MAGIC_EQUIP_REPLY(self, _ackMsg)
    print( "-- ACK_MAGIC_EQUIP_REPLY",_ackMsg.count)
    self.view:updateAttrView(_ackMsg)
end

function ArtifactViewMediator.ACK_MAGIC_EQUIP_ENHANCED_REPLY(self, _ackMsg)
    print( "-- ACK_MAGIC_EQUIP_ENHANCED_REPLY")
    if _ackMsg.result==1 then
        self.view : updatePower()
    end
end

function ArtifactViewMediator.ACK_MAGIC_EQUIP_ADVANCE_REPLY(self)
    print( "-- ACK_MAGIC_EQUIP_ADVANCE_REPLY")
    self.view : updatePower()
end

function ArtifactViewMediator.ACK_GOODS_REMOVE(self, _ackMsg)
    print( "-- ACK_GOODS_REMOVE")
    self.view : updateBtnBack()
end

return ArtifactViewMediator