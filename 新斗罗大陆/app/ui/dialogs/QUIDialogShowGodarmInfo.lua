-- @Author: liaoxianbo
-- @Date:   2019-12-30 15:05:19
-- @Last Modified by:   liaoxianbo
-- @Last Modified time: 2020-01-14 21:52:17
local QUIDialog = import("..dialogs.QUIDialog")
local QUIDialogShowGodarmInfo = class("QUIDialogShowGodarmInfo", QUIDialog)
local QUIWidgetActorDisplay = import("..widgets.actorDisplay.QUIWidgetActorDisplay")
local QColorLabel = import("...utils.QColorLabel")
local QNotificationCenter = import("...controllers.QNotificationCenter")
local QTutorialEvent = import("...tutorial.event.QTutorialEvent")
local QRichText = import("...utils.QRichText") 

function QUIDialogShowGodarmInfo:ctor(options)
    local ccbFile = "ccb/Dialog_Weapon_zhanshi_03.ccbi"
    local callBacks = {
    }
    QUIDialogShowGodarmInfo.super.ctor(self, ccbFile, callBacks, options)

    CalculateUIBgSize(self._ccbOwner.node_bg, 1280)

    self._godarmId = options.godarmId
    self._callBack = options.callBack

    self:setHeroInfo()

    self._scheduler = scheduler.performWithDelayGlobal(function()
            QNotificationCenter.sharedNotificationCenter():dispatchEvent({name = QTutorialEvent.EVENT_CALL_HERO_SUCCESS})
        end, 2)
end

function QUIDialogShowGodarmInfo:setHeroInfo()
    local heroInfo = db:getCharacterByID(self._godarmId)
    local sabcInfo = db:getSABCByQuality(heroInfo.aptitude)
    local color = string.upper(sabcInfo.color)
    self._ccbOwner.tf_name:setString(heroInfo.name)

    local fontColor = QIDEA_QUALITY_COLOR[color]
    self._ccbOwner.tf_name:setColor(fontColor)
    self._ccbOwner.tf_name = setShadowByFontColor(self._ccbOwner.tf_name, fontColor)

    local jobIconPath = remote.godarm:getGodarmJobPath(heroInfo.label)
    if jobIconPath then
        self._ccbOwner.sp_godarm_label:setVisible(true)
        QSetDisplaySpriteByPath(self._ccbOwner.sp_godarm_label,jobIconPath)
    end 
    self._ccbOwner.tf_name:setAnchorPoint(ccp(0, 0.5))
    self._ccbOwner.tf_name:setPositionX(self._ccbOwner.sp_godarm_label:getPositionX() + self._ccbOwner.sp_godarm_label:getContentSize().width)
    self:setSABC()
    
    self._avatar = QUIWidgetActorDisplay.new(self._godarmId)
    self._ccbOwner.node_avatar:addChild(self._avatar)   
    self._avatar:setScaleX(-0.9)
    self._avatar:setScaleY(0.9)

    local gradeConfig = db:getGradeByHeroActorLevel(self._godarmId, 0)
    if gradeConfig ~= nil then
        local skillIds = string.split(gradeConfig.god_arm_skill_sz, ":")
        local skillId = tonumber(skillIds[1])
        local skillInfo = db:getSkillByID(skillId)
        if skillInfo then
            local describe = (skillInfo.name or "").."："..(skillInfo.description or "")
            local skillDesc = q.getSkillMainDesc(describe)
            skillDesc = QColorLabel.removeColorSign(skillDesc)
            -- self._ccbOwner.tf_desc:setString(skillDesc)
            local strArray = {} 
            table.insert(strArray,{oType = "img", fileName = "ui/update_godarm/sp_shenqijineng.png"})
            -- table.insert(strArray,{oType = "font", content = skillConfig.name,size = 20,color = COLORS.k})      
            -- local describe = (skillDesc or "")
            local strArr  = string.split(skillDesc,"\n") or {}
            for i, v in pairs(strArr) do
                table.insert(strArray,{oType = "font", content = v,size = 20,color = COLORS.b})
            end
            local richText = QRichText.new(strArray, 488, {stringType = 1, defaultColor = COLORS.b, defaultSize = 20,lineSpacing=4})
            richText:setAnchorPoint(ccp(0, 1))
            self._ccbOwner.node_desc:addChild(richText)


            self._ccbOwner.tf_desc:setVisible(false)
            self:setIconPath(skillInfo.icon)
        end
    end
end 

function QUIDialogShowGodarmInfo:setSABC()
    local aptitudeInfo = db:getActorSABC(self._godarmId)
    q.setAptitudeShow(self._ccbOwner, aptitudeInfo.lower)
end

function QUIDialogShowGodarmInfo:setIconPath(path)
    if self._skillIcon == nil then
        self._skillIcon = CCSprite:create()
        self._skillIcon:setScale(1/0.8)
        self._ccbOwner.node_icon:addChild(self._skillIcon)
    end
    self._skillIcon:setTexture(CCTextureCache:sharedTextureCache():addImage(path))
end

function QUIDialogShowGodarmInfo:viewDidAppear()
    QUIDialogShowGodarmInfo.super.viewDidAppear(self)
end

function QUIDialogShowGodarmInfo:viewWillDisappear()
    QUIDialogShowGodarmInfo.super.viewWillDisappear(self)

    if self._scheduler then
        scheduler.unscheduleGlobal(self._scheduler)
        self._scheduler = nil
    end

    if self._effectScheduler then
        scheduler.unscheduleGlobal(self._effectScheduler)
        self._effectScheduler = nil
    end
end

function QUIDialogShowGodarmInfo:_backClickHandler(options)
    local callback = self._callBack
    self:popSelf()
    if callback then
        callback()
    end
end

return QUIDialogShowGodarmInfo
