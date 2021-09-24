--
-- desc: 合服大战
-- user: chenyunhe
--

local function api_active_hfdz(request)
	local self = {
	     response = {
            ret = -1,
            msg ='error',
            data = {},
        },
        aname = 'hfdz',
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

    -- 刷新
    function self.action_refresh(request)
    	local response = self.response
        local uid=request.uid
        local uobjs = getUserObjs(uid)
        uobjs.load({"userinfo",'useractive'})
        local mUseractive = uobjs.getModel('useractive')
        local mUserinfo = uobjs.getModel('userinfo')

        local flag = mUseractive.initAct(self.aname)


        if flag then
            if not uobjs.save() then
                response.ret = -106
                return response
            end
        end

        response.data[self.aname] = mUseractive.info[self.aname]
        response.data[self.aname].ascore = self.getalscore(mUseractive.info[self.aname].st,mUserinfo.alliance)
        response.ret = 0
        response.msg = 'Success'

        return response
    end

    -- 
    function self.getalscore(st,alliance)
        local score = 0
        if alliance>0 then
            local redis =getRedis()
            local scorekey = "zid."..getZoneId().."."..self.aname.."ts"..st..'score'
            local scorelist = json.decode(redis:get(scorekey))

            if type(scorelist)~='table' or not next(scorelist) then
                scorelist = {}
            end

            for k,v in pairs(scorelist) do
                if tonumber(v[1]) == alliance then
                   score = v[3]
                   break
                end
            end
        end

        return score
    end

    -- 领取任务奖励
    function self.action_task(request)
    	local response = self.response
        local uid=request.uid
        local tid = request.params.tid -- 哪个任务  下标
        local ts= getClientTs()
        local weeTs = getWeeTs()
        if not tid  then
           response.ret =-102
           return response
        end
        local uobjs = getUserObjs(uid)
        uobjs.load({"userinfo",'useractive'})
        local mUseractive = uobjs.getModel('useractive')
        local mUserinfo = uobjs.getModel('userinfo')

        mUseractive.initAct(self.aname)--打开领取界面 然后静等过零点 数据刷新了
        if type(mUseractive.info[self.aname].task)~='table' then
            response.ret = -102
            return response
        end

        local activeCfg = mUseractive.getActiveConfig(self.aname)
        local taskCfg = activeCfg.serverreward.taskList[1][tid]	
       
        if type(taskCfg)~='table' then
        	response.ret = -102
        	return response
        end
 
        -- 已经领取了
        if mUseractive.info[self.aname].task[tid][2]>=taskCfg.limit then
            response.ret = -1993
            return response
        end

        local cur = mUseractive.info[self.aname].task[tid][1]
        local fn = math.floor((cur-mUseractive.info[self.aname].task[tid][2]*taskCfg.num)/taskCfg.num)
        local ablenum = 0
        if mUseractive.info[self.aname].task[tid][2]+fn>taskCfg.limit then
            ablenum = taskCfg.limit-mUseractive.info[self.aname].task[tid][2]
        else
            ablenum = fn
        end

        if ablenum<=0 then
        	response.ret = -102
        	return response
        end

        local reward = {}
        for k,v in pairs(taskCfg.serverreward) do
            reward[k] = (reward[k] or 0) + v*ablenum
        end

 
        if not takeReward(uid,reward) then
            response.ret =-403
            return response
        end

        mUseractive.info[self.aname].task[tid][2] = mUseractive.info[self.aname].task[tid][2]+ablenum
        local score = taskCfg.score*ablenum
        if mUserinfo.alliance>0 then
            mUseractive.info[self.aname].s = mUseractive.info[self.aname].s + score
        end   

     
        if uobjs.save() then
        	self.addscore(mUseractive,mUserinfo.alliance,score)

            response.data[self.aname] = mUseractive.info[self.aname]
            response.data[self.aname].reward = formatReward(reward)
            response.data[self.aname].ascore = self.getalscore(mUseractive.info[self.aname].st,mUserinfo.alliance)
            response.ret = 0
            response.msg = 'Success'
        else
          response.ret=-106
        end

        return response
    end

    function self.addscore(mUseractive,aid,score)
        local ts= getClientTs()
        if aid>0 then
            if ts < tonumber(mUseractive.getAcet(self.aname, true)) then 
                local redis = getRedis()
                local scorekey = "zid."..getZoneId().."."..self.aname.."ts"..mUseractive.info[self.aname].st..'score'
                local scorelist = json.decode(redis:get(scorekey))

                if type(scorelist)~='table' or not next(scorelist) then
                    scorelist = {}
                end

                local aexit = false
                local setRet,code=M_alliance.getalliance{aid=aid}
                if type(setRet['data'])=='table' and next(setRet['data']) then
                    for k,v in pairs(scorelist) do
                        if tonumber(v[1]) == aid then
                            v[2] = setRet['data']['alliance']['name']
                            v[3] = v[3] + score

                            aexit = true
                            break
                        end
                    end

                    if not aexit then
                        table.insert(scorelist,{aid,setRet['data']['alliance']['name'],score,ts})
                    end

                    redis:set(scorekey,json.encode(scorelist))
                    redis:expireat(scorekey,mUseractive.info[self.aname].et+86400)  
                end
            end
        end

    end

    -- 军团积分排行榜
    function self.acrank(st,et,limitscore)
        local redkey = "zid."..getZoneId().."."..self.aname.."ts"..st..'score'
        local redis = getRedis()
        local scorelist = json.decode(redis:get(redkey))
       
        if type(scorelist)~='table' or not next(scorelist) then
            scorelist = {}
            local list = readRankfile(self.aname,st)
            if type(list) == 'table' then
                redis:set(redkey,json.encode(list))
                redis:expireat(redkey,et+86400)
                scorelist = list
            end
        else
            -- 排序
            table.sort( scorelist,function ( a,b )  
                -- body  
                if a[3]==b[3] then  
                    return a[4] < b [4]
                end 
        
                return a[3] > b[3]  
            end ) 

            local ranklist = json.encode(scorelist)
            writeActiveRankLog(ranklist,self.aname,st) -- 排行榜记录日志
        end

        local list = {}
        local num = 0 -- 显示前10条
        for k,v in pairs(scorelist) do
            if num>=10 then
                break
            end

            if v[3]>=limitscore then
                 table.insert(list,v)
            end 
            num = num + 1 
        end

        return list
    end

       -- 获取排行榜数据
    function self.action_getRank(request)
        local uid = request.uid
        local response = self.response
 
        if not uid  then
            response.ret =-102
            return response
        end
        local uobjs = getUserObjs(uid)
        uobjs.load({"userinfo",'useractive'})
        local mUseractive = uobjs.getModel('useractive')
        local mUserinfo =  uobjs.getModel('userinfo')

        -- 活动检测
        local activStatus = mUseractive.getActiveStatus(self.aname)
        if activStatus ~= 1 then
            response.ret = activStatus
            return response
        end
        local activeCfg = mUseractive.getActiveConfig(self.aname)

        local ranklist = {}
        local currank = -1

        ranklist = self.acrank(mUseractive.info[self.aname].st,mUseractive.info[self.aname].et,activeCfg.scoreLimit)
        for k,v in pairs(ranklist) do
            if v[1] == mUserinfo.alliance then
                currank = k
                break
            end
        end
   
        response.ret = 0
        response.msg = 'success'
        response.data[self.aname] = mUseractive.info[self.aname]
        response.data[self.aname].arank = ranklist
        response.data[self.aname].currank = currank
        response.data[self.aname].ascore = self.getalscore(mUseractive.info[self.aname].st,mUserinfo.alliance)

        return response
    end

     -- 领取排行榜奖励
    function self.action_rankReward(request)
        local uid = request.uid
        local response = self.response
        local rank = request.params.rank
        local ts = getClientTs()
 
        local uobjs = getUserObjs(uid)
        uobjs.load({"userinfo",'useractive'})
        local mUseractive = uobjs.getModel('useractive')
        local mUserinfo =  uobjs.getModel('userinfo')

        local lt = tonumber(mUseractive.getAcet(self.aname, true))
        -- 时间还没到
        if ts < lt then
            response.ret =-1978
            return response
        end

        if mUserinfo.alliance == 0 then
            response.ret = -4005
            return response
        end

        -- 最后一天加入军团的玩家不能领取
        local execRet = M_alliance.getalliance{uid=uid,aid=mUserinfo.alliance,acallianceLevel=1}
        local joinAt = tonumber(execRet.data.join_at) or 0
        if joinAt >= lt then
            response.ret = -27001
            return response
        end
        
        -- 已经领取奖励
        if mUseractive.info[self.aname].a2 == 1 then
            response.ret = -1976
            return response
        end
        local activeCfg = mUseractive.getActiveConfig(self.aname)
        
        -- 获取排名
        local myrank = -1
        local ranklist = self.acrank(mUseractive.info[self.aname].st,mUseractive.info[self.aname].et,activeCfg.scoreLimit)
        if type(ranklist)=='table' and next(ranklist) then
            for k,v in pairs(ranklist) do
                local aid= tonumber(v[1])
                if aid == mUserinfo.alliance then
                    myrank = k
                    break
                end
            end
        else
            response.ret = -1975
            return response
        end 

        if myrank ~= rank then
            response.ret = -102
            return response
        end

        
      
        -- 判断排名获得奖励下标
        local matchgift = 0
        for k,v in pairs(activeCfg.section) do
            if myrank>=v[1] and myrank<=v[2] then
                matchgift = k
                break
            end
        end

        if matchgift == 0 then
            response.ret = -102
            return response
        end

        if not takeReward(uid, activeCfg.serverreward['rank'..matchgift]) then
            response.ret = -403
            return response
        end

        mUseractive.info[self.aname].a2 = 1
        processEventsBeforeSave()
        if uobjs.save() then
            processEventsAfterSave()
            response.ret = 0
            response.msg = 'success'
            response.data[self.aname] = mUseractive.info[self.aname]
            response.data[self.aname].reward = formatReward(activeCfg.serverreward['rank'..matchgift])
        else
            response.ret = -106
        end

        return response
    end

    -- buy
    function self.action_buy(request)
        local response = self.response
        local uid=request.uid
      
        local uobjs = getUserObjs(uid)
        uobjs.load({"userinfo",'useractive'})
        local mUseractive = uobjs.getModel('useractive')
        local mUserinfo = uobjs.getModel('userinfo')

        local activeCfg = mUseractive.getActiveConfig(self.aname)
        local taskCfg = activeCfg.serverreward.taskList[2][1] 

        local bn = mUseractive.info[self.aname].bn or 0
        if bn>=taskCfg.limit then
            response.ret = -1987
            return response
        end

        local costGem = taskCfg.num
        if not mUserinfo.useGem(costGem) then
            response.ret = -109
            return response
        end

        if not takeReward(uid, taskCfg.serverreward) then
            response.ret = -403
            return response
        end

        mUseractive.info[self.aname].bn =  (mUseractive.info[self.aname].bn or 0)+1

        if mUserinfo.alliance>0 then
            mUseractive.info[self.aname].s = mUseractive.info[self.aname].s + taskCfg.score
        end 


        if costGem>0 then
            regActionLogs(uid, 1, {action = 199, item = "", value = costGem, params = {num = 1}})
        end     

        local score = taskCfg.score
        processEventsBeforeSave()
        if uobjs.save() then
            processEventsAfterSave()
            self.addscore(mUseractive,mUserinfo.alliance,score)
            response.ret = 0
            response.msg = 'success'
            response.data[self.aname] = mUseractive.info[self.aname]
            response.data[self.aname].reward = formatReward(taskCfg.serverreward)
            response.data[self.aname].ascore = self.getalscore(mUseractive.info[self.aname].st,mUserinfo.alliance)
        else
            response.ret = -106
        end

        return response

    end

    function self.action_scorereward(request)
        local response = self.response
        local uid=request.uid
        local ts = getClientTs()
      
        local uobjs = getUserObjs(uid)
        uobjs.load({"userinfo",'useractive'})
        local mUseractive = uobjs.getModel('useractive')
        local mUserinfo = uobjs.getModel('userinfo')

        local lt = tonumber(mUseractive.getAcet(self.aname, true))
        -- 时间还没到
        if ts < lt then
            response.ret =-1978
            return response
        end

        local activeCfg = mUseractive.getActiveConfig(self.aname)
        if mUserinfo.alliance==0 then
            response.ret = -4005
            return response
        end

        if mUseractive.info[self.aname].a1 == 1 then
            response.ret = -1976
            return response
        end

        local redis = getRedis()
        local scorekey = "zid."..getZoneId().."."..self.aname.."ts"..mUseractive.info[self.aname].st..'score'
        local scorelist = json.decode(redis:get(scorekey))

        if type(scorelist)~='table' or not next(scorelist) then
            scorelist = {}
        end
        local alscore = 0
        for k,v in pairs(scorelist) do
            if tonumber(v[1]) == mUserinfo.alliance  then
                alscore= v[3]
                break
            end
        end
        
        if alscore<activeCfg.scoreLimit then
            response.ret = -102
            return response
        end

        if not takeReward(uid,activeCfg.serverreward.shareReward) then
            response.ret = -403
            return response
        end

        mUseractive.info[self.aname].a1 = 1
        processEventsBeforeSave()
        if uobjs.save() then
            processEventsAfterSave()
            response.ret = 0
            response.msg = 'success'
            response.data[self.aname] = mUseractive.info[self.aname]
            response.data[self.aname].reward = formatReward(activeCfg.serverreward.shareReward)
        else
            response.ret = -106
        end

        return response

    end

    return self
end

return api_active_hfdz