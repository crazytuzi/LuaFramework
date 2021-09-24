-- 名将培养
-- action = 1 单抽， 2 十连抽 3，奖励日志
-- free = true 免费，不传或false 默认收费
function api_active_mingjiangpeiyang(request)
    local aname = 'mingjiangpeiyang'

    local response = {
        ret=-1,
        msg='error',
        data = {
        },
    }

    local uid = request.uid
    local action = tonumber(request.params.action) or 1
    local free = request.params.free or false
    local ts = getClientTs()
    local weeTs = getWeeTs()

    if not uid or not action then
        response.ret = -102
        return response
    end

    local uobjs = getUserObjs(uid)
    uobjs.load({"userinfo", "techs", "troops", "props","bag","skills","hero",'useractive'})
    local mUseractive = uobjs.getModel('useractive')
    local mUserinfo = uobjs.getModel('userinfo')
    local mTroops = uobjs.getModel('troops')
    local mAccessory = uobjs.getModel('accessory')
    local mBag = uobjs.getModel("bag")
    local mHero = uobjs.getModel('hero')

    -- 活动检测
    local activStatus = mUseractive.getActiveStatus(aname)
    if activStatus ~= 1 then
        response.ret = activStatus
        return response
    end

    -- 领奖记录缓存
    local redis = getRedis()
    local redkey = "z"..getZoneId()..'.'..aname.."."..mUseractive.info[aname].st.."."..uid
    local data = json.decode(redis:get(redkey)) or {}

    if action == 3 then
        local function formatRecord(rowRecord)
            local record = {{},0,1}

            for k,v in pairs(rowRecord) do
                if type(v) == 'table' then
                    for rName,rNum in pairs(v[1]) do
                        record[1][rName] = (record[1][rName] or 0 ) + (tonumber(rNum) or 0)
                    end

                    record[2] = v[2]
                    v[3] = tonumber(v[3]) or 1
                    if v[3] > record[3] then
                        record[3] = v[3]
                    end
                end
            end

            record[1] = formatReward(record[1])

            return record
        end

        if type(data) == 'table' then
            for k,v in pairs(data) do
                data[k] = formatRecord(v)
            end
            response.data.log = data
        end

        response.ret = 0
        response.msg = 'Success'
        return response
    end

    --[[
    if action == 3 then
        if type(data) == 'table' then
            for k,v in pairs(data) do
                for vk,vv in pairs(v) do
                    v[vk][1] = formatReward(v[vk][1])
                end
                data[k] = v
            end
            response.data.log = data
        end
        response.ret = 0
        response.msg = 'Success'
        return response
    end
    ]]

    local activeCfg = mUseractive.getActiveConfig(aname)
    local report = {}
    if not mUseractive.info[aname].t or getWeeTs(mUseractive.info[aname].t) < weeTs then
        mUseractive.info[aname].t = 0
        mUseractive.info[aname].f = 0
    end

    -- 判断是否免费
    local cost = activeCfg['cost'..action] or 0
    local freeNum = activeCfg.freeNum or 0
    if action == 1 and free and tonumber(mUseractive.info[aname].f) < freeNum then
        cost = 0
        mUseractive.info[aname].f = (mUseractive.info[aname].f or 0) + 1
    else
        if free then
            response.ret = -102
            return response
        end
        cost = activeCfg['cost'..action]
        regActionLogs(uid,1,{action=126,item="",value=cost,params={action=action}})
    end

    -- 使用金币
    if not free and cost <= 0 then
        response.ret = -1981
        return response
    end
    -- print('cost',cost)
    if not mUserinfo.useGem(cost) then
        response.ret = -109
        return response
    end

    function initPosInfo(ainfo)
        if not ainfo.s or type(ainfo.s) ~= 'table' then
            ainfo.s = {}
        end

        if type(activeCfg.randomItem) == 'table' then
            for i=1,#activeCfg.randomItem do
                ainfo.s[i] = 0
            end
        end

        return ainfo.s
    end

    if not mUseractive.info[aname].s or type(mUseractive.info[aname].s) ~= 'table' then
        mUseractive.info[aname].s = initPosInfo(mUseractive.info[aname])
    end

    -- mUseractive.info[aname].s2 = copyTable(mUseractive.info[aname].s)

    if not mUseractive.info[aname].d then
        mUseractive.info[aname].d = 1
    end

    if not mUseractive.info[aname].r then
        mUseractive.info[aname].r = {}
    end

    -- 抽奖

    local num = action == 2 and 10 or 1

    for i=1,num do
        local count = 0
        local fin = 0
        local reward = {}
        for rindex,rnum in pairs(activeCfg.randomItem) do
            count = count + 1
            if mUseractive.info[aname].s[rindex] >= activeCfg.maxPoint then
                fin = fin + 1
            end
        end

        -- 所有位置都集满只给英雄
        if count > 0 and fin > 0 and count == fin then
            for k,v in pairs(activeCfg.mustGetHero) do
                local hname = k:split('_')
                local flag = mHero.addHeroResource(hname[2],v)
                if not flag then
                    response.ret = -1989
                    return response
                end
                mUseractive.info[aname].s = initPosInfo(mUseractive.info[aname])
                mUseractive.info[aname].d = 0
                mUseractive.info[aname].r = {}
                table.insert(report,{4,formatReward({[k]=v})}) -- 所有部位集满log
            end
            table.insert(data,{{activeCfg.mustGetHero,ts,3}})
        else
            local result = getRewardByPool(activeCfg.serverreward.randomPool)
            local pointTypeList = activeCfg.serverreward.pointType or {}
            local rewardLog = {}
            table.insert(rewardLog,{result,ts,1}) -- 记录奖励log

            for k,v in pairs(result or {}) do

                -- 根据物品价值算出添加多少积分
                setRandSeed()
                local pointType = 1
                if pointTypeList[k] then
                    pointType = pointTypeList[k]
                end

                local pointList = activeCfg.serverreward.pointList[pointType] or {1,1}
                local addPoint = rand(pointList[1],pointList[2])
                local double = tonumber(mUseractive.info[aname].d) or 0
                if double and double == 1 then
                    addPoint = addPoint * activeCfg.pointTimes
                end

                -- 随机分配积分到某个部位
                local pool = {}
                local maxCount = 0
                for rindex,rnum in pairs(activeCfg.randomItem) do
                    maxCount = maxCount + 1
                    -- 过滤已经集满的部位
                    if mUseractive.info[aname].s[rindex] < activeCfg.maxPoint then
                        for num=1,rnum do
                            table.insert(pool,rindex)
                        end
                    end
                end

                -- 累计常规奖励
                reward[k] = (reward[k] or 0) + v
                table.insert(report,{1,formatReward({[k]=v})}) -- 常规奖励log

                -- 将积分加到对应位置 并判断是否集满
                setRandSeed()
                local pos = pool[rand(1,#pool)]
                mUseractive.info[aname].s[pos] = (mUseractive.info[aname].s[pos] or 0) + addPoint
                table.insert(report,{2,{pos,addPoint,double}}) -- 积分log

                if mUseractive.info[aname].s[pos] >= activeCfg.maxPoint then
                    mUseractive.info[aname].s[pos] = activeCfg.maxPoint

                    -- 发集满奖励
                    if not mUseractive.info[aname].r['s'..pos] then
                        extReward = activeCfg.serverreward.getReward[pos] or {}
                        for ek,ev in pairs(extReward) do
                            reward[ek] = (reward[ek] or 0) + ev
                            table.insert(report,{3,formatReward({[ek]=ev})}) -- 集满部位额外奖励log
                        end
                        mUseractive.info[aname].r['s'..pos] = 1
                        table.insert(rewardLog,{extReward,ts,2}) -- 记录奖励log
                    end
                end

                if reward and next(reward) then
                    if not takeReward(uid,reward) then
                        response.ret = -1989
                        return response
                    end
                end
                table.insert(data,rewardLog)
            end
        end
    end

    mUseractive.info[aname].t = ts

    processEventsBeforeSave()
    regEventBeforeSave(uid,'e1')
    
    -- 和谐版判断
    local harCReward={}--和谐版的值
    if moduleIsEnabled('harmonyversion') ==1 then
        local hReward,hClientReward = harVerGifts('active','mingjiangpeiyang',num)
        if not takeReward(uid,hReward) then
            response.ret = -403
            return response
        end

        harCReward = hClientReward
        local rwdlog={}
        table.insert(rwdlog,{hReward,ts,1})
        for k,v in pairs(hReward) do
            table.insert(data,rwdlog)
        end
    end

    if uobjs.save() then
        if next(data) then
            if #data > 15 then
                for i=1,#data-15 do
                    table.remove(data,1)
                end
            end
            data = json.encode(data)
            redis:set(redkey,data)
            redis:expireat(redkey,mUseractive.info[aname].et+86400)
        end
        response.data[aname] = mUseractive.info[aname]
        if next(harCReward) then
            response.data[aname].hReward=harCReward
        end        
        response.data.hero = mHero.toArray(true)
        response.data.report = report
        processEventsAfterSave()

        response.ret = 0
        response.msg = 'Success'
    end

    return response
end
