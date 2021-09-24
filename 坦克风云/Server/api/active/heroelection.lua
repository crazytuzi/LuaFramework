--desc:将领大选
--user:chenyunhe

local function api_active_heroelection(request)
    local self = {
        response = {
            ret = -1,
            msg ='error',
            data = {},
        },
        aname = 'heroelection',
    }

    -- 选举
    function self.action_elect(request)
        local uid = request.uid
        local response = self.response
        local hindex = tonumber(request.params.hindex) -- 选项
        local free = tonumber(request.params.free) -- 0非免费 1免费
        local item =tonumber(request.params.item) --单抽1 多抽2
        local ts= getClientTs()
        local weeTs = getWeeTs()
        
        if not table.contains({0,1},free) or not table.contains({1,2},item) or not table.contains({1,2,3},hindex) or not uid then
       	   response.ret=-102
       	   return response
        end

        local uobjs = getUserObjs(uid)
        uobjs.load({"userinfo","props","bag",'useractive'})
        local mUseractive = uobjs.getModel('useractive')
        local mHero= uobjs.getModel('hero')
        local mUserinfo = uobjs.getModel('userinfo')

        -- 活动检测
        local activStatus = mUseractive.getActiveStatus(self.aname)
        if activStatus ~= 1 then
            response.ret = activStatus
            return response
        end

		-- 免费时 单抽
        if free ==1 and item>1 then
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
        local num=1
        -- 消耗钻石
        local gems = 0
        if free==1 then
        	 mUseractive.info[self.aname].v=1
        else
	 		if item ==1 then
	            gems = activeCfg.cost1
	        else
	            num = 5
	            gems = activeCfg.cost2
	        end
        end
        -- 根据相同图片的数量情况 获取选票数
        --pnum 3:三张不同的 2:两张相同的 1:三张相同的
        local function getelectnum(pnum)
            local index=0
            if pnum==1 then index=3 end
            if pnum==2 then index=2 end
            if pnum==3 then index=1 end


            local match=activeCfg.numMatch
            for k,v in pairs(match) do
                if v.index==index then
                    return v.getNum
                end
            end

            return 0
        end

        -- 选举结果中 每种图片需要随机奖励次数
        -- num:每种图片的数量
        local function randnum(num)
            local match=activeCfg.numMatch
            for k,v in pairs(match) do
                if v.index==num then
                    return v.getNum
                end
            end

            return 0
        end

        local reward={}
        local addheroflag=false
        local tickets=0
        local pnum=activeCfg.serverreward.picType
        local randresult={}--随机结果
        local randtickets={}--随机到的选票
        -- 随机选举结果
        for i=1,num do
        	local er={}--每次选举结果(统计出 每张牌出现的数量 一共三张)
            local randr={}
        	for n=1,3 do
                local result,rewardkey = getRewardByPool(activeCfg.serverreward['heroPool'],1)
        		er[rewardkey[1]]=(er[rewardkey[1]] or 0)+1
                table.insert(randr,rewardkey[1])
        	end

            table.insert(randresult,randr)

            local electnum=0--获得选票数
            --计算每次的奖励
            for k,v in pairs(er) do
                local rdn=randnum(v)
                if k==pnum then
                    electnum=rdn
                else
                    for rn=1,rdn do
                        local rd,rk = getRewardByPool(activeCfg.serverreward['pool'..k],1)
                        local rcfg=activeCfg.serverreward['pool'..k][3][rk[1]]
                        reward[rcfg[1]]=(reward[rcfg[1]] or 0)+rcfg[2]
                    end
                end
            end

            -- 当前将领增加选票
            if type(mUseractive.info[self.aname].hero)~='table' then
                mUseractive.info[self.aname].hero={}
                for k,v in pairs(activeCfg.heroMatch) do
                    table.insert(mUseractive.info[self.aname].hero,{t=v.needTicket,c=0,n=0})--需要的票数 当前的票数 已经重置过几次
                end
            end
    
            --增加选票 且判断奖励将领情况
            if electnum>0  then
                tickets=tickets+electnum
                mUseractive.info[self.aname].hero[hindex].c=mUseractive.info[self.aname].hero[hindex].c+electnum
                --1 满足条件  给将领 如果将领已存在 给魂 且重置下一轮票数
                if mUseractive.info[self.aname].hero[hindex].c>=mUseractive.info[self.aname].hero[hindex].t then
                    local hero=activeCfg.heroMatch[hindex].hero
                    local hstar=activeCfg.heroMatch[hindex].star or 1                    
                    reward["hero_"..hero]=hstar
                   
                    local ext=mUseractive.info[self.aname].hero[hindex].c-mUseractive.info[self.aname].hero[hindex].t
                    -- 重置选票
                    local needTickets=activeCfg.heroMatch[hindex].needTicket
                    mUseractive.info[self.aname].hero[hindex].c=ext
                    mUseractive.info[self.aname].hero[hindex].n=(mUseractive.info[self.aname].hero[hindex].n or 0)+1
                    mUseractive.info[self.aname].hero[hindex].t=needTickets+mUseractive.info[self.aname].hero[hindex].n*activeCfg.heroMatch[hindex].needGrow
                end
                table.insert(randtickets,{mUseractive.info[self.aname].hero[hindex].c,mUseractive.info[self.aname].hero[hindex].t})
            end
        end


        if not takeReward(uid,reward) then
            response.ret=-403
            return response
        end

        local report={}
        for k,v in pairs(reward) do
            table.insert(report, formatReward({[k]=v}))
        end

        if not mUserinfo.useGem(gems) then
            response.ret = -109
            return response
        end

        if gems>0 then
        	 regActionLogs(uid,1,{action=171,item="",value=gems,params={num=num}})
        end

        -- 和谐版判断
        local harCReward={}
        if moduleIsEnabled('harmonyversion') ==1 then
            local hReward,hClientReward = harVerGifts('active','heroelection',num)
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
            
            table.insert(data,1,{ts,report,num,harCReward,tickets})
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
            response.data[self.aname].reward=report
            response.data[self.aname].tickets=tickets 
            response.data[self.aname].randresult=randresult
            response.data[self.aname].randtickets=randtickets
            response.data.hero =mHero.toArray(true)

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


    --  将领重生
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

    -- 刷新将领大选
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

        if type(mUseractive.info[self.aname].hero)~='table' then
            mUseractive.info[self.aname].hero={}
            for k,v in pairs(activeCfg.heroMatch) do
                table.insert(mUseractive.info[self.aname].hero,{t=v.needTicket,c=0,n=0})--需要的票数 当前的票数 已经重置过几次
            end
        end
        

        response.data[self.aname] =mUseractive.info[self.aname]
        response.ret = 0
        response.msg = 'Success'

        return response
    end




    return self
end

return api_active_heroelection