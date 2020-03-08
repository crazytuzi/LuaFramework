local Lplus = require("Lplus")
local CG = require("CG.CG")
local EC = require("Types.Vector")
local ECModel = require("Model.ECModel")
local ECGame = Lplus.ForwardDeclare("ECGame")
local ECPlayer = require("Model.ECPlayer")
local CGEventCreateHostPlayer = Lplus.Class("CGEventCreateHostPlayer")
local def = CGEventCreateHostPlayer.define
local s_inst
def.static("=>", CGEventCreateHostPlayer).Instance = function()
  if not s_inst then
    s_inst = CGEventCreateHostPlayer()
  end
  return s_inst
end
def.method("table", "table", "userdata").DramaEvent_Start = function(self, dataTable, dramaTable, eventObj)
  local heroModule = require("Main.Hero.HeroModule")
  local role = heroModule.Instance().myRole
  if role ~= nil then
    self:createModel(dataTable, dramaTable, eventObj)
  else
    self:createModelByEditor(dataTable, dramaTable, eventObj)
  end
end
def.method("table", "table", "userdata").createModel = function(self, dataTable, dramaTable, eventObj)
  local heroModule = require("Main.Hero.HeroModule")
  local ecModel = heroModule.Instance().myRole
  ecModel:SetVisible(true)
  local m = ecModel:DuplicatePlayer()
  m.m_bUncache = true
  dataTable.model = m
  dramaTable[dataTable.id] = m
  local model = m.m_model
  if dataTable.initPos then
    model.localPosition = Map2DPosTo3D(dataTable.pos3d_x, dataTable.pos3d_y)
    m.m_node2d.localPosition = dataTable.initPos.position
  else
    model.position = eventObj.gameObject.position
    model.forward = eventObj.gameObject.forward
  end
  model.parent = CG.Instance().m_rootObj
  model.localScale = EC.Vector3.one * dataTable.scale
  warn("hostPlayer")
  m:SetVisible(true)
  if dataTable.hide then
    m:SetVisible(false)
  end
  local ECPate = require("GUI.ECPate")
  local pate = ECPate.new()
  pate:CreateNameBoardByCgEditor(m)
  ecModel:SetVisible(false)
  eventObj:Finish()
end
def.method("table", "table", "userdata").createModelByEditor = function(self, dataTable, dramaTable, eventObj)
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
  CG.Instance().hostPlayerCount = CG.Instance().hostPlayerCount - 1
end
CGEventCreateHostPlayer.Commit()
CG.RegEvent("CGLuaEventCreateHostPlayer", CGEventCreateHostPlayer.Instance())
return CGEventCreateHostPlayer
