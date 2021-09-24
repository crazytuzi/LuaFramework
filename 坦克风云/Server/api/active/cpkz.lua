--
-- desc: 橙配馈赠
-- user: chenyunhe
--
local function api_active_cpkz(request)
    local self = {
        response = {
            ret = -1,
            msg ='error',
            data = {},
        },
        aname = 'cpkz',
    }

	
    -- 领取充值奖励
    function self.action_creward(request)
 		local uid = request.uid
        local response = self.response
        local item =  request.params.item
        local ts= getClientTs()
        local weeTs = getWeeTs()

        if not uid or not item then
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

        local activeCfg = mUseractive.getActiveConfig(self.aname)
        local cnum = table.length(activeCfg.serverreward.rechargeNum)
        local matchid = 0
        for i=cnum,1,-1 do
        	if mUseractive.info[self.aname].gem>=activeCfg.serverreward.rechargeNum[i] then
        		matchid=i
        		break
        	end

        end

        if matchid == 0 then
        	response.ret = -102
        	return response
        end
        local iteminfo = activeCfg.serverreward['gift'..item]
    
        if type(iteminfo)~='table' then
        	response.ret = -102
        	return response
        end

        local reward = {} 
        for k,v in pairs(iteminfo) do
         	reward[v[1]]=(reward[v[1]] or 0)+v[2]
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

    --  商店购买
    function self.action_shop(request)
         local response = self.response
         local uid=request.uid
         local item =  request.params.item
         local buyNum = request.params.useNum or 1

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
		
        if  type(mUseractive.info[self.aname].shop)~='table' then
        	mUseractive.info[self.aname].shop = {}
			local snum = table.length(activeCfg.serverreward.shopList)
        	for i=1,snum do
        		table.insert(mUseractive.info[self.aname].shop,0)
        	end        	
        end

        if mUseractive.info[self.aname].shop[item]+buyNum>iteminfo.limit then
        	response.ret = -1987
            return response
        end
        local gems = iteminfo.price * buyNum
        if not mUserinfo.useGem(gems) then
            response.ret = -109
            return response
        end

        if gems>0 then
            regActionLogs(uid,1,{action = 181, item = "", value = gems, params = {}})
        end

        local reward ={}
        reward[iteminfo.serverreward[1]] = iteminfo.serverreward[2]*buyNum
        if not takeReward(uid,reward) then
        	response.ret =-403
        	return response
        end

        mUseractive.info[self.aname].shop[item] = mUseractive.info[self.aname].shop[item] + buyNum
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

        local flag = false
        if type(mUseractive.info[self.aname].charge) ~='table' then
        	flag = true
        	mUseractive.info[self.aname].charge = {}
        	local activeCfg = mUseractive.getActiveConfig(self.aname)
        	local items = table.length(activeCfg.serverreward.rechargeNum)
        	for i=1,items do
        		table.insert(mUseractive.info[self.aname].charge,0)
        	end
        end

        if  type(mUseractive.info[self.aname].shop)~='table' then
        	flag = true
        	mUseractive.info[self.aname].shop = {}
        	local activeCfg = mUseractive.getActiveConfig(self.aname)
			local snum = table.length(activeCfg.serverreward.shopList)
        	for i=1,snum do
        		table.insert(mUseractive.info[self.aname].shop,0)
        	end        	
        end

        if mUseractive.info[self.aname].gem == nil then
        	flag = true
        	mUseractive.info[self.aname].gem  = 0
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

return api_active_cpkz
