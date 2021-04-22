local QUIWidget = import("..widgets.QUIWidget")
local QUIWidgetSocietyUnionLevelGuideSheet = class("QUIWidgetSocietyUnionLevelGuideSheet", QUIWidget)

function QUIWidgetSocietyUnionLevelGuideSheet:ctor(options)
	local ccbFile = "Widget_society_union_level_guide_sheet.ccbi"
	local callBacks = {
	}
	QUIWidgetSocietyUnionLevelGuideSheet.super.ctor(self,ccbFile,callBacks,options)
end

function QUIWidgetSocietyUnionLevelGuideSheet:setInfo(data)
	self._ccbOwner.tf_name:setString(data.name)
	self._ccbOwner.tf_desc:setString(data.particulars_describe or "")
	local level = remote.union.consortia.level
	if level >= (data.closing_condition or 0) then
		self._ccbOwner.tf_unlock:setString("")
		self._ccbOwner.sp_complete:setVisible(true)
		-- self._ccbOwner.tf_unlock:setColor(QIDEA_QUALITY_COLOR.GREEN)
	else
		self._ccbOwner.tf_unlock:setString("宗门"..(data.closing_condition or 0).."级开启")
		self._ccbOwner.sp_complete:setVisible(false)
		-- self._ccbOwner.tf_unlock:setColor(QIDEA_QUALITY_COLOR.RED)
	end
	self._ccbOwner.node_icon:removeAllChildren()
    local sp = CCSprite:create(data.particulars_icon)
	-- local icon = string.split(data.icon, "/")
 --    CCSpriteFrameCache:sharedSpriteFrameCache():addSpriteFramesWithFile("ui/"..icon[1]..".plist")
 --    sp:setDisplayFrame(CCSpriteFrameCache:sharedSpriteFrameCache():spriteFrameByName(icon[2]))
    sp:setScale(1.2)
    self._ccbOwner.node_icon:addChild(sp)
end

function QUIWidgetSocietyUnionLevelGuideSheet:getContentSize()
	return self._ccbOwner.node_size:getContentSize()
end

return QUIWidgetSocietyUnionLevelGuideSheet