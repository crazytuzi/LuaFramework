local CExtendBag = class("CExtendBag")
CExtendBag.TYPEID = 12584731
function CExtendBag:ctor(bagId, isuseyuanbao, curYuanbaoNum)
  self.id = 12584731
  self.bagId = bagId or nil
  self.isuseyuanbao = isuseyuanbao or nil
  self.curYuanbaoNum = curYuanbaoNum or nil
end
function CExtendBag:marshal(os)
  os:marshalInt32(self.bagId)
  os:marshalInt32(self.isuseyuanbao)
  os:marshalInt64(self.curYuanbaoNum)
end
function CExtendBag:unmarshal(os)
  self.bagId = os:unmarshalInt32()
  self.isuseyuanbao = os:unmarshalInt32()
  self.curYuanbaoNum = os:unmarshalInt64()
end
function CExtendBag:sizepolicy(size)
  return size <= 65535
end
return CExtendBag
