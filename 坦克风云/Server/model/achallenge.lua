-- 军团关卡 -----------------
-- 2014-03-01
function model_achallenge(uid)
    local self = {
        uid = uid,
    }
    
    ------------------------------------------------------------------
    -- 计算随机概率，去重
    function self.getRandBySeed(seedTable,valueN,array,randMaxN)
        array = array or {}

        if type(seedTable) == 'table' then   
            if not randMaxN then
                for _,v in ipairs(seedTable) do
                  randMaxN = (randMaxN or 0) + v 
                end
            end

            local randNum = rand(1,randMaxN)
            
            local i = 0
            for k,v in ipairs(seedTable) do         
                i = (seedTable[k-1] or 0 ) + i
               if randNum > i and randNum <= v + i then
                  table.insert(array,k)                  
                  if not valueN or valueN <= 1 then                      
                      return array
                  else
                      table.remove(seedTable,k)
                      valueN = valueN - 1
                      randMaxN = randMaxN - v
                      return self.getRandBySeed(seedTable,valueN,array,randMaxN)
                  end 
                end
            end
        end

        return array
    end

    function self.getRewardByRandKey(rewardKey,baseReward)
        local reward = {}
        if type(baseReward) == 'table' and #baseReward > 0 then      
            for _,v in ipairs(rewardKey) do     
                reward[baseReward[v][1]] = baseReward[v][2]
                table.remove(baseReward,v)
            end
        end

        return reward
    end

    function self.getChallengeRandReward(cid)
        setRandSeed()        
        local reward = {}

        local allianceChallengeCfg = getConfig("allianceChallengeCfg")
        if allianceChallengeCfg[cid] and allianceChallengeCfg[cid].propbonus then            
            local propbonus = copyTable(allianceChallengeCfg[cid].propbonus)   -- propbonus={{60,30,10},{50,30,20},{{"p19",1},{"p20",2},{"p20",2}}}
            local propN =  #propbonus[1]

            if propN > 1 then
                propN = arrayGet(self.getRandBySeed(propbonus[1]),1)
            end
                        
            local rewardKey = self.getRandBySeed(propbonus[2],propN)
            reward = self.getRewardByRandKey(rewardKey,propbonus[3])
        end

        return reward
    end

    -------------- 关卡战斗
    -- sid 关卡id
    -- fleetInfo 军队属性
    function self.battle(fleetInfo,defFleetInfo,challengeCfg,propsConsume,hero,equip)
        local defSkill = challengeCfg.skill
        local defTech = challengeCfg.tech
        local defAllianceTech = challengeCfg.alliance_tech
        local defAttUp = challengeCfg.attributeUp
        local defLevel = challengeCfg.level -- 关卡等级
        local defName = 0 -- 关卡名称

        local uobjs = getUserObjs(self.uid)
        local aUserinfo = uobjs.getModel('userinfo')
        local attackFleet = uobjs.getModel('troops')
        local aSequip = uobjs.getModel('sequip')

        local aFleetInfo,_,aheros = attackFleet.initFleetAttribute(fleetInfo,2,{hero=hero,equip=equip})
        local dFleetInfo = self.initDefFleetAttribute(defFleetInfo,defSkill,defTech,defAttUp,defAllianceTech)
        
        require "lib.battle"
        
        local report,aInavlidFleet, dInvalidFleet = {star=0}        
        local isWin = -1

        report.d, isWin, aInavlidFleet, dInvalidFleet = battle(aFleetInfo,dFleetInfo,0,propsConsume)
        report.t = {defFleetInfo,fleetInfo}
        report.p = {{defName,defLevel,0},{aUserinfo.nickname,aUserinfo.level,1}}
        report.ocean = challengeCfg.ocean
        
        if aheros and next(aheros) then report.h = {{},aheros[1]} end
        
        report.se = {0, aSequip.formEquip(equip)}
        
        if isWin == 1 then
            report.star = self.setStar(fleetInfo,aInavlidFleet)   -- 关卡评星，解锁            
        end
        
        return report,dInvalidFleet,report.star,isWin
    end

    -- dieTroops 已经干死的部队
    function self.getCurrentChallengeTroops(challengeTroops,dieTroops)
        local troops = {}
        if type(challengeTroops) == 'table' then
            for k,v in pairs(challengeTroops) do
                troops[k] = {v[1],v[2]}
                if dieTroops and type(dieTroops[k]) == 'table' and next(dieTroops[k]) then            
                    local num = v[2] and (v[2] - (tonumber(dieTroops[k][2]) or 0)) or 0                    
                    if v[1] == dieTroops[k][1] then
                        if num > 0 then
                          troops[k][1],troops[k][2] = v[1],num
                      else
                          troops[k] = {}
                      end
                    end
                end
            end
        end 

        return troops
    end

    -- 关卡是否已解锁 
    function self.checkUnlock(sid,maxUnlockedSid)
        if sid == 1 then return true end        
        return sid <= (tonumber(maxUnlockedSid) or 1)
    end

    -- 设置过关指数星    
    ---------- 规则：
    -- 星级判定以战斗力为基准
    -- 剩余30%以下为一星
    -- 剩余30%-69%为二星
    -- 70%以上为三星
    ---------- 参数：
    -- fleetinfo 攻打关卡的兵力
    -- 攻打关卡后的兵力    
    function self.setStar(fleetInfo,aInavlidFleet)        
        local totalFighting, invalidFighting = 0, 0
        local star = 0
        local tankCfg = getConfig('tank')
        
        if type(fleetInfo) == 'table' and type(aInavlidFleet) == 'table' then
            for k,v in pairs(fleetInfo) do
                if next(v) then                    
                    totalFighting = totalFighting + tankCfg[v[1]].Fighting * (v[2] or  0)
                    invalidFighting = invalidFighting + tankCfg[v[1]].Fighting * (aInavlidFleet[k].num or  0)
                end
            end
        end

        -- 损失的战力
        local damageFighting = totalFighting - invalidFighting
        if totalFighting > 0 then
            local damageRate = 1 - damageFighting/totalFighting
            
            if damageRate >= 0.7 then
                star = 3
            elseif damageRate >= 0.3 then
                star= 2
            else
                star= 1
            end
        end

        return star
    end

    -- 初始化军队属性
    function self.initDefFleetAttribute(tanks,skills,techs,defAttUp,defallianceTech)
        local inittanks = initTankAttribute(tanks,techs,skills,nil,defallianceTech,4,{acAttributeUp=defAttUp})
        return inittanks
    end

    ---------兵损失量--------------
    function self.damageTroops(fleetInfo,invalidFleetInfo)
        local troops = {}

        for k,v in pairs(fleetInfo) do           
            if next(v) then
                local dieNum = v[2] - invalidFleetInfo[k].num
                table.insert(troops,{v[1],dieNum})
            else
                table.insert(troops,{})
            end
        end

        return troops
    end

    -- 根据奖励与杀怪数量计算奖励
    function self.getBattleReward(reward,dieTroops)
        local r = {}
        local dieNum = 0
        
        if type(dieTroops) == 'table' then
            for _,v in ipairs(dieTroops) do
                dieNum = dieNum + (v[2] or 0)
            end
        end

        if type(reward) == 'table' then
            for k,v in pairs(reward) do
                if k == 'userinfo_exp' then
                    r[k] = v * dieNum
                else
                    r[k] = v
                end
            end
        end

        return r
    end

    -- 格式化奖励
    function self.takeReward(reward)
        local award = {u={},p={},o={}}
        local uobjs = getUserObjs(self.uid)
        local mUserinfo = uobjs.getModel('userinfo')
        local mTech,techLevel,mBag

        local serverToClient = function(type)
            local tmpData = type:split("_")
            local tmpType = tmpData[2]
            local tmpPrefix = string.sub(type, 1, 1)
            if tmpPrefix == 't' then tmpPrefix = 'o' end
            if tmpPrefix == 'a' then tmpPrefix = 'e' end
            return tmpPrefix, tmpType
        end

        if type(reward) == 'table' then
            setRandSeed()
            for k,v in pairs(reward) do
                if k =='userinfo_exp' then
                    local techCfg = techCfg or getConfig('tech.t20')
                    mTech = mTech or uobjs.getModel('techs')
                    techLevel = techLevel or mTech.getTechLevel('t20')
                    v = math.floor(v + (techCfg.value[techLevel] or 0) / 100 * v)
                    reward[k] = v
                    -- 荣誉
                elseif k=='userinfo_honors' then
                    --mUserinfo.addHonor(v)
                    reward[k] = v
                end
                --client
                local tmpPrefix,tmpType = serverToClient(k)
                if not award[tmpPrefix] then
                    award[tmpPrefix] = {}
                end
                if award[tmpPrefix][tmpType] then
                    award[tmpPrefix][tmpType] = reward[k] + award[tmpPrefix][tmpType]
                else
                    award[tmpPrefix][tmpType] = reward[k]
                end
            end
        end
        if not takeReward(uid, reward) then
            return false
        end
        return award
    end


    -- 副本boss

    function self.getBossInfo(bossCfg,aid)
        local data={}
        local redis  = getRedis()
        local weet = getWeeTs()
        local bosskey= "zid."..getZoneId().."allianceboss."..aid.."diehp.ts."..weet
        local levelkey= "zid."..getZoneId().."allianceboss."..aid..".level.ts."..weet
        local killkey   = "zid."..getZoneId().."allianceboss."..aid..".kill"..weet
        local killtime   = "zid."..getZoneId().."allianceboss."..aid..".lastkill.ts"..weet
        -- 获取今天boss的等级
        local expiretime=86400*2

        local level =tonumber(redis:get(levelkey))
        if level==nil then
            level =bossCfg.startLevel
            redis:set(levelkey,level)
            redis:expire(levelkey,expiretime)
            
        end
        local diets=tonumber(redis:get(killtime)) or 0
        local killcount =tonumber(redis:get(killkey))
        if killcount ==nil then
               killcount=0
        end
        local diehp=tonumber(redis:get(bosskey)) or 0
        local tolhp=bossCfg.getBossHp(level)
        if diehp>=tolhp then
            local ts =getClientTs()
            if diets==0 then
                redis:set(killtime,ts)
                redis:expire(killtime,172800)
                diets=ts
            end
            if diets>0 and diets+bossCfg.exprie<=ts then
                diehp=0
                redis:del(killtime)
                redis:del(bosskey)
                level =bossCfg.startLevel+killcount
                tolhp=bossCfg.getBossHp(level)
                redis:set(levelkey,level)
                redis:expire(levelkey,expiretime)
            end
        end
        return {level,tolhp,diehp,diets},killcount
    end

    --攻击boss
    function self.battleBoss(fleetInfo,aheros,boss,equip)
         --  初始化攻击方 
        local attactBossBuff=self.info.b
        local auobjs = getUserObjs(self.uid)         
        local attackFleet = auobjs.getModel('troops')
        local aSequip = auobjs.getModel('sequip')
        local aBadge = auobjs.getModel('badge')
        local aFleetInfo,aAccessory,aherosInfo = attackFleet.initFleetAttribute(fleetInfo,nil,{hero=aheros,attactBossBuff=attactBossBuff,equip=equip})

        local bossCfg = getConfig("alliancebossCfg");
        local baseTroop = {{"a99999",1},{},{},{},{},{}}
        --techs,skills,propSlots,allianceSkills,battleType,params
        local bossFleetInfo = initTankAttribute(baseTroop,nil,nil,nil,nil,nil,{})
        local bossActiveHp = boss[2]- boss[3] -- boss当前血量

        bossFleetInfo[1].anticrit = bossCfg.getBossArmor(boss[1])
        bossFleetInfo[1].evade = bossCfg.getBossDodge(boss[1])
        bossFleetInfo[1].armor = bossCfg.getBossDefence(boss[1])
        bossFleetInfo[1].maxhp = bossActiveHp
        bossFleetInfo[1].hp = bossActiveHp
        bossFleetInfo[1].bossHp = boss[2]   -- 总血量
        bossFleetInfo[1].boss = 1

        local copyTable = copyTable
        for i=2,6 do
            bossFleetInfo[i] = copyTable(bossFleetInfo[1])
        end

        require "lib.battle"
        local report={}
        local deBossHp={}
        report.d,deBossHp = battle(aFleetInfo,bossFleetInfo,0,nil,{boss=true,diePaoTou=bossCfg.paotou,})
        report.t = {baseTroop,fleetInfo}
        report.h = {{},aherosInfo[1]}
        report.se = {0, aSequip.formEquip(equip)}
        report.badge = {{0,0,0,0,0,0}, aBadge.formBadge()} --徽章数据
        
        return  report,deBossHp
    end

     -- 干死boss的血量相加
    function self.addBossHp(aid,point)
        local weet = getWeeTs()
        local bosskey= "zid."..getZoneId().."allianceboss."..aid.."diehp.ts."..weet
        local redis  = getRedis()
        local hp=tonumber(redis:incrby(bosskey,point))
        redis:expire(bosskey,172800)    
        return hp,hp-point

    end
    -- 干死boss 等级+1
    function self.killBoss(aid)
        local weet = getWeeTs()
        local killkey   = "zid."..getZoneId().."allianceboss."..aid..".kill"..weet
        local killtime   = "zid."..getZoneId().."allianceboss."..aid..".lastkill.ts"..weet
        local redis  = getRedis()
        local killcout =tonumber(redis:incr(killkey)) or 0
        local ts =getClientTs()
        redis:set(killtime,ts)
        redis:expire(killkey,172800)
        redis:expire(killtime,172800)
        return true
    end

    function self.getBossCount(aid)

        local weet = getWeeTs()
        local killkey   = "zid."..getZoneId().."allianceboss."..aid..".kill"..weet
        local redis  = getRedis()
        local killcout =tonumber(redis:get(killkey)) or 0
        return killcout
    end
    --------------------------------------------------------------------------------------------------------------
    
    if type(self.info) ~= 'table' then
        self.info = {}
    end

    return self
end	

