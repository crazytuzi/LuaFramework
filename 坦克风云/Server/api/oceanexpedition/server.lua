local function api_oceanexpedition_server(request)
    local self = {
        response = {
            ret=-1,
            msg='error',
            data = {},
            errors={},
        },
    }

    self._cronApi = {
        ["*"] = true,
    }

    --[[
        设置阵形
        跨服这边的战斗是瞬间计算完成的，所以这里没有对设置的时间区间做判断
    ]]
    function self.action_setFormation( request )
        local response = self.response
        local bid = request.params.bid
        local zid = tonumber(request.params.zoneid)
        local formation = request.params.formation

        if bid == nil or zid == nil then
            response.ret = -102
            return response
        end

        if type(formation) ~= "table" then
            response.ret = -102
            response.err = "formation must be a table"
            return response
        end

        local OceanExpedition = loadModel("model.oceanexpeditionserver")
        if not OceanExpedition:checkFormation(formation) then
            response.ret = -102
            response.err = "invalid formation"
            return response
        end

        local bidData = OceanExpedition:getBidDataFromDb(bid)
        if not bidData then
            response.ret = -27501
            return response
        end

        local ret, err = OceanExpedition:updateTeamData(bid,zid,{bid=bid,zid=zid,formation=formation})
        if not ret then
            response.ret = -27502
            return response
        end

        response.ret = 0
        response.msg = 'Success'
        return response
    end

    -- 设置队伍
    function self.action_setTeam( request )
        local response = self.response
        local bid = request.params.bid
        local zid = tonumber(request.params.zoneid)

        if bid == nil or zid == nil then
            response.ret = -102
            return response
        end

        local jobs = {}

        -- 这里没有检测是否有uid多次出现(战斗逻辑里有处理)
        local data = {bid=bid,zid=zid}
        for tid,memberList in pairs(request.params.teams) do
            if memberList[1] and memberList[2] and next(memberList[2]) then
                -- tid 减1是因为服内存的时候是队伍id是从1-6对应真实队伍id为0-5
                local teamId = "team"..(tonumber(tid)-1)
                data[teamId] = memberList

                if memberList[1] then
                    -- 1统帅 2队长 3成员
                    jobs[memberList[1]] = teamId == 0 and 1 or 2
                end
            end
        end

        local OceanExpedition = loadModel("model.oceanexpeditionserver")
        if next(jobs) then
            for mid,job in pairs(jobs) do
                OceanExpedition:updateMemberData(bid,mid,{job=job})
            end
        end

        local ret, err = OceanExpedition:updateTeamData(bid,zid,data)
        if not ret then
            response.ret = -27502
            return response
        end

        response.ret = 0
        response.msg = 'Success'
        return response
    end

    -- 设置士气值
    function self.action_setMorale( request )
        local response = self.response
        local bid = request.params.bid
        local zid = tonumber(request.params.zoneid)

        if bid == nil or zid == nil then
            response.ret = -102
            return response
        end

        local morale = request.params.morale
        if getConfig("oceanExpedition").morale.moralereward.morAtt[morale] then
            loadModel("model.oceanexpeditionserver"):updateTeamData(bid,zid,{bid=bid,zid=zid,morale=morale})
        end

        response.ret = 0
        response.msg = 'Success'
        return response 
    end

    -- 设置旗帜
    function self.action_setFlag( request )
        local response = self.response
        local bid = request.params.bid
        local zid = tonumber(request.params.zoneid)

        if bid == nil or zid == nil then
            response.ret = -102
            return response
        end

        if request.params.flag then
            loadModel("model.oceanexpeditionserver"):updateTeamData(bid,zid,{
                bid=bid,
                zid=zid,
                flag=request.params.flag
            })
        end
        
        response.ret = 0
        response.msg = 'Success'
        return response 
    end

    -- 设置用户信息
    function self.action_setMember( request )
        local response = self.response
        local bid = request.params.bid
        local zid = tonumber(request.params.zid)
        local member = request.params.member
        local uid = member.uid
        local action = request.params.action

        if not action or not uid or not bid then
            response.ret = -102
            return response
        end

        local OceanExpedition = loadModel("model.oceanexpeditionserver")
        local bidData = OceanExpedition:getBidDataFromDb(bid)
        if not bidData then
            response.ret = -27501
            return response
        end

        local ret, err
        if action == "apply" then
            ret, err = OceanExpedition:addMemberDataToDb(bid,member)
            if not ret then
                if OceanExpedition:getMemberDataFromDb(bid,uid) then 
                    action = "update"
                end
            end
        end

        if action == "update" then
            ret,err = OceanExpedition:updateMemberData(bid,uid,member)
        end

        if not ret then
            response.err = err
            response.ret = -27502
            return response
        end

        response.ret = 0
        response.msg = 'Success'
        return response
    end

    -- 开启大战
    function self.action_startWar(request)
        local response = self.response
        local bid = request.params.bid
        local st = request.params.st
        local et = request.params.et
        local servers = request.params.servers
        local zid = request.params.zid
        local fc = request.params.fc

        if bid == nil or st == nil or et == nil then
            response.ret = -102
            return response
        end

        -- 开服数必需为1-8 
        if type(servers) ~= "table" or #servers < 1 or #servers > 8 then
            response.ret = -102
            return response
        end

        for k,v in pairs(servers) do
            servers[k] = tonumber(v)
        end

        local OceanExpedition = loadModel("model.oceanexpeditionserver")
        if OceanExpedition:createMatch(bid,st,et,servers,zid,fc) then
            response.ret = 0
            response.msg = 'Success'
        end

        return response
    end

    -- 停止大战
    function self.action_stopWar(request)
        local response = self.response
        local bid = request.params.bid
        if not bid then
            response.ret = -102
            return response
        end

        local OceanExpedition = loadModel("model.oceanexpeditionserver")
        local bidData = OceanExpedition:getBidDataFromDb(bid)
        if bidData then
            if not OceanExpedition:updateBidData({bid=bid,st=1,et=1}) then
                return response
            end
        end
        
        response.ret = 0
        response.msg = 'Success'
        return response
    end

    function self.action_getUserRoundLog(request)
        local response = self.response
        local uid = request.uid
        local bid = request.params.bid
        local OceanExpedition = loadModel("model.oceanexpeditionserver")
        local userdata = OceanExpedition:getMemberDataFromDb(bid, uid)
        if userdata then
            response.data.roundLog = json.decode(userdata.log)
        end
        
        response.ret = 0
        response.msg = 'Success'
        return response
    end

    -- 获取对阵表
    function self.action_schedule(request)
        local response = self.response
        local bid = request.params.bid

        if bid == nil then
            response.ret = -102
            return response
        end

        local battlelist = {}
        local OceanExpedition = loadModel("model.oceanexpeditionserver")

        local bidData = OceanExpedition:getBidDataFromDb(bid)
        if bidData == nil then
            response.ret = -102
            return response
        end

        local teamsData = OceanExpedition:getAllTeamsDataFromDb(bid)
        local maxRound = OceanExpedition:getMaxRoundByServers(bidData.servers)
        
        -- TODO 当前完成到第几回合了
        -- local currRound = OceanExpedition.getCurrentRound(tonumber(bidData.st))
        -- mAreaWar.checkRoundData(bid,currRound,allianceBattleInfo,bidData)

        if type(teamsData) == 'table' then
            -- 将数据格式化成前端需要的格式
            for k,v in pairs(teamsData) do
                if type(v.log) == 'table' then
                    for round,logv in pairs(v.log) do
                        if next(logv) then
                            local group = tostring(logv[1])
                            if not battlelist[round] then battlelist[round] = {} end
                            if not battlelist[round][group] then battlelist[round][group] = {} end

                            -- 服id,是否胜利
                            table.insert(battlelist[round][group],{v.zid,(logv[2] or 0)})
                        end
                    end
                end
            end
        end

        --如果比赛还没结束
        if bidData.round < maxRound then
            local nextBattleList = OceanExpedition:mkMatchList(bidData.round,bidData.servers,teamsData)
            local nextRound = bidData.round + 1
            battlelist[nextRound] = {}

            -- 下场对阵列表格式保持一致
            for k,v in pairs(nextBattleList) do
                battlelist[nextRound][tostring(k)] = {
                    {v[1] or 0}, -- 2为nil是还没有结果
                    {v[2] or 0}
                }
            end
        end

        -- 战斗结束后返回结束标识
        if bidData.round == maxRound then
            response.data.over = 1
        end
        
        response.data.schedule = battlelist

        response.ret = 0
        response.msg = 'Success'
        return response
    end

    function self.action_battle(request)
        local response = self.response
        local OceanExpedition = loadModel("model.oceanexpeditionserver")

        -- 从库里取出所有对战数据
        local bidData = OceanExpedition:getAllBidDataFromDb()
        if type(bidData) ~= "table" or not next(bidData) then
            response.err = "no data"
            return response
        end

        local function work(data)
            local currentRound = OceanExpedition:getCurrentRound(data.st,data.servers)

            print("currentRound:",currentRound,"data.round:",data.round,"bid:", data.bid)

            if data.round < currentRound then
                local teams = OceanExpedition:getWinningTeamsDataFromDb(data.bid)
                local battleList = OceanExpedition:mkMatchList(data.round,data.servers,teams)

                -- 创建一组bid下所有舰队
                local fleets = OceanExpedition:createFleet(data.bid,teams,data.round)

                -- 按战斗列表,计算每一组数据
                for k,v in pairs(battleList) do
                    OceanExpedition:battle(fleets[v[1]],fleets[v[2]],v[1],v[2],k,data.round,data.bid)
                end

                OceanExpedition:setMatchRound(data.bid,data.round+1)
            end
        end

        for k,v in pairs(bidData) do
            -- 关闭自动提交
            -- cross:setautocommit(false)

            local rstatus,rerror = pcall(work,v)

            if not rstatus then
                -- cross:rollback()
                response.errors[v.bid] = rerror
            end

            -- if not cross:commit() then
            --     print(cross.db:getError())
            --     return cross.writeCrossLog('commit failed:' .. (cross.db:getError() or 'no db error') )
            -- end
        end

        response.ret = 0
        response.msg = 'Success'
        return response
    end

    return self
end

return api_oceanexpedition_server
