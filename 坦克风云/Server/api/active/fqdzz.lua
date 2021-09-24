--
-- desc: 番茄大作战
-- user: chenyunhe
--
local function api_active_fqdzz(request)
    local self = {
        response = {
            ret = -1,
            msg ='error',
            data = {},
        },
        aname = 'fqdzz',
    }

    function self.formatreward(rewards)
        local formatreward = {}
        local key = 'fqdzz'
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

    -- 刷新 初始化
    function self.action_refresh(request)
        local response = self.response
        local uid=request.uid
        local weeTs = getWeeTs()

        local uobjs = getUserObjs(uid)
        uobjs.load({"userinfo",'useractive'})
        local mUseractive = uobjs.getModel('useractive')
        local mUserinfo = uobjs.getModel('userinfo')
        local activeCfg = mUseractive.getActiveConfig(self.aname)
        local flag = false  

        local aid = mUserinfo.alliance
        if aid<=0 then
            response.ret = -4005
            return response
        end

        -- 任务
        if not mUseractive.info[self.aname].tk then
            mUseractive.info[self.aname].tk = {}
            for k,v in pairs(activeCfg.serverreward.taskList) do
                table.insert(mUseractive.info[self.aname].tk,{0,0,0})-- 可领取次数 已领取次数 当前值
            end
            flag = true
        end

        if mUseractive.info[self.aname].t ~= weeTs then
            mUseractive.info[self.aname].t = weeTs
            for k,v in pairs(activeCfg.serverreward.taskList) do
                if v.refresh==1 then
                    mUseractive.info[self.aname].tk[k] = {0,0,0} -- 可领取次数 已领取次数 当前值
                end
            end
            flag = true
        end

        -- 有没有领取排行榜奖励
        if not mUseractive.info[self.aname].r then
            flag = true
            mUseractive.info[self.aname].r = 0
        end

        -- 军团历史积分 领取奖励记录
        if not mUseractive.info[self.aname].ar then
            mUseractive.info[self.aname].ar = {}
            for k,v in pairs(activeCfg.serverreward.giftList) do
                table.insert(mUseractive.info[self.aname].ar,0)
            end
            flag = true
        end

        -- 玩家领取军团奖励记录
        if not mUseractive.info[self.aname].ur then
            mUseractive.info[self.aname].ur = {}
            flag = true
        end

        -- 玩家番茄数量
        if not mUseractive.info[self.aname].fqdzz_a1 then
            mUseractive.info[self.aname].fqdzz_a1 = 0
            flag = true
        end

        if flag then
            if not uobjs.save() then
                response.ret = -106
                return response
            end
        end
        
        response.data[self.aname] = mUseractive.info[self.aname]
        response.data[self.aname].tomato = 0
        local aAllianceActive = getModelObjs("allianceactive",aid)
        if aAllianceActive then
            local activeObj = aAllianceActive.getActiveObj(self.aname)
            local ar = activeObj.activeInfo.reward or {}
            response.data[self.aname].tomato = self.tomato(ar,mUseractive.info[self.aname].ur,activeCfg.serverreward.treward)
        end
       
        response.ret = 0
        response.msg = 'Success'

        return response
    end
    
    -- 领取任务奖励
    function self.action_treward(request)
        local uid = request.uid
        local response = self.response
        local index = request.params.i --任务下标
        local weeTs = getWeeTs()
        local ts = getClientTs()
        local uobjs = getUserObjs(uid)
        uobjs.load({"userinfo",'useractive'})
        local mUseractive = uobjs.getModel('useractive')
        local mUserinfo = uobjs.getModel('userinfo')

        if mUserinfo.alliance==0 then
            response.ret = -4005
            return response
        end

        local aid = mUserinfo.alliance
        local activeCfg = mUseractive.getActiveConfig(self.aname)
        local tkcfg = activeCfg.serverreward.taskList[index]
        if type(tkcfg)~='table' then
            response.ret = -102
            return response
        end

        -- 每日刷新的任务
        if tkcfg.refresh==1 then
            if mUseractive.info[self.aname].t ~= weeTs then
                mUseractive.info[self.aname].tk[index] = {0,0,0}
                mUseractive.info[self.aname].t = weeTs
            end
        end

        local rnum = mUseractive.info[self.aname].tk[index][1] or 0
        if rnum<=0 then
            response.ret = -102
            return response
        end
 
        if tkcfg.limit>0 then
            if mUseractive.info[self.aname].tk[index][2]>=tkcfg.limit then
                response.ret = -121
                return response
            end

            local left = tkcfg.limit - mUseractive.info[self.aname].tk[index][2]
            if rnum>left then
                rnum = left
            end
        end

        local reward = {} -- 个人奖励
        local areward = {} -- 军团奖励
        local report = {} -- 客户端用的
        local score = 0 -- 获得积分
        local fqdzz_a1 = 0 -- 获得番茄
        -- 个人
        if tkcfg.rewardType==1 or tkcfg.rewardType==3 then
            for k,v in pairs(tkcfg.r) do
                if string.find(k,"fqdzz_a1") then
                    fqdzz_a1 = v*rnum
                else
                    reward[k] = v*rnum
                end   
            end
        end
        -- 军团
        if tkcfg.rewardType==2 or tkcfg.rewardType==3 then
            areward[tkcfg.tr] = rnum
        end
        local share =  {}
        if next(areward) then
            local toma = 0
            for k,v in pairs(areward) do
                for rk,rv in pairs(activeCfg.serverreward.treward[k]) do
                    if string.find(rk,'fqdzz_a1') then
                        toma = toma + rv*v
                    else
                        table.insert(share,formatReward({[rk]=rv*v}))
                    end
                end
            end

            if toma>0 then
                table.insert(share,self.formatreward({['fqdzz_a1']=toma}))
            end 
        end

        if next(reward) then
            if not takeReward(uid,reward) then
                response.ret = -102
                return response
            end

            for k,v in pairs(reward) do
                table.insert(report,formatReward({[k]=v}))
            end
        end

        score = tkcfg.score*rnum

        local aAllianceActive = getModelObjs("allianceactive",aid)
        if not aAllianceActive then
            response.ret = -100
            return response
        end
        local activeObj = aAllianceActive.getActiveObj(self.aname)
        if score>0 or next(areward) and ts < tonumber(mUseractive.getAcet(self.aname, true)) then
            local setRet,code=M_alliance.getDetails{aid=aid}
            if type(setRet.data)~='table' or not next(setRet.data) then
                response.ret = -8017
                return response
            end
        
            local params = {}
            params.score = score
            params.reward = areward or {}
            params.logo = setRet.data.logo
            params.allianceName = mUserinfo.alliancename
            activeObj:addPoint(params)
        end  

        if fqdzz_a1>0 then
            table.insert(report,self.formatreward({['fqdzz_a1']=fqdzz_a1}))
            mUseractive.info[self.aname].fqdzz_a1 =  (mUseractive.info[self.aname].fqdzz_a1 or 0) + fqdzz_a1

            local params = {}
            params.fqdzz_a1 = fqdzz_a1
            activeObj:addfq(params)
        end

        mUseractive.info[self.aname].tk[index][2] = mUseractive.info[self.aname].tk[index][2] + mUseractive.info[self.aname].tk[index][1]
        mUseractive.info[self.aname].tk[index][1] = 0
       
        if uobjs.save() then
            processEventsAfterSave()
            local ar = activeObj.activeInfo.reward or {}
            local ur = mUseractive.info[self.aname].ur or {}
            response.data[self.aname] =mUseractive.info[self.aname]
            response.data[self.aname].reward = report
            response.data[self.aname].tomato = self.tomato(ar,ur,activeCfg.serverreward.treward)
            response.ret = 0
            response.msg = 'Success'

            if next(share) and ts < tonumber(mUseractive.getAcet(self.aname, true)) then
                local redis =getRedis()
                local redkey ="zid."..getZoneId()..self.aname..mUseractive.info[self.aname].st.."aid."..aid
                local data =redis:get(redkey)
                data =json.decode(data)
                if type (data)~="table" then data={}  end
                
                table.insert(data,1,{ts,mUserinfo.nickname,share})
                if next(data) then
                    for i=#data,51,-1 do
                        table.remove(data)
                    end

                    data=json.encode(data)
                    redis:set(redkey,data)
                    redis:expireat(redkey,mUseractive.info[self.aname].et+86400)
                end    
            end 
        else
            response.ret=-106
        end

        return response
    end

    -- 获取军团奖励详情 50条
    function self.action_getdetails(request)
        local response = self.response
        local uid = request.uid
        local uobjs = getUserObjs(uid)
        uobjs.load({"userinfo",'useractive'})
        local mUseractive = uobjs.getModel('useractive')
        local mUserinfo = uobjs.getModel('userinfo')
        local aid = mUserinfo.alliance

        response.data.report= {}
        response.data.tomato= 0
        if aid<=0 then
            response.ret = 0
            response.msg = 'Success'
            return response
        end
         local activeCfg = mUseractive.getActiveConfig(self.aname)

        local aAllianceActive = getModelObjs("allianceactive",aid)
        if not aAllianceActive then
            response.ret = -100
            return response
        end
        local activeObj = aAllianceActive.getActiveObj(self.aname)

        local redis =getRedis()
        local redkey ="zid."..getZoneId()..self.aname..mUseractive.info[self.aname].st.."aid."..aid
        local data =redis:get(redkey)
        data =json.decode(data)

        if type(data) ~= 'table' then data = {} end
        local ar = activeObj.activeInfo.reward or {}
        local ur = mUseractive.info[self.aname].ur or {}

        response.data.tomato = self.tomato(ar,ur,activeCfg.serverreward.treward)
        response.ret = 0
        response.msg = 'Success'
        response.data.report=data

        return response
    end

    -- 可以领取番茄的数量
    function self.tomato(areward,ureward,cfg)
        local num  = 0
        if type(areward)=='table' and next(areward) then
            for k,v in pairs(areward) do
                local left = v - (ureward[k] or 0)
                if left>0 then
                    if cfg[k] then
                        num = num + (cfg[k].fqdzz_a1 or 0)*left
                    end
                end
            end
        end

        return num
    end

    -- 领取宝箱奖励
    function self.action_areward(request)
        local uid = request.uid
        local response = self.response
        local ts =  getClientTs()
        local uobjs = getUserObjs(uid)
        uobjs.load({"userinfo",'useractive'})
        local mUseractive = uobjs.getModel('useractive')
        local mUserinfo = uobjs.getModel('userinfo')

        local activeCfg = mUseractive.getActiveConfig(self.aname)
        local aid = mUserinfo.alliance
        if aid<=0 then
            response.ret = -8012
            return response
        end

        if ts > tonumber(mUseractive.getAcet(self.aname, true)) then
            response.ret = -1989
            return response
        end

        local aAllianceActive = getModelObjs("allianceactive",aid)
        if not aAllianceActive then
            response.ret = -100
            return response
        end
        local activeObj = aAllianceActive.getActiveObj(self.aname)
        local ar = activeObj.activeInfo.reward or {}
        local ur = mUseractive.info[self.aname].ur or {}

        -- 可领取的军团奖励
        local r = {}
        if type(ar)=='table' and next(ar) then
            for k,v in pairs(ar) do
                local left = v - (ur[k] or 0)
                if left>0 then
                    r[k] = left
                end
            end
        end
    
        if not next(r) then
            response.ret = -102
            return response
        end

        local report = {}
        local reward = {}
        local fqdzz_a1 = 0

        for k,v in pairs(r) do
            local rewardcfg = activeCfg.serverreward.treward[k]
            if not rewardcfg then
                response.ret = -102
                return response
            end

            for re,rv in pairs(rewardcfg) do
                if string.find(re,"fqdzz_a1") then
                    fqdzz_a1 = fqdzz_a1 + rv*v
                else
                    reward[re] = (reward[re] or 0) + rv * v
                end
            end
            mUseractive.info[self.aname].ur[k] = (mUseractive.info[self.aname].ur[k] or  0) + v          
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

        if fqdzz_a1>0 then
            table.insert(report,self.formatreward({['fqdzz_a1']=fqdzz_a1}))
            mUseractive.info[self.aname].fqdzz_a1 =  (mUseractive.info[self.aname].fqdzz_a1 or 0) + fqdzz_a1

            local params = {}
            params.fqdzz_a1 = fqdzz_a1
            activeObj:addfq(params)
        end


        if uobjs.save() then
            processEventsAfterSave()
            response.data[self.aname] = mUseractive.info[self.aname]
            response.data[self.aname].reward = report

            response.ret = 0
            response.msg = 'Success'
        else
            response.ret=-106
        end

        return response
    end


    -- 页签二
    function self.action_refresh2(request)
        local response = self.response
        local uid=request.uid
        local weeTs = getWeeTs()

        local uobjs = getUserObjs(uid)
        uobjs.load({"userinfo",'useractive'})
        local mUseractive = uobjs.getModel('useractive')
        local mUserinfo = uobjs.getModel('userinfo')
        local aid = mUserinfo.alliance
        if aid<=0 then
            response.ret = -8012
            return response
        end
        local activeCfg = mUseractive.getActiveConfig(self.aname)
        
        local aAllianceActive = getModelObjs("allianceactive",mUserinfo.alliance)
        if not aAllianceActive then
            response.ret = -100
            return response
        end

        local flag = false
        if not mUseractive.info[self.aname].ar then
            mUseractive.info[self.aname].ar = {}
            for k,v in pairs(activeCfg.serverreward.giftList) do
                table.insert(mUseractive.info[self.aname].ar,0)
            end
            flag = true
        end


        if flag then
            uobjs.save()
        end
        local activeObj = aAllianceActive.getActiveObj(self.aname) 

        if type(activeObj.activeInfo.sr)~='table' then
            activeObj.activeInfo.sr = {}
            for k,v in pairs(activeCfg.serverreward.giftList) do
                table.insert(activeObj.activeInfo.sr,0)
            end

            regEventAfterSave(aid,'saveAllianceActive')
            processEventsAfterSave()
        end

        response.data[self.aname] = mUseractive.info[self.aname]
        response.data[self.aname].tfqdzz_a1 =  activeObj.activeInfo.fqdzz_a1 or 0
        response.data[self.aname].alliance = activeObj:gettargets()

        local redis =getRedis()
        local redkey ="zid."..getZoneId()..self.aname..mUseractive.info[self.aname].st..".throw."..aid
        local throwdata =redis:get(redkey)
        throwdata =json.decode(throwdata)
        if type (throwdata)~="table" then throwdata={}  end
        response.data[self.aname].thrownum = #throwdata -- 当前军团已经扔番茄的玩家数
        response.data[self.aname].scoreflag = self.checkthrow(throwdata,uid,activeCfg.partnerLimit) and 1 or 0 -- 扔番茄能否获得积分
        response.data[self.aname].sr = activeObj.activeInfo.sr -- 领取军团奖励次数
        
        response.ret = 0
        response.msg = 'Success'
     
        return response
    end

    function self.checkthrow(throwlog,uid,limit)

        if #throwlog<limit then
            return true
        else
            if table.contains(throwlog,uid) then
                return true
            else
                return false
            end
        end
    end


    -- 领取积分奖励
    function self.action_sreward(request)
        local uid = request.uid
        local response = self.response
        local ts =  getClientTs()
        local i = request.params.i --奖励下标
        local uobjs = getUserObjs(uid)
        uobjs.load({"userinfo",'useractive'})
        local mUseractive = uobjs.getModel('useractive')
        local mUserinfo = uobjs.getModel('userinfo')

        local activeCfg = mUseractive.getActiveConfig(self.aname)
        local aid = mUserinfo.alliance
        if aid<=0 then
            response.ret = -8012
            return response
        end

        if ts > tonumber(mUseractive.getAcet(self.aname, true)) then
            response.ret = -1989
            return response
        end


        local aAllianceActive = getModelObjs("allianceactive",aid)
        if not aAllianceActive then
            response.ret = -100
            return response
        end
        local activeObj = aAllianceActive.getActiveObj(self.aname)
        local tscore = activeObj.activeInfo.fqdzz_a1 or 0 

        activeObj.activeInfo.sr[i] = (activeObj.activeInfo.sr[i] or 0) + 1
        -- 领取次数达到上限
        if activeObj.activeInfo.sr[i] > activeCfg.rGetLimit then
            response.ret = -1993
            return response
        end

        if mUseractive.info[self.aname].ar[i]==1 then
            response.ret = -1976
            return response
        end

        local gcfg = activeCfg.serverreward.giftList[i]
        if type(gcfg)~='table' then
            response.ret = -120
            return response
        end

        if gcfg.scoreNeed>tscore then
            response.ret = -107
            return response
        end

        local report = {}
        local reward = {}
        local fqdzz_a1 = 0
        for k,v in pairs(gcfg.r) do
            if string.find(k,"fqdzz_a1") then
                fqdzz_a1 = fqdzz_a1 + v
            else
                reward[k] = v
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

        if fqdzz_a1>0 then
            table.insert(report,self.formatreward({['fqdzz_a1']=fqdzz_a1}))
            mUseractive.info[self.aname].fqdzz_a1 =  (mUseractive.info[self.aname].fqdzz_a1 or 0) + fqdzz_a1
            local params = {}
            params.fqdzz_a1 = fqdzz_a1
            activeObj:addfq(params)
        end

        local score = gcfg.score or 0
        if score>0 and ts < tonumber(mUseractive.getAcet(self.aname, true)) then

            local setRet,code=M_alliance.getDetails{aid=aid}
            if type(setRet.data)~='table' or not next(setRet.data) then
                response.ret = -8017
                return response
            end
            local params = {}
            params.logo = setRet.data.logo    
            params.score = score
            params.allianceName = mUserinfo.alliancename
            activeObj:addPoint(params)
        end  

        mUseractive.info[self.aname].ar[i] = 1
        regEventAfterSave(aid,'saveAllianceActive')
        if uobjs.save() then
            processEventsAfterSave()
            response.data[self.aname] = mUseractive.info[self.aname]
            response.data[self.aname].reward = report

            response.ret = 0
            response.msg = 'Success'
        else
            response.ret=-106
        end

        return response
    end
   
    -- 扔番茄
    function self.action_throw(request)
        local uid = request.uid
        local response = self.response
        local zid = getZoneId()
        local target = request.params.aid -- 被扔军团
        local tzid = request.params.zid -- 被扔军团所在服
        local act = request.params.act  -- false普通 true强力一击
        local index = request.params.i  --  1,2,3
        if not table.contains({1,2,3},index) or not target or not tzid then
            response.ret = -102
            return response
        end

        local ts =  getClientTs()
        local uobjs = getUserObjs(uid)
        uobjs.load({"userinfo",'useractive'})
        local mUseractive = uobjs.getModel('useractive')
        local mUserinfo = uobjs.getModel('userinfo')

        local activeCfg = mUseractive.getActiveConfig(self.aname)
        local aid = mUserinfo.alliance
        if aid<=0 then
            response.ret = -8012
            return response
        end


        if target==aid and zid==tzid then
            response.ret = -102
            return response
        end

        if ts > tonumber(mUseractive.getAcet(self.aname, true)) then
            response.ret = -1989
            return response
        end

        local aAllianceActive = getModelObjs("allianceactive",aid)
        if not aAllianceActive then
            response.ret = -100
            return response
        end

        local activeObj = aAllianceActive.getActiveObj(self.aname)
        local afqdzz_a1 = activeObj.activeInfo.fqdzz_a1 or 0
       
        if afqdzz_a1<activeCfg.rLimit then
            response.ret = -107
            return response
        end

        local costfq = activeCfg.throwNum[index]
        if not costfq then
            response.ret = -102
            return response
        end

        if mUseractive.info[self.aname].fqdzz_a1<costfq then
            response.ret = -107
            return response
        end

        local gems = 0
        local score = activeCfg.scoreUp*costfq
        local descore = activeCfg.scoreDown*costfq

        if act then
            gems = activeCfg.critCost*costfq
            if not mUserinfo.useGem(gems) then
                response.ret = -109
                return response
            end

            score = math.ceil(activeCfg.scoreUp*(1+activeCfg.critRate)*costfq)
            descore = math.ceil(activeCfg.scoreDown*(1+activeCfg.critRate)*costfq)
        end

        local redis =getRedis()
        local redkey ="zid."..getZoneId()..self.aname..mUseractive.info[self.aname].st..".throw."..aid
        local throwdata =redis:get(redkey)
        throwdata =json.decode(throwdata)
        if type (throwdata)~="table" then throwdata={}  end

        if self.checkthrow(throwdata,uid,activeCfg.partnerLimit) then
            local setRet,code=M_alliance.getDetails{aid=aid}
            if type(setRet.data)~='table' or not next(setRet.data) then
                response.ret = -8017
                return response
            end
            local params = {}
            params.score = score
            params.allianceName = mUserinfo.alliancename
            params.logo = setRet.data.logo 
            local ret,res = activeObj:addPoint(params)
            
            if res.ret~=0 then
                response.ret = ret 
                return response
            end
        else
            score = 0
        end

        local reward = {}
        for i=1,costfq do
            local result,rewardkey = getRewardByPool(activeCfg.serverreward.pool1,1)      
            for k,v in pairs (result) do
                for rk,rv in pairs(v) do
                    reward[rk]=(reward[rk] or 0)+rv
                end
            end  
        end

        if not takeReward(uid,reward) then
            response.ret = -403
            return response
        end

        mUseractive.info[self.aname].fqdzz_a1 = mUseractive.info[self.aname].fqdzz_a1 - costfq
        if gems>0 then
            regActionLogs(uid,1,{action = 256, item = "", value = gems, params = {num = costfq}})
        end
        if uobjs.save() then
            processEventsAfterSave()
            local senddata={
                zid=tzid,
                aid = target,
                acname=self.aname,
                st = mUseractive.info[self.aname].st,
                score = descore,
            }
    
            local r = require("lib.crossActivity").subaPoint(senddata)
            response.data[self.aname] = mUseractive.info[self.aname]
            response.data[self.aname].getscore = score
            response.data[self.aname].reward = formatReward(reward)
            response.data[self.aname].alliance = activeObj:gettargets()
            response.ret = 0
            response.msg = 'Success'

            
            if #throwdata<activeCfg.partnerLimit and not table.contains(throwdata,uid) then
                table.insert(throwdata,uid)

                throwdata=json.encode(throwdata)
                redis:set(redkey,throwdata)
                redis:expireat(redkey,mUseractive.info[self.aname].et+86400)
            end
        else
            response.ret=-106
        end

        return response
    end

    -- 排行榜列表
    function self.action_rankingList(request)
        local response = self.response
        local uid = request.uid
        local aid = request.params.aid or 0
        local zid = getZoneId()
        local ts = getClientTs()
    
        local uobjs = getUserObjs(uid)
        uobjs.load({'useractive'})
        local mUseractive = uobjs.getModel('useractive')
        local mAllianceActive = getModelObjs("allianceactive",0,true)
        local listdata,other = mAllianceActive.getActiveObj(self.aname):getRankingList(aid)
      
        response.data[self.aname] = {rankingList =listdata}
        response.data[self.aname].rt = 0 -- 军团已领取奖励次数
        response.data[self.aname].score = 0 -- 军团总积分
        response.data[self.aname].myrank = -1 -- 军团排名
        response.data[self.aname].r = mUseractive.info[self.aname].r or 0

        if aid>0 then
            if type(other)~='table' then
                other = {}
            end
            local aAllianceActive = getModelObjs("allianceactive",aid)
            local activeObj = aAllianceActive.getActiveObj(self.aname) 
            response.data[self.aname].rt = activeObj.activeInfo.r or 0
            response.data[self.aname].score = other.score or 0
            response.data[self.aname].myrank = other.rank or -1

            if ts > tonumber(mUseractive.getAcet(self.aname, true)) and type(listdata)=='table' and next(listdata) then
                local mflag = false
                for k,v in pairs(listdata) do
                    if v[1] == zid and v[2] == aid  then
                        mflag = true
                        response.data[self.aname].myrank = k
                        break
                    end
                end
                if not mflag then
                    response.data[self.aname].myrank = -1
                end
            end
        end

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

        local uobjs = getUserObjs(uid)
        local mUseractive = uobjs.getModel('useractive')
        local activeCfg = mUseractive.getActiveConfig(self.aname)

        if ts < tonumber(mUseractive.getAcet(self.aname, true)) then
            response.ret = -102
            return response
        end

        local aid = uobjs.getModel('userinfo').alliance
        if aid < 1 then
            response.ret = -8012
            return response
        end

        if not mUseractive.info[self.aname].r then
            mUseractive.info[self.aname].r = 0 
        end

        if mUseractive.info[self.aname].r ==  1 then
            response.ret = -1976
            return response
        end

        local mAllianceActive = getModelObjs("allianceactive",aid)
        if not mAllianceActive then
            response.ret = -100
            return response
        end
        local activeObj = mAllianceActive.getActiveObj(self.aname)

        local myRanking = nil
        local rankingList = activeObj:getRankingList(aid)
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
        activeObj.activeInfo.r = (activeObj.activeInfo.r or 0) + 1
        -- 领取次数达到上限
        if activeObj.activeInfo.r > activeCfg.rGetLimit then
            response.ret = -1993
            return response
        end

        local reward = activeCfg.serverreward.rank[matchid]
        if not reward then
            response.ret = -102
            response.err = "reward is nil"
            return response
        end

        -- 领奖
        if not takeReward(uid, reward) then
            response.ret = -403
            return response
        end

        mUseractive.info[self.aname].r =  1
        regEventAfterSave(aid,'saveAllianceActive')
        if uobjs.save() then
            processEventsAfterSave()
            response.data[self.aname] = mUseractive.info[self.aname]
            response.data[self.aname].reward = formatReward(reward)
            response.ret = 0
            response.msg = 'Success'
        end

        return response
    end

    

    return self
end

return api_active_fqdzz
