local Lplus = require("Lplus")
local ECPanelBase = require("GUI.ECPanelBase")
local SoloMissionTip = Lplus.Extend(ECPanelBase, "SoloMissionTip")
local DungeonUtils = require("Main.Dungeon.DungeonUtils")
local GUIUtils = require("GUI.GUIUtils")
local MathHelper = require("Common.MathHelper")
local def = SoloMissionTip.define
local _instance
def.field("number").dungeonId = 0
def.field("number").processId = 0
def.field("boolean").needGuide = false
def.field("table").guide = nil
def.static("=>", SoloMissionTip).Instance = function()
  if _instance == nil then
    _instance = SoloMissionTip()
  end
  return _instance
end
def.static("number", "number", "boolean").SetMissionTip = function(dungeonId, processId, needGuide)
  local dlg = SoloMissionTip.Instance()
  dlg.dungeonId = dungeonId
  dlg.processId = processId
  dlg.needGuide = needGuide
  if not dlg.m_panel then
    dlg:CreatePanel(RESPATH.PREFAB_SOLO_MISSION_TIP, 0)
  else
    dlg:SetContent()
  end
end
def.static().CloseMissionTip = function()
  SoloMissionTip.Instance():DestroyPanel()
end
def.static().ShowMissionTip = function()
  local dlg = SoloMissionTip.Instance()
  if not dlg.m_panel then
    dlg:CreatePanel(RESPATH.PREFAB_SOLO_MISSION_TIP, 0)
  else
    dlg:SetContent()
  end
end
def.override().OnCreate = function(self)
  self:SetContent()
end
def.method().SetContent = function(self)
  local dungeonInfo = DungeonUtils.GetDungeonCfg(self.dungeonId)
  local nameLabel = self.m_panel:FindDirect("Img_Bg/Label_FuBenName"):GetComponent("UILabel")
  nameLabel:set_text(dungeonInfo.name)
  local mission = self.m_panel:FindDirect("Img_Bg/Label_GuanKaName")
  local missionLabel = mission:GetComponent("UILabel")
  if self.processId > 0 then
    local missionInfo = DungeonUtils.GetOneSoloDungeonCfg(self.dungeonId, self.processId)
    missionLabel:set_text(string.format(textRes.Dungeon[2], MathHelper.Arabic2Chinese(self.processId), missionInfo.name))
  else
    missionLabel:set_text(textRes.Dungeon[35])
  end
  if self.needGuide then
    GameUtil.AddGlobalTimer(0.1, true, function()
      if self.m_panel and not self.m_panel.isnil then
        local CommonGuideTip = require("GUI.CommonGuideTip")
        if self.guide then
          self.guide:HideDlg()
        end
        self.guide = CommonGuideTip.ShowGuideTip(textRes.Dungeon[38], mission, CommonGuideTip.StyleEnum.LEFT)
      end
    end)
  end
end
def.override().OnDestroy = function(self)
  if self.guide then
    self.guide:HideDlg()
    self.guide = nil
  end
end
def.method("string").onClick = function(self, id)
  if id == "Btn_Map" then
    local SoloDungeonDlg = require("Main.Dungeon.ui.SoloDungeonDlg")
    SoloDungeonDlg.ShowSoloDungeon(self.dungeonId)
  elseif id == "Btn_Leave" then
    local DungeonModule = require("Main.Dungeon.DungeonModule")
    DungeonModule.Instance():LeaveDungeon()
  elseif id == "Label_GuanKaName" then
    if self.guide then
      self.guide:HideDlg()
      self.guide = nil
    end
    if self.processId > 0 then
      local DungeonModule = require("Main.Dungeon.DungeonModule")
      DungeonModule.Instance().soloMgr:FindMonster(true)
    end
  end
end
SoloMissionTip.Commit()
return SoloMissionTip
