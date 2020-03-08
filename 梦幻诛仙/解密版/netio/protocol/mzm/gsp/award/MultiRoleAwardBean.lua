local OctetsStream = require("netio.OctetsStream")
local MultiRoleAwardBean = class("MultiRoleAwardBean")
function MultiRoleAwardBean:ctor(id, count)
  self.id = id or nil
  self.count = count or nil
end
function MultiRoleAwardBean:marshal(os)
  os:marshalInt32(self.id)
  os:marshalInt32(self.count)
end
function MultiRoleAwardBean:unmarshal(os)
  self.id = os:unmarshalInt32()
  self.count = os:unmarshalInt32()
end
return MultiRoleAwardBean
