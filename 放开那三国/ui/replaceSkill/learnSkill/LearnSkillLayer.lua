-- Filename: LearnSkillLayer.lua
-- Author: zhangqiang
-- Date: 2014-08-21
-- Purpose: 创建选择学习技能界面

module("LearnSkillLayer", package.seeall)
require "script/model/utils/HeroUtil"
require "script/model/user/UserModel"
require "script/ui/star/StarSprite"
require "script/utils/LevelUpUtil"

--require "script/ui/replaceSkill/ReplaceSkillData"


-- local kMidUIContentSize = CCSizeMake(640, g_winSize.height/g_fScaleX-BulletinLayer.getLayerHeight()
-- 	                                 -MenuLayer.getLayerContentSize().height)
local kMidUIContentSize = CCSizeMake(640, g_winSize.height/g_fScaleX-146)
local kMainLayerTouchPriority = -300
local kMenuTouchPriority = -301
local kProgressWidth = 450

local _mainLayer = nil
local _affinityLevelLabel = nil
local _progressBar = nil
local _progressLeftLabel = nil
local _progressRightLabel = nil

local _bottomLeftLabel = nil
local _bottomAffinityIcon = nil
local _bottomLabelTable = nil
local _bottomMaxLevelLabel = nil

local _learnBtn = nil
local _oneLearnBtn = nil
local _oneLearnSprite = nil
local _nextGoldLabel = nil
local _goldIcon = nil

local _remainDescLabel = nil
local _remainLearnLabel = nil

local _goBackBtn = nil


--[[
	@desc :	初始化
	@param:	
	@ret  :
--]]
function init( ... )
	_mainLayer = nil
	_affinityLevelLabel = nil
	_progressBar = nil
	_progressLeftLabel = nil
	_progressRightLabel = nil

	_bottomLeftLabel = nil
	_bottomAffinityIcon = nil
	_bottomLabelTable = nil
	_bottomMaxLevelLabel = nil

	_learnBtn = nil
	_oneLearnBtn = nil
	_oneLearnSprite = nil
	_nextGoldLabel = nil
	_goldIcon = nil

	_remainDescLabel = nil
	_remainLearnLabel = nil

	_goBackBtn = nil
end

--[[
	@desc :	创建顶部的主角属性栏
	@param:	
	@ret  :
--]]
function createTopBar( ... )
	-- 添加顶部状态栏：战斗力 银币 金币
	local topBar = CCSprite:create("images/hero/avatar_attr_bg.png")

	local fightDesc = CCSprite:create("images/common/fight_value.png")
	fightDesc:setAnchorPoint(ccp(0,0.5))
	fightDesc:setPosition(52,21)
	topBar:addChild(fightDesc)

	-- 战斗力
	require "script/model/user/UserModel"
	local fightNum = CCRenderLabel:create(UserModel.getFightForceValue(), g_sFontName, 23, 1, ccc3( 0x00, 0x00, 0x00), type_stroke)
	fightNum:setAnchorPoint(ccp(0,0.5))
	fightNum:setPosition(140,20)
	topBar:addChild(fightNum)

	-- 银币
	-- modified by yangrui at 2015-12-03
	silverLabel = CCLabelTTF:create(string.convertSilverUtilByInternational(UserModel.getSilverNumber()),g_sFontName,20)
	silverLabel:setColor(ccc3(0xe5, 0xf9, 0xff))
	silverLabel:setAnchorPoint(ccp(0, 0.5))
	silverLabel:setPosition(ccp(375, 20))
	topBar:addChild(silverLabel)

	-- 金币
	_goldLabel = CCLabelTTF:create(UserModel.getGoldNumber(), g_sFontName, 20)
	_goldLabel:setColor(ccc3(0xff, 0xf6, 0x00))
	_goldLabel:setAnchorPoint(ccp(0, 0.5))
	_goldLabel:setPosition(ccp(520, 20))
	topBar:addChild(_goldLabel)

	return topBar
end

--[[
	@desc :	创建带有图标和标签的btn
	@param:	
	@ret  :
--]]
function createIconLabelBtn()
	local fullRect = CCRectMake(0,0,150,73)
	local insetRect = CCRectMake(30,10,90,50)
	local normalSprite = CCScale9Sprite:create("images/common/btn/btn1_d.png", fullRect, insetRect)
	local selectedSprite = CCScale9Sprite:create("images/common/btn/btn1_n.png", fullRect, insetRect)
	local preferredSize = CCSizeMake(280,73)
	normalSprite:setPreferredSize(preferredSize)
	selectedSprite:setPreferredSize(preferredSize)
	local btn = CCMenuItemSprite:create(normalSprite, selectedSprite)

	local handIcon = CCSprite:create("images/replaceskill/hand.png")
	handIcon:setAnchorPoint(ccp(1,0.5))
	handIcon:setPosition(preferredSize.width*0.5-25, preferredSize.height*0.5)
	btn:addChild(handIcon)

	local label = CCRenderLabel:create(GetLocalizeStringBy("zz_63"), g_sFontPangWa, 35,
		                               2, ccc3(0x00,0x00,0x00), type_shadow)
	label:setColor(ccc3(0xff,0xe4,0x00))
	label:setAnchorPoint(ccp(0,0.5))
	label:setPosition(preferredSize.width*0.5-20, preferredSize.height*0.5)
	btn:addChild(label)

	--花费金币数
	_nextGoldLabel = CCLabelTTF:create("00", g_sFontPangWa, 21)
	_nextGoldLabel:setColor(ccc3(0xff,0xe4,0x00))
	_nextGoldLabel:setAnchorPoint(ccp(1,0.5))
	_nextGoldLabel:setPosition(preferredSize.width-50,preferredSize.height*0.5)
	btn:addChild(_nextGoldLabel)

	--金币图标
	_goldIcon = CCSprite:create("images/common/gold.png")
	_goldIcon:setAnchorPoint(ccp(0,0.5))
	_goldIcon:setPosition(preferredSize.width-50,preferredSize.height*0.5)
	btn:addChild(_goldIcon)

	return btn
end

--创建一键学艺按钮
function createOneLearnBtn()
	local fullRect = CCRectMake(0,0,150,73)
	local insetRect = CCRectMake(30,10,90,50)
	local normalSprite = CCScale9Sprite:create("images/common/btn/btn_purple2_n.png", fullRect, insetRect)
	local selectedSprite = CCScale9Sprite:create("images/common/btn/btn_purple2_h.png", fullRect, insetRect)
	local preferredSize = CCSizeMake(280,73)
	normalSprite:setPreferredSize(preferredSize)
	selectedSprite:setPreferredSize(preferredSize)
	local btn = CCMenuItemSprite:create(normalSprite, selectedSprite)

	local handIcon = CCSprite:create("images/replaceskill/hand.png")
	handIcon:setAnchorPoint(ccp(1,0.5))
	handIcon:setPosition(preferredSize.width*0.5-45, preferredSize.height*0.5)
	btn:addChild(handIcon)

	local label = CCRenderLabel:create(GetLocalizeStringBy("zzh_1218"), g_sFontPangWa, 35,
		                               2, ccc3(0x00,0x00,0x00), type_shadow)
	label:setColor(ccc3(0xff,0xe4,0x00))
	label:setAnchorPoint(ccp(0,0.5))
	label:setPosition(preferredSize.width*0.5-40, preferredSize.height*0.5)
	btn:addChild(label)

	return btn
end

--创建一键学艺置灰Sprite
function createOneLearnSprite()
	local fullRect = CCRectMake(0,0,150,73)
	local insetRect = CCRectMake(30,10,90,50)
	local normalSprite = CCScale9Sprite:create("images/common/btn/btn1_g.png", fullRect, insetRect)
	local selectedSprite = CCScale9Sprite:create("images/common/btn/btn1_g.png", fullRect, insetRect)
	local preferredSize = CCSizeMake(280,73)
	normalSprite:setPreferredSize(preferredSize)
	selectedSprite:setPreferredSize(preferredSize)
	local btn = CCMenuItemSprite:create(normalSprite, selectedSprite)

	local handIcon = BTGraySprite:create("images/replaceskill/hand.png")
	handIcon:setAnchorPoint(ccp(1,0.5))
	handIcon:setPosition(preferredSize.width*0.5-45, preferredSize.height*0.5)
	btn:addChild(handIcon)

	local label = CCRenderLabel:create(GetLocalizeStringBy("zzh_1218"), g_sFontPangWa, 35,
		                               2, ccc3(0x00,0x00,0x00), type_shadow)
	label:setColor(ccc3(0xff,0xff,0xff))
	label:setAnchorPoint(ccp(0,0.5))
	label:setPosition(preferredSize.width*0.5-40, preferredSize.height*0.5)
	btn:addChild(label)

	return btn
end

--[[
	@desc :	创建中间的UI
	@param:	
	@ret  :
--]]
function createUI( ... )
	local uiNode = CCNode:create()
	uiNode:setContentSize(kMidUIContentSize)
	uiNode:setAnchorPoint(ccp(0,0))
	uiNode:setPosition(0, MenuLayer.getLayerContentSize().height*g_fScaleX)
	uiNode:setScale(g_fScaleX)
	_mainLayer:addChild(uiNode)

	local topBar = createTopBar()
	topBar:setAnchorPoint(ccp(0,1))
	topBar:setPosition(0,kMidUIContentSize.height)
	uiNode:addChild(topBar)

	local menu = CCMenu:create()
	menu:setPosition(0,0)
	menu:setTouchPriority(kMenuTouchPriority)
	uiNode:addChild(menu,1)

	--返回按钮
	_goBackBtn = CCMenuItemImage:create("images/common/close_btn_n.png","images/common/close_btn_h.png")
	_goBackBtn:setAnchorPoint(ccp(0,0))
	_goBackBtn:setPosition(535,kMidUIContentSize.height-120)
	_goBackBtn:registerScriptTapHandler(tapGoBackBtnCb)
	menu:addChild(_goBackBtn)

	--显示用户和名将
	local userSprite = HeroUtil.getHeroBodySpriteByHTID(UserModel.getAvatarHtid(), UserModel.getDressIdByPos(1),
		                                                  UserModel.getUserSex())
	local teacherInfo = ReplaceSkillData.getCurMasterInfo()
	print("teacherInfo")
	print_t(teacherInfo)
	require "db/DB_Heroes"
	--橙卡被炼化后，仍显示橙卡形象
	local tempTid = HeroUtil.getOnceOrangeHtid(teacherInfo.star_tid)
	local teacherSprite = StarSprite.createStarSprite(tempTid)
	local bodyOffset = HeroUtil.getHeroBodySpriteOffsetByHTID(tempTid)
	local userOffset = HeroUtil.getHeroBodySpriteOffsetByHTID(UserModel.getAvatarHtid())
	local tempTable = {
		[1] = {ccp(170,292), userSprite, UserModel.getUserName(), HeroUtil.getHeroLocalInfoByHtid(UserModel.getAvatarHtid()).star_lv,userOffset},
		[2] = {ccp(470,292), teacherSprite, teacherInfo.starTemplate.name, DB_Heroes.getDataById(tempTid).star_lv,bodyOffset},
	}
	for i=1,2 do
		local stageSprite = CCSprite:create("images/replaceskill/stage.png")
		--stageSprite:setScale(0.6)
		stageSprite:setAnchorPoint(ccp(0.5,0.5))
		stageSprite:setPosition(tempTable[i][1])
		uiNode:addChild(stageSprite)

		local generalSprite = tempTable[i][2]
		generalSprite:setScale(0.7)
		generalSprite:setAnchorPoint(ccp(0.5,0))
		generalSprite:setPosition(stageSprite:getContentSize().width/2,35 - tempTable[i][5])
		stageSprite:addChild(generalSprite)

		local nameLabel = CCRenderLabel:create(tempTable[i][3], g_sFontPangWa, 21, 1, ccc3(0x00,0x00,0x00), type_shadow)
		local nameColor = HeroPublicLua.getCCColorByStarLevel(tempTable[i][4])
		nameLabel:setColor(nameColor)
		nameLabel:setAnchorPoint(ccp(0.5,0))
		nameLabel:setPosition(137,0)
		stageSprite:addChild(nameLabel)
	end

	--向右的绿色箭头和拜师图标
	local learnTable = {
		[1] = {"images/replaceskill/learn.png", ccp(320,325)},
		[2] = {"images/replaceskill/right_arrow.png", ccp(331,310)},
	}
	for i = 1,2 do
		local tempSprite = CCSprite:create(learnTable[i][1])
		tempSprite:setAnchorPoint(ccp(0.5,0))
		tempSprite:setPosition(learnTable[i][2])
		uiNode:addChild(tempSprite)
	end
	
	--师徒关系等级背景
	local affinityLevelBg = CCSprite:create("images/star/intimate/namebg.png")
	affinityLevelBg:setAnchorPoint(ccp(0.5,0))
	affinityLevelBg:setPosition(320, 204)
	uiNode:addChild(affinityLevelBg,1)

	local affinityLabel_1 = CCRenderLabel:create(GetLocalizeStringBy("zz_57"), g_sFontName, 21, 2, ccc3(0x00,0x00,0x00), type_shadow)
	affinityLabel_1:setColor(ccc3(0x00,0xff,0x18))
	_affinityLevelLabel = CCRenderLabel:create("00", g_sFontName, 21, 2, ccc3(0x00,0x00,0x00), type_shadow)
	_affinityLevelLabel:setColor(ccc3(0x00,0xff,0x18))
	local topAffinityIcon = CCSprite:create("images/replaceskill/affinity.png")
	require "script/utils/BaseUI"
	local connectNode = BaseUI.createHorizontalNode({affinityLabel_1,topAffinityIcon,_affinityLevelLabel})
	connectNode:setAnchorPoint(ccp(0,0.5))
	connectNode:setPosition(ccp(46,20))
	affinityLevelBg:addChild(connectNode)

	--经验条
	local progressBarBg = CCScale9Sprite:create("images/common/exp_bg.png")
	progressBarBg:setPreferredSize(CCSizeMake(kProgressWidth,23))
	-- local progressBarBg = CCSprite:create("images/shop/exp_bg.png")
	progressBarBg:setAnchorPoint(ccp(0.5,0.5))
	progressBarBg:setPosition(335, 186)
	uiNode:addChild(progressBarBg)

	local fullRect = CCRectMake(0,0,46,23)
	local insetRect = CCRectMake(10,10,26,3)
	_progressBar = CCScale9Sprite:create("images/common/exp_progress.png", fullRect, insetRect)
	_progressBar:setPreferredSize(CCSizeMake(kProgressWidth,23))
	-- _progressBar = CCSprite:create("images/shop/exp_progress.png")
	_progressBar:setAnchorPoint(ccp(0,0.5))
	_progressBar:setPosition(1,11)
	_progressBar:setContentSize(CCSizeMake(1000/3000*kProgressWidth,23))
	progressBarBg:addChild(_progressBar)

	--经验条左边的label
	local affinityDescLabel = CCRenderLabel:create(GetLocalizeStringBy("zz_58"), g_sFontPangWa, 18, 1, ccc3(0x00,0x00,0x00), type_shadow)
	affinityDescLabel:setColor(ccc3(0x00,0xe4,0xff))
	affinityDescLabel:setAnchorPoint(ccp(1,0.5))
	affinityDescLabel:setPosition(0,12)
	progressBarBg:addChild(affinityDescLabel)

	--经验值
	_progressLeftLabel = CCRenderLabel:create("1000/", g_sFontName, 18, 1, ccc3(0x00,0x00,0x00), type_shadow)
	_progressLeftLabel:setColor(ccc3(0xff,0xff,0xff))
	_progressLeftLabel:setAnchorPoint(ccp(1,0.5))
	_progressLeftLabel:setPosition(225,12)
	progressBarBg:addChild(_progressLeftLabel,1)

	_progressRightLabel = CCRenderLabel:create("3000", g_sFontName, 18, 1, ccc3(0x00,0x00,0x00), type_shadow)
	_progressRightLabel:setColor(ccc3(0xff,0xff,0xff))
	_progressRightLabel:setAnchorPoint(ccp(0,0.5))
	_progressRightLabel:setPosition(225,12)
	progressBarBg:addChild(_progressRightLabel,1)

	--"师徒关系" "达到"
	local bottomLeftTable = {
		{desc = GetLocalizeStringBy("zz_60"), color = ccc3(0x00,0xff,0x18)},
		{desc = GetLocalizeStringBy("zz_59"), color = ccc3(0xff,0xff,0xff)},
	}
	_bottomLeftLabel = createBottomLabel(bottomLeftTable).parent
	_bottomLeftLabel:setAnchorPoint(ccp(1,0))
	_bottomLeftLabel:setPosition(235,140)
	uiNode:addChild(_bottomLeftLabel)

	--底部的亲密值图标
	_bottomAffinityIcon = CCSprite:create("images/replaceskill/affinity.png")
	_bottomAffinityIcon:setAnchorPoint(ccp(0,0.5))
	_bottomAffinityIcon:setPosition(235,153)
	uiNode:addChild(_bottomAffinityIcon)
	
	--"x可学习xxxx的xxxxx"
	local bottomRightTable = {
		{desc = "00", color = ccc3(0x00,0xff,0x18)},
		{desc = GetLocalizeStringBy("zz_61"), color = ccc3(0xff,0xff,0xff)},
		{desc = "00", color = ccc3(0xe4,0x00,0xff)},
		{desc = GetLocalizeStringBy("zz_62"), color = ccc3(0xff,0xff,0xff)},
		{desc = "00", color = ccc3(0xe4,0x00,0xff)},
	}
	_bottomLabelTable = createBottomLabel(bottomRightTable)
	local bottomRightLabel = _bottomLabelTable.parent
	bottomRightLabel:setAnchorPoint(ccp(0,0))
	bottomRightLabel:setPosition(273,140)
	uiNode:addChild(bottomRightLabel)

	--当技能已达到最大等级时显示的提示
	_bottomMaxLevelLabel = CCRenderLabel:create(GetLocalizeStringBy("zz_70"), g_sFontPangWa, 21, 1, ccc3(0x00,0x00,0x00), type_shadow)
	_bottomMaxLevelLabel:setColor(ccc3(0x00,0xff,0x18))
	_bottomMaxLevelLabel:setAnchorPoint(ccp(0.5,0))
	_bottomMaxLevelLabel:setPosition(320,140)
	uiNode:addChild(_bottomMaxLevelLabel)

	--学艺按钮
	_learnBtn = createIconLabelBtn()
	_learnBtn:setAnchorPoint(ccp(0.5,0))
	_learnBtn:setPosition(140,45)
	_learnBtn:registerScriptTapHandler(tapLearnBtnCb)
	menu:addChild(_learnBtn)

	_oneLearnBtn = createOneLearnBtn()
	_oneLearnBtn:setAnchorPoint(ccp(0.5,0))
	_oneLearnBtn:setPosition(500,45)
	_oneLearnBtn:registerScriptTapHandler(tapOneLearnBtnCb)
	menu:addChild(_oneLearnBtn)

	_oneLearnSprite = createOneLearnSprite()
	_oneLearnSprite:setAnchorPoint(ccp(0.5,0))
	_oneLearnSprite:setPosition(500,45)
	menu:addChild(_oneLearnSprite)

	--今日剩余翻牌次数
	_remainDescLabel = CCRenderLabel:create("00", g_sFontName, 21, 1, ccc3(0x00, 0x00,0x00), type_shadow)
	_remainDescLabel:setColor(ccc3(0x00,0xff,0x18))
	_remainDescLabel:setAnchorPoint(ccp(1,0))
	_remainDescLabel:setPosition(405,20)
	uiNode:addChild(_remainDescLabel,1)

	_remainLearnLabel = CCRenderLabel:create("00", g_sFontName, 21, 1, ccc3(0x00,0x00,0x00),type_shadow)
	_remainLearnLabel:setColor(ccc3(0xff,0xff,0xff))
	_remainLearnLabel:setAnchorPoint(ccp(0,0))
	_remainLearnLabel:setPosition(405,20)
	uiNode:addChild(_remainLearnLabel,1)

	--刷新底部描述
	refreshBottomLabel()

	--刷新师徒关系等级
	refreshAffinityLevel()

	--刷新经验条
	refreshProgressLabel()

	--刷新经验条
	refreshProgressBar()

	--刷新按钮上的金币花费
	refreshGoldLabel()

	--刷新剩余的翻牌次数
	refreshRemainLabel()

	local seq = CCSequence:createWithTwoActions(CCDelayTime:create(0.3),CCCallFunc:create(function ( ... )
		-- 主角换技能4
		addGuideChangeSkillGuide4()
	end))
	_mainLayer:runAction(seq)
end

--[[
	@desc :	刷新用户金币数目
	@param:	
	@ret  :
--]]
function refreshUserGoldNum( ... )
	_goldLabel:setString(tostring(UserModel.getGoldNumber()))
end

--[[
	@desc :	刷新师徒关系等级
	@param:	
	@ret  :
--]]
function refreshAffinityLevel( ... )
	local curTeacherInfo = ReplaceSkillData.getCurMasterInfo()
	_affinityLevelLabel:setString(curTeacherInfo.feel_level)
end

--[[
	@desc :	刷新经验值
	@param:	
	@ret  :
--]]
function refreshProgressLabel( ... )
	local curTeacherInfo = ReplaceSkillData.getCurMasterInfo()
	if tonumber(curTeacherInfo.feel_level) == ReplaceSkillData.getMaxConfigFeelLevel() then
		_progressLeftLabel:setVisible(false)
		_progressRightLabel:setString("Max Level")
		_progressRightLabel:setPosition(185,12)
		return
	end

	local leftValue = ReplaceSkillData.getLeftFeelValue()
	_progressLeftLabel:setString(leftValue .. "/")
	_progressLeftLabel:setVisible(true)

	local rightValue = ReplaceSkillData.getRightFeelValue()
	_progressRightLabel:setString(tostring(rightValue))
	_progressRightLabel:setPosition(225,12)

	--_progressBar:setContentSize(CCSizeMake(leftValue/rightValue*kProgressWidth, 23))
end

--[[
	@desc :	刷新经验条
	@param:	
	@ret  :
--]]
function refreshProgressBar()
	local curTeacherInfo = ReplaceSkillData.getCurMasterInfo()
	if tonumber(curTeacherInfo.feel_level) == ReplaceSkillData.getMaxConfigFeelLevel() then
		_progressBar:setContentSize(CCSizeMake(0, 23))
		return
	end

	local leftValue = ReplaceSkillData.getLeftFeelValue()
	local rightValue = ReplaceSkillData.getRightFeelValue()
	print("refreshProgressBar",leftValue,rightValue)
	_progressBar:setContentSize(CCSizeMake(leftValue/rightValue*kProgressWidth, 23))
end

-- --[[

-- --]]
-- function runProgressIncreaseAction( p_curLevel, p_leftValue, p_increaseValue )
-- 	local feelLevel = p_curLevel
-- 	local rightValue = ReplaceSkillData.getFeelValueByLevel(feelLevel)
-- 	local leftValue = p_leftValue
-- 	local count = 0
-- 	local step = rightValue/100
-- 	local increaseBarFunc = function ()
-- 		leftValue = leftValue+step
-- 		count = count + step
-- 		if leftValue <= rightValue then
-- 			_progressBar:setContentSize(CCSizeMake(leftValue/rightValue*kProgressWidth, 23))
-- 			--_progressBar:setTextureRect(CCRectMake(0,0,leftValue/rightValue*kProgressWidth,23))

-- 			if count == p_increaseValue then
-- 				_progressBar:stopAllActions()
-- 			end
-- 		else
-- 			_progressBar:setContentSize(CCSizeMake(kProgressWidth, 23))

-- 			leftValue = leftValue - rightValue
-- 			feelLevel = feelLevel+1
-- 			rightValue = ReplaceSkillData.getFeelValueByLevel(feelLevel)

-- 			_progressBar:setContentSize(CCSizeMake(leftValue/rightValue*kProgressWidth, 23))
			
-- 			count = count - step
-- 		end
-- 	end
-- 	schedule(_progressBar,increaseBarFunc,1/60)
-- end

--[[
	@desc :	创建中间的UI
	@param:	p_table 标签内容
	{
		{
			desc = string
			color = ccc3()
		}
	}
	@ret :	标签节点
	{
		parent = CCNode
		children = {
			CCRenderLabel1,
			CCRenderLabel2,
			...
		}
	}
--]]
function createBottomLabel( p_table )
	local labelTable = {parent = CCNode:create(), children = {}}

	local node = labelTable.parent
	local contentSize = CCSizeMake(0,21)
	for _,v in ipairs(p_table) do
		local label = CCRenderLabel:create(v.desc, g_sFontPangWa, 21, 1, ccc3(0x00,0x00,0x00), type_shadow)
		label:setColor(v.color)
		label:setAnchorPoint(ccp(0,0))
		label:setPosition(contentSize.width,0)
		node:addChild(label)
		contentSize.width = contentSize.width + label:getContentSize().width
		table.insert(labelTable.children, label)
	end
	node:setContentSize(contentSize)

	return labelTable
end

--[[
	@desc :	设置经验条下方描述是否可见
	@param:	p_bool true 可见 false 不可见
	@ret  :
--]]
function setBottomLabelVisible(p_bool)
	if _bottomLeftLabel == nil or _bottomAffinityIcon == nil or _bottomLabelTable.parent == nil then
		return
	end
	_bottomLeftLabel:setVisible(p_bool)
	_bottomAffinityIcon:setVisible(p_bool)
	_bottomLabelTable.parent:setVisible(p_bool)
end

--[[
	@desc :	刷新底部描述
	@param:	
	@ret  :
--]]
function refreshBottomLabel( ... )
	local skillInfo = ReplaceSkillData.getSelectSkillInfo()
	local nextLevel = skillInfo.skillLevel + 1
	if nextLevel > skillInfo.maxSkillLevel then
		setBottomLabelVisible(false)
		_bottomMaxLevelLabel:setVisible(true)
		return
	end

	setBottomLabelVisible(true)
	_bottomMaxLevelLabel:setVisible(false)

	local skillList = ReplaceSkillData.getCurMasterSkillInfo()
	local nextSkillInfo = ReplaceSkillData.getSkillByLevel(skillList, nextLevel)

	--local strTable = {tostring(skillInfo.needFeelLevel), skillInfo.starName, skillInfo.skillName}
	_bottomLabelTable.children[1]:setString(tostring(nextSkillInfo.needFeelLevel))
	_bottomLabelTable.children[3]:setString(nextSkillInfo.starName)
	_bottomLabelTable.children[5]:setString(nextSkillInfo.skillName)

	--"可学习" ＝> "可提升"
	if nextSkillInfo.skillLevel > 1 then
		_bottomLabelTable.children[2]:setString(GetLocalizeStringBy("zz_69"))
	end

	local contentSize = CCSizeMake(0,21)
	for _,v in ipairs(_bottomLabelTable.children) do
		v:setPosition(contentSize.width,0)
		contentSize.width = contentSize.width + v:getContentSize().width
	end
	_bottomLabelTable.parent:setContentSize(contentSize)
end

--[[
	@desc :	刷新按钮上的金币标签
	@param:	
	@ret  :
--]]
function refreshGoldLabel( ... )
	--if _goldIcon == nil or _nextGoldLabel == nil then return end
	--用上面注释的判断会出现错误，若进入该界面后再退出，_goldIcon和_nextGoldLabel不为nil，但它们已经被释放，调用其方法时会提示无效的self
	--_mainLayer在退出时已经被重置为nil
	if _mainLayer == nil then return end
	print("refreshGoldLabel",tolua.type(_goldIcon),tolua.type(_nextGoldLabel))

	print("免费次数",ReplaceSkillData.getFreeFlipNum())
	print("金币次数",ReplaceSkillData.getGoldFilpNum())

	if ReplaceSkillData.getFreeFlipNum() > 0 or ReplaceSkillData.getGoldFilpNum() <= 0 then
		_goldIcon:setVisible(false)
		_nextGoldLabel:setVisible(false)
	else
		_goldIcon:setVisible(true)
		_nextGoldLabel:setVisible(true)

		_nextGoldLabel:setString(ReplaceSkillData.getUseGoldNum())
	end
end

--[[
	@desc :	刷新剩余的翻牌次数
	@param:	
	@ret  :
--]]
function refreshRemainLabel( ... )
	--if _remainDescLabel == nil or _remainLearnLabel == nil then return end
	if _mainLayer == nil then return end

	local labelStr = GetLocalizeStringBy("zz_64")
	local remainNum = ReplaceSkillData.getFreeFlipNum()
	_oneLearnBtn:setVisible(true)
	_oneLearnSprite:setVisible(false)

	if remainNum <= 0 then
		labelStr = GetLocalizeStringBy("zz_66")
		remainNum = ReplaceSkillData.getGoldFilpNum()

		_oneLearnBtn:setVisible(false)
		_oneLearnSprite:setVisible(true)
	end

	_remainDescLabel:setString(labelStr)
	_remainLearnLabel:setString(remainNum)
end

--[[
	@desc :	创建层
	@param:	
	@ret  :
--]]
function createLayer( ... )
	_mainLayer = CCLayer:create()
	_mainLayer:registerScriptHandler(onNodeEvent)

	local layerBg = CCSprite:create("images/replaceskill/learn_bg.jpg")
	layerBg:setScale(MainScene.bgScale)
	layerBg:setAnchorPoint(ccp(0.5,0))
	layerBg:setPosition(g_winSize.width/2, MenuLayer.getLayerContentSize().height*g_fScaleX)
	_mainLayer:addChild(layerBg)

	createUI()
end

--[[
	@desc :	显示层
	@param:	
	@ret  :
--]]
function showLayer( ... )
	--ReplaceSkillData.setCurMasterInfo(9707)
	init()
	createLayer()

	MainScene.changeLayer(_mainLayer, "learnSkillLayer")
	MainScene.setMainSceneViewsVisible(true, false, true)
end

--[[
	@desc :	创建和移除层时的回调
	@param:	
	@ret  :
--]]
function onNodeEvent( p_eventType )
	if p_eventType == "enter" then
		print("主将学习技能 学习技能 创建")
		_mainLayer:registerScriptTouchHandler(touchMainLayerCb,false,kMainLayerTouchPriority,true)
		_mainLayer:setTouchEnabled(true)
	elseif p_eventType == "exit" then
		print("主将学习技能 学习技能 退出")
		_mainLayer:unregisterScriptTouchHandler()
		_mainLayer = nil
	else

	end
end

--[[
	@desc :	触摸回调
	@param:	
	@ret  :
--]]
function touchMainLayerCb( p_eventType, p_touchX, p_touchY )
	return true
end

--[[
	@desc :	点击关闭按钮回调
	@param:	
	@ret  :
--]]
function tapGoBackBtnCb( p_tag, p_item )
	AudioUtil.playEffect("audio/effect/guanbi.mp3")
	require "script/ui/replaceSkill/learnSkill/SelectSkillLayer"
	SelectSkillLayer.showLayer()
end

--[[
	@desc :	点击学习技能按钮回调
	@param:	
	@ret  :
--]]
require "script/ui/tip/SingleTip"
function tapLearnBtnCb(p_tag, p_item)

	if not table.isEmpty(ReplaceSkillData.remainRewardInfo()) then
		tapComfirmBtnCb(true)
		return
	end
	
	--"您与该武将的亲密等级已达到自身等级上限，请先提升主公等级。"
	local curTeacherInfo = ReplaceSkillData.getCurMasterInfo()
	local maxUserFeelLevel = ReplaceSkillData.getMaxUserFeelLevel()
	local maxConfigFeelLevel = ReplaceSkillData.getMaxConfigFeelLevel()
	if tonumber(curTeacherInfo.feel_level) >= maxUserFeelLevel and 
		tonumber(curTeacherInfo.feel_level) ~= maxConfigFeelLevel then
		SingleTip.showSingleTip(GetLocalizeStringBy("zz_72"))
		return
	end
	--"当前您与该武将的亲密等级已达到最高，不能进行学艺。"
	if tonumber(curTeacherInfo.feel_level) >= maxConfigFeelLevel then
		SingleTip.showSingleTip(GetLocalizeStringBy("zz_71"))
		return
	end

	--免费学艺次数用完
	if ReplaceSkillData.getFreeFlipNum() <= 0 then
		--金币次数用完
		if ReplaceSkillData.getGoldFilpNum() <= 0 then
			SingleTip.showSingleTip(GetLocalizeStringBy("zz_74"))
			return
		end

		local useGoldNum = ReplaceSkillData.getUseGoldNum()
		--金币不足时进入充值界面
		if UserModel.getGoldNumber() < useGoldNum then
			require "script/ui/tip/LackGoldTip"
            LackGoldTip.showTip()
			return
		end

		--提示花费金币翻牌
		AlertTip.showAlert(GetLocalizeStringBy("zz_67",useGoldNum), tapComfirmBtnCb, true)
		return
	else
		--跳转到翻牌界面
		tapComfirmBtnCb(true)
	end
end

--一键学艺回调
function tapOneLearnBtnCb()
	if not table.isEmpty(ReplaceSkillData.remainRewardInfo()) then
		SingleTip.showSingleTip(GetLocalizeStringBy("zzh_1219"))
		return
	end

	--"您与该武将的亲密等级已达到自身等级上限，请先提升主公等级。"
	local curTeacherInfo = ReplaceSkillData.getCurMasterInfo()
	local maxUserFeelLevel = ReplaceSkillData.getMaxUserFeelLevel()
	local maxConfigFeelLevel = ReplaceSkillData.getMaxConfigFeelLevel()
	if tonumber(curTeacherInfo.feel_level) >= maxUserFeelLevel and 
		tonumber(curTeacherInfo.feel_level) ~= maxConfigFeelLevel then
		SingleTip.showSingleTip(GetLocalizeStringBy("zz_72"))
		return
	end
	--"当前您与该武将的亲密等级已达到最高，不能进行学艺。"
	if tonumber(curTeacherInfo.feel_level) >= maxConfigFeelLevel then
		SingleTip.showSingleTip(GetLocalizeStringBy("zz_71"))
		return
	end

	local callBack = function(addNum)
		_oneLearnBtn:setVisible(false)
		_oneLearnSprite:setVisible(true)

		ReplaceSkillData.deleteDraw()
		
		continueFlipFly(ReplaceSkillData.getFreeFlipNum())
		
		--加一次翻牌次数
		ReplaceSkillData.addFlipNum(ReplaceSkillData.getFreeFlipNum())

		--刷新下一次翻牌所需金币数量
		refreshGoldLabel()

		--刷新剩余翻牌次数
		refreshRemainLabel()

		LevelUpUtil.showFlyText({{txt= GetLocalizeStringBy("zzh_1117"), num = addNum}})

		ReplaceSkillData.addCurStarFeel(addNum)
	end
	require "script/ui/replaceSkill/ReplaceSkillService"
	ReplaceSkillService.quickDraw(callBack)
end

function continueFlipFly(p_num)
	local conLabel = CCRenderLabel:create(GetLocalizeStringBy("zzh_1220"),g_sFontPangWa,35,1,ccc3(0,0,0),type_stroke)
	conLabel:setColor(ccc3(0xe4,0x00,0xff))

	local heroNameLable = CCRenderLabel:create(p_num,g_sFontPangWa,35,1,ccc3(0,0,0),type_stroke)
	heroNameLable:setColor(ccc3(0x76,0xfc,0x06))

	local honeyLabel = CCRenderLabel:create(GetLocalizeStringBy("zzh_1221"),g_sFontPangWa,35,1,ccc3(0,0,0),type_stroke)
	honeyLabel:setColor(ccc3(0xe4,0x00,0xff))

	local allNode = BaseUI.createHorizontalNode({conLabel,heroNameLable,honeyLabel})
	allNode:setScale( g_fElementScaleRatio)
	allNode:setAnchorPoint(ccp(0.5,0.5))
	allNode:setPosition(ccp(g_winSize.width*0.5,g_winSize.height*0.55))
	--allNode:setVisible(false)
	CCDirector:sharedDirector():getRunningScene():addChild(allNode,2013)

	local nextMoveToP = ccp(g_winSize.width*0.5, g_winSize.height*0.6)

	local actionArr = CCArray:create()
	--actionArr:addObject(CCDelayTime:create(1.0))
	--actionArr:addObject(CCFadeIn()) 
	-- actionArr:addObject(CCCallFuncN:create(function ( ... )
	-- 	allNode:setVisible(true)
	-- end))
	actionArr:addObject(CCEaseOut:create(CCMoveTo:create(1.0, nextMoveToP),2))
	--actionArr:addObject(CCDelayTime:create(0.2))
	actionArr:addObject(CCFadeOut:create(0.7))
	actionArr:addObject(CCCallFuncN:create(function()
		allNode:removeFromParentAndCleanup(true)
		allNode = nil
	end))

	allNode:runAction(CCSequence:create(actionArr))
end

--[[
	@desc :	点击弹出框确定按钮回调
	@param:	
	@ret  :
--]]
function tapComfirmBtnCb(p_isTure)
	if p_isTure == false then
		return
	end

	buttomUnTouch()
	-- runProgressIncreaseAction(3,450,500)
	require "script/ui/replaceSkill/FlipCardLayer"
	FlipCardLayer.showLayer()
end

--[[
	@desc :	设置学艺技能和关闭按钮成无效
	@param:	
	@ret  :
--]]
function buttomUnTouch()
	_learnBtn:setEnabled(false)
	_goBackBtn:setEnabled(false)
	_oneLearnBtn:setEnabled(false)
end

--[[
	@desc :	设置学艺技能和关闭按钮成有效
	@param:	
	@ret  :
--]]
function buttomSure()
	_learnBtn:setEnabled(true)
	_goBackBtn:setEnabled(true)
	_oneLearnBtn:setEnabled(true)
end

--------------------------------------用于新手引导---------------------------------
function getLearnBtn( ... )
	return _learnBtn
end


---[==[主角换技能 第3步
---------------------新手引导---------------------------------
function addGuideChangeSkillGuide4( ... )
	require "script/guide/NewGuide"
	require "script/guide/ChangeSkillGuide"
    if(NewGuide.guideClass ==  ksGuideChangeSkill and ChangeSkillGuide.stepNum == 3) then
        ChangeSkillGuide.show(4, nil)
    end
end