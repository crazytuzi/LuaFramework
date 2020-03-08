local Lplus = require("Lplus")
local AnnouncementTip = require("GUI.AnnouncementTip")
local RareItemAnnouncementTip = Lplus.Extend(AnnouncementTip, "RareItemAnnouncementTip")
local instance
local def = RareItemAnnouncementTip.define
def.const("number").MIN_REMAIN_TIME = 3
def.const("number").RARE_ANNOUNCE_PRIORITY = 0
def.static().PreInit = function()
  if instance == nil then
    instance = RareItemAnnouncementTip()
    instance:SetDepth(GUIDEPTH.TOPMOST)
    instance:CreatePanel(RESPATH.RARE_ITEM_ANNOUNCE_PANEL, -1)
  end
end
def.static("string").AnnounceRareItem = function(content)
  instance:_AddAnnounceWithPriorityAndDuration(string.format(textRes.AnnounceMent[76], content), RareItemAnnouncementTip.RARE_ANNOUNCE_PRIORITY, RareItemAnnouncementTip.MIN_REMAIN_TIME)
end
def.override().OnCreate = function(self)
  self:InitUI()
  self:InitQueuePriority(self:GetMaxAnnouncePriority())
  Event.RegisterEventWithContext(ModuleId.LOGIN, gmodule.notifyId.Login.LEAVE_WORLD, RareItemAnnouncementTip.ClearAnnounce, self)
end
def.method().InitUI = function(self)
  self.label1 = self.m_panel:FindDirect("Panel_Clip/Img_Background/Label_Text1")
  self.label2 = self.m_panel:FindDirect("Panel_Clip/Img_Background/Label_Text2")
  self.label1:GetComponent("NGUIHTML"):set_maxLineNumber(1)
  self.label2:GetComponent("NGUIHTML"):set_maxLineNumber(1)
  self.label1:GetComponent("NGUIHTML"):set_maxLineWidth(AnnouncementTip.MAX_ANNOUNCE_WIDTH)
  self.label2:GetComponent("NGUIHTML"):set_maxLineWidth(AnnouncementTip.MAX_ANNOUNCE_WIDTH)
  self.downY = self.m_panel:FindDirect("Panel_Clip/Img_Background/Widget_Down").localPosition.y
  self.middleY = self.m_panel:FindDirect("Panel_Clip/Img_Background/Widget_Middle").localPosition.y
  self.upY = self.m_panel:FindDirect("Panel_Clip/Img_Background/Widget_Up").localPosition.y
  GameUtil.AddGlobalTimer(0, true, function()
    self.containerWidth = self.m_panel:FindDirect("Panel_Clip/Img_Background"):GetComponent("UIWidget").width
    self.m_panel:SetActive(false)
  end)
end
def.method("=>", "number").GetMaxAnnouncePriority = function(self)
  return RareItemAnnouncementTip.RARE_ANNOUNCE_PRIORITY
end
def.override("table").ClearAnnounce = function(self, params)
  AnnouncementTip.ClearAnnounce(self, params)
end
RareItemAnnouncementTip.Commit()
return RareItemAnnouncementTip
