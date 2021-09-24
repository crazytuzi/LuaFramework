--
-- desc: 限时充值
-- user: chenyunhe
--
local function api_active_xscz(request)
    local self = {
        response = {
            ret = -1,
            msg ='error',
            data = {},
        },
        aname = 'xscz',
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

    -- 领取充值奖励
    function self.action_reward(request)
 		local uid = request.uid
        local response = self.response
        local item =  request.params.item -- 下标
        local act = request.params.act --是普通档1还是额外2
        local num = request.params.num -- 领取数量
        
        if not item or not table.contains({1,2},act) then
       	   response.ret=-102
       	   return response
        end

        local uobjs = getUserObjs(uid)
        uobjs.load({"userinfo","props","bag",'useractive'})
        local mUseractive = uobjs.getModel('useractive')
        local mUserinfo = uobjs.getModel('userinfo')

        local activeCfg = mUseractive.getActiveConfig(self.aname)
        local reward = {}
 
        if type(mUseractive.info[self.aname].charge) ~= 'table' then
            response.ret = -102
            return response
        end

        if act == 1 then
            local cur = mUseractive.info[self.aname].charge[item][1]
            if cur<=0 then
                response.ret = -102
                return response
            end

            if num>cur then
                response.ret = -102
                return response
            end

            local left = activeCfg.serverreward.buyLimit[item] - mUseractive.info[self.aname].charge[item][2]
            if left<=0 or num>left then
                response.ret = -1993
                return response
            end

            local giftcfg = activeCfg.serverreward['gift'..item]
            if type(giftcfg)~='table' then
                response.ret = -102
                return response
            end

            for k,v in pairs(giftcfg) do
                reward[k] = v*num
            end

            mUseractive.info[self.aname].charge[item][1] = mUseractive.info[self.aname].charge[item][1]-num
            mUseractive.info[self.aname].charge[item][2] = mUseractive.info[self.aname].charge[item][2]+num
        else
            if not mUseractive.info[self.aname].ex or not next(mUseractive.info[self.aname].ex) then
                response.ret = -102
                return response
            end
            local cur = mUseractive.info[self.aname].ex[item][1]
            if cur<=0 then
                response.ret = -102
                return response
            end

            if num>cur then
                response.ret = -102
                return response
            end

            local left = activeCfg.serverreward.extraBuyLimit[item] - mUseractive.info[self.aname].ex[item][2]
            if left<=0 or num>left then
                response.ret = -1993
                return response
            end

            local giftcfg = activeCfg.serverreward['extraGift'..item]
            if type(giftcfg)~='table' then
                response.ret = -102
                return response
            end

            for k,v in pairs(giftcfg) do
                reward[k] = v*num
            end

            mUseractive.info[self.aname].ex[item][1] = mUseractive.info[self.aname].ex[item][1]-num
            mUseractive.info[self.aname].ex[item][2] = mUseractive.info[self.aname].ex[item][2]+num
        end

        if not next(reward) then
            response.ret = -102
            return response
        end

        if not takeReward(uid,reward) then
        	response.ret = -403
        	return response
        end
        local report = {}
        for k,v in pairs(reward) do
            table.insert(report,formatReward({[k]=v}))
        end
     
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

    -- 刷新 初始化
    function self.action_refresh(request)
        local response = self.response
        local uid=request.uid

        local uobjs = getUserObjs(uid)
        uobjs.load({"userinfo",'useractive'})
        local mUseractive = uobjs.getModel('useractive')
        local activeCfg = mUseractive.getActiveConfig(self.aname)

        local flag = false
        -- 可领取次数和已领取次数记录
        if type(mUseractive.info[self.aname].charge) ~='table' then
        	flag = true
        	mUseractive.info[self.aname].charge = {}    	
            for k,v in pairs(activeCfg.serverreward.rechargeNum) do
        		table.insert(mUseractive.info[self.aname].charge,{0,0})
        	end
        end

        if type(mUseractive.info[self.aname].ex)~='table' then
            mUseractive.info[self.aname].ex = {}
	    if activeCfg.serverreward.extraRechargeNum then
		 for  k,v in pairs(activeCfg.serverreward.extraRechargeNum) do
		    table.insert(mUseractive.info[self.aname].ex,{0,0})
		  end 
	    end
                
        end
    
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

    return self
end

return api_active_xscz
