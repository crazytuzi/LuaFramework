local Lplus = require("Lplus")
local ModuleBase = require("Main.module.ModuleBase")
local GroupModule = Lplus.Extend(ModuleBase, "GroupModule")
require("Main.module.ModuleId")
local GroupData = require("Main.Group.data.GroupData")
local GroupProtocolMgr = require("Main.Group.GroupProtocolMgr")
local GroupUtils = require("Main.Group.GroupUtils")
local SAVE_PATH = "newgroupinfos"
local SAVE_TABLE_NAME = "newgroups"
local def = GroupModule.define
def.field("table").m_NewJoinGroups = nil
def.field("userdata").m_roleIdBackUp = nil
def.field("table").m_basicInfoReqs = nil
local instance
def.static("=>", GroupModule).Instance = function()
  if nil == instance then
    instance = GroupModule()
    instance.m_moduleId = ModuleId.GROUP
    instance.m_NewJoinGroups = nil
    instance.m_roleIdBackUp = nil
  end
  return instance
end
def.override().Init = function(self)
  ModuleBase.Init(self)
  GroupProtocolMgr.Init()
  Event.RegisterEvent(ModuleId.LOGIN, gmodule.notifyId.Login.ENTER_WORLD, function()
    self:OnEnterWorld()
  end)
  Event.RegisterEvent(ModuleId.LOGIN, gmodule.notifyId.Login.LEAVE_WORLD, function()
    self:Reset()
  end)
  Event.RegisterEvent(ModuleId.GROUP, gmodule.notifyId.Group.Group_BasicInfo_Inited, GroupModule.OnGroupBasicInfoInited)
end
def.method().OnEnterWorld = function(self)
  self.m_roleIdBackUp = GetMyRoleID()
  self:LoadNewJoinGroup()
end
def.override().OnReset = function(self)
  self:SaveNewJoinGroup()
  self.m_NewJoinGroups = nil
  self.m_roleIdBackUp = nil
  self.m_basicInfoReqs = nil
  GroupData.Instance():Clear()
end
def.method().SaveNewJoinGroup = function(self)
  if nil == self.m_NewJoinGroups then
    return
  end
  local saveGroups = {}
  for k, v in pairs(self.m_NewJoinGroups) do
    local groupId = Int64.new(k)
    if self:IsGroupExist(groupId) and v then
      table.insert(saveGroups, k)
    end
  end
  local myRoleId = self.m_roleIdBackUp
  if myRoleId then
    local roleString = myRoleId:tostring()
    local configPath = string.format("%s/%s/%s.lua", Application.persistentDataPath, SAVE_PATH, roleString)
    GameUtil.CreateDirectoryForFile(configPath)
    require("Main.Common.LuaTableWriter").SaveTable(SAVE_TABLE_NAME, configPath, saveGroups)
  end
end
def.method().LoadNewJoinGroup = function(self)
  local myRoleId = GetMyRoleID()
  if nil == myRoleId then
    return
  end
  local roleIdString = myRoleId:tostring()
  local configPath = string.format("%s/%s/%s.lua", Application.persistentDataPath, SAVE_PATH, roleIdString)
  local chunk, errorMsg = loadfile(configPath)
  if chunk then
    local newgroups = chunk()
    if not newgroups then
      Debug.LogWarning("Load new group info fail\n", errorMsg, chunk)
      return
    end
    local hasNewGroup = false
    self.m_NewJoinGroups = {}
    for k, v in pairs(newgroups) do
      self.m_NewJoinGroups[v] = true
      hasNewGroup = true
    end
    if hasNewGroup then
      local FriendModule = require("Main.friend.FriendModule")
      Event.DispatchEvent(ModuleId.FRIEND, gmodule.notifyId.Friend.Friend_OnApplicantsChange, {
        FriendModule.Instance():GetAllFriendCount()
      })
    end
  end
end
def.method("userdata").AddNewJoinGroup = function(self, groupId)
  if nil == groupId then
    return
  end
  if nil == self.m_NewJoinGroups then
    self.m_NewJoinGroups = {}
  end
  self.m_NewJoinGroups[groupId:tostring()] = true
end
def.method("userdata").RemoveNewJoinGroup = function(self, groupId)
  if nil == groupId then
    return
  end
  if nil == self.m_NewJoinGroups then
    return
  end
  if self.m_NewJoinGroups[groupId:tostring()] then
    self.m_NewJoinGroups[groupId:tostring()] = nil
  end
end
def.method("=>", "number").GetNewJoinGroupNum = function(self)
  if nil == self.m_NewJoinGroups then
    return 0
  end
  local count = 0
  for k, v in pairs(self.m_NewJoinGroups) do
    count = count + 1
  end
  return count
end
def.method("userdata", "=>", "boolean").IsNewJoinGroup = function(self, groupId)
  if nil == groupId then
    return false
  end
  if nil == self.m_NewJoinGroups then
    return false
  end
  if self.m_NewJoinGroups[groupId:tostring()] then
    return true
  else
    return false
  end
end
def.method("userdata", "=>", "boolean").IsGroupExist = function(self, groupId)
  if nil == groupId then
    return false
  end
  return GroupData.Instance():IsGroupExist(groupId)
end
def.method("=>", "boolean").IsInitedBasicAllGroup = function(self)
  if IsCrossingServer() then
    return true
  end
  return GroupData.Instance():IsInitedBasicAllGroup()
end
def.method("=>", "table").GetBasicGroupList = function(self)
  return GroupData.Instance():GetAllGroupBasicInfo() or {}
end
def.method("=>", "table").GetSortedBasicGroupList = function(self)
  local groupList = self:GetBasicGroupList()
  table.sort(groupList, GroupModule.GroupSortFunc)
  return groupList
end
def.method("userdata", "=>", "table").GetGroupBasicInfo = function(self, groupId)
  if nil == groupId then
    return nil
  end
  local groupList = self:GetBasicGroupList()
  for k, v in pairs(groupList) do
    if groupId:eq(v.groupId) then
      return v
    end
  end
  return nil
end
def.method("userdata", "=>", "table").GetGroupHeadIconInfo = function(self, groupId)
  if nil == groupId then
    return {}
  end
  return GroupData.Instance():GetGroupHeadIconInfo(groupId:tostring()) or {}
end
def.method("userdata", "=>", "boolean").IsGroupMaster = function(self, groupId)
  if nil == groupId then
    return false
  end
  return GroupData.Instance():IsGroupMaster(groupId:tostring())
end
def.method("=>", "number").GetMyAllGroupNum = function(self)
  return GroupData.Instance():GetMyGroupNum()
end
def.method("=>", "number").GetMyCreateGroupNum = function(self)
  return GroupData.Instance():GetMyCreateGroupNum()
end
def.method("userdata", "=>", "table").GetGroupMemberList = function(self, groupId)
  if nil == groupId then
    return {}
  end
  local groupKey = groupId:tostring()
  return GroupData.Instance():GetGroupMembers(groupKey) or {}
end
def.method("userdata", "=>", "number").GetGroupMemberNum = function(self, groupId)
  if nil == groupId then
    return 0
  end
  local basicInfo = self:GetGroupBasicInfo(groupId)
  return basicInfo and basicInfo.memberNum or 0
end
def.method("userdata", "=>", "boolean").GetMessageShildState = function(self, groupId)
  return GroupData.Instance():GetMessageShildState(groupId)
end
def.method("userdata", "=>", "table").GetCanInviteFriendList = function(self, groupId)
  if nil == groupId then
    return nil
  end
  local allFriends = require("Main.friend.FriendData").Instance():GetFriendList()
  local groupMemberList = self:GetGroupMemberList(groupId)
  local function isAllReadyInGroup(inviteRoleId)
    for k, v in pairs(groupMemberList) do
      local memberRoleId = v.roleId
      if memberRoleId:eq(inviteRoleId) then
        return true
      end
    end
    return false
  end
  local canInviteList = {}
  for k, v in pairs(allFriends) do
    if require("netio.protocol.mzm.gsp.friend.FriendConsts").STATUS_ONLINE == v.onlineStatus then
      local friendRoleId = v.roleId
      local joinLevel = GroupUtils.GetGroupJoinLevel()
      if not isAllReadyInGroup(friendRoleId) and joinLevel <= v.roleLevel then
        table.insert(canInviteList, v)
      end
    end
  end
  table.sort(canInviteList, function(a, b)
    return a.relationValue > b.relationValue
  end)
  return canInviteList
end
def.method("function").LoadBasicGroupList = function(self, callback)
  if self:IsInitedBasicAllGroup() then
    local basicGroupInfoList = self:GetBasicGroupList()
    _G.SafeCallback(callback, basicGroupInfoList)
  else
    self.m_basicInfoReqs = self.m_basicInfoReqs or {}
    table.insert(self.m_basicInfoReqs, callback)
    GroupProtocolMgr.SetWaitForBasicInfo(true)
    GroupProtocolMgr.CGroupBasicInfoReq()
  end
end
def.static("table", "table").OnGroupBasicInfoInited = function(params, context)
  local self = instance
  if self.m_basicInfoReqs == nil then
    return
  end
  local basicGroupInfoList = self:GetBasicGroupList()
  for i, callback in ipairs(self.m_basicInfoReqs) do
    _G.SafeCall(callback, basicGroupInfoList)
  end
  self.m_basicInfoReqs = nil
end
def.static("table", "table", "=>", "boolean").GroupSortFunc = function(lhs, rhs)
  local ChatModule = require("Main.Chat.ChatModule")
  local groupId1 = lhs.groupId
  local groupId2 = rhs.groupId
  local newChatCount1 = ChatModule.Instance():GetGroupChatNewCount(groupId1) or 0
  local newChatCount2 = ChatModule.Instance():GetGroupChatNewCount(groupId2) or 0
  if 0 == newChatCount1 and newChatCount2 > 0 then
    return false
  elseif 0 == newChatCount2 and newChatCount1 > 0 then
    return true
  elseif 0 == newChatCount1 and 0 == newChatCount2 then
    return lhs.createTime > rhs.createTime
  else
    local newChat1 = ChatModule.Instance():GetGroupNewOne(lhs.groupId)
    local newChat2 = ChatModule.Instance():GetGroupNewOne(rhs.groupId)
    if newChat1 and newChat2 then
      local chattime1 = newChat1.time or 0
      local cahttime2 = newChat2.time or 0
      return chattime1 > cahttime2
    else
      return true
    end
  end
end
GroupModule.Commit()
return GroupModule
