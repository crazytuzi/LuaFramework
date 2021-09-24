--[[
	执行一组过滤器时,某个过滤器有返回值时,后面的过滤器不会执行
	过滤器返回值ret不为0时,api不会执行,但routeCfg中配置的after过滤器会继续执行
]]
local Filter = {}

function Filter.getFilterByFuncname(funcname)
    return type(Filter[funcname]) == "function" and Filter[funcname]
end

function Filter.run(filters, parameters)
    if type(filters) == "table" then
        for funcname, routeParams in pairs(filters) do
            local filter = Filter.getFilterByFuncname(funcname)
            if filter then
                local response = filter(parameters, routeParams)
                if response then return response end
            end
        end
    end
end

function Filter.runApiFilters(filters, parameters)
    for funcname, filter in pairs(filters) do
        filter(parameters)
        filters[funcname] = nil
    end
    
    filters = nil
end

-- -----------------------------------------------------------------------------
-- filter callback 
-- -----------------------------------------------------------------------------

-- 出兵时检测飞机
function Filter.usePlaneCheck(request)
    local plane = request.params.plane
    local uobjs = getUserObjs(tonumber(request.uid))
    local mPlane = uobjs.getModel('plane')

    if plane then
        if not mPlane.checkFleetPlaneStats(plane) then
            return { ret = -12110 }
        end
    end

    -- 本次请求带来的超级装备 
    mPlane.setBringPlaneId(plane)
end

-- 出兵时检测出兵信息
function Filter.troopsCheck(request)
    if not request.params.fleetinfo or #request.params.fleetinfo ~= 6 then
        return { ret = -102 }
    end
    
    local num = 0
    for m, n in pairs(request.params.fleetinfo) do
        if next(n) then
            n[1] = 'a' .. n[1]
            num = num + n[2]
        end
    end
    
    if num <= 0 then
        return { ret = -102 }
    end
end

-- 检测功能开关
function Filter.switchsCheck(request,switchs)
    for _,switch in ipairs(switchs) do
        if not switchIsEnabled(switch) then
            return {ret = -180}
        end
    end
end

function Filter.setAdminLog(request)
    local adminLib = require "lib.adminlib"
    local toolApi,platformApi,cronApi = adminLib.getAdminApi()

    -- 非系统调用的api全部记下日志
    if not cronApi[request.cmd] then
        local db = getDbo()
        request.ip = tostring(getClientIP())
        local log = json.encode(request)
        if not db:insert("adminlog",{requestlog=log,updated_at=getClientTs()}) then
            return {ret = -106}
        end
        
        if not platformApi[request.cmd] then
            if not adminLib.check(request) then
                return {ret = -101}
            end
        end
    end

    -- -- 管理工具过来的API还需要验证
    -- if toolApi[request.cmd] then
    --     if not adminLib.check(request) then
    --         return {ret = -101}
    --     end
    -- end

    -- 这个接口特殊,管理工具和港台平台都在调
    -- 用adminname来判断是否是管理工具过来的,是的话走管理工具验证,不是的话只给港台平台开放
    -- if request.cmd == "admin.addprop" then
    --     if request.adminname then
    --         if not adminLib.check(request) then
    --             return {ret = -101}
    --         end
    --     elseif getClientPlat() ~= 'efun_tw' then
    --         return {ret = -101}
    --     end
    -- end
end


function Filter.checkRayapiToken(request)
    local eventId = request.params.event_id
    local token =request.params.token
    if not eventId or not token then 
        return {ret = -124, msg1="not token"} 
    end

    -- appid用来取配置,默认是"0"
    local appid = "0"

    -- 3kwan平台混过来了其它的平台用户,验证地址不一样,需要处理一下
    local clientPlat = tostring(getClientPlat())
    if clientPlat == "ship_3kwan" then
        local uobjs = getUserObjs(tonumber(request.uid))
        local mUserinfo = uobjs.getModel('userinfo')
        appid = tonumber(mUserinfo.email) or 0
        appid = tostring(math.floor(appid/1000))
    end

    local payServerCfg = getConfig('payServerCfg')
    if payServerCfg.rayapiUrl then
        local url = payServerCfg.rayapiUrl[appid] or payServerCfg.rayapiUrl["0"]

        local param = http_build_query({event_id=eventId,token=token})

        local http = require("socket.http")
        http.TIMEOUT= 5

        local sendret,code = http.request(url .. param)
        sendret = sendret and json.decode(sendret)

        if type(sendret) ~= "table" then
            return {ret = -124,rcode=code,msg1=tostring(sendret)}
        elseif sendret.code ~= 0 or sendret.msg ~= "success"  then
            return {ret = -124,rcode=code,msg2=json.encode(sendret)}
        end
    end
end

-- 侦察的验证码处理
function Filter.scoutCaptcha(request)
    if not switchIsEnabled("check2") then
        return
    end
    
    local response = {
        ret=-1,
        msg='error',
        data = {},
    }

    local zid = getZoneId()
    local uid = request.uid
    local ts = os.time()
    local scoutCfg = getConfig("scoutCfg")
    
    local hour = os.date("%H")
    local minute = math.floor(os.time()/scoutCfg.validate.validateTime)
    local scoutTimesKey = string.format("z%s.scouttimes.%s.%s",zid,getWeeTs(),uid)
    local scoutInfoKey = string.format("z%s.scoutinfo.%s",zid,uid)
    
    local redis = getRedis()
    local scoutInfo = redis:hgetall(scoutInfoKey)

    local resetField = {"lock","text","time","ts","answer","getnum"}
    if scoutInfo.lock then
        if tonumber(scoutInfo.lock) >= ts then
            response.data.captcha=false
            response.data.captchaTs = scoutInfo.lock
            return response
        elseif tonumber(scoutInfo.lock) < ts then
            redis:tk_hmdel(scoutInfoKey,resetField)
            redis:hdel(scoutTimesKey,"total")
            scoutInfo = {}
        end
    end

    scoutInfo.ts = tonumber(scoutInfo.ts) or 0

    -- 玩家输入了验证码
    if request.params.captcha and scoutInfo.ts >= ts and tostring(scoutInfo.answer) == tostring(request.params.captcha) then
        -- 清除锁定和答题信息
        redis:tk_hmdel(scoutInfoKey,resetField)

        -- 清除已侦察的次数
        redis:tk_hmdel(scoutTimesKey,{minute,"total"})

        -- 记录玩家验证成功的次数,这个次数如果大于了阀值,要锁定
        local validateOk = redis:hincrby(scoutTimesKey,hour,1)
        if validateOk > scoutCfg.validate.validateLimit then
            redis:hset(scoutInfoKey,"lock",ts + scoutCfg.validate.punishTime)
        end
        
        -- 验证成功奖励
        if redis:hincrby(scoutInfoKey,"reward",1) <= scoutCfg.validate.rewardLimit then
            takeReward(uid,scoutCfg.validate.bingoReward.serverreward)
            response.data.captchaReward = scoutCfg.validate.bingoReward.reward

            response.ret = 0
            response.msg = 'Success'
            return response
        end

    -- 正常侦察/验证未通过
    else
        local validate = false

        -- 如果有验证次数,必需传captcha走验证的逻辑
        -- 1、没有验证通过
        -- 2、直接没有验证
        if scoutInfo.time then
            if tonumber(scoutInfo.time) >= 2 then
                redis:hset(scoutInfoKey,"lock",ts + scoutCfg.validate.punishTime)
                response.ret = -5020 -- 验证码未通过,不能侦察
                return response
            elseif tonumber(scoutInfo.time) == 1 then
                validate = true
            end
        end

        -- 侦察次数检测 -----------------
        -- n每两分,n1是每天总的侦察次数
        local n = redis:hincrby(scoutTimesKey,minute,1)
        local n1 = redis:hincrby(scoutTimesKey,"total",1)
        redis:expire(scoutTimesKey,86400)
        if (n > scoutCfg.validate.validateNum) or (n1 > scoutCfg.validate.sumNum) then
            validate = true
        end

        if validate then
            setRandSeed()
            local validInfo = {}
            if rand(1,100) <= scoutCfg.validate.typeRatio[1] then
                local n1 = rand(1,75) + 50
                local n2 = rand(1,75) + 50
                response.data.question = string.format("%s+%s=",n1,n2)
                validInfo.ts = ts + scoutCfg.validate.timeLimit[1]
                local answer = n1 + n2

                validInfo.answer = rand(1,4)
                local answersOffset = {-1,-2,1,2}
                local text = {
                    [validInfo.answer] = answer
                }

                for i=1,4 do
                    if i ~= validInfo.answer then
                        local n = rand(1,#answersOffset)
                        text[i] = answer + table.remove(answersOffset,n) 
                    end
                end

                validInfo.quesType=1
                validInfo.text = json.encode(text)
            else
                local quesIdx = rand(1,#scoutCfg.question)
                response.data.question = scoutCfg.question[quesIdx].ques
                validInfo.ts = ts + scoutCfg.validate.timeLimit[2]
                validInfo.answer = rand(1,4)

                local answers = copyTable(scoutCfg.question[quesIdx].answer)
                local text = {
                    [validInfo.answer] = table.remove(answers,1)
                }

                for i=1,4 do
                    if i ~= validInfo.answer then
                        text[i]= table.remove(answers,rand(1,#answers))
                    end
                end

                validInfo.quesType=2
                validInfo.text = json.encode(text)
            end

            validInfo.getnum = 0
            redis:hmset(scoutInfoKey,validInfo)
            redis:hincrby(scoutInfoKey,"time",1)
            redis:expire(scoutInfoKey,86400)
	
            response.data.captcha = true
            response.data.captchaTs = validInfo.ts
            return response
        end
    end
end

return Filter