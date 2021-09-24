-- 17年情人节

local function api_active_wuduyouou(request)
    local self = {
        response = {
            ret = -1,
            msg = 'error',
            data = {},
        },
        
        -- 活动名
        aname = "wdyo",

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

        self.activeSt = mUseractive.info[self.aname].st
        self.activeEt = mUseractive.getAcet(self.aname)
        self.uid = uid
    end


    -- 抽奖 
    function self.action_rand(request)
       
        local response = self.response
        local randtype = tonumber(request.params.rand) or 2
        local uid = request.uid
        local uobjs = getUserObjs(uid)
        local aname = self.aname
        local mUseractive = uobjs.getModel('useractive')
        local mUserinfo = uobjs.getModel('userinfo')
        local activeCfg = mUseractive.getActiveConfig(aname)
        local activeInfo = mUseractive.info[aname]

        
        local redis =getRedis()
        local redkey="zid."..getZoneId()..aname..self.activeSt.."uid."..uid
        local ts = getClientTs()
        local weeTs = getWeeTs()
        if  activeInfo.t < weeTs then
            activeInfo.c = 0
            activeInfo.t =weeTs
        end
        if ts>=self.activeEt then
            response.ret=-102
            return response
        end
        -- 免费
        local gemCost=0
        local num=1
        if randtype==1 then
            if  activeInfo.c>=1 then
                response.ret=-102
                return response
            end
            activeInfo.c=1

        elseif randtype==2 then
            gemCost=activeCfg.cost1

        elseif randtype==3 then
            num=10
            gemCost=activeCfg.cost2
        end  
        if gemCost>0 then
             -- 使用金币
            if gemCost > 0 and not mUserinfo.useGem(gemCost) then
                response.ret = -109
                return response
            end
        end  

        local reward={}
        
        local data =redis:get(redkey)
        data =json.decode(data)
        local ts = getClientTs()
        if type (data)~="table" then data={}  end
        
        local left,right=self.randRate()
        local report={left,right}
       
        local count=1
        local rewardkey={}
        for k,v in pairs (left) do
            if table.contains(right, v) then
                count=count+1
                table.insert(rewardkey,v)
            end
        end
        if  next(rewardkey) then
            for k,v in pairs(rewardkey) do
                if activeCfg.serverreward.prize[v] then
                    for ak,av  in pairs (activeCfg.serverreward.prize[v]) do
                        reward[ak]=(reward[ak] or 0) +av*num
                    end
                end
            end
        end

      
        local point=activeCfg.getScore[count] *num
        activeInfo.v=activeInfo.v+point
        local tmp={num,formatReward(reward),point,ts}
        table.insert(data,1,tmp)
        if next(reward) then
            if not takeReward(uid,reward) then
                response.ret=-403
                return response
            end
        end

        if gemCost>0 then
            regActionLogs(uid,1,{action=159,item="",value=gemCost,params={num=num,reward=reward,point=point}})
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
            response.ret = 0
            response.data.report=report
            response.data.point=point
            response.data.reward=formatReward(reward)
            response.msg = 'Success'
        end
        return response
    end
    -- 商店购买
    function self.action_buy(request)
           
        local response = self.response
        local id = request.params.id
        local uid = request.uid
        local uobjs = getUserObjs(uid)
        local aname = self.aname
        local mUseractive = uobjs.getModel('useractive')
        local mUserinfo = uobjs.getModel('userinfo')
        local activeCfg = mUseractive.getActiveConfig(aname)
        local activeInfo = mUseractive.info[aname]

        
        local redis =getRedis()
        local redkey="zid."..getZoneId()..aname..self.activeSt.."uid."..uid
        local ts = getClientTs()
        local weeTs = getWeeTs()
        if  activeInfo.t < weeTs then
            activeInfo.c = 0
            activeInfo.t =weeTs
        end
        if ts>=self.activeEt then
            response.ret=-102
            return response
        end

        if activeCfg.shop[id]==nil then
            response.ret=-102
            return response
        end
        if activeInfo.v<activeCfg.shop[id].g then
            response.ret=-102
            return response
        end
        if type(activeInfo.b)~="table" then  activeInfo.b={}  end
        --检测数量的上线
        if activeCfg.shop[id].limit~=nil then
            local limit=activeCfg.shop[id].limit
            if (activeInfo.b[id] or 0)>= limit then
                response.ret=-102
                return response
            end
            activeInfo.b[id]=(activeInfo.b[id] or 0)+1
        end
        activeInfo.v=activeInfo.v-activeCfg.shop[id].g
        local reward={}
        reward=activeCfg.shop[id].serverreward
        if not takeReward(uid,reward) then
            response.ret=-403
            return response
        end

        if uobjs.save() then
            response.data[aname] =mUseractive.info[aname]
            response.ret = 0
            response.data.reward=formatReward(reward)
            response.msg = 'Success'
        end
        return response
    end
    function self.randRate()
        
        local left,right={},{}
        for i=1,3 do
            left =self.getRand(left)
            right=self.getRand(right)
        end

        return left,right
    end
    function self.getRand(arr)
        -- 随机种子
        setRandSeed()
        local rate=rand(1,8)
        if table.contains(arr, rate) then
            return self.getRand(arr)
        end
        table.insert(arr,rate)
        return arr
    end

        --抽奖日志
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


return api_active_wuduyouou