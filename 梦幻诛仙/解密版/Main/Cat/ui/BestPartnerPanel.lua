local Lplus = require("Lplus")
local ECPanelBase = require("GUI.ECPanelBase")
local GUIUtils = require("GUI.GUIUtils")
local ECUIModel = require("Model.ECUIModel")
local CatModule = require("Main.Cat.CatModule")
local CatModuleInst = CatModule.Instance()
local instance
local BestPartnerPanel = Lplus.Extend(ECPanelBase, "BestPartnerPanel")
local def = BestPartnerPanel.define
def.field("table").m_uiObjs = nil
def.field("number").m_partnerId = 0
def.field("table").ecUIModel = nil
def.static("=>", BestPartnerPanel).Instance = function()
  if instance == nil then
    instance = BestPartnerPanel()
    instance.m_TrigGC = true
    instance.m_TryIncLoadSpeed = true
  end
  return instance
end
def.method().Clear = function(self)
  self.m_uiObjs = nil
  self.m_partnerId = 0
  if self.ecUIModel then
    self.ecUIModel:Destroy()
  end
  self.ecUIModel = nil
end
def.method().Hide = function(self)
  self:DestroyPanel()
end
def.override().OnCreate = function(self)
  self:InitUI()
end
def.override().OnDestroy = function(self)
  self:Clear()
end
def.override("boolean").OnShow = function(self, show)
  if show then
    self:Update()
  else
  end
end
def.method().InitUI = function(self)
  self.m_uiObjs = {}
  local Container = self.m_panel:FindDirect("Container")
  self.m_uiObjs.Model = Container:FindDirect("Model")
  self.m_uiObjs.Label_Name = Container:FindDirect("Label_Name")
end
def.method().Update = function(self)
  self.m_uiObjs.Label_Name:GetComponent("UILabel"):set_text(CatModuleInst:GetPartnerName())
  local uiModel = self.m_uiObjs.Model:GetComponent("UIModel")
  local modelpath, modelcolor = GetIconPath(CatModuleInst:GetPartnerIconId())
  if modelpath == nil or modelpath == "" then
    return
  end
  if self.ecUIModel then
    self.ecUIModel:Destroy()
  end
  self.ecUIModel = nil
  local function AfterModelLoad()
    uiModel.modelGameObject = self.ecUIModel.m_model
    if uiModel.mCanOverflow ~= nil then
      uiModel.mCanOverflow = true
      local camera = uiModel:get_modelCamera()
      camera:set_orthographic(true)
    end
  end
  if not self.ecUIModel then
    self.ecUIModel = ECUIModel.new(0)
    self.ecUIModel.m_bUncache = true
    self.ecUIModel:LoadUIModel(modelpath, function(ret)
      if not self.ecUIModel or not self.ecUIModel.m_model or self.ecUIModel.m_model.isnil then
        return
      end
      AfterModelLoad()
    end)
  end
end
def.method("userdata").onClickObj = function(self, clickObj)
  local id = clickObj.name
  self:Hide()
end
def.method("number").ShowPanel = function(self, partnerId)
  if self:IsShow() then
    self:Update()
  else
    self:CreatePanel(RESPATH.PREFAB_BEST_PARTNER_PANEL, 0)
  end
end
return BestPartnerPanel.Commit()
