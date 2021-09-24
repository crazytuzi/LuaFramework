--
-- 脱光行动
-- User: luoning
-- Date: 14-10-29
-- Time: 下午4:36
--
function api_active_singles(request)

    local aname = 'singles'
    local response = {
        ret=-1,
        msg='error',
        data = {
            [aname] = {},
        },
    }

    local uid = request.uid
    local action = request.params.action
    if uid == nil and action == nil then
        response.ret = -102
        return response
    end

    local uobjs = getUserObjs(uid)
    uobjs.load({"userinfo", "techs", "troops", "props","bag","skills","buildings",'useractive'})
    local mUseractive = uobjs.getModel('useractive')
    local mUserinfo = uobjs.getModel('userinfo')
    local mTroops,reward

    -- 活动检测
    local activStatus = mUseractive.getActiveStatus(aname)
    if activStatus ~= 1 then
        response.ret = activStatus
        return response
    end

    local activeCfg = getConfig("active." .. aname .. "."..mUseractive.info[aname].cfg)
    local addMm = function(old, reward)
        if type(old) ~= 'table' then
            old = {}
        end
        for type, num in pairs(reward) do
            if not old[type] then
                old[type] = 0
            end
            old[type] = old[type] + num
        end
        return old
    end
    --初始化记录兑换的数据
    if type(mUseractive.info[aname].v) ~= 'table' then
        mUseractive.info[aname].v = {}
    end

    --每日领奖
    if action == 'daily' then

        local weelTs = getWeeTs()

        if mUseractive.info[aname].t >= weelTs then
            response.ret = -402
            return response
        end

        local vipCfg = activeCfg.vipReward
        local userVip = mUserinfo.vip
        local reward = {}
        for _, v in pairs(vipCfg) do
            if userVip >= v[1] then
                reward = v[2]
                break
            end
        end
        mUseractive.info[aname].mm = addMm(mUseractive.info[aname].mm, reward)
        mUseractive.info[aname].t = weelTs

    --抽奖
    elseif action == 'rank' then

        local weelTs = getWeeTs()
        --必须先领取代币券
        if mUseractive.info[aname].t < weelTs then
            return response
        end

        local num = tonumber(request.params.num) or 1
        local payCostNum = num == activeCfg.mul and activeCfg.mulc or 1
        local costGem = payCostNum * activeCfg.cost
        if costGem < activeCfg.cost or not mUserinfo.useGem(costGem) then
            response.ret = -109
            return response
        end

        local pool = activeCfg.serverreward.pool
        local rankItem = function(pool, num)
            local reward = {}
            local mmItem = {}
            local clientReward = {}
            for i=1, num do
                local poolReward = getRewardByPool(pool)
                for type, num in pairs(poolReward) do
                    local tTable = type:split('_')
                    if tTable[1] == 'mm' then
                        if not mmItem[type] then
                            mmItem[type] = 0
                        end
                        mmItem[type] = mmItem[type] + num
                        table.insert(clientReward, {tTable[1],type,num})
                    else
                        if not reward[type] then
                            reward[type] = 0
                        end
                        reward[type] = reward[type] + num
                        local tmpPrefix = string.sub(type, 1, 1)
                        if tmpPrefix == 't' then tmpPrefix = 'o' end
                        if tmpPrefix == 'a' then tmpPrefix = 'e' end
                        table.insert(clientReward, {tmpPrefix,tTable[2],num})
                    end
                end
            end
            return reward, mmItem, clientReward
        end

        local reward, mmItem, clientReward = rankItem(pool, num)
        if next(reward) and not takeReward(uid, reward) then
            return response
        end

        regActionLogs(uid,1,{action=45,item="",value=costGem,params={buyNum=num,reward=reward,mmItem=mmItem}})

        if next(mmItem) then
            mUseractive.info[aname].mm = addMm(mUseractive.info[aname].mm, mmItem)
        end
        response.data.clientReward = clientReward

    --商店
    elseif action == 'shop' then

        local item = request.params.item
        local shopCfg = activeCfg.shopItem
        local cfgItem = tonumber(string.sub(item, 2))
        if not shopCfg[cfgItem] then
            response.ret = -102
            return response
        end

        if not mUseractive.info[aname].v[item] then
            mUseractive.info[aname].v[item] = 0
        end

        if mUseractive.info[aname].v[item] >= shopCfg[cfgItem].buynum then
            return response
        end

        local costMM = shopCfg[cfgItem].price
        local reward = shopCfg[cfgItem].serverReward
        local mm = type(mUseractive.info[aname].mm) == 'table' and mUseractive.info[aname].mm or {}

        for type, num in pairs(costMM) do
            if not mm[type] or mm[type] < num then
                return response
            end
            mm[type] = mm[type] - num
        end
        mUseractive.info[aname].mm = mm
        mUseractive.info[aname].v[item] = mUseractive.info[aname].v[item] + 1
        if not takeReward(uid, reward) then
            return response
        end
    end

    if uobjs.save() then
        response.ret = 0
        response.msg = "Success"
    end

    return response
end

