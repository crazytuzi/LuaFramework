local Lplus = require("Lplus")
local CG = require("CG.CG")
local ECGame = Lplus.ForwardDeclare("ECGame")
local CGEventShake = Lplus.Class("CGEventShake")
local def = CGEventShake.define
local s_inst
def.static("=>", CGEventShake).Instance = function()
  if not s_inst then
    s_inst = CGEventShake()
  end
  return s_inst
end
def.method("table", "table", "userdata").DramaEvent_Start = function(self, dataTable, dramaTable, eventObj)
  local go = Camera.main.gameObject
  if dataTable.id and dataTable.id ~= "" then
    go = dramaTable[dataTable.id]
    if type(go) == "table" then
      go = go.m_model
    end
  elseif not CG.Instance().isInArtEditor and not dramaTable.changeCamera then
    CG.Instance():ChangeCamera()
    dramaTable.changeCamera = true
    go = Camera.main.gameObject
  end
  eventObj:Shake(go, dataTable.amount, dataTable.time)
end
def.method("table", "table", "userdata").DramaEvent_Release = function(self, dataTable, dramaTable, eventObj)
  dataTable.isFinished = true
end
CGEventShake.Commit()
CG.RegEvent("CGLuaEventShake", CGEventShake.Instance())
return CGEventShake
