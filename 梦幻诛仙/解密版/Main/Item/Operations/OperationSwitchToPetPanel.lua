local Lplus = require("Lplus")
local OperationBase = require("Main.Item.Operations.OperationBase")
local ItemTipsMgr = require("Main.Item.ItemTipsMgr")
local CommonConfirmDlg = require("GUI.CommonConfirmDlg")
local ItemInfo = require("netio.protocol.mzm.gsp.item.ItemInfo")
local ItemModule = require("Main.Item.ItemModule")
local MathHelper = require("Common.MathHelper")
local OperationSwitchToPetPanel = Lplus.Extend(OperationBase, "OperationSwitchToPetPanel")
local ItemType = require("consts.mzm.gsp.item.confbean.ItemType")
local PetUIMgr = require("Main.Pet.PetUIMgr")
local def = OperationSwitchToPetPanel.define
local Node = require("Main.Pet.ui.PetPanelNodeEnum")
local SubNode = Node.SubNode
def.const("table").PetPanelNode = Node
def.const("table").ItemTypeSwitchToNode = {
  [ItemType.PET_EQUIP] = {
    nodeId = Node.BasicNode,
    subNodeId = SubNode.Equip
  },
  [ItemType.PET_SKILL_BOOK] = {
    nodeId = Node.SkillNode,
    uiPath = PetUIMgr.UIPath.LearnSkillBtn
  },
  [ItemType.PET_EXP_ITEM] = {
    nodeId = Node.BasicNode,
    uiPath = PetUIMgr.UIPath.AddExpBtn
  },
  [ItemType.PET_LIFE_ITEM] = {
    nodeId = Node.SkillNode,
    uiPath = PetUIMgr.UIPath.AddLifeBtn
  },
  [ItemType.PET_DECORATE_ITEM] = {
    nodeId = Node.BasicNode,
    subNodeId = SubNode.Equip,
    uiPath = PetUIMgr.UIPath.DecorateBtn
  },
  [ItemType.PET_RESET_ITEM] = {
    nodeId = Node.BasicNode
  },
  [ItemType.PET_GROW_ITEM] = {
    nodeId = Node.SkillNode,
    uiPath = PetUIMgr.UIPath.AddGrowValueBtn
  },
  [ItemType.PET_HUASHENG_ITEM] = {
    nodeId = Node.HuaShengNode
  },
  [ItemType.PET_LIANGU_ITEM] = {
    nodeId = Node.SkillNode,
    uiPath = PetUIMgr.UIPath.LianGuBtn
  },
  [ItemType.PET_PUTONG_FANSHENG_ITEM] = {
    nodeId = Node.FanShengNode,
    uiPath = PetUIMgr.UIPath.FanShengBtn
  },
  [ItemType.PET_HIGHTLEVEL_FANSHENG_ITEM] = {
    nodeId = Node.FanShengNode,
    uiPath = PetUIMgr.UIPath.FanShengBtn
  },
  [ItemType.PET_REMEBER_SKILL_ITEM] = {
    nodeId = Node.SkillNode
  },
  [ItemType.PET_CHANGEMODEL_COMMONCOST_ITEM] = {
    nodeId = Node.BasicNode,
    subNodeId = SubNode.Equip,
    uiPath = PetUIMgr.UIPath.ChangeModelBtn
  },
  [ItemType.PET_CHANGEMODEL_SHENSHOUCOST_ITEM] = {
    nodeId = Node.BasicNode,
    subNodeId = SubNode.Equip,
    uiPath = PetUIMgr.UIPath.ChangeModelBtn
  }
}
def.field("number").itemType = -1
def.field("number").source = -1
def.override("number", "table", "table", "=>", "boolean").CanDispaly = function(self, source, item, itemBase)
  self.itemType = itemBase.itemType
  self.source = source
  if source == ItemTipsMgr.Source.Bag and self:NeedToSwitchToPetPanel(itemBase.itemType) then
    return true
  else
    return false
  end
end
def.override("=>", "string").GetOperationName = function(self)
  return textRes.Item[8101]
end
def.override("number", "number", "userdata", "table", "=>", "boolean").Operate = function(self, bagId, itemKey, m_panel, context)
  if self.itemType == ItemType.PET_HUASHENG_ITEM and not gmodule.moduleMgr:GetModule(ModuleId.PET):CheckPetHuaShengUnlockOK() then
    return true
  end
  local nodeId = OperationSwitchToPetPanel.ItemTypeSwitchToNode[self.itemType].nodeId
  local subNodeId = OperationSwitchToPetPanel.ItemTypeSwitchToNode[self.itemType].subNodeId
  local uiPath = OperationSwitchToPetPanel.ItemTypeSwitchToNode[self.itemType].uiPath
  local params = {}
  params.nodeId = nodeId
  params.subNodeId = subNodeId
  params.uiPath = uiPath
  Event.DispatchEvent(ModuleId.PET, gmodule.notifyId.Pet.OPEN_PET_PANEL_REQ, params)
  return true
end
def.method("number", "=>", "boolean").NeedToSwitchToPetPanel = function(self, itemType)
  return OperationSwitchToPetPanel.ItemTypeSwitchToNode[itemType] ~= nil
end
OperationSwitchToPetPanel.Commit()
return OperationSwitchToPetPanel
