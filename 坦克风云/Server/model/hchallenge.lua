function model_hchallenge(uid,data)
    local self = {
        uid = uid,
        info = {},
        reward = {},
        star = 0,
        weets = 0,
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
    function self.battle(defenderId,fleetInfo,hero, repair, equip)
        local challengeCfg = getConfig('hChallengeCfg.list.'..defenderId)
        local defFleetInfo = challengeCfg.tank
        local defSkill = challengeCfg.skill
        local defTech = challengeCfg.tech
        local defLevel = challengeCfg.level or 0 -- 关卡等级
        local defName = 0 -- 关卡名称
        local defAttUp = challengeCfg.attributeUp

        local uobjs = getUserObjs(self.uid)
        local aUserinfo = uobjs.getModel('userinfo')        
        local attackFleet = uobjs.getModel('troops')
        local mDailyTask=uobjs.getModel('dailytask')
        local mSequip = uobjs.getModel('sequip')
        local mTroop = uobjs.getModel('troops')
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
        if aheros and next(aheros) then report.h = {{},aheros[1]} end
        report.se = {0, mSequip.formEquip(equip)}
        report.badge = {{0,0,0,0,0,0}, mBadge.formBadge()} --徽章数据

         -- 损毁的坦克，巨兽再现活动需要以此计算积分
        local destroyTanks = {}

        local attach = {}
        local tankCfg = getConfig('tank')
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

        local ts = getClientTs()
        local weeTs = getWeeTs(ts)
        local lastTs = getWeeTs(self.weets)
        if lastTs < weeTs then
            self.refInfo()
            self.weets = weeTs
        end

        local key = 's' .. defenderId
        local win  = report.r   
        -- print('win',report.r)
        -- ptb:p(challengeCfg.reward)
        -- 巨兽再现
        activity_setopt(uid,'monsterComeback',{destroyTanks=destroyTanks})
        -- 许愿炉
        activity_setopt(uid,"xuyuanlu",{action="challenge"})

        if report.r == 1 then
            report.star = self.setStar(key,fleetInfo,aInavlidFleet)   -- 关卡评星，解锁
            report.r = self.takeReward(challengeCfg.reward)  -- 关卡奖励
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
        if sid == 1 then return true end
        
        if sid then
            local prevSid = 's' .. (sid - 1)
            if self.info[prevSid] and type(self.info[prevSid]) == 'table' and tonumber(self.info[prevSid]['s']) >= 1 then
                return true
            else
                return false
            end
        end

        return true
    end
    
    -- 关卡今日已攻打次数
    function self.checkAttackNum(sid)
        local num = 0
        local ts = getClientTs()
        local weeTs = getWeeTs(ts)
        local lastTs = getWeeTs(self.weets)
        if lastTs < weeTs then
            self.refInfo()
            self.weets = weeTs
        end
        
        if sid then
            local prevSid = 's' .. sid
            if self.info[prevSid] then
                if not self.info[prevSid] then
                    self.info[prevSid] = {}
                end
                num = tonumber(self.info[prevSid]['a']) or 0
            end
        end

        return num
    end
    
    -- 关卡今日已攻打次数
    function self.checkChallengekNum(sid,ctype)
        local num = 0
        local ts = getClientTs()
        local weeTs = getWeeTs(ts)
        local lastTs = getWeeTs(self.weets)
        if lastTs < weeTs then
            self.refInfo()
            self.weets = weeTs
        end
        
        if sid then
            local prevSid = 's' .. sid
            if self.info[prevSid] then
                if not self.info[prevSid] then
                    self.info[prevSid] = {}
                end
                num = tonumber(self.info[prevSid][ctype]) or 0
            end
        end

        return num
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
            if addStar > 0 then
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
        local inittanks = initTankAttribute(tanks,techs,skills,nil,nil,6,{acAttributeUp=defAttUp})
        return inittanks
    end

    -- 格式化奖励
	function self.takeReward(reward)
 		local result = {}
        --print('take1')
        --ptb:p(reward)
		if reward.base then
        --print('base')
			for rtype,rnum in pairs(reward.base) do
				if result[rtype] then
					result[rtype] = result[rtype] + rnum
				else
					result[rtype] = rnum
				end
			end
		end
        --print('take2')
		if reward.rand and next(reward.rand) then
            --print('rand')
			local randReward = getRewardByPool(reward.rand)
			
			if type(randReward) == 'table' then
				for rtype,rnum in pairs(randReward) do
					if result[rtype] then
						result[rtype] = result[rtype] + rnum
					else
						result[rtype] = rnum
					end
				end
			end
		end
        --print('take3')
        --ptb:p(result)
        local ret = takeReward(self.uid,result)
        if not ret then
            return false
        end
        
        return formatReward(result)
    end
    
    function self.refInfo()
        for i,v in pairs(self.info) do
            self.info[i]['a'] = nil
            self.info[i]['r'] = nil
        end
    end
    -- 获取所有关卡数据
    function self.getChallenge2AllData()
        local data = {}
        if type(self.info) == 'table' then
            for k,v in pairs(self.info) do
                self.info[k]['k'] = k
            end
            local tmpdata = {}
            for k,v in pairs(self.info) do
                table.insert(tmpdata,v)
            end
            table.sort(tmpdata, function( a,b )
                local r
                local ak = tonumber(a.k:sub(2))
                local bk = tonumber(b.k:sub(2))
                r = ak < bk
                return r
            end )
            for k,v in pairs(tmpdata) do
                table.insert(data,v.s)
            end
        end
        return data
    end
    -- 根据关卡id获取数据
    function self.getChallengeDataBySid(minSid,maxSid)
        local data = {
            info = {},
            maxsid = 0,
        }

        local ts = getClientTs()
        local weeTs = getWeeTs(ts)
        local lastTs = getWeeTs(self.weets)
        if lastTs < weeTs then
            self.refInfo()
            self.weets = weeTs
        end
        
        if type(self.info) == 'table' then
            local sid = 0
            for k,v in pairs(self.info) do
                data.maxsid = data.maxsid + 1
                sid = tonumber(k:sub(2))
                if sid and sid >= minSid and  sid <= maxSid then
                    if v.s and tonumber(v.s) >= 1 then
                        data.info[k] = v
                    else
                        data.maxsid = data.maxsid - 1
                    end
                end
            end
        end
        
        local chapterNum = getConfig("hChallengeCfg.chapterNum")
        local chapter = math.ceil(minSid/chapterNum)
        data.reward = self.reward

        return data
    end
    
    -- 返回所有关卡数据
    function self.getChallengeAllData()
        local data = {
            info = {},
            maxsid = 0,
        }

        local ts = getClientTs()
        local weeTs = getWeeTs(ts)
        local lastTs = getWeeTs(self.weets)
        if lastTs < weeTs then
            self.refInfo()
            self.weets = weeTs
        end
        
        if type(self.info) == 'table' then
            local sid = 0
            for k,v in pairs(self.info) do
                data.maxsid = data.maxsid + 1
                sid = tonumber(k:sub(2))
                if sid then
                    if v.s and tonumber(v.s) >= 1 then
                        data.info[k] = v
                    else
                        data.maxsid = data.maxsid - 1
                    end
                end
            end
        end

        return data
    end

    -- 返回最大的关卡id
    function self.getChallengeMaxSid()
        local data = {
            star = {},
            maxsid = 0,
        }

        if type(self.info) == 'table' then  
            local sid,chapter
            local chapterNum = getConfig("hChallengeCfg.chapterNum")
            for k,v in pairs(self.info) do                
                sid = tonumber(k:sub(2)) or 0
                data.maxsid = data.maxsid + 1
                chapter = math.ceil(sid/chapterNum)
                if not data.star[chapter] then
                    data.star[chapter] = 0
                end
                if v.s and tonumber(v.s) >= 1 then
                    data.star[chapter] = data.star[chapter] + v.s
                else
                    data.maxsid = data.maxsid - 1
                end
            end
        end

        return data
    end
    
    function self.useBattleNum(sid,num)
        local key = 's'..sid
        if not self.info[key] then
            self.info[key] = {}
        end
        
        if not num then
            num = 1
        end
        self.info[key]['a'] = (self.info[key]['a'] or 0) + num
        
        return true
    end
    
    function self.restNum(sid)
        local key = 's'..sid
        if not self.info then
            self.info = {}
        end
        
        if not self.info[key] then
            self.info[key] = {}
        end
        
        self.info[key]['a'] = 0
        self.info[key]['r'] = (self.info[key]['r'] or 0) + 1
        self.weets = getClientTs()
		
		return true
	end

    --------------------------------------------------------------------------------------------------------------
    
    if type(self.info) ~= 'table' then
        self.info = {}
    end

    return self
end 

