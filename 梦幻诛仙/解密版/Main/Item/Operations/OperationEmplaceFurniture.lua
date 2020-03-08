local Lplus = require("Lplus")
local OperationBase = require("Main.Item.Operations.OperationBase")
local ItemTipsMgr = require("Main.Item.ItemTipsMgr")
local OperationEmplaceFurniture = Lplus.Extend(OperationBase, "OperationEmplaceFurniture")
local FurnitureBag = require("Main.Homeland.FurnitureBag")
local HomelandUtils = require("Main.Homeland.HomelandUtils")
local def = OperationEmplaceFurniture.define
def.field("table").m_item = nil
def.override("number", "table", "table", "=>", "boolean").CanDispaly = function(self, source, item, itemBase)
  self.m_item = item
  local haveNum = FurnitureBag.Instance():GetFurnitureNumbersById(self.m_item.id)
  if source == ItemTipsMgr.Source.FurnitureBag and haveNum > 0 then
    return true
  else
    return false
  end
end
def.override("=>", "string").GetOperationName = function(self)
  local text = textRes.Item[8132]
  if self.m_item and not HomelandUtils.IsEditableFurniture(self.m_item.id) then
    text = textRes.Item[8135]
  end
  return text
end
def.override("number", "number", "userdata", "table", "=>", "boolean").Operate = function(self, bagId, itemKey, m_panel, context)
  local item = self.m_item
  if item == nil then
    return
  end
  local FurnitureBag = require("Main.Homeland.FurnitureBag")
  local furnitures = FurnitureBag.Instance():GetFurnituresById(item.id)
  local furnitureId = item.id
  local furnitureUUID
  local _, furniture = next(furnitures)
  if furniture == nil then
    return
  end
  furnitureUUID = furniture.uuid
  local ItemUtils = require("Main.Item.ItemUtils")
  local FurniturePosEnum = require("consts.mzm.gsp.item.confbean.FurniturePosEnum")
  local HomelandProtocol = require("Main.Homeland.HomelandProtocol")
  local furnitureCfg = ItemUtils.GetFurnitureCfg(furnitureId)
  local placeLayer = furnitureCfg and furnitureCfg.layer
  if placeLayer == FurniturePosEnum.WALL then
    HomelandProtocol.CChangeWallReq(furnitureId, furnitureUUID)
  elseif placeLayer == FurniturePosEnum.FLOOR_TILE then
    HomelandProtocol.CChangeFloortieReq(furnitureId, furnitureUUID)
  elseif placeLayer == FurniturePosEnum.COURT_YARD_FENCE or placeLayer == FurniturePosEnum.COURT_YARD_TERRAIN or placeLayer == FurniturePosEnum.COURT_YARD_ROAD then
    HomelandProtocol.CChangeCourtYardFurnitureReq(furnitureId, furnitureUUID)
  else
    gmodule.moduleMgr:GetModule(ModuleId.HOMELAND):LoadAndStartEditFurniture(furnitureId, furnitureUUID)
  end
  return true
end
OperationEmplaceFurniture.Commit()
return OperationEmplaceFurniture
