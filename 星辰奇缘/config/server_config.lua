ServerConfig = ServerConfig or {}

-- 获取服务器列表用这个方法
ServerConfig.GetServers = function()
    if ctx.ServerListConfig and ctx.ServerListConfig.table ~= nil and ctx.ServerListConfig.table.error ~= "1" then
        -- BaseUtils.dump(ctx.ServerListConfig.table,"转换结果")
        for i,v in ipairs(ctx.ServerListConfig.table.msg.server_list) do
            ctx.ServerListConfig.table.msg.server_list[i].begin_time = tonumber(ctx.ServerListConfig.table.msg.server_list[i].begin_time)
            ctx.ServerListConfig.table.msg.server_list[i].end_time = tonumber(ctx.ServerListConfig.table.msg.server_list[i].end_time)
            ctx.ServerListConfig.table.msg.server_list[i].port = tonumber(ctx.ServerListConfig.table.msg.server_list[i].port)
            ctx.ServerListConfig.table.msg.server_list[i].zone_id = tonumber(ctx.ServerListConfig.table.msg.server_list[i].zone_id)
        end
        ctx.ServerListConfig.table.msg.servers = ServerConfig.servers --ctx.ServerListConfig.table.msg.server_list
        return ctx.ServerListConfig.table.msg
    elseif LoginManager.Instance.window ~= nil and LoginManager.Instance.window.isLocalList then
        return ServerConfig
    else
        NoticeManager.Instance:FloatTipsByString(TI18N("服务器列表加载失败，请稍后重试"))
        ServerConfig.servers = {}
        return ServerConfig
    end
end

-- 默认服务器列表，不要直接使用
-- {name = "开发服", host = "192.168.1.101", port = 8001, platform = "dev", zone_id = 1, begin_time = 1351527200, end_time = 1651613600, first_zone = "1", recomed = "1", isnew = "0", hot = "1", roles = {}} ,
ServerConfig.servers = {

    {name = "測試服務1212", host = "222.186.173.217", port = 8001, platform = "dev", zone_id = 1, begin_time = 1351527200, end_time = 1651613600, first_zone = "0", recomed = "0", isnew = "0", hot = "0", roles = {}},

    -- {name = "最新未开服", host = "192.168.1.101", port = 8001, platform = "dev", zone_id = 1, begin_time = 1458309876, end_time = 1651613600, first_zone = "0", recomed = "1", isnew = "1", hot = "1", roles = {}} ,
    -- {name = "开发服", host = "192.168.1.101", port = 8001, platform = "dev", zone_id = 1, begin_time = 1351527200, end_time = 1651613600, first_zone = "1", recomed = "1", isnew = "1", hot = "1", roles = {}} ,
    -- {name = "开发服2", host = "192.168.1.101", port = 8002, platform = "dev", zone_id = 2, begin_time = 1351527200, end_time = 1651613600, first_zone = "1", recomed = "1", isnew = "1", hot = "1", roles = {}} ,
    -- {name = "开发服3", host = "192.168.1.101", port = 8003, platform = "dev", zone_id = 3, begin_time = 1351527200, end_time = 1651613600, first_zone = "1", recomed = "1", isnew = "1", hot = "1", roles = {}} ,
    -- {name = "开发服4", host = "192.168.1.101", port = 8004, platform = "dev", zone_id = 4, begin_time = 1351527200, end_time = 1651613600, first_zone = "1", recomed = "1", isnew = "1", hot = "1", roles = {}} ,
    -- {name = "IOS测试1", host = "192.168.1.101", port = 8001, platform = "ios", zone_id = 1, begin_time = 1351527200, end_time = 1651613600, first_zone = "1", recomed = "1", isnew = "1", hot = "1", roles = {}} ,
    -- {name = "IOS测试2", host = "192.168.1.101", port = 8001, platform = "ios", zone_id = 2, begin_time = 1351527200, end_time = 1651613600, first_zone = "1", recomed = "1", isnew = "1", hot = "1", roles = {}} ,
    -- {name = "IOS测试3", host = "192.168.1.101", port = 8001, platform = "ios", zone_id = 3, begin_time = 1351527200, end_time = 1651613600, first_zone = "1", recomed = "1", isnew = "1", hot = "1", roles = {}} ,
    -- {name = "IOS测试4", host = "192.168.1.101", port = 8001, platform = "ios", zone_id = 4, begin_time = 1351527200, end_time = 1651613600, first_zone = "1", recomed = "1", isnew = "1", hot = "1", roles = {}} ,
    -- {name = "IOS测试6", host = "192.168.1.101", port = 8001, platform = "ios", zone_id = 6, begin_time = 1351527200, end_time = 1651613600, first_zone = "1", recomed = "1", isnew = "1", hot = "1", roles = {}} ,
    -- {name = "IOS测试7", host = "192.168.1.101", port = 8001, platform = "ios", zone_id = 7, begin_time = 1351527200, end_time = 1651613600, first_zone = "1", recomed = "1", isnew = "1", hot = "1", roles = {}} ,
    -- {name = "IOS测试8", host = "192.168.1.101", port = 8001, platform = "ios", zone_id = 8, begin_time = 1351527200, end_time = 1651613600, first_zone = "1", recomed = "1", isnew = "1", hot = "1", roles = {}} ,
    -- {name = "IOS测试9", host = "192.168.1.101", port = 8001, platform = "ios", zone_id = 9, begin_time = 1351527200, end_time = 1651613600, first_zone = "1", recomed = "1", isnew = "1", hot = "1", roles = {}} ,
    -- {name = "IOS测试10", host = "192.168.1.101", port = 8001, platform = "ios", zone_id = 10, begin_time = 1351527200, end_time = 1651613600, first_zone = "1", recomed = "1", isnew = "1", hot = "1", roles = {}} ,
    -- {name = "IOS测试11", host = "192.168.1.101", port = 8001, platform = "ios", zone_id = 11, begin_time = 1351527200, end_time = 1651613600, first_zone = "1", recomed = "1", isnew = "1", hot = "1", roles = {}} ,
    -- {name = "IOS测试14", host = "192.168.1.101", port = 8001, platform = "ios", zone_id = 14, begin_time = 1351527200, end_time = 1651613600, first_zone = "1", recomed = "1", isnew = "1", hot = "1", roles = {}} ,
    -- {name = "IOS测试15", host = "192.168.1.101", port = 8001, platform = "ios", zone_id = 15, begin_time = 1351527200, end_time = 1651613600, first_zone = "1", recomed = "1", isnew = "1", hot = "1", roles = {}} ,
    -- {name = "IOS测试16", host = "192.168.1.101", port = 8001, platform = "ios", zone_id = 16, begin_time = 1351527200, end_time = 1651613600, first_zone = "1", recomed = "1", isnew = "1", hot = "1", roles = {}} ,
    -- {name = "IOS测试18", host = "192.168.1.101", port = 8001, platform = "ios", zone_id = 18, begin_time = 1351527200, end_time = 1651613600, first_zone = "1", recomed = "1", isnew = "1", hot = "1", roles = {}} ,
    -- {name = "IOS测试19", host = "192.168.1.101", port = 8001, platform = "ios", zone_id = 19, begin_time = 1351527200, end_time = 1651613600, first_zone = "1", recomed = "1", isnew = "1", hot = "1", roles = {}} ,
    -- {name = "IOS测试23", host = "192.168.1.101", port = 8001, platform = "ios", zone_id = 23, begin_time = 1351527200, end_time = 1651613600, first_zone = "1", recomed = "1", isnew = "1", hot = "1", roles = {}} ,
    -- {name = "IOS测试25", host = "192.168.1.101", port = 8001, platform = "ios", zone_id = 25, begin_time = 1351527200, end_time = 1651613600, first_zone = "1", recomed = "1", isnew = "1", hot = "1", roles = {}} ,
    -- {name = "IOS测试29", host = "192.168.1.101", port = 8001, platform = "ios", zone_id = 29, begin_time = 1351527200, end_time = 1651613600, first_zone = "1", recomed = "1", isnew = "1", hot = "1", roles = {}} ,
    -- {name = "IOS测试33", host = "192.168.1.101", port = 8001, platform = "ios", zone_id = 33, begin_time = 1351527200, end_time = 1651613600, first_zone = "1", recomed = "1", isnew = "1", hot = "1", roles = {}} ,
    -- {name = "IOS测试34", host = "192.168.1.101", port = 8001, platform = "ios", zone_id = 34, begin_time = 1351527200, end_time = 1651613600, first_zone = "1", recomed = "1", isnew = "1", hot = "1", roles = {}} ,
    -- {name = "IOS测试36", host = "192.168.1.101", port = 8001, platform = "ios", zone_id = 36, begin_time = 1351527200, end_time = 1651613600, first_zone = "1", recomed = "1", isnew = "1", hot = "1", roles = {}} ,
    -- {name = "IOS测试42", host = "192.168.1.101", port = 8001, platform = "ios", zone_id = 42, begin_time = 1351527200, end_time = 1651613600, first_zone = "1", recomed = "1", isnew = "1", hot = "1", roles = {}} ,
    -- {name = "IOS测试44", host = "192.168.1.101", port = 8001, platform = "ios", zone_id = 44, begin_time = 1351527200, end_time = 1651613600, first_zone = "1", recomed = "1", isnew = "1", hot = "1", roles = {}} ,
    -- {name = "IOS测试45", host = "192.168.1.101", port = 8001, platform = "ios", zone_id = 45, begin_time = 1351527200, end_time = 1651613600, first_zone = "1", recomed = "1", isnew = "1", hot = "1", roles = {}} ,
    -- {name = "IOS测试48", host = "192.168.1.101", port = 8001, platform = "ios", zone_id = 48, begin_time = 1351527200, end_time = 1651613600, first_zone = "1", recomed = "1", isnew = "1", hot = "1", roles = {}} ,
    -- {name = "IOS测试49", host = "192.168.1.101", port = 8001, platform = "ios", zone_id = 49, begin_time = 1351527200, end_time = 1651613600, first_zone = "1", recomed = "1", isnew = "1", hot = "1", roles = {}} ,
    -- -- {name = "星辰守护", host = "s3.ios.xcqy.shiyuegame.com", port = 8003, platform = "ios", zone_id = 3, begin_time = 1351527200, end_time = 1651613600, first_zone = "0", recomed = "0", isnew = "1", hot = "1", roles = {}},
    -- -- {name = "破晓之光", host = "s2.ios.xcqy.shiyuegame.com", port = 8002, platform = "ios", zone_id = 2, begin_time = 1351527200, end_time = 1651613600, first_zone = "0", recomed = "1", isnew = "1", hot = "1", roles = {}},
    -- -- {name = "盛世奇缘", host = "s1.ios.xcqy.shiyuegame.com", port = 8001, platform = "ios", zone_id = 1, begin_time = 1351527200, end_time = 1651613600, first_zone = "0", recomed = "1", isnew = "1", hot = "1", roles = {}},
    -- -- {name = "永恒星光", host = "s7.beta.xcqy.shiyuegame.com", port = 8107, platform = "beta", zone_id = 7, begin_time = 1351527200, end_time = 1651613600, first_zone = "0", recomed = "1", isnew = "0", hot = "1", roles = {}},
    -- -- {name = "风色物语", host = "s6.beta.xcqy.shiyuegame.com", port = 8106, platform = "beta", zone_id = 6, begin_time = 1351527200, end_time = 1651613600, first_zone = "0", recomed = "1", isnew = "0", hot = "1", roles = {}},
    -- -- {name = "精灵之森", host = "s5.beta.xcqy.shiyuegame.com", port = 8005, platform = "beta", zone_id = 5, begin_time = 1351527200, end_time = 1651613600, first_zone = "0", recomed = "1", isnew = "0", hot = "1", roles = {}},
    -- -- {name = "月痕海岸", host = "s4.beta.xcqy.shiyuegame.com", port = 8004, platform = "beta", zone_id = 4, begin_time = 1351527200, end_time = 1651613600, first_zone = "0", recomed = "1", isnew = "0", hot = "1", roles = {}},
    -- -- {name = "飞瀑小村", host = "s3.beta.xcqy.shiyuegame.com", port = 8003, platform = "beta", zone_id = 3, begin_time = 1351527200, end_time = 1651613600, first_zone = "0", recomed = "1", isnew = "0", hot = "1", roles = {}},
    -- -- {name = "绯月大陆", host = "s2.beta.xcqy.shiyuegame.com", port = 8002, platform = "beta", zone_id = 2, begin_time = 1351527200, end_time = 1651613600, first_zone = "0", recomed = "1", isnew = "0", hot = "1", roles = {}},
    -- {name = "梦幻之旅", host = "s1.beta.xcqy.shiyuegame.com", port = 8001, platform = "beta", zone_id = 1, begin_time = 1351527200, end_time = 1651613600, first_zone = "1", recomed = "1", isnew = "0", hot = "1", roles = {}},
    -- {name = "外服", host = "182.254.155.64", port = 8001, platform = "test", zone_id = 1, begin_time = 1351527200, end_time = 1651613600, first_zone = "0", recomed = "0", isnew = "0", hot = "0", roles = {}},
    -- {name = "外网测试服", host = "s1.test.xcqy.shiyuegame.com", port = 8001, platform = "test", zone_id = 1, begin_time = 1351527200, end_time = 1651613600, first_zone = "1", recomed = "0", isnew = "0", hot = "0", roles = {}},
    -- {name = "星辰奇缘", host = "s3.test.xcqy.shiyuegame.com", port = 8003, platform = "test", zone_id = 3, begin_time = 1351527200, end_time = 1651613600, first_zone = "0", recomed = "1", isnew = "0", hot = "0", roles = {}}, -- 审核用服务器
    -- {name = "安卓评审服", host = "s4.test.xcqy.shiyuegame.com", port = 8004, platform = "test", zone_id = 4, begin_time = 1351527200, end_time = 1651613600, first_zone = "0", recomed = "0", isnew = "0", hot = "1", roles = {}},
    -- {name = "仿梦幻之旅", host = "192.168.1.101", port = 8001, platform = "beta", zone_id = 1, begin_time = 1351527200, end_time = 1651613600, first_zone = "1", recomed = "0", isnew = "0", hot = "0", roles = {}},
    -- {name = "仿Beta2", host = "192.168.1.101", port = 8001, platform = "beta", zone_id = 2, begin_time = 1351527200, end_time = 1651613600, first_zone = "1", recomed = "0", isnew = "0", hot = "0", roles = {}},
    -- {name = "仿Beta3", host = "192.168.1.101", port = 8001, platform = "beta", zone_id = 3, begin_time = 1351527200, end_time = 1651613600, first_zone = "1", recomed = "0", isnew = "0", hot = "0", roles = {}},
    -- {name = "仿Beta4", host = "192.168.1.101", port = 8001, platform = "beta", zone_id = 4, begin_time = 1351527200, end_time = 1651613600, first_zone = "1", recomed = "0", isnew = "0", hot = "0", roles = {}},
    -- {name = "仿Beta5", host = "192.168.1.101", port = 8001, platform = "beta", zone_id = 5, begin_time = 1351527200, end_time = 1651613600, first_zone = "1", recomed = "0", isnew = "0", hot = "0", roles = {}},
    -- {name = "仿Beta6", host = "192.168.1.101", port = 8001, platform = "beta", zone_id = 6, begin_time = 1351527200, end_time = 1651613600, first_zone = "1", recomed = "0", isnew = "0", hot = "0", roles = {}},
    -- {name = "仿Beta7", host = "192.168.1.101", port = 8001, platform = "beta", zone_id = 7, begin_time = 1351527200, end_time = 1651613600, first_zone = "1", recomed = "0", isnew = "0", hot = "0", roles = {}},
    -- {name = "仿Beta8", host = "192.168.1.101", port = 8001, platform = "beta", zone_id = 8, begin_time = 1351527200, end_time = 1651613600, first_zone = "1", recomed = "0", isnew = "0", hot = "0", roles = {}},
    -- {name = "仿Beta9", host = "192.168.1.101", port = 8001, platform = "beta", zone_id = 9, begin_time = 1351527200, end_time = 1651613600, first_zone = "1", recomed = "0", isnew = "0", hot = "0", roles = {}},
    -- {name = "仿Beta10", host = "192.168.1.101", port = 8001, platform = "beta", zone_id = 10, begin_time = 1351527200, end_time = 1651613600, first_zone = "1", recomed = "0", isnew = "0", hot = "0", roles = {}},
    -- {name = "仿Beta11", host = "192.168.1.101", port = 8001, platform = "beta", zone_id = 11, begin_time = 1351527200, end_time = 1651613600, first_zone = "1", recomed = "0", isnew = "0", hot = "0", roles = {}},
    -- {name = "仿Beta12", host = "192.168.1.101", port = 8001, platform = "beta", zone_id = 12, begin_time = 1351527200, end_time = 1651613600, first_zone = "1", recomed = "0", isnew = "0", hot = "0", roles = {}},
    -- {name = "仿Beta13", host = "192.168.1.101", port = 8001, platform = "beta", zone_id = 13, begin_time = 1351527200, end_time = 1651613600, first_zone = "1", recomed = "0", isnew = "0", hot = "0", roles = {}},
    -- {name = "仿Beta14", host = "192.168.1.101", port = 8001, platform = "beta", zone_id = 14, begin_time = 1351527200, end_time = 1651613600, first_zone = "1", recomed = "0", isnew = "0", hot = "0", roles = {}},
    -- {name = "仿Beta15", host = "192.168.1.101", port = 8001, platform = "beta", zone_id = 15, begin_time = 1351527200, end_time = 1651613600, first_zone = "1", recomed = "0", isnew = "0", hot = "0", roles = {}},
    -- {name = "仿Beta16", host = "192.168.1.101", port = 8001, platform = "beta", zone_id = 16, begin_time = 1351527200, end_time = 1651613600, first_zone = "1", recomed = "0", isnew = "0", hot = "0", roles = {}},
    -- {name = "欧阳VM", host = "192.168.1.102", port = 8001, platform = "local", zone_id = 1, begin_time = 1351527200, end_time = 1651613600, first_zone = "0", recomed = "0", isnew = "0", hot = "0", roles = {}},
    -- {name = "争记本地", host = "192.168.0.15", port = 8001, platform = "local", zone_id = 1, begin_time = 1351527200, end_time = 1651613600, first_zone = "0", recomed = "0", isnew = "0", hot = "0", roles = {rid = "1", class = "3", sex = "1", lev = "63", name = "2测试用名"}},
    -- {name = "争记VM", host = "192.168.0.175", port = 8001, platform = "local", zone_id = 1, begin_time = 1351527200, end_time = 1651613600, first_zone = "0", recomed = "0", isnew = "0", hot = "0", roles = {}},
    -- {name = "欧阳本地", host = "192.168.0.14", port = 8001, platform = "local", zone_id = 1, begin_time = 1351527200, end_time = 1651613600, first_zone = "0", recomed = "0", isnew = "0", hot = "0", roles = {rid = "1", class = "2", sex = "0", lev = "87", name = "3测试用名"}},
    -- {name = "文龙本地", host = "192.168.0.57", port = 8001, platform = "local", zone_id = 1, begin_time = 1351527200, end_time = 1651613600, first_zone = "0", recomed = "0", isnew = "0", hot = "0", roles = {rid = "1", class = "1", sex = "1", lev = "32", name = "4测试用名"}},
    -- {name = "IT-VM", host = "192.168.1.104", port = 8001, platform = "local", zone_id = 1, begin_time = 1351527200, end_time = 1651613600, first_zone = "0", recomed = "0", isnew = "0", hot = "0", roles = {}},
    -- {name = "IT-VM2", host = "192.168.1.104", port = 8002, platform = "local", zone_id = 2, begin_time = 1351527200, end_time = 1651613600, first_zone = "0", recomed = "0", isnew = "0", hot = "0", roles = {}},
    -- {name = "IT-VM3", host = "192.168.1.104", port = 8003, platform = "local", zone_id = 3, begin_time = 1351527200, end_time = 1651613600, first_zone = "0", recomed = "0", isnew = "0", hot = "0", roles = {}},
    -- {name = "大包本地", host = "192.168.0.18", port = 8001, platform = "local", zone_id = 1, begin_time = 1351527200, end_time = 1651613600, first_zone = "0", recomed = "0", isnew = "0", hot = "0", roles = {}},
    -- {name = "广哥VM", host = "192.168.1.202", port = 8001, platform = "local", zone_id = 1, begin_time = 1351527200, end_time = 1651613600, first_zone = "0", recomed = "0", isnew = "0", hot = "0", roles = {}},
    -- {name = "广哥VM2", host = "192.168.1.202", port = 8002, platform = "local", zone_id = 2, begin_time = 1351527200, end_time = 1651613600, first_zone = "0", recomed = "0", isnew = "0", hot = "0", roles = {}},
    -- {name = "广哥VM3", host = "192.168.1.202", port = 8003, platform = "local", zone_id = 3, begin_time = 1351527200, end_time = 1651613600, first_zone = "0", recomed = "0", isnew = "0", hot = "0", roles = {}},
    -- {name = "文龙VM", host = "192.168.1.103", port = 8001, platform = "local", zone_id = 1, begin_time = 1351527200, end_time = 1651613600, first_zone = "0", recomed = "0", isnew = "0", hot = "0", roles = {}},
    -- {name = "本机", host = "127.0.0.1", port = 8001, platform = "local", zone_id = 1, begin_time = 1351527200, end_time = 1651613600, first_zone = "1", recomed = "0", isnew = "0", hot = "0", roles = {}},
    -- {name = "本机2", host = "127.0.0.1", port = 8002, platform = "local", zone_id = 2, begin_time = 1351527200, end_time = 1651613600, first_zone = "1", recomed = "0", isnew = "0", hot = "0", roles = {}},
    -- {name = "本机3", host = "127.0.0.1", port = 8003, platform = "local", zone_id = 3, begin_time = 1351527200, end_time = 1651613600, first_zone = "1", recomed = "0", isnew = "0", hot = "0", roles = {}},
    -- {name = "本机4", host = "127.0.0.1", port = 8004, platform = "local", zone_id = 4, begin_time = 1351527200, end_time = 1651613600, first_zone = "1", recomed = "0", isnew = "0", hot = "0", roles = {}},
    -- {name = "本机5", host = "127.0.0.1", port = 8005, platform = "local", zone_id = 5, begin_time = 1351527200, end_time = 1651613600, first_zone = "1", recomed = "0", isnew = "0", hot = "0", roles = {}},
    -- {name = "本机11", host = "127.0.0.1", port = 8011, platform = "local", zone_id = 11, begin_time = 1351527200, end_time = 1651613600, first_zone = "1", recomed = "0", isnew = "0", hot = "0", roles = {}},
    -- {name = "仿ios1服", host = "192.168.1.101", port = 8001, platform = "ios", zone_id = 1, begin_time = 1351527200, end_time = 1651613600, first_zone = "0", recomed = "0", isnew = "0", hot = "0", roles = {}},
    -- {name = "仿ios2服", host = "192.168.1.101", port = 8001, platform = "ios", zone_id = 2, begin_time = 1351527200, end_time = 1651613600, first_zone = "0", recomed = "0", isnew = "0", hot = "0", roles = {}},
    -- {name = "仿ios3服", host = "192.168.1.101", port = 8001, platform = "ios", zone_id = 3, begin_time = 1351527200, end_time = 1651613600, first_zone = "0", recomed = "0", isnew = "0", hot = "0", roles = {}},
    -- {name = "仿ios4服", host = "192.168.1.101", port = 8001, platform = "ios", zone_id = 4, begin_time = 1351527200, end_time = 1651613600, first_zone = "0", recomed = "0", isnew = "0", hot = "0", roles = {}},
    -- {name = "仿ios5服", host = "192.168.1.101", port = 8001, platform = "ios", zone_id = 5, begin_time = 1351527200, end_time = 1651613600, first_zone = "0", recomed = "0", isnew = "0", hot = "0", roles = {}},
    -- {name = "仿ios6服", host = "192.168.1.101", port = 8001, platform = "ios", zone_id = 6, begin_time = 1351527200, end_time = 1651613600, first_zone = "0", recomed = "0", isnew = "0", hot = "0", roles = {}},
    -- {name = "仿ios7服", host = "192.168.1.101", port = 8001, platform = "ios", zone_id = 7, begin_time = 1351527200, end_time = 1651613600, first_zone = "0", recomed = "0", isnew = "0", hot = "0", roles = {}},
    -- {name = "仿ios8服", host = "192.168.1.101", port = 8001, platform = "ios", zone_id = 8, begin_time = 1351527200, end_time = 1651613600, first_zone = "0", recomed = "0", isnew = "0", hot = "0", roles = {}},
    -- {name = "公告测试服", host = "wyserver.shiyuegame.com", port = 8001, platform = "test", zone_id = 1, begin_time = 1351527200, end_time = 1651613600, first_zone = "0", recomed = "0", isnew = "0", hot = "0", roles = {}},
    -- {name = "仁街本地", host = "192.168.0.15", port = 8001, platform = "local", zone_id = 1, begin_time = 1351527200, end_time = 1651613600, first_zone = "0", recomed = "0", isnew = "0", hot = "0", roles = {}},
    -- {name = "仁街本地2", host = "192.168.0.15", port = 8002, platform = "local", zone_id = 2, begin_time = 1351527200, end_time = 1651613600, first_zone = "0", recomed = "0", isnew = "0", hot = "0", roles = {}},
    -- {name = "家伟本地", host = "192.168.2.74", port = 8001, platform = "local", zone_id = 1, begin_time = 1351527200, end_time = 1651613600, first_zone = "0", recomed = "0", isnew = "0", hot = "0", roles = {}},
    -- {name = "欧阳本地1", host = "192.168.0.14", port = 8001, platform = "local", zone_id = 1, begin_time = 1351527200, end_time = 1651613600, first_zone = "0", recomed = "0", isnew = "0", hot = "0", roles = {}},
    -- {name = "欧阳本地2", host = "192.168.0.14", port = 8002, platform = "local", zone_id = 2, begin_time = 1351527200, end_time = 1651613600, first_zone = "0", recomed = "0", isnew = "0", hot = "0", roles = {}},
    -- {name = "欧阳本地3", host = "192.168.0.14", port = 8003, platform = "local", zone_id = 3, begin_time = 1351527200, end_time = 1651613600, first_zone = "0", recomed = "0", isnew = "0", hot = "0", roles = {}},
    -- {name = "欧阳本地4", host = "192.168.0.14", port = 8004, platform = "local", zone_id = 4, begin_time = 1351527200, end_time = 1651613600, first_zone = "0", recomed = "0", isnew = "0", hot = "0", roles = {}},
    -- {name = "欧阳本地5", host = "192.168.0.14", port = 8005, platform = "local", zone_id = 5, begin_time = 1351527200, end_time = 1651613600, first_zone = "0", recomed = "0", isnew = "0", hot = "0", roles = {}},
    -- {name = "争记本地2", host = "192.168.0.15", port = 8002, platform = "local", zone_id = 2, begin_time = 1351527200, end_time = 1651613600, first_zone = "0", recomed = "0", isnew = "0", hot = "0", roles = {}},
    -- {name = "争记本地3", host = "192.168.0.15", port = 8003, platform = "local", zone_id = 3, begin_time = 1351527200, end_time = 1651613600, first_zone = "0", recomed = "0", isnew = "0", hot = "0", roles = {}},
    -- {name = "海外开发服", host = "192.168.1.101", port = 9001, platform = "over_seas", zone_id = 1, roles = {}} ,
    -- {name = "镇广海外服", host = "192.168.1.202", port = 9001, platform = "over_seas", zone_id = 1, roles = {}} ,
    -- {name = "信益本地", host = "192.168.0.16", port = 8001, platform = "local", zone_id = 1, begin_time = 1351527200, end_time = 1651613600, first_zone = "1", recomed = "0", isnew = "0", hot = "0", roles = {}},
    -- {name = "剑斌本地", host = "192.168.61.27", port = 8001, platform = "local", zone_id = 1, begin_time = 1351527200, end_time = 1651613600, first_zone = "1", recomed = "0", isnew = "0", hot = "0", roles = {}},
    -- {name = "剑斌本地2", host = "192.168.61.27", port = 8002, platform = "local", zone_id = 2, begin_time = 1351527200, end_time = 1651613600, first_zone = "1", recomed = "0", isnew = "0", hot = "0", roles = {}},
    -- {name = "天洪本地", host = "192.168.1.184", port = 8001, platform = "local", zone_id = 1, begin_time = 1351527200, end_time = 1651613600, first_zone = "1", recomed = "0", isnew = "0", hot = "0", roles = {}},
    -- {name = "宇飞本地", host = "192.168.61.107", port = 8001, platform = "local", zone_id = 1, begin_time = 1351527200, end_time = 1651613600, first_zone = "1", recomed = "0", isnew = "0", hot = "0", roles = {}},
    -- {name = "嘉伟本地", host = "192.168.61.38", port = 8001, platform = "local", zone_id = 1, begin_time = 1351527200, end_time = 1651613600, first_zone = "1", recomed = "0", isnew = "0", hot = "0", roles = {}},
    -- {name = "文钢本地", host = "192.168.2.170", port = 8003, platform = "local", zone_id = 3, begin_time = 1351527200, end_time = 1651613600, first_zone = "1", recomed = "0", isnew = "0", hot = "0", roles = {}},
    -- {name = "增锦本地", host = "192.168.2.85", port = 8001, platform = "local", zone_id = 1, begin_time = 1351527200, end_time = 1651613600, first_zone = "1", recomed = "0", isnew = "0", hot = "0", roles = {}},
    -- {name = "万方本地", host = "192.168.1.180", port = 8001, platform = "local", zone_id = 1, begin_time = 1351527200, end_time = 1651613600, first_zone = "1", recomed = "0", isnew = "0", hot = "0", roles = {}},
    -- {name = "活动测试服", host = "182.254.155.64", port = 8005, platform = "test", zone_id = 5, begin_time = 1351527200, end_time = 1651613600, first_zone = "1", recomed = "0", isnew = "0", hot = "0", roles = {}},
    -- {name = "活动专用", host = "192.168.1.124", port = 8001, platform = "camp", zone_id = 1, begin_time = 1351527200, end_time = 1651613600, first_zone = "1", recomed = "0", isnew = "0", hot = "0", roles = {}},
    -- {name = "玩家测试服", host = "s1.experience.xcqy.shiyuegame.com", port = 6600, platform = "experience", zone_id = 1, begin_time = 1351527200, end_time = 1651613600, first_zone = "0", recomed = "1", isnew = "1", hot = "1", roles = {}} ,
    -- {name = "游戏体验服", host = "s1.experience.xcqy.shiyuegame.com", port = 6600, platform = "experience", zone_id = 1, begin_time = 1351527200, end_time = 1651613600, first_zone = "0", recomed = "1", isnew = "1", hot = "1", roles = {}} ,
    -- {name = "ios正式服", host = "s1.verify.xcqy.shiyuegame.com", port = 8021, platform = "verify", zone_id = 1, begin_time = 1351527200, end_time = 1651613600, first_zone = "0", recomed = "1", isnew = "1", hot = "1", roles = {}} ,
}

ServerConfig.default_zone = {}

ServerConfig.charge_list = {
    {platform = "dev", path = "http://s{num}.test.xcqy.shiyuegame.com/api.php/pf/3kw/pay/"}
    ,{platform = "test", path = "http://s{num}.test.xcqy.shiyuegame.com/api.php/pf/3kw/pay/"}
    ,{platform = "local", path = "http://s{num}.test.xcqy.shiyuegame.com/api.php/pf/3kw/pay/"}
    ,{platform = "verifyeyou", path = "http://s{num}.verifyeyou.xcqy.shiyuegame.com/api.php/pf/eyou/pay_ios"}
}

ServerConfig.target_server = {}
