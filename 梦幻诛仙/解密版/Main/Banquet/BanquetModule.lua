local Lplus = require("Lplus")
local ModuleBase = require("Main.module.ModuleBase")
local BanquetModule = Lplus.Extend(ModuleBase, "BanquetModule")
local BanquetInterface = require("Main.Banquet.BanquetInterface")
local banquetInterface = BanquetInterface.Instance()
local def = BanquetModule.define
local instance
def.static("=>", BanquetModule).Instance = function()
  if instance == nil then
    instance = BanquetModule()
    instance.m_moduleId = ModuleId.BANQUET
  end
  return instance
end
def.override().Init = function(self)
  gmodule.network.registerProtocol("netio.protocol.mzm.gsp.banquest.SSyncBanquetInfo", BanquetModule.OnSSyncBanquetInfo)
  gmodule.network.registerProtocol("netio.protocol.mzm.gsp.banquest.SHoldBanquetRep", BanquetModule.OnSHoldBanquetRep)
  gmodule.network.registerProtocol("netio.protocol.mzm.gsp.banquest.SSyncBanquetPlayerNumberBrd", BanquetModule.OnSSyncBanquetPlayerNumberBrd)
  gmodule.network.registerProtocol("netio.protocol.mzm.gsp.banquest.STriggerDishesBrd", BanquetModule.OnSTriggerDishesBrd)
  gmodule.network.registerProtocol("netio.protocol.mzm.gsp.banquest.SBanquetNormalResult", BanquetModule.OnSBanquetNormalResult)
  gmodule.network.registerProtocol("netio.protocol.mzm.gsp.banquest.SSyncBanquetEndBrd", BanquetModule.OnSSyncBanquetEndBrd)
  gmodule.network.registerProtocol("netio.protocol.mzm.gsp.banquest.SClearBanquetInfo", BanquetModule.OnSClearBanquetInfo)
  Event.RegisterEvent(ModuleId.LOGIN, gmodule.notifyId.Login.ENTER_WORLD, BanquetModule.OnEnterWorld)
  Event.RegisterEvent(ModuleId.LOGIN, gmodule.notifyId.Login.LEAVE_WORLD, function()
    self:Reset()
  end)
  Event.RegisterEvent(ModuleId.NPC, gmodule.notifyId.NPC.NPC_SERVICE, BanquetModule.OnNPCService)
  Event.RegisterEvent(ModuleId.HOMELAND, gmodule.notifyId.Homeland.SyncHomelandBasicInfo, BanquetModule.OnHomelandGeomancyChange)
  Event.RegisterEvent(ModuleId.HOMELAND, gmodule.notifyId.Homeland.GeomancyChange, BanquetModule.OnHomelandGeomancyChange)
  Event.RegisterEvent(ModuleId.FIGHT, gmodule.notifyId.Fight.ENTER_FIGHT, BanquetModule.OnEnterFight)
  Event.RegisterEvent(ModuleId.FIGHT, gmodule.notifyId.Fight.LEAVE_FIGHT, BanquetModule.OnLeaveFight)
  ModuleBase.Init(self)
end
def.override().OnReset = function(self)
  banquetInterface:Reset()
end
def.static("table", "table").OnEnterWorld = function()
  if banquetInterface.masterId then
    local endTime = banquetInterface:getCurBanquetEndTime()
    if endTime > GetServerTime() then
      local banquetPanel = require("Main.Banquet.ui.BanquetPanel").Instance()
      banquetPanel:ShowPanel()
      Event.DispatchEvent(ModuleId.BANQUET, gmodule.notifyId.Banquet.ENTER_BANQUET, nil)
    end
  end
end
def.static("table", "table").OnEnterFight = function(p1, p2)
  if banquetInterface.isBanqueting then
    Event.DispatchEvent(ModuleId.BANQUET, gmodule.notifyId.Banquet.BANQUET_EXIT, nil)
  end
end
def.static("table", "table").OnLeaveFight = function(p1, p2)
  if banquetInterface.isBanqueting then
    local p = require("netio.protocol.mzm.gsp.banquest.CSynBanquestReq").new()
    gmodule.network.sendProtocol(p)
  end
end
def.method().HoldBanquet = function()
  Event.DispatchEvent(ModuleId.ACTIVITY, gmodule.notifyId.activity.Activity_GotoNPC, {
    constant.CBanquetConsts.HOLD_BANQUEST_NPC
  })
end
def.method("userdata").JoinBanquet = function(self, roleId)
  local heroProp = require("Main.Hero.Interface"):GetBasicHeroProp()
  local myLv = heroProp.level
  local needLv = constant.CBanquetConsts.JOIN_LEVEL_MIN
  if myLv < needLv then
    Toast(string.format(textRes.Banquet[6], needLv))
    return
  end
  local p = require("netio.protocol.mzm.gsp.banquest.CJoinBanquet").new(roleId)
  gmodule.network.sendProtocol(p)
end
def.static("table", "table").OnHomelandGeomancyChange = function(p1, p2)
  banquetInterface:calcBanquetRank()
  Event.DispatchEvent(ModuleId.BANQUET, gmodule.notifyId.Banquet.BANQUET_INFO_CHANGE, nil)
end
def.static("table", "table").OnNPCService = function(p1, p2)
  local serviceId = p1[1]
  local npcId = p1[2]
  if serviceId == constant.CBanquetConsts.HOLD_BANQUEST_NPC_SERVICE then
    local heroProp = require("Main.Hero.Interface"):GetBasicHeroProp()
    local myLv = heroProp.level
    if myLv < constant.CBanquetConsts.HOLD_BANQUEST_ROLE_LEVEL then
      Toast(textRes.Banquet[5])
      return
    end
    local curTime = GetServerTime()
    local activityInterface = require("Main.activity.ActivityInterface").Instance()
    local isOpen = activityInterface:isActivityOpend(constant.CBanquetConsts.ACTIVITY_ID)
    if isOpen then
      local callback = function()
        local p = require("netio.protocol.mzm.gsp.banquest.CHoldBanquetReq").new()
        gmodule.network.sendProtocol(p)
      end
      local banquentConfirm = require("Main.Banquet.ui.BanquetConfirmPanel").Instance()
      banquentConfirm:ShowDlg(textRes.Banquet[9], callback)
    else
      Toast(textRes.Banquet[2])
    end
  end
end
def.static("table").OnSSyncBanquetInfo = function(p)
  warn("----------OnSSyncBanquetInfo:", p.player_num, p.start_time:ToNumber())
  banquetInterface.masterId = p.masterId
  banquetInterface.startTime = p.start_time:ToNumber()
  banquetInterface.playerNum = p.player_num
  banquetInterface.isBanqueting = true
  banquetInterface:calcBanquetRank()
  if IsEnteredWorld() and not _G.PlayerIsInFight() then
    local banquetPanel = require("Main.Banquet.ui.BanquetPanel").Instance()
    banquetPanel:ShowPanel()
    Event.DispatchEvent(ModuleId.BANQUET, gmodule.notifyId.Banquet.ENTER_BANQUET, nil)
  end
end
def.static("table").OnSHoldBanquetRep = function(p)
end
def.static("table").OnSSyncBanquetPlayerNumberBrd = function(p)
  warn("------OnSSyncBanquetPlayerNumberBrd:", p.player_num)
  banquetInterface.playerNum = p.player_num
  banquetInterface:calcBanquetRank()
  Event.DispatchEvent(ModuleId.BANQUET, gmodule.notifyId.Banquet.BANQUET_PALYER_NUM_CHANGE, nil)
end
def.static("table").OnSTriggerDishesBrd = function(p)
  banquetInterface.tiggerNum = p.tigger_count
  banquetInterface.delaySec = p.delay_seconds
end
def.static("table").OnSSyncBanquetEndBrd = function(p)
  warn("-------OnSSyncBanquetEndBrd")
  banquetInterface:Reset()
  Event.DispatchEvent(ModuleId.BANQUET, gmodule.notifyId.Banquet.BANQUET_END, nil)
end
def.static("table").OnSClearBanquetInfo = function(p)
  warn("--------OnSClearBanquetInfo")
  banquetInterface:Reset()
  Event.DispatchEvent(ModuleId.BANQUET, gmodule.notifyId.Banquet.BANQUET_EXIT, nil)
end
def.static("table").OnSBanquetNormalResult = function(p)
  warn("-----OnSBanquetNormalResult:", p.result)
  local fn = {}
  fn[p.EACH_BANQUEST_AWARD_UPPER_LIMIT] = function(args)
    Toast(string.format(textRes.Banquet.retResult[p.result], args[1]))
  end
  fn[p.EACH_DISH_AWARD_UPPER_LIMIT] = function(args)
    Toast(string.format(textRes.Banquet.retResult[p.result], args[1]))
  end
  fn[p.JOIN_BANQUEST_LV_ILLEGAL] = function(args)
    Toast(string.format(textRes.Banquet.retResult[p.result], args[1]))
  end
  fn[p.JOIN_BANQUEST_MEMBER_LV_ILLEGAL] = function(args)
    Toast(string.format(textRes.Banquet.retResult[p.result], args[1], args[2]))
  end
  fn[p.HOLD_BANQUEST_BAN__NUM_TO_MAX] = function(args)
    Toast(string.format(textRes.Banquet.retResult[p.result], args[1]))
  end
  if fn[p.result] then
    fn[p.result](p.args)
  else
    local str = textRes.Banquet.retResult[p.result]
    if str then
      Toast(str)
    else
      warn("!!!!!!!OnSBanquetNormalResult:", p.result)
    end
  end
end
return BanquetModule.Commit()
