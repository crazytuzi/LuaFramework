local BagChangeInfo = require("netio.protocol.mzm.gsp.item.BagChangeInfo")
local SBagChangeInfo = class("SBagChangeInfo")
SBagChangeInfo.TYPEID = 12584739
function SBagChangeInfo:ctor(data)
  self.id = 12584739
  self.data = data or BagChangeInfo.new()
end
function SBagChangeInfo:marshal(os)
  self.data:marshal(os)
end
function SBagChangeInfo:unmarshal(os)
  self.data = BagChangeInfo.new()
  self.data:unmarshal(os)
end
function SBagChangeInfo:sizepolicy(size)
  return size <= 131071
end
return SBagChangeInfo
