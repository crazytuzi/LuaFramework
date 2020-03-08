local Lplus = require("Lplus")
local ComponentBase = require("Main.MainUI.ui.MainUIComponentBase")
local BackToMain = Lplus.Extend(ComponentBase, "BackToMain")
local GUIUtils = require("GUI.GUIUtils")
local def = BackToMain.define
local instance
def.static("=>", BackToMain).Instance = function()
  if instance == nil then
    instance = BackToMain()
    instance:Init()
  end
  return instance
end
def.field("table").uiObjs = nil
def.override().Init = function(self)
end
def.override().OnCreate = function(self)
  if self.m_node == nil then
    return
  end
  self:InitUI()
end
def.override().OnDestroy = function(self)
  self:ClearUI()
end
def.override("boolean").SetVisible = function(self, visible)
end
def.method().InitUI = function(self)
  self.uiObjs = {}
  self.m_node:SetActive(true)
  self.m_node:GetComponent("UIWidget").alpha = 0
  self.m_isShow = true
end
def.method().ClearUI = function(self)
  self.uiObjs = nil
end
def.override().Expand = function(self)
  if self.m_node == nil then
    return
  end
  TweenAlpha.Begin(self.m_node, 0.4, 0)
end
def.override().Shrink = function(self)
  if self.m_node == nil then
    return
  end
  TweenAlpha.Begin(self.m_node, 0.4, 1)
end
def.override("string").OnClick = function(self, id)
  if id == "Btn_Back2" then
    self.m_container:ExpandAll(true)
  end
end
BackToMain.Commit()
return BackToMain
