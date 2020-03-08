local Lplus = require("Lplus")
local AnnounceMentModule = require("Main.Announcement.AnnouncementModule")
local MapInterface = require("Main.Map.Interface")
local AnnouncementTip = require("GUI.AnnouncementTip")
local ChatModule = require("Main.Chat.ChatModule")
local ChatMsgData = require("Main.Chat.ChatMsgData")
local HtmlHelper = require("Main.Chat.HtmlHelper")
local PersonalHelper = require("Main.Chat.PersonalHelper")
local YaoShowTuXiMgr = Lplus.Class("YaoShowTuXiMgr")
local def = YaoShowTuXiMgr.define
local NPCServiceConst = require("Main.npc.NPCServiceConst")
local MAX_MONSTER_STAR = 9
local instance
def.static("=>", YaoShowTuXiMgr).Instance = function()
  if instance == nil then
    instance = YaoShowTuXiMgr()
  end
  return instance
end
def.method().Init = function(self)
  Event.RegisterEvent(ModuleId.NPC, gmodule.notifyId.NPC.NPC_SERVICE, YaoShowTuXiMgr.onYaoShowTuXiQuickFight)
  gmodule.network.registerProtocol("netio.protocol.mzm.gsp.activity.SSynPlayerWinFightRes", YaoShowTuXiMgr.PlayerWinFight)
  gmodule.network.registerProtocol("netio.protocol.mzm.gsp.activity.SSynPlayerLoseFightRes", YaoShowTuXiMgr.PlayerLoseFight)
end
def.static("table").PlayerWinFight = function(p)
  if nil == p then
    return
  end
  local players = p.roleinfos
  local mapId = p.mapCfgid
  local monsterId = p.monsterid
  local monsterStar = p.start
  local mapName = YaoShowTuXiMgr.GetYaoShouMapName(mapId)
  local monsterName = YaoShowTuXiMgr.GetYaoShouName(monsterId)
  local isMaxStar = false
  if MAX_MONSTER_STAR == monsterStar then
    isMaxStar = true
  end
  local params = {
    players = players,
    monsterName = monsterName,
    mapName = mapName
  }
  YaoShowTuXiMgr.OnYaoShouTuXiWin(params, isMaxStar)
end
def.static("table").PlayerLoseFight = function(p)
  if nil == p then
    return
  end
  local players = p.roleinfos
  local mapId = p.mapCfgid
  local monsterId = p.monsterid
  local monsterStar = p.start
  local nextStar = p.nextStart
  local mapName = YaoShowTuXiMgr.GetYaoShouMapName(mapId)
  local monsterName = YaoShowTuXiMgr.GetYaoShouName(monsterId)
  local isShengXing = false
  if monsterStar < nextStar then
    isShengXing = true
  end
  if nextStar < MAX_MONSTER_STAR then
    return
  end
  local params = {
    players = players,
    monsterName = monsterName,
    mapName = mapName,
    monsterStar = monsterStar,
    nextStar = nextStar
  }
  YaoShowTuXiMgr.OnYaoShouTuXiLose(params, isShengXing)
end
def.static("number", "=>", "string").GetYaoShouMapName = function(mapId)
  local mapName = " "
  local mapCfg = MapInterface.GetMapCfg(mapId)
  if mapCfg then
    mapName = mapCfg.mapName
  end
  return mapName
end
def.static("number", "=>", "string").GetYaoShouName = function(monsterid)
  local yaoshouName = " "
  local record = DynamicData.GetRecord(CFG_PATH.DATA_BRIGHTMONSTER_CFG, monsterid)
  if record then
    yaoshouName = record:GetStringValue("name")
  end
  return yaoshouName
end
def.static("table", "boolean").OnYaoShouTuXiWin = function(params, isMaxStar)
  local players = params.players
  local monsterName = params.monsterName
  local mapName = params.mapName
  if not isMaxStar then
    local roleName = players[1].roleName
    local content = string.format(textRes.AnnounceMent[2], monsterName, roleName)
    AnnouncementTip.Announce(content)
    ChatModule.Instance():SendSystemMsg(ChatMsgData.System.SYS, HtmlHelper.Style.TuXiWin, {name = roleName, monsterName = monsterName})
  else
    local roleName = players[1].roleName
    local otherNames = ""
    for i = 2, #players do
      otherNames = otherNames .. " " .. players[i].roleName
    end
    local content = string.format(textRes.AnnounceMent[61], roleName, otherNames, MAX_MONSTER_STAR, monsterName)
    AnnouncementTip.Announce(content)
    ChatModule.Instance():SendSystemMsg(ChatMsgData.System.SYS, HtmlHelper.Style.TuXiWinMaxStar, {
      name = roleName,
      otherNames = otherNames,
      monsterName = monsterName,
      monsterStar = MAX_MONSTER_STAR
    })
  end
end
def.static("table", "boolean").OnYaoShouTuXiLose = function(params, isShengXing)
  local players = params.players
  local monsterName = params.monsterName
  local mapName = params.mapName
  local nextStar = params.nextStar
  if params.monsterStar > 0 then
    monsterName = string.format(textRes.Common[240], params.monsterStar, monsterName)
  end
  local roleName = players[1].roleName
  if isShengXing then
    local nextMonsterName = string.format(textRes.Common[240], nextStar, params.monsterName)
    local str = string.format(textRes.AnnounceMent[27], monsterName, mapName, roleName, nextMonsterName)
    AnnouncementTip.Announce(str)
    ChatModule.Instance():SendSystemMsg(ChatMsgData.System.SYS, HtmlHelper.Style.YaoShouShengXing, {
      name = roleName,
      monster = monsterName,
      monster2 = nextMonsterName,
      place = mapName
    })
  elseif nil == mapName or " " == mapName then
    local content = string.format(textRes.AnnounceMent[35], roleName, monsterName)
    AnnouncementTip.Announce(content)
    ChatModule.Instance():SendSystemMsg(ChatMsgData.System.SYS, HtmlHelper.Style.TuXiLost, {name = roleName, monsterName = monsterName})
  else
    local content = string.format(textRes.AnnounceMent[3], roleName, mapName, monsterName)
    AnnouncementTip.Announce(content)
    ChatModule.Instance():SendSystemMsg(ChatMsgData.System.SYS, HtmlHelper.Style.TuXiLost, {
      name = roleName,
      monsterName = monsterName,
      place = mapName
    })
  end
end
def.static("=>", "table").GetYaoShouTuXiConst = function()
  local tuxiCfg = {}
  tuxiCfg.needItem = DynamicData.GetRecord(CFG_PATH.DATA_YAOSHOUTUXI_CONST, "NPC_FIGHT_ITEM_ID"):GetIntValue("value")
  tuxiCfg.needNum = DynamicData.GetRecord(CFG_PATH.DATA_YAOSHOUTUXI_CONST, "NPC_FIGHT_ITEM_NUM"):GetIntValue("value")
  tuxiCfg.npcId = DynamicData.GetRecord(CFG_PATH.DATA_YAOSHOUTUXI_CONST, "NPCID"):GetIntValue("value")
  return tuxiCfg
end
def.static("table", "table").onYaoShowTuXiQuickFight = function(p1, p2)
  local npcId = p1[2]
  local serviceId = p1[1]
  if serviceId == NPCServiceConst.YaoShouTuXi then
    local tuxiCfg = YaoShowTuXiMgr.GetYaoShouTuXiConst()
    local itemId = tuxiCfg.needItem
    local num = tuxiCfg.needNum
    local ItemModule = require("Main.Item.ItemModule")
    local hasCount = ItemModule.Instance():GetItemCountById(itemId)
    if num <= hasCount then
      local startFight = require("netio.protocol.mzm.gsp.activity.CYaoShouTuXiNPCStartFight").new()
      gmodule.network.sendProtocol(startFight)
    else
      local itemBase = require("Main.Item.ItemUtils").GetItemBase(itemId)
      Toast(string.format(textRes.activity[280], num, require("Main.Item.ItemTipsMgr").Color[itemBase.namecolor], itemBase.name))
    end
  end
end
return YaoShowTuXiMgr.Commit()
