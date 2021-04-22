local QEEffectBrower = class("QEEffectBrower", function()
    return display.newScene("QEEffectBrower")
end)

function QEEffectBrower:ctor()
    local relativePath = "scripts/app/editor/scenes/QEEffectBrower.lua"
    local currentFilePath = CCFileUtils:sharedFileUtils():fullPathForFilename(relativePath)
    self._effectPath = string.sub(currentFilePath, 1, string.len(currentFilePath) - string.len(relativePath)) .. "res/effect/fca"
    if device.platform == "windows" then
        self._effectPath = string.gsub(self._effectPath, "/", "\\")
    end
    print("[Kumo] effect path = ", self._effectPath)

    -- background
    self:addChild(CCLayerColor:create(ccc4(128, 128, 128, 255), display.width, display.height))

    -- coordinate axis
    self._axisNode = CCNode:create()
    self:addChild(self._axisNode)
    local horizontalLine = CCDrawNode:create()
    horizontalLine:drawLine({-display.cx, 0}, {display.cx, 0})
    self._axisNode:addChild(horizontalLine)
    local verticalLine = CCDrawNode:create()
    verticalLine:drawLine({0, -display.cy}, {0, display.height})
    self._axisNode:addChild(verticalLine)
    self._axisNode:setPosition(display.cx, display.cy)

    self._effectRoot = CCNode:create()
    self:addChild(self._effectRoot)
    self._effectRoot:setPosition(display.cx, display.cy)

    self._uiRoot = CCNode:create()
    self:addChild(self._uiRoot)
    self._uiRoot:setPosition(0, 0)

    self._effectName = ui.newTTFLabel( {
        text = "effect file name",
        font = global.font_monaco,
        size = 20,
        color = display.COLOR_GREEN,
        } )
    self._uiRoot:addChild(self._effectName)
    self._effectName:setPosition(display.cx, 50)

    self._menu = CCMenu:create();
    self:addChild(self._menu)
    self._menu:setPosition(0, 0)

    self._previousButton = ui.newTTFLabelMenuItem( {
        text = "Previous",
        font = global.font_monaco,
        size = 20,
        listener = handler(self, QEEffectBrower.onPreviousClicked),
    } )
    self._menu:addChild(self._previousButton)
    self._previousButton:setPosition(display.cx, 20)

    self._nextButton = ui.newTTFLabelMenuItem( {
        text = "Next",
        font = global.font_monaco,
        size = 20,
        listener = handler(self, QEEffectBrower.onNextClicked),
    } )
    self._menu:addChild(self._nextButton)
    self._nextButton:setPosition(display.cx + 100, 20)

    self._isLoop = false
    self._loopButton = ui.newTTFLabelMenuItem( {
        text = "Loop",
        font = global.font_monaco,
        size = 20,
        listener = handler(self, QEEffectBrower.onLoopClicked),
    } )
    self._menu:addChild(self._loopButton)
    self._loopButton:setPosition(display.cx + 180, 20)

    self._scales = {1.0, 0.75, 0.5, 0.25}
    self._scaleIndex = 1
    self._scaleButton = ui.newTTFLabelMenuItem( {
        text = "Scale " .. string.format("%1.2f", self._scales[self._scaleIndex]),
        font = global.font_monaco,
        size = 20,
        listener = handler(self, QEEffectBrower.onScaleClick),
    } )
    self._menu:addChild(self._scaleButton)
    self._scaleButton:setPosition(display.cx + 300, 20)
end

function QEEffectBrower:onEnter()
    -- search all animation file
    local files = filesInFolder(self._effectPath, "", false) 
    self._fileNames = {}
    for _, fullName in ipairs(files) do
        if fullName ~= "animation_time" and fullName ~= ".DS_Store" then
            table.insert(self._fileNames, fullName)
        end
    end

    table.sort(self._fileNames)

    -- quick search button
    local letters = {"A", "B", "C", "D", "E", "F", "G", "H", "I", "J", "K", "L", "M", "N", "O", "P", "Q", "R", "S", "T", "U", "V", "W", "X", "Y", "Z"}
    local x, y = display.width - 30, display.height - 15
    local buttons = {}
    for _, letter in ipairs(letters) do
        local button = ui.newTTFLabelMenuItem( {
            text = letter,
            font = global.font_monaco,
            size = 20,
            listener = function ( ... )
                local index = nil
                for i, fileName in ipairs(self._fileNames) do
                    local firstLetter = string.upper(string.sub(fileName, 1, 1))
                    if firstLetter == letter then
                        index = i
                        break
                    end
                end
                if index ~= nil then
                    self._index = index
                    self:displayEffect()
                end
            end
        } )
        self._menu:addChild(button)
        button:setPosition(x, y)
        table.insert(buttons, button)
        y = y - 24
    end
    self._letterButtons = buttons

    self._index = 1
    self:displayEffect()
end

function QEEffectBrower:onExit()
    if self._scheduler then
        scheduler.unscheduleGlobal(self._scheduler)
        self._scheduler = nil
    end
end

function QEEffectBrower:displayEffect()
    if self._fileNames == nil or #self._fileNames == 0 then
        return
    end

    local total = #self._fileNames
    if self._index < 1 then
        self._index = total
    end

    if self._index > total then
        self._index = 1
    end

    local fileName = self._fileNames[self._index]

    self._effectRoot:removeAllChildren()
    self._effectView = nil

    self._effectName:setString(fileName)

    local effectView = QFcaSkeletonView_cpp:createFcaSkeletonView(fileName, "effect", false)
    assert(effectView)

    effectView:setScale(self._scales[self._scaleIndex])

    self._effectRoot:addChild(effectView)
    self._effectView = effectView

    self:playAnimation()
end

function QEEffectBrower:playAnimation()
    if self._effectView ~= nil then
        self._effectView:playAnimation(self._effectView:getPlayAnimationName(), self._isLoop)
        self:updateTime()
    end
end

function QEEffectBrower:updateTime()
    if not self._scheduler then
        local dt = 1/30
        self._scheduler = scheduler.scheduleGlobal(function()
                if self._effectView ~= nil then
                    self._effectView:updateAnimation(dt)
                end
            end, dt)
    end
end

function QEEffectBrower:onPreviousClicked()
    self._index = self._index - 1
    self:displayEffect()
end

function QEEffectBrower:onNextClicked()
    self._index = self._index + 1
    self:displayEffect()
end

function QEEffectBrower:onLoopClicked()
    self._isLoop = (not self._isLoop)
    if self._isLoop then
        self._loopButton:setString("Loop √")
    else
        self._loopButton:setString("Loop")
    end
    self:displayEffect()
end

function QEEffectBrower:onScaleClick()
    self._scaleIndex = self._scaleIndex + 1
    if self._scaleIndex > 4 then
        self._scaleIndex = 1 
    end
    self._scaleButton:setString("Scale " .. string.format("%1.2f", self._scales[self._scaleIndex]))
    self:displayEffect()
end

return QEEffectBrower
