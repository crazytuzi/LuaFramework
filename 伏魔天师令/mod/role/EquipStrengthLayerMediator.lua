local EquipStrengthLayerMediator = classGc(mediator, function(self, _view)
    self.name = "EquipStrengthLayerMediator"
    self.view = _view

    self:regSelf()
end)

EquipStrengthLayerMediator.protocolsList={
    -- _G.Msg["ACK_MAKE_STRENGTHEN_OK"], --接收强化成功信息 2520
    -- _G.Msg["ACK_MAKE_STREN_MAX"], --不可强化或已达最高级 2519
    _G.Msg["ACK_MAKE_PART_STREN_REPLY"], -- (2726手动) -- [2726]强化返回 -- 物品/打造/强化 
    _G.Msg["ACK_MAKE_STREN_SUCCESS"], 
}

EquipStrengthLayerMediator.commandsList={
    EquipmentsViewCommand.TYPE,
    CRoleViewCommand.TYPE,
    CPropertyCommand.TYPE,
}

function EquipStrengthLayerMediator.getView(self)
    return self.view
end

function EquipStrengthLayerMediator.processCommand(self, _command)
	local commandType = _command :getType()
    local commamdData = _command :getData()
    
    if _command:getType() == EquipmentsViewCommand.TYPE then
        local data = _command : getData()
        print("总界面发给元魂界面--->",data.nowGoodsPart)
        self : getView():pushData( data.nowGoodsPart )
    elseif _command:getType()==CRoleViewCommand.TYPE then
        if _command.isZLF then
            local uid=_command.uid
            self.view:chuangeRole(uid)
        end
    elseif commandType == CPropertyCommand.TYPE then
        if  commamdData == CPropertyCommand.MONEY then
            self.view:updateMoney()
        elseif _command:getData()==CPropertyCommand.POWERFUL then
            self.view:playerpower()
        end
    end
    return false
end

function EquipStrengthLayerMediator.ACK_MAKE_PART_STREN_REPLY(self, _ackMsg)
    local m_lv     = _ackMsg.lv
    local money    = _ackMsg.money
    local odds     = _ackMsg.odds
    local odds_vip = _ackMsg.odds_vip

    local count    = _ackMsg.count
    local msg_xxx  = _ackMsg.msg_xxx
    local count2   = _ackMsg.count2
    local msg_xxx2 = _ackMsg.msg_xxx2

    self :getView() :StrengthDataReturn(m_lv,money,odds,odds_vip,msg_xxx,msg_xxx2)
end
function EquipStrengthLayerMediator.ACK_MAKE_STREN_SUCCESS( self, _ackMsg )
    print("ACK_MAKE_STREN_SUCCESS==>>",_ackMsg.flag)
        self :getView() : showStrengthOkEffect(_ackMsg.flag)
end
return EquipStrengthLayerMediator