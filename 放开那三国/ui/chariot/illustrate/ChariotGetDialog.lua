-- FileName: ChariotGetDialog.lua
-- Author: lgx
-- Date: 2016-06-27
-- Purpose: 战车获取途径界面

module("ChariotGetDialog", package.seeall)

require "script/libs/LuaCCSprite"
require "script/libs/LuaCCLabel"
require "script/ui/chariot/ChariotMainData"
require "script/ui/item/ItemSprite"

local _touchPriority 	= nil -- 触摸优先级
local _zOrder 			= nil -- 显示层级
local _dialog			= nil -- 背景框

--[[
	@desc 	: 初始化方法
	@param 	: 
	@return : 
--]]
local function init()
	_touchPriority 	= nil
 	_zOrder 		= nil
 	_dialog			= nil
end

--[[
	@desc 	: 创建Dialog及UI
	@param 	: pChariotTid 战车Tid
	@param 	: pTouchPriority 触摸优先级
	@param 	: pZorder 显示层级
	@return : 
--]]
function createDialog( pChariotTid, pTouchPriority, pZorder )
	-- 初始化
	init()

	_touchPriority = pTouchPriority or -500
	_zOrder = pZorder or 5000

	local dialogInfo = {
	    title = GetLocalizeStringBy("key_8348"),
	    callbackClose = nil,
	    size = CCSizeMake(530, 351),
	    priority = _touchPriority,
	    swallowTouch = true,
	    isRunning = nil
	}
	_dialog = LuaCCSprite.createDialog_1(dialogInfo)

	local chariotData = ChariotMainData.getChariotDBByTid(pChariotTid)

	local chariotIcon = ItemSprite.getItemSpriteByItemId(pChariotTid)
	dialogInfo.dialog:addChild(chariotIcon)
	chariotIcon:setAnchorPoint(ccp(0.5, 0.5))
	chariotIcon:setPosition(ccp(dialogInfo.size.width * 0.5, dialogInfo.size.height - 90))

	local chariotNameLabel = CCRenderLabel:create(chariotData.name, g_sFontPangWa, 21, 1, ccc3( 0x00, 0x00, 0x00), type_stroke)
	chariotIcon:addChild(chariotNameLabel)
	chariotNameLabel:setAnchorPoint(ccp(0.5, 0.5))
	chariotNameLabel:setPosition(ccpsprite(0.5, -0.2, chariotIcon))
	-- chariotNameLabel:setColor(ccc3(0xff, 0xf6, 0x00))
	chariotNameLabel:setColor(HeroPublicLua.getCCColorByStarLevel(chariotData.quality))

	local tipBg = CCScale9Sprite:create("images/common/s9_1.png")
	dialogInfo.dialog:addChild(tipBg)
	tipBg:setPreferredSize(CCSizeMake(438, 127))
	tipBg:setAnchorPoint(ccp(0.5, 0))
	tipBg:setPosition(ccp(dialogInfo.size.width * 0.5, 37))

	local descLabel = CCLabelTTF:create(chariotData.reach, g_sFontPangWa, 21, CCSizeMake(400, 0), kCCTextAlignmentCenter)
	tipBg:addChild(descLabel)
	descLabel:setAnchorPoint(ccp(0.5, 0.5))
	descLabel:setPosition(ccpsprite(0.5, 0.5, tipBg))
  	descLabel:setColor(ccc3(0x78, 0x25, 0x00))

	return _dialog
end


--[[
	@desc 	: 显示界面方法
	@param 	: pChariotTid 战车Tid
	@param 	: pTouchPriority 触摸优先级
	@param 	: pZorder 显示层级
	@return : 
--]]
function showDialog( pChariotTid, pTouchPriority, pZorder )
	if (pChariotTid == nil or tonumber(pChariotTid) <= 0) then
		return
	end

	local dialog = createDialog(pChariotTid, pTouchPriority, pZorder)
	local scene = CCDirector:sharedDirector():getRunningScene()
    scene:addChild(dialog,_zOrder)
end

