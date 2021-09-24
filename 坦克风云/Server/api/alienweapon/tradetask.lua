-- 护航任务信息
function api_alienweapon_tradetask(request)
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
    local mUserinfo = uobjs.getModel('userinfo')
    local mTroop = uobjs.getModel('troops')
    local mHero = uobjs.getModel('hero')
    local mSequip = uobjs.getModel('sequip')

    local cfg = getConfig("alienWeaponTradingCfg")

    local self = {}
    -- 刷新护航列表(品质)
    function self.reftask()
        -- 刷新消耗
        if not mAweapon.incrAttackListnum() then
            return false, -12015
        end

        local gemCost = cfg.cost[mAweapon.tinfo.lsnum]
        if not mUserinfo.useGem(gemCost) then
            return false, -109
        end

        return true, mAweapon.refTradelist()
    end

    -- 初始化护航
    function self.init()
        -- 没有数据的时候初始化
        if not mAweapon.trade or not next(mAweapon.trade) then
            mAweapon.refTradelist()
        end
        -- 重置时间
        mAweapon.checkreset()
        -- 日志数
        local battlelogLib=require "lib.battlelog"
        local unreadlogs = {
            [1] = battlelogLib:logAweaponHasUnread(uid, 1),
            [2] = battlelogLib:logAweaponHasUnread(uid, 2),
         }
        return true, unreadlogs
    end

    -- 贸易领奖
    function self.getreward(slot)
        -- 护航结束
        if not mAweapon.checkTaskOver(slot) then
            return false, -1981
        end

        -- 发奖
        local reward = mAweapon.trade[slot].r
        local tid = tonumber(mAweapon.trade[slot].tid)
        local robed = mAweapon.trade[slot].rob == 1 and -1 or 0 -- 如果被抢了扣掉一个
        for k, v in pairs( cfg.tradereward[tid].base ) do
            reward[k] = (reward[k] or 0) + v + robed
        end

        if not takeReward(uid, reward) then
            return false, -403
        end

        -- 舰队正常返回，并清除数据
        if not mAweapon.fleetback(slot) then
            return false, -12015
        end

        -- 异星任务
        activity_setopt(uid,'alientask',{t='y1',n=1,p=0,w=1})
        activity_setopt(uid,'alientask',{t='y4',n=1,p=tid,w=1})        
        
        -- 岁末回馈
        activity_setopt(uid,'feedback',{act='hh',num=1})
        -- 跨服战资比拼
        zzbpupdate(uid,{t='f12',n=1,id=tid})

        -- 节日花朵
        activity_setopt(uid,'jrhd',{act="tk",id="hh",num=1})

        -- 感恩节拼图
        activity_setopt(uid,'gejpt',{act='tk',type='hh',num=1})

        return true, reward
    end

    -- 中途放弃任务
    function self.giveup(slot)
        if not mAweapon.trade[slot].st then -- 没有这任务 ?
            return false, -12016
        end

        if not mAweapon.fleetback(slot) then
            return false, -12015
        end

        return true
    end

    --护航记录  刷新任务
    local action = request.params.action
    local slot = request.params.id
    local ret, code = nil, nil
    if action == 1 then
        ret, code = self.reftask() -- 刷新任务列表
    elseif action == 5 then
        ret, code = self.init() -- 初始化任务列表
    elseif action == 6 then
        ret, code = self.getreward(slot) -- 任务领奖
    elseif action == 7 then
        ret, code = self.giveup(slot) -- 任务放弃
    end

    if not ret then
        response.ret = code
        return response
    end

    if uobjs.save() then
        if action == 6 then
            response.data.reward = formatReward(code)
        end
        if action == 6 or action == 7 then
            response.data.troops = mTroop.toArray(true)
            response.data.hero = {stats = mHero.stats}
            response.data.sequip = {stats = mSequip.stats}
        end
        if action == 5 then
            response.data.unread = code
        end
        response.data.alienweapon = mAweapon.toArray()
        response.ret = 0
        response.msg = 'Success'
    end

    return response

end
