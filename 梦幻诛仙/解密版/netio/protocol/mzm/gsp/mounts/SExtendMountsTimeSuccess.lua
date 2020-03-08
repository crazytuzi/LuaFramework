local SExtendMountsTimeSuccess = class("SExtendMountsTimeSuccess")
SExtendMountsTimeSuccess.TYPEID = 12606239
function SExtendMountsTimeSuccess:ctor(mounts_id, remain_time)
  self.id = 12606239
  self.mounts_id = mounts_id or nil
  self.remain_time = remain_time or nil
end
function SExtendMountsTimeSuccess:marshal(os)
  os:marshalInt64(self.mounts_id)
  os:marshalInt64(self.remain_time)
end
function SExtendMountsTimeSuccess:unmarshal(os)
  self.mounts_id = os:unmarshalInt64()
  self.remain_time = os:unmarshalInt64()
end
function SExtendMountsTimeSuccess:sizepolicy(size)
  return size <= 65535
end
return SExtendMountsTimeSuccess
