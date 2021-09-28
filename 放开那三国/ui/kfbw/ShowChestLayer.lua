-- FileName: ShowChestLayer.lua 
-- Author: yangrui
-- Date: 15-10-08
-- Purpose: function description of module 

module("ShowChestLayer", package.seeall)

require "script/ui/item/ItemUtil"

local _bgLayer            = nil
local _chestId            = nil  -- 宝箱id
local _chestState         = nil  -- 宝箱的状态
local _chestNeedWinTimes  = nil  -- 宝箱所需胜利场数次数
local _chestData          = nil  -- 宝箱奖励信息
local _rewardBtn          = nil  -- 领奖按钮
local _rewardTab          = nil  -- 奖励表
local _needRefreshCallFun = nil  -- 需要刷新回调

function init()
	_bgLayer            = nil
	_chestId            = nil  -- 宝箱id
	_chestState         = nil  -- 宝箱的状态
	_chestNeedWinTimes  = nil  -- 宝箱所需胜利场数次数
	_chestData          = nil  -- 宝箱奖励信息
	_rewardBtn          = nil  -- 领奖按钮
	_rewardTab          = nil  -- 奖励表
	_needRefreshCallFun = nil  -- 需要刷新回调
end

--[[
	@des    : touch事件处理
	@para   : 
	@return : 
--]]
function cardLayerTouch( eventType, x, y )
    return true
end

--[[
	@des    : 关闭按钮fangfa
	@para   : 
	@return : 
--]]
function closeButtonFunc( ... )
	if _bgLayer ~= nil then
		_bgLayer:removeFromParentAndCleanup(true)
		_bgLayer = nil
	end
end

--[[
	@des    : 关闭按钮回调
	@para   : 
	@return : 
--]]
function closeButtonCallback( tag, sender )
	print("closeButtonCallback")
    -- audio effect
    AudioUtil.playEffect("audio/effect/guanbi.mp3")
    closeButtonFunc()
end

--[[
	@des    : 宝箱处理
	@para   : 
	@return : 
--]]
function chestRewardFunc()
 	-- 关闭按钮
 	closeButtonCallback()
    -- 刷新箱子按钮
    if _needRefreshCallFun ~= nil then
    	_needRefreshCallFun(_chestId)
    end
end

--[[
	@des    : 领奖按钮回调
	@para   : 
	@return : 
--]]
function rewardBtnFunc( tag, itemBtn )
	-- 判断物品背包
	if ( ItemUtil.isBagFull() == true ) then
 		closeButtonCallback()
		return
	end
	-- 判断武将背包
    if HeroPublicUI.showHeroIsLimitedUI() then
 		closeButtonCallback()
    	return
    end
	-- 发送请求
	local winTimes = KuafuData.getNeedWinTimes(tag)
	KuafuController.getPrize(winTimes,_rewardTab)  -- 传入胜利次数
end

--[[
	@des    : 创建奖励物品tableView
	@para   : 
	@return : 
--]]
function createTableView( ... )
	_rewardTab = ItemUtil.getItemsDataByStr(_chestData)
 	local cellSize = CCSizeMake(116,140)
	local h = LuaEventHandler:create(function( fn, table, a1, a2 )
		local r
		if fn == "cellSize" then
			r = cellSize
		elseif fn == "cellAtIndex" then
        	a2 = ItemUtil.createGoodListCell(_rewardTab[a1+1],-425,1002,-425)
			r = a2
		elseif fn == "numberOfCells" then
			local num = #_rewardTab
			r = num
		elseif fn == "cellTouched" then
		elseif fn == "scroll" then
		end
		return r
	end)
	local goodTableView = LuaTableView:createWithHandler(h,CCSizeMake(470,140))
	goodTableView:setBounceable(true)
	if ( #_rewardTab > 4 ) then
		goodTableView:setTouchPriority(-426)
	end
	goodTableView:setDirection(kCCScrollViewDirectionHorizontal)
	goodTableView:setVerticalFillOrder(kCCTableViewFillTopDown)

	return goodTableView
end

--[[
	@des    : 创建UI
	@para   : 
	@return : 
--]]
function createUI( ... )
	-- 创建背景
	local boardBg = CCScale9Sprite:create(CCRectMake(100,80,10,20),"images/common/viewbg1.png")
    boardBg:setContentSize(CCSizeMake(524,328))
    boardBg:setAnchorPoint(ccp(0.5,0.5))
    boardBg:setPosition(ccp(g_winSize.width*0.5,g_winSize.height*0.5-24))
    _bgLayer:addChild(boardBg)
    -- 适配
    setAdaptNode(boardBg)
	local bgSize = boardBg:getContentSize()
    -- 标题背景
    local titlePanel = CCSprite:create("images/common/viewtitle1.png")
	titlePanel:setAnchorPoint(ccp(0.5,0.5))
	titlePanel:setPosition(ccp(bgSize.width/2,bgSize.height-6.6 ))
	boardBg:addChild(titlePanel)
	-- 标题文字
	local titleLabel = CCRenderLabel:create(GetLocalizeStringBy("yr_2009"),g_sFontPangWa,33,1,ccc3(0x00,0x00,0x00),type_stroke)
	titleLabel:setColor(ccc3(0xff,0xe4,0x00))
	titleLabel:setAnchorPoint(ccp(0.5,0.5))
	titleLabel:setPosition(ccp(titlePanel:getContentSize().width*0.5,titlePanel:getContentSize().height*0.5))
	titlePanel:addChild(titleLabel)
	-- 关闭按钮Bar
	local closerewardMenuBar = CCMenu:create()
    closerewardMenuBar:setTouchPriority(-425)
	closerewardMenuBar:setAnchorPoint(ccp(0,0))
	closerewardMenuBar:setPosition(ccp(0,0))
	boardBg:addChild(closerewardMenuBar,3)
	-- 关闭按钮
	local closeButton = CCMenuItemImage:create("images/common/btn_close_n.png","images/common/btn_close_h.png")
	closeButton:setAnchorPoint(ccp(0.5, 0.5))
	closeButton:setPosition(ccp(bgSize.width * 0.955, bgSize.height*0.975 ))
	closeButton:registerScriptTapHandler(closeButtonCallback)
	closerewardMenuBar:addChild(closeButton)
    -- 领取条件Label
   	local conditionFont = CCRenderLabel:create(GetLocalizeStringBy("yr_2010",_chestNeedWinTimes),g_sFontName,30,1,ccc3(0x00,0x00,0x00),type_stroke)
	conditionFont:setColor(ccc3(0xff,0xe4,0x00))
	conditionFont:setAnchorPoint(ccp(0.5,1))
	conditionFont:setPosition(ccp(bgSize.width*0.5,bgSize.height-42))
	boardBg:addChild(conditionFont)
	--物品奖励背景
	local fullRect = CCRectMake(0,0,61,47)
	local insetRect = CCRectMake(10,10,41,27)
	local itemBg = CCScale9Sprite:create("images/copy/fort/textbg.png",fullRect,insetRect)
	itemBg:setPreferredSize(CCSizeMake(480,150))
	itemBg:setAnchorPoint(ccp(0.5,0.5))
	itemBg:setPosition(ccp(bgSize.width*0.5,bgSize.height*0.5))
	boardBg:addChild(itemBg)
	-- 物品tableView
	local myTableView = createTableView()
	myTableView:setPosition(ccp(5,8))
	itemBg:addChild(myTableView)
    -- 按钮Bar
    local rewardMenuBar = CCMenu:create()
    rewardMenuBar:setPosition(ccp(0,0))
    rewardMenuBar:setTouchPriority(-425)
    boardBg:addChild(rewardMenuBar)
	-- 是否能领取的按钮
	local _rewardBtn = nil
	if ( _chestState == 1 ) then
		_rewardBtn = BTGraySprite:create("images/copy/reward/btn_reward_n.png")
		_rewardBtn:setAnchorPoint(ccp(0.5,0.5))
	    _rewardBtn:setPosition(ccp(bgSize.width/2,bgSize.height*0.165))
		boardBg:addChild(_rewardBtn)
	elseif ( _chestState == 2 ) then
		-- 领取奖励
		_rewardBtn = CCMenuItemImage:create("images/copy/reward/btn_reward_n.png","images/copy/reward/btn_reward_h.png")
		_rewardBtn:setAnchorPoint(ccp(0.5,0.5))
	    _rewardBtn:setPosition(ccp(bgSize.width/2,bgSize.height*0.165))
	    _rewardBtn:registerScriptTapHandler(rewardBtnFunc)
		rewardMenuBar:addChild(_rewardBtn,1,tonumber(_chestId))
	elseif ( _chestState == 3 ) then
		_rewardBtn = CCSprite:create("images/copy/reward/received.png")
		_rewardBtn:setAnchorPoint(ccp(0.5,0.5))
	    _rewardBtn:setPosition(ccp(bgSize.width/2,bgSize.height*0.165))
		boardBg:addChild(_rewardBtn)
	end
end

--[[
	@des    : 创建显示奖励Layer
	@para   : 
	@return : 
--]]
function showChestRewardLayer( pChestId, callFun )
	-- 初始化
	init()

	_chestId = pChestId
	_needRefreshCallFun = callFun
	_chestState,_chestNeedWinTimes = KuafuData.getChestStateInfoById(pChestId)
	_chestData = KuafuData.getWinRewardById(pChestId)

	_bgLayer = CCLayerColor:create(ccc4(11,11,11,200))
    _bgLayer:setTouchEnabled(true)
    _bgLayer:registerScriptTouchHandler(cardLayerTouch,false,-425,true)

    local scene = CCDirector:sharedDirector():getRunningScene()
    scene:addChild(_bgLayer)
    -- 创建UI
	createUI()
end
