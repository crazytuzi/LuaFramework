local ModelInfo = require("netio.protocol.mzm.gsp.pubdata.ModelInfo")
local SMemberModelChangedBrd = class("SMemberModelChangedBrd")
SMemberModelChangedBrd.TYPEID = 12588333
function SMemberModelChangedBrd:ctor(roleid, model)
  self.id = 12588333
  self.roleid = roleid or nil
  self.model = model or ModelInfo.new()
end
function SMemberModelChangedBrd:marshal(os)
  os:marshalInt64(self.roleid)
  self.model:marshal(os)
end
function SMemberModelChangedBrd:unmarshal(os)
  self.roleid = os:unmarshalInt64()
  self.model = ModelInfo.new()
  self.model:unmarshal(os)
end
function SMemberModelChangedBrd:sizepolicy(size)
  return size <= 65535
end
return SMemberModelChangedBrd
