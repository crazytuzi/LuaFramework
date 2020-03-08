local CBuyGoldUseInGotReq = class("CBuyGoldUseInGotReq")
CBuyGoldUseInGotReq.TYPEID = 12584842
function CBuyGoldUseInGotReq:ctor(inGotNum, clientInGotNum)
  self.id = 12584842
  self.inGotNum = inGotNum or nil
  self.clientInGotNum = clientInGotNum or nil
end
function CBuyGoldUseInGotReq:marshal(os)
  os:marshalInt32(self.inGotNum)
  os:marshalInt64(self.clientInGotNum)
end
function CBuyGoldUseInGotReq:unmarshal(os)
  self.inGotNum = os:unmarshalInt32()
  self.clientInGotNum = os:unmarshalInt64()
end
function CBuyGoldUseInGotReq:sizepolicy(size)
  return size <= 65535
end
return CBuyGoldUseInGotReq
