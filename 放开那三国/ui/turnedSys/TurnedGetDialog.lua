-- FileName: TurnedGetDialog.lua
-- Author: lgx
-- Date: 2016-10-11
-- Purpose: 幻化形象获取途径界面

module("TurnedGetDialog", package.seeall)

require "script/libs/LuaCCSprite"
require "script/libs/LuaCCLabel"
require "script/ui/turnedSys/HeroTurnedData"
require "script/ui/turnedSys/HeroTurnedUtil"

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
	@param 	: pTurnId 幻化形象id
	@param 	: pTouchPriority 触摸优先级
	@param 	: pZorder 显示层级
	@return : 
--]]
function createDialog( pTurnId, pTouchPriority, pZorder )
	-- 初始化
	init()

	_touchPriority = pTouchPriority or -700
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

	local turnIcon = HeroTurnedUtil.createHeroHeadIconById(pTurnId)
	dialogInfo.dialog:addChild(turnIcon)
	turnIcon:setAnchorPoint(ccp(0.5, 0.5))
	turnIcon:setPosition(ccp(dialogInfo.size.width * 0.5, dialogInfo.size.height - 90))

	local nameStr = HeroTurnedData.getTurnedNameById(pTurnId)
	local turnNameLabel = CCRenderLabel:create(nameStr, g_sFontPangWa, 21, 1, ccc3( 0x00, 0x00, 0x00), type_stroke)
	turnIcon:addChild(turnNameLabel)
	turnNameLabel:setAnchorPoint(ccp(0.5, 0.5))
	turnNameLabel:setPosition(ccpsprite(0.5, -0.2, turnIcon))
	turnNameLabel:setColor(ccc3(0xff, 0xf6, 0x00))

	local tipBg = CCScale9Sprite:create("images/common/s9_1.png")
	dialogInfo.dialog:addChild(tipBg)
	tipBg:setPreferredSize(CCSizeMake(438, 127))
	tipBg:setAnchorPoint(ccp(0.5, 0))
	tipBg:setPosition(ccp(dialogInfo.size.width * 0.5, 37))

	local textTab = nil
	if (pTurnId > 0 and pTurnId < 10000) then
		-- 稀有
		local access = HeroTurnedData.getHeroTurnAccessById(pTurnId)
		textTab = 
		{
			{
				text = GetLocalizeStringBy("lgx_1130"), -- 文本内容
			},
			{
				text = "【" .. access .. "】",
				color = ccc3(0x00, 0x6d, 0x2f)
			},
			{
				text = GetLocalizeStringBy("key_1984")
			}
		}
	elseif  (pTurnId > 10000) then
		-- 经典
		local noteStr = HeroTurnedData.getTurnUnlockNoteStr(pTurnId,false)
		textTab = 
		{
			{
				text = noteStr,
			}
		}
	end

	local textInfo = {
		width = 390, 		-- 宽度
		alignment = 2, 		-- 对齐方式  1 左对齐，2 居中， 3右对齐
		labelDefaultFont = g_sFontPangWa,      			-- 默认字体
		labelDefaultColor = ccc3(0x78, 0x25, 0x00),  	-- 默认字体颜色
		labelDefaultSize = 21,          				-- 默认字体大小
		defaultType = "CCLabelTTF",
		elements = textTab
	}
 	local tipLabel = LuaCCLabel.createRichLabel(textInfo)
 	tipBg:addChild(tipLabel)
 	tipLabel:setAnchorPoint(ccp(0.5, 0.5))
 	tipLabel:setPosition(ccpsprite(0.5, 0.5, tipBg))

	return _dialog
end

--[[
	@desc 	: 显示界面方法
	@param 	: pTurnId 幻化形象id
	@param 	: pTouchPriority 触摸优先级
	@param 	: pZorder 显示层级
	@return : 
--]]
function showDialog( pTurnId, pTouchPriority, pZorder )
	if (pTurnId == nil or tonumber(pTurnId) <= 0) then
		return
	end

	local dialog = createDialog(pTurnId, pTouchPriority, pZorder)
	local scene = CCDirector:sharedDirector():getRunningScene()
	scene:addChild(dialog,_zOrder)
end

