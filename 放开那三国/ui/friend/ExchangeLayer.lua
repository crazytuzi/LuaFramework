-- FileName: ExchangeLayer.lua 
-- Author: Li Cong 
-- Date: 13-8-29 
-- Purpose: function description of module 


module("ExchangeLayer", package.seeall)

local mainLayer = nil
local leaveMessageLayer = nil


-- touch事件处理
local function cardLayerTouch(eventType, x, y)
   
    return true
    
end


-- 创建交流弹出界面
function showExchangeLayer( uid )
	-- 音效
    require "script/audio/AudioUtil"
    AudioUtil.playEffect("audio/effect/zhujiemian.mp3")
	mainLayer = CCLayerColor:create(ccc4(11,11,11,200))
	mainLayer:setTouchEnabled(true)
    mainLayer:registerScriptTouchHandler(cardLayerTouch,false,-410,true)
    
    local scene = CCDirector:sharedDirector():getRunningScene()
    scene:addChild(mainLayer,1999,784321)

    -- 背景
    local main_bg = BaseUI.createViewBg(CCSizeMake(524,626))
    main_bg:setPosition(ccp(g_winSize.width*0.5,g_winSize.height*0.5))
    mainLayer:addChild(main_bg)
    -- 适配
	setAdaptNode(main_bg)

    -- 关闭按钮
	local closeMenu = CCMenu:create()
	closeMenu:setTouchPriority(-410)
	closeMenu:setPosition(ccp(0, 0))
	closeMenu:setAnchorPoint(ccp(0, 0))
	main_bg:addChild(closeMenu,3)
	local closeButton = CCMenuItemImage:create("images/common/btn_close_n.png", "images/common/btn_close_h.png")
	closeButton:setAnchorPoint(ccp(0.5, 0.5))
	closeButton:setPosition(ccp(main_bg:getContentSize().width*0.95, main_bg:getContentSize().height*0.95 ))
	closeButton:registerScriptTapHandler(closeButtonCallback)
	closeMenu:addChild(closeButton)
	-- 标题文字
	local font = CCRenderLabel:create( GetLocalizeStringBy("key_2505") , g_sFontPangWa, 35, 1, ccc3( 0xff, 0xff, 0xff), type_stroke)
    font:setColor(ccc3(0x78, 0x25, 0x00))
    font:setPosition(ccp((main_bg:getContentSize().width-font:getContentSize().width)*0.5,main_bg:getContentSize().height-34))
    main_bg:addChild(font)
    -- 二级背景
    local second_bg = BaseUI.createContentBg(CCSizeMake(464,502))
    second_bg:setAnchorPoint(ccp(0.5,0))
    second_bg:setPosition(ccp(main_bg:getContentSize().width*0.5,40))
    main_bg:addChild(second_bg)

    -- 文字提示
    -- 玩家的姓名和性别
    local user_name,user_utid = FriendData.getMyfriendName(uid)
    -- 玩家姓名的颜色
    local name_color,stroke_color = MyFriendCell.getHeroNameColor( user_utid )
	-- 创建文本
	local text_font1 = CCLabelTTF:create(GetLocalizeStringBy("key_2201"),g_sFontName,23)
	text_font1:setColor(ccc3(0xff,0xfb,0xd9))
	text_font1:setAnchorPoint(ccp(0,1))
	second_bg:addChild(text_font1)
   	local text_name = CCRenderLabel:create( user_name, g_sFontName, 23, 1, stroke_color, type_stroke)
    text_name:setColor(name_color)
   	second_bg:addChild(text_name)
   	local text_font2 = CCLabelTTF:create(GetLocalizeStringBy("lic_1248"),g_sFontName,23)
	text_font2:setColor(ccc3(0xff,0xfb,0xd9))
	text_font2:setAnchorPoint(ccp(0,1))
	second_bg:addChild(text_font2)
	-- 居中计算
	local text_x = (second_bg:getContentSize().width - (text_font1:getContentSize().width+text_name:getContentSize().width+text_font2:getContentSize().width))/2
	local text_y = second_bg:getContentSize().height-40
	text_font1:setPosition(ccp(text_x,text_y))
	text_name:setPosition(ccp(text_font1:getPositionX()+text_font1:getContentSize().width+5,text_y))
	text_font2:setPosition(ccp(text_name:getPositionX()+text_name:getContentSize().width+5,text_y))

	-- 创建按钮
	local menu = BTSensitiveMenu:create()
	if(menu:retainCount()>1)then
		menu:release()
		menu:autorelease()
	end
	menu:setTouchPriority(-410)
	menu:setPosition(ccp(0,0))
	second_bg:addChild(menu)
	-- 留言
	local leaveMessageItem = createButtonItem(GetLocalizeStringBy("key_2488"))
	leaveMessageItem:setAnchorPoint(ccp(0.5,0))
	leaveMessageItem:setPosition(ccp(second_bg:getContentSize().width*0.5,360))
	leaveMessageItem:registerScriptTapHandler(leaveMessageItemFun)
	menu:addChild(leaveMessageItem,1,tonumber(uid))
	-- 查看信息
	local lookInfoItem = createButtonItem(GetLocalizeStringBy("key_3334"))
	lookInfoItem:setAnchorPoint(ccp(0.5,0))
	lookInfoItem:setPosition(ccp(second_bg:getContentSize().width*0.5,leaveMessageItem:getPositionY()-lookInfoItem:getContentSize().height-5))
	lookInfoItem:registerScriptTapHandler(lookInfoItemFun)
	menu:addChild(lookInfoItem,1,tonumber(uid))
	-- 挑战
	local pkItem = createButtonItem(GetLocalizeStringBy("key_1777"))
	pkItem:setAnchorPoint(ccp(0.5,0))
	pkItem:setPosition(ccp(second_bg:getContentSize().width*0.5,lookInfoItem:getPositionY()-pkItem:getContentSize().height-5))
	pkItem:registerScriptTapHandler(pkItemFun)
	menu:addChild(pkItem,1,tonumber(uid))
	-- 删除好友
	local deleteItem = createButtonItem(GetLocalizeStringBy("key_2706"))
	deleteItem:setAnchorPoint(ccp(0.5,0))
	deleteItem:setPosition(ccp(second_bg:getContentSize().width*0.5,pkItem:getPositionY()-deleteItem:getContentSize().height-5))
	deleteItem:registerScriptTapHandler(deleteItemFun)
	menu:addChild(deleteItem,1,tonumber(uid))
	-- 加黑
	local blackItem = createButtonItem(GetLocalizeStringBy("lic_1052"))
	blackItem:setAnchorPoint(ccp(0.5,0))
	blackItem:setPosition(ccp(second_bg:getContentSize().width*0.5,deleteItem:getPositionY()-blackItem:getContentSize().height-5))
	blackItem:registerScriptTapHandler(blackItemFun)
	menu:addChild(blackItem,1,tonumber(uid))
	-- 返回
	local backItem = createButtonItem(GetLocalizeStringBy("key_2661"))
	backItem:setAnchorPoint(ccp(0.5,0))
	backItem:setPosition(ccp(second_bg:getContentSize().width*0.5,blackItem:getPositionY()-backItem:getContentSize().height-5))
	backItem:registerScriptTapHandler(closeButtonCallback)
	menu:addChild(backItem,1,tonumber(uid))
end


-- 关闭按钮回调
function closeButtonCallback( ... )
	-- 音效
	require "script/audio/AudioUtil"
	AudioUtil.playEffect("audio/effect/guanbi.mp3")
	if(mainLayer)then
		mainLayer:removeFromParentAndCleanup(true)
		mainLayer = nil
	end
end


-- 按钮item
function createButtonItem( str )
	local normalSprite  =CCScale9Sprite:create("images/common/btn/btn_blue_n.png")
    normalSprite:setContentSize(CCSizeMake(202,64))
    local selectSprite  =CCScale9Sprite:create("images/common/btn/btn_blue_h.png")
    selectSprite:setContentSize(CCSizeMake(202,64))
    local item = CCMenuItemSprite:create(normalSprite,selectSprite)
    -- 字体
	local item_font = CCRenderLabel:create( str , g_sFontPangWa, 30, 1, ccc3( 0x00, 0x00, 0x00), type_stroke)
    item_font:setColor(ccc3(0xfe, 0xdb, 0x1c))
    item_font:setPosition(ccp((item:getContentSize().width-item_font:getContentSize().width)*0.5,item:getContentSize().height-11))
   	item:addChild(item_font)
   	return item
end


-- 留言回调
function leaveMessageItemFun( tag, item_obj )
	-- 音效
    require "script/audio/AudioUtil"
    AudioUtil.playEffect("audio/effect/zhujiemian.mp3")
	local isFriend = FriendData.isMyFriendByUid(tag)
	if(isFriend == false)then
		require "script/ui/tip/AnimationTip"
		local str = GetLocalizeStringBy("lic_1000")
		AnimationTip.showTip(str)
		-- 删除成功后关闭交流层
		closeButtonCallback()
		return
	end
	leaveMessageLayer = CCLayerColor:create(ccc4(11,11,11,200))
	leaveMessageLayer:setTouchEnabled(true)
    leaveMessageLayer:registerScriptTouchHandler(cardLayerTouch,false,-420,true)
    
    local scene = CCDirector:sharedDirector():getRunningScene()
    scene:addChild(leaveMessageLayer,1999,78432)
    -- 创建好友回复背景
    local leaveMessage_bg = BaseUI.createViewBg(CCSizeMake(523,360))
    leaveMessage_bg:setPosition(ccp(g_winSize.width*0.5,g_winSize.height*0.5))
    leaveMessageLayer:addChild(leaveMessage_bg)
    -- 适配
	setAdaptNode(leaveMessage_bg)

    -- 关闭按钮
	local closeMenu = CCMenu:create()
	closeMenu:setTouchPriority(-420)
	closeMenu:setPosition(ccp(0, 0))
	closeMenu:setAnchorPoint(ccp(0, 0))
	leaveMessage_bg:addChild(closeMenu,3)
	local closeButton = CCMenuItemImage:create("images/common/btn_close_n.png", "images/common/btn_close_h.png")
	closeButton:setAnchorPoint(ccp(0.5, 0.5))
	closeButton:setPosition(ccp(leaveMessage_bg:getContentSize().width*0.95, leaveMessage_bg:getContentSize().height*0.92 ))
	closeButton:registerScriptTapHandler(closeButtonCallbackTwo)
	closeMenu:addChild(closeButton)

	-- 标题文字
	local font = CCRenderLabel:create( GetLocalizeStringBy("key_2680") , g_sFontPangWa, 35, 1, ccc3( 0xff, 0xff, 0xff), type_stroke)
    font:setColor(ccc3(0x78, 0x25, 0x00))
    font:setPosition(ccp((leaveMessage_bg:getContentSize().width-font:getContentSize().width)*0.5,leaveMessage_bg:getContentSize().height-38))
    leaveMessage_bg:addChild(font)

    -- 编辑框背景
    local editBox_bg = BaseUI.createContentBg(CCSizeMake(466,153))
    -- 编辑框
    editBox = CCEditBox:create(CCSizeMake(440,130), editBox_bg)
    editBox:setMaxLength(40)
    editBox:setReturnType(kKeyboardReturnTypeDone)
    editBox:setInputFlag(kEditBoxInputFlagInitialCapsWord)
    editBox:setPlaceHolder(GetLocalizeStringBy("key_1994"))
    editBox:setFont(g_sFontName, 23)
    editBox:setFontColor(ccc3(0xcd,0xcd,0xcd))
    editBox:setPosition(ccp(leaveMessage_bg:getContentSize().width*0.5,leaveMessage_bg:getContentSize().height*0.5))
    editBox:setTouchPriority(-420)
    leaveMessage_bg:addChild(editBox)
    -- 单行输入多行显示
    if(editBox:getChildByTag(1001) ~= nil)then 
	    tolua.cast(editBox:getChildByTag(1001),"CCLabelTTF"):setDimensions(CCSizeMake(440,130))
	    -- tolua.cast(editBox:getChildByTag(1002),"CCLabelTTF"):setDimensions(CCSizeMake(440,130))
	    tolua.cast(editBox:getChildByTag(1001),"CCLabelTTF"):setVerticalAlignment(kCCVerticalTextAlignmentTop)
	    -- tolua.cast(editBox:getChildByTag(1002),"CCLabelTTF"):setVerticalAlignment(kCCVerticalTextAlignmentTop)
	    tolua.cast(editBox:getChildByTag(1001),"CCLabelTTF"):setHorizontalAlignment(kCCTextAlignmentLeft)
	    -- tolua.cast(editBox:getChildByTag(1002),"CCLabelTTF"):setHorizontalAlignment(kCCTextAlignmentLeft)
    end
    -- 发送,关闭按钮
    local menu = CCMenu:create()
    menu:setTouchPriority(-420)
    menu:setPosition(ccp(0,0))
    leaveMessage_bg:addChild(menu)
    -- 发送
    local sendMenuItem = createButtonMenuItemTwo(GetLocalizeStringBy("key_1138"))
    sendMenuItem:setAnchorPoint(ccp(0,0))
    sendMenuItem:setPosition(ccp(88,32))
    menu:addChild(sendMenuItem,1,tag)
    -- 注册回调
    sendMenuItem:registerScriptTapHandler(sendMenuItemFun)

    -- 关闭
    local closeMenuItem = createButtonMenuItemTwo(GetLocalizeStringBy("key_2474"))
    closeMenuItem:setAnchorPoint(ccp(1,0))
    closeMenuItem:setPosition(ccp(leaveMessage_bg:getContentSize().width-88,32))
    menu:addChild(closeMenuItem)
    -- 注册回调
    closeMenuItem:registerScriptTapHandler(closeButtonCallbackTwo)
end

-- 创建好友留言按钮item 
-- str:按钮上文字
function createButtonMenuItemTwo( str )
	local item = CCMenuItemImage:create("images/common/btn/btn_blue_n.png", "images/common/btn/btn_blue_h.png")
	-- 字体
	local item_font = CCRenderLabel:create( str , g_sFontPangWa, 30, 1, ccc3( 0x00, 0x00, 0x00), type_stroke)
    item_font:setColor(ccc3(0xfe, 0xdb, 0x1c))
    item_font:setPosition(ccp(24,item:getContentSize().height-11))
   	item:addChild(item_font)
   	return item
end

-- 关闭按钮回调
function closeButtonCallbackTwo( tag, item_obj )
	-- 音效
	require "script/audio/AudioUtil"
	AudioUtil.playEffect("audio/effect/guanbi.mp3")
	leaveMessageLayer:removeFromParentAndCleanup(true)
	leaveMessageLayer = nil
end

-- 发送回调
function sendMenuItemFun( tag, item_obj)
	-- 音效
    require "script/audio/AudioUtil"
    AudioUtil.playEffect("audio/effect/zhujiemian.mp3")
	-- print("发送uid" .. tag)
	local isFriend = FriendData.isMyFriendByUid(tag)
	if(isFriend == false)then
		require "script/ui/tip/AnimationTip"
		local str = GetLocalizeStringBy("lic_1000")
		AnimationTip.showTip(str)
		-- 删除发送层
		closeButtonCallbackTwo()
		-- 删除成功后关闭交流层
		closeButtonCallback()
		return
	end
	local function createNext( dataRet )
		-- 发送成功后关闭本层
		closeButtonCallbackTwo()
		require "script/ui/tip/AnimationTip"
		local str = GetLocalizeStringBy("key_2170")
		AnimationTip.showTip(str)
	end
 	local content = editBox:getText()
	FriendService.sendMail(tag, 0, content,createNext)
end

-- 查看信息回调
function lookInfoItemFun( tag, item_obj )
	-- 音效
    require "script/audio/AudioUtil"
    AudioUtil.playEffect("audio/effect/zhujiemian.mp3")
	local isFriend = FriendData.isMyFriendByUid(tag)
	if(isFriend == false)then
		require "script/ui/tip/AnimationTip"
		local str = GetLocalizeStringBy("lic_1000")
		AnimationTip.showTip(str)
		-- 删除成功后关闭交流层
		closeButtonCallback()
		return
	end
    require "script/ui/active/RivalInfoLayer"
    RivalInfoLayer.createLayer(tag)
end

-- 删除好友回调
function deleteItemFun( tag, item_obj )
	-- 音效
    require "script/audio/AudioUtil"
    AudioUtil.playEffect("audio/effect/zhujiemian.mp3")
    local isFriend = FriendData.isMyFriendByUid(tag)
	if(isFriend == false)then
		require "script/ui/tip/AnimationTip"
		local str = GetLocalizeStringBy("lic_1000")
		AnimationTip.showTip(str)
		-- 删除成功后关闭交流层
		closeButtonCallback()
		return
	end

	-- 删除好友弹出框
	deleteFriendLayer = CCLayerColor:create(ccc4(11,11,11,200))
	deleteFriendLayer:setTouchEnabled(true)
    deleteFriendLayer:registerScriptTouchHandler(cardLayerTouch,false,-420,true)
    
    local scene = CCDirector:sharedDirector():getRunningScene()
    scene:addChild(deleteFriendLayer,1999,78432)
    -- 创建好友回复背景
    local deleteFriend_bg = BaseUI.createViewBg(CCSizeMake(523,360))
    deleteFriend_bg:setPosition(ccp(g_winSize.width*0.5,g_winSize.height*0.5))
    deleteFriendLayer:addChild(deleteFriend_bg)
    -- 适配
	setAdaptNode(deleteFriend_bg)

    -- 关闭按钮
	local closeMenu = CCMenu:create()
	closeMenu:setTouchPriority(-420)
	closeMenu:setPosition(ccp(0, 0))
	closeMenu:setAnchorPoint(ccp(0, 0))
	deleteFriend_bg:addChild(closeMenu,3)
	local closeButton = CCMenuItemImage:create("images/common/btn_close_n.png", "images/common/btn_close_h.png")
	closeButton:setAnchorPoint(ccp(0.5, 0.5))
	closeButton:setPosition(ccp(deleteFriend_bg:getContentSize().width*0.95, deleteFriend_bg:getContentSize().height*0.92 ))
	closeButton:registerScriptTapHandler(closeButtonCallbackThree)
	closeMenu:addChild(closeButton)

	-- 标题文字
	local font = CCRenderLabel:create( GetLocalizeStringBy("key_2706") , g_sFontPangWa, 35, 1, ccc3( 0xff, 0xff, 0xff), type_stroke)
    font:setColor(ccc3(0x78, 0x25, 0x00))
    font:setPosition(ccp((deleteFriend_bg:getContentSize().width-font:getContentSize().width)*0.5,deleteFriend_bg:getContentSize().height-38))
    deleteFriend_bg:addChild(font)

    -- 文字提示
    -- 玩家的姓名和性别
    local user_name,user_utid = FriendData.getMyfriendName(tag)
    -- 玩家姓名的颜色
    local name_color,stroke_color = MyFriendCell.getHeroNameColor( user_utid )
   	-- 创建文本
	local text_font1 = CCLabelTTF:create(GetLocalizeStringBy("key_1222"),g_sFontName,25)
	text_font1:setColor(ccc3(0x78,0x25,0x00))
	text_font1:setAnchorPoint(ccp(0,1))
	deleteFriend_bg:addChild(text_font1)
   	local text_name = CCRenderLabel:create( user_name, g_sFontName, 25, 1, stroke_color, type_stroke)
    text_name:setColor(name_color)
   	deleteFriend_bg:addChild(text_name)
   	local text_font2 = CCLabelTTF:create(GetLocalizeStringBy("key_2490"),g_sFontName,25)
	text_font2:setColor(ccc3(0x78,0x25,0x00))
	text_font2:setAnchorPoint(ccp(0,1))
	deleteFriend_bg:addChild(text_font2)
	-- 居中计算
	local text_x = (deleteFriend_bg:getContentSize().width - (text_font1:getContentSize().width+text_name:getContentSize().width+text_font2:getContentSize().width))/2
	local text_y = deleteFriend_bg:getContentSize().height-150
	text_font1:setPosition(ccp(text_x,text_y))
	text_name:setPosition(ccp(text_font1:getPositionX()+text_font1:getContentSize().width+5,deleteFriend_bg:getContentSize().height-150))
	text_font2:setPosition(ccp(text_name:getPositionX()+text_name:getContentSize().width+5,deleteFriend_bg:getContentSize().height-150))

    -- 确定,取消按钮
    local menu = CCMenu:create()
    menu:setTouchPriority(-420)
    menu:setPosition(ccp(0,0))
    deleteFriend_bg:addChild(menu)
    -- 确定
    local sendMenuItem = createButtonMenuItemTwo(GetLocalizeStringBy("key_1985"))
    sendMenuItem:setAnchorPoint(ccp(0,0))
    sendMenuItem:setPosition(ccp(88,32))
    menu:addChild(sendMenuItem,1,tag)
    -- 注册回调
    sendMenuItem:registerScriptTapHandler(YesMenuItemFun)

    -- 取消
    local closeMenuItem = createButtonMenuItemTwo(GetLocalizeStringBy("key_1202"))
    closeMenuItem:setAnchorPoint(ccp(1,0))
    closeMenuItem:setPosition(ccp(deleteFriend_bg:getContentSize().width-88,32))
    menu:addChild(closeMenuItem)
    -- 注册回调
    closeMenuItem:registerScriptTapHandler(closeButtonCallbackThree)
end

-- 挑战
function pkItemFun( tag, item_obj )
	-- 音效
    require "script/audio/AudioUtil"
    AudioUtil.playEffect("audio/effect/zhujiemian.mp3")
    local isFriend = FriendData.isMyFriendByUid(tag)
	if(isFriend == false)then
		require "script/ui/tip/AnimationTip"
		local str = GetLocalizeStringBy("lic_1000")
		AnimationTip.showTip(str)
		-- 删除成功后关闭交流层
		closeButtonCallback()
		return
	end
    require "script/ui/friend/PKFriendLayer"
    PKFriendLayer.showPkLayer(tag)
end

-- 关闭按钮回调
function closeButtonCallbackThree( tag, item_obj )
	-- 音效
	require "script/audio/AudioUtil"
	AudioUtil.playEffect("audio/effect/guanbi.mp3")
	deleteFriendLayer:removeFromParentAndCleanup(true)
	deleteFriendLayer = nil
end


--  确定按钮回调
function YesMenuItemFun( tag, item_obj )
	-- 音效
    require "script/audio/AudioUtil"
    AudioUtil.playEffect("audio/effect/zhujiemian.mp3")
	-- print(GetLocalizeStringBy("key_2418") .. tag)
	local isFriend = FriendData.isMyFriendByUid(tag)
	if(isFriend == false)then
		require "script/ui/tip/AnimationTip"
		local str = GetLocalizeStringBy("lic_1000")
		AnimationTip.showTip(str)
		-- 删除屏蔽层
		closeButtonCallbackThree()
		-- 删除成功后关闭交流层
		closeButtonCallback()
		return
	end
	local function createNext( dataRet )
		-- 更新好友列表
		print("FriendData.friendPage ..",FriendData.friendPage)
		-- 删除数据
		FriendData.deleteFriendData(tag)
		-- 刷新数据
		local lastHight = table.count(FriendData.showFriendData) * 120*g_fScaleX
		FriendData.showFriendData = FriendData.getShowMyFriendData( FriendData.friendPage )
		local newHight = table.count(FriendData.showFriendData) * 120*g_fScaleX
		local offset = MyFriendLayer.friendTableView:getContentOffset()
		MyFriendLayer.friendTableView:reloadData()
		print("offset -- ", offset.y)
		print("lastHight",lastHight,"newHight",newHight)
		if(lastHight > newHight)then
			if(offset.y ~= 0)then
				MyFriendLayer.friendTableView:setContentOffset(ccp(offset.x,offset.y+120*g_fScaleX))
			else
				MyFriendLayer.friendTableView:setContentOffset(ccp(offset.x,0))
			end
		else
			MyFriendLayer.friendTableView:setContentOffset(offset)
		end
		-- 更新显示好友总数
		MyFriendLayer.updateFriendsCountFont()
		-- 删除屏蔽层
		closeButtonCallbackThree()
		-- 删除成功后关闭交流层
		closeButtonCallback()
	end
	FriendService.delFriend(tag,createNext)
end

-- 拉黑回调
function blackItemFun( tag, item_obj )
	-- 音效
    require "script/audio/AudioUtil"
    AudioUtil.playEffect("audio/effect/zhujiemian.mp3")
	local isFriend = FriendData.isMyFriendByUid(tag)
	if(isFriend == false)then
		require "script/ui/tip/AnimationTip"
		local str = GetLocalizeStringBy("lic_1000")
		AnimationTip.showTip(str)
		-- 删除成功后关闭交流层
		closeButtonCallback()
		return
	end
	local function createNext( dataRet )
		-- 更新好友列表
		print("FriendData.friendPage ..",FriendData.friendPage)
		-- 删除数据
		FriendData.deleteFriendData(tag)
		-- 刷新数据
		local lastHight = table.count(FriendData.showFriendData) * 120*g_fScaleX
		FriendData.showFriendData = FriendData.getShowMyFriendData( FriendData.friendPage )
		local newHight = table.count(FriendData.showFriendData) * 120*g_fScaleX
		local offset = MyFriendLayer.friendTableView:getContentOffset()
		MyFriendLayer.friendTableView:reloadData()
		print("offset -- ", offset.y)
		if(lastHight > newHight)then
			if(offset.y ~= 0)then
				MyFriendLayer.friendTableView:setContentOffset(ccp(offset.x,offset.y+120*g_fScaleX))
			else
				MyFriendLayer.friendTableView:setContentOffset(ccp(offset.x,0))
			end
		else
			MyFriendLayer.friendTableView:setContentOffset(offset)
		end
		-- 更新显示好友总数
		MyFriendLayer.updateFriendsCountFont()
		-- 删除成功后关闭交流层
		closeButtonCallback()
	end
	FriendService.blackYou(tag,createNext)
end













