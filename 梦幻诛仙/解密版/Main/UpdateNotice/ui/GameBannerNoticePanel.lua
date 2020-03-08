local Lplus = require("Lplus")
local ECPanelBase = require("GUI.ECPanelBase")
local GameBannerNoticePanel = Lplus.Extend(ECPanelBase, "GameBannerNoticePanel")
local GUIUtils = require("GUI.GUIUtils")
local NoticeData = require("Main.UpdateNotice.NoticeData")
local def = GameBannerNoticePanel.define
local instance
local function Instance()
  if instance == nil then
    instance = GameBannerNoticePanel()
  end
  return instance
end
def.static("table", "function", "=>", GameBannerNoticePanel).ShowPanel = function(notice, onClose)
  local self = Instance()
  if self.m_panel and not self.m_panel.isnil then
    self:DestroyPanel()
  end
  self.notice = notice
  self.onClose = onClose
  self:SetDepth(_G.GUIDEPTH.TOP)
  self:CreatePanel(RESPATH.PREFAB_GAME_BANNER_NOTICE_PANEL_RES, 1)
  self:SetModal(true)
  return self
end
def.field("table").notice = nil
def.field("function").onClose = nil
def.field("table").uiObjs = nil
def.method("string").onClick = function(self, id)
  if id == "Btn_Close" or id == "Btn_Conform" or id == "Modal" then
    self:DestroyPanel()
  elseif id == "Texture" then
    self:OnTextureClick()
  end
end
def.override().OnCreate = function(self)
  self.uiObjs = {}
  self.uiObjs.Img_Bg0 = self.m_panel:FindDirect("Img_Bg0")
  self.uiObjs.Texture = self.uiObjs.Img_Bg0:FindDirect("Panel_Clip/Texture")
  GUIUtils.AddBoxCollider(self.uiObjs.Texture)
  self.m_msgHandler:Touch(self.uiObjs.Texture)
  self:UpdateTexture()
end
def.method().UpdateTexture = function(self)
  local picPath = self.notice.pictureUrl
  local Texture = self.uiObjs.Texture
  _G.DownLoadDataFromURL(picPath, nil)
  GUIUtils.FillTextureFromURL(Texture, picPath, function(tex2d)
    if tex2d == nil or Texture.isnil then
      return
    end
    local tex2dWidth, text2dHeight = tex2d.width, tex2d.height
    local tex2dRatio = tex2dWidth / text2dHeight
    local width, height = 0, 0
    local uiTexture = Texture:GetComponent("UITexture")
    local FIX_WIDTH = uiTexture.width
    width = FIX_WIDTH
    height = width / tex2dRatio
    uiTexture.mainTexture = tex2d
    uiTexture.width = width
    uiTexture.height = height
  end, true)
end
def.override().OnDestroy = function(self)
  if self.onClose then
    self.onClose()
  end
  instance = nil
end
def.method().OnTextureClick = function(self)
  if not self.notice:HasExternalLink() then
    return
  end
  local UpdateNoticeModule = require("Main.UpdateNotice.UpdateNoticeModule")
  UpdateNoticeModule.Instance():OperateNoticeUrl(self.notice)
  local noticeId = self.notice.id
  local ECMSDK = require("ProxySDK.ECMSDK")
  ECMSDK.SendTLogToServer(_G.TLOGTYPE.CLICKTHROWONFACE, {noticeId})
end
return GameBannerNoticePanel.Commit()
