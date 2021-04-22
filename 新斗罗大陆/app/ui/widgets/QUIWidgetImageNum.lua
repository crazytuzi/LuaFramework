-- @Author: xurui
-- @Date:   2019-11-01 19:33:32
-- @Last Modified by:   xurui
-- @Last Modified time: 2019-11-02 14:59:03
local QUIWidgetImageNum = class("QUIWidgetImageNum", function(layer)
    -- body
    return CCNode:create()
    
end)

local QNavigationController = import("...controllers.QNavigationController")
local QStaticDatabase = import("...controllers.QStaticDatabase")
local QUIViewController = import("..QUIViewController")

function QUIWidgetImageNum:ctor(options)
	self._totalNumWidth = 0 
	self._totalNumHeight = 0

	self._oldValue = 0
end

function QUIWidgetImageNum:onEnter()
end

function QUIWidgetImageNum:onExit()
end

function QUIWidgetImageNum:setString(value, numResName, gap)
	if value == nil then
		return 
	end

	if value == self._oldValue then
		return
	end
	self._totalNumWidth = 0 
	self._totalNumHeight = 0
	self:removeAllChildren()
	self._oldValue = value

	if numResName == nil then
		numResName = "activity_num"
	end

	if gap == nil then 
		gap = 0
	end

    local forceStr = tostring(value)
    local strLen = string.len(forceStr)
    local paths = QResPath(numResName)
    for i = 1, strLen, 1 do
        local num = string.sub(forceStr, i, i)
        if num == "0" then num = 10 end 
        if string.byte(num) == 46 then num = 11 end   -- 点号
        if paths[tonumber(num)] ~= nil then
	        local spNum = CCSprite:create(paths[tonumber(num)])
	        self:addChild(spNum)
	        local width = spNum:getContentSize().width
	        local height = spNum:getContentSize().height
	        if self._totalNumHeight < height then
	        	self._totalNumHeight = height
	        end

	        spNum:setPosition(self._totalNumWidth + width/2 + gap, 0)
	        self._totalNumWidth = self._totalNumWidth + width
	    end
    end

    self:setPositionX(-self._totalNumWidth/2)
end

function QUIWidgetImageNum:getContentSize()
	return CCSize(self._totalNumWidth, self._totalNumHeight)
end

return QUIWidgetImageNum
