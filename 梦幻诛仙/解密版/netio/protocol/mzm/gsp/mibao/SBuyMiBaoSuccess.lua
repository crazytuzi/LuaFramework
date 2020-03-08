local SBuyMiBaoSuccess = class("SBuyMiBaoSuccess")
SBuyMiBaoSuccess.TYPEID = 12603395
function SBuyMiBaoSuccess:ctor(random_item_map, current_lucky_value, current_score, current_mibao_index_id)
  self.id = 12603395
  self.random_item_map = random_item_map or {}
  self.current_lucky_value = current_lucky_value or nil
  self.current_score = current_score or nil
  self.current_mibao_index_id = current_mibao_index_id or nil
end
function SBuyMiBaoSuccess:marshal(os)
  os:marshalCompactUInt32(table.getn(self.random_item_map))
  for _, v in ipairs(self.random_item_map) do
    v:marshal(os)
  end
  os:marshalInt32(self.current_lucky_value)
  os:marshalInt32(self.current_score)
  os:marshalInt32(self.current_mibao_index_id)
end
function SBuyMiBaoSuccess:unmarshal(os)
  for _size_ = os:unmarshalCompactUInt32(), 1, -1 do
    local BeanClazz = require("netio.protocol.mzm.gsp.mibao.MiBaoItemInfo")
    local v = BeanClazz.new()
    v:unmarshal(os)
    table.insert(self.random_item_map, v)
  end
  self.current_lucky_value = os:unmarshalInt32()
  self.current_score = os:unmarshalInt32()
  self.current_mibao_index_id = os:unmarshalInt32()
end
function SBuyMiBaoSuccess:sizepolicy(size)
  return size <= 65535
end
return SBuyMiBaoSuccess
