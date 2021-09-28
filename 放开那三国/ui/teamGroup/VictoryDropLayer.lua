-- Filename: VictoryDropLayer.lua
-- Author: zhz
-- Date: 2013-2-22
-- Purpose: 物品掉落的UI

require "script/ui/item/ItemSprite"
require "script/ui/item/ItemUtil"

module("VictoryDropLayer", package.seeall)

local _bgLayer 					= nil
local _touchProperty
local _zOrder

local _itemInfoBg


local function init(  )
	_bgLayer= nil
	_touchProperty= nil
	_zOrder= nil

	_itemInfoBg= nil
end


function layerTouch(eventType, x, y)
    return true   
end


local function closeBtnCb(  )
	require "script/audio/AudioUtil"
	AudioUtil.playEffect("audio/effect/guanbi.mp3")
	if(_bgLayer ~= nil)then
		_bgLayer:removeFromParentAndCleanup(true)
		_bgLayer = nil
	end
end
-- 
function showLayer( items , touchProperty, zOrder)

	init()


    _touchProperty= touchProperty or -551
    _zOrder= zOrder or 655

	_bgLayer = CCLayerColor:create(ccc4(11,11,11,200))
	_bgLayer:registerScriptTouchHandler(layerTouch,false,_touchProperty,true)
	_bgLayer:setTouchEnabled(true)

   local scene = CCDirector:sharedDirector():getRunningScene()
    scene:addChild(_bgLayer,_zOrder)


        -- 根据奖励物品个数设置高度
    if(table.count(items) > 8)then
    	bg_hight = 606
    	itemBg_hight = 440
    	-- tableView_hight = 300
    elseif( table.count(items) > 4 and table.count(items) <= 8 )then
    	bg_hight = 461
    	itemBg_hight = 295
    	tableView_hight = 290
    else
    	bg_hight = 380
    	itemBg_hight = 150
    	-- tableView_hight = 140
    end
    
    local fullRect = CCRectMake(0, 0, 213, 171)
    local insetRect = CCRectMake(100, 80, 10, 20)
    _itemInfoBg= CCScale9Sprite:create("images/common/viewbg1.png", fullRect, insetRect)
    _itemInfoBg:setContentSize(CCSizeMake(640,bg_hight))
    _itemInfoBg:setScale(g_fElementScaleRatio)
    _bgLayer:addChild(_itemInfoBg)
    _itemInfoBg:setPosition(ccp(g_winSize.width*0.5,g_winSize.height*0.5))
    _itemInfoBg:setAnchorPoint(ccp(0.5,0.5))

   local titleBg= CCSprite:create("images/common/viewtitle1.png")
	titleBg:setPosition(ccp(_itemInfoBg:getContentSize().width*0.5,_itemInfoBg:getContentSize().height-6))
	titleBg:setAnchorPoint(ccp(0.5, 0.5))
	_itemInfoBg:addChild(titleBg)

	--奖励的标题文本
	local labelTitle = CCRenderLabel:create(GetLocalizeStringBy("key_1322"), g_sFontPangWa,33,2,ccc3(0x0,0x00,0x0),type_shadow)
	labelTitle:setColor(ccc3( 0xff, 0xe4, 0x0))
	labelTitle:setPosition(ccp(titleBg:getContentSize().width*0.5,titleBg:getContentSize().height*0.5+2 ))
	labelTitle:setAnchorPoint(ccp(0.5,0.5))
	titleBg:addChild(labelTitle)


        -- 关闭按钮
	local menu = CCMenu:create()
	menu:setTouchPriority(_touchProperty-1)
	menu:setPosition(ccp(0, 0))
	menu:setAnchorPoint(ccp(0, 0))
	_itemInfoBg:addChild(menu,16)
	local closeButton = CCMenuItemImage:create("images/common/btn_close_n.png", "images/common/btn_close_h.png")
	closeButton:setAnchorPoint(ccp(0.5, 0.5))
	closeButton:setPosition(ccp(_itemInfoBg:getContentSize().width*0.95, _itemInfoBg:getContentSize().height*0.95 ))
	closeButton:registerScriptTapHandler(closeBtnCb)
	menu:addChild(closeButton)

 	local sureBtn =  LuaCC.create9ScaleMenuItem("images/common/btn/btn_green_n.png","images/common/btn/btn_green_h.png",CCSizeMake(200,71) ,GetLocalizeStringBy("key_1465"),ccc3(0xfe, 0xdb, 0x1c),30,g_sFontPangWa,1, ccc3(0x00, 0x00, 0x00))
 	sureBtn:setPosition(_itemInfoBg:getContentSize().width*0.5, 33)
 	sureBtn:setAnchorPoint(ccp(0.5,0))
 	sureBtn:registerScriptTapHandler(closeBtnCb)
 	menu:addChild(sureBtn)


 	 local itemBg = CCScale9Sprite:create("images/common/bg/bg_ng_attr.png")
	itemBg:setContentSize(CCSizeMake(578, itemBg_hight))
	itemBg:setAnchorPoint(ccp(0.5, 1))
	itemBg:setPosition(ccp(_itemInfoBg:getContentSize().width*0.5,_itemInfoBg:getContentSize().height - 51))
	_itemInfoBg:addChild(itemBg)

	local cellSize = CCSizeMake(578, 140)
	local maxNum= 5
	local h = LuaEventHandler:create(function(fn, table, a1, a2) 	--创建
		local r
		if fn == "cellSize" then
			r = cellSize
		elseif fn == "cellAtIndex" then
			a2 = CCTableViewCell:create()
			local posArrX = {0.14,0.38,0.62,0.86}
			for i=1,maxNum do
				if(items[a1*maxNum+i] ~= nil)then
					local item_sprite = getItemSprite(items[a1*maxNum+i])
					item_sprite:setAnchorPoint(ccp(0,1))
					item_sprite:setPosition(ccp(21+ 578*(i-1)*0.19 ,130))
					a2:addChild(item_sprite)
				end
			end
			r = a2
		elseif fn == "numberOfCells" then
			local num = #items
			r = math.ceil(num/maxNum)
			print("num is : ", num)
		elseif fn == "cellTouched" then
			
		elseif (fn == "scroll") then
			
		end
		return r
	end)

	local goodTableView = LuaTableView:createWithHandler(h, CCSizeMake(578, itemBg_hight-10))
	goodTableView:setBounceable(true)
	goodTableView:setTouchPriority(_touchProperty-3)
	-- 上下滑动
	goodTableView:setDirection(kCCScrollViewDirectionVertical)
	goodTableView:setVerticalFillOrder(kCCTableViewFillTopDown)
	itemBg:addChild(goodTableView)

	require "script/network/PreRequest"
	PreRequest.registerTeamBattleDelegate(closeCb)

end

-- 创建物品图标
function getItemSprite( item )
	local iconBg = nil
	local iconName = nil
	local nameColor = nil

		-- 物品
	iconBg =  ItemSprite.getItemSpriteById(tonumber(item.tid),nil, nil, nil,_touchProperty-3,_zOrder+3  )
	local itemData = ItemUtil.getItemById(item.tid)
    iconName = itemData.name
    nameColor = HeroPublicLua.getCCColorByStarLevel(itemData.quality)

	-- 物品数量
	-- if( tonumber(cellValues.num) > 1 )then
	-- 	local numberLabel =  CCRenderLabel:create("" .. item.num , g_sFontName,21,2,ccc3(0x00,0x00,0x00),type_stroke)
	-- 	numberLabel:setColor(ccc3(0x00,0xff,0x18))
	-- 	numberLabel:setAnchorPoint(ccp(0,0))
	-- 	local width = iconBg:getContentSize().width - numberLabel:getContentSize().width - 6
	-- 	numberLabel:setPosition(ccp(width,5))
	-- 	iconBg:addChild(numberLabel)
	-- end

	--- desc 物品名字
	local descLabel = CCRenderLabel:create("" .. iconName , g_sFontName,21,1,ccc3(0x00,0x00,0x00),type_stroke)
	descLabel:setColor(nameColor)
	descLabel:setAnchorPoint(ccp(0.5,0.5))
	descLabel:setPosition(ccp(iconBg:getContentSize().width*0.5 ,-iconBg:getContentSize().height*0.2))
	iconBg:addChild(descLabel)

	return iconBg
end



