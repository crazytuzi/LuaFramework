local EquipGemLayerMediator = classGc(mediator, function(self, _view)
    self.name = "EquipGemLayerMediator"
    self.view = _view

    self:regSelf()
end)

EquipGemLayerMediator.protocolsList={
    -- _G.Msg["ACK_MAKE_PEARL_INSET_OK"], -- [2561]镶嵌宝石成功 -- 物品/打造/强化
    _G.Msg["ACK_MAKE_INSET_RMB"], -- [2565]宝石一键镶嵌元宝数 -- 物品/打造/强化
    _G.Msg["ACK_MAKE_PART_INSERT_FLAG"], -- 2810
    _G.Msg["ACK_MAKE_PART_UP_FLAG"], -- 2815
}

EquipGemLayerMediator.commandsList={
    EquipmentsViewCommand.TYPE,
    EquipGemInsertCommand.TYPE,
    CCharacterEquipInfoUpdataCommand.TYPE,
    CRoleViewCommand.TYPE,
    CGuideNoticDel.TYPE
}

function EquipGemLayerMediator.getView(self)
    return self.view
end

function EquipGemLayerMediator.processCommand(self, _command)
    local szType=_command:getType()
    local data=_command:getData()

    if szType==EquipmentsViewCommand.TYPE then
        if data ~= nil and data.nowPageId == 3 then --TAGBTN_XIANQIAN
            print("总界面发给镶嵌界面--->",data.nowPageId)
            self : getView():pushData( data )
        end
    elseif szType==EquipGemInsertCommand.TYPE then
        if data ~= nil and data == EquipGemInsertCommand.UPGRADE then
            print("tips按钮回调 升级 --->")
            self : getView():REQ_MAKE_PART_INSERT_UP()
        elseif data ~= nil and data == EquipGemInsertCommand.CHAIXIE then
            print("tips按钮回调 拆卸 --->")
            self : getView():REQ_MAKE_PART_GEM_REMOVE()
        elseif data ~= nil and data == EquipGemInsertCommand.INSERT then
            print("tips按钮回调 镶嵌 --->")
            self : getView():REQ_MAKE_PART_INSERT()
        end
    elseif szType==CCharacterEquipInfoUpdataCommand.TYPE then
        if data==_G.Msg["ACK_MAKE_PART_ALL_REP"] then
            self.view:insertOkReturn()
        end
    elseif szType==CRoleViewCommand.TYPE then
        if _command.isZLF then
            local uid=_command.uid
            self.view:chuangeRole(uid,_command.nowPartGem)
        end
    elseif szType==CGuideNoticDel.TYPE then
        self.view:guideDelete(_command.guideId)
    end
    return false
end

function EquipGemLayerMediator.ACK_MAKE_PART_INSERT_FLAG(self, _ackMsg)
    print("镶嵌成功就会刷过来了")
    self : getView():GemSuccEffect(1)
end

function EquipGemLayerMediator.ACK_MAKE_PART_UP_FLAG(self, _ackMsg)
    print("升级成功就会刷过来了")
    self : getView():GemSuccEffect(2)
end

function EquipGemLayerMediator.ACK_MAKE_INSET_RMB(self, _ackMsg)
    print("发了条money过来")
    for k,v in pairs(_ackMsg) do
        print(k,v)
    end
    self.view:gemUpdateMoneyBack(_ackMsg.rmb)
end

return EquipGemLayerMediator