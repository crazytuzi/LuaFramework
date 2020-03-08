local SyncPointRaceEnd = class("SyncPointRaceEnd")
SyncPointRaceEnd.TYPEID = 12617050
function SyncPointRaceEnd:ctor(activity_cfgid)
  self.id = 12617050
  self.activity_cfgid = activity_cfgid or nil
end
function SyncPointRaceEnd:marshal(os)
  os:marshalInt32(self.activity_cfgid)
end
function SyncPointRaceEnd:unmarshal(os)
  self.activity_cfgid = os:unmarshalInt32()
end
function SyncPointRaceEnd:sizepolicy(size)
  return size <= 65535
end
return SyncPointRaceEnd
