local SSynBattleTotalInfo = class("SSynBattleTotalInfo")
SSynBattleTotalInfo.TYPEID = 12621571
function SSynBattleTotalInfo:ctor(battleCfgId, campInfos, stage, startTime)
  self.id = 12621571
  self.battleCfgId = battleCfgId or nil
  self.campInfos = campInfos or {}
  self.stage = stage or nil
  self.startTime = startTime or nil
end
function SSynBattleTotalInfo:marshal(os)
  os:marshalInt32(self.battleCfgId)
  do
    local _size_ = 0
    for _, _ in pairs(self.campInfos) do
      _size_ = _size_ + 1
    end
    os:marshalCompactUInt32(_size_)
    for k, v in pairs(self.campInfos) do
      os:marshalInt32(k)
      v:marshal(os)
    end
  end
  os:marshalInt32(self.stage)
  os:marshalInt32(self.startTime)
end
function SSynBattleTotalInfo:unmarshal(os)
  self.battleCfgId = os:unmarshalInt32()
  for _size_ = os:unmarshalCompactUInt32(), 1, -1 do
    local k = os:unmarshalInt32()
    local BeanClazz = require("netio.protocol.mzm.gsp.singlebattle.CampGlobalInfo")
    local v = BeanClazz.new()
    v:unmarshal(os)
    self.campInfos[k] = v
  end
  self.stage = os:unmarshalInt32()
  self.startTime = os:unmarshalInt32()
end
function SSynBattleTotalInfo:sizepolicy(size)
  return size <= 65535
end
return SSynBattleTotalInfo
