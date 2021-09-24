--
-- desc: 召回付费礼包
-- user: chenyunhe
--
local function api_active_recallpay(request)
    local self = {
        response = {
            ret = -1,
            msg ='error',
            data = {},
        },
        aname = 'recallpay',
    }

	
    -- 领取充值礼包
    function self.action_reward(request)
 		local uid = request.uid

        local response = self.response
        local ts= getClientTs()
        local weeTs = getWeeTs()

        if not uid then
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

        local activeCfg = mUseractive.getActiveConfig(self.aname)
        if mUserinfo.level<activeCfg.levelLimit then
            response.ret = -102
            return response
        end

        if mUseractive.info[self.aname].pop~=1 or mUseractive.info[self.aname].cr==0 then
        	response.ret = -102
        	return response
        end

        if mUseractive.info[self.aname].r==1 then
        	response.ret = -1976
        	return response
        end

        local g1 = mUseractive.info[self.aname].g1
        local g2 = mUseractive.info[self.aname].g2

        -- 根据g1和g2获取奖励配置
        local reward = activeCfg.serverreward.giftList[g1][g2].serverreward
        if type(reward)~='table' or not next(reward) then
            response.ret = -102
            return response
        end

        if not takeReward(uid,reward) then
        	response.ret = -403
        	return response
        end

        mUseractive.info[self.aname].r = 1 --已领取
        activity_setopt(uid,'recallpay',{act='init'})--重置
        if uobjs.save() then
        	response.data[self.aname] =mUseractive.info[self.aname]
            response.data[self.aname].reward = formatReward(reward)

            response.ret = 0
            response.msg = 'Success'
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

        -- 活动检测
        local activStatus = mUseractive.getActiveStatus(self.aname)
        if activStatus ~= 1 then
            response.ret = activStatus
            return response
        end

        response.data[self.aname] = mUseractive.info[self.aname]
        response.ret = 0
        response.msg = 'Success'

        return response
    end


    return self
end

return api_active_recallpay
