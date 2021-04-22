
local QUIWidget = import("..widgets.QUIWidget")
local QUIWidgetIconAniTips = class("QUIWidgetIconAniTips", QUIWidget)

function QUIWidgetIconAniTips:ctor(options)
    local ccbFile = "ccb/Widget_chat_icon.ccbi"
    local callbacks = {}
    QUIWidgetIconAniTips.super.ctor(self, ccbFile, callbacks, options)

    if options then
        self:setInfo(options.tipType, options.iconNum, options.str, options.dirction)
    end
end

function QUIWidgetIconAniTips:setInfo(tipType, iconNum, str, dirction)
    self._ccbOwner.node_icon:setVisible(tipType == 1)
    self._ccbOwner.node_tf:setVisible(tipType == 2)
        
    local contentSize = self._ccbOwner.sp_bg_1:getContentSize()
    if dirction == "down" then
        self._ccbOwner.sp_bg_1:setVisible(true)
        self._ccbOwner.sp_bg_2:setVisible(false)
        self._ccbOwner.sp_bg_1:setRotation(0)
        self._ccbOwner.sp_bg_1:setPositionY(28)
    elseif dirction == "up" then
        self._ccbOwner.sp_bg_1:setVisible(true)
        self._ccbOwner.sp_bg_2:setVisible(false)
        self._ccbOwner.sp_bg_1:setRotation(180)
        self._ccbOwner.sp_bg_1:setPositionY(38)
        self._ccbOwner.node_bg:setPositionY(-contentSize.height)
    elseif dirction == "right" then
        self._ccbOwner.sp_bg_1:setVisible(false)
        self._ccbOwner.sp_bg_2:setVisible(true)
        self._ccbOwner.sp_bg_2:setRotation(0)
        self._ccbOwner.sp_bg_2:setPositionX(2)
        self._ccbOwner.node_bg:setPositionX(-contentSize.width/2)
    elseif dirction == "left" then
        self._ccbOwner.sp_bg_1:setVisible(false)
        self._ccbOwner.sp_bg_2:setVisible(true)
        self._ccbOwner.sp_bg_2:setRotation(180)
        self._ccbOwner.sp_bg_2:setPositionX(-8)
        self._ccbOwner.node_bg:setPositionX(contentSize.width/2)
    end 

    local index = 1
    while (self._ccbOwner["sp_"..index]) do
        self._ccbOwner["sp_"..index]:setVisible(index == iconNum)
        index = index + 1
    end
    self._ccbOwner.tf_desc:setString(str or "")
end

return QUIWidgetIconAniTips