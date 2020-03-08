local OctetsStream = require("netio.OctetsStream")
local ZhenfaBean = class("ZhenfaBean")
function ZhenfaBean:ctor(zhenfaId, level, exp)
  self.zhenfaId = zhenfaId or nil
  self.level = level or nil
  self.exp = exp or nil
end
function ZhenfaBean:marshal(os)
  os:marshalInt32(self.zhenfaId)
  os:marshalInt32(self.level)
  os:marshalInt32(self.exp)
end
function ZhenfaBean:unmarshal(os)
  self.zhenfaId = os:unmarshalInt32()
  self.level = os:unmarshalInt32()
  self.exp = os:unmarshalInt32()
end
return ZhenfaBean
