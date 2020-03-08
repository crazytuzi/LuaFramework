local Lplus = require("Lplus")
local ECPanelBase = require("GUI.ECPanelBase")
local ECFollowPanel = Lplus.Extend(ECPanelBase, "ECFollowPanel")
local Vector = require("Types.Vector")
local ECGame = require("Main.ECGame")
local HeroModule = require("Main.Hero.HeroModule")
local def = ECFollowPanel.define
def.field("number").m_offset = 0
def.static("number").Test = function(offset)
  local dlg = ECFollowPanel()
  dlg:CreatePanel(RESPATH.PREFAB_VOICE_PANEL, 0)
end
def.override().OnCreate = function(self)
  Timer:RegisterIrregularTimeListener(self.UpdatePos, self)
end
def.override().OnDestroy = function(self)
  Timer:RemoveIrregularTimeListener(self.UpdatePos)
end
def.method("number").SetOffset = function(self, offset)
  self.m_offset = offset
end
def.method("number").UpdatePos = function(self, dt)
  local UIRoot = GUIRoot.GetUIRootObj()
  local x, y, h = self:GetFollowPos()
  local localPos = Vector.Vector3.new(x, world_height - y, 0)
  local cam2dpos = ECGame.Instance():Get2dCameraPos()
  local diff = localPos - cam2dpos
  diff.y = diff.y + self.m_offset
  local scalse2d = ECGame.Instance():Get2dScale()
  diff.x = diff.x * scalse2d
  diff.y = diff.y * scalse2d + h / UIRoot.localScale.y / CommonCamera.game3DCamera.orthographicSize
  diff.z = 0
  if self.m_panel and not self.m_panel.isnil then
    self.m_panel.localPosition = diff
  end
end
def.virtual("=>", "number", "number", "number").GetFollowPos = function(self)
  local role = HeroModule.Instance().myRole
  if role then
    local pos = role:GetPos()
    return pos.x, pos.y, role:GetRoleHeight()
  else
    local pos = ECGame.Instance():Get2dCameraPos()
    return pos.x, world_height - pos.y, 0
  end
end
ECFollowPanel.Commit()
return ECFollowPanel
