
local QUIWidget = import("..widgets.QUIWidget")
local QUIWidgetLoadingBar = class("QUIWidgetLoadingBar", QUIWidget)

local QRectUiMask = import("...ui.battle.QRectUiMask")

function QUIWidgetLoadingBar:ctor(options)
	local ccbFile = "ccb/Widget_LoginPressBar2.ccbi"
	local callBacks = {
        {ccbCallbackName = "onTriggerShow", callback = handler(self, QUIWidgetLoadingBar._onTriggerShow)},
    }
	QUIWidgetLoadingBar.super.ctor(self, ccbFile, callBacks, options)
    self._totalSize = 0

    if CCNode.wakeup then
        self:wakeup()
    end
    self._ccbOwner.tf_tips:setString("")
    self._ccbOwner.tf_tips:setVisible(ENABLE_NEW_UPDATE)
end

function QUIWidgetLoadingBar:setCheckingVisible(visible)
    self._ccbOwner.checkingNode:setVisible(visible)
end

function QUIWidgetLoadingBar:setUpdatingVisible(visible)
    self._ccbOwner.updatingNode:setVisible(visible)
end

function QUIWidgetLoadingBar:setSizeVisible(visible)
    self._ccbOwner.size:setVisible(visible)
end

function QUIWidgetLoadingBar:setDownloadText(text)
    self._ccbOwner.updatingText:setString(text)
end

function QUIWidgetLoadingBar:setUpdatingText(size)
    self._text = string.format("游戏更新中(%s)，更新后可获得丰厚奖励...", size)
    self._ccbOwner.updatingText:setString(self._text)
end

function QUIWidgetLoadingBar:setFileUrl(urlStr)
    urlStr = string.gsub(urlStr, "http://update.dldl.joybest.com.cn/dldl/release/","")
    urlStr = string.gsub(urlStr, "?ver=([%d]*)","")
    self._fileText = urlStr
    self._ccbOwner.tf_tips:setString(self._fileText)
end

function QUIWidgetLoadingBar:setTips(text)
    self._ccbOwner.tf_tips:setString(text)
end

function QUIWidgetLoadingBar:setPercent(percent)
	self:_setBarPercent(percent)
end

-- In kb
function QUIWidgetLoadingBar:setTotalSize(size)
    self._totalSize = size
end

-- In kb
function QUIWidgetLoadingBar:setDownloadedSize(size)
	self._ccbOwner.size:setString(string.format("%d/%dKB", size, self._totalSize))
    local text = self._text .. string.format(" %.1f%%", (size/self._totalSize)*100)
    self._ccbOwner.updatingText:setString(text)
end

function QUIWidgetLoadingBar:_setBarPercent(percent)
	percent = percent/100

    local node_bar = self._ccbOwner.node_bar
    local width = node_bar:getContentSize().width
    if self._mask == nil then
        self._mask = QRectUiMask.new()
        self._mask:setFromLeftToRight(true)
        function self._mask:getCascadeBoundingBox()
            return CCRectMake(0, 0, width, 64)
        end
        self._mask:setAdditionalWidth(width)
        node_bar:getParent():addChild(self._mask)
        local positionX, positionY = node_bar:getPosition()
        node_bar:retain()
        node_bar:removeFromParent()
        self._mask:addChild(node_bar)
        self._mask:setPosition(positionX, positionY)
        node_bar:setPosition(0.0, 0.0)
        node_bar:release()
        -- self._ccbOwner.node_light:retain()
        -- self._ccbOwner.node_light:removeFromParent()
        -- self._mask:getParent():addChild(self._ccbOwner.node_light)
        -- self._ccbOwner.node_light:release()
    end

    -- self._ccbOwner.node_light:setPositionX(node_bar:getPositionX() + width * (percent - 0.5))
    self._mask:update(0.5 + percent / 2)
    self._ccbOwner.tf_percent:setString(string.format("%d%%", percent * 100))
end

function QUIWidgetLoadingBar:_onTriggerShow()
    self._ccbOwner.tf_tips:setVisible(not self._ccbOwner.tf_tips:isVisible())
end

function QUIWidgetLoadingBar:setWifiTipsVisible(trueOrFalse)
    -- body
    self._ccbOwner.wifiTips:setVisible(trueOrFalse)
end


return QUIWidgetLoadingBar
