-- Filename：	TreasCardSprite.lua
-- Author：		Cheng Liang
-- Date：		2013-11-5
-- Purpose：		宝物信息的展示

module("TreasCardSprite", package.seeall)

require "script/ui/item/ItemUtil"

function createSprite(item_tmpl_id,p_itemId, p_treasInfo)
	print("item_tmpl_id",item_tmpl_id, "totalScore",totalScore, "p_itemId",p_itemId)

	local localData = ItemUtil.getItemById(item_tmpl_id)
    

    local quality = 0
    print("p_treasInfo")
    print_t(p_treasInfo)
    if(p_treasInfo ~= nil)then
        quality = ItemUtil.getTreasureQualityByItemInfo( p_treasInfo )
        print("1")
    elseif(p_itemId ~= nil)then
        quality = ItemUtil.getTreasureQualityByItemId( p_itemId )
        print("2")
    else
        quality = ItemUtil.getTreasureQualityByTid( item_tmpl_id )
        print("3")
    end
    local baseScore = 0
    if(quality < 6)then
        baseScore = localData.base_score
    elseif(quality==6)then
        baseScore = localData.new_score
    elseif(quality==7)then
        baseScore = localData.new_score2
    end
    print("quality",quality,"baseScore",baseScore)
	-- 卡牌背景	
	local cardSprite = CCSprite:create("images/item/equipinfo/card/equip_" .. quality .. ".png")

    -- icon
    local iconSprite = CCSprite:create("images/base/treas/big/" .. localData.icon_big)
    iconSprite:setAnchorPoint(ccp(0.5, 0.5))
    iconSprite:setPosition(ccp(cardSprite:getContentSize().width/2, cardSprite:getContentSize().height*0.55))
    cardSprite:addChild(iconSprite)

    -- 星级
    for i=1, quality do
    	local starSp = CCSprite:create("images/formation/star.png")
    	starSp:setAnchorPoint(ccp(0.5, 0.5))
    	starSp:setPosition(ccp( cardSprite:getContentSize().width * 0.9 - cardSprite:getContentSize().width* 27.0/300 * (i-1), cardSprite:getContentSize().height * 410/440))
    	cardSprite:addChild(starSp)
    end
    require "script/libs/LuaCC"
    local scoreSprite = LuaCC.createSpriteOfNumbers("images/item/equipnum", baseScore, 17)
    if (scoreSprite ~= nil) then
        scoreSprite:setAnchorPoint(ccp(0, 0))
        scoreSprite:setPosition(cardSprite:getContentSize().width*110.0/301, cardSprite:getContentSize().height*0.05)
        cardSprite:addChild(scoreSprite)
    end

    -- 平台相关装备名字显示兼容
    local plName = Platform.getPlatformFlag()
    if(Platform.getPlatformFlag() == "ios_thailand" or Platform.getPlatformFlag() == "Android_taiguo" ) then
        local nameLabel = CCRenderLabel:create(localData.name, g_sFontName, 24, 1, ccc3( 0x00, 0x00, 0x00), type_stroke)
        nameLabel:setAnchorPoint(ccp(0.5,0.5))
        nameLabel:setColor(ccc3(0xff, 0xff, 0xff))
        nameLabel:setPosition(ccp( cardSprite:getContentSize().width*0.5, cardSprite:getContentSize().height*0.18))
        cardSprite:addChild(nameLabel,3)
    elseif (Platform.getLayout ~= nil and Platform.getLayout() == "enLayout" ) then
        local nameLabel = CCRenderLabel:create(localData.name, g_sFontName, 24, 1, ccc3( 0x00, 0x00, 0x00), type_stroke)
        nameLabel:setAnchorPoint(ccp(0.5,0.5))
        nameLabel:setColor(ccc3(0xff, 0xff, 0xff))
        nameLabel:setPosition(ccp( cardSprite:getContentSize().width*0.5, cardSprite:getContentSize().height*0.18))
        cardSprite:addChild(nameLabel,3)
    else
        local nameLabel = CCRenderLabel:createWithAlign(localData.name, g_sFontName, 24,
                                      1 , ccc3(0, 0, 0 ), type_stroke, CCSizeMake(25,180), kCCTextAlignmentCenter,
                                      kCCVerticalTextAlignmentCenter);
        -- nameLabel:setSourceAndTargetColor(ccc3( 0x36, 0xff, 0x00), ccc3( 0x36, 0xff, 0x00));
        nameLabel:setColor(ccc3(0xff, 0xff, 0xff))
        nameLabel:setPosition(ccp( cardSprite:getContentSize().width*0.02, cardSprite:getContentSize().height*0.98))
        cardSprite:addChild(nameLabel,3)
    end

    return cardSprite
end




