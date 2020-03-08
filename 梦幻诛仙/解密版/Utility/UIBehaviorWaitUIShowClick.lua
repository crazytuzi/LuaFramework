local Lplus = require("Lplus")
local EC = require("Types.Vector3")
local ECPanelBase = Lplus.ForwardDeclare("ECPanelBase")
local UIBehaviorBase = require("Utility.UIBehaviorBase")
local UIBehaviorWaitUIShowClick = Lplus.Extend(UIBehaviorBase, "UIBehaviorWaitUIShowClick")
local def = UIBehaviorWaitUIShowClick.define
def.field(ECPanelBase)._targetUI = nil
def.field("string")._waitShowUIName = ""
def.field("string")._clickName = ""
def.field("function")._OnShowCallBack = nil
def.field("boolean")._ready = false
def.static(ECPanelBase, "string", "string", "=>", UIBehaviorWaitUIShowClick).New = function(targetUI, waitShowUIName, clickName)
  local ret = UIBehaviorWaitUIShowClick()
  ret:Init(targetUI, waitShowUIName, clickName)
  return ret
end
def.method(ECPanelBase, "string", "string").Init = function(self, targetUI, waitShowUIName, clickName)
  self._targetUI = targetUI
  self._clickName = clickName
  self._waitShowUIName = waitShowUIName
  self._done = false
  function self._OnShowCallBack(p1, p2)
    local panelName = p1[1]
    local panel = p1[2]
    if panelName == self._waitShowUIName then
      self:OnUIShow()
    end
  end
end
def.override("=>", "number").GetBehaviorTypeID = function(self)
  return UIBehaviorBase.UIBehavior_WAIT_UISHOW_SHOWUI
end
def.override().Prepare = function(self)
  Event.RegisterEvent(ModuleId.FIRST, gmodule.notifyId.First.Panel_PostCreate, self._OnShowCallBack)
end
def.override("=>", "boolean").IsReady = function(self)
  return self._ready
end
def.override().Do = function(self)
  if self._ready == false then
    return
  end
  self._targetUI:onClick(self._clickName)
  self._done = true
end
def.method().OnUIShow = function(self)
  self._ready = true
  Event.UnregisterEvent(ModuleId.FIRST, gmodule.notifyId.First.Panel_PostCreate, self._OnShowCallBack)
end
UIBehaviorWaitUIShowClick.Commit()
return UIBehaviorWaitUIShowClick
