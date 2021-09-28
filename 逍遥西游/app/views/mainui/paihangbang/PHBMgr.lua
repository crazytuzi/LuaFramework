local _rankPHBSortFunc = function(a, b)
  if a == nil or b == nil then
    return false
  end
  if a.index == nil or b.index == nil then
    return false
  end
  return a.index < b.index
end
local PHBMgr = class(".PHBMgr", nil)
function PHBMgr:ctor()
  self.m_RankIssue = {}
  self.m_RankInfoCache = {}
  self.m_RankInfoIsFinish = {}
  self.m_IsRequestingIndex = {}
  self.m_SelfRankInfo = {}
  for _, bType in pairs(PHB_DEF_ALL_TYPE_DATA) do
    self.m_RankIssue[bType] = {}
    self.m_RankIssue[bType][1] = -1
    self.m_RankIssue[bType][2] = -1
    self.m_RankIssue[bType][3] = -1
    self.m_RankInfoCache[bType] = {}
    self.m_RankInfoCache[bType][1] = {}
    self.m_RankInfoCache[bType][2] = {}
    self.m_RankInfoCache[bType][3] = {}
    self.m_RankInfoIsFinish[bType] = {}
    self.m_RankInfoIsFinish[bType][1] = false
    self.m_RankInfoIsFinish[bType][2] = false
    self.m_RankInfoIsFinish[bType][3] = false
    self.m_IsRequestingIndex[bType] = {}
    self.m_IsRequestingIndex[bType][1] = -1
    self.m_IsRequestingIndex[bType][2] = -1
    self.m_IsRequestingIndex[bType][3] = -1
    self.m_SelfRankInfo[bType] = {}
  end
  self.m_InfoNumEveryTime = 10
end
function PHBMgr:getPHBRankInfo(bType, range, index)
  print("---->>PHB请求获取排行榜分段数据", self.m_RankIssue[bType][range], index)
  local canOpFlag = false
  if self.m_IsRequestingIndex[bType][range] >= 0 then
    print("--->>PHB正在请求数据", self.m_IsRequestingIndex[bType][range])
    return nil, canOpFlag, true
  end
  if self.m_RankIssue[bType][range] == -1 then
    print("--->>PHB本地没有数据，需要获取初始数据")
    self:send_requestPHBRankInfo(0, 0, bType, range)
    return nil, canOpFlag, true
  elseif index == 0 then
    print("--->>PHB获取初始数据时，先check本地缓存数据的有效性")
    self:send_checkPHBRankInfoIsEffective(self.m_RankIssue[bType][range], index, bType, range)
    return nil, canOpFlag, true
  elseif index >= 100 then
    print("--->>PHB没有更多数据(1)", index, self.m_RankInfoIsFinish[bType][range])
    return nil, canOpFlag, false
  elseif index + 1 > #self.m_RankInfoCache[bType][range] then
    if self.m_RankInfoIsFinish[bType][range] then
      print("--->>PHB没有更多数据(2)", index, self.m_RankInfoIsFinish[bType][range])
      return nil, true, false
    else
      print("--->>PHB超过本地缓存以外的数据段，需要向服务器获取")
      self:send_requestPHBRankInfo(self.m_RankIssue[bType][range], index, bType, range)
      return nil, canOpFlag, true
    end
  else
    local infoList = {}
    for i = index + 1, index + self.m_InfoNumEveryTime do
      local info = self.m_RankInfoCache[bType][range][i]
      if info ~= nil then
        infoList[#infoList + 1] = info
      else
        break
      end
    end
    print("--->>PHB返回本地有效数据，数据长度:", #infoList)
    return infoList, true, false
  end
end
function PHBMgr:checkPHBRankInfoIsEffectiveForeground(index, bType, range)
  self:send_checkPHBRankInfoIsEffective(self.m_RankIssue[bType][range], index, bType, range)
end
function PHBMgr:setPHBRankInfo(issue, bType, range, rankInfo)
  print("PHBMgr:setPHBRankInfo")
  if self.m_RankIssue[bType][range] ~= issue then
    self.m_RankIssue[bType][range] = issue
    self.m_RankInfoCache[bType][range] = {}
    self.m_RankInfoIsFinish[bType][range] = false
    SendMessage(MsgID_PHB_ClearRankList)
  end
  table.sort(rankInfo, _rankPHBSortFunc)
  for _, info in ipairs(rankInfo) do
    self.m_RankInfoCache[bType][range][#self.m_RankInfoCache[bType][range] + 1] = info
  end
  SendMessage(MsgID_PHB_NewRankInfo, bType, range, rankInfo)
  self.m_IsRequestingIndex[bType][range] = -1
end
function PHBMgr:setRankInfoFinish(issue, bType, range)
  if self.m_RankIssue[bType][range] == issue then
    self.m_RankInfoIsFinish[bType][range] = true
    self.m_IsRequestingIndex[bType][range] = -1
  end
  SendMessage(MsgID_PHB_RankIsFinished)
end
function PHBMgr:checkRankInfoIsOk(issue, bType, range)
  print("PHBMgr:checkRankInfoIsOk")
  if self.m_RankIssue[bType][range] == issue then
    if self.m_IsRequestingIndex[bType][range] == 0 then
      local infoList = {}
      for i = 1, self.m_InfoNumEveryTime do
        local info = self.m_RankInfoCache[bType][range][i]
        if info ~= nil then
          infoList[#infoList + 1] = info
        else
          break
        end
      end
      SendMessage(MsgID_PHB_NewRankInfo, bType, range, infoList)
    end
    self.m_IsRequestingIndex[bType][range] = -1
  end
  SendMessage(MsgID_PHB_RankIsOk)
end
function PHBMgr:setSelfRankInfo(bType, num, index)
  self.m_SelfRankInfo[bType] = {num = num, index = index}
  SendMessage(MsgID_PHB_UpdateSelfData, {
    bType = bType,
    num = num,
    index = index
  })
end
function PHBMgr:send_requestPHBRankInfo(issue, index, bType, range)
  netsend.netphb.requestPHBRankInfo(issue, index, bType, range)
end
function PHBMgr:send_checkPHBRankInfoIsEffective(issue, index, bType, range)
  self.m_IsRequestingIndex[bType][range] = index
  netsend.netphb.checkPHBRankInfoIsEffective(issue, bType, range)
end
function PHBMgr:send_requestPHBSelfData(bType)
  netsend.netphb.requestPHBSelfData(bType)
end
function PHBMgr:Clear()
end
g_PHBMgr = PHBMgr.new()
gamereset.registerResetFunc(function()
  if g_PHBMgr then
    g_PHBMgr:Clear()
    g_PHBMgr = nil
  end
  g_PHBMgr = PHBMgr.new()
end)
