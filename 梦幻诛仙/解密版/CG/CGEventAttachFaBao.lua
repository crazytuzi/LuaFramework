local Lplus = require("Lplus")
local CG = require("CG.CG")
local EC = require("Types.Vector")
local ECModel = require("Model.ECModel")
local ECGame = Lplus.ForwardDeclare("ECGame")
local ECPlayer = require("Model.ECPlayer")
local CGEventAttachFaBao = Lplus.Class("CGEventAttachFaBao")
local def = CGEventAttachFaBao.define
local s_inst
def.static("=>", CGEventAttachFaBao).Instance = function()
  if not s_inst then
    s_inst = CGEventAttachFaBao()
  end
  return s_inst
end
def.method("table", "table", "userdata").DramaEvent_Start = function(self, dataTable, dramaTable, eventObj)
  local role = dramaTable[dataTable.hostid]
  role:SetFabao(dataTable.fabaoid)
  eventObj:Finish()
end
def.method("table", "table", "userdata").DramaEvent_Release = function(self, dataTable, dramaTable, eventObj)
  dataTable.isFinished = true
  if dataTable.model then
    local m = dataTable.model
    m:Destroy()
    dataTable.model = nil
  end
end
CGEventAttachFaBao.Commit()
CG.RegEvent("CGEventAttachFaBao", CGEventAttachFaBao.Instance())
return CGEventAttachFaBao
