local CBidReq = class("CBidReq")
CBidReq.TYPEID = 12627206
function CBidReq:ctor(activityId, turnIndex, itemCfgId, moneyCount)
  self.id = 12627206
  self.activityId = activityId or nil
  self.turnIndex = turnIndex or nil
  self.itemCfgId = itemCfgId or nil
  self.moneyCount = moneyCount or nil
end
function CBidReq:marshal(os)
  os:marshalInt32(self.activityId)
  os:marshalInt32(self.turnIndex)
  os:marshalInt32(self.itemCfgId)
  os:marshalInt64(self.moneyCount)
end
function CBidReq:unmarshal(os)
  self.activityId = os:unmarshalInt32()
  self.turnIndex = os:unmarshalInt32()
  self.itemCfgId = os:unmarshalInt32()
  self.moneyCount = os:unmarshalInt64()
end
function CBidReq:sizepolicy(size)
  return size <= 65535
end
return CBidReq
