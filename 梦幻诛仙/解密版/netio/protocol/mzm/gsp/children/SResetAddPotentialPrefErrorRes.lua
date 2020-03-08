local SResetAddPotentialPrefErrorRes = class("SResetAddPotentialPrefErrorRes")
SResetAddPotentialPrefErrorRes.TYPEID = 12609398
SResetAddPotentialPrefErrorRes.ERROR_DO_NOT_HAS_OCCUPATION = 1
SResetAddPotentialPrefErrorRes.ERROR_DO_NOT_HAS_PREF = 2
SResetAddPotentialPrefErrorRes.ERROR_DO_NOT_HAS_ENOUGH_GOLD = 3
function SResetAddPotentialPrefErrorRes:ctor(ret)
  self.id = 12609398
  self.ret = ret or nil
end
function SResetAddPotentialPrefErrorRes:marshal(os)
  os:marshalInt32(self.ret)
end
function SResetAddPotentialPrefErrorRes:unmarshal(os)
  self.ret = os:unmarshalInt32()
end
function SResetAddPotentialPrefErrorRes:sizepolicy(size)
  return size <= 65535
end
return SResetAddPotentialPrefErrorRes
