local OctetsStream = require("netio.OctetsStream")
local ModelInfo = require("netio.protocol.mzm.gsp.pubdata.ModelInfo")
local CorpsMemberInfo = class("CorpsMemberInfo")
function CorpsMemberInfo:ctor(roleId, gender, occupation, role_name, avatar_id, role_level, role_fight_value, role_model_info, duty, join_time)
  self.roleId = roleId or nil
  self.gender = gender or nil
  self.occupation = occupation or nil
  self.role_name = role_name or nil
  self.avatar_id = avatar_id or nil
  self.role_level = role_level or nil
  self.role_fight_value = role_fight_value or nil
  self.role_model_info = role_model_info or ModelInfo.new()
  self.duty = duty or nil
  self.join_time = join_time or nil
end
function CorpsMemberInfo:marshal(os)
  os:marshalInt64(self.roleId)
  os:marshalInt32(self.gender)
  os:marshalInt32(self.occupation)
  os:marshalOctets(self.role_name)
  os:marshalInt32(self.avatar_id)
  os:marshalInt32(self.role_level)
  os:marshalInt32(self.role_fight_value)
  self.role_model_info:marshal(os)
  os:marshalInt32(self.duty)
  os:marshalInt32(self.join_time)
end
function CorpsMemberInfo:unmarshal(os)
  self.roleId = os:unmarshalInt64()
  self.gender = os:unmarshalInt32()
  self.occupation = os:unmarshalInt32()
  self.role_name = os:unmarshalOctets()
  self.avatar_id = os:unmarshalInt32()
  self.role_level = os:unmarshalInt32()
  self.role_fight_value = os:unmarshalInt32()
  self.role_model_info = ModelInfo.new()
  self.role_model_info:unmarshal(os)
  self.duty = os:unmarshalInt32()
  self.join_time = os:unmarshalInt32()
end
return CorpsMemberInfo
