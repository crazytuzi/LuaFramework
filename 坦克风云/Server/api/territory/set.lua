local function api_territory_set(request)
    local self = {
        response = {
            ret=-1,
            msg='error',
            data = {},
        },
    }

    function self.getRules()
        return {
            ["*"] = {
                _uid={"required"},
            },

            ["action_create"] = {
                target = {"required","table"},
                aid={"required","number"},
                buildCost={"required","number"},
            },

            ["action_move"] = {
                target = {"required","table"},
                aid={"required","number"},
                buildCost={"required","number"},
            },

            ["action_recovery"] = {
                -- recoveryCost = {"required","number"},
                aid={"required","number"},
                -- costType={"required","number"},
            },

            ["action_buyDevPoint"] = {
                recoveryCost = {"required","number"},
                aid={"required","number"},
                costType={"required","number"},
            },

            ["action_allotRes"] = {
                member = {"required","number"},
                aid={"required","number"},
                resource={"required","table"},
            },

            ["action_allottedList"] = {
                aid={"required","number"},
            },
        }
    end

    local function isCommander(role)
        return tonumber(role) == 2
    end

    -- function self.before(request) end

    -- 领地创建
    function self.action_create(request)
        local response = self.response
        local uid = request.uid
        local aid = request.params.aid
        local target = request.params.target
        local isMove = request.params.isMove    
        local isRecovery = request.params.isRecovery

        if target[1] <= 2 or target[1] >= 599 or target[2] <=2 or target[2] >= 599 then
            response.ret = 0
            response.msg = "Success"
            response.data.status = 8
            return response
        end

        -- 判断是不是军团长
        local uobjs = getUserObjs(uid)
        local mUserinfo = uobjs.getModel('userinfo')

        if mUserinfo.alliance ~= aid then
            response.ret = -102
            return response
        end

        local ainfo,code = M_alliance.getalliance{getuser=1,method=1,aid=aid,uid=uid}
        if not ainfo then
            response.ret = code
            return response
        end

        -- 不是军团长
        if not isCommander(ainfo.data.role) then
            response.ret = -8008
            return response
        end

        local mTerritory = getModelObjs("aterritory",aid)

        if isMove then
            -- 还未创建军团领地,不能搬迁
            if mTerritory.isEmpty() then
                response.ret = -8403
                return response
            end

            -- 军团领地处于锁定状态(挂起)无法搬家
            if mTerritory.isLocked() then
                response.ret = -8404
                return response
            end

            -- 迁城冷却
            if not mTerritory.moveCollDown() then
                response.ret = -8422
                return response
            end
        elseif isRecovery then
            -- -8417 军团领地不是挂起状态，不能恢复
            if not mTerritory.isLocked() then
                response.ret = -8417
                return response
            end 
        else
            -- 军团领地已存在
            if not mTerritory.isEmpty() then
                response.ret = -8401
                return response
            end 
        end
        
        local mapId = getMidByPos(target[1],target[2])
        local territoryPos,territoryMapIds = mTerritory.getTerritoryMapByPos(target[1],target[2])

        -- 加锁失败,该地区的地块数据发生变化,请刷新后再试(可能被人占了/或是有人正在攻击矿)
        if not mTerritory.territoryMapLock(territoryMapIds) then
            response.ret = -8402
            return response
        end

        local mapData = mTerritory.getTerritoryMapData(territoryMapIds)
        local mTroop = uobjs.getModel('troops')
        local troops = mTroop.getCanScanTroop()

        local mMap = require 'lib.map'
        local goldMineMap = mMap:getGoldMine()

        -- 0=可以创建 1=中心坐标不是空地 2=有玩家基地 3=有金矿 4=有叛军 5=将领试炼 6=有30级以上的资源矿 7=有资源矿未被军团长占领
        local checkStatus = 0

        for k,v in pairs(mapData) do
            if tonumber(v.level) >= 30 then
                checkStatus = 6
                break
            elseif tonumber(v.oid) ~= uid then
                checkStatus = 7
                break
            elseif tonumber(v.type) == 6 then
                checkStatus = 2
                break
            elseif tonumber(v.type) == 7 then
                checkStatus = 4
                break
            elseif tonumber(v.type) == 8 then
                checkStatus = 5
                break
            elseif tonumber(v.type) == 9 then
                checkStatus = 9
                break
            elseif goldMineMap[v.id] then
                checkStatus = 3
                break
            elseif tonumber(v.type) > 5 then
                response.ret = -8405
                return response
            end
        end

        -- 玩家出战部队检测
        -- 并且自动返回
        if checkStatus == 0 then
            for k,v in pairs(mapData) do
                local isOwn = false
                for _,tinfo in pairs(troops) do
                    if tinfo.mid == tonumber(v.id) then
                        -- 矿点升级后，map上的等级没有算上经验(exp),这里直接判断一下占有的矿等级
                        if tinfo.level >= 30 then
                            checkStatus = 6
                            break
                        end

                        -- 部队返航
                        mTroop.fleetBack(tinfo.cid)
                        isOwn = true
                        break
                    end
                end

                if checkStatus == 0 and not isOwn then
                    checkStatus = 7
                end

                if isOwn then
                    response.data.troops = mTroop.toArray(true)     
                end
            end
        end
        
        -- 无法建造
        if checkStatus ~= 0 then
            mTerritory.territoryMapUnlock(territoryMapIds)

            response.ret = 0
            response.msg = "Success"
            response.data.status = checkStatus
            return response
        end

        local buildCost = isMove and mTerritory.getMoveCost() or mTerritory.getBuildCost()
        local recoveryBuildCost = 0

        if isRecovery then
            local recoveryCost = mTerritory.getRecoveryCost(request.params.costType)
            if request.params.recoveryCost ~= recoveryCost then
                response.ret = -8408
                response.recoveryCost = recoveryCost
                return response
            end

            -- 金币消耗
            if request.params.costType == 1 then
                if recoveryCost > 0 then
                    if  not mUserinfo.useGem(recoveryCost) then
                        response.ret = -109
                        return response
                    end

                    regActionLogs(uid,1,{action=185,item=costType,value=recoveryCost,params={}})
                end
            else
                -- 军团资金消耗
                recoveryBuildCost = recoveryCost
            end

            mTerritory.recoveryDevPoint()
            buildCost = 0
        end
                
        local resultMine = {}
        local removeIslandCost = 0
        for k,v in pairs(mapData) do
            removeIslandCost = removeIslandCost + mTerritory.getRemoveIslandCost(v.level)
            resultMine[tonumber(v.id)] = mTerritory.buildTypeAndLevelNum(tonumber(v.type),tonumber(v.level))
        end

        -- 所需的军团资金与客户端的不一致
        if (buildCost + removeIslandCost)  ~= ( request.params.buildCost or 0) then
            response.ret = -8408
            response.buildCost = buildCost + removeIslandCost
            return response
        end

        local totalCost = buildCost + removeIslandCost + recoveryBuildCost
        if totalCost > 0 then
            local execRet,code = M_alliance.costacpoint{uid=uid,aid=mUserinfo.alliance,costpoint=totalCost}
            if not execRet then
                response.ret = -8042
                response.err = "costacpoint failed"
                response.buildCost = totalCost
                return response
            end
        end

        local db = getDbo()
        db.conn:setautocommit(false)

        local oldTerritoryPos,oldTerritoryMapIds,oldPos
        if isMove or isRecovery then
            oldPos = mTerritory.getPos()
            if oldPos then
                oldTerritoryPos,oldTerritoryMapIds = mTerritory.getTerritoryMapByPos(oldPos[1],oldPos[2])

                -- 对搬走的地块加锁(防止有人来采矿)
                if not mTerritory.territoryMapLock(oldTerritoryMapIds) then
                    response.ret = -8402
                    return response
                end

                local oldMapData = mTerritory.getTerritoryMapData(oldTerritoryMapIds)
                local originalMine = mTerritory.clearTerritoryMap(oldMapData)

                if not originalMine then
                    response.ret = -8402
                    return response
                end

                -- 注册部队返回的cron
                mTerritory.territoryFleetBack()

                response.data.originalMine = originalMine
                response.data.old = oldTerritoryPos
            end
        end

        local mapInfo = mTerritory.createTerritory(territoryMapIds,territoryPos,mUserinfo.alliancename,resultMine)

        -- kafkaLog
        regKfkLogs(uid,'action',{
                addition={
                    {desc="创建新的领地",value={aid=aid,oldPos=oldPos,newPos=mTerritory.getPos()}},
                }
            }
        )

        if mapInfo and uobjs.save() and mTerritory.saveData() and db.conn:commit() then
            response.data.status = checkStatus
            response.data.new = mapInfo
            response.data.territory = mTerritory.formatedata()
            response.ret = 0
            response.msg = "Success"
        else
            db.conn:rollback()
        end

        mTerritory.territoryMapUnlock(territoryMapIds)
        if oldTerritoryMapIds then
            mTerritory.territoryMapUnlock(oldTerritoryMapIds)
        end

        if isMove then
            db.conn:setautocommit(true)
            mTerritory.mailNotify(72)
        end

        return response
    end

    --领地移动(搬家)
    function self.action_move(request)
        -- 领海战期间领地不能迁移
        local mTerritory = getModelObjs("aterritory",request.params.aid,true)
        if mTerritory.checkTimeOfWar(2) and mTerritory.checkApplyOfWar() then
            self.response.ret = -8430
            return self.response
        end

        request.params.isMove=true
        return self.action_create(request)
    end

    function self.action_recovery(request)
        request.params.isRecovery = true
        if not request.params.recoveryCost then
            request.params.recoveryCost = 0
        end
        return self.action_create(request)
    end

    function self.action_fleetBack(request)
        if request.secret then
            local aid = request.params.aid
            if aid and aid > 0 then
                local execRet, code = M_alliance.getMemberList{aid=aid}
                if execRet and execRet.data and execRet.data.members then
                    local pushData = json.encode({data={event={f=1}},cmd="msg.event"})
                    for k,v in pairs(execRet.data.members) do
                        local uid = tonumber(v.uid)
                        if uid and uid > 0 then
                            local get,uobjs = pcall(getUserObjs,uid)
                            if get and uobjs.getModel('troops').territoryFleetBack(9) then 
                                pcall(uobjs.save)
                                sendMsgByUid(uid,pushData)
                            end
                        end
                    end
                end
            end
        end

        local response = self.response
        response.ret = 0
        response.msg = "Success"
        return response
    end

    function self.action_minimap(request)
        local response = self.response
        local sIdx = request.params.sIdx - 1
        local eIdx = request.params.eIdx - 1

        local mTerritory = getModelObjs("aterritory")
        response.data.minimap = mTerritory.getMinimapDataByRange(sIdx,eIdx)

        response.ret = 0
        response.msg = "Success"
        return response
    end

    -- 领地维护
    function self.action_maintain(request)
        local response = self.response
        if not request.secret or not switchIsEnabled("allianceDomain") then
            writeLog("territory maintenance failed")
            return response
        end

        local ts = os.time()
        local mTerritory = getModelObjs("aterritory")
        local data = mTerritory.getUnmaintainedAids()

        -- 删除领地等级排行榜
        mTerritory.delrank()

        local failed = {}
        for _,v in pairs(data) do
            local aid = tonumber(v.aid)
            local mTerritory = getModelObjs("aterritory",aid,false,true)

            -- 未获取到该军团领地model,需要暂存起来,等待后面处理
            if not mTerritory then
                table.insert(failed,aid)
            else
                local consumePoint = mTerritory.getMaintenanceCost()
                
                if consumePoint > 0 then
                    local devPointCost = 0
                    local powerCost = 0
                    if mTerritory.power < consumePoint then
                        devPointCost = consumePoint - mTerritory.power
                        powerCost = mTerritory.power
                    else
                        powerCost = consumePoint
                    end

                    if devPointCost > 0 then
                        mTerritory.subDevPoint(devPointCost)
                    end

                    if powerCost > 0 then
                        mTerritory.subPower(powerCost)
                    end
                end

                if not mTerritory.isDestroy() then
                    mTerritory.setMaintenanceValues()
                    mTerritory.randmine()--刷矿品质
                    mTerritory.cleanDailyData()
                    mTerritory.maintained_at = ts
                    mTerritory.saveData()
                end
            end
        end
        
        if next(failed) then
            writeLog({msg="maintenance failed",failed=failed})
        end

        writeLog("territory maintenance success")

        response.ret = 0
        response.msg = "Success"
        return response
    end


    -- 购买发展值
    function self.action_buyDevPoint(request)
        local response = self.response
        local uid = request.uid
        local aid = request.params.aid

        -- 判断是不是军团长
        local uobjs = getUserObjs(uid)
        local mUserinfo = uobjs.getModel('userinfo')

        if mUserinfo.alliance ~= aid then
            response.aid = tostring(mUserinfo.aid)
            response.ret = -102
            return response
        end

        local ainfo,code = M_alliance.getalliance{getuser=1,method=1,aid=aid,uid=uid}
        if not ainfo then
            response.ret = code
            return response
        end

        -- 不是军团长
        if not isCommander(ainfo.data.role) then
            response.ret = -8008
            return response
        end

        local mTerritory = getModelObjs("aterritory",aid)
        if mTerritory.isNormal() then
            local recoveryCost = mTerritory.getRecoveryCost(request.params.costType)

            if recoveryCost <= 0 then
                response.ret = 0
                response.msg = 'Success'
                return response
            end

            if request.params.recoveryCost ~= recoveryCost then
                response.ret = -8408
                response.recoveryCost = recoveryCost
                return response
            end

            -- 金币消耗
            if request.params.costType == 1 then
                if  not mUserinfo.useGem(recoveryCost) then
                    response.ret = -109
                    return response
                end

                regActionLogs(uid,1,{action=185,item=costType,value=recoveryCost,params={}})
            else
                local execRet,code = M_alliance.costacpoint{uid=uid,aid=mUserinfo.alliance,costpoint=recoveryCost}
                if not execRet then
                    response.ret = -1989
                    response.err = "costacpoint failed"
                    response.buildCost = totalCost
                    return response
                end
            end

            mTerritory.recoveryDevPoint()

            if uobjs.save() and mTerritory.saveData() then
                response.ret = 0
                response.msg = 'Success'
            end
        end

        return response
    end

    -- 分配资源
    function self.action_allotRes(request)
        local response = self.response
        local uid = request.uid
        local aid = request.params.aid
        local member = request.params.member
        local resource = request.params.resource

        -- 判断是不是军团长
        local uobjs = getUserObjs(uid,true)
        local mUserinfo = uobjs.getModel('userinfo')

        if mUserinfo.alliance ~= aid then
            response.aid = tostring(mUserinfo.aid)
            response.ret = -102
            return response
        end

        -- 检测是否该军团成员
        local memberObjs = getUserObjs(member,true)
        local memberInfo = memberObjs.getModel("userinfo")
        if memberInfo.alliance <= 0 or memberInfo.alliance ~= mUserinfo.alliance then
            response.ret = -8018
            return response
        end

        local ainfo,code = M_alliance.getalliance{getuser=1,method=1,aid=aid,uid=uid}
        if not ainfo then
            response.ret = code
            return response
        end

        -- 不是军团长
        if not isCommander(ainfo.data.role) then
            response.ret = -8008
            return response
        end

        local mTerritory = getModelObjs("aterritory",aid)
        if mTerritory.isNormal() then
            local resourceCfg = {r1=true,r2=true,r3=true,r4=true}
            local allianceCityCfg = getConfig("allianceCity")

            -- 总仓库的存储量
            local totalCapacity = 0
            for v in pairs(resourceCfg) do
                local capacity = mTerritory.getStorageCapacity(v)
                
                if resource[v] then
                    local allotRes =  mTerritory[v] - capacity * allianceCityCfg.fullLimit
                    if resource[v] > allotRes or allotRes <= 0 then
                        response.ret = -8418
                        response.err = {v,resource[v],allotRes}
                        return response
                    end
                end

                totalCapacity = totalCapacity + capacity
            end

            local oneMaxRes = math.floor(totalCapacity * allianceCityCfg.oneMax)

            -- resource:{r1=100,r2=200}
            local n = 0
            for k,v in pairs(resource) do
                n = n + v
                if not resourceCfg[k] then
                    response.ret = -8419
                    response.err = {n,oneMaxRes}
                end
            end

            -- 分配的总资源量超过了
            if n > oneMaxRes then
                response.ret = -8419
                response.err = {n,oneMaxRes}
                return response
            end

            if not mTerritory.useResource(resource) then
                response.ret = -8419
                return response
            end

            -- -8421 今日分配的成员数已经达到上限
            if mTerritory.countAllotMembers() >= allianceCityCfg.allotPeopleMax then
                response.ret = -8421
                return response
            end

            -- 已经分配过
            if not mTerritory.setAllotMember(member) then
                response.ret = -8420
                return response
            end

            if mTerritory.saveData() then
                local serverItem = {}
                local showItem = {u={}}

                for k,v in pairs(resource) do
                    serverItem["userinfo_"..k] = v
                    showItem.u[k] = v
                end

                -- {"f":[0],"h":{"userinfo_gems":80000},"q":{"u":[{"gems":80000}]}}
                local mailItem = {
                    h = serverItem,
                    q = showItem,
                }
                
                MAIL:mailSent(member,1,member,'','',mailType,"",1,0,5,mailItem)

                response.ret = 0
                response.msg = 'Success'
            end

            return response
            -- if
            -- --分配当前仓库的百分比
            -- --仓库满足条件>当前仓库存储的x%
            -- fullLimit=0.5,
            -- --最大分配人数
            -- allotPeopleMax=5,
            -- --每人最大分配比例
            -- oneMax=0.6,

        end
    end

    -- 获取分配资源的成员列表
    function self.action_allottedList(request)
        local response = self.response
        local uid = request.uid
        local aid = request.params.aid

        local mTerritory = getModelObjs("aterritory",aid)
        response.data.list = {}
        if mTerritory.isNormal() then
            response.data.list = mTerritory.getAlllotMembers()
        end

        response.ret = 0
        response.msg = 'Success'
        return response
    end

    -- function self.after() end

    -- 军团长手动刷新军团任务
    function self.action_rftask(request)
        local response = self.response
        local uid = request.uid
        local aid = request.params.aid

        -- 判断是不是军团长
        local uobjs = getUserObjs(uid)
        local mUserinfo = uobjs.getModel('userinfo')

        if mUserinfo.alliance ~= aid then
            response.ret = -102
            return response
        end

        local ainfo,code = M_alliance.getalliance{getuser=1,method=1,aid=aid,uid=uid}
        if not ainfo then
            response.ret = code
            return response
        end

        -- 不是军团长
        if not isCommander(ainfo.data.role) then
            response.ret = -8008
            return response
        end

        local mTerritory = getModelObjs("aterritory",aid)
        local allianceCityCfg = getConfig('allianceCity')

        local ts= getClientTs()
        local weeTs = getWeeTs()

        if mTerritory.maintenance() then
            response.ret = -8411
            return response
        end

        local sttime = weeTs + allianceCityCfg.pubTaskTime[1]*3600+allianceCityCfg.pubTaskTime[2]*60
        local edtime = weeTs + allianceCityCfg.realPubTaskTime[1]*3600+allianceCityCfg.realPubTaskTime[2]*60
        -- 不在刷新任务发布时间内
        if ts>edtime or ts<sttime then
            response.ret = -8415
            return response
        end

	mTerritory.tasklist()-- 先刷新任务数据 确保是当前已刷新过的（前端如果没有调用的话 服务器先刷新一下）
        mTerritory.rfTask()
        local total = allianceCityCfg.pubTaskNum + allianceCityCfg.pubTaskLimit
        if mTerritory.task.rn>total then
            response.ret = -8140
            return response
        end
        local gems = 0
        if mTerritory.task.rn>allianceCityCfg.pubTaskNum then
            gems = allianceCityCfg.pubTaskCost
        end

        local flag = false

        if gems>0 then
            -- 消耗钻石
            if not mUserinfo.useGem(gems) then
                response.ret = -109
                return response
            end
            regActionLogs(uid, 1, {action = 184, item = "", value = gems, params = {num=mTerritory.task.rn,reft=mTerritory.task.upt,ts=ts}})
            flag = true
        end

        if mTerritory.saveData() then
            if flag then
                if not uobjs.save() then
                    response.ret = -106
                    return response
                end
            end
            response.data.task = mTerritory.task
            response.ret = 0
            response.msg = 'Success'
        else
            response.ret = -106
        end

        return response
    end

    -- 发布军团任务
    function self.action_pubtask(request)
        local response = self.response
        local uid = request.uid
        local aid = request.params.aid
        local tid =  request.params.tid

        -- 判断是不是军团长
        local uobjs = getUserObjs(uid)
        local mUserinfo = uobjs.getModel('userinfo')

        if mUserinfo.alliance ~= aid or not uid or not tid then
            response.ret = -102
            return response
        end

        local ainfo,code = M_alliance.getalliance{getuser=1,method=1,aid=aid,uid=uid}
        if not ainfo then
            response.ret = code
            return response
        end

        -- 不是军团长
        if not isCommander(ainfo.data.role) then
            response.ret = -8008
            return response
        end

        local mTerritory = getModelObjs("aterritory",aid,false)
        local allianceCityCfg = getConfig('allianceCity')

        local ts= getClientTs()
        local weeTs = getWeeTs()

        if mTerritory.maintenance() then
            response.ret = -8411
            return response
        end

        local sttime = weeTs + allianceCityCfg.pubTaskTime[1]*3600+allianceCityCfg.pubTaskTime[1]*60
        local edtime =  weeTs + allianceCityCfg.realPubTaskTime[1]*3600+allianceCityCfg.realPubTaskTime[2]
        -- 不在任务发布时间内
        if ts>edtime or ts<sttime then
            response.ret = -8415
            return response
        end

        if not mTerritory.task.upt then mTerritory.task.upt=0 end

        local flagtime = weeTs + allianceCityCfg.pubTaskTime[1]*3600
        local refreshtime = 0 -- 刷新时间标识
        -- 获取刷新时间标识
        if ts > weeTs and ts < flagtime then
            refreshtime = flagtime-86400
        else
            refreshtime = flagtime
        end

        if mTerritory.task.upt ~= refreshtime then
            response.ret = -1981
            return response
        end

        if mTerritory.task.auto ==1 then
            response.ret = -1989
            return response
        end

        -- 设置军团任务
        if mTerritory.pubTask(tid) then
            if mTerritory.saveData() then
                --response.data.task = mTerritory.task
                response.ret = 0
                response.msg = 'Success'
            else
                response.ret = -106
            end
        else
            response.ret = -106
        end

        return response        

    end

    -- 军团长确认刷新的矿品质
    function self.action_setmine(request)
        local response = self.response
        local uid = request.uid

        -- 判断是不是军团长
        local uobjs = getUserObjs(uid)
        local mUserinfo = uobjs.getModel('userinfo')

        if mUserinfo.alliance ==0 then
            response.ret = -102
            return response
        end

        local ainfo,code = M_alliance.getalliance{getuser=1,method=1,aid=mUserinfo.alliance,uid=uid}
        if not ainfo then
            response.ret = code
            return response
        end

        -- 不是军团长
        if not isCommander(ainfo.data.role) then
            response.ret = -8008
            return response
        end

        local mTerritory = getModelObjs("aterritory",mUserinfo.alliance,false)
        local allianceCityCfg = getConfig('allianceCity')

        local ts= getClientTs()
        local weeTs = getWeeTs()

        local sttime = weeTs + allianceCityCfg.lockToCollect[1][1]*3600+allianceCityCfg.lockToCollect[1][2]*60
        local edtime =  weeTs + allianceCityCfg.lockToCollect[2][1]*3600+allianceCityCfg.lockToCollect[2][2]*60
      
        -- -- 不在任务发布时间内
        if ts>edtime or ts<sttime then
            response.ret = -8415
            return response
        end

        if not mTerritory.minerefresh.qr then
            mTerritory.minerefresh.qr = 0
        end

        if mTerritory.minerefresh.qr ==1 then
            response.ret = -8423
            return response
        end

        mTerritory.minerefresh.t = getWeeTs() 
        mTerritory.minerefresh.qr =1
        if mTerritory.saveData() then
            response.ret = 0
            response.msg = 'Success'
        else
            response.ret = -106
        end
        return response
    end

    return self
end

return api_territory_set
