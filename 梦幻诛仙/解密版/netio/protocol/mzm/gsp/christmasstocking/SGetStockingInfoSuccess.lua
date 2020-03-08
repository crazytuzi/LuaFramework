local SGetStockingInfoSuccess = class("SGetStockingInfoSuccess")
SGetStockingInfoSuccess.TYPEID = 12629515
SGetStockingInfoSuccess.POSITION_STATE_EMPTY = 1
SGetStockingInfoSuccess.POSITION_HANGING = 2
SGetStockingInfoSuccess.POSITION_WITH_AWARD = 3
function SGetStockingInfoSuccess:ctor(target_role_id, target_role_name, historys, position_state, self_hang_num)
  self.id = 12629515
  self.target_role_id = target_role_id or nil
  self.target_role_name = target_role_name or nil
  self.historys = historys or {}
  self.position_state = position_state or {}
  self.self_hang_num = self_hang_num or nil
end
function SGetStockingInfoSuccess:marshal(os)
  os:marshalInt64(self.target_role_id)
  os:marshalOctets(self.target_role_name)
  os:marshalCompactUInt32(table.getn(self.historys))
  for _, v in ipairs(self.historys) do
    v:marshal(os)
  end
  do
    local _size_ = 0
    for _, _ in pairs(self.position_state) do
      _size_ = _size_ + 1
    end
    os:marshalCompactUInt32(_size_)
    for k, v in pairs(self.position_state) do
      os:marshalInt32(k)
      os:marshalInt32(v)
    end
  end
  os:marshalInt32(self.self_hang_num)
end
function SGetStockingInfoSuccess:unmarshal(os)
  self.target_role_id = os:unmarshalInt64()
  self.target_role_name = os:unmarshalOctets()
  for _size_ = os:unmarshalCompactUInt32(), 1, -1 do
    local BeanClazz = require("netio.protocol.mzm.gsp.christmasstocking.HangStockingHistory")
    local v = BeanClazz.new()
    v:unmarshal(os)
    table.insert(self.historys, v)
  end
  for _size_ = os:unmarshalCompactUInt32(), 1, -1 do
    local k = os:unmarshalInt32()
    local v = os:unmarshalInt32()
    self.position_state[k] = v
  end
  self.self_hang_num = os:unmarshalInt32()
end
function SGetStockingInfoSuccess:sizepolicy(size)
  return size <= 65535
end
return SGetStockingInfoSuccess
