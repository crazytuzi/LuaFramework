local Lplus = require("Lplus")
local ConvoyProtocols = Lplus.Class("ConvoyProtocols")
local def = ConvoyProtocols.define
local ActivityInterface = require("Main.activity.ActivityInterface")
local activityInterface = ActivityInterface.Instance()
def.static("table").OnSHuSongRes = function(p)
  activityInterface._husongcfgid = p.husongcfgid
  activityInterface.husong_couple_npc_cfgid = p.husong_couple_npc_cfgid
  require("Main.activity.convoy.ui.Convoy").Instance():Fill()
end
def.static("table").OnSupdateHuSong = function(p)
  activityInterface._husongMap = activityInterface._husongMap or {}
  for k, v in pairs(p.husongMap) do
    activityInterface._husongMap[k] = v
  end
end
def.static("table").OnSynHuSongData = function(p)
  activityInterface._husongMap = {}
  for k, v in pairs(p.husongMap) do
    activityInterface._husongMap[k] = v
  end
end
def.static("table").OnSSyncStartHuSong = function(p)
  Event.DispatchEvent(ModuleId.ACTIVITY, gmodule.notifyId.activity.Activity_Convoy_START, nil)
end
def.static("table").OnSEndHuSongRes = function(p)
  local heroModule = gmodule.moduleMgr:GetModule(ModuleId.HERO)
  heroModule:StopEscort()
  heroModule.myRole:Stop()
  if p.ret == p.NORMAL then
    Event.DispatchEvent(ModuleId.ACTIVITY, gmodule.notifyId.activity.Activity_Convoy_Succeed, nil)
  end
  Event.DispatchEvent(ModuleId.ACTIVITY, gmodule.notifyId.activity.Activity_Convoy_END, nil)
  activityInterface._husongcfgid = 0
end
ConvoyProtocols.Commit()
return ConvoyProtocols
