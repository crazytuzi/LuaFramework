local OctetsStream = require("netio.OctetsStream")
local AwardInfoBean = class("AwardInfoBean")
function AwardInfoBean:ctor(moneyBeans, expBeans, itemmap, appellationid, titleid)
  self.moneyBeans = moneyBeans or {}
  self.expBeans = expBeans or {}
  self.itemmap = itemmap or {}
  self.appellationid = appellationid or nil
  self.titleid = titleid or nil
end
function AwardInfoBean:marshal(os)
  os:marshalCompactUInt32(table.getn(self.moneyBeans))
  for _, v in ipairs(self.moneyBeans) do
    v:marshal(os)
  end
  os:marshalCompactUInt32(table.getn(self.expBeans))
  for _, v in ipairs(self.expBeans) do
    v:marshal(os)
  end
  do
    local _size_ = 0
    for _, _ in pairs(self.itemmap) do
      _size_ = _size_ + 1
    end
    os:marshalCompactUInt32(_size_)
    for k, v in pairs(self.itemmap) do
      os:marshalInt32(k)
      os:marshalInt32(v)
    end
  end
  os:marshalInt32(self.appellationid)
  os:marshalInt32(self.titleid)
end
function AwardInfoBean:unmarshal(os)
  for _size_ = os:unmarshalCompactUInt32(), 1, -1 do
    local BeanClazz = require("netio.protocol.mzm.gsp.award.MoneyAwardBean")
    local v = BeanClazz.new()
    v:unmarshal(os)
    table.insert(self.moneyBeans, v)
  end
  for _size_ = os:unmarshalCompactUInt32(), 1, -1 do
    local BeanClazz = require("netio.protocol.mzm.gsp.award.ExpAwardBean")
    local v = BeanClazz.new()
    v:unmarshal(os)
    table.insert(self.expBeans, v)
  end
  for _size_ = os:unmarshalCompactUInt32(), 1, -1 do
    local k = os:unmarshalInt32()
    local v = os:unmarshalInt32()
    self.itemmap[k] = v
  end
  self.appellationid = os:unmarshalInt32()
  self.titleid = os:unmarshalInt32()
end
return AwardInfoBean
