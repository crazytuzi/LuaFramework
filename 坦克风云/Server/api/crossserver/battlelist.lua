-- status 1是淘汰，2是胜利，3是失败
function api_crossserver_battlelist(request)
    local response = {
        ret=-1,
        msg='error',
        data = {
            d = {},
            l = {},
            repair=nil,
        },
    }
    
    -- 战斗标识
    local bid = request.params.bid

    if bid == nil then
        response.ret = -102
        return response
    end

    local battlelist = {{},{}}
    local nextBattleList = {}   -- 下一轮的战斗列表

    local crossserver = require "model.crossserver"
    local cross = crossserver.new()

    local sevbattleCfg = getConfig("serverWarPersonalCfg")
    local roundEvents = cross.getRoundEvents(sevbattleCfg.sevbattlePlayer)
    local datas = cross:getBattleDataByBid(bid)

    if datas then     
        -- repair 如果有数据修复的操作，需要client重新推送一次数据
        datas,response.data.repair = cross.checkBattleData(datas,sevbattleCfg)     
        nextBattleList = cross.mkMatchList(datas,sevbattleCfg.matchList,roundEvents)   

        -- 将数据格式化成前端需要的格式
        for k,v in pairs(datas) do 
            local log = json.decode(v.log)

            if type(log) == 'table' then
                -- logv 1 round,2 pos,3 败/胜者组, 4战斗结果，5比分
                for _,logv in pairs(log) do                    
                    if next(logv) then
                        local logk = logv[1]
                        local list = battlelist[2]

                        -- 如果是小组赛，分配到battlist1中
                        if logv[1] == 0 then                            
                            list = battlelist[1]
                            logk = 1
                        end

                        -- 不同的服的uid可能一样的情况，需要拼上zid
                        local uidFlag = cross.mkBattleUidKey(v.uid,v.zid)

                        if not list[logk] then list[logk] = {} end
                        if not list[logk][cross.WIN] then list[logk][cross.WIN] = {} end
                        if not list[logk][cross.LOSE] then list[logk][cross.LOSE] = {} end                        
                        if not list[logk][logv[3]][logv[2]] then list[logk][logv[3]][logv[2]] = {} end

                        if not list[logk][logv[3]][logv[2]][1] then
                            table.insert(list[logk][logv[3]][logv[2]],uidFlag)
                        else
                            list[logk][logv[3]][logv[2]][2] = uidFlag
                        end

                        -- 在胜利组胜利或者在失败组不淘汰标识置为胜利
                        if (logv[3] == cross.WIN and logv[4] == cross.WIN) or (logv[3] == cross.LOSE and logv[4] == cross.LOSE) then
                            list[logk][logv[3]][logv[2]][3] = uidFlag
                        end

                        -- 设置每一场胜利者的标识
                        if type(logv[5]) == 'table' then
                            if not list[logk][logv[3]][logv[2]][4] then list[logk][logv[3]][logv[2]][4] = {} end
                            for _,winn in pairs(logv[5]) do
                                list[logk][logv[3]][logv[2]][4][winn] = uidFlag
                            end
                        end
                    end
                end
            end

            v.binfo = nil
            v.log = nil
            v.updated_at= nil
            v.battle_at = nil
            v.st = nil
            v.et = nil
            v.bet = nil

            table.insert(response.data.d,v)
        end                
    end

    -- 如果比赛还没结束
    if #battlelist[2] < roundEvents[2] then
        local nextGroup, nextGroup2 
        
        -- 下一场战斗充列
        for k,v in pairs(nextBattleList) do               
            for m,n in pairs(v) do 
                local tmp = {
                    cross.mkBattleUidKey(n[1].uid,n[1].zid),                
                }

                if n[2] then tmp[2] = cross.mkBattleUidKey(n[2].uid,n[2].zid) end

                if k == 'group' then 
                    if not nextGroup2 then 
                        nextGroup2 = {
                            [cross.WIN] = {},
                            [cross.LOSE] = {},
                        }
                    end
                    nextGroup2[cross.WIN][m] = tmp  
                else
                    if not nextGroup then 
                        nextGroup = {
                            [cross.WIN] = {},
                            [cross.LOSE] = {},
                        }
                    end

                     if k == 'win'  then
                        if n[1].round % 2 == 1 then
                            nextGroup[cross.WIN][m] = tmp
                        end
                    elseif k == 'lose' then
                        nextGroup[cross.LOSE][m] = tmp   
                    end
                end
            end        
        end
        
        table.insert(battlelist[2],nextGroup)
        table.insert(battlelist[1],nextGroup2)
    end

    -- 后期优化追加了地形(做好兼容)
    local landforms = cross:getCrossBattleLandform(bid)
    if type(landforms) == 'table' then
        -- 分组赛只有胜者组，并且只有1轮
        if type(battlelist[1][1]) == 'table' and type(battlelist[1][1][1]) == 'table' then
            for k,v in pairs(battlelist[1][1][1]) do
                if type(v) == 'table' then
                    -- 第一轮胜者组
                    v[5] = landforms[1][1][k]

                    -- 没有战斗结果时3,4号位是空的,占位, 6 7是鲜花数
                    for i=1,7 do
                        if not v[i] then v[i] = "" end
                    end
                end
            end
        end

        -- 淘汰赛
        if type(battlelist[2]) == 'table' then
            for k,v in pairs(battlelist[2]) do
                if type(v) == 'table' then
                    -- 淘汰赛k是从1开始的，地形是直接以1-8的回合数当key生成的数据所以+1
                    local tround = k + 1

                    -- m:[胜|败] 者组
                    for m,n in pairs(v) do
                        if type(n) == 'table' then
                            -- m1:[a-h]队名
                            for m1,n1 in pairs(n) do
                                n1[5] = landforms[tround][m][m1]
                                
                                for i=1,7 do
                                    if not n1[i] then n1[i] = "" end
                                end
                            end
                        end
                    end
                end
            end
        end
    end
    
    response.data.l = battlelist
    response.ret = 0
    response.msg = 'Success'

    return response
end
