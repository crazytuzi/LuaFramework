local SFlopLotteryContinue = class("SFlopLotteryContinue")
SFlopLotteryContinue.TYPEID = 12618502
function SFlopLotteryContinue:ctor(uid, flopLotteryMainCfgId, flopLotteryResultList)
  self.id = 12618502
  self.uid = uid or nil
  self.flopLotteryMainCfgId = flopLotteryMainCfgId or nil
  self.flopLotteryResultList = flopLotteryResultList or {}
end
function SFlopLotteryContinue:marshal(os)
  os:marshalInt64(self.uid)
  os:marshalInt32(self.flopLotteryMainCfgId)
  os:marshalCompactUInt32(table.getn(self.flopLotteryResultList))
  for _, v in ipairs(self.flopLotteryResultList) do
    v:marshal(os)
  end
end
function SFlopLotteryContinue:unmarshal(os)
  self.uid = os:unmarshalInt64()
  self.flopLotteryMainCfgId = os:unmarshalInt32()
  for _size_ = os:unmarshalCompactUInt32(), 1, -1 do
    local BeanClazz = require("netio.protocol.mzm.gsp.floplottery.FlopLotteryResult")
    local v = BeanClazz.new()
    v:unmarshal(os)
    table.insert(self.flopLotteryResultList, v)
  end
end
function SFlopLotteryContinue:sizepolicy(size)
  return size <= 65535
end
return SFlopLotteryContinue
