--
-- 新春红包活动
-- User: luoning
-- Date: 15-1-12
-- Time: 下午4:35
--
function api_active_xinchunhongbao(request)

    -- 活动名称，莫斯科赌局
    local aname = 'xinchunhongbao'

    local response = {
        ret=-1,
        msg='error',
        data = {
            [aname] = {},
        },
    }

    local uid = request.uid
    local action = request.params.action

    if uid == nil or action == nil then
        response.ret = -102
        return response
    end

    local uobjs = getUserObjs(uid)
    uobjs.load({"userinfo", "techs", "troops", "props","bag","skills","buildings",'useractive','friends'})
    local mUseractive = uobjs.getModel('useractive')
    local mUserinfo = uobjs.getModel('userinfo')
    local mFriends = uobjs.getModel('friends')

    -- 活动检测
    local activStatus = mUseractive.getActiveStatus(aname)
    if activStatus ~= 1 then
        response.ret = activStatus
        return response
    end
    local activeCfg = getConfig("active."..aname.."."..mUseractive.info[aname].cfg)
    --获取的礼包个数
    if not mUseractive.info[aname].q then
        mUseractive.info[aname].q = {0,0}
    end
    if not mUseractive.info[aname].r then
        mUseractive.info[aname].r = {}
    end
    --每日增加勋章数
    if not mUseractive.info[aname].p then
        mUseractive.info[aname].p = 0
        mUseractive.info[aname].m = 0
    end
    local weelTs = getWeeTs()
    if mUseractive.info[aname].m < weelTs then
        mUseractive.info[aname].m =weelTs
        mUseractive.info[aname].r = {}
    end

    local activeRecordKey = getActiveCacheKey(aname.."-"..uid, "def", mUseractive.info[aname].st)
    --赠送礼包
    if action == "give" then

        local giftUid = tonumber(request.params.giftUid) or 0
        local mtype = tonumber(request.params.type) or 0
        if giftUid == 0 or mtype == 0 or giftUid == uid then
            response.ret = -102
            return response
        end

        if type(mFriends.info)~='table' then  mFriends.info={} end
        if not table.contains(mFriends.info, giftUid) then
            response.ret = -1981
            return response
        end

        --验证赠送礼包条件
        if table.contains(mUseractive.info[aname].r, giftUid) or #mUseractive.info[aname].r >= activeCfg.dailyTimes then
            response.ret = -1981
            return response
        end
        table.insert(mUseractive.info[aname].r, giftUid)
        --金币消耗
        local gemCost = activeCfg.smallCost
        local activeGems = activeCfg.smallGiftGems
        if mtype == 2 then
            gemCost = activeCfg.bigCost
            activeGems = activeCfg.bigGiftGems
        end
        --增加活动的勋章数
        mUseractive.info[aname].p = mUseractive.info[aname].p + activeGems
        local getCostFlag = true
        if mUseractive.info[aname].t < weelTs and mtype == 1 then
            getCostFlag = false
            mUseractive.info[aname].t = weelTs
        end
        if getCostFlag and ( gemCost < activeCfg.smallCost or not mUserinfo.useGem(gemCost)) then
            response.ret = -109
            return response
        end
        --记录log
        if getCostFlag then
            regActionLogs(uid,1,{action=58,item="",value=gemCost,params={buyNum=mtype}})
        end
        mUseractive.info[aname].q[mtype] = mUseractive.info[aname].q[mtype] + 1
        --好友次数增加
        local giftuobjs = getUserObjs(giftUid)
        giftuobjs.load({"userinfo", "techs", "troops", "props","bag","skills","buildings",'useractive'})
        local mgiftUseractive = giftuobjs.getModel('useractive')
        local mgiftUserinfo = giftuobjs.getModel('userinfo')
        if not mgiftUseractive.info[aname].q then
            mgiftUseractive.info[aname].q = {0,0}
        end
        mgiftUseractive.info[aname].q[mtype] = mgiftUseractive.info[aname].q[mtype] + 1
        if not giftuobjs.save() then
            response.ret = -1981
            return response
        end
        --推送一条消息
        local data = {[aname] = mgiftUseractive.info[aname]}
        regSendMsg(giftUid,'active.change',data)

        --记录数据
        local giftRecordKey = getActiveCacheKey(aname.."-"..giftUid, "def", mUseractive.info[aname].st)
        local redis = getRedis()
        local nowTime = getClientTs()
        redis:lpush(activeRecordKey, json.encode({uid, mUserinfo.nickname, mUserinfo.level, mtype, 1, nowTime}))
        redis:expireat(activeRecordKey, mUseractive.info[aname].et)
        redis:lpush(giftRecordKey, json.encode({uid, mUserinfo.nickname, mUserinfo.level, mtype, 2, nowTime}))
        redis:expireat(giftRecordKey, mUseractive.info[aname].et)

        if uobjs.save() then
            response.ret = 0
            response.msg = "Success"
        end

    --打开礼包获取奖励
    elseif action == "getreward" then

        local mtype = tonumber(request.params.type) or 0
        if mtype == 0 then
            response.ret=-102
            return response
        end
        --礼包数量检测
        if mUseractive.info[aname].q[mtype] <= 0 then
            response.ret=-1981
            return response
        end
        mUseractive.info[aname].q[mtype] = mUseractive.info[aname].q[mtype] - 1
        local rewardPool = activeCfg.serverreward.smallPool
        if mtype == 2 then
            rewardPool = activeCfg.serverreward.bigPool
        end
        --勋章数量检测
        local activeGemsCost = activeCfg.openSmall
        if mtype == 2 then
            activeGemsCost = activeCfg.openBig
        end
        if activeGemsCost > mUseractive.info[aname].p then
            response.ret = -1981
            return response
        end
        mUseractive.info[aname].p = mUseractive.info[aname].p - activeGemsCost

        --领取奖励
        local reward = getRewardByPool(rewardPool)
        if not takeReward(uid, reward) then
            return response
        end
        local serverToClient = function(type)
            local tmpData = type:split("_")
            local tmpType = tmpData[2]
            local tmpPrefix = string.sub(type, 1, 1)
            if tmpPrefix == 't' then tmpPrefix = 'o' end
            if tmpPrefix == 'a' then tmpPrefix = 'e' end
            return tmpPrefix, tmpType
        end
        local clientReward = {}
        for mtype, mNum in pairs(reward) do
            local tmpPrefix,tmpType = serverToClient(mtype)
            table.insert(clientReward, {tmpPrefix, tmpType, mNum})
        end
        response.data[aname].clientReward=clientReward
        response.data[aname].type = mtype
        if uobjs.save() then
            response.ret = 0
            response.msg = "Success"
        end

    --获取礼包记录
    elseif action == "record" then

        local redis = getRedis()
        local res = redis:lrange(activeRecordKey, 0, activeCfg.recordNum-1)
        if type(res) == "table" and next(res) then
            for i,v in pairs(res) do
                res[i] = json.decode(v)
            end
        end
        response.data[aname].recordlist = type(res) == 'table' and res or {}
        response.ret = 0
        response.msg = "Success"
    end

    return response
end

