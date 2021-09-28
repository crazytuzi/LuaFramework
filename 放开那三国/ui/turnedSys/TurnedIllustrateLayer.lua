-- FileName: TurnedIllustrateLayer.lua
-- Author: lgx
-- Date: 2016-09-13
-- Purpose: 武将幻化系统 幻化图鉴界面

module("TurnedIllustrateLayer", package.seeall)

require "script/ui/turnedSys/TurnedDef"
require "script/ui/turnedSys/HeroTurnedData"
require "script/ui/turnedSys/TurnedIllustrateCell"

-- UI控件引用变量 --
local _bgLayer				= nil -- 背景层
local _topBg 				= nil -- 顶部背景
local _menuBg 				= nil -- 国家标签背景
local _bottomBg 			= nil -- 底部背景
local _selCounItem 			= nil -- 选择的按钮
local _heroTableView 		= nil -- 武将列表

-- 模块局部变量 --
local _touchPriority		= nil -- 触摸优先级
local _zOrder				= nil -- 显示层级
local _selCountry 			= nil -- 选择的国家
local _herosData 			= nil -- 武将列表数据
local _touchBeganX 			= nil -- 开始触摸点x坐标
local _touchBeganY 			= nil -- 开始触摸点y坐标
local _tableOffset 			= nil -- tableView的当前offset

--[[
	@desc 	: 初始化方法
	@param 	: 
	@return : 
--]]
local function init()
	_bgLayer 			= nil
	_topBg 				= nil
	_menuBg 			= nil
	_bottomBg 			= nil
	_selCounItem 		= nil
	_heroTableView 		= nil
	_touchPriority 		= nil
	_zOrder 			= nil
	_selCountry 		= nil
	_herosData 			= nil
	_touchBeganX 		= nil
	_touchBeganY 		= nil
	_tableOffset 		= nil
end

--[[
	@desc	: 背景层触摸回调
    @param	: eventType 事件类型 x,y 触摸点
    @return	: 
—-]]
local function layerToucCallback( eventType, x, y )
	-- print("------ TurnedIllustrateLayer layerToucCallback ------")
	local position = _heroTableView:convertToNodeSpace(ccp(x, y))

    if eventType == "began" then
		_touchBeganX = position.x
		_touchBeganY = position.y
		_tableOffset = _heroTableView:getContentOffset()
        return true
    elseif eventType == "moved" then
		local distanceX = math.abs(position.x - _touchBeganX)
		local distanceY = math.abs(position.y - _touchBeganY)
		-- 横行滑动大于纵向 或 纵向滑动小于150 不滑动
		if (distanceX > distanceY or distanceY < 150*g_fElementScaleRatio ) then
			_heroTableView:setContentOffset(_tableOffset)
		end
		-- print("distanceX =>",distanceX,"distanceY =>",distanceY)
    elseif eventType == "ended" or eventType == "cancelled" then
		local distanceX = math.abs(position.x - _touchBeganX)
		local distanceY = math.abs(position.y - _touchBeganY)
		-- 横行滑动大于纵向 或 纵向滑动小于150 不滑动
		if (distanceX > distanceY or distanceY < 150*g_fElementScaleRatio ) then
			_heroTableView:setContentOffset(_tableOffset)
		end
		-- print("distanceX =>",distanceX,"distanceY =>",distanceY)
    end
end

--[[
	@desc	: 回调onEnter和onExit事件
    @param	: event 事件名
    @return	: 
—-]]
function onNodeEvent( event )
	if (event == "enter") then
		_bgLayer:registerScriptTouchHandler(layerToucCallback,false,_touchPriority,true)
		_bgLayer:setTouchEnabled(true)
	elseif (event == "exit") then
		_bgLayer:unregisterScriptTouchHandler()
		_bgLayer = nil
	end
end

--[[
	@desc 	: 显示界面方法
	@param 	: pTouchPriority 触摸优先级
	@param 	: pZorder 显示层级
	@return : 
--]]
function showLayer( pTouchPriority, pZorder )
	local layer = createLayer(pTouchPriority, pZorder)
	local scene = CCDirector:sharedDirector():getRunningScene()
    scene:addChild(layer,_zOrder)
end

--[[
	@desc	: 创建Layer及UI
    @param	: pTouchPriority 触摸优先级
    @param 	: pZorder 显示层级
    @return	: CCLayer 背景层
—-]]
function createLayer( pTouchPriority, pZorder )
	-- 初始化
	init()

	_touchPriority = pTouchPriority or -600
	_zOrder = pZorder or 1000

	-- 背景层
	_bgLayer = CCLayerColor:create(ccc4(0, 0, 0, 200))
	_bgLayer:registerScriptHandler(onNodeEvent)
	_bgLayer:setPosition(ccp(0, 0))
	_bgLayer:setAnchorPoint(ccp(0, 0))

	-- 背景
	local bgSprite = CCSprite:create("images/main/module_bg.png")
	bgSprite:setAnchorPoint(ccp(0.5,0.5))
	bgSprite:setPosition(ccp(_bgLayer:getContentSize().width/2,_bgLayer:getContentSize().height/2))
	bgSprite:setScale(g_fBgScaleRatio)
	_bgLayer:addChild(bgSprite)

	-- 顶部按钮
	createTopInfo()
	-- 底部图鉴属性
	createBottomInfo()
	-- 武将列表
	createHeroTableView()

	return _bgLayer
end

--[[
	@desc	: 创建顶部按钮
    @param	: 
    @return	: 
—-]]
function createTopInfo()
	-- 顶部背景
	_topBg = CCSprite:create("images/hero/select/title_bg.png")
	_topBg:setAnchorPoint(ccp(0.5, 1))
	_topBg:setPosition(_bgLayer:getContentSize().width*0.5, _bgLayer:getContentSize().height)
	_topBg:setScale(g_fScaleX)
	_bgLayer:addChild(_topBg,1)

	-- 选择标题
	local titleSp = CCSprite:create("images/turnedSys/illustrate_title.png")
	titleSp:setAnchorPoint(ccp(0,0))
	titleSp:setPosition(ccp(45, 50))
	_topBg:addChild(titleSp)

	-- 按钮菜单
    local backMenu = CCMenu:create()
    backMenu:setAnchorPoint(ccp(0,0))
    backMenu:setPosition(ccp(0,0))
    backMenu:setTouchPriority(_touchPriority-5)
    _topBg:addChild(backMenu)

	-- 返回按钮
	local backItem = CCMenuItemImage:create("images/common/close_btn_n.png","images/common/close_btn_h.png")
	backItem:setAnchorPoint(ccp(0, 0))
	backItem:setPosition(ccp(520, 40))
	backMenu:addChild(backItem)
	backItem:registerScriptTapHandler(backItemCallback)

	-- 标签背景
	local fullRect = CCRectMake(0,0,58,99)
	local insetRect = CCRectMake(20,20,18,59)
	_menuBg = CCScale9Sprite:create("images/common/menubg.png", fullRect, insetRect)
	_menuBg:setPreferredSize(CCSizeMake(640, 100))
	_menuBg:setAnchorPoint(ccp(0.5, 1))
	_menuBg:setPosition(ccp(_bgLayer:getContentSize().width/2 , _bgLayer:getContentSize().height- (_topBg:getContentSize().height-25) * g_fScaleX ))
	_menuBg:setScale(g_fScaleX)
	_bgLayer:addChild(_menuBg)

	-- 国家标签
	local counMenu = CCMenu:create()
	counMenu:setTouchPriority(_touchPriority-5)
	counMenu:setPosition(ccp(0,0))
	_menuBg:addChild(counMenu)

	local image_n = "images/recycle/btn_title_h.png"
    local image_h = "images/recycle/btn_title_n.png"
    local rect_full_n   = CCRectMake(0,0,140,65)
    local rect_inset_n  = CCRectMake(68,35,2,3)
    local rect_full_h   = CCRectMake(0,0,140,65)
    local rect_inset_h  = CCRectMake(68,35,2,3)
    local btn_size_n    = CCSizeMake(140, 65)
    local btn_size_n2   = CCSizeMake(140, 65)
    local btn_size_h    = CCSizeMake(140, 65)
    local btn_size_h2   = CCSizeMake(140, 65)
    
    local text_color_n  = ccc3(0xff, 0xe4, 0x00)
    local text_color_h  = ccc3(0x48, 0x85, 0xb5)
    local font          = g_sFontPangWa
    local font_size_n   = 30
    local font_size_h   = 28
    local strokeCor_n   = ccc3(0x00, 0x00, 0x00)
    local strokeCor_h   = ccc3(0x00, 0x00, 0x00)
    local stroke_size_n = 1
    local stroke_size_h = 0

   	-- 魏
	local weiItem = LuaCCMenuItem.createMenuItemOfRenderAndFont( image_n, image_h,image_h,
		rect_full_n, rect_inset_n, rect_full_h, rect_inset_h,rect_full_h, rect_inset_h,
		btn_size_n2, btn_size_h2,btn_size_h2,
		GetLocalizeStringBy("lic_1758"), text_color_n, text_color_h, text_color_h, font, font_size_n,
		font_size_h, strokeCor_n, strokeCor_h,strokeCor_h, stroke_size_n, stroke_size_h, stroke_size_h)
	weiItem:setAnchorPoint(ccp(0, 0))
	weiItem:setPosition(ccp(_menuBg:getContentSize().width*0.01, _menuBg:getContentSize().height*0.1))
	weiItem:registerScriptTapHandler(countryItemCallback)
	counMenu:addChild(weiItem, 1, TurnedDef.kTagWeiGuo)

	-- 蜀
	local shuItem = LuaCCMenuItem.createMenuItemOfRenderAndFont( image_n, image_h,image_h,
		rect_full_n, rect_inset_n, rect_full_h, rect_inset_h,rect_full_h, rect_inset_h,
		btn_size_n2, btn_size_h2,btn_size_h2,
		GetLocalizeStringBy("lic_1759"), text_color_n, text_color_h, text_color_h, font, font_size_n,
		font_size_h, strokeCor_n, strokeCor_h,strokeCor_h, stroke_size_n, stroke_size_h, stroke_size_h)
	shuItem:setAnchorPoint(ccp(0, 0))
	shuItem:setPosition(ccp(_menuBg:getContentSize().width*0.22, _menuBg:getContentSize().height*0.1))
	shuItem:registerScriptTapHandler(countryItemCallback)
	counMenu:addChild(shuItem, 1, TurnedDef.kTagShuGuo)

	-- 吴
	local wuItem = LuaCCMenuItem.createMenuItemOfRenderAndFont( image_n, image_h,image_h,
		rect_full_n, rect_inset_n, rect_full_h, rect_inset_h,rect_full_h, rect_inset_h,
		btn_size_n2, btn_size_h2,btn_size_h2,
		GetLocalizeStringBy("lic_1760"), text_color_n, text_color_h, text_color_h, font, font_size_n,
		font_size_h, strokeCor_n, strokeCor_h,strokeCor_h, stroke_size_n, stroke_size_h, stroke_size_h)
	wuItem:setAnchorPoint(ccp(0, 0))
	wuItem:setPosition(ccp(_menuBg:getContentSize().width*0.43, _menuBg:getContentSize().height*0.1))
	wuItem:registerScriptTapHandler(countryItemCallback)
	counMenu:addChild(wuItem, 1, TurnedDef.kTagWuGuo)

	-- 群
	local qunItem = LuaCCMenuItem.createMenuItemOfRenderAndFont( image_n, image_h,image_h,
		rect_full_n, rect_inset_n, rect_full_h, rect_inset_h,rect_full_h, rect_inset_h,
		btn_size_n2, btn_size_h2,btn_size_h2,
		GetLocalizeStringBy("lic_1761"), text_color_n, text_color_h, text_color_h, font, font_size_n,
		font_size_h, strokeCor_n, strokeCor_h,strokeCor_h, stroke_size_n, stroke_size_h, stroke_size_h)
	qunItem:setAnchorPoint(ccp(0, 0))
	qunItem:setPosition(ccp(_menuBg:getContentSize().width*0.64, _menuBg:getContentSize().height*0.1))
	qunItem:registerScriptTapHandler(countryItemCallback)
	counMenu:addChild(qunItem, 1, TurnedDef.kTagQun)

	if (_selCountry == TurnedDef.kTagWeiGuo) then
		_selCounItem = weiItem
	elseif (_selCountry == TurnedDef.kTagShuGuo) then 
		_selCounItem = shuItem
	elseif (_selCountry == TurnedDef.kTagWuGuo) then
		_selCounItem = wuItem
	elseif (_selCountry == TurnedDef.kTagQun) then
		_selCounItem = qunItem
	else
		-- 默认
		_selCountry = TurnedDef.kTagWeiGuo	
		_selCounItem = weiItem
	end
	_selCounItem:selected()
end

--[[
	@desc	: 创建幻化图鉴总属性
    @param	: 
    @return	: 
—-]]
function createBottomInfo()
	-- 图鉴属性
	_bottomBg = BaseUI.createContentBg(CCSizeMake(640,175))
	_bottomBg:setAnchorPoint(ccp(0.5, 0))
	_bottomBg:setPosition(_bgLayer:getContentSize().width*0.5, 0)
	_bottomBg:setScale(g_fScaleX)
	_bgLayer:addChild(_bottomBg,1)

	-- 花边
	local upLineSp = CCSprite:create("images/hunt/up_line.png")
	upLineSp:setAnchorPoint(ccp(0.5,1))
	upLineSp:setPosition(ccp(_bottomBg:getContentSize().width*0.5,_bottomBg:getContentSize().height))
	_bottomBg:addChild(upLineSp, 1)

	local downLineSp = CCSprite:create("images/hunt/down_line.png")
	downLineSp:setAnchorPoint(ccp(0.5,0))
	downLineSp:setPosition(ccp(_bottomBg:getContentSize().width*0.5,0))
	_bottomBg:addChild(downLineSp, 1)

	-- 标题
	local titleBg = CCScale9Sprite:create(CCRectMake(86, 30, 4, 8), "images/pet/pet/talent_skill.png")
	_bottomBg:addChild(titleBg, 2)
	titleBg:setAnchorPoint(ccp(0.5, 0.5))
	titleBg:setPosition(ccp(_bottomBg:getContentSize().width * 0.5, _bottomBg:getContentSize().height - 10))

	local titleLab = CCLabelTTF:create(GetLocalizeStringBy("lgx_1111"), g_sFontPangWa, 27)
	titleBg:addChild(titleLab)
	titleLab:setAnchorPoint(ccp(0.5, 0.5))
	titleLab:setPosition(ccp(titleBg:getContentSize().width * 0.5, titleBg:getContentSize().height * 0.5 + 8))
	titleLab:setColor(ccc3(0xff, 0xe4, 0x00))

	-- 属性
	local attrInfo = HeroTurnedData.getAllTurnAttrInfo()
    local i = 0
    for k,v in pairs(attrInfo) do
    	local row = math.floor(i/2)
	 	local col = i%2
    	local affixDesc, displayNum, realNum = ItemUtil.getAtrrNameAndNum(k,v)

    	local attrTab = {}
    	attrTab[1] = CCLabelTTF:create(affixDesc.sigleName, g_sFontName, 23)
	    attrTab[1]:setColor(ccc3(0xff,0xff,0xff))
	    attrTab[2] = CCLabelTTF:create(" +" .. displayNum, g_sFontName, 23)
	    attrTab[2]:setColor(ccc3(0x00,0xff,0x18))

	    local attrFont = BaseUI.createHorizontalNode(attrTab)
	    attrFont:setAnchorPoint(ccp(0,0))
		attrFont:setPosition(ccp(85+330*col,110-row*35))
		_bottomBg:addChild(attrFont)
		i = i + 1
	end

	-- 完成度
	local progressTab = {}
    progressTab[1] = CCLabelTTF:create(GetLocalizeStringBy("key_2504")..":", g_sFontName, 23)
    progressTab[1]:setColor(ccc3(0xff,0xff,0xff))
    local porStr = HeroTurnedData.getAllProgressStr()
    progressTab[2] = CCLabelTTF:create(porStr, g_sFontName, 23)
    progressTab[2]:setColor(ccc3(0x00,0xff,0x18))

    local progressFont = BaseUI.createHorizontalNode(progressTab)
    progressFont:setAnchorPoint(ccp(0.5,0))
	progressFont:setPosition(ccp(_bottomBg:getContentSize().width*0.5,50))
	_bottomBg:addChild(progressFont)

	-- 提示
	local tipLabel = CCLabelTTF:create(GetLocalizeStringBy("lgx_1112"), g_sFontName, 23)
	_bottomBg:addChild(tipLabel,10)
	tipLabel:setAnchorPoint(ccp(0.5, 0))
	tipLabel:setPosition(ccp(_bottomBg:getContentSize().width*0.5,15))
	tipLabel:setColor(ccc3(0x00,0xe4,0xff))
end

--[[
	@desc	: 创建幻化图鉴武将列表
    @param	: 
    @return	: 
—-]]
function createHeroTableView()
	local topHeight = (_topBg:getContentSize().height-25)*g_fScaleX+_menuBg:getContentSize().height*g_fScaleX
	local bottomHeight = _bottomBg:getContentSize().height*g_fScaleX
	local tableViewHeight = _bgLayer:getContentSize().height - topHeight - bottomHeight

	local cellSize = CCSizeMake(_bgLayer:getContentSize().width,280*g_fScaleX)

	-- 获取数据
	_herosData = HeroTurnedData.getHerosDataByCountry(_selCountry - TurnedDef.kTagBase)

	local handler = LuaEventHandler:create(function(fn, table, a1, a2)
		local r
		if fn == "cellSize" then
			r = CCSizeMake(cellSize.width, cellSize.height)
		elseif fn == "cellAtIndex" then
	        a2 = TurnedIllustrateCell.createCell(_herosData[a1+1],_touchPriority)
	        a2:setScale(g_fScaleX)
			r = a2
		elseif fn == "numberOfCells" then
			r = #_herosData
		elseif fn == "cellTouched" then
		else
		end
		return r
	end)

	_heroTableView = LuaTableView:createWithHandler(handler, CCSizeMake(_bgLayer:getContentSize().width, tableViewHeight))
	_heroTableView:setAnchorPoint(ccp(0,0))
	_heroTableView:setBounceable(true)
	_heroTableView:setTouchPriority(_touchPriority-3)
	_heroTableView:setPosition(ccp(0,bottomHeight))
	_bgLayer:addChild(_heroTableView)
end

--[[
	@desc	: 更新幻化图鉴武将列表
    @param	: 
    @return	: 
—-]]
function updateHeroTableView()
	_herosData = HeroTurnedData.getHerosDataByCountry(_selCountry - TurnedDef.kTagBase)
	_heroTableView:reloadData()
end

--[[
	@desc	: 点击国家标签按钮回调
    @param	: pTag,pItem 按钮Tag,按钮
    @return	: 
—-]]
function countryItemCallback( pTag, pItem )
	require "script/audio/AudioUtil"
	AudioUtil.playEffect("audio/effect/changtiaoxing.mp3")
	pItem:selected()
	if (_selCounItem ~= pItem) then
		_selCounItem:unselected()
		_selCounItem = pItem
		_selCounItem:selected()
		_selCountry = pTag
		-- 刷新武将列表
		updateHeroTableView()
	end
end

--[[
	@desc	: 返回按钮回调，关闭界面
    @param	: 
    @return	: 
—-]]
function backItemCallback()
	require "script/audio/AudioUtil"
    AudioUtil.playEffect("audio/effect/guanbi.mp3")
	if not tolua.isnull(_bgLayer) then
		_bgLayer:removeFromParentAndCleanup(true)
		_bgLayer = nil
	end
end
