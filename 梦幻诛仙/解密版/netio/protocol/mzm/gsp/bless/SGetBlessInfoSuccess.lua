local BlessInfo = require("netio.protocol.mzm.gsp.bless.BlessInfo")
local SGetBlessInfoSuccess = class("SGetBlessInfoSuccess")
SGetBlessInfoSuccess.TYPEID = 12614658
function SGetBlessInfoSuccess:ctor(activity_cfgid, bless_info)
  self.id = 12614658
  self.activity_cfgid = activity_cfgid or nil
  self.bless_info = bless_info or BlessInfo.new()
end
function SGetBlessInfoSuccess:marshal(os)
  os:marshalInt32(self.activity_cfgid)
  self.bless_info:marshal(os)
end
function SGetBlessInfoSuccess:unmarshal(os)
  self.activity_cfgid = os:unmarshalInt32()
  self.bless_info = BlessInfo.new()
  self.bless_info:unmarshal(os)
end
function SGetBlessInfoSuccess:sizepolicy(size)
  return size <= 65535
end
return SGetBlessInfoSuccess
