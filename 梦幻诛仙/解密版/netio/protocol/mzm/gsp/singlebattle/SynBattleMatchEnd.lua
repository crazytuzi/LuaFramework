local SynBattleMatchEnd = class("SynBattleMatchEnd")
SynBattleMatchEnd.TYPEID = 12621605
SynBattleMatchEnd.REASON_TIME_OUT = 1
SynBattleMatchEnd.REASON_RESOURCE_DIFF = 2
SynBattleMatchEnd.REASON_ALL_LEAVE = 3
SynBattleMatchEnd.REASON_GM = 4
function SynBattleMatchEnd:ctor(reason)
  self.id = 12621605
  self.reason = reason or nil
end
function SynBattleMatchEnd:marshal(os)
  os:marshalInt32(self.reason)
end
function SynBattleMatchEnd:unmarshal(os)
  self.reason = os:unmarshalInt32()
end
function SynBattleMatchEnd:sizepolicy(size)
  return size <= 65535
end
return SynBattleMatchEnd
