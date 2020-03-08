local Lplus = require("Lplus")
local MathHelper = require("Common.MathHelper")
local GroupInfo = require("netio.protocol.mzm.gsp.group.GroupInfo")
local GroupMemberInfo = require("netio.protocol.mzm.gsp.group.GroupMemberInfo")
local GroupData = Lplus.Class("GroupData")
local def = GroupData.define
def.field("table").m_GroupList = nil
def.field("boolean").m_IsInited = false
def.field("table").m_ShiledStateList = nil
local instance
def.static("=>", GroupData).Instance = function()
  if nil == instance then
    instance = GroupData()
    instance.m_GroupList = {}
    instance.m_ShiledStateList = {}
    instance.m_IsInited = false
  end
  return instance
end
def.method("table", "boolean", "=>", "table").GenerateGroup = function(self, groupInfo, isInited)
  if nil == groupInfo then
    return nil
  end
  local group = {}
  group.basicInfo = {}
  group.memberInfo = {}
  local basicInfo = group.basicInfo
  basicInfo.groupId = groupInfo.groupid
  basicInfo.groupName = GetStringFromOcts(groupInfo.group_name)
  basicInfo.groupType = groupInfo.group_type
  basicInfo.masterId = groupInfo.masterid
  basicInfo.memberNum = groupInfo.member_num
  basicInfo.createTime = groupInfo.create_time
  basicInfo.announcement = GetStringFromOcts(groupInfo.announcement) or ""
  basicInfo.groupVersion = groupInfo.info_version
  basicInfo.isInited = isInited
  basicInfo.groupHeadIcons = {}
  if groupInfo.image_member_list then
    for k, v in pairs(groupInfo.image_member_list) do
      local headInfo = {}
      headInfo.occupation = v.menpai
      headInfo.gender = v.gender
      headInfo.avatarId = v.avatarid
      table.insert(basicInfo.groupHeadIcons, headInfo)
    end
  end
  local memberList = groupInfo.member_list
  if isInited and memberList then
    table.sort(memberList, function(a, b)
      return a.join_time < b.join_time
    end)
    for k, v in pairs(memberList) do
      local member = {}
      member.roleId = v.roleid
      member.roleName = GetStringFromOcts(v.name)
      member.roleLevel = v.level
      member.occupation = v.menpai
      member.gender = v.gender
      member.avatarId = v.avatarid
      member.avatarFrameId = v.avatar_frame_id
      member.onlineStatus = v.online_state
      member.joinTime = v.join_time
      table.insert(group.memberInfo, member)
    end
  end
  return group
end
def.method("table", "=>", "boolean").SetBasicGroup = function(self, groups)
  if nil == groups then
    return false
  end
  if nil == self.m_GroupList then
    self.m_GroupList = {}
  end
  for k, v in pairs(groups) do
    local group = self:GenerateGroup(v, false)
    if group then
      local groupKey = v.groupid:tostring()
      self.m_GroupList[groupKey] = group
    end
  end
  self.m_IsInited = true
  return true
end
def.method("table", "=>", "boolean").SetSingleGroup = function(self, groupInfo)
  if nil == groupInfo then
    return false
  end
  if nil == self.m_GroupList or 0 == MathHelper.CountTable(self.m_GroupList) then
    warn("grouplist is nil or empty ~~~~~~~~~")
    return false
  end
  local groupKey = groupInfo.groupid:tostring()
  if not self.m_GroupList[groupKey] then
    warn("the group basic info is nil ~~~~~", groupKey)
    return false
  end
  local group = self:GenerateGroup(groupInfo, true)
  if group then
    self.m_GroupList[groupKey] = group
    self:UpdateGroupHeadIconInfo(groupInfo.groupid)
    return true
  else
    return false
  end
end
def.method("table", "boolean", "=>", "boolean").AddGroup = function(self, groupInfo, isAllInfo)
  if nil == groupInfo then
    return false
  end
  if nil == self.m_GroupList then
    self.m_GroupList = {}
  end
  local groupKey = groupInfo.groupid:tostring()
  local group = self:GenerateGroup(groupInfo, isAllInfo)
  if group then
    self.m_GroupList[groupKey] = group
    return true
  else
    return false
  end
end
def.method("userdata", "=>", "boolean").RemoveGroup = function(self, groupId)
  if nil == groupId then
    return false
  end
  if nil == self.m_GroupList then
    return false
  end
  local groupKey = groupId:tostring()
  if nil == self.m_GroupList[groupKey] then
    return false
  end
  self.m_GroupList[groupKey] = nil
  return true
end
def.method("string", "=>", "boolean").ClearRemovedGroup = function(self, key)
  if nil == key then
    return false
  end
  if nil == self.m_GroupList then
    return false
  end
  local index = 0
  local isFind = false
  for k, v in pairs(self.m_GroupList) do
    index = index + 1
    if k == key then
      isFind = true
      break
    end
  end
  if isFind then
    table.remove(self.m_GroupList, index)
    return true
  else
    return false
  end
end
def.method("userdata", "string", "userdata").ChangeGroupName = function(self, groupId, newName, version)
  if nil == groupId then
    return
  end
  if nil == self.m_GroupList then
    return
  end
  local groupKey = groupId:tostring()
  if nil == self.m_GroupList[groupKey] then
    return
  end
  local basicInfo = self.m_GroupList[groupKey].basicInfo
  basicInfo.groupName = newName
  basicInfo.groupVersion = version
end
def.method("userdata", "string", "userdata").ChangeGroupAnnounceMent = function(self, groupId, newAnnounceMent, version)
  if nil == groupId then
    return
  end
  if nil == self.m_GroupList then
    return
  end
  local groupKey = groupId:tostring()
  if nil == self.m_GroupList[groupKey] then
    return
  end
  local basicInfo = self.m_GroupList[groupKey].basicInfo
  basicInfo.announcement = newAnnounceMent
  basicInfo.groupVersion = version
end
def.method("userdata", "table", "userdata").AddGroupMember = function(self, groupId, memberInfo, version)
  if nil == groupId or nil == memberInfo then
    return
  end
  if nil == self.m_GroupList then
    return
  end
  local groupKey = groupId:tostring()
  if nil == self.m_GroupList[groupKey] then
    return
  end
  local basicInfo = self.m_GroupList[groupKey].basicInfo
  basicInfo.memberNum = basicInfo.memberNum + 1
  basicInfo.groupVersion = version
  local memberList = self.m_GroupList[groupKey].memberInfo
  local member = {}
  member.roleId = memberInfo.roleid
  member.roleName = GetStringFromOcts(memberInfo.name)
  member.roleLevel = memberInfo.level
  member.occupation = memberInfo.menpai
  member.gender = memberInfo.gender
  member.avatarId = memberInfo.avatarid
  member.avatarFrameId = memberInfo.avatar_frame_id
  member.onlineStatus = memberInfo.online_state
  member.joinTime = memberInfo.join_time
  table.insert(memberList, member)
  self:UpdateGroupHeadIconInfo(groupId)
end
def.method("userdata", "userdata", "userdata").RemoveGroupMember = function(self, groupId, memberId, version)
  if nil == groupId or nil == memberId then
    return
  end
  if nil == self.m_GroupList then
    return
  end
  local groupKey = groupId:tostring()
  if nil == self.m_GroupList[groupKey] then
    return
  end
  local basicInfo = self.m_GroupList[groupKey].basicInfo
  local memberInfo = self.m_GroupList[groupKey].memberInfo
  basicInfo.groupVersion = version
  basicInfo.memberNum = basicInfo.memberNum - 1
  local index = -1
  for k, v in pairs(memberInfo) do
    if v.roleId:eq(memberId) then
      index = k
      break
    end
  end
  if index > 0 then
    table.remove(memberInfo, index)
  end
  self:UpdateGroupHeadIconInfo(groupId)
end
def.method("userdata").UpdateGroupHeadIconInfo = function(self, groupId)
  if nil == groupId then
    return
  end
  if nil == self.m_GroupList then
    return
  end
  local groupKey = groupId:tostring()
  if nil == self.m_GroupList[groupKey] then
    return
  end
  local basicInfo = self.m_GroupList[groupKey].basicInfo
  if not basicInfo.isInited then
    return
  end
  local groupHeadIcons = {}
  local memberList = self.m_GroupList[groupKey].memberInfo
  for k, v in pairs(memberList) do
    local headInfo = {}
    headInfo.occupation = v.occupation
    headInfo.gender = v.gender
    headInfo.avatarId = v.avatarId
    table.insert(groupHeadIcons, headInfo)
  end
  self.m_GroupList[groupKey].basicInfo.groupHeadIcons = groupHeadIcons
end
def.method("table").SetGroupMessageStates = function(self, states)
  if nil == states then
    return
  end
  self.m_ShiledStateList = {}
  for k, v in pairs(states) do
    self.m_ShiledStateList[k:tostring()] = v
  end
end
def.method("userdata", "number").ChangeGroupMessageState = function(self, groupId, state)
  if nil == groupId then
    return
  end
  if nil == self.m_ShiledStateList then
    self.m_ShiledStateList = {}
  end
  local groupKey = groupId:tostring()
  self.m_ShiledStateList[groupKey] = state
end
def.method("userdata", "userdata", "string", "userdata").ChangeMemberName = function(self, groupId, memberId, newName, version)
  if nil == groupId or nil == memberId then
    return
  end
  if nil == self.m_GroupList then
    return
  end
  local groupKey = groupId:tostring()
  if nil == self.m_GroupList[groupKey] then
    return
  end
  self.m_GroupList[groupKey].basicInfo.groupVersion = version
  local memberList = self.m_GroupList[groupKey].memberInfo
  for k, v in pairs(memberList) do
    if v.roleId:eq(memberId) then
      v.roleName = newName
      break
    end
  end
end
def.method("userdata", "userdata", "number", "userdata").ChangeMemberLevel = function(self, groupId, memberId, newLevel, version)
  if nil == groupId or nil == memberId then
    return
  end
  if nil == self.m_GroupList then
    return
  end
  local groupKey = groupId:tostring()
  if nil == self.m_GroupList[groupKey] then
    return
  end
  self.m_GroupList[groupKey].basicInfo.groupVersion = version
  local memberList = self.m_GroupList[groupKey].memberInfo
  for k, v in pairs(memberList) do
    if v.roleId:eq(memberId) then
      v.roleLevel = newLevel
      break
    end
  end
end
def.method("userdata", "userdata", "number", "userdata").ChangeMemberOnlineState = function(self, groupId, memberId, state, version)
  if nil == groupId or nil == memberId then
    return
  end
  if nil == self.m_GroupList then
    return
  end
  local groupKey = groupId:tostring()
  if nil == self.m_GroupList[groupKey] then
    return
  end
  self.m_GroupList[groupKey].basicInfo.groupVersion = version
  local memberList = self.m_GroupList[groupKey].memberInfo
  for k, v in pairs(memberList) do
    if v.roleId:eq(memberId) then
      v.onlineStatus = state
      break
    end
  end
end
def.method().Clear = function(self)
  self.m_GroupList = {}
  self.m_IsInited = false
  self.m_ShiledStateList = {}
end
def.method("=>", "table").GetAllGroupInfo = function(self)
  return self.m_GroupList
end
def.method("=>", "table").GetAllGroupBasicInfo = function(self)
  if nil == self.m_GroupList then
    return nil
  end
  local basicGroupList = {}
  for k, v in pairs(self.m_GroupList) do
    table.insert(basicGroupList, v.basicInfo)
  end
  return basicGroupList
end
def.method("string", "=>", "table").GetGroupHeadIconInfo = function(self, groupKey)
  if nil == self.m_GroupList then
    return nil
  end
  if nil == self.m_GroupList[groupKey] then
    return nil
  end
  return self.m_GroupList[groupKey].basicInfo.groupHeadIcons
end
def.method("userdata", "=>", "table").GetGroupBasicInfo = function(self, groupId)
  if nil == groupId then
    return nil
  end
  local groupKey = groupId:tostring()
  if nil == self.m_GroupList[groupKey] then
    return nil
  end
  return self.m_GroupList[groupKey].basicInfo
end
def.method("=>", "number").GetMyGroupNum = function(self)
  if nil == self.m_GroupList then
    return 0
  end
  return MathHelper.CountTable(self.m_GroupList)
end
def.method("string", "=>", "number").GetGroupMemberNum = function(self, groupKey)
  if nil == groupKey then
    return 0
  end
  if nil == self.m_GroupList then
    return 0
  end
  if nil == self.m_GroupList[groupKey] then
    return 0
  end
  local memberList = self.m_GroupList[groupKey].memberInfo
  return memberList and MathHelper.CountTable(memberList) or 0
end
def.method("string", "=>", "table").GetGroupMembers = function(self, groupKey)
  if nil == groupKey then
    return nil
  end
  if nil == self.m_GroupList or nil == self.m_GroupList[groupKey] then
    return nil
  end
  return self.m_GroupList[groupKey].memberInfo
end
def.method("=>", "number").GetMyCreateGroupNum = function(self)
  if nil == self.m_GroupList then
    return 0
  end
  local count = 0
  local myRoleId = GetMyRoleID()
  for k, v in pairs(self.m_GroupList) do
    local groupMasterId = self:GetGroupMasterRoleId(k)
    if myRoleId:eq(groupMasterId) then
      count = count + 1
    end
  end
  return count
end
def.method("string", "=>", "userdata").GetGroupMasterRoleId = function(self, groupKey)
  if nil == groupKey then
    return nil
  end
  if nil == self.m_GroupList or nil == self.m_GroupList[groupKey] then
    return nil
  end
  return self.m_GroupList[groupKey].basicInfo.masterId
end
def.method("userdata", "userdata", "=>", "table").GetGroupMemberByRoleId = function(self, groupId, memberId)
  if nil == groupId or nil == memberId then
    return nil
  end
  if nil == self.m_GroupList then
    return nil
  end
  local groupKey = groupId:tostring()
  if nil == self.m_GroupList[groupKey] then
    return nil
  end
  local memberList = self.m_GroupList[groupKey].memberInfo
  warn("member list is : ", memberList, #memberList)
  for k, v in pairs(memberList) do
    warn("the roleId is ~~~~ ", v.roleId)
    if v.roleId:eq(memberId) then
      return v
    end
  end
  return nil
end
def.method("string", "=>", "boolean").IsGroupMaster = function(self, groupKey)
  local masterRoleId = self:GetGroupMasterRoleId(groupKey)
  if nil == masterRoleId then
    return false
  end
  local myRoleId = GetMyRoleID()
  if myRoleId then
    if myRoleId:eq(masterRoleId) then
      return true
    else
      return false
    end
  else
    return false
  end
end
def.method("=>", "boolean").IsInitedBasicAllGroup = function(self)
  return self.m_IsInited
end
def.method("userdata", "=>", "boolean").IsGroupExist = function(self, groupId)
  if nil == groupId then
    return false
  end
  if nil == self.m_GroupList then
    return false
  end
  local groupKey = groupId:tostring()
  if self.m_GroupList[groupKey] then
    return true
  else
    return false
  end
end
def.method("userdata", "=>", "boolean").GetMessageShildState = function(self, groupId)
  if nil == groupId then
    return false
  end
  if nil == self.m_ShiledStateList then
    return false
  end
  local groupKey = groupId:tostring()
  if nil == self.m_ShiledStateList[groupKey] then
    return false
  end
  return self.m_ShiledStateList[groupKey] == GroupMemberInfo.MSG_STATE_REFUSE
end
def.method().printBasicGroups = function(self)
  warn("================== group basic begin =====================")
  warn("================== groupdata is inited : ", self.m_IsInited)
  warn("================== allGroupCount is : ", MathHelper.CountTable(self.m_GroupList))
  for k, v in pairs(self.m_GroupList) do
    warn("==========================", k, " , ", v)
  end
  warn("================== shieldListCount is : ", MathHelper.CountTable(self.m_ShiledStateList))
  warn("")
  for k, v in pairs(self.m_ShiledStateList) do
    warn("========================== ", k, " , ", v)
  end
  warn("================== group basic end =====================")
end
def.method("userdata").printGroupDetail = function(self, groupId)
  if nil == groupId then
    warn("***************groupid is nil *************************")
  end
  local groupKey = groupId:tostring()
  local group = self.m_GroupList[groupKey]
  if nil == group then
    warn("***************group detail info is nil ********** ", groupKey)
  end
  warn("********************group detail begin************************")
  warn("****** groupKey is : ", groupKey)
  warn("****** basic info and member info is : ", group.basicInfo, " , ", group.memberInfo)
  warn("****** group name is : ", group.basicInfo.groupName, group.basicInfo.isInited)
  warn("****** group member count is : ", MathHelper.CountTable(group.memberInfo))
  for k, v in pairs(group.memberInfo) do
    warn("***************** member info is : ", v.roleName)
  end
  warn("********************group detail end**************************")
end
GroupData.Commit()
return GroupData
