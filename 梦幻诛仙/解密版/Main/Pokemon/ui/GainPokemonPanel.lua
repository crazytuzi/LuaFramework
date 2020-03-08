local Lplus = require("Lplus")
local ECPanelBase = require("GUI.ECPanelBase")
local GUIUtils = require("GUI.GUIUtils")
local ECUIModel = require("Model.ECUIModel")
local Vector = require("Types.Vector")
local NPCInterface = require("Main.npc.NPCInterface")
local GainPokemonPanel = Lplus.Extend(ECPanelBase, "GainPokemonPanel")
local def = GainPokemonPanel.define
local instance
def.static("=>", GainPokemonPanel).Instance = function()
  if instance == nil then
    instance = GainPokemonPanel()
  end
  return instance
end
def.field("table")._uiObjs = nil
def.field("table")._pokemonCfg = nil
def.field("table")._model = nil
def.field("boolean")._bDragging = false
def.field("userdata")._effect = nil
def.static("table").ShowPanel = function(pokemonCfg)
  if pokemonCfg == nil then
    warn("[ERROR][GainPokemonPanel:ShowDlg] pokemonCfg nil.")
    if GainPokemonPanel.Instance():IsShow() then
      GainPokemonPanel.Instance():DestroyPanel()
    end
    return
  end
  GainPokemonPanel.Instance():InitData(pokemonCfg)
  instance:CreatePanel(RESPATH.PREFAB_HATCH_SUCC, 0)
end
def.method("table").InitData = function(self, pokemonCfg)
  self._pokemonCfg = pokemonCfg
end
def.override().OnCreate = function(self)
  instance:SetModal(true)
  self:_InitUI()
  gmodule.moduleMgr:GetModule(ModuleId.HERO):Stop()
  self:SetOutTouchDisappear()
end
def.method()._InitUI = function(self)
  self._uiObjs = {}
  self._uiObjs.Label_Title = self.m_panel:FindDirect("Img_Bg/Label_Title")
  self._uiObjs.Img_PetBg = self.m_panel:FindDirect("Img_Bg/Img_PetBg")
  self._uiObjs.UIModel = self.m_panel:FindDirect("Img_Bg/Img_PetBg/Model"):GetComponent("UIModel")
  self._uiObjs.Label_Name = self.m_panel:FindDirect("Img_Bg/Img_PetBg/Img_BgName/Label")
end
def.override("boolean").OnShow = function(self, show)
  self:HandleEventListeners(show)
  if show then
    self:UpdatePokemon()
  else
  end
end
def.override().OnDestroy = function(self)
  if self._model then
    self._model:Destroy()
  end
  self:_DestroyEffect()
end
def.method().UpdatePokemon = function(self)
  GUIUtils.SetText(self._uiObjs.Label_Title, textRes.Pokemon.GAIN_POKEMON_TITLE)
  local name = string.format(textRes.Pokemon.GAIN_POKEMON_NAME, self._pokemonCfg.starType, self._pokemonCfg.name)
  GUIUtils.SetText(self._uiObjs.Label_Name, name)
  self:_LoadModel()
  self:_PlayEffect()
end
def.method()._LoadModel = function(self)
  local npcCfg = NPCInterface.GetNPCCfg(self._pokemonCfg.npcCfgid)
  if npcCfg then
    if self._uiObjs.UIModel.mCanOverflow ~= nil then
      self._uiObjs.UIModel.mCanOverflow = true
      local camera = self._uiObjs.UIModel:get_modelCamera()
      camera:set_orthographic(true)
    end
    local modelPath = GetModelPath(npcCfg.monsterModelTableId)
    self._model = ECUIModel.new(npcCfg.monsterModelTableId)
    self._model:LoadUIModel(modelPath, function(ret)
      if self.m_panel and not self.m_panel.isnil then
        self._model:SetDir(180)
        self._model:SetScale(1)
        self._model:Play("Stand_c")
        self._uiObjs.UIModel.modelGameObject = self._model.m_model
        if npcCfg.dyeMode > 0 then
          local colorcfg = GetModelColorCfg(npcCfg.dyeMode)
          self._model:SetColoration(colorcfg)
        end
      end
    end)
  else
    warn("[ERROR][GainPokemonPanel:_LoadModel] npccfg nil for npcid: ", self._pokemonCfg.npcCfgid)
  end
end
def.method()._PlayEffect = function(self)
  if self._uiObjs.Img_PetBg then
    if nil == self._effect then
      local effectCfg = GetEffectRes(constant.CAnimalConst.EMBRYO_TO_ANIMAL_EFFECT_CFG_ID)
      self._effect = require("Fx.GUIFxMan").Instance():PlayAsChild(self._uiObjs.Img_PetBg, effectCfg and effectCfg.path, 0, 0, -1, false)
    end
  else
    warn("[ERROR][GainPokemonPanel:_PlayEffect] self._uiObjs.Img_PetBg nil, play failed.")
  end
end
def.method()._DestroyEffect = function(self)
  if self._effect then
    self._effect:Destroy()
    self._effect = nil
  end
end
def.method("string").onClick = function(self, id)
  if id == "Btn_Confirm" then
    self:DestroyPanel()
  elseif id == "Img_PetBg" then
    self._model:PlayAnim("Run_c", function()
      self._model:Play("Stand_c")
    end)
  end
end
def.method("string").onDragStart = function(self, id)
  if id == "Img_PetBg" then
    self._bDragging = true
  end
end
def.method("string").onDragEnd = function(self, id)
  self._bDragging = false
end
def.method("string", "number", "number").onDrag = function(self, id, dx, dy)
  if self._bDragging then
    self._model:SetDir(self._model.m_ang - dx / 2)
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
GainPokemonPanel.Commit()
return GainPokemonPanel
