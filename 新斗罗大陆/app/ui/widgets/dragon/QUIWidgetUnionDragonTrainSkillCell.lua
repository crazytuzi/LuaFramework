-- 
-- zxs
-- 技能
-- 
local QUIWidget = import("...widgets.QUIWidget")
local QUIWidgetUnionDragonTrainSkillCell = class("QUIWidgetUnionDragonTrainSkillCell", QUIWidget)
local QUIWidgetArtifactSkill = import("...widgets.artifact.QUIWidgetArtifactSkill")
local QRichText = import("....utils.QRichText") 

function QUIWidgetUnionDragonTrainSkillCell:ctor(options)
	local ccbFile = "ccb/Widget_artifact_client.ccbi"
	local callBacks = {
	}
	QUIWidgetUnionDragonTrainSkillCell.super.ctor(self,ccbFile,callBacks,options)

	self._size = self._ccbOwner.node_size:getContentSize()
end

function QUIWidgetUnionDragonTrainSkillCell:setInfo(info)
	if info.type == 2 then
		self._ccbOwner.node_head:setVisible(false)
		self._ccbOwner.node_skill:setVisible(false)
		self._ccbOwner.node_line:setVisible(false)

		self._size = self._ccbOwner.node_size:getContentSize()
		self._size.height = 40
		self._ccbOwner.tf_title:setString(info.name)
		if info.lock then
			self._ccbOwner.tf_title:setColor(GAME_COLOR_LIGHT.notactive)
		else
			self._ccbOwner.tf_title:setColor(GAME_COLOR_LIGHT.normal)
		end
	else
		self._ccbOwner.node_head:setVisible(true)
		self._ccbOwner.node_skill:setVisible(true)
		self._ccbOwner.node_line:setVisible(false)
		self:setSkillInfo(info)
	end
end

function QUIWidgetUnionDragonTrainSkillCell:setSkillInfo(skillInfo)
	self._size = self._ccbOwner.node_size:getContentSize()
	self._ccbOwner.node_icon:removeAllChildren()
	self._ccbOwner.node_desc:removeAllChildren()

	local skillBox = QUIWidgetArtifactSkill.new()
	skillBox:setSkill(skillInfo)
	skillBox:setName("")
	self._ccbOwner.node_icon:addChild(skillBox)

	local skillConfig = db:getSkillByID(skillInfo.skill_id)
	local color
	local desc = ""
	if skillInfo.lock then
		color = GAME_COLOR_LIGHT.notactive
		desc = string.gsub(skillConfig.description or "", "#%a+", "#c")
		self._ccbOwner.sp_mask:setVisible(true)
		self._ccbOwner.tf_title:setColor(GAME_COLOR_LIGHT.notactive)
	else
		color = GAME_COLOR_LIGHT.normal
		desc = string.gsub(skillConfig.description or "", "#%a+", "#n")
		self._ccbOwner.sp_mask:setVisible(false)
		self._ccbOwner.tf_title:setColor(GAME_COLOR_LIGHT.stress)
	end
    local strArr  = string.split(desc, "\n") or {}
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

function QUIWidgetUnionDragonTrainSkillCell:getContentSize()
	return self._size
end

return QUIWidgetUnionDragonTrainSkillCell