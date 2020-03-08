local Lplus = require("Lplus")
local ECPanelBase = require("GUI.ECPanelBase")
local GUIUtils = require("GUI.GUIUtils")
local ResultPanel = Lplus.Extend(ECPanelBase, "ResultPanel")
local GangCrossData = require("Main.GangCross.data.GangCrossData")
local GangCrossUtility = require("Main.GangCross.GangCrossUtility")
local def = ResultPanel.define
local instance
def.field("table").uiTbl = nil
def.field("number").actTime = 0
def.field("number").actIndex = 0
def.field("table").resultInfo = nil
def.static("=>", ResultPanel).Instance = function()
  if not instance then
    instance = ResultPanel()
  end
  return instance
end
def.method("table").ShowPanel = function(self, resultInfo)
  self.resultInfo = resultInfo
  if self:IsShow() then
    self:UpdateUI()
    return
  end
  local resPath = RESPATH.PREFAB_CROSS_RESULT
  local prefab = GameUtil.SyncLoad(resPath)
  self.m_SyncLoad = true
  self:CreatePanel(resPath, -1)
end
def.override().OnCreate = function(self)
  self:InitUI()
end
def.override().OnDestroy = function(self)
end
def.override("boolean").OnShow = function(self, isShow)
  if isShow then
    self:UpdateUI()
  end
end
def.method().InitUI = function(self)
  if not self.uiTbl then
    self.uiTbl = {}
  end
  local uiTbl = self.uiTbl
  local Img_Bg = self.m_panel:FindDirect("Img_Bg")
  local Img_Win = Img_Bg:FindDirect("Img_Win")
  local Img_Loss = Img_Bg:FindDirect("Img_Loss")
  uiTbl.Img_Win = Img_Win
  uiTbl.Img_Loss = Img_Loss
  local Group_Info = Img_Bg:FindDirect("Group_Info")
  local Group_Player = Group_Info:FindDirect("Group_Player")
  local PlayerGangName = Group_Player:FindDirect("Group_GangInfo/Label_GangName")
  local PlayerSvrName = Group_Player:FindDirect("Group_GangInfo/Label_GangServerName")
  local PlayerScore = Group_Player:FindDirect("Group_GangResult/Label_Score")
  local PlayerWinNum = Group_Player:FindDirect("Group_GangResult/Label_Win")
  local PlayerJoinNum = Group_Player:FindDirect("Group_GangResult/Label_JoinNum")
  local PlayerKeepNum = Group_Player:FindDirect("Group_GangResult/Label_RestNum")
  local Group_Enemy = Group_Info:FindDirect("Group_Enemy")
  local EnemyGangName = Group_Enemy:FindDirect("Group_GangInfo/Label_GangName")
  local EnemySvrName = Group_Enemy:FindDirect("Group_GangInfo/Label_GangServerName")
  local EnemyScore = Group_Enemy:FindDirect("Group_GangResult/Label_Score")
  local EnemyWinNum = Group_Enemy:FindDirect("Group_GangResult/Label_Win")
  local EnemyJoinNum = Group_Enemy:FindDirect("Group_GangResult/Label_JoinNum")
  local EnemyKeepNum = Group_Enemy:FindDirect("Group_GangResult/Label_RestNum")
  uiTbl.GroupPlayer = {
    LabelGangName = PlayerGangName,
    LabelSvrName = PlayerSvrName,
    LabelScore = PlayerScore,
    LabelWinNum = PlayerWinNum,
    LabelJoinNum = PlayerJoinNum,
    LabelKeepNum = PlayerKeepNum
  }
  uiTbl.GroupEnemy = {
    LabelGangName = EnemyGangName,
    LabelSvrName = EnemySvrName,
    LabelScore = EnemyScore,
    LabelWinNum = EnemyWinNum,
    LabelJoinNum = EnemyJoinNum,
    LabelKeepNum = EnemyKeepNum
  }
end
def.method().Reset = function(self)
end
def.method("table", "table").ShowGangInfo = function(self, uiTbl, infoTbl)
  local LabelGangName = uiTbl.LabelGangName
  local LabelSvrName = uiTbl.LabelSvrName
  local LabelScore = uiTbl.LabelScore
  local LabelWinNum = uiTbl.LabelWinNum
  local LabelJoinNum = uiTbl.LabelJoinNum
  local LabelKeepNum = uiTbl.LabelKeepNum
  LabelGangName:GetComponent("UILabel"):set_text(infoTbl.gangname)
  LabelSvrName:GetComponent("UILabel"):set_text(infoTbl.svrname)
  LabelScore:GetComponent("UILabel"):set_text(infoTbl.score)
  LabelWinNum:GetComponent("UILabel"):set_text(infoTbl.winnum)
  LabelJoinNum:GetComponent("UILabel"):set_text(infoTbl.joinnum)
  LabelKeepNum:GetComponent("UILabel"):set_text(infoTbl.keepnum)
end
def.method().UpdateUI = function(self)
  local uiTbl = self.uiTbl
  local resultInfo = self.resultInfo
  local gangId = GangCrossData.Instance():GetGangId() or Int64.new(1)
  if resultInfo and gangId then
    local playerWin = Int64.eq(gangId, resultInfo.winInfo.gangid)
    if playerWin then
      self:ShowGangInfo(uiTbl.GroupPlayer, resultInfo.winInfo)
      self:ShowGangInfo(uiTbl.GroupEnemy, resultInfo.lossInfo)
    else
      self:ShowGangInfo(uiTbl.GroupPlayer, resultInfo.lossInfo)
      self:ShowGangInfo(uiTbl.GroupEnemy, resultInfo.winInfo)
    end
    uiTbl.Img_Win:SetActive(playerWin)
    uiTbl.Img_Loss:SetActive(not playerWin)
  end
end
def.method().HidePanel = function(self)
  if self.m_panel then
    self:DestroyPanel()
  end
end
def.method("userdata").onClickObj = function(self, clickobj)
end
return ResultPanel.Commit()
