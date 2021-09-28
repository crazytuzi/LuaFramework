-- Filename: MainMenuLayer.lua.
-- Author: fang.
-- Date: 2013-05-23
-- Purpose: 该文件用于实现主菜单模块

module ("MainMenuLayer", package.seeall)

require "script/ui/main/MainItemFactory"

local _bgLayer         = nil
local _topButtonSprite = nil
local _middleButtonSprite = nil


function init()
	_bgLayer = nil
	_topButtonSprite = nil
	_middleButtonSprite = nil
end

function show()
	local layer = createLayer()
	MainScene.changeLayer(layer, "MainMenuLayer")
end

function createLayer()
	_bgLayer = CCLayer:create()
	createTopButton()
	_topButtonSprite:setPosition(ccp(0.5*g_winSize.width, g_winSize.height-avatarHeight))
	_topButtonSprite:setAnchorPoint(ccp(0.5, 1))
	_bgLayer:addChild(_topButtonSprite)
	_topButtonSprite:setScale(MainScene.elementScale)
	createBottomButton()
	return _bgLayer
end



--[[
	@des:创建上部按钮
--]]
function createTopButton()
	
	local avatarHeight = MainScene.getAvatarLayerFactSize().height
	_topButtonSprite = CCSprite:create()
	_topButtonSprite:setContentSize(CCSizeMake(640, 960))

	local btnCreateArray = MainItemFactory.getButtonCreateArray()
	local btnKeyArray = MainItemFactory.getTopBtnAarray()

	local row = 5 --每行有几个按钮
	local mh  = 120 -- 每行直接的间距
	local bgSize = _topButtonSprite:getContentSize()
	local sx = bgSize.width - (bgSize.width/row/2)
	local sy = bgSize.height - mh/2 - 20
	local tw = bgSize.width/row

	local num = 1
	for i,v in ipairs(btnKeyArray) do
		local btn = btnCreateArray[v].createButton()
		if btnCreateArray[v].isShow() then
			local x = sx - ((num-1)%5)*tw
			local y = sy - math.floor((num-1)/5)*mh
			btn:setAnchorPoint(ccp(0.5, 0.5))
			btn:setPosition(x, y)
			local zOrder = btnCreateArray[v].zOrder or 1
			_topButtonSprite:addChild(btn, zOrder)
			num = num + 1
		end
	end
	return _topButtonSprite
end

--[[
	@des:创建上部按钮
--]]
function createMiddleButton()
	local avatarHeight = MainScene.getAvatarLayerFactSize().height
	_middleButtonSprite = CCSprite:create()
	local btnCreateArray = MainItemFactory.getButtonCreateArray()
	local btnKeyArray = MainItemFactory.getMiddleBtnArray()
	local tw = 68

	local showNum = 1
	local btnArray = {}
	for i,v in ipairs(btnKeyArray) do
		local btn = btnCreateArray[v].createButton()
		if btnCreateArray[v].isShow() then
			local zOrder = btnCreateArray[v].zOrder or 1
			_middleButtonSprite:addChild(btn, zOrder)
			table.insert(btnArray, btn)
			showNum = showNum + 1
		end
	end
	_middleButtonSprite:setContentSize(CCSizeMake(showNum*tw, 50))

    local num = 1
	for i,v in ipairs(btnArray) do
		local x = ((num-1)%(#btnArray))*90
		local y = _middleButtonSprite:getContentSize().height/2
		v:setAnchorPoint(ccp(0.5, 0.5))
		v:setPosition(x, y)
		num = num + 1
	end
	return _middleButtonSprite
end


--[[
	@des:创建底部按钮
	@parm:void 
	@ret:void
--]]
function createBottomButton()
	local btnCreateArray = MainItemFactory.getButtonCreateArray()
	local btnPos = MainItemFactory.getBottomBtnPos()

	local bottomSprite = CCSprite:create()
	bottomSprite:setContentSize(CCSizeMake(640, 312))
	bottomSprite:setPosition(ccp(0.5*g_winSize.width, MenuLayer.getHeight()))
	bottomSprite:setAnchorPoint(ccp(0.5, 0))
	_bgLayer:addChild(bottomSprite)
	bottomSprite:setScale(MainScene.elementScale)

	for k,v in pairs(btnPos) do
		local btn = btnCreateArray[k].createButton()
		btn:setPosition(v)
		local zOrder = btnCreateArray[k].zOrder or 1
		bottomSprite:addChild(btn, zOrder)
	end
end

--[[
	@des:更新顶部按钮显示
--]]
function updateTopButton( ... )
	if tolua.isnull(_topButtonSprite) then
		return
	end
	local parentNode = _topButtonSprite:getParent()
	local x, y = _topButtonSprite:getPosition()
	local oldPos = ccp(x, y)
	local anchor = _topButtonSprite:getAnchorPoint()
	if _topButtonSprite then
		_topButtonSprite:removeFromParentAndCleanup(true)
		_topButtonSprite = nil
	end
	createTopButton()
	parentNode:addChild(_topButtonSprite)
	_topButtonSprite:setPosition(oldPos)
	_topButtonSprite:setAnchorPoint(anchor)
end

--[[
	@des:更新中部按钮
--]]
function updateMiddleButton( ... )
	if tolua.isnull(_middleButtonSprite) then
		return
	end
	local parentNode = _middleButtonSprite:getParent()
	local x, y = _middleButtonSprite:getPosition()
	local oldPos = ccp(x, y)
	local anchor = _middleButtonSprite:getAnchorPoint()
	if _middleButtonSprite then
		_middleButtonSprite:removeFromParentAndCleanup(true)
		_middleButtonSprite = nil
	end
	createMiddleButton()
	parentNode:addChild(_middleButtonSprite)
	_middleButtonSprite:setPosition(oldPos)
	_middleButtonSprite:setAnchorPoint(anchor)

end
