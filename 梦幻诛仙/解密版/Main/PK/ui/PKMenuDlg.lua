local Lplus = require("Lplus")
local ECPanelBase = require("GUI.ECPanelBase")
local PKMenuDlg = Lplus.Extend(ECPanelBase, "PKMenuDlg")
local MENPAI = require("consts.mzm.gsp.occupation.confbean.SOccupationEnum")
local def = PKMenuDlg.define
local dlg
local GUIUtils = require("GUI.GUIUtils")
local PKData = require("Main.PK.data.PKData")
def.field("number").selectedMenpai = 0
def.field("table").listItems = nil
def.field("number").refreshCd = -1
def.field("number")._timerID = 0
def.static("=>", PKMenuDlg).Instance = function()
  if dlg == nil then
    dlg = PKMenuDlg()
  end
  return dlg
end
def.override().OnCreate = function(self)
  Event.RegisterEvent(ModuleId.PK, gmodule.notifyId.PK.Show_PK_Menu, PKMenuDlg.OnShow)
  Event.RegisterEvent(ModuleId.PK, gmodule.notifyId.PK.Hide_Pk_Menu, PKMenuDlg.OnHide)
  Event.RegisterEvent(ModuleId.FIGHT, gmodule.notifyId.Fight.ENTER_FIGHT, PKMenuDlg.OnEnterFight)
end
def.method().ShowDlg = function(self)
  if self.m_panel then
    self:DestroyPanel()
  end
  self:CreatePanel(RESPATH.DLG_LEITAI, 0)
end
def.override().OnDestroy = function(self)
  Event.UnregisterEvent(ModuleId.LEITAI, gmodule.notifyId.PVP.UPDATE_LEITAI_INFO, PKMainDlg.UpdateInfo)
end
def.static().OnShow = function()
  dlg:ShowDlg()
end
def.static().OnHide = function()
  dlg:Hide()
end
def.static("table", "table").OnEnterFight = function(p1, p2)
  dlg:ShowDlg()
end
def.method("string").onClick = function(self, id)
  if id == "Btn_OnePerson" then
    Event.DispatchEvent(ModuleId.PK, gmodule.notifyId.PK.Show_PK_MainUI, {0})
  end
end
def.override("boolean").OnShow = function(self, s)
  if s == false then
    return
  end
  gmodule.network.sendProtocol(require("netio.protocol.mzm.gsp.leitai.CRefreshSingleListReq").new())
end
def.method().CheckMenpai = function(self)
end
def.method().ShowFightInfo = function(self)
end
def.method().ShowSoloInfo = function(self)
end
def.method().ShowTeamInfo = function(self)
end
def.method().Hide = function(self)
  if self._timerID > 0 then
    GameUtil.RemoveGlobalTimer(self._timerID)
    self._timerID = 0
  end
end
def.static("table", "table").UpdateInfo = function(p1, p2)
end
def.method()._FillTime = function(self)
  if self:IsShow() == true then
    do
      local Label_Time = self.m_panel:FindDirect("Img_Bg0/TopInfo/Label_Time")
      local nowSec = PKData.Instance().activityTime
      local nowHour = tonumber(os.date("%H", nowSec))
      local nowMinite = tonumber(os.date("%M", nowSec))
      local strTime = string.format("%02d:%02d", nowHour, nowMinite)
      Label_Time:GetComponent("UILabel"):set_text(strTime)
      if self._timerID > 0 then
        GameUtil.RemoveGlobalTimer(self._timerID)
        self._timerID = 0
      end
      local function OnTimer()
        PKData.Instance().activityTime = PKData.Instance().activityTime - 1
        if PKData.Instance().activityTime <= 0 then
          GameUtil.RemoveGlobalTimer(self._timerID)
          self._timerID = 0
        end
        local nowSec = PKData.Instance().activityTime
        local nowHour = tonumber(os.date("%H", nowSec))
        local nowMinite = tonumber(os.date("%M", nowSec))
        local strTime = string.format("%02d:%02d", nowHour, nowMinite)
        Label_Time:GetComponent("UILabel"):set_text(strTime)
      end
      self._timerID = GameUtil.AddGlobalTimer(1, false, OnTimer)
    end
  end
end
PKMainDlg.Commit()
return PKMainDlg
