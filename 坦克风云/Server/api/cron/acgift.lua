--  活动发奖
function api_cron_acgift(request)
    local response = {
        ret=-1,
        msg='error',
        data = {},
    }
    local redis =getRedis()
    local cachekey = "zid."..getZoneId().."levelopencache"
    local cachekeydata = redis:get(cachekey)
    cachekeydata =json.decode(cachekeydata)
    if cachekeydata ~= nil then
        response.ret = -102
        return response
    end
    local acname = 'levelopen' 
    local zoneid = getZoneId()
    -- 活动检测
    local db = getDbo()
    local result = db:getRow("select st,cfg,et from active where name=:acname",{acname=acname}) 
    if result == nil then
        response.ret = -102
        return response
    end
    local cfg = tonumber(result.cfg)
    local acst = result.st
    local et = tonumber(result.et) 
    local st = et - 86400 
    local ts = getClientTs()
    if ts < st or ts > et then
        response.ret = -102
        return response
    end 
    local activeCfg = getConfig("active/"..acname)[cfg]
    local myrank=0
    local name 
    local ranklist = crossserverranklist(acst,acname)
    -- ptb:e(ranklist)
    if type(ranklist)=='table' and next(ranklist) then
        for k,v in pairs(ranklist) do
            local mid= tonumber(v.zoneid)
            if mid==zoneid then
                myrank=k
                name = v.nickname
            end
        end
    end  
    if myrank<=0 then
        response.ret=-1980
        return response
    end
    local rankreward = {}
    for k,v in pairs(activeCfg.section) do
        if myrank<=v[2] then
            rankreward=activeCfg.serverreward["srank"..k]
            break
        end
    end
    -- ptb:e(rankreward)
    local item = {h=rankreward['serverreward'], q={}, f={} }
    for prefix,vv in pairs(rankreward['reward']) do
        if not item.q[prefix] then
            item.q[prefix] = {}
        end
        for k, goods in pairs(vv) do
            item.q[prefix][k] = {}
            for mType, mNum in pairs(goods) do
                -- table.insert(item.q[prefix], {[mType] = mNum})
                item.q[prefix][k][mType] = (item.q[prefix][k][mType] or 0) +mNum
            end
        end
    end
    for _,_ in pairs(rankreward['serverreward']) do
        table.insert(item.f, "0")
    end
    -- ptb:e(json.encode(item))
    local tmpetTime = ts + 86400*30
    local subject = '活动邮件'
    MAIL:sentSysMail(ts,tmpetTime,subject,json.encode({zoneid=zoneid, name=name}),1,8,item,1)
    redis:set(cachekey,1)
    redis:expireat(cachekey,ts+86400*2)    
    response.ret=0
    response.msg ='Success'
    return response

end