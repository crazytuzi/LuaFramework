-- Filename：	HeroFortInfoLayer.lua
-- Author：		LLP
-- Date：		2014-4-23
-- Purpose：		列传据点的信息

module ("HeroFortInfoLayer", package.seeall)



require "script/utils/LuaUtil"
require "script/ui/item/ItemSprite"
require "script/ui/item/ItemUtil"
require "script/model/user/UserModel"
require "script/ui/tip/AnimationTip"
require "script/ui/copy/CopyUtil"
require "script/ui/heroCpy/HeroFortItemSprite"
require "script/ui/copy/Fight10Border"


local _bgLayer 			= nil
local _bgColorLayer 	= nil
local _bgSprite 		= nil
local _copyInfo 		= nil
local _strongHoldInfo 	= nil
local _dropItems 		= {}			-- 掉落物品

local max_hard_lv		= nil			-- 当前可攻打的最大难度
local curBaseStars 		= nil			-- 当前据点所获得的星数
local curCopyId 		= nil
local curFortId			= nil

local totalStars 		= 0 			-- 几颗心心
local _progressState 	= nil
local _bodyCost 		= nil
local _simpleSprite 	= nil

local _coolTimeLabelArr = {}
local _coolTitleArr 	= {}
local _coolCostLabelArr = {}
local hardBgSprite 		= nil
local _defeat_num 		= 0
local _displayDefeatNum = 0
local _hardLevel			= 0
local _newData 			= {}

local function init()
	_bgLayer 			= nil
	_bgColorLayer 		= nil
	_bgSprite 			= nil
	_copyInfo 			= nil
	_strongHoldInfo 	= nil
	_dropItems 			= {}			-- 掉落物品
	max_hard_lv 		= nil
	curBaseStars 		= nil			-- 当前据点所获得的星数
	curCopyId 			= nil
	curFortId			= nil
	totalStars 			= 0 			-- 几颗心心
	_progressState 		= nil
	_bodyCost 			= nil
	_simpleSprite 		= nil
	_coolTimeLabelArr 	= {}
	_coolTitleArr 		= {}
	_coolCostLabelArr 	= {}
	hardBgSprite 		= nil
	_defeat_num 		= 0
	_displayDefeatNum 	= 0
	_newData 			= {}
	_hardLevel 			= 0
end


--[[
 @desc	 处理touches事件
 @para 	 string event
 @return
--]]
local function onTouchesHandler( eventType, x, y )

	if (eventType == "began") then
		print("began herofortinfoLayer")

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

local function onTipNodeEvent( event )
	if (event == "enter") then
		_bgColorLayer:registerScriptTouchHandler(onTouchesHandler, false, -410, true)
		_bgColorLayer:setTouchEnabled(true)
	elseif (event == "exit") then
		_bgColorLayer:unregisterScriptTouchHandler()
	end
end


-- 关闭
function closeAction( tag, itembtn )
	require "script/audio/AudioUtil"
	AudioUtil.playEffect("audio/effect/guanbi.mp3")
	if(_bgLayer ~= nil)then
		_bgLayer:removeFromParentAndCleanup(true)
		_bgLayer = nil
	end
end

function closeTipAction()
	require "script/audio/AudioUtil"
	AudioUtil.playEffect("audio/effect/guanbi.mp3")
	if(_bgColorLayer ~= nil)then
		_bgColorLayer:removeFromParentAndCleanup(true)
		_bgColorLayer = nil
	end
end


-- 创建奖励
local function createRewardItems()

	-- local drop_height = 155
	-- if(#_dropItems > 5 )then
	-- 	drop_height = 280
	-- end

	-- local bgSpriteSize = _bgSprite:getContentSize()
	-- -- 掉落物品背景
	-- local bg_sprite_1 = CCScale9Sprite:create("images/common/bg/9s_1.png")
	-- bg_sprite_1:setContentSize(CCSizeMake(585, drop_height))
	-- bg_sprite_1:setAnchorPoint(ccp(0.5, 1))
	-- -- bg_sprite_1:setScale(MainScene.elementScale)
	-- bg_sprite_1:setPosition(ccp(bgSpriteSize.width*0.5, bgSpriteSize.height - 215))
	-- _bgSprite:addChild(bg_sprite_1)
	-- -- 掉落标题
	-- local titleSprite = CCScale9Sprite:create("images/common/astro_labelbg.png")
	-- titleSprite:setContentSize(CCSizeMake(200, 35))
	-- titleSprite:setAnchorPoint(ccp(0.5, 0.5))
	-- -- titleSprite:setScale(MainScene.elementScale)
	-- titleSprite:setPosition(ccp(bg_sprite_1:getContentSize().width*0.5, bg_sprite_1:getContentSize().height))
	-- bg_sprite_1:addChild(titleSprite)
	-- -- 标题文字
	-- local titleLabel = CCRenderLabel:create(GetLocalizeStringBy("key_1322"), g_sFontPangWa, 24, 1, ccc3( 0x00, 0x00, 0x00), type_stroke)
 --    titleLabel:setColor(ccc3(0xff, 0xe4, 0x00))
 --    titleLabel:setPosition(ccp(titleSprite:getContentSize().width*0.5 - titleLabel:getContentSize().width*0.5, titleSprite:getContentSize().height*0.5 + titleLabel:getContentSize().height*0.5))
 --    titleSprite:addChild(titleLabel)

 --    local xPositionScale = {0.1, 0.3, 0.5, 0.7, 0.9, 0.1, 0.3, 0.5, 0.7, 0.9}
 --    local yPosition = {70, 70, 70, 70, 70, 200, 200, 200, 200, 200}

 --    -- 物品展示
 --    for index,item_tmpl_id in pairs(_dropItems) do
 --    	index = tonumber(index)
 --    	-- item_tmpl_id = 102322
 --    	local itemBtn = ItemSprite.getItemSpriteById(tonumber(item_tmpl_id), nil, nil, false, -420)
 --    	itemBtn:setAnchorPoint(ccp(0.5, 0.5))
 --    	itemBtn:setPosition(ccp(bg_sprite_1:getContentSize().width*xPositionScale[index], bg_sprite_1:getContentSize().height - yPosition[index]))
 --    	bg_sprite_1:addChild(itemBtn)

 --    	local itemDesc = ItemUtil.getItemById(item_tmpl_id)
 --    	local nameColor = HeroPublicLua.getCCColorByStarLevel(itemDesc.quality)
 --    	local nameLabel = CCRenderLabel:create(itemDesc.name, g_sFontName, 18, 1, ccc3( 0x00, 0x00, 0x00), type_stroke)
	--     nameLabel:setColor(nameColor)
	--     nameLabel:setPosition(ccp(itemBtn:getContentSize().width*0.5 - nameLabel:getContentSize().width*0.5, 0))
	--     itemBtn:addChild(nameLabel)

 --    end

end


-- 创建三种难度
local function createHardDegree()

	local height = 400 - (3-1) * 130+5
	local yDistance = 220

	-- if(#_dropItems > 5 )then
	-- 	yDistance = 500
	-- end

	-- if(_strongHoldInfo.reward_item_id_simple == nil) then
	-- 	yDistance = yDistance - 155
	-- end


	if(hardBgSprite)then
		hardBgSprite:removeFromParentAndCleanup(true)
		hardBgSprite = nil
	end

	hardBgSprite = CCScale9Sprite:create("images/common/bg/bg_ng_attr.png")
	hardBgSprite:setContentSize(CCSizeMake(585, height))
	hardBgSprite:setAnchorPoint(ccp(0.5, 1))
	hardBgSprite:setPosition(ccp(_bgSprite:getContentSize().width*0.5, _bgSprite:getContentSize().height-yDistance))
	_bgSprite:addChild(hardBgSprite)

	_coolTimeLabelArr 	= {}

	local hardBgSpriteSize = hardBgSprite:getContentSize()
	print("_htid====".._progressState)
	-- local hard = getHardLvByHTidAndHCopyId(_displayDefeatNum,curCopyId)
	-- print("hardhardhard===="..hard)
		local spriteTemp = HeroFortItemSprite.createSprite( _hardLevel, _strongHoldInfo)
		spriteTemp:setAnchorPoint(ccp(0.5, 1))
		spriteTemp:setPosition(ccp(hardBgSpriteSize.width*0.5, height - 3) )
		hardBgSprite:addChild(spriteTemp)
		_simpleSprite = spriteTemp

	-- if( DataCache.getSweepCoolTime() and (DataCache.getSweepCoolTime() - TimeUtil.getSvrTimeByOffset() ) > 0 )then
	-- 	cdTimeFunc()
	-- end

end

-- 刷新
function cdTimeFunc()

end

-- 创建背景
local function createBgSprite()

	local drop_height = 0
	-- if(#_dropItems > 5 )then
	-- 	drop_height = 280
	-- end

	local height = 665 + drop_height-(3-1) * 130

	-- if(_strongHoldInfo.reward_item_id_simple == nil) then
	-- 	height = height - drop_height
	-- end

	-- 背景
	_bgSprite = CCScale9Sprite:create("images/common/viewbg1.png")
	_bgSprite:setContentSize(CCSizeMake(630, height))
	_bgSprite:setAnchorPoint(ccp(0.5,0.5))
	_bgSprite:setScale(MainScene.elementScale)
	_bgSprite:setPosition(ccp(_bgLayer:getContentSize().width*0.5, _bgLayer:getContentSize().height*0.5-10))
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
	local closeBtn = LuaMenuItem.createItemImage("images/common/btn_close_n.png", "images/common/btn_close_h.png", closeAction )
	closeBtn:setAnchorPoint(ccp(0.5, 0.5))
    closeBtn:setPosition(ccp(_bgSprite:getContentSize().width*0.95, _bgSprite:getContentSize().height*0.98))
	closeMenuBar:addChild(closeBtn)
	local _strongHoldInfo = DB_Stronghold.getDataById(tonumber(curFortId))
	-- icon
	local copyFileLua = "db/heroCXml/hero_" .. curCopyId
	require (copyFileLua)
	local pngIndex = nil
	for k,fortInfo in pairs(HeroCXml.models.normal) do
		-- print("baseid == " .. curFortId .. " , fortInfo.looks.look.armyID == " .. fortInfo.looks.look.armyID)
		if ( tonumber(curFortId) == tonumber(fortInfo.looks.look.armyID)) then
			pngIndex = string.sub(fortInfo.looks.look.modelURL, 1, 1)
			break
		end
	end
	local potentialSprite = CCSprite:create("images/copy/ncopy/fortpotential/" .. pngIndex .. ".png")
	potentialSprite:setAnchorPoint(ccp(0.5, 1))
	potentialSprite:setPosition(ccp(160, bgSpriteSize.height - 30))
	_bgSprite:addChild(potentialSprite)
	-- 图片
	local icon_sp = CCSprite:create("images/base/hero/head_icon/" .. _strongHoldInfo.icon)
	icon_sp:setAnchorPoint(ccp(0.5, 0.5))
	icon_sp:setPosition(ccp(potentialSprite:getContentSize().width * 0.5, potentialSprite:getContentSize().height *0.53))
	potentialSprite:addChild(icon_sp)

	-- 名称背景
    local nameBgSprite = CCSprite:create("images/common/namebg.png" )
    nameBgSprite:setAnchorPoint(ccp(0.5, 1))
    nameBgSprite:setPosition(ccp(370, bgSpriteSize.height - 50))
    _bgSprite:addChild(nameBgSprite)
    --副本名称
    local baseNameLabel = CCRenderLabel:create(_strongHoldInfo.name, g_sFontPangWa, 33, 3, ccc3( 0x00, 0x00, 0x00), type_stroke)
    baseNameLabel:setColor(ccc3( 0xff, 0xe4, 0x00))
    baseNameLabel:setPosition(ccp( (nameBgSprite:getContentSize().width - baseNameLabel:getContentSize().width)/2,
    			(nameBgSprite:getContentSize().height - (nameBgSprite:getContentSize().height - baseNameLabel:getContentSize().height)/2) ))
    nameBgSprite:addChild(baseNameLabel)

    -- 体力
	local energyLabel = CCRenderLabel:create(GetLocalizeStringBy("key_1299") .. _strongHoldInfo.cost_energy_simple, g_sFontName, 24, 1, ccc3( 0x00, 0x00, 0x00), type_stroke)
    energyLabel:setColor(ccc3(0x8a, 0xff, 0x00))
    energyLabel:setAnchorPoint(ccp(0, 0.5))
    energyLabel:setPosition(ccp( 420, bgSpriteSize.height - 170))
    _bgSprite:addChild(energyLabel)
end

-- 处理数据
local function handleData( )

	-- -- 据点信息
	-- _strongHoldInfo = DB_Stronghold.getDataById(tonumber(curFortId))

	-- -- 当前星数和难度
	-- if (_progressState <= 2) then
	-- 	max_hard_lv = 1

	-- elseif (_progressState == 3) then
	-- 	max_hard_lv = 2

	-- elseif (_progressState == 4) then
	-- 	max_hard_lv = 3

	-- elseif (_progressState == 5) then
	-- 	max_hard_lv = 3

	-- else
	-- 	max_hard_lv = 1

	-- end

	-- -- 算总星星
	-- if(_strongHoldInfo.npc_army_ids_simple or _strongHoldInfo.army_ids_simple)then
	-- 	totalStars = totalStars + 1
	-- end
	-- if(_strongHoldInfo.army_num_normal)then
	-- 	totalStars = totalStars + 1
	-- end
	-- if(_strongHoldInfo.army_ids_hard)then
	-- 	totalStars = totalStars + 1
	-- end

	--
	-- _dropItems = {}
 --    if(_strongHoldInfo.reward_item_id_simple)then
	-- 	_dropItems = CopyUtil.parseItemDropString( _strongHoldInfo.reward_item_id_simple )
	-- end

end

-- 某个武将的副本难度
function getHardLvByHTidAndHCopyId( h_tid, copy_id )
	local hardLevel = nil

	require "db/DB_Heroes"
	local heroInfo = DB_Heroes.getDataById(h_tid)
	if(heroInfo.hero_copy_id)then
		local copy_ids = string.split(heroInfo.hero_copy_id, ",")
		for k,type_copy in pairs(copy_ids) do
			local type_copy_arr = string.split(type_copy, "|")
			if(tonumber(copy_id) == tonumber(type_copy_arr[1])  )then
				hardLevel = tonumber(type_copy_arr[2])
				break
			end
		end
	end

	return hardLevel
end

local function showTips( htid,hardLevel,addNum )
	-- body
	print("!!!!@@@####$$$%%%%")
	_bgColorLayer = CCLayerColor:create(ccc4(0,0,0,155))
	_bgColorLayer:registerScriptHandler(onTipNodeEvent)
	local runningScene = CCDirector:sharedDirector():getRunningScene()
	runningScene:addChild(_bgColorLayer, 2000)


	-- 背景
	local fullRect = CCRectMake(0,0,213,171)
	local insetRect = CCRectMake(50,50,113,71)
	local tipSprite = CCScale9Sprite:create("images/common/viewbg1.png", fullRect, insetRect)
	tipSprite:setPreferredSize(CCSizeMake(520, 360))
	tipSprite:setAnchorPoint(ccp(0.5, 0.5))
	tipSprite:setPosition(ccp(_bgColorLayer:getContentSize().width*0.5, _bgColorLayer:getContentSize().height*0.5))
	_bgColorLayer:addChild(tipSprite)
	tipSprite:setScale(g_fScaleX)

	local alertBgSize = tipSprite:getContentSize()

    --
    local innerSprite = CCScale9Sprite:create("images/common/bg/bg_ng_attr.png")
	innerSprite:setContentSize(CCSizeMake(450, 210))
	innerSprite:setAnchorPoint(ccp(0.5, 0.5))
	innerSprite:setPosition(ccp(tipSprite:getContentSize().width*0.5,tipSprite:getContentSize().height*0.6))
	tipSprite:addChild(innerSprite)

	-- 武将头像
	local heroIcon = HeroUtil.getHeroIconByHTID(htid)
	heroIcon:setAnchorPoint(ccp(0, 0))
	heroIcon:setPosition(ccp(25, 50))
	innerSprite:addChild(heroIcon)
	local heroDB = DB_Heroes.getDataById(htid)
	-- 名称
	local nameColor = HeroPublicLua.getCCColorByStarLevel(heroDB.potential)
	local nameLabel = CCLabelTTF:create(heroDB.name, g_sFontPangWa, 18)
	nameLabel:setColor(nameColor)
	nameLabel:setAnchorPoint(ccp(0.5, 1))
	nameLabel:setPosition(ccp(heroIcon:getContentSize().width*0.5, heroIcon:getContentSize().height*0))
	heroIcon:addChild(nameLabel)

	-- 通关文字

	-- 简单绿 普通黄 困难红
	local hardFont = {GetLocalizeStringBy("lic_1036"), GetLocalizeStringBy("lic_1037"), GetLocalizeStringBy("lic_1038")}
	local hardColor = {ccc3(0x00,0xff,0x18), ccc3(0xff,0xf6,0x00), ccc3(0xe8,0x00,0x00)}

	-- 第一行
	local oneStr1 = GetLocalizeStringBy("lic_1039")
	local oneStr2 = heroDB.name
	local oneStr3 = GetLocalizeStringBy("lic_1040")
	local oneStr4 = hardFont[tonumber(hardLevel)]
	local oneStr5 = GetLocalizeStringBy("lic_1041")
	local oneFont1 = CCLabelTTF:create(oneStr1, g_sFontPangWa, 23)
	oneFont1:setColor(ccc3(0xff, 0xff, 0xff))
	oneFont1:setAnchorPoint(ccp(0, 0))
	oneFont1:setPosition(ccp(135, 130))
	innerSprite:addChild(oneFont1)
	local oneFont2 = CCLabelTTF:create(oneStr2, g_sFontPangWa, 23)
	oneFont2:setColor(nameColor)
	oneFont2:setAnchorPoint(ccp(0, 0))
	oneFont2:setPosition(ccp(oneFont1:getPositionX()+oneFont1:getContentSize().width, oneFont1:getPositionY()))
	innerSprite:addChild(oneFont2)
	local oneFont3 = CCLabelTTF:create(oneStr3, g_sFontPangWa, 23)
	oneFont3:setColor(ccc3(0xff, 0xff, 0xff))
	oneFont3:setAnchorPoint(ccp(0, 0))
	oneFont3:setPosition(ccp(oneFont2:getPositionX()+oneFont2:getContentSize().width, oneFont1:getPositionY()))
	innerSprite:addChild(oneFont3)
	local oneFont4 = CCLabelTTF:create(oneStr4, g_sFontPangWa, 23)
	oneFont4:setColor(hardColor[tonumber(hardLevel)])
	oneFont4:setAnchorPoint(ccp(0, 0))
	oneFont4:setPosition(ccp(oneFont3:getPositionX()+oneFont3:getContentSize().width, oneFont1:getPositionY()))
	innerSprite:addChild(oneFont4)
	local oneFont5 = CCLabelTTF:create(oneStr5, g_sFontPangWa, 23)
	oneFont5:setColor(ccc3(0xff, 0xff, 0xff))
	oneFont5:setAnchorPoint(ccp(0, 0))
	oneFont5:setPosition(ccp(oneFont4:getPositionX()+oneFont4:getContentSize().width, oneFont1:getPositionY()))
	innerSprite:addChild(oneFont5)

	-- 第三行
	-- local threeStr1 = heroDB.name
	-- local threeStr2 = GetLocalizeStringBy("lic_1043") .. addnum
	local threeStr3 = GetLocalizeStringBy("llp_96")
	-- local threeFont1 = CCLabelTTF:create(threeStr1, g_sFontPangWa, 23)
	-- threeFont1:setColor(nameColor)
	-- threeFont1:setAnchorPoint(ccp(0, 0))
	-- threeFont1:setPosition(ccp(135, 30))
	-- innerSprite:addChild(threeFont1)
	-- local threeFont2 = CCLabelTTF:create(threeStr2, g_sFontPangWa, 23)
	-- threeFont2:setColor(ccc3(0xff,0xff,0xff))
	-- threeFont2:setAnchorPoint(ccp(0, 0))
	-- threeFont2:setPosition(ccp(threeFont1:getPositionX()+threeFont1:getContentSize().width, threeFont1:getPositionY()))
	-- innerSprite:addChild(threeFont2)
	local threeFont3 = CCLabelTTF:create(threeStr3, g_sFontPangWa, 23)
	threeFont3:setColor(ccc3(0xff,0xff,0xff))
	threeFont3:setAnchorPoint(ccp(0, 0))
	threeFont3:setPosition(ccp(135, 80))
	innerSprite:addChild(threeFont3)
	local sprite = CCSprite:create("images/biography/awaken" .. hardLevel .. ".png")
	sprite:setAnchorPoint(ccp(0,0))
	sprite:setPosition(ccp(135, 30))
	innerSprite:addChild(sprite)

	-- 按钮
	local menuBar = CCMenu:create()
	menuBar:setPosition(ccp(0,0))
	menuBar:setTouchPriority(-5602)
	tipSprite:addChild(menuBar)

	-- 确认
	require "script/libs/LuaCC"
	local confirmBtn = LuaCC.create9ScaleMenuItem("images/star/intimate/btn_blue_n.png", "images/star/intimate/btn_blue_h.png",CCSizeMake(160, 70), GetLocalizeStringBy("key_8022"), ccc3(0xfe, 0xdb, 0x1c),30,g_sFontPangWa,1, ccc3(0x00, 0x00, 0x00))
	confirmBtn:setAnchorPoint(ccp(0.5, 0.5))
    confirmBtn:registerScriptTapHandler(closeTipAction)
	menuBar:addChild(confirmBtn, 1, 10001)
	confirmBtn:setPosition(ccp(alertBgSize.width*0.5, alertBgSize.height*0.2))
end

local function refreshFortsInfoLayer()
	local data = _newData
	if(tonumber(data.hero_copy.finish_num) > 0)then
		-- 已经通关
		print(">0")
		-- _bgLayer:setVisible(true)
		require "db/DB_Hero_copy"
		local htid = DB_Hero_copy.getDataById(data.hero_copy.copyid).hero_id
		local hardLevel = _hardLevel
		require "script/ui/star/StarUtil"
		DataCache.addPassHeroCopyTimesBy(htid, data.hero_copy.copyid, tonumber(data.hero_copy.level))
		-- HeroLayout.closeFortsLayoutAction()
		-- AnimationTip.showTip(GetLocalizeStringBy("key_1103"))
		local addNum = 0
		require "db/DB_Heroes"
		local heroInfo = DB_Heroes.getDataById(htid)
		if(heroInfo.hero_copy_id)then
			local copy_ids = string.split(heroInfo.hero_copy_id, ",")
			for k,type_copy in pairs(copy_ids) do
				local type_copy_arr = string.split(type_copy, "|")
				if(tonumber(data.hero_copy.copyid) == tonumber(type_copy_arr[1])  )then
					addNum = tonumber(type_copy_arr[3])
					break
				end
			end
		end
		require "script/ui/heroCpy/PassHeroCopyLayer"
		PassHeroCopyLayer.showLayer(htid,hardLevel,addNum)
		print("!!!@@@###~~~~~~~~",HeroUtil.couldActivateTalent(tostring(htid),hardLevel))
        if(HeroUtil.couldActivateTalent(tostring(htid),hardLevel)==true)then
            showTips(htid,hardLevel,addNum)
        end
		_bgLayer:removeFromParentAndCleanup(true)
		_bgLayer = nil
	else
		print("<0")

		print("wandanle")
		local htid = DB_Hero_copy.getDataById(data.hero_copy.copyid).hero_id
		print("htid,tonumber(data.hero_copy.level)"..htid..tonumber(data.hero_copy.level))
		require "db/DB_Hero_copy"
		print_t(data.hero_copy)
		_bgLayer:removeFromParentAndCleanup(true)
		_bgLayer = nil
		require "script/ui/heroCpy/HeroLayout"
		local fortsLayer = HeroLayout.createFortsLayout(data.hero_copy,htid,tonumber(data.hero_copy.level))
		MainScene.changeLayer(fortsLayer, "fortsLayer")

	end

end

-- 战10次回调
function fight10Callback( cbFlag, dictData, bRet )

end

-- 战10次
function fight10Action( tag, itemBtn )

end

-- 战斗回调
function doBattleCallback( newData, isVictory, extra_reward, extra_info )
	-- if(newData.ret~="ok")then
	-- 	return
	-- end
	local isHaveTalk = false
    _newData = newData
	local isHadVictory = CopyUtil.isHeroStrongHoldIsVict(curFortId)
	local _strongHoldInfo = DB_Stronghold.getDataById(tonumber(curFortId))
	print("HeroFortInfoLayer=====curFortId"..curFortId)

	print("HeroFortInfoLayer=====curFortId"..curFortId)
	if(isVictory and (not isHadVictory)) then
		-- 对话
		print("HeroFortInfoLayer1")
	    if(_strongHoldInfo.victor_dialog_id and tonumber(_strongHoldInfo.victor_dialog_id) > 0 and (not CopyUtil.isFortIdVicHadDisplay(_strongHoldInfo.id)))then
	    	print("HeroFortInfoLayer2")
	    	CopyUtil.addHadVicDialogFortId(curFortId)
	    	require "script/ui/talk/talkLayer"
		    local talkLayer = TalkLayer.createTalkLayer(_strongHoldInfo.victor_dialog_id)
		    local runningScene = CCDirector:sharedDirector():getRunningScene()
		    runningScene:addChild(talkLayer,10000)
		    TalkLayer.setCallbackFunction(TalkOverCallback)
		    isHaveTalk = true
	    end
	    -- DataCache.addDefeatNumByCopyAndFort( curCopyId, curFortId, -1 )
	else
		-- 对话
		print("HeroFortInfoLayer3")
	    if( (not isHadVictory) and _strongHoldInfo.fail_dialog_id and tonumber(_strongHoldInfo.fail_dialog_id) > 0 and (not CopyUtil.isFortIdFailHadDisplay(_strongHoldInfo.id)))then
	    	CopyUtil.addHadFailDialogFortId(_strongHoldInfo.id)
	    	require "script/ui/talk/talkLayer"
	    	print("HeroFortInfoLayer4")
		    local talkLayer = TalkLayer.createTalkLayer(_strongHoldInfo.fail_dialog_id)
		    local runningScene = CCDirector:sharedDirector():getRunningScene()
		    runningScene:addChild(talkLayer,10000)
		    TalkLayer.setCallbackFunction(TalkOverCallback)
		    isHaveTalk = true
	    end
	end


	if(isHaveTalk == false) then
		print("HeroFortInfoLayer5")
		TalkOverCallback()
	end
end

-- 重置cd回调
function resetSweepCdCallback( cbFlag, dictData, bRet )

end

-- 是否确认reset
function confirmCBFunc( isConfirm )

end

-- 重置cd
function resetSweepCdAction()

end

-- 重置攻打次数回调
function resetAtkTimesDelegate()

end

-- 战斗
function fightAction( tag, itembtn )

	print("curCopyId, curFortId, selectedHardLevel, doBattleCallback==", curCopyId, curFortId, selectedHardLevel, doBattleCallback)

	require "script/ui/hero/HeroPublicUI"
	if(ItemUtil.isBagFull() == true)then
		--AnimationTip.showTip(GetLocalizeStringBy("key_2094"))
		return
	elseif HeroPublicUI.showHeroIsLimitedUI() then
		return
	end
	local _strongHoldInfo = DB_Stronghold.getDataById(tonumber(curFortId))
	local costBody = 0
	selectedHardLevel = _hardLevel
	if ( selectedHardLevel == 1 ) then
		costBody = _strongHoldInfo.cost_energy_simple
	elseif( selectedHardLevel == 2 ) then
		costBody = _strongHoldInfo.cost_energy_normal

	elseif( selectedHardLevel == 3 ) then
		costBody = _strongHoldInfo.cost_energy_hard
	end

	if(costBody > UserModel.getEnergyValue()) then
		require "script/ui/item/EnergyAlertTip"
        EnergyAlertTip.showTip()
        return
	else
		require "script/battle/BattleLayer"
		require "script/ui/heroCpy/HeroLayout"
		print("hahahahard_level===".._hardLevel)

		BattleLayer.enterBattle(curCopyId, curFortId, _hardLevel, doBattleCallback, 6,false)
	end
end

--[[
	@desc	创建
	@para 	hardLevel 1/2/3  简单/普通/困难
			progressState的取值：0可显示 1可攻击 2npc通关 3简单通关 4普通通关 5困难通关
	@return FortInfoLayer
--]]
function createLayer(copy_id,fortId,progressState, defeat_num)
	-- _copyInfo = copyInfo
	print("copy_id,fortId,progressState==",copy_id,fortId,progressState, defeat_num)

	init()
	-- print("htid====="..htid)
	_progressState = tonumber(progressState)
	-- _defeat_num = tonumber(defeat_num)
	_displayDefeatNum = tonumber(defeat_num)

	-- if(_displayDefeatNum>10)then
	-- 	-- _defeat_num = 10
	-- end
	curCopyId = copy_id
	curFortId = fortId
	-- _htid = htid
	_hardLevel = tonumber(defeat_num)
	-- handleData()
	print("hard====~~~~~"..defeat_num)
	_bgLayer = CCLayerColor:create(ccc4(0,0,0,155))
	_bgLayer:registerScriptHandler(onNodeEvent)

	-- 创建背景
	createBgSprite()
	-- if(_strongHoldInfo.reward_item_id_simple) then
	-- 	-- 掉落物品
	-- 	createRewardItems()
	-- end

	-- 创建三种难度
	createHardDegree()



	return _bgLayer
end

--add by lichenyang
function TalkOverCallback( ... )
	print("HeroFortInfoLayer6")
	-- CCNotificationCenter:sharedNotificationCenter():postNotification("NC_FightOver")
	print("fuckthis")
	print_t(_newData)
	print("fuckthis")
	refreshFortsInfoLayer(_newData)
	closeAction()
end



