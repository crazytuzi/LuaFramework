local OctetsStream = require("netio.OctetsStream")
local CorpsBriefInfo = class("CorpsBriefInfo")
function CorpsBriefInfo:ctor(corpsId, name, corpsBadgeId, average_fight_value)
  self.corpsId = corpsId or nil
  self.name = name or nil
  self.corpsBadgeId = corpsBadgeId or nil
  self.average_fight_value = average_fight_value or nil
end
function CorpsBriefInfo:marshal(os)
  os:marshalInt64(self.corpsId)
  os:marshalOctets(self.name)
  os:marshalInt32(self.corpsBadgeId)
  os:marshalFloat(self.average_fight_value)
end
function CorpsBriefInfo:unmarshal(os)
  self.corpsId = os:unmarshalInt64()
  self.name = os:unmarshalOctets()
  self.corpsBadgeId = os:unmarshalInt32()
  self.average_fight_value = os:unmarshalFloat()
end
return CorpsBriefInfo
