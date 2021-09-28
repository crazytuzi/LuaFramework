-- Filename：	GodWeaponCopyMainLayer.lua
-- Author：		LLP
-- Date：		2014-12-15
-- Purpose：		神兵据点主界面


module("GodWeaponCopyMainLayer", package.seeall)

require "db/DB_Vip"
require "db/DB_Overcome"
require "db/DB_Normal_config"
require "script/utils/TimeUtil"
require "script/ui/formation/MakeUpFormationLayer"
require "script/ui/godweapon/godweaponcopy/GodCopyUtil"
require "script/ui/godweapon/godweaponcopy/BuyBuffLayer"
require "script/ui/godweapon/godweaponcopy/GodWeaponChest"
require "script/ui/godweapon/godweaponcopy/ShowRewardLayer"
require "script/ui/godweapon/godweaponcopy/GodWeaponCopyData"
require "script/ui/godweapon/godweaponRank/GodWeaponRankLayer"
require "script/ui/godweapon/godweaponcopy/ChooseChallengerLayer"
require "script/ui/godweapon/godweaponcopy/GodWeaponCopyService"
require "script/ui/godweapon/godweaponcopy/AddHeroLayer"
require "script/ui/godweapon/godweaponcopy/BuyTimeLayer"
require "script/ui/shopall/godShop/GodShopLayer"
local _kTagBox 			= 10001		--宝箱tag
local _kTagBattle 		= 10002		--据点tag
local _kTagBuff 		= 10003 	--附加属性tag

local kDarkLayerZOrder  = 100

local _copyInfo 		= nil 		--enter信息
local _mainLayer 		= nil		--主层
local _starLabel 		= nil		--下边星数label
local _defeatLabel	 	= nil		--下边防御label
local _lifeLabel		= nil		--下边血量label
local _attackLabel		= nil 		--下边攻击label
local _challengeTimeLabel = nil

local _touch_priority   = -500      --触摸相应级别

local _allPass 			=false 		--通关状态
local _canClick 		= true

local _status 			= 1 		--1为据点
local _challengeTime 	= 0
local _buyNum 			= 0

--名称、 关卡层数、积分
local _passPointLabel
local _passNameLabel
local _passNumLabel

local _isRewardTime 	= false

local _middleItem 		= nil
local addTimeMenu 		= nil
local bottomBgSprite 	= nil

--中间的按钮是否有效, 防止特效没播完
local _isCanEffect 		= false

-- 播放特效时屏蔽按钮事件
local _interceptLayer 	= nil

local _toNextMenu 		= nil

-- 光特效
local _lightEffect 		= nil


--初始化
function init( ... )
	-- body
	_copyInfo 			= nil
	_mainLayer 			= nil
	_starLabel 			= nil
	_defeatLabel		= nil
	_lifeLabel 			= nil
	_attackLabel 		= nil
	_passPointLabel 	= nil
	_passNameLabel		= nil
	_passNumLabel		= nil
	addTimeMenu 		= nil
	_interceptLayer 	= nil
	_challengeTimeLabel = nil
	_allPass 			= false
	_isRewardTime 		= false
	_canClick 			= true
	_middleItem 		= nil
	_toNextMenu 		= nil
	_lightEffect 		= nil
	bottomBgSprite 		= nil
	_challengeTime 		= 0
	_status 			= 1
	_buyNum 			= 0
end

--layer进入退出
function onNodeEvent(event)
	if (event == "enter") then
		_mainLayer:registerScriptTouchHandler(onTouchesHandler, false, _touch_priority, true)
        _mainLayer:setTouchEnabled(true)
        AudioUtil.playBgm("audio/bgm/music04.mp3")
	elseif (event == "exit") then
		_mainLayer:unregisterScriptTouchHandler()
		AudioUtil.playMainBgm()
	end
end
--layer触摸事件
function onTouchesHandler( eventType, x, y )
	if (eventType == "began") then
		print("GodWeaponCopyMainLayer")
		return false
	end
end

-----------------------------------------------中间动画相关BEGIN-----------------------------------
function removeInterceptLayer()
	if(_interceptLayer ~= nil)then
		_interceptLayer:removeFromParentAndCleanup(true)
		_interceptLayer = nil
	end
end

function addInterceptLayer()

	removeInterceptLayer()

	_interceptLayer = CCLayer:create()

	_interceptLayer:registerScriptHandler(function ( eventType,node )
        if(eventType == "enter") then
           	_interceptLayer:registerScriptTouchHandler(function ( ... )
           		Logger.trace("addInter, touch")
           		return true
           	end,false, -1000,true)
        	_interceptLayer:setTouchEnabled(true)
        end
        if(eventType == "exit") then
            _interceptLayer:unregisterScriptTouchHandler()
        end
    end)

	local curScene = CCDirector:sharedDirector():getRunningScene()
    curScene:addChild(_interceptLayer)
end

-- 下个场景
function nextSenceEffect()
	setMiddleItemVisible(false)
	openDoorEffect()
end

-- 场景特效
function transToNextEffect()
	-- addInterceptLayer()
	local effecSprite = CCLayerSprite:layerSpriteWithName(CCString:create("images/base/effect/god_copy/changjingtexiao/changjingtexiao"), -1,CCString:create(""));
	effecSprite:setPosition(ccp(g_winSize.width*0.5, g_winSize.height*0.5))
	local replace_file = "images/godweaponcopy/copy_bg/" .. GodWeaponCopyData.getCopyBgName()

	local replaceXmlSprite = tolua.cast( effecSprite:getChildByTag(1000) , "CCXMLSprite")
    replaceXmlSprite:setReplaceFileName(CCString:create(replace_file))

    local replaceXmlSprite = tolua.cast( effecSprite:getChildByTag(1002) , "CCXMLSprite")
    replaceXmlSprite:setReplaceFileName(CCString:create(replace_file))

    local replaceXmlSprite = tolua.cast( effecSprite:getChildByTag(1003) , "CCXMLSprite")
    replaceXmlSprite:setReplaceFileName(CCString:create(replace_file))

    local replaceXmlSprite = tolua.cast( effecSprite:getChildByTag(1004) , "CCXMLSprite")
    replaceXmlSprite:setReplaceFileName(CCString:create(replace_file))

	effecSprite:setScale(g_fBgScaleRatio)
	local curScene = CCDirector:sharedDirector():getRunningScene()
    curScene:addChild(effecSprite,2000)

	function animation_end( ... )
		GodCopyUtil.addNextTransActionEffect()

		effecSprite:removeFromParentAndCleanup(true)
		effecSprite = nil
		if(_mainLayer~=nil)then
			_mainLayer:setVisible(false)
			_mainLayer:removeFromParentAndCleanup(true)
			_mainLayer = nil
		end

		_mainLayer = createLayer()
		MainScene.changeLayer(_mainLayer,"GodWeaponCopyMainLayer")
	end

	--增加动画监听
    local delegate = BTAnimationEventDelegate:create()
    delegate:registerLayerEndedHandler(animation_end)
    effecSprite:setDelegate(delegate)

	-- 删除之前光的特效
	_lightEffect:setVisible(false)
	_lightEffect:removeFromParentAndCleanup(true)
	-- setClick(true)

end

-- 开门特效
function openDoorEffect()
	print("nextSenceEffect")
	local effecSprite = CCLayerSprite:layerSpriteWithName(CCString:create("images/base/effect/god_copy/kaimentexiao/kaimentexiao"), -1,CCString:create(""));
	effecSprite:setPosition(ccp(g_winSize.width*0.5, g_winSize.height*0.5))
	effecSprite:setScale(g_fBgScaleRatio)
	_mainLayer:addChild(effecSprite)

	function animation_end( ... )
		effecSprite:cleanup()
		lightEffect()
	end

	--增加动画监听
    local delegate = BTAnimationEventDelegate:create()
    delegate:registerLayerEndedHandler(animation_end)
    effecSprite:setDelegate(delegate)
end

-- 开门光特效
function lightEffect()
	_lightEffect = CCLayerSprite:layerSpriteWithName(CCString:create("images/base/effect/god_copy/guangxianxh/guangxianxh"), -1,CCString:create(""));
	_lightEffect:setPosition(ccp(g_winSize.width*0.5, g_winSize.height*0.5))
	_lightEffect:setScale(g_fBgScaleRatio)
	_mainLayer:addChild(_lightEffect)
	addRealToNextMenu()
end


-- 去向下一关的按钮
function addRealToNextMenu()
	setClick(false)
	_toNextMenu = CCMenu:create()
	_toNextMenu:setTouchPriority(_touch_priority-1)
	_toNextMenu:setAnchorPoint(ccp(0,0))
	_toNextMenu:setPosition(ccp(0,0))
	_mainLayer:addChild(_toNextMenu)

	local item_sprite_n = CCSprite:create()
	item_sprite_n:setContentSize(CCSizeMake(200, 200))
	local item_sprite_h = CCSprite:create()
	item_sprite_h:setContentSize(CCSizeMake(200, 200))
	--
	local nextItem = CCMenuItemSprite:create(item_sprite_n, item_sprite_h)
	_toNextMenu:addChild(nextItem)
	nextItem:setAnchorPoint(ccp(0.5,0.5))
	nextItem:registerScriptTapHandler(realNextAction)
	nextItem:setPosition(ccp(g_winSize.width*0.5, g_winSize.height*0.5))
	nextItem:setScale(g_fBgScaleRatio)

	local handActionSprite = GodCopyUtil.figleEffectAction()
	handActionSprite:setAnchorPoint(ccp(0.5, 1))
	handActionSprite:setPosition(ccp(100, 120))
	nextItem:addChild(handActionSprite)

end

-- 按钮回调
function realNextAction()
	_toNextMenu:setVisible(false)
	setClick(false)
	if(GodWeaponCopyData.isHavePass())then
		-- passAll()
		return
	end
	transToNextEffect()
end


--中间按钮点击回调
local function battleClickAction( tag, itemBtn )
	local curScene = CCDirector:sharedDirector():getRunningScene()
	local pLayer = curScene:getChildByTag(757)
	if(pLayer~=nil)then
		pLayer:removeFromParentAndCleanup(true)
		pLayer = nil
	end

	local _allPass = GodWeaponCopyData.isHavePass()
	-- body
	-- 背包满了
	if(ItemUtil.isBagFull() == true )then
		return
	end

	local isCanSweep = GodWeaponCopyData.isCanSweep()
	local passNum = GodWeaponCopyData.lastPassNum()
	if(passNum<=1 and _kTagBattle == tag and tonumber(_copyInfo.cur_base) == 1)then
		require "script/ui/godweapon/godweaponcopy/GodWeaponTipDialog"
		GodWeaponTipDialog.show(false)
		return
	end
	if(isCanSweep and _kTagBattle == tag)then
		require "script/ui/godweapon/godweaponcopy/GodWeaponTipDialog"
		GodWeaponTipDialog.show(true)
		return
	end

	--获取发奖时间做判断
	local isReward = GodWeaponCopyData.isRewardTime()


	if(isReward)then
		AnimationTip.showTip(GetLocalizeStringBy("llp_143"))
		return
	end

	if(_challengeTime==0)then
		AnimationTip.showTip(GetLocalizeStringBy("llp_161"))
		return
	end

	if( _kTagBattle == tag )then
		-- 武将为空或者 还有活着的武将 说明今天能够继续打
		if( not table.isEmpty(_copyInfo["va_pass"]["heroInfo"]))then
			local isAllDead = true
			for k,v in pairs(_copyInfo["va_pass"]["heroInfo"])do
				if(tonumber(v["currHp"])>0)then
					isAllDead = false
					break
				end
			end
			--自己人没都死就可以挑战
			if(isAllDead)then
				AnimationTip.showTip(GetLocalizeStringBy("llp_124"))
			else
				if(not _allPass)then
					ChooseChallengerLayer.showLayer()
				else

				end
			end
		else
			ChooseChallengerLayer.showLayer()
		end
	elseif( _kTagBox == tag )then
		--判断是进普通宝箱还是金币宝箱
		if(_copyInfo["va_pass"]["chestShow"]~=nil and not table.isEmpty(_copyInfo["va_pass"]["chestShow"]) and tonumber(_copyInfo["va_pass"]["chestShow"]["freeChest"])==0)then
			sendRewardCommond()
		elseif(tonumber(_copyInfo["va_pass"]["chestShow"]["goldChest"])==0)then
			GodWeaponChest.showLayer()
		end
	else
		if(not _allPass)then
			--显示buff界面
			BuyBuffLayer.showLayer(_copyInfo["va_pass"]["buffShow"])
		else

		end
	end

end

-- 打开普通宝箱
function openNormalBoxEffect( ... )
	local curScene = CCDirector:sharedDirector():getRunningScene()
	local pLayer = curScene:getChildByTag(757)
	if(pLayer~=nil)then
		pLayer:removeFromParentAndCleanup(true)
		pLayer = nil
	end
	addInterceptLayer()
	AudioUtil.playEffect("audio/effect/putongdakai.mp3")

	_middleItem:getChildByTag(10001):removeFromParentAndCleanup(true)
	_middleItem:getChildByTag(10002):removeFromParentAndCleanup(true)

	local effecSprite = CCLayerSprite:layerSpriteWithName(CCString:create("images/base/effect/god_copy/putongdakai/putongdakai"), 0.5,CCString:create(""));
	effecSprite:setPosition(120, 115)
	_middleItem:addChild(effecSprite)

	function animation_end( ... )
		effecSprite:stopAllActions()
		_middleItem:cleanup()
		ShowRewardLayer.showLayer( ShowRewardLayer.kTypeNormalBox)
		removeInterceptLayer()
	end

	--增加动画监听
    local delegate = BTAnimationEventDelegate:create()
    delegate:registerLayerEndedHandler(animation_end)
    effecSprite:setDelegate(delegate)
end

-- 普通宝箱特效进入
function addNormalBoxEffect( b_itemBtn )
	addInterceptLayer()
	local effecSprite = CCLayerSprite:layerSpriteWithName(CCString:create("images/base/effect/god_copy/putongxialuo/putongxialuo"), 1,CCString:create(""));
	effecSprite:setPosition(100, 100)
	b_itemBtn:addChild(effecSprite,1, 10001)

	AudioUtil.playEffect("audio/effect/hualidakai.mp3")

	function animation_end( ... )
		effecSprite:cleanup()

		local effecSprite_normal = CCLayerSprite:layerSpriteWithName(CCString:create("images/base/effect/god_copy/putongchangtai/putongchangtai"), -1,CCString:create(""));
		effecSprite_normal:setPosition(114, 90)
		b_itemBtn:addChild(effecSprite_normal, 2, 10002)
		removeInterceptLayer()
	end

	--增加动画监听
    local delegate = BTAnimationEventDelegate:create()
    delegate:registerLayerEndedHandler(animation_end)
    effecSprite:setDelegate(delegate)
end

-- buff特效进入
function addBuffEffect( b_itemBtn )
	-- body
	local effecSprite = CCLayerSprite:layerSpriteWithName(CCString:create("images/base/effect/god_copy/nengliangqiu/nengliangqiu"), 1,CCString:create(""));
	effecSprite:setPosition(100, 100)
	b_itemBtn:addChild(effecSprite)
end

-- 守关武将特效
function addGodHeroEffect( b_itemBtn )
	local effecSprite = CCLayerSprite:layerSpriteWithName(CCString:create("images/base/effect/god_copy/shenbing/shenbing"), 1,CCString:create(""));
	effecSprite:setPosition(100, 100)
	b_itemBtn:addChild(effecSprite)
end

-- 创建三种中间状态的按钮特效
function createMiddleItemBy(type_tag)
	-- 空白区域
	local item_sprite_n = CCSprite:create()
	item_sprite_n:setContentSize(CCSizeMake(200, 200))
	local item_sprite_h = CCSprite:create()
	item_sprite_h:setContentSize(CCSizeMake(200, 200))
	local b_itemBtn = CCMenuItemSprite:create(item_sprite_n, item_sprite_h)
	b_itemBtn:setAnchorPoint(ccp(0.5,0.5))
	b_itemBtn:setPosition(ccp(g_winSize.width*0.5, g_winSize.height*0.5))
	b_itemBtn:registerScriptTapHandler(battleClickAction)
	b_itemBtn:setScale(g_fElementScaleRatio)

	local effect_name = nil
	if(_kTagBox == type_tag)then
		--宝箱
		addNormalBoxEffect(b_itemBtn)
		b_itemBtn:setPosition(ccp(g_winSize.width*0.47, g_winSize.height*0.45))
	elseif(_kTagBuff == type_tag)then
		--buff
		addBuffEffect(b_itemBtn)
		b_itemBtn:setPosition(ccp(g_winSize.width*0.5, g_winSize.height*0.4))
	elseif(_kTagBattle == type_tag)then
		--据点
		addGodHeroEffect(b_itemBtn)
		b_itemBtn:setPosition(ccp(g_winSize.width*0.47, g_winSize.height*0.4))
	end

	return b_itemBtn
end
-----------------------------------------------中间动画相关END-----------------------------------

-----------------------------------------------命令相关BEGIN-----------------------------------
--发送enter命令
function sendCommond( ... )
	-- body
	GodWeaponCopyService.getCopyInfo(getCopyInfoFunc)
end

--发送获取奖励命令
function sendRewardCommond()
	--获取当前在第几关
	_copyInfo = GodWeaponCopyData.getCopyInfo()
	--获取奖励信息命令参数
	local args = CCArray:create()
	args:addObject(CCInteger:create(tonumber(_copyInfo.cur_base)))
	args:addObject(CCInteger:create(0))
	--调用获取奖励命令
	GodWeaponCopyService.rewardInfo(openNormalBoxEffect,args)
end

--获取copyInfo信息
function getCopyInfoFunc( ... )
	-- body
	_copyInfo = GodWeaponCopyData.getCopyInfo()

	--通关状态
	_allPass = GodWeaponCopyData.isHavePass()

	--创建背景
	createBg()
	--创建上边栏
	createTop()
	--创建中间布局
	createMiddle()
	--创建底部布局
	createBottom()

	-- 刷新
	refreshTop()
	refreshBottom()
end

--刷新
function refreshFunc( ... )
	-- body
	_mainLayer:setTouchEnabled(true)
	-- local middleItem = _mainLayer:getChildByTag(9020)
	-- if(middleItem~=nil)then
	-- 	middleItem:setTouchEnabled(true)
	-- end
	_copyInfo = GodWeaponCopyData.getCopyInfo()
	--通关状态
	_allPass = GodWeaponCopyData.isHavePass()
	-- body
	refreshTop()
	refreshBottom()
	refreshMiddle()
end
-----------------------------------------------命令相关END-----------------------------------

-----------------------------------------------上中下布局相关创建BEGIN-----------------------------------
function createBg()
	--背景图片
	local mainBg = CCSprite:create("images/godweaponcopy/copy_bg/" .. GodWeaponCopyData.getCopyBgName() )
	mainBg:setScale(g_fBgScaleRatio)
	mainBg:setAnchorPoint(ccp(0.5,0.5))
	mainBg:setPosition(g_winSize.width*0.5,g_winSize.height*0.5)
	_mainLayer:addChild(mainBg)
end

--创建上边栏
function createTop( ... )
	--上边总sprite 缩放用
	local topSpriteBg = CCSprite:create()
	topSpriteBg:setAnchorPoint(ccp(0, 1))
	topSpriteBg:setPosition(ccp(0, g_winSize.height))
	topSpriteBg:setContentSize(CCSizeMake(640, 130))
	topSpriteBg:setScale(g_fScaleX)

	_mainLayer:addChild(topSpriteBg)

	-- body
	--当前关卡名称底板
	local passNameBg = CCSprite:create("images/godweaponcopy/passnamebg.png")
	topSpriteBg:addChild(passNameBg,1,1000)
	passNameBg:setAnchorPoint(ccp(0.5,1))
	passNameBg:setPosition(ccp(topSpriteBg:getContentSize().width*0.5,topSpriteBg:getContentSize().height))
	--表数据
	local dbData = DB_Overcome.getDataById(tonumber(_copyInfo.cur_base))
	--关卡名称
	_passNameLabel = CCRenderLabel:create(dbData.name,g_sFontPangWa,25,1,ccc3( 0x00, 0x00, 0x00),type_stroke)
	_passNameLabel:setColor(ccc3(0xff,0xf6,0x00))
	passNameBg:addChild(_passNameLabel,1,1)
	_passNameLabel:setAnchorPoint(ccp(0.5,0))
	_passNameLabel:setPosition(ccp(passNameBg:getContentSize().width*0.5,passNameBg:getContentSize().height*5/12))
	--关卡层数
	_passNumLabel = CCRenderLabel:create(GetLocalizeStringBy("llp_119",_copyInfo.cur_base),g_sFontName,18,1,ccc3( 0x00, 0x00, 0x00),type_stroke)
	_passNumLabel:setColor(ccc3(0xff,0xff,0xff))
	passNameBg:addChild(_passNumLabel,1,2)
	_passNumLabel:setAnchorPoint(ccp(0.5,1))
	_passNumLabel:setPosition(ccp(passNameBg:getContentSize().width*0.5,passNameBg:getContentSize().height*4/12))

	--上边Menu
	local clickMenu = CCMenu:create()
	clickMenu:setTouchPriority(_touch_priority-1)
	clickMenu:setAnchorPoint(ccp(0,0))
	clickMenu:setPosition(ccp(0,0))
	topSpriteBg:addChild(clickMenu)

	--排行Item
	local rankItem = CCMenuItemImage:create("images/match/paihang_n.png", "images/match/paihang_h.png")
	clickMenu:addChild(rankItem,1,1)
	rankItem:setAnchorPoint(ccp(0,0.5))
	rankItem:registerScriptTapHandler(rankListAction)
	rankItem:setPosition(ccp(0,topSpriteBg:getContentSize().height*0.5))

	-- 返回Item
	local closeMenuItem = CCMenuItemImage:create("images/common/close_btn_n.png","images/common/close_btn_h.png")
	closeMenuItem:registerScriptTapHandler(backAction)
	clickMenu:addChild(closeMenuItem)
	closeMenuItem:setAnchorPoint(ccp(1,0.5))
	closeMenuItem:setPosition(ccp(passNameBg:getPositionX()*2-rankItem:getPositionX(),topSpriteBg:getContentSize().height*0.5))
end

function getStatusType( ... )
	-- body
	-- 宝箱按钮
	local goldPass = GodWeaponCopyData.isGodBoxPass()

	if(_copyInfo.cur_base==_copyInfo.pass_num and not GodWeaponCopyData.isHavePass())then
		if(table.isEmpty(_copyInfo["va_pass"]))then
			Logger.trace("出问题了去找服务器")
		else
			if(not table.isEmpty(_copyInfo["va_pass"]["chestShow"])
				and tonumber(_copyInfo["va_pass"]["chestShow"]["freeChest"])==0
				or tonumber(_copyInfo["va_pass"]["chestShow"]["goldChest"])==0)then

				if(_copyInfo["va_pass"]~=nil
					and not table.isEmpty(_copyInfo["va_pass"]["chestShow"])
					and tonumber(_copyInfo["va_pass"]["chestShow"]["freeChest"])==1)then

					if(tonumber(_copyInfo["va_pass"]["chestShow"]["goldChest"])==0)then
						_status = 3
					end
				end
				--宝箱
				_status = 2
			elseif(not table.isEmpty(_copyInfo["va_pass"]["buffShow"]))then

				if(GodWeaponCopyData.isBuffPass()==false)then
					--buff
					_status = 4
				end
			end
		end
	else
		if(GodWeaponCopyData.isHavePass())then
			if(goldPass==true)then
				_status = 5
			else
				_status = 2
			end
		else
			--据点
			_status = 1
		end
	end

end

--创建中间布局
function createMiddle( ... )
	local battleMenu = CCMenu:create()
	battleMenu:setTouchPriority(_touch_priority-1)
	_mainLayer:addChild(battleMenu)
	battleMenu:setTag(9020)
	battleMenu:setAnchorPoint(ccp(0,0))
	battleMenu:setPosition(ccp(0,0))

	getStatusType()

	if(_status==1)then
		_middleItem = createMiddleItemBy(_kTagBattle)
		battleMenu:addChild(_middleItem, 1, _kTagBattle)
		local dbData = DB_Overcome.getDataById(tonumber(_copyInfo.cur_base))
		GodCopyUtil.showGodCopySprite(dbData.name)
	elseif(_status==2)then
		_middleItem = createMiddleItemBy(_kTagBox)
		battleMenu:addChild(_middleItem, 1, _kTagBox)
	elseif(_status==3)then
		GodWeaponChest.showLayer()
		_middleItem = nil
		return
	elseif(_status==4)then
		_middleItem 	= createMiddleItemBy(_kTagBuff)
		battleMenu:addChild(_middleItem, 1, _kTagBuff)
	elseif(_status==5)then
		_middleItem = nil
		return
	end

end

--创建底边栏
function createBottom( ... )
	--下边状态栏

	local fullRect = CCRectMake(0,0,640,51)
	local insetRect = CCRectMake(314,27,13,6)
	bottomBgSprite = CCScale9Sprite:create("images/god_weapon/view_bg.png",fullRect, insetRect)
	bottomBgSprite:setPreferredSize(CCSizeMake(640,100))
	bottomBgSprite:setScale(g_fScaleX)
	_mainLayer:addChild(bottomBgSprite)

	local passNameBg = CCSprite:create("images/godweaponcopy/passnamebg.png")
	--闯关积分label
	local challengeLabel = CCRenderLabel:create(GetLocalizeStringBy("llp_160"),g_sFontPangWa,25,1,ccc3( 0x00, 0x00, 0x00),type_stroke)
	challengeLabel:setColor(ccc3(0xff,0xff,0xff))
	challengeLabel:setAnchorPoint(ccp(0,0.5))
	--闯关积分数值
	local normalData = DB_Normal_config.getDataById(1)
	print("_copyInfo.buy_num".._copyInfo.buy_num)
	_challengeTime = tonumber(normalData.challengingTimes)-tonumber(_copyInfo.lose_num)+tonumber(_copyInfo.buy_num)
	_challengeTimeLabel = CCRenderLabel:create(_challengeTime,g_sFontPangWa,25,1,ccc3( 0x00, 0x00, 0x00),type_stroke)
	_challengeTimeLabel:setColor(ccc3(0x00,0xff,0x18))
	_challengeTimeLabel:setAnchorPoint(ccp(0,0.5))
	--购买挑战次数按钮
	addTimeMenu = CCMenu:create()
	addTimeMenu:setAnchorPoint(ccp(0,0))
	addTimeMenu:setPosition(ccp(0,0))
	addTimeMenu:setTouchPriority(_touch_priority-1)
	local addItem = CCMenuItemImage:create("images/common/btn/btn_plus_h.png", "images/common/btn/btn_plus_n.png")
	addItem:registerScriptTapHandler(buyTime)
	addItem:setAnchorPoint(ccp(0,0.5))
	addTimeMenu:addChild(addItem)
	--闯关积分底板
	local fullRect = CCRectMake(0,0,112,29)
	local insetRect = CCRectMake(50,10,10,8)
	local grayBg = CCScale9Sprite:create("images/godweaponcopy/gray_bg.png",fullRect, insetRect)
	if(_challengeTime == 0)then
		grayBg:setPreferredSize(CCSizeMake(challengeLabel:getContentSize().width+_challengeTimeLabel:getContentSize().width+addItem:getContentSize().width,addItem:getContentSize().height))
	else
		addTimeMenu:setVisible(false)
		grayBg:setPreferredSize(CCSizeMake(challengeLabel:getContentSize().width+_challengeTimeLabel:getContentSize().width,addItem:getContentSize().height))
	end
	grayBg:setAnchorPoint(ccp(0,0))
	grayBg:setPosition(ccp(0,bottomBgSprite:getContentSize().height))
	grayBg:addChild(challengeLabel)
	grayBg:addChild(_challengeTimeLabel,1)
	grayBg:addChild(addTimeMenu)
	bottomBgSprite:addChild(grayBg,1,119)

	challengeLabel:setPosition(ccp(0,grayBg:getContentSize().height*0.5))
	_challengeTimeLabel:setPosition(ccp(challengeLabel:getContentSize().width,grayBg:getContentSize().height*0.5))
	addItem:setPosition(ccp(challengeLabel:getContentSize().width+_challengeTimeLabel:getContentSize().width,grayBg:getContentSize().height*0.5))

	local passLabel = CCRenderLabel:create(GetLocalizeStringBy("llp_120"),g_sFontPangWa,25,1,ccc3( 0x00, 0x00, 0x00),type_stroke)
	passLabel:setColor(ccc3(0xff,0xff,0xff))
	passLabel:setAnchorPoint(ccp(0,0.5))
	--闯关积分数值
	_passPointLabel = CCRenderLabel:create(_copyInfo.point,g_sFontPangWa,25,1,ccc3( 0x00, 0x00, 0x00),type_stroke)
	_passPointLabel:setColor(ccc3(0x00,0xff,0x18))
	_passPointLabel:setAnchorPoint(ccp(0,0.5))
	--闯关积分底板
	local fullRect = CCRectMake(0,0,112,29)
	local insetRect = CCRectMake(50,10,10,8)
	local grayBg = CCScale9Sprite:create("images/godweaponcopy/gray_bg.png",fullRect, insetRect)
	grayBg:setPreferredSize(CCSizeMake(passLabel:getContentSize().width+_passPointLabel:getContentSize().width,passLabel:getContentSize().height))
	grayBg:setAnchorPoint(ccp(0,0))
	grayBg:setPosition(ccp(0,bottomBgSprite:getContentSize().height+addItem:getContentSize().height))

	bottomBgSprite:addChild(grayBg,1)--_grayBgTag1001
	grayBg:addChild(passLabel)
	grayBg:addChild(_passPointLabel,1,1)
	passLabel:setPosition(ccp(0,grayBg:getContentSize().height*0.5))
	_passPointLabel:setPosition(ccp(passLabel:getContentSize().width,grayBg:getContentSize().height*0.5))

	--下边Menu
	local clickMenu = CCMenu:create()
	clickMenu:setTouchPriority(_touch_priority-1)
	clickMenu:setAnchorPoint(ccp(0,0))
	clickMenu:setPosition(ccp(0,0))
	bottomBgSprite:addChild(clickMenu)

	--神兵商店Item
	local weaponShopItem = CCMenuItemImage:create("images/godweaponcopy/godweaponshop_n.png", "images/godweaponcopy/godweaponshop_h.png")
	clickMenu:addChild(weaponShopItem,1,2)
	weaponShopItem:setAnchorPoint(ccp(1,0))
	weaponShopItem:setPosition(ccp(bottomBgSprite:getContentSize().width,bottomBgSprite:getContentSize().height+5))
	weaponShopItem:registerScriptTapHandler(shopAction)

	--布阵Item
	local arrayMenuItem = nil
	if(DataCache.getSwitchNodeState(ksSwitchWarcraft, false) == true )then
		arrayMenuItem = CCMenuItemImage:create("images/copy/array_n.png","images/copy/array_h.png")
		arrayMenuItem:registerScriptTapHandler(arrayAction)
		clickMenu:addChild(arrayMenuItem)
	else
		arrayMenuItem = CCMenuItemImage:create("images/copy/arraybu_n.png","images/copy/arraybu_h.png")
		arrayMenuItem:registerScriptTapHandler(arrayAction)
		clickMenu:addChild(arrayMenuItem)
	end
	arrayMenuItem:setAnchorPoint(ccp(1,0))
	arrayMenuItem:setPosition(ccp(bottomBgSprite:getContentSize().width-arrayMenuItem:getContentSize().width-weaponShopItem:getContentSize().width-5,bottomBgSprite:getContentSize().height+5))
	--判断是否显示布阵
	local real_formation = GodWeaponCopyData.getFormationInfo()
	if(table.isEmpty(real_formation))then
		arrayMenuItem:setVisible(false)
	else
		arrayMenuItem:setVisible(true)
	end
	--替补武将Item
	local replaceItem = CCMenuItemImage:create("images/godweaponcopy/replace_n.png", "images/godweaponcopy/replace_h.png")
	clickMenu:addChild(replaceItem,1,3)
	replaceItem:setAnchorPoint(ccp(1,0))
	replaceItem:setPosition(ccp(bottomBgSprite:getContentSize().width-arrayMenuItem:getContentSize().width-5,bottomBgSprite:getContentSize().height+5))
	replaceItem:registerScriptTapHandler(replaceAction)

	--闯关属性加成黄字
	local passAddSprite = CCSprite:create("images/godweaponcopy/passbuffadd.png")
	bottomBgSprite:addChild(passAddSprite)
	passAddSprite:setAnchorPoint(ccp(0.5,0.5))
	passAddSprite:setPosition(ccp(bottomBgSprite:getContentSize().width*0.5,bottomBgSprite:getContentSize().height*0.90))

	--星星Sprite
	local starSprite = CCSprite:create("images/common/star_big.png")
	bottomBgSprite:addChild(starSprite,1,1)
	starSprite:setAnchorPoint(ccp(0,0.5))
	--星数Label
	_starLabel = CCRenderLabel:create("X0",g_sFontPangWa,21,1,ccc3( 0x00, 0x00, 0x00),type_stroke)
	starSprite:addChild(_starLabel,1,1)
	_starLabel:setAnchorPoint(ccp(0,0.5))
	_starLabel:setPosition(ccp(starSprite:getContentSize().width+10,starSprite:getContentSize().height*0.5))
	starSprite:setContentSize(CCSizeMake(starSprite:getContentSize().width+10+_starLabel:getContentSize().width,starSprite:getContentSize().height))
	starSprite:setPosition(ccp(0,bottomBgSprite:getContentSize().height*0.5))

	--攻击Sprite
	local attackSprite = CCSprite:create("images/warcraft/atk_title.png")
	bottomBgSprite:addChild(attackSprite,1,2)
	attackSprite:setAnchorPoint(ccp(0.5,0.5))
	--攻击Label
	_attackLabel = CCRenderLabel:create("+0%",g_sFontPangWa,21,1,ccc3( 0x00, 0x00, 0x00),type_stroke)
	attackSprite:addChild(_attackLabel,1,2)
	_attackLabel:setAnchorPoint(ccp(0,0.5))
	_attackLabel:setPosition(ccp(attackSprite:getContentSize().width+10,attackSprite:getContentSize().height*0.5))

	attackSprite:setContentSize(CCSizeMake(attackSprite:getContentSize().width+10+_attackLabel:getContentSize().width,attackSprite:getContentSize().height))
	attackSprite:setPosition(ccp(bottomBgSprite:getContentSize().width*0.3,bottomBgSprite:getContentSize().height*0.5))
	--生命Sprite
	local lifeSprite = CCSprite:create("images/warcraft/hp_title.png")
	bottomBgSprite:addChild(lifeSprite,1,3)
	lifeSprite:setAnchorPoint(ccp(0.5,0.5))
	--生命Label
	_lifeLabel = CCRenderLabel:create("+0%",g_sFontPangWa,21,1,ccc3( 0x00, 0x00, 0x00),type_stroke)
	lifeSprite:addChild(_lifeLabel,1,3)
	_lifeLabel:setAnchorPoint(ccp(0,0.5))
	_lifeLabel:setPosition(ccp(lifeSprite:getContentSize().width+10,lifeSprite:getContentSize().height*0.5))

	lifeSprite:setContentSize(CCSizeMake(lifeSprite:getContentSize().width+10+_lifeLabel:getContentSize().width,lifeSprite:getContentSize().height))
	lifeSprite:setPosition(ccp(bottomBgSprite:getContentSize().width*0.6,bottomBgSprite:getContentSize().height*0.5))
	--防御Sprite
	local defeatSprite = CCSprite:create("images/warcraft/def_title.png")
	bottomBgSprite:addChild(defeatSprite,1,4)
	defeatSprite:setAnchorPoint(ccp(1,0.5))
	--防御Label
	_defeatLabel = CCRenderLabel:create(GetLocalizeStringBy("llp_111",0).."%",g_sFontPangWa,21,1,ccc3( 0x00, 0x00, 0x00),type_stroke)
	defeatSprite:addChild(_defeatLabel,1,4)
	_defeatLabel:setAnchorPoint(ccp(0,0.5))
	_defeatLabel:setPosition(ccp(defeatSprite:getContentSize().width+10,defeatSprite:getContentSize().height*0.5))

	defeatSprite:setContentSize(CCSizeMake(defeatSprite:getContentSize().width+10+_defeatLabel:getContentSize().width,defeatSprite:getContentSize().height))
	defeatSprite:setPosition(ccp(bottomBgSprite:getContentSize().width-10,bottomBgSprite:getContentSize().height*0.5))
end
-----------------------------------------------上中下布局相关创建END-----------------------------------

-----------------------------------------------上中下布局刷新创建BEGIN-----------------------------------
--刷新上方
function refreshTop()
	--获取据点数据并刷新：关卡名／层数／积分
	local dbData = DB_Overcome.getDataById(tonumber(_copyInfo.cur_base))
	_passNameLabel:setString(dbData.name)
	_passNumLabel:setString(GetLocalizeStringBy("llp_119",_copyInfo.cur_base))
	_passPointLabel:setString(_copyInfo.point)
end

--刷新中间
function refreshMiddle( ... )
	_mainLayer:getChildByTag(9020):setVisible(false)
	_mainLayer:removeChildByTag(9020,true)
	local battleMenu = CCMenu:create()
	battleMenu:setTouchPriority(_touch_priority-1)
	_mainLayer:addChild(battleMenu)
	battleMenu:setTag(9020)
	battleMenu:setAnchorPoint(ccp(0,0))
	battleMenu:setPosition(ccp(0,0))

	getStatusType()

	if(_status==1)then
		_middleItem = createMiddleItemBy(_kTagBattle)
		battleMenu:addChild(_middleItem, 1, _kTagBattle)
		local dbData = DB_Overcome.getDataById(tonumber(_copyInfo.cur_base))
		GodCopyUtil.showGodCopySprite(dbData.name)
	elseif(_status==2)then
		_middleItem = createMiddleItemBy(_kTagBox)
		battleMenu:addChild(_middleItem, 1, _kTagBox)
	elseif(_status==3)then
		GodWeaponChest.showLayer()
		_middleItem = nil
		return
	elseif(_status==4)then
		_middleItem 	= createMiddleItemBy(_kTagBuff)
		battleMenu:addChild(_middleItem, 1, _kTagBuff)
	elseif(_status==5)then
		_middleItem = nil
		return
	end
end

-- 中间按钮是否隐藏
function setMiddleItemVisible( isVisible )
	if( tolua.cast(_middleItem, "CCMenuItemSprite") ) then
		_middleItem:setVisible(isVisible)
	end
end

--刷新底边
function refreshBottom( ... )
	_copyInfo = GodWeaponCopyData.getCopyInfo()
	_buyNum = GodWeaponCopyData.getBuyTimes()
	local buffInfo = GodWeaponCopyData.getCopyBuff()
		-- 刷新星数
		_starLabel:setString("X" .. GodWeaponCopyData.getStarNumber())
	if(not table.isEmpty(buffInfo))then
		-- 刷新攻击
		local attack_num = (buffInfo["19"] or 0) / 100
		_attackLabel:setString("+".. attack_num .. "%")

		-- 刷新生命
		local life_num = (buffInfo["11"] or 0)/100
		_lifeLabel:setString("+".. life_num .. "%")

		-- 刷新防御
		local defend_num = (tonumber(buffInfo["14"] or 0 )) / 100
		_defeatLabel:setString("+".. defend_num .. "%")
	end
	-- 刷新挑战次数
		bottomBgSprite:getChildByTag(119):setVisible(false)
		bottomBgSprite:removeChildByTag(119,true)
		-- local normalData = DB_Normal_config.getDataById(1)
		-- local lose_num = GodWeaponCopyData.getLoseTimes()

		-- _challengeTime = tonumber(normalData.challengingTimes)-tonumber(_copyInfo.lose_num)
		-- print("_challengeTime".._challengeTime)
		-- _challengeTimeLabel:setString(tostring(_challengeTime))

		--闯关积分label
		local challengeLabel = CCRenderLabel:create(GetLocalizeStringBy("llp_160"),g_sFontPangWa,25,1,ccc3( 0x00, 0x00, 0x00),type_stroke)
		challengeLabel:setColor(ccc3(0xff,0xff,0xff))
		challengeLabel:setAnchorPoint(ccp(0,0.5))
		--闯关积分数值
		local normalData = DB_Normal_config.getDataById(1)
		print("normalData.challengingTimes=="..normalData.challengingTimes.."_copyInfo.lose_num==".._copyInfo.lose_num.."_buyNum".._buyNum)
		_challengeTime = tonumber(normalData.challengingTimes)-tonumber(_copyInfo.lose_num)+tonumber(_buyNum)
		_challengeTimeLabel = CCRenderLabel:create(_challengeTime,g_sFontPangWa,25,1,ccc3( 0x00, 0x00, 0x00),type_stroke)
		_challengeTimeLabel:setColor(ccc3(0x00,0xff,0x18))
		_challengeTimeLabel:setAnchorPoint(ccp(0,0.5))
		--购买挑战次数按钮
		addTimeMenu = CCMenu:create()
		addTimeMenu:setAnchorPoint(ccp(0,0))
		addTimeMenu:setPosition(ccp(0,0))
		addTimeMenu:setTouchPriority(_touch_priority-1)
		local addItem = CCMenuItemImage:create("images/common/btn/btn_plus_h.png", "images/common/btn/btn_plus_n.png")
		addItem:registerScriptTapHandler(buyTime)
		addItem:setAnchorPoint(ccp(0,0.5))
		addTimeMenu:addChild(addItem)
		--闯关积分底板
		local fullRect = CCRectMake(0,0,112,29)
		local insetRect = CCRectMake(50,10,10,8)
		local grayBg = CCScale9Sprite:create("images/godweaponcopy/gray_bg.png",fullRect, insetRect)
		if(_challengeTime == 0)then
			grayBg:setPreferredSize(CCSizeMake(challengeLabel:getContentSize().width+_challengeTimeLabel:getContentSize().width+addItem:getContentSize().width,addItem:getContentSize().height))
		else
			addTimeMenu:setVisible(false)
			grayBg:setPreferredSize(CCSizeMake(challengeLabel:getContentSize().width+_challengeTimeLabel:getContentSize().width,addItem:getContentSize().height))
		end
		grayBg:setAnchorPoint(ccp(0,0))
		grayBg:setPosition(ccp(0,bottomBgSprite:getContentSize().height))
		grayBg:addChild(challengeLabel)
		grayBg:addChild(_challengeTimeLabel,1)
		grayBg:addChild(addTimeMenu)
		bottomBgSprite:addChild(grayBg,1,119)

		challengeLabel:setPosition(ccp(0,grayBg:getContentSize().height*0.5))
		_challengeTimeLabel:setPosition(ccp(challengeLabel:getContentSize().width,grayBg:getContentSize().height*0.5))
		addItem:setPosition(ccp(challengeLabel:getContentSize().width+_challengeTimeLabel:getContentSize().width,grayBg:getContentSize().height*0.5))
end

-----------------------------------------------上中下布局刷新创建END-----------------------------------

--创建神兵据点
function createLayer( ... )
	init()

	--创建layer
	_mainLayer = CCLayer:create()
	_mainLayer:registerScriptHandler(onNodeEvent)

	--发送获取神兵副本信息命令
	sendCommond()
	return _mainLayer
end

-- 显示神兵据点
function showLayer( ... )
	-- body
	local layer = createLayer()
	-- local runningScene = CCDirector:sharedDirector():getRunningScene()
	-- -- runningScene:addChild(_mainLayer, kDarkLayerZOrder)
	MainScene.changeLayer(layer,"GodWeaponCopyMainLayer")

end

-----------------------------------------------各种回调BEGIN-----------------------------------
--购买完成后
function afterBuyTime( ... )
	-- body
	-- _buyNum = GodWeaponCopyData.getBuyTimes()

	local vipLevel = UserModel.getVipLevel()
	local vipData = DB_Vip.getDataById(vipLevel+1)
	local res_attr_arry = string.split(vipData.challengeCost, ",")
	local cost = 0
	for i=tonumber(_copyInfo.buy_num)+1,tonumber(_copyInfo.buy_num)+_buyNum do
		cost = cost+tonumber(res_attr_arry[i])
	end
	GodWeaponCopyData.addBuyTimes(_buyNum)
	refreshBottom()
	UserModel.addGoldNumber(-cost)
end

--购买次数
function buyTime( tag,itembtn )
	-- body
	if(_canClick==true)then
		local vipLevel = UserModel.getVipLevel()
		local vipData = DB_Vip.getDataById(vipLevel+1)

		if(vipData~=nil and vipData.challengeCost~=nil)then
			-- GodWeaponCopyService.buyTimeCommond(afterBuyTime)
			local sureCallBack = function(p_num)
				_buyNum = p_num
				local args = CCArray:create()
				args:addObject(CCInteger:create(tonumber(p_num)))
				GodWeaponCopyService.buyTimeCommond(afterBuyTime,args)
				GodWeaponCopyData.setBuyTimes(p_num)
			end
			local res_attr_arry = string.split(vipData.challengeCost, ",")
			local paramTable = {}
			paramTable.title = GetLocalizeStringBy("llp_164")
			paramTable.first = GetLocalizeStringBy("llp_163")

			paramTable.max = table.count(res_attr_arry)-tonumber(_copyInfo.buy_num)
			-- print("challengeCost=="..table.count(vipData.challengeCost))
			-- print("vip_level",vipLevel)
			-- print("_copyInfo.buy_num".._copyInfo.buy_num)

			if(paramTable.max==0)then
				AnimationTip.showTip(GetLocalizeStringBy("llp_161"))
			else
				BuyTimeLayer.showBuyTimeLayer(paramTable,sureCallBack,nil,999,res_attr_arry)
			end

		else
			AnimationTip.showTip(GetLocalizeStringBy("llp_162"))
		end
	end
end
-- 返回
function backAction(tag, itembtn)
	-- Logger.debug("npc is a gost")
	if(_canClick==true)then
		local curScene = CCDirector:sharedDirector():getRunningScene()
		local pLayer = curScene:getChildByTag(757)
		if(pLayer~=nil)then
			pLayer:removeFromParentAndCleanup(true)
			pLayer = nil
		end
		require "script/audio/AudioUtil"
		AudioUtil.playEffect("audio/effect/guanbi.mp3")

		_mainLayer:setVisible(false)
		_mainLayer:removeFromParentAndCleanup(true)
		require "script/ui/active/ActiveList"
		local activeListr = ActiveList.createActiveListLayer()
		MainScene.changeLayer(activeListr, "activeListr")
	end
end
--排行按钮回调
function rankListAction( )
	if(_canClick==true)then
		local curScene = CCDirector:sharedDirector():getRunningScene()
		local pLayer = curScene:getChildByTag(757)
		if(pLayer~=nil)then
			pLayer:removeFromParentAndCleanup(true)
			pLayer = nil
		end
		GodWeaponRankLayer.showLayer()
	end
end
--神兵商店按钮回调
function shopAction()
	if(_canClick==true)then
		local curScene = CCDirector:sharedDirector():getRunningScene()
		local pLayer = curScene:getChildByTag(757)
		if(pLayer~=nil)then
			pLayer:removeFromParentAndCleanup(true)
			pLayer = nil
		end
		local shopLayer= GodShopLayer.showLayer(-599,1009,nil)
		-- local shopLayer= GodShopLayer.showLayer()
	end
    -- MainScene.changeLayer(shopLayer, "godWeaponShopLayer")
end

-- 布阵的回调函数
function arrayAction( ... )
	if(_canClick==true)then
		local curScene = CCDirector:sharedDirector():getRunningScene()
		local pLayer = curScene:getChildByTag(757)
		if(pLayer~=nil)then
			pLayer:removeFromParentAndCleanup(true)
			pLayer = nil
		end
		local real_formation = GodWeaponCopyData.getFormationInfo()
		if(table.isEmpty(real_formation))then
			return
		else
			if(DataCache.getSwitchNodeState(ksSwitchWarcraft, false) == true)then
				require "script/ui/warcraft/WarcraftLayer"
				WarcraftLayer.show(-1550,nil,WarcraftLayer.SHOW_TAG_GOD_WEAPON)
			else
				MakeUpFormationLayer.showLayer(-1550,100,GodWeaponCopyService.changePosCommond)
			end
		end
	end
end

function setClick( p_Click )
	-- body
	_canClick = p_Click
end

--替换回调
function replaceAction( ... )
	-- body
	if(_canClick==true)then
		local curScene = CCDirector:sharedDirector():getRunningScene()
		local pLayer = curScene:getChildByTag(757)
		if(pLayer~=nil)then
			pLayer:removeFromParentAndCleanup(true)
			pLayer = nil
		end
		_mainLayer:getChildByTag(9020):setVisible(false)
		AddHeroLayer.showLayer(false)
		_mainLayer:setTouchEnabled(false)
		_canClick = false
	end
	--MakeUpLayer.showLayer(-2500,100,1)
end
-----------------------------------------------各种回调END-----------------------------------































