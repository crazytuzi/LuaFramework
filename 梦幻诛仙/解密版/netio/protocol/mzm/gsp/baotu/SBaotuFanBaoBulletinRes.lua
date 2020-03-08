local SBaotuFanBaoBulletinRes = class("SBaotuFanBaoBulletinRes")
SBaotuFanBaoBulletinRes.TYPEID = 12583687
function SBaotuFanBaoBulletinRes:ctor(roleName, itemId, mapId, controllerId)
  self.id = 12583687
  self.roleName = roleName or nil
  self.itemId = itemId or nil
  self.mapId = mapId or nil
  self.controllerId = controllerId or nil
end
function SBaotuFanBaoBulletinRes:marshal(os)
  os:marshalOctets(self.roleName)
  os:marshalInt32(self.itemId)
  os:marshalInt32(self.mapId)
  os:marshalInt32(self.controllerId)
end
function SBaotuFanBaoBulletinRes:unmarshal(os)
  self.roleName = os:unmarshalOctets()
  self.itemId = os:unmarshalInt32()
  self.mapId = os:unmarshalInt32()
  self.controllerId = os:unmarshalInt32()
end
function SBaotuFanBaoBulletinRes:sizepolicy(size)
  return size <= 65535
end
return SBaotuFanBaoBulletinRes
