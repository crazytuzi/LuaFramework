--
-- zxs
-- 神技组件
--
local QUIWidget = import("..widgets.QUIWidget")
local QUIWidgetGodSkillCell = class("QUIWidgetGodSkillCell", QUIWidget)
local QUIWidgetHeroSkillBox = import("..widgets.QUIWidgetHeroSkillBox")
local QRichText = import("...utils.QRichText") 
local QColorLabel = import("...utils.QColorLabel")

function QUIWidgetGodSkillCell:ctor(options)
	local ccbFile = "ccb/Widget_artifact_client.ccbi"
	local callBacks = {
		}
	QUIWidgetGodSkillCell.super.ctor(self,ccbFile,callBacks,options)

	self._size = self._ccbOwner.node_size:getContentSize()
	self._ccbOwner.node_line:setVisible(false)
end

function QUIWidgetGodSkillCell:setInfo(skillInfo, actorId)
	self._size = self._ccbOwner.node_size:getContentSize()
	self._ccbOwner.node_icon:removeAllChildren()
	self._ccbOwner.node_desc:removeAllChildren()

	local skillBox = QUIWidgetHeroSkillBox.new()
	skillBox:setSkillID(skillInfo.skill_id)
	skillBox:setGodSkillShowLevel(skillInfo.real_level, actorId)
	local showLevel = remote.herosUtil:getGodSkillLevelByActorId(actorId)
	skillBox:setLock(showLevel < skillInfo.show_level)
	self._ccbOwner.node_icon:addChild(skillBox)
	self._ccbOwner.node_icon:setScale(0.9)

	local skillConfig = db:getSkillByID(skillInfo.skill_id)
	local color = GAME_COLOR_LIGHT.normal
	local desc = ""

	if showLevel >= skillInfo.show_level then
		color = GAME_COLOR_LIGHT.normal
		-- desc = string.gsub(skillConfig.description or "", "#%a+", "#n")
		desc = QColorLabel.replaceColorSign(skillConfig.description or "", false)
		self._ccbOwner.sp_mask:setVisible(false)
		self._ccbOwner.tf_title:setColor(GAME_COLOR_LIGHT.stress)
	else
		color = GAME_COLOR_LIGHT.notactive
		desc = string.gsub(skillConfig.description or "", "#%a+", "#c")
		self._ccbOwner.sp_mask:setVisible(true)
		self._ccbOwner.tf_title:setColor(GAME_COLOR_LIGHT.notactive)
	end

    local strArr  = string.split(desc,"\n") or {}
    local height = 0
    for _, v in pairs(strArr) do
        local richText = QRichText.new(v, 410, {stringType = 1, defaultColor = color, defaultSize = 22})
        richText:setAnchorPoint(ccp(0, 1))
        richText:setPositionY(-height)
		self._ccbOwner.node_desc:addChild(richText)
        height = height + richText:getContentSize().height
    end

    height = height - 80
	if height > 0 then
		self._size.height = self._size.height + height + 10
	end
	self._ccbOwner.tf_title:setString("【"..skillInfo.show_level.."阶效果】")
end

function QUIWidgetGodSkillCell:getContentSize()
	return self._size
end

return QUIWidgetGodSkillCell