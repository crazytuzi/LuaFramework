local Lplus = require("Lplus")
local ECPanelBase = require("GUI.ECPanelBase")
local GUIUtils = require("GUI.GUIUtils")
local StoryWallPanel = Lplus.Extend(ECPanelBase, "StoryWallPanel")
local ECUIModel = require("Model.ECUIModel")
local def = StoryWallPanel.define
local instance
def.field("table").uiTbl = nil
def.field("table").storyInfo = nil
def.static("=>", StoryWallPanel).Instance = function()
  if not instance then
    instance = StoryWallPanel()
    instance.m_TrigGC = true
  end
  return instance
end
def.method("table").ShowPanel = function(self, storyInfo)
  if not self:IsShow() then
    self:SetModal(true)
    self:CreatePanel(RESPATH.PREFAB_STORYWALL, 1)
  end
  self.storyInfo = storyInfo
  if storyInfo and storyInfo.id and storyInfo.id > 0 then
    gmodule.network.sendProtocol(require("netio.protocol.mzm.gsp.storywall.CReadStoryReq").new(storyInfo.id))
  end
end
def.override().OnCreate = function(self)
  self:InitUI()
end
def.override().OnDestroy = function(self)
end
def.method().InitUI = function(self)
  if not self.uiTbl then
    self.uiTbl = {}
  end
  local uiTbl = self.uiTbl
  local Img_Bg0 = self.m_panel:FindDirect("Img_Bg0")
  local Label_Title = Img_Bg0:FindDirect("Img_TitleBg/Label_Title")
  local ScrollView = self.m_panel:FindDirect("Scroll View")
  local Label_Content = ScrollView:FindDirect("Label_Content")
  uiTbl.Label_Title = Label_Title
  uiTbl.ScrollView = ScrollView
  if self.storyInfo then
    Label_Title:GetComponent("UILabel"):set_text(self.storyInfo.name or "")
    Label_Content:GetComponent("UILabel"):set_text(self.storyInfo.content or "")
  else
    Label_Title:GetComponent("UILabel"):set_text("")
    Label_Content:GetComponent("UILabel"):set_text("")
  end
end
def.method("userdata").onClickObj = function(self, clickobj)
  local id = clickobj.name
  if id == "Btn_Close" then
    self:DestroyPanel()
  else
    warn("gangrace panel btn:", id)
  end
end
def.method().onBtnConfirmClick = function(self)
end
return StoryWallPanel.Commit()
