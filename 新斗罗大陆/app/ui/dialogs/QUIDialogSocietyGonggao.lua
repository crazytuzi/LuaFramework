--[[	
	文件名称：QUIDialogSocietyGonggao.lua
	创建时间：2016-04-28 14:32:45
	作者：nieming
	描述：QUIDialogSocietyGonggao
]]

local QUIDialog = import(".QUIDialog")
local QNavigationController = import("...controllers.QNavigationController")
local QUIDialogSocietyGonggao = class("QUIDialogSocietyGonggao", QUIDialog)
local QRichText = import("...utils.QRichText")
--初始化
function QUIDialogSocietyGonggao:ctor(options)
	local ccbFile = "Dialog_society_gonggao.ccbi"
	local callBacks = {
	}
	QUIDialogSocietyGonggao.super.ctor(self,ccbFile,callBacks,options)
	--代码
	self.isAnimation = true --是否动画显示


	if options then
	end

	local contentStr = remote.union.consortia.mainMessage or ""
	local title = "致所有成员："
	-- if self._isWelcome then
	-- 	contentStr = {
	-- 		{oType = "font", content = string.format("    欢迎来到%s，您已经是我们的一员了，快和小伙伴一起攻打副本，将获得丰厚的战利品！", (remote.union.consortia.name or "")), dimensions = CCSize(600, 0), hAlignment = kCCTextAlignmentLeft},
	-- 		{oType = "font", content = "    大家一起共创美好未来！~", dimensions = CCSize(600, 0), hAlignment = kCCTextAlignmentLeft},
	-- 	}
	-- 	title = (remote.user.nickname or "").."："
	-- end

	local richText = QRichText.new(nil,600, {stringType = 1, lineSpacing = 3, defaultColor = ccc3(80,26,2), defaultSize = 24})
	richText:setAnchorPoint(ccp(0,1))
	self._richText = richText
	self._ccbOwner.announcementStr:addChild(richText)

	self._richText:setString(contentStr)

	local author = remote.union.consortia.main_message_author
	if author and author ~= "" then
		local authorTbl = string.split(author, ",")
		local str = ""
		if authorTbl[1] == "3" then
			str = "宗主："
		elseif authorTbl[1] == "2" then
			str = "副宗主："
		end
		self._ccbOwner.presidentName:setString(str..authorTbl[2])
	else
		author = remote.union.consortia.presidentName or ""
		self._ccbOwner.presidentName:setString("宗主："..author)
	end
	self._ccbOwner.announcementTitle:setString(title or "")
end

--describe：关闭对话框
function QUIDialogSocietyGonggao:close( )
	app.sound:playSound("common_cancel")
	self:playEffectOut()
end

--describe：viewAnimationOutHandler 
function QUIDialogSocietyGonggao:viewAnimationOutHandler()
	--代码
	app:getNavigationManager():popViewController(app.middleLayer, QNavigationController.POP_TOP_CONTROLLER)
end


--describe：_backClickHandler 
function QUIDialogSocietyGonggao:_backClickHandler()
	--代码
	self:close()
end

return QUIDialogSocietyGonggao
