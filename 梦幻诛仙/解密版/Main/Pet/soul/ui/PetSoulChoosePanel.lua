local Lplus = require("Lplus")
local ECPanelBase = require("GUI.ECPanelBase")
local GUIUtils = require("GUI.GUIUtils")
local PetSoulMgr = require("Main.Pet.soul.PetSoulMgr")
local PetSoulUtils = require("Main.Pet.soul.PetSoulUtils")
local PetSoulProtocols = require("Main.Pet.soul.PetSoulProtocols")
local PetSoulData = require("Main.Pet.soul.data.PetSoulData")
local PetSoulChoosePanel = Lplus.Extend(ECPanelBase, "PetSoulChoosePanel")
local def = PetSoulChoosePanel.define
local instance
def.static("=>", PetSoulChoosePanel).Instance = function()
  if instance == nil then
    instance = PetSoulChoosePanel()
  end
  return instance
end
def.field("table")._uiObjs = nil
def.field("userdata")._petId = nil
def.field("number")._pos = 0
def.field("function")._closeCB = nil
def.field("table").initPos = nil
def.static("userdata", "number", "function").ShowPanel = function(petId, pos, closeCB)
  if not PetSoulMgr.Instance():IsOpen(true) then
    if PetSoulChoosePanel.Instance():IsShow() then
      PetSoulChoosePanel.Instance():DestroyPanel()
    end
    return
  end
  PetSoulChoosePanel.Instance():InitData(petId, pos, closeCB)
  if PetSoulChoosePanel.Instance():IsShow() then
    PetSoulChoosePanel.Instance():UpdateUI()
    return
  end
  instance:CreatePanel(RESPATH.PREFAB_PET_SOUL_CHOOSE_PANEL, 2)
end
def.method("userdata", "number", "function").InitData = function(self, petId, pos, closeCB)
  self._petId = petId
  self._pos = pos
  self._closeCB = closeCB
end
def.override().OnCreate = function(self)
  self:SetModal(false)
  self:_InitUI()
end
def.method()._InitUI = function(self)
  self._uiObjs = {}
  self._uiObjs.Img_Icon = self.m_panel:FindDirect("Img_Bg0/Img_Icon")
  self._uiObjs.List_Attr = self.m_panel:FindDirect("Img_Bg0/List")
  self._uiObjs.uiList = self._uiObjs.List_Attr:GetComponent("UIList")
end
def.override("boolean").OnShow = function(self, show)
  self:HandleEventListeners(show)
  if show then
    if self.initPos then
      self.m_panel.localPosition = self.initPos
    else
      self.m_panel.localPosition = require("Types.Vector3").Vector3.zero
    end
    self:UpdateUI()
  else
  end
end
def.method().UpdateUI = function(self)
  local posCfg = PetSoulData.Instance():GetPosCfg(self._pos)
  if posCfg then
    GUIUtils.SetActive(self._uiObjs.Img_Icon, true)
    GUIUtils.SetTexture(self._uiObjs.Img_Icon, posCfg.img)
    GUIUtils.SetActive(self._uiObjs.List_Attr, true)
    local propList = PetSoulData.Instance():GetSoulPropList(self._pos, 1)
    local propCount = propList and #propList or 0
    self._uiObjs.uiList.itemCount = propCount
    self._uiObjs.uiList:Resize()
    self._uiObjs.uiList:Reposition()
    for i = 1, propCount do
      local listItem = self._uiObjs.uiList.children[i]
      local prop = propList[i]
      self:ShowProp(i, listItem, prop)
    end
  else
    warn("[ERROR][PetSoulTip:UpdateUI] posCfg nil for pos:", self._pos)
    GUIUtils.SetActive(self._uiObjs.Img_Icon, false)
    GUIUtils.SetActive(self._uiObjs.List_Attr, false)
  end
end
def.method("number", "userdata", "table").ShowProp = function(self, idx, listItem, prop)
  if nil == listItem then
    warn("[ERROR][PetSoulChoosePanel:ShowProp] listItem nil at idx:", idx)
    return
  end
  if nil == prop then
    warn("[ERROR][PetSoulChoosePanel:ShowProp] prop nil at idx:", idx)
    return
  end
  local attrStr = PetSoulUtils.GetAttrString(prop)
  local label = listItem:FindDirect("Label_Buff_" .. idx)
  GUIUtils.SetText(label, attrStr)
  if idx == 1 then
    GUIUtils.Toggle(listItem, true)
  end
end
def.override().OnDestroy = function(self)
  if self._closeCB then
    self._closeCB()
    self._closeCB = nil
  end
  self:_Reset()
end
def.method()._Reset = function(self)
  self._petId = nil
  self._pos = 0
  self._closeCB = nil
  self.initPos = nil
  self._uiObjs = nil
end
def.method("userdata").onClickObj = function(self, clickObj)
  local id = clickObj.name
  if id == "Btn_Confirm" then
    self:OnBtn_Confirm()
  elseif id == "Btn_Close" then
    self:OnBtn_Close()
  end
end
def.method().OnBtn_Confirm = function(self)
  local PetMgr = require("Main.Pet.mgr.PetMgr")
  local pet = PetMgr.Instance():GetPet(self._petId)
  local petLevel = pet and pet.level or 0
  if petLevel < 1 then
    Toast(textRes.Pet.Soul.CHOOSE_FAIL_LEVEL_0)
    return
  end
  local propCount = self._uiObjs.uiList.children and #self._uiObjs.uiList.children or 0
  local propIdx = 0
  for i = 1, propCount do
    local listItem = self._uiObjs.uiList.children[i]
    if listItem:GetComponent("UIToggle").value then
      propIdx = i
      break
    end
  end
  if propIdx > 0 then
    require("GUI.CommonConfirmDlg").ShowConfirm(textRes.Pet.Soul.CHOOSE_CONFIRM_TITLE, textRes.Pet.Soul.CHOOSE_CONFIRM_CONTENT, function(id, tag)
      if id == 1 then
        PetSoulProtocols.SendCPetSoulInitPropReq(self._petId, self._pos, propIdx)
        self:DestroyPanel()
      end
    end, nil)
  else
    Toast(textRes.Pet.Soul.CHOOSE_SELECT_A_PROP)
  end
end
def.method().OnBtn_Close = function(self)
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
PetSoulChoosePanel.Commit()
return PetSoulChoosePanel
