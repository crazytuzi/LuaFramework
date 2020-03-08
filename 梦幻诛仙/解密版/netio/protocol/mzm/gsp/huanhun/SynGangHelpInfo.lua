local GangHelpInfo = require("netio.protocol.mzm.gsp.huanhun.GangHelpInfo")
local SynGangHelpInfo = class("SynGangHelpInfo")
SynGangHelpInfo.TYPEID = 12584467
function SynGangHelpInfo:ctor(gangHelpInfo)
  self.id = 12584467
  self.gangHelpInfo = gangHelpInfo or GangHelpInfo.new()
end
function SynGangHelpInfo:marshal(os)
  self.gangHelpInfo:marshal(os)
end
function SynGangHelpInfo:unmarshal(os)
  self.gangHelpInfo = GangHelpInfo.new()
  self.gangHelpInfo:unmarshal(os)
end
function SynGangHelpInfo:sizepolicy(size)
  return size <= 65535
end
return SynGangHelpInfo
