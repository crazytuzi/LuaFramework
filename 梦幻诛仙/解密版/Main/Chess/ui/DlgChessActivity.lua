local Lplus = require("Lplus")
local ECPanelBase = require("GUI.ECPanelBase")
local DlgChessActivity = Lplus.Extend(ECPanelBase, "DlgChessActivity")
local def = DlgChessActivity.define
local dlg
local GUIUtils = require("GUI.GUIUtils")
local EC = require("Types.Vector3")
local Vector = require("Types.Vector")
def.field("number").time = 0
def.field("table").uiObjs = nil
def.static("=>", DlgChessActivity).Instance = function()
  if dlg == nil then
    dlg = DlgChessActivity()
  end
  return dlg
end
def.override().OnCreate = function(self)
end
def.method().ShowDlg = function(self)
  if self.m_panel then
    self:OnShow(true)
  else
    self:CreatePanel(RESPATH.PREFAB_CHESS_ACTIVITY, 1)
  end
end
def.override().OnDestroy = function(self)
  self.uiObjs = nil
end
def.method("string").onClick = function(self, id)
  if id == "Btn_Start" then
    gmodule.network.sendProtocol(require("netio.protocol.mzm.gsp.chess.CJoinChessReq").new(constant.ChessActivityConsts.ACTIVITY_ID))
    self:Hide()
  elseif id == "Bth_Close" then
    self:Hide()
  end
end
def.override("boolean").OnShow = function(self, s)
  if s == false then
    return
  end
  local tipContent = require("Main.Common.TipsHelper").GetHoverTip(constant.ChessActivityConsts.TIPS_ID)
  self.m_panel:FindDirect("Img_Bg0/Group_Right/Img_Bg_R/Scroll View/Label"):GetComponent("UILabel").text = tipContent
end
def.method().Hide = function(self)
  self:DestroyPanel()
end
DlgChessActivity.Commit()
return DlgChessActivity
