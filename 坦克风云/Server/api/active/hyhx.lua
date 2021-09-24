--
-- desc: 海域航线
-- user: chenyunhe
--
local function api_active_hyhx(request)
    local self = {
        response = {
            ret = -1,
            msg ='error',
            data = {},
        },
        aname = 'hyhx',
    }

    function self.formatreward(rewards)
        local formatreward = {}
        local key = 'hyhx'
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

        -- 任务
        if not mUseractive.info[self.aname].tk then
            mUseractive.info[self.aname].tk = {}
            for k,v in pairs(activeCfg.serverreward.taskList) do
                table.insert(mUseractive.info[self.aname].tk,{0,0,0}) --当前值 可领取次数 已领取次数
            end
            flag = true
        end

        if mUseractive.info[self.aname].t ~= weeTs then
            mUseractive.info[self.aname].t = weeTs
            for k,v in pairs(activeCfg.serverreward.taskList) do
                mUseractive.info[self.aname].tk[k] = {0,0,0} -- 可领取次数 已领取次数 当前值
            end
            flag = true
        end

        -- 有没有领取排行榜奖励
        if not mUseractive.info[self.aname].r then
            flag = true
            mUseractive.info[self.aname].r = 0
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
    
    -- 领取任务奖励
    function self.action_treward(request)
        local uid = request.uid
        local response = self.response
        local index = request.params.i --任务下标
        local weeTs = getWeeTs()
        local uobjs = getUserObjs(uid)
        uobjs.load({"userinfo",'useractive'})
        local mUseractive = uobjs.getModel('useractive')
        local mUserinfo = uobjs.getModel('userinfo')

        local activeCfg = mUseractive.getActiveConfig(self.aname)

        local tkcfg = activeCfg.serverreward.taskList[index]
        if type(tkcfg)~='table' then
            response.ret = -102
            return response
        end

        if mUseractive.info[self.aname].t ~= weeTs then
            mUseractive.info[self.aname].t = weeTs
            for k,v in pairs(activeCfg.serverreward.taskList) do
                mUseractive.info[self.aname].tk[k] = {0,0,0} -- 可领取次数 已领取次数 当前值
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
    
        if rnum<=0 then
            response.ret = -102
            return response
        end

        local reward = {}
        local report = {}
        local hyhx_a1 = 0
        for k,v in pairs(tkcfg.r) do
            if string.find(k,"hyhx_a1") then
                hyhx_a1 = v*rnum
                table.insert(report,self.formatreward({[k]=v*rnum}))
            else
                reward[k] = v*rnum
                table.insert(report,formatReward({[k]=v*rnum}))   
            end
        end

        if next(reward) then
            if not takeReward(uid,reward) then
                response.ret = -102
                return response
            end
        end

        local aid = mUserinfo.alliance
        if hyhx_a1>0 and aid>0 then
            local mAllianceActive = getModelObjs("allianceactive",aid,false,true)

            if mAllianceActive then
                local params = {}
                params.score = hyhx_a1
                mAllianceActive.getActiveObj(self.aname):addPoint(params)
            else
                writeLog({msg="hyhx addPoint error",aid=aid,point=hyhx_a1},'errorhyhx')
            end
        end

        mUseractive.info[self.aname].tk[index][2] = mUseractive.info[self.aname].tk[index][2] + mUseractive.info[self.aname].tk[index][1]
        mUseractive.info[self.aname].tk[index][1] = 0      
        if uobjs.save() then
            processEventsAfterSave()
            
            response.data[self.aname] =mUseractive.info[self.aname]
            response.data[self.aname].reward = report
            response.ret = 0
            response.msg = 'Success'
        else
            response.ret=-106
        end

        return response
    end

    -- 航线数据
    function self.action_route(request)
        local response = self.response
        local uid=request.uid
        local weeTs = getWeeTs()

        local uobjs = getUserObjs(uid)
        uobjs.load({"userinfo",'useractive'})
        local mUseractive = uobjs.getModel('useractive')
        local mUserinfo = uobjs.getModel('userinfo')

        if mUserinfo.alliance==0 then
            response.ret = -8012
            return response
        end
        local activeCfg = mUseractive.getActiveConfig(self.aname)
        
        local aAllianceActive = getModelObjs("allianceactive",mUserinfo.alliance)
        local activeObj = aAllianceActive.getActiveObj(self.aname) 
        if type(activeObj.activeInfo.cells)~='table' then
            activeObj:getcells(true)
        end
       
        -- 军团公用的宝箱  不能被清空 且成员领取后需要在自身上计数   
        -- 如果玩家对出军团 则在加入下一个军团时 已领取的数量要将加入的军团宝箱数同步在玩家身上 避免玩家不断加军团领箱子
        -- 宝箱奖励
        if not mUseractive.info[self.aname].box then
            mUseractive.info[self.aname].box = {}
        end

        -- 个人击杀和进攻的箱子领取完要清空
        -- 击杀奖励
        if not mUseractive.info[self.aname].kill then
            mUseractive.info[self.aname].kill = {}
        end

        -- 进攻奖励
        if not mUseractive.info[self.aname].att then
            mUseractive.info[self.aname].att = {}
        end

        -- 打过的boss所在轮数
        if not mUseractive.info[self.aname].bn then
            mUseractive.info[self.aname].bn = 0
        end

        -- 打过的boss所在轮中的下标
        if not mUseractive.info[self.aname].bi then
            mUseractive.info[self.aname].bi = 0
        end
    
        local getbox = self.getabox(activeObj.activeInfo.abox,mUseractive.info[self.aname].box)
        if uobjs.save() then
            processEventsAfterSave()
            response.data[self.aname] = mUseractive.info[self.aname]
            response.data[self.aname].cells = activeObj.activeInfo.cells -- 格子数据
            response.data[self.aname].hyhx_a1 = activeObj.activeInfo.score or 0 -- 当前的航线物资
            response.data[self.aname].n = activeObj.activeInfo.n or 1--当前轮数
            response.data[self.aname].index = activeObj.activeInfo.index or 1 -- 从位置1开始
            response.data[self.aname].abox = getbox ---可以领取的军团宝箱数量
            response.data[self.aname].steps = activeObj.activeInfo.steps or 0 -- 总步数
            response.ret = 0
            response.msg = 'Success'
        else
            response.ret = -106
        end

        return response
    end

    -- 可领取军团宝箱数据
    function self.getabox(abox,box)
        local r = {}
        if type(abox)=='table' and next(abox) then
            for k,v in pairs(abox) do
                local left = v - (box[k] or 0)
                if left>0 then
                    r[k] = left
                end
            end
        end

        return r
    end

    -- 点击前进按钮
    function self.action_move(request)
        local uid = request.uid
        local response = self.response
        local index = request.params.i --移动到下一个格子的下标 如果移动到最后一个 下一个为8
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

        if index<=0 or index>activeCfg.cellNum+1 then
            response.ret = -102
            return response
        end

        local ret,code = M_alliance.getalliance{getuser=1,method=1,aid=aid,uid=uid}
        -- 如果是军团长 需要给额外的奖励 如果是军团长 需要给额外的奖励
        if tonumber(ret.data.role)~=2 then
            response.ret = -102
            return response
        end

        local aAllianceActive = getModelObjs("allianceactive",aid)
        if not aAllianceActive then
            response.ret = -100
            return response
        end

        -- 移动方法
        local params = {}
        params.index = index
        params.allianceName = mUserinfo.alliancename
        local ret = aAllianceActive.getActiveObj(self.aname):move(params)

        if ret~=0 then
            response.ret = ret 
            return response
        end
    
        if uobjs.save() then
            processEventsAfterSave()

            local activeObj = aAllianceActive.getActiveObj(self.aname)
            local getbox = self.getabox(activeObj.activeInfo.abox,mUseractive.info[self.aname].box)
            response.data[self.aname] = mUseractive.info[self.aname]
            response.data[self.aname].cells = activeObj.activeInfo.cells -- 格子数据
            response.data[self.aname].hyhx_a1 = activeObj.activeInfo.score or 0 -- 当前的航线物资
            response.data[self.aname].n = activeObj.activeInfo.n or 1--当前轮数
            response.data[self.aname].index = activeObj.activeInfo.index or 1 -- 从位置1开始
            response.data[self.aname].abox = getbox ---可以领取的军团宝箱数量
            response.data[self.aname].steps = activeObj.activeInfo.steps or 0 -- 总步数
            response.ret = 0
            response.msg = 'Success'
        else
            response.ret=-106
        end

        return response
    end

    -- 军团长打开宝箱
    function self.action_open(request)
        local uid = request.uid
        local response = self.response
        local index = request.params.i -- 当前格子的下标
        local cost = request.params.cost --跟前端校验消耗
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

        if index<=0 or index>activeCfg.cellNum then
            response.ret = -102
            return response
        end

        local ret,code = M_alliance.getalliance{getuser=1,method=1,aid=aid,uid=uid}
        -- 如果是军团长 需要给额外的奖励 如果是军团长 需要给额外的奖励
        if tonumber(ret.data.role)~=2 then
            response.ret = -102
            return response
        end

        local aAllianceActive = getModelObjs("allianceactive",aid)
        if not aAllianceActive then
            response.ret = -100
            return response
        end

        -- 移动方法
        local params = {}
        params.index = index
        params.cost = cost
        local ret = aAllianceActive.getActiveObj(self.aname):open(params)

        if ret~=0 then
            response.ret = ret 
            return response
        end
    
        if uobjs.save() then
            processEventsAfterSave()

            local activeObj = aAllianceActive.getActiveObj(self.aname)
            local getbox = self.getabox(activeObj.activeInfo.abox,mUseractive.info[self.aname].box)
            response.data[self.aname] = mUseractive.info[self.aname]
            response.data[self.aname].cells = activeObj.activeInfo.cells -- 格子数据
            response.data[self.aname].hyhx_a1 = activeObj.activeInfo.score or 0 -- 当前的航线物资
            response.data[self.aname].n = activeObj.activeInfo.n or 1--当前轮数
            response.data[self.aname].index = activeObj.activeInfo.index or 1 -- 从位置1开始
            response.data[self.aname].abox = getbox ---可以领取的军团宝箱数量
            response.ret = 0
            response.msg = 'Success'
        else
            response.ret=-106
        end

        return response
    end

    -- 打boss
    function self.action_attack(request)
        local uid = request.uid
        local response = self.response
        local bn  = request.params.bn
        local bi = request.params.bi
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

        if bi<=0 or bi>activeCfg.cellNum then
            response.ret = -102
            return response
        end

        local aAllianceActive = getModelObjs("allianceactive",aid)
        if not aAllianceActive then
            response.ret = -100
            return response
        end

        local params = {}
        params.bi = bi
        params.bn = bn
        params.fc = mUserinfo.fc
        local bi1 = mUseractive.info[self.aname].bi or 0
        local bn1 = mUseractive.info[self.aname].bn or 0

        if bn==bn1 and bi==bi1 then
            response.ret = -1976
            return response
        end
     
        local ret,killflag,curn,cindex = aAllianceActive.getActiveObj(self.aname):attack(params)
        if ret~=0 then
            response.ret = ret 
            return response
        end

        mUseractive.info[self.aname].att['p5'] = (mUseractive.info[self.aname].att['p5'] or 0) + 1
        if killflag then
            mUseractive.info[self.aname].kill['p6'] = (mUseractive.info[self.aname].kill['p6'] or 0) + 1
        end

        mUseractive.info[self.aname].bn = curn
        mUseractive.info[self.aname].bi = cindex

        if uobjs.save() then
            processEventsAfterSave()

            local activeObj = aAllianceActive.getActiveObj(self.aname)
            local getbox = self.getabox(activeObj.activeInfo.abox,mUseractive.info[self.aname].box)
            response.data[self.aname] = mUseractive.info[self.aname]
            response.data[self.aname].cells = activeObj.activeInfo.cells -- 格子数据
            response.data[self.aname].hyhx_a1 = activeObj.activeInfo.score or 0 -- 当前的航线物资
            response.data[self.aname].n = activeObj.activeInfo.n or 1--当前轮数
            response.data[self.aname].index = activeObj.activeInfo.index or 1 -- 从位置0开始
            response.data[self.aname].abox = getbox ---可以领取的军团宝箱数量
            response.ret = 0
            response.msg = 'Success'
        else
            response.ret=-106
        end

        return response
    end

    -- 领取宝箱奖励
    function self.action_boxreward(request)
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

        local curn = activeObj.activeInfo.n or 1
        local safe = false
        if curn >= activeCfg.serverreward.safe then
            safe = true
        end
   
        local reward = {}
        -- 可领取的军团宝箱
        local getbox = self.getabox(activeObj.activeInfo.abox,mUseractive.info[self.aname].box)
        if type(getbox)=='table' and next(getbox) then
            for k,v in pairs(getbox) do
                local pool = k
                if safe then
                    pool= 's'..pool
                end

                for i=1,v do
                    local result,rewardkey = getRewardByPool(activeCfg.serverreward[pool],1)      
                    for rek,rev in pairs (result) do
                        for rk,rv in pairs(rev) do
                            reward[rk]=(reward[rk] or 0)+rv
                        end
                    end 
                end  
                mUseractive.info[self.aname].box[k] = (mUseractive.info[self.aname].box[k] or  0) + v          
            end 
        end

        -- 可领取的击杀宝箱
        if type(mUseractive.info[self.aname].kill)=='table' and next(mUseractive.info[self.aname].kill) then 
            for k,v in pairs(mUseractive.info[self.aname].kill) do
                local pool = k
                if safe then
                    pool= 's'..pool
                end
                for i=1,v do
                    local result,rewardkey = getRewardByPool(activeCfg.serverreward[pool],1)      
                    for rek,rev in pairs (result) do
                        for rk,rv in pairs(rev) do
                            reward[rk]=(reward[rk] or 0)+rv
                        end
                    end 
                end       
            end  
        end

        --可领取的攻击宝箱
        if type(mUseractive.info[self.aname].att)=='table' and next(mUseractive.info[self.aname].att) then
            for k,v in pairs(mUseractive.info[self.aname].att) do
                local pool = k
                if safe then
                    pool= 's'..pool
                end
                for i=1,v do
                    local result,rewardkey = getRewardByPool(activeCfg.serverreward[pool],1)      
                    for rek,rev in pairs (result) do
                        for rk,rv in pairs(rev) do
                            reward[rk]=(reward[rk] or 0)+rv
                        end
                    end 
                end       
            end 
        end
        
        if not next(reward) then
            response.ret = -102
            return response
        end

        if not takeReward(uid,reward) then
            response.ret = -403
            return response
        end

        -- 击杀、攻击的宝箱清空
        mUseractive.info[self.aname].att = {}
        mUseractive.info[self.aname].kill = {}

        if uobjs.save() then
            processEventsAfterSave()

            local activeObj = aAllianceActive.getActiveObj(self.aname)
            response.data[self.aname] = mUseractive.info[self.aname]
            response.data[self.aname].cells = activeObj.activeInfo.cells -- 格子数据
            response.data[self.aname].hyhx_a1 = activeObj.activeInfo.score or 0 -- 当前的航线物资
            response.data[self.aname].n = activeObj.activeInfo.n or 1--当前轮数
            response.data[self.aname].index = activeObj.activeInfo.index or 1 -- 从位置1开始
            response.data[self.aname].abox = {} ---可以领取的军团宝箱数量
            response.data[self.aname].reward = formatReward(reward)

            response.ret = 0
            response.msg = 'Success'
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
        local mAllianceActive = getModelObjs("allianceactive",0,true)
        response.data[self.aname] = {rankingList = mAllianceActive.getActiveObj(self.aname):getRankingList()}
        response.data[self.aname].rt1 = 0 -- 军团已领取奖励次数
        response.data[self.aname].rt2 = 0 -- 军团长领取奖励次数
        response.data[self.aname].steps = 0 -- 军团总积分
        local uobjs = getUserObjs(uid)
        local mUseractive = uobjs.getModel('useractive')
        response.data[self.aname].r = mUseractive.info[self.aname].r or 0
        if aid>0 then
            local aAllianceActive = getModelObjs("allianceactive",aid)
            local activeObj = aAllianceActive.getActiveObj(self.aname) 
            response.data[self.aname].rt1 = activeObj.activeInfo.r1 or 0
            response.data[self.aname].rt2 = activeObj.activeInfo.r2 or 0  
            response.data[self.aname].steps = activeObj.activeInfo.steps or 0
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

        if mUseractive.info[self.aname].r ==  1 then
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

        --返回值role 2是军团长，1是副团长，0是普通成员
        local ret,code = M_alliance.getalliance{getuser=1,method=1,aid=aid,uid=uid}
        local flag = false
        -- 如果是军团长 需要给额外的奖励 如果是军团长 需要给额外的奖励
        if tonumber(ret.data.role)==2 then
            flag =  true
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
        activeObj.activeInfo.r1 = (activeObj.activeInfo.r1 or 0) + 1
        if not activeObj.activeInfo.r2 then
            activeObj.activeInfo.r2 = 0
        end
        local reward

        -- 领取次数达到上限
        if activeObj.activeInfo.r1 > activeCfg.rGetLimit then
            if tonumber(ret.data.role)==2 then
                local r2 = activeObj.activeInfo.r2 or 0
                if r2 == 0 then
                    reward = copyTable(activeCfg.serverreward.trank[matchid])

                    activeObj.activeInfo.r2 = 1
                else
                    response.ret = -1976
                    return response
                end
            else
                response.ret = -1993
                return response
            end
        else
           reward = copyTable(activeCfg.serverreward.rank[matchid])
           if flag and activeObj.activeInfo.r2==0 then
                for k,v in pairs(activeCfg.serverreward.trank[matchid]) do
                    reward[k] = (reward[k] or 0) + v
                end
                activeObj.activeInfo.r2 = 1
           end
        end
        
        if not reward then
            response.ret = -102
            response.err = "reward is nil"
            return response
        end

        -- 领奖
        if not takeReward(uid, reward) then
            response.ret = -1989
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

return api_active_hyhx
