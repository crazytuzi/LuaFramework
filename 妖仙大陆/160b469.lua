local _M = {}
_M.__index = _M


local DisplayUtil = require "Zeus.Logic.DisplayUtil"

local GuildInfo = nil
local GuildList = nil
local MyGuildInfo = nil
local MembersList = nil
local remainKickCount = 0
local curMemberId = nil
local GuildRecord = {}
local MyInfoFromGuild = nil

local function sortMember()
  
  table.sort(MembersList,function (a,b)
    if b.job == 1 then
      return false
    elseif a.job ~= 1 and b.playerId == DataMgr.Instance.UserData.RoleID then
      return false
    elseif a.onlineState == b.onlineState then
      if a.job == b.job then
        return a.level > b.level
      else
        return a.job < b.job
      end
    else
      return a.onlineState > b.onlineState
    end
  end)
end

local function GetTextConfg(key)
  return ConfigMgr.Instance.TxtCfg:GetTextByKey(TextConfig.Type.GUILD, key)
end

function _M.getMyGuildInfoRequest(cb) 
  Pomelo.GuildHandler.getMyGuildInfoRequest(function (ex,sjson)
    if not ex then
      local msg = sjson:ToData()
      
      MyGuildInfo = msg.s2c_guildInfo
      cb(msg.s2c_guildInfo)
    end
  end)
end

function _M.getMyGuildInfoRequestWithoutWait(cb) 
  
  if not DataMgr.Instance.UserData.Guild then 
    cb({})
    return
  end

  Pomelo.GuildHandler.getMyGuildInfoRequest(function (ex,sjson)
    if not ex then
      local msg = sjson:ToData()
      MyGuildInfo = msg.s2c_guildInfo

      cb(msg.s2c_guildInfo or {})
    end
  end, XmdsNetManage.PackExtData.New(false, true))
end

function _M.createGuildRequest(c2s_icon,c2s_name,c2s_qqGroup,cb)
  Pomelo.GuildHandler.createGuildRequest(c2s_icon,c2s_name,c2s_qqGroup,function (ex,sjson)
    if not ex then
      local msg = sjson:ToData()
      
      MyGuildInfo = msg.s2c_guildInfo
      cb(msg)
    end
  end)
end

function _M.getGuildListRequest(c2s_name,cb)
  Pomelo.GuildHandler.getGuildListRequest(c2s_name,function (ex,sjson)
    if not ex then
      local msg = sjson:ToData()
      
      if not c2s_name then
        GuildList = msg.s2c_guildList
      end
      cb(msg.s2c_guildList)
    end
  end)
end

function _M.joinGuildRequest(c2s_guildId,cb)
  Pomelo.GuildHandler.joinGuildRequest(c2s_guildId,function (ex,sjson)
    if not ex then
      local msg = sjson:ToData()
      
      cb(msg)
    end
  end)
end

function _M.joinGuildOfPlayerRequest(c2s_playerId,cb)
  Pomelo.GuildHandler.joinGuildOfPlayerRequest(c2s_playerId,function (ex,sjson)
    if not ex then
      local msg = sjson:ToData()
      cb()
    end
  end)
end

function _M.getMyGuildMembersRequest(cb)
  Pomelo.GuildHandler.getMyGuildMembersRequest(function (ex,sjson)
    if not ex then
      local msg = sjson:ToData()
      
      MembersList = msg.s2c_memberList
      sortMember()
      remainKickCount = msg.s2c_leftKickNum or 0
      cb(msg)
    end
  end)
end

function _M.getApplyListRequest(cb)
  Pomelo.GuildHandler.getApplyListRequest(function (ex,sjson)
    if not ex then
      local msg = sjson:ToData()
     
      cb(msg.s2c_applyList)
    end
  end)
end

function _M.dealApplyRequest(c2s_applyId,c2s_operate,cb)
  Pomelo.GuildHandler.dealApplyRequest(c2s_applyId,c2s_operate,function (ex,sjson)
    if not ex then
      local msg = sjson:ToData()
      
      cb()
    end
  end)
end

function _M.setGuildInfoRequest(entryLevel,guildMode,entryUpLevel,cb)
  Pomelo.GuildHandler.setGuildInfoRequest(entryLevel,guildMode,entryUpLevel,function (ex,sjson)
    if not ex then
      local msg = sjson:ToData()
      
      MyGuildInfo.baseInfo.entryLevel = entryLevel
      MyGuildInfo.baseInfo.guildMode = guildMode
      MyGuildInfo.baseInfo.entryUpLevel = entryUpLevel
      cb()
    end
  end)
end

function _M.exitGuildRequest(cb)
  Pomelo.GuildHandler.exitGuildRequest(function (ex,sjson)
    if not ex then
      local msg = sjson:ToData()
      
      cb()
    end
  end)
end

function _M.kickMemberRequest(c2s_applyId,cb)
  Pomelo.GuildHandler.kickMemberRequest(c2s_applyId,function (ex,sjson)
    if not ex then
      local msg = sjson:ToData()
      
      remainKickCount = msg.s2c_leftKickNum or 0
      cb(remainKickCount)
    end
  end)
end

function _M.setGuildQQGroupRequest(qqGroup,cb)
  Pomelo.GuildHandler.setGuildQQGroupRequest(qqGroup,function (ex,sjson)
    if not ex then
      local msg = sjson:ToData()
      
      cb()
    end
  end)
end

function _M.upgradeGuildLevelRequest(cb)
  Pomelo.GuildHandler.upgradeGuildLevelRequest(function (ex,sjson)
    if not ex then
      local msg = sjson:ToData()
      MyGuildInfo = msg.s2c_guildInfo
      
      cb()
    end
  end)
end

function _M.changeGuildNoticeRequest(notice,cb)
  Pomelo.GuildHandler.changeGuildNoticeRequest(notice,function (ex,sjson)
    if not ex then
      local msg = sjson:ToData()
      
      
      
      MyGuildInfo.notice = msg.s2c_notice
      cb(msg.s2c_notice)
    end
  end)
end

function _M.changeGuildNameRequest(name,cb)
  Pomelo.GuildHandler.changeGuildNameRequest(name,function (ex,sjson)
    if not ex then
      local msg = sjson:ToData()
      
      cb()
    end
  end)
end

function _M.changeOfficeNameRequest(officeNames,cb)
  Pomelo.GuildHandler.changeOfficeNameRequest(officeNames,function (ex,sjson)
    if not ex then
      local msg = sjson:ToData()
      MyGuildInfo.officeNames = officeNames
      
      cb()
    end
  end)
end

function _M.contributeToGuildRequest(type,times,cb)
  Pomelo.GuildHandler.contributeToGuildRequest(type,times,function (ex,sjson)
    if not ex then
      local msg = sjson:ToData()
      MyGuildInfo = msg.s2c_guildInfo
      
      cb()
    end
  end)
end

function _M.setMemberJobRequest(memberId,job,cb)
  Pomelo.GuildHandler.setMemberJobRequest(memberId,job,function (ex,sjson)
    if not ex then
      local msg = sjson:ToData()
      
      cb()
    end
  end)
end

function _M.transferPresidentRequest(memberId,cb)
  Pomelo.GuildHandler.transferPresidentRequest(memberId,function (ex,sjson)
    if not ex then
      local msg = sjson:ToData()
      MembersList = msg.s2c_memberList
      sortMember()
      MyGuildInfo = msg.s2c_guildInfo
      
      cb()
    end
  end)
end

function _M.getGuildRecordRequest(page,cb)
  Pomelo.GuildHandler.getGuildRecordRequest(page,function (ex,sjson)
    if not ex then
      local msg = sjson:ToData()
      
      GuildRecord[msg.s2c_page] = msg.s2c_recordList
      cb(msg.s2c_page)
    end
  end)
end

function _M.impeachGuildPresidentRequest(cb)
  Pomelo.GuildHandler.impeachGuildPresidentRequest(function (ex,sjson)
    if not ex then
      local msg = sjson:ToData()
      
      cb()
    end
  end)
end

function _M.getGuildMoneyRequest(cb)
  Pomelo.GuildHandler.getGuildMoneyRequest(function (ex,sjson)
    if not ex then
      local msg = sjson:ToData()
      
      cb(msg.depositCount,msg.depositCountMax)
    end
  end)
end

function _M.getBuildingLevelRequest(cb)
  Pomelo.GuildManagerHandler.getBuildingLevelRequest(function (ex,sjson)
    if not ex then
      local msg = sjson:ToData()
      cb(msg.s2c_levelInfo)
    end
  end)
end

function _M.invitePlayerJoinMyGuildRequest(c2s_playerId)
  Pomelo.GuildHandler.invitePlayerJoinMyGuildRequest(c2s_playerId,function (ex,sjson)
    if not ex then
      local msg = sjson:ToData()
    end
  end)
end

local function agreeOrRefuseInviteRequest(c2s_isAgree,c2s_inviteId,c2s_guildId,cb)
  Pomelo.GuildHandler.agreeOrRefuseInviteRequest(c2s_isAgree,c2s_inviteId,c2s_guildId,function (ex,sjson)
    if not ex then
      local msg = sjson:ToData()
      print ("c2s_isAgree = "..c2s_isAgree)
    end
  end)
end

function _M.GetGuildBossInfoRequest(cb)
  Pomelo.GuildBossHandler.getGuildBossInfoRequest(function (ex,sjson)
    if not ex then
      local msg = sjson:ToData()
      cb(msg)
    end
  end)
end

function _M.EnterGuildBossAreaRequest(cb)
  Pomelo.GuildBossHandler.enterGuildBossAreaRequest(function (ex,sjson)
    if not ex then
      local msg = sjson:ToData()
      cb()
    end
  end)
end

function _M.GuildBossInspireRequest(index)
  Pomelo.GuildBossHandler.guildBossInspireRequest(index,function (ex,sjson)
    
    
    
  end)
end

function _M.GetMyGuildInfo()
  return MyGuildInfo
end

function _M.GetGuildList()
  return GuildList
end

function _M.GetMembersList()
  return MembersList
end

function _M.GetRemainKickCount()
  return remainKickCount
end

function _M.ChangeMemberToId(id)
  curMemberId = id
end

function _M.getCurMemberId()
  return curMemberId
end

function _M.getGuildRecord()
  return GuildRecord
end

function _M.setFouns(fundvalue)
  MyGuildInfo.fund = fundvalue
end

function _M.setContribution(value)
  MyGuildInfo.myInfo.currentContribute = value
end

function _M.GetMyInfoFromGuild()
  local function findmine()
    for k,v in pairs(MembersList) do
      if v.playerId == DataMgr.Instance.UserData.RoleID then
        local tab = {}
        tab = v
        return tab
      end
    end
  end

  if MembersList then
    MyInfoFromGuild = findmine()
    return MyInfoFromGuild
  end
  return 1
end


function GlobalHooks.DynamicPushs.GuildChangePush(ex, sjson)
  if ex == nil then
    local msg = sjson:ToData()
    
    if msg.isIn == 1 then
      EventManager.Fire('Event.Menu.InGuild', {})
    elseif msg.isOut == 1 then
      for i=3300,3333 do
        local node, luaobj = GlobalHooks.FindUI(i, 0)
        if node then
          node:Close()
        end
      end
    elseif msg.job and msg.jobName then
      if MembersList then
        for k,v in pairs(MembersList) do
          if v.playerId == DataMgr.Instance.UserData.RoleID then
            v.job = msg.job
            v.jobName = msg.jobName
            break
          end
        end
      end
    elseif msg.guildName then
      MyGuildInfo.baseInfo.name = msg.guildName
    elseif msg.timesList then
      
    end
  end
end

function GlobalHooks.DynamicPushs.GuildInvitePush(ex, sjson)
  if ex == nil then
    local msg = sjson:ToData()
    
    local namestr = DisplayUtil.playerHtmlName(msg.playerName,msg.playerPro)
    GameAlertManager.Instance:ShowAlertDialog(
        AlertDialog.PRIORITY_NORMAL, 
        string.format(GetTextConfg("guild_invite_tips"),namestr,msg.guildLevel,msg.guildName),
        GetTextConfg("guild_invite_sure"),
        GetTextConfg("guild_invite_cancel"),
        GetTextConfg("guild_invite_title"),
        nil,
        function()
          agreeOrRefuseInviteRequest(1,msg.playerId,msg.guildId)
        end,
        function ()
          agreeOrRefuseInviteRequest(0,msg.playerId,msg.guildId)
        end
    )
  end
end

function GlobalHooks.DynamicPushs.HurtRankChangePush(ex, sjson)
  if ex == nil then
    local msg = sjson:ToData()
    EventManager.Fire('Event.GuildBoss.HurtPush', {data = msg})
  end
end

function GlobalHooks.DynamicPushs.InspireChangePush(ex, sjson)
  if ex == nil then
    local msg = sjson:ToData()
    EventManager.Fire('Event.GuildBoss.InspireChange', {data = msg})
  end
end

function GlobalHooks.DynamicPushs.EndGuildBossPush(ex, sjson)
  if ex == nil then
    local msg = sjson:ToData()
    local node,lua_obj = GlobalHooks.OpenUI(GlobalHooks.UITAG.GameUIGuildBossEnd,0)
    lua_obj.SetEndInfo(msg)
  end
end

function GlobalHooks.DynamicPushs.QuitGuildBossPush(ex, sjson)
  if ex == nil then
    local msg = sjson:ToData()
    EventManager.Fire('Event.GuildBoss.QuitGuildBoss', {cd = msg.endSeconds or 0})
  end
end

function _M.InitNetWork()
  Pomelo.GuildHandler.guildRefreshPush(GlobalHooks.DynamicPushs.GuildChangePush)
  Pomelo.GuildHandler.guildInvitePush(GlobalHooks.DynamicPushs.GuildInvitePush)
  Pomelo.GuildBossHandler.onHurtRankChangePush(GlobalHooks.DynamicPushs.HurtRankChangePush)
  Pomelo.GuildBossHandler.onInspireChangePush(GlobalHooks.DynamicPushs.InspireChangePush)
  Pomelo.GuildBossHandler.onEndGuildBossPush(GlobalHooks.DynamicPushs.EndGuildBossPush)
  Pomelo.GuildBossHandler.onQuitGuildBossPush(GlobalHooks.DynamicPushs.QuitGuildBossPush)
end

return _M
