-- 一周年周年庆活动
-- @params action 0.获取活动数据【可用于凌晨刷新】 1.兑换集字奖励 2.领取戎马生涯奖励 3.领取充值奖励
-- @params id 目标id(兑换时是兑换目标的id)
function api_active_anniversary(request)
    local response = {
        ret = -1,
        msg = 'error',
        data = {},
    }

    local uid = request.uid
    local action = tonumber(request.params.action) or 0
    local tid = tonumber(request.params.id) or 1
    local aname = 'anniversary'

    if not uid or not action then
        response.ret = -102
        return response
    end

    local uobjs = getUserObjs(uid)
    uobjs.load({'userinfo','useractive','bag','troops','accessory','hero','friends'})
    local mUseractive = uobjs.getModel('useractive')
    local mUserinfo = uobjs.getModel('userinfo')
    local mTroops = uobjs.getModel('troops')
    local mAccessory = uobjs.getModel('accessory')
    local mBag = uobjs.getModel("bag")
    local mHero = uobjs.getModel('hero')
    local activStatus = mUseractive.getActiveStatus(aname)

    -- 活动检测
    if activStatus ~= 1 then
        response.ret = activStatus
        return response
    end

    -- 活动数据
    local weeTs = getWeeTs()
    local actinfo = mUseractive.info[aname]
    local actCfg = mUseractive.getActiveConfig(aname)

    -- 处理戎马生涯数据
    local function buildCareerInfo()
        local carinfo = {}
        
        -- 1.注册时间
        carinfo[1] = {mUserinfo.regdate}
        
        -- 2.加入军团时间和军团名称
        local adt = 0
        local execRet,code = M_alliance.getalliance{uid=uid,aid=mUserinfo.alliance,acallianceLevel=1}
        if execRet and execRet.data then
            adt = tonumber(execRet.data.join_at) or 0
        end
        carinfo[2] = {adt, mUserinfo.alliancename}
        
        -- 3.军功
        carinfo[3] = {mUserinfo.rp}
        
        -- 4.好友数
        local mFriends = uobjs.getModel('friends')
        carinfo[4] = {#mFriends.info}
        
        -- 5.游戏时长
        carinfo[5] = {mUserinfo.olt}
        
        return carinfo
    end

    -- 检查活动是否初始化或者隔天刷新数据
    local function checkActive()
        local crossDay = false
        -- 判断是否需要初始化
        if not actinfo or type(actinfo) ~= 'table' then
            actinfo = {}
        end
        
        -- 判断是否需要隔天重置
        if not tonumber(actinfo.t) or tonumber(actinfo.t) < weeTs then
            crossDay = true
        end

        -- 初始化
        if not actinfo.tbuy then
            actinfo.tbuy = {} -- 活动期间道具兑换总信息
        end
        
        if not actinfo.carprz then
            actinfo.carprz = {} -- 一周年记录奖励信息
        end

        -- 隔天重置
        if crossDay then
            actinfo.cnum = 0 -- 今日充值钻石数
            actinfo.cprz = 0 -- 重置充值奖励状态(0未达成 1可领取 2已领取)
            actinfo.t = weeTs -- 最后刷新时间
        end
        
        -- 初始化戎马生涯数据
        if not actinfo.carinfo or not actinfo.carinfot or actinfo.st ~= actinfo.carinfot then
            actinfo.carinfo = buildCareerInfo()
            actinfo.carinfot = actinfo.st
        end

        -- 重新设定活动数据
        mUseractive.info[aname] = actinfo
        return true
    end

    -- 兑换集字奖励
    local function getWordPrz(needCheck)
        -- 先检查活动
        if needCheck then
            checkActive()
        end

        tid = tostring(tid)

        -- 先找到要兑换的商品
        local shopItem
        for _,v in pairs(actCfg.exchange) do
            if tid == tostring(v.id) then
                shopItem = v
                break
            end
        end

        -- 商品不存在
        if not shopItem then
            response.ret = -102
            return false
        end

        -- 判断总兑换上限
        local tbuyNum = actinfo.tbuy[tid] or 0
        if tonumber(shopItem.maxLimit) and tbuyNum >= tonumber(shopItem.maxLimit) then
            response.ret = -102
            return false
        end

        -- 判断玩家道具数量足够并进行消耗
        if not mBag.usemore(shopItem.severprice) then
            response.ret = -1996
            return false
        end

        -- 增加对应奖励
        if not takeReward(uid, shopItem.serverReward) then
            response.ret = -403
            return false
        end

        -- 记录购买
        tbuyNum = tbuyNum + 1
        actinfo.tbuy[tid] = tbuyNum

        response.data.reward = formatReward(shopItem.serverReward)
        response.data.bag = mBag.toArray(true)
        return true
    end
    
    local function getRecordPrz(needCheck)
        -- 先检查活动
        if needCheck then
            checkActive()
        end
        
        -- 奖励配置
        local przCfg = actCfg.career[tonumber(tid)]
        if not przCfg then
            response.ret = -102
            return false
        end
        
        -- 判断是否已经领取过
        if actinfo.carprz[tostring(tid)] then
            response.ret = -102
            return false
        end
        
        -- 领取奖励
        if not takeReward(uid, przCfg.serverReward) then
            response.ret = -403
            return false
        end
        
        actinfo.carprz[tostring(tid)] = tid

        response.data.reward = formatReward(przCfg.serverReward)
        return true
    end

    -- 领取充值奖励
    local function getChargePrz(needCheck)
        -- 先检查活动
        if needCheck then
            checkActive()
        end
        
        local chargeCfg = actCfg.costMoney[1]
        
        -- 判断今日充值额度
        if actinfo.cnum < chargeCfg.needNum then
            response.ret = -102
            return false
        end
        
        -- 判断今日是否已经领取
        if 1 ~= actinfo.cprz then
            response.ret = -102
            return false
        end
        
        -- 领取奖励
        if not takeReward(uid, chargeCfg.serverReward) then
            response.ret = -403
            return false
        end
        
        actinfo.cprz = 2

        response.data.reward = formatReward(chargeCfg.serverReward)
        return true
    end

    -- 操作处理器
    local actionFunc = {
        ['0'] = checkActive, -- 检查活动是否初始化或者隔天刷新数据
        ['1'] = getWordPrz, -- 兑换集字奖励
        ['2'] = getRecordPrz, -- 领取戎马生涯奖励
        ['3'] = getChargePrz, -- 领取充值奖励
    }

    -- 根据action 调用不同的操作函数
    local flag = actionFunc[tostring(action)](true)

    -- 数据返回
    if uobjs.save() and flag then
        response.data[aname] = mUseractive.info[aname]
        response.ret = 0
        response.msg = 'Success'
    end

    return response
end
