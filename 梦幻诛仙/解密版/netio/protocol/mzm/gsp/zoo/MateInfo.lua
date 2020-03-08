local OctetsStream = require("netio.OctetsStream")
local MateInfo = class("MateInfo")
function MateInfo:ctor(role_name, animal_cfgid, mate_time)
  self.role_name = role_name or nil
  self.animal_cfgid = animal_cfgid or nil
  self.mate_time = mate_time or nil
end
function MateInfo:marshal(os)
  os:marshalOctets(self.role_name)
  os:marshalInt32(self.animal_cfgid)
  os:marshalInt32(self.mate_time)
end
function MateInfo:unmarshal(os)
  self.role_name = os:unmarshalOctets()
  self.animal_cfgid = os:unmarshalInt32()
  self.mate_time = os:unmarshalInt32()
end
return MateInfo
