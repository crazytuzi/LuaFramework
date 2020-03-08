local Lplus = require("Lplus")
local CG = require("CG.CG")
local ECModel = require("Model.ECModel")
local EC = require("Types.Vector")
local ECPlayer = require("Model.ECPlayer")
local CGEventCreatePlayer = Lplus.Class("CGEventCreatePlayer")
local def = CGEventCreatePlayer.define
local s_inst
def.static("=>", CGEventCreatePlayer).Instance = function()
  if not s_inst then
    s_inst = CGEventCreatePlayer()
  end
  return s_inst
end
def.method("table", "table", "userdata").DramaEvent_Start = function(self, dataTable, dramaTable, eventObj)
  local modelPath
  local m = ECPlayer()
  m:Init(dataTable.resourceID)
  m.m_bUncache = true
  if dataTable.resourceID > 0 then
    modelPath = GetModelPath(dataTable.resourceID)
    print("modelPath:", modelPath)
  else
    error("no set resourceID")
  end
  m:Load(modelPath, function(ret)
    if ret and not eventObj.isnil and not dataTable.isFinished then
      dataTable.model = m
      dramaTable[dataTable.id] = m
      local model = m.m_model
      if dramaTable.changeCamera then
        model:SetLayer(ClientDef_Layer.Player)
      end
      if dataTable.initPos then
        model.localPosition = Map2DPosTo3D(dataTable.pos3d_x, dataTable.pos3d_y)
        m.m_node2d.localPosition = dataTable.initPos.position
      else
        model.position = eventObj.gameObject.position
        model.forward = eventObj.gameObject.forward
      end
      model.parent = CG.Instance().m_rootObj
      model.localScale = EC.Vector3.one * dataTable.scale
      model.localRotation = Quaternion.Euler(EC.Vector3.new(0, dataTable.fAngle, 0))
      model:SetActive(not dataTable.hide)
      m:SetColor(dataTable.Color)
    elseif ret and dataTable.isFinished then
      m:Destroy()
    end
    if not eventObj.isnil then
      eventObj:Finish()
    end
  end)
end
def.method("table", "table", "userdata").DramaEvent_Release = function(self, dataTable, dramaTable, eventObj)
  dataTable.isFinished = true
  if dataTable.model then
    local m = dataTable.model
    m:Destroy()
    dataTable.model = nil
  end
  dramaTable[dataTable.id] = nil
end
CGEventCreatePlayer.Commit()
CG.RegEvent("CGLuaEventCreatePlayer", CGEventCreatePlayer.Instance())
return CGEventCreatePlayer
