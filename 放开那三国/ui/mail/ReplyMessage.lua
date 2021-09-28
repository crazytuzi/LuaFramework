-- FileName: ReplyMessage.lua 
-- Author: Li Cong 
-- Date: 13-8-26 
-- Purpose: function description of module 


module("ReplyMessage", package.seeall)

local replyLayer = nil
local editBox = nil

local function cardLayerTouch(eventType, x, y)
   
    return true
    
end



-- 创建好友回复按钮
function createReplyMessageLayer( uid )
	replyLayer = CCLayerColor:create(ccc4(11,11,11,166))

	replyLayer:setTouchEnabled(true)
    replyLayer:registerScriptTouchHandler(cardLayerTouch,false,-410,true)
    
    local scene = CCDirector:sharedDirector():getRunningScene()
    scene:addChild(replyLayer,1999,78431)

    -- 创建好友回复背景
    local reply_bg = BaseUI.createViewBg(CCSizeMake(523,360))
    reply_bg:setPosition(ccp(g_winSize.width*0.5,g_winSize.height*0.5))
    replyLayer:addChild(reply_bg)
    -- 适配
    setAdaptNode(reply_bg)

    -- 关闭按钮
	local closeMenu = CCMenu:create()
	closeMenu:setTouchPriority(-410)
	closeMenu:setPosition(ccp(0, 0))
	closeMenu:setAnchorPoint(ccp(0, 0))
	reply_bg:addChild(closeMenu,3)
	local closeButton = CCMenuItemImage:create("images/common/btn_close_n.png", "images/common/btn_close_h.png")
	closeButton:setAnchorPoint(ccp(0.5, 0.5))
	closeButton:setPosition(ccp(reply_bg:getContentSize().width*0.95, reply_bg:getContentSize().height*0.92 ))
	closeButton:registerScriptTapHandler(closeButtonCallback)
	closeMenu:addChild(closeButton)

	-- 标题文字
	local font = CCRenderLabel:create( GetLocalizeStringBy("key_2211") , g_sFontPangWa, 35, 1, ccc3( 0xff, 0xff, 0xff), type_stroke)
    font:setColor(ccc3(0x78, 0x25, 0x00))
    font:setPosition(ccp((reply_bg:getContentSize().width-font:getContentSize().width)*0.5,reply_bg:getContentSize().height-38))
    reply_bg:addChild(font)

    -- 编辑框背景
    local editBox_bg = BaseUI.createContentBg(CCSizeMake(466,153))
    -- 编辑框
    editBox = CCEditBox:create(CCSizeMake(440,130), editBox_bg)
    editBox:setMaxLength(40)
    editBox:setReturnType(kKeyboardReturnTypeDone)
    editBox:setInputFlag(kEditBoxInputFlagInitialCapsWord)
    editBox:setPlaceHolder(GetLocalizeStringBy("key_2052"))
    editBox:setFont(g_sFontName, 23)
    editBox:setFontColor(ccc3(0xcd,0xcd,0xcd))
    editBox:setPosition(ccp(reply_bg:getContentSize().width*0.5,reply_bg:getContentSize().height*0.5))
    editBox:setTouchPriority(-410)
    reply_bg:addChild(editBox)

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
    menu:setTouchPriority(-410)
    menu:setPosition(ccp(0,0))
    reply_bg:addChild(menu)
    -- 发送
    local sendMenuItem = createButtonMenuItem(GetLocalizeStringBy("key_1138"))
    sendMenuItem:setAnchorPoint(ccp(0,0))
    sendMenuItem:setPosition(ccp(88,32))
    menu:addChild(sendMenuItem,1,uid)
    -- 注册回调
    sendMenuItem:registerScriptTapHandler(sendMenuItemFun)

    -- 关闭
    local closeMenuItem = createButtonMenuItem(GetLocalizeStringBy("key_2474"))
    closeMenuItem:setAnchorPoint(ccp(1,0))
    closeMenuItem:setPosition(ccp(reply_bg:getContentSize().width-88,32))
    menu:addChild(closeMenuItem,1,uid)
    -- 注册回调
    closeMenuItem:registerScriptTapHandler(closeButtonCallback)

end


-- 关闭按钮回调
function closeButtonCallback( tag, item_obj )
    -- 音效
    require "script/audio/AudioUtil"
    AudioUtil.playEffect("audio/effect/guanbi.mp3")
	-- print("closeButtonCallback")
	replyLayer:removeFromParentAndCleanup(true)
	replyLayer = nil
end


-- 创建按钮item 
-- str:按钮上文字
function createButtonMenuItem( str )
	local item = CCMenuItemImage:create(Mail.COMMON_PATH .. "btn/btn_blue_n.png",Mail.COMMON_PATH .. "btn/btn_blue_h.png")
	-- 字体
	local item_font = CCRenderLabel:create( str , g_sFontPangWa, 30, 1, ccc3( 0x00, 0x00, 0x00), type_stroke)
    item_font:setColor(ccc3(0xfe, 0xdb, 0x1c))
    item_font:setPosition(ccp(24,item:getContentSize().height-11))
   	item:addChild(item_font)
   	return item
end



function sendMenuItemFun( tag, item_obj)
    -- 音效
    require "script/audio/AudioUtil"
    AudioUtil.playEffect("audio/effect/zhujiemian.mp3")
	-- print("发送uid" .. tag)
    local function nextFun( ... )
    	local function createNext( dataRet )
    		-- 发送成功后关闭本层
    		closeButtonCallback()
            require "script/ui/tip/AnimationTip"
            local str = GetLocalizeStringBy("key_3332")
            AnimationTip.showTip(str)
    	end
     	local content = editBox:getText()
     	-- print("content",content,type(content) )
    	MailService.sendMail(tag, 0, content,createNext)
    end
    require "script/ui/friend/FriendService"
    FriendService.isFriend(tag,nextFun,1)
end





























