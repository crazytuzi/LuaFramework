local Lplus = require("Lplus")
local ECObject = require("Object.ECObject")
local ECAniEventMgr = Lplus.Class("ECAniEventMgr")
local def = ECAniEventMgr.define
local ANI_EVENT_TYPE = {
  AET_QTE = 0,
  AET_COMMON = 1,
  AET_SOUND = 2,
  AET_SHAKE = 3,
  AET_HIDE_MONSTER = 4,
  AET_SKILL = 5
}
local GetAniEventType = function(param)
  local integral, fractional = math.modf(param / 10000000)
  return integral
end
local GetAniEventParam1 = function(param)
  local integral1, fractional1 = math.modf(param / 10000000)
  local integral2, fractional2 = math.modf((param - integral1 * 10000000) / 1000)
  return integral2
end
local GetAniEventParam2 = function(param)
  local integral, fractional = math.modf(param / 1000)
  return param - integral * 1000
end
local s_init
def.static("=>", ECAniEventMgr).Instance = function()
  if s_init == nil then
    s_init = ECAniEventMgr()
  end
  return s_init
end
def.method("string", "string", "=>", "table").Split = function(self, szFullString, szSeprator)
  local nFindStartIndex = 1
  local nSplitIndex = 1
  local nSplitArray = {}
  while true do
    local nFindLastIndex = string.find(szFullString, szSeprator, nFindStartIndex)
    if not nFindLastIndex then
      nSplitArray[nSplitIndex] = string.sub(szFullString, nFindStartIndex, string.len(szFullString))
      break
    end
    nSplitArray[nSplitIndex] = string.sub(szFullString, nFindStartIndex, nFindLastIndex - 1)
    nFindStartIndex = nFindLastIndex + string.len(szSeprator)
    nSplitIndex = nSplitIndex + 1
  end
  return nSplitArray
end
def.method(ECObject, "string", "=>", "boolean").AniEvent_Common = function(self, owner, param)
  if owner == nil then
    return false
  end
  local ECGame = require("Main.ECGame")
  local hp = ECGame.Instance().m_HostPlayer
  if not hp then
    return false
  end
  if hp.ID ~= owner.ID then
    return false
  end
  local ECAniEventQTE = require("AniEvent.ECAniEventQTE")
  local infos = self:Split(param, "_")
  assert(#infos > 1)
  if string.find(string.lower(infos[2]), "qte") == 1 then
    ECAniEventQTE.Instance():AniEvent_QTE(infos[4])
  end
  return true
end
def.method(ECObject, "number", "=>", "boolean").AniEvent_Common_Int = function(self, owner, param)
  local ECAniEventQTE = require("AniEvent.ECAniEventQTE")
  local ECAniEventShake = require("AniEvent.ECAniEventShake")
  local ECAniEventSkill = require("AniEvent.ECAniEventSkill")
  local event_param = param
  local event_type = GetAniEventType(event_param)
  local event_param1 = GetAniEventParam1(event_param)
  local event_param2 = GetAniEventParam2(event_param)
  if event_type == ANI_EVENT_TYPE.AET_QTE then
    return ECAniEventQTE.Instance():OnAniEvent(event_param1, event_param2)
  elseif event_type == ANI_EVENT_TYPE.AET_SKILL or event_type == ANI_EVENT_TYPE.AET_COMMON then
  elseif event_type == ANI_EVENT_TYPE.AET_SHAKE then
    return ECAniEventShake.Instance():OnAniEvent(event_param1, event_param2)
  end
  return true
end
ECAniEventMgr.Commit()
return ECAniEventMgr
