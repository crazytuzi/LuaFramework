local Lplus = require("Lplus")
local EC = require("Types.Vector")
local ECMapEffect = Lplus.Class("ECMapEffect")
local def = ECMapEffect.define
def.field("table").effects = nil
def.field("boolean").fini = false
def.field("number").effectType = 0
local g_MapEffectRoot
def.static("=>", ECMapEffect).new = function()
  if not g_MapEffectRoot then
    g_MapEffectRoot = GameObject.GameObject("MapEffectRoot")
  end
  local obj = ECMapEffect()
  return obj
end
def.method("number", "number", "number", "table").Init = function(self, x, y, effectType, resnames)
  self.effectType = effectType
  self.effects = {}
  local function loaded(obj)
    if not obj or self.fini then
      return
    end
    local m = Object.Instantiate(obj, "GameObject")
    m:SetActive(false)
    m.parent = g_MapEffectRoot
    m.position = EC.Vector3.new(x, y, 0)
    m.localScale = EC.Vector3.one
    m:SetActive(true)
    m.localRotation = Quaternion.identity
    table.insert(self.effects, m)
  end
  for _, v in ipairs(resnames) do
    GameUtil.AsyncLoad(v, loaded)
  end
end
def.method().Release = function(self)
  if not self.effects then
    return
  end
  for _, v in pairs(self.effects) do
    v.parent = nil
    Object.Destroy(v)
  end
  self.effects = nil
  self.fini = true
end
ECMapEffect.Commit()
return ECMapEffect
