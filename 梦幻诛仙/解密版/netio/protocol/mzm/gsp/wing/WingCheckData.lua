local OctetsStream = require("netio.OctetsStream")
local WingCheckData = class("WingCheckData")
function WingCheckData:ctor(cfgId, colorId, proIds, skills)
  self.cfgId = cfgId or nil
  self.colorId = colorId or nil
  self.proIds = proIds or {}
  self.skills = skills or {}
end
function WingCheckData:marshal(os)
  os:marshalInt32(self.cfgId)
  os:marshalInt32(self.colorId)
  os:marshalCompactUInt32(table.getn(self.proIds))
  for _, v in ipairs(self.proIds) do
    os:marshalInt32(v)
  end
  os:marshalCompactUInt32(table.getn(self.skills))
  for _, v in ipairs(self.skills) do
    os:marshalInt32(v)
  end
end
function WingCheckData:unmarshal(os)
  self.cfgId = os:unmarshalInt32()
  self.colorId = os:unmarshalInt32()
  for _size_ = os:unmarshalCompactUInt32(), 1, -1 do
    local v = os:unmarshalInt32()
    table.insert(self.proIds, v)
  end
  for _size_ = os:unmarshalCompactUInt32(), 1, -1 do
    local v = os:unmarshalInt32()
    table.insert(self.skills, v)
  end
end
return WingCheckData
