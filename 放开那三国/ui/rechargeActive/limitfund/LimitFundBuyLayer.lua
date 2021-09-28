-- FileName: LimitFundBuyLayer.lua 
-- Author: fuqiongqiong
-- Date: 2016-9-14
-- Purpose: 限时基金批量购买界面

module("LimitFundBuyLayer",package.seeall)

require "script/ui/tip/AnimationTip"
require "script/ui/item/ItemUtil"
require "script/model/user/UserModel"

local  _bglayer 			= nil	
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
local _index			= nil
local _item_day 		= nil
local _item_gold		= nil
local _item_num			= nil
local _goldLable        = nil
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
	_item_day			= nil
 	_item_gold			= nil
 	_item_num			= nil
 	_goldLable			= nil
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
		_bglayer:registerScriptTouchHandler(onTouchesHandler, false, -740, true)
		_bglayer:setTouchEnabled(true)
	elseif (event == "exit") then
		_bglayer:unregisterScriptTouchHandler()
	end
end

-- 关闭
 function closeAction()
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

        	--判断背包
	        require "script/ui/item/ItemUtil"
	        if(ItemUtil.isBagFull() == true )then
	        	closeAction()
	            return
	        end
        	-- -- 判断积分是否够
			if(_totalPrice <= UserModel.getGoldNumber())then  --当表中的价格小于等于玩家的钱
				closeAction()
				-- local callBack = function ( ... )
				    	 local callbackFunc = function ( ... )
				            --扣积分
				            UserModel.addGoldNumber(-_totalPrice)
				            --修改缓存
				            LimitFundData.setInfoOfGoods(_index,tonumber(_curNumber))
				            -- 弹提示
				   --      local item_type, item_id, item_num = DevilTowerShopData.getItemData(_goodsData.items)
				   --      local daData = _goodsData.items
				   --      local itemTab = ItemUtil.getItemsDataByStr( daData)
				   --      local data = ItemUtil.getItemById(item_id)
				   --      local nameStr = _itemData.name
				   --      local nameColor = HeroPublicLua.getCCColorByStarLevel(5)
				   --      if( nameStr == nil)then
				   --          if tonumber(_itemData.id) >=  80001 and tonumber(_itemData.id) <= 90000 then
							-- 	--时装名称特殊处理
							-- 	nameStr = ItemSprite.getStringByFashionString(_itemData.name)
							-- elseif(tonumber(_itemData.id) >= 1800000 and tonumber(_itemData.id)<= 1900000 ) then
							-- 	-- 时装碎片
							-- 	nameStr = ItemSprite.getStringByFashionString(_itemData.name)
							-- else
						 --        nameStr = _itemData.name
						 --    end
						 --    nameColor = HeroPublicLua.getCCColorByStarLevel(_itemData.quality)
				   --      end
				        -- local textInfo= {
				        --     {tipText=nameStr .. "+" .. item_num*tonumber(_curNumber), color=nameColor},
				        -- }
				        -- AnimationTip.showRichTextTip(textInfo)
				        AnimationTip.showTip(GetLocalizeStringBy("fqq_154"))
				        -- itemTab[1].num = (itemTab[1].num)*_curNumber
				        -- ItemUtil.addRewardByTable(itemTab)  
			        	end
			        LimitFundController.buy(_goodsData.id,tonumber(_curNumber),callbackFunc)
		        
			else
				AnimationTip.showTip(GetLocalizeStringBy("fqq_078"))  --积分不足
			end
        -- end
		
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
		_maxLimitNum = LimitFundData.getMaxBuyTimes()
		print_t(_goodsData)
	
	print("_curNumber,_maxLimitNum",_curNumber,_maxLimitNum)
	if(_curNumber>_maxLimitNum) then
		_curNumber = _maxLimitNum
	end

	local jifen = UserModel.getGoldNumber()
	_totalPrice = tonumber(_goodsData.price) * tonumber(_curNumber)
	if(_totalPrice > jifen)then
		local num = jifen%tonumber(_goodsData.price)
		local jifenNum = jifen - num
		_curNumber = tonumber(jifenNum/tonumber(_goodsData.price))
		if(_curNumber == 0)then
			_curNumber = 1
		end
	end
	-- 个数
	_numberLabel:setString(_curNumber)
	_numberLabel:setPosition(ccp( (170 - _numberLabel:getContentSize().width)/2, (65 + _numberLabel:getContentSize().height)/2) )

	
	-- 总价 
	_totalPrice = tonumber(_goodsData.price) * tonumber(_curNumber)
	_totalPriceLabel:setString(_totalPrice)

	--返还金币量
	local returnGold = tonumber(_curNumber)*_item_gold
	_goldLable:setString(returnGold)
	-- end
end

-- create 背景2
local function createInnerBg()
	-- 背景2
	_innerBgSp = CCScale9Sprite:create("images/common/bg/bg_ng_attr.png")
	_innerBgSp:setContentSize(CCSizeMake(560, 360))
	_innerBgSp:setAnchorPoint(ccp(0.5, 0))
	_innerBgSp:setPosition(ccp(layerBg:getContentSize().width*0.5, 95))
	layerBg:addChild(_innerBgSp)

	local innerSize = _innerBgSp:getContentSize()
---- 准备数据
	-- 物品名字 和 已经拥有的数量
	local itemName = _goodsData.name
	-- local hasNumber = 0
	
		-- if tonumber(_itemData.id) >=  80001 and tonumber(_itemData.id) <= 90000 then
		-- 	--时装名称特殊处理
		-- 	itemName = ItemSprite.getStringByFashionString(_itemData.name)
		-- elseif(tonumber(_itemData.id) >= 1800000 and tonumber(_itemData.id)<= 1900000 ) then
		-- 	-- 时装碎片
		-- 	itemName = ItemSprite.getStringByFashionString(_itemData.name)
		-- else
	 --        itemName = _itemData.name
	 --    end

	--提示（最多能买x份）
      local richInfo = {
        	labelDefaultColor = ccc3( 0xff, 0xff, 0xff),
	        labelDefaultFont = g_sFontPangWa,
	        labelDefaultSize = 25,
	        defaultType = "CCRenderLabel",
            elements = {
                
                {
                    text = LimitFundData.getMaxBuyTimes(),
                    color = ccc3(0x00, 0xff, 0x18)
                }
            }
        }
	local newRichInfo = GetLocalizeLabelSpriteBy_2(GetLocalizeStringBy("fqq_152"), richInfo)
	newRichInfo:setColor(ccc3(0xfe, 0xdb, 0x1c))  
	newRichInfo:setAnchorPoint(ccp(0.5,1))
	newRichInfo:setPosition(ccp(_innerBgSp:getContentSize().width*0.5,_innerBgSp:getContentSize().height -15))
	 _innerBgSp:addChild(newRichInfo)  
    -- 兑换提示
    local buyTipLabel_1 = CCRenderLabel:create(GetLocalizeStringBy("fqq_163"), g_sFontName, 24, 1, ccc3(0x49, 0x00, 0x00), type_stroke)
    buyTipLabel_1:setColor(ccc3(0xff, 0xff, 0xff))
    _innerBgSp:addChild(buyTipLabel_1)

    -- 物品名称
    local nameLabel = CCRenderLabel:create(itemName, g_sFontPangWa, 30, 1, ccc3(0x49, 0x00, 0x00), type_stroke)
    nameLabel:setColor(ccc3(0xfe, 0xdb, 0x1c))
    nameLabel:setPosition(ccp( (innerSize.width-nameLabel:getContentSize().width)/2, 270) )
    _innerBgSp:addChild(nameLabel)
    buyTipLabel_1:setPosition(ccp( (innerSize.width-nameLabel:getContentSize().width)/2 -buyTipLabel_1:getContentSize().width , 260) )

    -- 兑换提示2
    local buyTipLabel_2 = CCRenderLabel:create(GetLocalizeStringBy("fqq_164"), g_sFontName, 24, 1, ccc3(0x49, 0x00, 0x00), type_stroke)
    buyTipLabel_2:setColor(ccc3(0xff, 0xff, 0xff))
    buyTipLabel_2:setPosition(ccp( innerSize.width/2 + nameLabel:getContentSize().width/2, 260) )
    _innerBgSp:addChild(buyTipLabel_2)

---- 加减道具的按钮
	local changeNumBar = CCMenu:create()
	changeNumBar:setPosition(ccp(0,0))
	changeNumBar:setTouchPriority(-750)
	_innerBgSp:addChild(changeNumBar)

	-- -10
	local reduce10Btn = CCMenuItemImage:create("images/shop/prop/btn_reduce10_n.png", "images/shop/prop/btn_reduce10_h.png")
	reduce10Btn:setPosition(ccp(4, 140))
	reduce10Btn:registerScriptTapHandler(changeNumberAction)
	changeNumBar:addChild(reduce10Btn, 1, 10001)

	-- -1
	local reduce1Btn = CCMenuItemImage:create("images/shop/prop/btn_reduce_n.png", "images/shop/prop/btn_reduce_h.png")
	reduce1Btn:setPosition(ccp(123, 140))
	reduce1Btn:registerScriptTapHandler(changeNumberAction)
	changeNumBar:addChild(reduce1Btn, 1, 10002)

	-- 数量背景
	local numberBg = CCScale9Sprite:create("images/common/checkbg.png")
	numberBg:setContentSize(CCSizeMake(170, 75))
	numberBg:setAnchorPoint(ccp(0.5, 0))
	numberBg:setPosition(ccp(_innerBgSp:getContentSize().width*0.5, 135))
	_innerBgSp:addChild(numberBg)
	-- 数量数字
	_numberLabel = CCRenderLabel:create("1", g_sFontPangWa, 36, 1, ccc3(0x49, 0x00, 0x00), type_stroke)
    _numberLabel:setColor(ccc3(0xff, 0xff, 0xff))
    _numberLabel:setPosition(ccp( (numberBg:getContentSize().width - _numberLabel:getContentSize().width)/2, (numberBg:getContentSize().height + _numberLabel:getContentSize().height)/2) )
    numberBg:addChild(_numberLabel)

	-- +1
	local reduce1Btn = CCMenuItemImage:create("images/shop/prop/btn_addition_n.png", "images/shop/prop/btn_addition_h.png")
	reduce1Btn:setPosition(ccp(370, 140))
	reduce1Btn:registerScriptTapHandler(changeNumberAction)
	changeNumBar:addChild(reduce1Btn, 1, 10003)

	-- +10
	local reduce10Btn = CCMenuItemImage:create("images/shop/prop/btn_addition10_n.png", "images/shop/prop/btn_addition10_h.png")
	reduce10Btn:setPosition(ccp(445, 140))
	reduce10Btn:registerScriptTapHandler(changeNumberAction)
	changeNumBar:addChild(reduce10Btn, 1, 10004)


	--返还方式
	local returnLable = CCRenderLabel:create(GetLocalizeStringBy("fqq_153"), g_sFontPangWa, 20, 1, ccc3(0x49, 0x00, 0x00), type_stroke)
    returnLable:setColor(ccc3(0xfe, 0xdb, 0x1c))
    returnLable:setAnchorPoint(ccp(0,1))
    returnLable:setPosition(ccp(_innerBgSp:getContentSize().width*0.08,125))
    _innerBgSp:addChild(returnLable)
   	
   	local dayLable = CCRenderLabel:create(_item_day.."天返还", g_sFontPangWa, 20, 1, ccc3(0x49, 0x00, 0x00), type_stroke)
    dayLable:setColor(ccc3(0xfe, 0xdb, 0x1c))
    dayLable:setAnchorPoint(ccp(0,0.5))
    dayLable:setPosition(ccp(returnLable:getContentSize().width,returnLable:getContentSize().height*0.5))
    returnLable:addChild(dayLable)
    _goldLable = CCRenderLabel:create(_item_gold, g_sFontPangWa, 20, 1, ccc3(0x49, 0x00, 0x00), type_stroke)
    _goldLable:setColor(ccc3(0xfe, 0xdb, 0x1c))
    _goldLable:setAnchorPoint(ccp(0,0.5))
    _goldLable:setPosition(ccp(returnLable:getContentSize().width+dayLable:getContentSize().width+10,returnLable:getContentSize().height*0.5))
    returnLable:addChild(_goldLable)
    local timesLable = CCRenderLabel:create("金币,返".._item_num.."次", g_sFontPangWa, 20, 1, ccc3(0x49, 0x00, 0x00), type_stroke)
    timesLable:setColor(ccc3(0xfe, 0xdb, 0x1c))
    timesLable:setAnchorPoint(ccp(0,0.5))
    timesLable:setPosition(ccp(returnLable:getContentSize().width+dayLable:getContentSize().width+_goldLable:getContentSize().width+30,returnLable:getContentSize().height*0.5))
    returnLable:addChild(timesLable)
	-- 总价
	local totalTipLabel = CCRenderLabel:create(GetLocalizeStringBy("fqq_165"), g_sFontName, 34, 1, ccc3(0x49, 0x00, 0x00), type_stroke)
    totalTipLabel:setColor(ccc3(0xfe, 0xdb, 0x1c))
    totalTipLabel:setPosition(ccp(190, 50) )
    _innerBgSp:addChild(totalTipLabel)
     local goldSp_2 = CCSprite:create("images/common/gold.png")
	goldSp_2:setAnchorPoint(ccp(0,0))
	goldSp_2:setPosition(ccp(278,20))
	_innerBgSp:addChild(goldSp_2)
  -- price
	_totalPrice = tonumber(_goodsData.price)
	_totalPriceLabel = CCRenderLabel:create(_totalPrice, g_sFontName, 34, 1, ccc3(0x49, 0x00, 0x00), type_stroke)
    _totalPriceLabel:setColor(ccc3(0xfe, 0xdb, 0x1c))
    _totalPriceLabel:setPosition(ccp(310, 50) )
    _innerBgSp:addChild(_totalPriceLabel)

    -- local totalTipLabel_1 = CCRenderLabel:create(GetLocalizeStringBy("key_8039"), g_sFontName, 36, 1, ccc3(0x49, 0x00, 0x00), type_stroke)
    -- totalTipLabel_1:setColor(ccc3(0xfe, 0xdb, 0x1c))
    -- totalTipLabel_1:setAnchorPoint(ccp(0,0.5))
    -- totalTipLabel_1:setPosition(ccp(_totalPriceLabel:getContentSize().width, totalTipLabel:getContentSize().height*0.5) )
    -- _totalPriceLabel:addChild(totalTipLabel_1)
	
	
end

-- create
local function createBg( )
	-- 背景
	layerBg = CCScale9Sprite:create("images/formation/changeformation/bg.png")
	layerBg:setContentSize(CCSizeMake(610, 510))
	layerBg:setAnchorPoint(ccp(0.5, 0.5))
	layerBg:setPosition(ccp(_bglayer:getContentSize().width*0.5, _bglayer:getContentSize().height*0.5))
	_bglayer:addChild(layerBg)
	layerBg:setScale(g_fScaleX)	

	local titleSp = CCSprite:create("images/formation/changeformation/titlebg.png")
	titleSp:setAnchorPoint(ccp(0.5,0.5))
	titleSp:setPosition(ccp(layerBg:getContentSize().width/2, layerBg:getContentSize().height*0.985))
	layerBg:addChild(titleSp)

	local titleLabel = CCLabelTTF:create(GetLocalizeStringBy("fqq_151"), g_sFontPangWa, 30)
	titleLabel:setColor(ccc3(0xff, 0xe4, 0x00))
	titleLabel:setAnchorPoint(ccp(0.5, 0.5))
	titleLabel:setPosition(ccp(titleSp:getContentSize().width/2, titleSp:getContentSize().height/2))
	titleSp:addChild(titleLabel)

	-- 关闭按钮bar
	local closeMenuBar = CCMenu:create()
	closeMenuBar:setPosition(ccp(0, 0))
	layerBg:addChild(closeMenuBar)
	closeMenuBar:setTouchPriority(-750)
	-- 关闭按钮
	local closeBtn = LuaMenuItem.createItemImage("images/common/btn_close_n.png", "images/common/btn_close_h.png", closeAction )
	closeBtn:setAnchorPoint(ccp(0.5, 0.5))
    closeBtn:setPosition(ccp(layerBg:getContentSize().width*0.97, layerBg:getContentSize().height*0.98))
	closeMenuBar:addChild(closeBtn)

	local buyMenuBar = CCMenu:create()
	buyMenuBar:setPosition(ccp(0,0))
	buyMenuBar:setTouchPriority(-750)
	layerBg:addChild(buyMenuBar)

	-- 按钮
	local comfirmBtn = LuaCC.create9ScaleMenuItem("images/star/intimate/btn_blue_n.png", "images/star/intimate/btn_blue_h.png",CCSizeMake(140, 70), GetLocalizeStringBy("key_1985"),ccc3(0xfe, 0xdb, 0x1c),30,g_sFontPangWa,1, ccc3(0x00, 0x00, 0x00))
	comfirmBtn:setAnchorPoint(ccp(0, 0))
	comfirmBtn:setPosition(ccp(125, 22	))
	comfirmBtn:registerScriptTapHandler(buyAction)
	buyMenuBar:addChild(comfirmBtn, 1, 10001)

	local cancelBtn = LuaCC.create9ScaleMenuItem("images/star/intimate/btn_blue_n.png", "images/star/intimate/btn_blue_h.png",CCSizeMake(140, 70), GetLocalizeStringBy("key_1202"),ccc3(0xfe, 0xdb, 0x1c),30,g_sFontPangWa,1, ccc3(0x00, 0x00, 0x00))
	cancelBtn:setAnchorPoint(ccp(0, 0))
	cancelBtn:setPosition(ccp(350, 22))
	cancelBtn:registerScriptTapHandler(buyAction)
	buyMenuBar:addChild(cancelBtn, 1, 10002)

end 

-- showPurchaseLayer
function showPurchaseLayer( tag)
	init()
	require "script/ui/rechargeActive/limitfund/LimitFundData"
	-- 商品数据
	_goodsData = LimitFundData.getLimitFundInfoById(tag)
	_index = tag
	-- 兑换商品中物品的数据
	_item_day, _item_gold, _item_num = LimitFundData.getItemData(_goodsData.explain)
	-- -- 表中物品数据,物品图标
	-- local item_data = nil
	-- local iconSprite = nil
	-- _itemData = ItemUtil.getItemById(item_id)
	_bglayer = CCLayerColor:create(ccc4(0,0,0,155))
	_bglayer:registerScriptHandler(onNodeEvent)
	local runningScene = CCDirector:sharedDirector():getRunningScene()
	runningScene:addChild(_bglayer, 1010)

	-- 创建背景
	createBg()
	-- 创建二级背景
	createInnerBg()
end

function getExitBuyLayer( ... )
	local isExit = false
	if(_bglayer)then
		isExit = true
	end
	return isExit
end