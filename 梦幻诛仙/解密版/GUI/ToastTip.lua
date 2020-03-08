local Lplus = require("Lplus")
local ECPanelBase = require("GUI.ECPanelBase")
local Vector = require("Types.Vector")
local GUIUtils = require("GUI.GUIUtils")
local ToastTip = Lplus.Extend(ECPanelBase, "ToastTip")
local def = ToastTip.define
def.const("number").MINWIDTH = 352
def.field("table").transforms = nil
def.field("userdata").panelClip = nil
def.field("userdata").template = nil
def.field("table").waitQueue = nil
def.field("table").displayQueue = nil
def.field("number").timer = -1
def.field("number").lastLineCount = 1
local _instance
function _G.Toast(content)
  if content == nil or type(content) ~= "string" then
    warn("Toast param wrong", type(content), content, debug.traceback("Toast"))
    if Application.platform == RuntimePlatform.WindowsPlayer or Application.platform == RuntimePlatform.WindowsEditor then
    else
      return
    end
  end
  if _instance ~= nil then
    _instance:_toast(content, nil, nil)
  end
end
def.static("string").Toast = function(content)
  Toast("Please Use Global function Toast(string) instead!")
end
def.static("string", "function", "table").ToastWithCallback = function(content, cb, tag)
  if _instance ~= nil then
    _instance:_toast(content, cb, tag)
  end
end
def.static("boolean").Block = function(block)
  if _instance then
    if block then
      _instance:SetLayer(ClientDef_Layer.Invisible)
    else
      _instance:SetLayer(ClientDef_Layer.UI)
    end
  end
end
def.static().Init = function()
  if _instance == nil then
    _instance = ToastTip()
    _instance.waitQueue = {}
    _instance.displayQueue = {}
    _instance:SetDepth(6)
    _instance:CreatePanel(RESPATH.TOAST_PANEL, -1)
  end
end
def.override().OnCreate = function(self)
  self.template = self.m_panel:FindDirect("Panel_Clip/Widget_Tween")
  local panelClip = self.m_panel:FindDirect("Panel_Clip")
  self.panelClip = panelClip
  self.transforms = {}
  local i = 1
  while true do
    local pos = panelClip:FindDirect(string.format("Widget_%d", i))
    if pos == nil then
      break
    end
    local transform = pos.transform
    table.insert(self.transforms, transform)
    i = i + 1
  end
  self:ShowOne()
end
def.method("string", "function", "table")._toast = function(self, content, cb, tag)
  self:AddToQueue({
    content = content,
    callback = cb,
    tag = tag
  })
  if self:IsShow() then
    self:ShowOne()
  end
end
def.method().ShowOne = function(self)
  if self.timer == -1 then
    do
      local tbl = self.waitQueue[1]
      if tbl == nil then
        return
      end
      table.remove(self.waitQueue, 1)
      local toast = Object.Instantiate(self.template)
      toast.parent = self.panelClip
      toast:set_localScale(Vector.Vector3.one)
      toast.transform.localPosition = self.template.transform.localPosition
      toast:SetActive(true)
      local last = self.lastLineCount
      self.lastLineCount = self:SetContent(toast, tbl.content)
      if tbl.callback then
        GameUtil.AddGlobalTimer(4, true, function()
          if tbl.callback then
            tbl.callback(tbl.tag)
          end
        end)
      end
      self:GoUp(1)
      table.insert(self.displayQueue, 1, toast)
      for i = 1, self.lastLineCount - 1 do
        table.insert(self.displayQueue, 1, "empty")
      end
      self.timer = GameUtil.AddGlobalTimer(0.2, true, function()
        self.timer = -1
        self:ShowOne()
      end)
    end
  end
end
def.method("number").GoUp = function(self, offset)
  for i = 1, #self.displayQueue do
    local toast = self.displayQueue[i]
    if toast ~= nil and toast ~= "empty" then
      local from = self.transforms[i]
      local to = self.transforms[i + offset]
      if to ~= nil then
        toast.transform = from
        self:MoveUp(toast, to)
      else
        self:DestroyOne()
      end
    end
  end
end
def.method("table").AddToQueue = function(self, tbl)
  table.insert(self.waitQueue, tbl)
end
def.method("userdata", "string", "=>", "number").SetContent = function(self, toast, content)
  local html = toast:FindDirect("Html_Text"):GetComponent("NGUIHTML")
  html:ForceHtmlText("<p align=center valign=middle linespacing=8><font size=22>" .. content .. "</font></p>")
  local lineCount = html:get_LineCount()
  GameUtil.AddGlobalLateTimer(0.01, true, function()
    local bg = toast:FindDirect("Img_Background"):GetComponent("UISprite")
    local width = html:get_width()
    local height = html:get_height()
    local bgW = width + 44 > ToastTip.MINWIDTH and width + 44 or ToastTip.MINWIDTH
    bg:set_width(bgW)
    bg:set_height(height + 4)
  end)
  return lineCount
end
def.method("userdata", "userdata").MoveUp = function(self, toast, transform)
  TweenTransform.BeginEx(toast, 1.5, toast.transform, transform)
end
def.method().DestroyOne = function(self)
  local oldest = self.displayQueue[#self.displayQueue]
  Object.Destroy(oldest)
  table.remove(self.displayQueue, #self.displayQueue)
  while self.displayQueue[#self.displayQueue] == "empty" do
    table.remove(self.displayQueue, #self.displayQueue)
  end
end
ToastTip.Commit()
return ToastTip
