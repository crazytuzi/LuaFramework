-- desc: 累计充值(世界杯)
-- user: liming
local function api_active_ljczsjb(request)
    local self = {
        response = {
            ret = -1,
            msg ='error',
            data = {},
        },
        aname = 'ljczsjb',
    }
    -- 领取奖励
    function self.action_reward(request)
        local uid = request.uid
        local response = self.response
        local ts= getClientTs()
        local weeTs = getWeeTs()
        local step = request.params.step
        local index = request.params.id
        if not step or not index or not uid then
            response.ret =-102
            return response
        end
        local uobjs = getUserObjs(uid)
        uobjs.load({"userinfo","props","bag",'useractive','hero'})
        local mUseractive = uobjs.getModel('useractive')
        local mUserinfo = uobjs.getModel('userinfo')
        local activeCfg = mUseractive.getActiveConfig(self.aname)
        -- 活动检测
        local activStatus = mUseractive.getActiveStatus(self.aname)
        if activStatus ~= 1 then
            response.ret = activStatus
            return response
        end
        if mUseractive.info[self.aname].giftlog[step] == nil then
            response.ret =-102
            return response
        end
        if mUseractive.info[self.aname].chargeInfo[step] == 0 then
            response.ret =-102
            return response
        end
        if mUseractive.info[self.aname].giftlog[step][index] == 1 then
            response.ret = -1976
            return response
        end
        local iteminfo = activeCfg.serverreward[step][index]
        if iteminfo == nil then
            response.ret =-102
            return response
        end
        if mUseractive.info[self.aname].chargeInfo[step] < iteminfo.rechargeNum then
            response.ret = -30002
            return response
        end 
        local reward = iteminfo.gift
        if not takeReward(uid,reward) then
            response.ret = -403
            return response
        end
        local report = {}
        if next(reward) then
            for k,v in pairs(reward) do
                table.insert(report, formatReward({[k]=v}))
            end
        end
        mUseractive.info[self.aname].giftlog[step][index] = 1
        if uobjs.save() then
            response.data[self.aname] =mUseractive.info[self.aname]
            response.data[self.aname].reward = report
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
        local ts= getClientTs()
        local activeCfg = mUseractive.getActiveConfig(self.aname)
        if not mUseractive.info[self.aname].chargeInfo then 
            mUseractive.info[self.aname].chargeInfo = {}
            local x = #activeCfg.days
            for i=1,x do
                table.insert(mUseractive.info[self.aname].chargeInfo,0)
            end
        end
        if not mUseractive.info[self.aname].giftlog then 
            mUseractive.info[self.aname].giftlog = {}
            for k,v in pairs(activeCfg.serverreward) do
                mUseractive.info[self.aname].giftlog[k] = {}
                for k1,v1 in pairs(v) do
                    table.insert(mUseractive.info[self.aname].giftlog[k],0)
                end
            end
        end
        -- activity_setopt(uid,'ljczsjb',{act='charge',num=6000})
        if not uobjs.save() then
            response.ret = -106
            return response
        end
        response.data[self.aname] = mUseractive.info[self.aname]
        response.ret = 0
        response.msg = 'Success'

        return response
    end

    return self
end

return api_active_ljczsjb
