local SKickoutRes = class("SKickoutRes")
SKickoutRes.TYPEID = 12597800
SKickoutRes.SUCCESS = 0
SKickoutRes.ERROR_UNKNOWN = 1
SKickoutRes.ERROR_SILVER_NOT_ENOUGH = 2
SKickoutRes.ERROR_NOT_AGREE = 3
SKickoutRes.ERROR_NO_SWORN = 4
SKickoutRes.ERROR_VOTEING = 5
function SKickoutRes:ctor(resultcode)
  self.id = 12597800
  self.resultcode = resultcode or nil
end
function SKickoutRes:marshal(os)
  os:marshalInt32(self.resultcode)
end
function SKickoutRes:unmarshal(os)
  self.resultcode = os:unmarshalInt32()
end
function SKickoutRes:sizepolicy(size)
  return size <= 65535
end
return SKickoutRes
