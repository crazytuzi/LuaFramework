local QAssistOutPanel = class("QAssistOutPanel", function()
		return CCNode:create()
	end)
local QScrollContain = import("....ui.QScrollContain")

function QAssistOutPanel:ctor(options)

	self._count = 1
    self._line = 1
    self._maxCount = 300
	self._log = ""
    self._height = display.height - 50

    self._outTF = CCLabelTTF:create("", global.font_default, 16)
    self._outTF:setHorizontalAlignment(kCCTextAlignmentLeft)
    self._outTF:setVerticalAlignment(kCCVerticalTextAlignmentTop)
    self._outTF:setAnchorPoint(0,1)
    self._outTF:setDimensions(CCSize(display.width*0.7, 0))
    -- self:addChild(self._outTF)

    local node = CCNode:create()
    local layer = CCLayerColor:create(ccc4(0, 0, 0, 64), display.width*0.7, self._height)
    layer:setAnchorPoint(0.5, 0.5)
    layer:setPosition(ccp(0, -self._height))
    node:addChild(layer)
    self:addChild(node)
    self._scroll = QScrollContain.new({sheet = node, sheet_layout = layer, direction = QScrollContain.directionY, touchLayerOffsetY = 0})
    self._scroll:setIsCheckAtMove(true)
    self._scroll:addChild(self._outTF)
end

function QAssistOutPanel:setString(str)
	self._log = self._log..self._line..": "..str.."\n"
	self._count = self._count + 1
    self._line = self._line + 1

	self._outTF:setString(self._log)
    local height = self._outTF:getContentSize().height
    self._scroll:setContentSize(0, height)
    self._scroll:moveTo(0, height, false)
    if self._count > self._maxCount then
        local count = self._line - self._maxCount/2
        local pos = string.find(self._log, count..": ")
        if pos ~= nil then
            local len = string.len(self._log)
            self._log = string.sub(self._log, -len+pos)
            self._count = 0
        end
    end
end

function QAssistOutPanel:clearLog()
    self._log = ""
    self._count = 1
    self._line = 1
    self._outTF:setString(self._log)
    self._scroll:moveTo(0, 0, false)
end

return QAssistOutPanel