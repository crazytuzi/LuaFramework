-- FileName: GuildBossResultLayer.lua.lua 
-- Author: llp
-- Date: 16-3-9 
-- Purpose: function description of module 

require "script/model/user/UserModel"
require "script/ui/item/ItemSprite"
require "script/ui/item/ItemUtil"
require "script/ui/hero/HeroPublicLua"
require "script/ui/hero/HeroPublicCC"

module("GuildBossResultLayer", package.seeall)

local _bgLayer 					= nil
local otherCallFun 				= nil    -- 传入回调
local layer_priority			= nil    -- layerTouch优先级
local menu_priority				= nil    -- menuTouch优先级
local layer_zOrder				= nil    -- layerZ轴
local bg_hight 					= nil	 -- 背景高度
local itemBg_hight 				= nil	 -- 物品列表背景高度
local tableView_hight 			= nil	 -- 物品列表高度
local yesItem 					= nil 	 -- 确定按钮	
local tView_priority 			= nil
local tView_menuPriority        = nil
local tView_infoPriority		= nil

local _titleText 				= nil    -- 标题
local _callFunArgs 				= nil

-- 初始化
function init( ... )
	_bgLayer 					= nil
	otherCallFun 				= nil    -- 传入回调
	layer_priority				= nil    -- layerTouch优先级
	menu_priority				= nil    -- menuTouch优先级
	layer_zOrder				= nil    -- layerZ轴
	bg_hight 					= nil	 -- 背景高度
	itemBg_hight 				= nil	 -- 物品列表背景高度
	tableView_hight 			= nil	 -- 物品列表高度
	yesItem 					= nil 	 -- 确定按钮	
	tView_priority 				= nil
	tView_menuPriority        	= nil
	tView_infoPriority			= nil
	_titleText 					= nil
	_callFunArgs 				= nil
end

function showRewardWindow( itemArr_data, callBackFun, zOrder, priority, titleText, p_callFunArgs )
	if(_bgLayer ~= nil)then
		_bgLayer:removeFromParentAndCleanup(true)
		_bgLayer = nil
	end
	-- 初始化
	init()
	-- local itemArr_data = arr
	otherCallFun = callBackFun
	layer_priority = tonumber(priority) or -430 
	tView_menuPriority = tonumber(layer_priority-1) or -431
	tView_priority = tonumber(layer_priority-2) or -432
	menu_priority = tonumber(layer_priority-3) or -433
	tView_infoPriority = tonumber(layer_priority-4) or -434
    layer_zOrder = tonumber(zOrder) or 2100
    _titleText 	= titleText or GetLocalizeStringBy("key_2407")
    _callFunArgs = p_callFunArgs
   
	print("layer_priority",layer_priority,"tView_menuPriority",tView_menuPriority,"tView_priority",tView_priority,"menu_priority",menu_priority,"tView_infoPriority",tView_infoPriority)
	-- 创建层
	_bgLayer = CCLayerColor:create(ccc4(11,11,11,200))
	_bgLayer:setTouchEnabled(true)
    _bgLayer:registerScriptTouchHandler(cardLayerTouch,false,layer_priority,true)
    
    local scene = CCDirector:sharedDirector():getRunningScene()
    scene:addChild(_bgLayer,layer_zOrder,4320)
    print("layer_zOrder",layer_zOrder)
    -- 根据奖励物品个数设置高度
    if(table.count(itemArr_data) > 8)then
    	bg_hight = 570
    	itemBg_hight = 310
    	tableView_hight = 300
    elseif( table.count(itemArr_data) > 4 and table.count(itemArr_data) <= 8 )then
    	bg_hight = 530
    	itemBg_hight = 300
    	tableView_hight = 290
    else
    	bg_hight = 380
    	itemBg_hight = 150
    	tableView_hight = 140
    end
    -- 创建背景
    local reward_bg = BaseUI.createViewBg(CCSizeMake(583,bg_hight))
    reward_bg:setPosition(ccp(g_winSize.width*0.5,g_winSize.height*0.5))
    _bgLayer:addChild(reward_bg)
    reward_bg:setTag(4321)
    -- 适配
	setAdaptNode(reward_bg)
	local thisScale = reward_bg:getScale()
 	reward_bg:setScale(0)
 	local array = CCArray:create()
    local scale1 = CCScaleTo:create(0.08,1.2*thisScale)
    local fade = CCFadeIn:create(0.06)
    local spawn = CCSpawn:createWithTwoActions(scale1,fade)
    local scale2 = CCScaleTo:create(0.07,0.9*thisScale)
    local scale3 = CCScaleTo:create(0.07,1*thisScale)
    array:addObject(scale1)
    array:addObject(scale2)
    array:addObject(scale3)
    local seq = CCSequence:create(array)
    reward_bg:runAction(seq)

    -- 关闭按钮
	local menu = CCMenu:create()
	menu:setTouchPriority(menu_priority)
	menu:setPosition(ccp(0, 0))
	menu:setAnchorPoint(ccp(0, 0))
	reward_bg:addChild(menu)
	local closeButton = CCMenuItemImage:create("images/common/btn_close_n.png", "images/common/btn_close_h.png")
	closeButton:setAnchorPoint(ccp(0.5, 0.5))
	closeButton:setPosition(ccp(reward_bg:getContentSize().width*0.95, reward_bg:getContentSize().height*0.95 ))
	closeButton:registerScriptTapHandler(yesItemCallFun)
	menu:addChild(closeButton)

	-- 确定按钮
	local normalSprite  =CCScale9Sprite:create("images/common/btn/btn_blue_n.png")
	normalSprite:setContentSize(CCSizeMake(180,64))
    local selectSprite  =CCScale9Sprite:create("images/common/btn/btn_blue_h.png")
    selectSprite:setContentSize(CCSizeMake(180,64))
    yesItem = CCMenuItemSprite:create(normalSprite,selectSprite)
	yesItem:setAnchorPoint(ccp(0.5,0))
	yesItem:setPosition(ccp(reward_bg:getContentSize().width*0.5,reward_bg:getContentSize().height*0.08))
	menu:addChild(yesItem)
	-- 注册回调
	yesItem:registerScriptTapHandler(yesItemCallFun)
	-- 字体
	local item_font = CCRenderLabel:create( GetLocalizeStringBy("key_1922") , g_sFontPangWa, 30, 1, ccc3( 0x00, 0x00, 0x00), type_stroke)
    item_font:setColor(ccc3(0xfe, 0xdb, 0x1c))
    item_font:setAnchorPoint(ccp(0.5,0.5))
    item_font:setPosition(ccp(yesItem:getContentSize().width*0.5,yesItem:getContentSize().height*0.5))
   	yesItem:addChild(item_font)

	-- 标题文字
	local title_font = CCRenderLabel:create( _titleText, g_sFontPangWa, 30, 1, ccc3( 0x00, 0x00, 0x00), type_stroke)
    title_font:setColor(ccc3(0xff, 0xc6, 0x00))
    title_font:setAnchorPoint(ccp(0.5,1))
    title_font:setPosition(ccp(reward_bg:getContentSize().width*0.5,reward_bg:getContentSize().height*0.9))
    reward_bg:addChild(title_font)

    -- 物品区域
    local itemBg = CCScale9Sprite:create("images/copy/fort/textbg.png")
	itemBg:setContentSize(CCSizeMake(480, itemBg_hight))
	itemBg:setAnchorPoint(ccp(0.5, 0.5))
	itemBg:setPosition(ccp(reward_bg:getContentSize().width*0.5,reward_bg:getContentSize().height*0.5))
	reward_bg:addChild(itemBg)

	-- 物品列表
	local myTableView = createItemTableView(itemArr_data)
	myTableView:setPosition(ccp(5, 5))
	itemBg:addChild(myTableView)

	--添加一个下边屏蔽layer 优先级为 tView_priority
	-- touch事件处理
	local pingbiLayer = CCLayer:create()
	-- local pingbiLayer = CCLayerColor:create(ccc4(255,0,0,255))
	local function cardLayerTouch(eventType, x, y)
		local rect = getSpriteScreenRect(pingbiLayer)
		if(rect:containsPoint(ccp(x,y))) then
			return true
		else
			return false
		end
	end
	local p_height = itemBg:getPositionY()-itemBg:getContentSize().height*0.5
	pingbiLayer:setContentSize(CCSizeMake(reward_bg:getContentSize().width,p_height))
	pingbiLayer:setTouchEnabled(true)
	pingbiLayer:registerScriptTouchHandler(cardLayerTouch,false,tView_priority,true)
	pingbiLayer:ignoreAnchorPointForPosition(false)
	pingbiLayer:setAnchorPoint(ccp(1,0))
	pingbiLayer:setPosition(reward_bg:getContentSize().width,0)
	reward_bg:addChild(pingbiLayer)

	-- 新手引导
	if(didLoadEvent) then
    	local seq = CCSequence:createWithTwoActions(CCDelayTime:create(0.3),CCCallFunc:create(function ( ... )
			didLoadEvent()
		end))
		reward_bg:runAction(seq)
    end
    return reward_bg
end

-- 创建物品列表
-- 参数 物品的列表
function createItemTableView( itemArr_data )
	local itemData = itemArr_data or {}
	local cellSize = CCSizeMake(120, 140)
	for k,v in pairs(itemData)do
		if(v.type=="book_num")then
			UserModel.addBookNum(v.num)
		end
		if(v.type=="silver")then
			UserModel.addSilverNumber(v.num)
		end
		if(v.type=="gold")then
			UserModel.addGoldNumber(v.num)
		end
	end
	local h = LuaEventHandler:create(function(fn, table, a1, a2) 	--创建
		local r
		if fn == "cellSize" then
			r = cellSize
		elseif fn == "cellAtIndex" then
			a2 = CCTableViewCell:create()
			-- for i=1,#itemData do
				if(itemData[a1+1] ~= nil)then
					local item_sprite = ItemUtil.createGoodsIcon(itemData[a1+1])
						  item_sprite:setAnchorPoint(ccp(0.5,1))
						  item_sprite:setPosition(ccp(60,120))
					a2:addChild(item_sprite)
				end
			-- end
			r = a2
		elseif fn == "numberOfCells" then
			r = #itemData
		elseif fn == "cellTouched" then
			
		elseif (fn == "scroll") then
			
		end
		return r
	end)
	local pageNum = math.ceil(#itemData/4)
	local goodTableView = LuaTableView:createWithHandler(h, CCSizeMake(470, tableView_hight))
	goodTableView:setBounceable(true)
	goodTableView:setTouchPriority(tView_priority)
	-- 左右滑动
	goodTableView:setDirection(kCCScrollViewDirectionHorizontal)
	goodTableView:setVerticalFillOrder(kCCTableViewFillTopDown)

	return goodTableView
end

-- touch事件处理
function cardLayerTouch(eventType, x, y)
    return true   
end


-- 确定按钮回调
function yesItemCallFun( ... )
	-- 音效
	require "script/audio/AudioUtil"
	AudioUtil.playEffect("audio/effect/guanbi.mp3")
	if(_bgLayer ~= nil)then
		_bgLayer:removeFromParentAndCleanup(true)
		_bgLayer = nil
	end
	-- 如果有后续回调则调用
	if(otherCallFun ~= nil)then
		otherCallFun( _callFunArgs )
	end
	require "script/battle/BattleLayer"
    BattleLayer.closeLayer()
    -- GuildBossCopyLayer.freshBoss()
end

function closeAction( ... )
	-- body
	require "script/audio/AudioUtil"
	AudioUtil.playEffect("audio/effect/guanbi.mp3")
	if(_bgLayer ~= nil)then
		_bgLayer:removeFromParentAndCleanup(true)
		_bgLayer = nil
	end
end

--[[
	@des:	得到确定按钮
]]
function getEnterButton( ... )
	return yesItem
end































