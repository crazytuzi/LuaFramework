local Lplus = require("Lplus")
local ECPanelBase = require("GUI.ECPanelBase")
local ECMSDK = require("ProxySDK.ECMSDK")
local CommonConfirmDlg = require("GUI.CommonConfirmDlg")
local ActivityInterface = require("Main.activity.ActivityInterface")
local GUIUtils = require("GUI.GUIUtils")
local ShareWeddingPanel = Lplus.Extend(ECPanelBase, "ShareWeddingPanel")
local def = ShareWeddingPanel.define
def.field("function").m_AfterShareWedding = nil
def.field("table").m_ShowParams = nil
def.field("table").m_UIGO = nil
local instance
def.static("=>", ShareWeddingPanel).Instance = function()
  if not instance then
    instance = ShareWeddingPanel()
    instance.m_depthLayer = GUIDEPTH.TOPMOST
  end
  return instance
end
def.method("function").ShowPanel = function(self, cb)
  if self:IsShow() then
    self:DestroyPanel()
  end
  self.m_AfterShareWedding = cb
  self:CreatePanel(RESPATH.PREFAB_SHARE_BIG_TU2_PANEL, GUILEVEL.NORMAL)
  self:SetModal(true)
end
def.override().OnCreate = function(self)
  self:InitUI()
  self.m_bCanMoveBackward = true
end
def.override().OnDestroy = function(self)
  if self.m_AfterShareWedding then
    self.m_AfterShareWedding()
  end
  self.m_ShowParams = nil
end
def.method("string").onClick = function(self, id)
end
def.method("table").SetData = function(self, params)
  self.m_ShowParams = params
end
def.method().InitUI = function(self)
  local labelGO = self.m_panel:FindDirect("Texture_Di/Img_Di/Label")
  local name1 = self.m_ShowParams and self.m_ShowParams.name1 or ""
  local name2 = self.m_ShowParams and self.m_ShowParams.name2 or ""
  local cfg = require("Main.Login.ServerListMgr").Instance():GetSelectedServerCfg()
  local serverName = cfg.name
  local index = self.m_ShowParams and self.m_ShowParams.index or 1
  GUIUtils.SetText(labelGO, textRes.WeddingTour[21]:format(name1, name2, serverName, index))
end
return ShareWeddingPanel.Commit()
