-- 百团争霸活动

local function api_active_quanxiantuwei(request)
    local self = {
        response = {
            ret = -1,
            msg = 'error',
            data = {},
        },
        
        -- 活动名
        aname = "qxtw",

        activeSt = 0, -- 起始时间
    }

    function self.before(request)
        local uid = request.uid
        local uobjs = getUserObjs(uid)
        local mUseractive = uobjs.getModel('useractive')
        local mUserinfo = uobjs.getModel('userinfo')

        -- 活动状态检测
        local activStatus = mUseractive.getActiveStatus(self.aname,rewardTs)
        if activStatus ~= 1 then
            local response = self.response
            response.ret = activStatus
            return response
        end
        local ts = getClientTs()
        local weeTs = getWeeTs()
        self.activeSt = mUseractive.info[self.aname].st
        self.activeEt = mUseractive.info[self.aname].et
        -- 每日凌晨重置免费次数
        if  mUseractive.info[self.aname].t < weeTs then
            mUseractive.info[self.aname].c = 0
            mUseractive.info[self.aname].tk={}
            mUseractive.info[self.aname].tr={}
            mUseractive.info[self.aname].t=weeTs
        end
        

    end
    -- 走线路
    function self.action_rand(request)
        local response = self.response
        local rand = tonumber(request.params.rand) or 2
        local uid = request.uid
        local uobjs = getUserObjs(uid)
        local aname = self.aname
        local mUseractive = uobjs.getModel('useractive')
        local mUserinfo = uobjs.getModel('userinfo')
        local activeCfg = mUseractive.getActiveConfig(aname)
        local activeInfo = mUseractive.info[aname]
        local redis =getRedis()
        local redkey="zid."..getZoneId()..aname..self.activeSt.."uid."..uid
    
        -- 免费
        local num=1
        local gemCost=0
        if rand==1 then
            if  activeInfo.c>=1 then
                response.ret=-102
                return response
            end
            activeInfo.c=1

        elseif rand==2 then
            gemCost=activeCfg.cost1

        elseif rand==3 then
            gemCost=activeCfg.cost2
            num=5
        end  
        if gemCost>0 then
             -- 使用金币
            if gemCost > 0 and not mUserinfo.useGem(gemCost) then
                response.ret = -109
                return response
            end

        end  
        local reward={}
        local report={}
        local data =redis:get(redkey)
        data =json.decode(data)
        local ts = getClientTs()
        if type (data)~="table" then data={}  end
        for i=1,num do
        
            local line=self.getRand(activeCfg.serverreward.randomRoad)
            local Num=self.getRand(activeCfg.serverreward.randomNum)
            if Num>activeCfg.map[line].maxPoint then
                Num=activeCfg.map[line].maxPoint
            end
            local pool=activeCfg.map[line].random[Num]
           
            local result=getRewardByPool(activeCfg.serverreward['pool'..pool])
            for k,v in pairs (result) do
                reward[k]=(reward[k] or 0)+v
            end
            local tmp={line,Num,formatReward(result)}
            table.insert(report,tmp)
        end
        -- 全线突围
        activity_setopt(uid,'qxtw',{action=2,num=num})
        if not takeReward(uid,reward) then
            response.ret=-403
            return response
        end
        local cliReward=copyTable(reward)
        -- 和谐版判断
        local harCReward={}
        if moduleIsEnabled('harmonyversion') ==1 then
            local hReward,hClientReward = harVerGifts('active','qxtw',num)
            if not takeReward(uid,hReward) then
                response.ret = -403
                return response
            end
            harCReward = hClientReward
            for k,v in pairs(hReward) do
                reward[k] =(reward[k] or 0) + v
            end
        end

        local tmp={num,formatReward(reward),ts}
        table.insert(data,1,tmp)        

        if gemCost>0 then
            regActionLogs(uid,1,{action=152,item="",value=gemCost,params={num=num,reward=reward}})
        end

        if uobjs.save() then
            if next(data) then
                if #data >10 then
                    for i=#data,11 do
                        table.remove(data)
                    end
                end
                data=json.encode(data)
                redis:set(redkey,data)
                redis:expireat(redkey,mUseractive.info[aname].et+86400)
            end
            response.data[aname] =mUseractive.info[aname]
            if next(harCReward) then
                response.data[aname].hReward=harCReward
            end                    
            response.ret = 0
            response.data.report=report
            response.data.reward=formatReward(cliReward)
            response.msg = 'Success'
        end
        return response
    end

    function self.getRand(cfg)
        setRandSeed()
        local tal=0
        local tmp={}
        for k,v in pairs (cfg) do
            tal=tal+v
            table.insert(tmp,tal)
        end
        local seed = rand(1, tal)
        for k,v in pairs (tmp) do
            if seed<=v then
                return k
            end
        end
    end
    -- 兑换军徽
    function self.action_change(request)
        local response = self.response
        local uid = request.uid
        local uobjs = getUserObjs(uid)
        local aname = self.aname
        local mUseractive = uobjs.getModel('useractive')
        local mUserinfo = uobjs.getModel('userinfo')
        local mBag = uobjs.getModel("bag")

        local activeCfg = mUseractive.getActiveConfig(aname)
        local count = tonumber(request.params.count) or 5
        local useprops={}
        local reward={}
        for k,v in pairs  (activeCfg.exchange.need[1]) do 
            useprops[k]=v*count
        end
        for k,v in pairs  (activeCfg.exchange.get[1]) do 
            reward[k]=v*count
        end
        
        if not mBag.usemore(useprops) then
            response.ret=-1996
            return response
        end
        if not takeReward(uid,reward) then
            response.ret=-403
            return response
        end
        if uobjs.save() then
            response.data.reward = formatReward(reward)
            response.ret = 0
            response.data.report=report
            response.msg = 'Success'
        end
        return response
    end


     -- 任务奖励
    function self.action_taskreward(request)
        local response = self.response
        local uid = request.uid
        local uobjs = getUserObjs(uid)
        local aname = self.aname
        local mUseractive = uobjs.getModel('useractive')
        local mUserinfo = uobjs.getModel('userinfo')
        local mBag = uobjs.getModel("bag")
        local activeCfg = mUseractive.getActiveConfig(aname)
        local tid=tonumber(request.params.tid) or 2
        if activeCfg.dailyTask[tid] ==nil then
            response.ret=-102
            return response
        end

        local num =mUseractive.info[aname].tk["t"..tid] or 0
        if num<activeCfg.dailyTask[tid].needNum then
            response.ret=-1981
            return response
        end
        if type(mUseractive.info[aname].tr)~='table' then  mUseractive.info[aname].tr={} end
        local flag=table.contains(mUseractive.info[aname].tr,tid)
        if flag then
            response.ret=-1976
            return response
        end 
        local reward=activeCfg.dailyTask[tid].serverreward
        if activeCfg.dailyTask[tid].love~=nil and activeCfg.dailyTask[tid].love>0 then
            mUseractive.info[aname].v=mUseractive.info[aname].v+activeCfg.dailyTask[tid].love
        end
        if not takeReward(uid,reward) then
            response.ret=-403
            return response
        end
        table.insert(mUseractive.info[aname].tr,tid)
        if uobjs.save() then
            response.data.reward = formatReward(reward)
            response.data[aname] =mUseractive.info[aname]
            response.ret = 0
            response.data.report=report
            response.msg = 'Success'
        end
        return response
    end

       -- 任务奖励
    function self.action_getlog(request)
        local response = self.response
        local redis =getRedis()
        local aname = self.aname
        local uid = request.uid
        local redkey="zid."..getZoneId()..aname..self.activeSt.."uid."..uid
        local data  =redis:get(redkey)
        data =json.decode(data)
        if type(data)=='table' then
            response.data.log=data
        end   
        response.ret = 0
        response.msg = 'Success'
       
        return response
    end
    return self
end


return api_active_quanxiantuwei