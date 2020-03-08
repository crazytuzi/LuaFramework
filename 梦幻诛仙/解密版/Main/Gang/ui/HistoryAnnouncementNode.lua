local Lplus = require("Lplus")
local TabNode = require("GUI.TabNode")
local ECPanelBase = require("GUI.ECPanelBase")
local HistoryAnnouncementNode = Lplus.Extend(TabNode, "HistoryAnnouncementNode")
local GangData = require("Main.Gang.data.GangData")
local GangUtility = require("Main.Gang.GangUtility")
local GangAnnouncementPanel = Lplus.ForwardDeclare("GangAnnouncementPanel")
local def = HistoryAnnouncementNode.define
def.override(ECPanelBase, "userdata").Init = function(self, base, node)
  TabNode.Init(self, base, node)
end
def.override().OnShow = function(self)
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
end
def.method().FillHistoryAnnouncements = function(self)
  local annoucementList = GangAnnouncementPanel.Instance().annoucementList
  local amount = #annoucementList
  if amount == 0 then
    self.m_node:FindDirect("Group_Empty"):SetActive(true)
    self.m_node:FindDirect("Scroll View"):SetActive(false)
    return
  else
    self.m_node:FindDirect("Group_Empty"):SetActive(false)
    self.m_node:FindDirect("Scroll View"):SetActive(true)
  end
  local uiList = self.m_node:FindDirect("Scroll View/List"):GetComponent("UIList")
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
  self.m_base:TouchGameObject(self.m_base.m_panel, self.m_base.m_parent)
  self.m_node:FindDirect("Scroll View"):GetComponent("UIScrollView"):ResetPosition()
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
def.override().OnHide = function(self)
end
def.override("userdata").onClickObj = function(self, clickobj)
end
HistoryAnnouncementNode.Commit()
return HistoryAnnouncementNode
