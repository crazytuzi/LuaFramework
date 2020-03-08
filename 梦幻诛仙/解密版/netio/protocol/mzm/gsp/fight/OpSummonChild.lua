local OctetsStream = require("netio.OctetsStream")
local OpSummonChild = class("OpSummonChild")
function OpSummonChild:ctor(child_uuid)
  self.child_uuid = child_uuid or nil
end
function OpSummonChild:marshal(os)
  os:marshalInt64(self.child_uuid)
end
function OpSummonChild:unmarshal(os)
  self.child_uuid = os:unmarshalInt64()
end
return OpSummonChild
