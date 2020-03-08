local Lplus = require("Lplus")
local ModuleBase = require("Main.module.ModuleBase")
local ItemUtils = require("Main.Item.ItemUtils")
local LotteryPanel = require("Main.Lottery.ui.LotteryPanel")
local LotteryType = require("consts.mzm.gsp.item.confbean.LotteryType")
local ItemModule = require("Main.Item.ItemModule")
local PersonalHelper = require("Main.Chat.PersonalHelper")
local PetData = require("Main.Pet.data.PetData")
local LotteryModule = Lplus.Extend(ModuleBase, "LotteryModule")
local def = LotteryModule.define
local instance
def.field("number").lotteryItemId = -1
def.field("table").finalId2Num = nil
def.field("number").expType = 0
def.field("number").expNum = 0
def.field("number").moneyType = 0
def.field("number").moneyNum = 0
def.field("number").lotteryType = -1
def.field("boolean").isLotteryItem = true
def.const("boolean").isDebugging = false
def.static("=>", LotteryModule).Instance = function()
  if instance == nil then
    instance = LotteryModule()
    instance.m_moduleId = ModuleId.LOTTERY
  end
  return instance
end
def.override().Init = function(self)
  gmodule.network.registerProtocol("netio.protocol.mzm.gsp.item.SResUseNormalLottery", LotteryModule.OnSResUseNormalLottery)
  gmodule.network.registerProtocol("netio.protocol.mzm.gsp.item.SResUseTurntableItemLottery", LotteryModule.OnSResUseTurntableItemLottery)
  gmodule.network.registerProtocol("netio.protocol.mzm.gsp.item.SResUseTurntableTypeLottery", LotteryModule.OnSResUseTurntableTypeLottery)
  gmodule.network.registerProtocol("netio.protocol.mzm.gsp.item.SLotteryViewRandomResult", LotteryModule.OnSLotteryViewRandomResult)
  Event.RegisterEvent(ModuleId.LOGIN, gmodule.notifyId.Login.LEAVE_WORLD, function()
    self:Reset()
  end)
  Event.RegisterEvent(ModuleId.LOTTERY, gmodule.notifyId.Lottery.LOTTERY_USE, LotteryModule.OnLotteryUse)
  ModuleBase.Init(self)
  if LotteryModule.isDebugging then
    LotteryPanel.Instance():ShowPanel(1)
  end
end
def.static("table", "table").OnLotteryUse = function(params, context)
  local item = ItemModule.Instance():GetItemByBagIdAndItemKey(params.bagId, params.itemKey)
  if item == nil then
    return
  end
  local p = require("netio.protocol.mzm.gsp.item.CUseLotteryItem").new(item.uuid[1], 0)
  gmodule.network.sendProtocol(p)
end
def.method().NotifyLotteryFinished = function(self)
  local p = require("netio.protocol.mzm.gsp.item.CUseLotteryItemFinish").new()
  if not self.isLotteryItem then
    p = require("netio.protocol.mzm.gsp.item.CLotteryAwardFinish").new()
  end
  gmodule.network.sendProtocol(p)
end
def.method("number", "number").FillOneItem = function(self, id, num)
  if id > 0 and num > 0 then
    self.finalId2Num = {}
    self.finalId2Num[id] = num
  else
    self.finalId2Num = nil
  end
end
def.static("table").OnSResUseNormalLottery = function(p)
  LotteryModule.Instance().lotteryItemId = p.lotteryItemid
  LotteryModule.Instance().finalId2Num = p.finalItemid2num
  LotteryModule.Instance().lotteryType = LotteryType.NORMAL
  LotteryModule.Instance().isLotteryItem = true
  LotteryModule.Instance():NotifyItemGet()
end
def.static("table").OnSResUseTurntableItemLottery = function(p)
  LotteryModule.Instance().lotteryItemId = p.lotteryItemid
  LotteryModule.Instance():FillOneItem(p.itemids[p.finalIndex], 1)
  LotteryModule.Instance().lotteryType = LotteryType.TURNTABLE_ITEM
  LotteryModule.Instance().isLotteryItem = true
  local items = {}
  for k, v in pairs(p.itemids) do
    local itemBase = ItemUtils.GetItemBase(v)
    table.insert(items, itemBase)
  end
  LotteryPanel.Instance().lotteryItemId = p.lotteryItemid
  LotteryPanel.Instance().itemList = items
  LotteryPanel.Instance().finalItemIdx = p.finalIndex
  LotteryPanel.Instance():ShowPanel(LotteryPanel.DescType.LOTTERY)
end
def.static("table").OnSResUseTurntableTypeLottery = function(p)
  LotteryModule.Instance().lotteryItemId = p.lotteryItemid
  LotteryModule.Instance().lotteryType = LotteryType.TURNTABLE_TYPE
  LotteryModule.Instance():FillOneItem(p.itemid, p.itemnum)
  LotteryModule.Instance().expType = p.exptype
  LotteryModule.Instance().expNum = p.expnum
  LotteryModule.Instance().moneyType = p.moneytype
  LotteryModule.Instance().moneyNum = p.moneynum
  LotteryModule.Instance().isLotteryItem = true
  local lotteryId = p.lotteryItemid
  local lotteryCfg = ItemUtils.GetLotteryItemCfg(lotteryId)
  local randomItemsCfg = ItemUtils.GetLotteryViewRandomCfg(lotteryCfg.templateId)
  local itemIds = randomItemsCfg.itemIds
  local items = {}
  for k, v in pairs(itemIds) do
    local itemBase = ItemUtils.GetItemBase(v)
    table.insert(items, itemBase)
  end
  LotteryPanel.Instance().lotteryItemId = p.lotteryItemid
  LotteryPanel.Instance().itemList = items
  LotteryPanel.Instance().finalItemIdx = p.finalIndex
  LotteryPanel.Instance():ShowPanel(LotteryPanel.DescType.LOTTERY)
end
def.static("table").OnSLotteryViewRandomResult = function(p)
  LotteryModule.Instance().lotteryType = LotteryType.TURNTABLE_TYPE
  LotteryModule.Instance():FillOneItem(p.itemid, p.itemnum)
  LotteryModule.Instance().isLotteryItem = false
  local randomItemsCfg = ItemUtils.GetLotteryViewRandomCfg(p.lotteryViewid)
  local itemIds = randomItemsCfg.itemIds
  local items = {}
  for k, v in pairs(itemIds) do
    local itemBase = ItemUtils.GetItemBase(v)
    table.insert(items, itemBase)
  end
  LotteryPanel.Instance().itemList = items
  LotteryPanel.Instance().finalItemIdx = p.finalIndex
  LotteryPanel.Instance():ShowPanel(LotteryPanel.DescType.TXHW)
end
def.method().NotifyItemGet = function(self)
  if self.lotteryType == LotteryType.NORMAL then
    if self.finalId2Num and next(self.finalId2Num) then
      PersonalHelper.CommonMsg(PersonalHelper.Type.Text, textRes.Lottery[2], PersonalHelper.Type.ItemMap, self.finalId2Num)
    end
  elseif self.lotteryType == LotteryType.TURNTABLE_ITEM then
    if self.finalId2Num and next(self.finalId2Num) then
      PersonalHelper.CommonMsg(PersonalHelper.Type.Text, textRes.Lottery[2], PersonalHelper.Type.ItemMap, self.finalId2Num)
    end
  elseif self.lotteryType == LotteryType.TURNTABLE_TYPE then
    if self.finalId2Num and next(self.finalId2Num) then
      PersonalHelper.CommonMsg(PersonalHelper.Type.Text, textRes.Lottery[2], PersonalHelper.Type.ItemMap, self.finalId2Num)
    end
    if self.expNum > 0 then
      local ExpType = require("consts.mzm.gsp.item.confbean.ExpType")
      local exp = self.expNum
      if self.expType == ExpType.ROLE_EXP then
        PersonalHelper.CommonMsg(PersonalHelper.Type.Text, textRes.Lottery[2], PersonalHelper.Type.RoleExp, tostring(exp))
      elseif self.expType == ExpType.PET_EXP then
        local pet = self:TryGetPet()
        if pet then
          PersonalHelper.CommonMsg(PersonalHelper.Type.Text, textRes.Lottery[3], PersonalHelper.Type.PetExpMap, {
            [pet.id] = exp
          })
        end
      elseif self.expType == ExpType.XIU_LIAN_EXP then
        PersonalHelper.CommonMsg(PersonalHelper.Type.Text, textRes.Lottery[2], PersonalHelper.Type.XiuLianExp, tostring(exp))
      end
    end
    if 0 < self.moneyNum then
      local MoneyType = require("consts.mzm.gsp.item.confbean.MoneyType")
      local money = self.moneyNum
      if self.moneyType == MoneyType.YUANBAO then
        PersonalHelper.CommonMsg(PersonalHelper.Type.Text, textRes.Lottery[2], PersonalHelper.Type.Yuanbao, Int64.new(money))
      elseif self.moneyType == MoneyType.GOLD then
        PersonalHelper.CommonMsg(PersonalHelper.Type.Text, textRes.Lottery[2], PersonalHelper.Type.Gold, Int64.new(money))
      elseif self.moneyType == MoneyType.SILVER then
        PersonalHelper.CommonMsg(PersonalHelper.Type.Text, textRes.Lottery[2], PersonalHelper.Type.Silver, Int64.new(money))
      elseif self.moneyType == MoneyType.GANGCONTRIBUT then
        PersonalHelper.CommonMsg(PersonalHelper.Type.Text, textRes.Lottery[2], PersonalHelper.Type.Gang, Int64.new(money))
      end
    end
  else
    warn("In LotteryModule->NotifyItemGet():  Wrong Lottery Type")
  end
  self:NotifyLotteryFinished()
  self:Clear()
end
def.method("=>", PetData).TryGetPet = function(self)
  local petMgr = require("Main.Pet.mgr.PetMgr")
  local pet = petMgr.Instance():GetFightingPet()
  pet = pet or petMgr.Instance():GetDisplayPet()
  if not pet then
    local petList = petMgr.Instance():GetPets()
    for k, v in petList, nil, nil do
      if v then
        pet = v
        break
      end
    end
  end
  return pet
end
def.method().Clear = function(self)
  self.lotteryItemId = -1
  self.finalId2Num = nil
  self.expType = 0
  self.expNum = 0
  self.moneyType = 0
  self.moneyNum = 0
  self.lotteryType = -1
  self.isLotteryItem = true
end
def.override().OnReset = function(self)
  self:Clear()
end
return LotteryModule.Commit()
