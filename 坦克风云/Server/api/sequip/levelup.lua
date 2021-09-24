-- 装备升级
function api_sequip_levelup(request)
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
    
    local weeTs = getWeeTs()

    local uobjs = getUserObjs(uid)
    uobjs.load({"userinfo", "sequip"})
    local mSequip = uobjs.getModel('sequip')
    local mUserinfo = uobjs.getModel('userinfo')
    local mBag = uobjs.getModel('bag')

    local self = {}
    function self.upbyid(eid, num, useGems)
        num = tonumber(num) or 1

        local equipcfg = getConfig('superEquipListCfg.equipListCfg')
        if not equipcfg[eid].lvTo then
            return false, -405
        end

        local version  =getVersionCfg()
        local upgradeMaxLv = nil -- 版本控制 升级最高上限
        if equipcfg[eid].color == 4 then -- 紫色
            upgradeMaxLv = tonumber(version.unlockEmblemLevel1)
        elseif equipcfg[eid].color == 5 then --橙色
            upgradeMaxLv = tonumber(version.unlockEmblemLevel2)
        end

        if upgradeMaxLv and upgradeMaxLv <= equipcfg[eid].lv then 
            return false, -406
        end

        local gemCost = 0
        local itemlog = {} -- 消耗日志
        local propCfg = getConfig('prop')

        local consume = copyTab( equipcfg[eid].upCost)
        for k, v in pairs(consume) do
            consume[k] = v * num

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
            itemlog[k] = (itemlog[k] or 0 ) + costcnt
        end

        if gemCost > 0 and (not useGems or not mUserinfo.useGem(gemCost) ) then
            return false, -402
        end

        --消耗装备
        if not mSequip.consumeEquip(eid, num) then 
            return false, -402
        end
        itemlog[eid] = (itemlog[eid] or 0 ) + num

        --获得高等级装备
        local new_eid = equipcfg[eid].lvTo
        if not equipcfg[new_eid] then
            return false, -404
        end

        if gemCost > 0 then
            regActionLogs(uid,1,{action=1002,item=new_eid,value=gemCost,params=itemlog})
        end

        return mSequip.levelupEquip(new_eid, num)
    end

    -----------main
    local action = request.params.action or 0
    local eid = request.params.eid
    local cnt = tonumber( request.params.count ) or 1
    local useGems = request.params.useGems
    local ret, code = nil, nil

    if action == 0 then
        ret, code = self.upbyid(eid, cnt, useGems)
    end

    if not ret then
        response.ret = code
        return response
    end
    
    -- 全线突围活动埋点
    activity_setopt(uid, 'qxtw', {action=5,num=cnt})

    regEventBeforeSave(uid,'e1')
    processEventsBeforeSave()
    if uobjs.save() then 
        processEventsAfterSave()
        response.data.reward = code
        response.data.sequip = mSequip.toArray(true)
        response.data.bag = mBag.toArray(true)
        response.ret = 0        
        response.msg = 'Success'
    end

    return response

end
