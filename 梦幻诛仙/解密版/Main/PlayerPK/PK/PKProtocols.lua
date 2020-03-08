local MODULE_NAME = (...)
local Lplus = require("Lplus")
local PKProtocols = Lplus.Class(MODULE_NAME)
local def = PKProtocols.define
local instance
local PKMgr = Lplus.ForwardDeclare("PKMgr")
local CommonConfirmDlg = require("GUI.CommonConfirmDlg")
local txtConst = textRes.PlayerPK.PK
local const = constant.CPKConsts
def.static("=>", PKProtocols).Instance = function()
  if instance == nil then
    instance = PKProtocols()
  end
  return instance
end
def.method().Init = function(self)
  local Cls = PKProtocols
  gmodule.network.registerProtocol("netio.protocol.mzm.gsp.pk.SEnablePKSuccess", Cls.OnSEnablePKSuccess)
  gmodule.network.registerProtocol("netio.protocol.mzm.gsp.pk.SEnablePKFail", Cls.OnSEnablePKFailed)
  gmodule.network.registerProtocol("netio.protocol.mzm.gsp.pk.SNotifyPKStarted", Cls.OnSPKStart)
  gmodule.network.registerProtocol("netio.protocol.mzm.gsp.pk.SStartPKFail", Cls.OnSPKStartFailed)
  gmodule.network.registerProtocol("netio.protocol.mzm.gsp.pk.SBuyMoralValueFail", Cls.OnSBuyMeritFailed)
  gmodule.network.registerProtocol("netio.protocol.mzm.gsp.pk.SAcceptMoralValueTaskFail", Cls.OnSAcceptMeritTaskFailed)
  gmodule.network.registerProtocol("netio.protocol.mzm.gsp.pk.SRevengeItemAssignRoleFail", Cls.OnSBindTargetRoleFailed)
  gmodule.network.registerProtocol("netio.protocol.mzm.gsp.pk.SUseRevengeItemSuccess", Cls.OnSUseRevengeItemSuccess)
  gmodule.network.registerProtocol("netio.protocol.mzm.gsp.pk.SUseRevengeItemFail", Cls.OnSUseRevengeItemFailed)
  gmodule.network.registerProtocol("netio.protocol.mzm.gsp.pk.SUseRevengeItemTransferSuccess", Cls.OnSTransformSuccess)
  gmodule.network.registerProtocol("netio.protocol.mzm.gsp.pk.SUseRevengeItemTransferFail", Cls.OnSTransformFailed)
  gmodule.network.registerProtocol("netio.protocol.mzm.gsp.pk.SSyncPKStatus", Cls.OnSSyncPKStatus)
  gmodule.network.registerProtocol("netio.protocol.mzm.gsp.pk.SQueryRoleNameRes", Cls.OnQueryRoleNameRes)
  gmodule.network.registerProtocol("netio.protocol.mzm.gsp.pk.SNotifyPKPenalty", Cls.OnSNotifyPKPenalty)
  gmodule.network.registerProtocol("netio.protocol.mzm.gsp.pk.SQueryBoughtMoralValueRes", Cls.SQueryBoughtMoralVal)
end
def.static("userdata").SendCEnablePKReq = function(owndMoney)
  local p = require("netio.protocol.mzm.gsp.pk.CEnablePKReq").new(owndMoney)
  gmodule.network.sendProtocol(p)
end
def.static("userdata").SendCStartPKReq = function(roleId)
  local p = require("netio.protocol.mzm.gsp.pk.CStartPKReq").new(roleId)
  PKMgr.GetData():SetRoleId(roleId)
  gmodule.network.sendProtocol(p)
end
def.static("number", "userdata").SendBuyMeritReq = function(val, owndMoney)
  local p = require("netio.protocol.mzm.gsp.pk.CBuyMoralValueReq").new(val, owndMoney)
  gmodule.network.sendProtocol(p)
end
def.static().SendAcceptMeritTaskReq = function()
  local p = require("netio.protocol.mzm.gsp.pk.CAcceptMoralValueTaskReq").new()
  gmodule.network.sendProtocol(p)
end
def.static("number", "number", "string").SendBindTargetRoleReq = function(bagId, itemKey, roleInfo)
  local p = require("netio.protocol.mzm.gsp.pk.CRevengeItemAssignRoleReq").new(bagId, itemKey, roleInfo)
  gmodule.network.sendProtocol(p)
end
def.static("number", "number").SendCUseRevengeItemReq = function(bagId, itemKey)
  local p = require("netio.protocol.mzm.gsp.pk.CUseRevengeItemReq").new(bagId, itemKey)
  gmodule.network.sendProtocol(p)
end
def.static().SendTransformToTargetPos = function()
  local p = require("netio.protocol.mzm.gsp.pk.CUseRevengeItemTransferReq").new()
  gmodule.network.sendProtocol(p)
end
def.static("userdata").SendQueryUsrnameReq = function(roleId)
  local p = require("netio.protocol.mzm.gsp.pk.CQueryRoleNameReq").new(roleId)
  gmodule.network.sendProtocol(p)
end
def.static().SendQueryBoughtMeritReq = function()
  local p = require("netio.protocol.mzm.gsp.pk.CQueryBoughtMoralValueReq").new()
  gmodule.network.sendProtocol(p)
end
def.static("table").OnSEnablePKSuccess = function(p)
  PKMgr.GetData():SetExpireTime(p.expire_time or 0)
  Event.DispatchEvent(ModuleId.PLAYER_PK, gmodule.notifyId.PlayerPK.EnablePKResult, {ok = true})
end
local SEnablePKFail = require("netio.protocol.mzm.gsp.pk.SEnablePKFail")
def.static("table").OnSEnablePKFailed = function(p)
  if p.retcode == SEnablePKFail.LEVEL_TOO_LOW then
    Toast(txtConst[4]:format(const.ENABLE_PK_LEVEL))
  elseif p.retcode == SEnablePKFail.MORAL_VALUE_TOO_LOW then
    Toast(txtConst[6]:format(const.ENABLE_PK_MORAL_VALUE))
  elseif p.retcode == SEnablePKFail.INSUFFICIENT_MONEY then
    Toast(txtConst[5]:format(const.ENABLE_PK_PRICE))
  end
  Event.DispatchEvent(ModuleId.PLAYER_PK, gmodule.notifyId.PlayerPK.EnablePKResult, {ok = false})
end
def.static("table").OnSPKStart = function(p)
  local data = PKMgr.GetData()
  data:SetRoleId(nil)
  data.activeRoleId = p.active_role_id
  data.passiveRoleId = p.target_role_id
  PKMgr.OnEnterFight(nil, nil)
end
def.static("table").OnSPKStartFailed = function(p)
  local SStartPKFail = require("netio.protocol.mzm.gsp.pk.SStartPKFail")
  local roleId = PKMgr.GetData():GetRoleId()
  PKMgr.GetData():SetRoleId(nil)
  local bHasTeam = false
  if roleId ~= nil then
    local pubRoleInfo = require("Main.Pubrole.PubroleModule").Instance():GetRole(roleId)
    if pubRoleInfo ~= nil and pubRoleInfo.teamId ~= nil then
      bHasTeam = true
    end
  end
  if p.retcode == SStartPKFail.UNKNOWN then
    warn("Unkown error")
  elseif p.retcode == SStartPKFail.PK_NOT_ENABLED then
    Toast(txtConst[10]:format(_G.GetStringFromOcts(p.role_name)))
  elseif p.retcode == SStartPKFail.LEVEL_TOO_LOW then
    Toast(txtConst[11]:format(_G.GetStringFromOcts(p.role_name)))
  elseif p.retcode == SStartPKFail.TEAM_CHANGED_AFTER_CONFIRMATION then
    Toast(txtConst[12])
  elseif p.retcode == SStartPKFail.TARGET_TOO_FAR_AWAY then
    if bHasTeam then
      Toast(txtConst[13]:format(txtConst[56]))
    else
      Toast(txtConst[13]:format(txtConst[57]))
    end
  elseif p.retcode == SStartPKFail.IN_COMBAT then
    if bHasTeam then
      Toast(txtConst[14]:format(txtConst[56]))
    else
      Toast(txtConst[14]:format(txtConst[58]))
    end
  elseif p.retcode == SStartPKFail.TARGET_IN_SAFE_MAP then
    Toast(txtConst[15])
  elseif p.retcode == SStartPKFail.IN_PROTECTION then
    if bHasTeam then
      Toast(txtConst[16])
    else
      Toast(txtConst[59])
    end
  elseif p.retcode == SStartPKFail.IN_FORCE_PROTECTION then
    if bHasTeam then
      Toast(txtConst[17])
    else
      Toast(txtConst[60])
    end
  elseif p.retcode == SStartPKFail.OTHER_STATUS_CONFLICT then
    warn(">>>>>OTHER_STATUS_CONFLICT")
  elseif p.retcode == SStartPKFail.TARGET_IN_ABNORMAL_TEAM_STATE then
    warn(">>>>TARGET IN ABNORMAL TEAM STATE<<<<")
  elseif p.retcode == SStartPKFail.TARGET_IS_TEAMMATE then
    Toast(txtConst[19])
  elseif p.retcode == SStartPKFail.REACH_MAX_PK_TIMES then
    Toast(txtConst[20])
  elseif p.retcode == SStartPKFail.PK_CONFIRM_TIMEOUT then
    warn(">>>> PK Confirm Timeout")
  elseif p.retcode == 11 then
    if p.role_type == 0 then
      Toast(txtConst[69])
    elseif p.role_type == 1 then
      Toast(txtConst[68]:format(_G.GetStringFromOcts(p.role_name)))
    elseif p.role_type == 2 then
      Toast(txtConst[67]:format(_G.GetStringFromOcts(p.role_name)))
    end
  elseif p.retcode == SStartPKFail.ZERO_MORAL_VALUE then
    Toast(txtConst[79])
  end
end
def.static("table").OnSBuyMeritFailed = function(p)
  local REASON = require("netio.protocol.mzm.gsp.pk.SBuyMoralValueFail")
  if p.retcode == REASON.MORAL_VALUE_FULL then
    Toast(txtConst[34])
  elseif p.retcode == REASON.INSUFFICIENT_MONEY then
    local CurrencyFactory = require("Main.Currency.CurrencyFactory")
    local moneyData = CurrencyFactory.Create(const.MORAL_VALUE_MONEY_TYPE)
    Toast(txtConst[35]:format(moneyData:GetName()))
  elseif p.retcode == REASON.MONEY_NUM_NOT_MATCHED then
    warn("Ownd money not match to server")
  end
  Event.DispatchEvent(ModuleId.PLAYER_PK, gmodule.notifyId.PlayerPK.BuyMeritResult, {
    ok = false,
    reson = p.retcode
  })
end
def.static("table").OnSAcceptMeritTaskFailed = function(p)
  if p.retcode == 1 then
    Toast(txtConst[34])
  end
end
def.static("table").OnSBindTargetRoleFailed = function(p)
  Event.DispatchEvent(ModuleId.PLAYER_PK, gmodule.notifyId.PlayerPK.BindPlayerFailed, p)
end
def.static("table").OnSUseRevengeItemSuccess = function(p)
  local mapCfg = require("Main.Map.MapUtility").GetMapCfg(p.map_id)
  if mapCfg ~= nil then
    require("Main.Item.ItemModule").Instance():CloseInventoryDlg()
    local strContent = txtConst[30]:format(mapCfg.mapName)
    CommonConfirmDlg.ShowConfirmCoundDown(txtConst[29], strContent, "", "", 1, const.REVENGE_ITEM_TRANSFER_CONFIRM_SECONDS, function(select)
      if select == 1 then
        PKProtocols.SendTransformToTargetPos()
      end
    end, nil)
  end
end
def.static("table").OnSUseRevengeItemFailed = function(p)
  local Failed = require("netio.protocol.mzm.gsp.pk.SUseRevengeItemFail")
  if p.retcode == Failed.DEPLETED then
    Toast(txtConst[64])
  elseif p.retcode == Failed.PK_NOT_ENABLED then
    Toast(txtConst[26])
  elseif p.retcode == Failed.TARGET_NOT_ONLINE then
    Toast(txtConst[27])
  elseif p.retcode == Failed.TARGET_IN_SAFE_MAP then
    Toast(txtConst[15])
  end
end
def.static("table").OnSTransformSuccess = function(p)
  local strContent = txtConst[39]:format(_G.GetStringFromOcts(p.target_role_name))
  CommonConfirmDlg.ShowConfirm(txtConst[37], strContent, function(select)
    if select == 1 then
      PKMgr.GetProtocols().SendCStartPKReq(p.target_role_id)
    end
  end, nil)
end
def.static("table").OnSTransformFailed = function(p)
end
def.static("table").OnSSyncPKStatus = function(p)
  local me = gmodule.moduleMgr:GetModule(ModuleId.HERO).myRole
  local statusList = {}
  for _, status in pairs(p.status_set) do
    table.insert(statusList, status)
  end
  require("Main.Pubrole.PubroleModule").Instance():SetRoleStatus(me, statusList)
end
def.static("table").OnQueryRoleNameRes = function(p)
  local roleName = _G.GetStringFromOcts(p.role_name)
  Event.DispatchEvent(ModuleId.PLAYER_PK, gmodule.notifyId.PlayerPK.GetRoleName, {name = roleName})
end
def.static("table").OnSNotifyPKPenalty = function(p)
  if p.equipment_usability_penalty > 0 then
    warn("Toast p.equipment_usability_penalty", p.equipment_usability_penalty)
    Toast(txtConst[53]:format(p.equipment_usability_penalty))
  end
end
def.static("table").SQueryBoughtMoralVal = function(p)
  Event.DispatchEvent(ModuleId.PLAYER_PK, gmodule.notifyId.PlayerPK.QueryBoughtMeritRes, {
    result = p.bought_moral_value
  })
end
return PKProtocols.Commit()
