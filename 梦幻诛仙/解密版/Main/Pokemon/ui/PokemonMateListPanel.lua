local Lplus = require("Lplus")
local GUIUtils = require("GUI.GUIUtils")
local ECPanelBase = require("GUI.ECPanelBase")
local PokemonData = require("Main.Pokemon.data.PokemonData")
local PokemonProtocols = require("Main.Pokemon.PokemonProtocols")
local PokemonUtils = require("Main.Pokemon.PokemonUtils")
local PokemonMgr = require("Main.Pokemon.PokemonMgr")
local HomelandModule = Lplus.ForwardDeclare("HomelandModule")
local Vector = require("Types.Vector")
local PokemonModule, PokemonEntity
local PokemonMateListPanel = Lplus.Extend(ECPanelBase, "PokemonMateListPanel")
local def = PokemonMateListPanel.define
local instance
def.static("=>", PokemonMateListPanel).Instance = function()
  if instance == nil then
    instance = PokemonMateListPanel()
  end
  return instance
end
def.field("table")._uiObjs = nil
def.field("table")._mateList = nil
def.field("number")._curSelectIndex = 0
def.field("table")._targetPokemonEntity = nil
def.static("table").ShowPanel = function(targetPokemonEntity)
  PokemonModule = require("Main.Pokemon.PokemonModule")
  PokemonEntity = require("Main.Map.entity.PokemonEntity")
  if not PokemonModule.Instance():IsOpen(true) then
    if PokemonMateListPanel.Instance():IsShow() then
      PokemonMateListPanel.Instance():DestroyPanel()
    end
    return
  end
  if nil == targetPokemonEntity then
    if PokemonMateListPanel.Instance():IsShow() then
      PokemonMateListPanel.Instance():DestroyPanel()
    end
    warn("[ERROR][PokemonMateListPanel:ShowPanel] targetPokemonEntity nil!")
    return
  end
  PokemonMateListPanel.Instance():InitData(targetPokemonEntity)
  if PokemonMateListPanel.Instance():IsShow() then
    PokemonMateListPanel.Instance():ShowHatch()
    return
  end
  PokemonMateListPanel.Instance():CreatePanel(RESPATH.PREFAB_POKEMON_MATE_LIST, 0)
end
def.method("table").InitData = function(self, targetPokemonEntity)
  self._targetPokemonEntity = targetPokemonEntity
end
def.override().OnCreate = function(self)
  self:SetModal(false)
  self:_InitUI()
  self:SetOutTouchDisappear()
end
def.method()._InitUI = function(self)
  self._uiObjs = {}
  self._uiObjs.ScrollView = self.m_panel:FindDirect("Img_Bg/Group_PetList/Scrollview_PetList")
  self._uiObjs.List = self._uiObjs.ScrollView:FindDirect("List")
  self._uiObjs.uiList = self._uiObjs.List:GetComponent("UIList")
end
def.override().OnDestroy = function(self)
  self:_Reset()
end
def.method()._Reset = function(self)
  self._uiObjs = nil
  self._mateList = nil
  self._curSelectIndex = 0
  self._targetPokemonEntity = nil
end
def.override("boolean").OnShow = function(self, show)
  self:HandleEventListeners(show)
  if show then
    self:ShowMateList()
    Event.DispatchEvent(ModuleId.POKEMON, gmodule.notifyId.Pokemon.MATE_PANEL_SHOW, {
      entity = self._targetPokemonEntity
    })
  else
    Event.DispatchEvent(ModuleId.POKEMON, gmodule.notifyId.Pokemon.MATE_PANEL_HIDE, {
      entity = self._targetPokemonEntity
    })
  end
end
def.method().ShowMateList = function(self)
  self:ClearMateList()
  self._mateList = PokemonData.Instance():GetMateList()
  if self._mateList == nil or #self._mateList <= 0 then
    warn("[PokemonMateListPanel:ShowMateList] self._mateList nil!")
    return
  end
  self._uiObjs.ScrollView:GetComponent("UIScrollView"):ResetPosition()
  self._uiObjs.uiList.itemCount = #self._mateList
  self._uiObjs.uiList:Resize()
  self._uiObjs.uiList:Reposition()
  for i, v in ipairs(self._mateList) do
    local listItem = self._uiObjs.uiList.children[i]
    self:SetListItem(i, listItem, v)
  end
  self:TouchGameObject(self.m_panel, self.m_parent)
  self:_CheckToggle(1)
end
def.method().ClearMateList = function(self)
  self._uiObjs.ScrollView:GetComponent("UIScrollView"):ResetPosition()
  self._uiObjs.uiList.itemCount = 0
  self._uiObjs.uiList:Resize()
  self._uiObjs.uiList:Reposition()
end
def.method("number", "userdata", "table").SetListItem = function(self, index, listItem, pokemonInfo)
  if listItem == nil then
    warn("[ERROR][PokemonMateListPanel:SetListItem] listItem nil!")
    return
  end
  if pokemonInfo == nil then
    warn("[ERROR][PokemonMateListPanel:SetListItem] pokemonInfo nil!")
    return
  end
  local headIconId = PokemonUtils.GetPokemonHeadId(pokemonInfo.adultCfgId)
  if headIconId > 0 then
    local Img_Icon = listItem:FindDirect("Img_BgPetItem_" .. index .. "/Img_Icon_" .. index)
    GUIUtils.SetTexture(Img_Icon, headIconId)
  else
    warn("[ERROR][PokemonMateListPanel:SetListItem] headIconId iligle:", headIconId)
  end
  local Label_Name = listItem:FindDirect("Label_Name_" .. index)
  GUIUtils.SetText(Label_Name, pokemonInfo.name)
  local pokemonCfg = PokemonData.Instance():GetPokemonCfg(pokemonInfo.adultCfgId)
  if pokemonCfg then
    local Label_Star = listItem:FindDirect("Label_Star_" .. index)
    GUIUtils.SetText(Label_Star, string.format(textRes.Pokemon.POKEMON_STAR, pokemonCfg.starType))
  else
    warn("[ERROR][PokemonMateListPanel:SetListItem] pokemonCfg nil for pokemonInfo.adultCfgId:", pokemonInfo.adultCfgId)
    return
  end
end
def.method("number")._CheckToggle = function(self, index)
  local listItem = self._uiObjs.uiList.children[index]
  if listItem then
    local Toggle_Cicrle = listItem:FindDirect("Toggle_Cicrle_" .. index)
    if Toggle_Cicrle then
      GUIUtils.Toggle(Toggle_Cicrle, true)
    else
      warn("[ERROR][PokemonMateListPanel:_CheckToggle] Toggle_Cicrle nil at index:", index)
    end
  else
    warn("[ERROR][PokemonMateListPanel:_CheckToggle] listItem nil at index:", index)
  end
end
def.method("string", "boolean").onToggle = function(self, id, active)
  local togglePrefix = "Toggle_Cicrle_"
  if active and string.find(id, togglePrefix) then
    local index = tonumber(string.sub(id, string.len(togglePrefix) + 1))
    warn(string.format("[PokemonMateListPanel:onToggle] toggle [%d] checked.", index))
    self._curSelectIndex = index
  end
end
def.method("string").onClick = function(self, id)
  if id == "Btn_Close" then
    self:OnBtn_Close()
  else
    if id == "Btn_Confirm" then
      self:OnBtn_Confirm()
    else
    end
  end
end
def.method().OnBtn_Close = function(self)
  self:DestroyPanel()
end
def.method().OnBtn_Confirm = function(self)
  warn("[PokemonMateListPanel:OnBtn_Touch] On Btn_Touch!")
  local selectPokemonInfo = self._mateList and self._mateList[self._curSelectIndex] or nil
  local selectPokemonUuid = selectPokemonInfo and selectPokemonInfo.uuid or nil
  local targetPokemonUuid = self._targetPokemonEntity.instanceid
  if selectPokemonUuid and targetPokemonUuid then
    PokemonProtocols.SendCAnimalMate(selectPokemonUuid, targetPokemonUuid)
    self:DestroyPanel()
  elseif nil == selectPokemonUuid then
    warn("[ERROR][PokemonMateListPanel:OnBtn_Confirm] selectPokemonUuid nil for index:", self._curSelectIndex)
  else
    warn("[ERROR][PokemonMateListPanel:OnBtn_Confirm] targetPokemonUuid nil!")
  end
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
PokemonMateListPanel.Commit()
return PokemonMateListPanel
