-- FileName: NewForgeLayer.lua 
-- Author: licong 
-- Date: 15/7/20 
-- Purpose: 橙装铸造主界面

module("NewForgeLayer", package.seeall)

require "script/ui/forge/NewForgeViewLayer"

local _bgLayer 				= nil
local _bgSprite 			= nil
local _bulletSize 			= nil
local _btnFrameSp 			= nil
local _layerSize 			= nil
local _pubButton 			= nil
local _propButton 			= nil
local _curButton 			= nil
local _curDisplayLayer 		= nil
local _staminaLabel 		= nil
local _redPubButton			= nil
local _redPropButton  		= nil

local _memoryTreasureType 	= nil


kNormalEquipType 			= 0 -- 非套装
kSpecialEquipType 			= 1 -- 套装
kRedNormalEquipType 		= 3 -- 非套装
kRedSpecialEquipType 		= 4 -- 套装

local function init( ... )
	_bgLayer 				= nil
	_bgSprite 				= nil
	_bulletSize 			= nil
	_btnFrameSp 			= nil
	_layerSize 				= nil
	_curButton				= nil
	_curDisplayLayer		= nil
	_staminaLabel 			= nil
	_redPubButton			= nil
	_redPropButton  		= nil

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
		
		if(tag == kNormalEquipType) then
			_memoryTreasureType = kNormalEquipType
			_curDisplayLayer = NewForgeViewLayer.createLayer(kNormalEquipType, _layerSize)
		elseif(tag == kSpecialEquipType) then
			_memoryTreasureType = kSpecialEquipType
			_curDisplayLayer = NewForgeViewLayer.createLayer(kSpecialEquipType, _layerSize)
		elseif(tag == kRedNormalEquipType ) then 
			_memoryTreasureType = kRedNormalEquipType
			_curDisplayLayer = NewForgeViewLayer.createLayer(kRedNormalEquipType, _layerSize)
		elseif(tag == kRedSpecialEquipType) then 
			_memoryTreasureType = kRedSpecialEquipType
			_curDisplayLayer = NewForgeViewLayer.createLayer(kRedSpecialEquipType, _layerSize)
		else
		end

		_curDisplayLayer:setPosition(ccp(0,MenuLayer.getHeight()))
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


------------------------------------------------------ UI创建 ---------------------------------------------------------------------------
--[[
	@des:	创建分页按钮
]]
function createMenu( )
	
	local fullRect = CCRectMake(0,0,58,99)
	local insetRect = CCRectMake(20,20,18,59)
	--按钮背景
	_btnFrameSp = CCScale9Sprite:create("images/common/menubg.png", fullRect, insetRect)
	_btnFrameSp:setPreferredSize(CCSizeMake(640, 100))
	_btnFrameSp:setAnchorPoint(ccp(0.5, 1))
	_btnFrameSp:setPosition(ccp(_bgLayer:getContentSize().width/2 , _bgLayer:getContentSize().height - _bulletSize.height*g_fScaleX ))
	_bgLayer:addChild(_btnFrameSp, 10)
	_btnFrameSp:setScale(g_fScaleX)

	local menuBar = CCMenu:create()
	menuBar:setPosition(ccp(0, 0))
	_btnFrameSp:addChild(menuBar, 10)
	-- 普通橙装
	_pubButton = LuaMenuItem.createMenuItemSprite(GetLocalizeStringBy("lic_1056"), 28,25,nil,nil,CCSizeMake(163,66))
	_pubButton:setAnchorPoint(ccp(0, 0))
	_pubButton:setPosition(ccp(_btnFrameSp:getContentSize().width*0, _btnFrameSp:getContentSize().height*0.1))
	_pubButton:registerScriptTapHandler(tabMenuCallFunc)
	menuBar:addChild(_pubButton, 1, kNormalEquipType)
	_pubButton:setScale(0.8)

	-- 套装橙装
	_propButton = LuaMenuItem.createMenuItemSprite( GetLocalizeStringBy("lic_1057"),28,25,nil,nil,CCSizeMake(163,66))
	_propButton:setAnchorPoint(ccp(0, 0))
	_propButton:setPosition(ccp(_btnFrameSp:getContentSize().width*0.21, _btnFrameSp:getContentSize().height*0.1))
	_propButton:registerScriptTapHandler(tabMenuCallFunc)
	menuBar:addChild(_propButton, 1, kSpecialEquipType)
	_propButton:setScale(0.8)

	-- 普通红装
	_redPubButton = LuaMenuItem.createMenuItemSprite(GetLocalizeStringBy("lic_1740"), 28,25,nil,nil,CCSizeMake(163,66))
	_redPubButton:setAnchorPoint(ccp(0, 0))
	_redPubButton:setPosition(ccp(_btnFrameSp:getContentSize().width*0.42, _btnFrameSp:getContentSize().height*0.1))
	_redPubButton:registerScriptTapHandler(tabMenuCallFunc)
	menuBar:addChild(_redPubButton, 1, kRedNormalEquipType)
	_redPubButton:setScale(0.8)
	if not DataCache.getSwitchNodeState(ksSwitchRedEquip, false) then
		_redPubButton:setVisible(false)
	end

	-- 套装红装
	_redPropButton = LuaMenuItem.createMenuItemSprite( GetLocalizeStringBy("lic_1741"),28,25,nil,nil,CCSizeMake(163,66))
	_redPropButton:setAnchorPoint(ccp(0, 0))
	_redPropButton:setPosition(ccp(_btnFrameSp:getContentSize().width*0.63, _btnFrameSp:getContentSize().height*0.1))
	_redPropButton:registerScriptTapHandler(tabMenuCallFunc)
	menuBar:addChild(_redPropButton, 1, kRedSpecialEquipType)
	_redPropButton:setScale(0.8)
	if not DataCache.getSwitchNodeState(ksSwitchRedEquip, false) then
		_redPropButton:setVisible(false)
	end
	
	-- 关闭按钮
	local closeMenuItem = CCMenuItemImage:create("images/common/close_btn_n.png","images/common/close_btn_h.png")
	closeMenuItem:setAnchorPoint(ccp(0, 0))
	closeMenuItem:registerScriptTapHandler(closeLayerCallFunc)
	closeMenuItem:setAnchorPoint(ccp(1,0.5))
	closeMenuItem:setPosition(ccp(_btnFrameSp:getContentSize().width-10,_btnFrameSp:getContentSize().height*0.5+6))
	menuBar:addChild(closeMenuItem)

	--计算显示layer大小
	local curDisplayLayerHight = _bgLayer:getContentSize().height-_bulletSize.height*g_fScaleX-_btnFrameSp:getContentSize().height*g_fScaleX-MenuLayer.getHeight()
	_layerSize = CCSizeMake(_bgLayer:getContentSize().width, curDisplayLayerHight)

	if(_memoryTreasureType == kNormalEquipType or _memoryTreasureType == nil) then
		_curButton = _pubButton
		_curButton:selected()
		_memoryTreasureType = kNormalEquipType
		_curDisplayLayer = NewForgeViewLayer.createLayer(kNormalEquipType, _layerSize)
	elseif(_memoryTreasureType == kSpecialEquipType) then
		_curButton = _propButton
		_curButton:selected()
		_curDisplayLayer = NewForgeViewLayer.createLayer(kSpecialEquipType, _layerSize)
	elseif(_memoryTreasureType == kRedNormalEquipType ) then 
		_curButton = _redPubButton
		_curButton:selected()
		_curDisplayLayer = NewForgeViewLayer.createLayer(kRedNormalEquipType, _layerSize)
	elseif(_memoryTreasureType == kRedSpecialEquipType) then 
		_curButton = _redPropButton
		_curButton:selected()
		_curDisplayLayer = NewForgeViewLayer.createLayer(kRedSpecialEquipType, _layerSize)
	else
	end
	_curDisplayLayer:setPosition(ccp(0,MenuLayer.getHeight()))
	_bgLayer:addChild(_curDisplayLayer)
end 

--[[
	@des 	: 创建界面
	@param 	: 
	@return : 
--]]
function createLayer( ... )
	init()

	-- 按钮显示
	MainScene.setMainSceneViewsVisible(true,false,true)

	-- 公告栏大小
	require "script/ui/main/BulletinLayer"
    _bulletSize = BulletinLayer.getLayerContentSize()

	_bgLayer = CCLayer:create()

	-- 大背景
    _bgSprite = CCSprite:create("images/forge/background.jpg")
    _bgSprite:setAnchorPoint(ccp(0.5,0.5))
    _bgSprite:setPosition(ccp(_bgLayer:getContentSize().width*0.5,_bgLayer:getContentSize().height*0.5))
    _bgLayer:addChild(_bgSprite)
    _bgSprite:setScale(g_fBgScaleRatio)

	-- 创建标签
	createMenu()

	return _bgLayer
end

--[[
	@des 	: 显示主界面
	@param 	: 
	@return : 
--]]
function showLayer( ... )
	local layer = createLayer()
	MainScene.changeLayer(layer, "NewForgeLayer")
end


































































































































