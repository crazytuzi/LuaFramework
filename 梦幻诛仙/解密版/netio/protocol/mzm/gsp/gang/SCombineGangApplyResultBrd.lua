local SCombineGangApplyResultBrd = class("SCombineGangApplyResultBrd")
SCombineGangApplyResultBrd.TYPEID = 12589971
SCombineGangApplyResultBrd.RESULT_AGREE = 0
SCombineGangApplyResultBrd.RESULT_REFUSE = 1
SCombineGangApplyResultBrd.RESULT_TIMEOUT = 2
function SCombineGangApplyResultBrd:ctor(srcid, targetid, result)
  self.id = 12589971
  self.srcid = srcid or nil
  self.targetid = targetid or nil
  self.result = result or nil
end
function SCombineGangApplyResultBrd:marshal(os)
  os:marshalInt64(self.srcid)
  os:marshalInt64(self.targetid)
  os:marshalInt32(self.result)
end
function SCombineGangApplyResultBrd:unmarshal(os)
  self.srcid = os:unmarshalInt64()
  self.targetid = os:unmarshalInt64()
  self.result = os:unmarshalInt32()
end
function SCombineGangApplyResultBrd:sizepolicy(size)
  return size <= 65535
end
return SCombineGangApplyResultBrd
