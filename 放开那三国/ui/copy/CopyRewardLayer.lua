-- Filename：	CopyRewardLayer.lua
-- Author：		Cheng Liang
-- Date：		2013-7-31
-- Purpose：		副本奖励领取

module("CopyRewardLayer", package.seeall)


require "script/ui/common/LuaMenuItem"
require "script/ui/main/MainScene"
require "script/network/RequestCenter"
require "script/network/Network"
require "script/ui/item/ItemSprite"
require "script/model/utils/HeroUtil"
require "script/model/user/UserModel"
require "script/ui/item/ItemUtil"
require "script/ui/tip/AnimationTip"
require "script/ui/hero/HeroPublicLua"
require "script/ui/hero/HeroPublicCC"
require "script/ui/hero/HeroPublicUI"


local _bgLayer 		= nil

local _box_index 	= nil			-- 箱子的索引
local _box_status 	= nil			-- 箱子的状态
local _reward_t		= nil			-- 奖励的一系列东东
local _stars_c 		= nil			-- 领取条件
local _copy_id 		= nil			-- 副本id 

local _add_gold 	= 0 			-- 增加金币
local _add_coin 	= 0 			-- 增加硬币
local _add_soul 	= 0  			-- 增加将魂
local _item_arr 	= {} 			-- 奖励物品
local _card_arr		= {} 			-- 奖励hero 
local _rewardDelegateFunc = nil		-- 回调函数

local rewardBtn		= nil

local function init()
	_add_soul = 0
	_add_coin = 0
	_add_gold = 0
	_item_arr = {}
	_card_arr = {}
	_rewardDelegateFunc = nil
	rewardBtn		= nil
end

--[[
 @desc	 处理touches事件
 @para 	 string event
 @return 
--]]
local function onTouchesHandler( eventType, x, y )
	
	if (eventType == "began") then
		-- print("began")

	    return true
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
		_bgLayer:registerScriptTouchHandler(onTouchesHandler, false, -411, true)
		_bgLayer:setTouchEnabled(true)
	elseif (event == "exit") then
		print("exit")
		_bgLayer:unregisterScriptTouchHandler()
	end
end

-- 关闭按钮
function closeAction( tag, itemBtn )
	require "script/audio/AudioUtil"
	AudioUtil.playEffect("audio/effect/guanbi.mp3")
	_bgLayer:removeFromParentAndCleanup(true)
	_bgLayer = nil
end

-- 领取奖励回调
function getPrizeCallback( cbFlag, dictData, bRet )
	if(dictData.err ~= "ok") then
		return
	end
	UserModel.changeSilverNumber(_add_coin)
	UserModel.changeGoldNumber(_add_gold)
	UserModel.changeHeroSoulNumber(_add_soul)
	--[[local tip_text = GetLocalizeStringBy("key_3311")
	if(_add_coin>0)then
		tip_text = tip_text .. _add_coin .. GetLocalizeStringBy("key_2894")
	end
	if(_add_gold>0)then
		tip_text = tip_text .. _add_gold .. GetLocalizeStringBy("key_1447")
	end
	if(_add_soul>0)then
		tip_text = tip_text .. _add_soul .. GetLocalizeStringBy("key_1598")
	end
	if( not table.isEmpty(_item_arr) )then
		for k, item_info in pairs(_item_arr) do
			local db_info = ItemUtil.getItemById(item_info.id)
			tip_text = tip_text .. item_info.num .. GetLocalizeStringBy("key_2557") .. db_info.name .. " "
		end
	end
	if( not table.isEmpty(_card_arr))then
		for k, card_info in pairs(_card_arr) do
			require "db/DB_Heroes"
			local db_info = DB_Heroes.getDataById(tonumber(card_info.id))
		
			tip_text = tip_text .. card_info.num .. GetLocalizeStringBy("key_2557") .. db_info.name .. " "
		end
	end
	AnimationTip.showTip(tip_text)]]
	local items = {}
	if(_add_coin>0)then
		local item= {}
		item.type = "silver"
		item.num = _add_coin
		item.name = GetLocalizeStringBy("key_2889") .. _add_coin
		table.insert(items, item)
	end
	if(_add_gold>0)then
		local item= {}
		item.type = "gold"
		item.num = _add_gold
		item.name = GetLocalizeStringBy("key_1443") .. _add_gold
		table.insert(items, item)
	end
	if(_add_soul>0)then
		local item= {}
		item.type = "soul"
		item.num = _add_soul
		item.name = GetLocalizeStringBy("key_1603") .. _add_soul
		table.insert(items, item)
	end
	if( not table.isEmpty(_item_arr) )then
		for k, item_info in pairs(_item_arr) do
			local item= {}
			local db_info = ItemUtil.getItemById(item_info.id)
			--tip_text = tip_text .. item_info.num .. GetLocalizeStringBy("key_2557") .. db_info.name .. " "
			item.tid = item_info.id
			item.num = item_info.num
			item.type = "item"
			item.name = db_info.name
			table.insert(items,item)
		end
	end
	require "db/DB_Heroes"
	if( not table.isEmpty(_card_arr))then
		for k, card_info in pairs(_card_arr) do
			local item= {}
			local db_info = DB_Heroes.getDataById(tonumber(card_info.id))
		
			--tip_text = tip_text .. card_info.num .. GetLocalizeStringBy("key_2557") .. db_info.name .. " "
			item.type = "hero"
			item.tid = card_info.id
			item.num = card_info.num
			item.name =  db_info.name
			table.insert(items,item)
		end
	end

	-- require "script/utils/GoodTableView"
	-- require "script/utils/BaseUI"
	-- local layer = GoodTableView.ItemTableView:create(items)
	-- local alertContent = {}
	-- alertContent[1] = CCRenderLabel:create(GetLocalizeStringBy("key_1248") , g_sFontPangWa, 36,1, ccc3(0x00,0,0),type_stroke)
	-- alertContent[1]:setColor(ccc3(0xff, 0xc0, 0x00))
	-- local alert = BaseUI.createHorizontalNode(alertContent)
	-- layer:setContentTitle(alert)
	-- CCDirector:sharedDirector():getRunningScene():addChild(layer,1111)
	require "script/ui/item/ReceiveReward"
    ReceiveReward.showRewardWindow( items, nil , 1111, -800 )
    
	closeAction()
	if(_rewardDelegateFunc) then
		_rewardDelegateFunc(_box_index)
	end
end

-- 按钮响应
function menuAction( tag, itemBtn )
	---[==[副本箱子 新手引导屏蔽层
	---------------------新手引导---------------------------------
		--add by licong 2013.09.11
		require "script/guide/NewGuide"
		if(NewGuide.guideClass ==  ksGuideCopyBox) then
			require "script/guide/CopyBoxGuide"
			CopyBoxGuide.changLayer()
		end
	---------------------end-------------------------------------
	--]==]

	if(ItemUtil.isBagFull() == true or HeroPublicUI.showHeroIsLimitedUI()== true )then
		closeAction()
	else
		local args = Network.argsHandler( _copy_id, _box_index - 1)
		RequestCenter.ncopy_getPrize(getPrizeCallback, args)
	end
end

-- 0/1/2/3/4 物品/金币/银币/将魂/卡牌
local function handleData( ... )
	for k, v_info in pairs(_reward_t) do
		if(v_info.type == 1 ) then
			_add_gold = v_info.num
		elseif(v_info.type == 2 ) then
			_add_coin = v_info.num
		elseif(v_info.type == 3 ) then
			_add_soul = v_info.num
		elseif(v_info.type == 4 ) then
			table.insert(_card_arr, v_info)
		elseif(v_info.type == 0 ) then
			table.insert(_item_arr, v_info)
		end
	end
end 

--
local function create(  )
	-- 背景
	local fullRect = CCRectMake(0,0,213,171)
	local insetRect = CCRectMake(50,50,113,71)
	local rewardBg = CCScale9Sprite:create("images/formation/changeformation/bg.png", fullRect, insetRect)
	rewardBg:setPreferredSize(CCSizeMake(600, 450))
	rewardBg:setAnchorPoint(ccp(0.5, 0.5))
	rewardBg:setPosition(ccp(_bgLayer:getContentSize().width*0.5, _bgLayer:getContentSize().height*0.5))
	_bgLayer:addChild(rewardBg)
	rewardBg:setScale(g_fScaleX)

	local bgSize = rewardBg:getContentSize()

	-- 标题
	local titleSp = CCSprite:create("images/formation/changeformation/titlebg.png")
	titleSp:setAnchorPoint(ccp(0.5,0.5))
	titleSp:setPosition(ccp(bgSize.width/2, bgSize.height*0.986))
	rewardBg:addChild(titleSp)
	local titleLabel = CCRenderLabel:create(GetLocalizeStringBy("key_2392") , g_sFontName, 35, 2, ccc3( 0x00, 0x00, 0x00), type_stroke)
    titleLabel:setSourceAndTargetColor(ccc3( 0xff, 0xf0, 0x49), ccc3( 0xff, 0xa2, 0x00));
    -- titleLabel:setColor(ccc3(0xff, 0xf6, 0x00))
    titleLabel:setPosition(ccp( (titleSp:getContentSize().width-titleLabel:getContentSize().width)/2, titleSp:getContentSize().height*0.85))
    titleSp:addChild(titleLabel)

    -- 领取条件
    local conditionSprite = CCSprite:create("images/copy/reward/condition.png")
    conditionSprite:setAnchorPoint(ccp(0.5, 0.5))
    conditionSprite:setPosition(ccp( bgSize.width/2, bgSize.height*360.0/450))
    rewardBg:addChild(conditionSprite)
    -- 领取条件label
    local conditionLabel = CCRenderLabel:create(_stars_c , g_sFontName, 30, 3, ccc3( 0x00, 0x00, 0x00), type_stroke)
    -- conditionLabel:setSourceAndTargetColor(ccc3( 0xff, 0xed, 0x55), ccc3( 0xff, 0x8f, 0x00));
    titleLabel:setColor(ccc3(0xff, 0x8f, 0x00))
    if(Platform.getLayout ~= nil and Platform.getLayout() == "enLayout" ) then
    	conditionLabel:setPosition(ccp( conditionSprite:getContentSize().width *90.0/259, conditionSprite:getContentSize().height))
    else
    	conditionLabel:setPosition(ccp( conditionSprite:getContentSize().width *75.0/259, conditionSprite:getContentSize().height))
    end
    conditionSprite:addChild(conditionLabel)
	-- 星星sp
	local star_sprite = CCSprite:create("images/hero/star.png")
	star_sprite:setAnchorPoint(ccp(0.5, 0.5))
	if(Platform.getLayout ~= nil and Platform.getLayout() == "enLayout" ) then
		star_sprite:setPosition(ccp(conditionSprite:getContentSize().width*135.0/259, conditionSprite:getContentSize().height*0.5))
	else
		star_sprite:setPosition(ccp(conditionSprite:getContentSize().width*140.0/259, conditionSprite:getContentSize().height*0.5))
	end
	
	conditionSprite:addChild(star_sprite)

--------------------------------- 金币、银币、将魂 ----------------------------------------	
	-- local fullRect_l  = CCRectMake(0,0,169,37)
	-- local insetRect_l = CCRectMake(60,15,49,7)

	-- -- 银币 
	-- local silverSprite = CCScale9Sprite:create("images/common/labelbg_white.png", fullRect_l, insetRect_l)
	-- silverSprite:setPreferredSize(CCSizeMake(370, 37))
	-- silverSprite:setAnchorPoint(ccp(0.5, 0.5))
	-- silverSprite:setPosition(ccp(rewardBg:getContentSize().width*0.5, rewardBg:getContentSize().height*335.0/450))
	-- rewardBg:addChild(silverSprite)
	-- -- 银币label
	-- local silverLabel = CCLabelTTF:create(GetLocalizeStringBy("key_3341"), g_sFontName, 24)
	-- silverLabel:setColor(ccc3(0x78, 0x25, 0x00))
	-- silverLabel:setAnchorPoint(ccp(0.5, 0.5))
	-- silverLabel:setPosition(ccp(128, 18.5))
	-- silverSprite:addChild(silverLabel)
	-- -- 银币图标
	-- local silverIcon = CCSprite:create("images/common/coin.png")
	-- silverIcon:setAnchorPoint(ccp(0.5, 0.5))
	-- silverIcon:setPosition(ccp(185, 18.5))
	-- silverSprite:addChild(silverIcon)
	-- local silverNumLabel = CCLabelTTF:create(_add_coin, g_sFontName, 24)
	-- silverNumLabel:setColor(ccc3(0x00, 0x00, 0x00))
	-- silverNumLabel:setAnchorPoint(ccp(0, 0.5))
	-- silverNumLabel:setPosition(ccp(210, 18.5))
	-- silverSprite:addChild(silverNumLabel)

	-- -- 金币 
	-- local goldSprite = CCScale9Sprite:create("images/common/labelbg_white.png", fullRect_l, insetRect_l)
	-- goldSprite:setPreferredSize(CCSizeMake(370, 37))
	-- goldSprite:setAnchorPoint(ccp(0.5, 0.5))
	-- goldSprite:setPosition(ccp(rewardBg:getContentSize().width*0.5, rewardBg:getContentSize().height*290.0/450))
	-- rewardBg:addChild(goldSprite)
	-- -- 金币label
	-- local goldLabel = CCLabelTTF:create(GetLocalizeStringBy("key_1298"), g_sFontName, 24)
	-- goldLabel:setColor(ccc3(0x78, 0x25, 0x00))
	-- goldLabel:setAnchorPoint(ccp(0.5, 0.5))
	-- goldLabel:setPosition(ccp(128, 18.5))
	-- goldSprite:addChild(goldLabel)
	-- -- 金币图标
	-- local goldIcon = CCSprite:create("images/common/gold.png")
	-- goldIcon:setAnchorPoint(ccp(0.5, 0.5))
	-- goldIcon:setPosition(ccp(185, 18.5))
	-- goldSprite:addChild(goldIcon)
	-- local goldNumLabel = CCLabelTTF:create(_add_gold, g_sFontName, 24)
	-- goldNumLabel:setColor(ccc3(0x00, 0x00, 0x00))
	-- goldNumLabel:setAnchorPoint(ccp(0, 0.5))
	-- goldNumLabel:setPosition(ccp(210, 18.5))
	-- goldSprite:addChild(goldNumLabel)

	-- -- 将魂 
	-- local soulSprite = CCScale9Sprite:create("images/common/labelbg_white.png", fullRect_l, insetRect_l)
	-- soulSprite:setPreferredSize(CCSizeMake(370, 37))
	-- soulSprite:setAnchorPoint(ccp(0.5, 0.5))
	-- soulSprite:setPosition(ccp(rewardBg:getContentSize().width*0.5, rewardBg:getContentSize().height*245.0/450))
	-- rewardBg:addChild(soulSprite)
	-- -- 将魂label
	-- local soulLabel = CCLabelTTF:create(GetLocalizeStringBy("key_1086"), g_sFontName, 24)
	-- soulLabel:setColor(ccc3(0x78, 0x25, 0x00))
	-- soulLabel:setAnchorPoint(ccp(0.5, 0.5))
	-- soulLabel:setPosition(ccp(128, 18.5))
	-- soulSprite:addChild(soulLabel)
	-- -- 将魂图标
	-- local soulIcon = CCSprite:create("images/common/icon_soul.png")
	-- soulIcon:setAnchorPoint(ccp(0.5, 0.5))
	-- soulIcon:setPosition(ccp(185, 18.5))
	-- soulSprite:addChild(soulIcon)
	-- local soulNumLabel = CCLabelTTF:create(_add_soul, g_sFontName, 24)
	-- soulNumLabel:setColor(ccc3(0x00, 0x00, 0x00))
	-- soulNumLabel:setAnchorPoint(ccp(0, 0.5))
	-- soulNumLabel:setPosition(ccp(210, 18.5))
	-- soulSprite:addChild(soulNumLabel)

-------------------------- 奖励物品 -----------------------------
	-- local fullRect_i = CCRectMake(0,0,61,47)
	-- local insetRect_i = CCRectMake(10,10,41,27)
	-- --物品奖励背景
	-- local itemBg = CCScale9Sprite:create("images/copy/fort/textbg.png", fullRect_i, insetRect_i)
	-- itemBg:setPreferredSize(CCSizeMake(480, 170))
	-- itemBg:setAnchorPoint(ccp(0.5, 0.5))
	-- itemBg:setPosition(ccp(bgSize.width*0.5, bgSize.height*0.5))
	-- rewardBg:addChild(itemBg)

	-- -- 物品
	-- local i_index = 0
	-- for k, item_info in pairs(_item_arr) do
	--  	local icon_sprite = ItemSprite.getItemSpriteById(item_info.id)
	--  	icon_sprite:setAnchorPoint(ccp(0, 0.5))
	--  	icon_sprite:setPosition(ccp(30+i_index*110, itemBg:getContentSize().height/2))
	--  	i_index = i_index + 1
	--  	itemBg:addChild(icon_sprite)
	-- end 
	-- for k, hero_info in pairs(_card_arr) do
	-- 	local hero_sprite = HeroUtil.getHeroIconByHTID( hero_info.id )
	-- 	hero_sprite:setAnchorPoint(ccp(0, 0.5))
	--  	hero_sprite:setPosition(ccp(30+i_index*110, itemBg:getContentSize().height/2))
	--  	i_index = i_index + 1
	--  	itemBg:addChild(hero_sprite)
	-- end

	-- for i_k = i_index, 3 do
	-- 	local de_sprite = CCSprite:create("images/copy/fort/item_frame.png")
	-- 	de_sprite:setAnchorPoint(ccp(0, 0.5))
	--  	de_sprite:setPosition(ccp(30+i_k*110, itemBg:getContentSize().height/2))
	--  	itemBg:addChild(de_sprite)
	-- end
---------------------------奖励物品tableView-----------------------
	local fullRect_i = CCRectMake(0,0,61,47)
	local insetRect_i = CCRectMake(10,10,41,27)
	--物品奖励背景
	local itemBg = CCScale9Sprite:create("images/copy/fort/textbg.png", fullRect_i, insetRect_i)
	itemBg:setPreferredSize(CCSizeMake(480, 150))
	itemBg:setAnchorPoint(ccp(0.5, 0.5))
	itemBg:setPosition(ccp(bgSize.width*0.5, bgSize.height*0.5))
	rewardBg:addChild(itemBg)

	-- 物品tableView
	local myTableView = createTableView()
	myTableView:setPosition(ccp(5, 5))
	itemBg:addChild(myTableView)
--------------------------- 领取按钮 ------------------------------
    -- 按钮Bar
    local menuBar = CCMenu:create()
    menuBar:setPosition(ccp(0,0))
    menuBar:setTouchPriority(-412)
    rewardBg:addChild(menuBar)

    -- 关闭按钮
    local closeBtn = LuaMenuItem.createItemImage("images/common/btn_close_n.png", "images/common/btn_close_h.png", closeAction )
	closeBtn:setAnchorPoint(ccp(1, 1))
    closeBtn:setPosition(ccp(bgSize.width*1.02, bgSize.height*1.02))
	menuBar:addChild(closeBtn)

	-- 是否能领取的按钮
	
	if(_box_status == 1) then
		rewardBtn = BTGraySprite:create("images/copy/reward/btn_reward_n.png")
		rewardBtn:setAnchorPoint(ccp(0.5, 0.5))
	    rewardBtn:setPosition(ccp(bgSize.width/2, bgSize.height*0.2))
		rewardBg:addChild(rewardBtn)
	elseif(_box_status == 2) then
		-- 领取奖励安妮
		rewardBtn = LuaMenuItem.createItemImage("images/copy/reward/btn_reward_n.png", "images/copy/reward/btn_reward_h.png", menuAction )
		rewardBtn:setAnchorPoint(ccp(0.5, 0.5))
	    rewardBtn:setPosition(ccp(bgSize.width/2, bgSize.height*0.2))
		menuBar:addChild(rewardBtn)
	elseif(_box_status == 3) then
		rewardBtn = CCSprite:create("images/copy/reward/received.png")
		rewardBtn:setAnchorPoint(ccp(0.5, 0.5))
	    rewardBtn:setPosition(ccp(bgSize.width/2, bgSize.height*0.2))
		rewardBg:addChild(rewardBtn)
	end
end 


-- 创建奖励物品tableView
function createTableView( ... )
 	local cellSize = CCSizeMake(116, 140)
	local h = LuaEventHandler:create(function(fn, table, a1, a2) 	--创建
		local r
		if fn == "cellSize" then
			r = cellSize
		elseif fn == "cellAtIndex" then
           a2 = createRewardCell(_reward_t[a1+1])  
			r = a2
		elseif fn == "numberOfCells" then
			local num = #_reward_t
			r = num
			print("num is : ", num)
		elseif fn == "cellTouched" then
			
		elseif (fn == "scroll") then
			
		end
		return r
	end)

	local goodTableView = LuaTableView:createWithHandler(h, CCSizeMake(470, 140))
	goodTableView:setBounceable(true)
	if(#_reward_t> 4) then
		goodTableView:setTouchPriority(-413)
	end
	goodTableView:setDirection(kCCScrollViewDirectionHorizontal)
	goodTableView:setVerticalFillOrder(kCCTableViewFillTopDown)

	return goodTableView
end 

-- 创建物品图标
function createRewardCell( cellValues )
	local tCell = CCTableViewCell:create()
	local iconBg = nil
	local iconName = nil
	local nameColor = nil
	if(tonumber(cellValues.type) == 2) then
		-- 银币
		iconBg= ItemSprite.getSiliverIconSprite()
		iconName = GetLocalizeStringBy("key_1687")
		local quality = ItemSprite.getSilverQuality()
        nameColor = HeroPublicLua.getCCColorByStarLevel(quality)
	elseif(tonumber(cellValues.type) == 3) then
		-- 将魂
		iconBg= ItemSprite.getSoulIconSprite()
		iconName = GetLocalizeStringBy("key_1616")
		local quality = ItemSprite.getSoulQuality()
        nameColor = HeroPublicLua.getCCColorByStarLevel(quality)
	elseif(tonumber(cellValues.type) == 1) then
		-- 金币
		iconBg= ItemSprite.getGoldIconSprite()
		iconName = GetLocalizeStringBy("key_1491")
		local quality = ItemSprite.getGoldQuality()
        nameColor = HeroPublicLua.getCCColorByStarLevel(quality)
	elseif(tonumber(cellValues.type) == 0) then
		-- 物品
		iconBg =  ItemSprite.getItemSpriteByItemId(tonumber(cellValues.id))
		local itemData = ItemUtil.getItemById(cellValues.id)
        iconName = itemData.name
        nameColor = HeroPublicLua.getCCColorByStarLevel(itemData.quality)
	elseif(tonumber(cellValues.type) == 4) then
		-- 英雄
		require "db/DB_Heroes"
		iconBg = HeroPublicCC.getCMISHeadIconByHtid(cellValues.id)
		local heroData = DB_Heroes.getDataById(cellValues.id)
		iconName = heroData.name
		nameColor = HeroPublicLua.getCCColorByStarLevel(heroData.star_lv)
	end
	iconBg:setAnchorPoint(ccp(0,1))
	iconBg:setPosition(ccp(20,130))
	tCell:addChild(iconBg)

	-- 物品数量
	local numberLabel = CCRenderLabel:create("" .. cellValues.num,g_sFontName,21,2,ccc3(0x00,0x00,0x00),type_stroke)
	numberLabel:setColor(ccc3(0x00,0xff,0x18))
	numberLabel:setAnchorPoint(ccp(0,0))
	local width = iconBg:getContentSize().width - numberLabel:getContentSize().width - 6
	numberLabel:setPosition(ccp(width,5))
	iconBg:addChild(numberLabel)

	--- desc 物品名字
	local descLabel = CCRenderLabel:create("" .. iconName , g_sFontName,21,1,ccc3(0x00,0x00,0x00),type_stroke)
	descLabel:setColor(nameColor)
	descLabel:setAnchorPoint(ccp(0.5,0.5))
	descLabel:setPosition(ccp(iconBg:getContentSize().width*0.5 ,-iconBg:getContentSize().height*0.2))
	iconBg:addChild(descLabel)

	return tCell
end


--[[
	@desc	
	@para 		 		
	@return void
--]]
function createLayer( box_status, stars_c, reward_t, box_index, copy_id, rewardDelegate)
	init()
	_box_status = box_status
	_stars_c 	= stars_c
	_reward_t 	= reward_t
	print("_reward_t:")
	print_t(_reward_t)
	_box_index	= box_index
	_copy_id	= copy_id
	_rewardDelegateFunc = rewardDelegate
	handleData()
	-- layer
	_bgLayer = CCLayerColor:create(ccc4(155,150,150,80))
	_bgLayer:registerScriptHandler(onNodeEvent)
	-- local runningScene = CCDirector:sharedDirector():getRunningScene()
	-- runningScene:addChild(_bgLayer, 9999999)
	create()
		
	return _bgLayer
end


-- 新手引导
function getGuideObject()
	return rewardBtn
end


