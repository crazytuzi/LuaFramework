local Lplus = require("Lplus")
local CG = require("CG.CG")
local ECModel = require("Model.ECModel")
local CGEventTrapTrigger = Lplus.Class("CGEventTrapTrigger")
local def = CGEventTrapTrigger.define
local s_inst
def.static("=>", CGEventTrapTrigger).Instance = function()
  if not s_inst then
    s_inst = CGEventTrapTrigger()
  end
  return s_inst
end
def.method("table", "table", "userdata").DramaEvent_Start = function(self, dataTable, dramaTable, eventObj)
end
def.method("table", "table", "userdata").DramaEvent_Update = function(self, dataTable, dramaTable, eventObj)
  local ecModel = dramaTable[dataTable.id]
  if ecModel then
    local pos = ecModel.m_model.position
    local dist = (pos - eventObj.gameObject.position).Length
    if dist <= dataTable.radius then
      eventObj:Finish()
    end
  end
end
def.method("table", "table", "userdata").DramaEvent_Release = function(self, dataTable, dramaTable, eventObj)
end
CGEventTrapTrigger.Commit()
CG.RegEvent("CGLuaEventTrapTrigger", CGEventTrapTrigger.Instance())
return CGEventTrapTrigger
