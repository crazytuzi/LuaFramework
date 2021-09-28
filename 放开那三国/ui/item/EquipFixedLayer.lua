-- Filename：	EquipFixedLayer.lua
-- Author：		李晨阳
-- Date：		2013-7-26
-- Purpose：		装备洗练

module("EquipFixedLayer", package.seeall)

require "script/ui/main/MainScene"
require "script/utils/BaseUI"
require "script/ui/item/EquipFixedData"

kEquipBagType					= 101
kEquipInfoLayerType 			= 102

------------------------[[ 常量 ]]---------------------------

local kNormalTag 			= 1
local kSilverTag 			= 2
local kHighTag	 			= 3

local kEquipList 			= 1
local kEquipInfo 			= 2
local kEquipSuit 			= 3
local parentLayerTag 		= 1
----------------------[[ 模块变量 ]]--------------------------
local mainLayer 			= nil
local layerSize 			= nil 	
local itemId 				= nil
local itemTid 				= nil
local fixedMode 			= nil
local fixedButton 			= nil
local equipInfo 			= nil
local potentialityContainer = nil
local havaFixedStoneLabel 	= nil
local fixButtonMenu			= nil
local cancelButton 			= nil
local cleanButton 			= nil
local isCanFixed 			= nil
local _quality              = nil
function init( ... )
	cleanButton 			= nil
	mainLayer 				= nil
	layerSize 				= nil
	itemId 					= nil
	itemTid 				= nil
	fixedMode				= nil
 	fixedButton 			= nil
 	replaceFixedButton 		= nil
  	equipInfo 				= nil
 	potentialityContainer 	= nil
 	havaFixedStoneLabel 	= nil
 	fixButtonMenu			= nil
 	cancelButton 			= nil
 	EquipFixedData.fixedStoneNum = nil
 	isCanFixed 				= nil
 	_quality                = nil
end

-----------------------[[ ui 创建方法 ]]----------------------

function show( item_id , parent_tag, pQuality )
	init()
	_quality = pQuality
	if(parent_tag ~= nil) then
		parentLayerTag = parent_tag
	end

	equipInfo = ItemUtil.getItemInfoByItemId(item_id)
	if(equipInfo == nil) then
		-- 是否武将身上的装备
		equipInfo = ItemUtil.getEquipInfoFromHeroByItemId( item_id )
	end
	-- print(GetLocalizeStringBy("key_1639"))
	-- print_t(equipInfo)
	if(equipInfo.itemDesc == nil) then
		equipInfo = ItemUtil.getItemInfoByItemId(item_id)
		if(equipInfo == nil) then
			-- 是否武将身上的装备
			equipInfo = ItemUtil.getEquipInfoFromHeroByItemId( item_id )
		end
	end
	

	if(tonumber(equipInfo.itemDesc.fixedPropertyRefreshable) ~= 1) then
		require "script/ui/tip/AlertTip"
        AlertTip.showAlert( GetLocalizeStringBy("key_1565"), nil, false, nil)
        return
	end
	local layer = createLayer(item_id)
	MainScene.changeLayer(layer, "EquipFixedLayer")
end


--[[
	@des	:	创建装备洗练显示层
	@param	: 	itemId,itemTid
	@return :	CCLayer
]]
function createLayer( t_itemId, t_itemTid )

	itemId 		= t_itemId
	itemTid 	= t_itemTid

	-- getEquipFixedInfo(itemId)

	MainScene.setMainSceneViewsVisible(true, false, true)
	local bulletinLayerSize = BulletinLayer.getLayerFactSize()
	local avatarLayerSize 	= MainScene.getAvatarLayerFactSize()
	local menuLayerSize 	= MenuLayer.getLayerFactSize()
	local winSize 			= CCDirector:sharedDirector():getWinSize()
	layerSize 				= CCSizeMake(winSize.width, winSize.height - menuLayerSize.height - bulletinLayerSize.height)

	mainLayer = CCLayer:create()
	mainLayer:setPosition(0, menuLayerSize.height)

	--创建背景
	local fullRect  = CCRectMake(0 , 0, 196, 198)
	local insetRect = CCRectMake(50, 50, 96, 98)
	bgSprite = CCScale9Sprite:create("images/item/equipinfo/bg_9s.png", fullRect, insetRect)
	bgSprite:setPreferredSize(layerSize)
	bgSprite:setAnchorPoint(ccp(0.5, 0))
	bgSprite:setPosition(ccp(layerSize.width*0.5, 0))
	mainLayer:addChild(bgSprite)

	createTopUi()
	--卡牌信息
	local cardPanel = createCardInfo()
	cardPanel:setAnchorPoint(ccp(0.5, 1))
	cardPanel:setPosition(ccp(layerSize.width * 0.5, layerSize.height))
	mainLayer:addChild(cardPanel)
	cardPanel:setScale(g_fScaleX )

	--单选按钮组
	local radioPanel = createRadioMenu()
	radioPanel:setAnchorPoint(ccp(0.5, 0.5))
	local vh = layerSize.height - cardPanel:getContentSize().height * cardPanel:getScaleY()
	radioPanel:setPosition(layerSize.width * 0.5,  vh*3.5/5)
	mainLayer:addChild(radioPanel)
	radioPanel:setScale(g_fScaleX)

	--剩余炼化石
	local surplusFixedStoneTable = {}
	surplusFixedStoneTable[1]	= CCLabelTTF:create(GetLocalizeStringBy("key_2322"), g_sFontName, 23)
	surplusFixedStoneTable[1]:setColor(ccc3(0x78, 0x25, 0x00))
	surplusFixedStoneTable[2]	= CCSprite:create("images/common/fixed_gem.png")
	surplusFixedStoneTable[3]	= CCLabelTTF:create( "x" .. EquipFixedData.getFixedItemCount(), g_sFontName, 21)
	surplusFixedStoneTable[3]:setColor(ccc3(0x00, 0x00, 0x00))
	havaFixedStoneLabel = surplusFixedStoneTable[3]
	local surplusFixedStoneNode  = BaseUI.createHorizontalNode(surplusFixedStoneTable)
	surplusFixedStoneNode:setAnchorPoint(ccp(0.5,  1))
	surplusFixedStoneNode:setPosition(layerSize.width * 0.5, radioPanel:getPositionY()  - radioPanel:getContentSize().height * radioPanel:getScaleY()/2 - 10 * MainScene.elementScale)
	mainLayer:addChild(surplusFixedStoneNode)
	surplusFixedStoneNode:setScale(MainScene.elementScale)

	createFixedMenu()

	updateEquipPotentiality()
	return mainLayer
end

--[[
	@des	:	创建标题
]]
function createTopUi( ... )

	--  上标题栏 显示战斗力，银币，金币

	require "script/model/user/UserModel"
    local userInfo = UserModel.getUserInfo()
    if userInfo == nil then
        return
    end
	
-- 	_topBg = CCSprite:create("images/hero/avatar_attr_bg.png")
--     _topBg:setAnchorPoint(ccp(0,1))
--     _topBg:setPosition(0,layerSize.height)
--     _topBg:setScale(g_fScaleX)
--     mainLayer:addChild(_topBg, 10)
--     titleSize = _topBg:getContentSize()

--     local lvSp = CCSprite:create("images/common/lv.png")
--     lvSp:setAnchorPoint(ccp(0.5,0.5))
--     lvSp:setPosition(_topBg:getContentSize().width*0.08,_topBg:getContentSize().height*0.43)
--     _topBg:addChild(lvSp)
    
-- --   	lvLabel = CCRenderLabel:create( userInfo.level , g_sFontName, 23, 1.5, ccc3( 0x00, 0x00, 0x00), type_stroke)
-- 	local lvLabel = CCLabelTTF:create(userInfo.level , g_sFontName, 23)
--     lvLabel:setColor(ccc3(0xff, 0xf6, 0x00))
--     lvLabel:setAnchorPoint(ccp(0.5,0.5))
--     lvLabel:setPosition(_topBg:getContentSize().width*0.08+lvSp:getContentSize().width ,_topBg:getContentSize().height*0.43)
--     _topBg:addChild(lvLabel)

-- --    local nameLabel= CCRenderLabel:create( UserModel.getUserName(), g_sFontName, 23, 1,ccc3(0,0,0), type_stroke)
-- 	local nameLabel= CCLabelTTF:create(UserModel.getUserName(), g_sFontName, 23)
--     nameLabel:setPosition(_topBg:getContentSize().width*0.18, _topBg:getContentSize().height*0.43)
--     nameLabel:setAnchorPoint(ccp(0,0.5))
--     nameLabel:setColor(ccc3(0x70,0xff,0x18))
--     _topBg:addChild(nameLabel)

--     local vipSp = CCSprite:create ("images/common/vip.png")
-- 	vipSp:setPosition(_topBg:getContentSize().width*0.372, _topBg:getContentSize().height*0.43)
-- 	vipSp:setAnchorPoint(ccp(0,0.5))
-- 	_topBg:addChild(vipSp)

--     -- VIP对应级别
--     require "script/libs/LuaCC"
--     local vipNumSp = LuaCC.createSpriteOfNumbers("images/main/vip", UserModel.getVipLevel() , 23)
--     vipNumSp:setPosition(_topBg:getContentSize().width*0.382+vipSp:getContentSize().width, _topBg:getContentSize().height*0.43)
--     vipNumSp:setAnchorPoint(ccp(0,0.5))
--     _topBg:addChild(vipNumSp)
    
--     _silverLabel = CCLabelTTF:create( userInfo.silver_num,g_sFontName,18)
--     _silverLabel:setColor(ccc3(0xe5,0xf9,0xff))
--     _silverLabel:setAnchorPoint(ccp(0,0.5))
--     _silverLabel:setPosition(_topBg:getContentSize().width*0.61,_topBg:getContentSize().height*0.43)
--     _topBg:addChild(_silverLabel)
    
--     _goldLabel = CCLabelTTF:create( userInfo.gold_num,g_sFontName,18)
--     _goldLabel:setColor(ccc3(0xff,0xe2,0x44))
--     _goldLabel:setAnchorPoint(ccp(0,0.5))
--     _goldLabel:setPosition(_topBg:getContentSize().width*0.82,_topBg:getContentSize().height*0.43)
--     _topBg:addChild(_goldLabel)

	_topBg,_silverLabel,_goldLabel = HeroUtil.createNewAttrBgSprite(userInfo.level,UserModel.getUserName(),UserModel.getVipLevel(),userInfo.silver_num,userInfo.gold_num)
    _topBg:setAnchorPoint(ccp(0,1))
    _topBg:setPosition(0,layerSize.height)
    _topBg:setScale(g_fScaleX)
    mainLayer:addChild(_topBg, 10)

	-- 顶部
	local topSprite = CCSprite:create("images/item/equipinfo/topbg.png")
	topSprite:setAnchorPoint(ccp(0.5, 1))
	topSprite:setPosition(ccp(bgSprite:getContentSize().width*0.5, bgSprite:getContentSize().height - _topBg:getContentSize().height * _topBg:getScaleY()))
	topSprite:setScale(g_fScaleX)
	mainLayer:addChild(topSprite, 2)

	-- 标题
	local titleLabel = CCRenderLabel:create(GetLocalizeStringBy("key_3143"), g_sFontPangWa, 35, 1, ccc3( 0x00, 0x00, 0x00), type_stroke)
    titleLabel:setColor(ccc3(0xff, 0xe4, 0x00))
    titleLabel:setAnchorPoint(ccp(0.5, 0.5))
    titleLabel:setPosition(ccp( ( topSprite:getContentSize().width)/2, topSprite:getContentSize().height*0.55))
    topSprite:addChild(titleLabel)

    local menu = CCMenu:create()
	menu:setPosition(ccp(0, 0))
	menu:setAnchorPoint(ccp(0,0))
	menu:setTouchPriority(-800)
	topSprite:addChild(menu)

	local closeButton = CCMenuItemImage:create("images/common/btn_close_n.png","images/common/btn_close_h.png")
	closeButton:setPosition(ccp(topSprite:getContentSize().width * 0.96, topSprite:getContentSize().height * 0.5))
	closeButton:setAnchorPoint(ccp(0.5, 0.5))
	closeButton:registerScriptTapHandler(closeCallback)
	menu:addChild(closeButton)

	--更新layerSize
	layerSize = CCSizeMake(layerSize.width, layerSize.height - _topBg:getContentSize().height * _topBg:getScaleY() - topSprite:getContentSize().height * topSprite:getScaleY())
end

--[[
	@des	:	创建装备图标以及装备信息
]]
function createCardInfo( ... )
	local panle 	 = CCScale9Sprite:create("images/common/bg/bg_ng_attr.png")
	panle:setContentSize(CCSizeMake(600, 300))

	local t_numerial, t_numerial_PL
	t_numerial, t_numerial_PL, t_equip_score = ItemUtil.getTop2NumeralByIID(itemId)
	local cardSprite = EquipCardSprite.createSprite(nil, itemId, _quality)
	cardSprite:setAnchorPoint(ccp(0, 0.5))
	cardSprite:setPosition(ccp(10, panle:getContentSize().height * 0.5))
	panle:addChild(cardSprite)
	cardSprite:setScale((panle:getContentSize().height - 20) /cardSprite:getContentSize().height)

	--装备属性显示面板
	local infoPanle  = CCScale9Sprite:create("images/common/bg/white_text_ng.png")
	infoPanle:setContentSize(CCSizeMake(panle:getContentSize().width - cardSprite:getContentSize().width + 80, panle:getContentSize().height - 30))
	infoPanle:setAnchorPoint(ccp(1, 0.5))
	infoPanle:setPosition(ccp(panle:getContentSize().width - 10, panle:getContentSize().height * 0.5))
	panle:addChild(infoPanle)

	potentialityContainer = CCNode:create()
	potentialityContainer:setContentSize(infoPanle:getContentSize())
	infoPanle:addChild(potentialityContainer)

	return panle
end

--[[
	@des:	创建洗练档次选择按钮
]]
function createRadioMenu( ... )
	local bgPanel =  CCScale9Sprite:create("images/common/bg/white_text_ng.png")
	bgPanel:setContentSize(CCSizeMake(564, 180))
	
	local btMenu  = CCMenu:create()
	btMenu:setPosition(ccp(0, 0))
	btMenu:setAnchorPoint(ccp(0, 0))
	bgPanel:addChild(btMenu)

	normalFixedButton = CCMenuItemImage:create("images/common/btn/radio_normal.png","images/common/btn/radio_selected.png")
	normalFixedButton:setPosition(45, bgPanel:getContentSize().height * 0.85)
	normalFixedButton:setAnchorPoint(ccp(0.5, 0.5))
	normalFixedButton:registerScriptTapHandler(radioCallback)
	btMenu:addChild(normalFixedButton, 1, kNormalTag)

	silverFixedButton = CCMenuItemImage:create("images/common/btn/radio_normal.png","images/common/btn/radio_selected.png")
	silverFixedButton:setPosition(45, bgPanel:getContentSize().height * 0.5)
	silverFixedButton:setAnchorPoint(ccp(0.5, 0.5))
	silverFixedButton:registerScriptTapHandler(radioCallback)
	btMenu:addChild(silverFixedButton, 1, kSilverTag)

	highFixedButton   = CCMenuItemImage:create("images/common/btn/radio_normal.png","images/common/btn/radio_selected.png")
	highFixedButton:setPosition(45, bgPanel:getContentSize().height * 0.15)
	highFixedButton:setAnchorPoint(ccp(0.5, 0.5))
	highFixedButton:registerScriptTapHandler(radioCallback)
	btMenu:addChild(highFixedButton, 1,	kHighTag)

	--设置默认选择
	normalFixedButton:selected()
	fixedMode = kNormalTag
	
	--洗练级别描述
	local normalCostInfo= EquipFixedData.getFixedCost(equipInfo.itemDesc.fixedPotentialityID, 1)
	local normalDesTable= {}
	normalDesTable[1]	=  CCSprite:create("images/item/equipFixed/normal_fixed.png")
	normalDesTable[2]	=  CCNode:create()
	normalDesTable[2]:setContentSize(CCSizeMake(25, 15))
	normalDesTable[3]	=	CCLabelTTF:create(GetLocalizeStringBy("key_2062"), g_sFontName, 21)
	normalDesTable[3]:setColor(ccc3(0x78, 0x25, 0x00))
	normalDesTable[4]	=  CCNode:create()
	normalDesTable[4]:setContentSize(CCSizeMake(15, 15))
	normalDesTable[5]	=	CCSprite:create("images/common/fixed_gem.png")
	normalDesTable[6]	=	CCRenderLabel:create( normalCostInfo.item.num , g_sFontName, 23, 1, ccc3( 0x00, 0x00, 0x00), type_stroke)
	normalDesTable[6]:setColor(ccc3(0x00, 0xe4, 0xff))

	local silverCostInfo= EquipFixedData.getFixedCost(equipInfo.itemDesc.fixedPotentialityID, 2)
	local silverDesTable= {}
	silverDesTable[1]	=  CCSprite:create("images/item/equipFixed/silver_fixed.png")
	silverDesTable[2]	=  CCNode:create()
	silverDesTable[2]:setContentSize(CCSizeMake(25, 15))

	silverDesTable[3]	= CCLabelTTF:create(GetLocalizeStringBy("key_2712"), g_sFontName, 21)
	silverDesTable[3]:setColor(ccc3(0x78, 0x25, 0x00))
	silverDesTable[4]	=  CCNode:create()
	silverDesTable[4]:setContentSize(CCSizeMake(15, 15))

	silverDesTable[5]	= CCSprite:create("images/common/coin_silver.png")
	silverDesTable[6]	= CCRenderLabel:create( silverCostInfo.silver, g_sFontName, 23, 1, ccc3( 0x00, 0x00, 0x00), type_stroke)
	silverDesTable[6]:setColor(ccc3(0x00, 0xff, 0x18))
	silverDesTable[7]	=  CCNode:create()
	silverDesTable[7]:setContentSize(CCSizeMake(15, 15))

	silverDesTable[8]	=	CCSprite:create("images/common/fixed_gem.png")
	silverDesTable[9]	=	CCRenderLabel:create( silverCostInfo.item.num , g_sFontName, 23, 1, ccc3( 0x00, 0x00, 0x00), type_stroke)
	silverDesTable[9]:setColor(ccc3(0x00, 0xe4, 0xff))

	local goldCostInfo  = EquipFixedData.getFixedCost(equipInfo.itemDesc.fixedPotentialityID, 3)
	local highDesTable  = {}
	highDesTable[1]	 	=  CCSprite:create("images/item/equipFixed/high_fixed.png")
	highDesTable[2]	 	=  CCNode:create()
	highDesTable[2]:setContentSize(CCSizeMake(25, 15))
	highDesTable[3]	 	= CCLabelTTF:create(GetLocalizeStringBy("key_2712"), g_sFontName, 21)
	highDesTable[3]:setColor(ccc3(0x78, 0x25, 0x00))
	highDesTable[4]	 	=  CCNode:create()
	highDesTable[4]:setContentSize(CCSizeMake(15, 15))
	highDesTable[5]	 	= CCSprite:create("images/common/gold.png")
	highDesTable[6]	 	= CCRenderLabel:create( goldCostInfo.gold , g_sFontName, 23, 1, ccc3( 0x00, 0x00, 0x00), type_stroke)
	highDesTable[6]:setColor(ccc3(0x00, 0xff, 0x18))
	highDesTable[7]	 	=  CCNode:create()
	highDesTable[7]:setContentSize(CCSizeMake(15, 15))
	highDesTable[8]	 	=	CCSprite:create("images/common/fixed_gem.png")
	highDesTable[9]	 	=	CCRenderLabel:create( goldCostInfo.item.num , g_sFontName, 23, 1, ccc3( 0x00, 0x00, 0x00), type_stroke)
	highDesTable[9]:setColor(ccc3(0x00, 0xe4, 0xff))

	local normalDesNode = BaseUI.createHorizontalNode(normalDesTable)
	normalDesNode:setAnchorPoint(ccp(0, 0.5))
	normalDesNode:setPosition(85, normalFixedButton:getPositionY())
	bgPanel:addChild(normalDesNode)

	local silverDesNode = BaseUI.createHorizontalNode(silverDesTable)
	silverDesNode:setAnchorPoint(ccp(0, 0.5))
	silverDesNode:setPosition(85, silverFixedButton:getPositionY())
	bgPanel:addChild(silverDesNode)

	local highDesNode  	= BaseUI.createHorizontalNode(highDesTable)
	highDesNode:setAnchorPoint(ccp(0, 0.5))
	highDesNode:setPosition(85, highFixedButton:getPositionY())
	bgPanel:addChild(highDesNode)
	return bgPanel
end

--[[
	@des: 创建洗练和替换按钮
]]
function createFixedMenu( ... )
	fixButtonMenu = CCMenu:create()
	fixButtonMenu:setPosition(ccp(0, 0))
	fixButtonMenu:setAnchorPoint(ccp(0, 0))
	mainLayer:addChild(fixButtonMenu)

	--兼容越南 东南亚英文版
	local fontSize = nil
	if(Platform.getLayout ~= nil and Platform.getLayout() == "enLayout" ) then
		fontSize = 25
	end
	local  fixedButton1 		= LuaCC.create9ScaleMenuItem("images/common/btn/btn1_d.png","images/common/btn/btn1_n.png",CCSizeMake(195,73),GetLocalizeStringBy("key_2487"),ccc3(255,222,0),fontSize)
	fixedButton1:setPosition(ccp(layerSize.width * 0.20, 10 * MainScene.elementScale))
	fixedButton1:setAnchorPoint(ccp(0.5, 0))
	fixedButton1:registerScriptTapHandler(fixedCallback)
	fixButtonMenu:addChild(fixedButton1, 1, 1)
	fixedButton1:setScale(MainScene.elementScale)
	
	--兼容越南 东南亚英文版
	local fontSize = nil
	if(Platform.getLayout ~= nil and Platform.getLayout() == "enLayout" ) then
		fontSize = 25
	end
	local fixedButton5 		= LuaCC.create9ScaleMenuItem("images/common/btn/btn1_d.png","images/common/btn/btn1_n.png",CCSizeMake(195,73),GetLocalizeStringBy("key_2493"),ccc3(255,222,0),fontSize)
	fixedButton5:setPosition(ccp(layerSize.width * 0.5, 10 * MainScene.elementScale))
	fixedButton5:setAnchorPoint(ccp(0.5, 0))
	fixedButton5:registerScriptTapHandler(fixedCallback)
	fixButtonMenu:addChild(fixedButton5, 1, 5)
	fixedButton5:setScale(MainScene.elementScale)

	--兼容越南 东南亚英文版
	local fontSize = nil
	if(Platform.getLayout ~= nil and Platform.getLayout() == "enLayout" ) then
		fontSize = 25
	end

	local limitNum = tonumber(DB_Normal_config.getDataById(1).strengthen_potential)
    local userLevel = UserModel.getAvatarLevel()
    local fixedButton10 = nil
    if(userLevel<limitNum)then
		fixedButton10 = LuaCC.create9ScaleMenuItem("images/common/btn/btn1_d.png","images/common/btn/btn1_n.png",CCSizeMake(195,73),GetLocalizeStringBy("key_1803"),ccc3(255,222,0),fontSize)
		fixedButton10:setPosition(ccp(layerSize.width * 0.8, 10 * MainScene.elementScale))
		fixedButton10:setAnchorPoint(ccp(0.5, 0))
		fixedButton10:registerScriptTapHandler(fixedCallback)
		fixButtonMenu:addChild(fixedButton10, 1, 10)
		fixedButton10:setScale(MainScene.elementScale)
	else
		fixedButton10 = LuaCC.create9ScaleMenuItem("images/common/btn/btn_purple2_n.png","images/common/btn/btn_purple2_h.png",CCSizeMake(195,73),GetLocalizeStringBy("llp_512"),ccc3(255,222,0),fontSize)
		fixedButton10:setPosition(ccp(layerSize.width * 0.8, 10 * MainScene.elementScale))
		fixedButton10:setAnchorPoint(ccp(0.5, 0))
		fixedButton10:registerScriptTapHandler(cleanCallback)
		fixButtonMenu:addChild(fixedButton10, 1, 11)
		fixedButton10:setScale(MainScene.elementScale)
	end

	replaceFixedButton 	= LuaCC.create9ScaleMenuItem("images/common/btn/btn_violet_n.png","images/common/btn/btn_violet_h.png",CCSizeMake(195,73),GetLocalizeStringBy("key_2370"),ccc3(255,222,0))
	replaceFixedButton:setPosition(ccp(layerSize.width * 0.8, 10 * MainScene.elementScale))
	replaceFixedButton:setAnchorPoint(ccp(0.5, 0))
	replaceFixedButton:registerScriptTapHandler(replaceCallback)
	fixButtonMenu:addChild(replaceFixedButton)
	replaceFixedButton:setScale(MainScene.elementScale)
	replaceFixedButton:setVisible(false)

	cancelButton = LuaCC.create9ScaleMenuItem("images/common/btn/btn1_d.png","images/common/btn/btn1_n.png",CCSizeMake(195,73),GetLocalizeStringBy("key_2326"),ccc3(255,222,0))
	cancelButton:setPosition(ccp(layerSize.width * 0.2, 10 * MainScene.elementScale))
	cancelButton:setAnchorPoint(ccp(0.5, 0))
	cancelButton:registerScriptTapHandler(cancelCallback)
	fixButtonMenu:addChild(cancelButton)
	cancelButton:setScale(MainScene.elementScale)
	cancelButton:setVisible(false)
	if(getLastFixedTimes() == 1) then
		fixedButton = fixedButton1
	elseif(getLastFixedTimes() == 5) then
		fixedButton = fixedButton5
	elseif(getLastFixedTimes() == 10) then
		fixedButton = fixedButton10
	else
		fixedButton = fixedButton10
	end

end
-----------------------------------[[ ui 更新方法 ]] -------------------------------

function updateFixedButtons( ... )

end

function updateHaveItem( ... )
	
	havaFixedStoneLabel:setString("x" .. tostring(EquipFixedData.getFixedItemCount()))

	_silverLabel:setString(string.convertSilverUtilByInternational(UserModel.getSilverNumber()))
	_goldLabel:setString(UserModel.getGoldNumber())
end


function updateEquipPotentiality( ... )
	potentialityContainer:removeAllChildrenWithCleanup(true)
	local potentInfo = EquipFixedData.getEquipFixedInfo(itemId, fixedMode)

	-- print("updateEquipPotentiality potentInfo:")
	-- print_t(potentInfo)
	
	local quality = nil
    if _quality ~= nil and _quality ~= -1 then
        quality = _quality
    else
        quality = ItemUtil.getEquipQualityByItemInfo(equipInfo)
    end
    if quality == nil then
        quality = potentInfo.desc.quality
    end
	local nameColor = HeroPublicLua.getCCColorByStarLevel(quality)
	local nameLabel = CCRenderLabel:create( potentInfo.name, g_sFontPangWa, 25, 1, ccc3( 0x00, 0x00, 0x00), type_stroke)
	nameLabel:setColor(nameColor)
	nameLabel:setAnchorPoint(ccp(0.5, 1))
	nameLabel:setPosition(ccp(potentialityContainer:getContentSize().width * 0.5, potentialityContainer:getContentSize().height - 15))
	potentialityContainer:addChild(nameLabel)
	
	local leveTable = {}
	leveTable[1] = CCSprite:create("images/common/lv.png")
	leveTable[2] = CCRenderLabel:create( potentInfo.level, g_sFontName, 23, 1, ccc3( 0x00, 0x00, 0x00), type_stroke)
	leveTable[2]:setColor(ccc3(0xff, 0xf6, 0x00))

	local levelNode = BaseUI.createHorizontalNode(leveTable)
	levelNode:setAnchorPoint(ccp(1, 0))
	levelNode:setPosition(potentialityContainer:getContentSize().width - 10, nameLabel:getPositionY() - nameLabel:getContentSize().height)
	potentialityContainer:addChild(levelNode)
	

	if(potentInfo.isHaveFixed == true) then
		for i=1,table.maxn(potentInfo.fixedInfo) do
			local v = potentInfo.fixedInfo[i]
			local potentialityNameLabel = CCLabelTTF:create(v.name .. ":", g_sFontName, 23)
			potentialityNameLabel:setColor(ccc3(0x78, 0x25, 0x00))
			potentialityNameLabel:setAnchorPoint(ccp(1, 0))
			potentialityNameLabel:setPosition(ccp(105, potentialityContainer:getContentSize().height - 50 - 43 * i))
			potentialityContainer:addChild(potentialityNameLabel)

			local baseValueLabel = CCLabelTTF:create((v.baseValue or ""), g_sFontName, 23)
			baseValueLabel:setColor(ccc3(0x00, 0x00, 0x00))
			baseValueLabel:setAnchorPoint(ccp(0, 0))
			baseValueLabel:setPosition(ccp(110, potentialityNameLabel:getPositionY()))
			potentialityContainer:addChild(baseValueLabel)
			if(v.baseValue == nil) then
				potentialityNameLabel:setColor(ccc3(0x00, 0x70, 0xae))
			end


			local potentialityLabel =  CCLabelTTF:create("(+" .. (v.potentiality or 0 ), g_sFontName, 23)
			potentialityLabel:setColor(ccc3(0x00, 0x70, 0xae))
			potentialityLabel:setAnchorPoint(ccp(0, 0))
			potentialityLabel:setPosition(ccp(178, potentialityNameLabel:getPositionY()))
			potentialityContainer:addChild(potentialityLabel)

			local potentialityFixedLabel =  CCLabelTTF:create((v.fixedPotentiality or 0 ).. "", g_sFontName, 23)
			potentialityFixedLabel:setColor(ccc3(0x00, 0x83, 0x38))
			potentialityFixedLabel:setAnchorPoint(ccp(0, 0))
			potentialityFixedLabel:setPosition(ccp(257, potentialityNameLabel:getPositionY()))
			potentialityContainer:addChild(potentialityFixedLabel)

			if(v.fixedPotentiality ~= nil and tonumber(v.fixedPotentiality) < 0) then
				potentialityFixedLabel:setColor(ccc3(0xFF, 0x00, 0x00))
			end

			local upSprite = nil
			if(v.fixedPotentiality ~= nil and tonumber(v.fixedPotentiality) > 0) then
				upSprite = CCSprite:create("images/item/equipFixed/up.png")
				upSprite:setAnchorPoint(ccp(0, 0))
				upSprite:setPosition(potentialityFixedLabel:getPositionX() + potentialityFixedLabel:getContentSize().width + 10, potentialityFixedLabel:getPositionY())
				potentialityContainer:addChild(upSprite)
			elseif(v.fixedPotentiality ~= nil and tonumber(v.fixedPotentiality) < 0) then
				upSprite = CCSprite:create("images/item/equipFixed/down.png")
				upSprite:setAnchorPoint(ccp(0, 0))
				upSprite:setPosition(potentialityFixedLabel:getPositionX() + potentialityFixedLabel:getContentSize().width + 10, potentialityFixedLabel:getPositionY())
				potentialityContainer:addChild(upSprite)
			else

			end				
			if(v.fixedPotentiality ~= nil and tonumber(v.fixedPotentiality) == 0 and v.potentiality ~= nil and tonumber(v.potentiality) >= tonumber(v.maxFixed)) then
				potentialityFixedLabel:setString(GetLocalizeStringBy("key_3187"))
				if(upSprite ~= nil) then
					upSprite:setVisible(false)
				end
			end

			local leftKh = CCLabelTTF:create(")", g_sFontName, 23)
			leftKh:setColor(ccc3(0x00, 0x70, 0xae))
			leftKh:setAnchorPoint(ccp(0, 0))
			leftKh:setPosition(ccp(potentialityFixedLabel:getPositionX()+potentialityFixedLabel:getContentSize().width, potentialityFixedLabel:getPositionY()))
			potentialityContainer:addChild(leftKh)

			if(tonumber(v.potentiality or 0) >= tonumber(v.maxFixed or 0)) then
				isCanFixed = true
			end

		end
		print("have fixed info")
		fixedButton:setPosition(ccp(layerSize.width * 0.5, 10 * MainScene.elementScale))
		setAllVisible(false)
		fixedButton:setVisible(true)
		replaceFixedButton:setVisible(true)
		cancelButton:setVisible(true)
	else
		for i=1,table.maxn(potentInfo.fixedInfo) do
			local v = potentInfo.fixedInfo[i]
			local potentialityNameLabel = CCLabelTTF:create(v.name .. ":", g_sFontName, 23)
			potentialityNameLabel:setColor(ccc3(0x78, 0x25, 0x00))
			potentialityNameLabel:setAnchorPoint(ccp(1, 0))
			potentialityNameLabel:setPosition(ccp(105, potentialityContainer:getContentSize().height - 50 - 43 * i))
			potentialityContainer:addChild(potentialityNameLabel)

			local baseValueLabel = CCLabelTTF:create((v.baseValue or ""), g_sFontName, 23)
			baseValueLabel:setColor(ccc3(0x00, 0x00, 0x00))
			baseValueLabel:setAnchorPoint(ccp(0, 0))
			baseValueLabel:setPosition(ccp(110, potentialityNameLabel:getPositionY()))
			potentialityContainer:addChild(baseValueLabel)
			if(v.baseValue == nil) then
				potentialityNameLabel:setColor(ccc3(0x00, 0x70, 0xae))
			end

			local potentialityLabel =  CCLabelTTF:create("(+" .. (v.potentiality or 0 ).. "", g_sFontName, 23)
			potentialityLabel:setColor(ccc3(0x00, 0x70, 0xae))
			potentialityLabel:setAnchorPoint(ccp(0, 0))
			potentialityLabel:setPosition(ccp(178, potentialityNameLabel:getPositionY()))
			potentialityContainer:addChild(potentialityLabel)

			local maxedLabel =  CCLabelTTF:create(GetLocalizeStringBy("key_1987") .. (v.maxFixed or 0) .. "", g_sFontName, 23)
			maxedLabel:setColor(ccc3(0xd6, 0x00, 0x00))
			maxedLabel:setAnchorPoint(ccp(0, 0))
			maxedLabel:setPosition(ccp(257, potentialityNameLabel:getPositionY()))
			potentialityContainer:addChild(maxedLabel)

			local leftKh = CCLabelTTF:create(")", g_sFontName, 23)
			leftKh:setColor(ccc3(0x00, 0x70, 0xae))
			leftKh:setAnchorPoint(ccp(0, 0))
			leftKh:setPosition(ccp(maxedLabel:getPositionX()+maxedLabel:getContentSize().width, maxedLabel:getPositionY()))
			potentialityContainer:addChild(leftKh)


			if(tonumber(v.potentiality or 0) >= tonumber(v.maxFixed or 0)) then
				isCanFixed = true
			end
		end
		print("Don't have fixed info")
		setAllVisible(true)
		updateFixedButtonPos()
		replaceFixedButton:setVisible(false)
		cancelButton:setVisible(false)
	end

	local messageLabel = CCRenderLabel:create(GetLocalizeStringBy("key_2632"), g_sFontPangWa, 23,1.5, ccc3( 0x00, 0x00, 0x00), type_stroke)
	messageLabel:setPosition(potentialityContainer:getContentSize().width/2, 25)
	messageLabel:setColor(ccc3(0,255,0))
	messageLabel:setAnchorPoint(ccp(0.5, 0.5))
	potentialityContainer:addChild(messageLabel)

	-- fixedInfo{
	-- 	id:
	-- 	name:
	-- 	baseValue:
	-- 	potentiality:
	-- 	fixedPotentiality:
	-- 	maxFixed:
	-- }
end


function updateFixedButtonPos( ... )
	if(fixedButton:getTag() == 1) then
		fixedButton:setPosition(ccp(layerSize.width * 0.20, 10 * MainScene.elementScale))
	elseif(fixedButton:getTag() == 5) then
		fixedButton:setPosition(ccp(layerSize.width * 0.50, 10 * MainScene.elementScale))
	elseif(fixedButton:getTag() == 10) then
		fixedButton:setPosition(ccp(layerSize.width * 0.80, 10 * MainScene.elementScale))
	else
		fixedButton:setPosition(ccp(layerSize.width * 0.80, 10 * MainScene.elementScale))
	end
end


-----------------------------------[[ 回调事件处理 ]] -------------------------------
--[[
	@des:	关闭按钮回调事件
]]
function closeCallback( tag ,sender )
	require "script/audio/AudioUtil"
    AudioUtil.playEffect("audio/effect/guanbi.mp3")
	EquipFixedData.fixedStoneNum = nil

	print("parentLayerTag", parentLayerTag)

	if(parentLayerTag == kEquipInfoLayerType) then
		require("script/ui/formation/FormationLayer")
    	local formationLayer = FormationLayer.createLayer(FormationLayer.getLastSelectHeroId())
    	MainScene.changeLayer(formationLayer, "formationLayer")
	else
		require "script/ui/bag/BagLayer"
		local bagLayer = BagLayer.createLayer(BagLayer.Tag_Init_Arming)
		MainScene.changeLayer(bagLayer, "bagLayer")
	end
end

--[[
	@des:	单选按钮回调事件
]]
function radioCallback( tag, sender )
  	require "script/audio/AudioUtil"
	AudioUtil.playEffect("audio/effect/zhujiemian.mp3")
	fixedMode	=	sender:getTag()
	print("now fixedMode = ", tag)

	if(fixedMode == kNormalTag) then
		normalFixedButton:selected()
		silverFixedButton:unselected()
		highFixedButton:unselected()
	elseif(fixedMode == kSilverTag) then
		normalFixedButton:unselected()
		silverFixedButton:selected()
		highFixedButton:unselected()
	elseif(fixedMode == kHighTag) then
		normalFixedButton:unselected()
		silverFixedButton:unselected()
		highFixedButton:selected()
	end
	updateEquipPotentiality()
end


--[[
	@des:  洗练按钮回调事件
]]
function fixedCallback( tag , sender)
	require "script/audio/AudioUtil"
	AudioUtil.playEffect("audio/effect/zhujiemian.mp3")
	if(isCanFixed) then
		AlertTip.showAlert(GetLocalizeStringBy("lcy_10044"),nil)
		return
	end
	
	print("sender, tag:", sender, tag)
	local fixTimes = tag
 	local updateButtonPos = function ( ... )
 		fixedButton = tolua.cast(sender, "CCMenuItem")
 		fixedButton:setTag(tag)
		--隐藏替他按钮
		setAllVisible(false)
		fixedButton:setVisible(true)
		saveLastFixedTimes(fixTimes)
 	end

	require "script/ui/item/EquipFixedService"
	local requstCallback = function ( ... )
		equipInfo = ItemUtil.getItemInfoByItemId(itemId)
		if(equipInfo == nil) then
			-- 是否武将身上的装备
			equipInfo = ItemUtil.getEquipInfoFromHeroByItemId( itemId )
		end
		updateButtonPos()
		updateEquipPotentiality()
		updateHaveItem()
		playEffct()
		-- print(GetLocalizeStringBy("key_3123"))
		-- print_t(equipInfo)
	end
	print("fixTimes:", fixTimes)

	EquipFixedService.fixedRefresh(itemId, fixedMode, fixTimes, requstCallback)
end


--[[
   @des:	替换按钮回调事件
]]
function replaceCallback( tag, sender )
	require "script/audio/AudioUtil"
	AudioUtil.playEffect("audio/effect/zhujiemian.mp3")
	 local updateButtonPos = function ( ... )
 		local replaceButton = tolua.cast(sender, "CCMenuItem")
		--显示替他按钮
		setAllVisible(true)
		replaceFixedButton:setVisible(false)
		cancelButton:setVisible(false)
 	end

	require "script/ui/item/EquipFixedService"
	local requstCallback = function ( ... )
		updateEquipPotentiality()
		updateHaveItem()
		updateButtonPos()
	end
	EquipFixedService.fixedRefreshAffirm(itemId, requstCallback)
end

--[[
	@des:	取消按钮回调事件
]]
function cancelCallback( ... )
	require "script/audio/AudioUtil"
	AudioUtil.playEffect("audio/effect/zhujiemian.mp3")
	require "script/ui/tip/AlertTip"
	AlertTip.showAlert(GetLocalizeStringBy("key_2660"), function ( isConfirm )
		if(isConfirm) then
			setAllVisible(true)
			replaceFixedButton:setVisible(false)
			cancelButton:setVisible(false)
			updateFixedButtonPos()
			EquipFixedData.clearEquipFixedInfo(itemId)
			updateEquipPotentiality()
		end
	end, true)
end

function cleanCallback( ... )
	local potentInfo = EquipFixedData.getEquipFixedInfo(itemId, fixedMode)
	local isCanFix = false
	for i=1,table.maxn(potentInfo.fixedInfo) do
			local v = potentInfo.fixedInfo[i]
			if(tonumber(v.potentiality or 0) >= tonumber(v.maxFixed or 0)) then
				isCanFix = true
			end
		end
	if(isCanFix) then
		AlertTip.showAlert(GetLocalizeStringBy("lcy_10044"),nil)
		return
	end
	local isCancle = cancelButton:isVisible()
	if(isCancle)then
		local yesCallBack = function ()
	        replaceCallback()
	    end

	    local tipNode = CCNode:create()
	    tipNode:setContentSize(CCSizeMake(400,100))
	   
	    local textInfo = {
	            width = 340, -- 宽度
	            alignment = 1, -- 对齐方式  1 左对齐，2 居中， 3右对齐
	            labelDefaultFont = g_sFontName,      -- 默认字体
	            labelDefaultSize = 25,          -- 默认字体大小
	            labelDefaultColor = ccc3(0x78,0x25,0x00),
	            linespace = 10, -- 行间距
	            defaultType = "CCLabelTTF",
	            elements =
	            {   
	            }
	        }
	    local tipDes = GetLocalizeLabelSpriteBy_2("llp_514", textInfo)
	    tipDes:setAnchorPoint(ccp(0.5, 0.5))
	    tipDes:setPosition(ccp(tipNode:getContentSize().width*0.5,tipNode:getContentSize().height*0.5))
	    tipNode:addChild(tipDes)
	    require "script/ui/tip/TipByNode"
	    local callBack = function()
	    	local yesCallBack = function ()
	    		local nextCallFun = function ( pNum )
	    			replaceCallback()
	    			require "script/ui/item/EquipTipNode"
	    			EquipTipNode.showLayer(itemId,fixedMode,pNum)
	    		end
	    		require "script/ui/item/EquipFixedService"
		        EquipFixedService.fixedOneKey(itemId, fixedMode, nextCallFun)
		    end

		    local tipNode = CCNode:create()
		    tipNode:setContentSize(CCSizeMake(400,100))

		    local imageTable = {"images/item/equipFixed/normal_fixed.png",
		    					"images/item/equipFixed/silver_fixed.png",
		    					"images/common/coin_silver.png"
								}
		    
		    local textInfo = {
		            width = 340, -- 宽度
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
		                    image = imageTable[fixedMode],
		                }
		            }
		        }
		    local tipDes = GetLocalizeLabelSpriteBy_2("llp_513", textInfo)
		    tipDes:setAnchorPoint(ccp(0.5, 0.5))
		    tipDes:setPosition(ccp(tipNode:getContentSize().width*0.5,tipNode:getContentSize().height*0.5))
		    tipNode:addChild(tipDes)
		    require "script/ui/tip/TipByNode"
		    TipByNode.showLayer(tipNode,yesCallBack,CCSizeMake(440,340),-2000)
	    end
	    TipByNode.showLayer(tipNode,yesCallBack,CCSizeMake(440,340),-2000,nil,callBack)
	else
		local yesCallBack = function ()
			local nextCallFun = function ( pNum )
    			replaceCallback()
    			require "script/ui/item/EquipTipNode"
	    		EquipTipNode.showLayer(itemId,fixedMode,pNum)
    		end
    		require "script/ui/item/EquipFixedService"
	        EquipFixedService.fixedOneKey(itemId, fixedMode, nextCallFun)
	    end

	    local tipNode = CCNode:create()
	    tipNode:setContentSize(CCSizeMake(400,100))

	    local imageTable = {"images/item/equipFixed/normal_fixed.png",
	    					"images/item/equipFixed/silver_fixed.png",
	    					"images/item/equipFixed/high_fixed.png"
							}
	    
	    local textInfo = {
	            width = 340, -- 宽度
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
	                    image = imageTable[fixedMode],
	                }
	            }
	        }
	    local tipDes = GetLocalizeLabelSpriteBy_2("llp_513", textInfo)
	    tipDes:setAnchorPoint(ccp(0.5, 0.5))
	    tipDes:setPosition(ccp(tipNode:getContentSize().width*0.5,tipNode:getContentSize().height*0.5))
	    tipNode:addChild(tipDes)
	    require "script/ui/tip/TipByNode"
	    TipByNode.showLayer(tipNode,yesCallBack,CCSizeMake(440,340),-2000)
	end
end

--------------------------------------[[ 特效播放 ]]---------------------------------
function playEffct( ... )
	local appearEffectSprite = CCLayerSprite:layerSpriteWithName(CCString:create("images/item/equipFixed/lizibaokai/lizibaokai"), -1,CCString:create(""));
    appearEffectSprite:setAnchorPoint(ccp(0.5, 0.5));
    appearEffectSprite:setPosition(ccp(potentialityContainer:getContentSize().width/2, potentialityContainer:getContentSize().height/2));
    potentialityContainer:addChild(appearEffectSprite, 99999);

	appearEffectSprite:retain()
   	local delegate = BTAnimationEventDelegate:create()
    delegate:registerLayerEndedHandler(function ( ... )
    	print(GetLocalizeStringBy("key_1037"))
    	appearEffectSprite:removeFromParentAndCleanup(true)
    	appearEffectSprite:autorelease()
    end)
    appearEffectSprite:setDelegate(delegate)
end
---------------------------------------[[ 工具方法 ]]--------------------------------

--[[
	@des:记忆上次洗练次数类型
--]]
function saveLastFixedTimes( times )
	 CCUserDefault:sharedUserDefault():setIntegerForKey("equip_fixed_times_type_" .. itemId, times)
	 CCUserDefault:sharedUserDefault():flush()
end

function getLastFixedTimes( ... )
	local lastTimes = CCUserDefault:sharedUserDefault():getIntegerForKey("equip_fixed_times_type_" .. itemId)
	return lastTimes
end

function setAllVisible( visible )
	local menuChildren = fixButtonMenu:getChildren()
	for i=1,menuChildren:count() do
		local menuItem = tolua.cast(menuChildren:objectAtIndex(i-1), "CCMenuItem")
		menuItem:setVisible(visible)
	end
end
