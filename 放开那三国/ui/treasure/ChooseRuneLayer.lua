-- FileName: ChooseRuneLayer.lua 
-- Author: licong 
-- Date: 15/5/4 
-- Purpose: 选择镶嵌符印界面 


module("ChooseRuneLayer", package.seeall)

require "script/ui/treasure/TreasureData"
require "script/ui/treasure/TreasureRuneService"
require "script/ui/bag/RuneBagCell"
require "script/ui/bag/RuneData"
require "script/ui/tip/AnimationTip"

local _curTreasureItemId				= nil
local _callBack 				= nil
local _layer_priority			= nil
local _zOrderNum 				= nil
local _bgLayer 					= nil
local _bgSprite 				= nil
local _isMenuVisible      		= nil
local _isAvatarVisible    		= nil
local _isBulletinVisible  		= nil
local _topBg 					= nil
local _bulletinHeight 			= nil
local _listData 				= nil
local _curIndex 				= nil

--[[
	@des 	: 初始化
--]]
function init( ... )
	_curTreasureItemId					= nil
	_callBack 					= nil
	_layer_priority				= nil
 	_zOrderNum 					= nil
	_bgLayer 					= nil
	_bgSprite 					= nil
	_isMenuVisible      		= nil
	_isAvatarVisible    		= nil
	_isBulletinVisible  		= nil
	_topBg 						= nil
	_bulletinHeight 			= nil
	_listData 					= nil
	_curIndex 					= nil
end

--[[
	@des 	: 初始化数据
--]]
function initData( ... )
	-- 得到选择列表
	_listData = TreasureData.getChooseRuneData(_curTreasureItemId,_curIndex)
end

--[[
	@des 	:touch事件处理
	@param 	:
	@return :
--]]
local function layerTouch(eventType, x, y)
    return true
end

--[[
	@des 	:回调onEnter和onExit事件
	@param 	:
	@return :
--]]
function onNodeEvent( event )
	if (event == "enter") then
		_bgLayer:registerScriptTouchHandler(layerTouch,false,_layer_priority,true)
		_bgLayer:setTouchEnabled(true)
	elseif (event == "exit") then
	end
end

--[[
	@des 	: 关闭回调
--]]
function closeAction( ... )
	require "script/audio/AudioUtil"
	AudioUtil.playEffect("audio/effect/guanbi.mp3")
	if(_bgLayer ~= nil)then
		_bgLayer:removeFromParentAndCleanup(true)
		_bgLayer=nil
	end
	MainScene.setMainSceneViewsVisible(_isMenuVisible,_isAvatarVisible,_isBulletinVisible)
end

--[[
	@des 	: 镶嵌回调
--]]
function changeAction( tag, itemBtn )
	print("changeAction tag==>",tag)
	require "script/audio/AudioUtil"
	AudioUtil.playEffect("audio/effect/zhujiemian.mp3")

	-- 符印信息
	local runeItemInfo = RuneData.getRuneInfoByItemId( tag )
	-- 当前宝物信息
	local curItemInfo = ItemUtil.getItemByItemId(_curTreasureItemId)
	local isOnHero = false
	local hid = nil
	if(curItemInfo == nil)then
		curItemInfo = ItemUtil.getTreasInfoFromHeroByItemId(_curTreasureItemId)
		isOnHero = true
		hid = curItemInfo.hid
	end

	-- 当前位置有符印 若镶嵌已镶嵌过符印 要判断背包
	if( not table.isEmpty(curItemInfo.va_item_text.treasureInlay[tostring(_curIndex)]) and runeItemInfo.treasureItemId ~= nil )then
		-- 符印背包满了
		if( ItemUtil.isRuneBagFull(true) == true )then
			return
		end
	end
	local nextCallBack = function ( ... )
	
		AnimationTip.showTip(GetLocalizeStringBy("lic_1563"))

		if(isOnHero)then
			-- 修改英雄身上的缓存数据
			local temp = table.hcopy(runeItemInfo, {})
			HeroModel.changeHeroTreasureRuneBy( hid,_curTreasureItemId, temp, _curIndex)
		else
			-- 修改当前宝物缓存数据
			local temp = table.hcopy(runeItemInfo, {})
			DataCache.changeTreasureRuneInBag( _curTreasureItemId, temp, _curIndex)
		end
		-- 修改原来宝物镶嵌属性
		if( runeItemInfo.treasureItemId ~= nil )then
			local itemId = runeItemInfo.treasureItemId
			local itemInfo = ItemUtil.getItemByItemId(itemId)
			local isOnHero1 = false
			local hid1 = nil
			local pos = runeItemInfo.pos
			if(itemInfo == nil)then
				itemInfo = ItemUtil.getTreasInfoFromHeroByItemId(itemId)
				isOnHero1 = true
				hid1 = itemInfo.hid
			end
			if(isOnHero1)then
				-- 修改英雄身上的缓存数据
				HeroModel.changeHeroTreasureRuneBy( hid1,itemId, nil, pos)
			else
				-- 修改当前宝物缓存数据
				DataCache.changeTreasureRuneInBag( itemId, nil, pos)
			end
		end
		-- 关闭界面
		closeAction()
		-- 刷新方法
		if(_callBack ~= nil)then
			_callBack(_curIndex)
		end
	end
	-- 发请求
	TreasureRuneService.inlay(_curTreasureItemId, tag, _curIndex, runeItemInfo.treasureItemId, nextCallBack )
end

--[[
	@des 	: 创建上边ui
--]]
function createTopUI( ... )
	-- 标题
	_topBg = CCSprite:create("images/formation/changeofficer/topbar.png")
	_topBg:setAnchorPoint(ccp(0.5, 1))
	_topBg:setPosition(ccp(_bgLayer:getContentSize().width*0.5, _bgLayer:getContentSize().height))
	_bgLayer:addChild(_topBg)
	_topBg:setScale(g_fScaleX)

	-- 标题
	local titleSprite = CCSprite:create("images/common/rune_title.png")
	titleSprite:setAnchorPoint(ccp(0.5, 0.5))
	titleSprite:setPosition(ccp(_topBg:getContentSize().width * 0.2, _topBg:getContentSize().height*0.6))
	_topBg:addChild(titleSprite)

	-- 返回按钮
	local topMenuBar = CCMenu:create()
	topMenuBar:setPosition(ccp(0,0))
	_topBg:addChild(topMenuBar)
	topMenuBar:setTouchPriority(_layer_priority-4)
	local backBtn = LuaMenuItem.createItemImage("images/common/close_btn_n.png",  "images/common/close_btn_h.png", closeAction)
	backBtn:setAnchorPoint(ccp(0.5, 0.5))
	backBtn:setPosition(ccp(_topBg:getContentSize().width*0.85, _topBg:getContentSize().height*0.6))
	topMenuBar:addChild(backBtn)
end

--[[
	@des 	: 创建下边ui
--]]
function createBottomUI( ... )
	_bottomBg = CCSprite:create("images/common/sell_bottom.png")
	_bottomBg:setAnchorPoint(ccp(0.5, 0))
	_bottomBg:setPosition(ccp(_bgLayer:getContentSize().width*0.5,0))
	_bgLayer:addChild(_bottomBg, 10)
	_bottomBg:setScale(g_fScaleX)
end

--[[
	@des 	: 创建选择列表
--]]
function createSelectTableView( ... )
	local cellSize = CCSizeMake(635,170)
	cellSize.width = cellSize.width * g_fScaleX 
	cellSize.height = cellSize.height * g_fScaleX

    local nHeightOfBottom = (_bottomBg:getContentSize().height-12)*g_fScaleX
	local nHeightOfTitle = (_topBg:getContentSize().height-16)*g_fScaleX
	local _scrollview_height = _bgLayer:getContentSize().height - nHeightOfBottom - nHeightOfTitle

	local visiableCellNum = math.floor(_scrollview_height/(cellSize.height*g_fScaleX)) --计算可视的有几个cell
	
	local h = LuaEventHandler:create(function(fn, table, a1, a2) 	--创建
		local r
		if fn == "cellSize" then
			r = CCSizeMake(cellSize.width, cellSize.height)
		elseif fn == "cellAtIndex" then
            a2 = RuneBagCell.createCell( _listData[a1 + 1], nil, false, false, nil, true  )
            a2:setScale(g_fScaleX)
            local cellMenuBar = CCMenu:create()
			cellMenuBar:setPosition(ccp(0,0))
			cellMenuBar:setTouchPriority(_layer_priority-2)
			a2:addChild(cellMenuBar,10)

			-- 镶嵌按钮
			local xiangBtn = LuaCC.create9ScaleMenuItem("images/common/btn/green01_n.png", "images/common/btn/green01_h.png",CCSizeMake(134, 64), GetLocalizeStringBy("lic_1543"),ccc3(0xfe, 0xdb, 0x1c),30,g_sFontPangWa,1, ccc3(0x00, 0x00, 0x00))
			xiangBtn:setAnchorPoint(ccp(0.5, 0.5))
			xiangBtn:setPosition(ccp(cellSize.width/g_fScaleX *0.85, cellSize.height/g_fScaleX*0.5))
			xiangBtn:registerScriptTapHandler(changeAction)
			cellMenuBar:addChild(xiangBtn, 1, tonumber(_listData[a1 + 1].item_id))
			r = a2
		elseif fn == "numberOfCells" then
			r = #_listData
		else
		end
		return r
	end)
	_listTableView = LuaTableView:createWithHandler(h, CCSizeMake(_bgLayer:getContentSize().width, _scrollview_height))
    _listTableView:setAnchorPoint(ccp(0,0))
	_listTableView:setBounceable(true)
	_listTableView:setTouchPriority(_layer_priority-3)
	_listTableView:setPosition(ccp(0,nHeightOfBottom))
	_bgLayer:addChild(_listTableView)
end


--[[
	@des 	: 初始化界面
--]]
function initLayer( ... )
	-- 创建上边ui
	createTopUI()
	-- 创建下边ui
	createBottomUI()
	-- 创建选择列表
	createSelectTableView()
end

--[[
	@des 	: 显示选择符印界面
	@param 	: p_curTreasureItemId 当前宝物itemId
	@param 	: p_index 	  当前符印位置
	@param 	: p_CallBack  镶嵌回调
	@param 	: p_layer_priority 界面优先级
	@param 	: p_zOrderNum 界面z轴
	@return :
--]]
function showChooseLayer( p_curTreasureItemId, p_index, p_CallBack, p_layer_priority, p_zOrderNum )
	print(" showChooseLayer p_curTreasureItemId==>",p_curTreasureItemId)
	print("p_index==>",p_index)
	print("p_CallBack==>",p_CallBack)
	print("p_layer_priority==>",p_layer_priority)
	print("p_zOrderNum==>",p_zOrderNum)

	-- 初始化变量
	init()

	-- 接收参数
	_curTreasureItemId = p_curTreasureItemId 
	_curIndex = p_index
	_callBack = p_CallBack
	_layer_priority = p_layer_priority or -600
	_zOrderNum = p_zOrderNum or 1100

	-- 菜单状态
	_isMenuVisible      = MainScene.isMenuVisible()
	_isAvatarVisible    = MainScene.isAvatarVisible()
	_isBulletinVisible  = MainScene.isBulletinVisible()

	MainScene.setMainSceneViewsVisible(false,false,true)

	_bulletinHeight = MainScene.getBulletFactSize()

	_bgLayer = CCLayer:create()
	_bgLayer:registerScriptHandler(onNodeEvent) 
    local scene = CCDirector:sharedDirector():getRunningScene()
    scene:addChild(_bgLayer,_zOrderNum,1)

    -- 大背景
    _bgSprite = CCSprite:create("images/main/module_bg.png")
    _bgSprite:setAnchorPoint(ccp(0.5,0.5))
    _bgSprite:setPosition(ccp(_bgLayer:getContentSize().width*0.5,_bgLayer:getContentSize().height*0.5))
    _bgLayer:addChild(_bgSprite)
    _bgSprite:setScale(g_fBgScaleRatio)

    -- 初始化数据
    initData()

    -- 初始化界面
    initLayer()
end
































