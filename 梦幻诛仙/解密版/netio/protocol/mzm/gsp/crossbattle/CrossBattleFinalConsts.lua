local OctetsStream = require("netio.OctetsStream")
local GetFinalContext = require("netio.protocol.mzm.gsp.crossbattle.GetFinalContext")
local GetFinalContext_CreatePrepareWorld = require("netio.protocol.mzm.gsp.crossbattle.GetFinalContext_CreatePrepareWorld")
local GetFinalContext_CheckPanel = require("netio.protocol.mzm.gsp.crossbattle.GetFinalContext_CheckPanel")
local CrossBattleFinalConsts = class("CrossBattleFinalConsts")
function CrossBattleFinalConsts:ctor(_GetFinalContext, _GetFinalContext_CreatePrepareWorld, _GetFinalContext_CheckPanel)
  self._GetFinalContext = _GetFinalContext or GetFinalContext.new()
  self._GetFinalContext_CreatePrepareWorld = _GetFinalContext_CreatePrepareWorld or GetFinalContext_CreatePrepareWorld.new()
  self._GetFinalContext_CheckPanel = _GetFinalContext_CheckPanel or GetFinalContext_CheckPanel.new()
end
function CrossBattleFinalConsts:marshal(os)
  self._GetFinalContext:marshal(os)
  self._GetFinalContext_CreatePrepareWorld:marshal(os)
  self._GetFinalContext_CheckPanel:marshal(os)
end
function CrossBattleFinalConsts:unmarshal(os)
  self._GetFinalContext = GetFinalContext.new()
  self._GetFinalContext:unmarshal(os)
  self._GetFinalContext_CreatePrepareWorld = GetFinalContext_CreatePrepareWorld.new()
  self._GetFinalContext_CreatePrepareWorld:unmarshal(os)
  self._GetFinalContext_CheckPanel = GetFinalContext_CheckPanel.new()
  self._GetFinalContext_CheckPanel:unmarshal(os)
end
return CrossBattleFinalConsts
