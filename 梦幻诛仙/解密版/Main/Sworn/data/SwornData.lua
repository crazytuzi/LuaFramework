local Lplus = require("Lplus")
local SwornData = Lplus.Class("SwornData")
local def = SwornData.define
def.field("table").m_ConstTable = function()
  return {}
end
def.field("table").m_SwornName = function()
  return {}
end
def.field("table").m_SwornMember = function()
  return {}
end
def.field("userdata").m_FakeSwornID = nil
def.field("userdata").m_SwornID = nil
def.field("table").m_FakeSwornMember = function()
  return {}
end
local instance
def.static("=>", SwornData).Instance = function()
  if not instance then
    instance = SwornData()
  end
  return instance
end
def.static().ClearSwornData = function()
  instance.m_ConstTable = {}
  instance.m_SwornName = {}
  instance.m_SwornMember = {}
  instance.m_FakeSwornID = nil
  instance.m_SwornID = nil
  instance:ClearFakeSwornMember()
end
def.method().ClearFakeSwornMember = function(self)
  self.m_FakeSwornMember = {}
end
def.method("userdata").SetFakeSwornID = function(self, fakeSwornID)
  self.m_FakeSwornID = fakeSwornID
end
def.method("table").SetFakeSwornMember = function(self, SwornMembers)
  self.m_FakeSwornMember = SwornMembers
end
def.method("=>", "table").GetFakeSwornMember = function(self)
  return self.m_FakeSwornMember
end
def.method("=>", "userdata").GetFakeSwornID = function(self)
  return self.m_FakeSwornID
end
def.method("userdata").SetSwornID = function(self, swornID)
  self.m_SwornID = swornID
end
def.method("=>", "userdata").GetSwornID = function(self)
  return self.m_SwornID
end
def.method("table").SetSWornData = function(self, swornInfo)
  self:SetSwornName(swornInfo.name1, swornInfo.name2)
  self:SetSwornMember(swornInfo.members)
  warn("SetSWornData......", swornInfo.name1, swornInfo.name2, #swornInfo.members)
end
def.method("string", "string").SetSwornName = function(self, name1, name2)
  self.m_SwornName.name1 = name1
  self.m_SwornName.name2 = name2
end
def.method("=>", "table").GetSwornName = function(self)
  return self.m_SwornName
end
def.method("table").SetSwornMember = function(self, memberInfo)
  self.m_SwornMember = memberInfo
end
def.method("=>", "table").GetSwornMember = function(self)
  return self.m_SwornMember
end
def.method("table").AddSwornMember = function(self, memberInfo)
  table.insert(self.m_SwornMember, memberInfo)
end
def.method("userdata").DeleteMember = function(self, roleid)
  for k, v in pairs(self.m_SwornMember) do
    if v.roleid == roleid then
      self.m_SwornMember[k] = nil
      break
    end
  end
end
def.method("string", "userdata").ChangeMemberTitle = function(self, newTitle, roleid)
  for k, v in pairs(self.m_SwornMember) do
    if v.roleid == roleid then
      v.title = newTitle
      break
    end
  end
end
def.method("userdata", "=>", "boolean").IsSwornMember = function(self, roleid)
  for k, v in pairs(self.m_SwornMember) do
    if v.roleid == roleid then
      return true
    end
  end
  return false
end
def.method("userdata", "=>", "table").GetSwornMemberInfo = function(self, roleid)
  for k, v in pairs(self.m_SwornMember) do
    if v.roleid == roleid then
      return v
    end
  end
  return nil
end
def.static("string", "=>", "number").GetSwornConst = function(key)
  if instance.m_ConstTable[key] then
    return instance.m_ConstTable[key]
  end
  local record = DynamicData.GetRecord(CFG_PATH.DATA_SWORN_CONST, key)
  if not record then
    warn("GetSwornConst(" .. key .. ") return nil")
    return 0
  end
  local value = DynamicRecord.GetIntValue(record, "value")
  instance.m_ConstTable[key] = value
  return value
end
SwornData.Commit()
return SwornData
