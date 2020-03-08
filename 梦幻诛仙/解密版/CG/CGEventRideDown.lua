local Lplus = require("Lplus")
local CG = require("CG.CG")
local ECModel = require("Model.ECModel")
local EC = require("Types.Vector")
local CGEventRideDown = Lplus.Class("CGEventRideDown")
local def = CGEventRideDown.define
local s_inst
def.static("=>", CGEventRideDown).Instance = function()
  if not s_inst then
    s_inst = CGEventRideDown()
  end
  return s_inst
end
def.method("table", "table", "userdata").DramaEvent_Start = function(self, dataTable, dramaTable, eventObj)
  self:RideDown(dataTable, dramaTable, eventObj)
  eventObj:Finish()
end
def.method("table", "table", "userdata").DramaEvent_Release = function(self, dataTable, dramaTable, eventObj)
  self:RideDown(dataTable, dramaTable, eventObj)
end
def.method("table", "table", "userdata").RideDown = function(self, dataTable, dramaTable, eventObj)
  local horse = dramaTable[dataTable.id]
  if not horse then
    return
  end
  local driver = horse:Detach("Ride")
  if driver then
    driver.m_model:FindChild("characterShadow"):SetActive(true)
    local model = driver.m_model
    local pos = horse.m_model.position
    local rotation = horse.m_model.rotation
    model.parent = CG.Instance().m_rootObj
    model.position = pos
    model.rotation = rotation
    driver:Play("Stand_c")
  end
  horse:Destroy()
  dramaTable[dataTable.id] = nil
end
CGEventRideDown.Commit()
CG.RegEvent("CGLuaEventRideDown", CGEventRideDown.Instance())
return CGEventRideDown
