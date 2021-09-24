local EquipFenJieLayerMediator = classGc(mediator, function(self, _view)
    self.name = "EquipFenJieLayerMediator"
    self.view = _view

    self:regSelf()
end)

EquipFenJieLayerMediator.protocolsList={
    _G.Msg["ACK_MAKE_DECOMPOSE_REPLY"],-- [2600]分解成功 -- 物品/打造/强化 
}

EquipFenJieLayerMediator.commandsList={
    CPropertyCommand.TYPE,
}

function EquipFenJieLayerMediator.getView(self)
    return self.view
end

function EquipFenJieLayerMediator.ACK_MAKE_DECOMPOSE_REPLY(self)
    self :getView() : updateDetele()
end

return EquipFenJieLayerMediator