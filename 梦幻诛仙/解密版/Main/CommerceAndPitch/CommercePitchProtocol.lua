local MODULE_NAME = (...)
local Lplus = require("Lplus")
local CommercePitchProtocol = Lplus.Class(MODULE_NAME)
local CommercePitchModule = Lplus.ForwardDeclare("CommercePitchModule")
local PitchData = require("Main.CommerceAndPitch.data.PitchData")
local CommercePitchUtils = require("Main.CommerceAndPitch.CommercePitchUtils")
local def = CommercePitchProtocol.define
local instance
local pageReqMap = {}
local __Debug = false
local gmodule = gmodule
local __gmodule = gmodule
local GameUtil = GameUtil
if __Debug then
  gmodule = {
    network = {}
  }
  function gmodule.network.sendProtocol(p)
    warn("fake sendProtocol " .. p.__cname, debug.traceback())
  end
  gmodule.network.registerProtocol = __gmodule.network.registerProtocol
end
def.static().Init = function()
  gmodule.network.registerProtocol("netio.protocol.mzm.gsp.baitan.SQueryShopingListRes", CommercePitchProtocol.OnSQueryShopingListRes)
  gmodule.network.registerProtocol("netio.protocol.mzm.gsp.baitan.SRefreshShopingListRes", CommercePitchProtocol.OnSRefreshShopingListRes)
  gmodule.network.registerProtocol("netio.protocol.mzm.gsp.baitan.SQueryBaitanItemRes", CommercePitchProtocol.OnSQueryBaitanItemRes)
  Event.RegisterEvent(ModuleId.LOGIN, gmodule.notifyId.Login.LEAVE_WORLD, CommercePitchProtocol.OnReset)
end
def.static("table", "table").OnReset = function()
  pageReqMap = {}
end
def.static("number", "number", "number", "boolean").RecordPage = function(subType, pageIndex, param, isSet)
  local key = string.format("%d_%d_%d", subType, pageIndex, param)
  pageReqMap[key] = isSet
end
def.static("number", "number", "number", "=>", "boolean").IsPageRecord = function(subType, pageIndex, param)
  local key = string.format("%d_%d_%d", subType, pageIndex, param)
  return pageReqMap[key] and true or false
end
def.static("table").OnSynLastFreshTimeRes = function(p)
  local instance = CommercePitchModule.Instance()
  local data = instance._pitchData
  local lastFreeTime = Int64.ToNumber(p.lastFreshTime)
  local curTime = GetServerTime()
  data:SetLastFreeRefeshTime(lastFreeTime)
  local freeTime = curTime - lastFreeTime
  if freeTime >= CommercePitchUtils.GetPitchFreeRefeshTime() then
    data:SetIsFreeRefesh(true)
  else
    data:SetIsFreeRefesh(false)
  end
end
def.static("table").OnSQueryBaitanItemRes = function(p)
  CommercePitchProtocol.RecordPage(p.pageresult.subtype, p.pageresult.pageindex, p.pageresult.param, false)
  local instance = CommercePitchModule.Instance()
  local data = instance._pitchData
  local isReset = data:SetPageInfoToShoppingList(p.pageresult)
  Event.DispatchEvent(ModuleId.COMMERCEANDPITCH, gmodule.notifyId.CommerceAndPitch.QUERY_BAITAN_PAGE_ITEMS_RES, {
    p.pageresult.subtype,
    isReset
  })
end
def.static("table").OnSRefreshShopingListRes = function(p)
  local instance = CommercePitchModule.Instance()
  local bShow = false
  if 0 == PitchData.Instance():GetLastAutoRefeshTime() and false == PitchData.Instance():GetOnceFinished() and instance._bWaitToShow then
    bShow = true
  end
  local data = instance._pitchData
  local curTime = GetServerTime()
  data:SetLastFreeRefeshTime(Int64.ToNumber(p.lastFreshTime))
  data:ClearShoppingList()
  data:SetPageInfoToShoppingList(p.pageresult)
  if false == data:GetIsAutoRefesh() then
    if p.costGold == 0 then
      Toast(textRes.Pitch[14])
    else
      local PersonalHelper = require("Main.Chat.PersonalHelper")
      PersonalHelper.CommonMsg(PersonalHelper.Type.ColorText, textRes.Pitch[50], "ffffff", PersonalHelper.Type.Gold, p.costGold, PersonalHelper.Type.ColorText, textRes.Pitch[51], "ffffff")
    end
  end
  data:SetIsAutoRefesh(false)
  if 0 == Int64.ToNumber(p.lastFreshTime) then
    data:SetIsFreeRefesh(false)
  end
  data:SetOnceFinished(true)
  local lastFreeTime = instance._pitchData:GetLastFreeRefeshTime()
  local freeTime = curTime - lastFreeTime
  if freeTime >= CommercePitchUtils.GetPitchFreeRefeshTime() then
    instance._pitchData:SetIsFreeRefesh(true)
  else
    instance._pitchData:SetIsFreeRefesh(false)
  end
  if instance._dlg and instance._dlg.m_panel and false == instance._dlg.m_panel.isnil and instance._dlg.m_panel:get_activeInHierarchy() then
    instance._dlg:UpdatePitchTimeLabel()
  end
  if bShow then
    local CommercePitchPanel = require("Main.CommerceAndPitch.ui.CommercePitchPanel")
    CommercePitchPanel.ShowCommercePitchPanel(CommercePitchModule.Instance().waitToShowState)
    instance._bWaitToShow = false
  elseif instance._dlg and instance._dlg.m_panel and false == instance._dlg.m_panel.isnil and instance._dlg.m_panel:get_activeInHierarchy() then
    instance._dlg:UpdatePitchShoppingList()
  end
end
def.static("table").OnSQueryShopingListRes = function(p)
  CommercePitchProtocol.RecordPage(p.pageresult.subtype, p.pageresult.pageindex, p.pageresult.param, false)
  local instance = CommercePitchModule.Instance()
  local data = instance._pitchData
  data:SetLastFreeRefeshTime(Int64.ToNumber(p.lastFreshTime))
  data:SetPageInfoToShoppingList(p.pageresult)
  if 0 == Int64.ToNumber(p.lastFreshTime) then
    data:SetIsFreeRefesh(false)
  end
  data:SetOnceFinished(true)
  data:SetIsSyncShoppingList(true)
  local lastFreeTime = instance._pitchData:GetLastFreeRefeshTime()
  local curTime = GetServerTime()
  local freeTime = curTime - lastFreeTime
  if freeTime >= CommercePitchUtils.GetPitchFreeRefeshTime() then
    instance._pitchData:SetIsFreeRefesh(true)
  else
    instance._pitchData:SetIsFreeRefesh(false)
  end
  local isReset = false
  Event.DispatchEvent(ModuleId.COMMERCEANDPITCH, gmodule.notifyId.CommerceAndPitch.QUERY_BAITAN_PAGE_ITEMS_RES, {
    p.pageresult.subtype,
    isReset
  })
  if instance._dlg and instance._dlg.m_panel and false == instance._dlg.m_panel.isnil and instance._dlg.m_panel:get_activeInHierarchy() then
    instance._dlg:TimeToRefeshPitch()
  end
  if data:CanFreeRefresh() then
    data:SetIsAutoRefesh(true)
    CommercePitchProtocol.CFreeRefreshShopingListReq(p.pageresult.subtype, 0)
  end
end
def.static("number", "number").CQueryShopingListReq = function(subType, param)
  local p = require("netio.protocol.mzm.gsp.baitan.CQueryShopingListReq").new(subType, param)
  gmodule.network.sendProtocol(p)
  CommercePitchProtocol.RecordPage(subType, 1, param, true)
end
def.static("number", "number", "number").CQueryBaitanItemReq = function(pageIndex, subType, param)
  if CommercePitchProtocol.IsPageRecord(subType, pageIndex, param) then
    return
  end
  local p = require("netio.protocol.mzm.gsp.baitan.CQueryBaitanItemReq").new(pageIndex, param, subType)
  gmodule.network.sendProtocol(p)
  CommercePitchProtocol.RecordPage(subType, pageIndex, param, true)
end
def.static("number", "number", "number", "number").CQueryItemReq = function(index, itemid, num, price)
  local p = require("netio.protocol.mzm.gsp.baitan.CQueryItemReq").new(index, itemid, num, price)
  gmodule.network.sendProtocol(p)
end
def.static("number", "number", "number", "number").CBuyItemReq = function(index, itemid, num, price)
  local p = require("netio.protocol.mzm.gsp.baitan.CBuyItemReq").new(index, itemid, num, price)
  gmodule.network.sendProtocol(p)
end
def.static("number", "number").CFreeRefreshShopingListReq = function(subType, param)
  local p = require("netio.protocol.mzm.gsp.baitan.CFreeRefreshShopingListReq").new(subType, param)
  gmodule.network.sendProtocol(p)
end
def.static("number", "number").CGoldRefreshShopingListReq = function(subtype, param)
  local p = require("netio.protocol.mzm.gsp.baitan.CGoldRefreshShopingListReq").new(subtype, param)
  gmodule.network.sendProtocol(p)
end
def.static("number", "number", "number", "number", "number").CSellItemReq = function(bagId, itemKey, itemid, price, num)
  PitchData.Instance().itemPriceRecord[itemid] = price
  local p = require("netio.protocol.mzm.gsp.baitan.CSellItemReq").new(bagId, itemKey, itemid, price, num)
  gmodule.network.sendProtocol(p)
end
def.static("number", "number", "number", "number").CWuQIFuVigorSellReq = function(skillBagId, itemId, price, num)
  PitchData.Instance().itemPriceRecord[itemId] = price
  local p = require("netio.protocol.mzm.gsp.baitan.CWuQIFuVigorSellReq").new(skillBagId, itemId, price, num)
  gmodule.network.sendProtocol(p)
end
def.static("number", "number", "number", "number").CFuMoSkillVigorSellReq = function(skillId, skillBagId, price, num)
  local p = require("netio.protocol.mzm.gsp.baitan.CFuMoSkillVigorSellReq").new(skillId, skillBagId, price, num)
  gmodule.network.sendProtocol(p)
end
def.static("userdata", "number").CGetSellItemReq = function(shoppingid, itemid)
  local p = require("netio.protocol.mzm.gsp.baitan.CGetSellItemReq").new(shoppingid, itemid)
  gmodule.network.sendProtocol(p)
end
def.static("userdata", "number", "number").CReSellExpireItemReq = function(shoppingid, itemid, price)
  PitchData.Instance().itemPriceRecord[itemid] = price
  local p = require("netio.protocol.mzm.gsp.baitan.CReSellExpireItemReq").new(shoppingid, itemid, price)
  gmodule.network.sendProtocol(p)
end
def.static("userdata", "number").CGetMoneyReq = function(shoppingid, itemid)
  local p = require("netio.protocol.mzm.gsp.baitan.CGetMoneyReq").new(shoppingid, itemid)
  gmodule.network.sendProtocol(p)
end
def.static().CAutoGetMoneyReq = function()
  local p = require("netio.protocol.mzm.gsp.baitan.CAutoGetMoneyReq").new()
  gmodule.network.sendProtocol(p)
end
def.static("table").CRecommendPriceChangeReq = function(itemIdList)
  local idList = {}
  local idMap = {}
  for i, id in ipairs(itemIdList) do
    if idMap[id] == nil then
      table.insert(idList, id)
      idMap[id] = id
    end
  end
  local p = require("netio.protocol.mzm.gsp.baitan.CRecommendPriceChangeReq").new(idList)
  gmodule.network.sendProtocol(p)
end
def.static().CUnlockGridReq = function()
  local ItemModule = require("Main.Item.ItemModule")
  local yuanbao = ItemModule.Instance():GetAllYuanBao()
  local p = require("netio.protocol.mzm.gsp.baitan.CUnlockGridReq").new(yuanbao)
  gmodule.network.sendProtocol(p)
end
return CommercePitchProtocol.Commit()
