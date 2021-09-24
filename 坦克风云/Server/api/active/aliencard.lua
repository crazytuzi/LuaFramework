--desc:异星卡片
--user:liming
local function api_active_aliencard(request)
    local self = {
        response = {
            ret = -1,
            msg ='error',
            data = {},
        },
        aname = 'aliencard',
    }

    -- 抽奖
    function self.action_lottery(request)
        local uid = request.uid
        local response = self.response
        local num = tonumber(request.params.num) -- 抓取选项
        local free = tonumber(request.params.free) -- 0非免费 1免费
        local ts= getClientTs()
        local weeTs = getWeeTs()
        if not table.contains({0,1},free) or not table.contains({1,5},num) or not uid then
           response.ret=-102
           return response
        end
        local uobjs = getUserObjs(uid)
        uobjs.load({"userinfo","props","bag",'useractive'})
        local mUseractive = uobjs.getModel('useractive')
        local mUserinfo = uobjs.getModel('userinfo')
        -- 活动检测
        local activStatus = mUseractive.getActiveStatus(self.aname)
        if activStatus ~= 1 then
            response.ret = activStatus
            return response
        end
        -- 免费时 单抽
        if free ==1 and num>1 then
            response.ret = -102
            return response
        end
        local activeCfg = mUseractive.getActiveConfig(self.aname)
        if mUseractive.info[self.aname].t < weeTs then
            mUseractive.info[self.aname].v = 0
            mUseractive.info[self.aname].t = weeTs
        end
        if mUseractive.info[self.aname].v==1 and free==1 then
            response.ret = -102
            return response
        end
        -- 判断是否有免费次数
        if mUseractive.info[self.aname].v == 0 and free ~=1 then
            response.ret = -102
            return response
        end
        -- 消耗钻石
        local gems = 0
        if free==1 then
             mUseractive.info[self.aname].v=1
        else
            if num ==1 then
                gems = activeCfg.cost
            else
                num = 5
                gems = activeCfg.cost5
            end
        end
        if not mUserinfo.useGem(gems) then
            response.ret = -109
            return response
        end
        if gems>0 then
             regActionLogs(uid,1,{action=226,item="",value=gems,params={num=num}})
        end
        local reward={}
        local report={}
        local pos = {}
        local times,timeskey = getRewardByPool(activeCfg.numPool,1)
        times = times[1]
        table.insert(pos,timeskey[1])
        for i=1,4 do
            local result,rkey= getRewardByPool(activeCfg.serverreward,1)
            table.insert(pos,rkey[1])
            result = result[1]
            for k,v in pairs(result) do
                result[k] = v*times
            end
            for k,v in pairs(result) do
                result[k] = v*num
            end
            for k,v in pairs(result) do
                reward[k] = (reward[k] or 0) + v
                table.insert(report,formatReward({[k]=v}))
            end
        end
        -- ptb:p(report)
        -- ptb:p(reward)  
        if next(reward) then
            if not takeReward(uid,reward) then
                response.ret = -403
                return response
            end
        end
        -- 和谐版判断
        local harCReward={}
        if moduleIsEnabled('harmonyversion') ==1 then
            local hReward,hClientReward = harVerGifts('active','aliencard',num)
            if not takeReward(uid,hReward) then
                response.ret = -403
                return response
            end
            harCReward = hClientReward
        end
        if uobjs.save() then
            local redis =getRedis()
            local redkey ="zid."..getZoneId()..self.aname..mUseractive.info[self.aname].st.."uid."..uid
            local data =redis:get(redkey)
            data =json.decode(data)
            if type (data)~="table" then data={} end
            table.insert(data,1,{ts,report,num,harCReward,times})
            if next(data) then
                for i=#data,11,-1 do
                    table.remove(data)
                end
                data=json.encode(data)
                redis:set(redkey,data)
                redis:expireat(redkey,mUseractive.info[self.aname].et+86400)
            end         
            response.data[self.aname] =mUseractive.info[self.aname]
            if next(harCReward) then
                response.data[self.aname].hReward=harCReward
            end
            response.data[self.aname].reward=report
            response.data[self.aname].times=times
            response.data[self.aname].pos=pos
            response.ret = 0
            response.msg = 'Success'
        else
            response.ret=-106
        end

        return response
    end
    -- 获取记录
    function self.action_getReportLog(request)
        local response = self.response
        local uid = request.uid
        if not uid then
            response.ret = -102
            return response
        end
        local uobjs = getUserObjs(uid)
        uobjs.load({"useractive"})
        local mUseractive = uobjs.getModel('useractive')
        local redis =getRedis()
        local redkey ="zid."..getZoneId()..self.aname..mUseractive.info[self.aname].st.."uid."..uid
        local data =redis:get(redkey)
        data =json.decode(data)
        if type(data) ~= 'table' then data = {} end
        response.ret = 0
        response.msg = 'Success'
        response.data.report=data
        return response
    end

    return self
end

return api_active_aliencard