-- FileName: RecommendCell.lua 
-- Author: Li Cong 
-- Date: 13-8-27 
-- Purpose: function description of module 


module("RecommendCell", package.seeall)

local inviteFriendLayer = nil
local editBox = nil
-- touch事件处理
local function cardLayerTouch(eventType, x, y)
   
    return true
    
end

-- 玩家名字的颜色
function getHeroNameColor( utid )
	local name_color = nil
	local stroke_color = nil
	if(tonumber(utid) == 1)then
		-- 女性玩家
		name_color = ccc3(0xf9,0x59,0xff)
		stroke_color = ccc3(0x00,0x00,0x00)
	elseif(tonumber(utid) == 2)then
		-- 男性玩家 
		name_color = ccc3(0x00,0xe4,0xff)
		stroke_color = ccc3(0x00,0x00,0x00)
	end
	return name_color, stroke_color
end


-- 创建cell
function createCell( tCellValue )
	-- print("cell数据tCellValue:")
	-- print_t(tCellValue)
	-- 创建cell
 	-- local cell = CCTableViewCell:create()
 	-- cell背景
 	local cell_bg = BaseUI.createYellowBg(CCSizeMake(584,110))
	-- 名字背景
	local name_bg = CCScale9Sprite:create( FriendLayer.IMG_PATH .. "friend_name_bg.png")
	name_bg:setContentSize(CCSizeMake(330,36))
	name_bg:setAnchorPoint(ccp(0,1))
	name_bg:setPosition(ccp(10,cell_bg:getContentSize().height-10))
	cell_bg:addChild(name_bg)
	-- 名字等级
	-- lv.
	local lv_sprite = CCSprite:create(FriendLayer.COMMON_PATH .. "lv.png")
	lv_sprite:setAnchorPoint(ccp(0,1))
	lv_sprite:setPosition(ccp(16,name_bg:getContentSize().height-10))
	name_bg:addChild(lv_sprite)
	-- 等级
	local lv_data = CCRenderLabel:create( tCellValue.level , g_sFontName, 21, 1, ccc3( 0x00, 0x00, 0x00), type_stroke)
    lv_data:setColor(ccc3(0xff, 0xf6, 0x00))
    lv_data:setPosition(ccp(lv_sprite:getPositionX()+lv_sprite:getContentSize().width+5,name_bg:getContentSize().height-8))
   	name_bg:addChild(lv_data)
   	-- 名字
   	-- 玩家名字颜色
	local name_color,stroke_color = getHeroNameColor( tCellValue.utid )
   	local name = CCRenderLabel:create( tCellValue.uname , g_sFontName, 23, 1, stroke_color, type_stroke)
    name:setColor(name_color)
    name:setPosition(ccp(107,name_bg:getContentSize().height-6))
   	name_bg:addChild(name)

   	-- 战斗力
   	local fight_sprite = CCSprite:create(FriendLayer.COMMON_PATH .. "fight_value02.png")
   	fight_sprite:setAnchorPoint(ccp(0,0))
   	fight_sprite:setPosition(ccp(31,14))
   	cell_bg:addChild(fight_sprite)
   	-- 战斗力数据
   	local fight_data = CCRenderLabel:create( tCellValue.fight_force , g_sFontName, 23, 1, ccc3( 0x00, 0x00, 0x00), type_stroke)
    fight_data:setColor(ccc3(0xff, 0xf6, 0x00))
    fight_data:setPosition(ccp(133,43))
   	cell_bg:addChild(fight_data)

    -- 邀请按钮
	local inviteMenu = BTSensitiveMenu:create()
	if(inviteMenu:retainCount()>1)then
		inviteMenu:release()
		inviteMenu:autorelease()
	end
	inviteMenu:setPosition(ccp(0,0))
	cell_bg:addChild(inviteMenu)
	local inviteMenuItem = CCMenuItemImage:create(FriendLayer.IMG_PATH .. "friend_btn_n.png",FriendLayer.IMG_PATH .. "friend_btn_h.png")
	inviteMenuItem:setAnchorPoint(ccp(1,0.5))
	inviteMenuItem:setPosition(ccp(cell_bg:getContentSize().width-10, cell_bg:getContentSize().height*0.5))
	inviteMenu:addChild(inviteMenuItem,1,tonumber(tCellValue.uid))
	-- 注册回调
	inviteMenuItem:registerScriptTapHandler(inviteMenuItemCallFun)
	-- 邀请字体
	--兼容东南亚英文版
	local item_font
	if(Platform.getLayout ~= nil and Platform.getLayout() == "enLayout" ) then
		item_font = CCRenderLabel:create( GetLocalizeStringBy("key_3263"), g_sFontPangWa, 25, 1, ccc3( 0x00, 0x00, 0x00), type_stroke)
	else
		item_font = CCRenderLabel:create( GetLocalizeStringBy("key_3263"), g_sFontPangWa, 38, 1, ccc3( 0x00, 0x00, 0x00), type_stroke)
	end
    item_font:setColor(ccc3(0xfe, 0xdb, 0x1c))
    item_font:setAnchorPoint(ccp(0.5,0.5))
    item_font:setPosition(ccp(inviteMenuItem:getContentSize().width*0.5,inviteMenuItem:getContentSize().height*0.5))
   	inviteMenuItem:addChild(item_font)

 	return cell_bg
end



-- 邀请按钮回调
function inviteMenuItemCallFun( tag, item_obj)
	-- 音效
    require "script/audio/AudioUtil"
    AudioUtil.playEffect("audio/effect/zhujiemian.mp3")
	-- print(GetLocalizeStringBy("key_2791").. tag)
	require "script/model/user/UserModel"
	if(tag == UserModel.getUserUid())then
		require "script/ui/tip/AnimationTip"
		local str = GetLocalizeStringBy("key_1234")
		AnimationTip.showTip(str)
		return
	end
	-- 创建下一步UI
	local function createNext( ... )
		-- 创建邀请界面
		inviteFriendLayer = CCLayerColor:create(ccc4(11,11,11,200))
		inviteFriendLayer:setTouchEnabled(true)
	    inviteFriendLayer:registerScriptTouchHandler(cardLayerTouch,false,-420,true)
	    
	    local scene = CCDirector:sharedDirector():getRunningScene()
	    scene:addChild(inviteFriendLayer,1999,78432)
	    -- 创建好友回复背景
	    local inviteFriend_bg = BaseUI.createViewBg(CCSizeMake(523,360))
	    inviteFriend_bg:setPosition(ccp(g_winSize.width*0.5,g_winSize.height*0.5))
	    inviteFriendLayer:addChild(inviteFriend_bg)
	    -- 适配
	    setAdaptNode(inviteFriend_bg)

	    -- 关闭按钮
		local closeMenu = CCMenu:create()
		closeMenu:setTouchPriority(-420)
		closeMenu:setPosition(ccp(0, 0))
		closeMenu:setAnchorPoint(ccp(0, 0))
		inviteFriend_bg:addChild(closeMenu,3)
		local closeButton = CCMenuItemImage:create("images/common/btn_close_n.png", "images/common/btn_close_h.png")
		closeButton:setAnchorPoint(ccp(0.5, 0.5))
		closeButton:setPosition(ccp(inviteFriend_bg:getContentSize().width*0.95, inviteFriend_bg:getContentSize().height*0.92 ))
		closeButton:registerScriptTapHandler(closeButtonCallbackTwo)
		closeMenu:addChild(closeButton)

		-- 标题文字
		local font = CCRenderLabel:create( GetLocalizeStringBy("key_1611") , g_sFontPangWa, 35, 1, ccc3( 0xff, 0xff, 0xff), type_stroke)
	    font:setColor(ccc3(0x78, 0x25, 0x00))
	    font:setPosition(ccp((inviteFriend_bg:getContentSize().width-font:getContentSize().width)*0.5,inviteFriend_bg:getContentSize().height-38))
	    inviteFriend_bg:addChild(font)

	    -- 编辑框背景
	    local editBox_bg = BaseUI.createContentBg(CCSizeMake(466,153))
	    -- 编辑框
	    editBox = CCEditBox:create(CCSizeMake(440,130), editBox_bg)
	    editBox:setMaxLength(30)
	    editBox:setReturnType(kKeyboardReturnTypeDone)
	    editBox:setInputFlag(kEditBoxInputFlagInitialCapsWord)
	    editBox:setText(GetLocalizeStringBy("key_2659"))
	    editBox:setFont(g_sFontName, 23)
	    editBox:setFontColor(ccc3(0xcd,0xcd,0xcd))
	    editBox:setPosition(ccp(inviteFriend_bg:getContentSize().width*0.5,inviteFriend_bg:getContentSize().height*0.5))
	    editBox:setTouchPriority(-420)
	    inviteFriend_bg:addChild(editBox)
	    -- 单行输入多行显示
	    if(editBox:getChildByTag(1001) ~= nil)then
		    tolua.cast(editBox:getChildByTag(1001),"CCLabelTTF"):setDimensions(CCSizeMake(440,130))
		    -- tolua.cast(editBox:getChildByTag(1002),"CCLabelTTF"):setDimensions(CCSizeMake(440,130))
		    tolua.cast(editBox:getChildByTag(1001),"CCLabelTTF"):setVerticalAlignment(kCCVerticalTextAlignmentTop)
		    -- tolua.cast(editBox:getChildByTag(1002),"CCLabelTTF"):setVerticalAlignment(kCCVerticalTextAlignmentTop)
		    tolua.cast(editBox:getChildByTag(1001),"CCLabelTTF"):setHorizontalAlignment(kCCTextAlignmentLeft)
		    -- tolua.cast(editBox:getChildByTag(1002),"CCLabelTTF"):setHorizontalAlignment(kCCTextAlignmentLeft)
	    end
	    -- 确定，取消按钮
	    local menu = CCMenu:create()
	    menu:setTouchPriority(-420)
	    menu:setPosition(ccp(0,0))
	    inviteFriend_bg:addChild(menu)
	    -- 确定
	    local sendMenuItem = createButtonMenuItemTwo(GetLocalizeStringBy("key_1985"))
	    sendMenuItem:setAnchorPoint(ccp(0,0))
	    sendMenuItem:setPosition(ccp(88,32))
	    menu:addChild(sendMenuItem,1,tag)
	    -- 注册回调
	    sendMenuItem:registerScriptTapHandler(sendMenuItemFun)

	    -- 取消
	    local closeMenuItem = createButtonMenuItemTwo(GetLocalizeStringBy("key_1202"))
	    closeMenuItem:setAnchorPoint(ccp(1,0))
	    closeMenuItem:setPosition(ccp(inviteFriend_bg:getContentSize().width-88,32))
	    menu:addChild(closeMenuItem)
	    -- 注册回调
	    closeMenuItem:registerScriptTapHandler(closeButtonCallbackTwo)
	end
	-- 判断是否是好友
	FriendService.isFriend(tag,createNext)
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
	inviteFriendLayer:removeFromParentAndCleanup(true)
	inviteFriendLayer = nil
end

-- 发送回调
function sendMenuItemFun( tag, item_obj)
	-- 音效
    require "script/audio/AudioUtil"
    AudioUtil.playEffect("audio/effect/zhujiemian.mp3")
	-- print("发送uid" .. tag)

	local function createNext( dataRet )
		-- 发送成功后关闭本层
		closeButtonCallbackTwo()
		require "script/ui/tip/AnimationTip"
		local str = GetLocalizeStringBy("key_1714")
		AnimationTip.showTip(str)
	end
 	local content = editBox:getText()
 	local contentStr = string.gsub(content, "\n", "")
	FriendService.applyFriend(tag,contentStr,createNext)
end






