--
-- desc: 节日花朵
-- user: chenyunhe
--
local function api_active_jrhd(request)
    local self = {
        response = {
            ret = -1,
            msg ='error',
            data = {},
        },
        aname = 'jrhd',
    }

    function self.formatreward(rewards)
        local formatreward = {}
        local key = 'jrhd'
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
        local mUserinfo = uobjs.getModel('userinfo')
        local activeCfg = mUseractive.getActiveConfig(self.aname)
        local flag = false

        -- 活动道具  色块
        for _,v in pairs(activeCfg.colorItem) do
            if not mUseractive.info[self.aname][v] then
                mUseractive.info[self.aname][v] = 0
                flag = true
            end
        end

        -- 三种花多涂色进度
        if type(mUseractive.info[self.aname].flowers)~='table' then
            mUseractive.info[self.aname].flowers = {}
            for k,v in pairs(activeCfg.colorNeed) do
                table.insert(mUseractive.info[self.aname].flowers,0)
            end
            flag = true
        end

        -- 军团共享奖励领取的总数  如果退出军团需要清零
        if not mUseractive.info[self.aname].pshare then
            mUseractive.info[self.aname].pshare = 0
        end

        -- 任务
        mUseractive.info[self.aname].task,f = self.refTask(mUseractive.info[self.aname],activeCfg.serverreward.taskList)
        if f then flag = true end
        -- 个人贡献积分
        if not mUseractive.info[self.aname].pscore then
            mUseractive.info[self.aname].pscore = 0
        end

        -- 是否领取过军团排行奖励
        if not mUseractive.info[self.aname].rw then
            mUseractive.info[self.aname].rw = 0
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

    -- 获取任务列表
    function self.action_tasklist(request)
        local response = self.response
        local uid = request.uid
     
        local uobjs = getUserObjs(uid)
        uobjs.load({"userinfo",'useractive'})
        local mUseractive = uobjs.getModel('useractive')
        local mUserinfo = uobjs.getModel('userinfo')
        local activeCfg = mUseractive.getActiveConfig(self.aname)
    
        mUseractive.info[self.aname].task = self.refTask(mUseractive.info[self.aname],activeCfg.serverreward.taskList)
        if uobjs.save() then
            response.data[self.aname] =mUseractive.info[self.aname]

            local cur = mUseractive.info[self.aname].pshare or 0
            local total = 0
            if mUserinfo.alliance>0 then
                local mAllianceActive = getModelObjs("allianceactive",mUserinfo.alliance,false,true)
                if mAllianceActive then
                    local activeObj = mAllianceActive.getActiveObj(self.aname)
                    total = activeObj.activeInfo.share or 0
                end
            end
            -- 可以领取的共享奖励的个数
            response.data[self.aname].sharenum = self.getsharenum(cur,total,activeCfg.shareGetLimit,uid)
            response.data[self.aname].daynum = self.getdaynum(uid)
            response.ret = 0
            response.msg = 'Success'
        else
            response.ret=403
        end
        return response      
    end

    -- 刷新任务
    function self.refTask(ainfo,taskcfg)
        local flag = false
        if type(ainfo.task)~='table' then
            ainfo.task = {}
            for k,v in pairs(taskcfg) do
                ainfo.task[k] = {1,0,0}-- 当前任务id 进度 领取状态
            end
            flag = true
        end
  
        for k,v in pairs(ainfo.task) do
            if v[3]==0 and v[2]>=taskcfg[k][v[1]].num then
                v[3] = 1 -- 0未领取 1可领取 2 已领取
                flag = true
            end
        end

        return ainfo.task,flag
    end

    -- 任务奖励
    function self.action_treward(request)
        local uid = request.uid
        local response = self.response
        local tid1 = request.params.tid1 -- 任务链编号
        local tid2 = request.params.tid2 -- 任务链中任务的编号
        local ts = getClientTs()
        
        if not tid1 or not tid2 then
            response.ret = -102
            return response
        end

        local uobjs = getUserObjs(uid)
        uobjs.load({"userinfo","props","bag",'useractive'})
        local mUseractive = uobjs.getModel('useractive')
        local mUserinfo = uobjs.getModel('userinfo')

        if ts>tonumber(mUseractive.getAcet(self.aname, true)) then
            response.ret = -102
            return response
        end

        local activeCfg = mUseractive.getActiveConfig(self.aname)
        local itemcfg = activeCfg.serverreward.taskList[tid1][tid2]
        if not itemcfg then
            response.ret = -120
            return response
        end

        if not mUseractive.info[self.aname].task[tid1] or mUseractive.info[self.aname].task[tid1][1]~=tid2 then
            response.ret = -102
            return response
        end

        if mUseractive.info[self.aname].task[tid1][3]~=1 then
            response.ret = -102
            return response
        end

        if type(itemcfg.r)~='table' then
            response.ret = -120
            return response
        end

        local report = {}
        local reward = {}
        local actprop = {}
        for k,v in pairs(itemcfg.r) do
            if table.contains(activeCfg.colorItem,k) then   
                actprop[k] = (actprop[k] or 0) + v
            else
                reward[k] = (reward[k] or 0) + v
            end
        end

        local aid = mUserinfo.alliance
        if itemcfg.next then
            mUseractive.info[self.aname].task[tid1][1] = itemcfg.next
            mUseractive.info[self.aname].task[tid1][3] = 0
        else
            -- 任务链最后一个
            mUseractive.info[self.aname].task[tid1][3] = 2 -- 0未领取 1可领取 2已领取
        end
        mUseractive.info[self.aname].task = self.refTask(mUseractive.info[self.aname],activeCfg.serverreward.taskList)
        
        local total = 0
        local cur = mUseractive.info[self.aname].pshare or 0
        -- 有共享奖励
        if aid>0 and itemcfg.sharePool then
            local mAllianceActive = getModelObjs("allianceactive",aid,false,true)
            if mAllianceActive then
                local params = {}
                local setRet,code=M_alliance.getalliance{aid=mUserinfo.alliance}

                if type(setRet['data'])=='table' and next(setRet['data']) then
                     params.anum = tonumber(setRet['data']['alliance']['num'])
                end
                
                params.allianceName=mUserinfo.alliancename
                params.share = 1

                local activeObj = mAllianceActive.getActiveObj(self.aname)
                activeObj:addshare(params)

                total = activeObj.activeInfo.share or 0
            else
                writeLog({msg="jrhd addshare error",aid=aid,num=1})
            end

            -- 完成任务中的共享奖励 跟全军团分享的不冲突 
            local rd,rk = getRewardByPool(activeCfg.serverreward["p"..itemcfg.sharePool],1)
            for k,v in pairs(rd) do
                 for rkey,rval in pairs(v) do
                    if table.contains(activeCfg.flowerItem,rkey) or table.contains(activeCfg.colorItem,rkey) then
                        actprop[rkey] = (actprop[rkey] or 0) + rval
                    else
                        reward[rkey]=(reward[rkey] or 0)+rval
                    end               
                end
            end
        end

        if next(reward) then
            if not takeReward(uid,reward) then
                response.ret = -403
                return response
            end

            for k,v in pairs(reward) do
                table.insert(report,formatReward({[k]=v}))
            end
        end

        if next(actprop) then
            for k,v in pairs(actprop) do
                mUseractive.info[self.aname][k] = (mUseractive.info[self.aname][k] or 0) + v
                table.insert(report,self.formatreward({[k]=v}))
            end
        end

        if uobjs.save() then
            processEventsAfterSave()
            response.data[self.aname] = mUseractive.info[self.aname]
            response.data[self.aname].reward = report 

            response.data[self.aname].sharenum = self.getsharenum(cur,total,activeCfg.shareGetLimit,uid)
            response.data[self.aname].daynum = self.getdaynum(uid)

           
            response.ret = 0
            response.msg = 'Success'
        else
            response.ret = -106
        end

        return response
    end

    -- cur 当前已领取的数量（总数）
    -- total 军团共享总数
    -- limit 每日限制数
    function self.getsharenum(cur,total,limit,uid)
        local num = 0
        local redis = getRedis()
        local date = getDateByTimeZone(getClientTs(),'%m%d')
        local redkey = "zid."..getZoneId()..self.aname..'share'..uid..'_'..date
        local sharenum = tonumber(redis:get(redkey)) or 0

        local left = total-cur
        local dleft = limit - sharenum
        if left>0 and dleft>0 then
            num = left>dleft and dleft or left
        end
        
        return num
    end

    -- 获取当日已领取的数量
    function self.getdaynum(uid)
        local redis = getRedis()
        local date = getDateByTimeZone(getClientTs(),'%m%d')
        local redkey = "zid."..getZoneId()..self.aname..'share'..uid..'_'..date
        local sharenum = tonumber(redis:get(redkey)) or 0

        return sharenum
    end

    -- 设置每日获得共享奖励次数
    function self.setsharenum(num,uid)
        local redis = getRedis()
        local date = getDateByTimeZone(getClientTs(),'%m%d')
        local redkey = "zid."..getZoneId()..self.aname..'share'..uid..'_'..date
        local sharenum = tonumber(redis:get(redkey)) or 0

        redis:set(redkey,sharenum+num) -- 如果已经领取够一天的数量 
        redis:expire(redkey,86400)
    end

    -- 领取共享奖励
    function self.action_sharerwd(request)
 		local uid = request.uid
        local response = self.response
        local ts = getClientTs()

        local uobjs = getUserObjs(uid)
        uobjs.load({"userinfo","props","bag",'useractive'})
        local mUseractive = uobjs.getModel('useractive')
        local mUserinfo = uobjs.getModel('userinfo')

        if ts>tonumber(mUseractive.getAcet(self.aname, true)) then
            response.ret = -102
            return response
        end

        local aid = mUserinfo.alliance
        if aid<=0 then
            response.ret = -8012
            return response
        end

        local activeCfg = mUseractive.getActiveConfig(self.aname)
        local mAllianceActive = getModelObjs("allianceactive",aid,false,true)
        local total = 0
        local cur = mUseractive.info[self.aname].pshare or 0
        if mAllianceActive then
            local activeObj = mAllianceActive.getActiveObj(self.aname)
            total = activeObj.activeInfo.share or 0
        else
            response.ret = -100
            return response
        end

        local num = self.getsharenum(cur,total,activeCfg.shareGetLimit,uid)
        if num <=0 then
            response.ret = -102
            return response
        end

        local reward = {}
        local actprop = {}
        local report = {}
        for i=1,num do
            local rd,rk = getRewardByPool(activeCfg.serverreward.p1,1)
            for k,v in pairs(rd) do
                 for rkey,rval in pairs(v) do
                    if table.contains(activeCfg.colorItem,rkey) then
                        actprop[rkey] = (actprop[rkey] or 0) + rval
                    else
                        reward[rkey]=(reward[rkey] or 0)+rval
                    end               
                end
            end
        end

        if next(reward) then
            if not takeReward(uid,reward) then
                response.ret = -403
                return response
            end

            for k,v in pairs(reward) do
                table.insert(report,formatReward({[k]=v}))
            end
        end

        if next(actprop) then
            for k,v in pairs(actprop) do
                mUseractive.info[self.aname][k] = (mUseractive.info[self.aname][k] or 0) + v
                table.insert(report,self.formatreward({[k]=v}))
            end
        end

        mUseractive.info[self.aname].pshare = (mUseractive.info[self.aname].pshare or 0) + num
        if uobjs.save() then
            processEventsAfterSave()
        	response.data[self.aname] = mUseractive.info[self.aname]
            response.data[self.aname].reward = report
            response.data[self.aname].getnum = num --领取的数量

            self.setsharenum(num,uid)--- 设置当日领取的数量

            response.data[self.aname].sharenum = self.getsharenum(mUseractive.info[self.aname].pshare,total,activeCfg.shareGetLimit,uid)
            response.data[self.aname].daynum = self.getdaynum(uid)
            response.ret = 0
            response.msg = 'Success'
        else
        	response.ret = -106
        end

        return response
    end

    -- 献花
    function self.action_sflowers(request)
        local uid = request.uid
        local response = self.response
        local ts = getClientTs()

        local uobjs = getUserObjs(uid)
        uobjs.load({"userinfo","props","bag",'useractive'})
        local mUseractive = uobjs.getModel('useractive')
        local mUserinfo = uobjs.getModel('userinfo')
        local aid = mUserinfo.alliance

        if ts>tonumber(mUseractive.getAcet(self.aname, true)) then
            response.ret = -102
            return response
        end

        local activeCfg = mUseractive.getActiveConfig(self.aname)
        local flowers = {0,0,0}-- 占位用 花朵道具下标 花朵对应积分下标是一致的
        local score = 0
        for k,v in pairs(activeCfg.colorItem) do
            mUseractive.info[self.aname].flowers[k] = (mUseractive.info[self.aname].flowers[k] or 0) + (mUseractive.info[self.aname][v] or 0)
            local fnum = math.floor(mUseractive.info[self.aname].flowers[k]/activeCfg.colorNeed[k])
            if fnum>0 then
                mUseractive.info[self.aname].flowers[k] = mUseractive.info[self.aname].flowers[k] - fnum*activeCfg.colorNeed[k]
                flowers[k] = fnum
                score = fnum*activeCfg.flowerScore[k]
            end
            mUseractive.info[self.aname][v] = 0
        end

        local report = {}
        local reward = {}
        local actprop = {}
        local flowerslog = {}

        local redis =getRedis()
        local redkey ="zid."..getZoneId()..self.aname..mUseractive.info[self.aname].st.."uid."..uid
        local fdata =redis:get(redkey)
        fdata =json.decode(fdata)
        if type (fdata)~="table" then fdata={}  end 
        for k,v in pairs(flowers) do
            if v>0 then
                for i=1,v do
                    local tmp = {}
                    local rd,rwk = getRewardByPool(activeCfg.serverreward['pool'..k],1)
                    for rk,rv in pairs(rd) do
                        for rkey,rval in pairs(rv) do   
                            reward[rkey]=(reward[rkey] or 0)+rval  
                            tmp[rkey] = (tmp[rkey] or 0) + rval        
                        end
                    end

                    local item = {}
                    for rk,rv in pairs(tmp) do
                        table.insert(item,formatReward({[rk]=rv}))
                    end

                    if aid>0 then
                        table.insert(item,self.formatreward({[activeCfg.scoreprop]=activeCfg.flowerScore[k]}))
                    end
                    
                    local rpt = {activeCfg.flowerItem[k],item,ts}
                    table.insert(report,{activeCfg.flowerItem[k],item})
                    table.insert(fdata,1,{activeCfg.flowerItem[k],item,ts})
                    if next(fdata) then
                        for i=#fdata,11,-1 do
                            table.remove(fdata)
                        end
                    end
                    
                end
            end
        end

        if aid>0 and score>0 then
            local mAllianceActive = getModelObjs("allianceactive",aid,false,true)
            if mAllianceActive then
                local params = {}
                local setRet,code=M_alliance.getalliance{aid=mUserinfo.alliance}

                if type(setRet['data'])=='table' and next(setRet['data']) then
                     params.anum = tonumber(setRet['data']['alliance']['num'])
                end
                
                params.allianceName=mUserinfo.alliancename
                params.score = score

                local activeObj = mAllianceActive.getActiveObj(self.aname)
                activeObj:addPoint(params)
            else
                writeLog({msg="jrhd addscore error",aid=aid,num=score})
            end
            
            mUseractive.info[self.aname].pscore = (mUseractive.info[self.aname].pscore or 0) + score
        end

        if next(reward) then
            if not takeReward(uid,reward) then
                response.ret = -403
                return response
            end
        end

        if uobjs.save() then
            processEventsAfterSave()
            response.data[self.aname] = mUseractive.info[self.aname]
            response.data[self.aname].reward = report 
           
            if next(fdata) then
                fdata=json.encode(fdata)
                redis:set(redkey,fdata)
                redis:expireat(redkey,mUseractive.info[self.aname].et+86400)     
            end
            
            response.ret = 0
            response.msg = 'Success'
        else
            response.ret = -106
        end

        return response
    end

     -- 获取记录
    function self.action_getReportLog(request)
        local response = self.response
        local uid = request.uid
   
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

    -- 排行榜列表
    function self.action_rankingList(request)
        local response = self.response
        local uid = request.uid
        local uobjs = getUserObjs(uid)
        local mUseractive = uobjs.getModel('useractive')
        local mUserinfo = uobjs.getModel('userinfo')

        local activeCfg = mUseractive.getActiveConfig(self.aname)
        local mAllianceActive = getModelObjs("allianceactive",mUserinfo.alliance,true)
        local activeObj = mAllianceActive.getActiveObj(self.aname) 

        response.data[self.aname] = {rankingList = activeObj:getRankingList()}
        response.data[self.aname].rt = activeObj.activeInfo.rt or 0 -- 军团已领取奖励次数
        response.data[self.aname].score = activeObj.activeInfo.score or 0 -- 当前积分 
        response.data[self.aname].rw =  mUseractive.info[self.aname].rw -- 玩家当前有没有领取排行榜奖励
        response.data[self.aname].alliancename = mUserinfo.alliancename

        response.ret = 0
        response.msg = 'Success'
        return response
    end

    -- 排行榜奖励
    function self.action_rankingReward(request)
        local response = self.response
        local uid = request.uid
        local ranking = request.params.ranking
        local zoneId = getZoneId()
        local ts = getClientTs()

        if not ranking then
            response.ret = -102
            return response
        end

        local uobjs = getUserObjs(uid)
        local mUseractive = uobjs.getModel('useractive')
        local activeCfg = mUseractive.getActiveConfig(self.aname)
        if ts < tonumber(mUseractive.getAcet(self.aname, true)) then
            response.ret = -102
            return response
        end

        local aid = uobjs.getModel('userinfo').alliance
        if aid <=0 then
            response.ret = -8012
            return response
        end

        if mUseractive.info[self.aname].rw ==  1 then
            response.ret = -1976
            return response
        end

        local mAllianceActive = getModelObjs("allianceactive",aid)
        local activeObj = mAllianceActive.getActiveObj(self.aname)

        local myRanking = nil
        local rankingList = activeObj:getRankingList()
        if type(rankingList) == "table" then
            for k,v in pairs(rankingList) do
                if v[1] == aid and k == ranking and v[4] >= activeCfg.rLimit then
                    myRanking = k
                    break
                end
            end
        end

        if not myRanking then
            response.ret = -1981
            return response
        end

        local matchid = 0
        for k,v in pairs(activeCfg.section) do
            if myRanking >= v[1] and myRanking <= v[2] then
                matchid = k
                break
            end
        end

        if matchid==0 then
            response.ret = -102
            return response
        end
        -- 军团领取次数+1
        activeObj.activeInfo.rt = (activeObj.activeInfo.rt or 0) + 1
        local reward = {}
        -- 领取次数达到上限
        if activeObj.activeInfo.rt > activeCfg.rGetLimit then 
            response.ret = -29012
            return response 
        else
            reward = copyTable(activeCfg.serverreward.rankList[matchid].r)
        end
        
        if not next(reward) then
            response.ret = -120
            response.err = "reward is nil"
            return response
        end

        -- 领奖
        if not takeReward(uid, reward) then
            response.ret = -1989
            return response
        end

        local report = {}
        for k,v in pairs(reward) do
            table.insert(report,formatReward({[k]=v}))
        end

        mUseractive.info[self.aname].rw =  1
        regEventAfterSave(aid,'saveAllianceActive')
        if uobjs.save() then
            processEventsAfterSave()
            response.data[self.aname] = mUseractive.info[self.aname]
            response.data[self.aname].reward = report
            response.ret = 0
            response.msg = 'Success'
        end

        return response
    end

    return self
end

return api_active_jrhd
