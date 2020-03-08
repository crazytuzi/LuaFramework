local Lplus = require("Lplus")
local ModuleBase = require("Main.module.ModuleBase")
local MapItemModule = Lplus.Extend(ModuleBase, "MapItemModule")
require("Main.module.ModuleId")
local Space = require("consts.mzm.gsp.map.confbean.Space")
local CollectSliderPanel = require("GUI.CollectSliderPanel")
local CommonConfirmDlg = require("GUI.CommonConfirmDlg")
local def = MapItemModule.define
local instance
def.field("number").mapItemId = 0
def.field("table").mapItemCfg = nil
def.field("boolean").bCost = false
def.field("string").succeedStr = ""
def.static("=>", MapItemModule).Instance = function()
  if instance == nil then
    instance = MapItemModule()
    instance.m_moduleId = ModuleId.MAPITEM
  end
  return instance
end
def.override().Init = function(self)
  Event.RegisterEvent(ModuleId.PUBROLE, gmodule.notifyId.Pubrole.CLICK_ITEM, MapItemModule.OnClickMapItem)
  gmodule.network.registerProtocol("netio.protocol.mzm.gsp.map.SMapItemGatherSuccess", MapItemModule.OnSMapItemGatherSuccess)
  gmodule.network.registerProtocol("netio.protocol.mzm.gsp.map.SMapCommonResult", MapItemModule.OnSMapCommonResult)
end
def.static("table", "table").OnClickMapItem = function(p1, p2)
  MapItemModule.Instance().mapItemId = 0
  MapItemModule.Instance().mapItemCfg = nil
  local id = p1 and p1[1]
  if id == nil then
    return
  end
  local pubroleModule = gmodule.moduleMgr:GetModule(ModuleId.PUBROLE)
  local heroModule = gmodule.moduleMgr:GetModule(ModuleId.HERO)
  if heroModule.myRole:IsInState(RoleState.ESCORT) then
    return
  end
  if heroModule.myRole:IsInState(RoleState.BEHUG) then
    Toast(textRes.Hero[52])
    return
  end
  if pubroleModule:IsInFollowState(heroModule:GetMyRoleId()) then
    Toast(textRes.Hero[46])
    return
  end
  if pubroleModule:IsInWedding() then
    Toast(textRes.Hero[55])
    return
  end
  if pubroleModule:IsInWeddingParade() then
    Toast(textRes.Hero[61])
    return
  end
  heroModule:Stop()
  local mapItemCfg
  local theItem = pubroleModule:GetMapItem(id)
  if theItem == nil then
    return
  end
  mapItemCfg = theItem.m_cfgInfo
  if nil == mapItemCfg then
    return
  end
  local itemPos = theItem:GetPos()
  heroModule.needShowAutoEffect = true
  MapItemModule.Instance().mapItemId = id
  MapItemModule.Instance().mapItemCfg = mapItemCfg
  heroModule:MoveTo(-1, itemPos.x, itemPos.y, Space.GROUND, 4, MoveType.AUTO, MapItemModule.OnFindpathFinished)
end
def.static().OnFindpathFinished = function()
  if 0 ~= MapItemModule.Instance().mapItemId and nil ~= MapItemModule.Instance().mapItemCfg then
    MapItemModule.CollectMapItem(MapItemModule.Instance().mapItemCfg, MapItemModule.Instance().mapItemId)
    MapItemModule.SetNull()
  end
end
def.static("table").CollectMapItemCallback = function(tag)
  MapItemModule.RequireToCollectMapItem(tag.mapItemId, tag.bCost, tag.succeedStr)
end
def.static().CollectMapItemInterruptCallback = function(tag)
  Toast(textRes.CollectMapItem[27])
  MapItemModule.SetNull()
end
def.static("number", "boolean", "string").RequireToCollectMapItem = function(mapItemId, bCost, succeedStr)
  local pubroleModule = gmodule.moduleMgr:GetModule(ModuleId.PUBROLE)
  local mapItemCfg
  local theItem = pubroleModule:GetMapItem(mapItemId)
  if theItem == nil then
    return
  end
  mapItemCfg = theItem.m_cfgInfo
  if nil == mapItemCfg then
    return
  end
  if mapItemCfg.handlerType == constant.CLuckyBagCfgConsts.JADE_MAP_ITEM_HANDLER_TYPE then
    local JiuZhouFudaiPanel = require("Main.activity.JiuZhouFuDai.ui.JiuZhouFudaiPanel")
    local LuckyBagType = require("consts.mzm.gsp.luckybag.confbean.LuckyBagType")
    JiuZhouFudaiPanel.Instance():ShowPanel(mapItemId, mapItemCfg.id, LuckyBagType.JADE)
  elseif mapItemCfg.handlerType == constant.CLuckyBagCfgConsts.BRASS_MAP_ITEM_HANDLER_TYPE then
    local JiuZhouFudaiPanel = require("Main.activity.JiuZhouFuDai.ui.JiuZhouFudaiPanel")
    local LuckyBagType = require("consts.mzm.gsp.luckybag.confbean.LuckyBagType")
    JiuZhouFudaiPanel.Instance():ShowPanel(mapItemId, mapItemCfg.id, LuckyBagType.BRASS)
  elseif mapItemCfg.handlerType == constant.CLuckyBagCfgConsts.BOX_MAP_ITEM_HANDLER_TYPE then
    local JiuZhouFudaiPanel = require("Main.activity.JiuZhouFuDai.ui.JiuZhouFudaiPanel")
    local LuckyBagType = require("consts.mzm.gsp.luckybag.confbean.LuckyBagType")
    JiuZhouFudaiPanel.Instance():ShowPanel(mapItemId, mapItemCfg.id, LuckyBagType.BOX)
  elseif mapItemCfg.handlerType == require("netio.protocol.mzm.gsp.firework.FireWorkConsts").COLLECTION_CHECK_TYPE then
    local fireworksShowMgr = require("Main.activity.FireworksShow.FireworksShowMgr").Instance()
    fireworksShowMgr:CCollectFireworkReq(mapItemId)
  else
    local p = require("netio.protocol.mzm.gsp.map.CMapItemGather").new(mapItemId)
    gmodule.network.sendProtocol(p)
    MapItemModule.Instance().bCost = bCost
    MapItemModule.Instance().succeedStr = succeedStr
    Event.DispatchEvent(ModuleId.MAP, gmodule.notifyId.Map.COLLECT_ITEM_DONE, {mapItemId})
  end
end
def.static("number", "table").SureToCollectCallback = function(i, tag)
  if 1 == i then
    MapItemModule.SureToCollect(tag)
  elseif 0 == i then
    return
  end
end
def.static().SetNull = function()
  MapItemModule.Instance().mapItemId = 0
  MapItemModule.Instance().mapItemCfg = nil
end
def.static("table").SureToCollect = function(tag)
  local heroProp = require("Main.Hero.Interface").GetBasicHeroProp()
  local item = gmodule.moduleMgr:GetModule(ModuleId.PUBROLE):GetMapItem(instance.mapItemId)
  MapItemModule.SetNull()
  if item == nil then
    return
  end
  if heroProp.level < tag.mapItemCfg.minLevel or heroProp.level > tag.mapItemCfg.maxLevel then
    local str = string.format(textRes.CollectMapItem[16], tag.mapItemCfg.minLevel)
    Toast(str)
    return
  end
  local teamData = require("Main.Team.TeamData").Instance()
  local memberNum = #teamData:GetAllTeamMembers() + 1
  if memberNum < tag.mapItemCfg.minNum then
    Toast(string.format(textRes.CollectMapItem[19], tag.mapItemCfg.minNum))
    return
  end
  local heroModule = gmodule.moduleMgr:GetModule(ModuleId.HERO)
  local myRoleID = heroModule:GetMyRoleId()
  local ret = teamData:HasTeam() and teamData:IsCaptain(myRoleID)
  if false == ret and false == tag.mapItemCfg.isTeamMemberCanOpen then
    Toast(textRes.CollectMapItem[24])
    return
  end
  if false == tag.bGoldEnough then
    Toast(textRes.CollectMapItem[21])
    return
  end
  if false == tag.bSilverEnough then
    Toast(textRes.CollectMapItem[22])
    return
  end
  if false == tag.bItemEnough then
    local ItemUtils = require("Main.Item.ItemUtils")
    local itemBase = ItemUtils.GetItemBase(tag.needItemId)
    if tag.mapItemCfg.isItemCanBuy then
      local str = string.format(textRes.CollectMapItem[26], itemBase.name)
      Toast(str)
    else
      local str = string.format(textRes.CollectMapItem[20], itemBase.name)
      Toast(str)
      return
    end
  end
  if false == tag.bYuanBaoEnough then
    Toast(textRes.CollectMapItem[23])
    return
  end
  heroModule.myRole:LookAtTarget(item)
  if tag.mapItemCfg.costTime > 0 then
    local tag2 = {
      mapItemId = tag.mapItemId,
      bCost = tag.bCost,
      succeedStr = tag.succeedStr
    }
    CollectSliderPanel.ShowCollectSliderPanel(tag.mapItemCfg.desc, tag.mapItemCfg.costTime, MapItemModule.CollectMapItemInterruptCallback, MapItemModule.CollectMapItemCallback, tag2)
  else
    MapItemModule.RequireToCollectMapItem(tag.mapItemId, tag.bCost, tag.succeedStr)
  end
end
def.static("table", "number").CollectMapItem = function(mapItemCfg, mapItemId)
  local ItemUtils = require("Main.Item.ItemUtils")
  local ItemModule = require("Main.Item.ItemModule")
  local bCost = false
  local costStr = textRes.CollectMapItem[11]
  local succeedStr = textRes.CollectMapItem[25]
  local needItemId = mapItemCfg.needItemId
  local needItemNum = mapItemCfg.needItemNum
  local bItemEnough = true
  if needItemId ~= 0 and needItemNum > 0 then
    bCost = true
    local itemBase = ItemUtils.GetItemBase(needItemId)
    costStr = costStr .. string.format(textRes.CollectMapItem[12], itemBase.name, needItemNum)
    succeedStr = succeedStr .. string.format(textRes.CollectMapItem[12], itemBase.name, needItemNum)
    local have = ItemModule.Instance():GetItemCountById(needItemId)
    if needItemNum > have then
      bItemEnough = false
    end
  end
  local openCostYuanBao = mapItemCfg.openCostYuanBao
  local bYuanBaoEnough = true
  if openCostYuanBao > 0 then
    bCost = true
    costStr = costStr .. "," .. string.format(textRes.CollectMapItem[13], openCostYuanBao)
    succeedStr = succeedStr .. "," .. string.format(textRes.CollectMapItem[13], openCostYuanBao)
    local yuanbao = ItemModule.Instance():GetAllYuanBao()
    if Int64.lt(yuanbao, openCostYuanBao) then
      bYuanBaoEnough = false
    end
  end
  local openCostGold = mapItemCfg.openCostGold
  local bGoldEnough = true
  if openCostGold > 0 then
    bCost = true
    costStr = costStr .. "," .. string.format(textRes.CollectMapItem[14], openCostGold)
    succeedStr = succeedStr .. "," .. string.format(textRes.CollectMapItem[14], openCostGold)
    local gold = ItemModule.Instance():GetMoney(ItemModule.MONEY_TYPE_GOLD)
    if Int64.lt(gold, openCostGold) then
      bGoldEnough = false
    end
  end
  local openCostSilver = mapItemCfg.openCostSilver
  local bSilverEnough = true
  if openCostSilver > 0 then
    bCost = true
    costStr = costStr .. "," .. string.format(textRes.CollectMapItem[15], openCostSilver)
    succeedStr = succeedStr .. "," .. string.format(textRes.CollectMapItem[15], openCostSilver)
    local silver = ItemModule.Instance():GetMoney(ItemModule.MONEY_TYPE_SILVER)
    if Int64.lt(silver, openCostSilver) then
      bSilverEnough = false
    end
  end
  local tag = {
    mapItemCfg = mapItemCfg,
    mapItemId = mapItemId,
    bItemEnough = bItemEnough,
    needItemId = needItemId,
    bYuanBaoEnough = bYuanBaoEnough,
    bGoldEnough = bGoldEnough,
    bSilverEnough = bSilverEnough,
    bCost = bCost,
    succeedStr = succeedStr
  }
  if bCost then
    CommonConfirmDlg.ShowConfirm("", costStr, MapItemModule.SureToCollectCallback, tag)
  else
    MapItemModule.SureToCollect(tag)
  end
end
def.static("table").OnSMapItemGatherSuccess = function(p)
  local mapItemCfg = MapItemModule.GetMapItemInfo(p.instanceId)
  if nil ~= mapItemCfg then
    local str = ""
    if MapItemModule.Instance().bCost then
      str = MapItemModule.Instance().succeedStr
      str = str .. string.format(textRes.CollectMapItem[10], mapItemCfg.name)
      Toast(str)
    end
    if p.itemId > 0 and 0 < p.num then
      local PersonalHelper = require("Main.Chat.PersonalHelper")
      PersonalHelper.CommonMsg(PersonalHelper.Type.Text, textRes.Common[150], PersonalHelper.Type.ItemMap, {
        [p.itemId] = p.num
      })
    end
  end
  MapItemModule.Instance().bCost = false
  MapItemModule.Instance().succeedStr = ""
end
def.static("table").OnSMapCommonResult = function(p)
  local SMapCommonResult = require("netio.protocol.mzm.gsp.map.SMapCommonResult")
  local JiuZhouFuDaiMgr = require("Main.activity.JiuZhouFuDai.JiuZhouFuDaiMgr")
  if p.result == SMapCommonResult.TEAM_LEADER_MUST_GANG_MEMBER then
    Toast(textRes.PubRole[1])
  elseif p.result == SMapCommonResult.TEAM_MEMBER_MUST_THREE_GANG_MEMBER then
    Toast(textRes.PubRole[2])
  elseif p.result == SMapCommonResult.MAPITEM_ALREADY_GATHERED then
    if JiuZhouFuDaiMgr.Instance():GetServerState() then
      JiuZhouFuDaiMgr.Instance():OnSMapCommonResult(p)
    else
      local str = textRes.CollectMapItem[1]
      Toast(str)
    end
    MapItemModule.Instance().bCost = false
    MapItemModule.Instance().succeedStr = ""
  elseif p.result == SMapCommonResult.BAG_FULL then
    local str = textRes.CollectMapItem[2]
    Toast(str)
    MapItemModule.Instance().bCost = false
    MapItemModule.Instance().succeedStr = ""
  elseif p.result == SMapCommonResult.DISTANCE_NOT_MATCH then
  elseif p.result == SMapCommonResult.CAN_NOT_TRANSFER then
    Toast(textRes.Map[11])
  elseif p.result == SMapCommonResult.MONSTER_IN_FIGHT then
    Toast(textRes.Map[15])
  elseif p.result == SMapCommonResult.ERROR_DAILY_GATHER_TIMES_LIMIT then
    Toast(textRes.Map[17])
  elseif p.result == SMapCommonResult.ERROR_GATHER_INTERVAL then
    Toast(textRes.Map[18])
  elseif p.result == SMapCommonResult.COMPETITION_MERCENARY_NOT_TIME then
    Toast(textRes.Gang[272])
  elseif p.result == SMapCommonResult.COMPETITION_MERCENARY_SELF then
    Toast(textRes.Gang[273])
  elseif p.result == SMapCommonResult.COMPETITION_MERCENARY_DISRELATED then
    Toast(textRes.Gang[274])
  elseif p.result == SMapCommonResult.COMPETITION_MERCENARY_FINISHED then
    Toast(textRes.Gang[275])
  end
  JiuZhouFuDaiMgr.Instance():SetServerState(false)
end
def.static("number", "=>", "table").GetMapItemInfo = function(id)
  local record = DynamicData.GetRecord(CFG_PATH.DATA_MAP_ITEM_CFG, id)
  if record == nil then
    warn("GetMapItemInfo(" .. id .. ") return nil")
    return nil
  end
  local mapItemCfg = {}
  mapItemCfg.id = record:GetIntValue("id")
  mapItemCfg.name = record:GetStringValue("name")
  mapItemCfg.modelId = record:GetIntValue("modelId")
  mapItemCfg.handlerType = record:GetIntValue("handlerType")
  mapItemCfg.minLevel = record:GetIntValue("minLevel")
  mapItemCfg.maxLevel = record:GetIntValue("maxLevel")
  mapItemCfg.needItemId = record:GetIntValue("needItemId")
  mapItemCfg.radius = record:GetIntValue("radius")
  mapItemCfg.isTeamMemberCanOpen = record:GetCharValue("isTeamMemberCanOpen") == 1
  mapItemCfg.needItemNum = record:GetIntValue("needItemNum")
  mapItemCfg.openCostYuanBao = record:GetIntValue("openCostYuanBao")
  mapItemCfg.openCostGold = record:GetIntValue("openCostGold")
  mapItemCfg.openCostSilver = record:GetIntValue("openCostSilver")
  mapItemCfg.isItemCanBuy = record:GetCharValue("isItemCanBuy") == 1
  mapItemCfg.minNum = record:GetIntValue("minNum")
  mapItemCfg.costTime = record:GetIntValue("costTime")
  mapItemCfg.desc = record:GetStringValue("desc")
  mapItemCfg.maxCount = record:GetIntValue("maxCount")
  mapItemCfg.openMusicEffect = record:GetIntValue("openMusicEffect")
  mapItemCfg.openEffect = record:GetIntValue("openEffect")
  return mapItemCfg
end
MapItemModule.Commit()
return MapItemModule
