local SSearchAdvertsSuccess = class("SSearchAdvertsSuccess")
SSearchAdvertsSuccess.TYPEID = 12603662
function SSearchAdvertsSuccess:ctor(adverts, size, advertType, page)
  self.id = 12603662
  self.adverts = adverts or {}
  self.size = size or nil
  self.advertType = advertType or nil
  self.page = page or nil
end
function SSearchAdvertsSuccess:marshal(os)
  os:marshalCompactUInt32(table.getn(self.adverts))
  for _, v in ipairs(self.adverts) do
    v:marshal(os)
  end
  os:marshalInt32(self.size)
  os:marshalInt32(self.advertType)
  os:marshalInt32(self.page)
end
function SSearchAdvertsSuccess:unmarshal(os)
  for _size_ = os:unmarshalCompactUInt32(), 1, -1 do
    local BeanClazz = require("netio.protocol.mzm.gsp.personal.AdvertInfo")
    local v = BeanClazz.new()
    v:unmarshal(os)
    table.insert(self.adverts, v)
  end
  self.size = os:unmarshalInt32()
  self.advertType = os:unmarshalInt32()
  self.page = os:unmarshalInt32()
end
function SSearchAdvertsSuccess:sizepolicy(size)
  return size <= 65535
end
return SSearchAdvertsSuccess
