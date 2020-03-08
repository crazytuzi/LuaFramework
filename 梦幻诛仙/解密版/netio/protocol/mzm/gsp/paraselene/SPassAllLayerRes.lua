local SPassAllLayerRes = class("SPassAllLayerRes")
SPassAllLayerRes.TYPEID = 12598297
function SPassAllLayerRes:ctor(isFanPai, seconds)
  self.id = 12598297
  self.isFanPai = isFanPai or nil
  self.seconds = seconds or nil
end
function SPassAllLayerRes:marshal(os)
  os:marshalInt32(self.isFanPai)
  os:marshalInt32(self.seconds)
end
function SPassAllLayerRes:unmarshal(os)
  self.isFanPai = os:unmarshalInt32()
  self.seconds = os:unmarshalInt32()
end
function SPassAllLayerRes:sizepolicy(size)
  return size <= 65535
end
return SPassAllLayerRes
