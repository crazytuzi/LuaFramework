local Lplus = require("Lplus")
local ECPanelBase = require("GUI.ECPanelBase")
local GameNoticePanel = Lplus.Extend(ECPanelBase, "GameNoticePanel")
local Vector = require("Types.Vector")
local GUIUtils = require("GUI.GUIUtils")
local UpdateNoticeModule = require("Main.UpdateNotice.UpdateNoticeModule")
local NoticeData = require("Main.UpdateNotice.NoticeData")
local TagType = NoticeData.TagType
local def = GameNoticePanel.define
local TagSprites = {
  [TagType.None] = "nil",
  [TagType.Notice] = "anno",
  [TagType.Welfare] = "fuli",
  [TagType.Discount] = "specialprize"
}
def.field("table").notices = nil
def.field("table").uiObjs = nil
def.field("function").onClose = nil
def.field("number").selectedTab = 0
def.field("table").selectedNotice = nil
def.field("table").picNoticeSize = nil
def.field("table").innerbannerNotice = nil
def.field("boolean").hasSetBanner = false
def.field("boolean").hasSetBannerLink = false
def.field("userdata").lastText2d = nil
local instance
def.static("=>", GameNoticePanel).Instance = function()
  if instance == nil then
    instance = GameNoticePanel()
    instance:Init()
  end
  return instance
end
def.method().Init = function(self)
end
def.method("table").ShowPanel = function(self, notices)
  self:ShowPanelEx(notices, nil)
end
def.method("table", "function").ShowPanelEx = function(self, notices, onClose)
  if self.m_panel and not self.m_panel.isnil then
    self:DestroyPanel()
  end
  local filterdNotices = {}
  local focusIndex
  for i, v in ipairs(notices) do
    if v.type == NoticeData.NoticeType.INNER_BANNER then
      self.innerbannerNotice = v
    else
      filterdNotices[#filterdNotices + 1] = v
      if focusIndex == nil and not UpdateNoticeModule.Instance():HasTodayShow(v.id) then
        focusIndex = #filterdNotices
      end
    end
  end
  if #filterdNotices == 0 then
    if onClose then
      onClose(false)
    end
    return
  end
  self.selectedTab = focusIndex and focusIndex or 1
  self.notices = filterdNotices
  self.onClose = onClose
  self:CreatePanel(RESPATH.PREFAB_GAME_NOTICE_PANEL_RES, 1)
  self:SetDepth(_G.GUIDEPTH.TOP)
  self:SetModal(true)
end
def.override().OnCreate = function(self)
  self:InitUI()
end
def.method().InitUI = function(self)
  self.uiObjs = {}
  self.uiObjs.Img_Bg0 = self.m_panel:FindDirect("Img_Bg0")
  self.uiObjs.Img_BgTab = self.uiObjs.Img_Bg0:FindDirect("Img_BgTab")
  self.uiObjs.ScrollView_Tab = self.uiObjs.Img_BgTab:FindDirect("Scroll View_Tab")
  self.uiObjs.List_Tab = self.uiObjs.ScrollView_Tab:FindDirect("List_Tab")
  self.uiObjs.Group_Notice = self.uiObjs.Img_Bg0:FindDirect("Group_Notice")
  self.uiObjs.Img_NoticeImg = self.uiObjs.Group_Notice:FindDirect("Img_NoticeImg")
  self.uiObjs.Img_NoticeLink = self.uiObjs.Group_Notice:FindDirect("Img_NoticeLink")
  self.uiObjs.Img_NoticeTxt = self.uiObjs.Group_Notice:FindDirect("Img_NoticeTxt")
  self.uiObjs.Group_Caption = self.uiObjs.Img_Bg0:FindDirect("Group_Caption")
  self.uiObjs.Label_Caption = self.uiObjs.Group_Caption:FindDirect("Label_Caption")
  local uiTexture = self.uiObjs.Img_NoticeImg:FindDirect("Scroll View_Server/Texture"):GetComponent("UITexture")
  self.picNoticeSize = {
    width = uiTexture.width,
    height = uiTexture.height
  }
  self.picNoticeSize.aspectRatio = uiTexture.width / uiTexture.height
  local Btn_NoticeTab = self.uiObjs.List_Tab:FindDirect("Btn_NoticeTab")
  if Btn_NoticeTab then
    local uiToggle = Btn_NoticeTab:GetComponent("UIToggle")
    uiToggle:set_startsActive(false)
  end
end
def.override("boolean").OnShow = function(self, isShow)
  if isShow then
    self:UpdateUI()
  end
end
def.override().OnDestroy = function(self)
  self.uiObjs = nil
  self.notices = nil
  self.selectedNotice = nil
  self.picNoticeSize = nil
  self.hasSetBanner = false
  self.hasSetBannerLink = false
  self.lastText2d = nil
  self.innerbannerNotice = nil
  if self.onClose then
    self.onClose(true)
    self.onClose = nil
  end
end
def.method("userdata").onClickObj = function(self, obj)
  local id = obj.name
  local linkText = obj:GetComponent("NGUILinkText")
  if linkText then
    self:HandleLinkText(linkText)
  else
    self:onClick(id)
  end
end
def.method("string").onClick = function(self, id)
  if id == "Btn_Close" then
    self:DestroyPanel()
  elseif id == "Modal" then
    self:DestroyPanel()
  elseif id == "Btn_Check" then
    self:OnBtnGoClicked()
  elseif string.sub(id, 1, #"Btn_NoticeTab_") == "Btn_NoticeTab_" then
    local index = tonumber(string.sub(id, #"Btn_NoticeTab_" + 1, -1))
    self:OnTabClicked(index)
  end
end
def.method().OnBtnGoClicked = function(self)
  local UpdateNoticeModule = require("Main.UpdateNotice.UpdateNoticeModule")
  UpdateNoticeModule.Instance():OperateNoticeUrl(self.selectedNotice)
  local noticeId = self.selectedNotice.id
  local ECMSDK = require("ProxySDK.ECMSDK")
  ECMSDK.SendTLogToServer(_G.TLOGTYPE.CLICKNOTICECLINK, {noticeId})
end
def.method().OnImageClicked = function(self)
  if self.selectedNotice:HasExternalLink() then
    local url = self.selectedNotice.url
    self:OpenUrl(url)
  end
end
def.method("string").OpenUrl = function(self, url)
  require("Main.ECGame").Instance():OpenUrl(url)
end
def.method("number").Goto = function(self, operationId)
  self:DestroyPanel()
  require("Main.Grow.GrowUtils").ApplyOperation(operationId)
end
def.method("number").OnTabClicked = function(self, index)
  self.selectedTab = index
  self:UpdateSelectedNotice()
end
def.method("userdata").HandleLinkText = function(self, linkText)
  local url = ""
  if getmetatable(linkText) then
    url = linkText.linkText
  else
    url = GUIUtils.GetUILabelTxt(linkText.gameObject) or ""
  end
  self:OpenUrl(url)
end
def.method().UpdateUI = function(self)
  self:SetTabList(self.notices)
  self:UpdateSelectedNotice()
end
def.method("table").SetTabList = function(self, notices)
  if notices == nil then
    return
  end
  local itemCount = #notices
  local uiList = self.uiObjs.List_Tab:GetComponent("UIList")
  uiList.itemCount = itemCount
  uiList:Resize()
  local items = uiList.children
  for i = 1, itemCount do
    self:SetTabListItem(i, items[i], notices[i])
  end
end
def.method("number", "userdata", "table").SetTabListItem = function(self, index, listItem, notice)
  local labelObj = listItem:FindDirect("Label_Tab_" .. index)
  local title = notice.title
  GUIUtils.SetText(labelObj, title)
  local Img_Tag = listItem:FindDirect("Img_Tag_" .. index)
  local Img_Red = listItem:FindDirect("Img_Red_" .. index)
  local tagSprite = TagSprites[notice.tag] or "nil"
  GUIUtils.SetActive(Img_Tag, true)
  GUIUtils.SetSprite(Img_Tag, tagSprite)
  local needShow = not UpdateNoticeModule.Instance():HasNoticeShow(notice.id)
  GUIUtils.SetActive(Img_Red, needShow)
  if index == self.selectedTab then
    GUIUtils.Toggle(listItem, true)
  end
end
def.method().UpdateSelectedNotice = function(self)
  if self.notices == nil then
    return
  end
  local notice = self.notices[self.selectedTab]
  if notice == nil then
    return
  end
  self.selectedNotice = notice
  self:SetTitle(notice.title)
  self:SetNotice(notice)
  UpdateNoticeModule.Instance():MarkTodayAsShowed(notice.id)
  self:SetTabList(self.notices)
  local ECMSDK = require("ProxySDK.ECMSDK")
  ECMSDK.SendTLogToServer(_G.TLOGTYPE.VIEWNOTICE, {
    notice.id
  })
end
def.method("table").SetNotice = function(self, notice)
  if notice == nil then
    GUIUtils.SetActive(self.uiObjs.Img_NoticeImg, false)
    GUIUtils.SetActive(self.uiObjs.Img_NoticeLink, false)
    GUIUtils.SetActive(self.uiObjs.Img_NoticeTxt, false)
    return
  end
  if notice.type == NoticeData.NoticeType.UNIQUE_BANNER then
    self:SetPictureNotice(notice)
  elseif notice:HasExternalLink() then
    self:SetNormalNoticeWithExternLink(notice)
  else
    self:SetNormalNotice(notice)
  end
end
def.method("table").SetPictureNotice = function(self, notice)
  GUIUtils.SetActive(self.uiObjs.Img_NoticeImg, true)
  GUIUtils.SetActive(self.uiObjs.Img_NoticeLink, false)
  GUIUtils.SetActive(self.uiObjs.Img_NoticeTxt, false)
  GUIUtils.SetActive(self.uiObjs.Group_Caption, false)
  GUIUtils.SetActive(self.uiObjs.Img_NoticeImg:FindDirect("Img_Up"), false)
  GUIUtils.SetActive(self.uiObjs.Img_NoticeImg:FindDirect("Img_Down"), false)
  local Texture = self.uiObjs.Img_NoticeImg:FindDirect("Scroll View_Server/Texture")
  local uiTexture = Texture:GetComponent("UITexture")
  uiTexture.mainTexture = nil
  local picPath = notice.pictureUrl
  GUIUtils.FillTextureFromURL(Texture, picPath, function(tex2d)
    if tex2d == nil or Texture.isnil then
      return
    end
    local tex2dWidth, text2dHeight = tex2d.width, tex2d.height
    local tex2dRatio = tex2dWidth / text2dHeight
    local width, height = 0, 0
    local FIX_WIDTH = uiTexture.width
    width = FIX_WIDTH
    height = width / tex2dRatio
    uiTexture.mainTexture = tex2d
    uiTexture.width = width
    uiTexture.height = height
    self.lastText2d = tex2d
  end, true)
  local hasExternalLink = notice:HasExternalLink()
  local Btn_Check = self.uiObjs.Img_NoticeImg:FindDirect("Scroll View_Server/Btn_Check")
  GUIUtils.SetActive(Btn_Check, hasExternalLink)
  local hrefText = notice.hrefText ~= "" and notice.hrefText or textRes.UpdateNotice[2]
  local Label_Check = GUIUtils.FindDirect(Btn_Check, "Label_Check")
  GUIUtils.SetText(Label_Check, hrefText)
end
def.method("table").SetNormalNoticeWithExternLink = function(self, notice)
  GUIUtils.SetActive(self.uiObjs.Img_NoticeImg, false)
  GUIUtils.SetActive(self.uiObjs.Img_NoticeLink, true)
  GUIUtils.SetActive(self.uiObjs.Img_NoticeTxt, false)
  GUIUtils.SetActive(self.uiObjs.Group_Caption, true)
  GUIUtils.SetActive(self.uiObjs.Img_NoticeLink:FindDirect("Img_Up"), false)
  GUIUtils.SetActive(self.uiObjs.Img_NoticeLink:FindDirect("Img_Down"), false)
  local TOP_Y = 180
  local scrollView = self.uiObjs.Img_NoticeLink:FindDirect("Scroll View_Server")
  scrollView:GetComponent("UIScrollView"):ResetPosition()
  local htmlObj = self.uiObjs.Img_NoticeLink:FindDirect("Scroll View_Server/html")
  local Texture_TopBanner = self.uiObjs.Img_NoticeLink:FindDirect("Scroll View_Server/Texture_TopBanner")
  if Texture_TopBanner == nil then
    local template = self.uiObjs.Img_NoticeTxt:FindDirect("Scroll View_Server/Texture_TopBanner")
    Texture_TopBanner = GameObject.Instantiate(template)
    Texture_TopBanner.name = "Texture_TopBanner"
    Texture_TopBanner.parent = scrollView
    Texture_TopBanner.localScale = Vector.Vector3.one
    Texture_TopBanner.localPosition = Vector.Vector3.new(0, TOP_Y, 0)
    local uiDragScrollView = Texture_TopBanner:GetComponent("UIDragScrollView")
    uiDragScrollView.scrollView = scrollView:GetComponent("UIScrollView")
  end
  Texture_TopBanner:GetComponent("UITexture").mainTexture = nil
  local html = htmlObj:GetComponent("NGUIHTML")
  local pictureUrl = self:GetPictureURL(notice)
  if #pictureUrl > 0 then
    GUIUtils.SetActive(Texture_TopBanner, true)
    htmlObj.localPosition = Vector.Vector3.new(-258, TOP_Y, 0)
    GUIUtils.FillTextureFromURL(Texture_TopBanner, pictureUrl, function(tex2d)
      if tex2d == nil or Texture_TopBanner.isnil then
        return
      end
      local tex2dWidth, text2dHeight = tex2d.width, tex2d.height
      local tex2dRatio = tex2dWidth / text2dHeight
      local width, height = 0, 0
      local uiTexture = Texture_TopBanner:GetComponent("UITexture")
      local FIX_WIDTH = uiTexture.width
      width = FIX_WIDTH
      height = width / tex2dRatio
      uiTexture.mainTexture = tex2d
      uiTexture.width = width
      uiTexture.height = height
      local padding = 10
      local y = TOP_Y - height - padding
      htmlObj.localPosition = Vector.Vector3.new(-258, y, 0)
      self:UpdateGoToBtn()
    end, true)
    self.hasSetBannerLink = true
  else
    htmlObj.localPosition = Vector.Vector3.new(-258, TOP_Y, 0)
    GUIUtils.SetActive(Texture_TopBanner, false)
  end
  self:LoadAndSetHtmlContent(html, notice)
end
def.method("table").SetNormalNotice = function(self, notice)
  GUIUtils.SetActive(self.uiObjs.Img_NoticeImg, false)
  GUIUtils.SetActive(self.uiObjs.Img_NoticeLink, false)
  GUIUtils.SetActive(self.uiObjs.Img_NoticeTxt, true)
  GUIUtils.SetActive(self.uiObjs.Group_Caption, true)
  GUIUtils.SetActive(self.uiObjs.Img_NoticeTxt:FindDirect("Img_Up"), false)
  GUIUtils.SetActive(self.uiObjs.Img_NoticeTxt:FindDirect("Img_Down"), false)
  self.uiObjs.Img_NoticeTxt:FindDirect("Scroll View_Server"):GetComponent("UIScrollView"):ResetPosition()
  local htmlObj = self.uiObjs.Img_NoticeTxt:FindDirect("Scroll View_Server/html")
  local Texture_TopBanner = self.uiObjs.Img_NoticeTxt:FindDirect("Scroll View_Server/Texture_TopBanner")
  Texture_TopBanner:GetComponent("UITexture").mainTexture = nil
  local html = htmlObj:GetComponent("NGUIHTML")
  local TOP_Y = Texture_TopBanner.localPosition.y
  local pictureUrl = self:GetPictureURL(notice)
  if #pictureUrl > 0 then
    GUIUtils.SetActive(Texture_TopBanner, true)
    htmlObj.localPosition = Vector.Vector3.new(-258, TOP_Y, 0)
    GUIUtils.FillTextureFromURL(Texture_TopBanner, pictureUrl, function(tex2d)
      if tex2d == nil or Texture_TopBanner.isnil then
        return
      end
      local tex2dWidth, text2dHeight = tex2d.width, tex2d.height
      local tex2dRatio = tex2dWidth / text2dHeight
      local width, height = 0, 0
      local uiTexture = Texture_TopBanner:GetComponent("UITexture")
      local FIX_WIDTH = uiTexture.width
      width = FIX_WIDTH
      height = width / tex2dRatio
      uiTexture.mainTexture = tex2d
      uiTexture.width = width
      uiTexture.height = height
      local padding = 10
      local y = TOP_Y - height - padding
      htmlObj.localPosition = Vector.Vector3.new(-258, y, 0)
      self:UpdateGoToBtn()
    end, true)
    self.hasSetBanner = true
  else
    htmlObj.localPosition = Vector.Vector3.new(-258, TOP_Y, 0)
    GUIUtils.SetActive(Texture_TopBanner, false)
  end
  self:LoadAndSetHtmlContent(html, notice)
end
def.method("userdata", "table").LoadAndSetHtmlContent = function(self, html, notice)
  if #notice.content > 0 then
    self:SetHtmlContent(html, notice.content)
    self:UpdateGoToBtn()
    return
  end
  UpdateNoticeModule.Instance():QueryNoticeContent(notice.id, function()
    if html.isnil then
      return
    end
    self:SetHtmlContent(html, notice.content)
    self:UpdateGoToBtn()
  end)
end
def.method("table", "=>", "string").GetPictureURL = function(self, notice)
  if #notice.pictureUrl > 0 then
    return notice.pictureUrl
  elseif self.innerbannerNotice then
    return self.innerbannerNotice.pictureUrl
  else
    return ""
  end
end
def.method("string").SetTitle = function(self, title)
  GUIUtils.SetText(self.uiObjs.Label_Caption, title)
end
def.method("userdata", "string").SetHtmlContent = function(self, html, content)
  local content = UpdateNoticeModule.HtmlToNGUIHtml(content)
  local content = string.format("<font color=#4f3018>%s</font>", content)
  local content = string.format("<p><font size=4>&nbsp;</font></p><p>%s</p>", content)
  html:ForceHtmlText(content)
  local linkTexts = html.gameObject:GetComponentsInChildren("NGUILinkText")
  local htmlWidget = html.gameObject:GetComponent("UIWidget")
  for i, v in ipairs(linkTexts) do
    if getmetatable(v) == nil then
      break
    end
    local label = v.gameObject:GetComponent("UILabel")
    label:set_supportEncoding(true)
    label:set_text(string.format("[u]%s[/u]", label:get_text()))
    label.depth = htmlWidget.depth + 1
  end
  GUIUtils.FixBoldFontStyle(html.gameObject)
end
def.method().UpdateGoToBtn = function(self)
  local Btn_Check = self.uiObjs.Img_NoticeTxt:FindDirect("Scroll View_Server/Btn_Check")
  local Btn_CheckLink = self.uiObjs.Img_NoticeLink:FindDirect("Btn_Check")
  local htmlObj = self.uiObjs.Img_NoticeTxt:FindDirect("Scroll View_Server/html")
  local notice = self.selectedNotice
  if notice:HasExternalLink() then
    local hrefText = notice.hrefText ~= "" and notice.hrefText or textRes.UpdateNotice[2]
    GUIUtils.SetActive(Btn_Check, true)
    local padding = 30
    local y = htmlObj.localPosition.y - htmlObj:GetComponent("UIWidget").height - padding
    if Btn_Check then
      Btn_Check.localPosition = Vector.Vector3.new(5, y, 0)
      local Label_Check = Btn_Check:FindDirect("Label_Check")
      GUIUtils.SetText(Label_Check, hrefText)
    end
    GUIUtils.SetActive(Btn_CheckLink, true)
    local Label_Check = GUIUtils.FindDirect(Btn_CheckLink, "Label_Check")
    GUIUtils.SetText(Label_Check, hrefText)
  else
    GUIUtils.SetActive(Btn_Check, false)
  end
end
return GameNoticePanel.Commit()
