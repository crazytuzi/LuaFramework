-- Filename: PlayerMoneyTreeLayer.lua
-- Author: k
-- Date: 2013-11-30
-- Purpose: 摇钱树


require "script/utils/BaseUI"
require "script/utils/extern"
require "script/model/DataCache"
--require "amf3"
-- 主城场景模块声明
module("PlayerMoneyTreeLayer", package.seeall)

local _boosLife = 0
local _lifeNode = nil
local _infoPanel = nil
function createMoneyTreeLayer(armyId)

    local moneyTreeLayer = CCLayer:create()
    local layerSize = moneyTreeLayer:getContentSize()

    --血量和等级
    _infoPanel = CCScale9Sprite:create("images/battle/moneytree/labelbg.png")
    _infoPanel:setContentSize(CCSizeMake(240, 100))
    _infoPanel:setAnchorPoint(ccp(0,1))
    _infoPanel:setPosition(ccp(layerSize.width*0.0, layerSize.height*0.67))
    moneyTreeLayer:addChild(_infoPanel,2)
    _infoPanel:setScale(MainScene.elementScale)

    --摇钱树等级
    local levelDesLabel = CCRenderLabel:create(GetLocalizeStringBy("lcy_50115"), g_sFontPangWa, 24, 0, ccc3( 0x00, 0x00, 0x00), type_stroke)
    levelDesLabel:setColor(ccc3(0xff,0xe4,0x00))

    local levelSprite = CCSprite:create("images/common/lv.png")

    local boosLevelNum = DataCache.getBakBossTreeLevel()
    local levelNumLabel = CCRenderLabel:create("" .. boosLevelNum, g_sFontPangWa, 24, 0, ccc3( 0x00, 0x00, 0x00), type_stroke)
    levelNumLabel:setColor(ccc3(0xff,0xe4,0x00))

    local levelNode = BaseUI.createHorizontalNode({levelDesLabel, levelSprite, levelNumLabel})
    levelNode:setAnchorPoint(ccp(0, 1))
    levelNode:setPosition(ccp(10, _infoPanel:getContentSize().height - 10))
    _infoPanel:addChild(levelNode)

    --伤害
    local damageLabelBg = CCScale9Sprite:create("images/battle/moneytree/labelbg.png")
    damageLabelBg:setContentSize(CCSizeMake(240, 40))
    damageLabelBg:setAnchorPoint(ccp(0,1))
    damageLabelBg:setPosition(ccp(layerSize.width*0.0, layerSize.height*0.55))
    moneyTreeLayer:addChild(damageLabelBg,2)
    damageLabelBg:setScale(MainScene.elementScale)

    local damageDescLabel = CCSprite:create("images/battle/moneytree/damage_label.png")
    damageDescLabel:setAnchorPoint(ccp(0,0.5))
    damageDescLabel:setPosition(damageLabelBg:getContentSize().width*0.05,damageLabelBg:getContentSize().height*0.5)
    damageLabelBg:addChild(damageDescLabel)

    local damageLabel = CCRenderLabel:create("0", g_sFontPangWa, 24, 0, ccc3( 0x00, 0x00, 0x00), type_stroke)
    damageLabel:setColor(ccc3(0xff,0xe4,0x00))
    damageLabel:setAnchorPoint(ccp(0,0.5))
    damageLabel:setPosition(damageLabelBg:getContentSize().width*0.55,damageLabelBg:getContentSize().height*0.5)
    damageLabelBg:addChild(damageLabel)

    local silverLabelBg = CCScale9Sprite:create("images/battle/moneytree/labelbg.png")
    silverLabelBg:setContentSize(CCSizeMake(240, 40))
    silverLabelBg:setAnchorPoint(ccp(0,1))
    silverLabelBg:setPosition(ccp(layerSize.width*0.0, layerSize.height*0.5))
    moneyTreeLayer:addChild(silverLabelBg,2)
    silverLabelBg:setScale(MainScene.elementScale)

    local silverDescLabel = CCSprite:create("images/battle/moneytree/silver_label.png")
    silverDescLabel:setAnchorPoint(ccp(0,0.5))
    silverDescLabel:setPosition(silverLabelBg:getContentSize().width*0.05,silverLabelBg:getContentSize().height*0.5)
    silverLabelBg:addChild(silverDescLabel)

    local silverLabel = CCRenderLabel:create("0", g_sFontPangWa, 24, 0, ccc3( 0x00, 0x00, 0x00), type_stroke)
    silverLabel:setColor(ccc3(0xe9,0xe9,0xe8))
    silverLabel:setAnchorPoint(ccp(0,0.5))
    silverLabel:setPosition(silverLabelBg:getContentSize().width*0.55,silverLabelBg:getContentSize().height*0.5)
    silverLabelBg:addChild(silverLabel)

    local roundLabelBg = CCScale9Sprite:create("images/battle/moneytree/labelbg.png")
    roundLabelBg:setContentSize(CCSizeMake(240, 40))
    roundLabelBg:setAnchorPoint(ccp(0,1))
    roundLabelBg:setPosition(ccp(layerSize.width*0.0, layerSize.height*0.45))
    moneyTreeLayer:addChild(roundLabelBg,2)
    roundLabelBg:setScale(MainScene.elementScale)

    local roundDescLabel = CCSprite:create("images/battle/moneytree/round_label.png")
    roundDescLabel:setAnchorPoint(ccp(0,0.5))
    roundDescLabel:setPosition(roundLabelBg:getContentSize().width*0.05,roundLabelBg:getContentSize().height*0.5)
    roundLabelBg:addChild(roundDescLabel)

    require "db/DB_Army"
    local army = DB_Army.getDataById(tonumber(armyId))
    local fight_round = army.fight_round

    local roundLabel = CCRenderLabel:create("0/" .. fight_round, g_sFontPangWa, 24, 0, ccc3( 0x00, 0x00, 0x00), type_stroke)
    roundLabel:setColor(ccc3(0x00,0xff,0x18))
    roundLabel:setAnchorPoint(ccp(0,0.5))
    roundLabel:setPosition(roundLabelBg:getContentSize().width*0.55,roundLabelBg:getContentSize().height*0.5)
    roundLabelBg:addChild(roundLabel)

    local treeDamage = 0
    moneyTreeLayer.battleBlockChanged = function(block)
        local blockInfo = block
        if blockInfo == nil then
            return
        end
        if(blockInfo.arrReaction~=nil)then
            for reactionIndex=1,#(blockInfo.arrReaction) do
                print("PlayerMoneyTreeLayer 1")
                if(blockInfo.arrReaction[reactionIndex].defender==2701011 and blockInfo.arrReaction[reactionIndex].arrDamage~=nil)then
                    print("PlayerMoneyTreeLayer 2")
                    treeDamage = treeDamage + tonumber(blockInfo.arrReaction[reactionIndex].arrDamage[1].damageValue)
                    if(blockInfo.arrReaction[reactionIndex].buffer~=nil and blockInfo.arrReaction[reactionIndex].buffer[1].type==9)then
                        print("PlayerMoneyTreeLayer 3",blockInfo.arrReaction[reactionIndex].buffer[1].data)
                        treeDamage = treeDamage + tonumber(blockInfo.arrReaction[reactionIndex].buffer[1].data)
                    end
                end
            end
        end
        if(blockInfo.arrChild~=nil)then
            for arrChildIndex=1,#blockInfo.arrChild do

                if(blockInfo.arrChild[arrChildIndex].arrReaction~=nil)then
                    for reactionIndex=1,#(blockInfo.arrChild[arrChildIndex].arrReaction) do
                        if(blockInfo.arrChild[arrChildIndex].arrReaction[reactionIndex].defender==2701011 and blockInfo.arrChild[arrChildIndex].arrReaction[reactionIndex].arrDamage~=nil)then
                            treeDamage = treeDamage + tonumber(blockInfo.arrChild[arrChildIndex].arrReaction[reactionIndex].arrDamage[1].damageValue)
                            if(blockInfo.arrChild[arrChildIndex].arrReaction[reactionIndex].buffer~=nil and blockInfo.arrChild[arrChildIndex].arrReaction[reactionIndex].buffer[1].type==9)then
                                treeDamage = treeDamage + tonumber(blockInfo.arrChild[arrChildIndex].arrReaction[reactionIndex].buffer[1].data)
                            end
                        end
                    end
                end
            end
        end

        roundLabel:setString(blockInfo.round .. "/" .. fight_round)
        damageLabel:setString("" .. treeDamage)
        print("treeDamage:",treeDamage)

        --老版计算公式
        --[[
        require "script/model/user/UserModel"
        local userLevel = UserModel.getHeroLevel()
        userLevel = userLevel<50 and 50 or userLevel
        local silverNumber = userLevel*500 + treeDamage*0.05
        silverNumber = silverNumber>100000 and 100000 or silverNumber
        silverLabel:setString("" .. math.floor(silverNumber))
    --]]
        local silverNumber = 0
        if(treeDamage<5000)then

            silverNumber = treeDamage*0.1+0
        elseif(treeDamage<10000)then

            silverNumber = treeDamage*0.1+15000
        elseif(treeDamage<20000)then

            silverNumber = treeDamage*0.1+35000
        elseif(treeDamage<50000)then

            silverNumber = treeDamage*0.1+55000
        elseif(treeDamage<100000)then

            silverNumber = treeDamage*0.1+85000
        elseif(treeDamage<200000)then

            silverNumber = treeDamage*0.1+135000
        elseif(treeDamage<300000)then

            silverNumber = treeDamage*0.1+180000
        elseif(treeDamage<400000)then

            silverNumber = treeDamage*0.1+235000
        elseif(treeDamage<500000)then

            silverNumber = treeDamage*0.1+285000
        elseif(treeDamage<600000)then

            silverNumber = treeDamage*0.1+335000
        elseif(treeDamage<800000)then

            silverNumber = treeDamage*0.1+385000
        elseif(treeDamage<1000000)then

            silverNumber = treeDamage*0.1+435000
        else

            silverNumber = treeDamage*0.1+485000
        end

        silverLabel:setString("" .. math.floor(silverNumber))

    end

    return moneyTreeLayer
end


function setBoosLife( p_life )
    _boosLife = p_life
    if not tolua.cast(_infoPanel, "CCScale9Sprite") then
        return
    end

    if(_lifeNode ~= nil) then
        _lifeNode:removeFromParentAndCleanup(true)
        _lifeNode = nil
    end
    --摇钱树生命
    local lifeDesLabel = CCRenderLabel:create(GetLocalizeStringBy("lcy_50116"), g_sFontPangWa, 24, 0, ccc3( 0x00, 0x00, 0x00), type_stroke)
    lifeDesLabel:setColor(ccc3(0xff,0xe4,0x00))
    lifeDesLabel:setAnchorPoint(ccp(0,0.5))

    local boosLifeNum = _boosLife or 0
    local lifeNumLabel = CCRenderLabel:create("" .. boosLifeNum, g_sFontPangWa, 24, 0, ccc3( 0x00, 0x00, 0x00), type_stroke)
    lifeNumLabel:setColor(ccc3(0,254,24))
    lifeNumLabel:setAnchorPoint(ccp(0,0.5))

    local lifeNode = BaseUI.createHorizontalNode({lifeDesLabel, lifeNumLabel})
    lifeNode:setAnchorPoint(ccp(0, 0))
    lifeNode:setPosition(ccp(10, 10))
    _infoPanel:addChild(lifeNode)
end


-- 退出场景，释放不必要资源
function release (...)

end

