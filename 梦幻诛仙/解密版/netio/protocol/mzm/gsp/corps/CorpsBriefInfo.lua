local OctetsStream = require("netio.OctetsStream")
local CorpsBriefInfo = class("CorpsBriefInfo")
function CorpsBriefInfo:ctor(corpsId, name, declaration, corpsBadgeId, createTime)
  self.corpsId = corpsId or nil
  self.name = name or nil
  self.declaration = declaration or nil
  self.corpsBadgeId = corpsBadgeId or nil
  self.createTime = createTime or nil
end
function CorpsBriefInfo:marshal(os)
  os:marshalInt64(self.corpsId)
  os:marshalOctets(self.name)
  os:marshalOctets(self.declaration)
  os:marshalInt32(self.corpsBadgeId)
  os:marshalInt32(self.createTime)
end
function CorpsBriefInfo:unmarshal(os)
  self.corpsId = os:unmarshalInt64()
  self.name = os:unmarshalOctets()
  self.declaration = os:unmarshalOctets()
  self.corpsBadgeId = os:unmarshalInt32()
  self.createTime = os:unmarshalInt32()
end
return CorpsBriefInfo
