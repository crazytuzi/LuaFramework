local Lplus = require("Lplus")
local NPCModule = Lplus.ForwardDeclare("NPCModule")
local ECGUIMan = require("GUI.ECGUIMan")
local Vector = require("Types.Vector")
local ECPanelBase = require("GUI.ECPanelBase")
local HuanhunNext = Lplus.Extend(ECPanelBase, "HuanhunNext")
local def = HuanhunNext.define
local inst
local ItemUtils = require("Main.Item.ItemUtils")
local Vector = require("Types.Vector")
local TimeCfgUtils = require("Main.Common.TimeCfgUtils")
local GUIUtils = require("GUI.GUIUtils")
local ItemTipsMgr = require("Main.Item.ItemTipsMgr")
local ItemTips = require("Main.Item.ui.ItemTips")
local ActivityInterface = require("Main.activity.ActivityInterface")
local activityInterface = ActivityInterface.Instance()
def.static("=>", HuanhunNext).Instance = function()
  if inst == nil then
    inst = HuanhunNext()
    inst:Init()
  end
  return inst
end
def.method().Init = function(self)
  self.m_TrigGC = true
end
def.method().ShowDlg = function(self)
  if self.m_panel == nil or self.m_panel.isnil then
    self:CreatePanel(RESPATH.PREFAB_UI_HUANHUN_NEXT, 2)
    self:SetModal(true)
  end
end
def.method().HideDlg = function(self)
  if self.m_panel then
    self:DestroyPanel()
  end
end
def.method("string").onClick = function(self, id)
  if id == "Btn_Close" or id == "Btn_Get" then
    self:HideDlg()
    return
  end
  local fnTable = {}
  fnTable.Img_BgPrize1 = HuanhunNext.OnImg_BgPrize1
  fnTable.Img_BgPrize2 = HuanhunNext.OnImg_BgPrize2
  fnTable.Img_BgPrize3 = HuanhunNext.OnImg_BgPrize3
  local fn = fnTable[id]
  if fn ~= nil then
    fn(self)
  end
end
def.override().OnCreate = function(self)
end
def.override().OnDestroy = function(self)
end
def.override("boolean").OnShow = function(self, s)
  if s == true then
    self:Fill()
  else
  end
end
def.method().Fill = function(self)
  local Img_Bg0 = self.m_panel:FindDirect("Img_Bg0")
  for i = 1, 3 do
    local Img_BgPrize = Img_Bg0:FindDirect(string.format("Img_BgPrize%d", i))
    local Texture_Prize = Img_BgPrize:FindDirect("Texture_Prize")
    local uiTexture = Texture_Prize:GetComponent("UITexture")
    local itemID = activityInterface._huanhunNextItem[i]
    print("** ***** ** HuanhunNext.Fill()   itemID", itemID)
    local itemBase = ItemUtils.GetItemBase2(itemID)
    if itemBase ~= nil then
      GUIUtils.FillIcon(uiTexture, itemBase.icon)
    else
      local filterCfg = ItemUtils.GetItemFilterCfg(itemID)
      if filterCfg ~= nil then
        GUIUtils.FillIcon(uiTexture, filterCfg.icon)
      else
        GUIUtils.FillIcon(uiTexture, 0)
      end
    end
    local Label_PrizeNum = Img_BgPrize:FindDirect("Label_PrizeNum")
    Label_PrizeNum:SetActive(false)
  end
end
def.static(HuanhunNext).OnImg_BgPrize1 = function(self)
  self:OnImg_BgPrize(1)
end
def.static(HuanhunNext).OnImg_BgPrize2 = function(self)
  self:OnImg_BgPrize(2)
end
def.static(HuanhunNext).OnImg_BgPrize3 = function(self)
  self:OnImg_BgPrize(3)
end
def.method("number").OnImg_BgPrize = function(self, index)
  local itemID = activityInterface._huanhunNextItem[index]
  if itemID == nil or itemID <= 0 then
    return
  end
  local Img_Bg0 = self.m_panel:FindDirect("Img_Bg0")
  local Img_BgPrize = Img_Bg0:FindDirect(string.format("Img_BgPrize%d", index))
  local position = Img_BgPrize:get_position()
  local screenPos = WorldPosToScreen(position.x, position.y)
  local sprite = Img_BgPrize:GetComponent("UISprite")
  local itemBase = ItemUtils.GetItemBase2(itemID)
  if itemBase ~= nil then
    ItemTipsMgr.Instance():ShowBasicTips(itemID, screenPos.x, screenPos.y, sprite:get_width(), sprite:get_height(), 0, true)
  else
    ItemTipsMgr.Instance():ShowItemFilterTips(itemID, screenPos.x, screenPos.y, sprite:get_width(), sprite:get_height(), 0, true)
  end
end
HuanhunNext.Commit()
return HuanhunNext
