local Lplus = require("Lplus")
local ECPanelBase = require("GUI.ECPanelBase")
local GangAnnouncementInMailPanel = Lplus.Extend(ECPanelBase, "GangAnnouncementInMailPanel")
local def = GangAnnouncementInMailPanel.define
local instance
local GangUtility = require("Main.Gang.GangUtility")
local GangData = require("Main.Gang.data.GangData")
def.field("table").annoucementList = nil
def.static("=>", GangAnnouncementInMailPanel).Instance = function(self)
  if nil == instance then
    instance = GangAnnouncementInMailPanel()
  end
  return instance
end
def.static().ShowGangAnnouncementInMailPanel = function()
  GangAnnouncementInMailPanel.Instance().annoucementList = GangData.Instance():GetAnnoList()
  GangAnnouncementInMailPanel.Instance():SetDepth(GUIDEPTH.BOTTOM)
  GangAnnouncementInMailPanel.Instance():CreatePanel(RESPATH.PREFAB_GANG_ANNOUNCEMENT_MAIL_PANEL, 0)
  Event.RegisterEvent(ModuleId.FRIEND, gmodule.notifyId.Friend.Friend_OnGangClose, GangAnnouncementInMailPanel.OnClose)
  Event.RegisterEvent(ModuleId.GANG, gmodule.notifyId.Gang.Gang_NewAnno, GangAnnouncementInMailPanel.OnGetNewAnno)
end
def.static().CloseGangAnnouncementInMailPanel = function()
  if GangAnnouncementInMailPanel.Instance():IsShow() then
    GangAnnouncementInMailPanel.Instance():Hide()
  end
end
def.static("table", "table").OnGetNewAnno = function(params, context)
  GangAnnouncementInMailPanel.Instance().annoucementList = GangData.Instance():GetAnnoList()
  GangAnnouncementInMailPanel.Instance():FillHistoryAnnouncements()
  local time = Int64.new(GetServerTime() * 1000)
  GangData.Instance():SetLastReadAnnoTime(time)
  GangData.Instance():SetUnReadAnnoNum(0)
  Event.DispatchEvent(ModuleId.GANG, gmodule.notifyId.Gang.Gang_AnnouncementsChanged, {0})
  gmodule.network.sendProtocol(require("netio.protocol.mzm.gsp.gang.CSendLastAnnouncementTime").new(time))
end
def.override().OnCreate = function(self)
  self:FillHistoryAnnouncements()
  local data = GangData.Instance()
  local unRead = data:GetUnReadAnnoNum()
  if unRead > 0 then
    data:SetUnReadAnnoNum(0)
    Event.DispatchEvent(ModuleId.GANG, gmodule.notifyId.Gang.Gang_AnnouncementsChanged, {0})
    local time = Int64.new(GetServerTime() * 1000)
    data:SetLastReadAnnoTime(time)
    gmodule.network.sendProtocol(require("netio.protocol.mzm.gsp.gang.CSendLastAnnouncementTime").new(time))
  end
  Event.DispatchEvent(ModuleId.FRIEND, gmodule.notifyId.Friend.Friend_OnMailClose, nil)
end
def.override().OnDestroy = function(self)
  Event.UnregisterEvent(ModuleId.FRIEND, gmodule.notifyId.Friend.Friend_OnGangClose, GangAnnouncementInMailPanel.OnClose)
  Event.UnregisterEvent(ModuleId.GANG, gmodule.notifyId.Gang.Gang_NewAnno, GangAnnouncementInMailPanel.OnGetNewAnno)
end
def.method().FillHistoryAnnouncements = function(self)
  local annoucementList = self.annoucementList
  local amount = #annoucementList
  local uiList = self.m_panel:FindDirect("Img_Bg0/Bg_Content/Scroll View/List"):GetComponent("UIList")
  uiList:set_itemCount(amount)
  uiList:Resize()
  GameUtil.AddGlobalLateTimer(0, true, function()
    if not uiList.isnil then
      uiList:Reposition()
    end
  end)
  local announcements = uiList:get_children()
  for i = 1, amount do
    local announcementUI = announcements[i]
    local announcementInfo = annoucementList[i]
    self:FillAnnouncement(announcementUI, i, announcementInfo)
  end
  self:TouchGameObject(self.m_panel, self.m_parent)
  self.m_panel:FindDirect("Img_Bg0/Bg_Content/Scroll View"):GetComponent("UIScrollView"):ResetPosition()
end
def.method("userdata", "number", "table").FillAnnouncement = function(self, announcementUI, index, announcementInfo)
  local Label_Content = announcementUI:FindDirect(string.format("Label_Content_%d", index)):GetComponent("UILabel")
  local Label_Date = announcementUI:FindDirect(string.format("Label_Date_%d", index)):GetComponent("UILabel")
  local content = SensitiveWordsFilter.FilterContent(announcementInfo.announcement, "*")
  Label_Content:set_text(content)
  local date_1 = os.date("*t", Int64.ToNumber(announcementInfo.publishTime / 1000))
  local date1 = string.format(textRes.Friend[33], date_1.year, date_1.month, date_1.day)
  local date2 = os.date("%X", Int64.ToNumber(announcementInfo.publishTime / 1000))
  local date = string.format("%s%s", date1, date2)
  Label_Date:set_text(string.format(textRes.Gang[265], announcementInfo.publisher, date))
end
def.method().Hide = function(self)
  self:DestroyPanel()
  self = nil
end
def.static("table", "table").OnClose = function(p1, p2)
  GangAnnouncementInMailPanel.Instance():Hide()
end
def.method("userdata").onClickObj = function(self, clickobj)
  local id = clickobj.name
  if "Btn_Close" == id then
    self:Hide()
  elseif "Btn_Mail" == id then
    self:Hide()
  end
end
return GangAnnouncementInMailPanel.Commit()
