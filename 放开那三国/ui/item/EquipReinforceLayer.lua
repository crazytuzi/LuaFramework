-- Filename：	EquipReinforceLayer.lua
-- Author：		Cheng Liang
-- Date：		2013-7-27
-- Purpose：		装备强化

module("EquipReinforceLayer", package.seeall)


require "script/ui/item/ItemUtil"
require "script/ui/main/MainScene"
require "script/ui/common/LuaMenuItem"
require "script/network/RequestCenter"
require "script/model/user/UserModel"
require "script/model/hero/HeroModel"
require "script/model/DataCache"
require "script/ui/item/EquipCardSprite"
require "script/ui/tip/AnimationTip"

local Tag_Back 		= 90001
local Tag_Force 	= 90002
local Tag_Force_5 	= 90003


local _bgLayer 			= nil
local _item_id 			= nil
local _delegateAction 	= nil
local bgSprite			= nil

local _equipInfo 	= nil
local _equip_desc	= nil
local _fee_data 	= nil
local _n_string_t 	= {}		-- 属性名称
local _n_value_t 	= {}		-- 当前数值
local _n_value_e 	= {} 		-- 强化增加

-- 等级数值
local levelLabel 			= nil
-- 等级数值强化后
local levelLabel_e 		 	= nil
-- 当前值
local attrLabel_num_1 		= nil
-- 强化后值
local attrLabel_num_1_e 	= nil
-- 当前值
local attrLabel_num_2 		= nil
-- 强化后值
local attrLabel_num_2_e		= nil
-- 银币数值
local coinLabel 			= nil
-- 装备评分
local t_equip_score 		= 0
-- 装备是在hero身上还是背包中
local _isOnHero 			= false		
-- 装备卡牌
local _cardSprite 			= nil
-- 强化
local forceBtn				= nil
-- 自动强化
local autoBtn				= nil

-- 是否可强化
local _isCanEnhance 		= true

-- 是否强化5次
local _isEnhance_5 			= false
local add_lv 				= 0
local _isNeedHidden 		= false
local m_levelLabel 			= nil

-- 是否自动强化
local _isAutoEnhance 		= false

-- 真实的剩余硬币  自动强化用
local _realSilverNum 		= nil
-- 真实的装备等级 自动强化用
local _realArmLevel 		= nil
-- 真实的装备花费自动强化用
local _realArmLevelCost 	= nil


local _autoEnhaceResult 	= {} -- 自动强化的结果

local _curAutoEnhanceLoop 	= 0 	-- 自动强化的当前播放顺序

local _layerTouchPrority 	= nil

local _quality              = nil

-- 初始化
local function init()
	_bgLayer 		= nil
	bgSprite		= nil
	_item_id 		= nil
	_equipInfo 		= nil
	_equip_desc		= nil
	_fee_data 		= nil
	_n_string_t 	= {}		-- 属性名称
	_n_value_t 		= {}		-- 当前数值
	_n_value_e 		= {} 		-- 强化增加
	_isOnHero 		= false
	_delegateAction = nil
	t_equip_score 	= 0
	_cardSprite 	= nil
	forceBtn		= nil
	_isCanEnhance 	= true
	_isEnhance_5 	= false
	add_lv 			= 0
	_isNeedHidden 	= false
	m_levelLabel 	= nil
	_isAutoEnhance 	= false
	
	_realSilverNum 	= nil 		-- 真实的剩余硬币  自动强化用
	
	_realArmLevel 	= nil 		-- 真实的装备等级 自动强化用
	_autoEnhaceResult 	= {} 	-- 自动强化的结果
	
	_realArmLevelCost 	= nil 	-- 真实的装备花费自动强化用
	_curAutoEnhanceLoop = 0 	-- 自动强化的当前播放顺序
	_layerTouchPrority 	= nil

	_quality            = nil
end 

--[[
 @desc	 处理touches事件
 @para 	 string event
 @return 
--]]
local function onTouchesHandler( eventType, x, y )
	
	local touchBeganPoint = ccp(x, y)
	if (eventType == "began") then
		-- 是针对中间的scrollView滑动
        local vPosition = bgSprite:convertToNodeSpace(touchBeganPoint)
        if ( vPosition.x >0 and vPosition.x <  bgSprite:getContentSize().width and vPosition.y > 0 and vPosition.y <  bgSprite:getContentSize().height ) then
        	isTouch = true
        else
        	isTouch = false
        end
        return isTouch
	    
    elseif (eventType == "moved") then
    	
    else
        -- print("end")
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
		_bgLayer:registerScriptTouchHandler(onTouchesHandler, false, _layerTouchPrority, true)
		_bgLayer:setTouchEnabled(true)
	elseif (event == "exit") then
		print("exit")
		_bgLayer:unregisterScriptTouchHandler()
		if(_isAutoEnhance == true)then
			-- 自动强化结束后 清算数据
			setAutoEnhanceData()
		end
	end
end


-- 属性的变化
function showAttrChangeAnimation( addLv )
	local t_text = {}
	for k, strName in pairs(_n_string_t) do
		local o_text = {}
		o_text.txt = strName
		o_text.num = addLv* _n_value_e[k]
		table.insert(t_text, o_text)
	end
	require "script/utils/LevelUpUtil"
	LevelUpUtil.showFlyText(t_text)
end

-- 准备数据
local function prepareData()
	_equipInfo = ItemUtil.getItemInfoByItemId(_item_id)

    if(_equipInfo == nil )then
    	_isOnHero  = true
        _equipInfo = ItemUtil.getEquipInfoFromHeroByItemId(_item_id)
    end

    -- 获取装备数据
	require "db/DB_Item_arm"
	_equip_desc = DB_Item_arm.getDataById(_equipInfo.item_template_id)
	t_equip_score = _equip_desc.base_score

	-- 获取强化相关数值
	local fee_id = "" .. _equip_desc.quality .. _equip_desc.type
	require "db/DB_Reinforce_fee"
	_fee_data = DB_Reinforce_fee.getDataById( tonumber(fee_id) )

	-- -- 获得属性相关数值
	-- local t_numerial, t_numerial_PL
	-- t_numerial, t_numerial_PL, t_equip_score = ItemUtil.getTop2NumeralByIID(_item_id)
	
	_n_string_t = {}		-- 属性名称
	_n_value_t  = {}		-- 当前数值
	_n_value_e  = {} 		-- 强化增加
	-- for key,v_num in pairs(t_numerial) do
	-- 	n_name = nil
	-- 	if (key == "hp") then
	-- 		n_name = GetLocalizeStringBy("key_2075")
	-- 	elseif(key == "gen_att"  )then
	-- 		n_name = GetLocalizeStringBy("key_1727") 
	-- 	elseif(key == "phy_att"  )then
	-- 		n_name = GetLocalizeStringBy("key_1102") 
	-- 	elseif(key == "magic_att")then
	-- 		n_name = GetLocalizeStringBy("key_1289")
	-- 	elseif(key == "phy_def"  )then
	-- 		n_name = GetLocalizeStringBy("key_2804") 
	-- 	elseif(key == "magic_def")then
	-- 		n_name = GetLocalizeStringBy("key_1731")
	-- 	end
	-- 	table.insert(_n_string_t, n_name)
	-- 	table.insert(_n_value_t, v_num)
	-- 	table.insert(_n_value_e, t_numerial_PL[key])
	-- end

	-- 映射关系
	local showAttrId = {1,9,2,3,4,5}
	-- 当前基础属性
	local curBaseData = EquipAffixModel.getEquipAffixByEquipInfo( _equipInfo )
	local developData = EquipAffixModel.getDevelopAffixByInfo(_equipInfo)
	for k,v in pairs(curBaseData) do
		if(developData[k])then 
			curBaseData[k] = curBaseData[k] + developData[k] 
		end
	end

	-- 下一级的基础属性
	local nextEquipInfo = table.hcopy(_equipInfo, {})
	nextEquipInfo.va_item_text.armReinforceLevel = tonumber(nextEquipInfo.va_item_text.armReinforceLevel) + 1
	local nextBaseData = EquipAffixModel.getEquipAffixByEquipInfo( nextEquipInfo )
	local nextDevelopData = EquipAffixModel.getDevelopAffixByInfo(nextEquipInfo)
	for k,v in pairs(nextBaseData) do
		if(nextDevelopData[k])then 
			nextBaseData[k] = nextBaseData[k] + nextDevelopData[k] 
		end
	end
	for k,v_id in pairs(showAttrId) do
		if( curBaseData[v_id] > 0 )then
		    local affixDesc, displayNum1 = ItemUtil.getAtrrNameAndNum(v_id,curBaseData[v_id])
			table.insert(_n_string_t, affixDesc.sigleName)
			table.insert(_n_value_t, displayNum1)
			local affixDesc, displayNum2 = ItemUtil.getAtrrNameAndNum(v_id,nextBaseData[v_id])
			table.insert(_n_value_e, displayNum2-displayNum1)
		end
	end
	-- print("_n_string_t")print_t(_n_string_t)
	-- print("_n_value_t")print_t(_n_value_t)
	-- print("_n_value_e")print_t(_n_value_e)
end


-- 刷新界面
local function refreshUI(  )
	
	local t_increse = {}
	m_levelLabel:setString( _equipInfo.va_item_text.armReinforceLevel .. "/" .. _equip_desc.level_limit_ratio * UserModel.getHeroLevel())
	-- 等级数值
	levelLabel:setString("lv." .. _equipInfo.va_item_text.armReinforceLevel)

	-- 等级数值强化后
	levelLabel_e:setString("lv." .. (_equipInfo.va_item_text.armReinforceLevel+1))
	-- 当前值
	attrLabel_num_1:setString( "+" .. _n_value_t[1])
	-- 强化后值
	attrLabel_num_1_e:setString( "+" .. (_n_value_t[1] + _n_value_e[1]))
	if(_n_string_t[2])then
		-- 当前值
		attrLabel_num_2:setString( "+" .. _n_value_t[2] )
		-- 强化后值
		attrLabel_num_2_e:setString( "+" .. (_n_value_t[2] + _n_value_e[2]))
	end
	-- 银币数值
	coinLabel:setString( _fee_data["coin_lv" .. (_equipInfo.va_item_text.armReinforceLevel+1)] )

	EquipCardSprite.refreshCardSprite(_cardSprite)
end 



-- 强化回调
function reinforceCallback( cbFlag, dictData, bRet )
	
	if(dictData.err == "ok")then
		require "script/audio/AudioUtil"
		AudioUtil.playEffect("audio/effect/qianghuachuizi.mp3")
		local cost_silver = _fee_data["coin_lv" .. (_equipInfo.va_item_text.armReinforceLevel+1)]
		add_lv = tonumber(dictData.ret.level_num)

		UserModel.changeSilverNumber(-cost_silver)

		if(_isOnHero)then
			HeroModel.changeHeroEquipReinforceBy(_equipInfo.hid, _item_id, add_lv )
			HeroModel.changeHeroEquipReinforceCostBy(_equipInfo.hid, _item_id, tonumber(dictData.ret.cost_num))
		else
			DataCache.changeArmReinforceBy( _item_id, add_lv )
			DataCache.changeArmReinforceCostBy(_item_id, tonumber(dictData.ret.cost_num))
		end

		-- 锤子动画
		hammerEffect()

	end
end

-- 强化 锤子动画
function hammerEffect()
	-- 锤子动画
		local spellEffectSprite = CCLayerSprite:layerSpriteWithName(CCString:create("images/base/effect/item/qianghuachuizi"), -1,CCString:create(""));

	    spellEffectSprite:setPosition(_cardSprite:getContentSize().width*0.5,_cardSprite:getContentSize().height*0.5)
	    _cardSprite:addChild(spellEffectSprite,1);

	    -- 卡牌动画
	    local animationStart_2 = function ()
    	local spellEffectSprite_2 = CCLayerSprite:layerSpriteWithName(CCString:create("images/base/effect/hero/qianghua"), -1,CCString:create(""));
	    spellEffectSprite_2:retain()
	    spellEffectSprite_2:autorelease()
	    spellEffectSprite_2:setPosition(_cardSprite:getContentSize().width*0.5, _cardSprite:getContentSize().height*0.5)
	    _cardSprite:addChild(spellEffectSprite_2,1);
	    enhanceResultEffect(add_lv)

	    local animation_2_End = function(actionName,xmlSprite)
		    prepareData()
			refreshUI()
	        spellEffectSprite_2:removeFromParentAndCleanup(true)
	        _isCanEnhance = true
	        overAnimationDelegate()
	        
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

    --delegate
    -- 结束回调
    local animation_1_End = function(actionName,xmlSprite)
    	spellEffectSprite:retain()
	    spellEffectSprite:autorelease()
        spellEffectSprite:removeFromParentAndCleanup(true)
        
    end
    -- 每次回调
    local animationFrameChanged = function(frameIndex,xmlSprite)
        if(tonumber(frameIndex) == 9 )then
        	animationStart_2()
        end
    end

    --增加动画监听
    local delegate = BTAnimationEventDelegate:create()
    delegate:registerLayerEndedHandler(animation_1_End)
    delegate:registerLayerChangedHandler(animationFrameChanged)
    spellEffectSprite:setDelegate(delegate)

end

-- 暴击动画
function enhanceResultEffect(addLv)

	require "script/audio/AudioUtil"
	AudioUtil.playEffect("audio/effect/qianghuachenggong.mp3")
	local effectName_t = "images/base/effect/enhance/qianghuachenggong2"
	if(tonumber(addLv) <= 1) then
		effectName_t = "images/base/effect/enhance/qianghuachenggong"
	end
	local spellEffectSprite_2 = CCLayerSprite:layerSpriteWithName(CCString:create(effectName_t), -1,CCString:create(""));
    spellEffectSprite_2:setPosition(_cardSprite:getContentSize().width*0.5, _cardSprite:getContentSize().height*0.5)

    -- 替换强化等级
    local replaceXmlSprite = tolua.cast( spellEffectSprite_2:getChildByTag(1006) , "CCXMLSprite")
    replaceXmlSprite:setReplaceFileName(CCString:create("images/common/" .. addLv .. ".png"))

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

	local runningScene = CCDirector:sharedDirector():getRunningScene()
	spellEffectSprite_2:setPosition(ccp(runningScene:getContentSize().width*0.5, runningScene:getContentSize().height*0.5))
	runningScene:addChild(spellEffectSprite_2, 999)

	-- 属性变化
	showAttrChangeAnimation(addLv)
end

-- 动画结束回调
function overAnimationDelegate()
	if(_isAutoEnhance and _curAutoEnhanceLoop < #_autoEnhaceResult)then
		_curAutoEnhanceLoop = _curAutoEnhanceLoop + 1
		showOneAutoEnhanceEffect()
	end
end

-- 自动强化的一次特效展示
function showOneAutoEnhanceEffect()
	require "script/audio/AudioUtil"
	AudioUtil.playEffect("audio/effect/qianghuachuizi.mp3")

	add_lv = tonumber(_autoEnhaceResult[_curAutoEnhanceLoop].level_num)

	UserModel.changeSilverNumber(-tonumber(_autoEnhaceResult[_curAutoEnhanceLoop].cost_num))

	if(_isOnHero)then
		HeroModel.changeHeroEquipReinforceBy(_equipInfo.hid, _item_id, add_lv )
	else
		DataCache.changeArmReinforceBy( _item_id, add_lv )
	end

	-- 锤子动画
	hammerEffect()
end

-- 自动强化回调
function autoEnhanceCallback( cbFlag, dictData, bRet )
	if(dictData.err == "ok")then

		if( not table.isEmpty(dictData.ret) )then
			local t_cost = 0
			local t_addLv = 0
			_autoEnhaceResult = dictData.ret
			for k, enhance_data in pairs(_autoEnhaceResult) do
				t_cost = t_cost + tonumber(enhance_data.cost_num)
				t_addLv = t_addLv + tonumber(enhance_data.level_num)
			end

			_realSilverNum = UserModel.getSilverNumber() - t_cost
			_realArmLevel = tonumber(_equipInfo.va_item_text.armReinforceLevel) + t_addLv
			if(_equipInfo.va_item_text.armReinforceCost)then
				_realArmLevelCost = tonumber(_equipInfo.va_item_text.armReinforceCost) + t_cost
			else
				_realArmLevelCost = t_cost
			end
			printTable("autoEnhanceCallback", _equipInfo)
			_curAutoEnhanceLoop = 1
			showOneAutoEnhanceEffect()
			--刷新装备属性
			require "script/model/hero/HeroAffixFlush"
			HeroAffixFlush.onChangeEquip(_equipInfo.hid)
		end
	end
end

-- 自动强化
function autoEnhanceAction( tag, itemBtn )
	require "script/audio/AudioUtil"
	AudioUtil.playEffect("audio/effect/zhujiemian.mp3")
	---[==[铁匠铺 新手引导屏蔽层
	---------------------新手引导---------------------------------
	--add by licong 2013.09.26
	require "script/guide/NewGuide"
	if(NewGuide.guideClass == ksGuideSmithy) then
		require "script/guide/EquipGuide"
		EquipGuide.changLayer()
	end
	---------------------end-------------------------------------
	--]==]
	if( tonumber(_equipInfo.va_item_text.armReinforceLevel) >= _equip_desc.level_limit_ratio * UserModel.getHeroLevel())then
		AnimationTip.showTip(GetLocalizeStringBy("key_2095"))
	elseif(_fee_data["coin_lv" .. (_equipInfo.va_item_text.armReinforceLevel+1)] > UserModel.getSilverNumber()) then
		AnimationTip.showTip(GetLocalizeStringBy("key_1114"))
	elseif(_isCanEnhance == true and _isAutoEnhance ~= true) then
		_isCanEnhance = false
		_isAutoEnhance = true
		local args = Network.argsHandler(_item_id)
		RequestCenter.forge_autoReinforceArm(autoEnhanceCallback, args )
	end
	-- 铁匠铺 第6步 指向副本
	local seq = CCSequence:createWithTwoActions(CCDelayTime:create(0.3),CCCallFunc:create(function ( ... )
		addGuideEquipGuide6()
	end))
	_bgLayer:runAction(seq)
end

-- 自动强化结束后 清算数据
function setAutoEnhanceData()

	-- 修改装备等级
	if(_isOnHero)then
		HeroModel.setHeroEquipReinforceLevelBy(_equipInfo.hid, _item_id, _realArmLevel )
		HeroModel.setHeroEquipReinforceLevelCostBy(_equipInfo.hid, _item_id, _realArmLevelCost )
	else
		DataCache.setArmReinforceLevelBy( _item_id, _realArmLevel )
		DataCache.setArmReinforceLevelCostBy( _item_id, _realArmLevelCost )
	end

	-- 修改花费
	UserModel.addSilverNumber(_realSilverNum - UserModel.getSilverNumber())
	require "script/model/hero/HeroAffixFlush"
	HeroAffixFlush.onChangeEquip(_equipInfo.hid)
end

-- 
function menuAction( tag, itemBtn )
	require "script/audio/AudioUtil"
	AudioUtil.playEffect("audio/effect/zhujiemian.mp3")
	if(tag == Tag_Back)then
		if (_isAutoEnhance ~= true and _delegateAction) then
			_delegateAction()
		end
		require "script/audio/AudioUtil"
		AudioUtil.playEffect("audio/effect/guanbi.mp3")
		_bgLayer:removeFromParentAndCleanup(true)
		_bgLayer=nil

		if(_isNeedHidden)then
			MainScene.setMainSceneViewsVisible(true, false, true)
		end

		-- 是否自动强化
		if(_isAutoEnhance == true)then
			_isAutoEnhance = false
			setAutoEnhanceData()
			_delegateAction()
		end

	elseif(tag == Tag_Force)then
		if( tonumber(_equipInfo.va_item_text.armReinforceLevel) >= _equip_desc.level_limit_ratio * UserModel.getHeroLevel())then
			AnimationTip.showTip(GetLocalizeStringBy("key_2095"))
		elseif(_fee_data["coin_lv" .. (_equipInfo.va_item_text.armReinforceLevel+1)] > UserModel.getSilverNumber()) then
			AnimationTip.showTip(GetLocalizeStringBy("key_1114"))
		elseif(_isCanEnhance == true and _isAutoEnhance ~= true) then
			_isCanEnhance = false
			_isEnhance_5 = false
			local args = Network.argsHandler(_item_id)
			RequestCenter.forge_reinforce(reinforceCallback,args )
		end
	elseif(tag == Tag_Force_5)then
		
		if( tonumber(_equipInfo.va_item_text.armReinforceLevel) + 4 >= _equip_desc.level_limit_ratio * UserModel.getHeroLevel())then
			AnimationTip.showTip(GetLocalizeStringBy("key_2535"))
		else
			local t_moeny = 0
			for i=1, 5 do
				t_moeny = t_moeny + _fee_data["coin_lv" .. (_equipInfo.va_item_text.armReinforceLevel+i)]
			end
			if(t_moeny > UserModel.getSilverNumber()) then
				AnimationTip.showTip(GetLocalizeStringBy("key_1270") .. t_moeny .. GetLocalizeStringBy("key_1687"))
			elseif(_isCanEnhance == true) then
				_isCanEnhance = false
				_isEnhance_5 = true
				local args = Network.argsHandler(_item_id, 5)
				RequestCenter.forge_reinforce(reinforceCallback,args )
			end
		end
	end
end

-- 
local function create()
	local myScale = _bgLayer:getContentSize().width/640/_bgLayer:getElementScale()
	-- 背景
	local fullRect = CCRectMake(0,0,196, 198)
	local insetRect = CCRectMake(50,50,96,98)
	bgSprite = CCScale9Sprite:create("images/item/equipinfo/bg_9s.png", fullRect, insetRect)
	bgSprite:setPreferredSize(_bgLayer:getContentSize())  -- (CCSizeMake(640, 930))
	bgSprite:setAnchorPoint(ccp(0.5, 0))
	bgSprite:setPosition(ccp(_bgLayer:getContentSize().width*0.5, -MenuLayer.getHeight()))
	_bgLayer:addChild(bgSprite)
	-- 顶部
	local topSprite = CCSprite:create("images/item/equipinfo/topbg.png")
	topSprite:setAnchorPoint(ccp(0.5, 1))
	topSprite:setPosition(ccp(bgSprite:getContentSize().width*0.5, bgSprite:getContentSize().height-MenuLayer.getHeight()))
	topSprite:setScale(myScale)
	_bgLayer:addChild(topSprite, 2)
	bgSprite:setScale(1/MainScene.elementScale)
	-- 标题
	local titleLabel = CCRenderLabel:create(GetLocalizeStringBy("key_3074"), g_sFontName, 35, 1, ccc3( 0x00, 0x00, 0x00), type_stroke)
    titleLabel:setColor(ccc3(0xff, 0xa2, 0x00))
    titleLabel:setPosition(ccp( ( topSprite:getContentSize().width - titleLabel:getContentSize().width)/2, topSprite:getContentSize().height*0.85))
    topSprite:addChild(titleLabel)

	-- 卡牌
	_cardSprite = EquipCardSprite.createSprite(nil, _item_id, _quality)
	_cardSprite:setAnchorPoint(ccp(0.5, 1))
	_cardSprite:setPosition(ccp(bgSprite:getContentSize().width*0.25, bgSprite:getContentSize().height*0.88))
	bgSprite:addChild(_cardSprite)
	_cardSprite:setScale(MainScene.elementScale)

----------------------------- 强化信息 --------------------------
	-- 强化背景
	local fullRect = CCRectMake(0,0,75, 75)
	local insetRect = CCRectMake(25,25,25,25)
	local infoSpriteSp = CCScale9Sprite:create("images/item/equipinfo/reinforce/bg_9s.png", fullRect, insetRect)
	infoSpriteSp:setPreferredSize(CCSizeMake(290, 440))  -- (CCSizeMake(640, 930))
	infoSpriteSp:setAnchorPoint(ccp(0.5, 1))
	infoSpriteSp:setPosition(ccp(bgSprite:getContentSize().width*0.75, bgSprite:getContentSize().height*0.88))
	bgSprite:addChild(infoSpriteSp)
	infoSpriteSp:setScale(MainScene.elementScale)

	-- 强化标题
	local forceLabelTitle = CCLabelTTF:create(GetLocalizeStringBy("key_1940"), g_sFontName, 35)
	forceLabelTitle:setColor(ccc3(0x00, 0x00, 0x00))
	forceLabelTitle:setAnchorPoint(ccp(0.5, 1))
	forceLabelTitle:setPosition(ccp(infoSpriteSp:getContentSize().width*0.5, infoSpriteSp:getContentSize().height*0.98))
	infoSpriteSp:addChild(forceLabelTitle)

	local fullRect_attr = CCRectMake(0,0,61,47)
	local insetRect_attr = CCRectMake(10,10,41,27)
	-- 属性背景
	local attrBg = CCScale9Sprite:create("images/copy/fort/textbg.png", fullRect_attr, insetRect_attr)
	attrBg:setPreferredSize(CCSizeMake(260, 365))
	attrBg:setAnchorPoint(ccp(0.5, 1))
	attrBg:setPosition(ccp(infoSpriteSp:getContentSize().width*0.5, infoSpriteSp:getContentSize().height*0.88))
	infoSpriteSp:addChild(attrBg)

--------------------------------------- 已经强化的数值 ---------------------------
	-- 名称
	local quality = nil
    if _quality ~= nil and _quality ~= -1 then
        quality = _quality
    else
        quality = ItemUtil.getEquipQualityByItemInfo(_equipInfo)
    end
    if quality == nil then
        quality = _equip_desc.quality
    end
	local nameColor = HeroPublicLua.getCCColorByStarLevel(quality)
	local nameLabel = CCRenderLabel:create(_equip_desc.name, g_sFontPangWa, 25, 1, ccc3( 0x00, 0x00, 0x00), type_stroke)
	nameLabel:setColor(nameColor)
	nameLabel:setAnchorPoint(ccp(0.5, 0.5))
	nameLabel:setPosition(ccp(attrBg:getContentSize().width*0.5, attrBg:getContentSize().height*0.85))
	attrBg:addChild(nameLabel)


	-- 箭头
	local arrowSp_1 = CCSprite:create("images/item/equipinfo/reinforce/arrow.png")
	arrowSp_1:setAnchorPoint(ccp(0.5, 0.5))
	arrowSp_1:setPosition(ccp(attrBg:getContentSize().width*155.0/260, attrBg:getContentSize().height*225.0/365))
	attrBg:addChild(arrowSp_1)
	local arrowSp_2 = CCSprite:create("images/item/equipinfo/reinforce/arrow.png")
	arrowSp_2:setAnchorPoint(ccp(0.5, 0.5))
	arrowSp_2:setPosition(ccp(attrBg:getContentSize().width*155.0/260, attrBg:getContentSize().height*190.0/365))
	attrBg:addChild(arrowSp_2)
	if(_n_string_t[2])then
		local arrowSp_3 = CCSprite:create("images/item/equipinfo/reinforce/arrow.png")
		arrowSp_3:setAnchorPoint(ccp(0.5, 0.5))
		arrowSp_3:setPosition(ccp(attrBg:getContentSize().width*155.0/260, attrBg:getContentSize().height*160.0/365))
		attrBg:addChild(arrowSp_3)
	end

	-- 当前等级
	local m_levelTitleLabel = CCLabelTTF:create(GetLocalizeStringBy("key_1734"), g_sFontName, 23)
	m_levelTitleLabel:setColor(ccc3(0x78, 0x25, 0x00))
	m_levelTitleLabel:setAnchorPoint(ccp(0.5, 0.5))
	m_levelTitleLabel:setPosition(ccp(attrBg:getContentSize().width*40.0/260, attrBg:getContentSize().height*270.0/365))
	attrBg:addChild(m_levelTitleLabel)
	-- 等级数值
	m_levelLabel = CCLabelTTF:create( _equipInfo.va_item_text.armReinforceLevel .. "/" .. _equip_desc.level_limit_ratio * UserModel.getHeroLevel() , g_sFontName, 23)
	m_levelLabel:setColor(ccc3(0x00, 0x00, 0x00))
	m_levelLabel:setAnchorPoint(ccp(0.5, 0.5))
	m_levelLabel:setPosition(ccp(attrBg:getContentSize().width*105.0/260, attrBg:getContentSize().height*270.0/365))
	attrBg:addChild(m_levelLabel)

	-- 等级
	local levelTitleLabel = CCLabelTTF:create(GetLocalizeStringBy("key_1734"), g_sFontName, 23)
	levelTitleLabel:setColor(ccc3(0x78, 0x25, 0x00))
	levelTitleLabel:setAnchorPoint(ccp(0.5, 0.5))
	levelTitleLabel:setPosition(ccp(attrBg:getContentSize().width*40.0/260, attrBg:getContentSize().height*225.0/365))
	attrBg:addChild(levelTitleLabel)
	-- 等级数值
	levelLabel = CCLabelTTF:create("lv." .. _equipInfo.va_item_text.armReinforceLevel, g_sFontName, 23)
	levelLabel:setColor(ccc3(0x00, 0x00, 0x00))
	levelLabel:setAnchorPoint(ccp(0.5, 0.5))
	levelLabel:setPosition(ccp(attrBg:getContentSize().width*105.0/260, attrBg:getContentSize().height*225.0/365))
	attrBg:addChild(levelLabel)

	-- 等级数值强化后
	levelLabel_e = CCLabelTTF:create("lv." .. _equipInfo.va_item_text.armReinforceLevel+1, g_sFontName, 23)
	levelLabel_e:setColor(ccc3(0x00, 0x00, 0x00))
	levelLabel_e:setAnchorPoint(ccp(0.5, 0.5))
	levelLabel_e:setPosition(ccp(attrBg:getContentSize().width*210.0/260, attrBg:getContentSize().height*225.0/365))
	attrBg:addChild(levelLabel_e)

	-- 属性1
	if(_n_string_t[1])then
		local attrLabel_1 = CCLabelTTF:create("" .. _n_string_t[1], g_sFontName, 23)
		attrLabel_1:setColor(ccc3(0x78, 0x25, 0x00))
		attrLabel_1:setAnchorPoint(ccp(0.5, 0.5))
		attrLabel_1:setPosition(ccp(attrBg:getContentSize().width*40.0/260, attrBg:getContentSize().height*190.0/365))
		attrBg:addChild(attrLabel_1)
		-- 当前值
		attrLabel_num_1 = CCLabelTTF:create("+" .. _n_value_t[1], g_sFontName, 23)
		attrLabel_num_1:setColor(ccc3(0x00, 0x00, 0x00))
		attrLabel_num_1:setAnchorPoint(ccp(0.5, 0.5))
		attrLabel_num_1:setPosition(ccp(attrBg:getContentSize().width*105.0/260, attrBg:getContentSize().height*190.0/365))
		attrBg:addChild(attrLabel_num_1)

		-- 强化后值
		attrLabel_num_1_e = CCLabelTTF:create("+" .. (_n_value_t[1] + _n_value_e[1]), g_sFontName, 23)
		attrLabel_num_1_e:setColor(ccc3(0x00, 0x6d, 0x2f))
		attrLabel_num_1_e:setAnchorPoint(ccp(0.5, 0.5))
		attrLabel_num_1_e:setPosition(ccp(attrBg:getContentSize().width*210.0/260, attrBg:getContentSize().height*190.0/365))
		attrBg:addChild(attrLabel_num_1_e)
	end
	

	if(_n_string_t[2])then
		-- 属性2
		local attrLabel_2 = CCLabelTTF:create( "" ..  _n_string_t[2], g_sFontName, 23)
		attrLabel_2:setColor(ccc3(0x78, 0x25, 0x00))
		attrLabel_2:setAnchorPoint(ccp(0.5, 0.5))
		attrLabel_2:setPosition(ccp(attrBg:getContentSize().width*40.0/260, attrBg:getContentSize().height*160.0/365))
		attrBg:addChild(attrLabel_2)
		-- 当前值
		attrLabel_num_2 = CCLabelTTF:create("+" .. _n_value_t[2], g_sFontName, 23)
		attrLabel_num_2:setColor(ccc3(0x00, 0x00, 0x00))
		attrLabel_num_2:setAnchorPoint(ccp(0.5, 0.5))
		attrLabel_num_2:setPosition(ccp(attrBg:getContentSize().width*105.0/260, attrBg:getContentSize().height*160.0/365))
		attrBg:addChild(attrLabel_num_2)

		-- 强化后值
		attrLabel_num_2_e = CCLabelTTF:create("+" .. (_n_value_t[2] + _n_value_e[2]), g_sFontName, 23)
		attrLabel_num_2_e:setColor(ccc3(0x00, 0x6d, 0x2f))
		attrLabel_num_2_e:setAnchorPoint(ccp(0.5, 0.5))
		attrLabel_num_2_e:setPosition(ccp(attrBg:getContentSize().width*210.0/260, attrBg:getContentSize().height*160.0/365))
		attrBg:addChild(attrLabel_num_2_e)
	end

	-- 重生和炼化信息提示
	if(_equip_desc.quality >= 3)then

		local otherString = ""
		if(_equip_desc.quality==5)then
			otherString = GetLocalizeStringBy("key_3060")
		else
			otherString = GetLocalizeStringBy("key_2495")
		end
		local otherTipLabel = CCLabelTTF:create(otherString, g_sFontName, 23, CCSizeMake(260, 80), kCCTextAlignmentCenter, kCCVerticalTextAlignmentBottom)
		otherTipLabel:setColor(ccc3(0x00, 0x6d, 0x2f))
		otherTipLabel:setAnchorPoint(ccp(0.5, 0))
		otherTipLabel:setPosition(ccp(attrBg:getContentSize().width*0.5, attrBg:getContentSize().height*50.0/365))
		attrBg:addChild(otherTipLabel)
	end
	

	-- 银币
	local coinTitleLabel = CCLabelTTF:create(GetLocalizeStringBy("key_3073"), g_sFontName, 23)
	coinTitleLabel:setColor(ccc3(0x00, 0x6d, 0x2f))
	coinTitleLabel:setAnchorPoint(ccp(0.5, 0.5))
	coinTitleLabel:setPosition(ccp(attrBg:getContentSize().width*75.0/260, attrBg:getContentSize().height*26.0/365))
	attrBg:addChild(coinTitleLabel)

	-- 银币图标
	local coinSp = CCSprite:create("images/common/coin.png")
	coinSp:setAnchorPoint(ccp(0.5, 0.5))
	coinSp:setPosition(ccp(attrBg:getContentSize().width*140.0/260, attrBg:getContentSize().height*26.0/365))
	attrBg:addChild(coinSp)

	-- 银币数值
	coinLabel = CCLabelTTF:create(_fee_data["coin_lv" .. (_equipInfo.va_item_text.armReinforceLevel+1)], g_sFontName, 23)
	coinLabel:setColor(ccc3(0x00, 0x6d, 0x2f))
	coinLabel:setAnchorPoint(ccp(0, 0.5))
	coinLabel:setPosition(ccp(attrBg:getContentSize().width*160.0/260, attrBg:getContentSize().height*26.0/365))
	attrBg:addChild(coinLabel)

--------------------------------- 操作按钮 --------------------------
	-- 按钮Bar
	local btnMenuBar = CCMenu:create()
	btnMenuBar:setPosition(ccp(0, 0))
	bgSprite:addChild(btnMenuBar)
	btnMenuBar:setTouchPriority(_layerTouchPrority-2)
	-- 返回
	local backBtn = LuaCC.create9ScaleMenuItem("images/common/btn/btn1_d.png","images/common/btn/btn1_n.png",CCSizeMake(210,73),GetLocalizeStringBy("key_2661"),ccc3(255,222,0))
	backBtn:setAnchorPoint(ccp(0.5, 0.5))
    backBtn:setPosition(ccp(bgSprite:getContentSize().width*0.18, bgSprite:getContentSize().height*0.1))
    backBtn:registerScriptTapHandler(menuAction)
	btnMenuBar:addChild(backBtn, 2, Tag_Back)
	backBtn:setScale(MainScene.elementScale)

	-- 自动强化
	autoBtn = LuaCC.create9ScaleMenuItem("images/common/btn/btn1_d.png","images/common/btn/btn1_n.png",CCSizeMake(210,73),GetLocalizeStringBy("key_2567"),ccc3(255,222,0))
	autoBtn:setAnchorPoint(ccp(0.5, 0.5))
    autoBtn:setPosition(ccp(bgSprite:getContentSize().width*0.5, bgSprite:getContentSize().height*0.1))
    autoBtn:registerScriptTapHandler(autoEnhanceAction)
	btnMenuBar:addChild(autoBtn)
	autoBtn:setScale(MainScene.elementScale)

	-- 强化
	forceBtn = LuaCC.create9ScaleMenuItem("images/common/btn/btn1_d.png","images/common/btn/btn1_n.png",CCSizeMake(210,73),GetLocalizeStringBy("key_3391"),ccc3(255,222,0))
	forceBtn:setAnchorPoint(ccp(0.5, 0.5))
    forceBtn:setPosition(ccp(bgSprite:getContentSize().width*0.82, bgSprite:getContentSize().height*0.1))
    forceBtn:registerScriptTapHandler(menuAction)
	btnMenuBar:addChild(forceBtn, 2, Tag_Force)
	forceBtn:setScale(MainScene.elementScale)
end


-- 创建
function createLayer( item_id, delegateAction, isNeedHidden, pQuality )
	init()
	_delegateAction = delegateAction
	_item_id = item_id
	prepareData()
	_isNeedHidden = isNeedHidden or false
	_layerTouchPrority = -400
	_quality = pQuality
	_bgLayer = MainScene.createBaseLayer("images/main/module_bg.png", true, true, true)
	_bgLayer:setScale(1/MainScene.elementScale)
	_bgLayer:registerScriptHandler(onNodeEvent)
	create()


	-- 铁匠铺 第5步 点击 强化按钮
	local seq = CCSequence:createWithTwoActions(CCDelayTime:create(0.3),CCCallFunc:create(function ( ... )
		addGuideEquipGuide5()
	end))
	_bgLayer:runAction(seq)

	return _bgLayer
end

-- 新手引导
function getGuideObject()
	return autoBtn
end


---[==[铁匠铺 第5步
---------------------新手引导---------------------------------
function addGuideEquipGuide5( ... )
	require "script/guide/NewGuide"
	require "script/guide/EquipGuide"
    if(NewGuide.guideClass ==  ksGuideSmithy and EquipGuide.stepNum == 4) then
        local equipButton = getGuideObject()
        local touchRect   = getSpriteScreenRect(equipButton)
        EquipGuide.show(5, touchRect)
    end
end
---------------------end-------------------------------------
--]==]

---[==[铁匠铺 第6步
---------------------新手引导---------------------------------
function addGuideEquipGuide6( ... )
	require "script/guide/NewGuide"
	require "script/guide/EquipGuide"
    if(NewGuide.guideClass ==  ksGuideSmithy and EquipGuide.stepNum == 5) then
    	require "script/ui/main/MenuLayer"
        local equipButton = MenuLayer.getMenuItemNode(3)
        local touchRect   = getSpriteScreenRect(equipButton)
        EquipGuide.show(6, touchRect)
    end
end
---------------------end-------------------------------------
--]==]

