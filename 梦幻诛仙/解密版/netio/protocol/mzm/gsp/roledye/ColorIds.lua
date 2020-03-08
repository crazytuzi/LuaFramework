local OctetsStream = require("netio.OctetsStream")
local ColorIds = class("ColorIds")
function ColorIds:ctor(colorid, hairid, clothid, fashionDressCfgId)
  self.colorid = colorid or nil
  self.hairid = hairid or nil
  self.clothid = clothid or nil
  self.fashionDressCfgId = fashionDressCfgId or nil
end
function ColorIds:marshal(os)
  os:marshalInt32(self.colorid)
  os:marshalInt32(self.hairid)
  os:marshalInt32(self.clothid)
  os:marshalInt32(self.fashionDressCfgId)
end
function ColorIds:unmarshal(os)
  self.colorid = os:unmarshalInt32()
  self.hairid = os:unmarshalInt32()
  self.clothid = os:unmarshalInt32()
  self.fashionDressCfgId = os:unmarshalInt32()
end
return ColorIds
