local CLongjingMountReq = class("CLongjingMountReq")
CLongjingMountReq.TYPEID = 12595981
function CLongjingMountReq:ctor(itemkey, pos)
  self.id = 12595981
  self.itemkey = itemkey or nil
  self.pos = pos or nil
end
function CLongjingMountReq:marshal(os)
  os:marshalInt32(self.itemkey)
  os:marshalInt32(self.pos)
end
function CLongjingMountReq:unmarshal(os)
  self.itemkey = os:unmarshalInt32()
  self.pos = os:unmarshalInt32()
end
function CLongjingMountReq:sizepolicy(size)
  return size <= 65535
end
return CLongjingMountReq
