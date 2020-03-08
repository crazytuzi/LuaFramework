local ChildBean = require("netio.protocol.mzm.gsp.children.ChildBean")
local SAddChild = class("SAddChild")
SAddChild.TYPEID = 12609339
function SAddChild:ctor(child_id, child_info)
  self.id = 12609339
  self.child_id = child_id or nil
  self.child_info = child_info or ChildBean.new()
end
function SAddChild:marshal(os)
  os:marshalInt64(self.child_id)
  self.child_info:marshal(os)
end
function SAddChild:unmarshal(os)
  self.child_id = os:unmarshalInt64()
  self.child_info = ChildBean.new()
  self.child_info:unmarshal(os)
end
function SAddChild:sizepolicy(size)
  return size <= 65535
end
return SAddChild
