
local QUIDialog = import(".QUIDialog")
local QUIDialogBossIntroducePic = class(".QUIDialogBossIntroducePic", QUIDialog)

local QNavigationController = import("...controllers.QNavigationController")
local QUIViewController = import("..QUIViewController")
local QStaticDatabase = import("...controllers.QStaticDatabase")
local QUIWidgetActorActivityDisplay = import("..widgets.actorDisplay.QUIWidgetActorActivityDisplay")
local QRichText = import("...utils.QRichText")

-- 邮件对话框
function QUIDialogBossIntroducePic:ctor(options)
	local ccbFile = "ccb/Dialog_Boss_Introduce2.ccbi"
	local callBacks = {
        {ccbCallbackName = "onTriggerClose", callback = handler(self, QUIDialogBossIntroducePic._onTriggerClose)},
        {ccbCallbackName = "onTriggerLeft", callback = handler(self, QUIDialogBossIntroducePic._onTriggerLeft)},
        {ccbCallbackName = "onTriggerRight", callback = handler(self, QUIDialogBossIntroducePic._onTriggerRight)},      
    }
    QUIDialogBossIntroducePic.super.ctor(self, ccbFile, callBacks, options)
    self.isAnimation = true --是否动画显示

    self._enemyId = options.bossId
    self._enemyTips = options.enemyTips

    self._ccbOwner.node_right:setVisible(false)
    self._ccbOwner.node_left:setVisible(false)
    
    self:_init()
end

function QUIDialogBossIntroducePic:_init()
    -- self._characterConfig = QStaticDatabase.sharedDatabase():getCharacterByID(self._enemyId)
    self._newEnemyTipsConfig = QStaticDatabase.sharedDatabase():getNewEnemyTips(self._enemyTips)

    self._index = 1

    self:_setBossInfo()
    self:_showSkill()
    self:_analysis()
end

function QUIDialogBossIntroducePic:_setBossInfo()
    self._ccbOwner.tf_title:setString("")
    if not self._newEnemyTipsConfig then return end
    --self._ccbOwner.tf_title:setString(self._characterConfig.title or "")
    self._ccbOwner.tf_title:setString(self._newEnemyTipsConfig.enemy_name or "")

    local skillDescList = string.split(self._newEnemyTipsConfig.description, ";")
    local count = #skillDescList
    for index, str in ipairs(skillDescList) do
        local richText = QRichText.new(str, 1000, {autoCenter = false, stringType = 1})
        if count > 1 then
            if index == 1 then
                richText:setAnchorPoint(ccp(0,0))
            else
                richText:setAnchorPoint(ccp(0,1))
            end
        else
            richText:setAnchorPoint(ccp(0,0.5))
        end
        self._ccbOwner.node_desc:addChild(richText)
    end
end

function QUIDialogBossIntroducePic:_showSkill()
    if not self._newEnemyTipsConfig or not self._newEnemyTipsConfig.skill_desc then return end
    self._spPathList = string.split(self._newEnemyTipsConfig.skill_desc, ";")
    self:_updateSkillSpShow()
end

function QUIDialogBossIntroducePic:_updateSkillSpShow()
    self._ccbOwner.node_right:setVisible(false)
    self._ccbOwner.node_left:setVisible(false)

    if not self._spPathList or #self._spPathList == 0 then return end
    if #self._spPathList > 1 then
        if self._index == 1 then
            self._ccbOwner.node_left:setVisible(false)
            self._ccbOwner.node_right:setVisible(true)
        elseif self._index == #self._spPathList then
            self._ccbOwner.node_left:setVisible(true)
            self._ccbOwner.node_right:setVisible(false)
        else
            self._ccbOwner.node_left:setVisible(true)
            self._ccbOwner.node_right:setVisible(true)
        end
    end
    -- print(self._index, self._spPathList[self._index])
    local frame = QSpriteFrameByPath(self._spPathList[self._index])
    if frame then
        self._ccbOwner.sp_skillShow:setDisplayFrame(frame)
    end
    
end

function QUIDialogBossIntroducePic:_analysis()
    if not self._newEnemyTipsConfig then return end
    self._enemyList = {}
    local enemyLocation = self._newEnemyTipsConfig.enemy_location or "0, 0"
    local enemyScale = self._newEnemyTipsConfig.enemy_scale or 1
    local enemyDirection = self._newEnemyTipsConfig.enemy_direction or 1
    self._enemyList = {posStr = enemyLocation, scale = tonumber(enemyScale), direction = tonumber(enemyDirection)}

    self:_initEnemyAvatar()
end

function QUIDialogBossIntroducePic:_initEnemyAvatar()
    if not self._enemyList then return end
    local enemyAvatar = QUIWidgetActorActivityDisplay.new(self._enemyId, {})
    local actor = enemyAvatar:getActor()
    if actor then
        actor:getSkeletonView():setSkeletonScaleX(-self._enemyList.scale * self._enemyList.direction)
        actor:getSkeletonView():setSkeletonScaleY(self._enemyList.scale)
    end
    local posList = string.split(self._enemyList.posStr, ",")
    enemyAvatar:setPosition(tonumber(posList[1]) or 0, tonumber(posList[2]) or 0)
    self._ccbOwner.node_avatar:addChild(enemyAvatar)
end

function QUIDialogBossIntroducePic:_onTriggerLeft()
    app.sound:playSound("common_close")

    if self._index <= 1 then return end
    self._index = self._index - 1
    -- if self._index <= 0 then self._index = #self._spPathList or 1 end

    self:_updateSkillSpShow()
end

function QUIDialogBossIntroducePic:_onTriggerRight()
    app.sound:playSound("common_close")
    
    if self._index >= #self._spPathList then return end
    self._index = self._index + 1
    -- if not self._spPathList or self._index > #self._spPathList then self._index = 1 end

    self:_updateSkillSpShow()
end

--------------------------------------------------------

function QUIDialogBossIntroducePic:viewDidAppear()
	QUIDialogBossIntroducePic.super.viewDidAppear(self)
end

function QUIDialogBossIntroducePic:viewWillDisappear()
	QUIDialogBossIntroducePic.super.viewWillDisappear(self)
end

-- function QUIDialogBossIntroducePic:_backClickHandler()
--     self:_onTriggerClose()
-- end

-- 关闭对话框
function QUIDialogBossIntroducePic:_onTriggerClose(event)
    if q.buttonEventShadow(event, self._ccbOwner.frame_btn_close) == false then return end
    app.sound:playSound("common_close")
    self:playEffectOut()
end

function QUIDialogBossIntroducePic:viewAnimationOutHandler()
    app:getNavigationManager():popViewController(app.middleLayer, QNavigationController.POP_TOP_CONTROLLER)
end

return QUIDialogBossIntroducePic
