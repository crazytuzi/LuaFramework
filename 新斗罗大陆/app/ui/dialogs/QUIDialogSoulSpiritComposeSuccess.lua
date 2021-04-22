--
-- Author: Kumo.Wang
-- 魂靈恭喜獲得界面
--
local QUIDialog = import(".QUIDialog")
local QUIDialogSoulSpiritComposeSuccess = class("QUIDialogSoulSpiritComposeSuccess", QUIDialog)

local QUIWidgetActorDisplay = import("..widgets.actorDisplay.QUIWidgetActorDisplay")
local QColorLabel = import("...utils.QColorLabel")
local QNotificationCenter = import("...controllers.QNotificationCenter")
local QTutorialEvent = import("...tutorial.event.QTutorialEvent")
local QStaticDatabase = import("...controllers.QStaticDatabase")

function QUIDialogSoulSpiritComposeSuccess:ctor(options)
    local ccbFile = "ccb/Dialog_SoulSpirit_Compose_Success.ccbi"
    local callBacks = {
    }
    QUIDialogSoulSpiritComposeSuccess.super.ctor(self, ccbFile, callBacks, options)

    self._id = options.id
    self._callBack = options.callBack

    self._isEnd = false

    self:setHeroInfo()

    CalculateUIBgSize(self._ccbOwner.node_bg,1280)

    scheduler.performWithDelayGlobal(function()
            self._isEnd = true
            QNotificationCenter.sharedNotificationCenter():dispatchEvent({name = QTutorialEvent.EVENT_CALL_HERO_SUCCESS})
        end, 2)
end

function QUIDialogSoulSpiritComposeSuccess:setHeroInfo()
    local characterConfig = QStaticDatabase.sharedDatabase():getCharacterByID(self._id)
    local color = remote.soulSpirit:getColorByCharacherId(self._id)
    self._ccbOwner.tf_name:setString(characterConfig.name)

    local fontColor = QIDEA_QUALITY_COLOR[color]
    self._ccbOwner.tf_name:setColor(fontColor)
    self._ccbOwner.tf_name = setShadowByFontColor(self._ccbOwner.tf_name, fontColor)

    self:setSABC()
    
    local avatar = QUIWidgetActorDisplay.new(self._id)
    self._ccbOwner.node_avatar:addChild(avatar)   
    avatar:setScaleX(-1.2)
    avatar:setScaleY(1.2)

    local gradeConfig = QStaticDatabase.sharedDatabase():getGradeByHeroActorLevel(self._id, 0)
    if gradeConfig ~= nil then
        local skillIds = string.split(gradeConfig.soulspirit_dz, ":")
        local skillId = tonumber(skillIds[1])
        local skillInfo = QStaticDatabase.sharedDatabase():getSkillByID(skillId)
        if skillInfo then
            local describe = (skillInfo.name or "").."："..(skillInfo.description or "")
            local skillDesc = q.getSkillMainDesc(describe)
            skillDesc = QColorLabel.removeColorSign(skillDesc)
            self._ccbOwner.tf_desc:setString(skillDesc)
            self:setIconPath(skillInfo.icon)
        end
    end
end 

function QUIDialogSoulSpiritComposeSuccess:setSABC()
    local aptitudeInfo = db:getActorSABC(self._id)
    q.setAptitudeShow(self._ccbOwner, aptitudeInfo.lower)
end

function QUIDialogSoulSpiritComposeSuccess:setIconPath(path)
    if self._skillIcon == nil then
        self._skillIcon = CCSprite:create()
        self._ccbOwner.node_icon:addChild(self._skillIcon)
    end
    if path then
        self._skillIcon:setTexture(CCTextureCache:sharedTextureCache():addImage(path))
    end
end

function QUIDialogSoulSpiritComposeSuccess:viewDidAppear()
    QUIDialogSoulSpiritComposeSuccess.super.viewDidAppear(self)
end

function QUIDialogSoulSpiritComposeSuccess:viewWillDisappear()
    QUIDialogSoulSpiritComposeSuccess.super.viewWillDisappear(self)
end

function QUIDialogSoulSpiritComposeSuccess:_backClickHandler(options)
    if not self._isEnd then return end
    local callback = self._callBack
    self:popSelf()
    if callback then
        callback()
    end
end

return QUIDialogSoulSpiritComposeSuccess