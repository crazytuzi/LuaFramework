-- Filename：	FestivalActiveLayer.lua
-- Author：		Zhang Zihang
-- Date：		2015-1-9
-- Purpose：		节日活动界面

module("FestivalActiveLayer", package.seeall)

require "script/ui/rechargeActive/festivalActive/FestivalActiveData"
require "script/ui/rechargeActive/festivalActive/FestivalComposeLayer"
require "script/ui/rechargeActive/festivalActive/FestivalActiveService"

local _bgLayer				--背景层
local _activeType			--活动类型
local _imgPath				--图片路径
local _secBgSize 			--二级背景大小
local _secondBgSprite 		--二级背景图

--==================== Init ====================
--[[
	@des 	:初始化函数
--]]
function init()
	_bgLayer = nil
	_activeType = nil
	_imgPath = nil
	_secBgSize = nil
	_secondBgSprite = nil
end

--==================== CallBack ====================
--[[
	@des 	:合成回调
--]]
function composeCallBack()
	FestivalActiveService.getFestivalInfo(FestivalComposeLayer.showLayer)
end

--==================== UI ====================
--[[
	@des 	:创建掉落预览node
	@return :预览node
	@return :预览框高度
--]]
function createDropNode()
	local dropInfo = FestivalActiveData.getDropInfo()
	local dropNum = #dropInfo

	local gapHeight = 140
	
	local viewHeight = gapHeight*math.ceil(dropNum/3)
	local addHeight = 20
	local bgSize = CCSizeMake(385,viewHeight + addHeight)

	local viewBgSprite = CCScale9Sprite:create("images/common/bg/astro_btnbg.png")
	viewBgSprite:setPreferredSize(bgSize)

	local titleBgSize = CCSizeMake(185,35)

	local titleSprite = CCScale9Sprite:create(CCRectMake(25,15,20,10),"images/common/astro_labelbg.png")
	titleSprite:setPreferredSize(titleBgSize)
	titleSprite:setAnchorPoint(ccp(0.5,0.5))
	titleSprite:setPosition(ccp(bgSize.width*0.5,bgSize.height))
	viewBgSprite:addChild(titleSprite)

	local titleLabel = CCLabelTTF:create(GetLocalizeStringBy("zzh_1250"),g_sFontPangWa,23)
	titleLabel:setColor(ccc3(0xff,0xf6,0x00))
	titleLabel:setAnchorPoint(ccp(0.5,0.5))
	titleLabel:setPosition(ccp(titleBgSize.width*0.5,titleBgSize.height*0.5))
	titleSprite:addChild(titleLabel)

	local beginHeight = bgSize.height - 25
	local posXTable = {bgSize.width*0.5 - 120,bgSize.width*0.5,bgSize.width*0.5 + 120}

	for i = 1,dropNum do
		local itemId = dropInfo[i]
		local xIndex = i%3 == 0 and 3 or i%3
		local yIndex = math.ceil(i/3)
		local itemSprite = ItemSprite.getItemSpriteById(itemId)
		itemSprite:setAnchorPoint(ccp(0.5,1))
		itemSprite:setPosition(ccp(posXTable[xIndex],beginHeight - (yIndex - 1)*gapHeight))
		viewBgSprite:addChild(itemSprite)

		local itemInfo = ItemUtil.getItemById(itemId)
		local nameLabel = CCRenderLabel:create(itemInfo.name,g_sFontName,21,1,ccc3(0x00,0x00,0x00),type_stroke)
		nameLabel:setColor(HeroPublicLua.getCCColorByStarLevel(itemInfo.quality))
		nameLabel:setAnchorPoint(ccp(0.5,1))
		nameLabel:setPosition(ccp(itemSprite:getContentSize().width*0.5,-5))
		itemSprite:addChild(nameLabel)
	end

	return viewBgSprite,bgSize.height + 20
end

--[[
	@des 	:创建合成预览node
	@return :预览node
	@return :预览框高度
--]]
function createComposeNode()
	local composeInfo = FestivalActiveData.getComposeInfo()
	local composeNum = #composeInfo

	local gapHeight = 140
	local viewHeight = gapHeight*math.ceil(composeNum/3)
	local addHeight = 20
	local bgSize = CCSizeMake(385,viewHeight + addHeight)

	local viewBgSprite = CCScale9Sprite:create("images/common/bg/astro_btnbg.png")
	viewBgSprite:setPreferredSize(bgSize)

	local titleBgSize = CCSizeMake(185,35)

	local titleSprite = CCScale9Sprite:create(CCRectMake(25,15,20,10),"images/common/astro_labelbg.png")
	titleSprite:setPreferredSize(titleBgSize)
	titleSprite:setAnchorPoint(ccp(0.5,0.5))
	titleSprite:setPosition(ccp(bgSize.width*0.5,bgSize.height))
	viewBgSprite:addChild(titleSprite)

	local titleLabel = CCLabelTTF:create(GetLocalizeStringBy("zzh_1251"),g_sFontPangWa,23)
	titleLabel:setColor(ccc3(0xff,0xf6,0x00))
	titleLabel:setAnchorPoint(ccp(0.5,0.5))
	titleLabel:setPosition(ccp(titleBgSize.width*0.5,titleBgSize.height*0.5))
	titleSprite:addChild(titleLabel)

	local beginHeight = bgSize.height - 25
	local posXTable = {bgSize.width*0.5 - 120,bgSize.width*0.5,bgSize.width*0.5 + 120}

	for i = 1,composeNum do
		local itemId = composeInfo[i]
		local xIndex = i%3 == 0 and 3 or i%3
		local yIndex = math.ceil(i/3)
		local itemSprite = ItemSprite.getItemSpriteById(itemId)
		itemSprite:setAnchorPoint(ccp(0.5,1))
		itemSprite:setPosition(ccp(posXTable[xIndex],beginHeight - (yIndex - 1)*gapHeight))
		viewBgSprite:addChild(itemSprite)

		local itemInfo = ItemUtil.getItemById(itemId)
		local nameLabel = CCRenderLabel:create(itemInfo.name,g_sFontName,21,1,ccc3(0x00,0x00,0x00),type_stroke)
		nameLabel:setColor(HeroPublicLua.getCCColorByStarLevel(itemInfo.quality))
		nameLabel:setAnchorPoint(ccp(0.5,1))
		nameLabel:setPosition(ccp(itemSprite:getContentSize().width*0.5,-5))
		itemSprite:addChild(nameLabel)
	end

	return viewBgSprite,bgSize.height + 20
end

--[[
	@des 	:创建scrollView相关UI
--]]
function createScrollUI()
	--scrollView
	local contentScrollView = CCScrollView:create()
	contentScrollView:setViewSize(_secBgSize)
	contentScrollView:setDirection(kCCScrollViewDirectionVertical)
	contentScrollView:setAnchorPoint(ccp(0,0))
	contentScrollView:setPosition(ccp(0,0))
	_secondBgSprite:addChild(contentScrollView)

	--内部的layer
	local scrolLayer = CCLayer:create()
	contentScrollView:setContainer(scrolLayer)

	--layer高度
	local layerHeight = 10*g_fScaleX

	--如果是副本掉落
	if _activeType == FestivalActiveData.tagCopyDrop then
		local dropNode,dropHeight = createDropNode()
		dropNode:setAnchorPoint(ccp(0.5,0))
		dropNode:setPosition(ccp(_secBgSize.width*0.5,layerHeight))
		dropNode:setScale(g_fScaleX)
		scrolLayer:addChild(dropNode)

		layerHeight = layerHeight + dropHeight*g_fScaleX + 10*g_fScaleX
	elseif _activeType == FestivalActiveData.tagCompose then
		local composeNode,dropHeight = createComposeNode()
		composeNode:setAnchorPoint(ccp(0.5,0))
		composeNode:setPosition(ccp(_secBgSize.width*0.5,layerHeight))
		composeNode:setScale(g_fScaleX)
		scrolLayer:addChild(composeNode)

		layerHeight = layerHeight + dropHeight*g_fScaleX + 10*g_fScaleX
	end

	local labelWidth = 405

	--活动福利
	local desLabel = CCRenderLabel:createWithAlign(FestivalActiveData.getActiveDes(),g_sFontName,23,1,ccc3(0x00,0x00,0x00),type_stroke,CCSizeMake(labelWidth,0),kCCTextAlignmentCenter,kCCVerticalTextAlignmentTop)
	desLabel:setColor(ccc3(0xff,0xff,0xff))
	desLabel:setAnchorPoint(ccp(0.5,0))
	desLabel:setPosition(ccp(_secBgSize.width*0.5,layerHeight))
	desLabel:setScale(g_fScaleX)
	scrolLayer:addChild(desLabel)

	layerHeight = layerHeight + desLabel:getContentSize().height*g_fScaleX + 10*g_fScaleX

	--活动福利标题
	local desFlowerSprite = CCSprite:create("images/recharge/benefit_active/flower.png")
	desFlowerSprite:setAnchorPoint(ccp(0.5,0))
	desFlowerSprite:setPosition(ccp(_secBgSize.width*0.5,layerHeight))
	desFlowerSprite:setScale(g_fScaleX)
	scrolLayer:addChild(desFlowerSprite)

	local desTitleLabel = CCRenderLabel:create(GetLocalizeStringBy("key_1297"),g_sFontPangWa,25,1,ccc3(0xff,0xff,0xff),type_stroke)
	desTitleLabel:setColor(ccc3(0x78,0x25,0x00))
	desTitleLabel:setAnchorPoint(ccp(0.5,0))
	desTitleLabel:setPosition(ccp(_secBgSize.width*0.5,layerHeight))
	desTitleLabel:setScale(g_fScaleX)
	scrolLayer:addChild(desTitleLabel)

	layerHeight = layerHeight + desTitleLabel:getContentSize().height*g_fScaleX + 10*g_fScaleX

	--活动说明
	local explLabel = CCRenderLabel:createWithAlign(FestivalActiveData.getActiveExpl(),g_sFontName,23,1,ccc3(0x00,0x00,0x00),type_stroke,CCSizeMake(labelWidth,0),kCCTextAlignmentCenter,kCCVerticalTextAlignmentTop)
	explLabel:setColor(ccc3(0xff,0xff,0xff))
	explLabel:setAnchorPoint(ccp(0.5,0))
	explLabel:setPosition(ccp(_secBgSize.width*0.5,layerHeight))
	explLabel:setScale(g_fScaleX)
	scrolLayer:addChild(explLabel)

	layerHeight = layerHeight + explLabel:getContentSize().height*g_fScaleX + 10*g_fScaleX

	--活动说明标题
	local explFlowerSprite = CCSprite:create("images/recharge/benefit_active/flower.png")
	explFlowerSprite:setAnchorPoint(ccp(0.5,0))
	explFlowerSprite:setPosition(ccp(_secBgSize.width*0.5,layerHeight))
	explFlowerSprite:setScale(g_fScaleX)
	scrolLayer:addChild(explFlowerSprite)

	local explTitleLabel = CCRenderLabel:create(GetLocalizeStringBy("key_2934"),g_sFontPangWa,25,1,ccc3(0xff,0xff,0xff),type_stroke)
	explTitleLabel:setColor(ccc3(0x78,0x25,0x00))
	explTitleLabel:setAnchorPoint(ccp(0.5,0))
	explTitleLabel:setPosition(ccp(_secBgSize.width*0.5,layerHeight))
	explTitleLabel:setScale(g_fScaleX)
	scrolLayer:addChild(explTitleLabel)

	layerHeight = layerHeight + explTitleLabel:getContentSize().height*g_fScaleX + 10*g_fScaleX

	scrolLayer:setContentSize(CCSizeMake(_secBgSize.width,layerHeight))
	scrolLayer:setPosition(ccp(0,_secBgSize.height - layerHeight))
end

--[[
	@des 	:创建UI
--]]
function createUI()
	--如果是副本掉落
	if _activeType == FestivalActiveData.tagCopyDrop then
		_imgPath = "images/recharge/festival/drop/"
	--如果是合成
	elseif _activeType == FestivalActiveData.tagCompose then
		_imgPath = "images/recharge/festival/compose/"
	end

	--背景图
	local bgSprite = CCSprite:create(_imgPath .. "bg.png")
	bgSprite:setAnchorPoint(ccp(0.5,0.5))
	bgSprite:setPosition(ccp(g_winSize.width*0.5,g_winSize.height*0.5))
	bgSprite:setScale(g_fBgScaleRatio)
	_bgLayer:addChild(bgSprite)

	--跑马灯大小
	local bulletSize = RechargeActiveMain.getTopSize()
	--菜单大小
	local menuSize = MenuLayer.getLayerContentSize()

	--可视上边界位置
	local upBorderY = g_winSize.height - bulletSize.height*g_fScaleX - RechargeActiveMain.getBgWidth()

	--可视大小
	local visibleHeight = upBorderY - menuSize.height*g_fScaleX

	local girlPosY = menuSize.height*g_fScaleX + visibleHeight*0.5

	--小女孩儿
	local girlSprite = CCSprite:create(_imgPath .. "girl.png")
	girlSprite:setAnchorPoint(ccp(1,0.5))
	girlSprite:setPosition(ccp(g_winSize.width,girlPosY))
	girlSprite:setScale(g_fElementScaleRatio)
	_bgLayer:addChild(girlSprite)

	--名称位置y
	local titlePosY = upBorderY - 65*g_fElementScaleRatio

	--标题
	local titleSprite = CCSprite:create(_imgPath .. "title.png")
	titleSprite:setAnchorPoint(ccp(0.5,0))
	titleSprite:setPosition(ccp(g_winSize.width*0.5,titlePosY))
	titleSprite:setScale(g_fElementScaleRatio)
	_bgLayer:addChild(titleSprite)

	--时间
	local contentTime = TimeUtil.getSvrTimeByOffset()
	local avtiveCloseTime = nil
	if(tonumber(FestivalActiveData.getDataInfo().tpye) == 2 )then
		avtiveCloseTime = FestivalActiveData.getEndTime() - 86400
	else
		avtiveCloseTime = FestivalActiveData.getEndTime()
	end
	local timeLabel = nil
	if(contentTime <= avtiveCloseTime )then
		local beginTimeString = TimeUtil.getTimeFormatChnYMDHM(FestivalActiveData.getStartTime())
		
		---是的 没错 FestivalActiveData.getDataInfo().tpye没写错 就是tpye  策划写错了				
		local endTimeString = TimeUtil.getTimeFormatChnYMDHM(avtiveCloseTime)
		timeLabel = CCLabelTTF:create(beginTimeString .. " - " .. endTimeString,g_sFontName,18)
	elseif(tonumber(FestivalActiveData.getDataInfo().tpye) == 2 )then
		--print("GetLocalizeStringBydjn_190TimeUtil.getTimeFormatChnYMDHMavtiveCloseTime",GetLocalizeStringBy("djn_190",TimeUtil.getTimeFormatChnYMDHM(avtiveCloseTime) ))
		local timeStr  = GetLocalizeStringBy("djn_190",TimeUtil.getTimeFormatChnYMDHM(FestivalActiveData.getEndTime()) )
		timeLabel = CCLabelTTF:create( timeStr, g_sFontName,18 )
	end

	timeLabel:setColor(ccc3(0x00,0xff,0x18))
	timeLabel:setAnchorPoint(ccp(0.5,1))
	timeLabel:setPosition(ccp(g_winSize.width*0.5,titlePosY - 5*g_fElementScaleRatio))
	timeLabel:setScale(g_fElementScaleRatio)
	_bgLayer:addChild(timeLabel)

	local secBgPosX = 10*g_fElementScaleRatio
	local secBgPosY = titlePosY - 30*g_fElementScaleRatio
	local secBgHeightGap = secBgPosY - menuSize.height*g_fScaleX

	--如果是副本掉落
	if _activeType == FestivalActiveData.tagCopyDrop then
		_secBgSize = CCSizeMake(g_winSize.width*420/640,secBgHeightGap - 30*g_fElementScaleRatio)
	--如果是合成
	elseif _activeType == FestivalActiveData.tagCompose then
		_secBgSize = CCSizeMake(g_winSize.width*425/640,secBgHeightGap - 80*g_fElementScaleRatio)
	end

	--二级背景图
	_secondBgSprite = CCScale9Sprite:create(CCRectMake(50,50,6,4),"images/recharge/festival/inner_bg.png")
	_secondBgSprite:setPreferredSize(_secBgSize)
	_secondBgSprite:setAnchorPoint(ccp(0,1))
	_secondBgSprite:setPosition(ccp(secBgPosX,secBgPosY))
	_bgLayer:addChild(_secondBgSprite)

	--创建scrollView相关的UI
	createScrollUI()

	--如果是合成的话有合成按钮
	if _activeType == FestivalActiveData.tagCompose then
		local bgMenu = CCMenu:create()
		bgMenu:setPosition(ccp(0,0))
		_bgLayer:addChild(bgMenu)

		local composeMenuItem = LuaCC.create9ScaleMenuItem("images/common/btn/btn_purple2_n.png","images/common/btn/btn_purple2_h.png",CCSizeMake(200,73),GetLocalizeStringBy("zzh_1252"),ccc3(0xfe,0xdb,0x1c),35,g_sFontPangWa,1,ccc3(0x00,0x00,0x00))
		composeMenuItem:setAnchorPoint(ccp(0.5,0))
	    composeMenuItem:setPosition(ccp(secBgPosX + _secBgSize.width*0.5,menuSize.height*g_fScaleX + 10*g_fElementScaleRatio))
	    composeMenuItem:registerScriptTapHandler(composeCallBack)
		composeMenuItem:setScale(g_fElementScaleRatio)
		bgMenu:addChild(composeMenuItem)
	end
end

--==================== Entrance ====================
--[[
	@des 	:入口函数
--]]
function createLayer()
	init()

	_bgLayer = CCLayer:create()

	--得到当前活动的类型
	_activeType = FestivalActiveData.getActivityType()
	
	createUI()

	return _bgLayer
end