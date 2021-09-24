-- desc: 端午节2018
-- user: liming
local function api_active_dragonboat(request)
    local self = {
        response = {
            ret = -1,
            msg ='error',
            data = {},
        },
        aname = 'dragonboat',
    }
    function self.formatreward(rewards)
        local formatreward = {}
        local key = 'dragonboat'
        formatreward[key] = {}
        if type(rewards) == 'table' then
            for k,v in pairs(rewards) do
                formatreward[key][k] = v
            end 
        end
        return formatreward
    end
    -- 随机奖励并获得积分
    function self.action_lottery(request)
        local uid = request.uid
        local response = self.response
        local num = tonumber(request.params.num) -- 1单抽 5五连抽
        local free = tonumber(request.params.free) -- 0非免费 1免费
        local train = request.params.t --抽奖类型 0单选 1全选
        local ts= getClientTs()
        local weeTs = getWeeTs()
        if not table.contains({0,1},free) or not table.contains({1,5},num) and not table.contains({0,1},train)  then
       	   response.ret=-102
       	   return response
        end
        local uobjs = getUserObjs(uid)
        uobjs.load({"userinfo","props","bag",'useractive',"alienweapon"})
        local mUseractive = uobjs.getModel('useractive')
        local mUserinfo = uobjs.getModel('userinfo')
        local activeCfg = mUseractive.getActiveConfig(self.aname)
         -- 活动检测
        local activStatus = mUseractive.getActiveStatus(self.aname)
        if activStatus ~= 1 then
            response.ret = activStatus
            return response
        end
        -- 消耗钻石
        local gems = 0
        -- 单选是有免费的
        if train == 0 then 
            -- 免费时 单抽
            if free ==1 and num>1 then
                response.ret = -102
                return response
            end
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

            if free==1 then
                 mUseractive.info[self.aname].v=1
            else
                if num ==1 then
                    gems = activeCfg.cost1[1]
                else
                    num = 5
                    gems = activeCfg.cost1[2]
                end
            end
        else
            if free ==1 then
                response.ret = -102
                return response
            end
            if num ==1 then
                gems = activeCfg.cost2[1]
            else
                num = 5
                gems = activeCfg.cost2[2]
            end
        end
        local reward={}
        local report={}
        local spprop = {}
        local itemNeed = activeCfg.serverreward.itemNeed[1]
        setRandSeed()
        if train == 0 then
        	local rd = rand(1,100)
        	local needrate = activeCfg.winRate + mUseractive.info[self.aname].num*activeCfg.increaseRate
        	--大奖
        	local pool = {}
        	if rd<needrate*100 then
                mUseractive.info[self.aname].num = 0
                pool = activeCfg.serverreward.pool2
            else
                -- 小奖
                mUseractive.info[self.aname].num =  mUseractive.info[self.aname].num + 1
                pool = activeCfg.serverreward.pool1
            end
            for i=1,num do 
	 		    local result,rewardkey = getRewardByPool(pool,1)
	 		    for k,v in pairs (result) do
	                for rk,rv in pairs(v) do
	                    reward[rk]=(reward[rk] or 0)+rv
	                end
	            end
	            local score = pool.score[rewardkey[1]] 
	            local tmpspprop = {}
	            tmpspprop[itemNeed] = score
	            for k,v in pairs(tmpspprop) do
	                spprop[k] = (spprop[k] or 0) + v
	            end
            end
        else
            for i=1,num do 
	 		    local result,rewardkey = getRewardByPool(activeCfg.serverreward.pool2,1)
	 		    for k,v in pairs (result) do
	                for rk,rv in pairs(v) do
	                    reward[rk]=(reward[rk] or 0)+rv
	                end
	            end
	            local score = activeCfg.serverreward.pool2.score[rewardkey[1]] 
	            local tmpspprop = {}
	            tmpspprop[itemNeed] = score
	            for k,v in pairs(tmpspprop) do
	                spprop[k] = (spprop[k] or 0) + v
	            end
            end
            local totalnum = num*3
            for i=1,totalnum do 
	 		    local result,rewardkey = getRewardByPool(activeCfg.serverreward.pool1,1)
	 		    for k,v in pairs (result) do
	                for rk,rv in pairs(v) do
	                    reward[rk]=(reward[rk] or 0)+rv
	                end
	            end
	            local score = activeCfg.serverreward.pool1.score[rewardkey[1]] 
	            local tmpspprop = {}
	            tmpspprop[itemNeed] = score
	            for k,v in pairs(tmpspprop) do
	                spprop[k] = (spprop[k] or 0) + v
	            end
            end
        end
        -- ptb:p(spprop)
        -- ptb:e(reward)
        if not takeReward(uid,reward) then    
            response.ret=-403
            return response
        end
        for k,v in pairs(reward) do
            table.insert(report, formatReward({[k]=v}))
        end
        if next(spprop) then
            for k,v in pairs(spprop) do
                 mUseractive.info[self.aname][k] = (mUseractive.info[self.aname][k] or 0) + v
                 table.insert(report,self.formatreward({[k]=v}))
            end
        end
        if not mUserinfo.useGem(gems) then
            response.ret = -109
            return response
        end
        regActionLogs(uid,1,{action=237,item="",value=gems,params={num=num}})
        local clientReport= copyTable(report)
        -- 和谐版判断
        local harCReward={}
        if moduleIsEnabled('harmonyversion') ==1 then
        	local hReward,hClientReward
            if train==0 then
	            hReward,hClientReward = harVerGifts('active','dragonboat',num)
	        else
	        	hReward,hClientReward = harVerGifts('active','dragonboat',num,true)
	        	for k,v in pairs(hReward) do
	        		hReward[k] = v*num
	        	end
	        	for k,v in pairs(hClientReward) do
	        		for k1,v1 in pairs(v) do
	        			for k2,v2 in pairs(v1) do
	        				hClientReward[k][k1][k2] = v2*num
	        			end
	        		end
	        	end
	        end
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
            if type (data)~="table" then data={}  end
            table.insert(data,1,{ts,report,num,harCReward,train})
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
            response.data[self.aname].reward=clientReport
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
        local itemNeed = activeCfg.serverreward.itemNeed[1]
        local coststore=iteminfo.price*num
        -- 积分数量不足
        if mUseractive.info[self.aname][itemNeed]<coststore then
            response.ret=-1996
            return response
        end 
        -- 增加兑换次数
        mUseractive.info[self.aname].shop[itemid]=mUseractive.info[self.aname].shop[itemid]+num
        mUseractive.info[self.aname][itemNeed]=mUseractive.info[self.aname][itemNeed]-coststore
        local reward = {}
        for k,v in pairs(iteminfo.serverreward) do
        	reward[k] = v*num
        end
        if not takeReward(uid,reward) then
            response.ret=-102
            return response
        end

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
        local mUserinfo = uobjs.getModel('userinfo')
        -- 活动检测
        local activStatus = mUseractive.getActiveStatus(self.aname)
        if activStatus ~= 1 then
            response.ret = activStatus
            return response
        end
        local activeCfg = mUseractive.getActiveConfig(self.aname)
        local itemNeed = activeCfg.serverreward.itemNeed[1]
        -- 积分
        if mUseractive.info[self.aname][itemNeed]==nil  then
            mUseractive.info[self.aname][itemNeed]=0
        end
        if type(mUseractive.info[self.aname].shop)~='table' then
            mUseractive.info[self.aname].shop={}
            for k,v in pairs(activeCfg.serverreward.shopList) do
                table.insert(mUseractive.info[self.aname].shop,0)
            end
        end
        if mUseractive.info[self.aname].num==nil  then
            mUseractive.info[self.aname].num=0
        end
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

return api_active_dragonboat
