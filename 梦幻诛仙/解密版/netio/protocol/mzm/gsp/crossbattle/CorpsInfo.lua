local OctetsStream = require("netio.OctetsStream")
local CorpsInfo = class("CorpsInfo")
function CorpsInfo:ctor(corps_id, zone_id, corps_name, corps_icon, corps_rank)
  self.corps_id = corps_id or nil
  self.zone_id = zone_id or nil
  self.corps_name = corps_name or nil
  self.corps_icon = corps_icon or nil
  self.corps_rank = corps_rank or nil
end
function CorpsInfo:marshal(os)
  os:marshalInt64(self.corps_id)
  os:marshalInt32(self.zone_id)
  os:marshalOctets(self.corps_name)
  os:marshalInt32(self.corps_icon)
  os:marshalInt32(self.corps_rank)
end
function CorpsInfo:unmarshal(os)
  self.corps_id = os:unmarshalInt64()
  self.zone_id = os:unmarshalInt32()
  self.corps_name = os:unmarshalOctets()
  self.corps_icon = os:unmarshalInt32()
  self.corps_rank = os:unmarshalInt32()
end
return CorpsInfo
