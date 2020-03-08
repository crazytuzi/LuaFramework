local Lplus = require("Lplus")
local CG = require("CG.CG")
local ECModel = require("Model.ECModel")
local ECFxMan = require("Fx.ECFxMan")
local ECPlayer = require("Model.ECPlayer")
local ECGame = require("Main.ECGame")
local CGLuaEventCameraOrtheSize = Lplus.Class("CGLuaEventCameraOrtheSize")
local def = CGLuaEventCameraOrtheSize.define
local s_inst, o2dSize, o3dSize
def.static("=>", CGLuaEventCameraOrtheSize).Instance = function()
  if not s_inst then
    s_inst = CGLuaEventCameraOrtheSize()
  end
  return s_inst
end
def.method("table", "table", "userdata").DramaEvent_Start = function(self, dataTable, dramaTable, eventObj)
  local ecPlayer = dramaTable[dataTable.id]
  if dataTable.camType == 0 then
    if o2dSize == nil then
      o2dSize = ECGame.Instance().m_2DWorldCam.orthographicSize
    end
    CameraOrthoTween.TweenCameraOrtheSize(ECGame.Instance().m_2DWorldCam, dataTable.from, dataTable.to, dataTable._interval)
  elseif dataTable.camType == 1 then
    if o3dSize == nil then
      o3dSize = ECGame.Instance().m_Main3DCamComponent.orthographicSize
    end
    CameraOrthoTween.TweenCameraOrtheSize(ECGame.Instance().m_Main3DCamComponent, dataTable.from, dataTable.to, dataTable._interval)
  end
end
def.method("table", "table", "userdata").DramaEvent_Release = function(self, dataTable, dramaTable, eventObj)
  dataTable.isFinished = true
  if dataTable.camType == 0 then
    ECGame.Instance().m_2DWorldCam.orthographicSize = o2dSize
    local hudCam = require("GUI.ECGUIMan").Instance().m_hudCameraGo:GetComponent("Camera")
    hudCam.orthographicSize = o2dSize
    CameraOrthoTween.TweenCameraStop(hudCam)
    CameraOrthoTween.TweenCameraStop(ECGame.Instance().m_2DWorldCam)
  elseif dataTable.camType == 1 then
    ECGame.Instance().m_Main3DCamComponent.orthographicSize = o3dSize
    CameraOrthoTween.TweenCameraStop(ECGame.Instance().m_Main3DCamComponent)
  end
end
CGLuaEventCameraOrtheSize.Commit()
CG.RegEvent("CGLuaEventCameraOrtheSize", CGLuaEventCameraOrtheSize.Instance())
return CGLuaEventCameraOrtheSize
