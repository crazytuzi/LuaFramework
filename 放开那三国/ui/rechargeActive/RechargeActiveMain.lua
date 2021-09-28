-- Filename：	RechargeActiveMain.lua
-- Author：		chao he
-- Date：		2013-8-3
-- Purpose：		活动


module ("RechargeActiveMain", package.seeall)

require "script/network/RequestCenter"
require "script/ui/rechargeActive/FirstPackLayer"
require "script/ui/rechargeActive/GrowthFundLayer"
require "script/ui/rechargeActive/ActiveCache"
require "script/ui/rechargeActive/RestoreEnergyLayer"
require "script/ui/rechargeActive/GrowthFundLayer"
require "script/model/DataCache"
require "script/model/utils/ActivityConfigUtil"
require "script/ui/digCowry/DigCowryLayer"	
require "script/ui/digCowry/DigCowryData"	
require "script/ui/login/ServerList"
require "script/ui/rechargeActive/CardPackActiveLayer"
require "script/ui/rechargeActive/ConsumeLayer"
require "script/ui/rechargeActive/NewYearLayer"
require "script/ui/rechargeActive/RechargeFeedbackCache"
require "script/ui/rechargeActive/RechargeFeedbackLayer"
require "script/ui/rechargeActive/ChangeActiveLayer"
require "script/ui/rechargeActive/TuanLayer"
require "script/ui/tip/AnimationTip"
require "script/ui/mergeServer/accumulate/AccumulateData"
require "script/ui/rechargeActive/bowl/BowlData"
require "script/ui/rechargeActive/worldGroupBuy/WorldGroupData"
require "script/ui/rechargeActive/blackshop/BlackshopData"
require "script/ui/rechargeActive/travelShop/TravelShopData"
require "script/ui/active/NewActiveLayer"
require "script/ui/rechargeActive/rechargegift/RechargeGiftData"
require "script/ui/rechargeActive/rechargegift/RechargeGiftLayer"
require "script/ui/rechargeActive/happySign/HappySignData"
require "script/ui/rechargeActive/happySign/HappySignController"
require "script/ui/redpacket/RedPacketLayer"
require "script/ui/redpacket/RedPacketData"
require "script/utils/TopGoldSilver"
require "script/ui/rechargeActive/singleRecharge/SignleRechargeData"
require "script/ui/rechargeActive/singleRecharge/SignleRechargeController"
require "script/ui/vip_benefit/VIPBenefitData"
require "script/ui/vip_benefit/VIPBenefitController"
require "script/ui/active/mineral/MineralElvesData"
require "script/ui/rechargeActive/limitfund/LimitFundData"
require "script/ui/rechargeActive/limitfund/LimitFundLayer"
require "script/ui/rechargeActive/limitfund/LimitFundController"
_ksTagMainMenu 		= 1001
_tagShowChong 		= 101
_tagChengzhang 		= 102
_tagEatChieken 		= 103	-- 整点送体力，吃鸡
_tagMysteryShop		= 104
_tagCardActive 		= 105	-- 活动卡包
_tagConsume    		= 106	-- 消费累积
_tagChargeReward 	= 107	-- 充值回馈
_tagNewYear 	 	= 108   -- 新年礼包		
_tagWabao 			= 109   -- 挖宝
_tagBenefit			= 110   -- 福利活动
_tagVIPBenefit		= 111
_tagMysteryMerchant = 112	-- 神秘商人
_tagChange 			= 113   -- 兑换
_tagTuan 			= 114 	-- 团购
_tagChargeRaffle	= 115	-- 充值抽奖
_tagMonthCard		= 116	-- 月卡
_tagTopupReward		= 117	-- 充值大放送(名字源于后端，虽然用chargeBigRun更适合些),added by Zhang Zihang
_tagTransfer        = 118   -- 武将变身
_tagStepCounter 	= 119 	-- 计步活动
_tagMergeAccumulate = 120 	-- 合服累积登录
_tagMergeRecharge 	= 121 	-- 合服消费累积
_tagMonthSign       = 122   -- 月签到    added by DJN
_tagWeekendShop     = 123   -- 周末神秘商店
_tagScoreWheel      = 124   -- 积分轮盘 added by DJN 
_tagLimitShop 		= 125 	-- 限时商店
_tagBowl            = 126   -- 聚宝盆 add by DJN
_tagFestival 		= 127   -- 节日活动
_tagScoreShop       = 128   -- 积分商城 add by DJN
_tagWorldGroupOn    = 129   -- 跨服团购 add by DJN
_tagTravelShop 		= 130   -- 云游商人 add by bzx
_blackshop          = 131   -- 黑市兑换 add by yangrui
_tagFsReborn        = 132   -- 战魂重生 add by licong
_happySign          = 133   -- 欢乐签到 add by shengyixian
_tagNewActive 		= 134   -- 新活动 llp
_tagRechargeGift    = 135   -- 缤纷回馈 add by yangrui 2015-10-30
_tagRedPacket 		= 136   -- 红包
_tagSingleRecharge	= 137   -- 单充回馈 add by fuqiongqiong 2016.3.3
_tagElvesBenefit 	= 138 	-- 资源矿宝藏活动 add by bzx 
_tagLimitFund		= 139   -- 限时基金活动  add by fuqiongqiong

local _ksTagActivityNewIn = 1001  -- 新活动开启时的，提示图片  

local _tagArray		= {}	-- 用来存放tag的数组	
local _curTagIndex	= 1		-- 当前_tagArray 的index
local defaultIndex 	= nil
local _defaultBg	= nil
local count			= 0		 -- 活动数量

local bgLayer 
local _buttomLayer	= nil
local topBgSp
local scrollView
local mainMenu
local oldTag = 0

--福利活动红圈剩余次数
local numLabel

local _topBg 	= nil

local function init( )
	bgLayer= nil
	_buttomLayer= nil
	topBgSp= nil
	scrollView= nil
	mainMenu= nil
	oldTag = 0
	_tagArray= {}
	_curTagIndex =1

	numLabel = nil
	_topBg 	= nil
end

function onTouchesHandler( eventType, x, y )
	if(eventType == "began") then
		print("( eventType" , eventType)
		_touchBeganPoint = ccp(x, y)
		return true
	elseif(eventType == "moved") then
		-- local xOffset= x- _touchBeganPoint.x
		-- local curTag=1
		-- local nextLayer= nil
		-- if(xOffset >0) then
		-- else
			
		-- end
	else

	end
end

-- 开始创建UI
function create( index )
	init()
	count = 0
	defaultIndex = index

	MainScene.setMainSceneViewsVisible(true, false, false)

	bgLayer = CCLayer:create()
	bgLayer:setPosition(ccp(0,0))
	-- bgLayer:setContentSize(CCSizeMake(640,804))

	local bgLayerSize = bgLayer:getContentSize()

	-- 默认背景
	_defaultBg = CCSprite:create("images/recharge/fund/fund_bg.png")
	bgLayer:addChild(_defaultBg)
	_defaultBg:setScale(MainScene.bgScale)

	-- 上标题栏 显示战斗力，银币，金币
	_topBg = TopGoldSilver.create()
    _topBg:setAnchorPoint(ccp(0,1))
    _topBg:setPosition(0,bgLayerSize.height)
    _topBg:setScale(g_fScaleX)
    bgLayer:addChild(_topBg,1100)
	
	--背景	
	local winHeight = CCDirector:sharedDirector():getWinSize().height
	topBgSp = CCScale9Sprite:create("images/common/bg/bg_2.png")
	topBgSp:setContentSize(CCSizeMake(640,130))
	topBgSp:setAnchorPoint(ccp(0.5,1))
	topBgSp:setPosition(ccp(CCDirector:sharedDirector():getWinSize().width/2, winHeight - _topBg:getContentSize().height*g_fScaleX))
	bgLayer:addChild(topBgSp, 99)
	topBgSp:setScale(g_fScaleX)

    local topMenuBar = CCMenu:create()
    topMenuBar:setPosition(ccp(0, 0))
    topBgSp:addChild(topMenuBar)

	--左右翻页的按钮
	require "script/ui/common/LuaMenuItem"
	--左按钮
	local leftBtn = LuaMenuItem.createItemImage("images/formation/btn_left.png",  "images/formation/btn_left.png", topMenuItemAction )
	leftBtn:setAnchorPoint(ccp(0.5, 0.5))
	leftBtn:setPosition(ccp(topBgSp:getContentSize().width*0.06, topBgSp:getContentSize().height/2))
	topMenuBar:addChild(leftBtn, 10001, 10001)
	-- 右按钮
	local rightBtn = LuaMenuItem.createItemImage("images/formation/btn_right.png",  "images/formation/btn_right.png", topMenuItemAction )
	rightBtn:setAnchorPoint(ccp(0.5, 0.5))
	rightBtn:setPosition(ccp(topBgSp:getContentSize().width*0.94, topBgSp:getContentSize().height/2))
	topMenuBar:addChild(rightBtn, 10002, 10002)

	-- createScrollView()
	_buttomLayer = CCLayer:create()
	_buttomLayer:setPosition(ccp(0,0))
	_buttomLayer:registerScriptTouchHandler(onTouchesHandler)
	_buttomLayer:setTouchEnabled(true)
	bgLayer:addChild(_buttomLayer)
	--拉取限时基金信息
	if(ActivityConfigUtil.isActivityOpen("limitFund"))then
		LimitFundController.getInfo()
	end
	
	--拉取是否充值信息充值
	getNetData()
	--  test by zhz
	-- local layer = FirstPackLayer.createLayer()
	-- bgLayer:addChild(layer)

	return bgLayer
end

--[[
	@desc	活动图标
	@para 	none
	@return void
--]]
local function createScrollView( ... )
	print("createScrollView")
	if( scrollView~= nil ) then
		scrollView:removeFromParentAndCleanup(true)
		scrollView=nil
		--topBgSp:removeChildByTag(2000,true)
	end

	local width = 513
	scrollView = CCScrollView:create()
    scrollView:setContentSize(CCSizeMake(width, topBgSp:getContentSize().height))
    scrollView:setViewSize(CCSizeMake(513, topBgSp:getContentSize().height))
    scrollView:setPosition(66,0)
    scrollView:setTouchPriority(-400)
    scrollView:setDirection(kCCScrollViewDirectionHorizontal)
    scrollView:setContentOffset(ccp(0,0))
    topBgSp:addChild(scrollView,1,2000)

    mainMenu = BTMenu:create(true)
	mainMenu:setPosition(0,0)
	mainMenu:setTouchPriority(-390)
	mainMenu:setScrollView(scrollView)
	scrollView:addChild(mainMenu,1 , _ksTagMainMenu)
	mainMenu:setStyle(kMenuRadio)
	local  POTENTIAL_Base = "images/bag/gift/30001.png"
	local count = 0
	local firstItem = nil


	local activeTable = {

		{
			activity_name = GetLocalizeStringBy("key_1022"), 
			img= {images_n = "images/recharge/btn_shouchong1.png", images_h = "images/recharge/btn_shouchong2.png",},
			tag= _tagShowChong,
			note_data= {
				isActivity= false,
				isOpen= _boolCharge,
				hasTip= false,
				
			},

		},

		{
			activity_name = GetLocalizeStringBy("llp_256"), 
			img= {images_n = "images/active/activeIcon/newactive_n.png", images_h = "images/active/activeIcon/newactive_h.png",},
			tag= _tagNewActive,
			note_data= {
				isActivity= true,
				isOpen= NewActiveData.isNewActiveOpen(),
				hasTip= false,
				
			},

		},

		{
			activity_name = GetLocalizeStringBy("llp_303"), 
			img= {images_n = "images/active/activeIcon/redpacket_n.png", images_h = "images/active/activeIcon/redpacket_h.png",},
			tag= _tagRedPacket,
			note_data= {
				isActivity= true,
				isOpen= RedPacketData.isRedPacketOpen(),
				hasTip= false,
				key = "envelope"
			},

		},


		{
			activity_name = GetLocalizeStringBy("key_2485"), 
			img= {images_n = "images/recharge/btn_jihua1.png", images_h = "images/recharge/btn_jihua2.png" ,},
			tag= _tagChengzhang,
			note_data= {
				isActivity= false,
				isOpen= _boolGrowUp,
				hasTip= false,
				tipSprite= getTipSprite(),
			},

		},

		-- 烧鸡
		{
			activity_name = GetLocalizeStringBy("key_1850"), 
			img= {images_n = "images/recharge/btn_chicken1.png", images_h ="images/recharge/btn_chicken2.png",},
			tag= _tagEatChieken,
			note_data= {
				isActivity= false,
				isOpen= true,
				hasTip= ActiveCache.isOnTime(),
				-- tipSprite= getTipSprite(),
			}

		},

		-- 福利活动
		{
			activity_name = GetLocalizeStringBy("key_2971"), 
			img= {images_n = "images/recharge/benefit_active/benefit_n.png", images_h ="images/recharge/benefit_active/benefit_h.png",},
			tag= _tagBenefit,
			note_data= {
				isActivity= true,
				isOpen= ActivityConfigUtil.isActivityOpen("weal"),
				-- tipSprite= getTipSprite(),
				hasTip = ActiveCache.isHaveCardNum(),
				key= "weal"
			},

		},

		{
			activity_name = GetLocalizeStringBy("key_10364"), 
			img= {images_n = "images/recharge/elves_n.png", images_h ="images/recharge/elves_h.png",},
			tag= _tagElvesBenefit,
			note_data= {
				isActivity= true,
				isOpen= MineralElvesData.isOpen(),
				-- tipSprite= getTipSprite(),
				hasTip = false,
				key= "mineralelves"
			},

		},

		-- 神秘商店
		-- {
		-- 	activity_name = GetLocalizeStringBy("key_1063"), 
		-- 	img= {images_n = "images/recharge/mystery_shop/shop_n.png", images_h ="images/recharge/mystery_shop/shop_h.png",},
		-- 	tag= _tagMysteryShop,
		-- 	note_data= {
		-- 		isActivity= false,
		-- 		isOpen= true,
		-- 		hasTip= ActiveCache.isMysteryNewIn(),
		-- 		-- tipSprite= getTipSprite(),
		-- 	},

		-- },

		-- VIP福利
		{
			activity_name = GetLocalizeStringBy("key_3415"),
			img = {images_n = "images/recharge/vip_benefit/vipB_n.png", images_h = "images/recharge/vip_benefit/vipB_h.png"},
			tag = _tagVIPBenefit,
			note_data = {
				isActivity = false,
				isOpen = ActiveCache.isOpenVIPBenefit(),
				-- hasTip = ActiveCache.isHaveVIPBenefit(),
				hasTip = false,
			}

		},

		-- 活动卡包
		{
			activity_name = GetLocalizeStringBy("key_1149"), 
			img= {images_n ="images/recharge/card_active/btn_card/btn_card_n.png", images_h ="images/recharge/card_active/btn_card/btn_card_h.png",},
			tag= _tagCardActive,
			note_data= {
				isActivity= true,
				isOpen=  ActiveCache.isCardActiveOpen(),
				hasTip= false,--ActiveCache.getIsNewActivity("heroShop"),
				key= "heroShop"
				
			},

		},

		-- 消费累积
		{
			activity_name = GetLocalizeStringBy("key_2802"), 
			img= {images_n ="images/recharge/consume_n.png", images_h ="images/recharge/consume_h.png",},
			tag= _tagConsume,
			note_data= {
				isActivity= true,
				isOpen=  ConsumeLayer.isOpenConsume(),
				hasTip=false, --ActiveCache.getIsNewActivity("spend"),
				key= "spend",
			},
		},

		-- 新年礼包
		{
			activity_name = GetLocalizeStringBy("key_2796"), 
			img= {images_n ="images/recharge/newyear_n.png", images_h = "images/recharge/newyear_h.png",},
			tag= _tagNewYear,
			note_data= {
				isActivity= true,
				isOpen=  NewYearLayer.isOpenNewYear(),
				hasTip= false, --ActiveCache.getIsNewActivity("signActivity"),
				key="signActivity"
			},

		},

		-- 挖宝
		{
			activity_name = GetLocalizeStringBy("key_2011"), 
			img= {images_n ="images/digCowry/dig_icon_n.png", images_h = "images/digCowry/dig_icon_h.png",},
			tag= _tagWabao,
			note_data= {
				isActivity= true,
				isOpen=  DigCowryData.isDigcowryOpen(),
				hasTip=false ,--ActiveCache.getIsNewActivity("signActivity"),
				key= "robTomb"
			},

		},

		-- 充值回馈
		{
			activity_name = GetLocalizeStringBy("key_2055"), 
			img= {images_n ="images/recharge/feedback_active/btn_n.png", images_h = "images/recharge/feedback_active/btn_h.png",},
			tag= _tagChargeReward,
			note_data= {
				isActivity= true,
				isOpen=  RechargeFeedbackCache.isFeedbackOpen(),
				hasTip= false ,--ActiveCache.getIsNewActivity("topupFund"),
				key= "topupFund"
			},

		},

        --月签到
		--add by DJN
        {
            activity_name = GetLocalizeStringBy("djn_66"),
            img = {
                images_n = "images/recharge/btn_monthsign_n.png",
				images_h = "images/recharge/btn_monthsign_h.png"
            },
            tag = _tagMonthSign,
            note_data = {
                isActivity = false,
				isOpen = true,
				hasTip = ActiveCache.isHaveMonthSign(),
				key= "monthSign"
            }
        },

		--- added by bzx ，神秘商人 ，（这个不是活动， isActivity 应是false
		-- {
		-- 	activity_name = GetLocalizeStringBy("key_1242"),
		-- 	img = {images_n = "images/recharge/btn_mystery_merchant1.png",images_h = "images/recharge/btn_mystery_merchant2.png"},
		-- 	tag = _tagMysteryMerchant,
		-- 	note_data = {
		-- 		isActivity = false,
		-- 		isOpen = true,--ActiveCache.MysteryMerchant:isExist(),
		-- 		hasTip = ActiveCache.MysteryMerchant:isRefreshed(),
		-- 		-- tipSprite= getTipSprite(),
		-- 	},
		-- },
		
		-- added by licong 兑换活动 ， 
		{	
			activity_name = GetLocalizeStringBy("lic_1006"),
			img = {
				-- 限时兑换图标
				images_n = getExchangeActiveIcon1(),
				images_h = getExchangeActiveIcon2()
			},
			tag = _tagChange,
			note_data = {
				isActivity = true,
				isOpen = ActivityConfigUtil.isActivityOpen("actExchange"),
				hasTip = false,
				key= "actExchange"
			},
		},
		-- 团购活动
		{	
			activity_name = GetLocalizeStringBy("lic_1013"),
			img = {
				images_n = "images/recharge/tuan_n.png",
				images_h = "images/recharge/tuan_h.png"
			},
			tag = _tagTuan,
			note_data = {
				isActivity = true,
				isOpen = ActivityConfigUtil.isActivityOpen("groupon"),
				hasTip = false,
				key= "groupon"
			},
		},


		-- 月卡
		{	
			activity_name = GetLocalizeStringBy("key_4014"),
			img = {
				images_n = "images/recharge/month_card_n.png",
				images_h = "images/recharge/month_card_h.png"
			},
			tag = _tagMonthCard,
			note_data = {
				isActivity = false,
				isOpen = true, --BTUtil:isAppStore(),
				hasTip = false,
				-- key= "monthlyCardGift"
			},
		},

		-- 充值抽奖
		{	
			activity_name = GetLocalizeStringBy("lic_1013"),
			img = {
				images_n = "images/recharge/chargeRaffle_n.png",
				images_h = "images/recharge/chargeRaffle_h.png"
			},
			tag = _tagChargeRaffle,
			note_data = {
				isActivity = true,
				isOpen = ActivityConfigUtil.isActivityOpen("chargeRaffle"),
				hasTip = false,
				key= "chargeRaffle"
			},
		},

		--充值大放送
		--added by Zhang Zihang
		{	
			activity_name = GetLocalizeStringBy("zzh_1016"),
			img = {
				images_n = "images/recharge/rechargeBigRun/bigRun_n.png",
				images_h = "images/recharge/rechargeBigRun/bigRun_h.png"
			},
			tag = _tagTopupReward,
			note_data = {
				isActivity = true,
				isOpen = ActivityConfigUtil.isActivityOpen("topupReward"),
				hasTip = false,
				key= "topupReward"
			},
		},

    	-- 缤纷回馈
    	-- add by yangrui 2015-10-30
    	{
    		activity_name = GetLocalizeStringBy("yr_3000"),
        	img = {
        		-- 缤纷回馈 icon
        		images_n = "images/recharge/rechargegift/rechargegift_n.png",
        		images_h = "images/recharge/rechargegift/rechargegift_h.png",
        	},
        	tag = _tagRechargeGift,
        	note_data = {
        		isActivity = true,
        		isOpen = ActivityConfigUtil.isActivityOpen("rechargeGift"),
        		hasTip = ActiveCache.isRechargeGiftHaveTip(),
        		key = "rechargeGift",
        	},
    	},

		--计步活动
		--added by Zhang Zihang
		{
			activity_name = GetLocalizeStringBy("zzh_1140"),
			img = {
				images_n = "images/recharge/stepCounter/step_n.png",
				images_h = "images/recharge/stepCounter/step_h.png"
			},
			tag = _tagStepCounter,
			note_data = {
				isActivity = true,
				isOpen = ActivityConfigUtil.isActivityOpen("stepCounter"),
				hasTip = false,
				key = "stepCounter"
			},
		},
        
        -- added by bzx
    --     {
    --         activity_name = GetLocalizeStringBy("key_8342"),
    --         img = {
    --             images_n = "images/recharge/btn_transfer_n.png",
				-- images_h = "images/recharge/btn_transfer_h.png"
    --         },
    --         tag = _tagTransfer,
    --         note_data = {
    --             isActivity = true,
				-- isOpen = DataCache.getSwitchNodeState(ksTransfer,false),
				-- hasTip = false,
				-- key= "transfer"
    --         }
    --     },
 
        --合服登录累积活动
        --added by Zhang Zihang
        {
        	activity_name = GetLocalizeStringBy("zzh_1157"),
        	img = {
        		images_n = "images/mergeServer/accumulate/accumulate_n.png",
        		images_h = "images/mergeServer/accumulate/accumulate_h.png"
        	},
        	tag = _tagMergeAccumulate,
        	note_data = {
        		isActivity = true,
        		isOpen = AccumulateData.isMergeActivityOpen("mergeAccumulate"),
        		hasTip = false,
        		key = "mergeAccumulate"
        	}
    	},

    	--合服充值回馈活动
    	--added by Zhang Zihang
    	{
    		activity_name = GetLocalizeStringBy("zzh_1158"),
    		img = {
    			images_n = "images/mergeServer/accumulate/recharge_n.png",
    			images_h = "images/mergeServer/accumulate/recharge_h.png"
  	  		},
  	  		tag = _tagMergeRecharge,
  	  		note_data = {
  	  			isActivity = true,
  	  			isOpen = AccumulateData.isMergeActivityOpen("mergeRecharge"),
  	  			hasTip = false,
  	  			key = "mergeRecharge"
  	  		}
   		},

   		-- 周末神秘商店
		-- {
		-- 	activity_name = GetLocalizeStringBy("zz_104"), 
		-- 	img= {images_n = "images/weekendShop/weekend_btn_n.png", images_h ="images/weekendShop/weekend_btn_h.png",},
		-- 	tag= _tagWeekendShop,
		-- 	note_data= {
		-- 		isActivity= false,
		-- 		isOpen= DataCache.getSwitchNodeState(ksWeekendShop,false),
		-- 		hasTip= false,
		-- 		key = "weekendShop",
		-- 	},

		-- },

		--积分轮盘
		--add by DJN
        {
            activity_name = GetLocalizeStringBy("djn_76"),
            img = {
                images_n = "images/recharge/btn_scorewheel_n.png",
				images_h = "images/recharge/btn_scorewheel_h.png"
            },
            tag = _tagScoreWheel,
            note_data = {
                isActivity = true,
				isOpen = ActivityConfigUtil.isActivityOpen("roulette"),
				hasTip = ActiveCache.isHaveRoulette(),
				key= "roulette"
            }
        },

        --限时商店
        {
            activity_name = GetLocalizeStringBy("zzh_1198"),
            img = {
                images_n = "images/recharge/limit_shop/btn_n.png",
				images_h = "images/recharge/limit_shop/btn_h.png"
            },
            tag = _tagLimitShop,
            note_data = {
                isActivity = true,
				isOpen = ActivityConfigUtil.isActivityOpen("limitShop"),
				hasTip = false,
				key= "limitShop"
            }
        },
        -- 聚宝盆
		--add by DJN 2015/1/7
        {
            activity_name = GetLocalizeStringBy("djn_126"),
            img = {
                images_n = "images/recharge/btn_bowl_n.png",
				images_h = "images/recharge/btn_bowl_h.png"
            },
            tag = _tagBowl,
            note_data = {
                isActivity = true,
				isOpen = ActivityConfigUtil.isActivityOpen("treasureBowl") and BowlData.isHaveIcon(),
				hasTip = ActiveCache.isHaveBowl(),
				key= "treasureBowl"
            }
        },

        --节日活动
        --added by zhang zihang
        {
        	activity_name = GetLocalizeStringBy("zzh_1256"),
        	img = {
        		images_n = "images/recharge/festival/buttom_n.png",
        		images_h = "images/recharge/festival/buttom_h.png",
        	},
        	tag = _tagFestival,
        	note_data = {
        		isActivity = true,
        		isOpen = ActivityConfigUtil.isActivityOpen("festival"),
        		hasTip = false,
        		key = "festival"
        	}
    	},
    	-- 聚宝盆
		--add by DJN 2015/3/3
        {
            activity_name = GetLocalizeStringBy("djn_144"),
            img = {
                images_n = "images/recharge/btn_scoreshop_n.png",
				images_h = "images/recharge/btn_scoreshop_h.png",
            },
            tag = _tagScoreShop,
            note_data = {
                isActivity = true,
				isOpen = ActivityConfigUtil.isActivityOpen("scoreShop"),
				hasTip = ActiveCache.isHaveScoreShop(),
				key= "scoreShop"
            }
        },

        --跨服团购
        --add by DJN 2015/8/3
        {
            activity_name = GetLocalizeStringBy("djn_201"),
            img = {
                images_n = "images/recharge/btn_worldBuy_n.png",
                images_h = "images/recharge/btn_worldBuy_h.png",
            },
            tag = _tagWorldGroupOn,
            note_data = {
                isActivity = true,
                --活动开启后 有一段时间的分组期 这个期间屏蔽入口 感觉怪怪的。。。。
                isOpen = ActivityConfigUtil.isActivityOpen("worldgroupon") and WorldGroupData.isWorldGroupBuyOpen(),
                hasTip = WorldGroupData.isHaveWorldGroup(),
                key= "worldgroupon"
            }
        },

        -- 云游商人
        --add by bzx 2015/9/6
        {
            activity_name = GetLocalizeStringBy("key_10294"),
            img = {
                images_n = "images/recharge/travel_shop_n.png",
                images_h = "images/recharge/travel_shop_h.png",
            },
            tag = _tagTravelShop,
            note_data = {
                isActivity = true,
                isOpen = TravelShopData.isOpen(),
                hasTip = TravelShopData.canReceive(),
                key= "travelShop"
            }
        },

        -- 黑市兑换
        -- add by yangrui 2015/8/28
        {
        	activity_name = GetLocalizeStringBy("yr_1000"),
        	img = {
        		-- 黑市兑换 icon
        		images_n = "images/recharge/blackshop/change_black_n.png",
        		images_h = "images/recharge/blackshop/change_black_h.png",
        	},
        	tag = _blackshop,
        	note_data = {
        		isActivity = true,
        		isOpen = ActivityConfigUtil.isActivityOpen("blackshop"),
        		hasTip = false,
        		key = "blackshop",
        	},
    	},

    	-- 战魂重生
        --add by licong
        {
            activity_name = GetLocalizeStringBy("lic_1656"),
            img = {
                images_n = "images/recharge/soulReborn/reborn_n.png",
                images_h = "images/recharge/soulReborn/reborn_h.png",
            },
            tag = _tagFsReborn,
            note_data = {
                isActivity = true,
                isOpen = ActivityConfigUtil.isActivityOpen("fsReborn"),
                hasTip = false, 
                key= "fsReborn",
            }
        },
    	-- 欢乐签到
        -- add by shengyixian 2015/9/25
        {
        	activity_name = GetLocalizeStringBy(GetLocalizeStringBy("syx_1026")),
        	img = {
        		-- 欢乐签到 icon
        		images_n = "images/recharge/happy_sign/happy_sign_btn_n.png",
        		images_h = "images/recharge/happy_sign/happy_sign_btn_h.png",
        	},
        	tag = _happySign,
        	note_data = {
        		isActivity = true,
        		isOpen = ActivityConfigUtil.isActivityOpen("happySign"),
        		hasTip = false,
        		key = "happySign",
        	},
    	},
    	--单充回馈
    	--add by fuqiongqiong 2016.3.3.
    	{
    		activity_name = GetLocalizeStringBy("fqq_059"),
    		img = {
    			images_n = "images/sign/receive/single_n.png",
    			images_h = "images/sign/receive/single_h.png",
            },
            tag = _tagSingleRecharge,
            note_data = {
            	isActivity = true,
            	isOpen = SignleRechargeData.isOpen(),
            	hasTip = false,
            	key = "oneRecharge",
    		},
    },

    --限时基金  add by fuqiongqiong 2016 9.18
    
    {
    		activity_name = GetLocalizeStringBy("fqq_158"),
    		img = {
    			images_n = "images/recharge/xianshijijin_n.png",
    			images_h = "images/recharge/xianshijijin_h.png",
            },
            tag = _tagLimitFund,
            note_data = {
            	isActivity = true,
            	isOpen = LimitFundData.isOpen(),
            	hasTip = false,
            	key = "limitFund",
    		},
    }
		----------------------------------------------
	}
    
	for i=1, #activeTable do
		if( activeTable[i].note_data.isOpen ) then
			print("activeTable[i].img.images_n",activeTable[i].img.images_n)
			print("activeTable[i].img.images_h",activeTable[i].img.images_h)
			local menuItem = CCMenuItemImage:create(activeTable[i].img.images_n , activeTable[i].img.images_h)
			mainMenu:addChild(menuItem)
			menuItem:setAnchorPoint(ccp(0,0.5))
			menuItem:setPosition(ccp(120*count , scrollView:getContentSize().height/2))
			menuItem:registerScriptTapHandler(touchButton)
			menuItem:setTag(activeTable[i].tag )
			-- 把对应的tag，加到_tagArrayshang
			-- table.insert( _tagArray,activeTable[i].tag)
			-- local layer= getLayerByTag(activeTable[i].tag)
			print("activeTable[i].note_data.hasTip and name  is " , activeTable[i].note_data.hasTip,activeTable[i].activity_name )
			if(activeTable[i].note_data.hasTip) then
				local tipSprite=nil
				if(activeTable[i].note_data.isActivity and activeTable[i].tag == _tagBenefit )then
					tipSprite = getTipSpriteWithNum()
				elseif activeTable[i].note_data.isActivity and activeTable[i].tag == _tagRechargeGift then
					tipSprite = getRechargeGiftTipSpriteWithNum()
				-- elseif not activeTable[i].note_data.isActivity and activeTable[i].tag == _tagVIPBenefit then
				-- 		 tipSprite =  getWeekGiftBagTip()
				else
					tipSprite = getTipSprite()
				end
				tipSprite:setAnchorPoint(ccp(1,1))
				tipSprite:setPosition(menuItem:getContentSize().width*0.98,menuItem:getContentSize().height*0.98)
				-- end
				menuItem:addChild(tipSprite,1, 101)		
			end

			if( activeTable[i].note_data.isActivity and ActiveCache.IsNewInActivityByKey( activeTable[i].note_data.key ) ) then
				local newInTip= getNewTip()
				newInTip:setPosition(menuItem:getContentSize().width*0.75,menuItem:getContentSize().height*0.8)
				menuItem:addChild(newInTip,1, _ksTagActivityNewIn)	
			end
			------------------add by DJN  2014 10 19
			--因为月签到不是一个活动，没有活动配置，但是策划需要在首次进入活动前有new图标闪烁，所以单独为月签到写一个调用new的方法
			if( activeTable[i].tag == _tagMonthSign and ActiveCache.IsNewInMonthSign() ) then
				--print("月签到需要创建new图标")
				local newInTip= getNewTip()
				newInTip:setPosition(menuItem:getContentSize().width*0.75,menuItem:getContentSize().height*0.8)
				menuItem:addChild(newInTip,1, _ksTagActivityNewIn)	
			end

			
			count = count + 1
			if(firstItem == nil)then
				firstItem = menuItem
			end
		end 
	end

	print("defaultIndex = ",defaultIndex)
	if(defaultIndex)then
		local menuItem = tolua.cast(mainMenu:getChildByTag(defaultIndex),"CCMenuItemImage") 
		menuItem:selected()
		touchButton(menuItem:getTag())
		updateScrollViewContainerPosition(menuItem,0.1)
	elseif(firstItem ~= nil)then
		print("+===== =================  ")
		firstItem:selected()
		touchButton(firstItem:getTag())
	end
	if(count >= 4)then
        print("count > 3")
    	scrollView:setContentSize(CCSizeMake(120 * count,  topBgSp:getContentSize().height))
    end
	getHappySignData()
	getNewYearData()
	local callbck = function ( ... )
		refreshRechargeTip()
	end
	--判断活动是否开启
	if(SignleRechargeData.isOpen())then
		SignleRechargeController.getInfo(callbck)
	end	
	
	--判断ViP福利是否开启
	if(ActiveCache.isOpenVIPBenefit())then
		getWeekGiftBagTip()
	end

	--判断限时基金活动
	if(ActivityConfigUtil.isActivityOpen("limitFund"))then
		if(LimitFundData.getPeriodOfActivity() == 1)then
			--处于返还阶段
			getLimitFundTip()
		end
	end
end

--[[
	@des:	更新scrollView位置
]]
function updateScrollViewContainerPosition( selectNode,time)

	local posX = selectNode:getPositionX() - scrollView:getViewSize().width/2
	local lnx,px,vw = 0,selectNode:getPositionX(),scrollView:getViewSize().width
	if(px+ selectNode:getContentSize().width< vw ) then
		lnx = 0
	else
		lnx = px - vw*0.5 + selectNode:getContentSize().width/2
		if(lnx > px + selectNode:getContentSize().width  - vw) then
			lnx = px + selectNode:getContentSize().width - vw
		end
	end
	scrollView:setContentOffsetInDuration(ccp(-lnx, 0), time or 0.5)
end

-- 得到
function getTipSprite(  )
	local tipSprite= CCSprite:create("images/common/tip_2.png")
	local numLabel = CCLabelTTF:create("1",g_sFontName, 21)
	numLabel:setPosition(ccp(tipSprite:getContentSize().width/2,tipSprite:getContentSize().height/2))
	numLabel:setAnchorPoint(ccp(0.5,0.5))
	tipSprite:addChild(numLabel)
	return tipSprite
end

function getTipSpriteWithNum()
	local tipSprite= CCSprite:create("images/common/tip_2.png")
	require "script/ui/rechargeActive/BenefitActiveLayer"

	local accountNum = tonumber(BenefitActiveLayer.getAccountNum())
	local cardRate = tonumber(BenefitActiveLayer.getCostNum())
	local cardNum = math.floor(accountNum/cardRate)
	numLabel = CCLabelTTF:create(cardNum,g_sFontName, 21)
	numLabel:setPosition(ccp(tipSprite:getContentSize().width/2,tipSprite:getContentSize().height/2))
	numLabel:setAnchorPoint(ccp(0.5,0.5))
	tipSprite:addChild(numLabel)
	return tipSprite
end

function getNewTip( )

	local newAnimSprite = CCLayerSprite:layerSpriteWithName(CCString:create("images/mail/new/new"), -1,CCString:create(""));
	return newAnimSprite
end

-- 刷新提示的小红圈
function refreshItemByTag( tag )
	-- local mainMenu = scrollView:getChildByTag(_ksTagMainMenu)
	local item = tolua.cast(mainMenu:getChildByTag(tag), "CCMenuItemImage")
	local tipSprite= tolua.cast(item:getChildByTag(101), "CCSprite" )
	if(tipSprite) then
		tipSprite:removeFromParentAndCleanup(true)
		tipSprite=nil
	end
end

-- 刷新新活动开启的提示
function rfcNewTipByTag( tag )
	local item = tolua.cast(mainMenu:getChildByTag(tag), "CCMenuItemImage")
	local newInSprite= tolua.cast(item:getChildByTag(_ksTagActivityNewIn), "CCSprite" )
	if(newInSprite) then
		newInSprite:removeFromParentAndCleanup(true)
		newInSprite=nil
	end
end



function changeButtomLayer(layer)
	_buttomLayer:removeAllChildrenWithCleanup(true)
	_buttomLayer:addChild(layer)
end


function touchButton( tag )
	if(oldTag == tag)then
		return
	end
	oldTag = tag

	if(tag == _tagShowChong)then
		--显示首冲活动
		local layer = FirstPackLayer.createLayer()
		changeButtomLayer(layer)
	elseif(tag == _tagNewActive)then
		--显示新活动
		local layer = NewActiveLayer.createLayer()
		changeButtomLayer(layer)
	elseif(tag == _tagRedPacket)then
		--显示红包
		local layer =RedPacketLayer.createLayer()
		changeButtomLayer(layer)
		rfcNewTipByTag(_tagRedPacket)
		ActiveCache.setActivityStatusByKey("envelope")
	elseif(tag == _tagChengzhang)then
		--显示成长基金
		local layer = GrowthFundLayer.createLayer()
		changeButtomLayer(layer)
	elseif(tag == _tagEatChieken) then
		local layer = RestoreEnergyLayer.createLayer()
		changeButtomLayer(layer)
	elseif(tag== _tagMysteryShop) then
		if(DataCache.getSwitchNodeState(ksSwitchResolve,true)) then
			if( ActiveCache.isMysteryNewIn() ) then
				-- AnimationTip.showTip(GetLocalizeStringBy("key_2617"))
			end
			local layer= MysteryShopLayer.createLayer()
			changeButtomLayer(layer)
		end
	elseif(tag== _tagCardActive) then
		if( BTUtil:getSvrTimeInterval()<ActiveCache.getHeroShopStartTime() or BTUtil:getSvrTimeInterval() > ActiveCache.getHeroShopEndTime()+ ActiveCache.getCardData().coseTime ) then
			AnimationTip.showTip(GetLocalizeStringBy("key_1857"))
			return
		end	
		if(ActiveCache.getHeroShopOpenTime() < tonumber(ServerList.getSelectServerInfo().openDateTime) ) then
			AnimationTip.showTip(GetLocalizeStringBy("key_2586"))
			return
		end

		if(UserModel.getHeroLevel() < 25) then
			AnimationTip.showTip(GetLocalizeStringBy("key_2975"))
			return
		end
		local layer= CardPackActiveLayer.createLayer()
		changeButtomLayer(layer)

		--
		refreshItemByTag(_tagCardActive)
		rfcNewTipByTag(_tagCardActive)
		ActiveCache.setActivityStatusByKey("heroShop")


	elseif( tag == _tagConsume)then
		if( BTUtil:getSvrTimeInterval()<ActiveCache.getSpendStartTime() or BTUtil:getSvrTimeInterval() > ActiveCache.getSpendEndTime()) then
			AnimationTip.showTip(GetLocalizeStringBy("key_1857"))
			return
		end	
		if(ActiveCache.getSpendOpenTime() < tonumber(ServerList.getSelectServerInfo().openDateTime) ) then
			AnimationTip.showTip(GetLocalizeStringBy("key_2586"))
			return
		end
		-- 消费累积
		local layer= ConsumeLayer.createConsumeLayer()
		changeButtomLayer(layer)

		refreshItemByTag(_tagConsume)
		rfcNewTipByTag(_tagConsume)
		ActiveCache.setActivityStatusByKey("spend")

	elseif(tag == _tagChargeReward ) then
		-- 充值回馈
		if( BTUtil:getSvrTimeInterval()<RechargeFeedbackCache.getFeedbackStartTime() or BTUtil:getSvrTimeInterval() > RechargeFeedbackCache.getFeedbackEndTime() ) then
			AnimationTip.showTip(GetLocalizeStringBy("key_1857"))
			return
		end	
		if(RechargeFeedbackCache.getFeedbackOpenTime() < tonumber(ServerList.getSelectServerInfo().openDateTime) ) then
			AnimationTip.showTip(GetLocalizeStringBy("key_2586"))
			return
		end
		-- 充值回馈
		local layer= RechargeFeedbackLayer.createLayer()
		changeButtomLayer(layer)

		refreshItemByTag(_tagChargeReward)
		rfcNewTipByTag(_tagChargeReward)
		ActiveCache.setActivityStatusByKey("topupFund")

	elseif( tag == _tagNewYear)then
		if( BTUtil:getSvrTimeInterval()<ActiveCache.getNewYearStartTime() or BTUtil:getSvrTimeInterval() > ActiveCache.getNewYearEndTime()) then
			AnimationTip.showTip(GetLocalizeStringBy("key_1857"))
			return
		end	
		if(ActiveCache.getNewYearOpenTime() < tonumber(ServerList.getSelectServerInfo().openDateTime) ) then
			AnimationTip.showTip(GetLocalizeStringBy("key_2586"))
			return
		end
		-- 新年礼包
		local layer= NewYearLayer.createNewYearLayer()
		changeButtomLayer(layer)

		refreshItemByTag(_tagNewYear)
		rfcNewTipByTag(_tagNewYear)
		ActiveCache.setActivityStatusByKey("signActivity")

	elseif( tag == _tagWabao) then
		print("wabao")
		--等级限制
		local nowTime = BTUtil:getSvrTimeInterval()
	    local endTime = ActivityConfig.ConfigCache.robTomb.end_time
	    local beginTime = ActivityConfig.ConfigCache.robTomb.start_time
	    if(nowTime < beginTime) or (nowTime > endTime) then
	    	AnimationTip.showTip(GetLocalizeStringBy("key_1857"))
			return
		end
		local level = ActivityConfig.ConfigCache.robTomb.data[1].levelLimit
		if(tonumber(level) > UserModel.getHeroLevel()) then
			AnimationTip.showTip(GetLocalizeStringBy("key_1856")..level..GetLocalizeStringBy("key_1287"))
			return
		end
		
		local layer = DigCowryLayer:createDigCowry()
		changeButtomLayer(layer)
		refreshItemByTag(_tagWabao)

		rfcNewTipByTag(_tagWabao)
		ActiveCache.setActivityStatusByKey("robTomb")
	
	elseif( tag== _tagBenefit) then
		---- 福利活动
		if(ActivityConfigUtil.isActivityOpen("weal") ) then
			require "script/ui/rechargeActive/BenefitActiveLayer"
			local layer = BenefitActiveLayer.createLayer()
			changeButtomLayer(layer)

			rfcNewTipByTag(_tagBenefit)
			ActiveCache.setActivityStatusByKey("weal")

		else
			AnimationTip.showTip(GetLocalizeStringBy("key_1857"))
			return
		end
	elseif tag == _tagElvesBenefit then
		---- 福利活动之资源矿宝藏
		if MineralElvesData.isOpen() then
			require "script/ui/rechargeActive/elvesBenefit/ElvesBenefitLayer"
			local layer = ElvesBenefitLayer.createLayer()
			changeButtomLayer(layer)

			rfcNewTipByTag(_tagElvesBenefit)
			ActiveCache.setActivityStatusByKey("mineralelves")

		else
			AnimationTip.showTip(GetLocalizeStringBy("key_1857"))
			return
		end

    ----------------------------------------- 月签到 add by DJN
	elseif(tag == _tagMonthSign) then
		if(DataCache.getSwitchNodeState(kMonthSignIn))then
		   local time =  CCUserDefault:sharedUserDefault():getIntegerForKey("monthSign")
	       --print("获取上次点击的时间")
			if(time == 0)then
				--如果是第一次点击月签到这个活动，保存一下这次点击月签到的时间，根据ActiveCache中IsNewInMonthSign的判断，下次就不出现new的图标了
				--print("第一次进入月签到")
				local time= BTUtil:getSvrTimeInterval()
				-- print("获取到当前服务器时间")
				-- print(time)
	    		CCUserDefault:sharedUserDefault():setIntegerForKey("monthSign" , time )
	    		--print("将用户点击的月签到活动时间保存")
			end
	        require "script/ui/rechargeActive/MonthSignLayer"
			local layer= MonthSignLayer.showLayer()
			changeButtomLayer(layer)

			refreshItemByTag(_tagMonthSign)
			rfcNewTipByTag(_tagMonthSign)
		end
    ---------------------------------------------
    -------------------------------------------积分轮盘 add by djn
    elseif(tag == _tagScoreWheel) then
    	
    	require "script/ui/rechargeActive/scoreWheel/ScoreWheelLayer"
    	local layer= ScoreWheelLayer.showLayer()
		changeButtomLayer(layer)

		refreshItemByTag(_tagScoreWheel)
		rfcNewTipByTag(_tagScoreWheel)
		ActiveCache.setActivityStatusByKey("roulette")
	-------------------------------------------聚宝盆 add by djn
    elseif(tag == _tagBowl) then
    	
    	require "script/ui/rechargeActive/bowl/BowlLayer"
    	local layer= BowlLayer.showLayer()
		changeButtomLayer(layer)

		refreshItemByTag(_tagBowl)
		rfcNewTipByTag(_tagBowl)
		ActiveCache.setActivityStatusByKey("treasureBowl")
    	-------------------------------------------积分商城 add by djn
    elseif(tag == _tagScoreShop) then
    	
    	require "script/ui/rechargeActive/scoreShop/ScoreShopLayer"
    	local layer= ScoreShopLayer.showLayer()
		changeButtomLayer(layer)

		refreshItemByTag(_tagScoreShop)
		rfcNewTipByTag(_tagScoreShop)
		ActiveCache.setActivityStatusByKey("scoreShop")
    -------------------------------------------跨服团购 add by djn
    elseif(tag == _tagWorldGroupOn) then      
        require "script/ui/rechargeActive/worldGroupBuy/WorldGroupLayer"
        local layer= WorldGroupLayer.showLayer()
        changeButtomLayer(layer)

        refreshItemByTag(_tagWorldGroupOn)
        rfcNewTipByTag(_tagWorldGroupOn)
        ActiveCache.setActivityStatusByKey("worldgroupon")
	---------------------------------------------
    elseif(tag == _tagTravelShop) then      
        btimport "script/ui/rechargeActive/travelShop/TravelShopLayer"
        local layer= TravelShopLayer.create()
        changeButtomLayer(layer)
        refreshItemByTag(_tagTravelShop)
        rfcNewTipByTag(_tagTravelShop)
       	ActiveCache.setActivityStatusByKey("travelShop")
	elseif (tag == _tagVIPBenefit) then
		require "script/ui/vip_benefit/VIPBenefitLayer"
		local layer = VIPBenefitLayer.createLayer()
		changeButtomLayer(layer)
		refreshItemByTag(_tagVIPBenefit)


	elseif(tag == _tagChange)then
		-- 兑换
		if( BTUtil:getSvrTimeInterval()<tonumber(ActivityConfig.ConfigCache.actExchange.start_time) or BTUtil:getSvrTimeInterval() > tonumber(ActivityConfig.ConfigCache.actExchange.end_time) ) then
			AnimationTip.showTip(GetLocalizeStringBy("key_1857"))
			return
		end	
		if(tonumber(ActivityConfig.ConfigCache.actExchange.need_open_time) < tonumber(ServerList.getSelectServerInfo().openDateTime) ) then
			AnimationTip.showTip(GetLocalizeStringBy("key_2586"))
			return
		end
		-- 等级限制
		local level = ActiveCache.getChangeOpenLv() 
		if(tonumber(level) > UserModel.getHeroLevel()) then
			AnimationTip.showTip(GetLocalizeStringBy("key_1856")..level..GetLocalizeStringBy("key_1287"))
			return
		end
		local layer= ChangeActiveLayer.createChangeLayer()
		changeButtomLayer(layer)

		rfcNewTipByTag(_tagChange)
		ActiveCache.setActivityStatusByKey("actExchange")

	elseif(tag == _tagTuan)then
		-- 团购
		if( BTUtil:getSvrTimeInterval()<tonumber(ActivityConfig.ConfigCache.groupon.start_time) or BTUtil:getSvrTimeInterval() > tonumber(ActivityConfig.ConfigCache.groupon.end_time) ) then
			AnimationTip.showTip(GetLocalizeStringBy("key_1857"))
			return
		end	
		if(tonumber(ActivityConfig.ConfigCache.groupon.need_open_time) < tonumber(ServerList.getSelectServerInfo().openDateTime) ) then
			AnimationTip.showTip(GetLocalizeStringBy("key_2586"))
			return
		end

		local layer= TuanLayer.createTuanLayer()
		changeButtomLayer(layer)

		rfcNewTipByTag(_tagTuan)
		ActiveCache.setActivityStatusByKey("groupon")

	elseif(tag == _tagChargeRaffle)then
		--充值抽奖
		require "script/ui/rechargeActive/chargeRaffle/ChargeRaffleLayer"
		local  layer = ChargeRaffleLayer.create()
		changeButtomLayer(layer)

		rfcNewTipByTag(_tagChargeRaffle)
		ActiveCache.setActivityStatusByKey("chargeRaffle")

	elseif(tag== _tagMonthCard) then
		-- 月卡
		-- print(" monthcard  ==================== ")
		require "script/ui/month_card/MonthCardLayer"
		local layer= MonthCardLayer.createLayer()
		changeButtomLayer(layer)
	--充值大放送
	--added by Zhang Zihang
	elseif(tag == _tagTopupReward)then
		require "script/ui/rechargeActive/rechargeBigRun/RechargeBigRunLayer"
		local layer = RechargeBigRunLayer.createLayer()
		changeButtomLayer(layer)

		rfcNewTipByTag(_tagTopupReward)
		ActiveCache.setActivityStatusByKey("topupReward")

	--￥￥￥￥￥￥￥￥￥￥￥￥￥￥￥￥￥￥￥￥￥￥￥￥￥￥￥￥￥￥￥￥用钱砸出来的分割线￥￥￥￥￥￥￥￥￥￥￥￥￥￥￥￥￥￥￥￥￥￥￥￥￥￥￥￥￥￥￥￥	
	--计步活动
	--added by Zhang Zihang
	elseif tag == _tagStepCounter then
		require "script/ui/rechargeActive/stepCounterActive/StepCounterLayer"
		local layer = StepCounterLayer.createLayer()
		changeButtomLayer(layer)

		rfcNewTipByTag(_tagStepCounter)
		ActiveCache.setActivityStatusByKey("stepCounter")
	-- added by bzx
    elseif tag == _tagTransfer then
        -- require "script/ui/rechargeActive/transfer/TransferLayer"
        -- local layer = TransferLayer.create()
        -- changeButtomLayer(layer)
        -- rfcNewTipByTag(_tagTransfer)
        -- ActiveCache.setActivityStatusByKey("transfer")
    --合服累计登录
    --added by Zhang Zihang
    elseif tag == _tagMergeAccumulate then
    	require "script/ui/mergeServer/accumulate/AccumulateActivity"
		changeButtomLayer(AccumulateActivity.createLayer(1))
		rfcNewTipByTag(_tagMergeAccumulate)
        ActiveCache.setActivityStatusByKey("mergeAccumulate")
	--合服消费累积
	--added by Zhang Zihang
    elseif tag == _tagMergeRecharge then
    	require "script/ui/mergeServer/accumulate/AccumulateActivity"
		changeButtomLayer(AccumulateActivity.createLayer(2))
		rfcNewTipByTag(_tagMergeRecharge)
        ActiveCache.setActivityStatusByKey("mergeRecharge")
   	elseif tag == _tagLimitShop then
   		require "script/ui/rechargeActive/limitShop/LimitShopData"
   		if( BTUtil:getSvrTimeInterval() < tonumber(LimitShopData.getStartTime()) or BTUtil:getSvrTimeInterval() >= tonumber(LimitShopData.getEndTime()) ) then
			AnimationTip.showTip(GetLocalizeStringBy("key_1857"))
			return
		end
   		require "script/ui/rechargeActive/limitShop/LimitShopLayer"
		local layer = LimitShopLayer.createLayer()
		changeButtomLayer(layer)
		rfcNewTipByTag(_tagLimitShop)
		ActiveCache.setActivityStatusByKey("limitShop")
   	elseif tag == _tagFestival then
   		require "script/ui/rechargeActive/festivalActive/FestivalActiveLayer"
		changeButtomLayer(FestivalActiveLayer.createLayer())

		rfcNewTipByTag(_tagFestival)
		ActiveCache.setActivityStatusByKey("festival")
	-- 黑市兑换  Add by yangrui
	elseif tag == _blackshop then
		if( BTUtil:getSvrTimeInterval() < tonumber(BlackshopData.getStartTime()) or BTUtil:getSvrTimeInterval() >= tonumber(BlackshopData.getEndTime()) ) then
			AnimationTip.showTip(GetLocalizeStringBy("key_1857"))
			return
		end
		
		if(tonumber(ActivityConfig.ConfigCache.blackshop.need_open_time) < tonumber(ServerList.getSelectServerInfo().openDateTime) ) then
			AnimationTip.showTip(GetLocalizeStringBy("key_2586"))
			return
		end
		require "script/ui/rechargeActive/blackshop/BlackshopLayer"
		changeButtomLayer(BlackshopLayer.createLayer())

		rfcNewTipByTag(_blackshop)
		ActiveCache.setActivityStatusByKey("blackshop")
	elseif tag == _tagFsReborn then 
		if( not ActivityConfigUtil.isActivityOpen("fsReborn") )then 
			AnimationTip.showTip(GetLocalizeStringBy("key_1857"))
			return
		end
		
		require "script/ui/rechargeActive/soulReborn/SoulRebornLayer"
		local layer = SoulRebornLayer.createLayer()
		changeButtomLayer(layer)

		rfcNewTipByTag(_tagFsReborn)
		ActiveCache.setActivityStatusByKey("fsReborn") 
	elseif tag == _happySign then
		if ( BTUtil:getSvrTimeInterval() < tonumber(HappySignData.getStartTime()) or BTUtil:getSvrTimeInterval() >= tonumber(HappySignData.getEndTime()) ) then
			AnimationTip.showTip(GetLocalizeStringBy("key_1857"))
			return
		end
		require "script/ui/rechargeActive/happySign/HappySignLayer"
		changeButtomLayer(HappySignLayer.createLayer())
		rfcNewTipByTag(_happySign)
		ActiveCache.setActivityStatusByKey("happySign")	
	-- 缤纷回馈  add by yangrui  2015-10-30
	elseif tag == _tagRechargeGift then
		if ( BTUtil:getSvrTimeInterval() < tonumber(RechargeGiftData.getStartTime()) or BTUtil:getSvrTimeInterval() >= tonumber(RechargeGiftData.getEndTime()) ) then
			AnimationTip.showTip(GetLocalizeStringBy("key_1857"))
			return
		end
		if( tonumber(ActivityConfig.ConfigCache.rechargeGift.need_open_time) < tonumber(ServerList.getSelectServerInfo().openDateTime) ) then
			AnimationTip.showTip(GetLocalizeStringBy("key_2586"))
			return
		end
		changeButtomLayer(RechargeGiftLayer.createLayer())
		rfcNewTipByTag(_tagRechargeGift)
		ActiveCache.setActivityStatusByKey("rechargeGift")
	elseif tag == _tagSingleRecharge then
		if( BTUtil:getSvrTimeInterval() < tonumber(SignleRechargeData.getStartTime()) or BTUtil:getSvrTimeInterval() >= tonumber(SignleRechargeData.getEndTime()) ) then
			AnimationTip.showTip(GetLocalizeStringBy("key_1857"))
			return
		end
		rfcNewTipByTag(_tagSingleRecharge)
		require "script/ui/rechargeActive/singleRecharge/SignleRechargeLayer"
		changeButtomLayer(SignleRechargeLayer.createLayer())
		ActiveCache.setActivityStatusByKey("oneRecharge")
		-- refreshRechargeTip(_tagSingleRecharge)
	elseif tag == _tagLimitFund then
		if(not LimitFundData.isOpen() )then
			AnimationTip.showTip(GetLocalizeStringBy("key_1857"))
			return
		end
		changeButtomLayer(LimitFundLayer.createLayer())
		rfcNewTipByTag(_tagLimitFund)
		ActiveCache.setActivityStatusByKey("limitFund")
	else
   	end
end


function getLayerByTag(tag )

	if(oldTag == tag)then
		return
	end
	oldTag = tag

	if(tag == _tagShowChong)then
		--显示首冲活动
		local layer = FirstPackLayer.createLayer()
		return layer

	elseif(tag == _tagChengzhang)then
		--显示成长基金
		local layer = GrowthFundLayer.createLayer()
		return layer
	elseif(tag == _tagEatChieken) then
		local layer = RestoreEnergyLayer.createLayer()
		return layer
	elseif(tag== _tagMysteryShop) then
		if(DataCache.getSwitchNodeState(ksSwitchResolve,true)) then
			if( ActiveCache.isMysteryNewIn() ) then
				AnimationTip.showTip(GetLocalizeStringBy("key_2617"))
			end
			local layer= MysteryShopLayer.createLayer()
			return layer
		end
	elseif(tag== _tagCardActive) then
		if( BTUtil:getSvrTimeInterval()<ActiveCache.getHeroShopStartTime() or BTUtil:getSvrTimeInterval() > ActiveCache.getHeroShopEndTime()+ ActiveCache.getCardData().coseTime ) then
			AnimationTip.showTip(GetLocalizeStringBy("key_1857"))
			return
		end	
		if(ActiveCache.getHeroShopOpenTime() < tonumber(ServerList.getSelectServerInfo().openDateTime) ) then
			AnimationTip.showTip(GetLocalizeStringBy("key_2586"))
			return
		end

		if(UserModel.getHeroLevel() < 25) then
			AnimationTip.showTip(GetLocalizeStringBy("key_2975"))
			return
		end

		local layer= CardPackActiveLayer.createLayer()
		return layer	
	elseif( tag == _tagConsume)then
		if( BTUtil:getSvrTimeInterval()<ActiveCache.getSpendStartTime() or BTUtil:getSvrTimeInterval() > ActiveCache.getSpendEndTime()) then
			AnimationTip.showTip(GetLocalizeStringBy("key_1857"))
			return
		end	
		if(ActiveCache.getSpendOpenTime() < tonumber(ServerList.getSelectServerInfo().openDateTime) ) then
			AnimationTip.showTip(GetLocalizeStringBy("key_2586"))
			return
		end
		-- 消费累积
		local layer= ConsumeLayer.createConsumeLayer()
		changeButtomLayer(layer)
	elseif(tag == _tagChargeReward ) then
		-- 充值回馈
		if( BTUtil:getSvrTimeInterval()<RechargeFeedbackCache.getFeedbackStartTime() or BTUtil:getSvrTimeInterval() > RechargeFeedbackCache.getFeedbackEndTime() ) then
			AnimationTip.showTip(GetLocalizeStringBy("key_1857"))
			return
		end	
		if(RechargeFeedbackCache.getFeedbackOpenTime() < tonumber(ServerList.getSelectServerInfo().openDateTime) ) then
			AnimationTip.showTip(GetLocalizeStringBy("key_2586"))
			return
		end
		-- 充值回馈
		local layer= RechargeFeedbackLayer.createLayer()
		return layer
	elseif( tag == _tagNewYear)then
		if( BTUtil:getSvrTimeInterval()<ActiveCache.getNewYearStartTime() or BTUtil:getSvrTimeInterval() > ActiveCache.getNewYearEndTime()) then
			AnimationTip.showTip(GetLocalizeStringBy("key_1857"))
			return
		end	
		if(ActiveCache.getNewYearOpenTime() < tonumber(ServerList.getSelectServerInfo().openDateTime) ) then
			AnimationTip.showTip(GetLocalizeStringBy("key_2586"))
			return
		end
		-- 新年礼包
		local layer= NewYearLayer.createNewYearLayer()
		return layer
	elseif( tag == _tagWabao) then
		print("wabao")
		--等级限制
		local nowTime = BTUtil:getSvrTimeInterval()
	    local endTime = ActivityConfig.ConfigCache.robTomb.end_time
	    local beginTime = ActivityConfig.ConfigCache.robTomb.start_time 
	    if(nowTime < beginTime) or (nowTime > endTime) then
	    	AnimationTip.showTip(GetLocalizeStringBy("key_1857"))
			return
		end
		local level = ActivityConfig.ConfigCache.robTomb.data[1].levelLimit
		print_t(ActivityConfig.ConfigCache.robTomb.data[1])
		if(tonumber(level) > UserModel.getHeroLevel()) then
			AnimationTip.showTip(GetLocalizeStringBy("key_1856")..level..GetLocalizeStringBy("key_1287"))
			return
		end
		require "script/ui/digCowry/DigCowryLayer"	
		local layer = DigCowryLayer:createDigCowry()
		return layer
	
	elseif( tag== _tagBenefit) then

		if(ActivityConfigUtil.isActivityOpen("weal") ) then
			require "script/ui/rechargeActive/BenefitActiveLayer"
			local layer = BenefitActiveLayer.createLayer()
			return layer
		else
			AnimationTip.showTip(GetLocalizeStringBy("key_1857"))
			return
		end
		return layer
	end
end

-- 
local function getGrowUpInfo( cbFlag, dictData, bRet  )
	
	-- print("cool time",tonumber(UserModel.getUserInfo().create_time)+30*24*60*60 - BTUtil.getSvrTimeInterval())
	if (dictData.err == "ok") then
		-- added by zhz
		-- 将数据缓存器起来数据
		ActiveCache.setPrizeInfo(dictData.ret)
        -- 未充值，显示首冲
        if(dictData.ret == "unactived")then
        	_boolGrowUp = true
        elseif(dictData.ret == "invalid_time" or dictData.ret == "fetch_all" ) then
            _boolGrowUp = false
        else
        	_boolGrowUp = true
            count = count + 1 
        end
        
    end
    createScrollView()
   -- 

  
end

local function isPayAction(cbFlag, dictData, bRet )
    if (dictData.err == "ok") then
        -- 未充值，显示首冲
        if(dictData.ret == "false" or dictData.ret == false) then
            _boolCharge = true
        elseif(dictData.ret == "true" or dictData.ret == true ) then
            _boolCharge = false
            count = count + 1 
        end
        RequestCenter.growUp_getInfo(getGrowUpInfo)
    end
end

--是否充值过
function getNetData( ... )
	RequestCenter.user_isPay(isPayAction)
	
end

function  getBgWidth( ... )
	return topBgSp:getContentSize().height * g_fScaleX
end

function  getTopSize( ... )
	return _topBg:getContentSize()
end

function getTopFactHightSize( ... )
	
end


--By ZQ 充值回馈
function getTopBgHeight()
	return topBgSp:getContentSize().height
end

function getTopBgSp()
	return topBgSp
end

--更新红圈的翻卡次数
function refreshCardNum(remainCard)
	if tonumber(remainCard) <= 0 then
		local item = tolua.cast(mainMenu:getChildByTag(_tagBenefit), "CCMenuItemImage")
		local tipSprite= tolua.cast(item:getChildByTag(101), "CCSprite" )
		if(tipSprite) then
			tipSprite:removeFromParentAndCleanup(true)
			tipSprite=nil
		end
	else
		numLabel:setString(remainCard)
	end
end

-- 得到限时兑换活动图标1
function getExchangeActiveIcon1( ... )
	local images_n = nil
	if(ActivityConfig.ConfigCache.actExchange.data[1])then
		if(ActivityConfig.ConfigCache.actExchange.data[1].act_icon1)then
			images_n =  "images/recharge/change/" .. ActivityConfig.ConfigCache.actExchange.data[1].act_icon1
		else
			images_n =  "images/recharge/change/change_n.png"
		end
	else
		images_n =  "images/recharge/change/change_n.png"
	end
	return images_n
end

-- 得到限时兑换活动图标2
function getExchangeActiveIcon2( ... )
	local images_h = nil
	if(ActivityConfig.ConfigCache.actExchange.data[1])then
		if(ActivityConfig.ConfigCache.actExchange.data[1].act_icon2)then
			images_h =  "images/recharge/change/" .. ActivityConfig.ConfigCache.actExchange.data[1].act_icon2
		else
			images_h =  "images/recharge/change/change_h.png"
		end
	else
		images_h =  "images/recharge/change/change_h.png"
	end
	return images_h
end

--[[
	@des 	: 创建缤纷回馈小红点   add by yangrui
	@param 	: 
	@return : 
--]]
function getRechargeGiftTipSpriteWithNum( ... )
	local tipSprite= CCSprite:create("images/common/tip_2.png")
	-- getRechargeGiftTipNum
	numLabel = CCLabelTTF:create(ActiveCache.getRechargeGiftTipNum(),g_sFontName,21)
	numLabel:setPosition(ccp(tipSprite:getContentSize().width/2,tipSprite:getContentSize().height/2))
	numLabel:setAnchorPoint(ccp(0.5,0.5))
	tipSprite:addChild(numLabel)
	return tipSprite
end

--[[
	@des 	: 刷新缤纷回馈小红点   add by yangrui
	@param 	: 
	@return : 
--]]
function refreshRechargeGiftTipNum( tag )
	local item = tolua.cast(mainMenu:getChildByTag(tag), "CCMenuItemImage")
	local tipSprite = tolua.cast(item:getChildByTag(101), "CCSprite" )
	
	if tipSprite then
		tipSprite:removeFromParentAndCleanup(true)
		tipSprite=nil
	end
	if ActiveCache.getRechargeGiftTipNum() > 0 then
		local tipSprite = getRechargeGiftTipSpriteWithNum()
        tipSprite:setAnchorPoint(ccp(1,1))
        tipSprite:setPosition(ccp(item:getContentSize().width*0.98,item:getContentSize().height*0.98))
        item:addChild(tipSprite,1,101)
	end
end

function getHappySignData( ... )
	-- body
		-- body
	if not ActivityConfigUtil.isActivityOpen("happySign") then 
		return
	end
	HappySignController.getSignInfo(function ( ... )
		-- body
		-- local num = HappySignData.getCanReceiveDays()
		-- if num <= 0 then
		-- 	return
		-- end
		local isHave = HappySignData.ishaveGainToday()
		if (isHave)then
			return
		end
		local item = tolua.cast(mainMenu:getChildByTag(_happySign),"CCMenuItemImage")
		local tipSprite= CCSprite:create("images/common/tip_2.png")
		local numLabel = CCLabelTTF:create(HappySignData.getCanReceiveDays(),g_sFontName,21)
		-- numLabel:setPosition(ccp(tipSprite:getContentSize().width/2,tipSprite:getContentSize().height/2))
		-- numLabel:setAnchorPoint(ccp(0.5,0.5))
		-- tipSprite:addChild(numLabel,1,101)
		tipSprite:setAnchorPoint(ccp(1,1))
		tipSprite:setPosition(ccp(item:getContentSize().width,item:getContentSize().height))
		item:addChild(tipSprite,1,101)
	end)
end

--[[
	@des 	: 刷新欢乐签到小红点   add by shengyixian
	@param 	: 
	@return : 
--]]
function refreshHappySignTip( ... )
	-- body
	local item = tolua.cast(mainMenu:getChildByTag(_happySign),"CCMenuItemImage")
	local tipSprite = tolua.cast(item:getChildByTag(101), "CCSprite" )
	local isHave = HappySignData.ishaveGainToday()
	if isHave then
		if tipSprite ~= nil then
		tipSprite:removeFromParentAndCleanup(true)
	end
		-- return
	end
	-- local numLabel = tolua.cast(tipSprite:getChildByTag(101), "CCLabelTTF" )
	-- numLabel:setString(HappySignData.getCanReceiveDays())
end

--刷新单充回馈小红点  add by fuqiongqiong 2016.3.10
function refreshRechargeTip(  )
	local item = tolua.cast(mainMenu:getChildByTag(_tagSingleRecharge), "CCMenuItemImage")
	local tipSprite = tolua.cast(item:getChildByTag(137), "CCSprite" )
	
	if tipSprite then
		tipSprite:removeFromParentAndCleanup(true)
		tipSprite=nil
	end
	local tipNum = SignleRechargeData.getRedTipNum()
	if tipNum > 0 then
		local tipSprite = CCSprite:create("images/common/tip_2.png")
        tipSprite:setAnchorPoint(ccp(1,1))
        tipSprite:setPosition(ccp(item:getContentSize().width*0.98,item:getContentSize().height*0.98))
        item:addChild(tipSprite,1,137)

        local numLabel = CCLabelTTF:create(tipNum,g_sFontName,21)
		numLabel:setPosition(ccp(tipSprite:getContentSize().width/2,tipSprite:getContentSize().height/2))
		numLabel:setAnchorPoint(ccp(0.5,0.5))
		tipSprite:addChild(numLabel)
	end
end

function callbck( cbFlag, dictData, bRet )
	 if(dictData.err == "ok") then
	 	ActiveCache.setNewYearServiceInfo( dictData.ret )
		local isHave = ActiveCache.ishaveGainToday()
		if (isHave)then
			return
		end
		local item = tolua.cast(mainMenu:getChildByTag(_tagNewYear),"CCMenuItemImage")
		local tipSprite= CCSprite:create("images/common/tip_2.png")
		tipSprite:setAnchorPoint(ccp(1,1))
		tipSprite:setPosition(ccp(item:getContentSize().width,item:getContentSize().height))
		item:addChild(tipSprite,1,108)
	end
end
function getNewYearData( ... )	
	if not NewYearLayer.isOpenNewYear() then 
		return
	end
	-- 拉取消费累积数据
	Network.rpc(callbck, "signactivity.getSignactivityInfo", "signactivity.getSignactivityInfo", nil, true)
end
--累计登陆的小红点提示
function refreshNewYearTip( ... )
	local item = tolua.cast(mainMenu:getChildByTag(_tagNewYear), "CCMenuItemImage")
	local tipSprite = tolua.cast(item:getChildByTag(108), "CCSprite" )
	if tipSprite then
		tipSprite:removeFromParentAndCleanup(true)
		tipSprite=nil
	end
	local isHave =ActiveCache.ishaveGainToday()
	if isHave then
		if tipSprite ~= nil then
		tipSprite:removeFromParentAndCleanup(true)
		end
	end 
end
--获取VIP福利的红点提示
function getWeekGiftBagTip(  )
	
	local isRedTip = VIPBenefitData.AllGiftBagTip()
		if isRedTip then
			return
		end
		local item = tolua.cast(mainMenu:getChildByTag(_tagVIPBenefit),"CCMenuItemImage")
		local tipSprite= CCSprite:create("images/common/tip_2.png")
		tipSprite:setAnchorPoint(ccp(1,1))
		tipSprite:setPosition(ccp(item:getContentSize().width,item:getContentSize().height))
		item:addChild(tipSprite,1,111)
end
--刷新VIP福利红点
function refreshweekGiftBagTip( ... )
	local item = tolua.cast(mainMenu:getChildByTag(_tagVIPBenefit), "CCMenuItemImage")
	local tipSprite = tolua.cast(item:getChildByTag(111), "CCSprite" )
	if tipSprite then
		tipSprite:removeFromParentAndCleanup(true)
		tipSprite=nil
	end
	local isRedTip = VIPBenefitData.AllGiftBagTip()
		if isRedTip then
			if tipSprite ~= nil then
				tipSprite:removeFromParentAndCleanup(true)
			end
		end
end

--获取限时基金红点提示
function getLimitFundTip( ... )
	local isRedTip = LimitFundData.isRedTip()
		if not isRedTip then
			return
		end
		local item = tolua.cast(mainMenu:getChildByTag(_tagLimitFund),"CCMenuItemImage")
		local tipSprite= CCSprite:create("images/common/tip_2.png")
		tipSprite:setAnchorPoint(ccp(1,1))
		tipSprite:setPosition(ccp(item:getContentSize().width,item:getContentSize().height))
		item:addChild(tipSprite,1,139)
end

--刷新限时基金红点
function refreshLimitFundTip( ... )
	local item = tolua.cast(mainMenu:getChildByTag(_tagLimitFund), "CCMenuItemImage")
	local tipSprite = tolua.cast(item:getChildByTag(139), "CCSprite" )
	if tipSprite then
		tipSprite:removeFromParentAndCleanup(true)
		tipSprite=nil
	end
	local isRedTip = LimitFundData.isRedTip()
		if not isRedTip then
			if tipSprite ~= nil then
				tipSprite:removeFromParentAndCleanup(true)
			end
		end
end