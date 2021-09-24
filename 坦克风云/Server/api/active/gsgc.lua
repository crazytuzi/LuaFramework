--
-- desc: 果树工程
-- user: chenyunhe
--
local function api_active_gsgc(request)
    local self = {
        response = {
            ret = -1,
            msg ='error',
            data = {},
        },
        aname = 'gsgc',
    }

    function self.formatreward(rewards)
        local formatreward = {}
        local key = 'gsgc'
        formatreward[key] = {}
        if type(rewards) == 'table' then
            for k,v in pairs(rewards) do
                formatreward[key][k] = v
            end 
        end
        return formatreward
    end

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
        local uid=request.uid
        local uobjs = getUserObjs(uid)
        uobjs.load({"userinfo",'useractive'})
        local mUseractive = uobjs.getModel('useractive')
        local activeCfg = mUseractive.getActiveConfig(self.aname)
        
        local flag = false
        -- 累计抽奖次数
        if mUseractive.info[self.aname].ln==nil  then
            flag = true
            mUseractive.info[self.aname].ln=0
        end

        -- 累计果实数量
        if not mUseractive.info[self.aname].gsgc_a1 then
            mUseractive.info[self.aname].gsgc_a1 = 0
            flag = true
        end

        -- 树汁
        if not mUseractive.info[self.aname].gsgc_a2 then
            mUseractive.info[self.aname].gsgc_a2 = 0
            flag = true
        end

        -- 果实阶段奖励领取记录
        if mUseractive.info[self.aname].g==nil then
            flag = true
            mUseractive.info[self.aname].g = {}
            for k,v in pairs(activeCfg.serverreward.giftList) do
                table.insert(mUseractive.info[self.aname].g,0)
            end
        end

        if type(mUseractive.info[self.aname].shop)~='table' then
            flag = true
            activeCfg = mUseractive.getActiveConfig(self.aname)
            mUseractive.info[self.aname].shop={}
            for k,v in pairs(activeCfg.serverreward.shopList) do
                table.insert(mUseractive.info[self.aname].shop,0)
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

    -- 果实奖励
    function self.action_gift(request)
        local uid = request.uid
        local response = self.response
        local ts =  getClientTs()
        local i = request.params.i --奖励下标
        local uobjs = getUserObjs(uid)
        uobjs.load({"userinfo",'useractive'})
        local mUseractive = uobjs.getModel('useractive')
        local mUserinfo = uobjs.getModel('userinfo')

        local activeCfg = mUseractive.getActiveConfig(self.aname)
        if mUseractive.info[self.aname].g[i]==1 then
            response.ret = -1976
            return response
        end

        local gcfg = activeCfg.serverreward.giftList[i]
        if type(gcfg)~='table' then
            response.ret = -120
            return response
        end

        local cur = mUseractive.info[self.aname].gsgc_a1 or 0
        if gcfg.num>cur then
            response.ret = -102
            return response
        end
        
        if not next(gcfg.r) then
            response.ret = -120
            return response
        end

        if not takeReward(uid,gcfg.r) then
            response.ret = -403
            return response
        end

        mUseractive.info[self.aname].g[i] = 1
        if uobjs.save() then
            processEventsAfterSave()
            response.data[self.aname] = mUseractive.info[self.aname]
            response.data[self.aname].reward = formatReward(gcfg.r)

            response.ret = 0
            response.msg = 'Success'
        else
            response.ret=-106
        end

        return response
    end

    -- 抽奖
    function self.action_lottery(request)
        local uid = request.uid
        local response = self.response
        local num = tonumber(request.params.num)
        local free = tonumber(request.params.free) -- 0非免费 1免费
        local ts= getClientTs()
        local weeTs = getWeeTs()

        local uobjs = getUserObjs(uid)
        uobjs.load({"userinfo","props","bag",'useractive'})
        local mUseractive = uobjs.getModel('useractive')
        local mUserinfo = uobjs.getModel('userinfo')
        local activeCfg = mUseractive.getActiveConfig(self.aname)
        if not table.contains({0,1},free) or not table.contains({1,activeCfg.costMul},num) then
           response.ret=-102
           return response
        end

		-- 免费时 单抽
        if free ==1 and num>1 then
            response.ret = -102
            return response
        end

		if mUseractive.info[self.aname].t ~= weeTs then
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
	            gems = activeCfg.cost2
	        end
        end

        if not mUseractive.info[self.aname].ln then
        	mUseractive.info[self.aname].ln = 0
        end

        local reward = {}
        local report = {}
        local gsgc_a1 = 0
        local gsgc_a2 = 0
        for i=1,num do 	
            mUseractive.info[self.aname].ln = mUseractive.info[self.aname].ln + 1
            if mUseractive.info[self.aname].ln%activeCfg.fruitRoutine == 0 then
                gsgc_a1 = gsgc_a1 + 1
            end
            -- 常规奖励
            local rd,rk = getRewardByPool(activeCfg.serverreward.pool,1)
            for k,v in pairs(rd) do
                 for rkey,rval in pairs(v) do
                    if string.find(rkey,'gsgc_a2') then
                        gsgc_a2 = gsgc_a2 + rval
                    else
                        reward[rkey]=(reward[rkey] or 0)+rval
                    end               
                end
            end
        end
        
        if gsgc_a1>0 then
            table.insert(report,self.formatreward({gsgc_a1=gsgc_a1}))
            mUseractive.info[self.aname].gsgc_a1 = mUseractive.info[self.aname].gsgc_a1 + gsgc_a1
        end

        if gsgc_a2>0 then
            table.insert(report,self.formatreward({gsgc_a2=gsgc_a2}))
            mUseractive.info[self.aname].gsgc_a2 = mUseractive.info[self.aname].gsgc_a2 + gsgc_a2
        end

        if next(reward) then    
            if not takeReward(uid,reward) then
                response.ret=-403
                return response
            end

            for k,v in pairs(reward) do
                table.insert(report,formatReward({[k]=v}))
            end
        end
 
        if gems>0 then
            if not mUserinfo.useGem(gems) then
                response.ret = -109
                return response
            end
            regActionLogs(uid,1,{action = 257, item = "", value = gems, params = {num = num}})
        end

        -- 和谐版判断
        local harCReward={}
        if moduleIsEnabled('harmonyversion') == 1 then
            local hReward,hClientReward = harVerGifts('active','gsgc',num)
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
                response.data[self.aname].hReward=harCReward  -- 和谐版奖励
            end
            response.data[self.aname].reward = report -- 奖励
 
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
    function self.action_shop(request)
        local response = self.response
        local uid=request.uid
        local itemid=request.params.i--兑换哪一个
        local num=request.params.num or 1 --兑换个数

        if num<=0 then
            response.ret = -102
            return response
        end

        local uobjs = getUserObjs(uid)
        uobjs.load({"userinfo",'useractive'})
        local mUseractive = uobjs.getModel('useractive')

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

        -- 兑换次数不足
        if mUseractive.info[self.aname].shop[itemid] + num > iteminfo.limit then
            response.ret=-121
            return response
        end

        local cost=iteminfo.price*num
        if mUseractive.info[self.aname].gsgc_a2<cost then
            response.ret=-1996
            return response
        end 

        -- 记录购买的次数
        mUseractive.info[self.aname].shop[itemid]=mUseractive.info[self.aname].shop[itemid]+num
        mUseractive.info[self.aname].gsgc_a2=mUseractive.info[self.aname].gsgc_a2 - cost

        local reward = {}
        for k,v in pairs(iteminfo.sr) do
            reward[k] = v * num
        end

        if not takeReward(uid,reward) then
            response.ret=-403
            return response
        end

        if uobjs.save() then
            response.data[self.aname] = mUseractive.info[self.aname]
            response.data[self.aname].areward = formatReward(reward)
            response.ret = 0
            response.msg = 'Success'
        else
          response.ret=-106
        end

        return response        
    end

    return self
end

return api_active_gsgc
