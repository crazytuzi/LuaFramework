--[[
    * 类注释写在这里-----------------
    * @author {AUTHOR}
    * <br/>Create: 2016-12-06
]]
LoginModel = LoginModel or BaseClass()

function LoginModel:__init(ctrl)
    self.ctrl = ctrl
    self:config()
end

function LoginModel:config()
    self.dispatcher = GlobalEvent:getInstance()
    self.loginInfo = nil -- 进入游戏,登陆的角色信息
    self.world_lev = -1 -- 世界等级
    self.serverlist_completed = false -- 服务器列表是否加载完全
    self.default_completed = false -- 默认服务器是否请求过了

    self.request_server_time = 0

    self.loginData = {} -- 登入游戏数据
    self.loginData.platform = PLATFORM_NAME -- 暂时的
    self.loginData.ip = ""
    self.loginData.port = ""
    self.loginData.role_count = 0
    self.loginData.status = 0 -- 默认的服务器拥挤状态
    self.loginData.isNew = false -- 是否是新服
    self.loginData.isClose = false -- 是否关服
    self.loginData.host = "" -- host
    self.loginData.open_time = 0
    self.loginData.srv_name = ""
    self.loginData.srv_id = ""
    self.loginData.main_srv_id = ""
    self.loginData.rid = 0
    self.loginData.usrName = "" -- 账号
    self.loginData.password = ""
    self.loginData.platform_flag = "" -- 平台标签

    -- 从本地缓存读取最后一次使用的账号和密码
    self.loginData.usrName = SysEnv:getInstance():getStr(SysEnv.keys.usrName)
    self.loginData.password = SysEnv:getInstance():getStr(SysEnv.keys.password)
    if IS_TEST_SERVER then
        self.loginData.usrNameList = SysEnv:getInstance():getTable(SysEnv.keys.usrNameList)
    end
    --记录用户协议已经显示的的账号..
    self.loginData.newNameList = SysEnv:getInstance():getTable(SysEnv.keys.user_proto_name_list)

    -- 当前全部服务器数据
    self.total_server_data = ""
    self.is_in_handle = false
end

-- 获取登录数据
function LoginModel:getLoginData()
    return self.loginData
end

-- 缓存登录数据
function LoginModel:cacheNearLoginData(account, rid, srv_id)
    if account then
        self.loginData.usrName = account
        SysEnv:getInstance():set(SysEnv.keys.usrName, account, true)
    end
    if srv_id then
        self.loginData.srv_id = srv_id
        SysEnv:getInstance():set(SysEnv.keys.srv_id, srv_id, true)
    end
    if rid then
        self.loginData.rid = rid
        SysEnv:getInstance():set(SysEnv.keys.rid, rid, true)
    end
end

-- 请求默认服务器
function LoginModel:requestDefaultServerListReal(account, platform)
    print("LoginModel:requestDefaultServerList @@@@@@")
    account = account or self.loginData.usrName or ""
    platform = platform or PLATFORM_NAME
    local channelId = LoginPlatForm:getInstance():getChannel()
    local last_srv_id = cc.UserDefault:getInstance():getStringForKey("local_srv_id")
    -- 只返回url，没有body
    local url, body = get_servers_url(account, PLATFORM_NAME, channelId, last_srv_id, 0, 1)
    print(url, body)
    if not url then return end
    local string_format = string.format
    local xhr = cc.XMLHttpRequest:new()
    xhr.responseType = cc.XMLHTTPREQUEST_RESPONSE_JSON
    xhr:open("POST", url)
    local function onReadyStateChange()
        self.dispatcher:Fire(LoginEvent.DEFAULE_SERVER_SUCCESS, data.sign)
    end
    local function onReadyStateChange()
        if xhr.readyState == 4 and (xhr.status >= 200 and xhr.status < 207) then
            local response = xhr.response
            local servers = loadstring("return " .. response)
            print(response,"servers")
            if servers == nil then
                servers = {}
            else
                servers = servers()
            end
            self:managerDefualtServerListByJsonObj(servers, account, platform)
        else
            delayRun(ViewManager:getInstance():getLayerByTag(ViewMgrTag.MSG_TAG), 2, function()
                if self:useLocalServerData() == false then -- 如果本地缓存没有默认服务器,则继续请求
                    self:requestDefaultServerList(account, platform)
                end
            end)
        end
    end
    if body then
        body = self:getRequestExtend(body, channelId, account)
    end
    xhr:registerScriptHandler(onReadyStateChange)
    xhr:send(body)
end


-- 请求默认服务器
function LoginModel:requestDefaultServerList(account, platform)
    if true then
        self:requestDefaultServerListReal(account, platform)
        return
    end

    print("LoginModel:requestDefaultServerList @@@@@@")
    account = account or self.loginData.usrName or ""
    platform = platform or PLATFORM_NAME
    local channelId = LoginPlatForm:getInstance():getChannel()
    local last_srv_id = cc.UserDefault:getInstance():getStringForKey("local_srv_id")
    -- 只返回url，没有body
    local url, body = get_servers_url(account, PLATFORM_NAME, channelId, last_srv_id, 0, 1)
    print(url, body)
    if not url then return end
    local string_format = string.format
    local xhr = cc.XMLHttpRequest:new()
    xhr.responseType = cc.XMLHTTPREQUEST_RESPONSE_JSON
    xhr:open("POST", url)
    local function onReadyStateChange()
        --self.dispatcher:Fire(LoginEvent.DEFAULE_SERVER_SUCCESS, data.sign)
        local ip = "8.134.70.76"
        -- local ip = "192.168.2.133"
        local usrName = account
        local port = 9001
        LoginController:getInstance():requestConnect(ip, port, usrName)
    end
--[[    local function onReadyStateChange()
        if xhr.readyState == 4 and (xhr.status >= 200 and xhr.status < 207) then
            local response = xhr.response
            local servers = loadstring("return " .. response)
            print(response,"servers")
            if servers == nil then
                servers = {}
            else
                servers = servers()
            end
            self:managerDefualtServerListByJsonObj(servers, account, platform)
        else
            delayRun(ViewManager:getInstance():getLayerByTag(ViewMgrTag.MSG_TAG), 2, function()
                if self:useLocalServerData() == false then -- 如果本地缓存没有默认服务器,则继续请求
                    self:requestDefaultServerList(account, platform)
                end
            end)
        end
    end]]
    if body then
        body = self:getRequestExtend(body, channelId, account)
    end
    --xhr:registerScriptHandler(onReadyStateChange)
    --xhr:send(body)
    local ip = "8.134.70.76"
    -- local ip = "192.168.2.133"
    local usrName = account
    local port = 9001
    LoginController:getInstance():requestLoginGame(usrName,ip, port, true, true)
end

-- 请求全部服务器列表,现在不会登录就请求了,改成点击服务器列表的时候才去请求
function LoginModel:getServerData(account, platform)
    if self.isRequestServerDataing then return end
    account = account or self.loginData.usrName or ""
    platform = platform or PLATFORM_NAME
    local channelId = LoginPlatForm:getInstance():getChannel()
    local last_srv_id = cc.UserDefault:getInstance():getStringForKey("local_srv_id")
    local url, body = get_servers_url(account, PLATFORM_NAME, channelId, last_srv_id)
    if not url then return end
    self.serverlist_completed = false
    self.isRequestServerDataing = true
    local string_format = string.format
    local xhr = cc.XMLHttpRequest:new()
    xhr.responseType = cc.XMLHTTPREQUEST_RESPONSE_JSON
    xhr:open("POST", url)
    local function onReadyStateChange()
        self.isRequestServerDataing = false
        if xhr.readyState == 4 and (xhr.status >= 200 and xhr.status < 207) then
            print("Http Status Code:" .. xhr.statusText, xhr.readyState)
            -- 这里尝试缓存起来，只负责缓存起来，不干别的, 如果这个时候处理数据，会非常卡
            self.total_server_data = xhr.response
            -- local response = xhr.response
            -- local servers = loadstring("return " .. response)
            -- if servers == nil then
            --     servers = {}
            -- else
            --     servers = servers()
            -- end
            -- self:managerServerListByJsonObj(servers, account, platform)
        else
            delayRun(ViewManager:getInstance():getLayerByTag(ViewMgrTag.MSG_TAG), 2, function()
                self:getServerData(account, platform)
            end)
        end
    end
    if body then
        body = self:getRequestExtend(body, channelId, account)
    end
    xhr:registerScriptHandler(onReadyStateChange)
    xhr:send(body)
end

-- 处理缓存的lua数据
function LoginModel:handleTotalServerInfo()
    if self.total_server_data == nil or self.total_server_data == "" then
        self:getServerData()
    else
        if self.is_in_handle == true then return end
        self.is_in_handle = true

        local servers = loadstring("return " .. self.total_server_data)
        if servers == nil then
            servers = {}
        else
            servers = servers()
        end
        self:managerServerListByJsonObj(servers, account, platform)
    end
end

function LoginModel:getRequestExtend(data_info, channelId, account)
    local string_format = string.format
    local time = os.time()
    local tmp_timeZone = TimeTool.getTimeZone() + 100 -- 这里直接把时区转成正数,要不url无法访问到
    local timeZone = log_url_encode(tmp_timeZone)
    local tmp_body = string_format("%s&time=%s&timeZone=%s", data_info, time, timeZone)
    local sign = string_format("%s%s%s%s%s", channelId, time, timeZone, account, "232fgD0f3afBa1Tst88bH05727DFc")
    sign = cc.CCGameLib:getInstance():md5str(sign)
    tmp_body = string_format("%s&sign=%s", tmp_body, sign)
    if tmp_timeZone < 0 and error_log_report then
        error_log_report(string.format("请求默认服务器异常, MD5之后的数据, 地址===>%s", tmp_body))
    end
    return tmp_body
end

-- 解析默认服务器的json文件
--[[
    jsonObj = {
        data = {
            default_zone = {
                zone_id = ,
                name, srv_name = ,
                srv_id, main_srv_id, platform, main_platform, zone_id, main_zone_id = ,
                ip, host = ,
                port, erl_port = ,
                platform_flag = ,
                maintain = ,
                first_zone = ,
                recomed = ,
                open_time, begin_time = ,
                roles = {
                    {
                        login_time = ,
                    },
                },
            },
            new_account = true,
            ip = "0.0.0.0"
        },
        msg = ,
    }
]]
function LoginModel:managerDefualtServerListByJsonObj(jsonObj, account, platform)
    if not LoginEvent then return "not LoginEvent" end

    jsonObj = jsonObj or {}
    local data = jsonObj.data or jsonObj.msg
    if data == nil or data.default_zone == nil then
        return "default_zone null"
    end
    local defserver = data.default_zone
    if defserver.zone_id == nil then
        return "zone_id null"
    end
    if self.default_completed == true then
        return true
    end
    self.default_completed = true

    -- 是否为新账号
    self.new_account_flag = data.new_account
    -- 从php获取一个ip
    self.php_ip = data.ip

    -- 获取由服务器json得来的玩家在各个服务器上的角色数量
    local function _getRolesFromRoleInfo(v)
        if v.roles then
            ACCOUNT_HAS_ROLE = ACCOUNT_HAS_ROLE or #v.roles > 0
            return #v.roles
        end
        return 0
    end
    local function _getRolesLoginTime(v)
        local list = {}
        local time = 0
        if v.roles then
            for i = 1, #v.roles do
                if time < v.roles[i].login_time then
                    time = v.roles[i].login_time
                end
            end
        end
        return time
    end

    -- 服务器列表数据结构
    local vo = {}
    vo.srv_name = MAKELIFEBETTERSERVERNAME or defserver.name or defserver.srv_name
    vo.srv_id = defserver.srv_id or defserver.platform .. "_" .. defserver.zone_id
    vo.ip = defserver.ip or defserver.host
    vo.port = defserver.port or defserver.erl_port
    vo.host = defserver.host or ""
    vo.zone_id = defserver.zone_id
    vo.platform_flag = defserver.platform_flag or ""
    defserver.main_platform = defserver.main_platform or defserver.platform
    defserver.main_zone_id = defserver.main_zone_id or defserver.zone_id
    vo.main_srv_id = defserver.main_srv_id or defserver.main_platform .. "_" .. defserver.main_zone_id

    vo.isClose = defserver.maintain == 1 -- 是否维护关服状态
    vo.isTry = tonumber(defserver.first_zone or "0") == 1 -- 是否首服
    vo.isRecomed = defserver.recomed == 1 -- 是否推荐
    vo.isNew = defserver.isnew == 1 -- 是否新服
    vo.open_time = tonumber(defserver.open_time or defserver.begin_time) or 0
    vo.role_count = _getRolesFromRoleInfo(defserver)
    vo.role_logintime = _getRolesLoginTime(defserver)
    vo.usrName = account
    vo.platform = platform

    -- 储存当前选中的服务器数据,用于进入游戏设置
    self:setCurSrv(vo)

    -- 默认服务期处理完成
    self.dispatcher:Fire(LoginEvent.DEFAULE_SERVER_SUCCESS, data.sign)
    return true
end

-- 储存当前选中服务器信息
function LoginModel:setCurSrv(vo, save)
    self.loginData.ip = vo.ip or ""
    self.loginData.port = vo.port or ""
    self.loginData.role_count = vo.role_count or "0"
    self.loginData.status = vo.status or 0
    self.loginData.isNew = vo.isNew or false
    self.loginData.isClose = vo.isClose or false
    self.loginData.host = vo.host or ""
    self.loginData.open_time = vo.open_time or 0
    self.loginData.srv_name = vo.srv_name or ""
    print("self.loginData.srv_id",vo.srv_id，save)
    self.loginData.srv_id = vo.srv_id or ""
    self.loginData.main_srv_id = vo.main_srv_id or ""
    self.loginData.isTry = vo.isTry or false
    self.loginData.platform_flag = vo.platform_flag or ""
    self.loginData.rid = tonumber(vo.rid or 0)
    if vo.usrName then
        self.loginData.usrName = vo.usrName
    end
    if vo.platform then
        self.loginData.platform = vo.platform
    end

    self.no_local_serverdata = nil
    self.request_server_time = 0
    if save then
        self:saveCurSrv(vo)
    end
end

--[[
    @desc: 储存上次登录的时候的服务器,用于下次请求默认服务器请求不到的时候使用
    author:{author}
    time:2020-01-02 17:45:24
    @return:
]]
function LoginModel:saveLoginDataToLocal()
    SysEnv:getInstance():set(SysEnv.keys.default_server_data, self.loginData, true)
end

--[[
    @desc: 判断是否有本地缓存的默认服务器,直接使用
    author:{author}
    time:2020-01-02 17:45:44
    @return:
]]
function LoginModel:useLocalServerData()
    if self.request_server_time <= 5 then
        self.request_server_time = self.request_server_time + 1
        return false
    end
    if self.no_local_serverdata == false then
        return self.no_local_serverdata
    end
    local local_data = SysEnv:getInstance():getTable(SysEnv.keys.default_server_data, {})
    if local_data and next(local_data) ~= nil then
        self:setCurSrv(local_data, true)
        self.dispatcher:Fire(LoginEvent.DEFAULE_SERVER_SUCCESS)
        return true
    else
        self.no_local_serverdata = false
        return false
    end
end

-- 本地缓存当前选择服务器数据
function LoginModel:saveCurSrv(vo)
    local data = vo or self.loginData
    cc.UserDefault:getInstance():setStringForKey("local_srv_id", data.srv_id)
    cc.UserDefault:getInstance():setBoolForKey("is_enter_try_srv", data.isTry)
    cc.UserDefault:getInstance():flush()
end

--==============================--
--desc:检查是否重新请求服务器信息
--time:2019-06-10 03:52:18
--@data:
--@return
--==============================--
function LoginModel:checkReloadServerData(data)
    local now = GameNet:getInstance():getTime()
    -- 先判断开服公告
    if NEED_CHECK_CLOSE == true then
        data = data or self.loginData
        if SHOW_NOTICE ~= false and (data.isClose or data.open_time > now) then
            serverData = data -- 切换公告为指定服
            NoticeController:getInstance():openNoticeView()
            serverData = nil -- 切换回公告为默认已选择服
        elseif data.isClose then -- 维护中
            CommonAlert.show(TI18N("当前服务器正在维护中，请等待..."),TI18N("确定"))
        elseif data.open_time > now then -- 开服时间未到
            self:showSrvOpen(data)
        end
    end

    --如果是新账号,则不需要选服了
    -- if self:checkIsNewAccount() == true then
    --     return
    -- end
    self.check_time = self.check_time or 0
    if now - self.check_time > 10 then -- 指定秒内只重载一次
        self.check_time = now
        if self.total_server_data == nil or self.total_server_data == "" then
            self:getServerData()
        else
            self:handleTotalServerInfo()
        end
    else
        if self.total_server_data and self.total_server_data ~= "" then
            self:handleTotalServerInfo()
        end
    end
end

function LoginModel:showSrvOpen(data)
    NoticeController:getInstance():openNoticeView()
end

-- 解析全部服务器列表,数据量庞大,尽量少用这个
function LoginModel:managerServerListByJsonObj(jsonObj, account, platform, not_save)
    if not LoginEvent then
        return
    end
    self.server_list = {}
    jsonObj = jsonObj or {}
    local data = jsonObj.data or jsonObj.msg
    if data == nil or data.server_list == nil or next(data.server_list) == nil then
        return
    end
    local serverList = data.server_list
    local defserver = data.default_zone

    -- 获取由服务器json得来的玩家在各个服务器上的角色数量
    local function _getRolesFromRoleInfo(v)
        if v.roles then
            ACCOUNT_HAS_ROLE = ACCOUNT_HAS_ROLE or #v.roles > 0
            return #v.roles
        end
        return 0
    end
    local function _getRolesLoginTime(v)
        local list = {}
        local time = 0
        if v.roles then
            for i = 1, #v.roles do
                if time < v.roles[i].login_time then
                    time = v.roles[i].login_time
                end
            end
        end
        return time
    end
    -- 开发服加入线上服列表
    if IS_TEST_SERVER and SpecialServerList then
        for _, v in pairs(SpecialServerList) do
            table.insert(serverList, v)
        end
    end

    local last_srv_id = cc.UserDefault:getInstance():getStringForKey("local_srv_id")
    local srv_vo = nil
    local def_vo = nil
    for _, v in ipairs(serverList) do
        local vo = {}
        vo.srv_name = MAKELIFEBETTERSERVERNAME or v.name or v.srv_name
        vo.srv_id = v.srv_id or v.platform .. "_" .. v.zone_id
        v.main_platform = v.main_platform or v.platform
        v.main_zone_id = v.main_zone_id or v.zone_id
        vo.main_srv_id = v.main_srv_id or v.main_platform .. "_" .. v.main_zone_id
        vo.zone_id = v.zone_id
        vo.ip = v.ip or v.host
        vo.port = v.port or v.erl_port
        vo.host = v.host or ""
        vo.platform_flag = v.platform_flag or ""
        vo.isClose = v.maintain == 1 -- 是否维护关服状态
        vo.isTry = tonumber(v.first_zone or "0") == 1 -- 是否首服
        vo.isRecomed = v.recomed == 1 -- 是否推荐
        vo.isNew = v.isnew == 1 -- 是否新服
        vo.open_time = tonumber(v.open_time or v.begin_time) or 0
        vo.role_count = _getRolesFromRoleInfo(v)
        vo.role_logintime = _getRolesLoginTime(v)
        vo.group_id = v.group_id or 1
        vo.group_num = v.group_num or 1
        vo.usrName = account
        vo.platform = platform
        table.insert(self.server_list, vo)
        if vo.srv_id == last_srv_id then
            srv_vo = vo
        end
        if def_vo == nil and defserver then
            if defserver.srv_id == vo.srv_id then
                def_vo = vo
            end
        end
    end
    -- 如果本本地缓存的是一样的或者是默认服务器,则储存一下
    if srv_vo then
        self:setCurSrv(srv_vo)
    elseif def_vo then
        self:setCurSrv(def_vo)
    else
        if self.loginData.srv_id == "" then -- 没有进过游戏，默认第一个服务器
            local vo = self.server_list[1]
            self:setCurSrv(vo)
        end
    end
    -- 到这里表示服务器列表全部加载完成
    self.serverlist_completed = true
    self.dispatcher:Fire(LoginEvent.REQUEST_SERVERLIST_SUCCESS)
end

-- 判断是否需要切换服务器提示
function LoginModel:isNeedReload(msg, data, func)
    if not UPDATE_TRY_VERSION_MAX or UPDATE_VERSION_MAX == UPDATE_TRY_VERSION_MAX then
        return false
    end
    if data.isTry == (cc.UserDefault:getInstance():getBoolForKey("is_enter_try_srv") or false) then
        return false
    end
    if msg == nil then
        if data.isTry then
            msg = string.format(TI18N("[%s]为优先体验服，与其它服务器相互切换需要重新加载资源"), data.srv_name)
        else
            msg = string.format(TI18N("[%s]为优先体验服，与其它服务器相互切换需要重新加载资源"), self.loginData.srv_name)
        end
    end
    CommonAlert.show(
        msg,
        TI18N("确定"),
        function()
            self:saveCurSrv(data)
            func()
        end,
        TI18N("取消")
    )
    return true
end

--[[设置请求网关状态
    1:正在请求
    0 或空值 :结束请求
]]
function LoginModel:setGatewayCallState(int)
    self.gatewayCallState = int
end

-- 获取请求网关状态
function LoginModel:getGatewayCallState()
    return self.gatewayCallState
end

--[[
    获取全部服务器列表
]]
function LoginModel:getServerList()
    return self.server_list
end

--[[
    表示全部服务器列表是否加载完全
]]
function LoginModel:getSverListStatus()
    return self.serverlist_completed
end

--[[
    设置登陆信息
]]
function LoginModel:setLoginInfo(data)
    self.loginInfo = data
end

-- 获取登录信息
function LoginModel:getLoginInfo()
    return self.loginInfo
end

--[[
    世界登陆
]]
function LoginModel:setWorldLev(lev)
    self.world_lev = lev
end

function LoginModel:getWorldLev()
    return self.world_lev
end

-- 是否为新账号(新账号不让选择服务器)
function LoginModel:checkIsNewAccount()
    -- 联运服直接取消掉新账号不给进
    -- if PLATFORM_NAME == "symix" or PLATFORM_NAME == "symix2" then
    --     return false
    -- end

    -- if not self.new_account_flag or self.new_account_flag == 0 then
    --     return false
    -- end
    -- return true
    return false
end

-- 缓存一下全部服务器列表数据（退后台或断线时写入本地）
function LoginModel:setServerListData(data)
    self.server_list_data = data
end

function LoginModel:getServerListData()
    return self.server_list_data
end

-- 根据区号获取区名
function LoginModel:getSrvGroupNameByGroupId(group_id)
    if not group_id then
        return ""
    end
    group_id = tonumber(group_id)
    local platform_id = 1 -- 默认为安卓
    if PLATFORM_NAME == "icebird" then -- 冰鸟不区分android和ios区服
        platform_id = 6
    elseif PLATFORM_NAME == "9377" then -- 9377android
        platform_id = 8
    elseif PLATFORM_NAME == "9377ios" then -- 9377ios
        platform_id = 9
    elseif PLATFORM_NAME == "symix" then -- 渠道服1
        platform_id = 4
    elseif PLATFORM_NAME == "symix2" then -- 渠道服2
        platform_id = 5
    elseif PLATFORM_NAME == "tanwan" then -- 贪玩因为误操作,用户量太大,无法修改,只能继续区分
        if IS_IOS_PLATFORM == true then
            platform_id = 2
        else
            platform_id = 7
        end
    else
        if IS_IOS_PLATFORM == true then
            if FINAL_CHANNEL == "syios_djsdmm" then
                platform_id = 3
            else
                platform_id = 2
            end
        end
    end

    local srv_cfg = Config.ServerData.data_name[group_id]
    if srv_cfg then
        return srv_cfg[platform_id] or ""
    end
    return ""
end

--==============================--
--desc:解析专家服的默认服务器列表
--time:2017-11-22 09:46:46
--@return
--==============================--
function LoginModel:analysisDefualServerListForVerifyios(defserver, account, platform)
    if self.default_completed == true then
        return
    end
    self.default_completed = true

    local vo = {}
    vo.srv_name = MAKELIFEBETTERSERVERNAME or defserver.name or defserver.srv_name
    vo.srv_id = defserver.srv_id or defserver.platform .. "_" .. defserver.zone_id
    vo.ip = defserver.ip or defserver.host
    vo.port = defserver.port or defserver.erl_port
    vo.host = defserver.host or ""
    vo.zone_id = defserver.zone_id
    vo.platform_flag = defserver.platform_flag or ""
    defserver.main_platform = defserver.main_platform or defserver.platform
    defserver.main_zone_id = defserver.main_zone_id or defserver.zone_id
    vo.main_srv_id = defserver.main_srv_id or defserver.main_platform .. "_" .. defserver.main_zone_id

    vo.isClose = (defserver.maintain and defserver.maintain == 1) -- 是否维护关服状态
    vo.isTry = tonumber(defserver.first_zone or "0") == 1 -- 是否首服
    vo.isRecomed = (defserver.recomed or defserver.recomed == 1) -- 是否推荐
    vo.isNew = (defserver.isnew or defserver.isnew == 1) -- 是否新服
    vo.open_time = tonumber(defserver.open_time or defserver.begin_time) or 0
    vo.role_count = 0
    vo.role_logintime = 0
    vo.usrName = account
    vo.platform = platform

    self:setCurSrv(vo)
    self.dispatcher:Fire(LoginEvent.DEFAULE_SERVER_SUCCESS)
end

function LoginModel:__delete()
end
