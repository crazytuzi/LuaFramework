local GangHelp = require("netio.protocol.mzm.gsp.gang.GangHelp")
local SSyncGangHelpAdd = class("SSyncGangHelpAdd")
SSyncGangHelpAdd.TYPEID = 793383
function SSyncGangHelpAdd:ctor(newHelper)
  self.id = 793383
  self.newHelper = newHelper or GangHelp.new()
end
function SSyncGangHelpAdd:marshal(os)
  self.newHelper:marshal(os)
end
function SSyncGangHelpAdd:unmarshal(os)
  self.newHelper = GangHelp.new()
  self.newHelper:unmarshal(os)
end
function SSyncGangHelpAdd:sizepolicy(size)
  return size <= 65535
end
return SSyncGangHelpAdd
