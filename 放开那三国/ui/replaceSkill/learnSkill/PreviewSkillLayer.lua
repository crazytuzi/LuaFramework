-- Filename: PreviewSkillLayer.lua
-- Author: zhangqiang
-- Date: 2014-09-04
-- Purpose: 技能预览

module("PreviewSkillLayer", package.seeall)

local kMainLayerPriority = -350
local kMenuTouchPriority = -351
local kTablePriority = -352

local kMidBgSize = CCSizeMake(640, g_winSize.height/g_fScaleX-BulletinLayer.getLayerHeight()
	                            -MenuLayer.getLayerContentSize().height)
local kTableBgSize = CCSizeMake(600, kMidBgSize.height-180)
local kTableSize = CCSizeMake(kTableBgSize.width-10, kTableBgSize.height-20)
local kTableCellSize = CCSizeMake(kTableSize.width,185)

local _mainLayer = nil
local _tableView = nil


--[[
	@desc : 初始化
	@param:	
	@ret  :	
--]]
function init( ... )
	--require "script/ui/replaceSkill/learnSkill/ReplaceSkillData"
	ReplaceSkillData.initPreviewData()

	_mainLayer = nil
	_tableView = nil
end

--[[
	@desc : 创建中间的UI
	@param:	
	@ret  :	
--]]
function createMidUI( ... )
	--images/copy/fort/namebg_red.png

	--整个大背景
	local firstBg = CCScale9Sprite:create("images/item/equipinfo/bg_9s.png")
	firstBg:setPreferredSize(kMidBgSize)
	firstBg:setAnchorPoint(ccp(0.5,0))
	firstBg:setPosition(320, MenuLayer.getLayerContentSize().height)
	_mainLayer:addChild(firstBg)

	--技能名称背景
	local nameBg = CCSprite:create("images/copy/fort/namebg_red.png")
	nameBg:setAnchorPoint(ccp(0.5,0.5))
	nameBg:setPosition(320, 85+kTableBgSize.height)
	firstBg:addChild(nameBg)
	local nameBgSize = nameBg:getContentSize()

	--技能名称 和 名将的名字
	local skillInfo = ReplaceSkillData.getSelectSkillInfo()
	local labelStrTable = {
		[1] = {skillInfo.skillName, 30, ccc3(0xe4,0x00,0xff), ccp(0.5,0.5), ccp(nameBgSize.width*0.5, nameBgSize.height*0.5+8)},
		[2] = {GetLocalizeStringBy("zz_77",skillInfo.starName), 24, ccc3(0xff,0xe4,0x00), ccp(1,0), ccp(439,-4)},
	}
	for i = 1,2 do
		local label = CCRenderLabel:create(labelStrTable[i][1], g_sFontPangWa, labelStrTable[i][2], 1, ccc3(0x00,0x00,0x00), type_shadow)
		label:setColor(labelStrTable[i][3])
		label:setAnchorPoint(labelStrTable[i][4])
		label:setPosition(labelStrTable[i][5])
		nameBg:addChild(label)
	end

	local secondBg = CCScale9Sprite:create("images/common/bg/bg_ng_attr.png")
	secondBg:setPreferredSize(kTableBgSize)
	secondBg:setAnchorPoint(ccp(0.5,0))
	secondBg:setPosition(320,60)
	firstBg:addChild(secondBg)

	local titleBg = CCSprite:create("images/item/equipinfo/topbg.png")
	titleBg:setAnchorPoint(ccp(0.5,1))
	titleBg:setPosition(320, kMidBgSize.height)
	firstBg:addChild(titleBg)

	local titleLabel = CCLabelTTF:create(GetLocalizeStringBy("zz_75"), g_sFontPangWa, 35)
	titleLabel:setColor(ccc3(0xff,0xe4,0x00))
	titleLabel:setAnchorPoint(ccp(0.5,0.5))
	titleLabel:setPosition(320,titleBg:getContentSize().height*0.5+8)
	titleBg:addChild(titleLabel)

	-- 创建技能预览列表
	require "script/ui/replaceSkill/learnSkill/SelectSkillLayer"
	_tableView = SelectSkillLayer.createTableView(0, kTableSize, kTableCellSize, #ReplaceSkillData.getAllSkillList(),
		                                          createCell)
	_tableView:ignoreAnchorPointForPosition(false)
	_tableView:setAnchorPoint(ccp(0.5,0.5))
	_tableView:setPosition(kTableBgSize.width/2,kTableBgSize.height/2)
	_tableView:setTouchPriority(kTablePriority)
	secondBg:addChild(_tableView)

	--底部的描述
	local bottomLabel = CCLabelTTF:create(GetLocalizeStringBy("zz_98"), g_sFontPangWa, 25)
	bottomLabel:setColor(ccc3(0x78,0x25,0x00))
	bottomLabel:setAnchorPoint(ccp(0.5,0))
	bottomLabel:setPosition(320,25)
	firstBg:addChild(bottomLabel)


	local menu = CCMenu:create()
	menu:setPosition(0,0)
	menu:setTouchPriority(kMenuTouchPriority)
	firstBg:addChild(menu)

	--关闭按钮
	local closeBtn = CCMenuItemImage:create("images/common/btn_close_n.png", "images/common/btn_close_h.png")
	closeBtn:registerScriptTapHandler(tapCloseBtnCb)
	closeBtn:setAnchorPoint(ccp(0.5,0.5))
	closeBtn:setPosition(610,kMidBgSize.height-30)
	menu:addChild(closeBtn)
end

--[[
	@desc : 创建表格单元
	@param:	
	@ret  :	
--]]
function createCell( p_cellIndex )
	local cell = CCTableViewCell:create()
	local cellData = ReplaceSkillData.getAllSkillList()[p_cellIndex]
	-- print("createCell")
	-- print_t(cellData)
	--单元格背景
	local fullRect = CCRectMake(0,0,80,118)
	local insectRect = CCRectMake(35,35,10,48)
	local firstBg = CCScale9Sprite:create("images/pet/pet/bag_bg.png",fullRect,insectRect)
	firstBg:setPreferredSize(kTableCellSize)
	firstBg:setAnchorPoint(ccp(0,0))
	firstBg:setPosition(0,0)
	cell:addChild(firstBg)

	--描述背景
	local secondBg = CCScale9Sprite:create("images/common/bg/goods_bg.png")
	secondBg:setPreferredSize(CCSizeMake(285,144))
	secondBg:setAnchorPoint(ccp(0,0))
	secondBg:setPosition(108,15)
	firstBg:addChild(secondBg)

	--技能图标
	local skillIcon = ReplaceSkillLayer.createSkillIcon(cellData.skillId)
	skillIcon:setAnchorPoint(ccp(0,0))
	skillIcon:setPosition(15,60)
	firstBg:addChild(skillIcon)

	--LV图标
	local lvSprite = CCSprite:create("images/boss/LV.png")
	lvSprite:setScale(0.7)
	lvSprite:setAnchorPoint(ccp(1,0))
	lvSprite:setPosition(61,32)
	firstBg:addChild(lvSprite)

	--各个描述
	--[1] = {内容， 字体， 大小， 颜色, 锚点, 位置}
	local descTable = {
		[1] = {tostring(cellData.skillLevel), g_sFontPangWa, 18, ccc3(0xff,0xe4,0x00), ccp(0,0), ccp(61,32)},
		[2] = {GetLocalizeStringBy("zz_76"), g_sFontPangWa, 21, ccc3(0x00,0xff,0x18), ccp(0,0), ccp(410,102)},
		[3] = {tostring(cellData.needFeelLevel), g_sFontPangWa, 21, ccc3(0x00,0xff,0x18), ccp(1,0), ccp(480,60)},
	}
	for i = 1,3 do 
		local label = CCRenderLabel:create(descTable[i][1], descTable[i][2], descTable[i][3], 1, ccc3(0x00,0x00,0x00), type_shadow)
		label:setColor(descTable[i][4])
		label:setAnchorPoint(descTable[i][5])
		label:setPosition(descTable[i][6])
		firstBg:addChild(label)
	end

	--技能描述
	local skillDescLabel = CCLabelTTF:create("      " .. cellData.skillDesc, g_sFontName, 21)
	skillDescLabel:setColor(ccc3(0x78,0x25,0x00))
	skillDescLabel:setDimensions(CCSizeMake(260,115))
	skillDescLabel:setHorizontalAlignment(kCCTextAlignmentLeft)
	skillDescLabel:setVerticalAlignment(kCCVerticalTextAlignmentTop)
	skillDescLabel:setAnchorPoint(ccp(0.5,0.5))
	skillDescLabel:setPosition(secondBg:getContentSize().width/2,secondBg:getContentSize().height/2)
	secondBg:addChild(skillDescLabel)

	--图标“怒”
	local angerBg = CCSprite:create("images/hero/info/anger.png")
	angerBg:setScale(0.80)
	angerBg:setAnchorPoint(ccp(1,0))
	angerBg:setPosition(30,94)
	skillDescLabel:addChild(angerBg)

	local angerLabel = CCLabelTTF:create(GetLocalizeStringBy("zz_54"), g_sFontName, 25)
	angerLabel:setColor(ccc3(0xff,0xff,0xff))
	angerLabel:setAnchorPoint(ccp(0.5,0.5))
	angerLabel:setPosition(angerBg:getContentSize().width/2, angerBg:getContentSize().height/2)
	angerBg:addChild(angerLabel)

	--亲密图标
	local affinitySprite = CCSprite:create("images/replaceskill/affinity.png")
	affinitySprite:setAnchorPoint(ccp(0,0))
	affinitySprite:setPosition(480,56)
	affinitySprite:setScale(1.1)
	firstBg:addChild(affinitySprite)

	return cell
end

--[[
	@desc : 创建层
	@param:	
	@ret  :	
--]]
function createLayer( ... )
	_mainLayer = CCLayer:create()
	_mainLayer:registerScriptHandler(onNodeEvent)
	_mainLayer:setScale(g_fScaleX)

	createMidUI()
end

--[[
	@desc : 显示层
	@param:	
	@ret  :	
--]]
function showLayer( ... )
	init()
	createLayer()
	
	MainScene.changeLayer(_mainLayer, "PreviewSkillLayer")
	MainScene.setMainSceneViewsVisible(true,false,true)
end

--------------------------------------------------------[[回调]]----------------------------------------------
--[[
	@desc : 创建层时的回调
	@param:	
	@ret  :	
--]]
function onNodeEvent( p_eventType )
	local touchLayerCb = function ( p_eventType, p_touchX, p_touchY )
		return true
	end

	if p_eventType == "enter" then
		_mainLayer:registerScriptTouchHandler(touchLayerCb, false, kMainLayerPriority, true)
		_mainLayer:setTouchEnabled(true)
	elseif p_eventType == "exit" then
		_mainLayer:unregisterScriptTouchHandler()
	else

	end
end

--[[
	@desc : 关闭按钮回调
	@param:	
	@ret  :	
--]]
require "script/audio/AudioUtil"
function tapCloseBtnCb( p_tag, p_item )
	-- if _mainLayer ~= nil then
	-- 	AudioUtil.playEffect("audio/effect/guanbi.mp3")
	-- 	_mainLayer:removeFromParentAndCleanup(true)
	-- 	_mainLayer = nil
	-- end
	require "script/ui/replaceSkill/learnSkill/SelectSkillLayer"
	SelectSkillLayer.showLayer()
end