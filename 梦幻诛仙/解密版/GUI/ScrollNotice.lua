local Lplus = require("Lplus")
local ECPanelBase = require("GUI.ECPanelBase")
local Vector = require("Types.Vector")
local GUIUtils = require("GUI.GUIUtils")
local ScrollNotice = Lplus.Extend(ECPanelBase, "ScrollNotice")
local def = ScrollNotice.define
local _instance
def.static("=>", ScrollNotice).Instance = function()
  if _instance == nil then
    _instance = ScrollNotice()
    _instance.notices = {}
  end
  return _instance
end
def.static("string").Notice = function(content)
  ScrollNotice.Instance():_notice(content)
end
def.const("number").SPEED = 128
def.field("table").notices = nil
def.field("boolean").scrolling = false
def.method("string")._notice = function(self, cnt)
  if self:IsShow() then
    table.insert(self.notices, cnt)
    self:showOne()
  else
    self:SetDepth(5)
    table.insert(self.notices, cnt)
    self:CreatePanel(RESPATH.PREFAB_SCROLL_NOTICE, -1)
  end
end
def.override().OnCreate = function(self)
  self:showOne()
end
def.method().showOne = function(self)
  if self.scrolling then
    return
  end
  if #self.notices > 0 then
    local text = self.notices[1]
    table.remove(self.notices, 1)
    local lbl = self.m_panel:FindDirect("Img_Bg/Panel_Clip/ScrollText")
    local lblComp = lbl:GetComponent("UILabel")
    lblComp:set_text(text)
    local lblWidth = lblComp:get_width()
    local widget = self.m_panel:FindDirect("Img_Bg"):GetComponent("UIWidget")
    local bgWidget = widget:get_width()
    local startPos = Vector.Vector3.new(bgWidget / 2, 0, 0)
    local endPos = Vector.Vector3.new(0 - bgWidget / 2 - lblWidth, 0, 0)
    local moveLength = bgWidget + lblWidth
    lbl.transform.localPosition = startPos
    local time = moveLength / ScrollNotice.SPEED
    TweenPosition.Begin(lbl, time, endPos)
    self.scrolling = true
    GameUtil.AddGlobalTimer(time, true, function()
      self.scrolling = false
      self:showOne()
    end)
  else
    self:DestroyPanel()
  end
end
ScrollNotice.Commit()
return ScrollNotice
