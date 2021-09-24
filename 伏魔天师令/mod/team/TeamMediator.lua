local TeamMediator = classGc(mediator, function(self, _view)
    self.name = "TeamMediator"
    self.view = _view
    self:regSelf()
end)

TeamMediator.protocolsList={
    _G.Msg["ACK_TEAM_REPLY"],          -- 组队副本信息返回
    _G.Msg["ACK_TEAM_TEAM_INFO_NEW"],  -- 队伍信息返回
    _G.Msg["ACK_TEAM_LEAVE_NOTICE"],   -- 离队原因返回
    _G.Msg["ACK_TEAM_BUY_SUCCESS"],    -- 购买次数成功返回
    _G.Msg["ACK_TEAM_LIST_REPLY"],     -- 邀请列表返回
    _G.Msg["ACK_TEAM_INVITE_SUCCESS"], -- 邀请成功返回
    -- _G.Msg["ACK_TEAM_LIVE_REP"],       -- 查询队伍返回
}

TeamMediator.commandsList={
    CTeamCommand.TYPE,
}

function TeamMediator.processCommand(self, _command)
    if _command:getType() == CTeamCommand.TYPE then
        self : getView() : popRoot()
    end
end

function TeamMediator.ACK_TEAM_REPLY(self, _ackMsg)
    print("ACK_TEAM_REPLY ---> 组队副本信息",_ackMsg.copy_id,_ackMsg.times,_ackMsg.count)
    self:getView():pushdata(_ackMsg)
end

function TeamMediator.ACK_TEAM_TEAM_INFO_NEW(self, _ackMsg)
    print("ACK_TEAM_TEAM_INFO_NEW",_ackMsg.team_id,_ackMsg.copy_id,_ackMsg.leader_uid,_ackMsg.count,_ackMsg.data)
    self:getView():setTeamData(_ackMsg)
end

function TeamMediator.ACK_TEAM_LEAVE_NOTICE(self, _ackMsg)
    print("ACK_TEAM_LEAVE_NOTICE ---> ")
    self:getView():setNotice(_ackMsg)
end

function TeamMediator.ACK_TEAM_BUY_SUCCESS(self, _ackMsg)
    print("ACK_TEAM_BUY_SUCCESS ----> 购买成功",_ackMsg.times,_ackMsg.buy_count)
    self:getView():setBuySuccess(_ackMsg)
end

function TeamMediator.ACK_TEAM_LIST_REPLY(self, _ackMsg)
    print("ACK_TEAM_LIST_REPLY ",_ackMsg.type,_ackMsg.count)
    self:getView():setList(_ackMsg)
end

function TeamMediator.ACK_TEAM_INVITE_SUCCESS(self, _ackMsg)
    print("ACK_TEAM_INVITE_SUCCESS ")
    self:getView():setInvite(_ackMsg)
end

-- function TeamMediator.ACK_TEAM_LIVE_REP(self, _ackMsg)
--     print("ACK_TEAM_LIVE_REP ")
--     if not self.isInviteView then return end
--     self:getView():AcceptInvite(_ackMsg)
-- end

return TeamMediator