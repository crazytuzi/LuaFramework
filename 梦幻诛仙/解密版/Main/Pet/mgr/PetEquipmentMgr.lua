local Lplus = require("Lplus")
local PetEquipmentMgr = Lplus.Class("PetEquipmentMgr")
local def = PetEquipmentMgr.define
local PetData = require("Main.Pet.data.PetData")
local PetMgr = require("Main.Pet.mgr.PetMgr")
local instance
def.const("table").EquipmentSiftID = {
  [PetData.PetEquipmentType.EQUIP_NECKLACE] = 210202003,
  [PetData.PetEquipmentType.EQUIP_HELMET] = 210202004,
  [PetData.PetEquipmentType.EQUIP_AMULET] = 210202005
}
def.static("=>", PetEquipmentMgr).Instance = function()
  if instance == nil then
    instance = PetEquipmentMgr()
    instance:Init()
  end
  return instance
end
def.method().Init = function(self)
end
def.method("number", "=>", "table").GetEquipmentSourceItemIdList = function(self, equipType)
  local itemIdList = {}
  local cfg = self:GetEquipmentFilterCfg(equipType)
  for i, siftCfg in ipairs(cfg.siftCfgs) do
    local itemId = siftCfg.idvalue
    table.insert(itemIdList, itemId)
  end
  return itemIdList
end
def.method("number", "=>", "table").GetEquipmentFilterCfg = function(self, equipType)
  local ItemUtils = require("Main.Item.ItemUtils")
  local siftId = PetEquipmentMgr.EquipmentSiftID[equipType]
  local filterCfg = ItemUtils.GetItemFilterCfg(siftId)
  return filterCfg
end
def.method("number", "number").MergePetEquipReq = function(self, itemKey1, itemKey2)
  self:C2S_CMergePetEquipReq(itemKey1, itemKey2)
end
def.method("number", "boolean", "number", "userdata").AmuletRefreshReq = function(self, itemKey, isNeedYuanBao, needYuanBaoNumber, petId)
  self:C2S_CAmuletRefreshReq(itemKey, isNeedYuanBao, needYuanBaoNumber, petId)
end
def.method("number", "number").C2S_CMergePetEquipReq = function(self, itemKey1, itemKey2)
  local p = require("netio.protocol.mzm.gsp.pet.CMergePetEquipReq").new(itemKey1, itemKey2)
  gmodule.network.sendProtocol(p)
  print(string.format("sendProtocol CMergePetEquipReq(%d, %d)", itemKey1, itemKey2))
end
def.method("number", "boolean", "number", "userdata").C2S_CAmuletRefreshReq = function(self, itemKey, isNeedYuanBao, needYuanBaoNum, petId)
  local costType = 0
  if isNeedYuanBao then
    costType = 1
  end
  local ItemModule = require("Main.Item.ItemModule")
  local allYuanBao = ItemModule.Instance():GetAllYuanBao()
  local p = require("netio.protocol.mzm.gsp.pet.CAmuletRefreshReq").new(itemKey, costType, needYuanBaoNum, allYuanBao, petId)
  gmodule.network.sendProtocol(p)
  print(string.format("sendProtocol CAmuletRefreshReq(%d)", itemKey))
end
return PetEquipmentMgr.Commit()
