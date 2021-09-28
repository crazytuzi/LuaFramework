-- FileName: GetStaminaLayer.lua 
-- Author: Li Cong 
-- Date: 13-12-17 
-- Purpose: function description of module 


module("GetStaminaLayer", package.seeall)

local mainLayer = nil        
local m_layerSize = nil
local content_bg = nil
reciveTableView = nil
curNum_data = nil
set_width = nil
set_height = nil           						
-- 创建滑动列表
function createReciveTabView()
	-- 显示单元格背景的size
	local cell_bg_size = { width = 584, height = 110 } 
	-- 得到列表数据
	FriendData.receiveListInfo = FriendData.getReceiveList() or {}
	-- print(GetLocalizeStringBy("key_2241"))
	-- print_t(FriendData.receiveListInfo)
	require "script/ui/friend/GetStaminaCell"
	local handler = LuaEventHandler:create(function(fn, table, a1, a2)
		local r
		if (fn == "cellSize") then
			-- 显示单元格的间距
			local interval = 10
			r = CCSizeMake(cell_bg_size.width*g_fScaleX, (cell_bg_size.height + interval)*g_fScaleX)
		elseif (fn == "cellAtIndex") then
			r = GetStaminaCell.createCell(FriendData.receiveListInfo[a1+1])
			r:setScale(g_fScaleX)
		elseif (fn == "numberOfCells") then
			r = #FriendData.receiveListInfo
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

	reciveTableView = LuaTableView:createWithHandler(handler, CCSizeMake((set_width),(set_height)))
	reciveTableView:setBounceable(true)
	reciveTableView:ignoreAnchorPointForPosition(false)
	reciveTableView:setAnchorPoint(ccp(0.5, 1))
	reciveTableView:setPosition(ccp(content_bg:getPositionX(),content_bg:getPositionY()-4*MainScene.elementScale))
	mainLayer:addChild(reciveTableView)
	-- 设置单元格升序排列
	reciveTableView:setVerticalFillOrder(kCCTableViewFillTopDown)
	-- 设置滑动列表的优先级
	reciveTableView:setTouchPriority(-130)
end



-- 创建领取层
function initGetStaminaLayer( ... )
	-- 内容背景
	content_bg = BaseUI.createContentBg(CCSizeMake((m_layerSize.width-50*MainScene.elementScale),(m_layerSize.height-345*MainScene.elementScale)))
	content_bg:setAnchorPoint(ccp(0.5,1))
	content_bg:setPosition(ccp(mainLayer:getContentSize().width*0.5,mainLayer:getContentSize().height-250*MainScene.elementScale))
	mainLayer:addChild(content_bg)
	set_width = m_layerSize.width-50*MainScene.elementScale
	set_height = m_layerSize.height-355*MainScene.elementScale
	-- 今日剩余领取次数
	local curFriend_font = CCRenderLabel:create( GetLocalizeStringBy("key_2214") , g_sFontPangWa, 30*MainScene.elementScale, 1, ccc3( 0xff, 0xff, 0xff), type_stroke)
    curFriend_font:setColor(ccc3(0x1d, 0x71, 0x00))
    curFriend_font:setAnchorPoint(ccp(0,1))
    curFriend_font:setPosition(ccp(24*MainScene.elementScale,73*MainScene.elementScale))
    mainLayer:addChild(curFriend_font)
    -- 剩余领取次数数值
    local num = FriendData.getTodayReceiveTimes()
    curNum_data = CCRenderLabel:create( "" .. num , g_sFontPangWa, 25*MainScene.elementScale,1, ccc3( 0x00, 0x00, 0x00), type_stroke)
    curNum_data:setColor(ccc3(0xff, 0xf6, 0x00))
    curNum_data:setAnchorPoint(ccp(0,1))
    curNum_data:setPosition(ccp(285*MainScene.elementScale,70*MainScene.elementScale))
    mainLayer:addChild(curNum_data)

    -- 全部领取按钮
    local menu = CCMenu:create()
    menu:setPosition(ccp(0,0))
    menu:setTouchPriority(-150)
    mainLayer:addChild(menu)
     
local receiveAllItem
if(Platform.getLayout ~= nil and Platform.getLayout() == "enLayout" ) then
    receiveAllItem = LuaCC.create9ScaleMenuItem("images/common/btn/btn1_d.png","images/common/btn/btn1_n.png",CCSizeMake(300, 73),GetLocalizeStringBy("key_1194"),ccc3(0xfe, 0xdb, 0x1c),18,g_sFontPangWa,1, ccc3(0x00, 0x00, 0x00))
else
    receiveAllItem = LuaCC.create9ScaleMenuItem("images/common/btn/btn1_d.png","images/common/btn/btn1_n.png",CCSizeMake(300, 73),GetLocalizeStringBy("key_1194"),ccc3(0xfe, 0xdb, 0x1c),35,g_sFontPangWa,1, ccc3(0x00, 0x00, 0x00))
end
	receiveAllItem:setAnchorPoint(ccp(1, 1))
	receiveAllItem:setPosition(ccp(m_layerSize.width-20*MainScene.elementScale, 90*MainScene.elementScale))
	receiveAllItem:registerScriptTapHandler(receiveAllItemCallFun)
	receiveAllItem:setScale(g_fScaleX)
	menu:addChild(receiveAllItem)

    -- 创建好友列表
    createReciveTabView()

end

-- 更新剩余次数文字
function upDateCanReciveNumFont( ... )
	if( curNum_data ~= nil )then
		curNum_data:removeFromParentAndCleanup(true)
		curNum_data = nil
	end
	local num = FriendData.getTodayReceiveTimes()
	curNum_data = CCRenderLabel:create( "" .. num , g_sFontPangWa, 25*MainScene.elementScale,1, ccc3( 0x00, 0x00, 0x00), type_stroke)
    curNum_data:setColor(ccc3(0xff, 0xf6, 0x00))
    curNum_data:setAnchorPoint(ccp(0,1))
    curNum_data:setPosition(ccp(285*MainScene.elementScale,70*MainScene.elementScale))
    mainLayer:addChild(curNum_data)
end

-- 创建领取耐力层
function createGetStaminaLayer( ... )
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
		initGetStaminaLayer()
		-- -- 小红圈
		-- local num = FriendData.getReceiveListCount()
		-- local canReceiveNum = FriendData.getTodayReceiveTimes()
		-- print("canReceiveNum",canReceiveNum)
		-- if(canReceiveNum <= 0 or num <= 0 )then
		-- 	-- 好友图标红圈
		-- 	FriendData.setShowTipSprite(false)
		-- else
		-- 	-- 好友图标红圈
		-- 	FriendData.setShowTipSprite(true)
		-- end
		-- if(num <= 0)then
		-- 	FriendLayer.m_tipSprite:setVisible(false)
		-- else
		-- 	-- 刷新小红圈数字
		-- 	FriendLayer.m_tipSprite:setVisible(true)
		-- 	ItemDropUtil.refreshNum( FriendLayer.m_tipSprite, num )
		-- end
	end
	FriendService.getReceiveStaminaList(createNext)

	return mainLayer
end


-- 全部领取回调
function receiveAllItemCallFun(  tag, item_obj )
	-- 判断领取列表是否为空
	local listData = FriendData.getReceiveList()
	if( table.count(listData) == 0)then
		require "script/ui/tip/AnimationTip"
		local str = GetLocalizeStringBy("key_1729")
		AnimationTip.showTip(str)
		return
	end
	-- 判断是否还有剩余次数
	local times = FriendData.getTodayReceiveTimes()
	if( times <= 0)then
		require "script/ui/tip/AnimationTip"
		local str = GetLocalizeStringBy("key_3230")
		AnimationTip.showTip(str)
		return
	end
	-- 耐力已达上限
	if( UserModel.getStaminaNumber() >= UserModel.getMaxStaminaNumber() )then
		require "script/ui/tip/AnimationTip"
		local str = GetLocalizeStringBy("key_2642")
		AnimationTip.showTip(str)
		return
	end

	-- 弹出确认提示框
	require "script/ui/tip/AlertTip"
	local str = GetLocalizeStringBy("key_1439")
    AlertTip.showAlert( str, yesToreceive, true)
end


-- 确定全部领取
function yesToreceive( isConfirm )
	if(isConfirm == false)then
		return 
	end
	print(GetLocalizeStringBy("key_1498"))
	-- 创建下一步UI
	local function createNext( receiveStaminaNum )
		-- 弹出框
		sayYesCallFun( receiveStaminaNum )
		-- 更新可领取列表
		FriendData.receiveListInfo = FriendData.getReceiveList()
		GetStaminaLayer.reciveTableView:reloadData()
		-- 更新剩余次数
		upDateCanReciveNumFont()
		-- -- 刷新小红圈数字
		-- require "script/utils/ItemDropUtil"
		-- local times = FriendData.getTodayReceiveTimes()
		-- if(not table.isEmpty(FriendData.receiveListInfo) and times > 0)then
		-- 	ItemDropUtil.refreshNum( FriendLayer.m_tipSprite, table.count( FriendData.receiveListInfo ) )
		-- 	-- 设置小红圈数量
		-- 	FriendData.setReceiveListCount( table.count( FriendData.receiveListInfo ) )
		-- 	-- 好友图标红圈
		-- 	FriendData.setShowTipSprite(true)
		-- else
		-- 	ItemDropUtil.refreshNum( FriendLayer.m_tipSprite, table.count( FriendData.receiveListInfo ) )
		-- 	-- 设置小红圈数量
		-- 	FriendData.setReceiveListCount( table.count( FriendData.receiveListInfo ) )
		-- 	-- 好友图标红圈
		-- 	FriendData.setShowTipSprite(false)
		-- end
	end
	FriendService.receiveAllStamina(createNext)
end


-- touch事件处理
local function cardLayerTouch(eventType, x, y)
   
    return true
    
end

-- 确定领取后弹出提示
function sayYesCallFun( receiveStaminaNum )
	local tipLayer = CCLayerColor:create(ccc4(11,11,11,200))
	tipLayer:setTouchEnabled(true)
    tipLayer:registerScriptTouchHandler(cardLayerTouch,false,-420,true)
    
    local scene = CCDirector:sharedDirector():getRunningScene()
    scene:addChild(tipLayer,1999,78432)
    -- 创建背景
    local tip_bg = BaseUI.createViewBg(CCSizeMake(523,318))
    tip_bg:setPosition(ccp(g_winSize.width*0.5,g_winSize.height*0.5))
    tipLayer:addChild(tip_bg)
    -- 适配
	setAdaptNode(tip_bg)

	-- 关闭按钮回调
	local function closeButtonCallback( tag, item_obj )
		-- 音效
		require "script/audio/AudioUtil"
		AudioUtil.playEffect("audio/effect/guanbi.mp3")
		tipLayer:removeFromParentAndCleanup(true)
		tipLayer = nil
	end

    -- 关闭按钮
	local closeMenu = CCMenu:create()
	closeMenu:setTouchPriority(-420)
	closeMenu:setPosition(ccp(0, 0))
	closeMenu:setAnchorPoint(ccp(0, 0))
	tip_bg:addChild(closeMenu,3)
	local closeButton = CCMenuItemImage:create("images/common/btn_close_n.png", "images/common/btn_close_h.png")
	closeButton:setAnchorPoint(ccp(0.5, 0.5))
	closeButton:setPosition(ccp(tip_bg:getContentSize().width*0.95, tip_bg:getContentSize().height*0.92 ))
	closeButton:registerScriptTapHandler(closeButtonCallback)
	closeMenu:addChild(closeButton)

    -- 文字背景
    local font_bg = BaseUI.createContentBg(CCSizeMake(466,155))
    font_bg:setAnchorPoint(ccp(0.5,1))
    font_bg:setPosition(ccp(tip_bg:getContentSize().width*0.5,tip_bg:getContentSize().height-56))
    tip_bg:addChild(font_bg)
    -- 领取成功
    local sp_font = CCSprite:create("images/friend/sp_font.png")
    sp_font:setAnchorPoint(ccp(0.5,1))
    sp_font:setPosition(ccp(font_bg:getContentSize().width*0.5,font_bg:getContentSize().height-30))
    font_bg:addChild(sp_font)
    -- 第二行
    local font1 = CCRenderLabel:create( GetLocalizeStringBy("key_3302"), g_sFontName, 23, 1, ccc3( 0x00, 0x00, 0x00), type_stroke)
    font1:setColor(ccc3(0xff, 0xfb, 0xd9))
    font1:setAnchorPoint(ccp(1,0))
    font1:setPosition(ccp(213,31))
    font_bg:addChild(font1)
    local sp1 = CCSprite:create("images/friend/sp_icon.png")
    sp1:setAnchorPoint(ccp(0,0))
    sp1:setPosition(ccp(font1:getPositionX()+2,23))
    font_bg:addChild(sp1)
    -- 领取的耐力数量
    local num_font = CCRenderLabel:create( "x" .. receiveStaminaNum , g_sFontName, 23, 1, ccc3( 0x00, 0x00, 0x00), type_stroke)
    num_font:setColor(ccc3(0xff, 0xf6, 0x00))
    num_font:setAnchorPoint(ccp(0,0))
    num_font:setPosition(ccp(sp1:getPositionX()+sp1:getContentSize().width+4,31))
    font_bg:addChild(num_font)

    
    -- 今日剩余领取次数
    local times = FriendData.getTodayReceiveTimes()
	local curFriend_font = CCRenderLabel:create( GetLocalizeStringBy("key_1903") .. times , g_sFontPangWa, 25, 1, ccc3( 0xff, 0xff, 0xff), type_stroke)
    curFriend_font:setColor(ccc3(0x1d, 0x71, 0x00))
    curFriend_font:setAnchorPoint(ccp(0.5,0))
    curFriend_font:setPosition(ccp(tip_bg:getContentSize().width*0.5,54))
    tip_bg:addChild(curFriend_font)

end


-- 推送时调用
-- 当可领取数据超出60条时推送 重新拉取数据
function upDateReciveDataAndUi( ... )
	-- 创建下一步UI
	local function createNext( ... )
		-- 刷新UI
		if(mainLayer ~= nil)then
			if(GetStaminaLayer.reciveTableView ~= nil)then
				-- 更新可领取列表
				FriendData.receiveListInfo = FriendData.getReceiveList()
				GetStaminaLayer.reciveTableView:reloadData()
			end
			-- 更新剩余次数
			upDateCanReciveNumFont()
		end
	end
	FriendService.getReceiveStaminaList(createNext)
end





-- 更新好友列表
function updateGetStaminaLayer( ... )
	if(mainLayer ~= nil)then
		mainLayer:removeAllChildrenWithCleanup(true)
		m_layerSize = mainLayer:getContentSize()
		-- 创建下一步UI
		local function createNext( ... )
			-- 初始化
			initGetStaminaLayer()
		end
		FriendService.getReceiveStaminaList(createNext)
	end
end


















