local Lplus = require("Lplus")
local ECPanelBase = require("GUI.ECPanelBase")
local GUIUtils = require("GUI.GUIUtils")
local ECUIModel = require("Model.ECUIModel")
local Vector = require("Types.Vector")
local NPCInterface = require("Main.npc.NPCInterface")
local PokemonData = require("Main.Pokemon.data.PokemonData")
local PokemonUtils = require("Main.Pokemon.PokemonUtils")
local PokemonDetailPanel = Lplus.Extend(ECPanelBase, "PokemonDetailPanel")
local def = PokemonDetailPanel.define
local instance
def.static("=>", PokemonDetailPanel).Instance = function()
  if instance == nil then
    instance = PokemonDetailPanel()
  end
  return instance
end
def.const("number").UPDATE_INTERVAL = 1
def.const("number").MAX_HISTORY = 5
def.field("table")._uiObjs = nil
def.field("table")._pokemonCfg = nil
def.field("table")._detailInfo = nil
def.field("table")._model = nil
def.field("boolean")._bDragging = false
def.field("number")._timerID = 0
def.static("table").ShowPanel = function(detailInfo)
  if detailInfo == nil then
    warn("[ERROR][PokemonDetailPanel:ShowDlg] detailInfo nil.")
    if PokemonDetailPanel.Instance():IsShow() then
      PokemonDetailPanel.Instance():DestroyPanel()
    end
    return
  end
  PokemonDetailPanel.Instance():InitData(detailInfo)
  if PokemonDetailPanel.Instance():IsShow() then
    PokemonDetailPanel.Instance():UpdatePokemon()
  end
  instance:CreatePanel(RESPATH.PREFAB_POKEMON_DETAIL_PANEL, 0)
end
def.method("table").InitData = function(self, detailInfo)
  self._detailInfo = detailInfo
  self._pokemonCfg = PokemonData.Instance():GetPokemonCfgByInst(detailInfo.animalid)
end
def.override().OnCreate = function(self)
  instance:SetModal(true)
  self:_InitUI()
  if nil == self._pokemonCfg then
    warn("[ERROR][PokemonDetailPanel:OnCreate] pokemonCfg nil for uuid:", tostring(self._detailInfo.animalid))
    self:DestroyPanel()
  end
end
def.method()._InitUI = function(self)
  self._uiObjs = {}
  self._uiObjs.UIModel = self.m_panel:FindDirect("Img_Bg/Group_Message/Model"):GetComponent("UIModel")
  self._uiObjs.Label_LifeTime = self.m_panel:FindDirect("Img_Bg/Group_Message/Group_Info/Label_LifeTime")
  self._uiObjs.Label_Type = self.m_panel:FindDirect("Img_Bg/Group_Message/Group_Info/Label_Type")
  self._uiObjs.List_Star = self.m_panel:FindDirect("Img_Bg/Group_Message/Group_Info/List_Star")
  self._uiObjs.uiList_Star = self._uiObjs.List_Star:GetComponent("UIList")
  self._uiObjs.Label_OOXX = self.m_panel:FindDirect("Img_Bg/Group_Message/Group_Info/Label_OOXX")
  self._uiObjs.Drag_Tips = self.m_panel:FindDirect("Img_Bg/Img_Bg_Note/Scrollview_Note/Drag_Tips")
end
def.override("boolean").OnShow = function(self, show)
  self:HandleEventListeners(show)
  if show then
    self:UpdatePokemon()
  else
  end
end
def.method().UpdatePokemon = function(self)
  self:_UpdateLifeTime()
  GUIUtils.SetText(self._uiObjs.Label_Type, PokemonUtils.GetTypeName(self._pokemonCfg.id))
  self._uiObjs.uiList_Star.itemCount = self._pokemonCfg.starType
  self._uiObjs.uiList_Star:Resize()
  self._uiObjs.uiList_Star:Reposition()
  local mateCountStr = string.format(textRes.Pokemon.POKEMON_DETAIL_MATE_COUNT, self._detailInfo.mate_times)
  GUIUtils.SetText(self._uiObjs.Label_OOXX, mateCountStr)
  local mateHistoryStr = ""
  if self._detailInfo.mate_infos and #self._detailInfo.mate_infos > 0 then
    local AbsoluteTimer = require("Main.Common.AbsoluteTimer")
    for index, mateInfo in ipairs(self._detailInfo.mate_infos) do
      local roleName = mateInfo.role_name and _G.GetStringFromOcts(mateInfo.role_name) or ""
      local mateDate = AbsoluteTimer.GetServerTimeTable(mateInfo.mate_time)
      local pokemonCfg = PokemonData.Instance():GetPokemonCfg(mateInfo.animal_cfgid)
      local mateInfoStr = string.format(textRes.Pokemon.POKEMON_DETAIL_MATE_INFO, mateDate.year, mateDate.month, mateDate.day, roleName, pokemonCfg.starType, pokemonCfg.name)
      if "" ~= mateHistoryStr then
        mateHistoryStr = mateHistoryStr .. "\n"
      end
      mateHistoryStr = mateHistoryStr .. mateInfoStr
      if index >= PokemonDetailPanel.MAX_HISTORY then
        break
      end
    end
  else
    mateHistoryStr = textRes.Pokemon.POKEMON_DETAIL_MATE_INFO_ZERO
  end
  GUIUtils.SetText(self._uiObjs.Drag_Tips, mateHistoryStr)
  self:_LoadModel()
  if 0 < self._pokemonCfg.lifeTime then
    self._timerID = GameUtil.AddGlobalTimer(PokemonDetailPanel.UPDATE_INTERVAL, false, function()
      self:_Update()
    end)
  end
end
def.method()._Update = function(self)
  self:_UpdateLifeTime()
end
def.method()._UpdateLifeTime = function(self)
  if self._pokemonCfg.lifeTime > 0 then
    local liveTime = _G.GetServerTime() - self._detailInfo.birth_time
    local cfgLifeTime = self._pokemonCfg.lifeTime * 3600
    if liveTime < cfgLifeTime then
      local lifeTimeStr = PokemonUtils.GetLifeTimeString(cfgLifeTime, liveTime)
      GUIUtils.SetText(self._uiObjs.Label_LifeTime, lifeTimeStr)
    else
      self:DestroyPanel()
      return
    end
  else
    GUIUtils.SetText(self._uiObjs.Label_LifeTime, textRes.Pokemon.POKEMON_DETAIL_LIFE_TIME_FOREVER)
  end
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
    warn("[ERROR][PokemonDetailPanel:_LoadModel] npccfg nil for npcid: ", self._pokemonCfg.npcCfgid)
  end
end
def.method()._ClearTimer = function(self)
  if self._timerID ~= 0 then
    GameUtil.RemoveGlobalTimer(self._timerID)
    self._timerID = 0
  end
end
def.override().OnDestroy = function(self)
  self:_ClearTimer()
  if self._model then
    self._model:Destroy()
    self._model = nil
  end
  self._pokemonCfg = nil
  self._detailInfo = nil
  self._uiObjs = nil
end
def.method("string").onClick = function(self, id)
  if id == "Btn_Close" then
    self:DestroyPanel()
  elseif id == "Img_PetBg" then
    self._model:PlayAnim("Run_c", function()
      self._model:Play("Stand_c")
    end)
  end
end
def.method("string").onDragStart = function(self, id)
  if id == "Img_Flower" then
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
PokemonDetailPanel.Commit()
return PokemonDetailPanel
