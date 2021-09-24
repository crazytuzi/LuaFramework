-- 战术研讨活动
-- action 1 发表意见 2 提起抗议 3 结束研讨
-- 参数：tid 1 普通意见 2 集中讨论

function api_active_zhanshuyantao(request)
    local response = {
        ret=-1,
        msg='error',
        data = {},
    }

    local uid = request.uid
	local action = tonumber(request.params.action) or nil
	local tid = tonumber(request.params.tid)
	local free = request.params.free
	local ts = getClientTs()
	local weeTs = getWeeTs()
	
    if not uid or not action then
        response.ret = -102
        return response
    end

    local aname = 'zhanshuyantao'
        
    local uobjs = getUserObjs(uid)
    uobjs.load({"userinfo",'useractive','bag','troops','accessory'})
    local mUseractive = uobjs.getModel('useractive')
    local mUserinfo = uobjs.getModel('userinfo')
	local mTroops = uobjs.getModel('troops')
    local mAccessory = uobjs.getModel('accessory')
    local mBag = uobjs.getModel("bag")
    local mHero = uobjs.getModel('hero')
    local activStatus = mUseractive.getActiveStatus(aname)
    
    -- 活动检测
    if activStatus ~= 1 then
        response.ret = activStatus
        return response
    end
	
	local activeCfg = mUseractive.getActiveConfig(aname)
	
    --[[ 数据格式
        mUseractive.info[aname].t = weeTs -- 上次启动时间
		mUseractive.info[aname].m = { -- 当前讨论结果
            'sp','p1','p2','p3','p4','p5'
        }
        mUseractive.info[aname].f = 今日以免费的次数
        mUseractive.info[aname].n = 本次抗议次数
    ]]
    local harReward={}--和谐版客户端奖励
    if action == 1 then
        -- 当前还有讨论结果未结算
        if mUseractive.info[aname].m then
            response.ret = -1981
            return response
        end  
        
        if not mUseractive.info[aname].t or mUseractive.info[aname].t < weeTs then
            mUseractive.info[aname].t = ts
            mUseractive.info[aname].f = 0
        end
        
        if free then
            tid = 1
        end

        local gemCost = activeCfg['goldCost'..tid]
        local spStart = activeCfg['spStart'..tid] -- 启动时默认的高阶话题个数
        local itemNum = activeCfg.num -- 需要随机多少个话题
        local pool = activeCfg.poolStart
   
        if free then
            local freeNum = activeCfg.free
            if (mUseractive.info[aname].f or 0) >= freeNum then
                response.ret = -2032
                return response
            end
            mUseractive.info[aname].f = (mUseractive.info[aname].f or 0) + 1
        else
            if not mUserinfo.useGem(gemCost) then
                response.ret = -109
                return response
            end
            regActionLogs(uid,1,{action=107,item="",value=gemCost,params={action=action,tid=tid}})
        end
    
        local m = {}
        for i=1,itemNum do
            local result = getRewardByPool(pool)
            for rk,rv in pairs(result) do
                table.insert(m,rk)
            end
        end
        
        if #m > itemNum then
            del = #m - itemNum
            for i=1,del do
                table.remove(m,1)
            end
        end
        
        if spStart > 0 then
            local rand = {3,1,2,5} -- 写死4个足够用，如果这货运气好到4个都是sp那给不给默认也无所谓
            for i,v in pairs(rand) do
                if spStart > 0 and m[i] ~= 'sp' then
                    m[i] = 'sp'
                    spStart = spStart - 1
                    if spStart <= 0 then
                        break
                    end
                end
            end
        end
        
        mUseractive.info[aname].m = m
        mUseractive.info[aname].t = ts
        -- 次数记录
        if tid==1 then
           mUseractive.info[aname].yn = 1
        else
           mUseractive.info[aname].yn = 4
        end
    elseif action == 2 then
        if not mUseractive.info[aname].m then
            response.ret = -4001
            return response
        end
        
        local n = tonumber(mUseractive.info[aname].n) or 0
        local reStartTime = activeCfg.reStartTime -- 重开次数

        if n >= reStartTime then
            response.ret = -4001
            return response
        end
        
        local itemNum = activeCfg.num -- 需要随机多少个话题
        local gemCost = activeCfg.reStartGoldCost[n + 1]
        local pool = activeCfg.poolRestart
        
        if not mUserinfo.useGem(gemCost) then
            response.ret = -109
            return response
        end
        
        local m = copyTable(mUseractive.info[aname].m)
        local spNum = 0
        for i,v in pairs(m) do
            if v == 'sp' then
                spNum = spNum + 1
            end
        end
        
        if spNum >= itemNum then
            response.ret = -4001
            return response
        end
        
        for i,v in pairs(m) do
            if not m[i] or m[i] ~= 'sp' then
                local result = getRewardByPool(pool)
                -- print('result',json.encode(result))
                local new = ''
                for rk,rv in pairs(result) do
                    new = rk
                end
                m[i] = new
            end
        end
        
        if #m > itemNum then
            del = #m - itemNum
            for i=1,del do
                table.remove(m,1)
            end
        end
        
        mUseractive.info[aname].m = m
        mUseractive.info[aname].n = n + 1
        
        regActionLogs(uid,1,{action=107,item="",value=gemCost,params={action=action,m=mUseractive.info[aname].m}})
        -- 次数记录
        mUseractive.info[aname].yn = mUseractive.info[aname].yn + 1
    elseif action == 3 then
        if not mUseractive.info[aname].m then
            response.ret = -1981
            return response
        end
        
        local spNum = 0
        for i,v in pairs(mUseractive.info[aname].m) do
            if v == 'sp' then
                spNum = spNum + 1
            end
        end
        
        local reward = activeCfg.serverreward[spNum] or {}
        if not takeReward(uid,reward) then        
            response.ret = -403
            return response
        end
        
        mUseractive.info[aname].m = nil
        mUseractive.info[aname].n = 0
        
        -- 和谐版活动
        if moduleIsEnabled('harmonyversion') ==1 then
            local hReward,hClientReward = harVerGifts('active','zhanshuyantao', mUseractive.info[aname].yn)
            if not takeReward(uid,hReward) then
                response.ret = -403
                return response
            end
            harReward = hClientReward
        end
        
        -- 次数清理（包含免费）
        mUseractive.info[aname].yn = 0      
    end
    
    
    processEventsBeforeSave()

    if  uobjs.save() then        
        processEventsAfterSave()
		
        response.ret = 0
		response.data[aname] = mUseractive.info[aname]
        if next(harReward) then
           response.data[aname].hReward=harReward
        end
		response.data.accessory = mAccessory.toArray(true)
		response.data.bag = mBag.toArray(true)
		response.data.troops = mTroops.toArray(true)
		response.data.userinfo = mUserinfo.toArray(true)
        response.data.hero = mHero.toArray(true)
        response.msg = 'Success'
    end
    
    return response
end