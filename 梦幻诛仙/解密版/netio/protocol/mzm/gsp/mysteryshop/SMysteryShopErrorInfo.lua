local SMysteryShopErrorInfo = class("SMysteryShopErrorInfo")
SMysteryShopErrorInfo.TYPEID = 12614402
SMysteryShopErrorInfo.BUY_PAY_NOT_ENOUGH = 1
SMysteryShopErrorInfo.REFRESH_PAY_NOT_ENOUGH = 2
SMysteryShopErrorInfo.REFRESH_TIMES_NOT_ENOUGH = 3
SMysteryShopErrorInfo.GOODS_NOT_EXIST = 4
SMysteryShopErrorInfo.GOODS_BUY_COUNT_ERROR = 5
SMysteryShopErrorInfo.NO_FREE_TIMES_ERROR = 6
function SMysteryShopErrorInfo:ctor(error_code, params)
  self.id = 12614402
  self.error_code = error_code or nil
  self.params = params or {}
end
function SMysteryShopErrorInfo:marshal(os)
  os:marshalInt32(self.error_code)
  os:marshalCompactUInt32(table.getn(self.params))
  for _, v in ipairs(self.params) do
    os:marshalString(v)
  end
end
function SMysteryShopErrorInfo:unmarshal(os)
  self.error_code = os:unmarshalInt32()
  for _size_ = os:unmarshalCompactUInt32(), 1, -1 do
    local v = os:unmarshalString()
    table.insert(self.params, v)
  end
end
function SMysteryShopErrorInfo:sizepolicy(size)
  return size <= 65535
end
return SMysteryShopErrorInfo
