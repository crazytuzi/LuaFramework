-- Filename: SelectHeroLayer.lua
-- Author: zhangqiang
-- Date: 2014-09-15
-- Purpose: 能够进化橙卡的紫卡武将列表

module("SelectHeroLayer", package.seeall)
require "script/ui/develop/DevelopData"
require "script/libs/LuaCCMenuItem"

local kAdaptiveSize = CCSizeMake(640, g_winSize.height/g_fScaleX)
local kMidUISize = CCSizeMake(640, kAdaptiveSize.height-MenuLayer.getLayerContentSize().height-BulletinLayer.getLayerHeight())

local kMainLayerPriority = -350
local kMenuPriority = -353

local _mainLayer = nil
local _selectList = nil

--[[
	@desc :	初始化
	@param:	
	@ret  :
--]]
function init( ... )
	_mainLayer = nil
	_selectList = DevelopData.getSelectList()
end

--[[
	@desc :	创建标题面板
	@param:	
	@ret  :
--]]
function createTitleSprite( ... )
	--require "script/libs/LuaCCSprite"
	-- 标题背景底图
	local bg = CCSprite:create("images/hero/select/title_bg.png")

	-- 加入背景标题底图进层
	-- 标题
	local ccSpriteTitle = CCSprite:create("images/hero/select/title.png")
	ccSpriteTitle:setPosition(ccp(45, 50))
	bg:addChild(ccSpriteTitle)

	local tItems = {
		{normal="images/hero/btn_back_n.png", highlighted="images/hero/btn_back_h.png", pos_x=473, pos_y=40, cb=tapGoBackCb},
	}
	local menu = LuaCC.createMenuWithItems(tItems)
	menu:setTouchPriority(kMenuPriority)
	menu:setPosition(ccp(0, 0))
	bg:addChild(menu)

	return bg
end

--[[
	@desc :	创建武将星级
	@param:	
	@ret  :
--]]
function createStars(count, space)
	local node = CCSpriteBatchNode:create("images/hero/star.png")
	local texture = node:getTexture()
	-- local nodeSize = node:getContentSize()
	-- print("createStars",nodeSize.width,nodeSize.height)

	local star = CCSprite:createWithTexture(texture)
	local starSize = star:getContentSize()
	local size = CCSizeMake(0,starSize.height)
	star:setAnchorPoint(ccp(0,0))
	star:setPosition(size.width,0)
	node:addChild(star)

	for i=2, count do
		size.width = size.width + starSize.width + space

		star = CCSprite:createWithTexture(texture)
		star:setAnchorPoint(ccp(0,0))
		star:setPosition(size.width,0)
		node:addChild(star)
	end
	node:setContentSize(size)

	return node
end

--[[
	@desc :	根据hid创建头像图标，点击图标可弹出英雄信息(可独立使用)
	@param:	
	@ret  :
--]]
function creatHeroIcon( p_hid, p_menuTouchPriority, p_zOrderNum, p_infoLayerPriority)
	p_zOrderNum = p_zOrderNum or 1000
	p_menuTouchPriority = p_menuTouchPriority or -228
	p_infoLayerPriority = p_infoLayerPriority or -688

	local heroInfo = HeroModel.getHeroByHid(p_hid)
	local localInfo = HeroUtil.getHeroLocalInfoByHtid(tonumber(heroInfo.htid))
	local bgSprite = CCSprite:create("images/base/potential/officer_" .. localInfo.potential .. ".png")

	local menu = CCMenu:create()
	menu:setTouchPriority(p_menuTouchPriority)
	menu:setPosition(0,0)
	bgSprite:addChild(menu)

	local headFile = HeroUtil.getHeroIconImgByHTID( tonumber(heroInfo.htid), heroInfo.equip.dress[1] )
	local normalSprite = CCSprite:create(headFile)
	local selectSprite = CCSprite:create(headFile)
	local size = selectSprite:getContentSize()

	local highlightBorder = CCSprite:create("images/hero/quality/highlighted.png")
	highlightBorder:setAnchorPoint(ccp(0.5,0.5))
	highlightBorder:setPosition(size.width*0.5,size.height*0.5)
	selectSprite:addChild(highlightBorder)

	local iconBtn = CCMenuItemSprite:create(normalSprite, selectSprite)
	iconBtn:setAnchorPoint(ccp(0.5,0.5))
	iconBtn:setPosition(bgSprite:getContentSize().width*0.5,bgSprite:getContentSize().height*0.5)
	menu:addChild(iconBtn,1,tonumber(p_hid))

	local btnCb = function ( p_tag, p_item )
		local heroData = DevelopData.getHeroDataByHid(p_tag)
		require "script/ui/hero/HeroInfoLayer"
		HeroInfoLayer.createLayer(heroData, {isPanel=true}, p_zOrderNum, p_infoLayerPriority)
	end
	iconBtn:registerScriptTapHandler(btnCb)
    
	return bgSprite
end

--[[
	@desc :	创建表格单元
	@param:	
	@ret  :
--]]
function createCell( p_index )
	local cell = CCTableViewCell:create()
	local cellData = _selectList[p_index]

	local firstBg = CCSprite:create("images/hero/attr_bg.png")
	firstBg:setAnchorPoint(ccp(0,0))
	firstBg:setPosition(0,0)
	cell:addChild(firstBg)

	--所属国家
	local countryIcon = CCSprite:create(cellData.country_icon)
	countryIcon:setAnchorPoint(ccp(0.5,1))
	countryIcon:setPosition(35,146)
	firstBg:addChild(countryIcon)

	--英雄等级
	local levelLabel = CCRenderLabel:create("Lv. " .. cellData.level, g_sFontName, 21, 2, ccc3(0x00,0x00,0x00), type_shadow)
	levelLabel:setColor(ccc3(0xff,0xe4,0x00))
	levelLabel:setAnchorPoint(ccp(0,0))
	levelLabel:setPosition(58,114)
	firstBg:addChild(levelLabel)

	--武将名字和战斗力
	--ccc3(0x6c,0xff,0x00)
	local labelStr = {
		[1] = {cellData.name, 22, HeroPublicLua.getCCColorByStarLevel(cellData.star_lv), ccp(0.5,0), ccp(206,112)},
		[2] = {GetLocalizeStringBy("zz_97",cellData.heroQuality), 24,ccc3(0x48,0x1b,0x00), ccp(0,0), ccp(118,49)},	
	}
	for i = 1,2 do
		local label = CCLabelTTF:create(labelStr[i][1], g_sFontName, labelStr[i][2])
		label:setColor(labelStr[i][3])
		label:setAnchorPoint(labelStr[i][4])
		label:setPosition(labelStr[i][5])
		firstBg:addChild(label)
	end

	--星级
	local stars = createStars(cellData.star_lv, 2)
	stars:setAnchorPoint(ccp(0,0))
	stars:setPosition(285, 112)
	firstBg:addChild(stars)

	--武将头像
	--local heroIcon = ItemSprite.getHeroIconItemByhtid(cellData.htid, kMenuPriority+1)
	local heroIcon = creatHeroIcon(cellData.hid, kMenuPriority+1)
	heroIcon:setAnchorPoint(ccp(0,0))
	heroIcon:setPosition(15,10)
	firstBg:addChild(heroIcon)

	local menu = CCMenu:create()
	menu:setTouchPriority(kMenuPriority)
	menu:setPosition(0,0)
	firstBg:addChild(menu)
	--进化按钮
	tSprite = {normal="images/common/btn/green01_n.png", selected="images/common/btn/green01_h.png"}
 	tLabel = {text=GetLocalizeStringBy("djn_233"), fontsize=30, }
	local developBtn = LuaCCMenuItem.createMenuItemOfRenderLabelOnSprite(tSprite, tLabel)
	developBtn:registerScriptTapHandler(tapDevelopBtnCb)
	developBtn:setAnchorPoint(ccp(0,0))
	developBtn:setPosition(480,28)
	menu:addChild(developBtn,1,p_index)


	local spellEffectSprite = CCLayerSprite:layerSpriteWithName(CCString:create("images/base/effect/lvanniu/lvanniu"), -1,CCString:create(""))
    spellEffectSprite:setPosition(developBtn:getContentSize().width*0.5,developBtn:getContentSize().height*0.5)
    developBtn:addChild(spellEffectSprite)


	return cell
end

--[[
	@desc :	创建列表
	@param:	
	@ret  :
--]]
function createTable( ... )
	local tableSize = CCSizeMake(640, kMidUISize.height-107)
	local cellSize = CCSizeMake(640, 156)
	local tableView = CreateUI.createTableView(0,tableSize,cellSize,#_selectList,createCell)

	return tableView
end

--[[
	@desc :	创建UI
	@param:	
	@ret  :
--]]
function createUI( ... )
	local node = CCNode:create()
	node:setContentSize(kMidUISize)

	--创建标题
	local title = createTitleSprite()
	local titileSize = title:getContentSize()
	title:setAnchorPoint(ccp(0.5,1))
	title:setPosition(320,kMidUISize.height)
	node:addChild(title,1)

	--创建表格
	local tableView = createTable()
	tableView:setTouchPriority(kMenuPriority)
	tableView:ignoreAnchorPointForPosition(false)
	tableView:setAnchorPoint(ccp(0.5,0))
	tableView:setPosition(320,0)
	node:addChild(tableView)

	return node
end

--[[
	@desc :	创建层
	@param:	
	@ret  :
--]]
function createLayer( ... )
	init()

	_mainLayer = CCLayer:create()
	_mainLayer:registerScriptHandler(onNodeEvent)
	_mainLayer:setContentSize(kAdaptiveSize)
	_mainLayer:setScale(g_fScaleX)

	--背景
	local mainBg = CCSprite:create("images/main/module_bg.png")
	mainBg:setAnchorPoint(ccp(0.5,0))
	mainBg:setPosition(320, MenuLayer.getLayerContentSize().height)
	_mainLayer:addChild(mainBg)

	--创建中间的UI
	local midNode = createUI()
	midNode:setAnchorPoint(ccp(0,0))
	midNode:setPosition(0, MenuLayer.getLayerContentSize().height)
	_mainLayer:addChild(midNode)

	return _mainLayer
end

--[[
	@desc :	显示层
	@param:	
	@ret  :
--]]
function showLayer( ... )
	local mainLayer = createLayer()
	MainScene.changeLayer(mainLayer, "SelectHeroLayer")
	MainScene.setMainSceneViewsVisible(true,false,true)
end



-----------------------------------------------------------[[回调函数]]---------------------------------------------------------
--[[
	@desc :	层创建和释放时的回调
	@param:	
	@ret  :	
--]]
function onNodeEvent( p_eventType )
	local touchLayerCb = function ( p_eventType, p_touchX, p_touchY )
		if p_eventType == "began" then
			return true
		elseif p_eventType == "ended" then

		else
			print("moved")
		end
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
	@desc :	点击返回时的回调
	@param:	
	@ret  :	
--]]
function tapGoBackCb( p_tag, p_item )
	require "script/ui/develop/DevelopLayer"
	DevelopLayer.showLayer()
end

--[[
	@desc :	点击进化按钮时的回调
	@param:	
	@ret  :	
--]]
function tapDevelopBtnCb( p_tag, p_item )
	require "script/ui/develop/DevelopLayer"
	if _selectList ~= nil then
		DevelopLayer.showLayer(_selectList[p_tag].hid)
	end
end






