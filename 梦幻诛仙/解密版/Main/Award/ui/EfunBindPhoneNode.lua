local CUR_CLASS_NAME = (...)
local Lplus = require("Lplus")
local ECPanelBase = require("GUI.ECPanelBase")
local AloneNodeBase = require("Main.Award.ui.AloneNodeBase")
local EfunBindPhoneAwardNode = Lplus.Extend(AloneNodeBase, CUR_CLASS_NAME)
local def = EfunBindPhoneAwardNode.define
def.override(ECPanelBase, "userdata").Init = function(self, base, node)
  AloneNodeBase.Init(self, base, node)
end
def.override("=>", "boolean").IsOpen = function(self)
  return require("Main.CustomActivity.CustomActivityInterface").Instance():IsBindPhoneAwardOpen()
end
def.override("=>", "boolean").IsHaveNotifyMessage = function(self)
  if not self:IsOpen() then
    return false
  end
  return require("Main.CustomActivity.CustomActivityInterface").Instance():IsBindPhone()
end
def.override("=>", ECPanelBase).CreatePanel = function(self)
  if ClientCfg.GetSDKType() == ClientCfg.SDKTYPE.MSDK then
    return nil
  end
  self.panel = require("Main.Award.ui.EfunBindPhonePanel").Instance()
  self.panel:ShowPanel()
  return self.panel
end
return EfunBindPhoneAwardNode.Commit()
