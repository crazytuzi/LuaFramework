local OctetsStream = require("netio.OctetsStream")
local Uuid2num = class("Uuid2num")
function Uuid2num:ctor(uuid, num)
  self.uuid = uuid or nil
  self.num = num or nil
end
function Uuid2num:marshal(os)
  os:marshalInt64(self.uuid)
  os:marshalInt32(self.num)
end
function Uuid2num:unmarshal(os)
  self.uuid = os:unmarshalInt64()
  self.num = os:unmarshalInt32()
end
return Uuid2num
