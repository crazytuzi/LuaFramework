-- Filename: HeroStrengthenLayer.lua
-- Author: fang
-- Date: 2013-07-27
-- Purpose: 该文件用于: 武将强化系统

module("HeroStrengthenLayer", package.seeall)
require "script/ui/godweapon/godweaponcopy/GodWeaponCopyData"
require "script/ui/formation/secondfriend/SecondFriendData"
m_sign="HeroStrengthenLayer"

-- 当前正在运行的层
local _onRunningLayer
-- 卡牌强化层
local _ccLayerCardStrengthen
-- 将魂强化层
local _ccLayerSoulStrengthen

-- 英雄属性面板值保存
local _heroAttrPanel
-- 标题栏面板
local _titlePanel
----------------------------卡牌强化tag----------------------
-- GetLocalizeStringBy("key_1756")按钮tag
local _ksTagTabCardStrengthen=2001
-- GetLocalizeStringBy("key_3290")按钮tag
local _ksTagButtonReturnOnCard=2002
-- GetLocalizeStringBy("key_1269")按钮tag
local _ksTagButtonCardStrengthen=2003
-- “自动添加”按钮tag
local _ksTagButtonAutoAddOnCard=2004
-- 级别按钮tag
local _ksTagStarOnCard=2005
-- 强化所使用武将item
local _ksTagHeroItemOnCard=2100

-- GetLocalizeStringBy("key_1206")按钮tag
local _ksTagTabSoulStrengthen=3001
-- 武魂强化面板中的强化按钮tag
local _ksTagStrengthenOnSoul=3004
-- 武将选择起始tag
local _ksTagSelectedHeroStart=4001

----------------------------将魂强化tag----------------------
-- 将魂强化“返回”按钮tag
local _ksTagButtonReturnOnSoul=5001
-- 将魂强化“强化5次”按钮tag
local _ksTagButtonSoulStrengthen5=5002
-- 将魂强化“强化”按钮tag
local _ksTagButtonSoulStrengthen=5003


-- 卡牌强化按钮
local _ccButtonCardStrengthen
-- 武魂强化按钮
local _ccButtonSoulStrengthen
-- 从武将列表传递过来的英雄属性
local _tHeroAttr

-- 从选择武将界面返回的被选择的武将数组
local _arrSelectedHeroes

--播放特效是临时存储的
local _arrEffectHeroes

-- 标准内容高度为700
local _nStandardHeight = 700
-- 实际内容高度(默认为700，实际会变化)
local _nRealHeight=700

-- 除去按X轴方向的元素比率因子
local _fElementScale

-- 卡牌强化时需要的动态label
-- 获得经验值label
local _ccLabelExpNumCard
-- 消耗银币值label
local _ccLabelSilverNumCard

-- 玩家昵称显示标签
local _cltNickname
-- 玩家银币显示标签
local _cltSilverNum
-- 玩家金币显示标签
local _cltGoldNum

-- 选择武将面板的CCSprite对象
local _ccSpriteSelectedHeroes=nil
-- 选择武面板的层，
local _clItemOfNeeded=nil

-- 来自父级界面的参数结构
local _tParentParam

-- 将魂强化时需要的动态label

-- 武将强化所需要的银币总值
local _nTotalSilverCost=0
-- 武将当前等级计数器
local _nCounterOfHeroLevel=0
-- 武将基础属性值对象数组
local _arrBaseValueObjs={}
-- 武将升N级后属性值对象数组
local _arrLevelUpValueObjs={}

local _arrCurrentLevelValueObjs={}

-- 武将强化后的级别
local _nHeroLevelAfterUp=1
-- 武魂强化后的级别
local _nNextLevelNeedSoul=1

-- 将魂强化信息交换区
local _ccSpriteExchangeInfo

-- 天赋解锁技能数组
local _arrTalentUnlockObjs 

-- 记录当前索引子项，1：卡牌强化; 2：将魂强化
local _nIndexOfTab
local _nIndexOfCardStrengthen=101
local _nIndexOfSoulStrengthen=102

-- 增加武将按钮数组（为新手引导提供）
local _csAddHeroeButtons={}

-- 卡牌强化面板菜单
local _cmCardStrengthenPanel
-- 将魂强化面板菜单
local _cmSoulStrengthenPanel

-- 武将属性面板的高度
local _nHeightOfHeroAttr=390
-- 武将属性面板的Y坐标
local _nYPosOfHeroAttr


-- 武将升级显示进度条背景
local _cs9ProgressBg
-- 进度绿条（增加将魂后进度显示）
local _cs9ProgressGreenBar
-- 进度蓝条（实际进度条）
local _cs9ProgressBar
-- 卡牌展示背景
local _csCardShowBg

local _addedLv = 0
local _closeCallback = nil


local function init( ... )
	_cs9ProgressBg=nil
	_cs9ProgressGreenBar=nil
	_cs9ProgressBar=nil
	_arrSelectedHeroes={}
	_arrLevelUpValueObjs={}
	_addedLv = 0
end

-- 更新GetLocalizeStringBy("key_1734")字符串
function fnRenewLevelString(obj)
	local sLevel = _tHeroAttr.level
	obj:setColor(ccc3(0x78, 0x25, 0))
	if _nCounterOfHeroLevel % 2 == 0 then
		sLevel = _nHeroLevelAfterUp
		obj:setColor(ccc3(0, 0x6d, 0x2f))
	end
	_crlHeroLevel:setString(tostring(sLevel))
	_nCounterOfHeroLevel = _nCounterOfHeroLevel + 1
end
-- ”等级“动画
function actionOfLevel()
	local arrActions = CCArray:create()
	local fadeIn = CCFadeIn:create(1.0)
	local fadeOut = CCFadeOut:create(1.0)
	local myFunc01 = CCCallFuncN:create(fnRenewLevelString)
	local fadeIn02 = CCFadeIn:create(1.0)
	local fadeOut02 = CCFadeOut:create(1.0)
	local myFunc02 = CCCallFuncN:create(fnRenewLevelString)
	arrActions:addObject(fadeIn)
	arrActions:addObject(fadeOut)
	arrActions:addObject(myFunc01)
	arrActions:addObject(fadeIn02)
	arrActions:addObject(fadeOut02)
	arrActions:addObject(myFunc02)
	local sequence = CCSequence:create(arrActions)
	local action = CCRepeatForever:create(sequence)

	return action
end
-- 附加属性值动画
function actionOfAppendValue( ... )
	local arrActions = CCArray:create()
	local fadeIn = CCFadeIn:create(1.0)
	local fadeOut = CCFadeOut:create(1.0)
	arrActions:addObject(fadeIn)
	arrActions:addObject(fadeOut)
	local sequence = CCSequence:create(arrActions)
	local action = CCRepeatForever:create(sequence)

	return action
end

-- 显示所有附加属性淡进淡出动画
function fnShowActionOfAppendValues( ... )
	for i=1, #_arrLevelUpValueObjs do
		local action = actionOfAppendValue()
		_arrLevelUpValueObjs[i]:runAction(action)
	end
	-- for i=1, #_arrTalentUnlockObjs do
	-- 	local action = actionOfAppendValue()
	-- 	_arrTalentUnlockObjs[i]:runAction(action)
	-- end
end
-- 停止所有附加属性淡进淡出动画
function fnStopActionOfAppendValues( ... )
	for i=1, #_arrLevelUpValueObjs do
		_arrLevelUpValueObjs[i]:stopAllActions()
		_arrLevelUpValueObjs[i]:setString(" ")
	end
	-- for i=1, #_arrTalentUnlockObjs do
	-- 	_arrTalentUnlockObjs[i]:stopAllActions()
	-- 	_arrTalentUnlockObjs[i]:setString(" ")
	-- end
end

-- 英雄属性显示，角色名字，VIP级别，银币，金币
local function fnCreateHeroAttrPanel( ... )
	local bg = CCSprite:create("images/hero/avatar_attr_bg.png")
	require "script/model/user/UserModel"
	local userInfo = UserModel.getUserInfo()
	
	_cltNickname = CCLabelTTF:create(userInfo.uname, g_sFontName, 22)
	_cltNickname:setPosition(50, 8)
	_cltNickname:setColor(ccc3(0x6c, 0xff, 0))
	bg:addChild(_cltNickname)

	-- VIP图标
    local vip_lv = CCSprite:create ("images/common/vip.png")
	vip_lv:setPosition(250, 10)
	bg:addChild(vip_lv)
    -- VIP对应级别
    require "script/libs/LuaCC"
    local vip_lv_num = LuaCC.createSpriteOfNumbers("images/main/vip", userInfo.vip, 15)
    if (vip_lv_num ~= nil) then
        vip_lv_num:setPosition(vip_lv:getContentSize().width, 10)
        vip_lv:addChild(vip_lv_num)
    end

    -- 银币实际数据
	_cltSilverNum = CCLabelTTF:create(string.convertSilverUtilByInternational(userInfo.silver_num),g_sFontName,18)  -- modified by yangrui at 2015-12-03
	_cltSilverNum:setColor(ccc3(0xe5, 0xf9, 0xff))
	_cltSilverNum:setPosition(380, 10)
	bg:addChild(_cltSilverNum)

	-- 金币实际数据
    _cltGoldNum = CCLabelTTF:create(userInfo.gold_num, g_sFontName, 18)
	_cltGoldNum:setColor(ccc3(0xff, 0xe2, 0x44))
	_cltGoldNum:setPosition(520, 10)
	bg:addChild(_cltGoldNum)

	-- 该面板属性值
	return bg
end

function fnUpdateHeroAttrPanel()
	require "script/model/user/UserModel"

	local userInfo = UserModel.getUserInfo()
	_cltNickname:setString(userInfo.uname)
	-- 银两实际数据
	_cltSilverNum:setString(string.convertSilverUtilByInternational(userInfo.silver_num))  -- modified by yangrui at 2015-12-03
	_cltGoldNum:setString(userInfo.gold_num)

	for i=1, #_arrLevelUpValueObjs do
 		_arrLevelUpValueObjs[i]:setString(" ")
 	end
 	--停止所有动画
	fnStopAllActions()
	-- 设置当前级别
	_crlHeroLevel:setString(_tHeroAttr.level)
	_crlHeroLevel:setOpacity(255)
	_crlHeroLevel:setColor(ccc3(0x78, 0x25, 0))
	-- 从武将库中删除武将
	fnDeleteSelectedHeroes()
	-- 更新所选择的武将列表
	_ccSpriteSelectedHeroes:removeFromParentAndCleanup(true)
	_ccSpriteSelectedHeroes = fnCreateSelectedHeroes()
	_clItemOfNeeded:addChild(_ccSpriteSelectedHeroes)
	-- 消耗银币清零
	_ccLabelSilverNumCard:setString("0")
	-- 获得经验清零
	_ccLabelExpNumCard:setString("0")

 	fnUpdateSoulActions()
end

function fnDeleteSelectedHeroes()
	for i=1, #_arrSelectedHeroes do
		HeroModel.deleteHeroByHid(_arrSelectedHeroes[i].hid)
	end
	_arrSelectedHeroes = {}
end

-- 创建标题栏
local function fnCreateTitlePanel( ... )
	require "script/libs/LuaCC"
	local tLabel = {text=GetLocalizeStringBy("key_2912"), color=ccc3(0xff, 0xf0, 0x49), fontsize=35, vOffset=4, tag=101, fontname=g_sFontPangWa}
	local title = LuaCC.createSpriteWithLabel("images/common/title_bg.png", tLabel)
	local panel = {}
	panel.ccBG = title
	panel.ccBG:setScale(g_fScaleX)
	panel.size = title:getContentSize()
	panel.size.width = panel.size.width * g_fScaleX
	panel.size.height = panel.size.height * g_fScaleX
	return title
end

-- 卡牌强化，武魂强化属性项点击事件
local function fnHandlerOfButtonTapHandler(tag, item_obj)
	-- 音效
	require "script/audio/AudioUtil"
	AudioUtil.playEffect("audio/effect/changtiaoxing.mp3")
	item_obj:selected()
	if tag == _ksTagTabCardStrengthen and _nIndexOfTab == _nIndexOfCardStrengthen then
		return
	elseif tag == _ksTagTabSoulStrengthen and _nIndexOfTab == _nIndexOfSoulStrengthen then
		return
	end

	if tag == _ksTagTabCardStrengthen then
		_nIndexOfTab = _nIndexOfCardStrengthen
		_ccButtonSoulStrengthen:unselected()
		if _ccLayerCardStrengthen then
			_ccLayerCardStrengthen:setVisible(true)
			_ccLayerSoulStrengthen:setVisible(false)
		end
		fnStopAllActions()
		fnRestoreHeroLevelLabel()
		fnAddProgressBar()
	elseif tag == _ksTagTabSoulStrengthen then
		_nIndexOfTab = _nIndexOfSoulStrengthen
		_ccButtonCardStrengthen:unselected()
		if _ccLayerCardStrengthen then
			_ccLayerCardStrengthen:setVisible(false)
			_ccLayerSoulStrengthen:setVisible(true)
		end
		fnStopAllActions()
		_arrSelectedHeroes = {}
		_ccSpriteSelectedHeroes:removeFromParentAndCleanup(true)
		_ccSpriteSelectedHeroes = fnCreateSelectedHeroes()
		_clItemOfNeeded:addChild(_ccSpriteSelectedHeroes)
		fnUpdateSoulActions()
		fnUpdateSoulPanel()
		_ccLabelExpNumCard:setString("0")
		_ccLabelSilverNumCard:setString("0")
	end
	setButtonStauts(true)
end

function fnRestoreHeroLevelLabel( ... )
	_crlHeroLevel:stopAllActions()
	_crlHeroLevel:setString(_tHeroAttr.level)
	_crlHeroLevel:setOpacity(255)
	_crlHeroLevel:setColor(ccc3(0x78, 0x25, 0))
end

-- 创建卡牌强化属性页标题
local function fnCreateTitlePageTabs()
	local tNGInfo = {file="images/common/bg/button/ng_tab_n.png"}
	tNGInfo.rect = CCRectMake(0, 0, 63, 43)
	tNGInfo.rectInsets = CCRectMake(29, 18, 4, 1)
	tNGInfo.preferredSize = CCSizeMake(274, 43)
	tNGLightedInfo = {}
	tNGLightedInfo.file = "images/common/bg/button/ng_tab_h.png"
	tNGLightedInfo.rect = CCRectMake(0, 0, 73, 53)
	tNGLightedInfo.rectInsets = CCRectMake(34, 25, 4, 1)
	tNGLightedInfo.preferredSize = CCSizeMake(280, 53)
	local tLabel = {
		text=GetLocalizeStringBy("key_1756"),
		fontsize=30,
		color=ccc3(0x76, 0x3b, 0x0b),
		tag=101,
		vOffset=-4,
	}
	local ccNormalSpriteCard = LuaCC.create9SpriteWithLabel(tNGInfo, tLabel)
	tLabel.color = ccc3(0x74, 0x48, 1)
	local ccLightedSpriteCard = LuaCC.create9SpriteWithLabel(tNGLightedInfo, tLabel)
	
	tLabel.text = GetLocalizeStringBy("key_1477")
	tLabel.color = ccc3(0x76, 0x3b, 0x0b)
	local ccNormalSpriteSoul = LuaCC.create9SpriteWithLabel(tNGInfo, tLabel)
	tLabel.color = ccc3(0x74, 0x48, 1)
	local ccLightedSpriteSoul = LuaCC.create9SpriteWithLabel(tNGLightedInfo, tLabel)
	local ccMenu = CCMenu:create()
	_ccButtonCardStrengthen = CCMenuItemSprite:create(ccNormalSpriteCard, ccLightedSpriteCard)
	_ccButtonCardStrengthen:registerScriptTapHandler(fnHandlerOfButtonTapHandler)
	_ccButtonCardStrengthen:selected()
	_ccButtonCardStrengthen:setPosition(ccp(20, 0))
	ccMenu:addChild(_ccButtonCardStrengthen, 0, _ksTagTabCardStrengthen)

	_ccButtonSoulStrengthen = CCMenuItemSprite:create(ccNormalSpriteSoul, ccLightedSpriteSoul)
	_ccButtonSoulStrengthen:registerScriptTapHandler(fnHandlerOfButtonTapHandler)
	_ccButtonSoulStrengthen:setPosition(ccp(300, 0))
	ccMenu:addChild(_ccButtonSoulStrengthen, 0, _ksTagTabSoulStrengthen)

	return ccMenu
end

function createLayer(hero, tParam, pCloseCallback)
	init()
	if hero then
		_tHeroAttr = hero
	end
	if tParam then
		_tParentParam = tParam
		if tParam.selectedHeroes then
			_arrSelectedHeroes = tParam.selectedHeroes
		end
	end
	_onRunningLayer = CCLayer:create()
	-- 初始值为卡牌强化
	_nIndexOfTab = _nIndexOfCardStrengthen

	require "script/ui/main/BulletinLayer"
	require "script/ui/main/MainScene"
	require "script/ui/main/MenuLayer"
	local bulletinLayerSize = BulletinLayer.getLayerContentSize()
	local menuLayerSize = MenuLayer.getLayerContentSize()
	MenuLayer.getObject():setVisible(true)

	-- 加载模块背景图
	local bg = CCSprite:create("images/main/module_bg.png")
	bg:setScale(g_fBgScaleRatio)
	_onRunningLayer:addChild(bg)

	-- 隐藏avatar层
	local ccObjAvatar = MainScene.getAvatarLayerObj()
	ccObjAvatar:setVisible(false)

	_onRunningLayer:setPosition(ccp(0, menuLayerSize.height*g_fScaleX))
	local height = g_winSize.height - (menuLayerSize.height + bulletinLayerSize.height)*g_fScaleX
	_onRunningLayer:setContentSize(CCSizeMake(g_winSize.width, height))
	-- 英雄属性面板
	local ccSpriteHeroAttr = fnCreateHeroAttrPanel()
	ccSpriteHeroAttr:setScale(g_fScaleX)
	ccSpriteHeroAttr:setPosition(0, height)
	ccSpriteHeroAttr:setAnchorPoint(ccp(0, 1))
	_onRunningLayer:addChild(ccSpriteHeroAttr)

	height = height - ccSpriteHeroAttr:getContentSize().height*g_fScaleX
	-- 标题栏
	local ccSpriteTitle = fnCreateTitlePanel()
	ccSpriteTitle:setPosition(0, height)
	ccSpriteTitle:setAnchorPoint(ccp(0, 1))

	height = height - ccSpriteTitle:getContentSize().height*g_fScaleX
	_nRealHeight = height
-- 计算出元素的比率因子
	_fElementScale = _nRealHeight/_nStandardHeight
	if _fElementScale > g_fScaleX then
		_fElementScale = g_fScaleX
	end
	-- 背景图
	local fullRect = CCRectMake(0, 0, 196, 198)
    local insetRect = CCRectMake(61, 80, 46, 36)
    local ccStarSellBG = CCScale9Sprite:create("images/hero/bg_ng.png", fullRect, insetRect)
    local preferredSize = {w=g_winSize.width, h = height+4}
    ccStarSellBG:setPreferredSize(CCSizeMake(preferredSize.w+4, preferredSize.h+30))
    ccStarSellBG:setPosition(ccp(preferredSize.w/2, preferredSize.h/2))
    ccStarSellBG:setAnchorPoint(ccp(0.5, 0.5))
    _onRunningLayer:addChild(ccStarSellBG)
	_onRunningLayer:addChild(ccSpriteTitle)

	local ccLayerUpAttr = fnCreateStrenthenCardAndAttrPanel()
	ccLayerUpAttr:setAnchorPoint(ccp(0.5, 1))
-- 武将属性面板的高度
	_nHeightOfHeroAttr = ccLayerUpAttr:getContentSize().height
	local y = (266 + _nHeightOfHeroAttr)*_nRealHeight/_nStandardHeight
	ccLayerUpAttr:setPosition(g_winSize.width/2, y)
	_nYPosOfHeroAttr = y - _nHeightOfHeroAttr*_fElementScale
-- 卡牌强化，武魂强化菜单项
	local ccMenuTabs = fnCreateTitlePageTabs()
    ccMenuTabs:setPosition(0, ccLayerUpAttr:getContentSize().height-4)
    ccMenuTabs:setAnchorPoint(ccp(0, 0))
	ccLayerUpAttr:addChild(ccMenuTabs, -1, 1001)
	_onRunningLayer:addChild(ccLayerUpAttr)

-- 卡牌强化特性
    _ccLayerCardStrengthen = fnCreateCardStrengthenPanel()
    _ccLayerCardStrengthen:setPosition(ccp(0, 0))
    _onRunningLayer:addChild(_ccLayerCardStrengthen)
-- 将魂强化特性
    _ccLayerSoulStrengthen = fnCreateSoulStrengthenPanel()
    _ccLayerSoulStrengthen:setPosition(ccp(0, 0))
    _ccLayerSoulStrengthen:setVisible(false)
    _onRunningLayer:addChild(_ccLayerSoulStrengthen)

	return _onRunningLayer
end

-- 强化后端返回后回调
function fnHandlerOfNetwork(cbFlag, dictData, bRet)
	if not bRet then
		return
	end
	-- 武将卡牌强化
	if cbFlag == "hero.enforceByHero" or cbFlag == "hero.enforce" then
		require "script/model/user/UserModel"
		require "script/model/hero/HeroModel"
		-- 修改用户银币数量
		UserModel.addSilverNumber(-tonumber(dictData.ret.silver))
		-- 修改武将等级
		require "script/ui/common/PublicSpecialEffects"
		_addedLv = tonumber(dictData.ret.level) - _tHeroAttr.level
		
		HeroModel.setHeroLevelByHid(_tHeroAttr.hid, dictData.ret.level)
		_tHeroAttr.level = tonumber(dictData.ret.level)
		-- 修改武将武魂数量
		if cbFlag == "hero.enforceByHero" then
			_tHeroAttr.soul = _tHeroAttr.soul + tonumber(dictData.ret.soul)
			HeroModel.setHeroSoulByHid(_tHeroAttr.hid, _tHeroAttr.soul)
			fnAddProgressBar()
			fnDeleteSelectedHeroes()
			addEffectForHeadIcons()

		elseif cbFlag == "hero.enforce" then
			-- 减去消耗的将魂数量
			UserModel.addSoulNum(-tonumber(dictData.ret.soul))
			HeroModel.setHeroSoulByHid(_tHeroAttr.hid, tonumber(dictData.ret.hero_soul))
			_tHeroAttr.soul = tonumber(dictData.ret.hero_soul)
			fnUpdateSoulPanel()
			fnUpdateHeroAttrPanel()
			-- showAffixTip(_addedLv)
			-- PublicSpecialEffects.enhanceResultEffect(_addedLv)
		end
		


		require "db/DB_Heroes"
		local db_hero = DB_Heroes.getDataById(_tHeroAttr.htid)
		local nLimitLevel = db_hero.strength_limit_lv + tonumber(_tHeroAttr.evolve_level)*db_hero.strength_interval_lv
		local evolveData = string.split(db_hero.advanced_id,",")
		local evolveArray = string.split(evolveData[table.count(evolveData)],"|")
		if _tHeroAttr.level >= nLimitLevel and (tonumber(_tHeroAttr.evolve_level) < (tonumber(evolveArray[1])+1)) then
			require "script/ui/tip/AnimationTip"
			AnimationTip.showTip(GetLocalizeStringBy("key_1825"))
		end

		---[==[ 强化所第9步
		---------------------新手引导---------------------------------
		    --add by licong 2013.09.07
		    require "script/guide/NewGuide"
		    print("g_guideClass = ", NewGuide.guideClass)
			require "script/guide/StrengthenGuide"
		    if(NewGuide.guideClass ==  ksGuideForge and StrengthenGuide.stepNum == 8) then
			    require "script/ui/main/MenuLayer"
			    local strengthenButton = MenuLayer.getMenuItemNode(3)
			    local touchRect = getSpriteScreenRect(strengthenButton)
			    StrengthenGuide.show(9, touchRect)
			end
		 ---------------------end-------------------------------------
		--]==]

		---[==[ 等级礼包第17步 副本
        ---------------------新手引导---------------------------------
        --add by licong 2013.09.09
        require "script/guide/NewGuide"
        print("g_guideClass = ", NewGuide.guideClass)
        require "script/guide/LevelGiftBagGuide"
        if(NewGuide.guideClass ==  ksGuideFiveLevelGift and LevelGiftBagGuide.stepNum == 16) then
        	require "script/ui/main/MenuLayer"
            local levelGiftBagGuide_button = MenuLayer.getMenuItemNode(3)
            local touchRect = getSpriteScreenRect(levelGiftBagGuide_button)
            LevelGiftBagGuide.show(17, touchRect)
        end
        ---------------------end-------------------------------------
   		--]==]
	end
end

function showAffixTip( addedLv )
	-- 更新玩家银币显示数量
	if addedLv > 0 then
		print("showAffixTip", addedLv)
		local heroInfo = HeroModel.getHeroByHid(_tHeroAttr.hid)
	 	require "script/model/hero/FightForceModel"
	 	local tFightForce = FightForceModel.getHeroDisplayAffixByHeroInfo(heroInfo)
	 	
		local nextHeroInfo = {}
	 	table.hcopy(heroInfo, nextHeroInfo)
	 	nextHeroInfo.level = (heroInfo.level) + 1
	 	local tNextFightForce = FightForceModel.getHeroDisplayAffixByHeroInfo(nextHeroInfo)
 

		require "script/utils/LevelUpUtil"
		local tArgs = {}
		local arrTxt = {GetLocalizeStringBy("key_2075"), GetLocalizeStringBy("key_1727"), GetLocalizeStringBy("key_2804"), GetLocalizeStringBy("key_1731")}
		local arrValues = {
			tNextFightForce[AffixDef.LIFE] - tFightForce[AffixDef.LIFE],
			tNextFightForce[AffixDef.GENERAL_ATTACK] - tFightForce[AffixDef.GENERAL_ATTACK],
			tNextFightForce[AffixDef.PHYSICAL_DEFEND] - tFightForce[AffixDef.PHYSICAL_DEFEND],
			tNextFightForce[AffixDef.MAGIC_DEFEND] - tFightForce[AffixDef.MAGIC_DEFEND],
		}
		for i=1, #arrTxt do
			tArgs[i] = {}
			tArgs[i].txt = arrTxt[i]
			tArgs[i].num = arrValues[i]
		end
		LevelUpUtil.showFlyText(tArgs)
	end
end

function fnNetworkSendRequest( button )
	local tHids = {_tHeroAttr.hid, }
	for i=1, #_arrSelectedHeroes do
		table.insert(tHids, _arrSelectedHeroes[i].hid)
	end
	_arrEffectHeroes = {}
	table.hcopy(_arrSelectedHeroes,_arrEffectHeroes)
	local args = CCArray:create()
	args:addObject(CCInteger:create(_tHeroAttr.hid))
	local subArgs = CCArray:create()
	for i=1, #_arrSelectedHeroes do
		subArgs:addObject(CCInteger:create(_arrSelectedHeroes[i].hid))
	end
	args:addObject(subArgs)

	setButtonStauts(false)
	Network.rpc(function ( cbFlag, dictData, bRet )
		fnHandlerOfNetwork(cbFlag, dictData, bRet)
	end , "hero.enforceByHero","hero.enforceByHero", args, true)
end

function setButtonStauts( p_sataus )
	
	local button1 = nil
	local button2 = nil
	if tolua.cast(_cmCardStrengthenPanel, "CCNode") then
		button1 = tolua.cast(_cmCardStrengthenPanel:getChildByTag(_ksTagButtonCardStrengthen), "CCMenuItem")
		button2 = tolua.cast(_cmCardStrengthenPanel:getChildByTag(_ksTagButtonAutoAddOnCard), "CCMenuItem")
	end

	local button3 = nil
	local button4 = nil
	if tolua.cast(_cmSoulStrengthenPanel, "CCNode") then
		button3 = tolua.cast(_cmSoulStrengthenPanel:getChildByTag(_ksTagButtonSoulStrengthen5), "CCMenuItem")
		button4 = tolua.cast(_cmSoulStrengthenPanel:getChildByTag(_ksTagButtonSoulStrengthen), "CCMenuItem")
	end
	if button1 then
		button1:setEnabled(p_sataus)
	end
	if button2 then
		button2:setEnabled(p_sataus)
	end
	if button3 then
		button3:setEnabled(p_sataus)
	end
	if button4 then
		button4:setEnabled(p_sataus)
	end
end


-- 卡牌强化按钮回调处理
local function fnHandlerOfButtonsOnCardStrengthenPanel(tag, item_obj)
	if tag == _ksTagButtonReturnOnCard then
		-- 音效
		require "script/audio/AudioUtil"
		AudioUtil.playEffect("audio/effect/guanbi.mp3")
		require "script/ui/hero/HeroInfoLayer"
		-- local bIsFromFormation = HeroInfoLayer.fnBackToFormation()
		-- if not bIsFromFormation then
		-- 	require "script/ui/main/MainScene"
		-- 	if _tParentParam and type(_tParentParam.fnCreate) == "function" then
		-- 		local tArgs = {}
		-- 		tArgs = table.hcopy(_tParentParam.reserved, tArgs)
		-- 		tArgs.focusHid = _tHeroAttr.hid
		-- 		MainScene.changeLayer(_tParentParam.fnCreate(tArgs), _tParentParam.sign)
		-- 	else
		-- 		require "script/ui/hero/HeroLayer"
		-- 		MainScene.changeLayer(HeroLayer.createLayer(), "HeroLayer")
		-- 	end
		-- end
		print("_tHeroAttr.addPos=>", _tHeroAttr.addPos)
		if _tHeroAttr.addPos == HeroInfoLayer.kFormationPos then
			require("script/ui/formation/FormationLayer")
        	local formationLayer = FormationLayer.createLayer()
        	MainScene.changeLayer(formationLayer, "formationLayer")
        else
        	require "script/ui/hero/HeroLayer"
        	MainScene.changeLayer(HeroLayer.createLayer(), "HeroLayer")
        	HeroLayer.setHeroListOffSet(_tHeroAttr.heriListoffset)
        end
        
	elseif tag == _ksTagButtonCardStrengthen then
		-- 音效
		require "script/audio/AudioUtil"
		AudioUtil.playEffect("audio/effect/zhujiemian.mp3")
		---[==[强化所新手引导屏蔽层
		---------------------新手引导---------------------------------
			--add by licong 2013.09.06
			require "script/guide/NewGuide"
			if(NewGuide.guideClass ==  ksGuideForge) then
				require "script/guide/StrengthenGuide"
				StrengthenGuide.changLayer()
			end
		---------------------end-------------------------------------
		--]==]
		---[==[等级礼包新手引导屏蔽层
		---------------------新手引导---------------------------------
		--add by licong 2013.09.09
--		require "script/guide/NewGuide"
		if(NewGuide.guideClass == ksGuideFiveLevelGift) then
			require "script/guide/LevelGiftBagGuide"
			LevelGiftBagGuide.changLayer()
		end
		---------------------end-------------------------------------
		--]==]
		-- 判断强化功能节点是否开启了，如果没开启则返回
		require "script/model/DataCache"
		local status = DataCache.getSwitchNodeState(ksSwitchGeneralForge)
		if not status then
			return
		end

		-- 主角不能强化，判断是否是主角
		if HeroModel.isNecessaryHero(_tHeroAttr.htid) then
			require "script/ui/tip/AnimationTip"
			AnimationTip.showTip(GetLocalizeStringBy("key_2010"))
			return
		end
		-- 判断是否已选择卡牌
		if _arrSelectedHeroes==nil or #_arrSelectedHeroes==0 then
			require "script/ui/tip/AnimationTip"
			AnimationTip.showTip(GetLocalizeStringBy("key_1725"))
			return
		end
		-- 判断银币数量是否足够
		require "script/model/user/UserModel"
		local nUserSilver = UserModel.getSilverNumber()
		if nUserSilver < _nTotalSilverCost then
			require "script/ui/tip/AnimationTip"
			AnimationTip.showTip(GetLocalizeStringBy("key_1626"))
			return
		end
		-- 判断武将是否已达上限
--		require "db/DB_Heroes"
--		local db_hero = DB_Heroes.getDataById(_tHeroAttr.htid)
--		local nLimitLevel = db_hero.strength_limit_lv + tonumber(_tHeroAttr.evolve_level)*db_hero.strength_interval_lv
		local nLimitLevel = UserModel.getAvatarLevel()
		if _tHeroAttr.level >= nLimitLevel then
			require "script/ui/tip/AnimationTip"
			AnimationTip.showTip(GetLocalizeStringBy("key_1224"))
			return
		end
		local button = tolua.cast(item_obj, "CCMenuItem")
		fnNetworkSendRequest(button)
		-- addEffectForHeadIcons()
		
	elseif tag == _ksTagButtonAutoAddOnCard then
		-- 音效
		require "script/audio/AudioUtil"
		AudioUtil.playEffect("audio/effect/zhujiemian.mp3")
		---[==[等级礼包新手引导屏蔽层
		---------------------新手引导---------------------------------
		--add by licong 2013.09.09
		require "script/guide/NewGuide"
		if(NewGuide.guideClass == ksGuideFiveLevelGift) then
			require "script/guide/LevelGiftBagGuide"
			LevelGiftBagGuide.changLayer()
		end
		---------------------end-------------------------------------
		--]==]

		local tArgs = {}
		tArgs.filters = getFiltersForSelection(4)
		require "script/ui/hero/HeroSelectLayer"
		local arrHeroes = HeroSelectLayer.getHeroList(tArgs)
		print("...........................................................#arrHeroes: ", #arrHeroes)
		local nMaxLen = #arrHeroes
		if nMaxLen > 5 then
			nMaxLen = 5
		end
		_arrSelectedHeroes = {}
		for i=1, nMaxLen do
			_arrSelectedHeroes[i] = arrHeroes[#arrHeroes-i+1]
		end
		_ccSpriteSelectedHeroes:removeFromParentAndCleanup(true)
		_ccSpriteSelectedHeroes = fnCreateSelectedHeroes()
		_clItemOfNeeded:addChild(_ccSpriteSelectedHeroes)

		fnUpdateCardSilverAndExp()

		---[==[ 等级礼包第16步 强化
        ---------------------新手引导---------------------------------
        --add by licong 2013.09.09
        require "script/guide/NewGuide"
        print("g_guideClass = ", NewGuide.guideClass)
        require "script/guide/LevelGiftBagGuide"
        if(NewGuide.guideClass ==  ksGuideFiveLevelGift and LevelGiftBagGuide.stepNum == 15) then
            local levelGiftBagGuide_button = getCardStrengthenButtonForGuide(2)
            local touchRect = getSpriteScreenRect(levelGiftBagGuide_button)
            LevelGiftBagGuide.show(16, touchRect)
        end
        ---------------------end-------------------------------------
   		--]==]
	end
end

-- 将魂强化按钮回调处理
local function fnHandlerOfButtonsOnSoulStrengthenPanel(tag, item_obj)
	if tag == _ksTagButtonReturnOnSoul then
		-- 音效
		require "script/audio/AudioUtil"
		AudioUtil.playEffect("audio/effect/guanbi.mp3")
		print("_tHeroAttr.addPos=>", _tHeroAttr.addPos)
		if _tHeroAttr.addPos == HeroInfoLayer.kFormationPos then
			require("script/ui/formation/FormationLayer")
        	local formationLayer = FormationLayer.createLayer()
        	MainScene.changeLayer(formationLayer, "formationLayer")
        else
        	require "script/ui/hero/HeroLayer"
        	MainScene.changeLayer(HeroLayer.createLayer(), "HeroLayer")
        	if( _tParentParam )then
        		HeroLayer.setHeroListOffSet(_tParentParam.heriListoffset)
        	end
        end
	elseif tag == _ksTagButtonSoulStrengthen5 or tag == _ksTagButtonSoulStrengthen then
		-- 音效
		require "script/audio/AudioUtil"
		AudioUtil.playEffect("audio/effect/zhujiemian.mp3")
		-- 判断强化功能节点是否开启了，如果没开启则返回
		require "script/model/DataCache"
		local status = DataCache.getSwitchNodeState(ksSwitchGeneralForge)
		if not status then
			return
		end
		-- 如果需要的将魂大于现有将魂则提示GetLocalizeStringBy("key_2036")
		if _nNextLevelNeedSoul > UserModel.getSoulNum() then
			require "script/ui/tip/AnimationTip"
			AnimationTip.showTip(GetLocalizeStringBy("key_1353"))
			return
		end
-- 判断银币是否足够
		local nCostCoin = tonumber(_ccObjsCostSilver[3]:getString())
		if nCostCoin > UserModel:getSilverNumber() then
			require "script/ui/tip/AnimationTip"
			AnimationTip.showTip(GetLocalizeStringBy("key_1626"))
			return
		end
-- 判断武将是否已达上限
		local nLimitLevel = UserModel.getAvatarLevel()
		if _tHeroAttr.level >= nLimitLevel then
			require "script/ui/tip/AnimationTip"
			AnimationTip.showTip(GetLocalizeStringBy("key_1224"))
			return
		end
		
		local args = CCArray:create()
		args:addObject(CCInteger:create(_tHeroAttr.hid))
		local times = 1
		if tag == _ksTagButtonSoulStrengthen5 then
			times = 5
		end
		args:addObject(CCInteger:create(times))

		local button = tolua.cast(item_obj, "CCMenuItem")
		setButtonStauts(false)
		Network.rpc(function (cbFlag, dictData, bRet)
			setButtonStauts(true)
			--播放特效
			addCardStrengthenEffect()
			--网络回调
			fnHandlerOfNetwork(cbFlag, dictData, bRet)
		end, "hero.enforce","hero.enforce", args, true)
	end
end

-- 为选择武将提供过滤列表
function getFiltersForSelection(pLimitStarLevel)
	local filters = {}

	local tAllHeroes = HeroModel.getAllHeroes()
	require "db/DB_Heroes"
	for k, v in pairs(tAllHeroes) do
		-- 去除主角
		if HeroModel.isNecessaryHero(v.htid) then
			table.insert(filters, v.hid)
		else
			-- 去除在阵上武将
			local bIsBusy = HeroPublicLua.isBusyWithHid(v.hid)
			if bIsBusy then
				table.insert(filters, v.hid)
			end
			-- 去掉进阶过的武将
			if tonumber(v.evolve_level) > 0 then
				table.insert(filters, v.hid)
			end
			--过滤神兵副本中的武将 by lichenyang 20150106
		 	if GodWeaponCopyData.isOnCopyFormationBy(v.hid) then
		 		table.insert(filters, v.hid)
		 	end
		 	--过滤第二套小伙伴中的武将 by lichenyang 20150106
		 	if SecondFriendData.isInSecondFriendByHid(v.hid) then
		 		table.insert(filters, v.hid)
		 	end
			-- 去掉5星及以上武将
			local db_hero = DB_Heroes.getDataById(v.htid)
			local nLimitStarLevel = 5
			if pLimitStarLevel then
				nLimitStarLevel = pLimitStarLevel
			end
			if db_hero.star_lv >= nLimitStarLevel then
				table.insert(filters, v.hid)
			end
		end
	end
	local bIsNotExisted = true
	for i=1, #filters do
		if _tHeroAttr.hid == filters[i] then
			bIsNotExisted = false
		end
	end
	-- 去除被强化的武将本身
	if bIsNotExisted then
		table.insert(filters, _tHeroAttr.hid)
	end

	return filters
end

-- 选择英雄回调处理
local function fnHandlerOfSelectHero(tag, item_obj)
	-- 音效
	require "script/audio/AudioUtil"
	AudioUtil.playEffect("audio/effect/zhujiemian.mp3")
	---[==[强化所新手引导屏蔽层
	---------------------新手引导---------------------------------
		--add by licong 2013.09.06
		require "script/guide/NewGuide"
		if(NewGuide.guideClass ==  ksGuideForge) then
			require "script/guide/StrengthenGuide"
			StrengthenGuide.changLayer()
		end
	---------------------end-------------------------------------
	--]==]

	--当点击的按钮上已经选择了强化材料，再次点击时移除材料，并刷新需要消耗的银币和可获得的经验
	local selectedHeroIndex = tag - _ksTagSelectedHeroStart
	if _arrSelectedHeroes and _arrSelectedHeroes[selectedHeroIndex] ~= nil then
		table.remove(_arrSelectedHeroes,selectedHeroIndex)
		_ccSpriteSelectedHeroes:removeFromParentAndCleanup(true)
		_ccSpriteSelectedHeroes = fnCreateSelectedHeroes()
		_clItemOfNeeded:addChild(_ccSpriteSelectedHeroes)

		fnUpdateCardSilverAndExp()
		return
	end


	-- 进入武将出售菜单项（出售按钮）
	require "script/ui/hero/HeroSelectLayer"
	require "script/ui/main/MainScene"
	require "script/model/hero/HeroModel"
	require "script/ui/hero/HeroPublicLua"
	
	local tArgsOfModule = {sign="HeroStrengthenLayer"}
	tArgsOfModule.fnCreate = createLayerAfterSelectHero
	tArgsOfModule.filters = getFiltersForSelection()

    tArgsOfModule.selected = {}
    if _arrSelectedHeroes then
	    for i=1, #_arrSelectedHeroes do
	    	table.insert(tArgsOfModule.selected, _arrSelectedHeroes[i].hid)
	    end
	end

	MainScene.changeLayer(HeroSelectLayer.createLayer(tArgsOfModule), "HeroSelectLayer")

	---[==[ 强化所第4步
	---------------------新手引导---------------------------------
	    --add by licong 2013.09.07
	    require "script/guide/NewGuide"
	    print("g_guideClass = ", NewGuide.guideClass)
		require "script/guide/StrengthenGuide"
	    if(NewGuide.guideClass ==  ksGuideForge and StrengthenGuide.stepNum == 3) then
		    require "script/ui/hero/HeroSelectLayer"
		    local strengthenButton = HeroSelectLayer.get3SelectCellObjs()
		    local touchRect = getSpriteScreenRect(strengthenButton[1])
		    StrengthenGuide.show(4, touchRect)
		end
	 ---------------------end-------------------------------------
	--]==]
end

-- 创建所选择强化武将所需要的武将列表
fnCreateSelectedHeroes = function()
	-- 背景图(9宫格)
	local fullRect = CCRectMake(0, 0, 61, 47)
	local insetRect = CCRectMake(24, 16, 10, 4)
    local bg_ng = CCScale9Sprite:create("images/common/bg/white_text_ng.png", fullRect, insetRect)
    local tPreferredSize = {width=566, height=112}
    bg_ng:setPreferredSize(CCSizeMake(tPreferredSize.width, tPreferredSize.height))
    bg_ng:setScale(_fElementScale)
    bg_ng:setPosition(g_winSize.width/2, _nYPosOfHeroAttr*172/250)
    bg_ng:setAnchorPoint(ccp(0.5, 0.5))
    local distance = 14
    local x = distance/2+2
    local y = tPreferredSize.height/2
    local icon_width = 98

    --提示"点击图标取消选中的物品"
    local unselectTip = CCRenderLabel:create(GetLocalizeStringBy("zz_137"), g_sFontName, 22, 2, ccc3(0x00,0x00,0x00), type_shadow)
    unselectTip:setColor(ccc3(0x00,0xff,0x00))
    unselectTip:setAnchorPoint(ccp(0,0))
    unselectTip:setPosition(10,tPreferredSize.height+2)
    bg_ng:addChild(unselectTip)

    local menu = CCMenu:create()
    _csAddHeroeButtons = {}
    for i=1, 5 do
		-- 武将头像图标背景
		local head_icon_bg
		local tCellValue = {quality_bg="images/hero/quality/1.png", quality_h="images/hero/quality/highlighted.png"}
		if _arrSelectedHeroes and _arrSelectedHeroes[i] ~= nil then
			tCellValue = _arrSelectedHeroes[i]
		end
    	-- 头像图标
    	if _arrSelectedHeroes and _arrSelectedHeroes[i] ~= nil then
    		local csQuality = CCSprite:create(tCellValue.quality_bg)
			local csQualityLighted = CCSprite:create(tCellValue.quality_bg)
			local csFrame = CCSprite:create(tCellValue.quality_h)
			csFrame:setPosition(csQualityLighted:getContentSize().width/2, csQualityLighted:getContentSize().height/2)
			csFrame:setAnchorPoint(ccp(0.5, 0.5))
			csQualityLighted:addChild(csFrame)
    		head_icon_bg = CCMenuItemSprite:create(csQuality, csQualityLighted)
    		head_icon=CCSprite:create(_arrSelectedHeroes[i].head_icon)
    	 else
    	 	
    	 	head_icon_bg = CCMenuItemImage:create("images/common/border.png", "images/common/border.png")
			head_icon=CCSprite:create("images/common/add_new.png")
			local arrActions_2 = CCArray:create()
			arrActions_2:addObject(CCFadeOut:create(1))
			arrActions_2:addObject(CCFadeIn:create(1))
			local sequence_2 = CCSequence:create(arrActions_2)
			local action_2 = CCRepeatForever:create(sequence_2)
			head_icon:runAction(action_2)
    	end
    	table.insert(_csAddHeroeButtons, head_icon_bg)
    	head_icon_bg:registerScriptTapHandler(fnHandlerOfSelectHero)

    	head_icon:setPosition(ccp(head_icon_bg:getContentSize().width/2, head_icon_bg:getContentSize().height/2))
    	head_icon:setAnchorPoint(ccp(0.5, 0.5))
    	head_icon_bg:addChild(head_icon)
    	head_icon_bg:setPosition(ccp(x, y))
    	head_icon_bg:setAnchorPoint(ccp(0, 0.5))
    	x = x + icon_width + distance
    	menu:addChild(head_icon_bg, 0, _ksTagSelectedHeroStart+i)
	end
	menu:setPosition(ccp(0, 0))
    bg_ng:addChild(menu)

    return bg_ng
end
-- 添加卡牌强化效果
function addCardStrengthenEffect( ... )
	local ccDelegate=BTAnimationEventDelegate:create()
	ccDelegate:registerLayerEndedHandler(function (actionName, xmlSprite)
		xmlSprite:retain()
		xmlSprite:autorelease()
		xmlSprite:removeFromParentAndCleanup(true)
		--按钮状态
		setButtonStauts(true)
		--显示属性
		showAffixTip(_addedLv)
		PublicSpecialEffects.enhanceResultEffect(_addedLv)
		--
		fnUpdateHeroAttrPanel()
		--
	end)
	ccDelegate:registerLayerChangedHandler(function ()

	end)
	local sImgPath=CCString:create("images/base/effect/hero/qianghua")
	local clsEffect=CCLayerSprite:layerSpriteWithNameAndCount(sImgPath:getCString(), -1,CCString:create(""))
--	clsEffect:setAnchorPoint(ccp(0.5, 0.5))
	clsEffect:setPosition(_csCardShowBg:getContentSize().width/2, _csCardShowBg:getContentSize().height/2)
	clsEffect:setDelegate(ccDelegate)
	_csCardShowBg:addChild(clsEffect)
end

local _indexOfLast=0
-- 创建粒子特效
local function createParticleEffect(index, csObj)
	local rect = getSpriteScreenRect(csObj)
	local layerRect = getSpriteScreenRect(_onRunningLayer)
	local targetRect = getSpriteScreenRect(_csCardShowBg)
	local coordinates_offset={{h=-10, v=10}, {h=10, v=10}, {h=0, v=0}, {h=-10, v=-10}, {h=10, v=-10}, }
	local x_center=rect.origin.x + rect.size.width/2
	local y_center=rect.origin.y + rect.size.height/2
	_indexOfLast=index
	for i=1, 5 do
		local csParticle=CCSprite:create("images/base/effect/hero/particle.png")
		local x=x_center+coordinates_offset[i].h-layerRect.origin.x
		local y=y_center+coordinates_offset[i].v-layerRect.origin.y
		csParticle:setPosition(x, y)
		csParticle:setTag(1000+i+index)
		_onRunningLayer:addChild(csParticle)
		local tx=targetRect.origin.x - layerRect.origin.x + targetRect.size.width/2
		local ty=targetRect.origin.y - layerRect.origin.y+targetRect.size.height/2
		local arrActions = CCArray:create()
		arrActions:addObject(CCMoveTo:create(0.5, ccp(tx, ty)))
		arrActions:addObject(CCCallFuncN:create(function (obj)
			if obj:getTag() == 1005+_indexOfLast then
				-- fnNetworkSendRequest()
				addCardStrengthenEffect()
			end	
			obj:removeFromParentAndCleanup(true)
		end))
		local sequence = CCSequence:create(arrActions)
--		local action = CCRepeatForever:create(sequence)
		csParticle:runAction(sequence)
	end
end

-- 为卡牌头像添加特效
function addEffectForHeadIcons( ... )

	-- 武将强化时卡牌特效
	for i=1, #_arrEffectHeroes do
		local csParent=_csAddHeroeButtons[i]
		local ccDelegate=BTAnimationEventDelegate:create()
		ccDelegate:registerLayerEndedHandler(function (actionName, xmlSprite)
			xmlSprite:retain()
			xmlSprite:autorelease()
			createParticleEffect(i, xmlSprite)
			xmlSprite:removeFromParentAndCleanup(true)
		end)
		ccDelegate:registerLayerChangedHandler(function ( ... )
			-- body
		end)
		-- 武将强化时卡牌特效
		local sImgPath=CCString:create("images/base/effect/hero/wujiangqianghua")
		local clsEffect=CCLayerSprite:layerSpriteWithNameAndCount(sImgPath:getCString(), -1,CCString:create(""))
		clsEffect:setFPS_interval(1.0/60)
		clsEffect:setPosition(csParent:getContentSize().width/2, csParent:getContentSize().height/2)
		clsEffect:setDelegate(ccDelegate)
		csParent:addChild(clsEffect)
	end

end

-- 卡牌强化面板中强化需要物品及所获物品
fnAddExchangeInfoOnCardStrengthenPanel = function()
	local ccBgNg = CCScale9Sprite:create("images/common/transparent.png", CCRectMake(0, 0, 3, 3), CCRectMake(1, 1, 1, 1))
	ccBgNg:setPreferredSize(CCSizeMake(540, 73))
	ccBgNg:setAnchorPoint(ccp(0.5, 0))
	ccBgNg:setPosition(g_winSize.width/2, _nYPosOfHeroAttr*90/250)
	ccBgNg:setScale(_fElementScale)

	local pos_x=0
	-- 消耗银币
	local ccLabelTextSilver = CCLabelTTF:create(GetLocalizeStringBy("key_2115"), g_sFontName, 23)
	ccLabelTextSilver:setColor(ccc3(0x78, 0x25, 0))
	ccLabelTextSilver:setPositionX(pos_x)
	ccBgNg:addChild(ccLabelTextSilver)
	-- 银币图标
	pos_x = pos_x + ccLabelTextSilver:getContentSize().width
	local ccSpriteSilver = CCSprite:create("images/common/coin_silver.png")
	ccSpriteSilver:setPositionX(pos_x)
	ccBgNg:addChild(ccSpriteSilver)
	-- 银币数量
	pos_x = pos_x + ccSpriteSilver:getContentSize().width+6
	_ccLabelSilverNumCard = CCLabelTTF:create("0", g_sFontName, 23)
	local ccLabelSilverNum = _ccLabelSilverNumCard
	ccLabelSilverNum:setColor(ccc3(0, 0, 0))
	ccLabelSilverNum:setPositionX(pos_x)
	ccBgNg:addChild(ccLabelSilverNum)
	-- 获得经验值
	pos_x = 260
	local ccLabelTextExp = CCLabelTTF:create(GetLocalizeStringBy("key_2141"), g_sFontName, 23)
	ccLabelTextExp:setColor(ccc3(0x78, 0x25, 0))
	ccLabelTextExp:setPositionX(pos_x)
	ccBgNg:addChild(ccLabelTextExp)
	-- 经验值实际数据（从DB中读）
	pos_x = pos_x + ccLabelTextExp:getContentSize().width
	_ccLabelExpNumCard = CCLabelTTF:create("0", g_sFontName, 23)
	local ccLabelExpNum = _ccLabelExpNumCard
	ccLabelExpNum:setColor(ccc3(0, 0, 0))
	ccLabelExpNum:setPositionX(pos_x)
	ccBgNg:addChild(ccLabelExpNum)

	return ccBgNg
end

-- 创建将魂强化面板上的按钮
fnCreateButtonsOnSoulStrengthenPanel = function ( ... )
	-- 菜单按钮，返回，强化5次，强化
	local tMenuItems = {
		{file="images/hero/strengthen/buttons/return", 
				pos_x=0, pos_y=0, ccObj=nil, tag=_ksTagButtonReturnOnSoul,
				cb=fnHandlerOfButtonsOnSoulStrengthenPanel},
		{file="images/hero/strengthen/buttons/strengthen5", 
				pos_x=160, pos_y=0, ccObj=nil, tag=_ksTagButtonSoulStrengthen5, 
				cb=fnHandlerOfButtonsOnSoulStrengthenPanel},
		{file="images/hero/strengthen/buttons/strengthen", 
				pos_x=382, pos_y=0, ccObj=nil, tag=_ksTagButtonSoulStrengthen, 
				cb=fnHandlerOfButtonsOnSoulStrengthenPanel},
	}
	local menu = LuaCC.createMenuWithSpriteFile(tMenuItems)
	_cmSoulStrengthenPanel = menu
	menu:setPosition(0, 0)

	local ccBgNg = CCScale9Sprite:create("images/common/transparent.png", CCRectMake(0, 0, 3, 3), CCRectMake(1, 1, 1, 1))
	ccBgNg:setPreferredSize(CCSizeMake(568, 73))
	ccBgNg:setAnchorPoint(ccp(0.5, 0))
	ccBgNg:setPosition(g_winSize.width/2, 12 * _nRealHeight/_nStandardHeight)
	ccBgNg:setScale(_fElementScale)
	ccBgNg:addChild(menu)

	return ccBgNg
end

-- 创建卡牌强化面板上的按钮
fnCreateButtonsOnCardStrengthenPanel = function ( ... )
	-- 菜单按钮，返回，强化5次，强化
	local tMenuItems = {
		{file="images/hero/strengthen/buttons/return", 
				pos_x=0, pos_y=0, ccObj=nil, tag=_ksTagButtonReturnOnCard,
				cb=fnHandlerOfButtonsOnCardStrengthenPanel},
		{file="images/hero/strengthen/buttons/strengthen", 
				pos_x=156, pos_y=0, ccObj=nil, tag=_ksTagButtonCardStrengthen, 
				cb=fnHandlerOfButtonsOnCardStrengthenPanel},
		{file="images/hero/strengthen/buttons/autoadd", 
				pos_x=374, pos_y=0, ccObj=nil, tag=_ksTagButtonAutoAddOnCard, 
				cb=fnHandlerOfButtonsOnCardStrengthenPanel},
		-- {file="images/hero/strengthen/buttons/star_set", 
		-- 		pos_x=500, pos_y=70, ccObj=nil, tag=_ksTagStarOnCard,
		-- 		cb=fnHandlerOfButtonsOnCardStrengthenPanel},
	}
	local menu = LuaCC.createMenuWithSpriteFile(tMenuItems)
	_cmCardStrengthenPanel = menu
	menu:setPosition(ccp(0, 0))

-- 菜单项的透明背景
	local ccBgNg = CCScale9Sprite:create("images/common/transparent.png", CCRectMake(0, 0, 3, 3), CCRectMake(1, 1, 1, 1))
	ccBgNg:setPreferredSize(CCSizeMake(568, 73))
	ccBgNg:setAnchorPoint(ccp(0.5, 0))
	ccBgNg:setPosition(g_winSize.width/2, 12 * _nRealHeight/_nStandardHeight)
	ccBgNg:setScale(_fElementScale)
	ccBgNg:addChild(menu)

	return ccBgNg
end
-- 添加经验进度条
function fnAddProgressBar(nAddedSoul)
	local nMaxWidth = 170
	if _cs9ProgressBar then
		_cs9ProgressBar:removeFromParentAndCleanup(true)
	end
	if _cs9ProgressGreenBar then
		_cs9ProgressGreenBar:removeFromParentAndCleanup(true)
		_cs9ProgressGreenBar=nil
	end

	local fullRect = CCRectMake(0, 0, 46, 23)
    local insetRect = CCRectMake(20, 8, 5, 1)
    local preferredSize = CCSizeMake(nMaxWidth, 23)
    local tArgs = {}
	tArgs.exp_id = _tHeroAttr.exp_id
	tArgs.level = _tHeroAttr.level
    local nSoulOnCurrentLevel = HeroPublicLua.getSoulOnLevel(tArgs)
	local nSoulLeft = tonumber(_tHeroAttr.soul) - nSoulOnCurrentLevel
    tArgs.level = _tHeroAttr.level + 1
    local nSoulOnNextLevel = HeroPublicLua.getSoulOnLevel(tArgs)
    local nSoulNeededToNextLevel = nSoulOnNextLevel - nSoulOnCurrentLevel
   	local nBarWidth = math.ceil(nSoulLeft*nMaxWidth/nSoulNeededToNextLevel)

   	if nAddedSoul then
   		local nGreenBarWidth = math.ceil((nSoulLeft+nAddedSoul)*nMaxWidth/nSoulNeededToNextLevel)
		if nGreenBarWidth > nMaxWidth then
			nGreenBarWidth = nMaxWidth
		end
 		if nGreenBarWidth < 46 then
	    	_cs9ProgressGreenBar = CCSprite:create("images/hero/strengthen/green_bar.png")
			_cs9ProgressGreenBar:setTextureRect(CCRectMake(0, 0, nGreenBarWidth, 23))
	    else
			_cs9ProgressGreenBar = CCScale9Sprite:create("images/hero/strengthen/green_bar.png", fullRect, insetRect)
	    	_cs9ProgressGreenBar:setPreferredSize(CCSizeMake(nGreenBarWidth, preferredSize.height))
	    end
	    local arrActions = CCArray:create()
	    local fadeIn = CCFadeIn:create(0.8)
		local fadeOut = CCFadeOut:create(0.8)
		arrActions:addObject(fadeIn)
		arrActions:addObject(fadeOut)
		local sequence = CCSequence:create(arrActions)
		local action = CCRepeatForever:create(sequence)
		_cs9ProgressGreenBar:runAction(action)
		_cs9ProgressBg:addChild(_cs9ProgressGreenBar)
   	end

    if nBarWidth < 46 then
    	_cs9ProgressBar = CCSprite:create("images/hero/strengthen/exp_bar.png")
		_cs9ProgressBar:setTextureRect(CCRectMake(0, 0, nBarWidth, 23))
    else
    	if nBarWidth > nMaxWidth then
    		nBarWidth = nMaxWidth
    	end
		_cs9ProgressBar = CCScale9Sprite:create("images/hero/strengthen/exp_bar.png", fullRect, insetRect)
    	_cs9ProgressBar:setPreferredSize(CCSizeMake(nBarWidth, preferredSize.height))
    end
    _cs9ProgressBg:addChild(_cs9ProgressBar)
end

-- 创建属性面板方法（有关武将、武魂强化中，生命、物攻等属性值）
local fnCreateAttrPanel = function ( ... )
		-- 属性白色背景
	local fullRect = CCRectMake(0, 0, 61, 47)
    local insetRect = CCRectMake(24, 16, 10, 4)
	local bg_attr_ng = CCScale9Sprite:create("images/common/bg/white_text_ng.png", fullRect, insetRect)
	bg_attr_ng:setPreferredSize(CCSizeMake(282, 362))
	bg_attr_ng:setPosition(ccp(310, 10))

	csLevelIcon = CCSprite:create("images/common/lv.png")
	csLevelIcon:setPosition(16, 320)
	_crlHeroLevel = CCLabelTTF:create(_tHeroAttr.level, g_sFontName, 27)
	_crlHeroLevel:setAnchorPoint(ccp(0, 0.5))
	_crlHeroLevel:setColor(ccc3(0x78, 0x25, 0))
	local tIconSize = csLevelIcon:getContentSize()
	local tTextSize = _crlHeroLevel:getContentSize()
	_crlHeroLevel:setPosition(20+tIconSize.width, 314+tTextSize.height/2)

	bg_attr_ng:addChild(csLevelIcon)
	bg_attr_ng:addChild(_crlHeroLevel)

-- 进度条显示
    local fullRect = CCRectMake(0, 0, 46, 23)
    local insetRect = CCRectMake(20, 8, 5, 1)
    local preferredSize = CCSizeMake(170, 23)
-- 进度条九宫格背景
    _cs9ProgressBg = CCScale9Sprite:create("images/hero/strengthen/bg_exp_bar.png", fullRect, insetRect)
    _cs9ProgressBg:setPreferredSize(preferredSize)
    _cs9ProgressBg:setPosition(100, 320)
    bg_attr_ng:addChild(_cs9ProgressBg)

    fnAddProgressBar()

    require "script/libs/LuaCCLabel"
    require "script/model/hero/HeroModel"
 	-- 生命, 物攻, 策攻, 物防, 策防
 	local labelColor=ccc3(0x78, 0x25, 0)
 	local tLabels = {
 		{text=GetLocalizeStringBy("key_3032"), fontsize=23, color=labelColor},
 		{text=GetLocalizeStringBy("key_3033"), vOffset=32},
 		{text=GetLocalizeStringBy("key_1649")},
 		{text=GetLocalizeStringBy("key_1877")},
 	}
 	local tLabelObjs = LuaCCLabel.createVerticalLabelHeelLabels(tLabels)
 	tLabelObjs[1]:setPosition(ccp(30, 90))
 	bg_attr_ng:addChild(tLabelObjs[1])
 	-- 当前级别属性值
 	local labelColor=ccc3(0, 0, 0)
 	local heroInfo = HeroModel.getHeroByHid(_tHeroAttr.hid)
 	require "script/model/hero/FightForceModel"
 	local tFightForce = FightForceModel.getHeroDisplayAffixByHeroInfo(heroInfo)
 	
 	local nextHeroInfo = {}
 	table.hcopy(heroInfo, nextHeroInfo)
 	nextHeroInfo.level = (heroInfo.level) + 1
 	local tNextFightForce = FightForceModel.getHeroDisplayAffixByHeroInfo(nextHeroInfo)
 	-- 必防数值
 	local magicDefend = {
 		current=tFightForce[AffixDef.MAGIC_DEFEND],
 		next=tNextFightForce[AffixDef.MAGIC_DEFEND],
 	}
 	-- 物防数值
 	local physicalDefend = {
 		current=tFightForce[AffixDef.PHYSICAL_DEFEND],
 		next=tNextFightForce[AffixDef.PHYSICAL_DEFEND],
 	}

 	local generalAttack = {}
 	generalAttack.current=tFightForce[AffixDef.GENERAL_ATTACK]
 	generalAttack.next=tNextFightForce[AffixDef.GENERAL_ATTACK]
 	-- 生命数值
 	local life = {
 		current=tFightForce[AffixDef.LIFE],
 		next=tNextFightForce[AffixDef.LIFE]
 	}
 	local tLabels = {
 		{text=math.floor(magicDefend.current), fontsize=23, color=labelColor},
 		{text=math.floor(physicalDefend.current), vOffset=32},
		{text=math.floor(generalAttack.current)},
 		{text=math.floor(life.current)},
 	}
 	local tLabelObjs = LuaCCLabel.createVerticalLabelHeelLabels(tLabels)
 	_arrCurrentLevelValueObjs = tLabelObjs
 	--兼容东南亚英文版
if (Platform.getLayout ~= nil and Platform.getLayout() == "enLayout" ) then
	tLabelObjs[1]:setPosition(ccp(110, 89))
else
	tLabelObjs[1]:setPosition(ccp(92, 89))
end
 	bg_attr_ng:addChild(tLabelObjs[1])
 	_arrBaseValueObjs = tLabelObjs

 	-- 升级后级别属性差值（下一级值减去当前值）
 	local labelColor=ccc3(0, 0x6d, 0x2f)
 	local tLabels = {
 		{text=" ", fontsize=23, color=labelColor},
 		{text=" ", vOffset=32},
 		{text=" "},
 		{text=" "},
 	}
 	_arrLevelUpValueObjs = LuaCCLabel.createVerticalLabelHeelLabels(tLabels)
 	_arrLevelUpValueObjs[1]:setPosition(170, 88)
 	bg_attr_ng:addChild(_arrLevelUpValueObjs[1])

 	-- -- 天赋解锁
 	-- local tLabels = {{text=GetLocalizeStringBy("key_1720"), fontsize=23, color=ccc3(0x78, 0x25, 0),}}
 	-- local tLabelObjs = LuaCCLabel.createVerticalLabelHeelLabels(tLabels)
 	-- tLabelObjs[1]:setPosition(ccp(30, 50))
 	-- bg_attr_ng:addChild(tLabelObjs[1])

 	-- --  天赋技能数组
 	-- local labelColor=ccc3(0, 0x6d, 0x2f)
 	-- local tLabels = {
 	-- 	{text=" ", fontsize=23, color=labelColor},
 	-- 	{text=" ", vOffset=8},
 	-- }
 	-- _arrTalentUnlockObjs = LuaCCLabel.createVerticalLabelHeelLabels(tLabels)
 	-- _arrTalentUnlockObjs[1]:setPosition(ccp(140, 18))
 	-- bg_attr_ng:addChild(_arrTalentUnlockObjs[1])

 	return bg_attr_ng
end

-- 卡牌角色展示背景图片的
local _fHeroShowScale = 0.835	-- 370/443

-- 创建强化主显示面板
fnCreateStrenthenCardAndAttrPanel = function (layer)
	-- 背景图
	local fullRect = CCRectMake(0, 0, 75, 75)
    local insetRect = CCRectMake(30, 30, 15, 10)
	local bg_ng = CCScale9Sprite:create("images/common/bg/bg_ng_attr.png", fullRect, insetRect)
	local bgPreferredSize = CCSizeMake(600, 390)
	bg_ng:setPreferredSize(bgPreferredSize)
	bg_ng:setAnchorPoint(ccp(0.5, 0))
	bg_ng:setPosition(ccp(g_winSize.width/2, 0))
	bg_ng:setScale(_fElementScale)

	require "script/ui/hero/HeroPublicCC"
	local ccSpriteCardBG = HeroPublicCC.createSpriteCardShow(_tHeroAttr.htid, nil, _tHeroAttr.turned_id)
	_csCardShowBg = ccSpriteCardBG
	ccSpriteCardBG:setPosition(ccp(16, 6))
	ccSpriteCardBG:setScale(_fHeroShowScale)

	-- 卡牌角色展示
	local cardShowScrollView = CCScrollView:create()
-- 设置scrollview的container为角色展示背景
	cardShowScrollView:setContainer(ccSpriteCardBG)
-- 设置scrollview的显示区域为原始灰背景区域
	cardShowScrollView:setViewSize(bgPreferredSize)
	cardShowScrollView:setAnchorPoint(ccp(0, 0))
	cardShowScrollView:setBounceable(false)
	cardShowScrollView:setTouchEnabled(false)
	bg_ng:addChild(cardShowScrollView)

	-- 添加属性面板
	local attrPanel = fnCreateAttrPanel()
	bg_ng:addChild(attrPanel)

	return bg_ng
end

-- 卡牌强化显示内容
fnCreateCardStrengthenPanel = function ( ... )
	local layer = CCLayer:create()

	local menu = fnCreateButtonsOnCardStrengthenPanel()
	layer:addChild(menu)

-- 强化时银币与经验值交换数据层
	_ccSpriteExchangeInfo = fnAddExchangeInfoOnCardStrengthenPanel()
-- 武将选择层
	_ccSpriteSelectedHeroes = fnCreateSelectedHeroes()

	layer:addChild(_ccSpriteExchangeInfo)
	layer:addChild(_ccSpriteSelectedHeroes)

	_clItemOfNeeded = layer

	return layer
end

-- 将魂强化显示内容
fnCreateSoulStrengthenPanel = function ()
	local layer = CCLayer:create()

	-- 将魂强化的按钮menu
	local menu = fnCreateButtonsOnSoulStrengthenPanel()
	layer:addChild(menu)
	-- 
	-- 背景图(9宫格)
	local fullRect = CCRectMake(0, 0, 61, 47)
	local insetRect = CCRectMake(24, 16, 10, 4)
	local preferredSize = {width=568, height=146}
    local bg_ng = CCScale9Sprite:create("images/common/bg/white_text_ng.png", fullRect, insetRect)
	bg_ng:setPreferredSize(CCSizeMake(preferredSize.width, preferredSize.height))
	bg_ng:setScale(_fElementScale)
    bg_ng:setAnchorPoint(ccp(0.5, 0.5))
 	local y = _nYPosOfHeroAttr+(preferredSize.height-menu:getContentSize().height)*_fElementScale
    bg_ng:setPosition(g_winSize.width/2, y/2)
    layer:addChild(bg_ng)

 	-- 现有将魂
 	local tElements = {
 		{ctype=1, text=GetLocalizeStringBy("key_2560"), color=ccc3(0x78, 0x25, 0)},
 		{ctype=2, file="images/hero/strengthen/hero_soul.png",},
 		{ctype=1, text="0",color=ccc3(0, 0, 0), hOffset=11},
 	}
 	require "script/libs/LuaCC"
	_ccObjsCurrentSoul= LuaCC.createCCNodesOnHorizontalLine(tElements)
	_ccObjsCurrentSoul[1]:setPosition(ccp(20, 92))
	bg_ng:addChild(_ccObjsCurrentSoul[1])

	-- 消耗银币
	local tElements = {
 		{ctype=1, text=GetLocalizeStringBy("key_2115"), color=ccc3(0x78, 0x25, 0)},
 		{ctype=2, file="images/common/coin_silver.png",},
 		{ctype=1, text="0",color=ccc3(0, 0, 0), hOffset=6},
 	}
	_ccObjsCostSilver = LuaCC.createCCNodesOnHorizontalLine(tElements)
	_ccObjsCostSilver[1]:setPosition(ccp(20, 30))
	bg_ng:addChild(_ccObjsCostSilver[1])
	-- 升至下级需将魂
	local tElements = {
 		{ctype=1, text=GetLocalizeStringBy("key_2899"), color=ccc3(0x78, 0x25, 0)},
 		{ctype=2, file="images/hero/strengthen/hero_soul.png",},
 		{ctype=1, text="0",color=ccc3(0, 0, 0), hOffset=8},
 	}
	_ccObjsNextSoul = LuaCC.createCCNodesOnHorizontalLine(tElements)
	_ccObjsNextSoul[1]:setPosition(ccp(270, 92))
	bg_ng:addChild(_ccObjsNextSoul[1])
	-- 获得经验值
	local tElements = {
 		{ctype=1, text=GetLocalizeStringBy("key_2141"), color=ccc3(0x78, 0x25, 0)},
 		{ctype=1, text="0",color=ccc3(0, 0, 0), hOffset=4},
 	}
	_ccObjsGetExp = LuaCC.createCCNodesOnHorizontalLine(tElements)
	_ccObjsGetExp[1]:setPosition(ccp(270, 30))
	bg_ng:addChild(_ccObjsGetExp[1])

	fnUpdateSoulPanel()
	return layer
end

-- 更新武将强化武魂面板显示
function fnUpdateSoulPanel()
	-- 现有将魂：
	_ccObjsCurrentSoul[3]:setString(UserModel.getSoulNum())

	local tArgs = {}
	tArgs.exp_id = _tHeroAttr.exp_id
	tArgs.soul = _tHeroAttr.soul
	tArgs.level = _tHeroAttr.level
	tArgs.htid = _tHeroAttr.htid
	_nNextLevelNeedSoul = HeroPublicLua.getSoulToNextLevel(tArgs)
	-- 消耗银币：
	require "db/DB_Heroes"
	local db_hero = DB_Heroes.getDataById(_tHeroAttr.htid)
	local nCostCoin = math.floor(_nNextLevelNeedSoul * db_hero.lv_up_soul_coin_ratio / 100)
	_ccObjsCostSilver[3]:setString(nCostCoin)

	-- 升至下级需将魂：
--	local nNextLevelSoul = HeroPublicLua.getSoulToNextLevel(tArgs)
	_ccObjsNextSoul[3]:setString(_nNextLevelNeedSoul)

	-- 获得经验值
	_ccObjsGetExp[2]:setString(_nNextLevelNeedSoul)
	_crlHeroLevel:stopAllActions()
	if _nIndexOfTab == _nIndexOfSoulStrengthen then
		if _nNextLevelNeedSoul < UserModel.getSoulNum() then
			local action = actionOfLevel()
	     	_crlHeroLevel:runAction(action)
	     	_nHeroLevelAfterUp = _tHeroAttr.level+1
		 	fnShowActionOfAppendValues()
		 	fnAddProgressBar(_nNextLevelNeedSoul)
		else
			fnAddProgressBar(UserModel.getSoulNum())
		end
	end
end

function fnUpdateSoulActions()
	fnStopAllActions()
	_crlHeroLevel:stopAllActions()

	local tArgs = {}
	tArgs.exp_id = _tHeroAttr.exp_id
	tArgs.soul = _tHeroAttr.soul
	tArgs.level = _tHeroAttr.level
	_nNextLevelNeedSoul = HeroPublicLua.getSoulToNextLevel(tArgs)

	if _nIndexOfTab == _nIndexOfCardStrengthen then
--		_nHeroLevelAfterUp = _tHeroAttr.level + 1
		print("fnUpdateSoulActions 1")
		fnRenewHeroAttr(_tHeroAttr.level)
		return
	end
	if _nNextLevelNeedSoul < UserModel.getSoulNum() then
		local action = actionOfLevel()
		_crlHeroLevel:runAction(action)
		_nHeroLevelAfterUp = _tHeroAttr.level + 1
		print("fnUpdateSoulActions 2")
		fnRenewHeroAttr(_nHeroLevelAfterUp)
		fnShowActionOfAppendValues()
	end
end

-- 在选择武将界面退出后重新创建layer
function createLayerAfterSelectHero(tParam)
	local tArgs = {}
	if _tParentParam then
		tArgs = table.hcopy(_tParentParam, tArgs)
	end
	tArgs.selectedHeroes = tParam.selectedHeroes

	local layer = createLayer(nil, tArgs)
	fnUpdateCardSilverAndExp()

	return layer
end
-- 更新卡牌强化面板所显示的“获得经验值”及“消耗银币”方法
fnUpdateCardSilverAndExp = function ()
-- 计算被消耗卡牌的总武魂及对应所需要银币
	local nTotalExp = 0
	local nTotalCost=0

	if _arrSelectedHeroes then 
		for i=1, #_arrSelectedHeroes do
			local nHeroSoul = _arrSelectedHeroes[i].soul
			nTotalExp = nTotalExp + nHeroSoul
			nTotalCost=nTotalCost+nHeroSoul*_arrSelectedHeroes[i].lv_up_soul_coin_ratio/100
		end
	end
	nTotalCost = math.ceil(nTotalCost)
	_nTotalSilverCost = nTotalCost
-- 更新“获得经验值”标签文本
	_ccLabelExpNumCard:setString(nTotalExp)
-- 更新“消耗银币”标签文本
	_ccLabelSilverNumCard:setString(nTotalCost)
	local tArgs = {}
	tArgs.soul=_tHeroAttr.soul
	tArgs.added_soul=nTotalExp
	tArgs.exp_id=_tHeroAttr.exp_id
    local nLevelAfterAddSoul = HeroPublicLua.getHeroLevelByAddSoul(tArgs)

    if nLevelAfterAddSoul > _tHeroAttr.level then
    	fnRenewHeroAttr(nLevelAfterAddSoul)
    	local action = actionOfLevel()
    	_crlHeroLevel:runAction(action)
    	_nHeroLevelAfterUp = nLevelAfterAddSoul
		fnShowActionOfAppendValues()
		fnAddProgressBar(100000)
	else
		fnAddProgressBar(tArgs.added_soul)
		fnStopAllActions()
    end
end

function fnStopAllActions( ... )
	_crlHeroLevel:stopAllActions()
	_crlHeroLevel:setString(_tHeroAttr.level)
	_crlHeroLevel:setOpacity(255)
	
	fnStopActionOfAppendValues()
end

-- 更新武将属性值
function fnRenewHeroAttr(pNextLevel)
	if _addedLv <= 0 then
		return
	end
	print("fnRenewHeroAttr", pNextLevel)
	-- print(debug.traceback())
 	local heroInfo = HeroModel.getHeroByHid(_tHeroAttr.hid)
 	require "script/model/hero/FightForceModel"
 	local tFightForce = FightForceModel.getHeroDisplayAffixByHeroInfo(heroInfo)
 	
 	local nextHeroInfo = {}
 	table.hcopy(heroInfo, nextHeroInfo)
 	nextHeroInfo.level = (heroInfo.level) + 1
 	local tNextFightForce = FightForceModel.getHeroDisplayAffixByHeroInfo(nextHeroInfo)
	-- 必防数值
 	local magicDefend = {
 		current=tFightForce[AffixDef.MAGIC_DEFEND],
 		next=tNextFightForce[AffixDef.MAGIC_DEFEND],
 	}
 	-- 物防数值
 	local physicalDefend = {
 		current=tFightForce[AffixDef.PHYSICAL_DEFEND],
 		next=tNextFightForce[AffixDef.PHYSICAL_DEFEND],
 	}

 	local generalAttack = {}
 	generalAttack.current=tFightForce[AffixDef.GENERAL_ATTACK]
 	generalAttack.next=tNextFightForce[AffixDef.GENERAL_ATTACK]
 	-- 生命数值
 	local life = {
 		current=tFightForce[AffixDef.LIFE],
 		next=tNextFightForce[AffixDef.LIFE]
 	}
	local arrBaseValues = {magicDefend.current, physicalDefend.current, generalAttack.current, life.current}
 	local arrAppendValues = {" ", " ", " ", " "}

 	for i=1, #_arrBaseValueObjs do
 		_arrBaseValueObjs[i]:setString(math.floor(arrBaseValues[i]))
 	end
 	if pNextLevel > _tHeroAttr.level then
 		arrAppendValues = {
	 		magicDefend.next-magicDefend.current,
	 		physicalDefend.next-physicalDefend.current,
			generalAttack.next-generalAttack.current,
	 		life.next-life.current
 		}
 		for i=1, #_arrLevelUpValueObjs do
 			_arrLevelUpValueObjs[i]:setString("+"..math.floor(arrAppendValues[i]))
 		end
 	end

 	-- 清理天赋技能显示标签
 	-- for i=1, #_arrTalentUnlockObjs do
 	-- 	_arrTalentUnlockObjs[i]:setString("")
 	-- end
 	-- 显示天赋技能s
 	local arrGrowAwakeNames = {}
 	if  _tHeroAttr.grow_awake_id then
 		require "db/DB_Awake_ability"
 		local arrLevelAndIds = string.split(_tHeroAttr.grow_awake_id, ",")
 		for i=1, #arrLevelAndIds do
 			local level_id = string.split(arrLevelAndIds[i], "|")
 			if level_id and #level_id == 2 then
	 			local level = tonumber(level_id[1])
	 			local awake_id = level_id[2]
	 			if level > _tHeroAttr.level and level <= pNextLevel then
	 				table.insert(arrGrowAwakeNames, DB_Awake_ability.getDataById(awake_id).name)
	 			end
	 		end
 		end
 	end
 	-- local nMaxCount = #arrGrowAwakeNames
 	-- if nMaxCount > 2 then
 	-- 	nMaxCount = 2
 	-- end
 	-- for i=1, nMaxCount do
 	-- 	_arrTalentUnlockObjs[#_arrTalentUnlockObjs-i+1]:setString(arrGrowAwakeNames[i])
 	-- end
end

-- 为新手引导系统提供“武将强化”，”增加武将框“ 按钮对象
function getAddButtonForGuide()
	return _csAddHeroeButtons[1]
end

-- 为新手引导系统提供“卡牌强化”按钮对象
-- nType: 1 为“返回”
-- nType: 2 为“强化”
-- nType: 3 为“自动添加”	
function getCardStrengthenButtonForGuide(nType)
	local cmiObj
	local arrTag = {_ksTagButtonReturnOnCard, _ksTagButtonCardStrengthen, _ksTagButtonAutoAddOnCard}
	if _cmCardStrengthenPanel then
		cmiObj = tolua.cast(_cmCardStrengthenPanel:getChildByTag(arrTag[nType]), "CCMenuItem")
	end
	return cmiObj
end

-- 为新手引导系统提供“将魂强化”按钮对象
-- nType: 1 为“返回”
-- nType: 2 为“强化5次”
-- nType: 3 为“强化”
function getSoulStrengthenButtonForGuide(nType)
	local cmiObj
	local arrTag = {_ksTagButtonReturnOnSoul, _ksTagButtonSoulStrengthen5, _ksTagButtonSoulStrengthen}
	if _cmSoulStrengthenPanel then 
		local cmiObj = tolua.cast(_cmSoulStrengthenPanel:getChildByTag(arrTag[nType]), "CCMenuItem")
	end
	
	return cmiObj
end


