local CResetAddPotentialPrefReq = class("CResetAddPotentialPrefReq")
CResetAddPotentialPrefReq.TYPEID = 12609400
function CResetAddPotentialPrefReq:ctor(childrenid, nowMoneyNum)
  self.id = 12609400
  self.childrenid = childrenid or nil
  self.nowMoneyNum = nowMoneyNum or nil
end
function CResetAddPotentialPrefReq:marshal(os)
  os:marshalInt64(self.childrenid)
  os:marshalInt64(self.nowMoneyNum)
end
function CResetAddPotentialPrefReq:unmarshal(os)
  self.childrenid = os:unmarshalInt64()
  self.nowMoneyNum = os:unmarshalInt64()
end
function CResetAddPotentialPrefReq:sizepolicy(size)
  return size <= 65535
end
return CResetAddPotentialPrefReq
