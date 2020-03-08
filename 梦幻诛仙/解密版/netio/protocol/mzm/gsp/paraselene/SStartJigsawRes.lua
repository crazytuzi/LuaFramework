local SStartJigsawRes = class("SStartJigsawRes")
SStartJigsawRes.TYPEID = 12598280
function SStartJigsawRes:ctor(endtime)
  self.id = 12598280
  self.endtime = endtime or nil
end
function SStartJigsawRes:marshal(os)
  os:marshalInt64(self.endtime)
end
function SStartJigsawRes:unmarshal(os)
  self.endtime = os:unmarshalInt64()
end
function SStartJigsawRes:sizepolicy(size)
  return size <= 65535
end
return SStartJigsawRes
