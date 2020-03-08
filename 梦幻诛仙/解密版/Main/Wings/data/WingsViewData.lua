local Lplus = require("Lplus")
local WingsViewData = Lplus.Class("WingsViewData")
local def = WingsViewData.define
def.field("number").modelId = 0
def.field("number").dyeId = 0
def.method("table").RawSet = function(self, data)
  self.modelId = data.modelId
  self.dyeId = data.dyeId
end
return WingsViewData.Commit()
