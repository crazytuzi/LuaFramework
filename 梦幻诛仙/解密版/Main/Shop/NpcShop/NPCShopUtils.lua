local Lplus = require("Lplus")
local NPCShopUtils = Lplus.Class("NPCShopUtils")
local EquipUtils = require("Main.Equip.EquipUtils")
local def = NPCShopUtils.define
def.static("string", "userdata").FillIcon = function(iconId, uiSprite)
  local atlas = NPCShopUtils.GetAtlasName()
  GameUtil.AsyncLoad(atlas, function(obj)
    local atlas = obj:GetComponent("UIAtlas")
    uiSprite:set_atlas(atlas)
    uiSprite:set_spriteName(iconId)
  end)
end
def.static("=>", "string").GetAtlasName = function()
  local atlasName = RESPATH.BAGATLAS
  return atlasName
end
def.static("number", "=>", "number").GetItemSellNum = function(itemId)
  local sell = 0
  local record = DynamicData.GetRecord(CFG_PATH.DATA_ITEM_PRICE_CFG, itemId)
  if record ~= nil then
    sell = record:GetIntValue("shopSilverNum")
  end
  return sell
end
def.static("number", "=>", "number").GetEquipMaterialItemLevel = function(itemId)
  local level = 0
  local tbl = EquipUtils.GetEquipMakeMaterialInfo(itemId)
  if tbl ~= nil then
    level = tbl.materialLevel
  end
  return level
end
def.static("number", "=>", "boolean").IsItemId = function(itemId)
  local record = require("Main.Item.ItemUtils").GetItemBase(itemId)
  if nil ~= record then
    return true
  else
    return false
  end
end
def.static("number", "=>", "string").GetMedecineItemDesc = function(itemId)
  local record = DynamicData.GetRecord(CFG_PATH.DATA_DRUG_ITEM_CFG, itemId)
  if record == nil then
    return ""
  end
  local itemDesc = record:GetStringValue("itemdesc")
  return itemDesc
end
NPCShopUtils.Commit()
return NPCShopUtils
