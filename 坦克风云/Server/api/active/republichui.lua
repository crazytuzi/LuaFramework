--
-- 共和国光辉国庆活动
-- User: luoning
-- Date: 14-9-12
-- Time: 下午3:43
--
function api_active_republichui(request)

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
    local aname = 'republicHui'

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
    local lotterylog = {r={},hr={},n=1,ar={}}

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

        local costGem = getCostFlag
                and (free == 0 and activeCfg.cost or activeCfg.multiCost)
                or 0
        --用户金币是否够用
        if getCostFlag then
            if costGem < activeCfg.cost or not mUserinfo.useGem(costGem) then
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

        lotterylog.r = propReward

        if next(activeReward) then
            lotterylog.ar = copyTable(activeReward)
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

        -- 和谐版判断
        if moduleIsEnabled('harmonyversion') ==1 then
            local rnum=1
            if free==1 then
                rnum=10
            end
            local hReward,hClientReward = harVerGifts('active','republicHui',rnum)
            if not takeReward(uid,hReward) then
                response.ret = -403
                return response
            end
            response.data[aname]={}
            response.data[aname].hReward = hClientReward

            lotterylog.hr = hClientReward
        end
        if free ~= 0 then
            lotterylog.n=10
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
    elseif action=='log' then
        local redis =getRedis()
        local redkey ="zid."..getZoneId()..aname..mUseractive.info[aname].st.."uid."..uid
        local data =redis:get(redkey)
        data =json.decode(data)

        if type(data) ~= 'table' then data = {} end
        response.ret = 0
        response.msg = 'Success'
        response.data.report=data
        return response
    end

    if  (action == 'rand' or action == 'combine') and uobjs.save() then

        if action == 'rand' then
            local rewardlog = {}
            if next(lotterylog.r) then
                for k,v in pairs(lotterylog.r) do
                    table.insert(rewardlog,formatReward({[k]=v}))
                end
            end

            if next(lotterylog.ar) then
                for k,v in pairs(lotterylog.ar) do

                    table.insert(rewardlog,formatActiveReward(aname,{[k]=v}))
                end
            end

            local redis =getRedis()
            local redkey ="zid."..getZoneId()..aname..mUseractive.info[aname].st.."uid."..uid
            local data =redis:get(redkey)
            data =json.decode(data)
            if type (data)~="table" then data={} end   
            table.insert(data,1,{getClientTs(),1,rewardlog,lotterylog.hr,lotterylog.n})
            if next(data) then
                for i=#data,11,-1 do
                    table.remove(data)
                end

                data=json.encode(data)
                redis:set(redkey,data)
                redis:expireat(redkey,mUseractive.info[aname].et+86400)
            end 
        end
        
        response.ret = 0
        response.msg = 'Success'
    end

    return response
end

