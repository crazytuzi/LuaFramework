local SCombineGangApplyRes = class("SCombineGangApplyRes")
SCombineGangApplyRes.TYPEID = 12589970
function SCombineGangApplyRes:ctor(targetid, target_name)
  self.id = 12589970
  self.targetid = targetid or nil
  self.target_name = target_name or nil
end
function SCombineGangApplyRes:marshal(os)
  os:marshalInt64(self.targetid)
  os:marshalString(self.target_name)
end
function SCombineGangApplyRes:unmarshal(os)
  self.targetid = os:unmarshalInt64()
  self.target_name = os:unmarshalString()
end
function SCombineGangApplyRes:sizepolicy(size)
  return size <= 65535
end
return SCombineGangApplyRes
