local Lplus = require("Lplus")
local GUIUtils = require("GUI.GUIUtils")
local ComponentBase = require("Main.MainUI.ui.MainUIComponentBase")
local MainUIMainMenu = Lplus.Extend(ComponentBase, "MainUIMainMenu")
local FlyModule = require("Main.Fly.FlyModule")
local HomelandModule = Lplus.ForwardDeclare("HomelandModule")
local PartnerInterface = require("Main.partner.PartnerInterface")
local EC = require("Types.Vector3")
local def = MainUIMainMenu.define
local MENU_BTN_EFFECT_NAME = "lighteffect"
local AUTO_CLOSE_TIME = 90
local instance
def.field("boolean").m_open = true
def.field("boolean").m_attemptOpen = true
def.field("boolean").m_isMenuHided = false
def.field("table").uiObjs = nil
def.field("number").m_Timer = 0
def.field("number").m_period = 0
def.field("boolean").m_AllowAutoClose = false
def.field("boolean").m_NeedRefresh = false
def.static("=>", MainUIMainMenu).Instance = function()
  if instance == nil then
    instance = MainUIMainMenu()
    instance:Init()
  end
  return instance
end
def.override().Init = function(self)
end
def.override().OnCreate = function(self)
  Event.RegisterEvent(ModuleId.GANG, gmodule.notifyId.Gang.Gang_NoticeStatesChanged, MainUIMainMenu.OnGangNoticeStatesChange)
  Event.RegisterEvent(ModuleId.SKILL, gmodule.notifyId.Skill.SKILL_NOTIFY_UPDATE, MainUIMainMenu.OnSkillNotifyUpdate)
  Event.RegisterEvent(ModuleId.ITEM, gmodule.notifyId.item.Item_BagLeftCapacityChanged, MainUIMainMenu.OnBagLeftCapacityChange)
  Event.RegisterEvent(ModuleId.MAINUI, gmodule.notifyId.MainUI.MENU_BTN_OPERATION, MainUIMainMenu.OnOperationMenuBtn)
  Event.RegisterEvent(ModuleId.EQUIP, gmodule.notifyId.Equip.Equip_NewFunction_ChangeState, MainUIMainMenu.OnEquipNoticeChange)
  Event.RegisterEvent(ModuleId.FLY, gmodule.notifyId.Fly.Hero_Fly_State_Change, MainUIMainMenu.OnFlyChange)
  Event.RegisterEvent(ModuleId.FLY, gmodule.notifyId.Fly.Hero_Double_Fly_Change, MainUIMainMenu.OnFlyChange)
  Event.RegisterEvent(ModuleId.FIGHT, gmodule.notifyId.Fight.ENTER_FIGHT, MainUIMainMenu.OnFlyChange)
  Event.RegisterEvent(ModuleId.FIGHT, gmodule.notifyId.Fight.LEAVE_FIGHT, MainUIMainMenu.OnFlyChange)
  Event.RegisterEvent(ModuleId.ITEM, gmodule.notifyId.item.Item_OnBagInfoSynchronized, MainUIMainMenu.OnItemChange)
  Event.RegisterEvent(ModuleId.AIRCRAFT, gmodule.notifyId.Aircraft.AIRCRAFT_MOUNT_CHANGE, MainUIMainMenu.OnAirCraftChange)
  Event.RegisterEvent(ModuleId.FABAO, gmodule.notifyId.Fabao.FABAO_REDNOTICE_CHANGE, MainUIMainMenu.OnFabaoNoticeChange)
  Event.RegisterEvent(ModuleId.FABAO_SPIRIT, gmodule.notifyId.FabaoSpirit.NoticeChange, MainUIMainMenu.OnFabaoSpiritNoticeChange)
  Event.RegisterEvent(ModuleId.HOMELAND, gmodule.notifyId.Homeland.ENTER_HOMELAND, MainUIMainMenu.OnHomelandSenceChange)
  Event.RegisterEvent(ModuleId.HOMELAND, gmodule.notifyId.Homeland.LEAVE_HOMELAND, MainUIMainMenu.OnHomelandSenceChange)
  Event.RegisterEvent(ModuleId.HOMELAND, gmodule.notifyId.Homeland.LoseHomelandControl, MainUIMainMenu.OnHomelandSenceChange)
  Event.RegisterEvent(ModuleId.HOMELAND, gmodule.notifyId.Homeland.Sync_Furniture_Bag_Info, MainUIMainMenu.OnSyncFurnitureBagInfo)
  Event.RegisterEvent(ModuleId.HOMELAND, gmodule.notifyId.Homeland.CourtyardFeatureChange, MainUIMainMenu.OnCourtyardFeatureChange)
  Event.RegisterEvent(ModuleId.HOMELAND, gmodule.notifyId.Homeland.MysteryVisitorActChange, MainUIMainMenu.OnMysteryVisitorChange)
  Event.RegisterEvent(ModuleId.POKEMON, gmodule.notifyId.Pokemon.POKEMON_FONDLE_INFO_CHANGE, MainUIMainMenu.OnPokemonInfoChange)
  Event.RegisterEvent(ModuleId.POKEMON, gmodule.notifyId.Pokemon.POKEMON_NEW_EGG_CHANGE, MainUIMainMenu.OnPokemonInfoChange)
  Event.RegisterEvent(ModuleId.POKEMON, gmodule.notifyId.Pokemon.POKEMON_MATE_INFO_CHANGE, MainUIMainMenu.OnPokemonInfoChange)
  Event.RegisterEvent(ModuleId.POKEMON, gmodule.notifyId.Pokemon.POKEMON_AWARD_INFO_CHANGE, MainUIMainMenu.OnPokemonInfoChange)
  Event.RegisterEvent(ModuleId.POKEMON, gmodule.notifyId.Pokemon.POKEMON_MATE_INFO_CHANGE_OTHER, MainUIMainMenu.OnPokemonInfoChange)
  Event.RegisterEvent(ModuleId.FEATURE, gmodule.notifyId.Feature.FeatureOpenChange, MainUIMainMenu.OnFunctionOpenChange)
  Event.RegisterEvent(ModuleId.HOMELAND, gmodule.notifyId.Homeland.MyCourtyardCleannessChange, MainUIMainMenu.OnMyCourtyardCleannessChange)
  Event.RegisterEvent(ModuleId.HOMELAND, gmodule.notifyId.Homeland.CourtyardLevelUp, MainUIMainMenu.OnCourtyardLevelUp)
  Event.RegisterEvent(ModuleId.MARRIAGE, gmodule.notifyId.Marriage.Divorce, MainUIMainMenu.OnDivorce)
  Event.RegisterEvent(ModuleId.GOD_WEAPON, gmodule.notifyId.GodWeapon.GOD_WEAPON_FEATURE_CHANGE, MainUIMainMenu.OnGodWeaponFeatureChange)
  Event.RegisterEvent(ModuleId.PARTNER, gmodule.notifyId.partner.Partner_NotifyChange, MainUIMainMenu.OnPartnerNotifyChange)
  Event.RegisterEvent(ModuleId.WING, gmodule.notifyId.Wing.WINGS_RED_POINT_REFRESH, MainUIMainMenu.OnWingNotifyChange)
  Event.RegisterEvent(ModuleId.ORACLE, gmodule.notifyId.Oracle.ON_GET_ORACLE_ALLOCATION, MainUIMainMenu.OnOracleChange)
  Event.RegisterEvent(ModuleId.ORACLE, gmodule.notifyId.Oracle.ORACLE_TOTAL_POINTS_CHANGE, MainUIMainMenu.OnOracleChange)
  Event.RegisterEvent(ModuleId.ORACLE, gmodule.notifyId.Oracle.ON_SWITCH_ORACLE_CHANGE, MainUIMainMenu.OnOracleChange)
  Event.RegisterEvent(ModuleId.FEATURE, gmodule.notifyId.Feature.FeatureOpenInit, MainUIMainMenu.OnFunctionInit)
  self.uiObjs = {}
  self.uiObjs.Img_BagRed = self.m_node:FindDirect("Btn_Bag/Img_BagRed")
  self.uiObjs.Img_HomeRed = self.m_node:FindDirect("Group_Btn/Btn_HomeBack/Img_MakeRed")
  self.uiObjs.Img_PokemonRed = self.m_node:FindDirect("Group_In/Btn_GardenPet/Img_Furniture")
  self.uiObjs.Img_GodWeaponRed = self.m_node:FindDirect("Group_Btn/Btn_GodsWeapon/Img_MakeRed")
  self.uiObjs.openSprite = self.m_node:FindDirect("Img_Open")
  self.uiObjs.closeSprite = self.m_node:FindDirect("Img_ShouQi")
  self.uiObjs.Img_TipRed = self.m_node:FindDirect("Img_Red")
  self.uiObjs.Btn_Menu = self.m_node:FindDirect("Btn_Menu")
  self.uiObjs.Group_In = self.m_node:FindDirect("Group_In")
  if self.uiObjs.Group_In then
    local childCount = self.uiObjs.Group_In.childCount
    for i = 1, childCount do
      local childGO = self.uiObjs.Group_In:GetChild(i - 1)
      local tweenPosition = childGO:GetComponent("TweenPosition")
      if tweenPosition then
        tweenPosition:Destroy()
      end
    end
  else
    Debug.LogError(string.format("Group_In not found in %s, need update this panel!", self.m_container.m_panelName))
  end
  local uiPlayTween = self.uiObjs.Btn_Menu:GetComponent("UIPlayTween")
  uiPlayTween.ifDisabledOnPlay = 0
  uiPlayTween.enabled = false
  uiPlayTween.playDirection = 1
  self:SetOpenSprite(false)
  self.m_Timer = 0
  self.m_period = 0
  self.m_NeedRefresh = false
  self:SetAllowAutoClose(true)
  self:SetEquipmentUnreadMessageNum(0)
  self:SetFightSettingUnreadMessageNum(0)
  self:SetGangUnreadMessageNum(0)
  self:UpdatePartnerUnreadMessageNum()
  self:UpdateHomelandUnreadMessageNum(nil)
  self:UpdateSkillUnreadMessageNum()
  self:UpdateMenuBtnRedNotice()
  self:UpdateFabaoRedNotice()
  self:UpdateWingRedNotice()
  self:UpdateCloseBtnGroup()
  local ItemModule = require("Main.Item.ItemModule")
  self.uiObjs.Img_BagRed:SetActive(ItemModule.Instance():IsBagFull(ItemModule.BAG))
  self:UpdateHomelandPokemonRedPoints()
  self:UpdateGodWeaponRedPoints()
end
def.method().UpdateHomelandPokemonRedPoints = function(self)
  local PokemonModule = require("Main.Pokemon.PokemonModule")
  local bPokemonReddot = PokemonModule.Instance():NeedReddot()
  self:UpdateHomelandUnreadMessageNum(nil)
  if HomelandModule.Instance():IsInSelfHomeland() then
    warn("[MainUIMainMenu:UpdateHomelandPokemonRedPoints] in self homeland, bPokemonReddot:", bPokemonReddot)
    GUIUtils.SetActive(self.uiObjs.Img_PokemonRed, bPokemonReddot)
  else
    if gmodule.moduleMgr:GetModule(ModuleId.HERO).isInHomeland then
      local bCanEntityMate = require("Main.Pokemon.PokemonMgr").Instance():CanAnyEntityMate()
      warn("[MainUIMainMenu:UpdateHomelandPokemonRedPoints] in other homeland, bCanEntityMate:", bCanEntityMate)
      GUIUtils.SetActive(self.uiObjs.Img_PokemonRed, bCanEntityMate)
    else
    end
  end
end
def.method().UpdateGodWeaponRedPoints = function(self)
  GUIUtils.SetActive(self.uiObjs.Img_GodWeaponRed, require("Main.GodWeapon.GodWeaponModule").Instance():NeedReddot())
end
def.override().OnDestroy = function(self)
  Event.UnregisterEvent(ModuleId.GANG, gmodule.notifyId.Gang.Gang_NoticeStatesChanged, MainUIMainMenu.OnGangNoticeStatesChange)
  Event.UnregisterEvent(ModuleId.SKILL, gmodule.notifyId.Skill.SKILL_NOTIFY_UPDATE, MainUIMainMenu.OnSkillNotifyUpdate)
  Event.UnregisterEvent(ModuleId.ITEM, gmodule.notifyId.item.Item_BagLeftCapacityChanged, MainUIMainMenu.OnBagLeftCapacityChange)
  Event.UnregisterEvent(ModuleId.MAINUI, gmodule.notifyId.MainUI.MENU_BTN_OPERATION, MainUIMainMenu.OnOperationMenuBtn)
  Event.UnregisterEvent(ModuleId.EQUIP, gmodule.notifyId.Equip.Equip_NewFunction_ChangeState, MainUIMainMenu.OnEquipNoticeChange)
  Event.UnregisterEvent(ModuleId.FLY, gmodule.notifyId.Fly.Hero_Fly_State_Change, MainUIMainMenu.OnFlyChange)
  Event.UnregisterEvent(ModuleId.FLY, gmodule.notifyId.Fly.Hero_Double_Fly_Change, MainUIMainMenu.OnFlyChange)
  Event.UnregisterEvent(ModuleId.FIGHT, gmodule.notifyId.Fight.ENTER_FIGHT, MainUIMainMenu.OnFlyChange)
  Event.UnregisterEvent(ModuleId.FIGHT, gmodule.notifyId.Fight.LEAVE_FIGHT, MainUIMainMenu.OnFlyChange)
  Event.UnregisterEvent(ModuleId.ITEM, gmodule.notifyId.item.Item_OnBagInfoSynchronized, MainUIMainMenu.OnItemChange)
  Event.UnregisterEvent(ModuleId.AIRCRAFT, gmodule.notifyId.Aircraft.AIRCRAFT_MOUNT_CHANGE, MainUIMainMenu.OnAirCraftChange)
  Event.UnregisterEvent(ModuleId.FABAO, gmodule.notifyId.Fabao.FABAO_REDNOTICE_CHANGE, MainUIMainMenu.OnFabaoNoticeChange)
  Event.UnregisterEvent(ModuleId.FABAO_SPIRIT, gmodule.notifyId.FabaoSpirit.NoticeChange, MainUIMainMenu.OnFabaoSpiritNoticeChange)
  Event.UnregisterEvent(ModuleId.HOMELAND, gmodule.notifyId.Homeland.ENTER_HOUSE, MainUIMainMenu.OnHomelandSenceChange)
  Event.UnregisterEvent(ModuleId.HOMELAND, gmodule.notifyId.Homeland.LEAVE_HOUSE, MainUIMainMenu.OnHomelandSenceChange)
  Event.UnregisterEvent(ModuleId.HOMELAND, gmodule.notifyId.Homeland.LoseHomelandControl, MainUIMainMenu.OnHomelandSenceChange)
  Event.UnregisterEvent(ModuleId.HOMELAND, gmodule.notifyId.Homeland.Sync_Furniture_Bag_Info, MainUIMainMenu.OnSyncFurnitureBagInfo)
  Event.UnregisterEvent(ModuleId.HOMELAND, gmodule.notifyId.Homeland.CourtyardFeatureChange, MainUIMainMenu.OnCourtyardFeatureChange)
  Event.UnregisterEvent(ModuleId.HOMELAND, gmodule.notifyId.Homeland.MysteryVisitorActChange, MainUIMainMenu.OnMysteryVisitorChange)
  Event.UnregisterEvent(ModuleId.POKEMON, gmodule.notifyId.Pokemon.POKEMON_FONDLE_INFO_CHANGE, MainUIMainMenu.OnPokemonInfoChange)
  Event.UnregisterEvent(ModuleId.POKEMON, gmodule.notifyId.Pokemon.POKEMON_NEW_EGG_CHANGE, MainUIMainMenu.OnPokemonInfoChange)
  Event.UnregisterEvent(ModuleId.POKEMON, gmodule.notifyId.Pokemon.POKEMON_MATE_INFO_CHANGE, MainUIMainMenu.OnPokemonInfoChange)
  Event.UnregisterEvent(ModuleId.POKEMON, gmodule.notifyId.Pokemon.POKEMON_AWARD_INFO_CHANGE, MainUIMainMenu.OnPokemonInfoChange)
  Event.UnregisterEvent(ModuleId.POKEMON, gmodule.notifyId.Pokemon.POKEMON_MATE_INFO_CHANGE_OTHER, MainUIMainMenu.OnPokemonInfoChange)
  Event.UnregisterEvent(ModuleId.FEATURE, gmodule.notifyId.Feature.FeatureOpenChange, MainUIMainMenu.OnFunctionOpenChange)
  Event.UnregisterEvent(ModuleId.HOMELAND, gmodule.notifyId.Homeland.MyCourtyardCleannessChange, MainUIMainMenu.OnMyCourtyardCleannessChange)
  Event.UnregisterEvent(ModuleId.HOMELAND, gmodule.notifyId.Homeland.CourtyardLevelUp, MainUIMainMenu.OnCourtyardLevelUp)
  Event.UnregisterEvent(ModuleId.MARRIAGE, gmodule.notifyId.Marriage.Divorce, MainUIMainMenu.OnDivorce)
  Event.UnregisterEvent(ModuleId.GOD_WEAPON, gmodule.notifyId.GodWeapon.GOD_WEAPON_FEATURE_CHANGE, MainUIMainMenu.OnGodWeaponFeatureChange)
  Event.UnregisterEvent(ModuleId.PARTNER, gmodule.notifyId.partner.Partner_NotifyChange, MainUIMainMenu.OnPartnerNotifyChange)
  Event.UnregisterEvent(ModuleId.WING, gmodule.notifyId.Wing.WINGS_RED_POINT_REFRESH, MainUIMainMenu.OnWingNotifyChange)
  Event.UnregisterEvent(ModuleId.ORACLE, gmodule.notifyId.Oracle.ON_GET_ORACLE_ALLOCATION, MainUIMainMenu.OnOracleChange)
  Event.UnregisterEvent(ModuleId.ORACLE, gmodule.notifyId.Oracle.ORACLE_TOTAL_POINTS_CHANGE, MainUIMainMenu.OnOracleChange)
  Event.UnregisterEvent(ModuleId.ORACLE, gmodule.notifyId.Oracle.ON_SWITCH_ORACLE_CHANGE, MainUIMainMenu.OnOracleChange)
  Event.UnregisterEvent(ModuleId.FEATURE, gmodule.notifyId.Feature.FeatureOpenInit, MainUIMainMenu.OnFunctionInit)
  if self.m_Timer ~= 0 then
    GameUtil.RemoveGlobalTimer(self.m_Timer)
    self.m_Timer = 0
  end
  self:ResetPeriod()
  self.uiObjs = nil
  self.m_open = true
  self.m_attemptOpen = true
  self.m_isMenuHided = false
end
def.override().OnShow = function(self)
  self:UpdateUI()
end
def.override().OnHide = function(self)
end
def.method().UpdateUI = function(self)
  if self.m_NeedRefresh then
    self:SetRefreshState(false)
    require("Main.MainUI.ui.MainUIPanel").Instance():RefreshMainMenuGroup()
  elseif self.m_attemptOpen ~= self.m_open then
    if self.m_attemptOpen then
      self:ManualOpenMenuList()
    else
      self:ManualCloseMenuList()
    end
  end
end
def.override("string").OnClick = function(self, id)
  if id == "Btn_Menu" then
    self:OperateMenuList()
  elseif id == "Btn_GardenPet" then
    if HomelandModule.Instance():IsInSelfHomeland() then
      require("Main.Pokemon.ui.PokemonOperationPanel").ShowPanel(self.uiObjs.Group_In:FindDirect("Btn_GardenPet"))
    else
      require("Main.Pokemon.ui.MyPokemonPanel").ShowPanel()
    end
  elseif id == "Btn_GardenSet" then
    require("Main.Homeland.ui.FurnitureBagPanel").ShowPanel()
  elseif id == "Btn_Garden" then
    require("Main.Homeland.ui.CourtyardInfoPanel").Instance():ShowPanel()
  end
end
def.method("boolean").SetRefreshState = function(self, targetState)
  self.m_NeedRefresh = targetState
end
def.method("boolean").SetOpenSprite = function(self, isOpen)
  if self.uiObjs.openSprite and self.uiObjs.closeSprite then
    self.uiObjs.openSprite:SetActive(isOpen)
    self.uiObjs.closeSprite:SetActive(not isOpen)
  end
end
def.method("boolean").SetAllowAutoClose = function(self, isAllow)
  if self.m_AllowAutoClose == isAllow then
    return
  end
  if isAllow then
    self.m_AllowAutoClose = true
    if 0 == self.m_Timer then
      self:ResetPeriod()
      self.m_Timer = GameUtil.AddGlobalTimer(1, false, function()
        if self.m_node and self.m_node:get_activeInHierarchy() and self.m_open then
          if not self.m_AllowAutoClose then
            warn("Main Menu Btn AutoClose State is Error !!!!!")
            if self.m_Timer ~= 0 then
              GameUtil.RemoveGlobalTimer(self.m_Timer)
              self.m_Timer = 0
              self:ResetPeriod()
            end
            return
          end
          self.m_period = self.m_period + 1
          if AUTO_CLOSE_TIME <= self.m_period then
            self:ManualCloseMenuList()
          end
        end
      end)
    end
  else
    self.m_AllowAutoClose = false
    if 0 ~= self.m_Timer then
      GameUtil.RemoveGlobalTimer(self.m_Timer)
      self.m_Timer = 0
      self:ResetPeriod()
    end
  end
end
def.method().ResetPeriod = function(self)
  self.m_period = 0
end
def.method().ShakeBag = function(self)
  if self.m_node and not self.m_node.isnil then
    local playTween = self.m_node:FindDirect("Btn_Bag"):GetComponent("UIPlayTween")
    if playTween then
      playTween:Play(true)
    end
  end
end
def.method().ShakeFabao = function(self)
  if self.m_node and not self.m_node.isnil then
    if self.m_open then
      local playTween = self.m_node:FindDirect("Group_Btn/Btn_FaBao"):GetComponent("UIPlayTween")
      if playTween then
        playTween:Play(true)
      end
    else
      do
        local fabaoShadow = self.m_node:FindDirect("Btn_FaBao_Shadow")
        fabaoShadow:SetActive(true)
        local playTween = fabaoShadow:GetComponent("UIPlayTween")
        if playTween then
          playTween:Play(true)
        end
        GameUtil.AddGlobalTimer(0.5, true, function()
          if not fabaoShadow.isnil then
            fabaoShadow:SetActive(false)
          end
        end)
      end
    end
  end
end
def.method().OperateMenuList = function(self)
  if self.m_open then
    self:CloseMenuList()
    self:ResetPeriod()
    if self:hasMenuBtnEffect() then
      GameUtil.AddGlobalLateTimer(0.6, true, function()
        if self.m_node ~= nil and not self.m_open then
          GUIUtils.AddLightEffectToPanel("panel_main/Pnl_BtnGroup_Bottom/MenuGroup_Btn/Btn_Menu", GUIUtils.Light.Round)
        end
      end)
    end
  else
    self:SetAllowAutoClose(true)
    self:OpenMenuList()
  end
end
def.method("=>", "boolean").MenuGroupIsOpen = function(self)
  return self.m_open
end
def.method().OpenMenuList = function(self)
  self.m_open = true
  self.m_attemptOpen = self.m_open
  self:SetOpenSprite(false)
  local menuList = self.m_node:FindDirect("Btn_Menu")
  for i = 1, menuList.transform.childCount do
    menuList.transform:GetChild(i - 1):set_localScale(EC.Vector3.new(1, 1, 1))
  end
  self.m_isMenuHided = false
  self:PlayTweens(true)
  self:UpdateCloseBtnGroup()
end
def.method().CloseMenuList = function(self)
  self.m_open = false
  self.m_attemptOpen = self.m_open
  self:SetOpenSprite(true)
  self.m_isMenuHided = true
  self:PlayTweens(false)
end
def.method("boolean").PlayTweens = function(self, reverse)
  if self.uiObjs == nil then
    return
  end
  if reverse then
    Event.DispatchEvent(ModuleId.MAINUI, gmodule.notifyId.MainUI.OPEN_MAINMENU, nil)
  else
    Event.DispatchEvent(ModuleId.MAINUI, gmodule.notifyId.MainUI.CLOSE_MAINMENU, nil)
  end
  local forward = not reverse
  local uiPlayTween = self.uiObjs.Btn_Menu:GetComponent("UIPlayTween")
  uiPlayTween:Play(forward)
end
def.method("string", "string").onTweenerFinish = function(self, id, id2)
  if not self.m_open and not self.m_isMenuHided then
    self:OnCloseMenuListFinished(id)
  end
  if "Btn_Menu" == id then
  end
end
def.method("string").onCommonPlayTweenFinish = function(self, id)
  if "Btn_Menu" == id then
    self:UpdateCloseBtnGroup()
  end
end
def.method("string").OnCloseMenuListFinished = function(self, id)
  local menuList = self.m_node:FindDirect("Btn_Menu")
  for i = 1, menuList.transform.childCount do
    menuList.transform:GetChild(i - 1):set_localScale(EC.Vector3.new(0, 0, 0))
  end
  self.m_isMenuHided = true
end
def.method().CheckTweenPositionState = function(self)
  if nil == self.m_node then
    return
  end
  local btnSet = self.m_node:FindDirect("Group_Btn/Btn_Settle")
  if btnSet then
    local localPos = btnSet.transform.localPosition
    local localX = math.floor(math.abs(localPos.x))
    if localX >= 0 and localX <= 15 and self.m_open then
      self.m_open = false
      self.m_isMenuHided = true
      self:SetOpenSprite(true)
    elseif localX > 15 and not self.m_open then
      self.m_open = true
      self.m_isMenuHided = false
      self:SetOpenSprite(false)
    end
  end
end
def.method().ManualOpenMenuList = function(self)
  if self.m_open then
  end
  if self.uiObjs == nil then
    return
  end
  if self.uiObjs.Btn_Menu.activeInHierarchy then
    self:OpenMenuList()
  end
  self.m_attemptOpen = true
end
def.method().ManualCloseMenuList = function(self)
  if not self.m_open then
  end
  if self.uiObjs == nil then
    return
  end
  if self.uiObjs.Btn_Menu.activeInHierarchy then
    self:CloseMenuList()
    self:ResetPeriod()
  end
  self.m_attemptOpen = false
end
def.method("number").SetEquipmentUnreadMessageNum = function(self, num)
  local lastNum = num
  local EquipModule = require("Main.Equip.EquipModule")
  local hasRedNotice = EquipModule.Instance():CheckRedNoticeAll()
  if hasRedNotice then
    lastNum = 1
  end
  self:SetUnreadMessageNum("Btn_Make/Img_MakeRed", "Label_MakeRedNum", lastNum)
end
def.method("number").SetFightSettingUnreadMessageNum = function(self, num)
  self:SetUnreadMessageNum("Btn_Settle/Img_SettleRed", "Label_SettleRedNum", num)
end
def.method("number").SetGangUnreadMessageNum = function(self, num)
  local bNeedShowMainUINotice = require("Main.Gang.GangUtility").NeedShowMainUINotice()
  self:SetUnreadMessage("Btn_Faction/Img_FactionRed", "Label_FactionRedNum", bNeedShowMainUINotice)
end
def.method("number").SetQYZhiUnreadMessageNum = function(self, num)
  self:SetUnreadMessageNum("Btn_QYZhi/Img_RankRed", "Label", num)
end
def.method("number").SetSkillUnreadMessageNum = function(self, num)
  self:SetUnreadMessageNum("Btn_Skill/Img_SkillRed", "Label_SkillRedNum", num)
end
def.method().UpdateSkillUnreadMessageNum = function(self)
  local hasNotify = require("Main.Skill.SkillMgr").Instance():HasNotify()
  self:SetSkillUnreadMessageNum(hasNotify and 1 or 0)
end
def.method().UpdatePartnerUnreadMessageNum = function(self)
  local hasNotify = PartnerInterface.HasNotify()
  self:SetPartnerUnreadMessageNum(hasNotify and 1 or 0)
  self:UpdateMenuBtnRedNotice()
end
def.method("number").SetPartnerUnreadMessageNum = function(self, num)
  self:SetUnreadMessageNum("Btn_Partner/Img_PartnerRed", "Label_PartnerRedNum", num)
end
def.method("table").UpdateHomelandUnreadMessageNum = function(self, p)
  local bHasNotify = false
  if p == nil then
    local PokemonModule = require("Main.Pokemon.PokemonModule")
    local bPokemonReddot = PokemonModule.Instance():NeedReddot()
    local bMysteryVisitorActive = require("Main.Homeland.homeVisitor.homeVisitorMgr").IsActActive()
    local bCanCourtyardBeCleand = require("Main.Homeland.CourtyardMgr").Instance():CanCourtyardBeCleand()
    if bPokemonReddot or bMysteryVisitorActive or bCanCourtyardBeCleand then
      bHasNotify = true
    end
  else
    bHasNotify = p[1]
  end
  self:SetHomelandUnreadMessageNum(bHasNotify and 1 or 0)
end
def.method("number").SetHomelandUnreadMessageNum = function(self, num)
  self:SetUnreadMessageNum("Btn_HomeBack/Img_MakeRed", "Label_MakeRedNum", num)
end
def.method("string", "string", "number").SetUnreadMessageNum = function(self, imgName, labelName, num)
  if self.m_node == nil or self.m_node.isnil then
    return
  end
  local ui_Group_Btn = self.m_node:FindDirect("Group_Btn")
  if num <= 0 then
    ui_Group_Btn:FindDirect(imgName):SetActive(false)
  else
    local img = ui_Group_Btn:FindDirect(imgName)
    img:SetActive(true)
    img:FindDirect(labelName):GetComponent("UILabel"):set_text(num)
  end
end
def.method("string", "string", "boolean").SetUnreadMessage = function(self, imgName, labelName, haveMessage)
  if self.m_node == nil or self.m_node.isnil then
    return
  end
  local ui_Group_Btn = self.m_node:FindDirect("Group_Btn")
  if haveMessage then
    local img = ui_Group_Btn:FindDirect(imgName)
    img:SetActive(true)
    img:FindDirect(labelName):GetComponent("UILabel").text = ""
  else
    ui_Group_Btn:FindDirect(imgName):SetActive(false)
  end
end
def.method().UpdateMenuBtnRedNotice = function(self)
  local EquipModule = require("Main.Equip.EquipModule")
  local equipRedNotice = EquipModule.Instance():CheckRedNoticeAll()
  local skillRedNotice = require("Main.Skill.SkillMgr").Instance():HasNotify()
  local gangRedNotice = require("Main.Gang.GangUtility").NeedShowMainUINotice()
  local fabaoRedNotice = require("Main.Fabao.FabaoModule").Instance():CheckMainUIRedNotice()
  local homeVisitorNotice = require("Main.Homeland.homeVisitor.homeVisitorMgr").IsActActive()
  local partnerNotice = PartnerInterface.HasNotify()
  local wingNotice = require("Main.Wing.WingInterface").HasWingNotify()
  if self.uiObjs.Img_TipRed then
    if equipRedNotice or skillRedNotice or gangRedNotice or fabaoRedNotice or homeVisitorNotice or partnerNotice or wingNotice then
      self.uiObjs.Img_TipRed:SetActive(true)
    else
      self.uiObjs.Img_TipRed:SetActive(false)
    end
  end
end
def.method("string", "=>", "boolean").SetMenuBtnEffect = function(self, uiPath)
  if self.m_node == nil then
    return false
  end
  GUIUtils.AddLightEffectToPanel(uiPath, GUIUtils.Light.Round)
  if not self.m_open then
    GUIUtils.AddLightEffectToPanel("panel_main/Pnl_BtnGroup_Bottom/MenuGroup_Btn/Btn_Menu", GUIUtils.Light.Round)
  end
  return true
end
def.method("=>", "boolean").hasMenuBtnEffect = function(self)
  if self.m_node == nil then
    return false
  end
  local BtnGroup = self.m_node:FindDirect("Group_Btn")
  if BtnGroup == nil then
    return false
  end
  local effect = BtnGroup:FindChild(MENU_BTN_EFFECT_NAME)
  return effect ~= nil
end
def.static("table", "table").OnGangApplierChange = function(params, context)
  local num = params and params[1] or 0
  instance:SetGangUnreadMessageNum(num)
  warn("OnGangApplierChange ....", num)
end
def.static("table", "table").OnGangNoticeStatesChange = function(params, context)
  instance:SetGangUnreadMessageNum(0)
  MainUIMainMenu.Instance():UpdateMenuBtnRedNotice()
end
def.static("table", "table").OnSkillNotifyUpdate = function(params, context)
  instance:UpdateSkillUnreadMessageNum()
  MainUIMainMenu.Instance():UpdateMenuBtnRedNotice()
end
def.static("table", "table").OnOracleChange = function(params, context)
  instance:UpdateSkillUnreadMessageNum()
  MainUIMainMenu.Instance():UpdateMenuBtnRedNotice()
end
def.static("table", "table").OnFunctionInit = function(params, context)
  MainUIMainMenu.OnOracleChange(params, context)
end
def.static("table", "table").OnBagLeftCapacityChange = function(params)
  local self = instance
  local leftCapacity = params.left
  local isBagFull = leftCapacity == 0
  self.uiObjs.Img_BagRed:SetActive(isBagFull)
end
def.static("table", "table").OnOperationMenuBtn = function(params, context)
  local self = MainUIMainMenu.Instance()
  self:ResetPeriod()
end
def.static("table", "table").OnEquipNoticeChange = function(params, context)
  local self = MainUIMainMenu.Instance()
  if self.m_node and false == self.m_node.isnil then
    local EquipModule = require("Main.Equip.EquipModule")
    local hasRedNotice = EquipModule.Instance():CheckRedNoticeAll()
    local num = 0
    if hasRedNotice then
      num = 1
    end
    MainUIMainMenu.Instance():SetUnreadMessageNum("Btn_Make/Img_MakeRed", "Label_MakeRedNum", num)
    self:UpdateMenuBtnRedNotice()
  end
end
def.static("table", "table").OnItemChange = function(p1, p2)
  local bagId = p1.bagId
  if bagId == require("Main.Item.ItemModule").BAG then
    local self = MainUIMainMenu.Instance()
    self:UpdateFabaoRedNotice()
  end
end
def.static("table", "table").OnAirCraftChange = function(p1, p2)
  local self = MainUIMainMenu.Instance()
  self:UpdateFlyBtn(true)
end
def.static("table", "table").OnFlyChange = function(p1, p2)
  instance:UpdateFlyBtn(true)
end
def.static("table", "table").OnMysteryVisitorChange = function(p, context)
  local self = MainUIMainMenu.Instance()
  self:UpdateHomelandUnreadMessageNum(p)
end
def.method("boolean").UpdateFlyBtn = function(self, repos)
  if self.uiObjs == nil or self.uiObjs.Group_In == nil then
    return
  end
  local flyBtn = self.uiObjs.Group_In:FindDirect("Btn_Horse")
  local isCouplyFly = FlyModule.Instance().isInCoupleFly
  if isCouplyFly then
    flyBtn:SetActive(true)
    local btnSprite = flyBtn:GetComponent("UISprite")
    btnSprite:set_spriteName("Img_FlySplit")
  else
    local myRole = gmodule.moduleMgr:GetModule(ModuleId.HERO).myRole
    local btnSprite = flyBtn:GetComponent("UISprite")
    if myRole and myRole:IsInState(RoleState.FLY) then
      flyBtn:SetActive(true)
      btnSprite:set_spriteName("Img_Land")
    elseif FlyModule.Instance():HasAirCraft() then
      flyBtn:SetActive(true)
      btnSprite:set_spriteName("Img_Fly")
    else
      flyBtn:SetActive(false)
    end
  end
  if repos then
    self:UpdateCloseBtnGroupPos()
  end
end
def.method("boolean").UpdateFurnitureBagBtn = function(self, repos)
  if self.uiObjs == nil or self.uiObjs.Group_In == nil then
    return
  end
  local Btn_Home = self.uiObjs.Group_In:FindDirect("Btn_Home")
  local canShow = gmodule.moduleMgr:GetModule(ModuleId.HOMELAND):IsInSelfHouse()
  if canShow then
    local furnitureNums = require("Main.Homeland.FurnitureBag").Instance():GetHouseFurnitureNumbers()
    local hasNew = require("Main.Homeland.FurnitureBag").Instance():GetHouseHasNew()
    local Img_Furniture = Btn_Home:FindDirect("Img_Furniture")
    if hasNew then
      Btn_Home:FindDirect("Img_NewFurniture"):SetActive(true)
    else
      Btn_Home:FindDirect("Img_NewFurniture"):SetActive(false)
    end
    if furnitureNums > 0 then
      GUIUtils.SetActive(Img_Furniture, true)
      local Label_FurnitureNum = GUIUtils.FindDirect(Img_Furniture, "Label_FurnitureNum")
      GUIUtils.SetText(Label_FurnitureNum, furnitureNums)
    else
      GUIUtils.SetActive(Img_Furniture, false)
    end
  elseif gmodule.moduleMgr:GetModule(ModuleId.HOMELAND):IsInSelfCourtyard() then
    local furnitureNums = require("Main.Homeland.FurnitureBag").Instance():GetCourtyardFurnitureNumbers()
    local hasNew = require("Main.Homeland.FurnitureBag").Instance():GetCourtyardHasNew()
    local Btn_GardenSet = self.uiObjs.Group_In:FindDirect("Btn_GardenSet")
    local Img_Furniture = Btn_GardenSet:FindDirect("Img_Furniture")
    if hasNew then
      Btn_GardenSet:FindDirect("Img_NewFurniture"):SetActive(hasNew)
    else
      Btn_GardenSet:FindDirect("Img_NewFurniture"):SetActive(false)
    end
    if furnitureNums > 0 then
      GUIUtils.SetActive(Img_Furniture, true)
      local Label_FurnitureNum = GUIUtils.FindDirect(Img_Furniture, "Label_MakeRedNum")
      GUIUtils.SetText(Label_FurnitureNum, furnitureNums)
    else
      GUIUtils.SetActive(Img_Furniture, false)
    end
  end
  GUIUtils.SetActive(Btn_Home, canShow)
  if repos then
    self:UpdateCloseBtnGroupPos()
  end
end
def.method("boolean").UpdateCourtyardBtns = function(self, repos)
  if self.uiObjs == nil or self.uiObjs.Group_In == nil then
    return
  end
  local canShow = gmodule.moduleMgr:GetModule(ModuleId.HOMELAND):IsInSelfCourtyard()
  local courtyardFeatureOpen = require("Main.Homeland.CourtyardMgr").Instance():IsFeatureOpen()
  local pokemonFeatureOpen = gmodule.moduleMgr:GetModule(ModuleId.POKEMON):IsOpen(false)
  local bInHomeland = gmodule.moduleMgr:GetModule(ModuleId.HERO).isInHomeland
  local Btn_GardenPet = self.uiObjs.Group_In:FindDirect("Btn_GardenPet")
  local Btn_GardenSet = self.uiObjs.Group_In:FindDirect("Btn_GardenSet")
  local Btn_Garden = self.uiObjs.Group_In:FindDirect("Btn_Garden")
  GUIUtils.SetActive(Btn_GardenPet, canShow and bInHomeland and pokemonFeatureOpen)
  GUIUtils.SetActive(Btn_GardenSet, canShow and courtyardFeatureOpen)
  GUIUtils.SetActive(Btn_Garden, canShow and courtyardFeatureOpen)
  local hasNew = require("Main.Homeland.FurnitureBag").Instance():GetCourtyardHasNew()
  if hasNew then
    Btn_GardenSet:FindDirect("Img_NewFurniture"):SetActive(true)
  else
    Btn_GardenSet:FindDirect("Img_NewFurniture"):SetActive(false)
  end
  if canShow then
    self:UpdateCourtyardInfoBtnNotifys()
  end
  if repos then
    self:UpdateCloseBtnGroupPos()
  end
end
def.method().UpdateCloseBtnGroup = function(self)
  local CloseGroup = self.uiObjs.Group_In
  if not self.m_isMenuHided or self.m_open then
    GUIUtils.SetActive(CloseGroup, false)
    return
  end
  GUIUtils.SetActive(CloseGroup, true)
  self:UpdateFlyBtn(false)
  self:UpdateFurnitureBagBtn(false)
  self:UpdateCourtyardBtns(false)
  self:UpdateCloseBtnGroupPos()
end
def.method().UpdateCloseBtnGroupPos = function(self)
  if self.uiObjs == nil or self.uiObjs.Group_In == nil then
    return
  end
  local uiGrid = self.uiObjs.Group_In:GetComponent("UIGrid")
  uiGrid:Reposition()
end
def.static("table", "table").OnFabaoNoticeChange = function(p1, p2)
  local self = MainUIMainMenu.Instance()
  if self.m_node and not self.m_node.isnil then
    self:UpdateFabaoRedNotice()
  end
end
def.static("table", "table").OnFabaoSpiritNoticeChange = function(p, c)
  local self = MainUIMainMenu.Instance()
  if self.m_node and not self.m_node.isnil then
    self:UpdateFabaoRedNotice()
  end
end
def.static("table", "table").OnHomelandSenceChange = function(p1, p2)
  local self = MainUIMainMenu.Instance()
  if self.m_node and not self.m_node.isnil then
    if gmodule.moduleMgr:GetModule(ModuleId.HERO).isInHomeland then
      self:ManualCloseMenuList()
      self:UpdateHomelandPokemonRedPoints()
    else
      self:UpdateCloseBtnGroup()
    end
  end
end
def.static("table", "table").OnSyncFurnitureBagInfo = function(p1, p2)
  local self = MainUIMainMenu.Instance()
  if self.m_node and not self.m_node.isnil then
    self:UpdateFurnitureBagBtn(true)
  end
end
def.static("table", "table").OnCourtyardFeatureChange = function(p1, p2)
  local self = MainUIMainMenu.Instance()
  if self.m_node and not self.m_node.isnil then
    self:UpdateCourtyardBtns(true)
    self:UpdateHomelandUnreadMessageNum(nil)
  end
end
def.static("table", "table").OnPokemonInfoChange = function(p1, p2)
  local self = MainUIMainMenu.Instance()
  if self.m_node and not self.m_node.isnil then
    warn("[MainUIMainMenu:OnPokemonInfoChange] OnPokemonInfoChange.")
    GameUtil.AddGlobalTimer(0.01, true, function()
      self:UpdateHomelandPokemonRedPoints()
    end)
  end
end
def.static("table", "table").OnFunctionOpenChange = function(param, context)
  local self = MainUIMainMenu.Instance()
  local ModuleFunSwitchInfo = require("netio.protocol.mzm.gsp.open.ModuleFunSwitchInfo")
  if param.feature == ModuleFunSwitchInfo.TYPE_ZOO then
    if self.m_node and not self.m_node.isnil then
      self:UpdateHomelandPokemonRedPoints()
    end
  elseif param.feature == ModuleFunSwitchInfo.TYPE_GENIUS then
    MainUIMainMenu.OnOracleChange(param, context)
  end
end
def.static("table", "table").OnMyCourtyardCleannessChange = function(param, context)
  local self = MainUIMainMenu.Instance()
  if self.m_node and not self.m_node.isnil then
    self:UpdateHomelandUnreadMessageNum(nil)
    if HomelandModule.Instance():IsInSelfHomeland() then
      self:UpdateCourtyardInfoBtnNotifys()
    end
  end
end
def.static("table", "table").OnCourtyardLevelUp = function(param, context)
  local self = MainUIMainMenu.Instance()
  if self.m_node and not self.m_node.isnil then
    self:UpdateHomelandUnreadMessageNum(nil)
  end
end
def.static("table", "table").OnDivorce = function(param, context)
  local self = MainUIMainMenu.Instance()
  if self.m_node and not self.m_node.isnil then
    self:UpdateHomelandUnreadMessageNum(nil)
  end
end
def.static("table", "table").OnGodWeaponFeatureChange = function(param, context)
  local self = MainUIMainMenu.Instance()
  if self.m_node and not self.m_node.isnil then
    self:UpdateGodWeaponRedPoints()
  end
end
def.static("table", "table").OnPartnerNotifyChange = function(param, context)
  local self = MainUIMainMenu.Instance()
  if self.m_node and not self.m_node.isnil then
    self:UpdatePartnerUnreadMessageNum()
  end
end
def.static("table", "table").OnWingNotifyChange = function(param, context)
  local self = MainUIMainMenu.Instance()
  if self.m_node and not self.m_node.isnil then
    self:UpdateWingRedNotice()
    self:UpdateMenuBtnRedNotice()
  end
end
def.method().UpdateWingRedNotice = function(self)
  local num = 0
  if require("Main.Wing.WingInterface").HasWingNotify() then
    num = 1
  end
  self:SetUnreadMessageNum("Btn_Wing/Img_MakeRed", "Label_MakeRedNum", num)
end
def.method().UpdateFabaoRedNotice = function(self)
  if nil == self.m_node or self.m_node.isnil then
    return
  end
  local FabaoModule = require("Main.Fabao.FabaoModule")
  local hasRedNotice = FabaoModule.Instance():CheckMainUIRedNotice()
  local fabaoRedImg = self.m_node:FindDirect("Group_Btn/Btn_FaBao/Img_Red")
  local FabaoSpiritModule = require("Main.FabaoSpirit.FabaoSpiritModule")
  local hasLQRedNotice = FabaoSpiritModule.CheckLQRedNotice()
  fabaoRedImg:SetActive(hasRedNotice or hasLQRedNotice)
  self:UpdateMenuBtnRedNotice()
end
def.method().UpdateCourtyardInfoBtnNotifys = function(self)
  local Img_Red = self.m_node:FindDirect("Group_In/Btn_Garden/Img_Red")
  local bHasNotify = require("Main.Homeland.CourtyardMgr").Instance():CanCourtyardBeCleand()
  GUIUtils.SetActive(Img_Red, bHasNotify)
end
MainUIMainMenu.Commit()
return MainUIMainMenu
