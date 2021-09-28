-- Filename：	EliteBorder.lua
-- Author：		Cheng Liang
-- Date：		2013-8-31
-- Purpose：		精英副本的信息

module ("EliteBorder", package.seeall)


require "script/utils/LuaUtil"
require "script/ui/item/ItemSprite"
require "script/ui/item/ItemUtil"
require "script/model/user/UserModel"
require "script/ui/tip/AnimationTip"
require "script/ui/copy/CopyUtil"


local _bgLayer = nil
local _bgSprite = nil
local _copyInfo = nil
local _strongHoldInfo = nil
local _dropItems = {}			-- 掉落物品
local fightBtn = nil

local function init()
	if(_bgLayer)then
		_bgLayer:removeFromParentAndCleanup(true)
		_bgLayer = nil
	end
	_bgLayer = nil
	_bgSprite = nil
	_copyInfo = nil
	_strongHoldInfo = nil
	_dropItems = {}			-- 掉落物品
	fightBtn = nil
end


--[[
 @desc	 处理touches事件
 @para 	 string event
 @return 
--]]
local function onTouchesHandler( eventType, x, y )
	
	if (eventType == "began") then
		print("began fortinfoLayer")
		
	    return true
    elseif (eventType == "moved") then
    	
    else
        print("end")
	end
end

--[[
 @desc	 回调onEnter和onExit时间
 @para 	 string event
 @return void
 --]]
local function onNodeEvent( event )
	if (event == "enter") then
		_bgLayer:registerScriptTouchHandler(onTouchesHandler, false, -410, true)
		_bgLayer:setTouchEnabled(true)
	elseif (event == "exit") then
		_bgLayer:unregisterScriptTouchHandler()
	end
end

-- 关闭
function closeAction( tag, itembtn )
	require "script/audio/AudioUtil"
	AudioUtil.playEffect("audio/effect/guanbi.mp3")
	_bgLayer:removeFromParentAndCleanup(true)
	_bgLayer = nil
end 

local function fightAction( tag, itembtn )
	---[==[精英副本 清除新手引导
	---------------------新手引导---------------------------------
	--add by licong 2013.09.26
	require "script/guide/NewGuide"
	if(NewGuide.guideClass == ksGuideEliteCopy) then
		require "script/guide/EliteCopyGuide"
		EliteCopyGuide.cleanLayer()
		NewGuide.guideClass = ksGuideClose
		NewGuide.saveGuideClass()
		BTUtil:setGuideState(false)
	end
	---------------------end-------------------------------------
	--]==]
	if(DataCache.getEliteCopyData().can_defeat_num <= 0)then
		AnimationTip.showTip(GetLocalizeStringBy("key_1005"))
	else
		if (_copyInfo.copyInfo.energy <= UserModel.getEnergyValue()) then
			require "script/battle/BattleLayer"
			local battleLayer = BattleLayer.enterBattle(_copyInfo.copyInfo.id, _copyInfo.copyInfo.baseids, 0, CopyLayer.doBattleCallback, 2)
			closeAction()
		else
			-- AnimationTip.showTip(GetLocalizeStringBy("key_1059"))
			require "script/ui/item/EnergyAlertTip"
			EnergyAlertTip.showTip()
		end
	end
end

local function createRewardItems()
	local item_count = 0
	for k,v in pairs(_dropItems) do
		item_count = item_count + 1
	end
	
	local height = 155
	if(item_count>10)then
		height = 460
	elseif(item_count>5)then
		height = 310
	else
		height = 155
	end

	local bgSpriteSize = _bgSprite:getContentSize()
	-- 掉落物品背景
	local bg_sprite_1 = CCScale9Sprite:create("images/common/bg/9s_1.png")
	bg_sprite_1:setContentSize(CCSizeMake(585, height))
	bg_sprite_1:setAnchorPoint(ccp(0.5, 1))
	-- bg_sprite_1:setScale(MainScene.elementScale)
	bg_sprite_1:setPosition(ccp(bgSpriteSize.width*0.5, bgSpriteSize.height - 200))
	_bgSprite:addChild(bg_sprite_1)
	-- 掉落标题
	local titleSprite = CCScale9Sprite:create("images/common/astro_labelbg.png")
	titleSprite:setContentSize(CCSizeMake(200, 35))
	titleSprite:setAnchorPoint(ccp(0.5, 0.5))
	-- titleSprite:setScale(MainScene.elementScale)
	titleSprite:setPosition(ccp(bg_sprite_1:getContentSize().width*0.5, bg_sprite_1:getContentSize().height))
	bg_sprite_1:addChild(titleSprite)
	-- 标题文字
	local titleLabel = CCRenderLabel:create(GetLocalizeStringBy("key_1322"), g_sFontPangWa, 24, 1, ccc3( 0x00, 0x00, 0x00), type_stroke)
    titleLabel:setColor(ccc3(0xff, 0xe4, 0x00))
    titleLabel:setPosition(ccp(titleSprite:getContentSize().width*0.5 - titleLabel:getContentSize().width*0.5, titleSprite:getContentSize().height*0.5 + titleLabel:getContentSize().height*0.5))
    titleSprite:addChild(titleLabel)

    local xPositionScale = {0.1, 0.3, 0.5, 0.7, 0.9, 0.1, 0.3, 0.5, 0.7, 0.9, 0.1, 0.3, 0.5, 0.7, 0.9}
    local yPosition = {70, 70, 70, 70, 70, 220, 220, 220, 220, 220, 370, 370, 370, 370, 370}
    
    -- 物品展示
    for index,item_tmpl_id in pairs(_dropItems) do
    	index = tonumber(index)
    	-- item_tmpl_id = 102322
    	local itemBtn = ItemSprite.getItemSpriteById(tonumber(item_tmpl_id), nil, nil, false, -420)
    	itemBtn:setAnchorPoint(ccp(0.5, 0.5))
    	itemBtn:setPosition(ccp(bg_sprite_1:getContentSize().width*xPositionScale[index], bg_sprite_1:getContentSize().height - yPosition[index]))
    	bg_sprite_1:addChild(itemBtn)

    	local itemDesc = ItemUtil.getItemById(item_tmpl_id)
    	local nameColor = HeroPublicLua.getCCColorByStarLevel(itemDesc.quality)
    	local nameLabel = CCRenderLabel:create(itemDesc.name, g_sFontName, 18, 1, ccc3( 0x00, 0x00, 0x00), type_stroke)
	    nameLabel:setColor(nameColor)
	    nameLabel:setPosition(ccp(itemBtn:getContentSize().width*0.5 - nameLabel:getContentSize().width*0.5, 0))
	    itemBtn:addChild(nameLabel)

    end

end

-- 硬币 经验 将魂 三种固定奖励
local function create3Reward()
	local bgSpriteSize = _bgSprite:getContentSize()

	-- 银币奖励
    local bg_sprite_1 = CCScale9Sprite:create("images/common/bg/9s_2.png")
	bg_sprite_1:setContentSize(CCSizeMake(165, 33))
	bg_sprite_1:setAnchorPoint(ccp(0.5, 1))
	-- bg_sprite_1:setScale(MainScene.elementScale)
	bg_sprite_1:setPosition(ccp(370, bgSpriteSize.height - 75))
	_bgSprite:addChild(bg_sprite_1)
	-- 银币图标
	local coin_sp = CCSprite:create("images/common/coin.png")
	coin_sp:setAnchorPoint(ccp(0, 0.5))
	coin_sp:setPosition(ccp(5, bg_sprite_1:getContentSize().height*0.5))
	bg_sprite_1:addChild(coin_sp)
	local coin_num = _strongHoldInfo.coin_simple or 0
	-- 硬币数量
	local coingLabel = CCRenderLabel:create(coin_num, g_sFontName, 20, 1, ccc3( 0x00, 0x00, 0x00), type_stroke)
    coingLabel:setColor(ccc3(0xff, 0xff, 0xff))
    coingLabel:setPosition(ccp(65, bg_sprite_1:getContentSize().height*0.5 + coingLabel:getContentSize().height*0.5))
    bg_sprite_1:addChild(coingLabel)

	-- -- 经验奖励
 --    local bg_sprite_2 = CCScale9Sprite:create("images/common/bg/9s_2.png")
	-- bg_sprite_2:setContentSize(CCSizeMake(165, 33))
	-- bg_sprite_2:setAnchorPoint(ccp(0.5, 1))
	-- bg_sprite_2:setPosition(ccp(370, bgSpriteSize.height - 145))
	-- _bgSprite:addChild(bg_sprite_2)
	-- -- 经验图标
	-- local exp_sp = CCSprite:create("images/common/exp.png")
	-- exp_sp:setAnchorPoint(ccp(0, 0.5))
	-- exp_sp:setPosition(ccp(5, bg_sprite_2:getContentSize().height*0.5))
	-- bg_sprite_2:addChild(exp_sp)
	-- -- 经验数量
	-- local coin_num = _strongHoldInfo.exp_simple or 0
	-- local expLabel = CCRenderLabel:create(coin_num, g_sFontName, 20, 1, ccc3( 0x00, 0x00, 0x00), type_stroke)
 --    expLabel:setColor(ccc3(0xff, 0xff, 0xff))
 --    expLabel:setPosition(ccp(65, bg_sprite_2:getContentSize().height*0.5 + expLabel:getContentSize().height*0.5))
 --    bg_sprite_2:addChild(expLabel)

    -- 将魂奖励
    local bg_sprite_3 = CCScale9Sprite:create("images/common/bg/9s_2.png")
	bg_sprite_3:setContentSize(CCSizeMake(165, 33))
	bg_sprite_3:setAnchorPoint(ccp(0.5, 1))
	bg_sprite_3:setPosition(ccp(370, bgSpriteSize.height - 110))
	_bgSprite:addChild(bg_sprite_3)
	-- 将魂图标
	local exp_sp = CCSprite:create("images/common/icon_soul.png")
	exp_sp:setAnchorPoint(ccp(0, 0.5))
	exp_sp:setPosition(ccp(5, bg_sprite_3:getContentSize().height*0.5))
	bg_sprite_3:addChild(exp_sp)
	-- 将魂数量
	local coin_num = _strongHoldInfo.soul_simple or 0
	local expLabel = CCRenderLabel:create(coin_num, g_sFontName, 20, 1, ccc3( 0x00, 0x00, 0x00), type_stroke)
    expLabel:setColor(ccc3(0xff, 0xff, 0xff))
    expLabel:setPosition(ccp(65, bg_sprite_3:getContentSize().height*0.5 + expLabel:getContentSize().height*0.5))
    bg_sprite_3:addChild(expLabel)

end

local function createBgSprite()

	local item_count = 0
	print("_strongHoldInfo.reward_item_id_simple==", _strongHoldInfo.reward_item_id_simple)
	_dropItems = {}
	if(_strongHoldInfo.reward_item_id_simple)then
		_dropItems = CopyUtil.parseItemDropString( _strongHoldInfo.reward_item_id_simple )
		for k,v in pairs(_dropItems) do
			item_count = item_count + 1
		end
	end


	local height = 630 - 155
	if(item_count>10)then
		height = 780
	elseif(item_count>5)then
		height = 630
	else
		height = 630 - 155
	end
	-- 背景
	_bgSprite = CCScale9Sprite:create("images/common/viewbg1.png")
	_bgSprite:setContentSize(CCSizeMake(630, height))
	_bgSprite:setAnchorPoint(ccp(0.5,0.5))
	_bgSprite:setScale(MainScene.elementScale)
	_bgSprite:setPosition(ccp(_bgLayer:getContentSize().width*0.5, _bgLayer:getContentSize().height*0.5))
	_bgLayer:addChild(_bgSprite)

	local bgSpriteSize = _bgSprite:getContentSize()

	-- 彩色sprite
	local t_sprite = CCSprite:create("images/copy/border.png")
	t_sprite:setAnchorPoint(ccp(0.5,1))
	t_sprite:setPosition(ccp(bgSpriteSize.width*0.5, bgSpriteSize.height - 15))
	_bgSprite:addChild(t_sprite)

	-- 关闭按钮bar
	local closeMenuBar = CCMenu:create()
	closeMenuBar:setPosition(ccp(0, 0))
	_bgSprite:addChild(closeMenuBar)
	closeMenuBar:setTouchPriority(-411)
	-- 关闭按钮
	local closeBtn = LuaMenuItem.createItemImage("images/common/btn_close_n.png", "images/common/btn_close_h.png")
	closeBtn:setAnchorPoint(ccp(0.5, 0.5))
	closeBtn:registerScriptTapHandler(closeAction)
    closeBtn:setPosition(ccp(_bgSprite:getContentSize().width*0.95, _bgSprite:getContentSize().height*0.98))
	closeMenuBar:addChild(closeBtn)

	-- icon
	local potentialSprite = CCSprite:create("images/copy/ncopy/fortpotential/3.png")
	potentialSprite:setAnchorPoint(ccp(0.5, 1))
	potentialSprite:setPosition(ccp(160, bgSpriteSize.height - 30))
	_bgSprite:addChild(potentialSprite)
	-- 图片 
	local icon_sp = CCSprite:create("images/base/hero/head_icon/" .. _strongHoldInfo.icon)
	icon_sp:setAnchorPoint(ccp(0.5, 0.5))
	icon_sp:setPosition(ccp(potentialSprite:getContentSize().width * 0.5, potentialSprite:getContentSize().height *0.53))
	potentialSprite:addChild(icon_sp)

	-- 名称背景
    local nameBg = CCSprite:create("images/copy/ecopy/namebg.png" )
    nameBg:setAnchorPoint(ccp(0.5, 1))
    nameBg:setPosition(ccp(370, bgSpriteSize.height - 30))
    _bgSprite:addChild(nameBg)
    --副本名称
    local nameSpriteIcon = "images/copy/ecopy/nameimage/" .. _copyInfo.copyInfo.image
    local nameSprite = CCSprite:create(nameSpriteIcon)
    nameSprite:setAnchorPoint(ccp(0.5,0.5))
    nameSprite:setPosition(nameBg:getContentSize().width/2, nameBg:getContentSize().height/2);
    nameBg:addChild(nameSprite)

	-- 战斗
	local fightMenuBar = CCMenu:create()
	fightMenuBar:setPosition(ccp(0, 0))
	_bgSprite:addChild(fightMenuBar)
	fightMenuBar:setTouchPriority(-411)
	-- 战斗按钮
	fightBtn = LuaCC.create9ScaleMenuItem("images/common/btn/btn_red2_n.png","images/common/btn/btn_red2_h.png",CCSizeMake(225, 83),GetLocalizeStringBy("key_2565"),ccc3(0xfe, 0xdb, 0x1c),35,g_sFontPangWa,1, ccc3(0x00, 0x00, 0x00))
	fightBtn:setAnchorPoint(ccp(0.5, 0))
	fightBtn:setPosition(ccp(bgSpriteSize.width*0.5, 23))
	fightBtn:registerScriptTapHandler(fightAction)
	fightMenuBar:addChild(fightBtn, 2, 10001)

-- 硬币 经验 将魂 三种固定奖励
	create3Reward()

	createRewardItems()
end


-- 创建
function createLayer( copyInfo )

	_copyInfo = copyInfo
	require "db/DB_Stronghold"
	_strongHoldInfo = DB_Stronghold.getDataById(_copyInfo.copyInfo.baseids)
	

	
	_bgLayer = CCLayerColor:create(ccc4(0,0,0,155))
	_bgLayer:registerScriptHandler(onNodeEvent)

	createBgSprite()

	-- 精英副本 新手
	local seq = CCSequence:createWithTwoActions(CCDelayTime:create(0.3),CCCallFunc:create(function ( ... )
			addGuideEliteCopyGuide4()
		end))
	_bgLayer:runAction(seq)

	return _bgLayer

end


-- 新手引导用
function getGuideObject()
	return fightBtn
end


---[==[精英副本 第4步
---------------------新手引导---------------------------------
function addGuideEliteCopyGuide4( ... )
	require "script/guide/NewGuide"
	require "script/guide/EliteCopyGuide"
    if(NewGuide.guideClass ==  ksGuideEliteCopy and EliteCopyGuide.stepNum == 3) then
        local eliteButton = getGuideObject()
        local touchRect   = getSpriteScreenRect(eliteButton)
        EliteCopyGuide.show(4, touchRect)
    end
end
---------------------end-------------------------------------
--]==]

