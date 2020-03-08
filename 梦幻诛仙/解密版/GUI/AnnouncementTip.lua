local Lplus = require("Lplus")
local ECPanelBase = require("GUI.ECPanelBase")
local Vector = require("Types.Vector")
local GUIUtils = require("GUI.GUIUtils")
local AnnouncementTip = Lplus.Extend(ECPanelBase, "AnnouncementTip")
local def = AnnouncementTip.define
def.const("number").SLIDESPEED = 64
def.const("number").MINWAITTIME = 2
def.const("number").SCROLLWAIT = 0.5
def.const("number").SCROLLTIME = 0.5
def.const("number").MAX_ANNOUNCE_WIDTH = 5000
def.const("number").DEFAULT_ANNOUNCE_PRIORITY = 1
def.field("table").transforms = nil
def.field("userdata").label1 = nil
def.field("userdata").label2 = nil
def.field("number").state = 0
def.field("number").timer = -1
def.field("boolean").block = false
def.field("number").containerWidth = 960
def.field("number").downY = 0
def.field("number").middleY = 0
def.field("number").upY = 0
def.field("number").announceCustomDuration = 0
def.field("table").waitQueue = nil
def.field("number").maxAnnouncePriority = 0
local _instance
def.static("string").Announce = function(content)
  if _instance ~= nil then
    _instance:_AddAnnounceWithPriorityAndDuration(content, AnnouncementTip.DEFAULT_ANNOUNCE_PRIORITY, AnnouncementTip.MINWAITTIME)
  end
end
def.static("string", "number").AnnounceWithPriority = function(content, priority)
  if _instance ~= nil then
    _instance:_AddAnnounceWithPriorityAndDuration(content, priority, AnnouncementTip.MINWAITTIME)
  end
end
def.static("string", "number").AnnounceWithDuration = function(content, duration)
  if _instance ~= nil then
    _instance:_AddAnnounceWithPriorityAndDuration(content, AnnouncementTip.DEFAULT_ANNOUNCE_PRIORITY, duration)
  end
end
def.static("string", "number", "number").AddAnnounceWithPriorityAndDuration = function(content, priority, duration)
  if _instance ~= nil then
    _instance:_AddAnnounceWithPriorityAndDuration(content, priority, duration)
  end
end
def.method("string", "number", "number")._AddAnnounceWithPriorityAndDuration = function(self, content, priority, duration)
  self:_AddToQueue(content, priority, duration)
  self:ShowOne()
end
def.method("string", "number", "number")._AddToQueue = function(self, content, priority, duration)
  if self.waitQueue[priority] == nil then
    warn("\232\175\165\229\133\172\229\145\138\231\154\132\228\188\152\229\133\136\231\186\167\228\184\141\232\162\171\229\133\129\232\174\184:" .. priority)
  else
    local announce = {}
    announce.duration = duration
    announce.content = content
    self:_AddAnnounceToWaitQueue(priority, announce)
  end
end
def.method("number", "table")._AddAnnounceToWaitQueue = function(self, priority, announce)
  table.insert(self.waitQueue[priority], announce)
end
def.method("=>", "boolean")._IsWaitQueueEmpty = function(self)
  for i = 0, self.maxAnnouncePriority do
    if 0 < #self.waitQueue[i] then
      return false
    end
  end
  return true
end
def.virtual("=>", "table")._PopWaitAnnounce = function(self)
  local announce, waitQueue
  for i = 0, self.maxAnnouncePriority do
    if 0 < #self.waitQueue[i] then
      waitQueue = self.waitQueue[i]
      break
    end
  end
  if waitQueue ~= nil then
    announce = waitQueue[1]
    table.remove(waitQueue, 1)
  end
  return announce
end
def.static().HideImmediately = function(self)
  _instance.m_panel:SetActive(false)
end
def.static().Init = function()
  if _instance == nil then
    _instance = AnnouncementTip()
    _instance:SetDepth(5)
    _instance:CreatePanel(RESPATH.ANNOUNCEMENT_PANEL, -1)
  end
end
def.static("boolean").Block = function(block)
  if _instance then
    _instance.block = block
    if not block then
      _instance:ShowOne()
    end
  end
end
def.override().OnCreate = function(self)
  self.label1 = self.m_panel:FindDirect("Panel_Clip/Img_Background/Label_Text1")
  self.label2 = self.m_panel:FindDirect("Panel_Clip/Img_Background/Label_Text2")
  self.label1:GetComponent("NGUIHTML"):set_maxLineNumber(1)
  self.label2:GetComponent("NGUIHTML"):set_maxLineNumber(1)
  self.label1:GetComponent("NGUIHTML"):set_maxLineWidth(AnnouncementTip.MAX_ANNOUNCE_WIDTH)
  self.label2:GetComponent("NGUIHTML"):set_maxLineWidth(AnnouncementTip.MAX_ANNOUNCE_WIDTH)
  self.m_panel:SetActive(false)
  local GUIMan = require("GUI.ECGUIMan")
  local screenHeight = GUIMan.Instance().m_uiRootCom:get_activeHeight()
  self.containerWidth = screenHeight / Screen.height * Screen.width
  self.downY = self.m_panel:FindDirect("Panel_Clip/Img_Background/Widget_Down").localPosition.y
  self.middleY = self.m_panel:FindDirect("Panel_Clip/Img_Background/Widget_Middle").localPosition.y
  self.upY = self.m_panel:FindDirect("Panel_Clip/Img_Background/Widget_Up").localPosition.y
  self:InitQueuePriority(2)
  Event.RegisterEventWithContext(ModuleId.LOGIN, gmodule.notifyId.Login.LEAVE_WORLD, AnnouncementTip.ClearAnnounce, self)
end
def.method("number").InitQueuePriority = function(self, maxPriority)
  self.maxAnnouncePriority = maxPriority
  self.waitQueue = {}
  for i = 0, maxPriority do
    self.waitQueue[i] = {}
  end
end
def.method().ShowOne = function(self)
  if self.block then
    return
  end
  if self.timer == -1 then
    local announce = self:_PopWaitAnnounce()
    if announce == nil then
      return
    end
    local content = ""
    local duration = 0
    duration = announce.duration or AnnouncementTip.MINWAITTIME
    content = announce.content
    self.announceCustomDuration = duration
    self.m_panel:SetActive(true)
    local nextWaitTime = 5
    if self.state == 0 then
      self:SetContent(self.label2, "&nbsp;")
      self:SetContent(self.label1, content)
      nextWaitTime = self:MoveIn(self.label1)
      self.state = 1
    elseif self.state == 1 then
      self:SetContent(self.label2, content)
      nextWaitTime = self:MoveIn(self.label2)
      self:MoveOut(self.label1)
      self.state = 2
    elseif self.state == 2 then
      self:SetContent(self.label1, content)
      nextWaitTime = self:MoveIn(self.label1)
      self:MoveOut(self.label2)
      self.state = 1
    end
    if duration > nextWaitTime then
      nextWaitTime = duration or nextWaitTime
    end
    self.timer = GameUtil.AddGlobalTimer(nextWaitTime, true, function()
      self.timer = -1
      self.announceCustomDuration = 0
      if not self:_IsWaitQueueEmpty() then
        self:ShowOne()
      else
        self.m_panel:SetActive(false)
        self.state = 0
      end
    end)
  end
end
def.method("userdata", "string").SetContent = function(self, ctrl, content)
  local HtmlHelper = require("Main.Chat.HtmlHelper")
  content = HtmlHelper.ConvertAnnouncement(content)
  ctrl:GetComponent("NGUIHTML"):ForceHtmlText(content)
  AnnouncementTip._AjustHTMLCenter(ctrl)
end
def.static("userdata")._AjustHTMLCenter = function(ctrl)
  local totalWidth = ctrl:GetComponent("NGUIHTML"):get_width()
  local ctrlCount = ctrl.transform.childCount
  local preWidth = 0
  for i = 1, ctrlCount do
    local child = ctrl.transform:GetChild(i - 1).gameObject
    local childWidth = child:GetComponent("UIWidget"):get_width()
    local newPos = Vector.Vector3.new(preWidth + childWidth / 2 - totalWidth / 2, 0, 0)
    child.localPosition = newPos
    preWidth = preWidth + childWidth
  end
end
def.method("userdata", "=>", "number").MoveIn = function(self, ctrl)
  local label = ctrl:GetComponent("NGUIHTML")
  local width = label:get_width()
  if width <= self.containerWidth then
    ctrl.localPosition = Vector.Vector3.new(0, self.downY, 0)
    local tarPos = Vector.Vector3.new(0, self.middleY, 0)
    TweenPosition.Begin(ctrl, AnnouncementTip.SCROLLTIME, tarPos)
    return AnnouncementTip.MINWAITTIME
  else
    do
      local offsetX = (width - self.containerWidth) / 2
      ctrl.localPosition = Vector.Vector3.new(offsetX, self.downY, 0)
      local tarPos = Vector.Vector3.new(offsetX, self.middleY, 0)
      TweenPosition.Begin(ctrl, AnnouncementTip.SCROLLTIME, tarPos)
      local duration = offsetX * 2 / AnnouncementTip.SLIDESPEED
      local endPos = Vector.Vector3.new(-1 * offsetX, self.middleY, 0)
      local totalTime = duration + AnnouncementTip.SCROLLTIME + AnnouncementTip.SCROLLWAIT * 2
      if duration < 1 then
        duration = 1
      end
      GameUtil.AddGlobalTimer(AnnouncementTip.SCROLLTIME + AnnouncementTip.SCROLLWAIT, true, function()
        if self.m_panel then
          TweenPosition.Begin(ctrl, duration, endPos)
        end
      end)
      if totalTime < self.announceCustomDuration then
        self:AddLoopScrollTimer(ctrl, self.announceCustomDuration, totalTime, duration, tarPos, endPos)
      end
      return totalTime > AnnouncementTip.MINWAITTIME and totalTime or AnnouncementTip.MINWAITTIME
    end
  end
end
def.method("userdata").MoveOut = function(self, ctrl)
  local curX = ctrl.localPosition.x
  local tarPos = Vector.Vector3.new(curX, self.upY, 0)
  TweenPosition.Begin(ctrl, AnnouncementTip.SCROLLTIME, tarPos)
end
def.method("userdata", "number", "number", "number", "table", "table").AddLoopScrollTimer = function(self, ctrl, totalDuration, firstActionDuration, loopActionDuration, originPos, endPos)
  local resetTimePoints = {}
  local pointCount = 0
  local lastActionEndTimeTime = firstActionDuration
  local leftDuration = totalDuration - firstActionDuration
  while loopActionDuration <= leftDuration do
    table.insert(resetTimePoints, lastActionEndTimeTime)
    local actionNeddTime = loopActionDuration + AnnouncementTip.SCROLLWAIT
    lastActionEndTimeTime = lastActionEndTimeTime + actionNeddTime
    leftDuration = leftDuration - actionNeddTime
  end
  for i = 1, #resetTimePoints do
    GameUtil.AddGlobalTimer(resetTimePoints[i], true, function()
      if self.m_panel then
        if i % 2 == 1 then
          TweenPosition.Begin(ctrl, loopActionDuration, originPos)
        else
          TweenPosition.Begin(ctrl, loopActionDuration, endPos)
        end
      end
    end)
  end
  if leftDuration > 0 then
    GameUtil.AddGlobalTimer(lastActionEndTimeTime, true, function()
      if self.m_panel then
        local destPos
        local moveX = (endPos.x - originPos.x) * (leftDuration / loopActionDuration)
        if #resetTimePoints % 2 == 1 then
          destPos = Vector.Vector3.new(originPos.x + moveX, originPos.y, 0)
        else
          destPos = Vector.Vector3.new(endPos.x - moveX, endPos.y, 0)
        end
        TweenPosition.Begin(ctrl, math.floor(leftDuration), destPos)
      end
    end)
  end
end
def.virtual("table").ClearAnnounce = function(self, params)
  for i = 0, self.maxAnnouncePriority do
    self.waitQueue[i] = {}
  end
  self.m_panel:SetActive(false)
end
AnnouncementTip.Commit()
return AnnouncementTip
