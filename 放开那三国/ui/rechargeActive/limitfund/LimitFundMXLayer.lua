-- FileName: LimitFundMXLayer.lua 
-- Author: fuqiongqiong
-- Date: 2016-9-29
-- Purpose: 限时基金明细

module("LimitFundMXLayer",package.seeall)
require "script/ui/rechargeActive/limitfund/LimitFundData"

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
local _index			= nil
local _item_day 		= nil
local _item_gold		= nil
local _item_num			= nil
local _goldLable        = nil
local _index			= nil
local _returnNum		= nil
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
	_index				= nil
	_returnNum			= nil
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
local function closeAction()
	-- 音效
	require "script/audio/AudioUtil"
	AudioUtil.playEffect("audio/effect/guanbi.mp3")
	if(_bglayer)then
		_bglayer:removeFromParentAndCleanup(true)
		_bglayer = nil
	end	
end 

function showPurchaseLayer( pindex,returnNum)
	init()
	_bglayer = CCLayerColor:create(ccc4(0,0,0,155))
	_bglayer:registerScriptHandler(onNodeEvent)
	local runningScene = CCDirector:sharedDirector():getRunningScene()
	runningScene:addChild(_bglayer, 1010)
	_index = pindex
	_returnNum = returnNum
	-- 创建背景
	createBg()
	-- 创建二级背景
	createInnerBg()
end

 function createBg( )
	-- 背景
	layerBg = CCScale9Sprite:create("images/formation/changeformation/bg.png")
	layerBg:setContentSize(CCSizeMake(560, 470))
	layerBg:setAnchorPoint(ccp(0.5, 0.5))
	layerBg:setPosition(ccp(_bglayer:getContentSize().width*0.5, _bglayer:getContentSize().height*0.5))
	_bglayer:addChild(layerBg)
	layerBg:setScale(g_fScaleX)	

	local titleSp = CCSprite:create("images/formation/changeformation/titlebg.png")
	titleSp:setAnchorPoint(ccp(0.5,0.5))
	titleSp:setPosition(ccp(layerBg:getContentSize().width/2, layerBg:getContentSize().height*0.985))
	layerBg:addChild(titleSp)

	local titleLabel = CCLabelTTF:create(GetLocalizeStringBy("fqq_167"), g_sFontPangWa, 30)
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
	comfirmBtn:setAnchorPoint(ccp(0.5, 0))
	comfirmBtn:setPosition(ccp(280, 22	))
	comfirmBtn:registerScriptTapHandler(buyAction)
	buyMenuBar:addChild(comfirmBtn, 1)

	-- local cancelBtn = LuaCC.create9ScaleMenuItem("images/star/intimate/btn_blue_n.png", "images/star/intimate/btn_blue_h.png",CCSizeMake(140, 70), GetLocalizeStringBy("key_1202"),ccc3(0xfe, 0xdb, 0x1c),30,g_sFontPangWa,1, ccc3(0x00, 0x00, 0x00))
	-- cancelBtn:setAnchorPoint(ccp(0, 0))
	-- cancelBtn:setPosition(ccp(350, 22))
	-- cancelBtn:registerScriptTapHandler(buyAction)
	-- buyMenuBar:addChild(cancelBtn, 1, 10002)

end 

 function createInnerBg()
	-- 背景2
	_innerBgSp = CCScale9Sprite:create("images/common/bg/bg_ng_attr.png")
	_innerBgSp:setContentSize(CCSizeMake(490, 290))
	_innerBgSp:setAnchorPoint(ccp(0.5, 0))
	_innerBgSp:setPosition(ccp(layerBg:getContentSize().width*0.5, 105))
	layerBg:addChild(_innerBgSp)
	local returnNum1 = 0
    local typeNumTable = LimitFundData.getTypeOfNumTable()
    for k,v in pairs(typeNumTable) do
    	if(tonumber(v.type) == 1)then
    		local dataTable = LimitFundData.getDataOfWay(tonumber(v.type))
			local dataTable2 = dataTable[_index]
			local allreadyNum = LimitFundData.getAllreadyNum(tonumber(v.type))
			returnNum1 =  dataTable2[4]*allreadyNum
			break
    	end	
    end
    local baitiao = CCScale9Sprite:create("images/recharge/bg_9s_3.png")
    baitiao:setContentSize(CCSizeMake(400,30))
    baitiao:setAnchorPoint(ccp(0.5,1))
    baitiao:setPosition(ccp(_innerBgSp:getContentSize().width*0.5,_innerBgSp:getContentSize().height*0.88))
    _innerBgSp:addChild(baitiao)
    local name = LimitFundData.getLimitFundInfoById(1).name
	local firsetLable = CCRenderLabel:create(name..GetLocalizeStringBy("fqq_171"),g_sFontPangWa,28,1,ccc3(0x00,0x00,0x00),type_stroke)
	firsetLable:setColor(ccc3(0xff,0xff,0xff))
 	firsetLable:setAnchorPoint(ccp(0,1))
	firsetLable:setPosition(ccp(_innerBgSp:getContentSize().width*0.2,_innerBgSp:getContentSize().height*0.89))
	_innerBgSp:addChild(firsetLable)
	local returnNum1Lable = CCRenderLabel:create(returnNum1,g_sFontPangWa,28,1,ccc3(0x00,0x00,0x00),type_stroke)
	returnNum1Lable:setColor(ccc3(0x00,0xff,0x18))
 	returnNum1Lable:setAnchorPoint(ccp(0,01))
	returnNum1Lable:setPosition(ccp(_innerBgSp:getContentSize().width*0.6,_innerBgSp:getContentSize().height*0.89))
	_innerBgSp:addChild(returnNum1Lable)
	local jinbi = CCRenderLabel:create(GetLocalizeStringBy("fqq_170"),g_sFontPangWa,28,1,ccc3(0x00,0x00,0x00),type_stroke)
	jinbi:setColor(ccc3(0xff,0xf6,0x00))
 	jinbi:setAnchorPoint(ccp(0,0.5))
	jinbi:setPosition(ccp(returnNum1Lable:getContentSize().width,returnNum1Lable:getContentSize().height*0.5))
	returnNum1Lable:addChild(jinbi)
	local returnNum2 = 0
    local typeNumTable = LimitFundData.getTypeOfNumTable()
    for k,v in pairs(typeNumTable) do
    	if(tonumber(v.type) == 2)then
    		local dataTable = LimitFundData.getDataOfWay(tonumber(v.type))
			local dataTable2 = dataTable[_index]
			local allreadyNum = LimitFundData.getAllreadyNum(tonumber(v.type))
			returnNum2 =  dataTable2[4]*allreadyNum
			break
    	end	
    end
     local baitiao2 = CCScale9Sprite:create("images/recharge/bg_9s_3.png")
    baitiao2:setContentSize(CCSizeMake(400,30))
    baitiao2:setAnchorPoint(ccp(0.5,1))
    baitiao2:setPosition(ccp(_innerBgSp:getContentSize().width*0.5,_innerBgSp:getContentSize().height*0.67))
    _innerBgSp:addChild(baitiao2)
    local name = LimitFundData.getLimitFundInfoById(2).name
    local secondLable = CCRenderLabel:create(name..GetLocalizeStringBy("fqq_171"),g_sFontPangWa,28,1,ccc3(0x00,0x00,0x00),type_stroke)
	secondLable:setColor(ccc3(0xff,0xff,0xff))
 	secondLable:setAnchorPoint(ccp(0,1))
	secondLable:setPosition(ccp(_innerBgSp:getContentSize().width*0.2,_innerBgSp:getContentSize().height*0.68))
	_innerBgSp:addChild(secondLable)
	local returnNum2Lable = CCRenderLabel:create(returnNum2,g_sFontPangWa,28,1,ccc3(0x00,0x00,0x00),type_stroke)
	returnNum2Lable:setColor(ccc3(0x00,0xff,0x18))
 	returnNum2Lable:setAnchorPoint(ccp(0,01))
	returnNum2Lable:setPosition(ccp(_innerBgSp:getContentSize().width*0.6,_innerBgSp:getContentSize().height*0.68))
	_innerBgSp:addChild(returnNum2Lable)
	local jinbi = CCRenderLabel:create(GetLocalizeStringBy("fqq_170"),g_sFontPangWa,28,1,ccc3(0x00,0x00,0x00),type_stroke)
	jinbi:setColor(ccc3(0xff,0xf6,0x00))
 	jinbi:setAnchorPoint(ccp(0,0.5))
	jinbi:setPosition(ccp(returnNum2Lable:getContentSize().width,returnNum1Lable:getContentSize().height*0.5))
	returnNum2Lable:addChild(jinbi)
    local returnNum3 = 0
    local typeNumTable = LimitFundData.getTypeOfNumTable()
    for k,v in pairs(typeNumTable) do
    	if(tonumber(v.type) == 3)then
    		local dataTable = LimitFundData.getDataOfWay(tonumber(v.type))
			local dataTable2 = dataTable[_index]
			local allreadyNum = LimitFundData.getAllreadyNum(tonumber(v.type))
			returnNum3 =  dataTable2[4]*allreadyNum
			break
    	end	
    end
     local baitiao3 = CCScale9Sprite:create("images/recharge/bg_9s_3.png")
    baitiao3:setContentSize(CCSizeMake(400,30))
    baitiao3:setAnchorPoint(ccp(0.5,1))
    baitiao3:setPosition(ccp(_innerBgSp:getContentSize().width*0.5,_innerBgSp:getContentSize().height*0.47))
    _innerBgSp:addChild(baitiao3)
    local name = LimitFundData.getLimitFundInfoById(3).name
    local thridLable = CCRenderLabel:create(name..GetLocalizeStringBy("fqq_171"),g_sFontPangWa,28,1,ccc3(0x00,0x00,0x00),type_stroke)
	thridLable:setColor(ccc3(0xff,0xff,0xff))
 	thridLable:setAnchorPoint(ccp(0,1))
	thridLable:setPosition(ccp(_innerBgSp:getContentSize().width*0.2,_innerBgSp:getContentSize().height*0.48))
	_innerBgSp:addChild(thridLable)
	local returnNum3Lable = CCRenderLabel:create(returnNum3,g_sFontPangWa,28,1,ccc3(0x00,0x00,0x00),type_stroke)
	returnNum3Lable:setColor(ccc3(0x00,0xff,0x18))
 	returnNum3Lable:setAnchorPoint(ccp(0,01))
	returnNum3Lable:setPosition(ccp(_innerBgSp:getContentSize().width*0.6,_innerBgSp:getContentSize().height*0.48))
	_innerBgSp:addChild(returnNum3Lable)
	local jinbi = CCRenderLabel:create(GetLocalizeStringBy("fqq_170"),g_sFontPangWa,28,1,ccc3(0x00,0x00,0x00),type_stroke)
	jinbi:setColor(ccc3(0xff,0xf6,0x00))
 	jinbi:setAnchorPoint(ccp(0,0.5))
	jinbi:setPosition(ccp(returnNum3Lable:getContentSize().width,returnNum1Lable:getContentSize().height*0.5))
	returnNum3Lable:addChild(jinbi)
	local total = CCRenderLabel:create(GetLocalizeStringBy("fqq_169"),g_sFontPangWa,30,1,ccc3(0x00,0x00,0x00),type_stroke)
	total:setColor(ccc3(0xfd,0x01,0x00))
 	total:setAnchorPoint(ccp(0,0))
	total:setPosition(ccp(_innerBgSp:getContentSize().width*0.32,_innerBgSp:getContentSize().height*0.15))
	_innerBgSp:addChild(total)
	local numLable = CCRenderLabel:create(_returnNum,g_sFontPangWa,28,1,ccc3(0x00,0x00,0x00),type_stroke)
	numLable:setColor(ccc3(0x00,0xff,0x18))
 	numLable:setAnchorPoint(ccp(0,0.5))
	numLable:setPosition(ccp(total:getContentSize().width,total:getContentSize().height*0.5))
	total:addChild(numLable)
	local numLable1 = CCRenderLabel:create(GetLocalizeStringBy("fqq_170"),g_sFontPangWa,28,1,ccc3(0x00,0x00,0x00),type_stroke)
	numLable1:setColor(ccc3(0xff,0xf6,0x00))
 	numLable1:setAnchorPoint(ccp(0,0.5))
	numLable1:setPosition(ccp(total:getContentSize().width+numLable:getContentSize().width,total:getContentSize().height*0.5))
	total:addChild(numLable1)
	
end
-- 按钮响应
function buyAction( tag, itemBtn )
	-- 音效
	require "script/audio/AudioUtil"
	AudioUtil.playEffect("audio/effect/zhujiemian.mp3")
	closeAction()
end