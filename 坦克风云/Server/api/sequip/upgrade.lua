-- 装备进阶 advance
function api_sequip_upgrade(request)
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

    if moduleIsEnabled('sequip') == 0 then
        response.ret = -11000
        return response
    end
    
    local uobjs = getUserObjs(uid)
    uobjs.load({"userinfo", "sequip", "bag"})
    local mSequip = uobjs.getModel('sequip')
    local mUserinfo = uobjs.getModel('userinfo')
    local mBag = uobjs.getModel('bag')

    --活动全局数据
    local active_color, active_num = nil, nil

    local self = {}
    --进阶指定装备
    function self.upgradebyid(elist, useGems)
        local equipcfg = getConfig('superEquipListCfg.equipListCfg')
        local color = nil
        local getnum = 0
        local itemlog = {} --消耗日志
        --消耗装备
        for eid, num in pairs(elist) do
            if not equipcfg[eid] then return false end
            if not color then 
                color = equipcfg[eid].color
            elseif color and color ~= equipcfg[eid].color then --品阶不同
                return false, -400
            end
            if not mSequip.consumeEquip(eid, num) then 
                return false, -402
            end
            getnum = getnum + num
            itemlog[eid] = (itemlog[eid] or 0) + num
        end

        local cfg = getConfig('superEquipCfg')
        if color > cfg.upgrade.maxupcolor then --最大品阶
            return false, -404
        end
        if getnum % cfg.upgrade.equipnum ~= 0 then return false end --整数倍
        getnum = getnum / cfg.upgrade.equipnum

        --消耗道具
        local consume = copyTab( cfg.upgrade.prop[color] )
        local gemCost = 0
        local propCfg = getConfig('prop')
        for k, v in pairs(consume) do
            consume[k] = v * getnum

            --钻石补充
            local haditem = mBag.getPropNums(k)
            local costcnt = consume[k]
            if costcnt > haditem then
                gemCost = gemCost + propCfg[k].gemCost * ( costcnt - haditem) --不够钻石补
                costcnt = haditem --扣掉所以物品
            end

            if costcnt>0 and not mBag.use(k, costcnt) then
                return false, -1996
            end

            itemlog[k] = (itemlog[k] or 0) + costcnt
        end

        -- 消耗钻石
        if gemCost > 0 and (not useGems or not mUserinfo.useGem(gemCost) ) then
            return false, -109
        end

        if gemCost > 0 then
            regActionLogs(uid,1,{action=1003,item="",value=gemCost,params=itemlog })
        end

        active_color = color+1
        active_num = getnum

        return mSequip.upgradeEquip(color+1, getnum)
    end

    -----------main
    local action = request.params.action or 1
    local elist = request.params.elist
    local useGems = request.params.useGems

    local ret, code = nil, nil
    if action == 1 then
        ret, code = self.upgradebyid(elist, useGems)
    end

    if not ret then
        response.ret = code
        return response
    end

    -- 疯狂进阶
    activity_setopt(uid,'superEquipEvent',{color=active_color, num=active_num})
    -- 全线突围活动埋点
    activity_setopt(uid, 'qxtw', {action=4,num=active_num})

    regEventBeforeSave(uid,'e1')
    processEventsBeforeSave()
    if uobjs.save() then 
        processEventsAfterSave()
        response.data.reward = formatReward( code )
        response.data.sequip = mSequip.toArray(true)
        response.ret = 0        
        response.msg = 'Success'
    end

    return response

end
