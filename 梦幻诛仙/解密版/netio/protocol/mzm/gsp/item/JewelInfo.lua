local OctetsStream = require("netio.OctetsStream")
local JewelInfo = class("JewelInfo")
function JewelInfo:ctor(jewelCfgId)
  self.jewelCfgId = jewelCfgId or nil
end
function JewelInfo:marshal(os)
  os:marshalInt32(self.jewelCfgId)
end
function JewelInfo:unmarshal(os)
  self.jewelCfgId = os:unmarshalInt32()
end
return JewelInfo
