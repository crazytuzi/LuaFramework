-- FileName: PrestigeShopBuyLayer.lua 
-- Author: Li Cong 
-- Date: 13-11-27 
-- Purpose: function description of module 


module("PrestigeShopBuyLayer", package.seeall)


require "script/ui/tip/AnimationTip"
require "script/ui/item/ItemUtil"
require "script/ui/arena/ArenaData"

local _bglayer 			= nil	
local _goodsData 		= nil				-- 商品数据			
local _itemData 		= nil				-- 物品类型 
local _itemType 		= nil				-- 物品类型 1是物品 2是英雄
local layerBg			= nil
local _numberLabel 		= nil
local _totalPriceLabel 	= nil
local _maxLimitNum 		= 0
local _curNumber 		= 1
local _totalPrice 		= 0	

local function init( )
	_bglayer 			= nil
	_goodsData 			= nil
	_itemData 			= nil
	_itemType 			= nil
	layerBg				= nil
	_numberLabel 		= nil
	_totalPriceLabel 	= nil
	_maxLimitNum 		= 0
	_curNumber 			= 1
	_totalPrice 		= 0	
end


--[[
 @desc	 处理touches事件
 @para 	 string event
 @return 
--]]
local function onTouchesHandler( eventType, x, y )
	
	if (eventType == "began") then
		-- print("began")

	    return true
    elseif (eventType == "moved") then
    	
    else
        -- print("end")
	end
end


--[[
 @desc	 回调onEnter和onExit时间
 @para 	 string event
 @return void
 --]]
local function onNodeEvent( event )
	if (event == "enter") then
		print("enter")
		_bglayer:registerScriptTouchHandler(onTouchesHandler, false, -411, true)
		_bglayer:setTouchEnabled(true)
	elseif (event == "exit") then
		print("exit")
		_bglayer:unregisterScriptTouchHandler()
	end
end

-- 关闭
local function closeAction()
	-- 音效
	require "script/audio/AudioUtil"
	AudioUtil.playEffect("audio/effect/guanbi.mp3")
	_bglayer:removeFromParentAndCleanup(true)
	_bglayer = nil
end 

-- 按钮响应
function buyAction( tag, itemBtn )
	-- 音效
	require "script/audio/AudioUtil"
	AudioUtil.playEffect("audio/effect/zhujiemian.mp3")
	if(ItemUtil.isBagFull() == true)then
		--AnimationTip.showTip(GetLocalizeStringBy("key_2094"))
		-- added by fang. 2013.10.24
		closeAction()
		return
	end
	if(tag == 10001) then
		-- 判断声望值是否够
		if(_totalPrice <= UserModel.getPrestigeNum()) then
			-- 下一步创建与数据有关UI
    		local function createNext( ... )
    			-- 减去声望
    			UserModel.addPrestigeNum(-_totalPrice)
  				-- 刷新声望
  				PrestigeShop.refreshPrestigeNum() -- modify by yangrui on 15-09-23
  				-- 得到物品的个数
				local itemType, item_id, item_num = ArenaData.getItemData( _goodsData.items )
				AnimationTip.showTip(GetLocalizeStringBy("key_1004") .. GetLocalizeStringBy("key_1984") .. _curNumber*item_num .. GetLocalizeStringBy("key_2557") .. _itemData.name )
				-- 更新购买次数
				ArenaData.addBuyNumberBy( _goodsData.id, _curNumber )
				-- 关闭当前界面
				closeAction()
				-- 刷新列表
				PrestigeShop.reloadDataFunc()
    		end
			ArenaService.buy(_goodsData.id,_curNumber,createNext)
		else
			AnimationTip.showTip(GetLocalizeStringBy("key_2018"))
		end
	elseif(tag == 10002) then
		closeAction()
	end
end

-- 改变兑换数量
function changeNumberAction( tag, itemBtn )
	-- 音效
	require "script/audio/AudioUtil"
	AudioUtil.playEffect("audio/effect/zhujiemian.mp3")
	print("tag 的值:")
	print(tag)
	if(tag == 10001) then
		-- -10
		_curNumber = _curNumber - 10
	elseif(tag == 10002) then
		-- -1
		_curNumber = _curNumber - 1 
	elseif(tag == 10003) then
		-- +1
		_curNumber = _curNumber + 1 
	elseif(tag == 10004) then
		-- +10
		_curNumber = _curNumber + 10 
	end
		-- 限购次数

	if(_goodsData.level_num == nil)then
		_maxLimitNum = tonumber(_goodsData.baseNum) - ArenaData.getBuyNumBy(_goodsData.id)
	else 
	   	require "script/ui/arena/ArenaData"
		local _number,_level = ArenaData.getLevelnumber(_goodsData)
		_maxLimitNum = tonumber(_number - ArenaData.getBuyNumBy(_goodsData.id))

	end

	if(_curNumber<=0)then
		_curNumber = 1
	end
	if(_curNumber>_maxLimitNum) then
		_curNumber = _maxLimitNum
	end
	print("_curNumber\n", _curNumber)

    
	-- 个数
	_numberLabel:setString(_curNumber)
	_numberLabel:setPosition(ccp( (170 - _numberLabel:getContentSize().width)/2, (65 + _numberLabel:getContentSize().height)/2) )

	-- 总价
	_totalPrice = tonumber(_goodsData.costPrestige) * tonumber(_curNumber)
	_totalPriceLabel:setString(_totalPrice)
end

-- create 背景2
local function createInnerBg()
	-- 背景2
	local innerBgSp = CCScale9Sprite:create("images/common/bg/bg_ng_attr.png")
	innerBgSp:setContentSize(CCSizeMake(560, 330))
	innerBgSp:setAnchorPoint(ccp(0.5, 0))
	innerBgSp:setPosition(ccp(layerBg:getContentSize().width*0.5, 110))
	layerBg:addChild(innerBgSp)

	local innerSize = innerBgSp:getContentSize()
---- 准备数据
	-- 物品名字 和 已经拥有的数量
	local itemName = ""
	local hasNumber = 0
	if(tonumber(_itemType) == 1)then
		-- DB_Arena_shop表中每条数据中的 物品数据
		itemName = _itemData.name
		local cacheInfo = ItemUtil.getCacheItemInfoBy(_itemData.id)
		if( not table.isEmpty(cacheInfo))then
			hasNumber = cacheInfo.item_num
		end
	elseif(tonumber(_itemType) == 2)then
		-- -- DB_Arena_shop表中每条数据中的 英雄数据
		require "script/model/hero/HeroModel"
		itemName = _itemData.name
		local allHeroData = HeroModel.getAllByHtid(tostring(_itemData.id))
		if( not table.isEmpty(allHeroData))then
			hasNumber = table.count(allHeroData)
		end
	end


	-- 一共拥有
	local totalLael = CCRenderLabel:create(GetLocalizeStringBy("key_2041") .. hasNumber .. GetLocalizeStringBy("key_2557"), g_sFontName, 24, 1, ccc3(0x49, 0x00, 0x00), type_stroke)
    totalLael:setColor(ccc3(0xff, 0xff, 0xff))
    totalLael:setPosition(ccp( (innerSize.width-totalLael:getContentSize().width)/2, 295) )
    innerBgSp:addChild(totalLael)

    -- 兑换提示
    local buyTipLabel_1 = CCRenderLabel:create(GetLocalizeStringBy("key_1438"), g_sFontName, 24, 1, ccc3(0x49, 0x00, 0x00), type_stroke)
    buyTipLabel_1:setColor(ccc3(0xff, 0xff, 0xff))
    innerBgSp:addChild(buyTipLabel_1)

    -- 物品名称
    local nameLabel = CCRenderLabel:create(itemName, g_sFontPangWa, 30, 1, ccc3(0x49, 0x00, 0x00), type_stroke)
    nameLabel:setColor(ccc3(0xfe, 0xdb, 0x1c))
    nameLabel:setPosition(ccp( (innerSize.width-nameLabel:getContentSize().width)/2, 250) )
    innerBgSp:addChild(nameLabel)
    buyTipLabel_1:setPosition(ccp( (innerSize.width-nameLabel:getContentSize().width)/2 -buyTipLabel_1:getContentSize().width , 240) )

    -- 兑换提示2
    local buyTipLabel_2 = CCRenderLabel:create(GetLocalizeStringBy("key_3113"), g_sFontName, 24, 1, ccc3(0x49, 0x00, 0x00), type_stroke)
    buyTipLabel_2:setColor(ccc3(0xff, 0xff, 0xff))
    buyTipLabel_2:setPosition(ccp( innerSize.width/2 + nameLabel:getContentSize().width/2, 240) )
    innerBgSp:addChild(buyTipLabel_2)

---- 加减道具的按钮
	local changeNumBar = CCMenu:create()
	changeNumBar:setPosition(ccp(0,0))
	changeNumBar:setTouchPriority(-412)
	innerBgSp:addChild(changeNumBar)

	-- -10
	local reduce10Btn = CCMenuItemImage:create("images/shop/prop/btn_reduce10_n.png", "images/shop/prop/btn_reduce10_h.png")
	reduce10Btn:setPosition(ccp(4, 110))
	reduce10Btn:registerScriptTapHandler(changeNumberAction)
	changeNumBar:addChild(reduce10Btn, 1, 10001)

	-- -1
	local reduce1Btn = CCMenuItemImage:create("images/shop/prop/btn_reduce_n.png", "images/shop/prop/btn_reduce_h.png")
	reduce1Btn:setPosition(ccp(123, 110))
	reduce1Btn:registerScriptTapHandler(changeNumberAction)
	changeNumBar:addChild(reduce1Btn, 1, 10002)

	-- 数量背景
	local numberBg = CCScale9Sprite:create("images/common/checkbg.png")
	numberBg:setContentSize(CCSizeMake(170, 65))
	numberBg:setAnchorPoint(ccp(0.5, 0))
	numberBg:setPosition(ccp(innerBgSp:getContentSize().width*0.5, 110))
	innerBgSp:addChild(numberBg)
	-- 数量数字
	_numberLabel = CCRenderLabel:create("1", g_sFontPangWa, 36, 1, ccc3(0x49, 0x00, 0x00), type_stroke)
    _numberLabel:setColor(ccc3(0xff, 0xff, 0xff))
    _numberLabel:setPosition(ccp( (numberBg:getContentSize().width - _numberLabel:getContentSize().width)/2, (numberBg:getContentSize().height + _numberLabel:getContentSize().height)/2) )
    numberBg:addChild(_numberLabel)

	-- +1
	local reduce1Btn = CCMenuItemImage:create("images/shop/prop/btn_addition_n.png", "images/shop/prop/btn_addition_h.png")
	reduce1Btn:setPosition(ccp(370, 110))
	reduce1Btn:registerScriptTapHandler(changeNumberAction)
	changeNumBar:addChild(reduce1Btn, 1, 10003)

	-- +10
	local reduce10Btn = CCMenuItemImage:create("images/shop/prop/btn_addition10_n.png", "images/shop/prop/btn_addition10_h.png")
	reduce10Btn:setPosition(ccp(445, 110))
	reduce10Btn:registerScriptTapHandler(changeNumberAction)
	changeNumBar:addChild(reduce10Btn, 1, 10004)

	-- 总价
	local totalTipLabel = CCRenderLabel:create(GetLocalizeStringBy("key_2655"), g_sFontName, 36, 1, ccc3(0x49, 0x00, 0x00), type_stroke)
    totalTipLabel:setColor(ccc3(0xfe, 0xdb, 0x1c))
    totalTipLabel:setPosition(ccp(110, 72) )
    innerBgSp:addChild(totalTipLabel)
    local goldSp_2 = CCSprite:create("images/common/prestige.png")
	goldSp_2:setAnchorPoint(ccp(0,0))
	goldSp_2:setPosition(ccp(280, 35))
	innerBgSp:addChild(goldSp_2)
	_totalPrice = tonumber(_goodsData.costPrestige)
	_totalPriceLabel = CCRenderLabel:create(_totalPrice, g_sFontName, 36, 1, ccc3(0x49, 0x00, 0x00), type_stroke)
    _totalPriceLabel:setColor(ccc3(0xfe, 0xdb, 0x1c))
    _totalPriceLabel:setPosition(ccp(310, 70) )
    innerBgSp:addChild(_totalPriceLabel)
end

-- create
local function createBg( )
	-- 背景
	layerBg = CCScale9Sprite:create("images/formation/changeformation/bg.png")
	layerBg:setContentSize(CCSizeMake(610, 490))
	layerBg:setAnchorPoint(ccp(0.5, 0.5))
	layerBg:setPosition(ccp(_bglayer:getContentSize().width*0.5, _bglayer:getContentSize().height*0.5))
	_bglayer:addChild(layerBg)
	layerBg:setScale(g_fScaleX)	

	local titleSp = CCSprite:create("images/formation/changeformation/titlebg.png")
	titleSp:setAnchorPoint(ccp(0.5,0.5))
	titleSp:setPosition(ccp(layerBg:getContentSize().width/2, layerBg:getContentSize().height*0.985))
	layerBg:addChild(titleSp)
	local titleLabel = CCLabelTTF:create(GetLocalizeStringBy("key_2342"), g_sFontPangWa, 30)
	titleLabel:setColor(ccc3(0xff, 0xe4, 0x00))
	titleLabel:setAnchorPoint(ccp(0.5, 0.5))
	titleLabel:setPosition(ccp(titleSp:getContentSize().width/2, titleSp:getContentSize().height/2))
	titleSp:addChild(titleLabel)

	-- 关闭按钮bar
	local closeMenuBar = CCMenu:create()
	closeMenuBar:setPosition(ccp(0, 0))
	layerBg:addChild(closeMenuBar)
	closeMenuBar:setTouchPriority(-412)
	-- 关闭按钮
	local closeBtn = LuaMenuItem.createItemImage("images/common/btn_close_n.png", "images/common/btn_close_h.png", closeAction )
	closeBtn:setAnchorPoint(ccp(0.5, 0.5))
    closeBtn:setPosition(ccp(layerBg:getContentSize().width*0.97, layerBg:getContentSize().height*0.98))
	closeMenuBar:addChild(closeBtn)

	local buyMenuBar = CCMenu:create()
	buyMenuBar:setPosition(ccp(0,0))
	buyMenuBar:setTouchPriority(-412)
	layerBg:addChild(buyMenuBar)

	-- 按钮
	local comfirmBtn = LuaCC.create9ScaleMenuItem("images/star/intimate/btn_blue_n.png", "images/star/intimate/btn_blue_h.png",CCSizeMake(140, 70), GetLocalizeStringBy("key_1985"),ccc3(0xfe, 0xdb, 0x1c),30,g_sFontPangWa,1, ccc3(0x00, 0x00, 0x00))
	comfirmBtn:setAnchorPoint(ccp(0, 0))
	comfirmBtn:setPosition(ccp(125, 35	))
	comfirmBtn:registerScriptTapHandler(buyAction)
	buyMenuBar:addChild(comfirmBtn, 1, 10001)

	local cancelBtn = LuaCC.create9ScaleMenuItem("images/star/intimate/btn_blue_n.png", "images/star/intimate/btn_blue_h.png",CCSizeMake(140, 70), GetLocalizeStringBy("key_1202"),ccc3(0xfe, 0xdb, 0x1c),30,g_sFontPangWa,1, ccc3(0x00, 0x00, 0x00))
	cancelBtn:setAnchorPoint(ccp(0, 0))
	cancelBtn:setPosition(ccp(350, 35))
	cancelBtn:registerScriptTapHandler(buyAction)
	buyMenuBar:addChild(cancelBtn, 1, 10002)

end 

-- showPurchaseLayer
function showPurchaseLayer( goods_id )
	init()
	-- 选择的物品数据解析
	require "db/DB_Arena_shop"
	-- 商品数据
	_goodsData = DB_Arena_shop.getDataById(goods_id)
	-- 兑换商品中物品的数据
	local item_type, item_id, item_num = ArenaData.getItemData( _goodsData.items )
	print("item_type",item_type,"item_id",item_id,"item_num",item_num)
	-- 物品类型 1是物品 2是英雄
	_itemType = item_type
	-- 表中物品数据,物品图标
	local item_data = nil
	local iconSprite = nil
	if(tonumber(_itemType) == 1)then
		-- DB_Arena_shop表中每条数据中的 物品数据
		require "script/ui/item/ItemUtil"
		_itemData = ItemUtil.getItemById(item_id)
	elseif(tonumber(_itemType) == 2)then
		-- -- DB_Arena_shop表中每条数据中的 英雄数据
		require "script/model/utils/HeroUtil"
		_itemData = HeroUtil.getHeroLocalInfoByHtid(item_id)
	end

	_bglayer = CCLayerColor:create(ccc4(0,0,0,155))
	_bglayer:registerScriptHandler(onNodeEvent)
	local runningScene = CCDirector:sharedDirector():getRunningScene()
	runningScene:addChild(_bglayer, 1999)

	-- 创建背景
	createBg()
	-- 创建二级背景
	createInnerBg()
end
