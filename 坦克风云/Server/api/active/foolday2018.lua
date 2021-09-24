-- 设置标识
local function setFlag(flags,flag)
    return bit32.bor(flags or 0,flag);
end

-- 标识是否已被设置
local function isFlagSet(flags,flag)
    return bit32.band(flag,(flags or 0)) == flag
end

-- 合并数据给客户端用的(客户端要求)
local function mergeData(userActiveInfo,allianceActiveInfo)
    local d = {}
    if userActiveInfo then
        for k,v in pairs(userActiveInfo) do 
            d[k] = v
        end
    end

    if allianceActiveInfo then
        for k,v in pairs(allianceActiveInfo) do
            if not d[k] then
                d[k] = v
            end
        end
    end

    return d
end

-- 愚人大作战活动(愚人节2018)
local function api_active_foolday2018(request)
    local self = {
        response = {
            ret = -1,
            msg = 'error',
            data = {},
        },
        
        -- 活动名
        aname = "foolday2018",

        activeSt = 0, -- 起始时间
    }
    
    function self.getRules()
        local rules = {
            -- required 表示参数是必需的,必需放在table的第1位
            -- _uid 表示取request.uid 而不是request.params.uid
            ["*"] = {
                _uid = { "required" }
            },

            ["action_pTaskReward"] = {
                tid = { "required","string" },
            },

            ["action_donate"] = {
                itemId = { "required", "string"},
                num = {"required", "number", {"min", 1}},
            },

            ["action_donateReward"] = {
                itemId = { "required", "string"},
            },

            ["action_aTaskReward"] = {
                tid = { "required", "string"},
            },

            ["action_rechargeReward"] = {
                num = { "required", "number", {"min", 1}},
            },

            ["action_rankingReward"] = {
                ranking = { "required","number", {"min", 1}},
            },
            
        }
        return rules
    end
    
    function self.before(request)
        local uid = request.uid
        local uobjs = getUserObjs(uid)
        local mUseractive = uobjs.getModel('useractive')

        local rewardTs = true
        if request.cmd == "active.foolday2018.rankingList" or request.cmd == "active.foolday2018.rankingReward" then 
            rewardTs = false
        end

        -- 活动状态检测
        local activStatus = mUseractive.getActiveStatus(self.aname)

        if activStatus ~= 1 then
            local response = self.response
            response.ret = activStatus
            return response
        end

        if mUseractive.info[self.aname].t < getWeeTs() then
            mUseractive.setActive(self.aname,{act="clean"})
        end

        self.activeSt = mUseractive.info[self.aname].st
        self.uid = uid
    end
    
    -- 获取军团任务信息
    function self.action_get(request)
        local response = self.response
        local uid = request.uid
        local uobjs = getUserObjs(uid)
        local mUseractive = uobjs.getModel('useractive')
        local activeInfo = mUseractive.info[self.aname]

        local allianceActiveInfo
        local aid = uobjs.getModel('userinfo').alliance
        if aid > 0 then
            local mAllianceActive = getModelObjs("allianceactive",aid)
            allianceActiveInfo = mAllianceActive.getActiveObj(self.aname).activeInfo
        end

        if not activeInfo.task and activeInfo.c == 0 then
            mUseractive.setActive(self.aname,{act="newtask"})
            uobjs.save()
        end

        response.data[self.aname] = mergeData(activeInfo,allianceActiveInfo)
        processEventsAfterSave()

        response.ret = 0
        response.msg = 'Success'
        return response
    end

    -- 刷新个人任务
    function self.action_refreshTask(request)
        local response = self.response
        local uid = request.uid

        local uobjs = getUserObjs(uid)
        local mUseractive = uobjs.getModel('useractive')
        local activeInfo = mUseractive.info[self.aname]
        local activeCfg = mUseractive.getActiveConfig(self.aname)

        if not activeInfo.task then
            response.ret = -102
            response.err = "task invalid"
            return response
        end

        -- 每日可完成任务的次数次数达到上限
        if activeInfo.c >= activeCfg.taskLimit then
            response.ret = -1993 
            return response
        end

        activeInfo.rn = (activeInfo.rn or 0) + 1
        local n = (activeInfo.rn >= #activeCfg.refreshCost) and #activeCfg.refreshCost or activeInfo.rn
        local gemCost = activeCfg.refreshCost[n]
        if gemCost > 0 then
            if not uobjs.getModel("userinfo").useGem(gemCost) then
                response.ret = -109
                return response
            end

            -- 愚人节(2018)大作战-刷新个人任务
            regActionLogs(uid, 1, {action=211, item="", value=gemCost, params={rn=activeInfo.rn}})
        end

        mUseractive.setActive(self.aname,{act="newtask"})

        if uobjs.save() then
            response.data[self.aname] = activeInfo
            response.ret = 0
            response.msg = 'Success'
        end

        return response
    end

    -- 个人任务完成奖励
    function self.action_pTaskReward(request)
        local response = self.response
        local uid = request.uid
        local tid = request.params.tid

        local uobjs = getUserObjs(uid)
        local mUseractive = uobjs.getModel('useractive')
        local activeInfo = mUseractive.info[self.aname]
        local activeCfg = mUseractive.getActiveConfig(self.aname)

        if not activeInfo.task or activeInfo.task.tp ~= tid or not activeCfg.randtaskpool[tid] then
            response.ret = -102
            response.taskId = activeInfo.task
            return response
        end

        -- 任务条件未达成
        local taskCfg = activeCfg.taskList[activeCfg.randtaskpool[tid][1]]
        if activeInfo.task.num < taskCfg.num then
            response.ret = -1981
            return response
        end
        
        -- 当日已完成任务+1
        activeInfo.c = activeInfo.c + 1

        -- 最多完成10次
        if activeInfo.c > activeCfg.taskLimit then
            response.ret = -1976 -- 物品已领取
            return response
        end

        -- 新分配一个任务
        mUseractive.setActive(self.aname,{act="newtask"})

        -- 发奖励
        mUseractive.setActive(self.aname,{act="takeReward",reward=taskCfg.serverreward[1]})

        if uobjs.save() then
            response.data[self.aname] = activeInfo
            response.ret = 0
            response.msg = 'Success'
        end

        return response
    end

    -- 军团任务完成奖励
    function self.action_aTaskReward(request)
        local response = self.response
        local uid = request.uid
        local tid = request.params.tid

        local uobjs = getUserObjs(uid)
        local mUseractive = uobjs.getModel('useractive')
        local activeInfo = mUseractive.info[self.aname]
        local activeCfg = mUseractive.getActiveConfig(self.aname)

        local aid = uobjs.getModel('userinfo').alliance
        if aid < 1 then
            response.ret = -8012
            return response
        end

        local mAllianceActive = getModelObjs("allianceactive",aid)
        local activeObj = mAllianceActive.getActiveObj(self.aname)
        local allianceActiveInfo = activeObj.activeInfo

        -- 积分不足
        if not allianceActiveInfo or not allianceActiveInfo.atask then
            response.ret = -1981
            return response
        end

        local taskInfo = allianceActiveInfo.atask
        local taskCfg = activeCfg.allianceTask[taskInfo.id]

        if not taskCfg or taskCfg.type ~= tid then
            response.ret = -102
            return response
        end

        if taskInfo.num < taskCfg.num then
            response.ret = -1981
            return response
        end

        taskInfo.r = (taskInfo.r or 0) + 1
        -- 当日任务领取次数达到上限
        if (taskInfo.r or 0) > activeCfg.aTaskLimit then
            response.ret = -1993
            return response
        end

        local rewardFlag = 16
        if isFlagSet(activeInfo.rd,rewardFlag) then
            response.ret = -1976 -- 物品已领取
            return response
        end

        activeInfo.rd = setFlag(activeInfo.rd,rewardFlag)

        if mAllianceActive.saveData() then
            mUseractive.setActive(self.aname,{act="takeReward",reward=taskCfg.serverreward[1]})
        end

        if uobjs.save() then
            response.data[self.aname] = mergeData( mUseractive.info[self.aname],allianceActiveInfo)
            response.ret = 0
            response.msg = 'Success'
        end

        return response
    end

    -- 捐献
    function self.action_donate(request)
        local response = self.response
        local uid = request.uid
        local itemId = request.params.itemId
        local num = request.params.num

        local uobjs = getUserObjs(uid)
        local mUseractive = uobjs.getModel('useractive')
        local activeInfo = mUseractive.info[self.aname]
        local activeCfg = mUseractive.getActiveConfig(self.aname)

        -- 物品数量不足
        if not activeInfo.items or not activeInfo.items[itemId] or activeInfo.items[itemId] < num then
            response.ret = -1996
            return response
        end

        activeInfo.items[itemId] = math.floor(activeInfo.items[itemId] - num)

        local i = string.sub(itemId, #"foolday_a1")
        local point = activeCfg.point[tonumber(i)]
        local poolCfg = activeCfg["pool".. tostring(i)]
        if not point or point < 1 or not poolCfg then
            response.ret = -102
            response.err = "point error"
            return response
        end

        point = point * num
        local aActivity = mUseractive.setActive(self.aname,{act="addPoint",item=itemId,point=point})

        local reward = {}
        for i=1,num do
            local r = getRewardByPool(poolCfg)
            for k,v in pairs(r) do
                reward[k] = (reward[k] or 0) + v
            end
        end

        -- if num <= 50 then
        --     for i=1,num do
        --         local r = getRewardByPool(poolCfg)
        --         for k,v in pairs(r) do
        --             reward[k] = (reward[k] or 0) + v
        --         end
        --     end
        -- elseif num > 50 then
        --     reward = copyTable(poolCfg[3])
        -- end
       
        -- 领奖
        if not takeReward(uid, reward) then
            response.ret = -1989
            return response
        end

        if uobjs.save() then
            processEventsAfterSave()
            response.data[self.aname] = mergeData(activeInfo,aActivity)
            response.data[self.aname].reward = formatReward(reward)
            response.ret = 0
            response.msg = 'Success'
        end

        return response
    end

    -- 排行榜列表
    function self.action_rankingList(request)
        local response = self.response
        local mAllianceActive = getModelObjs("allianceactive",0,true)
        response.data[self.aname] = {rankingList = mAllianceActive.getActiveObj(self.aname):getRankingList()}
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

        local uobjs = getUserObjs(uid)
        local mUseractive = uobjs.getModel('useractive')
        local activeInfo = mUseractive.info[self.aname]
        local activeCfg = mUseractive.getActiveConfig(self.aname)

        local aid = uobjs.getModel('userinfo').alliance
        if aid < 1 then
            response.ret = -8012
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

        -- 军团领取次数+1
        activeObj.activeInfo.r = (activeObj.activeInfo.r or 0) + 1

        -- 领取次数达到上限
        if activeObj.activeInfo.r > activeCfg.rGetLimit then
            response.ret = -1993
            return response
        end

        local rewardFlag = 32
        if isFlagSet(activeInfo.rd,rewardFlag) then
            response.ret = -1976 -- 物品已领取
            return response
        end

        activeInfo.rd = setFlag(activeInfo.rd,rewardFlag)

        local reward
        for k,v in pairs(activeCfg.section) do
            if myRanking >= v[1] and myRanking <= v[2] then
                reward = activeCfg["rank"..k]
                break
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

        regEventAfterSave(aid,'saveAllianceActive')
        if uobjs.save() then
            processEventsAfterSave()
            response.data[self.aname] = activeInfo
            response.ret = 0
            response.msg = 'Success'
        end

        return response
    end

    -- 捐献奖励
    function self.action_donateReward(request)
        local response = self.response
        local uid = request.uid
        local itemId = request.params.itemId

        local uobjs = getUserObjs(uid)
        local mUseractive = uobjs.getModel('useractive')
        local activeInfo = mUseractive.info[self.aname]
        local activeCfg = mUseractive.getActiveConfig(self.aname)

        local i = string.sub(itemId, #"foolday_a1")
        local giftId = "gift" .. tostring(i)
        local needPoint = activeCfg.supportNeed[tonumber(i)]
        if not activeCfg[giftId] or not needPoint then
            response.ret = -102
            return response
        end

        local aid = uobjs.getModel('userinfo').alliance
        if aid < 1 then
            response.ret = -8012
            return response
        end

        local mAllianceActive = getModelObjs("allianceactive",aid)
        local activeObj = mAllianceActive.getActiveObj(self.aname)

        -- 积分不足
        if not activeObj.activeInfo or not activeObj.activeInfo.itemPoint or (activeObj.activeInfo.itemPoint[itemId] or 0) < needPoint then
            response.ret = -1981
            return response
        end

        i = tonumber(i)
        if not activeObj.activeInfo.dnr[i] then
            response.ret = -1993
            return response
        end

        -- 军团领取次数+1
        activeObj.activeInfo.dnr[i] = activeObj.activeInfo.dnr[i] + 1

        -- 领取次数达到上限
        if activeObj.activeInfo.dnr[i] > activeCfg.rGetLimit then
            response.ret = -1993
            return response
        end

        local rewardFlags = {1,2,4}
        local rewardFlag = rewardFlags[i]
        activeInfo.rd = activeInfo.rd or 0
        if not rewardFlag or isFlagSet(activeInfo.rd,rewardFlag) then
            response.ret = -1976 -- 物品已领取
            return response
        end

        activeInfo.rd = setFlag(activeInfo.rd,rewardFlag) 

        -- 领奖
        if not takeReward(uid, activeCfg[giftId]) then
            response.ret = -1989
            return response
        end

        regEventAfterSave(aid,'saveAllianceActive')
        if uobjs.save() then
            processEventsAfterSave()
            response.data[self.aname] = mergeData(activeInfo,activeObj.activeInfo)

            response.ret = 0
            response.msg = 'Success'
        end

        return response
    end

    -- 捐献大奖奖励
    function self.action_donateBigReward(request)
        local response = self.response
        local uid = request.uid

        local uobjs = getUserObjs(uid)
        local mUseractive = uobjs.getModel('useractive')
        local activeInfo = mUseractive.info[self.aname]
        local activeCfg = mUseractive.getActiveConfig(self.aname)

        local aid = uobjs.getModel('userinfo').alliance
        if aid < 1 then
            response.ret = -8012
            return response
        end

        local mAllianceActive = getModelObjs("allianceactive",aid)
        local activeObj = mAllianceActive.getActiveObj(self.aname)

        -- 积分不足
        if not activeObj.activeInfo or not activeObj.activeInfo.itemPoint then
            response.ret = -1981
            return response
        end

        -- 检测是否全部捐满
        for i=1,#activeCfg.supportNeed do
            local itemId = "foolday_a" .. tostring(i)
            if not activeObj.activeInfo.itemPoint[itemId] or activeObj.activeInfo.itemPoint[itemId] < activeCfg.supportNeed[i] then
                response.ret = -1981
                return response
            end
        end

        local i = 4
        if not activeObj.activeInfo.dnr[i] then
            response.ret = -1993
            return response
        end

        -- 军团领取次数+1
        activeObj.activeInfo.dnr[i] = activeObj.activeInfo.dnr[i] + 1

        -- 领取次数达到上限
        if activeObj.activeInfo.dnr[i] > activeCfg.rGetLimit then
            response.ret = -1993
            return response
        end

        local rewardFlag = 8
        activeInfo.rd = activeInfo.rd or 0
        if isFlagSet(activeInfo.rd,rewardFlag) then
            response.ret = -1976 -- 物品已领取
            return response
        end

        activeInfo.rd = setFlag(activeInfo.rd,rewardFlag)

        -- 领奖
        if not takeReward(uid, activeCfg.gift4) then
            response.ret = -1989
            return response
        end

        regEventAfterSave(aid,'saveAllianceActive')
        if uobjs.save() then
            processEventsAfterSave()
            response.data[self.aname] = mergeData(activeInfo,activeObj.activeInfo)

            response.ret = 0
            response.msg = 'Success'
        end

        return response
    end

    function self.action_rechargeReward(request)
        local response = self.response
        local uid = request.uid
        local num = request.params.num

        local uobjs = getUserObjs(uid)
        local mUseractive = uobjs.getModel('useractive')
        local activeInfo = mUseractive.info[self.aname]
        local activeCfg = mUseractive.getActiveConfig(self.aname)

        activeInfo.gem = activeInfo.gem or 0
        local leftGem = activeInfo.gem - activeCfg.rechargeNum * (activeInfo.tn or 0)
        if leftGem < activeCfg.rechargeNum then
            response.ret = -1981
            return response
        end
        
        local n = math.floor(leftGem/activeCfg.rechargeNum)
        if n ~= num or n <= 0 then
            response.err = n
            response.ret = -1981
            return response
        end

        activeInfo.tn = (activeInfo.tn or 0) + n

        local reward = {}
        for k,v in pairs(activeCfg.recharge2) do
            reward[k] = v * n
        end

        mUseractive.setActive(self.aname,{act="takeReward",reward=reward})

        if uobjs.save() then
            processEventsAfterSave()
            response.data[self.aname] = activeInfo

            response.ret = 0
            response.msg = 'Success'
        end

        return response
    end

    function self.action_buy(request)
        local response = self.response
        local uid = request.uid

        local uobjs = getUserObjs(uid)
        local mUseractive = uobjs.getModel('useractive')
        local activeCfg = mUseractive.getActiveConfig(self.aname)

        if activeCfg.cost < 10 then
            response.ret = -102
            return response
        end

        local mUserinfo = uobjs.getModel('userinfo')
        if not mUserinfo.useGem(activeCfg.cost) then
            response.ret = -109 
            return response
        end

        -- 愚人节大作战买礼包
        regActionLogs(uid,1,{action=215,item="",value=activeCfg.cost,params={}})

        mUseractive.setActive(self.aname,{act="takeReward",reward=activeCfg.recharge1})

        if uobjs.save() then
            processEventsAfterSave()
            response.data[self.aname] = mUseractive.info[self.aname]

            response.ret = 0
            response.msg = 'Success'
        end

        return response
    end
    
    return self
end

return api_active_foolday2018
