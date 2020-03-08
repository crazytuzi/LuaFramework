local Lplus = require("Lplus")
local ECPanelBase = require("GUI.ECPanelBase")
local DlgFight = Lplus.Extend(ECPanelBase, "DlgFight")
local def = DlgFight.define
local dlg, fightMgr
local ACT_TYPE = require("consts.mzm.gsp.fight.confbean.OperateType")
local GameUnitType = require("consts/mzm/gsp/common/confbean/GameUnitType")
local dlgSelectSkill = require("Main.Fight.ui.DlgSelectSkill").Instance()
local dlgPetSkill = require("Main.Fight.ui.DlgPetSkill").Instance()
local SkillType = require("consts.mzm.gsp.skill.confbean.SkillType")
local GUIUtils = require("GUI.GUIUtils")
local EC = require("Types.Vector3")
local Vector = require("Types.Vector")
local FightUtils = require("Main.Fight.FightUtils")
DlgFight.ButtonGroupId = {
  NONE = 0,
  CHAR = 1,
  PET = 2,
  UNAUTO = 3,
  SELECT = 4,
  AUTO = 5,
  WATCH = 6,
  MENU = 7
}
def.field("number").time = 0
def.field("table").buttonGroups = nil
def.field("function").onload = nil
def.field("boolean").firstRun = true
def.field("number").curGroup = DlgFight.ButtonGroupId.CHAR
def.field("table").btnPosStep = nil
def.field("table").autoSkills = nil
def.static("=>", DlgFight).Instance = function()
  if dlg == nil then
    dlg = DlgFight()
    fightMgr = require("Main.Fight.FightMgr").Instance()
  end
  return dlg
end
def.override().OnCreate = function(self)
  Event.RegisterEvent(ModuleId.FIGHT, gmodule.notifyId.Fight.NEXT_ROUND, DlgFight.SetRound)
  Event.RegisterEvent(ModuleId.FIGHT, gmodule.notifyId.Fight.DEFAULT_SKILL_CHANGED, DlgFight.OnAutoSkillChanged)
  Event.RegisterEvent(ModuleId.FIGHT, gmodule.notifyId.Fight.SHOW_UI_EFFECT, DlgFight.ShowUIEffect)
  Event.RegisterEvent(ModuleId.FIGHT, gmodule.notifyId.Fight.PET_REMOVED, DlgFight.OnRemovePet)
end
def.method().ShowDlg = function(self)
  if self.m_panel then
    self:OnShow(true)
  else
    self:CreatePanel(RESPATH.DLG_FIGHT_MAIN, 0)
    self:SetDepth(GUIDEPTH.BOTTOMMOST)
    self:SetHideOnDestroy(true)
  end
  self.firstRun = true
end
def.override().OnDestroy = function(self)
  local effComtainer = self.m_panel:FindDirect("Effect")
  if effComtainer.childCount > 0 then
    local effInst = effComtainer:GetChild(0)
    if effInst then
      effInst:Destroy()
    end
  end
  Event.UnregisterEvent(ModuleId.FIGHT, gmodule.notifyId.Fight.NEXT_ROUND, DlgFight.SetRound)
  Event.UnregisterEvent(ModuleId.FIGHT, gmodule.notifyId.Fight.DEFAULT_SKILL_CHANGED, DlgFight.OnAutoSkillChanged)
  Event.UnregisterEvent(ModuleId.FIGHT, gmodule.notifyId.Fight.SHOW_UI_EFFECT, DlgFight.ShowUIEffect)
  self.autoSkills = nil
end
def.method("string").onClick = function(self, id)
  Event.DispatchEvent(ModuleId.FIGHT, gmodule.notifyId.Fight.CLOSE_SECOND_LEVEL_UI, nil)
  if id == "Btn_Character01" or id == "Btn_Pet01" or id == "Btn_unAuto01" then
    fightMgr:SetAutoFightStatus(true)
  elseif id == "Btn_Character02" or id == "Btn_Pet02" then
    fightMgr:SetAction(ACT_TYPE.OP_SKILL, constant.FightConst.DEFENCE_SKILL)
  elseif id == "Btn_Character03" or id == "Btn_Pet03" then
    fightMgr:SetAction(ACT_TYPE.OP_PROTECT, 0)
    self:ShowSelectSkill({
      icon = 7013,
      name = textRes.Fight[21],
      simpleDesc = constant.FightConst.PROTECT_DES
    })
  elseif id == "Btn_Character04" then
    require("Main.Fight.ui.DlgSelectPet").Instance():ShowDlg()
  elseif id == "Btn_Character05" then
    fightMgr:SetAction(ACT_TYPE.OP_CAPTURE, 0)
    self:ShowSelectSkill({
      icon = 7014,
      name = textRes.Fight[22],
      simpleDesc = constant.FightConst.CAPTURE_DES
    })
  elseif id == "Btn_Character06" or id == "Btn_Pet04" then
    if fightMgr.sceneInfo and not fightMgr.sceneInfo.escapeAllowed then
      Toast(textRes.Fight[35])
      return
    end
    if self.firstRun then
      require("GUI.CommonConfirmDlg").ShowConfirm("", textRes.Fight[1], function(i, tag)
        if i == 1 then
          fightMgr:SetAction(ACT_TYPE.OP_ESCAPE, 0)
          self.firstRun = false
        end
      end, {id = self})
    else
      fightMgr:SetAction(ACT_TYPE.OP_ESCAPE, 0)
    end
  elseif id == "Btn_Character07" or id == "Btn_Pet05" then
    require("Main.Fight.ui.DlgUseItem").Instance():ShowDlg()
  elseif id == "Btn_Character08" or id == "Btn_Pet06" then
    local unit = fightMgr:GetCurrentControllable()
    if unit == nil then
      return
    end
    local skillId = FightUtils.GetNormalAttackSkillId(unit.menpai)
    fightMgr:SetAction(ACT_TYPE.OP_SKILL, skillId)
    local skill = GetSkillCfg(skillId)
    self:ShowSelectSkill(skill)
  elseif id == "Btn_Character09" then
    dlgSelectSkill.isAuto = false
    if not dlgSelectSkill:ShowDlg(SkillType.SPECIAL) then
      Toast(textRes.Fight[6])
    end
  elseif id == "Btn_Character10" or id == "Btn_Pet07" then
    local unit = fightMgr:GetCurrentControllable()
    if unit == nil then
      return
    end
    local dlgSkill
    if unit.fightUnitType == GameUnitType.ROLE then
      dlgSkill = dlgSelectSkill
    elseif unit.fightUnitType == GameUnitType.PET or unit.fightUnitType == GameUnitType.CHILDREN then
      dlgSkill = dlgPetSkill
    end
    if dlgSkill == nil then
      return
    end
    dlgSkill.isAuto = false
    if not dlgSkill:ShowDlg(bit.bor(SkillType.PHY, SkillType.MGC)) then
      Toast(textRes.Fight[5])
    end
  elseif id == "Btn_Character11" or id == "Btn_Pet08" then
    local unit = fightMgr:GetCurrentControllable()
    if unit == nil then
      return
    end
    local skillId
    if unit.fightUnitType == GameUnitType.ROLE then
      skillId = fightMgr.role_shortcut_skill
    elseif unit.fightUnitType == GameUnitType.PET then
      skillId = fightMgr.pet_shortcut_skill[unit.roleId:tostring()]
    elseif unit.fightUnitType == GameUnitType.CHILDREN then
      skillId = fightMgr.child_shortcut_skill[unit.roleId:tostring()]
    end
    if skillId then
      local usedData = unit.skillUsedData[skillId]
      if usedData and usedData.skillUseRound and fightMgr.curRound <= usedData.skillUseRound then
        Toast(textRes.Fight[46])
        return
      end
      fightMgr:SetAction(ACT_TYPE.OP_SKILL, skillId)
      local skill = GetSkillCfg(_G.GetOriginalSkill(skillId))
      self:ShowSelectSkill(skill)
    else
      warn("no short cut skill found", unit.name)
    end
  elseif id == "Btn_Character12" then
    fightMgr:SetAction(FightConst.ACTION_COMMAND, -1)
    self:ShowSelectSkill({
      icon = 734,
      name = textRes.Fight[50],
      simpleDesc = textRes.Fight[51]
    })
  elseif id == "Btn_Back" then
    dlg:GoBack()
  elseif id == "Btn_Auto01" then
    fightMgr:SetAutoFightStatus(false)
    local unit = fightMgr:GetCurrentControllable()
    if unit then
      if unit.fightUnitType == GameUnitType.ROLE then
        self:ShowButtonGroup(DlgFight.ButtonGroupId.CHAR)
      elseif unit.fightUnitType == GameUnitType.PET or unit.fightUnitType == GameUnitType.CHILDREN then
        self:ShowButtonGroup(DlgFight.ButtonGroupId.PET)
      end
    else
      self:ShowButtonGroup(DlgFight.ButtonGroupId.AUTO)
    end
  elseif id == "Btn_Auto02" then
    dlgPetSkill.unit = fightMgr:GetMyPet()
    if dlgPetSkill.unit == nil then
      return
    end
    dlgPetSkill.isAuto = true
    dlgPetSkill:ShowDlg(-1)
  elseif id == "Btn_Auto03" then
    dlgSelectSkill.unit = fightMgr:GetMyHero()
    dlgSelectSkill.isAuto = true
    dlgSelectSkill:ShowDlg(bit.bor(SkillType.PHY, SkillType.MGC))
  elseif id == "Btn_GJ" then
    gmodule.moduleMgr:GetModule(ModuleId.ONHOOK)
    Event.DispatchEvent(ModuleId.MAINUI, gmodule.notifyId.MainUI.BTN_AUTOFIGHT_CLICK, nil)
  elseif id == "Btn_Quit" then
    if fightMgr:IsObserverMode() then
      gmodule.network.sendProtocol(require("netio.protocol.mzm.gsp.fight.CObserveEndReq").new())
    end
  elseif id == "Btn_unAuto02" or id == "Btn_Auto04" then
    Event.DispatchEvent(ModuleId.MAINUI, gmodule.notifyId.MainUI.BTN_BAG_CLICK, nil)
  elseif string.find(id, "Img_BgZf") then
    local index = tonumber(string.sub(id, string.len("Img_BgZf") + 1))
    local DlgFormationTip = require("Main.Formation.ui.DlgFormationTip")
    local tip = DlgFormationTip()
    local function ShowFormationNumber(param)
      if not fightMgr.isInFight then
        return
      end
      local team = param[1]
      local isshow = param[2]
      for idx = 6, 10 do
        local unit = team:GetFightUnitByPos(idx)
        if unit and unit.model then
          if isshow then
            local power = 8 - idx
            local flag = 0
            if power < 0 then
              power = math.abs(power)
              flag = 1
            end
            local formationPos = math.pow(2, power) + flag
            unit.model:SetFormationNumber(formationPos)
          else
            unit.model:RemoveFormationNumber()
          end
        end
      end
    end
    if index == 1 and fightMgr.teams[2].formationInfo then
      ShowFormationNumber({
        fightMgr.teams[2],
        true
      })
      tip:ShowFormationTip(fightMgr.teams[2].formationInfo, fightMgr.teams[1].formationInfo, -1, ShowFormationNumber, {
        fightMgr.teams[2],
        false
      })
    elseif index == 2 and fightMgr.teams[1].formationInfo then
      ShowFormationNumber({
        fightMgr.teams[1],
        true
      })
      tip:ShowFormationTip(fightMgr.teams[1].formationInfo, fightMgr.teams[2].formationInfo, 1, ShowFormationNumber, {
        fightMgr.teams[1],
        false
      })
    end
  end
end
def.method("string").onLongPress = function(self, objName)
  if objName == "Btn_Auto02" then
    if self.autoSkills and self.autoSkills[2] then
      local obj = self.m_panel:FindDirect("Group_AutoBtn/Btn_Auto02")
      local pet = fightMgr:GetMyPet()
      if pet == nil then
        return
      end
      local skillData = require("Main.Skill.data.SkillData")()
      skillData.id = self.autoSkills[2]
      skillData.level = pet.level
      require("Main.Pet.PetUtility").ShowPetSkillDataTip(skillData, obj, -1)
    end
  elseif objName == "Btn_Auto03" then
    if self.autoSkills and self.autoSkills[1] then
      local obj = self.m_panel:FindDirect("Group_AutoBtn/Btn_Auto03")
      local position = obj:get_position()
      local screenPos = WorldPosToScreen(position.x, position.y)
      local widget = obj:GetComponent("UIWidget")
      local skillData = require("Main.Skill.data.SkillData")()
      skillData.id = self.autoSkills[1]
      local skillList = fightMgr:GetRoleSkillList()
      skillData.level = skillList and skillList[skillData.id] or 1
      require("Main.Skill.SkillTipMgr").Instance():ShowTip(skillData, screenPos.x, screenPos.y, widget.width, widget.height, 0)
    end
  elseif objName == "Btn_Character11" then
    local skillId = fightMgr.role_shortcut_skill
    local obj = self.m_panel:FindDirect("Group_CharacterBtn/Btn_Character11")
    local position = obj:get_position()
    local screenPos = WorldPosToScreen(position.x, position.y)
    local widget = obj:GetComponent("UIWidget")
    local skillData = require("Main.Skill.data.SkillData")()
    skillData.id = _G.GetOriginalSkill(skillId)
    local skillList = fightMgr:GetRoleSkillList()
    skillData.level = skillList and skillList[skillId] or 1
    require("Main.Skill.SkillTipMgr").Instance():ShowTip(skillData, screenPos.x, screenPos.y, widget.width, widget.height, 0)
  elseif objName == "Btn_Pet08" then
    local unit = fightMgr:GetCurrentControllable()
    if unit == nil then
      return
    end
    local skillId
    if unit.fightUnitType == GameUnitType.PET then
      skillId = fightMgr.pet_shortcut_skill[unit.roleId:tostring()]
    elseif unit.fightUnitType == GameUnitType.CHILDREN then
      skillId = fightMgr.child_shortcut_skill[unit.roleId:tostring()]
    end
    if skillId == nil then
      return
    end
    local obj = self.m_panel:FindDirect("Group_PetBtn/Btn_Pet08")
    local skillData = require("Main.Skill.data.SkillData")()
    skillData.id = skillId
    skillData.level = unit.level
    require("Main.Pet.PetUtility").ShowPetSkillDataTip(skillData, obj, -1)
  end
end
def.method().GoBack = function(self)
  dlg:ShowAutoSkill()
  local unit = fightMgr:GetCurrentControllable()
  if unit then
    if unit.actionType == FightConst.ACTION_COMMAND then
    elseif not FightUtils.IsNormalAttack(unit.menpai, unit.skillId) and unit.actionType ~= ACT_TYPE.OP_PROTECT then
      if unit.fightUnitType == GameUnitType.ROLE then
        dlgSelectSkill.isAuto = false
        dlgSelectSkill:ShowDlg(-1)
      elseif unit.fightUnitType == GameUnitType.PET then
        dlgPetSkill.isAuto = false
        dlgPetSkill:ShowDlg(-1)
      end
    end
    fightMgr:SetAction(ACT_TYPE.OP_SKILL, FightUtils.GetNormalAttackSkillId(unit.menpai))
    fightMgr:ShowAllValidTargets(unit, true)
  end
end
def.override("boolean").OnShow = function(self, s)
  if s == false then
    return
  end
  self.buttonGroups = {}
  local charPanel = self.m_panel:FindDirect("Group_CharacterBtn")
  self.buttonGroups[DlgFight.ButtonGroupId.CHAR] = charPanel
  self.buttonGroups[DlgFight.ButtonGroupId.PET] = self.m_panel:FindDirect("Group_PetBtn")
  self.buttonGroups[DlgFight.ButtonGroupId.UNAUTO] = self.m_panel:FindDirect("Group_AutoBtn")
  self.buttonGroups[DlgFight.ButtonGroupId.SELECT] = self.m_panel:FindDirect("Group_Choose")
  self.buttonGroups[DlgFight.ButtonGroupId.AUTO] = self.m_panel:FindDirect("Group_unAutoBtn")
  self.buttonGroups[DlgFight.ButtonGroupId.WATCH] = self.m_panel:FindDirect("Group_Watch")
  self:SetCharBtnPos()
  self:SetPetBtnPos()
  local panel = self.buttonGroups[DlgFight.ButtonGroupId.PET]
  panel:FindDirect("Btn_Pet08"):SetActive(false)
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
  if self.curGroup == DlgFight.ButtonGroupId.NONE then
    warn("DlgFight load set group to none")
  end
  self:ShowAutoSkill()
  DlgFight.SetRound(nil, nil)
  if require("Main.Fight.Replayer").Instance().isInFight then
    self:SetVisible(false)
  end
end
def.method("boolean").SetVisible = function(self, visible)
  if self.m_panel then
    self.m_panel:SetActive(visible)
  end
end
def.method().SetCharBtnPos = function(self)
  local btnName, btn
  local hBtns, vBtns = {}, {}
  local charPanel = self.buttonGroups[DlgFight.ButtonGroupId.CHAR]
  for i = 2, 6 do
    btnName = string.format("Btn_Character%02d", i)
    btn = charPanel:FindDirect(btnName)
    table.insert(hBtns, btn)
    btnName = string.format("Btn_Character%02d", i + 5)
    btn = charPanel:FindDirect(btnName)
    table.insert(vBtns, btn)
  end
  btn = charPanel:FindDirect("Btn_Character12")
  table.insert(hBtns, btn)
  if self.btnPosStep == nil then
    self.btnPosStep = {}
    self.btnPosStep.x = hBtns[1].localPosition.x - hBtns[2].localPosition.x
    self.btnPosStep.y = vBtns[2].localPosition.y - vBtns[1].localPosition.y
  end
  local heroProp = require("Main.Hero.Interface").GetHeroProp()
  local mylevel = heroProp and heroProp.level or 1
  local reqLevel = constant.FightConst.DEFENSE_BT_OPEN_LEVEL
  hBtns[1]:SetActive(mylevel >= reqLevel)
  reqLevel = constant.FightConst.ATTACK_BT_OPEN_LEVEL
  vBtns[2]:SetActive(mylevel >= reqLevel)
  reqLevel = constant.FightConst.CAPTURE_BT_OPEN_LEVEL
  hBtns[4]:SetActive(mylevel >= reqLevel)
  reqLevel = constant.FightConst.SUMMON_BT_OPEN_LEVEL
  hBtns[3]:SetActive(mylevel >= reqLevel)
  reqLevel = constant.FightConst.ITEM_BT_OPEN_LEVEL
  vBtns[1]:SetActive(mylevel >= reqLevel)
  reqLevel = constant.FightConst.ESCAPE_BT_OPEN_LEVEL
  hBtns[5]:SetActive(mylevel >= reqLevel)
  reqLevel = constant.FightConst.PROTECT_BT_OPEN_LEVEL
  hBtns[2]:SetActive(mylevel >= reqLevel)
  reqLevel = constant.FightConst.SPECIAL_SKILL_BT_OPEN_LEVEL
  vBtns[3]:SetActive(mylevel >= reqLevel)
  reqLevel = constant.FightConst.COMMAND_BT_OPEN_LEVEL
  hBtns[6]:SetActive(mylevel >= reqLevel)
  local count = 0
  for i = 1, #hBtns do
    if hBtns[i].activeSelf then
      hBtns[i].localPosition = Vector.Vector3.new(hBtns[1].localPosition.x - self.btnPosStep.x * count, hBtns[1].localPosition.y, hBtns[1].localPosition.z)
      count = count + 1
    end
  end
  count = 0
  for i = 1, #vBtns do
    if vBtns[i].activeSelf or i == #vBtns then
      vBtns[i].localPosition = Vector.Vector3.new(vBtns[1].localPosition.x, vBtns[1].localPosition.y + self.btnPosStep.y * count, vBtns[1].localPosition.z)
      count = count + 1
    end
  end
end
def.method().SetPetBtnPos = function(self)
  local btnName, btn
  local hBtns, vBtns = {}, {}
  local charPanel = self.buttonGroups[DlgFight.ButtonGroupId.PET]
  for i = 2, 4 do
    btnName = string.format("Btn_Pet%02d", i)
    btn = charPanel:FindDirect(btnName)
    table.insert(hBtns, btn)
    btnName = string.format("Btn_Pet%02d", i + 3)
    btn = charPanel:FindDirect(btnName)
    table.insert(vBtns, btn)
  end
  if self.btnPosStep == nil then
    self.btnPosStep = {}
    self.btnPosStep.x = hBtns[1].localPosition.x - hBtns[2].localPosition.x
    self.btnPosStep.y = vBtns[2].localPosition.y - vBtns[1].localPosition.y
  end
  local heroProp = require("Main.Hero.Interface").GetHeroProp()
  local mylevel = heroProp and heroProp.level or 1
  local reqLevel = constant.FightConst.DEFENSE_BT_OPEN_LEVEL
  hBtns[1]:SetActive(mylevel >= reqLevel)
  reqLevel = constant.FightConst.PROTECT_BT_OPEN_LEVEL
  hBtns[2]:SetActive(mylevel >= reqLevel)
  reqLevel = constant.FightConst.ESCAPE_BT_OPEN_LEVEL
  hBtns[3]:SetActive(mylevel >= reqLevel)
  reqLevel = constant.FightConst.ITEM_BT_OPEN_LEVEL
  vBtns[1]:SetActive(mylevel >= reqLevel)
  reqLevel = constant.FightConst.ATTACK_BT_OPEN_LEVEL
  vBtns[2]:SetActive(mylevel >= reqLevel)
  reqLevel = 0
  vBtns[3]:SetActive(mylevel >= reqLevel)
  local count = 0
  for i = 1, #hBtns do
    if hBtns[i].activeSelf then
      hBtns[i].localPosition = Vector.Vector3.new(hBtns[1].localPosition.x - self.btnPosStep.x * count, hBtns[1].localPosition.y, hBtns[1].localPosition.z)
      count = count + 1
    end
  end
  count = 0
  for i = 1, #vBtns do
    if vBtns[i].activeSelf or i == #vBtns then
      vBtns[i].localPosition = Vector.Vector3.new(vBtns[1].localPosition.x, vBtns[1].localPosition.y + self.btnPosStep.y * count, vBtns[1].localPosition.z)
      count = count + 1
    end
  end
end
def.method().ShowFormation = function(self)
  if self.m_panel == nil then
    self.onload = DlgFight.ShowFormation
    return
  end
  local fomationIcon = self.m_panel:FindDirect("Img_BgRound/Img_BgZf" .. FightConst.PASSIVE_TEAM)
  local activeTeam = fightMgr.teams[FightConst.ACTIVE_TEAM]
  fomationIcon:SetActive(activeTeam.formation > 0)
  if activeTeam.formation > 0 then
    activeTeam.formationInfo = gmodule.moduleMgr:GetModule(ModuleId.FORMATION):GetFormationInfoAtLevel(activeTeam.formation, activeTeam.formationLevel)
    local formationIconCtrl = fomationIcon:FindDirect("Texture_Zf" .. FightConst.PASSIVE_TEAM)
    if activeTeam.formationInfo then
      local icon = formationIconCtrl:GetComponent("UITexture")
      GUIUtils.FillIcon(icon, activeTeam.formationInfo.icon)
    end
  end
  fomationIcon = self.m_panel:FindDirect("Img_BgRound/Img_BgZf" .. FightConst.ACTIVE_TEAM)
  local passiveTeam = fightMgr.teams[FightConst.PASSIVE_TEAM]
  fomationIcon:SetActive(passiveTeam.formation > 0)
  if passiveTeam.formation > 0 then
    passiveTeam.formationInfo = gmodule.moduleMgr:GetModule(ModuleId.FORMATION):GetFormationInfoAtLevel(passiveTeam.formation, passiveTeam.formationLevel)
    local formationIconCtrl = fomationIcon:FindDirect("Texture_Zf" .. FightConst.ACTIVE_TEAM)
    if passiveTeam.formationInfo then
      local icon = formationIconCtrl:GetComponent("UITexture")
      GUIUtils.FillIcon(icon, passiveTeam.formationInfo.icon)
    end
  end
end
def.method().SetLabel = function(self)
  if self.m_panel == nil then
    return
  end
  self:ShowCountDown(true)
  local waitLabel = self.m_panel:FindDirect("Group_Top/Img_BgWait/Label_Wait")
  local timeLabelPanel = self.m_panel:FindDirect("Group_Top/Img_BgTime")
  local timeLabel = timeLabelPanel:FindDirect("Label_TimeNum")
  if waitLabel and timeLabel then
    if self.time > 0 then
      waitLabel:SetActive(false)
      timeLabel:GetComponent("UILabel").text = tostring(self.time)
      timeLabelPanel:SetActive(true)
    else
      waitLabel:SetActive(true)
      timeLabelPanel:SetActive(false)
    end
  end
end
def.static("table", "table").SetRound = function(p1, p2)
  if dlg == nil or dlg.m_panel == nil then
    return
  end
  dlg.m_panel:FindDirect("Img_BgRound"):SetActive(true)
  local roundLabel = dlg.m_panel:FindDirect("Img_BgRound/Label_RoundNum")
  roundLabel:GetComponent("UILabel").text = tostring(fightMgr.curRound)
end
def.static("table", "table").OnAutoSkillChanged = function(p1, p2)
  if dlg == nil or dlg.m_panel == nil then
    return
  end
  dlg:ShowAutoSkill()
end
def.method().Hide = function(self)
  self:RemoveUIEffect()
  self:DestroyPanel()
end
def.method("number").StartCountDown = function(self, _time)
  self.time = _time
  Timer:RegisterListener(DlgFight.Update, self)
  self:SetLabel()
  self:SetCountDown()
end
def.method().StopCountDown = function(self)
  Timer:RemoveListener(DlgFight.Update)
  self.time = 0
  self:SetLabel()
  self:SetCountDown()
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
  self.time = self.time - 1
  if fightMgr.auto_fight_status and constant.FightConst.WAIT_CMD_TIME - self.time > constant.FightConst.AUTO_WAIT_TIME then
    self:StopCountDown()
  else
    self:SetLabel()
    self:SetCountDown()
  end
end
def.method().SetCountDown = function(self)
  if self.m_panel == nil then
    return
  end
  local countDown = self.time - constant.FightConst.WAIT_CMD_TIME + constant.FightConst.AUTO_WAIT_TIME
  if fightMgr.curRound > 1 then
    countDown = self.time - constant.FightConst.WAIT_CMD_TIME + constant.FightConst.OTHER_ROUND_AUTO__WAIT_TIME
  end
  local autolabel = self.m_panel:FindDirect("Group_AutoBtn/Img_AutoLable")
  local countDownLabel = self.m_panel:FindDirect("Group_AutoBtn/Label_LeftTime")
  if countDown >= 0 then
    autolabel:SetActive(false)
    countDownLabel:SetActive(true)
    countDownLabel:GetComponent("UILabel").text = tostring(countDown)
  else
    autolabel:SetActive(true)
    countDownLabel:SetActive(false)
  end
end
def.method("number").ShowButtonGroup = function(self, id)
  self.curGroup = id
  if self.buttonGroups == nil then
    return
  end
  local i = 1
  for i = 1, #self.buttonGroups do
    self.buttonGroups[i]:SetActive(i == id)
  end
end
def.method("table").ShowSelectSkill = function(self, skill)
  if skill == nil then
    return
  end
  local unit = fightMgr:GetCurrentControllable()
  if unit == nil then
    return
  end
  self:ShowButtonGroup(DlgFight.ButtonGroupId.SELECT)
  local panel = self.buttonGroups[DlgFight.ButtonGroupId.SELECT]
  local sp = panel:FindDirect("Img_BgIcon/Img_Icon")
  if sp then
    local texture = sp:GetComponent("UITexture")
    if texture then
      GUIUtils.FillIcon(texture, skill.icon)
      GUIUtils.SetCircularEffect(texture, GUIUtils.Effect.Circular)
    end
  end
  local nameLabel = panel:FindDirect("Img_BgIcon/Label_IconName")
  if nameLabel then
    nameLabel:GetComponent("UILabel").text = skill.name
  end
  local descLabel = panel:FindDirect("Label_ShotDesc")
  if descLabel then
    descLabel:GetComponent("UILabel").text = skill.simpleDesc or ""
  end
  local countLabel = panel:FindDirect("Label_Choose")
  if skill.count == nil or skill.count == 0 then
    countLabel:GetComponent("UILabel").text = textRes.Fight[8]
    return
  end
  local skillId = skill.realSkillId
  if skillId == nil or skillId == 0 then
    skillId = skill.id
  end
  local usedData = unit.skillUsedData[skillId]
  local used = usedData and usedData.skillUseCount or 0
  local leftCount = skill.count - used
  countLabel:GetComponent("UILabel").text = string.format(textRes.Fight[9], leftCount)
end
def.method("table").ShowShortcutSkill = function(self, unit)
  local panel, sp, skill, btn, skillId, skillLevel
  if unit.fightUnitType == GameUnitType.ROLE then
    panel = self.buttonGroups[DlgFight.ButtonGroupId.CHAR]
    btn = panel:FindDirect("Btn_Character11")
    sp = btn:FindDirect("Icon_CharacterSkill")
    skillId = fightMgr.role_shortcut_skill
    if skillId == nil or FightUtils.IsNormalAttack(unit.menpai, skillId) or skillId == constant.FightConst.DEFENCE_SKILL then
      btn:SetActive(false)
      return
    end
    local skillList = fightMgr:GetRoleSkillList()
    skillLevel = skillList and skillList[skillId]
    if skillLevel == nil then
      fightMgr.role_shortcut_skill = 0
      skill = nil
    else
      skill = GetSkillCfg(_G.GetOriginalSkill(skillId))
      skillLevel = skillList and skillList[skillId] or 1
    end
  elseif unit.fightUnitType == GameUnitType.PET and fightMgr.pet_shortcut_skill then
    local unitIdStr = unit.roleId:tostring()
    skillId = fightMgr.pet_shortcut_skill[unitIdStr]
    panel = self.buttonGroups[DlgFight.ButtonGroupId.PET]
    btn = panel:FindDirect("Btn_Pet08")
    sp = btn:FindDirect("Icon_PetSkill")
    if skillId == nil or FightUtils.IsNormalAttack(unit.menpai, skillId) or skillId == constant.FightConst.DEFENCE_SKILL then
      btn:SetActive(false)
      return
    end
    local petSkillList = fightMgr:GetPetSkillList()
    if skillId and (petSkillList == nil or petSkillList[skillId] == nil) then
      fightMgr.pet_default_skill[unitIdStr] = nil
      skill = nil
    else
      skill = skillId and fightMgr:GetSkillCfg(skillId)
      skillLevel = unit.level
    end
  elseif unit.fightUnitType == GameUnitType.CHILDREN and fightMgr.child_shortcut_skill then
    local unitIdStr = unit.roleId:tostring()
    skillId = fightMgr.child_shortcut_skill[unitIdStr]
    panel = self.buttonGroups[DlgFight.ButtonGroupId.PET]
    btn = panel:FindDirect("Btn_Pet08")
    sp = btn:FindDirect("Icon_PetSkill")
    if skillId == nil or FightUtils.IsNormalAttack(unit.menpai, skillId) or skillId == constant.FightConst.DEFENCE_SKILL then
      btn:SetActive(false)
      return
    end
    local childSkillList = fightMgr:GetChildSkillList()
    if skillId and (childSkillList == nil or childSkillList[skillId] == nil) then
      fightMgr.child_shortcut_skill[unitIdStr] = nil
      skill = nil
    else
      skill = skillId and fightMgr:GetSkillCfg(skillId)
      skillLevel = unit.level
    end
  end
  if sp and btn then
    local texture = sp:GetComponent("UITexture")
    if skill and texture then
      GUIUtils.FillIcon(texture, skill.icon)
      GUIUtils.SetCircularEffect(texture)
      local valid = fightMgr:CheckSkillRequirement(unit, skillId, skillLevel, skill.count)
      if not valid then
        local mat = texture:get_material()
        if mat then
          mat:EnableKeyword("Grey_On")
        end
      end
    end
    btn:SetActive(skill ~= nil)
  end
end
def.method().ShowAutoSkill = function(self)
  if self.m_panel == nil or self.buttonGroups == nil then
    return
  end
  self.m_panel:FindDirect("Group_AutoBtn/Img_AutoLable"):SetActive(false)
  if fightMgr:IsObserverMode() then
    self:ShowButtonGroup(DlgFight.ButtonGroupId.WATCH)
    return
  end
  local unit = fightMgr:GetCurrentControllable()
  if not fightMgr.auto_fight_status then
    if unit == nil then
      self:ShowButtonGroup(DlgFight.ButtonGroupId.AUTO)
      return
    end
    self:ShowShortcutSkill(unit)
    if unit.fightUnitType == GameUnitType.ROLE then
      self:ShowButtonGroup(DlgFight.ButtonGroupId.CHAR)
    elseif unit.fightUnitType == GameUnitType.PET then
      self:ShowButtonGroup(DlgFight.ButtonGroupId.PET)
    elseif unit.fightUnitType == GameUnitType.CHILDREN then
      self:ShowButtonGroup(DlgFight.ButtonGroupId.PET)
    end
    return
  end
  self.autoSkills = {}
  self:ShowButtonGroup(DlgFight.ButtonGroupId.UNAUTO)
  unit = fightMgr:GetMyHero()
  if unit == nil then
    return
  end
  local panel = self.buttonGroups[DlgFight.ButtonGroupId.UNAUTO]
  local sp = panel:FindDirect("Btn_Auto03/Icon_CharacterSkill")
  local skillId = _G.GetOriginalSkill(fightMgr.role_default_skill)
  local skill = GetSkillCfg(skillId)
  if sp and skill then
    self.autoSkills[1] = skill.id
    local valid = true
    if not FightUtils.IsNormalAttack(unit.menpai, skillId) and skillId ~= constant.FightConst.DEFENCE_SKILL then
      local skillsData = fightMgr:GetRoleSkillList()
      local skillLevel = 1
      if skillsData then
        for k, v in pairs(skillsData) do
          if k == skillId then
            skillLevel = v
            break
          end
        end
      end
      valid = fightMgr:CheckSkillRequirement(unit, fightMgr.role_default_skill, skillLevel, skill.count)
    end
    local texture = sp:GetComponent("UITexture")
    if texture then
      GUIUtils.SetCircularEffect(texture)
      GUIUtils.FillIcon(texture, skill.icon)
      if not valid then
        local mat = texture:get_material()
        if mat then
          mat:EnableKeyword("Grey_On")
        end
      end
    end
  end
  skill = nil
  unit = fightMgr:GetMyPet()
  sp = panel:FindDirect("Btn_Auto02/Icon_PetSkill")
  if sp then
    local valid = true
    if unit then
      if unit.fightUnitType == GameUnitType.PET then
        skillId = fightMgr.pet_default_skill[unit.roleId:tostring()]
        if skillId and skillId > 0 then
          skill = fightMgr:GetSkillCfg(skillId)
        end
      elseif unit.fightUnitType == GameUnitType.CHILDREN then
        skillId = fightMgr.child_default_skill[unit.roleId:tostring()]
        if skillId and skillId > 0 then
          skill = fightMgr:GetSkillCfg(skillId)
        end
      end
      if skill then
        self.autoSkills[2] = skill.id
        if skillId ~= constant.FightConst.ATTACK_SKILL and skillId ~= constant.FightConst.DEFENCE_SKILL then
          valid = fightMgr:CheckSkillRequirement(unit, skillId, unit.level, skill.count)
        end
      else
        self.autoSkills[2] = nil
        valid = false
      end
    else
      self.autoSkills[2] = nil
      valid = false
    end
    local texture = sp:GetComponent("UITexture")
    if texture then
      GUIUtils.SetCircularEffect(texture, GUIUtils.Effect.Circular)
      GUIUtils.FillIcon(texture, skill and skill.icon or 0)
      if not valid then
        local mat = texture:get_material()
        if mat then
          mat:EnableKeyword("Grey_On")
        end
      end
    end
  end
end
def.static("table", "table").OnRemovePet = function(p1, p2)
  if dlg.curGroup == DlgFight.ButtonGroupId.UNAUTO then
    local panel = dlg.buttonGroups[DlgFight.ButtonGroupId.UNAUTO]
    local sp = panel:FindDirect("Btn_Auto02/Icon_PetSkill")
    if sp then
      local uiTexture = sp:GetComponent("UITexture")
      if uiTexture then
        uiTexture.mainTexture = nil
      end
    end
  end
end
def.static("table", "table").ShowUIEffect = function(p1, p2)
  local effid = p1[1]
  local effComtainer = dlg.m_panel:FindDirect("Effect")
  if effComtainer.childCount > 0 then
    local effInst = effComtainer:GetChild(0)
    if effInst then
      effInst:Destroy()
    end
  end
  local effres = GetEffectRes(effid)
  if effres == nil then
    return
  end
  local function OnLoadEffect(obj)
    if obj == null then
      warn("[Fight](ShowUIEffect)AsyncLoad obj is nil: ", effres)
      return
    end
    if not fightMgr.isInFight then
      return
    end
    local eff = Object.Instantiate(obj, "GameObject")
    eff:SetLayer(ClientDef_Layer.UI, true)
    eff.name = tostring(effid)
    eff.parent = effComtainer
    eff.localPosition = EC.Vector3.new(0, 0, 0)
    eff.localScale = EC.Vector3.one
    eff:SetActive(true)
  end
  GameUtil.AsyncLoad(effres.path, OnLoadEffect)
end
def.method().RemoveUIEffect = function(self)
  if self.m_panel == nil then
    return
  end
  local effComtainer = self.m_panel:FindDirect("Effect")
  if effComtainer.childCount > 0 then
    local effInst = effComtainer:GetChild(0)
    if effInst then
      effInst:Destroy()
    end
  end
end
def.method().ShakeBag = function(self)
  if self.m_panel then
    local bagIcon = self.m_panel:FindDirect("Group_AutoBtn/Btn_Auto04")
    if bagIcon and bagIcon:get_activeInHierarchy() then
      local playTween = bagIcon:GetComponent("UIPlayTween")
      if playTween then
        playTween:Play(true)
      end
    end
  end
end
DlgFight.Commit()
return DlgFight
