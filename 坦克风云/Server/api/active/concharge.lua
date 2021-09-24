-- desc: 累计充值
-- user: liming
local function api_active_concharge(request)
    local self = {
        response = {
            ret = -1,
            msg ='error',
            data = {},
        },
        aname = 'concharge',
    }
    -- 领取充值奖励
    function self.action_reward(request)
 		local uid = request.uid
        local response = self.response
        local item = request.params.item
        local gift = request.params.gift or nil
        local gifts = {}
        if gift ~= nil then
            if string.find(gift,',') then           
                gift = gift:split(',')
            end
            if type(gift)=='string' then
                local tmpgift = gift:split('_')
                gifts[tonumber(tmpgift[1])] = tonumber(tmpgift[2])
            else
                for k,v in pairs(gift) do
                   local tmpgift = v:split('_')
                   gifts[tonumber(tmpgift[1])] = tonumber(tmpgift[2])
                end
            end
           
        end
        local ts= getClientTs()
        local weeTs = getWeeTs()
        if not uid or not item then
       	   response.ret=-102
       	   return response
        end
        local uobjs = getUserObjs(uid)
        uobjs.load({"userinfo","props","bag",'useractive','hero'})
        local mUseractive = uobjs.getModel('useractive')
        local mUserinfo = uobjs.getModel('userinfo')
        local mHero = uobjs.getModel('hero')
        local activeCfg = mUseractive.getActiveConfig(self.aname)
        -- 活动检测
        local activStatus = mUseractive.getActiveStatus(self.aname)
        if activStatus ~= 1 then
            response.ret = activStatus
            return response
        end
        if mUseractive.info[self.aname].charge == nil or mUseractive.info[self.aname].gem == nil then
        	response.ret = -102
        	return response
        end
        if mUseractive.info[self.aname].charge[item]==2 then
        	response.ret = -1976
        	return response
        end
        if mUseractive.info[self.aname].charge[item]~=1 then
        	response.ret = -102
        	return response
        end
        if mUseractive.info[self.aname].rlog == nil then
            mUseractive.info[self.aname].rlog = {}
            local le = table.length(activeCfg.serverreward.rechargeNum)
            for i=1,le do
                mUseractive.info[self.aname].rlog[i] = {}
            end
        end
        local tmpiteminfo = activeCfg.serverreward['gift'..item]
        local iteminfo = {}
        local checkgifts = {}
        for k,v in pairs(tmpiteminfo) do
            if string.find(k,'altgift') then
                table.insert(checkgifts,v)
            else
                iteminfo[k] = v
            end
        end
        if next(checkgifts) and not next(gifts) then
            response.ret=-102
            return response
        end
        if not next(checkgifts) and next(gifts) then
            response.ret=-102
            return response
        end
        if next(checkgifts) and next(gifts) then
            if #checkgifts ~= table.length(gifts) then
                response.ret=-102
                return response
            end
            for k,v in pairs(gifts) do
                if not table.contains(checkgifts,k) then
                   response.ret=-102
                   return response
                end
            end
            for k,v in pairs(gifts) do
                local tmpaltgift = activeCfg.serverreward[k][v]
                for k1,v1 in pairs(tmpaltgift) do
                    iteminfo[k1] = (iteminfo[k1] or 0) + v1
                end
            end
        end
        if type(iteminfo)~='table' then
        	response.ret = -102
        	return response
        end
        local reward = {} 
        for k,v in pairs(iteminfo) do
         	reward[k]=(reward[k] or 0) + v
        end
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
        mUseractive.info[self.aname].charge[item] = 2
        mUseractive.info[self.aname].rlog[item] = report
        if uobjs.save() then
        	response.data[self.aname] =mUseractive.info[self.aname]
            response.data[self.aname].reward = report
            response.data.hero =mHero.toArray(true)
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
        local activeCfg = mUseractive.getActiveConfig(self.aname)
        local flag = false
        if type(mUseractive.info[self.aname].charge) ~='table' then
        	flag = true
        	mUseractive.info[self.aname].charge = {}
        	local items = table.length(activeCfg.serverreward.rechargeNum)
        	for i=1,items do
        		table.insert(mUseractive.info[self.aname].charge,0)
        	end
        end
        if mUseractive.info[self.aname].gem == nil then
        	flag = true
        	mUseractive.info[self.aname].gem  = 0
        end
        if mUseractive.info[self.aname].rlog == nil then
            flag = true
            mUseractive.info[self.aname].rlog = {}
            local le = table.length(activeCfg.serverreward.rechargeNum)
            for i=1,le do
                mUseractive.info[self.aname].rlog[i] = {}
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

return api_active_concharge
