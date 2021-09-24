local function getCacheKey()
    return string.format("z%s.friends.send.%s",getZoneId(),getWeeTs())
end

-- 几种红包共享次数了，不再管pid了
local function getFlag(...)
    return string.format("%s-prop",...)
end

local function getReceivedNum(uid,pid)
    local redis = getRedis()
    local cacheKey = getCacheKey()
    local flag = getFlag(uid,pid)
    local ret = tonumber(redis:hincrby(cacheKey,flag,1))
    redis:expireat(cacheKey,getWeeTs()+86400*7)

    return ret
end

local function checkReceiveStatus(fUid,pid)
    if pid == "p3306" then
        return getReceivedNum(fUid,pid) <= 5
    end
end

local sendFunc = {}
sendFunc.fsend_p3306 = function(fUid,sender, num)
    local pid = "p3307"
    num = tonumber(num) or 1

    local item={
        h={
            ["props_p3307"]=num
        },
        q={
            p={
                {[pid]=num},
            }
        },
        f={0},
    }

    local title=50
    local content={type=50,name=sender}
    local ret = MAIL:mailSent(fUid,1,fUid,sender,'',title,content,1,0,2,item)

    return true
end

sendFunc.fsend_p3309 = function(fUid,sender, num)
    local pid = "p3310"
    num = tonumber(num) or 1

    local item={
        h={
            ["props_p3310"]=num
        },
        q={
            p={
                {[pid]=num},
            }
        },
        f={0},
    }

    local title=50
    local content={type=50,name=sender}
    local ret = MAIL:mailSent(fUid,1,fUid,sender,'',title,content,1,0,2,item)

    return true
end

sendFunc.fsend_p3311 = function(fUid,sender, num)
    local pid = "p3312"
    num = tonumber(num) or 1

    local item={
        h={
            ["props_p3312"]=num
        },
        q={
            p={
                {[pid]=num},
            }
        },
        f={0},
    }

    local title=50
    local content={type=50,name=sender}
    local ret = MAIL:mailSent(fUid,1,fUid,sender,'',title,content,1,0,2,item)

    return true
end

local function getCurrReceivedNum(uid,pid)
    local redis = getRedis()
    local cacheKey = getCacheKey()
    local flag = getFlag(uid,pid)
    local cnt = tonumber(redis:hget(cacheKey,flag)) or 0
    cnt = cnt > 5 and 5 or cnt

    return cnt
end

local function setMultReceivedNum(params, pid)
    local redis = getRedis()
    local cacheKey = getCacheKey()
    
    for uid, num in pairs(params) do
        if num > 0 then
            local flag = getFlag(uid,pid)
            redis:hincrby(cacheKey, flag, num)
        end
    end
    return true
end

local function processSendMult(uid, fuids, pid)
    local uobjs = getUserObjs(uid)
    local mBag      = uobjs.getModel('bag')
    local mUserinfo = uobjs.getModel('userinfo')

    local cnt = 0
    local ret = {}
    for fUid, num in pairs(fuids) do
        local leftNum = 5 - getCurrReceivedNum(fUid,pid)
        num = num > leftNum and leftNum or num
        num = num > 0 and num or 0
        cnt = cnt + num
        ret[fUid] = num
    end
    if not next(ret) then
        return true, ret
    end
    local f = "fsend_" .. pid
    if type(sendFunc[f]) ~= 'function' then
        return false, -1
    end

    --送红包给慷慨值
    activity_setopt(uid,'rechargebag',{send=cnt,pid=pid})

    if not mBag.use(pid, cnt) or not uobjs.save() then
        return false, -2036
    end

    setMultReceivedNum(ret, pid)
    for fUid, num in pairs(ret) do
        if num > 0 then
            sendFunc[f](fUid,mUserinfo.nickname, num)
        end
    end

    return true, ret
end

function api_friends_send(request)
    local response = {
        ret=0,
        msg='Success',
        data = {},
    }

    local uid = request.uid
    local fUid = request.params.fUid
    local pid = request.params.pid
    if uid == nil or pid == nil then
        response.ret = -102
        return response
    end

    pid = 'p' .. pid

    local uobjs = getUserObjs(uid)
    uobjs.load({"userinfo", "techs", "props","bag","dailytask","task"})
    local mUserinfo = uobjs.getModel('userinfo')
    local mBag      = uobjs.getModel('bag')

    -- 批量处理
    local action = tonumber(request.params.action) or 0
    if action == 1 then
        response.data.left = 5 - getCurrReceivedNum(fUid, pid)
        response.ret = 0        
        response.msg = 'Success'
        return response
    elseif action == 2 then
        local fuids = request.params.fUids 
        local ret, code = processSendMult(uid, fuids, pid)
        if ret then
            response.data.bag = mBag.toArray(true)
            response.data.result = code
            response.msg = 'Success'
        else
            response.msg = 'error'
            response.ret = code
        end
        return response
    end    

    -- 不能送给自己
    if uid == fUid then
        response.ret=-2012
        return response
    end

    local use = mBag.use(pid,1)
    if not use then
        response.ret=-1996
        return response
    end

    -- 对方收礼达到每日上限
    if not checkReceiveStatus(fUid,pid) then
        response.ret=-2035
        return response
    end
    --送红包给慷慨值
    activity_setopt(uid,'rechargebag',{send=1})
    if uobjs.save() then 
        local f = "fsend_" .. pid

        if type(sendFunc[f]) == 'function' then
            sendFunc[f](fUid,mUserinfo.nickname)
        end

        response.data.bag = mBag.toArray(true)

        response.ret = 0        
        response.msg = 'Success'
    end

    return response
end
