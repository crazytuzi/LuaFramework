local SMountsUnBattleSuccess = class("SMountsUnBattleSuccess")
SMountsUnBattleSuccess.TYPEID = 12606220
function SMountsUnBattleSuccess:ctor(cell_id)
  self.id = 12606220
  self.cell_id = cell_id or nil
end
function SMountsUnBattleSuccess:marshal(os)
  os:marshalInt32(self.cell_id)
end
function SMountsUnBattleSuccess:unmarshal(os)
  self.cell_id = os:unmarshalInt32()
end
function SMountsUnBattleSuccess:sizepolicy(size)
  return size <= 65535
end
return SMountsUnBattleSuccess
