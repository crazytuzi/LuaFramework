--
-- 每日答题
-- User: luoning
-- Date: 15-1-23
-- Time: 下午4:25
--
function api_dailyactive_meiridati(request)

    local aname = 'meiridati'
    local response = {
        ret=-1,
        msg='error',
        data = {
            [aname] = {},
        },
    }

    local uid = request.uid or 0
    local action = request.params.action
    if uid == 0 and not (action== "getFirstGood" or action == "speakAll" or action == "recordlist") then
        response.ret = -102
        response.msg = 'uid invalid'
        return response
    end
    --客户端获取服务器时间
    if action == "getnowtime" then
        response.ret = 0
        return response
    end
    --每日答题开关
    if moduleIsEnabled('dailychoice')==0 then
        response.ret = -9000
        return response
    end
    local activeCfg = getConfig("dailyactive."..aname)
    local weelTs = getWeeTs()
    local nowTime = getClientTs()
    local st = weelTs + activeCfg.openTime[1][1] * 3600 + activeCfg.openTime[1][2] * 60
    local expireAt = weelTs + 24 * 3600
    local prefixSt = st - activeCfg.lastTime
    local et = weelTs + activeCfg.openTime[2][1] * 3600 + activeCfg.openTime[2][2] * 60
    --缓存key
    local titleKey = getActiveCacheKey(aname, "dailyactive.title", weelTs)
    --排名key
    local rankKey = getActiveCacheKey(aname, "dailyactive.rank", weelTs)
    --checkKey
    local checkKey = getActiveCacheKey(aname, "dailyactive.checkTitle", weelTs)

    --活动未开启
    if prefixSt > nowTime then
        response.ret = -1977
        return response
    end

    --发送全服聊天
    local sendUserMsg = function(msgType, params)
        local socket = require("socket.core")
        local msg = {
            sender = "",
            reciver = "",
            channel = 1,
            sendername = "",
            recivername = "",
            content = {
                type = msgType,
                ts = getClientTs(),
                contentType = 4,
                params = {
                    category = "",
                    data = params,
                },
            },
            type = "chat",
        }
        for i=1,4 do
            local ret = sendMessage(msg)
            if type(ret) == "string" then
                local success = string.find(ret, "Success")
                if success ~= nil then
                    break
                end
            end
        end
    end

    local choiceTitleTmp = function()

        local titles = {}
        local tmp = {}
        for i=1, activeCfg.serverreward.category do
            for m=1, activeCfg.serverreward.subjectCount[i] do
                local index = rand(1,2)
                local errorindex = rand(1,3)
                local tmpinfo = {}
                local tmpDid =  "qa"..tostring(i * 1000 + m)
                if index == 1 then
                    tmpinfo = {tmpDid.."_t", tmpDid.."_f"..errorindex}
                else
                    tmpinfo = {tmpDid.."_f"..errorindex, tmpDid.."_t"}
                end
                table.insert(tmp, {tmpDid.."_q", tmpinfo})
            end
        end
        local day = os.date("%d")
        day = day % 10;
        local start = day * 20 + 1;
        local endTime = (day+1) * 20;
        for i = start , endTime do
            table.insert(titles, tmp[i])
        end
        return titles
    end

    --选择题目
    local choiceTitle = function()

        local titles = {}
        setRandSeed()
        local category = {[1]={},[2]={},[3]={}}
        for i=1, activeCfg.serverreward.category do
            if i < activeCfg.serverreward.category then
                table.insert(category[1], 0)
            else
                table.insert(category[1], 100)
            end
            table.insert(category[2], 1)
            table.insert(category[3], i)
        end
        local choiceCategory = getRewardByPool(category)
        for _,v in pairs(choiceCategory) do
            local maxNum = activeCfg.serverreward.subjectCount[v]
            local detailChoice = {[1]={},[2]={},[3]={} }
            for m=1, activeCfg.serverreward.choiceSubject do
                if m < activeCfg.serverreward.choiceSubject then
                    table.insert(detailChoice[1], 0)
                else
                    table.insert(detailChoice[1], 100)
                end
            end
            for j=1, maxNum do
                table.insert(detailChoice[2], 1)
                table.insert(detailChoice[3], j)
            end
            local error = {2,3,4}
            local tmpChoice = getRewardByPool(detailChoice)
            for _,tmpll in pairs(tmpChoice) do
                local index = rand(1,2)
                local errorindex = rand(1,3)
                local tmpinfo = {}
                local tmpDid =  "qa"..tostring(v * 1000 + tmpll)
                if index == 1 then
                    tmpinfo = {tmpDid.."_t", tmpDid.."_f"..errorindex}
                else
                    tmpinfo = {tmpDid.."_f"..errorindex, tmpDid.."_t"}
                end
                table.insert(titles, {tmpDid.."_q", tmpinfo})
            end
        end
        return table.rand(titles)
    end

    --获取排名
    local getRanking = function()

        local res = {}
        local redis = getRedis()
        local pluslimit = 50
        local result = redis:zrevrange(rankKey,0,(activeCfg.rewardlimit -1 + pluslimit),'withscores')
        if type(result) == "table" and next(result) then
            local tmpresult = {}
            local resultlength = #result
            if resultlength > activeCfg.rewardlimit then
                for i=1, activeCfg.rewardlimit do
                    tmpresult[i] = result[i]
                end
                for i=activeCfg.rewardlimit+1, resultlength do 
                    if tonumber(result[i][2]) == tonumber(tmpresult[activeCfg.rewardlimit][2]) then
                        tmpresult[i] = result[i]
                    else
                        break
                    end
                end
            else
                tmpresult = result
            end
            local tmpSort = {}
            for i,v in pairs(tmpresult) do
                if not tmpSort["s"..v[2]] then
                    tmpSort["s"..v[2]] = i
                end
            end
            local base64 = require "lib.base64"
            for i,v in pairs(tmpresult) do
                local tmpUidName = string.split(v[1], "-")
                local tmpName = base64.Decrypt(tmpUidName[2])
                table.insert(res, {tmpName, tonumber(tmpUidName[1]), tmpSort["s"..v[2]], v[2]})
            end
        end
        return res
    end

    local setTrueGameCron = function(cmd, execTime)

        for i=1, 5 do
            local ret = setGameCron(cmd, execTime)
            if ret then
                break
            end
        end
    end


    --用户选择
    if action == "choice" then

        local uobjs = getUserObjs(uid)
        uobjs.load({"userinfo","dailychoice"})
        local userinfo = uobjs.getModel('userinfo')
        local mDailyChoice = uobjs.getModel('dailychoice')

        --每日积分重置
        if mDailyChoice.weelts < weelTs then
            mDailyChoice.weelts = weelTs
            mDailyChoice.score = 0
            mDailyChoice.info = {}
        end
        local choice = tonumber(request.params.choice) or 0
        local dtype = tonumber(request.params.dtype) or 0
        if choice <= 0 or choice > 4 or dtype <= 0 or dtype > activeCfg.serverreward.choiceSubject * activeCfg.serverreward.category then
            response.ret = -102
            return response
        end

        local checkdtype = 0
        for i=1 , activeCfg.serverreward.choiceSubject * activeCfg.serverreward.category do
            local startTime = st + (i - 1) * ((activeCfg.choiceTime + activeCfg.resultTime))
            local endTime = startTime + activeCfg.choiceTime + activeCfg.resultTime
            if startTime <= nowTime and endTime >= nowTime then
                checkdtype = i
                break
            end
        end
        --答题误差限制
        local tmpDifftype
        if checkdtype >= dtype then
            tmpDifftype = checkdtype - dtype
        else
            tmpDifftype = dtype - checkdtype
        end

        if tmpDifftype >= 2 then
            response.ret = -1981
            return response
        end

        --检查用户是否已经对某道题做出了选择
        if mDailyChoice.info.dtype and mDailyChoice.info.dtype >= dtype then
            response.ret = -1981
            return response
        end
        --记录用户选择的题号
        mDailyChoice.info.dtype = dtype
        --记录用户最近一题选择的答案
        mDailyChoice.info.choice = choice

        --开始计时的时间
        local startTime = st + (dtype - 1) * ((activeCfg.choiceTime + activeCfg.resultTime))
        local startError = false
        if startTime >= nowTime then
            startError = true
        end

        --记录选择历史
        if not mDailyChoice.info.h then
            mDailyChoice.info.h = {}
        end

        local endTime = startTime + activeCfg.choiceTime
        local diff = math.ceil((endTime - nowTime) + 10)
        if startError then
            setRandSeed()
            diff = math.ceil((endTime - (startTime + rand(2,4))) + 10)
        end
        if diff <= 0 then
            diff = 10
        end
        local score = 0
        local choicetype = "0-"..dtype
        local getRewardFlag = false
        if choice == activeCfg.rightAnswer then
            score = score + diff
            getRewardFlag = true
        else
            score = score + activeCfg.losepoint
            choicetype = "1-"..dtype
        end

        mDailyChoice.score = mDailyChoice.score + score
        mDailyChoice.info.reward = getRewardFlag and 1 or 0
        mDailyChoice.info.prefix = {mDailyChoice.score - score, score, mDailyChoice.score, dtype, choice}

        if getRewardFlag and not takeReward(uid, activeCfg.serverreward.choiceReward) then
            return response
        end

        table.insert(mDailyChoice.info.h, {dtype,choice,mDailyChoice.info.reward,score})

        --记录排名
        local speakAllInfo = function()
            local choiceKey = getActiveCacheKey(aname, "dailyactive.choice."..choicetype, weelTs)
            local tmpRankKey = getActiveCacheKey(aname, "dailyactive.tmprank."..choicetype, weelTs)
            local recordGameCronKey = getActiveCacheKey(aname, "dailyactive.recordGameCronKey", weelTs)

            local redis = getRedis()
            local number = redis:incr(choiceKey)
            redis:expireat(choiceKey, expireAt)
            local base64 = require "lib.base64"
            local tmpName = base64.Encrypt(userinfo.nickname)
            local recordGameNum = redis:incr(recordGameCronKey)
            --设置需要推送的时间(可能会失败，设置俩次)
            if recordGameNum <= 1 then
                local cmd = {cmd ="dailyactive.meiridati",params={action="speakAll",dtype=1,flag=1} }
                setTrueGameCron(cmd, 0)
                local cmd = {cmd ="dailyactive.meiridati",params={action="recordlist"} }
                local execTime = st + (activeCfg.serverreward.choiceSubject * activeCfg.serverreward.category) * (activeCfg.choiceTime + activeCfg.resultTime) - 2
                local diffexecTime = 0
                if execTime - nowTime > 0 then
                    diffexecTime = execTime - nowTime
                end
                setTrueGameCron(cmd, diffexecTime)
                --发送聊天公告
                local cmd = {cmd ="dailyactive.meiridati",params={action="getFirstGood"} }
                local diffexecTime = 0
                if execTime - nowTime > 0 then
                    diffexecTime = execTime - nowTime
                end
                local execTime = st + (activeCfg.serverreward.choiceSubject * activeCfg.serverreward.category) * (activeCfg.choiceTime + activeCfg.resultTime)
                setTrueGameCron(cmd, diffexecTime)
            end
            --前十个做出选择的发公告
            if number <= 10 then
                redis:zincrby(tmpRankKey, number, uid.."-"..tmpName)
                redis:expireat(tmpRankKey, expireAt)
                --[[
                local tmpRank = redis:zrange(tmpRankKey,0, 9,'withscores')
                local res = {}
                if type(tmpRank) == "table" and next(tmpRank) then
                    for i,v in pairs(tmpRank) do
                        local tmpUidName = string.split(v[1], "-")
                        local tmpName = base64.Decrypt(tmpUidName[2])
                        table.insert(res, {tmpName, tonumber(tmpUidName[1]), v[2]})
                    end
                end
                local flag = getRewardFlag and 1 or 0
                sendUserMsg(113, {res, flag, dtype})
                --]]
            end
            --记录全服排名
            redis:zincrby(rankKey, score,uid.."-"..tmpName)
            redis:expireat(rankKey, expireAt)
        end

        if uobjs.save() then
            response.data[aname].lastTime = nowTime
            response.data[aname].score = score - diff
            response.data[aname].prefix = mDailyChoice.info.prefix
            response.data[aname].diff = 0
            response.ret = 0
            response.msg = "Success"
        end

        speakAllInfo()

    elseif action == "getChoiceStatus" then

        local uobjs = getUserObjs(uid)
        uobjs.load({"userinfo","dailychoice","bag"})
        local userinfo = uobjs.getModel('userinfo')
        local mDailyChoice = uobjs.getModel('dailychoice')
        local mBag = uobjs.getModel('bag')

        local result = getRanking()
        if mDailyChoice.weelts < weelTs then
            mDailyChoice.weelts = weelTs
            mDailyChoice.score = 0
            mDailyChoice.info = {}
        end
        local rewardType = 0
        for i,v in pairs(result) do
            if v[2] == uid then
                rewardType = tonumber(v[3])
            end
        end

        if #result >= activeCfg.rewardlimit and mDailyChoice.score ~= 0 then
            rewardType = activeCfg.rewardlimit + 1
        end

        if mDailyChoice.info.reward == 1 then
            --if not takeReward(uid, activeCfg.serverreward.choiceReward) then
            --    return response
            --end
            response.data[aname].reward = 1
        else
            response.data[aname].reward = 0
        end
        mDailyChoice.info.reward = nil
        local diff = 0
        if mDailyChoice.info.diff then
            mDailyChoice.score = tonumber(mDailyChoice.score) or 0
            mDailyChoice.score = mDailyChoice.score + mDailyChoice.info.diff
            diff = tonumber(mDailyChoice.info.diff) or 0
            mDailyChoice.info.diff = nil
        end

        response.data.bag = mBag.toArray(true)

        if uobjs.save() then
            response.data[aname].score = tonumber(mDailyChoice.score) or 0
            response.data[aname].diff = diff
            response.data[aname].nowRank = rewardType
            response.msg = "Success"
            response.ret = 0
        end

    --获取用户的基础信息
    elseif action == "getUserStatus" then

        local nowTime = getClientTs()
        local dtype = 0
        for i=1 , activeCfg.serverreward.choiceSubject * activeCfg.serverreward.category do
            local startTime = st + (i - 1) * ((activeCfg.choiceTime + activeCfg.resultTime))
            local endTime = startTime + activeCfg.choiceTime + activeCfg.resultTime
            if startTime <= nowTime and endTime >= nowTime then
                dtype = i
                break
            end
        end
        local nowRank = 0
        local result = {}
        if dtype > 0 then
            local redis = getRedis()
            local rightchoiceKey = getActiveCacheKey(aname, "dailyactive.choice.0-"..dtype, weelTs)
            local errorchoiceKey = getActiveCacheKey(aname, "dailyactive.choice.1-"..dtype, weelTs)
            local righttmpRankKey = getActiveCacheKey(aname, "dailyactive.tmprank.0-"..dtype, weelTs)
            local errortmpRankKey = getActiveCacheKey(aname, "dailyactive.tmprank.1-"..dtype, weelTs)
            local rightNum = redis:get(rightchoiceKey)
            local errorNum = redis:get(errorchoiceKey)
            rightNum = tonumber(rightNum) or 0
            errorNum = tonumber(errorNum) or 0
            response.data[aname].counts = {{rightNum,errorNum}, dtype }
            local base64 = require "lib.base64"

            local tmpRank = redis:zrange(errortmpRankKey,0, 9,'withscores')
            local res = {}
            if type(tmpRank) == "table" and next(tmpRank) then
                for i,v in pairs(tmpRank) do
                    local tmpUidName = string.split(v[1], "-")
                    local tmpName = base64.Decrypt(tmpUidName[2])
                    table.insert(res, {tmpName, tonumber(tmpUidName[1]), v[2]})
                end
            end
            response.data[aname].errorRank = {res, 0, dtype}

            local tmpRank = redis:zrange(righttmpRankKey,0, 9,'withscores')
            local res = {}
            if type(tmpRank) == "table" and next(tmpRank) then
                for i,v in pairs(tmpRank) do
                    local tmpUidName = string.split(v[1], "-")
                    local tmpName = base64.Decrypt(tmpUidName[2])
                    table.insert(res, {tmpName, tonumber(tmpUidName[1]), v[2]})
                end
            end
            response.data[aname].rightRank = {res, 1, dtype }

            result = getRanking()
            for i,v in pairs(result) do
                if v[2] == uid then
                    nowRank = tonumber(v[3])
                end
            end

        end

        local uobjs = getUserObjs(uid)
        uobjs.load({"userinfo","dailychoice"})
        local userinfo = uobjs.getModel('userinfo')
        local mDailyChoice = uobjs.getModel('dailychoice')
        if mDailyChoice.weelts < weelTs then
            mDailyChoice.weelts = weelTs
            mDailyChoice.score = 0
            mDailyChoice.info = {}
        end

        if #result >= activeCfg.rewardlimit and mDailyChoice.score ~= 0 then
            nowRank = activeCfg.rewardlimit + 1
        end

        response.data[aname].info = mDailyChoice.toArray()
        if not response.data[aname].info.diff then
            response.data[aname].info.diff = 0
        end

        if not response.data[aname].info.reward then
            response.data[aname].info.reward = 0
        end

        if not mDailyChoice.info.prefix then
            mDailyChoice.info.prefix={0,0,0,0,0}
        end

        if uobjs.save() then
            response.data[aname].nowRank = nowRank
            response.data[aname].nowTime = getClientTs()
            response.msg = "Success"
            response.ret = 0
        end

    --选择题目
    elseif action == "getTitlelist" then

        local getTitlelist = function()
            local redis = getRedis()
            local result = redis:get(titleKey)
            result = json.decode(result) or {}
            if not next(result) then
                local freeData = getFreeData(aname..weelTs)
                if type(freeData) == "table"
                        and type(freeData.info) == "table"
                        and freeData.info.title
                then
                    redis:set(titleKey, json.encode(freeData.info.title))
                    redis:expireat(titleKey, expireAt)
                    result = freeData.info.title
                end
            end

            if not next(result) then
                local num = redis:incr(checkKey)
                redis:expireat(checkKey, expireAt)
                if num > 1 then
                    return false
                end
                result = choiceTitle()
                getFreeData(aname..weelTs)
                if not setFreeData(aname..weelTs, {title=result}) then
                    return response
                end
                redis:set(titleKey, json.encode(result))
                redis:expireat(titleKey, expireAt)
            end
            return result
        end

        local result = getTitlelist()
        if not result then
            for i=1, 3 do
                local socket = require("socket.core")
                local time = rand(20,60)/100
                socket.select(nil,nil,time)
                result = getTitlelist()
                if result then
                    break
                end
            end
        end

        response.data[aname].titlelist = result
        response.msg = "Success"
        response.ret = 0

    --排行榜信息
    elseif action == "getRanklist" then

        local dtype = tonumber(request.params.dtype) or 0
        if  dtype > activeCfg.serverreward.choiceSubject * activeCfg.serverreward.category then
            response.ret = -102
            return response
        end

        local nowtime = getClientTs()
        local endTime = st + (activeCfg.serverreward.choiceSubject * activeCfg.serverreward.category) * (activeCfg.choiceTime + activeCfg.resultTime)
        if nowTime < endTime then
            response.ret = -102
            return response
        end

        local redis = getRedis()
        local errorKey = getActiveCacheKey(aname, "dailyactive.choice.1-"..dtype, weelTs)
        local rightKey = getActiveCacheKey(aname, "dailyactive.choice.0-"..dtype, weelTs)
        local errorNums = redis:get(errorKey)
        local rightNums = redis:get(rightKey)
        errorNums = tonumber(errorNums) or 0
        rightNums = tonumber(rightNums) or 0
        local rank = getRanking()
        response.data[aname].nums = {rightNums,errorNums}
        response.data[aname].rank = rank
        response.msg = "Success"
        response.ret = 0

    --获取排名奖励
    elseif action == "getRankReward" then

        local uobjs = getUserObjs(uid)
        uobjs.load({"userinfo","dailychoice"})
        local userinfo = uobjs.getModel('userinfo')
        local mDailyChoice = uobjs.getModel('dailychoice')
        if mDailyChoice.info.flag then
            response.ret = -401
            return response
        end
        local result = getRanking()
        if mDailyChoice.weelts < weelTs then
            mDailyChoice.weelts = weelTs
            mDailyChoice.score = 0
            mDailyChoice.info = {}
        end
        local rewardType = 0
        for i,v in pairs(result) do
            if v[2] == uid then
                rewardType = tonumber(v[3])
            end
        end

        if rewardType == 0 then
            response.ret = -1981
            return response
        end
        local reward = {}
        for i,v in pairs(activeCfg.serverreward.rankReward) do
            if v[1][1] <= rewardType and rewardType <= v[1][2] then
                reward = v[2]
                break
            end
        end
        if not next(reward) then
            response.ret = -1981
            return response
        end

        if not takeReward(uid, reward) then
            return response
        end
        mDailyChoice.info.flag = 1
        if uobjs.save() then
            response.ret = 0
            response.msg = "Success"
        end

    --记录排名信息
    elseif action == "recordlist" then

        local rank = getRanking()
        if type(rank) == "table" and next(rank) then
            for i,v in pairs(rank) do
                local uobjs = getUserObjs(tonumber(v[2]))
                uobjs.load({"userinfo","dailychoice"})
                local userinfo = uobjs.getModel('userinfo')
                local mDailyChoice = uobjs.getModel('dailychoice')
                mDailyChoice.rank = tonumber(mDailyChoice.rank) or 0
                v[3] = tonumber(v[3]) or 0
                if (v[3] ~= 0) and mDailyChoice.rank > v[3] then
                    mDailyChoice.rank = v[3]
                    uobjs.save()
                elseif v[3] ~= 0 and mDailyChoice.rank == 0 then
                    mDailyChoice.rank = v[3]
                    uobjs.save()
                end
            end
        end
        response.ret = 0
        response.msg = "Success"

    --发送全服公告
    elseif action == "speakAll" then

        local dtype = tonumber(request.params.dtype) or 1
        local flag = tonumber(request.params.flag) or 0

        local num = activeCfg.serverreward.choiceSubject * activeCfg.serverreward.category
        local nowTime = getClientTs()
        local speakTime = math.floor((activeCfg.choiceTime))
        local cmd = {cmd ="dailyactive.meiridati",params={action="speakAll", dtype=1, flag=0} }
        if flag == 1 then
            for i=1, num do
                local tmpst = st + (i - 1) * ((activeCfg.choiceTime + activeCfg.resultTime))
                for j = 1, speakTime do
                    local tmpSpeakTime = (j) + tmpst
                    cmd.params.dtype = i
                    if tmpSpeakTime - nowTime > 0 then
                        setTrueGameCron(cmd, tmpSpeakTime - nowTime)
                    end
                end
            end
        end

        local base64 = require "lib.base64"
        --答题人数推送
        local redis = getRedis()
        local errorKey = getActiveCacheKey(aname, "dailyactive.choice.1-"..dtype, weelTs)
        local rightKey = getActiveCacheKey(aname, "dailyactive.choice.0-"..dtype, weelTs)
        local tmpErrorKey = getActiveCacheKey(aname, "dailyactive.tmprank.1-"..dtype, weelTs)
        local tmpRightKey = getActiveCacheKey(aname, "dailyactive.tmprank.0-"..dtype, weelTs)

        local errorNums = redis:get(errorKey)
        local rightNums = redis:get(rightKey)
        errorNums = tonumber(errorNums) or 0
        rightNums = tonumber(rightNums) or 0

        --错误答案
        local tmpRank = redis:zrange(tmpErrorKey,0, 9,'withscores')
        local errorinfo = {}
        if type(tmpRank) == "table" and next(tmpRank) then
            for i,v in pairs(tmpRank) do
                local tmpUidName = string.split(v[1], "-")
                local tmpName = base64.Decrypt(tmpUidName[2])
                table.insert(errorinfo, {tmpName, tonumber(tmpUidName[1]), v[2]})
            end
        end
        --正确答案
        local tmpRank = redis:zrange(tmpRightKey,0, 9,'withscores')
        local rightinfo = {}
        if type(tmpRank) == "table" and next(tmpRank) then
            for i,v in pairs(tmpRank) do
                local tmpUidName = string.split(v[1], "-")
                local tmpName = base64.Decrypt(tmpUidName[2])
                table.insert(rightinfo, {tmpName, tonumber(tmpUidName[1]), v[2]})
            end
        end

        sendUserMsg(114, {
                            {{rightNums,errorNums}, dtype}, --错误人数
                            {rightinfo, 1, dtype}, --答对的人数
                            {errorinfo, 0, dtype}, --答错的人数
                         }
                   )
        response.msg = "Success"
        response.ret = 0

    elseif action == "getFirstGood" then

        sendUserMsg(115, {1,1})
        response.msg = "Success"
        response.ret = 0
    end

    return response
end

