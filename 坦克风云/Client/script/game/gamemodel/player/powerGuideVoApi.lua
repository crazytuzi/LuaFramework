powerGuideVoApi={
    fcRank = nil,--战斗力排名
    bestHeroTb=nil,--当天打开页面计算战力最大的6个将领
    bestTankTb = nil,
    classTb = nil,--大类集合
    classDataTb = nil,
    CLASS_player = 1,
    CLASS_armor = 2, -- 装甲矩阵
    CLASS_accessory = 3, -- 配件
    CLASS_hero = 4, -- 英雄
    CLASS_alienweapon = 5, -- 超级武器
    CLASS_alientech = 6, -- 异星科技
    CLASS_superequip = 7, -- 军徽
    CLASS_plane = 8, -- 空战指挥所
    CLASS_strategy = 9, --战略中心
    CLASS_airship = 10, --战争飞艇
}

--每次重新打开战力引导页面时下面的数据要刷新
function powerGuideVoApi:clear()
    self.bestHeroTb = nil
    self.bestTankTb = nil
    self.classTb = nil
    self.classDataTb = nil
end

function powerGuideVoApi:setFcRank(rank)
    self.fcRank = rank
end

function powerGuideVoApi:getFcRank()
    if self.fcRank then
        return self.fcRank
    end
    return 0
end

function powerGuideVoApi:getClassTb()
    self.classTb = {}--1accessory 2equip 3armor 4alien
    local playerLv=playerVoApi:getPlayerLevel()
    --角色
    table.insert(self.classTb,powerGuideVoApi.CLASS_player)
    local flag=0
    --海兵军营(装甲矩阵)
    if base.armor == 1 and armorMatrixVoApi then
        local limitLv = armorMatrixVoApi:getPermitLevel()
        flag=1
        if limitLv and playerLv>= limitLv then
            flag=2
            table.insert(self.classTb,powerGuideVoApi.CLASS_armor)
        end
    end
    if flag==1 then
        table.insert(self.classTb,powerGuideVoApi.CLASS_armor)
        return self.classTb
    end
    flag=0

    --配件
    if base.ifAccessoryOpen==1 then
        flag=1
        if playerLv >=8 then
            table.insert(self.classTb,powerGuideVoApi.CLASS_accessory)
            flag=2
        end
    end
    if flag==1 then
        table.insert(self.classTb,powerGuideVoApi.CLASS_accessory)
        return self.classTb
    end
    flag=0
    --将领
    if base.heroSwitch==1 then
        flag=1
        if playerLv >=20 then
            table.insert(self.classTb,powerGuideVoApi.CLASS_hero)
            flag=2
        end
    end
    if flag==1 then
        table.insert(self.classTb,powerGuideVoApi.CLASS_hero)
        return self.classTb
    end
    flag=0

    --超级武器
    if base.ifSuperWeaponOpen==1 then 
        local superWeaponOpenLv=base.superWeaponOpenLv or 25
        flag=1
        if playerLv>=superWeaponOpenLv then
            table.insert(self.classTb,powerGuideVoApi.CLASS_alienweapon)
            flag=2
        end
    end

    if flag==1 then
        table.insert(self.classTb,powerGuideVoApi.CLASS_alienweapon)
        return self.classTb
    end
    flag=0

    --异星科技
    if base.alien==1 and base.richMineOpen==1 then 
        flag=1
        if playerLv>=alienTechCfg.openlevel then
            table.insert(self.classTb,powerGuideVoApi.CLASS_alientech)
            flag=2
        end
    end
    if flag==1 then
        table.insert(self.classTb,powerGuideVoApi.CLASS_alientech)
        return self.classTb
    end
    flag=0

    --军徽
    if base.emblemSwitch==1 and G_getBHVersion()~=2 then
        local permitLevel = emblemVoApi:getPermitLevel()
        flag=1
        if permitLevel and playerLv>=permitLevel then
            table.insert(self.classTb,powerGuideVoApi.CLASS_superequip)
            flag=2
        end
    end
    if flag==1 then
        table.insert(self.classTb,powerGuideVoApi.CLASS_superequip)
        return self.classTb
    end
    flag=0

    --空战指挥所
    if base.plane==1 then
        local permitLevel = planeVoApi:getOpenLevel()
        flag=1
        if permitLevel and playerLv>=permitLevel then
            table.insert(self.classTb,powerGuideVoApi.CLASS_plane)
            flag=2
        end
    end
    if flag==1 then
        table.insert(self.classTb,powerGuideVoApi.CLASS_plane)
        return self.classTb
    end
    flag=0

    --战略中心(不受开关控制)
    if G_isMemoryServer() == false or strategyCenterVoApi:isOpen() == true then
        flag = 1
        if playerLv >= strategyCenterVoApi:getOpenLv() then
            table.insert(self.classTb, powerGuideVoApi.CLASS_strategy)
            flag = 2
        end
        if flag == 1 then
            table.insert(self.classTb, powerGuideVoApi.CLASS_strategy)    
            return self.classTb
        end
        flag = 0
    end

    --战争飞艇
    if airShipVoApi and airShipVoApi:isCanEnter() == true then
        table.insert(self.classTb, powerGuideVoApi.CLASS_airship)
        flag = 2
    end
    flag = 0
    
    return self.classTb
end

function powerGuideVoApi:getMinUpgradeAccessory()
    local minLv=playerVoApi:getMaxLvByKey("roleMaxLevel")
    local minQuality=accessoryCfg.maxQuality+1
    local minVo
    for i=1,4 do
        for j=1,accessoryCfg.unLockPart do
            local aVo=accessoryVoApi:getAccessoryByPart(i,j)
            if(aVo~=nil)then
                if(aVo.lv<minLv)then
                    minLv=aVo.lv
                    minQuality=tonumber(aVo:getConfigData("quality"))
                    minVo=aVo
                elseif(aVo.lv==minLv)then
                    local quality=tonumber(aVo:getConfigData("quality"))
                    if(quality<minQuality)then
                        minLv=aVo.lv
                        minQuality=quality
                        minVo=aVo
                    end
                end
            end
        end
    end
    return minVo
end

function powerGuideVoApi:getAccessoryTotalLv()
    local total=0
    for i=1,4 do
        for j=1,accessoryCfg.unLockPart do
            local aVo=accessoryVoApi:getAccessoryByPart(i,j)
            if(aVo~=nil)then
                total=total+aVo.lv
            end
        end
    end
    return total
end

--获得已装配配件的精炼强度之和
function powerGuideVoApi:getAccessoryTotalSuccinct()
    local total=0
    local percent = 0
    local num = 0--未达到最大精炼强度的已装配配件数量

    local gsMaxAdd--精炼上限
    local succinctLv = accessoryVoApi:getSuccinct_level()
    local purpleGsMax = math.floor((succinctCfg.attLifeLimit[succinctLv])*800+(succinctCfg.arpArmorLimit[succinctLv])*20)
    local orangeGsMax = math.floor((succinctCfg.attLifeLimit[succinctLv] * 2)*800+(succinctCfg.arpArmorLimit[succinctLv] * 2)*20)
    if base.accessoryEvolutionSwitch==1 then
        gsMaxAdd = orangeGsMax
    else--配件突破开关没有打开的话，配件的最大品质是紫色，紫色品质的配件在精炼的时候精炼上限会打五折
        gsMaxAdd = purpleGsMax
    end

    local unLockPart = accessoryVoApi:getUnlockPartByLv(playerVoApi:getPlayerLevel())
    local maxSuccinct = unLockPart*gsMaxAdd*4
    

    local itemGs
    for i=1,4 do
        for j=1,unLockPart do
            local aVo=accessoryVoApi:getAccessoryByPart(i,j)
            if(aVo~=nil)then
                itemGs = aVo:getGsAdd()
                total=total+itemGs
                if itemGs < gsMaxAdd then
                    num = num + 1
                end
                local quality = aVo:getConfigData("quality")
                if quality == 3 then
                    maxSuccinct = maxSuccinct - gsMaxAdd + purpleGsMax
                end
            end
        end
    end

    if total > 0 and maxSuccinct > 0 then
        percent = total/maxSuccinct
    end
    if percent > 1 then
        percent = 1
    end

    return percent,num
end

--获得已装配配件科技
function powerGuideVoApi:getAccessoryTotalTech()
    local percent = 0
    local num = 0
    local unLockPart = accessoryVoApi:getUnlockPartByLv(playerVoApi:getPlayerLevel()) -- 当前等级解锁部位
    local techMaxLv=accessoryVoApi:getTechMaxLv()
    local totalMaxLv = unLockPart*4*techMaxLv
    local total=0

    for i=1,4 do
        for j=1,unLockPart do
            local aVo=accessoryVoApi:getAccessoryByPart(i,j)
            if(aVo~=nil)then
                local techLv=aVo.techLv or 0
                total=total+techLv
                if techLv >= techMaxLv then
                    num = num + 1
                end
            end
        end
    end
    percent=total/totalMaxLv
    num=unLockPart*4-num
    return percent,num
end

function powerGuideVoApi:checkCanUpgrade()
    local result=false
    for i=1,4 do
        for j=1,accessoryCfg.unLockPart do
            local canUpgrade=accessoryVoApi:checkCanUpgrade(i,j)
            if(canUpgrade==0)then
                return canUpgrade
            elseif(canUpgrade==2)then
                result=canUpgrade
            end
        end
    end
    return result
end

function powerGuideVoApi:getMinSmeltAccessory()
    local maxQuality=accessoryCfg.maxQuality
    local minRank=accessoryVoApi:getSmeltMaxRank(maxQuality)
    -- local minRank=accessoryCfg.smeltMaxRank
    local minQuality=accessoryCfg.maxQuality+1
    local minVo
    for i=1,4 do
        for j=1,accessoryCfg.unLockPart do
            local aVo=accessoryVoApi:getAccessoryByPart(i,j)
            if(aVo~=nil)then
                if(aVo.rank<minRank)then
                    minRank=aVo.rank
                    minQuality=tonumber(aVo:getConfigData("quality"))
                    minVo=aVo
                elseif(aVo.rank==minRank)then
                    local quality=tonumber(aVo:getConfigData("quality"))
                    if(quality<minQuality)then
                        minRank=aVo.rank
                        minQuality=quality
                        minVo=aVo
                    end
                end
            end
        end
    end
    return minVo
end

function powerGuideVoApi:getAccessoryTotalRank()
    local total=0
    if base.ifAccessoryOpen~=1 then
        return total
    end
    for i=1,4 do
        for j=1,accessoryCfg.unLockPart do
            local aVo=accessoryVoApi:getAccessoryByPart(i,j)
            if(aVo~=nil)then
                total=total+aVo.rank
            end
        end
    end
    return total
end

function powerGuideVoApi:checkCanSmelt()
    local result=false
    for i=1,4 do
        for j=1,accessoryCfg.unLockPart do
            local canUpgrade=accessoryVoApi:checkCanSmelt(i,j)
            if(canUpgrade==0)then
                return canUpgrade
            elseif(canUpgrade>=20 and canUpgrade<30)then
                result=canUpgrade
            end
        end
    end
    return result
end

function powerGuideVoApi:getEquipedAccessoryScore()
    local total=0
    local num = 0--未达到最大品质的配件位
    if base.ifAccessoryOpen~=1 then
        return total,num
    end
    local unLockPart=accessoryVoApi:getUnlockPartByLv(playerVoApi:getPlayerLevel())
    for i=1,4 do
        for j=1,unLockPart do
            local aVo=accessoryVoApi:getAccessoryByPart(i,j)
            if(aVo~=nil)then
                local quality=tonumber(aVo:getConfigData("quality"))
                total=total+quality
                if quality < accessoryCfg.maxQuality then
                    num = num + 1  
                end
            else
                num = num + 1
            end
        end
    end
    return total,num
end

--旧版配件品质之更好的配件
-- function powerGuideVoApi:getUnEquipedPurpleAccessoryNum()
--     local total=0
--     if base.ifAccessoryOpen~=1 then
--         return total
--     end
--     local allAccessory=accessoryVoApi:getAccessoryBag()
--     if allAccessory ~= nil then
--         for k,v in pairs(allAccessory) do
--             local quality=tonumber(v:getConfigData("quality"))
--             if(quality>2)then
--                 local tankID=v:getConfigData("tankID")
--                 local part=v:getConfigData("part")
--                 local equipedAvo=accessoryVoApi:getAccessoryByPart(tankID,part)
--                 if(equipedAvo==nil or tonumber(equipedAvo:getConfigData("quality"))<quality)then
--                     total=total+1
--                 end
--             end
--         end
--     end
--     return total
-- end

function powerGuideVoApi:getWorstPower()
    local bestTanks=self:getBestTankTb()
    local minPower
    for k,v in pairs(bestTanks) do
        local power=math.pow(1,0.7)*v[3]
        if(minPower==nil or minPower>power)then
            minPower=power
        end
    end
    if(minPower==nil)then
        minPower=0
    end
    return minPower
end

function powerGuideVoApi:getTankNumInBestTanks()
    local bestTanks=self:getBestTankTb()
    local count=0
    for k,v in pairs(bestTanks) do
        count=count+v[2]
    end
    return count
end

--获得异星武器百分比
function powerGuideVoApi:getAlienWeaponPercent(idx)
    local percent=0
    local num = 0--未达到最大品质的超级武器
    local equipList=superWeaponVoApi:getEquipList()


    local lockPart = SizeOfTable(superWeaponCfg.weaponCfg)
    

    if idx==1 then
        -- 6 六个位置（一定）
        local totalQuality=0
        local nowTotalQuality=0
        for i=lockPart,lockPart-5,-1 do
            local quality=superWeaponCfg.weaponCfg["w" .. i].quality or 0
            totalQuality=totalQuality+quality
        end
        local totalNum1=0 -- 品质1的个数
        local totalNum2=0 -- 品质2的个数
        -- 最大品质 4个2+2个1
        for k,v in pairs(equipList) do
            if v and v~=0 then
                local quality=superWeaponCfg.weaponCfg[v].quality or 0
                nowTotalQuality=nowTotalQuality+quality
                if quality==1 then
                    totalNum1=totalNum1+1
                else
                    totalNum2=totalNum2+1
                end
            end
        end
        percent=nowTotalQuality/totalQuality
        num=4-totalNum2+2-totalNum1
    elseif idx==2 then
        local nowtotalLevel=0
        local lockLevel = superWeaponCfg.maxLv
        for k,v in pairs(equipList) do
            if v and v~=0 then
                local weaponInfo=superWeaponVoApi:getWeaponByID(v)
                local lv=weaponInfo.lv or 0
                if lv>=lockLevel then
                    num=num+1
                end
                nowtotalLevel=nowtotalLevel+lv

            end
        end
        local totalLevel=lockLevel*6
        percent=nowtotalLevel/totalLevel
        num=6-num
    elseif idx==3 then
        -- 6:6个位置 3:一个武器装3个结晶
        local totalLevel=6*3*superWeaponCfg.maxCLv
        local nowtotalLevel=0
        for k,v in pairs(equipList) do
            if v and v~=0 then
                local weaponInfo=superWeaponVoApi:getWeaponByID(v)
                local slots=weaponInfo.slots
                for kk,vv in pairs(slots) do
                    if vv and vv~=0 then
                        local lv=superWeaponCfg.crystalCfg[vv].lvl or 0
                        nowtotalLevel=nowtotalLevel+lv
                        if lv>=superWeaponCfg.maxCLv then
                            num=num+1
                        end
                    end
                end
            end
        end
        percent=nowtotalLevel/totalLevel
        num=6*3-num
    end
    return percent,num
end


--获得超级装备百分比
function powerGuideVoApi:getBattleEquipPercent(idx)
    --最大出征队列数
    local fleetsNums=Split(playerCfg.actionFleets,",")[playerVoApi:getVipLevel()+1] 
    if emblemVoApi and fleetsNums then
        local num = tonumber(fleetsNums)--未满足条件的数量
        local maxLv1 = playerVoApi:getMaxLvByKey("emblemUpgrade4Lv")
        local maxLv2 = playerVoApi:getMaxLvByKey("emblemUpgrade5Lv")
        local totalMaxLv = num * maxLv2

        print("+++++++fleetsNums,maxLv2",fleetsNums,maxLv2,maxLv1)

        local allEquip = emblemVoApi:getEquipList()
        local selectNum = 0
        local cloneEquip = {}

        if allEquip then
            for k,v in pairs(allEquip) do
                if selectNum >= num then
                    break
                else
                    local cfg = v.cfg
                    if cfg.etype == 1 then
                        for j=1,v.num do
                            table.insert(cloneEquip,{v.id,cfg.qiangdu})
                            selectNum = selectNum + 1
                        end
                    end
                end
            end
        end

        local function sortFunc(a,b)
            return a[2]>b[2]
        end
        table.sort(cloneEquip,sortFunc)

        local percent = 0
        local sum = 0
        
        local cfg,v
        for i=1,num do
            v = cloneEquip[i]
            if v  then
                cfg = emblemVoApi:getEquipCfgById(v[1])
                if idx == 1 then
                    if cfg and cfg.color then
                        sum  = sum + cfg.color
                        if cfg.color >= 5 then
                            num = num - 1
                        end
                    end
                elseif idx == 2 then

                    if cfg and cfg.lv then--绿色1 蓝色2 紫色3 橙色4
                        local addLv = cfg.lv
                        if cfg.color<4 and addLv < 1 then
                            addLv = 1
                        end
                        sum = sum + addLv

                        local maxLv = maxLv2
                        if cfg.color == 4 then
                            maxLv = maxLv1
                        elseif cfg.color ~= 5 then
                            maxLv = addLv
                        end

                        --如果当前超级装备的等级已经达到最大等级了，那么就完成了一个
                        if addLv >= maxLv then
                            num = num - 1
                        end
                        totalMaxLv = totalMaxLv - maxLv2
                        totalMaxLv = totalMaxLv + maxLv
                    end
                end
            end
        end
        
        if sum > 0 then
            if idx == 1 then
                percent = sum/(fleetsNums * 5) --5 都是橙色品质
            elseif idx == 2 and totalMaxLv > 0 then
                percent = sum/totalMaxLv
            end
        end
        if percent > 1 then
            percent = 1
        end
        return percent,num
    end
    return 0,fleetsNums
end

--获得空战指挥所百分比
function powerGuideVoApi:getPlanePercent(idx)
    local percent,num=0,0
    local slotNum=planeVoApi:getSlotNumByLevel()
    local planeList=planeVoApi:getPlaneList()

    if planeList then
        local refitFlag
        if (not planeRefitVoApi:isFirstEnter()) and planeRefitVoApi and planeRefitVoApi:isCanEnter() == true then
            refitFlag = true
        end
        if idx==1 then -- 技能品质
            -- 5:5个位置能装技能
            local maxupcolor=planeGetCfg.upgrade.maxupcolor
            local totalNum=maxupcolor*5*slotNum
            if refitFlag then
                totalNum=maxupcolor*(5+1)*slotNum
            end
            
            local addNum=0
            for k,v in pairs(planeList) do
                local aSkillTb=v.aSkillTb
                local pSkillTb=v.pSkillTb
                for kk,vv in pairs(aSkillTb) do
                    if vv~=0 then
                        local _,cfg=planeVoApi:getSkillCfgById(vv)
                        local color=cfg.color
                        if color>=maxupcolor then
                            num=num+1
                        end
                        addNum=addNum+color
                    end
                end
                for kk,vv in pairs(pSkillTb) do
                    if vv~=0 then
                        local _,cfg=planeVoApi:getSkillCfgById(vv)
                        local color=cfg.color
                        if color>=maxupcolor then
                            num=num+1
                        end
                        addNum=addNum+color
                    end
                end
            end
            if refitFlag then
                num=(5+1)*slotNum-num
            else
                num=5*slotNum-num
            end
            percent=addNum/totalNum
        elseif idx==2 then -- 技能等级
            local maxLv1 = playerVoApi:getMaxLvByKey("pskillUpgrade4Lv")
            local maxLv2 = playerVoApi:getMaxLvByKey("pskillUpgrade5Lv")
            local totalNum=5*slotNum
            if refitFlag then
                totalNum=(5+1)*slotNum
            end
            local addNum=0

            for k,v in pairs(planeList) do
                local aSkillTb=v.aSkillTb
                local pSkillTb=v.pSkillTb
                for kk,vv in pairs(aSkillTb) do
                    if vv~=0 then
                        local _,cfg=planeVoApi:getSkillCfgById(vv)
                        local lv=cfg.lv
                        if not lv then
                            addNum=addNum+1
                            num=num+1
                        else
                            local color=cfg.color
                            local maxLv=maxLv1
                            if color==5 then
                                maxLv=maxLv2
                            end
                            addNum=addNum+lv/maxLv
                        end
                    end
                end
                for kk,vv in pairs(pSkillTb) do
                    if vv~=0 then
                        local _,cfg=planeVoApi:getSkillCfgById(vv)
                        local lv=cfg.lv
                        if not lv then
                            addNum=addNum+1
                            num=num+1
                        else
                            local color=cfg.color
                            local maxLv=maxLv1
                            if color==5 then
                                maxLv=maxLv2
                            end
                            addNum=addNum+lv/maxLv
                            if lv>=maxLv then
                                num=num+1
                            end
                        end
                    end
                end
            end
            if refitFlag then
                num=(5+1)*slotNum-num
            else
                num=5*slotNum-num
            end
            percent=addNum/totalNum
        elseif idx == 3 and refitFlag then --战机改装
            local strength, strengthMax = 0, 0
            local prCfg = planeRefitVoApi:getCfg()
            for k, v in ipairs(prCfg.refit) do --5个部位
                for kk, vv in ipairs(v) do --4架战机
                    for kkk, vvv in ipairs(vv) do --4个改装类型
                        local refitExp = planeRefitVoApi:getRefitExp(k, kk, kkk)
                        --基础技能
                        local skill1Cfg = planeRefitVoApi:getSkillCfg(vvv.skill1)
                        if skill1Cfg then
                            strength = strength + skill1Cfg.intensity * refitExp / 100
                            local refitExpMax = planeRefitVoApi:getRefitTypeData(k, kk, kkk).powerMax
                            strengthMax = strengthMax + skill1Cfg.intensity * refitExpMax / 100
                        end
                        --激活技能
                        for skillIndex, skillId in pairs(vvv.skill2) do
                            local skill2Cfg = planeRefitVoApi:getSkillCfg(skillId)
                            if refitExp >= vvv.powerNeed[skillIndex] then --是否激活
                                if skill2Cfg then
                                    local skillLv = planeRefitVoApi:getSkillLevel(k, kk, kkk, skillIndex)
                                    strength = strength + skill2Cfg.intensity * skillLv
                                end
                            end
                            if skill2Cfg then
                                local skillLvMax = SizeOfTable(prCfg.skillUp)
                                strengthMax = strengthMax + skill2Cfg.intensity * skillLvMax
                            end
                        end
                    end
                end
            end
            percent = math.floor(strength) / strengthMax
        end
    end
    return percent,num
end

function powerGuideVoApi:getBestHeroTb()
    if self.bestHeroTb == nil then
        self.bestHeroTb = {}
        if base.heroSwitch == 1 then
            local heroList = heroVoApi:getHeroList()
            local attrTb = {}
            for k,v in pairs(heroList) do
                if v and v.hid then
                    local fightingAttr = heroVoApi:getFightingByHeros(v.hid)
                    table.insert(attrTb,{id = v.hid,value = fightingAttr})
                end
            end
            local function sortFunc(a,b)
                return a.value>b.value
            end
            table.sort(attrTb,sortFunc)
            for i=1,6 do
                if attrTb[i] then
                    self.bestHeroTb[i] = attrTb[i].id
                end
            end
        end
    end
    return self.bestHeroTb
end

function powerGuideVoApi:getBestTankTb()
    if self.bestTankTb == nil then
        -- self.bestTankTb = tankVoApi:getBestTanks()
       -- 判断军徽开关，选择强度最高的军徽
        local maxEmblemID = nil
        if emblemVoApi:checkIfHadEquip()==true then
            maxEmblemID = emblemVoApi:getMaxStrongEquip()
        end
        emblemVoApi:setTmpEquip(maxEmblemID)    
        -- 最大战力
        local bestTab={}
        local temTanks=tankVoApi:getAllTanks()
        local singleTankFighting={}
        local num=playerVoApi:getTotalTroops()
        for k,v in pairs(temTanks) do
            singleTankFighting[k]=tankVoApi:getSingleTankFighting(k)
            local numTank=v[1]
            if numTank>num then
                local count=math.floor(numTank/num)
                if count>6 then
                    count=6
                end
                for i=1,count,1 do
                    table.insert(bestTab, {k,num,singleTankFighting[k]})
                end
                local otherCount=numTank%num
                if otherCount>0 then
                    table.insert(bestTab, {k,otherCount,singleTankFighting[k]})
                end                
            else
                if numTank>0 then
                    table.insert(bestTab, {k,numTank,singleTankFighting[k]})
                end
            end
        end

        local sortTb=function(a,b)
            return math.pow(a[2],0.7)*a[3] > math.pow(b[2],0.7)*b[3]
        end
        table.sort(bestTab,sortTb)

        
        self.bestTankTb={}
        for k,v in pairs(bestTab) do
            if k<=6 and v[2]>0 then
                table.insert(self.bestTankTb,k,v)
            end
        end
    end
    return self.bestTankTb
end

--得到当前品质最高的将领
function powerGuideVoApi:getMaxQualityHero()
    if base.heroSwitch == 1 then
        local heroList = heroVoApi:getHeroList()
        local quality = 0 
        local heroId
        local maxQuality = heroVoApi:getHeroMaxQuality()
        for k,v in pairs(heroList) do
            if v and v.productOrder and v.hid and v.productOrder > quality then
                quality = v.productOrder
                heroId = v.hid
                if quality == maxQuality then
                   return heroId
                end 
            end
        end
        return heroId
    end
    return nil
end

--将领品质
function powerGuideVoApi:getHeroQuaLityPercent(idx)
    if idx == 4 then
        return self:getHeroEquipPercent()
    elseif idx == 5 then
        return self:getHeroAdjutantPercent()
    end
    local percent = 0
    local num = 0
    if base.heroSwitch == 1 then
        local maxValue
        local attrTb = self:getBestHeroTb()
        if idx == 1 then
            maxValue = heroVoApi:getHeroMaxQuality()
            num = 6--六个位置
        elseif idx == 2 then
            maxValue = heroVoApi:getHeroMaxLevel()

            local pLv = playerVoApi:getPlayerLevel()
            if maxValue > pLv then
                maxValue = pLv
            end

            num = SizeOfTable(attrTb)
        elseif idx == 3 then
            maxValue = 0
            num = SizeOfTable(attrTb)
        end
        local sum = 0
        local heroVo
        for i=1,6 do
            if attrTb[i] then
                heroVo = heroVoApi:getHeroByHid(attrTb[i])
                if heroVo then
                    if idx == 1 then
                        sum = sum + heroVo.productOrder
                        if heroVo.productOrder >= maxValue then
                            num = num - 1
                        end
                    elseif idx == 2 then
                        sum = sum + heroVo.level
                        if heroVo.level >= maxValue then
                            num = num - 1
                        end
                    elseif idx == 3 then
                        --所有将领技能等级之和/将领当前品质开放的技能在当前品质下可升级的最大等级之和
                        for k1,v1 in pairs(heroVo.skill) do
                            if v1 > 0 then
                                sum = sum + v1
                            end
                        end

                        for k2,v2 in pairs(heroVo.honorSkill) do
                            if v2 and v2[2] and v2[2]> 0 then
                                sum = sum + v2[2]
                            end
                        end

                        for sk,sv in pairs(heroListCfg[heroVo.hid].skills) do
                            if heroVo.skill[sv[1]] or  heroVo.honorSkill[sk] then
                                maxValue = maxValue + sv[2][heroVo.productOrder]
                            end
                        end
                    end
                end
            end
        end

        if sum > 0 and maxValue > 0 then
            if idx == 1 or idx == 2 then
                percent =  sum/(maxValue * 6)
            elseif idx == 3 then
                percent = sum/maxValue
            elseif idx == 4 then
                percent = maxValue
            end
        end
        if percent > 1 then
            percent = 1
        end
    end
    return percent,num
end

--将领装备
function powerGuideVoApi:getHeroEquipPercent()
    local percent = 0
    local num = 0--六个位置
    local addTotalValue = 0
    if base.heroSwitch == 1 then
        -- 后端version限制的等级
        local unEquipLevel = playerVoApi:getMaxLvByKey("unEquipLevel")
        local maxQuality = heroVoApi:getHeroMaxQuality()
        local attrTb = self:getBestHeroTb()
        num = SizeOfTable(attrTb) * 6
        local qsum,psum,asum = 0,0,0
        local qTotal,pTotal,aTotal = 0,0,0
        local heroVo
        for i=1,6 do
            if attrTb[i] then
                heroVo = heroVoApi:getHeroByHid(attrTb[i])
                if heroVo then
                    local equipList = heroEquipVoApi:getEquipVo(heroVo.hid)
                    for j=1,6 do
                        local sid = "e"..j
                        local qlevel=1
                        local plevel=1
                        local alevel=0
                        local flag = true--是否完成的标志
                        if equipList and equipList.eList and equipList.eList[sid] then
                            qlevel = equipList.eList[sid][1]
                            plevel = equipList.eList[sid][2]
                            alevel = equipList.eList[sid][3]
                        end
                        qsum = qsum + qlevel
                        psum = psum + plevel
                        asum = asum + alevel

                        local maxLevel = heroEquipVoApi:getCanUpgradeMaxUpLevel(plevel)
                        qTotal = qTotal + maxLevel
                        if qlevel < maxLevel then
                            flag = false
                        end

                        --将领的品质决定装备的最大进阶等级
                        local curMaxLv = equipCfg.upgradeLimit[maxQuality]--heroVo.productOrder
                        if curMaxLv < unEquipLevel then
                            curMaxLv = unEquipLevel
                        end

                        pTotal = pTotal + curMaxLv

                        if plevel < curMaxLv then
                            flag = false
                        end

                        local awakenMaxLv = heroEquipVoApi:getAwakenMaxLevel(heroVo.hid,sid)
                        aTotal = aTotal + awakenMaxLv

                        if alevel < awakenMaxLv then
                            flag = false
                        end
                        if flag == true then
                            num = num - 1
                        end
                    end
                end
            end
        end
        if qsum > 0 and qTotal > 0  then
            local qPer = qsum/qTotal
            if qPer > 1 then
                qPer = 1
            end
            percent = qPer * 0.35
            if heroAdjutantVoApi:isOpen() then
                addTotalValue = addTotalValue + qPer * 0.14
            else
                addTotalValue = addTotalValue + qPer * 0.16
            end
        end
        if psum > 0 and pTotal > 0 then
            local pPer = psum/pTotal
            if pPer > 1 then
                pPer = 1
            end
            percent = percent + pPer * 0.35
            if heroAdjutantVoApi:isOpen() then
                addTotalValue = addTotalValue + pPer * 0.12
            else
                addTotalValue = addTotalValue + pPer * 0.14
            end
        end
        if asum > 0 and aTotal > 0 then
            local aPer = asum/aTotal
            if aPer > 1 then
                aPer = 1
            end
            percent = percent + aPer * 0.3
            if heroAdjutantVoApi:isOpen() then
                addTotalValue = addTotalValue + aPer * 0.08
            else
                addTotalValue = addTotalValue + aPer * 0.1
            end
        end
        if percent > 1 then
            percent = 1
        end
    end
    return percent,num,addTotalValue
end

--将领副官
function powerGuideVoApi:getHeroAdjutantPercent()
    local percent = 0
    local num = 0--六个位置
    local addTotalValue = 0
    if base.heroSwitch == 1 then
        local attrTb = self:getBestHeroTb()
        num = SizeOfTable(attrTb) * 4
        local maxAllAdjLevel, maxAllAdjQuality = 0, 0
        local curAllAdjLevel, curAllAdjQuality = 0, 0
        for i = 1, 6 do
            if attrTb[i] then
                local heroVo = heroVoApi:getHeroByHid(attrTb[i])
                if heroVo then
                    if heroAdjutantVoApi:isCanEquipAdjutant(heroVo) then
                        local heroAdjData = heroAdjutantVoApi:getAdjutant(heroVo.hid)
                        local maxAdjLevel, maxAdjQuality, canEquipMaxQuality = heroAdjutantVoApi:getAdjutantMaxTotalValue(heroVo)
                        maxAllAdjLevel = maxAllAdjLevel + maxAdjLevel
                        maxAllAdjQuality = maxAllAdjQuality + maxAdjQuality
                        if heroAdjData then
                            for j = 1, 4 do
                                if heroAdjData[j] and heroAdjData[j][3] and heroAdjData[j][4] then
                                    local adjCfgData = heroAdjutantVoApi:getAdjutantCfgData(heroAdjData[j][3])
                                    local ajdCurLv = heroAdjData[j][4]
                                    curAllAdjLevel = curAllAdjLevel + ajdCurLv
                                    curAllAdjQuality = curAllAdjQuality + adjCfgData.quality
                                    if ajdCurLv >= adjCfgData.lvMax and adjCfgData.quality >= canEquipMaxQuality then
                                        num = num - 1
                                    end
                                elseif heroVo.productOrder < heroAdjutantVoApi:getAdjutantCfg().needHeroStar[j] then --不可激活
                                    num = num - 1
                                end
                            end
                        end
                    else
                        num = num - 4
                    end
                end
            end
        end
        if curAllAdjLevel > 0 and maxAllAdjLevel > 0 then
            local levelPer = curAllAdjLevel / maxAllAdjLevel
            if levelPer > 1 then
                levelPer = 1
            end
            percent = percent + levelPer * 0.8
            addTotalValue = addTotalValue + levelPer * (0.12 * 0.8)
        end
        if curAllAdjQuality > 0 and maxAllAdjQuality > 0 then
            local qualityPer = curAllAdjQuality / maxAllAdjQuality
            if qualityPer > 1 then
                qualityPer = 1
            end
            percent = percent + qualityPer * 0.2
            addTotalValue = addTotalValue + qualityPer * (0.12 * 0.2)
        end
        if percent > 1 then
            percent = 1
        end
    end
    return percent, num, addTotalValue
end


function powerGuideVoApi:getArmorMatrixPercent(idx)
    if armorMatrixVoApi then
        local armorInfo = armorMatrixVoApi:getArmorMatrixInfo()
        if armorInfo and armorInfo.used then
            local usedArmor = armorInfo.used

            local playerLevel=playerVoApi:getPlayerLevel()
            local maxLvSize = SizeOfTable(armorCfg.upgradeMaxLv)
            local levelLimit=armorCfg.upgradeMaxLv[maxLvSize-1]
            if base.armorbr==1 then
                levelLimit = levelLimit + armorCfg.upgradeMaxLv[maxLvSize]
            else
                if levelLimit>playerLevel then
                    levelLimit=playerLevel
                end
            end

            local percent = 0
            local sum = 0
            local num = 36--未满足条件的数量
            local cfg
            local wVo
            for k,v in pairs(usedArmor) do
                if v and SizeOfTable(v) > 0 then
                    for k1,v1 in pairs(v) do
                        if v1 then
                            local mid,level=armorMatrixVoApi:getMidAndLevelById(v1)
                            cfg = armorMatrixVoApi:getCfgByMid(mid)
                            if idx == 1 then
                                if cfg and cfg.quality then
                                    local addSun = 0
                                    if cfg.quality == 1 then
                                        addSun = 1
                                    elseif cfg.quality == 2 then
                                        addSun = 3
                                    elseif cfg.quality == 3 then
                                        addSun = 5
                                    elseif cfg.quality == 4 then
                                        addSun = 10
                                    elseif (base.armorbr==1) and cfg.quality == 5 then
                                        addSun = 15
                                    end

                                    sum  = sum + addSun
                                    if addSun >= ((base.armorbr==1) and 15 or 10) then
                                        num = num -1
                                    end
                                end
                            elseif idx == 2 and cfg then
                                if base.armorbr==1 and cfg and cfg.quality == 5 then
                                    level = level + armorCfg.upgradeMaxLv[maxLvSize-1]
                                end
                                if level and level > 0 then--绿色1 蓝色2 紫色3 橙色4
                                    sum = sum + level
                                    if level >= levelLimit then
                                        num = num - 1
                                    end
                                end
                            end
                        end
                    end
                end
            end
            
            if sum > 0 then
                if idx == 1 then
                    if base.armorbr==1 then
                        percent = sum/(15 * 6 * 6) --15 是橙色品质对应的占比
                    else
                        percent = sum/(10 * 6 * 6) --10 是紫色品质对应的占比
                    end
                elseif idx == 2 then
                    percent = sum/(levelLimit * 6 * 6)
                end
            end
            return percent,num
        end
    end
    return 0,36
end

--战略中心
function powerGuideVoApi:getStrategyPercent(idx)
    local percent, num = 0, 0
    local scCfg = strategyCenterVoApi:getStrategyCenterCfg()
    if scCfg["strategy" .. idx] then
        local skillTb = scCfg["strategy" .. idx].skill
        if skillTb then
            local maxLevel = SizeOfTable(scCfg["strategy" .. idx].skillCost)
            local totalIntensity, curIntensity = 0, 0
            for skillId, v in pairs(skillTb) do
                totalIntensity = totalIntensity + maxLevel * v.intensity
                local skillLevel = strategyCenterVoApi:getSkillLevel(skillId)
                curIntensity = curIntensity + skillLevel * v.intensity
                if strategyCenterVoApi:isCanUpgrade(skillId, skillLevel) then
                    num = num + 1
                end
            end
            if totalIntensity > 0 then
                percent = curIntensity / totalIntensity
            end
        end
    end
    if percent > 1 then
        percent = 1
    end
    return percent, num
end

--战争飞艇
function powerGuideVoApi:getAirShipPercent(idx)
    local percent, num = 0, 0
    local asCfg = airShipVoApi:getAirShipCfg()
    if asCfg then
        if idx == 1 then --战斗艇当前强度/战斗艇总强度 (这里战术洗练不参与强度值计算)
            local curStrength, totalStrength = 0, 0
            local equipMaxQuality = SizeOfTable(asCfg.asEquip) --装置的最大品质
            local maxQualityNum, curMaxQualityNum = 0, 0
            for k, v in pairs(asCfg.airship) do
                if v.target > 0 then --排除非战斗艇
                    --计算当前飞艇的强度值
                    local curAirShipData = airShipVoApi:getCurAirShipInfo(k)
                    if curAirShipData then
                        local airShipEquip = curAirShipData[2]
                        for equipId, equipQuality in pairs(airShipEquip) do
                            if asCfg.asEquip[equipQuality] and asCfg.asEquip[equipQuality][equipId] then
                                local equipCfg = asCfg.asEquip[equipQuality][equipId]
                                curStrength = curStrength + equipCfg.strength
                            end
                            if equipQuality == equipMaxQuality then
                                curMaxQualityNum = curMaxQualityNum + 1
                            end
                        end
                        local combineEffect = airShipVoApi:getCurAirShipEquipInfo(curAirShipData)
                        local qualityFour, qualityTwo = (combineEffect[4] or 0), (combineEffect[2] or 0)
                        if qualityFour and qualityFour > 0 then
                            local combineStrength = asCfg.combine[4].strength[qualityFour]
                            if combineStrength then
                                curStrength = curStrength + combineStrength
                            end
                        end
                        if qualityTwo and qualityTwo > 0 then
                            local combineStrength = asCfg.combine[2].strength[qualityTwo]
                            if combineStrength then
                                curStrength = curStrength + combineStrength
                            end
                        end
                    end
                    --计算最大品质飞艇的强度值
                    for kk, equipId in pairs(v.equipId) do
                        if asCfg.asEquip[equipMaxQuality] and asCfg.asEquip[equipMaxQuality][equipId] then
                            local equipCfg = asCfg.asEquip[equipMaxQuality][equipId]
                            totalStrength = totalStrength + equipCfg.strength
                        end
                        maxQualityNum = maxQualityNum + 1
                    end
                    for combineIdx, combineCfg in pairs(asCfg.combine) do
                        totalStrength = totalStrength + (combineCfg.strength[equipMaxQuality] or 0)
                    end
                end
            end
            if totalStrength > 0 then
                percent = curStrength / totalStrength
            end
            if maxQualityNum >= curMaxQualityNum then
                num = maxQualityNum - curMaxQualityNum
            end
        end
    end
    if percent > 1 then
        percent = 1
    end
    return percent, num
end

function powerGuideVoApi:getClassContentData(classIndex,addContent)
    if addContent == nil then
        addContent = true
    end
    if self.classDataTb == nil or  self.classDataTb[classIndex] == nil then
        if self.classDataTb == nil then
            self.classDataTb = {}
        end
        local classData={}--{大类名称，{百分比,是否可以点击,下面的文字,图片,上面的文字}，大类百分比}
        local totalPercent--每一项在种类中所占的比重
        local totalValue = 0
        local picStr
        local upStr
        local downStr
        local percent=0
        local clickable=false
        if classIndex == self.CLASS_player then--角色
            --大类名字/图片/小类信息/总百分比
            classData = {getlocal("player_playerName"),{},0}
            if addContent == true then
                totalPercent = {0.1,0.1,0.28,0.1,0.2,0.2,0.02}
                for idx=1,7 do
                    if(idx==1)then--统率等级
                        percent=playerVoApi:getTroops()/playerVoApi:getPlayerLevel()
                        if(playerVoApi:getTroops()>=playerVoApi:getPlayerLevel())then
                            clickable=false
                        else
                            clickable=true
                        end
                    elseif(idx==2)then--技能等级
                        percent=0
                        local allSkills=skillVoApi:getAllSkills()
                        local totalSkill=0
                        for k,v in pairs(allSkills) do
                            totalSkill=totalSkill+v.lv
                        end
                        local skillLimit
                        if(base.nbSkillOpen==1 and playerVoApi:getPlayerLevel()>=playerSkillCfg.openlevel)then
                            --陶也给的特殊算法，参数是什么意思得问陶也
                            skillLimit=playerVoApi:getPlayerLevel()*( 4 + 8 + 2 + 8 ) + 12*5 - 500
                        else
                            --以前只有12个技能
                            skillLimit=12*playerVoApi:getPlayerLevel()
                        end
                        percent=totalSkill/skillLimit
                        
                        if(totalSkill>=skillLimit)then
                            clickable=false
                        else
                            clickable=true
                        end
                    elseif(idx==3)then--科技等级
                        local totalTech=0
                        clickable=false
                        percent=0
                        local lv,cur,next = playerVoApi:getHonorInfo()
                        local singleLimit=math.min(playerVoApi:getMaxLvByKey("techMaxLevel"),lv)
                        local techLimit=singleLimit*8
                        local buildVo=buildingVoApi:getBuildiingVoByBId(3)
                        if(buildVo and buildVo.level>0)then
                            for i=1,8 do
                                local techVo=technologyVoApi:getTechVoByTId(i)
                                if(techVo~=nil)then
                                    totalTech=totalTech+techVo.level
                                end
                                if(techVo.level<singleLimit)then
                                    clickable=true
                                end
                            end
                        end
                        if(techLimit>0)then
                            percent=totalTech/techLimit
                        end
                        if(clickable)then
                            downStr=getlocal("powerGuide_techCanUpgrade")
                        else
                            downStr=getlocal("powerGuide_techCantUpgrade")
                        end
                    elseif(idx==4)then--军团科技等级
                        percent=0
                        local selfAlliance=allianceVoApi:getSelfAlliance()
                        if(selfAlliance==nil)then
                            clickable=false
                            downStr=getlocal("noAlliance")
                        else
                            local totalLv=0
                            local lvLimit=0
                            for i=11,14 do
                                local skillCfg=allianceSkillCfg[i]
                                local skillID=tonumber(skillCfg.sid)
                                totalLv=totalLv+allianceSkillVoApi:getSkillLevel(skillID)
                                lvLimit=lvLimit+selfAlliance.level
                            end
                            if(lvLimit>0)then
                                percent=totalLv/lvLimit
                            end
                            local donateCount=0
                            for i=1,5 do
                                local count=allianceVoApi:getDonateCount(i)
                                donateCount=donateCount+count
                            end
                            local donateMaxCount=allianceVoApi:getDonateMaxNum()*5
                            downStr=getlocal("powerGuide_allianceDonate",{donateCount,donateMaxCount})
                            if(donateCount>=donateMaxCount)then
                                clickable=false
                            elseif(totalLv<lvLimit)then
                                clickable=true
                            end
                        end
                        if(base.isAllianceOpen~=true)then
                            downStr=""
                            clickable=false
                        end
                    elseif(idx==5)then--兵种强度
                        percent=0
                        local tankID,bestPower=tankVoApi:getBestTankCanProduce()
                        if(tankID)then
                            picStr = tankCfg[tankID].icon
                            local worstPower=self:getWorstPower()
                            if(bestPower>0)then
                                percent=worstPower/bestPower
                            end
                            downStr=getlocal("powerGuide_produceTankPowerDesc",{getlocal(tankCfg[tankID].name)})
                            if(worstPower<bestPower)then
                                clickable=true
                            else
                                clickable=false
                            end
                        else
                            picStr = "Icon_tan_ke_gong_chang.png"
                            downStr=getlocal("powerGuide_produceTankNoTank")
                            clickable=false
                        end
                    elseif(idx==6)then--出战部队满编
                        percent=0
                        local totalNum=self:getTankNumInBestTanks()
                        local limitNum=(playerVoApi:getTroopsLvNum()+playerVoApi:getExtraTroopsNum())*6
                        if(limitNum>0)then
                            percent=totalNum/limitNum
                        end
                        if(percent<1)then
                            downStr=getlocal("powerGuide_tankNumDesc",{limitNum-totalNum})
                        else
                            downStr=getlocal("powerGuide_tankNumDesc2")
                        end
                        local buildVo=buildingVoApi:getBuildiingVoByBId(11)
                        if(buildVo and buildVo.level and buildVo.level>0)then
                            if(percent<1)then
                                clickable=true
                            else
                                clickable=false
                            end
                        else
                            clickable=false
                        end
                    elseif(idx==7)then--个人繁荣度
                        percent=0
                        if base.isGlory==1 then
                            percent = gloryVoApi:getBoomPercent()
                        end
                        
                        if percent<1 then
                            downStr=getlocal("powerGuide_down1_7_0")
                            clickable = true
                        else
                            downStr=getlocal("powerGuide_down1_7_1")
                        end
                    end

                    if percent > 1 then
                        percent = 1
                    end
                    totalValue = totalValue + percent * totalPercent[idx]
                    classData[2][idx]={percent,clickable,downStr,picStr,upStr}
                end
            end
        elseif classIndex == self.CLASS_armor then--装甲矩阵
            classData = {getlocal("armorMatrix"),{},0}
            if addContent == true then
                totalPercent = {0.5,0.5}
                local roleMaxLv = playerVoApi:getMaxLvByKey("roleMaxLevel")
                for idx=1,2 do
                    local per,num = self:getArmorMatrixPercent(idx)
                    percent = per
                    if percent < 1 then
                        clickable = true
                        downStr = getlocal("powerGuide_down2_" .. idx .. "_0",{num})
                    else
                        downStr = getlocal("powerGuide_down2_" .. idx .. "_1")
                    end


                    totalValue = totalValue + percent * totalPercent[idx]
                    if percent > 1 then
                        percent = 1
                    end
                    classData[2][idx]={percent,clickable,downStr,picStr,upStr}
                end
            end
        elseif classIndex == self.CLASS_accessory then--配件
            classData = {getlocal("accessory"),{},0}
            if addContent == true then
                totalPercent = {0.21,0.22,0.24,0.18,0.15}
                local maxNum = 3
                if accessoryVoApi:succinctIsOpen() == true then
                    maxNum = 4
                end
                for idx=1,5 do
                    if(idx==1)then--已装配件品质
                        local ownedNum,num=self:getEquipedAccessoryScore()
                        local limitNum=accessoryVoApi:getUnlockPartByLv(playerVoApi:getPlayerLevel())*accessoryCfg.maxQuality*4
                        if(limitNum>0)then
                            percent=ownedNum/limitNum
                        end
                        
                        if(ownedNum<limitNum)then
                            clickable=true
                        else
                            clickable=false
                        end
                        if(base.ifAccessoryOpen~=1)then
                            clickable=false
                        end
                        classData[2][idx]={percent,clickable,{num}}
                    elseif(idx==2)then--配件强化等级
                        local totalLv=self:getAccessoryTotalLv()
                        local lvLimit=accessoryVoApi:getUnlockPartByLv(math.min(playerVoApi:getPlayerLevel(),playerVoApi:getMaxLvByKey("roleMaxLevel")))*playerVoApi:getPlayerLevel()*4
                        if(lvLimit>0)then
                            percent=totalLv/lvLimit
                        end
                        classData[2][idx]={percent}
                    elseif(idx==3)then--配件改造等级
                        local totalRank=self:getAccessoryTotalRank()
                        local maxQuality=accessoryCfg.maxQuality
                        local smeltMaxRank=accessoryVoApi:getSmeltMaxRank(maxQuality)
                        local rankLimit=accessoryVoApi:getUnlockPartByLv(playerVoApi:getPlayerLevel())*smeltMaxRank*4
                        if(rankLimit>0)then
                            percent=totalRank/rankLimit
                        end
                        classData[2][idx]={percent}
                    elseif(idx==4)then--配件精炼强度
                        local per,num = self:getAccessoryTotalSuccinct()
                        percent = per
                        classData[2][idx]={percent,nil,{num}}
                    elseif(idx==5)then--配件科技等级
                        local per,num = self:getAccessoryTotalTech()
                        percent = per
                        classData[2][idx]={percent,nil,{num}}
                    end
                    totalValue = totalValue + percent * totalPercent[idx]
                end
            end
        elseif classIndex == self.CLASS_hero then--将领
            classData = {getlocal("heroTitle"),{},0}
            if addContent == true then
                local classHeroListNum = 4
                totalPercent = {0.2,0.25,0.15}
                if heroAdjutantVoApi:isOpen() then
                    classHeroListNum = 5
                    totalPercent = {0.18,0.23,0.13}
                end
                for idx=1,classHeroListNum do--将领品质/将领等级/将领技能等级/将领装备强度/将领副官
                    local per,num,addTotalPer = self:getHeroQuaLityPercent(idx)
                    percent = per
                    if addTotalPer then
                        totalValue = totalValue + addTotalPer
                    else
                        totalValue = totalValue + percent * totalPercent[idx]
                    end
                    classData[2][idx]={percent,nil,{num}}
                end
            end
        elseif classIndex == self.CLASS_alienweapon then--超级武器
            classData = {getlocal("super_weapon_title_1"),{},0}
            if addContent == true then
                totalPercent = {0.32,0.35,0.33} 
                for idx=1,3 do
                    local per,num = self:getAlienWeaponPercent(idx)
                    percent = per
                    totalValue = totalValue + percent * totalPercent[idx]
                    classData[2][idx]={percent,nil,{num}}
                end
            end
        elseif classIndex == self.CLASS_alientech then--异星科技
            classData = {getlocal("alien_tech_title"),{},0}
            if addContent == true then
                totalPercent = {0.5,0.5}
                local treeCfg=alienTechVoApi:getTreeCfg(true)
                local maxLen = SizeOfTable(treeCfg)
                local getPoint = 0
                local totalPoint = 0
                local cfg
                for idx=1,2 do
                    getPoint = 0
                    totalPoint = 0
                    percent = 0
                    if(idx==1)then--常规军舰
                        for i=1,4 do
                            cfg = treeCfg[i]
                            if cfg then
                                getPoint = getPoint + alienTechVoApi:getPointByType(i)                            
                                totalPoint = totalPoint + cfg.totalPoint
                            end
                        end                    
                    elseif(idx==2)then--特战军舰
                        if maxLen > 4 then
                            for i=5,maxLen do
                                cfg = treeCfg[i]
                                if cfg then
                                    getPoint = getPoint + alienTechVoApi:getPointByType(i)
                                    totalPoint = totalPoint + cfg.totalPoint
                                end
                            end
                        end
                    end
                    if getPoint > 0 and totalPoint > 0 then
                        percent = getPoint/totalPoint
                    end
                    if percent > 1 then
                        percent = 1
                    end
                    totalValue = totalValue + percent * totalPercent[idx]

                    classData[2][idx]={percent,nil,{getPoint}}
                end
            end
        elseif classIndex == self.CLASS_superequip then--军徽
            classData = {getlocal("emblem_title"),{},0}
            if addContent == true then
                totalPercent = {0.6,0.4}
                for idx=1,2 do
                    local per,num = self:getBattleEquipPercent(idx)--已进行per>1 per = 1 判断
                    percent = per
                    totalValue = totalValue + percent * totalPercent[idx]

                    classData[2][idx]={percent,clickable,{num}}
                end
            end
        elseif classIndex == powerGuideVoApi.CLASS_plane then
            classData = {getlocal("sample_build_name_106"),{},0}
            if addContent == true then
                local perCount = 2
                if (not planeRefitVoApi:isFirstEnter()) and planeRefitVoApi and planeRefitVoApi:isCanEnter() == true then
                    totalPercent = {1/3,1/3,1/3}
                    perCount = 3
                else
                    totalPercent = {0.5,0.5}
                end
                for idx=1,perCount do
                    local per,num = self:getPlanePercent(idx)--已进行per>1 per = 1 判断
                    percent = per
                    totalValue = totalValue + percent * totalPercent[idx]

                    classData[2][idx]={percent,clickable,{num}}
                end
            end
        elseif classIndex == powerGuideVoApi.CLASS_strategy then --战略中心
            classData = {getlocal("strategyCenter_text"), {}, 0}
            if addContent == true then
                totalPercent = {0.5, 0.5}
                for idx = 1, 2 do
                    local per, num = self:getStrategyPercent(idx)
                    percent = per
                    totalValue = totalValue + percent * totalPercent[idx]
                    classData[2][idx] = {percent, clickable, {num}}
                end
            end
        elseif classIndex == powerGuideVoApi.CLASS_airship then --战争飞艇
            classData = {getlocal("airShip_text"), {}, 0}
            if addContent == true then
                totalPercent = {1}
                for idx = 1, 1 do
                    local per, num = self:getAirShipPercent(idx)
                    percent = per
                    totalValue = totalValue + percent * totalPercent[idx]
                    classData[2][idx] = {percent, clickable, {num}}
                end
            end
        end
        if addContent == true then
            if totalValue > 1 then
                totalValue = 1
            end
            if totalValue > 0 and classData[3] then
                classData[3] = totalValue
            end
            self.classDataTb[classIndex] = classData
        else--没有内容时就不记录，下次显示详细信息的时候再计算
            return classData
        end
    end
    return self.classDataTb[classIndex]
end

function powerGuideVoApi:showDetailPanel(classIndex,gotoFun,layerNum,closeFun)
    require "luascript/script/game/scene/gamedialog/playerDialog/powerGuideSmallDialog"
    local classData = powerGuideVoApi:getClassContentData(classIndex)
    local contentDialog = powerGuideSmallDialog:new()
    contentDialog:init(layerNum,classIndex,classData[2],classData[1],gotoFun,closeFun)
    -- body
end
