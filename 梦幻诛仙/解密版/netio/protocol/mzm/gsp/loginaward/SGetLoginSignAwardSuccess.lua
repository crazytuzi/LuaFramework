local SGetLoginSignAwardSuccess = class("SGetLoginSignAwardSuccess")
SGetLoginSignAwardSuccess.TYPEID = 12604684
function SGetLoginSignAwardSuccess:ctor(activity_cfgid, sortid)
  self.id = 12604684
  self.activity_cfgid = activity_cfgid or nil
  self.sortid = sortid or nil
end
function SGetLoginSignAwardSuccess:marshal(os)
  os:marshalInt32(self.activity_cfgid)
  os:marshalInt32(self.sortid)
end
function SGetLoginSignAwardSuccess:unmarshal(os)
  self.activity_cfgid = os:unmarshalInt32()
  self.sortid = os:unmarshalInt32()
end
function SGetLoginSignAwardSuccess:sizepolicy(size)
  return size <= 65535
end
return SGetLoginSignAwardSuccess
