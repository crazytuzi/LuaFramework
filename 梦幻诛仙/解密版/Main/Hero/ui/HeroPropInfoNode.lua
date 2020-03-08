local Lplus = require("Lplus")
local ECPanelBase = require("GUI.ECPanelBase")
local HeroPropPanelNodeBase = require("Main.Hero.ui.HeroPropPanelNodeBase")
local HeroPropInfoNode = Lplus.Extend(HeroPropPanelNodeBase, "HeroPropInfoNode")
local HeroPropMgr = require("Main.Hero.mgr.HeroPropMgr")
local HeroSecondProp = Lplus.ForwardDeclare("HeroSecondProp")
local HeroExtraProp = Lplus.ForwardDeclare("HeroExtraProp")
local HeroUtility = require("Main.Hero.HeroUtility")
local GameUnitType = require("consts.mzm.gsp.common.confbean.GameUnitType")
local TokenType = require("consts.mzm.gsp.item.confbean.TokenType")
local ItemModule = require("Main.Item.ItemModule")
local GangModule = require("Main.Gang.GangModule")
local TitleInterface = require("Main.title.TitleInterface")
local titleInterface = TitleInterface.Instance()
local FightMgr = require("Main.Fight.FightMgr")
local GangModule = Lplus.ForwardDeclare("GangModule")
local GangData = Lplus.ForwardDeclare("GangData")
local ECModel = require("Model.ECModel")
local GUIUtils = require("GUI.GUIUtils")
local EC = {}
EC.Vector3 = require("Types.Vector3").Vector3
local def = HeroPropInfoNode.define
def.field("table").uiObjs = nil
local instance
def.static("=>", HeroPropInfoNode).Instance = function()
  if instance == nil then
    instance = HeroPropInfoNode()
  end
  return instance
end
def.override("string").onClick = function(self, id)
  if id == "Btn_ModifyCW" then
    Event.DispatchEvent(ModuleId.MAINUI, gmodule.notifyId.MainUI.BTN_APPELLATION_CLICK, nil)
  elseif id == "Btn_ModifyTX" then
    Event.DispatchEvent(ModuleId.MAINUI, gmodule.notifyId.MainUI.BTN_TITLE_CLICK, nil)
  elseif id == "Btn_DuiHuanSM" then
    gmodule.moduleMgr:GetModule(ModuleId.CREDITSSHOP)
    Event.DispatchEvent(ModuleId.HERO, gmodule.notifyId.Hero.CREDITS_SHOP, {
      TokenType.JINGJICHANG_JIFEN
    })
  elseif id == "Btn_DuiHuanXY" then
    Event.DispatchEvent(ModuleId.HERO, gmodule.notifyId.Hero.CREDITS_SHOP, {
      TokenType.XIAYI_VALUE
    })
  elseif id == "Btn_DuiHuanSW" then
    Event.DispatchEvent(ModuleId.HERO, gmodule.notifyId.Hero.CREDITS_SHOP, {
      TokenType.REPUTATION_VALUE
    })
  elseif id == "Btn_DuiHuanZG" then
    if IsFeatureOpen(require("netio.protocol.mzm.gsp.open.ModuleFunSwitchInfo").TYPE_LADDER) then
      Event.DispatchEvent(ModuleId.HERO, gmodule.notifyId.Hero.CREDITS_SHOP, {
        TokenType.LADDER_SCORE
      })
    end
  elseif id == "Btn_DuiHuanZC" then
    Event.DispatchEvent(ModuleId.HERO, gmodule.notifyId.Hero.CREDITS_SHOP, {
      TokenType.SINGLE_CROSS_FIELD_SCORE
    })
  elseif id == "Btn_GoGang" then
    self:OnGotoGangMapButtonClicked()
  elseif id == "Btn_GoMenPai" then
    self:OnGotoOccupationMapButtonClicked()
  elseif id == "Btn_FuQi" then
    self:OnMarriageSkillButtonClicked()
  elseif id == "Btn_Badge_Tips" then
    local tipId = require("Main.Item.ItemUtils").GetTitleConst("BADGE_TIP")
    local tipStr = require("Main.Common.TipsHelper").GetHoverTip(tipId)
    local CommonUITipsDlg = require("GUI.CommonUITipsDlg")
    CommonUITipsDlg.Instance():ShowDlg(tipStr, {x = 0, y = 0})
  elseif string.find(id, "badge_") then
    local badgeId = tonumber(string.sub(id, 7))
    local badgeInfo = require("Main.Badge.BadgeModule").Instance():GetBadgeInfo(badgeId)
    local source = self.m_node:FindDirect("Group_Badge/Group_Badge/" .. id)
    local position = source:get_position()
    local screenPos = WorldPosToScreen(position.x, position.y)
    local widget = source:GetComponent("UIWidget")
    local desc = badgeInfo.desc .. os.date(textRes.Item[142], badgeInfo.limitTime)
    require("Main.Item.ItemTipsMgr").Instance():ShowCustomTip(badgeInfo.name, badgeInfo.iconId, textRes.Item[141], desc, screenPos.x, screenPos.y, widget:get_width(), widget:get_height(), 0)
  elseif id == "Btn_ModifyZT" then
    Event.DispatchEvent(ModuleId.MAINUI, gmodule.notifyId.MainUI.BUFF_ICON_CLICK, nil)
  elseif id == "Btn_Shitu" then
    self:OnShituInfoButtonClicked()
  elseif id == "Btn_ChangeHead" or id == "Img_BgHead01" then
    require("Main.Avatar.ui.AvatarPanel").Instance():ShowPanel()
  elseif id == "Btn_DuiHuanGD" then
    if require("Main.PlayerPK.PKMgr").IsBeWanted() then
      Toast(textRes.PlayerPK.PK[54])
      return
    end
    local heroProp = _G.GetHeroProp()
    if heroProp.level < constant.CPKConsts.ENABLE_PK_LEVEL then
      Toast(textRes.PlayerPK.PK[72]:format(constant.CPKConsts.ENABLE_PK_LEVEL))
      return
    end
    local npcCfg = require("Main.npc.NPCInterface").GetNPCCfg(constant.CPKConsts.MORAL_VALUE_NPC_ID)
    if npcCfg ~= nil then
      Toast(textRes.PlayerPK.PK[45]:format(npcCfg.npcName))
    end
    require("Main.PlayerPK.PK.ui.UIBuyMerit").Instance():ShowPanel()
  elseif id == "Btn_DuiHuanDC" then
    Event.DispatchEvent(ModuleId.HERO, gmodule.notifyId.Hero.CREDITS_SHOP, {
      TokenType.PET_FIGHT_SCORE
    })
  end
end
def.override("string", "boolean").onPress = function(self, id, state)
end
def.override().OnShow = function(self)
  self.uiObjs = {}
  self.uiObjs.Group_CreditsInfo = self.m_node:FindDirect("Group_CreditsInfo")
  self.uiObjs.Group_SocialInfo = self.m_node:FindDirect("Group_SocialInfo")
  self.uiObjs.Group_SelfInfo = self.m_node:FindDirect("Group_SelfInfo")
  self.uiObjs.Group_ChengWei = self.uiObjs.Group_SelfInfo:FindDirect("Group_ChengWei")
  self.uiObjs.Group_TouXian = self.uiObjs.Group_SelfInfo:FindDirect("Group_TouXian")
  self.uiObjs.Group_ZhuangTai = self.uiObjs.Group_SelfInfo:FindDirect("Group_ZhuangTai")
  self.uiObjs.Group_RealName = self.uiObjs.Group_SelfInfo:FindDirect("Group_RealName")
  self.uiObjs.List_Buff = self.uiObjs.Group_ZhuangTai:FindDirect("List_Buff")
  self:Fill()
  self:UpdateRealNameInfo()
  Event.RegisterEvent(ModuleId.TITLE, gmodule.notifyId.title.ActiveTitleChanged, HeroPropInfoNode.OnActiveTitleChanged)
  Event.RegisterEvent(ModuleId.TITLE, gmodule.notifyId.title.ActiveAppellationChanged, HeroPropInfoNode.OnActiveAppellationChanged)
  Event.RegisterEvent(ModuleId.BADGE, gmodule.notifyId.Badge.BadgeChanged, HeroPropInfoNode.OnBadgeChange)
  Event.RegisterEvent(ModuleId.BUFF, gmodule.notifyId.Buff.ADD_BUFF, HeroPropInfoNode.OnAddBuff)
  Event.RegisterEvent(ModuleId.BUFF, gmodule.notifyId.Buff.REMOVE_BUFF, HeroPropInfoNode.OnRemoveBuff)
  Event.RegisterEvent(ModuleId.MARRIAGE, gmodule.notifyId.Marriage.Marry, HeroPropInfoNode.OnMarriageChange)
  Event.RegisterEvent(ModuleId.SHITU, gmodule.notifyId.Shitu.ShituRelationChange, HeroPropInfoNode.OnShituChange)
end
def.override().OnHide = function(self)
  Event.UnregisterEvent(ModuleId.BADGE, gmodule.notifyId.Badge.BadgeChanged, HeroPropInfoNode.OnBadgeChange)
  Event.UnregisterEvent(ModuleId.TITLE, gmodule.notifyId.title.ActiveTitleChanged, HeroPropInfoNode.OnActiveTitleChanged)
  Event.UnregisterEvent(ModuleId.TITLE, gmodule.notifyId.title.ActiveAppellationChanged, HeroPropInfoNode.OnActiveAppellationChanged)
  Event.UnregisterEvent(ModuleId.BUFF, gmodule.notifyId.Buff.ADD_BUFF, HeroPropInfoNode.OnAddBuff)
  Event.UnregisterEvent(ModuleId.BUFF, gmodule.notifyId.Buff.REMOVE_BUFF, HeroPropInfoNode.OnRemoveBuff)
  Event.UnregisterEvent(ModuleId.MARRIAGE, gmodule.notifyId.Marriage.Marry, HeroPropInfoNode.OnMarriageChange)
  Event.UnregisterEvent(ModuleId.SHITU, gmodule.notifyId.Shitu.ShituRelationChange, HeroPropInfoNode.OnShituChange)
  self.uiObjs = nil
end
def.override("table", "table").OnSyncHeroProp = function(self, params, context)
  if require("Main.Fight.FightMgr").Instance().isInFight then
    return
  end
  self:Fill()
end
def.static("table", "table").OnActiveTitleChanged = function(p1, p2)
  local self = instance
  self:SetTitle()
end
def.static("table", "table").OnActiveAppellationChanged = function(p1, p2)
  local self = instance
  self:SetAppellation()
end
def.static("table", "table").OnBadgeChange = function(p1, p2)
  local self = instance
  self:SetBadge()
end
def.static("table", "table").OnMarriageChange = function()
  local self = instance
  self:SetMarriageInfo()
end
def.static("table", "table").OnShituChange = function()
  local self = instance
  self:SetShituInfo()
end
def.method().Fill = function(self)
  if self.uiObjs == nil then
    return
  end
  local prop = Lplus.ForwardDeclare("HeroModule").Instance():GetHeroProp()
  self:SetAppellation()
  self:SetTitle()
  self:SetBadge()
  self:SetOccupation(prop.occupation)
  self:SetMarriageInfo()
  self:SetShituInfo()
  self:UpdateBuffs()
  self:UpdateGangName()
  self:UpdateCredits()
  self:UpdateGangAidTimes()
  self:UpdateReceivedFlowers()
end
def.method().SetAppellation = function(self)
  local appellation = textRes.Common[1]
  local appellationID = titleInterface:GetActiveAppellation()
  local cfg
  if appellationID ~= 0 then
    cfg = TitleInterface.GetAppellationCfg(appellationID)
  end
  if cfg ~= nil then
    appellation = cfg.appellationName
    local appArgs = titleInterface:GetAppellationArgs(appellationID)
    if appArgs ~= nil then
      appellation = string.format(cfg.appellationName, unpack(appArgs))
    end
  end
  local Group_ChengWei = self.uiObjs.Group_ChengWei
  GUIUtils.SetText(GUIUtils.FindDirect(Group_ChengWei, "Img_BgTitle/Label_Title"), appellation)
  local hasNew = HeroPropMgr.Instance():HasNewAppellation()
  GUIUtils.SetActive(GUIUtils.FindDirect(Group_ChengWei, "Btn_ModifyCW/Img_Red"), hasNew)
end
def.method().SetTitle = function(self)
  local titleName = textRes.Common[1]
  local titleID = titleInterface:GetActiveTitle()
  local cfg = TitleInterface.GetTitleCfg(titleID)
  if cfg ~= nil then
    titleName = cfg.titleName
  end
  local Group_TouXian = self.uiObjs.Group_TouXian
  GUIUtils.SetText(GUIUtils.FindDirect(Group_TouXian, "Img_BgTitle/Label_Title"), titleName)
  local hasNew = HeroPropMgr.Instance():HasNewTitle()
  GUIUtils.SetActive(GUIUtils.FindDirect(Group_TouXian, "Btn_ModifyTX/Img_Red"), hasNew)
end
def.method("number").SetOccupation = function(self, occupation)
  local label_occupation = self.m_node:FindDirect("Group_SelfInfo/Group_MenPai/Img_BgTitle/Label_Title"):GetComponent("UILabel")
  label_occupation.text = GetOccupationName(occupation)
end
def.method().UpdateGangName = function(self)
  local gangName = textRes.Common[1]
  if GangModule.Instance():HasGang() then
    gangName = GangData.Instance():GetGangBasicInfo().name
  end
  self:SetGangName(gangName)
end
def.method("string").SetGangName = function(self, gangName)
  local label_gangName = self.m_node:FindDirect("Group_SelfInfo/Group_Gang/Img_BgTitle/Label_Title"):GetComponent("UILabel")
  label_gangName.text = gangName
end
def.method().SetMarriageInfo = function(self)
  local MarriageInterface = require("Main.Marriage.MarriageInterface")
  local mateInfo = MarriageInterface.GetMateInfo()
  local mateLabel = self.m_node:FindDirect("Group_CreditsInfo/Group_FuQi/Img_Name/Label_Name")
  if mateInfo ~= nil then
    local mateName = mateInfo.mateName
    mateLabel:GetComponent("UILabel"):set_text(mateName)
  else
    mateLabel:GetComponent("UILabel"):set_text(textRes.Marriage[35])
  end
end
def.method().SetShituInfo = function(self)
  local shituData = require("Main.Shitu.ShituData").Instance()
  local hasMaster = shituData:HasMaster()
  local nowApprenticeCount = shituData:GetNowApprenticeCount()
  local shituLabel = self.m_node:FindDirect("Group_CreditsInfo/Group_Shitu/Img_Name/Label_Name"):GetComponent("UILabel")
  if nowApprenticeCount > 0 then
    shituLabel:set_text(string.format(textRes.Shitu[1], nowApprenticeCount, constant.ShiTuConsts.maxApprenticeNum))
  elseif hasMaster then
    local master = shituData:GetMaster()
    shituLabel:set_text(string.format(textRes.Shitu[2], master.roleName))
  else
    shituLabel:set_text(textRes.Shitu[3])
  end
  local hasNotify = HeroPropMgr.Instance():HasShituNotify()
  GUIUtils.SetActive(GUIUtils.FindDirect(self.m_node, "Group_CreditsInfo/Group_Shitu/Btn_Shitu/Img_Red"), hasNotify)
end
def.method().SetBadge = function(self)
  local BadgeModule = require("Main.Badge.BadgeModule")
  local badges = BadgeModule.Instance():GetMyBadges()
  local badgeGroup = self.m_node:FindDirect("Group_Badge")
  local hasGroup = badgeGroup:FindDirect("Group_Badge")
  local notHasGroup = badgeGroup:FindDirect("Group_None")
  if next(badges) then
    while hasGroup:get_childCount() > 1 do
      Object.DestroyImmediate(hasGroup:GetChild(hasGroup:get_childCount() - 1))
    end
    hasGroup:SetActive(true)
    notHasGroup:SetActive(false)
    local template = hasGroup:FindDirect("Img_Badge")
    template:SetActive(false)
    for k, v in ipairs(badges) do
      local newBadge = Object.Instantiate(template)
      newBadge:set_name(string.format("badge_%d", v.badgeId))
      newBadge.parent = hasGroup
      newBadge:set_localScale(EC.Vector3.one)
      newBadge:SetActive(true)
      local badgeCfg = BadgeModule.Instance():GetBadgeInfo(v.badgeId)
      local sprite = newBadge:GetComponent("UISprite")
      sprite:set_spriteName(badgeCfg.spriteName)
      self.m_base.m_msgHandler:Touch(newBadge)
    end
    hasGroup:GetComponent("UITable"):Reposition()
  else
    hasGroup:SetActive(false)
    notHasGroup:SetActive(true)
  end
end
def.method().UpdateCredits = function(self)
  local value = ItemModule.Instance():GetCredits(TokenType.JINGJICHANG_JIFEN) or Int64.new(0)
  self:SetJingJiValue(value)
  local value = ItemModule.Instance():GetCredits(TokenType.XIAYI_VALUE) or Int64.new(0)
  self:SetXiaYiValue(value)
  local value = ItemModule.Instance():GetCredits(TokenType.REPUTATION_VALUE) or Int64.new(0)
  self:SetShengWangValue(value)
  local value = ItemModule.Instance():GetCredits(TokenType.LADDER_SCORE) or Int64.new(0)
  self:SetLadderValue(value)
  local value = ItemModule.Instance():GetCredits(TokenType.MORAL_VALUE) or Int64.new(0)
  self:SetMeritValue(value)
  local value = ItemModule.Instance():GetCredits(TokenType.SINGLE_CROSS_FIELD_SCORE) or Int64.new(0)
  self:SetSingleBattleValue(value)
  local value = ItemModule.Instance():GetCredits(TokenType.PET_FIGHT_SCORE) or Int64.new(0)
  self:SetPetArenaValue(value)
end
def.method("userdata").SetJingJiValue = function(self, value)
  local label = self.uiObjs.Group_CreditsInfo:FindDirect("Group_ShiGong/Img_Num/Label_Num")
  GUIUtils.SetText(label, tostring(value))
end
def.method("userdata").SetXiaYiValue = function(self, value)
  local label = self.uiObjs.Group_CreditsInfo:FindDirect("Group_XiaYiZhi/Img_Num/Label_Num")
  GUIUtils.SetText(label, tostring(value))
end
def.method("userdata").SetShengWangValue = function(self, value)
  local label = self.uiObjs.Group_CreditsInfo:FindDirect("Group_ShengWang/Img_Num/Label_Num")
  GUIUtils.SetText(label, tostring(value))
end
def.method("userdata").SetLadderValue = function(self, value)
  if not IsFeatureOpen(require("netio.protocol.mzm.gsp.open.ModuleFunSwitchInfo").TYPE_LADDER) then
    self.uiObjs.Group_CreditsInfo:FindDirect("Group_ZhanGong"):SetActive(false)
  else
    self.uiObjs.Group_CreditsInfo:FindDirect("Group_ZhanGong"):SetActive(true)
    local label = self.uiObjs.Group_CreditsInfo:FindDirect("Group_ZhanGong/Img_Num/Label_Num")
    GUIUtils.SetText(label, tostring(value))
  end
end
def.method("userdata").SetMeritValue = function(self, value)
  local ctrlRoot = self.uiObjs.Group_CreditsInfo:FindDirect("Group_GongDe")
  if not IsFeatureOpen(require("netio.protocol.mzm.gsp.open.ModuleFunSwitchInfo").TYPE_PK) then
    ctrlRoot:SetActive(false)
  else
    ctrlRoot:SetActive(true)
    local lblNum = ctrlRoot:FindDirect("Img_Num/Label_Num")
    GUIUtils.SetText(lblNum, tostring(value))
  end
end
def.method("userdata").SetSingleBattleValue = function(self, value)
  local ctrlRoot = self.uiObjs.Group_CreditsInfo:FindDirect("Group_ZhanChang")
  if not IsFeatureOpen(require("netio.protocol.mzm.gsp.open.ModuleFunSwitchInfo").TYPE_CROSS_FIELD) then
    ctrlRoot:SetActive(false)
  else
    ctrlRoot:SetActive(true)
    local lblNum = ctrlRoot:FindDirect("Img_Num/Label_Num")
    GUIUtils.SetText(lblNum, tostring(value))
  end
end
def.method("userdata").SetPetArenaValue = function(self, value)
  local ctrlRoot = self.uiObjs.Group_CreditsInfo:FindDirect("Group_DouChong")
  if not IsFeatureOpen(require("netio.protocol.mzm.gsp.open.ModuleFunSwitchInfo").TYPE_PET_ARENA) then
    ctrlRoot:SetActive(false)
  else
    ctrlRoot:SetActive(true)
    local lblNum = ctrlRoot:FindDirect("Img_Num/Label_Num")
    GUIUtils.SetText(lblNum, tostring(value))
  end
end
def.method().OnGotoGangMapButtonClicked = function(self)
  if GangModule.Instance():HasGang() then
    GangModule.Instance():GotoGangMap()
    self.m_base:DestroyPanel()
  else
    Toast(textRes.Hero[34])
  end
end
def.method().OnGotoOccupationMapButtonClicked = function(self)
  require("Main.Map.MapModule").Instance():GotoMenPaiMap()
  self.m_base:DestroyPanel()
end
def.method().OnMarriageSkillButtonClicked = function(self)
  require("Main.Marriage.MarriageInterface").ShowCoupleSkill()
end
def.method().OnShituInfoButtonClicked = function(self)
  require("Main.Shitu.ShituModule").Instance():ShowShituRelation()
end
def.method().UpdateGangAidTimes = function(self)
  local num = ""
  local Label_Num = self.uiObjs.Group_SocialInfo:FindDirect("Group_GangHelp/Img_Num/Label_Num")
  GUIUtils.SetText(Label_Num, num)
end
def.method().UpdateReceivedFlowers = function(self)
  local num = ""
  local Label_Num = self.uiObjs.Group_SocialInfo:FindDirect("Group_Flower/Img_Num/Label_Num")
  GUIUtils.SetText(Label_Num, num)
end
def.method().UpdateRealNameInfo = function(self)
  self.uiObjs.Group_RealName:SetActive(false)
  local RealNameAuthMgr = require("Main.RealNameAuth.RealNameAuthMgr")
  if not RealNameAuthMgr.Instance():IsEnabled() then
    print("RealNameAuth not enabled")
    return
  end
  RealNameAuthMgr.Instance():CheckAuthStatus(function(authStatus)
    if self.uiObjs == nil then
      return
    end
    if _G.IsNil(self.uiObjs.Group_RealName) then
      return
    end
    self.uiObjs.Group_RealName:SetActive(true)
    local Label_RealName = self.uiObjs.Group_RealName:FindDirect("Label_RealName")
    local statusText
    if authStatus == true then
      statusText = textRes.Common[1103]
    elseif authStatus == false then
      statusText = textRes.Common[1104]
    else
      statusText = textRes.Common[1105]
    end
    GUIUtils.SetText(Label_RealName, statusText)
  end)
end
def.method().UpdateBuffs = function(self)
  local BuffMgr = require("Main.Buff.BuffMgr")
  local buffList = BuffMgr.Instance():GetBuffList()
  self:SetBuffList(buffList)
end
local MAX_BUFF_AMOUNT = 4
def.method("table").SetBuffList = function(self, buffList)
  local uiList = self.uiObjs.List_Buff:GetComponent("UIList")
  local buffAmount = #buffList
  local minValue = math.min(MAX_BUFF_AMOUNT, buffAmount)
  uiList.itemCount = minValue
  uiList:Resize()
  for i = 1, minValue do
    local buff = buffList[i]
    self:SetBuffInfo(i, buff)
  end
  GameUtil.AddGlobalLateTimer(0, true, function()
    if uiList and not uiList.isnil then
      uiList:Reposition()
    end
  end)
end
def.method("number", "table").SetBuffInfo = function(self, index, buff)
  local ui_Img_Buff = self.uiObjs.List_Buff:FindDirect("Img_Buff_" .. index)
  local uiTexture = ui_Img_Buff:GetComponent("UITexture")
  local icon = buff:GetIcon()
  require("GUI.GUIUtils").FillIcon(uiTexture, icon)
end
def.static("table", "table").OnAddBuff = function(params)
  instance:UpdateBuffs()
end
def.static("table", "table").OnRemoveBuff = function()
  instance:UpdateBuffs()
end
def.override("=>", "boolean").HasNotify = function(self)
  local mgr = HeroPropMgr.Instance()
  if mgr:HasNewAppellation() then
    return true
  end
  if mgr:HasNewTitle() then
    return true
  end
  local shituUIMgr = require("Main.Shitu.ShituUIMgr").Instance()
  if shituUIMgr:HasNotify() then
    return true
  end
  return false
end
def.static("table", "table").OnAvatarChange = function(p1, p2)
  if not instance or not instance.m_node or not instance.m_node.isnil then
  end
end
def.method().SetHeadInfo = function(self)
end
return HeroPropInfoNode.Commit()
