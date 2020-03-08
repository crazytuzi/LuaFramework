local SOpenMultipleLuckyBagSuccess = class("SOpenMultipleLuckyBagSuccess")
SOpenMultipleLuckyBagSuccess.TYPEID = 12607499
function SOpenMultipleLuckyBagSuccess:ctor(items, award_items, instanceid, use_yuanbao, client_yuanbao, need_yuanbao)
  self.id = 12607499
  self.items = items or {}
  self.award_items = award_items or {}
  self.instanceid = instanceid or nil
  self.use_yuanbao = use_yuanbao or nil
  self.client_yuanbao = client_yuanbao or nil
  self.need_yuanbao = need_yuanbao or nil
end
function SOpenMultipleLuckyBagSuccess:marshal(os)
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
  os:marshalCompactUInt32(table.getn(self.award_items))
  for _, v in ipairs(self.award_items) do
    v:marshal(os)
  end
  os:marshalInt32(self.instanceid)
  os:marshalUInt8(self.use_yuanbao)
  os:marshalInt64(self.client_yuanbao)
  os:marshalInt64(self.need_yuanbao)
end
function SOpenMultipleLuckyBagSuccess:unmarshal(os)
  for _size_ = os:unmarshalCompactUInt32(), 1, -1 do
    local k = os:unmarshalInt32()
    local v = os:unmarshalInt32()
    self.items[k] = v
  end
  for _size_ = os:unmarshalCompactUInt32(), 1, -1 do
    local BeanClazz = require("netio.protocol.mzm.gsp.luckybag.ItemInfo")
    local v = BeanClazz.new()
    v:unmarshal(os)
    table.insert(self.award_items, v)
  end
  self.instanceid = os:unmarshalInt32()
  self.use_yuanbao = os:unmarshalUInt8()
  self.client_yuanbao = os:unmarshalInt64()
  self.need_yuanbao = os:unmarshalInt64()
end
function SOpenMultipleLuckyBagSuccess:sizepolicy(size)
  return size <= 65535
end
return SOpenMultipleLuckyBagSuccess
