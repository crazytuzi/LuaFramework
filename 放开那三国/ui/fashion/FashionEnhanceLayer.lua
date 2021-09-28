-- FileName: FashionEnhanceLayer.lua 
-- Author: Li Cong 
-- Date: 14-4-3 
-- Purpose: function description of module 


module("FashionEnhanceLayer", package.seeall)

require "script/ui/item/ItemUtil"
require "script/ui/main/MainScene"
require "script/ui/common/LuaMenuItem"
require "script/network/RequestCenter"
require "script/model/user/UserModel"
require "script/model/hero/HeroModel"
require "script/model/DataCache"
require "script/ui/tip/AnimationTip"
require "script/ui/fashion/FashionInfo"
require "script/ui/fashion/FashionData"
require "script/ui/fashion/FashionLayer"



local Tag_Back 					= 90001 -- 返回
local Tag_Force 				= 90002 -- 强化

local _bgLayer 					= nil
local _item_id 					= nil
local _delegateAction 			= nil
local bgSprite					= nil
local _topBg 					= nil
local _silverLabel 				= nil
local _goldLabel 				= nil
local _equipInfo 				= nil -- 目标时装数据
local attrTable 				= nil -- 当前属性数据
local nextAttrTable 			= nil -- 下级属性数据
local nextLvCost 				= nil -- 下级消费数据
local haveNum 					= nil -- 拥有时装精华个数
local levelLabel 				= nil -- 当前等级数值label
local curLv 					= nil -- 当前等级数值
local coinLabel 				= nil -- 消耗银币label
local jingLabel_1 				= nil -- 消耗精华lable
local jingLabel_2 				= nil -- 拥有精华lable
local _isOnHero 				= false	-- 时装是在hero身上还是背包中	
local _cardSprite 				= nil -- 时装卡牌
local forceBtn					= nil -- 强化按钮
local _isCanEnhance 			= true -- 是否强化
local topHeight 				= nil -- 上边高度
local arrowSpTab 				= {} -- 箭头
local nextAttrLabTable 			= {} -- 下级属性label
local curAttrLabTable 			= {} -- 当前属性label
local _nCounterOfHeroLevel 		= 0 -- 特效变换计数器
local nextLv 					= nil -- 下级


-- 初始化
function init()
	Tag_Back 					= 90001 -- 返回
	Tag_Force 					= 90002 -- 强化
	_bgLayer 					= nil
	_item_id 					= nil
	_delegateAction 			= nil
	bgSprite					= nil
	_topBg 						= nil
	_silverLabel 				= nil
	_goldLabel 					= nil
	_equipInfo 					= nil -- 目标时装数据
	attrTable 					= nil -- 当前属性数据
	nextAttrTable 				= nil -- 下级属性数据
	nextLvCost 					= nil -- 下级消费数据
	haveNum 					= nil -- 拥有时装精华个数
	levelLabel 					= nil -- 当前等级数值label
	curLv 						= nil -- 当前等级数值
	coinLabel 					= nil -- 消耗银币label
	jingLabel_1 				= nil -- 消耗精华lable
	jingLabel_2 				= nil -- 拥有精华lable
	_isOnHero 					= false	-- 时装是在hero身上还是背包中	
	_cardSprite 				= nil -- 时装卡牌
	forceBtn					= nil -- 强化按钮
	_isCanEnhance 				= true -- 是否强化
	topHeight 					= nil -- 上边高度
	arrowSpTab 					= {} -- 箭头
	nextAttrLabTable 			= {} -- 下级属性label
	curAttrLabTable 			= {} -- 当前属性label
	_nCounterOfHeroLevel 		= 0 -- 特效变换计数器
	nextLv 						= nil -- 下级
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
        local vPosition = _bgLayer:convertToNodeSpace(touchBeganPoint)
        if ( vPosition.x >0 and vPosition.x <  _bgLayer:getContentSize().width and vPosition.y > 0 and vPosition.y <  _bgLayer:getContentSize().height ) then
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
		_bgLayer:registerScriptTouchHandler(onTouchesHandler, false, -150, true)
		_bgLayer:setTouchEnabled(true)
		MainScene.registerFashionEnhanceRemove(removeSelfLayer)
	elseif (event == "exit") then
		print("exit")
		_bgLayer:unregisterScriptTouchHandler()
		MainScene.registerFashionEnhanceRemove(nil)
	end
end

function removeSelfLayer( ... )
	if(_bgLayer)then
		_bgLayer:removeFromParentAndCleanup(true)
	end
end

-- 准备数据
function prepareData()
	_equipInfo = ItemUtil.getItemInfoByItemId(_item_id)

    if(_equipInfo == nil )then
    	_isOnHero  = true
        _equipInfo = ItemUtil.getFashionFromHeroByItemId(_item_id)
        if( not table.isEmpty(_equipInfo))then
			require "db/DB_Item_dress"
			_equipInfo.itemDesc = DB_Item_dress.getDataById(_equipInfo.item_template_id)
		end
    end   

	-- 获取强化最大等级
	_equipInfo.maxLv = FashionData.getMaxLvForEnhance(_equipInfo.item_template_id)

	-- 获得属性相关数值
	attrTable = FashionData.getAttrByItemData(_equipInfo,tonumber(_equipInfo.va_item_text.dressLevel))

	-- 下一级属性相关值
	if( tonumber(_equipInfo.va_item_text.dressLevel) < tonumber(_equipInfo.maxLv))then
		nextAttrTable = FashionData.getAttrByItemData(_equipInfo,tonumber(_equipInfo.va_item_text.dressLevel)+1)
	else
		nextAttrTable = {}
	end

	-- 下一级消耗
	if( tonumber(_equipInfo.va_item_text.dressLevel) < tonumber(_equipInfo.maxLv))then
		nextLvCost = FashionData.getNeedCondition(_equipInfo.item_template_id,tonumber(_equipInfo.va_item_text.dressLevel)+1)
	else
		nextLvCost = {}
	end

	-- 当前等级
	curLv = tonumber(_equipInfo.va_item_text.dressLevel) or 0

	-- 下一级
	nextLv = curLv + 1 
	if(nextLv > tonumber(_equipInfo.maxLv))then
		nextLv = nil
	end
end


-- 刷新界面
local function refreshUI(  )
	-- 等级数值
	if( nextLv )then
		levelLabel:setString("+" .. curLv)
	else
		levelLabel:stopAllActions()
		levelLabel:setString("+" .. curLv)
	end
	-- 当前属性值
	-- print("refreshUI attrTable ")
	-- print_t(attrTable)
	for k,v in pairs(curAttrLabTable) do
		v:setString("".. attrTable[k].displayNum)
	end

	-- 飘字提示
	local t_text = {}
	for k,v in pairs(curAttrLabTable) do
		local o_text = {}
        o_text.txt = attrTable[k].desc.displayName
		o_text.num = tonumber(attrTable[k].displayNum)
		table.insert(t_text, o_text)
	end
	require "script/utils/LevelUpUtil"
	LevelUpUtil.showFlyText(t_text)
	
	-- 下级属性
	if( nextLv )then
		for k,v in pairs(nextAttrLabTable) do
			v:setString("+" .. nextAttrTable[k].displayNum )
		end
	else
		for k,v in pairs(nextAttrLabTable) do
			v:stopAllActions()
			v:removeFromParentAndCleanup(true)
		end
	end

	-- 箭头
	if( nextLv == nil)then
		for k,v in pairs(arrowSpTab) do
			v:stopAllActions()
			v:removeFromParentAndCleanup(true)
		end
	end

	-- 下级消耗银币数
	local num = nextLvCost.coin or 0
	coinLabel:setString(string.formatBigNumber2(tonumber(num)))
	-- 下级消耗精华数
	local num = nextLvCost.num or 0
	jingLabel_1:setString(num)
	-- 剩余精华数值
	jingLabel_2:setString(haveNum)

	-- 刷新上边银币
	_silverLabel:setString(string.convertSilverUtilByInternational(UserModel.getSilverNumber()))  -- modified by yangrui at 2015-12-03
end 



-- 强化回调
function reinforceCallback( cbFlag, dictData, bRet )
	
	if(dictData.err == "ok")then
		require "script/audio/AudioUtil"
		AudioUtil.playEffect("audio/effect/qianghuachuizi.mp3")
		-- 修改本地数据
		-- 扣银币
		UserModel.addSilverNumber(-tonumber(nextLvCost.coin))
		-- 扣除消耗的精华数
		haveNum = haveNum - tonumber(nextLvCost.num)
		-- 强化后等级
		local level = tonumber(dictData.ret.va_item_text.dressLevel)
		if(_isOnHero)then
			HeroModel.addFashionLevelOnHerosBy(_equipInfo.hid, 1, level )
		else
			DataCache.setFashionLevelBy( _item_id, level )
		end

		-- 锤子动画
		hammerEffect()

	end
end

-- 强化 锤子动画
function hammerEffect()
	-- 锤子动画
		local spellEffectSprite = CCLayerSprite:layerSpriteWithName(CCString:create("images/base/effect/item/qianghuachuizi"), -1,CCString:create(""));
	    spellEffectSprite:retain()
	    spellEffectSprite:setPosition(_cardSprite:getContentSize().width*0.5,_cardSprite:getContentSize().height*0.5)
	    _cardSprite:addChild(spellEffectSprite,1);

	    -- 卡牌动画
	    local animationStart_2 = function ()
    	local spellEffectSprite_2 = CCLayerSprite:layerSpriteWithName(CCString:create("images/base/effect/hero/qianghua"), -1,CCString:create(""));
	    spellEffectSprite_2:retain()
	    spellEffectSprite_2:setPosition(_cardSprite:getContentSize().width*0.5, _cardSprite:getContentSize().height*0.5)
	    _cardSprite:addChild(spellEffectSprite_2,1);
	    enhanceResultEffect(1)

	    local animation_2_End = function(actionName,xmlSprite)
	    	-- 结束 刷新操作
		    prepareData()
		    -- 刷新ui
			refreshUI()
	        spellEffectSprite_2:removeFromParentAndCleanup(true)
	        _isCanEnhance = true
	        spellEffectSprite_2:release()
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
        spellEffectSprite:removeFromParentAndCleanup(true)
        spellEffectSprite:release()
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
    spellEffectSprite_2:retain()
    spellEffectSprite_2:setPosition(_cardSprite:getContentSize().width*0.5, _cardSprite:getContentSize().height*0.5)

    -- 替换强化等级
    local replaceXmlSprite = tolua.cast( spellEffectSprite_2:getChildByTag(1006) , "CCXMLSprite")
    replaceXmlSprite:setReplaceFileName(CCString:create("images/common/" .. addLv .. ".png"))

    local animation_2_End = function(actionName,xmlSprite)
        spellEffectSprite_2:removeFromParentAndCleanup(true)
        spellEffectSprite_2:release()
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
end


-- 按钮回调
function menuAction( tag, itemBtn )
	if(tag == Tag_Back)then
		if(_delegateAction) then
			print(GetLocalizeStringBy("key_2324"))
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
		require "script/audio/AudioUtil"
		AudioUtil.playEffect("audio/effect/zhujiemian.mp3")
		if( curLv >= _equipInfo.maxLv)then
			AnimationTip.showTip(GetLocalizeStringBy("key_2095"))
		elseif(UserModel.getHeroLevel() < tonumber(nextLvCost.heroLv))then 
			AnimationTip.showTip(GetLocalizeStringBy("key_2263") .. nextLvCost.heroLv .. GetLocalizeStringBy("key_2469") )
		elseif(tonumber(nextLvCost.coin) > UserModel.getSilverNumber()) then
			AnimationTip.showTip(GetLocalizeStringBy("key_1114"))
		elseif(tonumber(nextLvCost.num) > haveNum) then
			AnimationTip.showTip(GetLocalizeStringBy("key_2810"))
		elseif(_isCanEnhance == true) then
			_isCanEnhance = false
			local args = Network.argsHandler(_item_id)
			RequestCenter.forge_upgradeFashion(reinforceCallback,args )
		else
		end
	else

	end
end

-- 更新GetLocalizeStringBy("key_1734")字符串
function fnRenewLevelString(obj)
	local sLevel = curLv
	if _nCounterOfHeroLevel % 2 == 0 then
		sLevel = nextLv
	end
	levelLabel:setString( "+" .. sLevel)
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

--  上标题栏 显示战斗力，银币，金币
function createTopUI()
	-- 公告栏大小
	require "script/ui/main/BulletinLayer"
    local upHeight = BulletinLayer.getLayerContentSize().height

	_topBg = CCSprite:create("images/hero/avatar_attr_bg.png")
    _topBg:setAnchorPoint(ccp(0.5,1))
    print("_bgLayer",_bgLayer:getContentSize().height-upHeight)
    _topBg:setPosition(_bgLayer:getContentSize().width*0.5,_bgLayer:getContentSize().height-upHeight*g_fScaleX)
    _bgLayer:addChild(_topBg, 10)
    _topBg:setScale(g_fScaleX)

    -- 上边部分高度
    topHeight = (upHeight + _topBg:getContentSize().height)*g_fScaleX

	local nameLabel= CCLabelTTF:create(UserModel.getUserName(), g_sFontName, 23)
    nameLabel:setPosition(_topBg:getContentSize().width*0.18, _topBg:getContentSize().height*0.43)
    nameLabel:setAnchorPoint(ccp(0,0.5))
    nameLabel:setColor(ccc3(0x70,0xff,0x18))
    _topBg:addChild(nameLabel)

    local vipSp = CCSprite:create ("images/common/vip.png")
	vipSp:setPosition(_topBg:getContentSize().width*0.372, _topBg:getContentSize().height*0.43)
	vipSp:setAnchorPoint(ccp(0,0.5))
	_topBg:addChild(vipSp)

    -- VIP对应级别
    require "script/libs/LuaCC"
    local vipNumSp = LuaCC.createSpriteOfNumbers("images/main/vip", UserModel.getVipLevel() , 23)
    vipNumSp:setPosition(_topBg:getContentSize().width*0.382+vipSp:getContentSize().width, _topBg:getContentSize().height*0.43)
    vipNumSp:setAnchorPoint(ccp(0,0.5))
    _topBg:addChild(vipNumSp)

	_silverLabel = CCLabelTTF:create(string.convertSilverUtilByInternational(UserModel.getSilverNumber()),g_sFontName,18)  -- modified by yangrui at 2015-12-03
    _silverLabel:setColor(ccc3(0xe5,0xf9,0xff))
    _silverLabel:setAnchorPoint(ccp(0,0.5))
    _silverLabel:setPosition(_topBg:getContentSize().width*0.61,_topBg:getContentSize().height*0.43)
    _topBg:addChild(_silverLabel)
    
    _goldLabel = CCLabelTTF:create( UserModel.getGoldNumber(),g_sFontName,18)
    _goldLabel:setColor(ccc3(0xff,0xe2,0x44))
    _goldLabel:setAnchorPoint(ccp(0,0.5))
    _goldLabel:setPosition(_topBg:getContentSize().width*0.82,_topBg:getContentSize().height*0.43)
    _topBg:addChild(_goldLabel)
end

-- 初始化
function initLayer()
	-- 背景
	local fullRect = CCRectMake(0,0,196, 198)
	local insetRect = CCRectMake(50,50,96,98)
	bgSprite = CCScale9Sprite:create("images/item/equipinfo/bg_9s.png", fullRect, insetRect) 
	local bgSpriteHeight = _bgLayer:getContentSize().height-topHeight+MenuLayer.getHeight()
	bgSprite:setContentSize(CCSizeMake(_bgLayer:getContentSize().width/g_fScaleX,bgSpriteHeight/g_fScaleX))
	bgSprite:setAnchorPoint(ccp(0.5, 0))
	bgSprite:setPosition(ccp(_bgLayer:getContentSize().width*0.5, -MenuLayer.getHeight()))
	_bgLayer:addChild(bgSprite)
	bgSprite:setScale(g_fScaleX)
	-- 顶部
	local topSprite = CCSprite:create("images/item/equipinfo/topbg.png")
	topSprite:setAnchorPoint(ccp(0.5, 1))
	topSprite:setPosition(ccp(_bgLayer:getContentSize().width*0.5, _bgLayer:getContentSize().height-topHeight))
	_bgLayer:addChild(topSprite, 10)
	topSprite:setScale(g_fScaleX)
	-- 标题
	local titleLabel = CCLabelTTF:create(GetLocalizeStringBy("key_1604"), g_sFontPangWa, 35)
    titleLabel:setColor(ccc3(0xff, 0xe4, 0x00))
    titleLabel:setAnchorPoint(ccp(0.5,1))
    titleLabel:setPosition(ccp(topSprite:getContentSize().width*0.5, topSprite:getContentSize().height*0.9))
    topSprite:addChild(titleLabel)

	-- 卡牌
	_cardSprite = FashionInfo.getFashionBigCard(_equipInfo.item_template_id)
	_cardSprite:setAnchorPoint(ccp(0.5, 0.5))
	-- local posY = topSprite:getPositionY()-topSprite:getContentSize().height*g_fScaleX-25*g_fScaleX
	_cardSprite:setPosition(ccp(_bgLayer:getContentSize().width*0.26, _bgLayer:getContentSize().height*0.54))
	_bgLayer:addChild(_cardSprite)
	_cardSprite:setScale(MainScene.elementScale)
	-- _cardSprite:setScale(_cardSprite:getScale()*g_fScaleX)

----------------------------- 强化信息 --------------------------
	-- 强化背景
	local fullRect = CCRectMake(0,0,75, 75)
	local insetRect = CCRectMake(30,40,10,15)
	local infoSpriteSp = CCScale9Sprite:create("images/common/bg/attr_bg.png", fullRect, insetRect)
	infoSpriteSp:setPreferredSize(CCSizeMake(273, 431)) 
	infoSpriteSp:setAnchorPoint(ccp(0.5, 0.5))
	-- local posY = topSprite:getPositionY()-topSprite:getContentSize().height*g_fScaleX-30*g_fScaleX
	infoSpriteSp:setPosition(ccp(_bgLayer:getContentSize().width*0.75,  _bgLayer:getContentSize().height*0.54))
	_bgLayer:addChild(infoSpriteSp)
	-- infoSpriteSp:setScale(g_fScaleX)
	infoSpriteSp:setScale(MainScene.elementScale)

	-- 强化标题
	local forceLabelTitle = CCLabelTTF:create(GetLocalizeStringBy("key_1940"), g_sFontName, 35)
	forceLabelTitle:setColor(ccc3(0x78, 0x25, 0x00))
	forceLabelTitle:setAnchorPoint(ccp(0.5, 1))
	forceLabelTitle:setPosition(ccp(infoSpriteSp:getContentSize().width*0.5, infoSpriteSp:getContentSize().height*0.98))
	infoSpriteSp:addChild(forceLabelTitle)

	local fullRect_attr = CCRectMake(0,0,61,47)
	local insetRect_attr = CCRectMake(10,10,41,27)
	-- 属性背景
	local attrBg = CCScale9Sprite:create("images/copy/fort/textbg.png", fullRect_attr, insetRect_attr)
	attrBg:setPreferredSize(CCSizeMake(256, 372))
	attrBg:setAnchorPoint(ccp(0.5, 1))
	attrBg:setPosition(ccp(infoSpriteSp:getContentSize().width*0.5, infoSpriteSp:getContentSize().height*0.88))
	infoSpriteSp:addChild(attrBg)

--------------------------------------- 已经强化的数值 ---------------------------
	-- -- 名称
	local nameColor = HeroPublicLua.getCCColorByStarLevel(_equipInfo.itemDesc.quality)
	local nameStr = FashionLayer.getIconPath(_equipInfo.item_template_id, "name")
	local nameLabel = CCRenderLabel:create(nameStr,g_sFontPangWa, 25, 1, ccc3( 0x00, 0x00, 0x00), type_stroke)
	nameLabel:setColor(nameColor)
	nameLabel:setAnchorPoint(ccp(0.5, 0.5))
	nameLabel:setPosition(ccp(attrBg:getContentSize().width*0.4, attrBg:getContentSize().height*0.9))
	attrBg:addChild(nameLabel)

	-- 等级数值
	levelLabel = CCLabelTTF:create("+" .. _equipInfo.va_item_text.dressLevel, g_sFontPangWa, 25)
	levelLabel:setColor(ccc3(0x00, 0x8d, 0x3d))
	levelLabel:setAnchorPoint(ccp(0, 0.5))
	levelLabel:setPosition(ccp(attrBg:getContentSize().width*172/256, attrBg:getContentSize().height*0.9))
	attrBg:addChild(levelLabel)

	if( nextLv )then
		local action = actionOfLevel()
		levelLabel:runAction(action)
	end

	-- 当前属性
	local curAttrFont = CCLabelTTF:create(GetLocalizeStringBy("key_1293"), g_sFontName, 23)
	curAttrFont:setColor(ccc3(0x00, 0x8d, 0x3d))
	curAttrFont:setAnchorPoint(ccp(0, 0))
	curAttrFont:setPosition(ccp(12,  attrBg:getContentSize().height*0.76))
	attrBg:addChild(curAttrFont)
	-- 横线
	-- 分割线
	local lineSprite = CCScale9Sprite:create("images/item/equipinfo/line.png")
	lineSprite:setContentSize(CCSizeMake(223,4))
	lineSprite:setAnchorPoint(ccp(0, 0))
	lineSprite:setPosition(ccp(0, attrBg:getContentSize().height*0.75))
	attrBg:addChild(lineSprite)

	-- 属性1
	print("==>")
	print_t(attrTable)
	local i = 0
	for k,v in pairs(attrTable) do
		i = i + 1
		local attrLabel_1 = CCLabelTTF:create("" .. v.desc.displayName .. "：+", g_sFontName, 21)
		attrLabel_1:setColor(ccc3(0x78, 0x25, 0x00))
		attrLabel_1:setAnchorPoint(ccp(0, 0))
		attrLabel_1:setPosition(ccp(16,236-(attrLabel_1:getContentSize().height+10)*(tonumber(i-1))))
		attrBg:addChild(attrLabel_1)
		-- 当前值
		local attrLabel_num_1 = CCLabelTTF:create( v.displayNum, g_sFontName, 21)
		attrLabel_num_1:setColor(ccc3(0x00, 0x00, 0x00))
		attrLabel_num_1:setAnchorPoint(ccp(0, 0))
		attrLabel_num_1:setPosition(ccp(attrLabel_1:getPositionX()+attrLabel_1:getContentSize().width,236-(attrLabel_1:getContentSize().height+10)*(tonumber(i-1))))
		attrBg:addChild(attrLabel_num_1)
		-- 保存
		curAttrLabTable[k] = attrLabel_num_1

		-- 强化后值
		if(nextAttrTable[k])then 
			-- 箭头
			local arrowSp = CCSprite:create("images/item/equipinfo/reinforce/arrow.png")
			arrowSp:setAnchorPoint(ccp(0, 0))
			arrowSp:setPosition(ccp(attrBg:getContentSize().width*0.6, 236-(attrLabel_1:getContentSize().height+10)*(tonumber(i-1))))
			attrBg:addChild(arrowSp)
			-- 保存
			arrowSpTab[k] = arrowSp

			local attrLabel_num_1_e = CCLabelTTF:create("+" ..  nextAttrTable[k].displayNum, g_sFontName, 21)
			attrLabel_num_1_e:setColor(ccc3(0x00, 0x8d, 0x3d))
			attrLabel_num_1_e:setAnchorPoint(ccp(0, 0))
			attrLabel_num_1_e:setPosition(ccp(arrowSp:getPositionX()+arrowSp:getContentSize().width+5, 236-(attrLabel_1:getContentSize().height+10)*(tonumber(i-1))))
			attrBg:addChild(attrLabel_num_1_e)
			-- 保存
			nextAttrLabTable[k] = attrLabel_num_1_e
		end
	end

	if(nextLv)then
		-- 闪一闪特效
		for k,v in pairs(arrowSpTab) do
			local arrActions_1 = CCArray:create()
			arrActions_1:addObject(CCFadeIn:create(1.0))
			arrActions_1:addObject(CCFadeOut:create(1.0))
			local sequence_1 = CCSequence:create(arrActions_1)
			local action_1 = CCRepeatForever:create(sequence_1)
			v:stopAllActions()
			v:runAction(action_1)
		end
		for k,v in pairs(nextAttrLabTable) do
			local arrActions_1 = CCArray:create()
			arrActions_1:addObject(CCFadeIn:create(1.0))
			arrActions_1:addObject(CCFadeOut:create(1.0))
			local sequence_1 = CCSequence:create(arrActions_1)
			local action_1 = CCRepeatForever:create(sequence_1)
			v:stopAllActions()
			v:runAction(action_1)
		end
	end

----------------------------------------- 消耗物品 -------------------------------------------------------------
	local fullRect_attr = CCRectMake(0,0,61,47)
	local insetRect_attr = CCRectMake(10,10,41,27)
	-- 属性背景
	local costBg = CCScale9Sprite:create("images/copy/fort/textbg.png", fullRect_attr, insetRect_attr)
	costBg:setPreferredSize(CCSizeMake(584, 126))
	costBg:setAnchorPoint(ccp(0.5, 0.5))
	-- local posY = infoSpriteSp:getPositionY()-infoSpriteSp:getContentSize().height*g_fScaleX-20*g_fScaleX
	costBg:setPosition(ccp(_bgLayer:getContentSize().width*0.5, _bgLayer:getContentSize().height*0.19))
	_bgLayer:addChild(costBg)
	costBg:setScale(g_fScaleX)

	-- 银币
	local coinTitleLabel = CCLabelTTF:create(GetLocalizeStringBy("key_2434"), g_sFontName, 23)
	coinTitleLabel:setColor(ccc3(0x78, 0x25, 0x00))
	coinTitleLabel:setAnchorPoint(ccp(0, 0.5))
	coinTitleLabel:setPosition(ccp(155,88))
	costBg:addChild(coinTitleLabel)

	-- 银币图标
	local coinSp = CCSprite:create("images/common/coin.png")
	coinSp:setAnchorPoint(ccp(0, 0.5))
	coinSp:setPosition(ccp( coinTitleLabel:getPositionX()+coinTitleLabel:getContentSize().width+1, 88))
	costBg:addChild(coinSp)

	-- 消耗银币数值
	local num = nextLvCost.coin or 0
	coinLabel = CCLabelTTF:create(string.formatBigNumber2(tonumber(num)), g_sFontName, 23)
	coinLabel:setColor(ccc3(0x00, 0x00, 0x00))
	coinLabel:setAnchorPoint(ccp(0, 0.5))
	coinLabel:setPosition(ccp(coinSp:getPositionX()+coinSp:getContentSize().width+2, 88))
	costBg:addChild(coinLabel)

	-- 精华图标
	local jingSp_1 = CCSprite:create("images/common/fashion_en.png")
	jingSp_1:setAnchorPoint(ccp(0, 0.5))
	jingSp_1:setPosition(ccp( coinLabel:getPositionX()+coinLabel:getContentSize().width+10, 88))
	costBg:addChild(jingSp_1)

	-- 消耗精华数值
	local num = nextLvCost.num or 0
	jingLabel_1 = CCLabelTTF:create(num, g_sFontName, 23)
	jingLabel_1:setColor(ccc3(0x00, 0x00, 0x00))
	jingLabel_1:setAnchorPoint(ccp(0, 0.5))
	jingLabel_1:setPosition(ccp(jingSp_1:getPositionX()+jingSp_1:getContentSize().width+2, 88))
	costBg:addChild(jingLabel_1)

	-- 剩余
	local titleLabel_2 = CCLabelTTF:create(GetLocalizeStringBy("key_1569"), g_sFontName, 23)
	titleLabel_2:setColor(ccc3(0x78, 0x25, 0x00))
	titleLabel_2:setAnchorPoint(ccp(0, 0.5))
	titleLabel_2:setPosition(ccp(155,28))
	costBg:addChild(titleLabel_2)
	-- 精华图标
	local jingSp_2 = CCSprite:create("images/common/fashion_en.png")
	jingSp_2:setAnchorPoint(ccp(0, 0.5))
	jingSp_2:setPosition(ccp(titleLabel_2:getPositionX()+titleLabel_2:getContentSize().width+1, 28))
	costBg:addChild(jingSp_2)
	-- 剩余精华数值
	jingLabel_2 = CCLabelTTF:create(haveNum, g_sFontName, 23)
	jingLabel_2:setColor(ccc3(0x00, 0x8d, 0x3d))
	jingLabel_2:setAnchorPoint(ccp(0, 0.5))
	jingLabel_2:setPosition(ccp(jingSp_2:getPositionX()+jingSp_2:getContentSize().width+2, 28))
	costBg:addChild(jingLabel_2)

--------------------------------- 操作按钮 --------------------------
	-- 按钮Bar
	local btnMenuBar = CCMenu:create()
	btnMenuBar:setPosition(ccp(0, 0))
	_bgLayer:addChild(btnMenuBar)
	btnMenuBar:setTouchPriority(-151)
	-- 返回
	local backBtn = LuaCC.create9ScaleMenuItem("images/common/btn/btn1_d.png","images/common/btn/btn1_n.png",CCSizeMake(210,73),GetLocalizeStringBy("key_2661"),ccc3(255,222,0))
	backBtn:setAnchorPoint(ccp(0.5, 0))
	-- local posY = costBg:getPositionY()-costBg:getContentSize().height*g_fScaleX-10*g_fScaleX
    backBtn:setPosition(ccp(_bgLayer:getContentSize().width*0.3,10*g_fScaleX))
    backBtn:registerScriptTapHandler(menuAction)
	btnMenuBar:addChild(backBtn, 2, Tag_Back)
	backBtn:setScale(g_fScaleX)

	-- 强化
	forceBtn = LuaCC.create9ScaleMenuItem("images/common/btn/btn1_d.png","images/common/btn/btn1_n.png",CCSizeMake(210,73),GetLocalizeStringBy("key_3391"),ccc3(255,222,0))
	forceBtn:setAnchorPoint(ccp(0.5, 0))
	-- local posY = costBg:getPositionY()-costBg:getContentSize().height*g_fScaleX-10*g_fScaleX
    forceBtn:setPosition(ccp(_bgLayer:getContentSize().width*0.7,10*g_fScaleX))
    forceBtn:registerScriptTapHandler(menuAction)
	btnMenuBar:addChild(forceBtn, 2, Tag_Force)
	forceBtn:setScale(g_fScaleX)
end


-- 创建
function createLayer( item_id, delegateAction, isNeedHidden)
	init()
	_delegateAction = delegateAction
	_item_id = item_id
	prepareData()
	if(isNeedHidden == nil)then
		_isNeedHidden = false
	else
		_isNeedHidden = isNeedHidden
	end
	_bgLayer = CCLayer:create()
	_bgLayer:setContentSize(CCSizeMake(_bgLayer:getContentSize().width,_bgLayer:getContentSize().height-MenuLayer.getHeight()))
	-- _bgLayer:setScale(1/MainScene.elementScale)
	_bgLayer:registerScriptHandler(onNodeEvent)
	MainScene.setMainSceneViewsVisible(true, false, true)
	local bigBg = CCSprite:create("images/main/module_bg.png")
	bigBg:setAnchorPoint(ccp(0.5,0.5))
	bigBg:setPosition(ccp(_bgLayer:getContentSize().width*0.5,_bgLayer:getContentSize().height*0.5))
	_bgLayer:addChild(bigBg)

	print("_equipInfo ==>") 
	print_t(_equipInfo)
	-- 拥有时装精华的个数
	local data = FashionData.getNeedCondition(_equipInfo.item_template_id,1)
	haveNum = ItemUtil.getCacheItemNumBy(data.id)

	-- 创建上部ui
	createTopUI()
	
	-- 初始化
	initLayer()

	_bgLayer:setPosition(ccp(0,MenuLayer.getHeight()))
	
	return _bgLayer
end

