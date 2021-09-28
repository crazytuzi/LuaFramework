-- Filename：	MoonMultiplyFightResultLayer.lua
-- Author：		bzx
-- Date：		2016-06-06
-- Purpose：		精英副本的信息

module ("MoonMultiplyFightResultLayer", package.seeall)


require "script/utils/LuaUtil"
require "script/ui/item/ItemSprite"
require "script/ui/item/ItemUtil"
require "script/model/user/UserModel"
require "script/ui/tip/AnimationTip"
require "script/ui/moon/MoonMultiplyFightResultCell.lua"


local _bgLayer 			= nil
local _bgSprite 		= nil
local _fortName 		= nil
local _rewardBgSprite 	= nil
local _rewardList 		= {}
local _myTableView 		= nil
local _cellSizeArr 		= {}
local _touchPriority 	= nil
function init()
	_bgLayer 		= nil
	_bgSprite 		= nil
	_fortName 		= nil
	_rewardBgSprite = nil
	_rewardList 	= {}
	_myTableView 	= nil
	_cellSizeArr 	= {}
	_touchPriority 	= nil
end


--[[
 @desc	 处理touches事件
 @para 	 string event
 @return 
--]]
local function onTouchesHandler( eventType, x, y )
	
	if (eventType == "began") then
	    return true
    elseif (eventType == "moved") then
    
    else
        print("end")
	end
end

--[[
 @desc	 回调onEnter和onExit时间
 @para 	 string event
 @return void
 --]]
local function onNodeEvent( event )
	if (event == "enter") then
		_bgLayer:registerScriptTouchHandler(onTouchesHandler, false, _touchPriority, true)
		_bgLayer:setTouchEnabled(true)
	elseif (event == "exit") then
		_bgLayer:unregisterScriptTouchHandler()
	end
end

-- 关闭
function closeAction( tag, itembtn )
	_bgLayer:removeFromParentAndCleanup(true)
	_bgLayer = nil
end 

-- 奖励的TableView
local function createTableView()
	-- local myScale = _bgLayer:getContentSize().width/cellBg:getContentSize().width/_bgLayer:getElementScale()
   local testIndex = 0
	local h = LuaEventHandler:create(function(fn, table, a1, a2) 	--创建
		local r
		if fn == "cellSize" then
			-- 兼容问题
			if(Platform.getOS() == "wp")then
                testIndex = a1+1
            else
                testIndex = testIndex + 1
            end

			local cellSize = _cellSizeArr[testIndex]
			r =  cellSize -- CCSizeMake(cellSize.width*myScale, cellSize.height*myScale)
		elseif fn == "cellAtIndex" then

            a2 = MoonMultiplyFightResultCell.createCell(_rewardList[a1 + 1], _cellSizeArr[a1 + 1], #_rewardList -a1, _touchPriority - 1)
            
			r = a2
		elseif fn == "numberOfCells" then
			r =  #_rewardList
		elseif fn == "cellTouched" then
		elseif (fn == "scroll") then
			
		end
		return r
	end)
	_myTableView = LuaTableView:createWithHandler(h, CCSizeMake(465, 520))
    _myTableView:setAnchorPoint(ccp(0,0))
	_myTableView:setBounceable(true)
	_myTableView:setPosition(ccp(3, 5))
	_myTableView:setTouchPriority(_touchPriority - 1)
	-- _myTableView:setVerticalFillOrder(kCCTableViewFillTopDown)
	_rewardBgSprite:addChild(_myTableView)
end


-- 创建背景
local function createBgSprite()
	-- 背景
	_bgSprite = CCScale9Sprite:create("images/common/viewbg1.png")
	_bgSprite:setContentSize(CCSizeMake(520, 700))
	_bgSprite:setAnchorPoint(ccp(0.5,0.5))
	_bgSprite:setScale(MainScene.elementScale)
	_bgSprite:setPosition(ccp(_bgLayer:getContentSize().width*0.5, _bgLayer:getContentSize().height*0.4))
	_bgLayer:addChild(_bgSprite)

	-- 头部
	local topSprite = CCSprite:create("images/common/v_top.png")
	topSprite:setAnchorPoint(ccp(0.5, 0))
	topSprite:setPosition(ccp(_bgSprite:getContentSize().width*0.5, _bgSprite:getContentSize().height - 110))
	_bgSprite:addChild(topSprite)
	-- 连战结算
	local titleSprite = CCSprite:create("images/copy/sweep.png")
	titleSprite:setAnchorPoint(ccp(0.5, 0.5))
	titleSprite:setPosition(ccp(topSprite:getContentSize().width*0.5, 130))
	topSprite:addChild(titleSprite)

	local backMenuBar = CCMenu:create()
	backMenuBar:setPosition(ccp(0,0))
	_bgSprite:addChild(backMenuBar)
	backMenuBar:setTouchPriority(_touchPriority - 1)
	-- 后退
	local backBtn = LuaCC.create9ScaleMenuItem("images/common/btn/btn_green_n.png","images/common/btn/btn_green_h.png",CCSizeMake(200, 71),GetLocalizeStringBy("key_1985"),ccc3(0xfe, 0xdb, 0x1c),35,g_sFontPangWa,2, ccc3(0x00, 0x00, 0x00))
	backBtn:setAnchorPoint(ccp(0.5, 0.5))
	backBtn:setPosition(ccp(_bgSprite:getContentSize().width*0.5, 55))
	backBtn:registerScriptTapHandler(closeAction)
	backMenuBar:addChild(backBtn)

	-- 据点名称
	local baseNameLabel = CCRenderLabel:create(_fortName, g_sFontPangWa, 33, 2, ccc3( 0x00, 0x00, 0x00), type_stroke)
	baseNameLabel:setAnchorPoint(ccp(0.5,1))
    baseNameLabel:setColor(ccc3( 0xff, 0xe4, 0x00))
    baseNameLabel:setPosition(ccp( _bgSprite:getContentSize().width*0.5, _bgSprite:getContentSize().height - 25) )
    _bgSprite:addChild(baseNameLabel)

    _rewardBgSprite = CCScale9Sprite:create("images/common/bg/bg_ng_attr.png")
	_rewardBgSprite:setContentSize(CCSizeMake(470, 530))
	_rewardBgSprite:setAnchorPoint(ccp(0.5, 1))
	
	_rewardBgSprite:setPosition(ccp(_bgSprite:getContentSize().width*0.5, 625))
	_bgSprite:addChild(_rewardBgSprite)

end 

-- 处理数据
local function handleData()
	_cellSizeArr 	= {}
	for k, tempReward in pairs(_rewardList) do
		local item_counts = table.count(tempReward)
		local rows =  math.ceil(item_counts/3)
		local cellSize = CCSizeMake(465, 100 + rows * 125)
		table.insert(_cellSizeArr, cellSize)
	end
end

-- 创建
function createLayer(fortName, rewardList, p_touchPriority)
	init()
	_fortName 		= fortName
	_rewardList 	= rewardList
	_touchPriority 	= p_touchPriority or -888

	handleData()
	_bgLayer = CCLayerColor:create(ccc4(0,0,0,155))
	_bgLayer:registerScriptHandler(onNodeEvent)

	createBgSprite()
	-- 奖励的TableView
	createTableView()

	return _bgLayer

end

function show(fortName, rewardList)
	local layer = createLayer(fortName, rewardList)
	local runningScene = CCDirector:sharedDirector():getRunningScene()
    runningScene:addChild(layer, 2001)
end


