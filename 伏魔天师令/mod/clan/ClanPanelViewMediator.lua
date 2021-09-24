local ClanPanelViewMediator = classGc(mediator, function(self, _view)
    self.name = "ClanPanelViewMediator"
    self.view = _view

    self:regSelf()
end)

ClanPanelViewMediator.protocolsList={
    _G.Msg["ACK_CLAN_OK_REBUILD_CLAN"],-- [33060]创建成功 -- 门派
    _G.Msg["ACK_CLAN_OK_OUT_CLAN"],-- [33160]退出门派成功 -- 门派
    _G.Msg["ACK_CLAN_AUDIT_SUCCESS"],-- [33098]申请门派审核成功 -- 门派  
    -- _G.Msg["ACK_CLAN_BOSS_STATE"],
    _G.Msg["ACK_CLAN_CORNER"],
}

ClanPanelViewMediator.commandsList={
    CFunctionOpenCommand.TYPE
}

function ClanPanelViewMediator.processCommand(self, _command)
    -- if _command:getType()==CFunctionOpenCommand.TYPE then
    --     if _command:getData()==CFunctionOpenCommand.TIMES_UPDATE then
    --         self.view:chuangIconNum(_command.sysId,_command.number)
    --     end
    -- end
    return false
end

function ClanPanelViewMediator.ACK_CLAN_OK_REBUILD_CLAN(self)  -- [33060]创建成功 -- 门派
    self:getView() : NetWorkReturn_changePageFromMediator()
end

function ClanPanelViewMediator.ACK_CLAN_OK_OUT_CLAN(self)
    self : getView() : NetWorkReturn_OutClan()
end

function ClanPanelViewMediator.ACK_CLAN_AUDIT_SUCCESS(self) 
    self:getView() : NetWorkReturn_changePageFromMediator()
end

function ClanPanelViewMediator.ACK_CLAN_CORNER( self, _ackmsg )
    self:getView() :Net_CLAN_CORNER( _ackmsg )
end

return ClanPanelViewMediator