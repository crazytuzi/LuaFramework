--desc: 鬼牌决胜
--user: liming
local function api_active_ghost(request)
	local self={
	    response={
	       ret=-1,
	       msg='error',
           data={},
		},
		aname="ghost",
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
    --消费开始 开启一轮
    function self.action_cost(request)
        local response = self.response
        local uid = tonumber(request.uid) or 0
        local num = tonumber(request.params.num)
        local free = tonumber(request.params.free)--0非免费 1免费
        if not table.contains({0,1},free) or not num or not uid then
           response.ret=-102
           return response
        end
        local ts = getClientTs()--服务器时间
        local weeTs = getWeeTs()--当天凌晨时间戳
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
        else
            gems = activeCfg.cost1
        end
        if not mUserinfo.useGem(gems) then
            response.ret = -109
            return response
        end
        if gems > 0 then
            regActionLogs(uid, 1, {action = 192, item = "", value = gems, params = {num = num}})
        end
        mUseractive.info[self.aname].status = 1
        local changeNum = activeCfg.changeNum
        local cellNum = activeCfg.cellNum
        local bombNum = activeCfg.bombNum
        local luckyNum = activeCfg.luckyNum
        local rewardCfg = {}
        local rewardtmpCfg = {}
        local position = {}
        local sign
        local res = {}
        while #rewardtmpCfg <  7 do
            if #rewardtmpCfg < changeNum-1 then
               res = getRewardByPool(activeCfg.serverreward.pool1)
            else
               res = getRewardByPool(activeCfg.serverreward.pool2)
            end
            sign = self.check(res,rewardtmpCfg)
            if sign == false then
               table.insert(rewardtmpCfg,res)
            end
        end
        for i=1,cellNum do
            table.insert(position,{})
        end
        for k,v in pairs(rewardtmpCfg) do
            table.insert(rewardCfg,formatReward(v))
        end
        setRandSeed()
        for i=luckyNum + 1,cellNum do
            local rd = rand(1,100)
            local surplus = cellNum-i+1
            local rate = math.ceil((bombNum/surplus)*100)
            if rd < rate then
               rewardCfg[i] = {}
               rewardtmpCfg[i] = {}
               mUseractive.info[self.aname].g = i
               break
            end 
        end
        -- ptb:p(mUseractive.info[self.aname].g)
        mUseractive.info[self.aname].cell = rewardCfg 
        mUseractive.info[self.aname].backcell = rewardtmpCfg
        mUseractive.info[self.aname].position = position 
         -- 和谐版判断
        local harCReward={}
        if moduleIsEnabled('harmonyversion') ==1 then
            local hReward,hClientReward = harVerGifts('active','ghost',num)
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
     -- 开始翻牌
    function self.action_gamestart(request)
        local uid = request.uid
        local index = tonumber(request.params.index) 
        local num = 1  
        local response = self.response
        local ts= getClientTs()
        local weeTs = getWeeTs()
        local uobjs = getUserObjs(uid)
        uobjs.load({"userinfo","props","bag",'useractive','accessory'})
        local mBag = uobjs.getModel('bag')
        local mAccessory = uobjs.getModel('accessory')
        local mUseractive = uobjs.getModel('useractive')
        local mUserinfo = uobjs.getModel('userinfo')
        -- 活动检测
        local activStatus = mUseractive.getActiveStatus(self.aname)
        if activStatus ~= 1 then
            response.ret = activStatus
            return response
        end
        -- mUseractive.info[self.aname].status = 1
        if mUseractive.info[self.aname].status == 0 then
            response.ret=-109
            return response
        end
        mUseractive.info[self.aname].totalCount = (mUseractive.info[self.aname].totalCount or 0) + 1
        mUseractive.info[self.aname].task[6] = mUseractive.info[self.aname].totalCount
        mUseractive.info[self.aname].count = (mUseractive.info[self.aname].count or 0) + 1
        mUseractive.info[self.aname].task[7] = mUseractive.info[self.aname].totalCount
        local count = mUseractive.info[self.aname].count
        if count == 1 then
            --轮数
            mUseractive.info[self.aname].wheelnum = (mUseractive.info[self.aname].wheelnum or 0) + 1
        end
        local activeCfg = mUseractive.getActiveConfig(self.aname)
        local ghostItem = activeCfg.serverreward.ghostItem
        local taskList = activeCfg.serverreward.taskList
        local reports={}
        for k,v in pairs(ghostItem) do
            table.insert(reports, formatReward({[k]=v}))
        end
        local report = {}
        local reward = {} --普通道具
        local rewardCfg = mUseractive.info[self.aname].cell
        local position = mUseractive.info[self.aname].position
        if count == mUseractive.info[self.aname].g then
            report = {}
            if count >= taskList[1].num[2] then 
               mUseractive.info[self.aname].task[1] = mUseractive.info[self.aname].task[1] + 1
            end
            if count >= taskList[2].num[2] then 
               mUseractive.info[self.aname].task[2] = mUseractive.info[self.aname].task[2] + 1
            end
            if count >= taskList[3].num[2] then 
               mUseractive.info[self.aname].task[3] = mUseractive.info[self.aname].task[3] + 1
            end
            if count >= taskList[4].num[2] then 
               mUseractive.info[self.aname].task[4] = mUseractive.info[self.aname].task[4] + 1
            end
            if count >= taskList[5].num[2] then 
               mUseractive.info[self.aname].task[5] = mUseractive.info[self.aname].task[5] + 1
            end
            mUseractive.info[self.aname].status = 0
            mUseractive.info[self.aname].count = 0
            mUseractive.info[self.aname].cell = {}
            if not takeReward(uid,ghostItem) then
                response.ret = -403
                return response
            end
        else
            if count == 6 then
                if count >= taskList[1].num[2] then 
                   mUseractive.info[self.aname].task[1] = mUseractive.info[self.aname].task[1] + 1
                end
                if count >= taskList[2].num[2] then 
                   mUseractive.info[self.aname].task[2] = mUseractive.info[self.aname].task[2] + 1
                end
                if count >= taskList[3].num[2] then 
                   mUseractive.info[self.aname].task[3] = mUseractive.info[self.aname].task[3] + 1
                end
                if count >= taskList[4].num[2] then 
                   mUseractive.info[self.aname].task[4] = mUseractive.info[self.aname].task[4] + 1
                end
                if count >= taskList[5].num[2] then 
                   mUseractive.info[self.aname].task[5] = mUseractive.info[self.aname].task[5] + 1
                end
                local backcell = mUseractive.info[self.aname].backcell
                for k,v in pairs(backcell) do 
                    if k > count then
                        break
                    end
                    for k1,v1 in pairs(v) do 
                        reward[k1] = (reward[k1] or 0) + v1
                    end
                end
                if next(reward) then
                    for k,v in pairs(reward) do
                        table.insert(report, formatReward({[k]=v}))
                    end
                    if not takeReward(uid,reward) then
                        response.ret = -403
                        return response
                    end
                end
                position[index] = rewardCfg[count] or {}
                mUseractive.info[self.aname].status = 0
                mUseractive.info[self.aname].count = 0
                mUseractive.info[self.aname].cell = {}
            else
                position[index] = rewardCfg[count] or {}
            end
        end
        -- 和谐版判断
        local harCReward={}
        if moduleIsEnabled('harmonyversion') ==1 then
            local hReward,hClientReward = harVerGifts('active','ghost',num)
            harCReward = hClientReward
        end
        if uobjs.save() then
            local redis =getRedis()
            local redkey ="zid."..getZoneId()..self.aname..mUseractive.info[self.aname].st.."uid."..uid
            local data =redis:get(redkey)
            data =json.decode(data)
            if type (data)~="table" then data={} end
            if count == 6 and mUseractive.info[self.aname].g == 7 then
               table.insert(data,1,{ts,report,num,harCReward})
            end
            if mUseractive.info[self.aname].status == 0 and count < 7 and mUseractive.info[self.aname].g ~= 7 then 
                table.insert(data,1,{ts,reports,num,harCReward})
            end
            if next(data) then
                if #data >10 then
                    for i=#data,11 do
                        table.remove(data)
                    end
                end
                data=json.encode(data)
                redis:set(redkey,data)
                redis:expireat(redkey,mUseractive.info[self.aname].et+86400)
            end       
            response.data[self.aname] = mUseractive.info[self.aname]
            response.data[self.aname].reward = report
            -- response.data.bag = mBag.toArray(true)
            -- response.data.accessory = mAccessory.toArray(true)
            response.ret = 0
            response.msg = 'Success'
        else
            response.ret=-106
        end
        return response        
    end
    --停止游戏
    function self.action_stop(request)
        local response = self.response
        local uid = tonumber(request.uid) or 0
        local num = 1
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
        if mUseractive.info[self.aname].status == 0 then
            response.ret = -109
            return response
        end 
        local activeCfg = mUseractive.getActiveConfig(self.aname)
        local taskList = activeCfg.serverreward.taskList
        local count = mUseractive.info[self.aname].count
        local backcell = mUseractive.info[self.aname].backcell
        local reward = {}
        local res = {}
        if count >= taskList[1].num[2] then 
           mUseractive.info[self.aname].task[1] = mUseractive.info[self.aname].task[1] + 1
        end
        if count >= taskList[2].num[2] then 
           mUseractive.info[self.aname].task[2] = mUseractive.info[self.aname].task[2] + 1
        end
        if count >= taskList[3].num[2] then 
           mUseractive.info[self.aname].task[3] = mUseractive.info[self.aname].task[3] + 1
        end
        if count >= taskList[4].num[2] then 
           mUseractive.info[self.aname].task[4] = mUseractive.info[self.aname].task[4] + 1
        end
        if count >= taskList[5].num[2] then 
           mUseractive.info[self.aname].task[5] = mUseractive.info[self.aname].task[5] + 1
        end
        for k,v in pairs(backcell) do 
            if k > count then
                break
            end
            for k1,v1 in pairs(v) do 
                reward[k1] = (reward[k1] or 0) + v1
            end
        end
        if next(reward) then
            for k,v in pairs(reward) do
                table.insert(res, formatReward({[k]=v}))
            end
            if not takeReward(uid,reward) then
                response.ret = -403
                return response
            end
        end
        mUseractive.info[self.aname].status = 0
        mUseractive.info[self.aname].count = 0
        mUseractive.info[self.aname].cell = {}
        -- 和谐版判断
        local harCReward={}
        if moduleIsEnabled('harmonyversion') ==1 then
            local hReward,hClientReward = harVerGifts('active','ghost',num)
            harCReward = hClientReward
        end
        if uobjs.save() then
            local redis =getRedis()
            local redkey ="zid."..getZoneId()..self.aname..mUseractive.info[self.aname].st.."uid."..uid
            local data =redis:get(redkey)
            data =json.decode(data)
            if type (data)~="table" then data={} end
            table.insert(data,1,{ts,res,num,harCReward})
            if next(data) then
                if #data >10 then
                    for i=#data,11 do
                        table.remove(data)
                    end
                end
                data=json.encode(data)
                redis:set(redkey,data)
                redis:expireat(redkey,mUseractive.info[self.aname].et+86400)
            end       
            response.data[self.aname] =mUseractive.info[self.aname]
            response.data[self.aname].reward = res
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
        uobjs.load({"userinfo","props","bag",'useractive','accessory','hero','equip'})
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
    function self.check(res,rewardtmpCfg)
        if not next(rewardtmpCfg) then
            return false
        end
        for k,v in pairs(rewardtmpCfg) do
            for k1,v1 in pairs(v) do 
               for k2,v2 in pairs(res) do 
                  if k1==k2 and v1==v2 then
                     return true
                  end
               end
            end
        end
        return false
    end

    return self
end

return api_active_ghost
