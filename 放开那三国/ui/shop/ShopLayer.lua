-- Filename：	ShopLayer.lua
-- Author：		Cheng Liang
-- Date：		2013-8-22
-- Purpose：		商店

module ("ShopLayer", package.seeall)

require "script/network/RequestCenter"
require "script/model/DataCache"

require "script/ui/main/MainScene"
require "script/ui/common/LuaMenuItem"
require "script/ui/tip/AnimationTip"
require "script/model/user/UserModel"

require "script/ui/shop/PubLayer"
require "script/ui/shop/GiftsPakLayer"
require "script/ui/shop/RechargeLayer"
require "script/ui/shop/GiftService"
require "script/utils/ItemDropUtil"

local _bgLayer 			= nil
local topBg				= nil
local _curShopCacheInfo = nil	-- 商城的信息
local btnFrameSp		= nil 	

local _curDisplayLayer 	= nil

local m_powerLabel
local m_silverLabel
local m_goldLabel

local _pubButton 		= nil
local _propButton 		= nil
local _giftsButton 		= nil
local _curButton 		= nil
local rechargeBtn 		= nil

-- added by zhz
local _tipSprite		= nil	-- vip 的提示sprite
local _ksVipLabeLTag 	= 101
local _firstChargeSp	= nil
local _pubTipSp			= nil	-- 酒馆按钮上的提示
local _ksPubLabelTag 	= 102   -- 酒馆上的字的tag 

-- 初始哪个界面
local _init_tag 		= nil
Tag_Shop_Hero 	= 912001
Tag_Shop_Prop 	= 912002
Tag_Shop_Gift 	= 912003

-- 初始化
local function init( )
	_firstChargeSp	= nil
	_bgLayer 	 	= nil
	m_powerLabel	= nil
	m_silverLabel	= nil
	m_goldLabel		= nil
	topBg			= nil

	_pubButton 		= nil
	_propButton 	= nil
	_giftsButton 	= nil
	_curButton 		= nil

	_curDisplayLayer= nil
	_init_tag 		= nil

	layerWillDisappearDelegate()

end 

local function createTopUI(  )
	topBg = CCSprite:create("images/hero/avatar_attr_bg.png")
    topBg:setAnchorPoint(ccp(0,1))
    topBg:setPosition(0, _bgLayer:getContentSize().height)
    topBg:setScale(g_fScaleX/MainScene.elementScale)
    _bgLayer:addChild(topBg)
    
    local powerDescLabel = CCSprite:create("images/common/fight_value.png")
    powerDescLabel:setAnchorPoint(ccp(0.5,0.5))
    powerDescLabel:setPosition(topBg:getContentSize().width*0.13,topBg:getContentSize().height*0.43)
    topBg:addChild(powerDescLabel)
    
    m_powerLabel = CCRenderLabel:create("" .. UserModel.getFightForceValue(), g_sFontName, 23, 1.5, ccc3(0, 0, 0), type_stroke)
    m_powerLabel:setColor(ccc3(255, 0xf6, 0))
    m_powerLabel:setPosition(topBg:getContentSize().width*0.23,topBg:getContentSize().height*0.66)
    topBg:addChild(m_powerLabel)
    
    local userInfo = UserModel.getUserInfo()
    if userInfo == nil then
        return
    end
    -- modified by yangrui at 2015-12-03
    m_silverLabel = CCLabelTTF:create(string.convertSilverUtilByInternational(userInfo.silver_num),g_sFontName,18)
    m_silverLabel:setColor(ccc3(0xe5,0xf9,0xff))
    m_silverLabel:setAnchorPoint(ccp(0,0.5))
    m_silverLabel:setPosition(topBg:getContentSize().width*0.61,topBg:getContentSize().height*0.43)
    topBg:addChild(m_silverLabel)
    
    m_goldLabel = CCLabelTTF:create(tostring(userInfo.gold_num),g_sFontName,18)
    m_goldLabel:setColor(ccc3(0xff,0xe2,0x44))
    m_goldLabel:setAnchorPoint(ccp(0,0.5))
    m_goldLabel:setPosition(topBg:getContentSize().width*0.82,topBg:getContentSize().height*0.43)
    topBg:addChild(m_goldLabel)

    RechargeLayer.registerChargeGoldCb(chargeCb)
end 

function chargeCb( )
	print("chargeCb  chargeCb  chargeCb  ")
	refreshTopUI()
	refreshChargeSp()
end

function refreshTopUI( )
	local userInfo = UserModel.getUserInfo()
	m_goldLabel:setString(userInfo.gold_num)
end 

local function shopMenuAction( tag, itemBtn )
	---[==[签到 新手引导屏蔽层
	---------------------新手引导---------------------------------
	--add by licong 2013.09.29
	require "script/guide/NewGuide"
	if(NewGuide.guideClass == ksGuideSignIn) then
		require "script/guide/SignInGuide"
		SignInGuide.changLayer()
	end
	---------------------end-------------------------------------
	--]==]
	itemBtn:selected()
	require "script/audio/AudioUtil"
	AudioUtil.playEffect("audio/effect/changtiaoxing.mp3")
	if (_curButton ~= itemBtn) then
		
		if(_curButton == _pubButton) then
			PubLayer.stopScheduler()
		end
		_curButton:unselected()
		_curButton = itemBtn
		_curButton:selected()
		if(_curDisplayLayer) then
			_curDisplayLayer:removeFromParentAndCleanup(true)
			_curDisplayLayer=nil
		end
		local bgLayerSize = _bgLayer:getContentSize()

		local curDisplayLayerHight = bgLayerSize.height- topBg:getContentSize().height * g_fScaleX - btnFrameSp:getContentSize().height * g_fScaleX
		if(_curButton == _pubButton) then
			_curDisplayLayer = PubLayer.createLayerBySize( CCSizeMake(bgLayerSize.width, curDisplayLayerHight) )
		elseif(_curButton == _propButton) then
			-- new shop enter
			require "script/ui/shopall/prop/PropLayer"
			_curDisplayLayer = PropLayer.createLayer( CCSizeMake(bgLayerSize.width/g_fScaleX, curDisplayLayerHight/g_fScaleX), false )
		elseif(_curButton == _giftsButton) then
			_curDisplayLayer = GiftsPakLayer.createLayerBySize( CCSizeMake(bgLayerSize.width, curDisplayLayerHight) )
		end
		_curDisplayLayer:setScale(1/MainScene.elementScale)
		
		_bgLayer:addChild(_curDisplayLayer)
	end
end

-- 充值
local function rechargeAction()
	-- 音效
	require "script/audio/AudioUtil"
	AudioUtil.playEffect("audio/effect/zhujiemian.mp3")
	---[==[签到 新手引导屏蔽层
	---------------------新手引导---------------------------------
	--add by licong 2013.09.29
	require "script/guide/NewGuide"
	if(NewGuide.guideClass == ksGuideSignIn) then
		require "script/guide/SignInGuide"
		SignInGuide.changLayer()
	end
	---------------------end-------------------------------------
	--]==]
	local layer = RechargeLayer.createLayer()
	local scene = CCDirector:sharedDirector():getRunningScene()
	scene:addChild(layer,1111)
	-- layer:setPosition(ccp(g_winSize.width/2,g_winSize.height/2))
	-- layer:setAnchorPoint(ccp(0.5,0.5))
	-- require "script/ui/shop/VipPrivilegeLayer"
 --    VipPrivilegeLayer.addPopLayer()
end

-- 创建按钮
local function createMenu( )
	
	local fullRect = CCRectMake(0,0,58,99)
	local insetRect = CCRectMake(20,20,18,59)
	--按钮背景
	btnFrameSp = CCScale9Sprite:create("images/common/menubg.png", fullRect, insetRect)
	btnFrameSp:setPreferredSize(CCSizeMake(640, 100))
	btnFrameSp:setAnchorPoint(ccp(0.5, 1))
	btnFrameSp:setPosition(ccp(_bgLayer:getContentSize().width/2 , _bgLayer:getContentSize().height- topBg:getContentSize().height * g_fScaleX ))
	btnFrameSp:setScale(g_fScaleX/MainScene.elementScale)
	_bgLayer:addChild(btnFrameSp)

	local shopMenuBar = CCMenu:create()
	shopMenuBar:setPosition(ccp(0, 0))
	btnFrameSp:addChild(shopMenuBar)
	-- 酒馆
	_pubButton = LuaMenuItem.createMenuItemSprite( GetLocalizeStringBy("key_1674"))
	_pubButton:setAnchorPoint(ccp(0, 0))
	_pubButton:setPosition(ccp(btnFrameSp:getContentSize().width*0, btnFrameSp:getContentSize().height*0.1))
	_pubButton:registerScriptTapHandler(shopMenuAction)
	shopMenuBar:addChild(_pubButton)
	_curButton = _pubButton
	_curButton:selected()

	-- 道具
	_propButton = LuaMenuItem.createMenuItemSprite( GetLocalizeStringBy("key_1409"))
	_propButton:setAnchorPoint(ccp(0, 0))
	_propButton:setPosition(ccp(btnFrameSp:getContentSize().width*0.24, btnFrameSp:getContentSize().height*0.1))
	_propButton:registerScriptTapHandler(shopMenuAction)
	shopMenuBar:addChild(_propButton)

	-- 礼包
	_giftsButton = LuaMenuItem.createMenuItemSprite( GetLocalizeStringBy("key_1816"))
	_giftsButton:setAnchorPoint(ccp(0, 0))
	_giftsButton:setPosition(ccp(btnFrameSp:getContentSize().width*0.48, btnFrameSp:getContentSize().height*0.1))
	_giftsButton:registerScriptTapHandler(shopMenuAction)
	shopMenuBar:addChild(_giftsButton)

	-- 充值 
	local rechargeMenuBar = CCMenu:create()
	rechargeMenuBar:setPosition(ccp(0,0))
	btnFrameSp:addChild(rechargeMenuBar)

	rechargeBtn = CCMenuItemImage:create("images/common/btn/btn_recharge_n.png", "images/common/btn/btn_recharge_h.png")
	rechargeBtn:setAnchorPoint(ccp(0.5, 0))
	rechargeBtn:setPosition(ccp(570, 20))
	rechargeBtn:registerScriptTapHandler(rechargeAction)
	rechargeMenuBar:addChild(rechargeBtn)

	-- VIP礼包的提示：VIP礼包可购买时，在“礼包”标签右上增加数字提示 added by zhz
	-- createTipSprite()
	-- 充值提示，首冲来袭
	-- createFirstCharge() -- 首充重置 去掉首充3倍提示 20160530 by lgx

	-- 招将提示
	createPubTip()

end 

-- 招将提示: 在找将按钮上添加提示信息，和礼包类似
function createPubTip(  )

	local canRecuitNum = DataCache.getRecuitFreeNum()
	_pubTipSp=   ItemDropUtil.getTipSpriteByNum(canRecuitNum) --CCSprite:create("images/common/tip_1.png")
	_pubTipSp:setPosition(_pubButton:getContentSize().width *0.98, _pubButton:getContentSize().height*0.97)
	_pubTipSp:setAnchorPoint(ccp(1,1))
	if(canRecuitNum ==0) then
		_pubTipSp:setVisible(false)
	end
	print("canRecuitNum  is : ", canRecuitNum)
	_pubButton:addChild(_pubTipSp,11)

end

-- 刷新pubTip
function refreshPubTip( )
	
	local canReceiveNum=  DataCache.getRecuitFreeNum()
	if(canReceiveNum == 0) then
		_pubTipSp:setVisible(false)
	end
	ItemDropUtil.refreshNum(_pubTipSp,canReceiveNum)
	-- local numLabel = tolua.cast(_pubTipSp:getChildByTag(_ksPubLabelTag) ,"CCLabelTTF")
	-- numLabel:setString("" .. canReceiveNum)
end

-- VIP礼包的提示：VIP礼包可购买时，在“礼包”标签右上增加数字提示 added by zhz
function createTipSprite(  )

	local canReceiveNum = DataCache.getCanReceiveVipNUm()
	_tipSprite=   ItemDropUtil.getTipSpriteByNum(canReceiveNum) --CCSprite:create("images/common/tip_1.png")
	_tipSprite:setPosition(ccp(_giftsButton:getContentSize().width *0.98, _giftsButton:getContentSize().height*0.97 ))
	_tipSprite:setAnchorPoint(ccp(1,1))
	
	if(canReceiveNum == 0) then
		_tipSprite:setVisible(false)
	end

	print("canReceiveNum  is :  ",canReceiveNum)

	_giftsButton:addChild(_tipSprite,11)

	
	GiftService.regirsterBuyVipGiftCb(refreshTipSprite)
end

-- 刷新 _tipSprite ,当点击vip礼包领取时调用 added by zhz
function refreshTipSprite(  )
	local canReceiveNum = DataCache.getCanReceiveVipNUm()
	if(canReceiveNum == 0) then
		_tipSprite:setVisible(false)
	end
	ItemDropUtil.refreshNum(_tipSprite,canReceiveNum)
	-- local numLabel = tolua.cast(_tipSprite:getChildByTag(101) ,"CCLabelTTF")
	-- numLabel:setString("" .. canReceiveNum)
end

function createFirstCharge(  )
	_firstChargeSp = CCSprite:create("images/common/first_charge.png")
	_firstChargeSp:setPosition(ccp(rechargeBtn:getContentSize().width/2, rechargeBtn:getContentSize().height*0))
	_firstChargeSp:setAnchorPoint(ccp(0.5,0))
	local chargeGold = DataCache.getChargeGoldNum()
	print("chargeGold is ; ", chargeGold)

	-- if(tonumber(chargeGold)>0) then
	-- 	_firstChargeSp:setVisible(false)
	-- end
	if RecharData.getIsPay() then
		_firstChargeSp:setVisible(false)
	end
	rechargeBtn:addChild(_firstChargeSp)
end

function refreshChargeSp( )
	-- local chargeGold = DataCache.getChargeGoldNum()
	-- if(tonumber(chargeGold)>0) then
	-- 	_firstChargeSp:setVisible(false)
	-- end
	print("RecharData.getIsPay()", RecharData.getIsPay())
	if RecharData.getIsPay() and _firstChargeSp~=nil then
		_firstChargeSp:setVisible(false)
	end
end

-- create
function create()
	local bgLayerSize = _bgLayer:getContentSize()

	createTopUI()
	createMenu()
	local curDisplayLayerHight = bgLayerSize.height- topBg:getContentSize().height * g_fScaleX - btnFrameSp:getContentSize().height * g_fScaleX 
	_curDisplayLayer = PubLayer.createLayerBySize( CCSizeMake(bgLayerSize.width, curDisplayLayerHight) )
	_curDisplayLayer:setScale(1/MainScene.elementScale)
	_bgLayer:addChild(_curDisplayLayer)

	if(_init_tag == Tag_Shop_Prop)then
		print("Tag_Shop_PropTag_Shop_PropTag_Shop_Prop")
		shopMenuAction( 1, _propButton )

	end

end

local function changerToSeniorLayer(  )
	require "script/ui/shop/SeniorAnimationLayer"
	local  seniorAnimationLayer = SeniorAnimationLayer.createLayer(_curShopCacheInfo.va_shop.gold_recruit, _curShopCacheInfo.va_shop.gold_hero)
	MainScene.changeLayer(seniorAnimationLayer, "seniorAnimationLayer")
end 

-- 是跳到神将的展示页面  还是 正常显示
local function showWhichLayer()

	-- if( (not table.isEmpty(_curShopCacheInfo.va_shop)) and not table.isEmpty(_curShopCacheInfo.va_shop.gold_recruit) ) then
	-- 	-- require "script/ui/shop/SeniorAnimationLayer"
	-- 	-- local  seniorAnimationLayer = SeniorAnimationLayer.createLayer(_curShopCacheInfo.va_shop.gold_recruit, _curShopCacheInfo.va_shop.gold_hero)
	-- 	-- MainScene.changeLayer(seniorAnimationLayer, "seniorAnimationLayer")
	-- 	local actionArr = CCArray:create()
	-- 	actionArr:addObject(CCDelayTime:create(0.001))
	-- 	actionArr:addObject(CCCallFuncN:create(changerToSeniorLayer))
	-- 	_bgLayer:runAction(CCSequence:create(actionArr))
	-- else
		create()
	-- end
end

-- 获取当前商店的信息
function shopInfoCallback( cbFlag, dictData, bRet )
	if(dictData.err ~= "ok")then
		return
	end
	_curShopCacheInfo = dictData.ret
	_curShopCacheInfo.silverExpireTime = os.time()+tonumber(_curShopCacheInfo.silver_recruit_time)
    
	_curShopCacheInfo.goldExpireTime = os.time()+tonumber(_curShopCacheInfo.gold_recruit_time)
   
		-- if LoyaltyData.isFunOpen(5) then
		-- 	--神将招募的时间减少
		-- 	local dbInfo = DB_Hall_loyalty.getArrDataByField("type",5)
		-- 	if(dbInfo)then
		-- 		_curShopCacheInfo.goldExpireTime = _curShopCacheInfo.goldExpireTime - dbInfo[1].num*60
		-- 	end
		-- end
    	
    
	DataCache.setShopCache(_curShopCacheInfo)
	showWhichLayer()
	
end

-- 
function layerWillDisappearDelegate()
	if(_curButton == _pubButton) then
		PubLayer.stopScheduler()
	end
end

function onNodeEvent(event )

	if (event == "enter") then
	elseif (event == "exit") then
		GiftService.regirsterBuyVipGiftCb(nil)
		RechargeLayer.registerChargeGoldCb(nil)
	end
	
end

function createLayer( init_tag)
	init()
	if(init_tag)then
		_init_tag = init_tag
	else
		_init_tag = Tag_Shop_Hero
	end

	_bgLayer = MainScene.createBaseLayer("images/main/module_bg.png", true, false,true)
	_bgLayer:registerScriptHandler(onNodeEvent)
	_curShopCacheInfo = DataCache.getShopCache()
	if(_curShopCacheInfo == nil) then
		RequestCenter.shop_getShopInfo(shopInfoCallback, nil)
	else
		showWhichLayer()
	end
	return _bgLayer
end

-- 新手引导
-- 得到充值按钮
function getRechargeBtnForGuide()
	return rechargeBtn
end
-- 得到礼包按钮
function getGiftsButtonForGuide()
	return _giftsButton
end

-- --处理因为聚义厅而触发的良将神将招将时间缩短的功能
-- function dealLoyal( ... )
-- 	 require "script/ui/star/loyalty/LoyaltyData"

--     --新增聚义厅功能 该功能可能触发 良将、神将 招募时间缩短
--     print("shopInfoCallback 聚义厅")
--     	require "db/DB_Hall_loyalty"
--     	local silverArray = DB_Hall_loyalty.getArrDataByField("type",4)
--     	print("silverArray")
--     	print_t(silverArray)
--     	if(not table.isEmpty(silverArray))then
--     		for k,v in pairs(silverArray)do 
-- 				if LoyaltyData.isFunOpen(4,v.id) then
-- 					--良将招募的时间减少
-- 					_curShopCacheInfo.silverExpireTime = _curShopCacheInfo.silverExpireTime - tonumber(v.num)*60

-- 				end
-- 			end
-- 		end

-- 		local goldArray = DB_Hall_loyalty.getArrDataByField("type",5)
-- 		print("goldArray")
--     	print_t(goldArray)
--     	if(not table.isEmpty(goldArray))then
--     		for k,v in pairs(goldArray)do 
-- 				if LoyaltyData.isFunOpen(5,v.id) then
-- 					--神将招募的时间减少
-- 					_curShopCacheInfo.goldExpireTime = _curShopCacheInfo.goldExpireTime - tonumber(v.num)*60

-- 				end
-- 			end
-- 		end
-- end













