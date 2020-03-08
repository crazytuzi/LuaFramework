local Lplus = require("Lplus")
local CG = require("CG.CG")
local ECGame = Lplus.ForwardDeclare("ECGame")
local CGEventShowText = Lplus.Class("CGEventShowText")
local def = CGEventShowText.define
local s_inst
def.static("=>", CGEventShowText).Instance = function()
  if not s_inst then
    s_inst = CGEventShowText()
  end
  return s_inst
end
def.method("table", "table", "userdata").DramaEvent_Start = function(self, dataTable, dramaTable, eventObj)
  local txt = CG.Instance():GetText(dataTable.resourceID)
  local panel = dramaTable.cgpanel
  panel:SetDialogText(txt)
  eventObj:Finish()
end
def.method("table", "table", "userdata").DramaEvent_Release = function(self, dataTable, dramaTable, eventObj)
  local panel = dramaTable.cgpanel
  if panel then
    panel:SetDialogText("")
  end
  dataTable.isFinished = true
end
CGEventShowText.Commit()
CG.RegEvent("CGLuaEventShowText", CGEventShowText.Instance())
return CGEventShowText
