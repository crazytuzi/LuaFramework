-- FileName: SoulRewardLayer.lua 
-- Author: licong 
-- Date: 15/9/25 
-- Purpose: 战魂重生奖励框 


module("SoulRewardLayer", package.seeall)

local _bgLayer                  	= nil
local _backGround 					= nil
local _second_bg  					= nil

local _showItems 					= nil
local _bgSize 						= nil
local _itemBgSize 					= nil 

local _touchPriority 				= nil
local _zOrder 						= nil
function init( ... )
	_bgLayer                    	= nil
	_backGround 					= nil
	_second_bg  					= nil

	_bgSize 						= nil
	_itemBgSize 					= nil 

	_touchPriority 					= nil
	_zOrder 						= nil
end


--[[
	@des 	:关闭提示框
	@param 	:
	@return :
--]]
function closeTipLayer()
    if(_bgLayer)then
		_bgLayer:removeFromParentAndCleanup(true)
		_bgLayer = nil
	end
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
	@des 	:关闭按钮回调
	@param 	:
	@return :
--]]
function closeButtonCallback( tag, sender )
    -- 音效
    require "script/audio/AudioUtil"
    AudioUtil.playEffect("audio/effect/guanbi.mp3")
	if(_bgLayer)then
		_bgLayer:removeFromParentAndCleanup(true)
		_bgLayer = nil
	end

	-- -- 显示快速猎魂
	-- require "script/ui/huntSoul/QuickHuntDialog"
	-- QuickHuntDialog.showTip()
end

--[[
	@des 	:再猎50次按钮回调
	@param 	:
	@return :
--]]
function zaiMenuItemCallback( tag, sender )
    -- 音效
    require "script/audio/AudioUtil"
    AudioUtil.playEffect("audio/effect/guanbi.mp3")
	if(_bgLayer)then
		_bgLayer:removeFromParentAndCleanup(true)
		_bgLayer = nil
	end

	-- 猎50次回调
	require "script/ui/huntSoul/SearchSoulLayer"
	SearchSoulLayer.fiftyHuntCallFun()
end


-- 创建物品图标
function createCell( cellValues )
	-- 物品   
	local iconBg =  ItemUtil.createGoodsIcon(cellValues, nil, nil, nil, nil ,nil,true,false,false)
	
	local iconName = nil
	local nameColor = nil
    if( cellValues.type == "silver" )then
    	iconName = GetLocalizeStringBy("key_1687")
		local quality = ItemSprite.getSilverQuality()
        nameColor = HeroPublicLua.getCCColorByStarLevel(quality)
    elseif(cellValues.type == "item")then
    	local itemData = ItemUtil.getItemById(tonumber(cellValues.tid))
    	iconName = itemData.name
    	nameColor = HeroPublicLua.getCCColorByStarLevel(itemData.quality)
    else
    end
   	
	--- desc 物品名字
	local descLabel = CCRenderLabel:create(iconName , g_sFontName,21,1,ccc3(0x00,0x00,0x00),type_stroke)
	descLabel:setColor(nameColor)
	descLabel:setAnchorPoint(ccp(0.5,0.5))
	descLabel:setPosition(ccp(iconBg:getContentSize().width*0.5 ,-iconBg:getContentSize().height*0.2))
	iconBg:addChild(descLabel)

	-- 是经验战魂显示具体的经验值
	if(tonumber(cellValues.item_template_id) == 72004)then
		-- 经验战魂
		local numFont = CCLabelTTF:create(cellValues.exp , g_sFontName, 18)
   	 	numFont:setColor(ccc3(0x00,0x00,0x00))
   	 	numFont:setAnchorPoint(ccp(0.5,0.5))
   	 	numFont:setPosition(ccp(iconBg:getContentSize().width*0.5,iconBg:getContentSize().height*0.5))
   	 	iconBg:addChild(numFont,100)
	end

	-- 材料
	if( cellValues.type == "silver" )then 
		descLabel:setPosition(ccp(iconBg:getContentSize().width*0.5 ,-iconBg:getContentSize().height*0.31))
		-- 物品数量
		if( cellValues.num > 1 )then
			local numberLabel =  CCRenderLabel:create(cellValues.num , g_sFontName,21,2,ccc3(0x00,0x00,0x00),type_stroke)
			numberLabel:setColor(ccc3(0x00,0xff,0x18))
			numberLabel:setAnchorPoint(ccp(0.5,0))
			local width = iconBg:getContentSize().width*0.5
			numberLabel:setPosition(ccp(width,5))
			iconBg:addChild(numberLabel)
		end
	end

	return iconBg
end

--[[
	@des 	:创建展示tableView
	@param 	:
	@return :
--]]
function createTableView( ... )
	local cellSize = CCSizeMake(556, 140)
	local h = LuaEventHandler:create(function(fn, table, a1, a2) 	--创建
		local r
		if fn == "cellSize" then
			r = cellSize
		elseif fn == "cellAtIndex" then
			a2 = CCTableViewCell:create()
			local posArrX = {0.13,0.37,0.62,0.87}
			for i=1,4 do
				if(_showItems[a1*4+i] ~= nil)then
					local item_sprite = createCell(_showItems[a1*4+i])
					item_sprite:setAnchorPoint(ccp(0.5,1))
					item_sprite:setPosition(ccp(556*posArrX[i],130))
					a2:addChild(item_sprite)
				end
			end
			r = a2
		elseif fn == "numberOfCells" then
			local num = #_showItems
			r = math.ceil(num/4)
			print("num is : ", num)
		else
		end
		return r
	end)

	local tableView = LuaTableView:createWithHandler(h, CCSizeMake(_itemBgSize.width,_itemBgSize.height-20))
	tableView:setBounceable(true)
	tableView:setTouchPriority(_touchPriority-4)
	tableView:ignoreAnchorPointForPosition(false)
	tableView:setAnchorPoint(ccp(0.5,0.5))
	tableView:setPosition(ccp(_second_bg:getContentSize().width*0.5,_second_bg:getContentSize().height*0.5))
	_second_bg:addChild(tableView)
	-- 设置单元格升序排列
	tableView:setVerticalFillOrder(kCCTableViewFillTopDown)
end

--[[
	@des 	:创建提示框
	@param 	:
	@return :
--]]
function createTipLayer( ... )

	_bgLayer = CCLayerColor:create(ccc4(11,11,11,200))
    _bgLayer:setTouchEnabled(true)
    _bgLayer:registerScriptTouchHandler(layerTouch,false,_touchPriority,true)
    local scene = CCDirector:sharedDirector():getRunningScene()
    scene:addChild(_bgLayer,_zOrder,1)

	-- 创建背景
	_bgSize = nil
	_itemBgSize = nil
	if #_showItems <= 4 then 
		_bgSize = CCSizeMake(620,410)
		_itemBgSize = CCSizeMake(556,200)
	elseif #_showItems >4 and #_showItems <= 8 then
		_bgSize = CCSizeMake(620,560)
		_itemBgSize = CCSizeMake(556,350)
	elseif #_showItems > 8 and #_showItems <= 12 then
		_bgSize = CCSizeMake(620,710)
		_itemBgSize = CCSizeMake(556,500)
	else
		_bgSize = CCSizeMake(620,860)
		_itemBgSize = CCSizeMake(556,600)
	end
	_backGround = CCScale9Sprite:create(CCRectMake(100, 80, 10, 20),"images/common/viewbg1.png")
    _backGround:setContentSize(_bgSize)
    _backGround:setAnchorPoint(ccp(0.5,0.5))
    _backGround:setPosition(ccp(_bgLayer:getContentSize().width*0.5,_bgLayer:getContentSize().height*0.5))
    _bgLayer:addChild(_backGround)
    -- 适配
    setAdaptNode(_backGround)

	-- 关闭按钮
	local menu = CCMenu:create()
    menu:setTouchPriority(_touchPriority-5)
	menu:setPosition(ccp(0, 0))
	menu:setAnchorPoint(ccp(0, 0))
	_backGround:addChild(menu,3)
	local closeButton = CCMenuItemImage:create("images/common/btn_close_n.png", "images/common/btn_close_h.png")
	closeButton:setAnchorPoint(ccp(0.5, 0.5))
	closeButton:setPosition(ccp(_backGround:getContentSize().width * 0.955, _backGround:getContentSize().height*0.975 ))
	closeButton:registerScriptTapHandler(closeButtonCallback)
	menu:addChild(closeButton)

	-- 标题
    local titlePanel = CCSprite:create("images/common/viewtitle1.png")
	titlePanel:setAnchorPoint(ccp(0.5, 0.5))
	titlePanel:setPosition(ccp(_backGround:getContentSize().width/2, _backGround:getContentSize().height-6.6 ))
	_backGround:addChild(titlePanel)
	local titleLabel = CCLabelTTF:create(GetLocalizeStringBy("key_2698"), g_sFontPangWa, 33)
	titleLabel:setColor(ccc3(0xff, 0xe4, 0x00))
	titleLabel:setAnchorPoint(ccp(0.5,0.5))
	titleLabel:setPosition(ccp(titlePanel:getContentSize().width*0.5, titlePanel:getContentSize().height*0.5))
	titlePanel:addChild(titleLabel)

	-- 恭喜主公获得
	local fontTip = CCRenderLabel:create(GetLocalizeStringBy("key_1303"), g_sFontPangWa,30,1,ccc3(0x00,0x00,0x00),type_shadow)
    fontTip:setColor(ccc3(0xff,0xf0,0x00))
    fontTip:setAnchorPoint(ccp(0,1))
    fontTip:setPosition(ccp(40,_backGround:getContentSize().height-50))
    _backGround:addChild(fontTip)

	-- 二级背景
	_second_bg = CCScale9Sprite:create("images/recycle/reward/rewardbg.png")
	_second_bg:setContentSize(_itemBgSize)
 	_second_bg:setAnchorPoint(ccp(0.5,1))
 	_second_bg:setPosition(ccp(_backGround:getContentSize().width*0.5,_backGround:getContentSize().height-100))
 	_backGround:addChild(_second_bg)

	-- 确定按钮
    local normalSprite  = CCScale9Sprite:create("images/common/btn/btn_bg_n.png")
    normalSprite:setContentSize(CCSizeMake(200, 73))
    local selectSprite  = CCScale9Sprite:create("images/common/btn/btn_bg_h.png")
    selectSprite:setContentSize(CCSizeMake(200, 73))
    local yesMenuItem = CCMenuItemSprite:create(normalSprite,selectSprite)
    yesMenuItem:setAnchorPoint(ccp(0.5,0))
    yesMenuItem:setPosition(ccp(_backGround:getContentSize().width*0.5, 20))
    yesMenuItem:registerScriptTapHandler(closeButtonCallback)
    menu:addChild(yesMenuItem)
    local  itemfont1 = CCRenderLabel:create( GetLocalizeStringBy("lic_1097"), g_sFontPangWa, 35, 1, ccc3(0x00,0x00,0x00), type_stroke)
    itemfont1:setAnchorPoint(ccp(0.5,0.5))
    itemfont1:setColor(ccc3(0xfe,0xdb,0x1c))
    itemfont1:setPosition(ccp(yesMenuItem:getContentSize().width*0.5,yesMenuItem:getContentSize().height*0.5))
    yesMenuItem:addChild(itemfont1)

    -- 创建列表
    createTableView()

    -- 动画
    local array = CCArray:create()
    local scale1 = CCScaleTo:create(0.08,1.2*MainScene.elementScale)
    local fade = CCFadeIn:create(0.06)
    local spawn = CCSpawn:createWithTwoActions(scale1,fade)
    local scale2 = CCScaleTo:create(0.07,0.9*MainScene.elementScale)
    local scale3 = CCScaleTo:create(0.07,1*MainScene.elementScale)
    array:addObject(scale1)
    array:addObject(scale2)
    array:addObject(scale3)
    local seq = CCSequence:create(array)
    _backGround:runAction(seq)
end


--[[
	@des 	:
	@param 	:p_rewardData 奖励数据,p_touchPriority界面优先级, p_zOrderNum
	@return :
--]]
function showTip( p_rewardData, p_touchPriority, p_zOrderNum )
	-- 初始化
	init()

	_showItems = p_rewardData
	print("_showItems")
	print_t(_showItems)

	_touchPriority = p_touchPriority or -450
	_zOrder = p_zOrderNum or 1010

	-- 创建提示layer
	createTipLayer()
end
































