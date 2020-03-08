local MODULE_NAME = (...)
local Lplus = require("Lplus")
local TabNode = require("GUI.TabNode")
local LeftTabGroupBase = Lplus.Extend(TabNode, MODULE_NAME)
local def = LeftTabGroupBase.define
def.virtual("number").OnOpen = function(self, index)
end
return LeftTabGroupBase.Commit()
