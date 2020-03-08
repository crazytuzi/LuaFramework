local SEquipMakeYunanbaoPriceRes = class("SEquipMakeYunanbaoPriceRes")
SEquipMakeYunanbaoPriceRes.TYPEID = 12584775
function SEquipMakeYunanbaoPriceRes:ctor(eqpId, clientNeedYuanbao, serverNeedYuanbao)
  self.id = 12584775
  self.eqpId = eqpId or nil
  self.clientNeedYuanbao = clientNeedYuanbao or nil
  self.serverNeedYuanbao = serverNeedYuanbao or nil
end
function SEquipMakeYunanbaoPriceRes:marshal(os)
  os:marshalInt32(self.eqpId)
  os:marshalInt32(self.clientNeedYuanbao)
  os:marshalInt32(self.serverNeedYuanbao)
end
function SEquipMakeYunanbaoPriceRes:unmarshal(os)
  self.eqpId = os:unmarshalInt32()
  self.clientNeedYuanbao = os:unmarshalInt32()
  self.serverNeedYuanbao = os:unmarshalInt32()
end
function SEquipMakeYunanbaoPriceRes:sizepolicy(size)
  return size <= 65535
end
return SEquipMakeYunanbaoPriceRes
