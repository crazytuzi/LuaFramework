-- Filename: WarcraftDescLayer.lua
-- Author: bzx
-- Date: 2014-11-22
-- Purpose: 阵法说明

module("WarcraftDescLayer", package.seeall)

require "script/libs/LuaCCSprite"
require "db/DB_Affix"
require "script/libs/LuaCCLabel"
require "db/DB_Method_attex"

local _layer 
local _touchPriority
local _zOrder
local _bgSprite
local _allGoalDatas

function show(touchPriority, zOrder)
	_layer = create(touchPriority, zOrder)
	_layer:registerScriptHandler(onNodeEvent)
	CCDirector:sharedDirector():getRunningScene():addChild(_layer, _zOrder)
end

function init( touchPriority, zOrder )
	_touchPriority = touchPriority or -500
	_zOrder = zOrder or 1000
	_allGoalDatas = WarcraftData.getAllGoalDatas()
end

function closeAction( tag, itenBtn )
	_layer:removeFromParentAndCleanup(true)
end

-- 创建tableView背景
function createTableView()
	local cellBg = CCSprite:create("images/star/star_achieve_bg.png")
	cellSize = cellBg:getContentSize()			--计算cell大小

	-- tableView
	local tableViewBgSprite = CCScale9Sprite:create("images/common/bg/bg_ng_attr.png")

	local spHeight = _bgSprite:getContentSize().height - 100
	tableViewBgSprite:setContentSize(CCSizeMake(_bgSprite:getContentSize().width*0.93, spHeight))
	tableViewBgSprite:setAnchorPoint(ccp(0.5, 1))
	tableViewBgSprite:setPosition(ccp(_bgSprite:getContentSize().width*0.5, _bgSprite:getContentSize().height-70))
	_bgSprite:addChild(tableViewBgSprite)

	local h = LuaEventHandler:create(function(fn, table, a1, a2) 	--创建
		local r
		if fn == "cellSize" then
			r = CCSizeMake(cellSize.width*g_fScaleX, cellSize.height)
		elseif fn == "cellAtIndex" then
            a2 = createCell(a1 + 1)
			r = a2
		elseif fn == "numberOfCells" then
			r = #_allGoalDatas
		elseif fn == "cellTouched" then

		elseif (fn == "scroll") then
			
		end
		return r
	end)
	local myTableView = LuaTableView:createWithHandler(h, CCSizeMake(tableViewBgSprite:getContentSize().width, tableViewBgSprite:getContentSize().height-20))
    myTableView:setAnchorPoint(ccp(0,0))
	myTableView:setBounceable(true)
	myTableView:setPosition(ccp(0, 10))
	myTableView:setVerticalFillOrder(kCCTableViewFillTopDown)
	tableViewBgSprite:addChild(myTableView)
	myTableView:setTouchPriority(_touchPriority - 10)
end


-- 创建背景Sprite
function createBgSprite()
	local bgSize = _layer:getContentSize()
	-- 背景sprite
	local contengSize = CCSizeMake(_layer:getContentSize().width/g_fScaleX,  _layer:getContentSize().height/g_fScaleX)

	_bgSprite = CCScale9Sprite:create("images/item/equipinfo/bg_9s.png")
	_bgSprite:setContentSize(contengSize)
	_bgSprite:setAnchorPoint(ccp(0,0))
	_bgSprite:setPosition(ccp(0,0))
	_bgSprite:setScale(g_fScaleX)
	_layer:addChild(_bgSprite, 1)

	-- 上部标题
	-- 顶部
	local topSprite = CCSprite:create("images/item/equipinfo/topbg.png")
	topSprite:setAnchorPoint(ccp(0.5, 1))
	topSprite:setPosition(ccp(_bgSprite:getContentSize().width*0.5, _bgSprite:getContentSize().height))
	_bgSprite:addChild(topSprite, 2)

	-- 标题
	local titleLabel = CCRenderLabel:create(GetLocalizeStringBy("key_8409"), g_sFontPangWa, 33, 1, ccc3( 0x00, 0x00, 0x00), type_stroke)
    titleLabel:setColor(ccc3(0xff, 0xe4, 0x00))
    titleLabel:setAnchorPoint(ccp(0.5,0.5))
    titleLabel:setPosition(ccp( ( topSprite:getContentSize().width )/2, topSprite:getContentSize().height*0.6))
    topSprite:addChild(titleLabel)

    -- 关闭按钮bar
	local closeMenuBar = CCMenu:create()
	closeMenuBar:setPosition(ccp(0, 0))
	topSprite:addChild(closeMenuBar)
	closeMenuBar:setTouchPriority(_touchPriority - 10)
	-- 关闭按钮
	local closeBtn = LuaMenuItem.createItemImage("images/common/btn_close_n.png", "images/common/btn_close_h.png" )
	closeBtn:setAnchorPoint(ccp(1, 0.5))
    closeBtn:setPosition(ccp(topSprite:getContentSize().width*1.01, topSprite:getContentSize().height*0.54))
    closeBtn:registerScriptTapHandler(closeAction)
	closeMenuBar:addChild(closeBtn)
end

function create(touchPriority, zOrder)
	init(touchPriority, zOrder)
	_layer = CCLayer:create()
-- 创建背景Sprite
	createBgSprite()
-- 创建tableView背景
	createTableView()

	return _layer
end

function createCell(index, totalLv)

	local tCell = CCTableViewCell:create()
	local goalData = _allGoalDatas[index]
	local goalDb = parseDB(DB_Method_attex.getDataById(goalData.id))
	local isGray = true
	if goalData.isReached == true then
		isGray = false
	end

	local bgName 	 = nil
	local titleColor = nil
	local textColor  = nil
	local attrColor  = nil
	local numColor   = nil
	local starName 	= nil

	if(isGray)then
		bgName 		= "images/star/star_achieve_graybg.png"
		titleColor 	= ccc3(0xca, 0xca, 0xca)
		textColor  	= ccc3(0x2a, 0x1d, 0x18)
		attrColor  	= ccc3(0x2a, 0x1d, 0x18)
		numColor   	= ccc3(0xca, 0xca, 0xca)
		starName 	= "images/star/intimate/heart_gray_s.png"
	else
		bgName 	 	= "images/star/star_achieve_bg.png"
		titleColor 	= ccc3(0x00, 0xe4, 0xff)
		textColor  	= ccc3(0x78, 0x25, 0x00)
		attrColor  	= ccc3(0x14, 0x61, 0x02)
		numColor   	= ccc3(0xff, 0xff, 0x60)
		starName   	= "images/star/intimate/heart_s.png"

	end

	local cellBg = CCSprite:create(bgName)
	cellBg:setAnchorPoint(ccp(0,0))
	tCell:addChild(cellBg,1,1)

	local cellBgSize = cellBg:getContentSize()

	-- icon
	local iconSprite = getGoalIcon(index, isGray)
	iconSprite:setAnchorPoint(ccp(0.5,0.5))
	iconSprite:setPosition(ccp(cellBgSize.width*0.15, cellBgSize.height*0.5))
	cellBg:addChild(iconSprite)


    local height_scale_1 = 0.5
    local height_scale_2 = 0.3
    if(isGray)then
    	height_scale_1 = 0.4
   		height_scale_2 = 0.2
    end

    local conditionRichInfo = {}
    conditionRichInfo.labelDefaultColor = isGray == true and ccc3(0x00, 0x00, 0x00) or ccc3(0x78, 0x25, 0x00)
    conditionRichInfo.labelDefaultSize = 25
    conditionRichInfo.elements = {
    	{
    		text = " " .. goalDb.needmetohdlevel[1]
    	},
    	{
    		type =  isGray ~= true and "CCRenderLabel" or nil,
    		text = " " .. goalDb.needmetohdlevel[2],
    		color = isGray == true and ccc3(0x00, 0x00, 0x00) or ccc3(0xff, 0xf6, 0x00)
  		}
	}

    local conditionTextLabel = GetLocalizeLabelSpriteBy_2("key_8410", conditionRichInfo)
    cellBg:addChild(conditionTextLabel)
    conditionTextLabel:setAnchorPoint(ccp(0, 0.5))
    conditionTextLabel:setPosition(ccp(cellBgSize.width*0.25, 100))


    local attrRichInfo = {}
    attrRichInfo.labelDefaultColor = isGray == true and ccc3(0x00, 0x00, 0x00) or ccc3(0x14, 0x61, 0x02)
    attrRichInfo.labelDefaultSize = 25
    attrRichInfo.elements = {
    	{
    		text = string.format(" +%d%%", math.floor(goalDb.allMetohdAttRatio / 100)),
    		color = ccc3(0x14, 0x61, 0x02)
    	}
	}
	local attrTextLabel = GetLocalizeLabelSpriteBy_2("key_8411", attrRichInfo)
	cellBg:addChild(attrTextLabel)
	attrTextLabel:setAnchorPoint(ccp(0, 0.5))
	attrTextLabel:setPosition(ccp(cellBgSize.width*0.25, 50))

	local coditionNumTitleLabel = CCRenderLabel:create(tostring(goalDb.needmetohdlevel[2]), g_sFontName, 21, 1, ccc3(0, 0, 0), type_stroke)
	cellBg:addChild(coditionNumTitleLabel)
	coditionNumTitleLabel:setAnchorPoint(ccp(0.5, 0.5))
	coditionNumTitleLabel:setPosition(ccp(cellBgSize.width*0.195 , 50))
	coditionNumTitleLabel:setColor(isGray == true and ccc3(125, 125, 125) or ccc3(0x00, 0xff, 0x18))
 
	if isGray == false then
		local passedSprite = CCSprite:create("images/star/dacheng.png")
		passedSprite:setAnchorPoint(ccp(1,1))
		passedSprite:setPosition(ccp(cellBgSize.width, cellBgSize.height))
		cellBg:addChild(passedSprite)
	end

	return tCell
end


-- 获得 名将成就的icon
function getGoalIcon(index, isGray )
	local goalData = _allGoalDatas[index]
	local goalDb = DB_Method_attex.getDataById(goalData.id)

	local borderName 	= "images/star/achieve_border.png"
	local potentialName = "images/base/potential/props_" .. goalDb.metohdcolor .. ".png"
	local iconName 		= "images/warcraft/warcraft_icon3.png"

	local borderSprite 		= nil 	-- 最外框
	local potentialSprite 	= nil	-- 品质框
	local iconSprite 		= nil	-- Icon
	local numColor 			= nil 	-- 数字颜色 
	if(isGray)then
		borderSprite 	= BTGraySprite:create(borderName)
		potentialSprite = BTGraySprite:create(potentialName)
		iconSprite 		= BTGraySprite:create(iconName)
		numColor		= ccc3(0xca, 0xca, 0xca)
	else
		borderSprite 	= CCSprite:create(borderName)
		potentialSprite = CCSprite:create(potentialName)
		iconSprite 		= CCSprite:create(iconName)
		numColor		= ccc3(0x00, 0xff, 0x18)
	end

	potentialSprite:setAnchorPoint(ccp(0.5,0.5))
	potentialSprite:setPosition(ccp(borderSprite:getContentSize().width*0.5, borderSprite:getContentSize().height*0.5))
	borderSprite:addChild(potentialSprite)

	iconSprite:setAnchorPoint(ccp(0.5,0.5))
	iconSprite:setPosition(ccp(potentialSprite:getContentSize().width*0.5, potentialSprite:getContentSize().height*0.5))
	potentialSprite:addChild(iconSprite)

	return borderSprite
end

function onNodeEvent( event )
	if event == "enter" then
		_layer:registerScriptTouchHandler(onTouchesHandler, false, _touchPriority, true)
		_layer:setTouchEnabled(true)
	elseif event == "exit" then
		_layer:unregisterScriptTouchHandler()
	end
end

function onTouchesHandler( eventType, x, y )
	if eventType == "began" then
		return true
	elseif eventType == "moved" then
	else
	end
end
