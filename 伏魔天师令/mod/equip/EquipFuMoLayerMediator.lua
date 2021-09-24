
local EquipFuMoLayerMediator = classGc(mediator, function(self, _view)
    self.name = "EquipFuMoLayerMediator"
    self.view = _view

    self:regSelf()
end)

EquipFuMoLayerMediator.protocolsList={
    -- _G.Msg["ACK_MAKE_STRENGTHEN_OK"], --接收强化成功信息 2520
    -- _G.Msg["ACK_MAKE_STREN_MAX"], --不可强化或已达最高级 2519
    _G.Msg["ACK_MAKE_ENCHANT_OK"],-- [2600]附魔成功 -- 物品/打造/强化 
}

EquipFuMoLayerMediator.commandsList={
    EquipmentsViewCommand.TYPE,
    CRoleViewCommand.TYPE,
    CGuideNoticDel.TYPE
}

function EquipFuMoLayerMediator.getView(self)
    return self.view
end

function EquipFuMoLayerMediator.processCommand(self, _command)
    if _command:getType() == EquipmentsViewCommand.TYPE then
        local data = _command : getData()
        if data ~= nil and data.nowPageId == 4 then --TAGBTN_FUMO
            print("总界面发给附魔界面--->",data.nowPageId,data.nowGoodsIndex,data.nowGoodsPart)
            self : getView():pushData( data )
        end
    elseif _command:getType()==CRoleViewCommand.TYPE then
        if _command.isZLF then
            local uid=_command.uid
            self.view:chuangeRole(uid) 
        end
    elseif _command:getType()==CGuideNoticDel.TYPE then
        self.view:guideDelete(_command.guideId)
    end
    return false
end

function EquipFuMoLayerMediator.ACK_MAKE_ENCHANT_OK(self, ackMessage)  -- [2600]附魔成功 -- 物品/打造/强化 
    local id    = ackMessage.id   -- {主将0|武将ID}
    local idx   = ackMessage.idx  -- {物品的idx}
    self :getView() : FuMoSuccEffect()
    self:getView() : NetWorkReturn__MAKE_ENCHANT_OK(id,idx)
end

return EquipFuMoLayerMediator