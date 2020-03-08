local SAutoAddPotentialPrefErrorRes = class("SAutoAddPotentialPrefErrorRes")
SAutoAddPotentialPrefErrorRes.TYPEID = 12609388
SAutoAddPotentialPrefErrorRes.ERROR_DO_NOT_HAS_OCCUPATION = 1
SAutoAddPotentialPrefErrorRes.ERROR_ALREADY_DID_IT = 2
function SAutoAddPotentialPrefErrorRes:ctor(ret)
  self.id = 12609388
  self.ret = ret or nil
end
function SAutoAddPotentialPrefErrorRes:marshal(os)
  os:marshalInt32(self.ret)
end
function SAutoAddPotentialPrefErrorRes:unmarshal(os)
  self.ret = os:unmarshalInt32()
end
function SAutoAddPotentialPrefErrorRes:sizepolicy(size)
  return size <= 65535
end
return SAutoAddPotentialPrefErrorRes
