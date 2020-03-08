local Lplus = require("Lplus")
local NotifyBar = Lplus.Class("NotifyBar")
local EC = require("Types.Vector3")
local def = NotifyBar.define
def.field("userdata").m_html1 = nil
def.field("userdata").m_html2 = nil
def.field("number").m_cur = 0
def.field("table").m_upPos = nil
def.field("table").m_midPos = nil
def.field("table").m_downPos = nil
def.static("userdata", "=>", NotifyBar).Create = function(uiGo)
  local ctrl = NotifyBar()
  ctrl.m_html1 = uiGo:FindDirect("Clip/Html_Text_1")
  ctrl.m_html2 = uiGo:FindDirect("Clip/Html_Text_2")
  local x = ctrl.m_html1.localPosition.x
  ctrl.m_upPos = EC.Vector3.new(x, 54, 0)
  ctrl.m_midPos = EC.Vector3.new(x, 11, 0)
  ctrl.m_downPos = EC.Vector3.new(x, -24, 0)
  return ctrl
end
def.method("userdata").TweenIn = function(self, html)
  html.localPosition = self.m_downPos
  TweenPosition.Begin(html, 0.5, self.m_midPos)
end
def.method("userdata").TweenOut = function(self, html)
  html.localPosition = self.m_midPos
  TweenPosition.Begin(html, 0.5, self.m_upPos)
end
def.method("string").AddNotify = function(self, notify)
  if self.m_cur == 0 then
    self.m_cur = 1
    self.m_html1:GetComponent("NGUIHTML"):ForceHtmlText(notify)
    self:TweenIn(self.m_html1)
  elseif self.m_cur == 1 then
    self.m_cur = 2
    self.m_html2:GetComponent("NGUIHTML"):ForceHtmlText(notify)
    self:TweenIn(self.m_html2)
    self:TweenOut(self.m_html1)
  elseif self.m_cur == 2 then
    self.m_cur = 1
    self.m_html1:GetComponent("NGUIHTML"):ForceHtmlText(notify)
    self:TweenIn(self.m_html1)
    self:TweenOut(self.m_html2)
  end
end
def.method("string").SetNotify = function(self, notify)
  if self.m_cur == 0 then
    self.m_cur = 1
    self.m_html1:GetComponent("NGUIHTML"):ForceHtmlText(notify)
    self.m_html1.localPosition = self.m_midPos
  elseif self.m_cur == 1 then
    self.m_cur = 2
    self.m_html2:GetComponent("NGUIHTML"):ForceHtmlText(notify)
    self.m_html2.localPosition = self.m_midPos
    self.m_html1.localPosition = self.m_upPos
  elseif self.m_cur == 2 then
    self.m_cur = 1
    self.m_html1:GetComponent("NGUIHTML"):ForceHtmlText(notify)
    self.m_html1.localPosition = self.m_midPos
    self.m_html2.localPosition = self.m_upPos
  end
end
NotifyBar.Commit()
return NotifyBar
