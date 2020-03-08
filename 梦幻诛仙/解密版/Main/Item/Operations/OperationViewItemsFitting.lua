local Lplus = require("Lplus")
local OperationBase = require("Main.Item.Operations.OperationBase")
local ItemTipsMgr = require("Main.Item.ItemTipsMgr")
local ItemModule = require("Main.Item.ItemModule")
local ItemUtils = require("Main.Item.ItemUtils")
local FittingRoomPanel = require("Main.Item.ui.FittingRoomPanel")
local OperationViewItemsFitting = Lplus.Extend(OperationBase, "OperationViewItemsFitting")
local def = OperationViewItemsFitting.define
def.field("number").mItemId = 0
def.field("number").mItemType = 0
def.field("table").mExtInfo = nil
def.override("number", "table", "table", "=>", "boolean").CanDispaly = function(self, source, item, itemBase)
  if source == ItemTipsMgr.Source.ChatOther then
    warn("ItemTipsMgr.Source.ChatOther....")
    if ItemUtils.IsShowViewItem(itemBase.itemType) then
      self.mItemId = itemBase.itemid
      self.mItemType = itemBase.itemType
      self.mExtInfo = item
      return true
    end
  end
  return false
end
def.override("=>", "string").GetOperationName = function(self)
  return textRes.Item[9500]
end
def.override("number", "number", "userdata", "table", "=>", "boolean").Operate = function(self, bagId, itemKey, m_panel, context)
  local panelinstance = FittingRoomPanel.Instance()
  panelinstance:ShowPanel(self.mItemType, self.mItemId, self.mExtInfo)
  if m_panel then
    m_panel:Destroy()
  end
  return true
end
OperationViewItemsFitting.Commit()
return OperationViewItemsFitting
