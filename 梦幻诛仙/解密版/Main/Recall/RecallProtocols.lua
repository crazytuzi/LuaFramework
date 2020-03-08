local Lplus = require("Lplus")
local RecallData = require("Main.Recall.data.RecallData")
local RecallProtocols = Lplus.Class("RecallProtocols")
local def = RecallProtocols.define
def.static().RegisterProtocols = function()
  gmodule.network.registerProtocol("netio.protocol.mzm.gsp.grc.SyncRecallLossInfo", RecallProtocols.OnSyncRecallLossInfo)
  gmodule.network.registerProtocol("netio.protocol.mzm.gsp.grc.SRecallFriendSuccess", RecallProtocols.OnSRecallFriendSuccess)
  gmodule.network.registerProtocol("netio.protocol.mzm.gsp.grc.SRecallFriendFailed", RecallProtocols.OnSRecallFriendFailed)
  gmodule.network.registerProtocol("netio.protocol.mzm.gsp.grc.SyncUserBackInfo", RecallProtocols.OnSyncUserBackInfo)
  gmodule.network.registerProtocol("netio.protocol.mzm.gsp.grc.SBindFriendSuccess", RecallProtocols.OnSBindFriendSuccess)
  gmodule.network.registerProtocol("netio.protocol.mzm.gsp.grc.SBindFriendFailed", RecallProtocols.OnSBindFriendFailed)
  gmodule.network.registerProtocol("netio.protocol.mzm.gsp.grc.SyncBindVitalityInfo", RecallProtocols.OnSyncBindVitalityInfo)
  gmodule.network.registerProtocol("netio.protocol.mzm.gsp.grc.AddBindVitalityInfo", RecallProtocols.OnAddBindVitalityInfo)
  gmodule.network.registerProtocol("netio.protocol.mzm.gsp.grc.SGetBindRewardSuccess", RecallProtocols.OnSGetBindRewardSuccess)
  gmodule.network.registerProtocol("netio.protocol.mzm.gsp.grc.SGetBindRewardFailed", RecallProtocols.OnSGetBindRewardFailed)
  gmodule.network.registerProtocol("netio.protocol.mzm.gsp.grc.SyncBackFriendBindInfo", RecallProtocols.OnSyncBackFriendBindInfo)
  gmodule.network.registerProtocol("netio.protocol.mzm.gsp.grc.SGetRecallRebateInfoSuccess", RecallProtocols.OnSGetRecallRebateInfoSuccess)
  gmodule.network.registerProtocol("netio.protocol.mzm.gsp.grc.SGetRecallRebateSuccess", RecallProtocols.OnSGetRecallRebateSuccess)
  gmodule.network.registerProtocol("netio.protocol.mzm.gsp.grc.SGetRecallRebateFailed", RecallProtocols.OnSGetRecallRebateFailed)
end
def.static("table").OnSyncRecallLossInfo = function(p)
  warn("[RecallProtocols:OnSyncRecallLossInfo] On SyncRecallLossInfo, #p.loss_infos:", p.loss_infos and #p.loss_infos)
  RecallData.Instance():OnSyncRecallLossInfo(p)
end
def.static("number", "userdata", "userdata").SendCRecallFriendReq = function(zoneId, roleId, openId)
  warn("[RecallProtocols:SendCRecallFriendReq] Send CRecallFriendReq:", zoneId, roleId and Int64.tostring(roleId), openId and _G.GetStringFromOcts(openId))
  local p = require("netio.protocol.mzm.gsp.grc.CRecallFriendReq").new(zoneId, roleId, openId)
  gmodule.network.sendProtocol(p)
end
def.static("table").OnSRecallFriendSuccess = function(p)
  warn("[RecallProtocols:OnSRecallFriendSuccess] On SRecallFriendSuccess!")
  RecallData.Instance():OnSRecallFriendSuccess(p)
end
def.static("table").OnSRecallFriendFailed = function(p)
  warn("[RecallProtocols:OnSRecallFriendFailed] On SRecallFriendFailed! p.retcode:", p.retcode)
  local SRecallFriendFailed = require("netio.protocol.mzm.gsp.grc.SRecallFriendFailed")
  if SRecallFriendFailed.ERROR_RECALL_LOGIN_TIME == p.retcode then
    RecallData.Instance():DeleteAfkFriendInfoByOpenId(p.open_id)
  elseif SRecallFriendFailed.ERROR_RECALL_NOT_FRIEND == p.retcode then
    RecallData.Instance():DeleteAfkFriendInfoByOpenId(p.open_id)
  end
  local errString = textRes.Recall.SRecallFriendFailed[p.retcode]
  if errString then
    Toast(errString)
  end
end
def.static("table").OnSyncUserBackInfo = function(p)
  warn("[RecallProtocols:OnSyncUserBackInfo] On SyncUserBackInfo, #p.recall_friends:", p.recall_friends and #p.recall_friends)
  RecallData.Instance():OnSyncUserBackInfo(p)
  if _G.IsEnteredWorld() and require("Main.Recall.RecallModule").Instance():IsBindActiveOpen(false) and RecallData.Instance():IsFirstReturnLogin() and RecallData.Instance():CanBindRecallFriend() then
    warn("[RecallProtocols:OnSyncUserBackInfo] show BindPanel after EnterWorld.")
    require("Main.Recall.ui.BindPanel").ShowPanel()
  end
end
def.static("userdata").SendCBindFriendReq = function(openId)
  warn("[RecallProtocols:SendCBindFriendReq] Send CBindFriendReq:", openId and _G.GetStringFromOcts(openId))
  local p = require("netio.protocol.mzm.gsp.grc.CBindFriendReq").new(openId)
  gmodule.network.sendProtocol(p)
end
def.static("table").OnSBindFriendSuccess = function(p)
  warn("[RecallProtocols:OnSBindFriendSuccess] On SBindFriendSuccess, p.open_id:", p.open_id and _G.GetStringFromOcts(p.open_id))
  local friendInfo = RecallData.Instance():GetRecallHeroFriendInfoByOpenId(p.open_id)
  if friendInfo then
    friendInfo:SetBinded(true)
    Event.DispatchEvent(ModuleId.RECALL, gmodule.notifyId.Recall.HERO_RETURN_INFO_CHANGE, nil)
    local toastStr = string.format(textRes.Recall.BIND_RECALL_FRIEND_SUCCESS, friendInfo:GetNickName())
    Toast(toastStr)
  else
    warn("[ERROR][RecallProtocols:OnSBindFriendSuccess] friendInfo nil for openId:", p.open_id and _G.GetStringFromOcts(p.open_id))
  end
end
def.static("table").OnSBindFriendFailed = function(p)
  warn("[RecallProtocols:OnSBindFriendFailed] On SBindFriendFailed! p.retcode:", p.retcode)
  local SBindFriendFailed = require("netio.protocol.mzm.gsp.grc.SBindFriendFailed")
  if SBindFriendFailed.ERROR_RECALL_NOT_LOSS == p.retcode then
    RecallData.Instance():ClearHeroReturnInfo()
  elseif SBindFriendFailed.ERROR_RECALL_BIND_EXPIRED == p.retcode or SBindFriendFailed.ERROR_RECALL_FRIEND_BIND_FULL == p.retcode or SBindFriendFailed.ERROR_RECALL_NOT_FRIEND == p.retcode or SBindFriendFailed.ERROR_RECALL_BIND_TOGETHER_FILLED == p.retcode then
    RecallData.Instance():DeleteRecallHeroFriendInfoByOpenId(p.open_id)
  end
  local errString = textRes.Recall.SBindFriendFailed[p.retcode]
  if errString then
    Toast(errString)
  end
end
def.static("table").OnSyncBindVitalityInfo = function(p)
  warn("[RecallProtocols:OnSyncBindVitalityInfo] On SyncBindVitalityInfo, #p.recall_bind_infos and #p.back_bind_infos:", p.recall_bind_infos and #p.recall_bind_infos, p.back_bind_infos and #p.back_bind_infos)
  RecallData.Instance():OnSyncBindVitalityInfo(p)
end
def.static("table").OnAddBindVitalityInfo = function(p)
  warn("[RecallProtocols:OnAddBindVitalityInfo] On AddBindVitalityInfo!")
  RecallData.Instance():OnAddBindVitalityInfo(p)
end
def.static().SendCGetBindVitalityInfoReq = function()
  warn("[RecallProtocols:SendCGetBindVitalityInfoReq] Send CGetBindVitalityInfoReq.")
  local p = require("netio.protocol.mzm.gsp.grc.CGetBindVitalityInfoReq").new()
  gmodule.network.sendProtocol(p)
end
def.static("userdata", "boolean").SendCGetBindRewardReq = function(openId, bCaller)
  warn("[RecallProtocols:SendCGetBindRewardReq] Send CGetBindRewardReq:", openId and _G.GetStringFromOcts(openId), bCaller)
  local p = require("netio.protocol.mzm.gsp.grc.CGetBindRewardReq").new(openId, bCaller and 1 or 0)
  gmodule.network.sendProtocol(p)
end
def.static("table").OnSGetBindRewardSuccess = function(p)
  warn("[RecallProtocols:OnSGetBindRewardSuccess] On SGetBindRewardSuccess!")
  RecallData.Instance():OnSGetBindRewardSuccess(p)
end
def.static("table").OnSGetBindRewardFailed = function(p)
  warn("[RecallProtocols:OnSGetBindRewardFailed] On SGetBindRewardFailed! p.retcode:", p.retcode)
  local SGetBindRewardFailed = require("netio.protocol.mzm.gsp.grc.SGetBindRewardFailed")
  if SGetBindRewardFailed.ERROR_RECALL_BIND_REWARD == p.retcode then
    local friendInfo = RecallData.Instance():GetFriendActiveInfoByOpenId(p.open_id)
    if friendInfo then
      friendInfo:SetAwardFetched(true)
    end
  end
  local errString = textRes.Recall.SGetBindRewardFailed[p.retcode]
  if errString then
    Toast(errString)
  end
end
def.static("table").OnSyncBackFriendBindInfo = function(p)
  warn("[RecallProtocols:OnSyncBackFriendBindInfo] On SyncBackFriendBindInfo, #p.back_friends:", p.back_friends and #p.back_friends)
  RecallData.Instance():OnSyncBackFriendBindInfo(p)
end
def.static("number").SendCGetRecallRebateReq = function(num)
  warn("[RecallProtocols:SendCGetRecallRebateReq] Send CGetRecallRebateReq:", num)
  local p = require("netio.protocol.mzm.gsp.grc.CGetRecallRebateReq").new(num)
  gmodule.network.sendProtocol(p)
end
def.static("table").OnSGetRecallRebateSuccess = function(p)
  warn("[RecallProtocols:OnSGetRecallRebateSuccess] On SGetRecallRebateSuccess!")
  RecallData.Instance():OnSGetRecallRebateSuccess(p)
  Toast(textRes.Recall.REBATE_FETCH_SUCCESS)
end
def.static("table").OnSGetRecallRebateFailed = function(p)
  warn("[RecallProtocols:OnSGetRecallRebateFailed] On SGetRecallRebateFailed! p.retcode:", p.retcode)
  local SGetRecallRebateFailed = require("netio.protocol.mzm.gsp.grc.SGetRecallRebateFailed")
  local errString = textRes.Recall.SGetRecallRebateFailed[p.retcode]
  if errString then
    Toast(errString)
  end
  RecallProtocols.SendCGetRecallRebateInfoReq()
end
def.static().SendCGetRecallRebateInfoReq = function()
  warn("[RecallProtocols:SendCGetRecallRebateInfoReq] Send CGetRecallRebateInfoReq.")
  local p = require("netio.protocol.mzm.gsp.grc.CGetRecallRebateInfoReq").new()
  gmodule.network.sendProtocol(p)
end
def.static("table").OnSGetRecallRebateInfoSuccess = function(p)
  warn("[RecallProtocols:OnSGetRecallRebateInfoSuccess] On SGetRecallRebateInfoSuccess!")
  RecallData.Instance():OnSGetRecallRebateInfoSuccess(p)
end
RecallProtocols.Commit()
return RecallProtocols
