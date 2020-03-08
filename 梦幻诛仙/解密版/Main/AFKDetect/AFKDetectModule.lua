local Lplus = require("Lplus")
local ModuleBase = require("Main.module.ModuleBase")
local AFKDetectModule = Lplus.Extend(ModuleBase, "AFKDetectModule")
require("Main.module.ModuleId")
local def = AFKDetectModule.define
local instance
def.static("=>", AFKDetectModule).Instance = function()
  if not instance then
    instance = AFKDetectModule()
    instance.m_moduleId = ModuleId.AFK_DETECT
  end
  return instance
end
def.override().Init = function(self)
  gmodule.network.registerProtocol("netio.protocol.mzm.gsp.afk.SRemind", AFKDetectModule.OnSRemind)
end
def.static("table").OnSRemind = function(p)
  local id = p.afk_detect_cfg_id
  local endTime = p.confirm_timestamp
  local tip = AFKDetectModule.GetRemindTip(id)
  require("GUI.CommonBtnCountDown").ShowBtnCountDown(textRes.Common[701], tip, textRes.Common[702], endTime, function(manual)
    if manual then
      AFKDetectModule.Replay(id)
    end
  end)
end
def.static("number").Replay = function(id)
  gmodule.network.sendProtocol(require("netio.protocol.mzm.gsp.afk.CReply").new(id))
end
def.static("number", "=>", "string").GetRemindTip = function(id)
  local record = DynamicData.GetRecord(CFG_PATH.DATA_AFK_DETECT, id)
  if record == nil then
    warn("GetRemind Tip nil", id)
    return ""
  end
  local tip = record:GetStringValue("remind_content")
  return tip
end
AFKDetectModule.Commit()
return AFKDetectModule
