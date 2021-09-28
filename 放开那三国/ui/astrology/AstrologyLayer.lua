-- Filename: AstrologyLayer.lua
-- Author: k
-- Date: 2013-08-03
-- Purpose: 占星



require "script/utils/extern"
--require "amf3"
-- 主城场景模块声明
module("AstrologyLayer", package.seeall)

require "script/network/RequestCenter"
require "script/network/Network"
require "script/utils/LuaUtil"
require "script/ui/main/MainScene"

local IMG_PATH = "images/astrology/"				-- 图片主路径

astroTime = 16
getAstrologyInfo = nil
local _isOneKey = false
local m_astrologyLayer
local m_refreshButton
local m_astrologyMenu
local currentStarLabel
local m_astroPos1
local m_astroPos2
local m_astroPos3
local m_astroPos4
local m_powerLabel
local m_silverLabel
local m_goldLabel
local m_rewardStarLabel
local astroTimesLabel
local freeTimesLabel
local layerSize
local m_bar
local m_barEffect
local m_barEffectLayer
local m_lastIntegral = 0
local _goldCostNum = 0
local _type = 0
local m_isBusy = false

local m_astrologyInfo

local getDiviInfoCallBack
local m_isAllStarSelected = false

local m_costItemTid = 0
local m_cost_num    = 0
-- add by licong 新手
local buttonTag = nil

local havaCostNum = 0
local m_havaLabel = nil

local haveTarget = false

--获得占星按键
function getAstroButtonByIndex(index)
    if(m_astrologyMenu~=nil and m_astrologyMenu:getChildByTag(1000+index) ~= nil)then
        return m_astrologyMenu:getChildByTag(1000+index)
        else
        return nil
    end
end

--获得占星目标星座
function getTargetAstroByIndex(index)
    if(index==1)then
        return m_astroPos1
    elseif(index==2)then
        return m_astroPos2
    elseif(index==3)then
        return m_astroPos3
    elseif(index==4)then
        return m_astroPos4
    else
        return nil
    end
end

--获得查看奖励按键
function getShowRewardButton()
    if(m_astrologyMenu~=nil and m_astrologyMenu:getChildByTag(1900) ~= nil)then
        return m_astrologyMenu:getChildByTag(1900)
    else
        return nil
    end
end

function showDesc()
    -- 音效
    require "script/audio/AudioUtil"
    AudioUtil.playEffect("audio/effect/zhujiemian.mp3")
    require "script/ui/astrology/AstrologyDescLayer"
    AstrologyDescLayer.showAstrologyDescLayer()
    --[[
    local fightStr = "eJydWFtsFFUY3jN7dtvptrTrAtWCTcu13W6ELqUKSARaSKtE67appDa0s93Z7sDemJ2llwflYrctWwIBo0/qm6kxaUoIPvjQBqIPvvhgNFHjc73ExFcfjPifMzs717MVSIA9c/7/O////bczU+NDdVFBUZIin0E1PsTLwqSIOT88EiYuijK+dv/Lbn9MjIvpGKzWft1fJ0woUiaN5xM+OZNPxzBqFGQ5IqqPeQ9B8RJBv1x6hlEAJHqFFEDzbrK/LUYXQzNZEdTVxbCQzIv4aiPyxQVFSLo1nOAWjBpUtWcw2orjCJHfHOYwOcVLLazGn3E1GNXyJTXyzKJ3UzAoXrt/b5yAt1XjYotRER5Z9OazCPnB/p6ElIypz036hQdBHaAumo/HRVld+NVFfwwX7nbzCnGW52PgHJ5r0G00udPmpdDgTq3ZnXvjFrOWmszuSMSc9mq8eNDsTrtRz70V3zhtOrCdgkt2/u5J1gPfNB24skGDXI0XGqhiVTnulgMLAeRILWzNKYhl5uLzaLvbaGhQC/TyiG5ofUpIxzJTabc94oBxc9Jk8WoPOagDIp41W2zNsPfGymZ1WLdmyluhLZgzGtihhW45vFnoOsx29ZZCVxzVFZvU/3biD19rxjtb8GP440jUQo0pniEtnkaa7PEkiZBg1wNXoR4W9iL0LKsOOKv5kPnNmG/RMp5yYS9gmvGc8VwH2oovsDOeq5TxEXaJVT5wlp3xXKWM38HM+EItM+NJnbAKk9usMMsBMSgWvh7aRLNQj9gVwlWokDkfu0LeNVaITcta0bRgRioFAqhZ6lcVbdViCTu7HivGeSnFLiE2f6YSgur8x1xFUAzuWr7OMUcI9RHnHCFb55xzhGwlESskhT5mSBbPkF7KCErhFbMPhopcO0F9oLK73I7U3TlgY6BclkcrMEAaVzezShZa6JZfTJ/Sxile5hy730lnQkg95ejWHl25wyJRjJZ4MciELDLzrVZ62rT0WB+mDnqY5XWrAWl7q73W24hsKlod9C2dc2rW6oDGkJVpvR81UR1mP7pxgMn0rUMlCkh87fTeyuhTWPM/qJn6KKKb6lgexeNWk/UGM2txc8opcW9WqwBw/9QTYao8W5Y5OloeP/63F5Uq3lWNXYBsm65tar9wM6aryzkNXUb7mceGnAgp1YuNklb2SMG1hsuzNZlDSI+S0zXKOlFXNtTJgQ0BWtmw8ttlSsKyIp0cFTULBypMDvyUk2OGOTnm651ug8RU0qPZlhLG99mSsLdEejGu28q8b1mbxlJ9qWKYGtZGNB9GFeVtjVG/0e1TG1OljCfcqzPOSMNqjzXU7v8NGlIblp1bcxMjl/R+djZ7DKPZ6uFiuyWcppT1VEzZ0+y882yed2oBWTNvzsPMPPIuwMo7tqHg4+2YyUdj2o3qqqo9tgw4Yb+QaAHxVApIcZe1X2tRCapjwmvoMdY8hW5gGIc5p2m4MM1mw1uRjTfshqmxC6rDwGsixBq9u+9o6jR5cyVW1G7vtZEcUkn2bvYuZXXvRtQSM5W7kJrRVYaMtmrOHWNHrKpSxArdDvkcUvOZeaAhL81Ox3UllUjbdaYR1AJCNisLUk5Iet2DdbI4JcgxEKhLZ+SUkIRffEKUM6oWn1CkGL76x6AvKV4WkzjsS+WU/hiJESDx0Un47WrGXH0qn5MmyIKPyqBx/dExf15OjpGFtzV6JCpExbDY2dkVf/GweMSniEKqk8CnhZTo9YcPdh6Cvc6qPDns5/EuvLtRyShCsi/bk8kp+Nr6234pN5AUZkTZXS/Ich8xkF4tqxKgQl7+w/hbvz+byUn0k5OrCyNfSpjuy+Lbzf6JvCxHyIctV0C8lJey/el4hngsyCkpPQm/3MSYekkRU2MA9/Dv0Vb6G/5mk4IikoeFDwb99GE6n8IooO5LKdFz8vtP9oSvuFzPXRbGSlrTCsDtBvSIKMFR8oR4lrIHFwp3GLvch2D7PH742+5xXPg0FMUoBigf/fCLy+WKw1aCCnapQn+dB6EVviT0ceaLK5oQBMB9WBX6cwyEHmzRhNrXjEgokLsoJZOnMpmLPEJ+RRaFXF4WYXsUuy4QCfJ9a5DIwH6AfAGkCzwvN6rfAUvLBCF8gL4HANv7Ixh14fAQ/g4NY9c52BopQ4KrEIMsYMsAqRiOugzraXg9msXFljKcBHA7IpijcD/tfWK4xaOzePGgBreyAXCBCHZTuB/5J4ZbaJqFitfgVnsAriOC8VM7OwvOZstwvQAXjGAPhfvm5SeCg+ZX+Hw7QMYBchRti0uTCeUMSTB8/fcLiNZVGDR6vagPX33/WBc+/iq+fmf6LPe6Wi4DZNyEyT8RUiMvDeH1EWIBrxm7dmIWprAm2kZE22igQfSrSybR9WEQrdVE24loOw3iZqhBIhqkAbKjPorMQtvURDuIqEq+gwHjIBrWRENENESJZaIi9B9uCkLh"
    
    require "script/battle/BattleLayer"
    BattleLayer.showBattleWithString(fightStr,nil,nil)
    --]]
end

function gotoReward(cbFlag, dictData, bRet)
    if(dictData.err=="ok")then
        m_astrologyInfo = dictData.ret
        table.hcopy(dictData.ret, m_astrologyInfo)
        require "script/ui/astrology/AstrologyRewardLayer"
        print("dfsdfdf")
        print_t(m_astrologyInfo)
        AstrologyRewardLayer.showAstrologyRewardLayer(m_astrologyInfo.prize_level,m_astrologyInfo.integral,m_astrologyInfo.prize_step,m_astrologyInfo.va_divine.newreward,m_astrologyInfo.ref_prize_num,m_astrologyInfo.divi_times)
    end
end

function showReward()
    -- 音效
    require "script/audio/AudioUtil"
    AudioUtil.playEffect("audio/effect/zhujiemian.mp3")
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
    --print("m_astrologyInfo",m_astrologyInfo)

    --added by zhang zihang
    RequestCenter.divine_getDiviInfo(gotoReward,CCArray:create())
    --print("==========showReward===============")
end

function refreshClick(tag,menuItem,isForceRefresh)
    require "script/audio/AudioUtil"
    AudioUtil.playEffect("audio/effect/zhujiemian.mp3")
    if(m_isBusy==true)then
        return
    end
    
    --无占星次数时不可刷新
    if(tonumber(m_astrologyInfo.divi_times)>=astroTime)then
        require "script/ui/tip/AlertTip"
        AlertTip.showAlert( GetLocalizeStringBy("key_1036"), nil, false, nil)
        return
    end
    
    --print("isForceRefresh:",tag,menuItem,isForceRefresh,isForceRefresh==false)
    --有存在的目标星座时提示是否刷新
    if(isForceRefresh==nil or isForceRefresh==false)then
        --print("isForceRefresh==nil or isForceRefresh==false")
        for i=1,#m_astrologyInfo.va_divine.target do
            if(m_astrologyInfo.va_divine.lighted[i]==nil or tonumber(m_astrologyInfo.va_divine.lighted[i])==0)then
                for j=1,5 do
                    local starId = m_astrologyInfo.va_divine.current[j]
                    if(starId~=nil and starId == m_astrologyInfo.va_divine.target[i] and m_astrologyMenu:getChildByTag(1000+j)~=nil)then
                        
                        local function confirmRefresh(forceRefresh)
                            if(forceRefresh==true)then
                                refreshClick(tag,menuItem,true)
                            else
                                
                            end
                        end
                        
                        require "script/ui/tip/AlertTip"
                        AlertTip.showAlert( GetLocalizeStringBy("key_2815"), confirmRefresh, true, nil)
                        
                        return
                    end
                end
            end
        end
    end
    
    -- 音效
    require "script/audio/AudioUtil"
    AudioUtil.playEffect("audio/effect/zhujiemian.mp3")
    if(UserModel.getGoldNumber()<10 and tonumber(m_astrologyInfo.free_refresh_num)<=0 and tonumber(havaCostNum) - tonumber(m_cost_num) <0)then
        
        local function refreshGold()
            require "script/model/user/UserModel"
            local userInfo = UserModel.getUserInfo()
            if userInfo == nil then
                return
            end
            m_silverLabel:setString(string.convertSilverUtilByInternational(userInfo.silver_num))  -- modified by yangrui at 2015-12-03
            
            m_goldLabel:setString(tostring(userInfo.gold_num))
            require "script/ui/shop/RechargeLayer"
            RechargeLayer.registerChargeGoldCb(nil)
        end
        --require "script/ui/tip/AlertTip"
        --AlertTip.showAlert( GetLocalizeStringBy("key_3245"), nil, false, nil)
        require "script/ui/tip/LackGoldTip"
        LackGoldTip.showTip()
        require "script/ui/shop/RechargeLayer"
        RechargeLayer.registerChargeGoldCb( refreshGold)
        return
    end
    local function refreshCurstarCallback(cbFlag, dictData, bRet)
        if(dictData.err=="ok")then
            print(GetLocalizeStringBy("key_3218"),havaCostNum)
            print(GetLocalizeStringBy("key_3169"),m_astrologyInfo.free_refresh_num)
            if(tonumber(m_astrologyInfo.free_refresh_num)<=0 and tonumber(havaCostNum) - tonumber(m_cost_num) >=0)then
                print(GetLocalizeStringBy("key_2808"))
                print(GetLocalizeStringBy("key_3218"),havaCostNum)
                print(GetLocalizeStringBy("key_3169"),m_astrologyInfo.free_refresh_num)
                updateHavaCostNode()
            elseif(tonumber(m_astrologyInfo.free_refresh_num)<=0 and tonumber(havaCostNum) - tonumber(m_cost_num) <0)then
                print(GetLocalizeStringBy("key_1080"))
                UserModel.changeGoldNumber(-10)
            end
            RequestCenter.divine_getDiviInfo(getDiviInfoCallBack,CCArray:create())
        end
    end
    
    RequestCenter.divine_refreshCurstar(refreshCurstarCallback,CCArray:create())
    --print("==========refreshClick===============")
end

function astroClick(tag, item_obj)
    if(m_isBusy==true)then
        return
    end

    -- require "script/model/user/UserModel"
    -- local userInfo = UserModel.getUserInfo()

    -- local comingAstrology = DB_Astrology.getDataById(tonumber(m_astrologyInfo.prize_level)+1)

    -- if ((comingAstrology) ~= nil ) and (tonumber(userInfo.level)>=tonumber(comingAstrology.limited_lv)) then
    --     require "script/ui/tip/AlertTip"
    --     AlertTip.showAlert( GetLocalizeStringBy("key_1643"), nil, false, nil)
    --     return
    -- end

    -- 音效
    require "script/audio/AudioUtil"
    AudioUtil.playEffect("audio/effect/zhujiemian.mp3")
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
    -- add by licong 新手
    buttonTag = tag
    -----------------
    if(tonumber(m_astrologyInfo.divi_times)>=astroTime)then
        
        require "script/ui/tip/AlertTip"
        AlertTip.showAlert( GetLocalizeStringBy("key_1819"), nil, false, nil)
        return
    end
    
    require "db/DB_Astrology"
    local dbAstrology = DB_Astrology.getDataById(tonumber(m_astrologyInfo.prize_level))
    if(tonumber(m_astrologyInfo.integral)>=dbAstrology.star_max)then
        
        require "script/ui/tip/AlertTip"
        AlertTip.showAlert( GetLocalizeStringBy("key_2092"), nil, false, nil)
        return
    end
    
    local function diviCallback(cbFlag, dictData, bRet)
        if(dictData.err=="ok" )then
            RequestCenter.divine_getDiviInfo(getDiviInfoCallBack,CCArray:create())
        end
    end
    
    local confirmRefresh = function(p_param)
        if p_param == true then
            haveTarget = false

            m_isBusy = true
            local effectSprite = CCLayerSprite:layerSpriteWithName(CCString:create("images/base/effect/astro/zhanxingxing"), -1,CCString:create(""));
            
            local function callDivi()
                --m_isBusy = false
                effectSprite:removeFromParentAndCleanup(true)
                RequestCenter.divine_divi(diviCallback,Network.argsHandler(tag-1001))
            end
            
            effectSprite:setPosition(item_obj:getPositionX()*MainScene.elementScale,item_obj:getPositionY()*MainScene.elementScale)
            m_astrologyLayer:addChild(effectSprite,99)
            
            local integral = tonumber(m_astrologyInfo.integral)>dbAstrology.star_max and dbAstrology.star_max or tonumber(m_astrologyInfo.integral)
            local barSize = m_bar:getTexture():getContentSize()
            
            local barWorldPoint = m_bar:convertToWorldSpace(ccp(barSize.width*(integral/dbAstrology.star_max),0))
            local currentX = m_astrologyLayer:convertToNodeSpace(barWorldPoint).x
            --barSize.width*(integral/dbAstrology.star_max)
            local effectActionArray = CCArray:create()
            effectActionArray:addObject(CCMoveTo:create(0.5,ccp(currentX,layerSize.height*0.54)))
            effectActionArray:addObject(CCDelayTime:create(0.2))
            effectActionArray:addObject(CCCallFunc:create(callDivi))
            effectSprite:runAction(CCSequence:create(effectActionArray))
        end
    end

    if item_obj:getChildByTag(100) == nil and haveTarget == true then
        require "script/ui/tip/AlertTip"
        AlertTip.showAlert( GetLocalizeStringBy("zzh_1191"), confirmRefresh, true, nil) 
    else
        confirmRefresh(true)
    end
    
    --print("==========astroClick===============")
end

getDiviInfoCallBack = function (cbFlag, dictData, bRet)
    --print_table("getDiviInfoCallBack",dictData)
    --print("-----------------------------")
    if(dictData.err=="ok")then
        m_lastIntegral = m_astrologyInfo == nil and tonumber(dictData.ret.integral) or tonumber(m_astrologyInfo.integral)
        --print("m_lastIntegral::",m_lastIntegral)
        if(m_astrologyInfo == nil)then
            m_isBusy = false
            m_astrologyInfo = dictData.ret
            table.hcopy(dictData.ret, m_astrologyInfo)
            --print_table("getDiviInfoCallBack",m_astrologyInfo)
            loadDivinInfo()
            return
        end
        
        --判断是否为当前星座完结
        local lightedNumber = 0
        for i=1,#m_astrologyInfo.va_divine.lighted do
            if(m_astrologyInfo.va_divine.lighted[i]~=nil and m_astrologyInfo.va_divine.lighted[i] ~= "0")then
               lightedNumber = lightedNumber + 1
           end
        end
        
        --print("lightedNumber:",lightedNumber,#m_astrologyInfo.va_divine.lighted,dictData.ret.va_divine.lighted[1])
        if(lightedNumber==#m_astrologyInfo.va_divine.lighted-1 and (dictData.ret.va_divine.lighted[1] == "0") and (dictData.ret.va_divine.lighted[2] == "0") and (dictData.ret.va_divine.lighted[3] == "0") and (dictData.ret.va_divine.lighted[4] == "0"))then
        --if(true)then
            
            m_isAllStarSelected = true
            --m_isBusy = true
            
            require "db/DB_Astrology"
            local dbAstrology = DB_Astrology.getDataById(tonumber(m_astrologyInfo.prize_level))
            
            local function showDivin()
                m_isBusy = false
                m_astrologyInfo = dictData.ret
                table.hcopy(dictData.ret, m_astrologyInfo)
                --print_table("getDiviInfoCallBack",m_astrologyInfo)
                loadDivinInfo()
            end
        
        local integral = tonumber(m_astrologyInfo.integral)>dbAstrology.star_max and dbAstrology.star_max or tonumber(m_astrologyInfo.integral)
        local barSize = m_bar:getTexture():getContentSize()
        
        local barWorldPoint = m_bar:convertToWorldSpace(ccp(barSize.width*(integral/dbAstrology.star_max),0))
        local currentX = m_astrologyLayer:convertToNodeSpace(barWorldPoint).x
        
            for i=1,#m_astrologyInfo.va_divine.target do
                local positionSprite = m_astrologyLayer:getChildByTag(112):getChildByTag(2000+i)
                --print("positionSprite:",positionSprite,positionSprite:getChildByTag(1310))
                positionSprite:getChildByTag(1310):runAction(CCFadeOut:create(0.6))
                positionSprite:removeChildByTag(711,true)
                
                local positionWorldPoint = positionSprite:convertToWorldSpace(ccp(positionSprite:getContentSize().width/2,-positionSprite:getContentSize().height/2))
                local tempPoint = m_astrologyLayer:convertToNodeSpace(positionWorldPoint)
                
                if(file_exists("audio/effect/" .. "zhanxingbao" .. ".mp3")) then
                    AudioUtil.playEffect("audio/effect/" .. "zhanxingbao" .. ".mp3")
                end
                
                local baoSprite = CCLayerSprite:layerSpriteWithName(CCString:create("images/base/effect/astro/zhanxingbao"), -1,CCString:create(""))
                baoSprite:setFPS_interval(1/50)
                
        
                local effectSprite = CCLayerSprite:layerSpriteWithName(CCString:create("images/base/effect/astro/zhanxingxing"), -1,CCString:create(""));

                effectSprite:setOpacity(0)
                
                local function removeEffectSprite()
                    effectSprite:removeFromParentAndCleanup(true)
                end
        
                effectSprite:setPosition(positionWorldPoint)
                m_astrologyLayer:addChild(effectSprite,99)

                --barSize.width*(integral/dbAstrology.star_max)
        
        
                local function removeEffect()
                    baoSprite:retain()
                    baoSprite:autorelease()
                    baoSprite:removeFromParentAndCleanup(true)
                    effectSprite:setOpacity(255)
                    local effectActionArray = CCArray:create()
                    effectActionArray:addObject(CCMoveTo:create(0.5,ccp(currentX,layerSize.height*0.54)))
                    effectActionArray:addObject(CCDelayTime:create(0.2))
                    effectActionArray:addObject(CCCallFunc:create(removeEffectSprite))
                    effectSprite:runAction(CCSequence:create(effectActionArray))
                end
                baoSprite:setPosition(positionWorldPoint)
                m_astrologyLayer:addChild(baoSprite,99)

                local animationFrameChanged = function(frameIndex,xmlSprite)
                end

                --增加动画监听
                local delegate = BTAnimationEventDelegate:create()
                delegate:registerLayerEndedHandler(removeEffect)
                delegate:registerLayerChangedHandler(animationFrameChanged)
                baoSprite:setDelegate(delegate)

            end

            local effectActionArray = CCArray:create()
            effectActionArray:addObject(CCDelayTime:create(2.8))
            effectActionArray:addObject(CCCallFunc:create(showDivin))
            m_astrologyLayer:runAction(CCSequence:create(effectActionArray))

        else
            m_isBusy = false
            m_astrologyInfo = dictData.ret
            table.hcopy(dictData.ret, m_astrologyInfo)
            --print_table("getDiviInfoCallBack",m_astrologyInfo)
            loadDivinInfo()
        end
    else
        
    end
    
end

function refreshAstrologyInfo()
    RequestCenter.divine_getDiviInfo(getDiviInfoCallBack,CCArray:create())
end

function resetAction( ... )
    require "script/audio/AudioUtil"
    AudioUtil.playEffect("audio/effect/zhujiemian.mp3")
    require "db/DB_Astrology"
    local data = DB_Astrology.getDataById(4)
    local userLevel = tonumber(UserModel.getUserInfo().level)
    local isCan = false
    if(userLevel >= tonumber(data.level))then
        isCan = true
    else
        isCan = false
    end
    require "script/ui/tip/AnimationTip"
    if( isCan == false )then
        AnimationTip.showTip(GetLocalizeStringBy("llp_502"))
        return
    end

    if(tonumber(m_astrologyInfo.divi_times)~=0 or tonumber(m_astrologyInfo.free_refresh_num)~=1)then
        AnimationTip.showTip(GetLocalizeStringBy("llp_504"))
        return
    end
    local yesCallBack = function ()
        -- 判断金币是否够
        if(_type==3) then
            LackGoldTip.showTip()
            return
        end
        local nextCallFun = function (p_retData )
            UserModel.addGoldNumber(-_goldCostNum)
            local freshCallBack = function ( ... )
                _isOneKey = true
                refreshAstrologyInfo()
                updateHavaCostNode()
            end
            
            local runningScene = CCDirector:sharedDirector():getRunningScene()
            performWithDelay(runningScene,freshCallBack,0.1)
        end
        RequestCenter.divine_diviAll(nextCallFun)
    end

    require "db/DB_Aster"
    require "db/DB_Normal_config"
    local starCount = table.count(DB_Aster.Aster)
    local leftCount = 0
    local cardCount = 0
    local itemCost = DB_Normal_config.getDataById(1).astrologyItem
    local itemData = string.split(itemCost,"|")
    local itemId = tonumber(itemData[1])
    local itemCount = tonumber(itemData[2])
    local goldCost = 10
    local itemCountInBag = ItemUtil.getCacheItemNumBy(itemId)
    local goldNum = UserModel.getGoldNumber()
    local tipNode = CCNode:create()
    tipNode:setContentSize(CCSizeMake(400,100))
    print("itemCountInBag==",itemCountInBag)
    print("starCount*itemCount==",starCount*itemCount)
    if(itemCountInBag>=(starCount*itemCount))then
        _type = 1
        local textInfo = {
            width = 400, -- 宽度
            alignment = 1, -- 对齐方式  1 左对齐，2 居中， 3右对齐
            labelDefaultFont = g_sFontName,      -- 默认字体
            labelDefaultSize = 25,          -- 默认字体大小
            labelDefaultColor = ccc3(0x78,0x25,0x00),
            linespace = 10, -- 行间距
            defaultType = "CCLabelTTF",
            elements =
            {   

                {
                    type = "CCSprite", 
                    image = "images/base/props/small_guijia.png",
                },
                {
                    type = "CCLabelTTF", 
                    text = starCount*itemCount,
                    color = ccc3(0x78,0x25,0x00)
                },
            }
        }
        m_cost_num = starCount*itemCount
        local tipDes = GetLocalizeLabelSpriteBy_2("llp_505", textInfo)
        tipDes:setAnchorPoint(ccp(0.5, 0.5))
        tipDes:setPosition(ccp(tipNode:getContentSize().width*0.5,tipNode:getContentSize().height*0.5))
        tipNode:addChild(tipDes)
    elseif(tonumber(itemCountInBag)<(starCount*itemCount) and tonumber(goldNum)>=((starCount*itemCount)-itemCountInBag)*goldCost)then
        print("hehehehhehehe")
        _type = 2
        local textInfo = {
            width = 400, -- 宽度
            alignment = 1, -- 对齐方式  1 左对齐，2 居中， 3右对齐
            labelDefaultFont = g_sFontName,      -- 默认字体
            labelDefaultSize = 25,          -- 默认字体大小
            labelDefaultColor = ccc3(0x78,0x25,0x00),
            linespace = 10, -- 行间距
            defaultType = "CCLabelTTF",
            elements =
            {   
                {
                    type = "CCSprite", 
                    image = "images/base/props/small_guijia.png",
                },
                {
                    type = "CCLabelTTF", 
                    text = itemCountInBag,
                    color = ccc3(0x78,0x25,0x00)
                },

                {
                    type = "CCSprite", 
                    image = "images/common/gold.png",
                },
                {
                    type = "CCLabelTTF", 
                    text = (starCount-itemCountInBag/itemCount)*goldCost,
                    color = ccc3(0x78,0x25,0x00)
                },
            }
        }
        m_cost_num = itemCountInBag
        _goldCostNum = tonumber((starCount-itemCountInBag/itemCount)*goldCost)
        local tipDes = GetLocalizeLabelSpriteBy_2("llp_506", textInfo)
        tipDes:setAnchorPoint(ccp(0.5, 0.5))
        tipDes:setPosition(ccp(tipNode:getContentSize().width*0.5,tipNode:getContentSize().height*0.5))
        tipNode:addChild(tipDes)
    else
        _type = 3
        local textInfo = {
            width = 400, -- 宽度
            alignment = 1, -- 对齐方式  1 左对齐，2 居中， 3右对齐
            labelDefaultFont = g_sFontName,      -- 默认字体
            labelDefaultSize = 25,          -- 默认字体大小
            labelDefaultColor = ccc3(0x78,0x25,0x00),
            linespace = 10, -- 行间距
            defaultType = "CCLabelTTF",
            elements =
            {   
                {
                    type = "CCSprite", 
                    image = "images/base/props/small_guijia.png",
                },
                {
                    type = "CCLabelTTF", 
                    text = itemCountInBag,
                    color = ccc3(0x78,0x25,0x00)
                },

                {
                    type = "CCSprite", 
                    image = "images/common/gold.png",
                },
                {
                    type = "CCLabelTTF", 
                    text = ((starCount*itemCount)-itemCountInBag)*goldCost,
                    color = ccc3(0x78,0x25,0x00)
                },
            }
        }
        local tipDes = GetLocalizeLabelSpriteBy_2("llp_507", textInfo)
        tipDes:setAnchorPoint(ccp(0.5, 0.5))
        tipDes:setPosition(ccp(tipNode:getContentSize().width*0.5,tipNode:getContentSize().height*0.5))
        tipNode:addChild(tipDes)
    end
    
    -- local str = RedCardDestinyData.getCurSpecialName(_heroInfo[_curHeroIndex].destiny,_heroInfo[_curHeroIndex])
    -- if(string.len(str)==0)then
    --     local dbInfo = DB_Heroes.getDataById(_heroInfo[_curHeroIndex].htid)
    --     str = dbInfo.name
    -- end
    require "script/ui/tip/TipByNode"
    TipByNode.showLayer(tipNode,yesCallBack,CCSizeMake(500,360),-2000)
end

getAstrologyInfo = function()
    
    if(m_astrologyInfo==nil)then
        function getAstrologyInfoCallBack(cbFlag, dictData, bRet)
            if(dictData.err=="ok")then
                m_lastIntegral = m_astrologyInfo == nil and tonumber(dictData.ret.integral) or tonumber(m_astrologyInfo.integral)
                
                m_astrologyInfo = dictData.ret
                table.hcopy(dictData.ret, m_astrologyInfo)
                
                local currentMaxPrize = 0
                require "db/DB_Astrology"
                dbAstrology = DB_Astrology.getDataById(tonumber(m_astrologyInfo.prize_level))
                local starArray =  lua_string_split(dbAstrology.star_arr,",")
                for i=1,#starArray do
                    --print("upgrade:",starArray[i])
                    if(tonumber(starArray[i])<=tonumber(m_astrologyInfo.integral))then
                        currentMaxPrize = i
                    end
                end
                
                local leftPrize = currentMaxPrize-tonumber(m_astrologyInfo.prize_step)
                
                print("getShowRewardButton1:",getShowRewardButton())
                if(getShowRewardButton()~=nil )then
                    getShowRewardButton():removeChildByTag(7711,true)
                    if(leftPrize>0)then
                        print("getShowRewardButton:",getShowRewardButton(),getShowRewardButton():getTag())
                        local alertSprite = CCSprite:create("images/common/tip_2.png")
                        alertSprite:setAnchorPoint(ccp(0.5,0.5))
                        alertSprite:setPosition(ccp(getShowRewardButton():getContentSize().width*0.9,getShowRewardButton():getContentSize().height*0.9))
                        getShowRewardButton():addChild(alertSprite,1,7711)
                        
                        local leftPrizeNumberLabel = CCLabelTTF:create("" .. leftPrize,g_sFontName,alertSprite:getContentSize().height*0.6)
                        leftPrizeNumberLabel:setAnchorPoint(ccp(0.5,0.5))
                        leftPrizeNumberLabel:setPosition(alertSprite:getContentSize().width*0.5,alertSprite:getContentSize().height*0.45)
                        alertSprite:addChild(leftPrizeNumberLabel)
                    end
                end

                print("m_astrologyInfo.divi_times:",m_astrologyInfo.divi_times,m_astrologyInfo.prize_step,currentMaxPrize,leftPrize)
                if(tonumber(m_astrologyInfo.divi_times)>=astroTime and leftPrize<=0)then
                    require "script/ui/main/MainBaseLayer"
                    MainBaseLayer.showAstroAlert(false)
                else
                    require "script/ui/main/MainBaseLayer"
                    MainBaseLayer.showAstroAlert(true)
                end
            end
        end
        RequestCenter.divine_getDiviInfo(getAstrologyInfoCallBack,CCArray:create())
        return false
    else
    --m_astrologyInfo.prize_level,m_astrologyInfo.integral,m_astrologyInfo.prize_step

        local currentMaxPrize = 0
        require "db/DB_Astrology"
        dbAstrology = DB_Astrology.getDataById(tonumber(m_astrologyInfo.prize_level))
        local starArray =  lua_string_split(dbAstrology.star_arr,",")
        for i=1,#starArray do
            --print("upgrade:",starArray[i])
            if(tonumber(starArray[i])<=tonumber(m_astrologyInfo.integral))then
                currentMaxPrize = i
            end
        end

        local leftPrize = currentMaxPrize-tonumber(m_astrologyInfo.prize_step)

        print("getShowRewardButton1:",getShowRewardButton())
        if(getShowRewardButton()~=nil )then
            getShowRewardButton():removeChildByTag(7711,true)
            if(leftPrize>0)then
                print("getShowRewardButton:",getShowRewardButton(),getShowRewardButton():getTag())
                local alertSprite = CCSprite:create("images/common/tip_2.png")
                alertSprite:setAnchorPoint(ccp(0.5,0.5))
                alertSprite:setPosition(ccp(getShowRewardButton():getContentSize().width*0.9,getShowRewardButton():getContentSize().height*0.9))
                getShowRewardButton():addChild(alertSprite,1,7711)
                
                local leftPrizeNumberLabel = CCLabelTTF:create("" .. leftPrize,g_sFontName,alertSprite:getContentSize().height*0.6)
                leftPrizeNumberLabel:setAnchorPoint(ccp(0.5,0.5))
                leftPrizeNumberLabel:setPosition(alertSprite:getContentSize().width*0.5,alertSprite:getContentSize().height*0.45)
                alertSprite:addChild(leftPrizeNumberLabel)
            end
        end

        print("m_astrologyInfo.divi_times:",m_astrologyInfo.divi_times,m_astrologyInfo.prize_step,currentMaxPrize,leftPrize)
        if(tonumber(m_astrologyInfo.divi_times)>=astroTime and leftPrize<=0)then
            require "script/ui/main/MainBaseLayer"
            MainBaseLayer.showAstroAlert(false)
            return true
        else
            require "script/ui/main/MainBaseLayer"
            MainBaseLayer.showAstroAlert(true)
            return false
        end

    end
end

-- 无连接中loading 获得占星数据
function getAstrologyInfoNoLoading( ... )
    function getAstrologyInfoCallBack(cbFlag, dictData, bRet)
        if(dictData.err=="ok")then
            m_lastIntegral = m_astrologyInfo == nil and tonumber(dictData.ret.integral) or tonumber(m_astrologyInfo.integral)
            
            m_astrologyInfo = dictData.ret
            table.hcopy(dictData.ret, m_astrologyInfo)
            
            local currentMaxPrize = 0
            require "db/DB_Astrology"
            dbAstrology = DB_Astrology.getDataById(tonumber(m_astrologyInfo.prize_level))
            local starArray =  lua_string_split(dbAstrology.star_arr,",")
            for i=1,#starArray do
                --print("upgrade:",starArray[i])
                if(tonumber(starArray[i])<=tonumber(m_astrologyInfo.integral))then
                    currentMaxPrize = i
                end
            end
            
            local leftPrize = currentMaxPrize-tonumber(m_astrologyInfo.prize_step)
            
            print("getShowRewardButton1:",getShowRewardButton())
            if(getShowRewardButton()~=nil )then
                getShowRewardButton():removeChildByTag(7711,true)
                if(leftPrize>0)then
                    print("getShowRewardButton:",getShowRewardButton(),getShowRewardButton():getTag())
                    local alertSprite = CCSprite:create("images/common/tip_2.png")
                    alertSprite:setAnchorPoint(ccp(0.5,0.5))
                    alertSprite:setPosition(ccp(getShowRewardButton():getContentSize().width*0.9,getShowRewardButton():getContentSize().height*0.9))
                    getShowRewardButton():addChild(alertSprite,1,7711)
                    
                    local leftPrizeNumberLabel = CCLabelTTF:create("" .. leftPrize,g_sFontName,alertSprite:getContentSize().height*0.6)
                    leftPrizeNumberLabel:setAnchorPoint(ccp(0.5,0.5))
                    leftPrizeNumberLabel:setPosition(alertSprite:getContentSize().width*0.5,alertSprite:getContentSize().height*0.45)
                    alertSprite:addChild(leftPrizeNumberLabel)
                end
            end

            print("m_astrologyInfo.divi_times:",m_astrologyInfo.divi_times,m_astrologyInfo.prize_step,currentMaxPrize,leftPrize)
            if(tonumber(m_astrologyInfo.divi_times)>=astroTime and leftPrize<=0)then
                require "script/ui/main/MainBaseLayer"
                MainBaseLayer.showAstroAlert(false)
            else
                require "script/ui/main/MainBaseLayer"
                MainBaseLayer.showAstroAlert(true)
            end
        end
    end
    PreRequest.divine_getDiviInfo_noLoading(getAstrologyInfoCallBack,CCArray:create())
end

function loadDivinInfo()
    
    getAstrologyInfo()
    
    require "db/DB_Astrology"
    local dbAstrology = DB_Astrology.getDataById(tonumber(m_astrologyInfo.prize_level))
    local rewardStarArray = lua_string_split(dbAstrology.target_reward_stars,",")
    local currentRewardStar
    if(tonumber(m_astrologyInfo.target_finish_num)+1<=#rewardStarArray) then
        --print_table("rewardStarArray",rewardStarArray)
        print("rewardStarArray[tonumber(m_astrologyInfo.target_finish_num)+1]",rewardStarArray[tonumber(m_astrologyInfo.target_finish_num)+1])
        --print("rewardStarArray[m_astrologyInfo.target_finish_num]:",rewardStarArray[tonumber(m_astrologyInfo.target_finish_num)+1])
        currentRewardStar = tonumber(lua_string_split(rewardStarArray[tonumber(m_astrologyInfo.target_finish_num)+1],"|")[2])
    end
    currentRewardStar = currentRewardStar==nil and 0 or currentRewardStar
    
    --更新数值
    m_rewardStarLabel:setString(currentRewardStar .. "")
    --[[
    m_rewardStarLabel:removeFromParentAndCleanup(true)
    m_rewardStarLabel = CCRenderLabel:create(currentRewardStar .. "", g_sFontName, 35, 2, ccc3( 0x00, 0x00, 0x00), type_stroke)
    m_rewardStarLabel:setColor(ccc3(0x00,0xeb,0x21))
    m_rewardStarLabel:setPosition(layerSize.width*0.58,layerSize.height*0.925)
    m_astrologyLayer:addChild(m_rewardStarLabel)
    --]]
    astroTimesLabel:removeFromParentAndCleanup(true)
    astroTimesLabel = LuaCCLabel.createShadowLabel(astroTime-tonumber(m_astrologyInfo.divi_times) .. "/" .. astroTime,g_sFontName,24)
    astroTimesLabel:setPosition(layerSize.width*0.32,layerSize.height*0.08)
    astroTimesLabel:setAnchorPoint(ccp(0,0.5))
    m_astrologyLayer:addChild(astroTimesLabel)
    
    freeTimesLabel:removeFromParentAndCleanup(true)
    freeTimesLabel = LuaCCLabel.createShadowLabel("" .. m_astrologyInfo.free_refresh_num,g_sFontName,24)
    freeTimesLabel:setPosition(layerSize.width*0.32,layerSize.height*0.04)
    freeTimesLabel:setAnchorPoint(ccp(0,0.5))
    freeTimesLabel:setColor(ccc3(0x00,0xeb,0x21))
    m_astrologyLayer:addChild(freeTimesLabel)
    
    currentStarLabel:removeFromParentAndCleanup(true)
    currentStarLabel = CCRenderLabel:create("" .. m_astrologyInfo.integral, g_sFontName, 24, 2, ccc3( 0x00, 0x06, 0x7c), type_stroke)
    currentStarLabel:setPosition(layerSize.width*0.24,layerSize.height*0.49)
    m_astrologyLayer:addChild(currentStarLabel)
    
    require "script/model/user/UserModel"
    local userInfo = UserModel.getUserInfo()
    if userInfo == nil then
        return
    end
    

    if( tonumber(m_astrologyInfo.integral) >=130 ) then
        -- added by zhz ,给台湾版本发送
        -- local star_arr = lua_string_split(dbAstrology.star_arr,",")
        -- local lastStar=  star_arr[ #star_arr]
        -- require "script/ui/showOff/ShowOffUtil"
        -- ShowOffUtil.sendShowOffByType( 5 )
    end
    
    m_silverLabel:setString(string.convertSilverUtilByInternational(userInfo.silver_num))  -- modified by yangrui at 2015-12-03
    
    m_goldLabel:setString(tostring(userInfo.gold_num))
    
    --更新进度条
    local barSize = m_bar:getTexture():getContentSize()
    
    local function updateBarLine()
        --print("m_lastIntegral:",m_lastIntegral)
        if(_isOneKey==false)then
            local integral = tonumber(m_lastIntegral)>dbAstrology.star_max and dbAstrology.star_max or tonumber(m_lastIntegral)
            if(m_astrologyInfo~=nil and m_lastIntegral>tonumber(m_astrologyInfo.integral))then
                m_bar:stopActionByTag(8909)
                m_lastIntegral = tonumber(m_astrologyInfo.integral)
                m_bar:setTextureRect(CCRectMake(0,0,barSize.width*(integral/dbAstrology.star_max),barSize.height))
                m_barEffectLayer:setViewSize(CCSizeMake(barSize.width*(integral/dbAstrology.star_max),barSize.height*1.2))
            else
                m_lastIntegral = m_lastIntegral + 1
                m_bar:setTextureRect(CCRectMake(0,0,barSize.width*(integral/dbAstrology.star_max),barSize.height))
                m_barEffectLayer:setViewSize(CCSizeMake(barSize.width*(integral/dbAstrology.star_max),barSize.height*1.2))
            end
        else
            m_bar:setTextureRect(CCRectMake(0,0,barSize.width,barSize.height))
            m_barEffectLayer:setViewSize(CCSizeMake(barSize.width,barSize.height*1.2))
        end
    end
    
    local barAction = schedule(m_bar,updateBarLine,1/30)
    barAction:setTag(8909)
    
    
    --更新图标
    require "db/DB_Aster"
    local startX = layerSize.width*0.12
    local startY = layerSize.height*0.195
    local intervalX = layerSize.width*0.19
    for i=1,5 do
        m_astrologyMenu:removeChildByTag(1000+i,true)
        local astroBtn 
        local starId = m_astrologyInfo.va_divine.current[i]
        if(starId~=nil)then
            local star = DB_Aster.getDataById(tonumber(starId))
            --print("-----------star.icon:",star.id,star.icon)
            astroBtn = LuaCC.create9ScaleMenuItemWithSpriteName("images/astrology/astro_btn_n.png","images/astrology/astro_btn_n.png",CCSizeMake(105,116),IMG_PATH .. "star/" .. star.icon)
        else
            astroBtn = LuaCC.create9ScaleMenuItem("images/astrology/astro_btn_n.png","images/astrology/astro_btn_n.png",CCSizeMake(105,116),"")
        end
        astroBtn:setPosition(MainScene.getMenuPositionInTruePoint(startX+(i-1)*intervalX,startY))
        astroBtn:setAnchorPoint(ccp(0.5,0.5))
        m_astrologyMenu:addChild(astroBtn)
        astroBtn:setTag(1000+i)
        
        astroBtn:registerScriptTapHandler(astroClick)
    end
    
    --判断是否有可选星
    for i=1,#m_astrologyInfo.va_divine.target do
        if(m_astrologyInfo.va_divine.lighted[i]==nil or tonumber(m_astrologyInfo.va_divine.lighted[i])==0)then
            for j=1,5 do
                local starId = m_astrologyInfo.va_divine.current[j]
                if(starId~=nil and starId == m_astrologyInfo.va_divine.target[i] and m_astrologyMenu:getChildByTag(1000+j)~=nil)then
                    --有目标星座
                    haveTarget = true
                    
                    local m_barEffect = CCLayerSprite:layerSpriteWithName(CCString:create("images/base/effect/astro/zhanxing"), -1,CCString:create(""));
                    m_barEffect:setAnchorPoint(ccp(0.5, 0.5));
                    m_barEffect:setPosition(m_astrologyMenu:getChildByTag(1000+j):getContentSize().width*0.5,m_astrologyMenu:getChildByTag(1000+j):getContentSize().height*0.5);
                    m_astrologyMenu:getChildByTag(1000+j):addChild(m_barEffect,1,100);
                end
            end
        end
    end
    
    
    
    for i=1,#m_astrologyInfo.va_divine.target do
        local positionSprite = m_astrologyLayer:getChildByTag(112):getChildByTag(2000+i)
        positionSprite:removeAllChildrenWithCleanup(true)
        
        local isLight = false
        if(m_astrologyInfo.va_divine.lighted~=nil and m_astrologyInfo.va_divine.lighted[i]~=nil and tonumber(m_astrologyInfo.va_divine.lighted[i])~=0)then
            isLight = true
        end
        
        if(isLight)then
            local texture = CCTextureCache:sharedTextureCache():addImage("images/astrology/astro_btn_l.png")
            positionSprite:setTexture(texture)
            
            local m_barEffect = CCLayerSprite:layerSpriteWithName(CCString:create("images/base/effect/astro/zhanxing"), -1,CCString:create(""));
            m_barEffect:setAnchorPoint(ccp(0.5, 0.5));
            m_barEffect:setPosition(positionSprite:getContentSize().width*0.5,positionSprite:getContentSize().height*0.5);
            positionSprite:addChild(m_barEffect,1,711);
        else
            local texture = CCTextureCache:sharedTextureCache():addImage("images/astrology/astro_btn_n.png")
            positionSprite:setTexture(texture)
        end
        
        local starId = m_astrologyInfo.va_divine.target[i]
        if(starId~=nil)then
            local star = DB_Aster.getDataById(tonumber(starId))
            --print("-----------star.icon:",star.id,star.icon)
            local starSprite = CCSprite:create(IMG_PATH .. "star/" .. star.icon)
            starSprite:setAnchorPoint(ccp(0.5,0.5))
            starSprite:setPosition(positionSprite:getContentSize().width/2,positionSprite:getContentSize().height/2)
            positionSprite:addChild(starSprite,1,1310)
            
            if(m_isAllStarSelected==true)then
                starSprite:setOpacity(0)
                starSprite:runAction(CCFadeIn:create(0.6))
                m_isAllStarSelected = false
            end
        end
    end

    -- 新手 add by licong
    if(buttonTag ~= nil)then
        if( (buttonTag-1000) == 1 )then
            local seq = CCSequence:createWithTwoActions(CCDelayTime:create(0.3),CCCallFunc:create(function ( ... )
                addGuideAstrologyGuide7()
            end))
            m_astrologyLayer:runAction(seq)
        end
        if( (buttonTag-1000) == 2 )then
            local seq = CCSequence:createWithTwoActions(CCDelayTime:create(0.3),CCCallFunc:create(function ( ... )
                addGuideAstrologyGuide4()
            end))
            m_astrologyLayer:runAction(seq)
        end
        if( (buttonTag-1000) == 3 )then
            local seq = CCSequence:createWithTwoActions(CCDelayTime:create(0.3),CCCallFunc:create(function ( ... )
                addGuideAstrologyGuide6()
            end))
            m_astrologyLayer:runAction(seq)
        end
        if( (buttonTag-1000) == 4 )then
            local seq = CCSequence:createWithTwoActions(CCDelayTime:create(0.3),CCCallFunc:create(function ( ... )
                addGuideAstrologyGuide5()
            end))
            m_astrologyLayer:runAction(seq)
        end
    end
    -------------------------------------
end

function initAstrologyLayer()
    require "script/libs/LuaCCLabel"
    
    layerSize = m_astrologyLayer:getContentSize()
    
    local astroTimesDescLabel = LuaCCLabel.createShadowLabel(GetLocalizeStringBy("key_2175"),g_sFontName,24)
    astroTimesDescLabel:setPosition(layerSize.width*0.06,layerSize.height*0.08)
    astroTimesDescLabel:setAnchorPoint(ccp(0,0.5))
    m_astrologyLayer:addChild(astroTimesDescLabel)
    
    local freeTimesDescLabel = LuaCCLabel.createShadowLabel(GetLocalizeStringBy("key_2726"),g_sFontName,24)
    freeTimesDescLabel:setPosition(layerSize.width*0.06,layerSize.height*0.04)
    freeTimesDescLabel:setAnchorPoint(ccp(0,0.5))
    freeTimesDescLabel:setColor(ccc3(0x00,0xeb,0x21))
    m_astrologyLayer:addChild(freeTimesDescLabel)
    
    astroTimesLabel = LuaCCLabel.createShadowLabel("0/" .. astroTime,g_sFontName,24)
    astroTimesLabel:setPosition(layerSize.width*0.32,layerSize.height*0.08)
    astroTimesLabel:setAnchorPoint(ccp(0,0.5))
    m_astrologyLayer:addChild(astroTimesLabel)
    
    freeTimesLabel = LuaCCLabel.createShadowLabel("0",g_sFontName,24)
    freeTimesLabel:setPosition(layerSize.width*0.32,layerSize.height*0.04)
    freeTimesLabel:setAnchorPoint(ccp(0,0.5))
    freeTimesLabel:setColor(ccc3(0x00,0xeb,0x21))
    m_astrologyLayer:addChild(freeTimesLabel)
    
    require "script/libs/LuaCC"
    m_refreshButton = LuaCC.create9ScaleMenuItem("images/common/btn/btn1_d.png","images/common/btn/btn1_n.png",CCSizeMake(150,73)," ",ccc3(255,222,0))
    m_refreshButton:setAnchorPoint(ccp(0.5,0.5))
    m_refreshButton:setPosition(MainScene.getMenuPositionInTruePoint(layerSize.width*0.55,layerSize.height*0.07))
    m_refreshButton:registerScriptTapHandler(refreshClick)
    
    local normalLabel = CCRenderLabel:create(GetLocalizeStringBy("key_1463"), g_sFontPangWa, 32, 1.5, ccc3(0,0,0), type_stroke)
    normalLabel:setColor(ccc3(255,222,0))
    normalLabel:setAnchorPoint(ccp(0.5, 1))
    normalLabel:setPosition((m_refreshButton:getContentSize().width)*0.5,(m_refreshButton:getContentSize().height)*0.8)
    m_refreshButton:addChild(normalLabel,1)
    
    -- local goldIcon = CCSprite:create("images/pet/petfeed/gold.png")
    -- goldIcon:setAnchorPoint(ccp(0.5,0.5))
    -- goldIcon:setPosition(m_refreshButton:getContentSize().width*0.6,m_refreshButton:getContentSize().height*0.5)
    -- m_refreshButton:addChild(goldIcon)
    
    -- local goldLabel = CCRenderLabel:create("10", g_sFontName, 35, 2, ccc3( 0x00, 0x0c, 0x04), type_stroke)
    -- goldLabel:setColor(ccc3(0xfe,0xdb,0x1c))
    -- goldLabel:setPosition(m_refreshButton:getContentSize().width*0.65,m_refreshButton:getContentSize().height*0.75)
    -- m_refreshButton:addChild(goldLabel)
    
    m_astrologyMenu = CCMenu:create()
    m_astrologyMenu:addChild(m_refreshButton)
    m_astrologyMenu:setPosition(0,0)
    m_astrologyMenu:setAnchorPoint(ccp(0,0))
    
    m_astrologyLayer:addChild(m_astrologyMenu,1)

    --add by lichenyang 占星消耗物品
    require "db/DB_Normal_config"
    require "script/utils/BaseUI"
    local normalInfo = DB_Normal_config.getDataById(1)
    local cost_info  = lua_string_split(normalInfo.astrologyItem, "|")
    m_costItemTid    = cost_info[1]
    m_cost_num       = cost_info[2]
    havaCostNum      = ItemUtil.getCacheItemNumBy(tonumber(m_costItemTid))
    local nodes      = {}
    
    nodes[1]         = CCLabelTTF:create(GetLocalizeStringBy("key_2515"), g_sFontName, 24)
    nodes[2]         = CCSprite:create("images/astrology/cost_item.png")
    nodes[3]         = CCLabelTTF:create(m_cost_num .. GetLocalizeStringBy("key_2178"), g_sFontName, 24)
    nodes[4]         = CCSprite:create("images/common/gold.png")
    nodes[5]         = CCLabelTTF:create("10", g_sFontName, 24)

    nodes[1]:setColor(ccc3(0xff,0xe4,0x00))
    nodes[3]:setColor(ccc3(0xff,0xe4,0x00))
    nodes[5]:setColor(ccc3(0xff,0xe4,0x00))

    local spendExplain  = BaseUI.createHorizontalNode(nodes)
    spendExplain:setAnchorPoint(ccp(0.5, 0.5))
    spendExplain:setPosition(layerSize.width*0.83,layerSize.height*0.09)
    m_astrologyLayer:addChild(spendExplain)

    local havaNodos = {}
    havaNodos[1] = CCLabelTTF:create(GetLocalizeStringBy("key_1337"), g_sFontName, 24)
    havaNodos[2] = CCLabelTTF:create("" .. havaCostNum, g_sFontName, 24)
    havaNodos[3] = CCLabelTTF:create(")", g_sFontName, 24)
    havaNodos[1]:setColor(ccc3(0xff,0xe4,0x00))
    havaNodos[2]:setColor(ccc3(0x00,0xff,0x18))
    havaNodos[3]:setColor(ccc3(0xff,0xe4,0x00))

    m_havaLabel  = BaseUI.createHorizontalNode(havaNodos)
    m_havaLabel:setAnchorPoint(ccp(0.5, 0.5))
    m_havaLabel:setPosition(layerSize.width*0.83,layerSize.height*0.05)
    m_astrologyLayer:addChild(m_havaLabel)

    
    local btnbg = CCScale9Sprite:create(CCRectMake(25, 25, 20, 20),IMG_PATH .. "astro_btnbg.png")
    btnbg:setPreferredSize(CCSizeMake(layerSize.width*0.98,layerSize.height*0.17))
    btnbg:setAnchorPoint(ccp(0,0))
    btnbg:setPosition(layerSize.width*0.01,layerSize.height*0.12)
    btnbg:setScale(1/MainScene.elementScale)
    m_astrologyLayer:addChild(btnbg)
    
    local labelbg = CCScale9Sprite:create(CCRectMake(25, 15, 20, 10),IMG_PATH .. "astro_labelbg.png")
    labelbg:setPreferredSize(CCSizeMake(layerSize.width*0.27,layerSize.height*0.05))
    labelbg:setAnchorPoint(ccp(0.5,0.5))
    labelbg:setPosition(layerSize.width*0.5,layerSize.height*0.288)
    labelbg:setScale(1/MainScene.elementScale)
    m_astrologyLayer:addChild(labelbg)
    
    local buttonTitleLabel = LuaCCLabel.createShadowLabel(GetLocalizeStringBy("key_2960"),g_sFontPangWa,24)
    buttonTitleLabel:setPosition(layerSize.width*0.5,layerSize.height*0.288)
    buttonTitleLabel:setAnchorPoint(ccp(0.5,0.5))
    buttonTitleLabel:setColor(ccc3(0xff,0xf6,0x00))
    m_astrologyLayer:addChild(buttonTitleLabel)
    
    local startX = layerSize.width*0.12
    local startY = layerSize.height*0.195
    local intervalX = layerSize.width*0.19
    for i=1,5 do
        local astroBtn = LuaCC.create9ScaleMenuItemWithSpriteName("images/astrology/astro_btn_n.png","images/astrology/astro_btn_n.png",CCSizeMake(105,116),IMG_PATH .. "astro_btnbg.png")
        astroBtn:setPosition(MainScene.getMenuPositionInTruePoint(startX+(i-1)*intervalX,startY))
        astroBtn:setAnchorPoint(ccp(0.5,0.5))
        m_astrologyMenu:addChild(astroBtn)
        astroBtn:setTag(1000+i)
        
        astroBtn:registerScriptTapHandler(astroClick)
    end
    
    local astroBg = CCSprite:create(IMG_PATH .. "astro_bg.png")
    astroBg:setAnchorPoint(ccp(0.5,0))
    astroBg:setPosition(layerSize.width*0.5,layerSize.height*0.32)
    astroBg:setScale(MainScene.bgScale/MainScene.elementScale)
    m_astrologyLayer:addChild(astroBg,0)
    
    local spliterSprite = CCSprite:create("images/common/separator_bottom.png")
    spliterSprite:setPosition(ccp(0,layerSize.height*0.32))
    spliterSprite:setAnchorPoint(ccp(0,0))
    spliterSprite:setScale(g_fScaleX/MainScene.elementScale)
    m_astrologyLayer:addChild(spliterSprite)
    
    local descButton = LuaCC.create9ScaleMenuItem("images/common/btn/btn1_d.png","images/common/btn/btn1_n.png",CCSizeMake(210,73),GetLocalizeStringBy("llp_503"),ccc3(255,222,0))
    descButton:setAnchorPoint(ccp(0.5,0.5))
    descButton:setPosition(MainScene.getMenuPositionInTruePoint(layerSize.width*0.8,layerSize.height*0.39))
    m_astrologyMenu:addChild(descButton)
    descButton:registerScriptTapHandler(resetAction)
    
    local rewardButton = LuaCC.create9ScaleMenuItem("images/common/btn/btn1_d.png","images/common/btn/btn1_n.png",CCSizeMake(210,73),GetLocalizeStringBy("key_3401"),ccc3(255,222,0))
    rewardButton:setAnchorPoint(ccp(0.5,0.5))
    rewardButton:setPosition(MainScene.getMenuPositionInTruePoint(layerSize.width*0.2,layerSize.height*0.39)) 
    m_astrologyMenu:addChild(rewardButton,1,1900)
    rewardButton:registerScriptTapHandler(showReward)

    local desButton = CCMenuItemImage:create("images/recycle/btn/btn_explanation_h.png","images/recycle/btn/btn_explanation_n.png")
    desButton:registerScriptTapHandler(showDesc)
    desButton:setAnchorPoint(ccp(0.5,0.5))
    desButton:setPosition(MainScene.getMenuPositionInTruePoint(layerSize.width*0.1,layerSize.height*0.83))
    m_astrologyMenu:addChild(desButton)
    
    local currentStarDescLabel = CCRenderLabel:create(GetLocalizeStringBy("key_2138"), g_sFontName, 24, 2, ccc3( 0x00, 0x06, 0x7c), type_stroke)
    currentStarDescLabel:setPosition(layerSize.width*0.06,layerSize.height*0.49)
    m_astrologyLayer:addChild(currentStarDescLabel)
    
    currentStarLabel = CCRenderLabel:create("0", g_sFontName, 24, 2, ccc3( 0x00, 0x06, 0x7c), type_stroke)
    currentStarLabel:setPosition(layerSize.width*0.24,layerSize.height*0.49)
    m_astrologyLayer:addChild(currentStarLabel)
    
    local barBg = CCSprite:create(IMG_PATH .. "astro_barbg.png")
    barBg:setAnchorPoint(ccp(0.5,0.5))
    barBg:setPosition(layerSize.width*0.5,layerSize.height*0.54)
    m_astrologyLayer:addChild(barBg)
    
    m_bar = CCSprite:create(IMG_PATH .. "astro_bar.png")
    m_bar:setAnchorPoint(ccp(0,0.5))
    m_bar:setPosition(barBg:getContentSize().width*0.05,barBg:getContentSize().height*0.5)
    barBg:addChild(m_bar)
    
     m_barEffectLayer = CCScrollView:create()
    --scrollView:setTouchPriority(-410)
	m_barEffectLayer:setContentSize(CCSizeMake(m_bar:getContentSize().width,m_bar:getContentSize().height*1.2))
	m_barEffectLayer:setViewSize(CCSizeMake(m_bar:getContentSize().width,m_bar:getContentSize().height*1.2))
    m_barEffectLayer:setAnchorPoint(ccp(0,0))
	m_barEffectLayer:setPosition(ccp(0,0))
    m_barEffectLayer:setTouchEnabled(false)
    m_bar:addChild(m_barEffectLayer,1);
    
    m_barEffect = CCLayerSprite:layerSpriteWithName(CCString:create("images/base/effect/astro/zhanxinglizi"), -1,CCString:create(""));
    m_barEffect:setAnchorPoint(ccp(0, 0.5));
    m_barEffect:setPosition(m_bar:getContentSize().width*0.45,m_bar:getContentSize().height*0.5);
    m_barEffectLayer:addChild(m_barEffect,1);
    
    local astroLineBg = CCSprite:create(IMG_PATH .. "astro_line_l.png")
    astroLineBg:setAnchorPoint(ccp(0.5,0.5))
    astroLineBg:setPosition(layerSize.width*0.5,layerSize.height*0.73)
    m_astrologyLayer:addChild(astroLineBg,0,112)
    
     m_astroPos1 = CCSprite:create("images/astrology/astro_btn_l.png")
    m_astroPos1:setPosition(-10,-25)
    m_astroPos1:setAnchorPoint(ccp(0.5,0.5))
    m_astroPos1:setTag(2001)
    astroLineBg:addChild(m_astroPos1)
    
     m_astroPos2 = CCSprite:create("images/astrology/astro_btn_l.png")
    m_astroPos2:setPosition(140,110)
    m_astroPos2:setAnchorPoint(ccp(0.5,0.5))
    m_astroPos2:setTag(2002)
    astroLineBg:addChild(m_astroPos2)
    
     m_astroPos3 = CCSprite:create("images/astrology/astro_btn_l.png")
    m_astroPos3:setPosition(300,-12)
    m_astroPos3:setAnchorPoint(ccp(0.5,0.5))
    m_astroPos3:setTag(2003)
    astroLineBg:addChild(m_astroPos3)
    
     m_astroPos4 = CCSprite:create("images/astrology/astro_btn_l.png")
    m_astroPos4:setPosition(420,123)
    m_astroPos4:setAnchorPoint(ccp(0.5,0.5))
    m_astroPos4:setTag(2004)
    astroLineBg:addChild(m_astroPos4)
    
    local topBg = CCSprite:create("images/hero/avatar_attr_bg.png")
    topBg:setAnchorPoint(ccp(0,1))
    topBg:setPosition(0,layerSize.height)
    topBg:setScale(g_fScaleX/MainScene.elementScale)
    m_astrologyLayer:addChild(topBg)
    
    local powerDescLabel = CCSprite:create("images/common/fight_value.png")
    powerDescLabel:setAnchorPoint(ccp(0.5,0.5))
    powerDescLabel:setPosition(topBg:getContentSize().width*0.13,topBg:getContentSize().height*0.43)
    topBg:addChild(powerDescLabel)
    
    require "script/model/user/UserModel"
    local userInfo = UserModel.getUserInfo()
    if userInfo == nil then
        return
    end
    
     m_powerLabel = CCRenderLabel:create("" .. UserModel.getFightForceValue(), g_sFontName, 23, 1.5, ccc3( 0x00, 0x00, 0x00), type_stroke)
    m_powerLabel:setColor(ccc3(0xff, 0xf6, 0x00))
    --m_powerLabel:setAnchorPoint(ccp(0,0.5))
    m_powerLabel:setPosition(topBg:getContentSize().width*0.23,topBg:getContentSize().height*0.66)
    topBg:addChild(m_powerLabel)
    
    m_silverLabel = CCLabelTTF:create(string.convertSilverUtilByInternational(userInfo.silver_num),g_sFontName,18)  -- modified by yangrui at 2015-12-03
    m_silverLabel:setColor(ccc3(0xe5,0xf9,0xff))
    m_silverLabel:setAnchorPoint(ccp(0,0.5))
    m_silverLabel:setPosition(topBg:getContentSize().width*0.61,topBg:getContentSize().height*0.43)
    topBg:addChild(m_silverLabel)
    
     m_goldLabel = CCLabelTTF:create(tostring(userInfo.gold_num),g_sFontName,18)
    m_goldLabel:setColor(ccc3(0xff,0xe2,0x44))
    m_goldLabel:setAnchorPoint(ccp(0,0.5))
    m_goldLabel:setPosition(topBg:getContentSize().width*0.82,topBg:getContentSize().height*0.43)
    topBg:addChild(m_goldLabel)
    
    --[[
    local currentStarDescLabel = CCRenderLabel:create(GetLocalizeStringBy("key_1818"), g_sFontName, 24, 2, ccc3( 0x00, 0x06, 0x7c), type_stroke)
    currentStarDescLabel:setColor(ccc3(0xe7,0xb7,0xfe))
    currentStarDescLabel:setPosition(layerSize.width*0.02,layerSize.height*0.92)
    m_astrologyLayer:addChild(currentStarDescLabel)
    
    local rewardStarDescLabel = CCRenderLabel:create(GetLocalizeStringBy("key_1662"), g_sFontName, 24, 2, ccc3( 0x00, 0x06, 0x7c), type_stroke)
    rewardStarDescLabel:setColor(ccc3(0xff,0x6b,0xe5))
    rewardStarDescLabel:setPosition(layerSize.width*0.02,layerSize.height*0.87)
    m_astrologyLayer:addChild(rewardStarDescLabel)
     
     --]]
    
    local currentStarDescLabel = CCSprite:create(IMG_PATH .. "astro_starlabel.png")
    currentStarDescLabel:setPosition(layerSize.width*0.02,layerSize.height*0.88)
    m_astrologyLayer:addChild(currentStarDescLabel)
    
    --m_rewardStarLabel = CCRenderLabel:create("000", g_sFontName, 24, 2, ccc3( 0x00, 0x06, 0x7c), type_stroke)
    m_rewardStarLabel = CCRenderLabel:create("0", g_sFontName, 35, 2, ccc3( 0x00, 0x00, 0x00), type_stroke)
    m_rewardStarLabel:setColor(ccc3(0x00,0xeb,0x21))
    m_rewardStarLabel:setAnchorPoint(ccp(0.5,0.5))
    m_rewardStarLabel:setPosition(currentStarDescLabel:getContentSize().width*0.74,currentStarDescLabel:getContentSize().height*0.45)
    currentStarDescLabel:addChild(m_rewardStarLabel)
    
    if(m_astrologyInfo~=nil)then
        loadDivinInfo()
    end
end

-- 获得占星层
function createAstrologyLayer()
    _goldCostNum = 0
    _type = 0
    _isOneKey = false
    --是否有目标星座
    haveTarget = false

    m_isBusy = false
    --判断是否开启
    require "DataCache"
    if(DataCache.getSwitchNodeState(ksSwitchStar)~=true)then
        require "script/ui/tip/AnimationTip"
        AnimationTip.showTip( GetLocalizeStringBy("key_2762"))
        return nil
    end
    
    m_astrologyLayer = MainScene.createBaseLayer("images/main/module_bg.png",true,false,true)
    m_astrologyLayer:retain()
    
    initAstrologyLayer()
    --if(m_astrologyInfo == nil)then
    m_astrologyInfo = nil
        RequestCenter.divine_getDiviInfo(getDiviInfoCallBack,CCArray:create())
    --end
    --[[
    require "script/libs/LuaCCLabel"
    local richTextInfo = {}
    richTextInfo.width = 513
    richTextInfo[1] = {content=GetLocalizeStringBy("key_1115"),ntype="label",color=ccc3(0,222,0),fontSize=23}
    richTextInfo[2] = {content=GetLocalizeStringBy("key_2308"),ntype="label",color=ccc3(0,111,255),tapFunc=showDesc,fontSize=23}
    richTextInfo[3] = {content=GetLocalizeStringBy("key_1989"),ntype="label",color=ccc3(255,111,111),fontSize=23}
    richTextInfo[4] = {content="1111银币",ntype="label",color=ccc3(0,111,255),tapFunc=showDesc,fontSize=23}
    local richTextLayer = LuaCCLabel.createRichText(richTextInfo)
    richTextLayer:setPosition(m_astrologyLayer:getContentSize().width*0,m_astrologyLayer:getContentSize().height/2)
    m_astrologyLayer:addChild(richTextLayer,9999)
    --]]
    m_astrologyLayer:release()

    local seq = CCSequence:createWithTwoActions(CCDelayTime:create(0.3),CCCallFunc:create(function ( ... )
            addGuideAstrologyGuide2()
        end))
    m_astrologyLayer:runAction(seq)

    return m_astrologyLayer
end

function getScene()
    
end

function exitAstro()
    m_astrologyLayer = nil
    m_astrologyMenu = nil
end

-- 退出场景，释放不必要资源
function release (...) 

end


function updateHavaCostNode( ... )
    havaCostNum = tonumber(havaCostNum) - tonumber(m_cost_num)
    if(m_havaLabel == nil) then
        return
    end
    m_havaLabel:removeFromParentAndCleanup(true)
    m_havaLabel = nil


    local havaNodos = {}
    havaNodos[1] = CCLabelTTF:create(GetLocalizeStringBy("key_1337"), g_sFontName, 24)
    havaNodos[2] = CCLabelTTF:create("" .. havaCostNum, g_sFontName, 24)
    havaNodos[3] = CCLabelTTF:create(")", g_sFontName, 24)
    havaNodos[1]:setColor(ccc3(0xff,0xe4,0x00))
    havaNodos[2]:setColor(ccc3(0x00,0xff,0x18))
    havaNodos[3]:setColor(ccc3(0xff,0xe4,0x00))

    m_havaLabel  = BaseUI.createHorizontalNode(havaNodos)
    m_havaLabel:setAnchorPoint(ccp(0.5, 0.5))
    m_havaLabel:setPosition(layerSize.width*0.87,layerSize.height*0.05)
    m_astrologyLayer:addChild(m_havaLabel)
end

function refreshGoldNum()
    require "script/model/user/UserModel"
    local userInfo = UserModel.getUserInfo()
    m_goldLabel:setString(userInfo.gold_num)
end

---[==[占星 第2步
---------------------新手引导---------------------------------
function addGuideAstrologyGuide2( ... )
    require "script/guide/NewGuide"
    require "script/guide/AstrologyGuide"
    if(NewGuide.guideClass ==  ksGuideAstrology and AstrologyGuide.stepNum == 1) then
        require "script/ui/main/MainBaseLayer"
        AstrologyGuide.show(2, nil)
    end
end
---------------------end-------------------------------------
--]==]

---[==[占星 第4步
---------------------新手引导---------------------------------
function addGuideAstrologyGuide4( ... )
    require "script/guide/NewGuide"
    require "script/guide/AstrologyGuide"
    if(NewGuide.guideClass ==  ksGuideAstrology and AstrologyGuide.stepNum == 3) then
        require "script/ui/astrology/AstrologyLayer"
        local astrologyButton1 = AstrologyLayer.getAstroButtonByIndex(4)
        local astrologyButton2 = AstrologyLayer.getTargetAstroByIndex(4)
        local touchRect1 = getSpriteScreenRect(astrologyButton1)
        local touchRect2 = getSpriteScreenRect(astrologyButton2)
        AstrologyGuide.show(4, touchRect1,touchRect2)
    end
end
---------------------end-------------------------------------
--]==]

---[==[占星 第5步
---------------------新手引导---------------------------------
function addGuideAstrologyGuide5( ... )
    require "script/guide/NewGuide"
    require "script/guide/AstrologyGuide"
    if(NewGuide.guideClass ==  ksGuideAstrology and AstrologyGuide.stepNum == 4) then
        require "script/ui/astrology/AstrologyLayer"
        local astrologyButton1 = AstrologyLayer.getAstroButtonByIndex(3)
        local astrologyButton2 = AstrologyLayer.getTargetAstroByIndex(3)
        local touchRect1 = getSpriteScreenRect(astrologyButton1)
        local touchRect2 = getSpriteScreenRect(astrologyButton2)
        AstrologyGuide.show(5, touchRect1,touchRect2)
    end
end
---------------------end-------------------------------------
--]==]

---[==[占星 第6步
---------------------新手引导---------------------------------
function addGuideAstrologyGuide6( ... )
    require "script/guide/NewGuide"
    require "script/guide/AstrologyGuide"
    if(NewGuide.guideClass ==  ksGuideAstrology and AstrologyGuide.stepNum == 5) then
        require "script/ui/astrology/AstrologyLayer"
        local astrologyButton1 = AstrologyLayer.getAstroButtonByIndex(1)
        local astrologyButton2 = AstrologyLayer.getTargetAstroByIndex(1)
        local touchRect1 = getSpriteScreenRect(astrologyButton1)
        local touchRect2 = getSpriteScreenRect(astrologyButton2)
        AstrologyGuide.show(6, touchRect1,touchRect2)
    end
end
---------------------end-------------------------------------
--]==]


---[==[占星 第7步
---------------------新手引导---------------------------------
function addGuideAstrologyGuide7( ... )
    require "script/guide/NewGuide"
    require "script/guide/AstrologyGuide"
    if(NewGuide.guideClass ==  ksGuideAstrology and AstrologyGuide.stepNum == 6) then
        require "script/ui/astrology/AstrologyLayer"
        local astrologyButton = AstrologyLayer.getShowRewardButton()
        local touchRect = getSpriteScreenRect(astrologyButton)
        AstrologyGuide.show(7, touchRect)
    end
end
---------------------end-------------------------------------
--]==]

