local BagChangeInfo = require("netio.protocol.mzm.gsp.item.BagChangeInfo")
local SStorageChangeInfo = class("SStorageChangeInfo")
SStorageChangeInfo.TYPEID = 12584803
function SStorageChangeInfo:ctor(data)
  self.id = 12584803
  self.data = data or BagChangeInfo.new()
end
function SStorageChangeInfo:marshal(os)
  self.data:marshal(os)
end
function SStorageChangeInfo:unmarshal(os)
  self.data = BagChangeInfo.new()
  self.data:unmarshal(os)
end
function SStorageChangeInfo:sizepolicy(size)
  return size <= 65535
end
return SStorageChangeInfo
