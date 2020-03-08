local CUR_CLASS_NAME = (...)
local Lplus = require("Lplus")
local LotteryAwardMgr = Lplus.Class(CUR_CLASS_NAME)
local ItemUtils = require("Main.Item.ItemUtils")
local CurrencyType = require("consts.mzm.gsp.common.confbean.CurrencyType")
local ActivityInterface = require("Main.activity.ActivityInterface")
local Feature = require("netio.protocol.mzm.gsp.open.ModuleFunSwitchInfo")
local FeatureOpenListModule = require("Main.FeatureOpenList.FeatureOpenListModule")
local AbsoluteTimer = require("Main.Common.AbsoluteTimer")
local ItemType = require("consts.mzm.gsp.item.confbean.ItemType")
local ItemModule = require("Main.Item.ItemModule")
local def = LotteryAwardMgr.define
local BUY_ONE_TIMES = 1
local BUY_TEN_TIMES = 10
local myFeature = Feature.TYPE_YI_XIAN_MI_BAO
def.const("number").NOT_USE_YUAN_BAO = 0
def.const("number").USE_YUAN_BAO = 1
def.field("table").m_info = nil
local instance
def.static("=>", LotteryAwardMgr).Instance = function()
  if instance == nil then
    instance = LotteryAwardMgr()
  end
  return instance
end
def.method().Init = function(self)
  Event.RegisterEvent(ModuleId.LOGIN, gmodule.notifyId.Login.LEAVE_WORLD, LotteryAwardMgr.OnLeaveWorld)
  Event.RegisterEvent(ModuleId.LOGIN, gmodule.notifyId.Login.ENTER_WORLD, LotteryAwardMgr.OnEnterWorld)
  Event.RegisterEvent(ModuleId.ACTIVITY, gmodule.notifyId.activity.Activity_Start, LotteryAwardMgr.OnActivityStart)
  Event.RegisterEvent(ModuleId.ACTIVITY, gmodule.notifyId.activity.Activity_Reset, LotteryAwardMgr.OnActivityRest)
  Event.RegisterEvent(ModuleId.ACTIVITY, gmodule.notifyId.activity.Activity_Close, LotteryAwardMgr.OnActivityClose)
  Event.RegisterEvent(ModuleId.FEATURE, gmodule.notifyId.Feature.FeatureOpenChange, LotteryAwardMgr.OnFunctionOpenChange)
  Event.RegisterEvent(ModuleId.FEATURE, gmodule.notifyId.Feature.FeatureOpenInit, LotteryAwardMgr.OnFunctionOpenInit)
  gmodule.network.registerProtocol("netio.protocol.mzm.gsp.mibao.SBuyMiBaoSuccess", LotteryAwardMgr.OnSBuyMiBaoSuccess)
  gmodule.network.registerProtocol("netio.protocol.mzm.gsp.mibao.SBuyMiBaoFail", LotteryAwardMgr.OnSBuyMiBaoFail)
  gmodule.network.registerProtocol("netio.protocol.mzm.gsp.mibao.SGetMiBaoInfo", LotteryAwardMgr.OnSGetMiBaoInfo)
  gmodule.network.registerProtocol("netio.protocol.mzm.gsp.mibao.SExchangeScoreSuccess", LotteryAwardMgr.OnSExchangeScoreSuccess)
  gmodule.network.registerProtocol("netio.protocol.mzm.gsp.mibao.SExchangeScoreFail", LotteryAwardMgr.OnSExchangeScoreFail)
end
def.method("=>", "boolean").IsForceUseExchangeItem = function(self)
  return true
end
def.method().CheckInfoData = function(self)
  if self.m_info == nil then
    self:CGetMiBaoInfo()
  end
end
def.method("=>", "boolean").HaveInfoData = function(self)
  if self.m_info == nil then
    return false
  end
  return true
end
def.method("=>", "table").GetLotteryInfo = function(self)
  local lotteryCfgId = self:GetCurLotteryCfgId()
  return self:_GetLotteryInfo(lotteryCfgId)
end
def.method("=>", "number").GetLuckyPoint = function(self)
  if self.m_info == nil then
    return 0
  end
  return self.m_info.luckyPoint
end
def.method("=>", "number").GetCreditScore = function(self)
  if self.m_info == nil then
    return 0
  end
  return self.m_info.creditScore
end
def.method("=>", "number").GetCreditIconId = function(self)
  return 900
end
def.method("=>", "number").GetCurBuyIndex = function(self)
  local index = 1
  if self.m_info then
    index = self.m_info.curIndex
  end
  return index
end
def.method("=>", "number").GetCurLotteryCfgId = function(self)
  local index = self:GetCurBuyIndex()
  return self:GetLotteryCfgId(index)
end
def.method("number", "=>", "number").GetLotteryCfgId = function(self, index)
  local drawLotteryCfg = self:GetBaoKuDrawLotteryCfg(index)
  if drawLotteryCfg == nil then
    return 0
  end
  local lotteryCfgId = drawLotteryCfg.lotteryCfgId
  return lotteryCfgId
end
def.method("=>", "boolean").CanBuyMultiLotterys = function(self)
  local index = self:GetCurBuyIndex()
  local cfg = self:GetLotteryDrawAwardCfg(index)
  if index >= cfg.count then
    return true
  else
    return false
  end
end
def.method("=>", "number").GetExchangeItemId = function(self)
  return _G.constant.BaoKuConsts.exchangeCostItemId
end
def.method("=>", "number").GetExchangeItemCount = function(self)
  local itemType = ItemType.BAO_KU_EXCHANGE_ITEM
  local count = ItemModule.Instance():GetNumByItemType(ItemModule.BAG, itemType)
  return count
end
def.method("number", "=>", "boolean").CheckExchangeItemEnough = function(self, buyNum)
  local count = self:GetExchangeItemCount()
  local need_num = self:GetNeededExchangeItemNum(buyNum)
  return count >= need_num
end
def.method("number", "=>", "number").GetNeededExchangeItemNum = function(self, buyNum)
  local lotteryItemInfo = self:GetExchangeLotteryInfo().lotteryItemInfo
  local once_cost_num = lotteryItemInfo.costCurrencyNum
  local need_num = 0
  if buyNum == BUY_ONE_TIMES then
    need_num = once_cost_num
  else
    need_num = require("Common.MathHelper").Floor(once_cost_num * buyNum * self:GetBaoKuDiscount())
  end
  return need_num
end
def.method("=>", "table").GetExchangeLotteryInfo = function(self)
  local index = _G.constant.BaoKuConsts.exchangeIndex
  local lotteryCfgId = self:GetLotteryCfgId(index)
  return self:_GetLotteryInfo(lotteryCfgId)
end
def.method("=>", "table").GetYuanBaoLotteryInfo = function(self)
  local index = _G.constant.BaoKuConsts.yuanBaoIndex
  local lotteryCfgId = self:GetLotteryCfgId(index)
  return self:_GetLotteryInfo(lotteryCfgId)
end
def.method("number", "=>", "table")._GetLotteryInfo = function(self, lotteryCfgId)
  local cfg = self:GetBaoKuLotteryCfg(lotteryCfgId, "all")
  local info = {}
  info.lotteryItemInfo = {
    costCurrencyType = cfg.costCurrencyType,
    costCurrencyNum = cfg.costCurrencyNum
  }
  info.randomItems = cfg.randomItems
  return info
end
def.method("=>", "number").GetTianDiBaoKuActivityId = function(self)
  return _G.constant.BaoKuConsts.miBaoActivityId
end
def.method("=>", "number").GetBaoKuDiscount = function(self)
  local onSaleValue = _G.constant.BaoKuConsts.onSaleValue or 9000
  local onSaleBase = _G.constant.BaoKuConsts.onSaleBase or 10000
  return onSaleValue / onSaleBase
end
def.method("=>", "number").GetBaoKuAheadEndDays = function(self)
  return _G.constant.BaoKuConsts.banBuyDays
end
def.method("=>", "number").GetBaoKuAheadEndTime = function(self)
  local ONE_DAY_SECONDS = 86400
  local activityId = LotteryAwardMgr.Instance():GetTianDiBaoKuActivityId()
  local beginTime, _, endTime = ActivityInterface.Instance():getActivityStatusChangeTime(activityId)
  local aheadEndSeconds = self:GetBaoKuAheadEndDays() * ONE_DAY_SECONDS
  local aheadEndTime = endTime - aheadEndSeconds
  return aheadEndTime
end
def.method("=>", "boolean").HasNotify = function(self)
  if self.m_info == nil then
    return false
  end
  local cfgId = self:GetCurLotteryCfgId()
  if cfgId == 0 then
    return false
  end
  local record = DynamicData.GetRecord(CFG_PATH.DATA_BAOKU_LOTTERY_CFG, cfgId)
  if record == nil then
    warn("GetBaoKuLotteryCfg(" .. id .. ") return nil")
    return false
  end
  local curTime = _G.GetServerTime()
  local aheadEndTime = self:GetBaoKuAheadEndTime()
  local lapseTime = 5
  if aheadEndTime <= curTime + lapseTime then
    return false
  end
  local costCurrencyType = record:GetIntValue("costCurrencyType")
  if costCurrencyType == CurrencyType.FREE then
    return true
  end
  return false
end
def.method("=>", "number").GetLeftFreeTimes = function(self)
  local allCfg = self:GetAllBaoKuDrawLotteryCfgs()
  local buyIndex = self:GetCurBuyIndex()
  local count = #allCfg
  local times = 0
  for i = buyIndex, count do
    local cfg = allCfg[i]
    if cfg == nil then
      break
    end
    local lotteryCfg = self:GetBaoKuLotteryCfg(cfg.lotteryCfgId, "basic")
    if lotteryCfg.costCurrencyType == CurrencyType.FREE then
      times = times + 1
    else
      break
    end
  end
  return times
end
def.method("userdata", "number").BuyLotterys = function(self, currencyHaveNum, times)
  self:BuyLotterysEx(currencyHaveNum, times, nil)
end
def.method("userdata", "number", "table").BuyLotterysEx = function(self, currencyHaveNum, times, extra)
  extra = extra or {}
  local is_use_yuan_bao = extra.useType or LotteryAwardMgr.NOT_USE_YUAN_BAO
  local item_price = extra.item_price or 0
  local client_need_yuan_bao = 0
  local buyIndex = self:GetCurBuyIndex()
  if self:IsForceUseExchangeItem() or self:CheckExchangeItemEnough(times) then
    local lotteryItemInfo = self:GetLotteryInfo().lotteryItemInfo
    if times == BUY_TEN_TIMES or lotteryItemInfo.costCurrencyType ~= CurrencyType.FREE then
      buyIndex = _G.constant.BaoKuConsts.exchangeIndex
      currencyHaveNum = Int64.new(self:GetExchangeItemCount())
    end
    local need_num = self:GetNeededExchangeItemNum(times)
    local lackNum = math.max(0, need_num - currencyHaveNum:ToNumber())
    client_need_yuan_bao = lackNum * item_price
  elseif times == BUY_TEN_TIMES then
    buyIndex = _G.constant.BaoKuConsts.yuanBaoIndex
  end
  print("CBuyMiBao", currencyHaveNum, buyIndex, times, is_use_yuan_bao, client_need_yuan_bao)
  local p = require("netio.protocol.mzm.gsp.mibao.CBuyMiBao").new(currencyHaveNum, buyIndex, times, is_use_yuan_bao, client_need_yuan_bao)
  gmodule.network.sendProtocol(p)
end
def.method().CMiBaoAwardFinish = function(self)
  print("CMiBaoAwardFinish")
  local p = require("netio.protocol.mzm.gsp.mibao.CMiBaoAwardFinish").new()
  gmodule.network.sendProtocol(p)
end
def.method().CGetMiBaoInfo = function(self)
  print("CGetMiBaoInfo")
  local p = require("netio.protocol.mzm.gsp.mibao.CGetMiBaoInfo").new()
  gmodule.network.sendProtocol(p)
end
def.method("number", "number").ExchangeCreditScore = function(self, exchange_cfgId, times)
  print("ExchangeCreditScore.." .. exchange_cfgId)
  local current_score_num = self:GetCreditScore()
  local p = require("netio.protocol.mzm.gsp.mibao.CExchangeScore").new(exchange_cfgId, current_score_num, times)
  gmodule.network.sendProtocol(p)
end
def.method("=>", "table").GetAllLotteryExchangeItems = function(self)
  local occupation = require("consts.mzm.gsp.occupation.confbean.SOccupationEnum")
  local gender = require("consts.mzm.gsp.occupation.confbean.SGenderEnum")
  local cfgs = self:GetAllLotteryExchangeCfgs()
  local items = {}
  for i, v in ipairs(cfgs) do
    local awardId = v.awardId
    local key = string.format("%d_%d_%d", awardId, occupation.ALL, gender.ALL)
    local cfg = ItemUtils.GetGiftAwardCfg(key)
    local itemList = ItemUtils.GetAwardItemsFromAwardCfg(cfg)
    if itemList and itemList[1] then
      local itemInfo = {
        scoreValue = v.scoreValue
      }
      itemInfo.cfgId = v.cfgId
      itemInfo.itemList = itemList
      table.insert(items, itemInfo)
    end
  end
  return items
end
def.method("number", "=>", "table").GetLotteryAwardCfg = function(self, id)
  local record = DynamicData.GetRecord(CFG_PATH.DATA_MIBAO_LOTTERY_CFG, id)
  if record == nil then
    warn("GetLotteryAwardCfg(" .. id .. ") return nil")
    return nil
  end
  local cfg = {}
  cfg.id = id
  cfg.itemId = record:GetIntValue("itemId")
  cfg.itemNum = record:GetIntValue("itemNum")
  cfg.costCurrencyType = record:GetIntValue("costCurrencyType")
  cfg.costCurrencyNum = record:GetIntValue("costCurrencyNum")
  cfg.randomItems = {}
  local itemsStruct = record:GetStructValue("randomItemIdsStruct")
  local size = itemsStruct:GetVectorSize("randomItemIdsVector")
  for i = 0, size - 1 do
    local vectorRow = itemsStruct:GetVectorValueByIdx("randomItemIdsVector", i)
    local row = {}
    row.id = vectorRow:GetIntValue("itemId")
    row.num = 1
    cfg.randomItems[i + 1] = row
  end
  return cfg
end
def.method("number", "=>", "table").GetLotteryDrawAwardCfg = function(self, indexId)
  local entries = DynamicData.GetTable(CFG_PATH.DATA_MIBAO_DRAW_LOTTERY_CFG)
  local count = DynamicDataTable.GetRecordsCount(entries)
  local index = indexId
  if count < index then
    index = count
  end
  local record = DynamicData.GetRecord(CFG_PATH.DATA_MIBAO_DRAW_LOTTERY_CFG, index)
  if record == nil then
    warn("GetLotteryDrawAwardCfg(" .. indexId .. ") return nil")
    return nil
  end
  local cfg = {}
  cfg.count = count
  cfg.lotteryCfgId = record:GetIntValue("lotteryCfgId")
  return cfg
end
def.method("number", "string", "=>", "table").GetBaoKuLotteryCfg = function(self, id, parts)
  local record = DynamicData.GetRecord(CFG_PATH.DATA_BAOKU_LOTTERY_CFG, id)
  if record == nil then
    warn("GetBaoKuLotteryCfg(" .. id .. ") return nil")
    return nil
  end
  return self:_GetBaoKuLotteryCfg(record, parts)
end
def.method("string", "=>", "table").GetAllBaoKuLotteryCfg = function(self, parts)
  local entries = DynamicData.GetTable(CFG_PATH.DATA_BAOKU_LOTTERY_CFG)
  local count = DynamicDataTable.GetRecordsCount(entries)
  local cfgs = {}
  for i = 0, count - 1 do
    local record = DynamicDataTable.GetRecordByIdx(entries, i)
    local cfg = self:_GetBaoKuLotteryCfg(record, parts)
    cfgs[i + 1] = cfg
  end
  return cfgs
end
def.method("userdata", "string", "=>", "table")._GetBaoKuLotteryCfg = function(self, record, parts)
  local cfg = {}
  cfg.id = record:GetIntValue("id")
  cfg.costCurrencyType = record:GetIntValue("costCurrencyType")
  cfg.costCurrencyNum = record:GetIntValue("costCurrencyNum")
  cfg.awardPoolLotteryCfgId = record:GetIntValue("awardPoolLotteryCfgId")
  if parts == "all" then
    cfg.randomItems = {}
    local viewCfg = ItemUtils.GetLotteryViewRandomCfg(cfg.awardPoolLotteryCfgId)
    for i, itemId in ipairs(viewCfg.itemIds) do
      local itemInfo = {}
      itemInfo.id = itemId
      itemInfo.num = 1
      table.insert(cfg.randomItems, itemInfo)
    end
    local cellColorListStruct = record:GetStructValue("cellColorListStruct")
    local size = cellColorListStruct:GetVectorSize("cellColorList")
    for i = 0, size - 1 do
      local vectorRow = cellColorListStruct:GetVectorValueByIdx("cellColorList", i)
      local color = vectorRow:GetIntValue("color")
      local itemInfo = cfg.randomItems[i + 1]
      if itemInfo then
        itemInfo.color = color
      end
    end
    local cellStateListStruct = record:GetStructValue("cellStateListStruct")
    local size = cellStateListStruct:GetVectorSize("cellStateList")
    for i = 0, size - 1 do
      local vectorRow = cellStateListStruct:GetVectorValueByIdx("cellStateList", i)
      local state = vectorRow:GetIntValue("state")
      local itemInfo = cfg.randomItems[i + 1]
      if itemInfo then
        itemInfo.state = state
      end
    end
  end
  return cfg
end
def.method("number", "=>", "table").GetBaoKuDrawLotteryCfg = function(self, indexId)
  local entries = DynamicData.GetTable(CFG_PATH.DATA_BAOKU_DRAW_LOTTERY_CFG)
  local count = DynamicDataTable.GetRecordsCount(entries)
  local index = indexId
  if count < index then
    index = count
  end
  local record = DynamicData.GetRecord(CFG_PATH.DATA_BAOKU_DRAW_LOTTERY_CFG, index)
  if record == nil then
    warn("GetBaoKuDrawLotteryCfg(" .. indexId .. ") return nil")
    return nil
  end
  local cfg = self:_GetBaoKuDrawLotteryCfg(record)
  cfg.count = count
  return cfg
end
def.method("=>", "table").GetAllBaoKuDrawLotteryCfgs = function(self)
  local entries = DynamicData.GetTable(CFG_PATH.DATA_BAOKU_DRAW_LOTTERY_CFG)
  local count = DynamicDataTable.GetRecordsCount(entries)
  local cfgs = {}
  for i = 0, count - 1 do
    local record = DynamicDataTable.GetRecordByIdx(entries, i)
    local cfg = self:_GetBaoKuDrawLotteryCfg(record)
    cfgs[cfg.indexId] = cfg
  end
  return cfgs
end
def.method("userdata", "=>", "table")._GetBaoKuDrawLotteryCfg = function(self, record)
  local cfg = {}
  cfg.indexId = record:GetIntValue("indexId")
  cfg.lotteryCfgId = record:GetIntValue("lotteryCfgId")
  return cfg
end
def.method("=>", "table").GetAllLotteryExchangeCfgs = function(self)
  local entries = DynamicData.GetTable(CFG_PATH.DATA_MIBAO_SCORE_CFG)
  local count = DynamicDataTable.GetRecordsCount(entries)
  local cfgs = {}
  for i = 0, count - 1 do
    local record = DynamicDataTable.GetRecordByIdx(entries, i)
    local cfg = {}
    cfg.cfgId = record:GetIntValue("cfgId") or 0
    cfg.scoreValue = record:GetIntValue("scoreValue")
    cfg.awardId = record:GetIntValue("awardId")
    cfg.index = record:GetIntValue("index") or 0
    cfgs[i + 1] = cfg
  end
  table.sort(cfgs, function(l, r)
    if l.index ~= r.index then
      return l.index > r.index
    else
      return l.cfgId < r.cfgId
    end
  end)
  return cfgs
end
def.method().InitActivityInfo = function(self)
  self.m_info = {}
  self.m_info.luckyPoint = 0
  self.m_info.creditScore = 0
  self.m_info.curIndex = 1
end
def.method().ResetActivityInfo = function(self)
  if self.m_info == nil then
    return
  end
  self.m_info.curIndex = 1
  Event.DispatchEvent(ModuleId.AWARD, gmodule.notifyId.Award.LOTTERY_AWARD_UPDATE, nil)
end
def.method().CheckAndShowBaoKuEntry = function(self)
  if self:IsActivityOpen() then
    self:ShowBaoKuEntry(true)
  end
end
def.method("=>", "boolean").IsActivityOpen = function(self)
  local activityId = self:GetTianDiBaoKuActivityId()
  if not ActivityInterface.Instance():isActivityOpend(activityId) then
    return false
  end
  if not FeatureOpenListModule.Instance():CheckFeatureOpen(myFeature) then
    return false
  end
  return true
end
def.method("=>", "boolean").CheckActivityOpenAndToast = function(self)
  if self:IsActivityOpen() then
    return true
  end
  Toast(textRes.activity[270])
  return false
end
def.method("boolean").ShowBaoKuEntry = function(self, isShow)
  local TianDiBaoKuEntry = require("Main.activity.TianDiBaoKu.ui.TianDiBaoKuEntry")
  if isShow then
    TianDiBaoKuEntry.Instance():ShowEntry()
  else
    TianDiBaoKuEntry.Instance():HideEntry()
  end
end
def.method("=>", "boolean").OpenBaoKuPanel = function(self)
  if self:CheckActivityOpenAndToast() then
    require("ProxySDK.ECMSDK").SendTLogToServer(_G.TLOGTYPE.BAOKU, {})
    require("Main.activity.TianDiBaoKu.ui.TianDiBaoKuPanel").Instance():ShowPanel()
    return true
  end
  return false
end
def.static("table", "table").OnEnterWorld = function(...)
end
def.static("table", "table").OnLeaveWorld = function(...)
  instance.m_info = nil
end
def.static("table", "table").OnActivityStart = function(params)
  local activityId = params and params[1] or 0
  if activityId ~= _G.constant.BaoKuConsts.miBaoActivityId then
    return
  end
  instance:InitActivityInfo()
  if _G.IsEnteredWorld() then
    instance:CheckAndShowBaoKuEntry()
  end
end
def.static("table", "table").OnActivityRest = function(params)
  local activityId = params and params[1] or 0
  if activityId ~= _G.constant.BaoKuConsts.miBaoActivityId then
    return
  end
  instance:ResetActivityInfo()
end
def.static("table", "table").OnActivityClose = function(params)
  local activityId = params and params[1] or 0
  if activityId ~= _G.constant.BaoKuConsts.miBaoActivityId then
    return
  end
  instance:ShowBaoKuEntry(false)
end
def.static("table", "table").OnFunctionOpenInit = function(params)
  instance:CheckAndShowBaoKuEntry()
end
def.static("table", "table").OnFunctionOpenChange = function(params)
  if myFeature ~= params.feature then
    return
  end
  if params.open then
    instance:CheckAndShowBaoKuEntry()
  else
    instance:ShowBaoKuEntry(false)
  end
end
def.static("table").OnSBuyMiBaoSuccess = function(p)
  print("OnSBuyMiBaoSuccess #p.random_item_map", #p.random_item_map)
  local lastCreditScore = instance.m_info.creditScore
  instance.m_info.luckyPoint = p.current_lucky_value
  instance.m_info.creditScore = p.current_score
  instance.m_info.curIndex = p.current_mibao_index_id
  local random_item_list = {}
  for i, v in ipairs(p.random_item_map) do
    local info = {
      id = v.itemId,
      num = v.itemNum
    }
    random_item_list[#random_item_list + 1] = info
  end
  Event.DispatchEvent(ModuleId.AWARD, gmodule.notifyId.Award.LOTTERY_AWARD_UPDATE, {random_item_list = random_item_list})
  local addCreditScore = p.current_score - lastCreditScore
  if addCreditScore > 0 then
    local text = string.format(textRes.Mibao[12], addCreditScore)
    Toast(text)
  end
end
def.static("table").OnSBuyMiBaoFail = function(p)
  local text = textRes.Mibao.SBuyMiBaoFail[p.result]
  Event.DispatchEvent(ModuleId.AWARD, gmodule.notifyId.Award.DRAW_MIBAO_FAILED, {
    result = p.result
  })
  if text then
    Toast(text)
  end
end
def.static("table").OnSGetMiBaoInfo = function(p)
  print("OnSGetMiBaoInfo", p.current_lucky_value, p.current_score, p.current_mibao_index_id)
  instance.m_info = {}
  instance.m_info.luckyPoint = p.current_lucky_value
  instance.m_info.creditScore = p.current_score
  instance.m_info.curIndex = p.current_mibao_index_id
  Event.DispatchEvent(ModuleId.AWARD, gmodule.notifyId.Award.LOTTERY_AWARD_UPDATE, nil)
end
def.static("table").OnSExchangeScoreSuccess = function(p)
  print("OnSExchangeScoreSuccess p.current_score_num", p.current_score_num)
  instance.m_info.creditScore = p.current_score_num
  Event.DispatchEvent(ModuleId.AWARD, gmodule.notifyId.Award.EXCHANGE_LOTTERY_SCORE_SUCCESS, nil)
  Event.DispatchEvent(ModuleId.AWARD, gmodule.notifyId.Award.LOTTERY_AWARD_UPDATE, nil)
end
def.static("table").OnSExchangeScoreFail = function(p)
  if textRes.Mibao.SExchangeScoreFail[p.result] then
    Toast(textRes.Mibao.SExchangeScoreFail[p.result])
  else
    Toast(string.format(textRes.Mibao.SExchangeScoreFail[0], p.result))
  end
end
return LotteryAwardMgr.Commit()
