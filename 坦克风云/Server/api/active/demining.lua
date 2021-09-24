--desc: 排雷大作战
--user: liming
local function api_active_demining(request)
	local self={
	    response={
	       ret=-1,
	       msg='error',
           data={},
		},
		aname="demining",
    }
    --初始化数据
    function self.action_init(request)
        local uid = request.uid
        local response = self.response
        local ts= getClientTs()
        local weeTs = getWeeTs()
        local uobjs = getUserObjs(uid)
        uobjs.load({"userinfo","props","bag",'useractive'})
        local mUseractive = uobjs.getModel('useractive')
        local mUserinfo = uobjs.getModel('userinfo')
        local activeCfg = mUseractive.getActiveConfig(self.aname)
        -- 活动检测
        local activStatus = mUseractive.getActiveStatus(self.aname)
        if activStatus ~= 1 then
            response.ret = activStatus
            return response
        end
        local partName = copyTable(activeCfg.partName)
        local randnum = {}
        randnum = table.rand(partName)
        local cell={}
        local status = mUseractive.info[self.aname].status or 0
        if status == 0 then 
            for i=1,activeCfg.cellNum do
                    table.insert(cell,0)
                end
            mUseractive.info[self.aname].randPart = randnum
            mUseractive.info[self.aname].cell = cell 
        end
        local support = {}
        local task = {}
        for i=1,7 do
            table.insert(support,0)
        end
        for i=1,7 do
            table.insert(task,0)
        end
        if mUseractive.info[self.aname].support == nil then
           mUseractive.info[self.aname].support = support
           mUseractive.info[self.aname].task = task
        end
        if uobjs.save() then
            response.data[self.aname] =mUseractive.info[self.aname]
            response.ret = 0
            response.msg = 'Success'
        else
            response.ret=-106
        end
        return response        
    end
    --消费开始
    function self.action_cost(request)
        local response = self.response
        local uid = tonumber(request.uid) or 0
        local num = tonumber(request.params.num)
        local free = tonumber(request.params.free)
        if not table.contains({0, 1}, free) or not table.contains({1, 5}, num) then
            response.ret = -102
            return response
        end
        local ts = getClientTs()
        local weeTs = getWeeTs()
        local uobjs = getUserObjs(uid)
        uobjs.load({"userinfo", "useractive"})
        local mUseractive = uobjs.getModel('useractive')
        local mUserinfo = uobjs.getModel('userinfo')
        local activeStatus = mUseractive.getActiveStatus(self.aname)
        if  activeStatus ~= 1 then
            response.ret = -1977
            return response
        end
        if free == 1 and num > 1 then
            response.ret = -102
            return response
        end
        if mUseractive.info[self.aname].t ~= weeTs then
            mUseractive.info[self.aname].v = 0
            mUseractive.info[self.aname].t = weeTs
        end
        if mUseractive.info[self.aname].v == 1 and free == 1 then
            response.ret = -102
            return response
        end
        if mUseractive.info[self.aname].v == 0 and free ~= 1 then
            response.ret = -102
            return response
        end
        local activeCfg  = mUseractive.getActiveConfig(self.aname)
        local gems = 0
        if free == 1 then
            mUseractive.info[self.aname].v = 1
            mUseractive.info[self.aname].rich = 1
        else
            if num == 1 then
                gems = activeCfg.cost1
                mUseractive.info[self.aname].rich = 1
            else 
                gems = activeCfg.cost2
                mUseractive.info[self.aname].rich = 2
            end
        end
        if not mUserinfo.useGem(gems) then
            response.ret = -109
            return response
        end
        if gems > 0 then
            regActionLogs(uid, 1, {action = 191, item = "", value = gems, params = {num = num}})
        end
        mUseractive.info[self.aname].status = 1
         -- 和谐版判断
        local harCReward={}
        if moduleIsEnabled('harmonyversion') ==1 then
            local hReward,hClientReward = harVerGifts('active','demining',num)
            if not takeReward(uid,hReward) then
                response.ret = -403
                return response
            end
            harCReward = hClientReward
        end
        if uobjs.save() then
            response.data[self.aname] =mUseractive.info[self.aname]
            if next(harCReward) then
                response.data[self.aname].hReward=harCReward
            end
            response.ret = 0
            response.msg = 'Success'
        else
            response.ret=-106
        end
        return response        
    end
     -- 开始扫雷
    function self.action_gamestart(request)
        local uid = request.uid
        local index= request.params.index   
        local response = self.response
        local ts= getClientTs()
        local weeTs = getWeeTs()
        local uobjs = getUserObjs(uid)
        uobjs.load({"userinfo","props","bag",'useractive','accessory'})
        local mBag = uobjs.getModel('bag')
        local mAccessory = uobjs.getModel('accessory')
        local mUseractive = uobjs.getModel('useractive')
        local mUserinfo = uobjs.getModel('userinfo')
        local rich =  mUseractive.info[self.aname].rich 
        -- 活动检测
        local activStatus = mUseractive.getActiveStatus(self.aname)
        if activStatus ~= 1 then
            response.ret = activStatus
            return response
        end
        if rich==nil then
            response.ret=-109
            return response
        end
        -- mUseractive.info[self.aname].status = 1
        if mUseractive.info[self.aname].status == 0 then
            response.ret=-109
            return response
        end
        if rich == 1 then
            mUseractive.info[self.aname].totalCount = (mUseractive.info[self.aname].totalCount or 0) + 1
        end
        if rich == 2 then
            mUseractive.info[self.aname].totalCount = (mUseractive.info[self.aname].totalCount or 0) + 5
        end
        mUseractive.info[self.aname].task[6] = mUseractive.info[self.aname].totalCount
        mUseractive.info[self.aname].task[7] = mUseractive.info[self.aname].totalCount
        mUseractive.info[self.aname].count = (mUseractive.info[self.aname].count or 0) + 1
        local activeCfg = mUseractive.getActiveConfig(self.aname)
        local partCell = activeCfg.partCell
        local index1
        for k,v in ipairs(partCell) do
          for k1,v1 in ipairs(v) do
             if index == v1 then
                index1 = k
             end 
          end
        end
        local pool = mUseractive.info[self.aname].randPart[index1]
        local report = {}
        local reward = {} --普通道具
        local spprop = {} --特殊道具
        local pool = 'pool'..pool
        local rewardCfg = {}
        local rewardtmpCfg = {}
        rewardtmpCfg = getRewardByPool(activeCfg.serverreward[pool])
        local num
        if rich == 1 then
            for k, v in pairs(rewardtmpCfg or {}) do
                rewardCfg[k] = (rewardCfg[k] or 0) + v
            end
            num = 1
        end
        if rich == 2 then
            for k, v in pairs(rewardtmpCfg or {}) do
                rewardCfg[k] = (rewardCfg[k] or 0) + v*5
            end
            
            num = 5
        end
        for k,v in pairs(rewardCfg) do
            reward[k] = (reward[k] or 0) + v
        end 

        local redis = getRedis()
        local redkey ="zid."..getZoneId()..self.aname..mUseractive.info[self.aname].st.."uid."..uid
        local newwheel = mUseractive.info[self.aname].newwheel or 0
         -- newwheel = 0
        local data = redis:get(redkey)
        data = json.decode(data)
        -- 和谐版判断
        local harCReward={}
        if moduleIsEnabled('harmonyversion') ==1 then
            local hReward,hClientReward = harVerGifts('active','demining',num)
            harCReward = hClientReward
        end
        local res = {}
        local taskList = activeCfg.serverreward.taskList

        if mUseractive.info[self.aname].count <= activeCfg.luckyNum then
            if next(reward) then
                for k,v in pairs(reward) do
                    for k1,v1 in pairs(mUseractive.info[self.aname].cell) do
                        if k1 == index then
                           mUseractive.info[self.aname].cell[index] = formatReward({[k]=v})
                        end
                    end
                    table.insert(report, formatReward({[k]=v}))
                end
                if not takeReward(uid,reward) then
                    response.ret = -403
                    return response
                end
              
                if newwheel == 0 then
                    if type (data)~="table" then
                        data = {}
                    end
                    table.insert(res,formatReward(reward))
                    table.insert(data,1,{ts,res,num,harCReward})
                    if #data >10 then
                        for i=#data,11 do
                            table.remove(data)
                        end
                    end
                    mUseractive.info[self.aname].newwheel = 1
                    --轮数
                    mUseractive.info[self.aname].wheelnum = (mUseractive.info[self.aname].wheelnum or 0) + 1
                end
                if newwheel == 1 then
                    table.insert(data[1][2],1,formatReward(reward))
                end
            end
        else
            setRandSeed()
            local rd = rand(1,100)
            local surplus = activeCfg.cellNum - mUseractive.info[self.aname].count + 1
            local rate = math.ceil((activeCfg.bombNum/surplus)*100)
            if rd < rate then
                report = {}
                if mUseractive.info[self.aname].count >= taskList[1].num[2] then 
                   mUseractive.info[self.aname].task[1] = mUseractive.info[self.aname].task[1] + 1
                end
                if mUseractive.info[self.aname].count >= taskList[2].num[2] then 
                   mUseractive.info[self.aname].task[2] = mUseractive.info[self.aname].task[2] + 1
                end
                if mUseractive.info[self.aname].count >= taskList[3].num[2] then 
                   mUseractive.info[self.aname].task[3] = mUseractive.info[self.aname].task[3] + 1
                end
                if mUseractive.info[self.aname].count >= taskList[4].num[2] then 
                   mUseractive.info[self.aname].task[4] = mUseractive.info[self.aname].task[4] + 1
                end
                if mUseractive.info[self.aname].count >= taskList[5].num[2] then 
                   mUseractive.info[self.aname].task[5] = mUseractive.info[self.aname].task[5] + 1
                end
                mUseractive.info[self.aname].cell[index] = {}
                mUseractive.info[self.aname].status = 0
                mUseractive.info[self.aname].rich = 0
                mUseractive.info[self.aname].cell = {}
                mUseractive.info[self.aname].count = 0
                mUseractive.info[self.aname].randPart = {}
                mUseractive.info[self.aname].newwheel = 0
                local partName = copyTable(activeCfg.partName)
                local randnum = {}
                randnum = table.rand(partName)
                local cell={}
                for i=1,activeCfg.cellNum do
                        table.insert(cell,0)
                    end
                mUseractive.info[self.aname].randPart = randnum
                mUseractive.info[self.aname].cell = cell 
            else
                if next(reward) then
                    for k,v in pairs(reward) do
                        for k1,v1 in pairs(mUseractive.info[self.aname].cell) do
                            if k1 == index then
                               mUseractive.info[self.aname].cell[index] = formatReward({[k]=v})
                            end
                        end
                        table.insert(report, formatReward({[k]=v}))
                    end
                    if not takeReward(uid,reward) then
                        response.ret = -403
                        return response
                    end
                    if newwheel == 1 then
                        table.insert(data[1][2],1,formatReward(reward))
                    end
                end                
            end 
        end
        
        if uobjs.save() then
            if mUseractive.info[self.aname].status == 1 then
                data = json.encode(data)
                redis:set(redkey,data)
                redis:expireat(redkey,mUseractive.info[self.aname].et+86400)
            end
            response.data[self.aname] =mUseractive.info[self.aname]
            response.data[self.aname].reward = report
            -- response.data.bag = mBag.toArray(true)
            -- response.data.accessory = mAccessory.toArray(true)
            -- 
            -- response.data.userinfo = mUserinfo.toArray(true)
            response.ret = 0
            response.msg = 'Success'
        else
            response.ret=-106
        end
        return response        
    end
    --奖励记录
    function self.action_record(request)
        local response = self.response
        local uid = tonumber(request.uid) or 0
        local ts = getClientTs()
        local weeTs = getWeeTs()
        local uobjs = getUserObjs(uid)
        uobjs.load({"userinfo", "useractive"})
        local mUseractive = uobjs.getModel('useractive')
        local mUserinfo = uobjs.getModel('userinfo')
        local activeStatus = mUseractive.getActiveStatus(self.aname)
        if  activeStatus ~= 1 then
            response.ret = -1977
            return response
        end
        local redis = getRedis()
        local redkey = "zid."..getZoneId()..self.aname..mUseractive.info[self.aname].st.."uid."..uid
        local data = redis:get(redkey)
        data = json.decode(data)
        if data == nil then
            data = {}
        end
        if uobjs.save() then
            response.data[self.aname] =mUseractive.info[self.aname]
            response.data[self.aname].reward = data
            response.ret = 0
            response.msg = 'Success'
        else
            response.ret=-106
        end
        return response        
    end
    --任务
    function self.action_task(request)
        local response = self.response
        local uid = tonumber(request.uid) or 0
        local index = tonumber(request.params.index)
        local ts = getClientTs()
        local weeTs = getWeeTs()
        local uobjs = getUserObjs(uid)
        uobjs.load({"userinfo","props","bag",'useractive','accessory','hero'})
        local mEquip= uobjs.getModel('equip')
        local mHero = uobjs.getModel('hero')
        local mBag = uobjs.getModel('bag')
        local mAccessory = uobjs.getModel('accessory')
        local mUseractive = uobjs.getModel('useractive')
        local mUserinfo = uobjs.getModel('userinfo')
        local activeStatus = mUseractive.getActiveStatus(self.aname)
        if  activeStatus ~= 1 then
            response.ret = -1977
            return response
        end
        local report = {}
        local reward = {} --普通道具
        local rewardCfg = {}
        local activeCfg = mUseractive.getActiveConfig(self.aname)
        local taskList = activeCfg.serverreward.taskList[index]
        rewardCfg = activeCfg.serverreward.taskList[index].serverreward
        for k,v in pairs(rewardCfg) do
            reward[v[1]] = (reward[v[1]] or 0) + v[2]
        end
        local task = mUseractive.info[self.aname].task
        if task[index] < taskList.num[1] then
           response.ret = -109
           return response 
        end
        if mUseractive.info[self.aname].support[index] == 1 then
            response.ret = -1976
            return response
        end
        if next(reward) then
            for k,v in pairs(reward) do
                table.insert(report, formatReward({[k]=v}))
            end
            if not takeReward(uid,reward) then
                response.ret = -403
                return response
            end
            mUseractive.info[self.aname].support[index] = 1
        end
        if uobjs.save() then
            response.data[self.aname] =mUseractive.info[self.aname]
            response.data[self.aname].reward = report
            -- response.data.equip = mEquip.toArray(true)
            -- response.data.hero = mHero.toArray(true)
            -- response.data.accessory = mAccessory.toArray(true)
            -- response.data.userinfo = mUserinfo.toArray(true)
            response.ret = 0
            response.msg = 'Success'
        else
            response.ret=-106
        end
        return response        
    end

    return self
end

return api_active_demining
