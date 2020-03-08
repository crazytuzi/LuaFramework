local Lplus = require("Lplus")
local ISystemSetting = Lplus.Interface("ISystemSetting")
local def = ISystemSetting.define
do
  local OnRoleQuitRes = Lplus.Class("ISystemSetting.OnRoleQuitRes")
  local def = OnRoleQuitRes.define
  def.field("boolean").canQuit = true
  def.field("boolean").canelQuit = false
  def.field("string").reason = ""
  OnRoleQuitRes.Commit()
end
def.virtual("=>", "table").OnRoleQuit = function(self)
end
return ISystemSetting.Commit()
