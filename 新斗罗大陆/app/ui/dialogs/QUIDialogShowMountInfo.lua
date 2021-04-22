--
-- Author: wkwang
-- Date: 2014-08-07 12:34:26
--
local QUIDialog = import(".QUIDialog")
local QUIDialogShowMountInfo = class("QUIDialogShowMountInfo", QUIDialog)
local QUIWidgetActorDisplay = import("..widgets.actorDisplay.QUIWidgetActorDisplay")
local QColorLabel = import("...utils.QColorLabel")
local QNotificationCenter = import("...controllers.QNotificationCenter")
local QTutorialEvent = import("...tutorial.event.QTutorialEvent")


function QUIDialogShowMountInfo:ctor(options)
    local ccbFile = "ccb/Dialog_Weapon_zhanshi_03.ccbi"
    local callBacks = {
    }
    QUIDialogShowMountInfo.super.ctor(self, ccbFile, callBacks, options)

    self._actorId = options.actorId
    self._callBack = options.callBack
    CalculateUIBgSize(self._ccbOwner.node_bg,1280)

    self:setHeroInfo()

    self._scheduler = scheduler.performWithDelayGlobal(function()
            QNotificationCenter.sharedNotificationCenter():dispatchEvent({name = QTutorialEvent.EVENT_CALL_HERO_SUCCESS})
        end, 2)
end

function QUIDialogShowMountInfo:setHeroInfo()
    local heroInfo = db:getCharacterByID(self._actorId)
    local color = remote.mount:getColorByMountId(self._actorId)
    self._ccbOwner.tf_name:setString(heroInfo.name)

    local fontColor = QIDEA_QUALITY_COLOR[color]
    self._ccbOwner.tf_name:setColor(fontColor)
    self._ccbOwner.tf_name = setShadowByFontColor(self._ccbOwner.tf_name, fontColor)

    self:setSABC()
    
    self._avatar = QUIWidgetActorDisplay.new(self._actorId)
    self._ccbOwner.node_avatar:addChild(self._avatar)   
    self._avatar:setScaleX(-1.2)
    self._avatar:setScaleY(1.2)
    self._effectScheduler = scheduler.performWithDelayGlobal(function()
            if self._avatar then
                local actorView = self._avatar:getActor():getSkeletonView()
                actorView:playAnimation("variant", false)
                actorView:appendAnimation("stand", true)
            end
        end, 1.4)

    if heroInfo.zuoqi_pj then
        self._ccbOwner.node_item:setVisible(false)   
        self._ccbOwner.tf_desc:setString("配件暗器不能装备于魂师上，无主力和援助效果，只能\n用于SS暗器的配件")
        self._ccbOwner.tf_desc:setPositionX(self._ccbOwner.tf_desc:getPositionX() - 45)
    else
        local gradeConfig = db:getGradeByHeroActorLevel(self._actorId, 0)
        if gradeConfig ~= nil then
            local skillIds = string.split(gradeConfig.zuoqi_skill_ms, ";")
            local skillId = tonumber(skillIds[1])
            local skillInfo = db:getSkillByID(skillId)
            if skillInfo then
                local describe = (skillInfo.name or "").."："..(skillInfo.description or "")
                local skillDesc = q.getSkillMainDesc(describe)
                skillDesc = QColorLabel.removeColorSign(skillDesc)
                self._ccbOwner.tf_desc:setString(skillDesc)
                self:setIconPath(skillInfo.icon)
            end
        end
    end

end 

function QUIDialogShowMountInfo:setSABC()
    local aptitudeInfo = db:getActorSABC(self._actorId)
    q.setAptitudeShow(self._ccbOwner, aptitudeInfo.lower)
end

function QUIDialogShowMountInfo:setIconPath(path)
    if self._skillIcon == nil then
        self._skillIcon = CCSprite:create()
        self._ccbOwner.node_icon:addChild(self._skillIcon)
    end
    self._skillIcon:setTexture(CCTextureCache:sharedTextureCache():addImage(path))
end

function QUIDialogShowMountInfo:viewDidAppear()
    QUIDialogShowMountInfo.super.viewDidAppear(self)
end

function QUIDialogShowMountInfo:viewWillDisappear()
    QUIDialogShowMountInfo.super.viewWillDisappear(self)

    if self._scheduler then
        scheduler.unscheduleGlobal(self._scheduler)
        self._scheduler = nil
    end

    if self._effectScheduler then
        scheduler.unscheduleGlobal(self._effectScheduler)
        self._effectScheduler = nil
    end
end

function QUIDialogShowMountInfo:_backClickHandler(options)
    local callback = self._callBack
    self:popSelf()
    if callback then
        callback()
    end
end

return QUIDialogShowMountInfo