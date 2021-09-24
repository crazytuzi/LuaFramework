--
-- desc: 感恩节拼图
-- user: chenyunhe
--
local function api_active_gejpt(request)
    local self = {
        response = {
            ret = -1,
            msg ='error',
            data = {},
        },
        aname = 'gejpt',
    }

    function self.formatreward(rewards)
        local formatreward = {}
        local key = 'gejpt'
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
        local ts= getClientTs()
        local weeTs = getWeeTs()
        local uobjs = getUserObjs(uid)
        uobjs.load({"userinfo",'useractive'})
        local mUseractive = uobjs.getModel('useractive')
        local mUserinfo = uobjs.getModel('userinfo')
        local activeCfg = mUseractive.getActiveConfig(self.aname)
        local flag = false

        local astore = {}
        -- 活动拼图道具
        for _,v in pairs(activeCfg.puzzleItem) do
            if not mUseractive.info[self.aname][v] then
                mUseractive.info[self.aname][v] = 0
                flag = true
            end
            table.insert(astore,0)
        end

        -- 个人积分
        if not mUseractive.info[self.aname].pscore then
            flag = true
            mUseractive.info[self.aname].pscore = 0
        end

        -- 签到次数
        if not mUseractive.info[self.aname].sn then
            flag = true
            mUseractive.info[self.aname].sn = 0
        end
        -- 判断当天是否已经签到
        if not mUseractive.info[self.aname].snt then
            flag = true
            mUseractive.info[self.aname].snt = 0
        end

        -- 兑换拼图次数
        if not mUseractive.info[self.aname].gLimit then
            mUseractive.info[self.aname].gLimit = 0
            flag = true
        end

        if type(mUseractive.info[self.aname].sign)~='table' then
            mUseractive.info[self.aname].sign = {}
            for k,v in pairs(activeCfg.serverreward.signList) do
                table.insert(mUseractive.info[self.aname].sign,0)
            end
            flag = true
        end

        if mUseractive.info[self.aname].t~=weeTs then
            mUseractive.info[self.aname].tk1 = {}
            for k,v in pairs(activeCfg.serverreward.taskList1) do
              table.insert(mUseractive.info[self.aname].tk1,{0,0,0}) --当前值 可领取次数  已领取次数    
            end

            mUseractive.info[self.aname].tk2 = {}
            for k,v in pairs(activeCfg.serverreward.taskList2) do
              table.insert(mUseractive.info[self.aname].tk2,{0,0,0}) --当前值 可领取次数  已领取次数    
            end

            mUseractive.info[self.aname].t = weeTs
            flag = true
        end

        if flag then
            if not uobjs.save() then
                response.ret = -106
                return response
            end
        end

        response.data[self.aname] = mUseractive.info[self.aname]
        local aid = mUserinfo.alliance
        response.data[self.aname].exflag = false
        response.data[self.aname].astore = astore
        if aid>0 then
            local mAllianceActive = getModelObjs("allianceactive",aid,false,true)
            if mAllianceActive then
                local activeObj = mAllianceActive.getActiveObj(self.aname)
                response.data[self.aname].astore = activeObj.activeInfo.store or astore
            end

            local redis =getRedis()
            local redkey ="zid."..getZoneId()..self.aname..mUseractive.info[self.aname].st..".exscore."..aid
            local exscoredata =redis:get(redkey)
            exscoredata =json.decode(exscoredata)
            if type (exscoredata)~="table" then exscoredata={}  end

            response.data[self.aname].exflag = self.checkexusers(exscoredata,uid,activeCfg.partnerLimit)
        end

        response.ret = 0
        response.msg = 'Success'

        return response
    end

    -- 签到
    function self.action_sign(request)
        local uid = request.uid
        local response = self.response
        local ts = getClientTs()
        local weeTs = getWeeTs()

        local uobjs = getUserObjs(uid)
        uobjs.load({"userinfo","props","bag",'useractive'})
        local mUseractive = uobjs.getModel('useractive')
        local mUserinfo = uobjs.getModel('userinfo')

        local activeCfg = mUseractive.getActiveConfig(self.aname)
        -- 当天已经签到
        if mUseractive.info[self.aname].snt==weeTs then
            response.ret = -102
            return response
        end

        if mUseractive.info[self.aname].sn>=#mUseractive.info[self.aname].sign then
            response.ret = -102
            return response
        end

        local index = mUseractive.info[self.aname].sn + 1
        local matchpool = 0
        if mUserinfo.level<activeCfg.poolLevel then
            matchpool = 'p0'
        else
            local mval = mUserinfo.level%activeCfg.pNum+1
            matchpool = 'p'..mval
        end

        if matchpool==0 then
            response.ret = -102
            return response
        end

        local signcfg = activeCfg.serverreward.signList[index]
        if type(signcfg)~='table' then
            response.ret = -121
            return response
        end

        local reward = {}
        local actprop = {}
        local report = {}
        for i=1,signcfg.puzzleNum do
            local rd,rk = getRewardByPool(activeCfg.serverreward[matchpool],1)
            for k,v in pairs(rd) do
                 for rkey,rval in pairs(v) do
                    if table.contains(activeCfg.puzzleItem,rkey) then
                        actprop[rkey] = (actprop[rkey] or 0) + rval
                    else
                        reward[rkey]=(reward[rkey] or 0)+rval
                    end               
                end
            end
        end

        if signcfg.r then
            for k,v in pairs(signcfg.r) do
                reward[k] = (reward[k] or 0)+v
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
        mUseractive.info[self.aname].snt = weeTs
        mUseractive.info[self.aname].sign[index] = 1
        mUseractive.info[self.aname].sn = (mUseractive.info[self.aname].sn or 0) + 1

        processEventsBeforeSave()
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

    -- 任务奖励
    function self.action_treward(request)
        local uid = request.uid
        local response = self.response
        local index = request.params.i -- 第几个页签
        local tid = request.params.tid -- 任务的编号
        local ts = getClientTs()
        local weeTs = getWeeTs()
        
        if not index or not tid then
            response.ret = -102
            return response
        end

        local uobjs = getUserObjs(uid)
        uobjs.load({"userinfo","props","bag",'useractive'})
        local mUseractive = uobjs.getModel('useractive')
        local mUserinfo = uobjs.getModel('userinfo')

        local activeCfg = mUseractive.getActiveConfig(self.aname)
        local taskcfg = activeCfg.serverreward['taskList'..index][tid]
        if not taskcfg then
            response.ret = -120
            return response
        end
        
        if mUseractive.info[self.aname].t~=weeTs then
            mUseractive.info[self.aname].tk1 = {}
            for k,v in pairs(activeCfg.serverreward.taskList1) do
              table.insert(mUseractive.info[self.aname],{0,0,0}) --当前值 可领取次数  已领取次数    
            end

            mUseractive.info[self.aname].tk2 = {}
            for k,v in pairs(activeCfg.serverreward.taskList2) do
              table.insert(mUseractive.info[self.aname].tk2,{0,0,0}) --当前值 可领取次数  已领取次数    
            end

            mUseractive.info[self.aname].t = weeTs
        end

        if mUseractive.info[self.aname]['tk'..index][tid][2]<=0 or mUseractive.info[self.aname]['tk'..index][tid][3]>=taskcfg.limit then
            response.ret = -102
            return response
        end
         
        local num = mUseractive.info[self.aname]['tk'..index][tid][2]
        if type(taskcfg.r)~='table' then
            response.ret = -120
            return response
        end

        local matchpool = 0
        if mUserinfo.level<activeCfg.poolLevel then
            matchpool = 'p0'
        else
            local mval = mUserinfo.level%activeCfg.pNum+1
            matchpool = 'p'..mval
        end

        if matchpool==0 then
            response.ret = -102
            return response
        end

        local report = {}
        local reward = {}
        local actprop = {}
        if taskcfg.puzzleNum>0 then
            local punum = taskcfg.puzzleNum*num
            for i=1,punum do
                local rd,rk = getRewardByPool(activeCfg.serverreward[matchpool],1)
                for k,v in pairs(rd) do
                     for rkey,rval in pairs(v) do
                        if table.contains(activeCfg.puzzleItem,rkey) then
                            actprop[rkey] = (actprop[rkey] or 0) + rval
                        else
                            reward[rkey]=(reward[rkey] or 0)+rval
                        end               
                    end
                end
            end
        end

        if taskcfg.r then
            for k,v in pairs(taskcfg.r) do
                if table.contains(activeCfg.puzzleItem,k) then
                    actprop[k] = (actprop[k] or 0) + v*num
                else
                    reward[k]=(reward[k] or 0)+v*num
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

        mUseractive.info[self.aname]['tk'..index][tid][3] = mUseractive.info[self.aname]['tk'..index][tid][3] + num
        mUseractive.info[self.aname]['tk'..index][tid][2] = 0

        processEventsBeforeSave()
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

    -- 交换拼图
    function self.action_exscore(request)
        local uid = request.uid
        local response = self.response
        local ts = getClientTs()
        local num = request.params.num or 0
        local index = request.params.i or 0

        if num<=0 or index<=0 or index>6 then
            response.ret = -102
            return response
        end

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
        local redis =getRedis()
        local redkey ="zid."..getZoneId()..self.aname..mUseractive.info[self.aname].st..".exscore."..aid
        local exscoredata =redis:get(redkey)
        exscoredata =json.decode(exscoredata)
        if type (exscoredata)~="table" then exscoredata={}  end

        if not self.checkexusers(exscoredata,uid,activeCfg.partnerLimit) then
            response.ret = -102
            return response
        end
        
        if mUseractive.info[self.aname][activeCfg.puzzleItem[index]]<num then
            response.ret = -102
            return response
        end

        local mAllianceActive = getModelObjs("allianceactive",aid,false,true)
        if mAllianceActive then
            local activeObj = mAllianceActive.getActiveObj(self.aname)
            local params = {}
            params.index = index
            params.num = num
            activeObj:addFrag(params)
        else
            response.ret = -100
            return response
        end

        local report = {}
        local score = activeCfg.getScore[index]*num
        mUseractive.info[self.aname].pscore = (mUseractive.info[self.aname].pscore or 0) + score
        mUseractive.info[self.aname][activeCfg.puzzleItem[index]] = mUseractive.info[self.aname][activeCfg.puzzleItem[index]] - num
        
        processEventsBeforeSave()
        if uobjs.save() then
            processEventsAfterSave()
            response.data[self.aname] = mUseractive.info[self.aname]
            response.data[self.aname].reward = report
            response.data[self.aname].getscore = score

            if #exscoredata<activeCfg.partnerLimit and not table.contains(exscoredata,uid) then
                table.insert(exscoredata,uid)

                exscoredata=json.encode(exscoredata)
                redis:set(redkey,exscoredata)
                redis:expireat(redkey,mUseractive.info[self.aname].et+86400)
            end
            
            response.ret = 0
            response.msg = 'Success'
        else
            response.ret = -106
        end

        return response
    end

    -- 检测玩家能否投放拼图碎片
    function self.checkexusers(exscoredata,uid,limit)
        if #exscoredata<limit then
            return true
        else
            if table.contains(exscoredata,uid) then
                return true
            else
                return false
            end
        end
    end

    -- 积分兑换拼图
    function self.action_expic(request)
        local uid = request.uid
        local response = self.response
        local ts = getClientTs()
        local num = request.params.num
        local index = request.params.i

        local uobjs = getUserObjs(uid)
        uobjs.load({"userinfo","props","bag",'useractive'})
        local mUseractive = uobjs.getModel('useractive')
        local mUserinfo = uobjs.getModel('userinfo')

        local aid = mUserinfo.alliance
        if aid<=0 then
            response.ret = -8012
            return response
        end

        local activeCfg = mUseractive.getActiveConfig(self.aname)
        local costscore = activeCfg.costScore[index]*num
        if (mUseractive.info[self.aname].pscore or 0)<costscore then
            response.ret = -102
            return response
        end

        local astore = {}
        local mAllianceActive = getModelObjs("allianceactive",aid,false,true)
        if mAllianceActive then
            local activeObj = mAllianceActive.getActiveObj(self.aname)
            local params = {}
            params.index = index
            params.num = num
            if not activeObj:subFrag(params) then
                response.ret = -100
                return response
            end
            astore =  activeObj.activeInfo.store or {}
        else
            response.ret = -100
            return response
        end  

        local report = {}
        mUseractive.info[self.aname][activeCfg.puzzleItem[index]] = (mUseractive.info[self.aname][activeCfg.puzzleItem[index]] or 0) + num
        table.insert(report,self.formatreward({[activeCfg.puzzleItem[index]]=num}))   
        mUseractive.info[self.aname].pscore = mUseractive.info[self.aname].pscore- costscore
        processEventsBeforeSave()
        if uobjs.save() then
            processEventsAfterSave()
            response.data[self.aname] = mUseractive.info[self.aname]
            response.data[self.aname].reward = report
            response.data[self.aname].astore = astore

            response.ret = 0
            response.msg = 'Success'
        else
            response.ret = -106
        end

        return response
    end

    -- 购买拼图碎片
    function self.action_buy(request)
        local uid = request.uid
        local response = self.response
        local ts = getClientTs()
        local num = request.params.num or 0
        local i = request.params.i or 0

        local uobjs = getUserObjs(uid)
        uobjs.load({"userinfo","props","bag",'useractive'})
        local mUseractive = uobjs.getModel('useractive')
        local mUserinfo = uobjs.getModel('userinfo')

        local activeCfg = mUseractive.getActiveConfig(self.aname)
        if num<=0 or i<=0 or i>6 then
            response.ret = -102
            return response
        end

        local gems = activeCfg.gemCost[i]*num
        if gems<=0 then 
            response.ret = -102
            return response
        end
        if not mUserinfo.useGem(gems) then
            response.ret = -109
            return response
        end

        local report = {}
        mUseractive.info[self.aname][activeCfg.puzzleItem[i]] = (mUseractive.info[self.aname][activeCfg.puzzleItem[i]]  or 0) + num
        table.insert(report,self.formatreward({[activeCfg.puzzleItem[i]]=num}))
        regActionLogs(uid,1,{action=277,item="",value=gems,params={num=num,index=i}})
        processEventsBeforeSave()
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

    -- 拼图
    function self.action_montage(request)
        local uid = request.uid
        local response = self.response
        local ts = getClientTs()

        local uobjs = getUserObjs(uid)
        uobjs.load({"userinfo","props","bag",'useractive'})
        local mUseractive = uobjs.getModel('useractive')
        local mUserinfo = uobjs.getModel('userinfo')
        
        local activeCfg = mUseractive.getActiveConfig(self.aname)
        local curglimit = mUseractive.info[self.aname].gLimit or 0
        if  curglimit>= activeCfg.giftLimit then
            response.ret = -121
            return response
        end
        local num = nil 
        for k,v in pairs(activeCfg.puzzleItem) do
            local cur = mUseractive.info[self.aname][v] 
            if not num then
                num = cur
            end
            if cur<num then
                num=cur 
            end
        end

        if not num or num<=0  then
            response.ret = -102
            return response
        end

        local leftn= activeCfg.giftLimit - curglimit

        if num > leftn then
            num = leftn
        end

        local report = {}
        local reward = {} 
        for k,v in pairs(activeCfg.serverreward.puzzleGift) do
            reward[k] = (reward[k] or 0)+v*num
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

        for k,v in pairs(activeCfg.puzzleItem) do
            mUseractive.info[self.aname][v] = mUseractive.info[self.aname][v] - num
        end

        mUseractive.info[self.aname].gLimit = (mUseractive.info[self.aname].gLimit or 0)+num

        processEventsBeforeSave()
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

    return self
end

return api_active_gejpt
