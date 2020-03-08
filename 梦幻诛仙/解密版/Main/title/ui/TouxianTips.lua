local Lplus = require("Lplus")
local ECPanelBase = require("GUI.ECPanelBase")
local GUIUtils = require("GUI.GUIUtils")
local TouxianTips = Lplus.Extend(ECPanelBase, "TouxianTips")
local MathHelper = require("Common.MathHelper")
local Vector = require("Types.Vector")
local UIModelWrap = require("Model.UIModelWrap")
local TitleInterface = require("Main.title.TitleInterface")
local def = TouxianTips.define
local dlg
def.field("number").touxianId = 0
def.field("string").name = ""
def.field("table").uiObjs = nil
def.field(UIModelWrap)._UIModelWrap = nil
def.static("=>", TouxianTips).Instance = function(self)
  if nil == dlg then
    dlg = TouxianTips()
  end
  return dlg
end
def.method("number", "string").ShowTip = function(self, touxianId, name)
  if self.m_panel == nil then
    self.touxianId = touxianId
    self.name = name
    self:CreatePanel(_G.RESPATH.PREFAB_TOUXIAN_TIPS_PANEL, 2)
    self:SetOutTouchDisappear()
  end
end
def.override().OnCreate = function(self)
  self:InitUI()
  self:ShowTouxianInfo()
end
def.override().OnDestroy = function(self)
  self:DestroyModel()
  self.touxianId = 0
  self.name = ""
  self.uiObjs = nil
end
def.method().DestroyModel = function(self)
  if self._UIModelWrap ~= nil then
    self._UIModelWrap:Destroy()
    self._UIModelWrap = nil
  end
end
def.method().InitUI = function(self)
  self.uiObjs = {}
  self.uiObjs.Img_Bg0 = self.m_panel:FindDirect("Img_Bg0")
  self.uiObjs.Model = self.uiObjs.Img_Bg0:FindDirect("Model")
  self.uiObjs.Label_Name = self.uiObjs.Img_Bg0:FindDirect("Label_1")
  self.uiObjs.Label_Desc = self.uiObjs.Img_Bg0:FindDirect("Label_2")
  self.uiObjs.Label_Getway = self.uiObjs.Img_Bg0:FindDirect("Label_3")
  self.uiObjs.Label_Time = self.uiObjs.Img_Bg0:FindDirect("Label_5")
end
def.method().ShowTouxianInfo = function(self)
  local touxianCfg = TitleInterface.GetTitleCfg(self.touxianId)
  if touxianCfg == nil then
    warn("no touxian id:" .. self.touxianId)
    self:DestroyPanel()
    return
  end
  GUIUtils.SetText(self.uiObjs.Label_Name, self.name)
  GUIUtils.SetText(self.uiObjs.Label_Desc, touxianCfg.description)
  GUIUtils.SetText(self.uiObjs.Label_Getway, touxianCfg.getMethod)
  local limit = touxianCfg.titleLimit
  if limit <= 0 then
    GUIUtils.SetText(self.uiObjs.Label_Time, textRes.Title[3])
  else
    GUIUtils.SetText(self.uiObjs.Label_Time, string.format(textRes.Title[1], limit))
  end
  local uiModel = self.uiObjs.Model:GetComponent("UIModel")
  uiModel:set_orthographic(true)
  uiModel:set_pivotCenter(true)
  uiModel.mCanOverflow = true
  local resourcePath, resourceType = GetIconPath(touxianCfg.picId)
  if self.uiObjs.Model:get_activeInHierarchy() == false then
    return
  end
  self._UIModelWrap = UIModelWrap.new(uiModel)
  self._UIModelWrap._defaultDir = 0
  self._UIModelWrap._defaultScale = 3
  self._UIModelWrap:Load(resourcePath)
  local uiTable = self.uiObjs.Img_Bg0:GetComponent("UITableResizeBackground")
  uiTable:Reposition()
end
TouxianTips.Commit()
return TouxianTips
