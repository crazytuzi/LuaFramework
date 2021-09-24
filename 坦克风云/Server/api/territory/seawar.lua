local function mapLock(mid)
    local ret = commonLock(mid,"maplock")
    if not ret then
        local redis = getRedis()
        local countKey = "z".. getZoneId() .. ".lockCount"
        local lockKey = "seaWarMapLock." .. mid
        local count = redis:hincrby(countKey,lockKey,1)
        if count >= 10 then
            commonUnlock(mid, "maplock")
            redis:hdel(countKey,lockKey)
        end

        redis:expire(countKey,3600)
    end

    return ret
end

local function mapUnlock(mid)
    return commonUnlock(mid, "maplock")
end

local function debugLog(msg)
    writeLog(msg,"seawar")
end

local function sendMail(uid,uname,mail_title,mType,content)
    local mail_content={
        type=mType,
        info = content
    }      
    MAIL:mailSent(uid,1,uid,'',uname,mail_title,mail_content,2,0)  
end

local function api_territory_seawar(request)
    local self = {
        response = {
            ret=-1,
            msg='error',
            data = {},
        },
    }

    function self.getRules()
        local rules = {
            ["action_seaWar"] = {
                target = {"required","table"},
                attacker={"required","number"},
                cronid={"required","string"},
            },

            ["action_back"] = {
                _uid={"required"},
                cronid = {"required","number"},
                target = {"required","table"},
            },
        }
        return rules
    end

    --[[
        客户端初始化接口
        返回报名信息，积分信息，排名信息，领奖信息
    ]]
    function self.action_get(request)
        local response = self.response
        local aid = request.params.aid
        local myuid = request.uid

        local mTerritory = getModelObjs("aterritory",aid,true)
        local libSeaWar = loadModel("lib.seawar")

        -- 返回报名标识
        response.data.applyFlag = mTerritory.checkApplyOfWar() and 1 or 0

        local ts = os.time()
        local warTime = mTerritory.getWarTime()
        local mAtmember = getUserObjs(request.uid,true).getModel('atmember')
        local allianceDomainWarCfg = getConfig('allianceDomainWar') 

        -- 个人积分,军团积分 默认都是0，大战开始之后出个人积分，结算期后，出军团积分
        response.data.warscore = {0,0}

        if ts > warTime.battleSt then
            local data = libSeaWar.getUserRankList()
            response.data.myAranking = -1
            response.data.myUranking = -1
            for k,v in pairs(data) do
                if myuid == tonumber(v[1]) then
                    response.data.myUranking = k
                    break
                end
            end

            -- 大于阳光普照奖积分,才返领奖标识
            if mAtmember.warscore >= allianceDomainWarCfg.everyOneL then
                response.data.ureward = not mAtmember.getWarUserRankRewardFlag()
            end

            response.data.warscore[1] = mAtmember.warscore
        end

        if aid and aid > 0 then
            if ts > warTime.clearingEt then
                local data = libSeaWar.getAllianceRankList()
                if type(data) == "table" then
                    for k,v in pairs(data) do
                        if v[#v] == aid then
                            response.data.myAranking = k
                            break
                        end
                    end
                end
                
                local mTerritory = getModelObjs("aterritory",aid,true)
                response.data.warscore[2] = mTerritory.getWarScore()

                -- 大于阳光普照奖积分,才返领奖标识
                if mTerritory.getWarScore() >= allianceDomainWarCfg.everyAllianceL then
                    response.data.areward = not mAtmember.getWarAllianceRankRewardFlag()
                end
            end
        end

        response.ret = 0
        response.msg = "Success"
        return response 
    end

    -- 领海战报名
    function self.action_apply(request)
        local response = self.response 
        local uid = request.uid
        local aid = getUserObjs(uid,true).getModel("userinfo").alliance

        if aid <= 0 then
            response.ret = -102
            return response
        end

        local ts = getClientTs()
        local mTerritory = getModelObjs("aterritory",aid)

        -- 已经报过名了
        if mTerritory.checkApplyOfWar() then
            response.ret = -8433
            return response
        end

        if not mTerritory.isNormal() then
            response.ret = -8411
            return response
        end

        if not mTerritory.checkLevelOfWar() then
            response.ret = -8426
            return response
        end

        local warTime = mTerritory.getWarTime()
        if (ts > warTime.warSt and ts < warTime.beginSt) or (ts > (warTime.warSt+172800) and ts < warTime.warEt) then
            local ainfo,code = M_alliance.getalliance{getuser=1,method=1,aid=aid,uid=uid}
            if not ainfo then
                response.ret = code
                return response
            end

            -- 不是军团长
            if tonumber(ainfo.data.role) ~= 2 then
                response.ret = -8008
                return response
            end

            mTerritory.applyForWar()
            if mTerritory.saveData() then
                response.ret = 0
                response.msg = "Success"
            end
        else
            response.ret = -8431
            return response
        end
        
        return response 
    end

    function self.action_applyList(request)
        local response = self.response 
        local aid = request.params.aid
        local mTerritory = getModelObjs("aterritory",aid,true)
        local libSeaWar = loadModel("lib.seawar")

        response.data.applyFlag = 0
        if mTerritory.checkApplyOfWar() then
            response.data.applyFlag = 1
        end

        if mTerritory.checkTimeOfWar(2) then
            if response.data.applyFlag == 1 then
                response.data.alertList = libSeaWar.getAlertList(aid)
            end

            response.data.applyList = libSeaWar.getJoinBattleList()
            response.data.statusList = libSeaWar.getAllGroundStatus()
        end

        response.ret = 0
        response.msg = "Success"
        return response 
    end

    --[[
        客户端检测到领海战出战队列异常时，会调用些接口
            1、大战结束后，未返回的
            2、我方领地战败后未返回的
            3、占领的军团已经战败了没有返回的
            4、占领的建筑已经被打爆了，或者是占领的建筑所属的主基地被打爆
    ]]
    function self.action_fleetCheck(request)
        local response = self.response
        local uid = request.uid
        local uobjs = getUserObjs(uid)
        local mTroops = uobjs.getModel("troops")

        local ts = os.time()

        local n = 2
        for cronId,fleetInfo in pairs(mTroops.attack) do
            if fleetInfo.seaWarFlag and fleetInfo.isGather == 0 and not fleetInfo.bs then
                local sec = 3 + n
                if ts > (fleetInfo.dist + sec) then
                    fleetInfo.dist = fleetInfo.dist + sec

                    local cronParams = {
                        cmd = "territory.seawar.attack",
                        uid=uid,
                        params = {
                            cronId=cronId,
                            target = fleetInfo.targetid,
                            attacker=uid
                        }
                    }

                    local ret,workId = setGameCron(cronParams,n)
                    if ret then
                        fleetInfo.workId = workId
                    end

                    n = n + 10
                end
            end
        end

        local warTime = getModelObjs("aterritory").getWarTime()

        -- 大战结束后，未返回的
        if ts > (warTime.battleEt + 120) then
            for cronId,fleetInfo in pairs(mTroops.attack) do
                if fleetInfo.seaWarFlag and fleetInfo.isGather > 0 and not fleetInfo.bs then
                    mTroops.fleetBack(cronId)
                    n = n + 1
                end
            end
        elseif ts > warTime.battleSt and ts < warTime.battleEt then
            for cronId,fleetInfo in pairs(mTroops.attack) do
                local mUserinfo
                if fleetInfo.seaWarFlag and fleetInfo.isGather > 0 and not fleetInfo.bs then
                    if not mUserinfo then
                        mUserinfo = uobjs.getModel("userinfo")
                    end

                    -- 我方军团战败后未返回的
                    if not getModelObjs("aterritory",mUserinfo.alliance,true).checkStatusOfWar() then
                        mTroops.fleetBack(cronId)
                        n = n + 1
                    end

                    -- 敌方军团战败后未返回的
                    if not getModelObjs("aterritory",tonumber(fleetInfo.oid),true).checkStatusOfWar() then
                        mTroops.fleetBack(cronId)
                        n = n + 1
                    end 

                    -- 占领的建筑已经被打爆了
                    if loadModel("lib.seawar").getGroundStatus(fleetInfo.mid) == 2 then
                        mTroops.fleetBack(cronId)
                        n = n + 1
                    end
                end
            end
        end

        if n > 2 then
            uobjs.save()
        end

        response.ret = 0
        response.msg = "Success"
        return response 
    end

    -- 获取耐久
    function self.action_getDura(request)
        local response = self.response
        local bid = request.params.bid
        local aid = request.params.aid

        local userAid = getUserObjs(request.uid,true).getModel("userinfo").alliance
        if userAid ~= aid then
            response.ret = -102
            response.userAid = userAid
            return response
        end

        local libSeaWar = loadModel("lib.seawar")
        local battleGround = libSeaWar.getBattleGround(aid,bid)

        local dura = 0
        if battleGround.baseDura then
            dura = battleGround.isDestroyed and battleGround.baseDura or battleGround.dura
            if dura > battleGround.baseDura then
                dura = battleGround.baseDura
            end
        end

        response.data.seawar = {
            dura = dura
        }

        response.ret = 0
        response.msg = "Success"
        return response
    end

    -- 获取地图状态
    function self.action_getMapStatus(request)
        local response = self.response
        local libSeaWar = loadModel("lib.seawar")
        local data = libSeaWar.getAllGroundStatus()

        response.data = data
        response.ret = 0
        response.msg = "Success"
        return response
    end

    -- 获取防守列表
    function self.action_defenderList(request)
        local response = self.response
        local uid = request.uid
        local bid = request.params.bid

        local uobjs = getUserObjs(uid,true)
        local mUserinfo = uobjs.getModel("userinfo")
        local aid = mUserinfo.alliance

        if aid > 0 then
            local libSeaWar = loadModel("lib.seawar")
            local battleGround = libSeaWar.getBattleGround(aid,bid)

            local list = {}
            if battleGround and battleGround.defenderList then
                for k,v in pairs(battleGround.defenderList) do
                    local tuobjs = getUserObjs(v.uid,true)
                    local userinfo = tuobjs.getModel('userinfo')
                    local fleetInfo = tuobjs.getModel('troops').getFleetByCron(v.cronId)

                    if fleetInfo and fleetInfo.seaWarFlag and not fleetInfo.bs then
                        local item = {}
                        table.insert(item,userinfo.nickname)
                        table.insert(item,userinfo.alliancename)
                        table.insert(item,fleetInfo.troops)
                        table.insert(list,item)
                    end
                end
            end

            response.data = list
        end

        response.ret = 0
        response.msg = "Success"
        return response
    end

    -- 撤回部队
    -- 
    function self.action_back(request)
        local response = self.response
        local uid = request.uid
        local cronId = "c" .. request.params.cronid
        local target = request.params.target
        local mapId = getMidByPos(target[1],target[2])
        if not mapLock(mapId) then
            response.ret = -5004  
            return response
        end

        local uobjs = getUserObjs(uid)
        local mTroop = uobjs.getModel('troops')

        local fleetInfo = mTroop.getFleetByCron(cronId)
        if not fleetInfo or not fleetInfo.seaWarFlag or fleetInfo.mid ~= mapId then
            response.ret = -102
            return response
        end

        local libSeaWar = loadModel("lib.seawar")
        local battleGround = libSeaWar.getBattleGround(fleetInfo.oid, fleetInfo.mType, mapId)
        local player = libSeaWar.delPlayer(battleGround,{uid=uid,cronId=cronId})

        if mTroop.fleetBack(cronId) then
            if player then
                libSeaWar.savePlayers()

                if player.role == 1 then
                    libSeaWar.reGroup(battleGround)
                    libSeaWar.setDecrDuraCron(battleGround)
                end

                debugLog({"dura Point :",player})
            else
                if not uobjs.save() then
                    return response
                end
            end

            libSeaWar.checkDeDuraQueue(battleGround)
            libSeaWar.saveBattleGround(battleGround)
        end
        
        mapUnlock(mapId)
        response.data.domainTroops = {[cronId]=fleetInfo}
        response.ret = 0
        response.msg = 'Success'
        return response
    end

    -- 舰队状态
    function self.action_fleetStatus(request)
        local response = self.response
        local uid = request.uid
        local cronId = "c" .. request.params.cronid

        local uobjs = getUserObjs(uid,true)
        local mTroop = uobjs.getModel('troops')

        local fleetInfo = mTroop.getFleetByCron(cronId)
        if not fleetInfo or not fleetInfo.seaWarFlag then
            response.ret = -102
            return response
        end

        local status = 0
        local score = 0
        if fleetInfo.isGather > 0 and not fleetInfo.bs then
            local libSeaWar = loadModel("lib.seawar")
            local battleGround = libSeaWar.getBattleGround(fleetInfo.oid,fleetInfo.mType)
            if battleGround and battleGround.players then
                local n = 0
                for i=1,#battleGround.players do
                    if battleGround.players[i].cronId == cronId and battleGround.players[i].uid == uid then
                        n = i
                        status = fleetInfo.seaWarFlag
                        score = battleGround.players[i].showScore + battleGround.players[i].score + battleGround.players[i].eScore
                        break
                    end
                    n = i
                end

                if n > getConfig('allianceDomainWar').captureTroopLimit then
                    status = 3
                end
            end
        end

        local data = {
            status = status, -- 0是未到达，1是进攻，2是防守，3是等待
            score = score,
        }

        response.data.status = data
        response.ret = 0
        response.msg = 'Success'
        return response
    end

    -- 侦察(要能查看所有防守方的部队？？是否太长)
    function self.action_scout(request)
        local response = self.response
        local uid = request.uid
        local land = copyTable(request.params.land)
        local aid = land.oid -- 军团id
        local bid = land.name -- 领地建筑ID(b1-b8)
        local aname = land.allianceName -- 军团名纯展示

        -- 有中文会影响金币日志
        request.params.land = {}

        local uobjs
        local gemCost = getConfig('allianceDomainWar').spyCost
        if request.params.cost == 0 then
            uobjs = getUserObjs(uid,true)
            local mTroops = uobjs.getModel("troops")
            for k,v in pairs(mTroops.attack) do
                if v.seaWarFlag == 1 and v.isGather == 5 and tonumber(land.id) == tonumber(v.mid) then
                    gemCost = 0
                    break
                end
            end

            if gemCost > 0 then
                response.ret = -102
                return response
            end
        else
            uobjs = getUserObjs(uid)
        end

        local libSeaWar = loadModel("lib.seawar")
        local battleGround = libSeaWar.getBattleGround(aid, bid)

        -- 该海域建筑已被催毁，不能操作
        if battleGround.isDestroyed then
            response.ret = -8435 
            return response
        end

        local mUserinfo = uobjs.getModel("userinfo")

        -- 该军团已战败，不能操作
        if (battleGround.mid and libSeaWar.getAllianceStatus(battleGround.aid) == 2) then
            response.ret = -8439
            return response
        end

        -- 我方领地已被摧毁，不能操作
        if libSeaWar.getAllianceStatus(mUserinfo.alliance) == 2 then
            response.ret = -8438
            return response
        end

        if gemCost > 0 then
            if not mUserinfo.useGem(gemCost) then
                response.ret = -109
                return response
            end

            -- 领海战侦察的金币日志
            regActionLogs(uid,1,{action=202,item="",value=gemCost,params={tonumber(aid),tostring(bid)}})

            if not uobjs.save() then
                return response
            end
        end

        local list = {}
        if battleGround and battleGround.defenderList then
            for k,v in pairs(battleGround.defenderList) do
                local tuobjs = getUserObjs(v.uid,true)
                local userinfo = tuobjs.getModel('userinfo')
                local fleetInfo = tuobjs.getModel('troops').getFleetByCron(v.cronId)

                if fleetInfo and fleetInfo.seaWarFlag and not fleetInfo.bs then
                    table.insert(list,{userinfo.nickname,userinfo.alliancename,fleetInfo.troops})
                end
            end
        end

        local content = {
            dura = battleGround.dura,
            list=list,
            land = land,
            time = os.time(),
        }
    
        local mailTitle = string.format("2-9-%s-%s",tostring(bid),tostring(aname))
        local mail = MAIL:mailSent(uid,1,uid,'',mUserinfo.nickname,mailTitle,content,2,1)   

        response.data = content
        response.ret = 0
        response.msg = 'Success'

        return response
    end

    -- 比赛通知
    function self.action_matchNotice()
        
    end

    -- 获取警报列表
    -- aid 没有取自己的aid,用的是客户端传过来的(只有显示逻辑,没有验证还好)
    function self.action_alertList(request)
        local response = self.response
        local aid = request.params.aid

        local libSeaWar = loadModel("lib.seawar")
        local list = libSeaWar.getAlertList(aid)

        if #list > 100 then
            for i=#list,100 do
                table.remove(list)
            end
        end
        
        response.data.list = list
        response.ret = 0
        response.msg = 'Success'
        return response
    end

    -- 个人排行榜 {"name",fc,score}
    function self.action_userRankList(request)
        local response = self.response
        local myuid = request.uid
        local libSeaWar = loadModel("lib.seawar")
        local data = libSeaWar.getUserRankList()

        local list = {}
        for k,v in pairs(data) do
            local uid = tonumber(v[1])
            if uid>0 then
                local uobjs = getUserObjs(uid,true)
                local userinfo = uobjs.getModel('userinfo')
                table.insert(list,{
                    userinfo.nickname,
                    userinfo.fc,
                    v[2],
                    v[1],
                })
            end
        end

        response.data.list = list
        response.ret = 0
        response.msg = 'Success'
        return response 
    end

    -- 领取个人奖励
    function self.action_userRankReward(request)
        local response = self.response
        local uid = request.uid
        local ranking = request.params.ranking
        local ts = os.time()

        local mTerritory = getModelObjs("aterritory")
        local warTime = mTerritory.getWarTime()

        -- 大战开始到结算期间不能领奖
        if ts >= warTime.warSt and ts <= warTime.clearingEt then
            response.ret = -1978
            return response
        end

        local libSeaWar = loadModel("lib.seawar")
        local data = libSeaWar.getUserRankList()
        local myranking = -1
        if type(data) == "table" then
            for k,v in pairs(data) do
                if tonumber(v[1]) == uid then
                    myranking = k
                    break
                end
            end
        end

        if myranking ~= ranking then
            response.data = {myranking,ranking}
            response.ret = -1975
            return response
        end

        local allianceDomainWarCfg = getConfig('allianceDomainWar')
        local reward
        local rewardCfg = allianceDomainWarCfg.serverreward.personRankReward
        if myranking == -1 then
            reward = rewardCfg[#rewardCfg][2]
        else
            for k,v in pairs(rewardCfg) do
                if type(v[1]) == "table" then
                    if myranking >= v[1][1] and myranking <= v[1][2] then
                        reward = v[2]
                    end
                elseif v[1] == myranking then
                    reward = v[2]
                end
            end
        end

        if not reward then
            response.ret = -1980
            return response
        end

        local uobjs = getUserObjs(uid)
        local mAtmember = uobjs.getModel('atmember')
        if mAtmember.getWarUserRankRewardFlag() then
            response.ret = -1976
            return response
        end

        -- -8436 积分不够,不能领取领海战奖励
        if mAtmember.warscore < allianceDomainWarCfg.everyOneL then
            response.ret = -8436
            return response
        end

        if not takeReward(uid,reward) then
            response.ret = -403
            return response
        end

        mAtmember.setWarUserRankRewardFlag()

        if uobjs.save() then
            response.ret = 0
            response.msg = 'Success'
        end

        return response 
    end

    --[[
        军团排行奖励,如果是第一名的军团长可以额外获取一份(盟主)奖励
    ]]
    function self.action_allianceRankReward(request)
        local response = self.response
        local uid = request.uid
        local ranking = request.params.ranking
        local ismaster = request.params.ismaster
        local ts = os.time()

        local uobjs = getUserObjs(uid)
        local mUserinfo = uobjs.getModel("userinfo")
        if mUserinfo.alliance <= 0 then
            response.ret = -102
            response.err = tostring(mUserinfo.alliance)
            return response
        end

        local mTerritory = getModelObjs("aterritory",mUserinfo.alliance,true)
        local warTime = mTerritory.getWarTime()

        if ts >= warTime.warSt and ts <= warTime.clearingEt then
            response.ret = -1978
            return response
        end

        local ainfo,code = M_alliance.getalliance{getuser=1,method=1,aid=aid,uid=uid}
        if not ainfo then
            response.ret = code
            return response
        end

        -- 加入军团时，军团活动已结束
        if (tonumber(ainfo.data.join_at) or warTime.battleSt + 1000) > warTime.battleSt then
            response.ret = -8440
            return response
        end

        if ismaster then
            if ranking ~= 1 then
                response.ret = -1981
                return response
            end

            -- 不是军团长
            if tonumber(ainfo.data.role) ~= 2 then
                response.ret = -8008
                return response
            end

            -- 获取军团奖励领取记录
            local data = getFreeData("territory.seawar.masterReward")
            if type(data) ~= "table" or type(data.info) ~= "table" then
                data = {info={ts=0}}
            end

            if data.info.ts < warTime.warSt then
                data.info = {}
            end

            -- 军团长奖励只能领取一次,换军团长不能重复领取
            if data.info.master then
                ismaster = nil
            end        
        end

        local libSeaWar = loadModel("lib.seawar")
        local data = libSeaWar.getAllianceRankList()

        local myranking = -1
        if type(data) == "table" then
            for k,v in pairs(data) do
                if tonumber(table.remove(v)) == mUserinfo.alliance then
                    myranking = k
                    break
                end
            end
        end

        if myranking ~= ranking then
            response.ret = -1975
            return response
        end

        local reward
        local allianceDomainWarCfg = getConfig('allianceDomainWar')
        local rewardCfg = allianceDomainWarCfg.serverreward.allianceRankReward

        if myranking == -1 then
            -- -8436 积分不够,不能领取领海战奖励
            if mTerritory.getWarScore() < allianceDomainWarCfg.everyAllianceL then
                response.ret = -8436
                return response
            end

            reward = rewardCfg[#rewardCfg][2]
        else
            for k,v in pairs(rewardCfg) do
                if type(v[1]) == "table" then
                    if myranking >= v[1][1] and myranking <= v[1][2] then
                        reward = v[2]
                    end
                elseif v[1] == myranking then
                    reward = v[2]
                end 
            end
        end

        if not reward then
            response.ret = -1980
            return response
        end

        local mAtmember = uobjs.getModel('atmember')
        if mAtmember.getWarAllianceRankRewardFlag() then
            response.ret = -1976
            return response
        end

        if not takeReward(uid,reward) then
            response.ret = -403
            return response
        end

        -- 军团长领取额外奖励
        if ismaster then
            if not takeReward(uid,allianceDomainWarCfg.serverreward.bossReward) then
                response.ret = -403
                return response
            end

            -- 给客户端返回标识，显示军团奖励
            response.data.ismaster = 1
        end

        mAtmember.setWarAllianceRankRewardFlag()

        if uobjs.save() then
            if ismaster then
                setFreeData("territory.seawar.masterReward", {ts=ts,master=uid,aid=mUserinfo.alliance})
            end

            response.ret = 0
            response.msg = 'Success'
        end
        
        return response 
    end

    -- 军团排行榜
    function self.action_allianceRankList(request)
        local response = self.response
        local aid = request.params.aid
        local libSeaWar = loadModel("lib.seawar")
        local data = libSeaWar.getAllianceRankList()

        response.data.list = data
        response.ret = 0
        response.msg = 'Success'
        return response 
    end

    -- 海战
    function self.action_attack(request)
        local response = self.response
        local cronId = request.params.cronId
        local target = request.params.target
        local attacker = request.params.attacker
        local workId = request.workId

        local ts = getClientTs()
        local mapId = getMidByPos(target[1],target[2])

        if not mapLock(mapId) then
            response.ret = -100  
            return response
        end

        local auobjs = getUserObjs(attacker)
        local mAttackTroop = auobjs.getModel('troops')
        local mAttackUserinfo = auobjs.getModel('userinfo')
        local mAttackArmor = auobjs.getModel('armor')
        local mAttackAweapon = auobjs.getModel('alienweapon')
        local attFleetInfo = mAttackTroop.getFleetByCron(cronId)    -- 攻击者的部队信息

        if not attFleetInfo or attFleetInfo.workId ~= workId or mAttackTroop.checkCronFleetStatus(cronId) ~= 0 then
            mapUnlock(mapId)
            response.ret = -5001
            return response
        end

        -- dist 到达时间
        -- 如果系统调用时间差在5秒以外，不处理此次请求
        local dist = attFleetInfo.dist or 0
        if not request.secret and (dist-ts) >= 5 then
            mapUnlock(mapId)
            return response
        end

        -- 抵达时间为当前
        attFleetInfo.dist = ts

        local allianceId = tonumber(attFleetInfo.oid) or 0

        local mTerritory = getModelObjs("aterritory")
        local libSeaWar = loadModel("lib.seawar")
        local battleGround = libSeaWar.getBattleGround(allianceId,attFleetInfo.mType,mapId,attFleetInfo.level)
        local returnFlag = 0
        local allianceDomainWarCfg = getConfig('allianceDomainWar')

        -- return_content_tip_14="时间不对，大战未开始或已结束",
        -- return_content_tip_15="出战部队已经达到配置的上限了",
        -- return_content_tip_16="攻击的建筑已经被打爆了",
        -- return_content_tip_17="攻击的军团已经被击败，退出比赛了",
        -- return_content_tip_18="该建筑可容纳部队数达到上限",
        -- return_content_tip_19="你的军团已经被击败，退出比赛了",
        -- return_content_tip_20="炮塔还未被完全击毁不能攻击",
        -- return_content_tip_21="正在敌方舰队里攻击时(未被击败)，由于已方军团主基地被击破，已方军团退出比赛，已方所有部队撤回",
        -- return_content_tip_22="正在进攻建筑时(未被击败)，但目标领地主基地被击破，导致自己的部队撤回",

        if not mTerritory.checkTimeOfWar(attFleetInfo.seaWarFlag) then
            returnFlag = 14
        elseif mAttackTroop.checkSeaWarFleetCount() > allianceDomainWarCfg.queueLimit then
            returnFlag = 15
        elseif battleGround.isDestroyed then
            returnFlag = 16
            libSeaWar.saveBattleGround(battleGround)
        elseif #battleGround.players >= allianceDomainWarCfg.enterLimitTroops then
            returnFlag = 18
        elseif libSeaWar.getAllianceStatus(mAttackUserinfo.alliance) == 2 then
            -- return_content_tip_19="你的军团已经被击败，退出比赛了",
            returnFlag = 19
        elseif attFleetInfo.seaWarFlag == 1 then
            if not libSeaWar.isAssaultable(allianceId,attFleetInfo.mType,target) then
                returnFlag = 20
            elseif libSeaWar.getAllianceStatus(allianceId) == 2 then
                -- return_content_tip_17="攻击的军团已经被击败，退出比赛了",
                returnFlag = 17
            end
        end

        if returnFlag > 0 then
            mAttackTroop.fleetBack(cronId)
            processEventsBeforeSave()
            if auobjs.save() then
                processEventsAfterSave()
                sendMail(attacker,mAttackUserinfo.nickname,"3-9",3,{rettype=returnFlag})
                response.ret = 0
                response.msg = 'Success'
            end

            mapUnlock(mapId)
            return response
        end

        -- 把状态置上(约定为5)
        attFleetInfo.isGather = 5

        local player = libSeaWar.newPlayer(attacker,mAttackUserinfo.alliance,cronId,attFleetInfo.seaWarFlag)
        libSeaWar.setPlayerTroopScore(player,attFleetInfo.troops)

        for k,v in pairs(battleGround.players) do
            getUserObjs(tonumber(v.uid))
        end

        libSeaWar.addPlayer(battleGround,player)
        libSeaWar.attack(battleGround,battleGround.attackerList,battleGround.defenderList,target)
        libSeaWar.savePlayers()
        libSeaWar.saveBattleGround(battleGround)

        mapUnlock(mapId)
        response.ret = 0
        response.msg = 'Success'
        return response
    end

    --[[
        战场耐久掉为0时请求的接口

            非主基地:
                耐久掉为0时,该战场驻守/攻击的部队需要全部结算返回
            主基地:
                该军团领地内的所有战场部队全部结算返回
                该军团成员的所有领海战出战部队全部结算返回

            邮件提示：
                return_content_tip_21="您的军团已战败，参战部队已自动返回",
                return_content_tip_22="敌方军团已战败，参战部队已自动返回",
                return_content_tip_23="敌方建筑已损毁，前往部队已自动返回",
        
        锁的问题：
            这里应该加锁保证同时只能有一个[主基地]爆炸
            因为主基地爆炸会撤回正在其它领海中的战斗部队,影响到其它领地战斗
            但是cron任务只有一个worker在消费,代码这里就没做检测,
            战场部队的撤回操作是由玩家执行的，可能会并发
    ]]
    function self.action_decrDura(request)
        local response = self.response
        local cronId = request.workId

        if not request.secret or not cronId then
            response.ret = -102
            return response
        end

        if not mapLock(request.params.mid) then
            response.ret = -100
            return response
        end

        local bid = request.params.bid
        local aid = request.params.aid

        -- 领地主基地标识
        local isMainCity = bid == "b1"

        local libSeaWar = loadModel("lib.seawar")
        local battleGround = libSeaWar.getBattleGround(aid,bid)

        -- 没有战场数据
        if not battleGround or not battleGround.mid then
            debugLog({"action_decrDura not found battleGround:",battleGround})
            return response
        end

        if battleGround.duraCronId ~= cronId then
            debugLog({"action_decrDura invalid params: cronId:", cronId, battleGround})
        end

        local allianceDomainWarCfg = getConfig('allianceDomainWar')

        -- 战场是否击破做一下兼容
        -- 如果战场未被击破,按当时的计算出的掉耐久时间再加一回合的时间检测一次
        if not battleGround.isDestroyed then
            libSeaWar.checkBattleGroundDura(battleGround,battleGround.cronDealy+allianceDomainWarCfg.dotTime)
            if not battleGround.isDestroyed then
                debugLog({"action_decrDura not destroyed:",battleGround})
            end
        end

        -- 记录下日志帮助分析
        debugLog({"action_decrDura:",battleGround})

        if battleGround.duraCronId == cronId and battleGround.isDestroyed then
            -- 当前战场的占领军团ID
            local ownerAid = battleGround.ownerAid

            -- 待处理的所有战场数据,
            -- 非领地只要处理本战场的相关数据
            -- 如果是主基地就需要处理该领地的所有战场
            local battleGrounds
            if isMainCity then
                battleGrounds = libSeaWar.getTerritoryBattleGround(aid)
            else
                battleGrounds = {[bid]=battleGround}
            end

            local saveUids = {}
            for bid,ground in pairs(battleGrounds) do
                if type(ground.players) == "table" then
                    for i=#ground.players,1,-1 do
                        local player = ground.players[i]

                        if player.uid then
                            local get,uobjs = pcall(getUserObjs,player.uid)
                            if get then
                                if uobjs.getModel('troops').fleetBack(player.cronId) then
                                    saveUids[player.uid] = uobjs

                                    -- 发送邮件
                                    local rettype
                                    if player.aid == ground.aid then
                                        rettype=21
                                    else
                                        rettype = isMainCity and 22 or 23
                                    end

                                    sendMail(player.uid,"","3-9",3,{rettype=rettype})
                                    debugLog({"action_decrDura fleetBack:",player})
                                end
                            else
                                debugLog({"action_decrDura: getUserObjs error1",player.uid})
                            end

                            -- 如果摧毁的额外分数没有加过,需要加摧毁的分
                            -- (有人防守的情况下发生战斗直接被摧毁会加给战斗的人)
                            if not request.params.dpAddFlag and i <= allianceDomainWarCfg.captureTroopLimit then
                                libSeaWar.addPlayerScore(player,allianceDomainWarCfg.destroyPoint)
                                debugLog({"action_decrDura: add destroyPoint",player})
                            end
                        end

                        -- 删除未尾的玩家
                        libSeaWar.delPlayer(ground)
                        debugLog({"action_decrDura:  delPlayer:",player})
                    end
                end

                -- 设置摧毁的标识
                battleGround.status = 2
                libSeaWar.saveBattleGround(ground)
            end

            -- 领地内的主基地被击破,该军团所有成员的部队需要自动返回
            if isMainCity then
                local allFleets = {}
                for _,uid in pairs(libSeaWar.getAllianceMembersId(aid)) do
                    if uid and uid > 0 then
                        local get,uobjs = pcall(getUserObjs,uid)
                        if get then
                            local fleets = uobjs.getModel('troops').seaWarFleetBack(1)
                            if next(fleets) then
                                saveUids[uid] = uobjs
                                sendMail(uid,"","3-9",3,{rettype=21})
                                table.merge(allFleets,fleets)
                            end
                        else
                            debugLog({"action_decrDura: getUserObjs error2",uid})
                        end
                    end
                end

                if next(allFleets) then
                    local groupFleets = {}
                    for k,v in pairs(allFleets) do
                        if not groupFleets[v.mid] then 
                            groupFleets[v.mid] = {}
                        end
                        table.insert(groupFleets[v.mid],v)
                    end

                    if next(groupFleets) then
                        for mid,fleet in pairs(groupFleets) do
                            if mid == request.params.mid or commonLock(mid,"maplock") then
                                local ground = libSeaWar.getBattleGround(fleet[1].aid,fleet[1].bid)
                                for i=1,#fleet do
                                    local player = libSeaWar.delPlayer(ground,fleet[i])
                                    if player then
                                        debugLog{"action_decrDura: del player by group fleets success",player}
                                    else
                                        debugLog{"action_decrDura: del player by group fleets failed",fleet[i]}
                                    end
                                end

                                libSeaWar.saveBattleGround(ground)
                                commonUnlock(mid, "maplock")
                            else
                                debugLog{"action_decrDura: commonLock failed ",mid}
                            end
                        end
                    end
                end
            end

            -- saveUids记录了本次处理的所有玩家,
            -- 防止战场里没有该玩家的数据,而实际上玩家有部队在
            -- 需要在这里保存
            local pushData = {event={f=1,m=2}}
            for k,v in pairs(saveUids) do
                if not libSeaWar.updatedList[k] then
                    regSendMsg(k,"msg.event",pushData)
                    v.save()
                end
            end

            -- 保存玩家信息
            libSeaWar.savePlayers()

            -- 设置战场状态(2是被摧毁)
            libSeaWar.setGroundStatus(battleGround,2)

            -- 广播建筑已被摧毁的消息
            libSeaWar.broadcast({battleGround.mid,2})

            -- 删除该建筑的所有警报
            libSeaWar.delAlertByBid(battleGround.aid,battleGround.bid)

            -- 击毁的军团事件
            if ownerAid ~= battleGround.aid then
                local allianceNames = {}
                local setRet,code=M_alliance.getalliancesname{aids=json.encode({battleGround.aid,ownerAid})}
                if type(setRet['data'])=='table' and next(setRet['data']) then
                    for k,v in pairs(setRet['data']) do
                        allianceNames[tonumber(v.aid)] = v.name
                    end 
                end

                -- 摧毁敌方领地[18]
                local aEvents = {
                    18,
                    getClientTs(),
                    battleGround.bid, -- 建筑id
                    allianceNames[ownerAid] or "", -- 攻击者军团名
                    allianceNames[battleGround.aid] or "", -- 领地军团名
                }

                M_alliance.setEvents({aid=ownerAid,data=json.encode(aEvents)})

                -- 我方领地被摧毁[19]
                aEvents[1] = 19
                M_alliance.setEvents({aid=battleGround.aid,data=json.encode(aEvents)})
            end
        end

        response.ret = 0
        response.msg = "Success"
        return response
    end

    --[[
        战争结束
        
        所有领地战场部队结算返回
        刷新最终的军团排行榜
    ]]
    function self.action_warOver(request)
        local response = self.response
        if not request.secret then
            response.ret = -102
            return response
        end

        local ts = os.time()
        local warTime = getModelObjs("aterritory").getWarTime()

        if not request.params.repair then
            if ts < warTime.battleEt or ts > warTime.clearingEt then
                response.ret = -102
                response.err = {ts,warTime.battleEt,warTime.clearingEt}
                return response
            end
        end

        local domainWarCfg = getConfig('allianceDomainWar')

        local libSeaWar = loadModel("lib.seawar")
        local result = libSeaWar.getJoinBattleList()

        local saveUids = {}
        for _,tinfo in pairs(result) do
            local battleGrounds = libSeaWar.getTerritoryBattleGround(tinfo[5])
            for bid,ground in pairs(battleGrounds) do
                if type(ground.players) == "table" then
                    for i=#ground.players,1,-1 do
                        local player = ground.players[i]
                        if player.uid then
                            local get,uobjs = pcall(getUserObjs,player.uid)
                            if get then
                                if uobjs.getModel('troops').fleetBack(player.cronId) then
                                    saveUids[player.uid] = uobjs
                                    debugLog({"action_warOver delPlayer:",player})
                                end
                            else
                                debugLog({"getUserObjs error",player.uid,player})
                            end
                        end

                        libSeaWar.delPlayer(ground)
                        debugLog({"action_decrDura:  delPlayer:",player})
                    end
                end

                libSeaWar.saveBattleGround(ground)
            end
        end

        for k,v in pairs(saveUids) do
            if not libSeaWar.updatedList[k] then
                if not v.save() then
                    debugLog({"failed",k})
                end
            end
        end

        libSeaWar.savePlayers()

        -- 设置军团领海战积分
        local result = libSeaWar.getMembersScoreFromDb()
        for k,v in pairs(result) do
            local mAterritory = getModelObjs("aterritory",v.aid,false,true)
            if mAterritory then
                -- 邮件（已经结束，快去领奖）
                mAterritory.mailNotify(75)
                mAterritory.setWarScore(v.ws)
                mAterritory.saveData()
            else
                debugLog({"mAterritory.setWarScore error:",v.ws})
            end
        end

        -- 刷新军团排行榜
        libSeaWar.setAllianceRanking(result,warTime.warEt)

        response.ret = 0
        response.msg = "Success"
        return response
    end

    -- 检测报名领地地块的名字和军团名字是否一致
    function self.action_applyMapNameCheck()
        local db = getDbo()
        local result = db:getAllRows("select aid from territory where mapx > 0 and mapy > 0")

        local aidlist = {}
        for k,v in pairs(result) do
            table.insert(aidlist,tonumber(v.aid))
        end

        local allianceInfo = {}
        local setRet,code=M_alliance.getalliancesname{aids=json.encode(aidlist)}
        if type(setRet['data'])=='table' and next(setRet['data']) then
            for k,v in pairs(setRet['data']) do
                allianceInfo[tonumber(v.aid)] = v
            end 
        end

        for k,v in pairs(result) do
            local aid = tonumber(v.aid)
            local allianceName = allianceInfo[aid] and allianceInfo[aid].name

            if allianceName then
                local mapData = db:getAllRows(string.format("select id,oid,type,x,y,name,alliance from map where oid=%d and type=9",aid))

                if type(mapData) == "table" then
                    for _,mapInfo in pairs(mapData) do
                        if mapInfo.alliance ~= allianceName then
                            local ret

                            if tonumber(mapInfo.id) > 0 then
                                ret = db:query(string.format("update map set alliance = '%s' where id = %d and oid=%d and type=9 limit 1",allianceName,mapInfo.id,aid))
                            end

                            writeLog({mapInfo,allianceInfo[aid],ret},"seawar")
                        end
                    end
                end
            end
        end

        writeLog({"applyMapNameCheck end"},"seawar")
        
        local response = self.response
        response.ret = 0
        response.msg = "Success"
        return response
    end

    function self.after() 
        local libSeaWar = loadModel("lib.seawar")
        libSeaWar.groundStorage = {}
        libSeaWar.updatedList = {}
    end

    return self
end

return api_territory_seawar