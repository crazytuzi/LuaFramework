local SAddBaoShiDuRes = class("SAddBaoShiDuRes")
SAddBaoShiDuRes.TYPEID = 12585997
function SAddBaoShiDuRes:ctor(addBaoShuDu)
  self.id = 12585997
  self.addBaoShuDu = addBaoShuDu or nil
end
function SAddBaoShiDuRes:marshal(os)
  os:marshalInt32(self.addBaoShuDu)
end
function SAddBaoShiDuRes:unmarshal(os)
  self.addBaoShuDu = os:unmarshalInt32()
end
function SAddBaoShiDuRes:sizepolicy(size)
  return size <= 65535
end
return SAddBaoShiDuRes
