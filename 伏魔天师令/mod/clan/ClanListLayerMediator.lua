local ClanListLayerMediator = classGc(mediator, function(self, _view)
    self.name = "ClanListLayerMediator"
    self.view = _view

    self:regSelf()
end)

ClanListLayerMediator.protocolsList={
    _G.Msg["ACK_CLAN_OK_REBUILD_CLAN"],-- [33060]创建成功 -- 门派
    _G.Msg["ACK_CLAN_OK_CLANLIST"],
    _G.Msg["ACK_CLAN_APPLIED_CLANLIST"], --申请的门派
    _G.Msg["ACK_CLAN_OK_OTHER_DATA"],-- 查看用得
    _G.Msg["ACK_CLAN_OK_OUT_CLAN"],-- [33160]退出门派成功 -- 门派
    _G.Msg["ACK_CLAN_OK_JOIN_CLAN"],-- [33040]申请成功 -- 门派 
    _G.Msg["ACK_CLAN_AUDIT_SUCCESS"],-- [33098]申请门派审核成功 -- 门派  
}

function ClanListLayerMediator.ACK_CLAN_OK_REBUILD_CLAN(self)  -- [33060]创建成功 -- 门派
    self : getView() : Net_REBUILD_CLAN()
end

function ClanListLayerMediator.ACK_CLAN_OK_CLANLIST(self, _ackMsg)
    self : getView() : Net_CLAN_OK_CLANLIST( _ackMsg )
end

function ClanListLayerMediator.ACK_CLAN_APPLIED_CLANLIST( self, _ackMsg ) 
    self : getView() : Net_APPLIED_CLANLIST( _ackMsg)
end

function ClanListLayerMediator.ACK_CLAN_OK_OTHER_DATA(self, _ackMsg)
    print("ClanListLayerMediator.ACK_CLAN_OK_OTHER_DATA",_ackMsg.master_uid)
    self : getView() : Net_OTHER_DATA( _ackMsg )
end

function ClanListLayerMediator.ACK_CLAN_OK_OUT_CLAN(self)
    self : getView() : Net_OUT_CLAN()
end

function ClanListLayerMediator.ACK_CLAN_OK_JOIN_CLAN( self, _ackMsg )
    self : getView() : Net_JOIN_CLAN(_ackMsg)
end

function ClanListLayerMediator.ACK_CLAN_AUDIT_SUCCESS( self )
    self : getView() : Net_AUDIT_SUCCESS()
end

return ClanListLayerMediator