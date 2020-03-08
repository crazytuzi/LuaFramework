local FactionMakeUpInfo = require("netio.protocol.mzm.gsp.makeup.FactionMakeUpInfo")
local SStartMakeUpQuestion = class("SStartMakeUpQuestion")
SStartMakeUpQuestion.TYPEID = 12625921
function SStartMakeUpQuestion:ctor(makeupInfo)
  self.id = 12625921
  self.makeupInfo = makeupInfo or FactionMakeUpInfo.new()
end
function SStartMakeUpQuestion:marshal(os)
  self.makeupInfo:marshal(os)
end
function SStartMakeUpQuestion:unmarshal(os)
  self.makeupInfo = FactionMakeUpInfo.new()
  self.makeupInfo:unmarshal(os)
end
function SStartMakeUpQuestion:sizepolicy(size)
  return size <= 65535
end
return SStartMakeUpQuestion
