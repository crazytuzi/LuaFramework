local SOpenLuckyBagSuccess = class("SOpenLuckyBagSuccess")
SOpenLuckyBagSuccess.TYPEID = 12607491
function SOpenLuckyBagSuccess:ctor(items, award_items, index, instanceid, use_yuanbao, client_yuanbao, need_yuanbao)
  self.id = 12607491
  self.items = items or {}
  self.award_items = award_items or {}
  self.index = index or nil
  self.instanceid = instanceid or nil
  self.use_yuanbao = use_yuanbao or nil
  self.client_yuanbao = client_yuanbao or nil
  self.need_yuanbao = need_yuanbao or nil
end
function SOpenLuckyBagSuccess:marshal(os)
  do
    local _size_ = 0
    for _, _ in pairs(self.items) do
      _size_ = _size_ + 1
    end
    os:marshalCompactUInt32(_size_)
    for k, v in pairs(self.items) do
      os:marshalInt32(k)
      os:marshalInt32(v)
    end
  end
  do
    local _size_ = 0
    for _, _ in pairs(self.award_items) do
      _size_ = _size_ + 1
    end
    os:marshalCompactUInt32(_size_)
    for k, v in pairs(self.award_items) do
      os:marshalInt32(k)
      os:marshalInt32(v)
    end
  end
  os:marshalInt32(self.index)
  os:marshalInt32(self.instanceid)
  os:marshalUInt8(self.use_yuanbao)
  os:marshalInt64(self.client_yuanbao)
  os:marshalInt64(self.need_yuanbao)
end
function SOpenLuckyBagSuccess:unmarshal(os)
  for _size_ = os:unmarshalCompactUInt32(), 1, -1 do
    local k = os:unmarshalInt32()
    local v = os:unmarshalInt32()
    self.items[k] = v
  end
  for _size_ = os:unmarshalCompactUInt32(), 1, -1 do
    local k = os:unmarshalInt32()
    local v = os:unmarshalInt32()
    self.award_items[k] = v
  end
  self.index = os:unmarshalInt32()
  self.instanceid = os:unmarshalInt32()
  self.use_yuanbao = os:unmarshalUInt8()
  self.client_yuanbao = os:unmarshalInt64()
  self.need_yuanbao = os:unmarshalInt64()
end
function SOpenLuckyBagSuccess:sizepolicy(size)
  return size <= 65535
end
return SOpenLuckyBagSuccess
