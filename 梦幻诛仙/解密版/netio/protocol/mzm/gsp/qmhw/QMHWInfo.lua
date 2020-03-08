local OctetsStream = require("netio.OctetsStream")
local QMHWInfo = class("QMHWInfo")
function QMHWInfo:ctor(score, winCount, loseCount, continueWinCount)
  self.score = score or nil
  self.winCount = winCount or nil
  self.loseCount = loseCount or nil
  self.continueWinCount = continueWinCount or nil
end
function QMHWInfo:marshal(os)
  os:marshalInt32(self.score)
  os:marshalInt32(self.winCount)
  os:marshalInt32(self.loseCount)
  os:marshalInt32(self.continueWinCount)
end
function QMHWInfo:unmarshal(os)
  self.score = os:unmarshalInt32()
  self.winCount = os:unmarshalInt32()
  self.loseCount = os:unmarshalInt32()
  self.continueWinCount = os:unmarshalInt32()
end
return QMHWInfo
