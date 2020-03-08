local Lplus = require("Lplus")
local ECPanelBase = require("GUI.ECPanelBase")
local UpdateNoticePanel = Lplus.Extend(ECPanelBase, "UpdateNoticePanel")
local Vector = require("Types.Vector")
local GUIUtils = require("GUI.GUIUtils")
local ECMSDK = require("ProxySDK.ECMSDK")
local def = UpdateNoticePanel.define
def.field("string").title = ""
def.field("string").content = ""
def.field("string").url = ""
def.field("table").uiObjs = nil
def.field("function").onClose = nil
local instance
def.static("=>", UpdateNoticePanel).Instance = function()
  if instance == nil then
    instance = UpdateNoticePanel()
    instance:Init()
  end
  return instance
end
def.method().Init = function(self)
end
def.method("string", "string").ShowPanel = function(self, title, content)
  self:ShowPanelEx(title, content, "", nil)
end
def.method("string", "string", "string", "function").ShowPanelEx = function(self, title, content, url, onClose)
  if self:IsShow() then
    self:DestroyPanel()
  end
  self.title = title
  self.content = content
  self.onClose = onClose
  self.url = url
  self:CreatePanel(RESPATH.PREFAB_UPDATE_NOTICE_PANEL_RES, 1)
  self:SetDepth(_G.GUIDEPTH.TOPMOST)
  self:SetModal(true)
end
def.override().OnCreate = function(self)
  local Img_Bg0 = self.m_panel:FindDirect("Img_Bg0")
  self.uiObjs = {}
  self.uiObjs.Label_Title = Img_Bg0:FindDirect("Label_Title")
  self.uiObjs.Label_Content = Img_Bg0:FindDirect("Bg_Content/Scroll View/Label")
  self.uiObjs.Btn_Submit = Img_Bg0:FindDirect("Btn_Submit")
  self.uiObjs.Btn_Submit1 = Img_Bg0:FindDirect("Btn_Submit1")
  self.uiObjs.Btn_Go = Img_Bg0:FindDirect("Btn_Go")
  if #self.url < 3 then
    GUIUtils.SetActive(self.uiObjs.Btn_Submit, true)
    GUIUtils.SetActive(self.uiObjs.Btn_Go, false)
    GUIUtils.SetActive(self.uiObjs.Btn_Submit1, false)
  elseif self.uiObjs.Btn_Go and self.uiObjs.Btn_Submit1 then
    GUIUtils.SetActive(self.uiObjs.Btn_Submit, false)
    GUIUtils.SetActive(self.uiObjs.Btn_Go, true)
    GUIUtils.SetActive(self.uiObjs.Btn_Submit1, true)
  end
end
def.override("boolean").OnShow = function(self, isShow)
  if isShow then
    self:UpdateUI()
  end
end
def.override().OnDestroy = function(self)
  self.uiObjs = nil
  self.title = ""
  self.content = ""
  self.url = ""
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
    ECMSDK.ReportEvent("Notice", "8", true)
  elseif id == "Modal" then
    self:DestroyPanel()
  elseif id == "Btn_Submit" or id == "Btn_Submit1" then
    self:DestroyPanel()
    ECMSDK.ReportEvent("Notice", "8", true)
  elseif id == "Btn_Go" then
    self:OnBtnGoClicked()
  end
end
def.method().OnBtnGoClicked = function(self)
  self:OpenUrl(self.url)
end
def.method("string").OpenUrl = function(self, url)
  require("Main.ECGame").Instance():OpenUrl(url)
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
  self:UpdateTitle()
  self:UpdateContent()
end
def.method().UpdateTitle = function(self)
  self:_SetTitle(self.title)
end
def.method("string")._SetTitle = function(self, title)
  self.uiObjs.Label_Title:GetComponent("UILabel").text = title
end
def.method().UpdateContent = function(self)
  self:_SetContent(self.content)
end
def.method("string")._SetContent = function(self, content)
  local html = self.uiObjs.Label_Content:GetComponent("NGUIHTML")
  local content = string.format("<font color=#4f3018>%s</font>", content)
  html:ForceHtmlText(content)
  local linkTexts = self.uiObjs.Label_Content:GetComponentsInChildren("NGUILinkText")
  for i, v in ipairs(linkTexts) do
    if getmetatable(v) == nil then
      break
    end
    local label = v.gameObject:GetComponent("UILabel")
    label:set_supportEncoding(true)
    label:set_text(string.format("[u]%s[/u]", label:get_text()))
  end
  GUIUtils.FixBoldFontStyle(html.gameObject)
end
return UpdateNoticePanel.Commit()
