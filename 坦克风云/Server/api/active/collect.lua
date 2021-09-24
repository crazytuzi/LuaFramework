--desc:采集物资
--user:chenyunhe
local function api_active_collect(request)
    local self = {
        response = {
            ret = -1,
            msg ='error',
            data = {},
        },
        aname = 'collect',
    }

    -- 抓取奖励
    function self.action_getreward(request)
        local uid = request.uid
        local response = self.response
        local num = tonumber(request.params.num) -- 抓取选项
        local free = tonumber(request.params.free) -- 0非免费 1免费
        local ts= getClientTs()
        local weeTs = getWeeTs()
        
        if not table.contains({0,1},free) or not table.contains({1,5},num) or not uid then
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

		-- 免费时 单抽
        if free ==1 and num>1 then
            response.ret = -102
            return response
        end

        local activeCfg = mUseractive.getActiveConfig(self.aname)
		if mUseractive.info[self.aname].t < weeTs then
            mUseractive.info[self.aname].v = 0
            mUseractive.info[self.aname].t = weeTs
        end

        if mUseractive.info[self.aname].v==1 and free==1 then
            response.ret = -102
            return response
        end

        -- 判断是否有免费次数
        if mUseractive.info[self.aname].v == 0 and free ~=1 then
            response.ret = -102
            return response
        end

        -- 消耗钻石
        local gems = 0
        if free==1 then
        	 mUseractive.info[self.aname].v=1
        else
	 		if num ==1 then
	            gems = activeCfg.cost1
	        else
	            num = 5
	            gems = activeCfg.cost2
	        end
        end

        if not mUseractive.info[self.aname].s then
        	mUseractive.info[self.aname].s=0
        end
        --所有宝箱的个数
        local totalbox=activeCfg.treasureNum

        local reward={}
        local report={}
        local allreward={}
        local rewardlist={}
        for i=1,totalbox do
        	local result,rewardkey
        	if i<=num then
	 		    result,rewardkey = getRewardByPool(activeCfg.serverreward['pool1'],1)
	 			for idx=1,#rewardkey do
	            	local score=0
	                score = activeCfg.serverreward['pool1'].score[rewardkey[idx]]
	                mUseractive.info[self.aname].s=(mUseractive.info[self.aname].s or 0)+score
	            end
				for k,v in pairs (result) do
	                for rk,rv in pairs(v) do
	                    reward[rk]=(reward[rk] or 0)+rv
	                end
	            end
	            -- 有效奖励 1
	            table.insert(rewardlist,1)
	        else
	        	result,rewardkey = getRewardByPool(activeCfg.serverreward['pool2'],1)
	        	-- 无效奖励 0 仅仅作为展示
	        	table.insert(rewardlist,0)
        	end
            local currrew={}
			for k,v in pairs (result) do
                for rk,rv in pairs(v) do
                    currrew[rk]=(currrew[rk] or 0)+rv
                end
	        end
	        --本次抽奖获得的奖励
	        table.insert(allreward,i,formatReward(currrew))
        end

        if not takeReward(uid,reward) then
            response.ret=-403
            return response
        end

        for k,v in pairs(reward) do
            table.insert(report, formatReward({[k]=v}))
        end

        if not mUserinfo.useGem(gems) then
            response.ret = -109
            return response
        end

        if gems>0 then
        	 regActionLogs(uid,1,{action=169,item="",value=gems,params={num=num}})
        end

        -- 和谐版判断
        local harCReward={}
        if moduleIsEnabled('harmonyversion') ==1 then
            local hReward,hClientReward = harVerGifts('active','collect',num)
            if not takeReward(uid,hReward) then
                response.ret = -403
                return response
            end
            harCReward = hClientReward
        end

        if uobjs.save() then
 			local redis =getRedis()
            local redkey ="zid."..getZoneId()..self.aname..mUseractive.info[self.aname].st.."uid."..uid
            local data =redis:get(redkey)
            data =json.decode(data)
            if type (data)~="table" then data={} end
            
            table.insert(data,1,{ts,report,num,harCReward})
            if next(data) then
                for i=#data,11,-1 do
                    table.remove(data)
                end

                data=json.encode(data)
                redis:set(redkey,data)
                redis:expireat(redkey,mUseractive.info[self.aname].et+86400)
            end        	
            response.data[self.aname] =mUseractive.info[self.aname]
            if next(harCReward) then
                response.data[self.aname].hReward=harCReward
            end
            response.data[self.aname].reward1=allreward
            response.data[self.aname].reward2=rewardlist
            response.ret = 0
            response.msg = 'Success'
        else
            response.ret=-106
        end

        return response
    end

	-- 获取记录
    function self.action_getReportLog(request)
        local response = self.response
        local uid = request.uid
        if not uid then
            response.ret = -102
            return response
        end
        local uobjs = getUserObjs(uid)
        uobjs.load({"useractive"})
        local mUseractive = uobjs.getModel('useractive')

        local redis =getRedis()
        local redkey ="zid."..getZoneId()..self.aname..mUseractive.info[self.aname].st.."uid."..uid
        local data =redis:get(redkey)
        data =json.decode(data)

        if type(data) ~= 'table' then data = {} end
        response.ret = 0
        response.msg = 'Success'
        response.data.report=data

        return response
    end


    -- 商店兑换
    function self.action_shopping(request)
         local response = self.response
         local uid=request.uid
         local itemid=request.params.item--兑换哪一个
         local num=request.params.num or 1 --兑换个数

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
        if type(mUseractive.info[self.aname].shop)~='table' then
        	mUseractive.info[self.aname].shop={}
            for k,v in pairs(activeCfg.serverreward.shopList) do
            	table.insert(mUseractive.info[self.aname].shop,0)
            end
        end
        
        local iteminfo=activeCfg.serverreward.shopList[itemid]
        if type(iteminfo)~='table' then
        	response.ret=-102
        	return response
        end

        -- 物品兑换次数不足
        if mUseractive.info[self.aname].shop[itemid]>iteminfo.limit then
            response.ret=-23305
            return response
        end
    
        local coststore=iteminfo.price*num
        -- 积分数量不足
        if mUseractive.info[self.aname].s<coststore then
            response.ret=-1996
            return response
        end 

        -- 增加兑换次数
        mUseractive.info[self.aname].shop[itemid]=mUseractive.info[self.aname].shop[itemid]+num
        mUseractive.info[self.aname].s=mUseractive.info[self.aname].s-coststore
        local reward={[iteminfo.serverreward[1]]=iteminfo.serverreward[2]*num}
 
        if not takeReward(uid,reward) then
            response.ret=-102
            return response
        end

        if uobjs.save() then
            response.data[self.aname] =mUseractive.info[self.aname]
            response.ret = 0
            response.msg = 'Success'
        else
          response.ret=-106                    
        end

        return response        
    end

    -- 刷新商店
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
        if mUseractive.info[self.aname].s==nil  then
            mUseractive.info[self.aname].s=0
        end

        response.data[self.aname] =mUseractive.info[self.aname]
        response.ret = 0
        response.msg = 'Success'

        return response
    end


    return self
end

return api_active_collect