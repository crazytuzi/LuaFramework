-- Filename：	DressDetInfoDialog.lua
-- Author：		bzx
-- Date：		2014-11-11
-- Purpose：		时装获得途径


module("DressGetInfoDialog", package.seeall)

require "script/libs/LuaCCSprite"
require "script/libs/LuaCCLabel"

local _dialog
local _dressID
local _touchPriority = -500
local _zOder = 5000

function show(dressID, touchPriority, zOder)
	_dialog = create(dressID, touchPriority, zOder)
	CCDirector:sharedDirector():getRunningScene():addChild(_dialog, _zOder)
end

function init(dressID, touchPriority, zOder)
	_dressID = dressID
	_touchPriority = touchPriority or _touchPriority
	_zOder = zOder or _zOder
end

function create(dressID, touchPriority, zOder)
	init(dressID, touchPriority, zOder)
	local dialog_info = {
	    title = GetLocalizeStringBy("key_8348"),
	    callbackClose = nil,
	    size = CCSizeMake(530, 351),
	    priority = _touchPriority,
	    swallowTouch = true,
	    isRunning = nil
	}
	_dialog = LuaCCSprite.createDialog_1(dialog_info)

	local dressIcon = ItemSprite.getItemSpriteByItemId(_dressID)
	dialog_info.dialog:addChild(dressIcon)
	dressIcon:setAnchorPoint(ccp(0.5, 0.5))
	dressIcon:setPosition(ccp(dialog_info.size.width * 0.5, dialog_info.size.height - 90))

	local dressDB = parseDB(DB_Item_dress.getDataById(_dressID))
	local genderId = UserModel.getUserSex()
	local dressName = CCRenderLabel:create(dressDB.name[genderId][2], g_sFontPangWa, 21, 1, ccc3( 0x00, 0x00, 0x00), type_stroke)
	dressIcon:addChild(dressName)
	dressName:setAnchorPoint(ccp(0.5, 0.5))
	dressName:setPosition(ccpsprite(0.5, -0.2, dressIcon))
	dressName:setColor(ccc3(0xff, 0xf6, 0x00))

	local tip_bg = CCScale9Sprite:create("images/common/s9_1.png")
  	dialog_info.dialog:addChild(tip_bg)
  	tip_bg:setPreferredSize(CCSizeMake(438, 127))
  	tip_bg:setAnchorPoint(ccp(0.5, 0))
  	tip_bg:setPosition(ccp(dialog_info.size.width * 0.5, 37))

  	local textInfo = {
        width = 390, -- 宽度
        alignment = 2, -- 对齐方式  1 左对齐，2 居中， 3右对齐
        labelDefaultFont = g_sFontPangWa,      -- 默认字体
        labelDefaultColor = ccc3(0x78, 0x25, 0x00),  -- 默认字体颜色
        labelDefaultSize = 21,          -- 默认字体大小
        defaultType = "CCLabelTTF",
        elements =
        {
            {
                text = GetLocalizeStringBy("key_8349"),                     -- 文本内容
            },
            {
            	text = "【" .. dressDB.dressInf .. "】",
            	color = ccc3(0x00, 0x6d, 0x2f)
        	},
        	{
        		text = GetLocalizeStringBy("key_8350")
        	}
        }
 	}
 	local label = LuaCCLabel.createRichLabel(textInfo)
 	tip_bg:addChild(label)
 	label:setAnchorPoint(ccp(0.5, 0.5))
 	label:setPosition(ccpsprite(0.5, 0.5, tip_bg))
	return _dialog
end

