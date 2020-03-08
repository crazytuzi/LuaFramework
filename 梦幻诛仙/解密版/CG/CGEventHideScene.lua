local Lplus = require("Lplus")
local CG = require("CG.CG")
local ECModel = require("Model.ECModel")
local ECFxMan = require("Fx.ECFxMan")
local ECGUIMan = Lplus.ForwardDeclare("ECGUIMan")
local ECGame = Lplus.ForwardDeclare("ECGame")
local CGEventHideScene = Lplus.Class("CGEventHideScene")
local def = CGEventHideScene.define
local s_inst
def.static("=>", CGEventHideScene).Instance = function()
  if not s_inst then
    s_inst = CGEventHideScene()
  end
  return s_inst
end
def.method("table", "table", "userdata").DramaEvent_Start = function(self, dataTable, dramaTable, eventObj)
  print("EventHideScene:", dataTable.hide)
  if CG.Instance().isInArtEditor then
    eventObj:Finish()
    return
  end
  if dataTable.hide then
    self:HideScene(true, dramaTable)
  else
    self:HideScene(false, dramaTable)
  end
  dramaTable.sceneLayerChanged = not dataTable.hide
  eventObj:Finish()
end
def.method("table", "table", "userdata").DramaEvent_Release = function(self, dataTable, dramaTable, eventObj)
  if CG.Instance().isInArtEditor then
    return
  end
  if dataTable.hide then
    self:HideScene(false, dramaTable)
  end
end
def.method("boolean", "table").HideScene = function(self, hide, dramaTable)
  CG.Instance().m_isHideScene = hide
  if hide and not dramaTable.changeCamera then
    CG.Instance():ChangeCamera()
    dramaTable.changeCamera = true
  elseif not hide and dramaTable.changeCamera then
    CG.Instance():RestoreCamera()
    dramaTable.changeCamera = false
  end
  ECGUIMan.Instance().m_camera.cullingMask = bit.lshift(1, hide and ClientDef_Layer.UICG or ClientDef_Layer.UI)
  ECGUIMan.Instance().m_ui2Camera.enabled = not hide
  UIModel.root2attachCamera:SetActive(not hide)
  ECGUIMan.Instance().m_hudCamera.enabled = not hide
  local cgcamera = ECGame.Instance().m_2DWorldCam:GetComponent("Camera")
  if hide then
    cgcamera.cullingMask = bit.lshift(1, ClientDef_Layer.Default) + bit.lshift(1, ClientDef_Layer.Building) + bit.lshift(1, ClientDef_Layer.SmallBuilding) + bit.lshift(1, ClientDef_Layer.FXCG)
  else
    cgcamera.cullingMask = default_cull_mask
  end
end
CGEventHideScene.Commit()
CG.RegEvent("CGLuaEventHideScene", CGEventHideScene.Instance())
return CGEventHideScene
