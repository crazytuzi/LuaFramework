local Lplus = require("Lplus")
local MainUIUtils = Lplus.Class("MainUIUtils")
local Vector = require("Types.Vector")
local BitMap = require("Types.BitMap")
local MainUIModule = Lplus.ForwardDeclare("MainUIModule")
local def = MainUIUtils.define
def.static("userdata", "boolean", "table").AlphaExpand = function(go, isExpand, params)
  if go == nil or go.isnil then
    return
  end
  local tweenAlpha = go:GetComponent("TweenAlpha")
  if tweenAlpha == nil then
    tweenAlpha = go:AddComponent("TweenAlpha")
    tweenAlpha.from = 1
    tweenAlpha.to = 0
    tweenAlpha.duration = 0.2
    tweenAlpha.steeperCurves = true
  end
  if isExpand then
    tweenAlpha.delay = 0.2
    if go.activeInHierarchy then
      tweenAlpha:PlayReverse()
    else
      local uiPanel = go:GetComponent("UIPanel")
      if uiPanel then
        uiPanel.alpha = tweenAlpha.from
      else
        local uiWidget = go:GetComponent("UIWidget")
        uiWidget.alpha = tweenAlpha.from
      end
    end
  else
    tweenAlpha.delay = 0
    if go.activeInHierarchy then
      tweenAlpha:PlayForward()
    else
      local uiPanel = go:GetComponent("UIPanel")
      if uiPanel then
        uiPanel.alpha = tweenAlpha.to
      else
        local uiWidget = go:GetComponent("UIWidget")
        uiWidget.alpha = tweenAlpha.to
      end
    end
  end
end
def.static("table", "table", "=>", BitMap).SetUndisplayScenes = function(bitmap, sceneids)
  if bitmap == nil then
    bitmap = BitMap.New(0)
  end
  for i, id in ipairs(sceneids) do
    bitmap:SetBit(id, 1)
  end
  return bitmap
end
def.static("table", "=>", "boolean").CanDisplayByUndisplayBitmap = function(undisplayBitmap)
  if undisplayBitmap == nil then
    return true
  end
  local sceneBitMap = MainUIModule.Instance().sceneBitMap
  if undisplayBitmap:AND(sceneBitMap):IsZero() then
    return true
  else
    return false
  end
end
return MainUIUtils.Commit()
