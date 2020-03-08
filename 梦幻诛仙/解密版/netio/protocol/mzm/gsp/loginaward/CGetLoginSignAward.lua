local CGetLoginSignAward = class("CGetLoginSignAward")
CGetLoginSignAward.TYPEID = 12604682
function CGetLoginSignAward:ctor(activity_cfgid, sortid)
  self.id = 12604682
  self.activity_cfgid = activity_cfgid or nil
  self.sortid = sortid or nil
end
function CGetLoginSignAward:marshal(os)
  os:marshalInt32(self.activity_cfgid)
  os:marshalInt32(self.sortid)
end
function CGetLoginSignAward:unmarshal(os)
  self.activity_cfgid = os:unmarshalInt32()
  self.sortid = os:unmarshalInt32()
end
function CGetLoginSignAward:sizepolicy(size)
  return size <= 65535
end
return CGetLoginSignAward
