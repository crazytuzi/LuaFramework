local Lplus = require("Lplus")
local LJTransformMgr = Lplus.Class("LJTransformMgr")
local FabaoUtils = require("Main.Fabao.FabaoUtils")
local FabaoModule = require("Main.Fabao.FabaoModule")
local ItemModule = require("Main.Item.ItemModule")
local ItemUtils = require("Main.Item.ItemUtils")
local ItemType = require("consts.mzm.gsp.item.confbean.ItemType")
local Feature = require("netio.protocol.mzm.gsp.open.ModuleFunSwitchInfo")
local def = LJTransformMgr.define
def.field("number").m_CurRestTranformNum = 0
def.field("number").m_NpcId = -1
def.field("number").m_ServiceId = -1
local instance
def.static("=>", LJTransformMgr).Instance = function()
  if nil == instance then
    instance = LJTransformMgr()
    instance.m_CurRestTranformNum = 0
    instance.m_ServiceId = -1
    instance.m_NpcId = -1
  end
  return instance
end
def.method().Init = function(self)
  gmodule.network.registerProtocol("netio.protocol.mzm.gsp.fabao.SQueryLongjingRestTransferRes", LJTransformMgr.OnSQueryLongjingRestTransfer)
  gmodule.network.registerProtocol("netio.protocol.mzm.gsp.fabao.SLongjingPropertyTransferRes", LJTransformMgr.OnSLongjingPropertyTransferRes)
  gmodule.network.registerProtocol("netio.protocol.mzm.gsp.fabao.SLongjingPropertyTransferErrorRes", LJTransformMgr.OnSLongjingPropertyTransferErrorRes)
  gmodule.network.registerProtocol("netio.protocol.mzm.gsp.fabao.SQueryLongjingTransferPriceRes", LJTransformMgr.OnSQueryLongjingTransferPriceRes)
  Event.RegisterEvent(ModuleId.NPC, gmodule.notifyId.NPC.NPC_SERVICE, LJTransformMgr.OnNpcService)
  Event.RegisterEvent(ModuleId.LOGIN, gmodule.notifyId.Login.ENTER_WORLD, LJTransformMgr.OnEnterWorld)
  Event.RegisterEvent(ModuleId.LOGIN, gmodule.notifyId.Login.LEAVE_WORLD, LJTransformMgr.OnLeaveWorld)
  Event.RegisterEvent(ModuleId.FEATURE, gmodule.notifyId.Feature.FeatureOpenChange, LJTransformMgr.OnFeatureOpenChange)
  Event.RegisterEvent(ModuleId.FEATURE, gmodule.notifyId.Feature.FeatureOpenInit, LJTransformMgr.OnFeatureOpenInit)
end
def.method("=>", "number").GetRestTransformNum = function(self)
  return self.m_CurRestTranformNum
end
def.method("=>", "table").GetCanTransformLongJingList = function(self)
  local allLongjing = ItemModule.Instance():GetItemsByItemType(ItemModule.BAG, ItemType.FABAO_LONGJING_ITEM)
  local longjingList
  local longjingTransformLevel = FabaoUtils.GetLJTransformNeedLevel()
  if allLongjing then
    for k, v in pairs(allLongjing) do
      if nil == longjingList then
        longjingList = {}
      end
      local longjingBase = ItemUtils.GetLongJingItem(v.id)
      local longjingItemBase = ItemUtils.GetItemBase(v.id)
      local longjingLevel = longjingBase.lv
      if longjingTransformLevel <= longjingLevel then
        local longjing = {}
        longjing.id = v.id
        longjing.uuid = v.uuid[1]
        longjing.num = v.number
        longjing.name = longjingItemBase.name
        longjing.iconId = longjingItemBase.icon
        longjing.attrId = longjingBase.attrIds[1]
        longjing.attrName = FabaoUtils.GetFabaoProName(longjing.attrId)
        longjing.attrValue = longjingBase.attrValues[1]
        longjing.typeName = longjingItemBase.itemTypeName
        longjing.level = longjingLevel
        table.insert(longjingList, longjing)
      end
    end
  end
  if longjingList then
    table.sort(longjingList, function(a, b)
      return a.id < b.id
    end)
  end
  return longjingList
end
def.static("table", "table").OnFeatureOpenChange = function(p1, p2)
  local featureType = p1.feature
  local isOpen = p1.open
  if featureType == Feature.TYPE_LONGJING_TRANSFER then
    local npcId, serviceId = FabaoUtils.GetLJTranformNpcIdAndServiceId()
    Event.DispatchEvent(ModuleId.PUBROLE, gmodule.notifyId.Pubrole.SET_NPC_ENABLE, {npcid = npcId, show = isOpen})
    if isOpen then
      LJTransformMgr.CQueryLJTransformRestNum()
    end
  end
end
def.static("table", "table").OnNpcService = function(p1, p2)
  local serviceId = p1[1]
  local npcId = p1[2]
  local self = LJTransformMgr.Instance()
  if -1 == self.m_NpcId or -1 == self.m_ServiceId then
    self.m_NpcId, self.m_ServiceId = FabaoUtils.GetLJTranformNpcIdAndServiceId()
  end
  if npcId == self.m_NpcId and serviceId == self.m_ServiceId then
    if not _G.IsFeatureOpen(Feature.TYPE_LONGJING_TRANSFER) then
      Toast(textRes.Fabao[127])
      return
    end
    if 1 > self.m_CurRestTranformNum then
      Toast(textRes.Fabao[126])
      return
    end
    local LJTransformPanel = require("Main.Fabao.ui.LJTransformPanel")
    LJTransformPanel.Instance():ShowPanel()
  end
end
def.static("table", "table").OnEnterWorld = function(p1, p2)
  if _G.IsFeatureOpen(Feature.TYPE_LONGJING_TRANSFER) then
    LJTransformMgr.CQueryLJTransformRestNum()
  end
end
def.static("table", "table").OnFeatureOpenInit = function(tbl, p2)
  local npcId, serviceId = FabaoUtils.GetLJTranformNpcIdAndServiceId()
  local npcShow = _G.IsFeatureOpen(Feature.TYPE_LONGJING_TRANSFER)
  Event.DispatchEvent(ModuleId.PUBROLE, gmodule.notifyId.Pubrole.SET_NPC_ENABLE, {npcid = npcId, show = npcShow})
end
def.static("table", "table").OnLeaveWorld = function(p1, p2)
  local self = LJTransformMgr.Instance()
  self.m_CurRestTranformNum = 0
  self.m_NpcId = -1
  self.m_ServiceId = -1
end
def.static().CQueryLJTransformRestNum = function()
  local p = require("netio.protocol.mzm.gsp.fabao.CQueryLongjingRestTransferReq").new()
  gmodule.network.sendProtocol(p)
end
def.static("userdata", "number", "number").CLongJingTransformReq = function(longjingUuid, targetLongJingAttrType, targetLongJingId)
  local p = require("netio.protocol.mzm.gsp.fabao.CLongjingPropertyTransferReq").new(longjingUuid, targetLongJingAttrType, targetLongJingId)
  gmodule.network.sendProtocol(p)
end
def.static("number", "number").CQueryTransformLongJingPriceReq = function(mainLongjingId, targetLongJingId)
  local p = require("netio.protocol.mzm.gsp.fabao.CQueryLongjingTransferPriceReq").new(mainLongjingId, targetLongJingId)
  gmodule.network.sendProtocol(p)
end
def.static("table").OnSQueryLongjingRestTransfer = function(p)
  warn("~~~~~~~~~~~~OnSQueryLongjingRestTransfer~~~~~~~~~~~~")
  local self = LJTransformMgr.Instance()
  self.m_CurRestTranformNum = p and p.resttransfercount or 0
end
def.static("table").OnSLongjingPropertyTransferRes = function(p)
  warn("~~~~~~~~~~~~OnSLongjingPropertyTransferRes~~~~~~~~~~~~~~")
  local self = LJTransformMgr.Instance()
  self.m_CurRestTranformNum = p.resttransfercount
  local info = {}
  info.sourceUuid = p.toTransferItemUuid
  info.sourceItemId = p.beforeitemid
  info.targetItemInfo = p.targetiteminfo
  Event.DispatchEvent(ModuleId.FABAO, gmodule.notifyId.Fabao.LONG_JING_TRANS_SUCC, {info})
  local sourceItemBase = ItemUtils.GetItemBase(p.beforeitemid)
  local targetItemBase = ItemUtils.GetItemBase(p.targetiteminfo.id)
  if nil == sourceItemBase or nil == targetItemBase then
    return
  end
  local HtmlHelper = require("Main.Chat.HtmlHelper")
  local sourceColor = HtmlHelper.NameColor[sourceItemBase.namecolor] or "fe7200"
  local targetColor = HtmlHelper.NameColor[targetItemBase.namecolor] or "fe7200"
  Toast(string.format(textRes.Fabao[130], sourceColor, sourceItemBase.name, targetColor, targetItemBase.name))
end
def.static("table").OnSLongjingPropertyTransferErrorRes = function(p)
  warn("~~~~~~~~~~OnSLongjingPropertyTransferErrorRes~~~~~~~~~~~", p.resultcode)
  local errMsg = textRes.Fabao.LongJingTransformError[p.resultcode]
  if errMsg then
    Toast(errMsg)
  end
end
def.static("table").OnSQueryLongjingTransferPriceRes = function(p)
  warn("~~~~~~~~OnSQueryLongjingTransferPriceRes~~~~~~~")
  Event.DispatchEvent(ModuleId.FABAO, gmodule.notifyId.Fabao.LONG_JING_QUERY_PRICE_SUCC, {
    priceMap = p.itemid2price
  })
end
LJTransformMgr.Commit()
return LJTransformMgr
