local OctetsStream = require("netio.OctetsStream")
local PetConsts = class("PetConsts")
PetConsts.PET_BAG_ID = 340600003
PetConsts.PET_DEPOT_ID = 340600004
function PetConsts:ctor(abc)
  self.abc = abc or nil
end
function PetConsts:marshal(os)
  os:marshalInt32(self.abc)
end
function PetConsts:unmarshal(os)
  self.abc = os:unmarshalInt32()
end
return PetConsts
