-- 
-- Kumo.Wang
-- 魂靈信息
-- 
local QUIWidget = import(".QUIWidget")
local QUIWidgetSoulSpiritInfoCell = class("QUIWidgetSoulSpiritInfoCell", QUIWidget)

local QUIViewController = import("...ui.QUIViewController")
local QUIWidgetActorDisplay = import("..widgets.actorDisplay.QUIWidgetActorDisplay")
local QActorProp = import("...models.QActorProp")
local QRichText = import("...utils.QRichText") 
local QColorLabel = import("...utils.QColorLabel")
local QStaticDatabase = import("...controllers.QStaticDatabase")
local QUIWidgetSoulSpiritHead = import("..widgets.QUIWidgetSoulSpiritHead")

function QUIWidgetSoulSpiritInfoCell:ctor(ccbFile,callBacks,options)
    local ccbFile = "ccb/Widget_SoulSpirit_Info_Cell.ccbi"
    local callBacks = {
        {ccbCallbackName = "onTriggerSkillInfo", callback = handler(self, self._onTriggerSkillInfo)},
        -- {ccbCallbackName = "onTriggerMaster", callback = handler(self, self._onTriggerMaster)},
        {ccbCallbackName = "onTriggerHandBook", callback = handler(self, self._onTriggerHandBook)},
        {ccbCallbackName = "onTriggerInherit", callback = handler(self, self._onTriggerInherit)},

    }
    QUIWidgetSoulSpiritInfoCell.super.ctor(self, ccbFile, callBacks, options)
    q.setButtonEnableShadow(self._ccbOwner.btn_inherit)
    q.setButtonEnableShadow(self._ccbOwner.btn_awaken)
    
    self._isMockBattle =false
    cc.GameObject.extend(self)
    self:addComponent("components.behavior.EventProtocol"):exportMethods()
end

function QUIWidgetSoulSpiritInfoCell:setInfo(id)
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

    self:skillInfo()
    self:awakenlInfo() 
    self:inheritlInfo()
    self:setPropInfo()
    self:handBookInfo()
end

function QUIWidgetSoulSpiritInfoCell:setInfoData(id,_data , _isMockBattle)

    self._offsetY = 0
    self._id = id
    self._soulSpiritInfo = _data
    self._characterConfig = QStaticDatabase.sharedDatabase():getCharacterByID(self._id)
    
    self._isMockBattle = _isMockBattle or false
    self:skillInfo(self._soulSpiritInfo.grade)
    self:awakenlInfo() 
    self:inheritlInfo()
    self:setPropInfo()
    self:handBookInfo()
end

function QUIWidgetSoulSpiritInfoCell:setPropInfo()
    self._ccbOwner.node_prop:setPositionY(-self._offsetY)
    self._ccbOwner.node_prop:setVisible(true)
    local height = 180

    local propList = remote.soulSpirit:getPropListById(self._id, 0, 1)
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

function QUIWidgetSoulSpiritInfoCell:skillInfo(grade)
    local grade_ = grade or 0

    local height = 50
    self._ccbOwner.node_skill:setPositionY(-self._offsetY)
    self._ccbOwner.node_skill:setVisible(true)
    self._ccbOwner.node_skill1:setVisible(false)
    self._ccbOwner.node_skill2:setVisible(false)

    local gradeConfig = QStaticDatabase.sharedDatabase():getGradeByHeroActorLevel(self._id, grade_)
    -- 由于配表原因，这里用星级来显示技能等级
    local rnumSkillLevel = q.getRomanNumberalsByInt(grade_ + 1)
    if gradeConfig then
        local skillId1 = string.split(gradeConfig.soulspirit_pg, ":")
        local skillConfig1 = QStaticDatabase.sharedDatabase():getSkillByID(tonumber(skillId1[1]))
        local height1, height2 = 0, 0
        if skillConfig1 ~= nil then
            local describe = "##e"..skillConfig1.name..rnumSkillLevel.."：##n"..(skillConfig1.description or "")
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
            local describe = "##e"..skillConfig2.name..rnumSkillLevel.."：##n"..(skillConfig2.description or "")
            describe = QColorLabel.replaceColorSign(describe or "", false)
            local richText = QRichText.new(describe, 500, {stringType = 1, defaultColor = COLORS.j, defaultSize = 20})
            richText:setAnchorPoint(ccp(0, 1))
            self._ccbOwner.node_skill2:addChild(richText)
            height2 = richText:getContentSize().height

            local posY = self._ccbOwner.node_skill1:getPositionY()-height1
            self._ccbOwner.node_skill2:setPositionY(posY)
            self._ccbOwner.node_skill2:setVisible(true)
        end

        self._ccbOwner.node_skill_tips:setVisible(false)
        height = height + height1 + height2 
    end

    self._offsetY = self._offsetY+height
end

function QUIWidgetSoulSpiritInfoCell:handBookInfo()
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

    local handBookInfo = remote.soulSpirit:getMyHandBookInfoByHandBookId(handBookId)
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

        local num = handBookConfig.grade or 1
        if self._characterConfig.aptitude == APTITUDE.SS then
            num = num - 1
        end
        local descStr = "（魂灵同时达到"..num.."星）"
        local label = CCLabelTTF:create(descStr, global.font_default, 22)
        label:setAnchorPoint(ccp(0.5, 0.5))
        label:setPosition(ccp(264, -280))
        label:setColor(COLORS.k)
        self._ccbOwner.node_handBook:addChild(label)
    end
    self._offsetY = self._offsetY + 320
end


function QUIWidgetSoulSpiritInfoCell:awakenlInfo()

    self._ccbOwner.btn_awaken:setVisible(false)
    if self._soulSpiritInfo == nil then
        self._ccbOwner.node_inherit:setVisible(false)
        return
    end
    
    local value  = remote.soulSpirit:getFightAddCoefficientByData(self._soulSpiritInfo)
    if value <= 0 then
        self._ccbOwner.node_awaken:setVisible(false)
        return
    end

    self._ccbOwner.node_awaken:setPositionY(-self._offsetY)
    self._ccbOwner.node_awaken:setVisible(true)
    local height = 0
    local describe = "魂灵上阵时继承主力魂师属性增加数值为"..q.PropPercentHanderFun(value)
    local richText = QRichText.new(describe, 450, {stringType = 1, defaultColor = GAME_COLOR_LIGHT.normal, defaultSize = 20})
    richText:setAnchorPoint(ccp(0, 1))
    self._ccbOwner.node_awaken_desc:addChild(richText)
    height = richText:getContentSize().height
    self._ccbOwner.node_awaken_desc:setVisible(true)
    self._ccbOwner.tf_awaken_tip:setPositionY( self._ccbOwner.node_awaken_desc:getPositionY()-(height + 10))

    if height < 30 then height = 30 end
    local posY = self._ccbOwner.node_awaken_desc:getPositionY() + self._ccbOwner.node_awaken_desc:getPositionY() - height + 20
    self._offsetY = self._offsetY - posY

end

function QUIWidgetSoulSpiritInfoCell:inheritlInfo()

    if self._soulSpiritInfo == nil then
        self._ccbOwner.node_inherit:setVisible(false)
        return
    end

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
        local rnumSkillLevel = q.getRomanNumberalsByInt(inheritLv)
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



function QUIWidgetSoulSpiritInfoCell:_onTriggerSkillInfo(e)
    if q.buttonEventShadow(e, self._ccbOwner.btn_skill) == false then return end
    app.sound:playSound("common_small")
    if self._isMockBattle then

        local _grade = self._soulSpiritInfo.grade
        app:getNavigationManager():pushViewController(app.middleLayer, {uiType = QUIViewController.TYPE_DIALOG, uiClass = "QUIDialogSoulSpiritSkillInfo", 
            options = {id = self._id , isMockBattle = self._isMockBattle , grade =  _grade}})
    else
        app:getNavigationManager():pushViewController(app.middleLayer, {uiType = QUIViewController.TYPE_DIALOG, uiClass = "QUIDialogSoulSpiritSkillInfo", 
            options = {id = self._id}})
    end

end

-- function QUIWidgetSoulSpiritInfoCell:_onTriggerMaster()
--     app.sound:playSound("common_menu")
--     app:getNavigationManager():pushViewController(app.middleLayer, {uiType = QUIViewController.TYPE_DIALOG, uiClass = "QUIDialogSoulSpiritMasterInfo", 
--         options = {id = self._id}})
-- end

function QUIWidgetSoulSpiritInfoCell:_onTriggerHandBook(e)
    if q.buttonEventShadow(e, self._ccbOwner.btn_handBook) == false then return end
    app.sound:playSound("common_menu")
    local handBookInfo = remote.soulSpirit:getMyHandBookInfoByHandBookId(self._handBookId)
    local handBookLevel = handBookInfo and handBookInfo.grade or 0
    app:getNavigationManager():pushViewController(app.middleLayer, {uiType = QUIViewController.TYPE_DIALOG, uiClass = "QUIDialogSoulSpiritCombinationProp", 
        options={combinationId = self._handBookId, grade = handBookLevel}}, {isPopCurrentDialog = false})
end


function QUIWidgetSoulSpiritInfoCell:_onTriggerInherit(e)
    app.sound:playSound("common_small")
    if self._isMockBattle then
        local _inheritLv = self._soulSpiritInfo.devour_level or 0
        app:getNavigationManager():pushViewController(app.middleLayer, {uiType = QUIViewController.TYPE_DIALOG, uiClass = "QUIDialogSoulSpiritInheritSkillInfo", 
            options = {id = self._id , isMockBattle = self._isMockBattle , inheritLv =  _inheritLv}})
    else
       app:getNavigationManager():pushViewController(app.middleLayer, {uiType = QUIViewController.TYPE_DIALOG, uiClass = "QUIDialogSoulSpiritInheritSkillInfo", 
            options = {id = self._id}})   
    end
end


function QUIWidgetSoulSpiritInfoCell:getContentSize()
    local size = CCSize(500, self._offsetY)  -- 介绍文字的高度
    return size
end

return QUIWidgetSoulSpiritInfoCell