function model_skyladderserver()
    local self={
        db = getCrossDbo("skyladderserver"),--getAllianceCrossDbo()
        redis = getAllianceCrossRedis("skyladderserver")
    }

    -- 设置自动提交
    function self.setautocommit(value)
        assert(self.db.conn:setautocommit(value),'mysql transaction set failed')
    end

    -- 提交数据库
    function self.commit()
        return self.db.conn:commit()
    end

    -- 回滚
    function self.rollback()
        self.db.conn:rollback()
    end

    -- 公共加锁
    function self.commonLock(params)
        local ret
        local redis = self.redis
        local key = table.concat(params,'.')

        local i = 1
        while i < 5 do
             ret = redis:getset(key,100)   
             redis:expire(key,3)      
             if ret==nil then
                 return true
             else
                local socket = require("socket.core")
                local time = rand(20,60)/100
                socket.select(nil,nil,time)
                i = i + 1
             end
        end

        return false
    end
    
    -- 公共解锁
    function self.commonUnlock(params)
        local ret
        local redis = self.redis
        local key = table.concat(params,'.')

        ret = redis:del(key)
        if ret == 1 then
            return true
        end
        
        return false
    end

    -- 根据操作类型取表名
    function self.getTableName(key)
        local tbname
        if key == 'status' then
            tbname = 'skyladder_status'
        elseif key == 'list' then
            tbname = 'skyladder_list'
        elseif key == 'person' then
            tbname = 'skyladder_personinfo'
        elseif key == 'alliance' then
            tbname = 'skyladder_allianceinfo'
        elseif key == 'history' then
            tbname = 'skyladder_historydata'
        elseif key == 'memlist' then
            tbname = 'skyladder_memlist'
        elseif key == 'update' then
            tbname = 'skyladder_update'
        else
            -- print('key',key)
            error({code=-106})
        end
        
        return tbname
    end
    
    -- 设置天梯榜开关状态
    function self.setStatus(params)
        local ret,err
        local ts = getClientTs()
        local tbname = self.getTableName('status')
        local have = self.db:getRow("select * from "..tbname.." where id='status' limit 1")
        
        if not have then
            local info = {
                id = 'status',
                cubid = params.cubid, -- 当前的赛季id
                lsbid = 0, -- 上一次结束的赛季id
                status = params.status or 0, -- 开关状态
                season = 1,
                over = 0, -- 是否已结算
                overtime = params.overtime or 0, -- 结算的时间点
                currst = ts, -- 当前赛季的起始时间，切换一下赛季后(未开启新的大战前),以前开的历史大战记录客户端不能显示
                updated_at = ts
            }
            
            ret = self.db:insert(tbname,info)
            if not ret then err = self.db:getError() end
        else
            local newBid = tonumber(params.cubid)
            local cuBid = tonumber(have.cubid)
            -- if newBid < cuBid or newBid == cuBid then
            if newBid < cuBid then
                return false,'bid error'
            end
            
            if newBid ~= cuBid then
                params.lsbid = cuBid
                params.over = 0
                params.overtime = 0
                params.fin = {}
                params.season = (have.season or 0) + 1
                params.nextready = 0
                params.nextreadytime = 0
                params.currst = ts -- 当前赛季的起始时间，切换一下赛季后(未开启新的大战前),以前开的历史大战记录客户端不能显示
            end
            
            params.updated_at = ts
            ret = self.db:update(tbname,params,"id='status' ")
            if not ret then err = self.db:getError() end
        end
        
        return ret,err
    end
    
    -- 更改天梯榜各项开关状态
    function self.changeStatus(bid,params)
        local ret,err
        local ts = getClientTs()
        local tbname = self.getTableName('status')
        local have = self.db:getRow("select * from "..tbname.." where id='status' limit 1")
        
        if have then
            local cuBid = tonumber(have.cubid)

            if tonumber(bid) ~= cuBid then
                return false,'bid error'
            end

            params.updated_at = ts
            
            ret = self.db:update(tbname,params,"id='status' ")
            if not ret then err = self.db:getError() end
        end
        
        return ret,err
    end
    
    -- 读取天梯榜开关信息
    function self.getStatus()
        local tbname = self.getTableName('status')
        local config = self.db:getRow("select * from "..tbname.." where id='status' limit 1")
        
        if not config or not config.cubid then
            config = {
                id = 'status',
                cubid = 0, -- 当前的赛季id
                lsbid = 0, -- 上一次结束的赛季id
                status = 0, -- 开关状态
                season = 0,
                over = 0, -- 是否已结算
                overtime = 0, -- 结算的时间点
                updated_at = 0
            }
        end
        
        return config
    end
    
    -- 添加天梯赛季分组关系
    function self.setgroup(bid,key,params)
        local ret,err
        local ts = getClientTs()
        local tbname = self.getTableName('list')
        local have = self.db:getRow("select * from "..tbname.." where bid='"..bid.."' limit 1")
        
        if not have then
            local row = {
                bid = bid,
                info = {},
                used = {},
                updated_at = ts
            }
            
            if not row.info[tostring(key)] then
                row.info[tostring(key)] = {params}
            end
            
            if not row.used[tostring(key)] then
                row.used[tostring(key)] = {}
            end
            
            for i,v in pairs(params) do
                row.used[tostring(key)][tostring(v)] = 1
            end
            
            ret = self.db:insert(tbname,row)
            if not ret then err = self.db:getError() end
        else
            local info = json.decode(have.info) or {}
            local used = json.decode(have.used) or {}
            
            if not info[tostring(key)] then
                info[tostring(key)] = {}
            end
            
            if not used[tostring(key)] then
                used[tostring(key)] = {}
            end
            
            -- 判断是否有重复的服务器
            for i,v in pairs(params) do
                if used[tostring(key)][tostring(v)] then
                    return -2,'repeat zid'
                end
            end
            
            -- 添加分组详情
            table.insert(info[tostring(key)],params)
            
            -- 记录已分组的服务器
            for i,v in pairs(params) do
                used[tostring(key)][tostring(v)] = 1
            end
            
            have.info = info
            have.used = used
            have.updated_at = ts
            ret = self.db:update(tbname,have,"bid="..bid)
            if not ret then err = self.db:getError() end
        end
        
        return ret,err
    end
    
    -- 读取天梯赛季分组关系
    function self.getgroup(bid,key)
        local result
        local ts = getClientTs()
        local tbname = self.getTableName('list')
        local have = self.db:getRow("select * from "..tbname.." where bid='"..bid.."' limit 1")

        if have then
            local info = json.decode(have.info) or {}
            local used = json.decode(have.used) or {}
            
            result = {}
            result.info = info[tostring(key)] or {}
            result.used = used[tostring(key)] or {}
        end

        return result
    end

    -- 刷新玩家积分数据
    function self.refRankData(bid,rtype,zid,id,save)
        local tbname = self.getTableName(rtype)
        local data = self.db:getRow("select * from "..tbname.." where bid=:bid and zid=:zid and id=:id limit 1",{id=id,zid=zid,bid=bid})

        if data and save then
            local key = 'skyladder.b'..bid..'.udata.'..rtype
            self.redis:hset(key,zid..'-'..id,json.encode(data))
            local ts = getClientTs()
            local nextTime = getWeeTs(ts + 86400)
            --self.redis:expire(key,nextTime-ts)
            --self.redis:expire(key,86400*2)
        end
        
        return data
    end
    
    -- 获取玩家积分数据
    function self.getRankData(bid,rtype,zid,id)
        local key = 'skyladder.b'..bid..'.udata.'..rtype
        local data = self.redis:hget(key,zid..'-'..id)
        
        return json.decode(data) or {}
    end

    -- 更新排行榜
    function self.setPfRanking(bid,rankingName,zid,uid,name,score,fc,maxLength)
        --print(bid,rankingName,zid,uid,name,score,fc,maxLength)
        local key = "skyladder.b"..bid..".origin.rank."..rankingName
        local key2 = "skyladder.b"..bid..".origin.rankAll."..rankingName
        local data = json.decode(self.redis:get(key))
        local rKey = zid..'-'..uid
        local score = tonumber(score)
        if not ts then
            ts = getClientTs()
        else
            ts = tonumber(ts)
        end
        
        if not fc then
            fc = 0
        end
        
        fc = tonumber(fc) or 0

        if type(data) ~= 'table' then
            data = {{rKey,score,name,fc,zid}}
        else
            local foundIndex -- 排行榜中自己的排名
            local foundPos = false -- 是否有晋升
            local posIndex -- 晋升的目标排名
            for k,v in ipairs(data) do
                local vscore = tonumber(v[2])
                if type(v) == 'table' then
                    if not foundPos then
                        if vscore < score then
                            foundPos = true
                            posIndex = k
                        elseif vscore == score then
                            if v[1] then
                                local vdata = string.split(v[1],'-')
                                local vzid = tonumber(vdata[1])
                                local vuid = tonumber(vdata[2])
                                --local vuid = tonumber(v[1])
                                local vfc = tonumber(v[4])
                                if vuid and vfc then
                                    if vfc < fc then
                                        foundPos = true
                                        posIndex = k
                                    elseif vfc == fc then
                                        if vuid > tonumber(uid) then
                                            foundPos = true
                                            posIndex = k
                                        end
                                    end
                                end
                            end
                        end
                    end

                    if tostring(v[1]) == tostring(rKey) then
                        foundIndex = k
                    end
                end
            end

            if foundIndex then
                table.remove(data,foundIndex)
                if not posIndex then
                    table.insert(data,{rKey,score,name,fc,zid})
                else
                    if foundIndex < posIndex then -- 容错 排名降低的情况 因为先到（从上面降下来）应该排在该位置前一名
                        posIndex = posIndex-1
                    end
                    table.insert(data,posIndex,{rKey,score,name,fc,zid})
                end
            else
                if posIndex then
                    table.insert(data,posIndex,{rKey,score,name,fc,zid})
                else
                    table.insert(data,{rKey,score,name,fc,zid})
                end
            end

            local rankLength = #data
            local maxLength = maxLength or rankLength

            if rankLength > maxLength then
                local delNum = rankLength - maxLength

                while delNum > 0 do
                    table.remove(data,#data)
                    delNum = delNum - 1
                end
            end
        end

        local result = self.redis:set(key,json.encode(data))
        local result2 = self.redis:zadd(key2,score,rKey)

        return result
    end
    
    -- 初始化积分log
    function self.getScore(player1Pt,player2Pt,result,battleType)
        -- player1Pt 第一位选手的分数
        -- player2Pt 第二位选手的分数
        -- rusult 战斗的结果 ：   1 为 第一位选手胜利 2 为第二位选手的胜利 3为 轮空且第一位选手得分
        --  battleType 战斗的类型
        -- 1 个人跨服战
        -- 2 世界大战 > 大师组 > 淘汰赛
        -- 3 世界大战 > 大师组 > 选拔赛
        -- 4 世界大战 > 精英组 > 淘汰赛
        -- 5 世界大战 > 精英组 > 选拔赛
        -- 6 跨服军团战
        -- 7 区域军团战

        --单次攻击胜利分数
        local basePt={60,75,35,50,25,60,75}
        --攻击常量标准值
        local avgPt={2500,3000,1500,2000,1000,2500,3000}
        --攻击常量最大值
        local maxPt={4000,5000,3000,3500,2500,4000,5000}

        local winPlayerPt
        local losePlayerPt

        ------------------------------------设置胜利方---------------------------------
        if result == 2 then
            winPlayerPt = player2Pt
            losePlayerPt = player1Pt
        else
            winPlayerPt = player1Pt
            losePlayerPt = player2Pt
        end

        ---------------------------------计算胜利方--------------------------------------

        ---------------------------------设置胜利方 战力对比获得常量-----------

        local avgValue
        if winPlayerPt - losePlayerPt >= 1000 then
            avgValue = 0
        elseif winPlayerPt - losePlayerPt >= -1000 then
            avgValue = -( winPlayerPt - losePlayerPt ) /1000 +1
        else
            avgValue = 2
        end

        ---------------------------------设置胜利方 战力成长获得常量(衰减）-----------
        local growValue
        if winPlayerPt < avgPt[battleType] then
            growValue =  1 --低于均值则为1
        elseif winPlayerPt > maxPt[battleType] then
            growValue = 0.2 --高于高值则为0.2
        else
            growValue = (  maxPt[battleType] - winPlayerPt  ) / ( maxPt[battleType] -avgPt[battleType]    ) * 0.8 + 0.2
        end

        ------------------------------胜利者获得差值--------------
        local winDiff = math.max( math.floor( basePt[battleType] *  avgValue  * growValue),1)
        ------------------------------计算失败方------------------


        ---------------------------------设置失败方 战力削减获得常量(衰减）-----------

        if losePlayerPt < avgPt[battleType] then
            growValue = -losePlayerPt / avgPt[battleType] * 0.8 -0.2
        else
            growValue = -1
        end


        ------------------------------胜利者获得差值--------------

        loseDiff = math.max(math.min( math.floor( basePt[battleType] *  avgValue  * growValue),-1),-losePlayerPt)

        local player1Diff,player2Diff
        if result == 2 then
            player1Diff= loseDiff
            player2Diff= winDiff
        else
            player1Diff= winDiff
            player2Diff= loseDiff
        end

        return player1Diff,player2Diff
    end
    
    -- 天梯积分log
    function self.saveLogData(bid,rtype,id,zid,blog)
        local ret,err
        local ts = getClientTs()
        local tbname = 'skyladder_'..rtype..'log'
        local have = self.db:getRow("select * from "..tbname.." where id="..id.." and bid="..bid.." and zid="..zid.."  limit 1")
        
        if not have then
            local row = {
                id = id,
                bid = bid,
                zid = zid,
                info = {blog},
                updated_at = ts
            }
            ret = self.db:insert(tbname,row)
            if not ret then err = self.db:getError() end
        else
            local info = json.decode(have.info) or {}
            local num = #info
            local cfg = getConfig("skyladderCfg")
            local limit = cfg.logLimit or 30
            local del = 0
            if num >= 30 then
                del = num - 30 + 1 
            end
            
            if del > 0 then
                for i=1,del do
                    table.remove(info,1)
                end
            end
            
            table.insert(info,blog)

            have.info = info
            have.updated_at = ts
            ret = self.db:update(tbname,have,'id='..id.." and bid="..bid.." and zid ="..zid)
            if not ret then err = self.db:getError() end
        end
        
        return ret,err
    end
    
    -- 保存战斗数据
    function self.saveBattleData(bid,rtype,ptype,battleType,params)
        if tonumber(ptype) ~= 3 then
            writeLog(json.encode({bid,rtype,ptype,battleType,params}),'saveBattleData')
        end
        local ret,err
        local ts = getClientTs()
        local cfg = getConfig("skyladderCfg")
        -- local rtype = cfg.projectsIncluded[tostring(ptype)]¸
        local countField = cfg[rtype..'CountField']
        -- local base = self.getStatus()
        -- local bid = base.cubid
        local id1 = params.id1
        local id2 = params.id2
        local z1 = params.z1
        local z2 = params.z2
        local win = z1..'-'..id1 == params.win and 1 or 2
        local winner,winzid
        if win == 1 then
            winner = id1
            winzid = z1
        else
            winner = id2
            winzid = z2
        end


        local v1 = 0
        if id1 and (not params.npc1 or tonumber(params.npc1) == 0) then
            local row1 = self.refRankData(bid,rtype,z1,id1)
            if row1 then
                for i,v in pairs(countField) do
                    if row1[i] then
                        v1 = v1 + row1[i]
                    end
                end
            end
        end

        local v2 = 0
        if id2 and (not params.npc2 or tonumber(params.npc2) == 0) then
            local row2 = self.refRankData(bid,rtype,z2,id2)
            if row2 then
                for i,v in pairs(countField) do
                    if row2[i] then
                        v2 = v2 + row2[i]
                    end
                end
            end
        end

        local addScore1,addScore2 = self.getScore(v1,v2,win,battleType)

        if id1 and not params.npc1 and tonumber(id1) > 0 then
            -- print('insert id1')
            local save = true
            -- if tonumber(id1)== 6000001 or (rtype == 'person' and tonumber(id1) < 1000000) then
                -- print('no save',tonumber(id1),1000000)
                -- save = false
            -- end
            
            if save then
                local blog1 = {
                    s = params.s, -- 类型1 类型2
                    r = ptype, -- 跨服战类型
                    t = params.t, --时间戳
                    w = winner, -- 胜利方
                    v1 = v1, -- 自己分数
                    v2 = v2, -- 对方分数
                    add1 = addScore1, -- 自己分数
                    add2 = addScore2, -- 对方分数
                    id1 = id1, -- 自己id
                    id2 = id2, -- 对方id
                    n1 = params.n1, -- 自己名字
                    n2 = params.n2, -- 对方名字
                    z1 = params.z1, -- 自己区id
                    z2 = params.z2, -- 对方区id
                }

                self.saveRankData(bid,rtype,ptype,params.z1,id1,params.n1,addScore1,params.fc1,params.pic1,blog1,params.bpic1,params.apic1,params.logo1)
            end
        end
        
        if id2 and not params.npc2 and tonumber(id2) > 0 then
            local save = true
            -- if tonumber(id2)== 6000001 or (rtype == 'person' and tonumber(id2) < 1000000) then
                -- print('no save',tonumber(id2),1000000)
                -- save = false
            -- end
            
            if save then
                local blog2 = {
                    s = params.s, -- 类型1 类型2
                    r = ptype, -- 跨服战类型
                    t = params.t, --时间戳
                    w = winner, -- 胜利方
                    v1 = v2, -- 自己分数
                    v2 = v1, -- 对方分数
                    add1 = addScore2,-- 自己分数
                    add2 = addScore1, -- 对方分数
                    id1 = id2, -- 自己id
                    id2 = id1, -- 对方id
                    n1 = params.n2, -- 自己名字
                    n2 = params.n1, -- 对方名字
                    z1 = params.z2, -- 自己区id
                    z2 = params.z1, -- 对方区id
                }
                self.saveRankData(bid,rtype,ptype,params.z2,id2,params.n2,addScore2,params.fc2,params.pic2,blog2,params.bpic2,params.apic2,params.logo2)
            end
        end
    end
    
    -- 保存战斗数据
    function self.saveBattleDataFromAreaServer(bid,rtype,ptype,battleType,params)
        writeLog(json.encode({bid,rtype,ptype,battleType,params}),'saveRankDataArea')
        local ret,err
        local ts = getClientTs()
        local cfg = getConfig("skyladderCfg")
        -- local rtype = cfg.projectsIncluded[tostring(ptype)]
        local countField = cfg[rtype..'CountField']
        -- local base = self.getStatus()
        -- local bid = base.cubid params.winname

        for i,v in pairs(params.item) do
            if not v.npc and v.id and tonumber(v.id) > 0 then
                local v1 = 0
                local row = self.refRankData(bid,rtype,v.z,v.id)

                if row then
                    for field,_ in pairs(countField) do
                        if row[field] then
                            v1 = v1 + row[field]
                        end
                    end
                end

                local win
                if params.win == v.z..'-'..v.id then
                    v2 = params.avg
                    win = 1
                else
                    v2 = params.winscore
                    win = 2
                end

                local addScore1,addScore2 = self.getScore(v1,v2,win,battleType)

                local blog = {}
                if win == 1 then
                    blog = {
                        s = params.s, -- 类型1 类型2
                        r = ptype, -- 跨服战类型
                        t = params.t, --时间戳
                        w = params.win, -- 胜利方
                        v1 = v1, -- 自己分数
                        v2 = v2, -- 对方分数(平均分)
                        add1 = addScore1, -- 自己分数
                        add2 = addScore2, -- 自己分数
                        id1 = v.id, -- 自己id
                        n1 = v.n, -- 自己名字
                        z1 = v.z, -- 自己区id
                    }
                else
                    blog = {
                        s = params.s, -- 类型1 类型2
                        r = ptype, -- 跨服战类型
                        t = params.t, --时间戳
                        w = params.win, -- 胜利方
                        v1 = v1, -- 自己分数
                        v2 = v2, -- 对方分数
                        add1 = addScore1, -- 自己分数
                        add2 = addScore2, -- 自己分数
                        id1 = v.id, -- 自己id
                        n1 = v.n, -- 自己名字
                        z1 = v.z, -- 自己区id
                        n2 = params.winname,
                        z2 = params.winzid
                    }
                end
                
                if params.nb then
                    blog.nb = 1
                end

                self.saveRankData(bid,rtype,ptype,v.z,v.id,v.n,addScore1,v.fc,v.pic,blog,nil,nil,v.logo)
            end
        end
    end
    
    -- 保存战斗数据
    function self.saveBattleDataDirect(rtype,ptype,addScore,params)
        local ret,err
        local ts = getClientTs()
        local cfg = getConfig("skyladderCfg")
        -- local rtype = cfg.projectsIncluded[tostring(ptype)]
        local countField = cfg[rtype..'CountField']
        local base = self.getStatus()
        local bid = base.cubid
        local id1 = params.id1
        local z1 = params.z1
        
        local v1 = 0
        if id1 then
            local row1 = self.refRankData(bid,rtype,z1,id1)
            if row1 then
                for i,v in pairs(countField) do
                    if row1[i] then
                        v1 = v1 + row1[i]
                    end
                end
            end
        end
        
        local blog1 = {
            s = params.s, -- 类型1 类型2
            r = ptype, -- 跨服战类型
            t = params.t, --时间戳
            v1 = v1, -- 自己分数
            add1 = addScore, -- 自己分数
            id1 = id1, -- 自己id
            n1 = params.n1, -- 自己名字
            z1 = params.z1, -- 自己区id
        }

        self.saveRankData(bid,rtype,ptype,params.z1,id1,params.n1,addScore,params.fc1,params.pic1,blog1)
    end
    
    -- 获取最新log并缓存
    function self.refLogData(bid,rtype,zid,id)
        local tbname = 'skyladder_'..rtype..'log'
        local data = self.db:getRow("select * from "..tbname.." where bid=:bid and zid=:zid and id=:id limit 1",{id=id,bid=bid,zid=zid})
        if data then
            local key = 'skyladder.b'..bid..'.log.'..rtype
            self.redis:hset(key,zid..'-'..id,json.encode(data))
            --self.redis:expire(key,86400)
            local ts = getClientTs()
            local nextTime = getWeeTs(ts + 86400)
            --self.redis:expire(key,nextTime-ts)
            --self.redis:expire(key,86400*2)
        end
        
        return data
    end
    
    -- 读取积分log
    function self.getLogData(bid,rtype,zid,id)
        local key = 'skyladder.b'..bid..'.log.'..rtype
        local data = self.redis:hget(key,zid..'-'..id)

        return json.decode(data) or {}
    end
    
    -- 保存积分数据
    function self.saveRankData(bid,rtype,ptype,zid,id,name,addScore,fc,pic,blog,bpic,apic,allianceLogo)
        if tonumber(ptype) ~= 3 then
            writeLog(json.encode({bid,rtype,ptype,zid,id,name,addScore,fc,pic,blog}),'saveRankData')
        end
        local ret,err
        local ts = getClientTs()
        local newScore = 0
        local upFc = 0
        local cfg = getConfig("skyladderCfg")
        local countField = cfg[rtype..'CountField']
        local ptypeField = cfg.ptypeField
        local tbname = self.getTableName(rtype)
        local row = self.refRankData(bid,rtype,zid,id)
        
        -- 个人排行榜辅助值 战力
        if fc then
            if not row or not row['fc'] or (row['fc'] and tonumber(row['fc']) < tonumber(fc)) then
                upFc = 1
            end
        end
            
        if not row then
            row = {
                id = id,
                bid = bid,
                pf = pf,
                zid = zid,
                name = name,
                [ptypeField[tostring(ptype)]] = addScore,
                fc = fc,
                pic = pic,
                updated_at = ts,
                bpic=bpic,
                apic=apic,
            }

            if allianceLogo then 
                row.logo = allianceLogo 
            end

            ret = self.db:insert(tbname,row)
            if not ret then err = self.db:getError() end
            
            newScore = 0
            for i,v in pairs(countField) do
                if row[i] then
                    newScore = newScore + tonumber(row[i])
                end
            end
        else
            if upFc and fc then
                if tonumber(fc) > 0 then
                    row.fc = fc
                end
            end
            row.pic = pic
            row[ptypeField[tostring(ptype)]] = row[ptypeField[tostring(ptype)]] + addScore
            row.updated_at = ts

            row.bpic = bpic
            row.apic = apic
            if allianceLogo then 
                row.logo = allianceLogo 
            end

            ret = self.db:update(tbname,row,"id="..id.." and bid="..bid.. " and zid="..zid)
            
            if not ret then err = self.db:getError() end
            
            newScore = 0
            for i,v in pairs(countField) do
                if row[i] then
                    newScore = newScore + tonumber(row[i])
                end
            end
        end
        
        if not ret then
            writeLog('save score '..rtype..' '..addScore.. ' to db fail '.. json.encode({bid=bid,rtype=rtype,ptype=ptype,zid=zid,id=id,name=name,addScore=addScore,fc=fc,pic=pic,blog=blog,sql=self.db:getQueryString()}),'skyladder_rank')
        end
        
        -- 积分log
        local logret = self.saveLogData(bid,rtype,id,zid,blog)
        if not logret then
            writeLog('save log '..rtype.. ' to db fail '.. json.encode({bid=bid,rtype=rtype,ptype=ptype,zid=zid,id=id,name=name,addScore=addScore,fc=fc,pic=pic,blog=blog,sql=self.db:getQueryString()}),'skyladderbattlelog')
        end

        local minScore = 0
        local rankNum = 0
        
        if rtype == 'person' then
            minScore = cfg.personMinScore
            rankNum = cfg.personShowNum
        else
            minScore = cfg.allianceMinScore
            rankNum = cfg.allianceShowNum
        end

        if newScore >= minScore then
            if rtype == 'person' and tonumber(id) < 1000000 then
                -- no process
            else
                self.setPfRanking(bid,rtype,zid,id,name,newScore,(row.fc or 11),rankNum)
            end
        end
        
        return newScore,ret,err
    end
    
    -- 更改昵称
    function self.changeName(bid,rtype,zid,id,name)
        local ret,err
        local ts = getClientTs()
        local tbname = self.getTableName(rtype)
        local row = self.refRankData(bid,rtype,zid,id)

        if row then
            row.name = name
            row.updated_at = ts
            ret = self.db:update(tbname,row,"id="..id.." and bid="..bid.. " and zid="..zid)
            
            if not ret then err = self.db:getError() end
            
            local rkey = "skyladder.b"..bid..".origin.rank."..rtype
            local list = json.decode(self.redis:get(rkey)) or {}
            for i,v in pairs(list) do
                if type(v) == 'table' and v[1] and v[1] == zid..'-'..id then
                    list[i][3] = name
                end
            end
            self.redis:set(rkey,json.encode(list))
            
            local rkey = "skyladder.b"..bid..".rank."..rtype
            local list = json.decode(self.redis:get(rkey)) or {}
            for i,v in pairs(list) do
                if type(v) == 'table' and v[1] and v[1] == zid..'-'..id then
                    list[i][3] = name
                end
            end
            self.redis:set(rkey,json.encode(list))
            
            local tbname = 'skyladder_'..rtype..'log'
            local data = self.db:getRow("select * from "..tbname.." where bid=:bid and zid=:zid and id=:id limit 1",{id=id,bid=bid,zid=zid})
            if data then
                if data.info then
                    ptb:p(data.info)
                    local info = json.decode(data.info) or {}
                    local count = #info
                    for i=1,count do
                        if info[i] and type(info[i]) == 'table' then
                            if info[i].n1 then
                                info[i].n1 = name
                            end
                        end
                    end
                    data.info = info
                    local up = self.db:update(tbname,data,"bid="..bid.." and id="..id.." and zid="..zid)
                    if up then
                        local rkey = 'skyladder.b'..bid..'.log.'..rtype
                        self.redis:hset(rkey,zid..'-'..id,json.encode(data))
                    end
                end
            end
        end
 
        return ret,err
    end

    -- 刷新公共排行榜
    function self.refRanking(bid,rankingName,page,num)
        local key = "skyladder.b"..bid..".origin.rank."..rankingName
        
        local list = {}
        local list = json.decode(self.redis:get(key)) or {}

        local startIndex = 1
        local endIndex = #list

        if page then 
            startIndex = (page - 1) * num + 1
            endIndex = page * num
        end

        if startIndex > #list then
            startIndex = #list
        end
        if endIndex > #list then
            endIndex = #list
        end

        local returnList = {}
        if startIndex == 0 then
            return returnList
        end
        
        if startIndex <= endIndex then
            for i=startIndex,endIndex do
                table.insert(returnList,list[i])
            end
        end
        
        local rkey = "skyladder.b"..bid..".rank."..rankingName
        self.redis:set(rkey,json.encode(returnList))
        local ts = getClientTs()
        --local nextTime = getWeeTs(ts + 86400)
        --self.redis:expire(rkey,nextTime-ts)
        --self.redis:expire(rkey,86400*2)
        
        return returnList
    end
    
    -- 获取排行榜
    function self.getRanking(bid,rankingName,page,num)
        local rkey = "skyladder.b"..bid..".rank."..rankingName
        local list = json.decode(self.redis:get(rkey)) or {}
        local startIndex = 1
        local endIndex = #list

        if page then 
            startIndex = (page - 1) * num + 1
            endIndex = page * num
        end

        if startIndex > #list then
            startIndex = #list
        end
        if endIndex > #list then
            endIndex = #list
        end

        local returnList = {}
        if startIndex == 0 then
            return returnList
        end
        
        if startIndex <= endIndex then
            for i=startIndex,endIndex do
                table.insert(returnList,list[i])
            end
        end
        
        return returnList
    end
    
    -- 刷新个人排名
    function self.refRank(bid,rankingName,zid,id)
        local inRank = self.refRanking(bid,rankingName,1,100)
        local rkey = zid..'-'..id
        local foundKey
        
        for i,v in pairs(inRank) do
            if v[1] and v[1] == rkey then
                foundKey = i
                break
            end
        end
        
        if not foundKey then
            local key2 = "skyladder.b"..bid..".origin.rankAll."..rankingName
            local result = self.redis:zrevrank(key2,rkey)
            foundKey = tonumber(result)
            if foundKey then
                foundKey = foundKey + 1 
                -- 因为有序集排名不准，后来先到，所以只要不在缓存列表里，即使有序集里排名小于100也返回101，
                if foundKey <= 100 then
                    foundKey = 101
                end
            end
        end
        
        if foundKey then
            local key = 'skyladder.b'..bid..'.myrank.'..rankingName
            self.redis:hset(key,zid..'-'..id,foundKey)
            local ts = getClientTs()
            local nextTime = getWeeTs(ts + 86400)
            --self.redis:expire(key,nextTime-ts)
            --self.redis:expire(key,86400*2)
        end
        
        return foundKey
    end
    
    -- 取个人排名
    function self.getRank(bid,rankingName,zid,id)
        local key = 'skyladder.b'..bid..'.myrank.'..rankingName
        return self.redis:hget(key,zid..'-'..id)
    end
    
    -- 保存军团成员列表
    function self.setAllianceMemberList(bid,battleType,zid,aid,uidList)
        local ret,err
        local ts = getClientTs()
        local tbname = self.getTableName('memlist')
        local have = self.db:getRow("select * from "..tbname.." where bid='"..bid.."' and id="..aid.." and zid="..zid.." limit 1")
        local save = false
        
        if not have then
            local row = {
                id = aid,
                bid = bid,
                zid = zid,
                info = {},
                updated_at = ts
            }
            
            row.info = {}
            if not row.info[tostring(battleType)] then
                row.info[tostring(battleType)] = {}
            end
            
            for i,v in pairs(uidList) do
                if v and type(v) == 'table' and v.id then
                    row.info[tostring(battleType)][tostring(v.id)] = {z=v.z,n=v.n,p=v.p}
                end
            end

            ret = self.db:insert(tbname,row)
            if not ret then err = self.db:getError() end
        else
            local info = json.decode(have.info) or {}
            if not info[tostring(battleType)] then
                info[tostring(battleType)] = {}
            end
            
            for i,v in pairs(uidList) do
                if v and type(v) == 'table' and v.id then
                    if not info[tostring(battleType)][tostring(v.id)] then
                        save = true
                        info[tostring(battleType)][tostring(v.id)] = {z=v.z,n=v.n,p=v.p}
                    end
                end
            end

            have.info = info
            have.updated_at = ts
            
            if save then
                ret = self.db:update(tbname,have,"bid="..bid.." and id="..aid.." and zid="..zid)
                if not ret then err = self.db:getError() end
            else
                ret = true
            end
        end

        writeLog('bid='..(bid or 0)..',zid='..(zid or 0)..',aid='..(aid or 0)..',uidList='..json.encode(uidList),'skyladderMemberList')
        
        return ret,err
    end
    
    -- 读取军团成员列表
    function self.getAllianceMemberList(bid,battleType,zid,aid)
        local list = {}
        local tbname = self.getTableName('memlist')
        local result = self.db:getRow("select * from "..tbname.." where bid = '"..bid.."' and id="..aid.." and zid="..zid)
        
        if result then
            local data = json.decode(result.info) or {}
            if tonumber(battleType) > 0 then
                list = data[tostring(battleType)] or {}
            else
                for _,ulist in pairs(data) do
                    for i,v in pairs(ulist) do
                        if not list[tostring(i)] then
                            list[tostring(i)] = v
                        end
                    end
                end
            end
        end
        
        return list
    end

    -- 统计用户数量
    function self.checkRecordNum(bid,rtype)
        local tbname = self.getTableName(rtype)
        local cfg = getConfig("skyladderCfg")
        local minScore = cfg[rtype..'MinScore']
        local field = cfg[rtype..'CountField']
        local num = 0
        local count = {}
        for i,v in pairs(field) do
            table.insert(count,i)
        end

        local pointField = table.concat(count,'+')

        minScore = 1
                    
        local info = self.db:getRow("select count(*) as num from "..tbname.." where bid = '"..bid.."' and "..pointField.." >= "..minScore)
        if info and type(info) == 'table' then
            num = info.num or 0
        end
        
        return tonumber(num)
    end
    
    -- 重置天梯榜
    function self.resetPointRank(bid,rtype,all)
        local tbname = self.getTableName(rtype)
        local cfg = getConfig("skyladderCfg")
        local rankNum = cfg[rtype..'ShowNum']
        local minScore = cfg[rtype..'MinScore']
        local field = cfg[rtype..'CountField']
        local count = {}
        for i,v in pairs(field) do
            table.insert(count,i)
        end

        local pointField = table.concat(count,'+') .. ' as total '
                    
        local list = self.db:getAllRows("select id,zid,name,fc,"..pointField.." from "..tbname.." where bid = '"..bid.."' order by total desc,fc desc,id limit " .. rankNum)
        local num = #list
        local resetnum = 0
        local id
        local zid
        local nickname
        local score
        local fc
        
        if not list then
            list = {}
        end
        
        for i=1,num do
            if not list[i] then
                list[i] = {}
            end
            
            id = list[i].id
            zid = list[i].zid
            name = list[i].name
            score = tonumber(list[i].total) or 0
            fc = tonumber(list[i].fc) or 0

            if id and zid and name and score and score >= minScore then
                self.setPfRanking(bid,rtype,zid,id,name,score,(fc or 12))
                resetnum = resetnum + 1
            end
        end
        
        if all then
            local list = self.db:getAllRows("select id,zid,name,fc,"..pointField.." from "..tbname.." where bid = '"..bid.."' order by total desc,fc desc,id")
            local num = #list
            for i=1,num do
                if not list[i] then
                    list[i] = {}
                end
                
                id = list[i].id
                zid = list[i].zid
                name = list[i].name
                score = tonumber(list[i].total) or 0
                fc = tonumber(list[i].fc) or 0

                if id and zid and name and score and score >= minScore then
                    self.setPfRanking(bid,rtype,zid,id,name,score,(fc or 13),rankNum)
                    resetnum = resetnum + 1
                end
            end
        end
        
        return num,resetnum
    end
    
    -- 合服更改zid
    function self.mergeServerChange(bid,oldzid,newzid)
        local tbname = 'skyladder_personinfo'
        self.db:query("update "..tbname.." set "..'zid'.."="..newzid.." where bid="..bid.." and zid = "..oldzid)
        
        self.resetPointRank('person')
        
        local tbname = 'skyladder_allianceinfo'
        self.db:query("update "..tbname.." set "..'zid'.."="..newzid.." where bid="..bid.." and zid = "..oldzid)
        
        self.resetPointRank('alliance')
        
        return true
    end
    
    -- 删除天梯榜中的军团信息
    function self.delAllianceInfo(bid,zid,id)
        local status = false
        local tbname = self.getTableName('alliance')
        local ret = self.db:query("delete FROM "..tbname.." WHERE bid="..bid.." AND zid="..zid.." AND id="..id)

        if ret then
            status = true
            self.resetPointRank(bid,'alliance')
            local key = "skyladder.b"..bid..".origin.rankAll.alliance"
            self.redis:zrem(key,zid..'-'..id)
        end
        
        return status
    end
    
    -- 读取名人堂信息
    function self.getHistoryData(id)
        local tbname = self.getTableName('history')
        local list = self.db:getAllRows("select * from "..tbname.." where id > "..id)
        
        if not list then
            list = {}
        end
        
        return list
    end
    
    -- 赛季结束结算 发奖 冠军数据留存 
    function self.setOver(bid)
        -- 冠军数据留存
        local ret,err
        local ts = getClientTs()
        local tbname = self.getTableName('history')
        local base = self.getStatus()
        self.refRanking(bid,'person',1,100)
        local plist = self.getRanking(bid,'person',1,3)
        local personHistoryData = {}

        for i=1,#plist do
            if plist[i] and type(plist[i])=='table' then
                if plist[i][1] then
                    local idparams = string.split(plist[i][1],'-')
                    print('idparams')
                    ptb:p(idparams)
                    local zid = idparams[1] or (plist[i][5] or 0)
                    local uid = idparams[2] or plist[i][1]
                    local row = self.refRankData(bid,'person',zid,uid) or {}
                    local pic = row.pic or 1
                    table.insert(plist[i],{pic,row.bpic,row.apic})
                    personHistoryData[i] = plist[i]
                end
            end
        end

        self.refRanking(bid,'alliance',1,100)
        local alist = self.getRanking(bid,'alliance',1,3)
        local allianceHistoryData = {}

        for i=1,#alist do
            local idparams = string.split(alist[i][1],'-')
            local zid = idparams[1]
            local aid = idparams[2]
            local row = self.refRankData(bid,'alliance',zid,aid) or {}

            local logo = json.decode(row.logo)
            if type(logo) ~= "table" or not next(logo) then logo = "" end
            table.insert(alist[i],logo)
            allianceHistoryData[i] = alist[i]
        end

        local row = {
            bid = bid,
            season = base.season or 0,
            info = {p=personHistoryData,a=allianceHistoryData},
            updated_at = ts,
        }

        ret = self.db:insert(tbname,row)
        if not ret then
            err = self.db:getError()
            return ret,err
        end

        -- 设置标识状态
        ret = self.changeStatus(bid,{over=1})
        if not ret then
            err = self.db:getError()
            return ret,err
        end
  
        return ret,err
    end
    
    -- 读取天梯榜各服排名前N的数据
    function self.getSkyladder(bid,rtype,battleType,groupnum,page,limit)
        local tbname = self.getTableName(rtype)
        local cfg = getConfig("skyladderCfg")
        local field = cfg[rtype..'CountField']
        local countA = {}
        local countB = {}
        for i,v in pairs(field) do
            table.insert(countA,'a.'..i)
            table.insert(countB,'b.'..i)
        end

        local pointField = table.concat(countA,'+') .. ' as total '
        local pointFieldA = table.concat(countA,'+')
        local pointFieldB = table.concat(countB,'+')
        
        -- 已配置的服务器
        local usedServer = self.getgroup(bid,battleType) or {}
        local used = {}
        for i,v in pairs(usedServer.used) do
            table.insert(used,i)
        end
        
        used = {}

        local noCount = ''
        if next(used) then
            noCount = " AND a.zid NOT IN("..table.concat(used,',')..") AND b.zid NOT IN("..table.concat(used,',')..") "
        end
        
        local fromPage = ''
        if page then
            local page = tonumber(page) or 1
            local limit = limit or 100
            local start = (page - 1) * limit
            fromPage = " limit " .. start .. ",".. limit
        end
        
        local list = self.db:getAllRows("SELECT a.zid,a.id,a.name,"..pointField.." FROM "..tbname.." a LEFT JOIN "..tbname.." b ON a.zid=b.zid AND "..pointFieldA.." <= "..pointFieldB.." WHERE a.bid = "..bid.." AND b.bid = "..bid..noCount.." GROUP BY a.id,a.zid HAVING COUNT(b.id) <= "..groupnum.." ORDER BY total DESC" .. fromPage)

        return list
    end
    
    function self.clearSkyladderLog(bid,rtype,stype)
        local list = self.db:getAllRows("select * from skyladder_"..rtype.."log where bid = '"..bid.."'")
        if not list then
            list = {}
        end
        
        for i,v in pairs(list) do
            if v.info then
                local newLog = {}
                if type(v.info) == 'string' then
                    v.info = json.decode(v.info) or {}
                end
                print(json.encode(v.info))
                for index,blog in pairs(v.info) do
                    if tonumber(blog.r) ~= tonumber(stype) then
                        
                        table.insert(newLog,blog)
                    end
                end
                print(json.encode(newLog))
                v.info = newLog
                local ret = self.db:update("skyladder_"..rtype.."log",v,'id='..v.id.." and bid="..bid.." and zid ="..v.zid)
                print('ret',ret)
                if not ret then writeLog(json.encode(v),'clearskyladderlog') end
            end
        end
    end
    
    function self.getBattleData(battleType,params)
        local cmdConfig = getConfig('skyladderCfg.battleDataCmd')
        local config = getConfig('config.skyladderserver.connect')
        local data={cmd=cmdConfig[tostring(battleType)].cmd,params=(params or {})}
        local ret

        for i=1,5 do
            ret = sendGameserver(config.host,config.port,data)
            if type(ret) == 'table' and type(ret.ret) == 'number' and ret.ret == 0 then
                break
            end
        end

        if type(ret) ~= 'table' or (not ret.ret) or ret.ret ~= 0 then
            writeLog('battleType='..battleType..',cmd='..(json.encode(data) or 'cmd')..',ret='..(json.encode(ret) or 'ret'), "getBattleDataFromSkyladder")
            return false
        end
        
        return ret
    end
    
    function self.setUpdataStatus(battleName,bid,...)
        local arg = {...}

        local str = ''
        for i,v in ipairs(arg) do
           str = str..'.'..v
        end
        
        local key = tostring(battleName)..str
        local info = {
            id = key,
            bid = bid,
            updated_at = getClientTs()
        }
        
        local tbname = self.getTableName('update')
        local ret = self.db:insert(tbname,info)
        if not ret then err = self.db:getError() end
            
        return ret
    end
    
    function self.getUpdataStatus(battleName,bid,...)
        local flag = true
        local arg = {...}

        local str = ''
        for i,v in ipairs(arg) do
           str = str..'.'..v
        end
        
        local key = tostring(battleName)..str
        local tbname = self.getTableName('update')
        local have = self.db:getRow("select * from "..tbname.." where id = :key and bid = :bid limit 1",{key=key,bid=bid})
        
        if not have then
            flag = false
        end
        
        return flag
    end
    
    -- 下赛季保留积分
    function self.startnextseasondata(bid,rtype)
        local tbname = self.getTableName(rtype)
        local cfg = getConfig("skyladderCfg")
        local field = cfg[rtype..'CountField']
        local keeppoint = cfg.keeppoint or 0
        local count = {}
        for i,v in pairs(field) do
            table.insert(count,i)
        end

        local bid = tonumber(bid)
        local pointField = table.concat(count,'+') .. ' as total '
        local resetnum = 0
        local ret
        if not list then
            list = {}
        end
        
        local list = self.db:getAllRows("select * from "..tbname.." where bid = '"..bid.."'")
        local num = #list
        local save = false
        for i=1,num do
            if not list[i] then
                list[i] = {}
            end
            if list[i].id then
                if rtype ~= 'person' or (rtype == 'person' and tonumber(list[i].id) > 100000) then
                    local score = 0
                    local info = {
                        id = list[i].id,
                        zid = list[i].zid,
                        bid = bid + 1,
                        pf = list[i].pf,
                        zid = list[i].zid,
                        name = list[i].name,
                        fc = tonumber(list[i].fc) or 0,
                        pic = list[i].pic,
                        bpic = list[i].bpic,
                        apic = list[i].apic,
                        logo = list[i].logo,
                        updated_at = ts
                    }
                    
                    for _,cfield in pairs(count) do
                        local point = tonumber(list[i][cfield] or 0) or 0
                        if point >= 0 then
                            info[cfield] = math.floor(point * keeppoint)
                        else
                            info[cfield] = math.ceil(point * keeppoint)
                        end
                        
                        score = score + info[cfield]
                    end

                    ret = self.db:insert(tbname,info)
                    if not ret then
                        err = self.db:getError() 
                    else
                        resetnum = resetnum + 1
                        self.setPfRanking(bid+1,rtype,info.zid,info.id,info.name,score,(info.fc or 13))
                    end
                    
                    if resetnum > 0 then
                        save = true
                    end
                end
            end
        end
        
        if save then
            ret = self.changeStatus(bid,{nextready=1})
            if not ret then
                error({code=-107})
            end
        end
        
        return num,resetnum
    end

    -- 获取一批用户的个人数据
    function self.getPersonsByUids(bid,uids)
        local uidStr = table.concat(uids,",")
        local tableName = self.getTableName("person")
        local sql = string.format("select id,pic,apic,bpic from %s where id in (%s) and bid = '%s'",tableName,uidStr,bid)
        local result = self.db:getAllRows(sql)
        return result
    end

    -- 获取一批军团的数据
    function self.getAlliancesByAids(bid,aids)
        local aidStr = table.concat(aids,",")
        local tableName = self.getTableName("alliance")
        local sql = string.format("select id,zid,logo from %s where id in (%s) and bid = '%s'",tableName,aidStr,bid)
        local result = self.db:getAllRows(sql)
        return result
    end

    return self
end