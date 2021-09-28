-- Filename: AlertCost.lua
-- Author: DJN
-- Date: 2014-12-15
-- Purpose: 资源追回确认花费界面

module("AlertCost", package.seeall)
require "script/audio/AudioUtil"
require "script/ui/item/ItemUtil"


local _bgLayer       --背景层
local _touchPriority --触摸优先级
local _ZOrder		 --Z轴值
local _count         -- 需要花费的数量
local _type          -- 需要花费的类型  金币/银币
local _goodIdInfo      -- 需要展示的奖励表
local _confirmCb     -- 得到确认并向网络请求后的回调函数

function init()
	
	_bgLayer = nil
	_touchPriority = nil
	_ZOrder		   = nil
	_count = nil
    _goodIdInfo = {}
    _type = nil
    _confirmCb = nil
end
----------------------------------------触摸事件函数
function onTouchesHandler(eventType,x,y)
	if eventType == "began" then
		print("onTouchesHandler,began")
	    return true
    elseif eventType == "moved" then
    	print("onTouchesHandler,moved")
    else
        print("onTouchesHandler,else")
	end
end

local function onNodeEvent(event)
	if event == "enter" then
		_bgLayer:registerScriptTouchHandler(onTouchesHandler,false,_touchPriority,true)
		_bgLayer:setTouchEnabled(true)
	elseif event == "exit" then
		_bgLayer:unregisterScriptTouchHandler()
	end
end
--[[
	@des 	:关闭按钮回调
	@param 	:
	@return :
--]]
function closeMenuCallBack()

	AudioUtil.playEffect("audio/effect/guanbi.mp3")
	--print("关闭按钮执行关闭")
    close()
end
--[[
	@des 	:关闭函数
	@param 	:
	@return :
--]]
function close( ... )
	_bgLayer:removeFromParentAndCleanup(true)
	_bgLayer = nil
end
--“确定”按钮回调
function confirmMenuCb( ... )
	AudioUtil.playEffect("audio/effect/zhujiemian.mp3")
	if(ItemUtil.isBagFull() == true )then
		 --背包满了
		 ReResourceLayer.closeLayer()
	else
		if(_type == "gold")then
			if (UserModel.getGoldNumber() >= _count) then
				ReResourceService.recoverByGold(_goodIdInfo,_confirmCb)
			else
				----------提示充值
				require "script/ui/tip/LackGoldTip"
				LackGoldTip.showTip(_touchPriority-50,_ZOrder+10)
			end
		elseif(_type == "silver")then
			if (UserModel.getSilverNumber() >= _count) then
			    ReResourceService.recoverBySilver(_goodIdInfo,_confirmCb)
			else
				----------提示银币不足
				require "script/ui/tip/AnimationTip"
				AnimationTip.showTip(GetLocalizeStringBy("djn_107"))
			end
		end
		
	end
	close()
end
---------------------------------------UI函数
--[[
	@des 	:创建背景
	@param 	:
	@return :
--]]
 function createBgUI()
	require "script/ui/main/MainScene"
	local bgSize = CCSizeMake(530,350)
	local bgScale = MainScene.elementScale
    
	--主黄色背景
	local bgSprite = CCScale9Sprite:create("images/common/viewbg1.png")
	bgSprite:setContentSize(CCSizeMake(bgSize.width,bgSize.height))
	bgSprite:setAnchorPoint(ccp(0.5,0.5))
	bgSprite:setPosition(_bgLayer:getContentSize().width*0.5,_bgLayer:getContentSize().height*0.5)
	bgSprite:setScale(bgScale)
	_bgLayer:addChild(bgSprite)

    local MenuBar = CCMenu:create()
	MenuBar:setPosition(ccp(0, 0))
	bgSprite:addChild(MenuBar)


	-- 关闭按钮
	local closeBtn = LuaMenuItem.createItemImage("images/common/btn_close_n.png", "images/common/btn_close_h.png" )
	closeBtn:setAnchorPoint(ccp(1, 0.5))
    closeBtn:setPosition(ccp(bgSprite:getContentSize().width*1.01, bgSprite:getContentSize().height*0.98))
    closeBtn:registerScriptTapHandler(closeMenuCallBack)
	MenuBar:addChild(closeBtn)
	MenuBar:setTouchPriority(_touchPriority-10)

    -- 确定按钮
	local confirmItem = LuaCC.create9ScaleMenuItem("images/star/intimate/btn_blue_n.png","images/star/intimate/btn_blue_n.png",CCSizeMake(140,70),GetLocalizeStringBy("key_8022"),ccc3(255,222,0))
    confirmItem:setAnchorPoint(ccp(0.5, 0.5))
    confirmItem:setPosition(bgSprite:getContentSize().width*0.3, bgSprite:getContentSize().height*0.18)
	MenuBar:addChild(confirmItem)
	confirmItem:registerScriptTapHandler(confirmMenuCb)
    -- 取消按钮
	local cancelItem = LuaCC.create9ScaleMenuItem("images/star/intimate/btn_blue_n.png","images/star/intimate/btn_blue_n.png",CCSizeMake(140,70),GetLocalizeStringBy("key_2326"),ccc3(255,222,0))
    cancelItem:setAnchorPoint(ccp(0.5, 0.5))
    cancelItem:setPosition(bgSprite:getContentSize().width*0.7, bgSprite:getContentSize().height*0.18)
	MenuBar:addChild(cancelItem)
	cancelItem:registerScriptTapHandler(closeMenuCallBack)

	-- local Node = CCNode:create()

    require "script/libs/LuaCCLabel"
    local imgPath = nil
    if(_type == "gold")then
    	imgPath = "images/common/gold.png"
    	strColor = ccc3(255,222,0)
    elseif(_type == "silver")then
    	imgPath= "images/common/coin_silver.png"
    	strColor = ccc3(0x00, 0xff, 0x18)
    end
    local richInfo = {lineAlignment = 2,elements = {}}
       richInfo.elements[1] = {
			    ["type"] = "CCLabelTTF", 
			    newLine = false, 
			    text = GetLocalizeStringBy("djn_103"),
			    font = g_sFontName, 
			    size = 30, 
			    color = ccc3(0x78, 0x25, 0x00),}
	    richInfo.elements[2] = {
			    ["type"] = "CCSprite", 
			    newLine = false, 
			    --text = GetLocalizeStringBy("key_1307"),
			    image = imgPath}
	    richInfo.elements[3] = {
			    ["type"] = "CCRenderLabel", 
			    newLine = false, 
			    text = _count,
			    font = g_sFontName, 
			    size = 30, 
			    color = strColor,
				strokeSize = 1, 
			    strokeColor = ccc3(0x00, 0x00, 0x00), 
			    renderType = 1}
	    richInfo.elements[4] = {
			    ["type"] = "CCLabelTTF", 
			    newLine = false, 
			    text = GetLocalizeStringBy("djn_104"),
			    font = g_sFontName, 
			    size = 30, 
			    color = ccc3(0x78, 0x25, 0x00),}
  
    local midSp = LuaCCLabel.createRichLabel(richInfo)
    midSp:setAnchorPoint(ccp(0.5,0.5))
    midSp:setPosition(ccp(bgSprite:getContentSize().width*0.5,bgSprite:getContentSize().height*0.8))
    bgSprite:addChild(midSp)
	
    -- 创建奖励物品
	local itemback = CCScale9Sprite:create("images/reward/item_back.png")
	itemback:setContentSize(CCSizeMake(400, 125))
	itemback:setAnchorPoint(ccp(0.5,0))
	itemback:setPosition(ccp(bgSprite:getContentSize().width *0.5, bgSprite:getContentSize().height*0.3))
	bgSprite:addChild(itemback)

	local rewardTable = {}
	--print("_goodInfo的类型",type(_goodInfo))
	if(type(_goodIdInfo) == "table")then
	    for k,v in pairs(_goodIdInfo)do 
	    	local goodTable = ReResourceData.getAllRewardByType(v,_type)
	    	local typeNum = ReResourceData.getTypeNumFromCache(v)
	    	for i=1,typeNum do
	    		if (goodTable) then
			    	for i,j in pairs(goodTable) do
			    		table.insert(rewardTable,j)
			    	end
			    end
	    	end
	    end
	    -- 合并奖励 add by lgx 20160825
	    rewardTable = ReResourceData.mergeRewardTable(rewardTable)
	else
		rewardTable = ReResourceData.getAllRewardByType(_goodIdInfo,tostring(_type))
    end

	local function rewardItemTableCallback( fn, p_table, a1, a2 )
		--print(fn)
		local r
		local length = table.count(rewardTable)
		if fn == "cellSize" then
			r = CCSizeMake(110, 115)
			-- print("cellSize", a1, r)
		elseif fn == "cellAtIndex" then
			-- if not a2 then
			a2 = CCTableViewCell:create()
			local itemIconBg = nil
			local itemIcon   = nil

			itemIconBg = ItemUtil.createGoodsIcon(rewardTable[a1+1])
			a2:addChild(itemIconBg)				
			itemIconBg:setAnchorPoint(ccp(0, 0))
			itemIconBg:setPosition(ccp(10, 30))			
			r = a2
			-- print("cellAtIndex", a1, r)
		elseif fn == "numberOfCells" then			
			r = length
		elseif fn == "cellTouched" then
		end
		return r
	end

	local tableViewSize = CCSizeMake(397,118)

	local rewardItemTable  = LuaTableView:createWithHandler(LuaEventHandler:create(rewardItemTableCallback), tableViewSize)
	itemback:addChild(rewardItemTable)
	rewardItemTable:setBounceable(true)
	rewardItemTable:setAnchorPoint(ccp(0, 0))
	rewardItemTable:setPosition(ccp(5, 0))
	rewardItemTable:setDirection(kCCScrollViewDirectionHorizontal)
	rewardItemTable:setTouchPriority(-581)
	rewardItemTable:reloadData()
end

-----------入口函数
-----------参数：花费的类型、花费的数量、奖励列表、得到确定后回调、触摸优先级、Z轴
function showLayer(p_type,p_num,p_allgoods,p_ConfirmCb,p_touchPriority,p_ZOrder)
	init()
	_touchPriority = p_touchPriority or -599
	_ZOrder = p_ZOrder or 9999
	
	_type = p_type
	--print("花费类型",_type)
	
	_count = p_num
	--print("花费数量",_count)

	_goodIdInfo = p_allgoods
	-- print("奖品预览id")
	-- print_t(_goodIdInfo)

	_confirmCb = p_ConfirmCb
	-- _infoTable = allinfo 
	_bgLayer = CCLayerColor:create(ccc4(0,0,0,155))
	_bgLayer:registerScriptHandler(onNodeEvent)
	--_bgLayer:setScale(g_fScaleX)
	local curScene = CCDirector:sharedDirector():getRunningScene()
    curScene:addChild(_bgLayer,_ZOrder)

    createBgUI()

	return _bgLayer
end