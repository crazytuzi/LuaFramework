local SAdvertsSuccess = class("SAdvertsSuccess")
SAdvertsSuccess.TYPEID = 12603667
function SAdvertsSuccess:ctor(adverts)
  self.id = 12603667
  self.adverts = adverts or {}
end
function SAdvertsSuccess:marshal(os)
  os:marshalCompactUInt32(table.getn(self.adverts))
  for _, v in ipairs(self.adverts) do
    v:marshal(os)
  end
end
function SAdvertsSuccess:unmarshal(os)
  for _size_ = os:unmarshalCompactUInt32(), 1, -1 do
    local BeanClazz = require("netio.protocol.mzm.gsp.personal.AdvertInfo")
    local v = BeanClazz.new()
    v:unmarshal(os)
    table.insert(self.adverts, v)
  end
end
function SAdvertsSuccess:sizepolicy(size)
  return size <= 65535
end
return SAdvertsSuccess
