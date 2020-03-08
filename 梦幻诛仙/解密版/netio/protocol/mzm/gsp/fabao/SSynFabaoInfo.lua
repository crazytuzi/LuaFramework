local SSynFabaoInfo = class("SSynFabaoInfo")
SSynFabaoInfo.TYPEID = 12595990
function SSynFabaoInfo:ctor(euqipFabao, euqipLongjing, disFaBaotype)
  self.id = 12595990
  self.euqipFabao = euqipFabao or {}
  self.euqipLongjing = euqipLongjing or {}
  self.disFaBaotype = disFaBaotype or nil
end
function SSynFabaoInfo:marshal(os)
  do
    local _size_ = 0
    for _, _ in pairs(self.euqipFabao) do
      _size_ = _size_ + 1
    end
    os:marshalCompactUInt32(_size_)
    for k, v in pairs(self.euqipFabao) do
      os:marshalInt32(k)
      v:marshal(os)
    end
  end
  do
    local _size_ = 0
    for _, _ in pairs(self.euqipLongjing) do
      _size_ = _size_ + 1
    end
    os:marshalCompactUInt32(_size_)
    for k, v in pairs(self.euqipLongjing) do
      os:marshalInt32(k)
      v:marshal(os)
    end
  end
  os:marshalInt32(self.disFaBaotype)
end
function SSynFabaoInfo:unmarshal(os)
  for _size_ = os:unmarshalCompactUInt32(), 1, -1 do
    local k = os:unmarshalInt32()
    local BeanClazz = require("netio.protocol.mzm.gsp.item.ItemInfo")
    local v = BeanClazz.new()
    v:unmarshal(os)
    self.euqipFabao[k] = v
  end
  for _size_ = os:unmarshalCompactUInt32(), 1, -1 do
    local k = os:unmarshalInt32()
    local BeanClazz = require("netio.protocol.mzm.gsp.fabao.LongJingInfo")
    local v = BeanClazz.new()
    v:unmarshal(os)
    self.euqipLongjing[k] = v
  end
  self.disFaBaotype = os:unmarshalInt32()
end
function SSynFabaoInfo:sizepolicy(size)
  return size <= 65535
end
return SSynFabaoInfo
