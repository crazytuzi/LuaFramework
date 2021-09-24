-- 春节攀升计划活动
-- cmd : active.chunjiepansheng
-- action 
-- 1 领取任务点奖励 参数:tid 1~n 领取第几档
-- 2 领取每日任务奖励 参数:day 1~n ，tid 任务id 第几天的第几档
-- 3 领取每日所有任务完成宝箱奖励 参数: day 1~n 第几天

function api_active_chunjiepansheng(request)
    local response = {
        ret=-1,
        msg='error',
        data = {},
    }

    local uid = request.uid
	local ts = getClientTs()
	local weeTs = getWeeTs()
    local action = tonumber(request.params.action)
	
    if not uid then
        response.ret = -102
        return response
    end

    local aname = 'chunjiepansheng'
        
    local uobjs = getUserObjs(uid)
    uobjs.load({"userinfo",'useractive','bag','troops','accessory','hero'})
    local mUseractive = uobjs.getModel('useractive')
    local mUserinfo = uobjs.getModel('userinfo')
	local mTroops = uobjs.getModel('troops')
    local mAccessory = uobjs.getModel('accessory')
    local mBag = uobjs.getModel("bag")
    -- local mWeapon = uobjs.getModel('weapon')
    local mHero = uobjs.getModel('hero')
    local activStatus = mUseractive.getActiveStatus(aname)
    
    -- 活动检测
    if activStatus ~= 1 then
        response.ret = activStatus
        return response
    end
	
	local activeCfg = mUseractive.getActiveConfig(aname)
    local st = mUseractive.info[aname].st or 0
    local currDay = math.floor(math.abs(ts-getWeeTs(st))/(24*3600)) + 1;
    
    -- print('currDay',currDay)
    if not activeCfg.taskList or type(activeCfg.taskList) ~= 'table' or currDay > #activeCfg.taskList then
        
        response.ret = -1977
        return response
    end
    
    --[[ 数据格式
        -- 总任务点
		mUseractive.info[aname].n = 0, 
        
        -- 任务点领取标志
        -- tbox = {tb1=1,tb2=1,tb3=1},
        
        -- 第一天任务数据 玩家没登录或者没完成，可能没有该字段
		mUseractive.info[aname].d1 = {
            -- 任务进度
            tk = {
                aa = 1,
                bb = 1,
            },
            
            -- 任务领取标志
            fin = {
                t1 = 1,t2 = 1,
            },
            
            -- 免费宝箱
            gf = 1,
        },
        .....
        mUseractive.info[aname].d7 = {}
    ]]

    if action == 1 then
        local tid = tonumber(request.params.tid)
        if not tid then
            response.ret = -102
            return response
        end

        if not mUseractive.info[aname].n then
            response.ret = -1981
            return response
        end  

        if not mUseractive.info[aname].tbox then
            mUseractive.info[aname].tbox = {}
        end
        
        if mUseractive.info[aname].tbox['tb'..tid] then
            response.ret = -1976
            return response
        end
        
        local needPoint = activeCfg.taskPoint[tid] or 0

        if mUseractive.info[aname].n >= needPoint then
            local reward = activeCfg.serverreward.taskPointReward[tid] or {}
            if not takeReward(uid,reward) then        
                response.ret = -403
                return response
            end
            mUseractive.info[aname].tbox['tb'..tid] = 1
        else
            response.ret = -1981
            return response
        end

    elseif action == 2 then
        local day = tonumber(request.params.day)
        local tid = tonumber(request.params.tid)
        local actype = request.params.type    
        if not day or not tid then
            response.ret = -102
            return response
        end
        
        --[[
            taskList={
            {
                -- 固定 购买礼包
                -- 条件{type,num},增加的任务点，奖励，是否金币礼包的价格
                {{"gu",1},5,{p={{p20=1}}},333},
            }
        ]]
        
        if not mUseractive.info[aname].day then
            mUseractive.info[aname].day = {}
        end
            
        if not mUseractive.info[aname].day['d'..day] then
            mUseractive.info[aname].day['d'..day] = {}
        end
        
        if not mUseractive.info[aname].day['d'..day].tk then
            mUseractive.info[aname].day['d'..day].tk = {}
        end
        
        if not mUseractive.info[aname].day['d'..day].fin then
            mUseractive.info[aname].day['d'..day].fin = {}
        end
        
        if mUseractive.info[aname].day['d'..day].fin['t'..tid] then
            response.ret = -1976
            return response
        end
        
        local conditionType = activeCfg.taskList[day][tid][1][1]
        local conditionNum = activeCfg.taskList[day][tid][1][2]
        local addPoint = activeCfg.taskList[day][tid][2]
        local buyBoxCost = activeCfg.taskList[day][tid][4] and activeCfg.taskList[day][tid][4] or 0
        if buyBoxCost > 0 then
            -- 购买礼包需要判断是不是当天
            if currDay ~= day then
                response.ret = -102
                return response
            end
        
            if not mUserinfo.useGem(buyBoxCost) then
                response.ret = -109
                return response
            end
           
            if not mUseractive.info[aname].day['d'..day].tk then
                mUseractive.info[aname].day['d'..day].tk = {}
            end
            
            mUseractive.info[aname].day['d'..day].tk[conditionType] = (mUseractive.info[aname].day['d'..day].tk[conditionType] or 0) + 1
            regActionLogs(uid,1,{action=119,item="",value=buyBoxCost,params={action=action,day=day,tid=tid}})
        else
            if actype==nil or actype~=conditionType  then
                if not mUseractive.info[aname].day['d'..day].tk[conditionType] or mUseractive.info[aname].day['d'..day].tk[conditionType] < conditionNum then
                    response.ret = -1981
                    return response
                end
            else
                mUseractive.info[aname].day['d'..day].tk[conditionType]=conditionNum    
            end
        end

        local reward = activeCfg.serverreward.taskListReward[day][tid] or {}
        if not takeReward(uid,reward) then        
            response.ret = -403
            return response
        end
        
        mUseractive.info[aname].n = (mUseractive.info[aname].n or 0) + addPoint
        mUseractive.info[aname].day['d'..day].fin['t'..tid] = 1

    elseif action == 3 then
        local day = tonumber(request.params.day)
  
        if not day then
            response.ret = -102
            return response
        end

        if not mUseractive.info[aname].day then
            mUseractive.info[aname].day = {}
        end
        
        if not mUseractive.info[aname].day['d'..day] then
            mUseractive.info[aname].day['d'..day] = {}
        end
        
        if not mUseractive.info[aname].day['d'..day].tk then
            mUseractive.info[aname].day['d'..day].tk = {}
        end
        
        if mUseractive.info[aname].day['d'..day].gf then
            response.ret = -1976
            return response
        end
        
        if not mUseractive.info[aname].day['d'..day].fin then
            mUseractive.info[aname].day['d'..day].fin = {}
        end
        
        local allTaskConfig = activeCfg.taskList[day] or {}
        local allTask = #allTaskConfig or 0
        local finTaskNum = 0
        for i,v in pairs(allTaskConfig) do
            local conditionType = v[1][1]
            local conditionNum = v[1][2]

            if mUseractive.info[aname].day['d'..day].tk[conditionType] and mUseractive.info[aname].day['d'..day].tk[conditionType] >= conditionNum then
                finTaskNum = finTaskNum + 1
            end
        end
        
        -- for i,v in pairs(mUseractive.info[aname].day['d'..day].fin) do
            -- finTaskNum = finTaskNum + 1
        -- end

        if allTask > 0 and finTaskNum >= allTask then
            local reward = activeCfg.serverreward.taskAllFinReward[day] or {}
            if not takeReward(uid,reward) then        
                response.ret = -403
                return response
            end
            
            mUseractive.info[aname].day['d'..day].gf = 1
        else
            response.ret = -1981
            return response
        end
    end
    
    
    processEventsBeforeSave()

    if  uobjs.save() then        
        processEventsAfterSave()
		
        response.ret = 0
		response.data[aname] = mUseractive.info[aname]
		--response.data.accessory = mAccessory.toArray(true)
		response.data.bag = mBag.toArray(true)
		--response.data.troops = mTroops.toArray(true)
		--response.data.userinfo = mUserinfo.toArray(true)
        -- response.data.weapon = mWeapon.toArray(true)
        response.data.hero = mHero.toArray(true)
        response.msg = 'Success'
    end
    
    return response
end
