local OctetsStream = require("netio.OctetsStream")
local FighterStatus = require("netio.protocol.mzm.gsp.fight.FighterStatus")
local ShareDamageRet = class("ShareDamageRet")
function ShareDamageRet:ctor(targetid, shareDamageStatus, statusMap)
  self.targetid = targetid or nil
  self.shareDamageStatus = shareDamageStatus or FighterStatus.new()
  self.statusMap = statusMap or {}
end
function ShareDamageRet:marshal(os)
  os:marshalInt32(self.targetid)
  self.shareDamageStatus:marshal(os)
  local _size_ = 0
  for _, _ in pairs(self.statusMap) do
    _size_ = _size_ + 1
  end
  os:marshalCompactUInt32(_size_)
  for k, v in pairs(self.statusMap) do
    os:marshalInt32(k)
    v:marshal(os)
  end
end
function ShareDamageRet:unmarshal(os)
  self.targetid = os:unmarshalInt32()
  self.shareDamageStatus = FighterStatus.new()
  self.shareDamageStatus:unmarshal(os)
  for _size_ = os:unmarshalCompactUInt32(), 1, -1 do
    local k = os:unmarshalInt32()
    local BeanClazz = require("netio.protocol.mzm.gsp.fight.FighterStatus")
    local v = BeanClazz.new()
    v:unmarshal(os)
    self.statusMap[k] = v
  end
end
return ShareDamageRet
