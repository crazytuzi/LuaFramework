-- FileName: HolidayHappyBuyLayer.lua 
-- Author: fuqiongqiong
-- Date: 2016-6-3
-- Purpose: 节日狂欢批量购买

module("HolidayHappyBuyLayer",package.seeall)

require "script/ui/tip/AnimationTip"
require "script/ui/item/ItemUtil"


local _bglayer 			= nil	
local _goodsData 		= nil				-- 商品数据			
local _itemData 		= nil				-- 物品类型 
local layerBg			= nil
local _numberLabel 		= nil
local _totalPriceLabel 	= nil
local _maxLimitNum 		= 0
local _curNumber 		= 1
local _totalPrice 		= 0	
local _taskType         = nil
local _innerBgSp		= nil
local kTaskOne = 1                        -- 限时折扣
local kTaskTwo = 2                        -- 限时兑换
local function init( )
	_bglayer 			= nil
	_goodsData 			= nil
	_itemData 			= nil
	_itemType 			= nil
	layerBg				= nil
	_numberLabel 		= nil
	_totalPriceLabel 	= nil
	_taskType           = nil
	_innerBgSp			= nil
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
		_bglayer:registerScriptTouchHandler(onTouchesHandler, false, -631, true)
		_bglayer:setTouchEnabled(true)
	elseif (event == "exit") then
		_bglayer:unregisterScriptTouchHandler()
	end
end

-- 关闭
local function closeAction()
	-- 音效
	require "script/audio/AudioUtil"
	AudioUtil.playEffect("audio/effect/guanbi.mp3")
	if(_bglayer)then
		_bglayer:removeFromParentAndCleanup(true)
		_bglayer = nil
	end	
end 

-- 按钮响应
function buyAction( tag, itemBtn )
	-- 音效
	require "script/audio/AudioUtil"
	AudioUtil.playEffect("audio/effect/zhujiemian.mp3")

	-- if(ItemUtil.isBagFull() == true)then  --背包已满
	-- 	closeAction()  
	-- 	return
	-- end
	if(tag == 10001) then  -- 10001确定按钮的tag

        if(_taskType == kTaskTwo)then
        	--判断背包
	        require "script/ui/item/ItemUtil"
	        if(ItemUtil.isBagFull() == true )then
	        	closeAction()
	        	HolidayHappyLimitExchargeLayer.closeCallback()
	            return
	        end
        	local need =string.split(_goodsData.need,",")
			for i=1,#need do
				local  item_type, item_id, item_num = HolidayHappyData.getItemData( need[i] )
				--数量是否足够
	        	local allNum = ItemUtil.getCacheItemNumBy(item_id)
	        	if(allNum < item_num*tonumber(_curNumber))then
	        		AnimationTip.showTip(GetLocalizeStringBy("fqq_124"))
	        		-- closeAction()
	        		return
	        	end
			end
			closeAction()
	        local callBack = function ()
	        -- 弹提示
	        local daData = _goodsData.exchange
	        local itemTab = ItemUtil.getItemsDataByStr( daData)
	        local nameStr = itemTab[1].name
	        local nameColor = HeroPublicLua.getCCColorByStarLevel(5)
	        if( nameStr == nil)then
	            if tonumber(_itemData.id) >=  80001 and tonumber(_itemData.id) <= 90000 then
					--时装名称特殊处理
					nameStr = ItemSprite.getStringByFashionString(_itemData.name)
				elseif(tonumber(_itemData.id) >= 1800000 and tonumber(_itemData.id)<= 1900000 ) then
					-- 时装碎片
					nameStr = ItemSprite.getStringByFashionString(_itemData.name)
				else
			        nameStr = _itemData.name
			    end
			    nameColor = HeroPublicLua.getCCColorByStarLevel(_itemData.quality)
	        end
	        local textInfo= {
	            {tipText=nameStr .. "+" .. itemTab[1].num*tonumber(_curNumber), color=nameColor},
	        }
	        AnimationTip.showRichTextTip(textInfo)
	        itemTab[1].num = (itemTab[1].num)*_curNumber
	        ItemUtil.addRewardByTable(itemTab)
	       	
	    end
	    HolidayHappyController.exchange(_goodsData.id,_curNumber,callBack)

        else
        	--判断背包
	        require "script/ui/item/ItemUtil"
	        if(ItemUtil.isBagFull() == true )then
	        	closeAction()
	            return
	        end
        	-- -- 判断金币是否够
			if(_totalPrice <= UserModel.getGoldNumber()) then  --当表中的价格小于等于玩家的钱
				closeAction()
				local callBack = function ( ... )
				    	 local callbackFunc = function ( ... )
				            --扣金币
				            UserModel.addGoldNumber(-_totalPrice)
				            --修改缓存
				            HolidayHappyData.setNumOfBuy(_goodsData.id,tonumber(_curNumber))  
			        	end
			        HolidayHappyController.buy(_goodsData.id,tonumber(_curNumber),callbackFunc)
		        	end
					
			            -- 提示
			        local richInfo = {
			            elements = {
			                
			                {
			                    text = _totalPrice
			                },
			                {
			                    ["type"] = "CCSprite",
			                    image = "images/common/gold.png"
			                 }
			            }
			        }
			        local newRichInfo = GetNewRichInfo(GetLocalizeStringBy("fqq_091"), richInfo)  
			        local alertCallback = function ( isConfirm, _argsCB )
			            if not isConfirm then
			                return
			            end   
			            callBack()
			        end
			        require "script/ui/tip/RichAlertTip"
			        RichAlertTip.showAlert(newRichInfo, alertCallback, true, nil, GetLocalizeStringBy("key_8129"), nil, nil, nil, nil)
			else
				AnimationTip.showTip(GetLocalizeStringBy("key_1092"))  --金币不足
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
	if(_taskType == kTaskTwo)then
		_maxLimitNum = tonumber(_goodsData.exchangetime)-HolidayHappyData.getAlreadyExchangeTimes(_goodsData.id)
		print_t(_goodsData)
	else
		-- 限购次数
		local seasonNumOfClick = HolidayHappyLayer.getSeasonNumOfClick()
		_maxLimitNum = HolidayHappyData.remainTimeOfBuy(_goodsData,seasonNumOfClick)
	end
	print("_curNumber,_maxLimitNum",_curNumber,_maxLimitNum)
	if(_curNumber>_maxLimitNum) then
		_curNumber = _maxLimitNum
	end

	-- 个数
	_numberLabel:setString(_curNumber)
	_numberLabel:setPosition(ccp( (170 - _numberLabel:getContentSize().width)/2, (65 + _numberLabel:getContentSize().height)/2) )

	if(_taskType == kTaskTwo)then
		-- local need =string.split(_goodsData.need,",")
		-- for i=1,#need do
		-- 	local  item_type, item_id, item_num = HolidayHappyData.getItemData( need[i] )
		-- 	local priceSprite = _innerBgSp:getChildByTag(300+i)
		-- 	local totalPrice = item_num*tonumber(_curNumber)
		-- 	local priceSprite = _innerBgSp:getChildByTag(300+i)
		-- 	if(priceSprite)then
		-- 		priceSprite:setString(totalPrice)
		-- 	end
		-- end		
	else
	-- 总价 
	_totalPrice = tonumber((HolidayHappyData.getMoneyCost(_goodsData.cost))[2]) * tonumber(_curNumber)
	_totalPriceLabel:setString(_totalPrice)
	end
end

-- create 背景2
local function createInnerBg()
	-- 背景2
	_innerBgSp = CCScale9Sprite:create("images/common/bg/bg_ng_attr.png")
	_innerBgSp:setContentSize(CCSizeMake(560, 330))
	_innerBgSp:setAnchorPoint(ccp(0.5, 0))
	_innerBgSp:setPosition(ccp(layerBg:getContentSize().width*0.5, 110))
	layerBg:addChild(_innerBgSp)

	local innerSize = _innerBgSp:getContentSize()
---- 准备数据
	-- 物品名字 和 已经拥有的数量
	local itemName = ""
	-- local hasNumber = 0
	if(table.isEmpty(_itemData))then
		itemName = GetLocalizeStringBy("fqq_122")
	else
		if tonumber(_itemData.id) >=  80001 and tonumber(_itemData.id) <= 90000 then
			--时装名称特殊处理
			itemName = ItemSprite.getStringByFashionString(_itemData.name)
		elseif(tonumber(_itemData.id) >= 1800000 and tonumber(_itemData.id)<= 1900000 ) then
			-- 时装碎片
			itemName = ItemSprite.getStringByFashionString(_itemData.name)
		else
	        itemName = _itemData.name
	    end
	end
		
		-- local cacheInfo = ItemUtil.getCacheItemInfoBy(_itemData.id)
		-- if( not table.isEmpty(cacheInfo))then
		-- 	hasNumber = cacheInfo.item_num
		-- end
	
	
	   

    -- 兑换提示
    local buyTipLabel_1 = CCRenderLabel:create(GetLocalizeStringBy("key_1438"), g_sFontName, 24, 1, ccc3(0x49, 0x00, 0x00), type_stroke)
    buyTipLabel_1:setColor(ccc3(0xff, 0xff, 0xff))
    _innerBgSp:addChild(buyTipLabel_1)

    -- 物品名称
    local nameLabel = CCRenderLabel:create(itemName, g_sFontPangWa, 30, 1, ccc3(0x49, 0x00, 0x00), type_stroke)
    nameLabel:setColor(ccc3(0xfe, 0xdb, 0x1c))
    nameLabel:setPosition(ccp( (innerSize.width-nameLabel:getContentSize().width)/2, 250) )
    _innerBgSp:addChild(nameLabel)
    buyTipLabel_1:setPosition(ccp( (innerSize.width-nameLabel:getContentSize().width)/2 -buyTipLabel_1:getContentSize().width , 240) )

    -- 兑换提示2
    local buyTipLabel_2 = CCRenderLabel:create(GetLocalizeStringBy("key_3113"), g_sFontName, 24, 1, ccc3(0x49, 0x00, 0x00), type_stroke)
    buyTipLabel_2:setColor(ccc3(0xff, 0xff, 0xff))
    buyTipLabel_2:setPosition(ccp( innerSize.width/2 + nameLabel:getContentSize().width/2, 240) )
    _innerBgSp:addChild(buyTipLabel_2)

---- 加减道具的按钮
	local changeNumBar = CCMenu:create()
	changeNumBar:setPosition(ccp(0,0))
	changeNumBar:setTouchPriority(-645)
	_innerBgSp:addChild(changeNumBar)

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
	numberBg:setPosition(ccp(_innerBgSp:getContentSize().width*0.5, 110))
	_innerBgSp:addChild(numberBg)
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
	--先做下标记，后期限时兑换加批量，此处要有改动
	if(_taskType == kTaskTwo)then
		-- local need =string.split(_goodsData.need,",")
		-- for i=1,#need do
		-- 	local  item_type, item_id, item_num = HolidayHappyData.getItemData( need[i] )
		-- 	local totalTipLabel = CCRenderLabel:create(GetLocalizeStringBy("fqq_121"), g_sFontName, 36, 1, ccc3(0x49, 0x00, 0x00), type_stroke)
		--     totalTipLabel:setColor(ccc3(0xfe, 0xdb, 0x1c))
		--     totalTipLabel:setPosition(ccp(50+totalTipLabel:getContentSize().width*(i-1)*4, 72) )
		--     _innerBgSp:addChild(totalTipLabel)
		--     local goldSp_2 = ItemSprite.getItemSpriteById(item_id)
		--     goldSp_2:setScale(0.5)
		-- 	goldSp_2:setAnchorPoint(ccp(0,0.5))
		-- 	goldSp_2:setPosition(ccp(totalTipLabel:getContentSize().width, totalTipLabel:getContentSize().height*0.5))
		-- 	totalTipLabel:addChild(goldSp_2)
		-- 	local totalPrice = tonumber(item_num)
		-- 	local totalPriceLabel = CCRenderLabel:create(totalPrice, g_sFontName, 36, 1, ccc3(0x49, 0x00, 0x00), type_stroke)
		--     totalPriceLabel:setColor(ccc3(0xfe, 0xdb, 0x1c))
		--     totalPriceLabel:setPosition(ccp(50+totalTipLabel:getContentSize().width+goldSp_2:getContentSize().width*0.5+totalTipLabel:getContentSize().width*4*(i-1), 70) )
		--     _innerBgSp:addChild(totalPriceLabel,1,300+i)
		--  end 
		
	else
		local totalTipLabel = CCRenderLabel:create(GetLocalizeStringBy("fqq_107"), g_sFontName, 36, 1, ccc3(0x49, 0x00, 0x00), type_stroke)
	    totalTipLabel:setColor(ccc3(0xfe, 0xdb, 0x1c))
	    totalTipLabel:setPosition(ccp(110, 72) )
	    _innerBgSp:addChild(totalTipLabel)
	    local goldSp_2 = CCSprite:create("images/common/gold.png")
		goldSp_2:setAnchorPoint(ccp(0,0))
		goldSp_2:setPosition(ccp(280, 35))
		_innerBgSp:addChild(goldSp_2)
		_totalPrice = tonumber((HolidayHappyData.getMoneyCost(_goodsData.cost))[2])
		_totalPriceLabel = CCRenderLabel:create(_totalPrice, g_sFontName, 36, 1, ccc3(0x49, 0x00, 0x00), type_stroke)
	    _totalPriceLabel:setColor(ccc3(0xfe, 0xdb, 0x1c))
	    _totalPriceLabel:setPosition(ccp(310, 70) )
	    _innerBgSp:addChild(_totalPriceLabel)
	end
	
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
	closeMenuBar:setTouchPriority(-645)
	-- 关闭按钮
	local closeBtn = LuaMenuItem.createItemImage("images/common/btn_close_n.png", "images/common/btn_close_h.png", closeAction )
	closeBtn:setAnchorPoint(ccp(0.5, 0.5))
    closeBtn:setPosition(ccp(layerBg:getContentSize().width*0.97, layerBg:getContentSize().height*0.98))
	closeMenuBar:addChild(closeBtn)

	local buyMenuBar = CCMenu:create()
	buyMenuBar:setPosition(ccp(0,0))
	buyMenuBar:setTouchPriority(-645)
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
function showPurchaseLayer( goods_id ,taskType)
	init()
	_taskType = taskType
	--限时折扣
	require "script/ui/holidayhappy/HolidayHappyData"
	-- 商品数据
	_goodsData = HolidayHappyData.getDataOfFestival_rewardByTaskId(goods_id)
	
	-- 兑换商品中物品的数据
	local item_type, item_id, item_num = HolidayHappyData.getItemData( _goodsData.discount )
	if(_taskType == kTaskTwo)then
		item_type, item_id, item_num = HolidayHappyData.getItemData( _goodsData.exchange )
	end
	-- 物品类型 1是物品 2是英雄
	_itemType = item_type
	-- 表中物品数据,物品图标
	local item_data = nil
	local iconSprite = nil
	require "script/ui/item/ItemUtil"
	_itemData = ItemUtil.getItemById(item_id)
	print("_itemData=====")
	print_t(_itemData)
	_bglayer = CCLayerColor:create(ccc4(0,0,0,155))
	_bglayer:registerScriptHandler(onNodeEvent)
	local runningScene = CCDirector:sharedDirector():getRunningScene()
	runningScene:addChild(_bglayer, 499)

	-- 创建背景
	createBg()
	-- 创建二级背景
	createInnerBg()
end