-- Filename：	FestivalComposeLayer.lua
-- Author：		Zhang Zihang
-- Date：		2015-1-13
-- Purpose：		节日活动合成界面

module("FestivalComposeLayer", package.seeall)

require "script/ui/rechargeActive/festivalActive/FestivalActiveData"
require "script/ui/rechargeActive/festivalActive/FestivalActiveService"
require "script/ui/item/ItemSprite"
require "script/ui/item/ItemUtil"
require "script/ui/item/ReceiveReward"
require "script/ui/hero/HeroPublicLua"
require "script/ui/tip/AnimationTip"
require "script/ui/common/BatchExchangeLayer"
require "script/utils/BaseUI"

local _bgLayer
local _touchPriority
local _zOrder
local _formulaInfo
local _labelTable
local _itemPosTable
local _ratioTable

--==================== Init ====================
--[[
	@des 	:初始化函数
--]]
function init()
	_bgLayer = nil
	_touchPriority = nil
	_zOrder = nil
	_formulaInfo = nil
	_labelTable = {}
	_itemPosTable = {}
	_ratioTable = {}
end

--[[
	@des 	:点击事件函数
--]]
function onTouchesHandler()
	return true
end

--[[
	@des 	:事件函数
	@param 	:事件
--]]
function onNodeEvent(event)
	if event == "enter" then
		_bgLayer:registerScriptTouchHandler(onTouchesHandler,false,_touchPriority,true)
		_bgLayer:setTouchEnabled(true)
	elseif eventType == "exit" then
		_bgLayer:unregisterScriptTouchHandler()
	end
end

--==================== Refresh ====================
--[[
	@des 	:刷新数量标签和合成信息
--]]
function refreshInfoAndLabel()
	_formulaInfo = FestivalActiveData.getFormulaInfo()
	local index = 0
	for i = 1,#_formulaInfo do
		local partInfo = _formulaInfo[i]
		local partNum = partInfo.num
		--物品位置信息
		local itemPosInfo = _itemPosTable[partNum]

		local ratioLabel = tolua.cast(_ratioTable[i],"CCLabelTTF")
		ratioLabel:setString("(" .. partInfo.composedNum .. "/" .. partInfo.maxNum .. ")")

		for j = 1,#itemPosInfo do
			index = index + 1
			local eachPosInfo = itemPosInfo[j]
			local itemInfo
			if j ~= #itemPosInfo then
				itemInfo = partInfo.itemInfo[j]
			else
				itemInfo = partInfo.targetInfo
			end

			local numColor
			local numString
			--如果是公式中的物品
			if itemInfo.own ~= nil then
				numColor = (itemInfo.own >= itemInfo.num) and ccc3(0x00,0xff,0x18) or ccc3(0xe8,0x00,0x00)
				numString = itemInfo.own .. "/" .. itemInfo.num
			--如果是目标物品
			else
				if itemInfo.num <= 1 then
					numString = " "
				else
					numString = itemInfo.num
				end
				numColor = ccc3(0x00,0xff,0x18)
			end

			local curLabel = tolua.cast(_labelTable[index],"CCRenderLabel")
			curLabel:setString(numString)
			curLabel:setColor(numColor)
		end
	end
end

--==================== CallBack ====================
--[[
	@des 	:删除页面
--]]
function removeLayer()
	_bgLayer:removeFromParentAndCleanup(true)
	_bgLayer = nil
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
	@param 	:tag值
--]]
function composeCallBack(p_tag)
	AudioUtil.playEffect("audio/effect/guanbi.mp3")

	local cellInfo = _formulaInfo[p_tag]
	--如果材料不足
	if not cellInfo.isEnough then
		AnimationTip.showTip(GetLocalizeStringBy("zzh_1257"))
	--如果到了最大合成次数
	elseif cellInfo.maxNum - cellInfo.composedNum <= 0 then
		AnimationTip.showTip(GetLocalizeStringBy("zzh_1260"))
	elseif ItemUtil.isBagFull() then
		removeLayer()
	else
		local buyOverCallBack = function(p_num)
			FestivalActiveData.addComposeNum(cellInfo.formulaId,p_num)
			local newNum = p_num*cellInfo.targetInfo.num
			local newString =  "7|" .. cellInfo.targetInfo.id .. "|" .. newNum
			--因为推送有延时，所以把刷新放到回调中
			ReceiveReward.showRewardWindow(ItemUtil.getItemsDataByStr(newString),refreshInfoAndLabel,nil,_touchPriority - 5)
		end

		local sureCallBack = function(p_num)
			FestivalActiveService.compose(cellInfo.formulaId,tonumber(p_num),buyOverCallBack)
		end

		local itemInfo = ItemUtil.getItemById(cellInfo.targetInfo.id)
		local paramTable = {}
		paramTable.title = GetLocalizeStringBy("zzh_1258")
		paramTable.first = GetLocalizeStringBy("zzh_1259")
		paramTable.max = FestivalActiveData.getLowerValue(cellInfo.totalComposeNum,cellInfo.maxNum - cellInfo.composedNum) 
		paramTable.name = itemInfo.name

		BatchExchangeLayer.showBatchLayer(paramTable,sureCallBack,_touchPriority - 4)
	end
end

--==================== UI ====================
--[[
	@des 	:得到展示的物品图片
	@param 	:物品信息
	@return :创建好的图片
--]]
function getShowItemSprite(p_info)
	local itemBgSprite = CCSprite:create("images/match/head_bg.png")
	local bgSize = itemBgSprite:getContentSize()

	local itemSprite = ItemSprite.getItemSpriteById(p_info.id,nil,nil,nil,_touchPriority - 4)
	itemSprite:setAnchorPoint(ccp(0.5,0.5))
	itemSprite:setPosition(ccp(bgSize.width*0.5,bgSize.height*0.5))
	itemBgSprite:addChild(itemSprite)

	local itemInfo = ItemUtil.getItemById(p_info.id)
	local nameLabel = CCRenderLabel:create(itemInfo.name,g_sFontPangWa,21,1,ccc3(0x00,0x00,0x00),type_stroke)
	nameLabel:setColor(HeroPublicLua.getCCColorByStarLevel(itemInfo.quality))
	nameLabel:setAnchorPoint(ccp(0.5,1))
	nameLabel:setPosition(ccp(bgSize.width*0.5,0))
	itemBgSprite:addChild(nameLabel)

	local numColor
	local numString
	--如果是公式中的物品
	if p_info.own ~= nil then
		numColor = (p_info.own >= p_info.num) and ccc3(0x00,0xff,0x18) or ccc3(0xe8,0x00,0x00)
		numString = p_info.own .. "/" .. p_info.num
	--如果是目标物品
	else
		if p_info.num <= 1 then
			numString = " "
		else
			numString = p_info.num
		end
		numColor = ccc3(0x00,0xff,0x18)
	end
	local numLabel = CCRenderLabel:create(numString,g_sFontPangWa,21,1,ccc3(0x00,0x00,0x00),type_stroke)
	numLabel:setColor(numColor)
	numLabel:setAnchorPoint(ccp(1,0))
	numLabel:setPosition(ccp(itemSprite:getContentSize().width - 5,5))
	itemSprite:addChild(numLabel)

	table.insert(_labelTable,numLabel)

	return itemBgSprite
end

--[[
	@des 	:得到标题label
	@param 	:当前合成栏的信息
	@return :创建好的label
--]]
function getTitleLabel(p_info)
	local itemInfo = ItemUtil.getItemById(p_info.targetInfo.id)
	local titleLabel = CCRenderLabel:create(itemInfo.name,g_sFontPangWa,25,1,ccc3(0x00,0x00,0x00),type_stroke)
	titleLabel:setColor(ccc3(0xff,0xff,0xff))

	return titleLabel
end

--[[
	@des 	:创建合成scrollView
	@param 	: $ p_bgSize 		: scrollView大小
	@param  : $ p_bgSprite 		: 二级背景sprite
--]]
function createViewScrollView(p_bgSize,p_bgSprite)
	_formulaInfo = FestivalActiveData.getFormulaInfo()

	local bgWidth = 560
	local innerBgWidth = 520

	--合成公式数量对应的背景高度
	local bgHeightTable = {
								[3] = 265,[4] = 400,[5] = 400
						  }
	--二级背景高度
	local innerBgHeightTable = {
									[3] = 140,[4] = 275,[5] = 275
							   }
	_itemPosTable = {
							[3] = {
										[1] = { 5,30 },[2] = { 145,30 },[3] = { 285,30 },[4] = { 420,30 }
								  },
							[4] = {
										[1] = { 5,165 },[2] = { 5,30 },[3] = { 215,165 },[4] = { 215,30 },[5] = { 420,95 }									
								  },
							[5] = {
										[1] = { 5,165 },[2] = { 5,30 },[3] = { 140,95 },[4] = { 280,165 },[5] = { 280,30 },[6] = { 420,95 }
								  }
						 }
	local commaPosTable = {
								[3] = {
											[1] = { 120,70 },[2] = { 260,70 },[3] = { 400,70 }

									  },
								[4] = {
											[1] = { 155,135 },[2] = { 370,135 }
									  },
								[5] = {
											[1] = { 115,135 },[2] = { 260,135 },[3] = { 395,135 }
									  }
						  }
	--scrollView
	local contentScrollView = CCScrollView:create()
	contentScrollView:setViewSize(p_bgSize)
	contentScrollView:setDirection(kCCScrollViewDirectionVertical)
	contentScrollView:setAnchorPoint(ccp(0,0))
	contentScrollView:setPosition(ccp(0,0))
	contentScrollView:setTouchPriority(_touchPriority - 5)
	p_bgSprite:addChild(contentScrollView)

	--内部的layer
	local scrolLayer = CCLayer:create()
	contentScrollView:setContainer(scrolLayer)

	local layerHeight = 30

	for i = 1,#_formulaInfo do
		local partInfo = _formulaInfo[i]
		local partNum = partInfo.num
		local bgHeight = bgHeightTable[partNum]

		local fullRect = CCRectMake(0,0,116,124)
    	local insetRect = CCRectMake(52,44,6,4)
		local cellBgSprite = CCScale9Sprite:create("images/common/bg/change_bg.png",fullRect,insetRect)
		cellBgSprite:setPreferredSize(CCSizeMake(bgWidth,bgHeight))
		cellBgSprite:setAnchorPoint(ccp(0.5,0))
		cellBgSprite:setPosition(ccp(p_bgSize.width*0.5,layerHeight))
		scrolLayer:addChild(cellBgSprite)

		--标题背景
		local titleBgSprite = CCSprite:create("images/sign/sign_bottom.png")
		titleBgSprite:setAnchorPoint(ccp(0,0))
		titleBgSprite:setPosition(ccp(0,bgHeight - 40))
		cellBgSprite:addChild(titleBgSprite)
		--标题名称
		local titleLabel = getTitleLabel(partInfo)
		titleLabel:setAnchorPoint(ccp(0.5,0.5))
		titleLabel:setPosition(ccp(titleBgSprite:getContentSize().width*0.5,titleBgSprite:getContentSize().height*0.5 + 3))
		titleBgSprite:addChild(titleLabel)

		--已合成次数
		local composedLabel = CCLabelTTF:create(GetLocalizeStringBy("zzh_1255"),g_sFontName,21)
		composedLabel:setColor(ccc3(0x78,0x25,0x00))
		--合成数量比例
		local ratioLabel = CCLabelTTF:create("(" .. partInfo.composedNum .. "/" .. partInfo.maxNum .. ")",g_sFontName,21)
		ratioLabel:setColor(ccc3(20,140,45))

		table.insert(_ratioTable,ratioLabel)

		local connectNode = BaseUI.createHorizontalNode({composedLabel,ratioLabel})
		connectNode:setAnchorPoint(ccp(1,1))
		connectNode:setPosition(ccp(bgWidth - 45,bgHeight - 25))
		cellBgSprite:addChild(connectNode)

		local innerBgHeight = innerBgHeightTable[partNum]
		--二级背景
		local innerBgSprite = CCScale9Sprite:create("images/common/bg/goods_bg.png")
		innerBgSprite:setPreferredSize(CCSizeMake(innerBgWidth,innerBgHeight))
		innerBgSprite:setAnchorPoint(ccp(0.5,1))
		innerBgSprite:setPosition(ccp(bgWidth*0.5,bgHeight - 45))
		cellBgSprite:addChild(innerBgSprite)

		--物品位置信息
		local itemPosInfo = _itemPosTable[partNum]
		--符号位置信息
		local commaPosInfo = commaPosTable[partNum]

		--展示的物品
		for j = 1,#itemPosInfo do
			local eachPosInfo = itemPosInfo[j]
			local itemInfo
			if j ~= #itemPosInfo then
				itemInfo = partInfo.itemInfo[j]
			else
				itemInfo = partInfo.targetInfo
			end
			local itemBgSprite = getShowItemSprite(itemInfo)
			itemBgSprite:setAnchorPoint(ccp(0,0))
			itemBgSprite:setPosition(ccp(eachPosInfo[1],eachPosInfo[2]))
			itemBgSprite:setScale(0.85)
			innerBgSprite:addChild(itemBgSprite)
		end

		--符号
		for j = 1,#commaPosInfo do
			local eachPosInfo = commaPosInfo[j]
			local commaSprite
			if j ~= #commaPosInfo then
				commaSprite = CCSprite:create("images/recharge/change/jia.png")
			else
				commaSprite = CCSprite:create("images/recharge/change/deng.png")
			end
			commaSprite:setAnchorPoint(ccp(0.5,0.5))
			commaSprite:setPosition(ccp(eachPosInfo[1],eachPosInfo[2]))
			innerBgSprite:addChild(commaSprite)
		end

		--cell的menu
		local innerMenu = CCMenu:create()
		innerMenu:setAnchorPoint(ccp(0,0))
		innerMenu:setPosition(ccp(0,0))
		innerMenu:setTouchPriority(_touchPriority - 3)
		cellBgSprite:addChild(innerMenu)

		local composeMenuItem = LuaCC.create9ScaleMenuItem("images/common/btn/purple01_n.png","images/common/btn/purple01_h.png",CCSizeMake(134,64),GetLocalizeStringBy("key_1363"),ccc3(0xfe,0xdb,0x1c),30,g_sFontPangWa,1,ccc3(0x00,0x00,0x00))
		composeMenuItem:setAnchorPoint(ccp(0.5,0))
		composeMenuItem:setPosition(ccp(bgWidth*0.5,15))
		composeMenuItem:registerScriptTapHandler(composeCallBack)
		innerMenu:addChild(composeMenuItem,1,i)

		layerHeight = layerHeight + bgHeight + 30
	end

	scrolLayer:setContentSize(CCSizeMake(p_bgSize.width,layerHeight))
	scrolLayer:setPosition(ccp(0,p_bgSize.height - layerHeight))
end

--[[
	@des 	:创建UI
--]]
function createUI()
	local bgSize = CCSizeMake(620,840)

	local bgSprite = CCScale9Sprite:create(CCRectMake(100,80,10,20),"images/common/viewbg1.png")
	bgSprite:setPreferredSize(bgSize)
	bgSprite:setAnchorPoint(ccp(0.5,0.5))
	bgSprite:setPosition(ccp(g_winSize.width*0.5,g_winSize.height*0.5))
	bgSprite:setScale(g_fElementScaleRatio)
	_bgLayer:addChild(bgSprite)

	local titleSprite = CCSprite:create("images/common/viewtitle1.png")
	titleSprite:setAnchorPoint(ccp(0.5,0.5))
	titleSprite:setPosition(ccp(bgSize.width*0.5,bgSize.height))
	bgSprite:addChild(titleSprite)

	local titleSize = titleSprite:getContentSize()

	local titleLabel = CCLabelTTF:create(GetLocalizeStringBy("zzh_1253"),g_sFontPangWa,33)
	titleLabel:setColor(ccc3(0xff,0xe4,0x00))
	titleLabel:setAnchorPoint(ccp(0.5,0.5))
	titleLabel:setPosition(ccp(titleSize.width*0.5,titleSize.height*0.5))
	titleSprite:addChild(titleLabel)

	local desLabel = CCRenderLabel:createWithAlign(FestivalActiveData.getComposeDes(),g_sFontPangWa,21,1,ccc3(0x00,0x00,0x00),type_stroke,CCSizeMake(470,0),kCCTextAlignmentCenter,kCCVerticalTextAlignmentTop)
	desLabel:setColor(ccc3(0xff,0xf6,0x00))
	desLabel:setAnchorPoint(ccp(0.5,0.5))
	desLabel:setPosition(ccp(bgSize.width*0.5,bgSize.height - 70))
	bgSprite:addChild(desLabel)

	local secBgSize = CCSizeMake(570,690)
	local secBgSprite = CCScale9Sprite:create("images/common/bg/bg_ng_attr.png")
	secBgSprite:setPreferredSize(secBgSize)
	secBgSprite:setAnchorPoint(ccp(0.5,0))
	secBgSprite:setPosition(ccp(bgSize.width*0.5,40))
	bgSprite:addChild(secBgSprite)

	createViewScrollView(secBgSize,secBgSprite)

	local bgMenu = CCMenu:create()
	bgMenu:setAnchorPoint(ccp(0,0))
	bgMenu:setPosition(ccp(0,0))
	bgMenu:setTouchPriority(_touchPriority - 1)
	bgSprite:addChild(bgMenu)

	local closeMenuItem = CCMenuItemImage:create("images/common/btn_close_n.png","images/common/btn_close_h.png")
	closeMenuItem:setAnchorPoint(ccp(1,1))
	closeMenuItem:setPosition(ccp(bgSize.width*1.03,bgSize.height*1.03))
	closeMenuItem:registerScriptTapHandler(closeCallBack)
	bgMenu:addChild(closeMenuItem)
end

--==================== Entrance ====================
--[[
	@des 	:入口函数
	@param 	: $ p_touchPriority 	: 触摸优先级
	@param 	: $ p_zOrder 			: Z轴
--]]
function showLayer(p_touchPriority,p_zOrder)
	init()

	_touchPriority = p_touchPriority or -550
	_zOrder = p_zOrder or 999

	--创建背景屏蔽层
	_bgLayer = CCLayerColor:create(ccc4(0,0,0,155))
	_bgLayer:registerScriptHandler(onNodeEvent)

    local scene = CCDirector:sharedDirector():getRunningScene()
    scene:addChild(_bgLayer,_zOrder)

    createUI()
end