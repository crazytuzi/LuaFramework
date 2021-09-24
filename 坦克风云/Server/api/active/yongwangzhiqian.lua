-- 勇往直前活动
-- action 1 领取关卡通过奖励 2 领取每日任务奖励

function api_active_yongwangzhiqian(request)
    local response = {
        ret=-1,
        msg='error',
        data = {},
    }

    local uid = request.uid
	local action = tonumber(request.params.action) or nil
	local skey = request.params.sid or nil
	local ts = getClientTs()
	local weeTs = getWeeTs()
	
    if uid == nil or not skey then
        response.ret = -102
        return response
    end

    local aname = 'yongwangzhiqian'
        
    local uobjs = getUserObjs(uid)
    uobjs.load({"userinfo",'useractive','bag','troops','accessory'})
    local mUseractive = uobjs.getModel('useractive')
    local mUserinfo = uobjs.getModel('userinfo')
	local mTroops = uobjs.getModel('troops')
    local mAccessory = uobjs.getModel('accessory')
    local mBag = uobjs.getModel("bag")
    local activStatus = mUseractive.getActiveStatus(aname)

    -- 活动检测
    if activStatus ~= 1 then
        response.ret = activStatus
        return response
    end
	
	local activeCfg = mUseractive.getActiveConfig(aname)
	
    --[[ 数据格式
        mUseractive.info[aname].t = weeTs -- 上次关卡攻打时间
		mUseractive.info[aname].r = { -- 任务关卡攻打次数，每日重置
            s1 = {n=5,f=1,h=1444901462}
            s2 = {n=5,f=1,h=1444901462}
        }
        mUseractive.info[aname].p = { -- 通过的章节 章节id = 是否领取
            s16 = {n=1,f=1,h=1444901462}, -- n 通过次数，f 是否领取，h领取时间戳
            s32 = {n=1,f=1,h=1444901462}, 
        }
    ]]

    if action == 2 and (not mUseractive.info[aname].t or getWeeTs(mUseractive.info[aname].t) < weeTs) then
        mUseractive.info[aname].t = ts
        mUseractive.info[aname].r = {}
    end
    

    if action == 1 then
        if not mUseractive.info[aname].p then
            mUseractive.info[aname].p = {}
        end
            
        if not activeCfg.passChallenge[skey] then
            response.ret = -102
            return response
        end
        
        if not mUseractive.info[aname].p[skey] or type(mUseractive.info[aname].p[skey]) ~= 'table' then
            response.ret = -1981
            return response
        end
        
        if mUseractive.info[aname].p[skey].f and mUseractive.info[aname].p[skey].f == 1 then
            response.ret = -1976
            return response
        end

        if mUseractive.info[aname].p[skey].n and tonumber(mUseractive.info[aname].p[skey].n) >= activeCfg.passChallenge[skey].num then
            local reward = activeCfg.passChallenge[skey].serverreward
            mUseractive.info[aname].p[skey].f = 1
            mUseractive.info[aname].p[skey].h = ts
            
            if not takeReward(uid,reward) then        
                response.ret = -403
                return response
            end
            response.data.reward = formatReward(reward)
        end
    elseif action == 2 then
        if not activeCfg.taskChallenge[skey] then
            response.ret = -102
            return response
        end
        
        local taskNeedNum = activeCfg.taskChallenge[skey].num
        if not mUseractive.info[aname].r or type(mUseractive.info[aname].r) ~= 'table' then
            response.ret = -1981
            return response
        end
        
        if not mUseractive.info[aname].r.f then
            mUseractive.info[aname].r.f = {}
        end
        
        if mUseractive.info[aname].r.f[skey] and mUseractive.info[aname].r.f[skey] == 1 then
            response.ret = -1976
            return response
        end

        if mUseractive.info[aname].r.n and tonumber(mUseractive.info[aname].r.n) >= taskNeedNum then
            local reward = activeCfg.taskChallenge[skey].serverreward
            mUseractive.info[aname].r.f[skey] = 1
            mUseractive.info[aname].r.h = ts
            
            if not takeReward(uid,reward) then        
                response.ret = -403
                return response
            end
            response.data.reward = formatReward(reward)
        end
    end
    
    processEventsBeforeSave()

    if  uobjs.save() then        
        processEventsAfterSave()
		
        response.ret = 0
		response.data[aname] = mUseractive.info[aname]
		response.data.accessory = mAccessory.toArray(true)
		response.data.bag = mBag.toArray(true)
		response.data.troops = mTroops.toArray(true)
		response.data.userinfo = mUserinfo.toArray(true)
        response.msg = 'Success'
    end
    
    return response
end