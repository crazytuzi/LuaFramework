local Lplus = require("Lplus")
local ConditionOp = Lplus.Class("ConditionOp")
do
  local def = ConditionOp.define
  def.virtual("=>", "boolean").hasState = function(self)
  end
  def.virtual("=>", "boolean").getState = function(self)
  end
  def.virtual("=>", "boolean").canWait = function(self)
  end
  def.virtual("function").wait = function(self, callback)
  end
  def.virtual().stopWaiting = function(self)
  end
end
ConditionOp.Commit()
return ConditionOp
