local SSyncVoteFightResult = class("SSyncVoteFightResult")
SSyncVoteFightResult.TYPEID = 12612383
function SSyncVoteFightResult:ctor(success)
  self.id = 12612383
  self.success = success or nil
end
function SSyncVoteFightResult:marshal(os)
  os:marshalUInt8(self.success)
end
function SSyncVoteFightResult:unmarshal(os)
  self.success = os:unmarshalUInt8()
end
function SSyncVoteFightResult:sizepolicy(size)
  return size <= 65535
end
return SSyncVoteFightResult
