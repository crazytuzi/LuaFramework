local Lplus = require("Lplus")
local ECPanelBase = require("GUI.ECPanelBase")
local HeroPropPanelNodeBase = require("Main.Hero.ui.HeroPropPanelNodeBase")
local TurnedCardNode = Lplus.Extend(HeroPropPanelNodeBase, "TurnedCardNode")
local ECUIModel = require("Model.ECUIModel")
local GUIUtils = require("GUI.GUIUtils")
local PropertyType = require("consts.mzm.gsp.common.confbean.PropertyType")
local TurnedCardInterface = require("Main.TurnedCard.TurnedCardInterface")
local TurnedCardUtils = require("Main.TurnedCard.TurnedCardUtils")
local ECModel = require("Model.ECModel")
local UIModelWrap = require("Model.UIModelWrap")
local ClassTypeEnum = require("consts.mzm.gsp.changemodelcard.confbean.ClassTypeEnum")
local CommonConfirmDlg = require("GUI.CommonConfirmDlg")
local TokenType = require("consts.mzm.gsp.item.confbean.TokenType")
local ItemModule = Lplus.ForwardDeclare("ItemModule")
local Vector = require("Types.Vector")
local CaptchaConfirmDlg = require("GUI.CaptchaConfirmDlg")
local FilterTypeEnum = require("consts.mzm.gsp.changemodelcard.confbean.FilterTypeEnum")
local ItemTipsMgr = require("Main.Item.ItemTipsMgr")
local ProValueType = require("consts.mzm.gsp.common.confbean.ProValueType")
local def = TurnedCardNode.define
def.field("table").curCardList = nil
def.field("number").selectedIdx = 0
def.field(UIModelWrap)._UIModelWrap = nil
def.field("number").curSelectedClass = 0
def.field("userdata").curSelectedUUID = nil
def.const("table").Level_Frame = TurnedCardUtils.TurnedCardLevelFrame
local instance
def.static("=>", TurnedCardNode).Instance = function()
  if instance == nil then
    instance = TurnedCardNode()
  end
  return instance
end
def.override("string").onClick = function(self, id)
  local strs = string.split(id, "_")
  if id == "Btn_CardBag" then
    local TurnedCardBagPanel = require("Main.TurnedCard.ui.TurnedCardBagPanel")
    TurnedCardBagPanel.Instance():ShowPanel()
  elseif id == "Btn_SkillChoose" then
    self:setClassDisplay()
  elseif id == "Btn_Card" then
    local DrawTurnedCardPanel = require("Main.TurnedCard.ui.DrawTurnedCardPanel")
    DrawTurnedCardPanel.Instance():ShowPanel()
  elseif id == "Btn_Zone" then
    self:setOperationDisplay()
  elseif id == "Btn_Use" then
    self:useTurnedCard()
  elseif id == "Btn_1" then
    self:setOperationDisplay()
    local TurnedCardDecomposePanel = require("Main.TurnedCard.ui.TurnedCardDecomposePanel")
    TurnedCardDecomposePanel.Instance():ShowPanel()
  elseif id == "Group_CurUse" then
    local curCardId = TurnedCardInterface.Instance():getCurTurnedCardId()
    if curCardId > 0 then
      self.m_base:HidePanel()
      require("Main.Buff.ui.BuffPanel").Instance():ShowPanel()
    end
  elseif id == "Btn_Help" then
    require("GUI.GUIUtils").ShowHoverTip(701605131, 0, 0)
  elseif id == "Btn_AddJing" then
    local itemList = {}
    local itemFilterCfg = TurnedCardUtils.GetChangeModelCardItemFilterCfg(FilterTypeEnum.CARD_ESSENCE_ITEM)
    if itemFilterCfg then
      do
        local ItemModule = require("Main.Item.ItemModule")
        local itemModule = ItemModule.Instance()
        local ids = {}
        for i, v in ipairs(itemFilterCfg.itemCfgIds) do
          ids[v] = v
        end
        local function filterFunc(item)
          if ids[item.id] then
            return true
          end
          return false
        end
        local items = itemModule:GetItemsByItemIds(ItemModule.BAG, ids)
        for i, v in pairs(items) do
          table.insert(itemList, v)
        end
        if #itemList > 0 then
          local CommonUsePanel = require("GUI.CommonUsePanel")
          CommonUsePanel.Instance():ShowPanelWithItems(filterFunc, nil, CommonUsePanel.Source.Bag, itemList, nil)
          return
        end
      end
    end
    local Btn_AddJing = self.m_node:FindDirect("Group_Right/Group_Title/Group_Jing/Btn_AddJing")
    local itemId = constant.CChangeModelCardConsts.ESSENCE_SOURCE_ITEM_CFG_ID
    ItemTipsMgr.Instance():ShowBasicTipsWithGO(itemId, Btn_AddJing, 0, true)
  elseif id == "Btn_Upgrade" then
    local card = self.curCardList[self.selectedIdx]
    if card == nil then
      Toast(textRes.TurnedCard[9])
      return
    end
    local TurnedCardLevelUpPanel = require("Main.TurnedCard.ui.TurnedCardLevelUpPanel")
    TurnedCardLevelUpPanel.Instance():ShowPanel(card:getUUID())
  elseif id == "Btn_2" then
    self:setOperationDisplay()
    do
      local card = self.curCardList[self.selectedIdx]
      if card == nil then
        Toast(textRes.TurnedCard[9])
        return
      end
      local cfgId = card:getCardCfgId()
      local level = card:getCardLevel()
      local cardLevelCfg = TurnedCardUtils.GetCardLevelCfg(cfgId)
      local levelCfg = cardLevelCfg.cardLevels[level]
      local score = 0
      if levelCfg then
        score = levelCfg.sellScore
      end
      local function callback(id)
        if id == 1 then
          local function callback1(s)
            if s == 1 then
              local p = require("netio.protocol.mzm.gsp.changemodelcard.CCardDecomposeReq").new({
                card:getUUID()
              })
              gmodule.network.sendProtocol(p)
            end
          end
          local PurpleLv = TurnedCardUtils.PurpleLevel
          if PurpleLv <= level then
            CaptchaConfirmDlg.ShowConfirm(textRes.TurnedCard[32], "", textRes.TurnedCard[33], nil, callback1, nil)
          else
            callback1(1)
          end
        end
      end
      CommonConfirmDlg.ShowConfirm("", string.format(textRes.TurnedCard[16], score), callback, nil)
    end
  elseif id == "Btn_AttHelp" then
    local TurnedCardRestraintRelationship = require("Main.TurnedCard.ui.TurnedCardRestraintRelationship")
    local card = self.curCardList[self.selectedIdx]
    if card == nil then
      TurnedCardRestraintRelationship.Instance():ShowPanel()
    else
      local cardCfg = TurnedCardUtils.GetChangeModelCardCfg(card:getCardCfgId())
      TurnedCardRestraintRelationship.Instance():ShowPanelByClass(cardCfg.classType)
    end
  elseif strs[1] == "Btn" and strs[2] == "Type" then
    local index = tonumber(strs[3])
    if index then
      self.curSelectedClass = index - 1
      self:setClassDisplay()
      self:setTurnedCardList()
      self:resetPositionCardList()
    end
  elseif strs[1] == "item" then
    local idx = tonumber(strs[2])
    if idx then
      self.selectedIdx = idx
      local curCard = self.curCardList[idx]
      self.curSelectedUUID = curCard:getUUID()
      self:setSelectedTurnedCardInfo()
    end
  elseif "Btn_Tj" == id then
    require("Main.TurnedCard.ui.UITurnCardTuJian").Instance():ShowPanel()
  else
    self:hideAllMenu()
  end
end
def.method().useTurnedCard = function(self)
  local turnedCardInterface = TurnedCardInterface.Instance()
  local curCardCfgId = turnedCardInterface:getCurTurnedCardId()
  local curCard = self.curCardList[self.selectedIdx]
  if curCard == nil then
    Toast(textRes.TurnedCard[9])
    return
  end
  local info = curCard:getCardInfo()
  local cardCfg = TurnedCardUtils.GetChangeModelCardCfg(info.card_cfg_id)
  local cardLevelCfg = TurnedCardUtils.GetCardLevelCfg(info.card_cfg_id)
  local level = info.level
  if level == 0 then
    level = 1
  end
  local myLevel = _G.GetHeroProp().level
  if myLevel < cardCfg.useLevel then
    Toast(string.format(textRes.TurnedCard[11], cardCfg.useLevel))
    return
  end
  local curLevelCfg = cardLevelCfg.cardLevels[level]
  local jingqiNum = ItemModule.Instance():GetCredits(TokenType.CHANGE_MODEL_CARD_ESSENCE) or Int64.new(0)
  if jingqiNum:lt(Int64.new(curLevelCfg.useCostEssence)) then
    Toast(string.format(textRes.TurnedCard[10], curLevelCfg.useCostEssence))
    return
  end
  local curUseCount = curCard:getCardUseCount()
  if 0 < curLevelCfg.useCount and curUseCount >= curLevelCfg.useCount then
    Toast(textRes.TurnedCard[12])
    return
  end
  local content
  local cardName = TurnedCardUtils.GetTurnedCardDisPlayName(info.card_cfg_id, level)
  if curCardCfgId == 0 then
    content = string.format(textRes.TurnedCard[7], cardName)
  elseif curCardCfgId == curCard:getCardCfgId() and curCard:getCardLevel() == turnedCardInterface:getCurTurnedCardLevel() then
    content = string.format(textRes.TurnedCard[25], cardName)
  else
    content = string.format(textRes.TurnedCard[8], cardName)
  end
  local function callback(id)
    if id == 1 then
      gmodule.network.sendProtocol(require("netio.protocol.mzm.gsp.changemodelcard.CUseCardReq").new(curCard.uuid))
    end
  end
  CommonConfirmDlg.ShowConfirm("", content, callback, nil)
end
def.method().hideAllMenu = function(self)
  local Btn_SkillChoose = self.m_node:FindDirect("Group_Left/Btn_SkillChoose")
  local Group_Zone = Btn_SkillChoose:FindDirect("Group_Zone")
  Group_Zone:SetActive(false)
  local Img_Up = Btn_SkillChoose:FindDirect("Img_Up")
  local Img_Down = Btn_SkillChoose:FindDirect("Img_Down")
  Img_Up:SetActive(true)
  Img_Down:SetActive(false)
  local Btn_Zone = self.m_node:FindDirect("Group_Right/Btn_Zone")
  local Group_Zone = Btn_Zone:FindDirect("Group_Zone")
  Group_Zone:SetActive(false)
  Btn_Zone:GetComponent("UIToggleEx").value = false
end
def.method().setClassDisplay = function(self)
  local Btn_SkillChoose = self.m_node:FindDirect("Group_Left/Btn_SkillChoose")
  local Group_Zone = Btn_SkillChoose:FindDirect("Group_Zone")
  local isShow = not Group_Zone.activeSelf
  Group_Zone:SetActive(isShow)
  local Img_Up = Btn_SkillChoose:FindDirect("Img_Up")
  local Img_Down = Btn_SkillChoose:FindDirect("Img_Down")
  Img_Up:SetActive(not isShow)
  Img_Down:SetActive(isShow)
  local Label_Btn = Btn_SkillChoose:FindDirect("Label_Btn")
  Label_Btn:GetComponent("UILabel"):set_text(textRes.TurnedCard.CardClassName[self.curSelectedClass])
end
def.method().setOperationDisplay = function(self)
  local Btn_Zone = self.m_node:FindDirect("Group_Right/Btn_Zone")
  local Group_Zone = Btn_Zone:FindDirect("Group_Zone")
  local isShow = Group_Zone.activeSelf
  Group_Zone:SetActive(not isShow)
  Btn_Zone:GetComponent("UIToggleEx").value = not isShow
end
def.override().OnShow = function(self)
  self:InitUI()
  Event.RegisterEvent(ModuleId.TURNED_CARD, gmodule.notifyId.TurnedCard.Get_Turned_Card, TurnedCardNode.OnGetTurnedCard)
  Event.RegisterEvent(ModuleId.ITEM, gmodule.notifyId.item.Item_Credit_Change, TurnedCardNode.OnCreditChange)
  Event.RegisterEvent(ModuleId.TURNED_CARD, gmodule.notifyId.TurnedCard.Remove_Turned_Card, TurnedCardNode.OnRemoveTurnedCard)
  Event.RegisterEvent(ModuleId.TURNED_CARD, gmodule.notifyId.TurnedCard.Turned_Card_Level_Change, TurnedCardNode.OnTurnedCardLevelChange)
  Event.RegisterEvent(ModuleId.TURNED_CARD, gmodule.notifyId.TurnedCard.Turned_Card_Use_Success, TurnedCardNode.OnTurnedCardUseSuccess)
  Event.RegisterEvent(ModuleId.TURNED_CARD, gmodule.notifyId.TurnedCard.Turned_CArd_Item_Red_Point_Change, TurnedCardNode.OnTurnedCardNotifyUpdate)
end
def.override().OnHide = function(self)
  Event.UnregisterEvent(ModuleId.TURNED_CARD, gmodule.notifyId.TurnedCard.Get_Turned_Card, TurnedCardNode.OnGetTurnedCard)
  Event.UnregisterEvent(ModuleId.ITEM, gmodule.notifyId.item.Item_Credit_Change, TurnedCardNode.OnCreditChange)
  Event.UnregisterEvent(ModuleId.TURNED_CARD, gmodule.notifyId.TurnedCard.Remove_Turned_Card, TurnedCardNode.OnRemoveTurnedCard)
  Event.UnregisterEvent(ModuleId.TURNED_CARD, gmodule.notifyId.TurnedCard.Turned_Card_Level_Change, TurnedCardNode.OnTurnedCardLevelChange)
  Event.UnregisterEvent(ModuleId.TURNED_CARD, gmodule.notifyId.TurnedCard.Turned_Card_Use_Success, TurnedCardNode.OnTurnedCardUseSuccess)
  Event.UnregisterEvent(ModuleId.TURNED_CARD, gmodule.notifyId.TurnedCard.Turned_CArd_Item_Red_Point_Change, TurnedCardNode.OnTurnedCardNotifyUpdate)
  if self._UIModelWrap then
    self._UIModelWrap:Destroy()
    self._UIModelWrap = nil
  end
  self.curCardList = nil
  self.selectedIdx = 0
  self._UIModelWrap = nil
  self.curSelectedClass = 0
  self.curSelectedUUID = nil
end
def.override("=>", "boolean").IsUnlock = function(self)
  return TurnedCardInterface.Instance():isOpenTurnedCard()
end
def.override("=>", "boolean").HasNotify = function(self)
  return TurnedCardInterface.Instance():isShowTurnedCardRedPoint()
end
def.static("table", "table").OnTurnedCardUseSuccess = function(p1, p2)
  if instance then
    instance:setSelectedTurnedCardInfo()
    instance:setCurUseCardInfo()
    instance:playUseSuccessEffect()
    local cfgId = p1[2]
    local cardCfg = TurnedCardUtils.GetChangeModelCardCfg(cfgId)
    if cardCfg then
      local curCard = instance.curCardList[instance.selectedIdx]
      if curCard then
        local info = curCard:getCardInfo()
        if info then
          local cardLevelCfg = TurnedCardUtils.GetCardLevelCfg(info.card_cfg_id)
          if cardLevelCfg then
            local level = info.level
            local curLevelCfg = cardLevelCfg.cardLevels[level]
            if curLevelCfg then
              local cardName = TurnedCardUtils.GetTurnedCardDisPlayName(cfgId, level)
              Toast(string.format(textRes.TurnedCard[13], cardName, curLevelCfg.useCostEssence))
            end
          end
        end
      end
    end
  end
end
def.static("table", "table").OnTurnedCardLevelChange = function(p1, p2)
  if instance then
    instance:setTurnedCardList()
    instance:setSelectedTurnedCardInfo()
  end
end
def.static("table", "table").OnTurnedCardNotifyUpdate = function(p1, p2)
  if instance then
    instance:setTurnedCardBagRedPoint()
  end
end
def.static("table", "table").OnRemoveTurnedCard = function(p1, p2)
  if instance then
    instance:setTurnedCardList()
  end
end
def.static("table", "table").OnCreditChange = function(p1, p2)
  if instance then
    instance:setScoreInfo()
  end
end
def.static("table", "table").OnGetTurnedCard = function(p1, p2)
  if instance then
    instance:setTurnedCardList()
  end
end
def.method().playUseSuccessEffect = function(self)
  local ECGUIMan = require("GUI.ECGUIMan")
  local uiRoot = ECGUIMan.Instance().m_UIRoot
  local Img_CardLevelTitle = self.m_node:FindDirect("Group_Right/Group_Head/Img_CardLevelTitle")
  local uiPath = "panel_main/Pnl_RolePet/RolePetGroup/Buff_Role/Grid/"
  local Buff_Grid = uiRoot:FindDirect(uiPath)
  local Img_Buff_2 = Buff_Grid:FindDirect("Img_Buff_2")
  local targetGo = Img_Buff_2 or Buff_Grid
  if _G.IsNil(targetGo) then
    warn("playUseSuccessEffect UIPath: " .. uiPath .. ", not exist.")
    return
  end
  local effectId = 702020290
  local effectCfg = _G.GetEffectRes(effectId)
  if effectCfg == nil then
    return
  end
  local resPath = effectCfg.path
  GameUtil.AsyncLoad(resPath, function(ass)
    if ass == nil then
      return
    end
    if _G.IsNil(targetGo) then
      return
    end
    local parent = require("Fx.GUIFxMan").Instance().fxroot
    local go = GameObject.GameObject("TurnedCardFX")
    go:SetLayer(ClientDef_Layer.UI2)
    go.transform.parent = parent.transform
    go.transform.localScale = Vector.Vector3.one
    go.transform.position = Img_CardLevelTitle.transform.position
    local localPosition = go.transform.localPosition
    GameObject.Destroy(go)
    local fx = require("Fx.GUIFxMan").Instance():PlayAsChild(parent, resPath, localPosition.x, localPosition.y, 1, false)
    local duration = 0.8
    local destPos = targetGo.transform.position
    local tp = TweenPosition.Begin(fx, duration, destPos)
    tp:set_worldSpace(true)
    tp.from = fx.transform.position
  end)
end
def.method().setClassName = function(self)
  local Btn_SkillChoose = self.m_node:FindDirect("Group_Left/Btn_SkillChoose")
  local Grid = Btn_SkillChoose:FindDirect("Group_Zone/Group_ChooseType/Grid")
  for i, v in pairs(ClassTypeEnum) do
    local Btn_Type = Grid:FindDirect("Btn_Type_" .. v + 1)
    if Btn_Type then
      local Label_Name = Btn_Type:FindDirect("Label_Name")
      Label_Name:GetComponent("UILabel"):set_text(textRes.TurnedCard.CardClassName[v])
    end
  end
  local Img_Up = Btn_SkillChoose:FindDirect("Img_Up")
  local Img_Down = Btn_SkillChoose:FindDirect("Img_Down")
  Img_Up:SetActive(true)
  Img_Down:SetActive(false)
  local Label_Btn = Btn_SkillChoose:FindDirect("Label_Btn")
  local classCfg = TurnedCardUtils.GetCardClassCfg(self.curSelectedClass)
  Label_Btn:GetComponent("UILabel"):set_text(classCfg.className)
  local Label_Btn = Btn_SkillChoose:FindDirect("Label_Btn")
  Label_Btn:GetComponent("UILabel"):set_text(textRes.TurnedCard.CardClassName[self.curSelectedClass])
end
def.override().InitUI = function(self)
  self:setClassName()
  self:setTurnedCardList()
  self:setScoreInfo()
  self:hideAllMenu()
  self:setCurUseCardInfo()
  self:setTurnedCardBagRedPoint()
  self:resetPositionCardList()
end
def.method().setTurnedCardBagRedPoint = function(self)
  local Btn_CardBag = self.m_node:FindDirect("Group_Left/Btn_CardBag")
  local Img_Red = Btn_CardBag:FindDirect("Img_Red")
  Img_Red:SetActive(TurnedCardInterface.Instance():isShowTurnedCardBagRedPoint())
end
def.method().resetPositionCardList = function(self)
  local Scrollview = self.m_node:FindDirect("Group_Left/Group_List/ScrollView_List")
  GameUtil.AddGlobalTimer(0, true, function()
    if _G.IsNil(self.m_panel) then
      return
    end
    Scrollview:GetComponent("UIScrollView"):ResetPosition()
  end)
end
def.method().setTurnedCardList = function(self)
  local turnedCardInterface = TurnedCardInterface.Instance()
  local cardList = turnedCardInterface:getTurnedCardList(self.curSelectedClass)
  self.curCardList = cardList
  local List = self.m_node:FindDirect("Group_Left/Group_List/ScrollView_List/List")
  local uiList = List:GetComponent("UIList")
  uiList.itemCount = #cardList
  uiList:Resize()
  local isSelected = false
  for i, v in ipairs(cardList) do
    local item = List:FindDirect("item_" .. i)
    local Icon = item:FindDirect("Icon")
    local Label_PowerLv = item:FindDirect("Label_PowerLv")
    local Img_Tpye = item:FindDirect("Img_Tpye")
    local info = v:getCardInfo()
    local uuid = v:getUUID()
    local toggle = item:GetComponent("UIToggle")
    if self.curSelectedUUID and self.curSelectedUUID:eq(uuid) then
      toggle.value = true
      isSelected = true
      self.selectedIdx = i
    else
      toggle.value = false
    end
    if info then
      local level = v:getCardLevel()
      item:GetComponent("UISprite"):set_spriteName(TurnedCardNode.Level_Frame[level])
      local cardCfg = TurnedCardUtils.GetChangeModelCardCfg(info.card_cfg_id)
      GUIUtils.FillIcon(Icon:GetComponent("UITexture"), cardCfg.iconId)
      local classCfg = TurnedCardUtils.GetCardClassCfg(cardCfg.classType)
      GUIUtils.FillIcon(Img_Tpye:GetComponent("UITexture"), classCfg.smallIconId)
      Label_PowerLv:GetComponent("UILabel"):set_text(turnedCardInterface:getTurnedCardQualityStr(cardCfg.quality))
    end
  end
  if not isSelected then
    local firstCard = self.curCardList[1]
    if firstCard then
      local item = List:FindDirect("item_1")
      if item then
        item:GetComponent("UIToggle").value = true
      end
      self:onClick("item_1")
    else
      self:setCardInfoEmpty(true)
    end
  else
    self:setSelectedTurnedCardInfo()
  end
end
def.method().setScoreInfo = function(self)
  local Group_Title = self.m_node:FindDirect("Group_Right/Group_Title")
  local Label_Jing_Num = Group_Title:FindDirect("Group_Jing/Label_Num")
  local jingqiNum = ItemModule.Instance():GetCredits(TokenType.CHANGE_MODEL_CARD_ESSENCE) or Int64.new(0)
  Label_Jing_Num:GetComponent("UILabel"):set_text(tostring(jingqiNum))
  local Label_Score_Num = Group_Title:FindDirect("Group_Ji/Label_Num")
  local scoreNum = ItemModule.Instance():GetCredits(TokenType.CHANGE_MODEL_CARD_SCORE) or Int64.new(0)
  Label_Score_Num:GetComponent("UILabel"):set_text(tostring(scoreNum))
end
def.method().setCurUseCardInfo = function(self)
  local Group_CurUse = self.m_node:FindDirect("Group_Left/Group_CurUse")
  local Label_CardName = Group_CurUse:FindDirect("Label_CardName")
  local curCardId = TurnedCardInterface.Instance():getCurTurnedCardId()
  if curCardId > 0 then
    local level = TurnedCardInterface.Instance():getCurTurnedCardLevel()
    local cardName = TurnedCardUtils.GetTurnedCardDisPlayName(curCardId, level)
    Label_CardName:GetComponent("UILabel"):set_text(cardName)
  else
    Label_CardName:GetComponent("UILabel"):set_text(textRes.TurnedCard[30])
  end
end
def.method("boolean").setCardInfoEmpty = function(self, isEmpty)
  local Group_Right = self.m_node:FindDirect("Group_Right")
  local Group_Head = Group_Right:FindDirect("Group_Head")
  local Group_BaseAtt = Group_Right:FindDirect("Group_BaseAtt")
  local Group_Table = Group_Right:FindDirect("Group_Table")
  local Btn_Zone = Group_Right:FindDirect("Btn_Zone")
  local Btn_Upgrade = Group_Right:FindDirect("Btn_Upgrade")
  local Btn_Use = Group_Right:FindDirect("Btn_Use")
  local Group_NoData = Group_Right:FindDirect("Group_NoData")
  local isShow = not isEmpty
  Group_Head:SetActive(isShow)
  Group_BaseAtt:SetActive(isShow)
  Group_Table:SetActive(isShow)
  Btn_Zone:SetActive(isShow)
  Btn_Upgrade:SetActive(isShow)
  Btn_Use:SetActive(isShow)
  Group_NoData:SetActive(isEmpty)
end
def.method().setSelectedTurnedCardInfo = function(self)
  local curCard = self.curCardList[self.selectedIdx]
  if curCard == nil then
    return
  end
  self:setCardInfoEmpty(false)
  local turnedCardInterface = TurnedCardInterface.Instance()
  local Group_Right = self.m_node:FindDirect("Group_Right")
  local Group_Head = Group_Right:FindDirect("Group_Head")
  local Model_Card = Group_Head:FindDirect("Model_Card")
  local Label_Name = Group_Head:FindDirect("Label_Name")
  local Img_Tpye = Group_Head:FindDirect("Img_Tpye")
  local Label_PowerLv = Group_Head:FindDirect("Label_PowerLv")
  local Group_BaseAtt = Group_Right:FindDirect("Group_BaseAtt")
  local Label_Level = Group_BaseAtt:FindDirect("Group_Level/Label_Num")
  local Label_Cost = Group_BaseAtt:FindDirect("Group_Cost/Label_Num")
  local Label_Time = Group_BaseAtt:FindDirect("Group_Time/Label_Num")
  local Label_Att01 = Group_BaseAtt:FindDirect("Label_Att01")
  local Label_Att02 = Group_BaseAtt:FindDirect("Label_Att02")
  local Img_CardLevel = Group_Head:FindDirect("Img_CardLevel")
  local Img_CardLevelTitle = Group_Head:FindDirect("Img_CardLevelTitle")
  local info = curCard:getCardInfo()
  if info then
    local cardCfg = TurnedCardUtils.GetChangeModelCardCfg(info.card_cfg_id)
    self:fillSelectedModel(cardCfg.changeModelId)
    local classCfg = TurnedCardUtils.GetCardClassCfg(cardCfg.classType)
    local level = info.level
    local cardName = TurnedCardUtils.GetTurnedCardDisPlayName(info.card_cfg_id, level)
    Label_Name:GetComponent("UILabel"):set_text(cardName)
    GUIUtils.FillIcon(Img_Tpye:GetComponent("UITexture"), classCfg.iconId)
    Label_PowerLv:GetComponent("UILabel"):set_text(turnedCardInterface:getTurnedCardQualityStr(cardCfg.quality))
    Label_Level:GetComponent("UILabel"):set_text(cardCfg.useLevel)
    local cardLevelCfg = TurnedCardUtils.GetCardLevelCfg(info.card_cfg_id)
    Img_CardLevel:GetComponent("UISprite"):set_spriteName(TurnedCardUtils.TurnedCardModelFrame[level])
    Img_CardLevelTitle:GetComponent("UISprite"):set_spriteName(TurnedCardUtils.TurnedCardLevelTitle[level])
    local curLevelCfg = cardLevelCfg.cardLevels[level]
    Label_Cost:GetComponent("UILabel"):set_text(curLevelCfg.useCostEssence)
    if curLevelCfg.useCount > 0 then
      local leftNum = curLevelCfg.useCount - curCard:getCardUseCount()
      if leftNum < 0 then
        leftNum = 0
      end
      Label_Time:GetComponent("UILabel"):set_text(leftNum)
    else
      Label_Time:GetComponent("UILabel"):set_text(textRes.TurnedCard[24])
    end
    Label_Att01:GetComponent("UILabel"):set_text(string.format(textRes.TurnedCard[4], curLevelCfg.effectPersistMinute))
    Label_Att02:GetComponent("UILabel"):set_text(string.format(textRes.TurnedCard[5], curLevelCfg.effectPersistPVPFight))
    local Group_Table = Group_Right:FindDirect("Group_Table")
    local propertys = curLevelCfg.propertys
    for i = 1, 5 do
      local Img_Attribute = Group_Table:FindDirect(string.format("Img_Attribute%02d", i))
      if Img_Attribute then
        local Label_Attribute = Img_Attribute:FindDirect(string.format("Label_Attribute%02d", i))
        local Label_AttributeNum = Img_Attribute:FindDirect(string.format("Label_AttributeNum%02d", i))
        local curProperty = propertys[i]
        if curProperty then
          local propertyCfg = _G.GetCommonPropNameCfg(curProperty.propType)
          if propertyCfg then
            Img_Attribute:SetActive(true)
            Label_Attribute:GetComponent("UILabel"):set_text(propertyCfg.propName .. ":")
            if propertyCfg.valueType == ProValueType.TEN_THOUSAND_RATE then
              Label_AttributeNum:GetComponent("UILabel"):set_text("+" .. curProperty.value / 100 .. "%")
            else
              Label_AttributeNum:GetComponent("UILabel"):set_text("+" .. curProperty.value)
            end
          else
            Img_Attribute:SetActive(false)
            Label_Attribute:GetComponent("UILabel"):set_text("")
            Label_AttributeNum:GetComponent("UILabel"):set_text("")
          end
        else
          Img_Attribute:SetActive(false)
          Label_Attribute:GetComponent("UILabel"):set_text("")
          Label_AttributeNum:GetComponent("UILabel"):set_text("")
        end
      end
    end
    local classLevelCfg = TurnedCardUtils.GetClassLevelCfg(cardCfg.classType)
    local curLevelCfg = classLevelCfg.classLevels[level]
    local damageAddRates = curLevelCfg.damageAddRates
    local sealAddRates = curLevelCfg.sealAddRates
    local Group_Good = Group_Right:FindDirect("Group_Good")
    for i = 1, 3 do
      local Group_AttKe = Group_Table:FindDirect("Group_AttKe0" .. i)
      local Img_Tpye = Group_AttKe:FindDirect("Img_Tpye")
      local Label_Att = Group_AttKe:FindDirect("Label_Att")
      local damageAdd = damageAddRates[i]
      if damageAdd then
        Group_AttKe:SetActive(true)
        local classCfg = TurnedCardUtils.GetCardClassCfg(damageAdd.classType)
        GUIUtils.FillIcon(Img_Tpye:GetComponent("UITexture"), classCfg.smallIconId)
        local sealValue = sealAddRates[damageAdd.classType]
        local sealStr = ""
        if sealValue and sealValue > 0 then
          sealStr = "\n" .. textRes.TurnedCard[28] .. " +" .. sealValue / 100 .. "%"
        end
        Label_Att:GetComponent("UILabel"):set_text(textRes.TurnedCard[6] .. " +" .. damageAdd.value / 100 .. "%" .. sealStr)
      else
        Group_AttKe:SetActive(false)
      end
    end
    local Group_AttBeiKe = Group_Table:FindDirect("Group_AttBeiKe")
    local beRestrictedClasses = curLevelCfg.beRestrictedClasses
    for i = 1, 2 do
      local Img_Tpye = Group_AttBeiKe:FindDirect("Img_AttBeiKeTpye0" .. i)
      local beRestrictedClass = beRestrictedClasses[i]
      if beRestrictedClass then
        Img_Tpye:SetActive(true)
        local classCfg = TurnedCardUtils.GetCardClassCfg(beRestrictedClass)
        GUIUtils.FillIcon(Img_Tpye:GetComponent("UITexture"), classCfg.smallIconId)
      else
        Img_Tpye:SetActive(false)
      end
    end
    Group_Table:GetComponent("UITable"):Reposition()
  end
end
def.method("number").fillSelectedModel = function(self, changeModelId)
  if self._UIModelWrap == nil then
    local Model_Card = self.m_node:FindDirect("Group_Right/Group_Head/Model_Card")
    local uiModel = Model_Card:GetComponent("UIModel")
    uiModel.mCanOverflow = true
    self._UIModelWrap = UIModelWrap.new(uiModel)
  end
  local changeModelCfg = _G.GetModelChangeCfg(changeModelId)
  local modelId = changeModelCfg.modelId
  local modelinfo = DynamicData.GetRecord(CFG_PATH.DATA_MODEL_CONFIG, modelId)
  local headidx = DynamicRecord.GetIntValue(modelinfo, "halfBodyIconId")
  local iconRecord = DynamicData.GetRecord(CFG_PATH.DATA_ICONRES, headidx)
  if iconRecord == nil then
    warn("Icon res get nil record for id: ", headidx)
    return
  end
  local resourceType = iconRecord:GetIntValue("iconType")
  if resourceType == 1 then
    local resourcePath = iconRecord:GetStringValue("path")
    if resourcePath and resourcePath ~= "" then
      self._UIModelWrap:Load(resourcePath .. ".u3dext")
    else
      warn(" resourcePath == \"\" iconId = " .. headidx)
    end
  end
end
return TurnedCardNode.Commit()
