local Lplus = require("Lplus")
local ECPanelBase = require("GUI.ECPanelBase")
local GUIUtils = require("GUI.GUIUtils")
local ChengweiTips = Lplus.Extend(ECPanelBase, "ChengweiTips")
local MathHelper = require("Common.MathHelper")
local Vector = require("Types.Vector")
local TitleInterface = require("Main.title.TitleInterface")
local def = ChengweiTips.define
local dlg
def.field("number").chengweId = 0
def.field("string").name = ""
def.field("table").uiObjs = nil
def.static("=>", ChengweiTips).Instance = function(self)
  if nil == dlg then
    dlg = ChengweiTips()
  end
  return dlg
end
def.method("number", "string").ShowTip = function(self, chengweId, name)
  if self.m_panel == nil then
    self.chengweId = chengweId
    self.name = name
    self:CreatePanel(_G.RESPATH.PREFAB_CHENGWEI_TIPS_PANEL, 2)
    self:SetOutTouchDisappear()
  end
end
def.override().OnCreate = function(self)
  self:InitUI()
  self:ShowChengweiInfo()
end
def.override().OnDestroy = function(self)
  self.chengweId = 0
  self.name = ""
  self.uiObjs = nil
end
def.method().InitUI = function(self)
  self.uiObjs = {}
  self.uiObjs.Img_Bg0 = self.m_panel:FindDirect("Img_Bg0")
  self.uiObjs.Label_Name = self.uiObjs.Img_Bg0:FindDirect("Label_1")
  self.uiObjs.Label_Desc = self.uiObjs.Img_Bg0:FindDirect("Label_2")
  self.uiObjs.Label_Getway = self.uiObjs.Img_Bg0:FindDirect("Label_3")
  self.uiObjs.Label_Attr = self.uiObjs.Img_Bg0:FindDirect("Label_4")
  self.uiObjs.Label_Time = self.uiObjs.Img_Bg0:FindDirect("Label_5")
end
def.method().ShowChengweiInfo = function(self)
  local chengweiCfg = TitleInterface.GetAppellationCfg(self.chengweId)
  if chengweiCfg == nil then
    warn("no title id:" .. self.touxianId)
    self:DestroyPanel()
    return
  end
  GUIUtils.SetText(self.uiObjs.Label_Name, self.name)
  GUIUtils.SetText(self.uiObjs.Label_Desc, chengweiCfg.description)
  GUIUtils.SetText(self.uiObjs.Label_Getway, chengweiCfg.getMethod)
  local strProperty = ""
  for k, v in pairs(chengweiCfg.properties) do
    local PropNameCfg = GetCommonPropNameCfg(v.propertyID)
    if strProperty ~= "" then
      strProperty = strProperty .. "  "
    end
    strProperty = strProperty .. string.format("%s +%d", PropNameCfg.propName, v.value)
  end
  if strProperty == "" then
    strProperty = textRes.Title[4]
  end
  GUIUtils.SetText(self.uiObjs.Label_Attr, strProperty)
  local limit = chengweiCfg.appellationLimit
  if limit <= 0 then
    GUIUtils.SetText(self.uiObjs.Label_Time, textRes.Title[3])
  else
    GUIUtils.SetText(self.uiObjs.Label_Time, string.format(textRes.Title[1], limit))
  end
  local uiTable = self.uiObjs.Img_Bg0:GetComponent("UITableResizeBackground")
  uiTable:Reposition()
end
ChengweiTips.Commit()
return ChengweiTips
