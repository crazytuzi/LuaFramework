local QUIWidget = import("..widgets.QUIWidget")
local QUIWidgetSkillPrompt = class("QUIWidgetSkillPrompt", QUIWidget)
local QUIWidgetHeroSkillBox = import("..widgets.QUIWidgetHeroSkillBox")

local QRichText = import("...utils.QRichText") 
local QColorLabel = import("...utils.QColorLabel")

local GAP = 20
local wordWidth = 20
local lineWidth = 329

function QUIWidgetSkillPrompt:ctor(options)
    local ccbFile = "ccb/Dialog_jinengxinxi.ccbi"
    local callBacks = {}
    QUIWidgetSkillPrompt.super.ctor(self, ccbFile, callBacks, options)
  
    if options ~= nil then
        self.skillId = options.skillId
        self.slotLevel = options.slotLevel
        self.params = options.params
    end
    self.params = self.params or {}

    self.isHave = false
    if self.slotLevel ~= nil then
        self.isHave = true
    end
    self.skillInfo = db:getSkillByID(self.skillId)
    self.skillDec = db:getSkillDataByIdAndLevel(self.skillInfo.id, self.slotLevel)
    self.skillNextDec = db:getSkillDataByIdAndLevel(self.skillInfo.id, self.slotLevel+1)
    self.size = self._ccbOwner.skill_bg:getContentSize() 
    self._ccbOwner.icon_bg:setVisible(false)

    self:skillTitleInfo()

    if self.skillInfo.icon then
        self:setIconPath()
    end

    -- 提前设置显示icon
    if self.params.showTitle ~= nil then
        self:setShowTitleIcon(self.params.showTitle)
    end


    if self.params.isTalent then
        self:setTalentInfo()
    else
        self:setSkillDescInfo()
    end

    if self.params.skillTitle and self.params.skillTitle ~= "" then
        self:setSkillDescTitle(self.params.skillTitle)
    end
    if self.params.showType ~= nil then
        self:setSkillTypeStated(self.params.showType)
    end
    if self.params.skillNamePos then
        self:setSkillNamePosOffset(self.params.skillNamePos.x, self.params.skillNamePos.y)
    end

end

function QUIWidgetSkillPrompt:setIconPath()
    if self._skillBox == nil then
        self._skillBox = QUIWidgetHeroSkillBox.new()
        self._skillBox:setLock(false)
        self._ccbOwner.node_icon:addChild(self._skillBox)
        self._ccbOwner.node_icon:setScale(1)
    end
    self._skillBox:setSkillID(self.skillId)
    self._skillBox:setGodSkillShowLevel(self.params.godGrade, self.params.actorId)
end
 
function QUIWidgetSkillPrompt:skillTitleInfo()
    if self.params.hideLevel == true then
        self._ccbOwner.skill_name:setString(self.skillInfo.name)
    else
        self._ccbOwner.skill_name:setString("LV.".. self.slotLevel .. " " .. self.skillInfo.name)
    end
    if self.skillInfo.description_type ~= nil then
        self._ccbOwner.skill_type:setString(self.skillInfo.description_type)
    else
        self._ccbOwner.skill_type:setVisible(false)
        self._ccbOwner.tf_skill_type_title:setVisible(false)
    end
end

function QUIWidgetSkillPrompt:setShortBg()
    local size = self._ccbOwner.skill_bg:getContentSize() 
    self._ccbOwner.skill_bg:setContentSize(CCSize(size.width, self._descH+225))
    self._ccbOwner.node_damage:setVisible(false)
    self._ccbOwner.node_line:setVisible(false)
    self:getView():setPositionY(-30)
end

function QUIWidgetSkillPrompt:setSkillDescInfo()
    local offsetY = 0
    local totalOffsetY = 0
    local diff = 5

    self._descH = 0

    -- set skill desc
    local desc = self.skillInfo.description or ""

    self._ccbOwner.skill_dec:setString("")

    local strArr  = string.split(desc,"\n") or {}
    local descHeight = 0
    for _, v in pairs(strArr) do
        local newskillDesc = QColorLabel.replaceColorSign(v,true)
        local newskillRichText = QRichText.new(newskillDesc, 360,{stringType = 1, defaultColor = COLORS.a, defaultSize = 20})
        newskillRichText:setAnchorPoint(ccp(0, 1))
        newskillRichText:setPositionY(-descHeight)
        self._ccbOwner.node_skill_desc:addChild(newskillRichText)
        descHeight = descHeight + newskillRichText:getContentSize().height
    end


    -- local newskillDesc = QColorLabel.replaceColorSign(desc,true)
    -- local newskillRichText = QRichText.new(newskillDesc, 360,{stringType = 1, defaultColor = COLORS.a, defaultSize = 20})
    -- newskillRichText:setAnchorPoint(ccp(0,1))
    -- self._ccbOwner.node_skill_desc:addChild(newskillRichText)
    -- local descHeight = newskillRichText:getContentSize().height

    -- self._ccbOwner.skill_dec:setString(QColorLabel.removeColorSign(desc))
    -- local descHeight = self._ccbOwner.skill_dec:getContentSize().height
    if descHeight > 2*GAP then
        offsetY = descHeight - (2 * GAP)
        self._descH = offsetY
    end

    totalOffsetY = offsetY
    local lineY = self._ccbOwner.node_line:getPositionY()
    self._ccbOwner.node_line:setPositionY(lineY-totalOffsetY)

    local positionY = self._ccbOwner.node_damage:getPositionY()
    self._ccbOwner.node_damage:setPositionY(positionY-totalOffsetY)

    offsetY = diff
    -- set skill current level damage
    if self.skillDec.description_1 ~= nil then
        local richText1 = QRichText.new({
                {oType = "font", content = "本级效果: ", size = wordWidth, color = ccc3(230,168,0)},
                {oType = "font", content = self.skillDec.description_1 or "", size = wordWidth, color = ccc3(230,168,0)},
            }, lineWidth)
        richText1:setAnchorPoint(ccp(0, 1))
        self._ccbOwner.tf_damage_node_1:addChild(richText1)
        richText1:setPositionY(offsetY)
        offsetY = offsetY+richText1:getContentSize().height
    end
    -- set skill next level damage
    if self.skillNextDec.description_1 ~= nil then
        local richText2 = QRichText.new({
                {oType = "font", content = "下级效果: ", size = wordWidth, color = ccc3(255,240,0)},
                {oType = "font", content = self.skillNextDec.description_1 or "", size = wordWidth, color = ccc3(255,240,0)},
            }, lineWidth)
        richText2:setAnchorPoint(ccp(0, 1))
        self._ccbOwner.tf_damage_node_1:addChild(richText2)
        richText2:setPositionY(-offsetY)
        offsetY = offsetY + richText2:getContentSize().height + diff
    end

    -- set skill strength by artifact
    if self.params.actorId ~= nil then
        local artifactSkills = remote.artifact:getSkillByHeroSkillId(self.params.actorId, self.skillId)
        if #artifactSkills > 0 then
            local learnSkill = nil
            local uiHeroModel = remote.herosUtil:getUIHeroByID(self.params.actorId)
            for _,skill in ipairs(artifactSkills) do
                local slotInfo = uiHeroModel:getArtifactSkillBySlot(skill.skill_order)
                if slotInfo.learnSkill ~= nil then
                    learnSkill = skill
                end
            end
            local learnDesc = "尚未觉醒"
            if learnSkill ~= nil then
                local skillConfig = db:getSkillDataByIdAndLevel(learnSkill.skill_id, 1)
                learnDesc = QColorLabel.removeColorSign(skillConfig.description_1 or "")
            end

            local richText3 = QRichText.new({
                    {oType = "font", content = "武魂真身效果: ", size = wordWidth, color = ccc3(237,215,177)},
                    {oType = "font", content = learnDesc, size = wordWidth, color = ccc3(62,249,0)},
                }, lineWidth)
            richText3:setAnchorPoint(ccp(0, 1))
            self._ccbOwner.tf_damage_node_1:addChild(richText3)
            richText3:setPositionY(-offsetY)
            offsetY = offsetY + richText3:getContentSize().height + diff
        end
    end

    -- set bg contentSize
    totalOffsetY = totalOffsetY + offsetY
    self._ccbOwner.skill_bg:setContentSize(CCSize(self.size.width, self.size.height + totalOffsetY))
    self:getView():setPositionY(totalOffsetY/2)
end

function QUIWidgetSkillPrompt:setTalentInfo()
    self._ccbOwner.tf_skill_type_title:setVisible(true)
    self._ccbOwner.skill_type:setVisible(true)
    self._ccbOwner.skill_type:setString("被动")
    self._ccbOwner.tf_desc_title:setString("天赋效果")
    self._ccbOwner.node_line:setVisible(false)
    self._ccbOwner.skill_dec:setString("")

    local desc = QColorLabel.replaceColorSign(self.params.desc or "", true)
    local strArr  = string.split(desc,"\n") or {}
    local height = 0
    for i, v in pairs(strArr) do
        local richText = QRichText.new(v, 360, {stringType = 1, defaultColor = GAME_COLOR_SHADOW.normal, defaultSize = 21})
        richText:setAnchorPoint(ccp(0, 1))
        richText:setPositionY(-height)
        self._ccbOwner.node_skill_desc:addChild(richText)
        height = height + richText:getContentSize().height
    end
    self._ccbOwner.skill_bg:setContentSize(CCSize(self.size.width, 200 + height))
    self:getView():setPositionY(height-display.height/2 +57)

end

function QUIWidgetSkillPrompt:setSkillDescTitle(title)
    self._ccbOwner.tf_desc_title:setString(title)
end

function QUIWidgetSkillPrompt:setSkillTypeStated(stated)
    self._ccbOwner.node_type:setVisible(stated)
end

function QUIWidgetSkillPrompt:setShowTitleIcon(stated)
    self._ccbOwner.node_title:setVisible(stated)
    if stated == false then
        self._ccbOwner.node_skill:setPositionY(100)
        self.size.height = self.size.height-160
    end
end

function QUIWidgetSkillPrompt:setSkillNamePosOffset(offsetX, offsetY)
    local position = ccp(self._ccbOwner.skill_name:getPosition())
    self._ccbOwner.skill_name:setPosition(position.x + offsetX, position.y + offsetY)
end

return QUIWidgetSkillPrompt