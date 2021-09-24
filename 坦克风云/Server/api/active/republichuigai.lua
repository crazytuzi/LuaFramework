--
-- 共和国光辉国庆活动
-- User: luoning
-- Date: 14-9-12
-- Time: 下午3:43
--
function api_active_republichuigai(request)

    local response = {
        ret=-1,
        msg='error',
        data = {},
    }

    local uid = request.uid
    local action = request.params.action

    if uid == nil then
        response.ret = -102
        return response
    end

    -- 活动名称
    local aname = 'republicHuiGai'

    local uobjs = getUserObjs(uid)
    uobjs.load({"userinfo", "techs", "troops", "props","bag","skills","buildings",'useractive'})
    local mUseractive = uobjs.getModel('useractive')
    local mUserinfo = uobjs.getModel('userinfo')
    local mTroops,reward

    local activStatus = mUseractive.getActiveStatus(aname)

    -- 活动检测
    if activStatus ~= 1 then
        response.ret = activStatus
        return response
    end

    local activeCfg = getConfig("active."..aname)
    --随机奖励
    local getMultiRand = function(serverrewardCfg, location, freeType, activeReward)

        if location < 1 then
            location = 1
        end
        setRandSeed()
        local numTab = {
            rand(serverrewardCfg.saizi[1][1], serverrewardCfg.saizi[1][2]),
            rand(serverrewardCfg.saizi[2][1], serverrewardCfg.saizi[2][2]),
        }

        local totalNum = numTab[1] + numTab[2]
        local tmpCfg = serverrewardCfg.pool
        local tmpCfg2 = serverrewardCfg.pool
        for i = 1, #tmpCfg2 do
            table.insert(tmpCfg, tmpCfg2[i])
        end

        local propReward = {}
        local tmpReward = {}
        local tmpLocation = location + totalNum

        for i = location + 1, tmpLocation do
            for type, num in pairs(tmpCfg[i]) do
                local tmpData = type:split("_")
                if freeType == 1 or (freeType == 0 and i == tmpLocation) then
                    if tmpData[1] == 'mm' then
                        if tmpReward[tmpData[2]] then
                            tmpReward[tmpData[2]] = tmpReward[tmpData[2]] + num
                        else
                            tmpReward[tmpData[2]] = num
                        end
                    else
                        if propReward[type] then
                            propReward[type] = propReward[type] + num
                        else
                            propReward[type] = num
                        end
                    end
                end
            end
        end

        if type(activeReward) ~= 'table' then
            activeReward = tmpReward
        else
            for type, num in pairs(tmpReward) do
                if activeReward[type] then
                    activeReward[type] = activeReward[type] + num
                else
                    activeReward[type] = num
                end
            end
        end

        return numTab, propReward, activeReward, tmpLocation <= 12 and tmpLocation or (tmpLocation - 12), tmpReward
    end

    if action == 'rand' then

        local free = tonumber(request.params.type) or 0
        --验证是否可以抽奖
        local weelTs = getWeeTs()
        local oldWeelTs = 0
        if mUseractive.info[aname].t then
            oldWeelTs = mUseractive.info[aname].t
        end
        --初始化免费抽奖次数
        local getCostFlag = true

        if oldWeelTs < weelTs then
            mUseractive.info[aname].ls = 0
            mUseractive.info[aname].t = weelTs
        end
        --验证是否收费
        local maxFree = activeCfg.free
        local freeCounts = mUseractive.info[aname].ls or 0
        if freeCounts < maxFree then
            getCostFlag = false
        end

        --验证免费次数，有免费次数 类型1不能抽奖
        if (not getCostFlag) and free == 1 then
            return response
        end

        local tmpCostGems = activeCfg.cost - tonumber(mUserinfo.vip)
        if tmpCostGems < 28 then
            tmpCostGems = 28
        end

        local costGem = getCostFlag
                and (free == 0 and tmpCostGems or (tmpCostGems * 6))
                or 0
        --用户金币是否够用
        if getCostFlag then
            if  not mUserinfo.useGem(costGem) then
                response.ret = -109
                return response
            end
        end
        local numTab, propReward, activeReward, localtion, tmpReward = getMultiRand(
            activeCfg.serverreward, mUseractive.info[aname].v,
            tonumber(free), mUseractive.info[aname].lv )

        --记录数据
        mUseractive.info[aname].v = localtion
        mUseractive.info[aname].lv = activeReward

        --增加道具
        if next(propReward) and not takeReward(uid, propReward) then
            return response
        end

        --客户端返回位置，俩个塞子的大小
        response.location = localtion
        response.numTab = numTab
        response.costFlag = getCostFlag

        --免费刷新时间和免费次数
        if not getCostFlag then
            mUseractive.info[aname].t = weelTs
            mUseractive.info[aname].ls = freeCounts + 1
        end

        --记录金币消耗
        if getCostFlag then
            regActionLogs(uid,1,{action=40,item="",value=costGem,params={prop=propReward,tmpRes=tmpReward}})
        end
    --兑换奖励
    elseif action == 'combine' then

        local costSpiceCfg = activeCfg.reward
        if type(mUseractive.info[aname].lv) ~= 'table'
                or tonumber(mUseractive.info[aname].lv.m1) < costSpiceCfg.needPartNum then
            return response
        end

        local tmpLv = (mUseractive.info[aname].lv.m1) % costSpiceCfg.needPartNum
        local vate = math.floor((mUseractive.info[aname].lv.m1) / costSpiceCfg.needPartNum)
        mUseractive.info[aname].lv.m1 = tmpLv
        local reward = {}
        for type, num in pairs(costSpiceCfg.gettank) do
            if not takeReward(uid, {['troops_'..type] = num * vate}) then
                return response
            end
            table.insert(reward, {[type] = num * vate})
        end
        response.clientReward = reward
        response.lv = tmpLv
    end

    if  (action == 'rand' or action == 'combine') and uobjs.save() then
        response.ret = 0
        response.msg = 'Success'
    end

    return response
end

