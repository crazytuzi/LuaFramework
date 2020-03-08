local Lplus = require("Lplus")
local ECPanelBase = require("GUI.ECPanelBase")
local GUIUtils = require("GUI.GUIUtils")
local AircraftData = require("Main.Aircraft.data.AircraftData")
local AircraftUtils = require("Main.Aircraft.AircraftUtils")
local PropertyType = require("consts.mzm.gsp.common.confbean.PropertyType")
local AircraftUIModel = require("Main.Aircraft.ui.AircraftUIModel")
local ECUIModel = require("Model.ECUIModel")
local AircraftSharePanel = Lplus.Extend(ECPanelBase, "AircraftSharePanel")
local def = AircraftSharePanel.define
local instance
def.static("=>", AircraftSharePanel).Instance = function()
  if instance == nil then
    instance = AircraftSharePanel()
  end
  return instance
end
def.field("table")._uiObjs = nil
def.field("table")._aircraftInfo = nil
def.field("table")._aircraftCfg = nil
def.field("boolean")._bMount = false
def.field(ECUIModel)._aircraftModel = nil
def.field(ECUIModel)._heroModel = nil
def.field("boolean")._isDrag = false
def.static("table").ShowPanel = function(aircraftInfo)
  if not AircraftSharePanel.Instance():_InitData(aircraftInfo) then
    if AircraftSharePanel.Instance():IsShow() then
      AircraftSharePanel.Instance():DestroyPanel()
    end
    return
  end
  if AircraftSharePanel.Instance():IsShow() then
    AircraftSharePanel.Instance():UpdateUI()
    return
  end
  instance:CreatePanel(RESPATH.PREFAB_AIRCRAFT_SHARE_PANEL, 1)
end
def.override().OnCreate = function(self)
  self:SetModal(false)
  self:_InitUI()
end
def.method()._InitUI = function(self)
  self._uiObjs = {}
  self._uiObjs.Label_Title = self.m_panel:FindDirect("Img_Bg/Img_TitleBg/Label_Title")
  self._uiObjs.Model = self.m_panel:FindDirect("Img_Bg/Model")
  self._uiObjs.Label_Shuxing = self.m_panel:FindDirect("Img_Bg/Group_ShuXing/Label_Shuxing")
  self._uiObjs.Label_Name = self.m_panel:FindDirect("Img_Bg/Btn_Do/Label_Name")
end
def.method("table", "=>", "boolean")._InitData = function(self, aircraftInfo)
  self._aircraftInfo = aircraftInfo
  self._aircraftCfg = aircraftInfo and AircraftData.Instance():GetAircraftCfg(aircraftInfo.cfgId)
  if self._aircraftInfo and self._aircraftCfg then
    return true
  else
    return false
  end
end
def.override("boolean").OnShow = function(self, show)
  if show then
    self:UpdateUI()
  else
  end
end
def.method().UpdateUI = function(self)
  self:DestroyAircraftModel()
  self:FillAircraftModel()
  self:ShowAttrs()
end
def.override().OnDestroy = function(self)
  self:_Reset()
end
def.method()._Reset = function(self)
  self._aircraftInfo = nil
  self._aircraftCfg = nil
  if not _G.IsNil(self._heroModel) then
    self._heroModel:Destroy()
    self._heroModel = nil
  end
  self:DestroyAircraftModel()
  self._isDrag = false
  self._bMount = false
  self._uiObjs = nil
end
def.method().DestroyAircraftModel = function(self)
  if not _G.IsNil(self._aircraftModel) then
    self._aircraftModel:DetachRole()
    self._aircraftModel:Destroy()
    self._aircraftModel = nil
  end
end
def.method().FillAircraftModel = function(self)
  GUIUtils.SetText(self._uiObjs.Label_Title, self._aircraftCfg.name)
  local uiModel = self._uiObjs.Model:GetComponent("UIModel")
  self._aircraftModel = AircraftUIModel.new(self._aircraftInfo.cfgId, self._aircraftInfo.colorId, uiModel)
  self._aircraftModel:LoadWithCB(function(model)
    if _G.IsNil(model) then
      return
    end
    self:MountAircraft(self._bMount, true)
  end)
end
def.method("boolean", "boolean").MountAircraft = function(self, bMount, bForce)
  if self._bMount == bMount and not bForce then
    warn("[WARN][AircraftNode:MountAircraft] self._bMount == bMount:", bMount)
    return
  end
  self._bMount = bMount
  self:UpdateMountState()
  if self:IsModelLoaded(self._aircraftModel) then
    if false == bMount then
      self._aircraftModel:DetachRole()
    elseif not _G.IsNil(self._heroModel) then
      if not self._heroModel:IsInLoading() then
        self._aircraftModel:AttachRole(self._heroModel)
      else
        warn("[AircraftSharePanel:MountAircraft] self._heroModel:IsInLoading().")
      end
    else
      warn("[AircraftSharePanel:MountAircraft] _G.IsNil(self._heroModel), LoadHeroModel.")
      self:LoadHeroModel()
    end
  end
end
def.method(ECUIModel, "=>", "boolean").IsModelLoaded = function(self, ecUIModel)
  if not _G.IsNil(ecUIModel) and not ecUIModel:IsInLoading() then
    return true
  else
    return false
  end
end
def.method().LoadHeroModel = function(self)
  local heroProp = require("Main.Hero.Interface").GetHeroProp()
  if heroProp == nil then
    return
  end
  local modelId = gmodule.moduleMgr:GetModule(ModuleId.HERO):GetMyModelId()
  self._heroModel = ECUIModel.new(modelId)
  self._heroModel.m_bUncache = true
  local modelInfo = gmodule.moduleMgr:GetModule(ModuleId.PUBROLE):GetRoleModelInfo(gmodule.moduleMgr:GetModule(ModuleId.HERO).roleId)
  local ModelInfo = require("netio.protocol.mzm.gsp.pubdata.ModelInfo")
  modelInfo.extraMap[ModelInfo.MAGIC_MARK] = nil
  self._heroModel:AddOnLoadCallback("AircraftSharePanel", function()
    if _G.IsNil(self.m_panel) then
      self._heroModel:Destroy()
      self._heroModel = nil
      return
    end
    if _G.IsNil(self._heroModel) or _G.IsNil(self._heroModel.m_model) then
      return
    end
    self:MountAircraft(self._bMount, true)
  end)
  _G.LoadModel(self._heroModel, modelInfo, 0, 0, 180, false, false)
end
def.method().UpdateMountState = function(self)
  local btnStr = ""
  if self._bMount then
    btnStr = textRes.Aircraft.AIRCRAFT_SHARE_BTN_DISMOUNT
  else
    btnStr = textRes.Aircraft.AIRCRAFT_SHARE_BTN_MOUNT
  end
  GUIUtils.SetText(self._uiObjs.Label_Name, btnStr)
end
def.method().ShowAttrs = function(self)
  local attrStr = AircraftUtils.GetAircraftAttrString(self._aircraftCfg)
  GUIUtils.SetText(self._uiObjs.Label_Shuxing, attrStr)
end
def.method("userdata").onClickObj = function(self, clickObj)
  local id = clickObj.name
  if id == "Btn_Close" then
    self:OnBtn_Close()
  elseif id == "Btn_Do" then
    self:OnBtn_Do()
  end
end
def.method().OnBtn_Close = function(self)
  self:DestroyPanel()
end
def.method().OnBtn_Do = function(self)
  self:MountAircraft(not self._bMount, false)
end
def.method("string").onDragStart = function(self, id)
  self._isDrag = true
end
def.method("string").onDragEnd = function(self, id)
  self._isDrag = false
end
def.method("string", "number", "number").onDrag = function(self, id, dx, dy)
  if self._isDrag == true and not _G.IsNil(self._aircraftModel) then
    self._aircraftModel:SetDir(self._aircraftModel.m_ang - dx / 2)
  end
end
AircraftSharePanel.Commit()
return AircraftSharePanel
