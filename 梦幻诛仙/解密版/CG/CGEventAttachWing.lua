local Lplus = require("Lplus")
local CG = require("CG.CG")
local EC = require("Types.Vector")
local ECModel = require("Model.ECModel")
local ECGame = Lplus.ForwardDeclare("ECGame")
local ECPlayer = require("Model.ECPlayer")
local CGEventAttachWing = Lplus.Class("CGEventAttachWing")
local def = CGEventAttachWing.define
local s_inst
def.static("=>", CGEventAttachWing).Instance = function()
  if not s_inst then
    s_inst = CGEventAttachWing()
  end
  return s_inst
end
def.method("table", "table", "userdata").DramaEvent_Start = function(self, dataTable, dramaTable, eventObj)
  local role = dramaTable[dataTable.hostid]
  role:SetWing(dataTable.wingId, dataTable.dyeId)
  eventObj:Finish()
end
def.method("table", "table", "userdata").DramaEvent_Release = function(self, dataTable, dramaTable, eventObj)
  dataTable.isFinished = true
  if dataTable.model then
    local m = dataTable.model
    m:Destroy()
    dataTable.model = nil
  end
  local hostm = dramaTable[dataTable.hostid]
  hostm:DestroyChild("HH_Wing")
end
CGEventAttachWing.Commit()
CG.RegEvent("CGEventAttachWing", CGEventAttachWing.Instance())
return CGEventAttachWing
