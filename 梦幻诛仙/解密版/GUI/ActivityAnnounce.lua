local Lplus = require("Lplus")
local ECPanelBase = require("GUI.ECPanelBase")
local Vector = require("Types.Vector")
local GUIUtils = require("GUI.GUIUtils")
local ActivityAnnounce = Lplus.Extend(ECPanelBase, "ActivityAnnounce")
local def = ActivityAnnounce.define
def.const("number").TWEENTIME = 1
def.const("number").STAYTIME = 6
def.field("userdata").label1 = nil
def.field("userdata").label2 = nil
def.field("number").timer = 0
def.field("number").downY = 0
def.field("number").middleY = 0
def.field("number").upY = 0
def.field("number").state = 1
def.field("string").title = ""
def.field("table").waitQueue = nil
local _instance
def.static("=>", ActivityAnnounce).Instance = function()
  if _instance == nil then
    _instance = ActivityAnnounce()
    _instance.waitQueue = {}
  end
  return _instance
end
def.method("string").Setup = function(self, title)
  self.title = title
  self.waitQueue = {}
  if self:IsShow() then
    self:ShowOne()
  else
    self:CreatePanel(RESPATH.PREFAB_HANHUA, 0)
  end
end
def.method().Uninstall = function(self)
  self:DestroyPanel()
end
def.method("string").SetDescText = function(self, cnt)
  if self:IsShow() then
    self:SetDesc(cnt)
  end
end
def.method("string").ScrollOne = function(self, cnt)
  table.insert(self.waitQueue, cnt)
  if self:IsShow() then
    self:ShowOne()
  end
end
def.override().OnCreate = function(self)
  self.label1 = self.m_panel:FindDirect("Panel_Clip/Label_Text1")
  self.label2 = self.m_panel:FindDirect("Panel_Clip/Label_Text2")
  self.downY = self.m_panel:FindDirect("Panel_Clip/Widget_Down").localPosition.y
  self.middleY = self.m_panel:FindDirect("Panel_Clip/Widget_Middle").localPosition.y
  self.upY = self.m_panel:FindDirect("Panel_Clip/Widget_Up").localPosition.y
  self:SetContent(self.label1, "")
  self:SetContent(self.label2, "")
  self:ShowOne()
  self:SetDesc("")
end
def.override().OnDestroy = function(self)
  self.waitQueue = {}
  GameUtil.RemoveGlobalTimer(self.timer)
  self.timer = 0
end
def.method("string").SetDesc = function(self, text)
  local lbl = self.m_panel:FindDirect("Label")
  if text == "" then
    lbl:SetActive(false)
  else
    lbl:SetActive(true)
    lbl:GetComponent("UILabel"):set_text(text)
  end
end
def.method().ShowOne = function(self)
  if self.timer == 0 then
    local cnt = self.title
    local time = 0
    if 0 < #self.waitQueue then
      cnt = table.remove(self.waitQueue, 1)
      time = ActivityAnnounce.TWEENTIME
    end
    if self.state == 1 then
      self:SetContent(self.label2, cnt)
      self:MoveIn(self.label2, time)
      self:MoveOut(self.label1, time)
      self.state = 2
    else
      self:SetContent(self.label1, cnt)
      self:MoveIn(self.label1, time)
      self:MoveOut(self.label2, time)
      self.state = 1
    end
    if time ~= 0 then
      self.timer = GameUtil.AddGlobalTimer(ActivityAnnounce.STAYTIME, true, function()
        self.timer = 0
        if self:IsShow() then
          self:ShowOne()
        end
      end)
    end
  end
end
def.method("userdata", "string").SetContent = function(self, ctrl, cnt)
  local lbl = ctrl:GetComponent("UILabel")
  lbl:set_text(cnt)
end
def.method("userdata", "number").MoveIn = function(self, ctrl, time)
  local tween = ctrl:GetComponent("TweenPosition")
  local from = Vector.Vector3.new(0, self.downY, 0)
  local to = Vector.Vector3.new(0, self.middleY, 0)
  tween:set_from(from)
  tween:set_to(to)
  tween:set_duration(time)
  tween:ResetToBeginning()
  tween:PlayForward()
end
def.method("userdata", "number").MoveOut = function(self, ctrl, time)
  local tween = ctrl:GetComponent("TweenPosition")
  local from = Vector.Vector3.new(0, self.middleY, 0)
  local to = Vector.Vector3.new(0, self.upY, 0)
  tween:set_from(from)
  tween:set_to(to)
  tween:set_duration(time)
  tween:ResetToBeginning()
  tween:PlayForward()
end
ActivityAnnounce.Commit()
return ActivityAnnounce
