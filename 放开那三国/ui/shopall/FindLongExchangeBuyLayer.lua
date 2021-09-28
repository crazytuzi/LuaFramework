-- FileName: ExchangeBuyLayer.lua 
-- Author: FQQ
-- Date: 2015-09-07 
-- Purpose: function description of module 


module("FindLongExchangeBuyLayer", package.seeall)


require "script/ui/tip/AnimationTip"
require "script/ui/item/ItemUtil"
require "script/ui/shopall/FindLongExchangeCache"

local _bglayer 			= nil	
local _goodsData 		= nil				-- 物品兑换配置表数据			
local _itemData 		= nil				-- 物品信息 
local _itemType 		= nil				-- 物品类型 1是物品 2是英雄
local layerBg			= nil
local _numberLabel 		= nil
local _totalPriceLabel 	= nil
local _maxLimitNum 		= 0
local _curNumber 		= 1
local _totalPrice 		= 0
local _touchPriority 	= nil

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
		_bglayer:registerScriptTouchHandler(onTouchesHandler, false, _touchPriority - 1, true)
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

function buySuccessful()
	----实时改变本地数据
	--增加本地数据（已通过推送自动增加）... 略
	
	-- 改变寻龙积分兑换表格单元中的剩余兑换次数
	local remainExchangeNum = _goodsData.remainExchangeNum - _curNumber
	--直接存入FindLongExchangeCache中的数据表中？？
	_goodsData.remainExchangeNum = remainExchangeNum
	require "script/ui/shopall/FindLongExchangeCell"
	local strSp = FindLongExchangeCell.getCanExchangeNumSp()
	local str = _goodsData.limitType == 1 and GetLocalizeStringBy("zz_3",remainExchangeNum) or GetLocalizeStringBy("zz_9",remainExchangeNum)
	strSp:setString(str)

	print("removeCellAtIndex outside ...")
	

	--改变FindLongExchangeLayer中的当前寻龙积分
	local curFindDragonNum = FindLongExchangeLayer.getFindDrogonNum() - _totalPrice
	FindLongExchangeLayer.setFindDrogonNum(curFindDragonNum)

	--购买成功后的提示
	local itemsTable = _goodsData.itemsTable
	local item_type, item_id, item_num = itemsTable.type, itemsTable.tid, itemsTable.num
	AnimationTip.showTip(GetLocalizeStringBy("key_1004") .. GetLocalizeStringBy("key_1984") .. _curNumber*item_num .. GetLocalizeStringBy("key_2557") .. _itemData.name )
	if remainExchangeNum < 1 then
		print("小于0刷新")
		-- print("removeCellAtIndex inside ...")
		-- local tableView = tolua.cast(FindLongExchangeLayer.getExchangeInfoLayer():getChildByTag(100),TOLUA_CAST_TABLEVIEW)
		FindLongExchangeLayer.updataTableView()
		-- tableView:reloadData()
	end
	-- 关闭当前界面
	closeAction()
end

-- 按钮响应
function buyAction( tag, itemBtn )
	-- 音效
	require "script/audio/AudioUtil"
	AudioUtil.playEffect("audio/effect/zhujiemian.mp3")
	if(ItemUtil.isBagFull() == true)then
		closeAction()
		return
	end

	local findDrogonNum = FindLongExchangeLayer.getFindDrogonNum()
	if(tag == 10001) then
		-- 判断寻龙积分值是否够
		if(_totalPrice <= findDrogonNum) then
	    	-- 点击领取按钮事件处理方法中服务器数据返回后的回调函数
			local function buyCb(cbFlag, dictData, bRet)
				if bRet == false then return end
				buySuccessful()
			end
			local args = CCArray:create()
			args:addObject(CCInteger:create(tonumber(_goodsData.id)))
			print("寻龙积分兑换数量: ",_curNumber)
			args:addObject(CCInteger:create(tonumber(_curNumber)))
			FindLongExchangeCache.addUserServerData(buyCb,args)
		else
			AnimationTip.showTip(GetLocalizeStringBy("zz_6"))
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
	
	-- 根据当前寻龙积分和兑换单价确定能够兑换的最大兑换数量
	local canBuyNum = math.floor(FindLongExchangeLayer.getFindDrogonNum() / tonumber(_goodsData.costPrestige))
	local max = _maxLimitNum < canBuyNum and _maxLimitNum or canBuyNum
	if(_curNumber>max) then
		_curNumber = max
	end

	--兑换需要其它物品材料时，兑换数量不能超过材料物品数量
	if _goodsData.needItem ~= nil then
		local canExchangeNumber = math.floor(ItemUtil.getCacheItemNumBy(_goodsData.needItem.tid)/_goodsData.needItem.num)
		_curNumber = _curNumber < canExchangeNumber and _curNumber or canExchangeNumber
	end

	-- 个数
	_numberLabel:setString(_curNumber)
	_numberLabel:setPosition(ccp( (170 - _numberLabel:getContentSize().width)/2, (65 + _numberLabel:getContentSize().height)/2) )

	-- 总价
	_totalPrice = tonumber(_goodsData.costPrestige) * tonumber(_curNumber)
	_totalPriceLabel:setString(_totalPrice)
end

-- create 背景2
local function createInnerBg(p_touch)
	-- 背景2
	local innerBgSp = CCScale9Sprite:create("images/common/bg/bg_ng_attr.png")
	innerBgSp:setContentSize(CCSizeMake(560, 330))
	innerBgSp:setAnchorPoint(ccp(0.5, 0))
	innerBgSp:setPosition(ccp(layerBg:getContentSize().width*0.5, 110))
	layerBg:addChild(innerBgSp,1,10)

	local innerSize = innerBgSp:getContentSize()
---- 准备数据
	-- 物品名字 和 已经拥有的数量
	local itemName = ""
	local hasNumber = 0
	local quality = nil
	if(tonumber(_itemType) == 1)then
		-- DB_Arena_shop表中每条数据中的 物品数据
		itemName = _itemData.name
		quality = _itemData.quality
		-- local cacheInfo = FindLongExchangeCache.getCacheItemInfoBy(_itemData.id)
		-- if( not table.isEmpty(cacheInfo))then
		-- 	hasNumber = cacheInfo.item_num
		-- end
		
		if _goodsData.needItem == nil then
			--已拥有的目标兑换物品数量
			hasNumber = ItemUtil.getCacheItemNumBy(_itemData.id)
		else
			--已拥有的兑换目标物品所需材料物品的数量
			hasNumber = ItemUtil.getCacheItemNumBy(_goodsData.needItem.tid)
		end
	elseif(tonumber(_itemType) == 2)then
		-- -- DB_Arena_shop表中每条数据中的 英雄数据
		require "script/model/hero/HeroModel"
		itemName = _itemData.name
		quality = _itemData.star_lv
		local allHeroData = HeroModel.getAllByHtid(tostring(_itemData.id))
		if( not table.isEmpty(allHeroData))then
			hasNumber = table.count(allHeroData)
		end
	end

	-- 限购次数
	_maxLimitNum = _goodsData.remainExchangeNum
	-- 一共拥有
	-- local totalLael = CCRenderLabel:create(GetLocalizeStringBy("key_2041") .. hasNumber .. GetLocalizeStringBy("key_2557"), g_sFontName, 24, 1, ccc3(0x49, 0x00, 0x00), type_stroke)
 --    totalLael:setColor(ccc3(0xff, 0xff, 0xff))
 --    totalLael:setPosition(ccp( (innerSize.width-totalLael:getContentSize().width)/2, 295) )
 --    innerBgSp:addChild(totalLael,1,10)
	require "script/libs/LuaCCLabel"
    local richInfo = {elements = {}}
    richInfo.elements[1] = {["type"] = "CCRenderLabel", newLine=false, text = GetLocalizeStringBy("key_2041") .. hasNumber .. GetLocalizeStringBy("key_2557"),
                            font = g_sFontName, size = 23, color = ccc3(0xff, 0xff, 0xff), strokeSize = 1, strokeColor = ccc3(0x49, 0x00, 0x00), renderType = 1}
    if _goodsData.needItem ~= nil then
    	local needItemData = ItemUtil.getItemById(_goodsData.needItem.tid)
	    richInfo.elements[2] = {["type"] = "CCRenderLabel", newLine=false, text = needItemData.name, font = g_sFontPangWa, size = 30,
	                            color = ccc3(0xff, 0xe4, 0x00), strokeSize = 1, strokeColor = ccc3(0x0, 0x0, 0x0), renderType = 1}
    end
    local totalLabel = LuaCCLabel.createRichLabel(richInfo)
    totalLabel:setAnchorPoint(ccp(0.5,0.5))
    totalLabel:setPosition(ccp( innerSize.width*0.5, 275) )
    innerBgSp:addChild(totalLabel,1,10)


    -- 兑换提示
    local buyTipNode = CCNode:create()
    local nodeSize = CCSizeMake(0,0)

    local buyTipLabel_1 = CCRenderLabel:create(GetLocalizeStringBy("key_1438"), g_sFontName, 24, 1, ccc3(0x49, 0x00, 0x00), type_stroke)
    buyTipLabel_1:setColor(ccc3(0xff, 0xff, 0xff))
    buyTipNode:addChild(buyTipLabel_1)
    local size_1 = buyTipLabel_1:getContentSize()
    nodeSize.width = nodeSize.width + size_1.width
    nodeSize.height = nodeSize.height > size_1.height and nodeSize.height or size_1.height

    -- 物品名称
    local nameLabel = CCRenderLabel:create(itemName, g_sFontPangWa, 30, 1, ccc3(0x00, 0x00, 0x00), type_stroke)
    --local fontColor = HeroPublicLua.getCCColorByStarLevel(quality)
    local fontColor = ccc3(0xff,0xe4,0x00)
	nameLabel:setColor(fontColor)
	nameLabel:setAnchorPoint(ccp(0,0))
    nameLabel:setPosition(nodeSize.width, -30)
    buyTipNode:addChild(nameLabel)
    local nameLabelSize = nameLabel:getContentSize()
    nodeSize.width = nodeSize.width + nameLabelSize.width
    nodeSize.height = nodeSize.height > nameLabelSize.height and nodeSize.height or nameLabelSize.height

    -- 兑换提示2
    local buyTipLabel_2 = CCRenderLabel:create(GetLocalizeStringBy("key_3113"), g_sFontName, 24, 1, ccc3(0x49, 0x00, 0x00), type_stroke)
    buyTipLabel_2:setColor(ccc3(0xff, 0xff, 0xff))
    buyTipLabel_2:setPosition(nodeSize.width, 0)
    buyTipNode:addChild(buyTipLabel_2)
    local size_2 = buyTipLabel_2:getContentSize()
    nodeSize.width = nodeSize.width + size_2.width
    nodeSize.height = nodeSize.height > size_2.height and nodeSize.height or size_2.height

    buyTipNode:setContentSize(nodeSize)
    buyTipNode:setAnchorPoint(ccp(0.5,0))
    buyTipNode:setPosition(innerSize.width*0.5,240)
    innerBgSp:addChild(buyTipNode)

	-- 加减道具的按钮
	local changeNumBar = CCMenu:create()
	changeNumBar:setPosition(ccp(0,0))
	changeNumBar:setTouchPriority(_touchPriority - 10)
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
	--local totalTipLabel = CCRenderLabel:create(GetLocalizeStringBy("key_2655"), g_sFontName, 36, 1, ccc3(0x49, 0x00, 0x00), type_stroke)
	local totalTipLabel = CCRenderLabel:create(GetLocalizeStringBy("zz_7"), g_sFontName, 36, 1, ccc3(0x49, 0x00, 0x00), type_stroke)
    totalTipLabel:setColor(ccc3(0xfe, 0xdb, 0x1c))
    totalTipLabel:setPosition(ccp(110, 72) )
    innerBgSp:addChild(totalTipLabel)
    local goldSp_2 = CCSprite:create("images/forge/xunlongjifen_icon.png")
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
local function createBg(p_touch)
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
	closeMenuBar:setTouchPriority(_touchPriority - 10)
	-- 关闭按钮
	local closeBtn = LuaMenuItem.createItemImage("images/common/btn_close_n.png", "images/common/btn_close_h.png", closeAction )
	closeBtn:setAnchorPoint(ccp(0.5, 0.5))
    closeBtn:setPosition(ccp(layerBg:getContentSize().width*0.97, layerBg:getContentSize().height*0.98))
	closeMenuBar:addChild(closeBtn)

	local buyMenuBar = CCMenu:create()
	buyMenuBar:setPosition(ccp(0,0))
	buyMenuBar:setTouchPriority(_touchPriority - 10)
	layerBg:addChild(buyMenuBar)

	-- 确定按钮
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
function showPurchaseLayer(cellData,p_touch)
	init()

	_goodsData = cellData
	_touchPriority = p_touch or -410
	-- 兑换商品中物品的数据
	local itemsTable = cellData.itemsTable
	local item_type, item_id, item_num = itemsTable.type, itemsTable.tid, itemsTable.num
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
		-- DB_Arena_shop表中每条数据中的 英雄数据
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