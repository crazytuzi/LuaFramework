-- FileName: ShowBoxLayer.lua 
-- Author: Li Cong 
-- Date: 14-3-19 
-- Purpose: function description of module 


module("ShowBoxLayer", package.seeall)

require "script/ui/everyday/EverydayData"
require "script/ui/everyday/EverydayService"
require "script/ui/item/ItemUtil"



local _bgLayer 				= nil
local _boxId 				= nil			-- 箱子奖励id
local _box_status 			= nil			-- 箱子的状态
local _boxNeedScore 		= nil
local rewardBtn				= nil
local backGround 			= nil
local _rewardTab 			= nil 
local needRefreshCallFun 	= nil
local _rewardId 			= nil
function init()
	_bgLayer 				= nil
	_boxId 					= nil
	_box_status 			= nil
	_boxNeedScore 			= nil
	rewardBtn				= nil
	backGround 				= nil
	_rewardTab 				= nil 
	needRefreshCallFun 		= nil
	_rewardId 				= nil
end

-- touch事件处理
local function cardLayerTouch(eventType, x, y)
   
    return true
    
end

-- 关闭按钮回调
function closeButtonCallback( tag, sender )
    -- 音效
    require "script/audio/AudioUtil"
    AudioUtil.playEffect("audio/effect/guanbi.mp3")
	-- print("closeButtonCallback")
	if(_bgLayer)then
		_bgLayer:removeFromParentAndCleanup(true)
		_bgLayer = nil
	end
end

-- 请求回来 操作函数
function getBoxRewardCallFun()
 	-- 关闭自己
 	closeButtonCallback()
 	-- 修改本地数据 加奖励
 	ItemUtil.addRewardByTable(_rewardTab)
 	-- 展现领取奖励列表
 	require "script/ui/item/ReceiveReward"
    ReceiveReward.showRewardWindow( _rewardTab, nil , 1001, -425 )
    -- 刷新箱子按钮
    if(needRefreshCallFun)then
    	needRefreshCallFun( _boxId )
    end
end

-- 按钮响应
function menuAction( tag, itemBtn )
	-- 判断物品背包
	if(ItemUtil.isBagFull() == true )then
		-- 关闭自己
 		closeButtonCallback()
 		-- 关闭每日任务
 		EverydayLayer.closeButtonCallback()
		return
	end
	-- 判断武将背包
    if HeroPublicUI.showHeroIsLimitedUI() then
    	-- 关闭自己
 		closeButtonCallback()
 		-- 关闭每日任务
 		EverydayLayer.closeButtonCallback()
    	return
    end
	-- 发送请求
	EverydayService.getPrize(_rewardId,getBoxRewardCallFun)
end

function initShowBoxRewardLayer(  )
	-- 创建背景
	backGround = CCScale9Sprite:create(CCRectMake(100, 80, 10, 20),"images/common/viewbg1.png")
    backGround:setContentSize(CCSizeMake(524, 438))
    backGround:setAnchorPoint(ccp(0.5,0.5))
    backGround:setPosition(ccp(g_winSize.width*0.5,g_winSize.height*0.5 - 24))
    _bgLayer:addChild(backGround)
    -- 适配
    setAdaptNode(backGround)
	local bgSize = backGround:getContentSize()
    -- 标题
    local titlePanel = CCSprite:create("images/common/viewtitle1.png")
	titlePanel:setAnchorPoint(ccp(0.5, 0.5))
	titlePanel:setPosition(ccp(bgSize.width/2, bgSize.height-6.6 ))
	backGround:addChild(titlePanel)
	local titleLabel = CCLabelTTF:create(GetLocalizeStringBy("key_2995"), g_sFontPangWa, 33)
	titleLabel:setColor(ccc3(0xff, 0xe4, 0x00))
	titleLabel:setAnchorPoint(ccp(0.5,0.5))
	titleLabel:setPosition(ccp(titlePanel:getContentSize().width*0.5, titlePanel:getContentSize().height*0.5))
	titlePanel:addChild(titleLabel)

	-- 关闭按钮
	local menu = CCMenu:create()
    menu:setTouchPriority(-425)
	menu:setPosition(ccp(0, 0))
	menu:setAnchorPoint(ccp(0, 0))
	backGround:addChild(menu,3)
	local closeButton = CCMenuItemImage:create("images/common/btn_close_n.png", "images/common/btn_close_h.png")
	closeButton:setAnchorPoint(ccp(0.5, 0.5))
	closeButton:setPosition(ccp(bgSize.width * 0.955, bgSize.height*0.975 ))
	closeButton:registerScriptTapHandler(closeButtonCallback)
	menu:addChild(closeButton)

    -- 领取条件
   	local condition_font = CCRenderLabel:create(GetLocalizeStringBy("key_1636") .. _boxNeedScore .. GetLocalizeStringBy("key_3383"), g_sFontName,30,1,ccc3(0x00,0x00,0x00),type_stroke)
	condition_font:setColor(ccc3(0xff, 0xe4, 0x00))
	condition_font:setAnchorPoint(ccp(0.5,1))
	condition_font:setPosition(ccp(bgSize.width*0.5, bgSize.height-80))
	backGround:addChild(condition_font)

	--物品奖励背景
	local fullRect_i = CCRectMake(0,0,61,47)
	local insetRect_i = CCRectMake(10,10,41,27)
	local itemBg = CCScale9Sprite:create("images/copy/fort/textbg.png", fullRect_i, insetRect_i)
	itemBg:setPreferredSize(CCSizeMake(480, 150))
	itemBg:setAnchorPoint(ccp(0.5, 0.5))
	itemBg:setPosition(ccp(bgSize.width*0.5, bgSize.height*0.5))
	backGround:addChild(itemBg)
	-- 物品tableView
	local myTableView = createTableView()
	myTableView:setPosition(ccp(5, 5))
	itemBg:addChild(myTableView)

    -- 按钮Bar
    local menuBar = CCMenu:create()
    menuBar:setPosition(ccp(0,0))
    menuBar:setTouchPriority(-425)
    backGround:addChild(menuBar)

	-- 是否能领取的按钮
	local rewardBtn = nil
	if(_box_status == 1) then
		rewardBtn = BTGraySprite:create("images/copy/reward/btn_reward_n.png")
		rewardBtn:setAnchorPoint(ccp(0.5, 0.5))
	    rewardBtn:setPosition(ccp(bgSize.width/2, bgSize.height*0.2))
		backGround:addChild(rewardBtn)
	elseif(_box_status == 2) then
		-- 领取奖励
		rewardBtn = CCMenuItemImage:create("images/copy/reward/btn_reward_n.png", "images/copy/reward/btn_reward_h.png")
		rewardBtn:setAnchorPoint(ccp(0.5, 0.5))
	    rewardBtn:setPosition(ccp(bgSize.width/2, bgSize.height*0.2))
	    rewardBtn:registerScriptTapHandler(menuAction)
		menuBar:addChild(rewardBtn,1,tonumber(_boxId))
	elseif(_box_status == 3) then
		rewardBtn = CCSprite:create("images/copy/reward/received.png")
		rewardBtn:setAnchorPoint(ccp(0.5, 0.5))
	    rewardBtn:setPosition(ccp(bgSize.width/2, bgSize.height*0.2))
		backGround:addChild(rewardBtn)
	end
end 


-- 创建奖励物品tableView
function createTableView( ... )
	_rewardTab = ItemUtil.getItemsDataByStr(_box_dbData.reward)
 	local cellSize = CCSizeMake(116, 140)
	local h = LuaEventHandler:create(function(fn, table, a1, a2) 	--创建
		local r
		if fn == "cellSize" then
			r = cellSize
		elseif fn == "cellAtIndex" then
           a2 = ItemUtil.createGoodListCell(_rewardTab[a1+1],-425,1002,-425)  
			r = a2
		elseif fn == "numberOfCells" then
			local num = #_rewardTab
			r = num
			print("num is : ", num)
		elseif fn == "cellTouched" then
			
		elseif (fn == "scroll") then
			
		end
		return r
	end)

	local goodTableView = LuaTableView:createWithHandler(h, CCSizeMake(470, 140))
	goodTableView:setBounceable(true)
	if(#_rewardTab> 4) then
		goodTableView:setTouchPriority(-426)
	end
	goodTableView:setDirection(kCCScrollViewDirectionHorizontal)
	goodTableView:setVerticalFillOrder(kCCTableViewFillTopDown)

	return goodTableView
end 


-- 显示奖励
function showBoxRewardLayer( boxId, callFun )
	init()
	_boxId = boxId
	needRefreshCallFun = callFun
	_box_status,_boxNeedScore = EverydayData.getBoxStateInfoById(boxId)
	_box_dbData,_rewardId = EverydayData.getBoxRewardDataByBoxId(boxId)

	_bgLayer = CCLayerColor:create(ccc4(11,11,11,200))
    _bgLayer:setTouchEnabled(true)
    _bgLayer:registerScriptTouchHandler(cardLayerTouch,false,-425,true)
    local scene = CCDirector:sharedDirector():getRunningScene()
    scene:addChild(_bgLayer,1001,1)

    -- 初始化显示界面
	initShowBoxRewardLayer()
		
end















