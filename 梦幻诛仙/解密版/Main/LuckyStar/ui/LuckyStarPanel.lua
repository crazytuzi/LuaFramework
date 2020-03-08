local Lplus = require("Lplus")
local ECPanelBase = require("GUI.ECPanelBase")
local LuckyStarPanel = Lplus.Extend(ECPanelBase, "LuckyStarPanel")
local GUIUtils = require("GUI.GUIUtils")
local LuckyStarMgr = require("Main.LuckyStar.mgr.LuckyStarMgr")
local LuckyStarUtils = require("Main.LuckyStar.LuckyStarUtils")
local ItemUtils = require("Main.Item.ItemUtils")
local ItemTipsMgr = require("Main.Item.ItemTipsMgr")
local Vector = require("Types.Vector")
local def = LuckyStarPanel.define
local instance
def.field("table").uiObjs = nil
def.static("=>", LuckyStarPanel).Instance = function()
  if instance == nil then
    instance = LuckyStarPanel()
  end
  return instance
end
def.method().ShowPanel = function(self)
  if self.m_panel ~= nil then
    return
  end
  self:CreatePanel(RESPATH.PREFAB_LUCKY_STAR_PANEL, 1)
  self:SetModal(true)
end
def.override().OnCreate = function(self)
  self:InitUI()
  self:SetLuckyStarConditions()
  self:SetLuckyStarAwards()
  self:ResetAwardPosition()
  if LuckyStarMgr.Instance():HasDrawLuckyStar() then
    self:ShowLuckyStarAward()
  else
    self:ShowDrawLuckyStar()
  end
  Event.RegisterEvent(ModuleId.LUCKYSTAR, gmodule.notifyId.LuckyStar.BUY_LUCKYSTAR_SUCCESS, LuckyStarPanel.OnBuyLuckyStarSuccess)
  Event.RegisterEvent(ModuleId.LUCKYSTAR, gmodule.notifyId.LuckyStar.LUCKYSTAR_STATUS_CHANGE, LuckyStarPanel.OnLuckyStarStatusChange)
  Event.RegisterEvent(ModuleId.LUCKYSTAR, gmodule.notifyId.LuckyStar.DRAW_LUCKYSTAR, LuckyStarPanel.OnDrawLuckyStar)
  Event.RegisterEvent(ModuleId.ACTIVITY, gmodule.notifyId.activity.Activity_Active_Changed, LuckyStarPanel.OnActiveChanged)
end
def.override().OnDestroy = function(self)
  self.uiObjs = nil
  Event.UnregisterEvent(ModuleId.LUCKYSTAR, gmodule.notifyId.LuckyStar.BUY_LUCKYSTAR_SUCCESS, LuckyStarPanel.OnBuyLuckyStarSuccess)
  Event.UnregisterEvent(ModuleId.LUCKYSTAR, gmodule.notifyId.LuckyStar.LUCKYSTAR_STATUS_CHANGE, LuckyStarPanel.OnLuckyStarStatusChange)
  Event.UnregisterEvent(ModuleId.LUCKYSTAR, gmodule.notifyId.LuckyStar.DRAW_LUCKYSTAR, LuckyStarPanel.OnDrawLuckyStar)
  Event.UnregisterEvent(ModuleId.ACTIVITY, gmodule.notifyId.activity.Activity_Active_Changed, LuckyStarPanel.OnActiveChanged)
end
def.method().InitUI = function(self)
  self.uiObjs = {}
  self.uiObjs.Group_Buy = self.m_panel:FindDirect("Group_Buy")
  self.uiObjs.Group_Try = self.m_panel:FindDirect("Group_Try")
  self.uiObjs.Group_Tips = self.m_panel:FindDirect("Group_Tips")
  GUIUtils.SetActive(self.uiObjs.Group_Tips, false)
end
def.method().SetLuckyStarConditions = function(self)
  local Label_ActNum = self.uiObjs.Group_Buy:FindDirect("Group_Act/Label_ActNum")
  local curActiveNum = require("Main.activity.ActivityInterface").Instance():GetCurActive()
  local needActiveNum = constant.CLuckyStarConsts.LUCKY_STAR_BUY_NEED_ACTIVE_VALUE
  if curActiveNum < needActiveNum then
    GUIUtils.SetText(Label_ActNum, string.format(textRes.LuckyStar[12], curActiveNum, needActiveNum))
  else
    GUIUtils.SetText(Label_ActNum, string.format(textRes.LuckyStar[13], curActiveNum, needActiveNum))
  end
end
def.method().SetLuckyStarAwards = function(self)
  local Group_Items = self.uiObjs.Group_Buy:FindDirect("Scroll View/Group_Items")
  local Label_Time = self.uiObjs.Group_Buy:FindDirect("Label_Time")
  local awardTemplate = Group_Items:FindDirect("Img_Item")
  GUIUtils.SetActive(awardTemplate, false)
  local activityId = LuckyStarMgr.Instance():GetLuckyStarActivityId()
  local activityInfo = require("Main.activity.ActivityInterface").GetActivityCfgById(activityId)
  if activityInfo ~= nil then
    GUIUtils.SetText(Label_Time, string.format(textRes.LuckyStar[4], activityInfo.timeDes))
  else
    GUIUtils.SetText(Label_Time, "")
    warn("lucky star activity not exist:" .. activityId)
  end
  local awards = LuckyStarMgr.Instance():GetLuckyStarAwards()
  local showAwardCount = #awards
  for i = 1, showAwardCount do
    local awardItem = Group_Items:FindDirect("Img_Item" .. i)
    if awardItem == nil then
      awardItem = GameObject.Instantiate(awardTemplate)
      awardItem.name = "Img_Item" .. i
      awardItem.transform.parent = Group_Items.transform
      awardItem.transform.localScale = Vector.Vector3.one
    end
    GUIUtils.SetActive(awardItem, true)
    self:SetLuckyStarAwardInfo(awardItem, awards[i])
  end
  local unusedIdx = showAwardCount + 1
  while true do
    local awardItem = Group_Items:FindDirect("Img_Item" .. unusedIdx)
    if _G.IsNil(awardItem) then
      break
    end
    GUIUtils.SetActive(awardItem, false)
    unusedIdx = unusedIdx + 1
  end
  Group_Items:GetComponent("UIGrid"):Reposition()
end
def.method().ResetAwardPosition = function(self)
  GameUtil.AddGlobalTimer(0, true, function()
    if self.uiObjs == nil then
      return
    end
    local ScrollView = self.uiObjs.Group_Buy:FindDirect("Scroll View")
    ScrollView:GetComponent("UIScrollView"):ResetPosition()
  end)
end
def.method("userdata", "table").SetLuckyStarAwardInfo = function(self, item, award)
  local Btn_Buy = item:FindDirect("Btn_Buy")
  local Btn_NoItem = item:FindDirect("Btn_NoItem")
  local Label_Limit = item:FindDirect("Label_Limit")
  local Bg_Item = item:FindDirect("Bg_Item")
  local Label_Num = Bg_Item:FindDirect("Label_Num")
  local Texture = Bg_Item:FindDirect("Texture")
  local Img_Zhe = item:FindDirect("Img_Zhe")
  local Label_Zhe = Img_Zhe:FindDirect("Label")
  local awardItem
  local luckyStarInfo = LuckyStarUtils.GetLuckyStarAwardInfoById(award.lucky_star_gift_cfg_id)
  if luckyStarInfo == nil then
    GUIUtils.SetActive(item, false)
    return
  end
  if luckyStarInfo.awardItem ~= nil then
    awardItem = ItemUtils.GetItemBase(luckyStarInfo.awardItem.itemId)
    GUIUtils.FillIcon(Texture:GetComponent("UITexture"), awardItem.icon)
    GUIUtils.SetText(Label_Num, luckyStarInfo.awardItem.num)
  else
    GUIUtils.FillIcon(Texture:GetComponent("UITexture"), 0)
    GUIUtils.SetText(Label_Num, 0)
  end
  if luckyStarInfo.sale_rate == 0 then
    GUIUtils.SetText(Label_Zhe, textRes.LuckyStar[3])
  else
    GUIUtils.SetText(Label_Zhe, string.format(textRes.LuckyStar[1], luckyStarInfo.sale_rate / 10000 * 100 / 10))
  end
  GUIUtils.SetText(Label_Limit, string.format(textRes.LuckyStar[2], award.has_buy_times, luckyStarInfo.buy_top_limit))
  if luckyStarInfo.awardItem ~= nil and award.has_buy_times < luckyStarInfo.buy_top_limit then
    GUIUtils.SetActive(Btn_Buy, true)
    GUIUtils.SetActive(Btn_NoItem, false)
    local Label_NewNum = Btn_Buy:FindDirect("Label_NewNum")
    local Label_OldNum = Btn_Buy:FindDirect("Label_OldNum")
    local Img_Money = Btn_Buy:FindDirect("Img_Money")
    GUIUtils.SetText(Label_OldNum, luckyStarInfo.base_price)
    local price = math.floor(luckyStarInfo.base_price * luckyStarInfo.sale_rate / 10000)
    if price > 0 then
      GUIUtils.SetText(Label_NewNum, price)
    else
      GUIUtils.SetText(Label_NewNum, textRes.LuckyStar[3])
    end
    local CurrencyFactory = require("Main.Currency.CurrencyFactory")
    local moneyData = CurrencyFactory.Create(luckyStarInfo.cost_currency_type)
    GUIUtils.SetSprite(Img_Money, moneyData:GetSpriteName())
  else
    GUIUtils.SetActive(Btn_Buy, false)
    GUIUtils.SetActive(Btn_NoItem, true)
  end
end
def.method("number").UpdateLuckyStarAwardInfoByCfgId = function(self, cfgId)
  local idx = LuckyStarMgr.Instance():GetLuckyStarAwardIndex(cfgId)
  local awards = LuckyStarMgr.Instance():GetLuckyStarAwards()
  local Group_Items = self.uiObjs.Group_Buy:FindDirect("Scroll View/Group_Items")
  local awardItem = Group_Items:FindDirect("Img_Item" .. idx)
  if awardItem ~= nil and awards[idx] ~= nil then
    self:SetLuckyStarAwardInfo(awardItem, awards[idx])
  end
end
def.method().ShowDrawLuckyStar = function(self)
  GUIUtils.SetActive(self.uiObjs.Group_Try, true)
  GUIUtils.SetActive(self.uiObjs.Group_Buy, false)
end
def.method().ShowLuckyStarAward = function(self)
  GUIUtils.SetActive(self.uiObjs.Group_Try, false)
  GUIUtils.SetActive(self.uiObjs.Group_Buy, true)
end
def.method("userdata").onClickObj = function(self, obj)
  local id = obj.name
  if id == "Texture" then
    local awardItem = obj.parent.parent.name
    local awardIndx = tonumber(string.sub(awardItem, #"Img_Item" + 1))
    if awardIndx ~= nil then
      self:OnClickAwardIcon(awardIndx, obj)
    end
  elseif id == "Btn_Buy" then
    if obj.parent.name == "Group_Try" then
      self:OnClickBtnDrawLuckyStar()
    else
      local awardItem = obj.parent.name
      local awardIndx = tonumber(string.sub(awardItem, #"Img_Item" + 1))
      if awardIndx ~= nil then
        self:OnClickBtnBuyAward(awardIndx)
      end
    end
    local ECMSDK = require("ProxySDK.ECMSDK")
    ECMSDK.SendTLogToServer(_G.TLOGTYPE.LUCKYSTAR, {1})
  else
    self:onClick(id)
  end
end
def.method("number", "userdata").OnClickAwardIcon = function(self, index, source)
  local awards = LuckyStarMgr.Instance():GetLuckyStarAwards()
  if awards[index] == nil then
    warn("no award at index:" .. index)
    return
  end
  local luckyStarInfo = LuckyStarUtils.GetLuckyStarAwardInfoById(awards[index].lucky_star_gift_cfg_id)
  if luckyStarInfo == nil then
    warn("no lucky star info:" .. awards[index].lucky_star_gift_cfg_id)
    return
  end
  if luckyStarInfo.awardItem == nil then
    warn("lucky star award has no item:" .. awards[index].lucky_star_gift_cfg_id)
    return
  end
  ItemTipsMgr.Instance():ShowBasicTipsWithGO(luckyStarInfo.awardItem.itemId, source, 0, false)
end
def.method("number").OnClickBtnBuyAward = function(self, index)
  local awards = LuckyStarMgr.Instance():GetLuckyStarAwards()
  if awards[index] == nil then
    warn("no award at index:" .. index)
    return
  end
  local luckyStarInfo = LuckyStarUtils.GetLuckyStarAwardInfoById(awards[index].lucky_star_gift_cfg_id)
  if luckyStarInfo == nil then
    warn("no lucky star info:" .. awards[index].lucky_star_gift_cfg_id)
    return
  end
  if luckyStarInfo.awardItem == nil then
    warn("lucky star award has no item:" .. awards[index].lucky_star_gift_cfg_id)
    return
  end
  if awards[index].has_buy_times >= luckyStarInfo.buy_top_limit then
    Toast(textRes.LuckyStar[5])
    return
  end
  if not self:CheckActiveNumAndToast() then
    return
  end
  local price = math.floor(luckyStarInfo.base_price * luckyStarInfo.sale_rate / 10000)
  require("Main.LuckyStar.ui.LuckyStarConfirmPanel").Instance():ShowBuyConfirmPanel(luckyStarInfo.awardItem.itemId, luckyStarInfo.awardItem.num, luckyStarInfo.cost_currency_type, price, luckyStarInfo.buy_top_limit - awards[index].has_buy_times, function(count)
    local CurrencyFactory = require("Main.Currency.CurrencyFactory")
    local moneyData = CurrencyFactory.Create(luckyStarInfo.cost_currency_type)
    local needNum = math.floor(luckyStarInfo.base_price * luckyStarInfo.sale_rate / 10000) * count
    if Int64.lt(moneyData:GetHaveNum(), needNum) then
      moneyData:AcquireWithQuery()
    else
      if not self:CheckActiveNumAndToast() then
        return
      end
      LuckyStarMgr.Instance():BuyLuckyStar(luckyStarInfo.id, count, moneyData:GetHaveNum())
    end
  end)
end
def.method("=>", "boolean").CheckActiveNumAndToast = function(self)
  local curActiveNum = require("Main.activity.ActivityInterface").Instance():GetCurActive()
  local needActiveNum = constant.CLuckyStarConsts.LUCKY_STAR_BUY_NEED_ACTIVE_VALUE
  if curActiveNum < needActiveNum then
    Toast(string.format(textRes.LuckyStar[14], needActiveNum))
    return false
  end
  return true
end
def.method().OnClickBtnDrawLuckyStar = function(self)
  LuckyStarMgr.Instance():DrawLuckyStar()
end
def.method("string").onClick = function(self, id)
  if id == "Btn_Close" then
    self:DestroyPanel()
  elseif id == "Btn_NoItem" then
    self:OnClickBtnNoItem()
  elseif id == "Btn_Tip" then
    self:OnClickBtnTips()
  end
end
def.method().OnClickBtnNoItem = function(self)
  Toast(textRes.LuckyStar[5])
end
def.method().OnClickBtnTips = function(self)
  require("GUI.GUIUtils").ShowHoverTip(constant.CLuckyStarConsts.LUCKY_STAR_HELP_DESCRIPTION)
  local ECMSDK = require("ProxySDK.ECMSDK")
  ECMSDK.SendTLogToServer(_G.TLOGTYPE.LUCKYSTAR, {2})
end
def.static("table", "table").OnBuyLuckyStarSuccess = function(params, context)
  local luckyStarCfgId = params.luckyStarCfgId
  local self = instance
  if self ~= nil and luckyStarCfgId ~= nil then
    self:UpdateLuckyStarAwardInfoByCfgId(luckyStarCfgId)
  end
end
def.static("table", "table").OnLuckyStarStatusChange = function(params, context)
  local self = instance
  if self ~= nil then
    local LuckyStarModule = require("Main.LuckyStar.LuckyStarModule")
    if not LuckyStarModule.Instance():IsLuckyStarOpened() then
      self:DestroyPanel()
      Toast(textRes.LuckyStar[10])
    end
  end
end
def.static("table", "table").OnDrawLuckyStar = function(params, context)
  local self = instance
  if self ~= nil then
    self:ShowLuckyStarAward()
  end
end
def.static("table", "table").OnActiveChanged = function(params, context)
  local self = instance
  if self ~= nil then
    self:SetLuckyStarConditions()
  end
end
LuckyStarPanel.Commit()
return LuckyStarPanel
