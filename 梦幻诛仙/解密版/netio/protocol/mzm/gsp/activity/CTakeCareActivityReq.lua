local CTakeCareActivityReq = class("CTakeCareActivityReq")
CTakeCareActivityReq.TYPEID = 12587568
CTakeCareActivityReq.CANCEL = 0
CTakeCareActivityReq.TAKE_CARE = 1
function CTakeCareActivityReq:ctor(activityCfgId, careFlag)
  self.id = 12587568
  self.activityCfgId = activityCfgId or nil
  self.careFlag = careFlag or nil
end
function CTakeCareActivityReq:marshal(os)
  os:marshalInt32(self.activityCfgId)
  os:marshalInt32(self.careFlag)
end
function CTakeCareActivityReq:unmarshal(os)
  self.activityCfgId = os:unmarshalInt32()
  self.careFlag = os:unmarshalInt32()
end
function CTakeCareActivityReq:sizepolicy(size)
  return size <= 65535
end
return CTakeCareActivityReq
