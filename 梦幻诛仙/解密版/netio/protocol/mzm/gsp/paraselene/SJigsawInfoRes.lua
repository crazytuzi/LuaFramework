local SJigsawInfoRes = class("SJigsawInfoRes")
SJigsawInfoRes.TYPEID = 12598293
function SJigsawInfoRes:ctor(issuccess, seconds, jigsawInfoRes)
  self.id = 12598293
  self.issuccess = issuccess or nil
  self.seconds = seconds or nil
  self.jigsawInfoRes = jigsawInfoRes or {}
end
function SJigsawInfoRes:marshal(os)
  os:marshalInt32(self.issuccess)
  os:marshalInt32(self.seconds)
  os:marshalCompactUInt32(table.getn(self.jigsawInfoRes))
  for _, v in ipairs(self.jigsawInfoRes) do
    v:marshal(os)
  end
end
function SJigsawInfoRes:unmarshal(os)
  self.issuccess = os:unmarshalInt32()
  self.seconds = os:unmarshalInt32()
  for _size_ = os:unmarshalCompactUInt32(), 1, -1 do
    local BeanClazz = require("netio.protocol.mzm.gsp.paraselene.JigsawInfo")
    local v = BeanClazz.new()
    v:unmarshal(os)
    table.insert(self.jigsawInfoRes, v)
  end
end
function SJigsawInfoRes:sizepolicy(size)
  return size <= 65535
end
return SJigsawInfoRes
