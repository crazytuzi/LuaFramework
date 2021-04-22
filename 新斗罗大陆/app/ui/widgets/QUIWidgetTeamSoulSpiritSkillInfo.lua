-- @Author: liaoxianbo
-- @Date:   2020-03-03 23:20:01
-- @Last Modified by:   xurui
-- @Last Modified time: 2020-04-22 11:58:49
local QUIWidget = import("..widgets.QUIWidget")
local QUIWidgetTeamSoulSpiritSkillInfo = class("QUIWidgetTeamSoulSpiritSkillInfo", QUIWidget)

local QNavigationController = import("...controllers.QNavigationController")
local QUIViewController = import("..QUIViewController")
local QColorLabel = import("...utils.QColorLabel")
local QRichText = import("...utils.QRichText")

function QUIWidgetTeamSoulSpiritSkillInfo:ctor(options)
	local ccbFile = "ccb/Widget_SoulSpirit_skilldesc.ccbi"
    local callBacks = {
		{ccbCallbackName = "onTriggerClose", callback = handler(self, self._onTriggerClose)},
    }
    QUIWidgetTeamSoulSpiritSkillInfo.super.ctor(self, ccbFile, callBacks, options)
  
	cc.GameObject.extend(self)
	self:addComponent("components.behavior.EventProtocol"):exportMethods()
	self._totalHeight = 30
end

function QUIWidgetTeamSoulSpiritSkillInfo:initSkillInfo(index,soulSpiritId,isCollegeTeam,chapterId,isMockBattle)

    -- self._ccbOwner.tf_title_skill:setString(string.format("魂灵%d上阵技能:",index))
	self._ccbOwner.tf_title_skill:setString("魂灵上阵技能:")
    self._ccbOwner.node_skill_1:removeAllChildren()
    self._ccbOwner.node_skill_2:removeAllChildren()
    self._ccbOwner.node_skill_3:removeAllChildren()
    local soulSpirit = nil
    if isCollegeTeam then
        soulSpirit = remote.collegetrain:getSpritInfoById(chapterId,soulSpiritId)
    elseif isMockBattle then
        soulSpirit = remote.mockbattle:getCardUiInfoById(soulSpiritId)
    else
        soulSpirit = remote.soulSpirit:getMySoulSpiritInfoById(soulSpiritId)           
    end       
    local offside = -25
	local gradeConfig = db:getGradeByHeroActorLevel(soulSpirit.id, soulSpirit.grade)
	if gradeConfig then
        local skillId1 = string.split(gradeConfig.soulspirit_pg, ":")
        local skillId2 = string.split(gradeConfig.soulspirit_dz, ":")
        local skillConfig1 = db:getSkillByID(tonumber(skillId1[1]))
        if skillConfig1 ~= nil then
            local describe = "##e"..(skillConfig1.name or "").."：##n"..(skillConfig1.description or "")
            describe = QColorLabel.replaceColorSign(describe)
    		describe = string.gsub(describe, "\n", "  ")
            local richText = QRichText.new(describe, 760, {stringType = 1, defaultColor = GAME_COLOR_LIGHT.normal, defaultSize = 20})
            richText:setAnchorPoint(ccp(0, 1))
            self._ccbOwner.node_skill_1:addChild(richText)
            self._totalHeight = self._totalHeight + richText:getContentSize().height

            offside = offside - richText:getContentSize().height 
        end

        local skillConfig2 = db:getSkillByID(tonumber(skillId2[1]))
        if skillConfig2 ~= nil then
            local describe = "##e"..(skillConfig2.name or "").."：##n"..(skillConfig2.description or "")
            describe = QColorLabel.replaceColorSign(describe)
    		describe = string.gsub(describe, "\n", "  ")
            local richText = QRichText.new(describe, 760, {stringType = 1, defaultColor = GAME_COLOR_LIGHT.normal, defaultSize = 20})
            richText:setAnchorPoint(ccp(0, 1))
            self._ccbOwner.node_skill_2:addChild(richText)
            self._ccbOwner.node_skill_2:setPositionY(offside)
            self._totalHeight = self._totalHeight + richText:getContentSize().height

            offside = offside - richText:getContentSize().height 

        end
    end	


    local  curInheritMod = remote.soulSpirit:getSoulSpiritInheritConfig(soulSpirit.devour_level ,soulSpirit.id)
    if curInheritMod then
        local skillId1 = string.split(curInheritMod.skill, ":")
        local skillConfig1 = db:getSkillByID(tonumber(skillId1[1]))
        if skillConfig1 ~= nil then
            local describe = "##e"..(skillConfig1.name or "").."：##n"..(skillConfig1.description or "")

            describe = QColorLabel.replaceColorSign(describe)
            describe = string.gsub(describe, "\n", "  ")
            local richText = QRichText.new(describe, 760, {stringType = 1, defaultColor = GAME_COLOR_LIGHT.normal, defaultSize = 20})
            richText:setAnchorPoint(ccp(0, 1))
            self._ccbOwner.node_skill_3:addChild(richText)
            self._totalHeight = self._totalHeight + richText:getContentSize().height
            self._ccbOwner.node_skill_3:setPositionY(offside)
            
        end
    end


end

function QUIWidgetTeamSoulSpiritSkillInfo:onEnter()
end

function QUIWidgetTeamSoulSpiritSkillInfo:onExit()
end

function QUIWidgetTeamSoulSpiritSkillInfo:getContentSize()
	return CCSize(760,self._totalHeight)
end

return QUIWidgetTeamSoulSpiritSkillInfo
