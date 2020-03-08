local SCrossCompeteTitle = class("SCrossCompeteTitle")
SCrossCompeteTitle.TYPEID = 12616741
function SCrossCompeteTitle:ctor(faction_id, faction_name, faction_duty, designed_titleid)
  self.id = 12616741
  self.faction_id = faction_id or nil
  self.faction_name = faction_name or nil
  self.faction_duty = faction_duty or nil
  self.designed_titleid = designed_titleid or nil
end
function SCrossCompeteTitle:marshal(os)
  os:marshalInt64(self.faction_id)
  os:marshalString(self.faction_name)
  os:marshalInt32(self.faction_duty)
  os:marshalInt32(self.designed_titleid)
end
function SCrossCompeteTitle:unmarshal(os)
  self.faction_id = os:unmarshalInt64()
  self.faction_name = os:unmarshalString()
  self.faction_duty = os:unmarshalInt32()
  self.designed_titleid = os:unmarshalInt32()
end
function SCrossCompeteTitle:sizepolicy(size)
  return size <= 65535
end
return SCrossCompeteTitle
