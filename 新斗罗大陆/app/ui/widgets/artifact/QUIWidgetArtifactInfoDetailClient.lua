-- 
-- zxs
-- 武魂真身详细界面
-- 
local QUIWidget = import("..QUIWidget")
local QUIWidgetArtifactInfoDetailClient = class("QUIWidgetArtifactInfoDetailClient", QUIWidget)

local QNotificationCenter = import("....controllers.QNotificationCenter")
local QNavigationController = import("....controllers.QNavigationController")
local QScrollView = import("....views.QScrollView")
local QUIViewController = import("....ui.QUIViewController")
local QUIWidgetActorDisplay = import("...widgets.actorDisplay.QUIWidgetActorDisplay")
local QSkeletonViewController = import("....controllers.QSkeletonViewController")
local QActorProp = import("....models.QActorProp")
local QColorLabel = import("....utils.QColorLabel") 
local QRichText = import("....utils.QRichText") 
local QUIWidgetFcaAnimation = import("..actorDisplay.QUIWidgetFcaAnimation")

function QUIWidgetArtifactInfoDetailClient:ctor(ccbFile,callBacks,options)
    local ccbFile = "ccb/Widget_artifact_info_client.ccbi"
    local callBacks = {
        {ccbCallbackName = "onTriggerSkillInfo", callback = handler(self, self._onTriggerSkillInfo)},
        {ccbCallbackName = "onTriggerUnwear", callback = handler(self, self._onTriggerUnwear)},
        {ccbCallbackName = "onTriggerMaster", callback = handler(self, self._onTriggerMaster)},
    }
    QUIWidgetArtifactInfoDetailClient.super.ctor(self, ccbFile, callBacks, options)

    cc.GameObject.extend(self)
    self:addComponent("components.behavior.EventProtocol"):exportMethods()

    self._width = 280
    self._offsetY = 0

    self._lineHeight = 26
    q.setButtonEnableShadow(self._ccbOwner.btn_reset)
end

function QUIWidgetArtifactInfoDetailClient:setInfo(actorId)
    self._offsetY = 0
    self._actorId = actorId
    self._artifactInfo = remote.herosUtil:getHeroByID(actorId).artifact
    self._artifactId = remote.artifact:getArtiactByActorId(actorId)

    -- 未合成
    self._ccbOwner.node_empty:setVisible(false)
    self._ccbOwner.node_info:setVisible(false)
    self._ccbOwner.node_jieshao:setVisible(false)
    if not self._artifactInfo then
        self._ccbOwner.node_empty:setVisible(true)
        self._ccbOwner.node_prop:setVisible(false)
        self._ccbOwner.node_super:setVisible(false)
        self:skillInfo(true)
    else
        self._ccbOwner.node_info:setVisible(true)
        self:setDetailInfo()
        self:skillInfo()
        self:setPropInfo()
        self:superInfo()
        self:setIntroInfo()
    end

    self._offsetY = self._offsetY + 290
    self:setContentSize(CCSize(550, self._offsetY))
end

function QUIWidgetArtifactInfoDetailClient:setDetailInfo()
    self._artifactConfig = db:getItemByID(self._artifactId)
    self._ccbOwner.tf_name:setString(self._artifactConfig.name)

    local fontColor = remote.artifact:getColorByActorId(self._actorId)
    self._ccbOwner.tf_name:setColor(fontColor)
    setShadowByFontColor(self._ccbOwner.tf_name, fontColor)
    
    self._ccbOwner.node_artifact:removeAllChildren()
    local heroInfo = db:getCharacterByID(self._actorId)
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
                artifact:setPosition(ccp(tonumber(tbl[1]), tonumber(tbl[2])))
            end
        end
        self._ccbOwner.node_artifact:addChild(artifact)
    end

    local grade = self._artifactInfo.artifactBreakthrough
    for i = 1, 5 do
        self._ccbOwner["star" .. i]:setVisible(false)
    end
    local starNum, iconPath = remote.herosUtil:getStarIconByStarNum(grade) 
    if starNum == nil then return end
    for i = 1, starNum do
        local displayFrame = QSpriteFrameByPath(iconPath)
        if displayFrame then
            self._ccbOwner["star"..i]:setDisplayFrame(displayFrame)
            self._ccbOwner["star"..i]:setVisible(true)
        end
    end

    self:setSABC()
end

function QUIWidgetArtifactInfoDetailClient:setSABC()
    local aptitudeInfo = db:getActorSABC(self._actorId)
    q.setAptitudeShow(self._ccbOwner, aptitudeInfo.lower)
end

function QUIWidgetArtifactInfoDetailClient:setPropInfo()
    self._ccbOwner.node_prop:setPositionY(-self._offsetY)
    self._ccbOwner.node_prop:setVisible(true)
    local height = 150

    local artifactProp = remote.artifact:getArtifactPropById(self._actorId)
    local prop = remote.artifact:getUIPropInfo(artifactProp, true)
    for i = 1, 6 do
        if prop[i] ~= nil then
            self._ccbOwner["tf_prop_name"..i]:setString(prop[i].name or "")
            self._ccbOwner["tf_prop_value"..i]:setString("+"..(prop[i].value or "0"))
        else
            self._ccbOwner["tf_prop_name"..i]:setString("")
            self._ccbOwner["tf_prop_value"..i]:setString("")
        end
    end

    self._offsetY = self._offsetY+height
end

function QUIWidgetArtifactInfoDetailClient:skillInfo()
    local height = 50
    self._ccbOwner.node_skill:setPositionY(-self._offsetY)
    self._ccbOwner.node_skill:setVisible(true)
    self._ccbOwner.node_skill1:setVisible(true)
    self._ccbOwner.node_skill2:setVisible(false)

    local height1 = 0
    local skillConfigs = remote.artifact:getSkillByArtifactId(self._artifactId) or {}
    for i, skillConfig in pairs(skillConfigs) do
        local skillConfig = db:getSkillByID(skillConfig.skill_id)
        if skillConfig ~= nil then
            local noLearn = "(未学习) "
            if self._artifactInfo and self._artifactInfo.artifactSkillList then
                noLearn = ""
            end
            local describe = "##e"..skillConfig.name.."："..noLearn.."##n"..(skillConfig.description or "")
            describe = QColorLabel.replaceColorSign(describe)
            local strArr  = string.split(describe,"\n") or {}
            for i, v in pairs(strArr) do
                local richText = QRichText.new(v, 500, {stringType = 1, defaultColor = GAME_COLOR_LIGHT.normal, defaultSize = 22})
                richText:setAnchorPoint(ccp(0, 1))
                richText:setPositionY(-height1)
                self._ccbOwner.node_skill1:addChild(richText)
                height1 = height1 + richText:getContentSize().height
            end
        end
        height = height + height1
        break
    end

    self._offsetY = self._offsetY+height
end

function QUIWidgetArtifactInfoDetailClient:superInfo()
    local height = 160
    self._ccbOwner.node_super:setPositionY(-self._offsetY)
    self._ccbOwner.node_super:setVisible(true)
    self._ccbOwner.super_desc1:setString("")
    self._ccbOwner.super_desc2:setString("")

    local heroInfo = db:getCharacterByID(self._actorId)
    local masterInfos, masterLevel = db:getArtifactMasterInfo(heroInfo.aptitude, (self._artifactInfo.artifactLevel or 0))
    masterLevel = masterLevel or 0
    local isHaveMaster = true
    if masterLevel == 0 then 
        isHaveMaster = false
    end
    local artifactStrengthMaster1 = db:getArtifactMasterInfoByLevel(heroInfo.aptitude, masterLevel)
    if artifactStrengthMaster1 ~= nil then
        local name,value  = self:findMasterProp(artifactStrengthMaster1)
        if isHaveMaster == true then
            self._ccbOwner.super_desc1:setString("【"..artifactStrengthMaster1.master_name.."】"..name.."+"..value.."（等级提升至"..artifactStrengthMaster1.condition.."级）")
            self._ccbOwner.super_desc1:setColor(GAME_COLOR_LIGHT.stress)
        else
            self._ccbOwner.super_desc1:setColor(GAME_COLOR_LIGHT.notactive)
        end
    else
        self._ccbOwner.super_desc1:setString("")
    end

    local artifactStrengthMaster2 = db:getArtifactMasterInfoByLevel(heroInfo.aptitude, masterLevel+1)
    if artifactStrengthMaster2 ~= nil then
        local name,value  = self:findMasterProp(artifactStrengthMaster2)
        self._ccbOwner.super_desc2:setColor(GAME_COLOR_LIGHT.notactive)
        self._ccbOwner.super_desc2:setString("【"..artifactStrengthMaster2.master_name.."】"..name.."+"..value.."（等级提升至"..artifactStrengthMaster2.condition.."级）")
        self._ccbOwner.super_name2:setVisible(true)
    else
        self._ccbOwner.super_desc2:setString("")
        self._ccbOwner.super_name2:setVisible(false)
    end

    self._offsetY = self._offsetY+height
end

function QUIWidgetArtifactInfoDetailClient:setIntroInfo()
    local height = 50
    self._ccbOwner.node_jieshao:setPositionY(-self._offsetY)
    local desc = self._artifactConfig.brief or ""
    self._ccbOwner.tf_desc:setString(desc)

    local skillLength = q.wordLen(desc, 22, 22)
    local count = math.ceil(skillLength/self._width)
    height = height + count*self._lineHeight
    self._offsetY = self._offsetY+height
end

function QUIWidgetArtifactInfoDetailClient:setUnwearButtonStated(stated)
    if stated == nil then return end

    self._ccbOwner.node_reset:setVisible(stated)
end

function QUIWidgetArtifactInfoDetailClient:findMasterProp(masterInfo)
    for name,filed in pairs(QActorProp._field) do
        if masterInfo[name] ~= nil and masterInfo[name] > 0 then
            local value = masterInfo[name]
            if filed.isPercent == true then
                value = string.format("%.1f%%",value*100)
            end
            return (filed.uiName or filed.name), value
        end
    end
    return "",""
end

function QUIWidgetArtifactInfoDetailClient:_onTriggerSkillInfo(event)
    if q.buttonEventShadow(event, self._ccbOwner.btn_skillInfo) == false then return end
    app.sound:playSound("common_small")
    app:getNavigationManager():pushViewController(app.middleLayer, {uiType = QUIViewController.TYPE_DIALOG, uiClass = "QUIDialogArtifactSkill", 
        options = {actorId = self._actorId}})
end

function QUIWidgetArtifactInfoDetailClient:_onTriggerUnwear(event)
    -- if q.buttonEventShadow(event, self._ccbOwner.btn_reset) == false then return end
    app.sound:playSound("common_small")
    local token = db:getConfiguration().ARTIFACT_RECYCLE.value or 0
    local heroInfo = db:getCharacterByID(self._actorId)
    -- local content = string.format("##n是否消耗##l%d钻石##n，摘除##l%s##n的武魂真身？摘除后，返还全部养成材料。", token, heroInfo.name ) 
    local content = string.format("##n摘除##l%s##n的武魂真身？摘除后，返还全部养成材料。", heroInfo.name ) 
    local sucessCallback = function()
        remote.artifact:artifactRecoverRequest(self._actorId, function(data)
                -- 展示奖励页面
                local awards = {}
                local tbl = string.split(data.artifactRecoverResponse.resultItemAndSource or "", ";")
                for _, awardStr in pairs(tbl or {}) do
                    if awardStr ~= "" then
                        local id, typeName, count = remote.rewardRecover:getItemBoxParaMetet(awardStr)
                        table.insert(awards, {id = id, count = count, typeName = typeName})
                    end
                end
                if next(awards) then
                    local dialog = app:getNavigationManager():pushViewController(app.middleLayer, {uiType=QUIViewController.TYPE_DIALOG, uiClass="QUIDialogEnchantResetAwardsAlert",
                        options = {awards = awards}},{isPopCurrentDialog = false} )
                    dialog:setTitle("武魂真身摘除返还以下道具")
                end
            end)
    end

    app:getNavigationManager():pushViewController(app.middleLayer, {uiType = QUIViewController.TYPE_DIALOG, uiClass = "QUIDialogArifactSkillReset", 
    options = {title = "摘除真身", contentStr = content, costToken = token,callback = function (isReset)
        if isReset == true then
            sucessCallback()
        end
    end}})

end

function QUIWidgetArtifactInfoDetailClient:_onTriggerMaster(event)
    if q.buttonEventShadow(event, self._ccbOwner.btn_genre) == false then return end
    app.sound:playSound("common_small")
    app:getNavigationManager():pushViewController(app.middleLayer, {uiType = QUIViewController.TYPE_DIALOG, uiClass = "QUIDialogArtifactTalent", 
        options = {actorId = self._actorId}})
end

return QUIWidgetArtifactInfoDetailClient