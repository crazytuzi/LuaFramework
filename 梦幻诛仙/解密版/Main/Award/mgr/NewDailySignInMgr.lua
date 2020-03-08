local CUR_CLASS_NAME = (...)
local Lplus = require("Lplus")
local AwardMgrBase = require("Main.Award.mgr.AwardMgrBase")
local NewDailySignInMgr = Lplus.Extend(AwardMgrBase, CUR_CLASS_NAME)
local ItemUtils = require("Main.Item.ItemUtils")
local AwardUtils = require("Main.Award.AwardUtils")
local def = NewDailySignInMgr.define
def.field("number").curPreciousCell = -1
def.field("boolean").hasPrecious = false
def.field("boolean").isFirstBoxReceived = false
local instance
def.static("=>", NewDailySignInMgr).Instance = function()
  if instance == nil then
    instance = NewDailySignInMgr()
  end
  return instance
end
def.method().Init = function(self)
  gmodule.network.registerProtocol("netio.protocol.mzm.gsp.signaward.SSignInRes", NewDailySignInMgr.OnSSignInRes)
  gmodule.network.registerProtocol("netio.protocol.mzm.gsp.signaward.SSignPreciousDrawLotterySuccess", NewDailySignInMgr.OnSSignPreciousDrawLotterySuccess)
  gmodule.network.registerProtocol("netio.protocol.mzm.gsp.signaward.SSignPreciousNotifyLuckyLottery", NewDailySignInMgr.OnSSignPreciousNotifyLuckyLottery)
  Event.RegisterEvent(ModuleId.LOGIN, gmodule.notifyId.Login.LEAVE_WORLD, NewDailySignInMgr.OnLeaveWorld)
  Event.RegisterEvent(ModuleId.FEATURE, gmodule.notifyId.Feature.FeatureOpenChange, NewDailySignInMgr.OnFeatureOpenChange)
end
def.static("table").OnSSignInRes = function(p)
  instance:SetPreciousData(p.current_precious_cell_num, p.current_precious_cell_buff_id, p.is_first_box_aleardy_get)
  gmodule.moduleMgr:GetModule(ModuleId.AWARD):CheckNotifyMessageCount()
end
def.static("table").OnSSignPreciousDrawLotterySuccess = function(p)
  instance:MarkReceivedPrecious()
  gmodule.moduleMgr:GetModule(ModuleId.AWARD):CheckNotifyMessageCount()
  if p.item_num > 0 then
    require("Main.Award.ui.NewDailySignInPreciousPanel").Instance():ShowPanel(p.lottery_view_id, p.final_index, p.item_id, p.item_num, p.box_type, p.buff_id, p.buff_id_n_times)
  end
end
def.static("table").OnSSignPreciousNotifyLuckyLottery = function(p)
  require("Main.Award.ui.NewDailySignInLuckyPanel").Instance():ShowPanel(p.precious_box_cfg_id, p.box_type, p.cost_yuan_bao)
end
def.static("table", "table").OnLeaveWorld = function(p1, p2)
  instance:ResetData()
end
def.static("table", "table").OnFeatureOpenChange = function(params, context)
  local ModuleFunSwitchInfo = require("netio.protocol.mzm.gsp.open.ModuleFunSwitchInfo")
  local AwardPanel = require("Main.Award.ui.AwardPanel")
  if params.feature == ModuleFunSwitchInfo.TYPE_SIGN_PRECIOUS then
    Event.DispatchEvent(ModuleId.AWARD, gmodule.notifyId.Award.AWARD_NODE_OPEN_CHANGE, {
      nodeId = AwardPanel.NodeId.DailySignIn
    })
    gmodule.moduleMgr:GetModule(ModuleId.AWARD):CheckNotifyMessageCount()
  end
end
def.override("=>", "boolean").IsHaveNotifyMessage = function(self)
  return self:GetNotifyMessageCount() > 0
end
def.override("=>", "number").GetNotifyMessageCount = function(self)
  if self:IsOpen() and self:HasPrecious() then
    return 1
  end
  return 0
end
def.override("=>", "boolean").IsOpen = function(self)
  if not IsFeatureOpen(require("netio.protocol.mzm.gsp.open.ModuleFunSwitchInfo").TYPE_SIGN_PRECIOUS) then
    return false
  end
  return true
end
def.method().ResetData = function(self)
  self.curPreciousCell = -1
  self.hasPrecious = false
end
def.method("number", "number", "number").SetPreciousData = function(self, cell, buffId, receiveFirstBox)
  local preCell = self.curPreciousCell
  self.curPreciousCell = cell
  self.hasPrecious = buffId > 0
  self.isFirstBoxReceived = receiveFirstBox ~= 0
  self:CheckMoveHero(preCell)
end
def.method().MarkReceivedPrecious = function(self)
  self.hasPrecious = false
  self.isFirstBoxReceived = true
end
def.method("=>", "boolean").IsReceivedFirstBox = function(self)
  return self.isFirstBoxReceived
end
def.method("number").CheckMoveHero = function(self, preCell)
  if preCell ~= -1 then
    if self.curPreciousCell == 0 then
      Event.DispatchEvent(ModuleId.AWARD, gmodule.notifyId.Award.NEW_DAILY_SIGN_RESET, nil)
    else
      local lastCell = math.max(0, preCell)
      local totalCell = constant.CSignPreciousConsts.cell_total_num
      local cellChange = (self.curPreciousCell + totalCell - lastCell) % totalCell
      if cellChange ~= 0 then
        Event.DispatchEvent(ModuleId.AWARD, gmodule.notifyId.Award.NEW_DAILY_SIGN_MOVE, {step = cellChange})
      end
    end
  end
end
def.method("=>", "number").GetCurrentCell = function(self)
  return self.curPreciousCell
end
def.method("=>", "boolean").HasPrecious = function(self)
  return self.hasPrecious
end
def.method().GetItemAward = function(self)
  local req = require("netio.protocol.mzm.gsp.signaward.CSignPreciousGetAward").new()
  gmodule.network.sendProtocol(req)
end
def.method().TryToGetBoxAward = function(self)
  local req = require("netio.protocol.mzm.gsp.signaward.CSignPreciousDrawLottery").new()
  gmodule.network.sendProtocol(req)
end
def.method().GetBoxAward = function(self)
  local req = require("netio.protocol.mzm.gsp.signaward.CSignPreciousGetAward").new()
  gmodule.network.sendProtocol(req)
end
def.method().PayToArriveBoxAward = function(self)
  local dailySignMgr = require("Main.Award.mgr.DailySignInMgr").Instance()
  local signInStates = dailySignMgr:GetSignInStates()
  local currentdate = signInStates.date
  local signDay = signInStates.signedDays + 1
  local date = currentdate.year * 10000 + currentdate.month * 100 + signDay
  local CurrencyFactory = require("Main.Currency.CurrencyFactory")
  local CurrencyType = require("consts.mzm.gsp.common.confbean.CurrencyType")
  local moneyData = CurrencyFactory.Create(CurrencyType.YUAN_BAO)
  if dailySignMgr:CanSigne(signDay) then
    local p = require("netio.protocol.mzm.gsp.signaward.CSignInReq").new(date, moneyData:GetHaveNum(), 1)
    gmodule.network.sendProtocol(p)
  elseif dailySignMgr:CanRedress(signDay) then
    local p = require("netio.protocol.mzm.gsp.signaward.CReplenishSignInReq").new(date, moneyData:GetHaveNum(), 1)
    gmodule.network.sendProtocol(p)
  end
end
def.method("userdata").PayToOpenLuckyBoxAward = function(self, yuanbaoNum)
  local req = require("netio.protocol.mzm.gsp.signaward.CSignPreciousOpenLuckyBox").new(yuanbaoNum)
  gmodule.network.sendProtocol(req)
end
def.method("number", "=>", "table").GetChessItemAward = function(self, cellNum)
  local entry = DynamicData.GetRecord(CFG_PATH.DATA_SIGN_CHESS_ITEM_CFG, cellNum)
  if entry == nil then
    return nil
  end
  local cfg = {}
  cfg.cell_num = DynamicRecord.GetIntValue(entry, "cell_num")
  cfg.item_id = DynamicRecord.GetIntValue(entry, "item_id")
  cfg.item_count = DynamicRecord.GetIntValue(entry, "item_count")
  return cfg
end
def.method("number", "=>", "table").GetChessBoxAward = function(self, cellNum)
  local entry = DynamicData.GetRecord(CFG_PATH.DATA_SIGN_CHESS_BOX_CFG, cellNum)
  if entry == nil then
    return nil
  end
  local cfg = {}
  cfg.cell_num = DynamicRecord.GetIntValue(entry, "cell_num")
  cfg.cell_award_type = DynamicRecord.GetIntValue(entry, "cell_award_type")
  cfg.gold_precious_cfg_id = DynamicRecord.GetIntValue(entry, "gold_precious_cfg_id")
  cfg.arrive_cost_yuan_bao = DynamicRecord.GetIntValue(entry, "arrive_cost_yuan_bao")
  return cfg
end
return NewDailySignInMgr.Commit()
