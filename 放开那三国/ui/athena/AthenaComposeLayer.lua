-- Filename：	AthenaComposeLayer.lua
-- Author：		zhang zihang
-- Date：		2015-4-7
-- Purpose：		星魂合成界面，第一次尝试用策划给美术的UI效果图拼UI，毕竟美术UI给的太慢了

module("AthenaComposeLayer",package.seeall)

require "script/ui/athena/AthenaData"
require "script/ui/athena/AthenaService"
require "script/ui/item/ItemUtil"
require "script/ui/item/ItemSprite"
require "script/ui/item/ReceiveReward"
require "script/ui/common/BatchExchangeLayer"
require "script/ui/tip/AnimationTip"
require "script/ui/tip/LackGoldTip"
require "script/ui/hero/HeroPublicLua"

local _touchPriority
local _zOrder
local _bgLayer
local _formulaInfo
local _dealData
local _finalNameLabel
local _secBgSprite

local kLabelTag = 2

--[[
	@des 	:初始化
--]]
function init()
	_touchPriority = nil
	_zOrder = nil
	_bgLayer = nil
	_formulaInfo = nil
	_dealData = nil
	_finalNameLabel = nil
	_secBgSprite = nil
end

--[[
	@des 	:触摸回调
	@param  :事件
--]]
function onTouchesHandler(p_eventType)
	if p_eventType == "began" then
	    return true
	end
end

--[[
	@des 	:touch事件
	@param  :事件
--]]
function onNodeEvent(p_event)
	if p_event == "enter" then
		_bgLayer:registerScriptTouchHandler(onTouchesHandler,false,_touchPriority,true)
		_bgLayer:setTouchEnabled(true)
	elseif p_event == "exit" then
		_bgLayer:unregisterScriptTouchHandler()
	end
end

--[[
	@des 	:关闭回调
--]]
function closeCallBack()
	AudioUtil.playEffect("audio/effect/guanbi.mp3")
	removeLayer()
end

--[[
	@des 	:合成回调
--]]
function composeCallBack()
	AudioUtil.playEffect("audio/effect/guanbi.mp3")
	local composeNum = AthenaData.getMaxComposeNum(_formulaInfo)
	if composeNum == 0 then
		AnimationTip.showTip(GetLocalizeStringBy("zzh_1320"))
		return
	elseif ItemUtil.isPropBagFull(true) then
		removeLayer()
		return
	end

	local overCallBack = function()
		--增加星魂数量
		-- print("增加的星魂数量",composeNum)
		-- AthenaData.addStarSoulNum(composeNum)

		-- AthenaMainLayer.refreshStarNum()
		-- AthenaMainLayer.refreshAllArrow()
		removeLayer()
	end

	local composeOverCallBack = function()

		local newString = "7|" .. AthenaData.getFinalItemId() .. "|" .. composeNum

		--增加星魂数量
		AthenaData.addStarSoulNum(composeNum)
		--刷新界面星魂数
		AthenaMainLayer.refreshStarNum()
		--刷箭头
		AthenaMainLayer.refreshAllArrow()

		ReceiveReward.showRewardWindow(AthenaData.analyseString(newString),overCallBack,nil,_touchPriority - 10,GetLocalizeStringBy("zzh_1322"))
	end

	AthenaService.synthesis(composeNum/AthenaData.getFinalItemNum(),composeOverCallBack)
end

--[[
	@des 	:购买回调
	@param  :tag值
--]]
function buyCallBack(p_tag)
	AudioUtil.playEffect("audio/effect/guanbi.mp3")
	local composeInfo = _dealData[p_tag]

	if composeInfo.canNum == 0 then
		AnimationTip.showTip(GetLocalizeStringBy("zzh_1318"))
		return
	elseif ItemUtil.isPropBagFull(true) then
		removeLayer()
		return
	end

	local itemInfo = ItemUtil.getItemById(composeInfo.tid)

	-- local paramTable = {}
	-- paramTable.title = GetLocalizeStringBy("key_1745")
	-- paramTable.first = GetLocalizeStringBy("key_2853")
	-- paramTable.max = composeInfo.canNum
 --    paramTable.maxLimit = 999
	-- paramTable.name = itemInfo.name
	-- paramTable.need = {
	-- 						{
	-- 						  needName = GetLocalizeStringBy("djn_89"),
	-- 						  price = composeInfo.canNum,
	-- 						  color = ccc3(0x00,0xff,0x18),
	-- 						  minus = 1,
	-- 						  size = 21,
	-- 						  x_1 = 190,
	-- 						  x_2 = 320
	-- 						},
	-- 						{ needName = GetLocalizeStringBy("llp_165"),
	-- 						  sprite = "images/common/gold.png",
	-- 						  price = AthenaData.getComposePrice(composeInfo.tid),
	-- 						  size = 28,
	-- 						  x_1 = 195,
	-- 						  x_2 = 305
	-- 						}
	-- 				  }

	local finalCallBack = function()
		_dealData = AthenaData.dealAndGetComposeInfo(_formulaInfo)
		_finalNameLabel:setString(AthenaData.getMaxComposeNum(_formulaInfo))
		local secBgSprite = tolua.cast(_secBgSprite:getChildByTag(p_tag),"CCSprite")
		local numLabel = tolua.cast(secBgSprite:getChildByTag(kLabelTag),"CCRenderLabel")
		local numColor = _dealData[p_tag].isEnough and ccc3(0x00,0xff,0x18) or ccc3(0xff,0x00,0x00)
		numLabel:setString(_dealData[p_tag].haveNum .. "/" .. _dealData[p_tag].needNum)
		numLabel:setColor(numColor)
	end

	local buyOKCallBack = function(p_num)
		local needGoldNum = p_num*AthenaData.getComposePrice(composeInfo.tid)
		UserModel.addGoldNumber(-needGoldNum)
		AthenaData.addCopmoseItemNum(composeInfo.tid,p_num)

		local newString = "7|" .. composeInfo.tid .. "|" .. p_num

		ReceiveReward.showRewardWindow(AthenaData.analyseString(newString),finalCallBack,nil,_touchPriority - 10,GetLocalizeStringBy("zzh_1322"))
	end

	local buyOverCallBack = function(p_num)
		local needGoldNum = p_num*AthenaData.getComposePrice(composeInfo.tid)
		if needGoldNum > UserModel.getGoldNumber() then
			LackGoldTip.showTip()
			removeLayer()
		else
			AthenaService.buy(composeInfo.tid,p_num,buyOKCallBack)
		end
	end

	-- BatchExchangeLayer.showBatchLayer(paramTable,buyOverCallBack,_touchPriority - 10)


	-- 选择购买数量
    require "script/utils/BigNumberSelectDialog"
    local dialog = BigNumberSelectDialog:create(610, 670)
    dialog:setTitle(GetLocalizeStringBy("key_1745"))
    dialog:setLimitNum(composeInfo.canNum)
    dialog:show(_touchPriority - 10, 1010)

    local contentMsgInfo = {}
	contentMsgInfo.labelDefaultColor = ccc3(0xff,0xff,0xff)
	contentMsgInfo.labelDefaultSize = 25
	contentMsgInfo.defaultType = "CCRenderLabel"
	contentMsgInfo.lineAlignment = 1
	contentMsgInfo.lineAlignment = 2
	contentMsgInfo.labelDefaultFont = g_sFontName
	contentMsgInfo.defaultStrokeColor = ccc3(0x49,0x00,0x00)
	contentMsgInfo.elements = {
	    {
	        text = itemInfo.name,
	        color = ccc3(0xfe,0xdb,0x1c),
	        font = g_sFontPangWa,
	        size = 30,
	    }
	}
	local contentMsgNode = GetLocalizeLabelSpriteBy_2(GetLocalizeStringBy("lic_1813"), contentMsgInfo)
	contentMsgNode:setAnchorPoint(ccp(0.5,0.5))
	contentMsgNode:setPosition(ccpsprite(0.5, 0.8, dialog))
	dialog:addChild(contentMsgNode)
	-- 总价
	local contentCostNode = CCRenderLabel:create(GetLocalizeStringBy("llp_165"),g_sFontName,28,1,ccc3(0x49,0x00,0x00),type_stroke)
	contentCostNode:setColor(ccc3(0xfe,0xdb,0x1c))
	contentCostNode:setAnchorPoint(ccp(1,0))
	contentCostNode:setPosition(ccpsprite(0.5, 0.23, dialog))
	dialog:addChild(contentCostNode)
	local goldSp = CCSprite:create("images/common/gold.png")
	goldSp:setColor(ccc3(0xfe,0xdb,0x1c))
	goldSp:setAnchorPoint(ccp(0,0))
	goldSp:setPosition(contentCostNode:getPositionX()+10,contentCostNode:getPositionY())
	dialog:addChild(goldSp)
	-- 价格
	local piceNum = AthenaData.getComposePrice(composeInfo.tid)
	local totalPriceLabel = CCRenderLabel:create(piceNum,g_sFontName,28,1,ccc3(0x49,0x00,0x00),type_stroke)
	totalPriceLabel:setColor(ccc3(0xfe,0xdb,0x1c))
	totalPriceLabel:setAnchorPoint(ccp(0,0))
	totalPriceLabel:setPosition(goldSp:getPositionX()+goldSp:getContentSize().width+10,contentCostNode:getPositionY())
	dialog:addChild(totalPriceLabel)

	-- 剩余购买次数
	local tipFont = CCRenderLabel:create(GetLocalizeStringBy("djn_89"),g_sFontName,21,1,ccc3(0x49,0x00,0x00),type_stroke)
	tipFont:setColor(ccc3(0x00,0xff,0x18))
	tipFont:setAnchorPoint(ccp(1,0))
	tipFont:setPosition(dialog:getContentSize().width*0.5,contentCostNode:getPositionY()-contentCostNode:getContentSize().height*0.5-20)
	dialog:addChild(tipFont)
	local canBuyNum = composeInfo.canNum
	local tipNumFont = CCRenderLabel:create(canBuyNum,g_sFontName,21,1,ccc3(0x49,0x00,0x00),type_stroke)
	tipNumFont:setColor(ccc3(0xfe,0xdb,0x1c))
	tipNumFont:setAnchorPoint(ccp(0,0))
	tipNumFont:setPosition(tipFont:getPositionX()+10,tipFont:getPositionY())
	dialog:addChild(tipNumFont)

	-- 改变数量
	dialog:registerChangeCallback(function ( p_selectNum )
		-- 价格
		local costNum = p_selectNum * piceNum
		totalPriceLabel:setString(costNum)
	end)

	-- 确定
	dialog:registerOkCallback(function ()
		--刷新cell显示
		local selectNum = dialog:getNum()
		buyOverCallBack(selectNum)
	end)
	dialog:registerCancelCallback(function ()
		
	end)

end

--[[
	@des 	:删除layer
--]]
function removeLayer()
	_bgLayer:removeFromParentAndCleanup(true)
	_bgLayer = nil
end

--[[
	@des 	:创建UI
--]]
function createUI()
	--背景大小
	local bgSize = CCSizeMake(615,775)
	--背景图
	local bgSprite = CCScale9Sprite:create(CCRectMake(100,80,10,20),"images/common/viewbg1.png")
	bgSprite:setContentSize(bgSize)
	bgSprite:setAnchorPoint(ccp(0.5,0.5))
	bgSprite:setPosition(ccp(g_winSize.width*0.5,g_winSize.height*0.5))
	bgSprite:setScale(g_fElementScaleRatio)
	_bgLayer:addChild(bgSprite)

	--标题背景
	local titleSprite = CCSprite:create("images/common/viewtitle1.png")
	titleSprite:setAnchorPoint(ccp(0.5,0.5))
	titleSprite:setPosition(ccp(bgSprite:getContentSize().width/2,bgSprite:getContentSize().height - 6))
	bgSprite:addChild(titleSprite)

	local titleSize = titleSprite:getContentSize()

	--标题
	local titleLabel = CCLabelTTF:create(GetLocalizeStringBy("zzh_1317"),g_sFontPangWa,33)
	titleLabel:setColor(ccc3(0xff,0xe4,0x00))
	titleLabel:setAnchorPoint(ccp(0.5,0.5))
	titleLabel:setPosition(ccp(titleSize.width*0.5,titleSize.height*0.5))
	titleSprite:addChild(titleLabel)

	--背景按钮层
	local bgMenu = CCMenu:create()
	bgMenu:setAnchorPoint(ccp(0,0))
	bgMenu:setPosition(ccp(0,0))
	bgMenu:setTouchPriority(_touchPriority - 1)
	bgSprite:addChild(bgMenu)

	--关闭按钮
	local closeMenuItem = CCMenuItemImage:create("images/common/btn_close_n.png","images/common/btn_close_h.png")
	closeMenuItem:setAnchorPoint(ccp(1,1))
	closeMenuItem:setPosition(ccp(bgSize.width*1.03,bgSize.height*1.03))
	closeMenuItem:registerScriptTapHandler(closeCallBack)
	bgMenu:addChild(closeMenuItem)

 	--二级背景
 	_secBgSprite = CCSprite:create("images/athena/compose_bg.png")
 	_secBgSprite:setAnchorPoint(ccp(0.5,1))
 	_secBgSprite:setPosition(ccp(bgSize.width*0.5,bgSize.height - 55))
 	bgSprite:addChild(_secBgSprite)

 	local secBgSize = _secBgSprite:getContentSize()

 	--三个箭头
 	local arrowPosX = 150
 	local arrowPosY = 180
 	local angle = 125
 	local arrowTable = {
 							{ccp(secBgSize.width*0.5,secBgSize.height - 165),0},
 							{ccp(arrowPosX,arrowPosY),-angle},
 							{ccp(secBgSize.width - arrowPosX,arrowPosY),angle}
 					   }
 	for i = 1,3 do
 		local arrowSprite = CCSprite:create("images/athena/arrow.png")
 		arrowSprite:setRotation(arrowTable[i][2])
 		arrowSprite:setAnchorPoint(ccp(0.5,1))
 		arrowSprite:setPosition(arrowTable[i][1])
 		_secBgSprite:addChild(arrowSprite)
 	end

    --二级背景按钮层
    local secMenu = CCMenu:create()
    secMenu:setAnchorPoint(ccp(0,0))
    secMenu:setPosition(ccp(0,0))
    secMenu:setTouchPriority(_touchPriority - 2)
    _secBgSprite:addChild(secMenu)

    --合成的物品
    local finalBgSprite = CCSprite:create("images/athena/item_bg.png")
    finalBgSprite:setAnchorPoint(ccp(0.5,0.5))
    finalBgSprite:setPosition(ccp(secBgSize.width*0.5,270))
    _secBgSprite:addChild(finalBgSprite)
    local itemBgSize = finalBgSprite:getContentSize()
    --合成的物品
    local finalItemSprite = ItemSprite.getItemSpriteById(AthenaData.getFinalItemId(),nil,nil,nil,_touchPriority - 3)
    finalItemSprite:setAnchorPoint(ccp(0.5,0.5))
    finalItemSprite:setPosition(ccp(itemBgSize.width*0.5,itemBgSize.height*0.5))
    finalBgSprite:addChild(finalItemSprite)
    local finalInfo = ItemUtil.getItemById(AthenaData.getFinalItemId())
    local canNumLabel = CCRenderLabel:create(finalInfo.name,g_sFontPangWa,25,1,ccc3(0x00,0x00,0x00),type_stroke)
    canNumLabel:setColor(HeroPublicLua.getCCColorByStarLevel(finalInfo.quality))
    canNumLabel:setAnchorPoint(ccp(0.5,1))
    canNumLabel:setPosition(ccp(itemBgSize.width*0.5,0))
    finalBgSprite:addChild(canNumLabel)
    _finalNameLabel = CCRenderLabel:create(AthenaData.getMaxComposeNum(_formulaInfo),g_sFontName,18,1,ccc3(0x00,0x00,0x00),type_stroke)
    _finalNameLabel:setColor(ccc3(0x00,0xff,0x18))
    _finalNameLabel:setAnchorPoint(ccp(1,0))
    _finalNameLabel:setPosition(ccp(itemBgSize.width - 20,20))
    finalBgSprite:addChild(_finalNameLabel)

    --几个物品
    local gapLenth = 85
    local gapHeight = 190
    local posTable = { {secBgSize.width*0.5,secBgSize.height - 95},
    				   {gapLenth,gapHeight},
    				   {secBgSize.width - gapLenth,gapHeight} 
					 }

	_dealData = AthenaData.dealAndGetComposeInfo(_formulaInfo)
    for i = 1,#_formulaInfo do
    	--物品底
    	local itemBgSprite = CCSprite:create("images/athena/item_bg.png")
    	itemBgSprite:setAnchorPoint(ccp(0.5,0.5))
    	itemBgSprite:setPosition(ccp(posTable[i][1],posTable[i][2]))
    	_secBgSprite:addChild(itemBgSprite,1,i)

    	--物品图
    	local itemSprite = ItemUtil.createGoodsIcon(_formulaInfo[i],_touchPriority - 3,nil,nil,nil,nil,nil,false,false)
    	itemSprite:setAnchorPoint(ccp(0.5,0.5))
    	itemSprite:setPosition(ccp(itemBgSize.width*0.5,itemBgSize.height*0.5))
    	itemBgSprite:addChild(itemSprite)
    	--名字底
    	local noSprite = CCSprite:create("images/athena/name_bg.png")
    	noSprite:setAnchorPoint(ccp(0.5,0))
    	noSprite:setPosition(ccp(itemBgSize.width*0.5,itemBgSize.height))
    	itemBgSprite:addChild(noSprite)

    	local noSize = noSprite:getContentSize()
    	--编号
    	local noLabel = CCRenderLabel:create(tostring(i),g_sFontPangWa,25,1,ccc3(0x00,0x00,0x00),type_stroke)
    	noLabel:setColor(ccc3(0xff,0xff,0xff))
    	noLabel:setAnchorPoint(ccp(0.5,0.5))
    	noLabel:setPosition(ccp(15,noSize.height*0.5))
    	noSprite:addChild(noLabel)

    	local itemInfo = ItemUtil.getItemById(_dealData[i].tid)
    	--名字
    	local nameLabel = CCRenderLabel:create(itemInfo.name,g_sFontPangWa,25,1,ccc3(0x00,0x00,0x00),type_stroke)
    	nameLabel:setColor(HeroPublicLua.getCCColorByStarLevel(itemInfo.quality))
    	nameLabel:setAnchorPoint(ccp(0,0.5))
    	nameLabel:setPosition(ccp(40,noSize.height*0.5))
    	noSprite:addChild(nameLabel)
    	--当前拥有数量
    	local numColor = _dealData[i].isEnough and ccc3(0x00,0xff,0x18) or ccc3(0xff,0x00,0x00)
    	local numLabel = CCRenderLabel:create(_dealData[i].haveNum .. "/" .. _dealData[i].needNum,g_sFontName,18,1,ccc3(0x00,0x00,0x00),type_stroke)
    	numLabel:setColor(numColor)
    	numLabel:setAnchorPoint(ccp(1,0))
    	numLabel:setPosition(ccp(itemBgSize.width - 20,20))
    	itemBgSprite:addChild(numLabel,1,kLabelTag)

    	local buyMenuItem = LuaCC.create9ScaleMenuItem("images/common/btn/purple01_n.png","images/common/btn/purple01_h.png",CCSizeMake(120,65),GetLocalizeStringBy("zz_116"),ccc3(0xfe,0xdb,0x1c),25,g_sFontPangWa,1,ccc3(0x00,0x00,0x00))
    	buyMenuItem:setAnchorPoint(ccp(0.5,1))
    	buyMenuItem:setPosition(ccp(posTable[i][1],posTable[i][2] - 50))
    	buyMenuItem:registerScriptTapHandler(buyCallBack)
    	secMenu:addChild(buyMenuItem,1,i)
    end

    local composeMenuItem = LuaCC.create9ScaleMenuItem("images/common/btn/btn1_d.png","images/common/btn/btn1_n.png",CCSizeMake(210,75),GetLocalizeStringBy("zzh_1319"),ccc3(0xfe,0xdb,0x1c),35,g_sFontPangWa,1,ccc3(0x00,0x00,0x00))
    composeMenuItem:setAnchorPoint(ccp(0.5,0))
    composeMenuItem:setPosition(ccp(bgSize.width*0.5,35))
    composeMenuItem:registerScriptTapHandler(composeCallBack)
    bgMenu:addChild(composeMenuItem)
end

--[[
	@des 	:入口函数
	@param  :触摸优先级
	@param  :Z轴
--]]
function showLayer(p_touchPriority,p_zOrder)
	init()

	_touchPriority = p_touchPriority or -550
	_zOrder = p_zOrder or 999

	_formulaInfo = AthenaData.getDeCodeComposeItemInfo()

	_bgLayer = CCLayerColor:create(ccc4(0,0,0,155))
	_bgLayer:registerScriptHandler(onNodeEvent)
    local scene = CCDirector:sharedDirector():getRunningScene()
    scene:addChild(_bgLayer,_zOrder)

    createUI()
end