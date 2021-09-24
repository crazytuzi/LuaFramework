--desc:配件研制
--user:chenyunhe
--抽奖
-- 1   单抽(概率性 点亮一盏灯)
-- 2   连抽(直接全部点亮灯)

--任务
-- 1   共点亮N盏灯
-- 2   全部点亮N次
-- 3   使用上调N次
-- 4   使用下降N次
-- 5   使用全面激活N次
-- 6   消耗钻石N
-- 6个任务

local function api_active_pjyz(request)
    local self = {
        response = {
            ret = -1,
            msg ='error',
            data = {},
        },
        aname = 'pjyz',
    }

    -- 提升、下降、全面激活
    function self.action_rand(request)
        local uid = request.uid
        local response = self.response
        local itemid=request.params.item--1:提升 2:下降3：全部激活
        local free = tonumber(request.params.free) -- 0非免费 1免费
        local ts= getClientTs()
        local weeTs = getWeeTs()

        if not table.contains({0,1},free) or not table.contains({1,2,3},itemid) or not uid then
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
        if free ==1 and itemid==3 then
            response.ret = -102
            return response
        end
        --每日重置免费次数
        local activeCfg = mUseractive.getActiveConfig(self.aname)
		if mUseractive.info[self.aname].t < weeTs then
            mUseractive.info[self.aname].v = 0
            mUseractive.info[self.aname].t = weeTs
        end

        if mUseractive.info[self.aname].v==1 and free==1 then
            response.ret = -102
            return response
        end

        --判断是否有免费次数
        if mUseractive.info[self.aname].v == 0 and free ~=1 then
            response.ret = -102
            return response
        end

        local num=1  --全部激活为5个 其他都为1个灯
        -- 消耗钻石
        local gems = 0
        if free==1 then
        	 mUseractive.info[self.aname].v=1
        else
            if itemid==1 then
                 gems = activeCfg.cost1
            end
	 		if itemid ==2 then
                gems = activeCfg.cost2
            end
            if itemid==3 then
                gems=activeCfg.cost3
                num=activeCfg.lampNum
            end
        end

        if not mUserinfo.useGem(gems) then
            response.ret = -109
            return response
        end        

        local reward={}
        local actall=0--所有灯都激活1 未激活0
        local actone=0--激活一盏灯 0未点亮 1激活
        --此处赋值 是因为有些数据会随完成条件重置 
        local jdval=0--本次进度值
        local cufn=0--当前灯需要的值
        local lights=0--点亮的灯数

        if type(mUseractive.info[self.aname].lr)~='table' then
            mUseractive.info[self.aname].lr={}
        end

        local nextjd=0
        local nextfn=0
        local times=activeCfg.times or 1--大奖倍数
        local reward1={}--每次小奖励
        local reward2={}--点亮灯的奖励
        local reward3={}--最终大奖奖励

        setRandSeed()
        --全面激活 给灯的奖励和大奖  且对单次的进度不影响
        if itemid==3 then
            --所有灯奖励+最终大奖
            --灯的奖励
            for i=1,activeCfg.lampNum do
                local result,rewardkey = getRewardByPool(activeCfg.serverreward['pool2'])
                for k,v in pairs (result) do
                    reward[k]=(reward[k] or 0)+v
                    reward2[k]=(reward2[k] or 0)+v
                end
            end

            --最终大奖
            local result,rewardkey = getRewardByPool(activeCfg.serverreward['pool3'])
            for k,v in pairs (result) do
               reward[k]=(reward[k] or 0)+v*times
               reward3[k]=(reward3[k] or 0)+v*times
            end
            actall=1
            --任务1 点亮n盏灯
            mUseractive.info[self.aname].tk[1].cur=mUseractive.info[self.aname].tk[1].cur+activeCfg.lampNum
            jdval=mUseractive.info[self.aname].jd
            cufn= mUseractive.info[self.aname].fn
            lights =mUseractive.info[self.aname].li
            nextjd=mUseractive.info[self.aname].jd
            nextfn=mUseractive.info[self.aname].fn
        else
            cufn=mUseractive.info[self.aname].fn
            -- 初始化点亮灯的次数 和点亮灯的值
            if mUseractive.info[self.aname].jd==nil or mUseractive.info[self.aname].fn==nil or mUseractive.info[self.aname].li==nil then
                response.ret=-102
                return response
            end

            --提示玩家错误的操作(策划说这个先不用了)
            --提升超出右边界
            -- if itemid==1 and mUseractive.info[self.aname].jd==activeCfg.totalRange[2] then
            --     response.ret=-118
            --     return response
            -- end
            -- -- 下降超出左边界 
            -- if itemid==2 and mUseractive.info[self.aname].jd==activeCfg.totalRange[1] then
            --     response.ret=-118
            --     return response
            -- end

           
            local rd=rand(1,activeCfg.needTimes)
            if itemid==2 then
                rd=-rd
            end

            mUseractive.info[self.aname].jd=mUseractive.info[self.aname].jd+rd
            if  mUseractive.info[self.aname].jd<=activeCfg.totalRange[1] then
                mUseractive.info[self.aname].jd=activeCfg.totalRange[1]
            end

            if  mUseractive.info[self.aname].jd>=activeCfg.totalRange[2] then
                mUseractive.info[self.aname].jd=activeCfg.totalRange[2]
            end
            jdval=mUseractive.info[self.aname].jd
            -- 判断本次是否点亮一盏灯
            local left=mUseractive.info[self.aname].fn-activeCfg.faultRange
            local right=mUseractive.info[self.aname].fn+activeCfg.faultRange

            if mUseractive.info[self.aname].jd>=left and mUseractive.info[self.aname].jd<=right then
                actone=1
                mUseractive.info[self.aname].li=mUseractive.info[self.aname].li+1
                local initarea=rand(1,2)
                local initrd=rand(activeCfg.initateRange[initarea][1],activeCfg.initateRange[initarea][2])                
                mUseractive.info[self.aname].jd=initrd--点亮一盏灯  初始化新的进度
                --重置点亮位置
                mUseractive.info[self.aname].fn=rand(activeCfg.signRange[1],activeCfg.signRange[2])

                --灯的奖励
                local result,rewardkey = getRewardByPool(activeCfg.serverreward['pool2'])
                for k,v in pairs (result) do
                    reward[k]=(reward[k] or 0)+v
                    reward2[k]=(reward2[k] or 0)+v
                end

                table.insert(mUseractive.info[self.aname].lr,formatReward(result))
                --任务1 点亮n盏灯
                mUseractive.info[self.aname].tk[1].cur=mUseractive.info[self.aname].tk[1].cur+1
            end
            lights=mUseractive.info[self.aname].li
            -- 全部点亮获得大奖
            if mUseractive.info[self.aname].li==activeCfg.lampNum then
                actall=1
                local result,rewardkey = getRewardByPool(activeCfg.serverreward['pool3'])
                for k,v in pairs (result) do
                   reward[k]=(reward[k] or 0)+v*times
                   reward3[k]=(reward3[k] or 0)+v*times
                end
                mUseractive.info[self.aname].li=0--重置点亮灯的个数
                mUseractive.info[self.aname].lr={}--重置已点亮灯的奖励
            end
            nextjd=mUseractive.info[self.aname].jd
            nextfn=mUseractive.info[self.aname].fn

            --单次的奖励，每次都有 除了全部激活
            --使用单独的奖池获取
            local result,rewardkey = getRewardByPool(activeCfg.serverreward['pool1'])
            for k,v in pairs (result) do
               reward[k]=(reward[k] or 0)+v
               reward1[k]=(reward1[k] or 0)+v
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
        --返给客户端的奖励格式
        local r1={}
        local r2={}
        local r3={}
        for k,v in pairs(reward1) do
            table.insert(r1, formatReward({[k]=v}))
        end        

        for k,v in pairs(reward2) do
             table.insert(r2, formatReward({[k]=v}))
        end

        for k,v in pairs(reward3) do
             table.insert(r3, formatReward({[k]=v}))
        end

        -- 和谐版判断
        local harCReward={}
        if moduleIsEnabled('harmonyversion') ==1 then
            local harnum=1
            if itemid==3 then
                harnum=5
            end
            local hReward,hClientReward = harVerGifts('active','pjyz',harnum)
            if not takeReward(uid,hReward) then
                response.ret = -403
                return response
            end
            harCReward = hClientReward
        end
        -- 任务3 提升n次
        if itemid==1 then
            mUseractive.info[self.aname].tk[3].cur=mUseractive.info[self.aname].tk[3].cur+1
        end
        -- 任务2 下降n次
        if itemid==2 then
            mUseractive.info[self.aname].tk[4].cur=mUseractive.info[self.aname].tk[4].cur+1
        end
        --任务2 全部点亮n次
        if actall==1 then
            mUseractive.info[self.aname].tk[2].cur=mUseractive.info[self.aname].tk[2].cur+1
        end
        --任务5 全面激活
        if itemid==3 then
            mUseractive.info[self.aname].tk[5].cur=mUseractive.info[self.aname].tk[5].cur+1
        end
        
        if gems>0 then
            --任务6 累计消耗钻石
             mUseractive.info[self.aname].tk[6].cur=mUseractive.info[self.aname].tk[6].cur+gems
             regActionLogs(uid,1,{action=170,item="",value=gems,params={num=num}})
        end        
       

        if uobjs.save() then
 			local redis =getRedis()
            local redkey ="zid."..getZoneId()..self.aname..mUseractive.info[self.aname].st.."uid."..uid
            local data =redis:get(redkey)
            data =json.decode(data)
            if type (data)~="table" then data={} end
            
            table.insert(data,1,{ts,r1,num,harCReward,r2,r3})
            if next(data) then
                for i=#data,11,-1 do
                    table.remove(data)
                end

                data=json.encode(data)
                redis:set(redkey,data)
                redis:expireat(redkey,mUseractive.info[self.aname].et+86400)
            end
            response.data[self.aname] =mUseractive.info[self.aname]
            response.data[self.aname].actall =actall--本次是否全部激活
            response.data[self.aname].actone =actone--本次是否激活一个
            response.data[self.aname].jd =jdval --本次进度
            response.data[self.aname].fn =cufn --本次点亮灯需要的标志值
            response.data[self.aname].li =lights --点亮灯的数量
            response.data[self.aname].tk ={} --点亮灯的数量
            -- 用于点亮灯后 客户端刷新进度
            response.data[self.aname].nextjd =nextjd
            response.data[self.aname].nextfn =nextfn


            if next(harCReward) then
                response.data[self.aname].hReward=harCReward
            end

            response.data[self.aname].reward=r1--每次都有的小奖励
            response.data[self.aname].reward1=r2--本次点亮灯的
            response.data[self.aname].reward2=r3--最终大奖的
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

        -- 活动检测
        local activStatus = mUseractive.getActiveStatus(self.aname)
        if activStatus ~= 1 then
            response.ret = activStatus
            return response
        end        

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

    -- 刷新活动数据
    function self.action_refresh(request)
        local response = self.response
        local uid = request.uid
        local ts= getClientTs()
        local weeTs = getWeeTs()

        if not uid then 
            response.ret=-102
            return response
        end

        local uobjs = getUserObjs(uid)
        uobjs.load({"useractive"})
        local mUseractive = uobjs.getModel('useractive')

        -- 活动检测
        local activStatus = mUseractive.getActiveStatus(self.aname)
        if activStatus ~= 1 then
            response.ret = activStatus
            return response
        end        

        local activeCfg = mUseractive.getActiveConfig(self.aname)
        local saveflag=0
        --初始化  随机次数  点亮灯的标志值 点亮灯的数量
        if mUseractive.info[self.aname].jd==nil  or mUseractive.info[self.aname].fn==nil or mUseractive.info[self.aname].li==nil then
            setRandSeed()
            local rd=rand(activeCfg.signRange[1],activeCfg.signRange[2])
            mUseractive.info[self.aname].fn=rd --需要达到的值
            local initarea=rand(1,2)
            local initrd=rand(activeCfg.initateRange[initarea][1],activeCfg.initateRange[initarea][2])         
            mUseractive.info[self.aname].jd=initrd-- 初始化新的进度
            mUseractive.info[self.aname].li=0
            saveflag=1
        end

        if type(mUseractive.info[self.aname].lr)~='table' then--已经点亮灯的奖励
            mUseractive.info[self.aname].lr={}
        end

        --初始化任务
        if type(mUseractive.info[self.aname].tk)~='table' then
            mUseractive.info[self.aname].tk={}
            for k,v in pairs(activeCfg.serverreward.taskList) do
                --任务：当前值 完成条件 下标 领取状态
                mUseractive.info[self.aname].tk[v['index']]={cur=0,con=v['num'],index=v['index'],r=0}--r领取状态 0未领取 1可领取 2 已领取
            end
            saveflag=1
        end
        -- 更新任务
        for k,v in pairs(mUseractive.info[self.aname].tk) do
            if v.r==0 then
                if v.cur>=v.con then
                    v.r=1
                    saveflag=1
                end
            end
        end

        if saveflag==1 then uobjs.save() end
        response.data[self.aname]=mUseractive.info[self.aname]
        response.ret = 0
        response.msg = 'Success'

        return response
    end

    -- 领取任务奖励
    function self.action_taskreward(request)
        local response=self.response
        local uid=request.uid
        local tid=request.params.tid

        if not tid or not uid then
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
        -- 未完成
        if mUseractive.info[self.aname].tk[tid].r==0 then
            response.ret=-1981
            return response
        end
        -- 已领取
        if mUseractive.info[self.aname].tk[tid].r==2 then
            response.ret=-8037
            return response
        end
        -- 其他值
        if mUseractive.info[self.aname].tk[tid].r~=1 then
            response.ret=-102
            return response
        end
      
        local activeCfg = mUseractive.getActiveConfig(self.aname)
        local rewardCfg=activeCfg.serverreward.taskList[tid].serverreward
        --配置判断
        if type(rewardCfg)~='table' or not next(rewardCfg) then
            response.ret=-102
            return response
        end
        local reward={}
        for k,v in pairs(rewardCfg) do
            reward[v[1]]=(reward[v[1]] or 0)+v[2]
        end

        if not takeReward(uid,reward) then
            response.ret=-403
            return response
        end

        mUseractive.info[self.aname].tk[tid].r=2
        if uobjs.save() then
            response.data.reward=formatReward(reward)
            response.ret = 0
            response.msg = 'Success'
        else
            response.ret=-106
        end

        return response
    end

    return self
end

return api_active_pjyz