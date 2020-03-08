local OctetsStream = require("netio.OctetsStream")
local Location = class("Location")
function Location:ctor(province, city)
  self.province = province or nil
  self.city = city or nil
end
function Location:marshal(os)
  os:marshalInt32(self.province)
  os:marshalInt32(self.city)
end
function Location:unmarshal(os)
  self.province = os:unmarshalInt32()
  self.city = os:unmarshalInt32()
end
return Location
