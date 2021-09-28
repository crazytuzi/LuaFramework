-- Filename: PetDescriptionPanel.lua
-- Author: ZQ
-- Date: 2014-07-07
-- Purpose: 创建宠物的说明面板
module("PetDescriptionPanel",package.seeall)

local kDarkLayerTouchPriority = -550
local kCloseBtnTouchPriority = -551
local KTableViewTouchPriority = -552
local kDarkLayerZOrder = 999
local kDescLabelFontSize = 21
local kSpaceBeforeDescLabel = 50			--文字说明label前的距离
local kSpaceFollowDescLabel = 50			--文字说明label和图鉴之间的间距
local kSpaceLeftAndRightDescLabel = 40		--文字说明label左右距离
local kIllustratedHandbookBgHeight = 250	--图鉴背景高度
local kSpaceFollowIllustratedHandbookBg = 30 --图鉴后的距离
local kTableViewContentSize = CCSizeMake(430, 200)


local _darkShieldLayer = nil
local _panelBackgroundSprite = nil
local _panelContentSize = nil				--整个描述面板的尺寸
local _descriptionLabelDimensions = nil 	--文字说明标签的尺寸
local _wordsPerLineNum = nil				--文字说明中的每行字数

--[[
	@des:		初始化各全局变量
	@param:		none
	@retrun:	none
--]]
function init()
	_darkShieldLayer = nil
	_panelBackgroundSprite = nil
	_panelContentSize = CCSizeMake(0,0)
	_descriptionLabelDimensions = CCSizeMake(0,0)
	_wordsPerLineNum = 23
end

--[[
	@des:		简单数据处理获取所需数据
	@param		none
	@return:	none
--]]
function load()
	require "script/ui/pet/description/PetDescriptionData"
	local descInfoString = PetDescriptionData.getDescriptionString()
	_descriptionLabelDimensions = PetDescriptionData.getStringToLineDimensions(descInfoString, _wordsPerLineNum, kDescLabelFontSize)

	_panelContentSize.width = _descriptionLabelDimensions.width + 2 * kSpaceLeftAndRightDescLabel
	_panelContentSize.height = kSpaceBeforeDescLabel + _descriptionLabelDimensions.height + kSpaceFollowDescLabel + kIllustratedHandbookBgHeight + kSpaceFollowIllustratedHandbookBg
end

-- --[[
-- 	@des:		获取tableViewCell的尺寸
-- 	@param		none
-- 	@return:	none
-- --]]
-- function getTableViewCellSize()
-- 	return kTableViewCellSize
-- end

--[[
	@des:		创建顶部描述
	@param:		none
	@retrun:	none
--]]
function createTopDescriptionLabel()
	local descInfoString = PetDescriptionData.getDescriptionString()
	local descInfoLabel = CCLabelTTF:create(descInfoString, g_sFontName, kDescLabelFontSize)
	descInfoLabel:setDimensions(_descriptionLabelDimensions)
	descInfoLabel:setHorizontalAlignment(kCCTextAlignmentLeft)
	descInfoLabel:setVerticalAlignment(kCCVerticalTextAlignmentTop)
	descInfoLabel:setColor(ccc3(0x78, 0x25, 0x00))
	descInfoLabel:setAnchorPoint(ccp(0.5, 1))
	descInfoLabel:setPosition(_panelContentSize.width/2, _panelContentSize.height - kSpaceBeforeDescLabel)
	_panelBackgroundSprite:addChild(descInfoLabel)
end

--[[
	@des:		创建宠物图鉴
	@param:		none
	@return:	none
--]]
function createIllustratedHandbook()
	--背景
	local illuStratedhandbookBg = CCScale9Sprite:create("images/common/bg/bg_ng_attr.png")
	illuStratedhandbookBg:setPreferredSize(CCSizeMake(_descriptionLabelDimensions.width, kIllustratedHandbookBgHeight))
	illuStratedhandbookBg:setAnchorPoint(ccp(0.5,1))
	illuStratedhandbookBg:setPosition(_panelContentSize.width/2, kIllustratedHandbookBgHeight + kSpaceFollowIllustratedHandbookBg)
	_panelBackgroundSprite:addChild(illuStratedhandbookBg)

	--标题
	--local titleSprite = CCSprite:create("images/forge/floor_title_bg.png")
	local titleSprite = CCScale9Sprite:create("images/astrology/astro_labelbg.png")
	titleSprite:setPreferredSize(CCSizeMake(184,35))
	titleSprite:setAnchorPoint(ccp(0.5,0.5))
	local bgContentSize = illuStratedhandbookBg:getContentSize()
	titleSprite:setPosition(bgContentSize.width/2, bgContentSize.height)
	illuStratedhandbookBg:addChild(titleSprite)

	--标题label
	local titleLabel = CCLabelTTF:create(GetLocalizeStringBy("zz_11"),g_sFontPangWa,24)
	titleLabel:setColor(ccc3(0xff, 0xe4, 0x00))
	titleLabel:setAnchorPoint(ccp(0.5,0.5))
	local titleSpriteContenSize = titleSprite:getContentSize()
	titleLabel:setPosition(titleSpriteContenSize.width/2,titleSpriteContenSize.height/2)
	titleSprite:addChild(titleLabel)

	--宠物图鉴table
	require "script/ui/pet/description/PetIllustratedHandbookCell"
	local illustratedHandbookDataTable = {}
	local tempTable = PetDescriptionData.getAllPetInfoTable()
	table.insert(illustratedHandbookDataTable, tempTable)
	local function createTableViewHandler(p_funcName, p_table, p_object1, p_object2)
		local ret = nil
		if p_funcName == "cellSize" then
			--if p_object1 == 0 then
				local height = math.ceil(table.count(tempTable) / PetIllustratedHandbookCell.getIconNumPerLine()) * 126
				ret = CCSizeMake(kTableViewContentSize.width, height)
			--end
		elseif p_funcName == "cellAtIndex" then
			ret = PetIllustratedHandbookCell.createTableViewCell(illustratedHandbookDataTable[p_object1+1])
		elseif p_funcName == "numberOfCells" then
			ret = #illustratedHandbookDataTable
		end
		return ret
	end
	local tableHandler = LuaEventHandler:create(createTableViewHandler)
	local illustratedHandbookTable = LuaTableView:createWithHandler(tableHandler,kTableViewContentSize)
	illustratedHandbookTable:setTouchPriority(KTableViewTouchPriority)
	illustratedHandbookTable:setBounceable(true)
	illustratedHandbookTable:setVerticalFillOrder(kCCTableViewFillTopDown)
	illustratedHandbookTable:ignoreAnchorPointForPosition(false)
	illustratedHandbookTable:setAnchorPoint(ccp(0.5,0.5))
	illustratedHandbookTable:setPosition(bgContentSize.width/2,bgContentSize.height/2-8)
	illuStratedhandbookBg:addChild(illustratedHandbookTable)
end

--[[
	@des:		创建描述面板
	@param:		none
	@retrun:	none
--]]
function createLayer()
	-- 屏蔽层
	_darkShieldLayer = CCLayerColor:create(ccc4(0,0,0,155))
	_darkShieldLayer:setContentSize(CCSizeMake(g_winSize.width/g_fScaleX,g_winSize.height/g_fScaleX))
	_darkShieldLayer:setScale(g_fScaleX)
	_darkShieldLayer:registerScriptHandler(onNodeEvent)

	-- 面板背景
	_panelBackgroundSprite = CCScale9Sprite:create("images/common/viewbg1.png")
	_panelBackgroundSprite:setPreferredSize(_panelContentSize)
	_panelBackgroundSprite:setAnchorPoint(ccp(0.5,0.5))
	_panelBackgroundSprite:setPosition(g_winSize.width/(g_fScaleX * 2),g_winSize.height/(g_fScaleX * 2))
	_darkShieldLayer:addChild(_panelBackgroundSprite)

	-- 面板标题
    local panelTitle = CCSprite:create("images/formation/changeformation/titlebg.png")
	panelTitle:setAnchorPoint(ccp(0.5,0.5))
	panelTitle:setPosition(ccp(_panelBackgroundSprite:getContentSize().width * 0.5, _panelBackgroundSprite:getContentSize().height - 6))
	_panelBackgroundSprite:addChild(panelTitle)

	local panelTitleText = CCLabelTTF:create(GetLocalizeStringBy("zz_10"), g_sFontPangWa, 33)
	panelTitleText:setColor(ccc3(0xff, 0xe4, 0x00))
	panelTitleText:setAnchorPoint(ccp(0.5, 0.5))
	panelTitleText:setPosition(ccp(panelTitle:getContentSize().width * 0.5, panelTitle:getContentSize().height * 0.5))
	panelTitle:addChild(panelTitleText)

	-- 创建文字说明
	createTopDescriptionLabel()

	-- 创建宠物图鉴
	createIllustratedHandbook()

	-- 关闭按钮
    local menu = CCMenu:create()
    menu:setPosition(ccp(0,0))
    menu:setTouchPriority(kCloseBtnTouchPriority)
    _panelBackgroundSprite:addChild(menu)
    local closeBtn = CCMenuItemImage:create("images/common/btn_close_n.png", "images/common/btn_close_h.png")
    closeBtn:setPosition(ccp(_panelContentSize.width*1.03,_panelContentSize.height*1.03))
    closeBtn:setAnchorPoint(ccp(1,1))
    closeBtn:registerScriptTapHandler(closeBtnCb)
    menu:addChild(closeBtn)
end

--[[
	@des:		显示屏蔽层及其内容
	@param:		none
	@return:	none
--]]
--(函数添加到PetMainLayer.lua)
function showLayer()
	init()
	load()
	createLayer()

	local runningScene = CCDirector:sharedDirector():getRunningScene()
	runningScene:addChild(_darkShieldLayer, kDarkLayerZOrder)
end

--[[
	@des:		屏蔽层创建和退出事件回调函数
	@param:		事件类型
	@return:	none
--]]
function onNodeEvent(p_eventType)
	--触摸事件回调
	local function onTouchEvent(p_eventType, p_x, p_y)
		if p_eventType == "began" then
			return true
		end
	end

	--"enter": 被创建事件 "exit": 退出事件
	if p_eventType == "enter" then
		_darkShieldLayer:registerScriptTouchHandler(onTouchEvent, false, kDarkLayerTouchPriority, true)
		_darkShieldLayer:setTouchEnabled(true)
	elseif p_eventType == "exit" then
		_darkShieldLayer:unregisterScriptTouchHandler()
	else
	end
end

--[[
	@des:		右上角关闭按钮点击回调
	@param:		p_tagNum 被点击对象tag
				p_itemObj 被点击对象
	@return:	none
--]]
function closeBtnCb(p_tagNum, p_itemObj)
	require "script/audio/AudioUtil"
	AudioUtil.playEffect("audio/effect/guanbi.mp3")
	_darkShieldLayer:removeFromParentAndCleanup(true)
	_darkShieldLayer = nil
end