local ChildBean = require("netio.protocol.mzm.gsp.children.ChildBean")
local SChildhoodToAdultSuccess = class("SChildhoodToAdultSuccess")
SChildhoodToAdultSuccess.TYPEID = 12609346
function SChildhoodToAdultSuccess:ctor(child_info)
  self.id = 12609346
  self.child_info = child_info or ChildBean.new()
end
function SChildhoodToAdultSuccess:marshal(os)
  self.child_info:marshal(os)
end
function SChildhoodToAdultSuccess:unmarshal(os)
  self.child_info = ChildBean.new()
  self.child_info:unmarshal(os)
end
function SChildhoodToAdultSuccess:sizepolicy(size)
  return size <= 65535
end
return SChildhoodToAdultSuccess
