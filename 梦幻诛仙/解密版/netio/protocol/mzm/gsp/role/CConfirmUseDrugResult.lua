local CConfirmUseDrugResult = class("CConfirmUseDrugResult")
CConfirmUseDrugResult.TYPEID = 12586014
function CConfirmUseDrugResult:ctor(itemKey, bagid)
  self.id = 12586014
  self.itemKey = itemKey or nil
  self.bagid = bagid or nil
end
function CConfirmUseDrugResult:marshal(os)
  os:marshalInt32(self.itemKey)
  os:marshalInt32(self.bagid)
end
function CConfirmUseDrugResult:unmarshal(os)
  self.itemKey = os:unmarshalInt32()
  self.bagid = os:unmarshalInt32()
end
function CConfirmUseDrugResult:sizepolicy(size)
  return size <= 65535
end
return CConfirmUseDrugResult
