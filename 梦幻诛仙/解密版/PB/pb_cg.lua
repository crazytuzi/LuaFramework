local Lplus = require("Lplus")
local pb_helper = require("PB.pb_helper")
local net_common = require("PB.net_common")
local CG = require("CG.CG")
local function on_gp_start_cg(sender, msg)
  print("on_gp_start_cg", msg.cg_id)
  local cg = CG.Instance()
  local id = msg.cg_id
  cg:PlayById(id, "server" .. tostring(id), nil)
end
pb_helper.AddHandler("gp_start_cg", on_gp_start_cg)
local function on_gp_stop_cg(sender, msg)
  print("--------------------------------------on_gp_stop_cg", msg.cg_id)
  local id = msg.cg_id
  if not id then
    return
  end
  local cg = CG.Instance()
  cg:Stop("server" .. tostring(id))
end
pb_helper.AddHandler("gp_stop_cg", on_gp_stop_cg)
local CGProt = Lplus.Class("CGProt")
local def = CGProt.define
def.static("boolean").Skip = function(skip)
  local msg = net_common.gp_cg_player_op()
  msg.skip = skip
  pb_helper.Send(msg)
end
CGProt.Commit()
return CGProt
