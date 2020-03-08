local Lplus = require("Lplus")
local AnnouncementTip = require("GUI.AnnouncementTip")
local InteractiveAnnouncementTip = Lplus.Extend(AnnouncementTip, "InteractiveAnnouncementTip")
local instance
local def = InteractiveAnnouncementTip.define
def.const("number").MIN_REMAIN_TIME = 5
def.const("string").DEFAULT_BG_NAME = "Group_1"
def.const("number").MAX_INTERACTIVE_PRIORITY = 6
def.const("number").SELF_DEFINE_ANNOUNCE_TYPE = -1
def.field("table").specialAnnounceCfg = nil
def.static().PreInit = function()
  if instance == nil then
    instance = InteractiveAnnouncementTip()
    instance:SetDepth(GUIDEPTH.TOPMOST)
    instance:CreatePanel(RESPATH.SOCIAL_ANNOUNCE_PANEL, -1)
  end
end
def.static("string", "number").AnnounceWithModuleId = function(content, moduleId)
  InteractiveAnnouncementTip.AnnounceWithModuleIdAndDuration(content, moduleId, InteractiveAnnouncementTip.MIN_REMAIN_TIME)
end
def.static("string", "number", "number").AnnounceWithModuleIdAndDuration = function(content, moduleId, duration)
  if instance ~= nil then
    instance:ShowAnnounceWithModuleIdAndDuration(content, moduleId, duration)
  end
end
def.static("string", "number").InteractiveAnnounceWithPriority = function(content, priority)
  InteractiveAnnouncementTip.InteractiveAnnounceWithPriorotyAndDuration(content, priority, InteractiveAnnouncementTip.MIN_REMAIN_TIME)
end
def.static("string", "number", "number").InteractiveAnnounceWithPriorotyAndDuration = function(content, priority, duration)
  InteractiveAnnouncementTip.SelfDefineAnnounce(content, priority, duration, InteractiveAnnouncementTip.DEFAULT_BG_NAME)
end
def.static("string", "number", "string").InteractiveAnnounceWithPriorityAndSprite = function(content, priority, spName)
  InteractiveAnnouncementTip.SelfDefineAnnounce(content, priority, InteractiveAnnouncementTip.MIN_REMAIN_TIME, spName)
end
def.static("string", "number", "number", "string").SelfDefineAnnounce = function(content, priority, duration, spName)
  if instance ~= nil then
    instance:ShowSelfDefineAnnounce(content, priority, duration, spName)
  end
end
def.override().OnCreate = function(self)
  self:LoadCfgData()
  self:InitUI()
  self:InitQueuePriority(self:GetMaxAnnouncePriority())
  Event.RegisterEventWithContext(ModuleId.LOGIN, gmodule.notifyId.Login.LEAVE_WORLD, InteractiveAnnouncementTip.ClearAnnounce, self)
end
def.method().InitUI = function(self)
  self.label1 = self.m_panel:FindDirect("Panel_Clip/Img_Background/Label_Text1")
  self.label2 = self.m_panel:FindDirect("Panel_Clip/Img_Background/Label_Text2")
  self.label1:GetComponent("NGUIHTML"):set_maxLineNumber(1)
  self.label2:GetComponent("NGUIHTML"):set_maxLineNumber(1)
  self.label1:GetComponent("NGUIHTML"):set_maxLineWidth(AnnouncementTip.MAX_ANNOUNCE_WIDTH)
  self.label2:GetComponent("NGUIHTML"):set_maxLineWidth(AnnouncementTip.MAX_ANNOUNCE_WIDTH)
  self.m_panel:SetActive(false)
  self.containerWidth = self.m_panel:FindDirect("Panel_Clip/Img_Background"):GetComponent("UIWidget").width
  self.downY = self.m_panel:FindDirect("Panel_Clip/Img_Background/Widget_Down").localPosition.y
  self.middleY = self.m_panel:FindDirect("Panel_Clip/Img_Background/Widget_Middle").localPosition.y
  self.upY = self.m_panel:FindDirect("Panel_Clip/Img_Background/Widget_Up").localPosition.y
end
def.method().LoadCfgData = function(self)
  self.specialAnnounceCfg = {}
  local entries = DynamicData.GetTable(CFG_PATH.DATA_INTERACTIVE_ANNOUNCE_CFG)
  local count = DynamicDataTable.GetRecordsCount(entries)
  DynamicDataTable.FastGetRecordBegin(entries)
  for i = 1, count do
    local cfg = {}
    local entry = DynamicDataTable.GetRecordByIdx(entries, i - 1)
    cfg.id = DynamicRecord.GetIntValue(entry, "id")
    cfg.noticeType = DynamicRecord.GetIntValue(entry, "noticeType")
    cfg.priority = DynamicRecord.GetIntValue(entry, "priority")
    cfg.pictureSetName = DynamicRecord.GetStringValue(entry, "pictureSetName")
    self.specialAnnounceCfg[cfg.noticeType] = cfg
  end
  DynamicDataTable.FastGetRecordEnd(entries)
end
def.method("=>", "number").GetMaxAnnouncePriority = function(self)
  local NoticeType = require("consts.mzm.gsp.function.confbean.NoticeType")
  local maxPriority = 0
  for name, priority in pairs(NoticeType) do
    if priority > maxPriority then
      maxPriority = priority
    end
  end
  return math.max(maxPriority, InteractiveAnnouncementTip.MAX_INTERACTIVE_PRIORITY)
end
def.method("string", "number", "number").ShowAnnounceWithModuleIdAndDuration = function(self, content, moduleId, duration)
  local priority = self:GetPriorityByModuleId(moduleId)
  self:_AddSpecialAnnounceToQueue(moduleId, content, priority, duration)
  if not self.block then
    self:ShowOne()
  end
end
def.method("number", "string", "number", "number")._AddSpecialAnnounceToQueue = function(self, moduleId, content, priority, duration)
  if self.waitQueue[priority] == nil then
    warn("\232\175\165\229\133\172\229\145\138\231\154\132\228\188\152\229\133\136\231\186\167\228\184\141\232\162\171\229\133\129\232\174\184:" .. priority)
  else
    local announce = {}
    announce.duration = duration
    announce.content = string.format(textRes.AnnounceMent[74], content)
    announce.moduleId = moduleId
    self:_AddAnnounceToWaitQueue(priority, announce)
  end
end
def.method("string", "number", "number", "string").ShowSelfDefineAnnounce = function(self, content, priority, duration, spName)
  if priority < 0 then
    priority = 0
  elseif priority > self:GetMaxAnnouncePriority() then
    priority = self:GetMaxAnnouncePriority()
  end
  local announce = {}
  announce.duration = duration
  announce.content = string.format(textRes.AnnounceMent[74], content)
  announce.moduleId = InteractiveAnnouncementTip.SELF_DEFINE_ANNOUNCE_TYPE
  announce.spName = spName
  self:_AddAnnounceToWaitQueue(priority, announce)
  if not self.block then
    self:ShowOne()
  end
end
def.override("=>", "table")._PopWaitAnnounce = function(self)
  local announce = AnnouncementTip._PopWaitAnnounce(self)
  if announce.moduleId == InteractiveAnnouncementTip.SELF_DEFINE_ANNOUNCE_TYPE then
    self:ChangeAnnounceStyle(announce.spName)
  else
    local interactiveCfg = self.specialAnnounceCfg[announce.moduleId]
    if interactiveCfg ~= nil then
      self:ChangeAnnounceStyle(interactiveCfg.pictureSetName)
    end
  end
  return announce
end
def.method("string").ChangeAnnounceStyle = function(self, spName)
  local ctrlCount = self.m_panel.transform.childCount
  for i = 1, ctrlCount do
    local child = self.m_panel.transform:GetChild(i - 1).gameObject
    if child.name ~= "Panel_Clip" then
      child:SetActive(false)
    end
  end
  if self.m_panel:FindDirect(spName) ~= nil then
    self.m_panel:FindDirect(spName):SetActive(true)
  else
    self.m_panel:FindDirect(InteractiveAnnouncementTip.DEFAULT_BG_NAME):SetActive(true)
  end
end
def.method("number", "=>", "number").GetPriorityByModuleId = function(self, moduleId)
  if self.specialAnnounceCfg[moduleId] == nil then
    return self.maxAnnouncePriority
  end
  return self.specialAnnounceCfg[moduleId].priority
end
def.override("table").ClearAnnounce = function(self, params)
  AnnouncementTip.ClearAnnounce(self, params)
end
InteractiveAnnouncementTip.Commit()
return InteractiveAnnouncementTip
