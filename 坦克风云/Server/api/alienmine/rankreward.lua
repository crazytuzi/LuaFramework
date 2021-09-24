-- 排行榜的奖励

function api_alienmine_rankreward(request)
    local response = {
        ret=0,
        msg='Success',
        data = {},
    }



    local weets =getWeeTs()
    local redis = getRedis()
    local key = "z"..getZoneId()..".refAlienUserRank.ts."..weets
    local refret=redis:get(key)
    local alienMineCfg = getConfig("alienMineCfg")
    local endTime = weets + alienMineCfg.endTime[1]*3600 + alienMineCfg.endTime[2]*60+300
    local ts = getClientTs()
    if ts< endTime then
        return response
    end
    if  refret~=nil and  tonumber(refret) >=1  then

        response.ret=0
        response.msg ='Success'
        response.data={'send ok'}
        return response
    end
    redis:incr(key)
    redis:expire(key,5*24*3600)
    local flag=false
    local userlist=getAlienMineRanking(9)
    if type(userlist)=='table' and next(userlist) then
        local reward=getConfig("alienMineCfg.userRanking.reward")
        for k,v in pairs(userlist) do
            local uid=tonumber(v.id)
            local rank=tonumber(v.rank)
            -- 在异星矿场中获得异星资源最多的玩家 每日捷报
            if rank==1 then
                local uobjs = getUserObjs(uid)
                local mUserinfo = uobjs.getModel('userinfo')
                local newsdata={mUserinfo.pic,mUserinfo.nickname,mUserinfo.level,mUserinfo.fc,mUserinfo.alliancename,uid,mUserinfo.bpic,mUserinfo.apic}
                local news={title="d17",content={
                        userinfo={
                            newsdata
                        }
                    }}
                setDayNews(news)
            end
            for rk,rv in pairs(reward) do
                if rank>=rv['range'][1] and rank<=rv['range'][2] then
                    local item={}
                    item['h']=rv['serverReward']
                    item['q']=rv['reward']
                    local ret = MAIL:mailSent(uid,1,uid,'','',25,json.encode({rank=rank,type=25}),1,0,4,item)
                    if ret then
                        flag=true
                    end
                end
            end
        end
    end

    local alliancelist=getAlienMineAllinceRanking(0)
    if type(alliancelist) and next(alliancelist) then
        local reward=getConfig("alienMineCfg.allianceRanking.reward")
        for k,v in pairs(alliancelist) do
            local aid=tonumber(v.id)
            local ret,code = M_alliance.getalliance{alliancebattle=1,method=1,aid=aid,uid=uid}
            if ret then
                if type(ret.data.members)=='table' and next(ret.data.members) then
                    for uk,uv in pairs(ret.data.members) do 
                        local uid=tonumber(uv.uid)
                        local join_at=tonumber(uv.join_at)
                        if join_at<=weets then
                            local item={}
                            item['q']=reward[k]['reward']
                            item['h']=reward[k]['serverReward']
                            local ret=MAIL:mailSent(uid,1,uid,'','',26,json.encode({rank=rank,type=26}),1,0,4,item)
                            if ret then
                                flag=true
                            end
                        end
                    end
                end
            end
        end

    end

    if not flag then
        redis:del(key)
    end
    return response
end