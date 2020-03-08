local STakeCareActivityRes = class("STakeCareActivityRes")
STakeCareActivityRes.TYPEID = 12587565
STakeCareActivityRes.SUCCESS = 0
STakeCareActivityRes.FAIL = 1
function STakeCareActivityRes:ctor(result, activityCfgId)
  self.id = 12587565
  self.result = result or nil
  self.activityCfgId = activityCfgId or nil
end
function STakeCareActivityRes:marshal(os)
  os:marshalInt32(self.result)
  os:marshalInt32(self.activityCfgId)
end
function STakeCareActivityRes:unmarshal(os)
  self.result = os:unmarshalInt32()
  self.activityCfgId = os:unmarshalInt32()
end
function STakeCareActivityRes:sizepolicy(size)
  return size <= 65535
end
return STakeCareActivityRes
