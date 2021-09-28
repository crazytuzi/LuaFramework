-- FileName: ChooseViewLayer.lua 
-- Author: licong 
-- Date: 14-6-14 
-- Purpose: 锻造装备选择界面


module("ChooseViewLayer", package.seeall)
require "script/ui/forge/ForgeData"

local _bgLayer 					= nil
local _btnFrameSp 				= nil
local _equipMenuItem 			= nil -- 装备按钮
local _curMenuItem 				= nil -- 当前按钮
local _listTableView 			= nil
local _bottomBg					= nil
local _chooseNumFont 			= nil
local _needItemId 				= nil
local _curData 					= nil
local _chooseList 				= nil
local _needItemQuality 			= nil

local function init( ... )
	_bgLayer 					= nil
	_btnFrameSp 				= nil
	_equipMenuItem 				= nil
	_listTableView 				= nil
	_bottomBg					= nil
	_chooseNumFont 				= nil
	_chooseList 				= nil

	_needItemId 				= nil
	_curData 					= nil
	_needItemQuality 			= nil
end

--[[
 @desc	 处理touches事件
 @para 	 string event
 @return 
--]]
local function onTouchesHandler( eventType, x, y )
	return true
end

--[[
 @desc	 回调onEnter和onExit时间
 @para 	 string event
 @return void
 --]]
local function onNodeEvent( event )
	if (event == "enter") then
		print("enter")
		_bgLayer:registerScriptTouchHandler(onTouchesHandler, false, -600, true)
		_bgLayer:setTouchEnabled(true)
	elseif (event == "exit") then
		print("exit")
		_bgLayer:unregisterScriptTouchHandler()
		_bgLayer = nil
	end
end

-- 关闭
local function closeAction()
	-- 音效
	require "script/audio/AudioUtil"
	AudioUtil.playEffect("audio/effect/guanbi.mp3")
	if(_bgLayer)then
		_bgLayer:removeFromParentAndCleanup(true)
		_bgLayer = nil
	end
	NewForgeViewLayer.showDownMenu()
	print("xxx ")
	print_t(ForgeData.getChooseListData())
end 

-- 选择确定按钮回调
local function confirmMenuAction( tag, itemBtn )
	print("confirmMenuAction .. ")
	-- 设置确认选择的装备
	ForgeData.setChooseListData(_chooseList)
	print("_chooseList")
	print_t(_chooseList)
	print("xxxxxxx ")
	print_t(ForgeData.getChooseListData())

	-- 关闭自己
	closeAction()
	-- 回调方法
	NewForgeViewLayer.choosedEquipCallFun()
end

-- 标签按钮回调
local function itemMenuAction( tag, menuItem )
	-- print("tag---->",tag)
	require "script/audio/AudioUtil"
	AudioUtil.playEffect("audio/effect/changtiaoxing.mp3")

	menuItem:selected()
	if( _curMenuItem ~= menuItem) then
		_curMenuItem:unselected()
		_curMenuItem = menuItem
		-- 数据准备
		bagInfo = DataCache.getBagInfo()
		if(_curMenuItem == _equipMenuItem) then
			_curData = {}
			for k,v in pairs(bagInfo.arm) do
				if(tonumber(v.itemDesc.id) == _needItemId)then
					table.insert(_curData, v)
				end
			end
		end
		if(_listTableView)then
			_listTableView:removeFromParentAndCleanup(true)
			_listTableView = nil
		end
		createItemTableView()
	end	
end

-- 更新选择状态
function checkedChooseCell( gid )
	print("_chooseList 1" ,gid)
	print_t(_chooseList)
	if ( table.isEmpty(_chooseList) ) then
		_chooseList = {}
		table.insert(_chooseList, gid)
		print("_chooseList 2",gid)
		print_t(_chooseList)
	else
		local isIn = false
		local index = -1
		for k,g_id in pairs(_chooseList) do
			if ( tonumber(g_id) == tonumber(gid) ) then
				isIn = true
				index = k
				break
			end
		end
		if (isIn) then
			table.remove(_chooseList, index)
			print("_chooseList 3",gid)
			print_t(_chooseList)
		else
			_chooseList = {}
			table.insert(_chooseList, gid)
			print("_chooseList 4",gid)
			print_t(_chooseList)
		end
	end

	-- 刷新状态
	local offset = _listTableView:getContentOffset()
	_listTableView:reloadData()
	_listTableView:setContentOffset(offset)

	-- 刷新 选择数量
	_chooseNumFont:setString(table.count(_chooseList))
end

-- 得到选择列表
function getChooseList( ... )
	return _chooseList
end

-- 创建物品tableView
local function createItemTableView( ... )
	-- 得到已选择的装备列表
	_chooseList = table.hcopy(ForgeData.getChooseListData(), {})
	print("_chooseList get")
	print_t(_chooseList)
	local cellBg = CCSprite:create("images/bag/item/item_cellbg.png")
	local cellSize = cellBg:getContentSize()			--计算cell大小 
	require "script/ui/forge/ChooseViewCell"
	local h = LuaEventHandler:create(function(fn, table, a1, a2) 	--创建
		local r
		if fn == "cellSize" then
			r = CCSizeMake(cellSize.width*g_fScaleX, cellSize.height*g_fScaleX)
		elseif fn == "cellAtIndex" then
            if (_curMenuItem == _equipMenuItem) then
            	a2 = ChooseViewCell.createEquipCell(_curData[a1 + 1])
        	end
            a2:setScale(g_fScaleX)
			r = a2
		elseif fn == "numberOfCells" then
			r = #_curData
		elseif fn == "cellTouched" then
			print("cellTouched == ")
			local m_data = _curData[a1:getIdx()+1]
			checkedChooseCell(tonumber(m_data.gid))
		else
		end
		return r
	end)
	local listHight = _btnFrameSp:getPositionY()-_btnFrameSp:getContentSize().height*g_fScaleX-_bottomBg:getContentSize().height*g_fScaleX
	_listTableView = LuaTableView:createWithHandler(h, CCSizeMake(640*g_fScaleX,listHight))
    _listTableView:setAnchorPoint(ccp(0,0))
	_listTableView:setBounceable(true)
	_listTableView:setPosition(ccp(0, _bottomBg:getContentSize().height*g_fScaleX))
	_listTableView:setTouchPriority(-602)
	_bgLayer:addChild(_listTableView)
end

-- 底部选择确认ui
local function createBottomPanel()
	-- 背景
	_bottomBg = CCSprite:create("images/common/sell_bottom.png")
	_bottomBg:setAnchorPoint(ccp(0,0))
	_bottomBg:setPosition(ccp(0,0))
	_bgLayer:addChild(_bottomBg)
	_bottomBg:setScale(g_fScaleX)

	-- 提示
	local tipSp = CCSprite:create("images/forge/tip.png")
	tipSp:setAnchorPoint(ccp(0.5,0))
	tipSp:setPosition(ccp(_bottomBg:getContentSize().width*0.5,50))
	_bottomBg:addChild(tipSp)

	-- 已选择装备
	local ccLabelSelected = CCLabelTTF:create (GetLocalizeStringBy("key_1351"), g_sFontName, 25)
	ccLabelSelected:setAnchorPoint(ccp(1,0.5))
	ccLabelSelected:setPosition(ccp(_bottomBg:getContentSize().width/2, 26))
	_bottomBg:addChild(ccLabelSelected)

	-- 出售英雄个数背景(9宫格)
	local fullRect = CCRectMake(0, 0, 34, 32)
	local insetRect = CCRectMake(12, 12, 10, 6)
	local numberBg = CCScale9Sprite:create("images/common/checkbg.png", fullRect, insetRect)
	numberBg:setPreferredSize(CCSizeMake(100, 36))
	numberBg:setAnchorPoint(ccp(0,0.5))
	numberBg:setPosition(ccp(ccLabelSelected:getPositionX()+5, ccLabelSelected:getPositionY()))
	_bottomBg:addChild(numberBg)
	-- 选择上限
	local limitCountFont = CCLabelTTF:create ("/1", g_sFontName, 25)
	limitCountFont:setColor(ccc3(0xff,0xff,0xff))
	limitCountFont:setAnchorPoint(ccp(0,0.5))
	limitCountFont:setPosition(ccp(numberBg:getContentSize().width*0.5, numberBg:getContentSize().height*0.5-2))
	numberBg:addChild(limitCountFont)
	-- 已选择英雄个数
	local chooseList = ForgeData.getChooseListData()
	_chooseNumFont = CCLabelTTF:create(table.count(chooseList), g_sFontName, 25)
	_chooseNumFont:setColor(ccc3(0x00,0xff,0x18))
	_chooseNumFont:setAnchorPoint(ccp(1,0.5))
	_chooseNumFont:setPosition(limitCountFont:getPositionX(), limitCountFont:getPositionY())
	numberBg:addChild(_chooseNumFont)

	-- 确定按钮
	local menu = CCMenu:create()
	menu:setTouchPriority(-610)
	menu:setPosition(ccp(0, 0))
	_bottomBg:addChild(menu)

	require "script/libs/LuaCC"
	local confirmBtn = LuaCC.create9ScaleMenuItem("images/star/intimate/btn_blue_n.png", "images/star/intimate/btn_blue_h.png",CCSizeMake(140, 70), GetLocalizeStringBy("key_1465"),ccc3(0xfe, 0xdb, 0x1c),30,g_sFontPangWa,1, ccc3(0x00, 0x00, 0x00))
	confirmBtn:setAnchorPoint(ccp(1, 0))
    confirmBtn:registerScriptTapHandler(confirmMenuAction)
    confirmBtn:setPosition(ccp(_bottomBg:getContentSize().width-15,10))
    menu:addChild(confirmBtn)
end

-- 创建按钮
local function addMenus()
    -- 公告栏高度
	require "script/ui/main/BulletinLayer"
    local bulletinLayerSize = BulletinLayer.getLayerContentSize()

	--按钮背景
	local fullRect = CCRectMake(0,0,58,99)
	local insetRect = CCRectMake(20,20,18,59)
	_btnFrameSp = CCScale9Sprite:create("images/common/menubg.png", fullRect, insetRect)
	_btnFrameSp:setPreferredSize(CCSizeMake(640, 100))
	_btnFrameSp:setAnchorPoint(ccp(0.5, 1))
	local posY = _bgLayer:getContentSize().height - bulletinLayerSize.height*g_fScaleX
	_btnFrameSp:setPosition(ccp(_bgLayer:getContentSize().width/2 , posY))
	_bgLayer:addChild(_btnFrameSp)
	_btnFrameSp:setScale(g_fScaleX)

	local menuBar = CCMenu:create()
	menuBar:setAnchorPoint(ccp(0,0))
	menuBar:setPosition(ccp(0,0))
	_btnFrameSp:addChild(menuBar)
	menuBar:setTouchPriority(-610)

	-- 标签按钮
	require "script/ui/common/LuaMenuItem"
	local title_item = {GetLocalizeStringBy("key_1791")}
	for i=1,1 do
		local itemImage =  LuaMenuItem.createMenuItemSprite( title_item[i])
		itemImage:setAnchorPoint(ccp(0,0))
        itemImage:setPosition(ccp(_btnFrameSp:getContentSize().width*(i-1) * 0.24, 10))
        itemImage:registerScriptTapHandler(itemMenuAction)
		menuBar:addChild(itemImage)
		if (i == 1) then
			_equipMenuItem = itemImage
		end 
	end
	
	--  返回按钮
	local closeMenuItem = CCMenuItemImage:create("images/common/close_btn_n.png","images/common/close_btn_h.png")
	closeMenuItem:setAnchorPoint(ccp(0, 0))
	closeMenuItem:registerScriptTapHandler(closeAction)
	closeMenuItem:setAnchorPoint(ccp(1,0.5))
	closeMenuItem:setPosition(ccp(_btnFrameSp:getContentSize().width-20,_btnFrameSp:getContentSize().height*0.5+6))
	menuBar:addChild(closeMenuItem)
end


local function initChooseViewLayer( ... )
	-- 背景
	local bigSp = CCSprite:create("images/main/module_bg.png")
	bigSp:setAnchorPoint(ccp(0.5,0.5))
	bigSp:setPosition(ccp(_bgLayer:getContentSize().width*0.5,_bgLayer:getContentSize().height*0.5))
	_bgLayer:addChild(bigSp)
	bigSp:setScale(g_fScaleX)

	-- 标签按钮
	addMenus()

	-- 底部确认按钮        
	createBottomPanel()

	-- 默认装备标签
	_curMenuItem = _equipMenuItem
	_curMenuItem:selected()

	-- 创建tableView
	local bagInfo = DataCache.getBagInfo()
	_curData = {}
	for k,v in pairs(bagInfo.arm) do
		if(tonumber(v.item_template_id) == _needItemId  and _needItemQuality == nil and v.va_item_text.armDevelop == nil)then
			table.insert(_curData, v)
		elseif(tonumber(v.item_template_id) == _needItemId  and _needItemQuality == 7 and v.va_item_text.armDevelop )then
			table.insert(_curData, v)
		else
		end
	end
	print("_curData ==")
	print_t(_curData)
	-- 排序
	if(not table.isEmpty(_curData) )then
		table.sort( _curData, ForgeData.equipSort)
	end
	createItemTableView()
end

--- 
-- @des    :创建装备选择界面
-- @param  :p_needItemId  需要选择的配方id, p_quality 需要装备品质
-- @return :返回装备选择界面
function showChooseViewLayer( p_needItemId, p_quality )
	init()
	_bgLayer = CCLayer:create()
	-- _bgLayer = CCLayerColor:create(ccc4(0,255,0,111))
	_bgLayer:registerScriptHandler(onNodeEvent)
	local runningScene = CCDirector:sharedDirector():getRunningScene()
	runningScene:addChild(_bgLayer, 800)
	-- 方法id
	_needItemId = p_needItemId
	_needItemQuality = p_quality
	-- 隐藏下排按钮
	MainScene.setMainSceneViewsVisible(false, false, true)
	-- 初始化界面
	initChooseViewLayer()
	return _bgLayer
end




















































