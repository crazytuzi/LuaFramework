-- Filename：	StarLayer.lua
-- Author：		Cheng Liang
-- Date：		2013-8-10
-- Purpose：		名将

module ("StarLayer", package.seeall)

require "script/network/RequestCenter"
require "script/model/DataCache"

require "script/utils/LuaUtil"
require "script/ui/main/MainScene"
require "script/ui/star/StarGiftCell"
require "script/ui/star/StarUtil"
require "script/libs/LuaCCLabel"
require "script/model/user/UserModel"
require "script/ui/tip/AnimationTip"
require "script/ui/star/StarSprite"
require "script/ui/star/StarDirLayer"
require "script/ui/star/StarAllAttrLayer"

require "script/network/PreRequest"

require "script/ui/star/StarAchieveLayer"
require "script/ui/star/StarAttrCell"


local Star_Img_Path = "images/star/intimate/"


local _curStarId 			= nil	-- 当前的star_id
local _allStarInfoArr 		= nil	-- 当前的所有star
local _curStarIndex 		= nil	-- 当前star的index

local _bgLayer 				= nil

---- TOP
local _fightValueLabel 		= nil	-- 战斗力
local _staminaLabel 		= nil	-- 耐力
local _silverLabel			= nil	-- 银币
local _goldLabel 			= nil	-- 金币

---- 等级经验
local _levelExpSprite		= nil	-- 等级经验

---- 单个名将的属性
local _starAttrSprite 		= nil	-- 单个名将的属性显示
local _starNameLabel 		= nil
local starNameBg			= nil	-- 名称背景
local _starLvLabel 			= nil	-- 名将等级

---- 底部UI
local _bottomSprite 		= nil	-- 底部UI
local _feelSprite			= nil	-- 增进感情的sprite

local _curChangeBtn 		= nil	-- 当前的按钮
local _isAddFeelStatus 		= true	-- 当前是增加感情的界面

local _addFeelBtn 			= nil	-- 增进感情的按钮
local _sendGiftBtn 			= nil	-- 赠送礼物的按钮
local _giftTableView 		= nil	-- 礼物Tableview
local _addStarExp 			= nil	-- 送礼物时候获得经验

local _actInfo_t 			= nil	-- 名将动作的相关奖励等等
local _act_id 				= nil	-- 点击的动作按钮的id

---- 名将的展示
local _starImgBorder 		= nil	-- 名将像的展示底
local _touchBeganPoint 		= nil	-- 第一次点击的坐标
local _curStarBodyImage 	= nil	-- 当前名将的全身像

local _isOnAnimation 		= false	-- 是否正在滑动

local _guideBtn 			= nil	-- 新手引导用

local _giftTableViewOffset 	= nil	-- tableview的偏移量
local _isSendGift 			= false -- 是否是送礼物
local _starScaleY 			= 0.32
local _gotoMatchBtn 		= nil	-- 去比武的按钮
local _gotoShopBtn 			= nil 	-- 去商店
local _giftTipLabel 		= nil 	-- 提示

local liezhuanBtn 			= nil 	-- 列传按钮

local _ratioGrow 			= 0

local progressSp			= nil

-- 展示属性
local _showMenuItem			= nil
local _attrTableView 		= nil

local _ability_t			= nil

local _curAchieveData 		= nil 	-- 刚刚达成的名将成就

-- 标题
local titleLabel 			= nil

local _oneKeyBtn 			= nil 	-- 一键赠送礼物按钮

local menuBar                       --按钮menu
local loyaltyTag = 9004
-----------------------

local function init()
	_bgLayer 				= nil
	_fightValueLabel 		= nil	-- 战斗力
	_staminaLabel 			= nil	-- 耐力
	_silverLabel 			= nil	-- 银币
	_goldLabel 				= nil	-- 金币
	_levelExpSprite			= nil	-- 等级经验
	_starAttrSprite 		= nil	-- 单个名将的属性显示
	_bottomSprite 			= nil	-- 底部UI
	_feelSprite				= nil	-- 增进感情的sprite
	_curChangeBtn 			= nil	-- 当前的按钮
	_addFeelBtn 			= nil	-- 增进感情的按钮
	_sendGiftBtn 			= nil	-- 赠送礼物的按钮
	_giftTableView 			= nil	-- 礼物Tableview
	_curStarId				= nil	-- 当前名将的id
	_allStarInfoArr			= nil	-- 所有名将数组
	_curStarIndex 			= nil	-- 当前star的index
	_actInfo_t 				= nil	-- 名将动作的相关奖励等等
	_isAddFeelStatus 		= true	-- 当前是增加感情的界面
	_act_id 				= nil	-- 点击的动作按钮的id
	_starImgBorder 			= nil	-- 名将像的展示底
	_touchBeganPoint 		= nil	-- 第一次点击的坐标
	_curStarBodyImage 		= nil	-- 当前名将的全身像
	_starNameLabel 			= nil
	starNameBg				= nil	-- 名称背景
	_isOnAnimation 			= false	-- 是否正在滑动
	_guideBtn 				= nil	-- 新手引导用
	_giftTableViewOffset 	= nil	-- tableview的偏移量
	_isSendGift 			= false -- 是否是送礼物
	_gotoMatchBtn 			= nil	-- 去比武的按钮
	_gotoShopBtn 			= nil 	-- 去商店
	_ratioGrow 				= 0
	progressSp				= nil
	_starLvLabel 			= nil	-- 名将等级
	_showMenuItem			= nil
	_attrTableView 			= nil
	_ability_t				= nil
	_curAchieveData			= nil
	attrCellHeight          = nil   --列表每个格子的高度
	titleLabel 				= nil
	_giftTipLabel 			= nil 	-- 提示
	menuBar = nil
end


-- 头部的UI
local function createTopUI()
	local topSprite = CCSprite:create(Star_Img_Path .. "top.png")
	topSprite:setAnchorPoint(ccp(0,1))
	topSprite:setPosition(ccp(0, _bgLayer:getContentSize().height))
	topSprite:setScale(g_fScaleX/MainScene.elementScale)
	_bgLayer:addChild(topSprite)

	-- 战斗力
    _fightValueLabel = CCRenderLabel:create(UserModel.getFightForceValue() , g_sFontName, 23, 1, ccc3( 0x00, 0x00, 0x00), type_stroke)
    -- _fightValueLabel:setSourceAndTargetColor(ccc3( 0x36, 0xff, 0x00), ccc3( 0x36, 0xff, 0x00));
    _fightValueLabel:setColor(ccc3(0xff, 0xf6, 0x00))
    _fightValueLabel:setPosition(108, 34)
    topSprite:addChild(_fightValueLabel,999)

    -- 耐力
    _staminaLabel = CCLabelTTF:create(UserModel.getStaminaNumber() .. "/" .. UserModel.getMaxStaminaNumber(), g_sFontName, 20)
	_staminaLabel:setColor(ccc3(0xff, 0xff, 0xff))
	_staminaLabel:setAnchorPoint(ccp(0, 0))
	_staminaLabel:setPosition(ccp(278, 10))
	topSprite:addChild(_staminaLabel)

	-- 银币
	-- modified by yangrui at 2015-12-03
	_silverLabel = CCLabelTTF:create(string.convertSilverUtilByInternational(UserModel.getSilverNumber()),g_sFontName,20)
	_silverLabel:setColor(ccc3(0xe5, 0xf9, 0xff))
	_silverLabel:setAnchorPoint(ccp(0, 0))
	_silverLabel:setPosition(ccp(402, 10))
	topSprite:addChild(_silverLabel)

	-- 金币
	_goldLabel = CCLabelTTF:create(UserModel.getGoldNumber(), g_sFontName, 20)
	_goldLabel:setColor(ccc3(0xff, 0xf6, 0x00))
	_goldLabel:setAnchorPoint(ccp(0, 0))
	_goldLabel:setPosition(ccp(522, 10))
	topSprite:addChild(_goldLabel)
end

-- 刷新上部的UI
function refreshTopUI()
	_fightValueLabel:setString(UserModel.getFightForceValue())
	_staminaLabel:setString(UserModel.getStaminaNumber() .. "/" .. UserModel.getMaxStaminaNumber())
	-- modified by yangrui at 2015-12-03
	_silverLabel:setString(string.convertSilverUtilByInternational(UserModel.getSilverNumber()))
	_goldLabel:setString(UserModel.getGoldNumber())


end
--刷新红点
function refreshTip( ... )
	--刷新聚义厅的红点
	local isShowTip = LoyaltyData.getIfRedIcon()
	local menuItem = getMainMenuItem( loyaltyTag )
	showTipSprite(menuItem,isShowTip)
end
-- 名将经验和等级
local function createLevelExpUI()
	if (_levelExpSprite) then
		_levelExpSprite:removeFromParentAndCleanup(true)
		_levelExpSprite = nil
	end
	_levelExpSprite = CCSprite:create( Star_Img_Path .. "intimatebg.png")
	_levelExpSprite:setAnchorPoint(ccp(0, 0))
	_levelExpSprite:setPosition(ccp( _bgLayer:getContentSize().width * 15/640, _bgLayer:getContentSize().height*250/960))
	_bgLayer:addChild(_levelExpSprite)

	-- 当前名将信息
	local curStarInfo = _allStarInfoArr[_curStarIndex]
	-- 等级 心
	if( tonumber(curStarInfo.level) > 0) then
		for i=1,tonumber(curStarInfo.level) do
			local heartSprite = CCSprite:create(Star_Img_Path .. "heart_b.png")
			heartSprite:setAnchorPoint(ccp(0.5,0.5))
			heartSprite:setPosition(ccp(93.5 + 41*(i-1), 62.5))
			_levelExpSprite:addChild(heartSprite)
		end
	end

	local needExp, levelExp = StarUtil.getExpProgress( tonumber(curStarInfo.total_exp), tonumber(curStarInfo.star_tid) )
	-- 经验条
	local fullRect = CCRectMake(0,0,46,23)
	local insetRect = CCRectMake(10,10,26,3)
	local expSprite = CCScale9Sprite:create(Star_Img_Path .. "exp_progress.png", fullRect, insetRect)
	expSprite:setPreferredSize(CCSizeMake(170.0*levelExp/needExp, 23))
	expSprite:setAnchorPoint(ccp(0, 0))
	expSprite:setPosition(ccp(95, 18))
	_levelExpSprite:addChild(expSprite)

	-- 经验值
	local expLabel = CCLabelTTF:create(levelExp .. "/" .. needExp, g_sFontName, 20)
	expLabel:setColor(ccc3(0xff, 0xff, 0xff))
	expLabel:setAnchorPoint(ccp(0.5, 0))
	expLabel:setPosition(ccp(180, 16))
	_levelExpSprite:addChild(expLabel)
	
end


-- 答题回调
function trigerCallbackFunc( text )
	local dialogSprite = CCSprite:create("images/star/triger/dialogbg.png")
	dialogSprite:setAnchorPoint(ccp(1, 0.5))
	dialogSprite:setPosition(ccp(_curStarBodyImage:getContentSize().width*0.55, _curStarBodyImage:getContentSize().height*0.7))

	local textLabel = CCRenderLabel:createWithAlign(text, g_sFontName, 18, 1,ccc3(0x45, 0x1c, 0x00), type_stroke,CCSizeMake(115, 80), kCCTextAlignmentLeft, kCCVerticalTextAlignmentCenter)
	textLabel:setColor(ccc3(0xff, 0xff, 0xff))
	textLabel:setPosition(ccp(14, 120))
	dialogSprite:addChild(textLabel)
	_curStarBodyImage:addChild(dialogSprite)
	refreshAllUI()
	local actEndCallback = function (  )
		dialogSprite:removeFromParentAndCleanup(true)
		dialogSprite = nil
	end

	local actionArr = CCArray:create()
	textLabel:runAction(CCFadeOut:create(5))
	actionArr:addObject(CCFadeOut:create(5))
	actionArr:addObject(CCCallFuncN:create(actEndCallback))

	dialogSprite:runAction(CCSequence:create(actionArr))
end

-- 动作回调获得的收益类型，。
-- 1银币，
-- 2金币，
-- 3将魂
-- 4耐力
-- 5体力
-- 6好感度（增加相应互动的名将的好感度）
-- 7经验（增加玩家的经验）
function feelActionCallback( cbFlag, dictData, bRet )
	if(dictData.err == "ok") then
		StarUtil.setLastOperatedStarId(_allStarInfoArr[_curStarIndex].star_id)
		if(_act_id)then
			for k, temp_act_info in pairs(_actInfo_t) do
				
				local prizeType = tonumber(temp_act_info.prizeType)
				local prizeNum = tonumber(temp_act_info.prizeNum)
				if( tonumber(temp_act_info.actid) == tonumber(_act_id )) then
					
					-- AnimationTip.showTip(temp_act_info.texts[math.mod(os.time(),3)+1])
					trigerCallbackFunc(temp_act_info.texts[math.mod(os.time(),3)+1])
					UserModel.changeStaminaNumber(-tonumber(temp_act_info.stamina))
					local tipText = ""
					if( prizeType == 1) then
						UserModel.changeSilverNumber(prizeNum)
						tipText = GetLocalizeStringBy("key_3326") .. prizeNum .. GetLocalizeStringBy("key_2019")
					elseif( prizeType == 2) then
						UserModel.changeGoldNumber(prizeNum)
						tipText = GetLocalizeStringBy("key_3326") .. prizeNum .. GetLocalizeStringBy("key_2876")
					elseif( prizeType == 3) then
						UserModel.addSoulNum(prizeNum)
						tipText = GetLocalizeStringBy("key_3326") .. prizeNum .. GetLocalizeStringBy("key_1507")
					elseif( prizeType == 4) then
						UserModel.changeStaminaNumber(prizeNum)
						tipText = GetLocalizeStringBy("key_3326") .. prizeNum .. GetLocalizeStringBy("key_2501")
					elseif( prizeType == 5) then
						UserModel.changeEnergyValue(prizeNum)
						tipText = GetLocalizeStringBy("key_3326") .. prizeNum .. GetLocalizeStringBy("key_2220")
					elseif( prizeType == 6) then
						DataCache.addExpToStar( _allStarInfoArr[_curStarIndex].star_id, prizeNum)
						tipText = GetLocalizeStringBy("key_3326") .. prizeNum .. GetLocalizeStringBy("key_1404")
					elseif( prizeType == 7) then
						UserModel.addExpValue(prizeNum,"starlayer")
						tipText = GetLocalizeStringBy("key_3326") .. prizeNum .. GetLocalizeStringBy("key_2612")
					end
					AnimationTip.showTip(tipText)
					break
				end
			end
			refreshAllUI()
		end
		if( tonumber(dictData.ret.trigerId) > 0) then
			require "script/ui/star/StarTriger"
			local layer = StarTriger.createLayer(_allStarInfoArr[_curStarIndex].star_id, tonumber(dictData.ret.trigerId), trigerCallbackFunc)
			local runningScene = CCDirector:sharedDirector():getRunningScene()
			runningScene:addChild(layer,99)
		end
	end

	
end

-- 动作：睡觉 按钮等等
local function feelBtnAction(tag, itemBtn)
	_act_id = tag
	local c_act_info = nil
	for i, act_info in pairs(_actInfo_t) do
		if( tonumber(act_info.actid) == _act_id ) then
			c_act_info = act_info
			break
		end
	end

	if(c_act_info.stamina <= UserModel.getStaminaNumber()) then
		local args = Network.argsHandler(_allStarInfoArr[_curStarIndex].star_id, tag)
		RequestCenter.star_addFavorByAct(feelActionCallback, args)
	else
		AnimationTip.showTip(GetLocalizeStringBy("key_1853"))
	end
end 

local function changeMenuAction( tag, itemBtn )
	itemBtn:selected()
	if(_curChangeBtn and _curChangeBtn == itemBtn) then

	else
		_curChangeBtn:unselected()
		_curChangeBtn = itemBtn
		_curChangeBtn:selected()

		if(_curChangeBtn == _addFeelBtn) then
			_feelSprite:setVisible(true)
			_giftTableView:setVisible(false)
			_isAddFeelStatus = true
		else
			_feelSprite:setVisible(false)
			_giftTableView:setVisible(true)
			_isAddFeelStatus = false
		end
	end
end

-- 使用礼物回调
function sendGiftCallback( cbFlag, dictData, bRet )
	if(dictData.err == "ok") then
		
		local f_level = StarUtil.getStarLevelBySid(_allStarInfoArr[_curStarIndex].star_id)
		if(dictData.ret == "true" or dictData.ret == true)then
			-- 暴击
			DataCache.addLevelToStar(_allStarInfoArr[_curStarIndex].star_id, 1)
			starCritEffect()
		else
			-- 非暴击
			DataCache.addExpToStar(_allStarInfoArr[_curStarIndex].star_id, _addStarExp, _ratioGrow)
			startEffect()
		end

		StarUtil.setLastOperatedStarId(_allStarInfoArr[_curStarIndex].star_id)
		
		_isSendGift = true
		
		local m_tipText = GetLocalizeStringBy("key_1692") .. _addStarExp

		local s_level = StarUtil.getStarLevelBySid(_allStarInfoArr[_curStarIndex].star_id)
		if(s_level > f_level)then
			
			local ability_t = StarUtil.getAttributeInfos(tonumber(_allStarInfoArr[_curStarIndex].star_tid), _allStarInfoArr[_curStarIndex].level)
			local t_text = {}
			for i=f_level+1, s_level do
				local ability_info = ability_t[i]
				if( ability_info.is_highLight ) then
					local o_text = {}
					o_text.txt = ability_info.name
					o_text.num = ability_info.num
					table.insert(t_text, o_text)
					-- 如果是耐力上限
					if(ability_info.a_id == -1)then
						UserModel.addStaminaMaxNumber(ability_info.num)
					end
				end
			end

			local t_ability_temp, all_levels = StarUtil.getTotalStarAttr()
			local t_achieve_text, m_achiveData = StarUtil.getOneStarAchieveBy(all_levels, (s_level - f_level) )

			if(not table.isEmpty(t_achieve_text))then
				_curAchieveData = m_achiveData
				local actionArr = CCArray:create()
				actionArr:addObject(CCDelayTime:create(1))
				actionArr:addObject(CCCallFuncN:create(showStarAchieveEffect))
				_bgLayer:runAction(CCSequence:create(actionArr))
				if(_curAchieveData.add_max_stamina)then
					UserModel.addStaminaMaxNumber(tonumber(_curAchieveData.add_max_stamina))
				end
				--增加体力上限
				if(_curAchieveData.add_max_execution) then
					UserModel.addExecutionMaxNumber(tonumber(_curAchieveData.add_max_execution))
				end
			end
			m_tipText = m_tipText .. GetLocalizeStringBy("key_3026") .. (s_level-f_level) .. GetLocalizeStringBy("key_2469")
			require "script/utils/LevelUpUtil"
			LevelUpUtil.showFlyText(t_text)
			refreshAllUI()
			----- 头部的UI
			refreshTopUI()

			-- 强制刷新缓存数据
			StarUtil.getStarAddNumBy( _allStarInfoArr[_curStarIndex].star_tid, true)
		else
			-- createLevelExpUI()
		end

		if(dictData.ret ~= "true" and dictData.ret ~= true )then
			AnimationTip.showTip(m_tipText)
		end



	end
end

-- 名将送礼的特效 added by zhz.
function startEffect(  )
	local img_path = CCString:create("images/pet/effect/chongwuweiyang/chongwuweiyang") 
	local addPetEffect = CCLayerSprite:layerSpriteWithNameAndCount(img_path:getCString(), 1,CCString:create(""))
	-- music
	if(file_exists("images/pet/effect/chongwuweiyang.mp3")) then
    	require "script/audio/AudioUtil"
    	AudioUtil.playEffect("images/pet/effect/chongwuweiyang.mp3")
	end
	addPetEffect:setPosition(ccp(_bgLayer:getContentSize().width*0.5,_bgLayer:getContentSize().height*0.6))
	addPetEffect:setAnchorPoint(ccp(0,0))
	_bgLayer:addChild(addPetEffect, 1000)
end

-- 名将送礼暴击的特效 added by zhz
function starCritEffect( )
	local img_path = CCString:create("images/base/effect/star/hgts/hgts") 
	local addPetEffect = CCLayerSprite:layerSpriteWithNameAndCount(img_path:getCString(), 1,CCString:create(""))
	-- music
	if(file_exists("images/pet/effect/chongwuweiyang.mp3")) then
    	require "script/audio/AudioUtil"
    	AudioUtil.playEffect("images/pet/effect/chongwuweiyang.mp3")
	end
	addPetEffect:setPosition(ccp(_bgLayer:getContentSize().width*0.5,_bgLayer:getContentSize().height*0.35))
	addPetEffect:setAnchorPoint(ccp(0.5,0))
	_bgLayer:addChild(addPetEffect, 1000)
end

-- 名将界面动画
function addStarAnimation()
	local effect_path = CCString:create("images/base/effect/star/glow/glow") 
	local starEffect_left = CCLayerSprite:layerSpriteWithNameAndCount(effect_path:getCString(), -1,CCString:create(""))
	starEffect_left:setPosition(ccp(_bgLayer:getContentSize().width*0.5,_bgLayer:getContentSize().height*0.5))
	-- starEffect_left:setAnchorPoint(ccp(0.5,0))
	_bgLayer:addChild(starEffect_left)


end

-- 名将成就达成特效
function showStarAchieveEffect()
	-- 计算
 --    local t_ability_temp, all_levels = StarUtil.getTotalStarAttr()
	-- local t_achieve_text, m_achiveData = StarUtil.getOneStarAchieveBy(all_levels)


	local img_path = CCString:create("images/base/effect/star/achieve/chengjiukuang") 
	local addAchieveEffect = CCLayerSprite:layerSpriteWithNameAndCount(img_path:getCString(), 1,CCString:create(""))
	
    
	-- icon
	local iconSprite = StarUtil.getStarAchieveIconSprite(_curAchieveData, false)
	local replaceXmlSprite_1 = tolua.cast( addAchieveEffect:getChildByTag(1003) , "CCXMLSprite")

    local img_path_2 = CCString:create("images/base/effect/star/lineRotation/lineRotation") 
	local addAchieveEffect_2 = CCLayerSprite:layerSpriteWithNameAndCount(img_path_2:getCString(), -1,CCString:create(""))
	addAchieveEffect_2:setPosition(ccp(60, 60))
	replaceXmlSprite_1:addChild(addAchieveEffect_2)
	replaceXmlSprite_1:addChild(iconSprite)

	-- 属性加成
	local replaceXmlSprite_2 = tolua.cast( addAchieveEffect:getChildByTag(1000) , "CCXMLSprite")
    
    local textStr = StarUtil.getStringAchieveAttrBy(_curAchieveData)
    local attrTextLabel = CCRenderLabel:create( GetLocalizeStringBy("key_1944") .. textStr, g_sFontName, 21, 2, ccc3( 0x00, 0x00, 0x00), type_stroke)
	attrTextLabel:setAnchorPoint(ccp(0, 0))
	attrTextLabel:setColor(ccc3(0x00, 0xff, 0x18))
	attrTextLabel:setPosition(ccp(50, 10))
	replaceXmlSprite_2:addChild(attrTextLabel)

	-- title
	local starNumTitleLabel = CCRenderLabel:create(_curAchieveData.name, g_sFontPangWa, 25, 1, ccc3(0, 0, 0), type_stroke)
	starNumTitleLabel:setColor(ccc3(0x00, 0xe4, 0xff))
    starNumTitleLabel:setAnchorPoint(ccp(0, 0))
    starNumTitleLabel:setPosition(ccp(45, 40))
    replaceXmlSprite_2:addChild(starNumTitleLabel)

	addAchieveEffect:setPosition(ccp(_bgLayer:getContentSize().width*0.5,_bgLayer:getContentSize().height*0.6))
	addAchieveEffect:setAnchorPoint(ccp(0.5,0))
	_bgLayer:addChild(addAchieveEffect, 1000)
	
end


-- 创建礼物的tableview
local function createGiftTableView( )
	-- local gift_infos = StarUtil.getStarGiftByStarTmplId(_allStarInfoArr[_curStarIndex].star_tid)
	local gift_infos = ItemUtil.getAllStarGifts()
	if(_gotoMatchBtn) then
		if(#gift_infos > 0)then
			_gotoMatchBtn:setVisible(false)
			_gotoShopBtn:setVisible(false)
			_giftTipLabel:setVisible(false)
		else
			_gotoMatchBtn:setVisible(true)
			_gotoShopBtn:setVisible(true)
			_giftTipLabel:setVisible(true)
		end
	end
	local cellSize = CCSizeMake(110, 125)
	local h = LuaEventHandler:create(function(fn, table, a1, a2) 	--创建
		local r
		if fn == "cellSize" then
			-- r = CCSizeMake(cellSize.width * myScale, cellSize.height * myScale)

			r = cellSize

		elseif fn == "cellAtIndex" then
            a2 = StarGiftCell.createCell(gift_infos[a1+1])
			r = a2
		elseif fn == "numberOfCells" then
			local num = #gift_infos
			r = num
		elseif fn == "cellTouched" then
			
			---[==[名将 清除新手引导
			---------------------新手引导---------------------------------
			--add by licong 2013.09.29
			require "script/guide/NewGuide"
			if(NewGuide.guideClass == ksGuideGreatSoldier) then
				require "script/guide/StarHeroGuide"
				StarHeroGuide.cleanLayer()
				NewGuide.guideClass = ksGuideClose
				BTUtil:setGuideState(false)
				NewGuide.saveGuideClass()
			end
			---------------------end-------------------------------------
			--]==]
			if(tonumber(gift_infos[a1:getIdx()+1].item_num) > 0) then
				if(tonumber(_allStarInfoArr[_curStarIndex].level) < #_ability_t ) then

					if( UserModel.getHeroLevel()< _ability_t[tonumber(_allStarInfoArr[_curStarIndex].level)+1].lvLimited)then
						AnimationTip.showTip(GetLocalizeStringBy("key_2713"))
						return
					end

					require "db/DB_Item_star_gift"
					local gift_data = DB_Item_star_gift.getDataById(tonumber(gift_infos[a1:getIdx()+1].item_template_id))
					_addStarExp = tonumber(gift_data.coins)
					_ratioGrow = tonumber(gift_data.ratioGrow)
					PreRequest.setBagDataChangedDelete(bagChangedDelegateFunc)
					local args = Network.argsHandler(tonumber(_allStarInfoArr[_curStarIndex].star_id), gift_infos[a1:getIdx()+1].item_template_id, 1)
					RequestCenter.star_addFavorByGift(sendGiftCallback, args)

				else
					AnimationTip.showTip(GetLocalizeStringBy("key_2304"))
				end
			else
				AnimationTip.showTip(GetLocalizeStringBy("key_2583"))
			end

		elseif (fn == "scroll") then
			
		end
		return r
	end)

	_giftTableView = LuaTableView:createWithHandler(h, CCSizeMake(550, 125))
	_giftTableView:setBounceable(true)
	_giftTableView:setDirection(kCCScrollViewDirectionHorizontal)
	_giftTableView:setPosition(ccp(22, 10))
	_giftTableView:setVerticalFillOrder(kCCTableViewFillTopDown)
	_bottomSprite:addChild(_giftTableView)
	_giftTableView:setVisible(false)	
end

-- 底部界面
function createBottomUI()
	_curChangeBtn = nil

	if(_giftTableView)then

		_giftTableViewOffset = _giftTableView:getContentOffset()
		print("_giftTableViewOffset===", _giftTableViewOffset.x)

	end
	if( _bottomSprite) then
		_bottomSprite:removeFromParentAndCleanup(true)
		_bottomSprite = nil
	end

	local fullRect = CCRectMake(0,0,75,75)
	local insetRect = CCRectMake(30,30,15,15)
	_bottomSprite = CCScale9Sprite:create(Star_Img_Path .. "bottom9s.png", fullRect, insetRect)
	_bottomSprite:setContentSize(CCSizeMake(575, 200))
	_bottomSprite:setAnchorPoint(ccp(0.5, 0))
	_bottomSprite:setPosition(ccp(_bgLayer:getContentSize().width/2, _bgLayer:getContentSize().height * 0.015))
	_bgLayer:addChild(_bottomSprite)

--------------- 两个标签按钮 --------------
	local menuBar_b = CCMenu:create()
	menuBar_b:setPosition(ccp(0,0))
	-- _bottomSprite:addChild(menuBar_b)
	-- 增进感情按钮
	_addFeelBtn = LuaCC.create9ScaleMenuItem( Star_Img_Path .. "btn_bg_n.png", Star_Img_Path .. "btn_bg_h.png",CCSizeMake(192, 61), GetLocalizeStringBy("key_1415"),ccc3(0xfe, 0xdb, 0x1c),30,g_sFontPangWa,1, ccc3(0x00, 0x00, 0x00))
	_addFeelBtn:setAnchorPoint(ccp(0, 0))
	_addFeelBtn:setPosition(ccp(70,  11))
	_addFeelBtn:registerScriptTapHandler(changeMenuAction)
	
	menuBar_b:addChild(_addFeelBtn)

	-- 赠送礼物按钮
	_sendGiftBtn = LuaCC.create9ScaleMenuItem( Star_Img_Path .. "btn_bg_n.png", Star_Img_Path .. "btn_bg_h.png",CCSizeMake(192, 61), GetLocalizeStringBy("key_1982"),ccc3(0xfe, 0xdb, 0x1c),30,g_sFontPangWa,1, ccc3(0x00, 0x00, 0x00))
	_sendGiftBtn:setAnchorPoint(ccp(0, 0))
	_sendGiftBtn:setPosition(ccp(310,  11))
	_sendGiftBtn:registerScriptTapHandler(changeMenuAction)
	menuBar_b:addChild(_sendGiftBtn)

--------------- 增进感情 ------------------------
	_feelSprite = CCSprite:create()
	_feelSprite:setContentSize(_bottomSprite:getContentSize())
	-- _bottomSprite:addChild(_feelSprite)
--[[
	-- 4种按钮
	local feelMenuBar = CCMenu:create()
	feelMenuBar:setPosition(ccp(0,0))
	_feelSprite:addChild(feelMenuBar)

	_actInfo_t = StarUtil.getStarActInfosBy(tonumber(_allStarInfoArr[_curStarIndex].star_tid), tonumber(_allStarInfoArr[_curStarIndex].level))

	-- local text_t = {GetLocalizeStringBy("key_1448"), GetLocalizeStringBy("key_1975"), GetLocalizeStringBy("key_2071"), GetLocalizeStringBy("key_1163")}
	local xPosition_t = {25, 135+25, 270+25, 405+25}

	for i, act_info in pairs(_actInfo_t) do

		-- 按钮
		local fellBtn = LuaCC.create9ScaleMenuItem( Star_Img_Path .. "btn_blue_n.png", Star_Img_Path .. "btn_blue_h.png",CCSizeMake(119, 64),act_info.btnName,ccc3(0xfe, 0xdb, 0x1c),30,g_sFontPangWa,2, ccc3(0x00, 0x00, 0x5d))
		fellBtn:setAnchorPoint(ccp(0, 0))
		fellBtn:setPosition(ccp(xPosition_t[i], 135))
		fellBtn:registerScriptTapHandler(feelBtnAction)
		feelMenuBar:addChild(fellBtn, 2, act_info.actid)
		-- 新手引导
		if(i==1)then
			_guideBtn = fellBtn
		end

		-- 耐力
		local staminaTitleLabel = LuaCCLabel.createShadowLabel(GetLocalizeStringBy("key_2021"), g_sFontName, 20)
		staminaTitleLabel:setColor(ccc3(0xff, 0xff, 0xff))
		staminaTitleLabel:setAnchorPoint(ccp(0, 0))
		staminaTitleLabel:setPosition(ccp(xPosition_t[i]+15, 115))
		_feelSprite:addChild(staminaTitleLabel)
		-- 耐力值
		local staminaLabel = LuaCCLabel.createShadowLabel("-" .. act_info.stamina, g_sFontName, 18)
		staminaLabel:setColor(ccc3(0x00, 0xeb, 0x21))
		staminaLabel:setAnchorPoint(ccp(0, 0))
		staminaLabel:setPosition(ccp(xPosition_t[i]+60, 115))
		_feelSprite:addChild(staminaLabel)

		-- 获得的东东
		local rewardLabel = LuaCCLabel.createShadowLabel(act_info.reward_name, g_sFontName, 18)
		rewardLabel:setColor(ccc3(0xff, 0xff, 0xff))
		rewardLabel:setAnchorPoint(ccp(0, 0))
		rewardLabel:setPosition(ccp(xPosition_t[i]+15, 85))
		_feelSprite:addChild(rewardLabel)
		-- 值
		if(act_info.prizeNum)then
			local rewardNumLabel = LuaCCLabel.createShadowLabel("+" .. act_info.prizeNum, g_sFontName, 18)
			rewardNumLabel:setColor(ccc3(0x00, 0xeb, 0x21))
			rewardNumLabel:setAnchorPoint(ccp(0, 0))
			rewardNumLabel:setPosition(ccp(xPosition_t[i]+75, 85))
			_feelSprite:addChild(rewardNumLabel)
		end
	end
	
	-- 三条竖线
	for i=1,3 do
		local lineSprite = CCSprite:create(Star_Img_Path .. "line.png")
		lineSprite:setAnchorPoint(ccp(0,0))
		lineSprite:setPosition(ccp(10 + 137 *i, 85))
		lineSprite:setScaleY(1.5)
		_feelSprite:addChild(lineSprite)
	end
--]]
-------------- 赠送礼物 ----------
	local curStarInfo = _allStarInfoArr[_curStarIndex]

	local tipLabel = LuaCCLabel.createShadowLabel(GetLocalizeStringBy("key_2473"), g_sFontName, 18)
	tipLabel:setColor(ccc3(0xff, 0xff, 0xff))
	tipLabel:setAnchorPoint(ccp(0,0.5))
	tipLabel:setPosition(ccp(_bottomSprite:getContentSize().width*0.05, _bottomSprite:getContentSize().height*0.91))
	_bottomSprite:addChild(tipLabel)

	local rate = StarUtil.calStarUpgradeRateBy(curStarInfo  )
	local needExp, levelExp = StarUtil.getExpProgress( tonumber(curStarInfo.total_exp), tonumber(curStarInfo.star_tid) )

	local bgProress = CCScale9Sprite:create("images/common/exp_bg.png")
	bgProress:setContentSize(CCSizeMake(520, 23))
	bgProress:setAnchorPoint(ccp(0.5, 0.5))
	bgProress:setPosition(ccp(_bottomSprite:getContentSize().width*0.5, _bottomSprite:getContentSize().height*0.78))
	_bottomSprite:addChild(bgProress)
	
	--经验条满级和非满级的相关处理
	local expStr, expWidth = nil, nil
	local maxSp = nil
	if levelExp == 0 and needExp == 0 then
		--好感满级时
		expStr = ""
		expWidth = 520
		maxSp = CCSprite:create("images/common/max.png")
		maxSp:setScale(0.7)
		maxSp:setAnchorPoint(ccp(0.5,0.5))
		maxSp:setPosition(260,12)
		bgProress:addChild(maxSp,2)
	else
		expStr = levelExp .. "/" .. needExp
		expWidth = 520 * levelExp/needExp
	end

	progressSp = CCScale9Sprite:create("images/common/exp_progress.png")
	progressSp:setContentSize(CCSizeMake(expWidth, 23))
	progressSp:setAnchorPoint(ccp(0, 0.5))
	progressSp:setPosition(ccp(0, bgProress:getContentSize().height * 0.5))
	bgProress:addChild(progressSp,1)

	-- 经验值
	local expLabel = CCLabelTTF:create(expStr, g_sFontName, 20)
	expLabel:setColor(ccc3(0xff, 0xff, 0xff))
	expLabel:setAnchorPoint(ccp(0.5, 0.5))
	expLabel:setPosition(ccp(bgProress:getContentSize().width*0.5, bgProress:getContentSize().height*0.5))
	bgProress:addChild(expLabel,2)

	-- 经验值
	rate = string.format("%.4f", rate)
	local pLabel = CCRenderLabel:create( (tonumber(rate) * 100 ) .. "%", g_sFontName, 20, 2, ccc3( 0x00, 0x00, 0x00), type_stroke)
	pLabel:setColor(ccc3(0x36, 0xff, 0x00))
	pLabel:setAnchorPoint(ccp(0, 0.5))
	pLabel:setPosition(ccp(_bottomSprite:getContentSize().width*0.05 + tipLabel:getContentSize().width+5 ,  _bottomSprite:getContentSize().height*0.91))
	_bottomSprite:addChild(pLabel)

	-- 前往商店
	local menuBar_g = CCMenu:create()
	menuBar_g:setPosition(ccp(0,0))
	_bottomSprite:addChild(menuBar_g)
	_gotoShopBtn  = LuaCC.create9ScaleMenuItem("images/common/btn/btn1_d.png","images/common/btn/btn1_n.png",CCSizeMake(200, 73),GetLocalizeStringBy("key_1408"),ccc3(0xfe, 0xdb, 0x1c),35,g_sFontPangWa,1, ccc3(0x00, 0x00, 0x00))
	_gotoShopBtn:setAnchorPoint(ccp(0.5, 0.5))
    _gotoShopBtn:setPosition(ccp(_bottomSprite:getContentSize().width*0.3, _bottomSprite:getContentSize().height*0.4))
    _gotoShopBtn:registerScriptTapHandler(gotoShopAction)
	menuBar_g:addChild(_gotoShopBtn)
	_gotoShopBtn:setVisible(false)

	-- 前往竞技
	local menuBar_g = CCMenu:create()
	menuBar_g:setPosition(ccp(0,0))
	_bottomSprite:addChild(menuBar_g)
	_gotoMatchBtn = LuaCC.create9ScaleMenuItem("images/common/btn/btn1_d.png","images/common/btn/btn1_n.png",CCSizeMake(200, 73),GetLocalizeStringBy("key_1279"),ccc3(0xfe, 0xdb, 0x1c),35,g_sFontPangWa,1, ccc3(0x00, 0x00, 0x00))
	_gotoMatchBtn:setAnchorPoint(ccp(0.5, 0.5))
    _gotoMatchBtn:setPosition(ccp(_bottomSprite:getContentSize().width*0.7, _bottomSprite:getContentSize().height*0.4))
    _gotoMatchBtn:registerScriptTapHandler(gotoMatchAction)
	menuBar_g:addChild(_gotoMatchBtn)
	_gotoMatchBtn:setVisible(false)

	-- 前往的提示
	_giftTipLabel = CCRenderLabel:create(GetLocalizeStringBy("key_1758"), g_sFontPangWa, 24, 1, ccc3( 0x00, 0x00, 0x00), type_stroke)
    _giftTipLabel:setColor(ccc3(0xff, 0xff, 0xff))
    _giftTipLabel:setAnchorPoint(ccp(0.5, 0))
    _giftTipLabel:setPosition( ccp(_bottomSprite:getContentSize().width*0.5, _bottomSprite:getContentSize().height*0.08))
    _bottomSprite:addChild(_giftTipLabel)


	---
	createGiftTableView()
	print("if ===== _giftTableViewOffset")
	if(_giftTableViewOffset ~= nil) then
		print("_giftTableViewOffset99099090009999===", _giftTableViewOffset.x)
		_giftTableView:setContentOffset(_giftTableViewOffset)

	end

	if(_isAddFeelStatus)then
		_curChangeBtn = _addFeelBtn
		_curChangeBtn:selected()
		_sendGiftBtn:unselected()

		_feelSprite:setVisible(true)
		_giftTableView:setVisible(false)

	else
		_curChangeBtn = _sendGiftBtn
		_curChangeBtn:selected()
		_addFeelBtn:unselected()

		_feelSprite:setVisible(false)
		_giftTableView:setVisible(true)
		-- _giftTableView:setContentOffset(ccp(-220,0))
		
	end

	

	--
	_giftTableView:setVisible(true)
end 

-- 前往竞技
function gotoMatchAction( tag, item )
	require "script/audio/AudioUtil"
	AudioUtil.playEffect("audio/effect/zhujiemian.mp3")
	if(ItemUtil.isBagFull() == true )then

		return
	end
	-- 判断武将满了
	require "script/ui/hero/HeroPublicUI"
    if HeroPublicUI.showHeroIsLimitedUI() then
    	return
    end
	local canEnter = DataCache.getSwitchNodeState( ksSwitchArena )
	if( canEnter ) then
		require "script/ui/arena/ArenaLayer"
		local arenaLayer = ArenaLayer.createArenaLayer()
		MainScene.changeLayer(arenaLayer, "arenaLayer")
	end

end

-- 前往商店
function gotoShopAction( tag, item )
	require "script/audio/AudioUtil"
	AudioUtil.playEffect("audio/effect/zhujiemian.mp3")
	if( DataCache.getSwitchNodeState( ksSwitchShop ) ) then
		require "script/ui/shop/ShopLayer"
		local  shopLayer = ShopLayer.createLayer(ShopLayer.Tag_Shop_Prop)
		MainScene.changeLayer(shopLayer, "shopLayer", ShopLayer.layerWillDisappearDelegate)
	end
end

-- 创建名将的全身像
function createStarSprite()
	-- 名将全身像
	--_curStarBodyImage = StarSprite.createStarSprite( _allStarInfoArr[_curStarIndex].star_htid )
	local tempTid = HeroUtil.getOnceOrangeHtid(_allStarInfoArr[_curStarIndex].star_tid)
	_curStarBodyImage = StarSprite.createStarSprite( tempTid )
	_curStarBodyImage:setAnchorPoint(ccp(0.5, 0))

	local bodyOffset = HeroUtil.getHeroBodySpriteOffsetByHTID(tempTid)
	_curStarBodyImage:setPosition(ccp( _bgLayer:getContentSize().width * 0.5, _bgLayer:getContentSize().height * _starScaleY-bodyOffset))
	_bgLayer:addChild(_curStarBodyImage)

end

-- 创建名将的名称
local function createNameUI( )
	starNameBg = CCSprite:create(Star_Img_Path .. "namebg.png")
	starNameBg:setAnchorPoint(ccp(0.5, 0))
	starNameBg:setPosition(ccp( _bgLayer:getContentSize().width * 0.5, _bgLayer:getContentSize().height * 260/960))
	_bgLayer:addChild(starNameBg, 100)

	-- 当前名将信息
	local curStarInfo = _allStarInfoArr[_curStarIndex]
	require "db/DB_Star"
	local starDesc = DB_Star.getDataById(tonumber(curStarInfo.star_tid))

	-- 等级
	_starLvLabel = CCRenderLabel:create(curStarInfo.level, g_sFontPangWa, 23, 1, ccc3( 0x00, 0x00, 0x00), type_stroke)
    _starLvLabel:setColor(ccc3(0xff, 0xe4, 0x00))
    _starLvLabel:setAnchorPoint(ccp(1,0.5))
    _starLvLabel:setPosition(ccp( starNameBg:getContentSize().width*0.3, starNameBg:getContentSize().height*0.5))
    starNameBg:addChild(_starLvLabel)

	-- 心
	local heartSprite = CCSprite:create(Star_Img_Path .. "heart_b.png")
	heartSprite:setAnchorPoint(ccp(0.5,0.5))
	heartSprite:setPosition(ccp(starNameBg:getContentSize().width*0.4, starNameBg:getContentSize().height*0.5))
	starNameBg:addChild(heartSprite)

	-- 名称
	_starNameLabel = LuaCCLabel.createShadowLabel(starDesc.name, g_sFontName, 23)
	_starNameLabel:setColor(ccc3(0xff, 0xe4, 0x65))
	_starNameLabel:setAnchorPoint(ccp(0,0.5))
	_starNameLabel:setPosition(ccp(starNameBg:getContentSize().width*0.5, starNameBg:getContentSize().height*0.5))
	starNameBg:addChild(_starNameLabel)

end

-- 刷新名将的名称
function refreshStarNameLabel()
	local curStarInfo = _allStarInfoArr[_curStarIndex]
	require "db/DB_Star"
	local starDesc = DB_Star.getDataById(tonumber(curStarInfo.star_tid))
	if(_starNameLabel)then
		_starNameLabel:removeFromParentAndCleanup(true)
		_starNameLabel = nil
	end

	-- 名称
	_starNameLabel = LuaCCLabel.createShadowLabel(starDesc.name, g_sFontName, 23)
	_starNameLabel:setColor(ccc3(0xff, 0xe4, 0x65))
	_starNameLabel:setAnchorPoint(ccp(0,0.5))
	_starNameLabel:setPosition(ccp(starNameBg:getContentSize().width*0.5, starNameBg:getContentSize().height*0.5))
	starNameBg:addChild(_starNameLabel)

	_starLvLabel:setString(curStarInfo.level)

	-- 属性标题
	titleLabel:setString(starDesc.name.. GetLocalizeStringBy("key_2835"))

end

-- 名将属性加成UI
local function createStarAttr()

	if(_starAttrSprite) then
		_starAttrSprite:removeFromParentAndCleanup(true)
		_starAttrSprite = nil
	end

	-- 背景
	local fullRect = CCRectMake(0,0,75,75)
	local insetRect = CCRectMake(30,30,15,15)
	_starAttrSprite = CCScale9Sprite:create(Star_Img_Path .. "attr9s.png", fullRect, insetRect)
	_starAttrSprite:setContentSize(CCSizeMake(255, 350))
	_starAttrSprite:setAnchorPoint(ccp(0, 0.5))
	_starAttrSprite:setPosition(ccp( _bgLayer:getContentSize().width +  54*MainScene.elementScale , _bgLayer:getContentSize().height * 555/960))
	_bgLayer:addChild(_starAttrSprite, 10)

	-- 隐藏属性
	local menuBarB = CCMenu:create()
	menuBarB:setPosition(ccp(0, 0))
	_starAttrSprite:addChild(menuBarB, 10)
	local hiddenMenuItem = CCMenuItemImage:create("images/star/btn_hidden_n.png", "images/star/btn_hidden_h.png")
	hiddenMenuItem:setAnchorPoint(ccp(1, 0.5))
	hiddenMenuItem:registerScriptTapHandler(showOrHiddenAttrUI)
    hiddenMenuItem:setPosition(ccp(6, _starAttrSprite:getContentSize().height*0.5))
    menuBarB:addChild(hiddenMenuItem, 2, 81002)

	-- 标题
	local curStarInfo = _allStarInfoArr[_curStarIndex]
	require "db/DB_Star"
	local starDesc = DB_Star.getDataById(tonumber(curStarInfo.star_tid))
	titleLabel = CCLabelTTF:create(starDesc.name .. GetLocalizeStringBy("key_2835"), g_sFontName, 25)
	titleLabel:setColor(ccc3(0x78, 0x25, 0x00))
	titleLabel:setAnchorPoint(ccp(0.5, 1))
	titleLabel:setPosition(ccp(_starAttrSprite:getContentSize().width*0.5, _starAttrSprite:getContentSize().height*0.97))
	_starAttrSprite:addChild(titleLabel)

	-- 背景2
	local fullRect_2 = CCRectMake(0,0,75,75)
	local insetRect_2 = CCRectMake(30,30,15,15)
	local starAttrSprite_2 = CCScale9Sprite:create(Star_Img_Path .. "attr9s_2.png", fullRect, insetRect)
	starAttrSprite_2:setContentSize(CCSizeMake(250, 310))
	starAttrSprite_2:setAnchorPoint(ccp(0.5, 0))
	starAttrSprite_2:setPosition(ccp( _starAttrSprite:getContentSize().width * 0.5, 2))
	_starAttrSprite:addChild(starAttrSprite_2)

-- 创建 属性TableView
	createAttrTableView( starAttrSprite_2 )
end

-- 刷新 属性Tableview
function refreshAttrTableView()
	local curStarInfo = _allStarInfoArr[_curStarIndex]
	_ability_t = StarUtil.getAttributeInfos(tonumber(curStarInfo.star_tid), curStarInfo.level)

	_attrTableView:reloadData()
	--add by zhang zihang
	local myScale = _bgLayer:getContentSize().width/640/MainScene.elementScale
	if tonumber(curStarInfo.level) >= 47 then
		_attrTableView:setContentOffset(ccp(0,20))
	elseif tonumber(curStarInfo.level) >=4 then
		_attrTableView:setContentOffset(ccp(0,-attrCellHeight*(47-curStarInfo.level)+20*myScale))
	end

end

-- 创建 属性TableView
function createAttrTableView( starAttrSprite_2 )
	-- 当前名将信息
	local curStarInfo = _allStarInfoArr[_curStarIndex]
	-- _ability_t = StarUtil.getAttributeInfos(tonumber(curStarInfo.star_tid), curStarInfo.level)
	_ability_t = {}
	local myScale = _bgLayer:getContentSize().width/640/MainScene.elementScale

	local cellSize = CCSizeMake(250,46)			--计算cell大小
	attrCellHeight = cellSize.height*myScale

	local h = LuaEventHandler:create(function(fn, table, a1, a2) 	--创建
		local r
		if fn == "cellSize" then
			r = CCSizeMake(cellSize.width*myScale, cellSize.height*myScale)
		elseif fn == "cellAtIndex" then

            a2 = StarAttrCell.createCell(_ability_t[a1 + 1], a1+1 )
            a2:setScale(myScale)
			r = a2
		elseif fn == "numberOfCells" then
			r = #_ability_t
		elseif fn == "cellTouched" then
		elseif (fn == "scroll") then
		end
		return r
	end)
	_attrTableView = LuaTableView:createWithHandler(h, CCSizeMake(starAttrSprite_2:getContentSize().width, starAttrSprite_2:getContentSize().height-10))
    _attrTableView:setAnchorPoint(ccp(0,0))
	_attrTableView:setBounceable(true)
	_attrTableView:setPosition(ccp(0, 5))
	_attrTableView:setVerticalFillOrder(kCCTableViewFillTopDown)
	starAttrSprite_2:addChild(_attrTableView)

	refreshAttrTableView()
end


-- 进入名将录 或者 属性总览
function starMenuAction( tag, itembtn )
	-- 音效
	require "script/audio/AudioUtil"
	AudioUtil.playEffect("audio/effect/zhujiemian.mp3")
	if(tag == 91001) then
		local dirLayer = StarDirLayer.createLayer()
		MainScene.changeLayer(dirLayer, "dirLayer")
	elseif(tag == 91002)then
		local  starAllAttrLayer= StarAllAttrLayer.createLayer()
		-- MainScene.changeLayer(starAllAttrLayer, "starAllAttrLayer")
		local runningScene = CCDirector:sharedDirector():getRunningScene()
		runningScene:addChild(starAllAttrLayer,9999)
	elseif(tag == 91003)then
		local starAchieveLayer = StarAchieveLayer.createLayer()
		MainScene.changeLayer(starAchieveLayer, "starAchieveLayer")
	end
end

-- 背包变化的回调通知
function bagChangedDelegateFunc()
	if( MainScene.getOnRunningLayerSign() == "starLayer" )then
		_isSendGift = true
		createBottomUI()
	end
end

-- 正常刷新所有界面
function refreshAllUI( )

----- 头部的UI
	-- refreshTopUI()

----- 名将经验和等级
	-- createLevelExpUI()

----- 名将属性加成UI
	-- createStarAttr()
	refreshAttrTableView()
	
---- 底部UI
	createBottomUI()

---- 刷新名将名称
	refreshStarNameLabel()

end

function showOrHiddenAttrUI( tag, itemBtn )
	require "script/audio/AudioUtil"
	AudioUtil.playEffect("audio/effect/zhujiemian.mp3")
	local toPosition = nil
	fnEndCallback_hidden = function ( ... )
		_showMenuItem:setVisible(false)
	end
	fnEndCallback_show = function ( ... )
		_showMenuItem:setVisible(true)
	end
	if(tag == 81001)then
		local t_point = ccp( _bgLayer:getContentSize().width -255*MainScene.elementScale , _bgLayer:getContentSize().height * 555/960)
		local spActionArr = CCArray:create()
		spActionArr:addObject(CCCallFuncN:create(fnEndCallback_hidden))
		spActionArr:addObject(CCMoveTo:create(g_cellAnimateDuration , t_point))
		_starAttrSprite:runAction(CCSequence:create(spActionArr))
	elseif(tag == 81002)then
		local t_point = ccp( _bgLayer:getContentSize().width + 54*MainScene.elementScale , _bgLayer:getContentSize().height * 555/960)
		local spActionArr = CCArray:create()
		spActionArr:addObject(CCMoveTo:create(g_cellAnimateDuration , t_point))
		spActionArr:addObject(CCCallFuncN:create(fnEndCallback_show))
		_starAttrSprite:runAction(CCSequence:create(spActionArr))
	end

end

function createUI()

	addStarAnimation()
	-- 聚光灯
	local spotLightSp = CCSprite:create("images/formation/spotlight.png")
	spotLightSp:setAnchorPoint(ccp(0.5,1))
	spotLightSp:setPosition(ccp(_bgLayer:getContentSize().width * 0.5, _bgLayer:getContentSize().height))
	_bgLayer:addChild(spotLightSp)

	menuBar = CCMenu:create()
	menuBar:setPosition(ccp(0, 0))
	_bgLayer:addChild(menuBar, 10)

	-- 名将录按钮
	local starListBtn = CCMenuItemImage:create( Star_Img_Path .. "btn_list_n.png", Star_Img_Path .. "btn_list_h.png" )
	starListBtn:registerScriptTapHandler(starMenuAction)
	starListBtn:setAnchorPoint(ccp(0.5, 1))
    starListBtn:setPosition(MainScene.getMenuPositionInTruePoint(_bgLayer:getContentSize().width*580/640, _bgLayer:getContentSize().height*870/960))
    menuBar:addChild(starListBtn, 2, 91001)

  --   local newStars = StarUtil.readNewStar()
  --   if(not table.isEmpty(newStars)) then
  --   	-- 名将个数
	 --    require "script/utils/ItemDropUtil"
		-- local newSatrSprite = ItemDropUtil.getTipSpriteByNum( #newStars)  
		-- newSatrSprite:setPosition(70, 50)
	 --    starListBtn:addChild(newSatrSprite)

  --   end


    -- 名将成就
    local achieveBtn = CCMenuItemImage:create( Star_Img_Path .. "btn_achieve_n.png", Star_Img_Path .. "btn_achieve_h.png")
	achieveBtn:setAnchorPoint(ccp(0.5, 1))
	achieveBtn:registerScriptTapHandler(starMenuAction)
    achieveBtn:setPosition(MainScene.getMenuPositionInTruePoint(_bgLayer:getContentSize().width*450/640, _bgLayer:getContentSize().height*870/960))
    menuBar:addChild(achieveBtn, 2, 91003)


    -- 武将列传
	liezhuanBtn = LuaMenuItem.createItemImage( "images/biography/bio_button_n.png", "images/biography/bio_button_h.png")
	liezhuanBtn:setAnchorPoint(ccp(0.5, 1))
	liezhuanBtn:registerScriptTapHandler(showHeroLiezhuanAction)
	liezhuanBtn:setPosition(MainScene.getMenuPositionInTruePoint(_bgLayer:getContentSize().width*320/640, _bgLayer:getContentSize().height*870/960))
	menuBar:addChild(liezhuanBtn, 2, 91003)
	liezhuanBtn:setVisible(false)

	-- 好感度互换
	local exchangeBtn = LuaMenuItem.createItemImage( "images/star/exchange_n.png", "images/star/exchange_h.png")
	exchangeBtn:setAnchorPoint(ccp(0.5, 1))
	exchangeBtn:registerScriptTapHandler(exchangeBtnCallFun)
	exchangeBtn:setPosition(MainScene.getMenuPositionInTruePoint(_bgLayer:getContentSize().width*320/640, _bgLayer:getContentSize().height*870/960))
	menuBar:addChild(exchangeBtn, 2)

	-- 聚义厅
	local loyalBtn = LuaMenuItem.createItemImage( "images/star/friend/enter_n.png", "images/star/friend/enter_h.png")
	loyalBtn:setAnchorPoint(ccp(0.5, 1))
	loyalBtn:registerScriptTapHandler(loyalBtnCallFun)
	loyalBtn:setPosition(MainScene.getMenuPositionInTruePoint(_bgLayer:getContentSize().width*190/640, _bgLayer:getContentSize().height*870/960))
	menuBar:addChild(loyalBtn, 2,loyaltyTag)


----- 展示属性
	_showMenuItem = CCMenuItemImage:create("images/star/btn_show_n.png", "images/star/btn_show_h.png")
	_showMenuItem:setAnchorPoint(ccp(1, 0.5))
	_showMenuItem:registerScriptTapHandler(showOrHiddenAttrUI)
    _showMenuItem:setPosition(MainScene.getMenuPositionInTruePoint(_bgLayer:getContentSize().width, _bgLayer:getContentSize().height*0.6))
    menuBar:addChild(_showMenuItem, 2, 81001)

----- 头部的UI
	createTopUI()

----- 名将经验和等级
	-- createLevelExpUI()

----- 名将属性加成UI
	createStarAttr()
	
----- 底部UI
	createBottomUI()

---- 创建star的全身像
	createStarSprite()
---- 创建名称
	createNameUI( )

---- 创建一键赠送按钮
	_oneKeyBtn = LuaCC.create9ScaleMenuItem("images/common/btn/btn1_d.png","images/common/btn/btn1_n.png",CCSizeMake(200, 73),GetLocalizeStringBy("lic_1125"),ccc3(0xfe, 0xdb, 0x1c),35,g_sFontPangWa,1, ccc3(0x00, 0x00, 0x00))
	_oneKeyBtn:setAnchorPoint(ccp(1, 0))
    -- _oneKeyBtn:setPosition(MainScene.getMenuPositionInTruePoint(_bgLayer:getContentSize().width, _bgLayer:getContentSize().height*0.3))
    _oneKeyBtn:setPosition(ccp(_bgLayer:getContentSize().width/MainScene.elementScale, _bottomSprite:getPositionY()/MainScene.elementScale+_bottomSprite:getContentSize().height))
    _oneKeyBtn:registerScriptTapHandler(oneKeyBtnCallFun)
	menuBar:addChild(_oneKeyBtn,2)

	--修行入口
	--added by Zhang Zihang
	-- local monkeryMenuItem = CCMenuItemImage:create("images/replaceskill/enter_n.png", "images/replaceskill/enter_h.png")
	-- monkeryMenuItem:setAnchorPoint(ccp(0,0))
	-- monkeryMenuItem:setPosition(ccp(20/MainScene.elementScale,40/MainScene.elementScale+_bottomSprite:getPositionY()/MainScene.elementScale+_bottomSprite:getContentSize().height))
	-- monkeryMenuItem:registerScriptTapHandler(monkeryCallBack)
	-- menuBar:addChild(monkeryMenuItem,2)

	--进来刷新一次红点 暂时没把刷新红点的函数放到refreshallUI中
	refreshTip()
end

--[[
	@des 	:修行回调
	@param 	:
	@return :
--]]
function monkeryCallBack()
	require "script/ui/replaceSkill/ReplaceSkillLayer"
  	ReplaceSkillLayer.showLayer()
end

-- 武将列传
function showHeroLiezhuanAction( tag, itembtn )
	require "script/audio/AudioUtil"
	AudioUtil.playEffect("audio/effect/zhujiemian.mp3")
	---[==[武将列传 新手引导屏蔽层
	---------------------新手引导---------------------------------
	--add by licong 2014.5.27
	require "script/guide/NewGuide"
	if(NewGuide.guideClass == ksGuideHeroBiography) then
		require "script/guide/LieZhuanGuide"
		LieZhuanGuide.changLayer()
	end
	---------------------end-------------------------------------
	--]==]
	-- 当前名将信息
	require "script/ui/heroCpy/HeroEnter"
	require "script/ui/famoushero/HeroEnterLayer"
    HeroEnterLayer.show()
end

--好感度互换
function exchangeBtnCallFun( tag, itemBtn )
	require "script/audio/AudioUtil"
	AudioUtil.playEffect("audio/effect/zhujiemian.mp3")
	local dirLayer = StarDirLayer.createLayer( StarDirLayer.kExchangeType,  _allStarInfoArr[_curStarIndex])
	MainScene.changeLayer(dirLayer, "dirLayer")
end
--聚义厅
function loyalBtnCallFun( tag, itemBtn )
	--require "script/audio/AudioUtil"
	--AudioUtil.playEffect("audio/effect/zhujiemian.mp3")
	if not DataCache.getSwitchNodeState(ksSwitchLoyal) then
			return
	end
    require "script/ui/star/loyalty/LoyaltyLayer"
    local loyalLayer = LoyaltyLayer.createLayer()
    MainScene.changeLayer(loyalLayer, "loyalLayer")
end
-- 一键赠送网络回调
function oneKeyServiceCallFun( cbFlag, dictData, bRet )
	if( dictData.err == "ok") then
		-- 特效
		startEffect()
		-- 数据处理
		print("addFavorByAllGifts-----")
		print_t(dictData.ret)
		local f_level = StarUtil.getStarLevelBySid(_allStarInfoArr[_curStarIndex].star_id)
		-- 加经验
		local addExp = tonumber(dictData.ret.exp)
		DataCache.addExpToStar(_allStarInfoArr[_curStarIndex].star_id, addExp)
		-- 记忆最后一次选择的名将
		StarUtil.setLastOperatedStarId(_allStarInfoArr[_curStarIndex].star_id)
		-- 送礼物
		_isSendGift = true
		
		-- 暴击次数
		local fatal = tonumber(dictData.ret.fatal)
		local m_tipText = string.format(GetLocalizeStringBy("lic_1127"), addExp) .. string.format(GetLocalizeStringBy("lic_1128"), fatal)

		local s_level = StarUtil.getStarLevelBySid(_allStarInfoArr[_curStarIndex].star_id)
		if(s_level > f_level)then
			
			local ability_t = StarUtil.getAttributeInfos(tonumber(_allStarInfoArr[_curStarIndex].star_tid), _allStarInfoArr[_curStarIndex].level)
			local t_text = {}
			for i=f_level+1, s_level do
				local ability_info = ability_t[i]
				if( ability_info.is_highLight ) then
					local o_text = {}
					o_text.txt = ability_info.name
					o_text.num = ability_info.num
					table.insert(t_text, o_text)
					-- 如果是耐力上限
					if(ability_info.a_id == -1)then
						UserModel.addStaminaMaxNumber(ability_info.num)
					end
				end
			end

			local t_ability_temp, all_levels = StarUtil.getTotalStarAttr()
			local t_achieve_text, m_achiveData = StarUtil.getOneStarAchieveBy(all_levels, (s_level - f_level) )

			if(not table.isEmpty(t_achieve_text))then
				_curAchieveData = m_achiveData
				local actionArr = CCArray:create()
				actionArr:addObject(CCDelayTime:create(1))
				actionArr:addObject(CCCallFuncN:create(showStarAchieveEffect))
				_bgLayer:runAction(CCSequence:create(actionArr))
				if(_curAchieveData.add_max_stamina)then
					UserModel.addStaminaMaxNumber(tonumber(_curAchieveData.add_max_stamina))
				end
				--增加体力上限
				if(_curAchieveData.add_max_execution) then
					UserModel.addExecutionMaxNumber(tonumber(_curAchieveData.add_max_execution))
				end
			end
			m_tipText = m_tipText .. string.format(GetLocalizeStringBy("lic_1129"), (s_level-f_level)) 
			require "script/utils/LevelUpUtil"
			LevelUpUtil.showFlyText(t_text)
			refreshAllUI()
			----- 头部的UI
			refreshTopUI()

			StarUtil.getStarAddNumBy( _allStarInfoArr[_curStarIndex].star_tid, true)
		end
		AnimationTip.showTip(m_tipText)
	end
end

-- 一键赠送回调
function oneKeyYesCallFun( isConfirm )
	if(isConfirm == false)then
		return 
	end
	-- 一键赠送请求
	local args = Network.argsHandler(tonumber(_allStarInfoArr[_curStarIndex].star_id))
	Network.rpc(oneKeyServiceCallFun, "star.addFavorByAllGifts","star.addFavorByAllGifts", args, true)
end

-- 一键赠送回调
function oneKeyBtnCallFun( tag, itemBtn )
	-- 按钮音效
	require "script/audio/AudioUtil"
	AudioUtil.playEffect("audio/effect/zhujiemian.mp3")

	-- 没有礼物拦截
	local gift_infos = ItemUtil.getAllStarGifts()
	if(table.isEmpty(gift_infos))then
		AnimationTip.showTip(GetLocalizeStringBy("lic_1126"))
		return
	end
	-- 好感达到上限
	if(tonumber(_allStarInfoArr[_curStarIndex].level) < #_ability_t ) then
		-- 人物等级不足
		if( UserModel.getHeroLevel()< _ability_t[tonumber(_allStarInfoArr[_curStarIndex].level)+1].lvLimited)then
			AnimationTip.showTip(GetLocalizeStringBy("key_2713"))
			return
		end	

		-- 注册背包物品消耗回调
		PreRequest.setBagDataChangedDelete(bagChangedDelegateFunc)
		require "script/ui/tip/AlertTip"
		local str = GetLocalizeStringBy("lic_1130")
		AlertTip.showAlert(str,oneKeyYesCallFun,true)
	else
		AnimationTip.showTip(GetLocalizeStringBy("key_2304"))
	end
end

-- 处理数据
function handleDataCache()
	_curStarIndex = 1
	if(_curStarId)then
		for k_index, starInfo in pairs(_allStarInfoArr) do
			if(tonumber(starInfo.star_id) == tonumber(_curStarId)) then
				_curStarIndex = k_index
				break
			end
		end
	end
end 

function getAllStarInfoCallback( cbFlag, dictData, bRet )
	if( dictData.err == "ok") then
		if( not table.isEmpty( dictData.ret.allStarInfo) ) then
			DataCache.saveStarInfoToCache( dictData.ret.allStarInfo )
		end
	end
	_allStarInfoArr = DataCache.getStarArr()
	if( not table.isEmpty(_allStarInfoArr))then
		handleDataCache()
		createUI()
	end
end


-- 动画结束
function animatedEndAction( nextStarSprite )
	_curStarBodyImage:removeFromParentAndCleanup(true)
	_curStarBodyImage = nextStarSprite
	_isOnAnimation = false
	refreshAllUI()
end

-- 移动名将像
local function switchNextStar( xOffset )

	local nextStarIndex = -1
	if(xOffset < 0) then
		if(_curStarIndex < #_allStarInfoArr) then
			nextStarIndex = _curStarIndex+1
		end
	else
		if(_curStarIndex > 1) then
			nextStarIndex = _curStarIndex-1
		end
	end

	if( nextStarIndex >= 1 and  nextStarIndex <= #_allStarInfoArr) then
		local tempTid = HeroUtil.getOnceOrangeHtid(_allStarInfoArr[nextStarIndex].star_tid)
		local nextStarSprite = StarSprite.createStarSprite( tempTid )
		nextStarSprite:setAnchorPoint(ccp(0.5, 0))
		-- nextStarSprite:setPosition(ccp( _bgLayer:getContentSize().width * 420/640, _bgLayer:getContentSize().height * 550/960))
		_bgLayer:addChild(nextStarSprite)

		local curMoveToP = nil
		local nextMoveToP = ccp( _bgLayer:getContentSize().width * 0.5, _bgLayer:getContentSize().height * _starScaleY)
		local curPositionX = _curStarBodyImage:getPosition()
		if(xOffset<0)then
			curMoveToP = ccp( curPositionX -_bgLayer:getContentSize().width, _bgLayer:getContentSize().height * _starScaleY)
			nextStarSprite:setPosition(curPositionX +_bgLayer:getContentSize().width, _bgLayer:getContentSize().height * _starScaleY)
		else
			
			curMoveToP = ccp(curPositionX + _bgLayer:getContentSize().width, _bgLayer:getContentSize().height * _starScaleY)
			nextStarSprite:setPosition(curPositionX -_bgLayer:getContentSize().width, _bgLayer:getContentSize().height * _starScaleY)
		end
		_isOnAnimation = true
		-- 当前的武将移动
		_curStarBodyImage:runAction(CCMoveTo:create(0.2, curMoveToP))
		local actionArr = CCArray:create()
		actionArr:addObject(CCMoveTo:create(0.2, nextMoveToP))
		actionArr:addObject(CCDelayTime:create(0.1))
		actionArr:addObject(CCCallFuncN:create(animatedEndAction))
		_curStarIndex = nextStarIndex

		nextStarSprite:runAction(CCSequence:create(actionArr))
	end
end


--[[
 @desc	 处理touches事件
 @para 	 string event
 @return 
--]]
local function onTouchesHandler( eventType, x, y )
	
	if (eventType == "began") then
		
		_touchBeganPoint = ccp(x, y)
		local vPosition = _curStarBodyImage:convertToNodeSpace(_touchBeganPoint)
		if( not _isOnAnimation and vPosition.x>0 and vPosition.y>70 and vPosition.x < _curStarBodyImage:getContentSize().width and vPosition.y < _curStarBodyImage:getContentSize().height ) then
			print("began true")

			local mPosition = _starAttrSprite:convertToNodeSpace(_touchBeganPoint)
			if( mPosition.x>0 and mPosition.y>70 and mPosition.x < _starAttrSprite:getContentSize().width and mPosition.y < _starAttrSprite:getContentSize().height)then
				return false
			else
				return true
			end
		else
			print("began false")
			return false
	    end
    elseif (eventType == "moved") then
    	print("moved")
    else
    	print("end")
    	local xOffset = x- _touchBeganPoint.x;
        if(math.abs(xOffset) > 10)then
        	switchNextStar(xOffset)
        end
	end
end


--[[
 @desc	 回调onEnter和onExit时间
 @para 	 string event
 @return void
 --]]
local function onNodeEvent( event )
	if (event == "enter") then
		print("enter")
		_bgLayer:registerScriptTouchHandler(onTouchesHandler, false, -127, true)
		_bgLayer:setTouchEnabled(true)
	elseif (event == "exit") then
		print("exit")
		_bgLayer:unregisterScriptTouchHandler()
		PreRequest.setBagDataChangedDelete(nil)
	end
end


---- 默认的starId
function createLayer(star_id)

	init()
	_curStarId = star_id
	-- print("star_id",star_id)
	if(_curStarId == nil)then
		_curStarId = StarUtil.getLastOperatedStarId()
	end
	_bgLayer = MainScene.createBaseLayer("images/star/starbg.jpg", true, false,true)
	_allStarInfoArr = DataCache.getStarArr()
	_bgLayer:registerScriptHandler(onNodeEvent)
	if(table.isEmpty(_allStarInfoArr))then
		RequestCenter.star_getAllStarInfo(getAllStarInfoCallback, nil)
	else
		handleDataCache()
		createUI()
	end
	
	local seq = CCSequence:createWithTwoActions(CCDelayTime:create(0.3),CCCallFunc:create(function ( ... )
			addGuideStarHeroGuide2()
			addGuideLieZhuanGuide2()
		end))
	_bgLayer:runAction(seq)

	return _bgLayer
end


-- 新手引导
function getGuideObject()
	return _guideBtn
end

function getGuideObject_2()
	return _giftTableView:cellAtIndex(0)
end

function getLieZhuanObject()
	return liezhuanBtn
end

---[==[名将 第2步 介绍1
---------------------新手引导---------------------------------
function addGuideStarHeroGuide2( ... )
	require "script/guide/NewGuide"
	require "script/guide/StarHeroGuide"
    if(NewGuide.guideClass ==  ksGuideGreatSoldier and StarHeroGuide.stepNum == 1) then
        StarHeroGuide.show(2, nil)
    end
end
---------------------end-------------------------------------
--]==]

---[==[武将列传 第2步
---------------------新手引导---------------------------------
function addGuideLieZhuanGuide2( ... )
	require "script/guide/NewGuide"
	require "script/guide/LieZhuanGuide"
    if(NewGuide.guideClass ==  ksGuideHeroBiography and LieZhuanGuide.stepNum == 1) then
    	local button = getLieZhuanObject()
        local touchRect   = getSpriteScreenRect(button)
        LieZhuanGuide.show(2, touchRect)
    end
end
---------------------end-------------------------------------
--]==]

-- 获得菜单项各个项的对象
-- 参数为item的tag值
function getMainMenuItem(tag)
	
	if(menuBar == nil )then
		return
	end
	if(menuBar:getChildByTag(tag) ~= nil) then
		return menuBar:getChildByTag(tag)
	end
end
-- 按钮上边的提示小红圈
-- 添加对象  item
-- isVisible 是否显示
function showTipSprite( item, isVisible )
	if(item == nil)then
		return
	end
	if( item:getChildByTag(1915) ~= nil )then
		local tipSprite = tolua.cast(item:getChildByTag(1915),"CCSprite")
		tipSprite:setVisible(isVisible)
	else
		local tipSprite = CCSprite:create("images/common/tip_2.png")
	    tipSprite:setAnchorPoint(ccp(0.5,0.5))
	    tipSprite:setPosition(ccp(item:getContentSize().width*0.8,item:getContentSize().height*0.8))
	    item:addChild(tipSprite,1,1915)
	    tipSprite:setVisible(isVisible)
	end
end

