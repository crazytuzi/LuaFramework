local DailyPvpHandler = class("DailyPvpHandler ", require("app.network.message.HandlerBase"))

function DailyPvpHandler:_onCtor( ... )

end

function DailyPvpHandler:initHandler(...)
    uf_eventManager:addEventListener(G_EVENTMSGID.EVENT_SCENE_CHANGED, self._onSceneChanged, self)
    uf_messageDispatcher:bindMsg(NetMsg_ID.ID_S2C_TeamPVPStatus, self._recvTeamPVPStatus, self)
    uf_messageDispatcher:bindMsg(NetMsg_ID.ID_S2C_TeamPVPCreateTeam, self._recvTeamPVPCreateTeam, self)
    uf_messageDispatcher:bindMsg(NetMsg_ID.ID_S2C_TeamPVPJoinTeam, self._recvTeamPVPJoinTeam, self)
    uf_messageDispatcher:bindMsg(NetMsg_ID.ID_S2C_TeamPVPLeave, self._recvTeamPVPLeave, self)
    uf_messageDispatcher:bindMsg(NetMsg_ID.ID_S2C_TeamPVPKickTeamMember, self._recvTeamPVPKickTeamMember, self)
    uf_messageDispatcher:bindMsg(NetMsg_ID.ID_S2C_TeamPVPSetTeamOnlyInvited, self._recvTeamPVPSetTeamOnlyInvited, self)
    uf_messageDispatcher:bindMsg(NetMsg_ID.ID_S2C_TeamPVPInvite, self._recvTeamPVPInvite, self)
    uf_messageDispatcher:bindMsg(NetMsg_ID.ID_S2C_TeamPVPBeInvited, self._recvTeamPVPBeInvited, self)
    uf_messageDispatcher:bindMsg(NetMsg_ID.ID_S2C_TeamPVPInvitedJoinTeam, self._recvTeamPVPInvitedJoinTeam, self)
    uf_messageDispatcher:bindMsg(NetMsg_ID.ID_S2C_TeamPVPInviteCanceled, self._recvTeamPVPInviteCanceled, self)
    uf_messageDispatcher:bindMsg(NetMsg_ID.ID_S2C_TeamPVPInviteNPC, self._recvTeamPVPInviteNPC, self)
    uf_messageDispatcher:bindMsg(NetMsg_ID.ID_S2C_TeamPVPAgreeBattle, self._recvTeamPVPAgreeBattle, self)
    uf_messageDispatcher:bindMsg(NetMsg_ID.ID_S2C_TeamPVPMatchOtherTeam, self._recvTeamPVPMatchOtherTeam, self)
    uf_messageDispatcher:bindMsg(NetMsg_ID.ID_S2C_TeamPVPChangePosition, self._recvTeamPVPChangePosition, self)
    uf_messageDispatcher:bindMsg(NetMsg_ID.ID_S2C_TeamPVPBattleResult, self._recvTeamPVPBattleResult, self)
    uf_messageDispatcher:bindMsg(NetMsg_ID.ID_S2C_TeamPVPStopMatch, self._recvTeamPVPStopMatch, self)
    uf_messageDispatcher:bindMsg(NetMsg_ID.ID_S2C_TeamPVPHistoryBattleReport, self._recvTeamPVPHistoryBattleReport, self)
    uf_messageDispatcher:bindMsg(NetMsg_ID.ID_S2C_TeamPVPHistoryBattleReportEnd, self._recvTeamPVPHistoryBattleReportEnd, self)
    uf_messageDispatcher:bindMsg(NetMsg_ID.ID_S2C_TeamPVPGetRank, self._recvTeamPVPGetRank, self)
    uf_messageDispatcher:bindMsg(NetMsg_ID.ID_S2C_TeamPVPGetUserInfo, self._recvTeamPVPGetUserInfo, self)
    uf_messageDispatcher:bindMsg(NetMsg_ID.ID_S2C_TeamPVPBuyAwardCnt, self._recvTeamPVPBuyAwardCnt, self)
    uf_messageDispatcher:bindMsg(NetMsg_ID.ID_S2C_TeamPVPAcceptInvite, self._recvTeamPVPAcceptInvite, self)
    uf_messageDispatcher:bindMsg(NetMsg_ID.ID_S2C_TeamPVPCrossServerLost, self._recvTeamPVPCrossServerLost, self)
    uf_messageDispatcher:bindMsg(NetMsg_ID.ID_S2C_TeamPVPPopChat, self._recvTeamPVPPopChat, self)
    -- uf_messageDispatcher:bindMsg(NetMsg_ID.ID_S2C_TeamPVPBattleTeamChange, self._recvTeamPVPBattleTeamChange, self)
end

function DailyPvpHandler:_onSceneChanged( sceneName )
    if G_Me.dailyPvpData:inTeam() and sceneName ~= "DailyPvpTeamScene" and sceneName ~= "DailyPvpBattleScene" then
        self:sendTeamPVPLeave()
    end
end

-------------recv messages

function DailyPvpHandler:_recvTeamPVPStatus( msgId, msg, len)
    local decodeBuffer = self:_decodeBuf("cs.S2C_TeamPVPStatus", msg, len)

    if type(decodeBuffer) ~= "table" then 
        return 
    end
    -- dump(decodeBuffer)
    if decodeBuffer.ret == NetMsg_ERROR.RET_OK then
        G_Me.dailyPvpData:updateData(decodeBuffer)
        uf_eventManager:dispatchEvent(G_EVENTMSGID.EVENT_TEAMPVPSTATUS, nil, false,decodeBuffer)
    elseif decodeBuffer.ret == NetMsg_ERROR.RET_TEAM_PVP_CROSS_SERVER_ERROR then
        G_Me.dailyPvpData:resetData()
        uf_eventManager:dispatchEvent(G_EVENTMSGID.EVENT_TEAMPVPSTATUS, nil, false,decodeBuffer)
    end
end


function DailyPvpHandler:_recvTeamPVPCreateTeam( msgId, msg, len)
    local decodeBuffer = self:_decodeBuf("cs.S2C_TeamPVPCreateTeam", msg, len)

    if type(decodeBuffer) ~= "table" then 
        return 
    end
    if decodeBuffer.ret == NetMsg_ERROR.RET_OK then

        uf_eventManager:dispatchEvent(G_EVENTMSGID.EVENT_TEAMPVPCREATETEAM, nil, false,decodeBuffer)
  
    end

end


function DailyPvpHandler:_recvTeamPVPJoinTeam( msgId, msg, len)
    local decodeBuffer = self:_decodeBuf("cs.S2C_TeamPVPJoinTeam", msg, len)

    if type(decodeBuffer) ~= "table" then 
        return 
    end
    if decodeBuffer.ret == NetMsg_ERROR.RET_OK then
        uf_eventManager:dispatchEvent(G_EVENTMSGID.EVENT_TEAMPVPJOINTEAM, nil, false,decodeBuffer)
    end
 
end

function DailyPvpHandler:_recvTeamPVPLeave( msgId, msg, len)
    local decodeBuffer = self:_decodeBuf("cs.S2C_TeamPVPLeave", msg, len)

    if type(decodeBuffer) ~= "table" then 
        return 
    end
    
    if decodeBuffer.ret == NetMsg_ERROR.RET_OK then
        uf_eventManager:dispatchEvent(G_EVENTMSGID.EVENT_TEAMPVPLEAVE, nil, false,decodeBuffer)
    elseif decodeBuffer.ret == NetMsg_ERROR.RET_TEAM_PVP_NOT_IN_TEAM then
        uf_eventManager:dispatchEvent(G_EVENTMSGID.EVENT_TEAMPVPNOTINTEAM, nil, false,decodeBuffer)
    end
end


function DailyPvpHandler:_recvTeamPVPKickTeamMember( msgId, msg, len)
    local decodeBuffer = self:_decodeBuf("cs.S2C_TeamPVPKickTeamMember", msg, len)

    if type(decodeBuffer) ~= "table" then 
        return 
    end
    if decodeBuffer.ret == NetMsg_ERROR.RET_OK then

        uf_eventManager:dispatchEvent(G_EVENTMSGID.EVENT_TEAMPVPKICKTEAMMEMBER, nil, false,decodeBuffer)
    elseif decodeBuffer.ret == NetMsg_ERROR.RET_TEAM_PVP_NOT_IN_TEAM then
      uf_eventManager:dispatchEvent(G_EVENTMSGID.EVENT_TEAMPVPNOTINTEAM, nil, false,decodeBuffer)
    end

end


function DailyPvpHandler:_recvTeamPVPSetTeamOnlyInvited( msgId, msg, len)
    local decodeBuffer = self:_decodeBuf("cs.S2C_TeamPVPSetTeamOnlyInvited", msg, len)

    if type(decodeBuffer) ~= "table" then 
        return 
    end
    if decodeBuffer.ret == NetMsg_ERROR.RET_OK then
        G_Me.dailyPvpData:updateOnlyInvited(self._onlyInvited)

        uf_eventManager:dispatchEvent(G_EVENTMSGID.EVENT_TEAMPVPSETTEAMONLYINVITED, nil, false,decodeBuffer)
    elseif decodeBuffer.ret == NetMsg_ERROR.RET_TEAM_PVP_NOT_IN_TEAM then
        uf_eventManager:dispatchEvent(G_EVENTMSGID.EVENT_TEAMPVPNOTINTEAM, nil, false,decodeBuffer)
    end
 
end

function DailyPvpHandler:_recvTeamPVPInvite( msgId, msg, len)
    local decodeBuffer = self:_decodeBuf("cs.S2C_TeamPVPInvite", msg, len)

    if type(decodeBuffer) ~= "table" then 
        return 
    end
    if decodeBuffer.ret == NetMsg_ERROR.RET_OK then
        G_Me.dailyPvpData:inviteFriend(self._inviteFriendId)
        uf_eventManager:dispatchEvent(G_EVENTMSGID.EVENT_TEAMPVPINVITE, nil, false,decodeBuffer)
    elseif decodeBuffer.ret == NetMsg_ERROR.RET_TEAM_PVP_NOT_IN_TEAM then
        uf_eventManager:dispatchEvent(G_EVENTMSGID.EVENT_TEAMPVPNOTINTEAM, nil, false,decodeBuffer)
    end
end


function DailyPvpHandler:_recvTeamPVPBeInvited( msgId, msg, len)
    local decodeBuffer = self:_decodeBuf("cs.S2C_TeamPVPBeInvited", msg, len)

    if type(decodeBuffer) ~= "table" then 
        return 
    end

    G_Me.dailyPvpData:insertInvitedData(decodeBuffer)

    uf_eventManager:dispatchEvent(G_EVENTMSGID.EVENT_TEAMPVPBEINVITED, nil, false,decodeBuffer)


end


function DailyPvpHandler:_recvTeamPVPInvitedJoinTeam( msgId, msg, len)
    local decodeBuffer = self:_decodeBuf("cs.S2C_TeamPVPInvitedJoinTeam", msg, len)

    if type(decodeBuffer) ~= "table" then 
        return 
    end
    if decodeBuffer.ret == NetMsg_ERROR.RET_OK then
        G_Me.dailyPvpData:deleteInvitedData(self._invitorTeamId)
        uf_eventManager:dispatchEvent(G_EVENTMSGID.EVENT_TEAMPVPINVITEDJOINTEAM, nil, false,decodeBuffer)
    elseif decodeBuffer.ret == NetMsg_ERROR.RET_TEAM_PVP_INVITOR_QUIT_TEAM or decodeBuffer.ret == NetMsg_ERROR.RET_TEAM_PVP_INVITE_TICKET_INVALID then
        G_Me.dailyPvpData:deleteInvitedData(self._invitorTeamId)
        uf_eventManager:dispatchEvent(G_EVENTMSGID.EVENT_TEAMPVPINVITEDJOINTEAM, nil, false,decodeBuffer)
    end
 
end


function DailyPvpHandler:_recvTeamPVPInviteCanceled( msgId, msg, len)
    local decodeBuffer = self:_decodeBuf("cs.S2C_TeamPVPInviteCanceled", msg, len)

    if type(decodeBuffer) ~= "table" then 
        return 
    end
    G_Me.dailyPvpData:deleteInvitedData(decodeBuffer.team_id)

    uf_eventManager:dispatchEvent(G_EVENTMSGID.EVENT_TEAMPVPINVITECANCELED, nil, false,decodeBuffer)
 
end

function DailyPvpHandler:_recvTeamPVPInviteNPC( msgId, msg, len)
    local decodeBuffer = self:_decodeBuf("cs.S2C_TeamPVPInviteNPC", msg, len)

    if type(decodeBuffer) ~= "table" then 
        return 
    end
    -- dump(decodeBuffer)
    if decodeBuffer.ret == NetMsg_ERROR.RET_OK then
        G_Me.dailyPvpData:setNpcCD()
        uf_eventManager:dispatchEvent(G_EVENTMSGID.EVENT_TEAMPVPINVITENPC, nil, false,decodeBuffer)
    elseif decodeBuffer.ret == NetMsg_ERROR.RET_TEAM_PVP_NOT_IN_TEAM then
        uf_eventManager:dispatchEvent(G_EVENTMSGID.EVENT_TEAMPVPNOTINTEAM, nil, false,decodeBuffer)
    elseif decodeBuffer.ret == RET_TEAM_PVP_NPC_SEARCH_CD then
        self:sendTeamPVPGetUserInfo()
    end
end


function DailyPvpHandler:_recvTeamPVPAgreeBattle( msgId, msg, len)
    local decodeBuffer = self:_decodeBuf("cs.S2C_TeamPVPAgreeBattle", msg, len)

    if type(decodeBuffer) ~= "table" then 
        return 
    end
    decodeBuffer.agree = self._sendAgreeBattle
    if decodeBuffer.ret == NetMsg_ERROR.RET_OK then

        uf_eventManager:dispatchEvent(G_EVENTMSGID.EVENT_TEAMPVPAGREEBATTLE, nil, false,decodeBuffer)
    elseif decodeBuffer.ret == NetMsg_ERROR.RET_TEAM_PVP_NOT_IN_TEAM then
        uf_eventManager:dispatchEvent(G_EVENTMSGID.EVENT_TEAMPVPNOTINTEAM, nil, false,decodeBuffer)
    end

end


function DailyPvpHandler:_recvTeamPVPMatchOtherTeam( msgId, msg, len)
    local decodeBuffer = self:_decodeBuf("cs.S2C_TeamPVPMatchOtherTeam", msg, len)

    if type(decodeBuffer) ~= "table" then 
        return 
    end
    if decodeBuffer.ret == NetMsg_ERROR.RET_OK then
        
        uf_eventManager:dispatchEvent(G_EVENTMSGID.EVENT_TEAMPVPMATCHOTHERTEAM, nil, false,decodeBuffer)
    elseif decodeBuffer.ret == NetMsg_ERROR.RET_TEAM_PVP_NOT_IN_TEAM then
        uf_eventManager:dispatchEvent(G_EVENTMSGID.EVENT_TEAMPVPNOTINTEAM, nil, false,decodeBuffer)
    end
 
end

function DailyPvpHandler:_recvTeamPVPChangePosition( msgId, msg, len)
    local decodeBuffer = self:_decodeBuf("cs.S2C_TeamPVPMatchOtherTeam", msg, len)

    if type(decodeBuffer) ~= "table" then 
        return 
    end
    if decodeBuffer.ret == NetMsg_ERROR.RET_OK then
        
        uf_eventManager:dispatchEvent(G_EVENTMSGID.EVENT_TEAMPVPCHANGEPOSITION, nil, false,decodeBuffer)
    elseif decodeBuffer.ret == NetMsg_ERROR.RET_TEAM_PVP_NOT_IN_TEAM then
        uf_eventManager:dispatchEvent(G_EVENTMSGID.EVENT_TEAMPVPNOTINTEAM, nil, false,decodeBuffer)
    end
 
end

function DailyPvpHandler:_recvTeamPVPBattleResult( msgId, msg, len)
    local decodeBuffer = self:_decodeBuf("cs.S2C_TeamPVPBattleResult", msg, len)

    if type(decodeBuffer) ~= "table" then 
        return 
    end
    -- dump(decodeBuffer)
    G_Me.dailyPvpData:battleStart()
    G_Me.dailyPvpData:updateReplay(decodeBuffer.report,false)
    uf_eventManager:dispatchEvent(G_EVENTMSGID.EVENT_TEAMPVPBATTLERESULT, nil, false,decodeBuffer)
 
end

function DailyPvpHandler:_recvTeamPVPStopMatch( msgId, msg, len)
    local decodeBuffer = self:_decodeBuf("cs.S2C_TeamPVPStopMatch", msg, len)

    if type(decodeBuffer) ~= "table" then 
        return 
    end
    if decodeBuffer.ret == NetMsg_ERROR.RET_OK then
        
        uf_eventManager:dispatchEvent(G_EVENTMSGID.EVENT_TEAMPVPSTOPMATCH, nil, false,decodeBuffer)
    elseif decodeBuffer.ret == NetMsg_ERROR.RET_TEAM_PVP_NOT_IN_TEAM then
        uf_eventManager:dispatchEvent(G_EVENTMSGID.EVENT_TEAMPVPNOTINTEAM, nil, false,decodeBuffer)
    end
 
end

function DailyPvpHandler:_recvTeamPVPHistoryBattleReport( msgId, msg, len)
    local decodeBuffer = self:_decodeBuf("cs.S2C_TeamPVPHistoryBattleReport", msg, len)

    if type(decodeBuffer) ~= "table" then 
        return 
    end
    G_Me.dailyPvpData:updateReplay(decodeBuffer.report,true)
    uf_eventManager:dispatchEvent(G_EVENTMSGID.EVENT_TEAMPVPHISTORYBATTLEREPORT, nil, false,decodeBuffer)
 
end

function DailyPvpHandler:_recvTeamPVPHistoryBattleReportEnd( msgId, msg, len)
    local decodeBuffer = self:_decodeBuf("cs.S2C_TeamPVPHistoryBattleReportEnd", msg, len)

    if type(decodeBuffer) ~= "table" then 
        return 
    end
        
    uf_eventManager:dispatchEvent(G_EVENTMSGID.EVENT_TEAMPVPHISTORYBATTLEREPORTEND, nil, false,decodeBuffer)
 
end

function DailyPvpHandler:_recvTeamPVPGetRank( msgId, msg, len)
    local decodeBuffer = self:_decodeBuf("cs.S2C_TeamPVPGetRank", msg, len)

    if type(decodeBuffer) ~= "table" then 
        return 
    end
    -- dump(decodeBuffer)
    if decodeBuffer.ret == NetMsg_ERROR.RET_OK then
        G_Me.dailyPvpData:setRankList(decodeBuffer)
        uf_eventManager:dispatchEvent(G_EVENTMSGID.EVENT_TEAMPVPGETRANK, nil, false,decodeBuffer)
    end
 
end

function DailyPvpHandler:_recvTeamPVPGetUserInfo( msgId, msg, len)
    local decodeBuffer = self:_decodeBuf("cs.S2C_TeamPVPGetUserInfo", msg, len)

    if type(decodeBuffer) ~= "table" then 
        return 
    end
    -- dump(decodeBuffer)
    if decodeBuffer.ret == NetMsg_ERROR.RET_OK then
        G_Me.userData.dailyPVPScore = decodeBuffer.score
        G_Me.dailyPvpData:updateUserData(decodeBuffer)
        uf_eventManager:dispatchEvent(G_EVENTMSGID.EVENT_TEAMPVPGETUSERINFO, nil, false,decodeBuffer)
    end
 
end

function DailyPvpHandler:_recvTeamPVPBuyAwardCnt( msgId, msg, len)
    local decodeBuffer = self:_decodeBuf("cs.S2C_TeamPVPBuyAwardCnt", msg, len)

    if type(decodeBuffer) ~= "table" then 
        return 
    end
    if decodeBuffer.ret == NetMsg_ERROR.RET_OK then
        G_Me.dailyPvpData:buyOneTimes()
        uf_eventManager:dispatchEvent(G_EVENTMSGID.EVENT_TEAMPVPBUYAWARDCNT, nil, false,decodeBuffer)
    end
 
end

function DailyPvpHandler:_recvTeamPVPAcceptInvite( msgId, msg, len)
    local decodeBuffer = self:_decodeBuf("cs.S2C_TeamPVPAcceptInvite", msg, len)

    if type(decodeBuffer) ~= "table" then 
        return 
    end
    if decodeBuffer.ret == NetMsg_ERROR.RET_OK then
        G_Me.dailyPvpData:setAcceptInvite(self._sendAccept)
        uf_eventManager:dispatchEvent(G_EVENTMSGID.EVENT_TEAMPVPBUYAWARDCNT, nil, false,decodeBuffer)
    end
 
end

function DailyPvpHandler:_recvTeamPVPCrossServerLost( msgId, msg, len)
    local decodeBuffer = self:_decodeBuf("cs.S2C_TeamPVPAcceptInvite", msg, len)
    self:sendTeamPVPStatus()
end

function DailyPvpHandler:_recvTeamPVPPopChat( msgId, msg, len)
    local decodeBuffer = self:_decodeBuf("cs.S2C_TeamPVPPopChat", msg, len)

    if type(decodeBuffer) ~= "table" then 
        return 
    end
    if decodeBuffer.ret == NetMsg_ERROR.RET_OK then
        G_Me.dailyPvpData:setPopChat(self._sendPopChat)
        uf_eventManager:dispatchEvent(G_EVENTMSGID.EVENT_TEAMPVPTEAMPOPCHAT, nil, false,decodeBuffer)
    end
 
end

-------------send messages

function DailyPvpHandler:sendTeamPVPStatus( )
    local msg = {

    }
    local msgBuffer = protobuf.encode("cs.C2S_TeamPVPStatus", msg) 
    self:sendMsg(NetMsg_ID.ID_C2S_TeamPVPStatus, msgBuffer)
end


function DailyPvpHandler:sendTeamPVPCreateTeam()
    local msg = {

    }
    local msgBuffer = protobuf.encode("cs.C2S_TeamPVPCreateTeam", msg) 
    self:sendMsg(NetMsg_ID.ID_C2S_TeamPVPCreateTeam, msgBuffer)
end

function DailyPvpHandler:sendTeamPVPJoinTeam( )
    local msg = {
    
    }
    local msgBuffer = protobuf.encode("cs.C2S_TeamPVPJoinTeam", msg) 
    self:sendMsg(NetMsg_ID.ID_C2S_TeamPVPJoinTeam, msgBuffer)
end


function DailyPvpHandler:sendTeamPVPLeave()
    local msg = {

    }
    local msgBuffer = protobuf.encode("cs.C2S_TeamPVPLeave", msg) 
    self:sendMsg(NetMsg_ID.ID_C2S_TeamPVPLeave, msgBuffer)
end

function DailyPvpHandler:sendTeamPVPKickTeamMember( member )
    local msg = {
        kicked_sid = member.sid,
        kicked_user_id = member.id
    }
    local msgBuffer = protobuf.encode("cs.C2S_TeamPVPKickTeamMember", msg) 
    self:sendMsg(NetMsg_ID.ID_C2S_TeamPVPKickTeamMember, msgBuffer)
end


function DailyPvpHandler:sendTeamPVPSetTeamOnlyInvited(only)
    local msg = {
        only_invited = only,
    }
    self._onlyInvited = only
    local msgBuffer = protobuf.encode("cs.C2S_TeamPVPSetTeamOnlyInvited", msg) 
    self:sendMsg(NetMsg_ID.ID_C2S_TeamPVPSetTeamOnlyInvited, msgBuffer)
end

function DailyPvpHandler:sendTeamPVPInvite(id )
    local msg = {
        invited_user_id = id,
        team_id = G_Me.dailyPvpData:getTeamId(),
    }
    self._inviteFriendId = id
    local msgBuffer = protobuf.encode("cs.C2S_TeamPVPInvite", msg) 
    self:sendMsg(NetMsg_ID.ID_C2S_TeamPVPInvite, msgBuffer)
end


function DailyPvpHandler:sendTeamPVPInvitedJoinTeam(uid,tid)
    local msg = {
        invitor_user_id = uid,
        invitor_team_id = tid,
    }
    self._invitorTeamId = tid
    local msgBuffer = protobuf.encode("cs.C2S_TeamPVPInvitedJoinTeam", msg) 
    self:sendMsg(NetMsg_ID.ID_C2S_TeamPVPInvitedJoinTeam, msgBuffer)
end

function DailyPvpHandler:sendTeamPVPInviteNPC()
    local msg = {
        
    }
    local msgBuffer = protobuf.encode("cs.C2S_TeamPVPInviteNPC", msg) 
    self:sendMsg(NetMsg_ID.ID_C2S_TeamPVPInviteNPC, msgBuffer)
end

function DailyPvpHandler:sendTeamPVPAgreeBattle(agree )
    local msg = {
        agree = agree,
    }
    self._sendAgreeBattle = agree
    local msgBuffer = protobuf.encode("cs.C2S_TeamPVPAgreeBattle", msg) 
    self:sendMsg(NetMsg_ID.ID_C2S_TeamPVPAgreeBattle, msgBuffer)
end


function DailyPvpHandler:sendTeamPVPMatchOtherTeam()
    local msg = {
        
    }
    local msgBuffer = protobuf.encode("cs.C2S_TeamPVPMatchOtherTeam", msg) 
    self:sendMsg(NetMsg_ID.ID_C2S_TeamPVPMatchOtherTeam, msgBuffer)
end

function DailyPvpHandler:sendTeamPVPStopMatch()
    local msg = {
        
    }
    local msgBuffer = protobuf.encode("cs.C2S_TeamPVPStopMatch", msg) 
    self:sendMsg(NetMsg_ID.ID_C2S_TeamPVPStopMatch, msgBuffer)
end

function DailyPvpHandler:sendTeamPVPChangePosition(pos1,pos2)
    local msg = {
        pos1 = pos1,
        pos2 = pos2,
    }
    local msgBuffer = protobuf.encode("cs.C2S_TeamPVPChangePosition", msg) 
    self:sendMsg(NetMsg_ID.ID_C2S_TeamPVPChangePosition, msgBuffer)
end

function DailyPvpHandler:sendTeamPVPHistoryBattleReport()
    local msg = {
        
    }
    local msgBuffer = protobuf.encode("cs.C2S_TeamPVPHistoryBattleReport", msg) 
    self:sendMsg(NetMsg_ID.ID_C2S_TeamPVPHistoryBattleReport, msgBuffer)
end

function DailyPvpHandler:sendTeamPVPGetRank()
    local msg = {
        
    }
    local msgBuffer = protobuf.encode("cs.C2S_TeamPVPGetRank", msg) 
    self:sendMsg(NetMsg_ID.ID_C2S_TeamPVPGetRank, msgBuffer)
end

function DailyPvpHandler:sendTeamPVPGetUserInfo()
    local msg = {
        
    }
    local msgBuffer = protobuf.encode("cs.C2S_TeamPVPGetUserInfo", msg) 
    self:sendMsg(NetMsg_ID.ID_C2S_TeamPVPGetUserInfo, msgBuffer)
end

function DailyPvpHandler:sendTeamPVPBuyAwardCnt()
    local msg = {
        
    }
    local msgBuffer = protobuf.encode("cs.C2S_TeamPVPBuyAwardCnt", msg) 
    self:sendMsg(NetMsg_ID.ID_C2S_TeamPVPBuyAwardCnt, msgBuffer)
end

function DailyPvpHandler:sendTeamPVPAcceptInvite(accept)
    local msg = {
        accept = accept,
    }
    self._sendAccept = accept
    local msgBuffer = protobuf.encode("cs.C2S_TeamPVPAcceptInvite", msg) 
    self:sendMsg(NetMsg_ID.ID_C2S_TeamPVPAcceptInvite, msgBuffer)
end

function DailyPvpHandler:sendTeamPVPPopChat(accept)
    local msg = {
        pop_chat = accept,
    }
    self._sendPopChat = accept
    local msgBuffer = protobuf.encode("cs.C2S_TeamPVPPopChat", msg) 
    self:sendMsg(NetMsg_ID.ID_C2S_TeamPVPPopChat, msgBuffer)
end

function DailyPvpHandler:sendTeamPVPBattleTeamChange()
    local msg = {
        
    }
    local msgBuffer = protobuf.encode("cs.C2S_TeamPVPBattleTeamChange", msg) 
    self:sendMsg(NetMsg_ID.ID_C2S_TeamPVPBattleTeamChange, msgBuffer)
end

return DailyPvpHandler
