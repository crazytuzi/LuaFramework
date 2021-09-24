-- 
-- desc:指挥官徽章
-- user:chenyunhe
--

function model_badge(uid,data)
    local self = {
        uid=uid,
        info={},-- 徽章背包
        used={0,0,0,0,0,0},-- 装备的
        fragment={},--徽章碎片
        exp=0,--经验池
        challenge={data={},buy=0,t=0,n=0},-- 副本 data关卡数据 buy购买次数 t刷新时间 可攻打次数
        material={},-- 突破材料 
        expPro = {},-- 经验道具
        initate = 0,-- 初始是否已赠送徽章
        buytimes = 0,-- 购买挑战总次数
        battletimes = 0, -- 副本挑战总次数
        updated_at=0,   
    }

    local badgeServerCfg = copyTable(getConfig("badge"))
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
                else
                    self[k] = data[k]
                end
            end
        end

        -- 初始化副本、活动副本数据
        self.initchallenge()
        self.initatebadge()

        return true
    end

    function self.toArray(format)
        local data = {}
            for k,v in pairs (self) do
                if type(v)~="function" and k~= 'uid' and k~= 'updated_at' then              
                    if format then
                        data[k] = v
                    else
                        data[k] = v
                    end
                end
            end

        return data
    end

    -- 初始赠送玩家一枚徽章
    function self.initatebadge()
        if self.initate==0 then
            takeReward(self.uid,badgeServerCfg.main.initate)
            self.initate = 1
        end
    end

    -- 获取背包徽章数量
    function self.getInfoCount()     
        local count = 0
        if type(self.info)=='table' and next(self.info)then
             count=table.length(self.info)
        end

       return count
    end

    -- 删除背包中的徽章 
    -- id：服务器创建的唯一id
    function self.del(id)
        -- body
        if type(self.info)=='table' then
            if type(self.info[id])=='table' and next(self.info[id]) then
                self.info[id]=nil
                return true
            end
        end
        return false
    end
    
    -- 添加徽章
    -- cid:配置cid
    -- num:数量
    -- level:强化等级
    function self.add(cid,num,level)
        level = level and level or 1
        local flag = true
        local ret = 0
        local idtab = {}

        if type(badgeServerCfg['itemList'][cid]) ~= 'table' then
            ret = -120
            flag = false
            return flag,ret,idtab
        end

        if type(self.info)~='table' then
            self.info = {}
        end

        -- 判断背包数量
        if self.getInfoCount()+num > badgeServerCfg['main'].storageLimit then
            ret = -30010
            flag=false
            return flag,ret,idtab
        end

        local infoLen = table.length(self.info)
        for i=1,num do
            local newkey = self.createId(infoLen)
            self.info[newkey] = {cid,level,0}-- 配置编号 等级 突破次数
            idtab[newkey] = 1
            infoLen = infoLen + 1
        end
        
        regKfkLogs(self.uid,'badge',{
                addition={
                    {desc="获得徽章",value=num},
                    {desc="id",value=cid},
                }
            }
        ) 

        return flag,ret,idtab   
    end

    -- 创建徽章id
    function self.createId(infoLen)
        infoLen = infoLen or 1
        local key = string.sub(os.time(),-3)
        local hid = 't'..key
        if type(self.info[hid]) =='table' then
            hid = hid .. infoLen   
            infoLen = infoLen + 1
            if self.info[hid] then
                return self.createId(infoLen)    
            end
        end
        return hid,infoLen
    end

    --获取徽章在配置文件中的id
    function self.getcid(hid)
        local  cid = nil
        local  info = nil
        if type(self.info[hid])=='table' then
            cid = self.info[hid][1]
            info =self.info[hid]
        end
        return cid,info
    end

    -- 增加经验
    function self.addExp(exp)
        if exp > 0 then
            self.exp = self.exp + math.floor(exp)
        end

        return true
    end

    -- 使用经验
    function self.useExp(exp)
        if exp > 0 then
            if self.exp >= exp then
                self.exp = self.exp - exp
                return self.exp
            end
        end

        return false
    end

    -- 增加碎片
    -- id
    function self.addFragment(id,num)
        if not id or num<0 then
            return false
        end

        if type(badgeServerCfg.fragmentList[id])~='table' then
            return false
        end

        if type(self.fragment)~='table' then
            self.fragment = {}
        end

        self.fragment[id] = (self.fragment[id] or 0) + num
        return true
    end

    -- 使用碎片
    function self.useFragment(id,num)
        if (self.fragment[id] or 0)<num or num<0 then
            return false
        end

        self.fragment[id] = self.fragment[id] - num
        return true
    end

    -- 增加材料
    function self.addMaterial(id,num)
        if not table.contains(badgeServerCfg.main.gadget,id) or num<0 then
            return false
        end

        if type(self.material)~='table' then
            self.material = {}
        end

        self.material[id] = (self.material[id] or 0) + num
        return true
    end

    -- 使用材料
    function self.useMaterial(id,num)
        if (self.material[id] or 0)<num or num<0 then
            return false
        end

        self.material[id] = self.material[id] - num
        return true
    end

    -- 增加经验道具
    function self.addExpPro(id,num)
        if not badgeServerCfg.main.expItem[id] or num<0 then
            return false
        end

        self.expPro[id] = (self.expPro[id] or 0) + num
        return true
    end

    -- 使用经验道具
    function self.useExpPro(id,num)
        local expItem = badgeServerCfg.main.expItem
        if not expItem[id] or num<0 or (self.expPro[id] or 0)<num then
            return false
        end

        self.expPro[id] = self.expPro[id] - num
        local exp = expItem[id] * num
        self.addExp(exp)

        return true,exp
    end

    -- 初始化副本数据
    function self.initchallenge()
        if moduleIsEnabled("badge") ~= 1 then
            return self.challenge
        end
      
        local ts = getClientTs()
        local weets = getWeeTs()
        local weekday = tonumber(getDateByTimeZone(ts,"%w"))
        if weekday==0 then
            weekday=7
        end
        
        local index = 0
        for k,v in pairs(badgeServerCfg.main.week) do
            if weekday>=v[1] and weekday<=v[2] then
                index = k
                break
            end
        end

        if index>0 then
            if type(self.challenge.data['c'..index])~='table' then
                self.challenge.data['c'..index] = {}
                for k,v in pairs(badgeServerCfg.challenge[index]) do
                    table.insert(self.challenge.data['c'..index],0)
                end
            end   
        end

        if (self.challenge.t or 0) ~= weets then
            self.challenge.buy = 0 -- 购买次数
            self.challenge.n = badgeServerCfg.main.freeNum -- 每日重置次数
            self.challenge.t = weets -- 重置时间标识
        end
        
        -- 初始化活动副本数据
        activity_setopt(self.uid,'badgechallenge',{schallenge=badgeServerCfg.schallenge})

        return self.challenge
    end

    -- 检测当天可否可以挑战关卡
    function self.checkopen(cid)
        local ts = getClientTs()
        local weets = getWeeTs()
        local weekday = tonumber(getDateByTimeZone(ts,"%w"))
        if weekday==0 then
            weekday=7
        end
        
        local index = 0
        for k,v in pairs(badgeServerCfg.main.week) do
            if weekday>=v[1] and weekday<=v[2] then
                index = k
                break
            end
        end

        if index==0 then
            return false
        end
     
        return "c"..index==cid
    end

    -- 检测关卡是否解锁
    function self.checkUnlock(cid,id)
        if type(self.challenge.data[cid])~='table' then
            return false
        end
    
        if id<=0 or id>#self.challenge.data[cid] then
            return false
        end
        if id>1 then
            if self.challenge.data[id-1] == 0 then
                return false
            end
        end

        return true
    end

    -- 检测挑战次数
    function self.checktimes(num)
        if num>self.challenge.n or num<=0 then
            return false
        end

        return true
    end

    -- 检测是否可以扫荡
    function self.checkraid(cid,index)
        if type(self.challenge.data[cid])~='table' then
            return false
        end

        if self.challenge.data[cid][index] < getConfig('badge.main.fastLimit') then
            return false
        end

        return true
        
    end

    -- 扣除副本挑战次数
    function self.usetimes(num)
        if self.challenge.n<num or num <=0 then
            return false
        end
        self.challenge.n = self.challenge.n - num
        self.battletimes = self.battletimes + num
        return true
    end

    -- 更新关卡通关次数
    function self.setstar(cid,index,num)
        if type(self.challenge.data[cid])~='table' or not self.challenge.data[cid][index] then
            return false
        end
        self.challenge.data[cid][index] = self.challenge.data[cid][index] + num

        return self.challenge.data[cid][index]
    end

    -- 获取使用中徽章的战力（刷新玩家战力会用）
    function self.getUsedFighting()  
        if moduleIsEnabled("badge") ~= 1 then
            return {},0
        end   
        -- 1-攻击，2-血量，3-命中,4-闪避，5-暴击，6-装甲
        local att2name = {"attack","hp","accuracy","evade","crit","anticrit"}
        local itemListcfg = badgeServerCfg.itemList  
        local suitListcfg = badgeServerCfg.suitList 
        local detailListcfg = badgeServerCfg.detailList

        local tankAttributes = {attack=0,hp=0,accuracy=0,evade=0,crit=0,anticrit=0}    
        for k,v in pairs(self.used) do
            if v~=0 then
                local binfo=self.info[v]
                local br = 0 -- 突破增加属性系数
                if binfo[3]>0 then
                    br = itemListcfg[binfo[1]].btGrow[binfo[3]]/100 or 0
                end

                for k,attType in pairs(itemListcfg[binfo[1]].attType) do             
                    local attValue = itemListcfg[binfo[1]].att[k] + itemListcfg[binfo[1]].lvGrow[k] * (binfo[2]-1)
                    tankAttributes[att2name[attType]] =  (tankAttributes[att2name[attType]] or 0) + (attValue/100) *(1+br) 
                end
            end 
        end

        local attr2code = getConfig("common.attributeStrForCode")
        local codeattr = {}
        for k, v in pairs( tankAttributes ) do
            if attr2code[k] then
                codeattr[ attr2code[k] ] = v
            end
        end

        -- 套装增加战力系数
        local suite = self.suiteff()
        local strength = 0
        if next(suite) then
            for k,v in pairs(suite) do
                strength = strength + detailListcfg[v].strength
            end  
        end

        return codeattr, strength/badgeServerCfg.main.sDivisor
    end

    -- 获取装配的徽章配置编号
    function self.usedcid()
        local cid = {}
        if type(self.used)=='table' then
            for k,v in pairs(self.used) do
                if v~=0 then
                    table.insert(cid,self.info[v][1])
                end
            end
        end
        return cid
    end

    -- 装配的徽章套装效果编号
    function self.suiteff()
        local stab = {} 
        local usedcid = self.usedcid()
        if type(self.used)=='table' then
            for k,v in pairs(self.used) do
                if v~=0 then
                    local cid = self.info[v][1]
                    -- 套装效果
                    if badgeServerCfg.itemList[cid].suitType then
                        local s = badgeServerCfg.itemList[cid].suitType
                        local sucfg = badgeServerCfg.suitList[s]
                        if sucfg and next(usedcid) then
                            local efn = 0
                            local ss = {}
                            for u,usid in pairs(usedcid) do
                                if table.contains(sucfg.matchMetal,usid) then
                                    efn = efn + 1
                                end
                            end
                            
                            for sk,sn in pairs(sucfg.suitNum) do
                                if efn>=sn then
                                    if not table.contains(stab,sucfg.include[sk]) then
                                        table.insert(stab,sucfg.include[sk])
                                    end
                                end
                            end
                        end     
                    end
                end
            end
        end

        return stab
    end

    -- 设置战斗部队属性 
    -- 返回值 增加的基础属性 套装技能
    function self.getUsedAttribute()
        local attVal = {att={},skill={}}
        -- 没开启就不生效了
        if moduleIsEnabled("badge") ~= 1 then
            return attVal
        end
        -- 1-攻击，2-血量，3-命中,4-闪避，5-暴击，6-装甲
        local att2name = {"dmg","maxhp","accuracy","evade","crit","anticrit"}
        local itemListcfg = badgeServerCfg.itemList
        local tankAttributes = {dmg=0,maxhp=0,accuracy=0,evade=0,crit=0,anticrit=0}    
        for k,v in pairs(self.used) do
            if v~=0 then
                local binfo=self.info[v]
                local br = 0 -- 突破增加属性系数
                if binfo[3]>0 then
                    br = itemListcfg[binfo[1]].btGrow[binfo[3]]/100 or 0
                end

                for k,attType in pairs(itemListcfg[binfo[1]].attType) do             
                    local attValue = itemListcfg[binfo[1]].att[k] + itemListcfg[binfo[1]].lvGrow[k] * (binfo[2]-1)
                    tankAttributes[att2name[attType]] =  (tankAttributes[att2name[attType]] or 0) + (attValue/100) *(1+br) 
                end
            end 
        end

        local suiteSkill = self.suiteff()
        attVal.att = tankAttributes
        attVal.skill = suiteSkill
  
        return attVal
    end

    -- 增加内矿资源生产速度
    function self.resourceSpeed()
        local addRate = 0
        if moduleIsEnabled("badge") ~= 1 then
            return addRate
        end
        local detailListcfg = badgeServerCfg.detailList
        local  ss = self.suiteff()
        if next(ss) then
            for k, v in pairs(ss) do
                local sscfg = detailListcfg[v]
                if sscfg and sscfg.type==2 then
                    addRate = addRate + sscfg.att
                end
            end
        end

        return addRate/100
    end

    -- 副本战斗
    function self.battle(cid,defenderId,fleetInfo,hero,repair,equip) 
        local ret = 0
        local itemid = tonumber(string.sub(cid,2))    
        local challengeCfg = badgeServerCfg.challenge[itemid][defenderId]
        if type(challengeCfg)~='table' then
            ret = -120
            return ret
        end
        local defFleetInfo = challengeCfg.tank
        local defSkill = challengeCfg.skill
        local defTech = challengeCfg.tech
        local defLevel = challengeCfg.difficult -- 关卡难度
        local defName = 0 -- 关卡名称
        local defAttUp = challengeCfg.attributeUp
        local tankCfg = getConfig('tank')

        local uobjs = getUserObjs(self.uid)
        local aUserinfo = uobjs.getModel('userinfo')        
        local attackFleet = uobjs.getModel('troops')
        local mDailyTask=uobjs.getModel('dailytask')
        local mTroop = uobjs.getModel('troops')
        local mSequip = uobjs.getModel('sequip')
        local debuffvalue = mSequip.dySkillAttr(equip, 's101', 0) --关卡护盾 减少敌方伤害x%
        local buffvalue = mSequip.dySkillAttr(equip, 's102', 0) --关卡强击 我方伤害增加X%
        local mAweapon = uobjs.getModel('alienweapon')
        local uservip  =aUserinfo.vip
        local aFleetInfo,_,aheros = attackFleet.initFleetAttribute(fleetInfo,1,{hero=hero, equip=equip, equipskill={dmg=buffvalue, dmg_reduce=1-debuffvalue}})
        local dFleetInfo = self.initDefFleetAttribute(defFleetInfo,defSkill,defTech,defAttUp,self.feetTypeNum(fleetInfo))

        require "lib.battle"
        
        local report,aInavlidFleet, dInvalidFleet = {}
        report.d, report.r, aInavlidFleet, dInvalidFleet = battle(aFleetInfo,dFleetInfo)
        report.t = {defFleetInfo,fleetInfo}
        report.p = {{defName,defLevel,0},{aUserinfo.nickname,aUserinfo.level,1}}
        report.ocean = challengeCfg.ocean

        if aheros and next(aheros) then report.h = {{},aheros[1]} end
        
        report.se = {0, mSequip.formEquip(equip)}
        -- 损毁的坦克，巨兽再现活动需要以此计算积分
        local destroyTanks = {}
        local attach = {}
        ---------兵损失量--------------
        for k,v in pairs(fleetInfo) do
            if next(v) then
                local dieNum = v[2] - aInavlidFleet[k].num
                if not attackFleet.consumeTanks(v[1],dieNum) then
                    return false
                end
                
                -- 徽章战斗 所有的阵亡部队 全部进入修理厂
                local repairNum = dieNum
                -- 自动修复
                local awRepair = mAweapon.autoRepairByPos(k, repairNum)
                if awRepair > 0 then
                    attackFleet.incrTanks(v[1], awRepair)
                    repairNum = repairNum - awRepair
                end

                destroyTanks[v[1]] = (destroyTanks[v[1]] or 0 ) + math.floor(dieNum-repairNum)
                attackFleet.incrDamagedTanks(v[1],repairNum)

                local isTroopsenough = mTroop.checkFleetInfo(fleetInfo)
                if repairNum > 0 and not attach[v[1]] then
                    attach[v[1]] = {needrepair = dieNum}
                elseif repairNum > 0 then
                    attach[v[1]].needrepair = attach[v[1]].needrepair + dieNum
                end
                -- 用户选择不修复，出兵量不够，给前端初始化字段
                if repairNum>0  and not isTroopsenough and not repair then
                    if not attach[v[1]].repaircost then attach[v[1]].repaircost = 0 end
                    if not attach[v[1]].repaired then attach[v[1]].repaired = 0 end
                end

                local repairflag = false
                -- 出兵量不够,直接修复
                if repairNum>0 and not isTroopsenough and repair  then
                    -- 直接修复阵亡的船数量
                    local mDmgTroop = mTroop.getDamagedTroops()
                    repairNum = (mDmgTroop[v[1]] - dieNum) > 0 and dieNum or repairNum

                    local costNum = tonumber(tankCfg[v[1]][repair]) or 0
                    local costNums = math.ceil (costNum * repairNum)

                    if repair == 'glodCost' and costNums>0 and aUserinfo.useResource({gold=costNums}) then
                        repairflag = true
                    elseif repair == 'gemCost' and costNums>0 and aUserinfo.useGem(costNums) then
                        repairflag = true
                    end

                    if not attach[v[1]].repaircost then attach[v[1]].repaircost = 0 end
                    if not attach[v[1]].repaired then attach[v[1]].repaired = 0 end
                    if repairflag then                        
                        attach[v[1]].repaircost = attach[v[1]].repaircost + costNums
                        attach[v[1]].repaired = attach[v[1]].repaired + repairNum
                    end
                     
                end
                if repairflag then
                    mTroop.repairTanks(v[1], repairNum)            
                end
            end
        end
        
        local win  = report.r   
        report.w = win    
        if report.r == 1 then
            ---- 通关次数
            if not self.setstar(cid,defenderId,1) then
                ret = -106
                return ret
            end
            local reward = {} 
            local pool = badgeServerCfg.reward[challengeCfg.pool]
            local result,rewardkey = getRewardByPool(pool,1)      
            for k,v in pairs (result) do
                for rk,rv in pairs(v) do
                    reward[rk]=(reward[rk] or 0)+rv
                end
            end

            if type(challengeCfg.exp)=='table' then
                setRandSeed()
                reward['badge_exp'] = rand(challengeCfg.exp[1],challengeCfg.exp[2])
            end

            report.r = formatReward(reward)
            if not takeReward(self.uid,reward) then
                ret = -106
                return ret
            end
        end

        return ret,report, win, attach
    end

    -- 活动副本战斗
    function self.sbattle(defenderId,fleetInfo,hero,repair,equip) 
        local ret = 0   
        local schallengeCfg = badgeServerCfg.schallenge
        local challengeCfg = schallengeCfg[defenderId]
        if type(challengeCfg)~='table' then
            ret = -120
            return ret
        end
        local defFleetInfo = challengeCfg.tank
        local defSkill = challengeCfg.skill
        local defTech = challengeCfg.tech
        local defLevel = challengeCfg.difficult -- 关卡难度
        local defName = 0 -- 关卡名称
        local defAttUp = challengeCfg.attributeUp
        local tankCfg = getConfig('tank')

        local uobjs = getUserObjs(self.uid)
        local aUserinfo = uobjs.getModel('userinfo')        
        local attackFleet = uobjs.getModel('troops')
        local mDailyTask=uobjs.getModel('dailytask')
        local mTroop = uobjs.getModel('troops')
        local mSequip = uobjs.getModel('sequip')
        local debuffvalue = mSequip.dySkillAttr(equip, 's101', 0) --关卡护盾 减少敌方伤害x%
        local buffvalue = mSequip.dySkillAttr(equip, 's102', 0) --关卡强击 我方伤害增加X%
        local mAweapon = uobjs.getModel('alienweapon')
        local uservip  =aUserinfo.vip
        local aFleetInfo,_,aheros = attackFleet.initFleetAttribute(fleetInfo,1,{hero=hero, equip=equip, equipskill={dmg=buffvalue, dmg_reduce=1-debuffvalue}})
        local dFleetInfo = self.initDefFleetAttribute(defFleetInfo,defSkill,defTech,defAttUp,self.feetTypeNum(fleetInfo))

        local aUseractive = uobjs.getModel('useractive')

        require "lib.battle"
        
        local report,aInavlidFleet, dInvalidFleet = {}
        report.d, report.r, aInavlidFleet, dInvalidFleet = battle(aFleetInfo,dFleetInfo)
        report.t = {defFleetInfo,fleetInfo}
        report.p = {{defName,defLevel,0},{aUserinfo.nickname,aUserinfo.level,1}}
        report.ocean = challengeCfg.ocean

        if aheros and next(aheros) then report.h = {{},aheros[1]} end
        
        report.se = {0, mSequip.formEquip(equip)}
        -- 损毁的坦克，巨兽再现活动需要以此计算积分
        local destroyTanks = {}
        local attach = {}
        ---------兵损失量--------------
        for k,v in pairs(fleetInfo) do
            if next(v) then
                local dieNum = v[2] - aInavlidFleet[k].num
                if not attackFleet.consumeTanks(v[1],dieNum) then
                    return false
                end
                
                local repairNum = dieNum
                -- 自动修复
                local awRepair = mAweapon.autoRepairByPos(k, repairNum)
                if awRepair > 0 then
                    attackFleet.incrTanks(v[1], awRepair)
                    repairNum = repairNum - awRepair
                end

                destroyTanks[v[1]] = (destroyTanks[v[1]] or 0 ) + math.floor(dieNum-repairNum)
                attackFleet.incrDamagedTanks(v[1],repairNum)

                local isTroopsenough = mTroop.checkFleetInfo(fleetInfo)
                if repairNum > 0 and not attach[v[1]] then
                    attach[v[1]] = {needrepair = dieNum}
                elseif repairNum > 0 then
                    attach[v[1]].needrepair = attach[v[1]].needrepair + dieNum
                end
                -- 用户选择不修复，出兵量不够，给前端初始化字段
                if repairNum>0  and not isTroopsenough and not repair then
                    if not attach[v[1]].repaircost then attach[v[1]].repaircost = 0 end
                    if not attach[v[1]].repaired then attach[v[1]].repaired = 0 end
                end

                local repairflag = false
                -- 出兵量不够,直接修复
                if repairNum>0 and not isTroopsenough and repair  then
                    -- 直接修复阵亡的船数量
                    local mDmgTroop = mTroop.getDamagedTroops()
                    repairNum = (mDmgTroop[v[1]] - dieNum) > 0 and dieNum or repairNum

                    local costNum = tonumber(tankCfg[v[1]][repair]) or 0
                    local costNums = math.ceil (costNum * repairNum)

                    if repair == 'glodCost' and costNums>0 and aUserinfo.useResource({gold=costNums}) then
                        repairflag = true
                    elseif repair == 'gemCost' and costNums>0 and aUserinfo.useGem(costNums) then
                        repairflag = true
                    end

                    if not attach[v[1]].repaircost then attach[v[1]].repaircost = 0 end
                    if not attach[v[1]].repaired then attach[v[1]].repaired = 0 end
                    if repairflag then                        
                        attach[v[1]].repaircost = attach[v[1]].repaircost + costNums
                        attach[v[1]].repaired = attach[v[1]].repaired + repairNum
                    end
                     
                end
                if repairflag then
                    mTroop.repairTanks(v[1], repairNum)            
                end
            end
        end
        
        local win  = report.r  
        report.w = win    
        if report.r == 1 then
            local reward = {} 
            local badgechallenge = aUseractive.getActiveConfig("badgechallenge")
            local pool = badgechallenge.serverreward["pool"..defenderId]
            local result,rewardkey = getRewardByPool(pool,1)      
            for k,v in pairs (result) do
                for rk,rv in pairs(v) do
                    reward[rk]=(reward[rk] or 0)+rv
                end
            end

            if type(challengeCfg.exp)=='table' then
                setRandSeed()
                reward['badge_exp'] = rand(challengeCfg.exp[1],challengeCfg.exp[2])
            end

            report.r = formatReward(reward)
            if not takeReward(self.uid,reward) then
                ret = -106
                return ret
            end
        end

        return ret,report, win, attach
    end

    -- 装备的徽章数据(战报里面会用)
    function self.formBadge()
        local used = {0,0,0,0,0,0}
        for k,v in pairs(self.used) do
            if v~=0 and self.info[v] then
                local id = self.info[v][1].."-"..self.info[v][2].."-"..self.info[v][3]
                used[k] = id
            end
        end
        return used
    end

    -- 初始化军队属性 
    function self.initDefFleetAttribute(tanks,skills,techs,defAttUp,tynum)
        local inittanks = initTankAttribute(tanks,techs,skills,nil,nil,31,{acAttributeUp=defAttUp,typenum=tynum})
        return inittanks
    end

    -- 查看玩家配置的兵种类型数
    function self.feetTypeNum(fleetInfo)  
        local ftype = {}
        if type(fleetInfo)=='table' then
            for k,v in pairs(fleetInfo) do
                if type(v)=='table' and next(v) then
                    local tankCfg = getConfig('tank.'..v[1])
                    if tankCfg and not table.contains(ftype,tankCfg.type) then
                        table.insert(ftype,tankCfg.type)
                    end
                end
            end
        end

        return #ftype
    end


    --------------------admin-----------
    -- 设置战斗部队属性 
    -- 返回值 增加的基础属性 套装技能
    function self.adminUsedAttribute()
        local attVal = {att={{},{},{},{},{},{}},skill={}}
        -- 1-攻击，2-血量，3-命中,4-闪避，5-暴击，6-装甲
        local att2name = {"dmg","maxhp","accuracy","evade","crit","anticrit"}
        local itemListcfg = badgeServerCfg.itemList   
        for k,v in pairs(self.used) do
            if v~=0 then
                local binfo=self.info[v]
                local br = 0 -- 突破增加属性系数
                if binfo[3]>0 then
                    br = itemListcfg[binfo[1]].btGrow[binfo[3]]/100 or 0
                end

                local tmp = {}
                for ka,attType in pairs(itemListcfg[binfo[1]].attType) do             
                    local attValue = itemListcfg[binfo[1]].att[ka] + itemListcfg[binfo[1]].lvGrow[ka] * (binfo[2]-1)
                    attVal.att[k][att2name[attType]] =  (attVal.att[k][att2name[attType]] or 0) + (attValue/100) *(1+br)   
                end
            end 
        end

        local suiteSkill = self.suiteff()
        attVal.skill = suiteSkill
  
        return attVal
    end

    -- 修改徽章的等级
    function self.setlevel(id,level)
        if not self.info[id] then
            return -1
        end

        local itemcfg = badgeServerCfg.itemList[self.info[id][1]]
        if not itemcfg then
            return -120
        end

        if level>itemcfg.maxLevel then
           return -121
        end

        self.info[id][2] = level

        return 0
    end

    return self
end