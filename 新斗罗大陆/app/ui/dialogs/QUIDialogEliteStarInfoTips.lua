--[[	
	文件名称：QUIDialogEliteStarInfoTips.lua
	创建时间：2016-09-13 12:04:25
	作者：nieming
	描述：QUIDialogEliteStarInfoTips
]]

local QUIDialog = import(".QUIDialog")
local QUIDialogEliteStarInfoTips = class("QUIDialogEliteStarInfoTips", QUIDialog)
local QNavigationController = import("...controllers.QNavigationController")
local QStaticDatabase = import("...controllers.QStaticDatabase")

--初始化
function QUIDialogEliteStarInfoTips:ctor(options)
	local ccbFile = "Dialog_EliteInfo001_tips.ccbi"
	local callBacks = {
	}
	QUIDialogEliteStarInfoTips.super.ctor(self,ccbFile,callBacks,options)
	--代码
	if not options then
		options = {}
	end
	self.dungeon_id = options.dungeonId

	local dungeonTargetConfig = QStaticDatabase:sharedDatabase():getDungeonTargetByID(self.dungeon_id)

	if 	dungeonTargetConfig and #dungeonTargetConfig >=3 then
		self._ccbOwner.tf_condition3:setString(":   "..(dungeonTargetConfig[1].target_text or ""))
		self._ccbOwner.tf_condition2:setString(":   "..(dungeonTargetConfig[2].target_text or ""))
		self._ccbOwner.tf_condition1:setString(":   "..(dungeonTargetConfig[3].target_text or ""))
	end

end

--describe：关闭对话框
function QUIDialogEliteStarInfoTips:close( )
	self:playEffectOut()
end


function QUIDialogEliteStarInfoTips:viewDidAppear()
	QUIDialogEliteStarInfoTips.super.viewDidAppear(self)
	--代码
end

function QUIDialogEliteStarInfoTips:viewWillDisappear()
	QUIDialogEliteStarInfoTips.super.viewWillDisappear(self)
	--代码
end

function QUIDialogEliteStarInfoTips:viewAnimationOutHandler()
	app:getNavigationManager():popViewController(app.middleLayer, QNavigationController.POP_TOP_CONTROLLER)
	--代码
end

--describe：viewAnimationInHandler 
--function QUIDialogEliteStarInfoTips:viewAnimationInHandler()
	----代码
--end

--describe：点击Dialog外  事件处理 
function QUIDialogEliteStarInfoTips:_backClickHandler()
	--代码
	self:close()
end

return QUIDialogEliteStarInfoTips
