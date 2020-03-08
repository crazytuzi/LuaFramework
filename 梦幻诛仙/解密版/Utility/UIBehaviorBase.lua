local Lplus = require("Lplus")
local EC = require("Types.Vector3")
local UIBehaviorBase = Lplus.Class("UIBehaviorBase")
local def = UIBehaviorBase.define
def.const("number").UIBehavior_SHOWUI = 1
def.const("number").UIBehavior_WAIT_UISHOW_SHOWUI = 2
def.const("number").UIBehavior_WAIT_UISHOW_Click = 3
def.field("boolean")._done = false
def.virtual("=>", "number").GetBehaviorTypeID = function(self)
  return 0
end
def.virtual().Prepare = function(self)
end
def.virtual().OnFrame = function(self)
end
def.virtual("=>", "boolean").IsReady = function(self)
  return true
end
def.virtual().Do = function(self)
end
def.virtual("=>", "boolean").IsDone = function(self)
  return self._done
end
UIBehaviorBase.Commit()
return UIBehaviorBase
