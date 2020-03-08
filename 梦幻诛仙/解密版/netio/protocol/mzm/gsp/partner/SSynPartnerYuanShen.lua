local SSynPartnerYuanShen = class("SSynPartnerYuanShen")
SSynPartnerYuanShen.TYPEID = 12588056
function SSynPartnerYuanShen:ctor(partnerId, yuanLv, levels)
  self.id = 12588056
  self.partnerId = partnerId or nil
  self.yuanLv = yuanLv or nil
  self.levels = levels or {}
end
function SSynPartnerYuanShen:marshal(os)
  os:marshalInt32(self.partnerId)
  os:marshalInt32(self.yuanLv)
  os:marshalCompactUInt32(table.getn(self.levels))
  for _, v in ipairs(self.levels) do
    os:marshalInt32(v)
  end
end
function SSynPartnerYuanShen:unmarshal(os)
  self.partnerId = os:unmarshalInt32()
  self.yuanLv = os:unmarshalInt32()
  for _size_ = os:unmarshalCompactUInt32(), 1, -1 do
    local v = os:unmarshalInt32()
    table.insert(self.levels, v)
  end
end
function SSynPartnerYuanShen:sizepolicy(size)
  return size <= 65535
end
return SSynPartnerYuanShen
