local Lplus = require("Lplus")
local ECPanelBase = require("GUI.ECPanelBase")
local DlgChessMain = Lplus.Extend(ECPanelBase, "DlgChessMain")
local def = DlgChessMain.define
local dlg
local GUIUtils = require("GUI.GUIUtils")
local EC = require("Types.Vector3")
local Vector = require("Types.Vector")
local SSynChessInfo = require("netio.protocol.mzm.gsp.chess.SSynChessInfo")
def.field("number").time = 0
def.field("table").uiObjs = nil
def.field("function").onShowCall = nil
def.static("=>", DlgChessMain).Instance = function()
  if dlg == nil then
    dlg = DlgChessMain()
  end
  return dlg
end
def.override().OnCreate = function(self)
end
def.method("number").ShowDlg = function(self, timeleft)
  self.time = timeleft
  if self.m_panel then
    self:OnShow(true)
  else
    self:CreatePanel(RESPATH.PREFAB_CHESS_MAIN, 1)
    self:SetDepth(GUIDEPTH.BOTTOMMOST)
  end
end
def.override().OnDestroy = function(self)
  self.uiObjs = nil
  self.onShowCall = nil
end
def.method("string").onClick = function(self, id)
  if id == "Button_Surrender" then
    require("Main.Chess.ChessMgr").Instance():Surrender()
  elseif id == "Btn_Talk" then
    Event.DispatchEvent(ModuleId.MAINUI, gmodule.notifyId.MainUI.BTN_CHAT_CLICK, nil)
  end
end
def.override("boolean").OnShow = function(self, s)
  if s == false then
    return
  end
  self.uiObjs = {}
  self.uiObjs.countPanel = self.m_panel:FindDirect("Panel_Info")
  self.uiObjs.countLabel = self.uiObjs.countPanel:FindDirect("Label_CountDown")
  self.uiObjs.countPanel:SetActive(false)
  self.uiObjs.roundLabel = self.m_panel:FindDirect("Pnl_Round/RoundGroup/Label_RoundNumber")
  local chessMgr = require("Main.Chess.ChessMgr").Instance()
  local SSynChessInfo = require("netio.protocol.mzm.gsp.chess.SSynChessInfo")
  self.uiObjs.roundLabel:GetComponent("UILabel").text = tostring(chessMgr.curRound)
  self.uiObjs.headPanels = {}
  local redPanel = self.m_panel:FindDirect("Pnl_RolePetLeft/RolePetLeftGroup/Img_Red")
  self.uiObjs.headPanels[SSynChessInfo.SIDE_RED] = redPanel
  local bluePanel = self.m_panel:FindDirect("Pnl_RolePetRight/RolePetGroupRight/Img_Blue")
  self.uiObjs.headPanels[SSynChessInfo.SIDE_BLUE] = bluePanel
  self.uiObjs.redWaitPanel = redPanel:FindDirect("Img_Grren")
  self.uiObjs.redWaitLabel = self.uiObjs.redWaitPanel:FindDirect("Label_SecCount")
  self.uiObjs.blueWaitPanel = bluePanel:FindDirect("Img_Grren")
  self.uiObjs.blueWaitLabel = self.uiObjs.blueWaitPanel:FindDirect("Label_SecCount")
  self.uiObjs.guidePanel = self.m_panel:FindDirect("Group_Anno")
  self.uiObjs.guideTip = self.uiObjs.guidePanel:FindDirect("Label_Tips")
  if self.time > 0 then
    self:StartCountDown()
  else
    self:ShowWaitPanel(false)
  end
  local myprop = require("Main.Hero.Interface").GetHeroProp()
  local myPanel = self.uiObjs.headPanels[chessMgr.my_side]
  myPanel:FindDirect("Label_PlayerName"):GetComponent("UILabel").text = myprop.name
  myPanel:FindDirect("Img_Menpai"):GetComponent("UISprite").spriteName = GUIUtils.GetOccupationSmallIcon(myprop.occupation)
  local genderIcon = myPanel:FindDirect("Img_Gender")
  GUIUtils.SetSprite(genderIcon, GUIUtils.GetSexIcon(myprop.gender))
  local headIcon = myPanel:FindDirect("Icon_Player")
  SetAvatarIcon(headIcon, nil)
  local rivalPanel
  if chessMgr.my_side == SSynChessInfo.SIDE_RED then
    rivalPanel = self.uiObjs.headPanels[SSynChessInfo.SIDE_BLUE]
  else
    rivalPanel = self.uiObjs.headPanels[SSynChessInfo.SIDE_RED]
  end
  rivalPanel:FindDirect("Label_PlayerName"):GetComponent("UILabel").text = chessMgr.rivalInfo.name
  rivalPanel:FindDirect("Img_Menpai"):GetComponent("UISprite").spriteName = GUIUtils.GetOccupationSmallIcon(chessMgr.rivalInfo.occupation)
  local genderIcon = rivalPanel:FindDirect("Img_Gender")
  GUIUtils.SetSprite(genderIcon, GUIUtils.GetSexIcon(chessMgr.rivalInfo.gender))
  local headIcon = rivalPanel:FindDirect("Icon_Player")
  if 0 < chessMgr.rivalInfo.avatar then
    SetAvatarIcon(headIcon, chessMgr.rivalInfo.avatar)
  else
    headIcon:GetComponent("UISprite"):set_spriteName(GUIUtils.GetHeadSpriteName(chessMgr.rivalInfo.occupation, chessMgr.rivalInfo.gender))
  end
  if self.onShowCall then
    _G.SafeCallback(self.onShowCall)
    self.onShowCall = nil
  end
end
def.method().SetLabel = function(self)
  if self.m_panel == nil then
    return
  end
  self:ShowWaitPanel(true)
  if self.uiObjs and self.time > 0 then
    local chessMgr = require("Main.Chess.ChessMgr").Instance()
    local waitLabel
    if chessMgr.currentPlayer == SSynChessInfo.SIDE_RED then
      waitLabel = self.uiObjs.redWaitLabel
    elseif chessMgr.currentPlayer == SSynChessInfo.SIDE_BLUE then
      waitLabel = self.uiObjs.blueWaitLabel
    end
    if waitLabel then
      waitLabel:GetComponent("UILabel").text = string.format("(%ds)", self.time)
    end
    self:Update3Count()
  end
end
def.method().Hide = function(self)
  self:StopCountDown()
  self:DestroyPanel()
end
def.method().NextRound = function(self)
  if self.uiObjs then
    self.uiObjs.roundLabel:GetComponent("UILabel").text = tostring(require("Main.Chess.ChessMgr").Instance().curRound)
  end
  local chessMgr = require("Main.Chess.ChessMgr").Instance()
  self.time = chessMgr.gameCfg.roundTimeLimit
  self:StartCountDown()
end
def.method().StartCountDown = function(self)
  Timer:RegisterListener(DlgChessMain.Update, self)
  self:SetLabel()
end
def.method().StopCountDown = function(self)
  Timer:RemoveListener(DlgChessMain.Update)
  self:Stop3Count()
  self.time = 0
  self:ShowWaitPanel(false)
end
def.method("boolean").ShowWaitPanel = function(self, v)
  if self.uiObjs then
    local chessMgr = require("Main.Chess.ChessMgr").Instance()
    self.uiObjs.redWaitPanel:SetActive(v and chessMgr.currentPlayer == SSynChessInfo.SIDE_RED)
    self.uiObjs.blueWaitPanel:SetActive(v and chessMgr.currentPlayer == SSynChessInfo.SIDE_BLUE)
  end
end
def.method("number").Update = function(self, tick)
  self.time = self.time - 1
  if self.time < 0 then
    self.time = 0
  end
  self:SetLabel()
  if self.time == 3 and require("Main.Chess.ChessMgr").Instance():IsMyTurn() then
    self:Start3Count()
  end
end
def.method().Start3Count = function(self)
  if self.uiObjs then
    self.uiObjs.countPanel:SetActive(true)
    self.uiObjs.countLabel:GetComponent("UILabel").text = tostring(self.time)
  end
end
def.method().Update3Count = function(self)
  if self.uiObjs and self.time <= 3 then
    self.uiObjs.countLabel:GetComponent("UILabel").text = tostring(self.time)
  end
end
def.method().Stop3Count = function(self)
  if self.uiObjs then
    self.uiObjs.countPanel:SetActive(false)
  end
end
def.method("string").ShowGuidTip = function(self, tipstr)
  if self.uiObjs then
    self.uiObjs.guidePanel:SetActive(true)
    self.uiObjs.guideTip:GetComponent("UILabel").text = tipstr
  else
    function self.onShowCall()
      self:ShowGuidTip(tipstr)
    end
  end
end
def.method().StopGuidTip = function(self)
  if self.uiObjs then
    self.uiObjs.guidePanel:SetActive(false)
  end
end
DlgChessMain.Commit()
return DlgChessMain
