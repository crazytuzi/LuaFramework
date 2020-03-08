local Lplus = require("Lplus")
local CG = require("CG.CG")
local ECModel = require("Model.ECModel")
local CGEventUITween = Lplus.Class("CGEventUITween")
local def = CGEventUITween.define
local s_inst
def.static("=>", CGEventUITween).Instance = function()
  if not s_inst then
    s_inst = CGEventUITween()
  end
  return s_inst
end
def.method("table", "table", "userdata").DramaEvent_Start = function(self, dataTable, dramaTable, eventObj)
  if dataTable.id == "" then
    eventObj:SetTweenTransform(eventObj.gameObject.transform)
    return
  end
  local ecModel = dramaTable[dataTable.id]
  if ecModel then
    eventObj:SetTweenTransform(ecModel.m_model.transform)
  else
    print("failed to find ecModel of id:", dataTable.id)
  end
end
def.method("table", "table", "userdata").DramaEvent_Release = function(self, dataTable, dramaTable, eventObj)
end
CGEventUITween.Commit()
CG.RegEvent("CGEventUITween", CGEventUITween.Instance())
return CGEventUITween
