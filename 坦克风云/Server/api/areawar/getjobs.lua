-- 获得所有职位信息

function api_areawar_getjobs(request)
    -- body

    local response = {
        ret=0,
        msg='Success',
        data = {},
    }
    local aid  = tonumber(request.params.aid) or 0
    

    if aid == 0  then
        response.ret = -102
        return response
    end

    local redis = getRedis()    

    local key   ="z" .. getZoneId() .."arenBattleWinAlliance"

    local data = json.decode(redis:get(key))

    if data==nil then
        -- 请求一下php 获取一下数据
        data={memberjobs={},membersfeat={},membersslave={}}
        local areaWarCfg = getConfig('areaWarCfg')
       
        local execRet,code = M_alliance.getjobs{aid=aid,buffTime=areaWarCfg.buffTime}

        if not execRet then
            return response
        end

        -- 军团奴隶
        if type(execRet.data.aslave)=="table" and next(execRet.data.aslave) then
            local slave={}
            for k,v in pairs(execRet.data.aslave) do
                local muid=tonumber(v[1] or 0)  
                 local uobjs = getUserObjs(muid)
                 uobjs.load({"userinfo","hero","troops"})
                 local mUserinfo = uobjs.getModel('userinfo')
                 table.insert(slave,{muid,mUserinfo.nickname,mUserinfo.level,mUserinfo.fc,v[2],v[4],v[3]}) 

            end
            data.membersslave=slave --execRet.data.content
        end
        -- 所有成员的贡献值
        if type(execRet.data.content)=='table' then
            data.membersfeat=execRet.data.content
        end
        if execRet.data.jobs~=nil then
            local jobs=execRet.data.jobs
            local memberjobs={}
            if type(jobs)=='table' and next(jobs) then
                
                for k,v in pairs(jobs) do
                    if type(memberjobs[k])~='table' then  memberjobs[k]={} end
                    for k1,v1 in pairs (v) do
                        local muid =tonumber(v1)
                        local uobjs = getUserObjs(muid,true)
                        uobjs.load({"userinfo","jobs"})
                        local mUserinfo=uobjs.getModel('userinfo')
                        table.insert(memberjobs[k],{muid,mUserinfo.nickname,mUserinfo.level,mUserinfo.fc,mUserinfo.pic})
                    end

                end

                data.memberjobs=memberjobs
            end
        redis:set(key,data)
        redis:expireat(key,tonumber(execRet.data.own_at)+areaWarCfg.buffTime)
    
        else
            redis:set(key,{})
            redis:expire(key,300)
        end
    end

    response.data.jobs=data.memberjobs
    response.data.membersfeat=data.membersfeat
    response.data.membersslave=data.membersslave

    return response

end
