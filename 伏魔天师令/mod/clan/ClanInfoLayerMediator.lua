local ClanInfoLayerMediator = classGc(mediator, function(self, _view)
    self.name = "ClanInfoLayerMediator"
    self.view = _view

    self:regSelf()
end)

ClanInfoLayerMediator.protocolsList={
    _G.Msg["ACK_CLAN_OK_CLAN_DATA"], -- [33020]返加门派基础数据1 -- 门派 
    _G.Msg["ACK_CLAN_OK_OTHER_DATA"],-- [33023]返加门派基础数据2 -- 门派
    _G.Msg["ACK_CLAN_CLAN_LOGS"],    -- (33025手动) -- [33025]返加社团日志数据3 -- 门派 
    _G.Msg["ACK_CLAN_OK_RESET_CAST"],-- [33120]返回修改公告结果 -- 门派 
    -- _G.Msg["ACK_CLAN_CORNER"],       --  33410
}
ClanInfoLayerMediator.commandsList=nil
-- function ClanInfoLayerMediator.processCommand(self, _command)
--     return false
-- end

function ClanInfoLayerMediator.ACK_CLAN_OK_CLAN_DATA(self, _ackmsg)
    -- local m_data = {}
    -- m_data.clan_id          = _ackmsg.clan_id          -- {门派ID}
    -- m_data.clan_name        = _ackmsg.clan_name        -- {门派名字}
    -- m_data.clan_lv          = _ackmsg.clan_lv          -- {门派等级}
    -- m_data.clan_rank        = _ackmsg.clan_rank        -- {门派排名}
    -- m_data.clan_members     = _ackmsg.clan_members     -- {门派当前成员数}
    -- m_data.clan_all_members = _ackmsg.clan_all_members  -- {门派成员上限数}
    self.view:NetWorkReturn_ClanInfoData(_ackmsg)
end

function ClanInfoLayerMediator.ACK_CLAN_OK_OTHER_DATA(self, _ackmsg)
    -- local m_data = {}
    -- m_data.master_uid          = _ackmsg.master_uid -- {掌门uid}
    -- m_data.master_name         = _ackmsg.master_name -- {掌门名字}
    -- m_data.master_name_color   = _ackmsg.master_name_color -- {掌门名字颜色}
    -- m_data.master_lv           = _ackmsg.master_lv -- {掌门等级}

    -- m_data.sum_power           = _ackmsg.sum_power -- {门派总战斗力}

    -- m_data.clan_all_contribute = _ackmsg.clan_all_contribute -- {门派总贡献值}
    -- m_data.clan_contribute     = _ackmsg.clan_contribute -- {升级所需贡献}
    -- m_data.clan_broadcast      = _ackmsg.clan_broadcast -- {门派公告} 

    -- for k,v in pairs(_ackmsg) do
    --     print(k,v)
    -- end
    self.view:NetWorkReturn_ClanInfoData2( _ackmsg )
end

function ClanInfoLayerMediator.ACK_CLAN_CLAN_LOGS(self, _ackmsg)
    print( "-- [33025]返加社团日志数据3 -- 社团",_ackmsg.count)
    local logscount = _ackmsg.count
    local logsmsg   = _ackmsg.logs_data

    self.view:NetWorkReturn_ClanLogs( logscount,logsmsg )
end

function ClanInfoLayerMediator.ACK_CLAN_OK_RESET_CAST( self )
    print("就是这里啦啦啦啦啦啦啦啦啦啦")
   self.view:NetWorkReturn_updateClanInfo()
end

return ClanInfoLayerMediator