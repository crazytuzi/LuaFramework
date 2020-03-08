local Lplus = require("Lplus")
local ECPanelBase = require("GUI.ECPanelBase")
local BubbleGamePanel = Lplus.Extend(ECPanelBase, "BubbleGamePanel")
local AbsoluteTimer = require("Main.Common.AbsoluteTimer")
local GUIUtils = require("GUI.GUIUtils")
local EC = require("Types.Vector")
local BubbleGameMgr = require("Main.MiniGame.BubbleGameMgr")
local bubbleGameMgr = BubbleGameMgr.Instance()
local ECModel = require("Model.ECModel")
local UIModelWrap = require("Model.UIModelWrap")
local def = BubbleGamePanel.define
local instance
def.field("number").timerId = 0
def.field("number").addTimerId = 0
def.field("number").countDowmTimerId = 0
def.field("number").dropTimerId = 0
def.field("number").runTime = 0
def.field("table").allBubbles = nil
def.field("number").bubbleNum = 0
def.field("number").curNum = 0
def.field("table").curGameCfg = nil
def.field("number").leftTime = 0
def.field("number").dropIntervalTime = 0
def.field("number").dropDurationTime = 0
def.field(UIModelWrap)._UIModelWrap = nil
def.static("=>", BubbleGamePanel).Instance = function()
  if instance == nil then
    instance = BubbleGamePanel()
  end
  return instance
end
def.method("number").ShowPanel = function(self, gameId)
  if self:IsShow() then
    return
  end
  self.curGameCfg = BubbleGameMgr.GetBubbleGameCfg(gameId)
  local uiPath = "Arts/Prefab/" .. self.curGameCfg.ui_id .. ".prefab.u3dext"
  self:CreatePanel(uiPath, 0)
  self:SetModal(true)
  self:SetDepth(GUIDEPTH.TOPMOST)
end
def.override("boolean").OnShow = function(self, show)
  if show then
    self:initGameInfo()
  else
    if self.timerId > 0 then
      GameUtil.RemoveGlobalTimer(self.timerId)
      self.timerId = 0
    end
    if 0 < self.addTimerId then
      GameUtil.RemoveGlobalTimer(self.addTimerId)
      self.addTimerId = 0
    end
    if self.countDowmTimerId ~= 0 then
      GameUtil.RemoveGlobalTimer(self.countDowmTimerId)
      self.countDowmTimerId = 0
    end
    self.runTime = 0
    self.curNum = 0
    self.leftTime = 0
    self.dropDurationTime = 0
    self.dropIntervalTime = 0
  end
end
def.override().OnCreate = function(self)
  self.allBubbles = {}
  local Slider_Item = self.m_panel:FindDirect("Img_Bg0/Slider_Item")
  Slider_Item:SetActive(false)
  local Wifget_Credits = self.m_panel:FindDirect("Img_Bg0/Wifget_Credits")
  Wifget_Credits:SetActive(false)
  local Model = self.m_panel:FindDirect("Img_Bg0/Model")
  local uiModel = Model:GetComponent("UIModel")
  uiModel:set_orthographic(true)
  uiModel.mCanOverflow = true
  self._UIModelWrap = UIModelWrap.new(uiModel)
  self._UIModelWrap._bUncache = true
  Event.RegisterEvent(ModuleId.MINI_GAME, gmodule.notifyId.MiniGame.BUBBLE_GAME_END, BubbleGamePanel.OnStopBubbleGame)
end
def.override().OnDestroy = function(self)
  if self._UIModelWrap ~= nil then
    self._UIModelWrap:Destroy()
  end
  self._UIModelWrap = nil
  Event.UnregisterEvent(ModuleId.MINI_GAME, gmodule.notifyId.MiniGame.BUBBLE_GAME_END, BubbleGamePanel.OnStopBubbleGame)
end
def.static("table", "table").OnStopBubbleGame = function(p1, p2)
  if instance and instance:IsShow() and instance.m_panel then
    Toast(textRes.MiniGame[3])
    local Group_End = instance.m_panel:FindDirect("Img_Bg0/Group_End")
    Group_End:SetActive(true)
  end
end
def.method().initGameInfo = function(self)
  local iconRecord = DynamicData.GetRecord(CFG_PATH.DATA_ICONRES, self.curGameCfg.model_id)
  if iconRecord then
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
  self:setScoreInfo()
  self:setCountDown()
  local Label_CountDown = self.m_panel:FindDirect("Img_Bg0/Label_CountDown")
  Label_CountDown:GetComponent("UILabel"):set_text("")
  if bubbleGameMgr.isResumeGame then
    self:startBubbleGame()
    return
  end
  local function callback()
    if self.m_panel == nil then
      return
    end
    local Label_CountDown = self.m_panel:FindDirect("Img_Bg0/Label_CountDown")
    local countdownTime = self.curGameCfg.countdown_time
    Label_CountDown:GetComponent("UILabel"):set_text(countdownTime)
    self.countDowmTimerId = GameUtil.AddGlobalTimer(1, false, function()
      countdownTime = countdownTime - 1
      Label_CountDown:GetComponent("UILabel"):set_text(countdownTime)
      if countdownTime <= 0 then
        GameUtil.RemoveGlobalTimer(self.countDowmTimerId)
        self.countDowmTimerId = 0
        Label_CountDown:GetComponent("UILabel"):set_text("")
        self:startBubbleGame()
      end
    end)
  end
  local tipsId = self.curGameCfg.tips_content_id
  if tipsId > 0 then
    do
      local MiniGameTip = require("Main.MiniGame.ui.MiniGameTip")
      local tipContent = require("Main.Common.TipsHelper").GetHoverTip(tipsId)
      MiniGameTip.Instance():ShowDlg(tipContent, callback)
      GameUtil.AddGlobalTimer(self.curGameCfg.tips_time, true, function()
        if MiniGameTip.Instance():IsShow() then
          MiniGameTip.Instance():Hide()
        end
      end)
    end
  else
    callback()
  end
end
def.method().startBubbleGame = function(self)
  local leftTime = bubbleGameMgr.startTime + self.curGameCfg.game_time - _G.GetServerTime()
  if bubbleGameMgr.curTurn == 0 then
    local gameTime = self.curGameCfg.game_time
    if leftTime >= gameTime - 3 then
      leftTime = gameTime
    end
  end
  leftTime = leftTime + self.curGameCfg.countdown_time + self.curGameCfg.tips_time
  if leftTime > 0 then
    self.leftTime = leftTime
  end
  if self.leftTime > self.curGameCfg.game_time then
    self.leftTime = self.curGameCfg.game_time
  end
  self:setDropTime()
  self:addBubble()
  self:setCountDown()
  self.countDowmTimerId = GameUtil.AddGlobalTimer(1, false, function()
    self.leftTime = self.leftTime - 1
    self:setCountDown()
    self:setDropTime()
    if self.leftTime <= 0 then
      GameUtil.RemoveGlobalTimer(self.countDowmTimerId)
      self.countDowmTimerId = 0
      GameUtil.RemoveGlobalTimer(self.addTimerId)
      self.addTimerId = 0
      self:playOverEffect()
      GameUtil.AddGlobalTimer(1, true, function()
        local p = require("netio.protocol.mzm.gsp.bubblegame.CStopBubbleGameReq").new(self.curGameCfg.game_id)
        gmodule.network.sendProtocol(p)
      end)
    end
  end)
  self.timerId = GameUtil.AddGlobalTimer(0, false, function()
    self:Update()
  end)
end
def.method().playOverEffect = function(self)
  local effectId = self.curGameCfg.game_over_effect_id
  if effectId > 0 then
    local effres = _G.GetEffectRes(effectId)
    if effres then
      local Img_Bg0 = self.m_panel:FindDirect("Img_Bg0")
      local effectObj = require("Fx.GUIFxMan").Instance():PlayAsChildLayerWithCallback(Img_Bg0, effres.path, "overEffect", 0, 0, 1, 1, -1, false, nil)
    else
      warn("!!!!!!!!!BubbleGame invalid effectId:", effectId)
    end
  end
end
def.method().setDropTime = function(self)
  local runTime = self.curGameCfg.game_time - self.leftTime
  for i, v in ipairs(self.curGameCfg.game_stage_infos) do
    if runTime <= i * v.duration then
      local oldIntervaltion = self.dropIntervalTime
      self.dropDurationTime = v.drop_duration_ms
      self.dropIntervalTime = v.drop_interval_ms
      if oldIntervaltion ~= self.dropIntervalTime then
        GameUtil.RemoveGlobalTimer(self.addTimerId)
        self.addTimerId = GameUtil.AddGlobalTimer(self.dropIntervalTime / 1000, false, function()
          self:addBubble()
        end)
      end
      return
    end
  end
end
def.method().setScoreInfo = function(self)
  if self.m_panel then
    local Label_TotalNum = self.m_panel:FindDirect("Img_Bg0/Label_Total/Label_TotalNum")
    Label_TotalNum:GetComponent("UILabel"):set_text(bubbleGameMgr.totalScore)
    local Label_NowNum = self.m_panel:FindDirect("Img_Bg0/Label_Now/Label_NowNum")
    Label_NowNum:GetComponent("UILabel"):set_text(bubbleGameMgr.curScore)
  end
end
def.method().setCountDown = function(self)
  local Label_TimeNum = self.m_panel:FindDirect("Img_Bg0/Label_Time/Label_TimeNum")
  if self.leftTime < 0 then
    self.leftTime = 0
  end
  Label_TimeNum:GetComponent("UILabel"):set_text(self.leftTime)
end
def.method().addBubble = function(self)
  local Group_Point = self.m_panel:FindDirect("Img_Bg0/Group_Point")
  local childCount = Group_Point.transform.childCount
  local idx = math.random(1, childCount)
  local Point = Group_Point:FindDirect("Point" .. idx)
  if Point then
    local Slider_Item = self.m_panel:FindDirect("Img_Bg0/Slider_Item")
    local SliderObj = GameObject.Instantiate(Slider_Item)
    local Icon_Thumb = SliderObj:FindDirect("Icon_Thumb")
    self.bubbleNum = self.bubbleNum + 1
    SliderObj.name = "Slider_Item_" .. self.bubbleNum
    Icon_Thumb.name = "Icon_Thumb_" .. self.bubbleNum
    SliderObj.parent = Point
    SliderObj.transform.localPosition = EC.Vector3.new(0, 0, 0)
    SliderObj.transform.localScale = EC.Vector3.one
    self.curNum = self.curNum + 1
    SliderObj:SetActive(true)
    local t = {}
    t.obj = SliderObj
    t.time = GameUtil.GetTickCount()
    self.allBubbles[self.bubbleNum] = t
  else
    warn("!!!!!!error Point:", idx)
  end
end
def.method("number", "boolean").destroyBubble = function(self, idx, isClick)
  local t = self.allBubbles[idx]
  if t == nil then
    return
  end
  local obj = t.obj
  if obj then
    local CReportBubbleGameResult = require("netio.protocol.mzm.gsp.bubblegame.CReportBubbleGameResult")
    local curTurn = bubbleGameMgr:addTurn(1)
    if isClick then
      local Icon_Thumb = obj:FindDirect("Icon_Thumb_" .. idx)
      local Wifget_Credits = self.m_panel:FindDirect("Img_Bg0/Wifget_Credits")
      local wifgetObj = GameObject.Instantiate(Wifget_Credits)
      wifgetObj.parent = obj
      wifgetObj.transform.localPosition = Icon_Thumb.transform.localPosition
      wifgetObj:SetActive(true)
      local Point_Label = wifgetObj:FindDirect("Label")
      local addPoint = self.curGameCfg.right_point
      Point_Label:GetComponent("UILabel"):set_text("+" .. addPoint)
      wifgetObj:GetComponent("UIPlayTween"):Play(true)
      GameUtil.AddGlobalTimer(0.5, true, function()
        if self.m_panel then
          GameObject.Destroy(obj)
        end
      end)
      bubbleGameMgr:addScore(addPoint)
      local p = CReportBubbleGameResult.new(self.curGameCfg.game_id, curTurn, CReportBubbleGameResult.RIGHT)
      gmodule.network.sendProtocol(p)
    else
      GameObject.Destroy(obj)
      bubbleGameMgr:addScore(self.curGameCfg.wrong_point)
      local p = CReportBubbleGameResult.new(self.curGameCfg.game_id, curTurn, CReportBubbleGameResult.WRONG)
      gmodule.network.sendProtocol(p)
    end
    self.allBubbles[idx] = nil
    self.curNum = self.curNum - 1
    self:setScoreInfo()
  end
end
def.method().Update = function(self)
  self.runTime = self.runTime + 0.001
  local curTime = GameUtil.GetTickCount()
  local dropDurationTime = self.dropDurationTime
  for i, v in pairs(self.allBubbles) do
    local obj = v.obj
    local time = v.time
    local value = 1 - (curTime - time) / dropDurationTime
    local ProgressBar = obj:GetComponent("UIProgressBar")
    local curValue = ProgressBar.value
    ProgressBar.value = value
    if ProgressBar.value <= 0 then
      self:destroyBubble(i, false)
    end
  end
end
def.method().Hide = function(self)
  self.bubbleNum = 0
  self.allBubbles = {}
  self.runTime = 0
  self.curNum = 0
  self:DestroyPanel()
end
def.method("userdata").onClickObj = function(self, clickObj)
  local id = clickObj.name
  if id == "Btn_Close" then
    if self.leftTime > 0 then
      local CommonConfirmDlg = require("GUI.CommonConfirmDlg")
      local dlg = CommonConfirmDlg.ShowConfirm("", textRes.MiniGame[4], function(selection, tag)
        if selection == 1 then
          local p = require("netio.protocol.mzm.gsp.bubblegame.CStopBubbleGameReq").new(self.curGameCfg.game_id)
          gmodule.network.sendProtocol(p)
          self:Hide()
        end
      end, nil)
      dlg:SetDepth(GUIDEPTH.TOPMOST)
    else
      self:Hide()
    end
  end
end
def.method("string", "boolean").onPress = function(self, id, state)
  if state then
    local strs = string.split(id, "_")
    if strs[1] == "Icon" and strs[2] == "Thumb" then
      local idx = tonumber(strs[3])
      if idx then
        self:destroyBubble(idx, true)
      end
    end
  end
end
BubbleGamePanel.Commit()
return BubbleGamePanel
