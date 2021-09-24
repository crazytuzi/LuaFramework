require "luascript/script/game/gamemodel/glory/gloryVo"
require "luascript/script/config/gameconfig/gloryCfg"

gloryVoApi ={
    isRef =false,
}

function gloryVoApi:clearAll( )
    self.isRef = false
end
function gloryVoApi:addPlayerGlory( data)
    return gloryVo:initWithData(data)
end

function gloryVoApi:refreshNewData(callBack)

    local curLevel,curBoom,curBoomMax = gloryVoApi:getPlayerCurGloryWithLevel( )
    -- print("SizeOfTable(gloryCfg.glory)======>>>>>",SizeOfTable(gloryCfg.glory))
    -- print("gloryVo.isRef=====>>>>>>>>>",self.isRef,curLevel,gloryCfg.glory[31]["needGloryExp"],curBoomMax)
    if self.isRef == false and SizeOfTable(gloryCfg.glory) > 31 and gloryCfg.glory[31]["needGloryExp"] == curBoomMax then
        local function renewCall(fn,data)
            local ret,sData = base:checkServerData(data)
            if ret==true then
                if sData.data.boom then
                    self.isRef = true
                    self:addPlayerGlory(sData.data.boom)
                    if callBack then
                        callBack()
                    end
                end
            end
        end
        socketHelper:refreshGloryData(renewCall)
    elseif callBack then
        callBack()
    end
end

function gloryVoApi:getPlayerGlory()--玩家繁荣度上限配置
    local curGloryTb = {}
    local curBoom = gloryVo.curBoom--当前繁荣度
    local curBoomMax = gloryVo.curBoomMax
    local gloryTb = gloryCfg.glory
    local nextGloryTb = nil
    local nextStr = nil
    if curBoom > curBoomMax then
        curBoom =curBoomMax
    end

    local maxLevel = playerVoApi:getMaxLvByKey("roleMaxLevel")
    local tbMaxNums = SizeOfTable(gloryTb)
    for i=1,tbMaxNums do
        -- print("curBoom~~~",curBoom,gloryTb[i].needGloryExp)
        if (curBoom >= gloryTb[i].needGloryExp and gloryTb[i].versionNeed <= maxLevel) or i == 1 then
            curGloryTb.level =gloryTb[i].level
            curGloryTb.troopsUp =gloryTb[i].troopsUp
            curGloryTb.resource =tostring(gloryTb[i].productAdd*100).."%"
            curGloryTb.isGloryOver =self:isGloryOver()
            curGloryTb.productAdd =gloryTb[i].productAdd
            if curGloryTb.isGloryOver ==true then
                    curGloryTb.resource = tonumber(gloryCfg.destoryGlory.prductAdd*100).."%"
                    curGloryTb.productAdd =gloryCfg.destoryGlory.prductAdd
            end
            if  gloryTb[i].productAdd <0 and curGloryTb.isGloryOver ==false then
                curGloryTb.resource = "-"..curGloryTb.resource
            elseif gloryTb[i].productAdd >0 then
                curGloryTb.resource = "+"..curGloryTb.resource
            end
            curGloryTb.curBoomMax =curBoomMax
            curGloryTb.curBoom = math.ceil(curBoom)

            curGloryTb.needGloryExp = gloryTb[i].needGloryExp
            nextGloryTb =gloryTb[i+1]
            -- print("nextGloryTb.versionNeed <= maxLevel----->",nextGloryTb.versionNeed,maxLevel)
            if nextGloryTb and SizeOfTable(nextGloryTb) >0 and nextGloryTb.versionNeed <= maxLevel then

                nextGloryTb.resource ="+"..tostring(nextGloryTb.productAdd*100).."%"
            else
                nextGloryTb =nil
                nextStr =getlocal("topLevelStr")
                if curGloryTb.curBoomMax > gloryTb[i].needGloryExp then
                    curGloryTb.curBoomMax = gloryTb[i].needGloryExp
                end
                if curGloryTb.curBoom > gloryTb[i].needGloryExp then
                    curGloryTb.curBoom = gloryTb[i].needGloryExp
                end
            end
        end
    end

    return curGloryTb,nextGloryTb,nextStr
end
function gloryVoApi:ShowStrWithGlory(curGloryTb)

    local curLevel = curGloryTb.level
    local maxLevel = 0
    local gloryTb = gloryCfg.glory
    for i=1,SizeOfTable(gloryTb) do
        if gloryTb[i].needGloryExp<=curGloryTb.curBoomMax then
            maxLevel =gloryTb[i].level
        end
    end
    if curGloryTb.isGloryOver ==true then
        return 3
    elseif  curLevel < maxLevel then
        return 2
    else
        return 1
    end
end

function gloryVoApi:getRenewGloryGold( )--缺恢复所需的金币数
    local gold = nil
    if gold ==nil then
        gold =999
    end
    return gold
end

function gloryVoApi:refreshAllGlory(curBoom,curBoomMax,boom_ts,boomBmd)
    gloryVo.curBoom =curBoom
    gloryVo.baseCurBoom =curBoom
    gloryVo.curBoomMax =curBoomMax
    gloryVo.boom_ts = boom_ts
    gloryVo.isGloryOver =boomBmd
end

function gloryVoApi:getIsFire(bmd)

    if bmd ==nil or bmd ==0 then
        return false
    else
        return true
    end
end

function gloryVoApi:setIsGlory( isGloryOver )
    if isGloryOver then
        gloryVo.isGloryOver =isGloryOver
    end
end
function gloryVoApi:isGloryOver()
    local isGloryOver = gloryVo.isGloryOver
    if isGloryOver ==1 then
        return true
    end
    return false
end

function gloryVoApi:getPlayerCurGloryWithTroop( )--玩家当前繁荣度 的增兵量
    local curGloryTb = self:getPlayerGlory()

    return curGloryTb.troopsUp
end

function gloryVoApi:getPlayerCurGloryWithLevel( )--玩家当前繁荣度 的等级
    local curGloryTb = self:getPlayerGlory()

    return curGloryTb.level,curGloryTb.curBoom,curGloryTb.curBoomMax
end

function gloryVoApi:isUpOrDownAboutLevel(newBoom)
    -- print("in isUpOrDownAboutLevel-------newBooom---->",newBoom)
    local curGloryTb,nextGloryTb = self:getPlayerGlory()
    local curLevel = curGloryTb.level
    local gloryTb = gloryCfg.glory
    local tbSize = SizeOfTable(gloryTb)
    local newLevel = 1
    local maxLevel = playerVoApi:getMaxLvByKey("roleMaxLevel")
    for i=1,tbSize do
        if newBoom >=gloryTb[i].needGloryExp and maxLevel >=gloryTb[i].versionNeed then
            newLevel = gloryTb[i].level
        end
    end
    -- print("newLevel,curLevel",newLevel,curLevel)
    if newLevel ~= curLevel then
        return true
    else
        return false
    end
end

function gloryVoApi:getDestroyNeedGold( )
    local curGloryTb = self:getPlayerGlory()
    if self:isGloryOver() ==false then
        return (curGloryTb.curBoomMax-curGloryTb.curBoom)*0.01
    else
        return (curGloryTb.curBoomMax-curGloryTb.curBoom)*0.01+((curGloryTb.curBoomMax-curGloryTb.curBoom)*0.01*gloryCfg.destoryGlory.gemFix)
    end

end

function gloryVoApi:setCurBoomInRenew(getBoom)--math.floor(((base.serverTime - zeroTime)%3600)/60)
    if gloryVo and gloryVo.curBoom then
        gloryVo.curBoom =gloryVo.baseCurBoom+getBoom*math.floor(((base.serverTime - gloryVo.boom_ts)%3600)/60)
    end
end
function gloryVoApi:getPermin( )
    return gloryCfg.timeGetBoom
end
function gloryVoApi:getPerminGlory( )--每秒刷新使用
    local renewGloryByMin = gloryCfg.timeGetBoom
    local curGloryTb = self:getPlayerGlory()
    if curGloryTb.curBoom >=curGloryTb.curBoomMax then
        return false
    end
    --local curMin=math.floor(((base.serverTime - zeroTime)%3600)/60)
    if math.floor(base.serverTime %60) ~=0 then
        return false
    end

    self:setCurBoomInRenew(renewGloryByMin)
    curGloryTb = self:getPlayerGlory()
    if curGloryTb.curBoom > curGloryTb.curBoomMax then
        curGloryTb.curBoom = curGloryTb.curBoomMax
    end

    return true,curGloryTb.curBoom,curGloryTb

end

function gloryVoApi:getGloryNums(resource)
    if resource then
        return math.ceil((resource/50000)^0.95)
    end
    return 0
end

function gloryVoApi:worldSceneBuildActionChange(boomBmd,tbX,btY)
    gloryVo.isOtherPlayerBmd = boomBmd
    if tbX and btY then
        gloryVo.tbX =tbX
        gloryVo.btY =btY
    end
end
function gloryVoApi:getWorldSceneBuildActionChange()
    return gloryVo.isOtherPlayerBmd,gloryVo.tbX,gloryVo.btY
end
-- 获取当前繁荣度百分比
function gloryVoApi:getBoomPercent()
    local maxLevel = playerVoApi:getMaxLvByKey("roleMaxLevel")
    local maxBoom=1
    for k,v in pairs(gloryCfg.glory) do
        if v.versionNeed==maxLevel then
            maxBoom=v.needGloryExp
        end
    end
    return (gloryVo.curBoom/maxBoom)
end

--计算繁荣度
function gloryVoApi:computePlayerGlory(boom,boomTs,boomMax)
    local boom=(boom or 0)+gloryCfg.timeGetBoom*math.floor(((base.serverTime-(boomTs or base.serverTime))%3600)/60)
    if boom>boomMax then
        boom=boomMax
    end
    return boom
end

