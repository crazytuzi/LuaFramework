-- FileName: ReceiveReward.lua 
-- Author: Li Cong 
-- Date: 13-12-19 
-- Purpose: function description of module 

require "script/model/user/UserModel"
require "script/ui/item/ItemSprite"
require "script/ui/item/ItemUtil"
require "script/ui/hero/HeroPublicLua"
require "script/ui/hero/HeroPublicCC"

module("ReceiveReward", package.seeall)

-- 测试数据
--[[
local arr = {
	-- { type= "gold",num= 150,tid = 0 },
	{type= "item",num   = 300,tid= 60002},
	{type= "item",num   = 10,tid= 410041},
	{type= "hero",num   = 1,tid= 10018},
	{type= "hero",num   = 1,tid= 10018},
	-- { type= "gold",num= 150,tid = 0 },
	{type= "hero",num   = 1,tid= 10018},
	{type= "hero",num   = 1,tid= 10018},
	{type= "item",num   = 300,tid= 60002},
	{type= "item",num   = 10,tid= 410041},
	-- {type= "gold",num   = 150,tid= 0},
	{type= "item",num   = 300,tid= 60002},
	{type= "item",num   = 10,tid= 410041},
	{type= "hero",num   = 1,tid= 10018},
	{type= "hero",num   = 1,tid= 10018}
}
--]]

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

local _titleText 				= nil    -- 标题
local _callFunArgs 				= nil

-- 初始化
function init( ... )
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
function showRewardWindow( itemArr_data, callBackFun, zOrder, priority, titleText, p_callFunArgs )
	if(_bgLayer ~= nil)then
		_bgLayer:removeFromParentAndCleanup(true)
		_bgLayer = nil
	end
	-- 初始化
	init()
	-- local itemArr_data = arr
	otherCallFun = callBackFun
	layer_priority = tonumber(priority) or -430 
	tView_menuPriority = tonumber(layer_priority-1) or -431
	tView_priority = tonumber(layer_priority-2) or -432
	menu_priority = tonumber(layer_priority-3) or -433
	tView_infoPriority = tonumber(layer_priority-4) or -434
    layer_zOrder = tonumber(zOrder) or 2100
    _titleText 	= titleText or GetLocalizeStringBy("key_2407")
    _callFunArgs = p_callFunArgs
   
	print("layer_priority",layer_priority,"tView_menuPriority",tView_menuPriority,"tView_priority",tView_priority,"menu_priority",menu_priority,"tView_infoPriority",tView_infoPriority)
	-- 创建层
	_bgLayer = CCLayerColor:create(ccc4(11,11,11,200))
	_bgLayer:setTouchEnabled(true)
    _bgLayer:registerScriptTouchHandler(cardLayerTouch,false,layer_priority,true)
    
    local scene = CCDirector:sharedDirector():getRunningScene()
    scene:addChild(_bgLayer,layer_zOrder,4320)
    print("layer_zOrder",layer_zOrder)
    -- 根据奖励物品个数设置高度
    if(table.count(itemArr_data) > 8)then
    	bg_hight = 570
    	itemBg_hight = 310
    	tableView_hight = 300
    elseif( table.count(itemArr_data) > 4 and table.count(itemArr_data) <= 8 )then
    	bg_hight = 530
    	itemBg_hight = 300
    	tableView_hight = 290
    else
    	bg_hight = 380
    	itemBg_hight = 150
    	tableView_hight = 140
    end
    -- 创建背景
    local reward_bg = BaseUI.createViewBg(CCSizeMake(583,bg_hight))
    reward_bg:setPosition(ccp(g_winSize.width*0.5,g_winSize.height*0.5))
    _bgLayer:addChild(reward_bg)
    reward_bg:setTag(4321)
    -- 适配
	setAdaptNode(reward_bg)
	local thisScale = reward_bg:getScale()
 -- 	reward_bg:setScale(0.1*thisScale)
 -- 	local args = CCArray:create()
	-- local scale1 = CCScaleTo:create(0.08,1.2*thisScale)
	-- local scale2 = CCScaleTo:create(0.06,0.9*thisScale)
 --    local scale3 = CCScaleTo:create(0.07,1*thisScale)
 --    args:addObject(scale1)
 --    args:addObject(scale2)
 --    args:addObject(scale3)
 --    reward_bg:runAction(CCSequence:create(args))
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

	-- 确定按钮
	local normalSprite  =CCScale9Sprite:create("images/common/btn/btn_blue_n.png")
	normalSprite:setContentSize(CCSizeMake(180,64))
    local selectSprite  =CCScale9Sprite:create("images/common/btn/btn_blue_h.png")
    selectSprite:setContentSize(CCSizeMake(180,64))
    yesItem = CCMenuItemSprite:create(normalSprite,selectSprite)
	yesItem:setAnchorPoint(ccp(0.5,0))
	yesItem:setPosition(ccp(reward_bg:getContentSize().width*0.5,reward_bg:getContentSize().height*0.08))
	menu:addChild(yesItem)
	-- 注册回调
	yesItem:registerScriptTapHandler(yesItemCallFun)
	-- 字体
	local item_font = CCRenderLabel:create( GetLocalizeStringBy("key_1922") , g_sFontPangWa, 30, 1, ccc3( 0x00, 0x00, 0x00), type_stroke)
    item_font:setColor(ccc3(0xfe, 0xdb, 0x1c))
    item_font:setAnchorPoint(ccp(0.5,0.5))
    item_font:setPosition(ccp(yesItem:getContentSize().width*0.5,yesItem:getContentSize().height*0.5))
   	yesItem:addChild(item_font)

	-- 标题文字
	local title_font = CCRenderLabel:create( _titleText, g_sFontPangWa, 30, 1, ccc3( 0x00, 0x00, 0x00), type_stroke)
    title_font:setColor(ccc3(0xff, 0xc6, 0x00))
    title_font:setAnchorPoint(ccp(0.5,1))
    title_font:setPosition(ccp(reward_bg:getContentSize().width*0.5,reward_bg:getContentSize().height*0.9))
    reward_bg:addChild(title_font)

    -- 物品区域
    local itemBg = CCScale9Sprite:create("images/copy/fort/textbg.png")
	itemBg:setContentSize(CCSizeMake(480, itemBg_hight))
	itemBg:setAnchorPoint(ccp(0.5, 0.5))
	itemBg:setPosition(ccp(reward_bg:getContentSize().width*0.5,reward_bg:getContentSize().height*0.5))
	reward_bg:addChild(itemBg)

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

	-- 新手引导
	if(didLoadEvent) then
    	local seq = CCSequence:createWithTwoActions(CCDelayTime:create(0.3),CCCallFunc:create(function ( ... )
			didLoadEvent()
		end))
		reward_bg:runAction(seq)
    end
end


-- 创建物品列表
-- 参数 物品的列表
function createItemTableView( itemArr_data )
	local itemData = itemArr_data or {}
	local cellSize = CCSizeMake(470, 140)
	local h = LuaEventHandler:create(function(fn, table, a1, a2) 	--创建
		local r
		if fn == "cellSize" then
			r = cellSize
		elseif fn == "cellAtIndex" then
			a2 = CCTableViewCell:create()
			local posArrX = {0.14,0.38,0.62,0.86}
			for i=1,4 do
				if(itemData[a1*4+i] ~= nil)then
					local item_sprite = createRewardCell(itemData[a1*4+i])
					item_sprite:setAnchorPoint(ccp(0.5,1))
					item_sprite:setPosition(ccp(470*posArrX[i],130))
					a2:addChild(item_sprite)
				end
			end
			r = a2
		elseif fn == "numberOfCells" then
			local num = #itemData
			r = math.ceil(num/4)
			print("num is : ", num)
		elseif fn == "cellTouched" then
			
		elseif (fn == "scroll") then
			
		end
		return r
	end)

	local goodTableView = LuaTableView:createWithHandler(h, CCSizeMake(470, tableView_hight))
	goodTableView:setBounceable(true)
	goodTableView:setTouchPriority(tView_priority)
	-- 上下滑动
	goodTableView:setDirection(kCCScrollViewDirectionVertical)
	goodTableView:setVerticalFillOrder(kCCTableViewFillTopDown)

	return goodTableView
end


-- 创建物品图标
function createRewardCell( cellValues )
	local iconBg = nil
	local iconName = nil
	local nameColor = nil
	if(cellValues.type == "silver") then
		-- 银币
		iconBg= ItemSprite.getSiliverIconSprite()
		iconName = GetLocalizeStringBy("key_1687")
		local quality = ItemSprite.getSilverQuality()
        nameColor = HeroPublicLua.getCCColorByStarLevel(quality)
	elseif(cellValues.type == "soul") then
		-- 将魂
		iconBg= ItemSprite.getSoulIconSprite()
		iconName = GetLocalizeStringBy("key_1616")
		local quality = ItemSprite.getSoulQuality()
        nameColor = HeroPublicLua.getCCColorByStarLevel(quality)
	elseif(cellValues.type == "gold") then
		-- 金币
		iconBg= ItemSprite.getGoldIconSprite()
		iconName = GetLocalizeStringBy("key_1491")
		local quality = ItemSprite.getGoldQuality()
        nameColor = HeroPublicLua.getCCColorByStarLevel(quality)
	elseif(cellValues.type == "item") then
		-- 物品
		if (tonumber(cellValues.tid) >= 400001 and tonumber(cellValues.tid) <= 500000) then
			-- 特殊需求 点击武魂图标查看武将信息
			iconBg = ItemSprite.getHeroSoulSprite(tonumber(cellValues.tid),tView_menuPriority,layer_zOrder+1,tView_infoPriority)
			local itemData = ItemUtil.getItemById(cellValues.tid)
	        iconName = itemData.name
	        nameColor = HeroPublicLua.getCCColorByStarLevel(itemData.quality)
	    else
			-- 物品
			iconBg =  ItemSprite.getItemSpriteById(tonumber(cellValues.tid),nil, nil, nil, tView_menuPriority,layer_zOrder+1,tView_infoPriority)
			local itemData = ItemUtil.getItemById(cellValues.tid)
	        iconName = ItemUtil.getItemNameByTid(cellValues.tid)
	        nameColor = HeroPublicLua.getCCColorByStarLevel(itemData.quality)
	    end
	elseif(cellValues.type == "hero") then
		-- 英雄
		require "db/DB_Heroes"
		-- iconBg = HeroPublicCC.getCMISHeadIconByHtid(cellValues.tid)
		iconBg = ItemSprite.getHeroIconItemByhtid(cellValues.tid,tView_menuPriority,layer_zOrder+1,tView_infoPriority)
		local heroData = DB_Heroes.getDataById(cellValues.tid)
		iconName = heroData.name
		nameColor = HeroPublicLua.getCCColorByStarLevel(heroData.star_lv)
	elseif(cellValues.type == "prestige") then
		-- 声望
		iconBg= ItemSprite.getPrestigeSprite()
		iconName = GetLocalizeStringBy("key_2231")
		local quality = ItemSprite.getPrestigeQuality()
        nameColor = HeroPublicLua.getCCColorByStarLevel(quality)
    elseif(cellValues.type == "jewel") then
		-- 魂玉
		iconBg= ItemSprite.getJewelSprite()
		iconName = GetLocalizeStringBy("key_1510")
		local quality = ItemSprite.getJewelQuality()
        nameColor = HeroPublicLua.getCCColorByStarLevel(quality)
    elseif(cellValues.type == "execution") then
		-- 体力
		iconBg= ItemSprite.getExecutionSprite()
		iconName = GetLocalizeStringBy("key_1032")
		local quality = ItemSprite.getExecutionQuality()
        nameColor = HeroPublicLua.getCCColorByStarLevel(quality)
    elseif(cellValues.type == "stamina") then
		-- 耐力
		iconBg= ItemSprite.getStaminaSprite()
		iconName = GetLocalizeStringBy("key_2021")
		local quality = ItemSprite.getStaminaQuality()
        nameColor = HeroPublicLua.getCCColorByStarLevel(quality)
    elseif(cellValues.type == "honor") then
		-- 荣誉
		iconBg= ItemSprite.getHonorIconSprite()
		iconName = GetLocalizeStringBy("lcy_10040")
		local quality = ItemSprite.getHonorQuality()
        nameColor = HeroPublicLua.getCCColorByStarLevel(quality)
    elseif(cellValues.type == "contri") then
		-- 贡献
		iconBg= ItemSprite.getContriIconSprite()
		iconName = GetLocalizeStringBy("lcy_10041")
		local quality = ItemSprite.getContriQuality()
        nameColor = HeroPublicLua.getCCColorByStarLevel(quality)
    elseif(cellValues.type == "grain") then
		-- 贡献
		iconBg= ItemSprite.getGrainSprite()
		iconName = GetLocalizeStringBy("lcyx_101")
		local quality = ItemSprite.getGrainQuality()
        nameColor = HeroPublicLua.getCCColorByStarLevel(quality)
    elseif(cellValues.type == "coin") then
		-- 神兵令
		iconBg= ItemSprite.getGodWeaponTokenSprite()
		iconName = GetLocalizeStringBy("lcyx_149")
		local quality = ItemSprite.getGodWeaponTokenSpriteQuality()
        nameColor = HeroPublicLua.getCCColorByStarLevel(quality)
    elseif(cellValues.type == "zg") then
		-- 战功
		iconBg= ItemSprite.getBattleAchieIcon()
		iconName = GetLocalizeStringBy("lcyx_1819")
		local quality = ItemSprite.getBattleAchieQuality()
        nameColor = HeroPublicLua.getCCColorByStarLevel(quality)
    elseif(cellValues.type == "tg_num") then
		-- 天工令
		iconBg= ItemSprite.getTianGongLingIcon()
		iconName = GetLocalizeStringBy("lic_1561")
		local quality = ItemSprite.getTianGongLingQuality()
        nameColor = HeroPublicLua.getCCColorByStarLevel(quality)
    elseif(cellValues.type == "wm_num") then
		-- 争霸令
		iconBg= ItemSprite.getWmIcon()
		iconName = GetLocalizeStringBy("lcyx_1912")
		local quality = ItemSprite.getWmQuality()
        nameColor = HeroPublicLua.getCCColorByStarLevel(quality)
    elseif(cellValues.type == "hellPoint") then
		-- 炼狱令
		iconBg= ItemSprite.getHellPointIcon()
		iconName = GetLocalizeStringBy("lcyx_1917")
		local quality = ItemSprite.getHellPointQuality()
        nameColor = HeroPublicLua.getCCColorByStarLevel(quality)
    elseif ( cellValues.type == "cross_honor" ) then
		-- 跨服比武  add by yangrui 15-10-13
		iconBg = ItemSprite.getKFBWHonorIcon()
		iconName = GetLocalizeStringBy("yr_2002")
		local quality = ItemSprite.getKFBWHonorQuality()
        nameColor = HeroPublicLua.getCCColorByStarLevel(quality)
    elseif ( cellValues.type == "fs_exp" ) then
    	-- 战魂经验
		iconBg = ItemSprite.getFSExpIconSprite()
		iconName = GetLocalizeStringBy("lic_1736")
		local quality = ItemSprite.getFSExpQuality()
        nameColor = HeroPublicLua.getCCColorByStarLevel(quality)
    elseif (cellValues.type == "jh") then
    	-- 将星
    	iconBg = ItemSprite.getHeroJhIcon()
		iconName = GetLocalizeStringBy("syx_1053")
		local quality = ItemSprite.getHeroJhQuality()
        nameColor = HeroPublicLua.getCCColorByStarLevel(quality)
    elseif (cellValues.type == "copoint") then
    	-- 国战积分
    	iconBg = ItemSprite.getCopointIcon()
		iconName = GetLocalizeStringBy("fqq_015")
		local quality = ItemSprite.getCopointQuality()
        nameColor = HeroPublicLua.getCCColorByStarLevel(quality)
     elseif ( cellValues.type == "tally_point" ) then 
    	-- 兵符积分
		iconBg = ItemSprite.getTallyPointIcon()
		iconName = GetLocalizeStringBy("syx_1072")
		local quality = ItemSprite.getTallyPointQuality()
        nameColor = HeroPublicLua.getCCColorByStarLevel(quality)
    elseif ( cellValues.type == "book_num" ) then 
    	-- 科技图纸
		iconBg = ItemSprite.getBookIcon()
		iconName = GetLocalizeStringBy("lic_1812")
		local quality = ItemSprite.getBookQuality()
        nameColor = HeroPublicLua.getCCColorByStarLevel(quality)
    elseif ( cellValues.type == "tower_num" ) then 
    	-- 试炼币
		iconBg = ItemSprite.getTowerNumIcon()
		iconName = GetLocalizeStringBy("lic_1845")
		local quality = ItemSprite.getTowerNumQuality()
        nameColor = HeroPublicLua.getCCColorByStarLevel(quality)
    elseif ( cellValues.type == "star_point" ) then 
    	-- 星魄
		iconBg = ItemSprite.getStarPointIcon()
		iconName = GetLocalizeStringBy("lic_1844")
		local quality = ItemSprite.getStarPointQuality()
        nameColor = HeroPublicLua.getCCColorByStarLevel(quality)
    elseif ( cellValues.type == "exp_num" ) then 
    	-- 经验
		iconBg = ItemSprite.getExpNumIcon()
		iconName = GetLocalizeStringBy("lic_1847")
		local quality = ItemSprite.getExpNumQuality()
        nameColor = HeroPublicLua.getCCColorByStarLevel(quality)
    else

	end
	printTable("cellValues", cellValues)
	-- 物品数量
	if( tonumber(cellValues.num) > 1 )then
		local numberLabel = CCRenderLabel:create(tostring(cellValues.num),g_sFontName,21,2,ccc3(0x00,0x00,0x00),type_stroke)-- modified by yangrui at 2015-12-03
		numberLabel:setColor(ccc3(0x00,0xff,0x18))
		numberLabel:setAnchorPoint(ccp(0,0))
		local width = iconBg:getContentSize().width - numberLabel:getContentSize().width - 6
		numberLabel:setPosition(ccp(width,5))
		iconBg:addChild(numberLabel,100)
	end

	--- desc 物品名字
	local descLabel = CCRenderLabel:create("" .. iconName , g_sFontName,21,1,ccc3(0x00,0x00,0x00),type_stroke)
	descLabel:setColor(nameColor)
	descLabel:setAnchorPoint(ccp(0.5,0.5))
	descLabel:setPosition(ccp(iconBg:getContentSize().width*0.5 ,-iconBg:getContentSize().height*0.2))
	iconBg:addChild(descLabel)

	return iconBg
end


-- touch事件处理
function cardLayerTouch(eventType, x, y)
    return true   
end


-- 确定按钮回调
function yesItemCallFun( ... )
	-- 音效
	require "script/audio/AudioUtil"
	AudioUtil.playEffect("audio/effect/guanbi.mp3")
	if(_bgLayer ~= nil)then
		_bgLayer:removeFromParentAndCleanup(true)
		_bgLayer = nil
	end
	-- 如果有后续回调则调用
	if(otherCallFun ~= nil)then
		otherCallFun( _callFunArgs )
	end
	-- 新手引导
	didClickEnter()
end



--[[
	@des:	得到确定按钮
]]
function getEnterButton( ... )
	return yesItem
end


--[[
	@des:	新手引导方法
]]
function didLoadEvent( ... )

	---[==[  等级礼包 第2.5步 点击弹出框的确定按钮 
	---------------------新手引导---------------------------------
	    --add by licong 2013.09.11
	    require "script/guide/NewGuide"
		require "script/guide/LevelGiftBagGuide"
	    if(NewGuide.guideClass ==  ksGuideFiveLevelGift and LevelGiftBagGuide.stepNum == 2) then
		    local levelGiftBagGuide_button = getEnterButton()
		    local touchRect = getSpriteScreenRect(levelGiftBagGuide_button)
		    LevelGiftBagGuide.show(2.5, touchRect)
	   	end
	 ---------------------end-------------------------------------
	--]==]

	---[==[  副本箱子 第2.5步 点击弹出框的确定按钮 
	---------------------新手引导---------------------------------
	    --add by licong 2013.09.11
	    require "script/guide/NewGuide"
		require "script/guide/CopyBoxGuide"
	    if(NewGuide.guideClass ==  ksGuideCopyBox and CopyBoxGuide.stepNum == 2) then
		    local copyBoxGuide_button = getEnterButton()
		    local touchRect = getSpriteScreenRect(copyBoxGuide_button)
		    CopyBoxGuide.show(2.5, touchRect)
	   	end
	 ---------------------end-------------------------------------
	--]==]
	--签到引导
	require "script/ui/sign/SignRewardCell"
    if(NewGuide.guideClass ==  ksGuideSignIn and SignInGuide.stepNum == 2) then
        SignInGuide.changLayer()
        local buttonRect = getEnterButton()
        local touchRect  = getSpriteScreenRect(buttonRect)
        SignInGuide.show(2.5, touchRect)
        print("didLoadEvent signLayerDidLoadCallback")
    end       

    ---[==[占星 第9步
	---------------------新手引导---------------------------------
    require "script/guide/AstrologyGuide"
    if(NewGuide.guideClass ==  ksGuideAstrology and AstrologyGuide.stepNum == 8) then
    	local copyBoxGuide_button = getEnterButton()
		local touchRect = getSpriteScreenRect(copyBoxGuide_button)
        AstrologyGuide.show(9, touchRect)
    end
	---------------------end-------------------------------------
	--]==]  	

end

--[[
	@des:	点击确定按钮新手引导
]]
function didClickEnter( ... )
	---[==[ 第三步等级礼包关闭按钮
	---------------------新手引导---------------------------------
	    --add by licong 2013.09.09
	    require "script/guide/NewGuide"
		print("g_guideClass = ", NewGuide.guideClass)
	    require "script/guide/LevelGiftBagGuide"
	    if(NewGuide.guideClass ==  ksGuideFiveLevelGift and LevelGiftBagGuide.stepNum == 2.5) then
	    	LevelGiftBagGuide.changLayer()
	        require "script/ui/level_reward/LevelRewardLayer"
	        local levelGiftBagGuide_button = LevelRewardLayer.getCloseBtn()
	        local touchRect = getSpriteScreenRect(levelGiftBagGuide_button)
	        LevelGiftBagGuide.show(3, touchRect)
	    end
	---------------------end-------------------------------------
	--]==]

	---[==[  副本箱子 第3步 领取后点击返回按钮
	---------------------新手引导---------------------------------
	    --add by licong 2013.09.11
	    require "script/guide/NewGuide"
		require "script/guide/CopyBoxGuide"
	    if(NewGuide.guideClass ==  ksGuideCopyBox and CopyBoxGuide.stepNum == 2.5) then
	    	CopyBoxGuide.changLayer()
		    require "script/ui/copy/FortsLayout"
		    local copyBoxGuide_button = FortsLayout.getGuideObject_3()
		    local touchRect = getSpriteScreenRect(copyBoxGuide_button)
		    CopyBoxGuide.show(3, touchRect)
		    CopyBoxGuide.stepNum = 7
	   	end
	 ---------------------end-------------------------------------
	--]==]
	
	 if(NewGuide.guideClass ==  ksGuideSignIn and SignInGuide.stepNum == 2.5) then
	    SignInGuide.changLayer()
	    local buttonRect = SignRewardLayer.getCancelBtn()
	    local touchRect  = getSpriteScreenRect(buttonRect)
	    SignInGuide.show(3, touchRect)
	    print("signLayerDidLoadCallback")
	end   

	---[==[占星 第10步
	---------------------新手引导---------------------------------
    require "script/guide/AstrologyGuide"
    if(NewGuide.guideClass ==  ksGuideAstrology and AstrologyGuide.stepNum == 9) then
    	AstrologyGuide.changLayer()
        AstrologyGuide.show(10, nil)
    end
	---------------------end-------------------------------------
	--]==]  	
end































