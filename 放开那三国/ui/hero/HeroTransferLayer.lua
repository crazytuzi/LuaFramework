-- Filename: HeroTransferLayer.lua
-- Author: fang
-- Date: 2013-08-05
-- Purpose: 该文件用于: 武将系统，进阶系统

module("HeroTransferLayer", package.seeall)

require "script/ui/godweapon/godweaponcopy/GodWeaponCopyData"

m_sign="HeroTransferLayer"
-- 当前英雄属性结构
local _tHeroAttr
-- 进阶后的英雄属性
local _tHeroTransferedAttr

-- 卡牌角色展示背景图片的
local _fHeroShowScale = 370/443


local _tSizeOfQuality={width=301, height=443}
local _tSizeOfExpected={width=160, height=235}
local _fScaleCard=_tSizeOfExpected.width/_tSizeOfQuality.width
-- “开始进阶”按钮
local _ccBtnBeginTransfer

-- 武将进化网络标识
local _sNetworkFlagOfHeroEvolve

-- 来自父级界面的参数结构
local _tParentParam

-- 进阶需要的物品数组
local _arrNeedItems

-- 进阶需要的物品或卡牌类型
local _ksTypeOfItem=101
local _ksTypeOfCard=102

-- 消耗银币显示标签对象数组
local _arrSilverInfoObjs

-- 卡牌和物品显示内容tableview
local _ctvCardItem

-- 该面板主layer
local _clTransfer

-- 左面板属性值数组
local _aLeftAttrValueObjs

local _debug_level=1

-- 进阶前等级、战斗力相关数值
local _tForceValues01
-- 进阶后等级、战斗力相关数值
local _tForceValues02
-- 解锁的天赋
local _aUnlockedTalentDesc

-- 进阶所需物品种类标识
local _nItemTypeProps = 10
local _nItemTypeTreas = 11
local _nItemTypeArms = 1


-- 网络事件处理
local function fnHandlerOfNetwork(cbFlag, dictData, bRet)
	if not bRet then
		require "script/ui/tip/AnimationTip"
		AnimationTip.showTip(GetLocalizeStringBy("key_2046"))
		return
	end 
	-- 武将卡牌强化
	if cbFlag == _sNetworkFlagOfHeroEvolve then
	-- 进阶成功后处理
		local tRet = dictData.ret
		require "script/model/user/UserModel"
		-- 减去消耗的银币数目
		UserModel.addSilverNumber(-tonumber(tRet.silver))
		-- 减去消耗的武将数组
		local length = 0
		if tRet.hero then
			length = #tRet.hero
		end
		require "script/model/hero/HeroModel"
		for i=1, length do
			HeroModel.deleteHeroByHid(tRet.hero[i])
		end
		-- 清理物品显示内容
		if _ctvCardItem then
			_ctvCardItem:removeFromParentAndCleanup(true)
			_ctvCardItem=nil
		end
		-- 修改武将进阶次数
		HeroModel.addEvolveLevelByHid(_tHeroAttr.hid, 1)
		-- 如果是主角则需要改UserModel信息
		if HeroModel.isNecessaryHero(_tHeroAttr.htid) then
			UserModel.getUserInfo().htid = _tHeroTransferedAttr.new_htid
		end
		-- 修改武将进阶后的模板id
		HeroModel.setHtidByHid(_tHeroAttr.hid, _tHeroTransferedAttr.new_htid)
		_tHeroAttr.htid = _tHeroTransferedAttr.new_htid
		-- 清理需要银币信息
		fnUpdateSilverCostUI(0)
		-- 清空左面板
		fnCleanAfterTransfer()
		fnCreateZhuanChangEffect(_clTransfer)

		--清除武将变身信息
		require "script/ui/rechargeActive/ActiveCache"
		ActiveCache.setUserTransfer(_tHeroAttr.hid)
		-- added by zhz ,台湾炫耀系统
		-- require "script/ui/showOff/ShowOffUtil"
		-- ShowOffUtil.sendShowOffByType( 6, tonumber(_tHeroAttr.htid))
	end
end  

-- “选择武将”回调
local  function fnHandlerOfButtonSelectHero(tag, obj)
	require "script/ui/hero/HeroSelectLayer"
	require "script/ui/main/MainScene"

	local tArgsOfModule = {withoutExp=true, isSingle=true}
	tArgsOfModule.sign="HeroTransferLayer"
	tArgsOfModule.fnCreate=createLayer
	tArgsOfModule.selected = {tostring(_tHeroAttr.hid), }

	tArgsOfModule.reserved = {}
	tArgsOfModule.reserved.fnCreate = _tParentParam.fnCreate
	tArgsOfModule.reserved.sign = _tParentParam.sign
	MainScene.changeLayer(HeroSelectLayer.createLayer(tArgsOfModule), "HeroSelectLayer")
end 

-- 创建进阶特效
function fnCreateTransferEffect(pForceValues01, pForceValues02, pHeroAttr)
	local runningScene = CCDirector:sharedDirector():getRunningScene()
	if runningScene == nil then
        runningScene = CCScene:create()
        CCDirector:sharedDirector():runWithScene(runningScene)
    end
	local colorLayer = CCLayerColor:create(ccc4(0, 0, 0, 255))
	colorLayer:setTouchEnabled(true)
	colorLayer:setTouchPriority(-32767)
	local function fnHandlerOfTouch(event, x, y)
		if event == "ended" then
			colorLayer:removeFromParentAndCleanup(true)
			colorLayer = nil
			addGenralGuideForOverTrs()
			-- 停止英雄音效
			require "script/utils/SoundEffectUtil"
			SoundEffectUtil.stopHeroAudio()

			local heroInfo = HeroModel.getHeroByHid(_tHeroAttr.hid)
			local heroAttr = {}
			table.hcopy(_tHeroAttr, heroAttr)
			heroAttr.evolve_level = heroInfo.evolve_level
			heroAttr.htid = heroInfo.htid
			_tParentParam.selectedHeroes = {heroAttr}
	   	 	MainScene.changeLayer(HeroTransferLayer.createLayer(_tParentParam), "HeroTransferLayer")
		end
		return true
	end
	colorLayer:registerScriptTouchHandler(fnHandlerOfTouch, false, -32767, true)
	-- 等级、生命、物攻、法攻、物防、法防
	local nUnlockHeight = 80
	local nHeightOfAttrBg = 350*g_fScaleY
	local cs9Attr = CCScale9Sprite:create("images/hero/transfer/level_up/bg_ng_attr.png", CCRectMake(0, 0, 209, 49), CCRectMake(86, 14, 45, 20))
	cs9Attr:setPreferredSize(CCSizeMake(g_winSize.height, nHeightOfAttrBg))
	cs9Attr:setPosition(0, 4)
	--	cs9Attr:setScale(g_fScaleX)
	colorLayer:addChild(cs9Attr, 10, 1000)

	local nHeightOfUnit = nHeightOfAttrBg/5
	local pics = {"magic_defend", "physical_defend", "attack", "life", "level"}
	local values = {
		{pForceValues01.magicDefend, pForceValues02.magicDefend},
		{pForceValues01.physicalDefend, pForceValues02.physicalDefend},
		{pForceValues01.generalAttack, pForceValues02.generalAttack},
		{pForceValues01.life, pForceValues02.life},
		{pForceValues01.level, pForceValues01.level},
	}
	local addedValues = {
		tonumber(pForceValues02.magicDefend) - tonumber(pForceValues01.magicDefend),
		tonumber(pForceValues02.physicalDefend) - tonumber(pForceValues01.physicalDefend),
		tonumber(pForceValues02.generalAttack) - tonumber(pForceValues01.generalAttack),
		tonumber(pForceValues02.life) - tonumber(pForceValues01.life),
		10,
	}
	local y=nHeightOfUnit/2

	for i=1, #pics do
		local csAttrName=CCSprite:create("images/hero/transfer/level_up/"..pics[i]..".png")
		csAttrName:setScale(g_fElementScaleRatio)
		csAttrName:setAnchorPoint(ccp(0, 0.5))
		csAttrName:setPosition(0.117*g_winSize.width, y)
		cs9Attr:addChild(csAttrName, 1001, 1001)

		local csAttrValue01 = CCLabelTTF:create(values[i][1], g_sFontName, 35)
		csAttrValue01:setScale(g_fElementScaleRatio)
		csAttrValue01:setColor(ccc3(255, 0x6c, 0))
		csAttrValue01:setPosition(0.297*g_winSize.width, y)
		csAttrValue01:setAnchorPoint(ccp(0, 0.5))
		cs9Attr:addChild(csAttrValue01, 1001, 1002)
		-- 箭头特效
		local sImgPathArrow=CCString:create("images/base/effect/hero/transfer/jiantou")
		local clsEffectArrow=CCLayerSprite:layerSpriteWithNameAndCount(sImgPathArrow:getCString(), -1, CCString:create(""))
		clsEffectArrow:setScale(g_fElementScaleRatio)
		clsEffectArrow:setAnchorPoint(ccp(0, 0.5))
		clsEffectArrow:setPosition(0.578*g_winSize.width, y)
		cs9Attr:addChild(clsEffectArrow, 1001, 1003)

		local csAttrValue02 = CCLabelTTF:create(values[i][2], g_sFontName, 35)
		csAttrValue02:setScale(g_fElementScaleRatio)
		csAttrValue02:setPosition(0.7*g_winSize.width, y)
		csAttrValue02:setColor(ccc3(0x67, 0xf9, 0))
		csAttrValue02:setAnchorPoint(ccp(0, 0.5))
		cs9Attr:addChild(csAttrValue02, 1001, 1004)

		if addedValues[i] > 0 then
			local csArrowGreen = CCSprite:create("images/hero/transfer/arrow_green.png")
			csArrowGreen:setScale(g_fElementScaleRatio)
			csArrowGreen:setPosition(0.85*g_winSize.width, y)
			csArrowGreen:setAnchorPoint(ccp(0, 0.5))
			cs9Attr:addChild(csArrowGreen, 1001, 1005)
		end

		y = y + nHeightOfUnit
	end
	-- 转光特效
	local sImgPath=CCString:create("images/base/effect/hero/transfer/zhuanguang")
	local clsEffectZhuanGuang=CCLayerSprite:layerSpriteWithNameAndCount(sImgPath:getCString(), -1, CCString:create(""))
	clsEffectZhuanGuang:setPosition(g_winSize.width/2, 740*g_fScaleY)
	clsEffectZhuanGuang:setScale(g_fElementScaleRatio)
	colorLayer:addChild(clsEffectZhuanGuang, 11, 100)
	clsEffectZhuanGuang:setVisible(false)
	
	-- 进阶成功特效
	local sImgPathSuccess=CCString:create("images/base/effect/hero/transfer/jinjiechenggong")
	local clsEffectSuccess=CCLayerSprite:layerSpriteWithNameAndCount(sImgPathSuccess:getCString(), -1, CCString:create(""))
	clsEffectSuccess:setAnchorPoint(ccp(0.5, 0.5))
	clsEffectSuccess:setScale(g_fElementScaleRatio)
	clsEffectSuccess:setPosition(g_winSize.width/2, 490*g_fScaleY)
	colorLayer:addChild(clsEffectSuccess, 999, 999)
	local ccDelegateSuccess=BTAnimationEventDelegate:create()
	ccDelegateSuccess:registerLayerEndedHandler(function (actionName, xmlSprite)
		clsEffectSuccess:cleanup()
	end)
	ccDelegateSuccess:registerLayerChangedHandler(function (index, xmlSprite)

	end)
	clsEffectSuccess:setDelegate(ccDelegateSuccess)
	if pHeroAttr ~= nil then
		_tHeroTransferedAttr = pHeroAttr
	end

	if _tHeroTransferedAttr then
		require "script/ui/hero/HeroPublicCC"
		local csCardShow = HeroPublicCC.createSpriteCardShow(_tHeroTransferedAttr.new_htid, nil, _tHeroTransferedAttr.turned_id)
		csCardShow:setAnchorPoint(ccp(0.5, 0.5))
		csCardShow:setScale(g_fElementScaleRatio)
		csCardShow:setPosition(g_winSize.width/2, 740*g_fScaleY)
		colorLayer:addChild(csCardShow, 999, 999)
		csCardShow:setScale(1.5*g_fElementScaleRatio)
		local sequence = CCSequence:createWithTwoActions(CCScaleTo:create(0.3, 0.8*g_fElementScaleRatio),
			CCCallFunc:create(function ( ... )
				clsEffectZhuanGuang:setVisible(true)
				require "script/audio/AudioUtil"
				AudioUtil.playEffect("audio/effect/zhuanguang.mp3")
			end))
		csCardShow:runAction(sequence)
	end
	require "script/audio/AudioUtil"
	AudioUtil.playEffect("audio/effect/zhuanshengchenggong.mp3")
	local cnTalentUnlock = CCNode:create()
	-- 天赋解锁显示区
	local csTalentUnlock = CCSprite:create("images/hero/transfer/level_up/unlock.png")
	cnTalentUnlock:addChild(csTalentUnlock)

	local desc = ""
	if #_aUnlockedTalentDesc > 0 then
		desc = table.concat(_aUnlockedTalentDesc, ",")
	else
		desc = GetLocalizeStringBy("key_1554")
	end

	local clTalentUnlockDesc = CCLabelTTF:create(desc, g_sFontName, 32)
	clTalentUnlockDesc:setColor(ccc3(255, 0xf6, 0))
	local tNodeSize = csTalentUnlock:getContentSize()
	clTalentUnlockDesc:setPosition(tNodeSize.width + 10, 10*g_fScaleY+cs9Attr:getContentSize().height * cs9Attr:getScaleY())
	csTalentUnlock:setPosition(csTalentUnlock:getPositionX(), 10*g_fScaleY+cs9Attr:getContentSize().height * cs9Attr:getScaleY())
	cnTalentUnlock:addChild(clTalentUnlockDesc)
	tNodeSize.width = tNodeSize.width + 10 + clTalentUnlockDesc:getContentSize().width
	cnTalentUnlock:setScale(g_fElementScaleRatio)
	cnTalentUnlock:setPosition(g_winSize.width/2, 50)
	cnTalentUnlock:setAnchorPoint(ccp(0.5, 0.5))
	cnTalentUnlock:setContentSize(CCSizeMake(tNodeSize.width, tNodeSize.height))
	clTalentUnlockDesc:setVisible(false)
	colorLayer:addChild(cnTalentUnlock)


	if #_aUnlockedTalentDesc > 0 then
		local function playBaoEffect( ... )
			if(colorLayer == nil) then
				return
			end
			local sImgPathArrow=CCString:create("images/hero/transfer/tianfujiesuobaolizi/tianfujiesuobaolizi")
			local unLockEffect=CCLayerSprite:layerSpriteWithNameAndCount(sImgPathArrow:getCString(), 1, CCString:create(""))
	        unLockEffect:setAnchorPoint(ccp(0.5, 0.5));
	        unLockEffect:setPosition(clTalentUnlockDesc:getPositionX() + clTalentUnlockDesc:getContentSize().width * 0.5, clTalentUnlockDesc:getPositionY() + clTalentUnlockDesc:getContentSize().height * 0.5)
	        clTalentUnlockDesc:getParent():addChild(unLockEffect,99999);

	        local effectDelegate = BTAnimationEventDelegate:create()
	        effectDelegate:registerLayerEndedHandler(function ( eventType,layerSprite )
				clTalentUnlockDesc:setVisible(true)
	        end)
	        unLockEffect:setDelegate(effectDelegate)
    	end
		local array = CCArray:create()
		array:addObject(CCDelayTime:create(0.8))
		array:addObject(CCCallFunc:create(playBaoEffect))
		local seq 	= CCSequence:create(array)
		runningScene:runAction(seq)
    else
    	clTalentUnlockDesc:setVisible(true)
    end

	runningScene:addChild(colorLayer, 32767, 32767)

	-- 进阶成功英雄语音
	require "script/utils/SoundEffectUtil"
	local dbData = SoundEffectUtil.getHeroAudioDataByHtid(_tHeroAttr.htid)
	if( dbData and dbData.promote_sound )then
		SoundEffectUtil.playHeroAudio(dbData.promote_sound)
	end
end

-- 创建转场特效
function fnCreateZhuanChangEffect(ccParent)
	local ccDelegate=BTAnimationEventDelegate:create()
	ccDelegate:registerLayerEndedHandler(function (actionName, xmlSprite)
	--		xmlSprite:getParent():removeFromParentAndCleanup(true)
	end)
	local nIndexCount=0
	ccDelegate:registerLayerChangedHandler(function (index, xmlSprite)
		if index+3 == 34 then
			fnCreateTransferEffect(_tForceValues01, _tForceValues02)
		end
	end)

	local sImgPath=CCString:create("images/base/effect/hero/transfer/zhuangchang")
	local clsEffect=CCLayerSprite:layerSpriteWithNameAndCount(sImgPath:getCString(), 1, CCString:create(""))
	nIndexCount=clsEffect:getLayerCount(sImgPath)
	clsEffect:setFPS_interval(1/60)
	clsEffect:setDelegate(ccDelegate)
	clsEffect:setPosition(ccp((g_winSize.width-320*2*g_fElementScaleRatio)/2, ccParent:getContentSize().height))
	clsEffect:setScale(g_fElementScaleRatio)
	ccParent:addChild(clsEffect)
end

-- 点击“开始进阶”按钮事件
local function fnHandlerOfTransfer(tag, obj)
	require "script/guide/NewGuide"
	require "script/guide/GeneralUpgradeGuide"
    if(NewGuide.guideClass ==  ksGuideGeneralUpgrade) then
        GeneralUpgradeGuide.changeLayer(0)
    end

	-- 音效
	require "script/audio/AudioUtil"
	AudioUtil.playEffect("audio/effect/zhujiemian.mp3")
	-- 判断进阶功能节点是否开启了，如果没开启则返回
	require "script/model/DataCache"
	local status = DataCache.getSwitchNodeState(ksSwitchGeneralTransform)
	if not status then
		GeneralUpgradeGuide.closeGuide()
		return
	end
	if not _clSelectedHeroPortrait then
		require "script/ui/tip/AnimationTip"
		AnimationTip.showTip(GetLocalizeStringBy("key_1139"))
		GeneralUpgradeGuide.closeGuide()
		return
	end
	if _tHeroTransferedAttr == nil then
		require "script/ui/tip/AnimationTip"
		AnimationTip.showTip(GetLocalizeStringBy("key_2779"))
		GeneralUpgradeGuide.closeGuide()
		return
	end
	if _tHeroAttr.need_player_lv == nil then
		require "script/ui/tip/AnimationTip"
		AnimationTip.showTip(GetLocalizeStringBy("key_3347"))
		GeneralUpgradeGuide.closeGuide()
		return
	end
	-- 判断主角等是否足够
	require "script/model/user/UserModel"
	if _tHeroAttr.need_player_lv > tonumber(UserModel.getHeroLevel()) then
		require "script/ui/tip/AnimationTip"
		AnimationTip.showTip(GetLocalizeStringBy("key_1155").._tHeroAttr.need_player_lv..GetLocalizeStringBy("key_2243"))
		GeneralUpgradeGuide.closeGuide()
		return
	end
	-- 判断武将等级是否足够
	require "db/DB_Heroes"
	local db_hero = DB_Heroes.getDataById(_tHeroAttr.htid)
	local nLimitLevel = _tHeroAttr.limit_lv -- + tonumber(_tHeroAttr.evolve_level)*db_hero.advanced_interval_lv
	_tHeroAttr.level = tonumber(_tHeroAttr.level)
	if nLimitLevel > _tHeroAttr.level then
		require "script/ui/tip/AnimationTip"
		AnimationTip.showTip(GetLocalizeStringBy("key_1680")..nLimitLevel..GetLocalizeStringBy("key_2243"))
		GeneralUpgradeGuide.closeGuide()
		return
	end
	-- 判断名将数量是否足够
	if _tHeroAttr.need_beauty_count > 0 then
		require "script/ui/star/StarUtil"
		if _tHeroAttr.need_beauty_count > StarUtil.getAllStarsNumber() then
			require "script/ui/tip/AnimationTip"
			AnimationTip.showTip(GetLocalizeStringBy("key_1344").._tHeroAttr.need_beauty_count..GetLocalizeStringBy("key_2243"))
		end
	end
	-- 判断进阶条件是否满足
	for i=1, #_arrNeedItems do
		local item = _arrNeedItems[i]
		if item.needCount > item.realCount then
			require "script/ui/tip/AnimationTip"
			if item.type == _ksTypeOfCard then
				AnimationTip.showTip(GetLocalizeStringBy("key_2622"))
			else
				AnimationTip.showTip(GetLocalizeStringBy("key_3095"))
			end
			GeneralUpgradeGuide.closeGuide()
			return
		end
	end
	-- 判断玩家银币数量是否足够
	if _tHeroAttr.cost_coin > UserModel.getSilverNumber() then
		require "script/ui/tip/AnimationTip"
		AnimationTip.showTip(GetLocalizeStringBy("key_1114"))
		GeneralUpgradeGuide.closeGuide()
		return
	end

	local isHaveTranfer = false -- 是否有要消耗的英雄处于变身状态
	local isInLittlerFormation = false -- 有在小伙伴上的武将
	require "script/network/RequestCenter"
	local args = CCArray:createWithObject(CCInteger:create(_tHeroAttr.hid))
	local sub_args = CCArray:create()
	local args_item = CCDictionary:create()
	for i=1, #_arrNeedItems do
		local item = _arrNeedItems[i]
		if item.type == _ksTypeOfCard then
			if item.realCount > item.needCount then
				table.sort(item.cards, function (p1, p2)
					return p1.level < p2.level
				end)
			end
			table.sort(item.cards, function ( a1, a2 )
				if not LittleFriendData.isInLittleFriend(a1.hid) and LittleFriendData.isInLittleFriend(a2.hid) then
					return true
				else
					return false
				end
			end)
			for j=1, item.needCount do
				sub_args:addObject(CCInteger:create(item.cards[j].hid))
				--判断英雄是否处于变身状态
				require "script/ui/rechargeActive/ActiveCache"
				if(ActiveCache.isUnhandleTransfer(item.cards[j].hid)) then
					isHaveTranfer = true
				end
				if LittleFriendData.isInLittleFriend(item.cards[j].hid) then
					isInLittlerFormation = true
				end
			end
		elseif item.type == _ksTypeOfItem then
			if item.item_type == _nItemTypeProps then
				args_item:setObject(CCInteger:create(item.needCount), tostring(item.itemId))
			elseif item.item_type == _nItemTypeTreas or item.item_type == _nItemTypeArms then
				for i=1, item.needCount do
					args_item:setObject(CCInteger:create(1), tostring(item.itemId[i]))
				end
			end
		end
	end
	require "script/ui/rechargeActive/ActiveCache"
	if(ActiveCache.isUnhandleTransfer(_tHeroAttr.hid)) then
		isHaveTranfer = true
	end
	if(isInLittlerFormation == true) then
		AnimationTip.showTip(GetLocalizeStringBy("lcy_50110"))
		return
	end

	if(isHaveTranfer) then
		--如果武将处于变身状态，那么弹出提示
		sub_args:retain()
		args_item:retain()
		args:retain()
		require "script/ui/tip/AlertTip"
	    AlertTip.showAlert(GetLocalizeStringBy("lcy_50108"), function ( isOk )
	    	if(isOk == true) then
	    		args:addObject(sub_args)
				args:addObject(args_item)
				_sNetworkFlagOfHeroEvolve = RequestCenter.hero_evolve(fnHandlerOfNetwork, args)
	    	end
	    	sub_args:release()
			args_item:release()
			args:release()
	    end, true, nil)
	else
		args:addObject(sub_args)
		args:addObject(args_item)
		_sNetworkFlagOfHeroEvolve = RequestCenter.hero_evolve(fnHandlerOfNetwork, args)
	end

end

-- 关闭按钮回调处理
local function fnHandlerCloseBtn(tag, item_obj)
	-- 音效
	require "script/audio/AudioUtil"
	AudioUtil.playEffect("audio/effect/guanbi.mp3")
	
	require "script/audio/AudioUtil"
	AudioUtil.playEffect("audio/effect/guanbi.mp3")
	require "script/ui/hero/HeroInfoLayer"
	require "script/ui/hero/HeroLayer"
	if _tParentParam.addPos == HeroInfoLayer.kFormationPos then
		require("script/ui/formation/FormationLayer")
    	local formationLayer = FormationLayer.createLayer()
    	MainScene.changeLayer(formationLayer, "formationLayer")
    else
    	MainScene.changeLayer(HeroLayer.createLayer(), "HeroLayer")
    end
	HeroLayer.setHeroListOffSet(_tParentParam.heriListoffset)
	
end

-- 创建标题面板
local function createTitleLayer( ... )
	require "script/libs/LuaCCSprite"

	local tLabel={
		text=GetLocalizeStringBy("key_1137"),
		fontsize=35,
		sourceColor=ccc3(0xff, 0xf0, 0x49),
		targetColor=ccc3(0xff, 0xf0, 0x49),
		tag=_ksTagCloseBtn,
		stroke_size=2,
		stroke_color=ccc3(0, 0, 0),
		anchorPoint=ccp(0.5, 0.5)
	}
	local sprite = LuaCCSprite.createSpriteWithRenderLabel("images/common/title_bg.png", tLabel)

	return sprite
end

-- 创建底部按钮控件
local function createBottomPanel( ... )
	local layer = CCLayer:create()

	local menu = CCMenu:create()
	_ccBtnBeginTransfer= LuaCC.create9ScaleMenuItem("images/common/btn/btn1_d.png","images/common/btn/btn1_n.png", CCSizeMake(210,73), GetLocalizeStringBy("key_2082"), ccc3(255,222,0))
	_ccBtnBeginTransfer:registerScriptTapHandler(fnHandlerOfTransfer)
	_ccBtnBeginTransfer:setPosition(390*g_winSize.width/640, 0)
	_ccBtnBeginTransfer:setScale(g_fElementScaleRatio)
	menu:addChild(_ccBtnBeginTransfer)

	local ccCloseButton = LuaCC.create9ScaleMenuItem("images/common/btn/btn1_d.png","images/common/btn/btn1_n.png", CCSizeMake(210,73), GetLocalizeStringBy("key_1951"), ccc3(255,222,0))
	ccCloseButton:registerScriptTapHandler(fnHandlerCloseBtn)
	ccCloseButton:setPosition(80*g_winSize.width/640, 0)
	ccCloseButton:setScale(g_fElementScaleRatio)
	menu:addChild(ccCloseButton)
	menu:setPosition(ccp(0, 0))
	layer:addChild(menu)

	return layer
end

function getNewHtid(tParam)
	require "db/DB_Heroes"
	local db_hero = DB_Heroes.getDataById(tParam.htid)
	print("getNewHtid",tParam.htid,db_hero.advanced_id)
	local arrTimeIds = {}
	if db_hero.advanced_id then
		local tmp = string.split(db_hero.advanced_id, ",")
		for i=1, #tmp do
			local times_htid = string.split(tmp[i], "|")
			table.insert(arrTimeIds, {times=tonumber(times_htid[1]), htid=tonumber(times_htid[2])})
		end
	end
	local new_htid = nil
	if tParam.evolve_level then
		for i=1, #arrTimeIds do
			if arrTimeIds[i].times == tonumber(tParam.evolve_level) then
				new_htid = arrTimeIds[i].htid
				break
			end
		end
	end
	return new_htid
end

local _heightOfDetailContent=748
-- 模块初始化方法
local function init( ... )
	_aUnlockedTalentDesc = {}
end

-- 创建武将进阶层
function createLayer(tParam)
	print("rsteft")
	print_t(tParam)
	init()
	if tParam then
		_tParentParam = tParam
		if tParam.selectedHeroes then
			if #tParam.selectedHeroes >= 1 then
				_tHeroAttr = tParam.selectedHeroes[1]
			else
				_tHeroAttr = tParam.selectedHeroes
			end
		end
	end
	print("rsteft..")
	print_t(_tHeroAttr)
	local new_htid = getNewHtid(_tHeroAttr)
	print("rsteft", new_htid)
	_tHeroTransferedAttr = nil
	if new_htid then
	    require "db/DB_Hero_transfer"
	    _tHeroTransferedAttr = DB_Hero_transfer.getDataById(new_htid)
	end

	local layer = CCLayer:create()
	-- 加载模块背景图
	local bg = CCSprite:create("images/main/module_bg.png")
	bg:setScale(g_fBgScaleRatio)
	layer:addChild(bg)

	require "script/ui/main/BulletinLayer"
	require "script/ui/main/MainScene"
	require "script/ui/main/MenuLayer"
	local bulletinLayerSize = BulletinLayer.getLayerContentSize()
	local menuLayerSize = MenuLayer.getLayerContentSize()
	MenuLayer.getObject():setVisible(true)

	-- 隐藏avatar层
	local ccObjAvatar = MainScene.getAvatarLayerObj()
	ccObjAvatar:setVisible(false)

	MainScene.setMainSceneViewsVisible(true, false, true)

	local layerRect = {}
	layerRect.width =640
	layerRect.height = g_winSize.height - (bulletinLayerSize.height + menuLayerSize.height)*g_fScaleX
	layer:setContentSize(CCSizeMake(layerRect.width, layerRect.height))
	layer:setPosition(ccp(0, menuLayerSize.height*g_fScaleX))
	-- 标题栏层
	local ccTitleLayer = createTitleLayer()
	local titleSize = ccTitleLayer:getContentSize()
	ccTitleLayer:setScale(g_fScaleX)
	ccTitleLayer:setPosition(ccp(0, layerRect.height-titleSize.height*g_fScaleX))
	-- 加入标题元素
	layer:addChild(ccTitleLayer, 10, -1)

	-- 内容区的实际高度
	local bgHeight = g_winSize.height-(ccTitleLayer:getContentSize().height+bulletinLayerSize.height+menuLayerSize.height) *g_fScaleX
	_heightOfDetailContent = bgHeight
	-- 背景九宫格图
	local fullRect = CCRectMake(0, 0, 196, 198)
    local insetRect = CCRectMake(61, 80, 46, 36)
    local ccStarSellBG = CCScale9Sprite:create("images/hero/bg_ng.png", fullRect, insetRect)
    ccStarSellBG:setPreferredSize(CCSizeMake(g_winSize.width+10, bgHeight+20))
	ccStarSellBG:setPosition(ccp(g_winSize.width/2, -5))
	ccStarSellBG:setAnchorPoint(ccp(0.5, 0))
    layer:addChild(ccStarSellBG)

    local ccLayerBottom = createBottomPanel()
    ccLayerBottom:setPosition(ccp(0, _heightOfDetailContent*10/748))
    layer:addChild(ccLayerBottom)

	-- 创建物品显示列表面板
    local ccSpriteItemPanel = fnCreateItemsPanel()
    ccSpriteItemPanel:setPosition(g_winSize.width/2, _heightOfDetailContent*124/748)
    ccSpriteItemPanel:setAnchorPoint(ccp(0.5, 0))
    ccSpriteItemPanel:setScale(g_fElementScaleRatio)
    layer:addChild(ccSpriteItemPanel)
 	-- 创建显示需要银币面板
    local ccLayerSilverInfo = fnCreateSilverInfoPanel()
    ccLayerSilverInfo:setPosition(g_winSize.width/2, _heightOfDetailContent*80/748)
    layer:addChild(ccLayerSilverInfo)
	-- 武将当前基础属性
    require "script/model/hero/HeroModel"
    local db_hero = DB_Heroes.getDataById(_tHeroAttr.htid)
    local tHeroArgs={}
    tHeroArgs = table.hcopy(_tHeroAttr, tHeroArgs)
    tHeroArgs.type = 0
	-- 计算解锁天赋
	local aAwakeIds = {}
	local growAwakeId = db_hero.grow_awake_id
	local nHeroEvolveLevel = _tHeroAttr.evolve_level or 0
	if growAwakeId ~= nil then
		local arrGrowAwakeId = string.split(db_hero.grow_awake_id, ",")
		for i=1, #arrGrowAwakeId do
			local tmpData01 = string.split(arrGrowAwakeId[i], "|")
			if tmpData01 and #tmpData01 == 3 then
				local nType = tonumber(tmpData01[1])
				if nType == 2 then
					local nTimes = tonumber(tmpData01[2])
					if nTimes-1 == tonumber(nHeroEvolveLevel) then
						table.insert(aAwakeIds, tmpData01[3])
					end
				end
			else
				print("......................htid: ", _tHeroAttr.htid, ", .......grow_awake_id db/data is innormal.")
				break
			end
		end
	end
	require "db/DB_Awake_ability"
	for i=1, #aAwakeIds do
		local db_awake = DB_Awake_ability.getDataById(aAwakeIds[i])
		if db_awake and db_awake.name then
			table.insert(_aUnlockedTalentDesc, db_awake.name)
		end
	end

    local ccLayerLeftAttr = fnCreateHeroAttrPanel(tHeroArgs)
    ccLayerLeftAttr:setScale(g_fElementScaleRatio)
    ccLayerLeftAttr:setPosition(ccp(g_winSize.width*32/640, _heightOfDetailContent*242/748))
    layer:addChild(ccLayerLeftAttr)
	-- 进阶后的属性，最高级别会提高
	if _tHeroTransferedAttr then
	    local tNewHeroAttr = DB_Heroes.getDataById(_tHeroTransferedAttr.new_htid)
		local tNewHeroArgs = {}
		tNewHeroArgs=table.hcopy(_tHeroAttr, tNewHeroArgs)
		tNewHeroArgs.htid = _tHeroTransferedAttr.new_htid
		local ndb_hero = DB_Heroes.getDataById(tNewHeroArgs.htid)
		tNewHeroArgs.heroQuality = ndb_hero.heroQuality
		if HeroModel.isNecessaryHero(tNewHeroArgs.htid) then
			tNewHeroArgs.name = UserModel.getUserName()
		else
			tNewHeroArgs.name = tNewHeroAttr.name
		end
	    tNewHeroArgs.evolve_level = _tHeroAttr.evolve_level + 1
	    tNewHeroArgs.type = 1
	    -- tNewHeroArgs.force_values = HeroFightForce.getAllForceValues(tNewHeroArgs)
	    local ccLayerRightAttr = fnCreateHeroAttrPanel(tNewHeroArgs)
	    ccLayerRightAttr:setScale(g_fElementScaleRatio)
	    ccLayerRightAttr:setPosition(ccp(g_winSize.width*356/640,_heightOfDetailContent*242/748))
	    layer:addChild(ccLayerRightAttr)
	end
	-- 创建“选择武将”面板
	_cs9SelectHero = fnCreateSelectPanel()
	_cs9SelectHero:setAnchorPoint(ccp(0.5, 0))
	_cs9SelectHero:setPosition(g_winSize.width*156/640, _heightOfDetailContent*500/748)
	layer:addChild(_cs9SelectHero)
	_cs9SelectHero:setVisible(false)
	-- 选择武将，武将形象
    _clSelectedHeroPortrait = fnCreateSelectedHeroPanel()
    _clSelectedHeroPortrait:setPosition(g_winSize.width*156/640, _heightOfDetailContent*500/748)
    _clSelectedHeroPortrait:setAnchorPoint(ccp(0.5, 0))
    layer:addChild(_clSelectedHeroPortrait)
	-- 进阶后的形象
	local right = fnCreateHeroNextLevelPanel()
	if right then
		right:setPosition(g_winSize.width*400/640, _heightOfDetailContent*500/748)
		layer:addChild(right)
	end
	-- 右箭头指示标识
	local ccSpriteArrow = CCSprite:create("images/hero/transfer/arrow.png")
	ccSpriteArrow:setScale(g_fElementScaleRatio)
	ccSpriteArrow:setPosition(g_winSize.width/2, _heightOfDetailContent*560/748)
	ccSpriteArrow:setAnchorPoint(ccp(0.5, 0))
	layer:addChild(ccSpriteArrow)

	_clTransfer = layer


	local seq = CCSequence:createWithTwoActions(CCDelayTime:create(0.3),CCCallFunc:create(function ( ... )
		addNewGuide()
	end))
	_clTransfer:runAction(seq)

	return layer
end

-- 创建“消耗银币”信息面板
function fnCreateSilverInfoPanel()
	-- 底(X69 Y15 W24 H14)
	-- 背景九宫格图
	local fullRect = CCRectMake(0, 0, 162, 43)
    local insetRect = CCRectMake(69, 15, 24, 14)
    local ccSpritCostSilverBG = CCScale9Sprite:create("images/hero/transfer/bg_ng_silver.png", fullRect, insetRect)
    local preferredSize = {w=640*2/3, h = 43}
    ccSpritCostSilverBG:setPreferredSize(CCSizeMake(preferredSize.w, preferredSize.h))
    ccSpritCostSilverBG:setAnchorPoint(ccp(0.5, 0))

	local tElements = {
		{ctype=1, text=GetLocalizeStringBy("key_2115"), fontsize=25},
		{ctype=2, file="images/common/coin_silver.png",},
 		{ctype=1, text="0", hOffset=8},
	}
	local tObjs = LuaCC.createCCNodesOnHorizontalLine(tElements)
	local width = 0
	local height = 0
	for i=1, #tObjs do
		local size = tObjs[i]:getContentSize()
		width = width + size.width
		if tElements[i].hOffset then
			width = width + tElements[i].hOffset
		end
		if size.height > height then
			height = size.height
		end
	end
	_arrSilverInfoObjs = tObjs
	tObjs[1]:setPosition(ccp((preferredSize.w-width)/2, (ccSpritCostSilverBG:getContentSize().height-height)/2))

	ccSpritCostSilverBG:addChild(tObjs[1])
	ccSpritCostSilverBG:setScale(g_fElementScaleRatio)
	fnUpdateSilverCostUI()

	return ccSpritCostSilverBG
end

-- 更新银币消耗界面显示
function fnUpdateSilverCostUI(pCostCoin)
	if _arrSilverInfoObjs == nil or #_arrSilverInfoObjs ~= 3 then
		return
	end
	local nCostCoin = pCostCoin or _tHeroAttr.cost_coin
	if nCostCoin == nil then
		nCostCoin = 0
	end
	_arrSilverInfoObjs[3]:setString(nCostCoin)
end

-- 创建物品列表单元
local function createCell(tParam)
	local ccCell = CCTableViewCell:create()

	local headIcon
	if tParam.type == _ksTypeOfCard then
		headIcon = ItemSprite.getHeroIconItemByhtid(tParam.htid, -256) --HeroPublicCC.getCMISHeadIconByHtid(tParam.htid)
	else
		headIcon = ItemSprite.getItemSpriteById(tParam.id, nil, nil, nil, -500, 1000, nil,true)
	end

	ccCell:addChild(headIcon, 1, 10001)
	-- 武将或物品个数比例显示
	local ccRenderLabelCount = CCRenderLabel:create(tParam.realCount.."/"..tParam.needCount, g_sFontName, 21, 1, ccc3(0, 0, 0), type_stroke)
	if tParam.realCount < tParam.needCount then
		ccRenderLabelCount:setColor(ccc3(0xff, 0, 0))
	else
		ccRenderLabelCount:setColor(ccc3(0, 0xff, 0x18))
	end
	ccRenderLabelCount:setPosition(headIcon:getContentSize().width/2, ccRenderLabelCount:getContentSize().height/2+2)
	ccRenderLabelCount:setAnchorPoint(ccp(0.5, 0.5))
	headIcon:addChild(ccRenderLabelCount)

	return ccCell
end

-- 创建物品列表TableView
local function createItemsTableView(tParam)
	local cellSize = CCSizeMake(105, 100)
	local new_htid = getNewHtid(tParam)
	local db_transfer
	if new_htid then
		db_transfer = DB_Hero_transfer.getDataById(new_htid)
	end
	if not db_transfer then
		return nil
	end
	-- 进阶需要的主角等级
	_tHeroAttr.need_player_lv = db_transfer.need_player_lv
	-- 进阶需要的名将数量
	_tHeroAttr.need_beauty_count = db_transfer.need_beauty or 0
	-- 进阶需要的英雄等级
	_tHeroAttr.limit_lv = db_transfer.limit_lv
	-- 进阶需要的花费银币
	_tHeroAttr.cost_coin = db_transfer.cost_coin

	require "db/DB_Heroes"
	-- 进阶需要的卡牌等级和ID
	local sCardNeeded = db_transfer.need_card_lv
	--printB("........................................sCardNeeded: ", sCardNeeded)
	local tArrCardNeeded = {}
	if sCardNeeded then
		tArrCardNeeded = string.split(sCardNeeded, ",")
	end
	local tArrCards = {}
	for i=1, #tArrCardNeeded do
		local data = string.split(tArrCardNeeded[i], "|")
		if #data < 3 then
			break
		end
		local tMapCard={htid=tonumber(data[1]), level=tonumber(data[2]), realCount=0, needCount=tonumber(data[3])}
		local tDB = DB_Heroes.getDataById(tMapCard.htid)
		tMapCard.bg = "images/base/potential/officer_"..tDB.potential..".png"
		tMapCard.file = "images/base/hero/head_icon/"..tDB.head_icon_id
		tMapCard.type = _ksTypeOfCard
		tMapCard.cards = {}
		table.insert(tArrCards, tMapCard)
	end
	-- 进阶需要的物品ID及数量组
	require "db/DB_Item_normal"
	local sItemNeeded = db_transfer.need_items
	local tArrItemNeeded = string.split(sItemNeeded, ",")
	local tArrItems = {}
	require "script/ui/item/ItemUtil"
	for i=1, #tArrItemNeeded do
		local data = string.split(tArrItemNeeded[i], "|")
		if #data < 2 then
			data[2] = 1
		end
		local tMapItem = {id=tonumber(data[1]), needCount=tonumber(data[2]), realCount=0}
		local tDB = ItemUtil.getItemById(tMapItem.id)
		tMapItem.file = "images/base/props/"..tDB.icon_small
		if tDB.item_type == 11 then
			tMapItem.file = "images/base/treas/small/"..tDB.icon_small
		end
		tMapItem.bg = "images/base/potential/props_"..tDB.quality..".png"
		tMapItem.type = _ksTypeOfItem
		tMapItem.item_type = tDB.item_type
		table.insert(tArrItems, tMapItem)
	end
	-- 从数据缓存中获取所有武将信息
	local allHeroes = HeroModel.getAllHeroes()
	-- 去除当前武将本身及已上阵武将
	require "script/model/DataCache"
	for k, v in pairs(allHeroes) do
		local bIsFiltered = false
		-- 过滤在阵上的
		-- local isBusy = DataCache.isHeroBusy({hid=tonumber(v.hid)})
		local isBusy = HeroPublicLua.isOnFormation(v.hid)	--只判断在阵容上，不判断小伙伴
		require "script/ui/formation/secondfriend/SecondFriendData"
		local isOnSecondFriend = SecondFriendData.isInSecondFriendByHid(v.hid)
		if not isBusy and not isOnSecondFriend then
			-- 过滤进阶过的
			if tonumber(v.evolve_level) == 0 then
				--过滤神兵副本中已上阵的武将
				if GodWeaponCopyData.isOnCopyFormationBy(v.hid) == false then
					-- 过滤自身
					if tonumber(_tHeroAttr.hid) ~= tonumber(v.hid) then
						for i=1, #tArrCards do
							-- 检测该武将是否是需要的卡牌
							local vHtid = tonumber(v.htid)
							local vLevel = tonumber(v.level)
							if vHtid == tArrCards[i].htid then
								-- 武将等级 >= 进阶需要的等级要求
								if vLevel <= tArrCards[i].level then
									tArrCards[i].realCount = tArrCards[i].realCount + 1
									table.insert(tArrCards[i].cards, {hid=tonumber(v.hid), level=vLevel})
								end
								break
							end
						end
					end
				end
			end
		end
	end
	-- 获取物品相关数据
	local bag = DataCache.getRemoteBagInfo()
	local treas = bag.treas
	local props = bag.props
	local arms = bag.arm
	if props then
		for k, v in pairs(props) do
			for i=1, #tArrItems do
				if tArrItems[i].item_type == _nItemTypeProps and tonumber(v.item_template_id) == tArrItems[i].id then
					if v.item_id then
						tArrItems[i].itemId = tonumber(v.item_id)
					end
					tArrItems[i].realCount = tArrItems[i].realCount +  tonumber(v.item_num)
				end
			end
		end
	end
	if treas then
		for k, v in pairs(treas) do
			for i=1, #tArrItems do
				if tArrItems[i].item_type == _nItemTypeTreas and tonumber(v.item_template_id) == tArrItems[i].id then
					if v.va_item_text and v.va_item_text.treasureLevel and tonumber(v.va_item_text.treasureLevel)==0 then
						tArrItems[i].realCount = tArrItems[i].realCount +  tonumber(v.item_num)
						if tArrItems[i].itemId == nil then
							tArrItems[i].itemId = {}
						end
						table.insert(tArrItems[i].itemId, v.item_id)
					end
				end
			end
		end
	end
	if arms then
		for k, v in pairs(arms) do
			for i=1, #tArrItems do
				if tArrItems[i].item_type == _nItemTypeArms and tonumber(v.item_template_id) == tArrItems[i].id then
					if v.va_item_text and v.va_item_text.armReinforceLevel and tonumber(v.va_item_text.armReinforceLevel)==0 then
						tArrItems[i].realCount = tArrItems[i].realCount +  tonumber(v.item_num)
						if tArrItems[i].itemId == nil then
							tArrItems[i].itemId = {}
						end
						table.insert(tArrItems[i].itemId, v.item_id)
					end
				end
			end
		end
	end
	-- tableview中单元项数组
	local tCellItems = {}
	-- 把卡牌信息加入单元项数组
	for i=1, #tArrCards do
		table.insert(tCellItems, tArrCards[i])
	end
	-- 把物品信息加入单元项数组
	for i=1, #tArrItems do
		table.insert(tCellItems, tArrItems[i])
	end
	_arrNeedItems = tCellItems
	require "script/ui/item/ItemSprite"

	local handler = LuaEventHandler:create(function(fn, table, a1, a2)
		local r
		if (fn == "cellSize") then
			r = CCSizeMake(cellSize.width, cellSize.height)
		elseif (fn == "cellAtIndex") then
			r = createCell(tCellItems[a1+1])
		elseif (fn == "numberOfCells") then
			r = #tCellItems
		end
		return r
	end)
	-- 创建卡牌、物品显示tableview
	local tableView = LuaTableView:createWithHandler(handler, CCSizeMake(432, 102))
	tableView:setAnchorPoint(ccp(0.5, 0))
	tableView:setBounceable(true)
	tableView:setDirection(kCCScrollViewDirectionHorizontal)
	tableView:setVerticalFillOrder(kCCTableViewFillTopDown)
	local visiableCellNum = 4

	return tableView
end

 function fnCreateItemsPanel()
	-- 背景图(9宫格)
	local fullRect = CCRectMake(0, 0, 61, 47)
	local insetRect = CCRectMake(24, 16, 10, 4)
    local bg_ng = CCScale9Sprite:create("images/common/bg/white_text_ng.png", fullRect, insetRect)
	-- 九宫格背景包实际大小
    local preferredSize = {width=580, height=116}
    bg_ng:setPreferredSize(CCSizeMake(preferredSize.width, preferredSize.height))
	-- 左箭头
    local ccSpriteLeftArrow = CCSprite:create("images/formation/btn_left.png")
    local x_left = 0.022*preferredSize.width
    ccSpriteLeftArrow:setPosition(ccp(x_left, preferredSize.height/2))
    ccSpriteLeftArrow:setAnchorPoint(ccp(0, 0.5))
	--    ccSpriteLeftArrow:setColor(ccc3(150, 150, 150))
    bg_ng:addChild(ccSpriteLeftArrow)

	-- 需要的卡牌及物品水平列表显示
    local ccItemsTableView = createItemsTableView(_tHeroAttr)
    _ctvCardItem = ccItemsTableView
    if ccItemsTableView then
	    ccItemsTableView:setPosition(80, 8)
	    bg_ng:addChild(ccItemsTableView)
	end

	-- 右箭头(只需要左箭头图片资源，然后旋转180度)
    local ccSpriteRightArrow = CCSprite:create("images/formation/btn_left.png")
    ccSpriteRightArrow:setRotation(180)
   	local x_right = preferredSize.width-x_left-ccSpriteRightArrow:getContentSize().width/2
    ccSpriteRightArrow:setPosition(ccp(x_right, preferredSize.height/2))
    ccSpriteRightArrow:setAnchorPoint(ccp(0.5, 0.5))
    bg_ng:addChild(ccSpriteRightArrow)

    return bg_ng
end
-- 创建武将属性面板
 function fnCreateHeroAttrPanel(tParam)
	-- 背景图(9宫格)
	local fullRect = CCRectMake(0, 0, 75, 75)
	local insetRect = CCRectMake(30, 30, 15, 10)
    local bg_ng = CCScale9Sprite:create("images/hero/transfer/bg_ng_graywhite.png", fullRect, insetRect)
    -- 九宫格背景包实际大小
    local preferredSize = {width=256, height=254}
    bg_ng:setPreferredSize(CCSizeMake(preferredSize.width, preferredSize.height))

    local x = 24
    local y = 16

    require "script/libs/LuaCCLabel"
    require "script/model/hero/HeroModel"
 	-- 属性名称列表
 	local tLabels = {
 		{text=GetLocalizeStringBy("key_2809"), fontsize=18, color=ccc3(0x78, 0x25, 0)},
 		{text=GetLocalizeStringBy("key_2207"), vOffset=10},
 		{text=GetLocalizeStringBy("key_3234")},
 		{text=GetLocalizeStringBy("key_3001")},
 		{text=GetLocalizeStringBy("key_1390")}
 	}
 	local tLabelAttrObjs = LuaCCLabel.createVerticalLabelHeelLabels(tLabels)
 	tLabelAttrObjs[1]:setPosition(ccp(x, y))
 	bg_ng:addChild(tLabelAttrObjs[1])
 	local maxWidth = tLabelAttrObjs[1]:getContentSize().width
 	for k,v in pairs(tLabelAttrObjs) do
 		if v:getContentSize().width > maxWidth then
 			maxWidth = v:getContentSize().width
 		end
 	end
 	x = x+maxWidth

 	-- 属性值列表
	local tArgs=tParam
 	require "script/ui/hero/HeroFightForce"
 	local tForceValue
	-- tForceValue = HeroFightForce.getAllForceValues(tParam)
	require "script/model/hero/FightForceModel"
	require "script/model/hero/HeroModel"
	require "script/model/affix/AffixDef"
	local heroInfo = {}
	table.hcopy(HeroModel.getHeroByHid(tParam.hid), heroInfo)
	heroInfo.evolve_level = tParam.evolve_level
	tForceValue = FightForceModel.getHeroDisplayAffixByHeroInfo(heroInfo)

 	local tLabels = {
 		{text=tForceValue[AffixDef.MAGIC_DEFEND], fontsize=18, color=ccc3(0, 0, 0)},
 		{text=tForceValue[AffixDef.PHYSICAL_DEFEND], vOffset=10},
		{text=tForceValue[AffixDef.GENERAL_ATTACK]},
 		{text=tForceValue[AffixDef.LIFE]},
 		{text=tParam.level}
 	}

 	local tValueObjs = LuaCCLabel.createVerticalLabelHeelLabels(tLabels)
 	if tParam.type == 0 then
		_aLeftAttrValueObjs = tValueObjs[1]
		_tForceValues01 = {}
		_tForceValues01.magicDefend = tLabels[1].text
		_tForceValues01.physicalDefend = tLabels[2].text
		_tForceValues01.generalAttack = tLabels[3].text
		_tForceValues01.life = tLabels[4].text
		_tForceValues01.level = tLabels[5].text
	else
		_tForceValues02 = {}
		_tForceValues02.magicDefend = tLabels[1].text
		_tForceValues02.physicalDefend = tLabels[2].text
		_tForceValues02.generalAttack = tLabels[3].text
		_tForceValues02.life = tLabels[4].text
		_tForceValues02.level = tLabels[5].text
	end
 	tValueObjs[1]:setPosition(x, y)
 	bg_ng:addChild(tValueObjs[1])
 	-- 战斗力信息面板
 	-- 背景图(9宫格)
	local fullRect = CCRectMake(0, 0, 46, 23)
	local insetRect = CCRectMake(20, 8, 5, 1)
 	local cc9SpriteFightForce = CCScale9Sprite:create("images/hero/transfer/bg_ng_orange.png", fullRect, insetRect)
 	local preferredSize = {width=230, height=46}
 	cc9SpriteFightForce:setPreferredSize(CCSizeMake(preferredSize.width, preferredSize.height))
 	cc9SpriteFightForce:setPosition(bg_ng:getContentSize().width/2, 170)
 	cc9SpriteFightForce:setAnchorPoint(ccp(0.5, 0))

 	bg_ng:addChild(cc9SpriteFightForce)

 	local x = 10
 	local y = cc9SpriteFightForce:getContentSize().height/2
 	local ccSpriteFightValue = CCSprite:create("images/hero/potential.png")
 	ccSpriteFightValue:setPosition(x, y)
 	ccSpriteFightValue:setAnchorPoint(ccp(0, 0.5))
 	cc9SpriteFightForce:addChild(ccSpriteFightValue)
 	x = x + ccSpriteFightValue:getContentSize().width

 	if tParam.heroQuality == nil then
 		tParam.heroQuality = DB_Heroes.getDataById(tParam.htid).heroQuality
 	end
 	local ccLabelFightValue = CCRenderLabel:create(tParam.heroQuality, g_sFontName, 25, 2, ccc3(0, 0, 0), type_stroke)
 	ccLabelFightValue:setColor(ccc3(0xff, 0xfe, 0))
 	ccLabelFightValue:setPosition(x + 14 + ccLabelFightValue:getContentSize().width/2, y-4)
 	ccLabelFightValue:setAnchorPoint(ccp(0.5, 0.5))
 	if tParam.type == 0 then
		_crlLeftFightValueObj = ccLabelFightValue
	end
 	cc9SpriteFightForce:addChild(ccLabelFightValue)

 	local tElements = {
 		{ctype=LuaCC.m_ksTypeLabel, text=tParam.name, color=ccc3(0x78, 0x25, 0)},
 		{ctype=LuaCC.m_ksTypeSprite, file="images/hero/transfer/numbers/add.png", hOffset=10},
 	}

 	local sEvolveLevel = tostring(tParam.evolve_level)
 	for i=1, #sEvolveLevel do
 		local sImageFile = "images/hero/transfer/numbers/"..(string.byte(sEvolveLevel, i)-48)..".png"
 		table.insert(tElements, {ctype=LuaCC.m_ksTypeSprite, file=sImageFile, hOffset=0} )
 	end

 	--橙卡显示“%d阶”
 	if tParam.star_lv >= 6 then
 		tElements[2] = {ctype=LuaCC.m_ksTypeLabel, text="  ", hOffset=0}
 		table.insert(tElements, {ctype=LuaCC.m_ksTypeRenderLabel, text=GetLocalizeStringBy("zz_100"), strokeSize=1, color = ccc3(0x00,0xff,0x00), fontname=g_sFontPangWa, strokeColor=ccc3(0x00,0x00,0x00), vOffset=32})
 	end
 	require "script/libs/LuaCC"
	local tObjs = LuaCC.createCCNodesOnHorizontalLine(tElements)
	tObjs[1]:setPosition(ccp(20, 220))
	if tParam.type == 0 then
		_aLeftEvolveLevel = tObjs[1]
	end
	bg_ng:addChild(tObjs[1])

	return bg_ng
end

-- 进阶后清理左面板显示属性内容值
function fnCleanLeftPanel( ... )
	if _aLeftEvolveLevel then
		_aLeftEvolveLevel:removeFromParentAndCleanup(true)
		_aLeftEvolveLevel = nil
	end
	_crlLeftFightValueObj:setString(" ")
	if _aLeftAttrValueObjs then
		_aLeftAttrValueObjs:removeFromParentAndCleanup(true)
		_aLeftAttrValueObjs = nil
	end
end

function fnCleanAfterTransfer( ... )
	_cs9SelectHero:setVisible(true)
	if _clSelectedHeroPortrait then
		_clSelectedHeroPortrait:removeFromParentAndCleanup(true)
		_clSelectedHeroPortrait = nil
	end
	fnCleanLeftPanel()
	fnUpdateSilverCostUI(0)
	if _ctvCardItem then
		_ctvCardItem:removeFromParentAndCleanup(true)
		_ctvCardItem = nil
	end
end

-- 创建“选择武将”面板
function fnCreateSelectPanel( ... )
	local fullRect = CCRectMake(0, 0, 77, 82)
    local insetRect = CCRectMake(38, 39, 1, 3)
    local preferredSize = {width=301, height=443}
	local cs9CardBg = CCScale9Sprite:create("images/hero/transfer/bg_ng_card.png", fullRect, insetRect)
	cs9CardBg:setPreferredSize(CCSizeMake(preferredSize.width, preferredSize.height))
	local fScale = _fScaleCard*g_fElementScaleRatio
	cs9CardBg:setScale(fScale)

	local cltSelectHero = CCRenderLabel:create(GetLocalizeStringBy("key_2150"), g_sFontName, 32, 2, ccc3(255, 0xea, 0x5a), type_stroke)
	cltSelectHero:setColor(ccc3(0, 0, 0))
	cltSelectHero:setAnchorPoint(ccp(0.5, 0.5))
	cltSelectHero:setScale(1/fScale)
	cltSelectHero:setPosition(preferredSize.width/2, preferredSize.height/2)

	cs9CardBg:addChild(cltSelectHero)

	-- 透明按钮
	local rect = CCRectMake(0, 0, 3, 3)
	local rectInsets = CCRectMake(1, 1, 1, 1)

	local ccSpriteTransparent = CCScale9Sprite:create("images/common/transparent.png", rect, rectInsets)
	ccSpriteTransparent:setPreferredSize(CCSizeMake(preferredSize.width, preferredSize.height))

	local ccMenu = CCMenu:create()
	local ccMenuItemSelect = CCMenuItemSprite:create(ccSpriteTransparent, ccSpriteTransparent)
	ccMenuItemSelect:registerScriptTapHandler(fnHandlerOfButtonSelectHero)
	ccMenu:addChild(ccMenuItemSelect)
	ccMenu:setPosition(0, 0)
	cs9CardBg:addChild(ccMenu)

	return cs9CardBg
end

-- 创建被选择武将形象
fnCreateSelectedHeroPanel = function ( ... )
	require "db/DB_Heroes"
	local tDB = DB_Heroes.getDataById(_tHeroAttr.htid)

	local quality = _tHeroAttr.star_lv
	-- 卡牌品质背景
	local ccSpriteBg = CCSprite:create("images/common/hero_show/quality/"..quality..".png")
	local fScale = _fScaleCard*g_fElementScaleRatio
	ccSpriteBg:setScale(fScale)
	-- 增加星星显示
	local tArrNodes = {}
	for i=1, _tHeroAttr.star_lv do
		tArrNodes[i] = {ctype=LuaCC.m_ksTypeSprite, file="images/hero/star.png", hOffset=1, }
	end
	local tObjs = LuaCC.createCCNodesOnHorizontalLine(tArrNodes)
	tObjs[1]:setPosition(18, 18)
	ccSpriteBg:addChild(tObjs[1])

	-- 所属国家图标
	local country_icon = HeroModel.getLargeCiconByCidAndlevel(tDB.country, _tHeroAttr.star_lv)
	if country_icon then
		local ccSpriteCountry = CCSprite:create(country_icon)
		ccSpriteCountry:setPosition(ccp(246, 10))
		ccSpriteBg:addChild(ccSpriteCountry)
	end
	-- 增加星星显示
	local tArrNodes = {{ctype=LuaCC.m_ksTypeSprite, file="images/hero/star.png", hOffset=1, }}
	local tObjs = LuaCC.createCCNodesOnHorizontalLine(tArrNodes)
	tObjs[1]:setPosition(18, 18)
	ccSpriteBg:addChild(tObjs[1])

	-- 卡牌角色展示
	local heroInfo = HeroModel.getHeroByHid(_tHeroAttr.hid)
	local heroOffSet = HeroUtil.getHeroBodySpriteOffsetByHTID(_tHeroAttr.htid, nil , heroInfo.turned_id)
	local imageFile = HeroUtil.getHeroBodyImgByHTID(_tHeroAttr.htid, nil,HeroModel.getSex(_tHeroAttr.htid), heroInfo.turned_id)
	local ccSpriteCardShow = CCSprite:create(imageFile)
	ccSpriteCardShow:setPosition(ccp(ccSpriteBg:getContentSize().width/2, 62-heroOffSet))
	ccSpriteCardShow:setAnchorPoint(ccp(0.5, 0))
	ccSpriteBg:addChild(ccSpriteCardShow)
	-- 透明按钮
	local file="images/common/transparent.png"
	local rect = CCRectMake(0, 0, 3, 3)
	local rectInsets = CCRectMake(1, 1, 1, 1)
	local preferredSize = {width=ccSpriteBg:getContentSize().width, height=ccSpriteBg:getContentSize().height}

	local ccSpriteTransparent = CCScale9Sprite:create(file, rect, rectInsets)
	ccSpriteTransparent:setPreferredSize(CCSizeMake(preferredSize.width, preferredSize.height))
    local ccMenu = CCMenu:create()
	local ccMenuItemSelect = CCMenuItemSprite:create(ccSpriteTransparent, ccSpriteTransparent)
	ccMenuItemSelect:registerScriptTapHandler(fnHandlerOfButtonSelectHero)
	ccMenu:addChild(ccMenuItemSelect)
	ccMenu:setPosition(0, 0)
	ccSpriteBg:addChild(ccMenu)

	return ccSpriteBg
end

-- 创建进阶后下级形象面板
function fnCreateHeroNextLevelPanel( ... )
	if not _tHeroTransferedAttr then
		return nil
	end 
	require "db/DB_Heroes"
	local tDB = DB_Heroes.getDataById(_tHeroTransferedAttr.new_htid)
	print("fnCreateHeroNextLevelPanel",_tHeroTransferedAttr.new_htid,tDB.star_lv)

	local quality = tDB.star_lv
	-- 卡牌品质背景
	local ccSpriteBg = CCSprite:create("images/common/hero_show/quality/"..quality..".png")
	ccSpriteBg:setScale(_fScaleCard*g_fElementScaleRatio)
	-- 增加星星显示
	local tArrNodes = {}
	for i=1, tDB.star_lv do
		tArrNodes[i] = {ctype=LuaCC.m_ksTypeSprite, file="images/hero/star.png", hOffset=1, }
	end
	local tObjs = LuaCC.createCCNodesOnHorizontalLine(tArrNodes)
	tObjs[1]:setPosition(18, 18)
	ccSpriteBg:addChild(tObjs[1])
	
	-- 所属国家图标
	local country_icon = HeroModel.getLargeCiconByCidAndlevel(tDB.country, tDB.star_lv)
	local ccSpriteCountry = CCSprite:create(country_icon)
	ccSpriteCountry:setPosition(ccp(246, 10))
	ccSpriteBg:addChild(ccSpriteCountry)

	-- 增加星星显示
	local tArrNodes = {{ctype=LuaCC.m_ksTypeSprite, file="images/hero/star.png", hOffset=1, }}
	local tObjs = LuaCC.createCCNodesOnHorizontalLine(tArrNodes)
	tObjs[1]:setPosition(18, 18)
	ccSpriteBg:addChild(tObjs[1])

	-- 卡牌角色展示
	local heroOffSet = HeroUtil.getHeroBodySpriteOffsetByHTID(_tHeroAttr.htid)

	local heroInfo = HeroModel.getHeroByHid(_tHeroAttr.hid)
	local heroOffSet = HeroUtil.getHeroBodySpriteOffsetByHTID(_tHeroAttr.htid, nil , heroInfo.turned_id)
	local imageFile = HeroUtil.getHeroBodyImgByHTID(_tHeroAttr.htid, nil,HeroModel.getSex(_tHeroAttr.htid), heroInfo.turned_id)
	local ccSpriteCardShow = CCSprite:create(imageFile)
	ccSpriteCardShow:setPosition(ccp(ccSpriteBg:getContentSize().width/2, 62-heroOffSet))
	ccSpriteCardShow:setAnchorPoint(ccp(0.5, 0))
	ccSpriteBg:addChild(ccSpriteCardShow)

	return ccSpriteBg
end

-- 获得GetLocalizeStringBy("key_2082")按钮（新手引导相关）
function getTransferButton( ... )
	return _ccBtnBeginTransfer
end

--[[
	@des: add new guide
]]
function addNewGuide( ... )
	require "script/guide/NewGuide"
	require "script/guide/GeneralUpgradeGuide"
    if(NewGuide.guideClass ==  ksGuideGeneralUpgrade and GeneralUpgradeGuide.stepNum == 2) then
       	require "script/ui/main/MainBaseLayer"
     	local equipButton = getTransferButton()
        local touchRect   = getSpriteScreenRect(equipButton)
        GeneralUpgradeGuide.show(3,touchRect)
    end
end

function addGenralGuideForOverTrs( ... )
	print("addGenralGuideForOverTrs")
	require "script/guide/NewGuide"
	require "script/guide/GeneralUpgradeGuide"
    if(NewGuide.guideClass ==  ksGuideGeneralUpgrade and GeneralUpgradeGuide.stepNum == 3) then
       	require "script/ui/main/MenuLayer"
     	local equipButton = MenuLayer.getMenuItemNode(3)
        local touchRect   = getSpriteScreenRect(equipButton)
        GeneralUpgradeGuide.show(4,touchRect)
    end
end





