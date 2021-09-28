local FriendLimitNum = 80
local CD_FriendCtlRequest = 1
local CFriendsMgr = class(".CFriendsMgr", nil)
function CFriendsMgr:ctor()
  self.m_FriendsInfo = {}
  self.m_FriendRequest = {}
  self.m_TimeRecord = {}
  self.m_BanLvId = nil
end
function CFriendsMgr:getFriendLimitNum()
  return FriendLimitNum
end
function CFriendsMgr:getFriendNum()
  return getTableLength(self.m_FriendsInfo)
end
function CFriendsMgr:getOnLineNum()
  local num = 0
  for pid, pInfo in pairs(self.m_FriendsInfo) do
    if pInfo.status == GAMESTATUS_ONLINE then
      num = num + 1
    end
  end
  return num
end
function CFriendsMgr:getAllFriendsList()
  return self.m_FriendsInfo
end
function CFriendsMgr:getFriendsList()
  local infoList = {}
  for pid, pInfo in pairs(self.m_FriendsInfo) do
    infoList[#infoList + 1] = {pid, pInfo}
  end
  return infoList
end
function CFriendsMgr:getChatFriendsList()
  local infoList = {}
  for pid, pInfo in pairs(self.m_FriendsInfo) do
    if g_LocalPlayer:getPrivateChatTime(pid) ~= nil then
      infoList[#infoList + 1] = {pid, pInfo}
    end
  end
  return infoList
end
function CFriendsMgr:getAllFriendRequestList()
  return self.m_FriendRequest
end
function CFriendsMgr:getSortedRequestList()
  local infoList = {}
  for pid, pInfo in pairs(self.m_FriendRequest) do
    infoList[#infoList + 1] = {pid, pInfo}
  end
  local _requestSortFunc = function(a, b)
    if a == nil or b == nil then
      return false
    end
    local t1 = a[2].time or 0
    local t2 = b[2].time or 0
    return t1 > t2
  end
  table.sort(infoList, _requestSortFunc)
  return infoList
end
function CFriendsMgr:getPlayerInfo(pid)
  if pid == nil then
    return nil
  end
  return self.m_FriendsInfo[pid]
end
function CFriendsMgr:isLocalPlayerFriend(pid)
  return self.m_FriendsInfo[pid] ~= nil
end
function CFriendsMgr:setAllFriendsList(friendsList)
  self.m_FriendsInfo = friendsList
  for pid, pInfo in pairs(self.m_FriendsInfo) do
    self.m_FriendRequest[pid] = nil
  end
  SendMessage(MsgID_Friends_InitAllFirendsList)
end
function CFriendsMgr:setFriend(pid, info)
  local fInfo = self.m_FriendsInfo[pid]
  if fInfo == nil then
    fInfo = {}
    fInfo.name = info.name or ""
    fInfo.rtype = info.rtype or 11001
    fInfo.level = info.level or 0
    fInfo.zs = info.zs or 0
    fInfo.status = info.status or GAMESTATUS_ONLINE
    fInfo.fValue = info.fValue or 0
    fInfo.time = info.time or 0
    fInfo.pcnt = info.pcnt or 0
    self.m_FriendsInfo[pid] = fInfo
    self.m_TimeRecord[pid] = 0
    SendMessage(MsgID_Friends_AddNewFirend, pid, fInfo)
    SendMessage(MsgID_Friends_PlayerStatus, pid, fInfo.status)
    self.m_FriendRequest[pid] = nil
    if g_LocalPlayer then
      g_LocalPlayer:recordPrivateChatTimeInfo(pid)
    end
  else
    if info.name ~= nil then
      fInfo.name = info.name
    end
    if info.rtype ~= nil then
      fInfo.rtype = info.rtype
    end
    if info.level ~= nil then
      fInfo.level = info.level
    end
    if info.zs ~= nil then
      fInfo.zs = info.zs
    end
    if info.fValue ~= nil then
      fInfo.fValue = info.fValue
    end
    if info.pcnt ~= nil then
      fInfo.pcnt = info.pcnt
    end
    if info.status ~= nil then
      if info.status == GAMESTATUS_ONLINE then
        g_MessageMgr:OnFriendOnLine(pid, fInfo.zs, fInfo.name)
      elseif info.status == GAMESTATUS_OUTLINE then
        g_MessageMgr:OnFriendOutLine(pid, fInfo.zs, fInfo.name)
      end
      fInfo.status = info.status
      SendMessage(MsgID_Friends_PlayerStatus, pid, fInfo.status)
    end
    if info.time ~= nil then
      fInfo.time = info.time
    end
    SendMessage(MsgID_Friends_UpdateFirend, pid, info)
  end
end
function CFriendsMgr:deleteFriend(pid)
  local fInfo = self.m_FriendsInfo[pid]
  if fInfo ~= nil then
    self.m_FriendsInfo[pid] = nil
    self.m_TimeRecord[pid] = 0
  end
  SendMessage(MsgID_Friends_DeleteFirend, pid)
  if g_LocalPlayer then
    g_LocalPlayer:deletePrivateChatTimeInfo(pid)
  end
end
function CFriendsMgr:findPlayerInfo(pid, info)
  if self.m_FriendsInfo[pid] ~= nil then
    self:setFriend(pid, info)
  end
  SendMessage(MsgID_Friends_FindPlayerInfo, pid, info)
end
function CFriendsMgr:receivePlayerInfo(pid, info)
  if self.m_FriendsInfo[pid] ~= nil then
    self:setFriend(pid, info)
  end
  SendMessage(MsgID_Friends_QueryPlayerInfo, pid, info)
end
function CFriendsMgr:receiveFriendRequest(pid, info)
  if self.m_FriendsInfo[pid] ~= nil then
    return
  end
  if self.m_FriendRequest[pid] == nil then
    self.m_FriendRequest[pid] = info
    SendMessage(MsgID_Friends_NewFriendRequest, pid, info)
  else
    self.m_FriendRequest[pid] = info
  end
end
function CFriendsMgr:deleteFriendRequest(pid)
  if self.m_FriendRequest[pid] ~= nil then
    self.m_FriendRequest[pid] = nil
    SendMessage(MsgID_Friends_DelFriendRequest, pid)
  end
end
function CFriendsMgr:receiveClearFriendRequest()
  self.m_FriendRequest = {}
  SendMessage(MsgID_Friends_ClearRequest)
end
function CFriendsMgr:send_findPlayerById(pid)
  if g_MapMgr:IsInBangPaiWarMap() then
    ShowNotifyTips("帮战地图无法使用此功能")
    return false
  end
  netsend.netfriends.findPlayerById(pid)
end
function CFriendsMgr:send_findPlayerByName(pName)
  if g_MapMgr:IsInBangPaiWarMap() then
    ShowNotifyTips("帮战地图无法使用此功能")
    return false
  end
  netsend.netfriends.findPlayerByName(pName)
end
function CFriendsMgr:send_addFriend(pid, pName)
  if g_MapMgr:IsInBangPaiWarMap() then
    ShowNotifyTips("帮战地图无法使用此功能")
    return false
  end
  if pid == g_LocalPlayer:getPlayerId() then
    ShowNotifyTips("不能添加自己为好友")
    return
  end
  if not self:isLocalPlayerFriend(pid) then
    local curTime = g_DataMgr:getServerTime()
    local lastTime = self.m_TimeRecord[pid] or 0
    if curTime - lastTime < CD_FriendCtlRequest then
      print("-->>添加请求过于频繁")
      return
    end
    netsend.netfriends.addFriend(pid)
    self.m_TimeRecord[pid] = curTime
  end
end
function CFriendsMgr:send_deleteFriend(pid)
  if g_MapMgr:IsInBangPaiWarMap() then
    ShowNotifyTips("帮战地图无法使用此功能")
    return false
  end
  if self:isLocalPlayerFriend(pid) then
    local curTime = g_DataMgr:getServerTime()
    local lastTime = self.m_TimeRecord[pid] or 0
    if curTime - lastTime < CD_FriendCtlRequest then
      print("-->>添加请求过于频繁")
      return
    end
    netsend.netfriends.deleteFriend(pid)
    self.m_TimeRecord[pid] = curTime
  end
end
function CFriendsMgr:send_queryPlayerInfo(pid)
  if g_MapMgr:IsInBangPaiWarMap() then
    ShowNotifyTips("帮战地图无法使用此功能")
    return false
  end
  netsend.netfriends.queryPlayerInfo(pid)
end
function CFriendsMgr:send_onFriendListOpen()
  netsend.netfriends.onFriendListOpen()
end
function CFriendsMgr:send_agreeFriendRequest(pid)
  if g_MapMgr:IsInBangPaiWarMap() then
    ShowNotifyTips("帮战地图无法使用此功能")
    return false
  end
  local curTime = g_DataMgr:getServerTime()
  local lastTime = self.m_TimeRecord[pid] or 0
  if curTime - lastTime < CD_FriendCtlRequest then
    print("-->>添加请求过于频繁")
    return
  end
  netsend.netfriends.agreeFriendRequest(pid)
  self.m_TimeRecord[pid] = curTime
end
function CFriendsMgr:send_refuseFriendRequest(pid)
  if g_MapMgr:IsInBangPaiWarMap() then
    ShowNotifyTips("帮战地图无法使用此功能")
    return false
  end
  local curTime = g_DataMgr:getServerTime()
  local lastTime = self.m_TimeRecord[pid] or 0
  if curTime - lastTime < CD_FriendCtlRequest then
    print("-->>添加请求过于频繁")
    return
  end
  netsend.netfriends.refuseFriendRequest(pid)
  self.m_TimeRecord[pid] = curTime
  self:deleteFriendRequest(pid)
end
function CFriendsMgr:setBanLvId(BanLvId)
  self.m_BanLvId = BanLvId
  SendMessage(MsgID_Friends_FlushBanLv, self.m_BanLvId)
end
function CFriendsMgr:getBanLvId()
  return self.m_BanLvId
end
function CFriendsMgr:getIsBanLv(pid)
  local fInfo = self.m_FriendsInfo[pid]
  if fInfo == nil then
    return false
  end
  if g_LocalPlayer == nil then
    return false
  end
  if self.m_BanLvId ~= pid then
    return false
  else
    local myType = g_LocalPlayer:getObjProperty(1, PROPERTY_SHAPE)
    if data_getRoleGender(fInfo.rtype) ~= data_getRoleGender(myType) then
      return true
    else
      return false
    end
  end
end
function CFriendsMgr:getIsJiYou(pid)
  local fInfo = self.m_FriendsInfo[pid]
  if fInfo == nil then
    return false
  end
  if g_LocalPlayer == nil then
    return false
  end
  if self.m_BanLvId ~= pid then
    return false
  else
    local myType = g_LocalPlayer:getObjProperty(1, PROPERTY_SHAPE)
    if data_getRoleGender(fInfo.rtype) == data_getRoleGender(myType) then
      return true
    else
      return false
    end
  end
end
function CFriendsMgr:getBanlvInfo()
  if self.m_BanLvId == nil then
    return 0, nil
  end
  local fInfo = self.m_FriendsInfo[self.m_BanLvId]
  if fInfo == nil then
    return 0, nil
  end
  if g_LocalPlayer == nil then
    return 0, nil
  end
  local myType = g_LocalPlayer:getObjProperty(1, PROPERTY_SHAPE)
  if data_getRoleGender(fInfo.rtype) == data_getRoleGender(myType) then
    return 2, self.m_BanLvId
  else
    return 1, self.m_BanLvId
  end
end
function CFriendsMgr:getFriendValue(pid)
  local fInfo = self.m_FriendsInfo[pid]
  if fInfo == nil then
    return nil
  end
  return fInfo.fValue or 0
end
function CFriendsMgr:getFriendName(pid)
  local fInfo = self.m_FriendsInfo[pid]
  if fInfo == nil then
    return nil
  end
  return fInfo.name
end
function CFriendsMgr:Clear()
end
g_FriendsMgr = CFriendsMgr.new()
gamereset.registerResetFunc(function()
  if g_FriendsMgr then
    g_FriendsMgr:Clear()
    g_FriendsMgr = nil
  end
  g_FriendsMgr = CFriendsMgr.new()
end)
