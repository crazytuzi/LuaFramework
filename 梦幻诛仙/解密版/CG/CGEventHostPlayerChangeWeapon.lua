local Lplus = require("Lplus")
local CG = require("CG.CG")
local ECModel = require("Model.ECModel")
local ECFxMan = require("Fx.ECFxMan")
local ECGUIMan = Lplus.ForwardDeclare("ECGUIMan")
local ECGame = Lplus.ForwardDeclare("ECGame")
local CGEventHostPlayerChangeWeapon = Lplus.Class("CGEventHostPlayerChangeWeapon")
local def = CGEventHostPlayerChangeWeapon.define
local s_inst
def.static("=>", CGEventHostPlayerChangeWeapon).Instance = function()
  if not s_inst then
    s_inst = CGEventHostPlayerChangeWeapon()
  end
  return s_inst
end
def.method("table", "table", "userdata").DramaEvent_Start = function(self, dataTable, dramaTable, eventObj)
  if CG.Instance().isInArtEditor then
    eventObj:Finish()
    return
  end
  local ecModel = dramaTable[dataTable.hostid]
  print("EventHideObj:", dataTable.hide)
  if ecModel then
    local hostPlayer = ECGame.Instance().m_HostPlayer
    if dataTable.inHand then
      hostPlayer:TakeUpWeapon2(ecModel)
    else
      hostPlayer:HolsterWeapon2(ecModel)
    end
  end
  eventObj:Finish()
end
def.method("table", "table", "userdata").DramaEvent_Release = function(self, dataTable, dramaTable, eventObj)
  dataTable.isFinished = true
end
CGEventHostPlayerChangeWeapon.Commit()
CG.RegEvent("CGLuaEventHostPlayerChangeWeapon", CGEventHostPlayerChangeWeapon.Instance())
return CGEventHostPlayerChangeWeapon
