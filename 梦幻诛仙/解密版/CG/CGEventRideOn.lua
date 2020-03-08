local Lplus = require("Lplus")
local CG = require("CG.CG")
local ECModel = require("Model.ECModel")
local EC = require("Types.Vector")
local CGEventRideOn = Lplus.Class("CGEventRideOn")
local def = CGEventRideOn.define
local _vehicle_offset = {
  pos = {
    x = 0,
    y = 0,
    z = 0
  },
  angle = {
    x = 0,
    y = -90,
    z = 180
  }
}
local s_inst
def.static("=>", CGEventRideOn).Instance = function()
  if not s_inst then
    s_inst = CGEventRideOn()
  end
  return s_inst
end
def.method("table", "table", "userdata").DramaEvent_Start = function(self, dataTable, dramaTable, eventObj)
  print("Model:", dataTable.model)
  print("resourceID:", dataTable.resourceID)
  print("eventObj:", eventObj, getmetatable(eventObj))
  local m = ECModel.new()
  m.m_bUncache = true
  local modelPath = dataTable.model
  if dataTable.resourceID > 0 then
    modelPath = datapath.GetPathByID(dataTable.resourceID)
    print("modelPath:", modelPath)
  end
  m:Load(modelPath, function(ret)
    if ret and not eventObj.isnil and not dataTable.isFinished then
      dataTable.model = m
      dramaTable[dataTable.id] = m
      print("go:", eventObj.Finish)
      local model = m.m_model
      if dataTable.initPos then
        model.position = dataTable.initPos.position
        model.forward = dataTable.initPos.forward
      else
        model.position = eventObj.gameObject.position
        model.forward = eventObj.gameObject.forward
      end
      model.parent = CG.Instance().m_rootObj
      model.localScale = EC.Vector3.one * dataTable.scale
      local driver = dramaTable[dataTable.driverid]
      model:SetActive(not dataTable.hide)
      m:AttachModelEx("Ride", driver, "Bip01 Spine1", _vehicle_offset.pos, _vehicle_offset.angle)
      local shadowGo = driver.m_model:FindChild("characterShadow")
      if shadowGo then
        shadowGo:SetActive(false)
      end
      if not dataTable.shadow then
        local shadowGo = m.m_model:FindChild("characterShadow_npc")
        if shadowGo then
          shadowGo:SetActive(false)
        end
      end
    elseif ret and dataTable.isFinished then
      m:Destroy()
    end
    if not eventObj.isnil then
      eventObj:Finish()
    end
  end)
end
def.method("table", "table", "userdata").DramaEvent_Release = function(self, dataTable, dramaTable, eventObj)
  print("CGEventRideOn release")
  dataTable.isFinished = true
  if dataTable.model then
    local m = dataTable.model
    if m then
      m:Destroy()
      dramaTable[dataTable.id] = nil
    end
    dataTable.model = nil
  end
end
CGEventRideOn.Commit()
CG.RegEvent("CGLuaEventRideOn", CGEventRideOn.Instance())
return CGEventRideOn
