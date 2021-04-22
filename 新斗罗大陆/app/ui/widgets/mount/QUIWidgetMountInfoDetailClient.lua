-- @Author: zhouxiaoshu
-- @Date:   2019-10-21 15:54:33
-- @Last Modified by:   liaoxianbo
-- @Last Modified time: 2020-10-31 17:10:04
local QUIWidget = import("..QUIWidget")
local QUIWidgetMountInfoDetailClient = class("QUIWidgetMountInfoDetailClient", QUIWidget)

local QNotificationCenter = import("....controllers.QNotificationCenter")
local QNavigationController = import("....controllers.QNavigationController")
local QScrollView = import("....views.QScrollView")
local QUIViewController = import("....ui.QUIViewController")
local QUIWidgetActorDisplay = import("...widgets.actorDisplay.QUIWidgetActorDisplay")
local QActorProp = import("....models.QActorProp")
local QRichText = import("....utils.QRichText") 
local QColorLabel = import("....utils.QColorLabel")

function QUIWidgetMountInfoDetailClient:ctor(ccbFile,callBacks,options)
    local ccbFile = "ccb/Widget_Weapon_jieshao_04.ccbi"
    local callBacks = {
        {ccbCallbackName = "onTriggerSkillInfo", callback = handler(self, self._onTriggerSkillInfo)},
        {ccbCallbackName = "onTriggerDressSkillInfo", callback = handler(self, self._onTriggerDressSkillInfo)},
        {ccbCallbackName = "onTriggerMaster", callback = handler(self, self._onTriggerMaster)},
        {ccbCallbackName = "onTriggerGraveMaster", callback = handler(self, self._onTriggerGraveMaster)},
    }
    QUIWidgetMountInfoDetailClient.super.ctor(self, ccbFile, callBacks, options)

    cc.GameObject.extend(self)
    self:addComponent("components.behavior.EventProtocol"):exportMethods()

    q.setButtonEnableShadow(self._ccbOwner.btn_fazhen_info)

    self._width = 280
    self._offsetY = 0

    self._lineHeight = 26

    self._bgRoleSize = self._ccbOwner.s9s_role_bg:getContentSize()
    self._tfRoleY1 = self._ccbOwner.tf_role1:getPositionY()
    self._tfRoleY2 = self._ccbOwner.tf_role2:getPositionY()
    self._bgWith = self._ccbOwner.sp_bg:getContentSize().width
    self._bgHeight = self._ccbOwner.sp_bg:getContentSize().height
    self._ccbOwner.node_effect:setVisible(false)
end

function QUIWidgetMountInfoDetailClient:setInfo(mountId, showSSMountEffect)
    self._offsetY = 0

    self._mountId = mountId
    self._showSSMountEffect = showSSMountEffect
    self._mountConfig = db:getCharacterByID(self._mountId)
    self._mountInfo = remote.mount:getMountById(mountId)

    self:setDetailInfo()

    self:skillInfo()

    self:setDressSkill()

    self:setPropInfo()

    if self._mountConfig.aptitude == APTITUDE.SSR then
        self:setGraveTalantPropInfo()
    end

    self:superInfo()

    self:setIntroInfo()

    if self._offsetY > self._bgHeight then
        self._ccbOwner.sp_bg:setContentSize(CCSize(self._bgWith, self._offsetY))
    end
    self._offsetY = self._offsetY + 290
end

function QUIWidgetMountInfoDetailClient:setMountStar()
    local grade = self._mountInfo.grade
    if self._mountInfo.aptitude == APTITUDE.SSR then
        if  grade == 0 then
            self._ccbOwner.node_hero_empty_star:setVisible(true)
            self._ccbOwner.node_hero_star:setVisible(false)
        else
            self._ccbOwner.node_hero_empty_star:setVisible(false)
            self._ccbOwner.node_hero_star:setVisible(true)
        end
    else
        grade = grade +1
    end
    for i = 1, 5 do
        if i <= grade then
            self._ccbOwner["star"..i]:setVisible(true)
        else
            self._ccbOwner["star"..i]:setVisible(false)
        end
    end

end

function QUIWidgetMountInfoDetailClient:setDetailInfo()
    local reformLevel = self._mountInfo.reformLevel or 0
    local nameStr = self._mountConfig.name or ""
    if reformLevel > 0 then
        nameStr = nameStr.."+"..reformLevel
    end
    self._ccbOwner.tf_name:setString(nameStr)
    self._ccbOwner.tf_name1:setVisible(false)

    local fontColor = QIDEA_QUALITY_COLOR[remote.mount:getColorByMountId(self._mountId)] or COLORS.b
    self._ccbOwner.tf_name:setColor(fontColor)
    self._ccbOwner.tf_name = setShadowByFontColor(self._ccbOwner.tf_name, fontColor)
    
    self._ccbOwner.node_mount:removeAllChildren()
    local avatar = QUIWidgetActorDisplay.new(self._mountId)
    if self._mountConfig.aptitude == APTITUDE.SSR then
        avatar:setScaleX(0.9)
    else
        avatar:setScaleX(-0.9)
    end
    avatar:setScaleY(0.9)
    self._ccbOwner.node_mount:addChild(avatar)
    if self._showSSMountEffect then 
        local actorView = avatar:getActor():getSkeletonView()
        actorView:playAnimation("variant", false)
        actorView:appendAnimation("stand", true)
    end

    self:setMountStar(self._mountInfo.grade)

    local roleStr = self._mountConfig.role_definition or ""
    local roleTextList = string.split(roleStr, ";")
    self._ccbOwner.tf_role1:setString(roleTextList[1])
    self._ccbOwner.tf_role2:setString(roleTextList[2] or "")
    if self._mountConfig.zuoqi_pj then
        self._ccbOwner.node_role:setVisible(false)
    else
        self._ccbOwner.node_role:setVisible(true)
    end
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

function QUIWidgetMountInfoDetailClient:setSABC()
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

function QUIWidgetMountInfoDetailClient:setGraveTalantPropInfo()
    self._ccbOwner.node_fazheng:setVisible(true)
    self._ccbOwner.node_fazheng:setPositionY(-self._offsetY)
    local height = 180
    local graveMasterProp,graveMasterLevel = remote.mount:getGraveTalantMasterInfo(self._mountConfig.aptitude,self._mountInfo.grave_level)
    local isHaveMaster = true
    if graveMasterLevel == 0 then 
        isHaveMaster = false
    end
    local mountStrengthMaster1 = remote.mount:getGraveTalantMasterInfoByLevel(self._mountConfig.aptitude, graveMasterLevel)
    if mountStrengthMaster1 ~= nil then
        local name, value  = self:findMasterProp(mountStrengthMaster1)
        if isHaveMaster == true then
            self._ccbOwner.fazhen_desc1:setString("【"..mountStrengthMaster1.master_name.."】"..name.."+"..value.."（等级提升至"..mountStrengthMaster1.condition.."级）")
            self._ccbOwner.fazhen_desc1:setColor(GAME_COLOR_LIGHT.stress)
        else
            self._ccbOwner.fazhen_desc1:setString("")
            self._ccbOwner.fazhen_desc1:setColor(GAME_COLOR_LIGHT.notactive)
        end
    else
        self._ccbOwner.fazhen_desc1:setString("")
    end

    local mountStrengthMaster2 = remote.mount:getGraveTalantMasterInfoByLevel(self._mountConfig.aptitude, graveMasterLevel+1)
    if mountStrengthMaster2 ~= nil then
        local name,value  = self:findMasterProp(mountStrengthMaster2)
        self._ccbOwner.fazhen_desc2:setColor(GAME_COLOR_LIGHT.notactive)
        self._ccbOwner.fazhen_desc2:setString("【"..mountStrengthMaster2.master_name.."】"..name.."+"..value.."（等级提升至"..mountStrengthMaster2.condition.."级）")
        self._ccbOwner.fazhen_name2:setVisible(true)
    else
        self._ccbOwner.fazhen_desc2:setString("")
        self._ccbOwner.fazhen_name2:setVisible(false)
    end


    self._offsetY = self._offsetY+height + 20
end

function QUIWidgetMountInfoDetailClient:setPropInfo()
    self._ccbOwner.node_prop:setPositionY(-self._offsetY)
    self._ccbOwner.node_prop:setVisible(true)
    self._ccbOwner.node_reform_prop:setVisible(false)
    self._ccbOwner.node_dress_prop:setVisible(false)
    self._ccbOwner.node_grave_prop:setVisible(false)
    self._ccbOwner.node_fazheng:setVisible(false)
    -- local height = 210
    local height = 90

    local mountProp = remote.mount:getMountPropById(self._mountId)
    local props = self:getUIPropInfo(mountProp:getTotalProp())
    self._ccbOwner.node_main_prop_richText:removeAllChildren()
    for i,prop in ipairs(props) do
        local value = prop.value 
        local tfNode = q.createPropTextNode(prop.name , value,nil,22)
        self._ccbOwner.node_main_prop_richText:addChild(tfNode)
        if i%2 == 0 then
            tfNode:setPosition(ccp(-10,-math.floor((i-1)/2)*30))
        else
            tfNode:setPosition(ccp(240,-math.floor((i-1)/2)*30))
            height = height + 30
        end
    end
    print("暗器主属性高度------height=",height)
    self._ccbOwner.tf_prop_dress_tip:setVisible(false)
    if self._mountInfo.superZuoqiId and self._mountInfo.superZuoqiId > 0 then
        self._ccbOwner.tf_prop_dress_tip:setVisible(true)
        height = height + 10
    end
    
    local reformLevel = self._mountInfo.reformLevel
    if reformLevel > 0 then
        self._ccbOwner.node_reform_prop:setPositionY(-height-40)
        self._ccbOwner.node_reform_prop:setVisible(true)  
        local reformConfig = db:getReformConfigByAptitudeAndLevel(self._mountConfig.aptitude, reformLevel) or {}
        local props = QActorProp:getPropUIByConfig(reformConfig)
        height = height + 50    
        local i = 1
        self._ccbOwner.node_reform_prop_richText:removeAllChildren()
        for key, prop in pairs(props) do
            local value = prop.value 
            if prop.isPercent then
                value = (value*100).."%"
            end
            local tfNode = q.createPropTextNode(prop.name , value,nil,22)
            self._ccbOwner.node_reform_prop_richText:addChild(tfNode)
            if i%2 == 0 then
                tfNode:setPosition(ccp(-10,-math.floor((i-1)/2)*30))
            else
                tfNode:setPosition(ccp(240,-math.floor((i-1)/2)*30))
                height = height + 30
            end
            i = i + 1
        end
    end

    local wearZuoqiInfo = self._mountInfo.wearZuoqiInfo
    if wearZuoqiInfo then
        local mountProp = remote.mount:getMountPropById(wearZuoqiInfo.zuoqiId)
        local props = self:getUIPropInfo(mountProp:getTotalProp())

        self._ccbOwner.node_dress_prop:setPositionY(-height-40)
        self._ccbOwner.node_dress_prop:setVisible(true)

         self._ccbOwner.node_dress_prop_richText:removeAllChildren()
        for i,prop in ipairs(props) do
            local value = prop.value 
            local tfNode = q.createPropTextNode(prop.name , value,nil,22)
            self._ccbOwner.node_dress_prop_richText:addChild(tfNode)
            if i%2 == 0 then
                tfNode:setPosition(ccp(-10,-math.floor((i-1)/2)*30))
            else
                tfNode:setPosition(ccp(240,-math.floor((i-1)/2)*30))
                height = height + 30
            end
        end
        height = height + 40
    end
    local grave_level = self._mountInfo.grave_level or 0
    if grave_level > 0 then
        if wearZuoqiInfo then
            height = height + 20
        end
        self._ccbOwner.node_grave_prop:setPositionY(-height-40)
        self._ccbOwner.node_grave_prop:setVisible(true)
        local graveLevelProp = remote.mount:getGraveInfoByAptitudeLv(self._mountConfig.aptitude,self._mountInfo.grave_level)
        local props = self:getUIPropInfo(graveLevelProp)
        self._ccbOwner.node_grave_prop_richText:removeAllChildren()
        for i,prop in ipairs(props) do
            local value = prop.value 
            local tfNode = q.createPropTextNode(prop.name , value,nil,22)
            self._ccbOwner.node_grave_prop_richText:addChild(tfNode)
            if i%2 == 0 then
                tfNode:setPosition(ccp(-10,-math.floor((i-1)/2)*30))
            else
                tfNode:setPosition(ccp(240,-math.floor((i-1)/2)*30))
                height = height + 30
            end
        end
    end    
    self._offsetY = self._offsetY+height + 20
end

function QUIWidgetMountInfoDetailClient:getUIPropInfo(props)
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

    if props.team_attack_percent and props.team_attack_percent > 0 then
        prop[index] = {}
        prop[index].value = (props.team_attack_percent*100).."%"
        prop[index].name = "全队 攻击"
        index = index + 1
    end
    if props.team_hp_percent and props.team_hp_percent > 0 then
        prop[index] = {}
        prop[index].value = (props.team_hp_percent*100).."%"
        prop[index].name = "全队 生命"
        index = index + 1
    end
    if props.team_armor_physical_percent and props.team_armor_physical_percent > 0 then
        prop[index] = {}
        prop[index].value = (props.team_armor_physical_percent*100).."%"
        prop[index].name = "全队 物防"
        index = index + 1
    end
    if props.team_armor_magic_percent and props.team_armor_magic_percent > 0 then
        prop[index] = {}
        prop[index].value = (props.team_armor_magic_percent*100).."%"
        prop[index].name = "全队 法防"
        index = index + 1
    end

    if props.team_attack_value and props.team_attack_value > 0 then
        prop[index] = {}
        prop[index].value = math.floor(props.team_attack_value)
        prop[index].name = "全队 攻击"
        index = index + 1
    end
    if props.team_hp_value and props.team_hp_value > 0 then
        prop[index] = {}
        prop[index].value = math.floor(props.team_hp_value)
        prop[index].name = "全队 生命"
        index = index + 1
    end
    if props.team_armor_physical and props.team_armor_physical > 0 then
        prop[index] = {}
        prop[index].value = math.floor(props.team_armor_physical)
        prop[index].name = "全队 物防"
        index = index + 1
    end
    if props.team_armor_magic and props.team_armor_magic > 0 then
        prop[index] = {}
        prop[index].value = math.floor(props.team_armor_magic)
        prop[index].name = "全队 法防"
        index = index + 1
    end

    return prop
end

function QUIWidgetMountInfoDetailClient:skillInfo()
    local height = 50

    self._ccbOwner.node_skill:setPositionY(-self._offsetY)

    self._ccbOwner.node_skill:setVisible(true)
    self._ccbOwner.node_skill1:setVisible(false)
    self._ccbOwner.node_skill2:setVisible(false)

    if self._mountConfig.zuoqi_pj then  --配件暗器不显示技能
        self._ccbOwner.btn_skill_info:setVisible(false)
        local height1 = 0
        local describe = "##e".."配件暗器".."：##n配件暗器不能装备于魂师上，无主力和援助效果，只能用于SS或SS+暗器的配件"
        local strArr  = string.split(describe,"\n") or {}
        for i, v in pairs(strArr) do
            local describe = QColorLabel.replaceColorSign(v or "", false)
            local richText = QRichText.new(describe, 500, {stringType = 1, defaultColor = GAME_COLOR_LIGHT.normal, defaultSize = 22})
            richText:setAnchorPoint(ccp(0, 1))
            richText:setPositionY(-height1)
            self._ccbOwner.node_skill1:addChild(richText)
            height1 = height1 + richText:getContentSize().height
        end
        self._ccbOwner.node_skill1:setVisible(true)
        height = height + height1
    else
        self._ccbOwner.btn_skill_info:setVisible(true)

        local gradeConfig = db:getGradeByHeroActorLevel(self._mountId, self._mountInfo.grade)
        if gradeConfig then
            local skillIds = string.split(gradeConfig.zuoqi_skill_ms, ";")
            local skillConfig1 = db:getSkillByID(tonumber(skillIds[1]))
            local height1, height2 = 0, 0
            if skillConfig1 ~= nil then
                local describe = "##e"..skillConfig1.name.."：##n"..(skillConfig1.description or "")
                local strArr  = string.split(describe,"\n") or {}
                for i, v in pairs(strArr) do
                    local describe = QColorLabel.replaceColorSign(v or "", false)
                    local richText = QRichText.new(describe, 500, {stringType = 1, defaultColor = GAME_COLOR_LIGHT.normal, defaultSize = 22})
                    richText:setAnchorPoint(ccp(0, 1))
                    richText:setPositionY(-height1)
                    self._ccbOwner.node_skill1:addChild(richText)
                    height1 = height1 + richText:getContentSize().height
                end
                self._ccbOwner.node_skill1:setVisible(true)
            end

            local skillConfig2 = db:getSkillByID(tonumber(skillIds[2]))
            if skillConfig2 ~= nil then
                local describe = "##e"..skillConfig2.name.."：##n"..(skillConfig2.description or "")
                local strArr  = string.split(describe,"\n") or {}
                for i, v in pairs(strArr) do
                    local describe = QColorLabel.replaceColorSign(v or "", false)
                    local richText = QRichText.new(describe, 500, {stringType = 1, defaultColor = GAME_COLOR_LIGHT.normal, defaultSize = 22})
                    richText:setAnchorPoint(ccp(0, 1))
                    richText:setPositionY(-height2)
                    self._ccbOwner.node_skill2:addChild(richText)
                    height2 = height2 + richText:getContentSize().height
                end
                local posY = self._ccbOwner.node_skill1:getPositionY()-height1
                self._ccbOwner.node_skill2:setPositionY(posY)
                self._ccbOwner.node_skill2:setVisible(true)
            end
            height = height + height1 + height2
        end
    end

    self._ccbOwner.tf_skill_dress_tip:setVisible(false)
    if self._mountInfo.superZuoqiId and self._mountInfo.superZuoqiId > 0 and not self._mountConfig.zuoqi_pj then
        self._ccbOwner.tf_skill_dress_tip:setVisible(true)
        self._ccbOwner.tf_skill_dress_tip:setPositionY(-height)
        height = height + 20
    end

    self._offsetY = self._offsetY+height
end

function QUIWidgetMountInfoDetailClient:setDressSkill()
    self._ccbOwner.node_dress_skill:setVisible(false)
    local wearZuoqiInfo = self._mountInfo.wearZuoqiInfo
    if not wearZuoqiInfo then
        return
    end

    local height = 70
    self._ccbOwner.node_dress_skill:setPositionY(-self._offsetY)
    self._ccbOwner.node_dress_skill:setVisible(true)

    local grade = 0
    if self._mountInfo.wearZuoqiInfo then
        grade = self._mountInfo.wearZuoqiInfo.grade
    end
    local gradeConfig = db:getGradeByHeroActorLevel(self._mountId, grade)
    if gradeConfig then
        local skillIds = string.split(gradeConfig.zuoqi_skill_xs, ":")
        local skillConfig1 = db:getSkillByID(tonumber(skillIds[1]))
        local height1 = 0
        if skillConfig1 ~= nil then
            local describe = "##e"..skillConfig1.name.."：##n"..(skillConfig1.description or "")
            local strArr  = string.split(describe,"\n") or {}
            for i, v in pairs(strArr) do
                local describe = QColorLabel.replaceColorSign(v or "", false)
                local richText = QRichText.new(describe, 500, {stringType = 1, defaultColor = GAME_COLOR_LIGHT.normal, defaultSize = 22})
                richText:setAnchorPoint(ccp(0, 1))
                richText:setPositionY(-height1)
                self._ccbOwner.node_dress_desc:addChild(richText)
                height1 = height1 + richText:getContentSize().height
            end
            self._ccbOwner.node_dress_desc:setVisible(true)
        end
        height = height + height1
    end
    self._ccbOwner.tf_dress_skill_tip:setPositionY(-(height-20))

    self._offsetY = self._offsetY+height
end

function QUIWidgetMountInfoDetailClient:superInfo()
    local height = 180
    self._ccbOwner.node_super:setPositionY(-self._offsetY)
    self._ccbOwner.node_super:setVisible(true)
    self._ccbOwner.node_dress_super:setVisible(false)
    self._ccbOwner.super_desc1:setString("")
    self._ccbOwner.super_desc2:setString("")

    local masterInfos, masterLevel = db:getMountMasterInfo(self._mountConfig.aptitude, (self._mountInfo.enhanceLevel or 0))
    masterLevel = masterLevel or 0
    local isHaveMaster = true
    if masterLevel == 0 then 
        isHaveMaster = false
    end
    local mountStrengthMaster1 = db:getMountMasterInfoByLevel(self._mountConfig.aptitude, masterLevel)
    if mountStrengthMaster1 ~= nil then
        local name, value  = self:findMasterProp(mountStrengthMaster1)
        if isHaveMaster == true then
            self._ccbOwner.super_desc1:setString("【"..mountStrengthMaster1.master_name.."】"..name.."+"..value.."（等级提升至"..mountStrengthMaster1.condition.."级）")
            self._ccbOwner.super_desc1:setColor(GAME_COLOR_LIGHT.stress)
        else
            self._ccbOwner.super_desc1:setString("")
            self._ccbOwner.super_desc1:setColor(GAME_COLOR_LIGHT.notactive)
        end
    else
        self._ccbOwner.super_desc1:setString("")
    end

    local mountStrengthMaster2 = db:getMountMasterInfoByLevel(self._mountConfig.aptitude, masterLevel+1)
    if mountStrengthMaster2 ~= nil then
        local name,value  = self:findMasterProp(mountStrengthMaster2)
        self._ccbOwner.super_desc2:setColor(GAME_COLOR_LIGHT.notactive)
        self._ccbOwner.super_desc2:setString("【"..mountStrengthMaster2.master_name.."】"..name.."+"..value.."（等级提升至"..mountStrengthMaster2.condition.."级）")
        self._ccbOwner.super_name2:setVisible(true)
    else
        self._ccbOwner.super_desc2:setString("")
        self._ccbOwner.super_name2:setVisible(false)
    end

    self._ccbOwner.tf_dress_super_tip:setVisible(false)
    if self._mountInfo.superZuoqiId and self._mountInfo.superZuoqiId > 0 then
        self._ccbOwner.tf_dress_super_tip:setVisible(true)
        height = height + 10
    end

    local wearZuoqiInfo = self._mountInfo.wearZuoqiInfo
    if wearZuoqiInfo then
        local wearMountConfig = db:getCharacterByID(wearZuoqiInfo.zuoqiId)
        local masterInfos, masterLevel = db:getMountMasterInfo(wearMountConfig.aptitude, (wearZuoqiInfo.enhanceLevel or 0))
        masterLevel = masterLevel or 0
        local isHaveMaster = true
        if masterLevel == 0 then 
            isHaveMaster = false
        end

        local mountStrengthMaster1 = db:getMountMasterInfoByLevel(wearMountConfig.aptitude, masterLevel)
        if mountStrengthMaster1 ~= nil then
            local name, value  = self:findMasterProp(mountStrengthMaster1)
            if isHaveMaster == true then
                self._ccbOwner.tf_dress_super_desc:setString("【"..mountStrengthMaster1.master_name.."】"..name.."+"..value)
                self._ccbOwner.node_dress_super:setVisible(true)
                self._ccbOwner.node_dress_super:setPositionY(-height-55)
                height = height + 75
            end
        end
    end

    self._offsetY = self._offsetY+height
end

function QUIWidgetMountInfoDetailClient:setIntroInfo()
    local height = 50
    self._ccbOwner.node_jieshao:setPositionY(-self._offsetY)
    local desc = self._mountConfig.brief or ""
    self._ccbOwner.tf_desc:setString(desc)

    local skillLength = q.wordLen(desc, 22, 22)
    local count = math.ceil(skillLength/self._width)
    height = height + count*self._lineHeight
    self._offsetY = self._offsetY+height
end

function QUIWidgetMountInfoDetailClient:findMasterProp(masterInfo)
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

function QUIWidgetMountInfoDetailClient:_onTriggerSkillInfo(event)
    if q.buttonEventShadow(event, self._ccbOwner.btn_skill_info) == false then return end
    app.sound:playSound("common_small")
    app:getNavigationManager():pushViewController(app.middleLayer, {uiType = QUIViewController.TYPE_DIALOG, uiClass = "QUIDialogMountSkill", 
        options = {mountId = self._mountId}})
end

function QUIWidgetMountInfoDetailClient:_onTriggerDressSkillInfo(event)
    if q.buttonEventShadow(event, self._ccbOwner.btn_dress_skill_info) == false then return end
    app.sound:playSound("common_small")

    local grade = -1
    if self._mountInfo.wearZuoqiInfo then
        grade = self._mountInfo.wearZuoqiInfo.grade
    end
    app:getNavigationManager():pushViewController(app.middleLayer, {uiType = QUIViewController.TYPE_DIALOG, uiClass = "QUIDialogMountSkill", 
        options = {mountId = self._mountId, isDress = true, dressGrade = grade}})
end

function QUIWidgetMountInfoDetailClient:_onTriggerMaster(event)
    if q.buttonEventShadow(event, self._ccbOwner.btn_master_info) == false then return end
    app.sound:playSound("common_menu")

    local talents = remote.mount:getMountStrengthMaster(self._mountInfo.zuoqiId)

    app:getNavigationManager():pushViewController(app.middleLayer, {uiType = QUIViewController.TYPE_DIALOG, uiClass = "QUIDialogMountTalent", 
        options = {talents = talents,compareLevel = self._mountInfo.enhanceLevel}})

end

function QUIWidgetMountInfoDetailClient:_onTriggerGraveMaster(event)
    app.sound:playSound("common_menu")

    local dbTalents = remote.mount:getMountGraveMaster(self._mountInfo.zuoqiId) or {}
    app:getNavigationManager():pushViewController(app.middleLayer, {uiType = QUIViewController.TYPE_DIALOG, uiClass = "QUIDialogMountTalent", 
        options = {talents = dbTalents,compareLevel = self._mountInfo.grave_level,title = "雕刻法阵"}})  

end

function QUIWidgetMountInfoDetailClient:getContentSize()
    local size = CCSize(550, self._offsetY)  -- 介绍文字的高度
    return size
end

return QUIWidgetMountInfoDetailClient
