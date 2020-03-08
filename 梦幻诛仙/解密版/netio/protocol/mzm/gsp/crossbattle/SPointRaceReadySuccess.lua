local SPointRaceReadySuccess = class("SPointRaceReadySuccess")
SPointRaceReadySuccess.TYPEID = 12617009
function SPointRaceReadySuccess:ctor(activity_cfgid, index)
  self.id = 12617009
  self.activity_cfgid = activity_cfgid or nil
  self.index = index or nil
end
function SPointRaceReadySuccess:marshal(os)
  os:marshalInt32(self.activity_cfgid)
  os:marshalInt32(self.index)
end
function SPointRaceReadySuccess:unmarshal(os)
  self.activity_cfgid = os:unmarshalInt32()
  self.index = os:unmarshalInt32()
end
function SPointRaceReadySuccess:sizepolicy(size)
  return size <= 65535
end
return SPointRaceReadySuccess
