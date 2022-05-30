local GuildBattleModel = {}
local guildBattleMsg = {
  getCityInfo = function(param)
    local _callback = param.callback
    local msg = {
      m = "union",
      a = "cityWallList"
    }
    RequestHelper.request(msg, _callback, param.errback)
  end,
  getCityWallInfo = function(param)
    local _callback = param.callback
    local msg = {
      m = "union",
      a = "cityWallInfo"
    }
    RequestHelper.request(msg, _callback, param.errback)
  end,
  setLineUp = function(param)
    local _callback = param.callback
    local msg = {
      m = "union",
      a = "lineup",
      type = param.type,
      bid = param.bid,
      ubid = param.ubid,
      pos = param.pos
    }
    RequestHelper.request(msg, _callback, param.errback)
  end,
  startFight = function(param)
    local _callback = param.callback
    local msg = {
      m = "union",
      a = "cityWallFight",
      fmt = param.fmt,
      type = param.type,
      aid = param.aid
    }
    RequestHelper.request(msg, _callback, param.errback)
  end,
  getSelfHero = function(param)
    local _callback = param.callback
    local msg = {m = "union", a = "selfLineup"}
    RequestHelper.request(msg, _callback, param.errback)
  end
}
function GuildBattleModel.init()
  GuildBattleModel.cityInfo = {}
  GuildBattleModel.cityWallInfo = nil
  GuildBattleModel.wallMaxMemberCount = 10
  GuildBattleModel.saveFormTitle = "kuafu_attack_form_" .. tostring(game.player.m_uid) .. "_" .. tostring(game.player.m_serverID)
end
GuildBattleFightStatus = {
  peace = 1,
  reader = 2,
  war = 3
}
function GuildBattleModel.setCityInfo(data)
  dump(data, "guildBattle Citye Info ")
  for key, value in pairs(data or {}) do
    GuildBattleModel.cityInfo[key] = value
  end
  GuildBattleModel.cityInfo.timeInit = true
  GuildBattleModel.cityInfo.time = GuildBattleModel.cityInfo.time / 1000
end
function GuildBattleModel.getCityInfo()
  return GuildBattleModel.cityInfo
end
function GuildBattleModel.cityInfoInit(callBackFunc)
  guildBattleMsg.getCityInfo({
    callback = function(data)
      GuildBattleModel.setCityInfo(data.rtnObj)
      callBackFunc(data.rtnObj)
    end
  })
end
local sortFunc = function(a, b)
  return a.attack > b.attack
end
function GuildBattleModel.setCityWallInfo(data)
  dump(data, "cityWallinfo ")
  local cityWallInfo = {}
  cityWallInfo.union_name = data.union_name
  cityWallInfo.union_id = data.union_id
  cityWallInfo.union_member = data.union_member
  cityWallInfo.union_pos = 0
  cityWallInfo.role_card = {}
  for i = 0, 4 do
    cityWallInfo.role_card[i] = {}
  end
  if cityWallInfo.union_member ~= GUILD_JOB_TYPE.others then
    for key, role in pairs(data.role_card) do
      if role.role_id == game.player.m_playerID then
        cityWallInfo.union_pos = role.pos
        break
      end
    end
  end
  for key, role in pairs(data.role_card) do
    table.insert(cityWallInfo.role_card[role.pos], role)
  end
  for key, role_card in pairs(cityWallInfo.role_card) do
    table.sort(role_card, sortFunc)
  end
  GuildBattleModel.cityWallInfo = cityWallInfo
end
function GuildBattleModel.cityWallInfoChange(data)
  local role_card = GuildBattleModel.cityWallInfo.role_card
  for key, hero in pairs(data) do
    local heroInfo
    for _, doorHero in pairs(role_card) do
      if not heroInfo then
        for index, _hero in pairs(doorHero) do
          if _hero.role_id == hero.role_id then
            _hero.pos = hero.pos
            heroInfo = _hero
            table.remove(doorHero, index)
            break
          end
        end
      end
    end
    if heroInfo then
      table.insert(role_card[hero.pos], heroInfo)
      table.sort(role_card[hero.pos], sortFunc)
      if hero.role_id == game.player.m_playerID then
        GuildBattleModel.cityWallInfo.union_pos = hero.pos
      end
    end
  end
end
function GuildBattleModel.getCityWallInfo()
  return GuildBattleModel.cityWallInfo
end
function GuildBattleModel.CityWallInfoInit(callBackFunc, init)
  if GuildBattleModel.cityWallInfo and not init then
    callBackFunc(GuildBattleModel.cityWallInfo)
  else
    guildBattleMsg.getCityWallInfo({
      callback = function(data)
        GuildBattleModel.setCityWallInfo(data.rtnObj)
        callBackFunc(GuildBattleModel.cityWallInfo)
      end
    })
  end
end
function GuildBattleModel.setLineUp(bid, ubid, pos, callBackFunc)
  local lineType = 1
  if ubid ~= 0 then
    lineType = 3
  end
  guildBattleMsg.setLineUp({
    type = lineType,
    bid = bid,
    ubid = ubid,
    pos = pos,
    callback = function(data)
      GuildBattleModel.cityWallInfoChange(data.rtnObj)
      callBackFunc()
    end,
    errback = function(data)
      GuildBattleModel.baseDataInit()
    end
  })
end
function GuildBattleModel.getSelfHeroInfo(callBackFunc)
  guildBattleMsg.getSelfHero({callback = callBackFunc})
end
function GuildBattleModel.baseDataInit()
  local count = 0
  guildBattleMsg.getCityInfo({
    callback = function(data)
      GuildBattleModel.setCityInfo(data.rtnObj)
      count = count + 1
      if count == 2 then
        GuildBattleModel.stateChangeNotice()
      end
    end
  })
  guildBattleMsg.getCityWallInfo({
    callback = function(data)
      GuildBattleModel.setCityWallInfo(data.rtnObj)
      count = count + 1
      if count == 2 then
        GuildBattleModel.stateChangeNotice()
      end
    end
  })
end
function GuildBattleModel.setStateChangeNotice(stateChangeNotice)
  GuildBattleModel.stateChangeNotice = stateChangeNotice
end
function GuildBattleModel.updateTime(dt)
  if GuildBattleModel.cityInfo and GuildBattleModel.cityInfo.timeInit then
    local time = GameModel.getServerTimeInSec()
    if time >= GuildBattleModel.cityInfo.time then
      GuildBattleModel.cityInfo.timeInit = false
      GuildBattleModel.baseDataInit()
    end
  end
end
function GuildBattleModel.startFight(fmtStr, member, fightType, callBackFunc)
  guildBattleMsg.startFight({
    type = fightType,
    fmt = fmtStr,
    aid = member.id,
    callback = function(data)
      dump(data)
      callBackFunc()
      if fightType == 1 then
        GuildBattleModel.CityWallInfoInit(function()
        end, true)
      end
      local scene = require("game.guild.guildBattle.GuildBattleFightScene").new({
        data = data,
        enemyName = member.name,
        enemyCombat = member.attack,
        fightType = fightType
      })
      push_scene(scene)
      GameAudio.playSound(ResMgr.getSFX(SFX_NAME.u_queding))
    end,
    errback = function(data)
      GuildBattleModel.baseDataInit()
    end
  })
end
return GuildBattleModel
