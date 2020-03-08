local CPointRaceReady = class("CPointRaceReady")
CPointRaceReady.TYPEID = 12617010
function CPointRaceReady:ctor(activity_cfgid, index)
  self.id = 12617010
  self.activity_cfgid = activity_cfgid or nil
  self.index = index or nil
end
function CPointRaceReady:marshal(os)
  os:marshalInt32(self.activity_cfgid)
  os:marshalInt32(self.index)
end
function CPointRaceReady:unmarshal(os)
  self.activity_cfgid = os:unmarshalInt32()
  self.index = os:unmarshalInt32()
end
function CPointRaceReady:sizepolicy(size)
  return size <= 65535
end
return CPointRaceReady
