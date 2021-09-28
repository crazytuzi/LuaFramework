-- Filename: TreasureFragmentInfoView.lua
-- Author: lichenyang
-- Date: 2013-11-2
-- Purpose: 宝物碎片界面

module("TreasureFragmentInfoView", package.seeall)

require "script/ui/treasure/TreasureData"
require "script/audio/AudioUtil"
require "script/utils/BaseUI"
require "script/ui/treasure/RobTreasureView"
require "script/ui/treasure/TreasureUtil"


kFragmentInfoOk			= 1
kFragmentInfoRob		= 2


local maskLayer 	 	= nil		-- 屏蔽层
local _item_tmp_id		= nil
local _fragmentTable	={}			-- 碎片数据
local guideButton 		= nil
local buttonType 		= nil

function init()
	maskLayer 	 		= nil
	_item_tmp_id 		= 0
	_fragmentTable 		= {}
	guideButton 		= nil
	buttonType 			= nil
end

function show( item_tmp_id, zOrder, button_type)
	init()
	buttonType 			= button_type
	_item_tmp_id = item_tmp_id
	_fragmentTable = TreasureData.getFragmentInfo(_item_tmp_id)
	print_t(_fragmentTable)
	maskLayer = BaseUI.createMaskLayer(-700)
	local infoLayer = createBgSrpite()
	setAdaptNode(infoLayer)
	maskLayer:addChild(infoLayer)
	local scene = CCDirector:sharedDirector():getRunningScene()
    scene:addChild(maskLayer, zOrder or 999,2013)
    --添加新手引导
    addNewGuide()
end

-- 创建属性的ui
local function createPropertyUi( attrBg)
	-- 碎片名字
	local fragmentNameLabel= CCRenderLabel:create(_fragmentTable.name , g_sFontPangWa, 25, 1, ccc3( 0x00, 0x00, 0x00), type_stroke)
	fragmentNameLabel:setAnchorPoint(ccp(0.5,0))
	fragmentNameLabel:setColor(ccc3(0x00,0xe4,0xff))
	fragmentNameLabel:setPosition(attrBg:getContentSize().width/2,387)
	attrBg:addChild(fragmentNameLabel)

	-- 简介
	local infoTitleLabel = CCRenderLabel:create(GetLocalizeStringBy("key_2371"), g_sFontName, 25, 2, ccc3( 0x00, 0x00, 0x0d), type_stroke)
    -- nameLabel:setSourceAndTargetColor(ccc3( 0xff, 0xf0, 0x49), ccc3( 0xff, 0xa2, 0x00));
    infoTitleLabel:setColor(ccc3(0x8a, 0xff, 0x00))
    infoTitleLabel:setAnchorPoint(ccp(0, 0))
    infoTitleLabel:setPosition(ccp( attrBg:getContentSize().width*0.08, 341))
    attrBg:addChild(infoTitleLabel)

	-- 分割线
	local lineSprite_0 = CCSprite:create("images/item/equipinfo/line.png")
	lineSprite_0:setAnchorPoint(ccp(0, 1))
	lineSprite_0:setScaleX(2)
	lineSprite_0:setPosition(ccp(attrBg:getContentSize().width*0.02, 334))
	attrBg:addChild(lineSprite_0)

	-- 简介的内容
	local noLabel = CCLabelTTF:create(_fragmentTable.desc , g_sFontName, 23, CCSizeMake(225,100 ), kCCTextAlignmentLeft, kCCVerticalTextAlignmentTop)
	noLabel:setColor(ccc3(0x78, 0x25, 0x00))
	noLabel:setAnchorPoint(ccp(0, 1))
	noLabel:setPosition(ccp(attrBg:getContentSize().width*0.07, 331))
	attrBg:addChild(noLabel)

	-- 文本：当前拥有的数量
	local alertContent = {}
	alertContent[1] = CCLabelTTF:create(GetLocalizeStringBy("key_2301") , g_sFontName, 20)
	alertContent[1]:setColor(ccc3(0x78, 0x25, 0x00))
	alertContent[2]= CCRenderLabel:create("" .. _fragmentTable.num , g_sFontPangWa, 20, 1, ccc3( 0x00, 0x00, 0x00), type_stroke)
	alertContent[2]:setColor(ccc3(0x2c, 0xdb, 0x23))
	alertContent[2]:setAnchorPoint(ccp(0,0))
	local alert = BaseUI.createHorizontalNode(alertContent)
	alert:setPosition(ccp(21,10))
	attrBg:addChild(alert)


end

function create( )
	-- 背景
	local fullRect = CCRectMake(0,0,196, 198)
	local insetRect = CCRectMake(50,50,96,98)
	local bgSprite = CCScale9Sprite:create("images/item/equipinfo/bg_9s.png")
	bgSprite:setContentSize(CCSizeMake(640, 640))
	bgSprite:setAnchorPoint(ccp(0.5, 0.5))
	bgSprite:setPosition(ccps(0.5, 0.5))

	local fullRect_attr = CCRectMake(0,0,61,47)
	local insetRect_attr = CCRectMake(10,10,41,27)
	-- 属性背景
	local attrBg = CCScale9Sprite:create("images/copy/fort/textbg.png", fullRect_attr, insetRect_attr)
	attrBg:setPreferredSize(CCSizeMake(260, 440))
	attrBg:setAnchorPoint(ccp(0.5, 1))
	attrBg:setPosition(ccp(bgSprite:getContentSize().width*0.75, bgSprite:getContentSize().height*0.92))
	bgSprite:addChild(attrBg)

	-- 属性内容
	createPropertyUi(attrBg)

	-- 碎片的图像
	local fragmentSp = TreasureUtil.getFragmentCardSprite(_fragmentTable.tid)
	fragmentSp:setAnchorPoint(ccp(0.5, 1))
	fragmentSp:setPosition(ccp(bgSprite:getContentSize().width*0.25, bgSprite:getContentSize().height*0.92))
	bgSprite:addChild(fragmentSp)

	-- 顶部
	local topSprite = CCSprite:create("images/item/equipinfo/topbg.png")
	topSprite:setAnchorPoint(ccp(0.5, 0.5))
	topSprite:setPosition(ccp(bgSprite:getContentSize().width*0.5, bgSprite:getContentSize().height))
	bgSprite:addChild(topSprite, 2)
	-- topSprite:setScale(myScale)

	-- 标题
	local titleLabel = CCRenderLabel:create(GetLocalizeStringBy("key_1055"), g_sFontPangWa, 35, 1, ccc3( 0x00, 0x00, 0x00), type_stroke)
    titleLabel:setColor(ccc3(0xff, 0xf6, 0x00))
    titleLabel:setAnchorPoint(ccp(0.5,0.5))
    titleLabel:setPosition(ccp( ( topSprite:getContentSize().width)/2, topSprite:getContentSize().height*0.6))
    topSprite:addChild(titleLabel)

	-- 关闭按钮bar
	local closeMenuBar = CCMenu:create()
	closeMenuBar:setPosition(ccp(0, 0))
	topSprite:addChild(closeMenuBar)
	-- 关闭按钮
	local closeBtn = LuaMenuItem.createItemImage("images/common/btn_close_n.png", "images/common/btn_close_h.png", closeAction_2 )
	closeBtn:setAnchorPoint(ccp(1, 0.5))
    closeBtn:setPosition(ccp(topSprite:getContentSize().width*1.01, topSprite:getContentSize().height*0.54))
    closeBtn:registerScriptTapHandler(closeAction)
	closeMenuBar:addChild(closeBtn)
	closeMenuBar:setTouchPriority(-600)
	setAdaptNode(bgSprite)

	--抢夺 和关闭按钮
	local menuBar=CCMenu:create()
	menuBar:setPosition(ccp(0,0))
	menuBar:setTouchPriority(-600)
	bgSprite:addChild(menuBar)

	local robBtn =  LuaCC.create9ScaleMenuItem("images/common/btn/btn1_d.png","images/common/btn/btn1_n.png",CCSizeMake(200, 73),GetLocalizeStringBy("key_1276"),ccc3(0xfe, 0xdb, 0x1c),35,g_sFontPangWa,1, ccc3(0x00, 0x00, 0x00))
	robBtn:setAnchorPoint(ccp(0.5,0))
	robBtn:setPosition(ccp(topSprite:getContentSize().width*0.25, bgSprite:getContentSize().height*0.07))
	robBtn:registerScriptTapHandler(robCallBack)
	menuBar:addChild(robBtn,1, _item_tmp_id)
	guideButton = robBtn

	local cancelBtn =  LuaCC.create9ScaleMenuItem("images/common/btn/btn1_d.png","images/common/btn/btn1_n.png",CCSizeMake(200, 73),GetLocalizeStringBy("key_1284"),ccc3(0xfe, 0xdb, 0x1c),35,g_sFontPangWa,1, ccc3(0x00, 0x00, 0x00))
	cancelBtn:setAnchorPoint(ccp(0.5,0))
	cancelBtn:setPosition(ccp(bgSprite:getContentSize().width*0.75, bgSprite:getContentSize().height*0.07))
	cancelBtn:registerScriptTapHandler(closeAction)
	menuBar:addChild(cancelBtn)

	-- 抢夺
	return bgSprite
end

function createBgSrpite( )
	
	local bgSprite =  CCScale9Sprite:create("images/common/viewbg1.png")
	bgSprite:setContentSize(CCSizeMake(511, 346))
	bgSprite:setAnchorPoint(ccp(0.5, 0.5))
	bgSprite:setPosition(ccps(0.5, 0.5))

	  -- 关闭按钮
    local menu =CCMenu:create()
	menu:setPosition(ccp(0,0))
	menu:setTouchPriority(-710)
	bgSprite:addChild(menu,1000)

	closeBtn = CCMenuItemImage:create("images/common/btn_close_n.png", "images/common/btn_close_h.png")
	closeBtn = CCMenuItemImage:create("images/common/btn_close_n.png", "images/common/btn_close_h.png")
	closeBtn:setAnchorPoint(ccp(1, 1))
	closeBtn:setPosition(ccp(bgSprite:getContentSize().width*1.01, bgSprite:getContentSize().height*1.02))
	closeBtn:registerScriptTapHandler(closeAction)
	menu:addChild(closeBtn)

	-- 标题	
	local titleBg= CCSprite:create("images/common/viewtitle1.png")
	titleBg:setPosition(ccp(bgSprite:getContentSize().width*0.5,bgSprite:getContentSize().height-6))
	titleBg:setAnchorPoint(ccp(0.5, 0.5))
	bgSprite:addChild(titleBg)

	--奖励的标题文本
	local labelTitle = CCRenderLabel:create(GetLocalizeStringBy("key_1055"), g_sFontPangWa,33,1,ccc3(0x0,0x00,0x0),type_stroke)
	labelTitle:setColor(ccc3( 0xff, 0xe4, 0x00))
	labelTitle:setPosition(ccp(titleBg:getContentSize().width*0.5,titleBg:getContentSize().height*0.5 ))
	labelTitle:setAnchorPoint(ccp(0.5,0.5))
	titleBg:addChild(labelTitle)

	-- 黑色的背景
	local itemInfoSpite = CCScale9Sprite:create("images/common/bg/bg_ng_attr.png")
    itemInfoSpite:setContentSize(CCSizeMake(470,162))
    itemInfoSpite:setPosition(ccp(bgSprite:getContentSize().width/2 ,120))
    itemInfoSpite:setAnchorPoint(ccp(0.5,0))
    bgSprite:addChild(itemInfoSpite)


	local itemSprite =  ItemSprite.getItemSpriteByItemId(_item_tmp_id)
	itemSprite:setPosition(ccp(8,48))
	itemInfoSpite:addChild(itemSprite)

	local nameColor = HeroPublicLua.getCCColorByStarLevel(tonumber(_fragmentTable.quality) )
	-- 显示名称
	local nameLabel = CCRenderLabel:create( _fragmentTable.name,  g_sFontName , 28, 2, ccc3( 0x00, 0x00, 0x00), type_stroke)
	-- nameLabel:setColor(ccc3(0xff,0xe4,0x00))
	nameLabel:setColor(nameColor)
	nameLabel:setPosition(ccp(126,121))
	nameLabel:setAnchorPoint(ccp(0,0))
	itemInfoSpite:addChild(nameLabel)

	-- line
	local lineSp = CCScale9Sprite:create("images/common/line01.png")
	lineSp:setContentSize(CCSizeMake(362,4))
	lineSp:setPosition(ccp(97,106))
	itemInfoSpite:addChild(lineSp)

	-- desc 
	local descLabel = CCLabelTTF:create( _fragmentTable.desc , g_sFontName,24, CCSizeMake(329,91 ), kCCTextAlignmentLeft, kCCVerticalTextAlignmentTop)
	descLabel:setPosition(ccp(120,10))
	descLabel:setColor(ccc3(0xff,0xff,0xff))
	itemInfoSpite:addChild(descLabel)

	local buttonLabel = nil

	if(buttonType == kFragmentInfoOk or buttonType == nil) then
		buttonLabel = GetLocalizeStringBy("key_1465")
		print("button type  = ", GetLocalizeStringBy("key_1465"))
	elseif(buttonType == kFragmentInfoRob) then
		buttonLabel = GetLocalizeStringBy("key_1946")
		print("button type  = ", GetLocalizeStringBy("key_1946"))
	end


	local robBtn =  LuaCC.create9ScaleMenuItem("images/common/btn/btn_bg_n.png","images/common/btn/btn_bg_h.png",CCSizeMake(192, 61),buttonLabel,ccc3(0xfe, 0xdb, 0x1c),35,g_sFontPangWa,1, ccc3(0x00, 0x00, 0x00))
	robBtn:setAnchorPoint(ccp(0.5,0))
	robBtn:setPosition(ccp(bgSprite:getContentSize().width*0.5, bgSprite:getContentSize().height*0.07))
	robBtn:registerScriptTapHandler(robCallBack)
	menu:addChild(robBtn,1, _item_tmp_id)
	guideButton = robBtn

	local numLabel = CCRenderLabel:create(GetLocalizeStringBy("key_2301") .. _fragmentTable.num ,g_sFontName, 24, 1, ccc3( 0x00, 0x00, 0x00), type_stroke)
	numLabel:setColor(ccc3(0x38,0xff,0x00))
	numLabel:setAnchorPoint(ccp(0.5,0))
	numLabel:setPosition(ccp(bgSprite:getContentSize().width/2,bgSprite:getContentSize().height*0.11))
	bgSprite:addChild(numLabel)
	numLabel:setVisible(false)

	if(NewGuide.guideClass == ksGuideRobTreasure) then
		numLabel:setString(GetLocalizeStringBy("key_2301") .. tonumber(_fragmentTable.num) -1)
	end

	require "script/guide/NewGuide"

	if(NewGuide.guideClass == ksGuideClose and TreasureData.seizerInfoData ~= nil  and TreasureData.getFragmentNum(_item_tmp_id) >= 1) then
		robBtn:setVisible(false)
		numLabel:setVisible(true)
		local alertLabel = CCRenderLabel:create(GetLocalizeStringBy("key_2452"),g_sFontName, 28, 2, ccc3( 0x00, 0x00, 0x00), type_stroke)
		alertLabel:setColor(ccc3(0x00,0xff,0x18))
		alertLabel:setAnchorPoint(ccp(0.5,0))
		alertLabel:setPosition(ccp(bgSprite:getContentSize().width/2,80))
		bgSprite:addChild(alertLabel)
	end

	return bgSprite
end

-- 关闭按钮
function closeAction( )
	require "script/audio/AudioUtil"
	AudioUtil.playEffect("audio/effect/guanbi.mp3")
	
	maskLayer:removeFromParentAndCleanup(true)
	maskLayer=nil
end

function robCallBack( tag, item )
	AudioUtil.playEffect("audio/effect/zhujiemian.mp3")
	print(GetLocalizeStringBy("key_1519"))
	maskLayer:removeFromParentAndCleanup(true)
	maskLayer=nil

	if(buttonType == kFragmentInfoOk or nil) then

	elseif(buttonType == kFragmentInfoRob) then

		RobTreasureView.createLayer( tonumber(tag))
		require "script/guide/NewGuide"
		if(NewGuide.guideClass == ksGuideRobTreasure) then
			RobTreasureGuide.changLayer()
		end
	end 


end

-- 获取碎片的大头像
function getTresureCard( item_tmp_id )

end


----------------------------[[ 新手引导 ]]----------------------------------
--[[
	@des:	得到新手引导的碎片图标
]]
function getGuideButton( ... )
	return guideButton
end

--[[
	@des:	添加引导层方法
]]
function addNewGuide( ... )
	local guideFunc = function ( ... )
		require "script/guide/RobTreasureGuide"
	    if(NewGuide.guideClass ==  ksGuideRobTreasure and RobTreasureGuide.stepNum == 2) then
	    	RobTreasureGuide.changLayer()
	       	require "script/ui/active/ActiveList"
	        local robTreasure = getGuideButton()
	        local touchRect   = getSpriteScreenRect(robTreasure)
	        RobTreasureGuide.show(3, touchRect)
	    end
	end
	local seq = CCSequence:createWithTwoActions(CCDelayTime:create(0.3),CCCallFunc:create(function ( ... )
			guideFunc()
	end))
	maskLayer:runAction(seq)
end








