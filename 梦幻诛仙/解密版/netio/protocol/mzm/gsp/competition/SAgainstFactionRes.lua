local SAgainstFactionRes = class("SAgainstFactionRes")
SAgainstFactionRes.TYPEID = 12598543
function SAgainstFactionRes:ctor(faction_id, faction_name)
  self.id = 12598543
  self.faction_id = faction_id or nil
  self.faction_name = faction_name or nil
end
function SAgainstFactionRes:marshal(os)
  os:marshalInt64(self.faction_id)
  os:marshalString(self.faction_name)
end
function SAgainstFactionRes:unmarshal(os)
  self.faction_id = os:unmarshalInt64()
  self.faction_name = os:unmarshalString()
end
function SAgainstFactionRes:sizepolicy(size)
  return size <= 65535
end
return SAgainstFactionRes
