local Lplus = require("Lplus")
local ECGUIMan = require("GUI.ECGUIMan")
local GUIUtils = require("GUI.GUIUtils")
local GUIFxMan = require("Fx.GUIFxMan")
local ItemUtils = require("Main.Item.ItemUtils")
local ItemTipsMgr = require("Main.Item.ItemTipsMgr")
local SkillUtils = require("Main.Skill.SkillUtility")
local PartnerMain = Lplus.ForwardDeclare("PartnerMain")
local PartnerMain_God2 = Lplus.Class("PartnerMain_God2")
local PartnerInterface = require("Main.partner.PartnerInterface")
local partnerInterface = PartnerInterface.Instance()
local PartnerYuanShenMgr = require("Main.partner.PartnerYuanShenMgr")
local PubroleInterface = require("Main.Pubrole.PubroleInterface")
local PropertyType = require("consts.mzm.gsp.common.confbean.PropertyType")
local ItemModule = Lplus.ForwardDeclare("ItemModule")
local ItemPriceHelper = require("Main.Item.ItemPriceHelper")
local MAX_ATTR_NUM = 10
local MAX_LINE_NUM = 9
local UPGRADE_MULTI_TIMES = 10
local def = PartnerMain_God2.define
local instance
def.field(PartnerMain)._partnerMain = nil
def.field(PartnerYuanShenMgr)._yuanShenMgr = nil
def.field("boolean")._isShow = false
def.field("table")._UIGOs = nil
def.field("table")._partners = nil
def.field("number")._selPosition = 0
def.field("number")._selPartnerId = 0
def.field("number")._toggleGroup = 0
def.field("boolean")._autoBuy = false
def.field("boolean")._autoBuyOpen = false
def.field("table")._costItem = nil
def.field("boolean")._upgrading = false
def.const("number").DEFAULT_POSITION = 1
def.static(PartnerMain, "=>", PartnerMain_God2).New = function(panel)
  if instance == nil then
    instance = PartnerMain_God2()
    instance._partnerMain = panel
    instance:Init()
  end
  return instance
end
def.static("=>", PartnerMain_God2).Instance = function()
  return instance
end
def.method().Init = function(self)
end
def.method().OnCreate = function(self)
  self._yuanShenMgr = PartnerYuanShenMgr.Instance()
  self._costItem = {
    itemIds = {}
  }
  self:InitPosition()
  self:InitToggleGroup()
  Event.RegisterEventWithContext(ModuleId.ITEM, gmodule.notifyId.item.Item_OnBagInfoSynchronized, PartnerMain_God2.OnBagInfoSynchronized, self)
  Event.RegisterEventWithContext(ModuleId.PARTNER, gmodule.notifyId.partner.YuanShenPartnerChange, PartnerMain_God2.OnYuanShenPartnerChange, self)
  Event.RegisterEventWithContext(ModuleId.PARTNER, gmodule.notifyId.partner.YuanShenUpgradeSuccess, PartnerMain_God2.OnYuanShenUpgradeSuccess, self)
  Event.RegisterEventWithContext(ModuleId.PARTNER, gmodule.notifyId.partner.YuanShenUpgradeFail, PartnerMain_God2.OnYuanShenUpgradeFail, self)
  Event.RegisterEventWithContext(ModuleId.PARTNER, gmodule.notifyId.partner.Partner_NotifyChange, PartnerMain_God2.OnPartnerNotifyChange, self)
  self:UpdateTabRedMark()
end
def.method().OnDestroy = function(self)
  self._UIGOs = nil
  self._yuanShenMgr = nil
  self._costItem = nil
  self._autoBuy = false
  self._upgrading = false
  Event.UnregisterEvent(ModuleId.ITEM, gmodule.notifyId.item.Item_OnBagInfoSynchronized, PartnerMain_God2.OnBagInfoSynchronized)
  Event.UnregisterEvent(ModuleId.PARTNER, gmodule.notifyId.partner.YuanShenPartnerChange, PartnerMain_God2.OnYuanShenPartnerChange)
  Event.UnregisterEvent(ModuleId.PARTNER, gmodule.notifyId.partner.YuanShenUpgradeSuccess, PartnerMain_God2.OnYuanShenUpgradeSuccess)
  Event.UnregisterEvent(ModuleId.PARTNER, gmodule.notifyId.partner.YuanShenUpgradeFail, PartnerMain_God2.OnYuanShenUpgradeFail)
  Event.UnregisterEvent(ModuleId.PARTNER, gmodule.notifyId.partner.Partner_NotifyChange, PartnerMain_God2.OnPartnerNotifyChange)
end
def.method("=>", "boolean").IsShow = function(self)
  if self._partnerMain == nil or self._partnerMain:IsLoaded() == false or self._partnerMain:IsShow() == false then
    return false
  end
  local Group_YuanShen = self._partnerMain.m_panel:FindDirect("Img_Bg0/Group_YuanShen")
  local ret = Group_YuanShen:get_activeInHierarchy() == true
  return ret
end
def.method("boolean").OnShow = function(self, b)
  self._isShow = b
  if b == false then
    self:OnHide()
    return
  end
  self._yuanShenMgr:MarkYuanShenOpenAsKnow()
  self:InitUI()
  self:UpdateUI()
end
def.method().OnHide = function(self)
  self._UIGOs = nil
end
def.method().InitUI = function(self)
  if self._UIGOs then
    return
  end
  self._UIGOs = {}
  self._UIGOs.Group_YuanShen = self._partnerMain.m_panel:FindDirect("Img_Bg0/Group_YuanShen")
  self._UIGOs.Group_ShowPartner = self._UIGOs.Group_YuanShen:FindDirect("Group_ShowPartner")
  self._UIGOs.Group_JiTan = self._UIGOs.Group_YuanShen:FindDirect("Group_JiTan")
  self._UIGOs.Group_YS = self._UIGOs.Group_YuanShen:FindDirect("Group_YS")
  self._UIGOs.Group_Effect = self._UIGOs.Group_YuanShen:FindDirect("Group_Effect")
  if self._UIGOs.Group_Effect then
    self._UIGOs.Effect_TuoWeiLiZi = self._UIGOs.Group_Effect:FindDirect("UI_TuoWeiLiZi")
    self._UIGOs.Effect_Upgrade = self._UIGOs.Group_Effect:FindDirect("UI_Panel_CrossServerBattle_RankResult_DuanWeiBianHua")
    self._UIGOs.Effect_CanUpgrade = self._UIGOs.Group_Effect:FindDirect("UI_Panel_FaBaoNew_XiaoJianTou")
    self._UIGOs.UI_Particle_TuoWeiLiZi = self._UIGOs.Group_Effect:FindDirect("UI_Particle_TuoWeiLiZi")
    self._UIGOs.UI_Particle_CanUpgrade = self._UIGOs.Group_Effect:FindDirect("UI_Particle_FaBaoNew_XiaoJianTou")
  end
  self._UIGOs.Group_Fight = self._UIGOs.Group_JiTan:FindDirect("Group_Fight")
  GUIUtils.SetActive(self._UIGOs.Effect_TuoWeiLiZi, false)
  GUIUtils.SetActive(self._UIGOs.Effect_Upgrade, false)
  GUIUtils.SetActive(self._UIGOs.Effect_CanUpgrade, false)
  GUIUtils.SetActive(self._UIGOs.UI_Particle_TuoWeiLiZi, false)
  GUIUtils.SetActive(self._UIGOs.UI_Particle_CanUpgrade, false)
  GUIUtils.SetActive(self._UIGOs.Group_Effect, true)
  self._UIGOs.Group_Right = self._UIGOs.Group_YS:FindDirect("Group_Right")
  self._UIGOs.Btn_Upgrade = self._UIGOs.Group_Right:FindDirect("Btn_Upgrade")
  self._UIGOs.Btn_UpgradeMulti = self._UIGOs.Group_Right:FindDirect("Btn_Upgrade10")
  local uiButton = self._UIGOs.Btn_Upgrade:GetComponent("UIButton")
  local uiButton10 = self._UIGOs.Btn_UpgradeMulti:GetComponent("UIButton")
  self._UIGOs.YuanShenUIs = {}
  self._UIGOs.YuanShenUIs.Img_TianShuBg1TS = {position = 1}
  self._UIGOs.YuanShenUIs.Img_TianShuBg2TX = {position = 2}
  self._UIGOs.YuanShenUIs.Img_TianShuBg3KY = {position = 3}
  self._UIGOs.YuanShenUIs.Img_TianShuBg4TJ = {position = 4}
  self._UIGOs.YuanShenUIs.Img_TianShuBg5YH = {position = 5}
  self._UIGOs.YuanShenUIs.Img_TianShuBg6TQ = {position = 6}
  self._UIGOs.PropertyLabels = {}
  self._UIGOs.PropertyLabels[PropertyType.MAG_CRT_VALUE] = "Label_FB"
  self._UIGOs.PropertyLabels[PropertyType.MAGDEF] = "Label_FF"
  self._UIGOs.PropertyLabels[PropertyType.MAGATK] = "Label_FG"
  self._UIGOs.PropertyLabels[PropertyType.SEAL_RESIST] = "Label_FK"
  self._UIGOs.PropertyLabels[PropertyType.MAX_MP] = "Label_FL"
  self._UIGOs.PropertyLabels[PropertyType.MAX_HP] = "Label_QX"
  self._UIGOs.PropertyLabels[PropertyType.SPEED] = "Label_SD"
  self._UIGOs.PropertyLabels[PropertyType.PHY_CRT_VALUE] = "Label_WB"
  self._UIGOs.PropertyLabels[PropertyType.PHYDEF] = "Label_WF"
  self._UIGOs.PropertyLabels[PropertyType.PHYATK] = "Label_WG"
  self._UIGOs.PropertyLabels[PropertyType.PHY_CRIT_LEVEL] = "Label_WB"
  self._UIGOs.PropertyLabels[PropertyType.MAG_CRT_LEVEL] = "Label_FB"
  self:SwitchToYuanShenUI()
end
def.method().InitPosition = function(self)
  self._selPosition = PartnerMain_God2.DEFAULT_POSITION
end
def.method().InitToggleGroup = function(self)
  self._toggleGroup = os.time()
end
def.method("string", "=>", "boolean").onClick = function(self, id)
  local fnTable = {}
  fnTable.Btn_AddPartner = PartnerMain_God2.OnClickAddPartnerBtn
  fnTable.Btn_Confirm = PartnerMain_God2.OnClickConfirmBtn
  fnTable.Btn_Upgrade = PartnerMain_God2.OnClickUpgradeBtn
  fnTable.Btn_Upgrade10 = PartnerMain_God2.OnClickUpgradeMultiBtn
  fnTable.Btn_YuanbaoUse = PartnerMain_God2.OnClickYuanbaoUseBtn
  fnTable.Img_ItemGet = PartnerMain_God2.OnClickImg_ItemGet
  local fn = fnTable[id]
  if fn ~= nil then
    fn(self)
    return true
  end
  if id:find("Img_BgPartner_") then
    local index = tonumber(id:split("_")[3])
    if index then
      self:OnClickPartnerImgBg(index)
    end
    return true
  elseif self._UIGOs.YuanShenUIs[id] then
    local position = self._UIGOs.YuanShenUIs[id].position
    self:SelectYuanShenPosition(position)
    return true
  elseif id:find("^Att%d%d$") then
    local index = tonumber(id:sub(4, -1))
    if index then
      self:OnClickAttrWidget(index, id)
    end
    return true
  end
  return false
end
def.method().UpdateUI = function(self)
  self:UpdateYuanShens()
  self:SelectYuanShenPosition(self._selPosition)
  self:UpdateAutoBuyBtnState()
  self:EnableUpgrade(true)
end
def.method().OnClickAddPartnerBtn = function(self)
  self:ShowSelectedPositionPartnerList()
end
def.method().OnClickConfirmBtn = function(self)
  self:SwitchToYuanShenUI()
  local posInfo = self._yuanShenMgr:GetYuanShenPosInfo(self._selPosition)
  if self._selPartnerId ~= 0 then
    if posInfo.partnerId ~= self._selPartnerId then
      self._yuanShenMgr:SetYuanShenPartner(self._selPosition, self._selPartnerId)
    end
  elseif posInfo.partnerId ~= 0 then
    self._yuanShenMgr:UnsetYuanShenPartner(self._selPosition)
  end
  self:ShowSelectedPositionProperties()
end
def.method().OnClickUpgradeBtn = function(self)
  if self._costItem == nil then
    return
  end
  if not self._costItem.upgrade then
    Toast(textRes.Partner.YuanShen[8])
    return
  end
  if self._upgrading then
    print("self._upgrading == true")
    Toast(textRes.Partner.YuanShen[9])
    return
  end
  local itemEnough = self._costItem.haveNum >= self._costItem.needNum
  if itemEnough then
    self._yuanShenMgr:UpgradeYuanShenWithItem(self._selPosition, 1)
    self:EnableUpgrade(false)
  elseif self._autoBuy then
    if self._costItem.itemYuanBao == nil then
      print("no yuanbao price for itemId = " .. self._costItem.displayItemId)
      return
    end
    local buyNum = self._costItem.needNum - self._costItem.haveNum
    local costYuanBao = Int64.new(self._costItem.itemYuanBao) * buyNum
    local haveYuanBao = ItemModule.Instance():GetAllYuanBao()
    if costYuanBao <= haveYuanBao then
      self._yuanShenMgr:UpgradeYuanShenWithYuanBao(self._selPosition, 1)
      self:EnableUpgrade(false)
    else
      Toast(textRes.Partner.YuanShen[2])
    end
  elseif self._autoBuyOpen then
    local CommonConfirmDlg = require("GUI.CommonConfirmDlg")
    CommonConfirmDlg.ShowConfirm("", textRes.Partner.YuanShen[1], function(s)
      if s == 1 then
        if self._UIGOs == nil then
          return
        end
        self:SetAutoBuy(true)
      end
    end, nil)
  else
    Toast(textRes.Partner.YuanShen[12])
    self:ShowNeededItemTips()
  end
end
def.method().OnClickUpgradeMultiBtn = function(self)
  if self._costItem == nil then
    return
  end
  if not self._costItem.upgrade then
    Toast(textRes.Partner.YuanShen[8])
    return
  end
  if self._upgrading then
    print("self._upgrading == true")
    Toast(textRes.Partner.YuanShen[9])
    return
  end
  local itemEnough = self._costItem.haveNum >= self._costItem.mulityNeedNum
  if itemEnough then
    self._yuanShenMgr:UpgradeYuanShenWithItem(self._selPosition, self._costItem.mulityTimes)
    self:EnableUpgrade(false)
  elseif self._autoBuy then
    if self._costItem.itemYuanBao == nil then
      print("no yuanbao price for itemId = " .. self._costItem.displayItemId)
      return
    end
    local buyNum = self._costItem.mulityNeedNum - self._costItem.haveNum
    local costYuanBao = Int64.new(self._costItem.itemYuanBao) * buyNum
    local haveYuanBao = ItemModule.Instance():GetAllYuanBao()
    if costYuanBao <= haveYuanBao then
      self._yuanShenMgr:UpgradeYuanShenWithYuanBao(self._selPosition, self._costItem.mulityTimes)
      self:EnableUpgrade(false)
    else
      _G.GotoBuyYuanbao()
    end
  elseif self._autoBuyOpen then
    local CommonConfirmDlg = require("GUI.CommonConfirmDlg")
    CommonConfirmDlg.ShowConfirm("", textRes.Partner.YuanShen[1], function(s)
      if s == 1 then
        if self._UIGOs == nil then
          return
        end
        self:SetAutoBuy(true)
      end
    end, nil)
  else
    Toast(textRes.Partner.YuanShen[12])
    self:ShowNeededItemTips()
  end
end
def.method().OnClickYuanbaoUseBtn = function(self)
  local Btn_YuanbaoUse = self._UIGOs.Group_YS:FindDirect("Group_Right/Btn_YuanbaoUse")
  local uiToggle = Btn_YuanbaoUse:GetComponent("UIToggle")
  local isSelected = uiToggle.value
  if isSelected then
    uiToggle.value = false
    local CommonConfirmDlg = require("GUI.CommonConfirmDlg")
    CommonConfirmDlg.ShowConfirm("", textRes.Partner.YuanShen[3], function(s)
      if s == 1 then
        if uiToggle == nil or uiToggle.isnil then
          return
        end
        self:SetAutoBuy(true)
      end
    end, nil)
  else
    self:SetAutoBuy(false)
  end
end
def.method().OnClickImg_ItemGet = function(self)
  self:ShowNeededItemTips()
end
def.method().ShowNeededItemTips = function(self)
  if self._costItem == nil then
    return
  end
  local itemId = self._costItem.displayItemId
  if itemId == nil then
    return
  end
  local go = self._UIGOs.Group_YS:FindDirect("Group_Right/Img_ItemGet")
  ItemTipsMgr.Instance():ShowBasicTipsWithGO(itemId, go, 0, true)
end
def.method("number", "string").OnClickAttrWidget = function(self, index, id)
  if self._UIGOs.properties == nil then
    return nil
  end
  local property = self._UIGOs.properties[index]
  if property == nil then
    return
  end
  local propertyCfg = _G.GetCommonPropNameCfg(property.type)
  local propertyName = propertyCfg and propertyCfg.propName or "property_" .. property.type
  local integralPart, fractionalPart = math.modf(property.ratio)
  local fractionalPartLen = #tostring(fractionalPart)
  local ratioStr
  if fractionalPartLen == 1 then
    ratioStr = string.format("%s", integralPart)
  elseif fractionalPartLen == 3 then
    ratioStr = string.format("%.1f", property.ratio)
  else
    ratioStr = string.format("%.2f", property.ratio)
  end
  local effectText = string.format("%s +%s%%", propertyName, ratioStr)
  local sourceObj = self._UIGOs.Group_YS:FindDirect(string.format("Group_Right/Group_Att/%s", id))
  local position = sourceObj:get_position()
  local screenPos = WorldPosToScreen(position.x, position.y)
  local widget = sourceObj:GetComponent("UIWidget")
  local CommonUISmallTip = require("GUI.CommonUISmallTip")
  CommonUISmallTip.Instance():ShowTip(effectText, screenPos.x, screenPos.y, widget:get_width(), widget:get_height(), 0)
end
def.method("boolean").SetAutoBuy = function(self, isAutoBuy)
  self._autoBuy = isAutoBuy
  self:UpdateAutoBuyBtnState()
end
def.method().UpdateAutoBuyBtnState = function(self)
  local Btn_YuanbaoUse = self._UIGOs.Group_YS:FindDirect("Group_Right/Btn_YuanbaoUse")
  GUIUtils.Toggle(Btn_YuanbaoUse, self._autoBuy)
  if self._costItem then
    if self._costItem.itemYuanBao then
      self:SetYuanShenUpgardeNeed()
      return
    end
    do
      local itemId = self._costItem.displayItemId
      ItemPriceHelper.GetItemsYuanbaoPriceAsync({itemId}, function(itemId2YuanBao)
        if self._costItem == nil then
          return
        end
        if not self:IsShow() then
          return
        end
        if self._UIGOs.Group_ShowPartner.activeSelf then
          return
        end
        self._costItem.itemYuanBao = itemId2YuanBao[itemId]
        self:SetYuanShenUpgardeNeed()
      end)
    end
  end
end
def.method("number").OnClickPartnerImgBg = function(self, index)
  if self._partners == nil then
    return
  end
  local partner = self._partners[index]
  if partner.position ~= 0 and partner.position ~= self._selPosition then
    local positionCfg = PartnerInterface.GetPartnerYuanShenPositionCfg(partner.position)
    local positionName = positionCfg and positionCfg.name
    local text = textRes.Partner.YuanShen[7]:format(positionName)
    Toast(text)
    return
  end
  local partnerId = partner.id or 0
  if partnerId ~= self._selPartnerId then
    self._selPartnerId = partnerId
    self:SelectPartnerListItem(index)
  else
    self._selPartnerId = 0
    self:SelectPartnerListItem(0)
  end
end
def.method().SwitchToPartnerUI = function(self)
  GUIUtils.SetActive(self._UIGOs.Group_ShowPartner, true)
  GUIUtils.SetActive(self._UIGOs.Group_YS, false)
  GUIUtils.SetActive(self._UIGOs.UI_Particle_CanUpgrade, false)
end
def.method().SwitchToYuanShenUI = function(self)
  GUIUtils.SetActive(self._UIGOs.Group_ShowPartner, false)
  GUIUtils.SetActive(self._UIGOs.Group_YS, true)
end
def.method().ShowSelectedPositionPartnerList = function(self)
  self:SwitchToPartnerUI()
  local partners = self._yuanShenMgr:GetYuanShenPartners()
  local selectedPosition = self._selPosition
  local selectedPartnerIndex = 0
  for i, v in ipairs(partners) do
    local position = self._yuanShenMgr:GetYuanShenByPartnerId(v.id)
    v.oi = i
    v.position = position
    v.isJoinedBattle = PartnerInterface.Instance():IsPartnerJoinedBattle(v.id)
    if position == selectedPosition then
      v.selected = true
      selectedPartnerIndex = 1
    end
  end
  table.sort(partners, function(l, r)
    local lpos = l.position
    local rpos = r.position
    if lpos == selectedPosition then
      return true
    elseif rpos == selectedPosition then
      return false
    elseif lpos == 0 and rpos == 0 or lpos ~= 0 and rpos ~= 0 then
      if l.isJoinedBattle and not r.isJoinedBattle then
        return true
      elseif not l.isJoinedBattle and r.isJoinedBattle then
        return false
      else
        return l.oi < r.oi
      end
    else
      return lpos < rpos
    end
  end)
  self._selPartnerId = 0
  if selectedPartnerIndex ~= 0 then
    local partner = partners[selectedPartnerIndex]
    self._selPartnerId = partner and partner.id or 0
  end
  self:SetPartnerList(partners)
  self:SelectPartnerListItem(selectedPartnerIndex)
end
def.method("table").SetPartnerList = function(self, partners)
  local ScrollView = self._UIGOs.Group_ShowPartner:FindDirect("Scroll View")
  local Grid = ScrollView:FindDirect("Grid")
  local count = #partners
  GUIUtils.ResizeGrid(Grid, count, "Img_BgPartner_")
  self._partners = partners
  for i, partner in ipairs(partners) do
    local itemGO = Grid:GetChild(i)
    self:InitParterListItem(itemGO)
  end
  for i, partner in ipairs(partners) do
    local itemGO = Grid:GetChild(i)
    self:SetPartnerListItemInfo(itemGO, partner)
  end
end
def.method("userdata").InitParterListItem = function(self, itemGO)
  local Group_Have = itemGO:FindDirect("Group_Have")
  local Img_Toggle = Group_Have:FindDirect("Img_Toggle")
  local boxCollider = Img_Toggle:GetComponent("BoxCollider")
  boxCollider.enabled = false
  local uiToggle = Img_Toggle:GetComponent("UIToggle")
  if uiToggle then
  end
end
def.method("userdata", "table").SetPartnerListItemInfo = function(self, itemGO, partner)
  local Label_Name = itemGO:FindDirect("Label_Name")
  local Img_School = itemGO:FindDirect("Img_School")
  local Img_BgHead = itemGO:FindDirect("Img_BgHead")
  local Tex_Head = Img_BgHead:FindDirect("Txt_Head")
  local Img_FightMark = Img_BgHead:FindDirect("Img_FightMark")
  local Img_unusual = Img_BgHead:FindDirect("Img_unusual")
  local Label_FightLevel = itemGO:FindDirect("Label_FightLevel")
  local Group_Have = itemGO:FindDirect("Group_Have")
  local Img_Toggle = Group_Have:FindDirect("Img_Toggle")
  local Img_Grey = itemGO:FindDirect("Img_Grey")
  local Label = itemGO:FindDirect("Label")
  local occupationSpriteName = GUIUtils.GetOccupationSmallIcon(partner.faction)
  local modelCfg = PubroleInterface.GetModelCfg(partner.modelId)
  local headIconId = modelCfg and modelCfg.headerIconId or 0
  local rankInfoId = partnerInterface:getPartnerInfoCfgId(partner.id)
  local rankLvStr, rankQualitySprite
  if rankInfoId > 0 then
    local rankInfoCfg = PartnerInterface.GetRankInfoCfg(rankInfoId)
    local rankEnum = rankInfoCfg.rankEnum
    local color = rankInfoCfg.color
    rankLvStr = partnerInterface:getRankLevelStr(rankEnum) or partner.rank
    rankQualitySprite = string.format("Cell_%02d", color)
  else
    rankLvStr = partner.rank
    rankQualitySprite = "Cell_00"
  end
  GUIUtils.SetText(Label_Name, partner.name)
  GUIUtils.SetSprite(Img_School, occupationSpriteName)
  GUIUtils.SetTexture(Tex_Head, headIconId)
  GUIUtils.SetText(Label_FightLevel, rankLvStr)
  GUIUtils.SetSprite(Img_BgHead, rankQualitySprite)
  GUIUtils.SetActive(Img_unusual, false)
  GUIUtils.Toggle(Img_Toggle, partner.selected)
  local canSelect = partner.position == 0 or partner.selected
  GUIUtils.SetActive(Img_Toggle, canSelect)
  GUIUtils.SetActive(Img_Grey, not canSelect)
  if Img_Grey then
    local Label = Img_Grey:FindDirect("Label")
    GUIUtils.SetActive(Label, false)
    local boxCollider = Img_Grey:GetComponent("BoxCollider")
    if boxCollider then
      boxCollider.enabled = false
    end
  end
  GUIUtils.SetActive(Label, true)
  local positionName = ""
  if partner.position ~= 0 then
    local positionCfg = PartnerInterface.GetPartnerYuanShenPositionCfg(partner.position)
    positionName = positionCfg and positionCfg.name
  end
  GUIUtils.SetText(Label, positionName)
  GUIUtils.SetActive(Img_FightMark, partner.isJoinedBattle)
end
def.method("number").SelectPartnerListItem = function(self, index)
  local ScrollView = self._UIGOs.Group_ShowPartner:FindDirect("Scroll View")
  local Grid = ScrollView:FindDirect("Grid")
  local childCount = Grid.childCount
  for i = 1, childCount - 1 do
    local itemGO = Grid:GetChild(i)
    local selected = i == index
    local Img_BgSelect = itemGO:FindDirect("Img_BgSelect")
    GUIUtils.SetActive(Img_BgSelect, selected)
    local Group_Have = itemGO:FindDirect("Group_Have")
    local Img_Toggle = Group_Have:FindDirect("Img_Toggle")
    GUIUtils.Toggle(Img_Toggle, selected)
    local Label = itemGO:FindDirect("Label")
    local Img_Grey = itemGO:FindDirect("Img_Grey")
    if Img_Grey.activeSelf == false then
      local positionName = ""
      if selected then
        local positionCfg = PartnerInterface.GetPartnerYuanShenPositionCfg(self._selPosition)
        positionName = positionCfg and positionCfg.name
      end
      GUIUtils.SetText(Label, positionName)
    end
  end
end
def.method().UpdateYuanShens = function(self)
  local Group_TianShuPos = self._UIGOs.Group_JiTan:FindDirect("Group_TianShuPos")
  local allYuanShens = self._yuanShenMgr:GetAllYuanShens()
  for objName, uiInfo in pairs(self._UIGOs.YuanShenUIs) do
    local yuanShenInfo = allYuanShens[uiInfo.position]
    local itemGO = Group_TianShuPos:FindDirect(objName)
    self:SetYuanShenInfo(itemGO, yuanShenInfo)
  end
  self:UpdateTotalFightValue()
  self:UpdateYuanShenNotifys()
end
def.method("userdata", "table").SetYuanShenInfo = function(self, itemGO, yuanShenInfo)
  if itemGO == nil then
    return
  end
  if yuanShenInfo == nil then
    warn(itemGO.name .. ":yuanShenInfo is nil")
    return
  end
  local Label_Level = itemGO:FindDirect("Img_LevelBg/Label_Level")
  local Img_HeadIcon = itemGO:FindDirect("Img_HeadIcon")
  local Img_Sign = itemGO:FindDirect("Img_Sign")
  local Group_Fight = itemGO:FindDirect("Group_Fight")
  local Img_FightMark = itemGO:FindDirect("Img_FightMark")
  GUIUtils.SetText(Label_Level, yuanShenInfo.level)
  local partnerId = yuanShenInfo.partnerId
  local headIconId = 0
  local isJoinedBattle = false
  if partnerId ~= 0 then
    local partnerCfg = PartnerInterface.Instance():GetPartnerCfgById(partnerId)
    local modelCfg = PubroleInterface.GetModelCfg(partnerCfg.modelId)
    headIconId = modelCfg and modelCfg.headerIconId or 0
    isJoinedBattle = PartnerInterface.Instance():IsPartnerJoinedBattle(partnerId)
  end
  GUIUtils.SetTexture(Img_HeadIcon, headIconId)
  GUIUtils.SetActive(Img_Sign, partnerId == 0)
  GUIUtils.SetActive(Img_FightMark, isJoinedBattle)
  if Group_Fight then
    local Label_Num = Group_Fight:FindDirect("Label_Num")
    GUIUtils.SetText(Label_Num, yuanShenInfo.fightValue)
  end
end
def.method().UpdateYuanShenNotifys = function(self)
  local Group_TianShuPos = self._UIGOs.Group_JiTan:FindDirect("Group_TianShuPos")
  local allYuanShens = self._yuanShenMgr:GetAllYuanShens()
  for objName, uiInfo in pairs(self._UIGOs.YuanShenUIs) do
    local yuanShenInfo = allYuanShens[uiInfo.position]
    local itemGO = Group_TianShuPos:FindDirect(objName)
    if itemGO then
      local Img_RedMark = itemGO:FindDirect("Img_RedMark")
      local hasNotify = self._yuanShenMgr:IsYuanShenHasNotify(yuanShenInfo.position)
      GUIUtils.SetActive(Img_RedMark, hasNotify)
    end
  end
end
def.method().ShowSelectedPositionProperties = function(self)
  self:SwitchToYuanShenUI()
  local position = self._selPosition
  local properties = self._yuanShenMgr:GetYuanShenProperties(position)
  local posInfo = self._yuanShenMgr:GetYuanShenPosInfo(position)
  self._UIGOs.properties = properties
  local Group_Right = self._UIGOs.Group_YS:FindDirect("Group_Right")
  local Group_Att = Group_Right:FindDirect("Group_Att")
  for i = 1, MAX_ATTR_NUM do
    local Att = Group_Att:FindDirect(string.format("Att%02d", i))
    if Att == nil then
      break
    end
    local propertyInfo = properties[i]
    self:SetPropertyInfo(Att, propertyInfo, posInfo)
  end
  self:UpdatePropertyLineInfo()
  self:UpdateCanUpgradeEffect()
  self:SetYuanShenUpgardeNeed()
  local Img_PosName = self._UIGOs.Group_Right:FindDirect("Img_PosName")
  if Img_PosName then
    local Group_TianShuPos = self._UIGOs.Group_JiTan:FindDirect("Group_TianShuPos")
    local uiInfo = self:FindPositionUIInfo(self._selPosition)
    local itemGO = Group_TianShuPos:FindDirect(uiInfo.objName)
    local Img_PosNameTemplate = itemGO:FindChildByPrefix("Img_PosName", false)
    local spriteName
    if Img_PosNameTemplate then
      spriteName = Img_PosNameTemplate:GetComponent("UISprite").spriteName
    else
      spriteName = "nil"
    end
    GUIUtils.SetSprite(Img_PosName, spriteName)
  end
end
def.method().UpdatePropertyLineInfo = function(self)
  local position = self._selPosition
  local posInfo = self._yuanShenMgr:GetYuanShenPosInfo(position)
  local Group_Att = self._UIGOs.Group_Right:FindDirect("Group_Att")
  local Group_Line = Group_Att:FindDirect("Group_Line")
  for i = 1, MAX_LINE_NUM do
    local Line = Group_Line:FindDirect("Sprite_" .. i)
    self:SetLineInfo(i, Line, posInfo)
  end
end
def.method().ResetPropertyLineInfo = function(self)
  local position = self._selPosition
  local posInfo = {position = position, property = 0}
  local Group_Att = self._UIGOs.Group_Right:FindDirect("Group_Att")
  local Group_Line = Group_Att:FindDirect("Group_Line")
  for i = 1, MAX_LINE_NUM do
    local Line = Group_Line:FindDirect("Sprite_" .. i)
    self:SetLineInfo(i, Line, posInfo)
  end
end
def.method("userdata", "table", "table").SetPropertyInfo = function(self, itemGO, property, posInfo)
  local Label_Effect = itemGO:FindDirect("Label_Effect")
  local Label_Lv = itemGO:FindDirect("Label_Lv")
  local Img_Name = itemGO:FindDirect("Img_Name")
  local Img_Select = itemGO:FindDirect("Img_Select")
  local Img_Bg = itemGO:FindDirect("Img_Bg")
  GUIUtils.SetText(Label_Lv, property.level)
  local img = self._UIGOs.PropertyLabels[property.type] or "nil"
  GUIUtils.SetSprite(Img_Name, img)
  local nextPropertyIndex = self:GetNextPropertyIndex(posInfo)
  local isSelected = nextPropertyIndex >= property.index
  GUIUtils.SetActive(Img_Select, isSelected)
  if isSelected then
    local uiWidget = Img_Select:GetComponent("UIWidget")
    local uiTweener = Img_Select:GetComponent("UITweener")
    if uiTweener then
      GUIUtils.SampleTweener(uiTweener, 0, false, true)
    end
    uiWidget.alpha = 1
  end
  if Img_Bg then
    local uiWidget = Img_Bg:GetComponent("UIWidget")
    local colorId = property.colorId
    local color
    if colorId ~= 0 then
      color = _G.GetColorData(colorId)
    end
    uiWidget.color = color or Color.white
  end
end
def.method("number", "userdata", "table").SetLineInfo = function(self, index, itemGO, posInfo)
  if itemGO == nil then
    return
  end
  local nextPropertyIndex = self:GetNextPropertyIndex(posInfo)
  local isLineUp = index < nextPropertyIndex
  local uiSlider = itemGO:GetComponent("UISlider")
  if isLineUp then
    uiSlider.value = 1
  else
    uiSlider.value = 0
  end
  uiSlider.autoprogress = false
  local Img_For = itemGO:FindDirect("Img_For")
  local uiWidget = Img_For:GetComponent("UIWidget")
  uiWidget.alpha = 1
  local uiTweener = Img_For:GetComponent("UITweener")
  if uiTweener then
    GUIUtils.SampleTweener(uiTweener, 0, false, true)
  end
end
def.method().UpdateCanUpgradeEffect = function(self)
  local position = self._selPosition
  local posInfo = self._yuanShenMgr:GetYuanShenPosInfo(position)
  local nextPropertyIndex = self:GetNextPropertyIndex(posInfo)
  local i = nextPropertyIndex
  if i >= 1 and i <= MAX_ATTR_NUM then
    if self._UIGOs.UI_Particle_CanUpgrade then
      self._UIGOs.UI_Particle_CanUpgrade:SetActive(true)
      local Group_Att = self._UIGOs.Group_Right:FindDirect("Group_Att")
      local Att = Group_Att:FindDirect(string.format("Att%02d", i))
      self._UIGOs.Effect_CanUpgrade.position = Att.position
    end
  else
    GUIUtils.SetActive(self._UIGOs.UI_Particle_CanUpgrade, false)
  end
end
def.method("table", "=>", "number").GetNextPropertyIndex = function(self, posInfo)
  local propertyIndex = posInfo.property
  local isYuanShenMaxLevel = self._yuanShenMgr:IsYuanShenReachMaxLevel(posInfo.position)
  if posInfo.intermediate then
    return propertyIndex
  elseif propertyIndex == MAX_ATTR_NUM and not isYuanShenMaxLevel then
    return 1
  else
    return propertyIndex + 1
  end
end
def.method().SetYuanShenUpgardeNeed = function(self)
  local Group_Right = self._UIGOs.Group_YS:FindDirect("Group_Right")
  local Btn_YuanbaoUse = Group_Right:FindDirect("Btn_YuanbaoUse")
  local Btn_Upgrade = Group_Right:FindDirect("Btn_Upgrade")
  local Btn_UpgradeMulti = self._UIGOs.Btn_UpgradeMulti
  local Img_ItemGet = Group_Right:FindDirect("Img_ItemGet")
  local Img_Icon = Img_ItemGet:FindDirect("Img_Icon")
  local Label_Number = Img_ItemGet:FindDirect("Label_Number")
  local Label_Tips = Group_Right:FindDirect("Label_Tips")
  local upgradeNeed = self._yuanShenMgr:GetCurYuanshenUpgradeNeed(self._selPosition)
  local canUpgrade = upgradeNeed ~= nil
  self._costItem.upgrade = canUpgrade
  GUIUtils.SetActive(Img_ItemGet, canUpgrade)
  GUIUtils.SetActive(Btn_YuanbaoUse, canUpgrade and self._autoBuyOpen)
  GUIUtils.SetActive(Btn_Upgrade, canUpgrade)
  GUIUtils.SetActive(Btn_UpgradeMulti, canUpgrade)
  GUIUtils.SetActive(Label_Tips, not canUpgrade)
  if canUpgrade == false then
    local positionCfg = PartnerInterface.GetPartnerYuanShenPositionCfg(self._selPosition)
    local positionName = positionCfg and positionCfg.name or "nil"
    local tips = textRes.Partner.YuanShen[11]:format(positionName)
    GUIUtils.SetText(Label_Tips, tips)
    return
  end
  local itemFilterCfg = ItemUtils.GetItemFilterCfg(upgradeNeed.itemSiftId)
  local iconId = 0
  local haveNum = 0
  self._costItem.itemIds = {}
  self._costItem.displayItemId = nil
  if itemFilterCfg then
    iconId = itemFilterCfg.icon
    for i, v in ipairs(itemFilterCfg.siftCfgs) do
      haveNum = haveNum + ItemModule.Instance():GetItemCountById(v.idvalue)
      table.insert(self._costItem.itemIds, v.idvalue)
      if self._costItem.displayItemId == nil then
        local itemBase = ItemUtils.GetItemBase(v.idvalue)
        if itemBase and not itemBase.isProprietary then
          self._costItem.displayItemId = v.idvalue
        end
      end
    end
  end
  self._costItem.haveNum = haveNum
  self._costItem.needNum = upgradeNeed.itemNum
  GUIUtils.SetTexture(Img_Icon, iconId)
  local numText = string.format("%d/%d", haveNum, upgradeNeed.itemNum)
  local isItemEnough = haveNum >= upgradeNeed.itemNum
  if isItemEnough then
    numText = string.format("[00ff00]%s[-]", numText)
  else
    numText = string.format("[ff0000]%s[-]", numText)
  end
  GUIUtils.SetText(Label_Number, numText)
  local Label_YS = Btn_Upgrade:FindDirect("Label_YS")
  local Group_MoneyMake = Btn_Upgrade:FindDirect("Group_MoneyMake")
  local Img_RedMark = Btn_Upgrade:FindDirect("Img_RedMark")
  local yuanBaoBuy = self._autoBuy and not isItemEnough
  local showMark = false
  GUIUtils.SetActive(Label_YS, not yuanBaoBuy)
  GUIUtils.SetActive(Group_MoneyMake, yuanBaoBuy)
  GUIUtils.SetActive(Img_RedMark, showMark and isItemEnough)
  if yuanBaoBuy then
    local Label_MoneyMake = Group_MoneyMake:FindDirect("Label_MoneyMake")
    local moneyText
    if self._costItem.itemYuanBao then
      local buyNum = upgradeNeed.itemNum - haveNum
      moneyText = self._costItem.itemYuanBao * buyNum
    else
      moneyText = "--"
    end
    GUIUtils.SetText(Label_MoneyMake, moneyText)
  end
  local upgradeNeed = self._yuanShenMgr:GetCurYuanshenUpgradeNeedEx(self._selPosition, UPGRADE_MULTI_TIMES)
  local isItemEnough = haveNum >= upgradeNeed.itemNum
  self._costItem.mulityNeedNum = upgradeNeed.itemNum
  self._costItem.mulityTimes = upgradeNeed.upgradeLevel
  local Label_YS = Btn_UpgradeMulti:FindDirect("Label_YS")
  local Group_MoneyMake = Btn_UpgradeMulti:FindDirect("Group_MoneyMake")
  local Img_RedMark = Btn_UpgradeMulti:FindDirect("Img_RedMark")
  local yuanBaoBuy = self._autoBuy and not isItemEnough
  local isTopLevel = self._yuanShenMgr:IsTopLevelYuanShen(self._selPosition)
  GUIUtils.SetActive(Label_YS, not yuanBaoBuy)
  GUIUtils.SetActive(Group_MoneyMake, yuanBaoBuy)
  GUIUtils.SetActive(Img_RedMark, isTopLevel and isItemEnough)
  if yuanBaoBuy then
    local Label_MoneyMake = Group_MoneyMake:FindDirect("Label_MoneyMake")
    local moneyText
    if self._costItem.itemYuanBao then
      local buyNum = upgradeNeed.itemNum - haveNum
      moneyText = self._costItem.itemYuanBao * buyNum
    else
      moneyText = "--"
    end
    GUIUtils.SetText(Label_MoneyMake, moneyText)
  end
end
def.method("number").SelectYuanShenPosition = function(self, position)
  self._selPosition = position
  if self._UIGOs.Group_ShowPartner.activeSelf then
    self:ShowSelectedPositionPartnerList()
  else
    self:ShowSelectedPositionProperties()
  end
  local Group_TianShuPos = self._UIGOs.Group_JiTan:FindDirect("Group_TianShuPos")
  for objName, uiInfo in pairs(self._UIGOs.YuanShenUIs) do
    local itemGO = Group_TianShuPos:FindDirect(objName)
    local isSelected = uiInfo.position == position
    if itemGO then
      local Img_SelectedBg = itemGO:FindDirect("Img_SelectedBg")
      GUIUtils.SetActive(Img_SelectedBg, isSelected)
      if isSelected then
        GUIUtils.SetLightEffect(itemGO, GUIUtils.Light.Square)
      else
        GUIUtils.SetLightEffect(itemGO, GUIUtils.Light.None)
      end
    end
  end
end
def.method("table", "table", "=>", "boolean").PlayPropertyUpgradeAni = function(self, posInfo, lastPosInfo)
  if self._selPosition ~= posInfo.position then
    self:UpdateYuanShens()
    return false
  end
  local Group_Right = self._UIGOs.Group_YS:FindDirect("Group_Right")
  local Group_Att = Group_Right:FindDirect("Group_Att")
  local properties = self._yuanShenMgr:GetYuanShenProperties(posInfo.position)
  local propertyDiff = self:GetAbsolutePropertyDiff(posInfo, lastPosInfo)
  local fightValueFrom = self:GetCurUIFightValue(lastPosInfo.position)
  local fightValueTo = self._yuanShenMgr:CalcYuanShengFightValue(posInfo.position)
  local intermediatePosInfo = clone(lastPosInfo)
  intermediatePosInfo.intermediate = true
  local AUTO_RPOGRESS_DURATION = 0.6 / math.max(1, propertyDiff / 3)
  local co = coroutine.create(function()
    for count = 1, propertyDiff do
      local progress = count / propertyDiff
      local i = (lastPosInfo.property + count - 1) % MAX_ATTR_NUM + 1
      local propertyInfo = properties[i]
      local Att = Group_Att:FindDirect(string.format("Att%02d", i))
      intermediatePosInfo = self._yuanShenMgr:UpgradeYuanShenLevel(intermediatePosInfo, 1)
      self:SetPropertyInfo(Att, propertyInfo, intermediatePosInfo)
      local Group_Line = Group_Att:FindDirect("Group_Line")
      local Line = Group_Line:FindDirect("Sprite_" .. i)
      if Line then
        local uiSlider = Line:GetComponent("UISlider")
        uiSlider:AutoProgress(true, 0, 1, AUTO_RPOGRESS_DURATION)
        coroutine.yield(AUTO_RPOGRESS_DURATION)
        if self._UIGOs.Group_ShowPartner.activeSelf then
          return
        end
        if self._selPosition ~= posInfo.position then
          return
        end
        local interFightValue = fightValueTo * progress + (1 - progress) * fightValueFrom
        self:SetYuanShenFightValue(posInfo, interFightValue)
        self:UpdateCanUpgradeEffect()
      elseif i == MAX_ATTR_NUM then
        self:PlayYuanShenUpgradeAni(posInfo, lastPosInfo)
        fightValueFrom = fightValueTo
      end
    end
  end)
  local function run(delay)
    delay = delay or 0
    GameUtil.AddGlobalLateTimer(delay, true, function()
      if self:IsShow() == false then
        return
      end
      if self._selPosition ~= posInfo.position then
        self:EnableUpgrade(true)
        self._UIGOs.UI_Particle_TuoWeiLiZi:SetActive(false)
        self:UpdateYuanShens()
        return
      end
      if coroutine.status(co) ~= "dead" then
        local ret = {
          coroutine.resume(co)
        }
        local delay, precall
        if ret[1] then
          delay = ret[2]
          precall = ret[3]
          if precall then
            precall()
          end
        else
          Debug.LogError(debug.traceback(co, ret[2]))
        end
        return run(delay)
      else
        self:EnableUpgrade(true)
        if self._UIGOs.Group_ShowPartner.activeSelf then
          self:UpdateYuanShens()
        else
          self:ShowSelectedPositionProperties()
        end
      end
    end)
  end
  run()
  return true
end
def.method("table", "table", "=>", "number").GetAbsolutePropertyDiff = function(self, posInfoA, posInfoB)
  local absolutePropertyA = posInfoA.level * MAX_ATTR_NUM + posInfoA.property
  local absolutePropertyB = posInfoB.level * MAX_ATTR_NUM + posInfoB.property
  return absolutePropertyA - absolutePropertyB
end
def.method("table", "number").SetYuanShenFightValue = function(self, posInfo, fightValue)
  local uiInfo = self:FindPositionUIInfo(posInfo.position)
  local Group_TianShuPos = self._UIGOs.Group_JiTan:FindDirect("Group_TianShuPos")
  local yuanShengGroup = Group_TianShuPos:FindDirect(uiInfo.objName)
  local Group_Fight = yuanShengGroup:FindDirect("Group_Fight")
  if Group_Fight then
    local Label_Num = Group_Fight:FindDirect("Label_Num")
    GUIUtils.SetText(Label_Num, fightValue)
  end
  self:UpdateTotalFightValue()
end
def.method().UpdateTotalFightValue = function(self)
  local Label_SX_PowerNumber = self._UIGOs.Group_Fight:FindDirect("Label_SX_PowerNumber")
  local Group_TianShuPos = self._UIGOs.Group_JiTan:FindDirect("Group_TianShuPos")
  local allYuanShens = self._yuanShenMgr:GetAllYuanShens()
  local totalFightValue = 0
  for i, v in ipairs(allYuanShens) do
    local fightValue = self:GetCurUIFightValue(v.position)
    totalFightValue = totalFightValue + fightValue
  end
  GUIUtils.SetText(Label_SX_PowerNumber, totalFightValue)
end
def.method("number", "=>", "number").GetCurUIFightValue = function(self, position)
  local uiInfo = self:FindPositionUIInfo(position)
  local Group_TianShuPos = self._UIGOs.Group_JiTan:FindDirect("Group_TianShuPos")
  local yuanShengGroup = Group_TianShuPos:FindDirect(uiInfo.objName)
  local Group_Fight = yuanShengGroup:FindDirect("Group_Fight")
  if Group_Fight then
    local Label_Num = Group_Fight:FindDirect("Label_Num")
    return tonumber(GUIUtils.GetUILabelTxt(Label_Num)) or 0
  end
  return 0
end
def.method("table", "table").PlayYuanShenUpgradeAni = function(self, posInfo, lastPosInfo)
  local UPGRADE_TIME = 0.6
  local EFFECT_FLY_TIME = 0.6
  local Group_Right = self._UIGOs.Group_YS:FindDirect("Group_Right")
  local Group_Att = Group_Right:FindDirect("Group_Att")
  for i = 2, MAX_ATTR_NUM do
    local Att = Group_Att:FindDirect(string.format("Att%02d", i))
    if Att == nil then
      break
    end
    local Img_Select = Att:FindDirect("Img_Select")
    TweenAlpha.Begin(Img_Select, UPGRADE_TIME, 0)
  end
  local Group_Line = Group_Att:FindDirect("Group_Line")
  for i = 1, MAX_LINE_NUM do
    local Line = Group_Line:FindDirect("Sprite_" .. i)
    local Img_For = Line:FindDirect("Img_For")
    TweenAlpha.Begin(Img_For, UPGRADE_TIME, 0)
  end
  local startGO = Group_Att:FindDirect(string.format("Att%02d", MAX_ATTR_NUM))
  local endGO
  local Group_TianShuPos = self._UIGOs.Group_JiTan:FindDirect("Group_TianShuPos")
  for objName, uiInfo in pairs(self._UIGOs.YuanShenUIs) do
    if posInfo.position == uiInfo.position then
      endGO = Group_TianShuPos:FindDirect(objName)
      break
    end
  end
  self._UIGOs.UI_Particle_TuoWeiLiZi:SetActive(true)
  local tp = TweenPosition.Begin(self._UIGOs.Effect_TuoWeiLiZi, EFFECT_FLY_TIME, endGO.position)
  tp.from = startGO.position
  tp:set_worldSpace(true)
  coroutine.yield(EFFECT_FLY_TIME)
  if self._UIGOs == nil or self._UIGOs.Effect_TuoWeiLiZi.isnil then
    return
  end
  self._UIGOs.UI_Particle_TuoWeiLiZi:SetActive(false)
  self._UIGOs.Effect_Upgrade:SetActive(false)
  self._UIGOs.Effect_Upgrade.position = endGO.position
  self._UIGOs.Effect_Upgrade:SetActive(true)
  coroutine.yield(EFFECT_FLY_TIME, function()
    self:UpdateYuanShens()
  end)
  coroutine.yield(UPGRADE_TIME - EFFECT_FLY_TIME)
  if self._UIGOs == nil or self._UIGOs.Effect_TuoWeiLiZi.isnil then
    return
  end
  self:ResetPropertyLineInfo()
end
def.method("boolean").EnableUpgrade = function(self, isEnabled)
  self._upgrading = not isEnabled
  if self._UIGOs == nil then
    return
  end
  if self._UIGOs.Btn_Upgrade.isnil then
    return
  end
  local uiButton = self._UIGOs.Btn_Upgrade:GetComponent("UIButton")
  uiButton.isEnabled = isEnabled
  local uiButton = self._UIGOs.Btn_UpgradeMulti:GetComponent("UIButton")
  uiButton.isEnabled = isEnabled
end
def.method("number", "=>", "table").FindPositionUIInfo = function(self, position)
  for objName, uiInfo in pairs(self._UIGOs.YuanShenUIs) do
    if uiInfo.position == position then
      uiInfo.objName = objName
      return uiInfo
    end
  end
  return nil
end
def.method().UpdateTabRedMark = function(self)
  if self._partnerMain == nil or _G.IsNil(self._partnerMain.m_panel) then
    return
  end
  local hasNotify = self._yuanShenMgr:HasNotify()
  local Img_RedMark_Tab = self._partnerMain.m_panel:FindDirect("Img_Bg0/Tab_YS/Img_RedMark")
  GUIUtils.SetActive(Img_RedMark_Tab, hasNotify)
end
def.method("table").OnBagInfoSynchronized = function(self, params)
  if not self:IsShow() then
    return
  end
  self:SetYuanShenUpgardeNeed()
  self:UpdateYuanShenNotifys()
end
def.method("table").OnYuanShenPartnerChange = function(self, params)
  if not self:IsShow() then
    return
  end
  self:UpdateYuanShens()
end
def.method("table").OnYuanShenUpgradeSuccess = function(self, params)
  if not self:IsShow() then
    return
  end
  local ret = self:PlayPropertyUpgradeAni(params.posInfo, params.lastPosInfo)
  if ret == false then
    self:EnableUpgrade(true)
  end
end
def.method("table").OnYuanShenUpgradeFail = function(self, params)
  self:EnableUpgrade(true)
  if not self:IsShow() then
    return
  end
end
def.method("table").OnPartnerNotifyChange = function(self, params)
  self:UpdateTabRedMark()
end
PartnerMain_God2.Commit()
return PartnerMain_God2
