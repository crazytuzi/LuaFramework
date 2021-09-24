function model_schallenge(uid,data)
    local self = {
        uid = uid,
        info={}, --精英关卡
        resetnum = 0, --重置次数
        reset_at = 0, -- 重置时间
        pernum = 0, --可攻击次数
        updated_at = 0,
    }
    

    -- private fields are implemented using locals
    -- they are faster than table access, and are truly private, so the code that uses your class can't get them
    -- local test = uid


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

        return true
    end

    function self.toArray(format)    
        local data = {}
        for k,v in pairs (self) do
            if type(v)~="function" and k~= 'uid' and k~= 'updated_at' then              
                if format then
                    if type(v) == 'table'  then
                        if next(v) then data[k] = v end
                        elseif v ~= 0 and v~= '0' and v~='' then
                            data[k] = v
                        end
                    else
                    data[k] = v
                end
            end
        end

        return data
    end

    function self.getKeys()
        local data = {}
        for k,v in pairs (self) do
            if type(v)~="function" then
                table.insert(data,k)
            end
        end
        return data
    end

    -------------- 关卡战斗
    -- 科技，道具，加成
    function self.battle(defenderId,fleetInfo,isTutorial,hero, repair, equip)       
        local challengeCfg = getConfig('schallenge.challenge.'..defenderId)
        local defFleetInfo = challengeCfg.tank
        local defSkill = challengeCfg.skill
        local defTech = challengeCfg.tech
        local defLevel = challengeCfg.level -- 关卡等级
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
        local mBadge = uobjs.getModel('badge')

        local uservip  =aUserinfo.vip
        local aFleetInfo,_,aheros = attackFleet.initFleetAttribute(fleetInfo,1,{hero=hero,equip=equip, equipskill={dmg=buffvalue, dmg_reduce=1-debuffvalue}})
        local dFleetInfo = self.initDefFleetAttribute(defFleetInfo,defSkill,defTech,defAttUp)

        require "lib.battle"
        
        local report,aInavlidFleet, dInvalidFleet = {star=0}
        report.d, report.r, aInavlidFleet, dInvalidFleet = battle(aFleetInfo,dFleetInfo)
        report.t = {defFleetInfo,fleetInfo}
        report.p = {{defName,defLevel,0},{aUserinfo.nickname,aUserinfo.level,1}}
        report.ocean = challengeCfg.ocean

        if aheros and next(aheros) then report.h = {{},aheros[1]} end
        
        report.se = {0, mSequip.formEquip(equip)}
        report.badge = {{0,0,0,0,0,0}, mBadge.formBadge()} --徽章数据
        
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
                
                local repairNum = math.ceil(dieNum * 0.8)
       
                --国庆期间坦克损坏降到10%
                repairNum = activity_setopt(uid,'nationalCampaign',{action='getTank',repairNum=dieNum}) or repairNum

                -------------------- start vip新特权 
                local addition = 0
                if moduleIsEnabled('vps') == 1 and uservip>0 then
                        local vipRelatedCfg = getConfig('player.vipRelatedCfg')
                        if type(vipRelatedCfg)=='table' then
                            local vip =vipRelatedCfg.storyLoss[1] 
                            if uservip>=vip then
                                addition=vipRelatedCfg.storyLoss[2] or 0
                            end
                        end 
                                       
                end
                --------------------- end
                repairNum=repairNum+math.ceil(dieNum*addition)
                if dieNum< repairNum then
                    repairNum=dieNum
                end
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
                if repairNum>0  and not isTroopsenough  and not repair then
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

                    --勇往直前活动
                    if repair == 'glodCost' then
                        local resDiscount = activity_setopt(uid,'yongwangzhiqian',{action="getResDiscount",num=costNums})
                        if resDiscount then
                            costNums = costNums - resDiscount
                        end  
                    end

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
        
        -- 巨兽再现
        activity_setopt(uid,'monsterComeback',{destroyTanks=destroyTanks})
        -- 许愿炉
        activity_setopt(uid,"xuyuanlu",{action="challenge"})

        local key = 's' .. defenderId
        local win  = report.r        
        if report.r == 1 then
            report.star = self.setStar(key,fleetInfo,aInavlidFleet)   -- 关卡评星，解锁
            report.r, report.rr = self.takeReward(challengeCfg.reward,isTutorial, nil, defenderId, equip)  -- 关卡奖励, rr为首次通关奖励！
            -- 国庆活动
            report.r = activity_setopt(self.uid, "nationalDay", {action="challenge", reward=report.r}, 0, report.r)

            -- 周年庆活动
            report.r = activity_setopt(self.uid, "anniversary", {action="level", reward=report.r}, 0, report.r)
            --中秋活动
            local tmpReward = activity_setopt(uid,'autumnCarnival',{level=defLevel})
            if tmpReward then
                report.acaward = tmpReward.acaward
            end
            -- 复活节彩蛋大搜寻
            local eggReward = activity_setopt(uid,'searchEasterEgg',{egg2=1})
            if eggReward and tonumber(eggReward.egg2) > 0 then
                report.acaward = report.acaward or {}
                report.acaward["egg2"] = eggReward.egg2  
            end            
            --新的日常任务检测
            mDailyTask.changeNewTaskNum('s203',1)
            mDailyTask.changeNewUrgencyTaskNum('s2',defenderId) 
        end
        return report,self.info[key], win, attach
    end

    -- 关卡是否已解锁 
    function self.checkUnlock(sid)
        if not tonumber(sid) or sid<1 then
            return false
        end

        --前一关未解锁
        local prevSid = 's' .. (sid - 1)
        if sid>1 and not arrayGet(self.info, prevSid) then
            return false
        end
        
        local schaConfig = getConfig('schallenge')
        local challengeCfg = schaConfig["challenge"][sid]
        local uobjs = getUserObjs(self.uid)
        local mUserinfo = uobjs.getModel('userinfo')
        local mBuilding = uobjs.getModel('buildings')
        local mChallenge = uobjs.getModel('challenge')
        local versioncfg = getVersionCfg()

        --普通关卡章节未解锁
        local ordchapterid = math.floor( table.length(mChallenge.info) / schaConfig.ordChapter )
        local eitechapterid = math.ceil( sid / schaConfig.eiteChapter )
        local chaStars = mChallenge.getChallengeMaxSid()
        if ordchapterid < eitechapterid or chaStars.star[eitechapterid] < schaConfig.ordstars  then
            return false
        end
        --版本控制
        if eitechapterid > versioncfg.unlockElitepoint then
            return false
        end
        
        -- 玩家等级不够
        if mUserinfo.level < challengeCfg.unlock.ulvl then
            return false
        end
        -- 改船厂等级不够
        if not next(mBuilding.b13) or mBuilding.b13[2] < challengeCfg.unlock.tankdiy then
            return false
        end 

        return true
    end

    -- 设置过关指数星    
    ---------- 规则：
    -- 星级判定以战斗力为基准
    -- 剩余30%以下为一星
    -- 剩余30%-69%为二星
    -- 70%以上为三星
    ---------- 参数：
    -- sid 关卡id
    -- fleetinfo 攻打关卡的兵力
    -- 攻打关卡后的兵力    
    function self.setStar(sid,fleetInfo,aInavlidFleet)        
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

            --当前关卡所获得的星星
             
            self.info[sid] = self.info[sid] or {}   
            local currStar = self.info[sid].s or 0  
            local addStar = star - currStar
            if  addStar > 0 then                        
                self.info[sid].s = star
                -- 总星数，统计到关卡中
                local uobjs = getUserObjs(self.uid)
                local mchallenge = uobjs.getModel('challenge')
                local allstar = mchallenge.addAllStar( addStar )
                -- regEventAfterSave(self.uid,'e2',{star=allstar})
                activity_setopt(self.uid,'personalCheckPoint',{score=allstar},true)
                 
            end
        end

        return star
    end

    -- 初始化军队属性
    function self.initDefFleetAttribute(tanks,skills,techs,defAttUp)
        -- local inittanks = initTankAttribute(tanks,techs,skills)
        local inittanks = initTankAttribute(tanks,techs,skills,nil,nil,6,{acAttributeUp=defAttUp})
        return inittanks
    end

    -- 格式化奖励
    -- flag true api challenge.info 需要后台把所有可以获取的道具返回给前台
    function self.takeReward(reward,isTutorial,flag, defenderId,equip)
        local award = {u={},p={},o={}}
        local uobjs = getUserObjs(self.uid)
        local mUserinfo = uobjs.getModel('userinfo')
        local mJob =uobjs.getModel('jobs')
        local mSequip = uobjs.getModel('sequip')
        local equipvalue = mSequip.dySkillAttr(equip, 's103', 0) --关卡教条 攻打关卡时经验加成X%

        -- 4 区域站攻打关卡经验加成
        local jobvalue =mJob.getjobaddvalue(4) -- 区域站经验加成        
        local mTech,techLevel,techCfg
        local firstAward = nil
        --flag为true时只是查看可以获取的东西，flag为nil或者false时才将资源获取的加到用户数据当中
        if type(reward) == 'table' then
            setRandSeed()
            for k,v in pairs(reward) do
                -- 有概率获取到道具奖励
                -- flag 给用户展示可以获取的道具
                if (k == 'propbonus' and not isTutorial) or (k == 'propbonus' and flag) then
                    local randnum = rand(1,100)                    
                    -- 运气来了
                    if randnum <= v.vate or flag then
                        local reward = getRewardByPool(v.pool)
                        --flag true 把所有可能的道具都取出来---
                        if flag then
                            reward = {}
                            for _, propinfo in pairs(v.pool[3]) do
                                reward[propinfo[1]] = propinfo[2]
                            end
                        end
                        -------------------------------------
                        --装备换代活动
                        reward = activity_setopt( self.uid, "armamentsUpdate1", {type=2, reward=reward}) or reward
                        reward = activity_setopt(self.uid, "armamentsUpdate2", {type=2, reward=reward}) or reward
                        if not flag then
                            takeReward(self.uid, reward)
                        end
                        for type, num in pairs(reward) do
                            local tmpRewardType = type:split("_")
                            award.p[tmpRewardType[2]] = num
                        end
                    end
                -- 经验
                elseif k =='exp' then
                        techCfg = techCfg or getConfig('tech.t20')
                        mTech = mTech or uobjs.getModel('techs')
                        techLevel = techLevel or mTech.getTechLevel('t20')
                        local addexp = v

                        ------国庆攻势,增加经验值
                        local nationalcampaignExp = activity_setopt(self.uid,'nationalCampaign',{exp=addexp,action='getExp'}) or 0
                        ------勇往直前增加经验
                        local yongwangzhiqExp = activity_setopt(self.uid,'yongwangzhiqian',{exp=addexp,action='getExp'}) or 0

                        -------------------- start vip新特权 增加打关卡增加经验
                        if moduleIsEnabled('vax') == 1 and mUserinfo.vip>0 then
                           local vipForAddExp = getConfig('player.vipForAddExp')
                           if type(vipForAddExp)=='table' then
                               v =addexp+math.floor(addexp*vipForAddExp[mUserinfo.vip+1])
                           end 
                           
                        end

                        if isTutorial and defenderId == 3 then
                            v = 105
                        end
                                                      
                        --------------------- end
                        v = math.floor(v + (techCfg.value[techLevel] or 0) / 100 * addexp)
                        v = activity_setopt(self.uid,'luckUp',{name='attackChallenge',item='exp',value=v}) or v
                        --累加国庆经验
                        v = v + nationalcampaignExp
                        v = v + yongwangzhiqExp
                        -- 区域站职位加成
                        if jobvalue>0 then
                            v=v+addexp*jobvalue
                        end
                        --超级装备加成
                        if equipvalue>0 then
                            v=v + math.ceil(addexp*equipvalue)
                        end

                        -- 全民劳动
                        local laborRate = activity_setopt(self.uid,'laborday',{act='upRate',n=3})
                        if laborRate then
                            v=v + math.ceil(addexp*laborRate)
                        end

                        if not flag then
                            mUserinfo.addExp(v)
                        end
                        
                        award.u[k] = v
                -- 荣誉
                elseif k=='honors' then
                    if not flag then
                        mUserinfo.addHonor(v)
                    end
                    award.u[k] = v
                elseif k=='firstAward' then
                    --第一次通关奖励
                    local  rewardFlag = false
                    if not self.other.fr then
                         self.other.fr = {}
                    end
                    if not self.other.fr['s'..defenderId] then
                        self.other.fr['s'..defenderId] = 1
                        rewardFlag = true
                    end
                    if rewardFlag then
                        takeReward(self.uid, v)
                        firstAward = formatReward(v)
                    end
                elseif k=='armor_exp' then
                    mArmor = uobjs.getModel('armor')

                    -- 活动加成经验
                    v = activity_setopt(self.uid,'armorStreng',{exp=v}) or v

                    mArmor.addAllResource('exp', v)
                    award.am = {exp = v}
                end
            end        
        end
        return award, firstAward
    end

    -- 根据关卡id获取数据
    function self.getChallengeDataBySid(minSid,maxSid)      
        local data = {
            info={},
            maxsid = 0,
        }
        if type(self.info) == 'table' then
            local sid = 0
            for k,v in pairs(self.info) do
                data.maxsid = data.maxsid + 1
                sid = tonumber(k:sub(2))
                if  sid and sid >= minSid and  sid <= maxSid then
                    data.info[k] = v                    
                end
            end
        end

        -- 最大关卡
        local maxSid = data.maxsid + 1
        if self.checkUnlock(maxSid) then
            data.maxsid = data.maxsid + 1
        end

        return data
    end

    -- 获取最大的关卡id
    function self.getChallengeMaxSid()
        -- 新的一天重置       
        self.checkResetEite()
        local data = {
            star = {},
            maxsid = 0, --可攻击关卡总数
            currsid=0, --已攻击关卡总数
            resetnum = self.resetnum, --重置次数
            reset_at = self.reset_at, -- 重置时间
            pernum = self.pernum, --攻击次数
        }

        local challengeCfg = getConfig('schallenge')
        local eiteChapter = challengeCfg.eiteChapter

        if type(self.info) == 'table' then  
            local sid, chapter
            for k,v in pairs(self.info) do                
                sid = tonumber(k:sub(2)) or 0
                chapter = math.ceil(sid/eiteChapter)
                if not data.star[chapter] then
                    data.star[chapter] = 0
                end
                data.star[chapter] = data.star[chapter] + v.s
                data.maxsid = data.maxsid + 1
            end
        end

        -- 最大关卡
        data.currsid = data.maxsid
        local maxSid = data.maxsid + 1
        if self.checkUnlock(maxSid) then
            data.maxsid = data.maxsid + 1
        end

        return data
    end

    -- 获取关卡星星
    function self.getStar(sid)
        return self.info[sid] and self.info[sid].s or 0 
    end
    
    -- 获取精英关卡攻打条件
    function self.checkAccessEite(sid, isInc)

        if self.pernum <= 0 and not self.checkResetEite() then
            return false 
        end

        if isInc then
            self.pernum = self.pernum - 1
        end

        return true
    end

    -- 精英关卡购买次数
    function self.buyEiteCount() 
        local challengeCfg = getConfig('schallenge')
        local uobjs = getUserObjs(self.uid)
        local mUserinfo = uobjs.getModel('userinfo')

        --隔天重置了
        if self.checkResetEite() then
           -- return -10004
        end
        -- 次数足够不卖
        -- if self.pernum < challengeCfg.pernum then
        --     return -10001 
        -- end
        -- 次数已满不卖
        local buycnt = challengeCfg.resetNum[ mUserinfo.vip+1 ]
        if not buycnt or self.resetnum >= buycnt then
            return -7004 
        end
        -- 没钱不卖
        local gemsCost = challengeCfg.resetGems[ self.resetnum+1 ]
        if not gemsCost or not mUserinfo.useGem( gemsCost )   then
            return -7005 
        end

        --恢复次数
        self.pernum = self.pernum + challengeCfg.pernum
        self.resetnum = self.resetnum + 1
        --日志
        regActionLogs(uid,1,{action=85,item="",value=gemsCost,params={resetNum=self.resetnum}})

        return 0
    end

    -- 精英关卡每日重置
    function self.checkResetEite()
        local weeTs = getWeeTs()
        if self.reset_at >= weeTs then
            return false
        end

        local challengeCfg = getConfig('schallenge')
        self.pernum = activity_setopt(self.uid,'armorStreng',{count=challengeCfg.pernum }, nil, challengeCfg.pernum)
        self.resetnum = 0
        self.reset_at = weeTs

        return true
    end

    --------------------------------------------------------------------------------------------------------------
    
    if type(self.info) ~= 'table' then
        self.info = {}
    end

    return self
end 
