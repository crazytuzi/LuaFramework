local SNormalResult = class("SNormalResult")
SNormalResult.TYPEID = 12590097
SNormalResult.DELETE_ERR_BANGZHU = 0
SNormalResult.DELETE_ERR_LEVEL_LIMIT = 1
function SNormalResult:ctor(res)
  self.id = 12590097
  self.res = res or nil
end
function SNormalResult:marshal(os)
  os:marshalInt32(self.res)
end
function SNormalResult:unmarshal(os)
  self.res = os:unmarshalInt32()
end
function SNormalResult:sizepolicy(size)
  return size <= 65535
end
return SNormalResult
