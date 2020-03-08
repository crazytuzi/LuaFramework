local OctetsStream = require("netio.OctetsStream")
local PetMarkInfo = class("PetMarkInfo")
function PetMarkInfo:ctor(pet_mark_cfg_id, level, exp, pet_id)
  self.pet_mark_cfg_id = pet_mark_cfg_id or nil
  self.level = level or nil
  self.exp = exp or nil
  self.pet_id = pet_id or nil
end
function PetMarkInfo:marshal(os)
  os:marshalInt32(self.pet_mark_cfg_id)
  os:marshalInt32(self.level)
  os:marshalInt32(self.exp)
  os:marshalInt64(self.pet_id)
end
function PetMarkInfo:unmarshal(os)
  self.pet_mark_cfg_id = os:unmarshalInt32()
  self.level = os:unmarshalInt32()
  self.exp = os:unmarshalInt32()
  self.pet_id = os:unmarshalInt64()
end
return PetMarkInfo
