-- 神秘海域探索
function api_alienweapon_seaexplore(request)
    local response = {
        ret=-1,
        msg='error',
        data = {},
    }

    local uid = request.uid
    if uid == nil then
        response.ret = -102
        return response
    end

    if moduleIsEnabled('alienweapon') == 0 then
        response.ret = -11000
        return response
    end

    local uobjs = getUserObjs(uid)
    uobjs.load({"userinfo", "alienweapon"})
    local mAweapon = uobjs.getModel('alienweapon')
    local mUserinfo = uobjs.getModel("userinfo")

    local cfg = getConfig("alienWeaponSecretSeaCfg")
    local weeTs = getWeeTs()

    local self = {}
    --进入海域
    function self.seaEnter(chapter, ntype)
        -- body
        if type(mAweapon.sinfo.sea) == 'table'  then
            return false, -12016
        end

        local currCid = (chapter-1)*cfg.difficult + ntype -- 章节id * 关卡数 + 关卡id
        if not mAweapon.checkUnlock(currCid) then -- 未解锁该章节s
            return false, -12013
        end
        if cfg.maxChapter < chapter then -- 章节上限
            return false, -12017
        end
        if cfg.difficult < ntype then -- 难度上限
            return false, -12014
        end

        if not mAweapon.seaEnter(chapter, ntype) then
            return false, -12015
        end

        return true
    end

    --探索当前海域
    function self.seaExplore(nIndex, useGems)
        -- 没进入海域 or 已经探索了
        if not tonumber(nIndex) or not mAweapon.sinfo.sea or not mAweapon.sinfo.sea.l[nIndex] or 
            mAweapon.sinfo.sea.l[nIndex] > 0 then
            return false, -12018
        end

        -- 探索次数不足
        if not self.checkAndBuyExploreNum(useGems) then
            return false, -12019
        end

        -- 探索
        local alltarget = 0
        for k, v in pairs(mAweapon.sinfo.sea.l) do
            if v == 0 then
                alltarget = alltarget + 1
            end
        end
        local isReward = true
        if mAweapon.sinfo.sea.boss == 0 then
            local isBoss = rand(1, alltarget) <= 1
            if isBoss then
                mAweapon.sinfo.sea.boss = 1 -- 发现boss未击败标记
                mAweapon.sinfo.sea.l[nIndex] = 2 -- 发现boss位置
                isReward = false -- 击败boss后发奖
            else
                mAweapon.sinfo.sea.l[nIndex] = 1 -- 平安 
            end
        else
            mAweapon.sinfo.sea.l[nIndex] = 1 -- 平安 
        end

        local exp = 0
        if isReward == true then
            exp = cfg.exp.normal[mAweapon.sinfo.sea.type][mAweapon.sinfo.sea.chap] -- [难度][章节]
            mAweapon.changeExp(exp)
        end

        return true, exp
    end

    -- 检测次数
    function self.checkAndBuyExploreNum(useGems)
        if type(mAweapon.sinfo.enum) ~= 'table' or mAweapon.sinfo.enum[3] < weeTs then
            mAweapon.sinfo.enum ={cfg.freeNum, 0, weeTs} -- {剩余探索次数, 购买的次数,  重置时间戳}
        end

        mAweapon.sinfo.enum[1] = mAweapon.sinfo.enum[1] - 1 --扣次数

        if mAweapon.sinfo.enum[1] >= 0 then -- 免费次数直接通过
            return true
        end
        if not useGems then -- 消耗钻石前端传个标志
            return false
        end

        local maxnum = cfg.num[mUserinfo.vip+1] -- vip1开始的购买次数
        if mAweapon.sinfo.enum[2] > maxnum then
            return false
        end
        mAweapon.sinfo.enum[2] = mAweapon.sinfo.enum[2] + 1 -- 购买次数累计

        local gemCost = cfg.exploreNumCost[ mAweapon.sinfo.enum[2] ]
        if not mUserinfo.useGem(gemCost) then
            return false
        end

        mAweapon.sinfo.enum[1] = mAweapon.sinfo.enum[1] + cfg.buyNum -- 购买了加上次数

        -- 日志
        regActionLogs(uid,1,{action=160,item="explorenum",value=gemCost,params={}})

        return true
    end

    -- 领取章节奖励
    function self.getReward()
        -- 待领奖状态
        if not mAweapon.checkPassSea(mUserinfo.level) then
            return false, -12023
        end

        local reward = copyTable(cfg.doneReward[tonumber(mAweapon.sinfo.sea.chap)][tonumber(mAweapon.sinfo.sea.type)])
        -- 判断宝石系统开关 玩家等级是否满足条件 (这个配置里面有宝石)
        if moduleIsEnabled("jewelsys") == 1  then
            local jewelCfg = getConfig("alienjewel")
            if mUserinfo.level >= jewelCfg.others['unlocklevel'] then
                reward = copyTable(cfg.doneReward2[tonumber(mAweapon.sinfo.sea.chap)][tonumber(mAweapon.sinfo.sea.type)])
                writeLog('使用了宝石随机配置 uid:'..mUserinfo.uid..'level:'..mUserinfo.level,'jewelreward')
            end
        end

        reward = getRewardByPool(reward)
        if not takeReward(uid, reward) then
            return false, 12024
        end

        --退出海域
        mAweapon.seaExit()

        return true , formatReward(reward)
    end

    -- 重置
    function self.init()
        if type(mAweapon.sinfo.enum) ~= 'table' or mAweapon.sinfo.enum[3] < weeTs then
            mAweapon.sinfo.enum ={cfg.freeNum, 0, weeTs} -- {剩余探索次数, 购买的次数,  重置时间戳}
        end
	
	-- 修复等级到了大海域关卡未解锁的问题
        -- unlock记录的是解锁的关卡,如果攻击的时候用户角色等级没有达到关卡要求，unlock就不会+1（变为下一海域）
        -- 当等级够的时候需要修复
        -- unlock 是记录的当前解锁的进度或下一进度(有可能等级卡住就是当前进度,没卡住就是下一进度)
        -- psea第一位是BOSSID,与unlock相同
        -- psea第二位是攻击次数,必需达到当前关卡要求的攻击次数才能解锁
        if type(mAweapon.sinfo) == "table" then
            local seaCfg = getConfig("alienWeaponSecretSeaCfg")
            local level2Key = 0
            for k,v in pairs(seaCfg.unlockLevel) do
                if mUserinfo.level >= v then
                    level2Key = k
                end
            end
            
            if level2Key > 1 then
                local level2unlock = (level2Key-1)*cfg.difficult
                -- sinfo: {"enum":[4,5,1502208000],"unlock":4,"psea":[4,5]}
                -- {"psea":[3,4],"unlock":3,"enum":[2,8,1504540800]}
                if mAweapon.sinfo.unlock and mAweapon.sinfo.psea then
                    if level2unlock == mAweapon.sinfo.unlock and mAweapon.sinfo.psea[1] == level2unlock and mAweapon.sinfo.psea[2] >= seaCfg.unlockAttackNum[level2Key-1] then
                        mAweapon.sinfo.unlock = mAweapon.sinfo.unlock + 1
                        mAweapon.sinfo.psea = nil
                    end
                end
            end
        end

        return true
    end

    local action = request.params.action
    local ntype = request.params.type
    local cid = request.params.cid 
    local chapter = request.params.chapter
    local useGems = request.params.useGems
    local ret, code = nil, nil
    if action == 1 then
        ret, code = self.seaEnter(chapter, ntype) -- 进入章节(章节，难度)
    elseif action == 2 then
        ret, code = self.seaExplore(cid, useGems) -- 探索(关卡id, 是否花费钻石 )
        --日常任务
        local mDailyTask = uobjs.getModel('dailytask')
        mDailyTask.changeTaskNum1('s1013')
        -- 活动：异星任务
        activity_setopt(uid,'alientask',{t='y3',n=1,w=1})
        -- 跨服战资比拼
        zzbpupdate(uid,{t='f11',n=1})

        -- 国庆七天乐
        activity_setopt(uid,'nationalday2018',{act='tk',type='ts',num=1})  
        -- 感恩节拼图
        activity_setopt(uid,'gejpt',{act='tk',type='ts',num=1})

    elseif action == 3 then
        ret, code = mAweapon.seaExit() -- 退出海域
    elseif action == 4 then
        ret, code = self.getReward() -- 领取章节奖励
    elseif action == 5 then -- 重置
        ret, code = self.init()
    end

    if not ret then
        response.ret = code
        return response
    end

    if uobjs.save() then
        if action == 2 then
            response.data.addexp=code
        end
        if action == 4 then
            response.data.reward=code
        end
        response.data.alienweapon = {sinfo = mAweapon.sinfo}
        response.ret = 0
        response.msg = 'Success'
    end

    return response

end
