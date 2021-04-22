-- 
-- Kumo.Wang
-- 魂靈信息
-- 
local QUIWidget = import(".QUIWidget")
local QUIWidgetSoulSpiritDetailCell = class("QUIWidgetSoulSpiritDetailCell", QUIWidget)

local QUIViewController = import("...ui.QUIViewController")
local QUIWidgetActorDisplay = import("..widgets.actorDisplay.QUIWidgetActorDisplay")
local QActorProp = import("...models.QActorProp")
local QRichText = import("...utils.QRichText") 
local QColorLabel = import("...utils.QColorLabel")
local QStaticDatabase = import("...controllers.QStaticDatabase")
local QUIWidgetSoulSpiritHead = import("..widgets.QUIWidgetSoulSpiritHead")

local NOT_SOULSPIRIT_OCCULT_POS = {ccp(0,-180),ccp(0,-370),ccp(0,-500),ccp(0,-760)}
local HAVE_SOULSPIRIT_OCCULT_POS = {ccp(0,-380),ccp(0,-570),ccp(0,-700),ccp(0,-960)}
function QUIWidgetSoulSpiritDetailCell:ctor(ccbFile,callBacks,options)
    local ccbFile = "ccb/Widget_SoulSpirit_Detail_Cell.ccbi"
    local callBacks = {
        {ccbCallbackName = "onTriggerSkillInfo", callback = handler(self, self._onTriggerSkillInfo)},
        {ccbCallbackName = "onTriggerMaster", callback = handler(self, self._onTriggerMaster)},
        {ccbCallbackName = "onTriggerHandBook", callback = handler(self, self._onTriggerHandBook)},
        {ccbCallbackName = "onTriggerInherit", callback = handler(self, self._onTriggerInherit)},
    }
    QUIWidgetSoulSpiritDetailCell.super.ctor(self, ccbFile, callBacks, options)

    cc.GameObject.extend(self)
    self:addComponent("components.behavior.EventProtocol"):exportMethods()

    self._width = 500
    self._offsetY = 0
    self._lineHeight = 30
    q.setButtonEnableShadow(self._ccbOwner.btn_inherit)
    self._bgRoleSize = self._ccbOwner.s9s_role_bg:getContentSize()
    self._tfRoleY1 = self._ccbOwner.tf_role1:getPositionY()
    self._tfRoleY2 = self._ccbOwner.tf_role2:getPositionY()
end

function QUIWidgetSoulSpiritDetailCell:setInfo(id)
    self._offsetY = 0
    self._id = id
    self._soulSpiritInfo = remote.soulSpirit:getMySoulSpiritInfoById(self._id)
    if self._soulSpiritInfo == nil then
        self._soulSpiritInfo ={}
        self._soulSpiritInfo.id = self._id
        self._soulSpiritInfo.grade = 0
        self._soulSpiritInfo.level = 1
        self._soulSpiritInfo.awaken_level = 0
        self._soulSpiritInfo.devour_level = 1
    end

    self._characterConfig = QStaticDatabase.sharedDatabase():getCharacterByID(self._id)
    
    self:setDetailInfo()
    self:skillInfo()
    self:awakenlInfo()    
    self:inheritlInfo()
    self:setPropInfo()
    self:setSoulOccultProp()
    self:masterInfo()
    self:handBookInfo()
    self:setDescInfo()
    self._offsetY = self._offsetY + 300
    self._ccbOwner.s9s_bg:setPreferredSize(CCSize(536, self._offsetY))
end

function QUIWidgetSoulSpiritDetailCell:setStar()
    local grade = self._soulSpiritInfo.grade

    if self._characterConfig.aptitude == APTITUDE.SS then
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


function QUIWidgetSoulSpiritDetailCell:setDetailInfo()
    self._ccbOwner.tf_name:setString(self._characterConfig.name)

    local fontColor = QIDEA_QUALITY_COLOR[remote.soulSpirit:getColorByCharacherId(self._id)] or COLORS.b
    self._ccbOwner.tf_name:setColor(fontColor)
    self._ccbOwner.tf_name = setShadowByFontColor(self._ccbOwner.tf_name, fontColor)
    
    self._ccbOwner.node_avatar:removeAllChildren()
    local avatar = QUIWidgetActorDisplay.new(self._id)
    self._ccbOwner.node_avatar:addChild(avatar)
    avatar:setScale(1.1)
    self._ccbOwner.node_avatar:setScaleX(-1)


    if self._characterConfig.aptitude == APTITUDE.SS and self._characterConfig.information_action then
        local actionArr = string.split(self._characterConfig.information_action, ";")
        local actionFirst = string.split(actionArr[1], ":")
        avatar:displayWithBehavior(actionFirst[1])
    end

    self:setStar()
    -- local grade = self._soulSpiritInfo.grade + 1
    -- for i = 1, 5 do
    --     if i <= grade then
    --         self._ccbOwner["star"..i]:setVisible(true)
    --     else
    --         self._ccbOwner["star"..i]:setVisible(false)
    --     end
    -- end

    local roleStr = self._characterConfig.role_definition or ""
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

function QUIWidgetSoulSpiritDetailCell:setSABC()
    local aptitudeInfo = db:getActorSABC(self._id)
    q.setAptitudeShow(self._ccbOwner, aptitudeInfo.lower)

    self._ccbOwner["node_bg_a"]:setVisible(false)
    self._ccbOwner["node_bg_a+"]:setVisible(false)
    self._ccbOwner["node_bg_s"]:setVisible(false)
    self._ccbOwner["node_bg_ss"]:setVisible(false)
    self._ccbOwner["node_bg_"..aptitudeInfo.lower]:setVisible(true)
end

function QUIWidgetSoulSpiritDetailCell:setPropInfo()
    self._ccbOwner.node_prop:setPositionY(-self._offsetY)
    self._ccbOwner.node_prop:setVisible(true)
    local height = 180
  
    local propList = remote.soulSpirit:getPropListById(self._id)
    for i = 1, 8 do
        if propList[i] ~= nil then
            self._ccbOwner["tf_prop_name"..i]:setString((propList[i].name or "").."：")
            self._ccbOwner["tf_prop_value"..i]:setString("+"..(propList[i].value or "0"))
        else
            self._ccbOwner["tf_prop_name"..i]:setString("")
            self._ccbOwner["tf_prop_value"..i]:setString("")
        end
    end

    self._offsetY = self._offsetY + height
end

function QUIWidgetSoulSpiritDetailCell:setSoulOccultProp()
    self._ccbOwner.node_occult_prop:setPositionY(-self._offsetY)
  
    local soulFirePropList = remote.soulSpirit:getSoulFirePropList()
    if q.isEmpty(soulFirePropList) then
        self._ccbOwner.node_occult_prop:setVisible(false)
        return
    end
    local height = 50
    self._ccbOwner.node_occult_prop:setVisible(true)
    for i = 1, 16 do
        if soulFirePropList[i] ~= nil then
            self._ccbOwner["tf_occult_prop_name"..i]:setString((soulFirePropList[i].name or ""))
            self._ccbOwner["tf_occult_prop_value"..i]:setString("+"..(soulFirePropList[i].value or "0"))
            if i%2 ~= 0 then
                height = height + 30
            end            
        else
            self._ccbOwner["tf_occult_prop_name"..i]:setString("")
            self._ccbOwner["tf_occult_prop_value"..i]:setString("")
        end
    end

   self._offsetY = self._offsetY + height + 20
   self._ccbOwner.tf_dress_skill_tip:setPositionY(-(height))
end

function QUIWidgetSoulSpiritDetailCell:skillInfo()
    local height = 50
    self._ccbOwner.node_skill:setPositionY(-self._offsetY)
    self._ccbOwner.node_skill:setVisible(true)
    self._ccbOwner.node_skill1:setVisible(false)
    self._ccbOwner.node_skill2:setVisible(false)

    local gradeConfig = QStaticDatabase.sharedDatabase():getGradeByHeroActorLevel(self._id, self._soulSpiritInfo.grade)
    -- 由于配表原因，这里用星级来显示技能等级
    local rnumSkillLevel = q.getRomanNumberalsByInt(self._soulSpiritInfo.grade+1)
    if gradeConfig then
        local skillId1 = string.split(gradeConfig.soulspirit_pg, ":")
        local skillConfig1 = QStaticDatabase.sharedDatabase():getSkillByID(tonumber(skillId1[1]))
        local height1, height2 = 0, 0
        if skillConfig1 ~= nil then
            local describe = "##e"..skillConfig1.name..rnumSkillLevel.."：##n"..skillConfig1.description
            describe = QColorLabel.replaceColorSign(describe or "", false)
            local richText = QRichText.new(describe, 500, {stringType = 1, defaultColor = GAME_COLOR_LIGHT.normal, defaultSize = 20})
            richText:setAnchorPoint(ccp(0, 1))
            self._ccbOwner.node_skill1:addChild(richText)
            height1 = richText:getContentSize().height
            self._ccbOwner.node_skill1:setVisible(true)
        end

        local skillId2 = string.split(gradeConfig.soulspirit_dz, ":")
        local skillConfig2 = QStaticDatabase.sharedDatabase():getSkillByID(tonumber(skillId2[1]))
        if skillConfig2 ~= nil then
            local describe = "##e"..skillConfig2.name..rnumSkillLevel.."：##n"..skillConfig2.description
            describe = QColorLabel.replaceColorSign(describe or "", false)
            local richText = QRichText.new(describe, 500, {stringType = 1, defaultColor = COLORS.j, defaultSize = 20})
            richText:setAnchorPoint(ccp(0, 1))
            self._ccbOwner.node_skill2:addChild(richText)
            height2 = richText:getContentSize().height

            local posY = self._ccbOwner.node_skill1:getPositionY()-height1
            self._ccbOwner.node_skill2:setPositionY(posY)
            self._ccbOwner.node_skill2:setVisible(true)
        end
        -- local posY = self._ccbOwner.node_skill1:getPositionY()-height1-height2
        -- self._ccbOwner.node_skill_tips:setPositionY(posY)
        -- self._ccbOwner.tf_skill_tips1:setString("注：魂灵战斗属性=上阵主力英雄属性x"..remote.soulSpirit:getFightCoefficientByAptitude(self._characterConfig.aptitude))
        -- height = height + height1 + height2 + 80

        self._ccbOwner.node_skill_tips:setVisible(false)
        height = height + height1 + height2 
    end

    self._offsetY = self._offsetY+height
end

function QUIWidgetSoulSpiritDetailCell:masterInfo()
    self._ccbOwner.node_master:setPositionY(-self._offsetY)
    self._ccbOwner.node_master:setVisible(true)
    self._ccbOwner.master_desc1:setString("")
    self._ccbOwner.master_desc2:setString("")

    local curMasterConfig = remote.soulSpirit:getMasterConfigByAptitudeAndSoulSpiritLevel(self._characterConfig.aptitude, (self._soulSpiritInfo.level or 0))
    local masterLevel = curMasterConfig and curMasterConfig.level or 0
    local isHaveMaster = true
    if masterLevel == 0 then 
        isHaveMaster = false
    end

    if curMasterConfig then
        local propDic  = remote.soulSpirit:getPropDicByConfig(curMasterConfig)
        if isHaveMaster == true then
            for key, value in pairs(propDic) do
                if value > 0 then
                    local name = QActorProp._field[key].uiName or QActorProp._field[key].name
                    local isPercent = QActorProp._field[key].isPercent
                    local str = q.getFilteredNumberToString(tonumber(value), isPercent, 2)  
                    self._ccbOwner.master_desc1:setString("【"..curMasterConfig.master_name.."】被护佑魂师"..name.."+"..str.."（魂灵"..curMasterConfig.condition.."级激活）")
                    self._ccbOwner.master_desc1:setColor(GAME_COLOR_LIGHT.stress)
                    break
                end
            end
        else
            self._ccbOwner.master_desc1:setString("")
            self._ccbOwner.master_desc1:setColor(GAME_COLOR_LIGHT.notactive)
        end
    else
        self._ccbOwner.master_desc1:setString("")
        self._ccbOwner.master_desc1:setString("")
    end

    local nextMasterConfig = remote.soulSpirit:getMasterConfigByAptitudeAndMasterLevel(self._characterConfig.aptitude, masterLevel + 1)
    if nextMasterConfig then
        local propDic  = remote.soulSpirit:getPropDicByConfig(nextMasterConfig)
        for key, value in pairs(propDic) do
            if value > 0 then
                local name = QActorProp._field[key].uiName or QActorProp._field[key].name
                local isPercent = QActorProp._field[key].isPercent
                local str = q.getFilteredNumberToString(tonumber(value), isPercent, 2)  
                self._ccbOwner.master_desc2:setString("【"..nextMasterConfig.master_name.."】被护佑魂师"..name.."+"..str.."（魂灵"..nextMasterConfig.condition.."级激活）")
                self._ccbOwner.master_desc2:setColor(GAME_COLOR_LIGHT.notactive)
                self._ccbOwner.master_name2:setVisible(true)
                break
            end
        end
    else
        self._ccbOwner.master_desc2:setString("")
        self._ccbOwner.master_name2:setVisible(false)
    end

    local height1 = self._ccbOwner.master_desc1:getContentSize().height
    if height1 < 30 then height1 = 30 end
    local posY = self._ccbOwner.node_master1:getPositionY() + self._ccbOwner.master_desc1:getPositionY() - height1 - 20
    self._ccbOwner.node_master2:setPositionY(posY)
    self._offsetY = self._offsetY - posY - self._ccbOwner.master_desc2:getPositionY() + self._ccbOwner.master_desc2:getContentSize().height
end

-- function QUIWidgetSoulSpiritDetailCell:masterAllInfo()
--     self._ccbOwner.node_master:setPositionY(-self._offsetY)
--     self._ccbOwner.node_master:setVisible(true)
--     self._ccbOwner.master_desc1:setString("")
--     self._ccbOwner.master_desc2:setString("")

--     local masterConfigListWithAptitude = remote.soulSpirit:getMasterConfigListByAptitude(self._characterConfig.aptitude)
--     local offsetY = 30
--     local soulSpiritInfo = remote.soulSpirit:getMySoulSpiritInfoById(self._id)
--     for _, masterConfig in ipairs(masterConfigListWithAptitude) do
--         local propDic  = remote.soulSpirit:getPropDicByConfig(masterConfig)
--         local text = ""
--         for key, value in pairs(propDic) do
--             if value > 0 then
--                 local name = QActorProp._field[key].uiName or QActorProp._field[key].name
--                 local isPercent = QActorProp._field[key].isPercent
--                 local str = q.getFilteredNumberToString(tonumber(value), isPercent, 2)  
--                 text = "【"..masterConfig.master_name.."】魂师"..name.."+"..str.."（魂灵"..masterConfig.condition.."级激活）"
--                 break
--             end
--         end
--         local label = CCLabelTTF:create(text, global.font_default, 22)
--         label:setAnchorPoint(ccp(0, 1))
--         label:setPosition(ccp(12, -offsetY))
--         if masterConfig.condition > (soulSpiritInfo.level or 0) then
--             label:setColor(COLORS.n)
--         else
--             label:setColor(COLORS.j)
--         end
--         self._ccbOwner.node_master:addChild(label)
--         offsetY = offsetY + 25
--     end

--     self._offsetY = self._offsetY + offsetY + 20
-- end

-- function QUIWidgetSoulSpiritDetailCell:handBookInfo()
--     self._ccbOwner.node_handBook:setPositionY(-self._offsetY)
--     self._ccbOwner.node_handBook:setVisible(true)

--     local handBookId = remote.soulSpirit:getHandBookIdById(self._id)
--     self._handBookId = handBookId
--     if handBookId == 0 then 
--         self._ccbOwner.node_handBook:setVisible(false)
--         return 
--     end 
--     local soulSpiritId1, soulSpiritId2 = remote.soulSpirit:getHandBookIdsByHandBookId(handBookId)
--     if soulSpiritId1 == 0 or soulSpiritId2 == 0 then
--         self._ccbOwner.node_handBook:setVisible(false)
--         return
--     end
--     local soulSpiritBox1 = QUIWidgetSoulSpiritHead.new()
--     self._ccbOwner.node_soulSpirit1:addChild(soulSpiritBox1)
--     soulSpiritBox1:setInfo(remote.soulSpirit:getMySoulSpiritHistoryInfoById(soulSpiritId1))
--     soulSpiritBox1:setScale(0.5)
--     local soulSpiritBox2 = QUIWidgetSoulSpiritHead.new()
--     self._ccbOwner.node_soulSpirit2:addChild(soulSpiritBox2)
--     soulSpiritBox2:setInfo(remote.soulSpirit:getMySoulSpiritHistoryInfoById(soulSpiritId2))
--     soulSpiritBox2:setScale(0.5)

--     local handBookInfo = remote.soulSpirit:getMyHandBookInfoByHandBookId(handBookId)
--     local handBookLevel = handBookInfo and handBookInfo.grade or 0
--     local curHandBookConfig = remote.soulSpirit:getHandBookConfigByHandBookIdAndLevel(handBookId, handBookLevel)
--     if curHandBookConfig then
--         local propDic  = remote.soulSpirit:getPropDicByConfig(curHandBookConfig)
--         local descStr = "【"..curHandBookConfig.name.."】"
--         local index = 0
--         for key, value in pairs(propDic) do
--             local name = QActorProp._field[key].uiName or QActorProp._field[key].name
--             local isPercent = QActorProp._field[key].isPercent
--             local str = q.getFilteredNumberToString(tonumber(value), isPercent, 2)  
--             if index == 0 then
--                 descStr = descStr..name.."+"..str
--             else
--                 descStr = descStr.."  "..name.."+"..str
--             end
--             index = index + 1
--         end
--         descStr = descStr.."（魂灵同时达到"..curHandBookConfig.grade.."星）"
--         self._ccbOwner.handBook_desc1:setString(descStr)
--         self._ccbOwner.handBook_desc1:setColor(GAME_COLOR_LIGHT.stress)
--     else
--         self._ccbOwner.handBook_desc1:setString("")
--     end

--     local nextHandBookConfig = remote.soulSpirit:getHandBookConfigByHandBookIdAndLevel(handBookId, handBookLevel + 1)
--     if nextHandBookConfig then
--         local propDic  = remote.soulSpirit:getPropDicByConfig(nextHandBookConfig)
--         local descStr = "【"..nextHandBookConfig.name.."】"
--         local index = 0
--         for key, value in pairs(propDic) do
--             local name = QActorProp._field[key].uiName or QActorProp._field[key].name
--             local isPercent = QActorProp._field[key].isPercent
--             local str = q.getFilteredNumberToString(tonumber(value), isPercent, 2)  
--             if index == 0 then
--                 descStr = descStr..name.."+"..str
--             else
--                 descStr = descStr.."  "..name.."+"..str
--             end
--             index = index + 1
--         end
--         descStr = descStr.."（魂灵同时达到"..nextHandBookConfig.grade.."星）"
--         self._ccbOwner.handBook_desc2:setString(descStr)
--         self._ccbOwner.handBook_desc2:setColor(GAME_COLOR_LIGHT.notactive)
--         self._ccbOwner.handBook_name2:setVisible(true)

--     else
--         self._ccbOwner.handBook_desc2:setString("")
--         self._ccbOwner.handBook_name2:setVisible(false)
--     end

--     local height1 = self._ccbOwner.handBook_desc1:getContentSize().height
--     if height1 < 30 then height1 = 30 end
--     local posY = self._ccbOwner.node_handBook1:getPositionY() + self._ccbOwner.handBook_desc1:getPositionY() - height1 - 20
--     self._ccbOwner.node_handBook2:setPositionY(posY)
--     self._offsetY = self._offsetY - posY - self._ccbOwner.handBook_desc2:getPositionY() + self._ccbOwner.handBook_desc2:getContentSize().height
-- end

function QUIWidgetSoulSpiritDetailCell:handBookInfo()
    self._ccbOwner.node_handBook:setPositionY(-self._offsetY)
    self._ccbOwner.node_handBook:setVisible(true)

    local handBookId = remote.soulSpirit:getHandBookIdById(self._id)
    self._handBookId = handBookId
    if handBookId == 0 then 
        self._ccbOwner.node_handBook:setVisible(false)
        return 
    end 
    local soulSpiritId1, soulSpiritId2 = remote.soulSpirit:getHandBookIdsByHandBookId(handBookId)
    if soulSpiritId1 == 0 or soulSpiritId2 == 0 then
        self._ccbOwner.node_handBook:setVisible(false)
        return
    end

    local handBookInfo = remote.soulSpirit:getMyHandBookInfoByHandBookId(handBookId)
    local combination = remote.soulSpirit:getHandBookConfigByHandBookIdAndLevel(handBookId, 1)
    local soulSpiritBox1 = QUIWidgetSoulSpiritHead.new()
    self._ccbOwner.node_soulSpirit1:addChild(soulSpiritBox1)
    soulSpiritBox1:setInfo(remote.soulSpirit:getMySoulSpiritHistoryInfoById(soulSpiritId1))
    soulSpiritBox1:setScale(0.5)
    local soulSpiritBox2 = QUIWidgetSoulSpiritHead.new()
    self._ccbOwner.node_soulSpirit2:addChild(soulSpiritBox2)
    if soulSpiritId2 and soulSpiritId2 ~= "nil" then
        soulSpiritBox2:setInfo(remote.soulSpirit:getMySoulSpiritHistoryInfoById(soulSpiritId2))
    else
        if combination.condition_num == 1 then
            self._ccbOwner.node_soulSpirit2:setVisible(false)
            self._ccbOwner.sp_handBook_add:setVisible(false)
            self._ccbOwner.node_soulSpirit1:setPositionX(self._ccbOwner.sp_handBook_add:getPositionX())
        end
        local color = remote.soulSpirit:getColorByCharacherId(soulSpiritId1)
        local aptitudeColor = string.lower(color)
        soulSpiritBox2:setFrame(aptitudeColor)
    end
    soulSpiritBox2:setScale(0.5)
 
    local handBookLevel = handBookInfo and handBookInfo.grade or 0
    local handBookConfig = remote.soulSpirit:getHandBookConfigByHandBookIdAndLevel(handBookId, handBookLevel)
    local isActive = true
    if not handBookConfig then
        isActive = false
        handBookConfig = remote.soulSpirit:getHandBookConfigByHandBookIdAndLevel(handBookId, handBookLevel + 1)
    end

    if handBookConfig then
        local name = "【"..handBookConfig.name.." LV."..handBookLevel.."】"
        local label = CCLabelTTF:create(name, global.font_default, 22)
        label:setAnchorPoint(ccp(0.5, 0.5))
        label:setPosition(ccp(264, -55))
        label:setColor(COLORS.k)
        self._ccbOwner.node_handBook:addChild(label)

        local propDic  = remote.soulSpirit:getPropDicByConfig(handBookConfig)
        local propList = {}
        for key, value in pairs(propDic) do
            table.insert(propList, {key = key, num = value})
        end
        -- local propList = remote.soulSpirit:markMergePropListByDic(propDic)

        local index = 1
        local markPropDic = {}
        for _, prop in ipairs(propList) do
            local propName = ""
            local isShow = true
            if prop.mark then
                if markPropDic[prop.mark] then 
                    isShow = false
                else
                    propName = QActorProp._field[prop.key].uiMergeName
                    markPropDic[prop.mark] = true
                end
            else
                propName = QActorProp._field[prop.key].uiName or QActorProp._field[prop.key].name
            end
            
            if isShow then
                local isPercent = QActorProp._field[prop.key].isPercent
                local str = q.getFilteredNumberToString(tonumber(prop.num), isPercent, 2)  
                local text = propName.."+"..str
                local label = CCLabelTTF:create(text, global.font_default, 22)
                label:setAnchorPoint(ccp(0, 1))
                local x = (index % 2) == 1 and 54 or 304
                local y = -175 - (math.floor((index - 1) / 2) * 50)
                label:setPosition(ccp(x, y))
                if isActive then
                    label:setColor(COLORS.j)
                else
                    label:setColor(COLORS.n)
                end
                self._ccbOwner.node_handBook:addChild(label)
                index = index + 1
            end
        end

        local descStr = "（魂灵同时达到"..handBookConfig.grade.."星）"
        local label = CCLabelTTF:create(descStr, global.font_default, 22)
        label:setAnchorPoint(ccp(0.5, 0.5))
        label:setPosition(ccp(264, -280))
        label:setColor(COLORS.k)
        self._ccbOwner.node_handBook:addChild(label)
    end
    self._offsetY = self._offsetY + 320
end

function QUIWidgetSoulSpiritDetailCell:setDescInfo()
    local height = 50
    self._ccbOwner.node_desc:setPositionY(-self._offsetY)
    local desc = self._characterConfig.brief or ""
    self._ccbOwner.tf_desc:setString(desc)

    local len = q.wordLen(desc, 22, 22)
    local count = math.ceil(len/self._width)
    height = height + count * self._lineHeight
    self._offsetY = self._offsetY + height
end

function QUIWidgetSoulSpiritDetailCell:awakenlInfo()

    local value  = remote.soulSpirit:getFightAddCoefficientByData(self._soulSpiritInfo)
    local _,addCoefficientAptitude = remote.soulSpirit:getFightCoefficientByAptitude(self._characterConfig.aptitude)
    if value <= 0 then
        self._ccbOwner.node_awaken:setVisible(false)
        return
    end

    self._ccbOwner.node_awaken:setPositionY(-self._offsetY)
    self._ccbOwner.node_awaken:setVisible(true)
    local height = 0
    local describe = "出战属性+"..q.PropPercentHanderFun(value).."（初始出战属性为上阵魂师"..q.PropPercentHanderFun(addCoefficientAptitude).."）"
    local richText = QRichText.new(describe, 500, {stringType = 1, defaultColor = GAME_COLOR_LIGHT.normal, defaultSize = 20})
    richText:setAnchorPoint(ccp(0, 1))
    self._ccbOwner.node_awaken_desc:addChild(richText)
    height = richText:getContentSize().height
    self._ccbOwner.node_awaken_desc:setVisible(true)
    self._ccbOwner.tf_awaken_tip:setPositionY( self._ccbOwner.node_awaken_desc:getPositionY()-(height + 10))

    if height < 30 then height = 30 end
    local posY = self._ccbOwner.node_awaken_desc:getPositionY() - height - 20
    self._offsetY = self._offsetY - posY

end

function QUIWidgetSoulSpiritDetailCell:inheritlInfo()

    local quality = self._characterConfig.aptitude

    local inheritLv = self._soulSpiritInfo.devour_level or 0

    if quality < APTITUDE.SS or inheritLv <= 0 then
        self._ccbOwner.node_inherit:setVisible(false)
        return
    end
    self._ccbOwner.node_inherit:setPositionY(-self._offsetY)
    self._ccbOwner.node_inherit:setVisible(true)
    local height = 0

    local  curInheritMod = remote.soulSpirit:getSoulSpiritInheritConfig(inheritLv ,self._id)
    local skillId1 = string.split(curInheritMod.skill, ":")

    local skillConfig1 = QStaticDatabase.sharedDatabase():getSkillByID(tonumber(skillId1[1]))
    if skillConfig1 ~= nil then
        local  rnumSkillLevel = q.getRomanNumberalsByInt(inheritLv)
        local describe = "##e"..skillConfig1.name..rnumSkillLevel.."：##n"..skillConfig1.description
        describe = QColorLabel.replaceColorSign(describe or "", false)
        local richText = QRichText.new(describe, 500, {stringType = 1, defaultColor = GAME_COLOR_LIGHT.normal, defaultSize = 20})
        richText:setAnchorPoint(ccp(0, 1))
        self._ccbOwner.node_inherit_desc:addChild(richText)
        height = richText:getContentSize().height
        self._ccbOwner.node_inherit_desc:setVisible(true)
    end

    if height < 30 then height = 30 end
    local posY = self._ccbOwner.node_inherit_desc:getPositionY()  - height
    self._offsetY = self._offsetY - posY

end


function QUIWidgetSoulSpiritDetailCell:_onTriggerSkillInfo(e)
    if q.buttonEventShadow(e, self._ccbOwner.btn_skill) == false then return end
    app.sound:playSound("common_small")
    app:getNavigationManager():pushViewController(app.middleLayer, {uiType = QUIViewController.TYPE_DIALOG, uiClass = "QUIDialogSoulSpiritSkillInfo", 
        options = {id = self._id}})
end

function QUIWidgetSoulSpiritDetailCell:_onTriggerMaster(e)
    if q.buttonEventShadow(e, self._ccbOwner.btn_master) == false then return end
    app.sound:playSound("common_menu")
    app:getNavigationManager():pushViewController(app.middleLayer, {uiType = QUIViewController.TYPE_DIALOG, uiClass = "QUIDialogSoulSpiritMasterInfo", 
        options = {id = self._id}})
end

function QUIWidgetSoulSpiritDetailCell:_onTriggerHandBook(e)
    if q.buttonEventShadow(e, self._ccbOwner.btn_handBook) == false then return end
    app.sound:playSound("common_menu")
    local handBookInfo = remote.soulSpirit:getMyHandBookInfoByHandBookId(self._handBookId)
    local handBookLevel = handBookInfo and handBookInfo.grade or 0
    app:getNavigationManager():pushViewController(app.middleLayer, {uiType = QUIViewController.TYPE_DIALOG, uiClass = "QUIDialogSoulSpiritCombinationProp", 
        options={combinationId = self._handBookId, grade = handBookLevel}}, {isPopCurrentDialog = false})
end

function QUIWidgetSoulSpiritDetailCell:_onTriggerInherit(e)
    app.sound:playSound("common_small")
    app:getNavigationManager():pushViewController(app.middleLayer, {uiType = QUIViewController.TYPE_DIALOG, uiClass = "QUIDialogSoulSpiritInheritSkillInfo", 
        options = {id = self._id}})    
end

function QUIWidgetSoulSpiritDetailCell:getContentSize()
    local size = CCSize(550, self._offsetY)  -- 介绍文字的高度
    return size
end

return QUIWidgetSoulSpiritDetailCell