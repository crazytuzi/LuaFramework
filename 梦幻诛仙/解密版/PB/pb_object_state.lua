local Lplus = require("Lplus")
local pb_helper = require("PB.pb_helper")
local ECGame = require("Main.ECGame")
local function on_object_state_respond(sender, msg)
  local obj = ECGame.Instance().m_CurWorld:FindObjectOrHost(msg.roleid)
  if obj then
    obj:UpdateObjectState(msg)
  end
end
pb_helper.AddHandler("gp_object_state", on_object_state_respond)
