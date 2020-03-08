local SSynBattleStage = class("SSynBattleStage")
SSynBattleStage.TYPEID = 12621572
SSynBattleStage.STAGE_PREPARE = 1
SSynBattleStage.STAGE_PLAY = 2
SSynBattleStage.STAGE_WAIT_CLEAN = 3
SSynBattleStage.STAGE_CLEAN = 4
function SSynBattleStage:ctor(stage)
  self.id = 12621572
  self.stage = stage or nil
end
function SSynBattleStage:marshal(os)
  os:marshalInt32(self.stage)
end
function SSynBattleStage:unmarshal(os)
  self.stage = os:unmarshalInt32()
end
function SSynBattleStage:sizepolicy(size)
  return size <= 65535
end
return SSynBattleStage
