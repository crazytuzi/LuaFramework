--[[	
	文件名称：QUIDialogSocietyZhaomu.lua
	创建时间：2016-03-28 18:12:57
	作者：nieming
	描述：QUIDialogSocietyZhaomu
]]

local QUIDialog = import(".QUIDialog")
local QNavigationController = import("...controllers.QNavigationController")
local QUIDialogSocietyZhaomu = class("QUIDialogSocietyZhaomu", QUIDialog)
local QRichText = import("...utils.QRichText")

--初始化
function QUIDialogSocietyZhaomu:ctor(options)
	local ccbFile = "Dialog_society_zhaomu.ccbi"
	local callBacks = {
		{ccbCallbackName = "onTriggerClose", callback = handler(self, QUIDialogSocietyZhaomu._onTriggerClose)},
		{ccbCallbackName = "onTriggerConfirm", callback = handler(self, QUIDialogSocietyZhaomu._onTriggerConfirm)},
	}

	QUIDialogSocietyZhaomu.super.ctor(self,ccbFile,callBacks,options)
	--代码
	printTable(options)
	self.isAnimation = true
	if not options or not options.info then
		return
	end

	self._info = options.info
	self:setInfo()
end

--describe：
function QUIDialogSocietyZhaomu:_onTriggerClose()
	--代码
	self:close()
end

--describe：
function QUIDialogSocietyZhaomu:_onTriggerConfirm()
	--代码
	remote.union:unionApplyRequest(self._info.sid, function (data)
		self:close()
		if data.consortia.apply then
			app.tip:floatTip("申请成功！") 
		else
			app.tip:floatTip("加入成功！") 
		end
	end)

end

--describe：关闭对话框
function QUIDialogSocietyZhaomu:close( )
	app.sound:playSound("common_cancel")
	self:playEffectOut()
end

--describe：viewAnimationOutHandler 
function QUIDialogSocietyZhaomu:viewAnimationOutHandler()
	--代码
	app:getNavigationManager():popViewController(app.middleLayer, QNavigationController.POP_TOP_CONTROLLER)

end


function QUIDialogSocietyZhaomu:setInfo(  )
	-- body
	local richTextCfg = {
	  	{oType = "font", content = self._info.name or "",size = 22,color = COLORS.v},
        {oType = "font", content = "邀请魂师大人您的加入",size = 22,color = ccc3(247,223,183)},
	}
	if not self._richText then
		self._richText = QRichText.new(richTextCfg,560, {autoCenter = true})
		self._ccbOwner.richText:addChild(self._richText)
	else
		self._richText:setString(richTextCfg)
	end
	self._ccbOwner.applyTeamLevel:setString(string.format("(等级限制: %d级)",self._info.applyTeamLevel or ""))
	
	self._ccbOwner.notice:setString(self._info.notice or string.format("尊敬的魂师大人，%s欢迎您的加入！~",self._info.name))
end
--describe：viewDidAppear 
--function QUIDialogSocietyZhaomu:viewDidAppear()
	----代码
--end

--describe：viewWillDisappear 
--function QUIDialogSocietyZhaomu:viewWillDisappear()
	----代码
--end

--describe：viewAnimationInHandler 
--function QUIDialogSocietyZhaomu:viewAnimationInHandler()
	----代码
--end

--describe：_backClickHandler 
function QUIDialogSocietyZhaomu:_backClickHandler()
	--代码
	self:close()
end

return QUIDialogSocietyZhaomu
