local SFactionPVETimesBrd = class("SFactionPVETimesBrd")
SFactionPVETimesBrd.TYPEID = 12613637
function SFactionPVETimesBrd:ctor(activate_times, set_times)
  self.id = 12613637
  self.activate_times = activate_times or nil
  self.set_times = set_times or nil
end
function SFactionPVETimesBrd:marshal(os)
  os:marshalInt32(self.activate_times)
  os:marshalInt32(self.set_times)
end
function SFactionPVETimesBrd:unmarshal(os)
  self.activate_times = os:unmarshalInt32()
  self.set_times = os:unmarshalInt32()
end
function SFactionPVETimesBrd:sizepolicy(size)
  return size <= 65535
end
return SFactionPVETimesBrd
