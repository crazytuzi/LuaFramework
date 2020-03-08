local Lplus = require("Lplus")
local GUIUtils = require("GUI.GUIUtils")
local ECPanelBase = require("GUI.ECPanelBase")
local PokemonData = require("Main.Pokemon.data.PokemonData")
local PokemonProtocols = require("Main.Pokemon.PokemonProtocols")
local PokemonUtils = require("Main.Pokemon.PokemonUtils")
local PokemonMgr = require("Main.Pokemon.PokemonMgr")
local HomelandModule = Lplus.ForwardDeclare("HomelandModule")
local Vector = require("Types.Vector")
local PokemonModule
local PokemonOperationPanel = Lplus.Extend(ECPanelBase, "PokemonOperationPanel")
local def = PokemonOperationPanel.define
local instance
def.static("=>", PokemonOperationPanel).Instance = function()
  if instance == nil then
    instance = PokemonOperationPanel()
  end
  return instance
end
def.field("table")._uiObjs = nil
def.field("userdata")._anchor = nil
def.static("userdata").ShowPanel = function(anchor)
  PokemonModule = require("Main.Pokemon.PokemonModule")
  if not PokemonModule.Instance():IsOpen(true) then
    if PokemonOperationPanel.Instance():IsShow() then
      PokemonOperationPanel.Instance():DestroyPanel()
    end
    return
  end
  if not HomelandModule.Instance():IsInSelfHomeland() then
    if PokemonOperationPanel.Instance():IsShow() then
      PokemonOperationPanel.Instance():DestroyPanel()
    end
    return
  end
  if nil == anchor then
    warn("[ERROR][PokemonOperationPanel:ShowPanel] anchor nil, return!")
    if PokemonOperationPanel.Instance():IsShow() then
      PokemonOperationPanel.Instance():DestroyPanel()
    end
    return
  end
  PokemonOperationPanel.Instance():_InitData(anchor)
  if PokemonOperationPanel.Instance():IsShow() then
    PokemonOperationPanel.Instance():ShowOperList()
    return
  end
  PokemonOperationPanel.Instance():CreatePanel(RESPATH.PREFAB_POKEMON_OPER_LIST, 0)
end
def.method("userdata")._InitData = function(self, anchor)
  self._anchor = anchor
end
def.override().OnCreate = function(self)
  self:SetModal(false)
  self:_InitUI()
  self:SetOutTouchDisappear()
end
def.method()._InitUI = function(self)
  self._uiObjs = {}
  self._uiObjs.tipFrame = self.m_panel:FindDirect("Table_Type")
  self._uiObjs.Btn_Convene = self.m_panel:FindDirect("Table_Type/Btn_01")
  self._uiObjs.Btn_Mine = self.m_panel:FindDirect("Table_Type/Btn_02")
  self._uiObjs.Convene_Red = self._uiObjs.Btn_Convene:FindDirect("Img_MakeRed")
  self._uiObjs.Mine_Red = self._uiObjs.Btn_Mine:FindDirect("Img_MakeRed")
end
def.override().OnDestroy = function(self)
  self:_Reset()
end
def.method()._Reset = function(self)
  self._uiObjs = nil
  self._anchor = nil
end
def.override("boolean").OnShow = function(self, show)
  self:HandleEventListeners(show)
  if show then
    self:ShowOperList()
  else
  end
end
def.method().ShowOperList = function(self)
  self:_UpdateContent()
  self:_UpdatePos()
end
def.method()._UpdateContent = function(self)
  GUIUtils.SetActive(self._uiObjs.Convene_Red, false)
  GUIUtils.SetActive(self._uiObjs.Mine_Red, PokemonModule.Instance():NeedReddot())
end
def.method()._UpdatePos = function(self)
  if self._anchor then
    local tipWidth = self._uiObjs.tipFrame:GetComponent("UISprite"):get_width()
    local tipHeight = self._uiObjs.tipFrame:GetComponent("UISprite"):get_height()
    local sourceW = self._anchor:GetComponent("UISprite"):get_width()
    local sourceH = self._anchor:GetComponent("UISprite"):get_height()
    local position = self._anchor:get_position()
    local screenPos = WorldPosToScreen(position.x, position.y)
    local targetX = screenPos.x - tipWidth / 2
    local targetY = screenPos.y + sourceH / 2
    self._uiObjs.tipFrame:set_localPosition(Vector.Vector3.new(targetX, targetY, 0))
  else
    warn("[PokemonOperationPanel:_UpdatePos] self._anchor nil!")
    self:DestroyPanel()
  end
end
def.method("string").onClick = function(self, id)
  if id == "Btn_01" then
    self:OnBtn_Convene()
  else
    if id == "Btn_02" then
      self:OnBtn_Mine()
    else
    end
  end
end
def.method().OnBtn_Convene = function(self)
  PokemonMgr.Instance():ConveneAllPokemon()
  self:DestroyPanel()
end
def.method().OnBtn_Mine = function(self)
  require("Main.Pokemon.ui.MyPokemonPanel").ShowPanel()
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
def.static("table", "table").OnFondleSuccess = function(param, context)
end
PokemonOperationPanel.Commit()
return PokemonOperationPanel
