
local QUIDialog = import(".QUIDialog")
local QUIDialogBossIntroduce = class(".QUIDialogBossIntroduce", QUIDialog)

local QNavigationController = import("...controllers.QNavigationController")
local QUIViewController = import("..QUIViewController")
local QStaticDatabase = import("...controllers.QStaticDatabase")
local QUIWidgetActorActivityDisplay = import("..widgets.actorDisplay.QUIWidgetActorActivityDisplay")

-- 邮件对话框
function QUIDialogBossIntroduce:ctor(options)
	local ccbFile = "ccb/Dialog_Boss_Introduce.ccbi"
	local callBacks = {
        {ccbCallbackName = "onTriggerClose", callback = handler(self, QUIDialogBossIntroduce._onTriggerClose)},
        {ccbCallbackName = "onTriggerLeft", callback = handler(self, QUIDialogBossIntroduce._onTriggerLeft)},
        {ccbCallbackName = "onTriggerRight", callback = handler(self, QUIDialogBossIntroduce._onTriggerRight)},      
    }
    QUIDialogBossIntroduce.super.ctor(self, ccbFile, callBacks, options)
    self.isAnimation = true --是否动画显示

    self._frindId = 1001
    self._enemyId = options.bossId
    self._enemyTips = options.enemyTips

    self._ccbOwner.node_right:setVisible(false)
    self._ccbOwner.node_left:setVisible(false)
    self._ccbOwner.ly_mask_size:setVisible(false)
    self._ccbOwner.node_battle_scene:setVisible(false)

    self:_init()
end

function QUIDialogBossIntroduce:_init()
    self._characterConfig = QStaticDatabase.sharedDatabase():getCharacterByID(self._enemyId)
    self._dialogDisplayConfig = QStaticDatabase.sharedDatabase():getDialogDisplayById(self._enemyId)
    self._newEnemyTipsConfig = QStaticDatabase.sharedDatabase():getNewEnemyTips(self._enemyTips)

    self._index = 1

    self:_setBossCard()
    self:_setBossInfo()
    self:_analysis()
end

function QUIDialogBossIntroduce:_setBossCard()
    self._ccbOwner.node_heroCard:removeAllChildren()
    self._ccbOwner.node_heroCard:setVisible(false)
    if not self._characterConfig or not self._dialogDisplayConfig then return end

    local card = "icon/hero_card/art_snts.png"
    local x = 0
    local y = 0
    local scale = 1
    local rotation = 0
    local turn = 1
    if self._dialogDisplayConfig and self._dialogDisplayConfig.chouka1_card then
        card = self._dialogDisplayConfig.chouka1_card
        x = self._dialogDisplayConfig.chouka1_x
        y = self._dialogDisplayConfig.chouka1_y
        scale = self._dialogDisplayConfig.chouka1_scale
        rotation = self._dialogDisplayConfig.chouka1_rotation
        turn = self._dialogDisplayConfig.chouka1_isturn
    end
    -- local frame = QSpriteFrameByPath(card)
    local sprite = CCSprite:create(card)
    if sprite then
        sprite:setPosition(x, y)
        sprite:setScaleX(scale*turn)
        sprite:setScaleY(scale)
        sprite:setRotation(rotation)
        self._ccbOwner.node_heroCard:addChild(sprite)
        self._ccbOwner.node_heroCard:setVisible(true)
    else
        assert(false, "<<<"..card..">>>not exist!")
    end

    if self._newEnemyTipsConfig.move_clip ~= nil then
        self._ccbOwner.sp_bg_1:setVisible(self._newEnemyTipsConfig.move_clip)
    end
end

function QUIDialogBossIntroduce:_setBossInfo()
    self._ccbOwner.tf_title:setString("")
    self._ccbOwner.tf_name:setString("")
    if not self._characterConfig then return end
    --self._ccbOwner.tf_title:setString(self._characterConfig.title or "")
    self._ccbOwner.tf_name:setString(self._newEnemyTipsConfig.enemy_name or "")
end

function QUIDialogBossIntroduce:_analysis()
    if not self._newEnemyTipsConfig then return end

    self._skillList = {}
    self._friendList = {}
    self._enemyList = {}

    local skillNames = string.split(self._newEnemyTipsConfig.enemy_skill, ";")
    local skillDescriptions = string.split(self._newEnemyTipsConfig.description, ";")
    local skillEnemyActions = string.split(self._newEnemyTipsConfig.enemy_action, ";")
   
    local enemyLocations = string.split(self._newEnemyTipsConfig.enemy_location, ";")
    local enemyScales = string.split(self._newEnemyTipsConfig.enemy_scale, ";")
    local enemyDirections = string.split(self._newEnemyTipsConfig.enemy_direction, ";")
    local index = 1
    while true do
        local name = skillNames[index]
        if name then
            self._skillList[index] = {name = name, description = skillDescriptions[index] or "", enemyAction = skillEnemyActions[index]}
            index = index + 1
        else
            break
        end
    end

    local friendLocations = string.split(self._newEnemyTipsConfig.friend_location, ";")
    local friendScales = string.split(self._newEnemyTipsConfig.friend_scale, ";")
    local friendDirections = string.split(self._newEnemyTipsConfig.friend_direction, ";")
    index = 1
    while true do
        local posStr = friendLocations[index]
        if posStr and posStr ~= "nil" then
            self._friendList[index] = {posStr = posStr, scale = tonumber(friendScales[index]) or 1, direction = tonumber(friendDirections[index]) or 1}
            index = index + 1
        else
            break
        end
    end

    local enemyLocations = string.split(self._newEnemyTipsConfig.enemy_location, ";")
    local enemyScales = string.split(self._newEnemyTipsConfig.enemy_scale, ";")
    local enemyDirections = string.split(self._newEnemyTipsConfig.enemy_direction, ";")
    index = 1
    while true do
        local posStr = enemyLocations[index]
        if posStr then
            self._enemyList[index] = {posStr = posStr, scale = tonumber(enemyScales[index]) or 1, direction = tonumber(enemyDirections[index]) or 1}
            index = index + 1
        else
            break
        end
    end

    -- QPrintTable(self._skillList)
    -- QPrintTable(self._friendList)
    -- QPrintTable(self._enemyList)

    local size = self._ccbOwner.ly_mask_size:getContentSize()
    local layerColor = CCLayerColor:create(ccc4(0,0,0,150), size.width, size.height)
    local ccclippingNode = CCClippingNode:create()
    layerColor:setAnchorPoint(self._ccbOwner.ly_mask_size:getAnchorPoint())
    layerColor:setPosition(ccp(self._ccbOwner.ly_mask_size:getPosition()))
    ccclippingNode:setStencil(layerColor)
    self._ccbOwner.node_battle_scene:retain()
    self._ccbOwner.node_battle_scene:removeFromParent()
    ccclippingNode:addChild(self._ccbOwner.node_battle_scene)
    self._ccbOwner.node_battle_scene:release()
    self:getView():addChild(ccclippingNode)

    self:_initFriendAvatar()
    self:_initEnemyAvatar()
end

function QUIDialogBossIntroduce:_initFriendAvatar()
    if not self._friendList or #self._friendList == 0 then return end
    for _, friend in ipairs(self._friendList) do
        local friendAvatar = QUIWidgetActorActivityDisplay.new(self._frindId, {})
        -- local friendAvatar = QUIWidgetHeroInformation.new({forceDonotShowStar = true})
        -- friendAvatar:setBackgroundVisible(false)
        -- friendAvatar:setStarVisible(false)
        -- friendAvatar:setNameVisible(false)
        -- friendAvatar:setAvatar(self._frindId, 1)
        friendAvatar:setScaleX(friend.scale * friend.direction)
        friendAvatar:setScaleY(friend.scale)
        local posList = string.split(friend.posStr, ",")
        friendAvatar:setPosition(tonumber(posList[1]) or 0, tonumber(posList[2]) or 0)
        -- self._ccbOwner.node_avatar:addChild(friendAvatar:getView())
        self._ccbOwner.node_avatar:addChild(friendAvatar)
    end
end

function QUIDialogBossIntroduce:_initEnemyAvatar()
    if not self._enemyList or #self._enemyList == 0 then return end
    self._enemyAvatarList = {}
    for _, enemy in ipairs(self._enemyList) do
        local enemyAvatar = QUIWidgetActorActivityDisplay.new(self._enemyId, {})
        -- local enemyAvatar = QUIWidgetHeroInformation.new({forceDonotShowStar = true})
        -- enemyAvatar:setBackgroundVisible(false)
        -- enemyAvatar:setStarVisible(false)
        -- enemyAvatar:setNameVisible(false)
        -- enemyAvatar:setAvatar(self._enemyId, 1)
        -- enemyAvatar:stopDisplay()
        -- enemyAvatar:setScaleX(enemy.scale * enemy.direction)
        local actor = enemyAvatar:getActor()
        if actor then
            actor:getSkeletonView():setSkeletonScaleX(-enemy.scale * enemy.direction)
            actor:getSkeletonView():setSkeletonScaleY(enemy.scale)
        end
        local posList = string.split(enemy.posStr, ",")
        enemyAvatar:setPosition(tonumber(posList[1]) or 0, tonumber(posList[2]) or 0)
        -- self._ccbOwner.node_avatar:addChild(enemyAvatar:getView())
        self._ccbOwner.node_avatar:addChild(enemyAvatar)
        -- enemyAvatar:displayWithBehavior()
        -- enemyAvatar:setDisplayBehaviorCallback(function ()
        --     enemyAvatar:setDisplayBehaviorCallback(nil)
        -- end)
        table.insert(self._enemyAvatarList, enemyAvatar)
    end

    self:_updateAvatarShow()
end

function QUIDialogBossIntroduce:_updateAvatarShow()
    print(" QUIDialogBossIntroduce:_updateAvatarShow() ", #self._enemyAvatarList)
    if not self._enemyAvatarList or #self._enemyAvatarList == 0 then return end
    local info = self._skillList[self._index]
    QPrintTable(self._skillList)
    QPrintTable(info)
    if not info then return end

    self:_setEnemySkillInfo()

    for _, enemy in ipairs(self._enemyAvatarList) do
        local actionList = string.split(info.enemyAction, ":")
        enemy:displayWithBehavior(actionList[1])
        enemy:setDisplayBehaviorCallback(function ()
            enemy:setDisplayBehaviorCallback(nil)
            self:_updateAvatarShow()
        end)
        -- enemy:avatarPlayAnimation(actionList[1])
    end
end

function QUIDialogBossIntroduce:_setEnemySkillInfo()
    self._ccbOwner.tf_skillName:setString("")
    self._ccbOwner.tf_skillDescribe:setString("")

    local info = self._skillList[self._index]
    if not info then return end

    self._ccbOwner.tf_skillName:setString(info.name)
    self._ccbOwner.tf_skillDescribe:setString(info.description)
end

function QUIDialogBossIntroduce:_onTriggerLeft()
    app.sound:playSound("common_close")

    self._index = self._index - 1
    if self._index <= 0 then self._index = #self._skillList or 1 end

    self:_updateAvatarShow()
end

function QUIDialogBossIntroduce:_onTriggerRight()
    app.sound:playSound("common_close")
    
    self._index = self._index + 1
    if not self._skillList or self._index > #self._skillList then self._index = 1 end

    self:_updateAvatarShow()
end

--------------------------------------------------------

function QUIDialogBossIntroduce:viewDidAppear()
	QUIDialogBossIntroduce.super.viewDidAppear(self)
    self._ccbOwner.node_battle_scene:setVisible(true)
end

function QUIDialogBossIntroduce:viewWillDisappear()
	QUIDialogBossIntroduce.super.viewWillDisappear(self)
end

-- function QUIDialogBossIntroduce:_backClickHandler()
--     self:_onTriggerClose()
-- end

-- 关闭对话框
function QUIDialogBossIntroduce:_onTriggerClose()
    app.sound:playSound("common_close")
    self._ccbOwner.node_battle_scene:setVisible(false)
    self:playEffectOut()
end

function QUIDialogBossIntroduce:viewAnimationOutHandler()
    app:getNavigationManager():popViewController(app.middleLayer, QNavigationController.POP_TOP_CONTROLLER)
end

return QUIDialogBossIntroduce
