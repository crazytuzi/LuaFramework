--
-- 有福同享
-- User: luoning
-- Date: 14-7-29
-- Time: 下午12:37
--

function api_active_sharehappiness(request)

    local aname = 'shareHappiness'

    local response = {
        ret=-1,
        msg='error',
        data = {
            [aname] = {},
        },
    }

    local uid = request.uid
    local action = request.params.action
    --local num = tonumber(request.params.num) or 0

    if uid == nil or action == nil then
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

    --初始化数据
    local allianceId = mUserinfo.alliance
    local allianceName = mUserinfo.alliancename
    local username = mUserinfo.nickname
    local cacheKey
    if tonumber(allianceId) > 0 then
        cacheKey = getActiveAllianceCacheKey(aname, "def", allianceId, mUseractive.info[aname].st )
    end
    local lastGetRewardTime = mUseractive.info[aname].t
    --local totalTime = mUseractive.info[aname].et - mUseractive.info[aname].st + 86400
    local joinAtData,code = M_alliance.getuseralliance{uid=uid,aid=mUserinfo.alliance}
    local joinAt = 0
    if type(joinAtData) == 'table' and joinAtData['ret'] == 0 then
	    joinAt = tonumber(joinAtData['data']['join_at']) or 0
    end
    --判断用户的加入时间
    if joinAt == 0 then
        response.ret = 0
        response.data = {}
        response.errorId = 1
        return response
    end

--    --得到分享礼包的档次
--    local getShareCode = function(num, shareConfig)
--
--        local shareCode = 0
--        if num == 0 then
--            return shareCode
--        end
--        for i, v in pairs(shareConfig) do
--            if num >= v[2] then
--                return i
--            end
--        end
--        return shareCode
--    end
--
--    --添加礼包
--    local addShareGift = function(shareCode, aid, aname, uid, uname, cacheKey, totalTime)
--
--        if cacheKey == nil then
--            return false
--        end
--        local cacheRedis = getRedis()
--        local nowTime = getClientTs()
--        local giftId = uid .. '.' .. nowTime
--        local flag = cacheRedis:hmset(cacheKey, giftId, json.encode({
--            cd = shareCode, aid = aid, am = aname, uid = uid, um = uname, st = nowTime,
--        }))
--        cacheRedis:expire(cacheKey, totalTime)
--        return flag, giftId
--    end

    --得到礼包列表
    local getShareList = function (cacheKey, lastGetRewardTime, uid, joinAt)
        local res = {}
        if cacheKey == nil then
            return res
        end
        local cacheRedis = getRedis()
        local rewardData = cacheRedis:hgetall(cacheKey)
        local expireTime = 86400
        local nowTime = getClientTs()
        if type(rewardData) == 'table' then
            for _, v in pairs(rewardData) do
                --数量限制
                local tmpData = json.decode(v)
                if lastGetRewardTime < tmpData['st'] and
                   nowTime - tmpData['st'] < expireTime and
                   tmpData['uid'] ~= uid and
                   tmpData['st'] >= joinAt
                then
                    table.insert(res, tmpData)
                end
            end
        end
        return res
    end

    --领取礼包数量
    local getTotalReward = function(cacheKey, rewardConfig, lastGetRewardTime, uid, joinAt)
	    --lastGetRewardTime = 0
        if cacheKey == nil then
            return false
        end

        local cacheRedis = getRedis()
        local rewardData = cacheRedis:hgetall(cacheKey)
        if type(rewardData) ~= 'table' then
            return false
        end
        local reward = {}
        local newRewardTime = lastGetRewardTime
        local expireTime = 86400
        local nowTime = getClientTs()
        local clientReward = {}
        for _, singleReward  in pairs(rewardData) do

            if type(singleReward) == 'string' then
                local tmpData = json.decode(singleReward)
                if tmpData['st'] > lastGetRewardTime and
                    nowTime - tmpData['st'] < expireTime and
                    tmpData['uid'] ~= uid and
                    tmpData['st'] >= joinAt
                then
                    --更新用户领奖时间
                    if tmpData['st'] > newRewardTime then
                        newRewardTime = tmpData['st']
                    end
                    --累加奖励
                    for configType, configNum in pairs(rewardConfig[tmpData['cd']][1]) do
                        if reward[configType] then
                            reward[configType] = reward[configType] + configNum
                        else
                            reward[configType] = configNum
                        end
                    end
                end
            end
        end
        for type, num in pairs(reward) do
            local tmpType = type:split('_')
            table.insert(clientReward, {[tmpType[2]]=num,index=1})
        end

        return reward, newRewardTime, clientReward
    end

    local activeCfg =  getConfig("active." .. aname )
    local serverCfg = activeCfg.serverreward

    --添加分享
    if action == "addShare" then
--        local gold_num = 8400
--        --test
--        activity_setopt(uid,'shareHappiness',{
--            num=gold_num,
--            allianceId = mUserinfo.alliance,
--            allianceName = mUserinfo.alliancename,
--            username = mUserinfo.nickname,
--        })
--        uobjs.save()
--        --得到分享的类型
--        local shareCode = getShareCode(num, serverCfg);
--        if shareCode == 0 then
--            response.ret = -102
--            return response
--        end
--
--        --增加礼包
--        local addFlag = addShareGift(shareCode, allianceId, allianceName, uid, username, cacheKey, totalTime)
--        local bagGift = getShareList(cacheKey, lastGetRewardTime, uid)
--        local totalReward = serverCfg[shareCode][1]
--        --添加物品
--        if not takeReward(uid, totalReward) then
--            return response
--        end
--
--        if addFlag then
--            response.ret = 0
--            response.data = bagGift
--            response.shareCode = shareCode
--            response.msg = 'Success'
--        end

    --得到礼包
    elseif action == "getShare" then

        if cacheKey == nil then
            response.ret = 0
            response.data = {}
            response.errorId = 1
            return response
        end
	
        local totalReward, newGetRewardTime, clientReward = getTotalReward(cacheKey, serverCfg, lastGetRewardTime, uid, joinAt)
        if not totalReward then
	    response.errorId = 0
            response.ret = -102
            return response
        end

        if not takeReward(uid, totalReward) then
            return response
        end

        mUseractive.info[aname].t = newGetRewardTime
        local bagGift = getShareList(cacheKey, newGetRewardTime, uid, joinAt)
        if uobjs.save() then
            response.ret = 0
            response.data = bagGift
	        response.errorId = 0
            response.clientReward = clientReward
            response.msg = 'Success'
        end

    --分享礼包列表
    elseif action == "getList" then

        local bagGift = getShareList(cacheKey, lastGetRewardTime, uid, joinAt)
        if uobjs.save() then
            response.ret = 0
	        response.errorId = 0
            response.data = bagGift
            response.msg = 'Success'
        end
    end

    return response
end
