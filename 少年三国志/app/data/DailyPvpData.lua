
local DailyPvpData = class("DailyPvpData")
local DailyPvpConst = require("app.const.DailyPvpConst")

require("app.cfg.daily_crosspvp_rank")
require("app.cfg.daily_crosspvp_award")
--[[message CrossUser {
  required uint32 id = 1;
  required uint64 sid = 2;
  optional string name = 3;
  optional string sname = 4;
  optional uint32 dress_id = 5;
  optional uint32 main_role = 6;
  optional uint32 fight_value = 7;
  optional uint32 sp1 = 8;//特殊字段 前后端对应 模块内对应
  optional uint32 sp2 = 9;
  optional uint32 fight_pet = 10;//战宠
  optional uint32 level = 11;//等级 //这个后面补的 有些地方还是都需要等级的 之前有2个模块用了SP2字段作为等级
  optional uint32 fid = 12;//头像框
  optional uint32 vip = 13;//
  optional uint32 sp3 = 14;
  optional uint32 sp4 = 15;
  optional uint32 sp5 = 16;
}]]

DailyPvpData.TOTAL_TIMES = 3
DailyPvpData.NPC_CD = 60
DailyPvpData.SPECIALTIME = {{start = 43200,stop = 50400},{start = 64800,stop = 72000}}

function DailyPvpData:ctor()
    self._teamId = 0
    self._status = 0
    self._teamMembers = {}
    self._onlyInvited = false

    self._honor = 0 --荣誉值
    self._awardCount = 0
    self._buyCount = 0
    self._npcCD = 0
    self._rank = 0
    self._title = 0
    self._accept_invite = true
    self._pop_chat = true
    self._readyTime = 0
    self._inBattle = false

    self._online_buff = 0
    self._corp_buff = 0
    self._friend_buff = 0

    self._invitedList = {}
    self._friends = {}
    self._onlineFriends = {}

    self._rankList = {}
    self._replays = {}
    self._gotReplay = false
    self._showTips = true

    self._date = nil
end

function DailyPvpData:isNeedRequestNewData()
    local dateTime = G_ServerTime:getDate()
    if dateTime ~= self._date  then
        return true
    else
        return false
    end
end

function DailyPvpData:updateUserData(data)
    self._date = G_ServerTime:getDate()
    self._honor = data.honor
    self._awardCount = data.award_cnt
    self._buyCount = data.buyed_award_cnt
    self._npcCD = data.npc_cd
    self._rank = data.rank
    self._title = data.title
    self._accept_invite = data.accept_invite
    self._pop_chat = data.pop_chat
end

function DailyPvpData:setRankList(data)
    self._rankList = {}
    for k , v in pairs(data.user) do 
        v.honor = data.honor[k]
        table.insert(self._rankList,k,v)
    end
end

function DailyPvpData:getRankList()
    return self._rankList
end

function DailyPvpData:getHonor()
    return self._honor
end

function DailyPvpData:getAwardCountLeft()
    return DailyPvpData.TOTAL_TIMES + self._buyCount - self._awardCount
end

function DailyPvpData:getBuyCount()
    return self._buyCount
end

function DailyPvpData:setNpcCD()
    self._npcCD = G_ServerTime:getTime()
end

function DailyPvpData:getNpcCd()
    return DailyPvpData.NPC_CD + self._npcCD - G_ServerTime:getTime()
end

function DailyPvpData:getRank()
    return self._rank
end

function DailyPvpData:getTitle()
    return self._title
end

function DailyPvpData:getAcceptInvite()
    return self._accept_invite
end

function DailyPvpData:getPopChat()
    return self._pop_chat
end

function DailyPvpData:setAcceptInvite(accept)
    self._accept_invite = accept
end

function DailyPvpData:setPopChat(pop_chat)
    self._pop_chat = pop_chat
end

function DailyPvpData:buyOneTimes()
    self._buyCount = self._buyCount + 1
end

function DailyPvpData:updateData(data)

  -- if  G_Me.dailyPvpData:isFull() then
  --     if G_Me.dailyPvpData:allReady() then
    local comeFull = false 
    local comeNotFull = false
    local inMatch = false
    local outMatch = false
    if not self:isFull() or not self:allReady() then
        local full = rawget(data,"team_members") and #data.team_members == 5
        if full then
            local ready = true
            for k , v in pairs(data.team_members) do 
              if data.leader_pos ~= v.sp3 then
                if not rawget(v,"sp5") or v.sp5 == 0 then
                  ready = false
                end
              end
            end
            if ready then
              comeFull = true
            end
        end
    end
    if self:isFull() and self:allReady() then
        local full = rawget(data,"team_members") and #data.team_members == 5
        if full then
            local ready = true
            for k , v in pairs(data.team_members) do 
              if data.leader_pos ~= v.sp3 then
                if not rawget(v,"sp5") or v.sp5 == 0 then
                  ready = false
                end
              end
            end
            if not ready then
              comeNotFull = true
            end
        else
          comeNotFull = true
        end
    end
    if self._status == DailyPvpConst.INTEAM and data.status == DailyPvpConst.MATCHING_FIGHT then
          inMatch = true
    end
    if self._status == DailyPvpConst.MATCHING_FIGHT and data.status == DailyPvpConst.INTEAM then
          outMatch = true
    end

    self._teamId = data.team_id
    self._status = data.status
    self._teamMembers = {}
    if rawget(data,"team_members") then
        for k , v in pairs(data.team_members) do 
            v.isLeader = data.leader_pos == v.sp3
            table.insert(self._teamMembers,#self._teamMembers+1,v)
        end
    end
    self._onlyInvited = data.only_invited
    self._online_buff = data.online_buff
    self._corp_buff = data.corp_buff
    self._friend_buff = data.friend_buff

    if comeFull then
          self:updateReadyTime()
          uf_eventManager:dispatchEvent(G_EVENTMSGID.EVENT_TEAMPVPTEAMCOMEFULL, nil, false,data)
    end
    if comeNotFull then
          self:updateReadyTime()
          uf_eventManager:dispatchEvent(G_EVENTMSGID.EVENT_TEAMPVPTEAMCOMENOTFULL, nil, false,data)
    end
    if inMatch then
          self:updateReadyTime()
          uf_eventManager:dispatchEvent(G_EVENTMSGID.EVENT_TEAMPVPTEAMINMATCH, nil, false,data)
    end
    if outMatch then
          self:updateReadyTime()
          uf_eventManager:dispatchEvent(G_EVENTMSGID.EVENT_TEAMPVPTEAMOUTMATCH, nil, false,data)
    end
    if not self:inTeam() then
          self:updateReadyTime()
    end
end

function DailyPvpData:updateReadyTime()
      if self:isFull() and self:allReady() and self._status == DailyPvpConst.INTEAM then
          self._readyTime = G_ServerTime:getTime()
      else
          self._readyTime = 0
      end
end

function DailyPvpData:getReadyTime()
      return self._readyTime
end

function DailyPvpData:checkReadyTime()
      if self:isLeader() and self._readyTime>0 and self._status == DailyPvpConst.INTEAM and self:isFull() and not (self:isSingle() and self._inBattle) and self:allReady() and G_ServerTime:getTime() - self._readyTime > require("app.scenes.dailypvp.DailyPvpTeamLayer").WAITTIME1 then
          G_HandlersManager.dailyPvpHandler:sendTeamPVPLeave()
      end
end

function DailyPvpData:getOnlineBuff()
    return self._online_buff
end

function DailyPvpData:getCorpBuff()
    return self._corp_buff
end

function DailyPvpData:getFriendBuff()
    return self._friend_buff
end

function DailyPvpData:getTotalBuff()
    return self._friend_buff + self._online_buff + self._corp_buff
end

function DailyPvpData:insertInvitedData(data)
    for k , v in pairs(self._invitedList) do 
        if v.team_id == data.invitor_team_id then
            return
        end
    end
    table.insert(self._invitedList,#self._invitedList+1,{user_id=data.invitor_user_id,team_id=data.invitor_team_id})
end

function DailyPvpData:deleteInvitedData(teamId)
    for k , v in pairs(self._invitedList) do 
        if v.team_id == teamId then
            table.remove(self._invitedList,k)
            return
        end
    end
end

function DailyPvpData:getInvitedList()
  if not self._accept_invite then
    return {}
  end
  local list = {}
  for k , v in pairs(self._invitedList) do 
      local friend = self:getFriend(v.user_id)
      -- if rawget(friend,"team_pvp_title") and friend.team_pvp_title > 0 then
          local find = false
          for k2 , v2 in pairs(self._teamMembers) do 
              if friend.id == v2.id and tostring(v2.sid) == tostring(G_PlatformProxy:getLoginServer().id) then
                 find = true
              end
          end
          if not find then
              table.insert(list,#list+1,v)
          end
      -- end
  end
  return list
end

function DailyPvpData:getTeamId()
    return self._teamId
end

function DailyPvpData:getStatus()
    return self._status
end

function DailyPvpData:inTeam()
    return self._status == DailyPvpConst.INTEAM or self._status == DailyPvpConst.MATCHING_FIGHT
end

function DailyPvpData:updateOnlyInvited(only)
    self._onlyInvited = only
end

function DailyPvpData:getOnlyInvited()
    return self._onlyInvited
end

function DailyPvpData:getTeamMembers()
    return self._teamMembers
end

function DailyPvpData:getSelfData()
    for k , v in pairs(self._teamMembers) do 
        if v.id == G_Me.userData.id and tostring(v.sid) == tostring(G_PlatformProxy:getLoginServer().id) then
          return v
        end
    end
end

function DailyPvpData:isLeader()
    local data = self:getSelfData()
    if not data then
      return false
    end
    return data.isLeader
end

function DailyPvpData:isFull()
    return #self._teamMembers == 5
end

function DailyPvpData:allReady()
    for k , v in pairs(self._teamMembers) do 
        if not v.isLeader then
          if not rawget(v,"sp5") or v.sp5 == 0 then
            return false
          end
        end
    end
    return true
end

function DailyPvpData:updateFriends(data)
    for k , v in pairs(data) do 
      local info = self:getFriend(v.id)
      if info then
        info.level = v.level
        info.fighting_capacity = v.fighting_capacity
        info.vip = v.vip
        info.online = v.online
        info.dress_id = v.dress_id
        info.team_pvp_title = v.team_pvp_title
        -- 好友可能在发邀请之前改过名字  added by 守彬
        if v.name then
          info.name = v.name
        end
      else
        v.lastSendTime = 0
        table.insert(self._friends,#self._friends+1,v)
      end
    end
    self._onlineFriends = {}
    for k , v in pairs(self._friends) do 
      if v.online == 0 then
        table.insert(self._onlineFriends,#self._onlineFriends+1,v)
      end
    end
end

function DailyPvpData:getFriend(id)
    for k , v in pairs(self._friends) do 
        if v.id == id then
          return v 
        end
    end
    return nil
end

function DailyPvpData:getOnlineFriends()
      local list = {}
      for k1 , v1 in pairs(self._onlineFriends) do 
            local find = false
            for k2 , v2 in pairs(self._teamMembers) do 
                if v1.id == v2.id and tostring(v2.sid) == tostring(G_PlatformProxy:getLoginServer().id) then
                   find = true
                end
            end
            if not find then
                table.insert(list,#list+1,v1)
            end
      end
      return list
end

function DailyPvpData:inviteFriend(id)
    local info = self:getFriend(id)
    if info then
      info.lastSendTime = G_ServerTime:getTime()
    end
end

function DailyPvpData:battleStart()
    self._status = DailyPvpConst.INTEAM
end

function DailyPvpData:getRankData(rank)
    for i = 1 , daily_crosspvp_rank.getLength() do 
        local data = daily_crosspvp_rank.indexOf(i)
        if rank <= data.lower_rank and rank >= data.upper_rank then
          return data
        end
    end
    return nil
end

function DailyPvpData:updateReplay(report,fromServer)
      if fromServer then 
          self._gotReplay = true
      end
      table.insert(self._replays,#self._replays+1, report)
      if #self._replays > 5 then
        table.remove(self._replays,1)
      end
end

function DailyPvpData:getReplays()
    table.sort(self._replays,function ( a,b )
        return a.battle_id > b.battle_id
    end)
    return self._replays
end

function DailyPvpData:needGetReplays()
    return not self._gotReplay
end

function DailyPvpData:needTips()
    return #self:getInvitedList() > 0 and self._accept_invite
end

function DailyPvpData:inSpecialTime()
    local curTime = G_ServerTime:getTime()
    local secFromToday = G_ServerTime:secondsFromToday(curTime)
    for k , v in pairs(DailyPvpData.SPECIALTIME) do 
          if secFromToday >= v.start and secFromToday <= v.stop then
              return k
          end
    end
    return 0
end

function DailyPvpData:getBaseScore()
    return daily_crosspvp_award.get(G_Me.userData.level)
end

function DailyPvpData:resetData()
    self._status = 0
end

function DailyPvpData:getShowTips()
    return self._showTips
end

function DailyPvpData:setShowTips(show)
    self._showTips = show
end

function DailyPvpData:isSingle()
    if not self:isLeader() then
      return false
    end
    local npc = true
    for k , v in pairs(self._teamMembers) do 
        if not v.isLeader and not self:isNpc(v.id) then
          npc = false
        end
    end
    return npc
end

function DailyPvpData:isNpc(id)
    return id > 2^24
end

function DailyPvpData:goBattle(go)
    self._inBattle = go
    if go == false and self:isSingle() then
        self:updateReadyTime()
    end
end

return DailyPvpData
