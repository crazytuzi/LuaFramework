-- FileName: TravelShopBuyLayer.lua 
-- Author: fuqiongqiong
-- Date: 2016-6-12
-- Purpose: 云游商人批量购买

module("TravelShopBuyLayer",package.seeall)

require "script/ui/tip/AnimationTip"
require "script/ui/item/ItemUtil"
require "script/ui/tip/LackGoldTip"
-- require "script/ui/rechargeActive/travelShop/TravelShopLayer"

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

	    return true
    elseif (eventType == "moved") then
    	
    else

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

	if(ItemUtil.isBagFull() == true)then  --背包已满
		closeAction()  --出现一个音效
		return
	end
	if(tag == 10001) then  -- 10001确定按钮的tag
		--判断背包
        require "script/ui/item/ItemUtil"
        if(ItemUtil.isBagFull() == true )then
            return
        end
		-- -- 判断金币是否够
		local haveMony = 0
		if (_newPriceData.type == "silver")then
			haveMony = UserModel.getSilverNumber()
		elseif _newPriceData.type == "gold" then
			haveMony = UserModel.getGoldNumber()
		end
		if(_totalPrice <= haveMony) then  --当表中的价格小于等于玩家的钱
			local items = ItemUtil.getItemsDataByStr(_config.item)
			-- 批量的数量
			items[1].num = items[1].num*_curNumber
			local buy = function ()
				local rpcCallback = function ()
					TravelShopData.addScore(tonumber(_config.score))
					ItemUtil.addRewardByTable({{["type"] = _newPriceData.type, num = -_newPriceData.num*_curNumber}})
					require "script/ui/item/ReceiveReward"
			    	ReceiveReward.showRewardWindow(items, nil, nil, -510)
			    	TravelShopLayer.refresh()
			    	closeAction()
				end
				TravelShopService.buy(rpcCallback, _config.id, _curNumber)
			end
			-- if _newPriceData.type == "gold" then
			local richInfo = {
				elements = {
					{
						["type"] = "CCNode",
						create = function ( ... )
							return ItemUtil.getSmallSprite(_newPriceData)
						end
					},
					{
						text = _newPriceData.num*_curNumber
					},
					{
						text = items[1].num
					},
					{
						text = ItemUtil.getItemNameByTid(items[1].tid)
					}
				}
			}
			local newRichInfo = GetNewRichInfo(GetLocalizeStringBy("key_10315"), richInfo)
			local alertCallback = function ( isConfirm, _argsCB )
				if not isConfirm then
					return
				end
				buy()
			end
			RichAlertTip.showAlert(newRichInfo, alertCallback, true, nil, GetLocalizeStringBy("key_8129"), nil, nil, nil, nil, nil, nil, true)  --确定
			-- end
		else
			if (_newPriceData.type == "silver")then
				AnimationTip.showTip(GetLocalizeStringBy("fqq_120"))  --银币不足
			elseif _newPriceData.type == "gold" then
				-- AnimationTip.showTip(GetLocalizeStringBy("key_1092"))  --金币不足
				closeAction()
				LackGoldTip.showTip()
				print("buyAction LackGoldTip showTip")
			end
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
	if(_curNumber>_remainNum) then
		_curNumber = _remainNum
	end

	-- 个数
	_numberLabel:setString(_curNumber)
	_numberLabel:setPosition(ccp( (170 - _numberLabel:getContentSize().width)/2, (65 + _numberLabel:getContentSize().height)/2) )

	-- 总价 
	_totalPrice = tonumber(_newPriceData.num) * tonumber(_curNumber)
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
	-- if(tonumber(_itemType) == 1)then
		local itemData = ItemUtil.getItemsDataByStr(_config.item)[1]
		local icon, itemName, itemColor = ItemUtil.createGoodsIcon(itemData, -500, 10001, -500, nil,nil,nil,false)
		itemName = itemName
		local cacheInfo = ItemUtil.getCacheItemInfoBy(_config.id)
		if( not table.isEmpty(cacheInfo))then
			hasNumber = cacheInfo.item_num
		end
	-- elseif(tonumber(_itemType) == 2)then
	-- 	require "script/model/hero/HeroModel"
	-- 	itemName = _itemData.name
	-- 	local allHeroData = HeroModel.getAllByHtid(tostring(_itemData.id))
	-- 	if( not table.isEmpty(allHeroData))then
	-- 		hasNumber = table.count(allHeroData)
	-- 	end
	-- end

	-- 限购次数
	-- _maxLimitNum = HolidayHappyData.remainTimeOfBuy(_goodsData)
	   

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
	local str = ""
	if (_newPriceData.type == "silver")then
		str = GetLocalizeStringBy("fqq_115")
	elseif _newPriceData.type == "gold" then
		str = GetLocalizeStringBy("fqq_107")
	end
	local totalTipLabel = CCRenderLabel:create(str, g_sFontName, 36, 1, ccc3(0x49, 0x00, 0x00), type_stroke)
    totalTipLabel:setColor(ccc3(0xfe, 0xdb, 0x1c))
    totalTipLabel:setPosition(ccp(110, 72) )
    innerBgSp:addChild(totalTipLabel)
    local goldSp_2 = CCSprite:create("images/common/gold.png")
    if((_newPriceData.type == "silver"))then
    	goldSp_2 = CCSprite:create("images/common/coin_silver.png")
    end
	goldSp_2:setAnchorPoint(ccp(0,0))
	goldSp_2:setPosition(ccp(280, 35))
	innerBgSp:addChild(goldSp_2)
	_totalPrice = tonumber(_newPriceData.num)
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
	local titleLabel = CCLabelTTF:create(GetLocalizeStringBy("fqq_108"), g_sFontPangWa, 30)
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
function showPurchaseLayer( goods_id ,config)
	init()
	_config = config
	-- -- 选择的物品数据解析
	-- 商品数据
	_newPriceData = ItemUtil.getItemsDataByStr(_config.new_price)[1]
	print("_newPriceData=====")
	print_t(_newPriceData)
	local items = ItemUtil.getItemsDataByStr(config.item)

	_goodsData = config
	-- 兑换商品中物品的数据
	-- local item_type, item_id, item_num = HolidayHappyData.getItemData( _goodsData.discount )
	-- print("item_type",item_type,"item_id",item_id,"item_num",item_num)
	-- 物品类型 1是物品 2是英雄
	_itemType = _newPriceData.type
	-- 表中物品数据,物品图标
	local item_data = nil
	local iconSprite = nil
		require "script/ui/item/ItemUtil"
		_itemData = ItemUtil.getItemById(_config.id)
	
	_remainNum =  TravelShopData.getGoodsRemainBuyCount(nil, _config)
	_bglayer = CCLayerColor:create(ccc4(0,0,0,155))
	_bglayer:registerScriptHandler(onNodeEvent)
	local runningScene = CCDirector:sharedDirector():getRunningScene()
	runningScene:addChild(_bglayer, 1000)

	-- 创建背景
	createBg()
	-- 创建二级背景
	createInnerBg()
end
