local SSyncDesignDutyName = class("SSyncDesignDutyName")
SSyncDesignDutyName.TYPEID = 12589855
function SSyncDesignDutyName:ctor(designCaseId)
  self.id = 12589855
  self.designCaseId = designCaseId or nil
end
function SSyncDesignDutyName:marshal(os)
  os:marshalInt32(self.designCaseId)
end
function SSyncDesignDutyName:unmarshal(os)
  self.designCaseId = os:unmarshalInt32()
end
function SSyncDesignDutyName:sizepolicy(size)
  return size <= 65535
end
return SSyncDesignDutyName
