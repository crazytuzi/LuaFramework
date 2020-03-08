local Lplus = require("Lplus")
local OperationBase = require("Main.Item.Operations.OperationBase")
local ItemTipsMgr = require("Main.Item.ItemTipsMgr")
local ItemModule = require("Main.Item.ItemModule")
local CatModule = require("Main.Cat.CatModule")
local OperationCat = Lplus.Extend(OperationBase, "OperationCat")
local def = OperationCat.define
def.override("number", "table", "table", "=>", "boolean").CanDispaly = function(self, source, item, itemBase)
  local ItemType = require("consts.mzm.gsp.item.confbean.ItemType")
  if source == ItemTipsMgr.Source.Bag and itemBase.itemType == ItemType.CAT_ITEM then
    return true
  else
    return false
  end
end
def.override("=>", "string").GetOperationName = function(self)
  return textRes.Item[8101]
end
def.override("number", "number", "userdata", "table", "=>", "boolean").Operate = function(self, bagId, itemKey, m_panel, context)
  local bOpen = CatModule.Instance():IsFeatureOpen()
  if not bOpen then
    local featureType = CatModule.Instance():GetFeatureType()
    local moduleName = textRes.IDIP.PlayTypeName[featureType]
    if moduleName then
      local tip = string.format(textRes.IDIP[7], moduleName)
      Toast(tip)
    end
    return true
  end
  local item = ItemModule.Instance():GetItemByBagIdAndItemKey(bagId, itemKey)
  if item == nil then
    return
  end
  local p = require("netio.protocol.mzm.gsp.item.CUseCatItem").new(item.uuid[1])
  gmodule.network.sendProtocol(p)
  return true
end
OperationCat.Commit()
return OperationCat
