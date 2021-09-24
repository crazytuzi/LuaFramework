local ArtifactMediator = classGc(mediator, function(self, _view)
	self.name = "ArtifactMediator"
    self.view = _view

    self:regSelf()
end)

ArtifactMediator.protocolsList={
    _G.Msg["ACK_MAGIC_EQUIP_REPLY_ONE"],	     --单个神兵请求返回
    _G.Msg["ACK_MAGIC_EQUIP_USE_REPLY"],         --使用神兵返回
    _G.Msg["ACK_GOODS_REMOVE"],                  --激活神兵返回
    _G.Msg["ACK_MAGIC_EQUIP_OFF_OK"],            --使用神兵返回
    _G.Msg["ACK_MAKE_COMPOSE_OK"],               --合成神兵返回
}

ArtifactMediator.commandsList={
	CProxyUpdataCommand.TYPE,
	CCharacterEquipInfoUpdataCommand.TYPE,
	CPropertyCommand.TYPE,
}

function ArtifactMediator.processCommand(self, _command)
    local szType=_command:getType()
    local data=_command:getData()
    if szType==CProxyUpdataCommand.TYPE then
        print("1")
        -- self.view:updateEquip()
        -- self.view:EquipScrollView()
    elseif szType==CCharacterEquipInfoUpdataCommand.TYPE then
        print("2")
        -- self.view:updateEquip()
        -- self.view:EquipScrollView()
    elseif szType==CPropertyCommand.TYPE then
    	print("3")
        if _command:getData()==CPropertyCommand.POWERFUL then
            -- self.view:playerpower()
        end
    end

    return false
end

function ArtifactMediator.ACK_MAGIC_EQUIP_REPLY_ONE(self, _ackMsg)
    print("id",_ackMsg.id,"idx",_ackMsg.idx,"skill_lv",_ackMsg.skill_lv)
    self.view : updateAttrData(_ackMsg)
end

function ArtifactMediator.ACK_MAGIC_EQUIP_USE_REPLY(self, _ackMsg)
    print("ACK_MAGIC_EQUIP_USE_REPLY")
    self.view : updateBtnStr(1)
end

function ArtifactMediator.ACK_GOODS_REMOVE(self)
    print( "-- ACK_GOODS_REMOVE")
    self.view:updateBtnStr()
end

function ArtifactMediator.ACK_MAGIC_EQUIP_OFF_OK(self)
    print( "-- ACK_MAGIC_EQUIP_OFF_OK")
    self.view:updateBtnStr()
end

function ArtifactMediator.ACK_MAKE_COMPOSE_OK( self )
    print( "合成神兵返回")
    self.view:updateBtnStr(2)
end

return ArtifactMediator