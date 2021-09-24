local ClanActivityLayerMediator = classGc(mediator, function(self, _view)
    self.name = "ClanActivityLayerMediator"
    self.view = _view

    self:regSelf()
end)

ClanActivityLayerMediator.protocolsList={
    _G.Msg["ACK_CLAN_OK_WATER_DATA"],-- (33330手动) -- [33330]返回浇水面板数据 -- 门派 
    _G.Msg["ACK_CLAN_BOSS_STATE"],
    _G.Msg["ACK_HILL_REPLAY"],
    _G.Msg["ACK_HILL_CLAN_TOP"],
    _G.Msg["ACK_HILL_REDIO_BACK"],
    _G.Msg["ACK_HILL_CLEAN_OK"],
    _G.Msg["ACK_CLAN_POST_BACK"],
    _G.Msg["ACK_HILL_CD_SEC"],
    _G.Msg["ACK_GANG_WARFARE_BACK"],
    _G.Msg["ACK_GANG_WARFARE_GROUP"],
    _G.Msg["ACK_GANG_WARFARE_ONCE"],        -- 40530
    _G.Msg["ACK_GANG_WARFARE_C_FINISH"],    -- 40550
    _G.Msg["ACK_DEFENSE_BWJM_BACK"],        -- 63809
    _G.Msg["ACK_DEFENSE_COMBAT_RANK"],      -- 64010
    _G.Msg["ACK_DEFENSE_ZHANBAO"],          -- 63940
    _G.Msg["ACK_DEFENSE_SELF_KILL"],        -- 63890  
    _G.Msg["ACK_CLIFFORD_REPLY"],           -- 29020     
    _G.Msg["ACK_CLIFFORD_OVER"],            -- 29050  
    _G.Msg["ACK_CLIFFORD_LQ_BACK"],         -- 29070  
    
}

function ClanActivityLayerMediator.ACK_CLAN_OK_WATER_DATA(self, _ackMsg) 
    local m_state  = _ackMsg.state
    print("ClanActivityLayerMediator.ACK_CLAN_OK_WATER_DATA",m_state)
    self:getView() : NetWorkReturn_isHuDongBtnOk(m_state)
end

function ClanActivityLayerMediator.ACK_CLAN_BOSS_STATE( self, _ackMsg )
    print( "ClanActivityLayerMediator.ACK_CLAN_BOSS_STATE",_ackMsg )
    self : getView() : Boss_State(_ackMsg)
end

function ClanActivityLayerMediator.ACK_HILL_REPLAY( self, _ackMsg )
    self : getView() : Net_HILL_REPLAY( _ackMsg )
end

function ClanActivityLayerMediator.ACK_HILL_CLAN_TOP( self, _ackMsg )
    local msg = _ackMsg
    self : getView() : Net_CLAN_TOP( _ackMsg )
end

function ClanActivityLayerMediator.ACK_HILL_REDIO_BACK( self, _ackMsg )
    self : getView() : Net_REDIO_BACK( _ackMsg )
end

function ClanActivityLayerMediator.ACK_HILL_CLEAN_OK( self )
    self : getView() : Net_CLEAN_OK( _ackMsg )
end

function ClanActivityLayerMediator.ACK_HILL_CD_SEC( self, _ackMsg )
    self : getView() : Net_CD_SEC( _ackMsg.rmb )
end

function ClanActivityLayerMediator.ACK_CLAN_POST_BACK( self, _ackMsg )
    print( "  收到协议  " )
    self : getView() : Net_POST_BACK( _ackMsg )
end

function ClanActivityLayerMediator.ACK_GANG_WARFARE_GROUP( self, _ackMsg )
    self : getView() : Net_WARFARE_GROUP( _ackMsg )
end

function ClanActivityLayerMediator.ACK_GANG_WARFARE_BACK( self, _ackMsg )
    self : getView() : Net_WARFARE_BACK( _ackMsg.enter )
end

function ClanActivityLayerMediator.ACK_GANG_WARFARE_ONCE( self, _ackMsg )
    self : getView() : Net_WARFARE_ONCE( _ackMsg )
end

function ClanActivityLayerMediator.ACK_GANG_WARFARE_C_FINISH( self, _ackMsg )
    self : getView() : Net_WARFARE_C_FINISH( _ackMsg )
end

function ClanActivityLayerMediator.ACK_DEFENSE_BWJM_BACK( self, _ackMsg )
    self : getView() : Net_BWJM_BACK(_ackMsg)
end

function ClanActivityLayerMediator.ACK_DEFENSE_COMBAT_RANK( self, _ackMsg )
    self : getView() : Net_COMBAT_RANK( _ackMsg )
end

function ClanActivityLayerMediator.ACK_DEFENSE_ZHANBAO( self, _ackMsg )
    self : getView() : Net_DEFENSE_ZHANBAO( _ackMsg.data )
end

function ClanActivityLayerMediator.ACK_DEFENSE_SELF_KILL( self, _ackMsg )
    self : getView() : Net_SELF_KILL( _ackMsg.kill_num )
end

function ClanActivityLayerMediator.ACK_CLIFFORD_REPLY( self, _ackMsg )
    self : getView() : Net_CLIFFORD_REPLY( _ackMsg )
end

function ClanActivityLayerMediator.ACK_CLIFFORD_OVER( self, _ackMsg )
    self : getView() : Net_CLIFFORD_OVER()
end

function ClanActivityLayerMediator.ACK_CLIFFORD_LQ_BACK( self, _ackMsg )
    self : getView() : Net_LQ_BACK( _ackMsg )
end

return ClanActivityLayerMediator