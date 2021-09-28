-- FileName: GuildBossBattleLayer.lua 
-- Author: llp 
-- Date: 16-3-7 
-- Purpose: function description of module 

require "script/model/user/UserModel"
require "script/ui/item/ItemSprite"
require "script/ui/item/ItemUtil"
require "script/ui/hero/HeroPublicLua"
require "script/ui/hero/HeroPublicCC"
require "script/ui/tip/AnimationTip"

module("GuildBossBattleLayer", package.seeall)

local _bgLayer 					= nil
local otherCallFun 				= nil    -- 传入回调
local layer_priority			= nil    -- layerTouch优先级
local menu_priority				= nil    -- menuTouch优先级
local layer_zOrder				= nil    -- layerZ轴
local bg_hight 					= nil	 -- 背景高度
local itemBg_hight 				= nil	 -- 物品列表背景高度
local tableView_hight 			= nil	 -- 物品列表高度
local yesItem 					= nil 	 -- 确定按钮	
local tView_priority 			= nil
local tView_menuPriority        = nil
local tView_infoPriority		= nil
local _id 						= nil
local _titleText 				= nil    -- 标题
local _callFunArgs 				= nil
local _battleResult 			= nil

-- 初始化
function init( ... )
	_battleResult 				= nil
	_id 						= nil
	_bgLayer 					= nil
	otherCallFun 				= nil    -- 传入回调
	layer_priority				= nil    -- layerTouch优先级
	menu_priority				= nil    -- menuTouch优先级
	layer_zOrder				= nil    -- layerZ轴
	bg_hight 					= nil	 -- 背景高度
	itemBg_hight 				= nil	 -- 物品列表背景高度
	tableView_hight 			= nil	 -- 物品列表高度
	yesItem 					= nil 	 -- 确定按钮	
	tView_priority 				= nil
	tView_menuPriority        	= nil
	tView_infoPriority			= nil
	_titleText 					= nil
	_callFunArgs 				= nil
end

-- 显示奖励  一行为4个，超过两行可上下滑动
-- 参数1.itemArr_data: 奖励物品数据
-- 参数2.callBackFun: 点击确定的回调  
-- 参数3.zOrder: 弹出层z轴    默认 2100
-- 参数4.priority: 弹出层touch优先级  默认 -420
function showRewardWindow( id, itemArr_data, callBackFun, zOrder, priority, titleText, p_callFunArgs )
	if(_bgLayer ~= nil)then
		_bgLayer:removeFromParentAndCleanup(true)
		_bgLayer = nil
	end
	-- 初始化
	init()
	_id = id
	local guildInfo = GuildBossCopyData.getUserInfo()
	-- local itemArr_data = arr
	local data = DB_GroupCopy.getDataById(id)
	itemArr_data = ItemUtil.getItemsDataByStr(data.reward)
	otherCallFun = callBackFun
	layer_priority = tonumber(priority) or -430 
	tView_menuPriority = tonumber(layer_priority-1) or -431
	tView_priority = tonumber(layer_priority-2) or -432
	menu_priority = tonumber(layer_priority-3) or -433
	tView_infoPriority = tonumber(layer_priority-4) or -434
    layer_zOrder = tonumber(zOrder) or 2100
    _titleText 	= titleText or GetLocalizeStringBy("key_2407")
    _callFunArgs = p_callFunArgs
   
	-- 创建层
	_bgLayer = CCLayerColor:create(ccc4(11,11,11,200))
	_bgLayer:setTouchEnabled(true)
    _bgLayer:registerScriptTouchHandler(cardLayerTouch,false,layer_priority,true)
    
    local scene = CCDirector:sharedDirector():getRunningScene()
    scene:addChild(_bgLayer,3)
   
    bg_hight = 580
    itemBg_hight = 150
    tableView_hight = 140
    -- 创建背景
    local reward_bg = BaseUI.createViewBg(CCSizeMake(583,bg_hight))
    reward_bg:setPosition(ccp(g_winSize.width*0.5,g_winSize.height*0.5))
    _bgLayer:addChild(reward_bg)

    -- 适配
	setAdaptNode(reward_bg)
	local thisScale = reward_bg:getScale()

 	reward_bg:setScale(0)
 	local array = CCArray:create()
    local scale1 = CCScaleTo:create(0.08,1.2*thisScale)
    local fade = CCFadeIn:create(0.06)
    local spawn = CCSpawn:createWithTwoActions(scale1,fade)
    local scale2 = CCScaleTo:create(0.07,0.9*thisScale)
    local scale3 = CCScaleTo:create(0.07,1*thisScale)
    array:addObject(scale1)
    array:addObject(scale2)
    array:addObject(scale3)
    local seq = CCSequence:create(array)
    reward_bg:runAction(seq)

    -- 关闭按钮
	local menu = CCMenu:create()
	menu:setTouchPriority(menu_priority)
	menu:setPosition(ccp(0, 0))
	menu:setAnchorPoint(ccp(0, 0))
	reward_bg:addChild(menu)
	local closeButton = CCMenuItemImage:create("images/common/btn_close_n.png", "images/common/btn_close_h.png")
	closeButton:setAnchorPoint(ccp(0.5, 0.5))
	closeButton:setPosition(ccp(reward_bg:getContentSize().width*0.95, reward_bg:getContentSize().height*0.95 ))
	closeButton:registerScriptTapHandler(yesItemCallFun)
	menu:addChild(closeButton)

	local flowerSprite = CCSprite:create("images/common/135.png")
    	  flowerSprite:setAnchorPoint(ccp(0.5,0.5))
    	  flowerSprite:setPosition(ccp(reward_bg:getContentSize().width*0.5,reward_bg:getContentSize().height-closeButton:getContentSize().height))
    reward_bg:addChild(flowerSprite)

    local battleData = DB_GroupCopy.getDataById(id)
    local copyNameLabel = CCRenderLabel:create( battleData.bossName , g_sFontPangWa, 33, 1, ccc3( 0x00, 0x00, 0x00), type_stroke)
    	  copyNameLabel:setColor(ccc3(0xff,0xe4,0x00))
    	  copyNameLabel:setAnchorPoint(ccp(0.5,0.5))
    	  copyNameLabel:setPosition(ccp(flowerSprite:getContentSize().width*0.5,flowerSprite:getContentSize().height*0.5))
    flowerSprite:addChild(copyNameLabel)

    local tipData = DB_GroupCopy_rule.getDataById(1)
    local attactNum = tonumber(tipData.num)+tonumber(guildInfo.boss_info.buy_boss_num)-tonumber(guildInfo.boss_info.atk_boss_num)
    local lastTimeLabel = CCRenderLabel:create( GetLocalizeStringBy("llp_346",attactNum) , g_sFontName, 23, 1, ccc3( 0x00, 0x00, 0x00), type_stroke)
    	  lastTimeLabel:setColor(ccc3(0xe4,0x00,0xff))
    	  lastTimeLabel:setAnchorPoint(ccp(0.5,1))
    	  lastTimeLabel:setPosition(ccp(copyNameLabel:getContentSize().width*0.5,-lastTimeLabel:getContentSize().height*0.5))
    copyNameLabel:addChild(lastTimeLabel)

	-- 攻击按钮
    fightItem = LuaCC.create9ScaleMenuItem("images/common/btn/btn1_d.png","images/common/btn/btn1_n.png",CCSizeMake(190,75),GetLocalizeStringBy("key_1727"),ccc3(0xff, 0xf6, 0x00),35,g_sFontPangWa,1, ccc3(0x00, 0x00, 0x00))
	fightItem:setAnchorPoint(ccp(0.5,0))
	fightItem:setPosition(ccp(reward_bg:getContentSize().width*0.5,reward_bg:getContentSize().height*0.08))
	menu:addChild(fightItem)
	-- 注册回调
	fightItem:registerScriptTapHandler(fightItemCallFun)

    -- 物品区域
    local itemBg = CCScale9Sprite:create("images/common/bg/9s_1.png")
	itemBg:setContentSize(CCSizeMake(480, itemBg_hight))
	itemBg:setAnchorPoint(ccp(0.5, 0.5))
	itemBg:setPosition(ccp(reward_bg:getContentSize().width*0.5,reward_bg:getContentSize().height*0.5))
	reward_bg:addChild(itemBg)

	local destinyLabelBg= CCScale9Sprite:create("images/common/astro_labelbg.png")
    destinyLabelBg:setContentSize(CCSizeMake(183,40))
    destinyLabelBg:setAnchorPoint(ccp(0.5,0.5))
    destinyLabelBg:setPosition(itemBg:getContentSize().width/2, itemBg:getContentSize().height)
    itemBg:addChild(destinyLabelBg)

    local titleLabel = CCLabelTTF:create(GetLocalizeStringBy("llp_345"),g_sFontPangWa,25)
    	  titleLabel:setColor(ccc3(0xff,0xf6,0x00))
    	  titleLabel:setAnchorPoint(ccp(0.5,0.5))
    	  titleLabel:setPosition(ccp(destinyLabelBg:getContentSize().width*0.5,destinyLabelBg:getContentSize().height*0.5))
    destinyLabelBg:addChild(titleLabel)

	--提示文字
	tipArray = ItemUtil.getItemsDataByStr(tipData.bonus) 
	local tipLabel = CCLabelTTF:create(GetLocalizeStringBy("llp_344",tipArray[1].num)..tipArray[1].name,g_sFontName,22)
		  tipLabel:setColor(ccc3(0x78,0x25,0x00))
		  tipLabel:setAnchorPoint(ccp(0.5,1))
		  tipLabel:setPosition(ccp(itemBg:getContentSize().width*0.5,-tipLabel:getContentSize().height*1.5))
	itemBg:addChild(tipLabel)

	-- 物品列表
	local myTableView = createItemTableView(itemArr_data)
	myTableView:setPosition(ccp(5, 5))
	itemBg:addChild(myTableView)

	--添加一个下边屏蔽layer 优先级为 tView_priority
	-- touch事件处理
	local pingbiLayer = CCLayer:create()
	-- local pingbiLayer = CCLayerColor:create(ccc4(255,0,0,255))
	local function cardLayerTouch(eventType, x, y)
		local rect = getSpriteScreenRect(pingbiLayer)
		if(rect:containsPoint(ccp(x,y))) then
			return true
		else
			return false
		end
	end
	local p_height = itemBg:getPositionY()-itemBg:getContentSize().height*0.5
	pingbiLayer:setContentSize(CCSizeMake(reward_bg:getContentSize().width,p_height))
	pingbiLayer:setTouchEnabled(true)
	pingbiLayer:registerScriptTouchHandler(cardLayerTouch,false,tView_priority,true)
	pingbiLayer:ignoreAnchorPointForPosition(false)
	pingbiLayer:setAnchorPoint(ccp(1,0))
	pingbiLayer:setPosition(reward_bg:getContentSize().width,0)
	reward_bg:addChild(pingbiLayer)
end


-- 创建物品列表
-- 参数 物品的列表
function createItemTableView( itemArr_data )
	local itemData = itemArr_data or {}
	local cellSize = CCSizeMake(120, 140)
	local h = LuaEventHandler:create(function(fn, table, a1, a2) 	--创建
		local r
		if fn == "cellSize" then
			r = cellSize
		elseif fn == "cellAtIndex" then
			a2 = CCTableViewCell:create()
			-- for i=1,#itemData do
				if(itemData[a1+1] ~= nil)then
					local item_sprite = ItemUtil.createGoodsIcon(itemData[a1+1])
						  item_sprite:setAnchorPoint(ccp(0.5,1))
						  item_sprite:setPosition(ccp(60,120))
					a2:addChild(item_sprite)
				end
			-- end
			r = a2
		elseif fn == "numberOfCells" then
			r = #itemData
		elseif fn == "cellTouched" then
			
		elseif (fn == "scroll") then
			
		end
		return r
	end)
	local pageNum = math.ceil(#itemData/4)
	local goodTableView = LuaTableView:createWithHandler(h, CCSizeMake(470, tableView_hight))
	goodTableView:setBounceable(true)
	goodTableView:setTouchPriority(tView_priority)
	-- 左右滑动
	goodTableView:setDirection(kCCScrollViewDirectionHorizontal)
	goodTableView:setVerticalFillOrder(kCCTableViewFillTopDown)

	return goodTableView
end


-- touch事件处理
function cardLayerTouch(eventType, x, y)
    return true   
end

function endFunc()
	-- body
	local data = DB_GroupCopy.getDataById(_id)
	local itemArr_data = ItemUtil.getItemsDataByStr(data.reward)
	local extraData = DB_GroupCopy_rule.getDataById(1)
	local bonusData = ItemUtil.getItemsDataByStr(extraData.bonus)
	
	if(tonumber(_battleResult.kill)==1)then
		table.insert(itemArr_data,bonusData[1])
	end
	
	require "script/ui/guildBossCopy/GuildBossResultLayer"
    local bg = GuildBossResultLayer.showRewardWindow(itemArr_data,nil,nil,nil,nil)
    GuildBossCopyLayer.freshBoss()
    local title_bg = CCSprite:create("images/formation/changeformation/titlebg.png")
    	  title_bg:setAnchorPoint(ccp(0.5,0.5))
    	  title_bg:setPosition(ccp(bg:getContentSize().width * 0.5, bg:getContentSize().height - 6))
    bg:addChild(title_bg)

    local titleLable = CCRenderLabel:create(GetLocalizeStringBy("key_10109"), g_sFontPangWa, 33, 1, ccc3( 0x00, 0x00, 0x00), type_stroke)
    	  titleLable:setColor(ccc3(0xff,0xe4,0x00))
    	  titleLable:setAnchorPoint(ccp(0.5,0.5))
    	  titleLable:setPosition(ccp(title_bg:getContentSize().width*0.5,title_bg:getContentSize().height*0.5))
    title_bg:addChild(titleLable)
end

function attackCallFunc(p_ret)
	_battleResult = p_ret
    require "script/battle/BattleLayer"
    BattleLayer.showBattleWithString(p_ret.fight_ret, endFunc, nil, nil,nil,nil,nil,nil,false)
end

function yesItemCallFun( ... )
	require "script/audio/AudioUtil"
	AudioUtil.playEffect("audio/effect/guanbi.mp3")
	if(_bgLayer ~= nil)then
		_bgLayer:removeFromParentAndCleanup(true)
		_bgLayer = nil
	end
end

function afterCheckBossInfo(p_Hp)
	-- body
	local hp = tonumber(p_Hp)
	local userInfo = GuildBossCopyData.getUserInfo()
	if(TimeUtil.getSvrTimeByOffset()>tonumber(userInfo.boss_info.cd))then
		GuildBossCopyService.attackBoss(attackCallFunc)
	else
		AnimationTip.showTip(GetLocalizeStringBy("llp_347"))
	end
	if(_bgLayer ~= nil)then
		_bgLayer:removeFromParentAndCleanup(true)
		_bgLayer = nil
	end
end

-- 确定按钮回调
function fightItemCallFun( tag,item )
	-- 音效
	local userInfo = GuildBossCopyData.getUserInfo()
	local tipData = DB_GroupCopy_rule.getDataById(1)
    local attactNum = tonumber(tipData.num)+tonumber(userInfo.boss_info.buy_boss_num)-tonumber(userInfo.boss_info.atk_boss_num)

	if(attactNum==0)then
		AnimationTip.showTip(GetLocalizeStringBy("llp_348"))
		return
	end
	if(ItemUtil.isBagFull() == true)then
		return
	end
	require "script/audio/AudioUtil"
	AudioUtil.playEffect("audio/effect/guanbi.mp3")
	GuildBossCopyService.getBossInfo(afterCheckBossInfo)
end

--[[
	@des:	得到确定按钮
]]
function getEnterButton( ... )
	return yesItem
end