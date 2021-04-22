local QEAnimationBrower = class("QEAnimationBrower", function()
    return display.newScene("QEAnimationBrower")
end)

function QEAnimationBrower:ctor()
    print("[Kumo] device.platform = ", device.platform)
    local relativePath = "scripts/app/editor/scenes/QEAnimationBrower.lua"
    local currentFilePath = CCFileUtils:sharedFileUtils():fullPathForFilename(relativePath)
    self._effectPath = string.sub(currentFilePath, 1, string.len(currentFilePath) - string.len(relativePath)) .. "res/actor/fca"
    self._bgPath = string.sub(currentFilePath, 1, string.len(currentFilePath) - string.len(relativePath)) .. "res/map"
    if device.platform == "windows" then
        self._effectPath = string.gsub(self._effectPath, "/", "\\")
        self._bgPath = string.gsub(self._bgPath, "/", "\\")
    end
    print("[Kumo] effect path = ", self._effectPath)
    print("[Kumo] bg path = ", self._bgPath)

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

    self._bgRoot = CCNode:create()
    self:addChild(self._bgRoot)
    self._bgRoot:setPosition(display.cx, display.cy)

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
        listener = handler(self, QEAnimationBrower.onPreviousClicked),
    } )
    self._menu:addChild(self._previousButton)
    self._previousButton:setPosition(display.cx, 20)

    self._nextButton = ui.newTTFLabelMenuItem( {
        text = "Next",
        font = global.font_monaco,
        size = 20,
        listener = handler(self, QEAnimationBrower.onNextClicked),
    } )
    self._menu:addChild(self._nextButton)
    self._nextButton:setPosition(display.cx + 100, 20)

    self._isLoop = false
    self._loopButton = ui.newTTFLabelMenuItem( {
        text = "Loop",
        font = global.font_monaco,
        size = 20,
        listener = handler(self, QEAnimationBrower.onLoopClicked),
    } )
    self._menu:addChild(self._loopButton)
    self._loopButton:setPosition(display.cx + 180, 20)

    self._scales = { 0.25, 0.5, 0.75, 1 }
    self._scaleIndex = 1
    self._scaleButton = ui.newTTFLabelMenuItem( {
        text = "Scale " .. string.format("%1.2f", self._scales[self._scaleIndex]),
        font = global.font_monaco,
        size = 20,
        listener = handler(self, QEAnimationBrower.onScaleClick),
    } )
    self._menu:addChild(self._scaleButton)
    self._scaleButton:setPosition(display.cx + 300, 20)

    self._curShowNum = 1
    self._pageShowNum = 20 -- 一页显示的角色数量
    self._pageUpButton = ui.newTTFLabelMenuItem( {
        text = "<page up>",
        font = global.font_monaco,
        size = 20,
        listener = handler(self, QEAnimationBrower.onPageUpClicked),
    } )
    self._menu:addChild(self._pageUpButton)
    self._pageUpButton:setPosition(100, 620)

    self._pageUpOnceButton = ui.newTTFLabelMenuItem( {
        text = "<up once>",
        font = global.font_monaco,
        size = 20,
        listener = handler(self, QEAnimationBrower.onPageUpOnceClicked),
    } )
    self._menu:addChild(self._pageUpOnceButton)
    self._pageUpOnceButton:setPosition(100, 600)

    self._pageDownButton = ui.newTTFLabelMenuItem( {
        text = "<page down>",
        font = global.font_monaco,
        size = 20,
        listener = handler(self, QEAnimationBrower.onPageDownClicked),
    } )
    self._menu:addChild(self._pageDownButton)
    self._pageDownButton:setPosition(100, 20)

    self._pageDownOnceButton = ui.newTTFLabelMenuItem( {
        text = "<down once>",
        font = global.font_monaco,
        size = 20,
        listener = handler(self, QEAnimationBrower.onPageDownOnceClicked),
    } )
    self._menu:addChild(self._pageDownOnceButton)
    self._pageDownOnceButton:setPosition(100, 40)

    self._curShowBgNum = 1
    self._pageShowBgNum = 8 -- 一页显示的角色数量
    self._pageUpBgButton = ui.newTTFLabelMenuItem( {
        text = "<page up>",
        font = global.font_monaco,
        size = 20,
        listener = handler(self, QEAnimationBrower.onPageUpBgClicked),
    } )
    self._menu:addChild(self._pageUpBgButton)
    self._pageUpBgButton:setPosition(display.width - 80, 300)

    self._pageUpOnceBgButton = ui.newTTFLabelMenuItem( {
        text = "<up once>",
        font = global.font_monaco,
        size = 20,
        listener = handler(self, QEAnimationBrower.onPageUpOnceBgClicked),
    } )
    self._menu:addChild(self._pageUpOnceBgButton)
    self._pageUpOnceBgButton:setPosition(display.width - 80, 280)

    self._pageDownBgButton = ui.newTTFLabelMenuItem( {
        text = "<page down>",
        font = global.font_monaco,
        size = 20,
        listener = handler(self, QEAnimationBrower.onPageDownBgClicked),
    } )
    self._menu:addChild(self._pageDownBgButton)
    self._pageDownBgButton:setPosition(display.width - 80, 20)

    self._pageDownOnceBgButton = ui.newTTFLabelMenuItem( {
        text = "<down once>",
        font = global.font_monaco,
        size = 20,
        listener = handler(self, QEAnimationBrower.onPageDownOnceBgClicked),
    } )
    self._menu:addChild(self._pageDownOnceBgButton)
    self._pageDownOnceBgButton:setPosition(display.width - 80, 40)
end

function QEAnimationBrower:onEnter()
    -- search all animation file
    local files = filesInFolder(self._effectPath, "", false) 
    self._fileNames = {}
    for _, fullName in ipairs(files) do
        if fullName ~= "animation_time" and fullName ~= ".DS_Store" then
            table.insert(self._fileNames, fullName)
        end
    end

    table.sort(self._fileNames)

    self:updateLeftLetterButtons()

    self._index = 1
    self:displayEffect()
end

function QEAnimationBrower:onExit()
    if self._scheduler then
        scheduler.unscheduleGlobal(self._scheduler)
        self._scheduler = nil
    end
end

function QEAnimationBrower:displayEffect()
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
    local effectView = QFcaSkeletonView_cpp:createFcaSkeletonView(fileName, "actor", false)
    assert(effectView)
    effectView:setScale(self._scales[self._scaleIndex])
    effectView:setPositionY(-250)

    self._effectRoot:addChild(effectView)
    self._effectView = effectView

    self._animationNames = string.split(effectView:getAvailableAnimationNames(), ";")
    self:updateRightLetterButtons()

    -- 背景
    local files = filesInFolder(self._bgPath, "", false)
    self._bgNames = {}
    for _, fullName in ipairs(files) do
        if string.find(fullName, ".jpg") then
            table.insert(self._bgNames, fullName)
        end
    end
    self:updateBgLetterButtons()
end

function QEAnimationBrower:updateLeftLetterButtons()
    for _, button in ipairs(self._leftLetterButtons or {}) do
        button:removeFromParent()
    end
    self._leftLetterButtons = {}

    local startIndex = self._curShowNum
    local endIndex = self._curShowNum + self._pageShowNum
    if endIndex > #self._fileNames then endIndex = #self._fileNames end
    -- print("[Kumo] <updateLeftLetterButtons> startIndex = ", startIndex, "  endIndex = ", endIndex)
    local letters = {}
    table.foreachi(self._fileNames, function(i, v)
            if i >= startIndex and i <= endIndex then
                table.insert(letters, (i - startIndex + 1), v)
            end
        end)
    -- print("[Kumo] <updateLeftLetterButtons> letters.length = ", #letters)
    table.sort( letters , function (a,b)
        return a < b
    end)
    local x, y = 100, 560
    local buttons = {}
    for _, letter in ipairs(letters) do
        local button = ui.newTTFLabelMenuItem( {
            text = letter,
            font = global.font_monaco,
            size = 20,
            align = ui.TEXT_ALIGN_LEFT,
            listener = function ( ... )
                local index = nil
                for i, fileName in ipairs(self._fileNames) do
                    if fileName == letter then
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

    self._leftLetterButtons = buttons
end

function QEAnimationBrower:updateRightLetterButtons()
    for _, button in ipairs(self._rightLetterButtons or {}) do
        button:removeFromParent()
    end
    self._rightLetterButtons = {}

    local letters = self._animationNames
    local x, y = display.width - 80, display.height - 15
    local buttons = {}
    for _, letter in ipairs(letters) do
        local button = ui.newTTFLabelMenuItem( {
            text = letter,
            font = global.font_monaco,
            size = 20,
            align = ui.TEXT_ALIGN_LEFT,
            listener = function ( ... )
                local index = nil
                for i, animationName in ipairs(self._animationNames) do
                    if animationName == letter then
                        self:playAnimation(animationName)
                    end
                end
            end
        } )
        self._menu:addChild(button)
        button:setPosition(x, y)
        table.insert(buttons, button)
        y = y - 24
    end

    self._rightLetterButtons = buttons
end

function QEAnimationBrower:updateBgLetterButtons()
    for _, button in ipairs(self._bgLetterButtons or {}) do
        button:removeFromParent()
    end
    self._bgLetterButtons = {}

    local startIndex = self._curShowBgNum
    local endIndex = self._curShowBgNum + self._pageShowBgNum
    if endIndex > #self._bgNames then endIndex = #self._bgNames end
    local letters = {}
    table.foreachi(self._bgNames, function(i, v)
            if i >= startIndex and i <= endIndex then
                table.insert(letters, (i - startIndex + 1), v)
            end
        end)
    local x, y = display.width - 80, 240
    local buttons = {}
    for _, letter in ipairs(letters) do
        local button = ui.newTTFLabelMenuItem( {
            text = string.gsub(letter, ".jpg", ""),
            font = global.font_monaco,
            size = 20,
            align = ui.TEXT_ALIGN_RIGHT,
            listener = function ( ... )
                local index = nil
                for i, bgName in ipairs(self._bgNames) do
                    if bgName == letter then
                        self._bgRoot:removeAllChildren()
                        local sp = CCSprite:create("res/map/"..bgName)
                        local scaleX = display.width / sp:getContentSize().width
                        local scaleY = display.height / sp:getContentSize().height
                        sp:setScaleX(scaleX)
                        sp:setScaleY(scaleY)
                        sp:setPosition(0, 0)
                        self._bgRoot:addChild(sp)
                    end
                end
            end
        } )
        self._menu:addChild(button)
        button:setPosition(x, y)
        table.insert(buttons, button)
        y = y - 20
    end

    self._bgLetterButtons = buttons
end

function QEAnimationBrower:playAnimation(animationName)
    print("animationName", animationName)
    if self._effectView ~= nil then
        self._effectView:playAnimation(tostring(animationName), self._isLoop)
        self:updateTime()
    end
end

function QEAnimationBrower:updateTime()
    if not self._scheduler then
        local dt = 1/30
        self._scheduler = scheduler.scheduleGlobal(function()
                if self._effectView ~= nil then
                    self._effectView:updateAnimation(dt)
                end
            end, dt)
    end
end

function QEAnimationBrower:onPreviousClicked()
    self._index = self._index - 1
    self:displayEffect()
end

function QEAnimationBrower:onNextClicked()
    self._index = self._index + 1
    self:displayEffect()
end

function QEAnimationBrower:onLoopClicked()
    self._isLoop = (not self._isLoop)
    if self._isLoop then
        self._loopButton:setString("Loop √")
    else
        self._loopButton:setString("Loop")
    end
    self:displayEffect()
end

function QEAnimationBrower:onScaleClick()
    self._scaleIndex = self._scaleIndex + 1
    if self._scaleIndex > #self._scales then
        self._scaleIndex = 1 
    end
    self._scaleButton:setString("Scale " .. string.format("%1.2f", self._scales[self._scaleIndex]))
    self:displayEffect()
end

function QEAnimationBrower:onPageUpClicked()
    self._curShowNum = self._curShowNum - self._pageShowNum
    if self._curShowNum < 1 then
        self._curShowNum = 1
    end
    self:updateLeftLetterButtons()
end

function QEAnimationBrower:onPageUpOnceClicked()
    self._curShowNum = self._curShowNum - 1
    if self._curShowNum < 1 then
        self._curShowNum = 1
    end
    self:updateLeftLetterButtons()
end

function QEAnimationBrower:onPageDownClicked()
    self._curShowNum = self._curShowNum + self._pageShowNum
    if self._curShowNum > #self._fileNames then
        self._curShowNum = #self._fileNames
    end
    self:updateLeftLetterButtons()
end

function QEAnimationBrower:onPageDownOnceClicked()
    self._curShowNum = self._curShowNum + 1
    if self._curShowNum > #self._fileNames then
        self._curShowNum = #self._fileNames
    end
    self:updateLeftLetterButtons()
end

function QEAnimationBrower:onPageUpBgClicked()
    self._curShowBgNum = self._curShowBgNum - self._pageShowBgNum
    if self._curShowBgNum < 1 then
        self._curShowBgNum = 1
    end
    self:updateBgLetterButtons()
end

function QEAnimationBrower:onPageUpOnceBgClicked()
    self._curShowBgNum = self._curShowBgNum - 1
    if self._curShowBgNum < 1 then
        self._curShowBgNum = 1
    end
    self:updateBgLetterButtons()
end

function QEAnimationBrower:onPageDownBgClicked()
    self._curShowBgNum = self._curShowBgNum + self._pageShowBgNum
    if self._curShowBgNum > #self._bgNames then
        self._curShowBgNum = #self._bgNames
    end
    self:updateBgLetterButtons()
end

function QEAnimationBrower:onPageDownOnceBgClicked()
    self._curShowBgNum = self._curShowBgNum + 1
    if self._curShowBgNum > #self._bgNames then
        self._curShowBgNum = #self._bgNames
    end
    self:updateBgLetterButtons()
end

return QEAnimationBrower