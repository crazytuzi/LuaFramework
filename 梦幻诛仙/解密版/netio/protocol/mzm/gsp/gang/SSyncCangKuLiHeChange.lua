local SSyncCangKuLiHeChange = class("SSyncCangKuLiHeChange")
SSyncCangKuLiHeChange.TYPEID = 12589931
function SSyncCangKuLiHeChange:ctor(liheNum)
  self.id = 12589931
  self.liheNum = liheNum or nil
end
function SSyncCangKuLiHeChange:marshal(os)
  os:marshalInt32(self.liheNum)
end
function SSyncCangKuLiHeChange:unmarshal(os)
  self.liheNum = os:unmarshalInt32()
end
function SSyncCangKuLiHeChange:sizepolicy(size)
  return size <= 65535
end
return SSyncCangKuLiHeChange
