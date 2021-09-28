-- Filename:LoyaltyControler.lua
-- Author: djn
-- Date: 2015-06-25
-- Purpose: 聚义厅控制层
module ("LoyaltyControler", package.seeall)
--require "script/ui/star/loyalty/LoyaltyData"
--require "script/ui/star/loyalty/LoyaltyService"
require "script/libs/LuaCCLabel"
require "script/utils/LevelUpUtil"
require "script/ui/tip/AnimationTip"
local FRIEND_TYPE = 1001
local LOYAL_TYPE = 1002
local ATTR_TYPE = 1003
local ALERTLEVEL = 101
local ALERTHERO = 102
local ALERTTREA = 103
local ALERTGOD = 104
local HEROTYPE = 1
local TREATYPE = 2
local GODTYPE = 3
--飘窗提示
function alertCb( p_tag)
    if(p_tag == ALERTLEVEL)then
        AnimationTip.showTip(GetLocalizeStringBy("djn_196"))
    elseif(p_tag == ALERTHERO)then
        AnimationTip.showTip(GetLocalizeStringBy("djn_197"))
    elseif(p_tag == ALERTTREA)then
        AnimationTip.showTip(GetLocalizeStringBy("djn_224"))
    elseif(p_tag == ALERTGOD)then
        AnimationTip.showTip(GetLocalizeStringBy("djn_225"))
    end

end
--镶嵌一个武将或宝物
--p_DBId 羁绊对应hall表中的id
--p_itemId 武将或宝物或神兵的 item Id
--p_itemType 镶嵌物品的类型 1 武将 0 宝物神兵
--p_activeType 标签的类型 0 缘分堂 1 忠义堂 2 演武堂
--p_callFunc 回调函数
function fillOneItem(p_DBId,p_itemId,p_itemType,p_activeType,p_callFunc)
    -- p_DBId = 1
    -- p_itemId = 10100692
    -- p_itemType = 1
    -- p_activeType = 0
    local args = CCArray:create()   
    args:addObject(CCInteger:create(p_DBId))
    args:addObject(CCInteger:create(p_itemId))
    args:addObject(CCInteger:create(p_itemType))
    args:addObject(CCInteger:create(p_activeType))
    LoyaltyService.fill(args,p_callFunc)
end
--点击一个卡上的加号后的回调
function cardCb( p_tag)
   -- print("cardCb p_tag",p_tag)
    local curType,curPage,curPos = LoyaltyLayer.getCurInfo()
    local needCard = LoyaltyData.getCardInfoByIndex(curType,curPage,curPos,p_tag)
    if(table.isEmpty(needCard) )then 
        return
    end
    local DBId = LoyaltyData.getIdByIndex(curType,curPage,curPos)
    local quality = 0 --消耗物品的个数和卡牌品质有关
    local itemDBInfo = {}
    local colorQuality = 3
    needCard[1] = tonumber(needCard[1])
    if(needCard[1] == HEROTYPE)then
        --武将
        itemDBInfo = HeroUtil.getHeroLocalInfoByHtid(needCard[2])
        if(not table.isEmpty(itemDBInfo))then
            quality = itemDBInfo.heroQuality  
            colorQuality = itemDBInfo.potential
        end
    elseif(needCard[1] == TREATYPE)then
        itemDBInfo = ItemUtil.getItemById(needCard[2])
        if(itemDBInfo)then
            quality = itemDBInfo.base_score 
            colorQuality = itemDBInfo.quality 
        end        
    elseif(needCard[1] == GODTYPE)then
        itemDBInfo = ItemUtil.getItemById(needCard[2])
        if(itemDBInfo)then
            quality = itemDBInfo.godarmrank  
            colorQuality = 6 
        end
    end
    -- print("quality",quality)
    -- print("colorQuality",colorQuality)
    --local costItemNum = LoyaltyData.getCostNumByQualty(curType,DBId,quality)
    local itemCost = LoyaltyData.getItemCostByIndex(curType,curPage,curPos,quality)
    -- print("itemCost")
    -- print_t(itemCost)
    local costItemNum = 0 --需要消耗多少个物品
    if(not table.isEmpty(itemCost))then
       costItemNum = itemCost.costNum
    else
        return
    end
    local goldCostNum = 0
    local itemHaveNum = LoyaltyData.getCostItemNumInBag(curType,curPage,curPos,quality) or 0
     --print("costItemNum ,itemHaveNum,goldCostNum ",costItemNum ,itemHaveNum,goldCostNum )
    if(itemHaveNum <= costItemNum)then
        --物品不够  金币来补充
        goldCostNum = (costItemNum - itemHaveNum) * itemCost.goldNum
        costItemNum = itemHaveNum
    end
   -- print("costItemNum ,itemHaveNum,goldCostNum ",costItemNum ,itemHaveNum,goldCostNum )

    local richInfo = {lineAlignment = 2,elements = {},labelDefaultSize = 28}
        richInfo.elements = {}
        local tmpElement = nil
        tmpElement = { 
                text = GetLocalizeStringBy("key_1088"),
                color = ccc3(0x78, 0x25, 0x00)}
        table.insert(richInfo.elements,tmpElement)
        if(goldCostNum > 0)then
            tmpElement = {
                    ["type"] = "CCSprite",
                    image = "images/common/gold.png"}
            table.insert(richInfo.elements,tmpElement)
            tmpElement = {
                    ["type"] = "CCRenderLabel", 
                    text = goldCostNum ,
                    color = ccc3(0xff,0xf6,0x00)}
            table.insert(richInfo.elements,tmpElement)
        end
        if(goldCostNum > 0 and itemHaveNum > 0)then
            tmpElement = {
                    ["type"] = "CCRenderLabel", 
                    text = "、",
                    color = ccc3(0xff,0xf6,0x00)}
            table.insert(richInfo.elements,tmpElement)
        end
        --消耗的物品的icon
        if(curType == FRIEND_TYPE)then
            imagePath = "images/star/friend/friStone.png"
        elseif(curType == LOYAL_TYPE)then
            imagePath = "images/star/friend/loyStone.png"
        elseif(curType == ATTR_TYPE)then
            imagePath = "images/star/friend/attrStone.png"
        end
        if(itemHaveNum > 0)then          
            tmpElement = {
                    ["type"] = "CCSprite",
                    image = imagePath}
            table.insert(richInfo.elements,tmpElement)
            tmpElement = {
                    ["type"] = "CCRenderLabel", 
                    text = costItemNum ,
                    color = ccc3(0xff,0xf6,0x00)}
            table.insert(richInfo.elements,tmpElement)
        
        end
        tmpElement = {
                text = GetLocalizeStringBy("djn_193"),
                color =  ccc3(0x78, 0x25, 0x00)}
        table.insert(richInfo.elements,tmpElement)
        tmpElement = {
                text = "["..itemDBInfo.name.."]",
                color = HeroPublicLua.getCCColorByStarLevel(colorQuality) or ccc3(0xff, 0xff, 0xff)}
        table.insert(richInfo.elements,tmpElement)
        tmpElement = {
                text = "?",
                color =   ccc3(0x78, 0x25, 0x00)}
        table.insert(richInfo.elements,tmpElement)
        tmpElement = {
                newLine = true,
                text = GetLocalizeStringBy("djn_235"),
                color =  ccc3(0x78, 0x25, 0x00)}
        table.insert(richInfo.elements,tmpElement)
        tmpElement = {
                newLine = true,
                text = GetLocalizeStringBy("key_1854")..":",
                color =  ccc3(0x00, 0x6d, 0x2f)}
        table.insert(richInfo.elements,tmpElement)
        tmpElement = {
                ["type"] = "CCSprite",
                image = imagePath}
        table.insert(richInfo.elements,tmpElement)
        tmpElement = {
                text = itemHaveNum,
                color =  ccc3(0x00, 0x6d, 0x2f)}
        table.insert(richInfo.elements,tmpElement)
        tmpElement = {
                newLine = true,
                ["type"] = "CCSprite",
                image = imagePath}
        table.insert(richInfo.elements,tmpElement)
        tmpElement = {
                
                text = "1",
                color =  ccc3(0x00, 0x6d, 0x2f)}
        table.insert(richInfo.elements,tmpElement)
        
        tmpElement = {
                text = "=",
                color =  ccc3(0x00, 0x6d, 0x2f)}
        table.insert(richInfo.elements,tmpElement)
        tmpElement = {
                    ["type"] = "CCSprite",
                    image = "images/common/gold.png"}
        table.insert(richInfo.elements,tmpElement)
         tmpElement = {
                text = itemCost.goldNum,
                color =  ccc3(0x00, 0x6d, 0x2f)}
        table.insert(richInfo.elements,tmpElement)
    

        local confirmCostCb = function (p_status)
            if(p_status)then
                confirmCb( p_tag,itemCost.itemId,costItemNum,goldCostNum)
            end
        end
        require "script/ui/tip/RichAlertTip"
        RichAlertTip.showAlert(richInfo, confirmCostCb, true) 
    -- body
end

--确认镶嵌的回调
function confirmCb( p_tag,p_itemId,p_itemNum,p_goldNum)
    --确认金币够不够 不够就去充值
    local curgold = UserModel.getGoldNumber()
    local needGold = tonumber(p_goldNum)
    local p_itemNum = tonumber(p_itemNum)
    if(needGold > 0)then
        if(tonumber(curgold) < needGold)then
            require "script/ui/tip/LackGoldTip"
            LackGoldTip.showTip()
            return              
        end
    end
    local curType,curPage,curPos = LoyaltyLayer.getCurInfo()

    local DBId = LoyaltyData.getIdByIndex(curType,curPage,curPos)
    local heroNeed = LoyaltyData.getCardInfoByIndex( curType,curPage,curPos,p_tag)
    local fitTab = LoyaltyData.getFitHeroByTid(heroNeed[1],heroNeed[2])
    if(table.isEmpty(fitTab))then
        --咋就突然没有合适的英雄了呢~ 没有合适的我当初怎么会创建btn  whatever 现在没有就打住
        return
    end
    local itemType = 1
    heroNeed[1] = tonumber(heroNeed[1])
    local sendItemId = 0
    if( heroNeed[1]== HEROTYPE)then
        --武将
        itemType = 1
        sendItemId = fitTab[1].hid
    elseif(heroNeed[1] == TREATYPE or heroNeed[1] == GODTYPE)then
        --宝物或者神兵
        itemType = 0
        sendItemId = fitTab[1].item_id
    end
    local activeType = 0
    if(curType == FRIEND_TYPE)then
        activeType = 0
    elseif(curType  == LOYAL_TYPE)then
        activeType = 1
    elseif(curType  == ATTR_TYPE)then
        activeType = 2
    end
    local necessary = HeroModel.getNecessaryHero()
    local hid = nil
    if(necessary)then
        hid = necessary.hid
    end
    local lastFightForce = FightForceModel.dealParticularValues(hid)
    local netCb = function ( ... )
        --发送完镶嵌请求后的回调
        --扣金币
        UserModel.addGoldNumber(-needGold)
        --扣消耗物品
        LoyaltyData.addItemInCache(p_itemId,-p_itemNum)  
        
        if(heroNeed[1]== HEROTYPE )then
            --扣武将
            HeroModel.deleteHeroByHid(fitTab[1].hid)
        end   
        -- elseif(heroNeed[1]== 2)then
        --     --扣宝物
        -- elseif(heroNeed[1]== 3)then
        --     --扣神兵
        --     --LoyaltyData.removeOneFitByType(3)
        -- end
        --扣除缓存中一个的对应适合镶嵌的材料
        LoyaltyData.removeOneFitByType(heroNeed[1],sendItemId)
        --刷新data缓存
        LoyaltyData.changeCacheByIndex(curType,curPage,curPos,heroNeed[2],heroNeed[1])
        --刷新UI
        LoyaltyLayer.refreshUI()
        -- body
        local curFight = FightForceModel.dealParticularValues(hid)

        --飘窗“所有上阵武将”
        local midSp = CCRenderLabel:create( GetLocalizeStringBy("djn_195"), g_sFontPangWa, 45, 1, ccc3(0x00,0x00,0x00), type_stroke)
        midSp:setColor(ccc3(0x76,0xfc,0x06))
        LevelUpUtil.showFlyNode(midSp,0.6)

        ItemUtil.showAttrChangeInfo(lastFightForce,curFight)
        -- performWithDelay(midSp,function()
        --     ItemUtil.showAttrChangeInfo(lastFightForce,curFight)
        --     end,0.8)
           
    end
    LoyaltyControler.fillOneItem(DBId,sendItemId,itemType,activeType,netCb)
end
--飘窗
function flyStr(p_Str)

    local richInfo = {elements = {},alignment = 2,defaultType = "CCRenderLabel",}

        richInfo.elements[1] = {
                text = GetLocalizeStringBy("zzh_1323"),
                font = g_sFontPangWa,
                size = 35,
                color = ccc3(0x00,0xff,0x18)}
        richInfo.elements[2] = { 
                text = "["..p_Str.."]",
                font = g_sFontPangWa,
                size = 35,
                color = ccc3(0xff,0xf6,0x00)}
    local midSp = LuaCCLabel.createRichLabel(richInfo)
    LevelUpUtil.showFlyNode(midSp,0.8)
end
--[[
    @des    :给sprite加效果
    @param  :sprite
--]]
function addActionToSprite(p_sprite)
    --动画
    local actionArray = CCArray:create()
    actionArray:addObject(CCFadeOut:create(1))
    actionArray:addObject(CCFadeIn:create(1))
    local sequence = CCSequence:create(actionArray)
    local action = CCRepeatForever:create(sequence)

    p_sprite:runAction(action)

end