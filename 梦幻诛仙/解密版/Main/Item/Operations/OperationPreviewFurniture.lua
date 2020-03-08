local Lplus = require("Lplus")
local OperationBase = require("Main.Item.Operations.OperationBase")
local ItemTipsMgr = require("Main.Item.ItemTipsMgr")
local OperationPreviewFurniture = Lplus.Extend(OperationBase, "OperationPreviewFurniture")
local FurnitureBag = require("Main.Homeland.FurnitureBag")
local def = OperationPreviewFurniture.define
def.field("table").m_item = nil
def.override("number", "table", "table", "=>", "boolean").CanDispaly = function(self, source, item, itemBase)
  self.m_item = item
  local haveNum = FurnitureBag.Instance():GetFurnitureNumbersById(self.m_item.id)
  if source == ItemTipsMgr.Source.FurnitureBag and haveNum == 0 then
    return true
  else
    return false
  end
end
def.override("=>", "string").GetOperationName = function(self)
  return textRes.Item[8134]
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
  if furniture then
    furnitureUUID = furniture.uuid
  else
    furnitureUUID = Int64.new(0)
  end
  local ItemUtils = require("Main.Item.ItemUtils")
  local FurniturePosEnum = require("consts.mzm.gsp.item.confbean.FurniturePosEnum")
  local HomelandUtils = require("Main.Homeland.HomelandUtils")
  local furnitureCfg = ItemUtils.GetFurnitureCfg(furnitureId)
  local placeLayer = furnitureCfg and furnitureCfg.layer
  if placeLayer == FurniturePosEnum.WALL then
    HomelandUtils.SetWallpaperById(furnitureId)
  elseif placeLayer == FurniturePosEnum.FLOOR_TILE then
    HomelandUtils.SetFloorTitleById(furnitureId)
  elseif placeLayer == FurniturePosEnum.COURT_YARD_FENCE then
    HomelandUtils.SetCourtyardFenceById(furnitureId)
  elseif placeLayer == FurniturePosEnum.COURT_YARD_TERRAIN then
    HomelandUtils.SetCourtyardGroundById(furnitureId)
  elseif placeLayer == FurniturePosEnum.COURT_YARD_ROAD then
    HomelandUtils.SetCourtyardRoadById(furnitureId)
  else
    gmodule.moduleMgr:GetModule(ModuleId.HOMELAND):LoadAndStartEditFurniture(furnitureId, furnitureUUID)
  end
  return true
end
OperationPreviewFurniture.Commit()
return OperationPreviewFurniture
