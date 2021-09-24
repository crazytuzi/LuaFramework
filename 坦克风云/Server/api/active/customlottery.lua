--
-- 抽奖自定义版本
-- User: luoning
-- Date: 14-10-8
-- Time: 上午10:45
--
function api_active_customlottery(request)

    -- 活动名称，莫斯科赌局
    local aname = 'customLottery'

    local response = {
        ret=-1,
        msg='error',
        data = {
            [aname] = {},
        },
    }

    local uid = request.uid
    if uid == nil then
        response.ret = -102
        return response
    end

    local uobjs = getUserObjs(uid)
    uobjs.load({"userinfo", "techs", "troops", "props","bag","skills","buildings",'useractive'})
    local mUseractive = uobjs.getModel('useractive')
    local mUserinfo = uobjs.getModel('userinfo')

    --format
    local formatClientData = function(poolReward)
        local clientReward = {}
        for type, num in pairs(poolReward) do
            local tmpData = type:split("_")
            local tmpType = tmpData[2]
            local tmpPrefix = string.sub(type, 1, 1)
            if tmpPrefix == 't' then tmpPrefix = 'o' end
            if tmpPrefix == 'a' then tmpPrefix = 'e' end
            table.insert(clientReward, {p=tmpPrefix, t=tmpType, n=num})
        end
        return clientReward
    end

    -- 活动检测
    local activStatus = mUseractive.getActiveStatus(aname)
    if activStatus ~= 1 then
        response.ret = activStatus
        return response
    end
    local action = false
    if request.params then
         action = request.params.action
    end
    local redisKey = getActiveCacheKey(aname, "def", mUseractive.info[aname].st)
    local retReward = {}
    --获取记录
    if action and action == 'getlist' then
        local redis = getRedis()
        local result = redis:hget(redisKey, uid)
        if type(result) == 'string' then
            result = json.decode(result)
        end
        response.data[aname].rewardList = type(result) == 'table' and result or {}
        response.msg = "Success"
        response.ret = 0
        return response
    elseif action and tonumber(action) == 2 then
        local lotteryNum = 10

        require "model.active"
        local mActive = model_active()
        --自定义配置文件
        local activeCfg = mActive.selfCfg(aname)
        -- 小于0 不判断次数
	if tonumber(activeCfg.time)>0 then
	    if mUseractive.info[aname].v+lotteryNum > tonumber(activeCfg.time) then
		response.ret = -102
		return response
	    end
	end

	


        -- 扣钱
        local costGem = activeCfg.cost * lotteryNum
        if costGem <=0 or not mUserinfo.useGem(costGem) then
            response.ret = -109
            return response
        end        
        mUseractive.info[aname].v = mUseractive.info[aname].v + lotteryNum

        local redis = getRedis()
        local result = redis:hget(redisKey, uid)
        if type(result) == 'string' then
            result = json.decode(result)
        end
        result = type(result) == 'table' and result or {}
        -- 发奖
        for i=1, lotteryNum do
            local poolReward = getRewardByPool(activeCfg.pool)
            --增加道具
            if not takeReward(uid, poolReward) then
                return response
            end

            --抽奖记录

            local clientReward = formatClientData(poolReward)
            local recordReward = clientReward[1]
            if recordReward then
                table.insert(result, {recordReward.p,recordReward.t,recordReward.n,getClientTs()})
                local flag = true
                while flag do
                    if #result > 20 then
                        table.remove(result, 1)
                    end
                    if #result <= 20 then
                        flag = false
                    end
                end
            end
            table.insert(retReward, clientReward)

        end

        redis:hset(redisKey, uid, json.encode(result))
        redis:expireat(redisKey, tonumber(mUseractive.info[aname].et))
        response.data[aname].rewardList = result

        --记录用户消费金币记录
        regActionLogs(uid,1,{action=34,item="",value=costGem,params={buyNum=lotteryNum, }})

    else

        require "model.active"
        local mActive = model_active()
        --自定义配置文件
        local activeCfg = mActive.selfCfg(aname)
        --免费次数
        if mUseractive.info[aname].v >= tonumber(activeCfg.time)
                --<=0不限制次数
                and tonumber(activeCfg.time) > 0
        then
            return response
        end
        --花费金币
        local costGem = activeCfg.cost
        if costGem <= 0 or not mUserinfo.useGem(costGem) then
            response.ret = -109
            return response
        end

        mUseractive.info[aname].v = mUseractive.info[aname].v + 1
        local poolReward = getRewardByPool(activeCfg.pool)
        --增加道具
        if not takeReward(uid, poolReward) then
            return response
        end
        --记录用户消费金币记录
        regActionLogs(uid,1,{action=34,item="",value=costGem,params={buyNum=1,hasNum=poolReward}})

        --抽奖记录
        local clientReward = formatClientData(poolReward)
        local recordReward = clientReward[1]
        if recordReward then
            local redis = getRedis()
            local result = redis:hget(redisKey, uid)
            if type(result) == 'string' then
                result = json.decode(result)
            end
            result = type(result) == 'table' and result or {}
            table.insert(result, {recordReward.p,recordReward.t,recordReward.n,getClientTs()})
            local flag = true
            while flag do
                if #result > 20 then
                    table.remove(result, 1)
                end
                if #result <= 20 then
                    flag = false
                end
            end
            redis:hset(redisKey, uid, json.encode(result))
            redis:expireat(redisKey, tonumber(mUseractive.info[aname].et))
            response.data[aname].rewardList = result
        end

        retReward =clientReward
    end

    if uobjs.save() then
        response.data[aname].clientReward = retReward
        response.ret = 0
        response.msg = 'Success'
    end

    return response
end

