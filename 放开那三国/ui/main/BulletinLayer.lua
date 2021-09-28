-- Filename: BulletinLayer.lua
-- Author: fang
-- Date: 2013-07-03
-- Purpose: 该文件用于: 01, 通告栏


module ("BulletinLayer", package.seeall)
require "script/ui/main/BulletinData"

local IMG_PATH = "images/main/"		-- 主城场景公告图片路径
local _bulletin_layer = nil
local _size = {width=0, height=0}
local _bg = nil
local _scrollview



-- 创建跑马灯式通知显示方式
local function create_marquee()
	if (_scrollview ~= nil) then
		local children = _scrollview:getChildren()
		for i = 1, children:count() do
			local child = tolua.cast(children:objectAtIndex(i-1), "CCNode")
			child:removeChildByTag(9876, true)
		end
	else
		_scrollview = CCScrollView:create()
	end
	_scrollview:setPosition(ccp(14, 7))
	_scrollview:setViewSize(CCSizeMake(612, 20))

	-- added by zhz
	-- local label =   CCLabelTTF:create(GetLocalizeStringBy("key_2127")  , g_sFontName, 18)
	local label =   BulletinData.getBulletNode() 
	label:setPosition(_scrollview:getContentSize().width/g_fScaleX, 0)
	
	_scrollview:addChild(label, 1, 9876)

	local array = CCArray:create()
	local callfunc = CCCallFunc:create(create_marquee)
	local move = CCMoveTo:create(15, ccp(0-label:getContentSize().width, 0))
	array:addObject(move)
	array:addObject(callfunc)
	array:addObject(CCDelayTime:create(1.5))
	local action = CCSequence:create(array)
	label:runAction(action)

	-- 屏蔽touch事件  add by licong 2013.10.23
 	_scrollview:setTouchEnabled(false)

	return _scrollview
end

-- 创建公告层内容
function create()
	if _bulletin_layer ~= nil then
		return _bulletin_layer
	end
	--通知Platform层用户进入游戏大厅
	Platform.sendInformationToPlatform(Platform.kEnterTheGameHall)

	_bulletin_layer = CCLayer:create()
	_bg = CCSprite:create(IMG_PATH .. "bulletin_bg.png")
	_size = _bg:getContentSize()
	_bulletin_layer:setContentSize(_size)
    _bulletin_layer:addChild(_bg)
 	local scrollView = create_marquee()
 	_bulletin_layer:addChild(scrollView)

 	_bulletin_layer:setScale(g_fScaleX)
 	_bulletin_layer:setPosition(0, g_winSize.height-_size.height*g_fScaleX)

    return _bulletin_layer
end
-- 显示公告层
local function show()
	if _bulletin_layer == nil then
		create()
	end
	_bulletin_layer:setVisible(true)
end
-- 隐藏公告层
local function hide()
	if (_bulletin_layer ~= nil) then
		_bulletin_layer:setVisible(false)
	end
end
-- 设置公告层显示与否
function setVisible(visible)
	if (type(visible) ~= type(true)) then
		CCLuaLog ("BulletinLayer.setVisible needs a parameter.")
		return
	end
	if (visible == true) then
		show()
	else
		hide()
	end
end
-- 获取公告层高
function getLayerHeight( ... )
	return _size.height
end
-- 获取公告层宽
function getLayerWidth( ... )
	return _size.width
end

--得到实际显示大小
function getLayerFactSize( ... )
	local size = CCSizeMake(_bg:getContentSize().width * g_fScaleX, _bg:getContentSize().height * g_fScaleX)
	return size
end

function getLayerContentSize()
	return _size
end

function getBg()
	if (_bg == nil) then
		create()
	end
	return _bulletin_layer
end

function getLayer()
	if (_bulletin_layer == nil) then
		create()
	end
	return _bulletin_layer
end

function release( ... )
	-- body
end

