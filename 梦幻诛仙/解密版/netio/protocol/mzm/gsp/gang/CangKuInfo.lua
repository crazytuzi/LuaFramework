local OctetsStream = require("netio.OctetsStream")
local CangKuInfo = class("CangKuInfo")
function CangKuInfo:ctor(level, levelUpEndTime, totalFuli, avaliableFuli, avaliableLiHe)
  self.level = level or nil
  self.levelUpEndTime = levelUpEndTime or nil
  self.totalFuli = totalFuli or nil
  self.avaliableFuli = avaliableFuli or nil
  self.avaliableLiHe = avaliableLiHe or nil
end
function CangKuInfo:marshal(os)
  os:marshalInt32(self.level)
  os:marshalInt32(self.levelUpEndTime)
  os:marshalInt32(self.totalFuli)
  os:marshalInt32(self.avaliableFuli)
  os:marshalInt32(self.avaliableLiHe)
end
function CangKuInfo:unmarshal(os)
  self.level = os:unmarshalInt32()
  self.levelUpEndTime = os:unmarshalInt32()
  self.totalFuli = os:unmarshalInt32()
  self.avaliableFuli = os:unmarshalInt32()
  self.avaliableLiHe = os:unmarshalInt32()
end
return CangKuInfo
