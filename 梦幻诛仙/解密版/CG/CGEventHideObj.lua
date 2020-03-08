local Lplus = require("Lplus")
local CG = require("CG.CG")
local ECModel = require("Model.ECModel")
local ECFxMan = require("Fx.ECFxMan")
local ECGUIMan = Lplus.ForwardDeclare("ECGUIMan")
local ECGame = Lplus.ForwardDeclare("ECGame")
local CGEventHideObj = Lplus.Class("CGEventHideObj")
local def = CGEventHideObj.define
local s_inst
def.static("=>", CGEventHideObj).Instance = function()
  if not s_inst then
    s_inst = CGEventHideObj()
  end
  return s_inst
end
def.method("table", "table", "userdata").DramaEvent_Start = function(self, dataTable, dramaTable, eventObj)
  local ecModel = dramaTable[dataTable.id]
  print("EventHideObj:", dataTable.hide)
  if ecModel then
    ecModel.m_model:SetActive(not dataTable.hide)
    if ecModel.m_uiNameHandle then
      ecModel.m_uiNameHandle:SetActive(not dataTable.hide)
    end
  end
  eventObj:Finish()
end
def.method("table", "table", "userdata").DramaEvent_Release = function(self, dataTable, dramaTable, eventObj)
end
CGEventHideObj.Commit()
CG.RegEvent("CGLuaEventHideObj", CGEventHideObj.Instance())
return CGEventHideObj
