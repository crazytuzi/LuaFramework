local Lplus = require("Lplus")
local ECPanelBase = require("GUI.ECPanelBase")
local DragonBaoKuPanel = Lplus.Extend(ECPanelBase, "DragonBaoKuPanel")
local ItemTipsMgr = require("Main.Item.ItemTipsMgr")
local GUIUtils = require("GUI.GUIUtils")
local ItemUtils = require("Main.Item.ItemUtils")
local DragonBaoKuMgr = require("Main.activity.DragonBaoKu.DragonBaoKuMgr")
local TokenType = require("consts.mzm.gsp.item.confbean.TokenType")
local ItemModule = Lplus.ForwardDeclare("ItemModule")
local CommonConfirmDlg = require("GUI.CommonConfirmDlg")
local NumberScroll = require("Main.AllLotto.ui.NumberScroll")
local def = DragonBaoKuPanel.define
local instance
local MAX_DIGITAL = 7
local MAX_GRIDNUM = constant.CDrawCarnivalConsts.AWARD_POOL_GRID_COUNT
local SlowAheadNum = constant.CDrawCarnivalConsts.SLOW_DOWN_STEP_COUNT
local SlowRoundNum = constant.CDrawCarnivalConsts.DRAW_EFFECT_CIRCLE_COUNT_MIN
local CacheMaxNum = 3
def.field("table").uiObjs = nil
def.field("number")._sign = 1
def.field("number").passType = 1
def.field("number").roundNum = 0
def.field("number").playGradAllNum = 0
def.field("number").slowStartNum = 0
def.field("table").awardInfo = nil
def.field("boolean").isAutoUse = false
def.field("table").m_scrollNumbers = nil
def.field("number").scrollCount = 0
def.field("boolean").isScroll = false
def.field("userdata").curYuanBao = nil
def.field("userdata").lastYuanBao = nil
def.field("table").yuanbaoQueue = nil
def.field("number").nextScrollTimerId = 0
def.field("number").timerId = 0
local Select_Frame = {
  "Img_SelectYellow",
  "Img_SelectGreen",
  "Img_SelectBlue"
}
def.static("=>", DragonBaoKuPanel).Instance = function()
  if instance == nil then
    instance = DragonBaoKuPanel()
  end
  return instance
end
def.method("number").ShowPanelByItem = function(self, itemId)
  local passItemCfg = DragonBaoKuMgr.GetOrigDrawCarnivalPassItemCfg(itemId)
  if passItemCfg then
    self.passType = passItemCfg.passTypeId
  end
  self:ShowPanel()
end
def.method().ShowPanel = function(self)
  if self:IsShow() then
    return
  end
  self:CreatePanel(RESPATH.PREFAB_RANDOM_PRIZE_DRAGON_BAO_KU, 1)
  self:SetModal(true)
end
def.override().OnCreate = function(self)
  self:initUI()
  self.m_scrollNumbers = {}
  local idGroup = self.m_panel:FindDirect("Group_Items/Bg_YuanBaoNum/Group_Id/Scrollview_Id/Grid")
  for i = 0, MAX_DIGITAL do
    local uiGo = idGroup:FindDirect(string.format("Group_Id_%d", i))
    self.m_scrollNumbers[i] = NumberScroll.New(uiGo)
  end
  Event.RegisterEvent(ModuleId.ACTIVITY, gmodule.notifyId.activity.ACTIVITY_DRAGON_BAOKU_LOTTERY_INFO, DragonBaoKuPanel.OnLotteryInfo)
  Event.RegisterEvent(ModuleId.ITEM, gmodule.notifyId.item.Item_Yuanbao_AwardChanged, DragonBaoKuPanel.OnCostInfoChange)
  Event.RegisterEvent(ModuleId.ITEM, gmodule.notifyId.item.Item_Yuanbao_BuyChanged, DragonBaoKuPanel.OnCostInfoChange)
  Event.RegisterEvent(ModuleId.ITEM, gmodule.notifyId.item.Item_Credit_Change, DragonBaoKuPanel.OnCostInfoChange)
  Event.RegisterEvent(ModuleId.ACTIVITY, gmodule.notifyId.activity.ACTIVITY_DRAGON_BAOKU_POOL_YUANBAO_CHANGE, DragonBaoKuPanel.OnPoolYuanbaoChange)
  Event.RegisterEvent(ModuleId.ITEM, gmodule.notifyId.item.Item_OnBagInfoSynchronized, DragonBaoKuPanel.OnCostInfoChange)
  Event.RegisterEvent(ModuleId.ACTIVITY, gmodule.notifyId.activity.ACTIVITY_DRAGON_BAOKU_NOTIFY_CHANGE, DragonBaoKuPanel.OnNotifyChange)
  Event.RegisterEvent(ModuleId.ACTIVITY, gmodule.notifyId.activity.ACTIVITY_DRAGON_BAOKU_BIG_AWARD, DragonBaoKuPanel.OnUpdateLastWinerInfo)
  Event.RegisterEvent(ModuleId.ACTIVITY, gmodule.notifyId.activity.ACTIVITY_DRAGON_BAOKU_BOX_AWARD, DragonBaoKuPanel.OnUpdateLastWinerInfo)
end
def.override().OnDestroy = function(self)
  if self.m_scrollNumbers then
    for i, v in pairs(self.m_scrollNumbers) do
      v:ClearTimer()
    end
  end
  self.m_scrollNumbers = nil
  Event.UnregisterEvent(ModuleId.ACTIVITY, gmodule.notifyId.activity.ACTIVITY_DRAGON_BAOKU_LOTTERY_INFO, DragonBaoKuPanel.OnLotteryInfo)
  Event.UnregisterEvent(ModuleId.ITEM, gmodule.notifyId.item.Item_Yuanbao_AwardChanged, DragonBaoKuPanel.OnCostInfoChange)
  Event.UnregisterEvent(ModuleId.ITEM, gmodule.notifyId.item.Item_Yuanbao_BuyChanged, DragonBaoKuPanel.OnCostInfoChange)
  Event.UnregisterEvent(ModuleId.ITEM, gmodule.notifyId.item.Item_Credit_Change, DragonBaoKuPanel.OnCostInfoChange)
  Event.UnregisterEvent(ModuleId.ACTIVITY, gmodule.notifyId.activity.ACTIVITY_DRAGON_BAOKU_POOL_YUANBAO_CHANGE, DragonBaoKuPanel.OnPoolYuanbaoChange)
  Event.UnregisterEvent(ModuleId.ITEM, gmodule.notifyId.item.Item_OnBagInfoSynchronized, DragonBaoKuPanel.OnCostInfoChange)
  Event.UnregisterEvent(ModuleId.ACTIVITY, gmodule.notifyId.activity.ACTIVITY_DRAGON_BAOKU_NOTIFY_CHANGE, DragonBaoKuPanel.OnNotifyChange)
  Event.UnregisterEvent(ModuleId.ACTIVITY, gmodule.notifyId.activity.ACTIVITY_DRAGON_BAOKU_BIG_AWARD, DragonBaoKuPanel.OnUpdateLastWinerInfo)
  Event.UnregisterEvent(ModuleId.ACTIVITY, gmodule.notifyId.activity.ACTIVITY_DRAGON_BAOKU_BOX_AWARD, DragonBaoKuPanel.OnUpdateLastWinerInfo)
end
def.static("table", "table").OnLotteryInfo = function(p1, p2)
  if instance and instance:IsShow() then
    local dragonBaoKuResultPanel = require("Main.activity.DragonBaoKu.ui.DragonBaoKuResultPanel").Instance()
    if dragonBaoKuResultPanel:IsShow() then
      return
    end
    local count = p1.passCount
    local awardInfo = p1.awardInfo
    if count == 1 then
      local targetIdx
      for i, v in ipairs(awardInfo[1].draw_award_info_list) do
        if targetIdx == nil or targetIdx > v.index then
          targetIdx = v.index
        end
      end
      instance.awardInfo = awardInfo
      instance:startPlayEffect(targetIdx + 1)
      instance:setBtnState()
    else
      dragonBaoKuResultPanel:ShowPanel(awardInfo)
    end
  end
end
def.static("table", "table").OnCostInfoChange = function(p1, p2)
  if instance and instance:IsShow() then
    instance:setCostInfo()
  end
end
def.static("table", "table").OnPoolYuanbaoChange = function(p1, p2)
  if instance and instance:IsShow() then
    local dragonBaoKuMgr = DragonBaoKuMgr.Instance()
    local lastYuanbaoNum = dragonBaoKuMgr:getLastPoolYuanbaoNum()
    local curYuanBaoNum = dragonBaoKuMgr:getPoolYuanbaoNum()
    local t = {last = lastYuanbaoNum, cur = curYuanBaoNum}
    instance.yuanbaoQueue = instance.yuanbaoQueue or {}
    if #instance.yuanbaoQueue >= CacheMaxNum then
      table.remove(instance.yuanbaoQueue, 1)
    end
    table.insert(instance.yuanbaoQueue, t)
    if not instance.isScroll then
      if instance.nextScrollTimerId ~= 0 then
        GameUtil.RemoveGlobalTimer(instance.nextScrollTimerId)
        instance.nextScrollTimerId = 0
      end
      instance:startScroll()
    end
  end
end
def.static("table", "table").OnNotifyChange = function(p1, p2)
  if instance and instance:IsShow() then
    instance:updateToggleEffect()
    instance:setBtnState()
  end
end
def.static("table", "table").OnUpdateLastWinerInfo = function(p1, p2)
  if instance and instance:IsShow() then
    instance:setLastWinnerInfo()
  end
end
def.override("boolean").OnShow = function(self, b)
  if b then
    self:setItemList()
    self:setBtnState()
    self:setPoolYuanBaoNum()
    self:setLastWinnerInfo()
    self:setSelectedToggle()
    self:setCostInfo()
    self:updateToggleEffect()
  else
    if self.timerId ~= 0 then
      GameUtil.RemoveGlobalTimer(self.timerId)
      self.timerId = 0
    end
    if self.nextScrollTimerId ~= 0 then
      GameUtil.RemoveGlobalTimer(self.nextScrollTimerId)
      self.nextScrollTimerId = 0
    end
    self.isScroll = false
    self.yuanbaoQueue = nil
    self.curYuanBao = nil
  end
end
def.method().Hide = function(self)
  self:DestroyPanel()
end
def.method("userdata").onClickObj = function(self, clickObj)
  local id = clickObj.name
  warn("-------DragonBaoKuPanel clickObj:", id)
  local strs = string.split(id, "_")
  if id == "Btn_Close" then
    self:Hide()
  elseif id == "Btn_GoldBuy" then
    self:sendDrawReq(1)
  elseif id == "Btn_BuyOne" then
    self:sendDrawReq(1)
  elseif id == "Btn_BuyTen" then
    self:sendDrawReq(10)
  elseif id == "Btn_Tip" then
    _G.ShowCommonCenterTip(constant.CDrawCarnivalConsts.TIP_ID)
  elseif id == "Img_UseGold" then
    local function callback(id)
      if id == 1 then
        clickObj:GetComponent("UIToggle").value = not self.isAutoUse
        self.isAutoUse = not self.isAutoUse
      else
        clickObj:GetComponent("UIToggle").value = self.isAutoUse
      end
    end
    local str
    if self.isAutoUse then
      str = textRes.activity.DragonBaoKu[10]
    else
      str = textRes.activity.DragonBaoKu[9]
    end
    CommonConfirmDlg.ShowConfirm("", str, callback, nil)
  elseif id == "Btn_Exchange" then
    gmodule.moduleMgr:GetModule(ModuleId.TOKEN_MALL):OpenTokenMallByActivityId(constant.CDrawCarnivalConsts.ACTIVITY_ID)
  elseif id == "Texture_Icon" then
    local pName = clickObj.parent.name
    local strs = string.split(pName, "_")
    if strs[1] == "item" then
      local idx = tonumber(strs[2])
      if idx then
        local passTypeCfg = DragonBaoKuMgr.GetDrawCarnivalPassTypeCfg(self.passType)
        local lotteryCfg = ItemUtils.GetLotteryViewRandomCfg(passTypeCfg.freePassLotteryViewCfgId)
        local itemId = lotteryCfg.itemIds[idx]
        if itemId then
          ItemTipsMgr.Instance():ShowBasicTipsWithGO(itemId, clickObj, 0, false)
        end
      end
    end
  elseif id == "Btn_Add" then
    local pName = clickObj.parent.name
    local MallPanel = require("Main.Mall.ui.MallPanel")
    if pName == "Img_YuanBao" then
      require("Main.Mall.MallModule").RequireToShowMallPanel(MallPanel.StateConst.Pay, 0, 0)
    elseif pName == "Img_ExchangeHave" then
      local passItemCfg = DragonBaoKuMgr.GetDrawCarnivalPassItemCfg(self.passType)
      if passItemCfg then
        local itemId = passItemCfg.itemCfgIdList[1]
        if itemId then
          local MallType = require("consts.mzm.gsp.mall.confbean.MallType")
          require("Main.Mall.MallModule").RequireToShowMallPanel(MallPanel.StateConst.Treasure, itemId, MallType.PRECIOUS_MALL)
        end
      end
    end
  elseif strs[1] == "Toggle" then
    local idx = tonumber(strs[2])
    if idx then
      self.passType = idx
      self:changePassTypeRefresh()
    end
  end
end
def.method("number").sendDrawReq = function(self, num)
  if _G.IsNil(self.m_panel) then
    return
  end
  if num == 1 then
    local freeNum = DragonBaoKuMgr.Instance():getFreeNumByPassType(self.passType)
    if freeNum > 0 then
      local req = require("netio.protocol.mzm.gsp.drawcarnival.CDrawReq").new(self.passType, num, 0)
      gmodule.network.sendProtocol(req)
      warn("-----freeNum CDrawReq:", freeNum, self.passType, num, 0)
      return
    end
  end
  local Img_UseGold = self.m_panel:FindDirect("Group_RandomPrize/Group_Bottom/Group_AutoBuy/Img_UseGold")
  local isUse = 0
  local count = self:getCurPassItemNum()
  if Img_UseGold:GetComponent("UIToggle").value then
    isUse = 1
    if num > count then
      local passTypeCfg = DragonBaoKuMgr.GetDrawCarnivalPassTypeCfg(self.passType)
      local needYuanbao = (num - count) * passTypeCfg.yuanBaoPrice
      local allYuanbao = ItemModule.Instance():GetAllYuanBao()
      if allYuanbao:lt(Int64.new(needYuanbao)) then
        _G.GotoBuyYuanbao()
        return
      end
    end
  elseif num > count then
    local function callback(id)
      if id == 1 then
        Img_UseGold:GetComponent("UIToggle").value = true
        self.isAutoUse = true
      end
    end
    CommonConfirmDlg.ShowConfirm("", textRes.activity.DragonBaoKu[7], callback, tag)
    return
  end
  local req = require("netio.protocol.mzm.gsp.drawcarnival.CDrawReq").new(self.passType, num, isUse)
  gmodule.network.sendProtocol(req)
  warn("-----CDrawReq:", self.passType, num, isUse)
end
def.method().startScroll = function(self)
  local dragonBaoKuMgr = DragonBaoKuMgr.Instance()
  if self.yuanbaoQueue == nil then
    return
  end
  local t = table.remove(self.yuanbaoQueue, 1)
  if t == nil then
    warn("-----scroll end>>>>>>>>>")
    return
  end
  local lastYuanbaoNum = self.curYuanBao or t.last
  local curYuanBaoNum = t.cur
  if lastYuanbaoNum == nil or curYuanBaoNum == nil then
    return
  end
  self.curYuanBao = curYuanBaoNum
  local curYuanBaoStr = string.reverse(tostring(curYuanBaoNum))
  local lastYuanbaoStr = string.reverse(tostring(lastYuanbaoNum))
  self.scrollCount = 0
  for i = 0, MAX_DIGITAL do
    local index = i + 1
    local str1 = string.sub(curYuanBaoStr, index, index)
    local str2 = string.sub(lastYuanbaoStr, index, index)
    if str1 ~= str2 then
      self.scrollCount = i
    end
  end
  if self.scrollCount <= 0 then
    return
  end
  self.isScroll = true
  GameUtil.AddGlobalTimer(0.1, true, function()
    if self.m_panel and not self.m_panel.isnil then
      self:Begin()
    end
  end)
  local endDelay = 0.5 + self.scrollCount * 0.1
  GameUtil.AddGlobalTimer(endDelay, true, function()
    if self.m_panel and not self.m_panel.isnil then
      self:End()
    end
  end)
end
def.method().Begin = function(self)
  local allNUm = self.scrollCount + 1
  for i = 0, self.scrollCount do
    GameUtil.AddGlobalTimer((allNUm - i) * 0.1, true, function()
      if self.m_panel and not self.m_panel.isnil then
        self.m_scrollNumbers[i]:Begin()
      end
    end)
  end
end
def.method().End = function(self)
  local endCount = 0
  local allNum = self.scrollCount + 1
  local yuanbaoNum = self.curYuanBao or Int64.new(0)
  local function scrollEnd()
    endCount = endCount + 1
    if endCount >= allNum then
      self.isScroll = false
      self.nextScrollTimerId = GameUtil.AddGlobalTimer(constant.CDrawCarnivalConsts.AWARD_POOL_YUAN_BAO_REFRESH_INTERVAL, true, function()
        if _G.IsNil(self.m_panel) then
          return
        end
        self:startScroll()
      end)
    end
  end
  local codeStr = string.format("%d", yuanbaoNum:ToNumber())
  local reverseCodeStr = string.reverse(codeStr)
  for i = 0, self.scrollCount do
    do
      local idStr = string.sub(reverseCodeStr, i + 1, i + 1)
      local id = idStr and tonumber(idStr) or 0
      local pos = self.scrollCount - i
      local delay = pos * 0.5
      GameUtil.AddGlobalTimer(delay, true, function()
        if self.m_panel and not self.m_panel.isnil then
          self.m_scrollNumbers[i]:End(id, scrollEnd)
        end
      end)
    end
  end
end
def.method().initUI = function(self)
end
def.method().changePassTypeRefresh = function(self)
  self:setItemList()
  self:setBtnState()
  self:setCostInfo()
end
def.method().setItemList = function(self)
  local Group_Items = self.m_panel:FindDirect("Group_Items")
  local passTypeCfg = DragonBaoKuMgr.GetDrawCarnivalPassTypeCfg(self.passType)
  local lotteryCfg = ItemUtils.GetLotteryViewRandomCfg(passTypeCfg.freePassLotteryViewCfgId)
  for i, v in ipairs(lotteryCfg.itemIds) do
    local item = Group_Items:FindDirect("item_" .. i)
    local Texture_Icon = item:FindDirect("Texture_Icon")
    local Img_BgIcon = item:FindDirect("Img_BgIcon")
    local Label_Num = Img_BgIcon:FindDirect("Label_Num")
    local itemBase = ItemUtils.GetItemBase(v)
    GUIUtils.FillIcon(Texture_Icon:GetComponent("UITexture"), itemBase.icon)
    Label_Num:GetComponent("UILabel"):set_text("")
  end
end
def.method().setBtnState = function(self)
  local Group_Btn = self.m_panel:FindDirect("Group_RandomPrize/Group_Btn")
  local Btn_BuyOne = Group_Btn:FindDirect("Btn_BuyOne")
  local Group_Free = Group_Btn:FindDirect("Group_Free")
  local freeNum = DragonBaoKuMgr.Instance():getFreeNumByPassType(self.passType)
  local passTypeCfg = DragonBaoKuMgr.GetDrawCarnivalPassTypeCfg(self.passType)
  local Icon_Exchange = Group_Btn:FindDirect("Btn_BuyTen/Icon_Exchange")
  GUIUtils.FillIcon(Icon_Exchange:GetComponent("UITexture"), passTypeCfg.icon)
  if freeNum > 0 then
    Btn_BuyOne:SetActive(false)
    Group_Free:SetActive(true)
    local freeBTn = Group_Free:FindDirect("Btn_GoldBuy")
    GUIUtils.SetLightEffect(freeBTn, GUIUtils.Light.Square)
    Group_Free:FindDirect("Label_Left/Label_Num"):GetComponent("UILabel"):set_text(freeNum)
  else
    Btn_BuyOne:SetActive(true)
    Group_Free:SetActive(false)
    local Icon_Exchange = Btn_BuyOne:FindDirect("Icon_Exchange")
    GUIUtils.FillIcon(Icon_Exchange:GetComponent("UITexture"), passTypeCfg.icon)
    if 0 >= passTypeCfg.freePassCountPerDay then
      local Label = Btn_BuyOne:FindDirect("Label")
      Label:GetComponent("UILabel"):set_text("")
      if self.timerId ~= 0 then
        GameUtil.RemoveGlobalTimer(self.timerId)
        self.timerId = 0
      end
      return
    end
    self:setLeftTime()
    if self.timerId == 0 then
      self.timerId = GameUtil.AddGlobalTimer(1, false, function()
        self:setLeftTime()
      end)
    end
  end
end
def.method().setLeftTime = function(self)
  if _G.IsNil(self.m_panel) then
    return
  end
  local resetTime = DragonBaoKuMgr.Instance():getResetTimeStamp(self.passType)
  local curTime = _G.GetServerTime()
  local leftTime = resetTime - curTime
  if leftTime > 0 then
    local hour = math.floor(leftTime / 3600)
    local min = math.floor((leftTime - hour * 3600) / 60)
    local sec = leftTime - hour * 3600 - min * 60
    local Group_Btn = self.m_panel:FindDirect("Group_RandomPrize/Group_Btn")
    local Btn_BuyOne = Group_Btn:FindDirect("Btn_BuyOne")
    local Label = Btn_BuyOne:FindDirect("Label")
    Label:GetComponent("UILabel"):set_text(string.format(textRes.activity.DragonBaoKu[4], hour, min, sec))
  else
  end
end
def.method().setPoolYuanBaoNum = function(self)
  local Group_Items = self.m_panel:FindDirect("Group_Items")
  local yuanbaoNum = DragonBaoKuMgr.Instance():getPoolYuanbaoNum() or Int64.new(0)
  local codeStr = string.format("%d", yuanbaoNum:ToNumber())
  local reverseCodeStr = string.reverse(codeStr)
  for i = 0, MAX_DIGITAL do
    local idStr = string.sub(reverseCodeStr, i + 1, i + 1)
    local id = idStr and tonumber(idStr) or 0
    self.m_scrollNumbers[i]:SetNumber(id)
  end
end
def.method().setLastWinnerInfo = function(self)
  local Label = self.m_panel:FindDirect("Group_Left/Img_Bg1/Label")
  local infoStr = DragonBaoKuMgr.Instance():getLastWinnerInfoStr()
  Label:GetComponent("UILabel"):set_text(infoStr)
end
def.method().setSelectedToggle = function(self)
  local Group_Toggle = self.m_panel:FindDirect("Group_Left/Group_Select/Group_Toggle")
  for i = 1, 3 do
    local Toggle = Group_Toggle:FindDirect("Toggle_" .. i)
    if Toggle then
      Toggle:GetComponent("UIToggle").value = i == self.passType
    end
  end
  local Img_UseGold = self.m_panel:FindDirect("Group_RandomPrize/Group_Bottom/Group_AutoBuy/Img_UseGold")
  Img_UseGold:GetComponent("UIToggle").value = self.isAutoUse
end
def.method().updateToggleEffect = function(self)
  local Group_Toggle = self.m_panel:FindDirect("Group_Left/Group_Select/Group_Toggle")
  local dragonBaoKuMgr = DragonBaoKuMgr.Instance()
  for i = 1, 3 do
    local freeNum = dragonBaoKuMgr:getFreeNumByPassType(i)
    local Toggle = Group_Toggle:FindDirect("Toggle_" .. i)
    if Toggle then
      if freeNum > 0 then
        GUIUtils.SetLightEffect(Toggle, GUIUtils.Light.Square)
      else
        GUIUtils.SetLightEffect(Toggle, GUIUtils.Light.None)
      end
    end
  end
end
def.method().setCostInfo = function(self)
  local Group_RandomPrize = self.m_panel:FindDirect("Group_RandomPrize")
  local Label_Credits = Group_RandomPrize:FindDirect("Group_Top/Label_Credits")
  local itemModule = ItemModule.Instance()
  local point = itemModule:GetCredits(TokenType.DRAW_CARNIVAL_POINT) or Int64.new(0)
  Label_Credits:FindDirect("Label_Num"):GetComponent("UILabel"):set_text(tostring(point))
  local Group_Bottom = Group_RandomPrize:FindDirect("Group_Bottom")
  local Label_Tip2 = Group_Bottom:FindDirect("Group_AutoBuy/Label_Tip2")
  local passTypeCfg = DragonBaoKuMgr.GetDrawCarnivalPassTypeCfg(self.passType)
  Label_Tip2:GetComponent("UILabel"):set_text(string.format(textRes.activity.DragonBaoKu[1], passTypeCfg.yuanBaoPrice))
  local Label_Coin = Group_Bottom:FindDirect("Img_YuanBao/Label_Coin")
  local yuanbaoNum = itemModule:GetAllYuanBao()
  Label_Coin:GetComponent("UILabel"):set_text(tostring(yuanbaoNum))
  local Label_HaveNum = Group_Bottom:FindDirect("Img_ExchangeHave/Label_HaveNum")
  local count = self:getCurPassItemNum()
  Label_HaveNum:GetComponent("UILabel"):set_text(count)
  local Icon_Exchange = Group_Bottom:FindDirect("Img_ExchangeHave/Icon_Exchange")
  local passTypeCfg = DragonBaoKuMgr.GetDrawCarnivalPassTypeCfg(self.passType)
  GUIUtils.FillIcon(Icon_Exchange:GetComponent("UITexture"), passTypeCfg.icon)
end
def.method("=>", "number").getCurPassItemNum = function(self)
  local count = 0
  local passItemCfg = DragonBaoKuMgr.GetDrawCarnivalPassItemCfg(self.passType)
  if passItemCfg then
    local itemModule = ItemModule.Instance()
    for i, v in ipairs(passItemCfg.itemCfgIdList) do
      local num = itemModule:GetNumberByItemId(ItemModule.BAG, v)
      count = count + num
    end
  end
  return count
end
def.method("number").startPlayEffect = function(self, targetIdx)
  self.roundNum = 0
  if targetIdx < SlowAheadNum then
    self.slowStartNum = (SlowRoundNum + 1) * MAX_GRIDNUM - (SlowAheadNum - targetIdx)
  else
    self.slowStartNum = SlowRoundNum * MAX_GRIDNUM + targetIdx - SlowAheadNum
  end
  self.playGradAllNum = 0
  self:playLotteryEffect(1, targetIdx)
end
def.method("number", "number").playLotteryEffect = function(self, idx, targerIdx)
  self.playGradAllNum = self.playGradAllNum + 1
  local Group_Items = self.m_panel:FindDirect("Group_Items")
  if idx > MAX_GRIDNUM then
    idx = 1
  end
  for i = 1, self.passType do
    local newIdx = idx + (i - 1)
    if newIdx > MAX_GRIDNUM then
      newIdx = 1
    end
    local item = Group_Items:FindDirect("item_" .. newIdx)
    local lastIdx = newIdx - 1
    if lastIdx <= 0 then
      lastIdx = MAX_GRIDNUM
    end
    local lastItem = Group_Items:FindDirect("item_" .. lastIdx)
    if lastItem then
      local Img_Select = lastItem:FindDirect("Img_BgIcon/Img_Select1")
      Img_Select:SetActive(false)
    end
  end
  for i = 1, self.passType do
    local newIdx = idx + (i - 1)
    if newIdx > MAX_GRIDNUM then
      newIdx = 1
    end
    local item = Group_Items:FindDirect("item_" .. newIdx)
    if item then
      local Img_Select = item:FindDirect("Img_BgIcon/Img_Select1")
      Img_Select:SetActive(true)
      Img_Select:GetComponent("UISprite"):set_spriteName(Select_Frame[i])
    end
  end
  local time = 0.03
  if self.roundNum >= SlowRoundNum and self.playGradAllNum >= self.slowStartNum then
    local slowIdx = self.playGradAllNum - self.slowStartNum
    time = 2 * time * slowIdx + time
    if idx == targerIdx then
      self:clearSelectedState()
      for i, v in ipairs(self.awardInfo[1].draw_award_info_list) do
        local awardItem = Group_Items:FindDirect("item_" .. v.index + 1)
        if awardItem then
          local Img_Select = awardItem:FindDirect("Img_BgIcon/Img_Select1")
          Img_Select:SetActive(true)
          Img_Select:GetComponent("UISprite"):set_spriteName(Select_Frame[i])
        end
      end
      GameUtil.AddGlobalTimer(0.5, true, function()
        if _G.IsNil(self.m_panel) then
          return
        end
        require("Main.activity.DragonBaoKu.ui.DragonBaoKuResultPanel").Instance():ShowPanel(self.awardInfo)
      end)
      return
    end
  end
  GameUtil.AddGlobalTimer(time, true, function()
    if _G.IsNil(self.m_panel) then
      return
    end
    local nexIdx = idx + 1
    self:playLotteryEffect(nexIdx, targerIdx)
    if nexIdx == MAX_GRIDNUM then
      self.roundNum = self.roundNum + 1
    end
  end)
end
def.method().clearSelectedState = function(self)
  if _G.IsNil(self.m_panel) then
    return
  end
  local passTypeCfg = DragonBaoKuMgr.GetDrawCarnivalPassTypeCfg(self.passType)
  local lotteryCfg = ItemUtils.GetLotteryViewRandomCfg(passTypeCfg.freePassLotteryViewCfgId)
  local Group_Items = self.m_panel:FindDirect("Group_Items")
  for i, v in ipairs(lotteryCfg.itemIds) do
    local item = Group_Items:FindDirect("item_" .. i)
    local Img_Select = item:FindDirect("Img_BgIcon/Img_Select1")
    Img_Select:SetActive(false)
  end
end
return DragonBaoKuPanel.Commit()
