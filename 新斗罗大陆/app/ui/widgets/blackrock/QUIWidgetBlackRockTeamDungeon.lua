local QUIWidget = import("...widgets.QUIWidget")
local QUIWidgetBlackRockTeamDungeon = class("QUIWidgetBlackRockTeamDungeon", QUIWidget)
local QStaticDatabase = import("....controllers.QStaticDatabase")
local QUIWidgetAvatar = import("...widgets.QUIWidgetAvatar")

function QUIWidgetBlackRockTeamDungeon:ctor(options)
    local ccbFile = "ccb/Widget_Black_mountain_chat1.ccbi"
    local callBacks = {
    }
    QUIWidgetBlackRockTeamDungeon.super.ctor(self,ccbFile,callBacks,options)
    cc.GameObject.extend(self)
    self:addComponent("components.behavior.EventProtocol"):exportMethods()

    self:setScale(0.8)
    self._ccbOwner.node_leader:setVisible(false)
    self._ccbOwner.node_member:setVisible(false)
    self._ccbOwner.node_headPicture_bg:setVisible(false)
end

function QUIWidgetBlackRockTeamDungeon:setDungeonId(dungeonId, isNpc)
    self._ccbOwner.node_head:removeAllChildren()
    self._ccbOwner.online:setVisible(true)
    if self._buffWidget ~= nil then
        self._buffWidget:removeFromParent()
        self._buffWidget = nil
    end
    if isNpc == true then
        self._dungeonId = dungeonId
        local dungeonConfig = remote.blackrock:getConfigByDungeonId(self._dungeonId)

        self._ccbOwner.tf_role:setVisible(true)
        self._ccbOwner.tf_role:setString(dungeonConfig.monster_name)
        self._ccbOwner.tf_role:setFontSize(22)
        self._ccbOwner.tf_role:setPositionY(-43)
        if dungeonConfig.combat_team_id == 1 then
            self._ccbOwner.tf_nickName:setColor(UNITY_COLOR_LIGHT.blue)
            self._ccbOwner.tf_role:setColor(UNITY_COLOR_LIGHT.blue)
        elseif dungeonConfig.combat_team_id == 2 then
            self._ccbOwner.tf_nickName:setColor(UNITY_COLOR_LIGHT.purple)
            self._ccbOwner.tf_role:setColor(UNITY_COLOR_LIGHT.purple)
        elseif dungeonConfig.combat_team_id == 3 then
            self._ccbOwner.tf_nickName:setColor(UNITY_COLOR_LIGHT.orange)
            self._ccbOwner.tf_role:setColor(UNITY_COLOR_LIGHT.orange)
        elseif dungeonConfig.combat_team_id == 4 then
            self._ccbOwner.tf_nickName:setColor(UNITY_COLOR_LIGHT.red)
            self._ccbOwner.tf_role:setColor(UNITY_COLOR_LIGHT.red)
        end

        local num,unit = q.convertLargerNumber(dungeonConfig.monster_battleforce)
        self._ccbOwner.tf_nickName:setString(num .. (unit or ""))

        if dungeonConfig.monster_id then
            local characterConfig = QStaticDatabase.sharedDatabase():getCharacterByID(dungeonConfig.monster_id)

            local owner = {}
            local proxy = CCBProxy:create()
            local node = CCBuilderReaderLoad("ccb/Widget_DailyMissionBox.ccbi", proxy, owner)
            self:initBlackRockTeamDungeon(node, owner, characterConfig,dungeonConfig)
            node:setScale(0.7)
            self._ccbOwner.node_head:addChild(node)
                     
        end

    else
        self._buffId = dungeonId
        local buffConfig = QStaticDatabase:sharedDatabase():getBlackRockBuffId(self._buffId)
        if buffConfig == nil then
            app.tip:floatTip("【"..self._buffId.."】ID的BUFF在量表中未找到~")
            return
        end
        self._ccbOwner.tf_nickName:setString(buffConfig.buff_name)
        self._ccbOwner.tf_nickName:setColor(COLORS.a)
        self._ccbOwner.node_headPicture_bg:setVisible(false)
        local buffPath = QSpriteFrameByPath(buffConfig.buff_photo_static)
        local sp_buff = CCSprite:createWithSpriteFrame(buffPath)
        if sp_buff then
            self._ccbOwner.node_head:addChild(sp_buff)      
        end    
    end
end

function QUIWidgetBlackRockTeamDungeon:initBlackRockTeamDungeon(widget, owner, data,dungeon)

    owner.node_green:setVisible(false)
    owner.node_blue:setVisible(false)
    owner.node_orange:setVisible(false)
    owner.node_purple:setVisible(false)
    owner.node_white:setVisible(false)
    owner.node_normal:setVisible(false)
    local colourType = 0
    if dungeon.colour then
        colourType = tonumber(dungeon.colour) 
    end
    if colourType == 1 then
        owner.node_white:setVisible(true)
    elseif colourType == 2 then
        owner.node_green:setVisible(true)
    elseif colourType == 3 then
        owner.node_blue:setVisible(true)
    elseif colourType == 4 then
        owner.node_purple:setVisible(true)
    elseif colourType == 5 then
        owner.node_orange:setVisible(true)
    elseif colourType == 6 then
        owner.node_red:setVisible(true) 
    else
        owner.node_normal:setVisible(true)                               
    end

    if data.icon ~= nil and data.icon ~= "" then
        local texture = CCTextureCache:sharedTextureCache():addImage(data.icon)
        owner.box_icon:setTexture(texture)
        owner.box_icon:setVisible(true)
        owner.box_icon:setScaleX(-1)
    end
end

function QUIWidgetBlackRockTeamDungeon:setRoleSize(size)
    -- self._ccbOwner.tf_role:setFontSize(size)
end

function QUIWidgetBlackRockTeamDungeon:hideFun(index)
    self._ccbOwner.sp_single:setVisible(false)
    self._ccbOwner.sp_attack:setVisible(false)
    self._ccbOwner.sp_armor:setVisible(false)
    self._ccbOwner.sp_multi:setVisible(false)
    if index ~= nil then
        if index == 1 then
            self._ccbOwner.sp_attack:setVisible(true)
        elseif index == 2 then
            self._ccbOwner.sp_armor:setVisible(true)
        elseif index == 3 then
            self._ccbOwner.sp_multi:setVisible(true)
        elseif index == 4 then
            self._ccbOwner.sp_single:setVisible(true)
        end
    end
end

return QUIWidgetBlackRockTeamDungeon