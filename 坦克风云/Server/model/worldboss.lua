function model_worldboss(uid,data)
        -- the new instance
    local self = {
        -- public fields go in the instance table
        uid= uid, 
        info={}, --buff等信息
        point =0, --积分
        auto=0, -- 是否自动攻击
        book=0, -- 是否已预定
        binfo={}, --设置部队镜像和英雄
        attack_at=0, --上一次攻击时间
        buy_at   =0, --上一次购买buff时间
        reward_at   =0, --上一次领奖时间
        updated_at=0,   -- 最近一次更新时间 
    }
    -- body



    function self.bind(data)
        if type(data) ~= 'table' then
            return false
        end
        for k,v in pairs (self) do
            local vType = type(v)
            if vType~="function" then
                if data[k] == nil then return false end
                if vType == 'number' then   
                    self[k] = tonumber(data[k]) or data[k]
                elseif vType == 'table' and type(data[k]) ~= 'table' then                    
                else
                    self[k] = data[k]
                end
            end
        end

        return true
    end


    function self.toArray(format)
        local data = {}
            for k,v in pairs (self) do
                if type(v)~="function" and k~= 'uid' and k~= 'updated_at' then              
                    if format then
                        -- if type(v) == 'table'  then
                        --     if next(v) then data[k] = v end
                        -- elseif v ~= 0 and v~= '0' and v~='' then
                            data[k] = v
                        --end
                    else
                        data[k] = v
                    end
                end
            end

        return data
    end

    -- 获取boss信息
    function self.getBossInfo(bossCfg)
        local data={}
        local redis  = getRedis()
        local weet = getWeeTs()
        local bosskey= "zid."..getZoneId().."worldboss.diehp.ts."..weet
        local landformkey= "zid."..getZoneId().."worldboss.landform.ts."..weet
        local levelkey= "zid."..getZoneId().."worldboss.level.ts."..weet
        local killkey   = "zid."..getZoneId().."worldboss.kill"
        local killtime   = "zid."..getZoneId().."worldboss.lastkill.ts"
        local updatetime   = "zid."..getZoneId().."worldboss.lastupdate.ts"
        -- 获取今天boss的等级
        local expiretime=86400*2

        local level =tonumber(redis:get(levelkey))
        if level==nil then
            local killcount =tonumber(redis:get(killkey))
            if killcount ==nil then
                local killinfo =getFreeData(killkey)
                if killinfo==nil then
                    --setFreeData(killkey,0)
                    redis:set(killkey,0)
                    killcount=0
                else
                    if type(killinfo)=='table' and next(killinfo) then
                        killcount=tonumber(killinfo.info)
                        redis:set(killkey,killcount)
                    end
                end

            end
            level =bossCfg.startLevel+killcount
            local lastkilltime =tonumber(redis:get(killtime)) or 0
            if lastkilltime>0 and level>bossCfg.startLevel then
                local lastupdatetime =tonumber(redis:get(updatetime)) or lastkilltime
                if ((weet-lastkilltime)/86400) > bossCfg.killday then
                    local count =((weet-lastupdatetime)/86400)
                    if count >bossCfg.killday then
                        count=count-bossCfg.killday
                    end
                    for i=1,count do
                        level=level-1
                    end
                    if bossCfg.startLevel>=level then
                        level=bossCfg.startLevel
                    end
                    redis:set(killkey,level-bossCfg.startLevel)
                    getFreeData(killkey)
                    setFreeData(killkey,level-bossCfg.startLevel)
                    redis:set(updatetime,weet)
                    redis:expire(updatetime,expiretime)
                end
            end

            redis:set(levelkey,level)
            redis:expire(levelkey,expiretime)
            
        end
        local landform=redis:get(landformkey)
        if landform==nil then
            setRandSeed()
            landform = rand(1,6)
            redis:set(landformkey,landform)
            redis:expire(landformkey,expiretime)
        end
        local diehp=tonumber(redis:get(bosskey)) or 0
        local tolhp=bossCfg.getBossHp(level)
        return {level,tolhp,diehp,tonumber(landform)}
        
    end

    --攻击boss
    function self.battle(fleetInfo,aheros,boss, equip,plane)
         --  初始化攻击方 
        local attactBossBuff=self.info.b
        local auobjs = getUserObjs(self.uid)         
        local attackFleet = auobjs.getModel('troops')
        local aSequip =auobjs.getModel('sequip')
        local aFleetInfo,aAccessory,aherosInfo = attackFleet.initFleetAttribute(fleetInfo,nil,{hero=aheros,attactBossBuff=attactBossBuff,landform=boss[4], equip=equip,plane=plane})

        local bossCfg = getConfig("bossCfg");
        local baseTroop = {{"a99999",1},{},{},{},{},{}}
        --techs,skills,propSlots,allianceSkills,battleType,params
        local bossFleetInfo = initTankAttribute(baseTroop,nil,nil,nil,nil,nil,{landform=boss[4]})
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
        report.se = {0, equip}
        return  report,deBossHp
    end



    -- 干死boss的血量相加
    function self.addBossHp(point)
        local weet = getWeeTs()
        local bosskey= "zid."..getZoneId().."worldboss.diehp.ts."..weet
        local redis  = getRedis()
        local hp=tonumber(redis:incrby(bosskey,point))
        redis:expire(bosskey,172800)    
        return hp,hp-point

    end

    -- 干死boss 等级+1
    function self.killBoss()
        local weet = getWeeTs()
        local killkey   = "zid."..getZoneId().."worldboss.kill"
        local userkillkey= "zid."..getZoneId().."worldboss.userkill.ts."..weet
        local killtime   = "zid."..getZoneId().."worldboss.lastkill.ts"
        local redis  = getRedis()
        local killcout =tonumber(redis:incr(killkey)) or 0
        local info =getFreeData(killkey)
        if info~=nil and info.info~=nil then
            if killcout<tonumber(info.info) then
                killcout=redis:incrby(killkey,tonumber(info.info))
            end
        end
        setFreeData(killkey,killcout)
        local uobjs = getUserObjs(self.uid)  
        local mUserinfo = uobjs.getModel('userinfo')
        redis:set(userkillkey,mUserinfo.nickname)
        redis:set(killtime,weet)
        redis:expire(userkillkey,172800)
        self.info.kc=(self.info.kc or 0)+1 
        return true
    end

    function self.getUserKill()
        local weet = getWeeTs()
        local userkillkey= "zid."..getZoneId().."worldboss.userkill.ts."..weet
        local redis  = getRedis()
        return redis:get(userkillkey)
    end

    -- 排行榜
    function self.addAttackBossRank(uid,point,ts)
        local weet = getWeeTs()
        local ret =setActiveRanking(uid,point,"worldboss.rank",10,weet,weet+86400)
        return ret
    end

    local function getBookQueueCacheKey()
        return "zid."..getZoneId()..".worldboss.bookqueue." .. getWeeTs()
    end

    -- cron.lua 中有修复对列的方法，如果book的值1(代表预定)有变动，该文件也要改
    function self.bookAutoAttack(value)
        if value == 0 and self.book ~= 0 then
            self.delBookQueue()
        end

        self.book = value
    end

    function self.checkAutoAttack()
        return self.book == 1
    end

    function self.addBookQueue()
        local redis=getRedis()
        local cachekey=getBookQueueCacheKey()
        redis:hset(cachekey,self.uid,getClientTs())
        redis:expire(cachekey,86400)
    end

    function self.delBookQueue()
        getRedis():hdel(getBookQueueCacheKey(),self.uid)
    end

    return self

end