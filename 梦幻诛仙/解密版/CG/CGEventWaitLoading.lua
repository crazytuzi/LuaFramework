local Lplus = require("Lplus")
local CG = require("CG.CG")
local CGEventWaitLoading = Lplus.Class("CGEventWaitLoading")
local def = CGEventWaitLoading.define
local s_inst
def.static("=>", CGEventWaitLoading).Instance = function()
  if not s_inst then
    s_inst = CGEventWaitLoading()
  end
  return s_inst
end
def.method("table", "table", "userdata").DramaEvent_Start = function(self, dataTable, dramaTable, eventObj)
  CG.Instance().m_waitloading = dataTable.suspend
  eventObj:Finish()
end
def.method("table", "table", "userdata").DramaEvent_Release = function(self, dataTable, dramaTable, eventObj)
  CG.Instance().m_waitloading = false
end
CGEventWaitLoading.Commit()
CG.RegEvent("CGLuaEventWaitLoading", CGEventWaitLoading.Instance())
return CGEventWaitLoading
