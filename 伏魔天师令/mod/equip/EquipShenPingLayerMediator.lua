local EquipShenPingLayerMediator = classGc(mediator, function(self, _view)
    self.name = "EquipShenPingLayerMediator"
    self.view = _view

    self:regSelf()
end)

EquipShenPingLayerMediator.protocolsList={
    -- _G.Msg["ACK_MAKE_STRENGTHEN_OK"], --接收强化成功信息 2520
    -- _G.Msg["ACK_MAKE_STREN_MAX"], --不可强化或已达最高级 2519
    _G.Msg.ACK_MAKE_EQUIP_NEW_REPLY,-- [2710]打造装备返回(新的) -- 物品/打造/强化
    _G.Msg.ACK_MAKE_EQUIP_NEXT_REPLY,
}

EquipShenPingLayerMediator.commandsList={
    EquipmentsViewCommand.TYPE,
    -- CPropertyCommand.TYPE,
    CRoleViewCommand.TYPE,
    CProxyUpdataCommand.TYPE,
    CGuideNoticDel.TYPE
}

function EquipShenPingLayerMediator.getView(self)
    return self.view
end

function EquipShenPingLayerMediator.processCommand(self, _command)
    if _command:getType() == EquipmentsViewCommand.TYPE then
        local data = _command : getData()
        if data ~= nil and data.nowPageId == 2 then --TAGBTN_SHENPING
            print("总界面发给升品界面--->",data.nowPageId,data.nowGoodsIndex,data.nowGoodsPart)
            self : getView():pushData( data )
        end
    -- elseif  _command:getType() == CPropertyCommand.TYPE then
    --     if _command :getData() == CPropertyCommand.MONEY then
    --         print("命令 玄铁更新")
    --         self :getView() :updateMoney()
    --     end 
    elseif _command:getType()==CRoleViewCommand.TYPE then
        if _command.isZLF then
            local uid=_command.uid
            self.view:chuangeRole(uid)
        end
    elseif _command:getType()==CProxyUpdataCommand.TYPE then
        self.view:bagGoodsUpdate()
    elseif _command:getType()==CGuideNoticDel.TYPE then
        self.view:guideDelete(_command.guideId)
    end
    return false
end

function EquipShenPingLayerMediator.ACK_MAKE_EQUIP_NEW_REPLY(self, ackMessage)  -- [2710]打造装备返回(新的) -- 物品/打造/强化 

    local flag      = ackMessage.flag -- {是否打造成功}
    local goodstype = ackMessage.type -- {1背包2装备栏}
    local id        = ackMessage.id   -- {主将0|武将ID}
    local idx       = ackMessage.idx  -- {物品的idx}

    self:getView() : NetWorkReturn_MAKE_EQUIP_NEW_REPLY(id,idx)
    self:getView() : ShengPinSuccEffect(flag)
end

function EquipShenPingLayerMediator.ACK_MAKE_EQUIP_NEXT_REPLY(self,_ackMsg)
    -- for k,v in pairs(_ackMsg.attr_xxx) do
    --     print("ACK_MAKE_EQUIP_NEXT_REPLY",k,v)
    -- end
    self.view:NetWorkReturn_MAKE_EQUIP_NEXT_REPLY(_ackMsg)
end

return EquipShenPingLayerMediator