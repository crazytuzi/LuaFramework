local Lplus = require("Lplus")
local ECPanelBase = require("GUI.ECPanelBase")
local GUIUtils = require("GUI.GUIUtils")
local MainUIPanel = Lplus.Extend(ECPanelBase, "MainUIPanel")
local def = MainUIPanel.define
local FuncType = require("consts.mzm.gsp.guide.confbean.FunType")
local GuideModule = Lplus.ForwardDeclare("GuideModule")
local Vector = require("Types.Vector")
local mainuiConfig = require("Main.MainUI.data.config")
local FightMgr = require("Main.Fight.FightMgr")
local Feature = require("netio.protocol.mzm.gsp.open.ModuleFunSwitchInfo")
local MainUIUtils = require("Main.MainUI.MainUIUtils")
local safeCall = _G.SafeCall
local LIMIT_NUM_PER_LINE = 7
local BtnGroupId = {
  Main = 1,
  Top = 2,
  Left = 3
}
def.const("table").BtnGroupId = BtnGroupId
def.const("table").BtnGroupDef = {
  [BtnGroupId.Main] = {
    {
      type = FuncType.XIANLV,
      name = "Btn_Partner"
    },
    {
      type = FuncType.SKILL,
      name = "Btn_Skill"
    },
    {
      type = FuncType.WING,
      name = "Btn_Wing"
    },
    {
      type = FuncType.FABAO,
      name = "Btn_FaBao"
    },
    {
      type = FuncType.GANG,
      name = "Btn_Faction"
    },
    {
      type = FuncType.EQUIP,
      name = "Btn_Make"
    },
    {
      type = FuncType.SETTING,
      name = "Btn_Settle"
    },
    {
      type = FuncType.RANK,
      name = "Btn_PaiHang"
    },
    {
      name = "Btn_ZuoQi",
      isOpen = function()
        return MainUIPanel.IsZuoQiFunctionOpen()
      end
    },
    {
      type = FuncType.HOMELAND,
      name = "Btn_HomeBack",
      isOpen = function()
        return MainUIPanel.IsHomelandFunctionOpen()
      end
    },
    {
      name = "Btn_GodsWeapon",
      isOpen = function()
        return MainUIPanel.IsGodWeaponFunctionOpen()
      end
    }
  },
  [BtnGroupId.Top] = {
    {
      type = FuncType.GUIDE,
      name = "Btn_Lead"
    },
    {
      type = FuncType.GUAJI,
      name = "Btn_Auto"
    },
    {
      type = FuncType.ACTIVITY,
      name = "Btn_Activity"
    },
    {
      type = FuncType.GAME_COMMUNITY,
      name = "Group_GameHome",
      isOpen = function()
        return not _G.IsOverseasVersion()
      end
    },
    {
      type = 1000,
      name = "Btn_BingFen",
      isOpen = function()
        return MainUIPanel.IsCustomActivityOpen()
      end
    },
    {
      type = FuncType.ADVANCE,
      name = "Btn_GuideUp"
    }
  },
  [BtnGroupId.Left] = {
    {
      type = FuncType.MALL,
      name = "Btn_Mall"
    },
    {
      type = FuncType.TRADE,
      name = "Btn_Shop"
    },
    {
      type = FuncType.AWARD,
      name = "Btn_Reward"
    }
  }
}
def.field("table").mainUIList = nil
def.field("table").btnGroups = nil
def.field("table").clickEventHandlerList = nil
def.field("table").toggleEventHandlerList = nil
def.field("boolean")._firstShow = true
def.field("table").uiObjs = nil
def.field("boolean").isTopBtnOpposite = false
def.field("table").cameraBtnDisplayableBitmap = nil
local Id = mainuiConfig.ComponentId
def.const("table").ComponentIDList = Id
def.field("boolean").isExpanded = true
def.field("boolean").isNeedShrink = false
local instance
def.static("=>", MainUIPanel).Instance = function()
  if instance == nil then
    instance = MainUIPanel()
    instance:Init()
    instance.m_ChangeLayerOnShow = true
  end
  return instance
end
def.method().Init = function(self)
  local Id = MainUIPanel.ComponentIDList
  self.mainUIList = {
    [Id.RoleHead] = require("Main.MainUI.ui.MainUIRoleHead").Instance(),
    [Id.MapRadar] = require("Main.MainUI.ui.MainUIMapRadar").Instance(),
    [Id.MainMenu] = require("Main.MainUI.ui.MainUIMainMenu").Instance(),
    [Id.Chat] = require("Main.MainUI.ui.MainUIChat").Instance(),
    [Id.RightSubPanel] = require("Main.MainUI.ui.MainUIRightSubPanel").Instance(),
    [Id.RoleExp] = require("Main.MainUI.ui.MainUIRoleExp").Instance(),
    [Id.TaskTrace] = require("Main.MainUI.ui.MainUITaskTrace").Instance(),
    [Id.PetHead] = require("Main.MainUI.ui.MainUIPetHead").Instance(),
    [Id.TopActivity] = require("Main.MainUI.ui.MainUITopActivity").Instance(),
    [Id.Buff] = require("Main.MainUI.ui.MainUIBuff").Instance(),
    [Id.TopButtonGroup] = require("Main.MainUI.ui.MainUITopButtonGroup").Instance(),
    [Id.LeftButtonGroup] = require("Main.MainUI.ui.MainUILeftButtonGroup").Instance(),
    [Id.HeadPortraitGroup] = require("Main.MainUI.ui.HeadPortraitGroup").Instance(),
    [Id.BackToMain] = require("Main.MainUI.ui.BackToMain").Instance(),
    [Id.NewFunction] = require("Main.MainUI.ui.MainUINewFunctionForecast").Instance()
  }
  for i, ui in pairs(self.mainUIList) do
    ui:Init()
  end
  require("Main.MainUI.ui.OutFightTargetPanel").Instance():Init()
end
def.method().ShowMainUI = function(self)
  if self.m_panel == nil then
    self:ShowPanel()
    return
  end
  for i, ui in pairs(self.mainUIList) do
    safeCall(ui.CheckDisplayable, ui)
  end
end
def.method("boolean").HideIncomplete = function(self, isHide)
  if self.m_panel ~= nil then
    local isShow = not isHide
    self.mainUIList[Id.MapRadar]:SetVisible(isShow)
    self.mainUIList[Id.MainMenu]:SetVisible(isShow)
    self.mainUIList[Id.TopButtonGroup]:SetVisible(isShow)
    self.mainUIList[Id.LeftButtonGroup]:SetVisible(isShow)
    self.mainUIList[Id.RightSubPanel]:SetVisible(isShow)
    self.mainUIList[Id.NewFunction]:SetVisible(isShow)
  end
end
def.override().OnCreate = function(self)
  local Pnl_Map_Info = self.m_panel:FindDirect("Pnl_MapInfo")
  if Pnl_Map_Info == nil then
    Toast("Please update \"Panel_Main.prefab\" res!")
    self:DestroyPanel()
    return
  end
  self:InitUI()
  self:SyncPanelState()
  for i, ui in pairs(self.mainUIList) do
    safeCall(ui.OnCreate, ui)
  end
  self:InitEventHandlerList()
  Event.RegisterEvent(ModuleId.MAINUI, gmodule.notifyId.MainUI.SCENE_CHANGE, MainUIPanel.OnMainUISceneChange)
  Event.RegisterEvent(ModuleId.FIGHT, gmodule.notifyId.Fight.ENTER_FIGHT, MainUIPanel.OnEnterFight)
  Event.RegisterEvent(ModuleId.FIGHT, gmodule.notifyId.Fight.LEAVE_FIGHT, MainUIPanel.OnLeaveFight)
  Event.RegisterEvent(ModuleId.GUIDE, gmodule.notifyId.Guide.New_Promote_Way, MainUIPanel.OnPromoteChange)
  Event.RegisterEvent(ModuleId.HERO, gmodule.notifyId.Hero.HERO_STATUS_CHANGED, MainUIPanel.OnPVP3StateChange)
  Event.RegisterEvent(ModuleId.PK, gmodule.notifyId.PK.UPDATE_AWARD, MainUIPanel.OnPVP3UpdateAward)
  Event.RegisterEvent(ModuleId.RELATIONSHIPCHAIN, gmodule.notifyId.RelationShipChain.QQVIPCharge, MainUIPanel.OnQQVIPCharge)
  Event.RegisterEvent(ModuleId.CUSTOM_ACTIVITY, gmodule.notifyId.CustomActivity.UPDATE_RED_POINT, MainUIPanel.OnUpdateCustomActivityRedPoint)
  Event.RegisterEvent(ModuleId.CUSTOM_ACTIVITY, gmodule.notifyId.CustomActivity.CUSTOM_ACTIVITY_OPEN_CHANGE, MainUIPanel.OnCustomActivityOpenChange)
  Event.RegisterEvent(ModuleId.FEATURE, gmodule.notifyId.Feature.FeatureOpenInit, MainUIPanel.OnFeatureOpenInit)
  Event.RegisterEvent(ModuleId.FEATURE, gmodule.notifyId.Feature.FeatureOpenChange, MainUIPanel.OnFeatureOpenChange)
  Event.RegisterEvent(ModuleId.MOUNTS, gmodule.notifyId.Mounts.MountsFunctionOpenChange, MainUIPanel.OnMountsFunctionOpenChange)
  Event.RegisterEvent(ModuleId.HOMELAND, gmodule.notifyId.Homeland.FunctionOpenChange, MainUIPanel.OnHomelandFunctionOpenChange)
  Event.RegisterEvent(ModuleId.GOD_WEAPON, gmodule.notifyId.GodWeapon.GOD_WEAPON_FEATURE_CHANGE, MainUIPanel.OnGodWeaponFunctionOpenChange)
  Event.RegisterEvent(ModuleId.SNAPSHOT, gmodule.notifyId.Snapshot.FEATURE_OPEN_CHANGE, MainUIPanel.OnSnapshotFeatureOpenChange)
  local advWays = require("Main.Guide.GuideModule").Instance().advWays
  local hasAdv = advWays ~= nil and next(advWays) or false
  MainUIPanel.OnPromoteChange({hasAdv}, nil)
  MainUIPanel.OnUpdateCustomActivityRedPoint({}, {})
  MainUIPanel.OnCustomActivityOpenChange({}, {})
  self:Refresh()
  local ECGame = require("Main.ECGame")
  ECGame.Instance():PreLoadRes()
end
def.override("boolean").OnShow = function(self, s)
  if s == false then
    self:OnHide()
    return
  end
  self:ShowMainUI()
  GameUtil.AddGlobalLateTimer(0, true, function(...)
    if self._firstShow then
      Event.DispatchEvent(ModuleId.MAINUI, gmodule.notifyId.MainUI.MAINUI_SHOW, nil)
      self._firstShow = false
    end
  end)
  MainUIPanel.OnPVP3UpdateAward(nil, nil)
end
def.method("=>", "userdata").GetTrumpetAnchor = function(self)
  if FightMgr.Instance().isInFight then
    return self.m_panel:FindDirect("Pnl_Chat/Panel_Btn/Position_Broadcast/Point_Battle")
  else
    return self.m_panel:FindDirect("Pnl_Chat/Panel_Btn/Position_Broadcast/Point_Main")
  end
end
def.override("number").OnLayerChange = function(self, newLayer)
  for i, ui in pairs(self.mainUIList) do
    ui:OnLayerChange(newLayer)
  end
end
def.override().OnDestroy = function(self)
  Event.DispatchEvent(ModuleId.MAINUI, gmodule.notifyId.MainUI.MAINUI_HIDE, nil)
  for i, ui in pairs(self.mainUIList) do
    ui:Destroy()
  end
  Event.UnregisterEvent(ModuleId.MAINUI, gmodule.notifyId.MainUI.SCENE_CHANGE, MainUIPanel.OnMainUISceneChange)
  Event.UnregisterEvent(ModuleId.FIGHT, gmodule.notifyId.Fight.ENTER_FIGHT, MainUIPanel.OnEnterFight)
  Event.UnregisterEvent(ModuleId.FIGHT, gmodule.notifyId.Fight.LEAVE_FIGHT, MainUIPanel.OnLeaveFight)
  Event.UnregisterEvent(ModuleId.GUIDE, gmodule.notifyId.Guide.New_Promote_Way, MainUIPanel.OnPromoteChange)
  Event.UnregisterEvent(ModuleId.PK, gmodule.notifyId.PK.UPDATE_AWARD, MainUIPanel.OnPVP3UpdateAward)
  Event.UnregisterEvent(ModuleId.RELATIONSHIPCHAIN, gmodule.notifyId.RelationShipChain.QQVIPCharge, MainUIPanel.OnQQVIPCharge)
  Event.UnregisterEvent(ModuleId.CUSTOM_ACTIVITY, gmodule.notifyId.CustomActivity.UPDATE_RED_POINT, MainUIPanel.OnUpdateCustomActivityRedPoint)
  Event.UnregisterEvent(ModuleId.CUSTOM_ACTIVITY, gmodule.notifyId.CustomActivity.CUSTOM_ACTIVITY_OPEN_CHANGE, MainUIPanel.OnCustomActivityOpenChange)
  Event.UnregisterEvent(ModuleId.FEATURE, gmodule.notifyId.Feature.FeatureOpenInit, MainUIPanel.OnFeatureOpenInit)
  Event.UnregisterEvent(ModuleId.FEATURE, gmodule.notifyId.Feature.FeatureOpenChange, MainUIPanel.OnFeatureOpenChange)
  Event.UnregisterEvent(ModuleId.MOUNTS, gmodule.notifyId.Mounts.MountsFunctionOpenChange, MainUIPanel.OnMountsFunctionOpenChange)
  Event.UnregisterEvent(ModuleId.HOMELAND, gmodule.notifyId.Homeland.FunctionOpenChange, MainUIPanel.OnHomelandFunctionOpenChange)
  Event.UnregisterEvent(ModuleId.GOD_WEAPON, gmodule.notifyId.GodWeapon.GOD_WEAPON_FEATURE_CHANGE, MainUIPanel.OnGodWeaponFunctionOpenChange)
  Event.UnregisterEvent(ModuleId.SNAPSHOT, gmodule.notifyId.Snapshot.FEATURE_OPEN_CHANGE, MainUIPanel.OnSnapshotFeatureOpenChange)
  self.clickEventHandlerList = nil
  self.toggleEventHandlerList = nil
  self.isExpanded = true
  self.isNeedShrink = false
  self._firstShow = true
  self.uiObjs = nil
  self.isTopBtnOpposite = false
  self.cameraBtnDisplayableBitmap = nil
end
def.method("=>", "boolean").IsReady = function(self)
  return self._firstShow == false
end
def.method().OnHide = function(self)
  if self.clickEventHandlerList == nil then
    return
  end
  for i, ui in pairs(self.mainUIList) do
    ui:PassiveHide()
  end
end
def.method().InitEventHandlerList = function(self)
  self.clickEventHandlerList = {
    Btn_Bag = self.Click_BagButton,
    Img_IconRole = self.Click_RoleHead,
    Img_BgPetHead = self.Click_PetHead,
    Img_BgMap = self.Click_WorldMap,
    Btn_MiniMap = self.Click_MiniMap,
    Buff_Role = self.Click_BuffIcon,
    Btn_Auto = self.Click_AutoFightButton,
    Btn_Activity = self.Click_ActivityButton,
    Btn_Make = self.Click_EquipmentButton,
    Btn_Settle = self.Click_SettingButton,
    Btn_Faction = self.Click_GangButton,
    Btn_PaiHang = self.Click_RanklistButton,
    Btn_Skill = self.Click_SKillButton,
    Btn_Wing = self.Click_WingsButton,
    Btn_Partner = self.Click_PartnerButton,
    Btn_Mall = self.Click_ShopButton,
    Btn_Shop = self.Click_TradingCenterButton,
    Btn_Reward = self.Click_AwardButton,
    Btn_Chat = self.Click_ChatButton,
    Btn_Talk = self.Click_SocialButton,
    Btn_Horse = self.Click_RideButton,
    Btn_GuideUp = self.Click_GuideUpButton,
    Btn_FaBao = self.Click_FabaoButton,
    Btn_PVP3 = self.Click_PVP3Button,
    Btn_Lead = self.Click_GrowGuideButton,
    Btn_GameHome = self.Click_GameCommunity,
    Btn_BingFen = self.Click_CustomActivity,
    Btn_QQ = self.Click_VIPRight,
    Btn_Fuli = self.Click_VIPRight,
    Btn_Vip = self.Click_QQVIPWellFare,
    Btn_Home = self.Click_HomeFurnitureBagBtn,
    Btn_ZuoQi = self.Click_ZuoQiButton,
    Btn_HomeBack = self.Click_HomeBackButton,
    Btn_GodsWeapon = self.Click_GodWeapon,
    Btn_MainInfoOpen = self.Click_MainInfoOpenButton,
    Btn_MainInfoClose = self.Click_MainInfoCloseButton,
    Btn_Camera = self.Click_CameraButton
  }
  self.toggleEventHandlerList = {}
end
def.method("string", "string").onTweenerFinish = function(self, id, id2)
  require("Main.MainUI.ui.MainUIMainMenu").Instance():onTweenerFinish(id, id2)
end
def.method("string").onCommonPlayTweenFinish = function(self, id)
  require("Main.MainUI.ui.MainUIMainMenu").Instance():onCommonPlayTweenFinish(id)
end
def.method("string").onClick = function(self, id)
  warn(id)
  local isCatched = self:DelegateClickEvent(id)
  if not isCatched then
    for i, ui in pairs(self.mainUIList) do
      ui:OnClick(id)
    end
  end
end
def.method("string", "string", "number").onSelect = function(self, id, selected, index)
  self.mainUIList[Id.Chat]:onSelect(id, selected, index)
end
def.method("string", "userdata").onSubmit = function(self, id, ctrl)
  self.mainUIList[Id.Chat]:onSubmit(id, ctrl)
end
def.method("string", "boolean").onPress = function(self, id, press)
  self.mainUIList[Id.Chat]:onPress(id, press)
end
def.method("string", "userdata").onDragOut = function(self, id, go)
  self.mainUIList[Id.Chat]:onDragOut(id, go)
end
def.method("string", "userdata").onDragOver = function(self, id, go)
  self.mainUIList[Id.Chat]:onDragOver(id, go)
end
def.method("string", "number", "number").onDrag = function(self, id, dx, dy)
  self.mainUIList[Id.Chat]:onDrag(id, dx, dy)
end
def.method("string", "=>", "boolean").DelegateClickEvent = function(self, id)
  if self.clickEventHandlerList == nil then
    return false
  end
  local handler = self.clickEventHandlerList[id]
  if handler then
    handler(self)
    return true
  end
  return false
end
def.method("string").onLongPress = function(self, id)
  if id == "Btn_Auto" then
    Event.DispatchEvent(ModuleId.MAINUI, gmodule.notifyId.MainUI.LONG_PRESS_BTN_AUTOFIGHT, nil)
  end
end
def.method().ShowPanel = function(self)
  if self.m_panel then
    self:DestroyPanel()
  end
  self:CreatePanel(RESPATH.MAINUI_PANEL_RES, 0)
  self._firstShow = true
  self:SetDepth(GUIDEPTH.BOTTOM)
end
def.method().Hide = function(self)
  self:DestroyPanel()
end
def.method().SyncPanelState = function(self)
  for i, ui in pairs(self.mainUIList) do
    ui.m_panel = self.m_panel
    ui.m_parent = self.m_parent
    ui.m_container = self
  end
  self.mainUIList[Id.HeadPortraitGroup].m_node = self.m_panel:FindDirect("Pnl_RolePet/RolePetGroup")
  self.mainUIList[Id.RoleHead].m_node = self.mainUIList[Id.HeadPortraitGroup].m_node:FindDirect("Img_BgCharacter")
  self.mainUIList[Id.PetHead].m_node = self.mainUIList[Id.HeadPortraitGroup].m_node:FindDirect("Img_BgPet")
  self.mainUIList[Id.MapRadar].m_node = self.m_panel:FindDirect("Pnl_MapInfo/Img_BgMap")
  self.mainUIList[Id.RightSubPanel].m_node = self.m_panel:FindDirect("Pnl_TaskTeam/TaskTeamMenu")
  self.mainUIList[Id.Chat].m_node = self.m_panel:FindDirect("Pnl_Chat")
  self.mainUIList[Id.RoleExp].m_node = self.m_panel:FindDirect("Slider_Exp")
  self.mainUIList[Id.MainMenu].m_node = self.m_panel:FindDirect("Pnl_BtnGroup_Bottom/MenuGroup_Btn")
  self.mainUIList[Id.Buff].m_node = self.m_panel:FindDirect("Pnl_RolePet/RolePetGroup/Buff_Role")
  self.mainUIList[Id.TopButtonGroup].m_node = self.m_panel:FindDirect("Pnl_BtnGroup_Top/BtnGroup_Top")
  self.mainUIList[Id.LeftButtonGroup].m_node = self.m_panel:FindDirect("Pnl_BtnGroup_Left/BtnGroup_Left")
  self.mainUIList[Id.BackToMain].m_node = self.m_panel:FindDirect("Group_Back")
  self.mainUIList[Id.NewFunction].m_node = self.m_panel:FindDirect("Pnl_NewFunction/Group_NewFunction")
  for componentId, binding in pairs(mainuiConfig.DisplayableBinding) do
    local component = self.mainUIList[componentId]
    if component then
      if binding.undisplay then
        component:SetUndisplayScenes(binding.undisplay)
      end
    else
      warn(string.format("MainUI:SyncPanelState: No component found for id=%d!", componentId))
    end
  end
end
def.static("table", "table").OnEnterFight = function()
  local self = instance
  for i, ui in pairs(self.mainUIList) do
    ui:OnEnterFight()
  end
  if not self.m_panel.activeSelf then
    self.m_panel:SetActive(true)
  end
  if not self.isExpanded then
    self:ExpandAll(true)
    self.isNeedShrink = true
  end
end
def.static("table", "table").OnLeaveFight = function()
  local self = instance
  for i, ui in pairs(self.mainUIList) do
    ui:OnLeaveFight()
  end
  if self.isNeedShrink then
    self:ExpandAll(false)
    self.isNeedShrink = false
  end
end
def.static("table", "table").OnMainUISceneChange = function(p1, p2)
  local self = instance
  for i, ui in pairs(self.mainUIList) do
    ui:CheckDisplayable()
  end
  self:RefreshCameraBtn()
end
def.static("table", "table").OnPVP3StateChange = function(p1, p2)
  if instance.m_panel == nil or instance.m_panel.isnil then
    return
  end
  instance:RefreshPVP3Active()
end
def.static("table", "table").OnPromoteChange = function(p1, p2)
  local promote = instance.m_panel:FindDirect("Pnl_BtnGroup_Top/BtnGroup_Top/Btn_GuideUp")
  local promoteRed = promote:FindDirect("Img_ActivityRed")
  promoteRed:SetActive(false)
  local has = p1[1] and true or false
  local btnGroup = MainUIPanel.BtnGroupDef[BtnGroupId.Top]
  local funcType = FuncType.ADVANCE
  local funcDef = getmetatable(btnGroup).funcTypes[funcType]
  if funcDef == nil then
    warn(string.format("OnPromoteChange:can't find funcType=%d", funcType))
    return
  end
  if funcDef.isOpen == has then
    return
  end
  funcDef.isOpen = has
  instance:RefreshTopBtnGroup()
  if has then
    local active = promote:get_activeSelf()
    promote:SetActive(true)
    if not active then
      GUIUtils.SetLightEffect(promote, GUIUtils.Light.Round)
    end
  else
    promote:SetActive(false)
  end
end
def.static("table", "table").OnUpdateCustomActivityRedPoint = function(p1, p2)
  if instance and instance.m_panel then
    local Btn_BingFen = instance.m_panel:FindDirect("Pnl_BtnGroup_Top/BtnGroup_Top/Btn_BingFen")
    local Img_ActivityRed = Btn_BingFen:FindDirect("Img_ActivityRed")
    local CustomActivityInterface = require("Main.CustomActivity.CustomActivityInterface")
    local flag = CustomActivityInterface.Instance():isOwnRedPoint()
    Img_ActivityRed:SetActive(flag)
    gmodule.moduleMgr:GetModule(ModuleId.MAINUI):SetTopLeftBtnsNotifyCount(Btn_BingFen, flag and 1 or 0)
  end
end
def.static("table", "table").OnCustomActivityOpenChange = function(p1, p2)
  if instance then
    local isOpen = MainUIPanel.IsCustomActivityOpen()
    local Btn_BingFen = instance.m_panel:FindDirect("Pnl_BtnGroup_Top/BtnGroup_Top/Btn_BingFen")
    if Btn_BingFen then
      local activeSelf = Btn_BingFen.activeSelf
      if activeSelf ~= isOpen then
        Btn_BingFen:SetActive(isOpen)
        instance:RefreshTopBtnGroup()
      end
    end
  end
end
def.static("=>", "boolean").IsCustomActivityOpen = function()
  local CustomActivityPanel = require("Main.CustomActivity.ui.CustomActivityPanel")
  local isOpen = CustomActivityPanel.isOwnOpendActivity()
  return isOpen
end
def.static("table", "table").OnMountsFunctionOpenChange = function(p1, p2)
  if instance then
    instance:RefreshMainMenuGroup()
  end
end
def.static("table", "table").OnHomelandFunctionOpenChange = function(p1, p2)
  if instance then
    instance:RefreshMainMenuGroup()
  end
end
def.static("table", "table").OnGodWeaponFunctionOpenChange = function(p1, p2)
  if instance then
    instance:RefreshMainMenuGroup()
  end
end
def.static("table", "table").OnSnapshotFeatureOpenChange = function(p1, p2)
  if instance then
    instance:RefreshCameraBtn()
  end
end
def.static("table", "table").OnFeatureOpenInit = function(params, context)
  MainUIPanel.OnCustomActivityOpenChange(params, context)
  instance:UpdateMainInfoBtnVisibility()
end
def.static("table", "table").OnFeatureOpenChange = function(params, context)
  local featureType = params.feature
  if featureType == Feature.TYPE_MAIN_UI_TOP_LEFT_BUTTON_GROUP_VISIBILITY then
    instance:UpdateMainInfoBtnVisibility()
  end
end
def.static("=>", "boolean").IsZuoQiFunctionOpen = function()
  local MountsModule = require("Main.Mounts.MountsModule")
  return MountsModule.IsFunctionOpen()
end
def.static("=>", "boolean").IsHomelandFunctionOpen = function()
  return gmodule.moduleMgr:GetModule(ModuleId.HOMELAND):IsFunctionOpen()
end
def.static("=>", "boolean").IsGodWeaponFunctionOpen = function()
  return gmodule.moduleMgr:GetModule(ModuleId.GOD_WEAPON):IsFunctionOpen()
end
def.method().ShowServiceLockedInfo = function(self)
  Toast(textRes.Common[9])
end
def.method().Click_UndefineButton = function(self)
  self:ShowServiceLockedInfo()
end
def.method().Click_BagButton = function(self)
  Event.DispatchEvent(ModuleId.MAINUI, gmodule.notifyId.MainUI.BTN_BAG_CLICK, nil)
end
def.method().Click_RoleHead = function(self)
  Event.DispatchEvent(ModuleId.MAINUI, gmodule.notifyId.MainUI.BTN_ROLE_PROP_CLICK, nil)
end
def.method().Click_PetHead = function(self)
  Event.DispatchEvent(ModuleId.MAINUI, gmodule.notifyId.MainUI.BTN_PET_PROP_CLICK, nil)
end
def.method().Click_WorldMap = function(self)
  Event.DispatchEvent(ModuleId.MAINUI, gmodule.notifyId.MainUI.BTN_WORLD_MAP_CLICK, nil)
end
def.method().Click_MiniMap = function(self)
  Event.DispatchEvent(ModuleId.MAINUI, gmodule.notifyId.MainUI.BTN_MINI_MAP_CLICK, nil)
end
def.method().Click_BuffIcon = function(self)
  self.mainUIList[Id.Buff]:HideGuideTip()
  Event.DispatchEvent(ModuleId.MAINUI, gmodule.notifyId.MainUI.BUFF_ICON_CLICK, nil)
end
def.method().Click_AutoFightButton = function(self)
  gmodule.moduleMgr:GetModule(ModuleId.ONHOOK)
  Event.DispatchEvent(ModuleId.MAINUI, gmodule.notifyId.MainUI.BTN_AUTOFIGHT_CLICK, nil)
end
def.method().Click_ActivityButton = function(self)
  Event.DispatchEvent(ModuleId.MAINUI, gmodule.notifyId.MainUI.BTN_ACTIVITY_CLICK, nil)
end
def.method().Click_RideButton = function(self)
  Event.DispatchEvent(ModuleId.MAINUI, gmodule.notifyId.MainUI.BTN_FLY_CLICK, nil)
end
def.method().Click_EquipmentButton = function(self)
  gmodule.moduleMgr:GetModule(ModuleId.EQUIP)
  Event.DispatchEvent(ModuleId.MAINUI, gmodule.notifyId.MainUI.BTN_EQUIPMENT_CLICK, nil)
  Event.DispatchEvent(ModuleId.MAINUI, gmodule.notifyId.MainUI.MENU_BTN_OPERATION, nil)
end
def.method().Click_GangButton = function(self)
  Event.DispatchEvent(ModuleId.MAINUI, gmodule.notifyId.MainUI.BTN_GANG_CLICK, nil)
  Event.DispatchEvent(ModuleId.MAINUI, gmodule.notifyId.MainUI.MENU_BTN_OPERATION, nil)
end
def.method().Click_SettingButton = function(self)
  Event.DispatchEvent(ModuleId.MAINUI, gmodule.notifyId.MainUI.BTN_SYSTEM_SETTING_CLICK, nil)
  Event.DispatchEvent(ModuleId.MAINUI, gmodule.notifyId.MainUI.MENU_BTN_OPERATION, nil)
end
def.method().Click_RanklistButton = function(self)
  gmodule.moduleMgr:GetModule(ModuleId.RANK_LIST)
  Event.DispatchEvent(ModuleId.MAINUI, gmodule.notifyId.MainUI.BTN_RANKLIST_CLICK, nil)
  Event.DispatchEvent(ModuleId.MAINUI, gmodule.notifyId.MainUI.MENU_BTN_OPERATION, nil)
end
def.method().Click_SKillButton = function(self)
  Event.DispatchEvent(ModuleId.MAINUI, gmodule.notifyId.MainUI.BTN_SKILL_CLICK, nil)
  Event.DispatchEvent(ModuleId.MAINUI, gmodule.notifyId.MainUI.MENU_BTN_OPERATION, nil)
end
def.method().Click_WingsButton = function(self)
  Event.DispatchEvent(ModuleId.MAINUI, gmodule.notifyId.MainUI.BTN_WINGS_CLICK, nil)
  Event.DispatchEvent(ModuleId.MAINUI, gmodule.notifyId.MainUI.MENU_BTN_OPERATION, nil)
end
def.method().Click_PartnerButton = function(self)
  gmodule.moduleMgr:GetModule(ModuleId.PARTNER)
  Event.DispatchEvent(ModuleId.MAINUI, gmodule.notifyId.MainUI.BTN_PARTNER_CLICK, nil)
  Event.DispatchEvent(ModuleId.MAINUI, gmodule.notifyId.MainUI.MENU_BTN_OPERATION, nil)
end
def.method().Click_ShopButton = function(self)
  local ECMSDK = require("ProxySDK.ECMSDK")
  ECMSDK.SendTLogToServer(_G.TLOGTYPE.MALL, {})
  gmodule.moduleMgr:GetModule(ModuleId.MALL)
  Event.DispatchEvent(ModuleId.MAINUI, gmodule.notifyId.MainUI.BTN_SHOP_CLICK, nil)
end
def.method().Click_TradingCenterButton = function(self)
  local ECMSDK = require("ProxySDK.ECMSDK")
  ECMSDK.SendTLogToServer(_G.TLOGTYPE.EXCHANGE, {})
  gmodule.moduleMgr:GetModule(ModuleId.COMMERCEANDPITCH)
  Event.DispatchEvent(ModuleId.MAINUI, gmodule.notifyId.MainUI.BTN_TRADING_CENTER_CLICK, nil)
end
def.method().Click_AwardButton = function(self)
  local ECMSDK = require("ProxySDK.ECMSDK")
  ECMSDK.SendTLogToServer(_G.TLOGTYPE.AWARD, {})
  Event.DispatchEvent(ModuleId.MAINUI, gmodule.notifyId.MainUI.BTN_AWARD_CLICK, nil)
end
def.method().Click_FirstTimeRechargeRewardButton = function(self)
  self:ShowServiceLockedInfo()
end
def.method().Click_ChatButton = function(self)
  Event.DispatchEvent(ModuleId.MAINUI, gmodule.notifyId.MainUI.BTN_SOCIAL_CLICK, nil)
end
def.method().Click_SocialButton = function(self)
  local ECMSDK = require("ProxySDK.ECMSDK")
  ECMSDK.SendTLogToServer(_G.TLOGTYPE.CHATAREASTATUS, {1})
  Event.DispatchEvent(ModuleId.MAINUI, gmodule.notifyId.MainUI.BTN_CHAT_CLICK, nil)
end
def.method().Click_FabaoButton = function(self)
  Event.DispatchEvent(ModuleId.MAINUI, gmodule.notifyId.MainUI.BTN_FABAO_CLICK, {
    id = count == 0 and 1 or 3
  })
  Event.DispatchEvent(ModuleId.MAINUI, gmodule.notifyId.MainUI.MENU_BTN_OPERATION, nil)
end
def.method().Click_PVP3Button = function(self)
  local pkMain = require("Main.PK.ui.PKMainDlg")
  pkMain.Instance():ShowDlg()
end
def.method().Click_GuideUpButton = function(self)
  local promote = self.m_panel:FindDirect("Pnl_BtnGroup_Top/BtnGroup_Top/Btn_GuideUp")
  GUIUtils.SetLightEffect(promote, GUIUtils.Light.None)
  local screenPos = WorldPosToScreen(promote.transform.position.x, promote.transform.position.y)
  Event.DispatchEvent(ModuleId.MAINUI, gmodule.notifyId.MainUI.BTN_GUIDE_UP_CLICK, {
    screenPos.x,
    screenPos.y
  })
end
def.method().Click_GrowGuideButton = function(self)
  if ClientCfg.GetSDKType() == ClientCfg.SDKTYPE.MSDK then
    local ECMSDK = require("ProxySDK.ECMSDK")
    ECMSDK.SendTLogToServer(_G.TLOGTYPE.STRONG, {1})
  end
  Event.DispatchEvent(ModuleId.MAINUI, gmodule.notifyId.MainUI.BTN_GROW_GUIDE_CLICK, nil)
end
def.method().Click_GameCommunity = function(self)
  local anchorGO = self.mainUIList[Id.TopButtonGroup].m_node:FindDirect("Group_GameHome/Btn_GameHome")
  Event.DispatchEvent(ModuleId.MAINUI, gmodule.notifyId.MainUI.BTN_GAME_COMMUNITY_CLICK, {anchorGO})
end
def.method().Click_CustomActivity = function()
  local ECMSDK = require("ProxySDK.ECMSDK")
  ECMSDK.SendTLogToServer(_G.TLOGTYPE.FEEDBACK, {})
  Event.DispatchEvent(ModuleId.MAINUI, gmodule.notifyId.MainUI.BTN_CUSTOM_ACTIVITY, nil)
end
def.method().Click_VIPRight = function(self)
  local VIPRightPanel = require("Main.MainUI.ui.VIPRightPanel")
  VIPRightPanel.Instance():ShowPanel(_G.LoginPlatform == MSDK_LOGIN_PLATFORM.WX and 2 or 1)
end
def.method().Click_QQVIPWellFare = function(self)
  local QQVIPWellFarePanel = require("Main.MainUI.ui.QQVIPWellFarePanel")
  QQVIPWellFarePanel.Instance():ShowPanel(2)
end
def.method().Click_HomeFurnitureBagBtn = function(self)
  require("Main.Homeland.ui.FurnitureBagPanel").ShowPanel()
end
def.method().Click_ZuoQiButton = function(self)
  Event.DispatchEvent(ModuleId.MAINUI, gmodule.notifyId.MainUI.BTN_MOUNTS_CLICK, nil)
  Event.DispatchEvent(ModuleId.MAINUI, gmodule.notifyId.MainUI.MENU_BTN_OPERATION, nil)
end
def.method().Click_HomeBackButton = function(self)
  Event.DispatchEvent(ModuleId.MAINUI, gmodule.notifyId.MainUI.BTN_RETURN_HOME_CLICK, nil)
end
def.method().Click_GodWeapon = function(self)
  Event.DispatchEvent(ModuleId.MAINUI, gmodule.notifyId.MainUI.BTN_GODWEAPON_CLICK, nil)
end
def.method().Click_CameraButton = function(self)
  Event.DispatchEvent(ModuleId.MAINUI, gmodule.notifyId.MainUI.BTN_CAMERA_CLICK, nil)
end
def.method("string", "boolean").onToggle = function(self, id, value)
  if self.toggleEventHandlerList == nil then
    return
  end
  local handler = self.toggleEventHandlerList[id]
  if handler then
    handler(self, value)
  else
    self.mainUIList[Id.Chat]:OnToggle(id, value)
    self.mainUIList[Id.RightSubPanel]:OnToggle(id, value)
  end
end
def.method().InitUI = function(self)
  self.uiObjs = {}
  self.btnGroups = {}
  local topBtnGroup = self:InitBtnGroup(BtnGroupId.Top, "Pnl_BtnGroup_Top/BtnGroup_Top", "Btn_Lead", "Btn_Auto")
  local RightAnchor = self.m_panel:FindDirect("Pnl_BtnGroup_Top/Anchor_Right")
  topBtnGroup.raTransform = RightAnchor and RightAnchor.transform
  self.uiObjs.RightAnchor = RightAnchor
  self:InitBtnGroup(BtnGroupId.Main, "Pnl_BtnGroup_Bottom/MenuGroup_Btn/Group_Btn", "Btn_Partner", "Btn_PaiHang")
  self:InitBtnGroup(BtnGroupId.Left, "Pnl_BtnGroup_Left/BtnGroup_Left", "Btn_Mall", "Btn_Shop")
  self.uiObjs.Btn_MainInfoOpen = self.m_panel:FindDirect("Pnl_BtnGroup_Left/BtnGroup_Left/Btn_MainInfoOpen")
  self.uiObjs.Btn_MainInfoClose = self.m_panel:FindDirect("Pnl_BtnGroup_Left/BtnGroup_Left/Btn_MainInfoClose")
  if self.uiObjs.Btn_MainInfoOpen then
    local uiWidget = self.uiObjs.Btn_MainInfoOpen:GetComponent("UIWidget")
    uiWidget:set_alpha(0)
  end
  self.uiObjs.Btn_Camera = self.m_panel:FindDirect("Pnl_RolePet/RolePetGroup/Btn_Camera")
  if self.uiObjs.Btn_Camera then
    self.uiObjs.Btn_Camera_Init_LocalPosition = self.uiObjs.Btn_Camera.localPosition
    local rightBtn = self.m_panel:FindDirect("Pnl_RolePet/RolePetGroup/Group_QQ/Btn_Vip")
    local rightBtnWidth = 0
    if rightBtn then
      local uiWidget = rightBtn:GetComponent("UIWidget")
      rightBtnWidth = uiWidget and uiWidget.width or rightBtnWidth
    end
    self.uiObjs.Btn_Camera_Right_LocalPosition = self.uiObjs.Btn_Camera_Init_LocalPosition + Vector.Vector3.new(rightBtnWidth, 0, 0)
    local uiWidget = self.uiObjs.Btn_Camera:GetComponent("UIWidget")
    self.uiObjs.Btn_Camera_Width = uiWidget.width
    self.cameraBtnDisplayableBitmap = MainUIUtils.SetUndisplayScenes(self.cameraBtnDisplayableBitmap, mainuiConfig.DisplayableBinding[mainuiConfig.ComponentId.Camera].undisplay)
  end
  self:InitMainInfoBtnVisibility()
  local iterator = function(t, index)
    local index = index or 1
    local nextindex = index + 1
    if t[index] == nil then
      nextindex = nil
    end
    return nextindex, t[index]
  end
  local reverse_iterator = function(t, index)
    local index = index or #t
    local nextindex = index - 1
    if t[index] == nil then
      nextindex = nil
    end
    return nextindex, t[index]
  end
  for _, btnGroupId in pairs(BtnGroupId) do
    do
      local btnGroupDef = MainUIPanel.BtnGroupDef[btnGroupId]
      local mt = {}
      mt.__index = mt
      setmetatable(btnGroupDef, mt)
      mt.opposite = false
      function mt.iterator(_, index)
        if mt.opposite then
          return reverse_iterator(btnGroupDef, index)
        end
        return iterator(btnGroupDef, index)
      end
      function mt.reverse_iterator(_, index)
        if mt.opposite then
          return iterator(btnGroupDef, index)
        end
        return reverse_iterator(btnGroupDef, index)
      end
      mt.funcTypes = {}
      for i, v in ipairs(btnGroupDef) do
        if v.type then
          mt.funcTypes[v.type] = v
        end
      end
    end
  end
  if ClientCfg.GetSDKType() == ClientCfg.SDKTYPE.UNISDK then
    GUIUtils.SetActive(self.m_panel:FindDirect("Pnl_BtnGroup_Top/BtnGroup_Top/Group_GameHome/Btn_GameHome"), false)
  end
end
def.method("number", "string", "string", "string", "=>", "table").InitBtnGroup = function(self, btnGroupId, rootName, firstBtnName, secondBtnName)
  local btnGroup = {}
  local Group_Btn = self.m_panel:FindDirect(rootName)
  local startBtn = Group_Btn:FindDirect(firstBtnName)
  local secondBtn = Group_Btn:FindDirect(secondBtnName)
  local startPos = startBtn.transform.localPosition
  local secondPos = secondBtn.transform.localPosition
  local step = secondPos - startPos
  btnGroup.startPos = startPos
  btnGroup.step = step
  btnGroup.elem = startBtn
  btnGroup.rootObj = Group_Btn
  self.btnGroups[btnGroupId] = btnGroup
  return btnGroup
end
def.method().Refresh = function(self)
  if self.m_panel == nil then
    return
  end
  self:RefreshMainMenuGroup()
  self:RefreshTopBtnGroup()
  self:RefreshLeftBtnGroup()
  self:RefreshPVP3Active()
  self:RefreshVIPRightView()
end
def.method().RefreshVIPRightView = function(self)
  local ECMSDK = require("ProxySDK.ECMSDK")
  GUIUtils.SetActive(self.m_panel:FindDirect("Pnl_RolePet/RolePetGroup/Group_QQ"), _G.LoginPlatform == MSDK_LOGIN_PLATFORM.QQ and not GameUtil.IsEvaluation() and not ClientCfg.IsOtherChannel())
  GUIUtils.SetActive(self.m_panel:FindDirect("Pnl_RolePet/RolePetGroup/Group_Wechat"), _G.LoginPlatform == MSDK_LOGIN_PLATFORM.WX and not GameUtil.IsEvaluation() and not ClientCfg.IsOtherChannel())
  GUIUtils.SetActive(self.m_panel:FindDirect("Pnl_RolePet/RolePetGroup/Group_QQ/Img_FromGameCenter"), ECMSDK.IsQQGameCenter())
  GUIUtils.SetActive(self.m_panel:FindDirect("Pnl_RolePet/RolePetGroup/Group_QQ/Btn_Vip"), platform == 2)
  GameUtil.AddGlobalLateTimer(1, true, function()
    if self.m_panel and not self.m_panel.isnil then
      local vipLevel = require("Main.RelationShipChain.RelationShipChainMgr").GetSepicalVIPLevel()
      GUIUtils.SetActive(self.m_panel:FindDirect("Pnl_RolePet/RolePetGroup/Group_QQ/Img_VIP"), vipLevel == 1)
      GUIUtils.SetActive(self.m_panel:FindDirect("Pnl_RolePet/RolePetGroup/Group_QQ/Img_SVIP"), vipLevel == 2)
    end
  end)
  GUIUtils.SetActive(self.m_panel:FindDirect("Pnl_RolePet/RolePetGroup/Group_YingYongBao/Btn_Tequan"), ECMSDK.IsFromYYB())
  GUIUtils.SetActive(self.m_panel:FindDirect("Pnl_RolePet/RolePetGroup/Group_Wechat/Btn_Tequan"), ECMSDK.IsWXGameCenter())
  self:RefreshCameraBtn()
end
def.method().RefreshCameraBtn = function(self)
  if _G.IsNil(self.uiObjs.Btn_Camera) then
    return
  end
  local SnapshotModule = require("Main.Snapshot.SnapshotModule")
  local isOpen = SnapshotModule.Instance():IsFeatureOpen()
  local canDisplay = false
  if isOpen then
    canDisplay = MainUIUtils.CanDisplayByUndisplayBitmap(self.cameraBtnDisplayableBitmap)
  end
  GUIUtils.SetActive(self.uiObjs.Btn_Camera, canDisplay)
  if not isOpen then
    return
  end
  local function isDependedBtnShow(btnPathList)
    for i, path in ipairs(btnPathList) do
      local btn = self.m_panel:FindDirect(path)
      if btn and btn:get_activeInHierarchy() then
        return true
      end
    end
    return false
  end
  local dependedShow = isDependedBtnShow({
    "Pnl_RolePet/RolePetGroup/Group_QQ/Btn_Vip",
    "Pnl_RolePet/RolePetGroup/Group_QQ/Btn_QQ",
    "Pnl_RolePet/RolePetGroup/Group_Wechat/Btn_Fuli"
  })
  if dependedShow then
    self.uiObjs.Btn_Camera.localPosition = self.uiObjs.Btn_Camera_Init_LocalPosition
  else
    self.uiObjs.Btn_Camera.localPosition = self.uiObjs.Btn_Camera_Right_LocalPosition
  end
end
def.method("=>", "table").GetTopBtnRightOffsetPos = function(self)
  if _G.IsNil(self.uiObjs.Btn_Camera) or not self.uiObjs.Btn_Camera:get_activeSelf() then
    return Vector.Vector3.zero
  end
  local padding = 4
  local offsetPos = self.uiObjs.Btn_Camera.localPosition - self.uiObjs.Btn_Camera_Init_LocalPosition - Vector.Vector3.new(self.uiObjs.Btn_Camera_Width + padding, 0, 0)
  return offsetPos
end
def.method().RefreshPVP3Active = function(self)
  local pvp3Btn = instance.m_panel:FindDirect("Pnl_BtnGroup_Left/BtnGroup_Left/Btn_PVP3")
  local heroModule = require("Main.Hero.HeroModule")
  local myRole = heroModule.Instance().myRole
  local pkMain = require("Main.PK.ui.PKMainDlg")
  if myRole:IsInState(RoleState.TXHW) then
    pvp3Btn:SetActive(true)
  else
    pvp3Btn:SetActive(false)
    pkMain.Instance():Hide()
  end
end
def.static("table", "table").OnPVP3UpdateAward = function(p1, p2)
  local myRole = gmodule.moduleMgr:GetModule(ModuleId.HERO).myRole
  if not myRole:IsInState(RoleState.TXHW) then
    return
  end
  local pkdata = require("Main.PK.data.PKData").Instance()
  local pvp3Btn_red = instance.m_panel:FindDirect("Pnl_BtnGroup_Left/BtnGroup_Left/Btn_PVP3/Img_PVP3Red")
  if pvp3Btn_red == nil then
    return
  end
  local visilbe = not pkdata:IsReceiveWinItem(0) and pkdata.myInfo.winCount >= pkdata.mWin1 or not pkdata:IsReceiveWinItem(1) and pkdata.myInfo.winCount >= pkdata.mWin2
  pvp3Btn_red:SetActive(visilbe)
end
def.static("table", "table").OnQQVIPCharge = function(p1, p2)
  if instance.m_panel and not instance.m_panel.isnil then
    instance:RefreshVIPRightView()
  end
end
def.method().RefreshMainMenuGroup = function(self)
  if self.mainUIList[Id.MainMenu].m_node then
    local Group_Btn = self.mainUIList[Id.MainMenu].m_node:FindDirect("Group_Btn")
    local uiTweener = Group_Btn:GetComponent("UITweener")
    local isOpen = uiTweener.tweenFactor < 1 and true or false
    self:CommonRefreshBtnGroup(BtnGroupId.Main, Group_Btn, isOpen)
  end
end
def.method().RefreshTopBtnGroup = function(self)
  local Group_Btn = self.mainUIList[Id.TopButtonGroup].m_node
  self:CommonRefreshBtnGroup(BtnGroupId.Top, Group_Btn, true)
  Event.DispatchEvent(ModuleId.MAINUI, gmodule.notifyId.MainUI.TOP_LEFT_BTNS_NOTIFY_UPDATE, nil)
end
def.method().RefreshLeftBtnGroup = function(self)
  local Group_Btn = self.mainUIList[Id.LeftButtonGroup].m_node
  local btnGroupId = BtnGroupId.Left
  self:CommonRefreshBtnGroup(btnGroupId, Group_Btn, true)
  if self.uiObjs.Btn_MainInfoClose then
    local btnGroup = self.btnGroups[btnGroupId]
    local btnGroupDef = MainUIPanel.BtnGroupDef[btnGroupId]
    local btn
    for i, v in btnGroupDef.reverse_iterator, nil, nil do
      if v.btn and v.btn:get_activeSelf() then
        btn = v.btn
        break
      end
    end
    local uiRect = self.uiObjs.Btn_MainInfoClose:GetComponent("UIRect")
    uiRect:SetAnchor(btn.transform)
  end
  Event.DispatchEvent(ModuleId.MAINUI, gmodule.notifyId.MainUI.TOP_LEFT_BTNS_NOTIFY_UPDATE, nil)
end
def.method("number", "userdata", "boolean").CommonRefreshBtnGroup = function(self, btnGroupId, rootObj, isOpen)
  local btnGroup = self.btnGroups[btnGroupId]
  local count = 1
  local btnGroupDef = MainUIPanel.BtnGroupDef[btnGroupId]
  for i, v in btnGroupDef.iterator, nil, nil do
    local btn = v.btn
    if not btn or btn.isnil then
      btn = rootObj:FindDirect(v.name)
      v.btn = btn
    end
    if self:CheckFunction(v) then
      btn:SetActive(true)
      local x, y, z
      if btnGroupId == BtnGroupId.Main then
        local curRaw = math.floor(count / LIMIT_NUM_PER_LINE)
        local curCol = count % LIMIT_NUM_PER_LINE
        if curRaw > 0 then
          curCol = curCol + 1 or curCol
        end
        x = btnGroup.startPos.x + (curCol - 1) * btnGroup.step.x
        y = btnGroup.startPos.y + curRaw * btnGroup.step.y
        z = btnGroup.startPos.z
      else
        x = btnGroup.startPos.x + (count - 1) * btnGroup.step.x
        y = btnGroup.startPos.y + (count - 1) * btnGroup.step.y
        z = btnGroup.startPos.z
      end
      btn.transform.localPosition = Vector.Vector3.new(x, y, z)
      local tweenPosition = v.tp
      if not tweenPosition or tweenPosition.isnil then
        tweenPosition = btn:GetComponent("TweenPosition")
        v.tp = tweenPosition
      end
      if tweenPosition then
        tweenPosition.from = btn.transform.localPosition
        tweenPosition.to = Vector.Vector3.zero
        tweenPosition.enabled = false
        if isOpen then
          tweenPosition.value = tweenPosition.from
          tweenPosition.tweenFactor = 0
        else
          tweenPosition.value = tweenPosition.to
          tweenPosition.tweenFactor = 1
        end
      end
      count = count + 1
    else
      btn:SetActive(false)
    end
  end
end
def.method("table", "=>", "boolean").CheckFunction = function(self, btnDef)
  if type(btnDef.isOpen) == "boolean" then
    return btnDef.isOpen
  elseif type(btnDef.isOpen) == "function" then
    return btnDef.isOpen()
  else
    return GuideModule.Instance():CheckFunction(btnDef.type)
  end
end
def.method("number", "number", "=>", "table").AddFunction = function(self, funcType, aniDuration)
  if self.m_panel == nil or self.m_panel.isnil then
    return nil
  end
  for btnGroupId, btnGroupDef in ipairs(MainUIPanel.BtnGroupDef) do
    for i, v in btnGroupDef.iterator, nil, nil do
      if v.type == funcType then
        return self:AddBtn(btnGroupId, funcType, aniDuration)
      end
    end
  end
  return nil
end
def.method("number", "number", "number", "=>", "table").AddBtn = function(self, btnGroupId, funcType, aniDuration)
  if btnGroupId == BtnGroupId.Main then
    self.mainUIList[Id.MainMenu]:SetAllowAutoClose(false)
    self.mainUIList[Id.MainMenu]:ManualOpenMenuList()
  elseif btnGroupId == BtnGroupId.Top or btnGroupId == BtnGroupId.Left then
    self:SwitchMainInfoUI(true, true)
  end
  local btnGroup = self.btnGroups[btnGroupId]
  local btnGroupDef = MainUIPanel.BtnGroupDef[btnGroupId]
  local rootObj = btnGroup.rootObj
  local count = 0
  for i, v in btnGroupDef.iterator, nil, nil do
    local btn = rootObj:FindDirect(v.name)
    if self:CheckFunction(v) then
      count = count + 1
    end
  end
  local position
  for i, v in btnGroupDef.reverse_iterator, nil, nil do
    local btn = v.btn
    if not btn then
      btn = rootObj:FindDirect(v.name)
      v.btn = btn
    end
    if self:CheckFunction(v) then
      local x, y, z
      if btnGroupId == BtnGroupId.Main then
        local curRaw = math.floor(count / LIMIT_NUM_PER_LINE)
        local curCol = count % LIMIT_NUM_PER_LINE
        local curCol = curRaw > 0 and curCol + 1 or curCol
        x = btnGroup.startPos.x + (curCol - 1) * btnGroup.step.x
        y = btnGroup.startPos.y + curRaw * btnGroup.step.y
        z = btnGroup.startPos.z
      else
        x = btnGroup.startPos.x + (count - 1) * btnGroup.step.x
        y = btnGroup.startPos.y + (count - 1) * btnGroup.step.y
        z = btnGroup.startPos.z
      end
      local tweenPosition = v.tp
      if not tweenPosition or tweenPosition.isnil then
        tweenPosition = btn:GetComponent("TweenPosition")
        v.tp = tweenPosition
      end
      if v.type ~= funcType then
        if self:IsShow() and tweenPosition and btn:get_activeInHierarchy() then
          local from = btn.transform.localPosition
          local to = Vector.Vector3.new(x, y, z)
          TweenPosition.Begin(btn, aniDuration, to)
        else
          btn.transform.localPosition = Vector.Vector3.new(x, y, z)
        end
        count = count - 1
      else
        btn.transform.localPosition = Vector.Vector3.new(x, y, z)
        position = btn.transform.position
        GameUtil.AddGlobalLateTimer(aniDuration, true, function()
          GameUtil.AddGlobalLateTimer(0, true, function()
            if self.m_panel == nil or self.m_panel.isnil then
              return position
            end
            if btnGroupId == BtnGroupId.Main then
              self:RefreshMainMenuGroup()
              self.mainUIList[Id.MainMenu]:SetAllowAutoClose(true)
            elseif btnGroupId == BtnGroupId.Left then
              self:RefreshLeftBtnGroup()
            elseif btnGroupId == BtnGroupId.Top then
              self:RefreshTopBtnGroup()
            else
              self:Refresh()
            end
          end)
        end)
        break
      end
    end
  end
  return position
end
def.method().ToggleMainUI = function(self)
  if not self:IsShow() then
    return
  end
  self:ExpandAll(not self.isExpanded)
end
def.method("boolean").ExpandAll = function(self, isExpand)
  if self:IsShow() then
    if not isExpand and _G.PlayerIsInFight() then
      return
    end
    self.isExpanded = isExpand
    local ExpandOrShrink = function(component, isExpand)
      if isExpand then
        component:Expand()
      else
        component:Shrink()
      end
    end
    local idList = {
      Id.MapRadar,
      Id.TopButtonGroup,
      Id.HeadPortraitGroup,
      Id.LeftButtonGroup,
      Id.NewFunction,
      Id.Chat,
      Id.MainMenu,
      Id.BackToMain
    }
    for i, id in ipairs(idList) do
      local component = self.mainUIList[id]
      ExpandOrShrink(component, isExpand)
    end
    local component = self.mainUIList[Id.RightSubPanel]
    if not _G.PlayerIsInFight() and not self.isNeedShrink then
      ExpandOrShrink(component, isExpand)
    end
    Event.DispatchEvent(ModuleId.MAINUI, gmodule.notifyId.MainUI.ON_EXPAND, {isExpand = isExpand})
  end
end
def.method("=>", "table").GetMainMenuBtns = function(self)
  return MainUIPanel.BtnGroupDef[BtnGroupId.Main]
end
local isAddTongChenEffect
def.method().addTongChenEffect = function(self)
  if not isAddTongChenEffect and self.mainUIList[Id.Chat].m_node then
    local Btn_Horse = self.mainUIList[Id.MainMenu].m_node:FindDirect("Btn_Horse")
    if Btn_Horse then
      do
        local effect = require("Fx.GUIFxMan").Instance():PlayAsChild(Btn_Horse, RESPATH.BTN_LIGHT_SQUARE, 0, 0, -1, false)
        GameUtil.AddGlobalTimer(10, true, function()
          isAddTongChenEffect = nil
          Object.Destroy(effect)
        end)
      end
    end
  end
end
def.method("boolean").SetTopBtnGroupOpposite = function(self, isOpposite)
  if self.m_panel == nil or self.m_panel.isnil then
    return
  end
  self.isTopBtnOpposite = isOpposite
  local btnGroupId = BtnGroupId.Top
  if self.btnGroups[btnGroupId].raTransform == nil then
    warn(string.format("MainUIPanel:SetTopBtnGroupOpposite failed, because of the right anchor of top-button-group not found!"))
    return
  end
  local btnGroupDef = MainUIPanel.BtnGroupDef[btnGroupId]
  local mt = getmetatable(btnGroupDef)
  if mt.opposite ~= isOpposite then
    mt.opposite = isOpposite
    local btnGroup = self.btnGroups[btnGroupId]
    btnGroup.step.x = -btnGroup.step.x
    if isOpposite then
      btnGroup.startPosSave = btnGroup.startPos
      local rightAnchorPos = btnGroup.elem.transform.parent:InverseTransformPoint(btnGroup.raTransform.position)
      btnGroup.startPos = rightAnchorPos + self:GetTopBtnRightOffsetPos()
    elseif btnGroup.startPosSave then
      btnGroup.startPos = btnGroup.startPosSave
    end
  end
  self:RefreshTopBtnGroup()
  if not self:IsMainInfoUIGroupOpened() then
    if isOpposite then
      require("Main.MainUI.ui.TopFloatBtnGroup").Instance():SetBtnGroupAnchorRight()
    else
      require("Main.MainUI.ui.TopFloatBtnGroup").Instance():SetBtnGroupAnchorLeft()
    end
  end
end
def.method().Click_MainInfoOpenButton = function(self)
  self:OpenMainInfoUI()
end
def.method().Click_MainInfoCloseButton = function(self)
  self:CloseMainInfoUI()
end
def.method().OpenMainInfoUI = function(self)
  self:SwitchMainInfoUI(true, false)
end
def.method().CloseMainInfoUI = function(self)
  self:SwitchMainInfoUI(false, false)
end
def.method("boolean", "boolean").SwitchMainInfoUI = function(self, isOpen, openInstantly)
  local function switchMainInfoUIGroups(aniDuration)
    self:SwitchMainInfoUIGroup(BtnGroupId.Left, self.mainUIList[Id.TopButtonGroup], isOpen, aniDuration)
    self:SwitchMainInfoUIGroup(BtnGroupId.Top, self.mainUIList[Id.LeftButtonGroup], isOpen, aniDuration)
  end
  local aniDuration = 0.3
  local toAlpha, openAlphaDuration, closeAlphaDuration
  if isOpen then
    toAlpha = 0
    openAlphaDuration = 0
    closeAlphaDuration = 2 * aniDuration
  else
    switchMainInfoUIGroups(aniDuration)
    toAlpha = 1
    openAlphaDuration = 2 * aniDuration
    closeAlphaDuration = 0
  end
  TweenAlpha.Begin(self.uiObjs.Btn_MainInfoOpen, openAlphaDuration, toAlpha)
  TweenAlpha.Begin(self.uiObjs.Btn_MainInfoClose, closeAlphaDuration, 1 - toAlpha)
  require("Main.MainUI.ui.TopFloatBtnGroup").Instance():SwitchBtnGroupState(isOpen, aniDuration)
  if isOpen then
    if openInstantly then
      switchMainInfoUIGroups(aniDuration)
    else
      GameUtil.AddGlobalTimer(aniDuration, true, function()
        if not self:IsLoaded() then
          return
        end
        switchMainInfoUIGroups(aniDuration)
      end)
    end
  end
end
def.method("number", "table", "boolean", "number").SwitchMainInfoUIGroup = function(self, btnGroupId, component, isOpen, aniDuration)
  local btnGroup = self.btnGroups[btnGroupId]
  local btnGroupDef = MainUIPanel.BtnGroupDef[btnGroupId]
  local rootObj = btnGroup.rootObj
  if isOpen then
    component:CheckDisplayable()
  else
    GameUtil.AddGlobalTimer(aniDuration, true, function()
      if not self:IsLoaded() then
        return
      end
      component:CheckDisplayable()
    end)
  end
  local count = 1
  local toAlpha = isOpen and 1 or 0
  for i, v in btnGroupDef.iterator, nil, nil do
    local btn = v.btn
    if _G.IsNil(btn) then
      btn = rootObj:FindDirect(v.name)
      v.btn = btn
    end
    if btn:get_activeSelf() then
      local x, y, z
      x = btnGroup.startPos.x + (count - 1) * btnGroup.step.x
      y = btnGroup.startPos.y + (count - 1) * btnGroup.step.y
      z = btnGroup.startPos.z
      local tweenPosition = v.tp
      if _G.IsNil(tweenPosition) then
        tweenPosition = btn:GetComponent("TweenPosition")
        v.tp = tweenPosition
      end
      local toPosition
      if isOpen then
        toPosition = Vector.Vector3.new(x, y, z)
      else
        toPosition = btnGroup.startPos
      end
      TweenPosition.Begin(btn, aniDuration, toPosition)
      TweenAlpha.Begin(btn, aniDuration, toAlpha)
      count = count + 1
    else
      local uiWidget = btn:GetComponent("UIWidget")
      if uiWidget then
        uiWidget:set_alpha(toAlpha)
      end
    end
  end
end
def.method("=>", "boolean").IsMainInfoUIGroupOpened = function(self)
  if self.uiObjs.Btn_MainInfoOpen == nil then
    return true
  end
  local tweenAlpha = self.uiObjs.Btn_MainInfoOpen:GetComponent("TweenAlpha")
  if tweenAlpha then
    if tweenAlpha.to == 0 then
      return true
    else
      return false
    end
  else
    local alpha = self.uiObjs.Btn_MainInfoOpen:GetComponent("UIWidget"):get_alpha()
    if alpha == 0 then
      return true
    else
      return false
    end
  end
end
def.method("=>", "table").GetTopBtnGroupAnchorLeftPosition = function(self)
  return self.btnGroups[MainUIPanel.BtnGroupId.Top].elem.transform.position
end
def.method("=>", "table").GetTopBtnGroupAnchorRightPosition = function(self)
  local raTransform = self.btnGroups[MainUIPanel.BtnGroupId.Top].raTransform
  local offsetWPos = raTransform:TransformPoint(self:GetTopBtnRightOffsetPos()) - raTransform:TransformPoint(Vector.Vector3.zero)
  return raTransform.position + offsetWPos
end
def.method("=>", "boolean").IsTopBtnOpposite = function(self)
  return self.isTopBtnOpposite
end
def.method("=>", "boolean").IsMainInfoUICloseFeatureOpened = function(self)
  if IsFeatureOpen(Feature.TYPE_MAIN_UI_TOP_LEFT_BUTTON_GROUP_VISIBILITY) then
    return true
  else
    return false
  end
end
def.method().InitMainInfoBtnVisibility = function(self)
  if not gmodule.moduleMgr:GetModule(ModuleId.FEATURE):IsFeatureListInited() or not self:IsMainInfoUICloseFeatureOpened() then
    GUIUtils.SetActive(self.uiObjs.Btn_MainInfoOpen, false)
    GUIUtils.SetActive(self.uiObjs.Btn_MainInfoClose, false)
  else
    GUIUtils.SetActive(self.uiObjs.Btn_MainInfoOpen, true)
    GUIUtils.SetActive(self.uiObjs.Btn_MainInfoClose, true)
  end
end
def.method().UpdateMainInfoBtnVisibility = function(self)
  if self:IsMainInfoUICloseFeatureOpened() then
    self.uiObjs.Btn_MainInfoOpen:SetActive(true)
    self.uiObjs.Btn_MainInfoClose:SetActive(true)
  elseif self.uiObjs.Btn_MainInfoOpen:get_activeSelf() then
    self.uiObjs.Btn_MainInfoOpen:SetActive(false)
    self.uiObjs.Btn_MainInfoClose:SetActive(false)
    self:OpenMainInfoUI()
  end
end
def.method("=>", "table").GetMainInfoBtns = function(self)
  local btns = {}
  local leftBtns = MainUIPanel.BtnGroupDef[BtnGroupId.Left]
  local topBtns = MainUIPanel.BtnGroupDef[BtnGroupId.Top]
  for i, v in ipairs(leftBtns) do
    table.insert(btns, v)
  end
  for i, v in ipairs(topBtns) do
    table.insert(btns, v)
  end
  return btns
end
MainUIPanel.Commit()
return MainUIPanel
