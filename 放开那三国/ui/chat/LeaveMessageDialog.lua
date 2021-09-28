-- Filename: LeaveMessageDialog.lua
-- Author: bzx
-- Date: 2014-09-17
-- Purpose: 留言板

module("LeaveMessageDialog", package.seeall)

local _layer
local _touchPriority
local _zOrder
local _uid
local _editBox

function show(uid, touchPriority, zOrder)
    _layer = create(uid, touchPriority, zOrder)
    local scene = CCDirector:sharedDirector():getRunningScene()
    scene:addChild(_layer, _zOrder)
end

function create(uid, touchPriority, zOrder)
    init(uid, touchPriority, zOrder)
   	_layer = CCLayerColor:create(ccc4(11,11,11,200))
    _layer:registerScriptTouchHandler(onTouchEvent, false, _touchPriority, true)
    _layer:setTouchEnabled(true)

    -- 创建好友回复背景
    local leaveMessage_bg = BaseUI.createViewBg(CCSizeMake(523,360))
    leaveMessage_bg:setPosition(ccp(g_winSize.width*0.5,g_winSize.height*0.5))
    _layer:addChild(leaveMessage_bg)
    -- 适配
	setAdaptNode(leaveMessage_bg)

    -- 关闭按钮
	local closeMenu = CCMenu:create()
	closeMenu:setTouchPriority(_touchPriority - 1)
	closeMenu:setPosition(ccp(0, 0))
	closeMenu:setAnchorPoint(ccp(0, 0))
	leaveMessage_bg:addChild(closeMenu,3)
	local closeButton = CCMenuItemImage:create("images/common/btn_close_n.png", "images/common/btn_close_h.png")
	closeButton:setAnchorPoint(ccp(0.5, 0.5))
	closeButton:setPosition(ccp(leaveMessage_bg:getContentSize().width*0.95, leaveMessage_bg:getContentSize().height*0.92 ))
	closeButton:registerScriptTapHandler(closeCallback)
	closeMenu:addChild(closeButton)

	-- 标题文字
	local font = CCRenderLabel:create(GetLocalizeStringBy("key_10018") , g_sFontPangWa, 35, 1, ccc3( 0xff, 0xff, 0xff), type_stroke)
    font:setColor(ccc3(0x78, 0x25, 0x00))
    font:setPosition(ccp((leaveMessage_bg:getContentSize().width-font:getContentSize().width)*0.5,leaveMessage_bg:getContentSize().height-38))
    leaveMessage_bg:addChild(font)

    -- 编辑框背景
    local editBox_bg = BaseUI.createContentBg(CCSizeMake(466,153))
    -- 编辑框
    _editBox = CCEditBox:create(CCSizeMake(440,130), editBox_bg)
    _editBox:setMaxLength(40)
    _editBox:setReturnType(kKeyboardReturnTypeDone)
    _editBox:setInputFlag(kEditBoxInputFlagInitialCapsWord)
    _editBox:setPlaceHolder(GetLocalizeStringBy("key_1994"))
    _editBox:setFont(g_sFontName, 23)
    _editBox:setFontColor(ccc3(0xcd,0xcd,0xcd))
    _editBox:setPosition(ccp(leaveMessage_bg:getContentSize().width*0.5,leaveMessage_bg:getContentSize().height*0.5))
    _editBox:setTouchPriority(_touchPriority - 1)
    leaveMessage_bg:addChild(_editBox)
    -- 单行输入多行显示
    if(_editBox:getChildByTag(1001) ~= nil)then 
	    tolua.cast(_editBox:getChildByTag(1001),"CCLabelTTF"):setDimensions(CCSizeMake(440,130))
	    -- tolua.cast(_editBox:getChildByTag(1002),"CCLabelTTF"):setDimensions(CCSizeMake(440,130))
	    tolua.cast(_editBox:getChildByTag(1001),"CCLabelTTF"):setVerticalAlignment(kCCVerticalTextAlignmentTop)
	    -- tolua.cast(_editBox:getChildByTag(1002),"CCLabelTTF"):setVerticalAlignment(kCCVerticalTextAlignmentTop)
	    tolua.cast(_editBox:getChildByTag(1001),"CCLabelTTF"):setHorizontalAlignment(kCCTextAlignmentLeft)
	    -- tolua.cast(_editBox:getChildByTag(1002),"CCLabelTTF"):setHorizontalAlignment(kCCTextAlignmentLeft)
    end
    -- 发送,关闭按钮
    local menu = CCMenu:create()
    menu:setTouchPriority(_touchPriority - 1)
    menu:setPosition(ccp(0,0))
    leaveMessage_bg:addChild(menu)
    -- 发送
    local sendMenuItem = createButtonMenuItemTwo(GetLocalizeStringBy("key_1138"))
    sendMenuItem:setAnchorPoint(ccp(0,0))
    sendMenuItem:setPosition(ccp(88,32))
    menu:addChild(sendMenuItem)
    -- 注册回调
    sendMenuItem:registerScriptTapHandler(sendCallback)

    -- 关闭
    local closeMenuItem = createButtonMenuItemTwo(GetLocalizeStringBy("key_2474"))
    closeMenuItem:setAnchorPoint(ccp(1,0))
    closeMenuItem:setPosition(ccp(leaveMessage_bg:getContentSize().width-88,32))
    menu:addChild(closeMenuItem)
    -- 注册回调
    closeMenuItem:registerScriptTapHandler(closeCallback)
    return _layer
end

function init(uid, touchPriority, zOrder)
    _uid = uid
    _touchPriority = touchPriority or -420
    _zOrder = zOrder or 1999
end


function closeCallback()
    close()
end

function createButtonMenuItemTwo( str )
	local item = CCMenuItemImage:create("images/common/btn/btn_blue_n.png", "images/common/btn/btn_blue_h.png")
	-- 字体
	local item_font = CCRenderLabel:create( str , g_sFontPangWa, 30, 1, ccc3( 0x00, 0x00, 0x00), type_stroke)
    item_font:setColor(ccc3(0xfe, 0xdb, 0x1c))
    item_font:setPosition(ccp(24,item:getContentSize().height-11))
   	item:addChild(item_font)
   	return item
end

function sendCallback()
    -- 音效
    require "script/audio/AudioUtil"
    AudioUtil.playEffect("audio/effect/zhujiemian.mp3")
 	local content = _editBox:getText()
    require "script/ui/friend/FriendService"
	FriendService.sendMail(_uid, 0, content, handleSend)
end

function close()
    _layer:removeFromParentAndCleanup(true)
end

function handleSend()
    close()
    require "script/ui/tip/AnimationTip"
    local str = GetLocalizeStringBy("key_2170")
    AnimationTip.showTip(str)
end

function onTouchEvent(eventType, x, y)
    return true
end

