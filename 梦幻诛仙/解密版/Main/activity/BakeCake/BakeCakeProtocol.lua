local MODULE_NAME = (...)
local Lplus = require("Lplus")
local BakeCakeProtocol = Lplus.Class(MODULE_NAME)
local def = BakeCakeProtocol.define
local BakeCakeMgr = Lplus.ForwardDeclare("Main.activity.BakeCake.BakeCakeMgr")
local bakeCakeMgr, factionCakeInfoReqs, cakeHistoryReqs
def.static(BakeCakeMgr).Init = function(mgr)
  bakeCakeMgr = mgr
  gmodule.network.registerProtocol("netio.protocol.mzm.gsp.cake.SMakeCakeStageBro", BakeCakeProtocol.OnSMakeCakeStageBro)
  gmodule.network.registerProtocol("netio.protocol.mzm.gsp.cake.SSynMakeCakeStage", BakeCakeProtocol.OnSSynMakeCakeStage)
  gmodule.network.registerProtocol("netio.protocol.mzm.gsp.cake.SGetFactionCakeInfoRep", BakeCakeProtocol.OnSGetFactionCakeInfoRep)
  gmodule.network.registerProtocol("netio.protocol.mzm.gsp.cake.SCakeInfoChangeBro", BakeCakeProtocol.OnSCakeInfoChangeBro)
  gmodule.network.registerProtocol("netio.protocol.mzm.gsp.cake.SSynCakeHistory", BakeCakeProtocol.OnSSynCakeHistory)
  gmodule.network.registerProtocol("netio.protocol.mzm.gsp.cake.SCakeNormalNotice", BakeCakeProtocol.OnSCakeNormalNotice)
  gmodule.network.registerProtocol("netio.protocol.mzm.gsp.cake.SGetCakeAward", BakeCakeProtocol.OnSGetCakeAward)
end
def.static().Clear = function()
  factionCakeInfoReqs = nil
  cakeHistoryReqs = nil
end
def.static("table").OnSMakeCakeStageBro = function(p)
end
def.static("table").OnSSynMakeCakeStage = function(p)
  bakeCakeMgr:SetActivityInfos(p.activityInfos)
end
def.static("table").OnSGetFactionCakeInfoRep = function(p)
  BakeCakeProtocol.CallbackFactionCakeInfoReqs(p)
end
def.static("table").OnSCakeInfoChangeBro = function(p)
  local BakeCakeUtils = Lplus.ForwardDeclare("Main.activity.BakeCake.BakeCakeUtils")
  local CakeHistory = require("netio.protocol.mzm.gsp.cake.CakeHistory")
  local SCakeInfoChangeBro = require("netio.protocol.mzm.gsp.cake.SCakeInfoChangeBro")
  local CakeDetailInfo = require("netio.protocol.mzm.gsp.cake.CakeDetailInfo")
  local Octets = require("netio.Octets")
  local lastCakeInfo = bakeCakeMgr:GetRoleCakeInfo(p.activityId, p.roleId)
  local function getCakeRank(cakeId)
    local cakeCfg
    if cakeId ~= 0 then
      cakeCfg = BakeCakeUtils.GetCakeCfg(cakeId)
      if cakeCfg then
        return cakeCfg.range
      end
    end
    return 0
  end
  local lastCakeId = lastCakeInfo and lastCakeInfo.cakeId or 0
  local cakeInfo = p.cakeInfo
  local newCakeId = cakeInfo.cakeId
  local orgRank = getCakeRank(lastCakeId)
  local newRank = getCakeRank(newCakeId)
  local myRoleId = _G.GetMyRoleID()
  if p.masterName then
    local roleName = _G.GetStringFromOcts(p.masterName)
    bakeCakeMgr:SetRoleNameInActivity(p.activityId, p.roleId, roleName)
  end
  if p.reason == SCakeInfoChangeBro.REASON_MAKE then
    if cakeInfo.state == CakeDetailInfo.STAGE_MAKE_ING then
      if myRoleId == p.makeRoleId then
        if myRoleId == p.roleId then
          bakeCakeMgr:IncBakeSelfsCakeLeftTimes(p.activityId)
        else
          bakeCakeMgr:IncBakeOthersCakeLeftTimes(p.activityId)
        end
      end
    else
      local history = CakeHistory.new()
      history.historyType = CakeHistory.HISTORY_TYPE__COOK
      history.recordTime = Int64.new(_G.GetServerTime())
      history.makeRoleName = Octets.rawFromString(bakeCakeMgr:GetRoleNameInActivity(p.activityId, p.makeRoleId))
      history.masterName = Octets.rawFromString(bakeCakeMgr:GetRoleNameInActivity(p.activityId, p.roleId))
      history.itemId = p.itemId
      history.orgRank = orgRank
      history.newRank = newRank
      bakeCakeMgr:AddCakeHistory(p.activityId, p.roleId, history)
      if myRoleId == p.roleId then
        local text = bakeCakeMgr:ConvertHistoryToLogText(history)
        local HtmlHelper = require("Main.Chat.HtmlHelper")
        text = HtmlHelper.ConvertBBCodeColorToHtml(text)
        Toast(text)
      end
    end
  elseif p.reason == SCakeInfoChangeBro.REASON_ADD and myRoleId == p.roleId then
    Toast(textRes.BakeCake[26]:format(newRank))
    bakeCakeMgr:InitRoundData(cakeInfo.curTurn)
  end
  bakeCakeMgr:SetRoleCakeInfo(p.activityId, p.roleId, p.cakeInfo)
  local params = {}
  params.activityId = p.activityId
  params.cakeOwnerId = p.roleId
  params.lastOperatorId = p.makeRoleId
  params.isAdd = p.reason == SCakeInfoChangeBro.REASON_ADD
  params.orgRank = orgRank
  params.newRank = newRank
  Event.DispatchEvent(ModuleId.ACTIVITY, gmodule.notifyId.activity.Activity_BakeCake_Cake_Info_Change, params)
end
def.static("table").OnSSynCakeHistory = function(p)
  BakeCakeProtocol.CallbackcakeHistoryReqs(p)
end
def.static("table").OnSCakeNormalNotice = function(p)
  local GangModule = require("Main.Gang.GangModule")
  local HtmlHelper = require("Main.Chat.HtmlHelper")
  local result = p.result
  local args = p.args
  local text = textRes.BakeCake.SCakeNormalNotice[result]
  if result == p.class.COOK_PERFECT or result == p.class.COOK_TERRIBLE then
    text = text:formatEx(unpack(p.args))
    text = HtmlHelper.ConvertEmoji(text)
    GangModule.ShowInGangChannel(text)
  elseif result == p.class.COLLECTION_START then
    GangModule.ShowInGangChannel(text)
    Toast(text)
  else
    if text then
      text = text:format(unpack(p.args))
    else
      text = textRes.BakeCake.SCakeNormalNotice.Unknow:format(result)
    end
    Toast(text)
  end
end
def.static("table").OnSGetCakeAward = function(p)
  local SGetCakeAward = require("netio.protocol.mzm.gsp.cake.SGetCakeAward")
  local HtmlHelper = require("Main.Chat.HtmlHelper")
  local AwardUtils = require("Main.Award.AwardUtils")
  local PersonalHelper = require("Main.Chat.PersonalHelper")
  local text
  if p.belongType == SGetCakeAward.ITEM_BELONG_TYPE__SELF then
    text = textRes.BakeCake[32]
  elseif p.belongType == SGetCakeAward.ITEM_BELONG_TYPE__OTHER then
    text = textRes.BakeCake[33]
  end
  local awardStr = table.concat(AwardUtils.GetHtmlTextsFromAwardBean(p.awardBean, ""))
  text = text:format(awardStr, p.leftNum)
  PersonalHelper.SendOut(text)
end
def.static("number", "userdata", "function").CGetFactionCakeInfoReq = function(activityId, factionId, callback)
  local p = require("netio.protocol.mzm.gsp.cake.CGetFactionCakeInfoReq").new(activityId, factionId)
  gmodule.network.sendProtocol(p)
  BakeCakeProtocol.AddFactionCakeInfoReq(activityId, factionId, callback)
end
def.static("number", "number").CAddCakeReq = function(activityId, clientTurn)
  local p = require("netio.protocol.mzm.gsp.cake.CAddCakeReq").new(activityId, clientTurn)
  gmodule.network.sendProtocol(p)
end
def.static("number", "userdata", "userdata", "number", "number").CMakeCakeReq = function(activityId, cakeMasterId, uuid, num, clientTurn)
  local p = require("netio.protocol.mzm.gsp.cake.CMakeCakeReq").new(activityId, clientTurn, cakeMasterId, uuid, num)
  gmodule.network.sendProtocol(p)
end
def.static("number", "userdata", "userdata", "function").CCheckCakeHistoryReq = function(activityId, factionId, roleId, callback)
  local p = require("netio.protocol.mzm.gsp.cake.CCheckCakeHistoryReq").new(activityId, factionId, roleId)
  gmodule.network.sendProtocol(p)
  BakeCakeProtocol.AddCakeHistoryReq(activityId, factionId, roleId, callback)
end
def.static("userdata", "number").CUseCakeItem = function(uuid, num)
  local p = require("netio.protocol.mzm.gsp.cake.CUseCakeItem").new(uuid, num)
  gmodule.network.sendProtocol(p)
end
def.static("number", "userdata", "function").AddFactionCakeInfoReq = function(activityId, factionId, callback)
  local reqId = BakeCakeProtocol.CalcFactionCakeInfoReqId(activityId, factionId)
  factionCakeInfoReqs = factionCakeInfoReqs or {}
  if factionCakeInfoReqs[reqId] == nil then
    factionCakeInfoReqs[reqId] = {callback}
  else
    table.insert(factionCakeInfoReqs[reqId], callback)
  end
end
def.static("table").CallbackFactionCakeInfoReqs = function(p)
  if factionCakeInfoReqs == nil then
    return
  end
  local reqId = BakeCakeProtocol.CalcFactionCakeInfoReqId(p.activityId, p.factionId)
  local reqs = factionCakeInfoReqs[reqId]
  if reqs == nil then
    return
  end
  for i, req in ipairs(reqs) do
    req(p)
  end
  factionCakeInfoReqs[reqId] = nil
  if table.nums(factionCakeInfoReqs) == 0 then
    factionCakeInfoReqs = nil
  end
end
def.static("number", "userdata", "=>", "string").CalcFactionCakeInfoReqId = function(activityId, factionId)
  return activityId .. "_" .. tostring(factionId)
end
def.static("number", "userdata", "userdata", "function").AddCakeHistoryReq = function(activityId, factionId, roleId, callback)
  local reqId = BakeCakeProtocol.CalcCakeHistoryReqId(activityId, factionId, roleId)
  cakeHistoryReqs = cakeHistoryReqs or {}
  if cakeHistoryReqs[reqId] == nil then
    cakeHistoryReqs[reqId] = {callback}
  else
    table.insert(cakeHistoryReqs[reqId], callback)
  end
end
def.static("table").CallbackcakeHistoryReqs = function(p)
  if cakeHistoryReqs == nil then
    return
  end
  local reqId = BakeCakeProtocol.CalcCakeHistoryReqId(p.activityId, p.factionId, p.roleId)
  local reqs = cakeHistoryReqs[reqId]
  if reqs == nil then
    return
  end
  for i, req in ipairs(reqs) do
    req(p)
  end
  cakeHistoryReqs[reqId] = nil
  if table.nums(cakeHistoryReqs) == 0 then
    cakeHistoryReqs = nil
  end
end
def.static("number", "userdata", "userdata", "=>", "string").CalcCakeHistoryReqId = function(activityId, factionId, roleId)
  return string.format("%s_%s_%s", activityId, tostring(factionId), tostring(roleId))
end
return BakeCakeProtocol.Commit()
