-- Filename: GuangongPreviewCell.lua
-- Author: zhang zihang
-- Date: 2014-1-20
-- Purpose: 该文件用于: 关公殿奖励预览cell

module ("GuangongPreviewCell", package.seeall)

function createCell( rewardData)

	local tCell = CCTableViewCell:create()

	local cellBg = CCScale9Sprite:create("images/reward/cell_back.png")
	cellBg:setContentSize(CCSizeMake(563,241))
	tCell:addChild(cellBg)

	local  descBg= CCSprite:create("images/sign/sign_bottom.png")
	descBg:setPosition(ccp(3,cellBg:getContentSize().height-56))
	cellBg:addChild(descBg)

	local rankLabel = CCRenderLabel:create( rewardData.layerName , g_sFontPangWa,24,1,ccc3(0xff,0xff,0xff),type_stroke)
	rankLabel:setColor(ccc3(0x75,0x38,0x01))
	rankLabel:setPosition(ccp(descBg:getContentSize().width*0.5,descBg:getContentSize().height*0.5+2))
	rankLabel:setAnchorPoint(ccp(0.5,0.5))
	descBg:addChild(rankLabel)

	local whiteBg = CCScale9Sprite:create("images/common/labelbg_white.png")
	whiteBg:setContentSize(CCSizeMake(490,37))
    whiteBg:setAnchorPoint(ccp(0.5,1))
    whiteBg:setPosition(ccp(cellBg:getContentSize().width/2,cellBg:getContentSize().height-60))
    cellBg:addChild(whiteBg)

    local executionLabel = CCRenderLabel:create( GetLocalizeStringBy("key_1299") .. rewardData.execution , g_sFontPangWa,24,1,ccc3(0x00,0x00,0x00),type_stroke)
    executionLabel:setColor(ccc3(0xff,0xf0,0x00))
    executionLabel:setAnchorPoint(ccp(0.5,0.5))
    executionLabel:setPosition(ccp(whiteBg:getContentSize().width/2,whiteBg:getContentSize().height/2))
    whiteBg:addChild(executionLabel)

	--  显示物品的bg
	local itemsBg= CCScale9Sprite:create("images/reward/item_back.png")
	itemsBg:setContentSize(CCSizeMake(513,127))
	itemsBg:setPosition(ccp(cellBg:getContentSize().width/2 ,18))
	itemsBg:setAnchorPoint(ccp(0.5,0))
	cellBg:addChild(itemsBg)

	--声望
	require "script/ui/item/ItemSprite"
	local pReward = ItemSprite.getPrestigeSprite()
	pReward:setAnchorPoint(ccp(0.5,0.4))
    pReward:setPosition(ccp(itemsBg:getContentSize().width*0.15,itemsBg:getContentSize().height-62))
    itemsBg:addChild(pReward)

    local pNum = CCRenderLabel:create(tostring(rewardData.prestige), g_sFontName,21,2,ccc3(0x00,0x00,0x00),type_shadow)
    pNum:setColor(ccc3(0x00,0xff,0x18))
    pNum:setPosition(ccp(pReward:getContentSize().width,0))
    pNum:setAnchorPoint(ccp(1,0))
    pReward:addChild(pNum)

    local pDescript = CCLabelTTF:create(GetLocalizeStringBy("key_2231"), g_sFontName , 21)
    pDescript:setColor(ccc3(0x78,0x25,0x00))
    pDescript:setPosition(ccp(itemsBg:getContentSize().width*0.15,28))
    pDescript:setAnchorPoint(ccp(0.5,1))
    itemsBg:addChild(pDescript)

    --银币
    local sReward = ItemSprite.getSiliverIconSprite()
    sReward:setAnchorPoint(ccp(0.5,0.4))
    sReward:setPosition(ccp(itemsBg:getContentSize().width*0.15+itemsBg:getContentSize().width*0.7/3,itemsBg:getContentSize().height-62))
    itemsBg:addChild(sReward)

    local sNum = CCRenderLabel:create(string.convertSilverUtilByInternational(rewardData.silver),g_sFontName,21,2,ccc3(0x00,0x00,0x00),type_shadow)  -- modified by yangrui at 2015-12-03
    sNum:setColor(ccc3(0x00,0xff,0x18))
    sNum:setPosition(ccp(sReward:getContentSize().width,0))
    sNum:setAnchorPoint(ccp(1,0))
    sReward:addChild(sNum)

    local sDescript = CCLabelTTF:create(GetLocalizeStringBy("key_1687"), g_sFontName , 21)
    sDescript:setColor(ccc3(0x78,0x25,0x00))
    sDescript:setPosition(ccp(itemsBg:getContentSize().width*0.15+itemsBg:getContentSize().width*0.7/3,28))
    sDescript:setAnchorPoint(ccp(0.5,1))
    itemsBg:addChild(sDescript)

	return tCell
end
