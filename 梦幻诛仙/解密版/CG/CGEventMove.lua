local Lplus = require("Lplus")
local CG = require("CG.CG")
local ECModel = require("Model.ECModel")
local CGEventMove = Lplus.Class("CGEventMove")
local def = CGEventMove.define
local s_inst
def.static("=>", CGEventMove).Instance = function()
  if not s_inst then
    s_inst = CGEventMove()
  end
  return s_inst
end
def.method("table", "table", "userdata").DramaEvent_Start = function(self, dataTable, dramaTable, eventObj)
  print("eventmove:", dataTable.id, " ", dataTable.driverType)
  if dataTable.driverType == 0 then
    if not CG.Instance().isInArtEditor and not dramaTable.changeCamera then
      CG.Instance():ChangeCamera()
      dramaTable.changeCamera = true
    end
  elseif dataTable.id ~= "" then
    local ecModel = dramaTable[dataTable.id]
    if not ecModel then
      Debug.LogError("EventMove: failed to find id:" .. dataTable.id)
    else
      eventObj.mDriver = ecModel.m_model.transform
    end
    local moveevents = dramaTable.moves
    if not moveevents then
      moveevents = {}
      dramaTable.moves = moveevents
    end
    moveevents[dataTable.id] = eventObj
    if ecModel.m_node2d ~= nil then
      eventObj.mNode2dTm = ecModel.m_node2d.transform
    end
  end
  if dataTable.targetid ~= "" then
    local ecModel = dramaTable[dataTable.id]
    if not ecModel then
      Debug.LogError("EventMove: failed to find id:" .. dataTable.id)
    else
      eventObj.mTarget = ecModel.m_model.transform
    end
  end
end
def.method("table", "table", "userdata").DramaEvent_Release = function(self, dataTable, dramaTable, eventObj)
  local moveevents = dramaTable.moves
  if moveevents then
    moveevents[dataTable.id] = nil
  end
  dataTable.isFinished = true
end
CGEventMove.Commit()
CG.RegEvent("CGLuaEventMove", CGEventMove.Instance())
return CGEventMove
