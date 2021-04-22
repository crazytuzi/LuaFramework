-- @Author: liaoxianbo
-- @Date:   2019-09-09 11:27:56
-- @Last Modified by:   liaoxianbo
-- @Last Modified time: 2019-09-11 17:06:40
local QUIWidget = import("..widgets.QUIWidget")
local QUIWidgetGemstoneSkillInfo = class("QUIWidgetGemstoneSkillInfo", QUIWidget)

local QNavigationController = import("...controllers.QNavigationController")
local QStaticDatabase = import("...controllers.QStaticDatabase")
local QUIViewController = import("..QUIViewController")
local QRichText = import("...utils.QRichText") 
local QActorProp = import("...models.QActorProp")
local QColorLabel = import("...utils.QColorLabel")

function QUIWidgetGemstoneSkillInfo:ctor(options)
	local ccbFile = "ccb/Widget_SoulSpirit_SkillInfo.ccbi"
    local callBacks = {
		{ccbCallbackName = "onTriggerClose", callback = handler(self, self._onTriggerClose)},
    }
    QUIWidgetGemstoneSkillInfo.super.ctor(self, ccbFile, callBacks, options)
  
	cc.GameObject.extend(self)
	self:addComponent("components.behavior.EventProtocol"):exportMethods()

	self._ccbOwner.node_size:setContentSize(0, 0)
	self._ccbOwner.node_skill:setVisible(false)
    self._ccbOwner.node_master:setVisible(false)

end

function QUIWidgetGemstoneSkillInfo:setGemadvanceSkillInfo( advancedConfig ,godLevel)
    if not advancedConfig or next(advancedConfig) == nil then return end
    if advancedConfig.level == 0 then return end
    
    self._ccbOwner.node_skill:setVisible(true)

    local compareLevel = tonumber(advancedConfig.evolution_level)
    local isActivate = godLevel >= compareLevel

    local descColor = isActivate and COLORS.j or COLORS.n
    local titleColor = isActivate and COLORS.k or COLORS.n

    local skillConfig = db:getSkillByID(tonumber(advancedConfig.gem_evolution_skill))

    local height1 = 0
    if skillConfig ~= nil then
		self._ccbOwner.tf_skill_title:setString("【"..skillConfig.name.."】")
		self._ccbOwner.tf_skill_title:setColor(titleColor)

    	self._ccbOwner.node_icon1:setTexture(CCTextureCache:sharedTextureCache():addImage(skillConfig.icon))
    	self._ccbOwner.sp_mask1:setVisible(not isActivate)

        local describe = skillConfig.description
        if not isActivate then
            describe = QColorLabel.removeColorSign(describe)
        else
            describe = QColorLabel.replaceColorSign(describe or "", false)
        end
        local richText = QRichText.new(describe, 414, {stringType = 1, defaultColor = descColor, defaultSize = 22})
        richText:setAnchorPoint(ccp(0, 1))
        self._ccbOwner.node_desc1:removeAllChildren()
        self._ccbOwner.node_desc1:addChild(richText)
        height1 = math.max(richText:getContentSize().height, self._ccbOwner.node_icon1:getContentSize().height)
        self._ccbOwner.node_skill1:setVisible(true)
    end
   	self._ccbOwner.node_skill2:setVisible(false)
    local posY = self._ccbOwner.node_skill1:getPositionY()-height1-20
    self._ccbOwner.node_line:setPositionY(posY)

	self._ccbOwner.node_size:setContentSize(510, -posY + 20)
end

function QUIWidgetGemstoneSkillInfo:setGemMixSuitSkillInfo( mixSuitConfig ,activateMixLevel)
    if not mixSuitConfig or next(mixSuitConfig) == nil then return end
    self._ccbOwner.node_skill:setVisible(true)

    local compareLevel = tonumber(mixSuitConfig.level)
    local isActivate = activateMixLevel >= compareLevel

    local descColor = isActivate and COLORS.j or COLORS.n
    local titleColor = isActivate and COLORS.k or COLORS.n

    local skillIdTbl = string.split(mixSuitConfig.suit_skill , ";")
    local skillId = skillIdTbl[1]

    if skillId == nil then return end
    local height1 = 0
    local skillConfig = db:getSkillByID(tonumber(skillId))
    if skillConfig ~= nil then
        self._ccbOwner.tf_skill_title:setString("【"..skillConfig.name.."】")
        self._ccbOwner.tf_skill_title:setColor(titleColor)

        self._ccbOwner.node_icon1:setTexture(CCTextureCache:sharedTextureCache():addImage(skillConfig.icon))
        self._ccbOwner.sp_mask1:setVisible(not isActivate)

        -- local describe = skillConfig.description
        -- if not isActivate then
        --     describe = QColorLabel.removeColorSign(describe)
        -- else
        --     describe = QColorLabel.replaceColorSign(describe or "", false)
        -- end
        -- local richText = QRichText.new(describe, 414, {stringType = 1, defaultColor = descColor, defaultSize = 22})
        -- richText:setAnchorPoint(ccp(0, 1))

        self._ccbOwner.node_desc1:removeAllChildren()
        local describe = skillConfig.description
        describe = QColorLabel.removeColorSign(describe)
        local color = GAME_COLOR_LIGHT.notactive
        if isActivate then
            describe = "##e【"..(skillConfig.name or "").."】##n"..describe
            color = GAME_COLOR_LIGHT.normal
        else
            describe = "【"..(skillConfig.name or "").."】"..describe
        end
        local text = QColorLabel:create(describe, 420, nil, nil, 18, color)
        text:setAnchorPoint(ccp(0, 1))
        local tfHeight = text:getContentSize().height
        self._ccbOwner.node_desc1:addChild(text)
        local heightNum =  text:getContentSize().height
        local heightNum2 = self._ccbOwner.node_icon1:getContentSize().height
        height1 = math.max(heightNum, heightNum2)
        self._ccbOwner.node_skill1:setVisible(true)
    end
    self._ccbOwner.node_skill2:setVisible(false)
    local posY = self._ccbOwner.node_skill1:getPositionY()-height1-20
    self._ccbOwner.node_line:setPositionY(posY)
    self._ccbOwner.node_size:setContentSize(510, -posY + 20)
end


function QUIWidgetGemstoneSkillInfo:onEnter()
end

function QUIWidgetGemstoneSkillInfo:onExit()
end

function QUIWidgetGemstoneSkillInfo:getContentSize()
	return self._ccbOwner.node_size:getContentSize()
end

return QUIWidgetGemstoneSkillInfo
