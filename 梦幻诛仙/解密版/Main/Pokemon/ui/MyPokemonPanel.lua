local Lplus = require("Lplus")
local GUIUtils = require("GUI.GUIUtils")
local ECPanelBase = require("GUI.ECPanelBase")
local PokemonData = require("Main.Pokemon.data.PokemonData")
local PokemonUtils = require("Main.Pokemon.PokemonUtils")
local PokemonMgr = require("Main.Pokemon.PokemonMgr")
local HomelandModule = Lplus.ForwardDeclare("HomelandModule")
local MapEntityType = require("netio.protocol.mzm.gsp.map.MapEntityType")
local Vector = require("Types.Vector")
local PokemonModule
local MyPokemonPanel = Lplus.Extend(ECPanelBase, "MyPokemonPanel")
local def = MyPokemonPanel.define
local instance
def.static("=>", MyPokemonPanel).Instance = function()
  if instance == nil then
    instance = MyPokemonPanel()
  end
  return instance
end
def.const("string").IMG_REST = "Img_OnRest"
def.const("string").IMG_AWARD = "Img_ONGet"
def.const("string").IMG_MATE = "Img_OnReproduce"
def.const("number").UPDATE_INTERVAL = 1
def.field("table")._uiObjs = nil
def.field("boolean")._bSelfHomeland = true
def.field("table")._pokemonList = nil
def.field("number")._timerID = 0
def.static().ShowPanel = function()
  PokemonModule = require("Main.Pokemon.PokemonModule")
  if not PokemonModule.Instance():IsOpen(true) then
    if MyPokemonPanel.Instance():IsShow() then
      MyPokemonPanel.Instance():DestroyPanel()
    end
    return
  end
  if MyPokemonPanel.Instance():IsShow() then
    MyPokemonPanel.Instance():ShowPokemonList()
    return
  end
  MyPokemonPanel.Instance():CreatePanel(RESPATH.PREFAB_MY_POKEMON_PANEL, 0)
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
  self._uiObjs.Label_Num = self.m_panel:FindDirect("Img_Bg/Group_Feed/Label_Num")
end
def.override("boolean").OnShow = function(self, show)
  self:HandleEventListeners(show)
  if show then
    self._bSelfHomeland = HomelandModule.Instance():IsInSelfHomeland()
    self:ShowPokemonList()
    if self._bSelfHomeland then
      self._timerID = GameUtil.AddGlobalTimer(MyPokemonPanel.UPDATE_INTERVAL, false, function()
        self:_Update()
      end)
    end
  elseif HomelandModule.Instance():IsInSelfHomeland() then
    PokemonData.Instance():ClearNewEggs()
  end
end
def.method().ShowPokemonList = function(self)
  if self._bSelfHomeland then
    self._pokemonList = PokemonData.Instance():GetPokemonList()
    local curCount = self._pokemonList and #self._pokemonList or 0
    local myCourtyard = gmodule.moduleMgr:GetModule(ModuleId.HOMELAND):GetMyCourtyard()
    local curBeauty = myCourtyard and myCourtyard:GetBeauty() or 0
    local maxCount = PokemonUtils.GetYardMaxPokemonCount(curBeauty)
    local countStr = string.format(textRes.Pokemon.POKEMON_COUNT, curCount, maxCount)
    GUIUtils.SetText(self._uiObjs.Label_Num, countStr)
  else
    self._pokemonList = PokemonMgr.Instance():GetEntityInfoList()
    local curCount = self._pokemonList and #self._pokemonList or 0
    GUIUtils.SetText(self._uiObjs.Label_Num, curCount)
  end
  self:ClearPokemonList()
  if self._pokemonList == nil or #self._pokemonList <= 0 then
    warn("[MyPokemonPanel:ShowPokemonList] self._pokemonList nil!")
  else
    self._uiObjs.ScrollView:GetComponent("UIScrollView"):ResetPosition()
    self._uiObjs.uiList.itemCount = #self._pokemonList
    self._uiObjs.uiList:Resize()
    self._uiObjs.uiList:Reposition()
    for i, v in ipairs(self._pokemonList) do
      local listItem = self._uiObjs.uiList.children[i]
      self:SetListItem(i, listItem, v)
    end
  end
  self:TouchGameObject(self.m_panel, self.m_parent)
end
def.method().ClearPokemonList = function(self)
  self._uiObjs.ScrollView:GetComponent("UIScrollView"):ResetPosition()
  self._uiObjs.uiList.itemCount = 0
  self._uiObjs.uiList:Resize()
  self._uiObjs.uiList:Reposition()
end
def.method("number", "userdata", "table").SetListItem = function(self, index, listItem, pokemonInfo)
  if listItem == nil then
    warn("[ERROR][MyPokemonPanel:SetListItem] listItem nil!")
    return
  end
  if pokemonInfo == nil then
    warn("[ERROR][MyPokemonPanel:SetListItem] pokemonInfo nil!")
    return
  end
  local Img_Icon = listItem:FindDirect("Img_BgPetItem_" .. index .. "/Img_Icon_" .. index)
  local Head_Red = listItem:FindDirect("Img_BgPetItem_" .. index .. "/Img_MakeRed_" .. index)
  local Label_Name = listItem:FindDirect("Label_Name_" .. index)
  local Label_Star = listItem:FindDirect("Label_Star_" .. index)
  local Img_Sign = listItem:FindDirect("Img_BgPetItem_" .. index .. "/Img_Sign_" .. index)
  local Label_RestTime_Title = listItem:FindDirect("Label_TimeName_" .. index)
  local Label_RestTime = listItem:FindDirect("Label_RestTime_" .. index)
  local Btn_Info = listItem:FindDirect("Btn_Info_" .. index)
  local Convene_Red = listItem:FindDirect("Btn_Come_" .. index .. "/Img_MakeRed_" .. index)
  local Btn_Mate = listItem:FindDirect("Btn_Birth_" .. index)
  local Btn_Come = listItem:FindDirect("Btn_Come_" .. index)
  if pokemonInfo.stage == 0 then
    local headIconId = PokemonUtils.GetEggHeadId(pokemonInfo.eggCfgId)
    if headIconId > 0 then
      GUIUtils.SetTexture(Img_Icon, headIconId)
    else
      warn("[ERROR][MyPokemonPanel:SetListItem] headIconId iligle:", headIconId)
    end
    GUIUtils.SetActive(Head_Red, PokemonData.Instance():IsNewEgg(pokemonInfo.uuid))
    GUIUtils.SetActive(Convene_Red, PokemonData.Instance():CanFondle(pokemonInfo.uuid))
    GUIUtils.SetText(Label_Name, PokemonUtils.GetEggName(pokemonInfo.eggCfgId))
    GUIUtils.SetText(Label_Star, "")
    GUIUtils.SetActive(Img_Sign, false)
    GUIUtils.SetActive(Label_RestTime_Title, false)
    GUIUtils.SetActive(Label_RestTime, false)
    GUIUtils.SetActive(Btn_Info, false)
    GUIUtils.SetActive(Btn_Mate, false)
    GUIUtils.SetActive(Btn_Come, self._bSelfHomeland)
  else
    local headIconId = PokemonUtils.GetPokemonHeadId(pokemonInfo.adultCfgId)
    if headIconId > 0 then
      GUIUtils.SetTexture(Img_Icon, headIconId)
    else
      warn("[ERROR][MyPokemonPanel:SetListItem] headIconId iligle:", headIconId)
    end
    GUIUtils.SetActive(Head_Red, false)
    GUIUtils.SetActive(Convene_Red, pokemonInfo.awardId and 0 < pokemonInfo.awardId)
    GUIUtils.SetText(Label_Name, pokemonInfo.name)
    GUIUtils.SetActive(Img_Sign, true)
    if pokemonInfo.awardId and 0 < pokemonInfo.awardId then
      GUIUtils.SetSprite(Img_Sign, MyPokemonPanel.IMG_AWARD)
    elseif PokemonData.Instance():CanMate(pokemonInfo.uuid) then
      GUIUtils.SetSprite(Img_Sign, MyPokemonPanel.IMG_MATE)
    else
      GUIUtils.SetSprite(Img_Sign, MyPokemonPanel.IMG_REST)
    end
    local pokemonCfg = PokemonData.Instance():GetPokemonCfg(pokemonInfo.adultCfgId)
    if nil == pokemonCfg then
      warn("[ERROR][MyPokemonPanel:SetListItem] pokemonCfg nil for pokemonInfo.adultCfgId:", pokemonInfo.adultCfgId)
      return
    end
    GUIUtils.SetText(Label_Star, string.format(textRes.Pokemon.POKEMON_STAR, pokemonCfg.starType))
    if self._bSelfHomeland then
      GUIUtils.SetActive(Label_RestTime, true)
      GUIUtils.SetActive(Label_RestTime_Title, true)
      local lifeTimeStr = PokemonUtils.GetLifeTimeString(pokemonCfg.lifeTime * 3600, _G.GetServerTime() - pokemonInfo.birthTime)
      GUIUtils.SetText(Label_RestTime, lifeTimeStr)
    else
      GUIUtils.SetActive(Label_RestTime, false)
      GUIUtils.SetActive(Label_RestTime_Title, false)
    end
    GUIUtils.SetActive(Btn_Info, self._bSelfHomeland)
    GUIUtils.SetActive(Btn_Mate, not self._bSelfHomeland and pokemonInfo.canMate)
    GUIUtils.SetActive(Btn_Come, self._bSelfHomeland)
  end
end
def.method()._Update = function(self)
  self:_UpdateLifeTime()
end
def.method()._UpdateLifeTime = function(self)
  if self._pokemonList == nil or #self._pokemonList <= 0 then
    return
  end
  for index, pokemonInfo in ipairs(self._pokemonList) do
    if pokemonInfo.stage == 1 then
      local listItem = self._uiObjs.uiList.children[index]
      if listItem then
        local pokemonCfg = PokemonData.Instance():GetPokemonCfg(pokemonInfo.adultCfgId)
        if nil == pokemonCfg then
          warn("[ERROR][MyPokemonPanel:_UpdateLifeTime] pokemonCfg nil for pokemonInfo.adultCfgId:", pokemonInfo.adultCfgId)
        else
          local Label_RestTime = listItem:FindDirect("Label_RestTime_" .. index)
          GUIUtils.SetActive(Label_RestTime, true)
          local lifeTimeStr = PokemonUtils.GetLifeTimeString(pokemonCfg.lifeTime * 3600, _G.GetServerTime() - pokemonInfo.birthTime)
          GUIUtils.SetText(Label_RestTime, lifeTimeStr)
        end
      else
        warn("[ERROR][MyPokemonPanel:_UpdateLifeTime] listItem nil for at index:", index)
      end
    end
  end
end
def.override().OnDestroy = function(self)
  self:_Reset()
end
def.method()._Reset = function(self)
  self:_ClearTimer()
  self._uiObjs = nil
  self._pokemonList = nil
end
def.method()._ClearTimer = function(self)
  if self._timerID ~= 0 then
    GameUtil.RemoveGlobalTimer(self._timerID)
    self._timerID = 0
  end
end
def.method("string").onClick = function(self, id)
  if id == "Btn_Close" then
    self:OnBtn_Close()
  elseif id == "Btn_Help" then
    self:OnBtn_Help()
  elseif string.find(id, "Btn_Come_") then
    self:OnBtn_Come(id)
  elseif string.find(id, "Btn_Info_") then
    self:OnBtn_Info(id)
  else
    if string.find(id, "Btn_Birth_") then
      self:OnBtn_Mate(id)
    else
    end
  end
end
def.method().OnBtn_Close = function(self)
  self:DestroyPanel()
end
def.method().OnBtn_Help = function(self)
  local tipContent = require("Main.Common.TipsHelper").GetHoverTip(constant.CAnimalConst.ANIMAL_TIP_CFG_ID)
  local CommonUITipsDlg = require("GUI.CommonUITipsDlg")
  CommonUITipsDlg.Instance():ShowDlg(tipContent, {x = 0, y = 0})
end
def.method("string").OnBtn_Come = function(self, id)
  local btnPrefix = "Btn_Come_"
  local index = tonumber(string.sub(id, string.len(btnPrefix) + 1))
  local pokemonInfo = self._pokemonList and self._pokemonList[index] or index
  if pokemonInfo then
    local entity = gmodule.moduleMgr:GetModule(ModuleId.MAP):GetMapEntity(MapEntityType.MET_ANIMAL, pokemonInfo.uuid)
    if entity then
      Toast(textRes.Pokemon.CONVENE_SUCC)
      entity:Convene()
      self:DestroyPanel()
    else
      warn("[ERROR][MyPokemonPanel:OnBtn_Come] entity nil for uuid:", tostring(pokemonInfo.uuid))
    end
  else
    warn("[ERROR][MyPokemonPanel:OnBtn_Come] pokemonInfo nil at index:", index)
  end
end
def.method("string").OnBtn_Info = function(self, id)
  local btnPrefix = "Btn_Info_"
  local index = tonumber(string.sub(id, string.len(btnPrefix) + 1))
  local pokemonInfo = self._pokemonList and self._pokemonList[index] or index
  if pokemonInfo then
    if pokemonInfo.stage == 1 then
      local PokemonProtocols = require("Main.Pokemon.PokemonProtocols")
      PokemonProtocols.SendCGetAnimalMates(pokemonInfo.uuid)
    else
      warn("[ERROR][MyPokemonPanel:OnBtn_Info] wrong stage:", pokemonInfo.stage)
      Toast(textRes.Pokemon.ERROR_DETAIL_EGG)
    end
  else
    warn("[ERROR][MyPokemonPanel:OnBtn_Info] pokemonInfo nil at index:", index)
  end
end
def.method("string").OnBtn_Mate = function(self, id)
  local btnPrefix = "Btn_Birth_"
  local index = tonumber(string.sub(id, string.len(btnPrefix) + 1))
  local pokemonInfo = self._pokemonList and self._pokemonList[index] or index
  if pokemonInfo then
    if pokemonInfo.stage == 1 then
      local pokemonEntity = gmodule.moduleMgr:GetModule(ModuleId.MAP):GetMapEntity(MapEntityType.MET_ANIMAL, pokemonInfo.uuid)
      local PokemonMateListPanel = require("Main.Pokemon.ui.PokemonMateListPanel")
      PokemonMateListPanel.ShowPanel(pokemonEntity)
      self:DestroyPanel()
    else
      warn("[ERROR][MyPokemonPanel:OnBtn_Mate] wrong stage:", pokemonInfo.stage)
      Toast(textRes.Pokemon.POKEMON_MATE_EGG)
    end
  else
    warn("[ERROR][MyPokemonPanel:OnBtn_Mate] pokemonInfo nil at index:", index)
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
def.method().OnSyncRemoveAnimal = function(self)
  if MyPokemonPanel.Instance():IsShow() then
    MyPokemonPanel.Instance():ShowPokemonList()
  end
end
MyPokemonPanel.Commit()
return MyPokemonPanel
