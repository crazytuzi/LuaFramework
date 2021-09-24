 --
-- desc: 通用充值商店
-- user: chenyunhe
--
local function api_active_tyczsd(request)
    local self = {
        response = {
            ret = -1,
            msg ='error',
            data = {},
        },
        aname = 'tyczsd',
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
        local weeTs = getWeeTs()
        local uid=request.uid
        local uobjs = getUserObjs(uid)
        uobjs.load({"userinfo",'useractive'})
        local mUseractive = uobjs.getModel('useractive')
        local mUserinfo = uobjs.getModel('userinfo')

        local activeCfg = mUseractive.getActiveConfig(self.aname)
        local flag = false
        if type(mUseractive.info[self.aname].shop) ~='table' then
        	flag = true
            mUseractive.info[self.aname].shop = {}
            for k,v in pairs(activeCfg.serverreward.shopList) do
                mUseractive.info[self.aname].shop[k] = 0
            end
        end

        if not mUseractive.info[self.aname].gems then
            flag = true
            mUseractive.info[self.aname].gems = 0
        end

        -- 出售券
        if not mUseractive.info[self.aname].sq then
            flag = true
            mUseractive.info[self.aname].sq = 0
        end

        -- 总的出售券
        if not mUseractive.info[self.aname].tsq then
            flag = true
            mUseractive.info[self.aname].tsq = 0
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

    -- 商店
    function self.action_shop(request)
    	local response = self.response
        local uid= request.uid
        local item = request.params.i
        local num = request.params.n

        if not item or num<=0 then
        	response.ret = -102
        	return response
        end

        local uobjs = getUserObjs(uid)
        uobjs.load({"userinfo",'useractive',})
        local mUseractive = uobjs.getModel('useractive')
        local mUserinfo = uobjs.getModel('userinfo')
 

        local activeCfg = mUseractive.getActiveConfig(self.aname)
        local itemcfg = activeCfg.serverreward.shopList[item]
        
        if type(itemcfg)~='table' then
            response.ret = -102
            return response
        end

        if mUseractive.info[self.aname].shop[item] + num > itemcfg.limit then
            response.ret = -121
            return response
        end
      
        local gems = itemcfg.price * num
        local nsq = itemcfg.needNum * num
        if nsq>mUseractive.info[self.aname].sq then
            response.ret = -1996
            return response
        end

        local reward = {}
        for k,v in pairs(itemcfg.r) do
            reward[k] = v * num
        end
          
        if not takeReward(uid,reward) then
        	response.ret = -403
        	return response
        end

        if not mUserinfo.useGem(gems) then
            response.ret = -109
            return response
        end
        regActionLogs(uid,1,{action = 261, item = "", value = gems, params = {i=item}})
    	mUseractive.info[self.aname].shop[item] = mUseractive.info[self.aname].shop[item] + num
        mUseractive.info[self.aname].sq = mUseractive.info[self.aname].sq - nsq
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

    -- 特别礼包
    function self.action_gift(request)
        local response = self.response
        local uid= request.uid
        local item = request.params.i
        local ts = getClientTs()

        if not item then
            response.ret = -102
            return response
        end

        local uobjs = getUserObjs(uid)
        uobjs.load({"userinfo",'useractive'})
        local mUseractive = uobjs.getModel('useractive')
        local mUserinfo = uobjs.getModel('userinfo')

        local activeCfg = mUseractive.getActiveConfig(self.aname)
        if mUserinfo.level < activeCfg.levelLimit then
            response.ret = -102
            return response
        end

        local currDay = math.floor(math.abs(ts-getWeeTs(mUseractive.info[self.aname].st))/(24*3600)) + 1
        -- 只能购买活动当天对应的礼包
        if item~=currDay then
            response.ret = -102
            return response
        end

        if mUseractive.info[self.aname].gt[item]==1 then
            response.ret = -1976
            return response
        end

        local itemcfg = activeCfg.serverreward.giftList[item]
        if type(itemcfg)~='table' then
            response.ret = -102
            return response
        end

        if not takeReward(uid,itemcfg.r) then
            response.ret = -403
            return response
        end

        if not mUserinfo.useGem(itemcfg.price) then
            response.ret = -109
            return response
        end
        regActionLogs(uid,1,{action = 258, item = "", value = itemcfg.price, params = {i=item}})
    
        mUseractive.info[self.aname].gt[item] = 1
        if uobjs.save() then
            response.data[self.aname] =mUseractive.info[self.aname]
            response.data[self.aname].reward = formatReward(itemcfg.r)
            response.ret = 0
            response.msg = 'Success'
        else
            response.ret = -106
        end

        return response        
    end

    return self
end

return api_active_tyczsd
