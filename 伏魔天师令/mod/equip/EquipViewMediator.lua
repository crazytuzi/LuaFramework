local EquipViewMediator = classGc(mediator, function(self, _view)
    self.name = "EquipViewMediator"
    self.view = _view

    self:regSelf()
end)

EquipViewMediator.protocolsList=nil

EquipViewMediator.commandsList={
    EquipGoodChangeCommand.TYPE,
    CCharacterEquipInfoUpdataCommand.TYPE,
    CPropertyCommand.TYPE,
    CRoleViewCommand.TYPE,
    CProxyUpdataCommand.TYPE,
}

function EquipViewMediator.setBagView(self,_bagView)
    self.m_bagView=_bagView
end

function EquipViewMediator.processCommand(self, _command)
    local szType=_command:getType()
    local data=_command:getData()
    if szType==EquipGoodChangeCommand.TYPE then
        if data == EquipGoodChangeCommand.EQUIP then --TAGBTN_SHENPING
            print("子页面发给主页面替换装备--->")
            self.view:updateEquip()
        elseif data == EquipGoodChangeCommand.DELEFFECT then
             self.view:delscelecteffectFromCommand()
        end
    elseif szType==CCharacterEquipInfoUpdataCommand.TYPE then
            self.view:updateEquip()
            local command = CProxyUpdataCommand()
            controller :sendCommand( command)            
        if data==_G.Msg["ACK_MAKE_PART_ALL_REP"] then
            self.view:updateArrAndGemSpr()
        end
    elseif szType==CPropertyCommand.TYPE then
        if _command:getData()==CPropertyCommand.POWERFUL then
            self.view:playerpower()
        end
    elseif szType==CProxyUpdataCommand.TYPE then
        if self.m_bagView then
            self.m_bagView:EquipScrollView()
        end
    elseif szType==CRoleViewCommand.TYPE then  --人物面板发给 属性页面
        if _command.isZLF then return end
        local uid=_command.uid
        if self.m_bagView then
            self.m_bagView:chuangeRole(uid)
        end
    end

    return false
end

function EquipViewMediator.getView(self)
    return self.view
end

return EquipViewMediator