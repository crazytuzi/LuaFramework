require "luascript/script/config/gameconfig/playerCfg"
require "luascript/script/game/gamemodel/player/playerVo"
--maxLevelTb:最大等级TB

playerVoApi={
maxLevelTb={},
maxLevelKeyTb={"buildingMaxLevel","newTankBuilding","roleMaxLevel","unlockCheckpoint","allianceMaxLevel","techMaxLevel","unlockAllianceFuben","unlockTaskLevel","unlockAccParts","unlockEliteChallenge","unlockThroughLevel","maxVip","fukuangMax","unlockBuildForceIdStr","unlockTankShopIdStr","unlockAlienTech","unlockSwParts","unlockSwLevel","unEquipLevel","unlockAccTechUpgradeLv","unlockAccTechSkillLv","emblemUpgrade4Lv","emblemUpgrade5Lv","pskillUpgrade4Lv","pskillUpgrade5Lv","unlockCitySkill"},
rankList={},                --军衔排行榜
rankAllLoaded=false,        --一个标识，军衔排行榜是否已经全部拉取完了
rankIsOpen=1,

platformReward={},
unLockHead={},
unLockTitle={},
worldLv=0, --新增世界等级
curWorldExp=0,--当前世界经验值
playerLastLevel=0,
realNameRegist=false,   --是否实名认证过
powerGuideTb={},
unlockData={},
unLockChatEmoji={}, --已解锁的聊天表情ID

}

function playerVoApi:add(data)
    if self.playerLastLevel==0 then
        local lastLevelKey=self:getPlayerLastKey(data.uid)
        local lastLevel=CCUserDefault:sharedUserDefault():getIntegerForKey(lastLevelKey)
        if lastLevel==0 then
            self:setPlayerLastLevel(data.uid,data.level)
        else
            self.playerLastLevel=lastLevel
        end
    end

    local beforeLevel=self:getPlayerLevel()

    playerVo:initWithData(data)

    if beforeLevel and beforeLevel>0 then
        local nowLevel=self:getPlayerLevel()
        if nowLevel>beforeLevel and nowLevel%10==0 then
            -- 1:玩家名称  2:活动名称 3:等级 4:奖励 5:技能名称
            local params = {key="playerUpgradeMessage",param={{self:getPlayerName(),1},{nowLevel,3}}}
            chatVoApi:sendUpdateMessage(41,params)
        end
    end
   
end

function playerVoApi:showPlayerDialog(tabType,layerNum,isGuide,taskVo)
    require "luascript/script/game/scene/gamedialog/playerDialog/playerDialog"
    require "luascript/script/game/scene/gamedialog/playerDialog/playerDialogTab1"
    require "luascript/script/game/scene/gamedialog/playerDialog/playerDialogTab2"
    require "luascript/script/game/scene/gamedialog/playerDialog/playerDialogTab3"
    CCTexture2D:setDefaultAlphaPixelFormat(kCCTexture2DPixelFormat_RGBA8888)
    CCTexture2D:setPvrDefaultAlphaPixelFormat(kCCTexture2DPixelFormat_RGBA8888) 
    spriteController:addPlist("public/nbSkill.plist")
    spriteController:addTexture("public/nbSkill.png")
    CCTexture2D:setDefaultAlphaPixelFormat(kCCTexture2DPixelFormat_RGBA4444)
    CCTexture2D:setPvrDefaultAlphaPixelFormat(kCCTexture2DPixelFormat_RGBA4444)
    local td=playerDialog:new(tabType,layerNum,isGuide,taskVo)
    local tbArr={getlocal("playerInfo"),getlocal("skillTab"),getlocal("buildingTab")}
    local dialog=td:init("panelBg.png",true,CCSizeMake(600,900),CCRect(0, 0, 400, 350),CCRect(168, 86, 10, 10),tbArr,nil,nil,getlocal("playerRole"),true,layerNum)
    sceneGame:addChild(dialog,layerNum)
    return td
end

function playerVoApi:getLuck()
    
    return playerVo.luck

end
function playerVoApi:getMaxLuck()
    if playerVoApi:getTroops()<playerVoApi:getMaxLvByKey("roleMaxLevel") then
       return playerCfg.commander_lucky_val[playerVoApi:getTroops()+1]
    else
       return playerCfg.commander_lucky_val[playerVoApi:getMaxLvByKey("roleMaxLevel")]
    end

end



function playerVoApi:getLogindate()--上一次登陆时间戳
    return tonumber(playerVo.logindate)
end

function playerVoApi:getIsBuyGrowingplan()--是否购买过成长计划
    return tonumber(playerVo.grow)
end
function playerVoApi:getGrowingPlanRewarded()--获取成长计划已领取的奖励
    return tonumber(playerVo.growrd)
end

function playerVoApi:getPlayerAid()  --获取公会id
    return tonumber(playerVo.aid)
end
function playerVoApi:getPlayerIsATag()  --获取公会id变化信息
    return tonumber(playerVo.isATag)
end
function playerVoApi:setPlayerAid(aid)  --获取公会id
    playerVo.aid=aid
end
function playerVoApi:setPlayerIsATag(isATag)  --获取公会id变化信息
    playerVo.isATag=isATag
end


function playerVoApi:getPlayerPower()  --获取玩家的战斗力
    return tonumber(playerVo.power)
end

function playerVoApi:setPlayerPower(power)
    if(playerVo)then
        playerVo.power=tonumber(power)
    end
end

function playerVoApi:getPlayerEnergycd()  --获取玩家能量cd时间
    return tonumber(playerVo.energycd)
end

function playerVoApi:getPlayerLevel()  --获取玩家等级
    --[[
    local sum=0
    --print("playerCfg.level_exps=",playerCfg.level_exps) 
    local lvCfg=Split(playerCfg.level_exps,",")
    local lv=0
    for i=1,60 do
        if tonumber(lvCfg[i])>self:getPlayerExp() then
             lv=i-1
             break;
        elseif tonumber(lvCfg[i])<=self:getPlayerExp() and i==playerVoApi:getMaxLvByKey("roleMaxLevel") then
            lv=playerVoApi:getMaxLvByKey("roleMaxLevel")
            break;
        end
    end
    return lv
    ]]
    if playerVo.level==nil then
        return 0
    end

    return tonumber(playerVo.level)
end

function playerVoApi:ifProtected()
    return  playerVo.protect>base.serverTime
end

function playerVoApi:getProtectEndTime()
     return playerVo.protect
end
function playerVoApi:getUid()

     return playerVo.uid
end

function playerVoApi:getPlayerExp()  --获取玩家经验
    return playerVo.exp
end

function playerVoApi:setPlayerName(name)  --设置玩家名称
    playerVo.name=name
end
function playerVoApi:getPlayerName()  --获取玩家名称
    return playerVo.name
end
function playerVoApi:getLvExp() --获取玩家当前经验和升级经验
    local maxLv=playerVoApi:getMaxLvByKey("roleMaxLevel")
    local lvCfg=Split(playerCfg.level_exps,",")
    local a,b=lvCfg[maxLv]-lvCfg[maxLv-1],lvCfg[maxLv]-lvCfg[maxLv-1]
    if playerVoApi:getPlayerLevel()<maxLv then
        a=self:getPlayerExp()-lvCfg[playerVoApi:getPlayerLevel()]
        b=lvCfg[playerVoApi:getPlayerLevel()+1]-lvCfg[playerVoApi:getPlayerLevel()]
    end
    return FormatNumber(a),FormatNumber(b)
end
function playerVoApi:getLvPercent() --获取升级等级百分比

    
    local lvCfg=Split(playerCfg.level_exps,",")
    
    
    local percent=100;

    if playerVoApi:getPlayerLevel()<playerVoApi:getMaxLvByKey("roleMaxLevel") then

        local a=self:getPlayerExp()-lvCfg[playerVoApi:getPlayerLevel()]
        local b=lvCfg[playerVoApi:getPlayerLevel()+1]-lvCfg[playerVoApi:getPlayerLevel()]
        percent = math.floor(a*100/b)        
    end

    return percent
    
end

function playerVoApi:getEnergy() --获取能量
    local maxEnergy = checkPointVoApi:getMaxEnergy()
    if playerVo.energy >= maxEnergy then --如果玩家拥有能量点大于最大能量点，则直接取拥有的能量点（玩家可以吃药或者买能量，且没有能量上限）
        return playerVo.energy
    else --如果能量点不满则需要根据能量恢复时间来动态算当前能量点
        local recoverTime = self:getPerEnergyRecoverTime() --恢复一点需要的时间
        local energy = playerVo.energy + math.floor((base.serverTime - playerVo.energy_at) / recoverTime)
        return math.min(energy, maxEnergy)
    end
end

function playerVoApi:setEnergy(param)
    playerVo.energy=param
end

function playerVoApi:getEnergyPercent() --获取能量百分比
    local maxEnergy = playerCfg.maxEnergy_normal
    if base.he==1 then
        maxEnergy = playerCfg.maxEnergy_equip
    end
    return playerVo.energy/maxEnergy
end

function playerVoApi:getVipLevel() --获取Vip等级
    return playerVo.vip
end

function playerVoApi:getGold() --获取金币
    return playerVo.gold
end

function playerVoApi:setGold(gold) --设置金币
    playerVo.gold=gold
end

function playerVoApi:getGems()  --获取宝石数量
    return playerVo.gems
end

function playerVoApi:setGems(gemnum)  --设置宝石数量
    playerVo.gems=gemnum
end

function playerVoApi:getBuygems()  --获取购买宝石数量
    return playerVo.buygems
end

--获取VIP的成长值，由两部分组成，一部分是充值金币，还有一部分是VIP道具获得的VIP成长值
function playerVoApi:getVipExp()
    local buyGems=self:getBuygems()
    local point=playerVo.vipPoint
    local exp=buyGems+point
    return exp
end

function playerVoApi:getHonors() --声望值
    return playerVo.honors
end

function playerVoApi:getRank() --军衔
    return playerVo.rank
end

function playerVoApi:getMapX()

    return playerVo.mapx
end

function playerVoApi:getMapY()

    return playerVo.mapy
end

--获取军衔名称
--param rank: 要获取的军衔等级, 可以不传, 不传的时候默认为玩家自己的军衔
--return 军衔等级对应的名称
function playerVoApi:getRankName(rank)
    if(rank==nil)then
        rank=self:getRank()
    end
    return getlocal("military_rank_"..rank)
end

--获取军衔对应的图片名称
--param rank: 要获取图片的军衔等级
--return 军衔对应的图片名称, 可以不传, 不传的时候默认为玩家自己的军衔
function playerVoApi:getRankIconName(rank)
    if(rank==nil)then
        rank=self:getRank()
    end
    local cfg=rankCfg.rank[rank]
    if(cfg and cfg.icon)then
        return cfg.icon
    else
        return nil
    end
end

--获取到下一军衔所需要的等级和战功
--return 升级到下一军衔所需等级
--return 升级到下一军衔所需战功
function playerVoApi:getNextRankLvAndPoint()
    local cfg=rankCfg.rank[self:getRank()]
    local lv
    local point
    if(cfg and cfg.lv)then
        lv=cfg.lv
    else
        lv=0
    end
    if(cfg and cfg.point)then
        point=cfg.point
    else
        point=0
    end
    return lv,point
end

--获取军衔每日可领取声望
--param rank: 哪一级军衔
function playerVoApi:getRankDailyHonor(rank)
    local cfg=rankCfg.rank[rank]
    if(cfg and cfg.honorAdd)then
        return cfg.honorAdd
    else
        return 0
    end
end

function playerVoApi:getHonorMaxLv()
    local honorMaxLv = playerVoApi:getMaxLvByKey("roleMaxLevel")
    local addValue = strategyCenterVoApi:getAttributeValue(14)
    if addValue and addValue > 0 then
        honorMaxLv = honorMaxLv + addValue
    end
    return honorMaxLv
end

function playerVoApi:getHonorInfo(honors) --声望详细信息
    local curHonors=self:getHonors()
    if honors and tonumber(honors) then
        curHonors=tonumber(honors)
    end
    local honorCfg=Split(playerCfg.honors,",")
    local lv=0
    local cur=0
    local next=0
    local honorMaxLv = self:getHonorMaxLv()
    for i=1,honorMaxLv do
        if tonumber(honorCfg[i])>curHonors then
             lv=i-1
             cur=curHonors-honorCfg[i-1]
             next=honorCfg[i]-honorCfg[i-1]
             break
        elseif tonumber(honorCfg[i])==curHonors and i~=honorMaxLv then
             lv=i
             cur=curHonors-honorCfg[i]
             next=honorCfg[i+1]-honorCfg[i]
             break

        elseif tonumber(honorCfg[i])<=curHonors and i==honorMaxLv then
             lv=i
             cur=honorCfg[i]-honorCfg[i-1]
             next=honorCfg[i]-honorCfg[i-1]
             break
            
        end
    end
    return lv,cur,next
end

function playerVoApi:convertGems( idx,num ) --人物等级满级 或是经验满级后 按比例直接兑换成水晶
    --idx 1 等级经验  2声望经验    num 可兑换的经验值（等级 或是声望的）  兑换比例 经验：水晶  10：1      声望：水晶 1：50
    if idx ==1 then
        local gems =math.ceil(num/10)
        return gems
    elseif idx ==2 then
        local gems=num*50
        return gems   
    end
    return 0   
end

function playerVoApi:getTroopsLvNum() --人物等级带兵量
    local honorCfg=Split(playerCfg.troops,",")
    
    return honorCfg[self:getPlayerLevel()]
end

function playerVoApi:getCredit() --荣誉
    return playerVo.credit
end
function playerVoApi:getTroops() --获取统御等级
    return playerVo.troops
end
function playerVoApi:getTroopsSuccess() --获取统御升级成功几率
    local honorCfg=Split(playerCfg.commander_success,",")
    local per=0
    if honorCfg[playerVoApi:getTroops()+1] and honorCfg[playerVoApi:getTroops()+1]~="" then
       per=tonumber(honorCfg[playerVoApi:getTroops()+1])/100
    end
    return per
end

--获取统率升级最终的成功几率
function playerVoApi:getTroopsTotalSuccess()
    local rate = 0
    --vip对统率升级的加成               
    local addPercent=1 + playerCfg.commandedSpeed[playerVoApi:getVipLevel()+1]
    --提高统率概率的活动 "data":{"attackIsland":{"propRate":0.3,"exp":0.2},"troopsup":{"upRate":0.1},"attackChallenge":{"exp":0.2}}
    local luckupActive=activityVoApi:getActivityVo("luckUp")
    if luckupActive and playerVoApi:getTroops()<playerVoApi:getMaxLvByKey("roleMaxLevel") then
        if luckupActive.otherData and luckupActive.st and luckupActive.et and base.serverTime>luckupActive.st and base.serverTime<luckupActive.et  then
            if luckupActive.otherData.troopsup and luckupActive.otherData.troopsup.upRate then
                local upRate=tonumber(luckupActive.otherData.troopsup.upRate)
                addPercent=addPercent*(1 + upRate)
            end
        end
    end
    if(addPercent>1)then
        rate=playerVoApi:getTroopsSuccess()*addPercent
    else
        rate=playerVoApi:getTroopsSuccess()
    end
    --判断是不是在元旦活动期间，如果在的话提升成功率
    local newyearVoApi = activityVoApi:getVoApiByType("newyeargift")
    if newyearVoApi then
        local openAc,troopNum,addRate = newyearVoApi:getTroopsConfig()
        rate = rate + playerVoApi:getTroopsSuccess()*addRate
    end
    return rate
end

function playerVoApi:getTroopsNum() --统御等级带兵量
    local honorCfg=Split(playerCfg.commander_troops,",")
    local num=0
    if self:getTroops()>0 then
        num=honorCfg[self:getTroops()]
    end
    return num
end
function playerVoApi:getNextTroopsNum() --下一级统御等级带兵量
    local honorCfg=Split(playerCfg.commander_troops,",")
    local num=0
    if self:getTroops()>0 then
        num=honorCfg[self:getTroops()+1]
    end
    return num
end

--获取指定统率等级的带兵量
function playerVoApi:getTroopsNumByCommanderLv(lv)
    local honorCfg=Split(playerCfg.commander_troops,",")
    local maxLv = SizeOfTable(honorCfg)
    local num=0
    if lv > maxLv then
        lv = maxLv
    end
    if lv>0 then
        num=honorCfg[lv]
    end
    return num
end

--军衔所提供的带兵量加成
--param rank: 要获取带兵量的军衔, 可以为空, 为空时取玩家自己的军衔等级
function playerVoApi:getRankTroops(rank)
    if(rank==nil)then
        rank=self:getRank()
    end
    local cfg=rankCfg.rank[rank]
    if(cfg and cfg.troops)then
        return cfg.troops
    else
        return 0
    end
end

--军衔所提供的属性加成
--param rank: 要获取加成的军衔, 可以为空, 为空时取玩家自己的军衔等级
--return: 一个table, 是各个属性的加成值, 第一个元素表示攻击加成百分比, 第二个元素表示血量加成的百分比
function playerVoApi:getRankAttAdd(rank)
    if(rank==nil)then
        rank=self:getRank()
    end
    local cfg=rankCfg.rank[rank]
    if(cfg and cfg.attAdd)then
        return cfg.attAdd
    else
        return {0,0}
    end
end

--获取除了基础带兵量之外的其他额外带兵量加成
function playerVoApi:getExtraTroopsNum(bType,isAddEmblem)
    local leaderTroops=tonumber(self:getTroopsNum())
    local rankTroops=tonumber(self:getRankTroops())
    local gloryWithNums =0
    if base.isGlory ==1 then
        gloryWithNums = gloryVoApi:getPlayerCurGloryWithTroop()
    end
    --军徽加带兵量
    local emblemTroopsAdd = 0
    if base.emblemSwitch==1 and isAddEmblem~=false then
        local emblemID = emblemVoApi:getTmpEquip(bType)
        if emblemID~=nil then
           emblemTroopsAdd=emblemVoApi:getTroopsAddById(emblemID)
        end
    end

    local warStatueTroopsAdd=0 --战争塑像的加成
    local battleBuff=warStatueVoApi:getTotalWarStatueAddedBuff("add")
    warStatueTroopsAdd=battleBuff.add or 0

    local planeBuffAdd=0 --空战指挥所系统战机革新技能加成
    local addBuffTb=planeVoApi:getPlaneNewSkillAddBuff("s15")
    if addBuffTb and addBuffTb.add then
        planeBuffAdd=addBuffTb.add
    end
    local championshipTroopsAdd = 0
    if bType==38 or bType==39 then --军团锦标赛可以购买带兵量，所以得特殊
        if championshipWarVoApi:isOpen()==1 then
            championshipTroopsAdd=championshipWarVoApi:getTroopsAdd()
        end
    end
    local skinAdd = 0
    if buildDecorateVoApi and base.isSkin == 1 and buildDecorateVoApi.addTroopNum then
        skinAdd = buildDecorateVoApi:addTroopNum()
    end
    local repairFactoryAdd = 0
    local buildVo = buildingVoApi:getBuildiingVoByBId(15)
    if buildVo and buildVo.level>0 then --修理厂等级加成
        local rate, pronum, troopAdd = buildingVoApi:getRepairFactoryBuff(buildVo.level)
        repairFactoryAdd = troopAdd
    end
    
    local airshipAdd = 0
    if airShipVoApi:isCanEnter() == true then
        local airshipId = airShipVoApi:getTempLineupId(bType)
        airshipAdd = airShipVoApi:getTacticsPropertyByType(airshipId, "add") --飞艇系统加成
    end
    
    local extra=leaderTroops+rankTroops+gloryWithNums + emblemTroopsAdd + warStatueTroopsAdd + planeBuffAdd + championshipTroopsAdd + skinAdd + repairFactoryAdd + airshipAdd
    return extra
end

function playerVoApi:getTotalTroops(bType,isAddEmblem) --总带兵量
    local basicNum=tonumber(playerVoApi:getTroopsLvNum())
    local extraNum=self:getExtraTroopsNum(bType,isAddEmblem)
    local total=basicNum+extraNum
    return total
end


--固定的额外增加的带兵量
function playerVoApi:getAddTroops()
    local addTroopsNum=0
    local addTroopsNum=self:getTroopsNum()+self:getRankTroops()
    if base.isGlory==1 then
        addTroopsNum=addTroopsNum+gloryVoApi:getPlayerCurGloryWithTroop()
    end
    local battleBuff=warStatueVoApi:getTotalWarStatueAddedBuff("add")
    addTroopsNum=addTroopsNum+(battleBuff.add or 0)

    local addBuffTb=planeVoApi:getPlaneNewSkillAddBuff("s15")
    if addBuffTb and addBuffTb.add then --空战指挥所系统战机革新技能加成
        addTroopsNum=addTroopsNum+addBuffTb.add
    end
    if buildDecorateVoApi and buildDecorateVoApi.addTroopNum and base.isSkin == 1 then
        addTroopsNum = addTroopsNum + buildDecorateVoApi:addTroopNum()
    end
    local buildVo = buildingVoApi:getBuildiingVoByBId(15)
    if buildVo and buildVo.level>0 then --修理厂等级加成
        local rate, pronum, troopAdd = buildingVoApi:getRepairFactoryBuff(buildVo.level)
        addTroopsNum = addTroopsNum + troopAdd
    end

    return addTroopsNum
end

function playerVoApi:useResNum(resKey, costNum)
    if resKey == "r1" then
        return self:useResource(costNum)
    elseif resKey == "r2" then
        return self:useResource(nil, costNum)
    elseif resKey == "r3" then
        return self:useResource(nil, nil, costNum)
    elseif resKey == "r4" then
        return self:useResource(nil, nil, nil, costNum)
    elseif resKey == "r5" or resKey == "gold" then
        return self:useResource(nil, nil, nil, nil, costNum)
    end
end

function playerVoApi:getResNum(resKey)
    if resKey == "r1" then
        return self:getR1()
    elseif resKey == "r2" then
        return self:getR2()
    elseif resKey == "r3" then
        return self:getR3()
    elseif resKey == "r4" then
        return self:getR4()
    elseif resKey == "r5" or resKey == "gold" then
        return self:getGold()
    end
    return 0
end

function playerVoApi:getR1()
    return playerVo.r1
end
function playerVoApi:getR2()
    return playerVo.r2
end
function playerVoApi:getR3()
    return playerVo.r3
end
function playerVoApi:getR4()
    return playerVo.r4
end
--获取永久建筑队列+临时建筑队列的总数
function playerVoApi:getBuildingSlotNum()
    if(playerVo.tempSlots>=base.serverTime)then
        return playerVo.buildingSlotNum + 1
    else
        return playerVo.buildingSlotNum
    end
end

--获取永久建筑队列的数目
function playerVoApi:getOriginBuildingSlotNum()
    return playerVo.buildingSlotNum
end

function playerVoApi:getWorkShopSlotNum()
    return playerVo.workShopSlotNum
end

function playerVoApi:useResource(r1,r2,r3,r4,gold,gems)
    r1=r1 or 0
    r2=r2 or 0
    r3=r3 or 0
    r4=r4 or 0
    gold=gold or 0
    gems=gems or 0
    playerVo.r1=playerVo.r1-r1
    playerVo.r2=playerVo.r2-r2
    playerVo.r3=playerVo.r3-r3
    playerVo.r4=playerVo.r4-r4
    playerVo.gems=playerVo.gems-gems
    playerVo.gold=playerVo.gold-gold
end

function playerVoApi:produceResource(time) --生产资源
    for i=1,5 do
        local totalSpeed,totalCapacity=buildingVoApi:getTotalProduceSpeedAndCapacityByBType(i)
        local produceCount=math.floor((totalSpeed/60)*time)
        if i==5 then
            if (playerVo.gold+produceCount)<=totalCapacity then
                 playerVo.gold=playerVo.gold+produceCount
            end
        else
            if (playerVo["r"..tostring(i)]+produceCount)<=totalCapacity then
                 playerVo["r"..tostring(i)]=playerVo["r"..tostring(i)]+produceCount
            end
        end
    end
end

function playerVoApi:setBasePos(x,y)
    playerVo.mapx=x
    playerVo.mapy=y
end

function playerVoApi:getTutorial()
    return playerVo.tutorial
end

function playerVoApi:setTutorial(tutorial)
    playerVo.tutorial=tutorial
end

--设置功能阶段性引导的步骤
function playerVoApi:setFuncGuideStep(stepId)
    local func=playerVo.func or {}
    for k,v in pairs(func) do
        if tonumber(v)==tonumber(stepId) then
            return
        end     
    end
    table.insert(func,stepId)
end

--获取功能阶段性引导的步骤
function playerVoApi:getFuncGuideStep()
    return playerVo.func or {}
end

function playerVoApi:getPic()
    return playerVo.pic
end

function playerVoApi:isGuest()
    return playerVo.isGuest
end
function playerVoApi:setIsGuest(flag)
    playerVo.isGuest=flag
end 

function playerVoApi:getMapOldPoint()

    return playerVo.oldmapx,playerVo.oldmapy
end

function playerVoApi:getRegdate()
    return (playerVo.regdate==nil and 0 or playerVo.regdate)
end

function playerVoApi:setValue(key,value)
    if key=="honors" and playerVo[key] then
        local beforeLv = self:getHonorInfo()
        local nowLv = self:getHonorInfo(value)
        if nowLv>beforeLv and beforeLv>0 and nowLv%10==0 then
            -- 1:玩家名称  2:活动名称 3:等级 4:奖励 5:技能名称
            local params = {key="honorUpgradeMessage",param={{self:getPlayerName(),1},{nowLv,3}}}
            chatVoApi:sendUpdateMessage(41,params)
        end
    end
    if playerVo[key] then
        playerVo[key]=value
    end
end

--获取用户的平台信息(FB picture, name, and so on)
function playerVoApi:getPlatformInfo(params,callback)
    self.getPlatformInfoCallback=callback
    if(playerVo.platformInfo~=nil)then
        if(callback~=nil)then
            callback(playerVo.platformInfo)
        end
        do return end
    end
    local tmpTb={}
    tmpTb["action"]="getmyplatforminfo"
    if(params~=nil)then
        tmpTb["parms"]=params
    else
        tmpTb["parms"]={}
    end
    local cjson = G_Json.encode(tmpTb)
    G_accessCPlusFunction(cjson)
end

function playerVoApi:onGetPlatformInfo(data)
    playerVo.platformInfo=data
    if(self.getPlatformInfoCallback~=nil)then
        self.getPlatformInfoCallback(playerVo.platformInfo)
    end
end

function playerVoApi:isPlayerLevelUpgrade()
    if playerVo.isLevelUpgrade~=nil and playerVo.isLevelUpgrade==true then
          playerVo.isLevelUpgrade=false
            return true
    end
    return false
end
function playerVoApi:clearAllianceData()--清空数据
    playerVo.aid=0
    playerVo.isATag=0

end
function playerVoApi:dispose()--清空数据
    self:clearAllianceData()
end

function playerVoApi:checkIfGetAllOnlinePackage()
    if playerVo.onlinePackage < 0 or playerVo.onlinePackage >= SizeOfTable(playerCfg.onlinePackage) then
        return true -- 所有奖励都已经领取
    end
    return false
end

-- 得到当前阶段在线礼包需要的在线时间
function playerVoApi:getOnLinePackageNeedTime()
    if self:checkIfGetAllOnlinePackage() == true then
        return -1
    end

    return playerCfg.onlinePackage[playerVo.onlinePackage + 1].t
end

-- 增加用户的在线时间(num 增加额度)
function playerVoApi:addOnlineTime(num)
    if self:checkIfGetAllOnlinePackage() == true then
        do
            return
        end
    end

    local zoneId=tostring(base.curZoneID)
    local gameUid=tostring(playerVoApi:getUid())
    local key = G_local_onlinePackage..zoneId..gameUid
    local t = playerVo.onlineTime

    if t ~= -1 then
        t = t + num
    else
        local settingsValue = CCUserDefault:sharedUserDefault():getStringForKey(key)

        if settingsValue ~= nil and settingsValue ~= "" then
           t = tonumber(settingsValue) + num
        else
            t = num
        end
    end

    if t >= playerCfg.onlinePackage[playerVo.onlinePackage + 1].t then
        -- 领奖时间到
        t = playerCfg.onlinePackage[playerVo.onlinePackage + 1].t
    end

    if t < 0 then
        t = 0
    end
    playerVo:updateOnlineTime(t)

    CCUserDefault:sharedUserDefault():setStringForKey(key,t)
    CCUserDefault:sharedUserDefault():flush()
end

-- 获取玩家该阶段的在线时长
function playerVoApi:getOnlineTime()
    local t = playerVo.onlineTime
    if t ~= nil and t > 0 then
        return tonumber(t)
    end
    return 0
end

-- 获得用户距离领奖所需在线时间的倒计时间
function playerVoApi:getLastNeedOnlineTime()
    if self:checkIfGetAllOnlinePackage() == true then
        return -1  -- 已领取完
    end
    local t = self:getOnLinePackageNeedTime() - self:getOnlineTime()
    if t > 0 then
        return t
    end
    return 0 -- 可领取
end

function playerVoApi:getOnlineAward()
    if self:checkIfGetAllOnlinePackage() == false then
        return playerCfg.onlinePackage[playerVo.onlinePackage + 1].award
    end
    return nil
end

function playerVoApi:afterGetOnlinePackageAward()
    playerVo:afterGetOnlinePackageAward()
    local zoneId=tostring(base.curZoneID)
    local gameUid=tostring(playerVoApi:getUid())
    local key = G_local_onlinePackage..zoneId..gameUid
    CCUserDefault:sharedUserDefault():setStringForKey(key,0)
    CCUserDefault:sharedUserDefault():flush()
end

function playerVoApi:addOnlineTimeAfterTick()
    if newGuidMgr:isNewGuiding() == true  or base.ifOnlinePackageOpen==0 or  playerVoApi:checkIfGetAllOnlinePackage() == true then -- 新手引导完成命名后才可以开始计时
        return
    end
    local lastAddTime = playerVo:getLastAddTime()
    if lastAddTime ~= nil and lastAddTime > 0 then
        local addTime = base.serverTime - lastAddTime
        if addTime > -10 and addTime<10 then
            self:addOnlineTime(addTime) 
        end
    end
    playerVo:setLastAddTime(base.serverTime)
end

--设置对应key的最大等级
function playerVoApi:setMaxLvByKey(lv,key)
    self.maxLevelTb[key]=lv
    
    if key=="unlockAccParts" then
        accessoryCfg.unLockPart=tonumber(lv)
    end

end

--取出对应key的最大等级
function playerVoApi:getMaxLvByKey(key)
    return self.maxLevelTb[key]
end

--显示战力引导面板
--param layerNum 面板要显示在哪个layerNum上
function playerVoApi:showPowerGuideDialog(layerNum,classIndex,callback,isBattleEnd,battleEndCall)

    local function showDialog()
        if base.powerGuide2017 == 1 then
            local function realShow()
                if callback then
                    callback()
                end
                require "luascript/script/game/scene/gamedialog/playerDialog/powerGuideNewDialog"
                local dialog=powerGuideNewDialog:new(classIndex)
                local layer=dialog:init("panelBg.png",true,CCSizeMake(768,800),CCRect(0, 0, 400, 350),CCRect(168, 86, 10, 10),{},nil,nil,getlocal("powerGuide_title"),true,layerNum)
                sceneGame:addChild(layer,layerNum)
            end
            realShow()

            
            

        else

            local function realShow()
                require "luascript/script/game/scene/gamedialog/playerDialog/powerGuideDialog"
                local dialog=powerGuideDialog:new()
                local layer=dialog:init("panelBg.png",true,CCSizeMake(768,800),CCRect(0, 0, 400, 350),CCRect(168, 86, 10, 10),{},nil,nil,getlocal("powerGuide_title"),true,layerNum)
                sceneGame:addChild(layer,layerNum)
            end
            if(accessoryVoApi.dataNeedRefresh)then
                accessoryVoApi:refreshData(realShow)
            else
                realShow()
            end
        end
    end

    
    local modelTb = {}--1accessory 2equip 3armor 4alien
    local playerLv=playerVoApi:getPlayerLevel()
    if base.ifAccessoryOpen==1 and playerLv >=8 and (accessoryVoApi.dataNeedRefresh)then
        table.insert(modelTb,1)
    end

    local equipOpenLv=base.heroEquipOpenLv or 30
    if base.he==1 and playerLv>=equipOpenLv then
        if heroEquipVoApi and heroEquipVoApi.ifNeedSendRequest == true then
           table.insert(modelTb,2)
        end
    end
    if base.armor == 1 and armorMatrixVoApi then
        local limitLv = armorMatrixVoApi:getPermitLevel()
        if limitLv and playerLv>= limitLv and (armorMatrixVoApi:getArmorMatrixInfo() == nil or armorMatrixVoApi.pullFreeFlag==true) then
            table.insert(modelTb,3)
        end
    end

    if base.alien==1 and base.richMineOpen==1 then
        if playerLv>=alienTechCfg.openlevel then
            if alienTechVoApi and alienTechVoApi:getFlag() == -1 then
                table.insert(modelTb,4)
            end
        end
    end
    -- print("#modelTb--->",#modelTb)
    for i=#modelTb,1,-1 do
        if self.powerGuideTb[modelTb[i]]==true then
            table.remove(modelTb,i)
        end
    end

    local function getDataSuccess(fn,data)
        local ret,sData=base:checkServerData(data)
        if ret==true then
            if sData and sData.data then
                local data = sData.data
                for k,v in pairs(modelTb) do
                    self.powerGuideTb[v]=true
                end
                if data.fcr then
                    require "luascript/script/game/gamemodel/player/powerGuideVoApi"
                    powerGuideVoApi:setFcRank(data.fcr)
                end

                if data.accessory and data.accessory.used and accessoryVoApi then
                    accessoryVoApi:refreshEquipData(data.accessory.used)
                end
                if data.equip and data.equip.info and heroEquipVoApi then
                    heroEquipVoApi:formatInfoData(data.equip.info)
                end
                if data.armor and data.armor.used and data.armor.info and armorMatrixVoApi then--armor.used + armor.info
                    armorMatrixVoApi:setPartArmorData(data.armor)
                end
                if data.alien and data.alien.used and data.alien.info and alienTechVoApi then
                    alienTechVoApi:setPartTechData(data.alien)
                end
                if isBattleEnd ==nil or isBattleEnd ==false then
                    showDialog()
                elseif battleEndCall then
                    battleEndCall()
                end
            end
        end
    end

    if #modelTb==0 then
        if isBattleEnd and battleEndCall then
            battleEndCall()
            do return end
        end
        showDialog()
    else
        socketHelper:getDataForpowerGuide(modelTb,getDataSuccess)

    end


    
    
end

--用户的战功
function playerVoApi:getRankPoint()
    return playerVo.rankPoint
end

--用户今日获得的战功
function playerVoApi:getTodayRankPoint()
    return playerVo.dailyRankPoint
end

--跨服战排名
function playerVoApi:getServerWarRank()
    return playerVo.serverWarRank
end
function playerVoApi:setServerWarRank(serverWarRank)
    playerVo.serverWarRank=serverWarRank
end

--跨服战排名称号持续时间
function playerVoApi:getServerWarRankStartTime()
    return playerVo.serverWarRankStartTime
end
function playerVoApi:setServerWarRankStartTime(serverWarRankStartTime)
    playerVo.serverWarRankStartTime=serverWarRankStartTime
end

--军团跨服战id
function playerVoApi:getServerWarTeamId()
    return playerVo.bid
end
--军团跨服战携带资金，提取资金用
function playerVoApi:getServerWarTeamUsegems()
    return playerVo.usegems
end
function playerVoApi:setServerWarTeamUsegems(usegems)
    playerVo.usegems=usegems
end

--群雄争霸携带资金，提取资金用
function playerVoApi:getServerWarLocalUsegems()
    if playerVo and playerVo.funds then
        return playerVo.funds or 0
    end
    return 0
end
function playerVoApi:setServerWarLocalUsegems(funds)
    playerVo.funds=funds
end


--本服购买金币的总金额
function playerVoApi:getbuycost()
    return playerVo.cost==nil and 0 or playerVo.cost
end
--本服购买金币的次数
function playerVoApi:getbuyn()
    return playerVo.buyn==nil and 0 or playerVo.buyn
end

--本服最后一次购买金币的时间
function playerVoApi:getbuyts()
    return playerVo.buyts==nil and 0 or playerVo.buyts
end


function playerVoApi:getPlatformCanReward()
    return self.platformReward
end
function playerVoApi:setPlatformCanReward(reward)
    self.platformReward=reward
end
function playerVoApi:addPlatformCanRewardByID(rewardid,taskid)
    if self.platformReward then
        for k,v in pairs(self.platformReward) do
            if v and v[1] and v[1] == rewardid and v[2] and v[2]==taskid then
                table.remove(self.platformReward, k)
            end
        end
    end
end

function playerVoApi:getRpCoin()
    return playerVo.rpCoin
end

function playerVoApi:setRpCoin(num)
    playerVo.rpCoin=num
end

function playerVoApi:getQQ()
    return playerVo.qq
end

function playerVoApi:setQQ(flag)
     playerVo.qq=flag
end

function playerVoApi:showPlayerCustomDialog(layerNum)
    local function callback2()
        require "luascript/script/game/scene/gamedialog/playerDialog/playerCustomDialog"
        require "luascript/script/game/scene/gamedialog/playerDialog/playerCustomDialogTab1"
        require "luascript/script/game/scene/gamedialog/playerDialog/playerCustomDialogTab2"
        require "luascript/script/game/scene/gamedialog/playerDialog/playerCustomDialogTab3"

        local td=playerCustomDialog:new()
        local tbArr={getlocal("player_icon"),getlocal("chat_buble"),getlocal("player_title")}
        local dialog=td:init("panelBg.png",true,CCSizeMake(600,900),CCRect(0, 0, 400, 350),CCRect(168, 86, 10, 10),tbArr,nil,nil,getlocal("individuation"),true,layerNum+1)
        sceneGame:addChild(dialog,layerNum+1)
    end
    self:socketGetulimit(callback2)
end

function playerVoApi:getCommonAndTeshuIconTb()
    local commonIconTb = {}
    local teshuIconTb = {}
    local heroIconTb = {}
    local unLockHead=self:getUnLockHead()
    for k,v in pairs(headCfg.list) do
        if v.type==1 then
            table.insert(commonIconTb,{key=k,value=v})
        end
         if v.type==3 then
            for m,q in pairs(unLockHead) do
                if tostring(q)==tostring(k) then
                    table.insert(teshuIconTb,{key=k,value=v})
                    break
                end
            end
        end
        if v.type==2 then
            for m,q in pairs(unLockHead) do
                if tostring(q)==tostring(k) then
                    table.insert(heroIconTb,{key=k,value=v})
                    break
                end
            end
        end
    end



    return commonIconTb,heroIconTb,teshuIconTb
end

function playerVoApi:setUnLockHead(unLockHead)
    self.unLockHead=unLockHead
end

function playerVoApi:getUnLockHead()
    if self.unLockHead then
        return self.unLockHead
    end
    return {}
end

function playerVoApi:setUnLockTitle(unLockTitle)
    self.unLockTitle=unLockTitle
end
function playerVoApi:getUnLockTitle()
    if self.unLockTitle then
        return self.unLockTitle
    end
    return {}
end

function playerVoApi:setUnLockChatFrame(unLockChatFrame)
    self.unLockChatFrame=unLockChatFrame
end

function playerVoApi:getUnLockChatFrame()
    if self.unLockChatFrame then
        return self.unLockChatFrame
    end
    return {}
end

function playerVoApi:getTitleTb()
    local titleTb={}
    local unLockTitle=self:getUnLockTitle()
    for k,v in pairs(titleCfg.list) do
        for kk,vv in pairs(unLockTitle) do
            if tostring(k)==tostring(vv) then
                 table.insert(titleTb,{key=k,value=v})
                 break
            end
        end
    end
    return titleTb

end

function playerVoApi:setPic(pic)
    playerVo.pic=pic
end

function playerVoApi:getPersonPhotoName(key,uid)
    local sid = tostring(self:getPic())
    if key then
        sid=tostring(key)
    end
    --有时因为未知原因，后台数据的头像可能是null或者0，这种情况下统一搞成默认头像防止报错
    if(sid==nil or sid=="0" or headCfg.list[tostring(sid)]==nil)then
        sid="1"
    end
    local personPhotoName
    if headCfg.list[tostring(sid)].type==1 then
        personPhotoName=headCfg.list[tostring(sid)].pic
    elseif headCfg.list[tostring(sid)].type==2  then
        local hid = "h" .. tonumber(sid)%2000
        local iconImage = headCfg.list[tostring(sid)].pic
        if(heroCfg.iconMap[hid] and heroCfg.iconMap[hid][G_getCurChoseLanguage()])then
            iconImage=heroCfg.iconMap[hid][G_getCurChoseLanguage()]
        end

        personPhotoName ="ship/Hero_Icon/"..iconImage
        if platCfg.platCfgHeroCartoonPhoto[G_curPlatName()]~=nil then
            personPhotoName ="ship/Hero_Icon_Cartoon/"..iconImage
        end
    else
        personPhotoName=headCfg.list[tostring(sid)].pic
    end
    return personPhotoName
end

--通过uid判断是否是gm
function playerVoApi:getPersonPhotoSp(key,iconSize,uid)
    local scale = 1
    local sp
    --采用GM头像逻辑
    if uid and GM_UidCfg[uid] then
        sp = CCSprite:createWithSpriteFrameName(GM_Icon)
        scale= iconSize and iconSize/sp:getContentSize().width or 80/150
        sp:setScale(scale)
        return sp
    end
    local sid = tostring(self:getPic())
    if key then
        sid=tostring(key)
    end
    --有时因为未知原因，后台数据的头像可能是null或者0，这种情况下统一搞成默认头像防止报错
    if(sid==nil or sid=="0" or headCfg.list[tostring(sid)]==nil)then
        sid="1"
    end
    if headCfg.list[tostring(sid)].type==1 then
        local personPhotoName=headCfg.list[tostring(sid)].pic
        sp=CCSprite:createWithSpriteFrameName(personPhotoName)
        if G_getGameUIVer()==2 then
            scale = 1.1
        end
    elseif headCfg.list[tostring(sid)].type==2  then
        local hid = "h" .. tonumber(sid)%2000
        local iconImage = headCfg.list[tostring(sid)].pic
        if(heroCfg.iconMap[hid] and heroCfg.iconMap[hid][G_getCurChoseLanguage()])then
            iconImage=heroCfg.iconMap[hid][G_getCurChoseLanguage()]
        end
        local heroImageStr ="ship/Hero_Icon/"..iconImage
        if platCfg.platCfgHeroCartoonPhoto[G_curPlatName()]~=nil then
            heroImageStr ="ship/Hero_Icon_Cartoon/"..iconImage
        end
        sp = CCSprite:create(heroImageStr)
        scale=70/150
        if G_getGameUIVer()==2 then
            scale=82/150
        end
    else
        local personPhotoName=headCfg.list[tostring(sid)].pic
        sp=CCSprite:createWithSpriteFrameName(personPhotoName)
        scale=70/sp:getContentSize().width
        if G_getGameUIVer()==2 then
            scale=82/sp:getContentSize().width
        end
        if personPhotoName=="threeyear_vipicon.png" then
            if G_getGameUIVer()==2 then
                scale=76/100
            else
                scale=70/100
            end
        end
    end
    sp:setScale(scale)
    return sp
end

function playerVoApi:GetPlayerBgIcon(icon,callback,iconBackSp,iconSize,bgSize,headFrameId,uid)
    --GM头像
    if uid and GM_UidCfg[uid] then
        local sp=CCSprite:createWithSpriteFrameName(GM_Icon)
        local scale = iconSize and iconSize/70 or 1
        sp:setScale(scale)
        return sp
    end
    local iconSp=CCSprite:createWithSpriteFrameName(icon)
    if iconSp==nil then
        iconSp=CCSprite:create(icon)
        iconSp:setScale(70/150)
    end
    if iconSize==nil then
        iconSize=70
    end
    --三周年头像特殊处理
    local iconWidth=iconSp:getContentSize().width
    if icon=="threeyear_vipicon.png" then
        iconWidth=100
    end
    if iconSize then
        iconSp:setScale(iconSize/iconWidth)
    end
    local iconBg
    if iconBackSp~=nil then
        if callback~=nil then
            iconBg=LuaCCSprite:createWithSpriteFrameName(iconBackSp,callback)
        else
            iconBg=CCSprite:createWithSpriteFrameName(iconBackSp)
        end
    else
        if callback~=nil then
            iconBg=LuaCCSprite:createWithSpriteFrameName("icon_bg_gray.png",callback)
        else
            iconBg=CCSprite:createWithSpriteFrameName("icon_bg_gray.png")
        end
    end

    iconSp:setPosition(getCenterPoint(iconBg))
    iconBg:addChild(iconSp)
    if bgSize then
        iconBg:setScale(bgSize/iconBg:getContentSize().width)
    else
        iconBg:setScale(1)
    end

    --头像框
    if headFrameId==nil or headFrameId=="" then
        headFrameId=headFrameCfg.default
    end
    local frameSp=self:getPlayerHeadFrameSp(headFrameId)
    if frameSp then
        frameSp:setPosition(iconBg:getContentSize().width/2,iconBg:getContentSize().height/2)
        frameSp:setScale((iconBg:getContentSize().width+7)/frameSp:getContentSize().width)
        iconBg:addChild(frameSp)
    end

    return iconBg
end

function playerVoApi:getTitle()
    return playerVo.title
end

function playerVoApi:setTitle(title)
    playerVo.title=title
end

function playerVoApi:getSwichOfGXH()
    if base.gxh==0 then
        return false
    end
    return true
end

--获取临时建造队列的过期时间戳
function playerVoApi:getTmpSlotTs()
    return playerVo.tempSlots
end

--得到vip免费加速的时间
--isOnlyVip只获取vip的加成（因为vip面板里要显示vip加成）
function playerVoApi:getFreeTime(temVip,isOnlyVip)
    local vip
    if temVip==nil then
        vip = playerVo.vip+1
    else
        vip = temVip+1
    end
     
    local time = 0
    local freespeedtimeTb = playerCfg.freespeedtime or {}
    time =  freespeedtimeTb[vip] or freespeedtimeTb[#freespeedtimeTb] or 0
    -- print("+++++++++++speedTime++++++++++++",time)

    --以下是除vip加成以外的加成逻辑处理
    local extraAdd = 0
    if isOnlyVip==nil or isOnlyVip==false then
        if base.isSkin == 1 and buildDecorateVoApi and buildDecorateVoApi.getFreeTime then
            local skinFreeTime = buildDecorateVoApi:getFreeTime()
            extraAdd = extraAdd + skinFreeTime
        end
    end
    time = time + extraAdd
    -- print("final free time ",time)
    return time
end

function playerVoApi:getPlayerBuildPic(selfLevel)---取到玩家等级对应的建筑图片 用于繁荣度
    local level = 0
    if selfLevel then
        level =selfLevel
    end
    if level<21 then
        resStr="map_base_building_1.png"
    elseif level<41 then
        resStr="map_base_building_2.png"
    elseif level<61 then
        resStr="map_base_building_3.png"
    elseif level<71 then
        resStr="map_base_building_4.png"
    else
        resStr="map_base_building_5.png"
    end
    return resStr
end
function playerVoApi:setStartPoint(point)
    playerVo.startPosition = point
end

function playerVoApi:getStartPoint()
    return playerVo.startPosition
end

function playerVoApi:setWorldLv(lv)
    if tonumber(lv)==nil or (self.worldLv and tonumber(lv)<=tonumber(self.worldLv)) then
        do return end
    end
    lv=tonumber(lv)
    local maxLv=self:getMaxLvByKey("roleMaxLevel")-20
    if lv>=tonumber(maxLv) then
        lv=tonumber(maxLv)
    end
    self.worldLv=lv
end

function playerVoApi:getWorldLv()
    return self.worldLv
end

function playerVoApi:setCurWorldExp(exp)
    if exp==nil then
        exp=0
    end
    if tonumber(exp)<=tonumber(self.curWorldExp) then
        do return end
    end
    local maxLv=self:getMaxLvByKey("roleMaxLevel")-20
    if tonumber(exp)>tonumber(goldMineCfg.worldExp[maxLv]) then
        exp=goldMineCfg.worldExp[maxLv]
    end
    self.curWorldExp=tonumber(exp)
end

function playerVoApi:getCurWorldExp()
    return self.curWorldExp
end

function playerVoApi:getNeedWorldExp()
    local lastExp=0
    local totalExp=0
    local need=0
    if goldMineCfg.worldExp then
        if goldMineCfg.worldExp[self.worldLv+1] then
            totalExp=goldMineCfg.worldExp[self.worldLv+1]
        end
        if goldMineCfg.worldExp[self.worldLv] then
            lastExp=goldMineCfg.worldExp[self.worldLv]
        end
    end
    if tonumber(totalExp-lastExp)>0 then
        need=tonumber(totalExp-lastExp)
    end
    return need
end

function playerVoApi:getWorldExpPercent()
    local needExp=0
    local curExp=0
    local lastExp=0
    local nextExp=0
    if goldMineCfg.worldExp[self.worldLv] then
        lastExp=goldMineCfg.worldExp[self.worldLv]
    end
    if goldMineCfg.worldExp[self.worldLv+1] then
        nextExp=goldMineCfg.worldExp[self.worldLv+1]
    end
    needExp=tonumber(nextExp-lastExp)
    curExp=tonumber(self.curWorldExp-lastExp)
    if nextExp<=0 then
        needExp=0
    end
    if curExp<=0 then
        curExp=0
    end
    if needExp==0 then
        return 0
    else
        local percent=curExp/needExp*100
        percent=string.format("%4.2f",percent)
        return percent
    end
end

function playerVoApi:isWorldLvTop()
    local isTop=false
    local maxLv=self:getMaxLvByKey("roleMaxLevel")-20
    if self.worldLv>=tonumber(maxLv) then
        isTop=true
    end
    return isTop
end

function playerVoApi:clear()
    playerVo.serverWarRank=0
    playerVo.serverWarRankStartTime=0
    playerVo.bid=nil
    playerVo.usegems=nil
    playerVo.func={}
    playerVo.hfid=nil
    playerVo.cfid=nil
    playerVo.flags=nil
    playerVo.alliance_create_at = nil
    playerVoApi.rankIsOpen=1
    playerVoApi.rankList={}
    playerVoApi.rankAllLoaded=false
    self.platformReward={}
    self.unLockHead={}
    self.unLockTitle={}
    self.worldLv=0
    self.curWorldExp=0
    self.playerLastLevel=0
    self.realNameRegist=false
    self.powerGuideTb={}
    self.unlockData={}
    self.newUnlockTb=nil
    self.getulimitFlag=nil
    self.unLockChatEmoji={}
    self.unLockChatFrame={}
end

-- award:转换前的奖励 tipReward:转换后的奖励
function  playerVoApi:getTrueReward(award)
    local playerHonors =self:getHonors() --用户当前的总声望值
    local maxLevel =self:getMaxLvByKey("roleMaxLevel") --当前服 最大等级
    local honTb =Split(playerCfg.honors,",")
    local maxHonors =honTb[maxLevel] --当前服 最大声望值
    local expTb =Split(playerCfg.level_exps,",")
    local maxExp = expTb[maxLevel] --当前服 最大经验值
    local playerExp = self:getPlayerExp() --用户当前的经验值


    local tipReward={}
    for k,v in pairs(award) do
        if v.name ==getlocal("honor") and base.isConvertGems==1 and tonumber(playerHonors) >=tonumber(maxHonors) then
            local numGold = self:convertGems(2,v.num)
            local tipFlag=false
            for kk,vv in pairs(tipReward) do
                if vv.type=="u" and vv.key=="gold" then
                vv.num=vv.num+numGold
                tipFlag=true
                end
            end
            if tipFlag==false then
                local name,pic,desc,id,index,eType,equipId,bgname = getItem("gold","u")
                local num=numGold
                local awardItem={type="u",key="gold",pic=pic,name=name,num=num,desc=desc,id=id,bgname=bgname}
                table.insert(tipReward,awardItem)
            end
        elseif v.name ==getlocal("sample_general_exp") and base.isConvertGems==1 and tonumber(playerExp) >=tonumber(maxExp) then
            local numGold = self:convertGems(1,v.num)
            local tipFlag=false
            for kk,vv in pairs(tipReward) do
                if vv.type=="u" and vv.key=="gold" then
                vv.num=vv.num+numGold
                tipFlag=true
                end
            end
            if tipFlag==false then
                local name,pic,desc,id,index,eType,equipId,bgname = getItem("gold","u")
                local num=numGold
                local awardItem={type="u",key="gold",pic=pic,name=name,num=num,desc=desc,id=id,bgname=bgname}
                table.insert(tipReward,awardItem)
            end
        else
            table.insert(tipReward,G_clone(v))
        end
    end
    return tipReward
end

-- 设置lastLevel
function  playerVoApi:setPlayerLastLevel(uid,level)
    local key=self:getPlayerLastKey(uid)
    CCUserDefault:sharedUserDefault():setIntegerForKey(key,level)
    CCUserDefault:sharedUserDefault():flush()
    self.playerLastLevel=level
end

function  playerVoApi:getPlayerLastKey(uid)
    local lastLevelKey="playerLastLevel@"..tostring(uid).."@"..tostring(base.curZoneID)
    return lastLevelKey
end

function playerVoApi:getHfid()
    return playerVo.hfid
end

function playerVoApi:getTodayFund( ... )
    return tonumber(playerVo.daily_dfund[1])
end

function playerVoApi:getTodatFundTime( ... )
    return playerVo.daily_dfund[2]
end

-- 是否弹出
function playerVoApi:getXsjxPop( ... )
    if base.xsjx == 0 then
        do return false end
    end
    if playerVo.xsjx and playerVo.xsjx.pop then
        if playerVo.xsjx.pop == 1 then
            return true
        else
            return false
        end
    end
end

-- 刷新限时惊喜的数据
function playerVoApi:refreshXsjxData(data)
     if playerVo.xsjx then
        playerVo.xsjx = data
     end
end


function playerVoApi:setXsjxPop( ... )
    if playerVo.xsjx and playerVo.xsjx.pop and playerVo.xsjx.pop == 1 then
        playerVo.xsjx.pop = 0
    end
end

-- 判断礼包是否过期
function playerVoApi:isXsjxValid()
    if playerVo.xsjx and playerVo.xsjx.td and playerVo.xsjx.td ~= 0 and base.serverTime >= playerVo.xsjx.td and base.serverTime <= playerVo.xsjx.td+86340 then
        return true
    else
        return false
    end
end

function playerVoApi:getXsjxRewardStatus( ... )
    if playerVo.xsjx and playerVo.xsjx.r then
        if playerVo.xsjx.r == 1 then
            return false
        else
            return true
        end
    end
end

function playerVoApi:setXsjxRewardStatus( )
    if playerVo.xsjx and playerVo.xsjx.r then
        playerVo.xsjx.r = 1
    end
end

-- 弹出礼包的奖励库下标
function playerVoApi:getXsjxRewardBank( ... )
    if playerVo.xsjx and playerVo.xsjx.g1 then
        return playerVo.xsjx.g1
    end
end

-- 奖励库中的礼包下标
function playerVoApi:getXsjxRewardTemp( ... )
    if playerVo.xsjx and playerVo.xsjx.g2 then
        return playerVo.xsjx.g2
    end
end

function playerVoApi:getRechargeNum( ... )
    if playerVo.xsjx and playerVo.xsjx.ch then
        return playerVo.xsjx.ch
    end
end

function playerVoApi:getGiftPushET( ... )
    if playerVo.xsjx and playerVo.xsjx.pt then
        return playerVo.xsjx.pt
    end
end


function playerVoApi:getAllFund()
    return playerVo.daily_fund
end

function playerVoApi:getCfid()
    return playerVo.cfid
end

function playerVoApi:setHfid(hfid)
    playerVo.hfid=hfid
end

function playerVoApi:setCfid(cfid)
    playerVo.cfid=cfid
end

function playerVoApi:getPlayerHeadFrameSp(hfid,callback,isStopAc)
    local sid = tostring(self:getHfid())
    if hfid then
        sid=tostring(hfid)
    end
    local hfCfg = headFrameCfg.list[sid]
    if hfCfg and "icon_bg_gray.png"~=hfCfg.pic then
        local function touchHandler()
            if callback then
                callback()
            end
        end
        local frameSp=LuaCCSprite:createWithSpriteFrameName(hfCfg.pic,touchHandler)
        if sid=="h3001" then
            local headTitleSp=CCSprite:createWithSpriteFrameName("fi_headFrameTop6.png")
            headTitleSp:setAnchorPoint(ccp(0.5,1))
            headTitleSp:setPosition(frameSp:getContentSize().width/2,frameSp:getContentSize().height+5)
            frameSp:addChild(headTitleSp)
            if isStopAc == nil or isStopAc == false then
                G_playParticle(frameSp,ccp(frameSp:getContentSize().width/2,frameSp:getContentSize().height),"public/believer/s2-shang.plist",kCCPositionTypeRelative,nil,nil,ccp(0.5,1),5)
                G_playParticle(frameSp,ccp(frameSp:getContentSize().width/2,0),"public/believer/s2-xia.plist",kCCPositionTypeRelative,nil,nil,ccp(0.5,1),5)

                local speed=0.01
                local moveX=frameSp:getContentSize().width/2-5
                local moveY=frameSp:getContentSize().height-5
                local beginPos=ccp(frameSp:getContentSize().width/2,frameSp:getContentSize().height)
                for i=1,2 do
                    local dianSp=G_playParticle(frameSp,beginPos,"public/believer/s2-dian.plist",kCCPositionTypeRelative,nil,nil,nil,5)
                    dianSp:setVisible(false)
                    local acArr=CCArray:create()
                    local function moveBegin()
                        dianSp:setVisible(true)
                    end
                    local dt1,dt2=moveX*speed,moveY*speed
                    print("dt1,dt2",dt1,dt2)
                    local moveBy1=CCMoveBy:create(dt1,ccp((2*i-3)*moveX,0))
                    local moveBy2=CCMoveBy:create(dt2,ccp(0,-moveY))
                    local moveBy3=CCMoveBy:create(dt1,ccp((3-2*i)*moveX,0))
                    local moveBy4=CCMoveBy:create(0.1,ccp(0,moveY))
                    local function moveEnd()
                        -- dianSp:setVisible(false)
                        dianSp:setPosition(beginPos)

                    end
                    local function reset()
                        dianSp:setPosition(beginPos)
                    end
                    acArr:addObject(CCCallFunc:create(moveBegin))
                    acArr:addObject(moveBy1)
                    acArr:addObject(moveBy2)
                    acArr:addObject(moveBy3)
                    acArr:addObject(moveBy4)
                    acArr:addObject(CCCallFunc:create(moveEnd))
                    -- acArr:addObject(CCDelayTime:create(0.3))
                    -- acArr:addObject(CCCallFunc:create(reset))
                    -- acArr:addObject(CCDelayTime:create(0.3))
                    local seq=CCSequence:create(acArr)
                    -- dianSp:runAction(seq)
                    dianSp:runAction(CCRepeatForever:create(seq))
                end
            end
        elseif sid == "h6001" then
            local hfEffectSp = CCSprite:createWithSpriteFrameName("fi_headFrame9_effect1.png")
            G_setBlendFunc(hfEffectSp, GL_ONE, GL_ONE)
            local frameArr = CCArray:create()
            for i = 1, 10 do
                local frame = CCSpriteFrameCache:sharedSpriteFrameCache():spriteFrameByName("fi_headFrame9_effect" .. i .. ".png")
                if frame then
                    frameArr:addObject(frame)
                end
            end
            local animation = CCAnimation:createWithSpriteFrames(frameArr, 0.08)
            local animate = CCAnimate:create(animation)
            hfEffectSp:setAnchorPoint(ccp(0.5, 0.5))
            hfEffectSp:setPosition(getCenterPoint(frameSp))
            frameSp:addChild(hfEffectSp, 1)
            hfEffectSp:runAction(CCRepeatForever:create(animate))
        elseif sid == "h6002" then
            local hfFrameName = "acznjl_hf1.png"
            local znjlHfSp = CCSprite:createWithSpriteFrameName(hfFrameName)
            local blendFunc = ccBlendFunc:new()
            blendFunc.src = GL_ONE
            blendFunc.dst = GL_ONE
            znjlHfSp:setBlendFunc(blendFunc)
            local pzArr = CCArray:create()
            for kk=1,15 do
                local nameStr= "acznjl_hf"..kk..".png"
                local frame = CCSpriteFrameCache:sharedSpriteFrameCache():spriteFrameByName(nameStr)
                pzArr:addObject(frame)
            end
            local animation = CCAnimation:createWithSpriteFrames(pzArr)
            animation:setDelayPerUnit(0.08)
            local animate = CCAnimate:create(animation)
            znjlHfSp:setAnchorPoint(ccp(0.5,0.5))          
            znjlHfSp:setPosition(getCenterPoint(frameSp))
            frameSp:addChild(znjlHfSp,1)
            local repeatForever = CCRepeatForever:create(animate)
            znjlHfSp:runAction(repeatForever)
        elseif sid == "h6007" then
            local heffectSp = CCSprite:createWithSpriteFrameName("fi_hf18_1.png")
            G_playFrame(heffectSp, {frmn=15, frname="fi_hf18_", perdelay=0.08, forever={0, 0}, blendType=1})
            heffectSp:setPosition(getCenterPoint(frameSp))
            frameSp:addChild(heffectSp)
        elseif sid == "h6008" then
            local heffectSp = CCSprite:createWithSpriteFrameName("fi_hf19_1.png")
            G_playFrame(heffectSp, {frmn=15, frname="fi_hf19_", perdelay=0.08, forever={0, 0}, blendType=1})
            heffectSp:setPosition(getCenterPoint(frameSp))
            frameSp:addChild(heffectSp)
        end
        return frameSp
    end
    return nil
end

function playerVoApi:foramtUnlockData(data)
    if data==nil then
        do return end
    end

----------- TODO TEST -----------
    -- data={
        -- h={ ["3501"]={1549736070} },
        -- hb={},
        -- bb={},
    -- }
----------- TODO TEST -----------

    self.unlockData={}
    for k, v in pairs(data) do
        local _tempTb={}
        for i, j in pairs(v) do
            -- if j[1]>base.serverTime then --未过期的
                table.insert(_tempTb,{i,j[1]})
            -- end
        end
        if k=="h" then
            self.unlockData[1]=_tempTb
        elseif k=="hb" then
            self.unlockData[2]=_tempTb
        elseif k=="bb" then
            self.unlockData[3]=_tempTb
        end
    end
end

--1:头像、2:头像框、3:聊天框
function playerVoApi:getUnLockData(_index)
    if _index==nil then
        do return end
    end
    if self.unlockData and self.unlockData[_index] then
        return self.unlockData[_index]
    end
end

function playerVoApi:setUnLockData(_index,_dataTb)
    if _index==nil or _dataTb==nil then
        do return end
    end
    if self.unlockData==nil then
        self.unlockData={}
    end
    if self.unlockData[_index]==nil then
        self.unlockData[_index]={}
    end
    table.insert(self.unlockData[_index],_dataTb)

    --新添加的flag表
    if self.newUnlockTb==nil then
        self.newUnlockTb={}
    end
    if self.newUnlockTb[_index]==nil then
        self.newUnlockTb[_index]={}
    end
    table.insert(self.newUnlockTb[_index],_dataTb[1])
end

--1:头像、2:头像框、3:聊天框
function playerVoApi:getNewUnlockTb(_index)
    if _index==nil then
        do return end
    end
    if self.newUnlockTb and self.newUnlockTb[_index] then
        return self.newUnlockTb[_index]
    end
end

function playerVoApi:delNewUnlockTb(_index)
    if _index==nil then
        do return end
    end
    if self.newUnlockTb and self.newUnlockTb[_index] then
        self.newUnlockTb[_index]=nil
    end
end

function playerVoApi:socketGetulimit(_callback)
    local function callback2(fn,data)
        local ret,sData = base:checkServerData(data)
        if ret==true then
            if sData.data and sData.data.unlockLimit then
                self:foramtUnlockData(sData.data.unlockLimit)
            end
            if _callback then
                _callback()
            end
        end
    end
    socketHelper:getulimit(callback2)
end

function playerVoApi:tick()
    --检测头像、头像框、聊天框是否过期
    if self.unlockData and SizeOfTable(self.unlockData)>0 then
        for k, v in pairs(self.unlockData) do
            local _id, _cfgList
            if k==1 then
                _id=self:getPic()
                _cfgList = headCfg.list
            elseif k==2 then
                _id=self:getHfid()
                _cfgList = headFrameCfg.list
            elseif k==3 then
                _id=self:getCfid()
                _cfgList = chatFrameCfg.list
            end
            for m, q in pairs(v) do
                -- local _isExpire
                if _cfgList and _cfgList[q[1]] and _cfgList[q[1]].time and q[2]<=base.serverTime then --过期
                    -- _isExpire=true
                    local _isUsed
                    if tostring(q[1])==tostring(_id) then --当前使用中的...
                        _isUsed=true
                        if k==1 then
                            self:setPic(headCfg.default)
                        elseif k==2 then
                            self:setHfid(headFrameCfg.default)
                        elseif k==3 then
                            self:setCfid(chatFrameCfg.default)
                        end
                        if k<3 then
                            eventDispatcher:dispatchEvent("playerIcon.Change",{})
                        end
                    end
                    if k<3 then
                        eventDispatcher:dispatchEvent("playerCustomDialogTab1.playerIconChange",{k,q[1]})
                    end
                    if _isUsed or k==3 then
                        eventDispatcher:dispatchEvent("playerCustomDialogTab3.playerIconChange",{k,q[1]})
                    end
                    if playerCustomDialogTab2 then
                        eventDispatcher:dispatchEvent("playerCustomDialogTab2.playerIconChange",{k,q[1]})
                    end
                    table.remove(self.unlockData[k],m)
                end
            end
        end
    else
        if not self.getulimitFlag then
            self.getulimitFlag=true
            self:socketGetulimit()
        end
    end
    playerVo.daily_online_time = (playerVo.daily_online_time or 0) + 1
end

function playerVoApi:formatTitleCfgInfo()
    local newTitleCfg = {}
    local typeTb = {}
    if titleCfg then
        local list = titleCfg.list
        for k,v in pairs(list) do
            if newTitleCfg[k] == nil and v.isShow == 1 then
                newTitleCfg[k] = v
                typeTb = self:addTitleTypeInTb(v,typeTb)
            end
        end
    end

    local unlockTitleTb = self:getTitleTb()

    for k,v in pairs(unlockTitleTb) do
        if v.value.isShow == 0 then
            newTitleCfg[v.key] = v.value
            typeTb = self:addTitleTypeInTb(v.value,typeTb)
        end
    end

    if not typeTb[1] then--基础称号
        local typeName = getlocal("defalut")..getlocal("player_title")--基础称号
        typeTb[1] = typeName
    end

    return newTitleCfg,typeTb
end

function playerVoApi:addTitleTypeInTb(vv,typeTb)

    if not typeTb[vv.type] then
        local typeName = getlocal("defalut")..getlocal("player_title")--基础称号
        if vv.type == 3 then
            typeName = getlocal("time_limit")..getlocal("player_title")
        elseif vv.type == 4 then
            typeName = getlocal("RankScene_level")..getlocal("player_title")
        elseif vv.type == 5 then
            typeName = getlocal("vipTitle")..getlocal("player_title")
        elseif vv.type == 6 then
            typeName = getlocal("activity")..getlocal("player_title")
        elseif vv.type == 7 then
            typeName = getlocal("warStr")..getlocal("player_title")
        end

        typeTb[vv.type] = typeName
    end
    return typeTb
end

--玩家等级发生变化的处理
function playerVoApi:onPlayerLvChanged(lastLevel)
    --成绩系统首次解锁的时候拉取一下成就系统数据
    if achievementVoApi then
        achievementVoApi:onPlayerLvChanged(lastLevel)
    end
    -- 升级到达皮肤解锁等级，前端初始化皮肤数据
    if buildDecorateVoApi and lastLevel < exteriorCfg.openlv and playerVoApi:getPlayerLevel() >= exteriorCfg.openlv then
        buildDecorateVoApi:initSkinTbByLevel()
    end
end

function playerVoApi:setRebelBuffEndTs(mt)
    playerVo.flags.mt=mt
end

--叛军天眼buff是否生效
function playerVoApi:isRebelBuffActive()
    local mt=playerVo.flags.mt or 0
    if base.serverTime>=mt then
        return false,mt
    else
        return true,mt
    end
end

function playerVoApi:getSkin( ... )
    if playerVo and playerVo.skin then
        return playerVo.skin
    end
end

--获取使用改名卡修改玩家名字剩余的CD时间
function playerVoApi:getChangeNameCD()
    if playerVo and playerVo.nameChangedCD then
        local cfgCd = propCfg["p4933"].useCDTime
        if base.serverTime >= playerVo.nameChangedCD + cfgCd then
            return 0
        end
        return playerVo.nameChangedCD + cfgCd - base.serverTime
    end
    return 0
end

function playerVoApi:setChangeNameCD(cdtime)
    if playerVo then
        playerVo.nameChangedCD = cdtime or base.serverTime
    end
end

function playerVoApi:setUnLockChatEmoji(unLockChatEmoji)
    self.unLockChatEmoji = unLockChatEmoji
end

function playerVoApi:getUnLockChatEmoji()
    if self.unLockChatEmoji then
        return self.unLockChatEmoji
    end
    return {}
end

--获取恢复一点能量剩余的时间
function playerVoApi:getEnergyRecoverLeftTime()
    local rt = playerVoApi:getPerEnergyRecoverTime()
    local lt = rt - (base.serverTime - playerVo.energy_at) % rt
    -- print("recover time ===>", GetTimeStr(lt))
    return lt
end

--获取能量点回复加成比例
function playerVoApi:getEnergyRecoverRate()
    --战机改装技能加成
    local rate = planeRefitVoApi:getSkvByType(62)

    return rate
end

--获取能量恢复一点的时间
function playerVoApi:getPerEnergyRecoverTime()
    local rate = playerVoApi:getEnergyRecoverRate()
    return math.floor(1800 * (1 - rate))
end

---拿到所有解锁的头像框的数量
function playerVoApi:getUnLockHeadFrameNums( )
    local headFrameList = headFrameCfg and headFrameCfg.list or {}
    local frameNums = 1 --SizeOfTable(headFrameList)
    local unLockData=self:getUnLockData(2)
        for k,v in pairs(headFrameList) do
            if v.type == 4 and self:getPlayerLevel() >= v.level then
                frameNums = frameNums + 1
            elseif v.type == 5 and self:getVipLevel() >= v.vip then
                frameNums = frameNums + 1
            end

            if unLockData then
                for kk,vv in pairs(unLockData) do
                    if tostring(vv[1]) == k and not v.time then
                        frameNums = frameNums + 1
                    end
                end
            end
        end
    return frameNums
end

--每月累计消费（货币非金币）
function playerVoApi:getMonthlyPay()
    if playerVo and playerVo.mpay then
        local mEndTs = playerVo.mpay[1]
        if base.serverTime >= mEndTs then --跨月
            playerVo.mpay[1] = G_getEOM()
            playerVo.mpay[2] = 0
        end
        return playerVo.mpay[2] or 0
    end
    return 0
end

--获取每日累计在线时长
function playerVoApi:getDailyOnlineTime()
    return playerVo.daily_online_time
end

--获取每日累计在线时长
function playerVoApi:resetDailyOnlineTime()
    playerVo.daily_online_time = 0
end

function playerVoApi:setCreateAt(at)
    playerVo.alliance_create_at = tonumber(at or 0)
end

--获取创建军团冷却时间
function playerVoApi:getCreateAllianceCoolingTime()
    if playerVo.alliance_create_at and playerVo.alliance_create_at > 0 then
        local et = playerVo.alliance_create_at + 86400
        return et - base.serverTime
    end
    return 0
end