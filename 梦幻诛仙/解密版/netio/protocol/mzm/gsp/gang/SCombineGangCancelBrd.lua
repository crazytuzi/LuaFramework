local SCombineGangCancelBrd = class("SCombineGangCancelBrd")
SCombineGangCancelBrd.TYPEID = 12589972
function SCombineGangCancelBrd:ctor(srcid, targetid)
  self.id = 12589972
  self.srcid = srcid or nil
  self.targetid = targetid or nil
end
function SCombineGangCancelBrd:marshal(os)
  os:marshalInt64(self.srcid)
  os:marshalInt64(self.targetid)
end
function SCombineGangCancelBrd:unmarshal(os)
  self.srcid = os:unmarshalInt64()
  self.targetid = os:unmarshalInt64()
end
function SCombineGangCancelBrd:sizepolicy(size)
  return size <= 65535
end
return SCombineGangCancelBrd
