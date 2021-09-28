-- FileName: MyFriendLayer.lua 
-- Author: Li Cong 
-- Date: 13-8-27 
-- Purpose: function description of module 


module("MyFriendLayer", package.seeall)

local mainLayer = nil        
local m_layerSize = nil
local content_bg = nil
friendTableView = nil
curFriend_data = nil
set_width = nil
set_height = nil           						
-- 创建滑动列表
function createMyFriendTabView()
	-- 显示单元格背景的size
	local cell_bg_size = { width = 584, height = 110 } 
	-- 得到全部好友列表数据
	FriendData.showFriendData = FriendData.getShowMyFriendData( FriendData.friendPage )
	-- print(GetLocalizeStringBy("key_1424")) 
	-- print_t(FriendData.showFriendData)
	require "script/ui/friend/MyFriendCell"
	local handler = LuaEventHandler:create(function(fn, table, a1, a2)
		local r
		if (fn == "cellSize") then
			-- 显示单元格的间距
			local interval = 10
			r = CCSizeMake(cell_bg_size.width*g_fScaleX, (cell_bg_size.height + interval)*g_fScaleX)
		elseif (fn == "cellAtIndex") then
			r = MyFriendCell.createCell(FriendData.showFriendData[a1+1])
			r:setScale(g_fScaleX)
		elseif (fn == "numberOfCells") then
			r = #FriendData.showFriendData
		elseif (fn == "cellTouched") then
			-- print ("a1: ", a1, ", a2: ", a2)
			-- print ("cellTouched, index is: ", a1:getIdx())
		elseif (fn == "scroll") then
			-- print ("scroll, index is: ")
		else
			-- print (fn, " event is not handled.")
		end
		return r
	end)

	friendTableView = LuaTableView:createWithHandler(handler, CCSizeMake((set_width),(set_height)))
	friendTableView:setBounceable(true)
	friendTableView:ignoreAnchorPointForPosition(false)
	friendTableView:setAnchorPoint(ccp(0.5, 1))
	friendTableView:setPosition(ccp(content_bg:getPositionX(),content_bg:getPositionY()-4*MainScene.elementScale))
	mainLayer:addChild(friendTableView)
	-- 设置单元格升序排列
	friendTableView:setVerticalFillOrder(kCCTableViewFillTopDown)
	-- 设置滑动列表的优先级
	friendTableView:setTouchPriority(-130)
end



-- 创建好友层
function initMyFriendLayer( ... )
	-- 内容背景
	content_bg = BaseUI.createContentBg(CCSizeMake((m_layerSize.width-50*MainScene.elementScale),(m_layerSize.height-345*MainScene.elementScale)))
	content_bg:setAnchorPoint(ccp(0.5,1))
	content_bg:setPosition(ccp(mainLayer:getContentSize().width*0.5,mainLayer:getContentSize().height-250*MainScene.elementScale))
	mainLayer:addChild(content_bg)
	set_width = m_layerSize.width-50*MainScene.elementScale
	set_height = m_layerSize.height-355*MainScene.elementScale
	-- 当前好友
	local curFriend_font = CCRenderLabel:create( GetLocalizeStringBy("key_1048") , g_sFontPangWa, 30*MainScene.elementScale, 1, ccc3( 0xff, 0xff, 0xff), type_stroke)
    curFriend_font:setColor(ccc3(0x78, 0x25, 0x00))
    curFriend_font:setPosition(ccp(206*MainScene.elementScale,73*MainScene.elementScale))
    mainLayer:addChild(curFriend_font)
    -- 当前好友数量
    curFriend_data = CCRenderLabel:create( table.count(FriendData.allfriendData) .. "/100" , g_sFontPangWa, 35*MainScene.elementScale, 1, ccc3( 0x00, 0x00, 0x00), type_stroke)
    curFriend_data:setColor(ccc3(0xff, 0xf6, 0x00))
    curFriend_data:setAnchorPoint(ccp(0,1))
    curFriend_data:setPosition(ccp(355*MainScene.elementScale,75*MainScene.elementScale))
    mainLayer:addChild(curFriend_data)

    -- 创建好友列表
    createMyFriendTabView()

end

-- 创建好友层
function createMyFriendLayer( ... )
	mainLayer = CCLayer:create()
	m_layerSize = mainLayer:getContentSize()
	-- mainLayer = CCLayerColor:create(ccc4(255,255,255,0))
	mainLayer:registerScriptHandler(function ( eventType,node )
   		if(eventType == "enter") then
   		end
		if(eventType == "exit") then
			mainLayer = nil
		end
	end)

	-- 创建下一步UI
	local function createNext( ... )
		-- 初始化
		initMyFriendLayer()
	end
	FriendService.getFriendInfoList(createNext)

	return mainLayer
end



-- 更新上线好友
function updateOnlineFriend( tableData )
	require "script/ui/friend/FriendData"
	FriendData.setFriendOnline(tableData)
	if(friendTableView ~= nil)then
		-- 排序在线在前
		FriendData.sortByOnline()
		friendTableView:reloadData()
	end
end

-- 更新下线好友
function updateOfflineFriend( tableData )
	require "script/ui/friend/FriendData"
	FriendData.setFriendOffline(tableData)
	if(friendTableView ~= nil)then
		-- 排序在线在前
		FriendData.sortByOnline()
		friendTableView:reloadData()
	end
end


-- 更新我的好友总数
function updateFriendsCountFont( ... )
	if(curFriend_data ~= nil)then
		curFriend_data:removeFromParentAndCleanup(true)
		curFriend_data = nil
	end
	curFriend_data = CCRenderLabel:create( table.count(FriendData.allfriendData) .. "/100" , g_sFontPangWa, 35*MainScene.elementScale, 1, ccc3( 0x00, 0x00, 0x00), type_stroke)
    curFriend_data:setColor(ccc3(0xff, 0xf6, 0x00))
    curFriend_data:setAnchorPoint(ccp(0,1))
    curFriend_data:setPosition(ccp(355*MainScene.elementScale,75*MainScene.elementScale))
    mainLayer:addChild(curFriend_data)
end


-- 更新好友列表
function updateMyFriendLayer( ... )
	if(mainLayer ~= nil)then
		mainLayer:removeAllChildrenWithCleanup(true)
		m_layerSize = mainLayer:getContentSize()
		-- 创建下一步UI
		local function createNext( ... )
			-- 初始化
			initMyFriendLayer()
		end
		FriendService.getFriendInfoList(createNext)
	end
end


