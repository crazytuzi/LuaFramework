local FlopLotteryResult = require("netio.protocol.mzm.gsp.floplottery.FlopLotteryResult")
local SFlopLotteryResult = class("SFlopLotteryResult")
SFlopLotteryResult.TYPEID = 12618497
function SFlopLotteryResult:ctor(uid, flopLotteryResult)
  self.id = 12618497
  self.uid = uid or nil
  self.flopLotteryResult = flopLotteryResult or FlopLotteryResult.new()
end
function SFlopLotteryResult:marshal(os)
  os:marshalInt64(self.uid)
  self.flopLotteryResult:marshal(os)
end
function SFlopLotteryResult:unmarshal(os)
  self.uid = os:unmarshalInt64()
  self.flopLotteryResult = FlopLotteryResult.new()
  self.flopLotteryResult:unmarshal(os)
end
function SFlopLotteryResult:sizepolicy(size)
  return size <= 65535
end
return SFlopLotteryResult
