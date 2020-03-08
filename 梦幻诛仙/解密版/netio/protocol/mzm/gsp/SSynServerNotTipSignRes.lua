local SSynServerNotTipSignRes = class("SSynServerNotTipSignRes")
SSynServerNotTipSignRes.TYPEID = 12590105
SSynServerNotTipSignRes.NOT_TIP = 0
SSynServerNotTipSignRes.TIP = 1
function SSynServerNotTipSignRes:ctor(isTip)
  self.id = 12590105
  self.isTip = isTip or nil
end
function SSynServerNotTipSignRes:marshal(os)
  os:marshalInt32(self.isTip)
end
function SSynServerNotTipSignRes:unmarshal(os)
  self.isTip = os:unmarshalInt32()
end
function SSynServerNotTipSignRes:sizepolicy(size)
  return size <= 65535
end
return SSynServerNotTipSignRes
