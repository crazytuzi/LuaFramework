local OctetsStream = require("netio.OctetsStream")
local GiveoutItemBean = class("GiveoutItemBean")
function GiveoutItemBean:ctor(uuid, num)
  self.uuid = uuid or nil
  self.num = num or nil
end
function GiveoutItemBean:marshal(os)
  os:marshalInt64(self.uuid)
  os:marshalInt32(self.num)
end
function GiveoutItemBean:unmarshal(os)
  self.uuid = os:unmarshalInt64()
  self.num = os:unmarshalInt32()
end
return GiveoutItemBean
