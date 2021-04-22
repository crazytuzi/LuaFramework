-- @Author: liaoxianbo
-- @Date:   2020-08-06 18:06:43
-- @Last Modified by:   liaoxianbo
-- @Last Modified time: 2020-08-14 14:40:22
local QUIWidget = import("..widgets.QUIWidget")
local QUIWidgetMazeExploreRecordCell = class("QUIWidgetMazeExploreRecordCell", QUIWidget)
local QRichText = import("...utils.QRichText") 
local QActorProp = import("...models.QActorProp")
local QColorLabel = import("...utils.QColorLabel")

function QUIWidgetMazeExploreRecordCell:ctor(options)
	local ccbFile = "ccb/Widget_Godarm_skill.ccbi"
	local callBacks = {
		}
	QUIWidgetMazeExploreRecordCell.super.ctor(self,ccbFile,callBacks,options)

	self._ccbOwner.node_size:setContentSize(0, 0)
	self._ccbOwner.node_skill:setVisible(false)
    self._ccbOwner.node_talent:setVisible(false)
    self._ccbOwner.tf_talent_limit:setVisible(false)
    self._ccbOwner.tf_soul_talent_desc:setVisible(false)
end

function QUIWidgetMazeExploreRecordCell:getContentSize()
	return self._ccbOwner.node_size:getContentSize()
end

function QUIWidgetMazeExploreRecordCell:setMazeExploreRecordInfo(recordConfig)

    if q.isEmpty(recordConfig) then return end

    self._ccbOwner.node_talent:setVisible(true)

    local isActivate = true
    local descColor = isActivate and COLORS.j or COLORS.n
    local titleColor = isActivate and COLORS.k or COLORS.n
    local limitColor = isActivate and COLORS.J or COLORS.n

    self._ccbOwner.tf_talent_title:setString("【"..recordConfig.title.."】")
    self._ccbOwner.tf_talent_title:setColor(titleColor)

    self._ccbOwner.tf_talent_desc:setVisible(false)
	self._ccbOwner.node_des:removeAllChildren()
	local richText = QRichText.new(recordConfig.des, 516, {autoCenter = true, stringType = 1, defaultSize = 22})
	richText:setAnchorPoint(ccp(0.5,1))
	self._ccbOwner.node_des:addChild(richText)


    local richTextHeight = richText:getContentSize().height

    self._ccbOwner.node_size:setContentSize(516, richTextHeight + 60)
end

return QUIWidgetMazeExploreRecordCell
