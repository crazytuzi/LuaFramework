-- desc: 钻石轮盘
-- user: liming
local function api_active_gemwheel(request)
    local self = {
        response = {
            ret = -1,
            msg ='error',
            data = {},
        },
        aname = 'gemwheel',
    }
    -- 刷新
    function self.action_refresh(request)
        local response = self.response
        local uid=request.uid
        local uobjs = getUserObjs(uid)
        uobjs.load({"userinfo",'useractive'})
        local mUseractive = uobjs.getModel('useractive')
        local mUserinfo = uobjs.getModel('userinfo')
        local activeCfg = mUseractive.getActiveConfig(self.aname)
        if not uid then
            response.ret = -102
            return response
        end
        local ts= getClientTs()
        local weeTs = getWeeTs()
        -- 当天23:59时间戳
        local currTs = weeTs+86400-1
        -- 活动检测
        local activStatus = mUseractive.getActiveStatus(self.aname)
        if activStatus ~= 1 then
            response.ret = activStatus
            return response
        end
        if mUseractive.info[self.aname].nighttime == nil then
            mUseractive.info[self.aname].nighttime = 0
        end
        if mUseractive.info[self.aname].gems == nil then
            mUseractive.info[self.aname].gems = 0
        end
        if mUseractive.info[self.aname].num == nil then
            mUseractive.info[self.aname].num = 0
        end
        if mUseractive.info[self.aname].r == nil then
            mUseractive.info[self.aname].r = 0
        end
        if ts > mUseractive.info[self.aname].nighttime then
            mUseractive.info[self.aname].num = 0 --次数
            mUseractive.info[self.aname].nighttime = currTs
        end
        local numprice = activeCfg.rcLimit
        if mUseractive.info[self.aname].gems>=numprice[1] and mUseractive.info[self.aname].r == 0 then
            mUseractive.info[self.aname].r=1
        end
        if not uobjs.save() then
            response.ret = -106
            return response
        end
        response.data[self.aname] = mUseractive.info[self.aname]
        response.ret = 0
        response.msg = 'Success'

        return response
    end

    -- 抽奖
    function self.action_lottery(request)
        local uid = request.uid
        local response = self.response

        local uobjs = getUserObjs(uid)
        uobjs.load({"userinfo",'useractive'})
        local mUseractive = uobjs.getModel('useractive')
        local mUserinfo = uobjs.getModel('userinfo')
        if not uid then
            response.ret = -102
            return response
        end
        local activeCfg = mUseractive.getActiveConfig(self.aname)

        -- 活动检测
        local activStatus = mUseractive.getActiveStatus(self.aname)
        if activStatus ~= 1 then
            response.ret = activStatus
            return response
        end
        local ts= getClientTs()
        local weeTs = getWeeTs()
        -- 当天23:59时间戳
        local currTs = weeTs+86400-1
        if ts > mUseractive.info[self.aname].nighttime then
            mUseractive.info[self.aname].num = 0 --次数
            mUseractive.info[self.aname].nighttime = currTs
        end
        local num = mUseractive.info[self.aname].num
        if num >= activeCfg.numLimit then
            response.ret = -102
            return response
        end
        if mUseractive.info[self.aname].r == 0 then
            response.ret = -30002
            return response
        end
        local gems = mUseractive.info[self.aname].gems
        local rebateLimit = activeCfg.serverreward.rebateLimit
        local floatWeight = activeCfg.serverreward.floatWeight
        local pool = copyTab(activeCfg.serverreward.pool)
        if next(floatWeight) then
            for k,v in pairs(floatWeight) do
                pool[2][v] = pool[2][v] + gems
            end
        end
        local reward = {}
        local spprop = {}
        local result,rewardkey= getRewardByPool(pool,1)
        local rewardgems = 0
        for k,v in pairs(result[1]) do
            if string.find(k,'gemwheel') then
                if v > rebateLimit then
                    response.ret = -102
                    return response
                end
               rewardgems = math.ceil(v*gems/100)
            end
        end
        if rewardgems > 0 then
            reward['userinfo_gems'] = rewardgems
        else
            reward = result[1]
        end
        mUseractive.info[self.aname].gems = 0
        mUseractive.info[self.aname].num = mUseractive.info[self.aname].num + 1
        mUseractive.info[self.aname].r = 0
        mUseractive.info[self.aname].t = ts
        local report = {}
        if next(reward) then
            if not takeReward(uid,reward) then
                response.ret = -403
                return response
            end
            for k,v in pairs(reward) do
                table.insert(report,formatReward({[k]=v}))
            end
        end
        if uobjs.save() then
            response.data[self.aname] =mUseractive.info[self.aname]
            response.data[self.aname].reward = report
            response.data[self.aname].target = rewardkey[1]
            response.ret = 0
            response.msg = 'Success'
        else
            response.ret = -106
        end

        return response
    end
  

    return self
end

return api_active_gemwheel
