local BattleMountsInfo = require("netio.protocol.mzm.gsp.mounts.BattleMountsInfo")
local SMountsReplaceProtectPetSuccess = class("SMountsReplaceProtectPetSuccess")
SMountsReplaceProtectPetSuccess.TYPEID = 12606246
function SMountsReplaceProtectPetSuccess:ctor(cell_id, protect_index, battle_mounts_info)
  self.id = 12606246
  self.cell_id = cell_id or nil
  self.protect_index = protect_index or nil
  self.battle_mounts_info = battle_mounts_info or BattleMountsInfo.new()
end
function SMountsReplaceProtectPetSuccess:marshal(os)
  os:marshalInt32(self.cell_id)
  os:marshalInt32(self.protect_index)
  self.battle_mounts_info:marshal(os)
end
function SMountsReplaceProtectPetSuccess:unmarshal(os)
  self.cell_id = os:unmarshalInt32()
  self.protect_index = os:unmarshalInt32()
  self.battle_mounts_info = BattleMountsInfo.new()
  self.battle_mounts_info:unmarshal(os)
end
function SMountsReplaceProtectPetSuccess:sizepolicy(size)
  return size <= 65535
end
return SMountsReplaceProtectPetSuccess
