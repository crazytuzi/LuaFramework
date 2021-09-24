arenaVoApi={
    arenaVo=nil,
    shopInfo={},
    userInfo={},
    weets=0,
}

function arenaVoApi:initData(arenatb)
    if self.arenaVo==nil then
        self.arenaVo=arenaVo:new()
    end
    self.arenaVo:initData(arenatb)

    if arenatb then
        if arenaReportVoApi and arenatb.unread then
            local unread=tonumber(arenatb.unread)
            arenaReportVoApi:setUnreadNum(unread)
        end
        if arenaReportVoApi and arenatb.maxrows then
            local totalNum=tonumber(arenatb.maxrows)
            arenaReportVoApi:setTotalNum(totalNum)
        end
    end
end

function arenaVoApi:getAttacklist()

    table.sort(arenaVoApi:getArenaVo().attacklist,function(a,b) return tonumber(a[1])<tonumber(b[1]) end)

    return arenaVoApi:getArenaVo().attacklist 

end

function arenaVoApi:isLuckReward()
    local isReward=false
    local rank = 0
    if self.arenaVo~=nil and self.luckrank~=nil and self.luckrank.uprank~=nil then
        for k,v in pairs(arenaVoApi:getArenaVo().luckrank.uprank) do
            if v[2]==playerVoApi:getUid() then
                isReward=true
                rank=v[1]
            end
        end
    end
    return isReward,rank
end

function arenaVoApi:isCanReward()
    local isReward=false
    if self.arenaVo~=nil then
        if self.arenaVo.reward_at<self.arenaVo.rewardtime[1] then
            isReward=true
        end
        if self.arenaVo.rewardtime[1]>base.serverTime then
            isReward=false
        end
    end
    return isReward
end



function arenaVoApi:getCDTime()
    local time=0
    if self.arenaVo~=nil then
        time=self.arenaVo.cdtime_at-base.serverTime
    end
    return time
end

function arenaVoApi:getRewardTime()
    local time=0
    if self.arenaVo~=nil then
        time=self.arenaVo.rewardtime[2]-base.serverTime
        if time<=0 then
            time=0
        end
    end
    return time
end


function arenaVoApi:tick()
    --self:tickCDTime()
end


--取出演习VO
function arenaVoApi:getArenaVo()
    return self.arenaVo
end

function arenaVoApi:isNPC(uid)
    if type(uid)=="number" and uid<=450 then
        return true
    end
    return false
end

function arenaVoApi:getNpcNameById(uid,name)
    if self:isNPC(uid)==true then
        local npcNameKey=nil
        local npcNameNum=nil
        for k,v in pairs(arenaCfg.npcName) do
            if uid<=v then
                npcNameKey="npcName"..k
                npcNameNum=k
                break
            end
        end
        local npcName = nil
        if npcNameKey~=nil then
            local nameNum = uid
            if npcNameNum>1 then
                nameNum = uid-arenaCfg.npcName[npcNameNum-1]
            end
            npcName=getlocal(npcNameKey,{nameNum})
        end

        return npcName
    elseif name~=nil then
        return name
    end
end

--清空
function arenaVoApi:clear()
    self.arenaVo=nil
    self.weets=0

    self:clearShop()
    self:clearUserInfo()
end

--------------- 军事演习新增 -----------------

function arenaVoApi:getRanking()
    return self:getArenaVo().ranking or 0
end
function arenaVoApi:getOldRanking()
    return self:getArenaVo().oldRanking or 0
end
function arenaVoApi:setOldRanking(oldRanking )
    self:getArenaVo().oldRanking = oldRanking
end
function arenaVoApi:getAttack_num()
    return self:getArenaVo().attack_num or 0
end

function arenaVoApi:getAttack_count()
    return self:getArenaVo().attack_count or 0
end

function arenaVoApi:setAttack_num(num)
    self:getArenaVo().attack_num = num
end

function arenaVoApi:setAttack_count(num)
    self:getArenaVo().attack_count = num
end

function arenaVoApi:getShop()
    return self.shopInfo
end

function arenaVoApi:clearShop()
    self.shopInfo={}
end

function arenaVoApi:clearUserInfo()
    self.userInfo={}
end

function arenaVoApi:initShop(tb,rt)
    self:clearShop()
    if tb~=nil then
        self.shopInfo=tb
        if rt then
            self.userInfo.rt=rt
        end
        
    end
end

function arenaVoApi:addBuy(id)
    table.insert(self.userInfo.buy,id)
end

function arenaVoApi:isSoldOut(id)
    local isSoldOut = false
    for k,v in pairs(self.userInfo.buy) do
        if v==id then
            isSoldOut = true
            break
        end
    end
    return isSoldOut
end

function arenaVoApi:setBuy(buy)
    self.userInfo.buy = buy or {}
end

function arenaVoApi:initRfcAdnRft(rfc,rft)
    self.userInfo.rfc=rfc
    self.userInfo.rft=rft
end

function arenaVoApi:getRft()
    return self.userInfo.rft
end

function arenaVoApi:getRfc()
    return self.userInfo.rfc
end

function arenaVoApi:getRefreshCost()
    local count = self:getRfc() or 0
    local num = count+1
    local cost = 0

    local refreshCost = arenaCfg.refreshCost or {}
    if num>=#refreshCost then
        cost=refreshCost[#refreshCost]
    else
        cost=refreshCost[num]
    end
    return cost
end

function arenaVoApi:getRefreshTime()
    return self.userInfo.rt or 0
end

function arenaVoApi:getRefreshTimeStr()
    local time=self:getRefreshTime()
    local timeStr
    if G_isGlobalServer()==true then
        timeStr=G_getCDTimeStr(time)
    else
        timeStr=G_getDataTimeStr(time)
    end
    return timeStr
end

-- 军事演习竞技勋章
function arenaVoApi:getPoint()
    if self:getArenaVo() then
        return self:getArenaVo().point or 0
    end
    return 0
end

function arenaVoApi:setPoint(point)
    if self.arenaVo==nil then
        self.arenaVo=arenaVo:new()
    end
    self:getArenaVo().point=point
end

function arenaVoApi:addPoint(addPoint)
    if self.arenaVo==nil then
        self.arenaVo=arenaVo:new()
    end
    local point = self.arenaVo.point or 0
    self.arenaVo.point = point+addPoint
end

-- 奖励配置
function arenaVoApi:getRankRewardCfg()
    return arenaCfg.rankReward
end

function arenaVoApi:getPointRewardCfg()
    return arenaCfg.pointReward
end

-- 进度条位置
function arenaVoApi:getPercentage()
    local pointReward=self:getPointRewardCfg()
    local score = self:getArenaVo().score

    local numDuan = SizeOfTable(pointReward)
    local everyPer = 100/numDuan

    local per = 0
    local diDuan=0 
    for i=1,numDuan do
        if score<=pointReward[i].point then
            diDuan=i
            break
        end
    end

    if score>=pointReward[numDuan].point then
        per=100
    elseif diDuan==1 then
        per=score/pointReward[1].point/numDuan*100
    else
        per = (diDuan-1)*everyPer+(score-pointReward[diDuan-1].point)/(pointReward[diDuan].point-pointReward[diDuan-1].point)/numDuan*100
    end

    return per
end

-- 已经领取的积分奖励
function arenaVoApi:getDr()
    return self:getArenaVo().dr or {}
end

function arenaVoApi:setDr(dr)
    self:getArenaVo().dr = dr
end

-- 是否有积分奖励未领取
function arenaVoApi:isHaveScoreReward()
    local arenaVo=self:getArenaVo()
    if arenaVo and arenaVo.score and arenaVo.dr then
        local haveNum = SizeOfTable(self:getDr())
        local score = self:getArenaVo().score

        local pointReward=self:getPointRewardCfg()
        local numDuan = SizeOfTable(pointReward)
        local diDuan=0
        for i=numDuan,1,-1 do
            if score>=pointReward[i].point then
                diDuan=i
                break
            end
        end

        if diDuan>haveNum then
            return true
        end
    end

    return false

end

-- 0点调用shopget
function arenaVoApi:isShopToday()
    local isToday=true
    if self.userInfo.rt and base.serverTime>self.userInfo.rt then--- self.userInfo.rt 判断是否存在 临时使用（整合商店时修改）
        isToday=false
    end
    return isToday
end

-- 购买次数花金币
function arenaVoApi:needGoldForchallenge()
    local buy_num = self:getArenaVo().buy_num
    local buyChallengingTimesGold2 =  arenaCfg.buyChallengingTimesGold2

    local cost = 50
    local diNum = buy_num+1
    local num = SizeOfTable(buyChallengingTimesGold2)

    if diNum>num then
        cost=buyChallengingTimesGold2[num]
    else
        cost=buyChallengingTimesGold2[diNum]
    end
    return cost
end

-- 是否还能购买挑战次数
function arenaVoApi:isCanBuyChallengeTimes()
    local buy_num = self:getArenaVo().buy_num
    local diNum = buy_num+1

    local key = "vip"..playerVoApi:getVipLevel()
    local num =arenaCfg.buyChallengingTimes2[key]
    if diNum>num then
        return false
    end
    return true
end

-- 0点调用get
function arenaVoApi:isToday()
    local isToday=true
    local time = self:getArenaVo().attack_at
    if time then
        isToday=G_isToday(time)
    end
    return isToday
end

function arenaVoApi:goldForAnotherBatch()
    local ref_num = self:getArenaVo().ref_num or 0
    local numDang = SizeOfTable(arenaCfg.refershPrice)
    if ref_num+1>numDang then
        return arenaCfg.refershPrice[numDang]
    else
        return arenaCfg.refershPrice[ref_num+1]
    end
end

-- 
function arenaVoApi:setWeets(weets)
    self.weets=weets
end

-- 23:55-24:00不能战斗
function arenaVoApi:isCanBattle()
    local weets=self.weets or 0
    if self.weets+24*3600-base.serverTime<arenaCfg.rewardStopWarTime2 and self.weets+24*3600-base.serverTime>0 then
        return true
    end
    return false
end



function arenaVoApi:showShamBattleDialog(layerNum)
     local function callback(fn,data)
        local ret,sData=base:checkServerData(data)
        if ret==true then
            require "luascript/script/game/scene/gamedialog/shambattleDialog/shamBattleDialog"
            local td=shamBattleDialog:new()
            local tbArr={}
            local dialog=td:init("panelBg.png",true,CCSizeMake(600,900),CCRect(0, 0, 400, 350),CCRect(168, 86, 10, 10),tbArr,nil,nil,getlocal("arena_title"),true,layerNum)
            sceneGame:addChild(dialog,layerNum)
        end
    end
    socketHelper:militaryGet(callback)
    
end

function arenaVoApi:showShamBattleFleetDialog(layerNum)
    require "luascript/script/game/scene/gamedialog/shambattleDialog/shamBattleFleetDialog"
    local td=shamBattleFleetDialog:new()
    local tbArr={}
    local dialog=td:init("panelBg.png",true,CCSizeMake(600,900),CCRect(0, 0, 400, 350),CCRect(168, 86, 10, 10),tbArr,nil,nil,getlocal("shamBattle_troops"),true,layerNum)
    sceneGame:addChild(dialog,layerNum)
end

function arenaVoApi:showShamBattleShopDialog(layerNum)
    -- local function reCallback(fn,data)
    --     local ret,sData=base:checkServerData(data)
    --     if ret==true then
            -- require "luascript/script/game/scene/gamedialog/shambattleDialog/shamBattleShopDialog"
            -- local td=shamBattleShopDialog:new()
            -- local tbArr={}
            -- local dialog=td:init("panelBg.png",true,CCSizeMake(600,900),CCRect(0, 0, 400, 350),CCRect(168, 86, 10, 10),tbArr,nil,nil,getlocal("shanBattleShop_title"),true,layerNum)
            -- sceneGame:addChild(dialog,layerNum)

            local td = allShopVoApi:showAllPropDialog(layerNum,"drill")
    --     end
    -- end
    
    -- socketHelper:shamBattleGetshop(reCallback)
end

function arenaVoApi:showShamBattleRankDialog(layerNum)
    local function reCallback(fn,data)
        local ret,sData=base:checkServerData(data)
        if ret==true then
             require "luascript/script/game/scene/gamedialog/shambattleDialog/shamBattleRankDialog"
            local td=shamBattleRankDialog:new()
            local tbArr={}
            local dialog=td:init("panelBg.png",true,CCSizeMake(600,900),CCRect(0, 0, 400, 350),CCRect(168, 86, 10, 10),tbArr,nil,nil,getlocal("shanBattleRank_title"),true,layerNum)
            sceneGame:addChild(dialog,layerNum)
        end
       
    end
    socketHelper:militaryRanklist(reCallback)
end

function arenaVoApi:showShamBattleRewardDialog(layerNum)
    require "luascript/script/game/scene/gamedialog/shambattleDialog/shamBattleRewardDialog"
    require "luascript/script/game/scene/gamedialog/shambattleDialog/shamBattleRewardTab1"
    require "luascript/script/game/scene/gamedialog/shambattleDialog/shamBattleRewardTab2"

    local td=shamBattleRewardDialog:new()
    local tbArr={getlocal("shanBattleReward_tab1"),getlocal("arena_rankReward")}
    local dialog=td:init("panelBg.png",true,CCSizeMake(600,900),CCRect(0, 0, 400, 350),CCRect(168, 86, 10, 10),tbArr,nil,nil,getlocal("shanBattleReward_title"),true,layerNum)
    sceneGame:addChild(dialog,layerNum)
end

function arenaVoApi:showShamBattleReportDialog(layerNum)
    require "luascript/script/game/scene/gamedialog/shambattleDialog/shamBattleReportDialog"

    local td=shamBattleReportDialog:new()
    local tbArr={}
    local dialog=td:init("panelBg.png",true,CCSizeMake(600,900),CCRect(0, 0, 400, 350),CCRect(168, 86, 10, 10),tbArr,nil,nil,getlocal("arena_fightRecord"),true,layerNum)
    sceneGame:addChild(dialog,layerNum)
end

function arenaVoApi:showEnemyInfoSmallDialog(layerNum,attacklist,data)
    require "luascript/script/game/scene/gamedialog/shambattleDialog/enemyInfoSmallDialog"

    local sd=enemyInfoSmallDialog:new(layerNum,attacklist,data)
    local dialog= sd:init(callback)
end







