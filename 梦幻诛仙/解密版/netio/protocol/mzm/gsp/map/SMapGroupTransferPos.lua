local Location = require("netio.protocol.mzm.gsp.map.Location")
local SMapGroupTransferPos = class("SMapGroupTransferPos")
SMapGroupTransferPos.TYPEID = 12590937
function SMapGroupTransferPos:ctor(group_type, groupid, pos, target_pos, map_cfgid, map_instance_id)
  self.id = 12590937
  self.group_type = group_type or nil
  self.groupid = groupid or nil
  self.pos = pos or Location.new()
  self.target_pos = target_pos or Location.new()
  self.map_cfgid = map_cfgid or nil
  self.map_instance_id = map_instance_id or nil
end
function SMapGroupTransferPos:marshal(os)
  os:marshalInt32(self.group_type)
  os:marshalInt64(self.groupid)
  self.pos:marshal(os)
  self.target_pos:marshal(os)
  os:marshalInt32(self.map_cfgid)
  os:marshalInt32(self.map_instance_id)
end
function SMapGroupTransferPos:unmarshal(os)
  self.group_type = os:unmarshalInt32()
  self.groupid = os:unmarshalInt64()
  self.pos = Location.new()
  self.pos:unmarshal(os)
  self.target_pos = Location.new()
  self.target_pos:unmarshal(os)
  self.map_cfgid = os:unmarshalInt32()
  self.map_instance_id = os:unmarshalInt32()
end
function SMapGroupTransferPos:sizepolicy(size)
  return size <= 65535
end
return SMapGroupTransferPos
