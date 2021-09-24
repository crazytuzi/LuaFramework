--
-- desc: 世界杯-一球成名
-- user: chenyunhe
--
local function api_active_oneshot(request)
    local self = {
        response = {
            ret = -1,
            msg ='error',
            data = {},
        },
        aname = 'oneshot',
    }

    function self.before(request)
        local response = self.response
        local uid=request.uid
        local uobjs = getUserObjs(uid)
        uobjs.load({'useractive'})
        local mUseractive = uobjs.getModel('useractive')

        if not uid then
            response.ret = -102
            return response
        end

        -- 活动检测
        local activStatus = mUseractive.getActiveStatus(self.aname)
        if activStatus ~= 1 then
            response.ret = activStatus
            return response
        end
    end

    -- 刷新
    function self.action_refresh(request)
        local response = self.response
        local uid=request.uid
        local ts = getClientTs()
        local uobjs = getUserObjs(uid)
        uobjs.load({'useractive'})
        local mUseractive = uobjs.getModel('useractive')
        local flag = mUseractive.initAct(self.aname)
         
        if flag then
            if not uobjs.save() then
                response.ret = -106
                return response
            end
        end

        local activeCfg =copyTable(mUseractive.getActiveConfig(self.aname)) 
        activeCfg.serverreward = nil
        -- 当前是活动的第几天
        local currDay = math.floor(math.abs(ts-getWeeTs(mUseractive.info[self.aname].st))/(24*3600)) + 1
        response.data[self.aname] = mUseractive.info[self.aname]
        response.data[self.aname].curday = currDay
        response.data.activeCfg = activeCfg
        response.ret = 0
        response.msg = 'Success'

        return response
    end

    -- 领取消费礼包
    function self.action_gift(request)
        local response = self.response
        local uid=request.uid
        local ts = getClientTs()
        local day =request.params.d or 0
        local num =request.params.n or 0

        if day<=0 or num<=0 then
            response.ret = -102
            return response
        end
        local uobjs = getUserObjs(uid)
        uobjs.load({'useractive'})
        local mUseractive = uobjs.getModel('useractive')
        mUseractive.initAct(self.aname)-- 这里面会刷新数据

        local activeCfg = mUseractive.getActiveConfig(self.aname)
        local currDay = math.floor(math.abs(ts-getWeeTs(mUseractive.info[self.aname].st))/(24*3600)) + 1
        -- 跟客户端做校验
        if currDay~=day then
            response.ret = -102
            return response
        end

        local giftLimit = copyTable(activeCfg.giftLimit)
        -- 如果取不到，用最后一个(数值同学要求)
        local len = #giftLimit
        local limit = giftLimit[currDay] or giftLimit[len]
      
        -- 检测可领取次数
        if mUseractive.info[self.aname].dg + num > limit then
            response.ret = -1993
            return response
        end
        
        local canget = math.floor(mUseractive.info[self.aname].ch/activeCfg.consumeNum)-mUseractive.info[self.aname].dg
        if canget<=0 or num > canget then
            response.ret = -102
            return response
        end

        local reward = {}
        for k,v in pairs(activeCfg.serverreward.gift) do
            reward[k] = v * num
        end

        if not takeReward(uid,reward) then    
            response.ret=-403
            return response
        end

        mUseractive.info[self.aname].dg = mUseractive.info[self.aname].dg + num 
        if uobjs.save() then        
            response.data[self.aname] =mUseractive.info[self.aname]
            response.data[self.aname].reward=formatReward(reward)
            response.data[self.aname].curday = currDay
            response.ret = 0
            response.msg = 'Success'
        else
            response.ret=-106
        end

        return response
    end
   
    return self
end

return api_active_oneshot
