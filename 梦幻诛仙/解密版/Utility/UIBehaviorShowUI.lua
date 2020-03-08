local Lplus = require("Lplus")
local EC = require("Types.Vector3")
local ECPanelBase = Lplus.ForwardDeclare("ECPanelBase")
local UIBehaviorBase = require("Utility.UIBehaviorBase")
local UIBehaviorShowUI = Lplus.Extend(UIBehaviorBase, "UIBehaviorShowUI")
local def = UIBehaviorShowUI.define
def.field(ECPanelBase)._targetUI = nil
def.field("function")._showFunction = nil
def.static(ECPanelBase, "function", "=>", UIBehaviorShowUI).New = function(targetUI, showFunction)
  local ret = UIBehaviorShowUI()
  ret:Init(targetUI, showFunction)
  return ret
end
def.method(ECPanelBase, "function").Init = function(self, targetUI, showFunction)
  self._targetUI = targetUI
  self._showFunction = showFunction
  self._done = false
end
def.override("=>", "number").GetBehaviorTypeID = function(self)
  return UIBehaviorBase.UIBehavior_SHOWUI
end
def.override().Prepare = function(self)
end
def.override().Do = function(self)
  self._showFunction(self._targetUI)
  self._done = true
end
UIBehaviorShowUI.Commit()
return UIBehaviorShowUI
