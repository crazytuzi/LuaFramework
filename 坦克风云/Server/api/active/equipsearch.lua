-- 装备探索
-- action 1为抽奖，2为获取前10排行,3、领取物资排行奖励
-- num 探索次数，默认为1，其它值：10，50
-- 每日免费探索一次，凌晨刷新，
function api_active_equipsearch(request)
    local response = {
        ret=-1,
        msg='error',
        data = {equipSearch={}},
    }

    local uid = request.uid
    local action = tonumber(request.params.action)
    local num = tonumber(request.params.num) or 1

     if uid == nil or action == nil then
        response.ret = -102
        return response
    end

    -- 活动名称，
    local aname = 'equipSearch'

    -- 奖励值转积分
    local function getPointByReward(rewardKey,cfg)
        if type(rewardKey) == 'table' and #rewardKey == 1 then
            return rand(cfg[rewardKey[1]][1],cfg[rewardKey[1]][2])
        end

        return 0
    end

    -- 探索
    local function search(lotteryCfg,num,reward,currN,point,report)
        local result,rewardKey = getRewardByPool(lotteryCfg.pool)
        report = report or {}
        currN = (currN or 0) + 1
        
        reward = reward or {}

        local searchPoint = getPointByReward(rewardKey,lotteryCfg.res4point)
        point = (point or 0) + searchPoint

        for k, v in pairs(result or {}) do
            reward[k] = (reward[k] or 0) + v
        end

        table.insert(report,{formatReward(result),searchPoint})

        if currN >= num then
            return reward,point,report
        else
            return search(lotteryCfg,num,reward,currN,point,report)
        end        
    end

    local uobjs = getUserObjs(uid)
    uobjs.load({"userinfo", "techs", "troops", "props","bag","skills","buildings",'useractive','accessory'})
    local mUseractive = uobjs.getModel('useractive')
    local mUserinfo = uobjs.getModel('userinfo')
    local mAccessory = uobjs.getModel('accessory')
    local reward,point,report

    local activStatus
    if action == 1 then
        activStatus = mUseractive.getActiveStatus(aname,true)
    elseif action == 2 then
        activStatus = 1
    elseif action == 4 then
        activStatus = 1
    elseif action==5 then
        activStatus = 1
    elseif action==6 then
         activStatus = 1
    else
        activStatus = mUseractive.isTakeReward(aname) 
    end

    -- 活动检测
    if activStatus ~= 1 then
        response.ret = activStatus
        return response
    end
    
    if type(mUseractive.info[aname].d) ~= 'table' then
        mUseractive.info[aname].d = {}
    end
    
    local ts = getClientTs()
    local weeTs = getWeeTs()
    local activeCfg = getActiveCfg(uid, aname)
    activeCfg = activeCfg.serverreward
    local rewardlog={}--奖励记录
    local addpoint=0--每次增加的资源值
    if action == 1 then
        local gemCost 
        if num == 1 then
            gemCost = activeCfg.searchConsume_1x
        else
            gemCost = activeCfg.searchConsume_10x
        end

        if not gemCost or gemCost <= 0 then
            return response
        end

        local lastTs = mUseractive.info[aname].d.ts or 0

        local isfree = false
        if num == 1 and weeTs > lastTs then
            -- 更新最后一次抽奖时间
            mUseractive.info[aname].d.ts = weeTs
            isfree = true
        end

        if not isfree then
            if not mUserinfo.useGem(gemCost) then
                response.ret = -109
                return response
            end
        end
        
        reward,point,report = search(activeCfg,num)
        
        if reward  and next(reward) then
            if not takeReward(uid,reward) then
                return response
            end
        end
      
        for k,v in pairs(reward) do
            table.insert(rewardlog, formatReward({[k]=v}))
        end 


        mUseractive.info[aname].point = (mUseractive.info[aname].point or 0) + point
        addpoint=point

        if mUseractive.info[aname].point > activeCfg.rankPoint then
            setEquipSearchRanking(uid,mUseractive.info[aname].point,mUseractive.info[aname].st)
        end

        -- 按是否免费分别记录抽奖次数
        if isfree then
            mUseractive.info[aname].d.fn = (mUseractive.info[aname].d.fn or 0) + num
        else
            regActionLogs(uid,1,{action=23,item="",value=gemCost,params={reward=reward}})
            mUseractive.info[aname].d.n = (mUseractive.info[aname].d.n or 0) + num
        end

        -- 和谐版判断
        if moduleIsEnabled('harmonyversion') ==1 then
            local hReward,hClientReward = harVerGifts('active','equipSearch',num)
            if not takeReward(uid,hReward) then
                response.ret = -403
                return response
            end
            response.data.equipSearch.hReward = hClientReward
        end

    elseif action == 2 then       
        local rankList = getEquipSearchRanking(mUseractive.info[aname].st)
        
        local list = {}
        for _,v in ipairs(rankList) do
            local uid = tonumber(v[1])
            if uid>0 then
                local uobjs = getUserObjs(uid,true)
                local userinfo = uobjs.getModel('userinfo')
                local item = {}

                table.insert(item,userinfo.nickname)
                table.insert(item,userinfo.level)
                table.insert(item,userinfo.fc)
                table.insert(item,(v[2] or 0))
                table.insert(item,userinfo.uid)
                table.insert(list,item)
            end    
        end

        response.data[aname] = {rankList =  list}
    
    -- 领取物资排行的奖励
    elseif action == 3 then
        if (mUseractive.info[aname].rr or 0) >= 1 then
            response.ret = -1976
            return response
        end

        local rank = tonumber(request.params.rank) or 0
        if rank < 1 or rank > 10 then
            response.ret = -1977
            return response
        end

        local selfRank 

        -- 领奖就领一次，一次性把所有排行（共10个）取出来，再遍历也无所谓
        -- 没必要再开一个方法，单独获取个人排名
        local rankList = getEquipSearchRanking(mUseractive.info[aname].st)
        for k,v in ipairs(rankList) do
            if tonumber(v[1]) == uid then
                selfRank = tonumber(k)
                break
            end 
        end
        
        if rank ~= selfRank then
            response.ret = -1975
            return response
        end

        if not selfRank or not activeCfg.r[selfRank] then
            response.ret = -1980
            return response
        end

        if not takeReward(uid,activeCfg.r[selfRank]) then
            response.ret = -1989
            return response
        end

        mUseractive.info[aname].rr = 1
    elseif action == 4 then
        response.data.equipSearch.pool = activeCfg.clientpool

    elseif action==5 then
        local redis =getRedis()
        local redkey ="zid."..getZoneId()..aname..mUseractive.info[aname].st.."uid."..uid
        local data =redis:get(redkey)
        data =json.decode(data)

        if type(data) ~= 'table' then data = {} end
        response.ret = 0
        response.msg = 'Success'
        response.data.rewardlog=data
    elseif action==6 then
        local redis =getRedis()
        local redkey ="zid."..getZoneId()..aname..mUseractive.info[aname].st.."uid."..uid..'new'
        local data =redis:get(redkey)
        data =json.decode(data)

        if type(data) ~= 'table' then data = {} end
        response.ret = 0
        response.msg = 'Success'
        response.data.report=data
        return response
    else
        return response
    end

    processEventsBeforeSave()

    if uobjs.save() then        
        if mTroops then
            response.data.troops = mTroops.toArray(true)   
        end

        if action == 1 and mUseractive.info[aname] then            
            response.data.useractive = {[aname]=mUseractive.info[aname]}
        end

        if report then
            response.data.equipSearch.report = report
        end

        if action==1 then
            local harCReward={}
            if type(response.data.equipSearch.hReward)=='table' then
                harCReward=response.data.equipSearch.hReward
            end
            -- 旧版记录保留
            local redis =getRedis()
            local redkey ="zid."..getZoneId()..aname..mUseractive.info[aname].st.."uid."..uid
            local data =redis:get(redkey)
            data =json.decode(data)
            if type (data)~="table" then data={} end

            table.insert(data,1,{ts,rewardlog,num,harCReward,addpoint})
            if next(data) then
                for i=#data,11,-1 do
                    table.remove(data)
                end

                data=json.encode(data)
                redis:set(redkey,data)
                redis:expireat(redkey,mUseractive.info[aname].et+86400)
            end

            -- 新版记录 
            local newredkey ="zid."..getZoneId()..aname..mUseractive.info[aname].st.."uid."..uid..'new'
            local newdata =redis:get(newredkey)
            newdata =json.decode(newdata)
            if type (newdata)~="table" then newdata={} end

            table.insert(newdata,1,{ts,1,rewardlog,harCReward,num})
            if next(newdata) then
                for i=#newdata,11,-1 do
                    table.remove(newdata)
                end

                newdata=json.encode(newdata)
                redis:set(newredkey,newdata)
                redis:expireat(newredkey,mUseractive.info[aname].et+86400)
            end
        end

        processEventsAfterSave()

        response.ret = 0
        response.msg = 'Success'
    end
    
    return response
end
