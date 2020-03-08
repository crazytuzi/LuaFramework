local OctetsStream = require("netio.OctetsStream")
local RolePartnerInfo = class("RolePartnerInfo")
RolePartnerInfo.LINEUP_A = 0
RolePartnerInfo.LINEUP_B = 1
RolePartnerInfo.LINEUP_C = 2
function RolePartnerInfo:ctor(ownPartners, lineUps, defaultLineUpNum, partner2Property)
  self.ownPartners = ownPartners or {}
  self.lineUps = lineUps or {}
  self.defaultLineUpNum = defaultLineUpNum or nil
  self.partner2Property = partner2Property or {}
end
function RolePartnerInfo:marshal(os)
  os:marshalCompactUInt32(table.getn(self.ownPartners))
  for _, v in ipairs(self.ownPartners) do
    os:marshalInt32(v)
  end
  do
    local _size_ = 0
    for _, _ in pairs(self.lineUps) do
      _size_ = _size_ + 1
    end
    os:marshalCompactUInt32(_size_)
    for k, v in pairs(self.lineUps) do
      os:marshalInt32(k)
      v:marshal(os)
    end
  end
  os:marshalInt32(self.defaultLineUpNum)
  local _size_ = 0
  for _, _ in pairs(self.partner2Property) do
    _size_ = _size_ + 1
  end
  os:marshalCompactUInt32(_size_)
  for k, v in pairs(self.partner2Property) do
    os:marshalInt32(k)
    v:marshal(os)
  end
end
function RolePartnerInfo:unmarshal(os)
  for _size_ = os:unmarshalCompactUInt32(), 1, -1 do
    local v = os:unmarshalInt32()
    table.insert(self.ownPartners, v)
  end
  for _size_ = os:unmarshalCompactUInt32(), 1, -1 do
    local k = os:unmarshalInt32()
    local BeanClazz = require("netio.protocol.mzm.gsp.partner.LineUp")
    local v = BeanClazz.new()
    v:unmarshal(os)
    self.lineUps[k] = v
  end
  self.defaultLineUpNum = os:unmarshalInt32()
  for _size_ = os:unmarshalCompactUInt32(), 1, -1 do
    local k = os:unmarshalInt32()
    local BeanClazz = require("netio.protocol.mzm.gsp.partner.Property")
    local v = BeanClazz.new()
    v:unmarshal(os)
    self.partner2Property[k] = v
  end
end
return RolePartnerInfo
