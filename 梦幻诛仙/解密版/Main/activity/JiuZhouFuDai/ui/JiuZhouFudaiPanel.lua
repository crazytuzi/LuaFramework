local MODULE_NAME = (...)
local Lplus = require("Lplus")
local ECPanelBase = require("GUI.ECPanelBase")
local GUIUtils = require("GUI.GUIUtils")
local ItemUtils = require("Main.Item.ItemUtils")
local ItemModule = require("Main.Item.ItemModule")
local EasyBasicItemTip = require("Main.Common.EasyBasicItemTip")
local CommonConfirmDlg = require("GUI.CommonConfirmDlg")
local ECSoundMan = require("Sound.ECSoundMan")
local MallUtility = require("Main.Mall.MallUtility")
local AwardUtils = require("Main.Award.AwardUtils")
local LuckyBagType = require("consts.mzm.gsp.luckybag.confbean.LuckyBagType")
local FuDaiUtils = require("Main.activity.JiuZhouFuDai.FuDaiUtils")
local FuDaiData = require("Main.activity.JiuZhouFuDai.data.FuDaiData")
local JiuZhouFuDaiMgr = require("Main.activity.JiuZhouFuDai.JiuZhouFuDaiMgr")
local JiuZhouFuDaiMgrInst = JiuZhouFuDaiMgr.Instance()
local JiuZhouFudaiPanel = Lplus.Extend(ECPanelBase, MODULE_NAME)
local def = JiuZhouFudaiPanel.define
local instance
def.static("=>", JiuZhouFudaiPanel).Instance = function()
  if instance == nil then
    instance = JiuZhouFudaiPanel()
  end
  return instance
end
def.field(EasyBasicItemTip).itemTipHelper = nil
def.field("table")._uiObjs = nil
def.field("number")._mapItemCfgId = 0
def.field("number")._mapItemInstId = 0
def.field("number")._drawType = 0
def.field("number")._fudaiType = 0
def.field("table")._fudaiCfg = nil
def.field("number")._useYuanbaoType = 0
def.field("table")._aniState = nil
def.field("boolean")._bOpened = false
def.method("number", "number", "number").ShowPanel = function(self, inst_id, cfg_id, fudai_type)
  if not JiuZhouFuDaiMgrInst:IsOpen() then
    self:DestroyPanel()
    return
  end
  if not JiuZhouFuDaiMgrInst:IsActOpen() then
    Toast(textRes.JiuZhouFuDai.SOpenLuckyBagFailed[-4])
    self:DestroyPanel()
    return
  end
  if self.m_panel and not self.m_panel.isnil and fudai_type <= 0 then
    self:DestroyPanel()
  end
  self._mapItemInstId = inst_id
  self._mapItemCfgId = cfg_id
  self._fudaiType = fudai_type
  self._fudaiCfg = FuDaiData.Instance():GetFuDaiCfgByType(fudai_type)
  if nil == self._fudaiCfg then
    warn("[JiuZhouFudaiPanel:ShowPanel] fudaiCfg nil for type:", fudai_type)
    return
  end
  self.m_TryIncLoadSpeed = true
  self:SetModal(true)
  self:CreatePanel(RESPATH.PREFAB_JIUZHOUFUDAI_PANEL, 1)
end
def.override().OnCreate = function(self)
  if self.m_panel == nil then
    return
  end
  self:_InitUI()
end
def.method()._InitUI = function(self)
  self.itemTipHelper = EasyBasicItemTip()
  self._uiObjs = {}
  self._uiObjs.Img_Title = self.m_panel:FindDirect("Img_Bg0/Img_Title")
  self._uiObjs.Img_Fudai = self.m_panel:FindDirect("Img_Bg0/Img_Fudai")
  self._uiObjs.Btn_Exchange = self.m_panel:FindDirect("Img_Bg0/Btn_Exchange")
  self._uiObjs.Btn_Help = self.m_panel:FindDirect("Img_Bg0/Btn_Help")
  self._uiObjs.fixAwardLabel = self.m_panel:FindDirect("Img_Bg0/Label_1")
  self._uiObjs.fixAwardGroup = self.m_panel:FindDirect("Img_Bg0/Img_ItemGet")
  self._uiObjs.fixAwardIcon = self._uiObjs.fixAwardGroup:FindDirect("Img_Icon")
  self._uiObjs.fixAwardNum = self._uiObjs.fixAwardGroup:FindDirect("Label_Number")
  self._uiObjs.Label_GetTips = self.m_panel:FindDirect("Img_Bg0/Label_GetTips")
  self._uiObjs.costItemLabel = self.m_panel:FindDirect("Img_Bg0/Label_2")
  self._uiObjs.costItemGroup = self.m_panel:FindDirect("Img_Bg0/Img_ItemCost")
  self._uiObjs.costItemIcon = self._uiObjs.costItemGroup:FindDirect("Img_ItemIcon")
  self._uiObjs.costItemNum = self._uiObjs.costItemGroup:FindDirect("Label_Number")
  self._uiObjs.costItemName = self._uiObjs.costItemGroup:FindDirect("Label_Name")
  self._uiObjs.Img_UseGold = self._uiObjs.costItemGroup:FindDirect("Img_UseGold")
  self._uiObjs.Img_UseGold10 = self._uiObjs.costItemGroup:FindDirect("Img_UseGold10")
  self._uiObjs.Label_Money = self._uiObjs.Img_UseGold:FindDirect("Group_Yuanbao/Label_Money")
  local Group_Item = self.m_panel:FindDirect("Img_Bg0/Group_Item")
  self._uiObjs.Items = {}
  for i = 1, 16 do
    self._uiObjs.Items[i] = Group_Item:FindDirect("Item" .. i)
  end
end
def.override("boolean").OnShow = function(self, isShow)
  self:_HandleEventListeners(isShow)
  if isShow then
    self:UpdateUI()
  end
end
def.override().OnDestroy = function(self)
  ItemModule.Instance():BlockItemGetEffect(false)
  require("Main.Item.ui.EasyUseDlg").Block(false)
  self._uiObjs = nil
  self.itemTipHelper = nil
  self._mapItemCfgId = 0
  self._fudaiCfg = nil
  self._drawType = 0
  self._fudaiType = 0
  self._useYuanbaoType = 0
  self._aniState = nil
  self._bOpened = false
end
def.method("=>", "number").GetMapItemInstId = function(self)
  return self._mapItemInstId
end
def.method().UpdateUI = function(self)
  self:UpdateTitleIcon()
  self:UpdateFudaiIcon()
  self:UpdateFixAward()
  self:UpdateCostItem()
  self:UpdateYuanBaoToggle()
  self:UpdateTurntable()
end
def.method().UpdateTitleIcon = function(self)
  GUIUtils.SetSprite(self._uiObjs.Img_Title, self._fudaiCfg.titleSpriteName)
  GUIUtils.SetActive(self._uiObjs.Btn_Exchange, self._fudaiType == LuckyBagType.BOX)
  GUIUtils.SetActive(self._uiObjs.Btn_Help, self._fudaiType == LuckyBagType.BOX)
end
def.method().UpdateFudaiIcon = function(self)
  local iconid
  if self._bOpened then
    local tween = self._uiObjs.Img_Fudai:GetComponent("TweenRotation")
    tween.enabled = false
    iconid = self._fudaiCfg.openedBagTexId
  else
    iconid = self._fudaiCfg.closedBagTexId
  end
  if iconid then
    GUIUtils.SetTexture(self._uiObjs.Img_Fudai, iconid)
  end
end
def.method().UpdateFixAward = function(self)
  GUIUtils.SetText(self._uiObjs.fixAwardLabel, self._fudaiCfg.topText)
  GUIUtils.SetText(self._uiObjs.Label_GetTips, self._fudaiCfg.midText)
  local itemId, count = FuDaiUtils.GetFixAwardInfo(self._fudaiType)
  local itemBase = ItemUtils.GetItemBase(itemId)
  if not itemBase then
    warn("[JiuZhouFudaiPanel:UpdateFixAward] itembase nil for itemid:", itemId)
    return
  end
  GUIUtils.SetTexture(self._uiObjs.fixAwardIcon, itemBase.icon)
  GUIUtils.SetSprite(self._uiObjs.fixAwardGroup, string.format("Cell_%02d", itemBase.namecolor))
  GUIUtils.SetText(self._uiObjs.fixAwardNum, count)
  self.itemTipHelper:RegisterItem2ShowTip(itemId, self._uiObjs.fixAwardGroup)
end
def.method().UpdateCostItem = function(self)
  GUIUtils.SetText(self._uiObjs.costItemLabel, self._fudaiCfg.bottumText)
  local itemId, need = FuDaiUtils.GetCostItemInfo(self._fudaiType, self._drawType)
  local itemBase = ItemUtils.GetItemBase(itemId)
  if not itemBase then
    warn("[JiuZhouFudaiPanel:UpdateCostItem] failed found item id ", itemId)
    return
  end
  GUIUtils.SetTexture(self._uiObjs.costItemIcon, itemBase.icon)
  GUIUtils.SetSprite(self._uiObjs.costItemGroup, string.format("Cell_%02d", itemBase.namecolor))
  local count = ItemModule.Instance():GetItemCountById(itemId)
  local textColor = need <= count and Color.green or Color.red
  GUIUtils.SetTextAndColor(self._uiObjs.costItemNum, count .. "/" .. need, textColor)
  GUIUtils.SetText(self._uiObjs.costItemName, itemBase.name)
  self.itemTipHelper:RegisterItem2ShowTip(itemId, self._uiObjs.costItemGroup)
end
def.method().UpdateYuanBaoToggle = function(self)
  if self._useYuanbaoType == JiuZhouFuDaiMgr.DrawType.SINGLE then
    self._uiObjs.Img_UseGold:GetComponent("UIToggle").value = true
    self._uiObjs.Img_UseGold10:GetComponent("UIToggle").value = false
  elseif self._useYuanbaoType == JiuZhouFuDaiMgr.DrawType.TEN then
    self._uiObjs.Img_UseGold:GetComponent("UIToggle").value = false
    self._uiObjs.Img_UseGold10:GetComponent("UIToggle").value = true
  else
    self._uiObjs.Img_UseGold:GetComponent("UIToggle").value = false
    self._uiObjs.Img_UseGold10:GetComponent("UIToggle").value = false
  end
  self._uiObjs.Label_Money:GetComponent("UILabel"):set_text(self:_GetNeedYuanbao())
end
def.method("=>", "number")._GetNeedYuanbao = function(self)
  local needYuanBao = 0
  if 0 >= self._useYuanbaoType then
    needYuanBao = 0
  else
    local itemId, needCount = FuDaiUtils.GetCostItemInfo(self._fudaiType, self._drawType)
    local haveCount = ItemModule.Instance():GetItemCountById(itemId)
    needCount = needCount - haveCount
    if needCount < 0 then
      needCount = 0
    end
    local price = MallUtility.GetPriceByItemId(itemId)
    needYuanBao = needCount * price
  end
  return needYuanBao
end
def.method().UpdateTurntable = function(self)
  local items = FuDaiUtils.GetTurntableItemInfos(self._fudaiType)
  for i = 1, #items do
    local item = items[i]
    local itemId = item.id
    local itemUI = self._uiObjs.Items[i]
    if itemUI then
      local itemBase = ItemUtils.GetItemBase(itemId)
      if not itemBase then
        warn("[JiuZhouFudaiPanel:UpdateTurntable] itembase nil for id ", itemId)
        return
      end
      local uiTexture = itemUI:FindDirect("Img_Icon"):GetComponent("UITexture")
      GUIUtils.FillIcon(uiTexture, itemBase.icon)
      local Img_Selected = itemUI:FindDirect("Img_Selected")
      Img_Selected:SetActive(false)
      self.itemTipHelper:RegisterItem2ShowTip(itemId, itemUI)
    end
  end
end
def.method().PlayDrawingAnimation = function(self)
  if self._aniState then
    return
  end
  local tween = self._uiObjs.Img_Fudai:GetComponent("TweenRotation")
  tween.enabled = true
  self._aniState = {
    timerId = 0,
    stopIndex = nil,
    finishcallback = nil
  }
  local jumpInterval = 0.01
  local maxInterval = 0.08
  local slowDownThrehold = 2
  local stopThreholdInterval = 0.08
  local intervalStep = 0.005
  local index = 1
  local timeCount = 0
  local startTime = GameUtil.GetTickCount()
  local function run(...)
    if self._aniState == nil then
      return
    end
    self._aniState.timerId = GameUtil.AddGlobalTimer(jumpInterval, true, function(...)
      if self.m_panel == nil or self.m_panel.isnil then
        return
      end
      local go = self._uiObjs.Items[index]
      if go == nil then
        index = 1
        go = self._uiObjs.Items[index]
      end
      if go then
        local curr = index - 1
        if curr < 1 then
          curr = #self._uiObjs.Items or curr
        end
        self._uiObjs.Items[curr]:FindDirect("Img_Selected"):SetActive(false)
        go:FindDirect("Img_Selected"):SetActive(true)
        ECSoundMan.Instance():Play2DSound(RESPATH.SOUND_ROUND)
        local curTime = GameUtil.GetTickCount()
        timeCount = (curTime - startTime) / 1000
        if timeCount > slowDownThrehold then
          jumpInterval = jumpInterval + intervalStep
          if jumpInterval >= maxInterval then
            jumpInterval = maxInterval
          end
          if index == self._aniState.stopIndex and jumpInterval >= stopThreholdInterval then
            self:FinishDrawingAnimation()
            return
          end
        end
        index = index + 1
        run()
      end
    end)
  end
  run()
end
def.method("number", "function").FinishDrawingAnimationInPos = function(self, index, callback)
  if self._aniState == nil then
    callback()
    return
  end
  self._aniState.stopIndex = index
  self._aniState.finishcallback = callback
end
def.method().FinishDrawingAnimation = function(self)
  local finishcallback
  if self._aniState then
    finishcallback = self._aniState.finishcallback
    local timerId = self._aniState.timerId
    if timerId and timerId ~= 0 then
      GameUtil.RemoveGlobalTimer(timerId)
    end
  end
  self._aniState = nil
  if finishcallback then
    finishcallback()
  end
end
def.method().AbortDrawingAnimation = function(self)
  if self._aniState then
    local timerId = self._aniState.timerId
    if timerId and timerId ~= 0 then
      GameUtil.RemoveGlobalTimer(timerId)
    end
  end
  self._aniState = nil
end
def.method("=>", "number").GetCurFudaiType = function(self)
  return self._fudaiType
end
def.method("userdata").onClickObj = function(self, obj)
  local id = obj.name
  if id == "Btn_Close" then
    self:OnBtn_Close()
  elseif id == "Img_UseGold" then
    self:OnUseYuanBaoClick()
  elseif id == "Img_UseGold10" then
    self:OnUse10YuanBaoClick()
  elseif id == "Btn_Open" then
    self:OnBtnDrawClick()
  elseif id == "Btn_Open10" then
    self:OnBtnDraw10Click()
  elseif id == "Btn_Exchange" then
    self:OnBtn_ExchangeClick()
  elseif string.find(id, "Item") == 1 or id == "Img_ItemCost" or id == "Img_ItemGet" then
    self.itemTipHelper:CheckItem2ShowTip(id, -1, true)
  elseif id == "Btn_Help" then
    self:OnBtn_Tip()
  end
end
def.method().OnBtn_Close = function(self)
  if self:IsAniEnd(true) then
    self:DestroyPanel()
  end
end
def.method("boolean", "=>", "boolean").IsAniEnd = function(self, bTip)
  local bEnd = self._aniState == nil
  if not bEnd then
    local text = textRes.JiuZhouFuDai[1]
    if self._fudaiType == LuckyBagType.BOX then
      text = string.format(text, textRes.JiuZhouFuDai[9])
    else
      text = string.format(text, textRes.JiuZhouFuDai[8])
    end
    Toast(text)
  end
  return bEnd
end
def.method().OnUseYuanBaoClick = function(self)
  if self._uiObjs.Img_UseGold:GetComponent("UIToggle").value then
    self._useYuanbaoType = JiuZhouFuDaiMgr.DrawType.SINGLE
    self._drawType = JiuZhouFuDaiMgr.DrawType.SINGLE
  else
    self._useYuanbaoType = 0
    self._drawType = 0
  end
  self:UpdateYuanBaoToggle()
  self:UpdateCostItem()
end
def.method().OnUse10YuanBaoClick = function(self)
  if self._uiObjs.Img_UseGold10:GetComponent("UIToggle").value then
    self._useYuanbaoType = JiuZhouFuDaiMgr.DrawType.TEN
    self._drawType = JiuZhouFuDaiMgr.DrawType.TEN
  else
    self._useYuanbaoType = 0
    self._drawType = 0
  end
  self:UpdateYuanBaoToggle()
  self:UpdateCostItem()
end
def.method().OnBtn_ExchangeClick = function(self)
  require("Main.activity.JiuZhouFuDai.ui.FuYuanExchangePanel").ShowDlg()
end
def.method().OnBtnDrawClick = function(self)
  self._drawType = JiuZhouFuDaiMgr.DrawType.SINGLE
  self:_DoDraw()
end
def.method().OnBtnDraw10Click = function(self)
  self._drawType = JiuZhouFuDaiMgr.DrawType.TEN
  self:_DoDraw()
end
def.method()._DoDraw = function(self)
  if not self:IsAniEnd(true) then
    return
  end
  ItemModule.Instance():BlockItemGetEffect(true)
  require("Main.Item.ui.EasyUseDlg").Block(true)
  local itemId, needCount = FuDaiUtils.GetCostItemInfo(self._fudaiType, self._drawType)
  local haveCount = ItemModule.Instance():GetItemCountById(itemId)
  local CurrencyFactory = require("Main.Currency.CurrencyFactory")
  local CurrencyType = require("consts.mzm.gsp.common.confbean.CurrencyType")
  local needNum = Int64.new(self:_GetNeedYuanbao())
  local moneyData = CurrencyFactory.Create(CurrencyType.YUAN_BAO)
  local haveNum = moneyData:GetHaveNum()
  if needCount > haveCount then
    if self._useYuanbaoType == self._drawType then
      local function OnConfirm(ret)
        if ret == 1 then
          if needNum > haveNum then
            moneyData:AcquireWithQuery()
            return
          end
          self:OpenLuckyBag(haveNum, needNum)
        end
      end
      CommonConfirmDlg.ShowConfirm("", string.format(textRes.JiuZhouFuDai[7], self:_GetNeedYuanbao()), OnConfirm, {})
    else
      local function OnConfirm(ret)
        if ret == 1 then
          self._useYuanbaoType = self._drawType
          self:UpdateYuanBaoToggle()
          self:UpdateCostItem()
        end
      end
      CommonConfirmDlg.ShowConfirm("", textRes.JiuZhouFuDai[2], OnConfirm, {})
    end
  else
    self:OpenLuckyBag(haveNum, needNum)
  end
end
def.method("userdata", "userdata").OpenLuckyBag = function(self, haveNum, needNum)
  local FuDaiProtocols = require("Main.activity.JiuZhouFuDai.FuDaiProtocols")
  if self._drawType == JiuZhouFuDaiMgr.DrawType.SINGLE then
    FuDaiProtocols.SendCOpenLuckyBag(self._mapItemInstId, self._useYuanbaoType > 0 and 1 or 0, haveNum, needNum)
    JiuZhouFuDaiMgrInst:SetServerState(true)
  elseif self._drawType == JiuZhouFuDaiMgr.DrawType.TEN then
    FuDaiProtocols.SendCOpenMultipleLuckyBag(self._mapItemInstId, self._useYuanbaoType > 0 and 1 or 0, haveNum, needNum)
    JiuZhouFuDaiMgrInst:SetServerState(true)
  else
    warn("[ERROR][FuDaiUtils:OpenLuckyBag] unknown drawType:", drawType)
  end
end
def.static("table").OnSOpenLuckyBagSuccess = function(p)
  warn("[JiuZhouFudaiPanel:OnSOpenLuckyBagSuccess] p.instanceid, p.use_yuanbao : ", p.instanceid, p.use_yuanbao)
  JiuZhouFuDaiMgrInst:SetServerState(false)
  if not instance then
    warn("[JiuZhouFudaiPanel:OnSOpenLuckyBagSuccess] return on instance nil.")
    return
  end
  if instance.m_panel == nil or instance.m_panel.isnil then
    warn("[JiuZhouFudaiPanel:OnSOpenLuckyBagSuccess] return on instance.m_panel == nil or instance.m_panel.isnil, instance.m_panel:", instance.m_panel)
    return
  end
  instance:PlayDrawingAnimation()
  instance:FinishDrawingAnimationInPos(p.index + 1, function(...)
    instance._bOpened = true
    instance:UpdateFudaiIcon()
    if p.award_items then
      AwardUtils.Check2NoticeAward(p.award_items)
    end
    if p.items then
      AwardUtils.Check2NoticeAward(p.items)
    end
    ItemModule.Instance():BlockItemGetEffect(false)
    require("Main.Item.ui.EasyUseDlg").Block(false)
    local p = require("netio.protocol.mzm.gsp.luckybag.CAwardFinish").new(instance._mapItemCfgId)
    gmodule.network.sendProtocol(p)
  end)
end
def.static("table").OnSOpenLuckyBagFailed = function(p)
  ItemModule.Instance():BlockItemGetEffect(false)
  require("Main.Item.ui.EasyUseDlg").Block(false)
  JiuZhouFuDaiMgrInst:SetServerState(false)
  if not JiuZhouFudaiPanel.Instance():IsShow() then
    return
  end
  if retcode == -3 or retcode == -4 then
    instance:DestroyPanel()
  end
end
def.static("table").OnSOpenMultipleLuckyBagSuccess = function(p)
  warn("[JiuZhouFudaiPanel:OnSOpenMultipleLuckyBagSuccess] p.instanceid, p.use_yuanbao : ", p.instanceid, p.use_yuanbao)
  JiuZhouFuDaiMgrInst:SetServerState(false)
  if not instance then
    warn("[JiuZhouFudaiPanel:OnSOpenMultipleLuckyBagSuccess] return on instance nil.")
    return
  end
  if instance.m_panel == nil or instance.m_panel.isnil then
    warn("[JiuZhouFudaiPanel:OnSOpenMultipleLuckyBagSuccess] return on instance.m_panel == nil or instance.m_panel.isnil, instance.m_panel:", instance.m_panel)
    return
  end
  instance._bOpened = true
  instance:UpdateFudaiIcon()
  local p = require("netio.protocol.mzm.gsp.luckybag.CAwardFinish").new(instance._mapItemCfgId)
  gmodule.network.sendProtocol(p)
end
def.method().OnBtn_Tip = function(self)
  local tipContent = require("Main.Common.TipsHelper").GetHoverTip(self._fudaiCfg.tipId)
  local CommonUITipsDlg = require("GUI.CommonUITipsDlg")
  CommonUITipsDlg.Instance():ShowDlg(tipContent, {x = 0, y = 0})
end
def.method("boolean")._HandleEventListeners = function(self, isRigister)
  local eventFunc
  if isRigister then
    eventFunc = Event.RegisterEvent
  else
    eventFunc = Event.UnregisterEvent
  end
  if eventFunc then
    eventFunc(ModuleId.ITEM, gmodule.notifyId.item.Item_OnBagInfoSynchronized, JiuZhouFudaiPanel.OnBagInfoSynchronized)
    eventFunc(ModuleId.FEATURE, gmodule.notifyId.Feature.FeatureOpenChange, JiuZhouFudaiPanel.OnFunctionOpenChange)
  end
end
def.static("table", "table").OnBagInfoSynchronized = function()
  if not JiuZhouFudaiPanel.Instance():IsShow() then
    return
  end
  instance:UpdateCostItem()
  instance:UpdateYuanBaoToggle()
end
def.static("table", "table").OnFunctionOpenChange = function()
  if not JiuZhouFudaiPanel.Instance():IsShow() then
    return
  end
  local Feature = require("netio.protocol.mzm.gsp.open.ModuleFunSwitchInfo")
  if p1 and p1.feature == Feature.TYPE_LUCKY_BAG then
    local bOpen = JiuZhouFuDaiMgrInst:IsOpen()
    if not bOpen then
      self:DestroyPanel()
    end
  end
end
return JiuZhouFudaiPanel.Commit()
