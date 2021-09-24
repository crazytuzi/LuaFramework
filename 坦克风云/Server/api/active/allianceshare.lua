--desc:军团分享
--user:chenyunhe
local function api_active_allianceshare(request)
    local self = {
        response = {
            ret = -1,
            msg ='error',
            data = {},
        },
        aname = 'allianceshare',
    }

    -- 领取奖励(存在并发性)
    function self.action_getreward(request)
        local uid = request.uid
        local response = self.response
        local gid = request.params.id -- 领取礼包的编号
        local ts= getClientTs()

        if not uid or not gid then
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

        local alliance = mUserinfo.alliance
        if alliance==0 then
        	response.ret = -4005   --没加入军团 不能领取奖励
        	return response
        end

        local redkey = "zid."..getZoneId().."."..self.aname.."ts"..mUseractive.info[self.aname].st.."_"..gid
        local redis = getRedis()
 		local giftinfo = json.decode(redis:hget(redkey,'info'))
		if type(giftinfo)~='table' or not next(giftinfo) then
			response.ret = -4001 --数据发生变化重试
			return response
		end

        -- 只能领取所在军团的礼包
		if alliance~=giftinfo.allianceId then
			response.ret = -2039
			return response
		end

	    local leftnum=tonumber(redis:hget(redkey,'num'))
	    if leftnum<=0 then
	    	response.ret = -30005
	    	return response
	    end

	    -- 需要判断当前玩家是否已领取  礼包是否能领取  是否是玩家发的
	    if giftinfo.sender == uid then
		    response.ret = -30004
		    return response
	    end

		for k,v in pairs(giftinfo.ulist) do
			if v[1]==uid then
				response.ret = -30001 --已领取
				return response
			end
    	end

        -- 减少礼包
		local left=redis:hincrby(redkey,"num",-1)
		if left<0 then
			response.ret =-30005 -- 超出上限
			return response
		end

		local activeCfg = mUseractive.getActiveConfig(self.aname)
		local reward = {}
		-- 随机奖励start
		local item = tonumber(giftinfo.item) or 0
		if item<=0 then
			response.ret = -4001
			return response
		end
		local result,rewardkey = getRewardByPool(activeCfg.serverreward['pool'..item],1)
		for k,v in pairs (result) do
            for rk,rv in pairs(v) do
                reward[rk]=(reward[rk] or 0)+rv
            end
        end
		--end
		
		local ret,retw=takeReward(uid,reward)
        if not ret then
            response.ret=-403
            return response
        end

        local clientReward = {}
        for k,v in pairs(reward) do
            table.insert(clientReward, formatReward({[k]=v}))
        end

        table.insert(giftinfo.ulist,{uid,mUserinfo.nickname,clientReward,ts})
		local data = json.encode(giftinfo)
        redis:hset(redkey,'info',data)
        redis:expireat(redkey,ts+86400*3)

        giftinfo.left = left
        giftinfo.received = 1
        if uobjs.save() then
            response.data[self.aname] =mUseractive.info[self.aname]
            response.data.reward = clientReward
            response.data.ginfo = giftinfo
			if type(retw.armor)=="table" and next(retw) then
	            response.data.amreward =retw.armor.info
	        end            
	           
            response.ret = 0
            response.msg = 'Success'
        else
            response.ret=-106
        end

        return response
    end
    -- 充值档位列表
    function self.action_clist(request)
 		local uid = request.uid
        local response = self.response
        local ts= getClientTs()

        if not uid then
       	   response.ret=-102
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
        local max = #activeCfg.serverreward.cost
        local saveflag = false
        if type(mUseractive.info[self.aname].charge)~='table' or not next(mUseractive.info[self.aname].charge) then
            mUseractive.info[self.aname].charge = {}
            for i=1,max do
            	table.insert(mUseractive.info[self.aname].charge,0)
            end
            saveflag = true
        end

        if saveflag then
        	if not uobjs.save() then
        		response.ret = -403
        		return response
        	end
        end

        response.data[self.aname] =mUseractive.info[self.aname]
 		response.ret = 0
        response.msg = 'Success'

        return response
    end

    -- 领取充值奖励
    function self.action_creward(request)
		local uid = request.uid
        local response = self.response
        local item = request.params.item

        if not uid or not item then
       	   response.ret=-102
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

        if not mUseractive.info[self.aname].charge[item] then
        	response.ret = -102
        	return response
        end

        if mUseractive.info[self.aname].charge[item]<=0 then
        	response.ret = -30003
        	return response
        end

 		local activeCfg = mUseractive.getActiveConfig(self.aname)    	
    	local reward = {}
    	local clientReward = {}

    	for k,v in pairs(activeCfg.serverreward['gift'..item]) do
            reward[v[1]] = (reward[v[1]] or 0) + v[2]
            table.insert(clientReward,formatReward({[v[1]]=v[2]}))
        end

        local ret,retw=takeReward(uid,reward)
        if not ret then
            response.ret = -403
            return response
        end

        mUseractive.info[self.aname].charge[item] = mUseractive.info[self.aname].charge[item]-1
        if uobjs.save() then
        	 response.data[self.aname] =mUseractive.info[self.aname]
        	 response.data.reward = clientReward
        	 if type(retw.armor)=="table" and next(retw) then
	            response.data.amreward =retw.armor.info
	        end  
        	 response.ret = 0
        	 response.msg = 'Success'
        else
        	response.ret = -106
        end

        return response
    end

	-- 礼包列表
    function self.action_glist(request)
		local uid = request.uid
        local response = self.response
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

        local alliance = mUserinfo.alliance
        local giftlist = {} --礼包列表
        if alliance>0 then
			local redis = getRedis()
	        local machkey = "zid."..getZoneId().."."..self.aname.."ts"..mUseractive.info[self.aname].st.."_"..alliance
	        local redkeys=redis:keys(machkey..'*')
	        if type(redkeys)=='table' then
	        	for k,v in pairs(redkeys) do
	        		local giftinfo=json.decode(redis:hget(v,'info'))
	        		local num = tonumber(redis:hget(v,'num')) or 0

                    local received=0--没有领取过
                    for k,v in pairs(giftinfo.ulist) do
                        if v[1]==uid then
                            received=1
                            break
                        end
                    end	

	        		local tmp = {
	        		    giftinfo.sender,
	        		    giftinfo.uname,
	        		    giftinfo.item,
	        		    num,
	        		    giftinfo.nu,
	        		    giftinfo.id,
	        		    received,
	        		    giftinfo.ts,
	        	    }

	        		table.insert(giftlist,tmp)
	        	end
	        end
        end

		response.data[self.aname] =mUseractive.info[self.aname]
        response.data[self.aname].list = giftlist
        response.ret = 0
        response.msg = 'Success'

        return response
    end

    -- 查看单独的礼包领取状况
    function self.action_view(request)
		local uid = request.uid
        local response = self.response
        local gid = request.params.id
        if not uid or not gid then
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

        local alliance = mUserinfo.alliance
        if alliance==0 then
			response.ret = -4005   --未加入军团
        	return response
        end


  		local redkey = "zid."..getZoneId().."."..self.aname.."ts"..mUseractive.info[self.aname].st.."_"..gid
        local redis = getRedis()
 		local info = json.decode(redis:hget(redkey,'info'))
		if type(info)~='table' or not next(info) then
			response.ret = -4001 --数据发生变化重试
			return response
		end

		if alliance~=info.allianceId then
			response.ret = -2039
			return response
		end

		local received=0--没有领取过
	    for k,v in pairs(info.ulist) do
	        if v[1]==uid then
	            received=1
	            break
	        end
	    end			

		info.left = tonumber(redis:hget(redkey,'num')) or 0
		info.received = received
		response.ret = 0
		response.msg = "Success"
		response.data.ginfo = info

		return response
    end

    -- 有没有可以领取的奖励
    function self.action_canreceive(request)
    	local uid = request.uid
        local response = self.response
        if not uid then
       	   response.ret=-102
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

        local alliance = mUserinfo.alliance
        local flag =  false
        response.ret = 0 
        if alliance==0 then
			response.data.flag = flag
        	return response
        end

        if type(mUseractive.info[self.aname].charge)=='table'  then
        	for k,v in pairs(mUseractive.info[self.aname].charge) do
        		if v>0 then
        			response.data.flag = true
        			return response
        		end
        	end
        end

		if alliance>0 then
			local redis = getRedis()
	        local machkey = "zid."..getZoneId().."."..self.aname.."ts"..mUseractive.info[self.aname].st.."_"..alliance
	        local redkeys=redis:keys(machkey..'*')
	        if type(redkeys)=='table' then
	        	for k,v in pairs(redkeys) do
	        		local giftinfo=json.decode(redis:hget(v,'info'))
	        		local num = tonumber(redis:hget(v,'num')) or 0
	        		if giftinfo.sender~=uid  and num>0 then
	        			response.data.flag = true
	        			return response
	        	    end
                end
	        end
        end

		response.data.flag = flag
		response.msg = "Success"
        return response	   
    end


    return self
end

return api_active_allianceshare
