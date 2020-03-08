local pb_helper = require("PB.pb_helper")
local ECGame = require("Main.ECGame")
local function on_gp_s2c_gs_ping(sender, msg)
  local game = ECGame.Instance()
  if msg.client_send_time == game.mLastCheckTime then
    local cur_time = math.fmod(math.floor(GameUtil.GetMillisecondsFromEpoch()), 60000)
    game.mClientLastTTL = cur_time - msg.client_send_time
    if game.mClientLastTTL < 0 then
      game.mClientLastTTL = game.mClientLastTTL + 60000
    end
  end
end
pb_helper.AddHandler("gp_s2c_gs_ping", on_gp_s2c_gs_ping)
