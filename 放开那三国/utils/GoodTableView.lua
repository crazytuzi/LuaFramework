--Filename:GoodTableView.lua
--Author：lichenyang   changed by zhz
--Date：2013/10/10
--Purpose:创建一个物品列表   第2个type


module ("GoodTableView", package.seeall)

require "script/libs/LuaCCMenuItem"
require "script/ui/hero/HeroPublicLua"
require "script/audio/AudioUtil"
require "script/utils/BaseUI"
require "script/ui/bag/BagUtil"

ItemTableView = class("ItemTableView", function ()
	local colorLayer = CCLayerColor:create(ccc4(0, 0, 0, 200))
	colorLayer:setPosition(ccp(0, 0))
	colorLayer:setAnchorPoint(ccp(0, 0))
	colorLayer:setTouchEnabled(true)
	colorLayer:setTouchPriority(-1021)
	colorLayer:registerScriptTouchHandler(function ( eventType,x,y )
		if(eventType == "began") then
			return true
		end
		print(eventType)
	end,false, -789, true)
	return colorLayer
end)

ItemTableView.__index = ItemTableView

local enterButton = nil
local _ksTagmenu= 101


ItemTableView.titlePanel = nil
ItemTableView.titleLabel = nil
ItemTableView.background = nil
ItemTableView.tableBackground = nil
ItemTableView.contentLabelNode = nil
-- ItemTableView.expNode = nil
ItemTableView.closeButton = nil
ItemTableView.closeEvent  = nil
ItemTableView.sureButton = nil
ItemTableView.contentTable = nil
ItemTableView.goolLuckSp = nil


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
	local giftNameLabel = CCRenderLabel:create("" , g_sFontName, 28, 1, ccc3(0,0,0),type_stroke)
	--local giftNameLabel = CCLabelTTF:create("",g_sFontPangWa,36) 
	giftNameLabel:setColor(ccc3(0xfe, 0xdb, 0x1c))
	-- giftNameLabel:setAnchorPoint(ccp(0,1))
	giftNameLabel:setPosition(ccp(124 , 138))
	cellBackground:addChild(giftNameLabel,9)

	if(cell_info.type == "item" ) then
		local sealSprite= BagUtil.getSealSpriteByItemTempId(cell_info.tid)
		sealSprite:setPosition(ccp(126, 138))
		sealSprite:setAnchorPoint(ccp(0,1))
		giftNameLabel:setPosition(ccp(124+sealSprite:getContentSize().width+3, 138))
		cellBackground:addChild(sealSprite)
	elseif(cell_info.type== "silver" or cell_info.type == "gold" or cell_info.type == "soul" ) then
		local sealSprite= BagUtil.getSealSpriteByItemTempId()
		sealSprite:setPosition(ccp(126, 138))
		sealSprite:setAnchorPoint(ccp(0,1))
		giftNameLabel:setPosition(ccp(124+sealSprite:getContentSize().width+3, 138))
		cellBackground:addChild(sealSprite)
	end


	local giftDescLabel = CCLabelTTF:create("", g_sFontName, 24, CCSizeMake(350,80), kCCTextAlignmentLeft)
	giftDescLabel:setColor(ccc3(0x78, 0x25,0x00))
	giftDescLabel:setPosition(ccp(124, 98))
	giftDescLabel:setAnchorPoint(ccp(0, 1))
	cellBackground:addChild(giftDescLabel)

	local iconSprite = nil
	if(cell_info.type == "item") then
		require "script/ui/item/ItemSprite"
		require "script/ui/item/ItemUtil"		
		local itemTableInfo = ItemUtil.getItemById(tonumber(cell_info.tid))
		iconSprite = ItemSprite.getItemSpriteByItemId(tonumber(cell_info.tid))
	
		local name = itemTableInfo.name
		local itemDesc= itemTableInfo.desc or itemTableInfo.info
		-- print("itemDesc==>",itemDesc,itemTableInfo.desc,itemTableInfo.info)
		-- print_t(itemTableInfo)
		if(tonumber(itemTableInfo.id) >= 1800000 and tonumber(itemTableInfo.id)<= 1900000 ) then
			itemDesc = ItemSprite.getStringByFashionString(itemDesc)
			name     = ItemSprite.getStringByFashionString(name)
		end

		if(tonumber(itemTableInfo.id) >= 80001 and tonumber(itemTableInfo.id)<= 90000 ) then
			itemDesc = ItemSprite.getStringByFashionString(itemDesc)
			name     = ItemSprite.getStringByFashionString(name)
		end
		giftNameLabel:setString(name)
		local color  = HeroPublicLua.getCCColorByStarLevel(tonumber(itemTableInfo.quality))
		giftNameLabel:setColor(color)
		giftDescLabel:setString(itemDesc)
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
		iconSprite = CCSprite:create("images/base/potential/props_3.png")
		local icon = CCSprite:create("images/online/reward/energy_big.png")
		icon:setPosition(ccp(iconSprite:getContentSize().width/2, iconSprite:getContentSize().height/2))
		icon:setAnchorPoint(ccp(0.5,0.5))
		iconSprite:added(icon)
		giftNameLabel:setString(GetLocalizeStringBy("key_3221"))
		giftDescLabel:setString(GetLocalizeStringBy("key_2455"))
	elseif(cell_info.type == "stamina") then
		iconSprite =  CCSprite:create("images/base/potential/props_3.png")
		local icon = CCSprite:create("images/online/reward/energy_big.png")
		icon:setPosition(ccp(iconSprite:getContentSize().width/2, iconSprite:getContentSize().height/2))
		icon:setAnchorPoint(ccp(0.5,0.5))
		iconSprite:added(icon)
		giftNameLabel:setString(GetLocalizeStringBy("key_1451"))
		giftDescLabel:setString(GetLocalizeStringBy("key_1993"))
	elseif(cell_info.type == "hero") then
		require "script/ui/hero/HeroPublicCC"
		require "db/DB_Heroes"
		iconSprite=  HeroPublicCC.getCMISHeadIconByHtid(tonumber(cell_info.tid))
		local heroTable = DB_Heroes.getDataById(cell_info.tid)
		local color = HeroPublicLua.getCCColorByStarLevel(heroTable.star_lv)
		giftNameLabel:setString(heroTable.name)
		giftNameLabel:setColor(color)
		giftDescLabel:setString(heroTable.desc)
	elseif(cell_info.type == "heroSoul") then
		require "db/DB_Item_hero_fragment"
		require "db/DB_Heroes"
		local heroSoulTable = DB_Item_hero_fragment.getDataById(cell_info.tid)
		local aimItem = heroSoulTable.aimItem
		iconSprite=  HeroPublicCC.getCMISHeadIconByHtid(tonumber(aimItem))
		giftNameLabel:setString(heroSoulTable.name)
		giftDescLabel:setString(heroSoulTable.desc)

	end
	-- -----------
	iconSprite:setAnchorPoint(ccp(0, 0.5))
	iconSprite:setPosition(ccp(15, cellBackground:getContentSize().height/2))
	cellBackground:addChild(iconSprite)	

	-- 物品数量
	local giftNumberLabel = CCRenderLabel:create(GetLocalizeStringBy("key_1486") .. cell_info.num,g_sFontName,24,1,ccc3(0,0,0), type_stroke)
	giftNumberLabel:setColor(ccc3(0xff, 0xff,0xff))
	
	-- 越南版本 英文版本
	if(Platform.getLayout ~= nil and Platform.getLayout() == "enLayout" ) then
		giftNumberLabel:setAnchorPoint(ccp(0.5, 1))
		giftNumberLabel:setPosition(ccp(iconSprite:getContentSize().width*0.5, 8))
		iconSprite:addChild(giftNumberLabel,10)
	else
		giftNumberLabel:setPosition(ccp(340, 133))
		giftNumberLabel:setAnchorPoint(ccp(0, 1))
		cellBackground:addChild(giftNumberLabel,10)
	end

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
function ItemTableView:create( table_data , exp )
	print("ItemTableView:create:")
	print_t(table_data)

	local exp = exp or 0
	local itemTable = ItemTableView:new()

	local backgroundContentSize = nil
	if(#table_data > 2) then
		backgroundContentSize = CCSizeMake(568, 659)
	else
		backgroundContentSize = CCSizeMake(568, #table_data * 154 + 180)
	end

	-- 判断exp
	if(#table_data>2 and tonumber(exp )~= 0) then
		backgroundContentSize = CCSizeMake(568, 689)
	elseif(#table_data<=2 and tonumber(exp)~= 0) then
		backgroundContentSize = CCSizeMake(568,#table_data*154 + 230)
	else

	end

	itemTable.background = CCScale9Sprite:create("images/common/viewbg1.png")
	itemTable.background:setContentSize(backgroundContentSize)
	itemTable.background:setAnchorPoint(ccp(0.5, 0.5))
	itemTable.background:setPosition(ccp(g_winSize.width/2, g_winSize.height/2))
	itemTable:addChild(itemTable.background)
	AdaptTool.setAdaptNode(itemTable.background)


	-- 屏幕创建得动画
	itemTable.background:setScale(0.1)
	createAction(itemTable.background)

	--标题
	itemTable.titlePanel = CCScale9Sprite:create("images/common/title_bg.png")
	itemTable.titlePanel:setContentSize(CCSizeMake(564,66))
	itemTable.titlePanel:setAnchorPoint(ccp(0.5, 0.5))
	itemTable.titlePanel:setPosition(itemTable.background:getContentSize().width/2, itemTable.background:getContentSize().height*1.0)
	itemTable.background:addChild(itemTable.titlePanel)
	itemTable.titlePanel:setVisible(setVisible)

	itemTable.goolLuckSp = CCScale9Sprite:create("images/common/luck.png")
	itemTable.goolLuckSp:setAnchorPoint(ccp(0.5, 0.5))
	itemTable.goolLuckSp:setPosition(ccp(itemTable.titlePanel:getContentSize().width/2, itemTable.titlePanel:getContentSize().height/2+2))
	itemTable.titlePanel:addChild(itemTable.goolLuckSp)

	-- itemTable.titleLabel =  CCLabelTTF:create("", g_sFontPangWa, 35)
	itemTable.titleLabel = CCRenderLabel:create("", g_sFontPangWa, 35, 1, ccc3(0,0,0))
	itemTable.titleLabel:setAnchorPoint(ccp(0,1))
	itemTable.titleLabel:setColor(ccc3(0xff, 0xe4, 0x00))
	local x = (itemTable.titlePanel:getContentSize().width - itemTable.titleLabel:getContentSize().width)/2
	local y = itemTable.titlePanel:getContentSize().height - (itemTable.titlePanel:getContentSize().height - itemTable.titleLabel:getContentSize().height)/2
	itemTable.titleLabel:setPosition(ccp(x , y))
	itemTable.titlePanel:addChild(itemTable.titleLabel)

	-- 
	if(exp ~= 0) then

	end

	local tableBackgroundContentSize = nil
	if(#table_data > 2) then
		tableBackgroundContentSize = CCSizeMake(520, 505)
	else
		tableBackgroundContentSize = CCSizeMake(510, #table_data * 154 + 25)
	end

	itemTable.tableBackground = CCScale9Sprite:create("images/common/bg/bg_ng_attr.png")
	itemTable.tableBackground:setContentSize(tableBackgroundContentSize)
	itemTable.tableBackground:setAnchorPoint(ccp(0.5, 0))
	itemTable.tableBackground:setPosition(ccp(itemTable.background:getContentSize().width*0.5, 100))
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

	itemTable.contentTable = LuaTableView:createWithHandler(LuaEventHandler:create(contentTableCallback), tableContentSize)
	itemTable.contentTable:setVerticalFillOrder(kCCTableViewFillTopDown)
	itemTable.contentTable:setBounceable(true)
	itemTable.contentTable:setAnchorPoint(ccp(0, 0))
	itemTable.contentTable:setPosition(ccp(9, 5))
	itemTable.contentTable:setTouchPriority(-1024)
	itemTable.tableBackground:addChild(itemTable.contentTable,30)

	local menu = CCMenu:create()
	menu:setPosition(ccp(0, 0))
	menu:setAnchorPoint(ccp(0,0))
	menu:setTouchPriority(-1028)
	itemTable.background:addChild(menu, 1,101)

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

	--确定按钮

    local tSprite = {normal="images/common/btn/btn_bg_n.png", selected="images/common/btn/btn_bg_h.png"}
 	local tLabel = {text=GetLocalizeStringBy("key_1465"), fontsize=30, strokeSize = 1, strokeColor = ccc3(0x00, 0, 0x00)}

    -- 确定按钮
   	itemTable.sureButton  = LuaCCMenuItem.createMenuItemOfRenderLabelOnSprite(tSprite, tLabel)
    itemTable.sureButton:setPosition(ccp(itemTable.background:getContentSize().width * 0.5, 20))
    itemTable.sureButton:setAnchorPoint(ccp(0.5,0))
    itemTable.sureButton:registerScriptTapHandler(function ( ... )
    	AudioUtil.playEffect("audio/effect/guanbi.mp3")
		itemTable:removeFromParentAndCleanup(true)
		-- itemTable = nil
		if(itemTable.closeEvent ~= nil) then
			itemTable.closeEvent()
		end
		-- didClickEnter()
	end)
    menu:addChild(itemTable.sureButton )

    enterButton = itemTable.sureButton

    if(tonumber(exp) > 0) then
    	local alertContent = {}
		alertContent[1] = CCSprite:create("images/common/exp.png")
		--  CCLabelTTF:create( " " .. exp,24,1)
		alertContent[2] = CCRenderLabel:create("+ " .. exp, g_sFontName,25,1,ccc3(0x00,0x00,0x0),type_stroke)
		alertContent[2]:setColor(ccc3(0x36,0xff,0x00))
		alertContent[2]:setAnchorPoint(ccp(0,0))
		local expNode = BaseUI.createHorizontalNode(alertContent)
		expNode:setAnchorPoint(ccp(0.5,0))
		expNode:setPosition(ccp(itemTable.background:getContentSize().width/2,itemTable.background:getContentSize().height  - 100))
		itemTable.background:addChild(expNode)	
    end

  --   if(didLoadEvent) then
  --   	local seq = CCSequence:createWithTwoActions(CCDelayTime:create(0.3),CCCallFunc:create(function ( ... )
		-- 	didLoadEvent()
		-- end))
		-- itemTable:runAction(seq)
  --   end

	return itemTable
end

-- 创建 expNode节点
function createExpNode( exp)
	local alertContent = {}
	alertContent[1] = CCSprite:create("images/common/exp.png")
	alertContent[2] = CCRenderLabel:create("" .. exp, g_sFontName,24,1,ccc3(0x00,0x00,0x0),type_stroke)
	alertContent[2]:setColor(ccc3(0x78,0x25,0x00))
	alertContent[1]:setAnchorPoint(ccp(0,0))
	local expNode = BaseUI.createHorizontalNode(alertContent)
	expNode:setAnchorPoint(ccp(0.5,1))
	expNode:setPosition(ccp(self.background:getContentSize().width/2,self.background:getContentSize().height  -25))
	itemTable:addChild(expNode)	
	-- return expNode
end

function createAction( background )

	background:setVisible(true)
	local args = CCArray:create()
	local scale1 = CCScaleTo:create(0.08,1.2*g_fElementScaleRatio)
	local scale2 = CCScaleTo:create(0.06,0.9*g_fElementScaleRatio)
    local scale3 = CCScaleTo:create(0.07,1*g_fElementScaleRatio)
    args:addObject(scale1)
    args:addObject(scale2)
    args:addObject(scale3)

    background:runAction(CCSequence:create(args))

end

function ItemTableView:setTitle( titleStr )
	self.titlePanel:setVisible(true)
	self.titleLabel:setString(titleStr)
	local x = (self.titlePanel:getContentSize().width - self.titleLabel:getContentSize().width)/2
	local y = self.titlePanel:getContentSize().height - (self.titlePanel:getContentSize().height - self.titleLabel:getContentSize().height)/2
	self.titleLabel:setPosition(ccp(x , y))

end

-- 让标题可见
function ItemTableView:setTitleVisible(  )
	self.titlePanel:setVisible(true)
end

function ItemTableView:setNdeTouchProperty(TouchPriority  )
	local menu = tolua.cast(self.background:getChildByTag(101), "CCMenu")
	menu:setTouchPriority(TouchPriority)
	self.contentTable:setTouchPriority(TouchPriority) 
	print("self.sureButton:setTouchPriority(TouchPriority)", TouchPriority)
	
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
		contentNodeOffset = 50
	else
		backgourndOffset = 45
		tableViewOffset  =  30
		contentNodeOffset = 25
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
	self.tableBackground:setPosition(self.tableBackground:getPositionX(),80) --self.tableBackground:getPositionY() - self.contentLabelNode:getContentSize().height + tableViewOffset)
	--更新标题位置
	--self.titlePanel:setPosition(self.background:getContentSize().width/2, self.background:getContentSize().height - 7 )
	--更新关闭按钮位置
	self.closeButton:setPosition(ccp(self.background:getContentSize().width * 0.96, self.background:getContentSize().height * 0.96))
	--设置
	self.contentLabelNode:setAnchorPoint(ccp(0.5, 1))
	self.contentLabelNode:setPosition(ccp(self.background:getContentSize().width/2, self.background:getContentSize().height - contentNodeOffset))
	self.background:addChild(self.contentLabelNode)
end

function ItemTableView:registerClosedEvent( callbackFunc )
	self.closeEvent = callbackFunc
end


--[[
	@des:	得到确定按钮
]]
function getEnterButton( ... )
	return enterButton
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
end


