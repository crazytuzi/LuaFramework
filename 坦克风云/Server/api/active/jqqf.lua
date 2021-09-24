--
-- desc: 金秋祈福
-- user: chenyunhe
--
local function api_active_jqqf(request)
    local self = {
        response = {
            ret = -1,
            msg ='error',
            data = {},
        },
        aname = 'jqqf',
    }

    function self.formatreward(rewards)
        local formatreward = {}
        local key = 'jqqf'
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
        -- 活动兑换货币A
        if not mUseractive.info[self.aname].jqqf_a1 then
            flag = true
            mUseractive.info[self.aname].jqqf_a1 = 0
        end

        -- 活动兑换货币B
        if not mUseractive.info[self.aname].jqqf_a2 then
            flag = true
            mUseractive.info[self.aname].jqqf_a2 = 0
        end

        -- 单笔充值记录
        if type(mUseractive.info[self.aname].ch)~='table' then
            flag = true
            mUseractive.info[self.aname].ch = {}
            for k,v in pairs(activeCfg.serverreward.giftList) do
                table.insert(mUseractive.info[self.aname].ch,{0,0}) -- 可领取 已领取
            end
        end

        -- 兑换商店
        if type(mUseractive.info[self.aname].shop)~='table' then
            flag = true
            mUseractive.info[self.aname].shop = {}
            for k,v in pairs(activeCfg.serverreward.shopList) do
                table.insert(mUseractive.info[self.aname].shop,0)--兑换次数
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

    -- 充值奖励
    function self.action_charge(request)
        local uid = request.uid
        local response = self.response
        local i = request.params.i --下标

        local uobjs = getUserObjs(uid)
        uobjs.load({"userinfo",'useractive'})
        local mUseractive = uobjs.getModel('useractive')
        local mUserinfo = uobjs.getModel('userinfo')

        local activeCfg = mUseractive.getActiveConfig(self.aname)

        local gcfg = activeCfg.serverreward.giftList[i]
        if type(gcfg)~='table' then
            response.ret = -120
            return response
        end

        if mUseractive.info[self.aname].ch[i][2]>= gcfg.limit then
            response.ret = -1976
            return response
        end

        local num = mUseractive.info[self.aname].ch[i][1]
        if num<=0 then
            response.ret = -102
            return response
        end
        
        if not next(gcfg.r) then
            response.ret = -120
            return response
        end

        local reward = {}
        local report = {}
        for k,v in pairs(gcfg.r) do
            local gn = v*num
            if string.find(k,'jqqf') then
                mUseractive.info[self.aname][k] = (mUseractive.info[self.aname][k] or 0) + gn
                table.insert(report,self.formatreward({[k]=gn}))
            else
                reward[k] = gn
                table.insert(report,formatReward({[k]=gn}))
            end
        end

        if not takeReward(uid,reward) then
            response.ret = -403
            return response
        end

        mUseractive.info[self.aname].ch[i][1] = 0
        mUseractive.info[self.aname].ch[i][2] = mUseractive.info[self.aname].ch[i][2] + num
        if uobjs.save() then
            response.data[self.aname] = mUseractive.info[self.aname]
            response.data[self.aname].reward = report

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

        local reward = {}
        local report = {}
        local jqqf_a1 = 0
        local jqqf_a2 = 0
        for i=1,num do 	
            -- 常规奖励
            local rd,rk = getRewardByPool(activeCfg.serverreward.pool,1)
            for k,v in pairs(rd) do
                 for rkey,rval in pairs(v) do
                    if string.find(rkey,'jqqf_a1') then
                        jqqf_a1 = jqqf_a1 + rval
                    elseif string.find(rkey,'jqqf_a2') then
                        jqqf_a2 = jqqf_a2 + rval
                    else
                        reward[rkey]=(reward[rkey] or 0)+rval
                    end               
                end
            end
        end
        
        if jqqf_a1>0 then
            table.insert(report,self.formatreward({jqqf_a1=jqqf_a1}))
            mUseractive.info[self.aname].jqqf_a1 = (mUseractive.info[self.aname].jqqf_a1 or 0) + jqqf_a1
        end

        if jqqf_a2>0 then
            table.insert(report,self.formatreward({jqqf_a2=jqqf_a2}))
            mUseractive.info[self.aname].jqqf_a2 = (mUseractive.info[self.aname].jqqf_a2 or 0) + jqqf_a2
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
            regActionLogs(uid,1,{action = 262, item = "", value = gems, params = {num = num}})
        end

        -- 和谐版判断
        local harCReward={}
        if moduleIsEnabled('harmonyversion') == 1 then
            local hReward,hClientReward = harVerGifts('active','jqqf',num)
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
        	response.ret=-120
        	return response
        end

        -- 兑换次数不足
        if mUseractive.info[self.aname].shop[itemid] + num > iteminfo.limit then
            response.ret=-121
            return response
        end

        local flag = false
        for i=1,2 do
            if iteminfo['num'..i] and iteminfo['num'..i]>0 then
                if mUseractive.info[self.aname][activeCfg.changeItem[i]]<num*iteminfo['num'..i] then
                    response.ret  = -1996
                    return response
                else
                    flag = true
                    mUseractive.info[self.aname][activeCfg.changeItem[i]] = mUseractive.info[self.aname][activeCfg.changeItem[i]] - num*iteminfo['num'..i]
                end
            end
        end

        if not flag then
            response.ret = -102
            return response
        end

        local reward = {}
        for k,v in pairs(iteminfo.r) do
            reward[k] = v * num
        end

        if not takeReward(uid,reward) then
            response.ret=-403
            return response
        end

        -- 记录购买的次数
        mUseractive.info[self.aname].shop[itemid]=mUseractive.info[self.aname].shop[itemid]+num
        if uobjs.save() then
            response.data[self.aname] = mUseractive.info[self.aname]
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

return api_active_jqqf
