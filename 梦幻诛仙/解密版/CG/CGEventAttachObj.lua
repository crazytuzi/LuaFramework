local Lplus = require("Lplus")
local CG = require("CG.CG")
local ECModel = require("Model.ECModel")
local ECFxMan = require("Fx.ECFxMan")
local ECGUIMan = Lplus.ForwardDeclare("ECGUIMan")
local ECGame = Lplus.ForwardDeclare("ECGame")
local CGEventAttachObj = Lplus.Class("CGEventAttachObj")
local def = CGEventAttachObj.define
local s_inst
def.static("=>", CGEventAttachObj).Instance = function()
  if not s_inst then
    s_inst = CGEventAttachObj()
  end
  return s_inst
end
def.method("table", "table", "userdata").DramaEvent_Start = function(self, dataTable, dramaTable, eventObj)
  local hostModel = dramaTable[dataTable.hostid]
  local attachmentModel = dramaTable[dataTable.attachmentid]
  print("EventAttachObj:", dataTable.hostid, dataTable.attachmentid, dataTable.attach)
  if dataTable.attach then
    hostModel:AttachModelEx(dataTable.hp, attachmentModel, dataTable.bonename, dataTable.offset, dataTable.rotation)
    local moveevents = dramaTable.moves
    if moveevents then
      local moveevent = moveevents[dataTable.attachmentid]
      if moveevent then
        moveevent:Finish()
        moveevents[dataTable.attachmentid] = nil
      end
    end
  else
    hostModel:Detach(dataTable.hp)
  end
  eventObj:Finish()
end
def.method("table", "table", "userdata").DramaEvent_Release = function(self, dataTable, dramaTable, eventObj)
end
CGEventAttachObj.Commit()
CG.RegEvent("CGLuaEventAttachObj", CGEventAttachObj.Instance())
return CGEventAttachObj
