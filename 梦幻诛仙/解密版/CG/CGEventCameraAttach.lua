local Lplus = require("Lplus")
local CG = require("CG.CG")
local ECGame = Lplus.ForwardDeclare("ECGame")
local CGEventCameraAttach = Lplus.Class("CGEventCameraAttach")
local def = CGEventCameraAttach.define
local s_inst
def.static("=>", CGEventCameraAttach).Instance = function()
  if not s_inst then
    s_inst = CGEventCameraAttach()
  end
  return s_inst
end
def.method("table", "table", "userdata").DramaEvent_Start = function(self, dataTable, dramaTable, eventObj)
  if CG.Instance().isInArtEditor then
    eventObj:Finish()
    return
  end
  local go = Camera.main.gameObject
  if dataTable.id and dataTable.id ~= "" then
    go = dramaTable[dataTable.id]
    if type(go) == "table" then
      go = go.m_model
      MainCamera.host = go
      dramaTable.changeCameraAttach = true
      dramaTable.automovemode = MainCamera.automovemode
      MainCamera.automovemode = true
      MainCamera.cgfollowmode = true
    end
  elseif dramaTable.changeCameraAttach then
    dramaTable.changeCameraAttach = false
    MainCamera.host = nil
    dramaTable.changeCameraAttach = nil
    MainCamera.automovemode = dramaTable.automovemode
    MainCamera.cgfollowmode = false
    dramaTable.automovemode = nil
  end
  eventObj:Finish()
end
def.method("table", "table", "userdata").DramaEvent_Release = function(self, dataTable, dramaTable, eventObj)
end
CGEventCameraAttach.Commit()
CG.RegEvent("CGLuaEventCameraAttach", CGEventCameraAttach.Instance())
return CGEventCameraAttach
