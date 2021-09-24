-- status 1是胜，2是败，3是淘汰
function api_crossserver_battle(request)
    local response = {
        ret=-1,
        msg='error',
        data = {},
    }
    
    local ts = getClientTs()
    local sevbattleCfg = getConfig("serverWarPersonalCfg")

    local crossserver = require "model.crossserver"
    local cross = crossserver.new()

    local roundEvents = cross.getRoundEvents(sevbattleCfg.sevbattlePlayer)
    local battleDatas = cross:getBattleDataByTime(ts,roundEvents[2])   
    
    -- 将数据按bid分离 
    local datas = nil
    if battleDatas and next(battleDatas) then    
        datas = {}
        for k,v in ipairs(battleDatas) do 
            if not datas[v.bid] then datas[v.bid] = {} end  

            if #datas[v.bid] < sevbattleCfg.sevbattlePlayer then
                table.insert(datas[v.bid],v)
            end
        end
    end

    --[[ 获取地形
        param landforms 所有的地形
        param battleRound 战都轮次
        param group 所属组[胜者|败者]
        return a={
                [1] = 2,
                [2] = 5,
                [3] = 6,
            },
    ]]
    local function getGroupLandforms(landforms,battleRound,group)
        -- 获取地形用的round需要在战斗round上加1，因为生成地形的时候key是从1开始的
        -- 分组赛round是0，淘汰赛是1-7
        battleRound = battleRound + 1
        return landforms[battleRound][group]
    end
    
    if datas then
        for bid,data in pairs(datas) do
            local battleLandforms = cross:getCrossBattleLandform(bid)

            local function execBattle(battleList,battleRound)
                -- 关闭自动提交
                cross:setautocommit(false)

                -- 处理用户的每轮战斗log，是一个json串
                local function getUserLog(ulog)
                    if type(ulog) == 'string' then ulog = json.decode(ulog) end
                    if not ulog then ulog = {} end
                    return ulog
                end

                local function setUserData(userinfo,pos,group,winRounds)
                    if not userinfo then return end

                    local tmpLog = {}
                    if pos and group and winRounds then 
                        tmpLog = {
                            tonumber(userinfo.round),
                            pos,
                            group,
                            userinfo.status,
                            winRounds,
                        }

                        userinfo.pos = pos
                    end

                    userinfo.log = getUserLog(userinfo.log)
                    table.insert(userinfo.log,tmpLog)

                    userinfo.round = tonumber(userinfo.round) + 1
                end

                -- 推的太及时了，前端还有15分钟等待时间，所以前台自己在聊天里加一下
                local function setChatMsg(userinfo,cross)
                    -- if userinfo.ranking <= 3 then 
                    --     cross:setChatMsg({
                    --         nickname = userinfo.nickname,
                    --         ranking = userinfo.ranking,
                    --         zid = tonumber(userinfo.zid),
                    --         servers = json.decode(userinfo.servers),
                    --     })
                    -- end  
                end

                if battleList.group then
                    local groupLandforms = getGroupLandforms(battleLandforms,battleRound,cross.WIN)
                    for gname,userinfo in pairs(battleList.group) do      
                        --  第一场随机
                        --  第二场为第一场后手玩家先手
                        -- 第三场为前两场剩余坦克数量多的玩家先手
                        -- 如果剩余数量相同，则随机先后手。
                        local aAliveNums, dAliveNums = 0, 0
                        local aWinNums, dWinNums = 0, 0                    
                        local aWinRound,dWinRound = {},{} -- 记录战斗结果

                        local aBinfo = json.decode(userinfo[1].binfo)                    
                        local dBinfo = json.decode(userinfo[2].binfo)

                        local attSeq
                        for i=1,3 do
                            -- 1是攻击，2是防守
                            attSeq = cross.getBattleSeq(i,aAliveNums,dAliveNums,attSeq)
                            local report, aAliveNum, dAliveNum,winer,battleAttSeq,seqPoint
                            local landform = groupLandforms[gname][i]

                            if attSeq == 1 then
                                report, aAliveNum, dAliveNum,battleAttSeq,seqPoint = cross.crossbattle(aBinfo,dBinfo,i,landform)
                                report.p = {{userinfo[2].nickname,userinfo[2].level,0,seqPoint[2]},{userinfo[1].nickname,userinfo[1].level,1,seqPoint[1]}}
                                if battleAttSeq == 1 then
                                    report.p[1][3] = 1
                                    report.p[2][3] = 0                               
                                end
                                winer = report.r == 1 and 1 or 2
                            else
                                report, dAliveNum, aAliveNum,battleAttSeq,seqPoint = cross.crossbattle(dBinfo,aBinfo,i,landform)
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

                            cross:setBattleReport({
                                bid = userinfo[1].bid,
                                round = userinfo[1].round,
                                pos = gname,
                                group = cross.WIN,
                                inning = i,
                                report = report,
                                landform = landform,
                            })
                        end

                        local winner
                        if aWinNums > dWinNums then
                            userinfo[1].status = cross.WIN
                            userinfo[2].status = cross.LOSE                   
                            userinfo[1].point = tonumber(userinfo[1].point) + sevbattleCfg.winTeam_win
                            userinfo[2].point = tonumber(userinfo[2].point) + sevbattleCfg.winTeam_lose
                            
                            winner = userinfo[1].uid
                        else
                            userinfo[1].status = cross.LOSE
                            userinfo[2].status = cross.WIN       
                            userinfo[1].point = tonumber(userinfo[1].point) + sevbattleCfg.winTeam_lose
                            userinfo[2].point = tonumber(userinfo[2].point) + sevbattleCfg.winTeam_win
                            
                            winner = userinfo[2].uid
                        end             
                                                                  
                        setUserData(userinfo[1],gname,cross.WIN,aWinRound)
                        setUserData(userinfo[2],gname,cross.WIN,dWinRound)
                    end            
                end
        
                -- 胜者组奇数轮开打
                if battleList.win then
                    local groupLandforms = getGroupLandforms(battleLandforms,battleRound,cross.WIN)
                    for gname,userinfo in pairs(battleList.win) do   
                        if userinfo[1].round % 2 == 1 then
                            local aAliveNums, dAliveNums = 0, 0
                            local aWinNums, dWinNums = 0, 0  
                            local aWinRound,dWinRound = {},{} -- 记录战斗结果
                            
                            local aBinfo = json.decode(userinfo[1].binfo)                            
                            local dBinfo = json.decode(userinfo[2].binfo)

                            local attSeq
                            for i=1,3 do
                                -- 1是攻击，2是防守
                                attSeq = cross.getBattleSeq(i,aAliveNums,dAliveNums,attSeq)
                                local report, aAliveNum, dAliveNum,battleAttSeq,seqPoint
                                local winer = nil
                                local landform = groupLandforms[gname][i]

                                if attSeq == 1 then
                                    report, aAliveNum, dAliveNum,battleAttSeq,seqPoint = cross.crossbattle(aBinfo,dBinfo,i,landform)
                                    report.p = {{userinfo[2].nickname,userinfo[2].level,0,seqPoint[2]},{userinfo[1].nickname,userinfo[1].level,1,seqPoint[1]}}
                                    if battleAttSeq == 1 then
                                        report.p[1][3] = 1
                                        report.p[2][3] = 0                               
                                    end                                         
                                    winer = report.r == 1 and 1 or 2
                                else
                                    report, dAliveNum, aAliveNum,battleAttSeq,seqPoint = cross.crossbattle(dBinfo,aBinfo,i,landform)
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

                                cross:setBattleReport({
                                    bid = userinfo[1].bid,
                                    round = userinfo[1].round,
                                    pos = gname,
                                    group = cross.WIN,
                                    inning = i,
                                    report = report,
                                    landform = landform,
                                })
                            end

                            local setRankingFlag = tonumber(userinfo[1].round) == roundEvents[2]

                            local winner = nil
                            if aWinNums > dWinNums then
                                userinfo[1].status = cross.WIN
                                userinfo[2].status = cross.LOSE
                                userinfo[1].point = tonumber(userinfo[1].point) + sevbattleCfg.winTeam_win
                                userinfo[2].point = tonumber(userinfo[2].point) + sevbattleCfg.winTeam_lose

                                if setRankingFlag then 
                                    userinfo[1].ranking = 1
                                    userinfo[2].ranking = 2
                                end
                                
                                winner = userinfo[1].uid
                            else
                                userinfo[1].status = cross.LOSE
                                userinfo[2].status = cross.WIN
                                userinfo[1].point = tonumber(userinfo[1].point) + sevbattleCfg.winTeam_lose
                                userinfo[2].point = tonumber(userinfo[2].point) + sevbattleCfg.winTeam_win

                                if setRankingFlag then 
                                    userinfo[1].ranking = 2
                                    userinfo[2].ranking = 1                          
                                end
                                
                                winner = userinfo[2].uid
                            end

                            if setRankingFlag then
                                setChatMsg(userinfo[1],cross)
                                setChatMsg(userinfo[2],cross)
                            end
                                                        
                            setUserData(userinfo[1],gname,cross.WIN,aWinRound)
                            setUserData(userinfo[2],gname,cross.WIN,dWinRound)
                        else

                            setUserData(userinfo[1])
                            setUserData(userinfo[2])
                        end
                    end
                end

                -- 败者组每轮都开打
                if battleList.lose then
                    local groupLandforms = getGroupLandforms(battleLandforms,battleRound,cross.LOSE)
                    for gname,userinfo in pairs(battleList.lose) do      
                        local aAliveNums, dAliveNums = 0, 0
                        local aWinNums, dWinNums = 0, 0   
                        local aWinRound,dWinRound = {},{} -- 记录战斗结果                 

                        local aBinfo = json.decode(userinfo[1].binfo)
                        local dBinfo = json.decode(userinfo[2].binfo)

                        local attSeq
                        for i=1,3 do
                            -- 1是攻击，2是防守
                            attSeq = cross.getBattleSeq(i,aAliveNums,dAliveNums,attSeq)
                            local report, aAliveNum, dAliveNum, battleAttSeq,seqPoint
                            local winer = nil
                            local landform = groupLandforms[gname][i]

                            if attSeq == 1 then
                                report, aAliveNum, dAliveNum,battleAttSeq,seqPoint = cross.crossbattle(aBinfo,dBinfo,i,landform)
                                report.p = {{userinfo[2].nickname,userinfo[2].level,0,seqPoint[2]},{userinfo[1].nickname,userinfo[1].level,1,seqPoint[1]}}
                                if battleAttSeq == 1 then
                                    report.p[1][3] = 1
                                    report.p[2][3] = 0                               
                                end      
                                winer = report.r == 1 and 1 or 2
                            else
                                report, dAliveNum, aAliveNum,battleAttSeq,seqPoint = cross.crossbattle(dBinfo,aBinfo,i,landform)
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

                            cross:setBattleReport({
                                bid = userinfo[1].bid,
                                round = userinfo[1].round,
                                pos = gname,
                                group = cross.LOSE,
                                inning = i,
                                report = report,
                                landform = landform,
                            })
                        end
                        
                        local winner
                        if aWinNums > dWinNums then
                            userinfo[1].status = cross.LOSE
                            userinfo[2].status = cross.DENY
                            userinfo[1].point = tonumber(userinfo[1].point) + sevbattleCfg.loseTeam_win
                            userinfo[2].point = tonumber(userinfo[2].point) + sevbattleCfg.loseTeam_lose                        
                            userinfo[2].ranking = cross.getRanking(sevbattleCfg.produceRank,userinfo[2].round,gname)
                            setChatMsg(userinfo[2],cross)
                            
                            winner = userinfo[1].uid
                        else
                            userinfo[1].status = cross.DENY
                            userinfo[2].status = cross.LOSE
                            userinfo[1].point = tonumber(userinfo[1].point) + sevbattleCfg.loseTeam_lose
                            userinfo[2].point = tonumber(userinfo[2].point) + sevbattleCfg.loseTeam_lose
                            userinfo[1].ranking = cross.getRanking(sevbattleCfg.produceRank,userinfo[1].round,gname)
                            setChatMsg(userinfo[1],cross)
                            
                            winner = userinfo[2].uid
                        end    

                        setUserData(userinfo[1],gname,cross.LOSE,aWinRound)
                        setUserData(userinfo[2],gname,cross.LOSE,dWinRound)
                    end       
                end

                cross:setBattleDatas(data)

                if cross:commit() then
                    -- 聊天推送
                    -- cross:pushChat()
                else
                    cross.writeCrossLog('commit failed:' .. (cross.db:getError() or 'no db error') )
                end
                
            end
            
            local currentRound = cross.getCurrentRound(data[1].st)
            print('\r\n------------------------------------------\r\nbid:',bid,'|','currround:',currentRound)
            data = cross.delDenyUserData(data)
            local dataRound = tonumber(data[1].round)

            for inum = dataRound,currentRound do 
                print('run start', '|', 'prevround/cround:',inum,'/',currentRound)
                data = cross.checkBattleData(data,sevbattleCfg)        
                local battleList = cross.mkMatchList(data,sevbattleCfg.matchList,roundEvents)

                local execStatus,execError = pcall(execBattle,battleList,inum)
                print('run end:', '|', 'bid:' .. (bid or 'no bid'),'error:',execError)
                if not execStatus then     
                    cross.writeCrossLog((bid or 'not bid') .. ' : ' .. execError)
                end
            end
            
        end
    end

    response.ret = 0
    response.msg = 'Success'
    return response     
end
