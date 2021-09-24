local _GAMEVARS = { zoneid=0, config={}, ts=0, mysql_instances={}, redis_instances={}, userobjs_instances={}, events={},action_log={},kfk_log={},sysDebug=nil,alliance={},isseed=0,requestCmd='',cacheobjs_instances={}}

local _EVENTS={eventsBeforeSave={},eventsAfterSave={},stats={}}

-- 版本配置，根据后台版本，获取配置（开放70级，技能70级等）无需每次初始化
local _VERSIONCFG = nil

local _ARENARANK = {}

local _FreeData = {}

local _ModelInstances = {}

sendMsg = {}
libKafka = nil

-- -----------------------------------------------------------------------------------------------------

function postFunc()    
    --baseSeed = 0   

    if type (_GAMEVARS.mysql_instances) == 'table' then
        for k,v in pairs(_GAMEVARS.mysql_instances) do
            v:close()
        end
    end

    if type (_ModelInstances) == 'table' then
        for k,v in pairs(_ModelInstances) do
            if v and v._unlock then
                v._unlock()
            end
            v=nil
        end
    end

    if type (_GAMEVARS.userobjs_instances) == 'table' then
        for k,v in pairs(_GAMEVARS.userobjs_instances) do
            if v and (not v.readOnly) then
                userUnlock(v.uid)
            end
        end
    end

    if type (_GAMEVARS.cacheobjs_instances) == 'table' then
        for k,v in pairs(_GAMEVARS.cacheobjs_instances) do
            if v and (not v.readOnly) then
                cacheUnlock(v.uid)
            end
        end
    end
    if type (_ARENARANK) == 'table' then
        for k,v in pairs(_ARENARANK) do
            userArenaRankUnLock(v)
        end
    end

    local logStatus,logError = pcall(processActionLogs)
    if not logStatus then
        writeLog(logError,'action_log')
    end

    local logStatus,logError = pcall(processKfkLogs)
    if not logStatus then
        writeLog(logError,'kafka_log')
    end

    -- 推送消息
    processSendMsg()

    if type (_GAMEVARS.redis_instances) == 'table' then        
        for k,v in pairs(_GAMEVARS.redis_instances) do    
            pcall(v.quit,v)
        end
    end

    initGAMEVARS()
end

function initGAMEVARS()
    _EVENTS={eventsBeforeSave={},eventsAfterSave={},stats={}}
    _ARENARANK = {}    

    _GAMEVARS = { zoneid=0, config={}, ts=0, mysql_instances={}, redis_instances={}, userobjs_instances={}, events={},action_log={},kfk_log={},sysDebug=nil,alliance={},isseed=0,requestCmd='',cacheobjs_instances={}}

    _FreeData = {}
    _ModelInstances = {}

    if type(package.loaded["lib.map"]) == "table" then
        if type(package.loaded["lib.map"].resetData) == 'function' then
            package.loaded["lib.map"]:resetData()
        end
    end

    if type(package.loaded["lib.alienmap"]) == "table" then
        if type(package.loaded["lib.alienmap"].resetData) == 'function' then
            package.loaded["lib.alienmap"]:resetData()
        end
    end
end

function regSendMsg(uid,cmd,data)
    if not sendMsg[uid] then sendMsg[uid] = {} end
    if not sendMsg[uid][cmd] then
        sendMsg[uid][cmd] = data or {}
    else
        if type(data) == 'table' then
            for k,v in pairs(data) do
                sendMsg[uid][cmd][k] = v
            end
        end
    end
end

function processSendMsg()
    for uid,data in pairs(sendMsg) do
        if type(data) == 'table' and next(data) then
            for cmd,val in pairs(data) do
                if cmd == 'msg.task' then
                    local response = {
                        ret = 0,
                        cmd = cmd,
                        msg='success',
                        data = {},
                        zoneid = getZoneId(),
                        ts = getClientTs(),
                    }
                    local uobjs = getUserObjs(uid)
                    local mDailytask = uobjs.getModel('dailytask')
                    local mTask = uobjs.getModel('task')
                    
                    response.data.task =  mTask.toArray(true)
                    response.data.dailytask =  mDailytask.toArray(true)                    
                    
                    sendMsgByUid(uid,json.encode(response))
                else
                    local response = {
                        data=val,
                        ret=0,
                        cmd=cmd,
                        ts = getClientTs(),
                    }
                    if sysDebug() then
                        writeLog('\n^*(- -)*^ ---- sendMsg ---- ^*(- -)*^' .. uid .."|".. (json.encode(response) or 'no response') .. '\n','sendmsg')
                    end

                    sendMsgByUid(uid,json.encode(response))
                end
            end
        end
    end
    sendMsg = {}
end

function getConfig(key,clientPlat)
    local config_item
    local clientPlat = clientPlat or getClientPlat()
    if not _GAMEVARS['config'][clientPlat] then _GAMEVARS['config'][clientPlat] = {} end
    
    local items = string.split(key,"%.")
    if #(items)<1 then return nil end
    
    if _GAMEVARS['config'][clientPlat][items[1]]==nil then        
        local rf = require("config."..items[1])
        if type(rf) == 'function' then
            _GAMEVARS['config'][clientPlat][items[1]] = rf(clientPlat)
        else
            _GAMEVARS['config'][clientPlat][items[1]] = rf
        end
    end
    
    config_item = _GAMEVARS['config'][clientPlat][items[1]]
    items[1] = nil
    for k,v in pairs(items) do
        v = tonumber(v) or v
        config_item = config_item[v]
    end
    return config_item
end

function getActiveCfg(uid, acname)
    local uobjs = getUserObjs(uid)
    local mUseractive = uobjs.getModel('useractive')
    local activeCfg = nil
    if mUseractive.info[acname].cfg then
      activeCfg = getConfig("active")[acname][mUseractive.info[acname].cfg]
    else
      activeCfg = getConfig("active")[acname]
    end

    return activeCfg
end

function setZoneId(id)
    _GAMEVARS['zoneid'] = tonumber(id)
end

function getZoneId(id)
    return _GAMEVARS['zoneid']
end

function getDbo()
    if not _GAMEVARS['mysql_instances'][_GAMEVARS['zoneid']] then
        local conn
        local config

        conn = require "lib.mysql"
        config = getConfig("config.z".._GAMEVARS['zoneid']..".mysql")
        conn:connect(config['user'],config['password'],config['db'],config['host'],config['port'])
        conn.conn:execute("SET NAMES UTF8")    
        -- assert(conn.conn:setautocommit(false),'mysql transaction set failed')        
        _GAMEVARS['mysql_instances'][_GAMEVARS['zoneid']] = conn
    end
    return _GAMEVARS['mysql_instances'][_GAMEVARS['zoneid']]
end

-- 跨服
function getCrossDbo()
    if not _GAMEVARS['mysql_instances']['crossserver'] then
        local conn
        local config

        conn = require "lib.mysql"
        config = getConfig("config.crossserver.mysql")
        conn:connect(config['user'],config['password'],config['db'],config['host'],config['port'])
        conn.conn:execute("SET NAMES UTF8")    
        -- assert(conn.conn:setautocommit(false),'mysql transaction set failed')        
        _GAMEVARS['mysql_instances']['crossserver'] = conn
    end
    return _GAMEVARS['mysql_instances']['crossserver']
end

function getAllianceCrossDbo()
    if not _GAMEVARS['mysql_instances']['acrossserver'] then
        local conn = require "lib.mysql"
        local config = getConfig("config.acrossserver.mysql")        
        conn:connect(config['user'],config['password'],config['db'],config['host'],config['port'])
        conn.conn:execute("SET NAMES UTF8")         
        _GAMEVARS['mysql_instances']['acrossserver'] = conn
    end
    return _GAMEVARS['mysql_instances']['acrossserver']
end

function getAllianceCrossRedis(serverwar)
    if not serverwar then serverwar = "acrossserver" end

    if not _GAMEVARS['redis_instances'][serverwar] then
        local conn = require "lib.redis"
        local config = getConfig("config."..serverwar..".redis")
        conn = conn.connect({host = config['host'], port = config['port'],})
        _GAMEVARS['redis_instances'][serverwar] = conn
    end
    return _GAMEVARS['redis_instances'][serverwar]
end

function getWorldWarDbo()
    if not _GAMEVARS['mysql_instances']['worldwarserver'] then
        local conn = require "lib.mysql"
        local config = getConfig("config.worldwarserver.mysql")        
        conn:connect(config['user'],config['password'],config['db'],config['host'],config['port'])
        conn.conn:execute("SET NAMES UTF8")         
        _GAMEVARS['mysql_instances']['worldwarserver'] = conn
    end
    return _GAMEVARS['mysql_instances']['worldwarserver']
end

function getWorldWarRedis()
    if not _GAMEVARS['redis_instances']['worldwarserver'] then
        local conn = require "lib.redis"
        local config = getConfig("config.worldwarserver.redis")        
        conn = conn.connect({host = config['host'], port = config['port'],})
        _GAMEVARS['redis_instances']['worldwarserver'] = conn
    end
    return _GAMEVARS['redis_instances']['worldwarserver']
end

function getRedisByCfg(config)
    local key = "bycfg_" .. config.host .. config.port
    if not _GAMEVARS['redis_instances'][key] then
        local conn = require "lib.redis"
        conn = conn.connect({host = config['host'], port = config['port'],})
        _GAMEVARS['redis_instances'][key] = conn
    end
    return _GAMEVARS['redis_instances'][key]
end 

function getRedis()
    if not _GAMEVARS['redis_instances'][_GAMEVARS['zoneid']] then
        local conn = require "lib.redis"
        local config
        config = getConfig("config.z".._GAMEVARS['zoneid']..".redis")
        
        conn = conn.connect({host = config['host'], port = config['port'],})
        _GAMEVARS['redis_instances'][_GAMEVARS['zoneid']] = conn
    end
    return _GAMEVARS['redis_instances'][_GAMEVARS['zoneid']]
end

function userLock(uid)
    local uid = tonumber(uid) or 0
    local redis = getRedis()
    local key = "z"..getZoneId()..".userlock."..uid
    local ret
    
    local i = 1
    while i<5 do
         ret = redis:getset(key,100)   
         redis:expire(key,3)      
         if ret==nil then
             return true
         else
             local socket = require("socket.core")
             local time = rand(20,60)/100
             socket.select(nil,nil,time)
             i = i + 1
         end
    end

    return false
end

function userUnlock(uid)
    local uid = tonumber(uid) or 0
    local redis = getRedis()
    local key = "z"..getZoneId()..".userlock."..uid
    local ret
    ret = redis:del(key)
    if ret==1 then
        return true
    end
    return false
end

function cacheLock(uid)
    local uid = tonumber(uid) or 0
    local redis = getRedis()
    local key = "z"..getZoneId()..".cachelock."..uid
    local ret
    
    local i = 1
    while i<5 do
         ret = redis:getset(key,100)   
         redis:expire(key,3)      
         if ret==nil then
             return true
         else
             local socket = require("socket.core")
             local time = rand(20,60)/100
             socket.select(nil,nil,time)
             i = i + 1
         end
    end

    return false
end

function cacheUnlock(uid)
    local uid = tonumber(uid) or 0
    local redis = getRedis()
    local key = "z"..getZoneId()..".cachelock."..uid
    local ret
    ret = redis:del(key)
    if ret==1 then
        return true
    end
    return false
end

function userArenaRankLock(rank)
    local uid = tonumber(uid) or 0
    local redis = getRedis()
    local key = "z"..getZoneId()..".userArenaLock."..rank
    local ret
    
    local i = 1
    while i<5 do
         ret = redis:getset(key,100)   
         redis:expire(key,3)      
         if ret==nil then
             return true
         else
             local socket = require("socket.core")
             local time = rand(20,60)/100
             socket.select(nil,nil,time)
             i = i + 1
         end
    end

    return false
end

function userArenaRankUnLock(rank)
    local uid = tonumber(uid) or 0
    local redis = getRedis()
    local key = "z"..getZoneId()..".userArenaLock."..rank
    local ret
    ret = redis:del(key)
    if ret==1 then
        return true
    end
    return false
end

-- 公共加锁
function commonLock(lockFlag,lockKey)
    local uid = tonumber(uid) or 0
    local redis = getRedis()
    local key = {
        "z",
        getZoneId(),
        lockKey or "commonlock",
        lockFlag,
    }
    key = table.concat(key,'.')
    
    local ret
    
    local i = 1
    while i<5 do
         ret = redis:getset(key,100)   
         redis:expire(key,3)      
         if ret==nil then
             return true
         else
             local socket = require("socket.core")
             local time = rand(20,60)/100
             socket.select(nil,nil,time)
             i = i + 1
         end
    end

    return false
end

-- 公共解锁
function commonUnlock(lockFlag,lockKey)
    local uid = tonumber(uid) or 0
    local redis = getRedis()
    local key = {
        "z",
        getZoneId(),
        lockKey or "commonlock",
        lockFlag,
    }
    key = table.concat(key,'.')

    local ret
    ret = redis:del(key)
    if ret==1 then
        return true
    end
    return false
end

function getArenaUidByRank(rank)
    -- body

    _ARENARANK['r'..rank]=rank

    local redis = getRedis()
    
    local key = "z"..getZoneId()..".rank.arena"
     
    local list = {}

    --根据积分排名取数据
    list = redis:zrangebyscore(key,rank,rank,'withscores')
    
    if not next(list)then
        local db = getDbo()
        local result = db:getRow("select uid,ranking from userarena WHERE ranking=:ranking",{ranking=rank})
        if type(result) == 'table' and result['uid'] then

            setArenaRanking(result['uid'],result['ranking'])
            return result['uid']

        else
          local arenaNpcCfg = getConfig('arenaNpcCfg')
          local sid = 's'..rank
          if arenaNpcCfg[sid] then
            setArenaRanking(rank,rank)
            return rank
          end

        end

    else
        return list[1][1]    
    end   
    return 450
end



function userGetUid(username)
    local db = getDbo()
    local result
    if type(username) == 'number' then 
        result = db:getRow("select uid from userinfo where uid=:uname",{uname=username})
    else
        result = db:getRow("select uid from userinfo where username=:uname",{uname=username})
    end
    if type(result) == 'table' and result['uid'] then
        return tonumber(result['uid'])
    end
    return 0
end

function userGetUidByNickname(nickname)
    local db = getDbo()
    local result = db:getRow("select uid from userinfo where nickname=:nickname",{nickname=nickname})
    if type(result) == 'table' and result['uid'] then
        return tonumber(result['uid'])
    end
    return 0
end

function userCreateUid()
    local maxUidKey = "z".._GAMEVARS['zoneid'].."_maxuid"
    local redis = getRedis()
    local uid = tonumber(redis:incr(maxUidKey)) or 0
    
    local minuid = _GAMEVARS['zoneid']*10000000
    
    if uid > minuid then
        return uid
    else
        local db = getDbo()
        local result = db:getRow("select max(uid) as uid from userinfo")
        if result then
            local maxUid = tonumber(result.uid) or 0
            if  maxUid < minuid then
                maxUid =  minuid
            end
                redis:set(maxUidKey,maxUid)
                uid = tonumber(redis:incr(maxUidKey)) 
            return uid
        end
    end
    return 0
end

function userLogin(uid)
        local db = getDbo()
        local result = db:getRow("select uid from userinfo where uid=:uid",{uid=uid})

        if result then
                return tonumber(result.uid) or -1
        else
            return 0
        end
end

function getUserObjs(uid,readOnly)    
    if not _GAMEVARS['userobjs_instances'][uid] then
        _GAMEVARS['userobjs_instances'][uid] = userobjs(uid,readOnly)
    end
    if not _GAMEVARS['userobjs_instances'][uid] then
        error ({code=-100})
    end
    return _GAMEVARS['userobjs_instances'][uid]
end

function getCacheObjs(uid,readOnly,source)
    uid=tonumber(uid)    
    if not _GAMEVARS['cacheobjs_instances'][uid] then
        _GAMEVARS['cacheobjs_instances'][uid] = cacheobjs(uid,readOnly)
    end
    if not _GAMEVARS['cacheobjs_instances'][uid] then
        error ({code=-101})
    end
    return _GAMEVARS['cacheobjs_instances'][uid]
end

function getUserAllianceSkills (aid) 
    if aid and _GAMEVARS['alliance'][aid] then
        return _GAMEVARS['alliance'][aid]
    end
end

function setUserAllianceSkills (aid,skills) 
    if aid then
        _GAMEVARS['alliance'][aid] = skills
    end
end

function setClientTs(ts)
    local ts_client = math.floor( tonumber(ts) or 0 )
    _GAMEVARS['ts'] = os.time()
    local ts_diff = _GAMEVARS['ts'] - ts_client
        
    if ts_diff>0 and ts_diff < 10 then
        _GAMEVARS['ts'] = ts_client
    end
end

function getClientTs()
    if _GAMEVARS['ts'] == 0 then
        setClientTs(os.time())
    end
    return _GAMEVARS['ts']
end

function setRequestCmd(cmd)
    _GAMEVARS['requestCmd'] = cmd
end

function getRequestCmd()
    return _GAMEVARS['requestCmd']
end

function getClientPlat()
    return _GAMEVARS['requestCmd'] and _GAMEVARS['requestCmd'][2] or 'def'
end

-- 获取客户端版号
function getClientBH()
    return _GAMEVARS['requestCmd'] and _GAMEVARS['requestCmd'][4] or 0
end

-- 获取客户端IP
function getClientIP()
    return _GAMEVARS['requestCmd'] and _GAMEVARS['requestCmd'][6] or "0"
end

function sysDebug()
    if _GAMEVARS['sysDebug'] == nil then
        _GAMEVARS['sysDebug'] = getConfig("base.SYSDEBUG")
    end
    return _GAMEVARS['sysDebug']
end

function getVersionCfg()
    if not _VERSIONCFG then
        local serverVersion = getConfig("base.serverVersion")
        local versionCfg = getConfig("version")
        _VERSIONCFG = versionCfg[serverVersion] or {}
    end
    
    return _VERSIONCFG
end

-- eid -------
-- 1支付
function regActionLogs(uid,logtype,params)
    if type (_GAMEVARS.action_log[uid] ) ~= 'table' then
        _GAMEVARS.action_log[uid] = {}
    end

    if logtype and type(params) == 'table' then
        params.type = logtype
        params.uid = uid
        table.insert(_GAMEVARS.action_log[uid],params)
    end
end

function setActionLogsStatus(status)
    status = status or 1
    if type (_GAMEVARS.action_log) == 'table' and next(_GAMEVARS.action_log) then
        _GAMEVARS.action_log.status = 1
    end

    setKfkStatus(status)
end

function processActionLogs()
    if type (_GAMEVARS.action_log ) == 'table' and _GAMEVARS.action_log.status == 1 then     
        _GAMEVARS.action_log.status = nil

        local http = require("socket.http")
        http.TIMEOUT= 0.5

        local logUrl,actionLogUrl
        local config = getConfig('config')
        local platform = getConfig("base.AppPlatform")    
        local cmd = getRequestCmd()
        local zoneid = getZoneId()
        local URL = require "lib.url"

        for uid,log in pairs(_GAMEVARS.action_log) do            
            if type(log) == 'table' and uid ~= 'status' then      
                local uobjs = getUserObjs(uid)
                local mUserinfo = uobjs.getModel('userinfo')
                
                for k,v in pairs(log) do
                    v.vip = mUserinfo.vip
                    v.level = mUserinfo.level
                    v.gems = v.nowGems and v.nowGems or mUserinfo.gems
                    v.zid = zoneid   
                    v.platform = platform
                    v.request = cmd
                    v.nowGems = nil
                    v.nickname = URL:url_escape(mUserinfo.nickname)
                    v.deviceid = mUserinfo.deviceid
                    v.subplat = mUserinfo.email
                    v.platid = tostring(mUserinfo.platid)
                    logUrl = logUrl or config['z'..v.zid].actionLogUrl
                    actionLogUrl = logUrl .. json.encode(v)
                    http.request(actionLogUrl)

                    -- 港台GS数据统计
                    -- 攻击玩家(主基地/正在采矿)
                    if platform == "ship_efun_tw" then
                        if v.type == 2 and (v.action == 1 or v.action == 2) then
                            writeLog(uid,"gsdata_attack_tw")
                        end
                    end
                end
            end
        end
    end
end

function regKfkLogs(uid,logtype,params)
    --do return end
    if type (_GAMEVARS.kfk_log[uid] ) ~= 'table' then
        _GAMEVARS.kfk_log[uid] = {}
    end

    if logtype and type(params) == 'table' then
        params.type = logtype
        params.user_id = uid
        if params.merge then
            local flags = {}
            for _,v in pairs(params.flags) do
                table.insert(flags,params[v])
            end
            table.insert(flags,logtype)

            local mergeStr = table.concat(flags,'_')

            if _GAMEVARS.kfk_log[uid][mergeStr] then
                for _,mergeField in pairs(params.merge) do
                    _GAMEVARS.kfk_log[uid][mergeStr][mergeField] = (_GAMEVARS.kfk_log[uid][mergeStr][mergeField] or 0) + (params[mergeField] or 0)
                end

                if params.rewrite then
                    for _,field in ipairs(params.rewrite) do
                        if params[field] then
                            _GAMEVARS.kfk_log[uid][mergeStr][field] = params[field]
                        end
                    end
                end

                _GAMEVARS.kfk_log[uid][mergeStr].addition = params.addition
            else
                _GAMEVARS.kfk_log[uid][mergeStr] = params
            end
        else
            table.insert(_GAMEVARS.kfk_log[uid],params)
        end
    end
end 

function setKfkStatus(status)
    status = status or 1
    if type (_GAMEVARS.kfk_log) == 'table' and next(_GAMEVARS.kfk_log) then
        _GAMEVARS.kfk_log.status = 1
    end
end

function processKfkLogs()

    if type (_GAMEVARS.kfk_log ) == 'table' and _GAMEVARS.kfk_log.status == 1 then     
        _GAMEVARS.kfk_log.status = nil

        local config = getConfig('config')
        local baseCfg = getConfig('base')
        local AppPlatformID = baseCfg.AppPlatformID
        local cmd = getRequestCmd()
        local zoneid = getZoneId()
        local ts = getClientTs()
        local datestr = getDateByTimeZone(ts,"%Y-%m-%d")

        if not libKafka then
            local kafka = require('lib.kafka')
            libKafka = kafka.new(config['z'..zoneid].kafka.host, config['z'..zoneid].kafka.port)
            -- local kf = kafka.new('192.168.8.209', '9092')
        end

        local type2KfkType = {item='item',tankChange='action',accessory='item',weapon='action',equip='action',userarena='action',expedition='action'}

        for uid,log in pairs(_GAMEVARS.kfk_log) do            
            if type(log) == 'table' and uid ~= 'status' then
                local mUserinfo

                for k,v in pairs(log) do
                    v.merge = nil
                    v.flags = nil
                    v.rewrite = nil
                    v.time = ts
                    v.zid = zoneid
                    v.op_type = cmd and cmd[1]
                    if v.type ~= 'item' then 
                        v.sub_type = v.type 
                    else
                        v.sub_type='prop'
                    end
                    v.type = type2KfkType[v.type] or "action"

                    if not v.notUser then 
                        if not mUserinfo then
                            mUserinfo = getUserObjs(uid).getModel('userinfo')
                        end

                        v.nickname=mUserinfo.nickname
                        v.subplat =mUserinfo.email
                        v.platid = mUserinfo.platid
                        v.deviceid = mUserinfo.deviceid
                    end
                    v.bigplat = AppPlatformID
                    v.date = datestr

                    v.notUser = nil
                    libKafka.produce(v,AppPlatformID)
                end
            end
        end

        type2KfkType = nil
        -- libKafka.destroyed(10)
    end
end

function regEvents(name,params)
    table.insert(_GAMEVARS.events,{name,params})
end

function processEvents()
end

function checkEvent(name)
    for k,v in pairs(_GAMEVARS.events) do
        if v[1] == name then
            return true
        end
    end
end

function copyTable(st)
    local tab = {}
    for k, v in pairs(st or {}) do
        if type(v) ~= "table" then
            tab[k] = v
        else
            tab[k] = copyTable(v)
        end
    end
    return tab
end

function pairsByKeys (t, f)
      local a = {}
      for n in pairs(t) do table.insert(a, n) end
      table.sort(a, f)
      local i = 0      -- iterator variable
      local iter = function ()   -- iterator function
        i = i + 1
        if a[i] == nil then return nil
        else return a[i], t[a[i]]
        end
      end
      return iter
end

--hallow compare of two tables
---------------------------------------------------------------------
local function diff(t1, t2)
    local type = type
    local pairs = pairs
    
    if t1 == t2 then return false; end
    -- 这里可以排除123,"123"这种情况，如果程序中把int类型转成string后再保存，其实是没有必要的 
    -- if tonumber(t1) == tonumber(t2) and tostring(t1) == tostring(t2) then
    --     return false;
    -- end
    if type(t1) ~= 'table' or type(t2) ~= 'table' then return true; end
    
    for k, v in pairs(t1) do
        if type(v) == 'table' then
            if diff(v,t2[k]) then return true; end
        else
            if v ~= t2[k] then return true; end
        end
    end
    
    for k, v in pairs(t2) do
        if type(v) == 'table' then
            if diff(v,t1[k]) then return true; end
        else
            if v ~= t1[k] then return true; end
        end
    end
    
    return false
end

function table_compare(t1, t2)
    return diff(t1,t2)
end

---------------------------------------------------------------------
function assert2 (expected, msg)
    if not msg then msg = ''    end
    return assert (expected,msg)
end

function table.contains(self, value)
    for _, v in pairs(self) do
        if v == value then return true end
    end
    return false
end

function merge_defaults(parameters,defaults)
    if parameters == nil then
        parameters = {}
    end
    
    for k, v in pairs(defaults) do
        if parameters[k] == nil then
            parameters[k] = defaults[k]
        else
            parameters[k]=parameters[k]+v
        end
    end
    return parameters
end

--[[
-- 合并t1与t2
-- params table t1
-- params table t2
-- params bool newTb 是否将合并的结果生成一个新的table，而不改变t1的值
-- return table
-- 将一个或多个数组的单元合并起来，一个数组中的值附加在前一个数组的后面。返回作为结果的数组。 

-- 如果输入的数组中有相同的字符串键名且值不都是数组，则该键名后面的值将覆盖前一个值。然而，如果数组包含数字键名，后面的值将不会覆盖原来的值，而是附加到后面。 

-- 如果输入的数组中有相同的字符串键名且值都是数组,则会递规的进行合并

-- 如果只给了一个数组并且该数组是数字索引的，则键名会以连续方式重新索引。
]]
function table.merge (t1,t2,newTb) 
    if newTb then
        t1 = copyTab(t1)
        t2 = copyTab(t2)
    end

    if t1 == nil then t1 = {} end

    for k, v in pairs(t2 or {}) do
        if type(t1) == 'table' and t1[k] == nil then
            t1[k] = t2[k]
        else
            if type(v) == "table" and type(t1[k]) == 'table' then
                table.merge (t1[k],v)
            else
                if type(t1) == 'table' then
                    if (type(t1[k]) ~= 'table' or type(v) ~= 'table') and type(k) ~= 'number' then
                        t1[k] = v
                    else
                        table.insert(t1,v)
                    end  
                end
            end
        end
    end

    return t1
end

function parse_boolean(v)
    if v == '1' or v == 'true' or v == 'TRUE' then
        return true
    elseif v == '0' or v == 'false' or v == 'FALSE' then
        return false
    else
        return nil
    end
end

function table.keys(self)
    local keys = {}
    for k, _ in pairs(self) do table.insert(keys, k) end
    return keys
end

function table.values(self)
    local values = {}
    for _, v in pairs(self) do table.insert(values, v) end
    return values
end

function copyTab(st)
    local tab = {}
    for k, v in pairs(st or {}) do
        if type(v) ~= "table" then
            tab[k] = v
        else
            tab[k] = copyTab(v)
        end
    end
    return tab
end

function arrayGet(array, key, default)
    if not key then return default or array end
    key = tostring(key)
    local keys = key:split('>')
    for _,v in pairs(keys) do
        if type(array) ~= 'table' then return default end
        v = tonumber(v) or v   
        array = array[v]
    end


    return tonumber(array) or array or default
end

-- lua保留n位小数方法
function GetPreciseDecimal(nNum, n)
    if type(nNum) ~= "number" then
        return nNum;
    end
    
    n = n or 0;
    n = math.floor(n)
    local fmt = '%.' .. n .. 'f'
    local nRet = tonumber(string.format(fmt, nNum))

    return nRet;
end

function writeLog(message,path)
    path = path or ''
    message = message or ''
    local date = os.date('%Y%m%d')
    local zoneid = tonumber(getZoneId()) or 0
    local logpath = zoneid > 0 and getConfig("config.z".. zoneid ..".logpath") or "/tmp/"
    local fileName = logpath .. path..zoneid..date .. '.log'

    if type(message) == 'table' then
        message = (json.encode(message) or '') .. '\r\n'
    else
        message = message .. '\r\n'
    end
    local ts = getClientTs()
    message = ts .. '|' .. (message or '')
    local f = io.open(fileName, "a+")
    if f then
        f:write(message)
        f:close()
    end
end

function writefile(message,path,wtype)
    path = path or ''
    wtype = wtype or 'a+'
    message = message or ''
    local date = os.date('%Y%m%d')
    local zoneid = tonumber(getZoneId()) or 0
    local logpath = zoneid > 0 and getConfig("config.z".. zoneid ..".logpath") or "/tmp/"
    local fileName = logpath .. path..zoneid..date .. '.log'

    if type(message) == 'table' then
        message = (json.encode(message) or {})
    else
        message = message
    end
    local ts = getClientTs()
    local f = io.open(fileName, wtype)
    if f then
        f:write(message)
        f:close()
    end
end

function readfile(path)
    path = path or ''
    wtype = wtype or 'r'
    message = message or ''
    local date = os.date('%Y%m%d')
    local zoneid = tonumber(getZoneId()) or 0
    local logpath = zoneid > 0 and getConfig("config.z".. zoneid ..".logpath") or "/tmp/"
    local fileName = logpath .. path..zoneid..date .. '.log'

    local f = io.read(fileName, wtype)
    if f then
        ptb:p(f)
    end
end
-- 排行榜log
function writeActiveRankLog(message,path,st)
    st = st or 0
    if st<=0 then
        return true
    end
    message = message or ''
    if message=='' then
        return true
    end
    local date = st
    local zoneid = tonumber(getZoneId()) or 0
    local logpath = zoneid > 0 and getConfig("config.z".. zoneid ..".logpath") or "/tmp/"
    local path = path or 'active'
    local fileName = logpath .. path..zoneid..date .. '.log'
    if type(message) == 'table' then
        message = (json.encode(message) or '') 
    else
        message = message 
    end
   
    local f = io.open(fileName, "w+")
    if f then
        f:write(message)
        f:close()
    end
end

function readRankfile(path,st)
    if st<=0 then
        return {}
    end
    local date = st
    local wtype ='r'
    local zoneid = tonumber(getZoneId()) or 0
    local logpath = zoneid > 0 and getConfig("config.z".. zoneid ..".logpath") or "/tmp/"
    local path = path or 'active'
    local fileName = logpath .. path..zoneid..date .. '.log'
    local file = io.open(fileName, "r")
    if file then
        local data = file:read("*a") -- 读取所有内容
        file:close()
        return json.decode(data) or {}
    end
    return {}
end
function tankError(message,level)
    error(message, (level or 1) + 1)
end

-- todo 宝石计算 "1分钟消耗1个超过1分钟且小于2分钟消耗2个，以此类推
function speedConsumeGems(secs)
    if secs <= 0 then return 0 end
    local iGems = 0
    local minutes = math.ceil((secs)/60)
    iGems = math.abs(minutes) * 1

    return iGems
end

-- 建筑等级更新后的队列所需时间比率
function getbuildQueueRate(buildLevel,timeConsume,addition,jobadd,equipadd,oceanExpBuff)
    addition = addition or 0
    jobadd   = jobadd   or 0  --区域站职位加成
    equipadd = equipadd or 0
    oceanExpBuff = oceanExpBuff or 0
    if buildLevel > 0 then
        return math.ceil( timeConsume/(1 + (buildLevel-1) * 0.05+addition+jobadd+equipadd+oceanExpBuff))
    end
    return timeConsume
end

-- 打乱数组
function table.rand(arr)

    local arr_size=#arr
    local tmp_arr={}

    setRandSeed()

    for i=1,arr_size do
        local rd=rand(1,arr_size+1-i)
        table.insert(tmp_arr,arr[rd])
        table.remove(arr,rd)
    end

    return tmp_arr
end

function setRandSeed()
    if _GAMEVARS.isseed == 0 then
        local socket = require("socket.core")
        math.randomseed( socket.gettime()*1000 )
        _GAMEVARS.isseed = 1
    end
end

-- 自动生成活动的自增的id
function getActiveIncrementId(activeName,expireTime)
    local maxIncrementKey = "z".._GAMEVARS['zoneid'].."_ac"..activeName.."INCREMENT"
    local redis = getRedis()
    local id = tonumber(redis:incr(maxIncrementKey)) or 0
    redis:expire(maxIncrementKey,expireTime)    
    return id

end

--获取活动中最大的自增id
function getMaxActiveIncrementId(activeName)

    local maxIncrementKey = "z".._GAMEVARS['zoneid'].."_ac"..activeName.."INCREMENT"
    local redis = getRedis()
    return redis:get(maxIncrementKey)
end

function rand(m,n)
    math.random(m,n); math.random(m,n); math.random(m,n)
    return math.random(m,n)
end

-- table 长度
function table.length(array)
    local len = 0
    if type(array) == 'table' then
        for _ in pairs(array) do
            len = len + 1
        end
    end

    return len
end


---------行军需要的时间

-- 根据攻击和自己的位置获取到格子数量。（勾股定理）
-- 每一个格子的基础航行时间为 20 秒
-- 出航的最低基础时间为 120 秒

-- 科技减少的移动时间
-- 最后结果向下取整。
function marchTimeConsume(selfCoord,targetCoord,techLevel,addition,asaddition,jobadd,oceanExpBuff)
    addition   =addition or 0
    asaddition =asaddition or 0
    jobadd     =jobadd or 0
    oceanExpBuff = oceanExpBuff or 0
    local x = math.pow( targetCoord[1] - selfCoord[1] ,2)
    local y = math.pow( targetCoord[2] - selfCoord[2] ,2 )
    local baseSec = 120 -- 基础时间
    local baseCellSec = 20  --单元格基础时间
    local techRate = 0.05
    local sec =  ( math.sqrt(x +y ) * baseCellSec + baseSec )  /  ( 1 + techLevel * techRate+addition+asaddition+jobadd+oceanExpBuff)
    return math.floor(sec)
end

---------------初始化舰队属性
    -- num      数量
    -- type     类型
    -- maxhp    最大血量
    -- hp       血量
    -- dmg      伤害
    -- arm      护甲
    -- salvo    齐射
    -- crit     爆击
    -- anticrit 免疫暴击
    -- accuracy 精准
    -- evade    闪避
    -- attacker[1] = {num=0,type=1,maxhp=150,hp=1500,dmg=500,anticrit=10,salvo=1,crit=0,accuracy=0,evade=0}
    -- 108 加血
    -- 100 加攻
    -- baseType 对应 兵种的type
    -- battleType 1攻击关卡,2攻击军团副本,3守卫基地,4军团关卡,5军团战,需要额外计算关卡加成,6普通关卡后来加了额外属性,20领海战,21 攻打矿点有守军 31 徽章副本
function initTankAttribute(tanks,techs,skills,propSlots,allianceSkills,battleType,params)
    local tankCfg = getConfig('tank')
    local techCfg = getConfig('tech')
    local skillCfg = getConfig('skill.skillList')
    local propCfg = getConfig('prop')
    local params = params or {}
    local commonCfg = getConfig("common")

    -- 军团据点战buff
    local allianceWarBuff,allianceWarCfg
    if battleType == 5 then
        -- allianceWarBuff = {}
        -- allianceWarBuff.b1 = {"maxhp","dmg","armor","arp"}
        -- allianceWarBuff.b2 = {"accuracy","evade","crit","anticrit"}
        -- allianceWarCfg = getConfig('allianceWarCfg')
    end

    ------------------------科技对坦克的加成-----------------------------
    local function techAdd(tank,techCfg,techs)
        local techLevel , rate= 0, 0
        local addAttributeValue = {}
        local tankType = tank.type

        for k,v in pairs(techCfg) do
            if v.baseType == tankType then
                techLevel = arrayGet(techs,k,0)

                if techLevel > 0 then
                    rate = techCfg[k].value[techLevel] / 100                    
                    if tonumber(v.attributeType) == 100 then
                        addAttributeValue.dmg = tank.dmg * rate
                    end

                    if tonumber(v.attributeType) == 108 then
                        addAttributeValue.maxhp = tank.maxhp * rate
                    end
                end
            end
        end

        return addAttributeValue
    end

    ------------------------技能加成-----------------------------
    local attributeType = getConfig("common.attrNumForAttrStr")
    local function skillAdd(tank,skillCfg,skills)
        local skillLevel,rate = 0,0
        local addAttributeValue = {}
        local tankType = tonumber(tank.type)
        
        --writeLog('skilladd1 uid='..skills.uid..'skills='..json.encode(skills.toArray()),'leaderskill')
        for k,v in pairs(skillCfg) do
            skillLevel = arrayGet(skills,k,0) 
            if skillLevel>0 then
                --新技能所有的坦克都能生效 
                --writeLog('skilladd2 s='..k..'lv='..skillLevel..'bty='..battleType,'leaderskill')
                if v.specialType==6 and battleType==3 then
                    --writeLog('newskill3='..k..skills.uid..'lv='..skillLevel..'bty='..battleType..'dmg='..tank['dmg'],'leaderskill')
                    local rate = skillCfg[k].skillValue*skillLevel
                    addAttributeValue['dmg'] = (addAttributeValue['dmg'] or 0) + tank['dmg'] * rate 
                    --writeLog('newdmg='..addAttributeValue['dmg']..'rate='..rate,'leaderskill')
                    addAttributeValue['dmg_reduce'] = 1- rate 
                elseif v.specialType==5 and battleType==21 then
                    --writeLog('newskill21='..k..skills.uid..'lv='..skillLevel..'bty='..battleType..'dmg='..tank['dmg'],'leaderskill')
                    local rate = skillCfg[k].skillValue*skillLevel
                    addAttributeValue['dmg'] = (addAttributeValue['dmg'] or 0) + tank['dmg'] * rate 
                    addAttributeValue['dmg_reduce'] = 1- rate 
                else
                    for _,baseType in pairs(v.skillBaseType) do
                        if tankType == baseType then 
                            local attrType = tonumber(v.attributeType) or 0
                            local attrName = attributeType[attrType]
                            if attrName then
                                local rate = skillCfg[k].skillValue*skillLevel
                                if attrName == 'maxhp' or attrName == 'dmg' then                            
                                    addAttributeValue[attrName] =(addAttributeValue[attrName] or 0) + tank[attrName] * rate 
                                else
                                    addAttributeValue[attrName] = rate
                                end
                            end
                        end
                    end
                end
            end
        end
        
        return addAttributeValue
    end
        

        ------------------------道具加成-----------------------------
        local prop4attribute = {
            attack='dmg',
            defence='dmg_reduce',
            avoid = 'evade',
            accurate = 'accuracy',
            critical = 'crit',
            decritical = 'anticrit',
        }
        local function propAdd(tank,propCfg,propSlots)
            local rate = 0.2            
            local ts = getClientTs()
            local tankType = tank.type
            local addAttributeValue = {}

            for k,v in pairs(propSlots) do   
                if v.st < ts and v.et > ts and next(tank) then 
                    for m,n in pairs(prop4attribute) do                        
                        if propCfg[v.id].useGetCrop and propCfg[v.id].useGetCrop[m] then
                            if n == 'dmg' then
                                addAttributeValue.dmg = (tank.dmg or 0) * (propCfg[v.id].useGetCrop[m] / 100)
                            elseif n == 'dmg_reduce' then
                                addAttributeValue.dmg_reduce = 1-(propCfg[v.id].useGetCrop[m]/100)
                            else
                                addAttributeValue[n] = propCfg[v.id].useGetCrop[m]/100
                            end
                        end
                    end
                end
            end
            
            return addAttributeValue
        end

    ------------------------军团加成-----------------------------
    local allianceSkillCfg
    if allianceSkills then
        allianceSkillCfg = getConfig("allianceSkillCfg")
    end
    local doubleHitS = {s6=1,s7=2,s8=4,s9=8,}

    local function allianceSkillAdd(tank,allianceSkillCfg,allianceSkills,battleType)
        local skillLevel,rate = 0,0
        local addAttributeValue = {}
        local tankType = tonumber(tank.type)

        for sid,skillLevel in pairs(allianceSkills) do
            skillLevel = tonumber(skillLevel) or 0
            rate = 0
            if skillLevel > 0 and allianceSkillCfg[sid] then
                for _,baseType in pairs(allianceSkillCfg[sid].skillBaseType) do
                    if tankType == baseType then                    
                        local attrType = tonumber(allianceSkillCfg[sid].attributeType) or 0
                        local attrName = attributeType[attrType]
                        if attrName then
                            if sid == 's1' or sid == 's3' then                                
                                if battleType == 1 and allianceSkillCfg[sid].challengeAddValue then                                    
                                    rate = (allianceSkillCfg[sid].challengeAddValue[skillLevel] or 0) / 100
                                end

                                if battleType == 3 and allianceSkillCfg[sid].defenseAddValue then
                                    rate = (allianceSkillCfg[sid].defenseAddValue[skillLevel] or 0) / 100                                    
                                end

                                 if battleType == 2 and allianceSkillCfg[sid].defenseAddValue then
                                    rate = (allianceSkillCfg[sid].defenseAddValue[skillLevel] or 0) / 100   * 5                          
                                end

                                if rate > 0 then
                                    addAttributeValue[attrName] = tank[attrName] * rate
                                end

                            elseif sid == 's2' or sid == 's4' then
                                if battleType == 1 and allianceSkillCfg[sid].challengeReduceValue then
                                    rate = (allianceSkillCfg[sid].challengeReduceValue[skillLevel] or 0) / 100
                                end

                                if battleType == 3 and allianceSkillCfg[sid].defenseReduceValue then
                                    rate = (allianceSkillCfg[sid].defenseReduceValue[skillLevel] or 0) / 100                                    
                                end

                                if battleType == 2 and allianceSkillCfg[sid].aChallengeReduceValue then
                                    rate = 1 - (allianceSkillCfg[sid].aChallengeReduceValue[skillLevel] or 0)
                                end

                                if rate > 0 then
                                    addAttributeValue.dmg_reduce = 1 - rate
                                end
                            
                            else 
                                rate = allianceSkillCfg[sid].value[skillLevel] / 100
                                if rate > 0 then
                                    if attrName == 'maxhp' or attrName == 'dmg' then                            
                                        addAttributeValue[attrName] = tank[attrName] * rate 
                                    else
                                        addAttributeValue[attrName] = rate
                                    end
                                end
                            end
                        else
                            if sid == 's10' then
                                addAttributeValue.buff_value = allianceSkillCfg[sid].buffValue[skillLevel] / 100
                            elseif doubleHitS[sid] and doubleHitS[sid] == tankType then
                                addAttributeValue.double_hit = allianceSkillCfg[sid].batterValue[skillLevel]
                            end
                        end
                    end
                end
            end
        end
        
        return addAttributeValue
    end

    local function allianceChallengeAdd(tank,attributeUp,attributeUp2)
        if type(tank) == 'table' and type(attributeUp) == 'table' then
            local baseAtt = {attack='dmg',life='maxhp',critical='crit',decritical='anticrit',avoid='evade',accurate='accuracy',armor='armor',arp='arp'}
            if type(attributeUp2) == 'table' then
                for k,v in pairs(attributeUp2) do                 
                    if baseAtt[k] and tank[baseAtt[k]] then
                        tank[baseAtt[k]] = (tank[baseAtt[k]] or 0) + v
                    end
                end
            end

            for k,v in pairs(attributeUp) do                 
                if baseAtt[k] and tank[baseAtt[k]] then
                    if k == 'armor' or k == 'arp' then
                        tank[baseAtt[k]] = (tank[baseAtt[k]] or 0) + v
                    else
                        tank[baseAtt[k]] = tank[baseAtt[k]] * v
                    end
                end
            end
        end
        
        return tank
    end

    local function  accessoryAdd(tank,accessoryAttribute,accessorySuccinctAttribute)
        --[[ 
            ptb:e(accessoryAttribute)
            ["t2"] = {
                ["armor"] = 20,
                ["attack"] = 0.18,
                ["arp"] = 20,
                ["hp"] = 0.01,
            },
            ["t1"] = {
                ["armor"] = 20,
                ["attack"] = 0.18,
                ["arp"] = 20,
                ["hp"] = 0.01,
            },
        ]]
        
        local addAttributeValue = {}
        local acc2TankType = {t1=1,t2=2,t3=4,t4=8}
        local baseAtt = {attack='dmg',hp='maxhp',armor='armor',arp='arp'}

        if type(accessoryAttribute) == 'table' and next(accessoryAttribute) then
            for k,v in pairs(accessoryAttribute) do
                if acc2TankType[k] == tank.type then
                    for m,n in pairs(v) do
                        if baseAtt[m] then
                            if baseAtt[m] == "dmg" or baseAtt[m] == "maxhp" then
                                addAttributeValue[baseAtt[m]] = tank[baseAtt[m]] * n
                            else
                                addAttributeValue[baseAtt[m]] = n
                            end
                        else
                            addAttributeValue[m] = n
                        end
                    end
                end
            end
        end

        if type(accessorySuccinctAttribute) == 'table' and next(accessorySuccinctAttribute) then
            for k,v in pairs(accessorySuccinctAttribute) do
                if acc2TankType[k] == tank.type then
                    return v
                end
            end
        end

        return addAttributeValue
    end

    -- 地形加成
    local landformCfg -- 地形配置
    local function  landformAdd(tank,landformInfo,landformCfg,attributeType)
        local addAttributeValue = {}
        -- landformInfo = 6
        if type(landformCfg[landformInfo]) == 'table' then
            for k,v in ipairs(landformCfg[landformInfo].attType) do
                local attrName = attributeType[v]
                local rate = landformCfg[landformInfo].attValue[k]

                if attrName == 'maxhp' or attrName == 'dmg' then
                    addAttributeValue[attrName] = tank[attrName] * rate 
                elseif attrName == 'dmg_reduce' then
                    addAttributeValue[attrName] = 1 - rate
                else
                    addAttributeValue[attrName] = rate
                end
            end            
        end
        
        return addAttributeValue
    end
    
    -- 关卡buff加成
    local challengeTechCfg
    local function challengeBuffAdd (tank,challengeBuff,challengeTechCfg)
        local addAttributeValue = {}
        local rate

        for k,v in pairs(challengeBuff) do
            if challengeTechCfg[k] and challengeTechCfg[k].attributeType then
                local  attrName = attributeType[challengeTechCfg[k].attributeType] 
                if attrName then                
                    rate = challengeTechCfg[k].value[v]
                    if attrName == 'maxhp' or attrName == 'dmg' then                            
                        addAttributeValue[attrName] = tank[attrName] * rate 
                    elseif attrName == 'dmg_reduce' then
                        addAttributeValue[attrName] = 1 - rate
                    else
                        addAttributeValue[attrName] = rate
                    end
                end
            end
        end

        return addAttributeValue
    end

    -- 新的军衔加成
    local rankCfg = getConfig('rankCfg')
    local function rankAdd (tank,rank,rankCfg)
        local addAttributeValue = {}

        if rankCfg.rank[rank] then
            if rankCfg.rank[rank].attAdd[1] > 0 then
                addAttributeValue.dmg = rankCfg.rank[rank].attAdd[1] * tank.dmg
            end

            if rankCfg.rank[rank].attAdd[2] > 0 then
                addAttributeValue.maxhp = rankCfg.rank[rank].attAdd[2] * tank.maxhp
            end
        end

        return addAttributeValue
    end

    -- 超级装备加成
    local function equipAdd (tank, equipattr, idx)
        local addV = {}
        
        for attr, add in pairs(equipattr) do
            if (attr == 'first' or attr == 'antifirst') then
                if idx==1 then
                    addV[attr] = add
                end
            else
                if tank[attr] then
                    addV[attr] = tank[attr] * add
                end
            end 
        end

        return addV
    end

    -- 异星科技加成
    local function alienTechAdd(tank ,alienAttr, attributeType)
        local addAttributeValue = {}

        for attrName, rate in pairs( alienAttr ) do
            if attributeType[attrName] == 'maxhp' or attributeType[attrName] == 'dmg' then
                addAttributeValue[attributeType[attrName]] = tank[attributeType[attrName]] * rate 
            else
                addAttributeValue[attributeType[attrName]] = rate
            end
        end

        return addAttributeValue
    end

    -- 异星武器加成
    local function aweaponAdd(tank, weaponAttr, k)
        local addValue = {}
        if type(weaponAttr[k]) == 'table' and next(weaponAttr[k]) then
            for attName, rate in pairs(weaponAttr[k]) do
                if attName == 'dmg' or attName == 'maxhp' then 
                    addValue[attName] = tank[attName] * rate -- 加比例
                else
                    addValue[attName] = rate -- 加数值
                end
            end
        end
        return addValue
    end

    -- 装甲矩阵
    local function armorMatrixAdd(tank,attributes)
        local addAttributeValue = {}
        local baseAtt = {attack='dmg',hp='maxhp'}
        if type(attributes) == 'table' then
            for k,v in pairs(attributes) do
                k = baseAtt[k] or k
                if tank[k] then
                    if k == "dmg" or k == "maxhp" then
                        addAttributeValue[k] = tank[k] * v
                    else
                        addAttributeValue[k] = v
                    end
                end
            end
        end
        return addAttributeValue
    end

    -- 飞机加成
    local function planeAdd (tank, planeid,level)
        local addAttributeValue = {}
        local planeCfg = getConfig('planeCfg.plane')
        local attributeType=commonCfg.attributeUpForAttrStr
        if planeCfg[planeid] and level>0 then
            for attr, add in pairs(planeCfg[planeid].attUp) do
                addAttributeValue[attributeType[attr]]=(addAttributeValue[attributeType[attr]] or 0)+add[level]
            end
        end
        return addAttributeValue
    end

    -- 领地BUFF
    local function territoryBuffAdd(tank,attributes)
        local addAttributeValue = {}
        if type(attributes) == 'table' then
            for k,v in pairs(attributes) do
                if tank[k] then
                    if k == "dmg" or k == "maxhp" then
                        addAttributeValue[k] = tank[k] * v
                    else
                        addAttributeValue[k] = v
                    end
                end
            end
        end
        return addAttributeValue
    end

    -- 补给舰属性加成
    local function tenderAttrsAdd(tank,attributes,idx)
        local addAttributeValue = {}
        if type(attributes) == 'table' then
            for k,v in pairs(attributes) do
                if tank[k] then
                    if (k == 'first' or k == 'antifirst') then
                        if idx==1 then
                            addAttributeValue[k] = v
                        end
                    elseif k == "dmg" or k == "maxhp" then
                        addAttributeValue[k] = tank[k] * v
                    elseif k == 'dmg_reduce' then
                        addAttributeValue[k] = 1 - v
                    else
                        addAttributeValue[k] = v
                    end
                end
            end
        end
        return addAttributeValue
    end

    -- 雕像加成
    local function statueAdd(tank,skillAtt,idx)
        local baseAdd,specialAdd = {},{}
        local baseAtt,specialAtt = {'maxhp','dmg','crit','anticrit','accuracy','evade','armor','arp','first'},{'dmg','dmg_reduce'}
        if skillAtt then
            -- 基础配置为基数
            if skillAtt.skill then
                for _,attkey in pairs(baseAtt) do
                    if tank[attkey] and skillAtt.skill[attkey] then
                        if attkey == 'first' then
                            if idx == 1 then 
                                baseAdd[attkey] = skillAtt.skill[attkey]
                            end
                        else
                            baseAdd[attkey] = tank[attkey] * skillAtt.skill[attkey]
                        end
                    end
                end
            end

            -- 最后总值再乘系数
            if skillAtt.special then
                for _,attkey in pairs(specialAtt) do
                    if skillAtt.special[attkey] then
                        if attkey == 'dmg_reduce' then
                            specialAdd[attkey] = 1 - skillAtt.special[attkey]
                        else
                            specialAdd[attkey] = 1 + skillAtt.special[attkey]
                        end
                    end
                end
            end
        end
        return baseAdd,specialAdd
    end

    -- 徽章加成
    local function badgeAttadd(tank,badgeVal,battleType)
        local addAttr = {}
        local attname = {"dmg","maxhp","accuracy","evade","crit","anticrit"}--顺序固定
        local addAttributeValue = {dmg=0,maxhp=0,accuracy=0,evade=0,crit=0,anticrit=0}
        local otherVal = {dmg=0,maxhp=0,accuracy=0,evade=0,crit=0,anticrit=0}
        if next(badgeVal.att) then
            addAttributeValue = badgeVal.att
        end

        -- 1-在任何条件下增加战斗属性，(写死判断了)
        -- 2-增加内矿资源产出速度，(有单独的方法 战斗这里用不到)
        -- 3-增加关卡战斗属性（参照电磁轨道炮技能s102），
        -- 4-增加服内PVP战斗属性（参照超级计算机技能s306)，
        -- 5-增加跨服战的战斗属性（参照射线歼击仪技能s307）
        local baTypes = {[1]=3,[11]=4,[5]=4,[12]=5}
        if next(badgeVal.skill) then
            local  badgesscfg = getConfig("badge.detailList")
            for k,v in pairs(badgeVal.skill) do
                local sscfg = badgesscfg[v]
                if sscfg then
                    -- 任何战斗都生效
                    if sscfg.type == 1 then
                        if sscfg.shipType == 15 or sscfg.shipType == tank.type then
                            for sk,sv in pairs(sscfg.attType) do
                                addAttributeValue[attname[sv]] = (addAttributeValue[attname[sv]] or 0) + sscfg.att[sk]/100
                            end
                        end
                    elseif baTypes[battleType] then
                        if sscfg.type == baTypes[battleType] then
                            for sk,sv in pairs(sscfg.attType) do
                                otherVal[attname[sv]] = (otherVal[attname[sv]] or 0) + sscfg.att[sk]/100
                            end
                        end
                    end
                end
            end
        end
     
        -- 部队基础属性
        for k,v in pairs(addAttributeValue) do
            if k == "dmg" or k == "maxhp" then
                addAttr[k] = tank[k] * v
            else
                addAttr[k] = v
            end
        end

        return addAttr,otherVal -- addAttr:直接叠加  otherVal:在全属性的基础上再做计算的值
    end

    -- 徽章副本npc的攻击 血量会根据玩家携带兵种数量降低
    local function badgeChallenge(tank,attributeUp,tynum)
        local NPCDecrease = getConfig("badge.main.NPCDecrease")/100
        local baseAtt = {attack='dmg',life='maxhp',critical='crit',decritical='anticrit',avoid='evade',accurate='accuracy',armor='armor',arp='arp'}
        if type(tank) == 'table' and type(attributeUp) == 'table' then
            for k,v in pairs(attributeUp) do                 
                if baseAtt[k] and tank[baseAtt[k]] then
                    tank[baseAtt[k]] = tank[baseAtt[k]] * v    
                    if tynum>0 then
                        if k=="attack" or k =="life" then
                            tank[baseAtt[k]] = tank[baseAtt[k]] * (1-tynum*NPCDecrease)
                        end   
                    end
                end
            end
        end
        
        return tank
    end

    local fleet,tankId,tankAttribute,nums,techAddValue,skillAddValue,propAddValue,accessoryAddValue = {}
    local allianceSkillAddValue = {}    
    local challengeBuffAddValue = {} -- 关卡BUFF加成后的属性值
    local rankAddValue = {} -- 军衔加成
    local equipAddValue = {}
    local equipskillAddValue = {}
    local addequipfirst=0

    for k,v in pairs(tanks) do
        fleet[k] = {}
        if type (v) == 'table' and next(v) then            
            tankId , nums= arrayGet(v,1),arrayGet(v,2,0)
            if tankId and nums > 0 then
                addequipfirst=addequipfirst+1
                fleet[k].num = nums --数量
                tankAttribute = tankCfg[tankId]                
                fleet[k].type   =tankAttribute.type  --类型
                fleet[k].buffType = tankAttribute.buffType or tankAttribute.type
                fleet[k].maxhp =  tankAttribute.life     --血量
                fleet[k].dmg  = tankAttribute.attack    --伤害
                fleet[k].salvo   = tankAttribute.attackType    --齐射
                fleet[k].crit  = tankAttribute.critical/100   --爆击
                fleet[k].anticrit = tankAttribute.decritical/100 --免役暴击 韧性 装甲
                fleet[k].accuracy = tankAttribute.accurate/100 --精准
                fleet[k].evade   = tankAttribute.avoid/100 --闪避
                fleet[k].dmg_reduce = 0     -- 减伤
                fleet[k].double_hit = 0     -- 连击
                fleet[k].buff_value = 0     -- 基础buff值,这个值是军团科技等其它外部加成值
                fleet[k].buffvalue = tankAttribute.buffvalue or 0 -- 此值是后来直接赋加在tank上的，原来是动态计算的
                fleet[k].armor = 0     -- 防护
                fleet[k].arp = 0        -- 穿透
                fleet[k].evade_reduce = 0 -- 减敌方闪避
                fleet[k].anticrit_reduce = 0 -- 减敌方装甲
                fleet[k].landform = 0 -- 地形
                fleet[k].actionType = 0 -- 部队作战行为battleType
                fleet[k].critDmg = 0 -- 暴击造成的伤害倍数
                fleet[k].decritDmg = 0 -- 减暴击造成的伤害倍数值
                fleet[k].first = 0  -- 先手值
                fleet[k].antifirst = 0  -- 反先手值
                fleet[k].dedouble_hit = 0  -- 减连击
                fleet[k].debuff_value = 0  -- 减光环加成

                local tmpFleetAbilityId = nil
                local tmpFleetAbilityLv = nil
                local alienAddValue = {}
                if params.alienTechAddValue and params.alienTechAddValue[tankId] then
                    for attrName,attrVal in pairs(params.alienTechAddValue[tankId]) do 
                        if type(attrName) == 'string' and #attrName == 1 then
                            tmpFleetAbilityId = attrName
                            tmpFleetAbilityLv = attrVal
                        elseif attributeType[attrName] then
                            fleet[k][attributeType[attrName]] = (fleet[k][attributeType[attrName]] or 0) + attrVal
                        end
                    end
                end
                
                -- 军团关卡，精英关卡 防守方有加成
                if battleType == 4 or battleType == 2 or battleType == 6 or params.attrUpFlag then                    
                    fleet[k] = allianceChallengeAdd(fleet[k],params.acAttributeUp,params.acAttributeUp2)
                end

                -- 指挥官徽章副本npc加成 typenum进攻方带的兵种数 该值会降低npc的攻 血
                if battleType == 31 then
                     fleet[k] = badgeChallenge(fleet[k],params.acAttributeUp,params.typenum)
                end  

                -- 科技加成
                techAddValue = techs and techAdd(fleet[k],techCfg,techs) or {}

                -- 技能加成
                skillAddValue = skills and skillAdd(fleet[k],skillCfg,skills) or {}
                
                -- 军团技能加成
                if allianceSkills then
                    allianceSkillAddValue = allianceSkillAdd(fleet[k],allianceSkillCfg,allianceSkills,battleType)                    
                end

                -- 装备加成                
                accessoryAddValue = accessoryAdd(fleet[k],params.accessory)

                -- 关卡BUFF加成
                if params.challengeBuff then
                    challengeTechCfg = challengeTechCfg or getConfig('challengeTech')
                    challengeBuffAddValue = challengeBuffAdd (fleet[k],params.challengeBuff,challengeTechCfg)
                end

                -- 军衔加成
                if params.rank then
                    rankAddValue = rankAdd (fleet[k],params.rank,rankCfg)
                end
                
                -- 超级装备的属性 加基础属性
                if params.equip and next(params.equip) then
                    equipAddValue = equipAdd(fleet[k], params.equip, addequipfirst)
                end

                -- 异星科技属性
                if type(params.alienTechAddValue1) == 'table' and params.alienTechAddValue1[tankId] then
                    alienAddValue = alienTechAdd(fleet[k], params.alienTechAddValue1[tankId], attributeType)
                end

                -- 异星武器属性
                local aweaponAddValue = {}
                if type(params.aweapon) == 'table' and next(params.aweapon) then
                    aweaponAddValue = aweaponAdd(fleet[k], params.aweapon, k)
                end

                -- 装甲矩阵,对应每个位置的属性
                local armorMatrixAddValue = {}
                if params.armor and params.armor[k] then
                    armorMatrixAddValue = armorMatrixAdd(fleet[k],params.armor[k])
                end


                -- 飞机加成
                local planeAddValue={}
                if params.planeSkills and params.planeSkills[1]  and params.planeSkills[1]~=0 then
                    planeAddValue= planeAdd(fleet[k],params.planeSkills[1],params.planeSkills[3])--第三个参数是飞机的等级
                end

                -- 军团领地加成
                local territoryBuffAddValue = {}
                if params.territoryBuff then
                    territoryBuffAddValue = territoryBuffAdd(fleet[k],params.territoryBuff)
                end

                -- 补给舰加成
                local tenderAddValue = {}
                if params.tenderAttrs then
                    tenderAddValue = tenderAttrsAdd(fleet[k],params.tenderAttrs,addequipfirst)
                end

                -- writeLog('start','leaderskill')
                -- writeLog('fleet uid='..skills.uid,'leaderskill')
                -- writeLog('fleetval='..json.encode(fleet),'leaderskill')
                -- writeLog('techAddValue='..json.encode(techAddValue),'leaderskill')
                -- writeLog('skillAddValue='..json.encode(skillAddValue),'leaderskill')
                -- writeLog('allianceSkillAddValue='..json.encode(allianceSkillAddValue),'leaderskill')
                -- writeLog('accessoryAddValue='..json.encode(accessoryAddValue),'leaderskill')
                -- writeLog('challengeBuffAddValue='..json.encode(challengeBuffAddValue),'leaderskill')
                -- writeLog('rankAddValue='..json.encode(rankAddValue),'leaderskill')
                -- writeLog('equipAddValue='..json.encode(equipAddValue),'leaderskill')
                -- writeLog('alienAddValue='..json.encode(alienAddValue),'leaderskill')
                -- writeLog('aweaponAddValue='..json.encode(aweaponAddValue),'leaderskill')
                -- writeLog('armorMatrixAddValue='..json.encode(armorMatrixAddValue),'leaderskill')
                -- writeLog('territoryBuffAddValue='..json.encode(territoryBuffAddValue),'leaderskill')

                local seawarBuffAddValue = {}
                if battleType == 20 then
                    local cfg = getConfig('allianceDomainWar')
                    for _,attr in pairs({"dmg","maxhp"}) do
                        seawarBuffAddValue[attr] = fleet[k][attr] * cfg.battleBuff
                    end
                end

                -- 战争雕像加成
                local statueBaseAdd,statueSpecialAdd = {},{} --基础值和总值，算法不同
                if params.statue then
                    statueBaseAdd,statueSpecialAdd=statueAdd(fleet[k],params.statue,addequipfirst)
                end

                -- 指挥官徽章加成
                local badgeadd1,badgeadd2 = {},{}
                if params.badge then
                    badgeadd1,badgeadd2 = badgeAttadd(fleet[k],params.badge,battleType)
                end

                for m,n in pairs(fleet[k]) do
                    if m == 'dmg_reduce' then
                        fleet[k][m] = fleet[k][m] + (techAddValue[m] or 1) * (skillAddValue[m] or 1) * (allianceSkillAddValue[m] or 1) * (challengeBuffAddValue[m] or 1) * (equipAddValue[m] or 1) * (aweaponAddValue[m] or 1)  * (planeAddValue[m] or 1)
                    else
                        fleet[k][m] = fleet[k][m] + (techAddValue[m] or 0) + (skillAddValue[m] or 0) + (allianceSkillAddValue[m] or 0) + (accessoryAddValue[m] or 0) + (challengeBuffAddValue[m] or 0) + (rankAddValue[m] or 0) + (equipAddValue[m] or 0) + (alienAddValue[m] or 0) + (aweaponAddValue[m] or 0) + (armorMatrixAddValue[m] or 0) + (territoryBuffAddValue[m] or 0) + (seawarBuffAddValue[m] or 0) + (planeAddValue[m] or 0) + (tenderAddValue[m] or 0) + (statueBaseAdd[m] or 0) + (badgeadd1[m] or 0)
                    end
                end

                -- writeLog('feetendval='..json.encode(fleet),'leaderskill')

                -- writeLog('end','leaderskill')

                if type(propSlots) == 'table' then 
                    propAddValue = propAdd(fleet[k],propCfg,propSlots)                     
                    if type(propAddValue) == 'table' then
                        for pk,pv in pairs(propAddValue) do
                            if pk == 'dmg_reduce' then
                                fleet[k][pk] = fleet[k][pk] * pv
                            else
                                fleet[k][pk] = fleet[k][pk] +pv
                            end
                        end                        
                    end
                end
                
                -- 军团据点战
                -- if allianceWarBuff and params.allianceWarBuff then
                --     for warBuffKey,warBuffLv in pairs(params.allianceWarBuff or {}) do
                --         if warBuffLv > 0 and allianceWarBuff[warBuffKey] then
                --             for _,attribute in ipairs(allianceWarBuff[warBuffKey]) do 
                --                 if warBuffKey == 'b2' then                                    
                --                     fleet[k][attribute] = fleet[k][attribute] + allianceWarCfg.buffSkill[warBuffKey].per * warBuffLv
                --                 else
                --                     fleet[k][attribute] = fleet[k][attribute] + fleet[k][attribute] * allianceWarCfg.buffSkill[warBuffKey].per * warBuffLv
                --                 end
                --             end
                --         end
                --     end
                -- end

                -- 世界boss战
                if params.attackBossBuff then
                    local attackBossBuff = {
                        b1 = "accuracy", -- 命中
                        b2 = "crit", -- 暴击
                        b3 = "dmg", -- 攻击 
                        b4 = "double_hit", -- 连击
                    }

                    local attackBossCfg = getConfig('bossCfg')

                    for warBuffKey,warBuffLv in pairs(params.attackBossBuff or {}) do
                        if warBuffLv > 0 and attackBossBuff[warBuffKey] then
                            local attribute = attackBossBuff[warBuffKey]
                            if warBuffKey == 'b3' then   
                                fleet[k][attribute] = fleet[k][attribute] + fleet[k][attribute] * attackBossCfg.buffSkill[warBuffKey].per * warBuffLv
                            else                                 
                                fleet[k][attribute] = fleet[k][attribute] + attackBossCfg.buffSkill[warBuffKey].per * warBuffLv
                            end
                        end
                    end
                end
                
                -- -- 地形加成
                local landformAddValue = {}
                if params.landform and params.landform > 0 then
                    if not landformCfg then landformCfg = getConfig("worldGroundCfg") end
                    landformAddValue = landformAdd(fleet[k],params.landform,landformCfg,attributeType)
                    fleet[k].landform = params.landform
                    
                    if type(landformAddValue) == 'table' then
                        for landBuffKey,landBuffValue in pairs(landformAddValue) do
                            if landBuffKey == 'dmg_reduce' then
                                fleet[k][landBuffKey] = fleet[k][landBuffKey] * (landBuffValue or 1)
                            else
                                fleet[k][landBuffKey] = fleet[k][landBuffKey] + (landBuffValue or 0)
                            end
                        end
                    end
                end
                
                -- 英雄属性加成
                -- heros {'atk','hlp','hit','eva','cri','res','first','antifirst'}
                if params.heros and next(params.heros[k]) then
                    for tk,tv in pairs({"dmg","dmg_reduce","accuracy","evade","crit","anticrit",'first','antifirst'}) do
                        if params.heros[k].a[tk] > 0 then
                            if tv == 'dmg' then
                                fleet[k][tv] = fleet[k][tv] + fleet[k][tv] * params.heros[k].a[tk] / 100
                            elseif tv =='dmg_reduce' then
                                fleet[k][tv] = fleet[k][tv] / (1+params.heros[k].a[tk]/100)
                            elseif tv =='first' or tv =='antifirst' then
                                fleet[k][tv] = (fleet[k][tv] or 0) + params.heros[k].a[tk]
                            else
                                fleet[k][tv] = fleet[k][tv] + params.heros[k].a[tk] / 100
                            end
                        end
                    end

                    fleet[k].hero = params.heros[k].s
                end

                if not fleet[k].hero then fleet[k].hero = {} end
                
               -- 超级装备的技能
                if params.equipskill and next(params.equipskill) then
                    equipskillAddValue = equipAdd(fleet[k], params.equipskill, addequipfirst)
                    if type(equipskillAddValue) == 'table' and next(equipskillAddValue) then
                        for attrk, attrv in pairs( equipskillAddValue ) do
                            if attrk == 'dmg_reduce' then
                                fleet[k][attrk] = attrv 
                            else
                                fleet[k][attrk] = fleet[k][attrk] + (attrv or 0)
                            end
                        end
                    end
                end

                -- 战争雕像技能 dmg,dmg_reduce属性最后总加成
                if statueSpecialAdd and next(statueSpecialAdd) then
                    for sk,sv in pairs(statueSpecialAdd) do
                        if fleet[k][sk] and sv and sv > 0 then
                            fleet[k][sk] = fleet[k][sk] * (sv or 1)
                        end
                    end
                end

                -- 指挥官徽章
                if badgeadd2 and next(badgeadd2) then
                    for attrk,attrv in pairs(badgeadd2) do
                        if attrv>0 then
                            if attrk == 'dmg' or attrk == "maxhp" then
                                fleet[k][attrk] = fleet[k][attrk] * (1+attrv)
                            else
                                if fleet[k][attrk] then
                                    fleet[k][attrk] = fleet[k][attrk]+attrv
                                end               
                            end
                        end
                    end
                end

                fleet[k].maxhp = math.floor(fleet[k].maxhp)
                fleet[k].hp   = fleet[k].maxhp * nums  --最大血量
                fleet[k].id = tankId 

                fleet[k].abilityID = tmpFleetAbilityId
                fleet[k].abilityLv = tmpFleetAbilityLv

                -- 上面如果有异星科技加了技能，那么，不用管tank.cfg中的配置了
                if not fleet[k].abilityID then
                    fleet[k].abilityID = tankAttribute.abilityID    -- 技能id
                    fleet[k].abilityLv = tankAttribute.abilityLv    -- 技能等级
                end

                -- 装备的洗练属性
                if params.accessorySuccinctAttribute and next(params.accessorySuccinctAttribute) then
                    fleet[k].asa = accessoryAdd(fleet[k],nil,params.accessorySuccinctAttribute)
                end

                -- 修改减伤属性过长
                fleet[k].dmg_reduce=GetPreciseDecimal(fleet[k].dmg_reduce,6) or 0


                fleet[k].abilityInfo = {    -- 技能作用详情
                    debuff={},  -- 减益
                    buff={},    -- 增益
                }  

                -- 配件科技技能
                local type2SkillKey = commonCfg.tankTypeToAccessorySkillKey[fleet[k].type]
                fleet[k].accessorySkill = {}
                if type(params.accessoryTechSkill) == 'table' and params.accessoryTechSkill[type2SkillKey] then
                    fleet[k].accessorySkill = params.accessoryTechSkill[type2SkillKey]
                end

                 -- 新加的指挥官技能
                fleet[k].playerSkill = params.playerSkill
                
                fleet[k].isSpecial = tankAttribute.isSpecial
                -- 英雄技能在特定行为下生效
                if tonumber(battleType) then
                    fleet[k].actionType = tonumber(battleType)
                end
                -- 异星武器的技能
                if type(params.aweaponSkill) == 'table' then
                    fleet[k].aweapon = params.aweaponSkill[k] or {} -- 每个战斗部位都有自己的技能
                else
                    fleet[k].aweapon = {}
                end
                -- 飞机技能
                fleet[k].plane = params.planeSkills or 0
                -- 补给舰技能
                fleet[k].tenderSkill = params.tenderSkill or 0
                fleet[k].tenderInfo = params.tenderInfo or 0
            end
        end
    end

    return fleet
end

--------按mid获取座标点
function getPosByMid(mid)
    if mid <= 360000 and mid >= 1 then
        local x = mid % 600
        if x == 0 then  x = 600 end
        local y = math.ceil(mid /600)

        return {x=x,y=y}
    end
end

function getMidByPos(x,y)
    local pos = (y-1)*600 + x
    if pos < 1 or pos > 360000 then
        tankError('pos invalid:'..pos)
        return false
    end

    return pos
end

-- 按mid获取异星矿山的座标点
function getAlienMinePosByMid(mid)
    if mid <= 400 and mid >= 1 then
        local x = mid % 20
        if x == 0 then  x = 20 end
        local y = math.ceil(mid /20)
        
        return {x=x,y=y}
    end
end

-- 根据座标获取异星矿山的id
function getAlienMineMidByPos(x,y)
    local pos = (y-1)*20 + x
    if pos < 1 or pos > 400 then
        tankError('pos invalid:'..pos)
        return false
    end

    return pos
end

----随机生成座标
-- type 6 玩家
function getMapPos(uid,name,isSetSeed,level,power,rank,alliance,protect,pic,allianceLogo)
    if not isSetSeed then
        setRandSeed()
        isSetSeed = true
    end

    local boxid,x,y
    if (tonumber(level) or 0) >= 20 then
        boxid = rand(1,36)
    else
        local baseUid = 1000000
        local baseBoxlen = 500

        boxid=math.ceil(uid % baseUid/baseBoxlen)
        boxid = boxid == 0 and 1 or boxid
        local box={15,16,21,22,14,23,8,29,20,17,9,27,10,28,26,11}
        local box1 = {1,2,3,4,5,6,12,18,24,30,36,35,34,33,32,31,25,19,13,7}

        if boxid <= 16 and boxid >= 1 then
             boxid = box[boxid]
        elseif boxid <= 200 and boxid >16  then
            boxid = box[rand(1,16)]
        elseif boxid <= 220 and boxid > 200 then
            boxid = box1[boxid%200]
        else 
            boxid = rand(1,36)
        end
    end

    x = boxid%6
    x = (x == 0 and 6 or x) * 100
    y =  math.ceil(boxid/6) * 100

    local xmin=x-99
    local ymin=y-99

    x = rand(xmin,x)
    y = rand(ymin,y)     

    local x1 = x - 5
    local x2 = x + 5
    local y1 = y - 5
    local y2 = y + 5

    if x1 < xmin then x1 = xmin end
    if y1 < ymin then y1 = ymin end
    if x2 > x then x2 = x end
    if y2 > y then y2 =y   end

    if x1 < 5 then x1 = 5 end
    if y1 < 5 then y1 = 5 end
    if x2 > 595 then x2 = 595 end
    if y2 > 595 then y2 = 595 end

    local db = getDbo()
    local sql = "select id,x,y,type from map where type=0 and x>:x1 and x<:x2 and y>:y1 and y<:y2"
    local result = db:getAllRows(sql,{x1=x1,y1=y1,x2=x2,y2=y2})

    if not result or #result < 1 then
        return getMapPos(uid,name,isSetSeed,level,power,rank,alliance,protect,pic,allianceLogo)
    else
        for i=1,#result do
            local k = rand(1,#result)
            local pos = result[k]

            if commonLock(tostring(pos.id),"maplock") then
                level = level or 1
                power = power or 0
                rank = rank or 1
                alliance = alliance or 0
                protect = protect or 0
                pic = pic or 0

                local ret = db:update('map',{name=name,oid=uid,type=6,level=level,power=power,rank=rank,alliance=alliance,protect=protect,pic=pic,allianceLogo=allianceLogo},"id="..pos.id.." and type=0")

                commonUnlock(tostring(pos.id),"maplock")
                
                if ret and ret > 0 then
                    return pos
                end  
            else
                table.remove(result,k)
            end
        end    
    end
end

-- fc 当前正确值 fc1 修正时正常值 fc2 修正时异常值
function getRealFighting(fc,fc1,fc2)
    -- 返回正常值
    if fc1 <= 0 or fc2 <= 0 or fc1 == fc2 then
        return fc
    end

    -- 不在三角形范围内,正常值
    if fc >= (2 * fc1) then
        return fc
    end

    -- 按照等比三角形取映射值
    if fc < fc1 then -- 战力下降映射
        return math.floor(fc2 * fc / fc1)
    elseif fc >= fc1 then -- 战力上升映射
        return fc2 + math.floor( (fc-fc1) * (2*fc1-fc2) / fc1 ) 
    end

    -- 公式： 2*fc1 - math.floor((2*fc1-fc) * (2*fc1-fc2) / fc1)

    -- if fc <= fc2 then
    --     return fc * (fc1/fc2)
    -- end 

    -- if (fc > fc2) and (fc < fc2 * 2) then
    --     return fc1 + (2 * fc2-fc1) * (fc - fc2) / fc2
    -- end

    -- h1  =  修正时刻 ----- 错误的虚高值
    -- h2 =   修正时刻 ----- 正常的真长值
    -- hnow = 当前时刻的 战斗值
    -- hshow = 当前时刻的  显示战斗值
    -- 当h1 < h2 时， 直接让 h1 = h2 并且之后不需要修正 
    -- 当 hnow >= 2 * h2 时  （完全进入正常状态）
    -- hshow = hnow
    -- 当 hnow <= h2 时
    -- hshow = hnow * （h1 / h2 ） 
    -- 当 h2 < hnow <h2 * 2 时
    -- hshow = h1 + （2 *  h2 - h1 ) * (hnow - h2 ) / h2
end

function refreshFighting(uid,troopsInfo,oldEquip)
    local tankCfg = getConfig('tank')
    local techCfg = getConfig('tech')
    local skillCfg = getConfig('skill.skillList')    
    local challengeBuffCfg  -- 军团关卡奖励的BUFF配置 
    local rankCfg = getConfig('rankCfg')

    local uobjs = getUserObjs(uid)
    local mUserinfo = uobjs.getModel('userinfo')
    local mTroop = uobjs.getModel('troops')
    local mTech = uobjs.getModel('techs')
    local mSkill = uobjs.getModel('skills')
    local mAccessory = uobjs.getModel('accessory')
    local mChallenge = uobjs.getModel('challenge')
    local mHero = uobjs.getModel('hero')
    local mAlien = uobjs.getModel('alien')
    local mSequip = uobjs.getModel('sequip')
    local mAweapon = uobjs.getModel('alienweapon')
    local mArmor  = uobjs.getModel('armor')
    local mPlane  = uobjs.getModel('plane')
    local mStatue  = uobjs.getModel('statue')
    local mBadge  = uobjs.getModel('badge') -- 指挥官徽章

    -- 指挥官徽章加成
    local badgeAdd,badgeRate = mBadge.getUsedFighting()

    local troopadd = 0
    if oldEquip then
        troopadd =  mSequip.sequipAttr(mSequip.maxstrong(),  true)
    else
        troopadd = mSequip.maxstrong()
    end
    

    local pairs = pairs
    local totalFighting = 0    
    local teamNum = 6
    local planeValue=mPlane.getMaxBattlePlane()
    local troops = troopsInfo or mTroop.formatTotalTroopsByType()
    local techs = mTech.toArray(true)
    local skills = mSkill.toArray(true)
    local maxNumByTeam = mTroop.getMaxBattleTroops( troopadd )
    
    local accessoryAttribute = mAccessory.getUsedAccessoryAttribute() --装备
    local challengeBuff = mChallenge.getChallengeBuff()   -- 关卡buff
    local rankAttribute = rankCfg.rank[mUserinfo.rank].attAdd   -- 军衔加成
    local acc2TankType = {t1=1,t2=2,t3=4,t4=8}
    local attribute2Code = getConfig("common.attributeStrForCode")

    local allianceSkills
    local allianceSkillCfg
    local allianceTerritoryBuff
    -- 军团技能
    if mUserinfo.alliance and mUserinfo.alliance > 0 then
        local allAllianceSkills = M_alliance.getAllianceSkills{aid=mUserinfo.alliance}
        if type(allAllianceSkills) == 'table' then
            if allAllianceSkills.s11 or allAllianceSkills.s12 or allAllianceSkills.s13 or allAllianceSkills.s14 then
                allianceSkills = {}
                allianceSkills.s11 = allAllianceSkills.s11
                allianceSkills.s12 = allAllianceSkills.s12
                allianceSkills.s13 = allAllianceSkills.s13
                allianceSkills.s14 = allAllianceSkills.s14
                allianceSkillCfg = getConfig("allianceSkillCfg")
            end
        end

        -- 领地信息
        local mTerritory = getModelObjs("aterritory",mUserinfo.alliance,true)
        allianceTerritoryBuff = mTerritory.getTerritoryBuildBuff()
    end
    
    if type(troops) ~= 'table' then
        return 
    end

    local getFightingByAid = function (aid) 
        local fighting=tankCfg[aid].Fighting
        local per = {}
        local tankType = tankCfg[aid].type

        for sid,skillLevel in pairs(skills) do
            if sid ~= 'queue' and skillLevel > 0 and table.contains(skillCfg[sid].skillBaseType,tankType) then
                local attributeType = tonumber(skillCfg[sid].attributeType) or 0
                -- 新技能算法
                if skillCfg[sid].skillValue~=nil  and attributeType>0 then
                    if attributeType == 201 or attributeType == 202 then                        
                        per[attributeType] = (per[attributeType] or 1) +  (skillCfg[sid].skillValue*skillLevel)/200
                    elseif attributeType == 301 then
                        per[attributeType] = (per[attributeType] or 1) +  (skillCfg[sid].skillValue*skillLevel)/10
                    else
                        per[attributeType] = (per[attributeType] or 1) +  (skillCfg[sid].skillValue*skillLevel)/4
                    end
                end
            end
        end
        
        -- 军团技能加成
        if type(allianceSkills) == 'table' and next(allianceSkills) then
            for sid,skillLevel in pairs(allianceSkills) do                
                skillLevel = tonumber(skillLevel)
                if skillLevel > 0 and table.contains(allianceSkillCfg[sid].skillBaseType,tankType) then
                    local attributeType = tonumber(allianceSkillCfg[sid].attributeType)      
                    per[attributeType] = (per[attributeType] or 1) +  (allianceSkillCfg[sid].value[skillLevel])/400
                end
            end
        end

        for tid,techLevel in pairs(techs) do
            if tid ~= 'queue' and techCfg[tid].baseType == tankType then  
                local attributeType = tonumber(techCfg[tid].attributeType)
                per[attributeType] = (per[attributeType] or 1) +  (techCfg[tid].value[techLevel]/400)                
            end
        end

        -- 装备加成
        for accType,accessoryInfo in pairs(accessoryAttribute or {}) do
            if acc2TankType[accType] == tankType then         
                for attribute,value in pairs(accessoryInfo) do                    
                    if attribute2Code[attribute] == 201 or attribute2Code[attribute] == 202 then                        
                        per[attribute2Code[attribute]] = (per[attribute2Code[attribute]] or 1) + (value/200)
                    else
                        per[attribute2Code[attribute]] = (per[attribute2Code[attribute]] or 1) + (value/4)   
                    end
                end
            end
        end

        -- 军衔加成
        if rankAttribute then
            if rankAttribute[1] > 0 then
                per[100] = (per[100] or 1) + (rankAttribute[1]/4)
            end

            if rankAttribute[2] > 0 then
                per[108] = (per[108] or 1) + (rankAttribute[2]/4)
            end
        end
        
        -- 关卡buff加成
        for k,v in pairs(challengeBuff or {}) do 
            challengeBuffCfg = challengeBuffCfg or getConfig("challengeTech")
            local attributeType = challengeBuffCfg[k].attributeType     
            if attributeType then
                per[attributeType] = (per[attributeType] or 1) +  (challengeBuffCfg[k].value[v])/4
            end
        end

        -- 异星科技加成
        local alienTechs, alienTechs1 = mAlien.getAttrValueByTank(aid)
        for k,v in pairs(alienTechs or {}) do
            -- 技能
            if type(k) == 'string' and #k == 1 then
                local alienAbility = 'alien_'..k
                per[alienAbility] = (per[alienAbility] or 1) + 0.2
            -- 暴击伤害和暴击伤害减少
            elseif k == 110 or k == 111 then
                per[k] = (per[k] or 1) + v/5
            -- 加攻
            elseif k == 100 then
                per[k] = (per[k] or 1) + v/tankCfg[aid].attack/4
            -- 加血
            elseif k == 108 then
                per[k] = (per[k] or 1) + v/tankCfg[aid].life/4
            -- 其它
            elseif k~= 200 then
                per[k] = (per[k] or 1) + v/400
            end
        end

        -- 新加科技树属性
        for k,v in pairs(alienTechs1 or {}) do
            -- 技能
            if type(k) == 'string' and #k == 1 then
                local alienAbility = 'alien_'..k
                per[alienAbility] = (per[alienAbility] or 1) + 0.2
            -- 暴击伤害和暴击伤害减少
            elseif k == 110 or k == 111 then
                per[k] = (per[k] or 1) + v/5
            -- 加攻
            elseif k == 100 then
                per[k] = (per[k] or 1) + v/tankCfg[aid].attack/4
            -- 加血
            elseif k == 108 then
                per[k] = (per[k] or 1) + v/tankCfg[aid].life/4
            -- 其它
            elseif k~= 200 then
                per[k] = (per[k] or 1) + v/400
            end
        end

        --超级装备加成
        local equipcodeAttr = mSequip.getFightAttr()

   

        if oldEquip then
            for k, v in pairs(equipcodeAttr) do
                if k == 110 or k == 111 then
                    v = v/5
                elseif k == 100 or v == 108 then
                    v = v/4
                end

                per[k] = (per[k] or 1) + v
            end
        else
            for k, v in pairs(equipcodeAttr) do
                if k == 110 or k == 111 then
                    v = v/5
                elseif k == 100 or k == 108 or k == 102 or k ==103 or k == 104 or k == 105 or k == 106 or k == 107 then
                    -- 如果是  生命 和 攻击 ， 命中，闪避，暴击，免暴 这六种属性 则 /4
                    v = v/4
                elseif k == 201 or k == 202   then
                    -- 如果是  击破 防护 ，  则 /200
                    v = v/200                
                end

                per[k] = (per[k] or 1) + v
            end
        end

        -- 军团领地BUFF加成
        if allianceTerritoryBuff then
            for k,v in pairs(allianceTerritoryBuff) do
                k = attribute2Code[k]
                if  k == 100 or k == 108 or k == 102 or k ==103 then
                    per[k] = (per[k] or 1) + v/4
                end
            end 
        end

        -- 战争雕像加成
        local statueAttr = mStatue.getSkillAttrs()
        if statueAttr then
            local addAttr = {}
            if statueAttr.skill then
                for attr,value in pairs(statueAttr.skill) do
                    if attribute2Code[attr] then
                        local attrkey = attribute2Code[attr]
                        -- 如果是击破 防护，则 /200
                        if attrkey == 201 or attrkey == 202 then
                            addAttr[attrkey] = (addAttr[attrkey] or 0) + value / 200
                        -- 暴击伤害和暴击伤害减少
                        elseif attrkey == 110 or attrkey == 111 then
                            addAttr[attrkey] = (addAttr[attrkey] or 0) + value / 5
                        else
                            addAttr[attrkey] = (addAttr[attrkey] or 0) + value / 4
                        end
                    end
                    
                end
            end
            if statueAttr.special then
                for attr,value in pairs(statueAttr.special) do
                    if attr == "dmg_reduce" or attr == "dmg" then
                        local attrkey
                        if attr == "dmg_reduce" then
                            attrkey = 109
                        else
                            attrkey = attribute2Code[attr]
                        end
                        if attrkey then
                            addAttr[attrkey] = (addAttr[attrkey] or 0) + value / 2
                        end
                    end
                end
            end

            for k,v in pairs(addAttr) do
                per[k] = (per[k] or 1) + v
            end
        end

        -- 指挥官徽章加成
        if type(badgeAdd)=='table' and next(badgeAdd) then
            for k,v in pairs(badgeAdd) do
                if k == 110 or k == 111 then
                    v = v/5
                elseif k == 100 or k == 108 or k == 102 or k ==103 or k == 104 or k == 105 or k == 106 or k == 107 then
                    -- 如果是  生命 和 攻击 ， 命中，闪避，暴击，免暴 这六种属性 则 /4
                    v = v/4
                elseif k == 201 or k == 202   then
                    -- 如果是  击破 防护 ，  则 /200
                    v = v/200                
                end
                per[k] = (per[k] or 1) + v
            end
        end

        local tPer = 1
        for k,v in pairs(per) do
            tPer = tPer * v
        end

        return fighting*tPer
    end

    local troopsFightingInfo = {}    

    for aid,anum in pairs(troops) do
        if anum > 0 then
            troopsFightingInfo[aid] = {}

            local currNum = 0
            for i=1,teamNum do
                currNum = anum - maxNumByTeam
                if currNum >= 0 then
                    table.insert(troopsFightingInfo[aid],maxNumByTeam)
                    anum = currNum
                elseif anum > 0 then
                    table.insert(troopsFightingInfo[aid],anum)
                    break
                else 
                    break
                end
            end
        end
    end

    local allFightings = {}
    local tmpAidFighting = {}
    for aid,teamInfo in pairs(troopsFightingInfo) do
        if not tmpAidFighting[aid] then 
            tmpAidFighting[aid] = getFightingByAid(aid) 
        end

        local fighting = tmpAidFighting[aid] 

        if type(teamInfo) == "table" then
            for k,v in pairs(teamInfo) do  
                table.insert(allFightings,math.pow(v,0.7)*fighting)
            end
        end
    end

    table.sort(allFightings,function(a,b)return (a> b) end)

    local heroPower ={}
    heroPower=mHero.getAllHeroPower()
    table.sort(heroPower,function(a,b)return (a> b) end)

    local awPower = mAweapon.getWeaponFight()
    --装甲战斗力加成
    local armorPower=mArmor.getUsedArmorFighting()
    local tenderPower = uobjs.getModel('tender').getBuildingStrength()  -- 补给舰数据

    for k,v in ipairs(allFightings) do
        v = v * (1 + (heroPower[k] or 0)/2000) * (1 + (awPower[k] or 0)/2000) * (1 + tenderPower/2000)

         -- 装甲加成
        if armorPower[k]~=nil and armorPower[k]>0 then
            v = v + v*armorPower[k]/2000
        end

        -- 飞机加成
        if planeValue>0 then
            v = v + v*planeValue/28000
        end

        totalFighting = totalFighting + v

        if k >= teamNum then break end
    end
    
    totalFighting = math.floor(totalFighting)
    -- 指挥官徽章增加战力系数
    if badgeRate>0 then
        totalFighting = math.floor(totalFighting * (1+badgeRate)) 
    end
           
    -- 修复超级装备bug导致的战力问题(首次更新时刷新玩家战力值)
    if not oldEquip and not mUserinfo.flags.fc1 and not troopsInfo then
        mUserinfo.flags.fc1 = totalFighting --修正时正确战力值
        mUserinfo.flags.fc2 = refreshFighting(uid,nil,true) -- 修正是异常战力值
    end

    if not oldEquip and not troopsInfo then
        totalFighting = getRealFighting(totalFighting,mUserinfo.flags.fc1,mUserinfo.flags.fc2)
    end

    if not troopsInfo and not oldEquip and mUserinfo.fc ~= totalFighting then
        mUserinfo.fc = totalFighting 
    end

    return totalFighting
end

-- 资源返还的比率 返还值=升级完成剩余时间 / 总时间*升级所需资源   
-- st 起始时间
-- et 结束时间
function getResRate4Cancel(st,et)    
    st = tonumber(st) or 0 
    et = tonumber(et) or 0    
    
    -- et 为0的时候表示队列还未开始，将资源全部返还
    if et == 0 then return 1 end

    local ts = getClientTs()
    local totalTime = et - st
    local surplusTime = et - ts

    local rate = 0
    if surplusTime > 0 and totalTime > 0 and surplusTime <= totalTime then 
        rate = surplusTime / totalTime
    end

    return rate
end

-- 按code返回msg
function getMsgByCode(code)
    code = code or -1
    local codeCfg = getConfig('code')
    return codeCfg[code] or codeCfg[-1]
end

-- 创建验证串
-- return string
function createAccessToken(uid,loginTs,newSecretkey)
    uid = uid or 0
    local isSet = false
    if not loginTs then
        loginTs = getClientTs()
        isSet = true
    end

    local secretkey = getConfig("base.SECRETKEY")   
    if newSecretkey then 
        secretkey = getConfig("base.SECRETKEYNEW") 
        if not secretkey then return {'token invalid'} end
    end

    local baseString = uid .. "_" .. secretkey .. "_" .. loginTs .. "_" ..getZoneId()
    local sha1 = require "lib.sha1"
    local base64 = require "lib.base64"

    local token = sha1(baseString)
    token = base64.Encrypt(token)

    local redis = getRedis()
    local key = "z"..getZoneId()..".login."..uid
    
    if isSet then redis:set(key,loginTs) end
    redis:expire(key,432000)

    return token, loginTs
end

-- 检测验证串
-- return boolen
function checkAccessToken(uid,loginTs,token)
    uid = uid or 1
    local code = -124    
    
    if token == (createAccessToken(uid,loginTs)) then        
        local redis = getRedis()
        local key = "z"..getZoneId()..".login."..uid

        local ret = tonumber(redis:get(key)) or 0

        if loginTs > 0 and loginTs == ret then
            redis:expire(key,432000)
            return true
        elseif ret == -133 then
            code = -133
        else
            code = -125
        end        
    end

    return false, code
end

function requestCheck(request)
    -- if request.cmd ~= 'user.login' and request.cmd ~= 'user.sigup' and request.cmd ~= 'user.pwdupdate' and request.cmd ~= 'user.check' then
    --     if string.find(request.cmd,'admin') or (request.cmd == 'cron.attack' and request.params.usegem ~=1) then
    --         local secretkey = getConfig("base.SECRETKEY")
    --         if request.secret ~= secretkey then
    --             return false, -124
    --         end
    --     else
    --         return checkAccessToken(request.uid,request.logints,request.access_token)                
    --     end
    -- end
    if request.cmd == 'user.check' then
        if request.access_token == (createAccessToken(request.uid,request.logints)) or request.access_token == (createAccessToken(request.uid,request.logints,true)) then 
            return true 
        end

        return false, -124 
    end

    local noCheck = {
        ["acrossserver"]=true,
        ["areateamwarserver"]=true,
        ["skyladderserver"]=true,
        ["admin.accountsbattle"]=true,
    }

    -- all 表示直接验证secret
    -- secret 表示只有request.secret有值的时候(后端自己的或支付平台的请求)，才验证secret
    local checkSecretkey = {
        ["admin"]="all",
        ["crossserver"]="all",
        ["worldserver"]="all",
        ["cross.winmail"]="secret",
        ["cross.finalist"]="secret",
        ["cron.attack"]="secret",
        ["alienmine.backall"]="secret",
        ["alliance.sendbattlemsg"]="secret",
        ["areawar.sendbattlemsg"]="secret",
        ["alliancewar.getwarpoint"]="secret",
        ["user.processorder"]="all",
        ["pay.processorder"]="all",
        ["military.update"]="all",
        ["dailyactive.meiridati"]="secret",
        ["active.calls"]="secret",
        ["cron.refnewrank"]="secret",
        ["pay.addprops"]="secret",
        ["pay.addplatprops"]="secret",
        ["across.finalist"]="secret",
        ["giftbag.get"]="secret",
        ["worldserver.setuser"]="secret",
        ["areawar.battle"]="secret",
        ["admin.addrewards"]="secret",
        ["rewardcenter.loopcheck"]="secret",
        ["rewardcenter.delexpirereward"]="secret",
        ["alliancewarnew.sendbattlemsg"]="secret",
        ["alliancewarnew.getwarpoint"]="secret",
        ["userwar.initbattle"]="secret",
        ["userwar.battle"]="secret",
        ["userwar.endbattle"]="secret",
        ["military.rankreward"]="secret",
        ["map.goldmine"]="secret",
        ["troop.arrivebase"]="secret",
		["troop.back"]="secret",
        ["alliancerebel.killreward"]="secret",
		["map.refreshrebel"]="secret",
		["alliance.help"]="secret",
        ["hero.annealclean"]="secret",
        ["dailynews.news.process"]="secret",
        ["user.checkpic"]="secret",
        ["killrace.season.reset"]="secret",
        ["areateamwarserver"]="all",
        ["admin.accountsbattle"]="secret",
        ['admin.checkserverstats']="secret",
        ['admin.getworldwarinfo']="secret",
        ['admin.getworldwarrank']="secret",
        ['troop.msgpush.invade']="secret",
        ['alienweapon.back']="secret",
        ['cron.refmilitaryrank']="secret",
        ['territory.ckbqueue']="secret",
        ['territory.set.fleetBack']="secret",
        ['territory.set.maintain']="secret",
        ['territory.seawar.decrDura']="secret",
        ['territory.seawar.warOver']="secret",
        ['territory.seawar.applyMapNameCheck']="secret",
        ['territory.seawar.attack']="secret",
        ['fleetgo.cron']="secret",
        ['cron.acgift']="secret",
        ['boss.battle']="secret",
        ['boss.reward']="secret",
        ['boss.book.rankingList']="secret",
        ['boss.book.getQueue']="secret",
        ['cron.checkchat']="secret",
        ['active.wcguess.sendmail']="secret",
        ['cron.oceanexpedition']="secret",---远洋征战报名结算脚本
        ['cron.oceanexcheck']="secret",---远洋征战报名结算验证脚本
        ['cron.oceanexfcrank']="secret",--远洋征战生成战力快照脚本
    }

    local cmdArray = string.split(request.cmd,"%.")

    if noCheck[cmdArray[1]] or noCheck[request.cmd] then
        return true
    end

    if checkSecretkey[cmdArray[1]] == "all" or checkSecretkey[request.cmd] == "all" or (checkSecretkey[request.cmd] == 'secret' and request.secret) then
        local baseCfg = getConfig("base")
        if request.secret ~= baseCfg.SECRETKEY then
            if baseCfg.SECRETKEYNEW then
                if request.secret ~= baseCfg.SECRETKEYNEW then
                    return false, -124
                end
            else
                return false, -124
            end
        end
        request._REQUESTCHECK = true
    elseif request.cmd == "map.get" then
        if math.abs(request.ts - os.time()) > 30 then
            return false,-1
        end        
        request._REQUESTCHECK = true
        return request.kuangchan == getChatEncrypt2( request.ts,request.uid,request.zoneid),-1
    else
        if #cmdArray <= 2 then
            request._REQUESTCHECK = true
            return checkAccessToken(request.uid,request.logints,request.access_token) 
        end
    end

    return true
end

function versionCheck(clientVersion,appid)
    clientVersion = clientVersion or 0    
    appid = tonumber(appid)

    local serverVersion
    local baseCfg = getConfig('base')

    if baseCfg.closeServers then
        if baseCfg.closeServers.all or baseCfg.closeServers[getZoneId()] then
            return false,-132
        end 
    end

    if appid and type(baseCfg.CLIENT_MAIN_VERSIONS) == 'table' and baseCfg.CLIENT_MAIN_VERSIONS[appid] then
        serverVersion = baseCfg.CLIENT_MAIN_VERSIONS[appid]
    else
        serverVersion = baseCfg.CLIENT_MAIN_VERSION
    end
    
    if clientVersion < serverVersion then        
        return false,-129
    end
    return true
end

-- 晚上12点的时间戳
function getWeeTs(now)    
    local zone = getConfig('base.TIMEZONE') or 0
    now = now or os.time()
    local ts = now-((now+zone*3600)%86400)
    
    return ts
end

function getDateByTimeZone(now,format)
    local zone = getConfig('base.TIMEZONE') or 0
    local isdst = getConfig('base.ISDST')

    now = now or os.time()
    local gtcnow = os.date("!*t", now)
    gtcnow.isdst=os.date("*t",now).isdst  -- 不用自动调整时区改成手动调整   

    local gtc = os.time(gtcnow)    
    local loc = gtc + zone * 3600

    format = format or '%Y%m%d' 
    return os.date(format,loc)
end

-- 注册需要在保存前处理的事件
-- e1为刷新战斗力
function regEventBeforeSave(uid,eventKey,eventData)
    if type (_EVENTS.eventsBeforeSave[uid] ) ~= 'table' then
        _EVENTS.eventsBeforeSave[uid] = {}
    end

    _EVENTS.eventsBeforeSave[uid][eventKey] = eventData or 1
end

-- 注册需要在保存成功后处理的事件
function regEventAfterSave(uid,eventKey,eventData)  
    local uid = tonumber(uid)

    if type (_EVENTS.eventsAfterSave[uid] ) ~= 'table' then
        _EVENTS.eventsAfterSave[uid] = {}
    end
    
    _EVENTS.eventsAfterSave[uid][eventKey] = eventData or 1

end

-- 注册需要在保存成功后处理的多个事件
function regEventsAfterSave(uid,eventKey,eventData)
     if type (_EVENTS.eventsAfterSave[uid] ) ~= 'table' then
        _EVENTS.eventsAfterSave[uid] = {}
    end
    
    if not _EVENTS.eventsAfterSave[uid][eventKey] then 
        _EVENTS.eventsAfterSave[uid][eventKey] = {}
    end

    table.insert(_EVENTS.eventsAfterSave[uid][eventKey],eventData)
end

-- 处理需要在保存前处理的事件
function processEventsBeforeSave()    
    for uid,event in pairs(_EVENTS.eventsBeforeSave) do
        if type(event) == 'table' then
            for eventKey,eventData in pairs(event) do
                local uobjs = getUserObjs(uid)
                local mUserinfo = uobjs.getModel('userinfo')

                if eventKey == 'e1' and mUserinfo.tutorial == 10 then
                   local fc = refreshFighting(uid)     

                    if fc and fc >= 0  then                        
                        regEventAfterSave(uid,'e1',{fc=fc})
                    end
                end

                -- 新手引导 新手引导最后一步有可能超时，客户端多次发送请求，不加判断，会多次分配地图
                if eventKey == 'e3' and mUserinfo.tutorial < 10 then 
                    mUserinfo.tutorial = eventData[1] or mUserinfo.tutorial                    
                end --e3 end

                -- 为3级并且没有分配地图坐标的用户分配地图
                if eventKey == 'e4' then
                    local uobjs = getUserObjs(uid)
                    local mUserinfo = uobjs.getModel('userinfo')

                    if mUserinfo.level >= 3 and (mUserinfo.mapx == -1 or mUserinfo.mapy == -1) then
                        -- 合服后，等级大于等于5的，保护时间为6小时
                        local ts = getClientTs() 
                        local ptime = mUserinfo.level >= 5 and 21600 or 21600
                        local protect = ts + ptime

                        local setProp = true
                        if (tonumber(mUserinfo.protect) or 0) > protect then
                            protect = tonumber(mUserinfo.protect)
                            setProp = false
                        end

                        local mMap = require "lib.map"
                        local mapData = mMap:getUserMap(uid)
                        if mapData then
                            if mapData.level ~= mUserinfo.level or mapData.name ~= mUserinfo.nickname or mapData.power ~= mUserinfo.fc or mapData.pic ~= mUserinfo.pic or mapData.rank ~= mUserinfo.rank or tonumber(mapData) ~= 0 then
                                mMap:update(mapData.id,{level=mUserinfo.level,name=mUserinfo.nickname,type=6,oid=mUserinfo.uid,power=mUserinfo.fc,rank=mUserinfo.rank,alliance=0,protect=protect,pic=mUserinfo.pic})      
                            end                  
                        else
                            mapData = getMapPos(uid,mUserinfo.nickname,false,mUserinfo.level,mUserinfo.fc,mUserinfo.rank,'',protect,mUserinfo.pic) 
                        end

                        if type(mapData) ~= 'table' then
                            tankError('getMapPos failed'.. (mapData and tostring(mapData) or ''))
                        end

                        mUserinfo.mapx = mapData.x
                        mUserinfo.mapy = mapData.y
                        mUserinfo.protect = protect

                        if setProp then
                            local mProp = uobjs.getModel('props')
                            local bSlotInfo = {} 
                            bSlotInfo.st = ts
                            bSlotInfo.et = protect
                            bSlotInfo.id = 'p14'
                            mProp.usePropSlot(bSlotInfo.id,bSlotInfo)
                        end

                        local mChallenge = uobjs.getModel('challenge')

                        setChallengeRanking(uid,mChallenge.star,mChallenge.star_at)
                        setHonorsRanking(uid,mUserinfo.reputation)
                        setFcRanking(uid,mUserinfo.fc)
                    end
                end

            end
        end
    end
end

-- 处理需要在保存成功后处理的事件
function processEventsAfterSave()      
    for uid,event in pairs(_EVENTS.eventsAfterSave) do
        
        if type(event) == 'table' then
            for eventKey,eventData in pairs(event) do

                -- 刷新战斗力
                if eventKey == 'e1' then

                    local uobjs = getUserObjs(uid)
                    local mUserinfo = uobjs.getModel('userinfo')

                    if mUserinfo.level >= 3 then
                        local data = {power=eventData.fc,rank=mUserinfo.rank,alliance=mUserinfo.alliancename}

                        if mUserinfo.alliance and  (tonumber(mUserinfo.alliance) or 0) > 0 then
                            M_alliance.updateFight{uid=uid,fight=eventData.fc}
                        end
                        
                        if (tonumber(mUserinfo.mapx) or 0) > 0 and (tonumber(mUserinfo.mapy) or 0) > 0 then
                            local mid = tonumber(getMidByPos(mUserinfo.mapx,mUserinfo.mapy))
                            if mid and mid >= 0  then
                                local mMap = require "lib.map"
                                mMap:update(mid,data)
                            end
                        end
                        
                        setFcRanking(uid,(mUserinfo.fc or 0))

                        -- push 
                        local pushCmd = 'userfc.change.push'
                        local pushData = {
                            fc=mUserinfo.fc,
                        }
                        
                        regSendMsg(uid,pushCmd,pushData)

                    end

                end

                -- 刷新关卡排行
                if eventKey == 'e2' then
                    local uobjs = getUserObjs(uid)
                    local mUserinfo = uobjs.getModel('userinfo')

                    if mUserinfo.level >= 3 then
                        setChallengeRanking(uid,eventData.star,eventData.star_at)   
                    end
                end
                
                -- 修改军团中的等级
                if eventKey == 'e4' then
                    M_alliance.editMember{uid=uid,aid=eventData.aid,level=eventData.level,name=eventData.name,logined_at=eventData.logined_at}
                end

                -- 设置军团事件
                if eventKey == 'e5' then                    
                    M_alliance.setEvents({uid=uid,data=json.encode{10,getClientTs(),eventData.defener,eventData.attacker,eventData.resource,eventData.allianceName}})
                end

                -- 推送事件消息
                if eventKey == 'e6' then
                    local response = {data={event={f=1}},cmd="msg.event"}                
                    sendMsgByUid(uid,json.encode(response))
                end

                if eventKey == 'e7' then
                    setLevelRanking(uid,(eventData.level or 0))
                end

                 -- 刷新地图
                if eventKey == 'e8' then
                    local uobjs = getUserObjs(uid)
                    local mUserinfo = uobjs.getModel('userinfo')
                    local mBoom = uobjs.getModel('boom')
                    if tonumber(mUserinfo.level) >= 3 and tonumber(mUserinfo.mapx) > 0 and tonumber(mUserinfo.mapy) > 0 then
                        local data = {
                            power=mUserinfo.fc,
                            rank=mUserinfo.rank,
                            alliance=mUserinfo.alliancename,
                            protect=mUserinfo.protect,
                            name=mUserinfo.nickname,
                            boom=mBoom.boom,
                            boom_max = mBoom.boom_max,
                            boom_ts = mBoom.boom_ts,
                        }

                            local mid = tonumber(getMidByPos(mUserinfo.mapx,mUserinfo.mapy))
                            if mid and mid >= 0  then
                                local mMap = require "lib.map"
                                mMap:update(mid,data)
                            end
                        end
                    end

                -- 设置异星矿场地图采集积分
                if eventKey == 'e9' then
                    local mCount = 0
                    local alliance = 0
                    local point = 0

                    for _,n in pairs(eventData) do
                        if type(n) == 'table' then
                            for k,v in pairs(n) do
                                mCount = tonumber(v.mCount) or 0
                                alliance = v.alliance
                                point = point + (tonumber(v.point) or 0)

                                local fleetInfo = v.fleetInfo
                                local content={
                                    type=3,
                                    resource = {
                                        alienRes={u={fleetInfo.res,},}, --采集的钛矿资源
                                    },
                                    info={
                                        place=fleetInfo.targetid,--坐标
                                        rettype=1,--类型，1自己返回，2被攻击返回
                                        islandType=fleetInfo.type,--矿类型
                                        level=fleetInfo.level,--矿等级
                                        -- loadNum=800,--部队载重
                                        alienPoint=v.point,--个人异星积分
                                        -- aAlienPoint=20,--军团异星积分
                                    },
                                }
                                
                                -- 被驱赶回家的邮件
                                if fleetInfo.expel == 1 then
                                    content.info.rettype = 2
                                end

                                if v.alliance > 0 then
                                    content.info.aAlienPoint = v.point
                                end
                                
                                local mailTitle = '3-'..fleetInfo.type

                                -- mailSent(uid,sender,receiver,mail_from,mail_to,subject,content,mail_type,isRead)
                                MAIL:mailSent(uid,1,uid,'','',mailTitle,content,4,0) 
                            end
                        end
                    end

                    setAlienRanking(uid,mCount,alliance,point)
                end

                -- 更新军团领地数据
                if eventKey=='e10' then
                    local mAterritory = getModelObjs("aterritory",eventData.aid,false,true)
                    if mAterritory then
                        mAterritory.saveData()
                    end
                end

                if eventKey == "arrivebase" then
                    for _,edata in pairs(eventData) do
                        if type(edata.func) == "function" then
                            edata.func(uid,edata.params.info,edata.params.boom,edata.params.nickname,edata.params.collectAlienRes)
                        end
                    end
                elseif eventKey == "saveAllianceActive" then
                    local mAllianceActive = getModelObjs("allianceactive",uid,false,true)
                    if mAllianceActive then
                        mAllianceActive.saveData()
                    end
                end                

            end
        end
    end

    -- 保存成功后处理统计
    processStats()  
end

-- table award
function takeReward(uid,award)
    local ret = true
    local rRecord = {} -- 奖励记录数据

    local uobjs = getUserObjs(uid)
    if uobjs and type(award) == 'table' then
        local model,tmpReward
        for reward,num in pairs(award) do
            reward = reward:split('_') 
            if type(reward) == 'table' then
                if reward[1] == 'props' then
                    model = uobjs.getModel('bag')
                    ret = model.add(reward[2],num)
                elseif reward[1] == 'troops' then
                    model = uobjs.getModel('troops')
                    ret = model.incrTanks(reward[2],num)
                elseif reward[1] == 'accessory' then
                    model = uobjs.getModel('accessory')
                    ret, tmpReward = model.addAllResource(reward[2],num)                    
                    retR = table.length(tmpReward) ~= 0 and true or false

                    if retR then
                        for k,v in pairs(tmpReward) do
                            if type(v) == "table" then
                                if not rRecord[reward[1]] then rRecord[reward[1]] = {} end
                                if not rRecord[reward[1]][k] then rRecord[reward[1]][k] = {} end

                                for rk,rv in pairs(v) do
                                    if type(rv) == 'number' then
                                        rRecord[reward[1]][k][rk] = (rRecord[reward[1]][k][rk] or 0) + rv
                                    else
                                        rRecord[reward[1]][k][rk] = rv
                                    end                           
                                end
                            end
                        end                        
                    end
                elseif reward[1] == 'armor' then
                    model = uobjs.getModel('armor')
                    ret,tmpReward = model.addAllResource(reward[2],num)                    
                    retR = table.length(tmpReward) ~= 0 and true or false

                    if retR then
                        for k,v in pairs(tmpReward) do
                            if type(v) == "table" then
                                if not rRecord[reward[1]] then rRecord[reward[1]] = {} end
                                if not rRecord[reward[1]][k] then rRecord[reward[1]][k] = {} end

                                for rk,rv in pairs(v) do
                                    if type(rv) == 'number' then
                                        rRecord[reward[1]][k][rk] = (rRecord[reward[1]][k][rk] or 0) + rv
                                    else
                                        rRecord[reward[1]][k][rk] = rv
                                    end                           
                                end
                            end
                        end                        
                    end
                elseif reward[1] == 'hero' then
                    model = uobjs.getModel('hero')
                    --新格式加多个将领的
                    if #reward>=3 then
                        ret = model.addMoreHero(reward[2],tonumber(reward[3]),num)
                    else
                        -- 加单个的奖励
                        ret = model.addHeroResource(reward[2],num)    
                    end                  
                elseif reward[1] == 'userinfo' then 
                    model = uobjs.getModel('userinfo')
                    if reward[2] == 'exp' then 
                        ret = model.addExp(num) 
                    elseif reward[2] == 'honors' then 
                        ret = model.addHonor(num)                    
                    else 
                        ret = model.addResource({[reward[2]]=num}) 
                    end
                elseif reward[1] == "alien" then
                    model = uobjs.getModel('alien')
                    ret = model.addMineProp(reward[2], num)
                elseif reward[1] == "userwar" then
                    model = uobjs.getModel('userwar')
                    ret = model.addPointForReward(reward[2], num)
                elseif reward[1] == "sequip" then
                    local itemid = reward[2]
                    if reward[3] then itemid = reward[2] .. "_" .. reward[3] end
                    model = uobjs.getModel('sequip')
                    ret = model.addEquip(itemid, num)
                elseif reward[1] == 'plane' then
                    model = uobjs.getModel('plane')
                    ret = model.addPlaneSkill(reward[2], num)
                elseif reward[1] == "aweapon" then
                    local itemid = reward[2]
                    model = uobjs.getModel('alienweapon')
                    if string.find(itemid, 'aw') then
                        ret = model.addWeapon(itemid)
                    elseif string.find(itemid, 'af') then
                        ret = model.addFragment(itemid, num)
                    elseif string.find(itemid, 'ap') then
                        ret = model.addProp(itemid, num)
                    elseif itemid == "exp" then
                        ret = model.changeExp(num)
                    elseif itemid == "y1" then
                        ret = model.changey1(num)
                    end
                elseif reward[1] == "ajewel" then
                    local itemid = reward[2]
                    model = uobjs.getModel('alienweapon')
                    if string.sub(itemid,1,1) == "j" then-- 加宝石
                        local retflag,adjewel = model.addjewel(itemid,num)
                        if retflag == 0 then
                            ret = true
                            for k,v in pairs(adjewel) do
                                rRecord[reward[1]..'_'..k] = (rRecord[reward[1]..'_'..k] or 0) + v
                            end 
                        end
                    elseif itemid == 'p1' then -- 增加宝石粉尘
                        ret = model.addstive(num)
                    elseif itemid == "p2" then --增加宝石结晶
                        ret = model.addcrystal(num)
                    end
                elseif reward[1] == "badge" then
                    local itemid = reward[2]
                    model = uobjs.getModel('badge')
                    if string.find(itemid, 'mw') then -- 徽章
                        ret = model.add(itemid,num)
                    elseif string.find(itemid, 'mf') then -- 碎片
                        ret = model.addFragment(itemid, num)
                    elseif string.find(itemid, 'mp') then -- 突破道具
                        ret = model.addMaterial(itemid, num)
                    elseif itemid == "exp" then---经验
                        ret = model.addExp(num)
                    elseif string.find(itemid,'xp') then--经验道具
                        ret = model.addExpPro(itemid,num)
                    end
                else
                    model = uobjs.getModel(reward[1])
                    ret = model.addResource(reward[2],num)   
                end

                if not ret then
                    return ret, rRecord
                end 

            end
        end

        return ret, rRecord
    end
end

-- 格式化
function getClientRewardType()
    return {userinfo='u',props='p',accessory='e',hero='h',alien='r',head='a',title='t',weapon='w',equip='f',userarena='m',userexpedition='n', sequip='se', aweapon='aw', armor='am',aterritory='ad',ajewel='aj',plane='pl',tender='ten',badge='badge'}
end

function formatReward(rewards)
    local format = getClientRewardType()
    local formatReward = {}
    if type(rewards) == 'table' then
        for reward,num in pairs(rewards) do
            reward = reward:split('_') 
            local key = format[reward[1]] or 'o'
            if reward[2] then
                if type(formatReward[key])~='table' then
                    formatReward[key]={}
                end

                -- 英雄和军徽额外属性放在了第三位
                if reward[3] then
                    formatReward[key][reward[2]] = reward[3]
                else
                    formatReward[key][reward[2]] = num
                end
            end
        end
    end

    return formatReward
end

function utfstrlen(str)
    str = str or ''
    local len = #str;
    local left = len;
    local cnt = 0;
    local arr={0,0xc0,0xe0,0xf0,0xf8,0xfc};
    while left ~= 0 do
        local tmp=string.byte(str,-left);
        local i=#arr;
        while arr[i] do
            if tmp>=arr[i] then 
                left=left-i;
                break;
            end
                i=i-1;
        end
        if tmp>=192 then
            cnt=cnt+2;
        else
            cnt=cnt+1;
        end
        
    end
    return cnt;
end

function dataCommit()
    -- local db = getDbo()
    -- return db.conn:commit()
end

-- return boolean
function match(str)
    local pattern = "[%'%.,:;*?~`!@#$%%%^&+=)(<{} %]%[/\"]"
    return string.find(str,pattern)
end

function activity_daily(uid)
    local ts = getClientTs()
    local activity_cfg = getConfig('activity')
    
    local uobjs = getUserObjs(uid)
    local mUserinfo = uobjs.getModel('userinfo')
    local mBag = uobjs.getModel('bag')
    
    if not mUserinfo.flags.activity then
        mUserinfo.flags.activity = {}
    end

    for k,v in pairs(activity_cfg) do
        if v.status==1 then
            if v.status==1 and v.begin_ts<=ts and v.end_ts >= ts then
                if v.type==1 then
                    local record = {ts=0,n=0}
                    if mUserinfo.flags.activity[k] then
                        record = mUserinfo.flags.activity[k]
                    end

                    if getWeeTs(ts)>record.ts then
                        record.ts = ts
                        record.n = record.n + 1
                        mUserinfo.flags.activity[k] = record


                        for m,n in pairs(v.reward.props) do
                            mBag.add('p'..n.id,n.num)
                        end

                        if v.reward.gems and v.reward.gems>0 then
                            mUserinfo.gems = mUserinfo.gems + v.gems
                        end
                    end
                end
            end
        elseif v.status==2 and mUserinfo.flags.activity.k then
            mUserinfo.flags.activity.k = nil
        end
    end
end

function activity_exp(uid,exp)
    local ts = getClientTs()
    local activity_cfg = getConfig('activity')
    
    local uobjs = getUserObjs(uid)
    local mUserinfo = uobjs.getModel('userinfo')
    local mBag = uobjs.getModel('bag')
    local zoneId = 'z' .. getZoneId()

    for k,v in pairs(activity_cfg) do
        if v.status==1 then
            if v.status==1 and v.begin_ts<=ts and v.end_ts >= ts then
                if v.type==2 then
                    if type(v.zoneid) == 'table' and v.zoneid[zoneId] == 1 then                        
                        exp = math.ceil(exp * 1.2)
                    end
                end
            end
        end
    end
    return exp
end

function activity_purchase(uid,num)
    local ts = getClientTs()
    local activity_cfg = getConfig('activity')
    
    local uobjs = getUserObjs(uid)
    local mUserinfo = uobjs.getModel('userinfo')
    local mBag = uobjs.getModel('bag')
    
    if not mUserinfo.flags.activity then
        mUserinfo.flags.activity = {}
    end
    
    for k,v in pairs(activity_cfg) do
        if v.status==1 then
            if v.status==1 and v.begin_ts<=ts and v.end_ts >= ts then
                if v.type==3 then
                    local record = {n=0}
                    if mUserinfo.flags.activity[k] then
                        record = mUserinfo.flags.activity[k]
                    end
                    
                    if record.n+num>100 then
                        local count = math.floor((record.n + num)/100)
                        record.n = record.n + num - (100 * count)
                        mUserinfo.flags.activity[k] = record

                        for m,n in pairs(v.reward.props) do
                            mBag.add('p'..n.id,count)
                        end
                    end
                end
            end
        elseif v.status==2 and mUserinfo.flags.activity.k then
            mUserinfo.flags.activity.k = nil
        end
    end
end
--active_setopt
--用户行为触发活动数据
--
--params int uid 用户姓名
--params string activeName 活动名称
--params table params 活动参数
--params mixed rewardTs 活动是否多出一天时间领奖
--params mixed default 默认值，如果活动不存在，或无返回值，返回此默认值
--
--return mixed
function activity_setopt(uid,activeName,params,rewardTs,default)
    local uobjs = getUserObjs(uid)
    local mUseractive = uobjs.getModel('useractive')
    --活动有效时间内
    if mUseractive.getActiveStatus(activeName,rewardTs) == 1 then
        local ret = mUseractive.setActive(activeName,params)
        if default and not ret then
            return default
        end
        return ret
    end
    -- 活动无效,有原始数据
    return default
end


--check active is exits

function checkActive(uid,activeName)
    -- body
    local status = false
    local ts = getClientTs()
    local uobjs = getUserObjs(uid)
    local mUseractive = uobjs.getModel('useractive')
    
    if(type(mUseractive.info[activeName])=='table')then
        if mUseractive.info[activeName].et>ts  then
            status=true
        end
    end
    return status
end


-- 生成http请求的post串
-- 只是内部接口调用，没必要做字串检测
function formPostData(reqbody)
        if type(reqbody) == 'table' then
            local postdata = ''
            for k,v in pairs(reqbody) do
                if v then
                    postdata = postdata .. k .. '=' .. v .. '&'
                end
            end
            
            return postdata
        end
    end
    --repetition 可以奖励物品的id重复出现
    function getRewardByPool(poolCfg,repetition)
        local function getRandBySeed(seedTable,valueN,array,randMaxN)
            array = array or {}

            if type(seedTable) == 'table' then   
                if not randMaxN then
                    for _,v in ipairs(seedTable) do
                      randMaxN = (randMaxN or 0) + v 
                    end
                end

                local randNum = rand(1,randMaxN)
                
                local i = 0
                for k,v in ipairs(seedTable) do         
                    i = (seedTable[k-1] or 0 ) + i
                   if randNum > i and randNum <= v + i then
                      table.insert(array,k)                  
                      if not valueN or valueN <= 1 then                      
                          return array
                      else
                          table.remove(seedTable,k)
                          valueN = valueN - 1
                          randMaxN = randMaxN - v
                          return getRandBySeed(seedTable,valueN,array,randMaxN)
                      end 
                    end
                end
            end

            return array
        end

        local function getRewardByRandKey(rewardKey,baseReward)
            local reward = {}
            if type(baseReward) == 'table' and #baseReward > 0 then
                for _,v in ipairs(rewardKey) do
                    if type(baseReward[v]) == 'table' then
                        if repetition  then
                            table.insert(reward,{[baseReward[v][1]]=baseReward[v][2]})
                        else
                            reward[baseReward[v][1]] = baseReward[v][2]
                        end
                    else
                        table.insert(reward,baseReward[v])
                    end                    
                    table.remove(baseReward,v)
                end
            end

            return reward
        end
        setRandSeed()                
        local reward = {}

        local pool = copyTable(poolCfg)   -- pool={{60,30,10},{50,30,20},{{"p19",1},{"p20",2},{"p20",2}}}
        local propN =  #pool[1]

        if propN > 1 then
            propN = arrayGet(getRandBySeed(pool[1]),1)
        end

        local rewardKey = getRandBySeed(pool[2],propN)

        reward = getRewardByRandKey(rewardKey,pool[3])

        return reward,rewardKey
    end

    -- --------------------------------------------------------------------------------------
    -- 统一的缓存key，以后别的地方需要用到key，都从这里生成
    -- 活动结束后，如果立即开新的活动，为了避免key冲突，需要加上活动的起始时间戳
    -- 活动结束后不好找啊
    -- 
    -- params string cName 类型的名称
    -- params string activeName 活动名称
    -- return string catchKey
    -- --------------------------------------------------------------------------------------
    function getActiveCacheKey(activeName,cName,st)
        return "z"..getZoneId() .. ".ac." .. cName .. "." .. tostring(activeName) .. "." .. st
    end
    --有福同享的cacheid
    function getActiveAllianceCacheKey(activeName,cName, aid, st)
        return "z"..getZoneId() .. ".ac." .. cName .. "." .. tostring(activeName) .. "." ..aid.. "." .. st
    end

-- 注册统计
-- regStats('accessory',{item= 'fUpgradeAnum',num=1})
function regStats(statName,params)
    if type (_EVENTS.stats[statName]) ~= 'table' then
        _EVENTS.stats[statName] = {}
    end
    table.insert(_EVENTS.stats[statName],params)
end

-- 处理统计
function processStats()    
    if type (_EVENTS.stats) == 'table' then
        local statsItems = {}
        for k,v in pairs(_EVENTS.stats) do            
            if not statsItems[k] then statsItems[k] = {} end
            if(k~="alliancebattle_daily") then
                if type(v) == 'table' then
                    for _,items in ipairs(v) do
                        if type(items.num) == 'number' then
                            statsItems[k][items.item] = (statsItems[k][items.item] or 0) + items.num
                        end
                    end
                end
            else

                statsItems[k]=v
            end

        end

        local statsLib = require "lib.stats"
        for statName,items in pairs(statsItems) do
            if type(statsLib[statName]) == 'function' then
                statsLib[statName](items)
            end
        end
    end
end

-- 发送请求给游戏服
-- return bool
function sendGameserver(host,port,params)
    if type(params) ~= 'table' then params = {} end

    local zoneid = getZoneId()

    params.zoneid = zoneid
    params.secret = getConfig("base.SECRETKEY")
    params = json.encode(params)

    local gameserver = require "lib.gameserver"
    local bs = gameserver.new(host, port)
    local ret
    if bs then
        ret = bs:put(params)
        bs:close()
    end

    return ret
end

-- 设置定时任务
-- params int uid 
-- params table params 
-- params int delay_time 延迟执行的秒数
-- return bool
function setGameCron(params,delay_time)
    if type(params) ~= 'table' then params = {} end

    local zoneid = getZoneId()
    
    params.zoneid = zoneid    
    params = json.encode(params)

    local scheduleJob = getConfig("config.z".. zoneid ..".scheduleJob")

    local haricot = require "lib.haricot"
    local bs = haricot.new(scheduleJob.host, scheduleJob.port)
    bs:use('battle')
    local exec,cronid = bs:put(0, delay_time, 5, params)
    bs:disconnect()
    return exec,cronid
end

-- 根据id获取任务信息
function getGameCron(cronId)
    local zoneid = getZoneId()
    local scheduleJob = getConfig("config.z".. zoneid ..".scheduleJob")

    local haricot = require "lib.haricot"
    local bs = haricot.new(scheduleJob.host, scheduleJob.port)
    bs:use('battle')
    
    local function get(id)
        id = tonumber(id)
        if ( (type(id) == "number") and (math.floor(id) == id) and (id >= 0) ) then
            local ret,cronData = bs:peek(id)
            if ret and type(cronData) == "table" and cronData.data then
                return json.decode(cronData.data)
            end
        end
    end

    local data
    if type(cronId) == "table" then
        local cronInfo = {}
        for k,id in pairs(cronId) do
            cronInfo[id] = get(id)
        end

        data = cronInfo
        -- return cronInfo
    else
        data = get(cronId)
        -- return get(cronId)
    end

    bs:disconnect()
    return data
end

-- 发送聊天信息至聊天频道
-- params string msg 发送的消息
-- return bool
function sendMessage(msg,zid)
    if type (msg) ~= 'table' then return false end
    msg.nocheck="tank_hwm"
    msg = json.encode(msg)

    if not msg then return false end

    local http = require("socket.http")
    http.TIMEOUT= 0.5

    local logUrl,actionLogUrl
    local config = getConfig('config')  
    local zoneid = zid or getZoneId()
    local chatUrl = config['z'..zoneid].chatUrl

    chatUrl = chatUrl .. 'msg=' .. msg
    -- chatUrl = chatUrl .. 'msg=' .. '{"sender":0,"reciver":0,"channel":1,"isSystem":1,"sendername":"","recivername":"","content":{"message":{"key":"chatSystemMessage8","param":["红色军团名字","蓝色军团名字","战场索引"]},"ts":1403869841,"contentType":3,"subType":4},"type":"chat","nocheck":"tank_hwm"}'
    
    local sendret = http.request(chatUrl)
    
    return sendret
end


--   随机数 
-- start  int  随机种子的开始 
-- end    int  随机种子的结束
-- len    int  随机种子的长度
-- return bool

function getRandList(start,ends,len)
    local list={}
    local i = 1
    setRandSeed()
    while i<= len do  
        
        local rate = rand(start,ends)
        local flag=table.contains(list, rate)
        if not flag then
            table.insert(list,rate)
            i=i+1
        end
    end
    return list
end


 -- 获取最大排名的是多少
function getMaxArenaRank()

    local maxrankKey = "z"..getZoneId().."_userarenarank"
    local redis = getRedis()
    local rank= redis:get(maxrankKey)
    if rank ==nil then
        rank=0
        local db = getDbo()
        local result = db:getRow("select max(ranking) AS  ranking from userarena")
        if next(result) then
            rank =tonumber(result.ranking)
            redis:set(maxrankKey,rank)
        end
    end
    return rank    
end

-- 设置安全数据（进缓存后会进数据库）只有比较重要怕丢失的数据才用这个
-- 调用此方法之前应该先get
-- 以key-value形式存放
function setFreeData(key,data,notCheckUpdateat)
    local key = "z"..getZoneId()..".free.".. key
    local db = getDbo()
    local result
    
    if _FreeData[key] then
        local netAt = getClientTs()
        if tonumber(_FreeData[key].update_at) == netAt then 
            netAt = netAt + 1
        end

        if notCheckUpdateat then
            result = db:update("freedata",{info=data,update_at=netAt},"name = '" .. key .. "'")
        else
            result = db:update("freedata",{info=data,update_at=netAt},"name = '" .. key .. "' and update_at = " .. _FreeData[key].update_at)
        end
    else
        result = db:update("freedata",{info=data,update_at=getClientTs()},"name = '" .. key .."'")
        if not result or result <= 0 then
            result = db:insert("freedata",{info=data,name=key,update_at=getClientTs()})
        end
        
    end
    
    return (tonumber(result) or 0) > 0 
end

-- 设置安全数据（进缓存后会进数据库）只有比较重要怕丢失的数据才用这个
-- 调用此方法之前应该先get
-- 以key-value形式存放
function setFreeDataWorldExp(tmpkey,data,notCheckUpdateat,addexp)
    local key = "z"..getZoneId()..".free.".. tmpkey
    local db = getDbo()
    local result
    

    local sql="UPDATE freedata SET update_at="..getClientTs().." , info=info+"..addexp.. " WHERE name = '"..key.."'"
  

    if db:query(sql)>0 then
        result=1
    else
        result = db:insert("freedata",{info=addexp,name=key,update_at=getClientTs()})    
    end

    local info =getFreeData(tmpkey)
    if info.info~=nil then

        if data<tonumber(info.info) then
            local redis  = getRedis()
            redis:del(tmpkey)
        else
            setFreeData(tmpkey,data)
        end
    end
    return result
end

-- 获取自由设置的数据（取数据库，数据不走缓存）
function getFreeData(key)
    local key = "z"..getZoneId()..".free.".. key

    if not _FreeData[key] then
        local db = getDbo()
        local result = db:getRow("select * from freedata where name=:key",{key=key})
        
        if type(result)  == 'table' then
            -- _FreeData[key] = json.decode(result) or result
            _FreeData[key] = result
            if _FreeData[key].info then
                _FreeData[key].info = json.decode(_FreeData[key].info)
            end
        end
    end
    
    return _FreeData[key]
end

function writeKunLunNALog(appid,logtype,logtext)
    local appid4pid = {
        [10226] = 733,
        [10126] = 734,
        [1028] = 759,
        [10132] = 4013,
        [10232] = 4014,
    }

    local zid = tostring(getZoneId())
    local zongid_len = #zid
    if zongid_len < 3 then
        zid = string.rep( 0, 3 - zongid_len ) .. zid
    end

    if tonumber(zid) == 1000 then zid = 999 end

    local pid = appid4pid[appid]
    if not pid or not logtext[1] then
        return false
    end

    local rid = pid .. zid 
    local yyyymm = os.date('%Y%m')
    local yyyymmdd = os.date('%Y%m%d')
    local ts = getClientTs()

    local logpath

    if logtype == 1 then
        logpath = "/data/syslog/platformlog/" .. yyyymm .. "/login_".. pid .. "_" .. rid .. "_" .. yyyymmdd .. ".log"
    elseif logtype == 2 then
        logpath = "/data/syslog/platformlog/" .. yyyymm .. "/active_".. pid .. "_" .. rid .. "_" .. yyyymmdd .. ".log"
    else
        logpath = "/data/syslog/platformlog/" .. yyyymm .. "/activesuccess_".. pid .. "_" .. rid .. "_" .. yyyymmdd .. ".log"
    end

    table.insert(logtext,pid)
    table.insert(logtext,rid)

    logtext = table.concat(logtext,"\t") .. '\r\n'
    local f = io.open(logpath, "a+")
    if f then
        f:write(logtext)
        f:close()
    end

end

-- 获取地形，根据坐标
-- MOD(INT(y*(y*4.6+1.5)+x*(x*3.8+1.9)+y*x*4.3),5)+1
function getLandformByPos(x,y)
    x = tonumber(x)
    y = tonumber(y)
    
    return (math.floor(y*(y*4.6+1.5)+x*(x*3.8+1.9)+y*x*4.3) % 5) +1
end

-- 获取攻击者攻击时享受的地形
-- 在发生战斗的时候获取，防止出现战斗前有人搬家改变地形
function getAttackerLandformOfBattle(attackerPos,targetPos)
    local landX,landY

    local x = targetPos[1] - attackerPos[1]
    local y = targetPos[2] - attackerPos[2]

    if x < 0 then
        landX = math.abs(2.5*x) > math.abs(y) and 1 or 0
    else
        landX = math.abs(2.5*x) > math.abs(y) and -1 or 0 
    end

    if y < 0 then
        landY = math.abs(2.5*y) > math.abs(x) and 1 or 0
    else
        landY = math.abs(2.5*y) > math.abs(x) and -1 or 0
    end

    landX = landX + targetPos[1]
    landY = landY + targetPos[2]

    if landX < 1 then landX = 1 end
    if landY < 1 then landY = 1 end
    if landX > 600 then landX = 600 end
    if landY > 600 then landY = 600 end

    local mapType = 0
    local mid = getMidByPos(landX,landY)
    if mid then
        local mMap = require  "lib.map"
        local map = mMap:getMapById(mid)
        mapType = tonumber(mMap.arrayGet(map,'type',0)) or 0
    end

    return (mapType > 0 and mapType <= 6) and mapType or getLandformByPos(landX,landY)
end

-- 开关是否打开(不影响以前代码里写的)
-- return bool
function switchIsEnabled(moduleName) 
    return moduleIsEnabled(moduleName) == 1
end

-- 功能是否已打开
-- return bool
function moduleIsEnabled (moduleName, subName)
    
    local gameconfig = getConfig('gameconfig')
    if  gameconfig.ts==nil then
        gameconfig=getModuleIs()
    end
    local enable=0
    if type(gameconfig[moduleName]) == 'table' and gameconfig[moduleName].enable == 1  then
        enable=1
    end

    if subName and type(gameconfig[moduleName]) == 'table' and gameconfig[moduleName][subName] ~= 0  then
        enable= gameconfig[moduleName][subName]
    end

    if gameconfig[moduleName] and type(gameconfig[moduleName]) ~= 'table' and gameconfig[moduleName] ~= 0 then
        enable=gameconfig[moduleName]
    end
    return enable
end

-- 获取所有功能开关
-- retrun table 
function getModuleIs( appid )
    
    --判断开关是否有数据没有就返回文件里的旧配置
    local gameconfig = getConfig('gameconfig') 
    
    if gameconfig.ts~=nil and not appid then
        return gameconfig
    end

    require 'model.gameconfig'
    local mGameconfig = model_gameconfig() 
    local gameCfg=mGameconfig.getValidgameconfigs( appid )
    if type(gameCfg)=='table' and next(gameCfg) then 
        for k,v in pairs(gameCfg) do

            if  k=='gw'  or k=='evaluate'  or k=='ec'  or k=='code' or k=='lf' or k=='nd'  or k=='sign' or k=='ol' or k=='friend' or k=='pay' or k=='military'  or k=='video' or k=='boom'  then
                if type(gameconfig[k]) ~='table' then  gameconfig[k]={} end

                gameconfig[k].enable=tonumber(v.value)

            elseif k=='alliance'   or k=='allianceachallenge' or k=='alliancewar' or k=='allianceskills' or k=='allianceshop' or k=='changepic' or k=='truepic' or k=='boom'
                or k=='boomtroops' or k=='boomres' then
                    if type(gameconfig.alliance) ~='table' then  gameconfig.alliance={} end

                    if k=='alliance' then
                        gameconfig.alliance.enable=tonumber(v.value)
                    end
                    if k=='allianceachallenge' then
                        gameconfig.alliance.achallenge=tonumber(v.value)
                    end
                    if k=='alliancewar' then
                        gameconfig.alliance.war=tonumber(v.value)
                        gameconfig.alliancewar =tonumber(v.value)
                    end
                    if k=='allianceskills' then
                        gameconfig.alliance.skills=tonumber(v.value)
                    end
                    if k=='allianceshop' then
                        gameconfig.alliance.shop=tonumber(v.value)
                        gameconfig.allianceshop=tonumber(v.value)
                    end
                    if k=='changepic' then
                        gameconfig.pic.changepic=tonumber(v.value)
                    end     
                    if k=='truepic' then
                        gameconfig.pic.truepic=tonumber(v.value)
                    end
                    if k=='boom' then
                        gameconfig.boom.enable=tonumber(v.value)
                    end
                    if k=='boomtroops' then
                       gameconfig.boom.troops=tonumber(v.value) 
                    end
                    if k=='boomres' then
                       gameconfig.boom.resources=tonumber(v.value) 
                    end
            else
                gameconfig[k]=tonumber(v.value)
            end
        end
        
    end    

    gameconfig.ts=1
    
    return gameconfig
end

--获取活动数据
function getActiveRewardFormatMail(uid, activeName, params, oldReward, rewardTs)
    local activeAward
    if not oldReward then
        oldReward = {}
    end
    local result = activity_setopt(uid,activeName,params,rewardTs)
    if type(result) ~= 'table' then 
	    return oldReward, activeAward
    end
    if result['reward'] then
        for _, v in pairs(result['reward']) do
	     
             if oldReward[v.type] then
                 if oldReward[v.type][v.name] then
                     oldReward[v.type][v.name] = oldReward[v.type][v.name] + v.number
                 else
                     oldReward[v.type][v.name] = v.number
                 end
	         else
		        oldReward[v.type] = {}
		        oldReward[v.type][v.name] = v.number
	         end
        end
    end
    if result['acaward'] then
        activeAward = result['acaward']
    end
    return oldReward, activeAward
end

function math.logn(num,base)
    return math.log10(num)/math.log10(base)
end

--计算远征军的档次
function getExpeditionGrade(fc)
    local grade= math.floor(math.logn((fc/40000),1.1)+1)
    if grade<1 then
        grade=1
    end
    return grade
end

-- 格式化攻击的坦克部队
-- params table tanks 客户端传过来的攻击部队信息{{10001,1},{10002,2},...}
-- return table,int 格式化好的坦克{a10001=1,a10002=2,...},坦克总数量
function formatAttackTanks(tanks)
    local fleetInfo = {}
    local totalTanks = 0
    for m,n in pairs(tanks) do        
        if type(n) == 'table' and next(n) and n[2] > 0 then
            if n[1] then 
                n[1]= 'a' .. n[1] 
            end    
            totalTanks = totalTanks + n[2]
            fleetInfo[m] = n
        else
            fleetInfo[m] = {}
        end
    end

    return fleetInfo,totalTanks
end

function getChatEncrypt( st1,uid1,zid1 )
    st1 = tostring(st1)
    uid1 = tonumber(uid1)
    zid1 = tonumber(zid1)
    local b1=math.floor(math.floor(tonumber(string.sub(st1,8))*4.1415))%3
    local b2=math.floor(tonumber(string.sub(st1,7))%7)
    local b3=math.floor(tonumber(string.sub(st1,6))%6)
    local b4=math.floor((uid1*3.1415)%9)
    local b5=math.floor(uid1%3)
    local b6=math.floor(uid1%4)
    local b7=math.floor((zid1*5.57))
    local b8=math.floor((zid1*7.78))
    local b9=math.floor((zid1*8.35))
    return ((b4*b1*b7+st1*3)..(b5*b2*b8+st1*4)..(5*b3*b6*b9))
end

function getChatEncrypt2(st1,uid1,zid1)
     st1 = tostring(st1)
    uid1 = tonumber(uid1)
    zid1 = tonumber(zid1)
    local b1=math.floor(math.floor(tonumber(string.sub(st1,8))*4.1415))%3
    local b2=math.floor(tonumber(string.sub(st1,7))%7)
    local b3=math.floor(tonumber(string.sub(st1,6))%6)
    local b4=math.floor((uid1*3.1415)%9)
    local b5=math.floor(uid1%3)
    local b6=math.floor(uid1%4)
    local b7=math.floor((zid1*5.57)%3)
    local b8=math.floor((zid1*7.78))
    local b9=math.floor((zid1*8.35))

    local b10=math.floor(tonumber(string.sub(st1,9))*3.5541)
    local b11=math.ceil(tonumber(string.sub(st1,10))*1.5541)
    if b10%2==0 then
        b5=math.floor(uid1%3)
        b2=7
    elseif b10%3==0 then
        b1=math.ceil(b1*b10%4)
    elseif b11<3  then
        b7=math.floor(b7*1.23123)
    elseif b11>3 and b11<8  then
        b7=math.floor(b7*5.12)
    else
        b8=math.ceil(b8*1.235)
    end

    local tb={"4u5h","894n","g5h6","45","y5g4","6g5v","g45t","M4f55","5s6V","4646","g8M1","642","g7v0","11y7","647n","9J5g","j8m0","98f7","903n","146T","884n","f3M9","4gf6","9fa9","6699","Mg80","5g","fakp","8fja","0ak0","m2z35","t8j0","j9fa","4f67m","h9o0g","80j9","9f9j","902m","9hs8","6h8n","32m9","7z8","78j1","8"}
    local tb2={"9fj9","j4f6","64","gy6h","g5a5","a6m7","Grv2","6656","j7m5","8739","f9a06","589G","9af9","a4D6G","8J77","9jG5","9j67","8fi6","9a65","g64g","t6m3t","4zku8","9jf9","M8iy","0O0j","G26D","1iz5G","8839","0ag50","8fu9","8h9h","56","0o08"}
    

    local ttbb=tb[math.floor(math.floor(tonumber(string.sub(st1,9)))%20)+1]
    local ttbb2=tb2[math.floor(math.floor(tonumber(string.sub(st1,9)))%30)+1]
    local ttbb3=tb2[math.floor(math.floor(tonumber(string.sub(st1,8)))%30)+1]

    local mbbd= (b4*b1*b8+b3*b5)..ttbb..(b4*b5+b8)..(b2*b3*b8)..(b3*b4+b11*b1)..ttbb3..(b7*b5)..(b5+b11+b3)..ttbb2..(b1+b2+20+b4+10+b7)..(b5*b3+b7*b1)..(b2*b3*b6*b7+b9)
    return mbbd
end


-- 符合条件的玩家显示 版号版本
function getCheckDailyActionNumUids( uid )
    local uidlist = {
        ['214003356'] = true, --格式

    } --白名单列表

    local uobjs = getUserObjs(uid)
    local mUserinfo = uobjs.getModel('userinfo')
    -- 白名单用户 or 客户端检测的版号用户
    if mUserinfo.hwid == "BH" or ( getClientBH() >= 2 and mUserinfo.level <= 15 ) then
        return {
            [tostring(uid)] = true,
        }
    end

    --判断设备id
    local device = {
        ["deviceidxxx"] = true,
    }
    if mUserinfo.deviceid and device[mUserinfo.deviceid] == true then
        uidlist[ tostring(uid) ] = true
    end

    return uidlist
end

-- 设置操作次数(给有加限制的地方用的)
function setUserDailyActionNum(uid,key,num)
    local uids = getCheckDailyActionNumUids( uid )

    if not uids[tostring(uid)] then return 0 end
    if getClientBH() ~= 2 then return 0 end

    local weets = getWeeTs()
    local cacheKeyTb ={ 
        "z"..getZoneId(),
        "userDailyActionNum",
        weets,
    }

    local cacheKey = table.concat(cacheKeyTb,'.')
    cacheKeyTb = nil

    local redis = getRedis()
    local actionNum = redis:hincrby(cacheKey,table.concat({key,uid},"_"),num or 1)
    redis:expireat(cacheKey,weets+86400)

    return tonumber(actionNum) or 0
end

-- 获取战斗天气
-- 第一个参数是海面：目前只有一种 第二个参数为天气：目前有两种 随机取1或2 第三个参数为地形：目前有两种 随机取1或2
-- 海面 1种  天气2种 1：晴 2：雨  背景4种 1：无 2：山石 3：礁石 4：冰山，冰山不会出现在雨天
function getBattleOcean()
    local baseOcean = {1,2,4}

    setRandSeed()
    local battleOcean = {1,rand(1,baseOcean[2])}
    table.insert(battleOcean,battleOcean[2]==2 and rand(1,baseOcean[3]-1) or rand(1,baseOcean[3]))
    
    return battleOcean
end

--增加用户系统奖励
function addGameReward(uid,stype,rewards,params,title,content,ts)
--mailSent(uid,sender,receiver,mail_from,mail_to,subject,content,mail_type,isRead,gift,item)
    local uobjs = getUserObjs(uid)
    local mUserinfo = uobjs.getModel('userinfo')
    MAIL:mailSent(uid,1,uid,'',mUserinfo.nickname, title,content,1,rewards)

    return true
end

-- 区域站获取buff的结束时间
function getAreaBuffEnd()
        local ts = getClientTs()
        local date  = getWeeTs()
        local weekday=tonumber(getDateByTimeZone(ts,"%w"))
        local areaWarCfg = getConfig('areaWarCfg')
        local startWarTime=areaWarCfg.startWarTime
        local day=areaWarCfg.prepareTime
        if weekday~=day then 
            if weekday>day then
                date=date-(weekday-day)*86400+areaWarCfg.battleTime*86400+startWarTime[1]*3600+startWarTime[2]*60
            else
                date=date+(day-weekday)*86400+areaWarCfg.battleTime*86400+startWarTime[1]*3600+startWarTime[2]*60
            end
        else
            date=date+areaWarCfg.battleTime*86400+startWarTime[1]*3600+startWarTime[2]*60
        end
        if ts>= date then
              date=date+7*86400
        end

        return date
    
end
-- 区域站报名结束的时间
function getAreaApplyEndAt()
        local ts = getClientTs()
        local date  = getWeeTs()
        local weekday=tonumber(getDateByTimeZone(ts,"%w"))
        local areaWarCfg = getConfig('areaWarCfg')
        local startWarTime=areaWarCfg.startWarTime
        local day=areaWarCfg.prepareTime
        if weekday~=day then 
            if weekday>day then
                date=date-(weekday-day)*86400+areaWarCfg.battleTime*86400
            else
                date=date+(day-weekday)*86400+areaWarCfg.battleTime*86400
                date=date-7*86400
            end
        else
            date=date+86400
        end
        return date
end
-- 获取bid
function getAreaWarId(ts)
    ts = ts or getAreaApplyEndAt()
    local zone = getConfig('base.TIMEZONE')
    local day = (getWeeTs(ts) + zone * 3600) / 86400
    return "b" .. getZoneId() .. day
end

-- 区域站插入王成记录
function addAreaWarCity(data)
    local db = getDbo()
    local ret = db:insert('areawarcity',data)
    if ret then
        local redis=getRedis()
        local key="z."..getZoneId().."areawarcitylog"
        redis:del(key)
    end
end
-- 获取王城的记录
function getAreaWarCity()
    local list={}
    local redis=getRedis()
    local key="z."..getZoneId().."areawarcitylog"
    list =json.decode(redis:get(key))
    if list==nil then
        list={}
        local db = getDbo()
        local result = db:getAllRows("select * from areawarcity ")
        if type(result)=='table' and next(result)  then
            list=result
        end
        redis:set(key,json.encode(list))
    end
    return list
end

-- 打印table 调试用
function showTable(data_table, idx)
    if type(data_table) ~= 'table' then
        print(data_table)
        return
    end

    idx = tonumber(idx) or 0
    local prefix = string.rep("    ",  idx)
    for k, v in pairs(data_table) do
        --print( '                     ---> ', idx or 0,  k, v)
        if type(v) == 'table' then
            print( prefix .. "[" .. k .. "] = {"  )
            showTable(v,  idx+1)
            print( prefix .. "}," )
        else
            print( prefix .. "[" .. k .. "] = " .. tostring(v) .. ",")
        end
    end

end
-- 发送到奖励中心
-- rtype = {ac = 'active',sys = 'sys',ed = 'everyDay','gm' = 'gm'}
function sendToRewardCenter(uid,rtype,title,rtime,expire,info,reward)
    --writeLog('rewardcenter start','rewardcenter')
	local ret = false
	local id
    local bid
	local ts = getClientTs()

	if not uid or not rtype or not title or not reward or type(reward) ~= 'table' then
		return ret
	end
	
	if not rtime then
		rtime = getWeeTs(ts)
	end
	
	if not info then
		info = {}
	end
	
	if not expire then
		expire = 86400*15
	end
    --writeLog('rewardcenter mid','rewardcenter')
	if rtype == 'ac' then 
		id = 'ac_' .. title .. '_' .. rtime .. '_' .. uid -- ac.kafkagift1.1849306600.1000001 按照活动档位 每档一次 title = aid，多档位 title = aid + 档位
	elseif rtype == 'sys' then
		id = 'sys_' .. title .. '_' .. uid -- sys.level15.1000001 系统事件触发 仅一次 title = 事件名
	elseif rtype == 'ed' then
		id = 'ed_' .. title .. '_' .. rtime .. '_' .. uid -- ed.sign.1849306600.1000001 每天一次的事件 title = 事件名，每天可能多次触发 title = 事件名+档位
	elseif rtype == 'gm' then
		id = 'gm_' .. os.time() .. '_' .. uid -- gm.1849306600.1000001 管理系统直接发送 不做key验证，会做每日uid条数限制
    elseif rtype == 'sw' then
		id = 'sw_' .. title .. '_' .. rtime .. '_' .. uid -- sw.sweep.1849306600.1000001 超级武器 title = 事件名，每天可能多次触发 title = 事件名+档位
	elseif rtype == 'pw' then
        title = tonumber(title)
        bid = rtime
        rtime = getWeeTs(ts)

        if title == 35 or title == 36 or title == 39 or title == 40 then
            id = 'pw_' .. bid .. '_' .. title .. '_' .. uid
        elseif title == 37 or title == 41 then
            id = 'pw_' .. bid .. '_' .. title .. '_' .. rtime .. '_' .. uid
        end
    elseif rtype == 'mi' then
        timeKey = rtime
        rtime = getWeeTs(rtime + 86400)
        id = 'mi_' .. title .. '_' .. timeKey .. '_' .. uid -- mi.junshiyanxi.1849306600.1000001 军事演习 title = 事件名，每天可能多次触发 title = 事件名+档位
    elseif rtype == 'sky' then
        bid = rtime
        rtime = getWeeTs(ts)
        id = 'sky_' .. bid .. '_' .. title .. '_' .. uid
    -- 军团战奖励
    elseif rtype=='aw' then
        if title == 43 or title == 45   then
            id = 'aw_' .. rtime .. '_' .. title .. '_' .. uid
        end
     -- 区域战奖励
    elseif rtype=='areawar' then
        id = 'areawar_' .. rtime .. '_' .. title .. '_' .. uid   
    elseif rtype=='usw' then
        bid = title
        title = 'reward'
        id = 'usw_' .. 'b'..bid .. '_' .. uid -- usw_b11854_1000001
        -- 叛军奖励
    elseif rtype=='rf' then
        local count=info.count
        info.count=nil
        id = 'rf_'..count.. rtime .. '_' .. title .. '_' .. uid
    elseif rtype == 'boss' then
        id = 'boss_' .. title .. '_' .. rtime .. '_' .. uid -- 世界boss触发仅一次title
    else
		return ret
	end

    --writeLog('rewardcenter id='..id,'rewardcenter')
	local item = {
		id = id,
		type = rtype, -- 奖励类型
		uid = uid,
		title = title, -- 类型为gm时，为纯文字 其他类型为英文
		st = rtime,
		et = rtime + expire,
		info = info,
		reward = reward,
		updated_at = ts,
	}

	require "lib.rewardcenter"
	local rewardcenter = model_rewardcenter()
    local ret = rewardcenter.addReward(title,item)
    
	return ret
end

-- 取最接近目标的索引值
function getClosestIndexValue(num,array)
	if type(array) ~= 'table' then
		return nil
	end

	local count = #array
	
	if num > count then
		num = count
	end

	return array[num]
end


-- 超级武器刷新配件
--'z'..zid..'.weapon.'..fid..'.'..plevel..'.list'
--=
-- z1.weapon.f3.3.list

function refWeaponFragment()
    local redis = getRedis()
    local db = getDbo()
    local zid=getZoneId()
    local result = db:getAllRows("select uid,info,fragment  from weapon where fragment <>'{}' ")
    -- print('ref-st')
    if next(result) then
        local config = getConfig('superWeaponCfg')
        local weaponCfg = config.weaponCfg
        local fragmentCfg = config.fragmentCfg
        
        for k,v in pairs (result) do
            local info = json.decode(v.info)
            local fragment = json.decode(v.fragment)
            
            for fk,fv in pairs(fragment) do
                local output=fragmentCfg[fk]["output"]
                local plevel = 0
                if type(info[output])=="table"  then
                    if info[output][1]~=nil then
                        plevel=info[output][1]
                    end
                end
                
                local add = 0
                local atype = 0
                if fragment[fk] and fragment[fk] > 1 then
                    add = 1
                    atype = 1
                else
                    atype = 2
                    local fidList = weaponCfg[output].fragment or {}
                    local total = 0
                    for i,v in pairs(fidList) do
                        if fragment[v] and fragment[v] > 0 then
                            total = total + 1
                        end
                    end
                    
                    -- if v.uid == '1000261' then
                        -- ptb:p()
                        -- print('total',total)
                    -- end
                    if total >= 2 then
                        add = 1
                    end
                end
                -- if v.uid == '1000261' then
                    -- print('atype',atype)
                    -- print('add',add)
                -- end
                
                if add == 1 then
                    local key='z'..zid..'.weapon.'..fk..'.'..plevel..'.list'
                    redis:hset(key,v.uid,v.uid)
                end
            end
           
        end
    end
    -- print('ref-et')
end

-- 超级武器 抢夺玩家成功率
function weaponRobRate(aRank,dRank,grapRate)
    local rankDiff = aRank - dRank
    local chance = 0
    if not grapRate then
        local weaponrobCfg = getConfig('weaponrobCfg')
        grapRate = weaponrobCfg.grapRate or 0
    end
    if rankDiff >= 0 then
        chance = math.floor(grapRate*(1-rankDiff/120)*100)
    else
        chance = math.floor(grapRate*(1+rankDiff/120)*100)
    end
    
    return chance
end

function pairsByRand(arr)
    local arr_size=#arr
    local keys = table.keys(arr)
    setRandSeed()
    local rand = rand
    local i = 1
    return function()
        if i<=arr_size then
            local rd=rand(1,arr_size+1-i)
            local key,val = keys[rd],arr[rd]
            table.remove(arr,rd)
            table.remove(keys,rd)
            i=i+1
            return key,val
        end
    end
end

-- 获取指定时间的时间戳
function getTimeByTimeZoneFromDate(dateStr)
    local zone = getConfig('base.TIMEZONE') or 0
    local isdst = getConfig('base.ISDST')
    assert(type(dateStr)=='string')
    local arr = string.split(dateStr," ")
    assert(#arr==2)
    local dateArr = string.split(arr[1],"-")
    local timeArr = string.split(arr[2],":")
    assert(#dateArr==3)
    assert(#timeArr==3)

    local year = tonumber(dateArr[1]) or 0
   
    local month = tonumber(dateArr[2]) or 0
    assert(month>=1 and month<=12)
    local day = tonumber(dateArr[3]) or 0
    assert(day>=1 and day<=31)
    local hour = tonumber(timeArr[1]) or 0
    assert(hour>=0 and hour<=23)
    local min = tonumber(timeArr[2]) or 0
    assert(min>=0 and min<=59)
    local sec = tonumber(timeArr[3]) or 0
    assert(sec>=0 and sec<=59)

    -- 时区用的是机器的系统时区而不是当地时区，需要按当地时区计算(计算0时区和当地时区差)
    local utcTime=os.time(os.date("!*t"))
    local serverTime=os.time(os.date("*t"))
    local serverZone=math.floor((serverTime - utcTime)/3600)
    local tb={year=year,month=month,day=day,hour=hour,min=min,sec=sec}
    local gtc = os.time(tb) + (serverZone - zone)*3600
    return gtc

    -- local gtc = os.time({year=year,month=month,day=day,hour=hour,min=min,sec=sec,isdst=isdst})
    -- local gtcnow = os.date("!*t", gtc)
    -- -- gtcnow.isdst=isdst    

    -- gtc = os.time(gtcnow)   + zone * 3600
    -- return gtc

end

--获取活动参数
function activity_get_global_opt(activityName,st)
    local result = {}
    local json = require "cjson.safe"
    local redis = getRedis()
    local key = "z"..getZoneId().."."..activityName.."."..st

    result = json.decode(redis:get(key))
    if type(result) ~= 'table' then
        result = {}
    end

    return result
end

--设置活动全服参数
function activity_set_global_opt(aname,st,et,params)
	local status = 0
    local json = require "cjson.safe"
    local redis = getRedis()
    local key = "z"..getZoneId().."."..aname.."."..st

    if not aname or aname == '' or type(params) ~= 'table' then
        return status
    end

    local data = json.encode(params)
    status = redis:set(key,data)
    redis:expire(key,et-st) 

	return status
end

-- 天梯榜军团奖励发放标识
function setAllianceSkyladderData(aid,bid,rank)
    local ret,err
    local key = "z"..getZoneId()..".AllianceSkyladder.".. aid
    local db = getDbo()
    local result
    local tbname = 'allianceskyladder'
    
    local have = db:getRow("select * from "..tbname.." where id='"..aid.."' limit 1")
        
    if not have then
        ret = db:insert(tbname,{id=aid,info={cubid=bid,lsbid=0,curank=rank,lsrank=0}})
        if not ret then err = db:getError() end
    else
        local info = json.decode(have.info) or {}
        if not info.cubid then
            info.cubid = 0
        end
        
        if not info.lsbid then
            info.lsbid = 0
        end
        
        if not info.curank then
            info.curank = 0
        end
        
        if not info.lsrank then
            info.lsrank = 0
        end
        
        info.lsbid = info.cubid
        info.lsrank = info.curank
        info.cubid = bid
        info.curank = rank
        
        have.info = info
        
        ret = db:update(tbname,have,"id='"..aid.."'")
        if not ret then err = self.db:getError() end
    end
    
    local redis = getRedis()
    redis:del(key)

    return (tonumber(result) or 0) > 0 
end

-- 天梯榜军团奖励发放标识
function getAllianceSkyladderData(aid)
    local redis = getRedis()
    local key = "z"..getZoneId()..".AllianceSkyladder.".. aid
    local tbname = 'allianceskyladder'
    local have = json.decode(redis:get(key))
    local result = {}

    if not have then
        local db = getDbo()
        local result = db:getRow("select * from "..tbname.." where id='"..aid.."' limit 1")

        if type(result)  == 'table' then
            result.info = json.decode(result.info) or {}
            
            if not result.info.cubid then
                result.info.cubid = 0
            end
            
            if not result.info.lsbid then
                result.info.lsbid = 0
            end
            
            if not result.info.curank then
                result.info.curank = 0
            end
            
            if not result.info.lsrank then
                result.info.lsrank = 0
            end
            
            redis:set(key,json.encode(result.info))
            result = result.info
        end
    else
        result = have
    end

    return result
end


-- 获取任意大战是否开启中
function getServerWarFlag()
    local flag =false
    local ts = getClientTs()
    require "model.serverbattle"
    local mServerbattle = model_serverbattle()
    -- 军团跨服战
    local amMatchinfo = mServerbattle.getAcrossBattleInfo()
    if type(amMatchinfo)=='table' and next(amMatchinfo) then
        local sevCfg=getConfig("serverWarTeamCfg")
        local start =tonumber(amMatchinfo.st or 0)
        start=start+(sevCfg.preparetime+sevCfg.signuptime)*86400
        local et=start+(sevCfg.durationtime-sevCfg.shoppingtime)*86400
        if ts>=start and ts<et then
            return true
        end
    end
    -- 个人跨服战
    local mMatchinfo, code = mServerbattle.getRoundInfo(1)
    --ptb:p(mMatchinfo)
    if code == 0 and next(mMatchinfo) then
        local sevCfg=getConfig("serverWarPersonalCfg")
        local start =tonumber(mMatchinfo.st or 0)+(sevCfg.preparetime)*86400
        local et=start+(sevCfg.durationtime-(sevCfg.preparetime-sevCfg.shoppingtime)+1)*86400
        --print('st',start)
        --print('et',et)
        if ts>=start and ts<et then
            return true
        end
    end

    --世界大战基本信息
    local mMatchinfo= mServerbattle.getWorldWarBattleInfo()
    if type(mMatchinfo)=='table'  and  next(mMatchinfo)  then
        local start =tonumber(mMatchinfo.st or 0)
        local sevCfg=getConfig("worldWarCfg")
        start=start+sevCfg.signuptime*86400
        local et =start+(sevCfg.pmatchdays+sevCfg.battletime)*86400
        if ts>=start and ts<et then
            return true
        end
    end

    --跨服区域战的基本信息 sevCfg
    local mMatchinfo= mServerbattle.getserverareabattlecfg()
    if type(mMatchinfo)=='table'  and  next(mMatchinfo)  then
        local start =tonumber(mMatchinfo.st or 0)
        local sevCfg=getConfig("serverAreaWarCfg")
        start=start+(sevCfg.signuptime*86400)
        
        local et =start+(sevCfg.battleTime)*86400
        if ts>=start and ts<et then
            return true
        end
    end

    return flag
end

function getSkyladderKuafuSwitch()
    local switch = getConfig("gameconfig.kfladder") or 0
    -- print('switch')
    -- ptb:p(config)
    return switch
end

--  扫矿统计
-- 每天 uid, ip超过限制的信息
-- 
function regCheckcode2(uid, client_ip)
    if not client_ip then
        client_ip = "0.0.0.0"
    end

    local redis = getRedis()
    local weeTs = getWeeTs()
    local ts = getClientTs()
    local hour = getDateByTimeZone(ts, "%H")

    local function update_scoutlog(params)
        --print('update_scoutlog ... ... ')
        --ptb:p(params)
        local db = getDbo()
        local rst = db:getRow("select * from scoutlog where id = :id",{id=params.id})
        -- ptb:p(rst)
        if rst then
            local id = params.id
            params.id = nil
            if rst.cntperhour and params.cntperhour and tonumber(rst.cntperhour) > tonumber(params.cntperhour) then
                params.cntperhour = nil
            end
            if rst.ipcntperhour and params.ipcntperhour and tonumber(rst.ipcntperhour) > tonumber(params.ipcntperhour) then
                params.ipcntperhour = nil
            end
            if rst.cnt and params.cnt and tonumber(rst.cnt) > tonumber(params.cnt) then
                params.cnt = nil
            end
            if rst.ipcnt and params.ipcnt and tonumber(rst.ipcnt) > tonumber(params.ipcnt) then
                params.ipcnt = nil
            end

            local rets= db:update("scoutlog", params, "id='" .. id .. "'")

        else
            db:insert("scoutlog", params)
        end
    end

    -- 统计玩家扫矿次数
    local uidkey = "z"..getZoneId()..".checkcode2.uids" .. weeTs
    local uid_cnt = redis:hincrby(uidkey, uid, 1)
    redis:expireat(uidkey,weeTs+86400)
    -- print('uid_cnt', uid_cnt)

    --统计ip扫矿次数
    local ipkey = "z"..getZoneId()..".checkcode2.ips" .. weeTs
    local ip_cnt = redis:hincrby(ipkey, client_ip, 1)
    redis:expireat(ipkey,weeTs+86400)
    -- print('ip_cnt', ip_cnt )

    local uidkeyperhour = "z"..getZoneId()..".checkcode2.uids" .. weeTs .. hour
    local uidperhour_cnt = redis:hincrby(uidkeyperhour, uid, 1)
    redis:expireat(uidkeyperhour,weeTs+86400)
    -- print('uidperhour_cnt', uidperhour_cnt)

    local ipkeyperhour = "z"..getZoneId()..".checkcode2.ips" .. weeTs .. hour
    local ipperhour_cnt = redis:hincrby(ipkeyperhour, client_ip, 1)
    redis:expireat(ipkeyperhour,weeTs+86400)
    -- print('ipperhour_cnt', ipperhour_cnt)

    --ip 连续侦查 取历史最高纪录
    for i=0, hour do 
        ipkeyperhour = "z"..getZoneId()..".checkcode2.ips" .. weeTs .. i
        local tmp_ipperhour_cnt = redis:hget(ipkeyperhour, client_ip)
        if tmp_ipperhour_cnt and tonumber(tmp_ipperhour_cnt) > tonumber(ipperhour_cnt) then
            ipperhour_cnt = tonumber(tmp_ipperhour_cnt) 
        end
    end

    local ip2uidkey = "z"..getZoneId()..".checkcode2.ip2uid" .. weeTs
    local ip2uids = json.decode( redis:get(ip2uidkey) )
    if uid_cnt == 1 then
        if not ip2uids then
            ip2uids = { [client_ip] ={uid} }
        else
            ip2uids[client_ip] = ip2uids[client_ip] or {}
            table.insert(ip2uids[client_ip], uid)
        end
        redis:set(ip2uidkey, json.encode(ip2uids))
        redis:expireat(ip2uidkey, weeTs+86400)
    elseif not ip2uids then
        ip2uids = {}
    end

    local params ={
        id = weeTs .. '-' .. uid, --每个玩家每天一条记录
        uid = uid,
        ip = client_ip,
        cnt = uid_cnt,
        cntperhour = uidperhour_cnt,
        ipcnt = ip_cnt,
        ipcntperhour = ipperhour_cnt,
        scoutdata = ts,
    }
    local cfg = getConfig('player.checkcode2')
    if ( ip_cnt > cfg[1] or ipperhour_cnt > cfg[2] ) and ip2uids[client_ip] then
        for k, v in pairs (ip2uids[client_ip]) do
            -- print(k, v)
            params.id = weeTs .. '-' .. v
            params.uid = v
            if uid ~= v then
                params.cnt = 0
                params.cntperhour = 0
            else
                params.cnt = uid_cnt
                params.cntperhour = uidperhour_cnt            
            end

            update_scoutlog(params)
        end    
    elseif uid_cnt > cfg[3] or uidperhour_cnt > cfg[4] then
        update_scoutlog(params)
    end

end

-- 存在数组中
function arrayIndex(array, value)
    if type(array) ~= 'table' then
        return nil 
    end

    for k, v in pairs(array) do
        if tonumber(value) and tonumber(v) == tonumber(value) then
            return k
        elseif tostring(value) and tostring(v) == tostring(value) then
            return k
        end
    end

    return nil 
end

-- 记录每天登入和登出信息
function regLoginAndLogout(uid, ip)
    local redis = getRedis()
    local weeTs = getWeeTs()
    local ts = getClientTs()

    local logkey = "z"..getZoneId() .. ".loginlogout." .. weeTs    --  登入登出key
    local onlinekey = "z"..getZoneId() .. ".useronline." .. weeTs --在线同步数据
    local uidkey = "z"..getZoneId() .. ".uidmetric." .. weeTs --玩家数据缓存，同步的时候数据库压力大，存起来

    -- 登入的时候 更新 上次在线信息
    local lastOnlineTs = redis:hget(onlinekey, uid)
    local info = redis:hget(logkey, uid)

    info = json.decode( info ) or {}

    -- [登入时间，ip，登出时间]
    local data = {ts, ip, 0}

    -- 登陆的时候修正上次下线时间，拉取数据的时候最后修正一次
    if next(info) then
        local len = #info
        info[len][3] = lastOnlineTs
    end

    table.insert(info, data)

    redis:hset(logkey, uid, json.encode( info ))
    redis:expireat(logkey,weeTs+86400*2) -- 保留2天

    redis:hset(onlinekey, uid, ts+5)
    redis:expireat(onlinekey, weeTs+86400*2) -- 保留2天

    --玩家数据 没有 缓存起来
    local udata = redis:hget(uidkey, uid)
    if not udata then
        local uobjs = getUserObjs(uid)
        local mUserinfo = uobjs.getModel('userinfo')

        local uinfo = {mUserinfo.nickname, mUserinfo.email, mUserinfo.deviceid, mUserinfo.platid}
        redis:hset(uidkey, uid, json.encode( uinfo ))
        redis:expireat(uidkey, weeTs+86400*2)
    end

    return 0 
end

-- 记录登出信息
function updateOnline(uid)
    local redis = getRedis()
    local ts = getClientTs()
    local weeTs = getWeeTs()

    local onlinekey = "z"..getZoneId() .. ".useronline." .. weeTs
    redis:hset(onlinekey, uid, ts)
    redis:expireat(onlinekey, weeTs+86400*2) -- 保留2天

    return 0
end

-- 保存排行榜log
function writeActiveRankLog(message,path,st)
    st = st or 0
    if st<=0 then
        return true
    end
    message = message or ''
    if message=='' then
        return true
    end
    local date = st
    local zoneid = tonumber(getZoneId()) or 0
    local logpath = zoneid > 0 and getConfig("config.z".. zoneid ..".logpath") or "/tmp/"
    local path = path or 'active'
    local fileName = logpath .. path..zoneid..date .. '.log'
    if type(message) == 'table' then
        message = (json.encode(message) or '') 
    else
        message = message 
    end
   
    local f = io.open(fileName, "w+")
    if f then
        f:write(message)
        f:close()
    end
end

--读取排行榜log
function readRankfile(path,st)
    if st<=0 then
        return {}
    end
    local date = st
    local wtype ='r'
    local zoneid = tonumber(getZoneId()) or 0
    local logpath = zoneid > 0 and getConfig("config.z".. zoneid ..".logpath") or "/tmp/"
    local path = path or 'active'
    local fileName = logpath .. path..zoneid..date .. '.log'
    local file = io.open(fileName, "r")
    if file then
        local data = file:read("*a") -- 读取所有内容
        file:close()
        return json.decode(data) or {}
    end
    return {}
end

-- 世界等级
function addWorldLevelExp(addexp,Maxlvl)
    local key   = "zid."..getZoneId().."worldLevelExp"
    local lkey   = "zid."..getZoneId().."worldLevel"
    local redis  = getRedis()
    local lvl =tonumber(redis:get(lkey)) or 0
    if lvl>=Maxlvl then
        return  lvl,nil
    end
    --[[local exp =tonumber(redis:get(key))
    if exp==nil then
        local expinfo =getFreeData(key)
        if expinfo==nil then
            redis:set(key,0)
            exp=0
        else
            if type(expinfo)=='table' and next(expinfo) then
                exp=tonumber(expinfo.info)
                redis:set(key,exp)
            end
        end
    end]]--
    local newexp=tonumber(redis:incrby(key,addexp))
    -- 数据丢了要修复
    if newexp<=addexp then
        local expinfo =getFreeData(key)
        if expinfo~=nil and type(expinfo)=='table' then
            newexp=tonumber(redis:incrby(key,tonumber(expinfo.info)))
        end
    end
    local worldExp=getConfig("goldMineCfg.worldExp")
    if newexp>=worldExp[#worldExp] then
        redis:set(lkey,#worldExp)
        redis:set(key,worldExp[#worldExp])
        setFreeData(key,worldExp[#worldExp])
        return #worldExp,worldExp[#worldExp]
    else
        setFreeDataWorldExp(key,newexp,nil,addexp)
        local newlvl=lvl
        if newexp>=worldExp[lvl+1]  then
            for i=lvl+1,#worldExp do
                if newexp>=worldExp[i] then
                    newlvl=i
                end
            end
        end

        if newlvl>lvl  then
            redis:set(lkey,newlvl)
            setFreeData(lkey,newlvl)
        end
        return newlvl,newexp
    end
end

-- 世界等级
function updateWorldLevelExp(addexp,Maxlvl)
    local key   = "zid."..getZoneId().."worldLevelExp"
    local lkey   = "zid."..getZoneId().."worldLevel"
    local redis  = getRedis()
    local lvl =tonumber(redis:get(lkey)) or 0
    
    local exp =tonumber(redis:get(key))
    if exp==nil then
        local expinfo =getFreeData(key)
        if expinfo==nil then
            redis:set(key,0)
            exp=0
        else
            if type(expinfo)=='table' and next(expinfo) then
                exp=tonumber(expinfo.info)
                redis:set(key,exp)
            end
        end
    end
    local newexp=0
    if addexp<0 then
        newexp=tonumber(redis:decrby(key,math.abs(addexp)))
    else
        newexp=tonumber(redis:incrby(key,addexp))
    end
    local worldExp=getConfig("goldMineCfg.worldExp")
    if newexp>=worldExp[#worldExp] then
        redis:set(lkey,#worldExp)
        redis:set(key,worldExp[#worldExp])
        setFreeData(key,worldExp[#worldExp])
        return #worldExp,#worldExp
    else
        setFreeData(key,newexp)
        local newlvl=0
        for i=1,#worldExp do
            if newexp>=worldExp[i] then
                newlvl=i
            end
        end
        

        if newlvl~=lvl  then
            redis:set(lkey,newlvl)
            setFreeData(lkey,newlvl)
            return newlvl,newlvl
        end
    end
end

--获取世界等级
function getWorldLevel()
    local lkey   = "zid."..getZoneId().."worldLevel"
    local redis  = getRedis()
    local lvl=redis:get(lkey)
    if lvl==nil then
        local linfo =getFreeData(lkey)
        if type(linfo)=='table' and next(linfo) then
            lvl=tonumber(linfo.info)
            redis:set(lkey,lvl)
        else
            redis:set(lkey,0)
            lvl=0    
        end

    end
        
    return tonumber(lvl)
end

-- 获取世界等级的exp
function getWorldLevelExp()
    local key   = "zid."..getZoneId().."worldLevelExp"
    local redis  = getRedis()
    -- local exp =tonumber(redis:get(key)) or 0
    local exp =tonumber(redis:get(key))
    if exp==nil then
        local expinfo =getFreeData(key)
        if expinfo==nil then
            redis:set(key,0)
            exp=0
        else
            if type(expinfo)=='table' and next(expinfo) then
                exp=tonumber(expinfo.info)
                redis:set(key,exp)
            end
        end
    end
    return exp
end

-- 新加一个加载非用户数据model的方法
-- 用于整个请求过程中某些方法只执行一次
function loadModel(model,params)
    if not _ModelInstances[model] then
        _ModelInstances[model] = require(tostring(model))

        if _ModelInstances[model].init then
            _ModelInstances[model].init(params)
        end
    end

    return _ModelInstances[model]
end

-- 有的model写成了全局方法,比如大战用的serverBattle
-- 这种需要特殊处理,加载文件后需要运行该全局方法得到最终的model
function loadFuncModel(model)
    if not _ModelInstances[model] then
        require("model."..tostring(model))
        local func = "model_".. model
        if type(_ENV[func]) == "function" then
            _ModelInstances[model] = _ENV[func]()
        end
    end

    return _ModelInstances[model]
end

function getModelObjs(model,id,readOnly,safeMode)
    readOnly = readOnly and true or false
    if not id then readOnly = true end

    local key = string.format("%s-%s-%s",model,tostring(id),tostring(readOnly))
    local key1 = string.format("%s-%s",model,tostring(id))

    if not _ModelInstances[key] then
        if _ModelInstances[key1] then
            if readOnly then
                _ModelInstances[key] = _ModelInstances[key1]
            else
                if _ModelInstances[key1]._lock() then
                    _ModelInstances[key1]._setReadOnlyFlag(readOnly)
                    _ModelInstances[key] = _ModelInstances[key1]
                end
            end
        else
            require "lib.modelobjs"
            local obj = modelobjs(model,id,readOnly)
            _ModelInstances[key] = obj
            _ModelInstances[key1] = obj
        end
    end

    if not _ModelInstances[key] then 
        if not safeMode then
            error ({code=-100})
        end
    end

    return _ModelInstances[key]
end

function http_build_query(tb,prefix)
   local t = {}
   local prefix = prefix or '&'
   for k,v in pairs(tb) do
       table.insert(t,tostring(k) .. "=" .. tostring(v))
   end
   return table.concat(t,prefix)
end

function requestCheckAdmin(request)
    local cmdArray = string.split(request.cmd,"%.")
    if cmdArray[1] == 'admin' then
        local Filter = require "lib.filter"
        local ret = Filter.setAdminLog(request)
        if ret then
            return false, ret
        end
    end

    return true
end

--  每日捷报 出来结果的直接入库
function setDayNews(data)
    if switchIsEnabled('dnews') then
        local mDailyNews = loadModel("model.dailynews")
        mDailyNews.addArticle(data)
    end
end


-- 和谐版抽奖奖励
-- yunhe
-- 参数
-- hType 配置类型：active活动 funcs系统功能
-- name 活动名称或功能名称
-- times 奖励倍数
--sp 特殊处理标识 true or false
function harVerGifts(hType,name,times,sp)
    if type(times)~='number'  then times =1 end
    times = math.abs(times)
    local gifts = {}
    local giftCfg = getConfig('harmonyVersion')
    gifts = giftCfg.default["serverreward"]
    if type(giftCfg[hType][name])=='table' and next(giftCfg[hType][name]) then
        gifts = giftCfg[hType][name]["serverreward"]
        if sp then
            gifts=giftCfg[hType][name]["spserverreward"]--特殊处理
            times=1
        end
    end

    local reward = {}
    local clientReward = {}
    for k,v in pairs(gifts) do
        reward[v[1]] = (reward[v[1]] or 0)+v[2]*times
    end

    for k,v in pairs(reward) do
        table.insert(clientReward, formatReward({[k]=v}))
    end

    return reward,clientReward
end

-- 和谐抽奖功能配置列表,且包含默认配置(登陆调用)
function getHarFunsCfg(hType)
    local funcsCfg = getConfig('harmonyVersion')
    local r = {}
    for k,v in pairs(funcsCfg[hType]) do
        r[k] = v["reward"]
    end
    r["default"] = funcsCfg.default["reward"]

    return r
end

-- 获取用户的邀请码
-- 某些活动中,需要参与用户有一个唯一标识
-- 没有查换到时会生成一个
-- param int uid 用户ID
-- param string name 邀请码的名称(不同功能需要不一样的邀请码时可以变更名称),如果相同活动每次开都需要新的邀请码,可以变更name来重新生成
-- return int 
function getUserInviteCode(uid,name)
    local inviteCode
    name = name or "_common"

    local db = getDbo()
    local res = db:getRow("select id,code from invitecode where uid = :uid and name = :name limit 1",{uid=uid,name=name})
    if not res then
        local function _getCode()
            local code = {}
            local codeLength = 6
            local characters = {
                'A','B','C','D','E','F','G',
                'H','I','J','K','L','M','N',
                'O','P','Q','R','S','T',
                'U','V','W','X','Y','Z',
                '1','2','3','4','5','6','7','8','9','0'
            }
            setRandSeed()
            for i=1,codeLength do
                local k = rand(1,#characters)
                table.insert(code,characters[k])
                table.remove(characters,k)
            end
            code = table.concat(code,"")
            return code
        end

        local code = _getCode()
        res = db:insert("invitecode",{uid=uid,name=name,code=code,updated_at=getClientTs()})
        if res then 
            inviteCode = code
        end
    else
        inviteCode = res.code
    end

    return inviteCode
end

-- 按邀请码找到对应的uid
function getUidByInviteCode(code)
    local db = getDbo()
    local res = db:getRow("select uid from invitecode where code = :code limit 1",{code=code})
    local uid = res and tonumber(res.uid)

    return uid
end

-- 随机
-- probability: {1,3,5,3,1} 权重
function randVal(probability)
    local newTb = {}
    local total = 0
    local r = 0
    if type(probability) == 'table' then
        for k,v in pairs(probability) do
            total = total + v
            table.insert(newTb,total)
        end

        setRandSeed()
        local rd=rand(1,total)
        for k,v in pairs(newTb) do
            if rd<=v then
                r = k
                break
            end
        end
    end

    return r
end

-- 记录请求次数
-- 达到指定次数 发邮件
function recordRequest(uid,recordkey,params)
    local uid = tonumber(uid) or 0
    local date = os.date('%m%d')
    local redis = getRedis()
    local zoneid = getZoneId()
    local key = "z"..zoneid..".recordRequest."..date..'.'..uid

    local log = json.decode(redis:get(key))
    if type(log)~='table'  then
        log = {}
    end

    if type(log[recordkey])~='table' then
        log[recordkey] = {}
    end

    local cmdinfo = getRequestCmd()
    local cmd = cmdinfo[1]

    local config = getConfig('recordCfg')
    if type(config[recordkey])~='table' then
        return false
    end
    -- 需要过滤的白名单  
    local whitelist = getConfig('whitelist')
    local plat = getClientPlat()
    if plat =='def' then
        return false
    end
    if type(whitelist[plat])=='table' and table.contains(whitelist[plat],uid) then  
        return false
    end


    local aviodcmd = {
        'firstRecharge',
        'rechargefight',
        'xuyuanlu',
    }
    local jsoncmd = json.encode(cmdinfo)
    for k,v in pairs(aviodcmd) do
        if string.find(jsoncmd,v) then
            return false
        end
    end  

    local title = config[recordkey][1] or '无标题'
    local content = config[recordkey][2] or '无内容'
    local limit  = config[recordkey][3] or 0
    local single = config[recordkey][4] or 0
    -- 大于900 的服为线上测试服 不需要记录
    if limit > 0 and zoneid<900 and zoneid>0 then
        local cur = (tonumber(log[recordkey]['num']) or 0) +1
        local flag = false
        if single>0 and params.num>single then
            flag = true
        end
        local divisor = 10
        if table.contains({"p236","p420"},recordkey) then
	       divisor = 1
        elseif table.contains({"p679"},recordkey) then
            divisor = 5
        end

        local n = cur%divisor  
        if cur >= limit and n==0 or flag then
            local uobjs = getUserObjs(uid)
            local mUserinfo = uobjs.getModel('userinfo')
            -- 内部号不发邮件
            if mUserinfo.flags.inner then
                return false
            end

            if string.find(jsoncmd,'pay.processorder') and table.contains({8820,17810,26718},params.num)  then
                return false
            end 
            -- 发邮件
            local http = require("socket.http")
            http.TIMEOUT= 1

            local postdata = {
                plat = plat,--平台
                zid = zoneid,
                uid = uid,
                nickname = mUserinfo.nickname,
                event = content,
                cur = cur,--当前次数
                cmd = json.encode(cmdinfo),
                getnum = params.num,--当前获取数量
                ip = mUserinfo.ip,--ip
                title=title,
            }

            if flag then
                postdata.event = '超过单次获得配置值'..single
            end
            
            local tankExtUrl = getConfig("config.z".. zoneid ..".tankExtUrl") .. "mail/sendmail/email?"
            local respbody, code = http.request(tankExtUrl,formPostData(postdata))
        end

        if cur > limit or flag then
            local db = getDbo()
            local requestLog = {
                uid = uid,
                recordkey = recordkey,
                cmd = cmd,
                request = cmdinfo,
                value = params,
                updated_at = getClientTs(),
            }

            local ret = db:insert('requestlog',requestLog)  
        end
        

        -- 记录缓存
        log[recordkey]['num'] = cur 
        log[recordkey][cmd] = cur
        redis:set(key,json.encode(log))
        redis:expire(key,86400)
    end
end

--排序
function getsort(tab)
    table.sort(tab, function( a,b )
        local r
        local auid = tonumber(a[1])
        local buid = tonumber(b[1])
        local ast = tonumber(a[2])
        local bst = tonumber(b[2])
        local akm = tonumber(a[3])
        local bkm = tonumber(b[3])
        if akm == bkm then
            if ast == bst then
                r = auid < buid
            else
                r = ast < bst
            end
        else
           r = akm > bkm
        end
        return r
    end )
    return tab
end


--跨服排行榜
function crossserverrank(params)
    local http = require("socket.http")
    http.TIMEOUT= 5
    local crossrank=getConfig("config.crossrank")
    local url = "http://"..crossrank.httphost.."/tank-server/public/index.php/api/areateamwar/crossrank?"
    local action = params.action or 1
    local postdata = {action=action,params=json.encode(params)}
    local respbody = http.request(url,formPostData(postdata))
    respbody = json.decode(respbody)
    if respbody.ret ~= 0 then
        return false
    end
    return true                
end

--获取跨服排行榜
function crossserverranklist(st,acname)
    local result = {}
    local http = require("socket.http")
    http.TIMEOUT= 5

    local crossrank =getConfig("config.crossrank")
    local url = "http://"..crossrank.httphost.."/tank-server/public/index.php/api/areateamwar/crossrank?"
    local postdata = {action=2,st=st,acname=acname}
    local res = http.request(url,formPostData(postdata)) 
    res = json.decode(res)
    if res.ret == 0 then
       result = res.data
    end  
    return result                
end



-- 更新跨服战资比拼数据
function zzbpupdate(uid,params)
    local ts = getClientTs()

    require "model.zzbp"
    local zzbp = model_zzbp()
    local  flag,cfg = zzbp.check()

    if not flag then
        return false
    end

    -- 能否加积分  活动开启时间到第二天的22点
    if ts<tonumber(cfg.st) or ts>(tonumber(cfg.et)-86399-7200) then
        return false
    end

    -- 根据活动第几天 生成相应的任务数据和商店列表
    local st = tonumber(cfg.st) or 0
    local currDay = math.floor(math.abs(ts-getWeeTs(st))/(24*3600)) + 1
    local taskpool = json.decode(cfg.task)
  
    -- 每天配置的任务不同  从taskpool下标取
    if type(taskpool[currDay])~='table' or not table.contains(taskpool[currDay],params.t) then
        return false
    end
    
    local uobjs = getUserObjs(uid)
    uobjs.load({"userinfo","zzbpuser"})
    local mUserinfo = uobjs.getModel('userinfo')
    local mZzbpuser = uobjs.getModel('zzbpuser')
   
    local zzbpCfg = getConfig("zzbp")
    local taskCfg = zzbpCfg[tonumber(cfg.cfgid)].taskList[params.t]
    if zzbpCfg[tonumber(cfg.cfgid)].levelLimit>mUserinfo.level then
        return false
    end

    if type(taskCfg)~='table' then
        return false
    end

    -- 根据task类型取出积分配置
    -- 计算当前任务获得积分数
    local score =  mZzbpuser.getScore(taskCfg,params)
    if score <=0 then return false end

    local day = 'd'..currDay
    local exparams = {level=mUserinfo.level,nickname=mUserinfo.nickname,day=day,score=score}
    -- 更新玩家的积分
    mZzbpuser.upscore(params,cfg,exparams)

    return true
end

-- 获取跨服战资比拼个人积分排行榜
function zzbppersonalrank(cfg)
    local zzbpCfg = getConfig("zzbp")
    local limitscore = zzbpCfg[tonumber(cfg.cfgid)].rLimit

    local http = require("socket.http")
    http.TIMEOUT= 5
    local crossrank = getConfig("config.crossrank")
    local url = "http://"..crossrank.httphost.."/tank-server/public/index.php/api/zzbp/zzbp?"

    local senddata = {groupid=tonumber(cfg.groupid),ls=limitscore}

    local postdata = {action=2,params=json.encode(senddata)}
    local respbody = http.request(url,formPostData(postdata))
    respbody = json.decode(respbody)

    if type(respbody.data)~='table' then
        return {}
    end
    return respbody.data
end


-- 获取跨服战资比拼积分第一的服
function getzzbpfirstserver(cfg)
    local http = require("socket.http")
    http.TIMEOUT= 5
    local crossrank = getConfig("config.crossrank")
    local url = "http://"..crossrank.httphost.."/tank-server/public/index.php/api/zzbp/zzbp?"


    local senddata = {groupid=tonumber(cfg.groupid)}

    local postdata = {action=3,params=json.encode(senddata)}
    local result = http.request(url,formPostData(postdata))
    result = json.decode(result)
    if type(result)~='table' then
        return {zid=0,s=0}  -- zid服务器id s积分
    end
    
    return result.data
end



-- 前端聊天变色
-- model  字段值
function getGmChat(model)
    local redis = getRedis()
    local key="z"..getZoneId()..".free."..model
    local ret = json.decode(redis:get(key))
    if ret==nil then
        local data=getFreeData(model)
        if data~=nil then
            ret=data.info
        else
            ret={}
        end
        redis:set(key,json.encode(ret))
        redis:expire(key,86400)
    end

    return ret
end

-- 后台修改GM玩家
function renameGM(uid,nickname)
    local response = {
        ret=-1,
        msg='error',
        data = {},
    }

    if not uid or not nickname then
        response.ret = -102
        return response
    end
    if string.len(nickname) < 2 or string.len(nickname) > 40 then
        response.ret = -103
        response.msg = 'nickname invalid'
        return response
    end
    if match(nickname) then
        response.ret = -8024
        return response
    end
    local uobjs = getUserObjs(uid)
    uobjs.load({"userinfo","props"})
    local userinfo = uobjs.getModel('userinfo')
    if userinfo.nickname == nickname then
        response.ret = 0
        response.msg = "success"
        return response
    end
    if userGetUidByNickname(nickname) <= 0  then
        userinfo.nickname = nickname

        local renameMap = function(uid, nickname)
            local db = getDbo()
            local result = db:getRow("select id,type,oid from map where type = :type and oid = :oid",{type=6, oid=uid})
            if result then
                db:update("map", {name=nickname}, "id=" .. result['id'])
            end
        end
        --修改地图名称
        renameMap(uid, nickname)
        --修改军团名称
        if tonumber(userinfo.alliance) > 0 then
            local joinAtData,code = M_alliance.admin{uid=uid,aid=userinfo.alliance,nickname=nickname }
            if type(joinAtData) ~= 'table' or joinAtData['ret'] ~= 0 then
                return response
            end
        end

        processEventsBeforeSave()

        if uobjs.save() then
            processEventsAfterSave()
            response.ret = 0
            response.msg = "success"
        end
    end

    return response
end

-- 发送邮件至qq企业邮箱（警报邮件）
function sendqqemail(params)
    local http = require("socket.http")
    http.TIMEOUT= 1
    local postdata = {
        plat = params.plat,--平台
        zid  = params.zid,
        uid  = params.uid or 0,
        nickname = params.nickname,
        event = params.event,
        cur = params.cur or 0,
        cmd = params.cmd,
        getnum = params.getnum,
        ip = params.ip,
        title = params.title,
    }

    local tankExtUrl = getConfig("config.z".. params.zid ..".tankExtUrl") .. "mail/sendmail/email?"
    local respbody, code = http.request(tankExtUrl,formPostData(postdata))
end

-- 德国召回活动
-- senddata:参数
-- act:1创建召回码 2 流失玩家绑定活跃玩家  3 更新跨服流失玩家数 4 拉取绑定活跃玩家的流失玩家数据
function gerrecallrequest(senddata,act)
    local http = require("socket.http")
    http.TIMEOUT= 5
    local crossrank = getConfig("config.crossrank")
    local url = "http://"..crossrank.httphost.."/tank-server/public/index.php/api/active/gerrecall?"
    local ts = getClientTs()
    local postdata = {act=act,params=json.encode(senddata),sign=require("lib.crossActivity").kuafuSign(ts),ts=ts}
 
    local respbody = http.request(url,formPostData(postdata))
    return respbody
end


-- 更新个人成就数据
-- model：model字符串
-- dtype：更新的数据的类型
function updatePersonAchievement(uid,aidTb)
    if moduleIsEnabled('avt') == 1 and uid and type(aidTb) == "table" and next(aidTb) then
        local achievementCfg = getConfig("achievement")
        local uobjs = getUserObjs(uid)
        local mAchievement = uobjs.getModel("achievement")
        local updatedata,senddata = {},{}
        for _,aid in pairs(aidTb) do
            if aid and achievementCfg and achievementCfg.person and achievementCfg.person[aid] and uobjs then
                local cfg = achievementCfg.person[aid]
                if cfg and cfg.type then
                    local model = cfg.type
                    local needType = cfg.needType
                    local subType = cfg.subType
                    local mModel = uobjs.getModel(model)
                    if mModel and mModel.getAchievementData then
                        local num = mModel.getAchievementData(needType,cfg,subType)
                        updatedata[aid] = num

                        local oldnum = mAchievement.uinfo[aid] or 0
                        for k,v in pairs(cfg.needNum) do
                            if oldnum < v and num and num >= v then
                                senddata[aid] = num
                                break
                            end
                        end
                    end
                end
            end
        end

        if next(updatedata) then
            mAchievement.setAchieveData(updatedata)
        end
        if next(senddata) then
            regSendMsg(uid,'avt.change',{achievement={uinfo=senddata}})
        end
    end
end

-- 获取全服成就数据
-- aid：有aid则取本系列数据，无aid则取所有数据
function getAllAchievement(aid)
    if aid then
        local all = {0,0,0}
        local update = {}
        local redis = getRedis()
        local key = "achievement"
        for k,v in pairs(all) do
            local redisKey = "z"..getZoneId()..".free."..key.."."..aid.."."..k
            local ret = redis:get(redisKey)
            if ret then
                all[k] = tonumber(ret) or 0
            else
                update[tostring(k)] = 1
            end
        end
        if next(update) then
            local data = getFreeData(key)
            if data and type(data) == "table" and data.info and data.info[aid] then
                local info = data.info[aid]
                for k,v in pairs(info) do
                    if update[tostring(k)] and v then
                        all[tonumber(k)] = tonumber(v) or 0

                        local redisKey = "z"..getZoneId()..".free."..key.."."..aid.."."..k
                        redis:set(redisKey,tonumber(v) or 0)
                    end
                end
            end
        end
        return all
    else
        local all = {}
        local aidTb = {}
        local achievementCfg = getConfig("achievement")
        local needDb,update = false,{}
        local redis = getRedis()
        local key = "achievement"
        for k,v in pairs(achievementCfg.all) do
            if not update[k] then
                update[k] = {}
            end
            if not all[k] then
                all[k] = {}
            end
            for kk,vv in pairs(v.num) do
                if not update[k][kk] then
                    update[k][kk] = 0
                end
                if not all[k][kk] then
                    all[k][kk] = 0
                end
                local redisKey = "z"..getZoneId()..".free."..key.."."..k.."."..kk
                local ret = redis:get(redisKey)
                if ret then
                    all[k][kk] = tonumber(ret) or 0
                else
                    update[k][kk] = 1
                    needDb = true
                end
            end
        end
        if needDb then
            local data = getFreeData(key)
            if data and type(data) == "table" and data.info and next(data.info) then
                for k,v in pairs(data.info) do
                    for kk,vv in pairs(v) do
                        if update[k] and update[k][tonumber(kk)] == 1 then
                            all[k][tonumber(kk)] = tonumber(vv) or 0

                            local redisKey = "z"..getZoneId()..".free."..key.."."..k.."."..kk
                            redis:set(redisKey,tonumber(vv) or 0)
                        end
                    end
                end
            end
        end
        return all
    end
end
-- 更新全服成就数据
function setAllAchievement(aid,info)
    if moduleIsEnabled('avt') == 1 and aid and info and next(info) then
        local redis = getRedis()
        local key = "achievement"
        local data = getAllAchievement()
        if not data then
            data = {}
        end
        if not data[aid] then
            data[aid] = {0,0,0}
        end
        for k,v in pairs(info) do
            local redisKey = "z"..getZoneId()..".free."..key.."."..aid.."."..k
            local incr = redis:incr(redisKey)
            if incr then
                data[aid][tonumber(k)] = incr
            end
        end
        if setFreeData(key,data) then
            return true
        end
    end
    return false
end

-- 根据坐标算方位
function getMineDirection(x,y)
    local directionTb={{0,200,0,200},{200,400,0,200},{400,600,0,200},{0,200,200,400},{200,400,200,400},{400,600,200,400},{0,200,400,600},{200,400,400,600},{400,600,400,600}}
    local direction=1
    for dir,pos in pairs(directionTb) do
        if x>pos[1] and x<=pos[2] and y>pos[3] and y<=pos[4] then
            direction=dir
            do break end
        end
    end
    return direction
end

-- 系统抽奖记录 
--[[
    type：抽奖类型
    name: 功能名称
    params={reward:常规奖励,hreward:和谐版奖励}
    rformat:常规奖励是否已经执行过奖励格式化处理
    hrformat:和谐版奖励是否已经执行过奖励格式化处理
]]
function setSysLotteryLog(uid,lotterytype,name,num,params,rformat,hrformat)
    local reward = {}
    local hreward = {}
    local flag = false
    if type(params.r)=='table' and next(params.r) then
        if not rformat then
            for k,v in pairs(params.r) do
                table.insert(reward,formatReward({[k]=v}))
            end
        else
            reward = params.r
        end
      
        flag = true
    end

    if type(params.hr)=='table' and next(params.hr) then
        if not hrformat then
            for k,v in pairs(params.hr) do
                table.insert(hreward,formatReward({[k]=v}))
            end
        else
            hreward = params.hr
        end
       
        flag = true
    end

    if not flag then return false end

    local ts = getClientTs()
    local redis =getRedis()
    local redkey ="zid."..getZoneId().."lotterylog_"..name..uid
    local data =redis:get(redkey)
    data =json.decode(data)
    if type (data)~="table" then data={} end   
    table.insert(data,1,{ts,lotterytype,reward,hreward,num}) -- 生成时间 抽奖类型 常规奖励 和谐版奖励 抽取次数
    if next(data) then
        for i=#data,11,-1 do
            table.remove(data)
        end

        data=json.encode(data)
        redis:set(redkey,data)
        redis:expireat(redkey,ts+7*86400)
    end  
end

--[[
    客户端需要的活动内道具格式
    reward活动奖励  {xx=1}
]]
function formatActiveReward(aname,rewards)
    local formatreward = {}
    formatreward[aname] = {}
    if type(rewards) == 'table' then
        for k,v in pairs(rewards) do
            formatreward[aname][k] = v
        end 
    end
    return formatreward
end

