-- Filename: AstrologyRewardLayer.lua
-- Author: k
-- Date: 2013-08-06
-- Purpose: 占星奖励

 --     __            __
 --  __|  |__________|  |__
 -- |                      |
 -- |          __          |
 -- |    ___        ___    |
 -- |     |          |     |
 -- |          ~~          |
 -- |                      |
 -- |_____            _____|
 --       |          |
 --       |          |
 --       |          |  神兽保佑
 --       |          |  永无BUG
 --       |          |
 --       |          |___________
 --       |                      |__
 --       |                       __|
 --       |__       _____       __|
 --          |  |  |     |  |  |
 --          |__|__|     |__|__|

require "script/utils/extern"
require "script/utils/LuaUtil"
--require "amf3"
-- 主城场景模块声明
module("AstrologyRewardLayer", package.seeall)

require "script/network/RequestCenter"
require "script/network/Network"
require "script/ui/tip/AlertTip"

local IMG_PATH = "images/astrology/reward/"				-- 图片主路径

local m_astrologyRewardLayer
local m_dbAstrology
local m_astroBg
local m_currentStar
local m_prize_step
local nextAstroLabel
local upgradeButton
local m_layerSize
local m_reportBg
local m_randReward
local refreshButton

local haveUpgrade

local refreshRewards

local _updateTimeScheduler 
local haveRefreshNum

local needGold

local astroNum

local afterString

local remainTimes

local function cardLayerTouch(eventType, x, y)
    
    return true
    
end

--获得领取奖励按键
function getDrawPrizeButton()
    if(m_reportBg~=nil and m_reportBg:getChildByTag(9109) ~= nil and m_reportBg:getChildByTag(9109):getChildByTag(8109) ~= nil)then
        return m_reportBg:getChildByTag(9109):getChildByTag(8109)
    else
        return nil
    end
end

function closeClick()
    
    if haveUpgrade == 1 then
        require "script/ui/astrology/AstrologyLayer"
        AstrologyLayer.refreshAstrologyInfo()
    end

    --点击音效
    require "script/audio/AudioUtil"
    AudioUtil.playEffect("audio/effect/guanbi.mp3")
    require "script/ui/main/MainScene"
    MainScene.setMainSceneViewsVisible(true,false,true)
    local scene = CCDirector:sharedDirector():getRunningScene()
    scene:removeChildByTag(1231,true)
    --print("==========closeClick===============")

    --清除定时器
    if(_updateTimeScheduler)then
        CCDirector:sharedDirector():getScheduler():unscheduleScriptEntry(_updateTimeScheduler)
        _updateTimeScheduler = nil
    end
end

function upRefresh(cbFlag, dictData, bRet)
    if(dictData.err=="ok" and dictData.ret~=nil)then
        local m_astrologyInfo = dictData.ret
        table.hcopy(dictData.ret, m_astrologyInfo)
        m_prize_level = tonumber(m_astrologyInfo.prize_level)
        m_currentStar = m_astrologyInfo.integral
        m_prize_step = tonumber(m_astrologyInfo.prize_step)
        m_randReward = m_astrologyInfo.va_divine.newreward

        print(GetLocalizeStringBy("key_1983"),m_prize_step)

        require "script/ui/astrology/AstrologyLayer"
        --AstrologyLayer.refreshAstrologyInfo()
        --m_prize_level = m_prize_level+1
        require "db/DB_Astrology"
        m_dbAstrology = DB_Astrology.getDataById(tonumber(m_prize_level))
        nextAstrology = DB_Astrology.getDataById(tonumber(m_prize_level)+1)

        --prize_step
        refreshRewards(m_prize_step+1)
        
        if(nextAstroLabel~=nil)then
            nextAstroLabel:removeFromParentAndCleanup(true)
            nextAstroLabel = nil
        end
        
        if remainTimes ~= nil then
            remainTimes:removeFromParentAndCleanup(true)
            remainTimes = nil
        end

        if middleLabel ~= nil then
            middleLabel:removeFromParentAndCleanup(true)
            middleLabel = nil
        end

        if middleTimes ~= nil then
            middleTimes:removeFromParentAndCleanup(true)
            middleTimes = nil
        end

        if(nextAstrology==nil)then
            upgradeButton:setVisible(false)
            --drawPrizeButton:setPosition(m_layerSize.width*0.5,m_layerSize.height*0.11)
            refreshButton:setVisible(true)

            drawPrizeButton:setPosition(m_layerSize.width*0.75,m_layerSize.height*0.11)

            currentStarLabel:setPosition(m_layerSize.width*0.75 - currentStarLabel:getContentSize().width/2,m_layerSize.height*0.07)

            refreshButton:setPosition(m_layerSize.width*0.25,m_layerSize.height*0.11)
            refreshButton:setEnabled(true)
            
            nextAstroLabel = CCRenderLabel:create(GetLocalizeStringBy("key_2719"), g_sFontName, 18, 2, ccc3( 0x00, 0x00, 0x00), type_stroke)
            nextAstroLabel:setColor(ccc3(0x36,0xff,0x00))
            nextAstroLabel:setPosition(m_layerSize.width*0.25 - nextAstroLabel:getContentSize().width/2,m_layerSize.height*0.075)
            m_reportBg:addChild(nextAstroLabel)

            remainTimes = CCRenderLabel:create(GetLocalizeStringBy("key_2697") .. tostring(afterString[1]-haveRefreshNum), g_sFontName, 18, 2, ccc3( 0x00, 0x00, 0x00), type_stroke)
            remainTimes:setColor(ccc3(0x36,0xff,0x00))
            remainTimes:setPosition(m_layerSize.width*0.25 - remainTimes:getContentSize().width/2 ,m_layerSize.height*0.045)
            m_reportBg:addChild(remainTimes)
            
            upgradeButton:setEnabled(false)
        else
            
            if tonumber(m_prize_level) >= 2 then
                refreshButton:setVisible(true)
                upgradeButton:setVisible(true)

                refreshButton:setPosition(m_layerSize.width*0.5,m_layerSize.height*0.11)

                middleLabel = CCRenderLabel:create(GetLocalizeStringBy("key_2719"), g_sFontName, 18, 2, ccc3( 0x00, 0x00, 0x00), type_stroke)
                --nextAstroLabel:setAnchorPoint(ccp(0.5,1))
                middleLabel:setColor(ccc3(0x36,0xff,0x00))
                middleLabel:setPosition(m_layerSize.width*0.5 - middleLabel:getContentSize().width/2 ,m_layerSize.height*0.075)
                m_reportBg:addChild(middleLabel)

                middleTimes = CCRenderLabel:create(GetLocalizeStringBy("key_2697") .. tostring(afterString[1]-haveRefreshNum), g_sFontName, 18, 2, ccc3( 0x00, 0x00, 0x00), type_stroke)
                middleTimes:setColor(ccc3(0x36,0xff,0x00))
                middleTimes:setPosition(m_layerSize.width*0.5 - middleTimes:getContentSize().width/2 ,m_layerSize.height*0.045)
                m_reportBg:addChild(middleTimes)
            end

            drawPrizeButton:setPosition(m_layerSize.width*0.8,m_layerSize.height*0.11)

            upgradeButton:setPosition(m_layerSize.width*0.2,m_layerSize.height*0.11)

            currentStarLabel:setPosition(m_layerSize.width*0.8 - currentStarLabel:getContentSize().width/2,m_layerSize.height*0.07)

            nextAstroLabel = CCRenderLabel:create(GetLocalizeStringBy("key_1636") .. nextAstrology.limited_lv .. GetLocalizeStringBy("key_2701"), g_sFontName, 18, 2, ccc3( 0x00, 0x00, 0x00), type_stroke)
            nextAstroLabel:setColor(ccc3(0x36,0xff,0x00))
            nextAstroLabel:setPosition(m_layerSize.width*0.2 - nextAstroLabel:getContentSize().width/2,m_layerSize.height*0.07)
            m_reportBg:addChild(nextAstroLabel)
            
            require "script/model/user/UserModel"
            local userInfo = UserModel.getUserInfo()
            if userInfo ~= nil then
                
                if(tonumber(userInfo.level)<tonumber(nextAstrology.limited_lv))then
                    
                    upgradeButton:setEnabled(false)
                end
            end
        end

        haveUpgrade = 1          
    end
end

function sureUpgrade(sureUp)
    print("sureUp",sureUp)
    if sureUp == true then
                      -- 音效
        require "script/audio/AudioUtil"
        AudioUtil.playEffect("audio/effect/zhujiemian.mp3")
        function upgradeCallback(cbFlag, dictData, bRet)
            if(dictData.err=="ok")then
                require "script/network/RequestCenter"
                RequestCenter.divine_getDiviInfo(upRefresh,CCArray:create())
            end
        end
        --print("==========upgradeClick===============")
        RequestCenter.divine_upgrade(upgradeCallback,CCArray:create())
    end
end

function upgradeClick()
    require "script/audio/AudioUtil"
    AudioUtil.playEffect("audio/effect/zhujiemian.mp3")
    local currentMaxPrize = 0
    local starArray =  lua_string_split(m_dbAstrology.star_arr,",")
    for i=1,#starArray do
        print("upgrade:",starArray[i],m_currentStar)
        if(tonumber(starArray[i])<=tonumber(m_currentStar))then
            currentMaxPrize = i
        end
    end
    
    if((m_prize_step) >= currentMaxPrize)then
        --local tipText = GetLocalizeStringBy("key_1313") 
        local tipText = nextAstrology.upTips
        AlertTip.showAlert(tipText, sureUpgrade, true, nil, GetLocalizeStringBy("key_1985"),GetLocalizeStringBy("key_1202"))  
    else
        require "script/ui/tip/AlertTip"
        AlertTip.showAlert( GetLocalizeStringBy("key_2134"), nil, false, nil)
    end  
end

function refreshClick()
    require "script/ui/tip/AnimationTip"
    local function refreshBack(cbFlag, dictData, bRet)
        -- if not bRet then
        --     return
        -- end
        if dictData.err=="ok" and dictData.ret~=nil then
            print(GetLocalizeStringBy("key_2909"))
            print_t(dictData.ret)
            m_randReward = dictData.ret
            refreshRewards()
            haveRefreshNum = haveRefreshNum+1
            require "db/DB_Vip"
            require "script/model/user/UserModel"
            UserModel.addGoldNumber(tonumber(-needGold))
            local vipLevel = UserModel.getVipLevel()
            local dbVip = DB_Vip.getDataById(vipLevel+1)
            local vipString = dbVip.astrologyCost
            afterString = lua_string_split(vipString,"|")
            needGold = tonumber(afterString[2])+(tonumber(haveRefreshNum))*tonumber(afterString[3])
            goldNum:setString(tostring(needGold))
            require "script/ui/astrology/AstrologyLayer"
            AstrologyLayer.refreshGoldNum()
            if remainTimes ~= nil then
                remainTimes:setString(GetLocalizeStringBy("key_2697") .. tostring(afterString[1]-haveRefreshNum))
            end

            if middleTimes ~= nil then
                middleTimes:setString(GetLocalizeStringBy("key_2697") .. tostring(afterString[1]-haveRefreshNum))
            end
        else
            require "script/ui/tip/AlertTip"
            AlertTip.showAlert( GetLocalizeStringBy("key_1634"), nil, false, nil)
        end
    end

    require "db/DB_Vip"
    require "script/model/user/UserModel"
    local vipLevel = UserModel.getVipLevel()
    local dbVip = DB_Vip.getDataById(vipLevel+1)
    local vipString = dbVip.astrologyCost
    afterString = lua_string_split(vipString,"|")

    local starList = m_dbAstrology.star_arr
    local starString = lua_string_split(starList,",")

    needGold = tonumber(afterString[2])+(tonumber(haveRefreshNum))*tonumber(afterString[3])
    local userInfo = UserModel.getUserInfo()

    if (tonumber(haveRefreshNum) < tonumber(afterString[1])) then
        if tonumber(m_prize_step) < 9 then
            if tonumber(userInfo.gold_num) >= tonumber(needGold) then
                require "script/network/Network"
                local arg = nil
                Network.rpc(refreshBack, "divine.refPrize","divine.refPrize", arg, true)
            else
                require "script/ui/tip/LackGoldTip"
                LackGoldTip.showTip()
            end
        elseif tonumber(m_prize_step) >= 10 then
            AnimationTip.showTip(GetLocalizeStringBy("key_2976"))
        else
            AnimationTip.showTip(GetLocalizeStringBy("key_2292"))
        end
    else
        AnimationTip.showTip(GetLocalizeStringBy("key_2096"))
    end

    -- require "script/network/Network"
    -- local arg = nil
    -- Network.rpc(refreshBack, "divine.refPrize","divine.refPrize", arg, true)
end

-- function drawPrizeClick()
--     -- 音效
--     require "script/audio/AudioUtil"
--     AudioUtil.playEffect("audio/effect/zhujiemian.mp3")
--     ---[==[占星 新手引导屏蔽层
--     ---------------------新手引导---------------------------------
--     --add by licong 2013.09.29
--     require "script/guide/NewGuide"
--     if(NewGuide.guideClass == ksGuideAstrology) then
--         require "script/guide/AstrologyGuide"
--         AstrologyGuide.changLayer()
--     end
--     ---------------------end-------------------------------------
--     --]==]
    
--     local rewardInfo = nil

--     if (tonumber(m_dbAstrology.id) > 1) and (m_prize_step+1 <= 10) then
--         local randTable = m_dbAstrology["randReward" .. tostring(m_prize_step+1)]
--         print("1")
--         print_t(randTable)
--         local rewardArray = lua_string_split(randTable,",")
--         print("2")
--         print_t(rewardArray)
--         local initReward = rewardArray[tonumber(m_randReward[m_prize_step+1])+1]
--         print("2.1")
--         print(m_randReward[tonumber(m_prize_step+1)+1])
--         print("2,2")
--         print(m_prize_step)
--         print("2.3")
--         print_t(m_randReward)
--         print("3")
--         print_t(initReward)
--         rewardInfo = initReward
--     end
--     if tonumber(m_dbAstrology.id) <= 1 then
--         local rewardArray =  lua_string_split(m_dbAstrology.reward_arr,",")
--         rewardInfo = rewardArray[m_prize_step+1]
--     end
    
--     if(rewardInfo==nil)then
        
--         require "script/ui/tip/AlertTip"
--         AlertTip.showAlert( GetLocalizeStringBy("key_1070"), nil, false, nil)
--         return
--     end
    
--     if("3"==lua_string_split(rewardInfo,"|")[1])then
--         local itemId = tonumber(lua_string_split(rewardInfo,"|")[2])
        
--         require "script/ui/item/ItemUtil"
--         -- if(itemId>1000000 and itemId>5000000)then
--         --     --装备碎片
--         --     if(ItemUtil.isArmFragBagFull()==true)then
--         --         --closeClick()
--         --         require "script/ui/tip/AlertTip"
--         --         AlertTip.showAlert( GetLocalizeStringBy("key_1440"), nil, false, nil)
--         --         return
--         --     end
--         -- else
--         --     --装备
--         --     if(ItemUtil.isEquipBagFull()==true)then
--         --         --closeClick()
--         --         require "script/ui/tip/AlertTip"
--         --         AlertTip.showAlert( GetLocalizeStringBy("key_1440"), nil, false, nil)
--         --         return
--         --     end
--         -- end
--         if ItemUtil.isBagFull() == true then
--             require "script/ui/tip/AlertTip"
--             closeClick()
--             --AlertTip.showAlert( GetLocalizeStringBy("key_1440"), nil, false, nil)
--             return
--         end
--     end
    
--     function upgradeCallback(cbFlag, dictData, bRet)
--         print("dictDatall")
--         print_t(dictData)
--         if(dictData.err=="ok" and dictData.ret~=nil)then
--             require "script/ui/astrology/AstrologyLayer"
--             AstrologyLayer.refreshAstrologyInfo()
            
--             local rewardInfo
--             if tonumber(m_dbAstrology.id) > 1 then
--                 local randTable = m_dbAstrology["randReward" .. tostring(m_prize_step+1)]
--                 local rewardArray = lua_string_split(randTable,",")
--                 local initReward = rewardArray[tonumber(m_randReward[m_prize_step+1])+1]
--                 rewardInfo = initReward
--             elseif tonumber(m_dbAstrology.id) <= 1 then
--                 local rewardArray =  lua_string_split(m_dbAstrology.reward_arr,",")
--                 rewardInfo = rewardArray[m_prize_step+1]
--             end
            
--             require "script/model/user/UserModel"
            
--             --判断奖励类型 lua_string_split(rewardInfo,"|")[2]
--             if("0"==lua_string_split(rewardInfo,"|")[1])then
--                 --银币
--                 print("drawPrizeClick 0",lua_string_split(rewardInfo,"|")[2])
--                 UserModel.addSilverNumber(tonumber(lua_string_split(rewardInfo,"|")[2]))
--             elseif("1"==lua_string_split(rewardInfo,"|")[1])then
--                 --金币
--                 print("drawPrizeClick 1",lua_string_split(rewardInfo,"|")[2])
--                 UserModel.addGoldNumber(tonumber(lua_string_split(rewardInfo,"|")[2]))
--             elseif("2"==lua_string_split(rewardInfo,"|")[1])then
--                 --将魂
--                 print("drawPrizeClick 2",lua_string_split(rewardInfo,"|")[2])
--                 UserModel.addSoulNum(tonumber(lua_string_split(rewardInfo,"|")[2]))
--             end
            
--             m_prize_step = m_prize_step+1
--             refreshRewards()
            
--         else
--             require "script/ui/tip/AlertTip"
--             AlertTip.showAlert( GetLocalizeStringBy("key_2591"), nil, false, nil)
--         end
--     end
    
--     --print("==========drawPrizeClick===============",m_prize_step)
--     RequestCenter.divine_drawPrize(upgradeCallback,Network.argsHandler(m_prize_step))
    
-- end

function getRewardPosition(pos)
    if(pos==1)then
        return ccp(485,145)
    elseif(pos==2)then
        return ccp(309,85)
    elseif(pos==3)then
        return ccp(148,145)
    elseif(pos==4)then
        return ccp(72,295)
    elseif(pos==5)then
        return ccp(212,418)
    elseif(pos==6)then
        return ccp(368,299)
    elseif(pos==7)then
        return ccp(510,381)
    elseif(pos==8)then
        return ccp(433,561)
    elseif(pos==9)then
        return ccp(126,603)
    elseif(pos==10)then
        return ccp(256,689)
    end
    
    return ccp(0,0)
end

function createRewardIcon(pos,init_reward)
    local rewardInfo
    if tonumber(m_dbAstrology.id) > 1 then
        rewardInfo = init_reward
    elseif tonumber(m_dbAstrology.id) <= 1 then
        local rewardArray =  lua_string_split(m_dbAstrology.reward_arr,",")
        rewardInfo = rewardArray[pos]
    end
    local starArray =  lua_string_split(m_dbAstrology.star_arr,",")
    local resultIcon = nil
    local rewardName = nil
    
    print(GetLocalizeStringBy("key_2783"))
    print_t(init_reward)

    --判断奖励类型
    if("0"==lua_string_split(rewardInfo,"|")[1])then
        resultIcon = CCSprite:create("images/item/bg/itembg_1.png")
        local moneyIcon = CCSprite:create("images/base/props/yinbi_xiao.png")
        moneyIcon:setAnchorPoint(ccp(0.5,0.5))
        moneyIcon:setPosition(resultIcon:getContentSize().width*0.5,resultIcon:getContentSize().height*0.5)
        resultIcon:addChild(moneyIcon)
        
        rewardName = GetLocalizeStringBy("key_1687") .. lua_string_split(rewardInfo,"|")[2]
    elseif("1"==lua_string_split(rewardInfo,"|")[1])then
        
        resultIcon = CCSprite:create("images/item/bg/itembg_4.png")
        local moneyIcon = CCSprite:create("images/base/props/jinbi_xiao.png")
        moneyIcon:setAnchorPoint(ccp(0.5,0.5))
        moneyIcon:setPosition(resultIcon:getContentSize().width*0.5,resultIcon:getContentSize().height*0.5)
        resultIcon:addChild(moneyIcon)
        
        rewardName = GetLocalizeStringBy("key_1491") .. lua_string_split(rewardInfo,"|")[2]
    elseif("2"==lua_string_split(rewardInfo,"|")[1])then
        
        resultIcon = CCSprite:create("images/item/bg/itembg_2.png")
        local moneyIcon = CCSprite:create("images/base/props/jianghun.png")
        moneyIcon:setAnchorPoint(ccp(0.5,0.5))
        moneyIcon:setPosition(resultIcon:getContentSize().width*0.5,resultIcon:getContentSize().height*0.5)
        resultIcon:addChild(moneyIcon)
        
        rewardName = GetLocalizeStringBy("key_1616") .. lua_string_split(rewardInfo,"|")[2]
    elseif("3"==lua_string_split(rewardInfo,"|")[1])then
        require "script/ui/item/ItemSprite"
        resultIcon = ItemSprite.getItemSpriteById(tonumber(lua_string_split(rewardInfo,"|")[2]))
        
        local touchLayer = CCLayer:create()
        touchLayer:setAnchorPoint(ccp(0,0))
        touchLayer:setPosition(ccp(0,0))
        resultIcon:addChild(touchLayer)
        resultIcon:setTag(tonumber(lua_string_split(rewardInfo,"|")[2]))
        
        local function iconTouch(eventType, x, y)
        --print("-------iconTouch--------")
        if (eventType == "began") then
            local nodePoint = resultIcon:convertToNodeSpace(ccp(x,y))
            if(nodePoint.x>=0 and nodePoint.x<=resultIcon:getContentSize().width and nodePoint.y>=0 and nodePoint.y<=resultIcon:getContentSize().height)then
                --require "script/ui/item/ItemInfoLayer"
                --local infoLayer = ItemInfoLayer.createItemInfoLayer(nil, resultIcon:getTag())
                
                require "script/ui/item/ItemUtil"
                if(ItemUtil.getItemTypeByTId(resultIcon:getTag())==1)then
                    
                    require "script/ui/item/EquipInfoLayer"
                    local infoLayer = EquipInfoLayer.createLayer(resultIcon:getTag(), nil, nil, nil, nil, nil, nil, nil, -510)
                    local runningScene = CCDirector:sharedDirector():getRunningScene()
                    runningScene:addChild(infoLayer, 999)
                else
                    require "script/ui/item/ItemInfoLayer"
                    local infoLayer = ItemInfoLayer.createItemInfoLayer(nil, resultIcon:getTag())
                    local runningScene = CCDirector:sharedDirector():getRunningScene()
                    runningScene:addChild(infoLayer, 999)
                end
                return true
                end
            end
        end
    
        touchLayer:setTouchEnabled(true)
        touchLayer:registerScriptTouchHandler(iconTouch,false,-502,true)
        
        require "script/ui/item/ItemUtil"
        local item = ItemUtil.getItemById(tonumber(lua_string_split(rewardInfo,"|")[2]))
        rewardName = item.name
    end
    
    if(resultIcon~=nil)then
        resultIcon:setAnchorPoint(ccp(0.5,0.5))
        
        local nameLabel = CCRenderLabel:create(rewardName, g_sFontName, 18, 1.5, ccc3( 0, 0, 0), type_stroke)
        nameLabel:setColor(ccc3(0xff,0xff,0xff))
        nameLabel:setPosition(resultIcon:getContentSize().width*0.5 - nameLabel:getContentSize().width/2,resultIcon:getContentSize().height*0.0)
        resultIcon:addChild(nameLabel)
        
        local levelLabel = CCRenderLabel:create(starArray[pos] .. GetLocalizeStringBy("key_1119"), g_sFontPangWa, 18, 1, ccc3( 0x00, 0x08, 0x09), type_stroke)
        local levelColor = tonumber(starArray[pos])>tonumber(m_currentStar) and ccc3(0xac,0xac,0xac) or ccc3(0xff,0xde,0x00)
        levelLabel:setColor(levelColor)
        levelLabel:setAnchorPoint(ccp(0,0.5))
        levelLabel:setPosition(resultIcon:getContentSize().width,resultIcon:getContentSize().height*0.5)
        resultIcon:addChild(levelLabel)

        local itemNum
        if init_reward ~= nil then
            itemNum = CCRenderLabel:create(tostring(lua_string_split(rewardInfo,"|")[3]), g_sFontName, 18, 1.5, ccc3( 0, 0, 0), type_stroke)
        else
            itemNum = CCRenderLabel:create("1", g_sFontName, 18, 1.5, ccc3( 0, 0, 0), type_stroke)
        end
        
        itemNum:setColor(ccc3(0x00,0xeb,0x21))
        itemNum:setAnchorPoint(ccp(1,0))
        itemNum:setPosition(ccp(resultIcon:getContentSize().width - 5,5))
        resultIcon:addChild(itemNum)
        --print("cccccccccccccc:",pos,m_prize_step)
        if(pos<m_prize_step+1)then
            local takenSprite = CCSprite:create(IMG_PATH .. "taken.png")
            takenSprite:setAnchorPoint(ccp(0.5,0.5))
            takenSprite:setPosition(resultIcon:getContentSize().width*0.5,resultIcon:getContentSize().height*0.5)
            resultIcon:addChild(takenSprite)
        end
        
        if(pos>=m_prize_step+1 and tonumber(starArray[pos])<=tonumber(m_currentStar))then
            local m_barEffect = CCLayerSprite:layerSpriteWithName(CCString:create("images/base/effect/astro/zhanxingckjl"), -1,CCString:create(""));
            m_barEffect:setAnchorPoint(ccp(0.5, 0.5));
            m_barEffect:setPosition(resultIcon:getContentSize().width*0.5,resultIcon:getContentSize().height*0.5);
            resultIcon:addChild(m_barEffect,1);
        end
    end
    
    return resultIcon
end

refreshRewards = function (refreshLevel)
    local iInit = refreshLevel or 1

    if(m_dbAstrology==nil or m_astroBg == nil)then
        --print("refreshRewards:",m_dbAstrology,m_astroBg)
        require "script/ui/tip/AlertTip"
        AlertTip.showAlert( GetLocalizeStringBy("key_2070"), nil, false, nil)
        return
    end

    m_astroBg:removeAllChildrenWithCleanup(true)
    
    --普通
    if tonumber(m_dbAstrology.id) <= 1 then
        local rewardArray =  lua_string_split(m_dbAstrology.reward_arr,",")
        for i=1,#rewardArray do
            local rewardIcon = createRewardIcon(i)
            rewardIcon:setPosition(getRewardPosition(i))
            rewardIcon:setAnchorPoint(ccp(0.5,0.5))
            m_astroBg:addChild(rewardIcon)
        end
    --随机
    elseif tonumber(m_dbAstrology.id) > 1 then
        for i = 1,10 do
            --下标
            local randTable = m_dbAstrology["randReward" .. tostring(i)]
            print("randTable")
            print_t(randTable)
            local rewardArray = lua_string_split(randTable,",")
            print("rewardArray")
            print_t(rewardArray)
            print(GetLocalizeStringBy("key_2939"))
            print_t(m_randReward)
            local initReward = rewardArray[tonumber(m_randReward[i])+1]
            print("猜猜我是谁",m_randReward[i])
            print(GetLocalizeStringBy("key_2212"))
            print_t(m_randReward)
            print("initReward")
            print(initReward)
            local rewardIcon = createRewardIcon(i,initReward)
            rewardIcon:setPosition(getRewardPosition(i))
            rewardIcon:setAnchorPoint(ccp(0.5,0.5))
            m_astroBg:addChild(rewardIcon)
        end
    end
end

function  nightRefresh(cbFlag, dictData, bRet)
    if(dictData.err=="ok" and dictData.ret~=nil)then
        local m_astrologyInfo = dictData.ret
        table.hcopy(dictData.ret, m_astrologyInfo)
        --require "script/ui/astrology/AstrologyRewardLayer"
        --AstrologyRewardLayer.showAstrologyRewardLayer(m_astrologyInfo.prize_level,m_astrologyInfo.integral,m_astrologyInfo.prize_step,m_astrologyInfo.va_divine.newreward)
        m_prize_level = tonumber(m_astrologyInfo.prize_level)
        m_currentStar = m_astrologyInfo.integral
        m_prize_step = tonumber(m_astrologyInfo.prize_step)
        m_randReward = m_astrologyInfo.va_divine.newreward
        refreshRewards()
        currentStarLabel:setString(GetLocalizeStringBy("key_1038") .. m_currentStar)

        haveRefreshNum = m_astrologyInfo.ref_prize_num

        require "db/DB_Vip"
        require "script/model/user/UserModel"
        local vipLevel = UserModel.getVipLevel()
        local dbVip = DB_Vip.getDataById(vipLevel+1)
        local vipString = dbVip.astrologyCost
        afterString = lua_string_split(vipString,"|")
        needGold = tonumber(afterString[2])+(tonumber(haveRefreshNum))*tonumber(afterString[3])
        goldNum:setString(needGold)
    end
end

--定时器
function updateTime()
    if tonumber(m_prize_level) > 1 then
        local curTime = TimeUtil.getSvrTimeByOffset(-5)
        local date = os.date("*t", curTime)
        local nowHour = date.hour
        local nowMin = date.min
        local nowSec = date.sec

        --print("H,M,S",nowHour,nowMin,nowSec)

        --为了防止时间差问题，所以延后10秒刷新
        if tonumber(nowHour) == 0 and nowMin == 0 and nowSec == 0 then
            require "script/network/RequestCenter"
            RequestCenter.divine_getDiviInfo(nightRefresh,CCArray:create())
            require "script/ui/astrology/AstrologyLayer"
            --AstrologyLayer.refreshAstrologyInfo()
        end 
    end
end

--[[
    @des    :将占星的奖励转换成标准奖励格式，方便调用弹出框
    @param  :要转换的奖励字符串
    @return :转换后的table
--]]
function transFormString(p_inputString)
    local splitTable = lua_string_split(p_inputString,"|")

    local itemType = tonumber(splitTable[1])
    local secondNum = tonumber(splitTable[2])
    local itemNum = splitTable[3] or 1

    local tab = {}

    --如果是银币
    if itemType == 0 then
        tab.type = "silver"
        tab.num = secondNum
        tab.tid = 0
        tab.name = GetLocalizeStringBy("key_8042")
    --如果是金币
    elseif itemType == 1 then
        tab.type = "gold"
        tab.num = secondNum
        tab.tid = 0
        tab.name = GetLocalizeStringBy("key_1447")
    --如果是将魂
    elseif itemType == 2 then
        tab.type = "soul"
        tab.num = secondNum
        tab.tid = 0
        tab.name = GetLocalizeStringBy("key_1086")
    --如果是物品
    else
        tab.type = "item"
        tab.num = tonumber(itemNum)
        tab.tid = secondNum
    end

    return tab
end

--[[
    @des    :一键领奖回调
    @param  :
    @return :
--]]
function onceDrawCallBack()
    -- 音效
    require "script/audio/AudioUtil"
    AudioUtil.playEffect("audio/effect/zhujiemian.mp3")

    require "script/ui/item/ItemUtil"
    if ItemUtil.isBagFull() == true then
        require "script/ui/tip/AlertTip"
        closeClick()

        -- 背包满了关闭新手引导
        ---[==[占星 清除新手引导
        ---------------------新手引导---------------------------------
        --add by licong 2013.09.29
        require "script/guide/NewGuide"
        if(NewGuide.guideClass == ksGuideAstrology) then
            require "script/guide/AstrologyGuide"
            AstrologyGuide.cleanLayer()
            NewGuide.guideClass = ksGuideClose
            BTUtil:setGuideState(false)
            NewGuide.saveGuideClass()
        end
        ---------------------end-------------------------------------
        --]==]
        return
    end

    ---[==[占星 新手引导屏蔽层
    ---------------------新手引导---------------------------------
    --add by licong 2013.09.29
    require "script/guide/NewGuide"
    if(NewGuide.guideClass == ksGuideAstrology) then
        require "script/guide/AstrologyGuide"
        AstrologyGuide.changLayer()
    end
    ---------------------end-------------------------------------
    --]==]

    require "script/ui/tip/AlertTip"
    --如果已经领取了第10个奖励，则代表奖励已经全部领取了
    if(m_prize_step >= 10)then   
        AlertTip.showAlert( GetLocalizeStringBy("key_1070"), nil, false, nil)
        return
    end

    local starArray = lua_string_split(m_dbAstrology.star_arr,",")

    --如果下一等级的奖励所需星数，大于当前已有星数，则代表下一等级还不能领
    if tonumber(starArray[m_prize_step + 1]) > tonumber(m_currentStar) then
        AlertTip.showAlert( GetLocalizeStringBy("key_2591"), nil, false, nil)
        return
    end

    local rewardTable = {}

    local rewardInfo = nil
    --虽然这么遍历，看起来不好看，但是也只能这样了
    for i = m_prize_step+1,10 do
        if tonumber(starArray[i]) <= tonumber(m_currentStar) then
            if tonumber(m_dbAstrology.id) > 1 then
                local randTable = m_dbAstrology["randReward" .. i]

                local rewardArray = lua_string_split(randTable,",")

                local initReward = rewardArray[tonumber(m_randReward[i])+1]

                rewardInfo = initReward
            else
                local rewardArray =  lua_string_split(m_dbAstrology.reward_arr,",")
                rewardInfo = rewardArray[i]
            end

            if i == 10 then
                m_prize_step = 10
            end
        else
            m_prize_step = i - 1
            break
        end

        local analyzeTable = transFormString(rewardInfo)
        table.insert(rewardTable,analyzeTable)
    end

    local drawAllCallBack = function(cbFlag,dictData,bRet)
        if(dictData.err=="ok")then
            require "script/ui/astrology/AstrologyLayer"
            AstrologyLayer.refreshAstrologyInfo()

            require "script/ui/item/ItemUtil"
            ItemUtil.addRewardByTable(rewardTable)
            require "script/ui/item/ReceiveReward"
            ReceiveReward.showRewardWindow(rewardTable,refreshRewards,nil,-550)

            --refreshRewards()
        end
    end

    RequestCenter.divine_drawPrizeAll(drawAllCallBack,nil)
end

-- 获得卡牌层
function showAstrologyRewardLayer(prize_level,currentStar,prize_step,new_reward,re_num,astro_num)
    --已刷新次数
    haveRefreshNum = re_num

    --占星次数
    astroNum = astro_num

    --判断是否这次升级了
    haveUpgrade = 0

    --用来读取占星表数据的变量
    m_dbAstrology = nil
    --一望无际的星空背景
    m_astroBg = nil
    --当前星数
    m_currentStar = currentStar
    --奖励等级（奖励升级的时候会用到，初始是一级奖励）
    m_prize_level = tonumber(prize_level)
    --当前级别的奖励领到的层数
    m_prize_step = tonumber(prize_step)
    --升级奖励按钮
    nextAstroLabel = nil

    remainTimes = nil
    --黄色底层框
    m_reportBg = nil
    --随机奖励
    m_randReward = new_reward

    _updateTimeScheduler = CCDirector:sharedDirector():getScheduler():scheduleScriptFunc(updateTime, 1, false)
    
    require "db/DB_Astrology"
    m_dbAstrology = DB_Astrology.getDataById(tonumber(prize_level))
    
    require "script/ui/main/MainScene"
    
    m_layerSize = CCSizeMake(620,930)
    
    local scale = MainScene.elementScale
    
    m_astrologyRewardLayer = CCLayerColor:create(ccc4(11,11,11,166))
    local m_reportInfoLayer = CCLayer:create()
    m_reportInfoLayer:setScale(scale)
    m_reportInfoLayer:setPosition((CCDirector:sharedDirector():getWinSize().width-m_layerSize.width*scale)/2,(CCDirector:sharedDirector():getWinSize().height-m_layerSize.height*scale)/2-15*scale)
    --m_reportInfoLayer:setPosition(ccp(CCDirector:sharedDirector():getWinSize().width/2,CCDirector:sharedDirector():getWinSize().height/2))
    m_astrologyRewardLayer:addChild(m_reportInfoLayer)
    
    
     m_reportBg = CCScale9Sprite:create(CCRectMake(100, 80, 10, 20),"images/common/viewbg1.png")
    m_reportBg:setContentSize(m_layerSize)
    m_reportBg:setAnchorPoint(ccp(0,0))
    m_reportBg:setPosition(0,0)
    m_reportInfoLayer:addChild(m_reportBg)
    
    -- TITLE
    local titleBg = CCSprite:create("images/battle/report/title_bg.png")
    titleBg:setAnchorPoint(ccp(0.5,0.5))
    titleBg:setPosition(m_layerSize.width*0.5,m_layerSize.height*0.993)
    m_reportBg:addChild(titleBg,1)
    
    local displayName = LuaCCLabel.createShadowLabel(GetLocalizeStringBy("key_3401"),g_sFontPangWa,33)
    displayName:setColor(ccc3( 0xff, 0xe4, 0x00));
    displayName:setAnchorPoint(ccp(0.5,0.5))
    displayName:setPosition((titleBg:getContentSize().width)/2,titleBg:getContentSize().height*0.5)
    titleBg:addChild(displayName)
    
    -- 奖励
     m_astroBg = CCSprite:create(IMG_PATH .. "rewardbg.png")
    m_astroBg:setAnchorPoint(ccp(0,1))
    m_astroBg:setPosition(10,880)
    m_reportBg:addChild(m_astroBg)
    
    refreshRewards()
    
    -- 按钮Bar
    local menuBar = CCMenu:create()
    menuBar:setPosition(ccp(0,0))
    menuBar:setTouchPriority(-501)
    m_reportBg:addChild(menuBar,0,9109)
    
    -- 关闭按钮
    local closeBtn = LuaMenuItem.createItemImage("images/common/btn_close_n.png", "images/common/btn_close_h.png" )
	closeBtn:setAnchorPoint(ccp(1, 1))
    closeBtn:setPosition(m_layerSize.width*1.02, m_layerSize.height*1.02)
	menuBar:addChild(closeBtn)
	closeBtn:registerScriptTapHandler(closeClick)
    
    require "script/libs/LuaCC"
    upgradeButton = LuaCC.create9ScaleMenuItem("images/common/btn/btn1_d.png","images/common/btn/btn1_n.png",CCSizeMake(180,73),GetLocalizeStringBy("key_2949"),ccc3(255,222,0))
    upgradeButton:setAnchorPoint(ccp(0.5,0.5))
    upgradeButton:setPosition(m_layerSize.width*0.2,m_layerSize.height*0.11)
	menuBar:addChild(upgradeButton)
	upgradeButton:registerScriptTapHandler(upgradeClick)

    refreshButton = LuaCC.create9ScaleMenuItem("images/common/btn/btn1_d.png","images/common/btn/btn1_n.png",CCSizeMake(180,73),"",ccc3(255,222,0))
    refreshButton:setAnchorPoint(ccp(0.5,0.5))
    refreshButton:setPosition(ccp(m_layerSize.width*0.2,m_layerSize.height*0.11))
    menuBar:addChild(refreshButton)
    refreshButton:registerScriptTapHandler(refreshClick)
    refreshButton:setVisible(false)

    local refreshCh = CCRenderLabel:create(GetLocalizeStringBy("key_1002"),g_sFontPangWa,32,1,ccc3(0,0,0),type_stroke)
    refreshCh:setColor(ccc3(255,222,0))
    local goldPic = CCSprite:create("images/common/gold.png")
    require "db/DB_Vip"
    require "script/model/user/UserModel"
    local vipLevel = UserModel.getVipLevel()
    local dbVip = DB_Vip.getDataById(vipLevel+1)
    local vipString = dbVip.astrologyCost
    afterString = lua_string_split(vipString,"|")
    needGold = tonumber(afterString[2])+(tonumber(haveRefreshNum))*tonumber(afterString[3])
    goldNum = CCLabelTTF:create(tostring(needGold),g_sFontName,28)
    goldNum:setColor(ccc3(0xff,0xff,0xff))

    local buttomUpper = BaseUI.createHorizontalNode({refreshCh ,goldPic, goldNum})
    buttomUpper:setAnchorPoint(ccp(0.5,0.5))
    buttomUpper:setPosition(ccp(refreshButton:getContentSize().width/2,refreshButton:getContentSize().height/2))
    refreshButton:addChild(buttomUpper)

    -- local goldSprite = CCSprite:create("images/common/gold.png")
    -- local goldNum = CCLabelTTF:create(, g_sFontName, 25)
    -- goldNum:setColor(ccc3(0xff,0xff,0xff))

    --需求改回来了，所以升级按钮可见了，change by zhang zihang
    --upgradeButton:setVisible(false) 
    --change by lichenyang 去掉升级奖励按钮 
    
    drawPrizeButton = LuaCC.create9ScaleMenuItem("images/common/btn/btn1_d.png","images/common/btn/btn1_n.png",CCSizeMake(180,73),GetLocalizeStringBy("zzh_1161"),ccc3(255,222,0))
    drawPrizeButton:setAnchorPoint(ccp(0.5,0.5))
    --需求变了，又改回来了
     drawPrizeButton:setPosition(m_layerSize.width*0.8,m_layerSize.height*0.11)
    --drawPrizeButton:setPosition(m_layerSize.width*0.5,m_layerSize.height*0.11)     
    --change by lichenyang 
	menuBar:addChild(drawPrizeButton,0,8109)
	drawPrizeButton:registerScriptTapHandler(onceDrawCallBack)
    
    currentStarLabel = CCRenderLabel:create(GetLocalizeStringBy("key_1038") .. m_currentStar, g_sFontName, 24, 2, ccc3( 0x00, 0x06, 0x7c), type_stroke)
    currentStarLabel:setColor(ccc3(0xe7,0xb7,0xfe))
    currentStarLabel:setPosition(m_layerSize.width*0.8 - currentStarLabel:getContentSize().width/2,m_layerSize.height*0.07)
    m_reportBg:addChild(currentStarLabel)
    
    require "db/DB_Astrology"
    nextAstrology = DB_Astrology.getDataById(tonumber(prize_level)+1)
    
    if(nextAstrology==nil)then
        upgradeButton:setVisible(false)
        refreshButton:setVisible(true)
        --drawPrizeButton:setPosition(m_layerSize.width*0.5,m_layerSize.height*0.11)

        refreshButton:setPosition(m_layerSize.width*0.25,m_layerSize.height*0.11)
        drawPrizeButton:setPosition(m_layerSize.width*0.75,m_layerSize.height*0.11)
        currentStarLabel:setPosition(m_layerSize.width*0.75 - currentStarLabel:getContentSize().width/2,m_layerSize.height*0.07)

        nextAstroLabel = CCRenderLabel:create(GetLocalizeStringBy("key_2719"), g_sFontName, 18, 2, ccc3( 0x00, 0x00, 0x00), type_stroke)
        --nextAstroLabel:setAnchorPoint(ccp(0.5,1))
        nextAstroLabel:setColor(ccc3(0x36,0xff,0x00))
        nextAstroLabel:setPosition(m_layerSize.width*0.25 - nextAstroLabel:getContentSize().width/2 ,m_layerSize.height*0.075)
        m_reportBg:addChild(nextAstroLabel)

        remainTimes = CCRenderLabel:create(GetLocalizeStringBy("key_2697") .. tostring(afterString[1]-haveRefreshNum), g_sFontName, 18, 2, ccc3( 0x00, 0x00, 0x00), type_stroke)
        remainTimes:setColor(ccc3(0x36,0xff,0x00))
        remainTimes:setPosition(m_layerSize.width*0.25 - remainTimes:getContentSize().width/2 ,m_layerSize.height*0.045)
        m_reportBg:addChild(remainTimes)

        --currentStarLabel:setPosition(ccp(m_layerSize.width*0.8 - currentStarLabel:getContentSize().width/2,m_layerSize.height*0.12))
        
        upgradeButton:setEnabled(false)
    else
        
        if tonumber(prize_level) >= 2 then
            refreshButton:setVisible(true)
            upgradeButton:setVisible(true)

            refreshButton:setPosition(m_layerSize.width*0.5,m_layerSize.height*0.11)

            middleLabel = CCRenderLabel:create(GetLocalizeStringBy("key_2719"), g_sFontName, 18, 2, ccc3( 0x00, 0x00, 0x00), type_stroke)
            --nextAstroLabel:setAnchorPoint(ccp(0.5,1))
            middleLabel:setColor(ccc3(0x36,0xff,0x00))
            middleLabel:setPosition(m_layerSize.width*0.5 - middleLabel:getContentSize().width/2 ,m_layerSize.height*0.075)
            m_reportBg:addChild(middleLabel)

            middleTimes = CCRenderLabel:create(GetLocalizeStringBy("key_2697") .. tostring(afterString[1]-haveRefreshNum), g_sFontName, 18, 2, ccc3( 0x00, 0x00, 0x00), type_stroke)
            middleTimes:setColor(ccc3(0x36,0xff,0x00))
            middleTimes:setPosition(m_layerSize.width*0.5 - middleTimes:getContentSize().width/2 ,m_layerSize.height*0.045)
            m_reportBg:addChild(middleTimes)
        end

        nextAstroLabel = CCRenderLabel:create(GetLocalizeStringBy("key_1636") .. nextAstrology.limited_lv .. GetLocalizeStringBy("key_2701"), g_sFontName, 20, 2, ccc3( 0x00, 0x00, 0x00), type_stroke)
        nextAstroLabel:setColor(ccc3(0x36,0xff,0x00))
        if tonumber(prize_level) == 1 then
            nextAstroLabel:setPosition(m_layerSize.width*0.25 - nextAstroLabel:getContentSize().width/2,m_layerSize.height*0.07)
            currentStarLabel:setPosition(m_layerSize.width*0.75 - currentStarLabel:getContentSize().width/2,m_layerSize.height*0.07)
            upgradeButton:setPosition(m_layerSize.width*0.25,m_layerSize.height*0.11)
            drawPrizeButton:setPosition(m_layerSize.width*0.75,m_layerSize.height*0.11)
        else
            nextAstroLabel:setPosition(m_layerSize.width*0.2 - nextAstroLabel:getContentSize().width/2,m_layerSize.height*0.07)
        end
        m_reportBg:addChild(nextAstroLabel)
        
        require "script/model/user/UserModel"
        local userInfo = UserModel.getUserInfo()
        if userInfo ~= nil then
            
            if(tonumber(userInfo.level)<tonumber(nextAstrology.limited_lv))then
                upgradeButton:setEnabled(false)
            end
        end
    end
    
    --m_astrologyRewardLayer:setScale(scale)
    m_astrologyRewardLayer:setTouchEnabled(true)
    m_astrologyRewardLayer:registerScriptTouchHandler(cardLayerTouch,false,-500,true)
    
    local scene = CCDirector:sharedDirector():getRunningScene()
    scene:addChild(m_astrologyRewardLayer,999,1231)

    local seq = CCSequence:createWithTwoActions(CCDelayTime:create(0.3),CCCallFunc:create(function ( ... )
        addGuideAstrologyGuide8()
    end))
    m_astrologyRewardLayer:runAction(seq)
end

-- 退出场景，释放不必要资源
function release (...) 

end

---[==[占星 第8步
---------------------新手引导---------------------------------
function addGuideAstrologyGuide8( ... )
    require "script/guide/NewGuide"
    require "script/guide/AstrologyGuide"
    if(NewGuide.guideClass ==  ksGuideAstrology and AstrologyGuide.stepNum == 7) then
        require "script/ui/astrology/AstrologyRewardLayer"
        local astrologyButton = AstrologyRewardLayer.getDrawPrizeButton()
        local touchRect = getSpriteScreenRect(astrologyButton)
        AstrologyGuide.show(8, touchRect)
    end
end
---------------------end-------------------------------------
--]==]


