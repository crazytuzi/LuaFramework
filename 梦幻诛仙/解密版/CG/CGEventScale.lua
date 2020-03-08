local Lplus = require("Lplus")
local CG = require("CG.CG")
local ECGame = Lplus.ForwardDeclare("ECGame")
local CGEventScale = Lplus.Class("CGEventScale")
local def = CGEventScale.define
local s_inst
def.static("=>", CGEventScale).Instance = function()
  if not s_inst then
    s_inst = CGEventScale()
  end
  return s_inst
end
def.method("table", "table", "userdata").DramaEvent_Start = function(self, dataTable, dramaTable, eventObj)
  print("eventScale:", dataTable.id, dataTable.scale)
  local go = dramaTable[dataTable.id]
  if not go then
    print("eventScale failed to find obj:", dataTable.id)
  end
  if type(go) == "table" then
    go = go.m_model
  end
  eventObj:Scale(go, dataTable.scale, dataTable.time)
end
def.method("table", "table", "userdata").DramaEvent_Release = function(self, dataTable, dramaTable, eventObj)
  dataTable.isFinished = true
end
CGEventScale.Commit()
CG.RegEvent("CGLuaEventScale", CGEventScale.Instance())
return CGEventScale
