local ChildBean = require("netio.protocol.mzm.gsp.children.ChildBean")
local SBabyToChildHoodSuccess = class("SBabyToChildHoodSuccess")
SBabyToChildHoodSuccess.TYPEID = 12609337
function SBabyToChildHoodSuccess:ctor(child_id, child_bean)
  self.id = 12609337
  self.child_id = child_id or nil
  self.child_bean = child_bean or ChildBean.new()
end
function SBabyToChildHoodSuccess:marshal(os)
  os:marshalInt64(self.child_id)
  self.child_bean:marshal(os)
end
function SBabyToChildHoodSuccess:unmarshal(os)
  self.child_id = os:unmarshalInt64()
  self.child_bean = ChildBean.new()
  self.child_bean:unmarshal(os)
end
function SBabyToChildHoodSuccess:sizepolicy(size)
  return size <= 65535
end
return SBabyToChildHoodSuccess
