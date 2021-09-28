-- Filename: PurgatoryHeroInfoLayer.lua
-- Author: fang
-- Date: 2013-08-05
-- Purpose: 该文件用于: 武将系统，信息页面

module("PurgatoryHeroInfoLayer", package.seeall)

require "script/ui/tip/AnimationTip"
-- 标记是否从阵容中来
local _isFromFormation

-- 当前正在运行的层
local _onRunningLayer

-- 关闭按钮tag
local _ksTagCloseBtn=1001
-- 标题层
local _ccTitleLayer
-- 界面底部
local _ccBottomLayer
-- 武将信息层所占高度
local _heightOfHeroInfoLayer
-- 刨去底层及标题栏所占高度
local _heightWithoutTitleAndBottom
-- 当前英雄数值
local _tHeroValue
-- 来自父级界面的参数结构
local _tParentParam

-- 新手引导
-- “更换武将”按钮
local _cmiChangeHero
-- “强化”按钮
local _ccStrengthenButton

local changHeroCallbackFunc = nil    -- 跟换武将事件
local heroInfoLayerDidLoad  = nil

-- added by zhz
local _touchProperty = nil

local _isHaveUpFormation = nil

local _dressId =  nil

local _delegation= nil

local _downArrowSp         = nil
local _upArrowSp           = nil

local affixScrollView      = nil

local _isExtHero 		   = nil
local _zOrder 			   = nil


--------------------------------- added by bzx
local _bulletin_layer_is_visible
---------------------------------
--------------------------------- added by DJN
--用于“更换装备”界面返回按钮回调中，判断跳向的界面
-- local _jumpTag = nil
---------------------------------
-- 关闭按钮回调处理
local function fnCloseBtnHandler(tag, item_obj)
    ----------------------------------------- added by bzx
    BulletinLayer.getLayer():setVisible(_bulletin_layer_is_visible)
    -----------------------------------------
	-- 音效
	require "script/audio/AudioUtil"
	AudioUtil.playEffect("audio/effect/guanbi.mp3")
	if _tParentParam and _tParentParam.isPanel then
		_onRunningLayer:removeFromParentAndCleanup(true)
		if(_delegation) then
			_delegation()
		end
		return
	elseif _tParentParam and _tParentParam.needChangeFriend then
		_onRunningLayer:removeFromParentAndCleanup(true)
		MainScene.changeLayer(FormationLayer.createLayer(nil,false,true),"formationLayer")
		return
	elseif _tParentParam and _tParentParam.needChangeSecFriend then
		_onRunningLayer:removeFromParentAndCleanup(true)
		local laye = FormationLayer.createLayer(nil, false, nil, nil,nil,nil,true,_tParentParam.reserved2)
		MainScene.changeLayer(laye,"formationLayer")
		return
	end
	-- 进入武将layer
	require "script/ui/main/MainScene"
	if _tParentParam then
		MainScene.changeLayer(_tParentParam.fnCreate(_tParentParam.reserved, false), _tParentParam.sign)
	else
		require "script/ui/hero/HeroLayer"
		MainScene.getAvatarLayerObj():setVisible(true)
		MenuLayer.getObject():setVisible(true)
		MainScene.changeLayer(HeroLayer.createLayer(), "HeroLayer")
	end
end

-- 创建标题面板
local function createTitleLayer( ... )
	require "script/libs/LuaCCSprite"

	local tLabel={
		text=GetLocalizeStringBy("key_1671"),
		fontsize=35,
		sourceColor=ccc3(0xff, 0xf0, 0x49),
		targetColor=ccc3(0xff, 0xa2, 0),
		tag=_ksTagCloseBtn,
		stroke_size=2,
		stroke_color=ccc3(0, 0, 0),
		anchorPoint=ccp(0.5, 0.5)
	}
	local csTitleBg = LuaCCSprite.createSpriteWithRenderLabel("images/common/title_bg.png", tLabel)
	local ccMenu = CCMenu:create()
	local cmiButtonClose = CCMenuItemImage:create("images/common/btn_close_n.png", "images/common/btn_close_h.png")
	local tBgSize = csTitleBg:getContentSize()
	local tBtnSize = cmiButtonClose:getContentSize()
	cmiButtonClose:setAnchorPoint(ccp(1, 1))
	cmiButtonClose:setPosition(tBgSize.width+8, tBgSize.height+8)
	cmiButtonClose:registerScriptTapHandler(fnCloseBtnHandler)
	ccMenu:setPosition(0, 0)

	ccMenu:setTouchPriority(_touchProperty-7 or -777)
	ccMenu:addChild(cmiButtonClose)

	csTitleBg:addChild(ccMenu)

	return csTitleBg
end
-- 模块进入初始化
local function init( ... )
	_isFromFormation     = nil
	_cmiChangeHero		 = nil
	_ccStrengthenButton	 = nil
	_touchProperty 		 = nil
	_isExtHero 			 = nil
	_downArrowSp		 = nil
	_upArrowSp			 = nil
end

-- 创建英雄信息显示层, zOrder and touchPriority added by zhz
-- 既然页面要改版，那我就趁这个机会把这里写上必要的注释好了 added by Zhang Zihang
function createLayer(heroValue, tParam, zOrder, touchPriority, isHaveUpFormation, delegation, p_isExtHero)
	-- added by zhz
	init()
	_zOrder=zOrder or 1500
	_touchProperty = touchPriority or -700
	_isExtHero = p_isExtHero
	_tHeroValue = heroValue
	--print("heroValue:")
	--print_t(heroValue)
	if _tHeroValue.hid then
		local heroInfo 			= HeroModel.getHeroByHid(_tHeroValue.hid)
		printTable("heroInfo:",heroInfo)
	end


	_delegation= delegation

	_tParentParam = tParam
	_isHaveUpFormation = isHaveUpFormation

	--print("createLayer _isHaveUpFormation = ", heroValue, tParam, zOrder, touchPriority, isHaveUpFormation)
	local layer = CCLayer:create()
	-- 加载模块背景图
	local csBg = CCSprite:create("images/main/module_bg.png")
	csBg:setScale(g_fBgScaleRatio)
	layer:addChild(csBg)

	require "script/ui/main/BulletinLayer"
	require "script/ui/main/MainScene"
	require "script/ui/main/MenuLayer"
    -------------------------------------------- added by bzx
    _bulletin_layer_is_visible = BulletinLayer.getLayer():isVisible()
    --------------------------------------------
    BulletinLayer.getLayer():setVisible(true)
	local bulletinLayerSize = BulletinLayer.getLayerContentSize()

	-- 隐藏avatar层
	local ccObjAvatar = MainScene.getAvatarLayerObj()
	if not (tParam and tParam.isPanel) then
		ccObjAvatar:setVisible(false)
		MenuLayer.getObject():setVisible(false)
	end

	-- 创建界面底部元素
	-- 底下的那些按钮
	local bottom_layer = createBottomPanel()
	local bottomSize = bottom_layer:getContentSize()
	bottom_layer:setPosition(ccp(0, 0))

	local layerRect = {}
	layerRect.width = g_winSize.width
	layerRect.height = g_winSize.height - bulletinLayerSize.height*g_fScaleX
	layer:setContentSize(CCSizeMake(layerRect.width, layerRect.height))
	layer:setPosition(ccp(0, 0))

	-- 标题栏层
	-- 标题和关闭按钮那里
	local ccTitleLayer = createTitleLayer()
	local titleSize = ccTitleLayer:getContentSize()
	ccTitleLayer:setScale(g_fScaleX)
	ccTitleLayer:setPosition(ccp(0, layerRect.height-titleSize.height*g_fScaleX))
	-- 加入标题元素
	layer:addChild(ccTitleLayer, 10, -1)

	-- 内容区的实际高度
	local bgHeight = layerRect.height - ccTitleLayer:getContentSize().height*g_fScaleX

	-- 背景九宫格图
	local fullRect = CCRectMake(0, 0, 196, 198)
    local insetRect = CCRectMake(61, 80, 46, 36)
    local ccStarSellBG = CCScale9Sprite:create("images/hero/bg_ng.png", fullRect, insetRect)
    local preferredSize = {w=g_winSize.width, h = bgHeight+ccTitleLayer:getContentSize().height/2}
    ccStarSellBG:setPreferredSize(CCSizeMake(preferredSize.w, preferredSize.h))
	ccStarSellBG:setPosition(ccp(0, 0))
    layer:addChild(ccStarSellBG)

	local sizeOfHeroContent={width=g_winSize.width, height=bgHeight-(bottomSize.height-11)*g_fScaleX}

	-------------------------------------------------------------------------------------------------
	--主要内容的入口在这里 fnCreateDetailContentLayer 函数
	--好隐蔽的说
	-------------------------------------------------------------------------------------------------
	local detailContentLayer, nHeight=fnCreateDetailContentLayer(sizeOfHeroContent)
	detailContentLayer:setPosition(ccp(0, (bottomSize.height-11)*g_fScaleX))
	layer:addChild(detailContentLayer)

	-- 加入界面底部元素
	layer:addChild(bottom_layer, 10, -1)

	_onRunningLayer = layer

	if tParam and tParam.isPanel then
		csBg:setPosition(0, layerRect.height)
		csBg:setAnchorPoint(ccp(0, 1))
		local runningScene = CCDirector:sharedDirector():getRunningScene()
		_onRunningLayer:setTouchPriority(_touchProperty)
		_onRunningLayer:setTouchEnabled(true)
		local function onTouches(event, x, y)
			return true
		end
		_onRunningLayer:registerScriptTouchHandler(onTouches, false, _touchProperty, true)
		runningScene:addChild(_onRunningLayer, _zOrder, 1000)
	end
	if(heroInfoLayerDidLoad ~= nil) then
		heroInfoLayerDidLoad()
	end

	return layer
end


fnCreateDetailContentLayer = function (viewSize)
	local contentScrollView = CCScrollView:create()
	contentScrollView:setTouchPriority(_touchProperty-3 or -703)
	contentScrollView:setViewSize(CCSizeMake(viewSize.width, viewSize.height+16))
	contentScrollView:setDirection(kCCScrollViewDirectionVertical)
	local layer = CCLayer:create()
	contentScrollView:setContainer(layer)

	local x=640/2
	local y=0
	local yOffset=8

	require "script/libs/LuaCC"
	require "script/libs/LuaCCLabel"
	require "script/libs/LuaCCSprite"
	require "db/DB_Heroes"
	require "db/skill"
	require "script/model/hero/HeroModel"

	-- 简介
	local ccLayerIntroduction, nHeight = fnCreateIntroductionPanel()
	ccLayerIntroduction:setPosition(ccp(x, y))
	ccLayerIntroduction:setAnchorPoint(ccp(0.5, 0))
	layer:addChild(ccLayerIntroduction)
	y = y + nHeight + yOffset

	-- 觉醒
	if(_tHeroValue.hid ~= nil and HeroModel.isNecessaryHero(_tHeroValue.htid) == false) then
		local ccSpriteAwaken, nHeight = fnCreateAwakenPanel()
		ccSpriteAwaken:setPosition(ccp(x, y))
		ccSpriteAwaken:setAnchorPoint(ccp(0.5, 0))
		layer:addChild(ccSpriteAwaken)
		y = y + nHeight + yOffset
	end
	-- 天赋
	local ccSpriteTalent, nHeight = fnCreateTalentPanel()
	ccSpriteTalent:setPosition(ccp(x, y))
	ccSpriteTalent:setAnchorPoint(ccp(0.5, 0))
	layer:addChild(ccSpriteTalent)
	y = y + nHeight + yOffset

	-- 羁绊
	local ccSpriteUnion, nHeight = fnCreateUnionPanel()
	if ccSpriteUnion then
		ccSpriteUnion:setPosition(ccp(x, y))
		ccSpriteUnion:setAnchorPoint(ccp(0.5, 0))
		layer:addChild(ccSpriteUnion)
		y = y + nHeight + yOffset
	end
	-- 技能
	local ccSpriteSkill, nHeight = fnCreateSkillPanel()
	ccSpriteSkill:setPosition(ccp(x, y))
	ccSpriteSkill:setAnchorPoint(ccp(0.5, 0))
	layer:addChild(ccSpriteSkill)
	y = y + nHeight + yOffset

	---------------------------------------------------------------------新代码-----------------------------------------------
	--以下是新版的内容
	-------------------------------------------------------------------------------------
	-- 属性 武将三维
	local ccSpriteProperty,nHeight = fnCreatePropertyPanel()
	ccSpriteProperty:setPosition(ccp(x,y))
	ccSpriteProperty:setAnchorPoint(ccp(0.5,0))
	layer:addChild(ccSpriteProperty)
	y = y + nHeight + yOffset
	-------------------------------------------------------------------------------------

	--------------------------------------------背景------------------------
	local infoBgSprite = CCSprite:create("images/hero/info_bg.png")
	infoBgSprite:setAnchorPoint(ccp(0.5,0))
	infoBgSprite:setPosition(ccp(x,y))
	layer:addChild(infoBgSprite)
	y = y + infoBgSprite:getContentSize().height + yOffset

	--------------------------------------------创建名字、国家------------------------
	local db_hero = DB_Heroes.getDataById(_tHeroValue.htid)

	--武将全身图
	local image_file = "images/base/hero/body_img/"..db_hero.body_img_id
	local dressId = _tHeroValue.dressId
	if(dressId and tonumber(dressId) > 0) then
		require "db/DB_Item_dress"
		require "script/model/utils/HeroUtil"
		local dressInfo = DB_Item_dress.getDataById(dressId)
		local genderId = HeroModel.getSex(_tHeroValue.htid)

		local dressImg =  HeroUtil.getStringByFashionString(dressInfo.changeBodyImg,genderId)
		if(dressImg) then
			image_file = "images/base/hero/body_img/" .. dressImg
		end
	end

	-- local yOffset = 0
	-- if db_hero.body_img_id == "shi_jiang_zhangbao.png" then
	-- 	yOffset = 177
	-- elseif db_hero.body_img_id == "shi_jiang_caocao.png" then
	-- 	yOffset = 32
	-- end
	require "script/ui/hero/HeroPublicCC"

	local yOffset = HeroPublicCC.getYOffset(db_hero.body_img_id)

	-- 全身像偏移量
	local offset = HeroUtil.getHeroBodySpriteOffsetByHTID(_tHeroValue.htid, dressId)

	local ccSpriteCardShow = CCSprite:create(image_file)
	ccSpriteCardShow:setPosition(infoBgSprite:getContentSize().width/2,60 - yOffset - offset)
	ccSpriteCardShow:setAnchorPoint(ccp(0.5,0))
	infoBgSprite:addChild(ccSpriteCardShow)

	local nameBgSprite = CCScale9Sprite:create("images/common/bg/bg_9s_2.png")
	nameBgSprite:setPreferredSize(CCSizeMake(280,40))
	nameBgSprite:setAnchorPoint(ccp(0.5,0))
	nameBgSprite:setPosition(ccp(infoBgSprite:getContentSize().width/2,20))
	infoBgSprite:addChild(nameBgSprite)

	--名字
	local nameNode = {}
	nameNode[1] = CCRenderLabel:create(_tHeroValue.name,g_sFontPangWa,25,2,ccc3(0, 0, 0),type_stroke)
	nameNode[1]:setColor(HeroPublicLua.getCCColorByStarLevel(_tHeroValue.star_lv))
	if _tHeroValue.evolve_level and tonumber(_tHeroValue.evolve_level) > 0 then
		if(_tHeroValue.star_lv > 5) then
			nameNode[2] = LuaCC.createNumberSprite02("images/hero/transfer/numbers", _tHeroValue.evolve_level)
			nameNode[3] = CCRenderLabel:create(GetLocalizeStringBy("zzh_1159"), g_sFontPangWa, 25, 2, ccc3(0, 0, 0), type_stroke)
			nameNode[3]:setColor(ccc3(60, 239, 21))
		else
			nameNode[2] = CCSprite:create("images/hero/transfer/numbers/add.png")
			nameNode[3] = LuaCC.createNumberSprite02("images/hero/transfer/numbers", _tHeroValue.evolve_level)
		end
	end
	local nameAndEvolve = BaseUI.createHorizontalNode(nameNode)
	nameAndEvolve:setAnchorPoint(ccp(0.5,0.5))
	nameAndEvolve:setPosition(nameBgSprite:getContentSize().width/2,nameBgSprite:getContentSize().height/2)
	nameBgSprite:addChild(nameAndEvolve)

	--国家
	require "script/model/hero/HeroModel"
	local country_icon = HeroModel.getLargeCiconByCidAndlevel(db_hero.country, db_hero.star_lv)
	local ccSpriteCountry = CCSprite:create(country_icon)
	ccSpriteCountry:setAnchorPoint(ccp(0.5,1))
	ccSpriteCountry:setPosition(ccp(0,nameBgSprite:getContentSize().height))
	nameBgSprite:addChild(ccSpriteCountry)

	--------------------------------------------等级、资质------------------------
	--等级
	local lvSprite = CCSprite:create("images/common/lv.png")
	local lvLabel = CCRenderLabel:create(_tHeroValue.level,g_sFontPangWa,22,1,ccc3(0,0,0),type_stroke)
	lvLabel:setColor(ccc3(0xff,0xf6,0x00))

	local lvNode = BaseUI.createHorizontalNode({lvSprite,lvLabel})
 	lvNode:setAnchorPoint(ccp(1,0))
 	lvNode:setPosition(ccp(infoBgSprite:getContentSize().width/2 - 5,65))
 	infoBgSprite:addChild(lvNode)

 	--资质
 	local ccSpriteFightValue = CCSprite:create("images/hero/potential.png")
 	ccSpriteFightValue:setScale(28/38)
	local db_hero = DB_Heroes.getDataById(_tHeroValue.htid)
 	local sFightValue = _tHeroValue.heroQuality
 	if _tHeroValue.heroQuality == nil then
 		sFightValue = db_hero.heroQuality
 	end

 	local ccLabelFightValue = CCRenderLabel:create(sFightValue, g_sFontPangWa,22,1,ccc3(0, 0, 0),type_stroke)
 	ccLabelFightValue:setColor(ccc3(0xff,0x00,0))

 	local qualityLabel = BaseUI.createHorizontalNode({ccSpriteFightValue,ccLabelFightValue})
 	qualityLabel:setAnchorPoint(ccp(0,0))
 	qualityLabel:setPosition(ccp(infoBgSprite:getContentSize().width/2 + 5,65))
 	infoBgSprite:addChild(qualityLabel)

 	--名将
	if db_hero.beauty_id then
		local csFamous = CCSprite:create("images/hero/famous.png")
		csFamous:setAnchorPoint(ccp(0.5,0))
		csFamous:setPosition(infoBgSprite:getContentSize().width - 115, 130)
		infoBgSprite:addChild(csFamous)
	end

	--星星
	-- 星星底
	local starsBgSp = CCSprite:create("images/formation/stars_bg.png")
	starsBgSp:setAnchorPoint(ccp(0.5, 1))
	starsBgSp:setPosition(ccp(infoBgSprite:getContentSize().width/2,infoBgSprite:getContentSize().height - 10))
	infoBgSprite:addChild(starsBgSp)

	-- 星星们
	local starsXPositions = {0.5, 0.4, 0.6, 0.3, 0.7, 0.2, 0.8}
	local starsYPositions = {0.75, 0.74, 0.74, 0.71, 0.71, 0.68, 0.68}
	local starsXPositionsDouble = {0.45,0.55,0.35,0.65,0.25,0.75,0.8}
    local starsYPositionsDouble = {0.745,0.745,0.72,0.72,0.7,0.7,0.68}

	for k = 1 ,db_hero.star_lv do
		local starSprite = CCSprite:create("images/formation/star.png")
		starSprite:setAnchorPoint(ccp(0.5, 0.5))
		if ((db_hero.star_lv%2) ~= 0) then
			starSprite:setPosition(ccp(starsBgSp:getContentSize().width * starsXPositions[k], starsBgSp:getContentSize().height * starsYPositions[k]))
		else
			starSprite:setPosition(ccp(starsBgSp:getContentSize().width * starsXPositionsDouble[k], starsBgSp:getContentSize().height * starsYPositionsDouble[k]))
		end
		starsBgSp:addChild(starSprite)
	end

	local heroType = tonumber(db_hero.herotype)
	if heroType ~= nil then
		local typeSprite = HeroUtil.createHeroTypeSprite(heroType)
        typeSprite:setAnchorPoint(ccp(0,1))
        typeSprite:setPosition(ccp(40,infoBgSprite:getContentSize().height))
        infoBgSprite:addChild(typeSprite)
	end

	------------------------------------------------------要返回的数据------------------------------------------------
	-- 设置container的坐标
	layer:setPosition(0, viewSize.height-y*g_fScaleX)
	layer:setContentSize(CCSizeMake(g_winSize.width, y))
	layer:setScale(g_fScaleX)

	return contentScrollView, y
end

--[[
	@des 	:创建武将属性显示区域
	@param 	:
	@return :创建好的区域
	@return :区域的高度
--]]
function fnCreatePropertyPanel()
	local fullRect = CCRectMake(0, 0, 61, 47)
    local insetRect = CCRectMake(24, 16, 10, 4)
    local preferredSize={width=604, height=150}
	local bg_attr_ng = CCScale9Sprite:create("images/common/bg/white_text_ng.png", fullRect, insetRect)
	bg_attr_ng:setPreferredSize(CCSizeMake(preferredSize.width, preferredSize.height))

	local tLabel={text=GetLocalizeStringBy("key_1141"), fontsize=25, color=ccc3(0, 0, 0)}
	local ccSpriteTitle = LuaCC.createSpriteWithLabel("images/hero/info/title_bg.png", tLabel)
	ccSpriteTitle:setAnchorPoint(ccp(0,0.5))
	ccSpriteTitle:setPosition(ccp(-5, bg_attr_ng:getContentSize().height))
	bg_attr_ng:addChild(ccSpriteTitle)

	------------------------------------------------统帅、武力、智慧-----------------------------------------------------------
	-- 统帅、武力、智慧
	local tLabels = {
 		{text=GetLocalizeStringBy("key_2739"), fontsize=25, color=ccc3(0x78, 0x25, 0)},
 		{text=GetLocalizeStringBy("key_3340"), vOffset=15},
 		{text=GetLocalizeStringBy("key_1090")},
 	}

 	local height_1 = 20

 	local tLabelObjs = LuaCCLabel.createVerticalLabelHeelLabels(tLabels)
 	tLabelObjs[1]:setPosition(ccp(30, height_1))
 	bg_attr_ng:addChild(tLabelObjs[1])

 	local sMagicDefend
 	local sMagicAttack
 	local sGeneralAttack
 	local sPhysicalDefend
 	local sPhysicalAttack
 	local sHeroLife
 	require "script/ui/hero/HeroFightSimple"
 	require "script/ui/hero/HeroFightForce"
 	-- 如果武将没有hid，则表示为武魂数据
 	local tForceValue
 	-- 简单战斗力
 	local tForceValue02
 	require "script/model/hero/FightForceModel"
 	require "script/model/affix/AffixDef"


 	if _tHeroValue.hid then
		tForceValue = FightForceModel.getHeroDisplayAffix(_tHeroValue.hid)
		sPhysicalDefend=tForceValue[AffixDef.PHYSICAL_DEFEND]
		sHeroLife=tForceValue[AffixDef.LIFE]
		sMagicDefend=tForceValue[AffixDef.MAGIC_DEFEND]
		sGeneralAttack=tForceValue[AffixDef.GENERAL_ATTACK]
 	else
 		tForceValue02 = HeroFightSimple.getAllForceValues(_tHeroValue)
 		sMagicDefend=tForceValue02.magicDefend
 		sGeneralAttack=tForceValue02.generalAttack
 		sPhysicalDefend=tForceValue02.physicalDefend
 		sHeroLife=tForceValue02.life
 	end

 	local tLabels = {}
 	if tForceValue then
	 	table.insert(tLabels, {text=tForceValue[AffixDef.INTELLIGENCE], fontsize=25})
	 	table.insert(tLabels, {text=tForceValue[AffixDef.STRENGTH], vOffset=15})
	 	table.insert(tLabels, {text=tForceValue[AffixDef.COMMAND]})
 	else
	 	table.insert(tLabels, {text=tForceValue02.intelligence, fontsize=25})
	 	table.insert(tLabels, {text=tForceValue02.strength, vOffset=15})
	 	table.insert(tLabels, {text=tForceValue02.command})
 	end
 	local tLabelObjs = LuaCCLabel.createVerticalLabelHeelLabels(tLabels)
 	--兼容泰国版
 	--added by Zhang Zihang
 	if(Platform.getPlatformFlag() == "ios_thailand" or Platform.getPlatformFlag() == "Android_taiguo" )then
 		tLabelObjs[1]:setPosition(ccp(105, height_1))
 	else
 		tLabelObjs[1]:setPosition(ccp(90, height_1))
 	end

 	bg_attr_ng:addChild(tLabelObjs[1])

 	---------------------------------------------------------生命、攻击、物防、法防--------------------------------------
 	-- 基础属性值
 	local tLabels = {
 		{text=GetLocalizeStringBy("key_3032"), fontsize=22, color=ccc3(0x78, 0x25, 0)},
 		{text=GetLocalizeStringBy("key_3033"), vOffset=6.5},
		{text=GetLocalizeStringBy("key_1649")},
 		{text=GetLocalizeStringBy("key_1877")},
 	}

 	local height_2 = 20
 	local addX = 200

 	local tLabelObjs = LuaCCLabel.createVerticalLabelHeelLabels(tLabels)
 	tLabelObjs[1]:setPosition(ccp(30+addX, height_2))
 	bg_attr_ng:addChild(tLabelObjs[1])

 	local tLabels = {
 		-- 法防值
 		{text=sMagicDefend, fontsize=22},
 		-- 物防值
 		{text=sPhysicalDefend, vOffset=6.5},
		-- 攻击值
 		{text=sGeneralAttack},
 		-- 生命值
 		{text=sHeroLife},
 	}
 	local tLabelObjs = LuaCCLabel.createVerticalLabelHeelLabels(tLabels)
 	--兼容泰国版
 	--added by Zhang Zihang
 	if(Platform.getPlatformFlag() == "ios_thailand" or Platform.getPlatformFlag() == "Android_taiguo" )then
 		tLabelObjs[1]:setPosition(ccp(105+addX, height_2))
 	else
 		tLabelObjs[1]:setPosition(ccp(90+addX, height_2))
 	end

 	bg_attr_ng:addChild(tLabelObjs[1])

 	----------------------------------------------------------战魂按钮----------------------------------------------------
 	local menu = BTMenu:create(true)
	menu:setPosition(ccp(0, 0))
	menu:setAnchorPoint(ccp(0, 0))
	menu:setTouchPriority(_touchProperty-1)
	--menu:setScrollView(contentScrollView)
	bg_attr_ng:addChild(menu)

	--local checkFightSoulButton = LuaCC.create9ScaleMenuItem("images/common/btn/btn_violet_n.png","images/common/btn/btn_violet_h.png",CCSizeMake(200, 55),GetLocalizeStringBy("lcy_50109"),ccc3(0xfe, 0xdb, 0x1c),25,g_sFontPangWa,1, ccc3(0x00, 0x00, 0x00))
	local checkFightSoulButton = CCMenuItemImage:create("images/common/btn/btn_violet_n.png", "images/common/btn/btn_violet_h.png")
	checkFightSoulButton:setPosition(ccp(450, 50))
	checkFightSoulButton:registerScriptTapHandler(checkFightSoulButtonCallback)
	menu:addChild(checkFightSoulButton)

	local checkFightSoulButtonLabel = CCRenderLabel:create(GetLocalizeStringBy("lcy_50109"), g_sFontPangWa, 22, 1, ccc3( 0x00, 0x00, 0x00), type_stroke)
	checkFightSoulButtonLabel:setColor(ccc3(239, 239, 50))
	checkFightSoulButtonLabel:setPosition(ccpsprite(0.5, 0.5, checkFightSoulButton))
	checkFightSoulButtonLabel:setAnchorPoint(ccp(0.5, 0.5))
	checkFightSoulButton:addChild(checkFightSoulButtonLabel)

    if(_isExtHero) then
    	checkFightSoulButton:setVisible(false)
    end

 	----------------------------------------------------------返回页面高度使用---------------------------------------------

	local nRealHeight = bg_attr_ng:getContentSize().height + ccSpriteTitle:getContentSize().height/2

	return bg_attr_ng,nRealHeight
end

-- 创建“简介”区域
fnCreateIntroductionPanel = function ()
	local tLabel={text=GetLocalizeStringBy("key_2371"), fontsize=25, color=ccc3(0, 0, 0)}
	local ccSpriteTitle = LuaCC.createSpriteWithLabel("images/hero/info/title_bg.png", tLabel)

	-- 九宫格图片原始九宫信息
	local fullRect = CCRectMake(0, 0, 61, 47)
    local insetRect = CCRectMake(24, 16, 10, 4)
    local preferredSize={width=604, height=120}
    -- 九宫格期望高度
	local bg_attr_ng = CCScale9Sprite:create("images/common/bg/white_text_ng.png", fullRect, insetRect)

	local db_hero = DB_Heroes.getDataById(_tHeroValue.htid)
	-- 武将描述信息
	local sHeroDesc = "        "
	if db_hero.desc then
		sHeroDesc = sHeroDesc .. db_hero.desc
	end
	local ccLabelDesc = LuaCCLabel.createMultiLineLabel({text=sHeroDesc, fontsize=22, color=ccc3(0x78, 0x25, 0), width=580})
	local x = 14
	local yOffset = 14
	local y = yOffset
	y = y + ccLabelDesc:getContentSize().height
	ccLabelDesc:setAnchorPoint(ccp(0, 1))
	ccLabelDesc:setPosition(x, y)
	bg_attr_ng:addChild(ccLabelDesc)
	-- 计算标题实际高度
	local nPreferredHeight = y + (yOffset + ccSpriteTitle:getContentSize().height)/2
	bg_attr_ng:addChild(ccSpriteTitle)
	-- 定位标题
	ccSpriteTitle:setPosition(ccp(-5, nPreferredHeight))
	ccSpriteTitle:setAnchorPoint(ccp(0, 0.5))

	bg_attr_ng:setPreferredSize(CCSizeMake(preferredSize.width, nPreferredHeight))
	local nRealHeight = nPreferredHeight + ccSpriteTitle:getContentSize().height/2

	return bg_attr_ng, nRealHeight
end


-- 创建“技能”区域面板
fnCreateSkillPanel = function ()
	local tLabel={text=GetLocalizeStringBy("key_1084"), fontsize=25, color=ccc3(0, 0, 0)}
	local ccSpriteTitle = LuaCC.createSpriteWithLabel("images/hero/info/title_bg.png", tLabel)

	-- cocos2d-x控件，是个二维数组 行x列.
	local ccObjs = {}
	local fullRect = CCRectMake(0, 0, 61, 47)
    local insetRect = CCRectMake(24, 16, 10, 4)
    local preferredSize={width=604, height=120}
	local bg_attr_ng = CCScale9Sprite:create("images/common/bg/white_text_ng.png", fullRect, insetRect)

	local db_hero = DB_Heroes.getDataById(_tHeroValue.htid)
	local normalSkill = skill.getDataById(db_hero.normal_attack)
	local rageSkill = skill.getDataById(db_hero.rage_skill_attack)

	--主角更换技能需要
	--added by Zhang Zihang
	--如果是主角
	require "script/model/user/UserModel"
	if HeroModel.isNecessaryHero(_tHeroValue.htid) and tostring(_tHeroValue.name) == UserModel.getUserName() then
	-- if _tHeroValue.isAvatar and (_tHeroValue.isAvatar == true) then
		-- require "script/ui/replaceSkill/ReplaceSkillData"
		--如果技能改变了
		-- if tonumber(ReplaceSkillData.getChangeSkillInfo()) ~= 0 then
		-- 	rageSkill = skill.getDataById(tonumber(ReplaceSkillData.getChangeSkillInfo()))
		-- 	normalSkill = skill.getDataById(tonumber(ReplaceSkillData.getNormalSkillInfo()))
		-- end
		rageSkill = skill.getDataById(UserModel.getUserRageSkill())
		normalSkill = skill.getDataById(UserModel.getUserNormalSkill())
	end

	if _tHeroValue.attack_skill ~= nil then
		normalSkill = skill.getDataById(_tHeroValue.attack_skill)
	end

	if _tHeroValue.rage_skill ~= nil then
		rageSkill = skill.getDataById(_tHeroValue.rage_skill)
	end

	-- 同一行中的
	local tLabel = {text=GetLocalizeStringBy("key_2064"), color=ccc3(255, 255, 255), fontsize=25, tag=101}
	local ccSpriteAnger = LuaCCSprite.createSpriteWithLabel("images/hero/info/anger.png", tLabel)
	local sSkillName = rageSkill.name or ""
	local ccLabelSkill=CCLabelTTF:create(sSkillName.." ", g_sFontName, 22)
	ccLabelSkill:setColor(ccc3(0x85, 0, 0x7a))

	local nVarWidth = 542-ccLabelSkill:getContentSize().width
	local tLabel={text=rageSkill.des, width=nVarWidth,}
	-- 下面多行文本显示测试
	-- text="对敌方横排目标造成伤害，并有概率眩晕目标--敬个礼，握个手，你是我的好朋友, , 对敌方横排目标造成伤害，并有概率眩晕目标一回会。敬个礼，握个手，你是我的好朋友",

	local ccLabelDesc = LuaCCLabel.createMultiLineLabel(tLabel)
	ccObjs[#ccObjs+1] = {}
	table.insert(ccObjs[#ccObjs], ccSpriteAnger)
	table.insert(ccObjs[#ccObjs], ccLabelSkill)
	table.insert(ccObjs[#ccObjs], ccLabelDesc)

	-- 同一行中的
	local tLabel = {text=GetLocalizeStringBy("key_1129"), color=ccc3(0xff, 0xff, 0xff), fontsize=25, tag=101}
	local ccSpriteNormal = LuaCCSprite.createSpriteWithLabel("images/hero/info/normal.png", tLabel)
	local skillName = normalSkill.name or ""
	local ccLabelSkill=CCLabelTTF:create(skillName.." ", g_sFontName, 22)
	ccLabelSkill:setColor(ccc3(0x85, 0, 0x7a))

	local nVarWidth = 542-ccLabelSkill:getContentSize().width
	local ccLabelDesc = LuaCCLabel.createMultiLineLabel({text=normalSkill.des, width=nVarWidth})
	ccObjs[#ccObjs+1] = {}
	table.insert(ccObjs[#ccObjs], ccSpriteNormal)
	table.insert(ccObjs[#ccObjs], ccLabelSkill)
	table.insert(ccObjs[#ccObjs], ccLabelDesc)

	local x=10
	local nHeightOfPanel = 10
	local nMaxHeightOnSameLine = 0

 	local arrCount = table.maxn(ccObjs)
 	for i=1, arrCount do
 		nMaxHeightOnSameLine = 0
 		x = 10
 		local objsLine = ccObjs[i]
 		local nHeight02 = objsLine[2]:getContentSize().height
 		local nHeight03 = objsLine[3]:getContentSize().height
 		for k=1, table.maxn(objsLine) do
 			if nMaxHeightOnSameLine < objsLine[k]:getContentSize().height then
 				nMaxHeightOnSameLine = objsLine[k]:getContentSize().height
 			end
			bg_attr_ng:addChild(objsLine[k])
 		end
 		local xOffset=10
 		if nHeight03 > nHeight02 then
 			local sizes = {}
 			for k=1, table.maxn(objsLine) do
 				sizes[k] = objsLine[k]:getContentSize()
 			end
 			objsLine[1]:setPosition(x, nHeightOfPanel + nHeight03 - sizes[1].height+((sizes[1].height-sizes[2].height)/2))
 			x = x + sizes[1].width
 			objsLine[2]:setPosition(x+xOffset, nHeightOfPanel + nHeight03 - sizes[2].height)
 			x = x + sizes[2].width
 			objsLine[3]:setPosition(x+xOffset, nHeightOfPanel + nHeight03)
 			nHeightOfPanel = nHeightOfPanel + 6
 		else
 			local tCCNodes = {}
			for k=1, table.maxn(objsLine) do
				table.insert(tCCNodes, {ccObj=objsLine[k]})
			end
			tCCNodes[2].xOffset=10
 			objsLine[1]:setPosition(x, nHeightOfPanel)
 			LuaCC.hAlignCCNodesAsFirst(tCCNodes)
 		end

 		nHeightOfPanel = nHeightOfPanel + nMaxHeightOnSameLine + 4
 	end
 	nHeightOfPanel = nHeightOfPanel+4

	-- 设置9宫格实际高度
	nHeightOfPanel = nHeightOfPanel + ccSpriteTitle:getContentSize().height/2
	preferredSize.height = nHeightOfPanel
	bg_attr_ng:setPreferredSize(CCSizeMake(preferredSize.width, preferredSize.height))
	bg_attr_ng:addChild(ccSpriteTitle)
	-- 定位标题
	ccSpriteTitle:setPosition(ccp(-5, preferredSize.height))
	ccSpriteTitle:setAnchorPoint(ccp(0, 0.5))

	local nHeightOfSkillArea = nHeightOfPanel + ccSpriteTitle:getContentSize().height/2

	return bg_attr_ng, nHeightOfSkillArea
end

-- 创建“天赋”区域面板
fnCreateTalentPanel = function ()
	local tLabel={text=GetLocalizeStringBy("key_2640"), fontsize=25, color=ccc3(0, 0, 0)}
	local ccSpriteTitle = LuaCC.createSpriteWithLabel("images/hero/info/title_bg.png", tLabel)

	-- 九宫格图片原始九宫信息
	local fullRect = CCRectMake(0, 0, 61, 47)
    local insetRect = CCRectMake(24, 16, 10, 4)
    local preferredSize={width=604, height=120}
    -- 九宫格期望高度
	local bg_attr_ng = CCScale9Sprite:create("images/common/bg/white_text_ng.png", fullRect, insetRect)

	local db_hero = DB_Heroes.getDataById(_tHeroValue.htid)
	local arrAwakeId = nil
	if db_hero.awake_id then
		arrAwakeId = string.split(db_hero.awake_id, ",")
	end
	local arrGrowAwakeId = nil
	if db_hero.grow_awake_id then
		arrGrowAwakeId = string.split(db_hero.grow_awake_id, ",")
	end


	require "db/DB_Awake_ability"
	-- 如果存在天赋ID
	local tAwakes = {}
	if arrAwakeId then
		for i=1, #arrAwakeId do
			tAwakes[#tAwakes+1] = {}
			local awake =  tAwakes[#tAwakes]
			awake.id = arrAwakeId[i]
			awake.evolve_level = 0
			awake.level = 0
		end
	end
	if arrGrowAwakeId then
		for i=1, #arrGrowAwakeId do
			tAwakes[#tAwakes+1] = {}
			local awake =  tAwakes[#tAwakes]
			local levelAndId = string.split(arrGrowAwakeId[i], "|")
			local awkae_type = tonumber(levelAndId[1])
			if awkae_type == 1 then
				awake.id = tonumber(levelAndId[3])
				awake.level = tonumber(levelAndId[2])
				awake.evolve_level = 0
			elseif awkae_type == 2 then
				awake.id = tonumber(levelAndId[3])
				awake.evolve_level = tonumber(levelAndId[2])
				awake.level = 0
			end
		end
	end

	local ccObjs = {}
	for i=1, #tAwakes do
		local v = tAwakes[i]
		local data = DB_Awake_ability.getDataById(v.id)
		local labelColor01 = ccc3(0xff, 0, 0)
		local labelColor02 = ccc3(0x78, 0x25, 0)

		local bLowLevel=false
		local bLowerEvolveLevel=false
		--print("_tHeroValue.level", _tHeroValue.level)
		--print("v.level", v.level)
		if _tHeroValue.evolve_level == nil then
			bLowLevel = true
		elseif tonumber(_tHeroValue.level) < v.level then
			bLowLevel = true
		end
		if _tHeroValue.evolve_level == nil then
			bLowerEvolveLevel = true
		elseif not bLowLevel and tonumber(_tHeroValue.evolve_level) < v.evolve_level then
			bLowerEvolveLevel = true
		end
		if bLowLevel or bLowerEvolveLevel then
			labelColor01 = ccc3(0x50, 0x50, 0x50)
			labelColor02 = ccc3(0x50, 0x50, 0x50)
		end

		ccObjs[#ccObjs+1] = {}
		local ccObj01 = CCLabelTTF:create(data.name, g_sFontName, 22)
		ccObj01:setAnchorPoint(ccp(0, 1))
		ccObj01:setColor(labelColor01)
		local ccObj02
		local richTextInfo = {}
		richTextInfo.width = 500 - ccObj01:getContentSize().width
		if bLowLevel and v.level > 0 then
			richTextInfo[2] = {content=data.des, ntype="label", color=labelColor02}
			richTextInfo[1] = {content=GetLocalizeStringBy("key_2162")..v.level..GetLocalizeStringBy("key_1066"), ntype="label", color=ccc3(0xff, 128,0)}
			ccObj02 = LuaCCLabel.createRichText(richTextInfo)
		elseif bLowerEvolveLevel then

			richTextInfo[2] = {content=data.des, ntype="label", color=labelColor02}
			local contentText = GetLocalizeStringBy("key_1648")
			if(tonumber(_tHeroValue.star_lv) > 5) then
				contentText =GetLocalizeStringBy("lcy_50112")
			end
			richTextInfo[1] = {content=contentText..v.evolve_level..GetLocalizeStringBy("key_1066"), ntype="label", color=ccc3(0xff, 128,0)}
			ccObj02 = LuaCCLabel.createRichText(richTextInfo)
		else
			richTextInfo[1] = {content=data.des, ntype="label", color=labelColor02}
			ccObj02 = LuaCCLabel.createRichText(richTextInfo)
		end
		table.insert(ccObjs[#ccObjs], ccObj01)
		table.insert(ccObjs[#ccObjs], ccObj02)
	end

	-- 如果武将没有天赋则显示“该武将没有天赋”标签
	if #ccObjs==0 then
		local ccObj01 = CCLabelTTF:create(GetLocalizeStringBy("key_2510"), g_sFontName, 22)
		ccObj01:setColor(ccc3(0x78, 0x25, 0))
		local ccObj02 = CCLabelTTF:create("  ", g_sFontName, 22)
		ccObj02:setColor(ccc3(0x78, 0x25, 0))
		ccObjs[#ccObjs+1] = {}
		ccObj01:setAnchorPoint(ccp(0, 1))
		ccObj02:setAnchorPoint(ccp(0, 1))
		table.insert(ccObjs[#ccObjs], ccObj01)
		table.insert(ccObjs[#ccObjs], ccObj02)
	end
	local tSorted = table.reverse(ccObjs)
	ccObjs = tSorted
	local x=60
	local nHeightOfPanel = 10
	local nMaxHeightOnSameLine = 0

 	local arrCount = table.maxn(ccObjs)
 	for i=1, arrCount do
 		nMaxHeightOnSameLine = 0
 		local objsLine = ccObjs[i]
 		local nHeight02 = objsLine[1]:getContentSize().height
 		local nHeight03 = objsLine[2]:getContentSize().height
 		for k=1, table.maxn(objsLine) do
 			if nMaxHeightOnSameLine < objsLine[k]:getContentSize().height then
 				nMaxHeightOnSameLine = objsLine[k]:getContentSize().height
 			end
			bg_attr_ng:addChild(objsLine[k])
 		end
 		local xOffset=10
 		x=60
 		if nHeight03 > nHeight02 then
 			local sizes = {}
 			for k=1, table.maxn(objsLine) do
 				sizes[k] = objsLine[k]:getContentSize()
 			end
 			objsLine[1]:setPosition(x, nHeightOfPanel+ nHeight03) -- sizes[1].height)
 			x = x + sizes[1].width
 			objsLine[2]:setPosition(x+xOffset, nHeightOfPanel + nHeight03)
 		else
 			local tCCNodes = {}
			for k=1, table.maxn(objsLine) do
				table.insert(tCCNodes, {ccObj=objsLine[k]})
			end
			tCCNodes[2].xOffset=10
 			objsLine[1]:setPosition(x, nHeightOfPanel+nHeight02)
 			LuaCC.hAlignCCNodesAsFirst(tCCNodes)
 		end

 		nHeightOfPanel = nHeightOfPanel + nMaxHeightOnSameLine + 4
 	end
	--
 	nHeightOfPanel = nHeightOfPanel+4

	-- 设置9宫格实际高度
	nHeightOfPanel = nHeightOfPanel + ccSpriteTitle:getContentSize().height/2
	preferredSize.height = nHeightOfPanel
	bg_attr_ng:setPreferredSize(CCSizeMake(preferredSize.width, preferredSize.height))
	bg_attr_ng:addChild(ccSpriteTitle)
	-- 定位标题
	ccSpriteTitle:setPosition(ccp(-5, preferredSize.height))
	ccSpriteTitle:setAnchorPoint(ccp(0, 0.5))

	local nRealHeight = nHeightOfPanel + ccSpriteTitle:getContentSize().height/2

	return bg_attr_ng, nRealHeight
end


-- 创建“觉醒”区域面板
function fnCreateAwakenPanel ()
	local tLabel={text=GetLocalizeStringBy("lcy_1001"), fontsize=25, color=ccc3(0, 0, 0)} --觉醒
	local ccSpriteTitle = LuaCC.createSpriteWithLabel("images/hero/info/title_bg.png", tLabel)

	-- 九宫格图片原始九宫信息
	local fullRect = CCRectMake(0, 0, 61, 47)
    local insetRect = CCRectMake(24, 16, 10, 4)
    local preferredSize={width=604, height=120}
    -- 九宫格期望高度
	local bg_attr_ng = CCScale9Sprite:create("images/common/bg/white_text_ng.png", fullRect, insetRect)

	local db_hero = DB_Heroes.getDataById(_tHeroValue.htid)
	local arrAwakeId = nil
	if db_hero.awake_id then
		arrAwakeId = string.split(db_hero.awake_id, ",")
	end
	local arrGrowAwakeId = nil
	if db_hero.grow_awake_id then
		arrGrowAwakeId = string.split(db_hero.grow_awake_id, ",")
	end


	require "db/DB_Awake_ability"
	-- 如果存在天赋ID
	local tAwakes = {}
	if arrAwakeId then
		for i=1, #arrAwakeId do
			tAwakes[#tAwakes+1] = {}
			local awake =  tAwakes[#tAwakes]
			awake.id = arrAwakeId[i]
		end
	end
	if arrGrowAwakeId then
		for i=1, #arrGrowAwakeId do
			tAwakes[#tAwakes+1] = {}
			local awake =  tAwakes[#tAwakes]
			local levelAndId = string.split(arrGrowAwakeId[i], "|")
			local awkae_type = tonumber(levelAndId[1])
			if awkae_type == 1 then
				awake.id = tonumber(levelAndId[3])
				awake.level = tonumber(levelAndId[2])
				awake.evolve_level = 0
			elseif awkae_type == 2 then
				awake.id = tonumber(levelAndId[3])
				awake.evolve_level = tonumber(levelAndId[2])
				awake.level = 0
			end
		end
	end

	local ccObjs = {}

	--查询武将第七天赋
	-- added by zhz :下面两行是有朱华智修改的
	---[[当前版本不上
	local db_hero = DB_Heroes.getDataById(tonumber( _tHeroValue.htid))
	--print(" _tHeroValue.hid  is : ", _tHeroValue.hid)
	if(_tHeroValue.hid ~= nil and tonumber(db_hero.star_lv) >= 5) then
		local hero_copy_id 		= DB_Heroes.getDataById(_tHeroValue.htid).hero_copy_id
		local hero_copy_talent 	= string.split(hero_copy_id, ",")
		for i=1,#hero_copy_talent do
			local hero_copy_id_info = hero_copy_talent[i]
			local heroInfo 			= HeroModel.getHeroByHid(_tHeroValue.hid)
			local sevenTalentText 	= nil
			local talentNameText 	= nil
			local cColorGreen 		= ccc3(0, 0x6d, 0x2f)
			-- 去掉武将列传Id判断，heroes表修改 20160407 lgx
			local evolveLevel 		= tonumber(string.split(hero_copy_id_info,"|")[2])
			local isSealed 			= false
			if(heroInfo["talent"]["sealed"] ~= nil and heroInfo["talent"]["sealed"][tostring(i)] ~= nil and heroInfo["talent"]["sealed"][tostring(i)] ~= 0) then
				isSealed = true
			end
			--print("Test Hero Info:")
			--print_t(heroInfo)
			--print("_tHeroValue:")
			--print_table("_tHeroValue:",_tHeroValue)

			--print("evolveLevel:",evolveLevel)
			require "script/ui/star/StarUtil"
			require "db/DB_Hero_refreshgift"
			local labelColor        = ccc3(96,96,96)
			local name_color = ccc3(255, 255, 255)


			if(HeroModel.isNecessaryHeroByHid(_tHeroValue.hid) == false) then
				if(tonumber(_tHeroValue.evolve_level) < evolveLevel
					and StarUtil.isHeroCopyPassed(_tHeroValue.htid, i) == true
					and heroInfo["talent"]["confirmed"][tostring(i)] == nil
					and isSealed == false) then
					sevenTalentText		= GetLocalizeStringBy("key_2441").. (evolveLevel or 7) .. GetLocalizeStringBy("key_3265")
					talentNameText 		= GetLocalizeStringBy("lcy_" .. tostring(1001 + i))
				elseif(tonumber(_tHeroValue.evolve_level) >= evolveLevel
					and StarUtil.isHeroCopyPassed(_tHeroValue.htid, i) == false
					and heroInfo["talent"]["confirmed"][tostring(i)] == nil
					and isSealed == false) then
					sevenTalentText		= GetLocalizeStringBy("lcy_" .. tostring(1007 + i))
					talentNameText 		= GetLocalizeStringBy("lcy_" .. tostring(1001 + i))
				elseif(tonumber(_tHeroValue.evolve_level) < evolveLevel
					and StarUtil.isHeroCopyPassed(_tHeroValue.htid, i) == false
					and heroInfo["talent"]["confirmed"][tostring(i)] == nil
					and isSealed == false) then
					sevenTalentText		= GetLocalizeStringBy("key_2441").. (evolveLevel or 7) ..GetLocalizeStringBy("lcy_" .. tostring(1004 + i))
					talentNameText 		= GetLocalizeStringBy("lcy_" .. tostring(1001 + i))
				else
					if(isSealed == false and heroInfo["talent"] ~= nil
						and heroInfo["talent"]["confirmed"][tostring(i)] ~= nil
						and tonumber(heroInfo["talent"]["confirmed"][tostring(i)]) ~= 0
						and tonumber(_tHeroValue.evolve_level) >= evolveLevel) then
						--如果通过了武将列传并且武将进阶等级满足能力开启等级
						local talentId  	= heroInfo["talent"]["confirmed"][tostring(i)]
						local talentInfo 	= DB_Hero_refreshgift.getDataById(talentId)
						sevenTalentText		= talentInfo.des
						talentNameText		= talentInfo.name
						labelColor 			= ccc3(0x78,0x25,0x00)
				      	require "script/ui/biography/ComprehendLayer"
				        name_color = ComprehendLayer.getNameColorByStar(talentInfo.level)
				    elseif(isSealed == false and heroInfo["talent"] ~= nil
						and heroInfo["talent"]["confirmed"][tostring(i)] ~= nil
						and tonumber(heroInfo["talent"]["confirmed"][tostring(i)]) ~= 0
						and tonumber(_tHeroValue.evolve_level) < evolveLevel) then
						--如果通过了武将列传并且武将进阶等级不满足能力开启等级
						local talentId  	= heroInfo["talent"]["confirmed"][tostring(i)]
						local talentInfo 	= DB_Hero_refreshgift.getDataById(talentId)
						sevenTalentText		= talentInfo.des .. GetLocalizeStringBy("lcyx_1921", evolveLevel)
						talentNameText		= talentInfo.name
						labelColor 			= ccc3(100,100,100)
						name_color			= ccc3(255,255,255)
				      	-- require "script/ui/biography/ComprehendLayer"
				       --  name_color = ComprehendLayer.getNameColorByStar(talentInfo.level)
					elseif(isSealed == true and heroInfo["talent"]["confirmed"][tostring(i)] ~= nil and tonumber(heroInfo["talent"]["confirmed"][tostring(i)]) ~= 0) then
						local talentId  	= heroInfo["talent"]["confirmed"][tostring(i)]
						local talentInfo 	= DB_Hero_refreshgift.getDataById(talentId)
						sevenTalentText		= talentInfo.des .. GetLocalizeStringBy("lcy_" .. tostring(50097+i))
						talentNameText		= talentInfo.name
						-- labelColor 			= ccc3(0x78,0x25,0x00)
					else
						sevenTalentText		= GetLocalizeStringBy("key_1605")
						talentNameText 		= GetLocalizeStringBy("lcy_" .. tostring(1001 + i))
					end
				end
				-- local nameLabel = CCLabelTTF:create(talentNameText, g_sFontName, 22)
				local nameLabel = CCRenderLabel:create( talentNameText, g_sFontName, 22, 1, ccc3( 0x00, 0x00, 0x00), type_stroke)
				nameLabel:setAnchorPoint(ccp(0, 1))
				nameLabel:setColor(name_color)

				local sevenTalentTextInfo = {{content=sevenTalentText, ntype="label", color=labelColor, tag=1001}}
				sevenTalentTextInfo.width = 420
				--print_t(sevenTalentTextInfo)
				local desLabel = LuaCCLabel.createRichText(sevenTalentTextInfo)
				-- local tempLabel = tolua.cast(desLabel:getChildByTag(1001) , "CCLabelTTF")
				-- tempLabel:setHorizontalAlignment(kCCTextAlignmentLeft)

				ccObjs[#ccObjs+1] = {}
				table.insert(ccObjs[#ccObjs], nameLabel)
				table.insert(ccObjs[#ccObjs], desLabel)
			end
		end
	end

	--print("lichenyang test ccObjs:")
	--print_t(ccObjs)
	--]]
	-- 如果武将没有天赋则显示“该武将没有天赋”标签
	if #ccObjs==0 then
		local ccObj01 = CCLabelTTF:create(GetLocalizeStringBy("key_2510"), g_sFontName, 22)
		ccObj01:setColor(ccc3(0x78, 0x25, 0))
		local ccObj02 = CCLabelTTF:create("  ", g_sFontName, 22)
		ccObj02:setColor(ccc3(0x78, 0x25, 0))
		ccObjs[#ccObjs+1] = {}
		ccObj01:setAnchorPoint(ccp(0, 1))
		ccObj02:setAnchorPoint(ccp(0, 1))
		table.insert(ccObjs[#ccObjs], ccObj01)
		table.insert(ccObjs[#ccObjs], ccObj02)
	end
	local tSorted = table.reverse(ccObjs)
	ccObjs = tSorted
	local x=60
	local nHeightOfPanel = 10
	local nMaxHeightOnSameLine = 0

 	local arrCount = table.maxn(ccObjs)
 	for i=1, arrCount do
 		nMaxHeightOnSameLine = 0
 		local objsLine = ccObjs[i]
 		local nHeight02 = objsLine[1]:getContentSize().height
 		local nHeight03 = objsLine[2]:getContentSize().height
 		for k=1, table.maxn(objsLine) do
 			if nMaxHeightOnSameLine < objsLine[k]:getContentSize().height then
 				nMaxHeightOnSameLine = objsLine[k]:getContentSize().height
 			end
			bg_attr_ng:addChild(objsLine[k])
 		end
 		local xOffset=10
 		x=60
 		if nHeight03 > nHeight02 then
 			local sizes = {}
 			for k=1, table.maxn(objsLine) do
 				sizes[k] = objsLine[k]:getContentSize()
 			end
 			objsLine[1]:setPosition(x, nHeightOfPanel+ nHeight03) -- sizes[1].height)
 			x = x + sizes[1].width
 			objsLine[2]:setPosition(x+xOffset, nHeightOfPanel + nHeight03)
 		else
 			local tCCNodes = {}
			for k=1, table.maxn(objsLine) do
				table.insert(tCCNodes, {ccObj=objsLine[k]})
			end
			tCCNodes[2].xOffset=10
 			objsLine[1]:setPosition(x, nHeightOfPanel+nHeight02)
 			LuaCC.hAlignCCNodesAsFirst(tCCNodes)
 		end

 		nHeightOfPanel = nHeightOfPanel + nMaxHeightOnSameLine + 4
 	end
	--
 	nHeightOfPanel = nHeightOfPanel+4

	-- 设置9宫格实际高度
	nHeightOfPanel = nHeightOfPanel + ccSpriteTitle:getContentSize().height/2
	preferredSize.height = nHeightOfPanel
	bg_attr_ng:setPreferredSize(CCSizeMake(preferredSize.width, preferredSize.height))
	bg_attr_ng:addChild(ccSpriteTitle)
	-- 定位标题
	ccSpriteTitle:setPosition(ccp(-5, preferredSize.height))
	ccSpriteTitle:setAnchorPoint(ccp(0, 0.5))

	local nRealHeight = nHeightOfPanel + ccSpriteTitle:getContentSize().height/2

	return bg_attr_ng, nRealHeight
end

-- 创建“羁绊”区域面板
fnCreateUnionPanel = function ()
	-- 检测数据有效性
	-- 连携属性ID组(字符串)
	require "db/DB_Heroes"
	local heroBaseHtid = DB_Heroes.getDataById(_tHeroValue.htid).model_id
	local tDB = DB_Heroes.getDataById(_tHeroValue.htid)
	local sLinkIDs = tDB.link_group1
	-- 连携属性ID组(Lua表数组结构)
	local tArrLinkIDs
	if sLinkIDs == nil then
		tArrLinkIDs = {}
	else
		tArrLinkIDs = string.split(sLinkIDs, ",")
	end
	local tLabel={text=GetLocalizeStringBy("key_3231"), fontsize=25, color=ccc3(0, 0, 0)}
	local ccSpriteTitle = LuaCC.createSpriteWithLabel("images/hero/info/title_bg.png", tLabel)

	-- 背景九宫格图
	local fullRect = CCRectMake(0, 0, 61, 47)
    local insetRect = CCRectMake(24, 16, 10, 4)
    local preferredSize={width=604, height=120}
	local bg_attr_ng = CCScale9Sprite:create("images/common/bg/white_text_ng.png", fullRect, insetRect)

	-- 三种显示颜色
	local cColorGray = ccc3(0x50, 0x50, 0x50)
	local cColorGreen = ccc3(0, 0x6d, 0x2f)
	local cColorYellow = ccc3(0x78, 0x25, 0)

	-- cocos2d-x控件，是个二维数组 行x列.
	local ccObjs = {}
	for i=1, #tArrLinkIDs do
		local tDB = DB_Union_profit.getDataById(tArrLinkIDs[i])
		--把方老师的判断羁绊方法删了，改用大一统的判断羁绊方法
		local bCondition = false

		if _tHeroValue.hid then
			bCondition = UnionProfitUtil.isHeroParticularUnionOpen(tArrLinkIDs[i],_tHeroValue.hid)
		end

		local color01 = cColorGreen
		local color02 = cColorYellow
		if not bCondition then
			color01 = cColorGray
			color02 = cColorGray
		end
		local ccLabelName=CCLabelTTF:create(tDB.union_arribute_name, g_sFontName, 22)
		ccLabelName:setColor(color01)
		local ccLabelDesc = LuaCCLabel.createMultiLineLabel({text=tDB.union_arribute_desc, color=color02, width=450})
		ccObjs[#ccObjs+1] = {}
		table.insert(ccObjs[#ccObjs], ccLabelName)
		table.insert(ccObjs[#ccObjs], ccLabelDesc)
	end
	if #ccObjs == 0 then
		local ccObj01=CCLabelTTF:create(GetLocalizeStringBy("key_1341"), g_sFontName, 22)
		ccObj01:setColor(cColorGreen)
		local ccObj02=CCLabelTTF:create(" ", g_sFontName, 22)
		ccObj02:setColor(ccc3(0, 0, 0))
		ccObjs[#ccObjs+1] = {}
		table.insert(ccObjs[#ccObjs], ccObj01)
		table.insert(ccObjs[#ccObjs], ccObj02)
	end

	local x=60
	local nHeightOfPanel = 10
	local nMaxHeightOnSameLine = 0

 	local arrCount = table.maxn(ccObjs)
 	for i=1, arrCount do
 		nMaxHeightOnSameLine = 0
 		local objsLine = ccObjs[arrCount-i+1]
 		local nHeight02 = objsLine[1]:getContentSize().height
 		local nHeight03 = objsLine[2]:getContentSize().height
 		for k=1, table.maxn(objsLine) do
 			if nMaxHeightOnSameLine < objsLine[k]:getContentSize().height then
 				nMaxHeightOnSameLine = objsLine[k]:getContentSize().height
 			end
			bg_attr_ng:addChild(objsLine[k])
 		end
 		local xOffset=10
 		x=60
 		if nHeight03 > nHeight02 then
 			local sizes = {}
 			for k=1, table.maxn(objsLine) do
 				sizes[k] = objsLine[k]:getContentSize()
 			end
 			objsLine[1]:setPosition(x, nHeightOfPanel+ nHeight03 - sizes[1].height)
 			x = x + sizes[1].width
 			objsLine[2]:setPosition(x+xOffset, nHeightOfPanel + nHeight03)
 		else
 			local tCCNodes = {}
			for k=1, table.maxn(objsLine) do
				table.insert(tCCNodes, {ccObj=objsLine[k]})
			end
			tCCNodes[2].xOffset=10
 			objsLine[1]:setPosition(x, nHeightOfPanel)
 			LuaCC.hAlignCCNodesAsFirst(tCCNodes)
 		end

 		nHeightOfPanel = nHeightOfPanel + nMaxHeightOnSameLine + 4
 	end
 	nHeightOfPanel = nHeightOfPanel+4

	-- 设置9宫格实际高度
	nHeightOfPanel = nHeightOfPanel + ccSpriteTitle:getContentSize().height/2
	preferredSize.height = nHeightOfPanel
	bg_attr_ng:setPreferredSize(CCSizeMake(preferredSize.width, preferredSize.height))
	bg_attr_ng:addChild(ccSpriteTitle)
	-- 定位标题
	ccSpriteTitle:setPosition(ccp(-5, preferredSize.height))
	ccSpriteTitle:setAnchorPoint(ccp(0, 0.5))

	local nHeightOfUnionArea = nHeightOfPanel + ccSpriteTitle:getContentSize().height/2

	return bg_attr_ng, nHeightOfUnionArea
end

-- “更换武将”按钮事件回调处理
local function fnHandlerOfChangeHero(tag, obj)
	-- 音效
	require "script/audio/AudioUtil"
	AudioUtil.playEffect("audio/effect/zhujiemian.mp3")
	if(changHeroCallbackFunc ~= nil) then
		changHeroCallbackFunc()
	end
	require "script/ui/formation/ChangeOfficerLayer"
	MainScene.changeLayer(ChangeOfficerLayer.createLayer(_tParentParam.reserved2, _tParentParam.reserved), "ChangeOfficerLayer")
end
-- “强化”按钮点击事件处理
local function fnHandlerOfStrengthenButton(tag, obj)
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
	_isFromFormation = true
	require "script/ui/hero/HeroStrengthenLayer"
	MainScene.changeLayer(HeroStrengthenLayer.createLayer(_tHeroValue), "ChangeOfficerLayer")

	---[==[ 等级礼包第15步 自动添加
        ---------------------新手引导---------------------------------
        --add by licong 2013.09.09
        require "script/guide/NewGuide"
        --print("g_guideClass = ", NewGuide.guideClass)
        require "script/guide/LevelGiftBagGuide"
        if(NewGuide.guideClass ==  ksGuideFiveLevelGift and LevelGiftBagGuide.stepNum == 14) then
            local levelGiftBagGuide_button = HeroStrengthenLayer.getCardStrengthenButtonForGuide(3)
            local touchRect = getSpriteScreenRect(levelGiftBagGuide_button)
            LevelGiftBagGuide.show(15, touchRect)
        end
        ---------------------end-------------------------------------
   	--]==]
end

local _ksTagChangeFriend = 5001
local _ksTagDown = 5002

-- 更换小伙伴回调处理
local function fnHandlerOfChangeFriend(tag, obj)
	require "script/audio/AudioUtil"
	AudioUtil.playEffect("audio/effect/zhujiemian.mp3")
	if tag == _ksTagChangeFriend then
		require "script/ui/formation/ChangeOfficerLayer"
		MainScene.changeLayer(ChangeOfficerLayer.createLayer(_tParentParam.reserved2, _tParentParam.reserved, true), "ChangeOfficerLayer")
	elseif tag ==  _ksTagDown then
		_tParentParam.fnCreate(_tParentParam.reserved, _tParentParam.reserved2)
	end
end

-- 更换助战军回调处理
local function fnHandlerOfChangeSecFriend(tag, obj)
	require "script/audio/AudioUtil"
	AudioUtil.playEffect("audio/effect/zhujiemian.mp3")
	if tag == _ksTagChangeFriend then
		require "script/ui/formation/ChangeOfficerLayer"
		MainScene.changeLayer(ChangeOfficerLayer.createLayer(_tParentParam.reserved2, _tParentParam.reserved, nil,true), "ChangeOfficerLayer")
	elseif tag ==  _ksTagDown then
		_tParentParam.fnCreate(_tParentParam.reserved, _tParentParam.reserved2)
	end
end

local function fnHandlerOfEvolve(tag, obj)
	-- 音效
	require "script/audio/AudioUtil"
	AudioUtil.playEffect("audio/effect/zhujiemian.mp3")

	require "script/ui/hero/HeroTransferLayer"
	local tArgs={selectedHeroes=_tHeroValue}
	tArgs.fnCreate = FormationLayer.createLayer
	tArgs.sign = _tParentParam.sign
	tArgs.reserved = _tParentParam.reserved

	tArgs.reserved2 = reserved2

	MainScene.changeLayer(HeroTransferLayer.createLayer(tArgs), "HeroTransferLayer")
end
-- 更换技能按钮回调 来自阵容 add by DJN
function fnHandlerOfFormation()
	require "script/audio/AudioUtil"
	AudioUtil.playEffect("audio/effect/zhujiemian.mp3")

	require "script/ui/replaceSkill/EquipmentLayer"
	_onRunningLayer:removeFromParentAndCleanup(true)
	local closeCb = function ( ... )
		require("script/ui/formation/FormationLayer")
        local formationLayer = FormationLayer.createLayer()
        MainScene.changeLayer(formationLayer, "formationLayer")
	end
	EquipmentLayer.showLayer(closeCb)
end
-- 更换技能按钮回调 来自武将 add by DJN
function fnHandlerOfHero()
		require "script/audio/AudioUtil"
	AudioUtil.playEffect("audio/effect/zhujiemian.mp3")

	require "script/ui/replaceSkill/EquipmentLayer"
	_onRunningLayer:removeFromParentAndCleanup(true)
	local closeCb = function ( ... )
		require "script/ui/hero/HeroLayer"
        MainScene.changeLayer(HeroLayer.createLayer(), "HeroLayer")
	end
	EquipmentLayer.showLayer(closeCb)
end

-- 创建底部按钮面板
function createBottomPanel( ... )
	local bg = CCSprite:create("images/common/sell_bottom.png")
	bg:setScale(g_fScaleX)
	local menu = CCMenu:create()
	bg:addChild(menu)
	menu:setTouchPriority( _touchProperty-1 or -701)
	menu:setPosition(ccp(0, 0))

	--领悟天赋按钮
	--- 领悟觉醒
	local talentButton = LuaCC.create9ScaleMenuItem("images/common/btn/btn_violet_n.png","images/common/btn/btn_violet_h.png", CCSizeMake(180,73), GetLocalizeStringBy("key_2522"), ccc3(255,222,0))
	talentButton:registerScriptTapHandler(talentButtonCallback)
	menu:addChild(talentButton)
	talentButton:setVisible(false)
	--当前武将是否可以领悟天赋
	local isAbleTalent = true

	-- 更换小伙伴

	if _tParentParam and _tParentParam.needChangeFriend then
		 -- 更换小伙伴
		local cs9miChangeFriend = LuaCC.create9ScaleMenuItem("images/common/btn/btn1_d.png","images/common/btn/btn1_n.png", CCSizeMake(210,73), GetLocalizeStringBy("key_2079"), ccc3(255,222,0))
		local y=8

		cs9miChangeFriend:setPosition(70, y)
		cs9miChangeFriend:registerScriptTapHandler(fnHandlerOfChangeFriend)
		menu:addChild(cs9miChangeFriend, 0, _ksTagChangeFriend)
        --卸下
		local cs9miDown = LuaCC.create9ScaleMenuItem("images/common/btn/btn1_d.png","images/common/btn/btn1_n.png", CCSizeMake(210,73), GetLocalizeStringBy("key_2592"), ccc3(255,222,0))
		cs9miDown:registerScriptTapHandler(fnHandlerOfChangeFriend)
		cs9miDown:setPosition(360, y)
		menu:addChild(cs9miDown, 0, _ksTagDown)
		return bg
	end


	-- 更换助战军
	if _tParentParam and _tParentParam.needChangeSecFriend then
		 -- 更换小伙伴
		local cs9miChangeFriend = LuaCC.create9ScaleMenuItem("images/common/btn/btn1_d.png","images/common/btn/btn1_n.png", CCSizeMake(210,73), GetLocalizeStringBy("lic_1496"), ccc3(255,222,0))
		local y=8

		cs9miChangeFriend:setPosition(70, y)
		cs9miChangeFriend:registerScriptTapHandler(fnHandlerOfChangeSecFriend)
		menu:addChild(cs9miChangeFriend, 0, _ksTagChangeFriend)
        --卸下
		local cs9miDown = LuaCC.create9ScaleMenuItem("images/common/btn/btn1_d.png","images/common/btn/btn1_n.png", CCSizeMake(210,73), GetLocalizeStringBy("key_2592"), ccc3(255,222,0))
		cs9miDown:registerScriptTapHandler(fnHandlerOfChangeSecFriend)
		cs9miDown:setPosition(360, y)
		menu:addChild(cs9miDown, 0, _ksTagDown)
		return bg
	end

	local y=8

	local isAvatar = HeroModel.isNecessaryHero(_tHeroValue.htid)
	if _tParentParam and _tParentParam.needChangeHeroBtn then
		if not isAvatar then
			if(isAbleTalent) then

				-- local bigBg = CCSprite:create("images/common/sell_bottom_big.png")
				-- bg:setTexture(bigBg:getTexture())
				-- bg:setTextureRect(CCRectMake(0,0,bigBg:getContentSize().width,bigBg:getContentSize().height))
	            --更换武将
				local ccBtnChangeHero = LuaCC.create9ScaleMenuItem("images/common/btn/btn1_d.png","images/common/btn/btn1_n.png", CCSizeMake(190,73), GetLocalizeStringBy("key_2278"), ccc3(255,222,0))
				_cmiChangeHero = ccBtnChangeHero
				ccBtnChangeHero:registerScriptTapHandler(fnHandlerOfChangeHero)
				menu:addChild(ccBtnChangeHero)

                --强化
				local ccStrengthenButton = LuaCC.create9ScaleMenuItem("images/common/btn/btn1_d.png","images/common/btn/btn1_n.png", CCSizeMake(150,73), GetLocalizeStringBy("key_1277"), ccc3(255,222,0))
				require "script/model/hero/HeroModel"
				_ccStrengthenButton = ccStrengthenButton
				ccStrengthenButton:registerScriptTapHandler(fnHandlerOfStrengthenButton)
				ccStrengthenButton:setPosition(430, y)
				menu:addChild(ccStrengthenButton)

                require "script/ui/develop/DevelopData"
                local ccBtnEvolve = nil
                if DevelopData.doOpenDevelopByHid(_tHeroValue.hid) then
                	--进化橙卡
                	ccBtnEvolve = CCMenuItemImage:create("images/develop/developup_btn_n.png","images/develop/developup_btn_h.png")
                	ccBtnEvolve:registerScriptTapHandler(tapCCBtnDevelopCb)
                	menu:addChild(ccBtnEvolve,1, _tHeroValue.hid)
                else
                	--进阶
					ccBtnEvolve = LuaCC.create9ScaleMenuItem("images/common/btn/btn1_d.png","images/common/btn/btn1_n.png", CCSizeMake(150,73), GetLocalizeStringBy("key_2325"), ccc3(255,222,0))
					ccBtnEvolve:registerScriptTapHandler(fnHandlerOfEvolve)
					menu:addChild(ccBtnEvolve)
				end

				--如果当前武将可以领悟天赋
				talentButton:setVisible(true)
				talentButton:setAnchorPoint(ccp(0.5,0.5))
				talentButton:setPosition(bg:getContentSize().width*0.41, bg:getContentSize().height*0.5)

				ccBtnEvolve:setAnchorPoint(ccp(0.5,0.5))
				ccBtnEvolve:setPosition(bg:getContentSize().width*0.665, bg:getContentSize().height*0.5)

				ccBtnChangeHero:setAnchorPoint(ccp(0.5,0.5))
				ccBtnChangeHero:setPosition(bg:getContentSize().width*0.135, bg:getContentSize().height*0.5)

				ccStrengthenButton:setAnchorPoint(ccp(0.5,0.5))
				ccStrengthenButton:setPosition(bg:getContentSize().width*0.89, bg:getContentSize().height*0.5)
			else

				--更换武将
				local ccBtnChangeHero = LuaCC.create9ScaleMenuItem("images/common/btn/btn1_d.png","images/common/btn/btn1_n.png", CCSizeMake(110,73), GetLocalizeStringBy("key_2278"), ccc3(255,222,0))
				_cmiChangeHero = ccBtnChangeHero
				ccBtnChangeHero:registerScriptTapHandler(fnHandlerOfChangeHero)
				menu:addChild(ccBtnChangeHero)
                --强化
				local ccStrengthenButton = LuaCC.create9ScaleMenuItem("images/common/btn/btn1_d.png","images/common/btn/btn1_n.png", CCSizeMake(190,73), GetLocalizeStringBy("key_1277"), ccc3(255,222,0))
				require "script/model/hero/HeroModel"
				ccBtnChangeHero:setPosition(20, y)
				_ccStrengthenButton = ccStrengthenButton
				ccStrengthenButton:registerScriptTapHandler(fnHandlerOfStrengthenButton)
				ccStrengthenButton:setPosition(430, y)
				menu:addChild(ccStrengthenButton)

                --进阶
				local ccBtnEvolve = LuaCC.create9ScaleMenuItem("images/common/btn/btn1_d.png","images/common/btn/btn1_n.png", CCSizeMake(190,73), GetLocalizeStringBy("key_2325"), ccc3(255,222,0))
				ccBtnEvolve:setPosition(225, y)
				ccBtnEvolve:registerScriptTapHandler(fnHandlerOfEvolve)
				menu:addChild(ccBtnEvolve)
			end

		else

            --进阶
			local ccBtnEvolve = LuaCC.create9ScaleMenuItem("images/common/btn/btn1_d.png","images/common/btn/btn1_n.png", CCSizeMake(160,73), GetLocalizeStringBy("key_2325"), ccc3(255,222,0))
			ccBtnEvolve:setPosition(ccp(bg:getContentSize().width *0.5-200, y))
			ccBtnEvolve:registerScriptTapHandler(fnHandlerOfEvolve)
			menu:addChild(ccBtnEvolve)

            ----------------------------------------------------------新增的更换技能按钮  add by DJN
			local ccBtnEquip = LuaCC.create9ScaleMenuItem("images/common/btn/btn1_d.png","images/common/btn/btn1_n.png", CCSizeMake(180,73), GetLocalizeStringBy("djn_30"), ccc3(255,222,0))
	        ccBtnEquip:setAnchorPoint(ccp(0.5, 0))
			ccBtnEquip:setPosition(ccp(bg:getContentSize().width *0.5+120, y))
		    ccBtnEquip:registerScriptTapHandler(fnHandlerOfFormation)
		    _jumpTag = 3
			menu:addChild(ccBtnEquip)
			--------------------------------------------------------------------------------------------------------------------------------------------------------------------------------

		end
	else
		if(_isHaveUpFormation == true) then
			-- local ccBtnClose = LuaCC.create9ScaleMenuItem("images/common/btn/btn1_d.png","images/common/btn/btn1_n.png", CCSizeMake(190,73), GetLocalizeStringBy("key_1951"), ccc3(255,222,0))
			-- ccBtnClose:registerScriptTapHandler(fnCloseBtnHandler)
			-- ccBtnClose:setPosition(bg:getContentSize().width * 0.75, y)
			-- ccBtnClose:setAnchorPoint(ccp(0.5, 0))
			-- menu:addChild(ccBtnClose)

			local btnTitle = GetLocalizeStringBy("key_1372")
			if _tHeroValue.isBusy then
				btnTitle = GetLocalizeStringBy("key_2278")
			end
            --上阵/更换武将
			local ccBtnChangeHero = LuaCC.create9ScaleMenuItem("images/common/btn/btn1_d.png","images/common/btn/btn1_n.png", CCSizeMake(190,73), btnTitle, ccc3(255,222,0))
			-- _cmiChangeHero = ccBtnChangeHero
			ccBtnChangeHero:registerScriptTapHandler(upFormationCallback)
			ccBtnChangeHero:setPosition(bg:getContentSize().width *0.5 - 100, y)
			ccBtnChangeHero:setAnchorPoint(ccp(0.5, 0))
			menu:addChild(ccBtnChangeHero)

			----------------------------------------------------------新增的更换技能按钮  add by DJN
			if(isAvatar)then
				local ccBtnEquip = LuaCC.create9ScaleMenuItem("images/common/btn/btn1_d.png","images/common/btn/btn1_n.png", CCSizeMake(180,73), GetLocalizeStringBy("djn_30"), ccc3(255,222,0))
	            ccBtnEquip:setAnchorPoint(ccp(0.5, 0))
			    ccBtnEquip:setPosition(ccp(bg:getContentSize().width *0.5+100, y))
				ccBtnEquip:registerScriptTapHandler(fnHandlerOfHero)
				--_jumpTag = 4
				menu:addChild(ccBtnEquip)
			end
            ----------------------------------------------------------------------------------------------------------------------------------------------------------------------------------
		-- else
		-- 	local ccBtnClose = LuaCC.create9ScaleMenuItem("images/common/btn/btn1_d.png","images/common/btn/btn1_n.png", CCSizeMake(190,73), GetLocalizeStringBy("key_1951"), ccc3(255,222,0))
		-- 	ccBtnClose:registerScriptTapHandler(fnCloseBtnHandler)
		-- 	ccBtnClose:setPosition((bg:getContentSize().width)/2, y)
		-- 	ccBtnClose:setAnchorPoint(ccp(0.5,0))
		-- 	menu:addChild(ccBtnClose)

			-- 只有在从武将进入并且武将star_Lv >= 5 时，才可以加锁和解锁
			local isAvatar = HeroModel.isNecessaryHero(_tHeroValue.htid)
			if( _tHeroValue.star_lv >= 5 and  not isAvatar and  _tHeroValue.hid ) then
				ccBtnChangeHero:setPosition(bg:getContentSize().width*0.25,y)

				--print("_tHeroValue.lock  is : ", _tHeroValue.lock)
                --武将解锁
				_ccLockedBtn = LuaCC.create9ScaleMenuItem("images/common/btn/btn1_d.png","images/common/btn/btn1_n.png", CCSizeMake(215,73), GetLocalizeStringBy("key_2998"), ccc3(255,222,0))
				_ccLockedBtn:registerScriptTapHandler(fnLockedHandler)
				_ccLockedBtn:setAnchorPoint(ccp(0.5,0))
				_ccLockedBtn:setPosition(bg:getContentSize().width*0.75, y)
				menu:addChild(_ccLockedBtn,1, _tHeroValue.hid)
				local goldIcon = CCSprite:create("images/hero/lock.png")
			    goldIcon:setAnchorPoint(ccp(1,0.5))
			    goldIcon:setPosition(_ccLockedBtn:getContentSize().width- 19,_ccLockedBtn:getContentSize().height/2)
			    _ccLockedBtn:addChild(goldIcon)
                --武将加锁
				_ccUnLockedBtn =LuaCC.create9ScaleMenuItem("images/common/btn/btn1_d.png","images/common/btn/btn1_n.png", CCSizeMake(215,73), GetLocalizeStringBy("key_1368"), ccc3(255,222,0))
				_ccUnLockedBtn:registerScriptTapHandler(fnUnLockedHandler)
				_ccUnLockedBtn:setPosition(bg:getContentSize().width*0.75, y)
				_ccUnLockedBtn:setAnchorPoint(ccp(0.5,0))
				menu:addChild(_ccUnLockedBtn,1, _tHeroValue.hid )
				local goldIcon = CCSprite:create("images/hero/unlock.png")
			    goldIcon:setAnchorPoint(ccp(1,0.5))
			    goldIcon:setPosition(_ccUnLockedBtn:getContentSize().width-19,_ccUnLockedBtn:getContentSize().height/2)
			    _ccUnLockedBtn:addChild(goldIcon)

				if(_tHeroValue.lock and tonumber(_tHeroValue.lock)== 1  ) then
					_ccLockedBtn:setVisible(true)
					_ccUnLockedBtn:setVisible(false)
				else
					_ccLockedBtn:setVisible(false)
					_ccUnLockedBtn:setVisible(true)
				end

				if(isAbleTalent) then
					--如果当前武将可以领悟天赋
					talentButton:setVisible(true)
					talentButton:setAnchorPoint(ccp(0.5,0.5))
					talentButton:setPosition(bg:getContentSize().width*0.483, bg:getContentSize().height*0.45)

					ccBtnChangeHero:setAnchorPoint(ccp(0.5, 0.5))
					ccBtnChangeHero:setPosition(bg:getContentSize().width*0.17, bg:getContentSize().height*0.45)

					_ccUnLockedBtn:setAnchorPoint(ccp(0.5, 0.5))
					_ccUnLockedBtn:setPosition(bg:getContentSize().width*0.82, bg:getContentSize().height*0.45)

					_ccLockedBtn:setAnchorPoint(ccp(0.5, 0.5))
					_ccLockedBtn:setPosition(bg:getContentSize().width*0.82, bg:getContentSize().height*0.45)
				end
			end



		else
			local label = CCLabelTTF:create(GetLocalizeStringBy("llp_226"),g_sFontName,20)
			label:setColor(ccc3(0x0C,0xFF,0x03))
			label:setAnchorPoint(ccp(0,0.5))
			bg:addChild(label)
			--返回
			local ccBtnClose = LuaCC.create9ScaleMenuItem("images/common/btn/btn1_d.png","images/common/btn/btn1_n.png", CCSizeMake(190,73), GetLocalizeStringBy("key_1951"), ccc3(255,222,0))
			ccBtnClose:registerScriptTapHandler(fnCloseBtnHandler)
			ccBtnClose:setPosition(bg:getContentSize().width * 0.5, y)
			ccBtnClose:setAnchorPoint(ccp(0.5, 0))
			menu:addChild(ccBtnClose)

			label:setPosition(ccp(bg:getContentSize().width * 0.5+ccBtnClose:getContentSize().width*0.5,y+ccBtnClose:getContentSize().height*0.5))

		end
	end

	--print("_isHaveUpFormation = ", _isHaveUpFormation)
	--print_t(_tHeroValue )


	return bg
end

function fnBackToFormation()
	if _isFromFormation then
		MainScene.changeLayer(_tParentParam.fnCreate(_tParentParam.reserved, false), _tParentParam.sign)
		_isFromFormation=nil
		return true
	end
	return false
end


-- 武将解锁的回调函数
function fnLockedHandler(tag, item )
	local hid= tonumber(tag)
	local args= CCArray:create()
	args:addObject(CCInteger:create(hid))
	Network.rpc(unlLockHeroCallbck, "hero.unlockHero" , "hero.unlockHero", args, true)
end

-- 武将加锁的回调函数
function fnUnLockedHandler( tag, item)
	local hid= tonumber(tag)
	local args= CCArray:create()
	args:addObject(CCInteger:create(hid))
	Network.rpc(lockHeroCallbck, "hero.lockHero" , "hero.lockHero", args, true)
end

-- 领悟天赋按钮回调
function talentButtonCallback( tag,item )
	-- body
	--print("talentButtonCallback hid:", _tHeroValue.hid)
	local hid = _tHeroValue.hid
	-------------------------------------------------- added by bzx
    require "script/ui/biography/ComprehendLayer"
    ComprehendLayer.show(hid,fnCloseBtnHandler, true)
    --------------------------------------------------
end

--------------------------------------------------[[网络回调函数]]--------------------------------------------------------------
--
function unlLockHeroCallbck(cbFlag, dictData, bRet)
	if(dictData.err ~= "ok" )then
	 	return
	end
	AnimationTip.showTip(GetLocalizeStringBy("key_2782"))
	HeroModel.setHeroLockStatusByHid( _tHeroValue.hid,0)
	_ccLockedBtn:setVisible(false)
	_ccUnLockedBtn:setVisible(true)

end


--
function lockHeroCallbck(cbFlag, dictData, bRet)
	if(dictData.err ~= "ok" )then
	 	return
	end
	AnimationTip.showTip(GetLocalizeStringBy("key_2548"))
	HeroModel.setHeroLockStatusByHid( _tHeroValue.hid,1 )
	_ccLockedBtn:setVisible(true)
	_ccUnLockedBtn:setVisible(false)

end

-- 新手引导
-- 获得“更换武将”按钮
function getChangeHeroButton( ... )
	return _cmiChangeHero
end
-- 新手引导
-- 获得“强化”按钮
function getStrengthenButton( ... )
	return _ccStrengthenButton
end

--add by lichenyang
function registerChangeHeroCallback( p_callback )
	changHeroCallbackFunc = p_callback
end

function registerHeroInfoLayerCallback( p_callback )
	heroInfoLayerDidLoad = p_callback
end

function upFormationCallback( ... )
	fnCloseBtnHandler()
	require("script/ui/formation/FormationLayer")
	local formationLayer = FormationLayer.createLayer(_tHeroValue.hid, false, false, true)
	MainScene.changeLayer(formationLayer, "formationLayer")
	require "script/ui/tip/AlertTip"
    AlertTip.showAlert(GetLocalizeStringBy("key_1995"), nil, false, nil)
end



function updateArrow( ... )
	local offset =  affixScrollView:getContentSize().height+ affixScrollView:getContentOffset().y- affixScrollView:getViewSize().height
	if(_upArrowSp~= nil )  then
		if(offset>1 or offset<-1) then
			_upArrowSp:setVisible(true)
		else
			_upArrowSp:setVisible(false)
		end
	end
	if(_downArrowSp ~= nil) then
		if( affixScrollView:getContentOffset().y ~=0) then
			_downArrowSp:setVisible(true)
		else
			_downArrowSp:setVisible(false)
		end
	end
end

-- 箭头的动画
function arrowAction( arrow)
	local arrActions_2 = CCArray:create()
	arrActions_2:addObject(CCFadeOut:create(1))
	arrActions_2:addObject(CCFadeIn:create(1))
	local sequence_2 = CCSequence:create(arrActions_2)
	local action_2 = CCRepeatForever:create(sequence_2)
	arrow:runAction(action_2)
end

--
function tapCCBtnDevelopCb( p_tag, p_item )
	require "script/ui/develop/DevelopLayer"
	DevelopLayer.showLayer(p_tag, DevelopLayer.kOldLayerTag.kFormationTag)
end
--[[
	@des: 查看战魂信息回调
--]]
function checkFightSoulButtonCallback( ... )
	require "script/ui/hero/FightSoulAttrDialog"
	FightSoulAttrDialog.showTip(_tHeroValue.htid,_tHeroValue.hid, _zOrder + 1000, _touchProperty-100)
end

