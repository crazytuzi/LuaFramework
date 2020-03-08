local Lplus = require("Lplus")
local ECPanelBase = require("GUI.ECPanelBase")
local NpcSendMoney = Lplus.Extend(ECPanelBase, "NpcSendMoney")
local GUIUtils = require("GUI.GUIUtils")
local def = NpcSendMoney.define
local _instance
def.static("=>", "table").Instance = function()
  if _instance == nil then
    _instance = NpcSendMoney()
  end
  return _instance
end
def.field("number").iconId = 0
def.field("function").callback = nil
def.field("number").autoCloseTime = 0
def.field("number").timer = 0
def.field("string").desc = ""
def.static("number", "number", "string", "function").ShowNpcSendMoney = function(iconId, lastTime, desc, callback)
  local dlg = NpcSendMoney.Instance()
  if dlg:IsShow() then
    dlg:DestroyPanel()
  end
  dlg.iconId = iconId
  dlg.callback = callback
  dlg.autoCloseTime = lastTime
  dlg.desc = desc
  dlg:CreatePanel(RESPATH.PREFAB_NPCREDBAG, 2)
  dlg:SetModal(true)
end
def.override().OnCreate = function(self)
  local npc = self.m_panel:FindDirect("Texture_Npc")
  local tex = npc:GetComponent("UITexture")
  GUIUtils.FillIcon(tex, self.iconId)
  if self.autoCloseTime > 0 then
    self.timer = GameUtil.AddGlobalTimer(self.autoCloseTime, true, function()
      self:DestroyPanel()
    end)
  end
  local lbl = self.m_panel:FindDirect("Label")
  lbl:GetComponent("UILabel"):set_text(self.desc)
end
def.method().DoCallback = function(self)
  if self.callback then
    self.callback()
    self.callback = nil
  end
end
def.override().OnDestroy = function(self)
  self:DoCallback()
  GameUtil.RemoveGlobalTimer(self.timer)
  self.timer = 0
end
def.method("string").onClick = function(self, id)
  if id == "Texture_Npc" then
    self:DestroyPanel()
  end
end
NpcSendMoney.Commit()
return NpcSendMoney
