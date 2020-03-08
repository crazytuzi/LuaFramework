local SChampionsBrd = class("SChampionsBrd")
SChampionsBrd.TYPEID = 12596230
function SChampionsBrd:ctor(champions)
  self.id = 12596230
  self.champions = champions or {}
end
function SChampionsBrd:marshal(os)
  os:marshalCompactUInt32(table.getn(self.champions))
  for _, v in ipairs(self.champions) do
    v:marshal(os)
  end
end
function SChampionsBrd:unmarshal(os)
  for _size_ = os:unmarshalCompactUInt32(), 1, -1 do
    local BeanClazz = require("netio.protocol.mzm.gsp.menpaipvp.Champion")
    local v = BeanClazz.new()
    v:unmarshal(os)
    table.insert(self.champions, v)
  end
end
function SChampionsBrd:sizepolicy(size)
  return size <= 65535
end
return SChampionsBrd
