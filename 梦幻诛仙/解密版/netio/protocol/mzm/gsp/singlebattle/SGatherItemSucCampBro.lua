local SGatherItemSucCampBro = class("SGatherItemSucCampBro")
SGatherItemSucCampBro.TYPEID = 12621602
function SGatherItemSucCampBro:ctor(roleId, gatherItemCfgId)
  self.id = 12621602
  self.roleId = roleId or nil
  self.gatherItemCfgId = gatherItemCfgId or nil
end
function SGatherItemSucCampBro:marshal(os)
  os:marshalInt64(self.roleId)
  os:marshalInt32(self.gatherItemCfgId)
end
function SGatherItemSucCampBro:unmarshal(os)
  self.roleId = os:unmarshalInt64()
  self.gatherItemCfgId = os:unmarshalInt32()
end
function SGatherItemSucCampBro:sizepolicy(size)
  return size <= 65535
end
return SGatherItemSucCampBro
