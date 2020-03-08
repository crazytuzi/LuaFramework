local Lplus = require("Lplus")
local OperationBase = require("Main.Item.Operations.OperationBase")
local ItemTipsMgr = require("Main.Item.ItemTipsMgr")
local CommonConfirmDlg = require("GUI.CommonConfirmDlg")
local OperationUseSpaceDecoration = Lplus.Extend(OperationBase, "OperationUseSpaceDecoration")
local def = OperationUseSpaceDecoration.define
def.field("number").m_source = 0
def.override("number", "table", "table", "=>", "boolean").CanDispaly = function(self, source, item, itemBase)
  local ItemType = require("consts.mzm.gsp.item.confbean.ItemType")
  warn("source", source, ItemTipsMgr.Source.SpaceDecoPanel)
  if (source == ItemTipsMgr.Source.Bag or source == ItemTipsMgr.Source.SpaceDecoPanel) and itemBase.itemType == ItemType.FRIENDS_CIRCLE_ITEM then
    self.m_source = source
    return true
  else
    return false
  end
end
def.override("=>", "string").GetOperationName = function(self)
  return textRes.Item[8101]
end
def.override("number", "number", "userdata", "table", "=>", "boolean").Operate = function(self, bagId, itemKey, m_panel, context)
  local item = gmodule.moduleMgr:GetModule(ModuleId.ITEM):GetItemByBagIdAndItemKey(bagId, itemKey)
  if item == nil then
    return true
  end
  local item_uuid = item.uuid[1]
  local SocialSpaceModule = require("Main.SocialSpace.SocialSpaceModule")
  local spaceModule = SocialSpaceModule.Instance()
  if not spaceModule:IsDecorateFeatureOpen(true) then
    return true
  end
  if spaceModule:HasDecorationQueryByItemId(item.id) then
    Toast(textRes.SocialSpace.SFriendsCircleNormalRes[14])
    return true
  end
  spaceModule:UseDecorateItem(item_uuid)
  if self.m_source == ItemTipsMgr.Source.Bag then
    local function onSpacePanelReady(panel)
      require("Main.SocialSpace.ui.SpaceDecorationPanel").Instance():ShowPanel(panel, {
        targetItemId = item.id
      })
    end
    spaceModule:EnterSpaceWithParams({onPanelReady = onSpacePanelReady})
  end
  return true
end
OperationUseSpaceDecoration.Commit()
return OperationUseSpaceDecoration
