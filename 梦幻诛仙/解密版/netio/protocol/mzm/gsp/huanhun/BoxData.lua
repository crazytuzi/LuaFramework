local OctetsStream = require("netio.OctetsStream")
local BoxData = class("BoxData")
function BoxData:ctor(itemId, num, startTime)
  self.itemId = itemId or nil
  self.num = num or nil
  self.startTime = startTime or nil
end
function BoxData:marshal(os)
  os:marshalInt32(self.itemId)
  os:marshalInt32(self.num)
  os:marshalInt64(self.startTime)
end
function BoxData:unmarshal(os)
  self.itemId = os:unmarshalInt32()
  self.num = os:unmarshalInt32()
  self.startTime = os:unmarshalInt64()
end
return BoxData
