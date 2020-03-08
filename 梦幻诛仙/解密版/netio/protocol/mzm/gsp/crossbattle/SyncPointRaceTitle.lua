local SyncPointRaceTitle = class("SyncPointRaceTitle")
SyncPointRaceTitle.TYPEID = 12617069
function SyncPointRaceTitle:ctor(corps_id, corps_name, corps_duty, corps_badge_id)
  self.id = 12617069
  self.corps_id = corps_id or nil
  self.corps_name = corps_name or nil
  self.corps_duty = corps_duty or nil
  self.corps_badge_id = corps_badge_id or nil
end
function SyncPointRaceTitle:marshal(os)
  os:marshalInt64(self.corps_id)
  os:marshalOctets(self.corps_name)
  os:marshalInt32(self.corps_duty)
  os:marshalInt32(self.corps_badge_id)
end
function SyncPointRaceTitle:unmarshal(os)
  self.corps_id = os:unmarshalInt64()
  self.corps_name = os:unmarshalOctets()
  self.corps_duty = os:unmarshalInt32()
  self.corps_badge_id = os:unmarshalInt32()
end
function SyncPointRaceTitle:sizepolicy(size)
  return size <= 65535
end
return SyncPointRaceTitle
