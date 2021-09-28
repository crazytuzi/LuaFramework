-- Filename: SelectSkillLayer.lua
-- Author: zhangqiang
-- Date: 2014-08-21
-- Purpose: 创建选择学习技能界面

module("SelectSkillLayer", package.seeall)
require "script/ui/replaceSkill/learnSkill/LearnSkillLayer"
require "script/ui/tip/SingleTip"

-- local kMidUIContentSize = CCSizeMake(640, g_winSize.height/g_fScaleX-BulletinLayer.getLayerHeight()
-- 	                                 -MenuLayer.getLayerContentSize().height)
local kMidUIContentSize = CCSizeMake(640, g_winSize.height/g_fScaleX-146)
local kTableViewBgSize = CCSizeMake(600,kMidUIContentSize.height - 140)
local kTableViewSize = CCSizeMake(kTableViewBgSize.width-10,kTableViewBgSize.height - 20)
local kTableViewCellSize = CCSizeMake(kTableViewSize.width,185)
local kMainLayerTouchPriority = -300
local kMenuTouchPriority = -301
local kTableViewPriority = -301

local _mainLayer = nil
local _tableView = nil
local _bottomLabel = nil
local _remainLearnLabel = nil

--用于新手引导(第一个学习技能按钮)
local _firstCellBtn = nil


--[[
	@desc :	初始化
	@param:	
	@ret  :	
--]]
function init( ... )
	ReplaceSkillData.init()
	_mainLayer = nil
	_tableView = nil
	_bottomLabel = nil
	_remainLearnLabel = nil
	_firstCellBtn = nil
end

--[[
	@desc :	创建中间的UI
	@param:	
	@ret  :
--]]
function createMidUI( ... )
	--"images/item/equipinfo/bg_9s.png"
	--"images/item/equipinfo/topbg.png"
	--"images/common/bg/bg_ng_attr.png"
	local firstBg = CCScale9Sprite:create("images/item/equipinfo/bg_9s.png")
	firstBg:setPreferredSize(kMidUIContentSize)
	firstBg:setAnchorPoint(ccp(0.5,0))
	firstBg:setScale(g_fScaleX)
	firstBg:setPosition(320*g_fScaleX, MenuLayer.getLayerContentSize().height*g_fScaleX)
	_mainLayer:addChild(firstBg)
	local firstBgContentSize = firstBg:getContentSize()

	local secondBg = CCScale9Sprite:create("images/common/bg/bg_ng_attr.png")
	secondBg:setPreferredSize(kTableViewBgSize)
	secondBg:setAnchorPoint(ccp(0.5,0))
	secondBg:setPosition(320,60)
	firstBg:addChild(secondBg)

	local titleBg = CCSprite:create("images/item/equipinfo/topbg.png")
	titleBg:setAnchorPoint(ccp(0.5,1))
	titleBg:setPosition(320, firstBgContentSize.height)
	firstBg:addChild(titleBg)

	local titleLabel = CCLabelTTF:create(GetLocalizeStringBy("zz_48"), g_sFontPangWa, 35)
	titleLabel:setColor(ccc3(0xff,0xe4,0x00))
	titleLabel:setAnchorPoint(ccp(0.5,0.5))
	titleLabel:setPosition(320,titleBg:getContentSize().height*0.5+8)
	titleBg:addChild(titleLabel)

	-- 创建学习技能列表
	_tableView = createTableView(0, kTableViewSize, kTableViewCellSize, #ReplaceSkillData.getSkillList(),
		                         createCell)
	_tableView:ignoreAnchorPointForPosition(false)
	_tableView:setAnchorPoint(ccp(0.5,0.5))
	_tableView:setPosition(kTableViewBgSize.width/2,kTableViewBgSize.height/2)
	_tableView:setTouchPriority(kTableViewPriority)
	secondBg:addChild(_tableView)

	-- "今日剩余次数"
	_bottomLabel = CCRenderLabel:create("", g_sFontName, 21, 1, ccc3(0x00, 0x00,0x00), type_shadow)
	_bottomLabel:setColor(ccc3(0x00,0xff,0x18))
	_bottomLabel:setAnchorPoint(ccp(1,0))
	_bottomLabel:setPosition(388,28)
	firstBg:addChild(_bottomLabel,1)

	_remainLearnLabel = CCRenderLabel:create("", g_sFontName, 21, 1, ccc3(0x00,0x00,0x00),type_shadow)
	_remainLearnLabel:setColor(ccc3(0xff,0xff,0xff))
	_remainLearnLabel:setAnchorPoint(ccp(0,0))
	_remainLearnLabel:setPosition(388,28)
	firstBg:addChild(_remainLearnLabel,1)

	local menu = CCMenu:create()
	menu:setPosition(0,0)
	menu:setTouchPriority(kMenuTouchPriority)
	firstBg:addChild(menu)

	local closeBtn = CCMenuItemImage:create("images/common/btn_close_n.png","images/common/btn_close_h.png")
	closeBtn:setAnchorPoint(ccp(0.5,0.5))
	closeBtn:setPosition(610,kMidUIContentSize.height-30)
	closeBtn:registerScriptTapHandler(tapCloseBtnCb)
	menu:addChild(closeBtn)

	refreshBottomLabel()
end

--[[
	@desc :	创建表格
	@param:	p_directionTag 0 垂直滑动 1 横向滑动
			p_tableViewSize 表格显示尺寸
			p_cellSize 表格单元尺寸
			p_cellNum 表格单元数目
			p_createCellFunc 创建表格单元的函数
	@ret  : 表格
--]]
function createTableView(p_directionTag, p_tableViewSize, p_cellSize, p_cellNum, p_createCellFunc)
	local createTableFunc = function ( p_funcName, p_table, p_a1, p_a2 )
		local ret = nil
		if p_funcName == "cellSize" then
			ret = p_cellSize
		elseif p_funcName == "cellAtIndex" then
			ret = p_createCellFunc(p_a1+1)
		elseif p_funcName == "numberOfCells" then
			ret = p_cellNum
		elseif p_funcName == "cellTouched" then

		elseif p_funcName == "scroll" then

		else

		end
		return ret
	end
	local funcEvent = LuaEventHandler:create(createTableFunc)
	local tableView = LuaTableView:createWithHandler(funcEvent, p_tableViewSize)
	if p_directionTag == 0 then
		tableView:setVerticalFillOrder(kCCTableViewFillTopDown)
	elseif p_directionTag == 1 then
		tableView:setDirection(kCCScrollViewDirectionHorizontal)
		tableView:reloadData()
	else
		error("Wrong direction, not surpported!")
	end
	return tableView
end

--[[
	@desc :	创建表格单元
	@param:	表格单元索引
	@ret  :	表格单元
--]]
require "script/ui/replaceSkill/ReplaceSkillData"
require "script/ui/replaceSkill/ReplaceSkillLayer"
function createCell( p_cellIndex )
	local cell = CCTableViewCell:create()
	local cellData = ReplaceSkillData.getSkillList()[p_cellIndex]
	print("createCell")
	print_t(cellData)
	--单元格背景
	local fullRect = CCRectMake(0,0,80,118)
	local insectRect = CCRectMake(35,35,10,48)
	local firstBg = CCScale9Sprite:create("images/pet/pet/bag_bg.png",fullRect,insectRect)
	firstBg:setPreferredSize(kTableViewCellSize)
	firstBg:setAnchorPoint(ccp(0,0))
	firstBg:setPosition(0,0)
	cell:addChild(firstBg)

	--描述背景
	local secondBg = CCScale9Sprite:create("images/common/bg/goods_bg.png")
	secondBg:setPreferredSize(CCSizeMake(265,124))
	secondBg:setAnchorPoint(ccp(0,0))
	secondBg:setPosition(108,15)
	firstBg:addChild(secondBg)

	local rightNode = nil
	if cellData.skillLevel == cellData.maxSkillLevel then
		rightNode = createMaxLevelRightUI()
	else
		rightNode = createRightUI(p_cellIndex)
	end
	rightNode:setPosition(0,0)
	firstBg:addChild(rightNode)

	--技能预览按钮
	local menu = CCMenu:create()
	menu:setPosition(0,0)
	menu:setTouchPriority(kMenuTouchPriority)
	firstBg:addChild(menu)

	local previewBtn = LuaCC.create9ScaleMenuItem("images/replaceskill/green_btn_n.png", "images/replaceskill/green_btn_h.png",
		                                          CCSizeMake(160,64), GetLocalizeStringBy("zz_75"), ccc3(0xff,0xf6,0x00))
	previewBtn:setAnchorPoint(ccp(0,0))
	previewBtn:setPosition(395,105)
	previewBtn:registerScriptTapHandler(tapPreviewBtnCb)
	menu:addChild(previewBtn,1,p_cellIndex)

	--技能图标
	local skillIcon = ReplaceSkillLayer.createSkillIcon(cellData.skillId)
	skillIcon:setAnchorPoint(ccp(0,0))
	skillIcon:setPosition(15,60)
	firstBg:addChild(skillIcon)

	--LV图标
	local lvSprite = CCSprite:create("images/boss/LV.png")
	lvSprite:setScale(0.7)
	lvSprite:setAnchorPoint(ccp(1,0))
	lvSprite:setPosition(61,32)
	firstBg:addChild(lvSprite)

	--各个描述
	--[1] = {内容， 字体， 大小， 颜色}
	--橙卡被炼化后，仍显示橙色品质
	local tempTid = HeroUtil.getOnceOrangeHtid(cellData.starTid)
	local qualityColor = HeroPublicLua.getCCColorByStarLevel(HeroUtil.getHeroLocalInfoByHtid(tempTid).star_lv)
	local descTable = {
		[1] = {cellData.skillName, g_sFontPangWa, 23, ccc3(0xe4,0x00,0xff)},
		[2] = {GetLocalizeStringBy("zz_55"), g_sFontPangWa, 18, ccc3(0xff,0xe4,0x00)},
		[3] = {cellData.starName, g_sFontPangWa, 18, qualityColor}, --ccc3(0xe4,0x00,0xff)
		[4] = {")", g_sFontPangWa, 18, ccc3(0xff,0xe4,0x00)},
	}
	local labelPosition = ccp(120,142)
	for i = 1,4 do 
		local label = CCRenderLabel:create(descTable[i][1], descTable[i][2], descTable[i][3], 2, ccc3(0x00,0x00,0x00), type_shadow)
		label:setColor(descTable[i][4])
		label:setAnchorPoint(ccp(0,0))
		label:setPosition(labelPosition)
		firstBg:addChild(label)
		labelPosition.x = labelPosition.x + label:getContentSize().width
	end

	--技能等级
	local skillLevelLabel = CCRenderLabel:create(tostring(cellData.skillLevel), g_sFontPangWa, 18, 2, ccc3(0x00,0x00,0x00), type_shadow)
	skillLevelLabel:setColor(ccc3(0xff,0xe4,0x00))
	skillLevelLabel:setAnchorPoint(ccp(0,0))
	skillLevelLabel:setPosition(61,32)
	firstBg:addChild(skillLevelLabel)

	--技能描述
	local skillDescLabel = CCLabelTTF:create("      " .. cellData.skillDesc, g_sFontName, 21)
	skillDescLabel:setColor(ccc3(0x78,0x25,0x00))
	skillDescLabel:setDimensions(CCSizeMake(240,95))
	skillDescLabel:setHorizontalAlignment(kCCTextAlignmentLeft)
	skillDescLabel:setVerticalAlignment(kCCVerticalTextAlignmentTop)
	skillDescLabel:setAnchorPoint(ccp(0.5,0.5))
	skillDescLabel:setPosition(secondBg:getContentSize().width/2,secondBg:getContentSize().height/2)
	secondBg:addChild(skillDescLabel)

	--图标“怒”
	local angerBg = CCSprite:create("images/hero/info/anger.png")
	angerBg:setScale(0.80)
	angerBg:setAnchorPoint(ccp(1,0))
	angerBg:setPosition(30,74)
	skillDescLabel:addChild(angerBg)

	local angerLabel = CCLabelTTF:create(GetLocalizeStringBy("zz_54"), g_sFontName, 25)
	angerLabel:setColor(ccc3(0xff,0xff,0xff))
	angerLabel:setAnchorPoint(ccp(0.5,0.5))
	angerLabel:setPosition(angerBg:getContentSize().width/2, angerBg:getContentSize().height/2)
	angerBg:addChild(angerLabel)

	return cell
end

--[[
	@desc :	技能未达到最高等级时创建按钮和提升到下一等级需要的条件标签
	@param:	p_cellIndex 单元格数据索引
	@ret  :
--]]
function createRightUI(p_cellIndex)
	local node = CCNode:create()
	local cellData = ReplaceSkillData.getSkillList()[p_cellIndex]

	local menu = CCMenu:create()
	menu:setPosition(0,0)
	menu:setTouchPriority(kMenuTouchPriority)
	node:addChild(menu)

	--学习技能按钮
	local learnBtnStr = nil
	if cellData.skillLevel == 0 then
		learnBtnStr = GetLocalizeStringBy("zz_48")
	else
		learnBtnStr = GetLocalizeStringBy("zz_65")
	end
	local learnBtn = LuaCC.create9ScaleMenuItem("images/common/btn/btn_blue_n.png", "images/common/btn/btn_blue_h.png",
		                                        CCSizeMake(160,64), learnBtnStr, ccc3(0xff,0xf6,0x00))
	learnBtn:setAnchorPoint(ccp(0,0))
	learnBtn:setPosition(395,48)
	learnBtn:registerScriptTapHandler(tapLearnBtnCb)
	menu:addChild(learnBtn,1,p_cellIndex)

	--用于新手引导
	if p_cellIndex == 1 then
		_firstCellBtn = learnBtn
	end

	--下一等级技能所需师徒关系等级
	local skillList = ReplaceSkillData.getSkillInfoByStid(cellData.starTid)
	local nextSkillInfo = ReplaceSkillData.getSkillByLevel(skillList, cellData.skillLevel+1)
	local label = CCRenderLabel:create(GetLocalizeStringBy("zz_56",nextSkillInfo.needFeelLevel), g_sFontPangWa, 18, 1, ccc3(0x00,0x00,0x00),
	                                   type_shadow)
	label:setColor(ccc3(0x00,0xff,0x18))
	label:setAnchorPoint(ccp(1,0))
	label:setPosition(537,26)
	node:addChild(label)

	--亲密图标
	local affinitySprite = CCSprite:create("images/replaceskill/affinity.png")
	affinitySprite:setAnchorPoint(ccp(0,0))
	affinitySprite:setPosition(537,22)
	node:addChild(affinitySprite)

	return node
end

--[[
	@desc :	技能达到最高等级时创建“已达上限”标签
	@param:	
	@ret  :
--]]
function createMaxLevelRightUI( ... )
	local node = CCNode:create()

	local redBg = CCScale9Sprite:create("images/replaceskill/redbg.png",CCRectMake(0,0,64,37),CCRectMake(20,10,24,17))
	redBg:setPreferredSize(CCSizeMake(160,64))
	redBg:setAnchorPoint(ccp(0,0))
	redBg:setPosition(395,35)
	node:addChild(redBg)

	local label = CCRenderLabel:create(GetLocalizeStringBy("key_10198"), g_sFontPangWa, 30, 1, ccc3(0x00,0x00,0x00), type_shadow)
	label:setAnchorPoint(ccp(0.5,0.5))
	--label:setPosition(graySprite:getContentSize().width/2, graySprite:getContentSize().height/2)
	--graySprite:addChild(label)
	label:setPosition(redBg:getContentSize().width/2, redBg:getContentSize().height/2)
	redBg:addChild(label)

	return node
end

--[[
	@desc :	添加红点提示
	@param:	
	@ret  :
--]]
function createRedTip(p_menuItem)
	local redTip = p_menuItem:getChildByTag(1918)
	if redTip ~= nil then
		redTip = tolua.cast(redTip, "CCSprite")
		redTip:removeFromParentAndCleanup(true)
		redTip = nil
	end

	local remainFlipNum = ReplaceSkillData.getFreeFlipNum()
	local size = p_menuItem:getContentSize()
	if ReplaceSkillData.isShowTip() then
		require "script/libs/LuaCCSprite"
		redTip = LuaCCSprite.createTipSpriteWithNum(remainFlipNum)
		redTip:setAnchorPoint(ccp(0.5,0.5))
		redTip:setPosition(size.width*0.8, size.height*0.8)
		p_menuItem:addChild(redTip,1,1918)
	end
end

--[[
	@desc :	刷新底部描述和学艺次数
	@param:	
	@ret  :
--]]
function refreshBottomLabel( ... )
	--if _bottomLabel == nil or _remainLearnLabel == nil then return end
	--用上面注释的判断会出现错误，若进入该界面后再退出，_bottomLabel和_remainLearnLabel不为nil，但它们已经被释放，调用其方法时会提示无效的self
	--_mainLayer在退出时已经被重置为nil
	if _mainLayer == nil then return end

	local remainNum = ReplaceSkillData.getFreeFlipNum()
	local descStr = GetLocalizeStringBy("zz_64")
	--当免费学艺次数用完后显示剩余金币学艺次数
	if remainNum == 0 then
		remainNum = ReplaceSkillData.getGoldFilpNum()
		descStr = GetLocalizeStringBy("zz_66")
	end
	_bottomLabel:setString(descStr)
	_remainLearnLabel:setString(tostring(remainNum))
end

--[[
	@desc :	创建层
	@param:	
	@ret  :
--]]
function createLayer( ... )
	_mainLayer = CCLayer:create()
	_mainLayer:registerScriptHandler(onNodeEvent)

	createMidUI()

	local seq = CCSequence:createWithTwoActions(CCDelayTime:create(0.3),CCCallFunc:create(function ( ... )
		-- 主角换技能3
		addGuideChangeSkillGuide3()
	end))
	_mainLayer:runAction(seq)
end

--[[
	@desc :	显示层
	@param:	
	@ret  :
--]]
function showLayer( ... )
	init()
	createLayer()

	MainScene.changeLayer(_mainLayer, "SelectSkillLayer")
	MainScene.setMainSceneViewsVisible(true, false, true)
end

--[[
	@desc :	创建和移除层时的回调
	@param:	
	@ret  :
--]]
function onNodeEvent( p_eventType )
	if p_eventType == "enter" then
		print("主将学习技能 选择技能 创建")
		_mainLayer:registerScriptTouchHandler(touchMainLayerCb,false,kMainLayerTouchPriority,true)
		_mainLayer:setTouchEnabled(true)
	elseif p_eventType == "exit" then
		print("主将学习技能 选择技能 退出")
		_mainLayer:unregisterScriptTouchHandler()
		_mainLayer = nil
	else

	end
end

--[[
	@desc :	层的触摸回调
	@param:	
	@ret  :
--]]
function touchMainLayerCb( p_eventType, p_touchX, p_touchY )
	return true
end

--[[
	@desc :	关闭按钮回调
	@param:	
	@ret  :
--]]
require "script/audio/AudioUtil"
require "script/ui/destiny/DestinyLayer"
function tapCloseBtnCb(p_tag, p_item)
	AudioUtil.playEffect("audio/effect/guanbi.mp3")

	local destinyLayer = DestinyLayer.createLayer()
	MainScene.changeLayer(destinyLayer, "destinyLayer")
end

--[[
	@desc :	学习技能按钮回调
	@param:	
	@ret  :
--]]
function tapLearnBtnCb( p_tag, p_item )
	---[==[ 主角换技能 新手引导屏蔽层
	---------------------新手引导---------------------------------
	require "script/guide/NewGuide"
	if(NewGuide.guideClass == ksGuideChangeSkill) then
		require "script/guide/ChangeSkillGuide"
		ChangeSkillGuide.changLayer()
	end
	---------------------end-------------------------------------
	--]==]

	local skillList = ReplaceSkillData.getSkillList()
	print("tapLearnBtnCb...",skillList[p_tag].starId)
	print_t(ReplaceSkillData.remainInfoBySid(skillList[p_tag].starId))
	--当上次学艺翻牌奖励已经领取后
	if table.isEmpty(ReplaceSkillData.remainInfoBySid(skillList[p_tag].starId)) then
		--当天用户所有翻牌次数用完后
		if ReplaceSkillData.getFreeFlipNum() + ReplaceSkillData.getGoldFilpNum() <= 0 then
			SingleTip.showSingleTip(GetLocalizeStringBy("zz_74"))
			return
		end
		
		--若用户名将列表中不存在该名将模版则提示需要先获取该名将
		if skillList[p_tag].starId == nil then
			SingleTip.showSingleTip(GetLocalizeStringBy("zz_73"))
			return
		end
	end

	--记录选择学习的技能索引
	ReplaceSkillData.setSelectSkillIndex(p_tag)

	--更新当前信息
	local skillInfo = ReplaceSkillData.getSkillList()[p_tag]
	ReplaceSkillData.setCurMasterInfo(skillInfo.starId)

	--跳转界面
	LearnSkillLayer.showLayer()
end

--[[
	@desc :	技能预览按钮回调
	@param:	
	@ret  :
--]]
function tapPreviewBtnCb( p_tag, p_item )
	--记录选择查看的技能索引
	ReplaceSkillData.setSelectSkillIndex(p_tag)

	--AudioUtil.playEffect("audio/effect/guanbi.mp3")
	require "script/ui/replaceSkill/learnSkill/PreviewSkillLayer"
	PreviewSkillLayer.showLayer()
end

----------------------------------------新手引导-----------------------------------------
function getFirstCellBtn( ... )
	return _firstCellBtn
end

---[==[主角换技能 第3步
---------------------新手引导---------------------------------
function addGuideChangeSkillGuide3( ... )
	require "script/guide/NewGuide"
	require "script/guide/ChangeSkillGuide"
    if(NewGuide.guideClass ==  ksGuideChangeSkill and ChangeSkillGuide.stepNum == 2) then
        local button = getFirstCellBtn()
        local touchRect   = getSpriteScreenRect(button)
        ChangeSkillGuide.show(3, touchRect)
    end
end
