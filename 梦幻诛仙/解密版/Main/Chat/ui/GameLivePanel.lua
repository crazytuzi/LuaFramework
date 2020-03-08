local Lplus = require("Lplus")
local ECPanelBase = require("GUI.ECPanelBase")
local Vector = require("Types.Vector")
local GUIUtils = require("GUI.GUIUtils")
local ECQQEC = require("ProxySDK.ECQQEC")
local ECLuaString = require("Utility.ECFilter")
local GameLivePanel = Lplus.Extend(ECPanelBase, "GameLivePanel")
local def = GameLivePanel.define
def.field("number").m_NewCommentNum = 0
def.field("boolean").m_IsExpand = false
def.field("table").m_UIGO = nil
def.field("table").m_CommentData = nil
local instance
def.static("=>", GameLivePanel).Instance = function()
  if not instance then
    instance = GameLivePanel()
  end
  return instance
end
def.static("table", "table").OnQQECCommentNotify = function(p1, p2)
  warn("OnQQECCommentNotify", p1.type, " ", p1.nick, " ", p1.content, " ", p1.time, " ", p1.timeValue)
  if not instance.m_panel or instance.m_panel.isnil then
    return
  end
  instance.m_NewCommentNum = instance.m_NewCommentNum + 1
  if not instance.m_CommentData then
    instance.m_CommentData = {}
  end
  table.insert(instance.m_CommentData, 1, {
    type = p1.type,
    nick = p1.nick,
    content = p1.content,
    time = p1.time,
    timeValue = p1.timeValue
  })
  instance:Update()
end
def.method().ShowPanel = function(self)
  if self:IsShow() then
    self:DestroyPanel()
  end
  self:CreatePanel(RESPATH.PREFAB_GAME_LIVE_PANEL, GUILEVEL.NORMAL)
end
def.override().OnCreate = function(self)
  self:InitUI()
  self:Update()
  Event.RegisterEvent(ModuleId.CHAT, gmodule.notifyId.Chat.QQECCommentNotify, GameLivePanel.OnQQECCommentNotify)
end
def.override().OnDestroy = function(self)
  self.m_IsExpand = false
  self.m_NewCommentNum = 0
  self.m_UIGO = nil
  self.m_CommentData = nil
  Event.UnregisterEvent(ModuleId.CHAT, gmodule.notifyId.Chat.QQECCommentNotify, GameLivePanel.OnQQECCommentNotify)
end
def.method("string").onClick = function(self, id)
  if id == "Btn_Close" then
    GUIUtils.SetActive(self.m_UIGO.Group_Live, false)
    GUIUtils.SetActive(self.m_UIGO.Btn_Close, false)
    GUIUtils.SetActive(self.m_UIGO.Btn_Open, true)
    self.m_IsExpand = false
    self.m_NewCommentNum = 0
    self:UpdateNumerView()
  elseif id == "Btn_Open" then
    GUIUtils.SetActive(self.m_UIGO.Group_Live, true)
    GUIUtils.SetActive(self.m_UIGO.Btn_Close, true)
    GUIUtils.SetActive(self.m_UIGO.Btn_Open, false)
    self.m_IsExpand = true
    self.m_NewCommentNum = 0
    self:Update()
  elseif id == "Btn_Finish" then
    ECQQEC.StopLive()
  end
end
def.method().InitUI = function(self)
  self.m_UIGO = {}
  self.m_UIGO.Btn_Close = self.m_panel:FindDirect("Img_Bg0/Btn_Close")
  self.m_UIGO.Btn_Open = self.m_panel:FindDirect("Img_Bg0/Btn_Open")
  self.m_UIGO.Group_Live = self.m_panel:FindDirect("Img_Bg0/Group_Live")
  self.m_UIGO.ScrollView = self.m_UIGO.Group_Live:FindDirect("Img_Bg1/Scroll View")
  self.m_UIGO.List_Content = self.m_UIGO.Group_Live:FindDirect("Img_Bg1/Scroll View/List_Content")
  self.m_UIGO.Img_Red = self.m_UIGO.Btn_Open:FindDirect("Img_Red")
  GUIUtils.SetActive(self.m_UIGO.Btn_Close, false)
  GUIUtils.SetActive(self.m_UIGO.Group_Live, false)
end
def.method("userdata", "number", "table").FillInfo = function(self, item, index, commentData)
  local contentGO = item:FindDirect("Label_Content")
  local htmlCO = contentGO:GetComponent("NGUIHTML")
  local content = textRes.Chat[51]:format(os.date("%X", commentData.timeValue), commentData.nick, commentData.content)
  local strLen, aNum, hNum = ECLuaString.Len(content)
  warn(item.name, "FillInfo", content:len(), ECLuaString.Len(content))
  htmlCO:ForceHtmlText("<p align=left valign=middle linespacing=8><font size=22>" .. content .. "</font></p>")
  local count = 0
  for i = 5, contentGO.childCount - 1 do
    local child = contentGO:GetChild(i)
    count = count + 1
    if child then
      GUIUtils.SetActive(child, false)
    end
  end
  if count ~= 0 then
    contentGO:GetComponent("UIWidget").height = 60
  end
end
def.method().UpdateNumerView = function(self)
  local textGO = self.m_UIGO.Img_Red:FindDirect("Label_Number")
  local number = self.m_NewCommentNum
  warn("UpdateNumerView", number)
  local desc = tostring(number)
  if number >= 99 then
    desc = desc .. "+"
  end
  GUIUtils.SetActive(self.m_UIGO.Img_Red, number > 0)
  GUIUtils.SetText(textGO, desc)
end
def.method().Reposition = function(self)
  local pad = 10
  local offset = 0
  local listGO = self.m_UIGO.List_Content
  local baseObj = listGO:GetChild(0)
  if not baseObj then
    warn("Can not Find baseObj", listGO:GetChild(0).name)
    return
  end
  local basePos = baseObj.localPosition
  warn(basePos, "~~~~~~~~~~~", listGO.childCount)
  for i = 0, listGO.childCount - 1 do
    local child = listGO:GetChild(i)
    local groupGO = child:FindDirect("Group_Content")
    if groupGO then
      local childWidget = child:GetComponent("UIWidget")
      local groupWidget = groupGO:GetComponent("UIWidget")
      local labelWidget = groupGO:FindDirect("Img_ContentBg"):GetComponent("UIWidget")
      childWidget.height = labelWidget.height
      groupWidget.height = labelWidget.height
      if i > 0 then
        local lastChild = listGO:GetChild(i - 1):FindDirect("Group_Content/Img_ContentBg")
        local widget = lastChild:GetComponent("UIWidget")
        warn(child.name, "  ", i, "widget height ", widget.height, offset)
        offset = offset - widget.height
        local pos = child.localPosition
        pos.y = basePos.y + offset
        child.localPosition = pos
      end
    end
  end
end
def.method().Update = function(self)
  self:UpdateNumerView()
  if not self.m_IsExpand then
    return
  end
  local scrollListObj = self.m_UIGO.List_Content
  local uiScrollList = scrollListObj:GetComponent("UIScrollList")
  local commentData = self.m_CommentData
  if not commentData then
    warn("There is no Commonent Data")
    ScrollList_setCount(uiScrollList, 0)
    return
  end
  local scrollViewObj = self.m_UIGO.ScrollView
  local GUIScrollList = scrollListObj:GetComponent("GUIScrollList")
  if not GUIScrollList then
    scrollListObj:AddComponent("GUIScrollList")
  end
  ScrollList_setUpdateFunc(uiScrollList, function(item, i)
    self:FillInfo(item, i, commentData[i])
  end)
  ScrollList_setCount(uiScrollList, #commentData)
  self.m_msgHandler:Touch(scrollListObj)
  scrollViewObj:GetComponent("UIScrollView"):ResetPosition()
end
return GameLivePanel.Commit()
