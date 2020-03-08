local Lplus = require("Lplus")
local ECPanelBase = require("GUI.ECPanelBase")
local WarmUpPanel = Lplus.Extend(ECPanelBase, "WarmUpPanel")
local def = WarmUpPanel.define
def.field("number").m_activityId = 0
def.field("number").m_turn = 0
def.field("number").m_timer = 0
def.static("number", "number").ShowWarmUp = function(activityId, turn)
  local dlg = WarmUpPanel()
  dlg.m_activityId = activityId
  dlg.m_turn = turn
  dlg:CreatePanel(RESPATH.PREFAB_ALLLOTTO_WARMUP, 0)
end
def.override().OnCreate = function(self)
  self.m_timer = GameUtil.AddGlobalTimer(constant.CAllLottoConsts.WARM_UP_AWARD_VAILD_DURATION_IN_SECOND / 4, true, function()
    require("Main.AllLotto.AllLottoModule").Instance():GetWarmUp(self.m_activityId, self.m_turn)
    self:DestroyPanel()
  end)
end
def.override("boolean").OnShow = function(self, show)
end
def.override().OnDestroy = function(self)
  GameUtil.RemoveGlobalTimer(self.m_timer)
end
def.method("string").onClick = function(self, id)
  if id == "Texture_Npc" then
    require("Main.AllLotto.AllLottoModule").Instance():GetWarmUp(self.m_activityId, self.m_turn)
    self:DestroyPanel()
  end
end
WarmUpPanel.Commit()
return WarmUpPanel
