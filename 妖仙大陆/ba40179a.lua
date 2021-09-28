
local _M = {}
_M.__index = _M

local cjson = require "cjson"
local helper = require "Zeus.Logic.Helper"
local Util = require 'Zeus.Logic.Util'

local CACHE_TIME = 10
local cacheMap = {}

function _M.ClearCache()
  cacheMap = {}
end

_M.TeamData = {
  info = nil,
  bag = nil,
  bagListener = {},
}

_M.ItemMode = {
  free = 1,
  allot = 2,
  roll = 3
}

_M.ItemRoll = {
  giveup = 1,
  random = 2,
  roll = 3
}

function _M.RemoveTeamBagListener(key)
  _M.TeamData.bagListener[key] = nil
end

function _M.AddTeamBagListener(key, cb)
  _M.TeamData.bagListener[key] = cb
end

function _M.OpenFunctionMenu(type, id, name, pro, level, cb)
  EventManager.Fire("Event.ShowInteractive", {
      type = type,
      
      
      player_info = {
        name = name,
        pro = pro,
        lv = level,
        playerId = id,
        activeMenuCb = function(_id, info)
          if cb ~= nil then
            cb(_id, info)
          end
        end,
      }
  })
end

local function ShowTeamInteractiveMenu( eventname, params )
  local funcMenu = require "Zeus.UI.InteractiveMenu"
  local id = params.id
  local name = params.name
  local pro = params.pro
  local level = params.level
  local menuType = params.type
  _M.OpenFunctionMenu(menuType, id, name, pro, level, nil)
end

function _M.RequestGotoTeamTarget(targetId,difficulty,cb)
  Pomelo.TeamHandler.gotoTeamTargetRequest(targetId,difficulty,function( ex, sjson )
    
    if ex == nil then
      local param = sjson:ToData()
      
      if cb ~= nil then
        cb()
      end
    end
  end, nil)
end

function _M.RequestSummonConfirm(id, operate, cb)
  Pomelo.TeamHandler.summonConfirmRequest(id, operate, function( ex, sjson )
    
    if ex == nil then
      local param = sjson:ToData()
      
      if cb ~= nil then
        cb()
      end
    end
  end, nil)
end

function _M.RequestSummonAllMembers(cb)
    Pomelo.TeamHandler.summonRequest("",function(ex,sjson)
        if ex == nil then
            local param = sjson:ToData()
            if cb ~= nil then
                cb()
            end
        end
    end)
end

function _M.RequestSummon(memberId, name, pro, cb)
  local playerName = string.format("<f color='%x'>%s</f>", GameUtil.GetProColorARGB(pro), name)
  local content = string.format(ConfigMgr.Instance.TxtCfg:GetTextByKey(TextConfig.Type.TEAM, "sengdsummon"), playerName)
  GameAlertManager.Instance.AlertDialog:ShowAlertDialog(AlertDialog.PRIORITY_NORMAL, content, nil, nil, nil, function()
    Pomelo.TeamHandler.summonRequest(memberId, function( ex, sjson )
      
      if ex == nil then
        local param = sjson:ToData()
        
        if cb ~= nil then
          cb()
        end
      end
    end, nil)
  end, nil)
end

function _M.RequestApplyResult(id, type, result, cb)
  Pomelo.MessageHandler.handleMessageRequest(id, type, result, function( ex, sjson )
    
    DataMgr.Instance.MessageData:RemoveMessage(id, type)
    if ex == nil then
      local param = sjson:ToData()
      
      if cb ~= nil then
        cb()
      end
    end
  end, nil)
end

function _M.RequestApplyList(cb)
  Pomelo.TeamHandler.getAppliedPlayersRequest(function( ex, sjson )
    
    
    if ex == nil then
      local param = sjson:ToData()
      
      if cb ~= nil then
        cb(param)
      end
    end
  end, nil)
end

function _M.RequestInviteList(type, cb)
  
  Pomelo.TeamHandler.getPlayersByTypeRequest(type, function( ex, sjson )
    
    
    if ex == nil then
      local param = sjson:ToData()
      
      if cb ~= nil then
        cb(param)
      end
    end
  end, nil)
end

function _M.RequestSetTarget(targetId, diffcuilty, minLv, maxLv, isAutoTeam, isAutoStart, cb)
  maxLv = maxLv > 0 and maxLv or tonumber(GlobalHooks.DB.Find("Parameters", { ParamName = "Role.LevelLimit" })[1].ParamValue) 
  minLv = minLv > 0 and minLv or GlobalHooks.DB.Find('TeamTarget', targetId).OpenLv
  Pomelo.TeamHandler.setTeamTargetRequest(targetId, diffcuilty, minLv, maxLv, isAutoTeam, isAutoStart, function( ex, sjson )
    
    
    if ex == nil then
      local param = sjson:ToData()
      if cb ~= nil then
        cb(param)
      end
    end
  end, nil)
end

function _M.RequestSearchTeam(targetId, diffcuilty, isForce, cb)
  
  local key = string.format("%d_%d", targetId, diffcuilty)
  if not isForce then
    local data = cacheMap[key]
    if data and data.time + CACHE_TIME > os.time() then
      cb(data.data)
      return
    end
  end

  Pomelo.TeamHandler.queryTeamByTargetRequest(targetId, diffcuilty, function( ex, sjson )
    
    
    if ex == nil then
      local param = sjson:ToData()
      cacheMap[key] = {time = os.time(), data=param}
      if cb ~= nil then
        cb(param)
      end
    end
  end, nil)
end

function _M.RequestCreateTeamAndSetTarget(targetid, difficulty, cb, forceCallBack)
  _M.RequestCreateTeam(function(p)
    local reqLevel = 0
    local reqUpLevel = 0
    local reqPower = 0
    local isAutoTeam = targetid ~=1 and 1 or 0
    local isAutoStart = 1
    local db = GlobalHooks.DB.Find('TeamTarget', targetid)
    local mapType = {"NormalMapID","EliteMapID","HeroMapID"}
    if db[mapType[difficulty]] > 0 then
      local mapInfo = GlobalHooks.DB.Find("Map", db[mapType[difficulty]])
      if mapInfo ~= nil then
        if mapInfo.ReqUpLevel > 0 then
          reqUpLevel = mapInfo.ReqUpLevel
        elseif mapInfo.ReqLevel > 0 then
          reqLevel = mapInfo.ReqLevel
        else

        end
      end
    end
    
    local maxLv  = tonumber(GlobalHooks.DB.Find("Parameters", { ParamName = "Role.LevelLimit" })[1].ParamValue) 
    local minLv = db.OpenLv
    _M.RequestSetTarget(targetid, difficulty, minLv, maxLv, isAutoTeam, isAutoStart, function(param)
      if cb ~= nil then
        cb(param)
      end
    end)
  end, forceCallBack)
end

function _M.RequestCreateTeam(cb, forceCallBack)
  Pomelo.TeamHandler.createTeamRequest(function( ex, sjson )
    local param
    if ex == nil or forceCallBack then
      if ex == nil then
        param = sjson:ToData()
      end
      if cb ~= nil then
        cb(param)
      end
    end
  end, nil)
end

function _M.RequestLeaveFightLevel(cb)
  Pomelo.FightLevelHandler.leaveFightLevelSingleRequest(function( ex, sjson )
    
    
    if ex == nil then
      local param = sjson:ToData()
      if cb ~= nil then
        cb()
      end
    end
  end, nil)
end

function _M.RequestItemAllot(itemId, playerId, cb)
  Pomelo.TeamHandler.distributeTeamItemRequest(itemId, playerId, function( ex, sjson )
    
    
    if ex == nil then
      local param = sjson:ToData()
      
      if cb ~= nil then
        cb()
      end
    end
  end, nil)
end

function _M.RequestItemRoll(itemId, type, cb)
  Pomelo.TeamHandler.grapTeamItemRequest(itemId, type, function( ex, sjson )
    
    
    if ex == nil then
      local param = sjson:ToData()
      
      if cb ~= nil then
        cb()
      end
    end
  end, nil)
end

function _M.RequestChangeMode(mode, quality, cb)
  Pomelo.TeamHandler.changeDistributeTypeRequest(mode, quality, function( ex, sjson )
    
    
    if ex == nil then
      local param = sjson:ToData()
      if cb ~= nil then
          _M.TeamData.info.s2c_distributeType = param.s2c_distributeType
          _M.TeamData.info.s2c_distributeItemQcolor = param.s2c_distributeItemQcolor
        cb(_M.TeamData.info)
      end
    end
  end, nil)
end

function _M.RequestChangeLeader(playerId, cb)
  _M.RequestAutoAccept(0,nil)
  Pomelo.TeamHandler.changeTeamLeaderRequest(playerId, function( ex, sjson )
    
    if ex == nil then
      
      
      if cb ~= nil then
        cb()
      end
    end
  end, nil)
end

function _M.RequestKickOutTeam(playerId, cb)
  Pomelo.TeamHandler.kickOutTeamRequest(playerId, function( ex, sjson )
    
    if ex == nil then
      
      
      if cb ~= nil then
        cb()
      end
    end
  end, nil)
end

function _M.RequestLeaveTeam(cb)
  Pomelo.TeamHandler.leaveTeamRequest(function( ex, sjson )
    
    if ex == nil then
      
      
      if cb ~= nil then
        cb()
      end
    end
  end, nil)
end

function _M.RequestAutoAccept(isAccept,cb)
  Pomelo.TeamHandler.setAutoAcceptTeamRequest(isAccept, function( ex, sjson )
    if ex == nil then
        if cb ~= nil then
            cb(isAccept)
        end
    else
      if cb ~= nil then
          cb(isAccept==1 and 0 or 1)
      end
    end
  end, XmdsNetManage.PackExtData.New(false, true))
end

function _M.RequestApplyTeam(leaderId, cb)
  Pomelo.TeamHandler.formTeamRequest(leaderId, function( ex, sjson )
    
    if ex == nil then
      
      
      if cb ~= nil then
        cb()
      end
    end
  end, nil)
end

function _M.RequestApplyTeamByTeamId(teamId, cb)
    
  Pomelo.TeamHandler.joinTeamRequest(teamId, function( ex, sjson )
    
    if ex == nil then
      
      
      if cb ~= nil then
        cb(teamId)
      end
    end
  end, nil)
end

function _M.RequestAutoApplyTeam(targetId, diffcuilty, cb)
  Pomelo.TeamHandler.autoJoinTeamRequest(targetId, diffcuilty, function( ex, sjson )
    
    if ex == nil then
      
      
      if cb ~= nil then
        cb(targetId, diffcuilty)
      end
    end
  end, nil)
end

function _M.RequestInviteTeam(playerId, cb)
  Pomelo.TeamHandler.formTeamRequest(playerId, function( ex, sjson )
     
    if ex == nil then
      
      
      if cb ~= nil then
        cb()
      end
    end
  end, nil)
end

function _M.RequestOnlineFriends(cb)
  Pomelo.TeamHandler.getNearbyFriendsRequest(function( ex, sjson )
    
    
    if ex == nil then
      local param = sjson:ToData()
      
      if cb ~= nil then
        cb(param)
      end
    end
  end, nil)
end

function _M.RequestNearPlayers(cb)
  Pomelo.TeamHandler.getNearbyPlayersRequest(function( ex, sjson )
    
    
    if ex == nil then
      local param = sjson:ToData()
      
      if cb ~= nil then
        cb(param)
      end
    end
  end, nil)
end

function _M.RequestNearTeams(cb)
  Pomelo.TeamHandler.getNearTeamsRequest(function( ex, sjson )
    
    
    if ex == nil then
      local param = sjson:ToData()
      local data = param.teams
      if cb ~= nil then
        cb(param)
      end
    end
  end, nil)
end

function _M.RequestTeamMembers(cb)
  
  Pomelo.TeamHandler.getTeamMembersRequest(function( ex, sjson )
     
    
    if ex == nil then
      local param = sjson:ToData()
      _M.TeamData.info = param
      if cb ~= nil then
        cb(param)
      end
    end
  end, nil)
end

function _M.RequestTeamSetFollowLeader(follow,cb)
   Pomelo.TeamHandler.followLeaderRequest(follow,function( ex, sjson )
    if ex == nil then
        local param = sjson:ToData()
        if cb then
            cb(follow)
        end
    else
      cb(not follow)
    end
   end,nil)
end

function _M.RequestCancelAuto(cb)
  Pomelo.TeamHandler.cancelAutoRequest(function( ex, sjson )
    if ex == nil then
        if cb then
            cb()
        end
    end
   end,nil)
end

function GlobalHooks.DynamicPushs.OnSummonTeamPush(ex, json)
  
  

  if ex == nil then
    local param = json:ToData()
    local id = param.s2c_id
    local content = param.s2c_content
    local key
    GameAlertManager.Instance.AlertDialog:ShowAlertDialog(AlertDialog.PRIORITY_NORMAL, content, '', '', nil, function(parma)
      _M.RequestSummonConfirm(id, 1, nil)
    end, function(parma)
      _M.RequestSummonConfirm(id, 0, nil)
    end)
  end
end

function GlobalHooks.DynamicPushs.OnTeamKickOutFightLevelPush(ex, json)
  
  

  if ex == nil then
    local param = json:ToData()
    local titleStr = ConfigMgr.Instance.TxtCfg:GetTextByKey(TextConfig.Type.TEAM, "IsLeave")
    local content = ConfigMgr.Instance.TxtCfg:GetTextByKey(TextConfig.Type.TEAM, "leave")
    local time = param.s2c_remainTime
    local key
    key = GameAlertManager.Instance.AlertDialog:ShowAlertDialogTime(AlertDialog.PRIORITY_NORMAL, content, time, '', titleStr, nil, function(parma)
      _M.RequestLeaveFightLevel(function()
        GameAlertManager.Instance.AlertDialog:CloseDialog(key)
      end)
    end, nil)
  end
end

function GlobalHooks.DynamicPushs.OnGrapItemPush(ex, json)
  
  

  if ex == nil then
    local param = json:ToData()
    local ItemRoll = require "Zeus.UI.Team.ItemRoll"
    local node, luaObj = ItemRoll.Create()
    luaObj.SetData(luaObj, param)
    GameAlertManager.Instance.AlertDialog:ShowAlertDialog(node, AlertDialog.PRIORITY_NORMAL, nil)
  end
end

function GlobalHooks.DynamicPushs.OnTeamBagItemPush(ex, json)
  
  

  if ex == nil then
    local param = json:ToData()
    if _M.TeamData.bag == nil then
      _M.TeamData.bag = {}
    end
    local items = param.s2c_items
    local clearBag = param.s2c_isClearBag
    if clearBag == 1 then
      _M.TeamData.bag = {}
    else
      for i=1, #items do
        local item = items[i]
        if item.itemDetail ~= nil then 
          local isExis = false
          for i=1, #_M.TeamData.bag do
            if _M.TeamData.bag[i].itemId == item.itemId then
              _M.TeamData.bag[i] = item
              isExis = true
              break
            end
          end
          if not isExis then
            _M.TeamData.bag[#_M.TeamData.bag + 1] = item
          end
        else 
          local delIndex = nil
          for i=1, #_M.TeamData.bag do
            if _M.TeamData.bag[i].itemId == item.itemId then 
              delIndex = i
            elseif delIndex ~= nil then 
              _M.TeamData.bag[i - 1] = _M.TeamData.bag[i]
            end
          end
          if delIndex ~= nil then 
            _M.TeamData.bag[#_M.TeamData.bag] = nil
          end
        end
      end
    end
    for key,val in pairs(_M.TeamData.bagListener) do
      val()
    end
    EventManager.Fire('Event.Hud.TeamBagUpdate', {itemCount = #_M.TeamData.bag})
  end
end

function GlobalHooks.DynamicPushs.onGrapWinItemPush(ex, json)
  
  

  
  
  
  
  
  
  
  
  
  
end
  
function GlobalHooks.DynamicPushs.OnTeamTargetPush(ex,json)
  
    local param = json:ToData()
    
    _M.TeamData.info = _M.TeamData.info or {}
    _M.TeamData.info.s2c_isAcceptAutoTeam = param.s2c_isAcceptAutoTeam
    _M.TeamData.info.s2c_teamTarget = param.s2c_teamTarget
    if _M.TeamData.info.haveApply ~= param.haveApply then
      _M.TeamData.info.haveApply = param.haveApply
      if param.haveApply ~= 0 then
        EventManager.Fire("Event.RefreshTeamApply",{applyNum = param.haveApply})
      else
      
         DataMgr.Instance.MessageData:RemoveList(MessageData.MsgType.TeamApply)
      end
    end

    
    
    
    

  
end

function GlobalHooks.DynamicPushs.OnTeamMumberHurtPush(ex,json)
  if ex == nil then
      local param = json:ToData()
      if param.players and #param.players > 0 then
          EventManager.Fire("Event.GuildWar.UpdateDungeonTongJiUI",{players = param.players})
      end
  end
end

local function handler_goTarget(evtName,param)
    local function handler()
      GlobalHooks.CloseUI(GlobalHooks.UITAG.GameUITeamMain)
    end
    
    _M.TeamData.info = _M.TeamData.info or {}
    local targetinfo = _M.TeamData.info.s2c_teamTarget
    if targetinfo  then
      
        if targetinfo.targetId == 1010 then 
            EventManager.Fire('Event.Goto', {id = "oneDragon"})
            GlobalHooks.CloseUI(GlobalHooks.UITAG.GameUITeamMain)
        elseif targetinfo.targetId == 5010 or targetinfo.targetId == 5020 then 
            EventManager.Fire('Event.Goto', {id = "Lingzhu"})
            GlobalHooks.CloseUI(GlobalHooks.UITAG.GameUITeamMain)
        elseif math.floor(targetinfo.targetId/100)==30 then 
            EventManager.Fire('Event.Goto', {id = "Dreamland"})
        elseif targetinfo.targetId == 1 then
            GameAlertManager.Instance:ShowNotify(Util.GetText(TextConfig.Type.TEAM, "noTarget"))
        else
            _M.RequestGotoTeamTarget(targetinfo.targetId,targetinfo.difficulty,handler)
        end
    else
        
        
        
    end
end


local function handler_newLeaderAutoAccept(evtName,param)
  _M.TeamData.info = _M.TeamData.info or {}
    local targetinfo = _M.TeamData.info.s2c_teamTarget
    if targetinfo  then
      local content = nil
      local okStr = Util.GetText(TextConfig.Type.TEAM, "confirm")
      local cancelStr = Util.GetText(TextConfig.Type.TEAM, "cancelgo")
      if targetinfo.targetId == 1 then
        content =  Util.GetText(TextConfig.Type.TEAM, "isLeader1")
        GameAlertManager.Instance.AlertDialog:ShowAlertDialog(AlertDialog.PRIORITY_NORMAL, content, okStr, nil, nil)
      else
        local db = GlobalHooks.DB.Find('TeamTarget', targetinfo.targetId)
        local text = db.TargetName
        if db.HardChange ~= 0 then
            text = text .."--" .. Util.GetText(TextConfig.Type.FUBEN, "hardName_" .. (targetinfo.difficulty) .. (targetinfo.difficulty)) 
        end
        content =  string.format(Util.GetText(TextConfig.Type.TEAM, "isLeader2"),text)
        GameAlertManager.Instance.AlertDialog:ShowAlertDialog(AlertDialog.PRIORITY_NORMAL, content, okStr, cancelStr, nil, function( ... )
          _M.RequestAutoAccept(1,nil)
        end, nil)
      end



           
    end
end


function _M.initial()
  
  
  EventManager.Subscribe("Hud.Team.Event.ShowInteractive", ShowTeamInteractiveMenu)
  EventManager.Subscribe("Event.TeamGoTarget",handler_goTarget)
  EventManager.Subscribe("Event.NewLeaderAutoAccept",handler_newLeaderAutoAccept)
end

function _M.fin()
  
  
end

function _M.InitNetWork()
  
  
  
  
  
  
  
  
  Pomelo.GameSocket.onSummonTeamPush(GlobalHooks.DynamicPushs.OnSummonTeamPush)
  Pomelo.GameSocket.onTeamTargetPush(GlobalHooks.DynamicPushs.OnTeamTargetPush)
  
  
  Pomelo.GameSocket.onTeamMumberHurtPush(GlobalHooks.DynamicPushs.OnTeamMumberHurtPush)
end

return _M
