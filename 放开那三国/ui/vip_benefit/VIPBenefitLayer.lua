-- Filename：	VIPBenefitLayer.lua
-- Author：		Zhang zihang
-- Date：		2014-4-1
-- Purpose：		vip福利界面

--本想放在rechargeActive文件夹下，后来华仔反应那里东西太多，所以就拿出来了

module("VIPBenefitLayer", package.seeall)

require "script/ui/main/MainScene"
require "script/ui/vip_benefit/VIPNumTool"
require "script/network/Network"
require "script/ui/main/BulletinLayer"
require "script/ui/rechargeActive/RechargeActiveMain"
require "script/ui/main/MenuLayer"
require "script/ui/vip_benefit/VIPBenefitCell"
require "script/ui/vip_benefit/VIPBenefitData"
require "script/ui/vip_benefit/VIPBenefitController"
local scrollBg
local vipBenefitBottom
local VBSize
local _rewardTable
local giftButton
local vipPowerItem
local haveHad
local layer
local haveLing
local _imagePath
local _btnAry = nil
local _kDayGift = 1
local _kWeekGift = 2
local _viewBgSprite
local _alreadyBuyWeekGiftBag
local _btnHeight
local _tableView
local _timeCountDown
local _time 
local _countdownLable
local firstTag = 103
local secondTag = 104
local function init()
	scrollBg = nil
	vipBenefitBottom = nil
	VBSize = nil
	_rewardTable = {}
	giftButton = nil
	vipPowerItem = nil
	haveHad = nil
	layer = nil
	haveLing = nil
	_imagePath = {
        tap_btn_n = "images/common/btn/tab_button/btn1_n.png",
        tap_btn_h = "images/common/btn/tab_button/btn1_h.png"
    }
    _btnAry = {}
    _viewBgSprite = nil
    _alreadyBuyWeekGiftBag = nil
    _btnHeight = nil
    _tableView = nil
    _timeCountDown = nil
    _time = nil
    _countdownLable = nil
end


local function vipPowerCallBack()
	require "script/ui/shop/VipPrivilegeLayer"
	VipPrivilegeLayer.addPopLayer()
end

function enableCallback()
	giftButton:setEnabled(true)
	vipPowerItem:setEnabled(true)
	giftButton:setVisible(false)
	haveHad = CCSprite:create("images/sign/receive_already.png")
	haveHad:setAnchorPoint(ccp(0.5,0.5))
	haveHad:setPosition(ccp(VBSize.width/2,5+giftButton:getContentSize().height/2))
	vipBenefitBottom:addChild(haveHad)
end

--领取每日奖励的回调
function getTheGifts(cbFlag, dictData, bRet)
	if not bRet then
		return
	end

	if cbFlag == "vipbonus.fetchVipBonus" then

		require "script/model/user/UserModel"
		print("_rewardTable~~~~")
		print_t(_rewardTable)
		for i = 1,#_rewardTable do
			local RTpye = _rewardTable[i].type
			local RNum = _rewardTable[i].num
			if RTpye == "silver" then
				UserModel.addSilverNumber(tonumber(RNum))
			elseif RTpye == "soul" then
				UserModel.addSoulNum(tonumber(RNum))
			elseif RTpye == "gold" then
				UserModel.addGoldNumber(tonumber(RNum))
			elseif RTpye == "execution" then
				UserModel.addEnergyValue(tonumber(RNum))
			elseif RTpye == "stamina" then
				UserModel.addStaminaNumber(tonumber(RNum))
			elseif RTpye == "jewel" then
				UserModel.addJewelNum(tonumber(RNum))
			elseif RTpye == "prestige" then
				UserModel.addPrestigeNum(tonumber(RNum))
			end
		end

		giftButton:setEnabled(false)
		vipPowerItem:setEnabled(false)
		require "script/ui/item/ReceiveReward"
		
		haveLing = 1
		VIPBenefitData.writeHave(haveLing)
		delateFistTip()
		--刷新小红点提示
		require "script/ui/rechargeActive/RechargeActiveMain"
		RechargeActiveMain.refreshweekGiftBagTip()
		enableCallback()
		ReceiveReward.showRewardWindow(_rewardTable,nil)
	end
end

local function getReward()
	require "script/ui/hero/HeroPublicUI"
	require "script/ui/item/ItemUtil"
	if HeroPublicUI.showHeroIsLimitedUI() then

	elseif ItemUtil.isBagFull() then

	else
		local arg = CCArray:create()
		Network.rpc(getTheGifts, "vipbonus.fetchVipBonus","vipbonus.fetchVipBonus", arg, true)
	end
end

local function createScrollView()
	local scrollSize = scrollBg:getContentSize()
	local contentScrollView = CCScrollView:create()
	contentScrollView:setViewSize(CCSizeMake(scrollSize.width, scrollSize.height))
	contentScrollView:setDirection(kCCScrollViewDirectionHorizontal)
	contentScrollView:setTouchPriority(-600)
	local scrollLayer = CCLayer:create()
	contentScrollView:setContainer(scrollLayer)

	local rewardTable = {}
	rewardTable = VIPNumTool.unpackGiftInfo()
	local rewardTableNum = table.count(rewardTable)
	local scrollWide = rewardTableNum*121

	scrollLayer:setContentSize(CCSizeMake(scrollWide,scrollSize.height))
	scrollLayer:setPosition(ccp(0,0))

	contentScrollView:setPosition(ccp(0,0))

	scrollBg:addChild(contentScrollView)

	local picBeginX = 11.5
	_rewardTable = {}
	for k,v in pairs(rewardTable) do
		local rewardSprite = {}
		local rewardNum = {}
		local rewardName = {}
		local newTable = {}
		rewardSprite,rewardNum,rewardName,newTable= VIPNumTool.vipGiftDetial(v)
		table.insert(_rewardTable,newTable)

		rewardSprite:setAnchorPoint(ccp(0,1))
		rewardSprite:setPosition(ccp(picBeginX,scrollSize.height-13))
		scrollLayer:addChild(rewardSprite)

		local spriteSize = rewardSprite:getContentSize()
		picBeginX = picBeginX + spriteSize.width + 23

		local numTxt = nil
		if (rewardName == GetLocalizeStringBy("lic_1509")) then  -- modified by yangrui at 2015-12-03
			numTxt = CCRenderLabel:create(string.convertSilverUtilByInternational(rewardNum),g_sFontName,18,1,ccc3(0x00,0x00,0x00),type_stroke)
		else
			numTxt = CCRenderLabel:create(tostring(rewardNum),g_sFontName,18,1,ccc3(0x00,0x00,0x00),type_stroke)
		end
		numTxt:setColor(ccc3(0x00,0xff,0x18))
		numTxt:setAnchorPoint(ccp(1,0))
		numTxt:setPosition(ccp(spriteSize.width-7,3))
		rewardSprite:addChild(numTxt)

		local nameTxt = CCLabelTTF:create(tostring(rewardName), g_sFontName ,18)
		nameTxt:setColor(ccc3(0xff,0xff,0xff))
		nameTxt:setAnchorPoint(ccp(0.5,1))
		nameTxt:setPosition(ccp(spriteSize.width/2,-5))
		rewardSprite:addChild(nameTxt)
		
		-- 越南版本
		if(Platform.getLayout ~= nil and Platform.getLayout() == "enLayout" )then
			nameTxt:setVisible(false)
		end
	end
	print("_rewardTable~~~~~")
	print_t(_rewardTable)
	local menuInner = CCMenu:create()
    menuInner:setPosition(ccp(0,0))
    menuInner:setTouchPriority(-551)
    vipBenefitBottom:addChild(menuInner)

	giftButton = LuaCC.create9ScaleMenuItem("images/common/btn/btn1_d.png","images/common/btn/btn1_n.png",CCSizeMake(200, 73),GetLocalizeStringBy("key_1715"),ccc3(0xfe, 0xdb, 0x1c),35,g_sFontPangWa,1, ccc3(0x00, 0x00, 0x00))
	giftButton:setAnchorPoint(ccp(0.5,0))
	giftButton:setPosition(ccp(VBSize.width/2,5))
	giftButton:registerScriptTapHandler(getReward)
	menuInner:addChild(giftButton)

	local rewardButtonSize = giftButton:getContentSize()



	-- haveHad = LuaCC.create9ScaleMenuItem("images/common/btn/btn1_g.png","images/common/btn/btn1_g.png",CCSizeMake(200, 73),GetLocalizeStringBy("key_1369"),ccc3(0xff, 0xff, 0xff),35,g_sFontPangWa,1, ccc3(0x00, 0x00, 0x00))

	--0为可以领取
	if tonumber(haveLing) == 0 then
		giftButton:setVisible(true)
		--1为已经领取
	elseif tonumber(haveLing) == 1 then
		giftButton:setVisible(false)
		haveHad = CCSprite:create("images/sign/receive_already.png")
		haveHad:setScale(1.4)
		haveHad:setAnchorPoint(ccp(0.5,0.5))
		haveHad:setPosition(ccp(VBSize.width/2,5+rewardButtonSize.height/2))
		vipBenefitBottom:addChild(haveHad)
	end
end

function  doWeHave()
	
		haveLing = VIPBenefitData.getHave()   --tonumber(dictData.ret.bonus)
		_alreadyBuyWeekGiftBag = VIPBenefitData.getWeekGiftBag()     --dictData.ret.week_gift
		local bulletSize = RechargeActiveMain.getTopSize()
		local rechargeHeight = RechargeActiveMain.getBgWidth()
		local menuLayerSize = MenuLayer.getLayerContentSize()

		local sunPosY = g_winSize.height - bulletSize.height*MainScene.elementScale - rechargeHeight - menuLayerSize.height*MainScene.elementScale - _btnHeight*MainScene.elementScale - 30*MainScene.elementScale
		--一个太阳光芒的图
		local sunShine = CCSprite:create("images/recharge/vip_benefit/sunShine.png")
		sunShine:setPosition(ccp(g_winSize.width/2,sunPosY))
		sunShine:setAnchorPoint(ccp(0.5,1))
		sunShine:setScale(MainScene.elementScale)
		_viewBgSprite:addChild(sunShine)

		local zhenPosY = sunPosY
		--一个美女的图
		local missZhen = CCSprite:create("images/recharge/vip_benefit/zhenji.png")
		missZhen:setAnchorPoint(ccp(0,1))
		missZhen:setPosition(ccp(0,zhenPosY))
		missZhen:setScale(g_fScaleY * 1.1)
		_viewBgSprite:addChild(missZhen)	

		bFPosY = sunPosY - 20*g_fScaleY
		--胡蝶
		local butterFly = CCSprite:create("images/recharge/vip_benefit/butterfly.png")
		butterFly:setPosition(ccp(g_winSize.width,bFPosY))
		butterFly:setAnchorPoint(ccp(1,1))
		butterFly:setScale(MainScene.elementScale)
		_viewBgSprite:addChild(butterFly)

		local vipBPosY = menuLayerSize.height*MainScene.elementScale + 10*MainScene.elementScale

		--奖励框的背景
		vipBenefitBottom = CCScale9Sprite:create(CCRectMake(33, 35, 12, 45),"images/recharge/vip_benefit/vipBB.png")
		vipBenefitBottom:setPreferredSize(CCSizeMake(630,255))
		vipBenefitBottom:setPosition(ccp(g_winSize.width/2,0))
		vipBenefitBottom:setScale(MainScene.elementScale)
		vipBenefitBottom:setAnchorPoint(ccp(0.5,0))
		_viewBgSprite:addChild(vipBenefitBottom)

		VBSize = vipBenefitBottom:getContentSize() 

		local everyDayB = CCScale9Sprite:create(CCRectMake(86, 32, 4, 3),"images/recharge/vip_benefit/everyday.png")
		everyDayB:setPreferredSize(CCSizeMake(380,68))
		everyDayB:setAnchorPoint(ccp(0.5,0.5))
		everyDayB:setPosition(ccp(VBSize.width/2,VBSize.height-3))
		vipBenefitBottom:addChild(everyDayB)

		local everyDaySize = everyDayB:getContentSize()

		local levelDes = CCSprite:create("images/recharge/vip_benefit/vipwenzi.png")
		levelDes:setAnchorPoint(ccp(0.5,0.5))
		levelDes:setPosition(ccp(everyDaySize.width/2,everyDaySize.height/2))
		everyDayB:addChild(levelDes)

		local LDSize = levelDes:getContentSize()

		local vipLevelNum = VIPNumTool.getVIPNumSprite()
		vipLevelNum:setAnchorPoint(ccp(0.5,0.5))
		vipLevelNum:setPosition(ccp(86,LDSize.height/2))
		levelDes:addChild(vipLevelNum)

		scrollBg = CCScale9Sprite:create("images/common/bg/bg_ng_attr.png")
		scrollBg:setPreferredSize(CCSizeMake(605,145))
		scrollBg:setAnchorPoint(ccp(0.5,1))
		scrollBg:setPosition(ccp(VBSize.width/2,VBSize.height-everyDaySize.height/2-3))
		vipBenefitBottom:addChild(scrollBg)

		--查看vip特权按钮
		local image_n = "images/common/btn/btn_violet_n.png"
	    local image_h = "images/common/btn/btn_violet_h.png"
	    local rect_full   = CCRectMake(0,0,119,64)
	    local rect_inset  = CCRectMake(25,20,13,3)
	    local btn_size_n    = CCSizeMake(220, 64)
	    local btn_size_h    = CCSizeMake(222, 64)   
	    local text_color_n  = ccc3(0xfe, 0xdb, 0x1c) 
	    local text_color_h  = ccc3(0xfe, 0xdb, 0x1c) 
	    local font          = g_sFontPangWa
	    local font_size     = 30
	    local strokeCor_n   = ccc3(0x00, 0x00, 0x00) 
	    local strokeCor_h   = ccc3(0x00, 0x00, 0x00)  
	    local stroke_size   = 1

	    local menu = CCMenu:create()
	    menu:setPosition(ccp(0,0))
	    menu:setTouchPriority(-551)
	    vipBenefitBottom:addChild(menu)

	    local minusHeight = sunPosY - (menuLayerSize.height*MainScene.elementScale + 10*g_fScaleY + VBSize.height*MainScene.elementScale + everyDaySize.height/2*MainScene.elementScale)
	    local vipPosY = sunPosY - minusHeight*0.9

		vipPowerItem = LuaCCMenuItem.createMenuItemOfRender( image_n, image_h, rect_full, rect_inset, rect_full, rect_inset, btn_size_n, btn_size_h, GetLocalizeStringBy("key_3054"), text_color_n, text_color_h, font, font_size, strokeCor_n, strokeCor_h, stroke_size )
		vipPowerItem:setAnchorPoint(ccp(0.5,0))
		vipPowerItem:setPosition(ccp(vipBenefitBottom:getContentSize().width*0.7,vipBenefitBottom:getContentSize().height*1.1))
		vipPowerItem:registerScriptTapHandler(vipPowerCallBack)
		menu:addChild(vipPowerItem)

		local desPosY = sunPosY - minusHeight*0.56
		--一堆文字描述的背景
		local desButtom = CCScale9Sprite:create("images/recharge/vip_benefit/desButtom.png")
		desButtom:setPreferredSize(CCSizeMake(380,150))
		desButtom:setAnchorPoint(ccp(0.5,0))
		desButtom:setPosition(ccp(vipPowerItem:getContentSize().width*0.5,vipPowerItem:getContentSize().height*1.08))
		vipPowerItem:addChild(desButtom)

		local desBSize = desButtom:getContentSize()

		local arrow = CCSprite:create("images/common/star_bg.png")
		arrow:setAnchorPoint(ccp(0.5,0.5))
		arrow:setPosition(ccp(desBSize.width/2,desBSize.height*2/3+20))
		arrow:setScaleX(1.5)
		desButtom:addChild(arrow)

		--一堆文字
		local desVIP = CCSprite:create("images/recharge/vip_benefit/des.png")
		desVIP:setAnchorPoint(ccp(0.5,0.5))
		desVIP:setPosition(ccp(desBSize.width/2,desBSize.height/2))
		desButtom:addChild(desVIP)

		local flowerPosY = sunPosY - minusHeight*0.25
		--VIP福利文字背景
		local vipFlower = CCSprite:create("images/recharge/vip_benefit/vipflower.png")
		vipFlower:setPosition(ccp(g_winSize.width*2/3,_viewBgSprite:getContentSize().height*0.98))
		vipFlower:setAnchorPoint(ccp(0.5,1))
		_viewBgSprite:addChild(vipFlower)

		local flowerSize = vipFlower:getContentSize()
		--VIP福利文字
		local benefitTitle = CCSprite:create("images/recharge/vip_benefit/fuli.png")
		benefitTitle:setPosition(ccp(flowerSize.width/2,15))
		benefitTitle:setAnchorPoint(ccp(0.5,0))
		benefitTitle:setScale(MainScene.elementScale)
		vipFlower:addChild(benefitTitle)

		createScrollView()
	
end


--创建按钮的切换
function createBtn(text)
    local insertRect = CCRectMake(35,20,1,1)
    local tapBtnN = CCScale9Sprite:create(insertRect,_imagePath.tap_btn_n)
    tapBtnN:setPreferredSize(CCSizeMake(211,43))
    local tapBtnH = CCScale9Sprite:create(insertRect,_imagePath.tap_btn_h)
    tapBtnH:setPreferredSize(CCSizeMake(211,53))
    
    local label1 = CCRenderLabel:create(text, g_sFontPangWa, 24, 2, ccc3(0x00, 0x00, 0x00 ), type_stroke)
    label1:setColor(ccc3(0xff, 0xf6, 0x00))
    label1:setAnchorPoint(ccp(0.5,0.5))
    label1:setPosition(ccp(tapBtnN:getContentSize().width*0.5,tapBtnN:getContentSize().height*0.45))
    tapBtnH:addChild(label1) 

    local label2 = CCRenderLabel:create(text, g_sFontPangWa, 24, 1, ccc3(0xd7, 0xa5, 0x56 ), type_stroke)
    label2:setColor(ccc3(0xb9, 0x6e, 0x00))
    label2:setAnchorPoint(ccp(0.5,0.5))
    label2:setPosition(ccp(tapBtnH:getContentSize().width*0.5,tapBtnH:getContentSize().height*0.4))
    tapBtnN:addChild(label2) 
    local btn = CCMenuItemSprite:create(tapBtnN, nil,tapBtnH)
    btn:setAnchorPoint(ccp(0.5,0.5))
    btn:registerScriptTapHandler(changeLayer)

    return btn
end
--切换页面的回调
function changeLayer(pValue )
	 for i=1,#_btnAry do
        if(i == pValue )then
            _btnAry[pValue]:setEnabled(false)
        else
            _btnAry[i]:setEnabled(true)
        end
    end
    if(_kDayGift == pValue)then
    	createViewBgSprite()
    	 doWeHave()
    else
    	createViewBgSprite()
    	createCountdown()
    end
end
function createViewBgSprite( ... )
	local bulletSize = RechargeActiveMain.getTopSize()
	local rechargeHeight = RechargeActiveMain.getBgWidth()
	local menuLayerSize = MenuLayer.getLayerContentSize()
	if(_viewBgSprite)then
		_viewBgSprite:removeFromParentAndCleanup(true)
		_viewBgSprite = nil
	end
	--tableView背景
	local sunPosY = g_winSize.height - bulletSize.height*MainScene.elementScale - rechargeHeight - menuLayerSize.height*MainScene.elementScale - _btnHeight*MainScene.elementScale - 30*MainScene.elementScale
	_viewBgSprite = CCScale9Sprite:create(CCRectMake(53,57,10,10),"images/recharge/change/list_bg.png")
	_viewBgSprite:setPreferredSize(CCSizeMake(g_winSize.width,sunPosY))
	_viewBgSprite:setPosition(ccp(5,(menuLayerSize.height+20)*MainScene.elementScale))
	layer:addChild(_viewBgSprite)
end
function updateTime( ... )
	_time = _time -1
	_timeCountDown:setString(TimeUtil.getTimeString(_time))
	if(_time <= 0)then

		--刷新界面
		print("_time < 0")
		refreshWeekUpdateUI()
		_time = 7*24*3600
	end
end
--创建倒计时
function createCountdown( ... )
	--重置倒计时
	_countdownLable = CCLabelTTF:create(GetLocalizeStringBy("fqq_067"),g_sFontName,25)
	_countdownLable:setColor(ccc3(0x00,0xe4,0xff))
	_countdownLable:setAnchorPoint(ccp(0.5,1))
	_countdownLable:setScale(MainScene.elementScale)
	_countdownLable:setPosition(ccp(_viewBgSprite:getContentSize().width*0.38,_viewBgSprite:getContentSize().height- 15))
	_viewBgSprite:addChild(_countdownLable)
	if(_time)then
		_time = nil
	end
	_time = VIPBenefitData.getCountDown()
	_timeCountDown = CCLabelTTF:create(TimeUtil.getTimeString(_time),g_sFontName,21)
	_timeCountDown:setColor(ccc3(0x00,0xff,0x18))
	_timeCountDown:setAnchorPoint(ccp(0,0.5))
	_timeCountDown:setPosition(ccp(_countdownLable:getContentSize().width,_countdownLable:getContentSize().height*0.5))
	_countdownLable:addChild(_timeCountDown)
	schedule(_viewBgSprite,updateTime,1)
	createWeekGiftUI()
end
--创建每周礼包礼包界面
function createWeekGiftUI( )
	
	
	local height = _viewBgSprite:getContentSize().height - _countdownLable:getContentSize().height*MainScene.elementScale - 40*MainScene.elementScale
	--创建tableview
	local data = VIPBenefitData.getAllWeekGiftBag()
	 local h = LuaEventHandler:create(function ( fn,p_table,a1,a2)
            local r
            if fn == "cellSize" then
                r = CCSizeMake(_viewBgSprite:getContentSize().width,250*g_fScaleX)
            elseif fn == "cellAtIndex" then
                a2 = VIPBenefitCell.createCell(data[a1 + 1], a1 + 1,-630)
                r = a2
            elseif fn == "numberOfCells" then
                r = table.count(data)

            end
            return r
        end)
	 print("_viewBgSprite:getContentSize().width",_viewBgSprite:getContentSize().width)
        _tableView = LuaTableView:createWithHandler(h,CCSizeMake(_viewBgSprite:getContentSize().width,height))
        _viewBgSprite:addChild(_tableView)
        _tableView:setVerticalFillOrder(kCCTableViewFillTopDown)
        _tableView:setAnchorPoint(ccp(0.5,0))
        _tableView:setPosition(ccp(_viewBgSprite:getContentSize().width * 0.5, 5))
        _tableView:ignoreAnchorPointForPosition(false)
        _tableView:setTouchPriority(-600)
end
function createExchangeBtnAndBg( ... )
	local bulletSize = RechargeActiveMain.getTopSize()
	local rechargeHeight = RechargeActiveMain.getBgWidth()
	local menuLayerSize = MenuLayer.getLayerContentSize()
	-- 标签文本
    local btnLabel = {
        GetLocalizeStringBy("fqq_065"),
        GetLocalizeStringBy("fqq_066")
    }
    local menu = CCMenu:create()
    menu:setPosition(ccp(0, 0))
    menu:setTouchPriority(-600)
    layer:addChild(menu)
    local btn
    for i=1,2 do
        btn = createBtn(btnLabel[i])
        btn:setPosition(ccp(20 + 230 * (i - 1)*MainScene.elementScale,layer:getContentSize().height - bulletSize.height*MainScene.elementScale - rechargeHeight - 10*MainScene.elementScale))
        btn:setScale(MainScene.elementScale)
        btn:setAnchorPoint(ccp(0,1))
        --每日奖励的红点
	    if(i == 1)then
	     	if(not VIPBenefitData.dayGiftBag())then
	     
	     	else
	     		local tipSprite= CCSprite:create("images/common/tip_2.png")
			      	  tipSprite:setAnchorPoint(ccp(1,1))
			      	  tipSprite:setPosition(ccp(btn:getContentSize().width*0.98,btn:getContentSize().height*0.98))
				btn:addChild(tipSprite,1,firstTag)
	    	end
	     
	    end
	    if(i == 2)then
	    	local data =  VIPBenefitData.getWeekGiftBag()
	    	if(not table.isEmpty(data))then
		    
		    else
		    	local tipSprite= CCSprite:create("images/common/tip_2.png")
	     			  tipSprite:setAnchorPoint(ccp(1,1))
	     			  tipSprite:setPosition(ccp(btn:getContentSize().width*0.98,btn:getContentSize().height*0.98))
	     		btn:addChild(tipSprite,1,secondTag)
		    end
	    end
        if i == 1 then
            btn:setEnabled(false)
        else
            btn:setEnabled(true)
        end
        menu:addChild(btn,1,i)
        table.insert(_btnAry,btn)
    end
   
    _btnHeight = btn:getContentSize().height
	local sunPosY = g_winSize.height - bulletSize.height*MainScene.elementScale - rechargeHeight - menuLayerSize.height*MainScene.elementScale - _btnHeight*MainScene.elementScale - 30*MainScene.elementScale
	if(_viewBgSprite)then
		_viewBgSprite:removeFromParentAndCleanup(true)
		_viewBgSprite = nil
	end
    --tableView背景
	_viewBgSprite = CCScale9Sprite:create(CCRectMake(53,57,10,10),"images/recharge/change/list_bg.png")
	_viewBgSprite:setPreferredSize(CCSizeMake(g_winSize.height,sunPosY))
	_viewBgSprite:setPosition(ccp(5,(menuLayerSize.height+20)*MainScene.elementScale))
	layer:addChild(_viewBgSprite)
end
function createLayer()
	init()
	layer = CCLayer:create()
	createExchangeBtnAndBg()
	doWeHave()
	return layer
end

function readHave()
	return haveLing
end
--购买后刷新界面
function updateUI( ... )
	if(_tableView)then
		_tableView:removeFromParentAndCleanup(true)
		_tableView = nil
	end
	createWeekGiftUI()
end
--自然周自动刷新
function refreshWeekUpdateUI( ... )
	--先判断VIp福利是否开启
	if(not ActiveCache.isOpenVIPBenefit())then
		print("VIp福利否开启")
		return
	else
		--判断是否在当前页面
		if(layer == nil)then
			print("界面不存在")
			return
		else
			print("界面存在")
			local function callback( ... )
				print("刷新界面")
				updateUI()
			end
			VIPBenefitController.getVipBonusInfo(callback)
		end
	end
end
--删除第一个小红点
function delateFistTip( ... )
	local item = tolua.cast(_btnAry[1],"CCMenuItemSprite")
	local tipSprite = tolua.cast(item:getChildByTag(firstTag),"CCSprite")
	if(tipSprite)then
		tipSprite:removeFromParentAndCleanup(true)
	end
end
--删除第二个小红点
function delateSecondTip( ... )
	local tipSprite = _btnAry[2]:getChildByTag(secondTag)
	if(tipSprite)then
		tipSprite:removeFromParentAndCleanup(true)
	end
end