-- FileName: StaminaAlertTip.lua 
-- Author: Li Cong 
-- Date: 13-12-16 
-- Purpose: 耐力使用提示


module("StaminaAlertTip", package.seeall)

require "script/ui/common/LuaMenuItem"
require "script/ui/main/MainScene"
require "script/ui/item/ItemSprite"
require "script/ui/shop/ShopUtil"


local alertLayer

local stamina_template_id = 10042
local stamina_goods_id = 2
local _curHasLabel = nil
local _curNumber = 0
local alertBg
local _curPrice = 0
local _curPriceLabel = nil
local _callBack = nil     -- 回调函数


-- 初始
local function init()
	_curHasLabel = nil
	_curNumber = 0
	alertBg = nil
	_curPrice = 0
	_curPriceLabel = nil
	_callBack = nil
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
		print("AlertTip.onNodeEvent.......................enter")
		alertLayer:registerScriptTouchHandler(onTouchesHandler, false, -560, true)
		alertLayer:setTouchEnabled(true)
	elseif (event == "exit") then
		print("AlertTip.onNodeEvent.......................exit")
		alertLayer:unregisterScriptTouchHandler()
	end
end


function closeAction()
	require "script/audio/AudioUtil"
	AudioUtil.playEffect("audio/effect/guanbi.mp3")
	if(alertLayer) then
		alertLayer:removeFromParentAndCleanup(true)
		alertLayer = nil
	end
end

-- 购买回调
function buyCallback( cbFlag, dictData, bRet )
	if(dictData.err == "ok") then
		require "db/DB_Goods"
		local goodsData = DB_Goods.getDataById(stamina_goods_id)
		UserModel.addGoldNumber(-_curPrice)
		DataCache.addBuyNumberBy( goodsData.id, 1 )
		AnimationTip.showTip(GetLocalizeStringBy("key_2824"))
		_curNumber = _curNumber + 1
	    _curHasLabel:setString(GetLocalizeStringBy("key_3413") .. _curNumber)

	    -- 修改当前价格
		_curPrice = ShopUtil.getNeedGoldByGoodsAndTimes( goodsData.id, ShopUtil.getBuyNumBy(goodsData.id)+1)
	    _curPriceLabel:setString(_curPrice)

	    -- 购买后回调
	    if(_callBack ~= nil)then
	    	print("222222222222")
	    	_callBack()
	   	end
	end
end

-- 使用回调
function useItemCallback( cbFlag, dictData, bRet )
	if (dictData.err == "ok") then
		AnimationTip.showTip(GetLocalizeStringBy("key_3016"))
		UserModel.addStaminaNumber(10)

		_curNumber = _curNumber - 1
	    _curHasLabel:setString(GetLocalizeStringBy("key_3413") .. _curNumber)

		-- 注册方法不为空则调用
		print("_callBack--",_callBack)
		if( _callBack ~= nil )then
			_callBack()
		end
	end
	-- if(alertLayer) then
	-- 	alertLayer:removeFromParentAndCleanup(true)
	-- 	alertLayer = nil
	-- end
end

-- 按钮响应
function menuAction( tag, itemBtn )
	-- if(alertLayer) then
	-- 	alertLayer:removeFromParentAndCleanup(true)
	-- 	alertLayer = nil
	-- end
	print ("tag==", tag)
	if(tag == 10001) then
		if( not DataCache.getSwitchNodeState(ksSwitchShop,true)) then
			return
		end
		-- 道具背包已满
		if(ItemUtil.isPropBagFull() == true)then
			
			closeAction()
			return
		end
		
		require "db/DB_Goods"
		local goodsData = DB_Goods.getDataById(stamina_goods_id)

		if(goodsData.vip_needed and tonumber(goodsData.vip_needed)>tonumber(UserModel.getVipLevel())) then
			AnimationTip.showTip(GetLocalizeStringBy("key_2597").. goodsData.vip_needed .. GetLocalizeStringBy("key_2005") )
			return
		end
		if(goodsData.user_lv_needed and  tonumber(goodsData.user_lv_needed)> tonumber( UserModel.getHeroLevel())) then
			AnimationTip.showTip(GetLocalizeStringBy("key_2803").. goodsData.user_lv_needed .. GetLocalizeStringBy("key_1093") )
			return
		end
		require "script/ui/shop/ShopUtil"
		-- 是否限购
		if(ShopUtil.getAddBuyTimeBy(UserModel.getVipLevel(), goodsData.id) > 0) then
			local maxLimitNum = - ShopUtil.getBuyNumBy(goodsData.id) + ShopUtil.getAddBuyTimeBy(UserModel.getVipLevel(), goodsData.id)
			if(maxLimitNum<=0)then
				AnimationTip.showTip(GetLocalizeStringBy("key_2553"))
				return
			end
		end
		-- print("+++++++++++++ ",goodsData.current_price)
		-- print("----------",UserModel.getGoldNumber())
		if(tonumber(_curPrice) <= UserModel.getGoldNumber()) then
			local args = Network.argsHandler(goodsData.id, 1)
			RequestCenter.shop_buyGoods(buyCallback, args)
		else
			alertLayer:removeFromParentAndCleanup(true)
			alertLayer = nil
			require "script/ui/tip/LackGoldTip"
			LackGoldTip.showTip()
			--AnimationTip.showTip(GetLocalizeStringBy("key_2716"))
		end
	elseif (tag == 10002) then
		local staminaInfo = ItemUtil.getCacheItemInfoBy(stamina_template_id)
		if((not table.isEmpty(staminaInfo)) and tonumber(staminaInfo.item_num) > 0) then
			local args = Network.argsHandler(staminaInfo.gid, staminaInfo.item_id, 1,1)
			RequestCenter.bag_useItem(useItemCallback, args)
		else
			AnimationTip.showTip(GetLocalizeStringBy("key_1660"))
		end
	end
	
end

--[[
	@desc	alertView
	@para 	func1:使用耐力后回调， func2:购买耐力后回调
	@return void
--]]
function showTip(p_CallBack)
	init()
	-- 耐力增加后回调
	print("p_CallBack",p_CallBack)
	_callBack = p_CallBack

	-- layer
	alertLayer = CCLayerColor:create(ccc4(0,0,0,155))
	alertLayer:registerScriptHandler(onNodeEvent)
	local runningScene = CCDirector:sharedDirector():getRunningScene()
	runningScene:addChild(alertLayer, 2000)

	-- 背景
	local fullRect = CCRectMake(0,0,213,171)
	local insetRect = CCRectMake(50,50,113,71)
	alertBg = CCScale9Sprite:create("images/common/viewbg1.png", fullRect, insetRect)
	alertBg:setPreferredSize(CCSizeMake(520, 460))
	alertBg:setAnchorPoint(ccp(0.5, 0.5))
	alertBg:setPosition(ccp(alertLayer:getContentSize().width*0.5, alertLayer:getContentSize().height*0.5))
	alertLayer:addChild(alertBg)
	alertBg:setScale(g_fScaleX)	

	local alertBgSize = alertBg:getContentSize()

	-- 关闭按钮bar
	local closeMenuBar = CCMenu:create()
	closeMenuBar:setPosition(ccp(0, 0))
	alertBg:addChild(closeMenuBar)
	closeMenuBar:setTouchPriority(-561)
	-- 关闭按钮
	local closeBtn = CCMenuItemImage:create("images/common/btn_close_n.png", "images/common/btn_close_h.png")
	closeBtn:registerScriptTapHandler(closeAction)
	closeBtn:setAnchorPoint(ccp(0.5, 0.5))
    closeBtn:setPosition(ccp(alertBg:getContentSize().width*0.95, alertBg:getContentSize().height*0.98))
	closeMenuBar:addChild(closeBtn)

	-- 标题
	local titleLabel = CCRenderLabel:create(GetLocalizeStringBy("key_3158"), g_sFontPangWa, 35, 1, ccc3( 0xff, 0xff, 0xff), type_stroke)
    titleLabel:setColor(ccc3(0x78, 0x25, 0x00))
    titleLabel:setAnchorPoint(ccp(0.5, 0.5))
    titleLabel:setPosition(ccp(alertBgSize.width*0.5, alertBgSize.height*0.8))
    alertBg:addChild(titleLabel)

	-- 描述
	local tipText = GetLocalizeStringBy("key_3209")
	local descLabel = CCLabelTTF:create(tipText, g_sFontName, 25, CCSizeMake(460, 120), kCCTextAlignmentCenter, kCCVerticalTextAlignmentTop)
	descLabel:setColor(ccc3(0x78, 0x25, 0x00))
	descLabel:setAnchorPoint(ccp(0.5, 0.5))
	descLabel:setPosition(ccp(alertBgSize.width * 0.5, alertBgSize.height*0.6))
	alertBg:addChild(descLabel)

	-- ICON
	local iconSprite = ItemSprite.getItemSpriteByItemId(stamina_template_id)
	iconSprite:setAnchorPoint(ccp(0.5, 0.5))
	iconSprite:setPosition(ccp(alertBg:getContentSize().width*0.5, alertBg:getContentSize().height*0.45))
	alertBg:addChild(iconSprite)
	-- 耐力+10
	local energyLabel = CCRenderLabel:create(GetLocalizeStringBy("key_2340"), g_sFontName, 20, 1, ccc3( 0x00, 0x00, 0x00), type_stroke)
    energyLabel:setColor(ccc3(0x36, 0xff, 0x00))
    energyLabel:setAnchorPoint(ccp(0.5, 1))
    energyLabel:setPosition(ccp(iconSprite:getContentSize().width*0.5, 0))
    iconSprite:addChild(energyLabel)

	-- 按钮
	local menuBar = CCMenu:create()
	menuBar:setPosition(ccp(0,0))
	menuBar:setTouchPriority(-561)
	alertBg:addChild(menuBar)

	-- 确认
	local confirmBtn = LuaCC.create9ScaleMenuItem("images/star/intimate/btn_blue_n.png", "images/star/intimate/btn_blue_h.png",CCSizeMake(160, 70), GetLocalizeStringBy("key_2745"), ccc3(0xfe, 0xdb, 0x1c),30,g_sFontPangWa,1, ccc3(0x00, 0x00, 0x00))
	confirmBtn:setAnchorPoint(ccp(0.5, 0.5))
    confirmBtn:registerScriptTapHandler(menuAction)
	menuBar:addChild(confirmBtn, 1, 10001)
	
	-- 取消
	local cancelBtn = LuaCC.create9ScaleMenuItem("images/star/intimate/btn_blue_n.png", "images/star/intimate/btn_blue_h.png",CCSizeMake(160, 70), GetLocalizeStringBy("key_2948"), ccc3(0xfe, 0xdb, 0x1c),30,g_sFontPangWa,1, ccc3(0x00, 0x00, 0x00))
	cancelBtn:setAnchorPoint(ccp(0.5, 0.5))
    cancelBtn:registerScriptTapHandler(menuAction)
	menuBar:addChild(cancelBtn, 1, 10002)

	confirmBtn:setPosition(ccp(alertBgSize.width*0.3, alertBgSize.height*0.2))
	cancelBtn:setPosition(ccp(alertBgSize.width*0.7, alertBgSize.height*0.2))

	
	require "db/DB_Goods"
	local goodsData = DB_Goods.getDataById(stamina_goods_id)
	local goldSp_2 = CCSprite:create("images/common/gold.png")
	goldSp_2:setAnchorPoint(ccp(0,0))
	goldSp_2:setPosition(ccp(alertBg:getContentSize().width*0.23, alertBg:getContentSize().height*0.065))
	alertBg:addChild(goldSp_2)

	-- 现价
	_curPrice = ShopUtil.getNeedGoldByGoodsAndTimes( goodsData.id, ShopUtil.getBuyNumBy(goodsData.id)+1)

	_curPriceLabel = CCRenderLabel:create(_curPrice, g_sFontName, 20, 1, ccc3(0x00, 0x00, 0x00), type_stroke)
    _curPriceLabel:setColor(ccc3(0xfe, 0xdb, 0x1c))
    _curPriceLabel:setAnchorPoint(ccp(0,0))
    _curPriceLabel:setPosition(ccp(alertBg:getContentSize().width*0.3, alertBg:getContentSize().height*0.07) )
    alertBg:addChild(_curPriceLabel)

    -- 拥有个数
	_curNumber = 0
	local cacheInfo = ItemUtil.getCacheItemInfoBy(stamina_template_id)
	if( not table.isEmpty(cacheInfo))then
		_curNumber = cacheInfo.item_num
	end
	
	_curHasLabel = CCRenderLabel:create(GetLocalizeStringBy("key_3413") .. _curNumber, g_sFontName, 20, 1, ccc3(0x00, 0x00, 0x00), type_stroke)
    _curHasLabel:setColor(ccc3(0xfe, 0xdb, 0x1c))
    _curHasLabel:setAnchorPoint(ccp(0,0))
    _curHasLabel:setPosition(ccp(alertBg:getContentSize().width*0.59, alertBg:getContentSize().height*0.07) )
    alertBg:addChild(_curHasLabel)
end



