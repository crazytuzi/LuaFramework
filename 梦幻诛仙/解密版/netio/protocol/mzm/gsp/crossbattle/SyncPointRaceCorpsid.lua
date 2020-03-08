local SyncPointRaceCorpsid = class("SyncPointRaceCorpsid")
SyncPointRaceCorpsid.TYPEID = 12617070
function SyncPointRaceCorpsid:ctor(corps_id)
  self.id = 12617070
  self.corps_id = corps_id or nil
end
function SyncPointRaceCorpsid:marshal(os)
  os:marshalInt64(self.corps_id)
end
function SyncPointRaceCorpsid:unmarshal(os)
  self.corps_id = os:unmarshalInt64()
end
function SyncPointRaceCorpsid:sizepolicy(size)
  return size <= 65535
end
return SyncPointRaceCorpsid
