local Lplus = require("Lplus")
local ECPanelBase = require("GUI.ECPanelBase")
local DlgPetFight = Lplus.Extend(ECPanelBase, "DlgPetFight")
local def = DlgPetFight.define
local dlg, fightMgr
local GUIUtils = require("GUI.GUIUtils")
local EC = require("Types.Vector3")
local Vector = require("Types.Vector")
local FightUtils = require("Main.Fight.FightUtils")
def.field("number").time = 0
def.field("number").timeToClose = 0
def.field("function").onload = nil
def.field("table").uiObjs = nil
def.field("table").petMap = nil
def.static("=>", DlgPetFight).Instance = function()
  if dlg == nil then
    dlg = DlgPetFight()
    fightMgr = require("Main.Fight.Replayer").Instance()
  end
  return dlg
end
def.override().OnCreate = function(self)
  Event.RegisterEvent(ModuleId.FIGHT, gmodule.notifyId.Fight.SKIP_ROUND_REMOVE_UNIT, DlgPetFight.OnPetDestroyed)
end
def.method().ShowDlg = function(self)
  if self.m_panel then
    self:OnShow(true)
  else
    self:CreatePanel(RESPATH.DLG_PET_FIGHT, 0)
    self:SetDepth(GUIDEPTH.BOTTOMMOST)
  end
end
def.override().OnDestroy = function(self)
  self:StopCountDownToClose()
  local effComtainer = self.m_panel:FindDirect("Effect")
  if effComtainer.childCount > 0 then
    local effInst = effComtainer:GetChild(0)
    if effInst then
      effInst:Destroy()
    end
  end
  self.uiObjs = nil
  self.petMap = nil
  Event.UnregisterEvent(ModuleId.FIGHT, gmodule.notifyId.Fight.SKIP_ROUND_REMOVE_UNIT, DlgPetFight.OnPetDestroyed)
end
def.method("string").onClick = function(self, id)
  if id == "Btn_QuitBattle" then
    require("Main.Fight.Replayer").OnFightEnd(nil)
  elseif id == "Btn_Quit" then
    fightMgr:CheckResult()
  elseif id == "Btn_NextTurn" then
    fightMgr:SkipToNextRound()
  elseif id == "Btn_LastTrun" then
    fightMgr:SkipToPrevRound()
  end
end
def.method("userdata").onClickObj = function(self, obj)
  if obj.name == "Img_BgPetHead" then
    local panel = obj.parent
    if panel and string.find(panel.name, "Img_BgPet_") then
      if self.petMap == nil then
        return
      end
      local idx = tonumber(string.sub(panel.name, #"Img_BgPet_" + 1, -1))
      local pet = self.petMap[idx]
      if pet == nil then
        return
      end
      Event.DispatchEvent(ModuleId.FIGHT, gmodule.notifyId.Fight.CLICK_PET_HEAD, {
        id = pet.roleId
      })
    end
  else
    self:onClick(obj.name)
  end
end
def.override("boolean").OnShow = function(self, s)
  if s == false then
    return
  end
  self.uiObjs = {}
  self.uiObjs.waitLabel = self.m_panel:FindDirect("Group_Top/Img_BgWait/Label_Wait")
  self.uiObjs.waitLabel:SetActive(false)
  self.uiObjs.timeLabelPanel = self.m_panel:FindDirect("Group_Top/Img_BgTime")
  self.uiObjs.timeLabel = self.uiObjs.timeLabelPanel:FindDirect("Label_TimeNum")
  local watch = self.m_panel:FindDirect("Group_Watch")
  self.uiObjs.Group_Watch = watch
  self.uiObjs.Group_End = watch:FindDirect("Group_End")
  self.uiObjs.countDownToCloseLabel = self.uiObjs.Group_End:FindDirect("Label")
  self.uiObjs.Btn_Quit = watch:FindDirect("Btn_Quit")
  self.uiObjs.Btn_QuitBattle = self.m_panel:FindDirect("Img_BgRound/Btn_QuitBattle")
  self.uiObjs.Btn_Quit:SetActive(false)
  self.uiObjs.pets = {}
  for i = 1, 5 do
    self.uiObjs.pets[i] = self.m_panel:FindDirect("Img_BgRound/Img_BgPet_" .. i)
  end
  self:ShowPets()
  if self.time > 0 then
    self:SetLabel()
  else
    self:ShowCountDown(false)
  end
  local roundLabel = self.m_panel:FindDirect("Img_BgRound/Label_RoundNum")
  roundLabel:GetComponent("UILabel").text = tostring(fightMgr.curRound)
  if self.onload then
    self.onload(self)
    self.onload = nil
  end
  if 0 < fightMgr.countDown then
    self:NextRound()
  end
  self:StartCountDownToClose()
end
def.method().SetLabel = function(self)
  if self.m_panel == nil then
    return
  end
  self:ShowCountDown(true)
  if self.uiObjs and self.uiObjs.timeLabel then
    if self.time > 0 then
      self.uiObjs.timeLabel:GetComponent("UILabel").text = tostring(self.time)
      self.uiObjs.timeLabelPanel:SetActive(true)
    else
      self.uiObjs.timeLabelPanel:SetActive(false)
    end
  end
end
def.method("table", "number").SetPetHp = function(self, pet, hp)
  if pet == nil or self.petMap == nil then
    return
  end
  for k, v in pairs(self.petMap) do
    if v.id == pet.id then
      self:SetPetHpByIdx(k, hp)
    end
  end
end
def.method("number", "number").SetPetHpByIdx = function(self, idx, hp)
  if self.uiObjs == nil then
    return
  end
  local petPanel = self.uiObjs.pets[idx]
  if petPanel == nil then
    return
  end
  petPanel:FindDirect("Slider_BloodPet"):GetComponent("UISlider").value = hp
  local uiTexture = petPanel:FindDirect("Img_BgPetHead/Img_IconPet"):GetComponent("UITexture")
  if hp <= 0 then
    GUIUtils.SetTextureEffect(uiTexture, GUIUtils.Effect.Gray)
  else
    GUIUtils.SetTextureEffect(uiTexture, GUIUtils.Effect.Normal)
  end
end
def.method("table", "number").SetPetMp = function(self, pet, mp)
  if pet == nil or self.petMap == nil then
    return
  end
  for k, v in pairs(self.petMap) do
    if v.id == pet.id then
      self:SetPetMpByIdx(k, mp)
    end
  end
end
def.method("number", "number").SetPetMpByIdx = function(self, idx, mp)
  if self.uiObjs == nil then
    return
  end
  local petPanel = self.uiObjs.pets[idx]
  if petPanel == nil then
    return
  end
  petPanel:FindDirect("Slider_BluePet"):GetComponent("UISlider").value = mp
end
def.method().ShowPets = function(self)
  local team = fightMgr.teams[fightMgr.myTeam]
  local idx = 0
  if team == nil then
    for idx = 1, 5 do
      self.uiObjs.pets[idx]:SetActive(false)
    end
    return
  end
  local k, unit
  local finished = false
  if self.petMap == nil then
    self.petMap = {}
    for idx = 1, 5 do
      if not finished then
        k, unit = next(team.fighters, k)
        if k == nil then
          finished = true
        end
      end
      self.petMap[idx] = unit
    end
  end
  local PI = require("Main.Pet.Interface")
  for idx = 1, 5 do
    unit = self.petMap[idx]
    local petPanel = self.uiObjs.pets[idx]
    local uiTexture = petPanel:FindDirect("Img_BgPetHead/Img_IconPet"):GetComponent("UITexture")
    if unit then
      petPanel:FindDirect("Label_LvPet"):GetComponent("UILabel"):set_text(tostring(unit.level))
      local pet = PI.GetPet(unit.roleId)
      local petCfgData = pet:GetPetCfgData()
      local modelCfg = require("Main.Pubrole.PubroleInterface").GetModelCfg(petCfgData.modelId)
      GUIUtils.FillIcon(uiTexture, modelCfg.headerIconId, nil)
      if unit.hpmax == 0 or unit:IsDead() then
        self:SetPetHpByIdx(idx, 0)
      else
        self:SetPetHpByIdx(idx, unit.hp / unit.hpmax)
      end
      if 0 < unit.mpmax then
        self:SetPetMpByIdx(idx, unit.mp / unit.mpmax)
      else
        self:SetPetMpByIdx(idx, 0)
      end
    else
      petPanel:FindDirect("Label_LvPet"):GetComponent("UILabel"):set_text("")
      uiTexture.mainTexture = nil
      self:SetPetHpByIdx(idx, 0)
      self:SetPetMpByIdx(idx, 0)
    end
  end
end
def.method().NextRound = function(self)
  if self.m_panel == nil then
    return
  end
  local roundLabel = self.m_panel:FindDirect("Img_BgRound/Label_RoundNum")
  roundLabel:GetComponent("UILabel").text = tostring(fightMgr.curRound)
  self:StartCountDown()
end
def.method().Hide = function(self)
  self:DestroyPanel()
end
def.method().StartCountDown = function(self)
  self.time = constant.FightConst.WAIT_CMD_TIME
  Timer:RegisterListener(DlgPetFight.Update, self)
  self:SetLabel()
end
def.method().StopCountDown = function(self)
  Timer:RemoveListener(DlgPetFight.Update)
  self.time = 0
  self:SetLabel()
end
def.method("boolean").ShowCountDown = function(self, v)
  if self.m_panel == nil then
    return
  end
  local group = self.m_panel:FindDirect("Group_Top")
  if group then
    group:SetActive(v)
  end
end
def.method("number").Update = function(self, tick)
  if fightMgr.paused then
    return
  end
  self.time = self.time - 1
  if self.time < 0 then
    self.time = 0
  end
  self:SetLabel()
end
def.method("number").SetSpetatorsNum = function(self, num)
  local g = self.m_panel:FindDirect("Group_Num")
  if num <= 0 then
    g:SetActive(false)
    return
  end
  g:FindDirect("Label_Num"):GetComponent("UILabel").text = tostring(num)
  g:SetActive(true)
end
def.method().StartCountDownToClose = function(self)
  if fightMgr:IsPetFightCVC() then
    self.timeToClose = constant.CPetBattleConsts.watchTime or 0
    Timer:RegisterListener(DlgPetFight.UpdateClosingCountDown, self)
    self:SetCloseCountDown()
    self.uiObjs.Btn_QuitBattle:SetActive(false)
  else
    self.timeToClose = 0
    self.uiObjs.Group_Watch:SetActive(false)
  end
end
def.method().StopCountDownToClose = function(self)
  Timer:RemoveListener(DlgPetFight.UpdateClosingCountDown)
  self.timeToClose = 0
end
def.method("number").UpdateClosingCountDown = function(self, tick)
  self.timeToClose = self.timeToClose - 1
  if self.timeToClose < 0 then
    self.timeToClose = 0
  end
  self:SetCloseCountDown()
  if self.timeToClose == 0 then
    self.uiObjs.Btn_Quit:SetActive(true)
    self.uiObjs.Group_End:SetActive(false)
  end
end
def.method().SetCloseCountDown = function(self)
  if self.uiObjs then
    if self.timeToClose > 0 then
      self.uiObjs.countDownToCloseLabel:GetComponent("UILabel").text = string.format(textRes.Fight[82], self.timeToClose)
      self.uiObjs.Group_End:SetActive(true)
    else
      self.uiObjs.Group_End:SetActive(false)
    end
  end
end
def.static("table", "table").OnPetDestroyed = function(p1, p2)
  local id = p1 and p1[1]
  if id and dlg.petMap then
    for idx, unit in pairs(dlg.petMap) do
      if unit.id == id then
        dlg:SetPetHpByIdx(idx, 0)
        break
      end
    end
  end
end
DlgPetFight.Commit()
return DlgPetFight
