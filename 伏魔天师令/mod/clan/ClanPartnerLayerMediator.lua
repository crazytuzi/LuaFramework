local ClanPartnerLayerMediator = classGc(mediator, function(self, _view)
    self.name = "ClanPartnerLayerMediator"
    self.view = _view

    self:regSelf()
end)

ClanPartnerLayerMediator.protocolsList={
    _G.Msg["ACK_CLAN_OK_JOIN_LIST"],  -- (33080手动) -- [33080]返回入帮申请列表 -- 门派
    _G.Msg["ACK_CLAN_OK_MEMBER_LIST"],-- (33140手动) -- [33140]返回门派成员列表 -- 门派 
    _G.Msg["ACK_DEFENSE_DIED_STATE"], -- [63930]状态返回 -- 门派守卫战 
    _G.Msg["ACK_DEFENSE_ALL_GROUP"],
    _G.Msg["ACK_DEFENSE_REPLAY"],
    _G.Msg["ACK_SYSTEM_ERROR"],
}

function ClanPartnerLayerMediator.ACK_CLAN_OK_JOIN_LIST(self, _ackMsg) 
    local m_count     = _ackMsg.count
    local m_user_data = _ackMsg.user_data 

    self:getView() : NetWorkReturn_CLAN_OK_JOIN_LIST(m_count,m_user_data)
end

function ClanPartnerLayerMediator.ACK_CLAN_OK_MEMBER_LIST(self, _ackMsg) 
    local m_count     = _ackMsg.count
    local m_user_data = _ackMsg.member_msg 

    -- for k,v in pairs(m_user_data) do
    --     print("=================")
    --     for kk,vv in pairs(v) do
    --         print(kk,vv)
    --     end
    --     print("=================")
    -- end
    self:getView() : NetWorkReturn_CLAN_OK_MEMBER_LIST(m_count,m_user_data)
end

function ClanPartnerLayerMediator.ACK_DEFENSE_DIED_STATE(self,_ackMsg)
    for k,v in pairs(_ackMsg) do
        print(k,v)
    end
end

function ClanPartnerLayerMediator.ACK_DEFENSE_ALL_GROUP(self,_ackMsg)
    for k,v in pairs(_ackMsg) do
        print(k,v)
    end
    for k,v in pairs(_ackMsg.data) do
        print("=======>>>>>",k)
        for kk,vv in pairs(v) do
            print(kk,vv)
        end
        -- for kk,vv in pairs(v.data) do
        --     for kkk,vvv in pairs(vv) do
        --         print(kkk,vvv)
        --     end
        -- end
    end
    self.view:NetWorkReturn_DEFENSE_ALL_GROUP(_ackMsg)
end

function ClanPartnerLayerMediator.ACK_DEFENSE_REPLAY(self,_ackMsg)
    self.view:hallHandleBack(_ackMsg)
end

function ClanPartnerLayerMediator.ACK_SYSTEM_ERROR( self, _ackMsg )
    self : getView() : Net_SYSTEM_ERROR( _ackMsg )
end

return ClanPartnerLayerMediator