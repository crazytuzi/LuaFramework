local SSynBattleFinalInfo = class("SSynBattleFinalInfo")
SSynBattleFinalInfo.TYPEID = 12621577
function SSynBattleFinalInfo:ctor(battleCfgId, winCampId, campFinalInfos)
  self.id = 12621577
  self.battleCfgId = battleCfgId or nil
  self.winCampId = winCampId or nil
  self.campFinalInfos = campFinalInfos or {}
end
function SSynBattleFinalInfo:marshal(os)
  os:marshalInt32(self.battleCfgId)
  os:marshalInt32(self.winCampId)
  local _size_ = 0
  for _, _ in pairs(self.campFinalInfos) do
    _size_ = _size_ + 1
  end
  os:marshalCompactUInt32(_size_)
  for k, v in pairs(self.campFinalInfos) do
    os:marshalInt32(k)
    v:marshal(os)
  end
end
function SSynBattleFinalInfo:unmarshal(os)
  self.battleCfgId = os:unmarshalInt32()
  self.winCampId = os:unmarshalInt32()
  for _size_ = os:unmarshalCompactUInt32(), 1, -1 do
    local k = os:unmarshalInt32()
    local BeanClazz = require("netio.protocol.mzm.gsp.singlebattle.CampFinalInfo")
    local v = BeanClazz.new()
    v:unmarshal(os)
    self.campFinalInfos[k] = v
  end
end
function SSynBattleFinalInfo:sizepolicy(size)
  return size <= 65535
end
return SSynBattleFinalInfo
