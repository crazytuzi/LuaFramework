local Lplus = require("Lplus")
local LunhuiTreasureMgr = Lplus.Class("LunhuiTreasureMgr")
local Feature = require("netio.protocol.mzm.gsp.open.ModuleFunSwitchInfo")
local def = LunhuiTreasureMgr.define
local instance
def.static("=>", LunhuiTreasureMgr).Instance = function()
  if not instance then
    instance = LunhuiTreasureMgr()
  end
  return instance
end
def.method().Init = function(self)
  gmodule.network.registerProtocol("netio.protocol.mzm.gsp.floplottery.SFlopLotteryNew", LunhuiTreasureMgr.OnSFlopLotteryNew)
  gmodule.network.registerProtocol("netio.protocol.mzm.gsp.floplottery.SFlopLotteryContinue", LunhuiTreasureMgr.OnSFlopLotteryContinue)
  gmodule.network.registerProtocol("netio.protocol.mzm.gsp.floplottery.SFlopLotteryResult", LunhuiTreasureMgr.OnSFlopLotteryResult)
  gmodule.network.registerProtocol("netio.protocol.mzm.gsp.floplottery.SFlopLotteryError", LunhuiTreasureMgr.OnSFlopLotteryError)
end
def.static("table").OnSFlopLotteryNew = function(p)
  require("Main.Award.ui.LunhuiTreasurePanel").ShowDrawCard(p.uid, p.flopLotteryMainCfgId, {})
end
def.static("table").OnSFlopLotteryContinue = function(p)
  local CommonConfirmDlg = require("GUI.CommonConfirmDlg")
  CommonConfirmDlg.ShowConfirm("", textRes.Award[202], function(sel)
    if sel == 1 then
      local drawInfo = {}
      for k, v in pairs(p.flopLotteryResultList) do
        drawInfo[v.index] = v.awardIdList
      end
      require("Main.Award.ui.LunhuiTreasurePanel").ShowDrawCard(p.uid, p.flopLotteryMainCfgId, drawInfo)
    elseif sel == 0 then
      LunhuiTreasureMgr.Instance():Close(p.uid)
    end
  end, nil)
end
def.static("table").OnSFlopLotteryResult = function(p)
  require("Main.Award.ui.LunhuiTreasurePanel").TurnOver(p.uid, p.flopLotteryResult.index, p.flopLotteryResult.awardIdList)
end
def.static("table").OnSFlopLotteryError = function(p)
  local tips = textRes.Award.SFlopLotteryError[p.code]
  if tips then
    Toast(string.format(tips, unpack(p.params)))
  end
end
def.method("number", "userdata").OpenLunhuiItem = function(self, cfgId, uuid)
  if self:IsOpen(cfgId) then
    gmodule.network.sendProtocol(require("netio.protocol.mzm.gsp.floplottery.CUseFlopLotteryItem").new(uuid))
  end
end
def.method("userdata", "number", "number", "number").Draw = function(self, sessionId, index, count, cfgId)
  if self:IsOpen(cfgId) then
    local cardCfg = self:GetTreasureCfg(cfgId)
    local drawCfg = self:GetDrawCardCfg(cardCfg.typeId)
    if drawCfg == nil or drawCfg[count] == nil then
      return
    end
    local oneDrawCfg = drawCfg[count]
    local moneyType = oneDrawCfg.moneyType
    local moneyCount = oneDrawCfg.moneyCount
    if self:CheckMoneyEnough(moneyType, moneyCount) then
      gmodule.network.sendProtocol(require("netio.protocol.mzm.gsp.floplottery.CFlopLottery").new(sessionId, index, count))
    end
  end
end
def.method("number", "number", "=>", "boolean").CheckMoneyEnough = function(self, moneyType, moneyCount)
  local MoneyType = require("consts.mzm.gsp.item.confbean.MoneyType")
  local ItemModule = require("Main.Item.ItemModule")
  local enough = true
  if moneyType == MoneyType.YUANBAO then
    local yuanbaoNum = ItemModule.Instance():GetAllYuanBao()
    if yuanbaoNum < Int64.new(moneyCount) then
      enough = false
    end
  elseif moneyType == MoneyType.GOLD then
    local goldNum = ItemModule.Instance():GetMoney(ItemModule.MONEY_TYPE_GOLD)
    if goldNum < Int64.new(moneyCount) then
      enough = false
    end
  elseif moneyType == MoneyType.SILVER then
    local silverNum = ItemModule.Instance():GetMoney(ItemModule.MONEY_TYPE_SILVER)
    if silverNum < Int64.new(moneyCount) then
      enough = false
    end
  end
  if not enough then
    Toast(textRes.Award[203])
  end
  return enough
end
def.method("userdata").Close = function(self, sessionId)
  gmodule.network.sendProtocol(require("netio.protocol.mzm.gsp.floplottery.CFlopLotteryExit").new(sessionId))
end
def.method("number", "=>", "boolean").IsOpen = function(self, cfgId)
  local cfg = self:GetTreasureCfg(cfgId)
  if not cfg then
    return false
  end
  local isOpen = IsFeatureOpen(cfg.switchId)
  if isOpen then
    return true
  else
    Toast(textRes.Award[201])
    return false
  end
end
def.method("number", "=>", "table").GetTreasureCfg = function(self, id)
  local record = DynamicData.GetRecord(CFG_PATH.DATA_CFlopLotteryMainCfg, id)
  if record == nil then
    warn("GetTreasureCfg nil", id)
    return nil
  end
  local cfg = {}
  cfg.id = id
  cfg.typeId = record:GetIntValue("typeId")
  cfg.tipId = record:GetIntValue("tipId")
  cfg.switchId = record:GetIntValue("switchId")
  return cfg
end
def.method("number", "=>", "table").GetDrawCardCfg = function(self, id)
  local record = DynamicData.GetRecord(CFG_PATH.DATA_TFlopLotteryAwardPoolCfg, id)
  if record == nil then
    warn("GetDrawCardCfg nil", id)
    return nil
  end
  local drawList = {}
  local drawStruct = record:GetStructValue("drawStruct")
  local drawListSize = DynamicRecord.GetVectorSize(drawStruct, "drawList")
  for i = 0, drawListSize - 1 do
    local rec = DynamicRecord.GetVectorValueByIdx(drawStruct, "drawList", i)
    local index = rec:GetIntValue("index")
    local moneyType = rec:GetIntValue("moneyType")
    local moneyCount = rec:GetIntValue("moneyCount")
    drawList[index] = {moneyType = moneyType, moneyCount = moneyCount}
  end
  return drawList
end
return LunhuiTreasureMgr.Commit()
