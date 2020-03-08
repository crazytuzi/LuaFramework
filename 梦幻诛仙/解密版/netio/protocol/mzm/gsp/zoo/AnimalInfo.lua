local OctetsStream = require("netio.OctetsStream")
local AnimalInfo = class("AnimalInfo")
function AnimalInfo:ctor(animalid, stage, name, stage_info)
  self.animalid = animalid or nil
  self.stage = stage or nil
  self.name = name or nil
  self.stage_info = stage_info or nil
end
function AnimalInfo:marshal(os)
  os:marshalInt64(self.animalid)
  os:marshalInt32(self.stage)
  os:marshalOctets(self.name)
  os:marshalOctets(self.stage_info)
end
function AnimalInfo:unmarshal(os)
  self.animalid = os:unmarshalInt64()
  self.stage = os:unmarshalInt32()
  self.name = os:unmarshalOctets()
  self.stage_info = os:unmarshalOctets()
end
return AnimalInfo
