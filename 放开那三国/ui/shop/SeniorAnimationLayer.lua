-- Filename：	SeniorAnimationLayer.lua
-- Author：		Cheng Liang
-- Date：		2013-8-23
-- Purpose：		神将展示信息

module ("SeniorAnimationLayer", package.seeall)

require "script/model/DataCache"

require "script/ui/main/MainScene"
require "script/ui/star/StarSprite"
require "script/model/user/UserModel"
require "script/ui/hero/HeroPublicCC"
require "script/ui/hero/HeroPublicLua"

-- addby licong 2013.09.09
local didClickZhaoJiangFun = nil
------------end-----------

local AnimationDuration = 0.2

local _isCanRecruit 	= false

local _bgLayer			= nil
local _t_hids 			= nil	
local _select_htid 		= nil
local _allHerosSp 		= {}
local _allOppBtn	 	= {}
local recruitMenuBar 	= nil
local _updateTimeScheduler = nil

local _selectedIndex 	= nil

local _oppMenuBar 		= nil

local _curDictData 		= nil
local _nameBgArr 		= {}			-- 名称背景
local _nameLabelArr 	= {}			-- 名称

local _fiveStarBg 		= nil	-- 法阵背景
local _isShowEffect 	= true
local _guangSpriteEffect = nil
local _isCanAction	= true

local positionX = {320.0/640, 530.0/640, 480.0/640, 160.0/640, 110.0/640, }
local positionY = {800.0/960, 540.0/960, 215.0/960, 215.0/960, 540.0/960, }

local _overCount = 0
local _addPSoulNum = 0  -- 紫色魂玉数量

-- 初始化
local function init( )
	_bgLayer 		= nil
	_t_hids 		= nil	
	_allHerosSp 	= {}
	_allOppBtn 		= {}
	recruitMenuBar	= nil
	_oppMenuBar 	= nil
	_select_htid 	= nil
	_isCanRecruit 	= false
	_selectedIndex 	= nil
	_curDictData 	= nil
	_nameBgArr 		= {}
	_nameLabelArr 	= {}			-- 名称
	_updateTimeScheduler = nil
	_fiveStarBg 	= nil	-- 法阵背景
	_isShowEffect 	= true
	_guangSpriteEffect = nil
	_isCanAction	= true
	_overCount 		= 0
	_addPSoulNum 	= 0  -- 紫色魂玉数量
end 

-- 停止scheduler
function stopScheduler( )
	if(_updateTimeScheduler)then
		CCDirector:sharedDirector():getScheduler():unscheduleScriptEntry(_updateTimeScheduler)
		_updateTimeScheduler = nil
	end
end


function endCallback( tipSprite )
	tipSprite:removeFromParentAndCleanup(true)
	tipSprite = nil
	for k,v in pairs(_allOppBtn) do
		v:setVisible(true)
	end
end 

-- 点击招将按钮Actin
local function recruitAction( tag, itemBtn )
	-- 音效
	require "script/audio/AudioUtil"
	AudioUtil.playEffect("audio/effect/zhujiemian.mp3")
	---[==[等级礼包新手引导屏蔽层
	---------------------新手引导---------------------------------
	--add by licong 2013.09.09
	require "script/guide/NewGuide"
	require "script/guide/LevelGiftBagGuide"
	if(NewGuide.guideClass == ksGuideFiveLevelGift) then
		require "script/guide/LevelGiftBagGuide"
		LevelGiftBagGuide.changLayer()
		print("LevelGiftBagGuide changeLayer")
	end
	---------------------end-------------------------------------
	--]==]

	_isCanRecruit = false
	recruitMenuBar:removeFromParentAndCleanup(true)
	recruitMenuBar=nil
	local bgLayerSize = _bgLayer:getContentSize()

	delNamesBgSprite()

	createOppsiteCards()

	for k,t_hero_sp in pairs(_allHerosSp) do
		local actionArr = CCArray:create()
		actionArr:addObject(CCOrbitCamera:create(AnimationDuration, 1, 0, 0, 90, 0, 0))
		actionArr:addObject(CCCallFuncN:create(endCallback))
		t_hero_sp:runAction(CCSequence:create(actionArr))

		local oppBtn = _allOppBtn[k]
		local actionArr_2 = CCArray:create()
		actionArr_2:addObject(CCOrbitCamera:create(AnimationDuration*2, 1, 0, 0, 180, 0, 0))
		actionArr_2:addObject(CCCallFuncN:create(shuffleCard))
		oppBtn:runAction(CCSequence:create(actionArr_2))
	end
end

-- 洗牌结束
local function shuffleCardEndFunc(  )
	_isCanRecruit = true
	-- addby licong 2013.09.09
	if(didClickZhaoJiangFun ~= nil)then
		didClickZhaoJiangFun()
	end
	---------------------------
end
-- 洗牌
function shuffleCard( oppBtn, tag )
	local bgLayerSize = _bgLayer:getContentSize()
	
	local positionX,positionY = oppBtn:getPosition()
	
	local actionArr = CCArray:create()
	actionArr:addObject(CCMoveTo:create(AnimationDuration, MainScene.getMenuPositionInTruePoint(bgLayerSize.width/2, bgLayerSize.height/2)))
	actionArr:addObject(CCMoveTo:create(AnimationDuration, ccp(positionX, positionY)))
	actionArr:addObject(CCCallFuncN:create(shuffleCardEndFunc))
	oppBtn:runAction(CCSequence:create(actionArr))
end

-- 选中卡牌的动画_2
local function callVisibleAnimateion_2( cardBtn )
	cardBtn:removeFromParentAndCleanup(true)
	cardBtn = nil
	for k,v in pairs(_allHerosSp) do
		v:setVisible(true)
	end
end

-- 结束
local function endAnimation()
	for k,v in pairs(_nameBgArr) do
		v:setVisible(true)
	end
	-- _overCount = _overCount + 1
	-- if(_overCount == 4) then
	-- 	showAnimation()
	-- end
end

-- 展示英雄
local function displayHero(  )
	if(_curDictData.err == "ok") then
		local h_tid = nil
		local h_id 	= nil
		local s_tid = nil
		local s_id 	= nil

		local hero_t = _curDictData.ret.hero
		local star_t = _curDictData.ret.star
		if( not table.isEmpty(hero_t))then
			local h_keys = table.allKeys(hero_t)
			h_id = tonumber(h_keys[1])
			h_tid = tonumber(hero_t["" .. h_id])
		end
		if( not table.isEmpty(star_t))then
			local s_keys = table.allKeys(star_t)
			s_id = tonumber(s_keys[1])
			s_tid = tonumber(star_t["" .. s_id])
		end
		
		DataCache.changeSeniorHeros(nil, nil)
		
		require "script/ui/shop/HeroDisplayerLayer"
		local  heroDisplayerLayer = HeroDisplayerLayer.createLayer(h_id, h_tid, s_id, s_tid, _addPSoulNum)
		MainScene.changeLayer(heroDisplayerLayer, "heroDisplayerLayer")
	end
end 

-- scheduler 刷新
local function updateTime()
	stopScheduler()
	displayHero()
end

-- 其他四个的动画
local function otherAnimation( m_sprite )
	for k_index,cardBtn in pairs(_allOppBtn) do

		if(k_index ~= _selectedIndex) then
			local actionArr = CCArray:create()
			actionArr:addObject(CCOrbitCamera:create(AnimationDuration, 1, 0, 0, 90, 0, 0))
			actionArr:addObject(CCCallFuncN:create(callVisibleAnimateion_2))
			cardBtn:runAction(CCSequence:create(actionArr))
			
			local s_sprite = _allHerosSp[k_index]
			local actionArr_2 = CCArray:create()
			actionArr_2:addObject(CCOrbitCamera:create(AnimationDuration*2, 1, 180, 0, 360, 0, 0))
			actionArr_2:addObject(CCCallFuncN:create(endAnimation))
			s_sprite:runAction(CCSequence:create(actionArr_2))
		end
	end
	_updateTimeScheduler = CCDirector:sharedDirector():getScheduler():scheduleScriptFunc(updateTime, AnimationDuration*2.4, false)
end

-- 选中卡牌的动画
local function callVisibleAnimateion( cardBtn )
	cardBtn:removeFromParentAndCleanup(true)
	cardBtn = nil
	local sprite 		= _allHerosSp[_selectedIndex]:setVisible(true)
	local selectLabel 	= _nameLabelArr[_selectedIndex]
	local selectNameBg 	= _nameBgArr[_selectedIndex]:setVisible(true)
end

-- 完成招将的动画
function recruitDisplayAnimation( h_tid )
	local index = nil
	for k,v in pairs(_t_hids) do
		if(tonumber(v) == tonumber(h_tid) ) then
			index = k
			break
		end
	end
	
	_t_hids[index] = _t_hids[_selectedIndex]
	_t_hids[_selectedIndex] = h_tid

	createDisplayCards(false)
	local s_sprite = _allHerosSp[_selectedIndex]
	local s_cardBtn = _allOppBtn[_selectedIndex]

	local actionArr = CCArray:create()
	actionArr:addObject(CCOrbitCamera:create(AnimationDuration, 1, 0, 0, 90, 0, 0))
	actionArr:addObject(CCCallFuncN:create(callVisibleAnimateion))
	s_cardBtn:runAction(CCSequence:create(actionArr))
	
	local actionArr_2 = CCArray:create()
	actionArr_2:addObject(CCOrbitCamera:create(AnimationDuration*2, 1, 180, 0, 360, 0, 0))
	actionArr_2:addObject(CCCallFuncN:create(otherAnimation))
	s_sprite:runAction(CCSequence:create(actionArr_2))

end

-- 招募回调
function realRecruitCallback( cbFlag, dictData, bRet )
	if(dictData.err == "ok") then
		_curDictData = dictData
		-- _guangSpriteEffect:setVisible(false)
		recruitDisplayAnimation( _select_htid )
		
		if(dictData.ret.add_point and tonumber(dictData.ret.add_point) > 0)then
			DataCache.addShopPoint(tonumber(dictData.ret.add_point))
            _addPSoulNum = tonumber(dictData.ret.add_point)
		end

	end
end

-- 真实招募
local function realRecruitAction( tag, itemBtn )
	-- 音效
	require "script/audio/AudioUtil"
	AudioUtil.playEffect("audio/effect/zhujiemian.mp3")
	if(_isCanRecruit) then
		_selectedIndex 	= tag
		
		local args = Network.argsHandler(_select_htid)
		RequestCenter.shop_goldRecruitConfirm(realRecruitCallback, args)
		_isCanRecruit = false

	end
end 

-- 创建翻牌的5个按钮
function createOppsiteCards()
	-- 翻牌
	_oppMenuBar = CCMenu:create()
	_oppMenuBar:setPosition(ccp(0,0))
	_bgLayer:addChild(_oppMenuBar)

	local bgLayerSize = _bgLayer:getContentSize()
	for index,h_tid in pairs(_t_hids) do
		local oppBtn =  CCMenuItemImage:create("images/shop/pub/card_opp.png", "images/shop/pub/card_opp.png")
		oppBtn:setAnchorPoint(ccp(0.5, 0.5))
		oppBtn:setPosition(MainScene.getMenuPositionInTruePoint(bgLayerSize.width*positionX[index], bgLayerSize.height*positionY[index]))
		oppBtn:setScale(0.5)
		oppBtn:registerScriptTapHandler(realRecruitAction)
		oppBtn:setVisible(false)
		_oppMenuBar:addChild(oppBtn, 1, index)
		table.insert(_allOppBtn, oppBtn)
	end
end

-- 招将
local function createDisplayCardsRecuitMenu( )
	local bgLayerSize = _bgLayer:getContentSize()
	-- 招将
	recruitMenuBar = CCMenu:create()
	recruitMenuBar:setPosition(ccp(0,0))
	_bgLayer:addChild(recruitMenuBar)

	local recruitBtn = CCMenuItemImage:create("images/shop/pub/btn_recruit_n.png", "images/shop/pub/btn_recruit_h.png")
	recruitBtn:setAnchorPoint(ccp(0.5, 0.5))
	recruitBtn:setPosition(MainScene.getMenuPositionInTruePoint(bgLayerSize.width*0.5, bgLayerSize.height*0.5))
	recruitBtn:registerScriptTapHandler(recruitAction)
	recruitMenuBar:addChild(recruitBtn)

end


-- 显示/隐藏名称
function delNamesBgSprite()
	for k,v in pairs(_nameBgArr) do
		v:removeFromParentAndCleanup(true)
		v=nil
	end
end

function showAnimation()
	if(_isShowEffect) then
		_isShowEffect = false
		displayHero()
		-- local spellEffectSprite = CCLayerSprite:layerSpriteWithName(CCString:create("images/base/effect/item/jinbizhaojiangbao"), -1,CCString:create(""));
	 --    spellEffectSprite:retain()
	 --    spellEffectSprite:setPosition(_fiveStarBg:getContentSize().width/2,_fiveStarBg:getContentSize().height/2)
	 --    _fiveStarBg:addChild(spellEffectSprite);
	 --    spellEffectSprite:release()

	 --    --delegate
	 --    -- 结束回调
	 --    local animation_1_End = function(actionName,xmlSprite)
	 --        spellEffectSprite:removeFromParentAndCleanup(true)
	 --        _guangSpriteEffect:setVisible(true)
		-- 	displayHero()
	 --    end
	 --    -- 每次回调
	 --    local animationFrameChanged = function(frameIndex,xmlSprite)
	        
	 --    end

	 --    --增加动画监听
	 --    local delegate = BTAnimationEventDelegate:create()
	 --    delegate:registerLayerEndedHandler(animation_1_End)
	 --    delegate:registerLayerChangedHandler(animationFrameChanged)
	 --    spellEffectSprite:setDelegate(delegate)
	end

end

-- create 
function createDisplayCards(isShow)
	isShow = isShow == nil and true or isShow
	
	local bgLayerSize = _bgLayer:getContentSize()
	

	_allHerosSp = {}
	_nameBgArr = {}
	for index,h_tid in pairs(_t_hids) do
		local hSprite = HeroPublicCC.createSpriteCardShow(tonumber(h_tid))
		hSprite:setAnchorPoint(ccp(0.5, 0.5))
		hSprite:setPosition(ccp(bgLayerSize.width*positionX[index], bgLayerSize.height*positionY[index]))
		hSprite:setScale(0.5)
		hSprite:setVisible(isShow)
		_bgLayer:addChild(hSprite, 3)
		table.insert(_allHerosSp, hSprite)

		-- 名称背景
		local nameBg = CCScale9Sprite:create("images/common/bg/bg_9s_2.png")
		nameBg:setContentSize(CCSizeMake(200, 37))
		nameBg:setAnchorPoint(ccp(0.5,0.5))
		nameBg:setPosition(ccp(bgLayerSize.width*positionX[index], bgLayerSize.height*(positionY[index] - 130.0/960)))
		_bgLayer:addChild(nameBg, 2)
		nameBg:setVisible(isShow)
		table.insert(_nameBgArr, nameBg)

		require "db/DB_Heroes"
		local heroLocalInfo = DB_Heroes.getDataById(tonumber(h_tid))
		-- 名称
		local nameColor = HeroPublicLua.getCCColorByStarLevel(heroLocalInfo.potential)
		local nameLabel = CCRenderLabel:create(heroLocalInfo.name, g_sFontPangWa, 25, 2, ccc3( 0x00, 0x00, 0x00), type_stroke)
	    nameLabel:setColor(nameColor)
	    nameLabel:setPosition(ccp(nameBg:getContentSize().width/2-nameLabel:getContentSize().width/2, nameBg:getContentSize().height*0.5+nameLabel:getContentSize().height*0.5))
	    nameBg:addChild(nameLabel)
	    table.insert(_nameLabelArr, nameLabel)

	end
end

function createFazhenEffect( )
    require "script/audio/AudioUtil"
    AudioUtil.playEffect("audio/effect/fazhengguang.mp3")
	_guangSpriteEffect = CCLayerSprite:layerSpriteWithName(CCString:create("images/base/effect/item/fazhengguang"), -1,CCString:create(""));
    _guangSpriteEffect:retain()
    _guangSpriteEffect:setScale(MainScene.bgScale/MainScene.elementScale)
    _guangSpriteEffect:setPosition(_bgLayer:getContentSize().width/2,_bgLayer:getContentSize().height/2)
    _bgLayer:addChild(_guangSpriteEffect)
    _guangSpriteEffect:release()
end

function create( )
	createDisplayCards()

	createDisplayCardsRecuitMenu( )
end

function createLayer( t_htids, select_htid )
	init()
	print_table("t_htids",t_htids)
	_t_hids = t_htids
	print("select_htid==", select_htid)
	_select_htid = tonumber(select_htid)
	_bgLayer = MainScene.createBaseLayer("images/shop/pub/pubbg.jpg", false, false, false)
	createFazhenEffect( )
	
	-- _fiveStarBg = CCSprite:create("images/shop/pub/fivestarbg.png")
	-- _fiveStarBg:setAnchorPoint(ccp(0.5,0.5))
	-- _fiveStarBg:setPosition(ccp(_bgLayer:getContentSize().width*0.493, _bgLayer:getContentSize().height*0.472))
	-- _bgLayer:addChild(_fiveStarBg)

	create()
	return _bgLayer
end


-- add by licong 2013.09.09
function registerDidClickZhaoJiangCallBack( callBack )
	didClickZhaoJiangFun = callBack
end
-----------------------------

