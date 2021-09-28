-- Filename: GodShopAlertCost.lua
-- Author: DJN
-- Date: 2014-12-20
-- Purpose: 神兵商店确认花费界面

module("GodShopAlertCost", package.seeall)
require "script/audio/AudioUtil"
require "script/ui/item/ItemUtil"


local _bgLayer       --背景层
local _touchPriority --触摸优先级
local _ZOrder		 --Z轴值
local _tag          -- 奖励id
local _costType
local _confirmCb     -- 得到确认并向网络请求后的回调函数

function init()
	
	_bgLayer = nil
	_touchPriority = nil
	_ZOrder		   = nil
    _tag    = nil
    _costType = {}
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
		 -- ReResourceLayer.closeLayer()
	else
		
		if(tonumber(_costType[1]) == 1)then
			if(GodShopData.isTokenEnough(_costType[2]))then
				
				GodShopService.buyGoods(_tag,_confirmCb)
			else
				----------提示闯关令不足
				require "script/ui/tip/AnimationTip"
				AnimationTip.showTip(GetLocalizeStringBy("djn_112"))
			end
		elseif(tonumber(_costType[1]) == 2)then
			if(GodShopData.isGoldEnough(_costType[2]))then
			    GodShopService.buyGoods(_tag,_confirmCb)
			else
				----------提示金币不足
				require "script/ui/tip/LackGoldTip"
				LackGoldTip.showTip(_touchPriority-50,_ZOrder+10)
			end
		elseif(tonumber(_costType[1]) == 3)then
			if(GodShopData.isSilverEnough(_costType[2]))then
			    GodShopService.buyGoods(_tag,_confirmCb)
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
	local bgSize = CCSizeMake(530,370)
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
    confirmItem:setPosition(bgSprite:getContentSize().width*0.3, bgSprite:getContentSize().height*0.22)
	MenuBar:addChild(confirmItem)
	confirmItem:registerScriptTapHandler(confirmMenuCb)
    -- 取消按钮
	local cancelItem = LuaCC.create9ScaleMenuItem("images/star/intimate/btn_blue_n.png","images/star/intimate/btn_blue_n.png",CCSizeMake(140,70),GetLocalizeStringBy("key_2326"),ccc3(255,222,0))
    cancelItem:setAnchorPoint(ccp(0.5, 0.5))
    cancelItem:setPosition(bgSprite:getContentSize().width*0.7, bgSprite:getContentSize().height*0.22)
	MenuBar:addChild(cancelItem)
	cancelItem:registerScriptTapHandler(closeMenuCallBack)

	-- local Node = CCNode:create()

	local noteStr = CCRenderLabel:create(GetLocalizeStringBy("key_3158"),g_sFontPangWa,35,1,ccc3(0xff,0xff,0xff),type_stroke)
	noteStr:setAnchorPoint(ccp(0.5,0))
    noteStr:setColor(ccc3(0x78, 0x25, 0x00))
    noteStr:setPosition(ccp(bgSprite:getContentSize().width *0.5,bgSprite:getContentSize().height*0.8))
    bgSprite:addChild(noteStr)

    require "script/libs/LuaCCLabel"
    local imgPath = nil
    local purchaseStr = ""
    if(tonumber(_costType[1]) == 1)then
    	imgPath = "images/god_weapon/shop/token.png"
    	strColor = ccc3(255,222,0)
    	textStr = GetLocalizeStringBy("djn_123")
    	purchaseStr = GetLocalizeStringBy("key_2689")
    elseif(tonumber(_costType[1]) == 2)then
    	imgPath= "images/common/gold.png"
    	strColor = ccc3(0x00, 0xff, 0x18)
    	textStr = GetLocalizeStringBy("key_1491")
    	purchaseStr = GetLocalizeStringBy("key_3420")
    elseif(tonumber(_costType[1]) == 3)then
    	imgPath= "images/common/coin_silver.png"
    	strColor = ccc3(0x00, 0xff, 0x18)
    	textStr = GetLocalizeStringBy("key_1687")
    	purchaseStr = GetLocalizeStringBy("key_2689")
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
			    text = _costType[2],
			    font = g_sFontName, 
			    size = 30, 
			    color = strColor,
				strokeSize = 1, 
			    strokeColor = ccc3(0x00, 0x00, 0x00), 
			    renderType = 1}
		richInfo.elements[4] = {
			    ["type"] = "CCLabelTTF", 
			    newLine = false, 
			    text = textStr,
			    font = g_sFontName, 
			    size = 30, 
			    color = ccc3(0x78, 0x25, 0x00),}
	    richInfo.elements[5] = {
			    ["type"] = "CCLabelTTF", 
			    newLine = false, 
			    text = purchaseStr,
			    font = g_sFontName, 
			    size = 30, 
			    color = ccc3(0x78, 0x25, 0x00),}

  
    local midSp = LuaCCLabel.createRichLabel(richInfo)
    midSp:setAnchorPoint(ccp(0.5,0.5))
    midSp:setPosition(ccp(bgSprite:getContentSize().width*0.5,bgSprite:getContentSize().height*0.65))
    bgSprite:addChild(midSp)

    local DBStr = DB_Overcomeshop_items.getDataById(_tag).items
    local icon,itemName,itemColor = ItemUtil.createGoodsIcon(ItemUtil.getItemsDataByStr(DBStr)[1])
	local num = (ItemUtil.getItemsDataByStr(DBStr))[1].num

	local itemRichInfo = {lineAlignment = 2,elements = {}}
       itemRichInfo.elements[1] = {
			    ["type"] = "CCLabelTTF",  
			    text = num,
			    font = g_sFontPangWa, 
			    size = 30, 
			    color = ccc3(0x78, 0x25, 0x00),}
	    itemRichInfo.elements[2] = {
			    ["type"] = "CCLabelTTF",   
			    text = GetLocalizeStringBy("key_2557"),
                font = g_sFontPangWa, 
			    size = 30, 
			    color = ccc3(0x78, 0x25, 0x00),}
	    itemRichInfo.elements[3] = {
			    ["type"] = "CCRenderLabel", 
			    text = itemName,
			    font = g_sFontPangWa, 
			    size = 30, 
			    color = itemColor,}
	    itemRichInfo.elements[4] = {
			    ["type"] = "CCLabelTTF",  
			    text = "?",
			    font = g_sFontName, 
			    size = 35, 
			    color = ccc3(0x78, 0x25, 0x00),}
	    -- richInfo.elements[4] = {
			  --   ["type"] = "CCLabelTTF", 
			  --   newLine = false, 
			  --   text = GetLocalizeStringBy("djn_111"),
			  --   font = g_sFontName, 
			  --   size = 30, 
			  --   color = ccc3(0x78, 0x25, 0x00),}
  
    local itemSp = LuaCCLabel.createRichLabel(itemRichInfo)
    itemSp:setAnchorPoint(ccp(0.5,0.5))
    itemSp:setPosition(ccp(bgSprite:getContentSize().width*0.5,bgSprite:getContentSize().height*0.5))
    bgSprite:addChild(itemSp)

 --    -- 创建奖励物品
	-- local itemback = CCScale9Sprite:create("images/reward/item_back.png")
	-- itemback:setContentSize(CCSizeMake(400, 125))
	-- itemback:setAnchorPoint(ccp(0.5,0))
	-- itemback:setPosition(ccp(bgSprite:getContentSize().width *0.5, bgSprite:getContentSize().height*0.3))
	-- bgSprite:addChild(itemback)

 -- 	local rewardTable = ItemUtil.getItemsDataByStr(DB_Overcomeshop_items.getDataById(_tag).items)

	-- local function rewardItemTableCallback( fn, p_table, a1, a2 )
	-- 	--print(fn)
	-- 	local r
	-- 	local length = table.count(rewardTable)
	-- 	if fn == "cellSize" then
	-- 		r = CCSizeMake(110, 115)
	-- 		-- print("cellSize", a1, r)
	-- 	elseif fn == "cellAtIndex" then
	-- 		-- if not a2 then
	-- 		a2 = CCTableViewCell:create()
	-- 		local itemIconBg = nil
	-- 		local itemIcon   = nil

	-- 		itemIconBg = ItemUtil.createGoodsIcon(rewardTable[a1+1])
	-- 		a2:addChild(itemIconBg)				
	-- 		itemIconBg:setAnchorPoint(ccp(0, 0))
	-- 		itemIconBg:setPosition(ccp(10, 30))			
	-- 		r = a2
	-- 		-- print("cellAtIndex", a1, r)
	-- 	elseif fn == "numberOfCells" then			
	-- 		r = length
	-- 	elseif fn == "cellTouched" then
	-- 	end
	-- 	return r
	-- end

	-- local tableViewSize = CCSizeMake(397,118)

	-- local rewardItemTable  = LuaTableView:createWithHandler(LuaEventHandler:create(rewardItemTableCallback), tableViewSize)
	-- itemback:addChild(rewardItemTable)
	-- rewardItemTable:setBounceable(true)
	-- rewardItemTable:setAnchorPoint(ccp(0, 0))
	-- rewardItemTable:setPosition(ccp(5, 0))
	-- rewardItemTable:setDirection(kCCScrollViewDirectionHorizontal)
	-- rewardItemTable:setTouchPriority(-581)
	-- rewardItemTable:reloadData()
end

-----------入口函数
-----------参数：花费的类型、花费的数量、奖励列表、得到确定后回调、触摸优先级、Z轴
-- function showLayer(p_type,p_num,p_allgoods,p_ConfirmCb,p_touchPriority,p_ZOrder)
-----------参数：奖励在数据表中的id,得到确定后回调、触摸优先级、Z轴
function showLayer(p_tag,p_ConfirmCb,p_touchPriority,p_ZOrder)
	init()
	_touchPriority = p_touchPriority or -599
	_ZOrder = p_ZOrder or 9999
	_tag = p_tag
	_confirmCb = p_ConfirmCb
	_costType = GodShopData.getCostById(_tag)
	
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
function getZorder( ... )
	return _ZOrder
end