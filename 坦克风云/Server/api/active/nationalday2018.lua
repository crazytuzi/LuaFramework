--
-- desc: 国庆节2018
-- user: chenyunhe
--
local function api_active_nationalday2018(request)
    local self = {
        response = {
            ret = -1,
            msg ='error',
            data = {},
        },
        aname = 'nationalday2018',
    }

    function self.formatreward(rewards)
        local formatreward = {}
        local key = 'nd'
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

        -- 活动道具
        for _,v in pairs(activeCfg.itemNeed) do
            if not mUseractive.info[self.aname][v] then
                mUseractive.info[self.aname][v] = 0
                flag = true
            end
        end

        -- 任务
        if type(mUseractive.info[self.aname].tk)~='table' then
            flag = true
            mUseractive.info[self.aname].tk = {}
            for k,v in pairs(activeCfg.serverreward.taskList) do
                mUseractive.info[self.aname].tk['d'..k] = {{},0,0}-- 当天的任务数据  进度奖励领取状态 进度
                for tk,tv in pairs(v) do
                     table.insert(mUseractive.info[self.aname].tk['d'..k][1],{0,0,0}) --当前进度 可领取 已领取
                end
            end
        end

        -- 个人功勋奖励领取记录
        if type(mUseractive.info[self.aname].gx)~='table' then
            flag = true
            mUseractive.info[self.aname].gx = {}
            for k,v in pairs(activeCfg.serverreward.stepList) do
                table.insert(mUseractive.info[self.aname].gx,0)
            end
        end

        -- 军团祝福奖励
        if type(mUseractive.info[self.aname].zf)~='table' then
            flag = true
            mUseractive.info[self.aname].zf = {}
            for k,v in pairs(activeCfg.serverreward.groupList) do
                table.insert(mUseractive.info[self.aname].zf,0)
            end
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
        response.data[self.aname].score = 0 -- 军团祝福值
        if mUserinfo.alliance>0 then
            local mAllianceActive = getModelObjs("allianceactive",mUserinfo.alliance,true)
            local activeObj = mAllianceActive.getActiveObj(self.aname) 
            response.data[self.aname].score = activeObj.activeInfo.score or 0 -- 祝福值
        end
        response.ret = 0
        response.msg = 'Success'

        return response
    end

    -- 领取功勋奖励
    function self.action_gxreward(request)
 		local uid = request.uid
        local response = self.response
        local index = request.params.i -- 奖励下标
        local ts = getClientTs()
        
        if not index then
            response.ret = -102
            return response
        end

        local uobjs = getUserObjs(uid)
        uobjs.load({"userinfo","props","bag",'useractive'})
        local mUseractive = uobjs.getModel('useractive')
        local mUserinfo = uobjs.getModel('userinfo')

        local activeCfg = mUseractive.getActiveConfig(self.aname)
        local itemcfg = activeCfg.serverreward.stepList[index]
        if not itemcfg then
            response.ret = -120
            return response
        end

        if (mUseractive.info[self.aname].nd_a1 or 0)<itemcfg.num then
            response.ret = -102
            return response
        end

        if mUseractive.info[self.aname].gx[index]==1 then
            response.ret = -1976
            return response
        end   

        if type(itemcfg.r)~='table' then
            response.ret = -120
            return response
        end
        
        local report = {}
        if not takeReward(uid,itemcfg.r) then
        	response.ret = -403
        	return response
        end

        for k,v in pairs(itemcfg.r) do
            table.insert(report,formatReward({[k]=v}))
        end

        mUseractive.info[self.aname].gx[index] = 1
        if uobjs.save() then
            processEventsAfterSave()
        	response.data[self.aname] = mUseractive.info[self.aname]
            response.data[self.aname].reward = report

            response.ret = 0
            response.msg = 'Success'
        else
        	response.ret = -106
        end

        return response
    end

    -- 每日任务进度奖励
    function self.action_jdreward(request)
        local uid = request.uid
        local response = self.response
        local day = request.params.d -- 第几天
        local ts = getClientTs()
        
        if not day then
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

        local currDay = math.floor(math.abs(ts-getWeeTs(mUseractive.info[self.aname].st))/(24*3600)) + 1
        if day>currDay then
            response.ret = -102
            return response
        end

        local activeCfg = mUseractive.getActiveConfig(self.aname)
        local itemcfg = activeCfg.serverreward.rateList[day]
        if not itemcfg then
            response.ret = -120
            return response
        end

        if mUseractive.info[self.aname].tk['d'..day][2]==1 then
            response.ret = -1976
            return response
        end

        if mUseractive.info[self.aname].tk['d'..day][3]<itemcfg.num then
            response.ret = -102
            return response
        end   

        if type(itemcfg.r)~='table' then
            response.ret = -120
            return response
        end

        local report = {}
        local reward = {}
        local nd_a1 = 0
        local nd_a2 = 0
        for k,v in pairs(itemcfg.r) do
            if k=="nd_a1" then
                nd_a1 = nd_a1 + v
            elseif k=="nd_a2" then
                nd_a2 = nd_a2 + v
            else
                reward[k] = (reward[k] or 0) + v
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

        if nd_a1>0 then
            mUseractive.info[self.aname].nd_a1 = (mUseractive.info[self.aname].nd_a1 or 0) + nd_a1
            table.insert(report,self.formatreward({nd_a1=nd_a1}))
        end

        local aid = mUserinfo.alliance
        local score = 0
        if nd_a2>0 and aid>0 then
            mUseractive.info[self.aname].nd_a2 = (mUseractive.info[self.aname].nd_a2 or 0) + nd_a2
            table.insert(report,self.formatreward({nd_a2=nd_a2}))

            -- 更新军团祝福值
            local aAllianceActive = getModelObjs("allianceactive",aid)
            if not aAllianceActive then
                response.ret = -100
                return response
            end

            local activeObj = aAllianceActive.getActiveObj(self.aname) 
            local setRet,code=M_alliance.getDetails{aid=aid}
            if type(setRet.data)~='table' or not next(setRet.data) then
                response.ret = -8017
                return response
            end

            local params = {}    
            params.allianceName=mUserinfo.alliancename
            params.score = nd_a2
            params.logo = setRet.data.logo
            activeObj:addPoint(params)  
            score = activeObj.activeInfo.score or 0
        end

        mUseractive.info[self.aname].tk['d'..day][2] = 1
        if uobjs.save() then
            processEventsAfterSave()
            response.data[self.aname] = mUseractive.info[self.aname]
            response.data[self.aname].reward = report
            response.data[self.aname].score = score -- 军团祝福值 

            response.ret = 0
            response.msg = 'Success'
        else
            response.ret = -106
        end

        return response
    end

    -- 任务奖励
    function self.action_treward(request)
        local uid = request.uid
        local response = self.response
        local day = request.params.d -- 第几天
        local tid = request.params.tid -- 任务下标
        local ts = getClientTs()
        
        if not day or not tid then
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

        local currDay = math.floor(math.abs(ts-getWeeTs(mUseractive.info[self.aname].st))/(24*3600)) + 1
        if day>currDay then
            response.ret = -102
            return response
        end

        local activeCfg = mUseractive.getActiveConfig(self.aname)
        local itemcfg = activeCfg.serverreward.taskList[day][tid]
        if not itemcfg then
            response.ret = -120
            return response
        end

        local num = mUseractive.info[self.aname].tk['d'..day][1][tid][2] or 0
        local gems = 0
        -- 购买礼包任务
        if itemcfg.type=='hf' then
            if day~=currDay then
                response.ret = -102
                return response
            end

            gems = itemcfg.num
            if not mUserinfo.useGem(itemcfg.num) then
                response.ret = -109
                return response
            end

            num = 1
            if mUseractive.info[self.aname].tk['d'..day][1][tid][3] == 0 then
                mUseractive.info[self.aname].tk['d'..day][3] = mUseractive.info[self.aname].tk['d'..day][3] + 1
            end
        end

        if num<=0 then
            response.ret = -102
            return response
        end

        if mUseractive.info[self.aname].tk['d'..day][1][tid][3]>=itemcfg.limit then
            response.ret = -121
            return response
        end   

        if type(itemcfg.r)~='table' then
            response.ret = -120
            return response
        end

        local report = {}
        local reward = {}
        
        local nd_a1 = 0
        local nd_a2 = 0
        for k,v in pairs(itemcfg.r) do
            if k=="nd_a1" then
                nd_a1 = nd_a1 + v*num
            elseif k=="nd_a2" then
                nd_a2 = nd_a2 + v*num
            else
                reward[k] = (reward[k] or 0) + v*num
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

        if nd_a1>0 then
            mUseractive.info[self.aname].nd_a1 = (mUseractive.info[self.aname].nd_a1 or 0) + nd_a1
            table.insert(report,self.formatreward({nd_a1=nd_a1}))
        end

        local aid = mUserinfo.alliance
        local score = 0
        if nd_a2>0 and aid>0 then
            mUseractive.info[self.aname].nd_a2 = (mUseractive.info[self.aname].nd_a2 or 0) + nd_a2
            table.insert(report,self.formatreward({nd_a2=nd_a2}))
            -- 更新军团祝福值
            local aAllianceActive = getModelObjs("allianceactive",aid)
            if not aAllianceActive then
                response.ret = -100
                return response
            end

            local activeObj = aAllianceActive.getActiveObj(self.aname) 
            local setRet,code=M_alliance.getDetails{aid=aid}
            if type(setRet.data)~='table' or not next(setRet.data) then
                response.ret = -8017
                return response
            end

            local params = {}    
            params.allianceName=mUserinfo.alliancename
            params.score = nd_a2
            params.logo = setRet.data.logo
            activeObj:addPoint(params)  
            score = activeObj.activeInfo.score or 0
        end

        mUseractive.info[self.aname].tk['d'..day][1][tid][3] = (mUseractive.info[self.aname].tk['d'..day][1][tid][3] or 0) + num
        mUseractive.info[self.aname].tk['d'..day][1][tid][2] = 0

        if gems>0 then
             regActionLogs(uid,1,{action = 267, item = "", value = gems, params = {day=day}})
        end

        if uobjs.save() then
            processEventsAfterSave()
            response.data[self.aname] = mUseractive.info[self.aname]
            response.data[self.aname].reward = report
            response.data[self.aname].score = score -- 军团祝福值 

            response.ret = 0
            response.msg = 'Success'
        else
            response.ret = -106
        end

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
        response.data[self.aname].score = activeObj.activeInfo.score or 0 -- 祝福值 
        response.data[self.aname].score1 = activeObj.activeInfo.score1 or 0 -- 历史祝福值 
     

        response.data[self.aname].rw =  mUseractive.info[self.aname].rw -- 玩家当前有没有领取排行榜奖励
        response.data[self.aname].nd_a2 =  mUseractive.info[self.aname].nd_a2 or 0 -- 玩家的祝福值

        if type(activeObj.activeInfo.gift)~='table' then
            activeObj.activeInfo.gift = {}
            for k,v in pairs(activeCfg.serverreward.groupList) do
                table.insert(activeObj.activeInfo.gift,0)
            end
        end
        response.data[self.aname].gift = activeObj.activeInfo.gift
        response.data[self.aname].alliancename = mUserinfo.alliancename

        response.ret = 0
        response.msg = 'Success'
        return response
    end

    -- 排行榜奖励(跨服军团排行榜)
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
                if v[1] == zoneId and v[2] == aid and k == ranking and v[3] >= activeCfg.rLimit then
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
            reward = copyTable(activeCfg.serverreward.giftList[matchid].r)
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

    -- 领取军团祝福值奖励
    function self.action_zfreward(request)
         local response = self.response
        local uid = request.uid
        local index = request.params.i
        local zoneId = getZoneId()
        local ts = getClientTs()

        if not index then
            response.ret = -102
            return response
        end

        local uobjs = getUserObjs(uid)
        local mUseractive = uobjs.getModel('useractive')
        local activeCfg = mUseractive.getActiveConfig(self.aname)

        local aid = uobjs.getModel('userinfo').alliance
        if aid <=0 then
            response.ret = -8012
            return response
        end

        local itemcfg = activeCfg.serverreward.groupList[index]
        if type(itemcfg)~='table' then
            response.ret = -120
            return response
        end

        if mUseractive.info[self.aname].zf[index] == 1 then
            response.ret = -1976
            return response
        end

        local mAllianceActive = getModelObjs("allianceactive",aid)
        local activeObj = mAllianceActive.getActiveObj(self.aname)

        if (activeObj.activeInfo.score1 or 0)<itemcfg.num then
            response.ret = -29011
            return response
        end

        if type(activeObj.activeInfo.gift)~='table' then
            activeObj.activeInfo.gift = {}
            for k,v in pairs(activeCfg.serverreward.groupList) do
                table.insert(activeObj.activeInfo.gift,0)
            end
        end

        activeObj.activeInfo.gift[index] = activeObj.activeInfo.gift[index] + 1
        local reward = {}
        -- 领取次数达到上限
        if activeObj.activeInfo.gift[index] > activeCfg.rGetLimit then 
            response.ret = -29012
            return response 
        else
            reward = copyTable(itemcfg.r)
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

        mUseractive.info[self.aname].zf[index] =  1
        regEventAfterSave(aid,'saveAllianceActive')
        if uobjs.save() then
            processEventsAfterSave()
            response.data[self.aname] = mUseractive.info[self.aname]
            response.data[self.aname].reward = report
            response.data[self.aname].score = activeObj.activeInfo.score or 0 -- 祝福值 
            response.data[self.aname].score1 = activeObj.activeInfo.score1 or 0 -- 祝福值 
            response.ret = 0
            response.msg = 'Success'
        end

        return response
    end

    return self
end

return api_active_nationalday2018
