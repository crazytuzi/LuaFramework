local Lplus = require("Lplus")
local CG = require("CG.CG")
local ECModel = require("Model.ECModel")
local ECPate = require("GUI.ECPate")
local CGLuaEventUIAttachModel = Lplus.Class("CGLuaEventUIAttachModel")
local def = CGLuaEventUIAttachModel.define
local s_inst
def.static("=>", CGLuaEventUIAttachModel).Instance = function()
  if not s_inst then
    s_inst = CGLuaEventUIAttachModel()
  end
  return s_inst
end
def.method("table", "table", "userdata").DramaEvent_Start = function(self, dataTable, dramaTable, eventObj)
  local ecModel = dramaTable[dataTable.id]
  if ecModel and dataTable.resName ~= "" then
    if eventObj.isnil then
      return
    end
    if dataTable.isFinished then
      eventObj:Finish()
      return
    end
    do
      local pate = ECPate.new()
      pate:CreateUIBoard(ecModel, dataTable.resName, dataTable.offsetH, dataTable.txt, dataTable.endtime, dataTable.mType)
      eventObj:SetEndTime(dataTable.endtime)
      if dataTable.endtime > 0 and dataTable.mType ~= 3 then
        GameUtil.AddCGTimer(dataTable.endtime, true, function()
          if pate ~= nil and pate.m_pate ~= nil then
            if pate.m_pate.isnil then
              return
            end
            pate.m_pate:SetActive(false)
          end
        end)
      end
    end
  end
end
def.method("table", "table", "userdata").DramaEvent_Release = function(self, dataTable, dramaTable, eventObj)
  print("UIattachModel End")
  local ecModel = dramaTable[dataTable.id]
  dataTable.isFinished = true
end
CGLuaEventUIAttachModel.Commit()
CG.RegEvent("CGLuaEventUIAttachModel", CGLuaEventUIAttachModel.Instance())
return CGLuaEventUIAttachModel
