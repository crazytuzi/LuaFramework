--
-- zxs
-- 真身技能组件
--
local QUIWidget = import("...widgets.QUIWidget")
local QUIWidgetArtifactSkillCell = class("QUIWidgetArtifactSkillCell", QUIWidget)
local QUIWidgetArtifactSkill = import("...widgets.artifact.QUIWidgetArtifactSkill")
local QRichText = import("....utils.QRichText") 
local QColorLabel = import("....utils.QColorLabel")

function QUIWidgetArtifactSkillCell:ctor(options)
	local ccbFile = "ccb/Widget_artifact_client.ccbi"
	local callBacks = {
		}
	QUIWidgetArtifactSkillCell.super.ctor(self,ccbFile,callBacks,options)

	self._size = self._ccbOwner.node_size:getContentSize()
end

function QUIWidgetArtifactSkillCell:setInfo(skillInfo, artifactSkills, index)
	local isHave = false
	if artifactSkills[skillInfo.skill_id] then
		isHave = true
	end
	self._size = self._ccbOwner.node_size:getContentSize()
	self._ccbOwner.node_icon:removeAllChildren()
	self._ccbOwner.node_desc:removeAllChildren()

	local skillBox = QUIWidgetArtifactSkill.new()
	skillBox:setSkill(skillInfo)
	skillBox:setSkillSlot(index)
	skillBox:setName("")
	self._ccbOwner.node_icon:addChild(skillBox)

	local skillConfig = db:getSkillByID(skillInfo.skill_id)
	local color = GAME_COLOR_LIGHT.normal
	local desc = ""
	if isHave then
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
	self._ccbOwner.node_line:setPositionY(-self._size.height+10)
	self._ccbOwner.tf_title:setString("【"..(skillConfig.name or "").."】")
end

function QUIWidgetArtifactSkillCell:getContentSize()
	return self._size
end

return QUIWidgetArtifactSkillCell