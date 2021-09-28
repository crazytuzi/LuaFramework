-- Filename：	PurchaseLayer.lua
-- Author：		Cheng Liang
-- Date：		2013-8-23
-- Purpose：		购买界面

module("PurchaseLayer", package.seeall)



require "script/ui/shop/ShopUtil"
require "script/ui/tip/AnimationTip"

local _bglayer 			= nil
local _goodsData 		= nil
local layerBg			= nil
local _numberLabel 		= nil
local _totalPriceLabel 	= nil
local _maxLimitNum 		= 99999
local _curNumber 		= 1
local _totalPrice 		= 0	

local function init( )
	_bglayer 			= nil
	_goodsData 			= nil
	layerBg				= nil
	_numberLabel 		= nil
	_totalPriceLabel 	= nil
	_maxLimitNum 		= 99999
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

-- 购买回调
function buyCallback( cbFlag, dictData, bRet )
	if(dictData.err == "ok") then
		print("_goodsData.id==", _goodsData.id)
		if(_goodsData.id == 11 )then
			UserModel.addGoldNumber( -ShopUtil.getBuySiliverTotalPriceBy(ShopUtil.getBuyNumBy(11)+1, _curNumber))
			UserModel.addSilverNumber(_curNumber * tonumber(_goodsData.buy_siliver_num))
			AnimationTip.showTip(GetLocalizeStringBy("key_3097") .. GetLocalizeStringBy("key_1984") .. _curNumber * tonumber(_goodsData.buy_siliver_num) .. GetLocalizeStringBy("key_1687") )
		elseif( _goodsData.id == 12) then
			UserModel.addGoldNumber( -ShopUtil.getBuySoulTotalPriceBy(ShopUtil.getBuyNumBy(12)+1, _curNumber))
			UserModel.addSoulNum(_curNumber * tonumber(_goodsData.buy_soul_num))
			AnimationTip.showTip(GetLocalizeStringBy("key_3097") .. GetLocalizeStringBy("key_1984") .. _curNumber * tonumber(_goodsData.buy_soul_num) .. GetLocalizeStringBy("key_1616") )
		elseif(_goodsData.item_id ~= nil)then
			UserModel.addGoldNumber(-_totalPrice)
			local itemInfo = ItemUtil.getItemById(_goodsData.item_id)
			AnimationTip.showTip(GetLocalizeStringBy("key_3097") .. GetLocalizeStringBy("key_1984") .. _curNumber .. GetLocalizeStringBy("key_2557") .. itemInfo.name )
		elseif(_goodsData.hero_id ~= nil)then
			UserModel.addGoldNumber(-_totalPrice)
			local heroDesc = HeroUtil.getHeroLocalInfoByHtid(_goodsData.hero_id)
			AnimationTip.showTip(GetLocalizeStringBy("key_3097") .. GetLocalizeStringBy("key_1984") .. _curNumber .. GetLocalizeStringBy("key_2557") .. heroDesc.name )
		end
		ShopLayer.refreshTopUI()
		DataCache.addBuyNumberBy( _goodsData.id, _curNumber )

		closeAction()
		-- if(_goodsData.id == 11 or _goodsData.id == 12 )then
		-- 	PropLayer.reloadDataFunc()
		-- end
		PropLayer.reloadDataFunc()
	end
end

-- 按钮响应
function buyAction( tag, itemBtn )
	-- 音效
	require "script/audio/AudioUtil"
	AudioUtil.playEffect("audio/effect/zhujiemian.mp3")
	if(_goodsData.item_id)then
		if(ItemUtil.isBagFull() == true)then
			
			closeAction()
			return
		end
	elseif(_goodsData.hero_id)then
		require "script/ui/hero/HeroPublicUI"
		if(HeroPublicUI.showHeroIsLimitedUI()== true)then
			
			closeAction()
			return
		end
	end
	if(tag == 10001) then
		if(_totalPrice <= UserModel.getGoldNumber()) then
			local args = Network.argsHandler(_goodsData.id, _curNumber)
			RequestCenter.shop_buyGoods(buyCallback, args)
		else
			--AnimationTip.showTip(GetLocalizeStringBy("key_2716"))
			require "script/ui/tip/LackGoldTip"
			LackGoldTip.showTip()
			closeAction()
		end
	elseif(tag == 10002) then
		closeAction()
	end
end

-- 改变购买数量
function changeNumberAction( tag, itemBtn )
	-- 音效
	require "script/audio/AudioUtil"
	AudioUtil.playEffect("audio/effect/zhujiemian.mp3")
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
	if(_curNumber<=0)then
		_curNumber = 1
	end
	if(_curNumber>_maxLimitNum) then
		_curNumber = _maxLimitNum
	end

	-- 个数
	_numberLabel:setString(_curNumber)
	_numberLabel:setPosition(ccp( (170 - _numberLabel:getContentSize().width)/2, (65 + _numberLabel:getContentSize().height)/2) )

	-- 总价
	if(_goodsData.id == 11 )then
		_totalPrice = ShopUtil.getBuySiliverTotalPriceBy(ShopUtil.getBuyNumBy(11)+1, _curNumber)
	elseif( _goodsData.id == 12) then
		_totalPrice = ShopUtil.getBuySoulTotalPriceBy(ShopUtil.getBuyNumBy(12)+1, _curNumber)
	else
		-- _totalPrice = _curNumber * _goodsData.current_price
		_totalPrice = ShopUtil.getNeedGoldByMoreGoods( _goodsData.id, ShopUtil.getBuyNumBy(_goodsData.id)+1, _curNumber)
	end
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
	local itemName = ""
	local hasNumber = 0
	if(_goodsData.buy_siliver_num) then
		-- 是购买银币
		itemName = GetLocalizeStringBy("key_1041")
		hasNumber = UserModel.getSilverNumber()
	elseif(_goodsData.buy_soul_num) then
		-- 是购买将魂
		itemName = GetLocalizeStringBy("key_3397")
		hasNumber = UserModel.getSoulNum()
	elseif(_goodsData.item_id ~=nil)then
		local itemDesc = ItemUtil.getItemById(_goodsData.item_id)
		itemName = itemDesc.name
		local cacheInfo = ItemUtil.getCacheItemInfoBy(_goodsData.item_id)
		if( not table.isEmpty(cacheInfo))then
			hasNumber = cacheInfo.item_num
		end
	elseif(_goodsData.hero_id ~=nil)then

		local heroDesc = HeroUtil.getHeroLocalInfoByHtid(_goodsData.hero_id)
		itemName = heroDesc.name
		hasNumber = HeroUtil.getHeroNumByHtid(_goodsData.hero_id)
	end

	-- 是否限购
	if(ShopUtil.getAddBuyTimeBy(UserModel.getVipLevel(), _goodsData.id) > 0) then
		 UserModel.getVipLevel()
		_maxLimitNum = - ShopUtil.getBuyNumBy(_goodsData.id) + ShopUtil.getAddBuyTimeBy(UserModel.getVipLevel(), _goodsData.id)
	end

	if(_goodsData.buy_siliver_num==nil) then
		-- 一共拥有
		local totalLael = CCRenderLabel:create(GetLocalizeStringBy("key_2041") .. hasNumber .. GetLocalizeStringBy("key_2557"), g_sFontName, 24, 1, ccc3(0x49, 0x00, 0x00), type_stroke)
	    totalLael:setColor(ccc3(0xff, 0xff, 0xff))
	    totalLael:setPosition(ccp( (innerSize.width-totalLael:getContentSize().width)/2, 295) )
	    innerBgSp:addChild(totalLael)
    end

    -- 购买提示
    local buyTipLabel_1 = CCRenderLabel:create(GetLocalizeStringBy("key_2853"), g_sFontName, 24, 1, ccc3(0x49, 0x00, 0x00), type_stroke)
    buyTipLabel_1:setColor(ccc3(0xff, 0xff, 0xff))
    innerBgSp:addChild(buyTipLabel_1)

    -- 物品名称
    local nameLabel = CCRenderLabel:create(itemName, g_sFontPangWa, 30, 1, ccc3(0x49, 0x00, 0x00), type_stroke)
    nameLabel:setColor(ccc3(0xfe, 0xdb, 0x1c))
    nameLabel:setPosition(ccp( (innerSize.width-nameLabel:getContentSize().width)/2, 250) )
    innerBgSp:addChild(nameLabel)
    buyTipLabel_1:setPosition(ccp( (innerSize.width-nameLabel:getContentSize().width)/2 -buyTipLabel_1:getContentSize().width , 240) )

    -- 购买提示2
    local buyTipLabel_2 = CCRenderLabel:create(GetLocalizeStringBy("key_2518"), g_sFontName, 24, 1, ccc3(0x49, 0x00, 0x00), type_stroke)
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
	local totalTipLabel = CCRenderLabel:create(GetLocalizeStringBy("key_1217"), g_sFontName, 36, 1, ccc3(0x49, 0x00, 0x00), type_stroke)
    totalTipLabel:setColor(ccc3(0xfe, 0xdb, 0x1c))
    totalTipLabel:setPosition(ccp(190, 72) )
    innerBgSp:addChild(totalTipLabel)
    local goldSp_2 = CCSprite:create("images/common/gold.png")
	goldSp_2:setAnchorPoint(ccp(0,0))
	goldSp_2:setPosition(ccp(280, 35))
	innerBgSp:addChild(goldSp_2)
	

    if(_goodsData.id == 11) then
		-- 是购买银币
		_totalPrice = ShopUtil.getSiliverPriceBy(ShopUtil.getBuyNumBy(11)+1)
		-- _totalPriceLabel:setString(_totalPrice)
	elseif(_goodsData.id == 12) then
		-- 是购买将魂
		_totalPrice = ShopUtil.getSoulPriceBy(ShopUtil.getBuyNumBy(12)+1)
		-- _totalPriceLabel:setString(_totalPrice)
	else
		_totalPrice = ShopUtil.getNeedGoldByGoodsAndTimes( _goodsData.id, ShopUtil.getBuyNumBy(_goodsData.id)+1)
	end

	_totalPriceLabel = CCRenderLabel:create(_totalPrice, g_sFontName, 36, 1, ccc3(0x49, 0x00, 0x00), type_stroke)
    _totalPriceLabel:setColor(ccc3(0xfe, 0xdb, 0x1c))
    _totalPriceLabel:setPosition(ccp(310, 70) )
    innerBgSp:addChild(_totalPriceLabel)


    -- 提示
    if(_goodsData.id == 1 or _goodsData.id == 2 or _goodsData.id == 10 or _goodsData.id == 11  )then
    	local tipLabel = CCLabelTTF:create(GetLocalizeStringBy("key_1651"), g_sFontName, 25)
		tipLabel:setColor(ccc3(0xff, 0xe4, 0x00))
		tipLabel:setAnchorPoint(ccp(0.5, 0.5))
		tipLabel:setPosition(ccp(270, 30))
		innerBgSp:addChild(tipLabel)

		totalTipLabel:setPosition(ccp(190, 92) )
		goldSp_2:setPosition(ccp(280, 55))
		_totalPriceLabel:setPosition(ccp(310, 90) )
    end
end

-- create
local function create( )
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
	local titleLabel = CCLabelTTF:create(GetLocalizeStringBy("key_1745"), g_sFontPangWa, 30)
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
function showPurchaseLayer( goods_id)
	init()
	_goodsData = goods_data
	require "db/DB_Goods"
	_goodsData = DB_Goods.getDataById(tonumber(goods_id))
	

	_bglayer = CCLayerColor:create(ccc4(0,0,0,155))
	_bglayer:registerScriptHandler(onNodeEvent)
	local runningScene = CCDirector:sharedDirector():getRunningScene()
	runningScene:addChild(_bglayer, 1999)

	create()
	createInnerBg()
end

