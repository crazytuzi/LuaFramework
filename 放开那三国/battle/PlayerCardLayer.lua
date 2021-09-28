-- Filename: PlayerCardLayer.lua
-- Author: k
-- Date: 2013-05-27
-- Purpose: 战斗场景



require "script/utils/extern"
--require "amf3"
-- 主城场景模块声明
module("PlayerCardLayer", package.seeall)

require "script/battle/BattleCardUtil"
--require "script/battle/BattleLayer"

local IMG_PATH = "images/battle/"				-- 图片主路径

local m_playerCardLayer			-- 玩家卡牌层
local m_playerCardList          -- 玩家卡牌列表
local m_layerSize          -- 层尺寸
local m_onMovingCard          -- 当前移动卡
local m_isSwitchable            -- 是否可换位置
local cardWidth 

local m_formation

function getPointByPosition(index)
    
    local cardWidth = m_layerSize.width*0.2
    
    local startX = 0.20*m_layerSize.width
    local startY = 0.48*m_layerSize.height
    
    return ccp(startX+index%3*cardWidth*1.4, startY-math.floor(index/3)*(cardWidth*1.2)*1.2)
end

local function setPlayerCardsBack()
    
    local cardSize = m_playerCardList:count()
    
    for i=0,5 do
        
        local card = m_playerCardLayer:getChildByTag(2000+i)
        if card then
            local position = card:getTag()-2000
            --card:stopAllActions()
            --card:setScale(cardWidth/card:getContentSize().width)
            card:setPosition(getPointByPosition(position))
            
            local blinkArray = CCArray:create()
            blinkArray:addObject(CCFadeOut:create(0.8))
            blinkArray:addObject(CCFadeIn:create(0.8))
            blinkArray:addObject(CCDelayTime:create(0.2))
            card:runAction(CCRepeatForever:create(CCSequence:create(blinkArray)))
        end
    end
    
    for i=0,cardSize-1 do
        
        local card = tolua.cast(m_playerCardList:objectAtIndex(i), "CCXMLSprite")
        if card then
            local position = card:getTag()-1000
            --card:stopAllActions()
            --card:setScale(cardWidth/card:getContentSize().width)
            card:setPosition(getPointByPosition(position))
            card:setBasePoint(getPointByPosition(position));
        end
    end
    
end

local function initPlayerCards()
    
    --m_playerCardLayer = CCLayerColor:create(ccc4(255,0,0,111))
    m_playerCardLayer:setPosition(ccp(0, 0))
    m_playerCardLayer:setAnchorPoint(ccp(0, 0))
    --m_bg:addChild(m_playerCardLayer)
    
    if(m_playerCardList~=nil)then
        m_playerCardList:release()
        m_playerCardList = nil
    end
    
    m_playerCardList = CCArray:create()
    m_playerCardList:retain()
    
    for i=0,5 do
        
        local cardBg = CCSprite:create(IMG_PATH .. "card/card_bg.png")
        cardBg:setAnchorPoint(ccp(0.5,0.5))
        cardBg:setTag(2000+i)
        m_playerCardLayer:addChild(cardBg,1)
        
        --print("initPlayerCards:",m_formation["" .. i],(m_formation["" .. i])~=0,(m_formation["" .. i])~="0")
        if(m_formation["" .. i]~=nil and (m_formation["" .. i])~=0) then
            local card = BattleLayer.createBattleCard(m_formation["" .. i])
            card:setTag(1000+i)
            m_playerCardLayer:addChild(card,2, 1000+i)
            m_playerCardList:addObject(card)
            --card:release()
        end
    end
    setPlayerCardsBack()
end

local function getCardList()
    m_playerCardList:removeAllObjects()
    
    for i=0,5 do
        local card = m_playerCardLayer:getChildByTag(1000+i)
        if(nil~=card) then
            m_playerCardList:addObject(card)
            else
            
        end
    end
    return m_playerCardList
end

function getFormation()
    return m_formation
end

local function switchCard(x, y)
    
    local isSwitched = false
    
    --迭代卡牌判断交换位置
    for i=0,5 do
        --local card = tolua.cast(m_playerCardList:objectAtIndex(i), "CCSprite")
        local cardBg = m_playerCardLayer:getChildByTag(2000+i)
        if cardBg then
            print("switchCard:",cardBg:getTag(),m_onMovingCard:getTag())
            if(cardBg:getTag()-1000==m_onMovingCard:getTag()) then
                
                local location = cardBg:convertToNodeSpace(ccp(x, y))
                if(location.x>=0 and location.y>=0 and location.x<=cardBg:getContentSize().width and location.y<=cardBg:getContentSize().height) then
                    --处理复活
                    local hid1 = m_formation["" .. m_onMovingCard:getTag()-1000]
                    BattleLayer.reviveCardByHid(hid1)
                end
            else
                local location = cardBg:convertToNodeSpace(ccp(x, y))
                if(location.x>=0 and location.y>=0 and location.x<=cardBg:getContentSize().width and location.y<=cardBg:getContentSize().height) then
                    local index1 = m_onMovingCard:getTag()-1000
                    local index2 = cardBg:getTag()-2000
                    
                    require "script/ui/formation/FormationUtil"
                    local openedPosition = FormationUtil.getFormationOpenedNum()
                    --if(index2>(openedPosition-1)) then
                    --print("switch :",FormationUtil.isOpenedByPosition(index2),FormationUtil.isOpenedByPosition(index1))
                    if(FormationUtil.isOpenedByPosition(index2)==false or FormationUtil.isOpenedByPosition(index1)==false) then
                        isSwitched = false
                        require "script/ui/tip/AnimationTip"
                        AnimationTip.showTip( GetLocalizeStringBy("key_1513"))
                        break
                    end
                    
                    local hid1 = m_formation["" .. index1]
                    local hid2 = m_formation["" .. index2]
                    m_formation["" .. index1] = hid2
                    m_formation["" .. index2] = hid1
                    
                    local card = m_playerCardLayer:getChildByTag(1000+index2)
                    if(card~=nil) then
                        card:setPosition(getPointByPosition(index1))
                        card:setTag(1000+index1)
                    end
                    
                    m_onMovingCard:setPosition(getPointByPosition(index2))
                    m_onMovingCard:setTag(1000+index2)
                    
                    isSwitched = true
                    break
                end
            end
        end
    end
    
    if(isSwitched~=true) then
        local index = m_onMovingCard:getTag()-1000
        m_onMovingCard:setPosition(getPointByPosition(index))
    end
end

local function cardLayerTouch(eventType, x, y)
    if(m_isSwitchable~=true) then
        return false
    end
    
    if eventType == "began" then
        --print("cardLayerTouch:" .. x .. "," .. y)
        for i=0,m_playerCardList:count()-1 do
            local card = tolua.cast(m_playerCardList:objectAtIndex(i), "CCSprite")
            local location = card:convertToNodeSpace(ccp(x, y))
            if(location.x>=0 and location.y>=0 and location.x<=card:getContentSize().width and location.y<=card:getContentSize().height) then
                m_onMovingCard = card
                m_playerCardLayer:reorderChild(card,9)
                return true
            end
        end
        m_onMovingCard = nil
        return false
    elseif eventType == "moved" then
        if(nil~=m_onMovingCard) then
            local location = m_playerCardLayer:convertToNodeSpace(ccp(x, y))
            m_onMovingCard:setPosition(location)
        end
    else
        if(nil~=m_onMovingCard) then
            m_playerCardLayer:reorderChild(m_onMovingCard,2)
            switchCard(x, y)
        end
    end
end

-- 获得卡牌层
function getPlayerCardLayer (layerSize,formation)
    m_layerSize = layerSize
    m_isSwitchable = false
    
    m_playerCardLayer = CCLayer:create()
    
    m_formation = {}
    for k,v in pairs(formation) do
        --local teamInfo = dictData.ret[i]
        m_formation["" .. k] = v
    end
    
    
    --print("==========getPlayerCardLayer=============")
    require("script/utils/LuaUtil")
    --print_table ("m_formation", m_formation)
    --print("==========getPlayerCardLayer=============")
    
    cardWidth = m_layerSize.width*0.2
    
    initPlayerCards()
    
    m_playerCardLayer:setTouchEnabled(true)
    m_playerCardLayer:registerScriptTouchHandler(cardLayerTouch,false,-500,true)
    
    return m_playerCardLayer
end

-- 获得卡牌顺序
function getPlayerCardList (playerCardLayer)
    
    playerCardList = CCArray:create()
    
    for i=0,5 do
        local card = m_playerCardLayer:getChildByTag(1000+i)
        if(nil~=card) then
            playerCardList:addObject(card)
        else
            
        end
    end
    
    playerCardList:retain()
    return playerCardList
end

function setSwitchable(switchable)
    m_isSwitchable = switchable
    require "script/ui/formation/FormationUtil"
    for i=0,5 do
        
        if(FormationUtil.isOpenedByPosition(i)==true) then
            local cardBg = m_playerCardLayer:getChildByTag(2000+i)
            if cardBg then
                cardBg:setVisible(m_isSwitchable)
            end
        else
            local cardBg = m_playerCardLayer:getChildByTag(2000+i)
            if cardBg then
                cardBg:setVisible(false)
            end
        end
        
        --local cardBg = m_playerCardLayer:getChildByTag(2000+i)
        --cardBg:setVisible(m_isSwitchable)
    end
end
-- 退出场景，释放不必要资源
function release (...) 

end
