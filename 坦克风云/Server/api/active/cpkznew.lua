--
-- desc: 新橙配馈赠
-- user: chenyunhe
--
local function api_active_cpkznew(request)
    local self = {
        response = {
            ret = -1,
            msg ='error',
            data = {},
        },
        aname = 'cpkznew',
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

    -- 领取充值或者消费奖励
    function self.action_reward(request)
 		local uid = request.uid
        local response = self.response
        local item =  request.params.item
        local act = request.params.act -- 1累计充值 2累计消费
        
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
        if act == 1 then
            if type(mUseractive.info[self.aname].charge) ~= 'table' then
                response.ret = -102
                return response
            end

            if mUseractive.info[self.aname].charge[item]==1 then
                response.ret = -1976
                return response
            end
            -- 充值钻石数
            if mUseractive.info[self.aname].gem < activeCfg.serverreward.rechargeNum[item] then
                response.ret = -102
                return response
            end

            reward = copyTable(activeCfg.serverreward['gift'..item])
            mUseractive.info[self.aname].charge[item] = 1
        elseif act == 2 then
            if type(mUseractive.info[self.aname].cost) ~= 'table' then
                response.ret = -102
                return response
            end

            if mUseractive.info[self.aname].cost[item]==1 then
                response.ret = -1976
                return response
            end
            -- 当前消耗钻石数
            if mUseractive.info[self.aname].co < activeCfg.serverreward.consumeNum[item] then
                response.ret = -102
                return response
            end
            reward = copyTable(activeCfg.serverreward['costGift'..item])
            mUseractive.info[self.aname].cost[item] = 1
        else
            response.ret = -1
            return response
        end

        if not next(reward) then
            response.ret = -102
            return response
        end

        if not takeReward(uid,reward) then
        	response.ret = -403
        	return response
        end
     
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

    --  商店购买 
    function self.action_shop(request)
         local response = self.response
         local uid=request.uid
         local item =  request.params.item
         local buyNum = request.params.num or 1

         if not item or buyNum<=0  then
         	response.ret =-102
         	return response
         end

         local uobjs = getUserObjs(uid)
         uobjs.load({"userinfo",'useractive'})
         local mUseractive = uobjs.getModel('useractive')
         local mUserinfo = uobjs.getModel('userinfo')

		local activeCfg = mUseractive.getActiveConfig(self.aname)
		local iteminfo = activeCfg.serverreward.shopList[item]
		if type(iteminfo)~='table' then
			response.ret = -102
			return response
		end
		
        if type(mUseractive.info[self.aname].shop)~='table' then
            response.ret = -102
            return response       	
        end
        -- 判断当前物品的购买次数是否达上限
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
            regActionLogs(uid,1,{action = 244, item = "", value = gems, params = {}})
        end

        local reward ={}
        for k,v in pairs(iteminfo.serverreward) do
            reward[k] = v* buyNum
        end

        if not next(reward) then
            response.ret = -102
            return response
        end

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

    -- 刷新 初始化
    function self.action_refresh(request)
        local response = self.response
        local uid=request.uid
        local uobjs = getUserObjs(uid)
        uobjs.load({"userinfo",'useractive'})
        local mUseractive = uobjs.getModel('useractive')
        local activeCfg = mUseractive.getActiveConfig(self.aname)

        local flag = false
        -- 累计充值领取奖励记录
        if type(mUseractive.info[self.aname].charge) ~='table' then
        	flag = true
        	mUseractive.info[self.aname].charge = {}    	
        	local items = table.length(activeCfg.serverreward.rechargeNum)
        	for i=1,items do
        		table.insert(mUseractive.info[self.aname].charge,0)
        	end
        end
        -- 消耗钻石 领取记录
        if type(mUseractive.info[self.aname].cost) ~= 'table' then
            flag = true
            mUseractive.info[self.aname].cost = {}
            local items = table.length(activeCfg.serverreward.consumeNum)
            for i=1,items do
                table.insert(mUseractive.info[self.aname].cost,0)
            end
        end
        -- 商店初始化 记录购买次数
        if  type(mUseractive.info[self.aname].shop)~='table' then
        	flag = true
        	mUseractive.info[self.aname].shop = {}
			local snum = table.length(activeCfg.serverreward.shopList)
        	for i=1,snum do
        		table.insert(mUseractive.info[self.aname].shop,0)
        	end        	
        end

        -- 累计充值
        if mUseractive.info[self.aname].gem == nil then
        	flag = true
        	mUseractive.info[self.aname].gem  = 0
        end

        -- 累计消费
        if mUseractive.info[self.aname].co == nil then
            flag = true
            mUseractive.info[self.aname].co  = 0
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

return api_active_cpkznew
