function model_battle()
    local self = {        
        attacker = 0,
        attackerName = '',
        attackerLevel = 0,
        defenser = 0,
        defenserName = '',
        defenserLevel = 0,
        islandType = 0,
        islandOwner = 0,
        islandLevel = 0,
        place = {},
        isVictory=0,
        AttackerPlace={},
        islandTroops={},
        mMap = {},
        battleReputation = 0,
        receiveProps = false,
        AAName = '',
        DAName = '',
        pillageRes = 0, -- 掠夺的资源总量
        helpDefender=nil,
        aAey = {},  -- 攻击者的配件信息
        dAey = {},  -- 防守者的配件信息
        aHeroPoint = 0, -- 攻击者英雄强度
        dHeroPoint = 0, -- 防守者英雄强度
        aHeroInfo = {}, -- 攻击方英雄信息
        dHeroInfo = {}, -- 防守方英雄信息
        attackerLandform = 1,   -- 攻击者地形
        defenserLandform = 1,   -- 防守方地形
        acaward = nil,
        resetAttackerProtectFlag = nil, -- 重置攻击方保护罩标志
        arp = 0,    -- 攻击方获得的军功值
        drp = 0,    -- 防守方获得的军功值
        rLv = 0,    -- 富矿等级
        defboom = 0,   -- 防守方繁荣度
        aEquip = 0, -- 攻击方超级装备
        dEquip = 0, -- 防守方超级装备
        goldMineInfo=nil, -- 金矿信息
        robGoldMineGems = nil, -- 抢夺的金矿金币
        robLeftGoleMineGems = nil, -- 抢夺后剩余的金币 
        robAlienRes = nil, -- 抢夺的异星资源
        rebelInfo = nil, -- 叛军信息
        annealInfo = nil, --将领试炼
        battleground = 0, -- 战场 1是主基地，2是世界野矿
        aPlane={}, -- 攻击方飞机信息
        dPlane={}, -- 防守方飞机信息
    }

    -- 攻打据点，采集资源
    function self.gather(cronId,uid,troops,robRes,mapId,robGoldMineGems,oldlvl)
        local uobjs = getUserObjs(uid)
        local mTroop = uobjs.getModel('troops')

        if type (mTroop.attack[cronId]) == 'table' then 
            local ts = getClientTs()
            mTroop.attack[cronId].troops = troops 

    	    if mTroop.attack[cronId].mid then
                -- 如果是异星矿场，兼容代码，这里预设热度等级是0
                if mTroop.attack[cronId].alienMine == 1 then
                    mTroop.attack[cronId].heatLv = 0
                else
                    mTroop.attack[cronId].heatLv = self.mMap:getHeatLevel(mTroop.attack[cronId].mid)
                end

                self.rLv = mTroop.attack[cronId].heatLv
    	    end

            if self.goldMineInfo then
                mTroop.attack[cronId].goldMine=self.goldMineInfo
                mTroop.setGoldMineBackCron(self.goldMineInfo[2]+10,cronId)
            end

            local res,gtime,vate = self.gatherInfo(uid,mTroop.attack[cronId], cronId)
            
            --驱鬼活动时间减少倍率
            if vate then
               mTroop.attack[cronId].vate=vate
            end

            mTroop.attack[cronId].isGather = 2
            mTroop.attack[cronId].gts = ts
            mTroop.attack[cronId].wkts = 0 -- workTs 已采集的时间
            mTroop.attack[cronId].res = robRes or {[(next(res))]=0}
            mTroop.attack[cronId].maxRes = res
            mTroop.attack[cronId].ges =  ts + gtime
            mTroop.attack[cronId].olvl = oldlvl
            -- 抢到的金矿金币
            if robGoldMineGems then
                mTroop.attack[cronId].gems = robGoldMineGems
            end

            -- 金矿的采集的初始时间
            if mTroop.attack[cronId].goldMine and not mTroop.attack[cronId].gts1 then
                mTroop.attack[cronId].gts1 = ts
            end
        end
    end

    -- 被攻击后刷新资源采集信息
    function self.updateGather(uid,mid,troops)
        local uobjs = getUserObjs(uid)
        local mTroop = uobjs.getModel('troops')
        local _ , cronId = mTroop.getGatherFleetByMid(mid)

        if type(mTroop.attack[cronId]) == 'table' then
            mTroop.attack[cronId].troops = troops 
            local res,gtime,vate = self.gatherInfo(uid,mTroop.attack[cronId], cronId)
            --驱鬼活动时间减少倍率
            if vate then
                mTroop.attack[cronId].vate=vate
            end
            mTroop.attack[cronId].maxRes = res 
            mTroop.attack[cronId].ges =  mTroop.attack[cronId].gts + gtime - (mTroop.attack[cronId].wkts or 0)
        else
            tankError('updateGather not found cronId By mid:'.. mid)
        end
    end

    -- 被攻击后刷新异星矿山资源采集信息
    function self.updateAlienmineTroopGather(uid,mid,troops)
        local uobjs = getUserObjs(uid)
        local mTroop = uobjs.getModel('troops')
        local _ , cronId = mTroop.getGatherFleetByAlienMineMid(mid)

        if type(mTroop.attack[cronId]) == 'table' then
            mTroop.attack[cronId].troops = troops 
            local res,gtime,vate = self.gatherInfo(uid,mTroop.attack[cronId], cronId)
            --驱鬼活动时间减少倍率
            if vate then
                mTroop.attack[cronId].vate=vate
            end
            mTroop.attack[cronId].maxRes = res 
            mTroop.attack[cronId].ges =  mTroop.attack[cronId].gts + gtime - (mTroop.attack[cronId].wkts or 0)
        else
            tankError('updateAlienmineTroopGather not found cronId By mid:'.. mid)
        end
    end

    -- 攻打据点后返回
    function self.back(cronId,uid,troops,robRes,robGoldMineGems)
        local uobjs = getUserObjs(uid)
        local mTroop = uobjs.getModel('troops')
        if type (mTroop.attack[cronId]) == 'table' then 
            mTroop.attack[cronId].troops = troops
            mTroop.attack[cronId].res = robRes 
            mTroop.attack[cronId].gems = robGoldMineGems
            mTroop.fleetBack(cronId)
        end
    end

    -----主动出击，战败而回 
    function self.loseBack(cronId,uid,troops)
        if type(troops) == 'table' then
            local pairs = pairs
            for _,v in pairs(troops) do
                if v[2] and v[2] > 0 then
                    self.back(cronId,uid,troops)
                    return
                end
            end
        end

        local uobjs = getUserObjs(uid)
        local mTroop = uobjs.getModel('troops')
        if type(arrayGet(mTroop.attack,cronId)) == 'table' then
            mTroop.setCleanAttackByCid(cronId)
        end
    end

    -- 资源岛被人抢了,坦克肯定没了
    function self.loseExpel(uid,mid,troops)
        local uobjs = getUserObjs(uid)
        local mTroop = uobjs.getModel('troops')

        local _ , cronId = mTroop.getGatherFleetByMid(mid)

        if type(arrayGet(mTroop.attack,cronId)) == 'table' then
            mTroop.setCleanAttackByCid(cronId)
        end

        if self.robLeftGoleMineGems and self.robLeftGoleMineGems > 0 then
            local mUserinfo = uobjs.getModel('userinfo')
            mUserinfo.addGoldMineGems(self.robLeftGoleMineGems)
        end
    end

    -- 更新战斗舰队的兵员
    function self.updateBattleFleetTroops(uid,cronId,troops)
        local uobjs = getUserObjs(uid)
        local mTroop = uobjs.getModel('troops')
        if type(arrayGet(mTroop.attack,cronId)) == 'table' then
            if type(troops) == 'table' then
                local pairs = pairs
                for _,v in pairs(troops) do
                    if v[2] and v[2] > 0 then
                        mTroop.attack[cronId].troops = troops
                        return
                    end
                end
            end

            mTroop.setCleanAttackByCid(cronId)
        end
    end

    ------------------------ 攻打玩家    
    -- attUid ,攻击方uid
    -- fleetInfo ,攻击方舰队
    -- defenser ,防守方id
    -- 攻打玩家时，防守方先出手
    function self.battlePlayer(attUid,fleetInfo,defenser,cronId)
        -- 初始化防守方
        local duobjs = getUserObjs(defenser)
        local dUserinfo = duobjs.getModel('userinfo')        
        local auobjs = getUserObjs(attUid)
        local aHero = auobjs.getModel('hero')
        local aEquip = auobjs.getModel('sequip')
        local aUserinfo = auobjs.getModel('userinfo')  
        local aHeros =aHero.getAttackHeros('a',cronId)
        local aEquipid = aEquip.getEquipFleet('a',cronId)
        local aPlane = auobjs.getModel('plane')
        local aPlaneid = aPlane.getPlaneFleet('a',cronId)
        local aBadge = auobjs.getModel('badge')
        local aBadgeVal = aBadge.formBadge()

        local defackFleet = duobjs.getModel('troops')
        local dFleetInfo = defackFleet.getDefenseFleet()
        local dmHero       = duobjs.getModel('hero')
        local dHeros = dmHero.getAttackHeros('d',1)
        local dEquip = duobjs.getModel('sequip')
        local dEquipid = dEquip.getEquipFleet('d',1)    
        local dPlane = duobjs.getModel('plane')
        local dPlaneid = dPlane.getPlaneFleet('d',1) 
        local dBadge = duobjs.getModel('badge')
        local dBadgeVal = dBadge.formBadge()   


        local totalDefendTanks = 0
        local dtankinfo={}
        if type(dFleetInfo) == 'table' then
            for k,v in pairs(dFleetInfo) do
                if type(v)=='table' and next(v) then
                    totalDefendTanks = totalDefendTanks + v[2]
                    dtankinfo[v[1]]  =(dtankinfo[v[1]] or 0) +v[2]
                    if v[2]<=0 then
                        if type(dHeros)=='table' then
                            if dHeros[k]~=nil and dHeros[k]~=0 then
                                dHeros[k]=0
                            end
                        end
                    end
                end
            end
        end
        local loseRate = 0 --敌舰价值损失比例
        local addRate = aEquip.dySkillAttr(aEquipid, 's1', 0)  --繁荣掠夺 战胜后额外减少繁荣度

        --触发 战争之路活动
        activity_setopt(attUid,'battleRoad',{c=1})
	
        -- 本次双方损失的坦克数量
        local lostShip = {
            attacker  = {},
            defenser = {},
        }

        local award,resource
        self.resetAttackerProtectFlag = true
        self.reputation = 0
        
        -- 初始化防守方
        local defFleetInfo,dAccessory,dherosInfo,dplanevalue = defackFleet.initFleetAttribute(dFleetInfo,3,{landform=self.defenserLandform,hero=dHeros,equip=dEquipid,place=self.place,plane=dPlaneid})
        
        --  初始化攻击方          
        local attackFleet = auobjs.getModel('troops')
        local aFleetInfo,aAccessory,aherosInfo,aplanevalue = attackFleet.initFleetAttribute(fleetInfo,0,{landform=self.attackerLandform,hero=aHeros,equip=aEquipid,place=self.place,plane=aPlaneid})

        -- 双方装备对比
        self.dAey = dAccessory
        self.aAey = aAccessory

        self.dEquip =dEquip.formEquip(dEquipid)
        self.aEquip =aEquip.formEquip(aEquipid)
        self.aPlane = aplanevalue
        self.dPlane = dplanevalue

        -- 主基地战场
        self.battleground = 1

        local atankinfo={}
        for k,v in pairs(fleetInfo) do
            if type(v)=='table' and next(v) then
                atankinfo[v[1]]  =(atankinfo[v[1]] or 0) +v[2]
            end
        end
        local tankinfo={a=atankinfo,d=dtankinfo}
        
        -- 英雄强度
        self.aHeroPoint = aherosInfo[2]
        self.dHeroPoint = dherosInfo[2]
        self.aHeroInfo = aherosInfo[1]
        self.dHeroInfo = dherosInfo[1]

        -- 指挥官徽章
        self.abadge = aBadgeVal
        self.dbadge = dBadgeVal

        -- 无防守舰队，直接胜利
        if totalDefendTanks < 1 then
            self.isVictory = 1
            -- 荣誉
            self.battleReputation = self.getBattleReputation(aUserinfo.reputation,dUserinfo.reputation)
            
            -- 周年庆活动
            award = nil
            award = activity_setopt(attUid, "anniversary", {action="player", reward=award, battle=self}, 0, award)

            -- 粽子作战
             local zongzi=activity_setopt(attUid, 'zongzizuozhan', {u=attUid,e='c',num=1})
             if type(zongzi)=='table' and next(zongzi) then
                if type(self.acaward)~='table' then
                    self.acaward={}
                end
                
                for k,v in pairs(zongzi) do
                    self.acaward[k]=v
                end 
             end

             -- 啤酒节  *奖励加在self.acaward中 就可以在邮件中展示了*
             local beerreward = activity_setopt(attUid,'beerfestival',{act='Rate4',num=1})
             if type(beerreward)=='table' and next(beerreward) then
                if type(self.acaward)~='table' then
                    self.acaward={}
                end
                
                for k,v in pairs(beerreward) do
                    self.acaward['beerfestival_'..k]=v
                end                 
             end
            -- 二周年
            local anniversary2 = activity_setopt(attUid,'anniversary2',{act='pl'})
            if type(anniversary2)=='table' and next(anniversary2) then
                if type(self.acaward)~='table' then
                    self.acaward={}
                end
                
                for k,v in pairs(anniversary2) do
                    self.acaward[k]= (self.acaward[k] or 0) + v
                end
             end

            -- 万圣节狂欢
            local wsjkh = activity_setopt(attUid,'wsjkh',{act=2,num=1,w=1})  
            if type(wsjkh)=='table' and next(wsjkh) then
                if type(self.acaward)~='table' then
                    self.acaward={}
                end
                
                for k,v in pairs(wsjkh) do
                    self.acaward[k]= (self.acaward[k] or 0) + v
                end
             end
            
            -- 感恩节2017
            local thanksgiving = activity_setopt(attUid,'thanksgiving',{act=2,num=1,w=1})  
            if type(thanksgiving)=='table' and next(thanksgiving) then
                if type(self.acaward)~='table' then
                    self.acaward={}
                end
                
                for k,v in pairs(thanksgiving) do
                    self.acaward[k]= (self.acaward[k] or 0) + v
                end
            end

            -- 装扮圣诞节
            self.setActReward({uid=attUid,act=2,aname='dresstree',num=1,w=1})
            
            -- 圣帕特里克
            self.setActReward({uid=attUid,act=2,aname='dresshat',num=1,w=1})

             -- 国庆七天乐
            activity_setopt(attUid,'nationalday2018',{act='tk',type='fc',p=aPlaneid,num=1})

            -- 感恩节拼图
            activity_setopt(attUid,'gejpt',{act='tk',type='fc',p=aPlaneid,num=1})

            -- 携带的资源
            local resource = self.pillageResource(attUid,defenser,fleetInfo)
            self.back(cronId,attUid,fleetInfo,resource)
            self.loseBoom(defenser, loseRate, addRate)

            self.attackerDmginfo = {}
            for k,v in pairs(fleetInfo) do
                if type(v)=='table' and next(v) then
                    self.attackerDmginfo[k] = string.format("%s-%s-%s",v[1],v[2],0)
                else
                    self.attackerDmginfo[k] = ""
                end
            end

            -- 邮件
            self.sendReport(attUid,self.attackerName,nil,award,resource,lostShip,tankinfo)
            self.sendReport(defenser,self.defenserName,nil,award,resource,lostShip,tankinfo)

            return 1
        end
                
        require "lib.battle"
        
        local report, aInavlidFleet, dInvalidFleet, attSeq, seqPoint,aSurviveTroops,dSurviveTroops= {}
        -- 防守方先出手
        report.d, report.r, aInavlidFleet, dInvalidFleet, attSeq, seqPoint = battle(aFleetInfo,defFleetInfo,1)
        report.t = {dFleetInfo,fleetInfo}

        if attSeq == 1 then
            report.p = {{dUserinfo.nickname,dUserinfo.level,1,seqPoint[2]},{aUserinfo.nickname,aUserinfo.level,0, seqPoint[1]}}            
        else
            report.p = {{dUserinfo.nickname,dUserinfo.level,0,seqPoint[2]},{aUserinfo.nickname,aUserinfo.level,1,seqPoint[1]}}
        end

        report.h = {dherosInfo[1],aherosInfo[1]}
        report.ocean = getBattleOcean()
        report.se ={dEquip.formEquip(dEquipid), aEquip.formEquip(aEquipid)}
        report.badge ={dBadgeVal, aBadgeVal}
      
        lostShip.attacker ,aSurviveTroops, self.attackerDmginfo = self.damageTroops(attUid,fleetInfo,aInavlidFleet)
        lostShip.defenser,dSurviveTroops, self.defenserDmgInfo = self.damageTroops(defenser,dFleetInfo,dInvalidFleet,false,true)
       
        -- kafkaLog
        self.setKfkLog(attackFleet,lostShip.attacker,cronId)
        self.setKfkLog(defackFleet,lostShip.defenser,cronId)
        
        self.drp = self.setUserRankPointByTanks(defenser,lostShip.attacker,dHeros,attUid)
        self.arp = self.setUserRankPointByTanks(attUid,lostShip.defenser,aHeros,defenser)
        
        -- 战斗胜利，奖励 ，防守方先出手，若防守方失败，则表示此次攻打胜利
        if report.r == 1 then     
            self.isVictory = 1

            -- 荣誉
            self.battleReputation = self.getBattleReputation(aUserinfo.reputation,dUserinfo.reputation)

            local resource = self.pillageResource(attUid,defenser,aSurviveTroops)
            self.back(cronId,attUid,aSurviveTroops,resource)            
            
            --损失比例
            local allValue = 0
            local loseValue = 0
            for k , v in pairs( atankinfo ) do 
                local oneValue = getConfig('tank.' .. k).tankPoint
                allValue = allValue +  oneValue*v
            end

            for k, v in pairs( lostShip.attacker ) do 
                local oneValue = getConfig('tank.' .. k).tankPoint
                loseValue = loseValue + oneValue*v
            end
            loseRate = loseValue/allValue
            
            -- 周年庆活动
            award = nil
            award = activity_setopt(attUid, "anniversary", {action="player", reward=award, battle=self}, 0, award)
            report.r = award or report.r

             -- 粽子作战
             local zongzi=activity_setopt(attUid, 'zongzizuozhan', {u=attUid,e='c',num=1})
             if type(zongzi)=='table' and next(zongzi) then
                if type(self.acaward)~='table' then
                    self.acaward={}
                end
                
                for k,v in pairs(zongzi) do
                    self.acaward[k]=v
                end 
     
             end

             -- 啤酒节
            local beerreward = activity_setopt(attUid,'beerfestival',{act='Rate4',num=1})
            if type(beerreward)=='table' and next(beerreward) then
                if type(self.acaward)~='table' then
                    self.acaward={}
                end
                
                for k,v in pairs(beerreward) do
                    self.acaward['beerfestival_'..k]=v
                end
            end
            -- 二周年
            local anniversary2 = activity_setopt(attUid,'anniversary2',{act='pl'})
            if type(anniversary2)=='table' and next(anniversary2) then
                if type(self.acaward)~='table' then
                    self.acaward={}
                end
                
                for k,v in pairs(anniversary2) do
                    self.acaward[k]= (self.acaward[k] or 0) + v
                end
             end

            -- 万圣节狂欢
            local wsjkh = activity_setopt(attUid,'wsjkh',{act=2,num=1,w=1})  
            if type(wsjkh)=='table' and next(wsjkh) then
                if type(self.acaward)~='table' then
                    self.acaward={}
                end
                
                for k,v in pairs(wsjkh) do
                    self.acaward[k]= (self.acaward[k] or 0) + v
                end
             end
             -- 感恩节2017
            local thanksgiving = activity_setopt(attUid,'thanksgiving',{act=2,num=1,w=1})  
            if type(thanksgiving)=='table' and next(thanksgiving) then
                if type(self.acaward)~='table' then
                    self.acaward={}
                end
                
                for k,v in pairs(thanksgiving) do
                    self.acaward[k]= (self.acaward[k] or 0) + v
                end
            end

             -- 装扮圣诞节
            self.setActReward({uid=attUid,act=2,aname='dresstree',num=1,w=1})
            
             -- 圣帕特里克
            self.setActReward({uid=attUid,act=2,aname='dresshat',num=1,w=1})
             -- 国庆七天乐
            activity_setopt(attUid,'nationalday2018',{act='tk',type='fc',p=aPlaneid,num=1})
            -- 感恩节拼图
            activity_setopt(attUid,'gejpt',{act='tk',type='fc',p=aPlaneid,num=1})

            self.loseBoom(defenser, loseRate, addRate)
            self.sendReport(attUid,self.attackerName,report,award,resource,lostShip,tankinfo)
            self.sendReport(defenser,self.defenserName,report,award,resource,lostShip,tankinfo)

            return 1
        end

        -- 荣誉
        self.battleReputation = self.getBattleReputation(dUserinfo.reputation,aUserinfo.reputation)

        self.loseBack(cronId,attUid,aSurviveTroops)

        self.sendReport(attUid,self.attackerName,report,award,resource,lostShip,tankinfo)
        self.sendReport(defenser,self.defenserName,report,award,resource,lostShip,tankinfo)

        return 0
    end

    ------------------------ 攻打玩家,有协防部队
    -- attUid ,攻击方uid
    -- fleetInfo ,攻击方舰队
    -- defenser ,防守方id
    -- 攻打玩家时，防守方先出手
    function self.battlePlayerByHelpDefence(attUid,fleetInfo,defenser,cronId,dFleetInfo,dcronId)
        -- 初始化防守方
        local duobjs = getUserObjs(defenser)
        local dUserinfo = duobjs.getModel('userinfo')
        local dHero = duobjs.getModel('hero')
        local dHeros =dHero.getAttackHeros('a',dcronId)
        local dEquip = duobjs.getModel('sequip')
        local dEquipid = dEquip.getEquipFleet('a', dcronId)
        local dPlane = duobjs.getModel('plane')
        local dPlaneid=dPlane.getPlaneFleet('a',dcronId)
        local dBadge = duobjs.getModel('badge')
        local dBadgeVal = dBadge.formBadge()

        local auobjs = getUserObjs(attUid)
        local aUserinfo = auobjs.getModel('userinfo')
        local ahero = auobjs.getModel('hero')          
        local aHeros =ahero.getAttackHeros('a',cronId)
        local defackFleet = duobjs.getModel('troops')
        local aEquip = auobjs.getModel('sequip')
        local aEquipid = aEquip.getEquipFleet('a', cronId)
        local aPlane = auobjs.getModel('plane')
        local aPlaneid= aPlane.getPlaneFleet('a',cronId)
        local aBadge = auobjs.getModel('badge')
        local aBadgeVal = aBadge.formBadge()

        -- 本次双方损失的坦克数量
        local lostShip = {
            attacker  = {},
            defenser = {},
        }

        self.reputation = 0
        self.resetAttackerProtectFlag = true
        self.helpDefender = dUserinfo.nickname

        -- [战报优化] 协防时，敌方的所有信息显示为协助玩家的
        self.defenserArmorInfo = duobjs.getModel('armor').formatUsedInfoForBattle()
        self.defenserAweaponInfo = duobjs.getModel('alienweapon').formatUsedInfoForBattle()
        
        self.helpDefenderInfoForReport = {
            level=dUserinfo.level, 
            vip=dUserinfo.showvip(), 
            fc=dUserinfo.fc,
            pic={
                dUserinfo.pic,dUserinfo.bpic,dUserinfo.apic
            },
        }

        -- 初始化防守方
        local defFleetInfo,dAccessory,dherosInfo,dplanevalue = defackFleet.initFleetAttribute(dFleetInfo,3,{landform=self.defenserLandform,hero=dHeros,equip=dEquipid,place=self.place,plane=dPlaneid})
        
        --  初始化攻击方          
        local attackFleet = auobjs.getModel('troops')
        local aFleetInfo,aAccessory,aherosInfo,aplanevalue = attackFleet.initFleetAttribute(fleetInfo,0,{landform=self.attackerLandform,hero=aHeros,equip=aEquipid,place=self.place,plane=aPlaneid})
        
        -- 双方装备对比
        self.dAey = dAccessory
        self.aAey = aAccessory

        self.dEquip = dEquip.formEquip(dEquipid)
        self.aEquip = aEquip.formEquip(aEquipid)      
        self.aPlane = aplanevalue
        self.dPlane = dplanevalue        

        -- 主基地战场
        self.battleground = 1

        -- 双方总坦克对比
        local dtankinfo={}
        if type(dFleetInfo) == 'table' then
            for k,v in pairs(dFleetInfo) do
                if type(v)=='table' and next(v) then
                    dtankinfo[v[1]]  =(dtankinfo[v[1]] or 0) +v[2]
                end
            end
        end
        local atankinfo={}
        for k,v in pairs(fleetInfo) do
            if type(v)=='table' and next(v) then
                atankinfo[v[1]]  =(atankinfo[v[1]] or 0) +v[2]
            end
        end
        local tankinfo={a=atankinfo,d=dtankinfo}

                -- 英雄强度
        self.aHeroPoint = aherosInfo[2]
        self.dHeroPoint = dherosInfo[2]
        self.aHeroInfo = aherosInfo[1]
        self.dHeroInfo = dherosInfo[1]

        -- 指挥官徽章
        self.abadge = aBadgeVal
        self.dbadge = dBadgeVal

        require "lib.battle"
        
        local report, aInavlidFleet, dInvalidFleet, attSeq, seqPoint ,aSurviveTroops,dSurviveTroops= {}
        -- 防守方先出手
        report.d, report.r, aInavlidFleet, dInvalidFleet, attSeq,seqPoint = battle(aFleetInfo,defFleetInfo,1)
        report.t = {dFleetInfo,fleetInfo}

        if attSeq == 1 then
            report.p = {{dUserinfo.nickname,dUserinfo.level,1,seqPoint[2]},{aUserinfo.nickname,aUserinfo.level,0,seqPoint[1]}}            
        else
            report.p = {{dUserinfo.nickname,dUserinfo.level,0,seqPoint[2]},{aUserinfo.nickname,aUserinfo.level,1,seqPoint[1]}}
        end

        report.h = {dherosInfo[1],aherosInfo[1]}
        report.ocean = getBattleOcean()
        report.se ={dEquip.formEquip(dEquipid), aEquip.formEquip(aEquipid)}
        report.badge ={dBadgeVal, aBadgeVal}
       
        lostShip.attacker ,aSurviveTroops, self.attackerDmginfo = self.damageTroops(attUid,fleetInfo,aInavlidFleet)        
        lostShip.defenser,dSurviveTroops, self.defenserDmgInfo  = self.damageTroops(defenser,dFleetInfo,dInvalidFleet)
       
        -- kafkaLog
        self.setKfkLog(attackFleet,lostShip.attacker,cronId)
        self.setKfkLog(defackFleet,lostShip.defenser,cronId)
        
        self.drp = self.setUserRankPointByTanks(defenser,lostShip.attacker,dHeros,attUid)
        self.arp = self.setUserRankPointByTanks(attUid,lostShip.defenser,aHeros,defenser)
        
        return report.r == 1,lostShip,aSurviveTroops,report,dSurviveTroops,tankinfo
    end

    -- 抢占资源点,此资源点已被占领
    function self.robNpcToPlayer(cronId,mapId,attUid,fleetInfo,defenser,isGather,olvl)
        --  初始化攻击方
        local auobjs = getUserObjs(attUid)
        local aUserinfo = auobjs.getModel('userinfo')        
        local attackFleet = auobjs.getModel('troops')    
        local ahero       = auobjs.getModel('hero')
        local aHeros      =ahero.getAttackHeros('a',cronId)
        local aEquip = auobjs.getModel('sequip')
        local aEquipid = aEquip.getEquipFleet('a', cronId)
        local aPlane = auobjs.getModel('plane')
        local aPlaneid= aPlane.getPlaneFleet('a',cronId)
        local aBadge = auobjs.getModel('badge')
        local aBadgeVal = aBadge.formBadge() 

        local aFleetInfo,aAccessory,aherosInfo,aplanevalue = attackFleet.initFleetAttribute(fleetInfo,0,{landform=self.attackerLandform,hero=aHeros,equip=aEquipid,place=self.place,plane=aPlaneid})
        local duobjs = getUserObjs(defenser)
        local dUserinfo = duobjs.getModel('userinfo')        
        local defackFleet = duobjs.getModel('troops')
        local dhero       =duobjs.getModel('hero')
        local dFleetInfo,dCronId = defackFleet.getGatherFleetByMid(mapId)
        local dHeros      =dhero.getAttackHeros('a',dCronId)
        local dEquip = duobjs.getModel('sequip')
        local dEquipid = dEquip.getEquipFleet('a', dCronId)
        local dPlane = duobjs.getModel('plane')
        local dPlaneid = dPlane.getPlaneFleet('a', dCronId)
        local dBadge = duobjs.getModel('badge')
        local dBadgeVal = dBadge.formBadge() 
        

        -- 此岛未有驻守部队
        if not dFleetInfo or not  dFleetInfo.troops then
            local mMap = require "lib.map"
            mMap:format(mapId)

            self.defenser = 0
            self.defenserName = ''
            self.defenserLevel = 0
            self.DAName = ''
            self.helpDefender=nil
            self.dAey = {}  -- 防守者的配件信息
            self.dHeroPoint = 0 -- 防守者英雄强度
            self.dHeroInfo = {} -- 防守方英雄信息
            self.drp = 0    -- 防守方获得的军功值
            self.islandOwner = 0
            self.defenserVip = nil
            self.defenserFc = nil
            self.defenserPic = nil
            self.defenseraPic = nil
            self.defenserbPic = nil
            self.defenserArmorInfo = nil
            self.defenserAweaponInfo = nil

            return self.battleNpc(attUid,fleetInfo,mapId,cronId,isGather,olvl)
        end
        --战争之路活动
        activity_setopt(attUid,'battleRoad',{c=1})
        -- 复活节彩蛋大搜寻
        local eggReward = activity_setopt(attUid,'searchEasterEgg',{egg3=1})
        if eggReward then
            self.acaward = self.acaward or {}
            self.acaward["egg3"] = 1
        end

        -- 中秋赏月活动埋点(富矿)
        local goldMineMap = self.mMap:getGoldMine()
        if self.mMap:getHeatLevel(mapId) > 0 or (goldMineMap and goldMineMap[tostring(mapId)]) then
            activity_setopt(attUid, 'midautumn', {action='rb'})
            -- 国庆活动埋点
            activity_setopt(attUid, 'nationalDay', {action='rb'})
            -- 开年大吉
            activity_setopt(attUid,'openyear',{action="rb"})
            -- 春节攀升
            activity_setopt(attUid, 'chunjiepansheng', {action='rb'})
            -- 陨石冶炼
            activity_setopt(attUid, 'yunshiyelian', {action='rb'})
            -- 悬赏任务
            activity_setopt(attUid,'xuanshangtask',{t='',e='rb',n=1}) 
            -- 点亮铁塔
             activity_setopt(attUid,'lighttower',{act='rb',num=1}) 
             -- 愚人节大作战-攻打X次富矿
            activity_setopt(attUid,'foolday2018',{act='task',tp='rb',num=1})

            -- 国庆七天乐
            activity_setopt(attUid,'nationalday2018',{act='tk',type='rb',num=1})
        end

        dFleetInfo = dFleetInfo.troops
        defFleetInfo,dAccessory,dherosInfo,dplanevalue = defackFleet.initFleetAttribute(dFleetInfo,21,{landform=self.defenserLandform,hero=dHeros,equip=dEquipid,place=self.place,plane=dPlaneid})
        
        -- 双方装备对比
        self.dAey = dAccessory
        self.aAey = aAccessory
        self.resetAttackerProtectFlag = true

        self.dEquip = dEquip.formEquip(dEquipid)
        self.aEquip = aEquip.formEquip(aEquipid)
        -- 飞机对比值
        self.aPlane= aplanevalue
        self.dPlane= dplanevalue

        -- 战场世界野矿
        self.battleground = 2

                -- 英雄强度
        self.aHeroPoint = aherosInfo[2]
        self.dHeroPoint = dherosInfo[2]
        self.aHeroInfo = aherosInfo[1]
        self.dHeroInfo = dherosInfo[1]

        -- 指挥官徽章
        self.abadge = aBadgeVal
        self.dbadge = dBadgeVal

        -- 双方总坦克对比
        local dtankinfo={}
        if type(dFleetInfo) == 'table' then
            for k,v in pairs(dFleetInfo) do
                if type(v)=='table' and next(v) then
                    dtankinfo[v[1]]  =(dtankinfo[v[1]] or 0) +v[2]
                end
            end
        end
        local atankinfo={}
        for k,v in pairs(fleetInfo) do
            if type(v)=='table' and next(v) then
                atankinfo[v[1]]  =(atankinfo[v[1]] or 0) +v[2]
            end
        end
        local tankinfo={a=atankinfo,d=dtankinfo}

        require "lib.battle"
        
        local report, aInavlidFleet, dInvalidFleet, attSeq, seqPoint,aSurviveTroops,dSurviveTroops = {}
        -- 防守方先出手
        report.d, report.r, aInavlidFleet, dInvalidFleet, attSeq,seqPoint = battle(aFleetInfo,defFleetInfo,1)
        report.t = {dFleetInfo,fleetInfo}

        if attSeq == 1 then
            report.p = {{dUserinfo.nickname,dUserinfo.level,1,seqPoint[2]},{aUserinfo.nickname,aUserinfo.level,0,seqPoint[1]}}            
        else
            report.p = {{dUserinfo.nickname,dUserinfo.level,0,seqPoint[2]},{aUserinfo.nickname,aUserinfo.level,1,seqPoint[1]}}
        end

        report.h = {dherosInfo[1],aherosInfo[1]}
        report.ocean = getBattleOcean()
        report.se ={dEquip.formEquip(dEquipid), aEquip.formEquip(aEquipid)}
        report.badge ={dBadgeVal, aBadgeVal}
        local lostShip = {}
       
        lostShip.attacker , aSurviveTroops, self.attackerDmginfo = self.damageTroops(attUid,fleetInfo,aInavlidFleet)
        lostShip.defenser, dSurviveTroops, self.defenserDmgInfo = self.damageTroops(defenser,dFleetInfo,dInvalidFleet,nil, true)
       
        -- kafkaLog
        self.setKfkLog(attackFleet,lostShip.attacker,cronId)
        self.setKfkLog(defackFleet,lostShip.defenser,cronId)

        self.drp = self.setUserRankPointByTanks(defenser,lostShip.attacker,dHeros,attUid)
        self.arp = self.setUserRankPointByTanks(attUid,lostShip.defenser,aHeros,defenser)
        
        local heatLv = self.mMap:getHeatLevel(mapId)
        self.rLv = heatLv

        local award,resource

        -- 攻占此岛屿胜利                 
        if report.r == 1 then
            self.isVictory = 1
            if heatLv>0 or type(self.goldMineInfo)=="table" then
                -- 二次授勋增加携带此将领占领富矿X次
                ahero.refreshFeat("t13",aHeros,1)
            end
            local robRes = self.pillageCollectedResource(defackFleet.attack[dCronId])
            
            if type(robRes) == 'table' and next(robRes) then
                local rname,rnum = next(robRes)
                local islandFlag = defackFleet.attack[dCronId].goldMine and 1 or 2
                self.robAlienRes = attackFleet.goldAddAlien(rname,rnum,fleetInfo.AcRate,true,islandFlag,heatLv)
                attackFleet.attack[cronId].heatLv = heatLv

                if self.goldMineInfo then
                    attackFleet.attack[cronId].goldMine=self.goldMineInfo
                end
            end

            if isGather == 1 then
                self.gather(cronId,attUid,aSurviveTroops,robRes,nil,self.robGoldMineGems)        -- 开始采集        
                self.occupyPoint(mapId,attUid)   -- 占领据点
            else
                -- 富矿热度
                self.mMap:refreshHeat(mapId)
                self.mMap:decrHeatPoint(mapId)
                self.back(cronId,attUid,aSurviveTroops,robRes,self.robGoldMineGems)  -- 返回
                self.mMap:changeOwner(mapId,0,true)
            end

            --秘宝探寻(业务需求，攻打已经占领的资源点不得碎片和复原药水)
            --award, self.acaward = getActiveRewardFormatMail(attUid, 'miBao', {level=self.islandLevel}, award)
            -- 周年庆活动
            award = nil
            award = activity_setopt(attUid, "anniversary", {action="res", reward=award, battle=self}, 0, award)
            report.r = award or report.r

            self.loseExpel(defenser,mapId,dSurviveTroops)   -- 占岛者被弄死了

            -- 荣誉
            self.battleReputation = self.getBattleReputation(aUserinfo.reputation,dUserinfo.reputation)

            -- 粽子作战
             local zongzi=activity_setopt(attUid, 'zongzizuozhan', {u=attUid,e='c',num=1})
             if type(zongzi)=='table' and next(zongzi) then
                if type(self.acaward)~='table' then
                    self.acaward={}
                end
                for k,v in pairs(zongzi) do
                    self.acaward[k]=v
                end
             end

             -- 二周年
            local anniversary2 = activity_setopt(attUid,'anniversary2',{act='kd'})
            if type(anniversary2)=='table' and next(anniversary2) then
                if type(self.acaward)~='table' then
                    self.acaward={}
                end
                
                for k,v in pairs(anniversary2) do
                    self.acaward[k] = v
                end
             end  

            -- 万圣节狂欢
            local wsjkh = activity_setopt(attUid,'wsjkh',{act=3,num=1,w=1})   
            if type(wsjkh)=='table' and next(wsjkh) then
                if type(self.acaward)~='table' then
                    self.acaward={}
                end
                
                for k,v in pairs(wsjkh) do
                    self.acaward[k] = v
                end
             end          
            
             -- 感恩节2017
            local thanksgiving = activity_setopt(attUid,'thanksgiving',{act=3,num=1,w=1})  
            if type(thanksgiving)=='table' and next(thanksgiving) then
                if type(self.acaward)~='table' then
                    self.acaward={}
                end
                
                for k,v in pairs(thanksgiving) do
                    self.acaward[k]= (self.acaward[k] or 0) + v
                end
            end

            -- 装扮圣诞节
            self.setActReward({uid=attUid,act=3,aname='dresstree',num=1,w=1})
            -- 圣帕特里克
            self.setActReward({uid=attUid,act=3,aname='dresshat',num=1,w=1})
            -- 世界杯_一球成名
            self.setActReward({uid=attUid,act='task',aname='oneshot',id=1})

            -- 国庆七天乐
            activity_setopt(attUid,'nationalday2018',{act='tk',type='fc',p=aPlaneid,num=1})
            -- 感恩节拼图
            activity_setopt(attUid,'gejpt',{act='tk',type='fc',p=aPlaneid,num=1})

            --邮件
            self.sendReport(attUid,self.attackerName,report,award,robRes,lostShip,tankinfo)
            self.sendReport(defenser,self.defenserName,report,award,robRes,lostShip,tankinfo)

            return 1
        -- 防守方胜利
        else

            -- 荣誉
            self.battleReputation = self.getBattleReputation(dUserinfo.reputation,aUserinfo.reputation)

            self.loseBack(cronId,attUid,aSurviveTroops)
            self.updateGather(defenser,mapId,dSurviveTroops)    -- 重新计算经过战斗后舰队的采集量
            
            self.sendReport(attUid,self.attackerName,report,award,resource,lostShip,tankinfo)
            self.sendReport(defenser,self.defenserName,report,award,resource,lostShip,tankinfo)

            return 0
        end

    end

    ------------------ 攻打npc
    -- attUid ,攻击方uid
    -- fleetInfo ,攻击方舰队
    -- defenser ,防守方id
    -- 攻打npc时攻击方先出手
    function self.battleNpc(attUid,fleetInfo,defenser,cronId,isGather,olvl)
        local islandCfg = getConfig('island')        
        local defFleetInfo = self.islandTroops
        local defSkill = islandCfg[self.islandLevel].skill
        local defTech = islandCfg[self.islandLevel].tech        
        local defName = self.islandType  --'敌人' -- 名称
        local defAttUp = islandCfg[self.islandLevel].attributeUp

        local auobjs = getUserObjs(attUid)
        local aUserinfo = auobjs.getModel('userinfo')        
        local attackFleet = auobjs.getModel('troops')  
        local ahero       = auobjs.getModel('hero') 
        local aHeros      = ahero.getAttackHeros('a',cronId) 
        local aEquip      = auobjs.getModel('sequip')
        local aEquipid    = aEquip.getEquipFleet('a', cronId)
        local aPlane      = auobjs.getModel('plane')
        local aPlaneid    = aPlane.getPlaneFleet('a',cronId)
        local aBadge      = auobjs.getModel('badge')
        local aBadgeVal   = aBadge.formBadge()


        local equipvalue = aEquip.dySkillAttr(aEquipid, 's104', 0)  -- 矿点作战 攻打矿点伤害加成X%

        local aFleetInfo,aAccessory,aherosInfo,aplanevalue = attackFleet.initFleetAttribute(fleetInfo,0,{landform=self.attackerLandform,hero=aHeros,equip=aEquipid, equipskill={dmg=equipvalue},place=self.place,plane=aPlaneid})        
        local dFleetInfo = self.initDefFleetAttribute(defFleetInfo,defSkill,defTech,defAttUp)

        self.aAey = aAccessory
        -- 英雄强度
        self.aHeroPoint = aherosInfo[2]
        self.aHeroInfo = aherosInfo[1]

        self.aEquip = aEquip.formEquip(aEquipid)
        --飞机
        self.aPlane = aplanevalue
          -- 指挥官徽章
        self.abadge = aBadgeVal
        
        -- 双方总坦克对比
        local dtankinfo={}
        if type(defFleetInfo) == 'table' then
            for k,v in pairs(defFleetInfo) do
                if type(v)=='table' and next(v) then
                    dtankinfo[v[1]]  =(dtankinfo[v[1]] or 0) +v[2]
                end
            end
        end
        local atankinfo={}
        for k,v in pairs(fleetInfo) do
            if type(v)=='table' and next(v) then
                atankinfo[v[1]]  =(atankinfo[v[1]] or 0) +v[2]
            end
        end
        local tankinfo={a=atankinfo,d=dtankinfo}



        require "lib.battle"
        
        local report, aInavlidFleet, dInvalidFleet,aSurviveTroops,dSurviveTroops = {}
        report.d, report.r, aInavlidFleet, dInvalidFleet = battle(aFleetInfo,dFleetInfo)
        report.t = {defFleetInfo,fleetInfo}        
        report.p = {{defName,self.islandLevel,0},{aUserinfo.nickname,aUserinfo.level,1}}
        report.h = {{},aherosInfo[1]}
        report.ocean = getBattleOcean()
        report.se = {0, aEquip.formEquip(aEquipid)}
        report.badge = {{0,0,0,0,0,0}, aBadgeVal}

        local lostShip,_ = {}
      
        lostShip.attacker  ,aSurviveTroops, self.attackerDmginfo = self.damageTroops(attUid,fleetInfo,aInavlidFleet)
        lostShip.defenser, _, self.defenserDmgInfo = self.damageTroops(defenser,defFleetInfo,dInvalidFleet,true)  
      
        -- kafkaLog
        self.setKfkLog(attackFleet,lostShip.attacker,cronId)
        
        local award ,resource
        -- 复活节彩蛋大搜寻
        local eggReward = activity_setopt(attUid,'searchEasterEgg',{egg3=1})
        if eggReward then
            self.acaward = self.acaward or {}
            self.acaward["egg3"] = 1
        end
        
        -- 富矿热度(获取富矿等级之前需要刷新一下热度)
        self.mMap:refreshHeat(defenser)
        -- 中秋赏月活动埋点（富矿）
        local heatLv = self.mMap:getHeatLevel( defenser )
        self.rLv = heatLv
        local goldMineMap = self.mMap:getGoldMine()
        if heatLv > 0 or (goldMineMap and goldMineMap[tostring(defenser)]) then
            activity_setopt(attUid, 'midautumn', {action='rb'})
            -- 国庆活动埋点
            activity_setopt(attUid, 'nationalDay', {action='rb'})
            -- 开年大吉
            activity_setopt(attUid,'openyear',{action="rb"})
            -- 春节攀升
            activity_setopt(attUid, 'chunjiepansheng', {action='rb'})
            -- 陨石冶炼
            activity_setopt(attUid, 'yunshiyelian', {action='rb'})
            -- 悬赏任务
            activity_setopt(attUid,'xuanshangtask',{t='',e='rb',n=1}) 
            -- 点亮铁塔
            activity_setopt(attUid,'lighttower',{act='rb',num=1}) 
            -- 愚人节大作战-攻打X次富矿
            activity_setopt(attUid,'foolday2018',{act='task',tp='rb',num=1})
            -- 国庆七天乐
            activity_setopt(attUid,'nationalday2018',{act='tk',type='rb',num=1})
        end

        -- 战斗胜利，奖励
        if report.r == 1 then
            self.isVictory = 1
            local islandRewards = copyTable(islandCfg[self.islandLevel].reward)
            local islandRewardProp,islandRewardPropNums = self.getBattleProp()
            if islandRewardProp then
                islandRewards[islandRewardProp] = islandRewardPropNums
            end

            if heatLv>0 or type(self.goldMineInfo)=="table" then
                -- 二次授勋增加携带此将领占领富矿X次
                ahero.refreshFeat("t13",aHeros,1)
            end

            self.takeReward(attUid,islandRewards)

            local award = self.formatReward(islandRewards)
            --增加活动数据
            local addAcaward = function(add, default)
                if type(add) ~= "table" then
                    return default
                end
                if type(default) == 'table' then
                    for i,v in pairs(add) do
                        default[i] = v
                    end
                else
                    default = add
                end
                return default
            end
            local tmpacaward
            --秘宝探寻
            award, tmpacaward = getActiveRewardFormatMail(attUid, 'miBao', {level=self.islandLevel}, award)
            self.acaward = addAcaward(tmpacaward, self.acaward)
            --jidongbudui active
            award, tmpacaward = getActiveRewardFormatMail(attUid, 'jidongbudui',
                {mlv=self.islandLevel,getReward=true,troops=defFleetInfo,index=self.place}, award)
            self.acaward = addAcaward(tmpacaward, self.acaward)
            
            -- 不给糖就捣蛋
            if award and 'table' == type(award) then
                award.t = activity_setopt(attUid,'halloween',{ar=1})
            end

            --万圣节驱鬼大战
            award = getActiveRewardFormatMail(attUid, 'ghostWars', {level=self.islandLevel,type='getReward'}, award)
            -- 周年庆活动
            award = activity_setopt(attUid, "anniversary", {action="res", reward=award, battle=self}, 0, award)
            report.r = award

            -- 更新岛屿兵力
            self.mMap:setDefenseFleet(defenser)
            if isGather == 1 then
                self.gather(cronId,attUid,aSurviveTroops,nil,defenser,nil,olvl)  
                self.occupyPoint(defenser,attUid,true)   -- 占领据点
            else
                self.mMap:decrHeatPoint(defenser)
                self.mMap:changeOwner(defenser,0,true) -- 更新岛的兵力了，所以要更新数据
                self.back(cronId,attUid,aSurviveTroops) -- 回家
            end

            -- 粽子作战
             local zongzi=activity_setopt(attUid, 'zongzizuozhan', {u=attUid,e='c',num=1})
             if type(zongzi)=='table' and next(zongzi) then
                if type(self.acaward)~='table' then
                    self.acaward={}
                end
                
                for k,v in pairs(zongzi) do
                    self.acaward[k]=v
                end
             end 

            -- 二周年
            local anniversary2 = activity_setopt(attUid,'anniversary2',{act='kd'})
            if type(anniversary2)=='table' and next(anniversary2) then
                if type(self.acaward)~='table' then
                    self.acaward={}
                end
                
                for k,v in pairs(anniversary2) do
                    self.acaward[k] = v
                end
             end   

            -- 万圣节狂欢
            local wsjkh = activity_setopt(attUid,'wsjkh',{act=3,num=1,w=1}) 
            if type(wsjkh)=='table' and next(wsjkh) then
                if type(self.acaward)~='table' then
                    self.acaward={}
                end
                
                for k,v in pairs(wsjkh) do
                    self.acaward[k] = v
                end
             end             
            
            -- 感恩节2017
            local thanksgiving = activity_setopt(attUid,'thanksgiving',{act=3,num=1,w=1})  
            if type(thanksgiving)=='table' and next(thanksgiving) then
                if type(self.acaward)~='table' then
                    self.acaward={}
                end
                
                for k,v in pairs(thanksgiving) do
                    self.acaward[k]= (self.acaward[k] or 0) + v
                end
            end

             -- 装扮圣诞树
            self.setActReward({uid=attUid,act=3,aname='dresstree',num=1,w=1})
            
             -- 圣帕特里克
            self.setActReward({uid=attUid,act=3,aname='dresshat',num=1,w=1})
            -- 世界杯_一球成名
            self.setActReward({uid=attUid,act='task',aname='oneshot',id=1})
            -- 国庆七天乐
            activity_setopt(attUid,'nationalday2018',{act='tk',type='fc',p=aPlaneid,num=1})

            -- 感恩节拼图
            activity_setopt(attUid,'gejpt',{act='tk',type='fc',p=aPlaneid,num=1})

            -- 发送邮件 
            self.sendReport(attUid,self.attackerName,report,award,resource,lostShip,tankinfo)
            return 1
        end

        self.loseBack(cronId,attUid,aSurviveTroops)
        self.sendReport(attUid,self.attackerName,report,award,resource,lostShip,tankinfo)
        return 0
    end

    -- 抢占异星矿山资源点,此资源点被其它玩家占领
    function self.robAlienMineNpcToPlayer(cronId,mapId,attUid,fleetInfo,defenser,isGather)
        --  初始化攻击方
        local auobjs = getUserObjs(attUid)
        local aUserinfo = auobjs.getModel('userinfo')        
        local attackFleet = auobjs.getModel('troops')    
        local ahero       = auobjs.getModel('hero')
        local aHeros      =ahero.getAttackHeros('a',cronId)
        local aEquip = auobjs.getModel('sequip')
        local aEquipid = aEquip.getEquipFleet('a',cronId)       
        local aPlane      = auobjs.getModel('plane')
        local aPlaneid    = aPlane.getPlaneFleet('a',cronId) 
        local aBadge      = auobjs.getModel('badge')
        local aBadgeVal = aBadge.formBadge()     
        local aFleetInfo,aAccessory,aherosInfo,aplanevalue = attackFleet.initFleetAttribute(fleetInfo,0,{hero=aHeros,equip=aEquipid,plane=aPlaneid})

        local duobjs = getUserObjs(defenser)
        local dUserinfo = duobjs.getModel('userinfo')        
        local defackFleet = duobjs.getModel('troops')
        local dhero       =duobjs.getModel('hero')
        local dFleetInfo,dCronId = defackFleet.getGatherFleetByAlienMineMid(mapId)
        local dHeros      =dhero.getAttackHeros('a',dCronId)
        local dEquip = duobjs.getModel('sequip')
        local dEquipid = dEquip.getEquipFleet('a', dCronId)
        local dPlane      = duobjs.getModel('plane')
        local dPlaneid    = dPlane.getPlaneFleet('a',dCronId)
        local dBadge      = duobjs.getModel('badge')
        local dBadgeVal = dBadge.formBadge()   

        -- 此岛未有驻守部队
        if not dFleetInfo or not  dFleetInfo.troops then
            return false
        end

        dFleetInfo = dFleetInfo.troops
        defFleetInfo,dAccessory,dherosInfo,dplanevalue = defackFleet.initFleetAttribute(dFleetInfo,0,{landform=self.defenserLandform,hero=dHeros,equip=dEquipid,plane=dPlaneid})
        
        -- 战报中显示坦克信息
        local tankinfo={a=self.getTankInfo(fleetInfo),d=self.getTankInfo(dFleetInfo)}

        -- 双方装备对比
        self.dAey = dAccessory
        self.aAey = aAccessory
        self.resetAttackerProtectFlag = true

        self.dEquip =  dEquip.formEquip(dEquipid)
        self.aEquip =  aEquip.formEquip(aEquipid)

        --飞机强度
        self.aPlane = aplanevalue
        self.dPlane = dplanevalue

        -- 英雄强度
        self.aHeroPoint = aherosInfo[2]
        self.dHeroPoint = dherosInfo[2]
        self.aHeroInfo = aherosInfo[1]
        self.dHeroInfo = dherosInfo[1]

        -- 指挥官徽章
        self.abadge = aBadgeVal
        self.dbadge = dBadgeVal

        require "lib.battle"
        
        local report, aInavlidFleet, dInvalidFleet, attSeq, seqPoint,aSurviveTroops,dSurviveTroops = {}
        -- 防守方先出手
        report.d, report.r, aInavlidFleet, dInvalidFleet, attSeq,seqPoint = battle(aFleetInfo,defFleetInfo,1)
        report.t = {dFleetInfo,fleetInfo}

        if attSeq == 1 then
            report.p = {{dUserinfo.nickname,dUserinfo.level,1,seqPoint[2]},{aUserinfo.nickname,aUserinfo.level,0,seqPoint[1]}}
        else
            report.p = {{dUserinfo.nickname,dUserinfo.level,0,seqPoint[2]},{aUserinfo.nickname,aUserinfo.level,1,seqPoint[1]}}
        end

        report.h = {dherosInfo[1],aherosInfo[1]}
        report.se = {dEquip.formEquip(dEquipid), aEquip.formEquip(aEquipid)}
        report.badge = {dBadgeVal, aBadgeVal}

        local lostShip = {}
        -- TODO 这里部队直接扣掉20%，其它直接加回到用户身上，
        lostShip.attacker , aSurviveTroops = self.alienMineBattleDamageTroops(attUid,fleetInfo,aInavlidFleet)
        lostShip.defenser, dSurviveTroops = self.alienMineBattleDamageTroops(defenser,dFleetInfo,dInvalidFleet)

        -- kafkaLog
        self.setKfkLog(attackFleet,lostShip.attacker,cronId)
        self.setKfkLog(defackFleet,lostShip.defenser,cronId)

        self.drp = self.setUserRankPointByTanks(defenser,lostShip.attacker,attUid)
        self.arp = self.setUserRankPointByTanks(attUid,lostShip.defenser,defenser)
        
        local award,resource 

        -- 攻占此岛屿胜利                 
        if report.r == 1 then
            self.isVictory = 1

            -- 抢得的前一位占岛者的资源的50%
            local robRes,clientShowRes = self.robAlienMineResource(defackFleet.attack[dCronId])
            report.r = clientShowRes

            -- 如果有采集行为，开始采集，并占领据点
            -- 否则清空矿山
            if isGather == 1 then
                self.gather(cronId,attUid,aSurviveTroops,robRes)   
                self.mMap:changeAlienMapOwner(mapId,attUid,false,self.attackerName,self.AAName,aUserinfo.fc)
            else
                attackFleet.attack[cronId].troops = aSurviveTroops
                attackFleet.attack[cronId].res = robRes
                attackFleet.fleetBack(cronId,true)
                attackFleet.updateAttack()
                self.mMap:changeAlienMapOwner(mapId,0)
            end

            -- 部队直接返回
            defackFleet.attack[dCronId].troops = dSurviveTroops
            defackFleet.attack[dCronId].expel = 1
            defackFleet.fleetBack(dCronId,true)
            defackFleet.updateAttack()

            -- TODO 邮件需要重新生成一个类型的邮件
            self.sendReport(attUid,self.attackerName,report,award,robRes,lostShip,tankinfo,4)
            self.sendReport(defenser,self.defenserName,report,award,robRes,lostShip,tankinfo,4)

            return 1,report

        -- 防守方胜利
        else
            attackFleet.attack[cronId].troops = aSurviveTroops
            attackFleet.fleetBack(cronId,true)
            attackFleet.updateAttack()

            self.updateAlienmineTroopGather(defenser,mapId,dSurviveTroops)    -- 重新计算经过战斗后舰队的采集量
            
            -- TODO 攻击方直接回家，扣除其部队，并扣掉一次掠夺次数
            self.sendReport(attUid,self.attackerName,report,award,resource,lostShip,tankinfo,4)
            self.sendReport(defenser,self.defenserName,report,award,resource,lostShip,tankinfo,4)

            return 0,report
        end

    end

    -- 攻打异星矿山资源点
    -- 只有有采集行为的用户才能攻打矿山
    function self.battleAlienMineNpc(attUid,fleetInfo,defenser,cronId,isGather)
        local islandCfg = getConfig('island')        
        local defFleetInfo = self.islandTroops
        local defSkill = islandCfg[self.islandLevel].skill
        local defTech = islandCfg[self.islandLevel].tech        
        local defName = self.islandType  --'敌人' -- 名称
        local defAttUp = islandCfg[self.islandLevel].attributeUp

        local auobjs = getUserObjs(attUid)
        local aUserinfo = auobjs.getModel('userinfo')        
        local attackFleet = auobjs.getModel('troops')  
        local ahero       = auobjs.getModel('hero') 
        local aHeros      = ahero.getAttackHeros('a',cronId) 
        local aEquip = auobjs.getModel('sequip')
        local aEquipid = aEquip.getEquipFleet('a',cronId)
        local aPlane = auobjs.getModel('plane')
        local aPlaneid = aPlane.getPlaneFleet('a',cronId)
        local aFleetInfo,aAccessory,aherosInfo,aplanevalue = attackFleet.initFleetAttribute(fleetInfo,0,{landform=self.attackerLandform,hero=aHeros,equip=aEquipid,plane=aPlaneid})        
        local dFleetInfo = self.initDefFleetAttribute(defFleetInfo,defSkill,defTech,defAttUp)

        -- 战报中显示坦克信息
        local tankinfo={a=self.getTankInfo(fleetInfo),d=self.getTankInfo(defFleetInfo)}

        self.aAey = aAccessory
        self.aEquip =aEquip.formEquip(aEquipid)
        self.aPlane = aplanevalue
        
        -- 英雄强度
        self.aHeroPoint = aherosInfo[2]
        self.aHeroInfo = aherosInfo[1]

        require "lib.battle"
        
        local report, aInavlidFleet, dInvalidFleet = {}
        report.d, report.r, aInavlidFleet, dInvalidFleet = battle(aFleetInfo,dFleetInfo)
        report.t = {defFleetInfo,fleetInfo}        
        report.p = {{defName,self.islandLevel,0},{aUserinfo.nickname,aUserinfo.level,1}}
        report.h = {{},aherosInfo[1]}
        report.se = {0, 0}

        local lostShip,aSurviveTroops = {}
        lostShip.attacker  ,aSurviveTroops = self.alienMineBattleDamageTroops(attUid,fleetInfo,aInavlidFleet)
        lostShip.defenser = self.alienMineBattleDamageTroops(defenser,defFleetInfo,dInvalidFleet,true)   

        -- kafkaLog
        self.setKfkLog(attackFleet,lostShip.attacker,cronId)
        
        local award ,resource

        -- 战斗胜利，奖励
        if report.r == 1 then
            self.isVictory = 1

            -- 更新岛屿兵力
            self.mMap:setDefenseFleet(defenser)

            if isGather == 1 then
                self.gather(cronId,attUid,aSurviveTroops)
                self.mMap:changeAlienMapOwner(defenser,attUid,true,self.attackerName,self.AAName,aUserinfo.fc)
            end
            
            -- 发送邮件
            self.sendReport(attUid,self.attackerName,report,award,resource,lostShip,tankinfo,4)
            return 1,report
        end

        attackFleet.attack[cronId].troops = aSurviveTroops
        attackFleet.fleetBack(cronId,true)
        attackFleet.updateAttack()

        self.sendReport(attUid,self.attackerName,report,award,resource,lostShip,tankinfo,4)
        return 0,report
    end

    -- 叛军战斗
    function self.battleRebelForces(attUid,attFleetInfo,defenser,cronId)
        local defFleetInfo = self.rebelInfo.troops      
        local defName = self.islandType
        local dFleetInfo = self.mRebel.initDefFleetAttribute(defFleetInfo,self.rebelInfo.level,self.defenserLandform,self.rebelInfo)

        local auobjs = getUserObjs(attUid)
        local aUserinfo = auobjs.getModel('userinfo')        
        local attackFleet = auobjs.getModel('troops')  
        local ahero       = auobjs.getModel('hero') 
        local aHeros      = ahero.getAttackHeros('a',cronId) 
        local aUserforces = auobjs.getModel('userforces')
        local aEquip      = auobjs.getModel('sequip')
        local aEquipid    = aEquip.getEquipFleet('a', cronId)        
        local aPlane = auobjs.getModel('plane')
        local aPlaneid = aPlane.getPlaneFleet('a',cronId)
        local aBadge = auobjs.getModel('badge')
        local aBadgeVal = aBadge.formBadge()


        local fleetInfo = attFleetInfo.troops
        local hitCount = aUserforces.getAttackRate(defenser,self.rebelInfo.expireTs)
        local aFleetInfo,aAccessory,aherosInfo,aplanevalue = attackFleet.initFleetAttribute(fleetInfo,0,{landform=self.attackerLandform,hero=aHeros, equip=aEquipid,place=self.place,plane=aPlaneid})        
        
        -- 连击次数buff加成
        local rebelCfg = getConfig("rebelCfg")
        if hitCount > 0 then
            local hitBuff = 1 + rebelCfg.attackBuff * hitCount
            for k,v in pairs(aFleetInfo) do
                if v.dmg then
                    v.dmg = math.floor(v.dmg * hitBuff)
                end
            end
        end

        -- 攻击倍数
        if attFleetInfo.rebelMulti == 2 then
            for k,v in pairs(aFleetInfo) do
                if v.dmg then
                    v.dmg = math.floor(v.dmg * rebelCfg.highAttack)
                end
            end
        end

        self.aAey = aAccessory
        self.aEquip = aEquip.formEquip(aEquipid)
        self.aPlane = aplanevalue 
        -- 指挥官徽章
        self.abadge = aBadgeVal
   

        -- 英雄强度
        self.aHeroPoint = aherosInfo[2]
        self.aHeroInfo = aherosInfo[1]
        -- 双方总坦克对比
        local dtankinfo={}
        if type(defFleetInfo) == 'table' then
            for k,v in pairs(defFleetInfo) do
                if type(v)=='table' and next(v) then
                    dtankinfo[v[1]]  =(dtankinfo[v[1]] or 0) +v[2]
                end
            end
        end
        local atankinfo={}
        for k,v in pairs(fleetInfo) do
            if type(v)=='table' and next(v) then
                atankinfo[v[1]]  =(atankinfo[v[1]] or 0) +v[2]
            end
        end
        local tankinfo={a=atankinfo,d=dtankinfo}

        require "lib.battle"
        
        local report, aInavlidFleet, dInvalidFleet,aSurviveTroops,dSurviveTroops,battleData,_ = {}
        report.d, report.r, aInavlidFleet, dInvalidFleet,_,_,_,battleData = battle(aFleetInfo,dFleetInfo,nil,nil,{delhp=rebelCfg.startDamage,delhpShowKey="@"})
        report.t = {defFleetInfo,fleetInfo}        
        report.p = {{defName,self.islandLevel,0},{aUserinfo.nickname,aUserinfo.level,1}}
        report.h = {{},aherosInfo[1]}
        report.se ={0, aEquip.formEquip(aEquipid)}
        report.badge ={{0,0,0,0,0,0}, aBadgeVal}

        local killFlag,dmgTotalHp,leftHp = self.mRebel.deHp(defenser,battleData.defenderLossHpCount,aUserinfo.alliance)
        
        -- 开年大吉
        activity_setopt(attUid,'openyear',{action="fa"})
        -- 春节攀升
        activity_setopt(attUid, 'chunjiepansheng', {action='fa'})

        -- 悬赏任务
        activity_setopt(attUid,'xuanshangtask',{t='',e='fa',n=1})          
        -- 愚人节大作战-攻打X次海盗
        activity_setopt(attUid,'foolday2018',{act='task',tp='fa',num=1})
        -- 全民劳动
        activity_setopt(attUid,'laborday',{act='task',t='fa',n=1})  

        --海域航线
        activity_setopt(attUid,'hyhx',{act='tk',type='fa',num=1})

        -- 三周年-冲破噩梦-炮弹搜索
        self.setActReward({uid=attUid,type='fa',aname='cpem',num=1})

        -- 国庆七天乐
        activity_setopt(attUid,'nationalday2018',{act='tk',type='fa',num=1})


        -- 如果不是被别人击杀(没死或者是被我方击杀)
        if killFlag ~= 2 then
            local lostShip, _ = {}
            lostShip.attacker  ,aSurviveTroops, self.attackerDmginfo = self.rebelBattleDamageTroops(attUid,fleetInfo,aInavlidFleet)
            lostShip.defenser, _, self.defenserDmgInfo = self.countDamageTroops(defFleetInfo,dInvalidFleet)

            self.arp = self.getRebelRankPoint(self.rebelInfo.level,lostShip.defenser,attUid)
            self.addUserRankPoint(attUid, self.arp, aHeros)
            -- 摧枯拉朽活动
            activity_setopt(attUid,"cuikulaxiu",{point=self.arp},true,0)

            -- kafkaLog
            self.setKfkLog(attackFleet,lostShip.attacker,cronId,{killRebelFlag=killFlag,hp=battleData.defenderLossHpCount})

            local reward = self.mRebel.getBattleReward(dmgTotalHp,self.rebelInfo.maxHp,self.rebelInfo.level,self.rebelInfo.force)
            takeReward(attUid,reward)
            local beerreward={} -- 啤酒节的活动
            local wsjkh = {} --万圣节狂欢
            local thanksgiving = {} --感恩节2017
            local dresshat = {} --圣帕特里克
            
            if report.r == 1 then
                self.isVictory = 1
                self.back(cronId,attUid,aSurviveTroops) -- 回家
                if killFlag == 1 then
                    -- 啤酒节
                    beerreward = activity_setopt(attUid,'beerfestival',{act='Rate5',num=1})   
                    -- 番茄大作战
                    activity_setopt(attUid,'fqdzz',{act='tk',type='fs',num=1})   

                    -- 三周年-冲破噩梦-炮弹搜索
                    self.setActReward({uid=attUid,type='fs',aname='cpem',num=1})                     
                end
                -- 万圣节狂欢
                wsjkh = activity_setopt(attUid,'wsjkh',{act=4,num=1,w=1}) 
                --感恩节2017
                thanksgiving = activity_setopt(attUid,'thanksgiving',{act=4,num=1,w=1})
                --圣帕特里克
                dresshat = activity_setopt(attUid,'dresshat',{act=7,num=1,w=1})  

                -- 国庆七天乐
                activity_setopt(attUid,'nationalday2018',{act='tk',type='fc',p=aPlaneid,num=1})
                -- 感恩节拼图
                activity_setopt(attUid,'gejpt',{act='tk',type='fc',p=aPlaneid,num=1})
            elseif report.r == -1 then
                self.loseBack(cronId,attUid,aSurviveTroops)
            end
            -- 二次授勋增加攻击携带此将领攻打叛军X次
            ahero.refreshFeat("t10",aHeros,1)
            -- 发送邮件  *奖励放在award这里就可以加到邮件中展示了*
            local award = formatReward(reward)
            if type(beerreward)=='table' and next(beerreward) then
                award.beer = beerreward
            end

            if type(wsjkh)=='table' and next(wsjkh) then
                award.wsjkh = wsjkh
            end

            if type(thanksgiving)=='table' and next(thanksgiving) then
                award.thank = thanksgiving
            end

            if type(dresshat)=='table' and next(dresshat) then
                award.dresshat = dresshat
            end
            -- 世界杯_一球成名
            self.setActReward({uid=attUid,act='task',aname='oneshot',id=2})
   
            local mailParams = {
                rebelMultiNum = attFleetInfo.rebelMulti == 2 and rebelCfg.highAttack or 1,
                rebelAttNum = hitCount,
                rebelLeftLife = leftHp,
                reduceLife = dmgTotalHp,
            }
            self.sendReport(attUid,self.attackerName,report,award,nil,lostShip,tankinfo,nil,mailParams)
            -- --军团击杀海盗
            if aUserinfo.alliance > 0 and type(lostShip.defenser)=='table' then
               local rebeldietroops = 0
                for k,v in pairs(lostShip.defenser) do
                    rebeldietroops = rebeldietroops + v    
                end
                if rebeldietroops >0 then
                    -- 战资比拼
                    zzbpupdate(attUid,{t='f9',n=rebeldietroops,id=self.islandLevel})
                    
                    local mAtmember = auobjs.getModel('atmember')
                    if mAtmember.upKill(rebeldietroops) then
                        local mAterritory = getModelObjs("aterritory",aUserinfo.alliance,false,true)
                        if mAterritory then
                            if mAterritory.upKill(rebeldietroops) then
                                regEventAfterSave(attUid,'e10',{aid=aUserinfo.alliance})
                            end
                        else
                            writeLog('军团领地击杀海盗添加失败uid'..attUid..'aid='..aUserinfo.alliance..'击杀数'..rebeldietroops,'killrebel')
                        end                    
                    end
                end    
            end
        end

        return killFlag,leftHp
    end

    -- 将领试炼
    function self.battleAnneal(attUid,attFleetInfo,defenser,cronId, annealUid)
        local defFleetInfo = self.annealInfo.troops      
        local defName = self.islandType
        local dFleetInfo = self.mAnneal.initDefFleetAttribute(defFleetInfo,self.annealInfo.level,self.defenserLandform,self.annealInfo)
        
        local auobjs = getUserObjs(attUid)
        local aUserinfo = auobjs.getModel('userinfo')        
        local attackFleet = auobjs.getModel('troops')  
        local ahero       = auobjs.getModel('hero') 
        local aHeros      = ahero.getAttackHeros('a',cronId)
        local aEquip      = auobjs.getModel('sequip')
        local aEquipid    = aEquip.getEquipFleet('a', cronId)         
        local aPlane = auobjs.getModel('plane')
        local aPlaneid = aPlane.getPlaneFleet('a',cronId) 
        local aBadge = auobjs.getModel('badge')
        local aBadgeVal = aBadge.formBadge()

        local fleetInfo = attFleetInfo.troops
        local aFleetInfo,aAccessory,aherosInfo,aplanevalue = attackFleet.initFleetAttribute(fleetInfo,0,{landform=self.attackerLandform,hero=aHeros,equip=aEquipid,place=self.place,plane=aPlaneid})    
        
        self.aAey = aAccessory
        self.aEquip =aEquip.formEquip(aEquipid)
        self.aPlane = aplanevalue 

        -- 指挥官徽章
        self.abadge = aBadgeVal

        -- 英雄强度
        self.aHeroPoint = aherosInfo[2]
        self.aHeroInfo = aherosInfo[1]
        -- 双方总坦克对比
        local dtankinfo={}
        if type(defFleetInfo) == 'table' then
            for k,v in pairs(defFleetInfo) do
                if type(v)=='table' and next(v) then
                    dtankinfo[v[1]]  =(dtankinfo[v[1]] or 0) +v[2]
                end
            end
        end
        local atankinfo={}
        for k,v in pairs(fleetInfo) do
            if type(v)=='table' and next(v) then
                atankinfo[v[1]]  =(atankinfo[v[1]] or 0) +v[2]
            end
        end
        local tankinfo={a=atankinfo,d=dtankinfo}

        require "lib.battle"
        
        local report, aInavlidFleet, dInvalidFleet,aSurviveTroops,dSurviveTroops,battleData,_ = {}
        report.d, report.r, aInavlidFleet, dInvalidFleet,_,_,_,battleData = battle(aFleetInfo,dFleetInfo,nil,nil,{delhpShowKey="@"})
        report.t = {defFleetInfo,fleetInfo}        
        report.p = {{defName,self.islandLevel,0},{aUserinfo.nickname,aUserinfo.level,1}}
        report.h = {{},aherosInfo[1]}
        report.se ={0, aEquip.formEquip(aEquipid)}
        report.badge ={{0,0,0,0,0,0}, aBadgeVal}

        local killFlag,dmgTotalHp,leftHp = self.mAnneal.deHp(defenser,battleData.defenderLossHpCount,aUserinfo.alliance)

        -- 如果不是被别人击杀(没死或者是被我方击杀)
        if killFlag ~= 2 then
            local lostShip, _ = {}
            lostShip.attacker  ,aSurviveTroops, self.attackerDmginfo = self.damageTroops(attUid,fleetInfo,aInavlidFleet)
            lostShip.defenser, _, self.defenserDmgInfo = self.countDamageTroops(defFleetInfo,dInvalidFleet)

            -- kafkaLog
            self.setKfkLog(attackFleet,lostShip.attacker,cronId,{killFlag=killFlag,hp=battleData.defenderLossHpCount})

            if report.r == 1 then
                self.isVictory = 1
                self.back(cronId,attUid,aSurviveTroops) -- 回家
            elseif report.r == -1 then
                self.loseBack(cronId,attUid,aSurviveTroops)
            end

            local ownobjs = getUserObjs(annealUid)
            local ownUserinfo = ownobjs.getModel('userinfo')
            local ownHero = ownobjs.getModel('hero')

            local fly = nil
            if attUid ~= annealUid and killFlag == 1 then
                local annealCfg = getConfig("heroAnnealCfg")
                local quality = string.split(ownHero.anneal.t.task, "_")
                fly = annealCfg.troops[ownHero.anneal.t.lv].friendly[tonumber(quality[2])]
                if ownUserinfo.alliance ~= 0 and ownUserinfo.alliance == aUserinfo.alliance then
                    fly = math.floor( fly * annealCfg.sameAlliance )
                end

                fly = ahero.addAnnealFly(fly, annealCfg.friendlyMax)
            end            
            -- 发送邮件 
            local mailParams = {
                annealLeftLife = leftHp,
                reduceLife = dmgTotalHp,
                task = ownHero.anneal.t.task,
                ownId = annealUid,
                ownName = ownUserinfo.nickname,
                fly = fly,
            }
            -- 世界杯_一球成名
            self.setActReward({uid=attUid,act='task',aname='oneshot',id=3})
            self.sendReport(attUid,self.attackerName,report,nil,nil,lostShip,tankinfo,nil,mailParams)
        end  

        return killFlag,leftHp, dmgTotalHp      
    end

    -- 领海战
    function self.battleSeaWar(libSeaWar,attacker,defender,place,turretFire,battleGround)
        local dCronId = defender.cronId
        local aCronId = attacker.cronId

        local auobjs = getUserObjs(attacker.uid)
        local aTroop = auobjs.getModel('troops')
        local aHero = auobjs.getModel('hero')   
        local aEquip = auobjs.getModel('sequip')
        local aUserinfo = auobjs.getModel('userinfo')  
        local aHeros =aHero.getAttackHeros('a',aCronId)
        local aEquipid = aEquip.getEquipFleet('a',aCronId)
        local aFleetInfo = aTroop.getFleetByCron(aCronId)
        local aPlane      = auobjs.getModel('plane')
        local aPlaneid    = aPlane.getPlaneFleet('a',aCronId)  
        local aBadge      = auobjs.getModel('badge')
        local aBadgeVal = aBadge.formBadge()


        local duobjs = getUserObjs(defender.uid)
        local dUserinfo = duobjs.getModel('userinfo')  
        local dTroop = duobjs.getModel('troops')
        local dmHero       = duobjs.getModel('hero')
        local dHeros = dmHero.getAttackHeros('a',dCronId)
        local dEquip = duobjs.getModel('sequip')
        local dEquipid = dEquip.getEquipFleet('a',dCronId)
        local dFleetInfo = dTroop.getFleetByCron(dCronId)
        local dPlane      = duobjs.getModel('plane')
        local dPlaneid    = dPlane.getPlaneFleet('a',dCronId)
        local dBadge     = duobjs.getModel('badge')
        local dBadgeVal = dBadge.formBadge()
        
        if not aFleetInfo or aFleetInfo.bs then
            return -2
        end

        if not dFleetInfo or dFleetInfo.bs then
            return -3
        end

        -- 防守方地形按城市算
        local defenserLandform = 6
        local attackerLandform = getAttackerLandformOfBattle({aUserinfo.mapx,aUserinfo.mapy},place)

        -- 初始化防守方
        local defFleetInfo,dAccessory,dherosInfo,dplanevalue = dTroop.initFleetAttribute(dFleetInfo.troops,20,{landform=defenserLandform,hero=dHeros,equip=dEquipid,place=place,plane=dPlaneid})
        
        local attFleetInfo,aAccessory,aherosInfo,aplanevalue = aTroop.initFleetAttribute(aFleetInfo.troops,20,{landform=attackerLandform,hero=aHeros,equip=aEquipid,place=place,plane=aPlaneid})

        libSeaWar.winDebuff(attacker.wins,attFleetInfo)
        libSeaWar.winDebuff(defender.wins,defFleetInfo)

        -- 双方装备对比
        self.dAey = dAccessory
        self.aAey = aAccessory
        self.dEquip = dEquip.formEquip(dEquipid)
        self.aEquip = aEquip.formEquip(aEquipid)
        
        -- 飞机对比值
        self.aPlane= aplanevalue
        self.dPlane= dplanevalue

        -- 英雄强度
        self.aHeroPoint = aherosInfo[2]
        self.dHeroPoint = dherosInfo[2]
        self.aHeroInfo = aherosInfo[1]
        self.dHeroInfo = dherosInfo[1]

        -- 指挥官徽章
        self.abadge = aBadgeVal
        self.dbadge = dBadgeVal

        self.islandType = 9
        self.place = place
        self.domainType = battleGround.bid

        self.setAttackInfoForReport(attacker.uid,place)
        self.setDefenderInfoForReport(defender.uid,defenserLandform)

        local mailParams = {
            seawar = {
                domainType = battleGround.bid,
                showDura = battleGround.aid == defender.aid and 1 or 0,
            }
        }

        require "lib.battle"
         
        local report, aInavlidFleet, dInvalidFleet, attSeq, seqPoint,aSurviveTroops,dSurviveTroops = {}
        -- 防守方先出手
        report.d, report.r, aInavlidFleet, dInvalidFleet, attSeq,seqPoint = battle(attFleetInfo,defFleetInfo,1,nil,{delhp=turretFire,delhpShowKey="@2"})
        report.t = {dFleetInfo.troops,aFleetInfo.troops}

        if attSeq == 1 then
            report.p = {{dUserinfo.nickname,dUserinfo.level,1,seqPoint[2]},{aUserinfo.nickname,aUserinfo.level,0,seqPoint[1]}}
        else
            report.p = {{dUserinfo.nickname,dUserinfo.level,0,seqPoint[2]},{aUserinfo.nickname,aUserinfo.level,1,seqPoint[1]}}
        end

        report.h = {dherosInfo[1],aherosInfo[1]}
        report.se = {dEquip.formEquip(dEquipid), aEquip.formEquip(aEquipid)}
        report.badge = {dBadgeVal, aBadgeVal}

        local lostShip = {}

        lostShip.attacker ,aSurviveTroops, self.attackerDmginfo = self.seaWarBattleDamageTroops(attacker.uid,aFleetInfo.troops,aInavlidFleet)
        lostShip.defenser,dSurviveTroops, self.defenserDmgInfo = self.seaWarBattleDamageTroops(defender.uid,dFleetInfo.troops,dInvalidFleet)

        -- kafkaLog
        self.setKfkLog(aTroop,lostShip.attacker,aCronId)
        self.setKfkLog(dTroop,lostShip.defenser,aCronId)

        -- 攻占此岛屿胜利
        if report.r == 1 then
            self.isVictory = 1
            aFleetInfo.troops = aSurviveTroops
            self.loseBack(dCronId,defender.uid,dSurviveTroops)

        -- 防守方胜利
        else
            self.isVictory = 0
            dFleetInfo.troops = dSurviveTroops
            self.loseBack(aCronId,attacker.uid,aSurviveTroops)
        end

        self.sendReport(attacker.uid,aUserinfo.nickname,report,nil,nil,lostShip,nil,nil,mailParams)
        self.sendReport(defender.uid,dUserinfo.nickname,report,nil,nil,lostShip,nil,nil,mailParams)

        return self.isVictory, aSurviveTroops, dSurviveTroops
    end

    -- 发送胜利战报
    --rid       -- eid
    --time  时间戳 
    --type 类型：1攻击 2被攻击
    --islandType 岛屿类型 1自己，2别人，3资源岛，4被玩家占领的资源岛，待定
    --target 目标名字
    --place 地点 {x,y}
    --isVictory 是否获胜
    --award 奖励
    --resource 掠夺或被掠夺资源
    --lostShip 双方损失战船
    -- local lostShip={
    --         attacker ={{a10001=12},{},{}},
    --         defenser={{name="sample_ship_name_c1",num="20"},{name="sample_ship_name_b2",num="20"}}
    --honor 获得或损失荣誉
    --helpDefender 协防部队 
    -- aey table  装备对比 {攻方装备情况，防守方装备情况}
    function self.sendReport(uid,uname,report,award,resource,lostShip,tankinfo,mail_type,params)
        local mail = {
            type=1,
            report = report,
            helpDefender = self.helpDefender,
            destroy  = lostShip,
            tank = tankinfo,
            rewards = award,
            aey = {self.aAey,self.dAey,},
            hh = {{self.aHeroInfo,self.aHeroPoint},{self.dHeroInfo,self.dHeroPoint}},
            rp = {self.arp,self.drp,},
            armor = {self.attackerArmorInfo or {},self.defenserArmorInfo or {}},
            alienWeapon = {self.attackerAweaponInfo or {},self.defenserAweaponInfo or {}},
            dmginfo = {self.attackerDmginfo or {},self.defenserDmgInfo or {}},
            equip = {self.aEquip or 0, self.dEquip or 0},
            bdrate = {self.arate or -1,self.drate or -1},--- 进维修厂比例
            badge = {self.abadge or {0,0,0,0,0,0},self.dbadge or {0,0,0,0,0,0}},--- 指挥官徽章
            fromWay = self.fromReport(uname), 
            resource = {
                battle=resource,
                alienRes=self.robAlienRes,
            },
            rLv = self.rLv,
            plane={self.aPlane,self.dPlane},
            info={
                attacker = self.attacker,
                attackerName = self.attackerName,
                attackerLevel = self.attackerLevel,
                attackerVip = self.attackerVip or 0,
                attackerFc = self.attackerFc or 0,
                defenser = self.defenser,
                defenserName = self.defenserName,
                defenserLevel = self.defenserLevel,
                defenserVip = self.defenserVip or 0,
                defenserFc = self.defenserFc or 0,
                islandType = self.islandType,
                islandOwner = self.islandOwner,
                islandLevel = self.islandLevel,
                boom = self.defboom, -- 繁荣度
                place = self.place,
                ts = getClientTs(),
                reputation = self.battleReputation,
                isVictory = self.isVictory,    
                AttackerPlace = self.AttackerPlace,   
                AAName = self.AAName,
                DAName = self.DAName,
                aLandform = self.attackerLandform,
                dLandform = self.defenserLandform,
                attackerPic = {self.attackerPic or "",self.attackerbPic or "",self.attackeraPic or ""}, -- 攻击方图片
                defenserPic = {self.defenserPic or "",self.defenserbPic or "" ,self.defenseraPic or "battle"},
            }
        }

        if self.acaward then
            mail.acaward = self.acaward

            -- 注 发战报的时候 一定先给攻击方发(发完 奖励就被清空了)
            self.acaward = nil
        end

        -- 金矿信息
        if type(self.goldMineInfo) == 'table' then
            mail.resource.robGems = self.robGoldMineGems  -- 本次被抢夺的金币
            mail.resource.leftGems = self.robLeftGoleMineGems    -- 被抢后剩余的金币
            mail.goldMineLv=self.goldMineInfo[3] -- 金矿等级
            mail.goldLeftTime=self.goldMineInfo[2] -- 金矿消失时间
        end

        -- 叛军信息
        if type(self.rebelInfo) == "table" then
            mail.rebel = {
                pic = self.attackerPic, -- 攻击方图片
                bpic= self.attackerbPic,--攻击方头像框
                apic= self.attackeraPic,--攻击方挂件
                multiNum = params.rebelMultiNum, -- 攻击倍数
                attNum = params.rebelAttNum, -- 攻击方连击次数
                rebelLv = self.rebelInfo.level, -- 叛军等级
                rebelID = self.rebelInfo.force, -- 叛军部队id
                rebelTotalLife = self.rebelInfo.maxHp, -- 叛军总血量
                rebelLeftLife = params.rebelLeftLife, -- 叛军剩余血量
                reduceLife = params.reduceLife, -- 本次扣除的血量
            }
        end

        -- 将领试炼
        if type(self.annealInfo) == 'table' then
            mail.anneal ={
                pic = self.attackerPic,-- 攻击方图片
                bpic= self.attackerbPic,--攻击方头像框
                apic= self.attackeraPic,--攻击方挂件
                Lv = self.annealInfo.level,
                leftLife = params.annealLeftLife,
                totalLife = self.annealInfo.maxHp,
                reduceLife = params.reduceLife,
                task = params.task,
                ownId = params.ownId,
                ownName = params.ownName,
            }
            mail.acaward = mail.acaward or {}
            mail.acaward['fly'] = params.fly
        end

        -- [战报优化] 增加了协防者的相关信息
        if self.helpDefenderInfoForReport then
            mail.helpDefenderInfo = self.helpDefenderInfoForReport
        end

        if params and params.seawar then
            for k,v in pairs(params.seawar) do
                mail.info[k] = v
            end
        end

        local mail_type = mail_type or 2
        local isRead = 0
        local aName = self.attackerName and string.gsub(self.attackerName,'-','—') or self.attackerName
        local dName = self.defenserName and string.gsub(self.defenserName,'-','—') or self.defenserName
        local mailTitle = '1-'..self.islandType..'-'..aName..'-'..dName .. '-' .. self.attacker .. '-' .. self.defenser .. '-' .. tostring(self.isVictory)
        --mailSent(uid,sender,receiver,mail_from,mail_to,subject,content,mail_type,isRead)

        MAIL:mailSent(uid,1,uid,'',uname,mailTitle,mail,mail_type,isRead)        
    end

    -------初始化npc的舰队属性
    function self.initDefFleetAttribute(tanks,skills,techs,defAttUp)
        local inittanks = initTankAttribute(tanks,techs,skills,nil,nil,0,{landform=self.defenserLandform,acAttributeUp=defAttUp})
        return inittanks
    end

    ---------兵损失量--------------
    function self.damageTroops(uid,fleetInfo,invalidFleetInfo,isNpc,isDefender)
        local dietroops = {}
        local troops = {}
        local dietroops2 = {}

        -- 战报优化客户需要的数据格式：{tid-该位置参战数量-剩余数量，tid-该位置参战数量-剩余数量}
        local detailForClient = {}

        for k,v in pairs(fleetInfo) do           
            if next(v) and v[2] > 0 then
                if invalidFleetInfo[k].num < 0 or invalidFleetInfo[k].num > v[2] then
                    tankError(string.format("invalid FleetInfo: %s,%s,%s", tostring(k), tostring(v[2]), tostring(invalidFleetInfo[k].num)))
                end

                local aid = v[1]
                table.insert(troops,{aid,invalidFleetInfo[k].num})
                
                local dieNum = v[2] - invalidFleetInfo[k].num   -- 损失坦克
                
                if dieNum > 0 then
                    dietroops[aid]= (dietroops[aid] or 0) + dieNum
                    dietroops2[k] = {aid, dieNum} -- 每个位置损失的坦克
                end                

                detailForClient[k] = string.format("%s-%s-%s",v[1],v[2],dieNum)
            else
                table.insert(troops,{v[1],v[2],})
                detailForClient[k] = ""
            end
        end

        if isNpc then 
            return dietroops,nil,detailForClient 
        end
        
        local uobjs = getUserObjs(uid)
        local mTroop = uobjs.getModel('troops')
        local mAweapon = uobjs.getModel('alienweapon')
        local mSkills = uobjs.getModel('skills')

      

        -- 损毁的坦克，巨兽再现活动需要以此计算积分
        local destroyTanks = {}
        --战争守护活动防守方不损兵
        local surviveRate = activity_setopt(uid,'attackedProtect',{})
        local baseRate = 0.8 
        if isDefender and surviveRate and surviveRate>=0 and surviveRate<=1 then
            baseRate = baseRate + (1-baseRate)*surviveRate
        end

        -- 防守方在野外和主基地作战时,超级装备减少损失
        if self.dEquip ~=0 and not isNpc and isDefender and (self.battleground == 1 or self.battleground == 2) then
            local mSequip = uobjs.getModel('sequip')
            local equipvalue = mSequip.dySkillAttr(self.dEquip, 's3', 0)
            if equipvalue > 0 then
                baseRate = baseRate + (1-baseRate) * equipvalue
                baseRate = math.floor(baseRate * 1000) / 1000
            end
        end
        
        if baseRate > 1 then baseRate = 1 end

        local repaired = mAweapon.autoRepair(dietroops2, baseRate)

        ------损失的坦克进修理厂
        for k,v in pairs(dietroops) do
            local repairNum = math.ceil(v * baseRate )
            destroyTanks[k] = (destroyTanks[k] or 0) + math.floor(v * (1-baseRate) )

            --技能自动修复
            if repaired[k] then
                repairNum = repairNum - repaired[k]
                mTroop.incrTanks(k, repaired[k])
            end 

            mTroop.incrDamagedTanks(k,repairNum)
            regEventBeforeSave(uid,'e1')
            if isDefender and tonumber(self.islandType) == 6 then
                mTroop.consumeTanks(k,v,isDefender)
            end 
        end

        -- if isDefender then
        --     mTroop.setDefenseFleet(troops)
        -- end
    
        activity_setopt(uid,'monsterComeback',{destroyTanks=destroyTanks})
        if isDefender then
            self.drate = baseRate 
        else
            self.arate = baseRate
        end

        return dietroops,troops,detailForClient
    end

    ---------兵损失量--------------
    function self.allianceWarDamageTroops(uid,fleetInfo,invalidFleetInfo)
        local dietroops = {}
        local troops = {}

        for k,v in pairs(fleetInfo) do           
            if next(v) and v[2] > 0 then
                if invalidFleetInfo[k].num < 0 or invalidFleetInfo[k].num > v[2] then
                    tankError(string.format("invalid FleetInfo: %s,%s,%s", tostring(k), tostring(v[2]), tostring(invalidFleetInfo[k].num)))
                end

                ------损失坦克
                local dieNum = v[2] - invalidFleetInfo[k].num                
                local aid = v[1]
                dietroops[aid]= (dietroops[aid] or 0) + dieNum
                
                if invalidFleetInfo[k].num > 0 then
                    table.insert(troops,{aid,invalidFleetInfo[k].num})
                else
                    table.insert(troops,{})
                end
            else
                table.insert(troops,{})
            end
        end
                
        local uobjs = getUserObjs(uid)
        local mTroop = uobjs.getModel('troops')

        -- 损毁的坦克，巨兽再现活动需要以此计算积分
        local destroyTanks = {}
        
        ------损失的坦克直接返给家中
        for k,v in pairs(dietroops) do
            local repairNum = math.ceil(v * 0.99)
            destroyTanks[k] = (destroyTanks[k] or 0) + math.floor(v * 0.01)

            mTroop.incrTanks(k,repairNum)
            regEventBeforeSave(uid,'e1')
        end
    
        activity_setopt(uid,'monsterComeback',{destroyTanks=destroyTanks})

        return dietroops,troops
    end

    -- 异星矿山战斗阵亡
    -- 与其它战斗不一样的是，阵亡的部队按80%存活率直接带回家
    -- 阵亡的部队还需要参加巨兽再现活动
    function self.alienMineBattleDamageTroops(uid,fleetInfo,invalidFleetInfo,isNpc,isDefender)
        -- 统计阵亡部队
        local dietroops = {}

        -- 存活下来的部队，这个部队数会附加上阵亡复活的80%,异星矿山部队返还方式走的是Model刷新
        local troops = {}

        for k,v in pairs(fleetInfo) do           
            if next(v) and v[2] > 0 then
                if invalidFleetInfo[k].num < 0 or invalidFleetInfo[k].num > v[2] then
                    tankError(string.format("invalid FleetInfo: %s,%s,%s", tostring(k), tostring(v[2]), tostring(invalidFleetInfo[k].num)))
                end

                -- 实际损失的坦克数量
                local dieNum = v[2] - invalidFleetInfo[k].num 
                local aid = v[1]
                dietroops[aid]= (dietroops[aid] or 0) + dieNum
                
                if invalidFleetInfo[k].num > 0 then
                    table.insert(troops,{aid,invalidFleetInfo[k].num})
                else
                    table.insert(troops,{})
                end
            else
                table.insert(troops,{})
            end
        end

        if isNpc then return dietroops end

        local uobjs = getUserObjs(uid)
        local mTroop = uobjs.getModel('troops')
        
        -- 损毁的坦克，巨兽再现活动需要以此计算积分
        local destroyTanks = {}
        for k,v in pairs(dietroops) do
            local repairNum = math.ceil(v * 0.8)
            destroyTanks[k] = (destroyTanks[k] or 0) + math.floor(v * 0.2)

            mTroop.incrTanks(k,repairNum)
            regEventBeforeSave(uid,'e1')
        end
        activity_setopt(uid,'monsterComeback',{destroyTanks=destroyTanks})
        
        return dietroops,troops
    end

    -- 战斗结束资源处理
    function self.pillageResource(attuid,defuid,fleetInfo)
        local pillageRes = {r1=0,r2=0,r3=0,r4=0,gold=0} 
        local auobjs = getUserObjs(attuid)
        local duobjs = getUserObjs(defuid)
        local aUserinfo = auobjs.getModel('userinfo')
        local dUserinfo = duobjs.getModel('userinfo')

        local res = dUserinfo.getUnprotectedResource() or {}
        local carryRes = 0
        local addCarryRate = self.addCarryRateByAlliance(attuid)

        local Scarryrate=auobjs.getModel('skills').getSkillRate(2)
        Scarryrate = Scarryrate + (auobjs.getModel('statue').getSkillValue('capacityBonus') or 0)

        if type(fleetInfo) == 'table' then
            local tankCfg = getConfig('tank')
            for _,v in pairs(fleetInfo) do
                if type(v) == 'table' and next(v) then
                    -- local carryResource = tankCfg[v[1]].carryResource + tankCfg[v[1]].carryResource * addCarryRate
                    local carryResource = tankCfg[v[1]].carryResource * v[2]
                    carryResource = carryResource + carryResource * addCarryRate
                    carryResource = carryResource + carryResource * Scarryrate
                    carryRes = carryRes + carryResource
                end
            end
        end 

        local totalRes = 0
        for k,v in pairs(res) do
            totalRes = totalRes + v
        end

        local nums = 0

         if totalRes > 0 and totalRes <= carryRes then          
            pillageRes = res 
            nums = totalRes
        elseif totalRes > 0 and totalRes > carryRes then  
            local pillageRate = {}
            for k,v in pairs(res) do
                pillageRate[k] = v / totalRes
            end
            
            for k,v in pairs(pillageRes) do
                pillageRes[k] = math.floor(v + pillageRate[k] * carryRes)
            end

            nums = carryRes
        end

        dUserinfo.useResource(pillageRes)
        self.pillageRes = nums or 0

        return pillageRes,carryRes
    end

    -- 掠夺别人已经收集到的资源
    function self.pillageCollectedResource(fleetInfo)
        local robRes = arrayGet(fleetInfo,'res')     -- 抢得的前一位占岛者的资源

        if fleetInfo.gems then
            local goldMineCfg = getConfig("goldMineCfg")
            self.robGoldMineGems = math.floor(fleetInfo.gems * goldMineCfg.gemsRob)
            if self.robGoldMineGems > fleetInfo.gems then
                self.robGoldMineGems = fleetInfo.gems
            end
            self.robLeftGoleMineGems = fleetInfo.gems - self.robGoldMineGems
        end

        return robRes
    end

    -- 攻占据点
    function self.occupyPoint(mid,uid,setDataFlag)
        -- local db = getDbo()
        -- db:update('map',{oid=uid},"id="..mid)
        self.mMap:changeOwner(mid,uid,setDataFlag)
    end

    function self.gatherInfo(uid,cronFleetInfo, cronId)
        local arrayGet = arrayGet

        local fleetInfo = arrayGet(cronFleetInfo,'troops')
        local landlevel = arrayGet(cronFleetInfo,'level')
        local islandType = arrayGet(cronFleetInfo,'type')
        local islandHeatLv = arrayGet(cronFleetInfo,'heatLv',0)

        local type2name = {'r1','r2','r3','r4','gold'}
        local islandCfg = getConfig('map')        
        local tankCfg = getConfig('tank')
        local mapHeatCfg = getConfig('mapHeat')
        
        local resource = {nil}   -- 采集的最大资源
        local gtime = 0     -- 采集所需时间
        local rname = type2name[islandType]

        -- 如果是异星矿场，采集的资源只能是钛矿
        if cronFleetInfo.alienMine then 
            rname = 'r4' 
        end
        
        resource[rname] = 0

        local ts = getClientTs()
        local speed = islandCfg[islandType][landlevel].resource

        -- 这里记住原始的采集速度，后面用来反推本次所有的加成
        local originalSpeed = speed

        --驱鬼活动
        local diffspeed = activity_setopt(uid,"ghostWars",{type='decTime',time=speed},false,0)
        speed = speed + diffspeed

        --a10103 增加采集速度的坦克 公式 INT(数量^LOG(5,10))/100
        local total_a10103 = 0
        if type(fleetInfo) == 'table' then
            local pairs = pairs
            local arrayGet = arrayGet
            for k,v in pairs(fleetInfo) do
                local num = arrayGet(v,2,0)
                local aid = arrayGet(v,1,0)
                if num > 0 then
                    if aid == 'a10103' then
                        total_a10103 = total_a10103 + num
                    end
                end
            end
        end
        local speed_a10103 = math.floor(total_a10103^math.logn(5,10))/100
        speed = speed + math.ceil(speed * speed_a10103)
        local addCarryRate = self.addCarryRateByAlliance(uid)

        local heatSpeed
        if moduleIsEnabled('lf')==1 and moduleIsEnabled('heat')==1 and islandHeatLv > 0 then
            heatSpeed = mapHeatCfg.resourceSpeed[islandHeatLv] or 0
            speed = speed + speed * heatSpeed
        end

         -- 5 是采集速度增加
        local uobjs = getUserObjs(uid,true)
        local mJob  = uobjs.getModel('jobs')
        local mSkills  = uobjs.getModel('skills')
        local jobvalue=mJob.getjobaddvalue(5) -- 区域站速度增加
        if (tonumber(jobvalue) or 0) > 0 then
            speed = speed + speed * jobvalue
        end
        -- 圣诞大作战
        local christRate = activity_setopt(uid, "christmasfight", {getRes=1}, true)
        if christRate ~= nil and christRate > 0 then
            speed = speed + speed * christRate
        end

        -- 全民劳动
        local laborrate = activity_setopt(uid,'laborday',{act='upRate',n=1})
        if laborrate  then
            speed = speed + speed * laborrate
        end

        -- 超级装备加成
        local mSequip = uobjs.getModel('sequip')
        local mEquipid = mSequip.getEquipFleet('a',cronId)
        local equipvalue = mSequip.dySkillAttr(mEquipid, 's201', 0) --急速采集 资源采集速度增加X%
        if equipvalue > 0 then
            speed = speed + speed * equipvalue
        end

        local mUserinfo = uobjs.getModel('userinfo')
        if mUserinfo.alliance > 0 then
            local mTerritory = getModelObjs("aterritory",mUserinfo.alliance,true)
            local _,territorySpeed = mTerritory.getTerritoryAreaBuff(cronFleetInfo.targetid[1],cronFleetInfo.targetid[2])
            if territorySpeed then
                speed = speed + speed * territorySpeed
            end
        end

        -- 金矿数度加倍
        if cronFleetInfo.goldMine then
            local goldMineCfg = getConfig("goldMineCfg")
            speed = speed * goldMineCfg.resOutputCfg.resUp
        end

        -- 新技能采集加速
        local Srate=mSkills.getSkillRate(1)
        if Srate > 0 then
            speed = speed + speed * Srate
        end

         -- 新技能载重量
        local Scarryrate=mSkills.getSkillRate(2)

        -- 战争雕像采集加速
        local mStatue  = uobjs.getModel('statue')
        local statuevalue = mStatue.getSkillValue('colloctSpeed') or 0
        if (tonumber(statuevalue) or 0) > 0 then
            speed = speed + speed * statuevalue
        end

        Scarryrate = Scarryrate + (mStatue.getSkillValue('capacityBonus') or 0)

        if type(fleetInfo) == 'table' then
            local pairs = pairs
            local arrayGet = arrayGet

            for k,v in pairs(fleetInfo) do   
                local num = arrayGet(v,2,0)
                local aid = arrayGet(v,1,0)
                if num > 0 then

                    local carryResource = arrayGet(tankCfg,aid..'>carryResource',0) * num
                    carryResource = carryResource + carryResource * addCarryRate
                    carryResource = carryResource + carryResource * Scarryrate
                    resource[rname] = resource[rname] + carryResource
                    
                    local info=activity_setopt(uid,"hardGetRich",{getvalue=1},true)
                    if info~=nil and info[1]>0 then
                        local value = info[1]
                        local et = info[2]
                        local rtime=math.ceil(carryResource/(speed*(1+value) )* 3600)    
                        if ts + rtime <= et then
                            gtime=gtime+rtime
                        else
                            local rttime =et -ts
                            local residue=carryResource-(speed*(1+value)*rttime/3600)
                            local retime =rttime+math.ceil(residue/speed * 3600)
                            gtime=gtime+retime
                        end     
                       
                    else
                        --正常没有活动
                        gtime = gtime + math.ceil(carryResource/speed * 3600)
                    end
                    
                end
            end
        end

        local activeVate
        local tmpVate = speed / originalSpeed 
        if tmpVate > 1 then
            -- 保留两位小数，并减1，这里减1是因为在实际计算资源的时候是按speed+speed*vate算的
            activeVate = math.floor(tmpVate * 100) / 100
            activeVate = activeVate - 1
        end


        return resource,gtime, activeVate
    end

    function self.addCarryRateByAlliance(uid)
        -- 军团技能，加储存量的
        local allianceCarryAdd = 0
        local uobjs = getUserObjs(uid) 
        local mUserinfo = uobjs.getModel('userinfo')
        if mUserinfo.alliance and mUserinfo.alliance > 0 then
            local allAllianceSkills = M_alliance.getAllianceSkills{aid=mUserinfo.alliance}

            local skillLevel = 0
            if type(allAllianceSkills) == 'table' then
                 skillLevel =  tonumber(allAllianceSkills.s5)  or 0
            end

            if type(allAllianceSkills) == 'table' and skillLevel > 0 then
                local allianceSkillCfg = getConfig("allianceSkillCfg")
                allianceCarryAdd = allianceSkillCfg.s5.capacityValue[skillLevel] / 100
            end

            local mTerritory = getModelObjs("aterritory",mUserinfo.alliance,true)
            local territoryCapacityValue = mTerritory.getTerritoryCapacityBuff()
            if territoryCapacityValue then
                allianceCarryAdd = allianceCarryAdd + territoryCapacityValue
            end
        end

        if allianceCarryAdd and allianceCarryAdd > 0 then
            return allianceCarryAdd
        end

        return 0
    end

        -- props_19=34
    function self.takeReward(uid,rewards)
        local uobjs = getUserObjs(uid) 
        local mTech,techLevel,techCfg

        if type(rewards) == 'table' then
            for rewardKey,num in pairs(rewards) do
                local reward = rewardKey:split('_') 
                if type(reward) == 'table' and num > 0 then
                     if reward[1] == 'userinfo' then
                        local model = uobjs.getModel('userinfo')
                        if reward[2] == 'exp' then 
                            techCfg = techCfg or getConfig('tech.t20')
                            mTech = mTech or uobjs.getModel('techs')
                            techLevel = techLevel or mTech.getTechLevel('t20')
                            num = math.floor(num + (techCfg.value[techLevel] or 0) / 100 * num)
                            num = activity_setopt(uid,'luckUp',{name='attackIsland',item='exp',value=num}) or num
                            rewards[rewardKey] = num
                            model.addExp(num) 
                        elseif reward[2] == 'honors' then 
                            model.addHonor(num)
                        else model.addResource({[reward[2]]=num}) end
                    elseif reward[1] == 'props' then
                        local model = uobjs.getModel('bag')
                        model.add(reward[2],num)
                    elseif reward[1] == 'troops' then
                        local model = uobjs.getModel('troops')
                        model.incrTanks(reward[2],num)
                    end
                end
            end
        end
    end

    -- 格式化
    function self.formatReward(rewards,num)
        local format = {userinfo='u',props='p'}
        local formatReward = {u={},p={},o={}}
        if type(rewards) == 'table' then
            for reward,num in pairs(rewards) do
                reward = reward:split('_') 
                local key = format[reward[1]] or 'o'
                formatReward[key] = {[reward[2]]=num}                
            end
        end

        return formatReward
    end

    -- 战斗荣誉
    function self.getBattleReputation(winReputation,LoseReputation)
        local diff = (LoseReputation - winReputation + 200) 
        if diff > 400 then diff = 400 end
        if diff < 0 then diff = 0 end

        local reputation =  math.floor(diff * 0.07) or 0
        return reputation
    end

    -- 获取的道具
    function self.getBattleProp()
        setRandSeed()
        local randNum = rand(1,100)
        
        local rate = 30
        rate = activity_setopt(self.attacker,'luckUp',{name='attackIsland',item='propRate',value=rate}) or rate

        if randNum > rate then
            return false
        end
        
        local propReward = {
            p21 = 100,
            p22 = 100,
            p23 = 100,
            p24 = 100,
            p25 = 100,
            p26 = 55,
            p27 = 55,
            p28 = 55,
            p29 = 55,
            p30 = 55,
            p19 = 20,
            p20 = 5,
            p6= 40,
            p7= 40,
            p8= 40,
            p9= 40,
            p10 = 40,
        }

        local count = 0
        local seed = {}
        for k,v in pairs(propReward) do
            count = count + v
            for i=1,v do
                table.insert(seed,k)
            end
        end
  
        randNum = rand(1,count)
        if seed[randNum] then
            self.receiveProps = true
            local pname = 'props_'..seed[randNum]
            regActionLogs(self.attacker,3,{action=1,item=pname,value=1,params={islandType=self.islandType}})
            return pname , 1
        end

        return false
    end

    -- 协防部队到达基地
    function self.helpTroopsArrive(hUid,hName,troops,uid,cronId,htroops)
        local uobjs = getUserObjs(uid)
        local mTroop = uobjs.getModel('troops')
        local mUserinfo =uobjs.getModel('userinfo')
        local stats     =mUserinfo.flags.sadf or 1
        return mTroop.setHDefenceStatus(cronId,1,hUid,hName,stats,htroops) , mTroop.helpdefense
    end

    -- params table tanks 坦克信息 {a10001=10}
    function self.getRankPointByTanks(tanks)
        local point = 0
        local tankCfg = getConfig('tank')
        if type(tanks)=='table' and next(tanks)  then
            for k,v in pairs(tanks) do
                if tankCfg[k] and tankCfg[k].point and v > 0 then
                    point = point + tankCfg[k].point * v
                end
            end
        end
        return point
    end

    -- 获取叛军对应的军功点数
    function self.getRebelRankPoint(rebelLv,tanks,uid)
        local point = 0
        local rebelCfg = getConfig("rebelCfg")
        if type(tanks)=='table' and next(tanks)  then
            for k,v in pairs(tanks) do
                point = point + rebelCfg.troops.tankPoint[rebelLv] * v
            end
        end
        
        -- 圣诞大作战（2015）
        if point > 0 then
            local christRate=activity_setopt(uid,"christmasfight",{getBrp=1},true)
            if christRate ~= nil and christRate > 0 then
                point = point + math.floor(point * christRate)
            end
        end
        
        return point
    end

    -- 增加玩家军功
    function self.addUserRankPoint(uid,point,hero)
        local uobjs = getUserObjs(uid)
        local mUserinfo = uobjs.getModel('userinfo') 
        local mHero     = uobjs.getModel('hero')
        mHero.refreshFeat("t5",hero,point)           
        mUserinfo.addRankPoint(point)

        activity_setopt(uid,"christmasfight",{addBrp=point},true)

         
         if mUserinfo.alliance>0 then
            local mAtmember = uobjs.getModel('atmember')
            mAtmember.uptask({act=4,num=point,aid=mUserinfo.alliance})
         end
         
    end

    -- params table tanks 坦克信息 {a10001=10}
    function self.setUserRankPointByTanks(uid,tanks,hero,tarUid)

        local point = self.getRankPointByTanks(tanks)

        -- 防止刷军工限制，有一方等级小于10级 并且等级差大于30 战斗不加军功
        local uobjs = getUserObjs(uid)
        local mUserinfo = uobjs.getModel("userinfo")

        local duobjs = getUserObjs(tarUid)
        local dUserinfo = duobjs.getModel("userinfo")
        local isForbid = dUserinfo.level<15 and mUserinfo.level > 25
        if isForbid then point = 0 end

        local opoint=point
        -- 摧枯拉朽活动
        activity_setopt(uid,"cuikulaxiu",{point=point},true,0)
        -- 万圣节驱鬼大战
        local diffGhostRep = activity_setopt(uid,"ghostWars",{type='addReputation',reputation=point},false,0)
        point = point + diffGhostRep

        -- 圣诞大作战（2015）
        if opoint > 0 then
            local christRate=activity_setopt(uid,"christmasfight",{getBrp=1},true)
            if christRate ~= nil and christRate > 0 then
                point = point + math.floor(opoint * christRate)
            end
        end

        if point > 0 then
           self.addUserRankPoint(uid,point,hero)
        end

        return point
    end



    -- 抢夺异星矿山玩家的资源
    function self.robAlienMineResource(userFleetInfo)
        local robRes = {}
        local clientShowRes = {u={}}
        local rate = getConfig("alienMineCfg.robRate")

        if type(userFleetInfo) == 'table' then
            for k,v in pairs(userFleetInfo.res) do
                local resource = math.floor((tonumber(v) or 0) * rate)
                if resource > 0 then
                    robRes[k] = resource
                    clientShowRes.u[k]=resource
                    userFleetInfo.res[k] = math.floor(tonumber(v) - resource)
                end
            end
        end

        return robRes,clientShowRes
    end

    -- 部队信息按坦克汇总
    function self.getTankInfo(troopInfo)
        local tankinfo={}
        if type(troopInfo) == 'table' then
            for k,v in pairs(troopInfo) do
                if type(v)=='table' and next(v) then
                    tankinfo[v[1]]  =(tankinfo[v[1]] or 0) +v[2]
                end
            end
        end

        return tankinfo
    end

    --损失繁荣度
    function self.loseBoom( defenser, nRate, rateadd)
        local duobjs = getUserObjs(defenser)
        local mBoom = duobjs.getModel('boom')
        local orginal_boom = mBoom.boom
        
        mBoom.decBoom(nRate, rateadd)
        self.defboom = orginal_boom - mBoom.boom
	end
	
    function self.setKfkLog(mTroop,dietroops,cronId)
        -- kafkaLog
        local storeTroops,storeDieTroops = mTroop.getStoreTroopsByFleet(dietroops)
        regKfkLogs(mTroop.uid,'tankChange',{
                addition={
                    {desc="战斗地点",value="野外"},
                    {desc="id", value=cronId},
                    {desc="阵亡",value=dietroops},
                    {desc="修理场",value=storeDieTroops},
                    {desc="留存",value=storeTroops},
                    {desc="目标",value=self.place},
                }
            }
        ) 
    end

    function self.setKfkLog(mTroop,dietroops,cronId,log)
        -- kafkaLog
        local storeTroops,storeDieTroops = mTroop.getStoreTroopsByFleet(dietroops)
        local addition={
            {desc="战斗地点",value="野外"},
            {desc="id", value=cronId},
            {desc="阵亡",value=dietroops},
            {desc="修理场",value=storeDieTroops},
            {desc="留存",value=storeTroops},
            {desc="目标",value=self.place},
        }

        if log then
            table.insert(addition,{desc="log",value=log})
        end

        regKfkLogs(mTroop.uid,'tankChange',{addition = addition})
    end


    --战报来源
    function self.fromReport( uname )
        -- body
        local ret = 0

        local redis = getRedis()
        local key = "z"..getZoneId()..".radarSearch." .. self.attacker
        local radarData =  redis:get(key)

        radarData = radarData and json.decode(radarData) or {}
        --雷达搜索, 防守方才需要
        if uname == self.defenserName and self.place and self.place[1] and self.place[2] and radarData[self.defenserName] and 
            tonumber(radarData[self.defenserName].x) == self.place[1] and tonumber(radarData[self.defenserName].y) == self.place[2] then
            -- 第一次攻击发送
            ret = 1
        end

        --销毁缓存
        if radarData[self.defenserName] then    
            radarData[self.defenserName] = nil
            redis:set(key, json.encode(radarData))
        end
        
        return ret
    end


    ----------------------------------------------------------------------------------------------------
    -- 战斗损毁的坦克,有的需要修理,有的不需要修理,战损比例也不一样,把方法拆分
    -- 没有改以前的处理逻辑,怕出问题,以后新加战斗的坦克处理都在下边加方法
    ----------------------------------------------------------------------------------------------------

    -- 统计损毁的坦克(NPC战损直接用这个方法)
    function self.countDamageTroops(fleetInfo,invalidFleetInfo)
        -- 阵亡坦克
        local dietroops,troops = {}
        -- 存活坦克
        local troops = {}
        -- 战报优化客户需要的数据格式：{tid-该位置参战数量-剩余数量，tid-该位置参战数量-剩余数量}
        local detailForClient = {}

        for k,v in pairs(fleetInfo) do
            if next(v) and v[2] > 0 then
                if invalidFleetInfo[k].num < 0 or invalidFleetInfo[k].num > v[2] then
                    tankError(string.format("invalid FleetInfo: %s,%s,%s", tostring(k), tostring(v[2]), tostring(invalidFleetInfo[k].num)))
                end

                local tankId = v[1]
                local dieNum = v[2] - invalidFleetInfo[k].num
                if dieNum > 0 then
                    dietroops[tankId]= (dietroops[tankId] or 0) + dieNum
                end

                table.insert(troops,{tankId,invalidFleetInfo[k].num})
                detailForClient[k] = string.format("%s-%s-%s",v[1],v[2],dieNum)
            else
                table.insert(troops,{})
                detailForClient[k] = ""
            end
        end

        return dietroops,troops,detailForClient
    end

    -- 按损毁率获取无法修复的坦克,玩家真正损失的就是这一部分的坦克
    function self.getDestroyTanks(dietroops,destroyRate)
        local destroyTanks = {}
        
        if destroyRate < 0 then destroyRate = 0 end
        for k,v in pairs(dietroops) do
            destroyTanks[k] = (destroyTanks[k] or 0) + math.floor(v * destroyRate)
        end

        return destroyTanks
    end

    -- 按修复率获取可以修得的坦克
    -- 玩家会有相关技能影响修复
    function self.getRepairTanks(uid,dietroops,repairRate)
        local repairTanks = {}
        local destroyTanks = {}

        if repairRate > 1 then repairRate = 1 end

        local Srate = uid and self.getSkillRepairRate(uid) or 0
        for k,v in pairs(dietroops) do
            local repairNum = math.ceil(v * repairRate)
            local count=math.floor( (v-repairNum)*Srate)
            if count>v-repairNum then
                count=v-repairNum
            end
            repairNum=repairNum+count

            assert(repairNum<=v)
            repairTanks[k] = (repairTanks[k] or 0) + repairNum
            destroyTanks[k] = v - repairNum
        end

        for k,v in pairs(dietroops) do
            assert((repairTanks[k] + destroyTanks[k]) == v,string.format("repair:%d,destroy:%d,total:%d",repairTanks[k],destroyTanks[k],v))
        end

        return repairTanks, destroyTanks
    end

    -- 获取玩家技能对坦克修复影响的比率
    function self.getSkillRepairRate(uid)
        local uobjs = getUserObjs(uid)
        local mSkills = uobjs.getModel('skills')
        local srate=mSkills.getSkillRate(5)

        return srate or 0
    end    

    -- 自动修复损毁的坦克
    function self.autoRepairTanks(uid,repairTanks)
        local uobjs = getUserObjs(uid)
        local mTroop = uobjs.getModel('troops')

        for k,v in pairs(repairTanks) do
            mTroop.incrTanks(k,v)
        end

        regEventBeforeSave(uid,'e1')
    end

    -- 损毁的坦克去修理厂
    function self.damageTanksToFactory(uid,repairTanks)
        local uobjs = getUserObjs(uid)
        local mTroop = uobjs.getModel('troops')

        for k,v in pairs(repairTanks) do
            mTroop.incrDamagedTanks(k,v)
        end

        regEventBeforeSave(uid,'e1')
    end

    ----------------------------------------------------------------------------------------------------

    -- 叛军战斗损失部队处理
    function self.rebelBattleDamageTroops(uid,fleetInfo,invalidFleetInfo)
        local dietroops,troops,detailForClient = self.countDamageTroops(fleetInfo,invalidFleetInfo)

        local rebelCfg = getConfig("rebelCfg")
        local repairTanks,destroyTanks = self.getRepairTanks(uid,dietroops,1-rebelCfg.damageRatio)

        -- 损失的坦克自动修复
        self.autoRepairTanks(uid,repairTanks)
        activity_setopt(uid,'monsterComeback',{destroyTanks=destroyTanks})
        
        return dietroops,troops,detailForClient
    end

    -- 领海战损失部队处理
    -- 没有任何损失,一部分部队需要修理，其它直接修复回家
    function self.seaWarBattleDamageTroops(uid,fleetInfo,invalidFleetInfo)
        local dietroops,troops,detailForClient = self.countDamageTroops(fleetInfo,invalidFleetInfo)
        local repairTanks,destroyTanks = self.getRepairTanks(nil,dietroops,1-getConfig('allianceDomainWar').saveValue)

        self.autoRepairTanks(uid,repairTanks)
        self.damageTanksToFactory(uid,destroyTanks)

        return dietroops,troops,detailForClient
    end

    function self.getFleetCapacity(uid,fleetInfo)
        local pairs = pairs
        local arrayGet = arrayGet
        local addCarryRate = self.addCarryRateByAlliance(uid)
        local tankCfg = getConfig('tank')

        local uobjs = getUserObjs(uid)
        local Scarryrate=uobjs.getModel('skills').getSkillRate(2)
        Scarryrate = Scarryrate + (uobjs.getModel('statue').getSkillValue('capacityBonus') or 0)

        local capacity = 0
        for k,v in pairs(fleetInfo) do   
            local num = arrayGet(v,2,0)
            local aid = arrayGet(v,1,0)
            if num > 0 then
                local carryResource = arrayGet(tankCfg,aid..'>carryResource',0) * num
                carryResource = carryResource + carryResource * addCarryRate
                carryResource = carryResource + carryResource * Scarryrate
                capacity = capacity + carryResource
            end
        end

        return capacity
    end

    -- 设置活动掉落特殊奖励奖励
    function self.setActReward(params)
        local reward = {}
        -- 装扮圣诞树
        if params.aname == 'dresstree' then
            reward = activity_setopt(params.uid,params.aname,{act=params.act,num=params.num,w=params.w})  
        end

        if params.aname == 'dresshat' then
            reward = activity_setopt(params.uid,params.aname,{act=params.act,num=params.num,w=params.w})  
        end
         -- 世界杯-一球成名
        if params.aname=='oneshot' then
            reward = activity_setopt(params.uid,params.aname,{act=params.act,id=params.id})
            if type(reward)=='table' and next(reward) then
                writeLog('uid='..params.uid..'_id='..params.id..'_data='..json.encode(reward),'oneshot')
            end
	    self.receiveProps = true
        end
        -- 三周年--冲破噩梦--炮弹探索
        if params.aname == 'cpem' then
            reward = activity_setopt(params.uid,params.aname,{type=params.type,num=params.num})  
        end

        
        if type(reward)=='table' and next(reward) then
            if type(self.acaward)~='table' then
                self.acaward={}
            end
            
            for k,v in pairs(reward) do
                if type(v)=='table' and next(v) then ---针对一些系统中已处理好的物品类型  如果k是根据活动命名（非系统已处理，保证是个二维的table）也是可以的                  
                    if type(self.acaward[k])~='table' then
                        self.acaward[k] = {}
                    end
                    for vk,val in pairs(v) do
                        self.acaward[k][vk] = (self.acaward[k][vk] or 0) + val
                    end
                else--针对 仅在活动期间的物品
                    self.acaward[k]= (self.acaward[k] or 0) + v
                end         
            end
         end
    end

    function self.setAttackInfoForReport(uid,target)
        local uobjs = getUserObjs(uid)
        local mUserinfo = uobjs.getModel("userinfo")
        self.attacker = uid
        self.attackerName = mUserinfo.nickname
        self.attackerLevel = mUserinfo.level     
        self.attackerPic = mUserinfo.pic--头像
        self.attackerbPic = mUserinfo.bpic--头像框
        self.attackeraPic = mUserinfo.apic--挂件
        self.attackerVip = mUserinfo.showvip() 
        self.attackerFc = mUserinfo.fc
        self.AAName = mUserinfo.alliancename
        self.AttackerPlace = {mUserinfo.mapx,mUserinfo.mapy}

        self.attackerArmorInfo = uobjs.getModel('armor').formatUsedInfoForBattle()
        self.attackerAweaponInfo = uobjs.getModel('alienweapon').formatUsedInfoForBattle()
        self.attackerLandform = getAttackerLandformOfBattle({mUserinfo.mapx,mUserinfo.mapy},target)
    end

    function self.setDefenderInfoForReport(uid,landform)
        local uobjs = getUserObjs(uid)
        local mUserinfo = uobjs.getModel("userinfo")
        self.defenser = uid
        self.defenserName = mUserinfo.nickname
        self.defenserLevel = mUserinfo.level
        self.DAName = mUserinfo.alliancename
        self.defenserVip = mUserinfo.showvip() 
        self.defenserFc = mUserinfo.fc
        self.defenserPic = mUserinfo.pic
        self.defenseraPic = mUserinfo.apic
        self.defenserbPic = mUserinfo.bpic
        self.defenserArmorInfo = uobjs.getModel('armor').formatUsedInfoForBattle()
        self.defenserAweaponInfo = uobjs.getModel('alienweapon').formatUsedInfoForBattle()
        self.defenserLandform = landform
    end
    
    return self
end

