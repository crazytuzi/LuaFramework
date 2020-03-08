local MODULE_NAME = (...)
local Lplus = require("Lplus")
local TabNode = require("GUI.TabNode")
local ECPanelBase = require("GUI.ECPanelBase")
local RoomNodeBase = Lplus.Extend(TabNode, MODULE_NAME)
local def = RoomNodeBase.define
def.field("string").nodeId = ""
def.method("table").InitEx = function(self, params)
  self:Init(params[1], params[2])
  self.nodeId = params[3]
end
return RoomNodeBase.Commit()
