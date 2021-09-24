-- desc: 表彰大会
-- user: liming
local function api_active_bzdh(request)
    local self = {
        response = {
            ret = -1,
            msg ='error',
            data = {},
        },
        aname = 'bzdh',
    }

    -- 抽奖
    function self.action_lottery(request)
        local uid = request.uid
        local response = self.response
        local num = tonumber(request.params.num)
        local free = tonumber(request.params.free) -- 0非免费 1免费
        local ts= getClientTs()
        local weeTs = getWeeTs()
       
        if not table.contains({0,1},free) or not table.contains({1,10},num) or not uid then
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
	            num = 10
	            gems = activeCfg.cost2
	        end
        end

        local reward = {}
        local tmpreward = {}
        local report = {}
        local get = {}
        local tmpget = {}
        local target = {}
        local tmptarget = {}
        -- ptb:p(mUseractive.info[self.aname].target[1])
        for i=1,num do
            while (#tmpget<3) do
               tmpget = getRewardByPool(activeCfg.serverreward.pool_s2)
            end
            if i<2 then
                for k,v in pairs(tmpget) do
                    local ret = self.isIntable(v,mUseractive.info[self.aname].target[1])
                    if ret then
                        tmpreward = getRewardByPool(activeCfg.serverreward['pool_g'..v])
                    else
                        tmpreward = getRewardByPool(activeCfg.serverreward.basePool)
                    end
                    for k1,v1 in pairs(tmpreward) do
                        reward[k1] = (reward[k1] or 0)+v1
                    end 
                end
                
            else
                while (#tmptarget<3) do
                   tmptarget = getRewardByPool(activeCfg.serverreward.pool_s1)
                end
                for k,v in pairs(tmpget) do
                    local ret = self.isIntable(v,tmptarget)
                    if ret then
                        tmpreward = getRewardByPool(activeCfg.serverreward['pool_g'..v])
                    else
                        tmpreward = getRewardByPool(activeCfg.serverreward.basePool)
                    end
                    for k1,v1 in pairs(tmpreward) do
                        reward[k1] = (reward[k1] or 0)+v1
                    end 
                end
                table.insert(target,tmptarget)
                tmptarget = {}
            end
            table.insert(get,tmpget)
            tmpget = {}
        end
        while (#tmptarget<3) do
           tmptarget = getRewardByPool(activeCfg.serverreward.pool_s1)
        end
        table.insert(target,1,tmptarget)
        -- ptb:p(get)
        -- ptb:p(tmptarget)
        -- ptb:e(reward)
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
            regActionLogs(uid,1,{action = 205, item = "", value = gems, params = {num = num}})
        end

        -- 和谐版判断
        local harCReward={}
        if moduleIsEnabled('harmonyversion') == 1 then
            local hReward,hClientReward = harVerGifts('active','bzdh',num)
            if not takeReward(uid,hReward) then
                response.ret = -403
                return response
            end
            harCReward = hClientReward
        end
        mUseractive.info[self.aname].target = target
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
            response.data[self.aname].get = get
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
    
    -- 将领重生
    function self.action_rebirth(request)
         local response = self.response
         local uid=request.uid
         local hid=request.params.hid--将领id
         local action=request.params.act or 1 --1预览 2重生
         local costType=request.params.type -- 消耗物品类型 1 道具 2 钻石

         if not uid or not hid or not table.contains({1,2},action) or  not table.contains({1,2},costType) then
            response.ret=-102
            return response
         end
    
         local uobjs = getUserObjs(uid)
         uobjs.load({"userinfo",'useractive'})
         local mUseractive = uobjs.getModel('useractive')
         local mHero = uobjs.getModel('hero')
         local mBag = uobjs.getModel('bag')
         local mUserinfo = uobjs.getModel('userinfo')
         local mEquip= uobjs.getModel('equip')


         local heroinfo=copyTable(mHero.hero[hid]) or {}
         local equipinfo=copyTable(mEquip.info[hid]) or {}
        
        -- 活动检测
        local activStatus = mUseractive.getActiveStatus(self.aname)
        if activStatus ~= 1 then
            response.ret = activStatus
            return response
        end

        local activeCfg = mUseractive.getActiveConfig(self.aname)
        local flag,r=mHero.rebirth(hid,action)
        --判断是否满足条件
        if flag~=1 then
            response.ret=flag
            return response
        end


        if action==1 then
            response.ret = 0
            response.data.preview=r
            response.data[self.aname] =mUseractive.info[self.aname]
        else
            --使用道具
            if costType==1 then
                local herorebirthCfg = getConfig('herorebirth')
                local useprop=herorebirthCfg.useItem
                local usenum=herorebirthCfg.useNum
                local pid=useprop:split('_')
                if not mBag.use(pid[2],usenum) then
                    response.ret=-1996
                    return response
                end

            --使用钻石
            else
                if r.costGems<=0 then
                    response.ret=-102
                    return response
                end
                if not mUserinfo.useGem(r.costGems) then
                    response.ret = -109
                    return response
                end
            end
            
            --刷新战力
            regEventBeforeSave(uid,'e1')
            processEventsBeforeSave()
            if uobjs.save() then
                processEventsAfterSave()
                response.data.reward=r
                local jsonstr=json.encode(r)
                local jsonhero=json.encode(heroinfo)
                local jsonequp=json.encode(equipinfo)
                writeLog('uid='..uid..'--hid='..hid..'--return='..jsonstr..'--heroinfo='..jsonhero..'--equipinfo='..jsonequp,"herorebirth")
                response.data[self.aname] =mUseractive.info[self.aname]
                response.data.hero =mHero.toArray(true)
                response.data.equip =mEquip.toArray(true)
                response.ret = 0
                response.msg = 'Success'
            else
                response.ret=-106  
            end
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
        local tmptarget = {}
        if type(mUseractive.info[self.aname].target)~='table' then
            flag = true
            mUseractive.info[self.aname].target = {}
            while (#tmptarget<3) do
               tmptarget = getRewardByPool(activeCfg.serverreward.pool_s1)
            end
            table.insert(mUseractive.info[self.aname].target,tmptarget)
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

    function self.isIntable(b,tbl)
        if not tbl then
            return false
        end
        for k,v in pairs(tbl) do
            if b==v then
               return true
            end
        end
        return false
    end

    return self
end

return api_active_bzdh
