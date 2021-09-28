-- FileName: TransformMainLayer.lua 
-- Author: licong 
-- Date: 16/3/1 
-- Purpose: 转换功能主界面

module("TransformMainLayer", package.seeall)
require "script/ui/transform/TransformGodData"
require "script/ui/transform/TsTreasureData"
require "script/ui/transform/tstally/TsTallyData"
require "script/libs/LuaCCMenuItem"

local _bgLayer 									= nil
local _bgSprite 								= nil
local _topBg 									= nil
local _menuBg 									= nil
local _curButton 								= nil
local _curDisplayLayer 							= nil

local _curType 									= nil

local _touchPriority 							= -400

ksHeroType 										= 1001 -- 武将转换
ksGodWpType 									= 1002 -- 神兵转换
ksTreasureType 									= 1003 -- 宝物转换
ksTallyType										= 1004 -- 兵符转换
	
--[[
	@des 	: 初始化
	@param 	: 
	@return : 
--]]
function init( ... )
	_bgLayer 									= nil
	_bgSprite 									= nil
	_topBg 										= nil
	_menuBg 									= nil
	_curButton 									= nil
	_curDisplayLayer 							= nil

	_curType 									= nil

end

--[[
	@des 	:回调onEnter和onExit事件
	@param 	:
	@return :
--]]
function onNodeEvent( event )
	if (event == "enter") then
	elseif (event == "exit") then
	end
end

--[[
	@des 	:返回按钮
	@param 	:
	@return :
--]]
function backCallBack(tag, itemBtn )
	require "script/audio/AudioUtil"
	AudioUtil.playEffect("audio/effect/guanbi.mp3")

	require "script/ui/main/MainBaseLayer"
	local main_base_layer = MainBaseLayer.create()
	MainScene.changeLayer(main_base_layer, "main_base_layer",MainBaseLayer.exit)
	MainScene.setMainSceneViewsVisible(true,true,true)
end

--[[
	@des 	:创建上部分UI
	@param 	:
	@return :
--]]
function menuBarAction(tag, itemBtn )
	require "script/audio/AudioUtil"
	AudioUtil.playEffect("audio/effect/changtiaoxing.mp3")
	itemBtn:selected()
	if (_curButton ~= itemBtn) then
		_curButton:unselected()
		_curButton = itemBtn
		_curButton:selected()
		_curType = tag
		if(_curDisplayLayer ~= nil) then
			_curDisplayLayer:removeFromParentAndCleanup(true)
			_curDisplayLayer = nil
		end
		-- 创建中间ui
		createMiddleUI()
	end
end

--[[
	@des 	:创建上部分UI
	@param 	:
	@return :
--]]
function createTopUI( ... )
	require "script/utils/TopGoldSilver"
	-- 上标题栏 显示战斗力，银币，金币
	_topBg = TopGoldSilver.create()
    _topBg:setAnchorPoint(ccp(0.5,1))
    _topBg:setPosition(_bgLayer:getContentSize().width*0.5,_bgLayer:getContentSize().height)
    _topBg:setScale(g_fScaleX)
    _bgLayer:addChild(_topBg,30)

    -- 按钮背景
	local fullRect = CCRectMake(0,0,58,99)
	local insetRect = CCRectMake(20,20,18,59)
	_menuBg = CCScale9Sprite:create("images/common/menubg.png", fullRect, insetRect)
	_menuBg:setPreferredSize(CCSizeMake(640, 100))
	_menuBg:setAnchorPoint(ccp(0.5, 1))
	_menuBg:setPosition(ccp(_bgLayer:getContentSize().width*0.5 , _bgLayer:getContentSize().height-_topBg:getContentSize().height*g_fScaleX))
	_bgLayer:addChild(_menuBg,30)
	_menuBg:setScale(g_fScaleX)

	local menuBar = CCMenu:create()
	menuBar:setTouchPriority(_touchPriority)
	menuBar:setPosition(ccp(0, 0))
	_menuBg:addChild(menuBar)

	-- 返回
	local backBtn = CCMenuItemImage:create("images/common/close_btn_n.png","images/common/close_btn_h.png")
	backBtn:setAnchorPoint(ccp(1, 0))
	backBtn:setPosition(ccp(_menuBg:getContentSize().width*0.99, _menuBg:getContentSize().height*0.12))
	menuBar:addChild(backBtn)
	backBtn:registerScriptTapHandler(backCallBack)

	local image_n = "images/common/btn_title_n.png"
    local image_h = "images/common/btn_title_h.png"
    local rect_full_n   = CCRectMake(0,0,163,66)
    local rect_inset_n  = CCRectMake(80,35,2,3)
    local rect_full_h   = CCRectMake(0,0,163,66)
    local rect_inset_h  = CCRectMake(80,35,2,3)
    local btn_size_n    = CCSizeMake(163, 66)
    local btn_size_n2   = CCSizeMake(163, 66)
    local btn_size_h    = CCSizeMake(163, 66)
    local btn_size_h2   = CCSizeMake(163, 66)
    
    local text_color_n  = ccc3(0xff, 0xe4, 0x00)
    local text_color_h  = ccc3(0x48, 0x85, 0xb5)
    local font          = g_sFontPangWa
    local font_size_n   = 34
    local font_size_h   = 32
    local strokeCor_n   = ccc3(0x00, 0x00, 0x00)
    local strokeCor_h   = ccc3(0x00, 0x00, 0x00)
    local stroke_size_n = 1
    local stroke_size_h = 0

	-- 武将
	local heroBtn = LuaCCMenuItem.createMenuItemOfRenderAndFont( image_n, image_h,image_h,
		rect_full_n, rect_inset_n, rect_full_h, rect_inset_h,rect_full_h, rect_inset_h,
		btn_size_n2, btn_size_h2,btn_size_h2,
		GetLocalizeStringBy("lic_1790"), text_color_n, text_color_h, text_color_h, font, font_size_n,
		font_size_h, strokeCor_n, strokeCor_h,strokeCor_h, stroke_size_n, stroke_size_h, stroke_size_h)
	heroBtn:setAnchorPoint(ccp(0, 0))
	heroBtn:setPosition(ccp(_menuBg:getContentSize().width*0.01, _menuBg:getContentSize().height*0.1))
	heroBtn:registerScriptTapHandler(menuBarAction)
	menuBar:addChild(heroBtn, 1, ksHeroType)
	heroBtn:setScale(0.85)

	-- 神兵
	local godwpBtn = LuaCCMenuItem.createMenuItemOfRenderAndFont( image_n, image_h,image_h,
		rect_full_n, rect_inset_n, rect_full_h, rect_inset_h,rect_full_h, rect_inset_h,
		btn_size_n2, btn_size_h2,btn_size_h2,
		GetLocalizeStringBy("lic_1791"), text_color_n, text_color_h, text_color_h, font, font_size_n,
		font_size_h, strokeCor_n, strokeCor_h,strokeCor_h, stroke_size_n, stroke_size_h, stroke_size_h)
	godwpBtn:setAnchorPoint(ccp(0, 0))
	godwpBtn:setPosition(ccp(_menuBg:getContentSize().width*0.43, _menuBg:getContentSize().height*0.1))
	godwpBtn:registerScriptTapHandler(menuBarAction)
	menuBar:addChild(godwpBtn, 1, ksGodWpType)
	local isShow = TransformGodData.isOpen()
	godwpBtn:setVisible(isShow)
	godwpBtn:setScale(0.85)

	-- 宝物
	local treasureBtn = LuaCCMenuItem.createMenuItemOfRenderAndFont( image_n, image_h,image_h,
		rect_full_n, rect_inset_n, rect_full_h, rect_inset_h,rect_full_h, rect_inset_h,
		btn_size_n2, btn_size_h2,btn_size_h2,
		GetLocalizeStringBy("lic_1792"), text_color_n, text_color_h, text_color_h, font, font_size_n,
		font_size_h, strokeCor_n, strokeCor_h,strokeCor_h, stroke_size_n, stroke_size_h, stroke_size_h)
	treasureBtn:setAnchorPoint(ccp(0, 0))
	treasureBtn:setPosition(ccp(_menuBg:getContentSize().width*0.22, _menuBg:getContentSize().height*0.1))
	treasureBtn:registerScriptTapHandler(menuBarAction)
	menuBar:addChild(treasureBtn, 1, ksTreasureType)
	local isShow = TsTreasureData.isOpen()
	treasureBtn:setVisible(isShow)
	treasureBtn:setScale(0.85)

	-- 兵符 add by lgx 20160822
	local tallyBtn = LuaCCMenuItem.createMenuItemOfRenderAndFont( image_n, image_h,image_h,
		rect_full_n, rect_inset_n, rect_full_h, rect_inset_h,rect_full_h, rect_inset_h,
		btn_size_n2, btn_size_h2,btn_size_h2,
		GetLocalizeStringBy("lic_1771"), text_color_n, text_color_h, text_color_h, font, font_size_n,
		font_size_h, strokeCor_n, strokeCor_h,strokeCor_h, stroke_size_n, stroke_size_h, stroke_size_h)
	tallyBtn:setAnchorPoint(ccp(0, 0))
	tallyBtn:setPosition(ccp(_menuBg:getContentSize().width*0.64,_menuBg:getContentSize().height*0.1))
	tallyBtn:registerScriptTapHandler(menuBarAction)
	menuBar:addChild(tallyBtn, 1, ksTallyType)
	local isShow = TsTallyData.isOpen()
	tallyBtn:setVisible(isShow)
	tallyBtn:setScale(0.85)

	if(_curType == ksHeroType) then
		_curButton = heroBtn
		_curButton:selected()
	elseif(_curType == ksGodWpType) then 
		_curButton = godwpBtn
		_curButton:selected()
	elseif(_curType == ksTreasureType) then
		_curButton = treasureBtn
		_curButton:selected()
	elseif (_curType == ksTallyType) then
		_curButton = tallyBtn
		_curButton:selected()
	else
		-- 默认
		_curType = ksHeroType	
		_curButton = heroBtn
		_curButton:selected()
	end
end

--[[
	@des 	:创建下部分UI
	@param 	:
	@return :
--]]
function createMiddleUI( ... )
	local layerHight = _bgLayer:getContentSize().height-_topBg:getContentSize().height*g_fScaleX-_menuBg:getContentSize().height*g_fScaleX-MenuLayer.getHeight()
	local layerSieze = CCSizeMake(_bgLayer:getContentSize().width, layerHight)
	print("layerSieze==>",layerSieze.width,layerSieze.height)
	if(_curType == ksHeroType) then 
		-- 武将
		require "script/ui/rechargeActive/transfer/TransferLayer"
        _curDisplayLayer = TransferLayer.create( layerSieze )
        -- _curDisplayLayer = CCLayer:create()
	elseif(_curType == ksGodWpType) then 
		-- 神兵
		require "script/ui/transform/TransformGodLayer"
		_curDisplayLayer = TransformGodLayer.createLayer( layerSieze )
	elseif(_curType == ksTreasureType) then
		-- 宝物
		require "script/ui/transform/TsTreasureLayer"
		_curDisplayLayer = TsTreasureLayer.createLayer( layerSieze )
	elseif (_curType == ksTallyType) then
		-- 兵符
		require "script/ui/transform/tstally/TsTallyLayer"
		_curDisplayLayer = TsTallyLayer.createLayer( layerSieze )
	else	
		_curDisplayLayer = CCLayer:create()
	end
	_curDisplayLayer:setPosition(ccp(0,MenuLayer.getHeight()))
	_bgLayer:addChild(_curDisplayLayer)
end

--[[
	@des 	: 创建主界面
	@param 	: 
	@return : 
--]]
function createLayer( p_type )
	-- 初始化
	init()

	_curType = p_type

	_bgLayer = CCLayer:create()
	_bgLayer:registerScriptHandler(onNodeEvent) 

	-- 隐藏下排按钮
	MainScene.setMainSceneViewsVisible(true, false, false)

	-- 大背景
    _bgSprite = CCSprite:create("images/destney/destney_bg.png")
    _bgSprite:setAnchorPoint(ccp(0.5,0.5))
    _bgSprite:setPosition(ccp(_bgLayer:getContentSize().width*0.5,_bgLayer:getContentSize().height*0.5))
    _bgLayer:addChild(_bgSprite)
    _bgSprite:setScale(g_fBgScaleRatio)

    -- 创建上部分
    createTopUI()

    -- 创建中间
    createMiddleUI()

	return _bgLayer
end

--[[
	@des 	: 显示主界面
	@param 	: 
	@return : 
--]]
function showLayer( p_type )
 	if not DataCache.getSwitchNodeState(ksTransfer) then
        return
    end
    require "script/ui/bag/BagLayer"
    local layer = createLayer(p_type)
    MainScene.changeLayer(layer, "TransformMainLayer")
end












