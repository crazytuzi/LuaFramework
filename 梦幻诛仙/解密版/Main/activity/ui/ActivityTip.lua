local Lplus = require("Lplus")
local NPCModule = Lplus.ForwardDeclare("NPCModule")
local ECGUIMan = require("GUI.ECGUIMan")
local Vector = require("Types.Vector")
local ECPanelBase = require("GUI.ECPanelBase")
local ActivityTip = Lplus.Extend(ECPanelBase, "ActivityTip")
local def = ActivityTip.define
local inst
local Vector = require("Types.Vector")
local TimeCfgUtils = require("Main.Common.TimeCfgUtils")
local GUIUtils = require("GUI.GUIUtils")
local ItemTipsMgr = require("Main.Item.ItemTipsMgr")
local ItemTips = require("Main.Item.ui.ItemTips")
local ActivityInterface = require("Main.activity.ActivityInterface")
local activityInterface = ActivityInterface.Instance()
def.static("=>", ActivityTip).Instance = function()
  if inst == nil then
    inst = ActivityTip()
    inst:Init()
  end
  return inst
end
def.field("number")._activityID = 0
def.field("table")._cfg = nil
def.field("string")._msdktiplink = ""
def.method().Init = function(self)
  self.m_TrigGC = true
end
def.method().ShowDlg = function(self)
  if self:IsShow() == false then
    self:CreatePanel(RESPATH.PREFAB_UI_ACTIVITY_TIPS, 2)
    self:SetOutTouchDisappear()
  end
end
def.method().HideDlg = function(self)
  if self.m_panel then
    self:DestroyPanel()
  end
end
def.method("string").onClick = function(self, id)
  local strs = string.split(id, "_")
  if strs[1] == "Img" and strs[2] == "BgIcon" then
    local idx = tonumber(strs[3])
    if idx ~= nil and idx ~= 0 then
      local Img_Bg0 = self.m_panel:FindDirect("Img_Bg0")
      local Img_BgIcon = Img_Bg0:FindDirect(string.format("Label_Prize/Grid/Img_BgIcon_%02d", idx))
      local position = Img_BgIcon:get_position()
      local screenPos = WorldPosToScreen(position.x, position.y)
      local sprite = Img_BgIcon:GetComponent("UISprite")
      local itemID = self._cfg.awardDisItems[idx]
      ItemTipsMgr.Instance():ShowBasicTips(itemID, screenPos.x - sprite:get_width() * 0.5, screenPos.y + sprite:get_height() * 0.5, sprite:get_width(), 1, 0, false)
    end
  elseif id == "Btn_GongLue" then
    self:OnBtn_GongLueClicked()
  else
    self:HideDlg()
  end
end
def.method().OnBtn_GongLueClicked = function(self)
  if "" ~= self._msdktiplink then
    require("Main.ECGame").Instance():OpenUrl(self._msdktiplink)
  end
end
def.method("number", "=>", "string").GetGonglueUrl = function(self, activityId)
  local url = ""
  if activityId > 0 then
    do
      local acttipcfg = DynamicData.GetRecord(CFG_PATH.DATA_ACTIVITY_TIPS_LINK_CFG, activityId)
      if acttipcfg ~= nil then
        local msdklinkcfg = DynamicData.GetRecord(CFG_PATH.DATA_BTN_LINK_CFG, acttipcfg:GetIntValue("msdkButtonid"))
        url = msdklinkcfg and msdklinkcfg:GetStringValue("url") or ""
      end
    end
  else
  end
  return url
end
def.override().OnCreate = function(self)
  local Img_BgIcon = self.m_panel:FindDirect("Img_Bg0/Label_Prize/Grid/Img_BgIcon")
  Img_BgIcon:set_name("Img_BgIcon_01")
end
def.override().OnDestroy = function(self)
end
def.override("boolean").OnShow = function(self, s)
  if s == true then
    self:Fill()
  else
  end
end
def.method("number").SetActivityID = function(self, ActivityID)
  self._activityID = ActivityID
  if self:IsShow() then
    self:Fill()
  end
end
def.method().Fill = function(self)
  self._cfg = ActivityInterface.GetActivityCfgById(self._activityID)
  if _G.IsOverseasVersion() then
    self._msdktiplink = self:GetGonglueUrl(self._activityID)
  end
  local Img_Bg0 = self.m_panel:FindDirect("Img_Bg0")
  local Group_Title = Img_Bg0:FindDirect("Group_Title")
  local Texture_Title = Group_Title:FindDirect("Texture_Title")
  local uiTexture = Texture_Title:GetComponent("UITexture")
  GUIUtils.FillIcon(uiTexture, self._cfg.activityIcon)
  local Label_Name = Group_Title:FindDirect("Label_Name")
  Label_Name:GetComponent("UILabel"):set_text(self._cfg.activityName)
  local Label_Prize = Img_Bg0:FindDirect("Label_Prize")
  local Grid = Label_Prize:FindDirect("Grid")
  local Img_BgIcon_1 = Grid:FindDirect(string.format("Img_BgIcon_01"))
  local grid = Grid:GetComponent("UIGrid")
  for k, v in pairs(self._cfg.awardDisItems) do
    local itemName = string.format("Img_BgIcon_%02d", k)
    local Img_BgIcon = Grid:FindDirect(itemName)
    if Img_BgIcon == nil then
      Img_BgIcon = Object.Instantiate(Img_BgIcon_1)
      grid:AddChild(Img_BgIcon.transform)
      Img_BgIcon:set_name(itemName)
      Img_BgIcon.parent = Img_BgIcon_1.parent
      Img_BgIcon:set_localScale(Vector.Vector3.one)
    end
    local Texture_Icon = Img_BgIcon:FindDirect("Texture_Icon")
    local uiTexture = Texture_Icon:GetComponent("UITexture")
    local ItemUtils = require("Main.Item.ItemUtils")
    local takeItemBase = ItemUtils.GetItemBase(self._cfg.awardDisItems[k])
    if takeItemBase ~= nil then
      GUIUtils.FillIcon(uiTexture, takeItemBase.icon)
    end
  end
  grid:Reposition()
  self:TouchGameObject(self.m_panel, self.m_parent)
  local Group_Label = Img_Bg0:FindDirect("Group_Label")
  local Label_01 = Group_Label:FindDirect("Label_Title01/Label_01")
  Label_01:GetComponent("UILabel"):set_text(self._cfg.timeDes)
  local Label_02 = Group_Label:FindDirect("Label_Title02/Label_02")
  local str = ""
  if self._cfg.personMax == self._cfg.personMin then
    if self._cfg.personMax == 1 then
      str = string.format(textRes.activity[62], self._cfg.personMin)
    else
      str = string.format(textRes.activity[64], self._cfg.personMin)
    end
  else
    str = string.format(textRes.activity[65], self._cfg.personMin, self._cfg.personMax)
  end
  Label_02:GetComponent("UILabel"):set_text(str)
  local Label_03 = Group_Label:FindDirect("Label_Title03/Label_03")
  Label_03:GetComponent("UILabel"):set_text(string.format(textRes.activity[63], self._cfg.levelMin))
  local Label_04 = Group_Label:FindDirect("Label_Title04/Label_04")
  local activityDes = self._cfg.activityDes
  local isSpeical, des = self:isSpecialActivityDes(self._cfg.id)
  if isSpeical then
    activityDes = des
  end
  Label_04:GetComponent("UILabel"):set_text(activityDes)
  local Btn_GongLue = Group_Label:FindDirect("Btn_GongLue")
  if nil ~= Btn_GongLue then
    Btn_GongLue:SetActive("" ~= self._msdktiplink)
  end
end
def.method("number", "=>", "boolean", "string").isSpecialActivityDes = function(self, activityId)
  local Feature = require("netio.protocol.mzm.gsp.open.ModuleFunSwitchInfo")
  local feature = require("Main.FeatureOpenList.FeatureOpenListModule").Instance()
  if activityId == constant.ZhenYaoActivityCfgConsts.ZhenYao_ACTIVITY_ID and feature:CheckFeatureOpen(Feature.TYPE_ZHENYAO_FIFTY_AWARD) then
    return true, textRes.activity[405]
  end
  return false, ""
end
ActivityTip.Commit()
return ActivityTip
