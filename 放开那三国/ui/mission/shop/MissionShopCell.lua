-- FileName: MissonTaskCell.lua
-- Author: shengyixian
-- Date: 2015-08-28
-- Purpose: 悬赏榜商店表单元
module("MissionShopCell",package.seeall)

-- 触摸优先级
local _touchPriority = nil
-- 次数文本的内容
local _timeTxt = nil
--[[
	@des 	: 创建表单元
	@param 	: 
	@return : 
--]]
function createCell(i)
	local shopInfo = MissionShopData.getShopInfo()[i]
	print("shopInfo名望")
	print_t(shopInfo)
	-- body
	local tcell = CCTableViewCell:create()
	_touchPriority = -555
	_timeTxt = GetLocalizeStringBy("syx_1005",shopInfo.receiveTimes)
	if shopInfo.limitType == 2 then
		_timeTxt = GetLocalizeStringBy("syx_1006",shopInfo.receiveTimes)
	end

	-- 背景
	local cellBg = CCScale9Sprite:create("images/reward/cell_back.png")
	cellBg:setContentSize(CCSizeMake(442,164))
	tcell:addChild(cellBg)
	cellBg:setScale(g_fScaleX)

	-- 白底
	local itemBg= CCScale9Sprite:create("images/reward/item_back.png")
	itemBg:setAnchorPoint(ccp(0.5,0.5))
	itemBg:setContentSize(CCSizeMake(274,115))
	itemBg:setPosition(153,96)
	cellBg:addChild(itemBg)

	--“名望”文本
	local needFameLabel = CCRenderLabel:create(GetLocalizeStringBy("syx_1007"),g_sFontBold, 18, 1, ccc3( 0x00, 0x00, 0x00), type_stroke)
   	needFameLabel:setAnchorPoint(ccp(0,0))
   	needFameLabel:setColor(ccc3(0xff,0xf6,0x00))
   	needFameLabel:setPosition(ccp(138,80))
   	cellBg:addChild(needFameLabel)

	--名望值
	local fameValueLabel = CCRenderLabel:create(shopInfo.price,g_sFontBold, 18, 1, ccc3( 0x00, 0x00, 0x00), type_stroke)
   	fameValueLabel:setAnchorPoint(ccp(0,0))
   	fameValueLabel:setColor(ccc3( 0xff, 0xff, 0xff))
   	fameValueLabel:setPosition(ccp(needFameLabel:getPositionX() + needFameLabel:getContentSize().width,needFameLabel:getPositionY()))
   	cellBg:addChild(fameValueLabel)

	-- 兑换按钮
	local menu= CCMenu:create()
	menu:setPosition(ccp(0,0))
	menu:setTouchPriority(_touchPriority)
	cellBg:addChild(menu)
	local exchangeItem = CCMenuItemImage:create("images/common/btn/btn_blue_n.png","images/common/btn/btn_blue_h.png")
	exchangeItem:setAnchorPoint(ccp(0.5,0.5))
	exchangeItem:setPosition(360,80)
	menu:addChild(exchangeItem,1,i)
	--处理兑换
	exchangeItem:registerScriptTapHandler(exchangeHandler)
	
	-- “兑换”字体
	local item_font = CCRenderLabel:create(GetLocalizeStringBy("key_2689") , g_sFontPangWa, 30, 1, ccc3( 0x00, 0x00, 0x00), type_stroke)
    item_font:setColor(ccc3(0xfe, 0xdb, 0x1c))
    item_font:setAnchorPoint(ccp(0.5,0.5))
    item_font:setPosition(ccp(exchangeItem:getContentSize().width*0.5,exchangeItem:getContentSize().height*0.5))
   	exchangeItem:addChild(item_font)

   	-- 商品图标
   	local icon = ItemSprite.getItemSpriteById(tonumber(shopInfo.goodID),nil,nil,nil,_touchPriority - 10)
   	icon:setAnchorPoint(ccp(0.5,0.5))
   	icon:setPosition(ccp(72,96))
   	cellBg:addChild(icon)

   	-- 可兑换次数
   	local timeLabel = CCRenderLabel:create(_timeTxt,g_sFontBold, 18, 1, ccc3( 0x00, 0x00, 0x00), type_stroke)
   	timeLabel:setAnchorPoint(ccp(0,0))
   	timeLabel:setColor(ccc3(0x00,0xff,0x18))
   	timeLabel:setPosition(ccp(17,18))
   	cellBg:addChild(timeLabel)

   	-- 商品名称
   	local itemInfo = ItemUtil.getItemById(shopInfo.goodID)
   	local goodNameLabel = CCRenderLabel:create(itemInfo.name,g_sFontPangWa, 23, 1, ccc3( 0x00, 0x00, 0x00), type_stroke)
   	goodNameLabel:setColor(HeroPublicLua.getCCColorByStarLevel(itemInfo.quality))
   	goodNameLabel:setAnchorPoint(ccp(0.5,0.5))
   	goodNameLabel:setPosition(ccp(186,129))
   	cellBg:addChild(goodNameLabel)

   	-- 数量文本
   	local iconSize = icon:getContentSize()
   	local numLabel = CCRenderLabel:create(shopInfo.goodNum,g_sFontPangWa, 21, 1, ccc3( 0x00, 0x00, 0x00), type_stroke)
   	numLabel:setColor(ccc3( 0xff, 0xff, 0xff ))
   	numLabel:setAnchorPoint(ccp(1,0))
   	numLabel:setPosition(ccp(iconSize.width,0))
   	icon:addChild(numLabel)

   	if(shopInfo.receiveTimes < 1)then
   		exchangeItem:setVisible(false)
	    local hasReceiveItem = CCSprite:create("images/common/yiduihuan.png")
	    hasReceiveItem:setAnchorPoint(ccp(0.5,0.5))
	    hasReceiveItem:setPosition(ccp(360,80))
	    cellBg:addChild(hasReceiveItem) 
   	end
	return tcell
end
--[[
	@des 	: 兑换按钮回调函数
	@param 	: 
	@return : 
--]]
function exchangeHandler(tag,item)
	MissionShopController.exchange(tag,1,function (shopInfo)
		require "script/utils/SelectNumDialog"
		local dialog = SelectNumDialog:create()
		dialog:setTitle(GetLocalizeStringBy("lcyx_1910"))
		dialog:show(_touchPriority - 10,1000)
	    dialog:setMinNum(1)
	    local price = tonumber(shopInfo.price)
	    local maxNum = math.floor(UserModel.getFameNum() / price)
	    if(maxNum > tonumber(shopInfo.receiveTimes)) then
	    	maxNum = tonumber(shopInfo.receiveTimes)
	    end
	    if maxNum > 50 then
	    	maxNum = 50
	    end
	    dialog:setLimitNum(maxNum)

	    local size = dialog:getContentSize()
	    local nameLabelHeight = size.height*0.7
	    -- 商品名称
		local itemInfo = ItemUtil.getItemById(shopInfo.goodID)
		shopName = itemInfo.name
		local goodNameLabel = CCRenderLabel:create(shopName,g_sFontPangWa,33,1,ccc3(0,0x00,0x00))
		goodNameLabel:setColor(HeroPublicLua.getCCColorByStarLevel(itemInfo.quality))
		goodNameLabel:setAnchorPoint(ccp(0.5,0.5))
		goodNameLabel:setPosition(ccp(size.width / 2,nameLabelHeight + 4))
		dialog:addChild(goodNameLabel)
		local goodLabelSize = goodNameLabel:getContentSize()

		-- “请选择兑换”
		local label = CCRenderLabel:create(GetLocalizeStringBy("key_1438"),g_sFontPangWa,24,1,ccc3(0,0x00,0x00))
		label:setColor(ccc3(0xff,0xff,0xff))
		label:setAnchorPoint(ccp(0.5,0.5))
		label:setPosition(ccp(goodNameLabel:getPositionX() - goodLabelSize.width / 2 - label:getContentSize().width / 2 - 8,nameLabelHeight))
		dialog:addChild(label)
		-- "的数量"
		local label2 = CCRenderLabel:create(GetLocalizeStringBy("key_2518"),g_sFontPangWa,24,1,ccc3(0,0x00,0x00))
		label2:setColor(ccc3(0xff,0xff,0xff))
		label2:setAnchorPoint(ccp(0.5,0.5))
		label2:setPosition(ccp(goodNameLabel:getPositionX() + goodLabelSize.width / 2 + label2:getContentSize().width / 2 + 8,nameLabelHeight))
		dialog:addChild(label2)

		dialog:registerOkCallback(function ()
	      	local num = dialog:getNum()
	      	MissionShopController.buy(shopInfo, num)
	    end)
	    -- 需要的名望值文本
        local fameLabel = CCRenderLabel:create(GetLocalizeStringBy("syx_1008",shopInfo.price), g_sFontBold,18, 1, ccc3( 0x00, 0x00, 0x00), type_shadow)
	    fameLabel:setColor(ccc3( 0xff, 0xff, 0xff))
	    fameLabel:setAnchorPoint(ccp(0.5,0.5))
	    fameLabel:setPosition(size.width*0.5, size.height*0.3)
	    dialog:addChild(fameLabel)
	    dialog:registerChangeCallback(function ()
	    	fameLabel:setString(GetLocalizeStringBy("syx_1008",dialog:getNum() * price))
	    end)
	end)
end