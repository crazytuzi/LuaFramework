-- Filename:TreasureEvolveMainView.lua
-- Author: 	lichenyang
-- Date: 	2014-1-7
-- Purpose: 宝物升级主界面

module("TreasureEvolveMainView", package.seeall)

require "script/ui/item/ItemUtil"
require "script/ui/item/TreasCardSprite"
require "script/ui/hero/HeroPublicLua"


--tag
local parentLayerTag		= nil

kTreasureListTag			= 101
kFormationListTag			= 102


local mainLayer				= nil
local layerSize 			= nil
local contentNode 			= nil
local treasureId 			= nil
local treasureInfo 			= nil
local oldInfoContainerNode 	= nil
local newInfoContainerNode 	= nil
local costlistScrollView 	= nil
local costInfo 				= nil
local costSilverLabel 		= nil
local backDelegate 			= nil
local layerYscale 			= nil
local closeButton 			= nil

function init( ... )
	mainLayer				= nil
	layerSize 				= nil
	contentNode 			= nil
	treasureId 				= nil
	treasureInfo 			= nil
 	oldInfoContainerNode 	= nil
 	newInfoContainerNode 	= nil
 	costlistScrollView		= nil
 	costInfo 				= nil
 	costSilverLabel			= nil
 	backDelegate 			= nil
 	closeButton 			= nil
end


function createLayer( treasure_id, callbackFunc )
	init()
	treasureId 				= treasure_id
	backDelegate			= callbackFunc
	treasureInfo 			= ItemUtil.getItemInfoByItemId(tonumber(treasureId))
	if(table.isEmpty(treasureInfo))then
		treasureInfo 		= ItemUtil.getTreasInfoFromHeroByItemId(tonumber(treasureId))
	end
	print("upgrade treasure info:")
	print_t(treasureInfo)
	require "script/ui/treasure/evolve/TreasureEvolveUtil"
	local oldInfo = TreasureEvolveUtil.getOldAffix(treasure_id)
	--
	print(GetLocalizeStringBy("key_1830"))
	print_t(oldInfo)

	costInfo = TreasureEvolveUtil.getEvolveCostInfo(treasureInfo.item_id, tonumber(treasureInfo.va_item_text.treasureEvolve) + 1)
	print("进阶花费数据:")
	print_t(costInfo)

	MainScene.setMainSceneViewsVisible(true, false, true)
	local bulletinLayerSize = BulletinLayer.getLayerFactSize()
	local menuLayerSize 	= MenuLayer.getLayerFactSize()
	local mainLayer 		= CCLayer:create()

	-- 顶部
	local topSprite = CCSprite:create("images/item/equipinfo/topbg.png")
	topSprite:setAnchorPoint(ccp(0.5, 1))
	topSprite:setPosition(ccp(g_winSize.width*0.5, g_winSize.height - bulletinLayerSize.height))
	topSprite:setScale(g_fScaleX)
	mainLayer:addChild(topSprite, 2)

	-- 标题
	local titleLabel = CCRenderLabel:create(GetLocalizeStringBy("key_2151"), g_sFontPangWa, 35, 1, ccc3( 0x00, 0x00, 0x00), type_stroke)
    titleLabel:setColor(ccc3(0xff, 0xe4, 0x00))
    titleLabel:setAnchorPoint(ccp(0.5, 0.5))
    titleLabel:setPosition(ccp( ( topSprite:getContentSize().width)/2, topSprite:getContentSize().height*0.55))
    topSprite:addChild(titleLabel)

    --创建背景
	local fullRect  = CCRectMake(0 , 0, 196, 198)
	local insetRect = CCRectMake(50, 50, 96, 98)
	bgSprite = CCScale9Sprite:create("images/item/equipinfo/bg_9s.png", fullRect, insetRect)
	bgSprite:setPreferredSize(CCSizeMake(g_winSize.width, g_winSize.height - menuLayerSize.height - bulletinLayerSize.height))
	bgSprite:setAnchorPoint(ccp(0.5, 0))
	bgSprite:setPosition(ccp(g_winSize.width*0.5, menuLayerSize.height))
	mainLayer:addChild(bgSprite)

    contentNode = CCNode:create()
    contentNode:setContentSize(CCSizeMake(g_winSize.width, bgSprite:getContentSize().height - topSprite:getContentSize().height * g_fScaleX))
    mainLayer:addChild(contentNode)
    contentNode:setAnchorPoint(ccp(0.5, 0.5))
    contentNode:setPosition(ccp(g_winSize.width * 0.5, menuLayerSize.height + (bgSprite:getContentSize().height - topSprite:getContentSize().height*g_fScaleX)/2))

    local deviceHeith = bgSprite:getContentSize().height - topSprite:getContentSize().height * g_fScaleX
    -- local deviceWidth = bgSprite:getContentSize().width
    -- local x = deviceWidth/contentNode:getContentSize().width
    -- local y = deviceHeith/contentNode:getContentSize().height
    -- if (x > y) then
    --     contentNode:setScale(y)
    -- else
    --     contentNode:setScale(x)
    -- end
    layerYscale = deviceHeith/714
    createContent()
	return mainLayer
end


function createContent( ... )
	-- body
	local menu = CCMenu:create()
	menu:setPosition(ccp(0,0))
	menu:setAnchorPoint(ccp(0,0))
	contentNode:addChild(menu)


	local fullRect 		= CCRectMake(0, 0, 61, 47)
	local insetRect 	= CCRectMake(24, 16, 10, 4)
    local itemListBg 	= CCScale9Sprite:create("images/common/bg/white_text_ng.png", fullRect, insetRect)
    local preferredSize = {width=580, height=107}
    itemListBg:setAnchorPoint(ccp(0.5, 0))
    itemListBg:setPosition(ccp(contentNode:getContentSize().width*0.5, 135 * layerYscale))
    itemListBg:setPreferredSize(CCSizeMake(preferredSize.width, preferredSize.height))
    contentNode:addChild(itemListBg)
    itemListBg:setScale(MainScene.elementScale)

	local leftCardSpriteA = TreasCardSprite.createSprite(treasureInfo.item_template_id,treasureInfo.item_id)
	local leftCardSpriteB = TreasCardSprite.createSprite(treasureInfo.item_template_id,treasureInfo.item_id)
	local leftCard 		  = CCMenuItemSprite:create(leftCardSpriteA, leftCardSpriteB)
	leftCard:setAnchorPoint(ccp(0.5, 0.5))
	
	leftCard:registerScriptTapHandler(selectNewCard)
	menu:addChild(leftCard)
	leftCard:setScale(160/leftCard:getContentSize().width)
	leftCard:setScale( leftCard:getScale() * MainScene.elementScale )


	local rightCard = TreasCardSprite.createSprite(treasureInfo.item_template_id,treasureInfo.item_id)
	rightCard:setAnchorPoint(ccp(0.5, 0.5))
	
	contentNode:addChild(rightCard)
	rightCard:setScale(160/leftCard:getContentSize().width)
	rightCard:setScale( rightCard:getScale() * MainScene.elementScale )

	local ccSpriteArrow = CCSprite:create("images/hero/transfer/arrow.png")
	ccSpriteArrow:setAnchorPoint(ccp(0.5, 0.5))
	contentNode:addChild(ccSpriteArrow)
	ccSpriteArrow:setScale(MainScene.elementScale)
	-- 背景图(9宫格)
	local contentH = rightCard:getContentSize().height * rightCard:getScale() + 30 * layerYscale
	local ch        = itemListBg:getContentSize().height * MainScene.elementScale + itemListBg:getPositionY() + 0 * layerYscale
	local fullRect 	= CCRectMake(0, 0, 75, 75)
	local insetRect = CCRectMake(30, 30, 15, 10)
    local leftInfoPanel	= CCScale9Sprite:create("images/hero/transfer/bg_ng_graywhite.png", fullRect, insetRect)
    -- 九宫格背景包实际大小
    leftInfoPanel:setPreferredSize(CCSizeMake(265, 252))
    leftInfoPanel:setAnchorPoint(ccp(0.5, 0))
    leftInfoPanel:setPosition(ccp(contentNode:getContentSize().width*0.25, ch))
    contentNode:addChild(leftInfoPanel)
    oldInfoContainerNode= CCNode:create()
	oldInfoContainerNode:setContentSize(CCSizeMake(265, 252))
	oldInfoContainerNode:setAnchorPoint(ccp(0, 0))
	oldInfoContainerNode:setPosition(ccp(0, 0))
	leftInfoPanel:addChild(oldInfoContainerNode)
	leftInfoPanel:setScale(MainScene.elementScale)

   -- 背景图(9宫格)
    local rightInfoPanel= CCScale9Sprite:create("images/hero/transfer/bg_ng_graywhite.png", fullRect, insetRect)
    -- 九宫格背景包实际大小
    rightInfoPanel:setPreferredSize(CCSizeMake(265, 252))
    rightInfoPanel:setAnchorPoint(ccp(0.5, 0))
    rightInfoPanel:setPosition(ccp(contentNode:getContentSize().width*0.75, ch))
    contentNode:addChild(rightInfoPanel)
	newInfoContainerNode= CCNode:create()
	newInfoContainerNode:setContentSize(CCSizeMake(265, 252))
	newInfoContainerNode:setAnchorPoint(ccp(0, 0))
	newInfoContainerNode:setPosition(ccp(0, 0))
	rightInfoPanel:addChild(newInfoContainerNode)
	rightInfoPanel:setScale(MainScene.elementScale)

	local laH = rightInfoPanel:getContentSize().height * MainScene.elementScale + rightInfoPanel:getPositionY()
	leftCard:setPosition(ccp(contentNode:getContentSize().width*0.25, laH + (contentNode:getContentSize().height - laH)/2  - 3))
	rightCard:setPosition(ccp(contentNode:getContentSize().width*0.75,laH + (contentNode:getContentSize().height - laH)/2  - 3))
	ccSpriteArrow:setPosition(contentNode:getContentSize().width/2,laH + (contentNode:getContentSize().height - laH)/2  - 3)
    local ccSpriteLeftArrow = CCSprite:create("images/formation/btn_left.png")
    local x_left = 0.022*preferredSize.width
    ccSpriteLeftArrow:setPosition(ccp(x_left, preferredSize.height/2))
    ccSpriteLeftArrow:setAnchorPoint(ccp(0, 0.5))
    itemListBg:addChild(ccSpriteLeftArrow)

    local ccSpriteRightArrow = CCSprite:create("images/formation/btn_left.png")
    local x_left = (1 - 0.022)*preferredSize.width
    ccSpriteRightArrow:setPosition(ccp(x_left, preferredSize.height/2))
    ccSpriteRightArrow:setAnchorPoint(ccp(1, 0.5))
    ccSpriteRightArrow:setFlipX(true)
    itemListBg:addChild(ccSpriteRightArrow)

    costlistScrollView = CCScrollView:create()
	costlistScrollView:setContentSize(CCSizeMake(100*table.count(costInfo.items) + 10, 110))
	costlistScrollView:setViewSize(CCSizeMake(450, 110))
    costlistScrollView:setAnchorPoint(ccp(0.5,0.5))
	costlistScrollView:setDirection(kCCScrollViewDirectionHorizontal)
	costlistScrollView:setPosition(ccpsprite(0.12, 0.1, itemListBg))
    itemListBg:addChild(costlistScrollView)

    createMenu()			--菜单
    createOldInfo()			--精炼前属性
    createNewInfo()			--精炼后属性
    createCostItemList()	--消耗物品列表
    createCostSilverPanel() --消耗银币背景
end

function createMenu( ... )
	local menu = CCMenu:create()
	menu:setAnchorPoint(ccp(0, 0))
	menu:setPosition(ccp(0, 0))
	contentNode:addChild(menu)

	upgradeButton= LuaCC.create9ScaleMenuItem("images/common/btn/btn1_d.png","images/common/btn/btn1_n.png", CCSizeMake(210,73), GetLocalizeStringBy("key_3199"), ccc3(255,222,0))
	upgradeButton:registerScriptTapHandler(evolveButtonCallback)
	upgradeButton:setAnchorPoint(ccp(0.5, 0))
	upgradeButton:setPosition(contentNode:getContentSize().width * 0.75, 15)
	menu:addChild(upgradeButton)
	upgradeButton:setScale( MainScene.elementScale )

	closeButton = LuaCC.create9ScaleMenuItem("images/common/btn/btn1_d.png","images/common/btn/btn1_n.png", CCSizeMake(210,73), GetLocalizeStringBy("key_1951"), ccc3(255,222,0))
	closeButton:registerScriptTapHandler(closeButtonCallback)
	closeButton:setAnchorPoint(ccp(0.5, 0))
	closeButton:setPosition(contentNode:getContentSize().width * 0.25, 15)
	closeButton:setScale( MainScene.elementScale )
	menu:addChild(closeButton)
end

--创建旧属性
function createOldInfo( ... )
	local oldInfo 		= TreasureEvolveUtil.getOldAffix(treasureId)

	local nameLabel 	= CCRenderLabel:create(oldInfo.name, g_sFontName, 26, 1, ccc3( 0x00, 0x00, 0x00), type_stroke)
	nameLabel:setColor(HeroPublicLua.getCCColorByStarLevel(oldInfo.quality))
	nameLabel:setAnchorPoint(ccp(0, 1))
	oldInfoContainerNode:addChild(nameLabel)

	local reinforceLabel = CCRenderLabel:create("+" .. oldInfo.reinforceLeve, g_sFontPangWa, 21, 1, ccc3( 0x00, 0x00, 0x00), type_stroke)
    reinforceLabel:setColor(ccc3(0x00, 0xff, 0x18))
    reinforceLabel:setAnchorPoint(ccp(0, 0.5))
    oldInfoContainerNode:addChild(reinforceLabel)

    local x = oldInfoContainerNode:getContentSize().width/2 - (nameLabel:getContentSize().width + reinforceLabel:getContentSize().width)/2
    nameLabel:setPosition(ccp(x,oldInfoContainerNode:getContentSize().height - 8))
    reinforceLabel:setPosition(ccp(nameLabel:getPositionX() + nameLabel:getContentSize().width + 5, oldInfoContainerNode:getContentSize().height - 21))

	--宝石级别
	local gemPanle 		= createEvolveGemPanel(oldInfo.evolveLevel, treasureInfo.itemDesc.max_upgrade_level)
	gemPanle:setAnchorPoint(ccp(0.5,1))
	gemPanle:setPosition(oldInfoContainerNode:getContentSize().width/2,  oldInfoContainerNode:getContentSize().height - 50)
	oldInfoContainerNode:addChild(gemPanle)

	--精炼属性
	local nameLabel 	= CCLabelTTF:create(GetLocalizeStringBy("key_2155"), g_sFontName, 26)
	nameLabel:setColor(ccc3(0x78, 0x25, 0x00))
	nameLabel:setAnchorPoint(ccp(0, 1))
	nameLabel:setPosition(ccp(14,oldInfoContainerNode:getContentSize().height - 135))
	oldInfoContainerNode:addChild(nameLabel)

	local i = 0
	for k,v in pairs(oldInfo.affix) do
		local affixNameLabel = CCLabelTTF:create(v.name .. ":", g_sFontName, 23)
		affixNameLabel:setAnchorPoint(ccp(0, 0.5))
		affixNameLabel:setPosition(14 , oldInfoContainerNode:getContentSize().height - 185 - i*35)
		affixNameLabel:setColor(ccc3(0x00, 0x70, 0xae))
		oldInfoContainerNode:addChild(affixNameLabel)

		local affixValueLabel = CCLabelTTF:create(TreasureEvolveUtil.AffixDisplayTransform(v.id, v.num), g_sFontName, 23)
		affixValueLabel:setAnchorPoint(ccp(0, 0.5))
		affixValueLabel:setColor(ccc3(0x00, 0x70, 0xae))
		affixValueLabel:setPosition(110 , oldInfoContainerNode:getContentSize().height - 185 - i*35)
		oldInfoContainerNode:addChild(affixValueLabel)
		i = i+1
	end

	--未结束属性
	local lockAffixInfo = nil
	for k,v in pairs(oldInfo.lockAffix) do
		print("oldInfo.lockAffix k =", k)
		if(tonumber(v.level) > tonumber(treasureInfo.va_item_text.treasureEvolve)) then
			print_t(v)
			lockAffixInfo = v
			break
		end
	end
	if(lockAffixInfo ~= nil) then
		local lockNodeTable = {}
		lockNodeTable[1] = 	CCLabelTTF:create(lockAffixInfo.name .. ":" .. TreasureEvolveUtil.AffixDisplayTransform( lockAffixInfo.id,lockAffixInfo.num), g_sFontName, 23)
		lockNodeTable[1]:setColor(ccc3(100, 100, 100))
		-- lockNodeTable[2] = 	CCLabelTTF:create(GetLocalizeStringBy("key_1428") .. lockAffixInfo.level .. GetLocalizeStringBy("key_3229"), g_sFontName, 23)
		-- lockNodeTable[2]:setColor(ccc3(0xd6, 0, 0))
		local  lockNode = BaseUI.createHorizontalNode(lockNodeTable)
		lockNode:setAnchorPoint(ccp(0, 0))
		lockNode:setPosition(ccp(15, 22))
		oldInfoContainerNode:addChild(lockNode)
	end

end

--创建新属性
function createNewInfo( ... )
	if(tonumber(treasureInfo.va_item_text.treasureEvolve) >= tonumber(treasureInfo.itemDesc.max_upgrade_level)) then
		return
	end

	local oldInfo 		= TreasureEvolveUtil.getNewAffix(treasureId)
	print("createNewInfo :")
	print_t(oldInfo)

	local nameLabel 	= CCRenderLabel:create(oldInfo.name, g_sFontName, 26, 1, ccc3( 0x00, 0x00, 0x00), type_stroke)
	nameLabel:setColor(HeroPublicLua.getCCColorByStarLevel(oldInfo.quality))
	nameLabel:setAnchorPoint(ccp(0, 1))
	newInfoContainerNode:addChild(nameLabel)

	local reinforceLabel = CCRenderLabel:create("+" .. oldInfo.reinforceLeve, g_sFontPangWa, 21, 1, ccc3( 0x00, 0x00, 0x00), type_stroke)
    reinforceLabel:setColor(ccc3(0x00, 0xff, 0x18))
    reinforceLabel:setAnchorPoint(ccp(0, 0.5))
    newInfoContainerNode:addChild(reinforceLabel)

    local x = newInfoContainerNode:getContentSize().width/2 - (nameLabel:getContentSize().width + reinforceLabel:getContentSize().width)/2
    nameLabel:setPosition(ccp(x,newInfoContainerNode:getContentSize().height - 8))
    reinforceLabel:setPosition(ccp(nameLabel:getPositionX() + nameLabel:getContentSize().width + 5, newInfoContainerNode:getContentSize().height - 21))

	--宝石级别
	local gemPanle 		= createEvolveGemPanel(oldInfo.evolveLevel, treasureInfo.itemDesc.max_upgrade_level)
	gemPanle:setAnchorPoint(ccp(0.5,1))
	gemPanle:setPosition(newInfoContainerNode:getContentSize().width/2,  newInfoContainerNode:getContentSize().height - 50)
	newInfoContainerNode:addChild(gemPanle)

	--精炼属性
	local nameLabel 	= CCLabelTTF:create(GetLocalizeStringBy("key_2155"), g_sFontName, 26)
	nameLabel:setColor(ccc3(0x78, 0x25, 0x00))
	nameLabel:setAnchorPoint(ccp(0, 1))
	nameLabel:setPosition(ccp(14,newInfoContainerNode:getContentSize().height - 135))
	newInfoContainerNode:addChild(nameLabel)

	local i = 0
	for k,v in pairs(oldInfo.affix) do
		local affixNameLabel = CCLabelTTF:create(v.name .. ":", g_sFontName, 23)
		affixNameLabel:setAnchorPoint(ccp(0, 0.5))
		affixNameLabel:setPosition(14 , newInfoContainerNode:getContentSize().height - 185 - i*35)
		affixNameLabel:setColor(ccc3(0x00, 0x70, 0xae))
		newInfoContainerNode:addChild(affixNameLabel)

		local affixValueLabel = CCLabelTTF:create(TreasureEvolveUtil.AffixDisplayTransform(v.id ,v.num), g_sFontName, 23)
		affixValueLabel:setAnchorPoint(ccp(0, 0.5))
		affixValueLabel:setColor(ccc3(0x00, 0x70, 0xae))
		affixValueLabel:setPosition(110 , newInfoContainerNode:getContentSize().height - 185 - i*35)
		newInfoContainerNode:addChild(affixValueLabel)
		if(v.isNew == true) then
			local newSprite = CCSprite:create("images/common/new_hanzi.png")
			newSprite:setAnchorPoint(ccp(1, 0.5))
			newSprite:setPosition(newInfoContainerNode:getContentSize().width - 10, newInfoContainerNode:getContentSize().height - 185 - i*35)
			newInfoContainerNode:addChild(newSprite)
		end
		i = i+1
	end

	--未结束属性
	local lockAffixInfo = nil
	for k,v in pairs(oldInfo.lockAffix) do
		print("oldInfo.lockAffix k =", k)
		if(tonumber(v.level) > tonumber(treasureInfo.va_item_text.treasureEvolve)+1) then
			print_t(v)
			lockAffixInfo = v
			break
		end
	end
	if(lockAffixInfo ~= nil) then
		local lockNodeTable = {}
		lockNodeTable[1] = 	CCLabelTTF:create(lockAffixInfo.name .. ":" .. TreasureEvolveUtil.AffixDisplayTransform( lockAffixInfo.id,lockAffixInfo.num), g_sFontName, 23)
		lockNodeTable[1]:setColor(ccc3(100, 100, 100))
		-- lockNodeTable[2] = 	CCLabelTTF:create(GetLocalizeStringBy("key_1428") .. lockAffixInfo.level .. GetLocalizeStringBy("key_3229"), g_sFontName, 23)
		-- lockNodeTable[2]:setColor(ccc3(0xd6, 0, 0))
		local  lockNode = BaseUI.createHorizontalNode(lockNodeTable)
		lockNode:setAnchorPoint(ccp(0, 0))
		lockNode:setPosition(ccp(15, 22))
		newInfoContainerNode:addChild(lockNode)
	end

end

function createCostItemList( ... )
	if(tonumber(treasureInfo.va_item_text.treasureEvolve) >= tonumber(treasureInfo.itemDesc.max_upgrade_level)) then
		return
	end
	require "script/ui/item/ItemSprite"
	local i = 0
	for k,v in pairs(costInfo.items) do
		local itemSprite = ItemSprite.getItemSpriteByItemId(v.tid)
		local maxNum 	 = TreasureEvolveUtil.getItemNumByTid(v.tid, treasureId)
		local numLabel 	 = CCRenderLabel:create(tostring(maxNum) .. "/" .. tostring(v.num) , g_sFontName, 23, 1, ccc3( 0x00, 0x00, 0x00), type_stroke)
		if(tonumber(maxNum) < tonumber(v.num)) then
			numLabel:setColor(ccc3(0xd6, 0x00, 0x00))
		else
			numLabel:setColor(ccc3(0x00, 0xff, 0x18))
		end
		
		numLabel:setAnchorPoint(ccp(1, 0))
		numLabel:setPosition(itemSprite:getContentSize().width - 3, 0)
		itemSprite:addChild(numLabel)

		itemSprite:setPosition(ccp(5 + i* 100, 0))
		itemSprite:setAnchorPoint(ccp(0, 0))
		costlistScrollView:addChild(itemSprite)
		i = i + 1
	end
end

function createCostSilverPanel( ... )
	if(tonumber(treasureInfo.va_item_text.treasureEvolve) >= tonumber(treasureInfo.itemDesc.max_upgrade_level)) then
		return
	end
	local costSilverbgPanel = CCScale9Sprite:create("images/hero/transfer/bg_ng_silver.png")
	costSilverbgPanel:setContentSize(CCSizeMake(450, 42))
	costSilverbgPanel:setAnchorPoint(ccp(0.5, 0))
	costSilverbgPanel:setPosition(ccp(contentNode:getContentSize().width/2, 90 *  layerYscale))
	costSilverbgPanel:setScale(MainScene.elementScale)
	contentNode:addChild(costSilverbgPanel)

	local speedTable = {}
	speedTable[1] = CCLabelTTF:create(GetLocalizeStringBy("key_1657"), g_sFontName, 25)
	speedTable[2] = CCSprite:create("images/common/coin_silver.png")
	speedTable[3] = CCLabelTTF:create(costInfo.silver .. "", g_sFontName, 25)

	costSilverLabel = speedTable[3] 

	local costNode = BaseUI.createHorizontalNode(speedTable)
    costNode:setAnchorPoint(ccp(0.5, 0.5))
    costNode:setPosition(ccp(costSilverbgPanel:getContentSize().width/2, costSilverbgPanel:getContentSize().height/2))
    costSilverbgPanel:addChild(costNode)

end

--------------------------------------[[ 更新ui 方法]]--------------------------------
function updateTreasureInfo( ... )
	-- body
	oldInfoContainerNode:removeAllChildrenWithCleanup(true)
	newInfoContainerNode:removeAllChildrenWithCleanup(true)
	
	createNewInfo()
	createOldInfo()
	updateCostItemList()
	if(tonumber(treasureInfo.va_item_text.treasureEvolve) < tonumber(treasureInfo.itemDesc.max_upgrade_level)) then
		costSilverLabel:setString(costInfo.silver .. "")
	end
end

function updateCostItemList( ... )
	local reloadFunc = function ( ... )
		costlistScrollView:getContainer():removeAllChildrenWithCleanup(true)
		createCostItemList()
		print("刷新消耗数据!!!!!")
	end
	local runningScene = CCDirector:sharedDirector():getRunningScene()
	local actions = CCArray:create()
	actions:addObject(CCDelayTime:create(0.5))
	actions:addObject(CCCallFunc:create(reloadFunc))
	local seqAction = CCSequence:create(actions)
	runningScene:runAction(seqAction)
end


---------------------------------------[[回调事件]]------------------------------------
--精炼按钮回调时间
function evolveButtonCallback( ... )
	require "script/audio/AudioUtil"
	AudioUtil.playEffect("audio/effect/zhujiemian.mp3")
	require "script/ui/treasure/evolve/TreasEvolveSuccessLayer"

	local oldInfo 		= TreasureEvolveUtil.getOldAffix(treasureId)
	local newInfo 		= TreasureEvolveUtil.getNewAffix(treasureId)

	local changeEffectFunc = function ( ... )
		upgradeButton:setEnabled(false)
		closeButton:setEnabled(false)
	    local action1 = CCLayerSprite:layerSpriteWithName(CCString:create("images/guide/effect/zhuangchang/zhuangchang"),-1,CCString:create(""))
	    action1:setScale(getScaleParm())
	    action1:setPosition(ccp(g_winSize.width * 0.5 - 640*getScaleParm()*0.5, g_winSize.height * 0.5 + 960*getScaleParm()*0.5))
	    
	    local animationDelegate = BTAnimationEventDelegate:create()
	    action1:setDelegate(animationDelegate)
	    animationDelegate:registerLayerEndedHandler(function ( eventType,layerSprite )
	    	action1:retain()
	    	action1:autorelease()
	        action1:removeFromParentAndCleanup(true)
	        
	        action1 = nil
			require "script/ui/treasure/evolve/TreasEvolveSuccessLayer"
			local tparam = TreasureEvolveUtil.getEvolveInfo(treasureId,oldInfo,newInfo)
			TreasEvolveSuccessLayer.fnCreateTransferEffect(tparam)
			upgradeButton:setEnabled(true)
			closeButton:setEnabled(true)
	    end)
	    local runningScene = CCDirector:sharedDirector():getRunningScene()
	    runningScene:addChild(action1, 3202)		
	end

	require "script/ui/treasure/evolve/TreasureEvolveService"
	TreasureEvolveService.evolve(treasureId,function ( ... )
		treasureInfo 			= ItemUtil.getItemInfoByItemId(tonumber(treasureId))
		if(table.isEmpty(treasureInfo))then
			treasureInfo 		= ItemUtil.getTreasInfoFromHeroByItemId(tonumber(treasureId))
		end
		costInfo = TreasureEvolveUtil.getEvolveCostInfo(treasureInfo.item_id, tonumber(treasureInfo.va_item_text.treasureEvolve) + 1)
		updateTreasureInfo()
		changeEffectFunc()
	end)

end

--关闭界面事件
function closeButtonCallback( ... )
	require "script/audio/AudioUtil"
	AudioUtil.playEffect("audio/effect/guanbi.mp3")
	if(parentLayerTag == kFormationListTag) then
		require("script/ui/formation/FormationLayer")
		-- addby chengliang
		local treasureInfo 		= ItemUtil.getTreasInfoFromHeroByItemId(tonumber(treasureId))
        local formationLayer = FormationLayer.createLayer(treasureInfo.hid, false, false)
        MainScene.changeLayer(formationLayer, "formationLayer")
	elseif(parentLayerTag == kTreasureListTag) then
		require "script/ui/bag/BagLayer"
		local bagLayer = BagLayer.createLayer(BagLayer.Tag_Init_Treas, BagLayer.Type_Bag_Treas)
		MainScene.changeLayer(bagLayer, "bagLayer")
	else
		require "script/ui/bag/BagLayer"
		local bagLayer = BagLayer.createLayer(BagLayer.Tag_Init_Treas, BagLayer.Type_Bag_Treas)
		MainScene.changeLayer(bagLayer, "bagLayer")
	end

	parentLayerTag	=	nil
end


--选择新卡片回调事件
function selectNewCard( ... )
	print("select new card")
	require "script/ui/treasure/evolve/TreasRefineSelLayer"
	local treasRefineSelLayer = TreasRefineSelLayer.createLayer(treasureId )
	MainScene.changeLayer(treasRefineSelLayer, "treasRefineSelLayer")
end


--------------------------------------[[ ui工具方法 ]]-----------------------------------

function createEvolveGemPanel( level,maxLevel )



	local row 		= math.floor(10/5)
	local gemPanle 	= CCScale9Sprite:create("images/hero/transfer/bg_ng_orange.png")
	gemPanle:setContentSize(CCSizeMake(230, row * 36))

	if tonumber(level) <= tonumber(maxLevel) then
		require "script/ui/treasure/TreasureUtil"
		for i=1, 10 do
			local sprite = nil

			if(i <= tonumber(level)%10)then
				sprite 	= TreasureUtil.getFixedLevelSprite(level)
			else
				sprite 	= CCSprite:create("images/common/big_gray_gem.png")
			end

			if math.floor(tonumber(level)/10) >= 1 and tonumber(level)%10==0  then
				sprite 	= TreasureUtil.getFixedLevelSprite(level)
			end

			sprite:setAnchorPoint(ccp(0.5, 0.5))
			local dis  	= gemPanle:getContentSize().width/5
			local x    	= dis/2 + dis * ((i-1)%5)
			local y 	= gemPanle:getContentSize().height + 29/2 - (math.floor((i-1)/5) + 1)*35
			sprite:setPosition(ccp(x , y))
			gemPanle:addChild(sprite)
		end
	end
	return gemPanle
end

--[[
	@des 	:	设置父跳转Layer标记
--]]
function setFromLayerTag( layer_tag )
	parentLayerTag	=	layer_tag
end