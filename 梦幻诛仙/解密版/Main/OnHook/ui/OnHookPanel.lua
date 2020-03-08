local Lplus = require("Lplus")
local ECPanelBase = require("GUI.ECPanelBase")
local OnHookPanel = Lplus.Extend(ECPanelBase, "OnHookPanel")
local Vector = require("Types.Vector")
local OnHookData = require("Main.OnHook.OnHookData")
local ECUIModel = require("Model.ECUIModel")
local OnHookUtils = require("Main.OnHook.OnHookUtils")
local CommonConfirmDlg = require("GUI.CommonConfirmDlg")
local OnHookModule = Lplus.ForwardDeclare("OnHookModule")
local HeroModule = require("Main.Hero.HeroModule")
local TeamData = require("Main.Team.TeamData")
local PetMgr = require("Main.Pet.mgr.PetMgr")
local PubroleInterface = Lplus.ForwardDeclare("PubroleInterface")
local PetCfgData = require("Main.Pet.data.PetCfgData")
local PetData = require("Main.Pet.data.PetData")
local ChooseAutoFightPanel = require("Main.OnHook.ui.ChooseAutoFightPanel")
local GUIUtils = require("GUI.GUIUtils")
local FightMgr = require("Main.Fight.FightMgr")
local CommonDescDlg = require("GUI.CommonUITipsDlg")
local ItemModule = require("Main.Item.ItemModule")
local ItemUtils = require("Main.Item.ItemUtils")
local Feature = require("netio.protocol.mzm.gsp.open.ModuleFunSwitchInfo")
local FeatureOpenListModule = require("Main.FeatureOpenList.FeatureOpenListModule")
local def = OnHookPanel.define
local dlg
def.field("boolean").bIsDataInit = false
def.field("table").dataTbl = nil
def.field("table").uiTbl = nil
def.field("boolean").bListFill = false
def.field("number").selectIndex = 0
def.field("boolean").isDrag = false
def.field("number").dragIndex = 0
def.field("table").models = nil
def.static("=>", OnHookPanel).Instance = function(self)
  if nil == dlg then
    dlg = OnHookPanel()
    dlg.bIsDataInit = false
    dlg.m_TrigGC = true
    dlg.m_TryIncLoadSpeed = true
  end
  if false == dlg.bIsDataInit then
    OnHookData.InitOnHookScenesData()
    dlg.bIsDataInit = true
    dlg.uiTbl = {}
  end
  return dlg
end
def.override().OnCreate = function(self)
  self.dragIndex = 0
  self.models = {}
  self.uiTbl = OnHookUtils.FillUIFromPrefab(self.m_panel, self.uiTbl)
  self.dataTbl = OnHookData.GetAllOnHookScenes()
  self:CreateScenesList()
  self:FillSceneMasters()
  self:FillDoublePoint()
  self:FillSkill()
  self:UpdateHookBtn()
  Event.RegisterEvent(ModuleId.FIGHT, gmodule.notifyId.Fight.DEFAULT_SKILL_CHANGED, OnHookPanel.OnAutoSkillChanged)
  Event.RegisterEvent(ModuleId.FEATURE, gmodule.notifyId.Feature.FeatureOpenChange, OnHookPanel.OnFunctionOpenChange)
end
def.override("boolean").OnShow = function(self, s)
  if s == false then
    return
  end
  self:FillSceneMasters()
  self:setDoublePointUseCount()
end
def.method().CreateScenesList = function(self)
  self.bListFill = false
  local gridTemplate = self.uiTbl.Grid_List
  local groupTemplate = self.uiTbl.Img_BgMap01
  self.selectIndex = self:GetDefaultSceneIndex()
  local recommendIndex = self:GetRecommendSceneIndex()
  self:FillScenesList(self.bListFill, self.dataTbl, groupTemplate, gridTemplate, self.FillSceneInfo, recommendIndex)
  if self.selectIndex > 6 then
    GameUtil.AddGlobalTimer(0.1, true, function()
      if self.m_panel and false == self.m_panel.isnil then
        local group = gridTemplate:GetChild(self.selectIndex - 1)
        self.uiTbl.Scroll_View:GetComponent("UIScrollView"):DragToMakeVisible(group.transform, 10)
      end
    end)
  end
  local uiGrid = gridTemplate:GetComponent("UIGrid")
  uiGrid:Reposition()
  self:TouchGameObject(self.m_panel, self.m_parent)
end
def.method("boolean", "table", "userdata", "userdata", "function", "number").FillScenesList = function(self, bFill, list, groupTemplate, gridTemplate, fillInfoFunc, recommendIndex)
  local index = 1
  local count = 0
  for i = index, #list do
    count = count + 1
    local panel
    if i == 1 then
      panel = groupTemplate
    else
      panel = Object.Instantiate(groupTemplate)
      panel:set_name(string.format("Img_BgMap0%d", i))
      panel.parent = gridTemplate
      panel:set_localScale(Vector.Vector3.one)
    end
    fillInfoFunc(self, list, i, count, panel, recommendIndex)
  end
end
def.method("table", "number", "number", "userdata", "number").FillSceneInfo = function(self, list, index, count, groupNew, recommendIndex)
  local sign = groupNew:FindDirect("Img_Sign")
  local isRecommend = index == recommendIndex
  sign:SetActive(isRecommend)
  local isSelected = index == self.selectIndex
  groupNew:GetComponent("UIToggle"):set_isChecked(isSelected)
  local Label_MapName = groupNew:FindDirect("Label_MapName"):GetComponent("UILabel")
  Label_MapName:set_text(list[index].mapName)
  local Label_Lv = groupNew:FindDirect("Label_Lv"):GetComponent("UILabel")
  local prop = require("Main.Hero.Interface").GetHeroProp()
  local level = prop.level
  local unlockStr = ""
  local lock = groupNew:FindDirect("Img_Lock")
  local Texture_Map = groupNew:FindDirect("Texture_Map"):GetComponent("UITexture")
  GUIUtils.FillIcon(Texture_Map, list[index].samallMapPath)
  if level >= list[index].unLockLevel then
    GUIUtils.SetTextureEffect(Texture_Map, GUIUtils.Effect.Normal)
    unlockStr = list[index].minLevel .. " - " .. list[index].maxLevel
    lock:SetActive(false)
    Label_MapName:set_textColor(Color.white)
    Label_MapName:set_effectStyle(Effect.Outline)
    Label_MapName:set_effectColor(Color.Color(0.318, 0.137, 0.047, 1))
    Label_Lv:set_textColor(Color.white)
    Label_Lv:set_effectStyle(Effect.Outline)
    Label_Lv:set_effectColor(Color.Color(0.318, 0.137, 0.047, 1))
  else
    GUIUtils.SetTextureEffect(Texture_Map, GUIUtils.Effect.Gray)
    unlockStr = list[index].unLockLevel .. textRes.OnHook[1]
    lock:SetActive(true)
    Label_MapName:set_effectStyle(Effect.None)
    Label_MapName:set_textColor(Color.Color(0.557, 0.298, 0.086, 1))
    Label_Lv:set_effectStyle(Effect.None)
    Label_Lv:set_textColor(Color.Color(0.31, 0.188, 0.094, 1))
  end
  Label_Lv:set_text(unlockStr)
end
def.method("=>", "number").GetDefaultSceneIndex = function(self)
  local prop = require("Main.Hero.Interface").GetHeroProp()
  local level = prop.level
  local index = 0
  local curMapId = require("Main.Map.MapModule").Instance():GetMapId()
  for k, v in pairs(self.dataTbl) do
    if curMapId == v.sendMapId then
      index = k
      break
    end
  end
  if index == 0 then
    for i = 1, #self.dataTbl do
      if level >= self.dataTbl[i].minLevel and level <= self.dataTbl[i].maxLevel or i == #self.dataTbl and level > self.dataTbl[i].maxLevel then
        index = i
        break
      end
    end
  end
  return index
end
def.method("=>", "number").GetRecommendSceneIndex = function(self)
  local prop = require("Main.Hero.Interface").GetHeroProp()
  local level = prop.level
  local index = 0
  for i = 1, #self.dataTbl do
    if level >= self.dataTbl[i].minLevel and level <= self.dataTbl[i].maxLevel or i == #self.dataTbl and level > self.dataTbl[i].maxLevel then
      index = i
      break
    end
  end
  return index
end
def.method().FillSceneMasters = function(self)
  local scene = self.dataTbl[self.selectIndex]
  if scene == nil then
    return
  end
  self.uiTbl.Label_MapTitle:GetComponent("UILabel"):set_text(scene.mapName)
  for i = 1, #self.dataTbl[self.selectIndex].mods do
    if self.models[i] ~= nil then
      self.models[i]:Destroy()
      self.models[i] = nil
    end
    do
      local group = self.uiTbl.Grid_Monster:FindDirect(string.format("Img_BgMonster0%d", i))
      local uiModel = group:FindDirect(string.format("Model%d", i)):GetComponent("UIModel")
      local modId = self.dataTbl[self.selectIndex].mods[i].modId
      local modelPath = GetModelPath(modId)
      local mod = ECUIModel.new(modId)
      self.models[i] = mod
      mod:LoadUIModel(modelPath, function(ret)
        if nil == ret or uiModel == nil or uiModel.isnil then
          return
        end
        local m = mod.m_model
        m.parent = nil
        m:SetLayer(ClientDef_Layer.UI_Model1)
        mod:SetDir(180)
        mod:Play("Stand_c")
        mod:SetScale(1)
        uiModel.modelGameObject = m
        uiModel.mCanOverflow = true
        mod:CloseAlphaBase()
        local camera = uiModel:get_modelCamera()
        camera:set_orthographic(true)
      end)
      local modName = group:FindDirect("Label_NameMonster")
      modName:GetComponent("UILabel"):set_text(self.dataTbl[self.selectIndex].mods[i].modName)
    end
  end
end
def.method().FillDoublePoint = function(self)
  local frozenPoolPointNum = OnHookModule.GetFrozenPoolPointNum()
  local getingPoolPointNum = OnHookModule.GetGetingPoolPointNum()
  self:UpdateDoublePointLabel(frozenPoolPointNum, getingPoolPointNum)
  local bOpen = FeatureOpenListModule.Instance():CheckFeatureOpen(Feature.TYPE_DOUBLE_POINT_SWITCH)
  local bUse = OnHookModule.GetIsUseDoublePoint()
  self.uiTbl.Btn_Off:SetActive(bOpen)
  if bOpen then
    self.uiTbl.Btn_Off:GetComponent("UIToggle"):set_isChecked(bUse)
  end
end
def.method().FillSkill = function(self)
  local b = FightMgr.Instance():IsAutoFight()
  self.uiTbl.Btn_Switch:GetComponent("UIToggle"):set_isChecked(b)
  local fightingPet = PetMgr.Instance():GetFightingPet()
  if nil == fightingPet then
    self.uiTbl.Img_BgSkillPet:SetActive(false)
  else
    self.uiTbl.Img_BgSkillPet:SetActive(true)
    local petSkillId = FightMgr.Instance():GetPetAutoSkill(fightingPet.id)
    self:SetPetAutoSkill(fightingPet.id, petSkillId)
  end
  local heroSkillId = FightMgr.Instance():GetAutoSkill()
  self:SetHeroAutoSkill(heroSkillId)
end
def.method("number", "number").UpdateDoublePointLabel = function(self, frozenPoolPointNum, getingPoolPointNum)
  self.uiTbl.Group_Frezze:SetActive(true)
  self.uiTbl.Label_FreezeNum:GetComponent("UILabel"):set_text(frozenPoolPointNum)
  self.uiTbl.Label_DoubleNum:GetComponent("UILabel"):set_text(getingPoolPointNum)
end
def.method("string").onDragStart = function(self, id)
  if nil ~= string.find(id, "Model") then
    self.isDrag = true
    local index = string.sub(id, string.len("Model") + 1)
    local groupName = "Img_BgMonster0" .. index
    self.dragIndex = tonumber(index)
  end
end
def.method("string").onDragEnd = function(self, id)
  self.isDrag = false
  self.dragIndex = 0
end
def.method("string", "number", "number").onDrag = function(self, id, dx, dy)
  if self.isDrag == true and 0 ~= self.dragIndex then
    local mod = self.models[self.dragIndex]
    mod:SetDir(mod.m_ang - dx / 2)
  end
end
def.method("string").OnModClick = function(self, id)
  local index = string.sub(id, string.len("Model") + 1)
  local groupName = "Img_BgMonster0" .. index
  local mod = self.models[tonumber(index)]
  if true == mod:IsPlaying("Stand_c") then
    local num = math.random(0, 9)
    local aniName = ""
    if 0 == math.fmod(num, 2) then
      aniName = "attackTime"
      mod:CrossFade("Attack1_c", 0)
    else
      aniName = "spellTime"
      mod:CrossFade("Magic_c", 0)
    end
    mod:CrossFadeQueued("Stand_c", 0.1)
  end
end
def.method().OnDoublePointTipsClick = function(self)
  local tipsId = OnHookUtils.GetDoublePointTipsId()
  local GUIUtils = require("GUI.GUIUtils")
  GUIUtils.ShowHoverTip(tipsId, 0, 0)
end
def.method().OnOnHookTipsClick = function(self)
  local desc = textRes.OnHook[15]
  local tmpPosition = {x = 0, y = 0}
  CommonDescDlg.ShowCommonTip(desc, tmpPosition)
end
def.method().OnFreezeBtnClick = function(self)
  gmodule.network.sendProtocol(require("netio.protocol.mzm.gsp.guaji.CFrozenPointReq").new())
end
def.static("number", "table").BuyDoublePointByGoldCallback = function(i, tag)
  if i == 1 then
  end
end
def.static("number", "table").BuyItemCallback = function(i, tag)
  if i == 1 then
    local itemId = tag.itemId
    local MallPanel = require("Main.Mall.ui.MallPanel")
    local MallUtility = require("Main.Mall.MallUtility")
    local MallType = require("consts.mzm.gsp.mall.confbean.MallType")
    local pageType = MallUtility.GetPageTypeByMallType(MallType.PRECIOUS_MALL)
    if pageType ~= 0 then
      require("Main.Mall.MallModule").RequireToShowMallPanel(pageType, itemId, MallType.PRECIOUS_MALL)
    end
  end
end
def.method().OnBuyDoublePointItemClick = function(self)
  local doublePointItemId = OnHookUtils.GetDoublePointItemId()
  local tag = {itemId = doublePointItemId}
  CommonConfirmDlg.ShowConfirm("", textRes.OnHook[24], OnHookPanel.BuyItemCallback, tag)
end
def.static().OnGetBtnClick = function()
  local frozenPoolPointNum = OnHookModule.GetFrozenPoolPointNum()
  local getingPoolPointNum = OnHookModule.GetGetingPoolPointNum()
  local carryMax = OnHookUtils.GetCarryMaxNum()
  if frozenPoolPointNum >= carryMax then
    Toast(string.format(textRes.OnHook[3], carryMax))
    return
  end
  if getingPoolPointNum <= 0 then
    local doublePointItemId = OnHookUtils.GetDoublePointItemId()
    local tag = {itemId = doublePointItemId}
    local itemBase = ItemUtils.GetItemBase(doublePointItemId)
    CommonConfirmDlg.ShowConfirm("", string.format(textRes.OnHook[4], itemBase.name), OnHookPanel.BuyItemCallback, tag)
    return
  end
  gmodule.network.sendProtocol(require("netio.protocol.mzm.gsp.guaji.CGetPointReq").new())
end
def.method().OnHide = function(self)
  self:DestroyPanel()
  self = nil
end
def.method("=>", "boolean").EnterMap = function(self)
  local data = self.dataTbl and self.dataTbl[self.selectIndex]
  if data == nil then
    return false
  end
  local id = data.sendMapId
  self:OnHide()
  return HeroModule.Instance():EnterMap(id, nil)
end
def.static("number", "table").ReciveDoublePointCallback = function(i, tag)
  if i == 1 then
    OnHookPanel.OnGetBtnClick()
  end
  if tag.bOnHook then
    OnHookPanel.EnterMapToOnHook(tag.bOnHook, tag.bSameMap)
  end
end
def.static().AfterGetDoublePoint = function()
  if dlg then
    dlg:setDoublePointUseCount()
  end
end
def.static("boolean", "boolean").EnterMapToOnHook = function(bOnHook, bSameMap)
  if false == bSameMap then
    local success = OnHookPanel.Instance():EnterMap()
    if bOnHook and success then
      OnHookModule.Instance().bWaitToOnHook = true
    end
  else
    OnHookPanel.Instance():OnHide()
    if bOnHook then
      HeroModule.Instance():Patrol()
    end
  end
end
def.static("number", "table").UseDoublePointCallback = function(i, tag)
  if i == 1 then
    gmodule.network.sendProtocol(require("netio.protocol.mzm.gsp.item.CUseDoublePointReq").new(tag.itemId))
  end
  OnHookPanel.EnterMapToOnHook(tag.bOnHook, tag.bSameMap)
end
def.static("boolean", "boolean", "boolean").JudgeIfPointEnough = function(bOnHook, bSameMap, isActivity)
  local frozenPoolPointNum = OnHookModule.GetFrozenPoolPointNum()
  local getingPoolPointNum = OnHookModule.GetGetingPoolPointNum()
  local remainCount = require("Main.OnHook.DoublePointData").Instance():GetWeekCanUseCount()
  local tipPoint = OnHookUtils.GetFrozenMinNumForTip()
  if isActivity then
    if frozenPoolPointNum < tipPoint then
      if getingPoolPointNum > 0 then
        CommonConfirmDlg.ShowConfirm("", textRes.OnHook[11], function(i, tag)
          if i == 1 then
            gmodule.network.sendProtocol(require("netio.protocol.mzm.gsp.guaji.CGetPointReq").new())
          end
        end, nil)
      elseif remainCount > 0 then
        Toast(textRes.OnHook[29])
      end
    end
  else
    if frozenPoolPointNum < tipPoint then
      if getingPoolPointNum > 0 then
        Toast(textRes.OnHook[19])
      elseif remainCount > 0 then
        Toast(textRes.OnHook[29])
      end
    end
    if bOnHook then
      OnHookPanel.EnterMapToOnHook(bOnHook, bSameMap)
    end
  end
end
def.method().OnOnHookClick = function(self)
  if PlayerIsInFight() and not HeroModule.Instance():IsPatroling() then
    return Toast(textRes.OnHook[21])
  end
  local heroModule = gmodule.moduleMgr:GetModule(ModuleId.HERO)
  if heroModule:IsInState(RoleState.ESCORT) then
    Toast(textRes.OnHook[22])
    return
  end
  local ECMSDK = require("ProxySDK.ECMSDK")
  local PubroleModule = require("Main.Pubrole.PubroleModule")
  if true == PubroleModule.Instance():IsInFollowState(heroModule.roleId) then
    Toast(textRes.OnHook[20])
    return
  end
  if heroModule.myRole:IsInState(RoleState.UNTRANPORTABLE) then
    Toast(textRes.Hero[50])
    return
  end
  if HeroModule.Instance():IsPatroling() then
    self:OnHide()
    HeroModule.Instance():StopPatroling()
    self:CheckInFight()
    ECMSDK.SendTLogToServer(_G.TLOGTYPE.PATROL, {2})
  else
    self:JudgeIfDanger(OnHookPanel.OnHookCallback, true)
    ECMSDK.SendTLogToServer(_G.TLOGTYPE.PATROL, {1})
  end
  self:UpdateHookBtn()
end
def.method().UpdateHookBtn = function(self)
  local str = textRes.OnHook[16]
  if HeroModule.Instance():IsPatroling() then
    str = textRes.OnHook[17]
  end
  self.uiTbl.Label_Onhook:GetComponent("UILabel"):set_text(str)
end
def.method().CheckInFight = function(self)
  if PlayerIsInFight() then
    Toast(textRes.OnHook[25])
  end
end
def.static("number", "table").EnterSceneCallback = function(i, tag)
  if i == 1 and false == tag.bSameMap then
    tag.id:EnterMap()
  end
end
def.static("number", "table").OnHookCallback = function(i, tag)
  if i == 1 then
    local bOnHook = tag.bOnHook
    local bSameMap = tag.bSameMap
    OnHookPanel.JudgeIfPointEnough(bOnHook, bSameMap, false)
  end
end
def.method("number", "=>", "boolean").IsSceneLock = function(self, index)
  local prop = require("Main.Hero.Interface").GetHeroProp()
  local level = prop.level
  local sceneInfo = self.dataTbl[index]
  if sceneInfo == nil then
    Debug.LogWarning(string.format("[OnHookPanel]sceneInfo is nil, invalid index: %d", index))
    return true
  end
  local bLock = true
  if level >= sceneInfo.unLockLevel then
    bLock = false
  end
  return bLock
end
def.method("function", "boolean").JudgeIfDanger = function(self, callback, bOnHook)
  local prop = require("Main.Hero.Interface").GetHeroProp()
  local level = prop.level
  local sceneInfo = self.dataTbl[self.selectIndex]
  local curMapId = require("Main.Map.MapModule").Instance():GetMapId()
  local bLock = self:IsSceneLock(self.selectIndex)
  local bDanger = false
  local bSameMap = false
  if false == bLock and level < sceneInfo.minLevel then
    bDanger = true
  end
  if sceneInfo.sendMapId == curMapId then
    bSameMap = true
  end
  if bLock then
    Toast(textRes.OnHook[9])
  end
  local bIsInTeam = TeamData.Instance():IsTeamMember(HeroModule.Instance():GetMyRoleId())
  local bIsTeamLeader = TeamData.Instance():IsCaptain(HeroModule.Instance():GetMyRoleId())
  local status = TeamData.Instance():GetStatus()
  if bDanger and (false == bIsInTeam or bIsInTeam and bIsTeamLeader or bIsInTeam and status == require("netio.protocol.mzm.gsp.team.TeamMember").ST_TMP_LEAVE) then
    local tag = {
      id = self,
      bOnHook = bOnHook,
      bSameMap = bSameMap
    }
    CommonConfirmDlg.ShowConfirm("", textRes.OnHook[10], callback, tag)
  else
    OnHookPanel.JudgeIfPointEnough(bOnHook, bSameMap, false)
  end
end
def.method().OnEnterMapClick = function(self)
  if PlayerIsInFight() then
    Toast(textRes.OnHook[21])
    return
  end
  local heroModule = gmodule.moduleMgr:GetModule(ModuleId.HERO)
  if heroModule:IsInState(RoleState.ESCORT) then
    Toast(textRes.OnHook[22])
    return
  end
  local prop = require("Main.Hero.Interface").GetHeroProp()
  local PubroleModule = require("Main.Pubrole.PubroleModule")
  if true == PubroleModule.Instance():IsInFollowState(prop.id) then
    Toast(textRes.OnHook[20])
    return
  end
  self:JudgeIfDanger(OnHookPanel.EnterSceneCallback, false)
end
def.method("string").OnScenesListClick = function(self, id)
  local index = tonumber(string.sub(id, #"Img_BgMap0" + 1))
  local gridTemplate = self.uiTbl.Grid_List
  if self:IsSceneLock(index) then
    Toast(textRes.OnHook[9])
    if self.selectIndex > 0 then
      local group = gridTemplate:GetChild(self.selectIndex - 1)
      group:GetComponent("UIToggle"):set_isChecked(true)
    end
    return
  end
  local group = gridTemplate:GetChild(index - 1)
  group:GetComponent("UIToggle"):set_isChecked(true)
  self.selectIndex = index
  self:FillSceneMasters()
end
def.method("number").UpdateHeroAutoSkillIcon = function(self, skillId)
  local iconTex = self.uiTbl.Icon_SkillHero:GetComponent("UITexture")
  local skillCfg = GetSkillCfg(_G.GetOriginalSkill(skillId))
  GUIUtils.FillIcon(iconTex, skillCfg.icon)
end
def.method("number").UpdatePetAutoSkillIcon = function(self, skillId)
  local iconTex = self.uiTbl.Icon_SkillPet:GetComponent("UITexture")
  local skillCfg = require("Main.Pet.PetUtility").Instance():GetPetSkillCfg(skillId)
  if nil == skillCfg then
    return
  end
  GUIUtils.FillIcon(iconTex, skillCfg.iconId)
end
def.static("table", "number").OnHeroSkillSelectCallback = function(tag, skillId)
  local dlg = tag.id
  local OracleData = require("Main.Oracle.data.OracleData")
  local skillId = OracleData.Instance():GetTalentSkillId(skillId)
  FightMgr.Instance():SetAutoSkill(skillId)
end
def.method("number").SetHeroAutoSkill = function(self, skillId)
  self:UpdateHeroAutoSkillIcon(skillId)
  FightMgr.Instance():SetAutoSkill(skillId)
end
def.method("userdata", "number").SetPetAutoSkill = function(self, petId, skillId)
  self:UpdatePetAutoSkillIcon(skillId)
  FightMgr.Instance():SetPetAutoSkill(petId, skillId)
end
def.static("table", "table").OnAutoSkillChanged = function(p1, p2)
  local heroSkillId = FightMgr.Instance():GetAutoSkill()
  OnHookPanel.Instance():UpdateHeroAutoSkillIcon(heroSkillId)
  local fightingPet = PetMgr.Instance():GetFightingPet()
  if nil ~= fightingPet then
    local petSkillId = FightMgr.Instance():GetPetAutoSkill(fightingPet.id)
    OnHookPanel.Instance():UpdatePetAutoSkillIcon(petSkillId)
  end
end
def.static("table", "table").OnFunctionOpenChange = function(p1, p2)
  if p1 and p1.feature == Feature.TYPE_DOUBLE_POINT_SWITCH then
    OnHookPanel.Instance():FillDoublePoint()
  end
end
def.method().OnChooseHeroSkillClick = function(self)
  if PlayerIsInFight() then
    Toast(textRes.Common[30])
    return
  end
  local heroSkillIds = require("Main.Skill.Interface").GetOnHookSkillList()
  if #heroSkillIds >= 1 then
    local heroSkillId = FightMgr.Instance():GetAutoSkill()
    local tag = {
      id = self,
      bIsPet = false,
      autoSkillId = heroSkillId
    }
    ChooseAutoFightPanel.ShowSkillChoose(heroSkillIds, OnHookPanel.OnHeroSkillSelectCallback, textRes.OnHook[12], tag)
  end
end
def.static("table", "number").OnPetSkillSelectCallback = function(tag, skillId)
  FightMgr.Instance():SetPetAutoSkill(tag.petId, skillId)
end
def.method().OnChoosePetSkillClick = function(self)
  if PlayerIsInFight() then
    Toast(textRes.Common[30])
    return
  end
  local petSkillIds = {}
  local fightingPet = PetMgr.Instance():GetFightingPet()
  if nil ~= fightingPet then
    petSkillIds = fightingPet:GetOnHookSkillIdList()
  end
  if #petSkillIds >= 1 then
    local petSkillId = FightMgr.Instance():GetPetAutoSkill(fightingPet.id)
    local tag = {
      id = self,
      petId = fightingPet.id,
      bIsPet = true,
      autoSkillId = petSkillId,
      level = fightingPet.level
    }
    ChooseAutoFightPanel.ShowSkillChoose(petSkillIds, OnHookPanel.OnPetSkillSelectCallback, textRes.OnHook[13], tag)
  end
end
def.method().OnAutoFightClick = function(self)
  local b = self.uiTbl.Btn_Switch:GetComponent("UIToggle"):get_isChecked()
  FightMgr.Instance():SetAutoFightStatus(b)
end
def.method().OnBtnOffClick = function(self)
  local bUse = self.uiTbl.Btn_Off:GetComponent("UIToggle"):get_isChecked()
  local SwitchType = require("netio.protocol.mzm.gsp.guaji.SwitchType")
  gmodule.network.sendProtocol(require("netio.protocol.mzm.gsp.guaji.CChangeSwitch").new(SwitchType.GUA_JI, bUse and 1 or 0))
end
def.method("string").onClick = function(self, id)
  if nil ~= string.find(id, "Model") then
    self:OnModClick(id)
  elseif "Btn_Tips01" == id then
    require("Main.OnHook.ui.OnHookTipsPanel").Instance():ShowPanel()
  elseif "Btn_Close" == id then
    self:OnHide()
  elseif "Modal" == id then
    self:OnHide()
  elseif "Btn_Freeze" == id then
    self:OnFreezeBtnClick()
  elseif "Btn_Double" == id then
    OnHookPanel.OnGetBtnClick()
  elseif "Btn_Onhook" == id then
    self:OnOnHookClick()
  elseif "Btn_Tips02" == id then
    self:OnOnHookTipsClick()
  elseif nil ~= string.find(id, "Img_BgMap") then
    self:OnScenesListClick(id)
  elseif "Img_BgSkillHero" == id then
    self:OnChooseHeroSkillClick()
  elseif "Img_BgSkillPet" == id then
    self:OnChoosePetSkillClick()
  elseif "Btn_Switch" == id then
    self:OnAutoFightClick()
  elseif "Btn_Buy" == id then
    self:OnBuyDoublePointItemClick()
  elseif "Btn_Off" == id then
    self:OnBtnOffClick()
  end
end
def.method("number").DestoryDisplayMod = function(self, i)
  local groupName = string.format("Img_BgMonster0%d", i)
  local group = self.uiTbl.Grid_Monster:FindDirect(groupName)
  local uiModel = group:FindDirect(string.format("Model%d", i)):GetComponent("UIModel")
  if nil ~= uiModel.modelGameObject then
    uiModel.modelGameObject:Destroy()
    uiModel.modelGameObject = nil
  end
end
def.override().OnDestroy = function(self)
  for k, v in pairs(self.models) do
    v:Destroy()
  end
  self.models = nil
  self.dataTbl = nil
  Event.UnregisterEvent(ModuleId.FIGHT, gmodule.notifyId.Fight.DEFAULT_SKILL_CHANGED, OnHookPanel.OnAutoSkillChanged)
  Event.UnregisterEvent(ModuleId.FEATURE, gmodule.notifyId.Feature.FeatureOpenChange, OnHookPanel.OnFunctionOpenChange)
end
def.method().setDoublePointUseCount = function(self)
  if self.m_panel then
    local label_num = self.m_panel:FindDirect("Img_Bg0/Group_Point/Label")
    label_num:GetComponent("UILabel"):set_text(string.format(textRes.OnHook[27], OnHookModule.GetWeekCanUseCount()))
  end
end
OnHookPanel.Commit()
return OnHookPanel
