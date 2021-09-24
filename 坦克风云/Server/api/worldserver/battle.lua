-- status 1是胜，2是败，3是淘汰
-- TODO rollback 情况需要考虑
function api_worldserver_battle(request)
    local response = {
        ret=-1,
        msg='error',
        data = {},
        errers={},
    }
    
    -- 比赛类型,1是大师，2是精英
    local matchType = request.params.matchType

    -- 淘汰赛或积分赛，1是积分赛，2是淘汰赛
    local tMatch = request.params.tMatch
    if not matchType or not tMatch then
        response.ret = -102
        return response
    end

    local ts = getClientTs()
    local sevbattleCfg = getConfig("worldWarCfg")
    
    local base = false
    local crossserver = require "model.worldserver"
    local cross = crossserver.new()
    cross.initBattle()

    local allBids = cross:getBidDataByMatchType(matchType,ts)
    if not allBids or type(allBids)~= 'table' or not next(allBids) then 
        response.err = "not find bid"
        return response
    end 

    -- 设置用户的积分与商店积分信息
    -- score 排行积分
    -- shopScore 商店积分
    -- landform 地形
    -- winFlag 胜利标志
    local function setPointBattleUserInfo(round,userinfos,score,shopScore,winFlag,sevbattleCfg) 
        local userinfo = userinfos[1]
        
        local etype = nil   -- 事件报告类型
        local overStreak = nil  -- 终节前的连胜数

        if winFlag then
            userinfo.winStreak = (tonumber(userinfo.winStreak) or 0) + 1
            userinfo.winNum = (tonumber(userinfo.winNum) or 0) + 1
            if userinfo.winStreak > (tonumber(userinfo.maxWinStreak) or 0) then
                userinfo.maxWinStreak = userinfo.winStreak
            end

            etype = sevbattleCfg.winningStreak[userinfo.winStreak]
        else
            userinfo.loseNum = (tonumber(userinfo.loseNum) or 0) + 1
            overStreak = tonumber(userinfo.winStreak)
            userinfo.winStreak = 0

            if overStreak >= 5 then 
                etype = sevbattleCfg.winningStreak[userinfo.winStreak]
            end
        end

        if etype then
            -- 如果类型是1，表示是终结，终结时，需要终结者的信息
            if etype == 1 then
                if type(userinfo[2]) == 'table' then
                    cross:addPointMatchEvent({round,etype,userinfo.uid,userinfo.zid,userinfo.nickname,userinfos[2].zid,userinfos[2].nickname,userinfo.winStreak,overStreak})
                end
            else
                cross:addPointMatchEvent({round,etype,userinfo.uid,userinfo.zid,userinfo.nickname})
            end
        end

        if type(userinfo.pointlog) == 'string' and #userinfo.pointlog > 0 then
            userinfo.pointlog = tostring(userinfo.pointlog) .. ',' .. tostring(shopScore)
        else
            userinfo.pointlog = shopScore
        end

        if userinfo.winStreak >= sevbattleCfg.conWinTime then
            score = score + sevbattleCfg.conWinPoint
        end

        userinfo.score = tonumber(userinfo.score) + score
        userinfo.point = tonumber(userinfo.point) + shopScore
        userinfo.sround = tonumber(userinfo.sround) + 1

        -- 用户分数值最小为0
        if userinfo.score < 0 then
            userinfo.score = 0
        end

        return score
    end

    -- 积分赛战斗
    local function runPointBattle(bid,round,matchType,sevbattleCfg,runNum)
        if not runNum then runNum = 0 end

        local battleData = cross:getBattleDataByBid(bid,round,matchType)

        if not battleData or not next(battleData) then 
            return true
        end

        if runNum > 1500 then
            local tmpLog = {
                bid=bid,
                round=round,
                matchType=matchType,
                runNum=runNum,
            }
            writeCrossLog("runNum error : " .. json.encode(tmpLog))
            return false
        end

        runNum = runNum + 1

        -- 详细战斗列表
        local battleList = cross.getPointMatchList(battleData)

        if battleList and next(battleList) then 

            -- 关闭自动提交
            cross:setautocommit(false)

            for _,userinfo in pairs(battleList) do
                if userinfo[2] then
                    --  第一场随机
                    --  第二场为第一场后手玩家先手
                    -- 第三场为前两场剩余坦克数量多的玩家先手
                    -- 如果剩余数量相同，则随机先后手。
                    local aAliveNums, dAliveNums = 0, 0
                    local aWinNums, dWinNums = 0, 0                    
                    local aWinRound,dWinRound = {},{} -- 记录战斗结果
                    local reports,battleWiners = {},{}
                    local landforms = cross.randBattleLandform()
                    
                    local aBinfo = json.decode(userinfo[1].binfo)
                    local dBinfo = json.decode(userinfo[2].binfo)
                    local aStrategy = json.decode(userinfo[1].strategy)
                    local dStrategy = json.decode(userinfo[2].strategy)

                    for i=1,3 do
                        -- 1是攻击，2是防守
                        attSeq = cross.getBattleSeq(i,aAliveNums,dAliveNums,attSeq)

                        -- 本场战斗地形
                        local landform = landforms[i]

                        local report, aAliveNum, dAliveNum,winer,battleAttSeq,seqPoint

                        if attSeq == 1 then
                            report, aAliveNum, dAliveNum,battleAttSeq,seqPoint = cross.crossbattle(aBinfo,dBinfo,i,landform,{aStrategy,dStrategy})
                            report.p = {{userinfo[2].nickname,userinfo[2].level,0,seqPoint[2]},{userinfo[1].nickname,userinfo[1].level,1,seqPoint[1]}}
                            if battleAttSeq == 1 then
                                report.p[1][3] = 1
                                report.p[2][3] = 0                               
                            end
                            winer = report.r == 1 and 1 or 2
                        else
                            report, dAliveNum, aAliveNum,battleAttSeq,seqPoint = cross.crossbattle(dBinfo,aBinfo,i,landform,{dStrategy,aStrategy})
                            report.p = {{userinfo[1].nickname,userinfo[1].level,0,seqPoint[2]},{userinfo[2].nickname,userinfo[2].level,1,seqPoint[1]}}
                            if battleAttSeq == 1 then
                                report.p[1][3] = 1
                                report.p[2][3] = 0                               
                            end                           
                            winer = report.r == 1 and 2 or 1
                        end

                        if winer == 1 then 
                            aWinNums = aWinNums + 1
                            table.insert(aWinRound,i)
                            table.insert(battleWiners, userinfo[1].uid .. '-' .. userinfo[1].zid)
                        else
                            dWinNums = dWinNums + 1
                            table.insert(dWinRound,i)
                            table.insert(battleWiners,userinfo[2].uid .. '-' .. userinfo[2].zid)
                        end

                        aAliveNums = aAliveNums + aAliveNum 
                        dAliveNums = dAliveNums + dAliveNum

                        table.insert(reports,report)

                    end

                    local winFlag = aWinNums > dWinNums
                    local winner
                    if winFlag then
                        winner = userinfo[1].uid
                    else
                        winner = userinfo[2].uid
                    end

                    -- 双方获得的排行分
                    local aScore = sevbattleCfg.tmatchRankPt[aWinNums]
                    local dScore = sevbattleCfg.tmatchRankPt[dWinNums]

                    -- 双方获得的商店分
                    local aPoint = matchType == 2 and sevbattleCfg.tmatchPoint2[aWinNums] or sevbattleCfg.tmatchPoint1[aWinNums] 
                    local dPoint = matchType == 2 and sevbattleCfg.tmatchPoint2[dWinNums] or sevbattleCfg.tmatchPoint1[dWinNums]
                    
                    aScore = setPointBattleUserInfo(round,{userinfo[1],userinfo[2]},aScore,aPoint,winFlag,sevbattleCfg) 
                    dScore = setPointBattleUserInfo(round,{userinfo[2],userinfo[1]},dScore,dPoint,not winFlag,sevbattleCfg) 

                    cross:setPointBattleReport({
                        bid = bid,
                        round = round,
                        userinfo1 = {
                            userinfo = userinfo[1],
                            point = aPoint,
                            score = aScore,
                        },
                        userinfo2 = {
                            userinfo = userinfo[2],
                            point = dPoint,
                            score = dScore,
                        },
                        reports = reports,
                        landforms = landforms,
                        battleWiners = battleWiners,
                        winFlag = winFlag,
                    })

                    cross:setPointMatchRanking(bid,round,userinfo[1].uid,userinfo[1].score,userinfo[1].fc,matchType)
                    cross:setPointMatchRanking(bid,round,userinfo[2].uid,userinfo[2].score,userinfo[2].fc,matchType)
                else
                    -- 轮空直接按胜利三场算
                    local aScore = sevbattleCfg.tmatchRankPt[3]
                    local aPoint = matchType == 2 and sevbattleCfg.tmatchPoint2[3] or sevbattleCfg.tmatchPoint1[3]

                    aScore = setPointBattleUserInfo(round,{userinfo[1],userinfo[2]},aScore,aPoint,true,sevbattleCfg) 

                    cross:setPointBattleReport({
                        bid=bid,
                        round=round,
                        userinfo1 = {
                            userinfo = userinfo[1],
                            point = aPoint,
                            score = aScore,
                        },
                        winFlag = true,
                    })

                    cross:setPointMatchRanking(bid,round,userinfo[1].uid,userinfo[1].score,userinfo[1].fc,matchType)
                end

            end -- for end

            cross:setPointMatchBattleDatas(battleList,matchType)

            if not cross:commit() then
                print(cross.db:getError())
                cross.writeCrossLog('commit failed:' .. (cross.db:getError() or 'no db error') )
            else
                cross:setPointMatchEvent(bid,round,matchType)
            end
        end

        return runPointBattle(bid,round,matchType,sevbattleCfg,runNum)
    end

    if tMatch == 1 then
        for _,bidInfo in pairs(allBids) do
            local currRound = cross.getPointCurrentRound(bidInfo.st)
            local bidRound = tonumber(bidInfo.sround) or 1

            for tmpRound=bidRound,currRound do
                print('scoreMatch',tmpRound,currRound,bidInfo.bid,matchType)

                local runReturn = runPointBattle(bidInfo.bid,tmpRound,matchType,sevbattleCfg,0)
                
                cross:delPointMatchRanking(bidInfo.bid,tmpRound,matchType)

                if runReturn then
                    bidInfo.sround = ( tonumber(bidInfo.sround) or 0 ) + 1
                    
                    cross:setautocommit(true)
                    local ret,err = cross:updateBidData(bidInfo)
                    
                    if not ret then 
                        print(err)
                        cross.writeCrossLog('update bid info failed:' .. (err or 'not find db error') )
                    end
                end

            end -- for end

        end
    end

    -- 淘汰赛 ---------------------------------------------


    -- 处理用户的每轮战斗log，是一个json串
    local function getUserLog(ulog)
        if type(ulog) == 'string' then 
            ulog = json.decode(ulog) 
        end

        if not ulog then ulog = {} end

        return ulog
    end

    -- 处理用户数据
    local function setUserData(userinfo,pos,winRounds,landforms,strategy)
        if not userinfo then return end

        local tmpLog = {}
        if pos then 
            tmpLog = {
                tonumber(userinfo.round),
                pos,
                userinfo.status,
                winRounds,
                landforms,
                strategy,
            }

            userinfo.eliminateFlag = 1
            userinfo.pos = pos
        end

        userinfo.log = getUserLog(userinfo.log)
        table.insert(userinfo.log,tmpLog)

        userinfo.round = tonumber(userinfo.round) + 1
    end

    local function runEliminateBattle(bid,round,matchType,matchLandforms,sevbattleCfg)
        local eliminateBattleData = cross:getEliminateBattleDataByBid(bid,round,matchType)
        local battleMatchList = cross.mkMatchList(round,eliminateBattleData,sevbattleCfg.matchList)
        
        for gname,userinfo in pairs(battleMatchList or {}) do
            if #userinfo > 0 then
                if userinfo[2] then
                    --  第一场随机
                    --  第二场为第一场后手玩家先手
                    -- 第三场为前两场剩余坦克数量多的玩家先手
                    -- 如果剩余数量相同，则随机先后手。
                    local aAliveNums, dAliveNums = 0, 0
                    local aWinNums, dWinNums = 0, 0                    
                    local aWinRound,dWinRound = {},{} -- 记录战斗结果

                    -- 地形信息
                    local landforms = cross.getEliminateBattleLandform(matchLandforms,gname)

                    local aBinfo = json.decode(userinfo[1].binfo)                    
                    local dBinfo = json.decode(userinfo[2].binfo)
                    local aStrategy = json.decode(userinfo[1].strategy)
                    local dStrategy = json.decode(userinfo[2].strategy)

                    local attSeq = nil

                    for i=1,3 do
                        -- 1是攻击，2是防守
                        attSeq = cross.getBattleSeq(i,aAliveNums,dAliveNums,attSeq)
                        local report, aAliveNum, dAliveNum,winer,battleAttSeq,seqPoint

                        -- 本场战斗地形
                        local landform = landforms[i]

                        if attSeq == 1 then
                            report, aAliveNum, dAliveNum,battleAttSeq,seqPoint = cross.crossbattle(aBinfo,dBinfo,i,landform,{aStrategy,dStrategy})
                            report.p = {{userinfo[2].nickname,userinfo[2].level,0,seqPoint[2]},{userinfo[1].nickname,userinfo[1].level,1,seqPoint[1]}}
                            if battleAttSeq == 1 then
                                report.p[1][3] = 1
                                report.p[2][3] = 0                               
                            end
                            winer = report.r == 1 and 1 or 2
                        else
                            report, dAliveNum, aAliveNum,battleAttSeq,seqPoint = cross.crossbattle(dBinfo,aBinfo,i,landform,{dStrategy,aStrategy})
                            report.p = {{userinfo[1].nickname,userinfo[1].level,0,seqPoint[2]},{userinfo[2].nickname,userinfo[2].level,1,seqPoint[1]}}
                            if battleAttSeq == 1 then
                                report.p[1][3] = 1
                                report.p[2][3] = 0                               
                            end                           
                            winer = report.r == 1 and 2 or 1
                        end

                        if winer == 1 then 
                            aWinNums = aWinNums + 1
                            table.insert(aWinRound,i)
                        else
                            dWinNums = dWinNums + 1
                            table.insert(dWinRound,i)
                        end

                        aAliveNums = aAliveNums + aAliveNum 
                        dAliveNums = dAliveNums + dAliveNum

                        cross:setEliminateBattleReport({
                            bid = bid,
                            round = round,
                            pos = gname,
                            inning = i,
                            report = report,
                            matchType=matchType,
                        })
                    end

                    local statusInfoOfBattle = cross.getOverStatusByRound(round)

                    local winner
                    if aWinNums > dWinNums then
                        userinfo[1].status = statusInfoOfBattle[1]
                        userinfo[2].status = statusInfoOfBattle[2]

                        -- TODO 商店积分，服内自己加
                        -- userinfo[1].point = tonumber(userinfo[1].point) + (sevbattleCfg.tmatchPoint1[aWinNums] or 0)
                        -- userinfo[2].point = tonumber(userinfo[2].point) + (sevbattleCfg.tmatchPoint1[dWinNums] or 0)

                        userinfo[1].ranking = cross.getRanking(sevbattleCfg.produceRank,round,userinfo[1].status,gname)
                        userinfo[2].ranking = cross.getRanking(sevbattleCfg.produceRank,round,userinfo[2].status,gname)
                        
                        winner = userinfo[1].uid
                    else
                        userinfo[1].status = statusInfoOfBattle[2]
                        userinfo[2].status = statusInfoOfBattle[1]

                        -- 商店积分，服内自己加
                        -- userinfo[1].point = tonumber(userinfo[1].point) + (sevbattleCfg.tmatchPoint1[aWinNums] or 0)
                        -- userinfo[2].point = tonumber(userinfo[2].point) + (sevbattleCfg.tmatchPoint1[dWinNums] or 0)

                        userinfo[1].ranking = cross.getRanking(sevbattleCfg.produceRank,round,userinfo[1].status,gname)
                        userinfo[2].ranking = cross.getRanking(sevbattleCfg.produceRank,round,userinfo[2].status,gname)
                        
                        winner = userinfo[2].uid
                    end

                    setUserData(userinfo[1],gname,aWinRound,landforms,aStrategy)
                    setUserData(userinfo[2],gname,dWinRound,landforms,dStrategy)
                else
                    local statusInfoOfBattle = cross.getOverStatusByRound(round)

                    userinfo[1].status = statusInfoOfBattle[1]

                    -- TODO 商店积分服内自己加
                    -- userinfo[1].point = tonumber(userinfo[1].point) + sevbattleCfg.tmatchPoint1[3]

                    userinfo[1].ranking = cross.getRanking(sevbattleCfg.produceRank,round,userinfo[1].status,gname)

                    setUserData(userinfo[1],gname)
                end
            end

        end -- for gname,userinfo END

        cross:setBattleDatas(eliminateBattleData,matchType)
    end

    if tMatch == 2 then
        for _,bidInfo in pairs(allBids) do
            -- 积分赛最大轮次，要进行淘汰赛必须确定积分赛已经打完了
            local pointBattleMaxRound = cross.getPointBattleMaxRound(bidInfo.st)

            local matchLandforms = {}
            
            matchLandforms = json.decode(bidInfo.landform)

            if (tonumber(bidInfo.sround) or 0) > pointBattleMaxRound then
                local currRound = cross.getEliminateCurrentRound(bidInfo.st)
                local bidRound = tonumber(bidInfo.tround) or 1
        
                for tmpRound=bidRound,currRound do
                    print('eliminateMatch',tmpRound,currRound,bidInfo.bid,matchType)

                    -- 关闭自动提交
                    cross:setautocommit(false)

                    local rstatus,rerror = pcall(runEliminateBattle,bidInfo.bid,tmpRound,matchType,matchLandforms,sevbattleCfg)

                    if not rstatus then
                        cross:rollback()
                        response.errers[bidInfo.bid] = rerror
                    end

                    bidInfo.tround = (tonumber(bidInfo.tround) or 1) + 1

                    bidInfo.landform = cross.randEliminateBattleLandform(bidInfo.tround)
                    
                    local ret,err = cross:updateBidData(bidInfo)

                    if not ret then 
                        cross.writeCrossLog('update bid info failed:' .. (err or 'not find db error') )
                        print(err)
                    end

                    if not cross:commit() then
                        print(cross.db:getError())
                        return cross.writeCrossLog('commit failed:' .. (cross.db:getError() or 'no db error') )
                    end
                    
                end
            end

        end
    end

    response.ret = 0
    response.msg = 'Success'
    return response     
end
