local SSurpriseNormalResult = class("SSurpriseNormalResult")
SSurpriseNormalResult.TYPEID = 12592158
SSurpriseNormalResult.USE_ACTIVE_GRAPH_ITEM_ERR__ONLY_ONE = 1
SSurpriseNormalResult.USE_ACTIVE_GRAPH_ITEM_ERR__ONLY_XX_TIME = 2
SSurpriseNormalResult.USE_ACTIVE_GRAPH_ITEM_ERR__ALREADY_OWN_GRAPH = 3
SSurpriseNormalResult.USE_ACTIVE_GRAPH_ITEM_ERR__DAY_USED_UP = 4
function SSurpriseNormalResult:ctor(result, args)
  self.id = 12592158
  self.result = result or nil
  self.args = args or {}
end
function SSurpriseNormalResult:marshal(os)
  os:marshalInt32(self.result)
  os:marshalCompactUInt32(table.getn(self.args))
  for _, v in ipairs(self.args) do
    os:marshalString(v)
  end
end
function SSurpriseNormalResult:unmarshal(os)
  self.result = os:unmarshalInt32()
  for _size_ = os:unmarshalCompactUInt32(), 1, -1 do
    local v = os:unmarshalString()
    table.insert(self.args, v)
  end
end
function SSurpriseNormalResult:sizepolicy(size)
  return size <= 65535
end
return SSurpriseNormalResult
