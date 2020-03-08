local Lplus = require("Lplus")
local ECPanelBase = require("GUI.ECPanelBase")
local DlgReplay = Lplus.Extend(ECPanelBase, "DlgReplay")
local def = DlgReplay.define
local dlg, fightMgr
local GUIUtils = require("GUI.GUIUtils")
local EC = require("Types.Vector3")
local Vector = require("Types.Vector")
local FightUtils = require("Main.Fight.FightUtils")
def.field("number").time = 0
def.field("function").onload = nil
def.field("boolean").showSubtitle = false
def.field("table").uiObjs = nil
def.static("=>", DlgReplay).Instance = function()
  if dlg == nil then
    dlg = DlgReplay()
    fightMgr = require("Main.Fight.Replayer").Instance()
  end
  return dlg
end
def.override().OnCreate = function(self)
end
def.method().ShowDlg = function(self)
  if self.m_panel then
    self:OnShow(true)
  else
    self:CreatePanel(RESPATH.DLG_FIGHT_REPLAY, 0)
    self:SetDepth(GUIDEPTH.BOTTOMMOST)
  end
end
def.override().OnDestroy = function(self)
  local effComtainer = self.m_panel:FindDirect("Effect")
  if effComtainer.childCount > 0 then
    local effInst = effComtainer:GetChild(0)
    if effInst then
      effInst:Destroy()
    end
  end
  self.uiObjs = nil
end
def.method("string").onClick = function(self, id)
  if id == "Btn_DanMu" then
    self.showSubtitle = not self.showSubtitle
    self:ShowSubtitle(self.showSubtitle)
  elseif id == "Btn_Quit" then
    if fightMgr:IsRealtime() then
      gmodule.network.sendProtocol(require("netio.protocol.mzm.gsp.fight.CQuitRealtimeRecordReq").new())
    end
    require("Main.Fight.Replayer").OnFightEnd(nil)
  elseif id == "Btn_NextTurn" then
    require("Main.Fight.Replayer").Instance():SkipToNextRound()
  elseif id == "Btn_Play" then
    require("Main.Fight.Replayer").Instance():Pause(false)
    self.uiObjs.btnPlay:SetActive(false)
    self.uiObjs.btnPause:SetActive(true)
  elseif id == "Btn_Pause" then
    require("Main.Fight.Replayer").Instance():Pause(true)
    self.uiObjs.btnPlay:SetActive(true)
    self.uiObjs.btnPause:SetActive(false)
  elseif id == "Btn_LastTrun" then
    require("Main.Fight.Replayer").Instance():SkipToPrevRound()
  elseif id == "Btn_Nice" then
  elseif id == "Btn_Collect" then
  elseif string.find(id, "Img_BgZf") then
    local index = tonumber(string.sub(id, string.len("Img_BgZf") + 1))
    local DlgFormationTip = require("Main.Formation.ui.DlgFormationTip")
    local tip = DlgFormationTip()
    local function ShowFormationNumber(param)
      if not fightMgr.isInFight then
        return
      end
      local team = param[1]
      local isshow = param[2]
      for idx = 6, 10 do
        local unit = team:GetFightUnitByPos(idx)
        if unit and unit.model then
          if isshow then
            local power = 8 - idx
            local flag = 0
            if power < 0 then
              power = math.abs(power)
              flag = 1
            end
            local formationPos = math.pow(2, power) + flag
            unit.model:SetFormationNumber(formationPos)
          else
            unit.model:RemoveFormationNumber()
          end
        end
      end
    end
    if index == 1 and fightMgr.teams[2].formationInfo then
      ShowFormationNumber({
        fightMgr.teams[2],
        true
      })
      tip:ShowFormationTip(fightMgr.teams[2].formationInfo, fightMgr.teams[1].formationInfo, -1, ShowFormationNumber, {
        fightMgr.teams[2],
        false
      })
    elseif index == 2 and fightMgr.teams[1].formationInfo then
      ShowFormationNumber({
        fightMgr.teams[1],
        true
      })
      tip:ShowFormationTip(fightMgr.teams[1].formationInfo, fightMgr.teams[2].formationInfo, 1, ShowFormationNumber, {
        fightMgr.teams[1],
        false
      })
    end
  end
end
def.override("boolean").OnShow = function(self, s)
  if s == false then
    return
  end
  self.m_panel:FindDirect("Group_Watch/Group_VideoBtn"):SetActive(not fightMgr:IsRealtime())
  self.m_panel:FindDirect("Group_Watch/Group_VideoBtn/Btn_Nice"):SetActive(false)
  self.m_panel:FindDirect("Group_Watch/Group_VideoBtn/Btn_Collect"):SetActive(false)
  self.m_panel:FindDirect("Group_Num"):SetActive(false)
  self.uiObjs = {}
  self.uiObjs.waitLabel = self.m_panel:FindDirect("Group_Top/Img_BgWait/Label_Wait")
  self.uiObjs.waitLabel:SetActive(false)
  self.uiObjs.timeLabelPanel = self.m_panel:FindDirect("Group_Top/Img_BgTime")
  self.uiObjs.timeLabel = self.uiObjs.timeLabelPanel:FindDirect("Label_TimeNum")
  self.uiObjs.btnPlay = self.m_panel:FindDirect("Group_Watch/Group_VideoBtn/Btn_Play")
  self.uiObjs.btnPause = self.m_panel:FindDirect("Group_Watch/Group_VideoBtn/Btn_Pause")
  self.uiObjs.btnPlay:SetActive(fightMgr.paused)
  self.uiObjs.btnPause:SetActive(not fightMgr.paused)
  if self.time > 0 then
    self:SetLabel()
  else
    self:ShowCountDown(false)
  end
  local roundLabel = self.m_panel:FindDirect("Img_BgRound/Label_RoundNum")
  roundLabel:GetComponent("UILabel").text = tostring(fightMgr.curRound)
  if self.onload then
    self.onload(self)
    self.onload = nil
  end
  if 0 < fightMgr.countDown then
    self:NextRound()
  end
  self:ShowFormation()
end
def.method().ShowFormation = function(self)
  if self.m_panel == nil then
    self.onload = DlgReplay.ShowFormation
    return
  end
  local fomationIcon = self.m_panel:FindDirect("Img_BgRound/Img_BgZf" .. FightConst.PASSIVE_TEAM)
  local activeTeam = fightMgr.teams[FightConst.ACTIVE_TEAM]
  fomationIcon:SetActive(activeTeam.formation > 0)
  if activeTeam.formation > 0 then
    activeTeam.formationInfo = gmodule.moduleMgr:GetModule(ModuleId.FORMATION):GetFormationInfoAtLevel(activeTeam.formation, activeTeam.formationLevel)
    local formationIconCtrl = fomationIcon:FindDirect("Texture_Zf" .. FightConst.PASSIVE_TEAM)
    if activeTeam.formationInfo then
      local icon = formationIconCtrl:GetComponent("UITexture")
      GUIUtils.FillIcon(icon, activeTeam.formationInfo.icon)
    end
  end
  fomationIcon = self.m_panel:FindDirect("Img_BgRound/Img_BgZf" .. FightConst.ACTIVE_TEAM)
  local passiveTeam = fightMgr.teams[FightConst.PASSIVE_TEAM]
  fomationIcon:SetActive(passiveTeam.formation > 0)
  if passiveTeam.formation > 0 then
    passiveTeam.formationInfo = gmodule.moduleMgr:GetModule(ModuleId.FORMATION):GetFormationInfoAtLevel(passiveTeam.formation, passiveTeam.formationLevel)
    local formationIconCtrl = fomationIcon:FindDirect("Texture_Zf" .. FightConst.ACTIVE_TEAM)
    if passiveTeam.formationInfo then
      local icon = formationIconCtrl:GetComponent("UITexture")
      GUIUtils.FillIcon(icon, passiveTeam.formationInfo.icon)
    end
  end
end
def.method().SetLabel = function(self)
  if self.m_panel == nil then
    return
  end
  self:ShowCountDown(true)
  if self.uiObjs then
    if self.time > 0 then
      self.uiObjs.timeLabel:GetComponent("UILabel").text = tostring(self.time)
      self.uiObjs.timeLabelPanel:SetActive(true)
    else
      self.uiObjs.timeLabelPanel:SetActive(false)
    end
  end
end
def.method().NextRound = function(self)
  if self.m_panel == nil then
    return
  end
  self.m_panel:FindDirect("Img_BgRound"):SetActive(true)
  local roundLabel = self.m_panel:FindDirect("Img_BgRound/Label_RoundNum")
  roundLabel:GetComponent("UILabel").text = tostring(fightMgr.curRound)
  self.uiObjs.btnPlay:SetActive(fightMgr.paused)
  self.uiObjs.btnPause:SetActive(not fightMgr.paused)
  self:StartCountDown()
end
def.method().Hide = function(self)
  self.showSubtitle = false
  self:ShowSubtitle(false)
  self:DestroyPanel()
end
def.method().StartCountDown = function(self)
  self.time = constant.FightConst.WAIT_CMD_TIME
  Timer:RegisterListener(DlgReplay.Update, self)
  self:SetLabel()
end
def.method().StopCountDown = function(self)
  Timer:RemoveListener(DlgReplay.Update)
  self.time = 0
  self:SetLabel()
end
def.method("boolean").ShowCountDown = function(self, v)
  if self.m_panel == nil then
    return
  end
  local group = self.m_panel:FindDirect("Group_Top")
  if group then
    group:SetActive(v)
  end
end
def.method("number").Update = function(self, tick)
  if fightMgr.paused then
    return
  end
  self.time = self.time - 1
  if self.time < 0 then
    self.time = 0
  end
  self:SetLabel()
end
def.method("number").SetSpetatorsNum = function(self, num)
  local g = self.m_panel:FindDirect("Group_Num")
  if num <= 0 then
    g:SetActive(false)
    return
  end
  g:FindDirect("Label_Num"):GetComponent("UILabel").text = tostring(num)
  g:SetActive(true)
end
def.method("boolean").ShowSubtitle = function(self, visible)
end
DlgReplay.Commit()
return DlgReplay
