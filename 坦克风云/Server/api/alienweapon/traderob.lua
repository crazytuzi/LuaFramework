-- 护航抢夺信息
function api_alienweapon_traderob(request)
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

    local ts = getClientTs()
    local cfg = getConfig("alienWeaponTradingCfg")
    local self = {}

    -- 刷新抢夺列表
    function self.refmyroblist()
        mAweapon.incrRobListnum() 
        local gemCost = cfg.robCost[mAweapon.tinfo.rlsnum] or cfg.robCost[#cfg.robCost]
        if not mUserinfo.useGem(gemCost) then
            return false, -109
        end

        regActionLogs(uid,1,{action=160,item="refroblist",value=gemCost,params={}})

        return self.robdetail(true)
    end

    -- 抢夺详细信息
    function self.robdetail(ref)
        if not mAweapon.tinfo.rls or ref == true then
            mAweapon.refRoblist()
        end

        local detail = {}
        local npcids = {} --NPC查数据库
        for _, id in pairs(mAweapon.tinfo.rls) do
            local target = id:split("_")
            if target[1] == 'npc' then
                table.insert(npcids, target[2])
            end
        end

        local npcdata = {}
        if next(npcids) then --找到NPC数据
            local sql = "select * from alienweaponpc where id in (" .. table.concat(npcids,',') .. ")"
            local result = getDbo():getAllRows(sql)
            if type(result) == 'table' then
                for k, v in pairs(result) do
                    npcdata[tonumber(v.id)] = v
                end
            end
        end

        for _, id in pairs(mAweapon.tinfo.rls) do
            local target = id:split("_")
            local ret = nil
            if target[1] == 'npc' then
                local nid = tonumber(target[2])
                local level = tonumber(npcdata[nid].level)
                local slot = tonumber(npcdata[nid].slot)
                local rw = json.decode( npcdata[nid].sr )
                ret = {
                    id, -- 航队唯一标识
                    id, -- NPC名称 通过id关联
                    level, -- 等级
                    slot, -- 任务品质 配置的索引就是品质 注意！
                    json.decode( npcdata[nid].troops ), --带出的部队
                    self.robAward(slot, rw), --可以抢到的奖励
                    npcdata[nid].fc, --战斗力
                    id, --头像
                    '', --所属军团
                }
            else
                local playerid = tonumber(target[1])
                local slot = tonumber(target[2])
                local pobjs = getUserObjs(playerid)
                local pAweapon = pobjs.getModel('alienweapon')
                local pUserinfo = pobjs.getModel('userinfo')

                -- 玩家数据过期了 再刷新一次
                if not ref and ( not pAweapon.trade[slot].et or pAweapon.trade[slot].rob == 1 or pAweapon.trade[slot].et - ts<10) then
                    -- 发现过期的数据，检查缓存
                    local redis = getRedis()
                    local globalkey = 'z' .. getZoneId() .. ".aweapon.roblistuid"
                    redis:zrem(globalkey, target)
                    return self.robdetail(true)
                end
                local troops = {}
                for k, v in pairs(pAweapon.trade[slot].troops or {}) do
                    if next(v) then
                        troops[v[1]] = (troops[v[1]] or 0 ) + v[2]
                    end
                end
                ret = {
                    id, -- 航队唯一标识
                    pUserinfo.nickname, -- 玩家名称
                    pUserinfo.level, -- 等级
                    pAweapon.trade[slot].tid, --任务品质
                    pAweapon.trade[slot].troops or {}, --带出的部队
                    self.robAward(pAweapon.trade[slot].tid, pAweapon.trade[slot].r), --可以抢到的奖励
                    refreshFighting(playerid, troops), --部队战斗力
                    pUserinfo.pic, -- 头像
                    pUserinfo.alliancename, -- 军团
                }
            end

            table.insert(detail, ret)
        end

        return true , detail
    end

    -- 可以抢到的奖励 随机奖励一半，基础宝箱一个
    function self.robAward(slot, reward)
        local ret = {}
        for k, v in pairs(reward) do
            ret[k] = math.floor(v / 2)
        end
        for k, v in pairs(cfg.tradereward[slot].base) do
            ret[k] = (ret[k] or 0) + 1
        end

        return formatReward(ret)
    end

    --护航记录  刷新任务
    local action = request.params.action
    local ret, code = nil, nil
    if action == 1 then
        ret, code = self.refmyroblist() -- 刷新抢夺列表
    elseif action == 3 then
        ret, code = self.robdetail() -- 抢夺对象详细信息
    end

    if not ret then
        response.ret = code
        return response
    end

    if uobjs.save() then
        response.data.roblist = code
        response.data.alienweapon = mAweapon.toArray()
        response.ret = 0
        response.msg = 'Success'
    end

    return response

end
