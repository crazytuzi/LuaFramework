local Lplus = require("Lplus")
local ItemModule = Lplus.ForwardDeclare("ItemModule")
local ECPanelBase = require("GUI.ECPanelBase")
local ItemUtils = require("Main.Item.ItemUtils")
local GUIUtils = require("GUI.GUIUtils")
local OperationTaskItemUse = require("Main.Item.Operations.OperationTaskItemUse")
local ItemTipsMgr = require("Main.Item.ItemTipsMgr")
local Vector = require("Types.Vector")
local TaskEasyUseDlg = Lplus.Extend(ECPanelBase, "TaskEasyUseDlg")
local def = TaskEasyUseDlg.define
local _inst
def.static("table").ShowTaskEasyUse = function(taskItem)
  if _inst ~= nil then
    _inst:DestroyPanel()
  else
    _inst = TaskEasyUseDlg()
  end
  _inst.taskItem = taskItem
  _inst:CreatePanel(RESPATH.DLG_EASYUSE, 0)
end
def.field("table").taskItem = nil
def.override().OnCreate = function(self)
  self:UpdateInfo()
end
def.method().UpdateInfo = function(self)
  local itemBase = ItemUtils.GetItemBase(self.taskItem.itemID)
  local title = self.m_panel:FindDirect("Img_Bg/Label_Name"):GetComponent("UILabel")
  title:set_text(itemBase.name)
  local buttonLabel = self.m_panel:FindDirect("Img_Bg/Btn_Use/Label_Use"):GetComponent("UILabel")
  buttonLabel:set_text(textRes.Item[8101])
  local uiTexture = self.m_panel:FindDirect("Img_Bg/Img_Item/Icon_Item"):GetComponent("UITexture")
  GUIUtils.FillIcon(uiTexture, itemBase.icon)
  local buttonSprite = self.m_panel:FindDirect("Img_Bg/Btn_Use")
  GUIUtils.SetLightEffect(buttonSprite, GUIUtils.Light.Square)
end
def.method("string").onClick = function(self, id)
  if id == "Btn_Close" then
    self:DestroyPanel()
    self = nil
  elseif id == "Btn_Use" then
    local ope = OperationTaskItemUse()
    ope:Operate(0, 0, nil, self.taskItem.param)
    self:DestroyPanel()
    self = nil
  elseif id == "Img_Item" then
    local source = self.m_panel:FindDirect("Img_Bg/Img_Item")
    local position = source:get_position()
    local screenPos = WorldPosToScreen(position.x, position.y)
    local sprite = self.m_panel:FindDirect("Img_Bg/Img_Item"):GetComponent("UISprite")
    ItemTipsMgr.Instance():ShowTaskItemTip(self.taskItem.itemID, screenPos.x, screenPos.y, sprite:get_width(), sprite:get_height(), 0, false, false)
  end
end
TaskEasyUseDlg.Commit()
return TaskEasyUseDlg
