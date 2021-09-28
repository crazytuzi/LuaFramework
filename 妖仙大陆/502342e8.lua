local PomeloUtil = require "Zeus.Logic.PomeloUtil"
local Util = require "Zeus.Logic.Util"
local Model = {}

Model.StateNotOpen = 1
Model.StateOpening = 2
Model.StateBattle = 3
Model.StateOver = 4

function Model.requestDungeonList(cb, failCb)
    PomeloUtil.wrapRequest(Pomelo.GuildManagerHandler.guildDungeonListRequest, function (data)
        
        cb(data.s2c_list)
    end, failCb)
end


function Model.requestOpenDungeon(cb)
    Pomelo.GuildManagerHandler.openGuildDungeonRequest(function (ex, sjson)
        if ex then return end

        local data = sjson:ToData()
        
        cb(data.s2c_waitTime)
    end)
end

function Model.requestDungeonRank(rankType, cb, failCb)
    PomeloUtil.wrapRequest(Pomelo.GuildManagerHandler.dungeonRankRequest, function (data)
        
        cb(data.s2c_data)
    end, failCb, rankType)
end

function Model.requestDungeonAward(cb, failCb)
    PomeloUtil.wrapRequest(Pomelo.GuildManagerHandler.dungeonAwardInfoRequest, function (data)
        
        cb(data.diceLeftTime, data.getDungeonScoreInfo, data.itemInfos, data.isFightOver)
    end, failCb)
end

function Model.requestEnterDungeon(enterType, cb)
    enterType = enterType or 1
    cb = cb or emptyFunc
    Pomelo.GuildHandler.joinGuildDungeonRequest(enterType, cb)
end

function Model.requestLeaveDungeon()
    Pomelo.GuildHandler.leaveGuildDungeonRequest(emptyFunc)
end

function Model.requestDice(pos, cb)
    Pomelo.GuildManagerHandler.diceAwardRequest(pos, function(ex, sjson)
        if ex then return end
        local data = sjson:ToData()
        cb(data.s2c_itemInfo)
    end)
end


function Model.onGuildDungeonOpen(ex, sjson)
    print("onGuildDungeonOpen")
    EventManager.Fire('Event.GuildDungeonChange', {})
    GameAlertManager.Instance:ShowAlertDialog(
        AlertDialog.PRIORITY_NORMAL, 
        Util.GetText(TextConfig.Type.GUILD, "guild_Dungeon_confirmEnter"),
        Util.GetText(TextConfig.Type.GUILD, "guild_Dungeon_go"),
        Util.GetText(TextConfig.Type.GUILD, "guild_Dungeon_notGo"),
        Util.GetText(TextConfig.Type.GUILD, "guild_Dungeon_openEnterTitle"),
        nil,
        Model.requestEnterDungeon,
        nil
    )
end

function Model.onGuildDungeonEnd(ex, sjson)
    local data = sjson:ToData()
    
    local menu, ui = GlobalHooks.OpenUI(GlobalHooks.UITAG.GameUIGuildDungeonEnd, 0)
    if ui then
        ui:setData(data.state, data.leftTime, data.awardItem)
    end
end
function Model.onGuildDungeonChange(ex, sjson)
    local data = sjson:ToData()
    
    EventManager.Fire('Event.GuildDungeonChange', {})
end

function Model.initial()
    
end

function Model.InitNetWork()
    Pomelo.GuildHandler.onDungeonEndPush(Model.onGuildDungeonEnd)
    Pomelo.GuildHandler.guildDungeonOpenPush(Model.onGuildDungeonOpen)
    Pomelo.GuildHandler.guildDungeonPassPush(Model.onGuildDungeonChange)
    Pomelo.GuildHandler.guildDungeonPlayerNumPush(Model.onGuildDungeonChange)
end


return Model
