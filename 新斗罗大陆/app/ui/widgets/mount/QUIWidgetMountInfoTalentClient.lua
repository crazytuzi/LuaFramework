-- @Author: zhouxiaoshu
-- @Date:   2019-10-21 15:54:33
-- @Last Modified by:   liaoxianbo
-- @Last Modified time: 2020-10-31 14:30:50
local QUIWidget = import("..QUIWidget")
local QUIWidgetMountInfoTalentClient = class("QUIWidgetMountInfoTalentClient", QUIWidget)

local QNotificationCenter = import("....controllers.QNotificationCenter")
local QNavigationController = import("....controllers.QNavigationController")
local QScrollView = import("....views.QScrollView")
local QUIViewController = import("....ui.QUIViewController")
local QUIWidgetActorDisplay = import("...widgets.actorDisplay.QUIWidgetActorDisplay")
local QActorProp = import("....models.QActorProp")
local QRichText = import("....utils.QRichText") 
local QColorLabel = import("....utils.QColorLabel")

function QUIWidgetMountInfoTalentClient:ctor(ccbFile,callBacks,options)
    local ccbFile = "ccb/Widget_Weapon_jieshao_04.ccbi"
    local callBacks = {
        {ccbCallbackName = "onTriggerSkillInfo", callback = handler(self, self._onTriggerSkillInfo)},
        {ccbCallbackName = "onTriggerDressSkillInfo", callback = handler(self, self._onTriggerDressSkillInfo)},
        {ccbCallbackName = "onTriggerMaster", callback = handler(self, self._onTriggerMaster)},
    }
    QUIWidgetMountInfoTalentClient.super.ctor(self, ccbFile, callBacks, options)

    cc.GameObject.extend(self)
    self:addComponent("components.behavior.EventProtocol"):exportMethods()

    self._width = 280
    self._offsetY = 0

    self._lineHeight = 26

    self._bgRoleSize = self._ccbOwner.s9s_role_bg:getContentSize()
    self._tfRoleY1 = self._ccbOwner.tf_role1:getPositionY()
    self._tfRoleY2 = self._ccbOwner.tf_role2:getPositionY()
    self._bgWith = self._ccbOwner.sp_bg:getContentSize().width
    self._bgHeight = self._ccbOwner.sp_bg:getContentSize().height
    self._ccbOwner.node_role:setVisible(false)
    self._ccbOwner.sp_guang_ss:setVisible(false)
    self._ccbOwner.node_aptitude:setPositionY(40)
end

function QUIWidgetMountInfoTalentClient:setInfo(mountId, showSSMountEffect)
    self._ccbOwner.node_skill:setVisible(false)
    self._ccbOwner.node_dress_skill:setVisible(false)
    self._ccbOwner.node_prop:setVisible(false)
    self._ccbOwner.node_title:setVisible(false)
    self._ccbOwner.node_star:setVisible(false)

    self._offsetY = 0

    self._mountId = mountId
    self._showSSMountEffect = showSSMountEffect

    self._mountInfo = remote.mount:getMountById(mountId)

    self:setDetailInfo()

    self:setDressSkill()

    self:setPropInfo()

    if self._offsetY > self._bgHeight then
        self._ccbOwner.sp_bg:setContentSize(CCSize(self._bgWith, self._offsetY))
    end
    self._offsetY = self._offsetY + 290
end

function QUIWidgetMountInfoTalentClient:setDetailInfo()
    self._mountConfig = db:getCharacterByID(self._mountId)

    local reformLevel = self._mountInfo.reformLevel or 0
    local nameStr = self._mountConfig.name or ""
    if reformLevel > 0 then
        nameStr = nameStr.."+"..reformLevel
    end
    
    if self._mountConfig.aptitude == APTITUDE.SSR then
        self._ccbOwner.tf_name1:setPositionX(300)
    end

    self._ccbOwner.tf_name1:setString(nameStr)

    local fontColor = QIDEA_QUALITY_COLOR[remote.mount:getColorByMountId(self._mountId)] or COLORS.b
    self._ccbOwner.tf_name1:setColor(fontColor)
    self._ccbOwner.tf_name1 = setShadowByFontColor(self._ccbOwner.tf_name1, fontColor)
    
    self._ccbOwner.node_mount:removeAllChildren()
    local avatar = QUIWidgetActorDisplay.new(self._mountId)
    if self._mountConfig.aptitude == APTITUDE.SSR then
        avatar:setScaleX(1)
    else
        avatar:setScaleX(-1)
    end
    
    self._ccbOwner.node_mount:addChild(avatar)
    
    if self._showSSMountEffect then 
        local actorView = avatar:getActor():getSkeletonView()
        actorView:playAnimation("variant", false)
        actorView:appendAnimation("stand", true)
    end
    
    self._ccbOwner.node_effect:setVisible(false)
    if self._mountInfo.wearZuoqiInfo then 
        avatar:setPositionX(-120)
        local dressAvatar = QUIWidgetActorDisplay.new(self._mountInfo.wearZuoqiInfo.zuoqiId)
        dressAvatar:setPositionX(130)
        dressAvatar:setScaleX(-0.5)
        dressAvatar:setScaleY(0.5)
        self._ccbOwner.node_effect:setVisible(true)
        self._ccbOwner.node_mount:addChild(dressAvatar)
    end
    
    local grade = self._mountInfo.grade + 1
    for i = 1, 5 do
        if i <= grade then
            self._ccbOwner["star"..i]:setVisible(true)
        else
            self._ccbOwner["star"..i]:setVisible(false)
        end
    end

    local roleStr = self._mountConfig.role_definition or ""
    local roleTextList = string.split(roleStr, ";")
    self._ccbOwner.tf_role1:setString(roleTextList[1])
    self._ccbOwner.tf_role2:setString(roleTextList[2] or "")

    local tempH1 = self._ccbOwner.tf_role1:getContentSize().height
    local tempH2 = self._ccbOwner.tf_role2:getContentSize().height
    local tempH3 = 6 -- 兩段文字時間的間隔
    if tempH2 > 0 then
        self._ccbOwner.tf_role1:setPositionY(self._tfRoleY1 + tempH2/2 + tempH3/2)
        self._ccbOwner.tf_role2:setPositionY(self._tfRoleY1 - tempH1/2 - tempH3/2)
    end
    local tempH = tempH1 + (tempH2 == 0 and 0 or tempH2 + tempH3)
    local s9sRoleBgH = tempH > 92 and tempH + 25 or self._bgRoleSize.height
    self._ccbOwner.s9s_role_bg:setPreferredSize(CCSize(self._bgRoleSize.width, s9sRoleBgH))

    self:setSABC()
end

function QUIWidgetMountInfoTalentClient:setSABC()
    local aptitudeInfo = db:getActorSABC(self._mountId)
    q.setAptitudeShow(self._ccbOwner, aptitudeInfo.lower)

    self._ccbOwner["node_bg_b"]:setVisible(false)
    self._ccbOwner["node_bg_a"]:setVisible(false)
    self._ccbOwner["node_bg_a+"]:setVisible(false)
    self._ccbOwner["node_bg_s"]:setVisible(false)
    self._ccbOwner["node_bg_ss"]:setVisible(false)
    self._ccbOwner["node_bg_ss+"]:setVisible(false)
    self._ccbOwner["node_bg_"..aptitudeInfo.lower]:setVisible(true)
end

function QUIWidgetMountInfoTalentClient:setPropInfo()
    local wearZuoqiInfo = self._mountInfo.wearZuoqiInfo
    if not wearZuoqiInfo then
        return
    end

    self._ccbOwner.node_prop:setPositionY(-self._offsetY)
    self._ccbOwner.node_prop:setVisible(true)
    self._ccbOwner.node_main_prop:setVisible(false)
    self._ccbOwner.node_grave_prop:setVisible(false)
    self._ccbOwner.node_reform_prop:setVisible(false)
    self._ccbOwner.node_dress_prop:setVisible(true)
    self._ccbOwner.node_dress_prop:setPositionY(self._ccbOwner.node_main_prop:getPositionY())

    local height = 230
    local mountProp = remote.mount:getMountPropById(wearZuoqiInfo.zuoqiId)
    local props = self:getUIPropInfo(mountProp:getTotalProp())
    local i = 1
    for key, prop in pairs(props) do
        local value = prop.value 
        if prop.isPercent then
            value = (value*100).."%"
        end
        local tfNode = q.createPropTextNode(prop.name , value,nil,22)
        self._ccbOwner.node_dress_prop_richText:addChild(tfNode)
        if i%2 == 0 then
            tfNode:setPosition(ccp(-10,-math.floor((i-1)/2)*30))
        else
            tfNode:setPosition(ccp(240,-math.floor((i-1)/2)*30))
            -- height = height + 30
        end
        i = i + 1
    end

    self._offsetY = self._offsetY+height
end

function QUIWidgetMountInfoTalentClient:getUIPropInfo(props)
    local prop = {}
    local index = 1
    if props.attack_percent then
        prop[index] = {}
        prop[index].value = (props.attack_percent*100).."%"
        prop[index].name = "攻    击"
        index = index + 1
    end
    if props.hp_percent then
        prop[index] = {}
        prop[index].value = (props.hp_percent*100).."%"
        prop[index].name = "生    命"
        index = index + 1
    end
    if props.armor_physical_percent then
        prop[index] = {}
        prop[index].value = (props.armor_physical_percent*100).."%"
        prop[index].name = "物    防"
        index = index + 1
    end
    if props.armor_magic_percent then
        prop[index] = {}
        prop[index].value = (props.armor_magic_percent*100).."%"
        prop[index].name = "法    防"
        index = index + 1
    end

    if props.attack_value then
        prop[index] = {}
        prop[index].value = math.floor(props.attack_value)
        prop[index].name = "攻    击"
        index = index + 1
    end
    if props.hp_value then
        prop[index] = {}
        prop[index].value = math.floor(props.hp_value)
        prop[index].name = "生    命"
        index = index + 1
    end
    if props.armor_physical then
        prop[index] = {}
        prop[index].value = math.floor(props.armor_physical)
        prop[index].name = "物    防"
        index = index + 1
    end
    if props.armor_magic then
        prop[index] = {}
        prop[index].value = math.floor(props.armor_magic)
        prop[index].name = "法    防"
        index = index + 1
    end

    return prop
end

function QUIWidgetMountInfoTalentClient:setDressSkill()
    local height = 70
    self._ccbOwner.node_dress_skill:setPositionY(-self._offsetY)
    self._ccbOwner.node_dress_skill:setVisible(true)

    local grade = 0
    local skillColor = GAME_COLOR_LIGHT.notactive
    if self._mountInfo.wearZuoqiInfo then
        skillColor = GAME_COLOR_LIGHT.normal
        grade = self._mountInfo.wearZuoqiInfo.grade
    end
    local gradeConfig = db:getGradeByHeroActorLevel(self._mountId, grade)
    if gradeConfig then
        local skillIds = string.split(gradeConfig.zuoqi_skill_xs, ":")
        local skillConfig1 = db:getSkillByID(tonumber(skillIds[1]))
        local height1, height2 = 0, 0
        if skillConfig1 ~= nil then
            local describe = "##e"..skillConfig1.name.."：##n"..(skillConfig1.description or "")
            local strArr  = string.split(describe,"\n") or {}
            for i, v in pairs(strArr) do
                local describe = QColorLabel.replaceColorSign(v or "", false)
                local richText = QRichText.new(describe, 500, {stringType = 1, defaultColor = skillColor, defaultSize = 22})
                richText:setAnchorPoint(ccp(0, 1))
                richText:setPositionY(-height1)
                self._ccbOwner.node_dress_desc:addChild(richText)
                height1 = height1 + richText:getContentSize().height
            end
            self._ccbOwner.node_dress_desc:setVisible(true)
        end
        height = height + height1 + height2
    end
    self._ccbOwner.tf_dress_skill_tip:setPositionY(-(height-20))

    self._offsetY = self._offsetY+height
end

function QUIWidgetMountInfoTalentClient:_onTriggerSkillInfo(event)
    if q.buttonEventShadow(event, self._ccbOwner.btn_skill_info) == false then return end
    app.sound:playSound("common_small")
    app:getNavigationManager():pushViewController(app.middleLayer, {uiType = QUIViewController.TYPE_DIALOG, uiClass = "QUIDialogMountSkill", 
        options = {mountId = self._mountId}})
end

function QUIWidgetMountInfoTalentClient:_onTriggerDressSkillInfo(event)
    if q.buttonEventShadow(event, self._ccbOwner.btn_dress_skill_info) == false then return end
    app.sound:playSound("common_small")

    local grade = -1
    if self._mountInfo.wearZuoqiInfo then
        grade = self._mountInfo.wearZuoqiInfo.grade
    end
    app:getNavigationManager():pushViewController(app.middleLayer, {uiType = QUIViewController.TYPE_DIALOG, uiClass = "QUIDialogMountSkill", 
        options = {mountId = self._mountId, isDress = true, dressGrade = grade}})
end

function QUIWidgetMountInfoTalentClient:_onTriggerMaster(event)
    if q.buttonEventShadow(event, self._ccbOwner.btn_master_info) == false then return end
    app.sound:playSound("common_menu")

    local talents = remote.mount:getMountStrengthMaster(self._mountInfo.zuoqiId)

    app:getNavigationManager():pushViewController(app.middleLayer, {uiType = QUIViewController.TYPE_DIALOG, uiClass = "QUIDialogMountTalent", 
        options = {talents = talents,compareLevel = self._mountInfo.enhanceLevel}})

end

function QUIWidgetMountInfoTalentClient:getContentSize()
    local size = CCSize(550, self._offsetY)
    return size
end

return QUIWidgetMountInfoTalentClient
