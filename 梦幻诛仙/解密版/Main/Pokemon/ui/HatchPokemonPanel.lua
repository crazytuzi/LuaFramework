local Lplus = require("Lplus")
local GUIUtils = require("GUI.GUIUtils")
local ECPanelBase = require("GUI.ECPanelBase")
local PokemonData = require("Main.Pokemon.data.PokemonData")
local PokemonProtocols = require("Main.Pokemon.PokemonProtocols")
local PokemonUtils = require("Main.Pokemon.PokemonUtils")
local HomelandModule = Lplus.ForwardDeclare("HomelandModule")
local Vector = require("Types.Vector")
local PokemonModule, PokemonEntity
local HatchPokemonPanel = Lplus.Extend(ECPanelBase, "HatchPokemonPanel")
local def = HatchPokemonPanel.define
local instance
def.static("=>", HatchPokemonPanel).Instance = function()
  if instance == nil then
    instance = HatchPokemonPanel()
  end
  return instance
end
def.const("number").UPDATE_INTERVAL = 0.03
def.field("table")._uiObjs = nil
def.field("table")._pokemonEntity = nil
def.field("number")._timerID = 0
def.static("table").ShowDlg = function(pokemonEntity)
  PokemonModule = require("Main.Pokemon.PokemonModule")
  PokemonEntity = require("Main.Map.entity.PokemonEntity")
  if not PokemonModule.Instance():IsOpen(true) then
    if HatchPokemonPanel.Instance():IsShow() then
      HatchPokemonPanel.Instance():DestroyPanel()
    end
    return
  end
  if nil == pokemonEntity then
    if HatchPokemonPanel.Instance():IsShow() then
      HatchPokemonPanel.Instance():DestroyPanel()
    end
    warn("[ERROR][HatchPokemonPanel:ShowDlg] show failed! pokemonEntity nil.")
    return
  end
  if pokemonEntity:GetLifeStage() ~= PokemonEntity.LifeStageEnum.EGG then
    if HatchPokemonPanel.Instance():IsShow() then
      HatchPokemonPanel.Instance():DestroyPanel()
    end
    warn(string.format("[ERROR][HatchPokemonPanel:ShowDlg] pokemonEntity:GetLifeStage()[%d] ~= PokemonEntity.LifeStageEnum.EGG[%d].", pokemonEntity:GetLifeStage(), PokemonEntity.LifeStageEnum.EGG))
    return
  end
  HatchPokemonPanel.Instance():InitData(pokemonEntity)
  if HatchPokemonPanel.Instance():IsShow() then
    HatchPokemonPanel.Instance():ShowHatch()
    return
  end
  HatchPokemonPanel.Instance():CreatePanel(RESPATH.PREFAB_POKEMON_HATCH, 0)
end
def.override().OnCreate = function(self)
  self:SetModal(false)
  self:_InitUI()
  self:SetOutTouchDisappear()
end
def.method("table").InitData = function(self, pokemonEntity)
  self._pokemonEntity = pokemonEntity
end
def.method("=>", "table").GetPokemonEntity = function(self)
  return self._pokemonEntity
end
def.method()._InitUI = function(self)
  self._uiObjs = {}
  self._uiObjs.tipFrame = self.m_panel:FindDirect("Img_Bg")
  self._uiObjs.Label_Desc = self.m_panel:FindDirect("Img_Bg/Label_Info")
  self._uiObjs.Progress = self.m_panel:FindDirect("Img_Bg/Slider_Prograss"):GetComponent("UISlider")
  self._uiObjs.Label_Progress = self.m_panel:FindDirect("Img_Bg/Slider_Prograss/Label_DeYu_Slider")
  self._uiObjs.Label_Other = self.m_panel:FindDirect("Img_Bg/Label_Other")
  self._uiObjs.Btn_Touch = self.m_panel:FindDirect("Img_Bg/Group_Btn/Btn_Touch")
  self._uiObjs.Btn_Hatch = self.m_panel:FindDirect("Img_Bg/Group_Btn/Btn_Hatch")
end
def.override().OnDestroy = function(self)
  self:_Reset()
end
def.method()._Reset = function(self)
  self:_ClearTimer()
  self._uiObjs = nil
  self._pokemonEntity = nil
end
def.override("boolean").OnShow = function(self, show)
  self:_ClearTimer()
  self:HandleEventListeners(show)
  if show then
    self._timerID = GameUtil.AddGlobalTimer(HatchPokemonPanel.UPDATE_INTERVAL, false, function()
      self:_Update()
    end)
    self:ShowHatch()
  else
    Event.DispatchEvent(ModuleId.POKEMON, gmodule.notifyId.Pokemon.FONDLE_PANEL_CLOSED, {
      entity = self._pokemonEntity
    })
  end
end
def.method()._Update = function(self)
  self:_UpdatePos()
end
def.method()._ClearTimer = function(self)
  if self._timerID ~= 0 then
    GameUtil.RemoveGlobalTimer(self._timerID)
    self._timerID = 0
  end
end
def.method().ShowHatch = function(self)
  self:_UpdateContent()
  self:_UpdatePos()
end
def.method()._UpdateContent = function(self)
  local curCount = self._pokemonEntity:GetFondleCount()
  local maxCount = PokemonUtils.GetEggMaxFondleCount(self._pokemonEntity.cfgid)
  local desc = string.format(textRes.Pokemon.HATCH_DESC, maxCount)
  GUIUtils.SetText(self._uiObjs.Label_Desc, desc)
  local progressString = string.format(textRes.Pokemon.HATCH_PROGRESS, curCount, maxCount)
  GUIUtils.SetText(self._uiObjs.Label_Progress, progressString)
  local progressValue = 0
  if maxCount > 0 then
    progressValue = curCount / maxCount
  end
  self._uiObjs.Progress:set_sliderValue(progressValue)
  if HomelandModule.Instance():IsInSelfHomeland() and nil ~= PokemonData.Instance():GetPokemonInfo(self._pokemonEntity.instanceid) then
    GUIUtils.SetActive(self._uiObjs.Label_Other, false)
    if curCount >= maxCount then
      GUIUtils.SetActive(self._uiObjs.Btn_Touch, false)
      GUIUtils.SetActive(self._uiObjs.Btn_Hatch, true)
    else
      GUIUtils.SetActive(self._uiObjs.Btn_Touch, true)
      GUIUtils.SetActive(self._uiObjs.Btn_Hatch, false)
    end
  else
    GUIUtils.SetActive(self._uiObjs.Btn_Touch, false)
    GUIUtils.SetActive(self._uiObjs.Btn_Hatch, false)
    GUIUtils.SetActive(self._uiObjs.Label_Other, true)
    local ownerStr = string.format(textRes.Pokemon.OTHER_ROLE_EGG, self._pokemonEntity:GetOwnerName())
    GUIUtils.SetText(self._uiObjs.Label_Other, ownerStr)
  end
end
def.method()._UpdatePos = function(self)
  if self._pokemonEntity then
    local position = self._pokemonEntity:GetInteractivePanelPos()
    self._uiObjs.tipFrame:set_localPosition(Vector.Vector3.new(position.x, position.y, 0))
  else
    warn("[HatchPokemonPanel:_UpdatePos] self._pokemonEntity nil!")
    self:DestroyPanel()
  end
end
def.method("string").onClick = function(self, id)
  if id == "Btn_Close" then
    self:OnBtn_Close()
  elseif id == "Btn_Help" then
    self:OnBtn_Help()
  elseif id == "Btn_Touch" then
    self:OnBtn_Touch()
  else
    if id == "Btn_Hatch" then
      self:OnBtn_Hatch()
    else
    end
  end
end
def.method().OnBtn_Close = function(self)
  self:DestroyPanel()
end
def.method().OnBtn_Help = function(self)
  local tipContent = require("Main.Common.TipsHelper").GetHoverTip(constant.CAnimalConst.EMBRYO_TIP_CFG_ID)
  local CommonUITipsDlg = require("GUI.CommonUITipsDlg")
  CommonUITipsDlg.Instance():ShowDlg(tipContent, {x = 0, y = 0})
end
def.method().OnBtn_Touch = function(self)
  if PokemonData.Instance():CanFondle(self._pokemonEntity.instanceid) then
    PokemonProtocols.SendCFondle(self._pokemonEntity.instanceid)
  else
    Toast(textRes.Pokemon.FONDLE_EGG_FAILED_FONDLED)
  end
end
def.method().OnBtn_Hatch = function(self)
  PokemonProtocols.SendCHatch(self._pokemonEntity.instanceid)
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
    eventFunc(ModuleId.POKEMON, gmodule.notifyId.Pokemon.EGG_FONDLE_COUNT_CHANGE, HatchPokemonPanel.OnFondleSuccess)
  end
end
def.static("table", "table").OnFondleSuccess = function(param, context)
  if HatchPokemonPanel.Instance():IsShow() and param.entity == instance._pokemonEntity then
    instance:_UpdateContent()
  end
end
HatchPokemonPanel.Commit()
return HatchPokemonPanel
