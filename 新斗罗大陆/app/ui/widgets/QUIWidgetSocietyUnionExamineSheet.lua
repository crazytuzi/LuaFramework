--[[	
	文件名称：QUIWidgetSocietyUnionExamineSheet.lua
	创建时间：2016-03-25 17:05:49
	作者：nieming
	描述：QUIWidgetSocietyUnionExamineSheet 审核宗门申请界面item
]]

local QUIWidget = import(".QUIWidget")
local QUIWidgetSocietyUnionExamineSheet = class("QUIWidgetSocietyUnionExamineSheet", QUIWidget)
local QUIWidgetAvatar = import("..widgets.QUIWidgetAvatar")

--初始化
function QUIWidgetSocietyUnionExamineSheet:ctor(options)
	local ccbFile = "Widget_society_union_examine_sheet.ccbi"
	local callBacks = {
	}
	QUIWidgetSocietyUnionExamineSheet.super.ctor(self,ccbFile,callBacks,options)
	--代码
end

--describe：onEnter 
--function QUIWidgetSocietyUnionExamineSheet:onEnter()
	----代码
--end

--describe：onExit 
--function QUIWidgetSocietyUnionExamineSheet:onExit()
	----代码
--end

--describe：setInfo 
function QUIWidgetSocietyUnionExamineSheet:setInfo(info)
	--代码
	self._info = info
	if not self._avatar then
		self._avatar = QUIWidgetAvatar.new(info.avatar)
		self._avatar:setSilvesArenaPeak(info.championCount)
	    self._ccbOwner.nodeIcon:addChild(self._avatar)
	else
		self._avatar:setInfo(info.avatar)
		self._avatar:setSilvesArenaPeak(info.championCount)
	end
	self._ccbOwner.memberLevel:setString("LV."..(info.level or 1))
	self._ccbOwner.memberName:setString(info.name or "")
	self._ccbOwner.vipNum:setString("VIP"..(info.vip or ""))

	if info.lastLeaveTime ~= nil and info.lastLeaveTime > 0 then
		local lastLeaveTime = info.lastLeaveTime/1000
		if lastLeaveTime > HOUR then
			local hour = math.floor(lastLeaveTime/HOUR)
			if hour < 24 then
				self._ccbOwner.time:setString(string.format("%s小时前", hour))
			else
				self._ccbOwner.time:setString(string.format("%s天前", math.floor(hour/24)))
			end
		else
			self._ccbOwner.time:setString(string.format("%s分前", math.floor(lastLeaveTime/MIN)))
		end
	end

	if info.force then
		if info.force > 1000000 then
			self._ccbOwner.fightNum:setString(math.floor(info.force/10000).."万")
		else
			self._ccbOwner.fightNum:setString(info.force)
		end
	end
end

--describe：getContentSize 
function QUIWidgetSocietyUnionExamineSheet:getContentSize()
	--代码
	return self._ccbOwner.btnLook:getContentSize()
end

return QUIWidgetSocietyUnionExamineSheet
