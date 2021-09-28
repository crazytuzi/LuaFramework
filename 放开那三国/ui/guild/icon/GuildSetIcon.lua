-- Filename: GuildSetIcon.lua
-- Author: bzx
-- Date: 2015-1-14
-- Purpose: 设置军团军旗

module("GuildSetIcon", package.seeall)

require "script/libs/LuaCCSprite"
require "script/ui/guild/icon/GuildIconData"
require "script/ui/guild/GuildUtil"
require "script/ui/guild/icon/GuildIconService"
require "script/ui/tip/SingleTip"

local _layer 				-- 本层主Layer
local _touchPriority 		-- 本层触摸优先级
local _zOrder 				-- 本层z轴
local _dialogBg				-- 对话框的背景
local _selectedTagSprite   	-- 被选择的标记
local _selectedId 			-- 被选择的军旗的Id
local _selectedIcon 		-- 被选择的军旗

--[[
	@desc: 		显示本层
	@return: 	nil
--]]
function show(p_touchPriority, p_zOrder)
	_layer = create(p_touchPriority, p_zOrder)
	CCDirector:sharedDirector():getRunningScene():addChild(_layer, _zOrder)
end

function init( ... )
	_layer 				= nil
	_touchPriority 		= 0
	_zOrder 			= 0
	_dialogBg 			= nil
	_selectedTagSprite 	= nil
	_selectedId 		= 0
	_selectedIcon 		= nil
end

function initData( p_touchPriority, p_zOrder )
	_touchPriority = p_touchPriority or -200
	_zOrder = p_zOrder or 200
end

--[[
	@desc: 		创建本层
	@return:	CCLayer
--]]
function create( p_touchPriority, p_zOrder )
	init()
	initData(p_touchPriority, p_zOrder)
	local dialogInfo = {
		title = "军团军旗",
		callbackClose = nil,
		size = CCSizeMake(615, 595),
		priority = _touchPriority,
		swallowTouch = true,
		-- LuaCCSprite.createDialog_1(dialogInfo)执行后，dialog为对话框
		dialog = nil		
	}
	_layer = LuaCCSprite.createDialog_1(dialogInfo)
	local tip = CCLabelTTF:create("军团等级越高，可装备的军旗越多", g_sFontPangWa, 25)
	_dialogBg = dialogInfo.dialog
	_dialogBg:addChild(tip)
	tip:setAnchorPoint(ccp(0.5, 0.5))
	tip:setPosition(ccp(_dialogBg:getContentSize().width * 0.5, 60))
	tip:setColor(ccc3(0x78, 0x25, 0x00))
	loadTableView()
	return _layer
end

--[[
	@desc: 		显示TableView
	@return:	nil
--]]
-- 加载头像
function loadTableView()
    local fullRect = CCRectMake(0,0,75, 75)
	local insetRect = CCRectMake(30,30,15,15)
	local tableViewBg = CCScale9Sprite:create("images/common/bg/bg_ng_attr.png", fullRect, insetRect)
	tableViewBg:setPreferredSize(CCSizeMake(512, 400))
    _dialogBg:addChild(tableViewBg)
    tableViewBg:setAnchorPoint(ccp(0.5, 1))
	tableViewBg:setPosition(ccp(_dialogBg:getContentSize().width * 0.5, _dialogBg:getContentSize().height - 100))
    
    local cellIconCount = 4
	local cellSize = CCSizeMake(479, 125)
	local h = LuaEventHandler:create(function(p_functionName, p_tableView, p_index,p_cell)
		if p_functionName == "cellSize" then
			return cellSize
		elseif p_functionName == "cellAtIndex" then
			local cell = CCTableViewCell:create()
			local start = p_index * cellIconCount
			local iconCount = GuildIconData.getIconCount()
			for i=1, 4 do
                local index = start + i
				if index <= iconCount then
                    local iconId = index
					local iconSprite = createGuildIcon(iconId, callbackSelected, _touchPriority - 1)
					cell:addChild(iconSprite)
		            iconSprite:setAnchorPoint(ccp(0.5, 0.5))
		            iconSprite:setPosition(ccp(cellSize.width / cellIconCount * 0.5 + (i - 1) * cellSize.width / cellIconCount, cellSize.height * 0.5))
                    if iconId == GuildDataCache.getGuildIconId() then
                        addSelectedIcon(iconSprite)
                    end
                end
			end
			return cell
		elseif p_functionName == "numberOfCells" then
			local count = GuildIconData.getIconCount()
			return math.ceil(count / cellIconCount )
		elseif p_functionName == "cellTouched" then
		elseif p_functionName == "scroll" then
		end
	end)
	local iconTableView = LuaTableView:createWithHandler(h, CCSizeMake(479, 370))
	tableViewBg:addChild(iconTableView)
    iconTableView:ignoreAnchorPointForPosition(false)
    iconTableView:setAnchorPoint(ccp(0.5, 1))
	iconTableView:setBounceable(true)
	iconTableView:setPosition(ccp(tableViewBg:getContentSize().width * 0.5, tableViewBg:getContentSize().height - 15))
	iconTableView:setVerticalFillOrder(kCCTableViewFillTopDown)
    iconTableView:setTouchPriority(_touchPriority - 2)
end

function callbackSelected(p_tag, p_guidIconItem)
    require "script/audio/AudioUtil"
	AudioUtil.playEffect("audio/effect/zhujiemian.mp3")
    _selectedId = p_tag
    local legionIconDb = DB_Legion_icon.getDataById(_selectedId)
	local guildLevel = GuildDataCache.getGuildHallLevel()
	if guildLevel < legionIconDb.needlegionlv then
		SingleTip.showTip(string.format("需要军团等级达到%d等级可以装备", legionIconDb.needlegionlv))
		return
	end
    _selectedIcon = p_guidIconItem
    GuildIconService.guildModifyIcon(handleModifyIcon, {_selectedId})
end

function handleModifyIcon( ... )
	GuildDataCache.setGuildIconId(_selectedId)
	addSelectedIcon(_selectedIcon)
end

-- 为头像添加被选择的标记
function addSelectedIcon(p_guildIcon)
    if _selectedTagSprite == nil then
        _selectedTagSprite = CCSprite:create("images/common/checked.png")
        _selectedTagSprite:setAnchorPoint(ccp(0.5, 0.5))
        _selectedTagSprite:retain()
    else
    	_selectedTagSprite:retain()
        _selectedTagSprite:removeFromParentAndCleanup(true)
    end
    p_guildIcon:addChild(_selectedTagSprite)
    _selectedTagSprite:release()
    _selectedTagSprite:setPosition(ccp(p_guildIcon:getContentSize().width * 0.5, p_guildIcon:getContentSize().height * 0.5))
end

--[[
	@desc: 		创建军团军旗
	@return:	BTSensitiveMenu
--]]
function createGuildIcon(p_iconId, p_callback, p_touchPriority)
	local icon = CCSprite:create() 
	-- 按钮Bar
	local menuBar = BTSensitiveMenu:create()
	icon:addChild(menuBar)
	menuBar:setPosition(ccp(0, 0))
    if p_touchPriority ~= nil then
        menuBar:setTouchPriority(p_touchPriority)
    end
	
	local guildIcon = GuildUtil.getGuildIcon(p_iconId)
	menuBar:setContentSize(guildIcon:getContentSize())
	icon:setContentSize(guildIcon:getContentSize())
	-- 按钮
	local item = CCMenuItemSprite:create(guildIcon, guildIcon)
	menuBar:addChild(item, 1, p_iconId)
	item:registerScriptTapHandler(p_callback)
	item:setAnchorPoint(ccp(0.5, 0.5))
	item:setPosition(ccpsprite(0.5, 0.5, menuBar))

	local legionIconDb = DB_Legion_icon.getDataById(p_iconId)
	-- 等级
	local levelLabel = CCRenderLabel:create(string.format("Lv.%d", legionIconDb.needlegionlv), g_sFontPangWa, 18, 1, ccc3( 0x00, 0x00, 0x00), type_stroke)
   	item:addChild(levelLabel)
    levelLabel:setAnchorPoint(ccp(0, 0))
    levelLabel:setPosition(ccp(0, 0))
    
    local guildLevel = GuildDataCache.getGuildHallLevel()
	-- 等级不满足条件是为红色,否则为黄色
	if guildLevel < legionIconDb.needlegionlv then
		levelLabel:setColor(ccc3(0xff, 0x00, 0x00))
	else
		levelLabel:setColor(ccc3(0xfe, 0xdb, 0x1c))
	end
	return icon
end