function api_cross_getpvplist(request)

    local response = {
        ret=-1,
        msg='error',
        data = {},
    }

    local ts = request.params.ts and request.params.ts or getClientTs()
    local lts = request.params.lts and request.params.lts or ts
    local btype = request.params.btype and request.params.btype or nil
    local uid = request.uid
    local battleList = {}

    require "model.skyladderserver"
    local skyladderserver = model_skyladderserver()
    local skyladderCfg = getConfig("skyladderCfg")
    local base = skyladderserver.getStatus()
    local db = getCrossDbo()
    db.conn:setautocommit(false)
    
    local plat = getClientPlat()
    local projectsIncluded = skyladderCfg.projectsIncluded
    local noShow = skyladderCfg.noShow[plat] or skyladderCfg.noShow.default
    for pid,ptype in pairs(projectsIncluded) do
        if not noShow[tostring(pid)] then
            if tonumber(pid) == 1 and tonumber(pid) == btype then
                local sevbattleCfg = getConfig("serverWarPersonalCfg")
    
                -- 个人跨服战
                local allDatas = db:getAllRows("SELECT bid,st,et FROM tank_kuafu.battle WHERE st < :ts and et > :lts GROUP BY bid limit 1",{ts=ts,lts=lts})
                ptb:p(allDatas)
                for i,v in pairs(allDatas) do
                    if v.bid then
                        print('bid',v.bid,v.st,v.et)
                        local result = skyladderserver.getBattleData(pid,v.bid)
                        if type(result) == 'table' and result.data and type(result.data) == 'table' then
                            local userData = result.data.d or {}
                            local battleList = result.data.l or {}
                            if type(battleList)=='table' then
                                local race1 = battleList[1] or {}
                                local race2 = battleList[2] or {}
                                local userinfo = {}

                                for uindex,udata in pairs(userData) do
                                    if udata.zid and udata.uid then
                                        userinfo[udata.uid..'-'..udata.zid] = udata
                                    end
                                end

                                for race_index,race_info in pairs(battleList) do
                                    for round,rdata in pairs(race_info) do
                                        for group,gdata in pairs(rdata) do
                                            for sgroup,sgdata in pairs(gdata) do
                                                local have = skyladderserver.getUpdataStatus('cross',race_index,round,group,sgroup)
                                                if not have then
                                                    local uKey1 = sgdata[1]
                                                    local uKey2 = sgdata[2]
                                                    local winner = sgdata[3] and userinfo[sgdata[3]].uid or nil
                                                    local winnerzid = sgdata[3] and userinfo[sgdata[3]].zid or nil
                                                    print(uKey1,uKey2)
                                                    
                                                    local params = {
                                                        s = 1, -- 类型1 类型2
                                                        t = v.st + (86400*(2+(race_index-1))) + (3600*20) + (sevbattleCfg.battleTime*3), --时间戳
                                                        id1 = userinfo[uKey1].uid, -- 自己id
                                                        id2 = userinfo[uKey2].uid, -- 对方id
                                                        n1 = userinfo[uKey1].nickname, -- 自己名字
                                                        n2 = userinfo[uKey2].nickname, -- 对方名字
                                                        z1 = userinfo[uKey1].zid, -- 自己区id
                                                        z2 = userinfo[uKey2].zid, -- 对方区id
                                                        fc1 = userinfo[uKey1].fc, -- 自己战力
                                                        fc2 = userinfo[uKey2].fc, -- 对方战力
                                                        pic1 = userinfo[uKey1].pic, -- 自己pic
                                                        pic2 = userinfo[uKey2].pic, -- 对方pic
                                                        npc1 = userinfo[uKey1].npc, -- 自己是否npc
                                                        npc2 = userinfo[uKey2].npc, -- 对方是否npc
                                                        win = winnerzid..'-'..winner-- 胜利者id
                                                    }
                                                    ptb:p(params)
                                                    skyladderserver.saveBattleData(base.cubid,'person',1,1,params)
                                                    local save = skyladderserver.setUpdataStatus('cross',race_index,round,group,sgroup)
                                                end
                                            end
                                        end
                                    end
                                end
                            end
                        end
                    end
                end
            elseif tonumber(pid) == 2 and tonumber(pid) == btype then
                local sevbattleCfg = getConfig("serverWarTeamCfg")
                local acrossserver = require "model.acrossserver"
                local across = acrossserver.new()
                local allDatas = db:getAllRows("SELECT bid,st,et FROM tank_kuafu.alliance WHERE st < :ts and et > :lts GROUP BY bid limit 1",{ts=ts,lts=ts})

                local function getBattleTime(round,group,st)
                    local round = tonumber(round) or 0
                    local sevbattleCfg = getConfig("serverWarTeamCfg")
                    local timeGroup = {
                        a = 1,
                        b = 2,
                        c = 3,
                        d = 4,
                    }
                    local hour = sevbattleCfg.startBattleTs[timeGroup[group]]
                    local t = st + ((round - 1) * 86400) + (hour[1] * 3600) + (hour[2] * 60) + sevbattleCfg.warTime + 300

                    return t
                end
    
                for i,v in pairs(allDatas) do
                    if v.bid then
                        print('bid',v.bid,v.st,v.et)
                        local result = skyladderserver.getBattleData(pid,v.bid)
                        if type(result) == 'table' and result.data and type(result.data) == 'table' then
                            local userinfo = result.data.ainfo or {}
                            local battleList = result.data.schedule or {}

                            for round,rdata in pairs(battleList) do
                                print('round',round)
                                for sgroup,sgdata in pairs(rdata) do
                                    local have = skyladderserver.getUpdataStatus('across',round,sgroup)
                                    if not have then
                                        local logts = getBattleTime(round,sgroup,v.st)
                                        local uKey1 = sgdata[1] or 0
                                        local uKey2 = sgdata[2] or 0
                                        local winner = sgdata[3] and userinfo[sgdata[3]].aid or nil
                                        local winnerzid = sgdata[3] and userinfo[sgdata[3]].zid or nil
                                        local losser
                                        local losserzid
                                        if uKey1 == sgdata[3] then
                                            if uKey2 and userinfo[uKey2] and type(userinfo[uKey2]) == 'table' then
                                                losser = userinfo[uKey2].aid or 0
                                                losserzid = userinfo[uKey2].zid or 0
                                            else
                                                losser = 0
                                                losserzid = 0
                                            end
                                        else
                                            if uKey1 and userinfo[uKey1] and type(userinfo[uKey1]) == 'table' then
                                                losser = userinfo[uKey1].aid or 0
                                                losserzid = userinfo[uKey1].zid or 0
                                            else
                                                losser = 0
                                                losserzid = 0
                                            end
                                        end

                                        local winMemlist = across:getAllianceMemberList(v.bid,winnerzid,winner)
                                        if winMemlist and type(winMemlist) == 'table' then
                                            local uidList = {}
                                            for i,v in pairs(winMemlist) do
                                                table.insert(uidList,{id=v.uid,z=v.zid,n=v.nickname,p=v.pic})
                                            end
                                            skyladderserver.setAllianceMemberList(base.cubid,2,winnerzid,winner,uidList)
                                        end

                                        local params = {
                                            s = 1,
                                            r = 2,
                                            t = logts,
                                        }
                                        params.win = winner
                                        params.winzid = winnerzid
                                        if uKey1 and userinfo[uKey1] and type(userinfo[uKey1]) == 'table' then
                                            params.id1 = userinfo[uKey1].aid
                                            params.n1 = userinfo[uKey1].name
                                            params.z1 = userinfo[uKey1].zid
                                            params.fc1 = userinfo[uKey1].fight
                                        else
                                            params.id1 = 0
                                            params.n1 = ''
                                            params.z1 = 0
                                            params.fc1 = 0
                                        end
                                        
                                        params.loss = losser
                                        params.losszid = losserzid
                                        if uKey2 and userinfo[uKey2] and type(userinfo[uKey2]) == 'table' then
                                            params.id2 = userinfo[uKey2].aid
                                            params.n2 = userinfo[uKey2].name
                                            params.z2 = userinfo[uKey2].zid
                                            params.fc2 = userinfo[uKey2].fight
                                        else
                                            params.id2 = 0
                                            params.n2 = ''
                                            params.z2 = 0
                                            params.fc2 = 0
                                        end
                                        print('params')
                                        ptb:p(params)
                                        skyladderserver.saveBattleData(base.cubid,'alliance',2,6,params)
                                        
                                        if winMemlist then
                                            local addScore = skyladderCfg.allianceToPersonPoint or 0
                                            for i,v in pairs(winMemlist) do
                                                local params = {
                                                    s = 3, -- 类型1 类型2
                                                    r = 2,
                                                    t = logts, --时间戳
                                                    id1 = v.uid, -- 自己id
                                                    n1 = v.nickname, -- 自己名字
                                                    z1 = v.zid, -- 自己区id
                                                    pic1 = v.pic, -- 自己pic
                                                    add1 = addScore, -- 增加的天梯分
                                                }

                                                skyladderserver.saveRankData(base.cubid,'person',2,v.zid,v.uid,v.nickname,addScore,v.fc,v.pic,params)
                                            end
                                        end
                                        local save = skyladderserver.setUpdataStatus('across',round,sgroup)
                                    end
                                end
                            end
                        end
                    end
                end
            elseif tonumber(pid) == 3 and tonumber(pid) == btype then
                local crossserver = require "model.worldserver"
                local cross = crossserver.new()
                
                local allDatas = db:getAllRows("SELECT bid,st,et FROM tank_kuafu.worldwar_bid WHERE st < :ts and et > :lts GROUP BY bid limit 1",{ts=ts,lts=ts})
                local sevbattleCfg = getConfig("worldWarCfg")

                local function getBattleType(matchType,tMatch)
                    local battleType = 1
                    if matchType == 1 then  -- 大师
                        if tMatch == 1 then -- 积分赛
                            battleType = 3
                        else -- 淘汰赛
                            battleType = 2
                        end
                    else -- 精英
                        if tMatch == 1 then
                            battleType = 5  -- 积分
                        else
                            battleType = 4  -- 淘汰
                        end
                    end
                end
                
                for i,v in pairs(allDatas) do
                    if v.bid then
                        print('bid',v.bid,v.st,v.et)
                        -- 循环积分赛 大师
                        for round=1,73 do
                            local have = skyladderserver.getUpdataStatus('worldwar',1,1,round)
                            if not have then
                                local allBattleDatas = db:getAllRows("SELECT * FROM tank_kuafu.worldwar_battlelog WHERE bid = :bid and round = :round GROUP BY bid limit 1",{bid=v.bid,round=round})
                                if allBattleDatas then
                                    for _,battleData in pairs(allBattleDatas) do
                                        local winner = battleData.winerId and battleData.winerId or nil
                                        local winnerzid = battleData.wZid and battleData.wZid or nil

                                        if winner and winnerzid then
                                            local params = {
                                                s = 1, -- 类型1 类型2
                                                t = battleData.updated_at, --时间戳
                                                id1 = battleData.winerId, -- 自己id
                                                id2 = battleData.loserId, -- 对方id
                                                n1 = battleData.wNickname, -- 自己名字
                                                n2 = battleData.lNickname, -- 对方名字
                                                z1 = battleData.wZid, -- 自己区id
                                                z2 = battleData.lZid, -- 对方区id
                                                fc1 = battleData.wFc, -- 自己战力
                                                fc2 = battleData.lFc, -- 对方战力
                                                pic1 = battleData.wPic, -- 自己pic
                                                pic2 = battleData.lPic, -- 对方pic
                                                win = winnerzid..'-'..winner-- 胜利者id
                                            }
                                            ptb:p(params)
                                            local battleType = getBattleType(1,1)
                                            skyladderserver.saveBattleData(base.cubid,'person',3,battleType,params)
                                        end
                                    end
                                    local save = skyladderserver.setUpdataStatus('worldwar',1,1,round)
                                end
                            end
                            
                            -- 循环积分赛 精英
                            local have = skyladderserver.getUpdataStatus('worldwar',2,1,round)
                            if not have then
                                local allBattleDatas = db:getAllRows("SELECT * FROM tank_kuafu.worldwar_battlelog WHERE bid = :bid and round = :round GROUP BY bid limit 1",{bid=v.bid,round=round})
                                if allBattleDatas then
                                    for _,battleData in pairs(allBattleDatas) do
                                        local winner = battleData.winerId and battleData.winerId or nil
                                        local winnerzid = battleData.wZid and battleData.wZid or nil
                                        local round = battleData.round or nil
                                        
                                        if winner and winnerzid then
                                            local params = {
                                                s = 1, -- 类型1 类型2
                                                t = battleData.updated_at, --时间戳
                                                id1 = battleData.winerId, -- 自己id
                                                id2 = battleData.loserId, -- 对方id
                                                n1 = battleData.wNickname, -- 自己名字
                                                n2 = battleData.lNickname, -- 对方名字
                                                z1 = battleData.wZid, -- 自己区id
                                                z2 = battleData.lZid, -- 对方区id
                                                fc1 = battleData.wFc, -- 自己战力
                                                fc2 = battleData.lFc, -- 对方战力
                                                pic1 = battleData.wPic, -- 自己pic
                                                pic2 = battleData.lPic, -- 对方pic
                                                win = winnerzid..'-'..winner-- 胜利者id
                                            }
                                            ptb:p(params)
                                            local battleType = getBattleType(2,1)
                                            skyladderserver.saveBattleData(base.cubid,'person',3,battleType,params)
                                        end
                                    end
                                    local save = skyladderserver.setUpdataStatus('worldwar',2,1,round)
                                end
                            end
                        end                
                                        
                                        
                                        
                                        
                                        
                                        
                        
                        -- 处理淘汰赛 大师
                        local result = skyladderserver.getBattleData(pid,v.bid)
                        if type(result) == 'table' and result.data and type(result.data) == 'table' then
                            local userData = result.data.info or {}
                            local battleList = result.data.schedule or {}
                            local userinfo = {}

                            for _,uinfo in pairs(userData) do
                                if uinfo[1] and uinfo[2] then
                                    userinfo[uinfo[1]..'-'..uinfo[2]] = uinfo
                                end
                            end

                            local n = 0
                            local t = 0
                            for round,rdata in pairs(battleList) do
                                print('round',round)
                                local hour = 0
                                if n = 0 then
                                    hour = sevbattleCfg.tmatch1starttime1[1] * 3600 + sevbattleCfg.tmatch1starttime1[2] * 60
                                else
                                    hour = sevbattleCfg.tmatch2starttime1[1] * 3600 + sevbattleCfg.tmatch2starttime1[2] * 60
                                end
                                local logts = v.st + (86400 * (sevbattleCfg.signuptime + sevbattleCfg.pmatchdays)) + (86400*(round+t)) + hour --时间戳
                                for sgroup,sgdata in pairs(rdata) do
                                    local have = skyladderserver.getUpdataStatus('worldwar',1,2,round,sgroup)
                                    if not have then
                                        local logts = logts
                                        local uKey1 = sgdata[1] or 0
                                        local uKey2 = sgdata[2] or 0
                                        local winner,winnerzid
                                        if sgdata[3] and userinfo[sgdata[3]] and type(userinfo[sgdata[3]]) == 'table' and userinfo[sgdata[3]][2] then
                                            winner = userinfo[sgdata[3]][2]
                                            winnerzid = userinfo[sgdata[3]][1]
                                        end
                                        
                                        if not userinfo[uKey1] then
                                            userinfo[uKey1] = {}
                                        end
                                        
                                        if not userinfo[uKey2] then
                                            userinfo[uKey2] = {}
                                        end

                                        if winner and winnerzid then
                                            local params = {
                                                s = 1, -- 类型1 类型2
                                                t = logts
                                                id1 = userinfo[uKey1][2], -- 自己id
                                                id2 = userinfo[uKey2][2], -- 对方id
                                                n1 = userinfo[uKey1][4], -- 自己名字
                                                n2 = userinfo[uKey2][4], -- 对方名字
                                                z1 = userinfo[uKey1][1], -- 自己区id
                                                z2 = userinfo[uKey2][1], -- 对方区id
                                                fc1 = userinfo[uKey1][3], -- 自己战力
                                                fc2 = userinfo[uKey2][3], -- 对方战力
                                                pic1 = userinfo[uKey1][6], -- 自己pic
                                                pic2 = userinfo[uKey2][6], -- 对方pic
                                                win = winnerzid..'-'..winner -- 胜利者id
                                            }
                                            ptb:p(params)
                                            local battleType = getBattleType(1,2)
                                            skyladderserver.saveBattleData(base.cubid,'person',3,1,params)
                                        end
                                        local save = skyladderserver.setUpdataStatus('worldwar',1,2,round,sgroup)
                                    end
                                end
                            end
                        end
                        
                        -- 处理淘汰赛 精英
                        local result = skyladderserver.getBattleData(pid,v.bid)
                        if type(result) == 'table' and result.data and type(result.data) == 'table' then
                            local userData = result.data.info or {}
                            local battleList = result.data.schedule or {}
                            local userinfo = {}

                            for _,uinfo in pairs(userData) do
                                if uinfo[1] and uinfo[2] then
                                    userinfo[uinfo[1]..'-'..uinfo[2]] = uinfo
                                end
                            end

                            local n = 0
                            local t = 0
                            for round,rdata in pairs(battleList) do
                                print('round',round)
                                local hour = 0
                                if n = 0 then
                                    hour = sevbattleCfg.tmatch1starttime2[1] * 3600 + sevbattleCfg.tmatch1starttime2[2] * 60
                                else
                                    hour = sevbattleCfg.tmatch2starttime2[1] * 3600 + sevbattleCfg.tmatch2starttime2[2] * 60
                                end
                                local logts = v.st + (86400 * (sevbattleCfg.signuptime + sevbattleCfg.pmatchdays)) + (86400*(round+t)) + hour --时间戳
                                for sgroup,sgdata in pairs(rdata) do
                                    local have = skyladderserver.getUpdataStatus('worldwar',2,2,round,sgroup)
                                    if not have then
                                        local logts = getBattleTime(round,sgroup,v.st)
                                        local uKey1 = sgdata[1] or 0
                                        local uKey2 = sgdata[2] or 0
                                        local winner,winnerzid
                                        if sgdata[3] and userinfo[sgdata[3]] and type(userinfo[sgdata[3]]) == 'table' and userinfo[sgdata[3]][2] then
                                            winner = userinfo[sgdata[3]][2]
                                            winnerzid = userinfo[sgdata[3]][1]
                                        end
                                        
                                        if not userinfo[uKey1] then
                                            userinfo[uKey1] = {}
                                        end
                                        
                                        if not userinfo[uKey2] then
                                            userinfo[uKey2] = {}
                                        end

                                        if winner and winnerzid then
                                            local params = {
                                                s = 1, -- 类型1 类型2
                                                t = logts
                                                id1 = userinfo[uKey1][2], -- 自己id
                                                id2 = userinfo[uKey2][2], -- 对方id
                                                n1 = userinfo[uKey1][4], -- 自己名字
                                                n2 = userinfo[uKey2][4], -- 对方名字
                                                z1 = userinfo[uKey1][1], -- 自己区id
                                                z2 = userinfo[uKey2][1], -- 对方区id
                                                fc1 = userinfo[uKey1][3], -- 自己战力
                                                fc2 = userinfo[uKey2][3], -- 对方战力
                                                pic1 = userinfo[uKey1][6], -- 自己pic
                                                pic2 = userinfo[uKey2][6], -- 对方pic
                                                win = winnerzid..'-'..winner -- 胜利者id
                                            }
                                            ptb:p(params)
                                            local battleType = getBattleType(2,2)
                                            skyladderserver.saveBattleData(base.cubid,'person',3,1,params)
                                        end
                                        local save = skyladderserver.setUpdataStatus('worldwar',2,2,round,sgroup)
                                    end
                                end
                            end
                        end
                    end
                end
            elseif tonumber(pid) == 5 and tonumber(pid) == btype then
                local sevbattleCfg = getConfig("serverWarLocalCfg")
                local acrossserver = require "model.areawarserver"
                acrossserver.construct()
                local addDatas = db:getAllRows("SELECT bid,st,et FROM tank_kuafu.areawar_bid WHERE st < :ts and et > :lts GROUP BY bid",{ts=ts,lts=ts})

                for i,v in pairs(addDatas) do
                    if v.bid then
                        print('bid',v.bid,v.st,v.et)
                        local result = skyladderserver.getBattleData(pid,v.bid)
                        if type(result) == 'table' and result.data and type(result.data) == 'table' then
                            local userinfo = result.data.ainfo or {}

                            local battleList = result.data.schedule or {}
                            local countField = skyladderCfg.allianceCountField
                            
                            
                            for round,rdata in pairs(battleList) do
                                print('round',round)
                                for sgroup,sgdata in pairs(rdata) do
                                    local have = skyladderserver.getUpdataStatus('areateamwars',round,sgroup)
                                    if not have then
                                        local winner,iswin,winAid,winscore
                                        local totalLadderPoint = 0
                                        local avgLadderPoint = 0
                                        for sn,sinfo in pairs(sgdata) do
                                            if sinfo and type(sinfo) == 'table' and sinfo[1] then
                                                local tempinfo = string.split(sinfo[1],'-') or {}
                                                local zid = tempinfo[1]
                                                local aid = tempinfo[2]
                                                if tonumber(sn) == 1 then
                                                    winner = sinfo[1]
                                                    winAid = aid
                                                    winscore = 0
        
                                                    local sadata = skyladderserver.refRankData(base.cubid,'alliance',zid,aid)
                                                    if sadata then
                                                        for i,v in pairs(countField) do
                                                            if sadata[i] then
                                                                winscore = winscore + tonumber(sadata[i])
                                                            end
                                                        end
                                                    end
                                                    iswin = true
                                                else
                                                    local sadata = skyladderserver.refRankData(base.cubid,'alliance',zid,aid)
                                                    if sadata then
                                                        for i,v in pairs(countField) do
                                                            if sadata[i] then
                                                                totalLadderPoint = totalLadderPoint + tonumber(sadata[i])
                                                            end
                                                        end
                                                    end
                                                end
                                            end
                                        end
                                        
                                        if #sgdata and (#sgdata - 1) > 1 then
                                            avgLadderPoint = math.ceil(totalLadderPoint / (#overPoints - 1))
                                        end
                                        
                                        local logts = v.st + (86400 * (sevbattleCfg.signuptime + sevbattleCfg.pmatchdays)) + (86400*(round+t)) + hour --时间戳
                                        local params = {
                                            s = 1,
                                            r = 5,
                                            t = ts,
                                            item = {},
                                            avg = avgLadderPoint,
                                            winscore = winscore,
                                        }

                                        local winMemlist = {}
                                        for sn,sinfo in pairs(sgdata) do
                                            if sinfo and type(sinfo) == 'table' and sinfo[1] then
                                                local tempinfo = string.split(sinfo[1],'-') or {}
                                                local zid = tempinfo[1]
                                                local aid = tempinfo[2]
                                                local name,fc
                                                
                                                if not userinfo[sinfo[1]] or type(userinfo[sinfo[1]]) ~= 'table' then
                                                    userinfo[sinfo[1]] = {}
                                                    writeLog(sinfo[1],'notallianceinfo')
                                                end
                                                
                                                if sinfo[1] == winner then
                                                    params.win = zid..'-'..aid
                                                    params.winzid = zid
                                                    params.winname = userinfo[sinfo[1]][1]
                                                    name = userinfo[sinfo[1]][1] or ''
                                                    fc = userinfo[sinfo[1]][4] or 0
                                                    winMemlist = acrossserver.getUserListFromDb(v.bid,zid,aid)
                                                    if winMemlist and type(winMemlist) == 'table' then
                                                        local uidList = {}
                                                        for _,minfo in pairs(winMemlist) do
                                                            table.insert(uidList,{id=minfo.uid,z=minfo.zid,n=minfo.nickname,p=minfo.pic})
                                                        end
                                                        skyladderserver.setAllianceMemberList(base.cubid,5,aInfo.zid,aInfo.aid,uidList)
                                                    end
                                                else
                                                    name = userinfo[sinfo[1]][1] or ''
                                                    fc = userinfo[sinfo[1]][4] or 0
                                                    
                                                    local memberList = acrossserver.acrossserver.getUserListFromDb(v.bid,zid,aid)
                                                    if memberList and type(memberList) == 'table' then
                                                        local uidList = {}
                                                        for _,minfo in pairs(memberList) do
                                                            table.insert(uidList,{id=minfo.uid,z=minfo.zid,n=minfo.nickname,p=minfo.pic})
                                                        end
                                                        skyladderserver.setAllianceMemberList(base.cubid,5,zid,aid,uidList)
                                                    end
                                                end
                                            end
                                            
                                            local info = {}
                                            info.id = aid
                                            info.n = name
                                            info.z = zid
                                            info.fc = fc
                                            table.insert(params.item,info)
                                        end

                                        if params.win then
                                            if #sgdata == 1 then
                                                params.nb = 1
                                            end
                                            
                                            skyladderserver.saveBattleDataFromAreaServer(base.cubid,'alliance',5,7,params)
                                            if winMemlist and type(winMemlist) == 'table' then
                                                local addScore = skyladderCfg.allianceToPersonPoint or 0
                                                for _,minfo in pairs(winMemlist) do
                                                    local params = {
                                                        s = 3, -- 类型1 类型2
                                                        r = 5,
                                                        t = ts, --时间戳
                                                        id1 = minfo.uid, -- 自己id
                                                        n1 = minfo.nickname, -- 自己名字
                                                        z1 = minfo.zid, -- 自己区id
                                                        pic1 = minfo.pic, -- 自己pic
                                                        add1 = addScore, -- 增加的天梯分
                                                    }

                                                    skyladderserver.saveRankData(base.cubid,'person',5,minfo.zid,minfo.uid,minfo.nickname,addScore,minfo.fc,minfo.pic,params)
                                                end
                                            end
                                        end
                                        local save = skyladderserver.getUpdataStatus('areateamwars',round,sgroup)
                                    end
                                end
                            end
                        end
                    end
                end
            end
        end
    end
    
    
    

    
    db.conn:commit()
    print('fin')
    

    return response
end
