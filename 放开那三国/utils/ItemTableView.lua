--Filename:ItemTableView.lua
--Author：lichenyang
--Date：2013/8/27
--Purpose:创建一个物品列表

require "script/libs/LuaCCMenuItem"
require "script/ui/hero/HeroPublicLua"
require "script/audio/AudioUtil"

ItemTableView = class("ItemTableView", function ()
	local colorLayer = CCLayerColor:create(ccc4(0, 0, 0, 200))
	colorLayer:setPosition(ccp(0, 0))
	colorLayer:setAnchorPoint(ccp(0, 0))
	colorLayer:setTouchEnabled(true)
	colorLayer:setTouchPriority(-512)
	colorLayer:registerScriptTouchHandler(function ( eventType,x,y )
		if(eventType == "began") then
			return true
		end
		print(eventType)
	end,false, - 512, true)
	return colorLayer
end)

ItemTableView.__index = ItemTableView

ItemTableView.titlePanel = nil
ItemTableView.titleLabel = nil
ItemTableView.titleLabel = nil
ItemTableView.tableBackground = nil
ItemTableView.contentLabelNode = nil
ItemTableView.closeButton = nil
ItemTableView.closeEvent  = nil
ItemTableView.sureButton  = nil
ItemTableView.sureEvent   = nil

 ----------[私有变量]----------
 local createCell = function ( cell_info )
 	local tableCell = CCTableViewCell:create()

 	local cellBackground = CCScale9Sprite:create("images/reward/cell_back.png")
	cellBackground:setContentSize(CCSizeMake(501, 157))
	tableCell:addChild(cellBackground)

	local spriteLine = CCScale9Sprite:create("images/common/line01.png")
	spriteLine:setContentSize(CCSizeMake(327, 4))
	--spriteLine:setAnchorPoint(ccp(0,0.5))
	spriteLine:setPosition(ccp(115, 98))
	cellBackground:addChild(spriteLine)


	--礼包名称
	local giftNameLabel = CCRenderLabel:create("" , g_sFontName, 28, 1, ccc3(0,0,0))
	--local giftNameLabel = CCLabelTTF:create("",g_sFontPangWa,36) 
	giftNameLabel:setColor(ccc3(0xfe, 0xdb, 0x1c))
	-- giftNameLabel:setAnchorPoint(ccp(0,1))
	giftNameLabel:setPosition(ccp(124 , 138))
	cellBackground:addChild(giftNameLabel,9)

	local giftDescLabel = CCLabelTTF:create("", g_sFontName, 24, CCSizeMake(350,99), kCCTextAlignmentLeft)
	giftDescLabel:setColor(ccc3(0x78, 0x25,0x00))
	giftDescLabel:setPosition(ccp(124, 98))
	giftDescLabel:setAnchorPoint(ccp(0, 1))
	cellBackground:addChild(giftDescLabel)

	local giftNumberLabel = CCRenderLabel:createWithAlign("" ,g_sFontName,24,1,ccc3(0,0,0), type_stroke,CCSizeMake(330,30),kCCTextAlignmentLeft,kCCVerticalTextAlignmentTop)
	giftNumberLabel:setColor(ccc3(0xff, 0xff,0xff))
	giftNumberLabel:setPosition(ccp(340, 133))
	giftNumberLabel:setAnchorPoint(ccp(0, 1))
	cellBackground:addChild(giftNumberLabel,10)

	local iconSprite = nil
	if(cell_info.type == "item") then
		require "script/ui/item/ItemSprite"
		require "script/ui/item/ItemUtil"		
		local itemTableInfo = ItemUtil.getItemById(tonumber(cell_info.tid))
		iconSprite = ItemSprite.getItemSpriteByItemId(tonumber(cell_info.tid), nil, function ( ... )
			require "script/ui/main/MainScene"
			MainScene.setMainSceneViewsVisible(true, false, true)
		end, nil, -900, 20000)
		local color  = HeroPublicLua.getCCColorByStarLevel(itemTableInfo.quality)
		giftNameLabel:setColor(color)
		giftDescLabel:setString(itemTableInfo.desc)
		giftNameLabel:setString(itemTableInfo.name)
		giftDescLabel:setString(itemTableInfo.desc)
	elseif(cell_info.type == "gold")  then
		require "script/ui/item/ItemSprite"
		iconSprite = ItemSprite.getGoldIconSprite()
		giftNameLabel:setString(GetLocalizeStringBy("key_1491"))
		local goldQuality = ItemSprite.getGoldQuality()
		local color  = HeroPublicLua.getCCColorByStarLevel(goldQuality)
		giftNameLabel:setColor(color)
		giftDescLabel:setString(GetLocalizeStringBy("key_1855"))
	elseif(cell_info.type == "silver") then
		require "script/ui/item/ItemSprite"
		iconSprite = ItemSprite.getSiliverIconSprite()
		giftNameLabel:setString(GetLocalizeStringBy("key_1687"))
		local silverQuality = ItemSprite.getSilverQuality()
		local color  = HeroPublicLua.getCCColorByStarLevel(silverQuality)
		giftNameLabel:setColor(color)
		giftDescLabel:setString(GetLocalizeStringBy("key_2552"))
	elseif(cell_info.type == "soul") then
		require "script/ui/item/ItemSprite"
		iconSprite = ItemSprite.getSoulIconSprite()
		giftNameLabel:setString(GetLocalizeStringBy("key_1616"))
		local soulQuality = ItemSprite.getSoulQuality()
		local color  = HeroPublicLua.getCCColorByStarLevel(soulQuality)
		giftNameLabel:setColor(color)
		giftDescLabel:setString(GetLocalizeStringBy("key_1683"))
		--added by zhz
	elseif(cell_info.type == "execution") then
		iconSprite = CCSprite:create("images/online/reward/energy_big.png")
		giftNameLabel:setString(GetLocalizeStringBy("key_3221"))
		giftDescLabel:setString(GetLocalizeStringBy("key_2455"))
	elseif(cell_info.type == "stamina") then
		iconSprite = CCSprite:create("images/online/reward/stain_big.png")
		giftNameLabel:setString(GetLocalizeStringBy("key_1451"))
		giftDescLabel:setString(GetLocalizeStringBy("key_1993"))
	elseif(cell_info.type == "hero") then
		require "script/ui/hero/HeroPublicCC"
		require "db/DB_Heroes"
		iconSprite=  HeroPublicCC.getCMISHeadIconByHtid(tonumber(cell_info.tid))
		local heroTable = DB_Heroes.getDataById(cell_info.tid)
		giftNameLabel:setString(heroTable.name)
		giftDescLabel:setString(heroTable.desc)

	end
	-- -----------
	iconSprite:setAnchorPoint(ccp(0, 0.5))
	iconSprite:setPosition(ccp(15, cellBackground:getContentSize().height/2))
	cellBackground:addChild(iconSprite)	
	giftNumberLabel:setString(GetLocalizeStringBy("key_1486") .. cell_info.num)

	return tableCell
 end

local updateCell = function ( cell,cell_info )
	
end

-- table_data：-- 耐力，体力 added by zhz
-- [
-- 	{
-- 		type:(item,gold,silver,soul,execution,stamina) 物品类型（普通物品，金币，银币，将魂,体力, 耐力）
-- 		tid:物品模板id
-- 		num:物品数量
-- 	}
-- ]
function ItemTableView:create( table_data )
	print("ItemTableView:create:")
	print_t(table_data)

	local itemTable = ItemTableView:new()

	local backgroundContentSize = nil
	if(#table_data > 2) then
		backgroundContentSize = CCSizeMake(568, 633)
	else
		backgroundContentSize = CCSizeMake(568, #table_data * 154 + 150)
	end
	itemTable.background = CCScale9Sprite:create("images/common/viewbg1.png")
	itemTable.background:setContentSize(backgroundContentSize)
	itemTable.background:setAnchorPoint(ccp(0.5, 0.5))
	itemTable.background:setPosition(ccp(g_winSize.width/2, g_winSize.height/2))
	itemTable:addChild(itemTable.background)
	AdaptTool.setAdaptNode(itemTable.background)

	--标题
	itemTable.titlePanel = CCSprite:create("images/common/viewtitle1.png")
	itemTable.titlePanel:setAnchorPoint(ccp(0.5, 0.5))
	itemTable.titlePanel:setPosition(itemTable.background:getContentSize().width/2, itemTable.background:getContentSize().height - 7 )
	itemTable.background:addChild(itemTable.titlePanel)
	itemTable.titlePanel:setVisible(setVisible)

	-- itemTable.titleLabel =  CCLabelTTF:create("", g_sFontPangWa, 35)
	itemTable.titleLabel = CCRenderLabel:create("", g_sFontPangWa, 35, 1, ccc3(0,0,0))
	itemTable.titleLabel:setAnchorPoint(ccp(0,1))
	itemTable.titleLabel:setColor(ccc3(0xff, 0xe4, 0x00))
	local x = (itemTable.titlePanel:getContentSize().width - itemTable.titleLabel:getContentSize().width)/2
	local y = itemTable.titlePanel:getContentSize().height - (itemTable.titlePanel:getContentSize().height - itemTable.titleLabel:getContentSize().height)/2
	itemTable.titleLabel:setPosition(ccp(x , y))
	itemTable.titlePanel:addChild(itemTable.titleLabel)

	local tableBackgroundContentSize = nil
	if(#table_data > 2) then
		tableBackgroundContentSize = CCSizeMake(520, 505)
	else
		tableBackgroundContentSize = CCSizeMake(520, #table_data * 154 + 30)
	end

	itemTable.tableBackground = CCScale9Sprite:create("images/common/bg/bg_ng_attr.png")
	itemTable.tableBackground:setContentSize(tableBackgroundContentSize)
	itemTable.tableBackground:setAnchorPoint(ccp(0.5, 0))
	itemTable.tableBackground:setPosition(ccp(itemTable.background:getContentSize().width*0.5, 64))
	itemTable.background:addChild(itemTable.tableBackground)

	-- 创建列表
	local  function contentTableCallback(fn, t_table, a1, a2)
		local r
		if fn == "cellSize" then
			r = CCSizeMake(500, 155)
		elseif fn == "cellAtIndex" then
			a2 = createCell(table_data[a1 + 1])
			r = a2
		elseif fn == "numberOfCells" then
			r = #table_data
		elseif fn == "cellTouched" then
			
		end
		return r
	end
	local tableContentSize = nil
	if(#table_data > 2) then
		tableContentSize = CCSizeMake(510, 495)
	else
		tableContentSize = CCSizeMake(510, #table_data * 154 + 18)
	end

	local contentTable = LuaTableView:createWithHandler(LuaEventHandler:create(contentTableCallback), tableContentSize)
	contentTable:setVerticalFillOrder(kCCTableViewFillTopDown)
	contentTable:setBounceable(true)
	contentTable:setAnchorPoint(ccp(0, 0))
	contentTable:setPosition(ccp(9, 5))
	contentTable:setTouchPriority(-1024)
	itemTable.tableBackground:addChild(contentTable,30)

	local menu = CCMenu:create()
	menu:setPosition(ccp(0, 0))
	menu:setAnchorPoint(ccp(0,0))
	menu:setTouchPriority(-800)
	itemTable.background:addChild(menu)

	itemTable.closeButton = CCMenuItemImage:create("images/common/btn_close_n.png","images/common/btn_close_h.png")
	itemTable.closeButton:setPosition(ccp(itemTable.background:getContentSize().width * 0.96, itemTable.background:getContentSize().height * 0.96))
	itemTable.closeButton:setAnchorPoint(ccp(0.5, 0.5))
	itemTable.closeButton:registerScriptTapHandler(function ( ... )
		itemTable:removeFromParentAndCleanup(true)
		AudioUtil.playEffect("audio/effect/guanbi.mp3")
		if(itemTable.closeEvent ~= nil) then
			itemTable.closeEvent()
		end
	end)
	menu:addChild(itemTable.closeButton)

	return itemTable
end


function ItemTableView:setTitle( titleStr )
	self.titlePanel:setVisible(true)
	self.titleLabel:setString(titleStr)
	local x = (self.titlePanel:getContentSize().width - self.titleLabel:getContentSize().width)/2
	local y = self.titlePanel:getContentSize().height - (self.titlePanel:getContentSize().height - self.titleLabel:getContentSize().height)/2
	self.titleLabel:setPosition(ccp(x , y))
end

function ItemTableView:setContentTitle( p_node )
	
	if(self.contentLabelNode ~= nil) then
		self.contentLabelNode:removeFromParentAndCleanup(true)
		self.contentLabelNode = nil
	end

	local backgourndOffset = 0
	local tableViewOffset  = 0
	local contentNodeOffset = 0
	if(self.titlePanel:isVisible() == true) then
		backgourndOffset = 20
		tableViewOffset = 20
		contentNodeOffset = 45
	else
		backgourndOffset = 45
		tableViewOffset  =  30
		contentNodeOffset = 25
	end 

	-- added by zhz
	if(self.sureButton ~=nil) then
		tableViewOffset=tableViewOffset+30
	end

	if(p_node == nil) then
		self.tableBackground:setPosition(self.tableBackground:getPositionX(), self.tableBackground:getPositionY() - self.contentLabelNode:getContentSize().height)
		return
	end

	self.contentLabelNode = p_node
	--更新背景大小
	local backgroundContentSizd = CCSizeMake(self.background:getContentSize().width, self.background:getContentSize().height + self.contentLabelNode:getContentSize().height- backgourndOffset)
	self.background:setContentSize(backgroundContentSizd)
	--更新tableView位置
	self.tableBackground:setPosition(self.tableBackground:getPositionX(), self.tableBackground:getPositionY() - self.contentLabelNode:getContentSize().height + tableViewOffset)
	--更新标题位置
	self.titlePanel:setPosition(self.background:getContentSize().width/2, self.background:getContentSize().height - 7 )
	--更新关闭按钮位置
	self.closeButton:setPosition(ccp(self.background:getContentSize().width * 0.96, self.background:getContentSize().height * 0.96))
	--设置
	self.contentLabelNode:setAnchorPoint(ccp(0.5, 1))
	self.contentLabelNode:setPosition(ccp(self.background:getContentSize().width/2, self.background:getContentSize().height - contentNodeOffset))
	self.background:addChild(self.contentLabelNode)
end


-- added by zhz
--[[
	@desc: 在layer,下面加一个按钮
	@para:Table:{ img_n = "" , img_h="",size, txt="",txtColor="" }:详见 :LuaCC.create9ScaleMenuItem
		"img_n","img_h",CCSizeMake(200, 73),GetLocalizeStringBy("key_1715"),ccc3(0xfe, 0xdb, 0x1c),35,g_sFontPangWa,1, ccc3(0x00, 0x00, 0x00)

--]]
function ItemTableView:addSureBtn(tParam)

	local menu = CCMenu:create()
	menu:setPosition(ccp(0, 0))
	menu:setAnchorPoint(ccp(0,0))
	menu:setTouchPriority(-800)
	self.background:addChild(menu)

	self.sureButton=LuaCC.create9ScaleMenuItem( tParam.img_n, tParam.img_h, tParam.size, tParam.txt,  tParam.txtColor, tParam.txtSize, tParam.font ,tParam.strokeSize, tParam.strokeColor ) 
	self.sureButton:setPosition(ccp(self.background:getContentSize().width * 0.5, 20))
	self.sureButton:setAnchorPoint(ccp(0.5, 0))
	self.sureButton:registerScriptTapHandler(function ( ... )
		self:removeFromParentAndCleanup(true)
		AudioUtil.playEffect("audio/effect/guanbi.mp3")
		if(self.sureEvent ~= nil) then
			self.sureEvent()
		end
	end)

	menu:addChild(self.sureButton)
	self.tableBackground:setPosition(ccp(self.background:getContentSize().width*0.5, 80))

	local backgroundSize= self.background:getContentSize()
	self.background:setContentSize( CCSizeMake(self.background:getContentSize().width, self.background:getContentSize().height+50) )
	
end

function ItemTableView:registerClosedEvent( callbackFunc )
	self.closeEvent = callbackFunc
end

-- 注册 sure的回调函数
function ItemTableView:registerScriptSureEvent(callbackFunc)
	self.sureEvent= callbackFunc
end


