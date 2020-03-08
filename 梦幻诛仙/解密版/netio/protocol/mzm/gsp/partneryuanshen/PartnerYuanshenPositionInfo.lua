local OctetsStream = require("netio.OctetsStream")
local PartnerYuanshenPositionInfo = class("PartnerYuanshenPositionInfo")
function PartnerYuanshenPositionInfo:ctor(attached_partner_id, level, property)
  self.attached_partner_id = attached_partner_id or nil
  self.level = level or nil
  self.property = property or nil
end
function PartnerYuanshenPositionInfo:marshal(os)
  os:marshalInt32(self.attached_partner_id)
  os:marshalInt32(self.level)
  os:marshalInt32(self.property)
end
function PartnerYuanshenPositionInfo:unmarshal(os)
  self.attached_partner_id = os:unmarshalInt32()
  self.level = os:unmarshalInt32()
  self.property = os:unmarshalInt32()
end
return PartnerYuanshenPositionInfo
