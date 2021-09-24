function api_cron_attack(request)
    local response = {
        ret=-1,
        msg='error',
        data = {},
    }
    
    local cronId = request.params.cronid
    local target = request.params.target
    local attacker = request.params.attacker
    local isUseGem = request.params.usegem
    local ts = getClientTs()    
    
    -- 参数验证
    if cronId == nil or type(target) ~= 'table' or attacker == nil then
        response.ret = -102
        response.msg = 'params invalid'
        return response
    end
    local mapId = getMidByPos(target[1],target[2])
    if not commonLock(mapId,"maplock", attacker) then
        response.ret = -5004  
        return response
    end
    cronId = 'c'.. cronId
    ------------------------------------------------------------------------------------

    -- isSys 是否是系统定时队列调用，如果不是，需要返回相应数据
    -- mAttackTroop 攻击者的troop model
    -- mAttackUserinfo 攻击者的userinfo model
    -- mAttackBag 攻击的bag model 攻击矿点时，有可能获得道具
    -- mBattle 战斗的model
    local function setResponseData(isSys,mAttackTroop,mAttackUserinfo,mAttackBag,mBattle)
        if not isSys then    
            response.data.troops = mAttackTroop.toArray(true)
            response.data.userinfo = mAttackUserinfo.toArray(true)
            if mBattle.receiveProps or mBattle.rebelInfo then
                response.data.bag = mAttackBag.toArray(true)
            end
        end
    end

    --[[
        主基地击飞

        param int mailType 
            76 参战玩家被击飞
            77 非参战玩家被击飞(没有保护罩)
            78 非参战玩家被击飞(有保护罩)
        param table mTargetUserinfo 目标用户的信息
        param table territoryPos 领地的中心坐标(飞离以该坐标为中点计算出的范围)
        param string alliancelogo
        ...

        return bool
    ]]
    local function baseFly(mailType,mTargetUserinfo,territoryPos,alliancelogo,attackerName)
        local ret, posInfo = loadModel("lib.seawar").userBaseMoveOutWarRange(mTargetUserinfo,territoryPos,alliancelogo)
        if ret then
            local content = json.encode({
                type=mailType,
                attacker=attackerName,
                oldPos=posInfo[1],
                newPos=posInfo[2],
            })

            MAIL:mailSent(mTargetUserinfo.uid,1,mTargetUserinfo.uid,'','',mailType,content,1,0)
        end

        return ret
    end

    ------------------------------------------------------------------------------------

    local auobjs = getUserObjs(attacker)
    auobjs.load({"userinfo", "techs", "troops", "props","bag","skills","buildings","dailytask","task","useractive"})
    local mAttackTroop = auobjs.getModel('troops')
    local mAttackBag = auobjs.getModel('bag')
    local mAttackUserinfo = auobjs.getModel('userinfo')
    local mAttackTask = auobjs.getModel('task')
    local mAttackArmor = auobjs.getModel('armor')
    local mAttackAweapon = auobjs.getModel('alienweapon')
    local mAttackDailyTask = auobjs.getModel('dailytask')  -- 日常任务
    local attFleetInfo = mAttackTroop.getFleetByCron(cronId)    -- 攻击者的部队信息
    local duobjs,mTargetUserinfo,mTargetTroop,huobjs,anobjs -- 防守者uobj，防守方用户信息，协防者uobj,试炼任务

    -- 非等待攻击状态
    if mAttackTroop.checkCronFleetStatus(cronId) ~= 0 or not attFleetInfo or attFleetInfo.seaWarFlag then
        response.ret = -5001
        response.msg = 'fleet status invalid'
        
        commonUnlock(mapId, "maplock")
        return response
    end

    --------------------活动加成

    attFleetInfo.AcRate=mAttackTroop.getActiveAlienRate()
    ------------------------------------------------------------------------------------
    
    -- 初始化map与battle相关数据
    -- targetType 目标类型，0为空地，1-5是资源点，6是玩家
    local mMap = require 'lib.map'        
    
    local map = mMap:getMapById(mapId)
    local targetType = tonumber(map.type) or 0     
    local oid = tonumber(map.oid) or 0
    local omaplevel = tonumber(map.level) or 0
    local mapexp = tonumber(map.exp) or 0
    -- 矿点升级需要计算一下矿点最新等级
    maplevel=mMap:getMapLevel(omaplevel,mapexp,mapId)


    -- 清除攻击方的保护罩
    local function resetAttackerProtect()
        -- 解除保护时间
        local protectTime = mAttackUserinfo.protect or 0       
        local ts = getClientTs()
          
        if protectTime > ts then
            mMap:resetProtectTime(attacker)
            local mAttackProp = auobjs.getModel('props')
            mAttackProp.clearUsePropCd('p14')
            response.data.props = mAttackProp.toArray(true)
        end
    end

    -- 排查自己
    local function checkMapIsOccupyed()
        if type(mAttackTroop.attack) == 'table' and next(mAttackTroop.attack) then
            for k, v in pairs(mAttackTroop.attack) do
                if not v.bs and tonumber(v.isGather) and tonumber(v.isGather)>1 then
                    if v.targetid[1] == target[1] and v.targetid[2] == target[2] then
                        return true
                    elseif ( v.type == 9 and attFleetInfo.type == v.type and not v.seaWarFlag ) then
                        return true
                    end
                end
            end
        end

        return false
    end

    require "model.battle"
    local mBattle = model_battle()    
    mBattle.mMap = mMap
    mBattle.defenser = oid
    mBattle.attacker = attacker
    mBattle.islandType = targetType
    mBattle.place = target
    mBattle.islandLevel = maplevel
    mBattle.attackerName = mAttackUserinfo.nickname
    mBattle.attackerLevel = mAttackUserinfo.level     
    mBattle.attackerPic = mAttackUserinfo.pic--头像
    mBattle.attackerbPic = mAttackUserinfo.bpic--头像框
    mBattle.attackeraPic = mAttackUserinfo.apic--挂件
    mBattle.attackerVip = mAttackUserinfo.showvip()
    mBattle.attackerFc = mAttackUserinfo.fc
    mBattle.AAName = mAttackUserinfo.alliancename
    mBattle.AttackerPlace = {mAttackUserinfo.mapx,mAttackUserinfo.mapy}
    mBattle.attackerArmorInfo = mAttackArmor.formatUsedInfoForBattle()
    mBattle.attackerAweaponInfo = mAttackAweapon.formatUsedInfoForBattle()

    mBattle.rLv = 0

    if moduleIsEnabled('lf')==1 then
        mBattle.attackerLandform = getAttackerLandformOfBattle({mAttackUserinfo.mapx,mAttackUserinfo.mapy},target)
        mBattle.defenserLandform = targetType
    end
    
    -- 防守岛的兵力
    if targetType >= 1 and targetType <= 5 then
        mBattle.islandTroops = mMap:getDefenseFleet(mapId)
    end

    -- 金矿信息
    local goldMineMap = mMap:getGoldMine()
    if goldMineMap[tostring(mapId)] then
        mBattle.goldMineInfo = goldMineMap[tostring(mapId)]
    end

    -- 叛军信息
    local rebelInfo,rebelIsDie,mRebel = false
    if targetType == 7 then
        mRebel = loadModel("model.rebelforces")
        rebelInfo = mRebel.getRebelInfo(mapId)
        rebelIsDie = rebelInfo.isDie

        mBattle.rebelInfo = rebelInfo
        mBattle.mRebel = mRebel
    end

    -- 将领试炼
    local annealInfo, annealIsDie, mAnneal = false
    local annealUid = map.data.oid
    if targetType == 8 then
        mAnneal = loadModel("model.heroanneal", {uid=annealUid})
        annealInfo = mAnneal.getAnnealInfo(mapId)
        annealIsDie = annealInfo.isDie

        mBattle.annealInfo = annealInfo
        mBattle.mAnneal = mAnneal
    end

    ------------------------------------------------------------------------------------

    -- dist 到达时间
    -- sec 到达时间的差（秒）
    -- 如果加速，扣除消耗的宝石，需要排除时间已到，卡住的任务队列
    -- 如果系统调用时间差在5秒以外，不处理此次请求
    local dist = attFleetInfo.dist or 0
    local sec = dist - ts

    -- 使用宝石加速
    if  isUseGem == 1 and sec > 0 then
        local iGems = speedConsumeGems(sec)
        --活动检测
        iGems = activity_setopt(attacker,'speedupdisc',{speedtype="troop", gems=iGems},false,iGems)        
        if iGems > 0 then
            --日常任务
            --新的日常任务检测
            mAttackDailyTask.changeNewTaskNum('s402',1)
            if not mAttackUserinfo.useGem(iGems) then
                response.ret = -109
                response.msg = 'not enough gem'

                commonUnlock(mapId, "maplock")
                return response
            end
            regActionLogs(attacker,1,{action=6,item=mapId,value=iGems,params={islandType=targetType,islandOid=oid,troopsInfo=attFleetInfo,cronId=cronId}})
        end
    elseif not request.secret and sec >= 5 then
        commonUnlock(mapId, "maplock")
        return response
    end

    -- 抵达时间为当前
    attFleetInfo.dist = ts
    
    ------------------------------------------------------------------------------------
    if checkMapIsOccupyed() == true then
        oid = attacker
    end
    -- 如果攻打的是自己,此岛已被自己占领，舰队返回，并发邮件
    if oid == attacker then
        mAttackTroop.fleetBack(cronId)  

        processEventsBeforeSave()
        if auobjs.save() then
            processEventsAfterSave()
            setResponseData(request.secret,mAttackTroop,mAttackUserinfo,mAttackBag,mBattle)

            -- 邮件--------------------------
            local mail_title =  "3-"..targetType
            local mail_content={
                type=3,
                info = {
                    place = target,
                    name = mBattle.attackerName,
                    islandType = targetType,
                    level = maplevel,
                    rettype = 3
                }
            }      
            MAIL:mailSent(attacker,1,attacker,'',mBattle.attackerName,mail_title,mail_content,2,0)       

            response.ret = 0
            response.msg = 'Success'
        end
        commonUnlock(mapId, "maplock")
        return response

    end

    ------------------------------------------------------------------------------------
    local mapIsEmpty = false
    local mailRetType

    if attFleetInfo.type == 9 then
        -- 地图没有占有者
        if oid == 0 then
            mapIsEmpty = true
        -- 攻击者没有军团
        elseif mAttackUserinfo.alliance <= 0 then
            mapIsEmpty = true
        -- 领地不是自己的军团的
        elseif mAttackUserinfo.alliance ~= oid then
            mapIsEmpty = true
        else
            local mTerritory = getModelObjs("aterritory",mAttackUserinfo.alliance,true)
            if not mTerritory.isNormal() then
                mapIsEmpty = true
            elseif mTerritory.isLockCollectTime() then
                -- 在维护期内不让采集，
                mapIsEmpty = true
                mailRetType = 12
            elseif not auobjs.getModel('atmember').canCollect() then
                -- 是当日采集次数达到上限
                mapIsEmpty = true
                mailRetType = 13
            end
        end
    end
    
    -- 攻打空地，被攻击有可能已搬家
    if targetType == 0 or (targetType == 6 and attFleetInfo.tUid and attFleetInfo.tUid ~= oid) or (targetType == 7 and rebelIsDie) or (targetType==8 and annealIsDie) or (targetType ~= attFleetInfo.type) or mapIsEmpty then
        mAttackTroop.fleetBack(cronId)

        processEventsBeforeSave()
        if auobjs.save() then
            processEventsAfterSave()
            setResponseData(request.secret,mAttackTroop,mAttackUserinfo,mAttackBag,mBattle)

            local mail_title =  "3-"..targetType
            local mail_content={
                type = 3,
                info = {
                    place = target,
                    name  = '',
                    islandType = targetType,
                    level = maplevel,
                    rettype = 2,
                }
            }

            if attFleetInfo.rebelForce then
                mail_content.rebel = {
                        rebelID = attFleetInfo.rebelForce,
                        rebelLv = attFleetInfo.level,
                    }
            end

            if attFleetInfo.type == 8 then -- 将领试炼，变成空地了
                mail_content.info.islandType = attFleetInfo.type
            elseif attFleetInfo.type == 9 then
                mail_content.rettype= mailRetType or 10
            end

            MAIL:mailSent(attacker,1,attacker,'',mAttackUserinfo.nickname,mail_title,mail_content,2,0)

            response.ret = 0
            response.msg = 'Success'
        end

        commonUnlock(mapId, "maplock")
        return response

    end

    ------------------------------------------------------------------------------------

    -- 如果oid存在，初始化防守方的所有数据
    -- 如果不是协防，需要处理防守方的警报信息
    if oid > 0 and targetType ~= 9 then
        duobjs = getUserObjs(oid)
        duobjs.load({"userinfo", "techs", "troops", "props","bag","skills","buildings","dailytask","task"})
        mTargetUserinfo = duobjs.getModel('userinfo')
        mTargetTroop = duobjs.getModel('troops')
        local mTargetArmor = duobjs.getModel('armor')
        local mTargetAweapon = duobjs.getModel('alienweapon')

        mBattle.defenserName = mTargetUserinfo.nickname
        mBattle.defenserLevel = mTargetUserinfo.level
        mBattle.DAName = mTargetUserinfo.alliancename
        mBattle.defenserVip = mTargetUserinfo.showvip() 
        mBattle.defenserFc = mTargetUserinfo.fc
        mBattle.defenserPic = mTargetUserinfo.pic
        mBattle.defenseraPic = mTargetUserinfo.apic
        mBattle.defenserbPic = mTargetUserinfo.bpic
        mBattle.defenserArmorInfo = mTargetArmor.formatUsedInfoForBattle()
        mBattle.defenserAweaponInfo = mTargetAweapon.formatUsedInfoForBattle()

        if attFleetInfo.isHelp ~= 1 then                
            mTargetTroop.clearAlarm(cronId) -- 解除敌军来袭           
            mTargetUserinfo.flags.event.f = 1

            regEventAfterSave(oid,'e6',{})
        end
    end   

    ------------------------------------------------------------------------------------

    -- 协防
    if attFleetInfo.isHelp == 1 then  
        local mailRetType
        if mAttackUserinfo.alliance <= 0 or mTargetUserinfo.alliance <= 0 or mAttackUserinfo.alliance ~= mTargetUserinfo.alliance then
            mAttackTroop.fleetBack(cronId)
            mTargetTroop.clearHelpDefence(cronId)          
            mailRetType = 6  
        elseif mTargetTroop.getHelpDefenceNums() >= 5 then
            mAttackTroop.fleetBack(cronId)
            mTargetTroop.clearHelpDefence(cronId)
            mailRetType= 7
        else
            local ret,helpdefense = mBattle.helpTroopsArrive(attacker,mAttackUserinfo.nickname,attFleetInfo.troops,oid,cronId,mAttackTroop) 
        end

        processEventsBeforeSave()
        if auobjs.save() then
            setResponseData(request.secret,mAttackTroop,mAttackUserinfo,mAttackBag,mBattle)

            if mailRetType then
                local mail_title =  "3-"..targetType
                local mail_content={
                    type = 3,
                    info = {
                        place = target,
                        name  = '',
                        islandType = targetType,
                        level = maplevel,
                        rettype = mailRetType,
                    }
                }

                MAIL:mailSent(attacker,1,attacker,'',mAttackUserinfo.nickname,mail_title,mail_content,2,0)
            end

            if not duobjs then
                processEventsAfterSave()                
            elseif duobjs.save() then
                mTargetTroop.sendHelpDefenseMsgByUid() 
                processEventsAfterSave()   
            end

            response.ret = 0
            response.msg = 'Success'
        end

        commonUnlock(mapId, "maplock")
        return response
    end
    
    ------------------------------------------------------------------------------------

    -- 同盟不能互相攻击
    if oid > 0 and type(mTargetUserinfo) == 'table' and (mTargetUserinfo.alliance > 0 or mAttackUserinfo.alliance > 0) and mAttackUserinfo.alliance == mTargetUserinfo.alliance then
        mAttackTroop.fleetBack(cronId)         
        processEventsBeforeSave()

        if auobjs.save() then
            processEventsAfterSave()
            setResponseData(request.secret,mAttackTroop,mAttackUserinfo,mAttackBag,mBattle)

            local mail_title =  "3-"..targetType
            local mail_content={
                type=3,
                info = {
                    place = target,
                    name = mTargetUserinfo.nickname,
                    islandType = targetType,
                    level = maplevel,
                    AAName = mAttackUserinfo.alliancename,
                    DAName = mTargetUserinfo.alliancename,
                    rettype = targetType == 6 and 5 or 4
                }
            }
            MAIL:mailSent(attacker,1,attacker,'',mBattle.attackerName,mail_title,mail_content,2,0)    

            response.ret = 0
            response.msg = 'Success'
        end

        commonUnlock(mapId, "maplock")
        return response

    end

    ------------------------------------------------------------------------------------

    -- 攻打玩家
    if targetType == 6 then
        -- 打飞标识, 需要飞离的领地坐标
        local blowFlyFlag, territoryPos = false

        -- 如果开关打开了,并且攻击者已经报名领海战
        -- 需要检测被攻击的目标是否能被击飞
        if switchIsEnabled('baseFly') and getModelObjs("aterritory",mAttackUserinfo.alliance,true).checkApplyOfWar() then
            blowFlyFlag,territoryPos = loadModel("lib.seawar").checkBaseFly(target[1],target[2],mTargetUserinfo.alliance,mTargetUserinfo.level)
        end

        -- 保护时间内不能攻打 -----------------------------------
        local protectTime = tonumber(map.protect) or 0
        local mTargetProp = duobjs.getModel('props')
        if protectTime > ts or tonumber(mTargetUserinfo.protect) > ts or mTargetProp.pidIsInUse("p14") then
            local rettype = 1
            
            if blowFlyFlag then
                -- 参加海域战争的军团玩家，身处参赛海域范围内时，保护罩失效
                if blowFlyFlag == 1 then
                    rettype = 0
                elseif blowFlyFlag == 2 then
                    -- 未报名，但有保护罩，无损击飞
                    if baseFly(78,mTargetUserinfo,territoryPos,map.alliancelogo,mBattle.attackerName) then
                        rettype = 24
                    end
                end
            end

            if rettype > 0 then
                mAttackTroop.fleetBack(cronId)
                processEventsBeforeSave()

                if auobjs.save() then
                    processEventsAfterSave()
                    setResponseData(request.secret,mAttackTroop,mAttackUserinfo,mAttackBag,mBattle)

                    local mail_title =  "3-"..targetType
                    local mail_content={
                        type=3,
                        info={
                            place = target,
                            name  = mTargetUserinfo.nickname,
                            islandType = targetType,
                            level = maplevel,
                            AAName = mAttackUserinfo.alliancename,
                            DAName = mTargetUserinfo.alliancename,
                            rettype = rettype,
                        }
                    }

                    MAIL:mailSent(attacker,1,attacker,'',mAttackUserinfo.nickname,mail_title,mail_content,2,0)

                    if duobjs then duobjs.save() end

                    response.ret = 0
                    response.msg = 'Success'
                end

                commonUnlock(mapId, "maplock")
                return response
            end
        end

        --  -----------------------------------
        regActionLogs(attacker,2,{action=1,item=oid,value=isWin,params={islandType=targetType,cronId=cronId}})

        local hCid,hDefense = mTargetTroop.getHelpDefenceTroops()            
        local isBattleHelpDefense,hFleet = false            
        local hMtroops,hMuserinfo  

        -- 奔赴前线,攻打主基地
        activity_setopt(attacker,'benfuqianxian',{tasks={t1=1}})
        -- 中秋赏月活动埋点
        activity_setopt(attacker, 'midautumn', {action='pp'})
        -- 国庆活动埋点
        activity_setopt(attacker, 'nationalDay', {action='pp'})
        -- 开年大吉埋点
        activity_setopt(attacker, 'openyear', {action='pp'})
        -- 春节攀升
        activity_setopt(attacker, 'chunjiepansheng', {action='pp'})

        -- 中秋赏月活动埋点
        activity_setopt(attacker,'halloween',{sw=1})

        -- 攻打玩家最多的玩家 每日捷报
        setNewsUidRankingScore(attacker,"d11")

        -- 悬赏任务
        activity_setopt(attacker,'xuanshangtask',{t='',e='pp',n=1})        
        --点亮铁塔
        activity_setopt(attacker,'lighttower',{act='pp',num=1}) 
        --德国七日狂欢 
        activity_setopt(attacker,'sevendays',{act='sd19',v=0,n=1})
        -- 跨年福袋
        activity_setopt(attacker,'luckybag',{act=2,n=1})   

        --岁末回馈
        activity_setopt(attacker,'feedback',{act='pp',num=1})
        -- 合服大战
        activity_setopt(attacker,'hfdz',{act='pp',num=1})
        -- 愚人节大作战-世界地图其他玩家-攻打X次
        activity_setopt(attacker,'foolday2018',{act='task',tp='pp',num=1})
        --海域航线
        activity_setopt(attacker,'hyhx',{act='tk',type='pp',num=1})
        -- 番茄大作战
        activity_setopt(attacker,'fqdzz',{act='tk',type='pp',num=1}) 
        -- 国庆七天乐
        activity_setopt(attacker,'nationalday2018',{act='tk',type='pp',num=1})
         
         if mAttackUserinfo.alliance>0 then
            local mAtmember = auobjs.getModel('atmember')
            mAtmember.uptask({act=5,num=1,aid=mAttackUserinfo.alliance})
         end

        if hCid and hDefense then
            huobjs = getUserObjs(hDefense.uid)
            hMtroops = huobjs.getModel('troops')
            hMuserinfo = huobjs.getModel('userinfo')                

            if hDefense.uid ~= attacker then
                hFleet = hMtroops.getFleetTroopsByCron(hCid)
            end

            local totalDefendTanks = 0
            if type(hFleet) == 'table' then
                for k,v in pairs(hFleet) do
                    if type(v)=='table' and next(v) then
                        totalDefendTanks = totalDefendTanks + v[2]
                    end
                end
            end

            if totalDefendTanks > 0 then
                isBattleHelpDefense = true   
            else
                hMtroops.clearHelpDefence(hCid)
            end
        end   
                
        -- 协防部队战斗
        if isBattleHelpDefense then                                
            local isWin,lostShip,aSurviveTroops,report,dSurviveTroops,tankinfo= mBattle.battlePlayerByHelpDefence(attacker,attFleetInfo.troops,hDefense.uid,cronId,hFleet,hCid)

            mBattle.updateBattleFleetTroops(hDefense.uid,hCid,dSurviveTroops)
            local award,resource,setrank,rep

            -- 战斗胜利，奖励 ，防守方先出手，若防守方失败，则表示此次攻打胜利
            if isWin then
                mBattle.isVictory = 1
                mTargetTroop.clearHelpDefence(hCid)

                -- 荣誉
                mBattle.battleReputation = mBattle.getBattleReputation(mAttackUserinfo.reputation,hMuserinfo.reputation)

                rep = {reputation=mBattle.battleReputation}
                if mBattle.battleReputation > 0 then  
                    mAttackUserinfo.addResource(rep)
                    hMuserinfo.useResource(rep)
                    setrank = true
                end

                resource = mBattle.pillageResource(attacker,oid,aSurviveTroops)
                mBattle.back(cronId,attacker,aSurviveTroops,resource)

                if mAttackUserinfo.alliance>0 then
                    local mAtmember = auobjs.getModel('atmember')
                    mAtmember.uptask({act=5,num=1,aid=mAttackUserinfo.alliance})
                end

                -- 强制搬家
                if blowFlyFlag and territoryPos then
                    local mailType = blowFlyFlag==1 and 76 or 77
                    baseFly(mailType,mTargetUserinfo,territoryPos,map.alliancelogo,mBattle.attackerName)
                end
            else
                mBattle.isVictory = 0

                -- 荣誉
                mBattle.battleReputation = mBattle.getBattleReputation(hMuserinfo.reputation,mAttackUserinfo.reputation)

                rep = {reputation=mBattle.battleReputation}
                if mBattle.battleReputation > 0 then
                    mAttackUserinfo.useResource(rep)
                    hMuserinfo.addResource(rep)
                    setrank = true
                end

                mBattle.loseBack(cronId,attacker,aSurviveTroops)
            end
 
            if setrank then
                setHonorsRanking(attacker,mAttackUserinfo.reputation)
                setHonorsRanking(oid,mTargetUserinfo.reputation)
            end

            if mTargetUserinfo.alliance > 0 then      
                local tmpRes = isWin and mBattle.pillageRes or -1              
                regEventAfterSave(oid,'e5',{defener=mTargetUserinfo.nickname,attacker=mAttackUserinfo.nickname,resource=tmpRes,allianceName=mAttackUserinfo.alliancename})
            end

            mAttackTask.check()

            if not isUseGem then
                if checkEvent('task') or checkEvent('dailytask') then
                    regSendMsg(attacker,"msg.task")
                end
            end

            -- actionlog 玩家协防的部队被攻击
            regActionLogs(hDefense.uid,2,{action=12,item=attacker,value=isWin,params={islandType=targetType,cronId=cronId}})

            processEventsBeforeSave()
            if auobjs.save() then
                setResponseData(request.secret,mAttackTroop,mAttackUserinfo,mAttackBag,mBattle)
                mBattle.sendReport(attacker,mBattle.attackerName,report,award,resource,lostShip,tankinfo)

                if huobjs and huobjs.save() then                        
                    mBattle.sendReport(hMuserinfo.uid,hMuserinfo.nickname,report,award,resource,lostShip,tankinfo)
                    local response = {data={event=1},cmd="msg.event"}
                    sendMsgByUid(hDefense.uid,json.encode(response))
                end

                if duobjs and duobjs.save() then
                    mBattle.sendReport(oid,mBattle.defenserName,report,award,resource,lostShip,tankinfo)
                    local response = {data={event=1},cmd="msg.event"}
                    sendMsgByUid(oid,json.encode(response))
                end

                processEventsAfterSave()

                response.ret = 0
                response.msg = 'Success'
            end
        
            commonUnlock(mapId, "maplock")
            return response
        end
        
        ------------------------------------------------------------------------------------

        local isWin =  mBattle.battlePlayer(attacker,attFleetInfo.troops,oid,cronId) == 1  

        if mTargetUserinfo.alliance > 0 then               
            local tmpRes = isWin and mBattle.pillageRes or -1
            regEventAfterSave(oid,'e5',{defener=mTargetUserinfo.nickname,attacker=mAttackUserinfo.nickname,resource=tmpRes,allianceName=mAttackUserinfo.alliancename})
        end   

        if isWin then     
            mAttackTask.attackTaskCheck(2,mTargetUserinfo.level)

            --新的日常任务检测
            mAttackDailyTask.changeNewTaskNum('s202',1)                    
            mAttackDailyTask.changeTaskNum(6)

            -- 强制搬家
            if blowFlyFlag and territoryPos then
                local mailType = blowFlyFlag==1 and 76 or 77
                baseFly(mailType,mTargetUserinfo,territoryPos,map.alliancelogo,mBattle.attackerName)
            end
        end

        if mBattle.battleReputation > 0 then
            local rep = {reputation=mBattle.battleReputation}
            if isWin then
                mAttackUserinfo.addResource(rep)
                mTargetUserinfo.useResource(rep)
            else
                mAttackUserinfo.useResource(rep)
                mTargetUserinfo.addResource(rep)
            end
            setHonorsRanking(attacker,mAttackUserinfo.reputation)
            setHonorsRanking(oid,mTargetUserinfo.reputation)
        end

        -- actionlog 玩家主基地被攻击
        regActionLogs(oid,2,{action=10,item=attacker,value=isWin,params={islandType=targetType,cronId=cronId}})

        ------------------------------------------------------------------------------------

    -- 攻击叛军
    elseif targetType == 7 then
        mBattle.defenserLandform = getLandformByPos(target[1],target[2])
        mBattle.defenserName = tostring(rebelInfo.level) .. "," .. tostring(rebelInfo.force)

        local killFlag,leftHp = mBattle.battleRebelForces(attacker,attFleetInfo,mapId,cronId)

        -- 通知军团增加一条发现记录
        M_alliance.setforces{
            ts=rebelInfo.expireTs,
            id=mapId,
            aid=mAttackUserinfo.alliance,
            uid=attacker,
            lvl=rebelInfo.level,
            rfname=rebelInfo.force,
            date = getWeeTs(),
        }

        -- 未被击杀时,需要将战斗的相关信息返给前端
        if killFlag ~= 2 then
            local rebelForClient = {
                mid = mapId,
                place  = target,
                level=rebelInfo.level,
                rebelLeftLife = leftHp,
                rebelID=rebelInfo.force,
            }

            -- 如果是系统执行,并且未被击杀的情况,需要给前端同步一下本次伤害信息
            if request.secret then
                regSendMsg(attacker,"push.cron.attack",{rebelInfo=rebelForClient})
            else
                response.data.rebelInfo = rebelForClient
            end
        end

        -- 每日任务,攻打叛军
        mAttackDailyTask.changeTaskNum1("s1015")

        -- 被击杀
        if killFlag == 1 then
            -- 增加击杀经验
            mRebel.addKillExp(rebelInfo.expireTs)
            local killReward = mRebel.getKillReward(rebelInfo.level,rebelInfo.force)
            M_alliance.killforces(mAttackUserinfo.alliance,mapId,rebelInfo.expireTs,rebelInfo.level,mAttackUserinfo.nickname,killReward,rebelInfo.force,attacker,mAttackUserinfo.alliancename,target[1],target[2])
 
            -- 击杀叛军最多的军团 每日捷报
            setNewsUidRankingScore(mAttackUserinfo.alliance,"d13")
           
            --军团击杀海盗
            -- if mAttackUserinfo.alliance>0 then
            --     local mAtmember = auobjs.getModel('atmember')
            --     if mAtmember.upKill(1) then
            --         local mAterritory = getModelObjs("aterritory",mAttackUserinfo.alliance,false,true)
            --         if mAterritory then
            --             if mAterritory.upKill(1) then
            --                 regEventAfterSave(attacker,'e10',{aid=mAttackUserinfo.alliance})
            --             end
            --         end                    
            --     end
                
            -- end

        -- 已被别人击杀,直接发一个返航报告
        elseif killFlag == 2 then
            mAttackTroop.fleetBack(cronId)
            processEventsBeforeSave()

            if auobjs.save() then
                processEventsAfterSave()
                setResponseData(request.secret,mAttackTroop,mAttackUserinfo,mAttackBag,mBattle)

                local mail_title =  "3-"..targetType
                local mail_content={
                    type = 3,
                    info = {
                        place = target,
                        name  = '',
                        islandType = targetType,
                        level = maplevel,
                        rettype = 2,
                    },
                    rebel = {
                        rebelID = attFleetInfo.rebelForce,
                        rebelLv = attFleetInfo.level,
                    }
                }

                MAIL:mailSent(attacker,1,attacker,'',mAttackUserinfo.nickname,mail_title,mail_content,2,0)

                response.ret = 0
                response.msg = 'Success'
            end

            return response
        end

    --试炼任务
    elseif targetType == 8 then
        mBattle.defenserLandform = getLandformByPos(target[1],target[2])
        mBattle.defenserName = tostring(annealInfo.level) .. "," .. tostring(annealUid)        
        local killFlag,leftHp,dmgTotalHp = mBattle.battleAnneal(attacker,attFleetInfo,mapId,cronId, annealUid)

        -- 已被别人击杀,直接发一个返航报告
        if killFlag == 2 then
            mAttackTroop.fleetBack(cronId)
            processEventsBeforeSave()

            if auobjs.save() then
                processEventsAfterSave()
                setResponseData(request.secret,mAttackTroop,mAttackUserinfo,mAttackBag,mBattle)

                local mail_title =  "3-"..targetType
                local mail_content={
                    type = 3,
                    info = {
                        place = target,
                        name  = '',
                        islandType = targetType,
                        level = maplevel,
                        rettype = 2,
                    },
                }

                MAIL:mailSent(attacker,1,attacker,'',mAttackUserinfo.nickname,mail_title,mail_content,2,0)

                response.ret = 0
                response.msg = 'Success'
            end

            return response
        end

        anobjs = getUserObjs(tonumber(annealUid)) 
        local anHero = anobjs.getModel("hero")
        anHero.updateAnnealTask(killFlag, leftHp) --更新任务信息

        if attacker ~= annealUid then
            anHero.updateAnnealLog(mAttackUserinfo.nickname, dmgTotalHp/tonumber(map.data.maxHp), killFlag) -- 记录帮助信息
        end

        local annealForClient = {
            mid = mapId,
            place  = target,
            level=annealInfo.level,
            annealLeftLife = leftHp,
        }

        -- 世界地图推送当前血量
        regSendMsg(attacker,'map.change', {anneal = annealForClient})

    -- 领地采矿
    elseif targetType == 9 then
        attFleetInfo.AcRate=nil
        local allianceCityCfg = getConfig("allianceCity")
        local capacity = mBattle.getFleetCapacity(attacker,attFleetInfo.troops)
        local mTerritory = getModelObjs("aterritory",mAttackUserinfo.alliance,true)
        local resourceName = mTerritory.getResourceNameByBid(attFleetInfo.mType)

        attFleetInfo.speed = mTerritory.getResourceProduceSpeed(attFleetInfo.mType)
        attFleetInfo.ges =  ts+allianceCityCfg.collectTime
        attFleetInfo.isGather = 2
        attFleetInfo.gts = ts
        attFleetInfo.gts1 = ts
        attFleetInfo.res = {[resourceName]=0}
        attFleetInfo.maxRes = {[resourceName]=capacity}

        -- 设置自动返回定时
        mAttackTroop.setGoldMineBackCron(attFleetInfo.ges,cronId)

        if mAttackUserinfo.alliance>0 then
             local mAtmember = auobjs.getModel('atmember')
            mAtmember.addCollectNum(1)--增加次数
        end

    -- 攻击矿点
    else
        local isWin = false
        if mAttackTroop.attack[cronId].level~=maplevel then
            mAttackTroop.attack[cronId].level=maplevel
        end

        local olvl=nil
        if omaplevel~=maplevel then
            olvl=omaplevel
        end
        -- 资源点被占领 
        if oid > 0 then
            mBattle.islandOwner = oid
            isWin = mBattle.robNpcToPlayer(cronId,mapId,attacker,attFleetInfo.troops,oid,attFleetInfo.isGather,olvl) == 1 

            if mBattle.battleReputation > 0 then
                local rep = {reputation=mBattle.battleReputation}
                if isWin then
                    mAttackUserinfo.addResource(rep)
                    mTargetUserinfo.useResource(rep)
                else
                    mAttackUserinfo.useResource(rep)
                    mTargetUserinfo.addResource(rep)
                end
                setHonorsRanking(attacker,mAttackUserinfo.reputation)
                setHonorsRanking(oid,mTargetUserinfo.reputation)
            end
            regActionLogs(attacker,2,{action=2,item=oid,value=isWin,params={islandType=targetType,cronId=cronId}})
            regActionLogs(oid,2,{action=11,item=attacker,value=isWin,params={islandType=targetType,cronId=cronId}})
        else
           
            isWin = mBattle.battleNpc(attacker,attFleetInfo.troops,mapId,cronId,attFleetInfo.isGather,olvl) == 1 
            regActionLogs(attacker,2,{action=3,item=oid,value=isWin,params={islandType=targetType,cronId=cronId}})
        end

        if isWin then
            mAttackTask.attackTaskCheck(1,maplevel)
             --新的日常任务检测
            mAttackDailyTask.changeNewTaskNum('s205',1) 
            mAttackDailyTask.changeNewUrgencyTaskNum('s1',maplevel)  
        end
        mAttackDailyTask.changeTaskNum(4)

        -- 奔赴前线,攻打野外矿点
        activity_setopt(attacker,'benfuqianxian',{tasks={t2=1}})
        -- 中秋赏月活动埋点
        activity_setopt(attacker, 'midautumn', {action='pe'})
        -- 国庆活动埋点
        activity_setopt(attacker, 'nationalDay', {action='pe'})
        -- 春节攀升
        activity_setopt(attacker, 'chunjiepansheng', {action='pe'})
        -- 陨石冶炼
        activity_setopt(attacker, 'yunshiyelian', {action='pe'})
        -- 猎杀潜航
        activity_setopt(attacker,'silentHunter',{action='ps',num=1,troops=attFleetInfo.troops})
        -- 点亮铁塔
        activity_setopt(attacker,'lighttower',{act='pe',num=1}) 
        -- 岁末回馈
        activity_setopt(attacker,'feedback',{act='pe',num=1})
        
        if mBattle.resetAttackerProtectFlag then
            resetAttackerProtect()
        end
        -- 攻打矿点最多的玩家 每日捷报
        setNewsUidRankingScore(attacker,"d12")
        -- 悬赏任务
        activity_setopt(attacker,'xuanshangtask',{t='',e='pe',n=1})
        -- 德国七日狂欢
        activity_setopt(attacker,'sevendays',{act='sd16',v=0,n=1})
        -- 愚人节大作战-攻打X次世界资源点
        activity_setopt(attacker,'foolday2018',{act='task',tp='pe',num=1})

        --海域航线
        activity_setopt(attacker,'hyhx',{act='tk',type='pe',num=1})
        -- 国庆七天乐
        activity_setopt(attacker,'nationalday2018',{act='tk',type='pe',num=1})
    end
        
    mAttackTask.check()

    if not isUseGem then
        if checkEvent('task') or checkEvent('dailytask') then
            regSendMsg(attacker,"msg.task")
        end
    end

    ------------------------------------------------------------------------------------
    processEventsBeforeSave()

    if auobjs.save() then
        setResponseData(request.secret,mAttackTroop,mAttackUserinfo,mAttackBag,mBattle)
        processEventsAfterSave()    

        if duobjs  then
            duobjs.save()
        end

        if huobjs then
            huobjs.save()
        end

        if anobjs then
            anobjs.save()
        end
        
        response.ret = 0
        response.msg = 'Success'
    end
    
    commonUnlock(mapId, "maplock")
    return response
end
