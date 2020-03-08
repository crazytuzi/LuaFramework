local SBuyItemErrorInfo = class("SBuyItemErrorInfo")
SBuyItemErrorInfo.TYPEID = 12585474
SBuyItemErrorInfo.YUANBAO_NOT_ENOUGH = 1
SBuyItemErrorInfo.SHIMEN_NOT_ENOUGH = 2
SBuyItemErrorInfo.ITEM_NOT_EXIST = 3
SBuyItemErrorInfo.ITEM_BUY_NUM_ERROR = 4
function SBuyItemErrorInfo:ctor(errorCode, params)
  self.id = 12585474
  self.errorCode = errorCode or nil
  self.params = params or {}
end
function SBuyItemErrorInfo:marshal(os)
  os:marshalInt32(self.errorCode)
  os:marshalCompactUInt32(table.getn(self.params))
  for _, v in ipairs(self.params) do
    os:marshalString(v)
  end
end
function SBuyItemErrorInfo:unmarshal(os)
  self.errorCode = os:unmarshalInt32()
  for _size_ = os:unmarshalCompactUInt32(), 1, -1 do
    local v = os:unmarshalString()
    table.insert(self.params, v)
  end
end
function SBuyItemErrorInfo:sizepolicy(size)
  return size <= 65535
end
return SBuyItemErrorInfo
