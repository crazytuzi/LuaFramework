-- 排行榜奖励

function api_military_rankreward(request)
    local response = {
        ret=-1,
        msg='error',
        data = {
            userarena={},
        },
    }
    if moduleIsEnabled('ma')  == 0 then
        response.ret = -10000
        return response
    end

    local weets = getWeeTs()
    local redis = getRedis()
    local key = "z"..getZoneId()..".sndUserArenaRankReward.ts."..weets
    local refret=redis:get(key)
    local alienMineCfg = getConfig("alienMineCfg")
    
    if  refret~=nil and  tonumber(refret) >=1  then

        response.ret=0
        response.msg ='Success'
        response.data={'send ok'}
        return response
    end
    redis:incr(key)
    redis:expire(key,5*24*3600)
    local db = getDbo()
    local result = db:getAllRows("select uid,ranking from userarena order by ranking ASC")
    

    if type(result)=='table'   and next(result) then
        local rankReward = nil
        if moduleIsEnabled('he') == 1 then
            rankReward = getConfig('arenaCfg.rankReward2')
        else
            rankReward = getConfig('arenaCfg.rankReward1')
        end

        for k,v in pairs (result) do
            local ranking=tonumber(v.ranking) 
            local uid    =tonumber(v.uid)
            local reward={}
            if ranking>=2000 then
                reward=rankReward[#rankReward].serverReward
            else
                for rk,rd in pairs (rankReward) do
                    if ranking>=rd['range'][1]  and  ranking <= rd['range'][2] then
                        reward=rd.serverReward
                        break
                    end
                end
            end
            if next(reward) then 
                local ret=sendToRewardCenter(uid,'mi','ma',weets,nil,{r=ranking},reward)
                --print('reward',uid,ret)
            end
        end

    end
    response.ret=0
    response.msg ='Success'
    return response

end