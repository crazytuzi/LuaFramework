local Lplus = require("Lplus")
local GUIFxMan = Lplus.Class("GUIFxMan")
local Vector = require("Types.Vector")
local def = GUIFxMan.define
local ECGUIMan = Lplus.ForwardDeclare("ECGUIMan")
def.field("userdata")._GUIFxMan = nil
local GUIFXRoot
def.field("userdata").fxroot = nil
def.field("number").fxoneId = 0
local s_man
def.static("=>", GUIFxMan).Instance = function()
  if not s_man then
    s_man = GUIFxMan()
    s_man:Init()
  end
  return s_man
end
def.method().Init = function(self)
  local panel_guifx = GameObject.GameObject("panel_guifx")
  panel_guifx:set_layer(ClientDef_Layer.UIFX)
  local UIRoot = GUIRoot.GetUIRootObj()
  panel_guifx.transform.parent = UIRoot.transform
  panel_guifx.transform.localPosition = Vector.Vector3.zero
  panel_guifx.transform.localScale = Vector.Vector3.one
  local uiPanel = panel_guifx:AddComponent("UIPanel")
  uiPanel.depth = 90000
  local root = GameObject.GameObject("FXRoot")
  root:set_layer(ClientDef_Layer.UIFX)
  root.parent = panel_guifx
  root:AddComponent("UIWidget")
  GUIFXRoot = root
  self.fxroot = root
end
def.method("userdata", "string", "number", "number", "number", "boolean", "=>", "userdata").PlayAsChild = function(self, parent, resName, offsetX, offsetY, lifetime, needHighLod)
  if not parent then
    return nil
  end
  local fx = GameUtil.RequestFx(resName, 1)
  if fx then
    fx:SetLayer(parent:get_layer())
    fx.parent = parent
    local fxone = fx:GetComponent("FxOne")
    self.fxoneId = self.fxoneId + 1
    fxone:set_id(self.fxoneId)
    fx.localPosition = Vector.Vector3.new(offsetX, offsetY, 0)
    fx.localScale = Vector.Vector3.one
    fxone:Play2(lifetime, needHighLod)
  else
    print("failed to get fx:", resName)
  end
  return fx
end
def.method("userdata", "string", "string", "number", "number", "number", "number", "number", "boolean", "function").PlayAsChildLayerWithCallback = function(self, parent, resName, objName, offsetX, offsetY, scaleX, scaleY, lifetime, needHighLod, cb)
  local function OnFxLoad(obj)
    if obj and parent ~= nil and not parent.isnil then
      local fx = Object.Instantiate(obj)
      fx:SetLayer(parent:get_layer())
      local widget = parent:GetComponent("UIWidget")
      if widget then
        do
          local w = widget:get_width()
          local h = widget:get_height()
          local depth = widget:get_depth()
          local renderers = fx:GetRenderersInChildren()
          local oldParticle = parent:FindDirect(objName)
          if oldParticle then
            Object.Destroy(oldParticle)
          end
          local particle = GameObject.GameObject(objName)
          particle:SetLayer(parent:get_layer())
          particle.parent = parent
          fx.parent = particle
          local offset = widget:get_pivotOffset()
          local offX = 0 - (offset.x - 0.5) * w + offsetX
          local offY = 0 - (offset.y - 0.5) * h + offsetY
          particle.localPosition = Vector.Vector3.new(offX, offY, 0)
          particle.localScale = Vector.Vector3.new(scaleX, scaleY, 0)
          for k, v in ipairs(renderers) do
            local go = v.gameObject
            local uiparticle = particle:AddComponent("UIParticle")
            uiparticle:set_depth(depth + 1)
            uiparticle:set_width(2)
            uiparticle:set_height(2)
            uiparticle:set_modelGameObject(go)
            uiparticle:SetCliping(true)
          end
          if parent:IsEq(GUIFXRoot) then
            if lifetime < 0 then
              local fxDuration = fx:GetComponent("FxDuration")
              if fxDuration then
                lifetime = fxDuration.duration
              end
            end
            if lifetime >= 0 then
              GameUtil.AddGlobalLateTimer(lifetime, true, function()
                self:RemoveFx(particle)
              end)
            end
          end
          if cb then
            cb(particle, depth + 2)
          end
        end
      else
        warn(resName, ":Trying to add Layer FX to a UI controll without a widget component, this maybe lead to unexpected result")
      end
    else
      warn(resName, ":Load failed")
    end
  end
  GameUtil.AsyncLoad(resName, OnFxLoad)
end
def.method("userdata", "string", "string", "number", "number", "number", "number", "number", "boolean").PlayAsChildLayer = function(self, parent, resName, objName, offsetX, offsetY, scaleX, scaleY, lifetime, needHighLod)
  self:PlayAsChildLayerWithCallback(parent, resName, objName, offsetX, offsetY, scaleX, scaleY, lifetime, needHighLod, nil)
end
def.method("string", "string", "number", "number", "number", "number", "number", "boolean").PlayLayer = function(self, resName, name, offsetX, offsetY, scaleX, scaleY, lifetime, needHighLod)
  self:PlayAsChildLayer(GUIFXRoot, resName, name, offsetX, offsetY, 1, 1, lifetime, needHighLod)
end
def.method("string", "string", "number", "number", "number", "boolean", "=>", "userdata").Play = function(self, resName, name, offsetX, offsetY, lifetime, needHighLod)
  return self:PlayAsChild(GUIFXRoot, resName, offsetX, offsetY, lifetime, needHighLod)
end
def.method("userdata", "number", "number").AddFx = function(self, fx, x, y)
  do return end
  fx.transform.parent = ECGUIMan.Instance().m_uifxRoot.transform
  fx.transform.localScale = Vector.Vector3.one
  fx.transform.localPosition = Vector.Vector3.new(x, y, 0)
  fx:SetLayer(ClientDef_Layer.UIFX)
  fx:SetActive(true)
  local fxDuration = fx:GetComponent("FxDuration")
  if fxDuration then
    local duration = fxDuration.duration
    if duration < 0 then
      return
    end
    GameUtil.AddGlobalLateTimer(duration, true, function()
      self:RemoveFx(fx)
    end)
  end
end
def.method("userdata").RemoveFx = function(self, fx)
  if fx == nil or fx.isnil then
    return
  end
  fx.transform.parent = nil
  local fxone = fx:GetComponent("FxOne")
  if fxone then
    fxone:Stop()
  else
    Object.Destroy(fx)
  end
end
GUIFxMan.Commit()
return GUIFxMan
