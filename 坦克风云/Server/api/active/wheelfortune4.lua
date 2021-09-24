-- 坦克轮盘（北美的实物奖励）
--[[ 
action 
    1为抽奖，涉及到实物奖励，走事务吧
    2为领取在线时间奖励的抽奖次数,
    3为查看领奖名单
]]

-- 增加了十连抽功能
function api_active_wheelfortune4(request)
    -- 活动名称，坦克轮盘
    local aname = 'wheelFortune4'

    local response = {
        ret=-1,
        msg='error',
        data = {[aname]={}},
    }

    local uid = request.uid
    local action = tonumber(request.params.action)

     if uid == nil or action == nil then
        response.ret = -102
        return response
    end

    local uobjs = getUserObjs(uid)
    uobjs.load({"userinfo", "techs", "troops", "props","bag","skills","buildings",'useractive'})
    local mUseractive = uobjs.getModel('useractive')
    local mUserinfo = uobjs.getModel('userinfo')
    local db = getDbo()
    local reward,report,luckyReward

    -- 活动检测
    local activStatus = mUseractive.getActiveStatus(aname)    
    if activStatus ~= 1 then
        response.ret = activStatus
        return response
    end
    
    if type(mUseractive.info[aname].d) ~= 'table' then
        mUseractive.info[aname].d = {}
    end

    local ts = getClientTs()
    local weeTs = getWeeTs()

    -- 如果过了凌晨，重置数据
    if weeTs ~= ( mUseractive.info[aname].t or 0 ) then
        mUseractive[aname](aname,{reset=true})
    end

    local activeCfg = getConfig("active.".. aname)

    -- 直接抽奖
    if action == 1 then        
        db.conn:setautocommit(false)

        local lnum = request.params.num or 1        
        if lnum ~= 1 and lnum ~= 10 then
            return response
        end

        if (mUseractive.info[aname].d.n or 0) < lnum then
            local enough = false

            local useProp = tonumber(request.params.useProp) or 0
            if useProp > 0 then
                local mBag = uobjs.getModel('bag') 
                local needNum = activeCfg.propConsume[2] * (lnum - (mUseractive.info[aname].d.n or 0))
                
                if needNum == useProp and mBag.use(activeCfg.propConsume[1],needNum) then
                    enough = true
                end
            end
            
            if not enough then
                response.ret = -1981
                return response
            end
        end

        -- 抽奖
        setRandSeed()
        
        local function lottery(mUseractive,activeCfg,lnum,report,reward,luckyReward)
            local tmpReward = {}
            local superReward = false
            report = report or {}
            reward = reward or {}
            local zoneid = getZoneId()
            
            if not mUseractive.info[aname].d.superReward and activeCfg.serverreward.zonePool[zoneid] then
                local randomNum = rand(1,100000)
                
                if randomNum <= activeCfg.serverreward.luckchance then
                    local cPoolkey = aname .. '.pool.' .. mUseractive.info[aname].st
                    
                    local zPool = copyTable(activeCfg.serverreward.zonePool[zoneid])                    
                    local currPool = getFreeData( cPoolkey ) or {}          
                    currPool = currPool.info or {}

                    local seedNum = 0
                    
                    if zPool then
                        for k,v in pairs(zPool[2]) do 
                            if currPool[k] then
                                zPool[2][k] = zPool[2][k] - (tonumber(currPool[k]) or 0)
                            else
                                currPool[k] = 0
                            end

                            seedNum = seedNum + zPool[2][k]
                        end
                    end
                    
                    if seedNum > 0 then
                        local rkey
                        tmpReward,rkey = getRewardByPool(zPool)                
                        for _,v in pairs(rkey or {}) do
                            if currPool[v] then
                                currPool[v] = (currPool[v] or 0) + 1
                            end
                        end

                        superReward = tmpReward

                        if not setFreeData(cPoolkey ,currPool) then
                            return false
                        end
                    end
                end
            end

            if type(superReward) == 'table' then
                if type(mUseractive.info[aname].d.superReward) ~= 'table' then
                    mUseractive.info[aname].d.superReward ={}
                end

                for k,v in pairs(superReward) do
                    mUseractive.info[aname].d.superReward[k] = v
                end

                luckyReward = superReward
            else
                tmpReward = getRewardByPool(activeCfg.serverreward.poolReward)
            end
            
            for k, v in pairs(tmpReward or {}) do
                reward[k] = (reward[k] or 0) + v                    
            end

            table.insert(report,{formatReward(tmpReward)})

            lnum = lnum - 1

            if lnum > 0 then
                return lottery(mUseractive,activeCfg,lnum,report,reward,luckyReward)
            else
                return reward,report,luckyReward
            end
        
        end

        reward,report,luckyReward = lottery(mUseractive,activeCfg,lnum,report,reward,luckyReward)
        
        if not reward then
            response.ret = -307
            return response
        end

        mUseractive.info[aname].d.n = mUseractive.info[aname].d.n - lnum
        mUseractive.info[aname].c = mUseractive.info[aname].c + lnum
        if mUseractive.info[aname].d.n < 0 then
            mUseractive.info[aname].d.n = 0
        end

        -- 纯粹是为了统计每日VIP用户抽奖数
        if mUserinfo.vip > 0 and (mUseractive.info[aname].vip or 0) == 0 then            
            mUseractive.setStats(aname,{res=reward,lottery=1,isvip=1})
            mUseractive.info[aname].vip = mUserinfo.vip
        else
            mUseractive.setStats(aname,{res=reward,lottery=1})
        end

        -- 更新最后一次抽奖时间
        mUseractive.info[aname].t = weeTs
        response.data[aname].active = mUseractive.info[aname]

        if not takeReward(uid,reward) then
            response.ret = -1989
            return response
        end

    -- 领取免费活动次数
    elseif action == 2 then
        mUseractive[aname](aname,{freeNum=true})
        response.data[aname].active = mUseractive.info[aname]
    -- 查看获奖名单
    elseif action == 3 then
        local awardList = mUseractive[aname](aname,{getreport=true})
        
        if type(awardList) == "table" then
            for _,v in pairs(awardList) do
                local tuid = tonumber(v[1])            
                if tuid>0 then
                    local tuobjs = getUserObjs(tuid,true)
                    local tuserinfo = tuobjs.getModel('userinfo')                    
                    table.insert(v,tuserinfo.nickname)
                    table.insert(v,tuserinfo.level)
                end    
            end

            response.data[aname].awardList = awardList
        end
    else
        return response
    end

    processEventsBeforeSave()

    if uobjs.save() then
        if report then
            response.data[aname].report = report
        end

        processEventsAfterSave()

        if action ~= 1 then
            response.ret = 0
            response.msg = 'Success'
        end
    end

    if action == 1 and db.conn:commit() then        
        if type(luckyReward) == "table" then
            local pid = next(luckyReward)
            mUseractive[aname](aname,{setreport=true,uid=uid,reward=formatReward(luckyReward),sort=activeCfg.serverreward.ranksort[pid]})
        end

        response.ret = 0
        response.msg = 'Success'
    end
    
    return response
end
