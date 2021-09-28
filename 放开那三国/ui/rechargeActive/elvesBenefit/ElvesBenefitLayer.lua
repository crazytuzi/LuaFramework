-- Filename：	ElvesBenefitLayer.lua
-- Author：		bzx
-- Date：		2015-5-14
-- Purpose：		资源矿福利活动界面

module("ElvesBenefitLayer", package.seeall)

require "script/ui/main/MainScene"
require "script/model/utils/ActivityConfigUtil"
require "script/utils/TimeUtil"
require "script/ui/tip/AnimationTip"

local scrollBg
local titlePosY
local backGroundPic
local activeMes
local titleBg
local layer
local timePosY
local duringTime
local openingData = {}
local menuLayerSize
local remainPoint
local remainCard
local downHeight
local accumulateNum
local cardNum

local rate

local isOpenCard
local allPoint
local haveCard
local cardOverNum

local function init()
	scrollBg = nil
	titlePosY = nil
	backGroundPic = nil
	activeMes = {}
	openingData = {}
	timePosY = nil
	titleBg = nil
	duringTime = nil
	layer = nil
	menuLayerSize = nil
	remainPoint = 0
	remainCard = 0
	rate = 0
	downHeight = nil
	accumulateNum = nil
	cardNum = nil
	isOpenCard = nil
	allPoint = 0
	haveCard = 0
	cardOverNum = 0
end

--福利活动
local function getWealAllData()
	local wealActive= ActivityConfigUtil.getDataByKey("mineralelves")
    return wealActive
end

local function getWealData()
	return getWealAllData().data
end

local function openedActiveMes()
	activeMes = {}

	-- for k,v in pairs(getWealData()) do
	-- 	if tonumber(v.open_act) == 1 then
	-- 		openingData = v
	-- 		activeMes.expl = v.expl
	-- 		activeMes.desc = v.desc
	-- 		activeMes.name = v.name
	-- 		rate = v.card_cost
	-- 		isOpenCard = v.open_draw
	-- 		break
	-- 	end
	-- end

	local allData = getWealAllData()

	local wealData = getWealData()
	openingData = wealData[1]


	activeMes.expl = openingData.expl
	activeMes.desc = openingData.desc
	activeMes.name = openingData.name
	activeMes.openTime = allData.start_time
	activeMes.endTime = allData.end_time

	rate = openingData.card_cost
	isOpenCard = openingData.open_draw
end

local function counLine(str)
	local strLen = 0
	local i =1
	local enter = 0
	while i<= #str do
		if(string.byte(str,i) > 127) then
			-- 汉字
			strLen = strLen + 1
			i= i+ 3
		elseif(string.byte(str,i) == 10) then
			--换行符
			i =i+1
			enter = enter+1
		elseif(string.byte(str,i) == 32) then
			strLen = strLen + 1/3
			i = i+1
		else
			--英文
			i =i+1
			strLen = strLen + 1
		end
	end

	--21号字
	local linNum = math.ceil(strLen/(405/23))+enter
	local linHeight = linNum*23

	return linHeight
end

local function createScrollContent()
	local contentScrollView = CCScrollView:create()
	contentScrollView:setViewSize(CCSizeMake(scrollBg:getContentSize().width, scrollBg:getContentSize().height))
	contentScrollView:setDirection(kCCScrollViewDirectionVertical)
	local layer = CCLayer:create()
	contentScrollView:setContainer(layer)
	activeMes.expl = string.gsub(activeMes.expl, "\\n", "\n")
	activeMes.desc = string.gsub(activeMes.desc, "\\n", "\n")
	--activeMes.expl = GetLocalizeStringBy("key_3327")
	local EXPL = CCRenderLabel:createWithAlign(tostring(activeMes.expl), g_sFontName, 23, 1, ccc3( 0x00, 0x00, 0x00), type_stroke,CCSizeMake(405,0), kCCTextAlignmentLeft, kCCVerticalTextAlignmentTop)
	local DES = CCRenderLabel:createWithAlign(tostring(activeMes.desc), g_sFontName, 23, 1, ccc3( 0x00, 0x00, 0x00), type_stroke,CCSizeMake(405,0), kCCTextAlignmentLeft, kCCVerticalTextAlignmentTop)

	local explHeight = EXPL:getContentSize().height
	local desHeight  = DES:getContentSize().height

	print(GetLocalizeStringBy("key_3404"),explHeight,desHeight)

	-- local addLength = 0

	-- if tonumber(explHeight) > 180 then
	-- 	addLength = addLength + tonumber(explHeight) - 180
	-- end
	-- if tonumber(desHeight) > 180 then
	-- 	addLength = addLength + tonumber(desHeight) - 180
	-- end

	local layerHeight = 180+explHeight+desHeight

	layer:setContentSize(CCSizeMake(scrollBg:getContentSize().width,layerHeight))
	layer:setPosition(ccp(0,scrollBg:getContentSize().height-layerHeight))

	contentScrollView:setPosition(ccp(0,0))

	scrollBg:addChild(contentScrollView)

	local flower = CCSprite:create("images/recharge/benefit_active/flower.png")
	flower:setPosition(ccp(layer:getContentSize().width/2,layer:getContentSize().height-40))
	flower:setAnchorPoint(ccp(0.5,0.5))
	layer:addChild(flower)

	local activeDes = CCRenderLabel:create(GetLocalizeStringBy("key_2934"), g_sFontPangWa, 25, 1, ccc3( 0xff, 0xff, 0xff), type_stroke)
	activeDes:setPosition(ccp(layer:getContentSize().width/2,layer:getContentSize().height-40))
	activeDes:setAnchorPoint(ccp(0.5,0.5))
	activeDes:setColor(ccc3(0x78,0x25,0x00))
	layer:addChild(activeDes)	

	EXPL:setPosition(ccp(layer:getContentSize().width/2,layer:getContentSize().height-80))
	EXPL:setAnchorPoint(ccp(0.5,1))
	EXPL:setColor(ccc3(0xff,0xff,0xff))
	layer:addChild(EXPL)

	local flower2 = CCSprite:create("images/recharge/benefit_active/flower.png")
	flower2:setPosition(ccp(layer:getContentSize().width/2,layer:getContentSize().height-120-explHeight))
	flower2:setAnchorPoint(ccp(0.5,0.5))
	layer:addChild(flower2)

	local activeExpl = CCRenderLabel:create(GetLocalizeStringBy("key_1297"), g_sFontPangWa, 25, 1, ccc3( 0xff, 0xff, 0xff), type_stroke)
	activeExpl:setPosition(ccp(layer:getContentSize().width/2,layer:getContentSize().height-120-explHeight))
	activeExpl:setAnchorPoint(ccp(0.5,0.5))
	activeExpl:setColor(ccc3(0x78,0x25,0x00))
	layer:addChild(activeExpl)

	DES:setPosition(ccp(layer:getContentSize().width/2,layer:getContentSize().height-160-explHeight))
	DES:setAnchorPoint(ccp(0.5,1))
	DES:setColor(ccc3(0xff,0xff,0xff))
	layer:addChild(DES)
end

local function topMessage()
	-- local startYMD = TimeUtil.getTimeFormatChnYMDHM(getWealStartTime())
	-- local endYMD = TimeUtil.getTimeFormatChnYMDHM(getWealEndTime())

	local startYMD = getFormatYMDHM(1)
	local endYMD = getFormatYMDHM(2)

	timePosY = titlePosY - titleBg:getContentSize().height*g_fScaleX - 12*MainScene.elementScale 

	duringTime = CCRenderLabel:create(startYMD .. "  -  " .. endYMD,g_sFontName,  18, 1, ccc3( 0x00, 0x00, 0x00), type_stroke)
	duringTime:setColor(ccc3(0x00, 0xff, 0x18))
	duringTime:setPosition(ccp(g_winSize.width/2,timePosY))
	duringTime:setAnchorPoint(ccp(0.5,1))
	layer:addChild(duringTime,99)

	duringTime:setScale(MainScene.elementScale)

	local activeName = CCRenderLabel:create(tostring(activeMes.name),g_sFontPangWa,  40, 1, ccc3( 0x00, 0x00, 0x00), type_stroke)
	activeName:setColor(ccc3(0xff,0xf6,0x00))
	activeName:setAnchorPoint(ccp(0.5,0.5))
	activeName:setPosition(ccp(titleBg:getContentSize().width/2,titleBg:getContentSize().height/2))
	titleBg:addChild(activeName)
end

local function gotoDie()
	if tonumber(remainCard) <= 0 then
		AnimationTip.showTip(GetLocalizeStringBy("key_3207"))
	else
		require "script/ui/rechargeActive/BenefitCardLayer"
		BenefitCardLayer.showLayer(remainCard)
		--BenefitCardLayer.showLayer(100)
	end
end

local function downMessage(downHeight)
	require "script/utils/BaseUI"

	--积分
	local accumulateDes = CCRenderLabel:create(GetLocalizeStringBy("key_2346"),g_sFontPangWa,  21, 1, ccc3( 0x00, 0x00, 0x00), type_stroke)
	accumulateDes:setColor(ccc3(0xff,0xff,0xff))
	accumulateNum = CCRenderLabel:create(allPoint,g_sFontPangWa,  21, 1, ccc3( 0x00, 0x00, 0x00), type_stroke)
	accumulateNum:setColor(ccc3(0xff,0xf6,0x00))

	local accumulation = BaseUI.createHorizontalNode({accumulateDes, accumulateNum})
	accumulation:setAnchorPoint(ccp(0, 0.5))
	accumulation:setPosition(ccp(30*MainScene.elementScale,menuLayerSize.height*g_fScaleX+downHeight*2/3-20*MainScene.elementScale))
	layer:addChild(accumulation)
	accumulation:setScale(MainScene.elementScale)

	remainCard = math.floor(remainPoint/rate)
	haveCard = math.floor(allPoint/rate) - remainCard

	--翻牌次数
	local cardDes = CCRenderLabel:create(GetLocalizeStringBy("key_2329"),g_sFontPangWa,  21, 1, ccc3( 0x00, 0x00, 0x00), type_stroke)
	cardDes:setColor(ccc3(0xff,0xff,0xff))
	cardNum = CCRenderLabel:create(remainCard,g_sFontPangWa,  21, 1, ccc3( 0x00, 0x00, 0x00), type_stroke)
	cardNum:setColor(ccc3(0xff,0xf6,0x00))

	local carding = BaseUI.createHorizontalNode({cardDes, cardNum})
	carding:setAnchorPoint(ccp(0, 0.5))
	carding:setPosition(ccp(210*MainScene.elementScale,menuLayerSize.height*g_fScaleX+downHeight/3-5*MainScene.elementScale))
	layer:addChild(carding)
	carding:setScale(MainScene.elementScale)

	--已翻牌次数
	local cardOverDes = CCRenderLabel:create(GetLocalizeStringBy("key_2309"),g_sFontPangWa,21,1,ccc3(0x00,0x00,0x00),type_stroke)
	cardOverDes:setColor(ccc3(0xff,0xff,0xff))
	cardOverNum = CCRenderLabel:create(haveCard,g_sFontPangWa,  21, 1, ccc3( 0x00, 0x00, 0x00), type_stroke)
	cardOverNum:setColor(ccc3(0xff,0xf6,0x00))

	local over = BaseUI.createHorizontalNode({cardOverDes,cardOverNum})
	over:setAnchorPoint(ccp(0,0.5))
	over:setPosition(ccp(30*MainScene.elementScale,menuLayerSize.height*g_fScaleX+downHeight/3-5*MainScene.elementScale))
	layer:addChild(over)
	over:setScale(MainScene.elementScale)

	local menuBar_g = CCMenu:create()
	menuBar_g:setPosition(ccp(0,0))
	layer:addChild(menuBar_g)

	local cardBtn = LuaCC.create9ScaleMenuItem("images/common/btn/btn_purple2_n.png","images/common/btn/btn_purple2_h.png",CCSizeMake(200, 73),GetLocalizeStringBy("key_1570"),ccc3(0xfe, 0xdb, 0x1c),35,g_sFontPangWa,1, ccc3(0x00, 0x00, 0x00))
	cardBtn:setAnchorPoint(ccp(0.5 , 0.5))
    cardBtn:setPosition(ccp(g_winSize.width/2+180*MainScene.elementScale, menuLayerSize.height*g_fScaleX+downHeight/2-20*MainScene.elementScale))
    cardBtn:registerScriptTapHandler(gotoDie)
	menuBar_g:addChild(cardBtn)
	cardBtn:setScale(MainScene.elementScale)
end

function fnHandlerOfNetwork(cbFlag, dictData, bRet)
	if not bRet then
		return
	end
	if cbFlag == "weal.getKaInfo" then
		remainPoint = dictData.ret.point_today
		allPoint = dictData.ret.point_add
		require "script/ui/rechargeActive/RechargeActiveMain"
		require "script/ui/main/BulletinLayer"
		require "script/ui/main/MenuLayer"

		local bulletSize = RechargeActiveMain.getTopSize()
		local rechargeHeight = RechargeActiveMain.getBgWidth()
		menuLayerSize = MenuLayer.getLayerContentSize()

		titlePosY = g_winSize.height - bulletSize.height*g_fScaleX - rechargeHeight

		backGroundPic = CCScale9Sprite:create("images/recharge/benefit_active/bg.png")
		backGroundPic:setPreferredSize(CCSizeMake(640,960))
		backGroundPic:setScale(MainScene.bgScale)
		layer:addChild(backGroundPic)

		titleBg = CCScale9Sprite:create("images/recharge/benefit_active/titlebg.png")
		titleBg:setPreferredSize(CCSizeMake(640,50))
		titleBg:setPosition(ccp(g_winSize.width/2,titlePosY))
		titleBg:setAnchorPoint(ccp(0.5,1))
		titleBg:setScale(g_fScaleX)
		layer:addChild(titleBg)

		topMessage()

		local minusHeight = 80

		if (isOpenCard ~= nil) and (tonumber(isOpenCard) == 1) then
			minusHeight = 130
		end

		local midHeight = g_winSize.height/MainScene.elementScale - bulletSize.height - rechargeHeight/g_fScaleX - menuLayerSize.height - titleBg:getContentSize().height - 12 - duringTime:getContentSize().height - 12- minusHeight
		local scrollBgY = timePosY-duringTime:getContentSize().height*g_fScaleX - 12*MainScene.elementScale

		local queen = CCSprite:create("images/recharge/benefit_active/queen.png")
		queen:setPosition(ccp(g_winSize.width,scrollBgY-(midHeight/2-30)*g_fScaleY))
		queen:setAnchorPoint(ccp(1,0.5))
		queen:setScale(MainScene.elementScale)
		layer:addChild(queen)

		scrollBg = CCScale9Sprite:create("images/recharge/benefit_active/scroll.png")
		scrollBg:setPreferredSize(CCSizeMake(g_winSize.width/MainScene.elementScale - queen:getContentSize().width+50,midHeight))
		scrollBg:setPosition(ccp(g_winSize.width-queen:getContentSize().width*MainScene.elementScale+60*MainScene.elementScale,scrollBgY))
		scrollBg:setAnchorPoint(ccp(1,1))
		scrollBg:setScale(MainScene.elementScale)
		layer:addChild(scrollBg)

		createScrollContent()
		
		if (isOpenCard ~= nil) and (tonumber(isOpenCard) == 1) then

			downHeight = g_winSize.height - menuLayerSize.height*g_fScaleX - bulletSize.height*g_fScaleX - rechargeHeight - scrollBg:getContentSize().height*MainScene.elementScale -24*MainScene.elementScale - duringTime:getContentSize().height*MainScene.elementScale

			downMessage(downHeight)

		end
	end
end

local function  getPointMessage()
	require "script/network/Network"
	local arg = CCArray:create()
	Network.rpc(fnHandlerOfNetwork, "weal.getKaInfo","weal.getKaInfo", arg, true)
end

function createLayer()
	init()

	openedActiveMes()

	getPointMessage()

	layer = CCLayer:create()

	return layer
end

local function isActiveOpen()
	return MineralElvesData.isOpen()
end

--普通副本福利活动
function isNormalCopyOpen()
	local isOpen = false
	local param = nil
	if isActiveOpen() then
		openedActiveMes()

		if openingData.nc_act ~= nil then
			isOpen = true
			param = openingData.nc_act
		end
	end

	return isOpen,param
end

--活动副本福利活动
function isActiveCopyOpen()
	local isOpen = false
	local param = nil
	
	if isActiveOpen() then
		openedActiveMes()
		if(openingData.ac_double_num ~= nil )then
			isOpen = true
			param = openingData.ac_double_num
		end
	end

	return isOpen, param
end

--军团战副本活动
function isGuildCopyOpen()
	local isOpen = false
	local param = nil
	
	if isActiveOpen() then
		openedActiveMes()
		if(openingData.lec_act ~= nil )then
			isOpen = true
			param = openingData.lec_act
		end
	end

	return isOpen, param
end

--建设度福利活动
function isConstructionOpen()
	local isOpen = false
	local param = nil

	if isActiveOpen() then
		openedActiveMes()
		if openingData.guild_donate_act ~= nil then
			isOpen = true
			param = openingData.guild_donate_act
		end
	end

	return isOpen,param
end

-- 福利活开始时间
function getWealStartTime()
    return tonumber( getWealAllData().start_time )
end

-- 福利活动结束时间
function getWealEndTime()
    return  tonumber( getWealAllData().end_time )
end

--福利活动开启时间
function getWealOpenTime()
    return tonumber( getWealAllData().need_open_time )
end

function getRate()
	return rate
end

function toANewDay(newPoint,newAll)
	remainPoint = newPoint
	allPoint = newAll
	remainCard = math.floor(remainPoint/rate)
	haveCard = math.floor(allPoint/rate) - remainCard
	accumulateNum:setString(newAll)
	cardNum:setString(remainCard)
	cardOverNum:setString(haveCard)
	require "script/ui/rechargeActive/RechargeActiveMain"
	RechargeActiveMain.refreshCardNum(remainCard)
end

function refreshNum()
	remainPoint = remainPoint-rate
	remainCard = math.floor(remainPoint/rate)
	haveCard = math.floor(allPoint/rate) - remainCard
	--accumulateNum:setString(allPoint)
	cardNum:setString(remainCard)
	cardOverNum:setString(haveCard)
	require "script/ui/rechargeActive/RechargeActiveMain"
	RechargeActiveMain.refreshCardNum(remainCard)
end

function writePreAccountNum(accountNum)
	remainPoint = accountNum
end

function getAccountNum()
	if remainPoint ~= nil and remainPoint ~= 0 then
		return remainPoint
	else
		return 0
	end
end

function writeCardCost(costNum)
	rate = costNum
end

function getCostNum()
	print("rate的值，大富科技阿卡发发大家看见",rate)
	if rate ~= nil and string.len(rate) > 0 and rate ~= 0 then
		return rate
	else
		local cardActiveData = ActivityConfigUtil.getDataByKey("weal").data
		print("活动信息，倒萨科技发达时间放假啊咖啡加快加快立法将空间的时刻")
		print_t(cardActiveData)
		cardCost = cardActiveData[1].card_cost
		print("翻牌消耗比率，三大类分开发开放就开了房咖啡机",cardCost)
		return cardCost
	end
end

function getFormatYMDHM(typeNum)
	local oriTime
	if typeNum == 1 then
		oriTime = TimeUtil.getCurDayZeroTime()
	else
		oriTime = TimeUtil.getCurDayZeroTime() + 23 * 60 * 60 + 59 * 60 + 59
	end
	return TimeUtil.getTimeFormatYMDHMS(oriTime)
	--return tostring(year) .. "-" .. tostring(month) .. "-" .. tostring(day) .. " " .. " " .. tostring(hour) .. ":" .. tostring(min)
end