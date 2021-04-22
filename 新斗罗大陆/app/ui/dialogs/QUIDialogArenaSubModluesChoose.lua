-- 
-- Kumo.Wang
-- 斗魂场子模块选择界面
--

local QUIDialogSubModluesChoose = import(".QUIDialogSubModluesChoose")
local QUIDialogArenaSubModluesChoose = class("QUIDialogArenaSubModluesChoose", QUIDialogSubModluesChoose)

local QUIViewController = import("..QUIViewController")
local QUIWidgetIconAniTips = import("..widgets.QUIWidgetIconAniTips")

function QUIDialogArenaSubModluesChoose:ctor(options)
	QUIDialogArenaSubModluesChoose.super.ctor(self,options)
end

function QUIDialogArenaSubModluesChoose:viewDidAppear()
	QUIDialogArenaSubModluesChoose.super.viewDidAppear(self)
end

function QUIDialogArenaSubModluesChoose:viewWillDisappear()
	QUIDialogArenaSubModluesChoose.super.viewWillDisappear(self)
end

function QUIDialogArenaSubModluesChoose:init()
	if q.isEmpty(self.data) then
		self.data = {}
		table.insert(self.data, {index = 1, itemClassName = "QUIWidgetArenaSubModluesChoose", iconClassName = "QUIWidgetNormalArenaModuleOption", 
			fightTipsFunc = handler(remote.arena, remote.arena.getTips)--[[, redTipsFunc = handler(remote.arena, remote.arena.getArenaTips)]]})
	end

	if app.unlock:getUnlockSotoTeam() then
		table.insert(self.data, {index = 2, itemClassName = "QUIWidgetArenaSubModluesChoose", iconClassName = "QUIWidgetSotoArenaModuleOption", 
			fightTipsFunc = handler(remote.sotoTeam, remote.sotoTeam.checkFightRedTips)--[[, redTipsFunc = handler(remote.sotoTeam, remote.sotoTeam.checkRedTips)]]})
	end

	if remote.silvesArena:checkUnlock() then
		table.insert(self.data, {index = 3, itemClassName = "QUIWidgetArenaSubModluesChoose", iconClassName = "QUIWidgetSilvesArenaModuleOption", 
			fightTipsFunc = handler(remote.silvesArena, remote.silvesArena.checkFightTips)--[[, redTipsFunc = handler(remote.silvesArena, remote.silvesArena.checkRedTips)]], stakeTipsFunc = handler(remote.silvesArena, remote.silvesArena.checkStakeRedTips)})
	end

	table.sort(self.data, function(a, b)
		return a.index < b.index
	end)

	QKumo(self.data)

	self:initListView()
end

function QUIDialogArenaSubModluesChoose:chooseModule(info)
	print("QUIDialogArenaSubModluesChoose:chooseModule() ")
	QKumo(info)
	if info.index == 1 then
		remote.arena:openArena()
	elseif info.index == 2 then
		remote.sotoTeam:openDialog()
	elseif info.index == 3 then
		remote.silvesArena:openDialog()
	end
end

return QUIDialogArenaSubModluesChoose
