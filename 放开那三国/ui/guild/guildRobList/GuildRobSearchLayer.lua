-- Filename：	GuildRobSearchLayer.lua
-- Author：		bzx
-- Date：		2014-11-13
-- Purpose：		搜索军团


module("GuildRobSearchLayer", package.seeall)

require "script/libs/LuaCCSprite"

local _layer 
local _dialogInfo
local _touchPriority
local _zOder
local _editBox

function show(touchPriority, zOder)
	_layer = create(touchPriority, zOder)
	CCDirector:sharedDirector():getRunningScene():addChild(_layer, _zOder)
end

function init(touchPriority, zOder)
	_touchPriority = touchPriority or -500
	_zOder = zOder or 500
	_dialogInfo = {
		title = GetLocalizeStringBy("key_8402"),
		callbackClose = nil,
		size = CCSizeMake(538, 331),
		priority = _touchPriority,
		swallowTouch = true,
	}
end

function create(touchPriority, zOder)
	init(_touchPriority, _zOder)
	_layer = LuaCCSprite.createDialog_1(_dialogInfo)

	local tip = CCLabelTTF:create(GetLocalizeStringBy("key_8403"), g_sFontName, 25)
	_dialogInfo.dialog:addChild(tip)
	tip:setAnchorPoint(ccp(0, 0.5))
	tip:setPosition(ccp(72, 229))
	tip:setColor(ccc3(0x78, 0x25, 0x00))

	_editBox = CCEditBox:create (CCSizeMake(398, 50), CCScale9Sprite:create("images/common/bg/white_text_ng.png"))
   	_dialogInfo.dialog:addChild(_editBox)
   	_editBox:setTouchPriority(_touchPriority - 10)
   	_editBox:setPosition(ccp(_dialogInfo.size.width * 0.5, 178))
   	_editBox:setAnchorPoint(ccp(0.5,0.5))
  	_editBox:setMaxLength(100)
   	_editBox:setReturnType(kKeyboardReturnTypeDone)
   	_editBox:setFontColor(ccc3(0x00, 0x00, 0x00))

	local menu = CCMenu:create()
	_dialogInfo.dialog:addChild(menu)
	menu:setPosition(ccp(0, 0))
	menu:setContentSize(_dialogInfo.dialog:getContentSize())
	menu:setTouchPriority(_touchPriority - 10)

	local confirmItem = LuaCC.create9ScaleMenuItem("images/common/btn/btn_blue_n.png", "images/common/btn/btn_blue_h.png", CCSizeMake(175, 64), GetLocalizeStringBy("key_8404"),ccc3(0xfe, 0xdb, 0x1c),30,g_sFontPangWa,1, ccc3(0x00, 0x00, 0x00))
	menu:addChild(confirmItem)
	confirmItem:setAnchorPoint(ccp(0.5, 0.5))
	confirmItem:registerScriptTapHandler(confirmCallback)
	confirmItem:setPosition(ccp(163, 81))

	local cancelItem = LuaCC.create9ScaleMenuItem("images/common/btn/btn_blue_n.png", "images/common/btn/btn_blue_h.png", CCSizeMake(175, 64), GetLocalizeStringBy("key_8405"),ccc3(0xfe, 0xdb, 0x1c),30,g_sFontPangWa,1, ccc3(0x00, 0x00, 0x00))
	menu:addChild(cancelItem)
	cancelItem:setAnchorPoint(ccp(0.5, 0.5))
	cancelItem:registerScriptTapHandler(cancelCallback)
	cancelItem:setPosition(ccp(_dialogInfo.size.width - 163, 81))

	return _layer
end

function cancelCallback( ... )
	close()
end

function confirmCallback( ... )
	local searchKey = _editBox:getText()
	if searchKey == "" then
		AnimationTip.showTip(GetLocalizeStringBy("key_8406"), 0.6)
		return
	end
	local handleGetGuildRobAreaInfo = function (dictData)
		if table.isEmpty(dictData.ret.guildInfo) then
			AnimationTip.showTip(GetLocalizeStringBy("key_8407"), 0.6)
			return
		end
		close()
		GuildRobListLayer:enterSearchResultLayer()
	end
	GuildRobData.getGuildRobAreaInfo(handleGetGuildRobAreaInfo, 1, searchKey)
end

function close( ... )
	_layer:removeFromParentAndCleanup(true)
end