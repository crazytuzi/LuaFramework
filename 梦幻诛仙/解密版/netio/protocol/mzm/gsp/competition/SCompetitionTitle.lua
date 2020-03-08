local SCompetitionTitle = class("SCompetitionTitle")
SCompetitionTitle.TYPEID = 12598536
function SCompetitionTitle:ctor(faction_id, faction_name, faction_duty, display_type)
  self.id = 12598536
  self.faction_id = faction_id or nil
  self.faction_name = faction_name or nil
  self.faction_duty = faction_duty or nil
  self.display_type = display_type or nil
end
function SCompetitionTitle:marshal(os)
  os:marshalInt64(self.faction_id)
  os:marshalString(self.faction_name)
  os:marshalInt32(self.faction_duty)
  os:marshalInt32(self.display_type)
end
function SCompetitionTitle:unmarshal(os)
  self.faction_id = os:unmarshalInt64()
  self.faction_name = os:unmarshalString()
  self.faction_duty = os:unmarshalInt32()
  self.display_type = os:unmarshalInt32()
end
function SCompetitionTitle:sizepolicy(size)
  return size <= 65535
end
return SCompetitionTitle
