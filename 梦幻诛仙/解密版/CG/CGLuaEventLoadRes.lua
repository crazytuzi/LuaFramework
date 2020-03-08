local Lplus = require("Lplus")
local CG = require("CG.CG")
local ECModel = require("Model.ECModel")
local EC = require("Types.Vector")
local ECPlayer = require("Model.ECPlayer")
local CGLuaEventLoadRes = Lplus.Class("CGLuaEventLoadRes")
local def = CGLuaEventLoadRes.define
local s_inst
def.static("=>", CGLuaEventLoadRes).Instance = function()
  if not s_inst then
    s_inst = CGLuaEventLoadRes()
  end
  return s_inst
end
def.method("table", "table", "userdata").DramaEvent_Start = function(self, dataTable, dramaTable, eventObj)
  local function OnLoadObj(obj)
    if obj then
      dataTable.obj = Object.Instantiate(obj, "GameObject")
    end
  end
  GameUtil.AsyncLoad(dataTable.resPath, OnLoadObj)
  if not eventObj.isnil then
    eventObj:Finish()
  end
end
def.method("table", "table", "userdata").DramaEvent_Release = function(self, dataTable, dramaTable, eventObj)
  dataTable.isFinished = true
  if dataTable.obj then
    Object.Destroy(dataTable.obj)
  end
end
CGLuaEventLoadRes.Commit()
CG.RegEvent("CGLuaEventLoadRes", CGLuaEventLoadRes.Instance())
return CGLuaEventLoadRes
