function model_echallenge(uid,data)
    local self = {
        uid = uid,
        info={},
        dailykill={},
        resetnum = 0,  -- 重置次数
        reset_at = 0,   -- 上次重置凌晨时间
        star = 0,
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

        if type(self.info) ~= 'table' then
            self.info = {}
        end

        local weeTs = getWeeTs()
        if (self.reset_at or 0) < weeTs then
            self.reset(weeTs)
        end

        return true
    end

    function self.toArray(format)    
        local data = {}
        for k,v in pairs (self) do
            if type(v)~="function" and k~= 'uid' and k~= 'updated_at' then              
                if format then
                    if type(v) == 'table'  then
                        if next(v) then 
                            if k == 'info' then
                                data[k] = {}     

                                local tmpKey = {}  
                                for sk,_ in pairs(v) do
                                    table.insert(tmpKey,sk)
                                end

                                table.sort(tmpKey,function(a,b) return tonumber(a:sub(2))<tonumber(b:sub(2))  end)

                                for _,sk in ipairs(tmpKey) do
                                    table.insert(data[k],(v[sk].s or 0))
                                end                   
                            else
                                data[k] = v
                            end
                        end
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

    -- ----------------------------------------------------------------------------------------------

    -- 关卡是否已解锁 
        --  用户等级
        --  用户未通过前一关    
    -- sid int 关卡id
    -- userLv int 用户等级
    function self.checkUnlock(sid,userLv)
        userLv = userLv or 0
        local eChallengeCfg = getConfig('eliteChallengeCfg.challenge')
        
        if userLv < eChallengeCfg[sid].unlockLv then
            return false
        end

        if sid == 's1' then return true end
        
        if sid then
            local prevSid = 's' .. (sid:sub(2) - 1)
            if not arrayGet(self.info,prevSid) then
                return false
            end
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
        local firstWin = false
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
                self.star = self.star + addStar

                if currStar == 0 and sid == 's1' then
                    firstWin = true
                end

                -- 德国七日狂欢
                activity_setopt(self.uid,'sevendays',{act='sd17',v=0,n=self.star})
            end
        end

        return star,firstWin
    end

    -- 初始化军队属性
    function self.initDefFleetAttribute(tanks,skills,techs,defAttUp)
        local inittanks = initTankAttribute(tanks,techs,skills,nil,nil,2,{acAttributeUp=defAttUp})
        return inittanks
    end

    -- 格式化奖励
    function self.takeReward(reward,isTutorial)
        local award = {u={},p={},o={}}
        local uobjs = getUserObjs(self.uid)
        local mUserinfo = uobjs.getModel('userinfo')
        local mTech,techLevel

        if type(reward) == 'table' then
            setRandSeed()
            for k,v in pairs(reward) do
                -- 有概率获取到道具奖励
                if k == 'propbonus' and not isTutorial then
                    local randnum = rand(1,100)                    
                    -- 运气来了
                    if randnum <= v[3] then
                        local mBag = uobjs.getModel('bag')
                        mBag.add(v[1],v[2])
                        award.p[v[1]] = v[2]
                    end
                -- 经验
                elseif k =='exp' then
                        local oriv = v
                        techCfg = techCfg or getConfig('tech.t20')
                        mTech = mTech or uobjs.getModel('techs')
                        techLevel = techLevel or mTech.getTechLevel('t20')
                        v = math.floor(v + (techCfg.value[techLevel] or 0) / 100 * v)
                        v = activity_setopt(self.uid,'luckUp',{name='attackChallenge',item='exp',value=v}) or v

                        -- 全民劳动 补给线没有调用到这个接口
                        -- local laborRate = activity_setopt(self.uid,'laborday',{act='upRate',n=3})
                        -- if laborRate then
                        --     v=v + math.ceil(oriv*laborRate)
                        -- end
                        mUserinfo.addExp(v)
                        
                        award.u[k] = v
                -- 荣誉
                elseif k=='honors' then                    
                    mUserinfo.addHonor(v)
                    award.u[k] = v
                end
            end        
        end
        return award
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

        return data
    end

    -- 返回每日未击杀的关卡数量
    -- userLv int 用户等级
    -- return int 
    function self.getDailyNotKillNum(userLv)
        local num = 0
        local cfg = getConfig('eliteChallengeCfg.level4challenge')
        local lvUnlockNum = cfg[userLv] or 0
        local unlockNum = table.length(self.info)
        local killNum = table.length(self.dailykill)

        local versionLvCfg =getVersionCfg()        
        if versionLvCfg.unlockEliteChallenge and lvUnlockNum > versionLvCfg.unlockEliteChallenge then
            lvUnlockNum = versionLvCfg.unlockEliteChallenge
        end

        if unlockNum < lvUnlockNum then
            unlockNum = unlockNum + 1
        end

        num = unlockNum - killNum

        if num < 0 then num = 0 end

        return num
    end

    -- weeTs 当日凌晨时间
    -- userAction 是否用户触发
    function self.reset(weeTs,userAction)
        weeTs = weeTs or getWeeTs()
        if userAction then
            self.resetnum = self.resetnum + 1
        else 
            self.resetnum = 0
        end

        self.dailykill = {}        
        self.reset_at = weeTs
    end

    -- 击杀关卡后，标识每日击杀关卡
    function self.kill(sid)
        self.dailykill[sid] = 1
    end

    -- 获取可被扫荡的关卡
    function self.getAssaultable()
        local challenges = {}
        for k,v in pairs(self.info) do
            if not self.dailykill[k] and v.s >= 3 then
                table.insert(challenges,k)
            end
        end

        table.sort(challenges,function(a,b) return tonumber(a:sub(2))<tonumber(b:sub(2))  end)
        return challenges
    end

    -- 根据关卡id获取配置文件
        -- 奖励分为两部分，一部分是固定奖励，另一部分为概率性掉落，需要合并
    -- sid int 关卡
    -- challengeCfg table 关卡配置
    -- return table reward 具体奖励
    function self.getRewardBySid(sid,challengeCfg,firstWin, equip)
        challengeCfg = challengeCfg or getConfig('eliteChallengeCfg.challenge')

        local uobjs = getUserObjs(self.uid)
        local mSequip = uobjs.getModel('sequip')
        local equipvalue = mSequip.dySkillAttr(equip, 's103', 0) --关卡教条 攻打关卡时经验加成X%

        local reward 
        if firstWin then
            reward = {accessory_a1 = 1}
        else
            reward = getRewardByPool(challengeCfg[sid].propbonus) or {}
        end

        -- 全民劳动
        local laborRate = activity_setopt(self.uid,'laborday',{act='upRate',n=3})
        
        for m,n in pairs(challengeCfg[sid].award) do
            if m == 'userinfo_exp' then
                local addexp = n
                n = n + math.ceil(addexp*equipvalue)
                if laborRate then
                    n=n + math.ceil(addexp*laborRate)
                end
                
                reward[m] = (reward[m] or 0 ) + n
            else
                reward[m] = (reward[m] or 0 ) + n
            end

        end
        
        return reward
    end

    --------------------------------------------------------------------------------------------------------------
 

    return self
end 

