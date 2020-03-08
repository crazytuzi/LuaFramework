local FILE_NAME = (...)
local Lplus = require("Lplus")
local ECPanelBase = require("GUI.ECPanelBase")
local TopFloatBtnBase = require("Main.MainUI.ui.TopFloatBtnBase")
local PostGuideEntry = Lplus.Extend(TopFloatBtnBase, FILE_NAME)
local Cls = PostGuideEntry
local def = Cls.define
local GUIUtils = require("GUI.GUIUtils")
local instance
def.static("=>", Cls).Instance = function()
  if instance == nil then
    instance = Cls()
    Event.RegisterEvent(ModuleId.MULTIOCCUPATION, gmodule.notifyId.MultiOccupation.GUIDE_EXPIRED, Cls.OnNotifyUpdate)
  end
  return instance
end
def.override().OnShow = function(self)
  self:UpdateNotifyBadge()
end
def.override().OnHide = function(self)
end
def.override("=>", "boolean").IsOpen = function(self)
  local bOpen = require("Main.MultiOccupation.PostGuide.PostGuideMgr").IsShowGuideEntry()
  return bOpen
end
def.method().UpdateNotifyBadge = function(self)
  local Btn_ComeBackNew = self.m_node
  local Img_Red = Btn_ComeBackNew:FindDirect("Img_Red")
  local bAllGuideDone = require("Main.MultiOccupation.PostGuide.PostGuideMgr").Instance():IsAllGuideDone()
  Img_Red:SetActive(not bAllGuideDone)
end
def.override("string").onClick = function(self, id)
  if id == "Btn_TransformGuide" then
    require("Main.MultiOccupation.PostGuide.ui.UIPostGuide").Instance():ShowPanel()
  end
end
def.static("table", "table").OnNotifyUpdate = function(params, context)
  local self = instance
  self:UpdateNotifyBadge()
end
return Cls.Commit()
