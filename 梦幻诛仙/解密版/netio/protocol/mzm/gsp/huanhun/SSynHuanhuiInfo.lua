local SSynHuanhuiInfo = class("SSynHuanhuiInfo")
SSynHuanhuiInfo.TYPEID = 12584453
SSynHuanhuiInfo.ST_HUN__ACCEPT = 1
SSynHuanhuiInfo.ST_HUN__FINISH = 2
SSynHuanhuiInfo.ST_HUN__HAND_UP = 3
function SSynHuanhuiInfo:ctor(firstTime, itemInfos, status, seekHelpLeftCount, helpOtherLeftCount, timeLimit)
  self.id = 12584453
  self.firstTime = firstTime or nil
  self.itemInfos = itemInfos or {}
  self.status = status or nil
  self.seekHelpLeftCount = seekHelpLeftCount or nil
  self.helpOtherLeftCount = helpOtherLeftCount or nil
  self.timeLimit = timeLimit or nil
end
function SSynHuanhuiInfo:marshal(os)
  os:marshalInt32(self.firstTime)
  do
    local _size_ = 0
    for _, _ in pairs(self.itemInfos) do
      _size_ = _size_ + 1
    end
    os:marshalCompactUInt32(_size_)
    for k, v in pairs(self.itemInfos) do
      os:marshalInt32(k)
      v:marshal(os)
    end
  end
  os:marshalInt32(self.status)
  os:marshalInt32(self.seekHelpLeftCount)
  os:marshalInt32(self.helpOtherLeftCount)
  os:marshalInt64(self.timeLimit)
end
function SSynHuanhuiInfo:unmarshal(os)
  self.firstTime = os:unmarshalInt32()
  for _size_ = os:unmarshalCompactUInt32(), 1, -1 do
    local k = os:unmarshalInt32()
    local BeanClazz = require("netio.protocol.mzm.gsp.huanhun.ItemInfo")
    local v = BeanClazz.new()
    v:unmarshal(os)
    self.itemInfos[k] = v
  end
  self.status = os:unmarshalInt32()
  self.seekHelpLeftCount = os:unmarshalInt32()
  self.helpOtherLeftCount = os:unmarshalInt32()
  self.timeLimit = os:unmarshalInt64()
end
function SSynHuanhuiInfo:sizepolicy(size)
  return size <= 65535
end
return SSynHuanhuiInfo
