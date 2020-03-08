local Lplus = require("Lplus")
local ECPanelBase = require("GUI.ECPanelBase")
local GUIUtils = require("GUI.GUIUtils")
local PetSoulMgr = require("Main.Pet.soul.PetSoulMgr")
local PetSoulUtils = require("Main.Pet.soul.PetSoulUtils")
local PetSoulData = require("Main.Pet.soul.data.PetSoulData")
local PetSoulTip = Lplus.Extend(ECPanelBase, "PetSoulTip")
local def = PetSoulTip.define
local instance
def.static("=>", PetSoulTip).Instance = function()
  if instance == nil then
    instance = PetSoulTip()
  end
  return instance
end
def.field("table")._uiObjs = nil
def.field("userdata")._petId = nil
def.field("table")._soulInfo = nil
def.static("userdata", "table").ShowPanel = function(petId, soulInfo)
  if not PetSoulMgr.Instance():IsOpen(true) or nil == soulInfo then
    if PetSoulTip.Instance():IsShow() then
      PetSoulTip.Instance():DestroyPanel()
    end
    return
  end
  PetSoulTip.Instance():InitData(petId, soulInfo)
  if PetSoulTip.Instance():IsShow() then
    PetSoulTip.Instance():UpdateUI()
    return
  end
  instance:CreatePanel(RESPATH.PREFAB_PET_SOUL_TIP_PANEL, 2)
end
def.method("userdata", "table").InitData = function(self, petId, soulInfo)
  self._petId = petId
  self._soulInfo = soulInfo
end
def.override().OnCreate = function(self)
  self:SetModal(false)
  self:_InitUI()
  self:SetOutTouchDisappear()
end
def.method()._InitUI = function(self)
  self._uiObjs = {}
  self._uiObjs.Img_Icon = self.m_panel:FindDirect("Img_Bg0/Img_Icon")
  self._uiObjs.Label_Name = self.m_panel:FindDirect("Label_Name")
  self._uiObjs.Label_Level = self.m_panel:FindDirect("Label_Num")
  self._uiObjs.Label_Attr = self.m_panel:FindDirect("Label_BloodBuff")
  self._uiObjs.Label_Description = self.m_panel:FindDirect("Img_Bg0/Label_Description")
  self._uiObjs.Btn_Random = self.m_panel:FindDirect("Img_Bg0/Btn_RadomProperty")
  self._uiObjs.Btn_Update = self.m_panel:FindDirect("Img_Bg0/Btn_Update")
end
def.override("boolean").OnShow = function(self, show)
  self:HandleEventListeners(show)
  if show then
    self:UpdateUI()
  else
  end
end
def.method().UpdateUI = function(self)
  local posCfg = PetSoulData.Instance():GetPosCfg(self._soulInfo.pos)
  if self._soulInfo and posCfg then
    GUIUtils.SetActive(self._uiObjs.Img_Icon, true)
    GUIUtils.SetTexture(self._uiObjs.Img_Icon, posCfg.img)
    GUIUtils.SetText(self._uiObjs.Label_Name, posCfg.name)
    local level = self._soulInfo.level and self._soulInfo.level or 0
    GUIUtils.SetText(self._uiObjs.Label_Level, level)
    local propIdx = self._soulInfo.propIndex and self._soulInfo.propIndex or 0
    local prop = PetSoulData.Instance():GetSoulPropByIdx(self._soulInfo.pos, level, propIdx)
    local attrStr = PetSoulUtils.GetAttrString(prop)
    GUIUtils.SetText(self._uiObjs.Label_Attr, attrStr)
    if level > 0 then
      GUIUtils.SetText(self._uiObjs.Label_Description, posCfg.tip)
    else
      GUIUtils.SetText(self._uiObjs.Label_Description, textRes.Pet.Soul.SOUL_LEVEL_0)
    end
    local PetMgr = require("Main.Pet.mgr.PetMgr")
    local bSelfPet = PetMgr.Instance():GetPet(self._petId) ~= nil
    GUIUtils.SetActive(self._uiObjs.Btn_Random, bSelfPet)
    GUIUtils.SetActive(self._uiObjs.Btn_Update, bSelfPet)
  else
    warn("[ERROR][PetSoulTip:UpdateUI] self._soulInfo nil or posCfg nil.")
    GUIUtils.SetActive(self._uiObjs.Img_Icon, false)
    GUIUtils.SetText(self._uiObjs.Label_Name, "")
    GUIUtils.SetText(self._uiObjs.Label_Level, "")
    GUIUtils.SetText(self._uiObjs.Label_Attr, "")
    GUIUtils.SetText(self._uiObjs.Label_Description, "")
    GUIUtils.SetActive(self._uiObjs.Btn_Random, false)
    GUIUtils.SetActive(self._uiObjs.Btn_Update, false)
  end
end
def.override().OnDestroy = function(self)
  self:_Reset()
end
def.method()._Reset = function(self)
  self._petId = nil
  self._soulInfo = nil
  self._uiObjs = nil
end
def.method("userdata").onClickObj = function(self, clickObj)
  local id = clickObj.name
  if id == "Btn_RadomProperty" then
    self:OnBtn_Random()
  elseif id == "Btn_Update" then
    self:OnBtn_LevelUp()
  end
end
def.method().OnBtn_Random = function(self)
  if self._soulInfo.level and self._soulInfo.level > 0 then
    local PetSoulRandomPanel = require("Main.Pet.soul.ui.PetSoulRandomPanel")
    PetSoulRandomPanel.ShowPanel(self._petId, self._soulInfo.pos)
    self:DestroyPanel()
  else
    Toast(textRes.Pet.Soul.RANDOM_FAIL_NEED_LEVEL_UP)
  end
end
def.method().OnBtn_LevelUp = function(self)
  if self._soulInfo then
    if self._soulInfo.level and self._soulInfo.level > 0 then
      local PetSoulLevelupPanel = require("Main.Pet.soul.ui.PetSoulLevelupPanel")
      PetSoulLevelupPanel.ShowPanel(self._petId, self._soulInfo.pos)
    else
      local PetSoulChoosePanel = require("Main.Pet.soul.ui.PetSoulChoosePanel")
      PetSoulChoosePanel.ShowPanel(self._petId, self._soulInfo.pos, nil)
    end
  else
    warn("[ERROR][PetSoulTip:OnBtn_LevelUp] self._soulInfo nil.")
  end
  self:DestroyPanel()
end
def.method("boolean").HandleEventListeners = function(self, isRigister)
  local eventFunc
  if isRigister then
    eventFunc = Event.RegisterEvent
  else
    eventFunc = Event.UnregisterEvent
  end
  if eventFunc then
  end
end
PetSoulTip.Commit()
return PetSoulTip
