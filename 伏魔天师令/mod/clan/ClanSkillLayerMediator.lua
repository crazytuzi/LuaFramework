local ClanSkillLayerMediator = classGc(mediator, function(self, _view)
    self.name = "ClanSkillLayerMediator"
    self.view = _view

    self:regSelf()
end)

ClanSkillLayerMediator.protocolsList={
    _G.Msg["ACK_CLAN_OK_CLAN_SKILL"],-- (33210手动) -- [33210]返回社团技能面板数据 -- 门派
}

function ClanSkillLayerMediator.processCommand(self, _command)
    return false
end

function ClanSkillLayerMediator.ACK_CLAN_OK_CLAN_SKILL(self, _ackMsg) 
    local m_stamina  = _ackMsg.stamina
    local m_count    = _ackMsg.count 
    local m_attr_msg = _ackMsg.attr_msg 

    self:getView() : NetWorkReturn_skillDataFromSever(m_stamina,m_count,m_attr_msg)
end

return ClanSkillLayerMediator