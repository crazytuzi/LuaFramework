local function api_greatroute_map(request)
    local self = {
        response = {
            ret=-1,
            msg='error',
            data = {},
        },

        aid = 0,
        bid = 0,
    }

    self._cronApi = {
        action_settlement=true,
    }

    function self.getRules()
        return {
            ["*"] = {
                _uid={"required"}
            },
            ["action_explore2"] = {
                fortId = {"required", "string"},
            },
        }
    end

    function self.before(request) 
        local response = self.response
        local uid=request.uid
    
        if not uid then
            response.ret = -102
            return response
        end

        local matchInfo,code = loadFuncModel("serverbattle").getGreatRouteInfo()
        if not next(matchInfo) then
            response.ret = -180
            return response
        end

        self.bid = matchInfo.bid
        if self._cronApi[self._method] then
            self.matchInfo = matchInfo
            return
        end

        local uobjs = getUserObjs(uid)
        local aid = uobjs.getModel("userinfo").alliance

        if aid < 0 then
            response.ret = -102
            return response
        end

        self.aid = aid
        local mAGreatRoute = getModelObjs("agreatroute",aid,true)

        -- 没有报名无法操作
        if not mAGreatRoute.checkApplyOfWar() then
            response.ret = -8483
            return response
        end

        -- 不是战斗期
        if not mAGreatRoute.isBattleStage() then
            response.ret = -8492
            return response
        end
    end

    function self.action_get(request)
        local response = self.response
        local uid = request.uid
        local uobjs = getUserObjs(uid)
        local aid = uobjs.getModel("userinfo").alliance
        local mAGreatRoute = getModelObjs("agreatroute",aid,true)

        local map,agreatroute = mAGreatRoute.toArray()
        response.data.greatRoute = {
            map = map,
            agreatroute=agreatroute,
        }

        response.ret = 0
        response.msg = 'Success'
        return response
    end

    -- 探索要塞（打BOSS）
    function self.action_explore2(request)
        local response = self.response
        local uid = request.uid
        local fortId = request.params.fortId

        local uobjs = getUserObjs(uid)
        local mUserinfo = uobjs.getModel("userinfo")
        local aid = mUserinfo.alliance
        local mUGreatRoute = uobjs.getModel("ugreatroute")

        local mAGreatRoute = getModelObjs("agreatroute",aid)
        if not mAGreatRoute.checkFortCanReach(fortId) then
            response.ret = -8484 -- 操作的据点不可到达
            return response
        end

        -- 行动点数不够
        if not mUGreatRoute.reduceAcPoint() then
            response.ret = -8485
            return response
        end

        local mapCfg = getConfig("greatRoute").map[fortId]
        if mapCfg.type ~= 2 then
            response.ret = -102
            return response
        end

        -- 已被击杀，不能再探索了
        if mAGreatRoute.bossWasKilled(fortId) then
            response.ret = -8486
            return response
        end

        local mTGreatRoute = getModelObjs("tgreatroute",uid,true)
        local userTroop, userFleetInfo = mTGreatRoute.getTroops(mUGreatRoute.getBuff())
        if not userTroop then
            response.ret = -102
            return response
        end
        
        local bossTroop, bossFleetInfo, bossHp, bossPaotou, currHp = mAGreatRoute.getBoss(fortId,mapCfg.bossLevel)

        -- 每次攻击会固定掉BOSS总血量百分比的血量
        local battleParams = {
            boss=true,
            -- delhp=math.ceil(bossHp * mapCfg.cutHpRate / (math.ceil(bossHp * 6  / currHp))),
            diePaoTou=bossPaotou,
            -- delhpShowKey="@",
        }

        require "lib.battle"
        local report={}
        local deBossHp=0
        report.d,deBossHp = battle(userFleetInfo,bossFleetInfo,nil,nil,battleParams)
        report.p = {{},{mUserinfo.nickname,mUserinfo.level,1,1}}
        report.t = {bossTroop,userTroop.troops}
        report.h = {{},userTroop.hero}
        report.se = {0, userTroop.equip}
        
        local score = 0
        local isWin = 0
        if deBossHp > 0 then
            score = mapCfg.perScore

            -- 如果被击杀，额外给击杀积分
            if mAGreatRoute.deBossHp(fortId,deBossHp) then
                score = score + mapCfg.killScore
                report.w = 1
                isWin = 1

                mAGreatRoute.addScore(mapCfg.aliExScore)
                mUGreatRoute.addFeat(mapCfg.aliExScore)
            end

            mUGreatRoute.addScore(score)
        end

        local fixedDamage = bossHp * mapCfg.cutHpRate
        if fixedDamage < mAGreatRoute[fortId] then
            mAGreatRoute.deBossHp(fortId,fixedDamage)
        end

        if mAGreatRoute.save() and uobjs.save() then
            report.greatboss = {mapCfg.bossLevel,bossHp,bossHp-mAGreatRoute[fortId],0,currHp}
            response.data.greatRoute = {
                report = report,
                map = mAGreatRoute.toArray(),
                ugreatroute = mUGreatRoute.toArray(true),
            }

            mAGreatRoute.addBattleReport({
                uid=uid,
                fort=fortId,
                score=score,
                win=isWin,
                content=report
            })

            if isWin == 1 then
                mAGreatRoute.addBattleEvent({2,fortId,os.time(),mUserinfo.nickname,0,0})
            end

            response.ret = 0
            response.msg = 'Success'
        end

        return response
    end

    -- 探索港口
    function self.action_explore3(request)
        local response = self.response
        local uid = request.uid
        local fortId = request.params.fortId
        local portCost = tonumber(request.params.portCost)

        local uobjs = getUserObjs(uid)
        local mUserinfo = uobjs.getModel("userinfo")
        local aid = mUserinfo.alliance
        local mUGreatRoute = uobjs.getModel("ugreatroute")

        local mAGreatRoute = getModelObjs("agreatroute",aid)
        if not mAGreatRoute.checkFortCanReach(fortId) then
            response.ret = -8484 -- 操作的据点不可到达
            return response
        end

        -- 行动点数不够
        if not mUGreatRoute.reduceAcPoint() then
            response.ret = -8485
            return response
        end

        local mapCfg = getConfig("greatRoute").map[fortId]
        if mapCfg.type ~= 3 then
            response.ret = -102
            return response
        end

        -- 叛军已被击杀，不能再探索了
        if mAGreatRoute.rebelWasKilled(fortId) then
            response.ret = -8486
            return response
        end

        local gemCost = 0
        if portCost > 0 then
            if mapCfg.portCost ~= portCost then
                response.ret = -102
                return response
            end

            gemCost = portCost
        end

        local portBuff
        if gemCost > 0 then
            if not mUserinfo.useGem(gemCost) then
                response.ret = -109
                return response
            end

            portBuff = true

            -- actionlog 伟大航线-购买三倍攻击
            regActionLogs(uid,1,{action=280,item="",value=gemCost,params={fortId=fortId}})
        end

        local mTGreatRoute = getModelObjs("tgreatroute",uid,true)
        local userTroop, userFleetInfo = mTGreatRoute.getTroops(mUGreatRoute.getBuff(),portBuff)
        if not userTroop then
            response.ret = -102
            return response
        end

        local rebelInfo, rebelTroop, rebelFleetInfo, startDamage = mAGreatRoute.getRebel(fortId)
        if not rebelTroop then
            response.ret = -8486
            return response
        end

        -- 每次攻击会固定掉指定比例的血量
        local battleParams = {
            -- delhp=startDamage,
            -- delhpShowKey="@",
        }

        require "lib.battle"
        local report={}
        local deBossHp=0
        report.d, report.r = battle(userFleetInfo,rebelFleetInfo,nil,nil,battleParams)
        report.p = {{mAGreatRoute.getRebelName(rebelInfo),0,0},{mUserinfo.nickname,mUserinfo.level,1}}
        report.t = {rebelTroop,userTroop.troops}
        report.h = {{},userTroop.hero}
        report.se = {0, userTroop.equip}

        local score = mapCfg.perScore
        local isWin = 0
        if report.r == 1 then
            isWin = 1
            score = score + mapCfg.killScore
            mAGreatRoute.killRebel(fortId)

            mAGreatRoute.addScore(mapCfg.aliExScore)
            mUGreatRoute.addFeat(mapCfg.aliExScore)
        end

        mUGreatRoute.addScore(score)

        if mAGreatRoute.save() and uobjs.save() then
            response.data.greatRoute = {
                map = mAGreatRoute.toArray(),
                report = report,
                ugreatroute = mUGreatRoute.toArray(true),
            }

            mAGreatRoute.addBattleReport({
                uid=uid,
                fort=fortId,
                score=score,
                win=isWin,
                content=report
            })

            if isWin == 1 then
                local eid = 4
                if mAGreatRoute[fortId] == mapCfg.passNeed then
                    eid = 1
                elseif mAGreatRoute.rebelWasKilled() then
                    eid = 2
                end

                mAGreatRoute.addBattleEvent({eid,fortId,os.time(),mUserinfo.nickname,0,0})
            end

            response.ret = 0
            response.msg = 'Success'
        end

        return response
    end

    -- 探索无人岛屿
    function self.action_explore4(request)
        local response = self.response
        local uid = request.uid
        local fortId = request.params.fortId
        local score = math.floor(tonumber(request.params.score))
        local pass = request.params.pass

        local uobjs = getUserObjs(uid)
        local aid = uobjs.getModel("userinfo").alliance
        local mUGreatRoute = uobjs.getModel("ugreatroute")

        local mAGreatRoute = getModelObjs("agreatroute",aid)
        if not mAGreatRoute.checkFortCanReach(fortId) then
            response.ret = -8484 -- 操作的据点不可到达
            return response
        end

        -- 行动点数不够
        if not mUGreatRoute.reduceAcPoint() then
            response.ret = -8485
            return response
        end

        local greatRouteCfg = getConfig("greatRoute")
        local mapCfg = greatRouteCfg.map[fortId]
        if mapCfg.type ~= 4 or score < 0 then
            response.ret = -102
            return response
        end

        -- 加分不能超过配置
        if score > mapCfg.perScore then
            score = mapCfg.perScore
        end

        -- 如果客户端小游戏通过
        if pass and score > 0 then
            -- 未探索过该据点
            if not mUGreatRoute.wasExplored(fortId) then
                mUGreatRoute.explore(fortId)
                mAGreatRoute.explore(fortId)
                mUGreatRoute.addFeat(mapCfg.aliExScore)
                mAGreatRoute.addScore(mapCfg.aliExScore)
            end
        end

        if score > 0 then
            mUGreatRoute.addScore(score)
        end

        if uobjs.save() and mAGreatRoute.save() then
            response.data.greatRoute = {
                map = mAGreatRoute.toArray(),
                ugreatroute = mUGreatRoute.toArray(true),
            }

            response.ret = 0
            response.msg = 'Success'
        end

        return response
    end

    -- 探索未知海域
    function self.action_explore5(request)
        local response = self.response
        local uid = request.uid
        local fortId = request.params.fortId

        local uobjs = getUserObjs(uid)
        local mUserinfo = uobjs.getModel("userinfo")
        local aid = mUserinfo.alliance
        local mUGreatRoute = uobjs.getModel("ugreatroute")

        local mAGreatRoute = getModelObjs("agreatroute",aid)
        if not mAGreatRoute.checkFortCanReach(fortId) then
            response.ret = -8484 -- 操作的据点不可到达
            return response
        end

        -- 行动点数不够
        if not mUGreatRoute.reduceAcPoint() then
            response.ret = -8485
            return response
        end

        local greatRouteCfg = getConfig("greatRoute")
        local mapCfg = greatRouteCfg.map[fortId]
        if mapCfg.type ~= 5 then
            response.ret = -102
            return response
        end

        local buffId = getRewardByPool(greatRouteCfg.buffPool[mapCfg.buffPool])[1]
        local buffCfg = greatRouteCfg.buff[buffId]

        local items = {}

        if buffCfg.attType then
            mUGreatRoute.setBuff(buffId)
        elseif buffCfg.perScore then
            setRandSeed()
            table.insert(items,rand(buffCfg.perScore[1],buffCfg.perScore[2]))
            table.insert(items,rand(buffCfg.aliScore[1],buffCfg.aliScore[2]))

            mUGreatRoute.addScore(items[1])
            mUGreatRoute.addFeat(items[2])
            mAGreatRoute.addScore(items[2])

            mAGreatRoute.setSyncData({1,uid,mUGreatRoute.getFeat()})
        elseif buffCfg.point then
            table.insert(items,rand(buffCfg.point[1],buffCfg.point[2]))
            mUGreatRoute.recoverAcPoint(items[1])
        end

        local isOccupy = mAGreatRoute.explore(fortId)

        if mAGreatRoute.save() and uobjs.save() then
            response.data.greatRoute = {
                map = mAGreatRoute.toArray(),
                items = items,
                buffId = buffId,
                ugreatroute = mUGreatRoute.toArray(true),
            }

            if items[2] or isOccupy then
                local eid = isOccupy and 2 or 5
                mAGreatRoute.addBattleEvent({eid,fortId,os.time(),mUserinfo.nickname,0,items[2] or 0})
            end

            response.ret = 0
            response.msg = 'Success'
        end

        return response
    end

    -- 探索矿场
    -- 没有产量，即没有完成，则不会有入侵
    function self.action_explore6(request)
        local response = self.response
        local uid = request.uid
        local fortId = request.params.fortId

        local uobjs = getUserObjs(uid)
        local aid = uobjs.getModel("userinfo").alliance
        local mUGreatRoute = uobjs.getModel("ugreatroute")

        local mAGreatRoute = getModelObjs("agreatroute",aid)
        if not mAGreatRoute.checkFortCanReach(fortId) then
            response.ret = -8484 -- 操作的据点不可到达
            return response
        end

        -- 行动点数不够
        if not mUGreatRoute.reduceAcPoint() then
            response.ret = -8485
            return response
        end

        local greatRouteCfg = getConfig("greatRoute")
        local mapCfg = greatRouteCfg.map[fortId]
        if mapCfg.type ~= 6 then
            response.ret = -102
            return response
        end

        -- 已探索过该据点
        if mUGreatRoute.wasExplored(fortId) then
            response.ret = -8487
            return response
        end

        mUGreatRoute.explore(fortId)
        mUGreatRoute.addScore(mapCfg.perScore)

        local isOccupy = mAGreatRoute.explore6(fortId)

        if uobjs.save() and mAGreatRoute.save() then
            response.data.greatRoute = {
                map = mAGreatRoute.toArray(),
                ugreatroute = mUGreatRoute.toArray(true),
            }

            if isOccupy then
                mAGreatRoute.addBattleEvent({2,fortId,os.time(),uobjs.getModel("userinfo").nickname,0,0})
            end

            response.ret = 0
            response.msg = 'Success'
        end

        return response
    end

    -- 攻击入侵者
    function self.action_attackInvader(request)
        local response = self.response
        local uid = request.uid
        local fortId = request.params.fortId

        local uobjs = getUserObjs(uid)
        local mUserinfo = uobjs.getModel("userinfo")
        local aid = mUserinfo.alliance
        local mUGreatRoute = uobjs.getModel("ugreatroute")

        local mAGreatRoute = getModelObjs("agreatroute",aid)
        if not mAGreatRoute.checkFortCanReach(fortId) then
            response.ret = -8484 -- 操作的据点不可到达
            return response
        end

        -- 行动点数不够
        if not mUGreatRoute.reduceAcPoint() then
            response.ret = -8485
            return response
        end

        local mapCfg = getConfig("greatRoute").map[fortId]
        if mapCfg.type ~= 6 then
            response.ret = -102
            return response
        end

        -- 入侵者已被击杀
        if mAGreatRoute.invaderWasKilled(fortId) then
            response.ret = -8489
            return response
        end

        local mTGreatRoute = getModelObjs("tgreatroute",uid,true)
        local userTroop, userFleetInfo = mTGreatRoute.getTroops(mUGreatRoute.getBuff())
        if not userTroop then
            response.ret = -102
            return response
        end

        local invaderList = mAGreatRoute.getInvaderList(fortId)
        if not next(invaderList) then
            response.err = "no invaderList"
            response.ret = -8486
            return response
        end

        local invader, iLevel, invaderTroop, invaderFleetInfo = mAGreatRoute.getInvader(fortId,invaderList)
        if not invaderTroop then
            response.ret = -8486
            return response
        end

        require "lib.battle"
        local report={}

        local report, aInavlidFleet, dInvalidFleet, attSeq, seqPoint= {}
        report.d, report.r, aInavlidFleet, dInvalidFleet, attSeq, seqPoint = battle(userFleetInfo,invaderFleetInfo,1)

        if attSeq == 1 then
            report.p = {{invader[4],iLevel,1,seqPoint[2]},{mUserinfo.nickname,mUserinfo.level,0, seqPoint[1]}}
        else
            report.p = {{invader[4],iLevel,0,seqPoint[2]},{mUserinfo.nickname,mUserinfo.level,1,seqPoint[1]}}
        end

        report.t = {invaderTroop.troops,userTroop.troops}
        report.h = {invaderTroop.hero,userTroop.hero}
        report.se = {invaderTroop.equip, userTroop.equip}

        local score = mapCfg.perScore
        local isWin = 0

        if report.r == 1 then
            score = score + mapCfg.killScore
            mAGreatRoute.killInvader(fortId,invaderList)
            isWin = 1

            mUGreatRoute.addFeat(mapCfg.aliExScore)
            mAGreatRoute.addScore(mapCfg.aliExScore)
            mAGreatRoute.setSyncData({1,uid,mUGreatRoute.getFeat()})
        else
            mAGreatRoute.setInvadeTroops(fortId,dInvalidFleet)
        end

        mUGreatRoute.addScore(score)

        if mAGreatRoute.save() and uobjs.save() then
            response.data.greatRoute = {
                map = mAGreatRoute.toArray(),
                report = report,
                ugreatroute = mUGreatRoute.toArray(true),
            }

            mAGreatRoute.addBattleReport({
                uid=uid,
                fort=fortId,
                score=score,
                win=isWin,
                content=report
            })

            if isWin == 1 then
                mAGreatRoute.addBattleEvent({3,fortId,os.time(),mUserinfo.nickname,invader[4],0})
            end

            response.ret = 0
            response.msg = 'Success'
        end

        return response
    end

    -- 矿点检测
    function self.action_check(request)
        local response = self.response
        response.ret = 0
        response.msg = 'Success'

        local uid = request.uid
        local fortId = request.params.fortId

        local aid = getUserObjs(uid).getModel("userinfo").alliance
        local mAGreatRoute = getModelObjs("agreatroute",aid)

        local greatRouteCfg = getConfig("greatRoute")
        local mapCfg = greatRouteCfg.map[fortId]
        if mapCfg.type ~= 6 then
            return response
        end

        -- 已有入侵者
        if mAGreatRoute.hasInvader(fortId) then
            response.err = "invaders exists"
            return response
        end

        if not mAGreatRoute.canInvade(fortId) then
            response.err = "can't invade"
            return response
        end

        -- 执行入侵
        mAGreatRoute.invade()

        mAGreatRoute.save() 

        response.ret = 0
        response.msg = 'Success'

        return response
    end

    -- 入侵者列表
    function self.action_invaderList(request)
        local response = self.response

        local uid = request.uid
        local fortId = request.params.fortId

        local aid = getUserObjs(uid).getModel("userinfo").alliance
        local mAGreatRoute = getModelObjs("agreatroute",aid)

        local greatRouteCfg = getConfig("greatRoute")
        local mapCfg = greatRouteCfg.map[fortId]
        if mapCfg.type ~= 6 then
            response.ret = -102
            return response
        end

        local invaderList = mAGreatRoute.getInvaderList(fortId)

        response.data.greatRoute = {
            invaderList = invaderList
        }
        
        response.ret = 0
        response.msg = 'Success'
        return response
    end

    --[[
        战场结算
        每小时结算一次,直接拿当前的积分产出速度*h
    ]]
    function self.action_settlement(request)
        local response = self.response
        local mAGreatRoute = getModelObjs("agreatroute")
        local agData = mAGreatRoute.getAgData(self.bid)

        -- 不是战斗期
        if not mAGreatRoute.isBattleStage(self.matchInfo.st) then
            response.ret = 0
            response.msg = 'Success'
            return response
        end

        local syncData = {}
        if type(agData) == "table" then
            for k,v in pairs(agData) do
                local aid = tonumber(v) or 0
                if aid > 0 then
                    local agModel = getModelObjs("agreatroute",aid,false,true)
                    if agModel and agModel.score > 0 then
                        table.insert(syncData,{
                            2,agModel.score,aid
                        })

                        agModel.save()
                    else
                        writeLog("get agModel failed")
                    end
                end
            end
        end

        if next(syncData) then
            local data={
                cmd='greatroute.server.syncScore',
                params = {
                    bid="b" .. self.bid,
                    zid=getZoneId(),
                    data = syncData,
                }
            }

            local ok,ret = mAGreatRoute.serverRequest(data) 
            if ok then
                response.ret = 0
                response.msg = 'Success'
            else
                response.err = ret
            end
        else
            response.ret = 0
            response.msg = 'Success'
        end

        response.syncData = syncData
        return response
    end

    function self.after(response)
        if response.ret == 0 then
            getModelObjs("agreatroute",self.aid,true).syncAllData()
        end
    end

    return self
end

return api_greatroute_map