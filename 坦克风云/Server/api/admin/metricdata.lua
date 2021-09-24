--登陆统计
function api_admin_metricdata(request)
    local response = {
        ret=-1,
        msg='error',
        data = {},
    }

    local sdate  = tonumber(request.params.startdate) or getWeeTs()
    local edate = tonumber(request.params.enddate) or 0

    local zoneid = getZoneId()

    local self = {}
    function self.searchloginlog()
        local redis = getRedis()
        local weeTs = getWeeTs( sdate )
        local ts = getClientTs()        

        local logkey = "z"..zoneid .. ".loginlogout." .. weeTs    --  登入登出key
        local onlinekey = "z"..zoneid .. ".useronline." .. weeTs
        local uidkey = "z"..zoneid .. ".uidmetric." .. weeTs

        local result = {}

        local log = redis:hgetall(logkey)
        local onlinelog = redis:hgetall(onlinekey)        
        local userlog = redis:hgetall(uidkey)
        if type(log) ~= 'table' then --登陆数据
            return result
        end
        if type(onlinelog) ~= 'table' then --最后在线数据
            onlinelog = {}
        end
        if type(userlog) ~= 'table' then --用户缓存数据
            userlog = {}
        end

        for uid, data in pairs( log ) do
            userinfo = json.decode( userlog[uid] ) or {"", 0, "", ""} --只读缓存

            data = json.decode( data ) --玩家登入登出数据

            if type(data) == 'table' then
                for k, v in pairs( data ) do
                    if tonumber(v[1]) >= sdate and tonumber(v[1])<= edate then
                        -- {uid, 登入时间, 登出时间, ip}
                        local logoutTs = v[3]==0 and onlinelog[uid] or v[1] -- 最后一次 登出时间在资源同步里sync
                        v[2] = v[2] == 0 and "0.0.0.0" or v[2]
                        if not string.find(v[2], '%d+.%d+.%d+.%d') then
                            v[2] = '0.0.0.0'
                        end

                        -- 玩家id 登入时间 登出时间  登陆ip  角色名 渠道id
                        -- local d = {tonumber(uid), tonumber(v[1]), logoutTs, v[2], userinfo[1], userinfo[2]}
                            --[[
                            服务器编号
                            渠道ID
                            玩家账号ID
                            玩家角色名
                            角色ID
                            游戏名称
                            登录时间
                            登出时间
                            最后登录IP
                            设备标识码
                            ]]
                        local d = {
                                    zoneid, --服务器编号
                                    userinfo[2] or 0, --渠道ID
                                    userinfo[4] or 0, --玩家账号ID
                                    userinfo[1] or 0, --玩家角色名
                                    tonumber(uid), --角色ID
                                    'cjjd', -- 游戏名称
                                    tonumber(v[1]), -- 登录时间
                                    logoutTs, -- 登出时间
                                    v[2], -- 最后登录IP
                                    userinfo[3] or 0, -- 设备标识码
                                }
                        table.insert(result, d)
                    end
                end
            end

        end

        return result
    end

    function self.searchloginlogExt()
        local redis = getRedis()
        local weeTs = getWeeTs( sdate )
        local ts = getClientTs()        

        local logkey = "z"..zoneid .. ".loginlogout." .. weeTs    --  登入登出key
        local onlinekey = "z"..zoneid .. ".useronline." .. weeTs
        local uidkey = "z"..zoneid .. ".uidmetric." .. weeTs

        local result = {}
        local result1 = {}

        local log = redis:hgetall(logkey)
        local onlinelog = redis:hgetall(onlinekey)        
        local userlog = redis:hgetall(uidkey)
        if type(log) ~= 'table' then --登陆数据
            return result
        end
        if type(onlinelog) ~= 'table' then --最后在线数据
            onlinelog = {}
        end
        if type(userlog) ~= 'table' then --用户缓存数据
            userlog = {}
        end

        for uid, data in pairs( log ) do
            userinfo = json.decode( userlog[uid] ) or {"", 0, "", ""} --只读缓存

            data = json.decode( data ) --玩家登入登出数据

            if type(data) == 'table' then
                for k, v in pairs( data ) do
                    if tonumber(v[1]) >= sdate and tonumber(v[1])<= edate then
                        -- {uid, 登入时间, 登出时间, ip}
                        local logoutTs = v[3]==0 and onlinelog[uid] or v[1] -- 最后一次 登出时间在资源同步里sync
                        v[2] = v[2] == 0 and "0.0.0.0" or v[2]
                        if not string.find(v[2], '%d+.%d+.%d+.%d') then
                            v[2] = '0.0.0.0'
                        end

                        -- 玩家id 登入时间 登出时间  登陆ip  角色名 渠道id
                        -- local d = {tonumber(uid), tonumber(v[1]), logoutTs, v[2], userinfo[1], userinfo[2]}
                            --[[
                            服务器编号
                            渠道ID
                            玩家账号ID
                            玩家角色名
                            角色ID
                            游戏名称
                            登录时间
                            登出时间
                            最后登录IP
                            设备标识码
                            ]]
                        local d = {
                                    zoneid, --服务器编号
                                    userinfo[2] or 0, --渠道ID
                                    userinfo[4] or 0, --玩家账号ID
                                    userinfo[1] or 0, --玩家角色名
                                    tonumber(uid), --角色ID
                                    'cjjd', -- 游戏名称
                                    tonumber(v[1]), -- 登录时间
                                    logoutTs, -- 登出时间
                                    v[2], -- 最后登录IP
                                    userinfo[3] or 0, -- 设备标识码
                                }

                        if tonumber(userinfo[2]) > 9002000 then -- ios平台的
                            table.insert(result1, d)
                        else
                            table.insert(result, d)
                        end
                    end
                end
            end

        end

        return result, result1
    end

    local action  = request.params.action or 1

    local clientPlat = getClientPlat()
    if clientPlat == 'ship_3kwan' and zoneid >= 211 then
        action = 2
    end

    if action == 1 then -- 登入登出信息
        response.data.result = self.searchloginlog()
    elseif action == 2 then
        response.data.result, response.data.result1 = self.searchloginlogExt()
    end

    response.msg = 'Success'
    response.ret = 0

    return response
end
