local CExpressionPlayReq = class("CExpressionPlayReq")
CExpressionPlayReq.TYPEID = 12590944
function CExpressionPlayReq:ctor(actionEnum)
  self.id = 12590944
  self.actionEnum = actionEnum or nil
end
function CExpressionPlayReq:marshal(os)
  os:marshalInt32(self.actionEnum)
end
function CExpressionPlayReq:unmarshal(os)
  self.actionEnum = os:unmarshalInt32()
end
function CExpressionPlayReq:sizepolicy(size)
  return size <= 65535
end
return CExpressionPlayReq
