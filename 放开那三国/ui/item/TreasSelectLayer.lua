-- Filename：	TreasSelectLayer.lua
-- Author：		Cheng Liang
-- Date：		2013-11-7
-- Purpose：		选择宝物合成材料

module("TreasSelectLayer", package.seeall)


require "script/ui/bag/TreasBagCell"
require "script/ui/bag/ItemCell"

local _bgLayer 			= nil
local bottomSprite 		= nil
local topTitleSprite 	= nil
local _ex_itemId 			= nil
local curData 			= {}
local _itemNumLabel  	= nil
local _upgradePercentLabel	= nil
local _treasData 		= {}
local _layerTouchPrority = nil


function init()
	_bgLayer 		= nil
	bottomSprite 	= nil
	topTitleSprite 	= nil
	_ex_itemId 		= nil
	curData 		= {}
	_itemNumLabel  	= nil
	_upgradePercentLabel	= nil
	_treasData 		= {}
	_layerTouchPrority = nil

end

-- 返回按钮回调处理
local function closeAction(tag, item_obj)
	-- 音效
	require "script/audio/AudioUtil"
	AudioUtil.playEffect("audio/effect/guanbi.mp3")

	_bgLayer:removeFromParentAndCleanup(true)
	_bgLayer = nil
end


--
local function onTouchesHandler( eventType, x, y )
	
	local touchBeganPoint = ccp(x, y)
	if (eventType == "began") then
        return true
    elseif (eventType == "moved") then
    	
    else
	end
end

 --
local function onNodeEvent( event )
	if (event == "enter") then
		print("enter")
		_bgLayer:registerScriptTouchHandler(onTouchesHandler, false, _layerTouchPrority, true)
		_bgLayer:setTouchEnabled(true)
	elseif (event == "exit") then
		print("exit")
		_bgLayer:unregisterScriptTouchHandler()
	end
end


-- 创建标题面板
local function createTitleLayer( ... )
	--require "script/libs/LuaCCSprite"
	-- 标题背景底图
	topTitleSprite = CCSprite:create("images/hero/select/title_bg.png")
	topTitleSprite:setScale(g_fScaleX)
	-- 加入背景标题底图进层
	-- 标题
	local ccSpriteTitle = CCSprite:create("images/treasure/treas_select.png")
	ccSpriteTitle:setPosition(ccp(45, 50))
	topTitleSprite:addChild(ccSpriteTitle)

	local tItems = {
		{normal="images/hero/btn_back_n.png", highlighted="images/hero/btn_back_h.png", pos_x=473, pos_y=40, cb=closeAction},
	}
	local menu = LuaCC.createMenuWithItems(tItems)
	menu:setPosition(ccp(0, 0))
	menu:setTouchPriority(_layerTouchPrority-2)
	topTitleSprite:addChild(menu)

	topTitleSprite:setPosition(0, _bgLayer:getContentSize().height)
	topTitleSprite:setAnchorPoint(ccp(0, 1))
	_bgLayer:addChild(topTitleSprite)

end

-- 创建底部面板
local function createBottomSprite()
	bottomSprite = CCSprite:create("images/common/sell_bottom.png")
	bottomSprite:setScale(g_fScaleX)
	bottomSprite:setPosition(ccp(0, 0))
	bottomSprite:setAnchorPoint(ccp(0,0))
	_bgLayer:addChild(bottomSprite, 10)

	-- 已选择装备
	local equipLabel = CCLabelTTF:create(GetLocalizeStringBy("key_1979"), g_sFontName, 25)
	equipLabel:setColor(ccc3(0xff, 0xff, 0xff))
	equipLabel:setAnchorPoint(ccp(0.5, 0.5))
	equipLabel:setPosition(ccp(bottomSprite:getContentSize().width*0.13, bottomSprite:getContentSize().height*0.4))
	bottomSprite:addChild(equipLabel)

	-- 升级概率
	local sellTitleLabel = CCLabelTTF:create(GetLocalizeStringBy("key_3142"), g_sFontName, 25)
	sellTitleLabel:setColor(ccc3(0xff, 0xff, 0xff))
	sellTitleLabel:setAnchorPoint(ccp(0.5, 0.5))
	sellTitleLabel:setPosition(ccp(bottomSprite:getContentSize().width*0.47, bottomSprite:getContentSize().height*0.4))
	bottomSprite:addChild(sellTitleLabel) 

	-- 物品数量背景
	local fullRect = CCRectMake(0,0,34,32)
	local insetRect = CCRectMake(10,10,14,12)
	local itemNumSprite = CCScale9Sprite:create("images/common/checkbg.png", fullRect, insetRect)
	itemNumSprite:setPreferredSize(CCSizeMake(65, 38))
	itemNumSprite:setAnchorPoint(ccp(0.5,0.5))
	itemNumSprite:setPosition(ccp(bottomSprite:getContentSize().width* 180/640, bottomSprite:getContentSize().height*0.4))
	bottomSprite:addChild(itemNumSprite)

	-- 物品数量
	_itemNumLabel = CCLabelTTF:create(0, g_sFontName, 25)
	_itemNumLabel:setColor(ccc3(0xff, 0xff, 0xff))
	_itemNumLabel:setAnchorPoint(ccp(0.5, 0.5))
	_itemNumLabel:setPosition(ccp(itemNumSprite:getContentSize().width*0.5, itemNumSprite:getContentSize().height*0.4))
	itemNumSprite:addChild(_itemNumLabel)

	-- 总计出售背景
	local totalSellSprite = CCScale9Sprite:create("images/common/checkbg.png", fullRect, insetRect)
	totalSellSprite:setPreferredSize(CCSizeMake(100, 38))
	totalSellSprite:setAnchorPoint(ccp(0.5,0.5))
	totalSellSprite:setPosition(ccp(bottomSprite:getContentSize().width* 400/640, bottomSprite:getContentSize().height*0.4))
	bottomSprite:addChild(totalSellSprite)
	

	-- 升级概率
	_upgradePercentLabel = CCLabelTTF:create(0, g_sFontName, 25)
	_upgradePercentLabel:setColor(ccc3(0xff, 0xff, 0xff))
	_upgradePercentLabel:setAnchorPoint(ccp(0.5, 0.5))
	_upgradePercentLabel:setPosition(ccp(totalSellSprite:getContentSize().width*0.5, totalSellSprite:getContentSize().height*0.4))
	totalSellSprite:addChild(_upgradePercentLabel)

	-- 出售按钮
	local sellMenuBar = CCMenu:create()
	sellMenuBar:setPosition(ccp(0,0))
	bottomSprite:addChild(sellMenuBar)
	sellMenuBar:setTouchPriority(_layerTouchPrority-3)
	local sellBtn =  LuaMenuItem.createItemImage("images/tip/btn_confirm_n.png", "images/tip/btn_confirm_h.png" )
	sellBtn:setAnchorPoint(ccp(0.5, 0.5))
    sellBtn:setPosition(ccp(bottomSprite:getContentSize().width*560/640, bottomSprite:getContentSize().height*0.4))
    sellBtn:registerScriptTapHandler(closeAction)

	sellMenuBar:addChild(sellBtn)
end

-- 刷新底部
function refreshBottomSprite()
	local sellList = TreasReinforceLayer.getMaterialsArr()
	local chooseNum = 0
	for k,v in pairs(sellList) do
		chooseNum = chooseNum + v.num
	end
	_itemNumLabel:setString(chooseNum)

	_upgradePercentLabel:setString(BagUtil.getTreasAddExpBy(sellList))
end


-- 添加出售列表
function checkedSelectCell( p_itemId, p_num )

	local sellList = TreasReinforceLayer.getMaterialsArr()
	
	local isIn = false
	local pos = 0
	for k,v in pairs(sellList) do
		if(tonumber(v.item_id) == tonumber(p_itemId))then
			isIn = true
			pos = k
			break
		end
	end

	local chooseNum = table.count(sellList)
	if( chooseNum >= 5 and isIn == false)then  
		-- 五个了 不能再选择了
		AnimationTip.showTip(GetLocalizeStringBy("key_1861"))
		return true
	end


	local itemInfo = ItemUtil.getItemByItemId(p_itemId)
	if(isIn)then
		if( tonumber(itemInfo.itemDesc.maxStacking) > 1 )then
			if(p_num >= 1)then
				sellList[pos].num = p_num
			else
				table.remove(sellList,pos)
			end
		else
			table.remove(sellList,pos)
		end
	else
		if( tonumber(itemInfo.itemDesc.maxStacking) > 1 )then
			if(p_num >= 1)then
				local tab = {}
				tab.num = p_num
				tab.item_id = p_itemId
				table.insert(sellList,tab)
			end
		else
			local tab = {}
			tab.num = p_num
			tab.item_id = p_itemId
			table.insert(sellList,tab)
		end
	end
	TreasReinforceLayer.setMaterialsArr(sellList)
	return isIn
end

--
local function createSelectTableView( ... )
	print("curData:")
	print_t(curData)

	local cellSize = CCSizeMake(635,240)
	cellSize.width = cellSize.width * g_fScaleX 
	cellSize.height = cellSize.height * g_fScaleX

    local nHeightOfBottom = (bottomSprite:getContentSize().height-12)*g_fScaleX
	local nHeightOfTitle = (topTitleSprite:getContentSize().height-16)*g_fScaleX
	local _scrollview_height = g_winSize.height - nHeightOfBottom - nHeightOfTitle

	local visiableCellNum = math.floor(_scrollview_height/(cellSize.height*g_fScaleX)) --计算可视的有几个cell
	
	local h = LuaEventHandler:create(function(fn, t, a1, a2) 	--创建
		local r
		if fn == "cellSize" then
			r = CCSizeMake(cellSize.width, cellSize.height)
		elseif fn == "cellAtIndex" then
			-- if not a2 then
			local sellList = TreasReinforceLayer.getMaterialsArr()
            a2 = TreasBagCell.createTreasCell(curData[a1 + 1], false, refreshMyTableView, true, _layerTouchPrority-2,sellList)
            a2:setScale(g_fScaleX)
			r = a2
		elseif fn == "numberOfCells" then
			r = #curData
		elseif fn == "cellTouched" then
			
			local m_data = curData[a1:getIdx()+1]

			local cellBg = tolua.cast(a1:getChildByTag(1), "CCSprite")
			local menubar_m = tolua.cast(cellBg:getChildByTag(9898), "CCMenu")
			local menuBtn_M = tolua.cast(menubar_m:getChildByTag(tonumber(m_data.item_id)), "CCMenuItemSprite")
			if( m_data.va_item_text and not table.isEmpty(m_data.va_item_text.treasureInlay) )then
				-- 有符印不能选择
				AnimationTip.showTip(GetLocalizeStringBy("lic_1588"))
			elseif( tonumber(m_data.itemDesc.maxStacking) > 1 )then
			else
				local isIn = checkedSelectCell(tonumber(m_data.item_id),1)
				if(isIn == true) then
					menuBtn_M:unselected()
				else
					menuBtn_M:selected()
				end
			end
			refreshBottomSprite()
		elseif (fn == "scroll") then
			
		end
		return r
	end)
	myTableView = LuaTableView:createWithHandler(h, CCSizeMake(_bgLayer:getContentSize().width, _scrollview_height))
    myTableView:setAnchorPoint(ccp(0,0))
	myTableView:setBounceable(true)
	myTableView:setTouchPriority(_layerTouchPrority-3)
	myTableView:setPosition(ccp(0,nHeightOfBottom))
	-- myTableView:setVerticalFillOrder(kCCTableViewFillTopDown)
	_bgLayer:addChild(myTableView, 9)

	-- 刷新底部
	refreshBottomSprite()
end

-- 处理数据
function handlePrepareData()
	local curDataBag = BagUtil.getTreasInfosExceptGid(_ex_itemId, _treasData.itemDesc.type)
	print("curDataBag==>")
	print_t(curDataBag)
	-- 排序 选择的宝物显示到列表最上边
	local selectArr = TreasReinforceLayer.getMaterialsArr()
	-- print("selectArr")
	-- print_t(selectArr)
	local tab1 = {}
	local tab2 = {}
	local tab3 = {}
	for k,v in pairs(curDataBag) do
		if(tonumber(v.itemDesc.maxStacking) > 1 )then
			table.insert(tab3,v)
		else
			local isIn = false
			for k,select_v in pairs(selectArr) do
				if( tonumber(select_v.item_id) == tonumber(v.item_id) )then
					v.isIn = true
					isIn = true
					table.insert(tab1,v)
					break
				end
			end
			if(isIn == false)then
				table.insert(tab2,v)
			end
		end
	end
	for k,v in pairs(tab2) do
		table.insert(curData,v)
	end
	for k,v in pairs(tab1) do
		table.insert(curData,v)
	end
	for k,v in pairs(tab3) do
		table.insert(curData,v)
	end
end

--
function createLayer(excepte_itemId, treasData, p_layer_priority )
	init()
	_ex_itemId = excepte_itemId
	_treasData = treasData
	_layerTouchPrority = p_layer_priority or -455
	-- 创建背景
	_bgLayer = CCLayer:create()
	local bgSprite = CCSprite:create("images/main/module_bg.png")
	bgSprite:setScale(g_fBgScaleRatio)
	_bgLayer:addChild(bgSprite)
	_bgLayer:setContentSize(CCSizeMake(g_winSize.width, g_winSize.height))
	_bgLayer:registerScriptHandler(onNodeEvent)

	-- 准备数据
	handlePrepareData()
	-- 创建上部
	createTitleLayer()
	-- 创建底部
	createBottomSprite()
	-- 创建选择的tableview
	createSelectTableView()



	return _bgLayer

end
