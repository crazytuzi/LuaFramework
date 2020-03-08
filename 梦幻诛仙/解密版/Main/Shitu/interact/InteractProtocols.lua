local Lplus = require("Lplus")
local InteractUtils = require("Main.Shitu.interact.InteractUtils")
local InteractData = require("Main.Shitu.interact.data.InteractData")
local ChatModule = Lplus.ForwardDeclare("ChatModule")
local InteractProtocols = Lplus.Class("InteractProtocols")
local def = InteractProtocols.define
def.static().RegisterProtocols = function()
  gmodule.network.registerProtocol("netio.protocol.mzm.gsp.shitu.SSyncShiTuInfo", InteractProtocols.OnSSyncShiTuInfo)
  gmodule.network.registerProtocol("netio.protocol.mzm.gsp.shitu.SSynShiTuRoleInfoAndModelInfoChange", InteractProtocols.OnSSynShiTuRoleInfo)
  gmodule.network.registerProtocol("netio.protocol.mzm.gsp.shitu.SAgreeOrRefuseShouTu", InteractProtocols.OnSAgreeOrRefuseShouTu)
  gmodule.network.registerProtocol("netio.protocol.mzm.gsp.shitu.SRelieveShiTuRelation", InteractProtocols.OnSRelieveShiTuRelation)
  gmodule.network.registerProtocol("netio.protocol.mzm.gsp.shitu.SChuShiSuccess", InteractProtocols.OnSChuShiSuccess)
  gmodule.network.registerProtocol("netio.protocol.mzm.gsp.shitu.SSynAllShiTuTaskInfos", InteractProtocols.OnSSynAllShiTuTaskInfos)
  gmodule.network.registerProtocol("netio.protocol.mzm.gsp.shitu.SSynShiTuTaskInfo", InteractProtocols.OnSSynShiTuTaskInfo)
  gmodule.network.registerProtocol("netio.protocol.mzm.gsp.shitu.SSynShiTuTaskStatus", InteractProtocols.OnSSynShiTuTaskStatus)
  gmodule.network.registerProtocol("netio.protocol.mzm.gsp.shitu.SGetShiTuTaskInfoRep", InteractProtocols.OnSGetShiTuTaskInfoRep)
  gmodule.network.registerProtocol("netio.protocol.mzm.gsp.shitu.SRefreshShiTuTaskRep", InteractProtocols.OnSRefreshShiTuTaskRep)
  gmodule.network.registerProtocol("netio.protocol.mzm.gsp.shitu.SPublishShiTuTaskRep", InteractProtocols.OnSPublishShiTuTaskRep)
  gmodule.network.registerProtocol("netio.protocol.mzm.gsp.shitu.SReceiveShiTuTaskRep", InteractProtocols.OnSReceiveShiTuTaskRep)
  gmodule.network.registerProtocol("netio.protocol.mzm.gsp.shitu.SReceiveMasterTaskRewardRep", InteractProtocols.OnSReceiveMasterTaskRewardRep)
  gmodule.network.registerProtocol("netio.protocol.mzm.gsp.shitu.SynAllShiTuActiveInfos", InteractProtocols.OnSynAllShiTuActiveInfos)
  gmodule.network.registerProtocol("netio.protocol.mzm.gsp.shitu.SynShiTuActiveUpdate", InteractProtocols.OnSynShiTuActiveUpdate)
  gmodule.network.registerProtocol("netio.protocol.mzm.gsp.shitu.SynShiTuActiveInfo", InteractProtocols.OnSynShiTuActiveInfo)
  gmodule.network.registerProtocol("netio.protocol.mzm.gsp.shitu.SGetShiTuActiveInfoRep", InteractProtocols.OnSGetShiTuActiveInfoRep)
  gmodule.network.registerProtocol("netio.protocol.mzm.gsp.shitu.SReceiveShiTuActiveRewardRep", InteractProtocols.OnSReceiveShiTuActiveRewardRep)
  gmodule.network.registerProtocol("netio.protocol.mzm.gsp.shitu.SClearShiTuActiveRewardInfo", InteractProtocols.OnSClearShiTuActiveRewardInfo)
  gmodule.network.registerProtocol("netio.protocol.mzm.gsp.shitu.SynMasterRecommendInfos", InteractProtocols.OnSynMasterRecommendInfos)
  gmodule.network.registerProtocol("netio.protocol.mzm.gsp.shitu.SAgreeOrRefuseMasterRecommendRep", InteractProtocols.OnSAgreeOrRefuseMasterRecommendRep)
  gmodule.network.registerProtocol("netio.protocol.mzm.gsp.shitu.SynApprenticeRecommendInfo", InteractProtocols.OnSynApprenticeRecommendInfo)
end
def.static("table").OnSSyncShiTuInfo = function(p)
  warn("[InteractProtocols:OnSSyncShiTuInfo] On SSyncShiTuInfo! sync all shitu role info.")
  InteractData.Instance():SetMasterRoleInfo(p.masterInfo)
  if p.nowApprenticeList and #p.nowApprenticeList > 0 then
    for _, prenticeInfo in ipairs(p.nowApprenticeList) do
      InteractData.Instance():SetPrenticeRoleInfo(prenticeInfo.roleId, prenticeInfo)
    end
  end
end
def.static("table").OnSSynShiTuRoleInfo = function(p)
  warn("[InteractProtocols:OnSSynShiTuRoleInfo] On SSynShiTuRoleInfoAndModelInfoChange! update single role info.")
  InteractData.Instance():SetPrenticeRoleInfo(p.changeInfo.roleId, p.changeInfo)
  Event.DispatchEvent(ModuleId.SHITU, gmodule.notifyId.Shitu.SHITU_ROLE_INFO_CHANGE, {
    roleId = p.changeInfo.roleId
  })
end
def.static("table").OnSAgreeOrRefuseShouTu = function(p)
  warn("[InteractProtocols:OnSAgreeOrRefuseShouTu] On SAgreeOrRefuseShouTu!")
  local ShiTuConst = require("netio.protocol.mzm.gsp.shitu.ShiTuConst")
  if p.operator == ShiTuConst.AGREE_SHOUTU then
    InteractProtocols.DoAddShituRelation(p)
  end
end
def.static("table").DoAddShituRelation = function(p)
  warn("[InteractProtocols:DoAddShituRelation] Add Shitu Relation:", Int64.tostring(p.masterRoleInfo.roleId), Int64.tostring(p.apprenticeRoleInfo.roleId))
  local selfRoleId = _G.GetHeroProp().id
  if Int64.eq(selfRoleId, p.masterRoleInfo.roleId) then
    InteractData.Instance():SetPrenticeRoleInfo(p.apprenticeRoleInfo.roleId, p.apprenticeRoleInfo)
  else
    InteractData.Instance():SetMasterRoleInfo(p.masterRoleInfo)
  end
  Event.DispatchEvent(ModuleId.SHITU, gmodule.notifyId.Shitu.SHITU_RELATION_ADD_REMOVE, nil)
  Event.DispatchEvent(ModuleId.SHITU, gmodule.notifyId.Shitu.MASTER_TASK_INFO_CHANGE, nil)
end
def.static("table").OnSRelieveShiTuRelation = function(p)
  warn("[InteractProtocols:OnSRelieveShiTuRelation] On SRelieveShiTuRelation!")
  InteractProtocols.DoRemoveShituRelation(p.apprenticeRoleId)
end
def.static("table").OnSChuShiSuccess = function(p)
  warn("[InteractProtocols:OnSChuShiSuccess] On SChuShiSuccess!")
  InteractProtocols.DoRemoveShituRelation(p.apprenticeRoleId)
end
def.static("userdata").DoRemoveShituRelation = function(apprenticeRoleId)
  warn("[InteractProtocols:DoRemoveShituRelation] Remove Shitu Relation.")
  local selfRoleId = _G.GetHeroProp().id
  if Int64.eq(selfRoleId, apprenticeRoleId) then
    InteractData.Instance():SetMasterRoleInfo(nil)
  else
    InteractData.Instance():SetPrenticeRoleInfo(apprenticeRoleId, nil)
  end
  InteractData.Instance():SetActiveAwardInfo(apprenticeRoleId, nil)
  InteractData.Instance():SetMasterTaskInfo(apprenticeRoleId, nil)
  Event.DispatchEvent(ModuleId.SHITU, gmodule.notifyId.Shitu.SHITU_RELATION_ADD_REMOVE, nil)
  Event.DispatchEvent(ModuleId.SHITU, gmodule.notifyId.Shitu.MASTER_TASK_INFO_CHANGE, nil)
end
def.static("table").OnSSynAllShiTuTaskInfos = function(p)
  warn("[InteractProtocols:OnSSynAllShiTuTaskInfos] On SSynAllShiTuTaskInfos!")
  if p.all_shitu_task_infos and #p.all_shitu_task_infos > 0 then
    for _, masterTaskInfo in pairs(p.all_shitu_task_infos) do
      InteractData.Instance():SetMasterTaskInfo(masterTaskInfo.role_id, masterTaskInfo)
    end
    Event.DispatchEvent(ModuleId.SHITU, gmodule.notifyId.Shitu.MASTER_TASK_INFO_CHANGE, nil)
  end
end
def.static("table").OnSSynShiTuTaskInfo = function(p)
  warn("[InteractProtocols:OnSSynShiTuTaskInfo] On SSynShiTuTaskInfo!")
  local oldTaskData
  if Int64.eq(p.shitu_task_info.role_id, _G.GetMyRoleID()) then
    oldTaskData = InteractData.Instance():GetMasterTaskInfo(_G.GetMyRoleID())
  end
  local masterTaskData = InteractData.Instance():SetMasterTaskInfo(p.shitu_task_info.role_id, p.shitu_task_info)
  Event.DispatchEvent(ModuleId.SHITU, gmodule.notifyId.Shitu.MASTER_TASK_INFO_CHANGE, nil)
end
def.static("table").OnSSynShiTuTaskStatus = function(p)
  warn("[InteractProtocols:OnSSynShiTuTaskStatus] On SSynShiTuTaskStatus!")
  local bNeedShowTask = false
  local oldTaskData
  if Int64.eq(p.role_id, _G.GetMyRoleID()) then
    oldTaskData = InteractData.Instance():GetMasterTaskInfo(_G.GetMyRoleID())
    if oldTaskData then
      local ShiTuTask = require("netio.protocol.mzm.gsp.shitu.ShiTuTask")
      local oldTaskInfo = oldTaskData:GetTaskInfo(p.graph_id, p.task_id)
      if oldTaskInfo and oldTaskInfo.taskState ~= ShiTuTask.FINISHED and p.task_state == ShiTuTask.FINISHED then
        bNeedShowTask = true
      end
    end
  end
  InteractData.Instance():OnSSynTaskStatus(p)
  Event.DispatchEvent(ModuleId.SHITU, gmodule.notifyId.Shitu.MASTER_TASK_INFO_CHANGE, {
    roleId = p.role_id
  })
  if bNeedShowTask and oldTaskData and oldTaskData:HaveUnFinishedTask() then
    local InteractTaskPanel = require("Main.Shitu.interact.ui.InteractTaskPanel")
    InteractTaskPanel.Instance():ShowPanel(InteractTaskPanel.NodeId.Prentice)
  end
end
def.static().SendCGetShiTuTaskInfoReq = function()
  warn("[InteractProtocols:SendCGetShiTuTaskInfoReq] Send CGetShiTuTaskInfoReq!")
  local p = require("netio.protocol.mzm.gsp.shitu.CGetShiTuTaskInfoReq").new()
  gmodule.network.sendProtocol(p)
end
def.static("table").OnSGetShiTuTaskInfoRep = function(p)
  warn("[InteractProtocols:OnSGetShiTuTaskInfoRep] On SGetShiTuTaskInfoRep! p.result:", p.result)
  local SGetShiTuTaskInfoRep = require("netio.protocol.mzm.gsp.shitu.SGetShiTuTaskInfoRep")
  local errString
  if SGetShiTuTaskInfoRep.RESULT_SUCCESS == p.result then
  elseif SGetShiTuTaskInfoRep.RESULT_ERROR_TASK_INIT == p.result then
  elseif SGetShiTuTaskInfoRep.RESULT_ERROR_ROLE_INFO == p.result then
  else
    warn("[ERROR][InteractProtocols:OnSGetShiTuTaskInfoRep] unhandled p.result:", p.result)
  end
  if errString then
    Toast(errString)
  end
end
def.static("userdata").SendCRefreshShiTuTaskReq = function(roleId)
  warn("[InteractProtocols:SendCRefreshShiTuTaskReq] Send CRefreshShiTuTaskReq!")
  local p = require("netio.protocol.mzm.gsp.shitu.CRefreshShiTuTaskReq").new(roleId)
  gmodule.network.sendProtocol(p)
end
def.static("table").OnSRefreshShiTuTaskRep = function(p)
  warn("[InteractProtocols:OnSRefreshShiTuTaskRep] On SRefreshShiTuTaskRep! p.result:", p.result)
  local SRefreshShiTuTaskRep = require("netio.protocol.mzm.gsp.shitu.SRefreshShiTuTaskRep")
  local errString
  if SRefreshShiTuTaskRep.RESULT_SUCCESS == p.result then
    errString = textRes.Shitu.Interact.TASK_REFRESH_SUCCESS
  elseif SRefreshShiTuTaskRep.RESULT_ERROR_NOT_MASTER == p.result then
    errString = textRes.Shitu.Interact.TASK_REFRESH_FAIL_NOT_MASTER
  elseif SRefreshShiTuTaskRep.RESULT_ERROR_NO_TIMES == p.result then
    errString = textRes.Shitu.Interact.TASK_REFRESH_FAIL_NO_COUNT
  elseif SRefreshShiTuTaskRep.RESULT_ERROR_ROLE_INFO == p.result then
    errString = textRes.Shitu.Interact.TASK_REFRESH_FAIL_DATA_ERR
  elseif SRefreshShiTuTaskRep.RESULT_ERROR_APPRENTICE_TASK_INIT == p.result then
    errString = textRes.Shitu.Interact.TASK_REFRESH_FAIL_NOT_INIT
  elseif SRefreshShiTuTaskRep.RESULT_ERROR_REFRESH_FAIL == p.result then
    errString = textRes.Shitu.Interact.TASK_REFRESH_FAIL_FAIL
  elseif SRefreshShiTuTaskRep.RESULT_ERROR_APPRENTICE_STATE == p.result then
    errString = textRes.Shitu.Interact.TASK_REFRESH_FAIL_WRONG_STATE
  else
    warn("[ERROR][InteractProtocols:OnSRefreshShiTuTaskRep] unhandled p.result:", p.result)
  end
  if errString then
    Toast(errString)
  end
end
def.static("userdata").SendCPublishShiTuTaskReq = function(roleId)
  warn("[InteractProtocols:SendCPublishShiTuTaskReq] Send CPublishShiTuTaskReq!")
  local p = require("netio.protocol.mzm.gsp.shitu.CPublishShiTuTaskReq").new(roleId)
  gmodule.network.sendProtocol(p)
end
def.static("table").OnSPublishShiTuTaskRep = function(p)
  warn("[InteractProtocols:OnSPublishShiTuTaskRep] On SPublishShiTuTaskRep! p.result:", p.result)
  local SPublishShiTuTaskRep = require("netio.protocol.mzm.gsp.shitu.SPublishShiTuTaskRep")
  local errString
  if SPublishShiTuTaskRep.RESULT_SUCCESS == p.result then
    errString = textRes.Shitu.Interact.TASK_ASSIGN_SUCCESS
    local roleInfo = InteractData.Instance():GetPrenticeRoleInfo(p.role_id)
    InteractProtocols.SendPrivateMsg(roleInfo, textRes.Shitu.Interact.TASK_ASSIGN_DONE)
  elseif SPublishShiTuTaskRep.RESULT_ERROR_NOT_MASTER == p.result then
    errString = textRes.Shitu.Interact.TASK_ASSIGN_FAIL_NOT_MASTER
  elseif SPublishShiTuTaskRep.RESULT_ERROR_ROLE_INFO == p.result then
    errString = textRes.Shitu.Interact.TASK_ASSIGN_FAIL_DATA_ERR
  elseif SPublishShiTuTaskRep.RESULT_ERROR_APPRENTICE_TASK_INIT == p.result then
    errString = textRes.Shitu.Interact.TASK_ASSIGN_FAIL_NOT_INIT
  elseif SPublishShiTuTaskRep.RESULT_ERROR_APPRENTICE_STATE == p.result then
    errString = textRes.Shitu.Interact.TASK_ASSIGN_FAIL_WRONG_STATE
  else
    warn("[ERROR][InteractProtocols:OnSPublishShiTuTaskRep] unhandled p.result:", p.result)
  end
  if errString then
    Toast(errString)
  end
end
def.static("number", "number").SendCReceiveShiTuTaskReq = function(graphId, taskId)
  warn("[InteractProtocols:SendCReceiveShiTuTaskReq] Send CReceiveShiTuTaskReq!")
  local p = require("netio.protocol.mzm.gsp.shitu.CReceiveShiTuTaskReq").new(graphId, taskId)
  gmodule.network.sendProtocol(p)
end
def.static("table").OnSReceiveShiTuTaskRep = function(p)
  warn("[InteractProtocols:OnSReceiveShiTuTaskRep] On SReceiveShiTuTaskRep! p.result:", p.result)
  local SReceiveShiTuTaskRep = require("netio.protocol.mzm.gsp.shitu.SReceiveShiTuTaskRep")
  local errString
  if SReceiveShiTuTaskRep.RESULT_SUCCESS == p.result then
    errString = textRes.Shitu.Interact.TASK_FETCH_SUCCESS
    local InteractTaskPanel = require("Main.Shitu.interact.ui.InteractTaskPanel")
    if InteractTaskPanel.Instance():IsShow() then
      InteractTaskPanel.Instance():DestroyPanel()
    end
    local SocialDlg = require("Main.friend.ui.SocialDlg")
    if SocialDlg.Instance():IsShow() then
      SocialDlg.Instance():DestroyPanel()
    end
  elseif SReceiveShiTuTaskRep.RESULT_ERROR_TASK_INFO == p.result then
    errString = textRes.Shitu.Interact.TASK_FETCH_FAIL_WRONG_INFO
  elseif SReceiveShiTuTaskRep.RESULT_ERROR_IN_TEAM == p.result then
    errString = textRes.Shitu.Interact.TASK_FETCH_FAIL_IN_TEAM
  elseif SReceiveShiTuTaskRep.RESULT_ERROR_TIMES_MAX == p.result then
    errString = textRes.Shitu.Interact.TASK_FETCH_FAIL_REACH_LIMIT
  elseif SReceiveShiTuTaskRep.RESULT_ERROR_ROLE_INFO == p.result then
    errString = textRes.Shitu.Interact.TASK_FETCH_FAIL_DATA_ERR
  elseif SReceiveShiTuTaskRep.RESULT_ERROR_TASK_INIT == p.result then
    errString = textRes.Shitu.Interact.TASK_FETCH_FAIL_NOT_INIT
  elseif SReceiveShiTuTaskRep.RESULT_ERROR_STATE == p.result then
    errString = textRes.Shitu.Interact.TASK_FETCH_FAIL_WRONG_STATE
  elseif SReceiveShiTuTaskRep.RESULT_ERROR_LEVEL_MAX == p.result then
    errString = textRes.Shitu.Interact.TASK_FETCH_FAIL_MAX_LEVEL
  else
    warn("[ERROR][InteractProtocols:OnSReceiveShiTuTaskRep] unhandled p.result:", p.result)
  end
  if errString then
    Toast(errString)
  end
end
def.static("userdata", "number", "number").SendCReceiveMasterTaskRewardReq = function(roleId, graphId, taskId)
  warn("[InteractProtocols:SendCReceiveMasterTaskRewardReq] Send CReceiveMasterTaskRewardReq!")
  local p = require("netio.protocol.mzm.gsp.shitu.CReceiveMasterTaskRewardReq").new(roleId, graphId, taskId)
  gmodule.network.sendProtocol(p)
end
def.static("table").OnSReceiveMasterTaskRewardRep = function(p)
  warn("[InteractProtocols:OnSReceiveMasterTaskRewardRep] On SReceiveMasterTaskRewardRep! p.result:", p.result)
  local SReceiveMasterTaskRewardRep = require("netio.protocol.mzm.gsp.shitu.SReceiveMasterTaskRewardRep")
  local errString
  if SReceiveMasterTaskRewardRep.RESULT_SUCCESS == p.result then
    errString = textRes.Shitu.Interact.GET_MASTER_TASK_AWARD_SUCCESS
  elseif SReceiveMasterTaskRewardRep.RESULT_ERROR_TASK_INFO == p.result then
    errString = textRes.Shitu.Interact.GET_MASTER_TASK_AWARD_FAIL_WRONG_INFO
  elseif SReceiveMasterTaskRewardRep.RESULT_ERROR_NOT_MASTER == p.result then
    errString = textRes.Shitu.Interact.GET_MASTER_TASK_AWARD_FAIL_NOT_MASTER
  elseif SReceiveMasterTaskRewardRep.RESULT_ERROR_ROLE_INFO == p.result then
    errString = textRes.Shitu.Interact.GET_MASTER_TASK_AWARD_FAIL_DATA_ERR
  elseif SReceiveMasterTaskRewardRep.RESULT_ERROR_APPRENTICE_TASK_INIT == p.result then
    errString = textRes.Shitu.Interact.GET_MASTER_TASK_AWARD_FAIL_NOT_INIT
  elseif SReceiveMasterTaskRewardRep.RESULT_ERROR_APPRENTICE_STATE == p.result then
    errString = textRes.Shitu.Interact.GET_MASTER_TASK_AWARD_FAIL_WRONG_STATE
  elseif SReceiveMasterTaskRewardRep.RESULT_ERROR_BAG_FULL == p.result then
    errString = textRes.Shitu.Interact.GET_MASTER_TASK_AWARD_FAIL_BAG_FULL
  else
    warn("[ERROR][InteractProtocols:OnSReceiveMasterTaskRewardRep] unhandled p.result:", p.result)
  end
  if errString then
    Toast(errString)
  end
end
def.static("table").OnSynAllShiTuActiveInfos = function(p)
  warn("[InteractProtocols:OnSynAllShiTuActiveInfos] On SynAllShiTuActiveInfos!")
  if p.all_shitu_active_infos and #p.all_shitu_active_infos > 0 then
    for _, activeAwardInfo in pairs(p.all_shitu_active_infos) do
      InteractData.Instance():SetActiveAwardInfo(activeAwardInfo.role_id, activeAwardInfo)
    end
    Event.DispatchEvent(ModuleId.SHITU, gmodule.notifyId.Shitu.SHITU_ACTIVE_INFO_CHANGE, nil)
  end
end
def.static("table").OnSynShiTuActiveInfo = function(p)
  warn("[InteractProtocols:OnSynShiTuActiveInfo] On SynShiTuActiveInfo!")
  InteractData.Instance():SetActiveAwardInfo(p.shitu_active_info.role_id, p.shitu_active_info)
  Event.DispatchEvent(ModuleId.SHITU, gmodule.notifyId.Shitu.SHITU_ACTIVE_INFO_CHANGE, nil)
end
def.static("table").OnSynShiTuActiveUpdate = function(p)
  warn("[InteractProtocols:OnSynShiTuActiveUpdate] On SynShiTuActiveUpdate!")
  InteractData.Instance():SynShiTuActiveUpdate(p.role_id, p.active_value)
  Event.DispatchEvent(ModuleId.SHITU, gmodule.notifyId.Shitu.SHITU_ACTIVE_INFO_CHANGE, nil)
end
def.static().SendCGetShiTuActiveInfoReq = function()
  warn("[InteractProtocols:SendCGetShiTuActiveInfoReq] Send CGetShiTuActiveInfoReq!")
  local p = require("netio.protocol.mzm.gsp.shitu.CGetShiTuActiveInfoReq").new()
  gmodule.network.sendProtocol(p)
end
def.static("table").OnSGetShiTuActiveInfoRep = function(p)
  warn("[InteractProtocols:OnSGetShiTuActiveInfoRep] On SGetShiTuActiveInfoRep! p.result:", p.result)
  local SGetShiTuActiveInfoRep = require("netio.protocol.mzm.gsp.shitu.SGetShiTuActiveInfoRep")
  local errString
  if SGetShiTuActiveInfoRep.RESULT_SUCCESS == p.result then
  elseif SGetShiTuActiveInfoRep.RESULT_ERROR_NO_SHITU == p.result then
  elseif SGetShiTuActiveInfoRep.RESULT_ERROR_ROLE_INFO == p.result then
  else
    warn("[ERROR][InteractProtocols:OnSGetShiTuActiveInfoRep] unhandled p.result:", p.result)
  end
  if errString then
    Toast(errString)
  end
end
def.static("table").OnSClearShiTuActiveRewardInfo = function(p)
  warn("[InteractProtocols:OnSClearShiTuActiveRewardInfo] On SClearShiTuActiveRewardInfo!")
  local infoMap = InteractData.Instance():GetAllActiveAwardInfo()
  if infoMap then
    for _, activeAwardInfo in pairs(infoMap) do
      activeAwardInfo:UpdateFetchedInfo(nil)
    end
    Event.DispatchEvent(ModuleId.SHITU, gmodule.notifyId.Shitu.SHITU_ACTIVE_INFO_CHANGE, nil)
  end
end
def.static("userdata", "number").SendCReceiveShiTuActiveRewardReq = function(roleId, awardIdx)
  warn("[InteractProtocols:SendCReceiveShiTuActiveRewardReq] Send CReceiveShiTuActiveRewardReq!")
  local p = require("netio.protocol.mzm.gsp.shitu.CReceiveShiTuActiveRewardReq").new(roleId, awardIdx)
  gmodule.network.sendProtocol(p)
end
def.static("table").OnSReceiveShiTuActiveRewardRep = function(p)
  warn("[InteractProtocols:OnSReceiveShiTuActiveRewardRep] On SReceiveShiTuActiveRewardRep! p.result:", p.result)
  local SReceiveShiTuActiveRewardRep = require("netio.protocol.mzm.gsp.shitu.SReceiveShiTuActiveRewardRep")
  local errString
  if SReceiveShiTuActiveRewardRep.RESULT_SUCCESS == p.result then
    errString = textRes.Shitu.Interact.GET_MASTER_TASK_AWARD_SUCCESS
  elseif SReceiveShiTuActiveRewardRep.RESULT_ERROR_BAG_FULL == p.result then
    errString = textRes.Shitu.Interact.GET_ACTIVE_AWARD_FAIL_BAG_FULL
  elseif SReceiveShiTuActiveRewardRep.RESULT_ERROR_INDEX_ALEARDY_AWARD == p.result then
    errString = textRes.Shitu.Interact.GET_ACTIVE_AWARD_FAIL_FETCHED
  elseif SReceiveShiTuActiveRewardRep.RESULT_ERROR_VALUE_NOT_ENOUGH == p.result then
    errString = textRes.Shitu.Interact.GET_ACTIVE_AWARD_FAIL_LACK_ACTIVE
  elseif SReceiveShiTuActiveRewardRep.RESULT_ERROR_AWARD_FAILED == p.result then
    errString = textRes.Shitu.Interact.GET_ACTIVE_AWARD_FAIL_SEND_FAIL
  elseif SReceiveShiTuActiveRewardRep.RESULT_ERROR_LEVEL_NOT_FOUND == p.result then
    errString = textRes.Shitu.Interact.GET_ACTIVE_AWARD_FAIL_NO_LEVEL_CFG
  elseif SReceiveShiTuActiveRewardRep.RESULT_ERROR_INDEX_NOT_EXIST == p.result then
    errString = textRes.Shitu.Interact.GET_ACTIVE_AWARD_FAIL_NO_IDX
  elseif SReceiveShiTuActiveRewardRep.RESULT_ERROR_NOT_MASTER == p.result then
    errString = textRes.Shitu.Interact.GET_ACTIVE_AWARD_FAIL_NOT_MASTER
  elseif SReceiveShiTuActiveRewardRep.RESULT_ERROR_ROLE_INFO == p.result then
    errString = textRes.Shitu.Interact.GET_ACTIVE_AWARD_FAIL_ROLE_INFO_ERR
  elseif SReceiveShiTuActiveRewardRep.RESULT_ERROR_NO_MASTER == p.result then
    errString = textRes.Shitu.Interact.GET_ACTIVE_AWARD_FAIL_NOT_SHITU
  elseif SReceiveShiTuActiveRewardRep.RESULT_ERROR_RELATION_START_DAY == p.result then
    errString = textRes.Shitu.Interact.GET_ACTIVE_AWARD_FAIL_WRONG_DAY
  else
    warn("[ERROR][InteractProtocols:OnSReceiveShiTuActiveRewardRep] unhandled p.result:", p.result)
  end
  if errString then
    Toast(errString)
  end
end
def.static("table").OnSynMasterRecommendInfos = function(p)
  warn("[InteractProtocols:OnSynMasterRecommendInfos] On SynMasterRecommendInfos!")
  local InteractMgr = require("Main.Shitu.interact.InteractMgr")
  if InteractMgr.Instance():IsFeatrueRecommandOpen(false) then
    local RecommandMasterPanel = require("Main.Shitu.interact.ui.RecommandMasterPanel")
    RecommandMasterPanel.ShowPanel(p.sessionid, p.all_master_recommend_infos)
  else
    warn("[ERROR][InteractProtocols:OnSynMasterRecommendInfos] IDIP not open.")
  end
end
def.static("number", "userdata").SendCAgreeOrRefuseMasterRecommendReq = function(operator, sessionid)
  warn("[InteractProtocols:SendCAgreeOrRefuseMasterRecommendReq] Send CAgreeOrRefuseMasterRecommendReq!")
  local p = require("netio.protocol.mzm.gsp.shitu.CAgreeOrRefuseMasterRecommendReq").new(operator, sessionid)
  gmodule.network.sendProtocol(p)
end
def.static("table").OnSAgreeOrRefuseMasterRecommendRep = function(p)
  warn("[InteractProtocols:OnSAgreeOrRefuseMasterRecommendRep] On SAgreeOrRefuseMasterRecommendRep! p.result:", p.result)
  local SAgreeOrRefuseMasterRecommendRep = require("netio.protocol.mzm.gsp.shitu.SAgreeOrRefuseMasterRecommendRep")
  local errString
  if SAgreeOrRefuseMasterRecommendRep.RESULT_SUCCESS == p.result then
    local ShiTuConst = require("netio.protocol.mzm.gsp.shitu.ShiTuConst")
    if p.operator == ShiTuConst.AGREE_RECOMMEND then
      errString = textRes.Shitu.Interact.RECOMMAND_MASTER_SUCCESS
    end
  elseif SAgreeOrRefuseMasterRecommendRep.RESULT_ERROR_TIME_OUT == p.result then
    errString = textRes.Shitu.Interact.RECOMMAND_MASTER_FAIL_TIME_OUT
  elseif SAgreeOrRefuseMasterRecommendRep.RESULT_ERROR_HAS_MASTER == p.result then
    errString = textRes.Shitu.Interact.RECOMMAND_MASTER_FAIL_HAS_MASTER
  else
    warn("[ERROR][InteractProtocols:OnSAgreeOrRefuseMasterRecommendRep] unhandled p.result:", p.result)
  end
  if errString then
    Toast(errString)
  end
end
def.static("table").OnSynApprenticeRecommendInfo = function(p)
  warn("[InteractProtocols:OnSynApprenticeRecommendInfo] On SynApprenticeRecommendInfo!")
  local roleInfo = p.apprentice_recommend_info
  local confirmContent = string.format(textRes.Shitu.Interact.PRENTICE_REQ_CONFIRM_CONTENT, roleInfo.roleLevel, roleInfo.roleName)
  require("GUI.CommonConfirmDlg").ShowConfirmCoundDown(textRes.Shitu.Interact.PRENTICE_REQ_CONFIRM_TITLE, confirmContent, textRes.Shitu.Interact.PRENTICE_REQ_CONFIRM_YES, textRes.Shitu.Interact.PRENTICE_REQ_CONFIRM_NO, 0, constant.CMasterRecommendConsts.RECOMMEND_APPRENTICE_COUNTDOWN_TIME, function(id, tag)
    if id == 1 then
      InteractProtocols.SendPrivateMsg(roleInfo, textRes.Shitu.Interact.PRENTICE_REQ_REP)
    end
  end, nil)
end
def.static("table", "string").SendPrivateMsg = function(roleInfo, content)
  if roleInfo then
    ChatModule.Instance():SetChatRoleCache2(roleInfo.roleId, roleInfo.roleName, roleInfo.roleLevel, roleInfo.occupationId, roleInfo.gender, roleInfo.avatarId, roleInfo.avatarFrameId)
    ChatModule.Instance():SendPrivateMsg(roleInfo.roleId, content, false)
  else
    warn("[ERROR][InteractProtocols:SendPrivateMsg] send failed! roleInfo nil.")
  end
end
InteractProtocols.Commit()
return InteractProtocols
