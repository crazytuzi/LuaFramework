local _M = {}


function _M.GetGuildAreaListRequest(cb)
    Pomelo.GuildFortHandler.getGuildAreaListRequest(function (ex,sjson)
        if ex then return end
        local data = sjson:ToData()
        print("GetGuildAreaListRequest: ",PrintTable(data))
        cb(data)
    end)
end

function _M.GetGuildAreaDetailRequest(id, cb)
    Pomelo.GuildFortHandler.getGuildAreaDetailRequest(id, function (ex,sjson)
        if ex then return end
        local data = sjson:ToData()
        print("GetGuildAreaDetailRequest: ",PrintTable(data))
        cb(data.areaDetail)
    end)
end

function _M.GetGuildAreaApplyListRequest(id, cb)
    Pomelo.GuildFortHandler.getGuildAreaApplyListRequest(id, function (ex,sjson)
        if ex then return end
        local data = sjson:ToData()
        print("GetGuildAreaApplyListRequest: ",PrintTable(data))
        cb(data)
    end)
end

function _M.ApplyGuildFundRequest(cb)
    Pomelo.GuildFortHandler.applyGuildFundRequest(function (ex,sjson)
        if ex then return end
        local data = sjson:ToData()
        print("ApplyGuildFundRequest: ",PrintTable(data))
        cb(data.guildFund)
    end)
end

function _M.ApplyFundRequest(id, fund, cb)
    Pomelo.GuildFortHandler.applyFundRequest(id, fund, function (ex,sjson)
        if ex then return end
        cb()
    end)
end

function _M.ApplyCancelFundRequest(id, cb)
    Pomelo.GuildFortHandler.applyCancelFundRequest(id, function (ex,sjson)
        if ex then return end
        cb()
    end)
end

function _M.ApplyDailyAwardListRequest(cb)
    Pomelo.GuildFortHandler.applyDailyAwardListRequest(function (ex,sjson)
        if ex then return end
        local data = sjson:ToData()
        print("ApplyDailyAwardListRequest: ",PrintTable(data))
        cb(data.areaAwardList or {})
    end)
end

function _M.ApplyDailyAwardRequest(id, cb)
    Pomelo.GuildFortHandler.applyDailyAwardRequest(id, function (ex,sjson)
        if ex then return end
        cb()
    end)
end

function _M.ApplyAccessRequest(id, fund, cb)
    Pomelo.GuildFortHandler.applyAccessRequest(id, function (ex,sjson)
    end)
end

function _M.ApplyFortGuildInfoRequest(cb)
    Pomelo.GuildFortHandler.applyFortGuildInfoRequest(function (ex,sjson)
        if ex then return end
        local data = sjson:ToData()
        print("ApplyFortGuildInfoRequest: ",PrintTable(data))
        cb(data)
    end)
end

function _M.ApplyAllReportListRequest(cb)
    local function reverseTable(tab) 
        local tmp = {}  
        for i = 1, #tab do  
            local key = #tab  
            tmp[i] = table.remove(tab)
        end  
    
        return tmp  
    end
    Pomelo.GuildFortHandler.applyAllReportListRequest(function (ex,sjson)
        if ex then return end
        local data = sjson:ToData()
        print("ApplyAllReportListRequest: ",PrintTable(data))

        if data and data.reportList and #data.reportList > 0 then
            local tmp = reverseTable(data.reportList)
            cb(tmp)
        else
            cb({})
        end
    end)
end

function _M.ApplyReportDetailRequest(data, areaId, cb)
    Pomelo.GuildFortHandler.applyReportDetailRequest(data, areaId, function (ex,sjson)
        if ex then return end
        local data = sjson:ToData()
        print("ApplyReportDetailRequest: ",PrintTable(data))
        cb(data)
    end)
end

function _M.ApplyReportStatisticsRequest(data, areaId, guildId, cb)
    Pomelo.GuildFortHandler.applyReportStatisticsRequest(data, areaId, guildId, function (ex,sjson)
        if ex then return end
        local data = sjson:ToData()
        print("ApplyReportStatisticsRequest: ",PrintTable(data))
        cb(data.statisticsDetail or {})
    end)
end

function GlobalHooks.DynamicPushs.OnGuildFortPush(ex, json)
    if ex then return end
    local data = json:ToData()
    print("OnGuildFortPush: ", PrintTable(data))
    local param = {ownGuild = data.ownGuild, enemyGuild = data.enemyGuild or nil}
    EventManager.Fire("Event.GuildWar.UpdateGuildWarUI", param)
end

function GlobalHooks.DynamicPushs.OnGuildResultPush(ex, json)
    if ex then return end
    local data = json:ToData()
    print("OnGuildResultPush: ", PrintTable(data))
    local menu, ui = GlobalHooks.OpenUI(GlobalHooks.UITAG.GameUIGuildWarResult, 0)
    ui.SetResultDetail(data)
end

function _M.fin(relogin)

end

function _M.InitNetWork()
    Pomelo.GameSocket.onGuildFortPush(GlobalHooks.DynamicPushs.OnGuildFortPush)
    Pomelo.GameSocket.onGuildResultPush(GlobalHooks.DynamicPushs.OnGuildResultPush)
end

return _M
