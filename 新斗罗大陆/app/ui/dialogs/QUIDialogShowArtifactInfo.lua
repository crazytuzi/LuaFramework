--
-- zxs
-- 武魂真身激活
--
local QUIDialog = import(".QUIDialog")
local QUIDialogShowArtifactInfo = class("QUIDialogShowArtifactInfo", QUIDialog)
local QUIWidgetHeroInformation = import("..widgets.QUIWidgetHeroInformation")
local QColorLabel = import("...utils.QColorLabel")
local QNotificationCenter = import("...controllers.QNotificationCenter")
local QTutorialEvent = import("...tutorial.event.QTutorialEvent")
local QUIWidgetArtifactSkill = import("..widgets.artifact.QUIWidgetArtifactSkill")
local QUIWidgetFcaAnimation = import("..widgets.actorDisplay.QUIWidgetFcaAnimation")
local QRichText = import("...utils.QRichText")

function QUIDialogShowArtifactInfo:ctor(options)
    local ccbFile = "ccb/Dialog_artifact_juexing.ccbi"
    local callBacks = {
    }
    QUIDialogShowArtifactInfo.super.ctor(self, ccbFile, callBacks, options)
    CalculateUIBgSize(self._ccbOwner.node_bg, 1280)

    self._actorId = options.actorId
    self._callBack = options.callBack

    self:setHeroInfo()

    self._isEnd = false
    scheduler.performWithDelayGlobal(function()
            self._isEnd = true
        end, 2)
end

function QUIDialogShowArtifactInfo:setHeroInfo()
    local heroInfo = db:getCharacterByID(self._actorId)
    local heros = remote.herosUtil:getHeroByID(self._actorId)
    local color = remote.mount:getColorByMountId(self._actorId)
    self._ccbOwner.tf_name:setString(heroInfo.name)

    local fontColor = QIDEA_QUALITY_COLOR[color]
    self._ccbOwner.tf_name:setColor(fontColor)
    setShadowByFontColor(self._ccbOwner.tf_name, fontColor)
    
    local avatar = QUIWidgetHeroInformation.new()
    self._ccbOwner.node_avatar:addChild(avatar)
    avatar:setAvatarByHeroInfo({skinId = heros.skinId}, self._actorId, 1.1)
    avatar:setNameVisible(false)
    avatar:setStarVisible(false)
    --avatar:avatarPlayAnimation(ANIMATION_EFFECT.VICTORY, true)

    -- 真身动画
    if heroInfo.backSoulFile then
        local fcaFile = heroInfo.backSoulFile
        local artifact = QUIWidgetFcaAnimation.new(fcaFile, "actor")
        if artifact:getSkeletonView().isFca then
            artifact:setScale(0.37)
        else
            artifact:getSkeletonView():flipActor()
            artifact:attachEffectToDummy(heroInfo.backSoulShowEffect)
            if heroInfo.backSoulFile_xy then
                local tbl = string.split(heroInfo.backSoulFile_xy,",")
                artifact:setPosition(ccp(tonumber(tbl[1]), tonumber(tbl[2]) - 35))
            end
        end
        self._ccbOwner.node_artifact:addChild(artifact)
    end

    local skillConfigs = remote.artifact:getSkillByArtifactId(heroInfo.artifact_id)
    if skillConfigs and skillConfigs[1] then
        local skill = {}
        skill.skill_id = skillConfigs[1].skill_id
        local skillBox = QUIWidgetArtifactSkill.new()
        skillBox:setSkill(skill)
        skillBox:setName("")
        self._ccbOwner.node_icon:addChild(skillBox)

        local skillInfo = db:getSkillByID(skillConfigs[1].skill_id)
        local skillDesc = q.getSkillMainDesc(skillInfo.description or "")
        local describe = "##w"..skillInfo.name.."：(可学习) ##j"..skillDesc
        local strArr  = string.split(describe,"\n") or {}
        local height = 0
        for i, v in pairs(strArr) do
            v = QColorLabel.replaceColorSign(v or "", true)
            local richText = QRichText.new(v, 488, {stringType = 1, defaultColor = GAME_COLOR_LIGHT.normal, defaultSize = 20}) --GAME_COLOR_LIGHT.normal
            richText:setAnchorPoint(ccp(0, 1))
            richText:setPositionY(-height)
            self._ccbOwner.node_desc:addChild(richText)
            height = height + richText:getContentSize().height
        end
        self._ccbOwner.tf_desc:setString("")
    end

    self._ccbOwner.tf_hero_desc:setString(heroInfo.label or "")
    self._ccbOwner.tf_award_title1:setString(heroInfo.title or "")
    self._ccbOwner.tf_award_title2:setString(heroInfo.title or "")

    --self:setSABC()
end 

function QUIDialogShowArtifactInfo:setSABC()
    local aptitudeInfo = db:getActorSABC(self._actorId)
    q.setAptitudeShow(self._ccbOwner, aptitudeInfo.lower)
end

function QUIDialogShowArtifactInfo:_backClickHandler(options)
    if self._isEnd then
        local callback = self._callBack
        self:popSelf()
        if callback then
            callback()
        end
    end
end

return QUIDialogShowArtifactInfo