local Lplus = require("Lplus")
local TabNode = require("GUI.TabNode")
local ECPanelBase = require("GUI.ECPanelBase")
local TradingArcadeTabGroup = Lplus.Extend(TabNode, "TradingArcadeTabGroup")
local def = TradingArcadeTabGroup.define
def.field("number").nodeId = 0
def.method("table").InitEx = function(self, params)
  self:Init(params[1], params[2])
  self.nodeId = params[3]
end
return TradingArcadeTabGroup.Commit()
