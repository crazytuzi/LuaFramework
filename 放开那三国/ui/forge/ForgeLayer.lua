-- FileName: ForgeLayer.lua 
-- Author: licong 
-- Date: 14-6-12 
-- Purpose: 橙装锻造主界面


module("ForgeLayer", package.seeall)

require "script/ui/forge/ForgeViewLayer"

local _bgLayer 				= nil
local _layerSize 			= nil
local _btnFrameSp 			= nil
local _pubButton 			= nil
local _propButton 			= nil
local _curButton 			= nil
local _curDisplayLayer 		= nil
local _staminaLabel 		= nil
local _memoryTreasureType 	= nil

kNormalEquipType 			= 0 -- 非套装
kSpecialEquipType 			= 1 -- 套装

local function init( ... )
	_bgLayer 			= nil
	_layerSize 			= nil
	_btnFrameSp 		= nil
	_curButton			= nil
	_curDisplayLayer	= nil
	_staminaLabel 		= nil
end


----------------------------[[ ui创建 ]]----------------------------------

--[[
	@des:	创建分页按钮
]]
local function createMenu( )
	
	local fullRect = CCRectMake(0,0,58,99)
	local insetRect = CCRectMake(20,20,18,59)
	--按钮背景
	_btnFrameSp = CCScale9Sprite:create("images/common/menubg.png", fullRect, insetRect)
	_btnFrameSp:setPreferredSize(CCSizeMake(640, 100))
	_btnFrameSp:setAnchorPoint(ccp(0.5, 1))
	_btnFrameSp:setPosition(ccp(_bgLayer:getContentSize().width/2 , _bgLayer:getContentSize().height ))
	_btnFrameSp:setScale(g_fScaleX/MainScene.elementScale)
	_bgLayer:addChild(_btnFrameSp, 10)

	local shopMenuBar = CCMenu:create()
	shopMenuBar:setPosition(ccp(0, 0))
	_btnFrameSp:addChild(shopMenuBar, 10)
	-- 普通橙装
	_pubButton = LuaMenuItem.createMenuItemSprite(GetLocalizeStringBy("lic_1056"), 30)
	_pubButton:setAnchorPoint(ccp(0, 0))
	_pubButton:setPosition(ccp(_btnFrameSp:getContentSize().width*0, _btnFrameSp:getContentSize().height*0.1))
	_pubButton:registerScriptTapHandler(tabMenuCallFunc)
	shopMenuBar:addChild(_pubButton, 1, kNormalEquipType)

	-- 套装橙装
	_propButton = LuaMenuItem.createMenuItemSprite( GetLocalizeStringBy("lic_1057"),30)
	_propButton:setAnchorPoint(ccp(0, 0))
	_propButton:setPosition(ccp(_btnFrameSp:getContentSize().width*0.25, _btnFrameSp:getContentSize().height*0.1))
	_propButton:registerScriptTapHandler(tabMenuCallFunc)
	shopMenuBar:addChild(_propButton, 1, kSpecialEquipType)

	local  menuCloseBar = CCMenu:create()
	menuCloseBar:setTouchPriority(-150)
	menuCloseBar:setPosition(ccp(0,0))
	_btnFrameSp:addChild(menuCloseBar)
	local closeMenuItem = CCMenuItemImage:create("images/common/close_btn_n.png","images/common/close_btn_h.png")
	closeMenuItem:setAnchorPoint(ccp(0, 0))
	closeMenuItem:registerScriptTapHandler(closeLayerCallFunc)
	closeMenuItem:setAnchorPoint(ccp(1,0.5))
	closeMenuItem:setPosition(ccp(_btnFrameSp:getContentSize().width-20,_btnFrameSp:getContentSize().height*0.5+6))
	menuCloseBar:addChild(closeMenuItem)

	-- 铸造帮助按钮添加
	-- local helpMenuItem = CCMenuItemImage:create("images/forge/help_n.png","images/forge/help_h.png")
	-- helpMenuItem:setAnchorPoint(ccp(0, 0))
	-- helpMenuItem:registerScriptTapHandler(helpButtonCallback)
	-- helpMenuItem:setAnchorPoint(ccp(1,0.5))
	-- helpMenuItem:setPosition(ccp(_btnFrameSp:getContentSize().width-160,_btnFrameSp:getContentSize().height*0.5+6))
	-- menuCloseBar:addChild(helpMenuItem)

	--计算层大小
	local t_layerSize = CCSizeMake(_layerSize.width, _bgLayer:getContentSize().height-_btnFrameSp:getContentSize().height * g_fScaleX)
	if(_memoryTreasureType == kNormalEquipType or _memoryTreasureType == nil) then
		_curButton = _pubButton
		_curButton:selected()
		_memoryTreasureType = kNormalEquipType
		_curDisplayLayer = ForgeViewLayer.createForgeViewLayer(kNormalEquipType, t_layerSize)
	elseif(_memoryTreasureType == kSpecialEquipType) then
		_curButton = _propButton
		_curButton:selected()
		_curDisplayLayer = ForgeViewLayer.createForgeViewLayer(kSpecialEquipType, t_layerSize)
	end
	_bgLayer:addChild(_curDisplayLayer)
end 

--[[
	@des 		:主创建方法，创建整个碎片界面
	@return		:CCLayer
]]
function createForgeLayer()
	init()
	_bgLayer = MainScene.createBaseLayer("images/forge/background.jpg",true,false,true)
	_layerSize = _bgLayer:getContentSize()
	print("_bgLayer size:",_layerSize.width, _layerSize.height)
	print("_bgLayer scale", _bgLayer:getScale())
	-- 创建标签
	createMenu()
	return _bgLayer
end

----------------------------[[ 回调事件 ]]----------------------------------
--[[
	@des 		:分页按钮回调处理
]]
function tabMenuCallFunc( tag, itemBtn )
	itemBtn:selected()
	require "script/audio/AudioUtil"
	AudioUtil.playEffect("audio/effect/changtiaoxing.mp3")
	if (_curButton ~= itemBtn) then
		_curButton:unselected()
		_curButton = itemBtn
		_curButton:selected()
		if(_curDisplayLayer) then
			_curDisplayLayer:removeFromParentAndCleanup(true)
			_curDisplayLayer=nil
		end
		--计算层大小
		local t_layerSize = CCSizeMake(_layerSize.width, _bgLayer:getContentSize().height-_btnFrameSp:getContentSize().height * g_fScaleX)
		print("t_layerSize", t_layerSize)
		print("t_layerSize ", t_layerSize.width, t_layerSize.height)
		if(tag == kNormalEquipType) then
			_memoryTreasureType = kNormalEquipType
			_curDisplayLayer = ForgeViewLayer.createForgeViewLayer(kNormalEquipType, t_layerSize)
		elseif(tag == kSpecialEquipType) then
			_memoryTreasureType = kSpecialEquipType
			_curDisplayLayer = ForgeViewLayer.createForgeViewLayer(kSpecialEquipType, t_layerSize)
		end
		_bgLayer:addChild(_curDisplayLayer)
	end
end


--[[
	@des 		:关闭按钮事件
]]
function closeLayerCallFunc( ... )
	require "script/ui/forge/FindTreasureLayer"
    FindTreasureLayer.show()
end

--[[
	@des:	铸造帮助按钮回调事件
]]
function helpButtonCallback( sender,tag )


end

































































































