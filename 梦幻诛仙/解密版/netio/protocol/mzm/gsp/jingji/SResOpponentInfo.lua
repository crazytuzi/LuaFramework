local SResOpponentInfo = class("SResOpponentInfo")
SResOpponentInfo.TYPEID = 12595713
function SResOpponentInfo:ctor(opponentList)
  self.id = 12595713
  self.opponentList = opponentList or {}
end
function SResOpponentInfo:marshal(os)
  os:marshalCompactUInt32(table.getn(self.opponentList))
  for _, v in ipairs(self.opponentList) do
    v:marshal(os)
  end
end
function SResOpponentInfo:unmarshal(os)
  for _size_ = os:unmarshalCompactUInt32(), 1, -1 do
    local BeanClazz = require("netio.protocol.mzm.gsp.jingji.OpponentInfo")
    local v = BeanClazz.new()
    v:unmarshal(os)
    table.insert(self.opponentList, v)
  end
end
function SResOpponentInfo:sizepolicy(size)
  return size <= 65535
end
return SResOpponentInfo
