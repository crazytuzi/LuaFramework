local SSynBattleGlobalInfo = class("SSynBattleGlobalInfo")
SSynBattleGlobalInfo.TYPEID = 12621570
function SSynBattleGlobalInfo:ctor(campInfos)
  self.id = 12621570
  self.campInfos = campInfos or {}
end
function SSynBattleGlobalInfo:marshal(os)
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
function SSynBattleGlobalInfo:unmarshal(os)
  for _size_ = os:unmarshalCompactUInt32(), 1, -1 do
    local k = os:unmarshalInt32()
    local BeanClazz = require("netio.protocol.mzm.gsp.singlebattle.CampInfo")
    local v = BeanClazz.new()
    v:unmarshal(os)
    self.campInfos[k] = v
  end
end
function SSynBattleGlobalInfo:sizepolicy(size)
  return size <= 65535
end
return SSynBattleGlobalInfo
