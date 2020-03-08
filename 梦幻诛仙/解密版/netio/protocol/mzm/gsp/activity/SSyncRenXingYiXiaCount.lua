local SSyncRenXingYiXiaCount = class("SSyncRenXingYiXiaCount")
SSyncRenXingYiXiaCount.TYPEID = 12587534
function SSyncRenXingYiXiaCount:ctor(count)
  self.id = 12587534
  self.count = count or nil
end
function SSyncRenXingYiXiaCount:marshal(os)
  os:marshalInt32(self.count)
end
function SSyncRenXingYiXiaCount:unmarshal(os)
  self.count = os:unmarshalInt32()
end
function SSyncRenXingYiXiaCount:sizepolicy(size)
  return size <= 65535
end
return SSyncRenXingYiXiaCount
