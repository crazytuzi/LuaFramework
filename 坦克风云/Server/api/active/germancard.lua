--
--desc:德国月卡
--user:chenyunhe
--
local function api_active_germancard(request)
    local self = {
        response = {
            ret = -1,
            msg ='error',
            data = {},
        },
        aname = 'germancard',
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

    -- 玩家开启领取功能
    function self.action_open(request)
        local response = self.response
        local item = request.params.item --开启的哪个

        if not table.contains({1,2},item) then
            response.ret = -102
            return response
        end
        local uid=request.uid
        local uobjs = getUserObjs(uid)
        uobjs.load({"userinfo",'useractive'})
        local mUseractive = uobjs.getModel('useractive')
        local mUserinfo = uobjs.getModel('userinfo')
        local activeCfg = mUseractive.getActiveConfig(self.aname)

        mUseractive.initAct(self.aname)
        -- 玩家充值钻石数
        if mUseractive.info[self.aname]['ot'][item] > 0 then
            response.ret = -102
            return response
        end

        if mUseractive.info[self.aname].gem < activeCfg.recharge[item] then
            response.ret = -102
            return response
        end

        mUseractive.info[self.aname]['ot'][item] = getWeeTs()
        if uobjs.save() then
            response.ret = 0
            response.msg = 'Success'
            response.data[self.aname] = mUseractive.info[self.aname]
        else
            response.ret = -106
        end

        return response
    end

    -- 刷新
    function self.action_refresh(request)
        local response = self.response
        local uid=request.uid
        local uobjs = getUserObjs(uid)
        uobjs.load({"userinfo",'useractive'})
        local mUseractive = uobjs.getModel('useractive')
        local mUserinfo = uobjs.getModel('userinfo')

        local flag = mUseractive.initAct(self.aname)
        if flag then
            if not uobjs.save() then
                response.ret = -106
                return response
            end
        end

        response.data[self.aname] = mUseractive.info[self.aname]
        response.ret = 0
        response.msg = 'Success'

        return response
    end

    -- 领取月卡奖励
    function self.action_reward(request)
 		local uid = request.uid
        local item = request.params.item -- 领取的是哪个卡
        local ts = getClientTs()
        local weeTs = getWeeTs()
        local response = self.response
   		if not table.contains({1,2},item) then
            response.ret = -102
            return response
        end

        local uobjs = getUserObjs(uid)
        uobjs.load({"userinfo",'useractive'})
        local mUseractive = uobjs.getModel('useractive')
        local mUserinfo = uobjs.getModel('userinfo')
         
  		local activeCfg = mUseractive.getActiveConfig(self.aname)
        if mUseractive.info[self.aname]['ot'][item] == 0 then
            return response
        end

        -- 从开启到当前的天数是否
        local currDay = math.floor(math.abs(ts-getWeeTs(mUseractive.info[self.aname]['ot'][item]))/(24*3600)) + 1
        if currDay> activeCfg.dayCount[item] then
            response.ret =-27002
            return response
        end

        -- 当天是否已领取
        if weeTs == mUseractive.info[self.aname]['lt'][item]  then
            response.ret = -1976
            return response
        end
        local reward = {}
        reward['userinfo_gems'] = activeCfg.backReward[item]
        if not takeReward(uid,reward) then
            response.ret = -403
            return response
        end

        mUseractive.info[self.aname]['lt'][item] = weeTs
        mUseractive.info[self.aname]['n'][item] = (mUseractive.info[self.aname]['n'][item] or 0) + 1
	    if uobjs.save() then
            response.data[self.aname] =mUseractive.info[self.aname]
            response.ret = 0
            response.msg = 'Success'
            response.data.reward=formatReward(reward)
        else
            response.ret=-106
        end

        return response
    end

    return self
end

return api_active_germancard