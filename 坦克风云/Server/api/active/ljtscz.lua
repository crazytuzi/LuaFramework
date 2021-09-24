-- desc: 累计天数充值(世界杯)
-- user: liming
local function api_active_ljtscz(request)
    local self = {
        response = {
            ret = -1,
            msg ='error',
            data = {},
        },
        aname = 'ljtscz',
    }
    -- 领取每日奖励
    function self.action_dayreward(request)
        local uid = request.uid
        local response = self.response
        local ts= getClientTs()
        local weeTs = getWeeTs()
        local currDay = request.params.day
        if  not uid or not currDay then
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
        if mUseractive.info[self.aname].giftlog[currDay] == nil then
            response.ret =-102
            return response
        end
        if mUseractive.info[self.aname].giftlog[currDay] == 1 then
            response.ret = -1976
            return response
        end
        if mUseractive.info[self.aname].dayInfo[currDay] < activeCfg.rechargeNum then
            response.ret = -30002
            return response
        end 
        local reward = activeCfg.serverreward.dailyGift 
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
        mUseractive.info[self.aname].giftlog[currDay] = 1
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
    -- 领取大奖
    function self.action_bigreward(request)
 		local uid = request.uid
        local response = self.response
        local ts= getClientTs()
        local weeTs = getWeeTs()
        if not uid then
       	   response.ret=-102
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
        if mUseractive.info[self.aname].biglog == 1 then
        	response.ret = -1976
        	return response
        end
        local x = 0
        for k,v in pairs(mUseractive.info[self.aname].dayInfo) do
            if v >= activeCfg.rechargeNum then
                x = x + 1
            end
        end
        if x < activeCfg.bigNeed then
            response.ret = -30002
            return response
        end 
        local reward = activeCfg.serverreward.bigGift 
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
        mUseractive.info[self.aname].biglog = 1
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
        -- 当前是第几天
        local currDay = math.floor(math.abs(ts-getWeeTs(mUseractive.info[self.aname].st))/(24*3600)) + 1
        local totalDay = math.ceil(math.abs(mUseractive.info[self.aname].et - mUseractive.info[self.aname].st)/(24*3600))
        local activeCfg = mUseractive.getActiveConfig(self.aname)
        if not mUseractive.info[self.aname].dayInfo then 
            mUseractive.info[self.aname].dayInfo = {}
            for i=1,totalDay do
                table.insert(mUseractive.info[self.aname].dayInfo,0)
            end
        end
        if not mUseractive.info[self.aname].giftlog then 
            mUseractive.info[self.aname].giftlog = {}
            for i=1,totalDay do
                table.insert(mUseractive.info[self.aname].giftlog,0)
            end
        end
        if type(mUseractive.info[self.aname].buynum) ~= 'table' then
            mUseractive.info[self.aname].buynum = {}
            for _,v in pairs(activeCfg.serverreward.shopList) do
                table.insert(mUseractive.info[self.aname].buynum,0)
            end
        end
        if mUseractive.info[self.aname].biglog == nil then
            mUseractive.info[self.aname].biglog = 0 --大奖领取状态
        end
        -- activity_setopt(uid,'ljtscz',{act='charge',num=50})
        -- ptb:e(mUseractive.info[self.aname])
        if not uobjs.save() then
            response.ret = -106
            return response
        end
        response.data[self.aname] = mUseractive.info[self.aname]
        response.ret = 0
        response.msg = 'Success'

        return response
    end
    --  商店购买
    function self.action_shop(request)
        local response = self.response
        local uid=request.uid
        local item =  request.params.item
        local buyNum = request.params.num or 1
        if  not uid or not item then
            response.ret =-102
            return response
        end
        local uobjs = getUserObjs(uid)
        uobjs.load({"userinfo",'useractive'})
        local mUseractive = uobjs.getModel('useractive')
        local mUserinfo = uobjs.getModel('userinfo')

        -- 活动检测
        local activStatus = mUseractive.getActiveStatus(self.aname)
        if activStatus ~= 1 then
            response.ret = activStatus
            return response
        end
        local activeCfg = mUseractive.getActiveConfig(self.aname)
        local iteminfo = activeCfg.serverreward.shopList[item]
        if type(iteminfo)~='table' then
            response.ret = -102
            return response
        end
        local x = 0
        for k,v in pairs(mUseractive.info[self.aname].dayInfo) do
            if v >= activeCfg.rechargeNum then
                x = x + 1
            end
        end
        if x < activeCfg.buyNeed[item] then
            response.ret = -30002
            return response
        end
        if mUseractive.info[self.aname].buynum[item]+buyNum>iteminfo.limit then
            response.ret = -1987
            return response
        end
        local gems = iteminfo.price * buyNum
        if not mUserinfo.useGem(gems) then
            response.ret = -109
            return response
        end

        if gems>0 then
            regActionLogs(uid,1,{action = 235, item = "", value = gems, params = {}})
        end

        local reward ={}
        for k,v in pairs(iteminfo.serverreward) do
            reward[k] = v*buyNum
        end
        if not takeReward(uid,reward) then
            response.ret =-403
            return response
        end
        mUseractive.info[self.aname].buynum[item] = mUseractive.info[self.aname].buynum[item] + buyNum
        if uobjs.save() then
            response.data[self.aname] =mUseractive.info[self.aname]
            response.data[self.aname].reward = formatReward(reward)
            response.ret = 0
            response.msg = 'Success'
        else
          response.ret=-106
        end
        return response        
    end

    return self
end

return api_active_ljtscz
