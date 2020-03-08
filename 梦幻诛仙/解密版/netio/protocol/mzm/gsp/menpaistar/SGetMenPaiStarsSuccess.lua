local SGetMenPaiStarsSuccess = class("SGetMenPaiStarsSuccess")
SGetMenPaiStarsSuccess.TYPEID = 12612385
function SGetMenPaiStarsSuccess:ctor(champions)
  self.id = 12612385
  self.champions = champions or {}
end
function SGetMenPaiStarsSuccess:marshal(os)
  os:marshalCompactUInt32(table.getn(self.champions))
  for _, v in ipairs(self.champions) do
    v:marshal(os)
  end
end
function SGetMenPaiStarsSuccess:unmarshal(os)
  for _size_ = os:unmarshalCompactUInt32(), 1, -1 do
    local BeanClazz = require("netio.protocol.mzm.gsp.menpaistar.MenPaiStarChampionInfo")
    local v = BeanClazz.new()
    v:unmarshal(os)
    table.insert(self.champions, v)
  end
end
function SGetMenPaiStarsSuccess:sizepolicy(size)
  return size <= 65535
end
return SGetMenPaiStarsSuccess
