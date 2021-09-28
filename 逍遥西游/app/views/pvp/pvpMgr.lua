local _rankSortFunc = function(a, b)
  if a == nil or b == nil then
    return false
  end
  return a.i_rank < b.i_rank
end
local PvpMgr = class(".PvpMgr", nil)
function PvpMgr:ctor()
  self.m_RankIssue = -1
  self.m_RankInfoCache = {}
  self.m_RankInfoIsFinish = false
  self.m_IsRequestingIndex = -1
  self.m_InfoNumEveryTime = 10
  self.m_LastUpdatePvpEnemyTime = 0
  self.m_CD_UpdatePvpEnemyTime = 1
  self.m_CanFightTimes = 0
  self.m_HasBuyBWCNum = 0
end
function PvpMgr:getRankInfo(index)
  print("---->>请求获取排行榜分段数据", self.m_RankIssue, index)
  if self.m_IsRequestingIndex >= 0 then
    print("--->>正在请求数据", self.m_IsRequestingIndex)
    return nil, true
  end
  if self.m_RankIssue == -1 then
    print("--->>本地没有数据，需要获取初始数据")
    self:send_requestPvpRankInfo(0, 0)
    return nil, true
  elseif index == 0 then
    print("--->>获取初始数据时，先check本地缓存数据的有效性")
    self:send_checkPvpRankInfoIsEffective(self.m_RankIssue, index)
    return nil, true
  elseif index >= 100 then
    print("--->>没有更多数据", index, self.m_RankInfoIsFinish)
    return nil, false
  elseif index + 1 > #self.m_RankInfoCache then
    if self.m_RankInfoIsFinish then
      print("--->>没有更多数据", index, self.m_RankInfoIsFinish)
      return nil, false
    else
      print("--->>超过本地缓存以外的数据段，需要向服务器获取")
      self:send_requestPvpRankInfo(self.m_RankIssue, index)
      return nil, true
    end
  else
    local infoList = {}
    for i = index + 1, index + self.m_InfoNumEveryTime do
      local info = self.m_RankInfoCache[i]
      if info ~= nil then
        infoList[#infoList + 1] = info
      else
        break
      end
    end
    print("--->>返回本地有效数据，数据长度:", #infoList)
    return infoList, false
  end
end
function PvpMgr:getCanFightTimes()
  return self.m_CanFightTimes
end
function PvpMgr:checkPvpRankInfoIsEffectiveForeground(index)
  self:send_checkPvpRankInfoIsEffective(self.m_RankIssue, index)
end
function PvpMgr:setPvpBaseInfo(info)
  if info.i_chance ~= nil then
    self.m_CanFightTimes = info.i_chance
    SendMessage(MsgID_Pvp_BWCFightNum, info.i_chance)
  end
  SendMessage(MsgID_Pvp_BaseInfo, info)
end
function PvpMgr:setBuyBWCNum(bwcNum)
  if bwcNum ~= nil then
    self.m_HasBuyBWCNum = bwcNum
  end
end
function PvpMgr:getBuyBWCNum()
  return self.m_HasBuyBWCNum or 0
end
function PvpMgr:setBWCFightNum(num)
  if num ~= nil then
    self.m_CanFightTimes = num
    SendMessage(MsgID_Pvp_BWCFightNum, num)
  end
end
function PvpMgr:setPvpRankInfo(issue, rankInfo)
  if self.m_RankIssue ~= issue then
    self.m_RankIssue = issue
    self.m_RankInfoCache = {}
    self.m_RankInfoIsFinish = false
    SendMessage(MsgID_Pvp_ClearRankList)
  end
  table.sort(rankInfo, _rankSortFunc)
  for _, info in ipairs(rankInfo) do
    self.m_RankInfoCache[#self.m_RankInfoCache + 1] = info
  end
  SendMessage(MsgID_Pvp_NewRankInfo, rankInfo)
  self.m_IsRequestingIndex = -1
end
function PvpMgr:setRankInfoFinish(issue)
  if self.m_RankIssue == issue then
    self.m_RankInfoIsFinish = true
    self.m_IsRequestingIndex = -1
    SendMessage(MsgID_Pvp_RankInfoFinish)
  end
end
function PvpMgr:checkRankInfoIsOk(issue)
  if self.m_RankIssue == issue then
    if self.m_IsRequestingIndex == 0 then
      local infoList = {}
      for i = 1, self.m_InfoNumEveryTime do
        local info = self.m_RankInfoCache[i]
        if info ~= nil then
          infoList[#infoList + 1] = info
        else
          break
        end
      end
      SendMessage(MsgID_Pvp_NewRankInfo, infoList)
    end
    self.m_IsRequestingIndex = -1
    SendMessage(MsgID_Pvp_RankIsOk)
  end
end
function PvpMgr:send_requestPvpBaseInfo()
  netsend.netpvp.requestPvpBaseInfo()
end
function PvpMgr:send_requestNewEnemy()
  local curTime = g_DataMgr:getServerTime()
  if curTime - self.m_LastUpdatePvpEnemyTime < self.m_CD_UpdatePvpEnemyTime then
    return
  end
  self.m_LastUpdatePvpEnemyTime = curTime
  netsend.netpvp.requestNewEnemy()
end
function PvpMgr:send_requestPvpFight(pid, rank)
  local teamState = g_LocalPlayer:getIsFollowTeam()
  if teamState > 0 then
    ShowNotifyTips("组队情况下队长不能进入比武场")
    return
  elseif teamState == 0 then
    ShowNotifyTips("组队跟随状态下不能进入比武场")
    return
  end
  netsend.netpvp.requestPvpFight(pid, rank)
end
function PvpMgr:send_requestPvpRankInfo(issue, index)
  self.m_IsRequestingIndex = index
  netsend.netpvp.requestPvpRankInfo(issue, index)
end
function PvpMgr:send_checkPvpRankInfoIsEffective(issue, index)
  self.m_IsRequestingIndex = index
  netsend.netpvp.checkPvpRankInfoIsEffective(issue)
end
function PvpMgr:Clear()
end
g_PvpMgr = PvpMgr.new()
gamereset.registerResetFunc(function()
  if g_PvpMgr then
    g_PvpMgr:Clear()
    g_PvpMgr = nil
  end
  g_PvpMgr = PvpMgr.new()
end)
