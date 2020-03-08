local Lplus = require("Lplus")
local CorpsData = Lplus.Class("CorpsData")
local CorpsDuty = require("consts.mzm.gsp.corps.confbean.CorpsDuty")
local def = CorpsData.define
def.field("userdata").corpsId = nil
def.field("string").name = ""
def.field("string").declaration = ""
def.field("number").badgeId = 0
def.field("number").createTime = 0
def.field("table").members = nil
def.static("table", "=>", CorpsData).Create = function(bean)
  local data = CorpsData()
  data:SetCorpsId(bean.corpsBriefInfo.corpsId)
  data:SetName(GetStringFromOcts(bean.corpsBriefInfo.name))
  data:SetDeclaration(GetStringFromOcts(bean.corpsBriefInfo.declaration))
  data:SetBadgeId(bean.corpsBriefInfo.corpsBadgeId)
  data:SetCreateTime(bean.corpsBriefInfo.createTime)
  for k, v in pairs(bean.members) do
    data:AddMember(v)
  end
  return data
end
def.method("userdata").SetCorpsId = function(self, corpsId)
  self.corpsId = corpsId
end
def.method("=>", "userdata").GetCorpsId = function(self)
  return self.corpsId
end
def.method("=>", "string").GetName = function(self)
  return self.name
end
def.method("string").SetName = function(self, name)
  self.name = name
end
def.method("string").SetDeclaration = function(self, declaration)
  self.declaration = declaration
end
def.method("=>", "string").GetDeclaration = function(self)
  return self.declaration
end
def.method("number").SetBadgeId = function(self, badgeId)
  self.badgeId = badgeId
end
def.method("=>", "number").GetBadgeId = function(self)
  return self.badgeId
end
def.method("=>", "number").GetCreateTime = function(self)
  return self.createTime
end
def.method("number").SetCreateTime = function(self, createTime)
  self.createTime = createTime
end
def.method("table").AddMember = function(self, bean)
  if self.members == nil then
    self.members = {}
  end
  self.members[bean.baseInfo.roleId:tostring()] = {
    roleId = bean.baseInfo.roleId,
    name = GetStringFromOcts(bean.baseInfo.name),
    level = bean.baseInfo.level,
    occupationId = bean.baseInfo.occupationId,
    gender = bean.baseInfo.gender,
    avatarId = bean.baseInfo.avatarId,
    avatarFrameId = bean.baseInfo.avatarFrameId,
    duty = bean.baseInfo.duty,
    joinTime = bean.baseInfo.joinTime,
    offlineTime = bean.baseInfo.offlineTime,
    mfv = bean.extroInfo.multiFightValue,
    model = bean.extroInfo.model
  }
end
def.method("userdata", "table").ChangeMemberBaseInfo = function(self, roleId, bean)
  if self.members then
    local member = self.members[roleId:tostring()]
    if member then
      member.roleId = bean.roleId
      member.name = GetStringFromOcts(bean.name)
      member.level = bean.level
      member.occupationId = bean.occupationId
      member.gender = bean.gender
      member.avatarId = bean.avatarId
      member.avatarFrameId = bean.avatarFrameId
      member.duty = bean.duty
      member.joinTime = bean.joinTime
      member.offlineTime = bean.offlineTime
    end
  end
end
def.method("userdata", "number").ChangeMemberMFV = function(self, roleId, mfv)
  if self.members then
    local member = self.members[roleId:tostring()]
    if member then
      member.mfv = mfv
    end
  end
end
def.method("userdata", "table").ChangeMemberModel = function(self, roleId, model)
  if self.members then
    local member = self.members[roleId:tostring()]
    if member then
      member.model = model
    end
  end
end
def.method("userdata").RemoveMember = function(self, roleId)
  if self.members then
    self.members[roleId:tostring()] = nil
  end
end
def.method("=>", "number").GetMemberCount = function(self)
  if self.members then
    local count = 0
    for k, v in pairs(self.members) do
      count = count + 1
    end
    return count
  else
    return 0
  end
end
def.method("=>", "table").GetMemberRoleIds = function(self)
  if self.members then
    local sorted = {}
    for k, v in pairs(self.members) do
      table.insert(sorted, Int64.new(k))
    end
    table.sort(sorted, function(a, b)
      return a < b
    end)
    return sorted
  else
    return nil
  end
end
def.method("=>", "table").GetAllMemberSorted = function(self)
  if self.members then
    local sorted = {}
    for k, v in pairs(self.members) do
      table.insert(sorted, v)
    end
    table.sort(sorted, function(a, b)
      if a.offlineTime <= 0 and b.offlineTime <= 0 then
        if a.duty < b.duty then
          return true
        end
        if a.duty > b.duty then
          return false
        end
        if a.duty == b.duty then
          return a.joinTime < b.joinTime
        end
      elseif a.offlineTime <= 0 and b.offlineTime > 0 then
        return true
      elseif a.offlineTime > 0 and b.offlineTime <= 0 then
        return false
      else
        if a.duty < b.duty then
          return true
        end
        if a.duty > b.duty then
          return false
        end
        if a.duty == b.duty then
          return a.joinTime < b.joinTime
        end
      end
    end)
    return sorted
  else
    return nil
  end
end
def.method("userdata", "=>", "table").GetMemberInfoByRoleId = function(self, roleId)
  if self.members then
    return self.members[roleId:tostring()]
  else
    return nil
  end
end
def.method("userdata", "=>", "boolean").IsLeader = function(self, roleId)
  if self.members then
    local member = self.members[roleId:tostring()]
    if member then
      return member.duty == CorpsDuty.CAPTAIN
    else
      return false
    end
  else
    return false
  end
end
def.method("=>", "table").GetLeaderInfo = function(self)
  if self.members then
    for k, v in pairs(self.members) do
      if v.duty == CorpsDuty.CAPTAIN then
        return v
      end
    end
    return nil
  end
end
def.method("userdata").ChangeLeader = function(self, leaderId)
  if self.members then
    for k, v in pairs(self.members) do
      if v.roleId == leaderId then
        v.duty = CorpsDuty.CAPTAIN
      else
        v.duty = CorpsDuty.MEMBER
      end
    end
  end
end
def.method("userdata", "number").SetMemberOnlineState = function(self, roleId, state)
  if self.members then
    local info = self.members[roleId:tostring()]
    if info then
      info.offlineTime = state
    end
  end
end
CorpsData.Commit()
return CorpsData
