local Lplus = require("Lplus")
local ECPanelBase = require("GUI.ECPanelBase")
local DeadBlind = Lplus.Extend(ECPanelBase, "DeadBlind")
local def = DeadBlind.define
local _instance
def.static("=>", "table").Instance = function()
  if _instance == nil then
    _instance = DeadBlind()
  end
  return _instance
end
def.field("number").endTime = 0
def.field("number").timer = 0
def.static("number").ShowDeadBlind = function(endTime)
  local dlg = DeadBlind.Instance()
  dlg.endTime = endTime
  if dlg:IsShow() then
    dlg:SetEndTime()
  else
    dlg:SetDepth(GUIDEPTH.BOTTOMMOST)
    dlg:CreatePanel(RESPATH.PREFAB_SINGLEBATTLE_REBORN, 0)
    dlg:SetModal(true)
  end
end
def.static().Close = function()
  local dlg = DeadBlind.Instance()
  dlg:DestroyPanel()
end
def.override().OnCreate = function(self)
  self:SetEndTime()
end
def.override().OnDestroy = function(self)
  GameUtil.RemoveGlobalTimer(self.timer)
end
def.method().SetEndTime = function(self)
  local timeLbl = self.m_panel:FindDirect("Label_Name/Label_Time"):GetComponent("UILabel")
  timeLbl:set_text(self.endTime - GetServerTime())
  self.timer = GameUtil.AddGlobalTimer(1, false, function()
    local left = self.endTime - GetServerTime()
    if not timeLbl.isnil then
      timeLbl:set_text(left)
    end
    if left <= 0 then
      self:DestroyPanel()
    end
  end)
end
DeadBlind.Commit()
return DeadBlind
