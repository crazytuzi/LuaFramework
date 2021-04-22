--
--  zxs
--  段位icon
--
local QUIWidget = import("..widgets.QUIWidget")
local QUIWidgetFloorIcon = class("QUIWidgetFloorIcon", QUIWidget)

function QUIWidgetFloorIcon:ctor(options)
    local ccbFile = "ccb/Widget_floor_icon.ccbi"
    QUIWidgetFloorIcon.super.ctor(self,ccbFile,nil,options)
    options = options or {}

    self._ccbOwner.node_name:setVisible(false)
    self._ccbOwner.node_level:setVisible(false)
    self._ccbOwner.node_icon:setVisible(false)

    local isLarge = options.isLarge
    if isLarge == nil then
        isLarge = true
    end
    self._ccbOwner.tf_rank_s:setVisible(not isLarge)
    self._ccbOwner.tf_rank_l:setVisible(isLarge)

    self:setInfo(options.floor, options.iconType)
end

function QUIWidgetFloorIcon:setColor(color)
    self._ccbOwner.tf_rank_s:setColor(color)
    self._ccbOwner.tf_rank_l:setColor(color)
end

function QUIWidgetFloorIcon:setShowName(visible)
    self._ccbOwner.node_name:setVisible(visible)
end

function QUIWidgetFloorIcon:setIconOffset(offset)
    self._ccbOwner.node_icon:setPositionY(offset)
end

function QUIWidgetFloorIcon:setNameOffset(offset)
    self._ccbOwner.node_name:setPositionY(offset)
end

function QUIWidgetFloorIcon:setLevelOffset(offset)
    self._ccbOwner.node_level:setPositionY(offset)
end

function QUIWidgetFloorIcon:setInfo(floor, iconType)
    floor = floor or 0
    if floor <= 0 and iconType == "consortiaWar" then
        floor = 1
    end
    iconType = iconType or "fightClub"
    
    local name, icon, level = remote[iconType]:getFloorTextureName(floor)
    if name then
        self._ccbOwner.node_name:setVisible(true)
        self._ccbOwner.tf_rank_s:setString(name)
        self._ccbOwner.tf_rank_l:setString(name)
    end
    if icon then
        self._ccbOwner.node_icon:removeAllChildren()
        self._ccbOwner.node_icon:setVisible(true)
        local spIcon = CCSprite:create(icon)
        --spIcon:setShaderProgram(qShader.Q_ProgramPositionTextureShadow)
        self._ccbOwner.node_icon:addChild(spIcon)
    end
    if level then
        self._ccbOwner.node_level:removeAllChildren()
        self._ccbOwner.node_level:setVisible(true)
        local spIcon = CCSprite:create(level)
        self._ccbOwner.node_level:addChild(spIcon)
    end
end


return QUIWidgetFloorIcon
