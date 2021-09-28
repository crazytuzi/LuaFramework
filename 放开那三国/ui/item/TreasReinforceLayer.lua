-- Filename：	TreasReinforceLayer.lua
-- Author：		Cheng Liang
-- Date：		2013-11-6
-- Purpose：		宝物强化

module("TreasReinforceLayer", package.seeall)

require "script/GlobalVars"
require "script/ui/item/ItemUtil"
require "script/ui/main/MainScene"
require "script/ui/common/LuaMenuItem"
require "script/network/RequestCenter"
require "script/model/user/UserModel"
require "script/model/hero/HeroModel"
require "script/model/DataCache"
require "script/ui/item/EquipCardSprite"
require "script/ui/tip/AnimationTip"
require "script/ui/item/TreasCardSprite"



local Tag_Back 		= 90001
local Tag_Force 	= 90002
local Tag_AutoAdd 	= 90003


local _bgLayer 			= nil
local _item_id 			= nil
local _delegateAction 	= nil
local bgSprite			= nil
local _silverLabel	 	= nil
local _goldLabel 		= nil
local _topSprite 		= nil
-- 装备是在hero身上还是背包中
local _isOnHero 		= false	

-- 材料背景
local enhanceBgSprite  	= nil 
local _materialsMenuBar = nil

local _materialsArr = {}

local attr_arr, score_t, ext_active, enhanceLv = {}, {}, {}, 0

local siliverLabel 		= nil
local _upgradRateLabel	= nil

local _upgradeNeedNum 	= 0
local _levelLimited 	= nil
local _treasData 		= {}
local _isCanEnhance 	= true

local cardAndAttrSprite = nil

local _materialsMenuItemArr = {}

-- 卡牌
local _cardSprite 		= nil

local _isEnhanceSuccess = false

local _addLv 			= 0
local _addProgressGreenBar	= nil
local curLevel, curLevelExp, curLevelLimiteExp = nil, nil, nil

local _m_level_label	= nil
-- 属性背景
local attrBgSprite		= nil
-- 强化
local enhanceLvLabel 	= nil
-- 增加的数值
local _addPLLabel		= nil
local _isNeedHidden 	= nil
 
local containerLayer    = nil
local descLabel 		= nil

local _layerTouchPrority = nil

-- 初始化
local function init()
	_bgLayer 		= nil
	bgSprite		= nil
	_item_id 		= nil
	_delegateAction = nil
	_silverLabel	= nil
	_goldLabel 		= nil
	_topSprite		= nil
	attr_arr, score_t, ext_active, enhanceLv, _treasData = {}, {}, {}, 0, {}
	_isOnHero 		= false	
	_materialsMenuBar 	= nil
	_materialsArr 		= {}
	enhanceBgSprite  	= nil 
	siliverLabel 		= nil
	_upgradRateLabel	= nil
	_levelLimited 		= nil
	_upgradeNeedNum 	= 0
	_isCanEnhance 		= true
	cardAndAttrSprite 	= nil
	_materialsMenuItemArr = {}
	_cardSprite 		= nil
	_isEnhanceSuccess 	= true
	_addLv 				= 0
	_addProgressGreenBar= nil
	_m_level_label		= nil
	attrBgSprite		= nil
	-- 强化
	enhanceLvLabel 		= nil
	-- 增加的数值
	_addPLLabel			= nil
	_isNeedHidden 		= nil
	containerLayer   	= nil
	descLabel 			= nil
	_layerTouchPrority = nil
end 

--
local function onTouchesHandler( eventType, x, y )
	
	local touchBeganPoint = ccp(x, y)
	if (eventType == "began") then
        return true
    elseif (eventType == "moved") then
    	
    else
        -- print("end")
	end
end

 --
local function onNodeEvent( event )
	if (event == "enter") then
		_bgLayer:registerScriptTouchHandler(onTouchesHandler, false, _layerTouchPrority, true)
		_bgLayer:setTouchEnabled(true)
	elseif (event == "exit") then
		_bgLayer:unregisterScriptTouchHandler()
	end
end

-- 获得选中的材料item_id
function getMaterialsArr()
	return _materialsArr
end

-- 设置
function setMaterialsArr( materials_arr )
	_materialsArr = materials_arr
	refreshSliver()
	recreateMaterialMenuBar()
	refreshRateLabel()
	refreshAddExpBar()
	setAddAttrAnimation()
end

function setAddAttrAnimation()
	local m_level, m_levelExp, m_levelLimiteExp = ItemUtil.getTreasExpAndLevelInfo(_treasData.item_template_id, tonumber(_treasData.va_item_text.treasureExp) + BagUtil.getTreasAddExpBy(_materialsArr))
	
	if(_m_level_label)then
		_m_level_label:removeFromParentAndCleanup(true)
		_m_level_label = nil
	end

	if(_addPLLabel) then
		_addPLLabel:removeFromParentAndCleanup(true)
		_addPLLabel=nil
	end

	enhanceLvLabel:stopAllActions()
	enhanceLvLabel:runAction(CCFadeIn:create(0.1))
	-- local temp_node = tolua.cast(enhanceLvLabel, "CCLabelTTF")
	-- temp_node:setOpacity(0)

	if(m_level>curLevel)then
		-- 如果可以升级

		local p_x,p_y = enhanceLvLabel:getPosition()
		_m_level_label = CCRenderLabel:create("+" .. m_level, g_sFontPangWa, 25, 1, ccc3( 0x00, 0x00, 0x00), type_stroke)
	    _m_level_label:setAnchorPoint(ccp(0,1))
	    _m_level_label:setPosition(ccp(p_x, p_y))
	    _m_level_label:setColor(ccc3(0x2c, 0xdb, 0x23))
 		containerLayer:addChild(_m_level_label)

 		local temp_node_m = tolua.cast(_m_level_label, "CCLabelTTF")
		temp_node_m:setOpacity(0)

	    local arrActions = CCArray:create()
	    arrActions:addObject(CCDelayTime:create(0.8))
		arrActions:addObject(CCFadeIn:create(0.8))
		arrActions:addObject(CCFadeOut:create(0.8))
		arrActions:addObject(CCDelayTime:create(0.8))
		
		local sequence = CCSequence:create(arrActions)
		local action = CCRepeatForever:create(sequence)
		_m_level_label:runAction(action)

		local arrActions_2 = CCArray:create()
		arrActions_2:addObject(CCFadeOut:create(0.8))
		arrActions_2:addObject(CCDelayTime:create(0.8))
		arrActions_2:addObject(CCDelayTime:create(0.8))
		arrActions_2:addObject(CCFadeIn:create(0.8))
		
		local sequence_2 = CCSequence:create(arrActions_2)
		local action_2 = CCRepeatForever:create(sequence_2)
		enhanceLvLabel:runAction(action_2)

		-- 属性值
	    local plDescString = ""
		for key,attr_info in pairs(attr_arr) do
	        
			if(tonumber(attr_info.pl)>0) then
				local affixDesc, m_displayNum = ItemUtil.getAtrrNameAndNum(attr_info.attId, attr_info.pl*(m_level-curLevel))
				plDescString = plDescString .. "+"..m_displayNum .. "\n"
			else
				plDescString = plDescString .. "\n"
			end
		end
		-- 增加的数值
		_addPLLabel = CCRenderLabel:createWithAlign(plDescString, g_sFontName, 23, 1, ccc3(0x00, 0x00, 0x00), type_stroke, CCSizeMake(225, 80), kCCTextAlignmentLeft, kCCVerticalTextAlignmentTop)
		_addPLLabel:setColor(ccc3(0x2c, 0xdb, 0x23))
		_addPLLabel:setAnchorPoint(ccp(0, 1))
		_addPLLabel:setPosition(ccp(containerLayer:getContentSize().width*0.7, descLabel:getPositionY()))
		containerLayer:addChild(_addPLLabel)

		local arrActions_3 = CCArray:create()
		arrActions_3:addObject(CCFadeOut:create(0.8))
		arrActions_3:addObject(CCFadeIn:create(0.8))
		
		local sequence_3 = CCSequence:create(arrActions_3)
		local action_3 = CCRepeatForever:create(sequence_3)
		_addPLLabel:runAction(action_3)

	end
end

-- 刷新概率
function refreshRateLabel()

	if(_upgradRateLabel)then
		_upgradRateLabel:removeFromParentAndCleanup(true)
		_upgradRateLabel = nil
	end
	_upgradRateLabel = CCRenderLabel:create(BagUtil.getTreasAddExpBy(_materialsArr), g_sFontName, 23, 1, ccc3( 0x00, 0x00, 0x00), type_stroke)
	_upgradRateLabel:setColor(ccc3(0x2c, 0xdb, 0x23))
	_upgradRateLabel:setAnchorPoint(ccp(0, 0.5))
	_upgradRateLabel:setPosition(ccp(bgSprite:getContentSize().width*0.68, bgSprite:getContentSize().height*0.15))
	bgSprite:addChild(_upgradRateLabel) 
	_upgradRateLabel:setScale(MainScene.elementScale)

end

-- 刷新银币
function refreshSliver()
	-- _upgradeNeedNum, _levelLimited = BagUtil.getCostSliverByItemId(_item_id)
	_upgradeNeedNum = ItemUtil.getTreasCostToAddExp( _treasData.item_template_id, tonumber(_treasData.va_item_text.treasureExp), tonumber(_treasData.va_item_text.treasureExp) + BagUtil.getTreasAddExpBy(_materialsArr) )
	siliverLabel:setString(_upgradeNeedNum)
end

-- 刷新TopUI
function refreshTopUI()
	-- modified by yangrui at 2015-12-03
	_silverLabel:setString(string.convertSilverUtilByInternational(UserModel.getSilverNumber()))
end

-- 刷新新增的经验
function refreshAddExpBar()

	local rate = (tonumber(curLevelExp)+tonumber(BagUtil.getTreasAddExpBy(_materialsArr)))/curLevelLimiteExp
	rate = rate>1 and 1 or rate
	_addProgressGreenBar:setContentSize(CCSizeMake(190 * rate, 23))
end
-- 刷新之后的经验
function refreshRealExp()
	
	curLevel, curLevelExp, curLevelLimiteExp = ItemUtil.getTreasExpAndLevelInfo(_treasData.item_template_id, tonumber(_treasData.va_item_text.treasureExp))
	progressSp:setContentSize(CCSizeMake(190 * curLevelExp/curLevelLimiteExp, 23))
	
end

-- 准备数据
local function prepareData()
	attr_arr, score_t, ext_active, enhanceLv, _treasData = ItemUtil.getTreasAttrByItemId(_item_id)
	-- attr_arr = TreasAffixModel.getIncreaseAffixByInfo(_treasData)
end

-- 展示属性变化
function showAttrChangeAnimationBy( addLV )
	local t_text = {}

	for k, t_attr_info in pairs(attr_arr) do
		require "db/DB_Affix"
	    local affixDesc = DB_Affix.getDataById(tonumber(t_attr_info.attId))
		local o_text = {}
		o_text.txt = affixDesc.sigleName
		o_text.num = t_attr_info.pl * addLV
		o_text.displayNumType = affixDesc.type
		if(o_text.num ~=0 )then
			table.insert(t_text, o_text)
		end
	end
	require "script/utils/LevelUpUtil"
	LevelUpUtil.showFlyText(t_text)
end

-- 展示强化结果
function displayEnhanceResult()
	if(_addLv>0)then
		if(_m_level_label)then
			_m_level_label:removeFromParentAndCleanup(true)
			_m_level_label = nil
		end
		if(_addPLLabel) then
			_addPLLabel:removeFromParentAndCleanup(true)
			_addPLLabel=nil
		end
		refreshUI()
    	showAttrChangeAnimationBy(_addLv)
    end
    enhanceResultEffect(_addLv)
    setMaterialsArr({})
	refreshTopUI()

	refreshRealExp()
	refreshAddExpBar()
end

-- 卡牌的动画
function animationStart_2()

	-- 展示强化结果
	displayEnhanceResult()

	local spellEffectSprite_2 = CCLayerSprite:layerSpriteWithName(CCString:create("images/base/effect/hero/qianghua"), -1,CCString:create(""));
    
    spellEffectSprite_2:setPosition(_cardSprite:getContentSize().width*0.5, _cardSprite:getContentSize().height*0.5)
    _cardSprite:addChild(spellEffectSprite_2,1);

    local animation_2_End = function(actionName,xmlSprite)
		spellEffectSprite_2:retain()
		spellEffectSprite_2:autorelease()
        spellEffectSprite_2:removeFromParentAndCleanup(true)
        _isCanEnhance = true
    end

    -- 每次回调
    local animationFrameChanged = function(frameIndex,xmlSprite)
        
    end

    --增加动画监听
    local delegate = BTAnimationEventDelegate:create()
    delegate:registerLayerEndedHandler(animation_2_End)
    delegate:registerLayerChangedHandler(animationFrameChanged)
    spellEffectSprite_2:setDelegate(delegate)
end

-- 移动的animation
function moveToCardAnimation()
	-- menubar的相对bgSprite坐标
	local m_b_x, m_b_y = enhanceBgSprite:getPosition()
	local menuBgPosition = ccp(m_b_x, m_b_y)

	-- 卡牌的坐标
	local c_x, x_y = _cardSprite:getPosition()
	local c_b_x, c_b_y = cardAndAttrSprite:getPosition()
	local cardPositionInBgSprite = ccp(c_b_x-c_x, c_b_y-cardAndAttrSprite:getContentSize().height*0.5)

	for k, t_menuItem in pairs(_materialsMenuItemArr) do
		local t_x, t_y = t_menuItem:getPosition()
		local positionInBgSprite = ccp(m_b_x-enhanceBgSprite:getContentSize().width*0.5 + t_x, m_b_y)

		local particleSp = CCSprite:create("images/base/effect/hero/particle.png")
		particleSp:setAnchorPoint(ccp(0.5, 0.5))
		particleSp:setPosition(positionInBgSprite)
		bgSprite:addChild(particleSp,90, 10005+k)

		local arrActions = CCArray:create()
		arrActions:addObject(CCMoveTo:create(0.5, cardPositionInBgSprite))
		arrActions:addObject(CCCallFuncN:create(function (obj)
			if obj:getTag() == 10005+1 then
				-- 卡牌的动画
				animationStart_2()
			end	
			obj:removeFromParentAndCleanup(true)
		end))
		local sequence = CCSequence:create(arrActions)
		particleSp:runAction(sequence)

	end
end

-- 一个按钮上的动画
function addEffectOnItem( menuItem, isDelegate )
	local spellEffectSprite = CCLayerSprite:layerSpriteWithName(CCString:create("images/base/effect/hero/wujiangqianghua"), -1,CCString:create(""));
    spellEffectSprite:setPosition(menuItem:getContentSize().width*0.5, menuItem:getContentSize().height*0.5)
    spellEffectSprite:setFPS_interval(1.0/60)
    local animationEndFunc = function(actionName,xmlSprite)
    	local effect =  xmlSprite:getParent()
        effect:removeFromParentAndCleanup(true)
        if(isDelegate)then
        	moveToCardAnimation()
        end
    end

    local animationFrameChanged = function(frameIndex,xmlSprite)
        
    end

    --增加动画监听
    local delegate = BTAnimationEventDelegate:create()
    delegate:registerLayerEndedHandler(animationEndFunc)
    delegate:registerLayerChangedHandler(animationFrameChanged)
    spellEffectSprite:setDelegate(delegate)

    menuItem:addChild(spellEffectSprite)

end

-- 按钮上的动画
function startAnimationOnItem()
	for k, t_menuItem in pairs(_materialsMenuItemArr) do
		if(k == 1)then
			addEffectOnItem(t_menuItem, true)
		else
			addEffectOnItem(t_menuItem, false)
		end
	end
end

-- 强化回调
function reinforceCallback( cbFlag, dictData, bRet )
	if(dictData.err == "ok")then
		require "script/audio/AudioUtil"
		AudioUtil.playEffect("audio/effect/qianghuachuizi.mp3")

		UserModel.changeSilverNumber(-_upgradeNeedNum)
		_isEnhanceSuccess = false

		local result_treas = dictData.ret
		_addLv = 0
		if(not table.isEmpty(result_treas))then
			_addLv = tonumber(result_treas.va_item_text.treasureLevel) - tonumber(_treasData.va_item_text.treasureLevel)

			if(_treasData.equip_hid and tonumber(_treasData.equip_hid)>0 )then
				HeroModel.addTreasLevelOnHerosBy( _treasData.equip_hid, _treasData.pos, _addLv, result_treas.va_item_text.treasureExp )
			else
				DataCache.changeTreasReinforceBy(_item_id, _addLv, result_treas.va_item_text.treasureExp)
			end
			startAnimationOnItem()
		end	
	end
end

-- 刷新页面
function refreshUI()
	prepareData()
	createCardAndAttrUI()
end

-- 强化失败
function enhanceFailedEffect()
	require "script/audio/AudioUtil"
	AudioUtil.playEffect("audio/effect/qianghuachenggong.mp3")
	
	local spellEffectSprite_2 = CCLayerSprite:layerSpriteWithName(CCString:create("images/base/effect/enhance/qhsb"), -1,CCString:create(""));
    
    -- spellEffectSprite_2:setPosition(_cardSprite:getContentSize().width*0.5, _cardSprite:getContentSize().height*0.5)
    
    spellEffectSprite_2:release()

    local animation_2_End = function(actionName,xmlSprite)
    	spellEffectSprite_2:retain()
    	spellEffectSprite_2:autorelease()
        spellEffectSprite_2:removeFromParentAndCleanup(true)

    end

    spellEffectSprite_2:setScale(g_fScaleX)
    -- 每次回调
    local animationFrameChanged = function(frameIndex,xmlSprite)
        
    end

    --增加动画监听
    local delegate = BTAnimationEventDelegate:create()
    delegate:registerLayerEndedHandler(animation_2_End)
    delegate:registerLayerChangedHandler(animationFrameChanged)
    spellEffectSprite_2:setDelegate(delegate)

	spellEffectSprite_2:setPosition(ccp(bgSprite:getContentSize().width*0.5, bgSprite:getContentSize().height*0.5))
	bgSprite:addChild(spellEffectSprite_2, 999)
end

-- 强化成功
function enhanceResultEffect(addLv)

	require "script/audio/AudioUtil"
	AudioUtil.playEffect("audio/effect/qianghuachenggong.mp3")

	local spellEffectSprite_2 = nil

	local effectName_t = "images/base/effect/enhance/qianghuachenggong2"
	if(tonumber(_addLv) < 1) then
		effectName_t = "images/base/effect/item/qianghuachenggong"
		spellEffectSprite_2 = CCLayerSprite:layerSpriteWithName(CCString:create(effectName_t), 1,CCString:create(""))

		spellEffectSprite_2:setPosition(ccp(bgSprite:getContentSize().width*0.5, bgSprite:getContentSize().height*0.5))
		bgSprite:addChild(spellEffectSprite_2, 999)
		local animation_2_End = function(actionName,xmlSprite)
			spellEffectSprite_2:retain()
			spellEffectSprite_2:autorelease()
	        spellEffectSprite_2:removeFromParentAndCleanup(true)
	    end

	    spellEffectSprite_2:setScale(g_fScaleX)
	    -- 每次回调
	    local animationFrameChanged = function(frameIndex,xmlSprite)
	    end

	    --增加动画监听
	    local delegate = BTAnimationEventDelegate:create()
	    delegate:registerLayerEndedHandler(animation_2_End)
	    delegate:registerLayerChangedHandler(animationFrameChanged)
	    spellEffectSprite_2:setDelegate(delegate)
	else
		-- spellEffectSprite_2 = CCLayerSprite:layerSpriteWithName(CCString:create("images/base/effect/enhance/qianghuachenggong"), -1,CCString:create(""));
	 --    -- 替换强化等级
	 --    local replaceXmlSprite = tolua.cast( spellEffectSprite_2:getChildByTag(1006) , "CCXMLSprite")
	 --    replaceXmlSprite:setReplaceFileName(CCString:create("images/common/" .. _addLv .. ".png"))

	    require "script/ui/common/PublicSpecialEffects"
		PublicSpecialEffects.enhanceResultEffect(_addLv)
	end
	

    

	

end

function menuAction( tag, itemBtn )
	
	if(tag == Tag_Back)then
		if (_delegateAction) then
			_delegateAction()
		end
		require "script/audio/AudioUtil"
		AudioUtil.playEffect("audio/effect/guanbi.mp3")
		_bgLayer:removeFromParentAndCleanup(true)
		_bgLayer=nil
		if(_isNeedHidden)then
			MainScene.setMainSceneViewsVisible(true, true, true)
		end
	elseif(tag == Tag_Force)then
		if( tonumber(_treasData.va_item_text.treasureLevel) >= _levelLimited)then
			AnimationTip.showTip(GetLocalizeStringBy("key_2095"))
		elseif(_upgradeNeedNum > UserModel.getSilverNumber()) then
			AnimationTip.showTip(GetLocalizeStringBy("key_1114"))
		elseif(table.isEmpty(_materialsArr))then
			AnimationTip.showTip(GetLocalizeStringBy("key_2984"))
		elseif(_isCanEnhance == true) then
			_isCanEnhance = false

			local args = CCArray:create()
			args:addObject(CCInteger:create(_item_id))
			local t_args = CCArray:create()
			local t_args1 = CCArray:create()
			for k,v in pairs(_materialsArr) do
				t_args:addObject(CCInteger:create(tonumber(v.item_id)))
				t_args1:addObject(CCInteger:create(tonumber(v.num)))
			end
			args:addObject(t_args)
			args:addObject(t_args1)
			RequestCenter.forge_upgradeTreas(reinforceCallback,args )
		end
	elseif(tag == Tag_AutoAdd)then
		if(_isCanEnhance == false)then
			return
		end
		if(#_materialsArr<5)then
			_materialsArr = {}
			local num = 3
			require "db/DB_Normal_config"
			local limitLevel = tonumber(DB_Normal_config.getDataById(1).limitLevel)
			if(tonumber(UserModel.getAvatarLevel())>=limitLevel)then
				num = 4
			end
			local item_ids = ItemUtil.getTreasIdsByCondition( num, _treasData.item_id, _materialsArr, _treasData.itemDesc.type )
			setMaterialsArr(item_ids)
		end
	end
end

-- 创建Top信息
 function createTopUI()
 	local myScale = _bgLayer:getContentSize().width/640/_bgLayer:getElementScale()
 	_topSprite = CCSprite:create("images/hero/avatar_attr_bg.png")
 	_topSprite:setAnchorPoint(ccp(0,1))
	_topSprite:setPosition(ccp(0, _bgLayer:getContentSize().height - MenuLayer.getHeight()))
	_topSprite:setScale(myScale)
	_bgLayer:addChild(_topSprite)

	require "script/model/user/UserModel"
	local userInfo = UserModel.getUserInfo()
	
	local _cltNickname = CCLabelTTF:create(userInfo.uname, g_sFontName, 22)
	_cltNickname:setPosition(50, 8)
	_cltNickname:setColor(ccc3(0x6c, 0xff, 0))
	_topSprite:addChild(_cltNickname)

	-- VIP图标
    local vip_lv = CCSprite:create ("images/common/vip.png")
	vip_lv:setPosition(250, 10)
	_topSprite:addChild(vip_lv)
    -- VIP对应级别
    require "script/libs/LuaCC"
    local vip_lv_num = LuaCC.createSpriteOfNumbers("images/main/vip", userInfo.vip, 15)
    if (vip_lv_num ~= nil) then
        vip_lv_num:setPosition(vip_lv:getContentSize().width, 10)
        vip_lv:addChild(vip_lv_num)
    end

    -- 银币实际数据
    -- modified by yangrui at 2015-12-03
	_silverLabel = CCLabelTTF:create(string.convertSilverUtilByInternational(userInfo.silver_num),g_sFontName,18)
	_silverLabel:setColor(ccc3(0xe5, 0xf9, 0xff))
	_silverLabel:setPosition(380, 10)
	_topSprite:addChild(_silverLabel)

	-- 金币实际数据
    _goldLabel = CCLabelTTF:create(userInfo.gold_num, g_sFontName, 18)
	_goldLabel:setColor(ccc3(0xff, 0xe2, 0x44))
	_goldLabel:setPosition(520, 10)
	_topSprite:addChild(_goldLabel)
end

-- 创建卡牌和属性
function createCardAndAttrUI()

	if(cardAndAttrSprite)then
		cardAndAttrSprite:removeFromParentAndCleanup(true)
		cardAndAttrSprite = nil
	end

	-- 背景
	cardAndAttrSprite = CCScale9Sprite:create("images/common/bg/bg_ng_attr.png")
	cardAndAttrSprite:setPreferredSize(CCSizeMake(600, 390))
	cardAndAttrSprite:setAnchorPoint(ccp(0.5, 1))
	cardAndAttrSprite:setPosition(ccp(bgSprite:getContentSize().width*0.5, bgSprite:getContentSize().height*0.9))
	bgSprite:addChild(cardAndAttrSprite)
	cardAndAttrSprite:setScale(MainScene.elementScale)
	-- 卡牌
	_cardSprite = TreasCardSprite.createSprite(_treasData.item_template_id, _treasData.item_id )
	_cardSprite:setAnchorPoint(ccp(0.5, 0.5))
	_cardSprite:setPosition(ccp(cardAndAttrSprite:getContentSize().width*0.25, cardAndAttrSprite:getContentSize().height*0.5))
	_cardSprite:setScale(0.8)
	cardAndAttrSprite:addChild(_cardSprite)
	-- 属性背景
	attrBgSprite = CCScale9Sprite:create("images/common/bg/white_text_ng.png")
	attrBgSprite:setPreferredSize(CCSizeMake(285, 350))
	attrBgSprite:setAnchorPoint(ccp(0.5, 0.5))
	attrBgSprite:setPosition(ccp(cardAndAttrSprite:getContentSize().width*0.73, cardAndAttrSprite:getContentSize().height*0.5))
	cardAndAttrSprite:addChild(attrBgSprite)

	-- scrollView
	local viewSize = CCSizeMake(285,340)
	local scroll = CCScrollView:create()
	scroll:setViewSize(viewSize)
	scroll:setDirection(kCCScrollViewDirectionVertical)
	scroll:setTouchPriority(_layerTouchPrority-3)
	scroll:setBounceable(true)
	scroll:ignoreAnchorPointForPosition(false)
	scroll:setAnchorPoint(ccp(0.5,0.5))
	scroll:setPosition(ccp(attrBgSprite:getContentSize().width*0.5, attrBgSprite:getContentSize().height*0.5))
	attrBgSprite:addChild(scroll)

	-- 计算containerLayer的size
	containerLayer = CCLayer:create()
	local containerHight = 0

	-- 名称
	local quality = ItemUtil.getTreasureQualityByItemInfo( _treasData )
	local nameLabel = ItemUtil.getTreasureNameByItemInfo( _treasData, g_sFontPangWa, 25 )
	nameLabel:setAnchorPoint(ccp(0,1))
    containerLayer:addChild(nameLabel)

    containerHight = containerHight + nameLabel:getContentSize().height + 10

    -- 强化
	enhanceLvLabel = CCRenderLabel:create("+" .. _treasData.va_item_text.treasureLevel, g_sFontPangWa, 25, 1, ccc3( 0x00, 0x00, 0x00), type_stroke)
    enhanceLvLabel:setAnchorPoint(ccp(0,1))
    enhanceLvLabel:setColor(ccc3(0x2c, 0xdb, 0x23))
    containerLayer:addChild(enhanceLvLabel)

    -- 经验进度
	local expTitle = CCRenderLabel:create(GetLocalizeStringBy("key_1907"), g_sFontName, 25, 2, ccc3( 0x00, 0x00, 0x0d), type_stroke)
	expTitle:setColor(ccc3(0x8a, 0xff, 0x00))
	expTitle:setAnchorPoint(ccp(0, 0.5))
	containerLayer:addChild(expTitle)

	containerHight = containerHight + expTitle:getContentSize().height + 10

	curLevel, curLevelExp, curLevelLimiteExp = ItemUtil.getTreasExpAndLevelInfo(_treasData.item_template_id, tonumber(_treasData.va_item_text.treasureExp))
	local bgProress = CCScale9Sprite:create("images/common/exp_bg.png")
	bgProress:setContentSize(CCSizeMake(190, 23))
	bgProress:setAnchorPoint(ccp(0, 0.5))
	containerLayer:addChild(bgProress)

	-- 增长经验条
	_addProgressGreenBar = CCScale9Sprite:create("images/hero/strengthen/green_bar.png")
	_addProgressGreenBar:setContentSize( CCSizeMake(190 * curLevelExp/curLevelLimiteExp, 23) )
	_addProgressGreenBar:setAnchorPoint(ccp(0,0.5))
	_addProgressGreenBar:setPosition(ccp(0, bgProress:getContentSize().height *0.5))
	bgProress:addChild(_addProgressGreenBar)
	local arrActions = CCArray:create()
	arrActions:addObject(CCFadeIn:create(0.8))
	arrActions:addObject(CCFadeOut:create(0.8))
	local sequence = CCSequence:create(arrActions)
	local action = CCRepeatForever:create(sequence)
	_addProgressGreenBar:runAction(action)

	progressSp = CCScale9Sprite:create("images/common/exp_progress.png")
	progressSp:setContentSize(CCSizeMake(190 * curLevelExp/curLevelLimiteExp, 23))
	progressSp:setAnchorPoint(ccp(0, 0.5))
	progressSp:setPosition(ccp(0, bgProress:getContentSize().height *0.5))
	bgProress:addChild(progressSp)


 	-- 当前属性
	local attrLabelTitle = CCRenderLabel:create(GetLocalizeStringBy("key_1293"), g_sFontName, 25, 2, ccc3( 0x00, 0x00, 0x0d), type_stroke)
	attrLabelTitle:setColor(ccc3(0x8a, 0xff, 0x00))
	attrLabelTitle:setAnchorPoint(ccp(0, 1))
	containerLayer:addChild(attrLabelTitle)

	containerHight = containerHight + attrLabelTitle:getContentSize().height + 10

	-- 分割线
	local lineSprite = CCSprite:create("images/item/equipinfo/line.png")
	lineSprite:setAnchorPoint(ccp(0, 1))
	lineSprite:setScaleX(2)
	containerLayer:addChild(lineSprite)

	containerHight = containerHight + lineSprite:getContentSize().height + 10

    -- 属性值
    local descString = ""
    local plDescString = ""
	for key,attr_info in pairs(attr_arr) do
        local affixDesc, displayNum = ItemUtil.getAtrrNameAndNum(attr_info.attId, attr_info.num)
	    descString = descString .. affixDesc.sigleName .. " +"
		descString = descString .. displayNum .. "\n"
	end
	-- 描述
	descLabel = CCLabelTTF:create(descString, g_sFontName, 23, CCSizeMake(225, 80), kCCTextAlignmentLeft, kCCVerticalTextAlignmentTop)
	descLabel:setColor(ccc3(0x78, 0x25, 0x00))
	descLabel:setAnchorPoint(ccp(0, 1))
	containerLayer:addChild(descLabel)

	containerHight = containerHight + descLabel:getContentSize().height + 10

	-- 宝物技能
	local enchanceLabelTitle = CCRenderLabel:create(GetLocalizeStringBy("key_2582"), g_sFontName, 25, 2, ccc3( 0x00, 0x00, 0x0d), type_stroke)
	enchanceLabelTitle:setColor(ccc3(0x8a, 0xff, 0x00))
	enchanceLabelTitle:setAnchorPoint(ccp(0, 1))
	containerLayer:addChild(enchanceLabelTitle)

	containerHight = containerHight + enchanceLabelTitle:getContentSize().height + 10

	-- 分割线
	local lineSprite2 = CCSprite:create("images/item/equipinfo/line.png")
	lineSprite2:setAnchorPoint(ccp(0, 1))
	lineSprite2:setScaleX(2)
	containerLayer:addChild(lineSprite2)

	containerHight = containerHight + enchanceLabelTitle:getContentSize().height + 10

	local attrFontTab = {}
	local redAttrFontTab = {}
	local attrTab = {}
	local redAttrTab = {}
	for i,v in ipairs(ext_active) do
		if( v.needDevelopLv < 6 )then
			table.insert(attrTab, v)
		else
			-- 红色的
			table.insert(redAttrTab, v)
		end
	end

	for key, active_info in pairs(attrTab) do
        local affixDesc, displayNum = ItemUtil.getAtrrNameAndNum(active_info.attId, active_info.num)
	    local t_descString = affixDesc.sigleName .. " +" .. displayNum 

		local ccc3_c = nil
		if(active_info.isOpen)then
			ccc3_c = ccc3(0x78, 0x25, 0x00)
		else
			ccc3_c = ccc3(100,100,100)
			if( active_info.needDevelopLv )then
				if(active_info.needDevelopLv<6)then
					t_descString = t_descString .. "\n" .. GetLocalizeStringBy("lic_1560",active_info.needDevelopLv,active_info.openLv)
				else
					t_descString = t_descString .. "\n" .. GetLocalizeStringBy("llp_485",active_info.needDevelopLv-6,active_info.openLv)
				end
			else
				t_descString = t_descString .. "(" .. active_info.openLv .. GetLocalizeStringBy("key_1066")
			end
		end
		-- 描述
		local descLabel_PL = CCLabelTTF:create(t_descString, g_sFontName, 23)
		descLabel_PL:setColor(ccc3_c)
		descLabel_PL:setAnchorPoint(ccp(0, 0))
		containerLayer:addChild(descLabel_PL)
		containerHight = containerHight + descLabel_PL:getContentSize().height + 10
		attrFontTab[key] = descLabel_PL
	end

	-- 宝物天赋
	local tianTitle = CCRenderLabel:create(GetLocalizeStringBy("lic_1846"), g_sFontName, 25, 2, ccc3( 0x00, 0x00, 0x0d), type_stroke)
	tianTitle:setColor(ccc3(0x8a, 0xff, 0x00))
	tianTitle:setAnchorPoint(ccp(0, 1))
	containerLayer:addChild(tianTitle)

	containerHight = containerHight + tianTitle:getContentSize().height + 10

	-- 分割线
	local lineSprite3 = CCSprite:create("images/item/equipinfo/line.png")
	lineSprite3:setAnchorPoint(ccp(0, 1))
	lineSprite3:setScaleX(2)
	containerLayer:addChild(lineSprite3)

	containerHight = containerHight + tianTitle:getContentSize().height + 10

	for key, active_info in pairs(redAttrTab) do
        local affixDesc, displayNum = ItemUtil.getAtrrNameAndNum(active_info.attId, active_info.num)
	    local t_descString = affixDesc.sigleName .. " +" .. displayNum 

		local ccc3_c = nil
		if(active_info.isOpen)then
			ccc3_c = ccc3(0x78, 0x25, 0x00)
		else
			ccc3_c = ccc3(100,100,100)
			if( active_info.needDevelopLv )then
				if(active_info.needDevelopLv<6)then
					t_descString = t_descString .. "\n" .. GetLocalizeStringBy("lic_1560",active_info.needDevelopLv,active_info.openLv)
				else
					t_descString = t_descString .. "\n" .. GetLocalizeStringBy("llp_485",active_info.needDevelopLv-6,active_info.openLv)
				end
			else
				t_descString = t_descString .. "(" .. active_info.openLv .. GetLocalizeStringBy("key_1066")
			end
		end
		-- 描述
		local descLabel_PL = CCLabelTTF:create(t_descString, g_sFontName, 23)
		descLabel_PL:setColor(ccc3_c)
		descLabel_PL:setAnchorPoint(ccp(0, 0))
		containerLayer:addChild(descLabel_PL)
		containerHight = containerHight + descLabel_PL:getContentSize().height + 10
		redAttrFontTab[key] = descLabel_PL
	end

	containerLayer:setContentSize(CCSizeMake(viewSize.width,containerHight))
	scroll:setContainer(containerLayer)
	scroll:setContentOffset(ccp(0,scroll:getViewSize().height-containerLayer:getContentSize().height))

	-- 坐标
	local posY = containerHight
	posY = posY - 10
    local temp_length = nameLabel:getContentSize().width + enhanceLvLabel:getContentSize().width + 10
    nameLabel:setPosition(ccp((containerLayer:getContentSize().width-temp_length)/2, posY))
    enhanceLvLabel:setPosition(ccp((containerLayer:getContentSize().width-temp_length)/2 + nameLabel:getContentSize().width+5, posY))

    posY = posY - nameLabel:getContentSize().height - 20
    expTitle:setPosition(ccp(containerLayer:getContentSize().width*0.08, posY))
    bgProress:setPosition(ccp(containerLayer:getContentSize().width*0.28, posY))

    posY = posY - expTitle:getContentSize().height - 10
    attrLabelTitle:setPosition(ccp(containerLayer:getContentSize().width*0.08, posY))

    posY = posY - attrLabelTitle:getContentSize().height - 3
    lineSprite:setPosition(ccp(containerLayer:getContentSize().width*0.02, posY))

    posY = posY - lineSprite:getContentSize().height - 2
    descLabel:setPosition(ccp(containerLayer:getContentSize().width*0.1, posY))

    posY = posY - descLabel:getContentSize().height - 2
    enchanceLabelTitle:setPosition(ccp(containerLayer:getContentSize().width*0.08, posY))

    posY = posY - enchanceLabelTitle:getContentSize().height - 3
    lineSprite2:setPosition(ccp(containerLayer:getContentSize().width*0.02, posY))

    posY = posY - lineSprite2:getContentSize().height - 2

    for key, active_info in pairs(attrTab) do
    	if( active_info.needDevelopLv and active_info.isOpen == false)then
    		posY = posY - 50
    	else
    		posY = posY - 25
    	end
    	attrFontTab[key]:setPosition(ccp(containerLayer:getContentSize().width*0.08, posY))
    end

    posY = posY-10
    tianTitle:setPosition(ccp(containerLayer:getContentSize().width*0.08, posY))
    posY = posY - tianTitle:getContentSize().height - 3
    lineSprite3:setPosition(ccp(containerLayer:getContentSize().width*0.02, posY))

    posY = posY - lineSprite3:getContentSize().height - 2

    for key, active_info in pairs(redAttrTab) do
    	if( active_info.needDevelopLv and active_info.isOpen == false)then
    		posY = posY - 50
    	else
    		posY = posY - 25
    	end
    	redAttrFontTab[key]:setPosition(ccp(containerLayer:getContentSize().width*0.08, posY))
    end
end


-- 
local function create()
	local myScale = _bgLayer:getContentSize().width/640/_bgLayer:getElementScale()
	-- 背景
	local fullRect = CCRectMake(0,0,196, 198)
	local insetRect = CCRectMake(50,50,96,98)
	bgSprite = CCScale9Sprite:create("images/item/equipinfo/bg_9s.png", fullRect, insetRect)
	bgSprite:setPreferredSize( CCSizeMake(_bgLayer:getContentSize().width, _bgLayer:getContentSize().height-_topSprite:getContentSize().height*MainScene.elementScale))  -- (CCSizeMake(640, 930))
	bgSprite:setAnchorPoint(ccp(0.5, 0))
	bgSprite:setPosition(ccp(_bgLayer:getContentSize().width*0.5, -MenuLayer.getHeight() ))
	_bgLayer:addChild(bgSprite)

	print("treasure Reinforce layer position y = ", bgSprite:getPositionX())
	-- 顶部
	local topSprite = CCSprite:create("images/item/equipinfo/topbg.png")
	topSprite:setAnchorPoint(ccp(0.5, 1))
	topSprite:setPosition(ccp(bgSprite:getContentSize().width*0.5, bgSprite:getContentSize().height-MenuLayer.getHeight()))
	topSprite:setScale(myScale)
	_bgLayer:addChild(topSprite, 2)
	bgSprite:setScale(1/MainScene.elementScale)
	-- 标题
	local titleLabel = CCRenderLabel:create(GetLocalizeStringBy("key_2307"), g_sFontPangWa, 35, 1, ccc3( 0x00, 0x00, 0x00), type_stroke)
    titleLabel:setColor(ccc3(0xff, 0xe4, 0x00))
    titleLabel:setAnchorPoint(ccp(0.5, 0.5))
    titleLabel:setPosition(ccp( ( topSprite:getContentSize().width)/2, topSprite:getContentSize().height*0.55))
    topSprite:addChild(titleLabel)

-- 创建卡牌和属性
	createCardAndAttrUI()


-------------- 强化材料  --------------
	-- 材料背景
	enhanceBgSprite = CCScale9Sprite:create("images/common/bg/white_text_ng.png")
	enhanceBgSprite:setPreferredSize(CCSizeMake(570, 120))
	enhanceBgSprite:setAnchorPoint(ccp(0.5, 0.5))
	enhanceBgSprite:setPosition(ccp(bgSprite:getContentSize().width*0.5, bgSprite:getContentSize().height*0.26))
	bgSprite:addChild(enhanceBgSprite)
	enhanceBgSprite:setScale(MainScene.elementScale)

	--提示"点击图标取消选中的物品"
    local unselectTip = CCRenderLabel:create(GetLocalizeStringBy("zz_137"), g_sFontName, 22, 2, ccc3(0x00,0x00,0x00), type_shadow)
    unselectTip:setColor(ccc3(0x00,0xff,0x00))
    unselectTip:setAnchorPoint(ccp(0,0))
    unselectTip:setPosition(10,123)
    enhanceBgSprite:addChild(unselectTip)

	-- 创建5个材料背景
	recreateMaterialMenuBar()

	-- 银币
	local siliverTitleLabel = CCLabelTTF:create(GetLocalizeStringBy("key_1417"), g_sFontName, 23)
	siliverTitleLabel:setColor(ccc3(0x78, 0x25, 0x00))
	siliverTitleLabel:setAnchorPoint(ccp(0, 0.5))
	siliverTitleLabel:setPosition(ccp(bgSprite:getContentSize().width*0.1, bgSprite:getContentSize().height*0.15))
	bgSprite:addChild(siliverTitleLabel)
	siliverTitleLabel:setScale(MainScene.elementScale)

	local sliverSprite = CCSprite:create("images/common/coin.png")
	sliverSprite:setAnchorPoint(ccp(0, 0.5))
	sliverSprite:setPosition(ccp(bgSprite:getContentSize().width*0.26, bgSprite:getContentSize().height*0.15))
	bgSprite:addChild(sliverSprite)
	sliverSprite:setScale(MainScene.elementScale)

	local ttt_upgradeNeedNum = 0
	ttt_upgradeNeedNum, _levelLimited = BagUtil.getCostSliverByItemId(_item_id)
	-- 银币
	siliverLabel = CCLabelTTF:create(_upgradeNeedNum, g_sFontName, 23)
	siliverLabel:setColor(ccc3(0x00, 0x00, 0x00))
	siliverLabel:setAnchorPoint(ccp(0, 0.5))
	siliverLabel:setPosition(ccp(bgSprite:getContentSize().width*0.32, bgSprite:getContentSize().height*0.15))
	bgSprite:addChild(siliverLabel)
	siliverLabel:setScale(MainScene.elementScale)

	-- 升级概率
	local upgradTitleLabel = CCLabelTTF:create(GetLocalizeStringBy("key_3338"), g_sFontName, 23)
	upgradTitleLabel:setColor(ccc3(0x78, 0x25, 0x00))
	upgradTitleLabel:setAnchorPoint(ccp(0, 0.5))
	upgradTitleLabel:setPosition(ccp(bgSprite:getContentSize().width*0.5, bgSprite:getContentSize().height*0.15))
	bgSprite:addChild(upgradTitleLabel) 
	upgradTitleLabel:setScale(MainScene.elementScale)
	-- 概率
	_upgradRateLabel = CCRenderLabel:create("0", g_sFontName, 23, 1, ccc3( 0x00, 0x00, 0x00), type_stroke)
	_upgradRateLabel:setColor(ccc3(0x2c, 0xdb, 0x23))
	_upgradRateLabel:setAnchorPoint(ccp(0, 0.5))
	_upgradRateLabel:setPosition(ccp(bgSprite:getContentSize().width*0.68, bgSprite:getContentSize().height*0.15))
	bgSprite:addChild(_upgradRateLabel) 
	_upgradRateLabel:setScale(MainScene.elementScale)

	-- local arrActions = CCArray:create()
	-- local fadeIn = CCFadeIn:create(1.0)
	-- local fadeOut = CCFadeOut:create(1.0)
	-- arrActions:addObject(fadeIn)
	-- arrActions:addObject(fadeOut)
	-- local sequence = CCSequence:create(arrActions)
	-- local action = CCRepeatForever:create(sequence)
	-- _upgradRateLabel:runAction(action)

	-- 按钮
	local btnMenuBar = CCMenu:create()
	btnMenuBar:setPosition(ccp(0,0))
	btnMenuBar:setTouchPriority(_layerTouchPrority-2)
	bgSprite:addChild(btnMenuBar)

	-- 返回
	local backBtn = LuaMenuItem.createItemImage("images/item/equipinfo/reinforce/btn_back_n.png", "images/item/equipinfo/reinforce/btn_back_h.png")
	backBtn:setAnchorPoint(ccp(0.5, 0.5))
    backBtn:setPosition(ccp(bgSprite:getContentSize().width*0.18, bgSprite:getContentSize().height*0.08))
    backBtn:registerScriptTapHandler(menuAction)
	btnMenuBar:addChild(backBtn, 2, Tag_Back)
	backBtn:setScale(MainScene.elementScale)

	-- 强化
	local forceBtn = LuaMenuItem.createItemImage("images/item/equipinfo/reinforce/btn_force_n.png", "images/item/equipinfo/reinforce/btn_force_h.png")
	forceBtn:setAnchorPoint(ccp(0.5, 0.5))
    forceBtn:setPosition(ccp(bgSprite:getContentSize().width*0.5, bgSprite:getContentSize().height*0.08))
    forceBtn:registerScriptTapHandler(menuAction)
	btnMenuBar:addChild(forceBtn, 2, Tag_Force)
	forceBtn:setScale(MainScene.elementScale)

	--  自动添加
	local autoAddBtn = LuaMenuItem.createItemImage("images/hero/strengthen/buttons/autoadd_n.png", "images/hero/strengthen/buttons/autoadd_h.png")
	autoAddBtn:setAnchorPoint(ccp(0.5, 0.5))
    autoAddBtn:setPosition(ccp(bgSprite:getContentSize().width*0.82, bgSprite:getContentSize().height*0.08))
    autoAddBtn:registerScriptTapHandler(menuAction)
	btnMenuBar:addChild(autoAddBtn, 2, Tag_AutoAdd)
	autoAddBtn:setScale(MainScene.elementScale)
end

-- 
function materialAction( tag, itemBtn )
	if(_isCanEnhance == false)then
		return
	end
	
	if( tonumber(_treasData.va_item_text.treasureLevel) >= _levelLimited)then
		AnimationTip.showTip(GetLocalizeStringBy("key_2095"))
	else
		--当点击的按钮上已经选择了强化材料，再次点击时移除材料，并刷新需要消耗的银币和可获得的经验
		if _materialsArr and _materialsArr[tag] ~= nil then
			table.remove(_materialsArr,tag)
			setMaterialsArr(_materialsArr)
			return
		end

		require "script/ui/item/TreasSelectLayer"
		local treasSelectLayer = TreasSelectLayer.createLayer(_item_id, _treasData, _layerTouchPrority-10)
		local runningScene = CCDirector:sharedDirector():getRunningScene()
		runningScene:addChild(treasSelectLayer, 999)
	end
end

-- 创建5个材料背景
function recreateMaterialMenuBar()
	-- 按钮Bar
	if(_materialsMenuBar)then
		_materialsMenuBar:removeFromParentAndCleanup(true)
		_materialsMenuBar = nil
	end
	_materialsMenuItemArr = {}

	_materialsMenuBar = CCMenu:create()
	_materialsMenuBar:setPosition(ccp(0,0))
	enhanceBgSprite:addChild(_materialsMenuBar)
	_materialsMenuBar:setTouchPriority(_layerTouchPrority-2)
	
	local xScale = {0.1, 0.3, 0.5, 0.7, 0.9}

	for i=1,5 do
		local itemSprite = nil
		if(_materialsArr[i])then
			local item_info = ItemUtil.getItemInfoByItemId(_materialsArr[i].item_id)
			itemSprite = ItemSprite.getItemSpriteByItemId(item_info.item_template_id)
			-- 物品数量
			if( _materialsArr[i].num > 1 )then
				local numberLabel =  CCRenderLabel:create(_materialsArr[i].num , g_sFontName,21,2,ccc3(0x00,0x00,0x00),type_stroke)
				numberLabel:setColor(ccc3(0x00,0xff,0x18))
				numberLabel:setAnchorPoint(ccp(1,0))
				local width = itemSprite:getContentSize().width - 6
				numberLabel:setPosition(ccp(width,5))
				itemSprite:addChild(numberLabel,100)
			end
		else
			itemSprite = CCSprite:create("images/common/border.png")
			local addSprite = CCSprite:create("images/common/add_new.png")
			addSprite:setAnchorPoint(ccp(0.5,0.5))
			addSprite:setPosition(ccp(itemSprite:getContentSize().width*0.5, itemSprite:getContentSize().height*0.5))
			
			local arrActions_2 = CCArray:create()
			arrActions_2:addObject(CCFadeOut:create(1))
			arrActions_2:addObject(CCFadeIn:create(1))
			
			local sequence_2 = CCSequence:create(arrActions_2)
			local action_2 = CCRepeatForever:create(sequence_2)
			addSprite:runAction(action_2)
			itemSprite:addChild(addSprite)
		end
		local menuItem = CCMenuItemSprite:create(itemSprite, itemSprite)
		menuItem:setAnchorPoint(ccp(0.5, 0.5))
		menuItem:setPosition(ccp(enhanceBgSprite:getContentSize().width*xScale[i], enhanceBgSprite:getContentSize().height*0.5))
		menuItem:registerScriptTapHandler(materialAction)
		_materialsMenuBar:addChild(menuItem,1,i)

		-- 保存
		if(_materialsArr[i])then
			table.insert(_materialsMenuItemArr, menuItem)
		end
	end

end


-- 创建
function createLayer( item_id, delegateAction, p_isNeedHidden)
	init()
	_delegateAction = delegateAction
	_item_id = item_id

	if(p_isNeedHidden == nil)then
		_isNeedHidden = false
	else
		_isNeedHidden = p_isNeedHidden
	end

	_layerTouchPrority = -400

	prepareData()

	_bgLayer = MainScene.createBaseLayer("images/main/module_bg.png", true, false, true)
	_bgLayer:setScale(1/MainScene.elementScale)
	_bgLayer:registerScriptHandler(onNodeEvent)

	-- 
	createTopUI()
	create()

	return _bgLayer
end




