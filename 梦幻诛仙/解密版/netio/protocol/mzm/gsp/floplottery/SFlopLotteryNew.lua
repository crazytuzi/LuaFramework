local SFlopLotteryNew = class("SFlopLotteryNew")
SFlopLotteryNew.TYPEID = 12618500
function SFlopLotteryNew:ctor(uid, flopLotteryMainCfgId)
  self.id = 12618500
  self.uid = uid or nil
  self.flopLotteryMainCfgId = flopLotteryMainCfgId or nil
end
function SFlopLotteryNew:marshal(os)
  os:marshalInt64(self.uid)
  os:marshalInt32(self.flopLotteryMainCfgId)
end
function SFlopLotteryNew:unmarshal(os)
  self.uid = os:unmarshalInt64()
  self.flopLotteryMainCfgId = os:unmarshalInt32()
end
function SFlopLotteryNew:sizepolicy(size)
  return size <= 65535
end
return SFlopLotteryNew
