-- 万圣节大作战
-- 参数：
-- action 1 开炮消除，2 领取任务奖励
-- index 选中的位置id，tid 任务id

function api_active_wanshengjiedazuozhan(request)
    local response = {
        ret=-1,
        msg='error',
        data = {},
    }

    local uid = request.uid
	local free = request.params.free or nil
	local action = tonumber(request.params.action) or nil
	local index = tonumber(request.params.index) or nil
	local tid = request.params.tid or nil
	local ts = getClientTs()
	local weeTs = getWeeTs()
	
    if uid == nil then
        response.ret = -102
        return response
    end

    local aname = 'wanshengjiedazuozhan'
        
    local uobjs = getUserObjs(uid)
    uobjs.load({"userinfo",'useractive','bag','troops','accessory','hero','props'})
    local mUseractive = uobjs.getModel('useractive')
    local mUserinfo = uobjs.getModel('userinfo')
	local mTroops = uobjs.getModel('troops')
    local mAccessory = uobjs.getModel('accessory')
    local mBag = uobjs.getModel("bag")
    local mHero = uobjs.getModel("hero")
    local mProp = uobjs.getModel("props")
    local mAlien= uobjs.getModel('alien')
    local mEquip= uobjs.getModel('equip')
    local activStatus = mUseractive.getActiveStatus(aname)

    -- 活动检测
    if activStatus ~= 1 then
        response.ret = activStatus
        return response
    end
	
	local activeCfg = getActiveCfg(uid, aname)
	local gemCost = activeCfg.cost or nil
	
	if not gemCost then -- 配置不对
		response.ret = -102
		return response
	end
	
    --[[ 数据格式
        mUseractive.info[aname].t = weeTs -- 上次免费时间戳
		mUseractive.info[aname].l = {} -- boss血量
		mUseractive.info[aname].r = { -- 消除记录
            k1 = 0, -- 击杀南瓜1次数
            k2 = 0, -- 击杀南瓜2次数
            k3 = 0, -- 击杀南瓜3次数
            hit = 0, -- 一次性连击最大次数
        }
        mUseractive.info[aname].f = {t1=1,t2=1} -- 任务领取记录
    ]]
    local harCReward={}--和谐版返回客户端奖励
    local lotterylog = {r={},hr={}}
    if action == 1 then
        if index == nil then
            response.ret = -102
            return response
        end

        if free and (not mUseractive.info[aname].t or mUseractive.info[aname].t < weeTs) then
            mUseractive.info[aname].t = weeTs
        else
            if not mUserinfo.useGem(gemCost) then
                response.ret = -109
                return response
            end
        end
        
        if not mUseractive.info[aname].m then
            mUseractive.info[aname].m = activeCfg.map
        end
        
        if not mUseractive.info[aname].l then
            mUseractive.info[aname].l = activeCfg.bossLife
        end
        
        if not mUseractive.info[aname].r then
            mUseractive.info[aname].r = {}
        end
        
        local report = {normal={},boss={}}
        local col = {}
        local colNum = activeCfg.serverreward.column
        local itemNum = table.length(mUseractive.info[aname].m)
        local layerNum = math.ceil(itemNum / colNum)
        -- print('colNum',colNum)
        -- print('itemNum',itemNum)
        
        -- 初始化每列id索引 用于计算下落
        for i=1,colNum do
            if not col[i] then
                col[i] = {}
            end
            for j=1,layerNum do
                if j == 1 then
                    col[i][j] = i
                else
                    col[i][j] = col[i][j-1] + colNum
                end
            end
        end
        
        local map = copyTable(mUseractive.info[aname].m)
        
        -- print('before')
        -- for i=1,#map,colNum do
            -- print(map[i],map[i+1],map[i+2])
        -- end
        
        local selectType = tonumber(map[index])
        local list = {}

        -- 计算相连南瓜数量
        function clearPumpkin(id)
            local self = id
            local status = 0
            if map[self] and not list[self] then
                list[self] = 1
                clearPumpkin(self)
                status = 1
            end
            -- print('self',self,map[self],status)

            local top = id - colNum
            local status = 0
            if map[top] and tonumber(map[top]) == selectType and not list[top] then
                list[top] = 1
                clearPumpkin(top)
                status = 1
            end
            -- print('top',top,map[top],status)
            
            local bottom = id + colNum
            local status = 0
            if map[bottom] and tonumber(map[bottom]) == selectType and not list[bottom] then
                list[bottom] = 1
                clearPumpkin(bottom)
                status = 1
            end
            -- print('bottom',bottom,map[bottom],status)

            if id % colNum ~= 1 then
                local left = id - 1
                local status = 0
                if map[left] and tonumber(map[left]) == selectType and not list[left] then
                    list[left] = 1
                    clearPumpkin(left)
                    status = 1
                end
                -- print('left',left,map[left],status)
            end
            
            if id % colNum ~= 0 then
                local right = id + 1
                local status = 0
                if map[right] and tonumber(map[right]) == selectType and not list[right] then
                    list[right] = 1
                    clearPumpkin(right)
                    status = 1
                end
                -- print('right',right,map[right],status)
            end

            return list
        end

        clearPumpkin(index)
        -- print('list')
        -- ptb:p(list)
        
        -- 消除南瓜 boss扣血
        local hitNum = table.length(list)
        -- print('active')
        -- ptb:p(activeCfg.pumpkinLife)
        -- print('selectType',selectType,type(selectType))
        local damage = activeCfg.pumpkinLife[selectType]
        -- print('damage',damage)
        local bossKill = false

        for i,v in pairs(list) do
            if damage then
                if damage >= mUseractive.info[aname].l[selectType] then
                    local keep = damage - mUseractive.info[aname].l[selectType]
                    mUseractive.info[aname].l[selectType] = activeCfg.bossLife[selectType] - keep
                    bossKill = true
                    -- boss击杀记录
                    mUseractive.info[aname].r['kb'..selectType] = (mUseractive.info[aname].r['kb'..selectType] or 0) + 1
                else
                    mUseractive.info[aname].l[selectType] = mUseractive.info[aname].l[selectType] - damage
                end
            end
            
            -- 消除记录累加
            mUseractive.info[aname].r['k'..selectType] = (mUseractive.info[aname].r['k'..selectType] or 0) + 1

            map[i] = nil
        end
        
        -- 记录一次性消除数量
        if not mUseractive.info[aname].r['hit'] or hitNum > mUseractive.info[aname].r['hit'] then
            mUseractive.info[aname].r['hit'] = hitNum
        end

        -- 处理南瓜下落
        for cid,cdata in pairs(col) do
            for i=1,layerNum do
                for j=layerNum,1,-1 do
                    if j > 1 and not map[col[cid][j]] and map[col[cid][j-1]] then
                        map[col[cid][j]] = map[col[cid][j-1]]
                        map[col[cid][j-1]] = nil
                    end
                end
            end
        end
        
        function randItem()
            local rdata = getRewardByPool(activeCfg.serverreward['pumpkinPool'])

            local key = 0
            for i,v in pairs(rdata) do
                key = tonumber(i)
            end
            
            return key
        end
        
        -- print('map')
        -- ptb:p(map)
        
        -- print('itemNum',itemNum)
        local newItem = {}
        for i=1,itemNum do
            if not map[i] then
                map[i] = randItem()
                table.insert(newItem,{i,map[i]})
            end
        end
        
        mUseractive.info[aname].m = map

        -- 按消除数量抽奖
        for i=1,hitNum do
            local rewardPool = activeCfg.serverreward['normal'..selectType]
            local result = getRewardByPool(rewardPool)
            
            table.insert(report['normal'],formatReward(result))

            for k,v in pairs(result) do
                lotterylog.r[k] = (lotterylog.r[k] or 0) + v
            end
            
            if not takeReward(uid,result) then
                response.ret = -1989
                return response
            end
        end
        
        if bossKill then
            local rewardPool = activeCfg.serverreward['boss'..selectType]
            local result = getRewardByPool(rewardPool)
            table.insert(report['boss'],formatReward(result))

            for k,v in pairs(result) do
                lotterylog.r[k] = (lotterylog.r[k] or 0) + v
            end
            
            if not takeReward(uid,result) then
                response.ret = -1989
                return response
            end
        end
   
        response.data.report = report
        response.data.newItem = newItem

        -- 和谐版活动
        if moduleIsEnabled('harmonyversion') ==1 then
            local hReward,hClientReward = harVerGifts('active','wanshengjiedazuozhan', 1)
            if not takeReward(uid,hReward) then
                response.ret = -403
                return response
            end
            harCReward=hClientReward

            lotterylog.hr = harCReward
        end
        
        -- print('after')
        -- for i=1,#map,colNum do
            -- print(map[i],map[i+1],map[i+2])
        -- end
        
        -- print('newItem')
        -- ptb:p(newItem)
        
    	if free then
    	   gemCost = 0
    	end
        regActionLogs(uid,1,{action=103,item="",value=gemCost,params={bossKill=bossKill,hitNum=hitNum}})
    elseif action == 2 then
        if tid == nil then
            response.ret = -102
            return response
        end
        
        if not mUseractive.info[aname].f then
            mUseractive.info[aname].f = {}
        end
            
        if mUseractive.info[aname].f[tid] == 1 then
            response.ret = -1976
            return response
        end

        local taskInfo = activeCfg.taskList[tid]
        if mUseractive.info[aname].r[taskInfo.conditions.type] >= taskInfo.conditions.num then
            mUseractive.info[aname].f[tid] = 1
            
            if not takeReward(uid,taskInfo.serverreward) then        
                response.ret = -403
                return response
            end
            response.data.reward = formatReward(taskInfo.serverreward)
        end
    elseif action==3 then
        local redis =getRedis()
        local redkey ="zid."..getZoneId()..aname..mUseractive.info[aname].st.."uid."..uid
        local data =redis:get(redkey)
        data =json.decode(data)

        if type(data) ~= 'table' then data = {} end
        response.ret = 0
        response.msg = 'Success'
        response.data.report=data
        return response
    end
    
    processEventsBeforeSave()

    if  uobjs.save() then        
        processEventsAfterSave()
		
        response.ret = 0
		response.data[aname] = mUseractive.info[aname]
        if next(harCReward) then
            response.data[aname].hReward=harCReward
        end

        if action==1 then
            local rewardlog = {}
            if next(lotterylog.r) then
                for k,v in pairs(lotterylog.r) do
                    table.insert(rewardlog,formatReward({[k]=v}))
                end
            end

            local redis =getRedis()
            local redkey ="zid."..getZoneId()..aname..mUseractive.info[aname].st.."uid."..uid
            local data =redis:get(redkey)
            data =json.decode(data)
            if type (data)~="table" then data={} end   
            table.insert(data,1,{ts,1,rewardlog,lotterylog.hr,1})
            if next(data) then
                for i=#data,11,-1 do
                    table.remove(data)
                end

                data=json.encode(data)
                redis:set(redkey,data)
                redis:expireat(redkey,mUseractive.info[aname].et+86400)
            end      
        end
        
		response.data.accessory = mAccessory.toArray(true)
		response.data.bag = mBag.toArray(true)
		response.data.troops = mTroops.toArray(true)
		response.data.userinfo = mUserinfo.toArray(true)
		response.data.hero = mHero.toArray(true)
		response.data.prop = mProp.toArray(true)
		response.data.alien = mAlien.toArray(true)
		response.data.equip =mEquip.toArray(true)
		response.msg = 'Success'
    end


    
    return response
end
