--
-- desc: 狙击海盗
-- user: chenyunhe
--
local function api_active_jjhd(request)
    local self = {
        response = {
            ret = -1,
            msg ='error',
            data = {},
        },
        aname = 'jjhd',
    }

    -- 随机奖励并获得积分
    function self.action_lottery(request)
        local uid = request.uid
        local response = self.response
        local num = tonumber(request.params.num)
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

        local reward = {}
        local report = {}
        local finalscore = 0
        local target = {}

        for i=1,num do
        	local result,rewardkey = getRewardByPool(activeCfg.serverreward.mainPool)
        	local score = activeCfg.serverreward.mainPool[4][rewardkey[1]]

            -- 常规奖励
            local rd,rk = getRewardByPool(activeCfg.serverreward['pool'..rewardkey[1]],1)
            for k,v in pairs(rd) do
                 for rkey,rval in pairs(v) do
                    reward[rkey]=(reward[rkey] or 0)+rval
                end
            end
            table.insert(target,result[1])
            finalscore = finalscore + score
        end
     
        -- 连抽 必定击中特殊目标并获得额外奖励和积分
        local sptarget = false
        if num>1 then
        	sptarget = true
        else
        	-- 单次有可能击中特殊目标
        	if target[1] == mUseractive.info[self.aname].sp then
        		sptarget =  true
        	end
        end

        if sptarget then
        	local rg,rgk = getRewardByPool(activeCfg.serverreward.goldpool,1)
            for k,v in pairs(rg) do
                 for rgkey,rgval in pairs(v) do
                    reward[rgkey]=(reward[rgkey] or 0)+rgval
                end
            end
            finalscore = finalscore + activeCfg.extraScore
        end

        -- 更换特殊目标
        local result,rewardkey = getRewardByPool(activeCfg.serverreward.mainPool)
        mUseractive.info[self.aname].sp = result[1]
        -- 获得奖励
        mUseractive.info[self.aname].s=(mUseractive.info[self.aname].s or 0)+finalscore
        for k,v in pairs(reward) do
            table.insert(report, formatReward({[k]=v}))
        end
 
        if not takeReward(uid,reward) then
            response.ret=-403
            return response
        end

        if not mUserinfo.useGem(gems) then
            response.ret = -109
            return response
        end

        if gems>0 then
            regActionLogs(uid,1,{action = 180, item = "", value = gems, params = {num = num}})
        end

        -- 和谐版判断
        local harCReward={}
        if moduleIsEnabled('harmonyversion') == 1 then
            local hReward,hClientReward = harVerGifts('active','jjhd',num)
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
            
            table.insert(data,1,{ts,report,num,harCReward,finalscore})
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
            response.data[self.aname].allreward = report -- 奖励
            response.data[self.aname].finalscore = finalscore --本次获得积分
            response.data[self.aname].spflag = target --是否击中特殊目标

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
            response.data[self.aname].allreward = formatReward(reward)
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
        -- 积分
        if mUseractive.info[self.aname].s==nil  then
            flag = true
            mUseractive.info[self.aname].s=0
        end

        -- 初始化特殊目标
        if mUseractive.info[self.aname].sp==nil then
        	flag = true
        	local activeCfg = mUseractive.getActiveConfig(self.aname)
        	local result,rewardkey = getRewardByPool(activeCfg.serverreward.mainPool)
        	mUseractive.info[self.aname].sp = result[1] 
        end

        if type(mUseractive.info[self.aname].shop)~='table' then
            flag = true
            local activeCfg = mUseractive.getActiveConfig(self.aname)
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

    return self
end

return api_active_jjhd
