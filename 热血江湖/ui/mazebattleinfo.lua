module(..., package.seeall)

local require = require;

local ui = require("ui/base");
-------------------------------------------------------
wnd_mazeBattleInfo = i3k_class("wnd_mazeBattleInfo", ui.wnd_base)

local ACT_BENIFIT = 1

function wnd_mazeBattleInfo:ctor()
end

function wnd_mazeBattleInfo:configure()
	local widgets = self._layout.vars
	widgets.checkResult:onClick(self, self.openBenifitUI)
	widgets.closeBtn:onClick(self, self.onCloseAnisBtn)
	widgets.openBtn:onClick(self, self.onOpenAnisBtn)
	widgets.team:onClick(self, function()
		g_i3k_ui_mgr:PopupTipMessage(i3k_get_string(49))
	end
	)
	widgets.closeBtn:onClick(self, self.onCloseAnisBtn)
	widgets.openBtn:onClick(self, self.onOpenAnisBtn)
end

function wnd_mazeBattleInfo:refresh()
	local mazeData = g_i3k_game_context:getBattleMazeData()
	self:setTntNumText(mazeData)
	self:setMiningNumText(mazeData)
	local widgets = self._layout.vars
	widgets.name:setText(i3k_get_string(17760))
	self:refreshTotalExp(mazeData)
end

function wnd_mazeBattleInfo:setTntNumText(mazeData)
	if not mazeData then
		return
end

	local str = i3k_get_string(17761, mazeData.transferItemCnt) 
	local widgets = self._layout.vars
	widgets.tntNum:setText(str)
end

function wnd_mazeBattleInfo:setMiningNumText(mazeData)
	if not mazeData then
		return
end

	local allTimes = i3k_db_maze_Area[mazeData.curZoneID].resourceTimes
	local str = i3k_get_string(17762, allTimes - mazeData.zoneMineralTimes, allTimes)
	local widgets = self._layout.vars
	widgets.miningNum:setText(str)
		end

function wnd_mazeBattleInfo:refreshTotalExp(mazeData)
	if not mazeData then
		return
	end
	
	self._layout.vars.des4:setText(i3k_get_string(17793, mazeData.totalExp))
end

function wnd_mazeBattleInfo:openBenifitUI(sender)
	i3k_sbean.sync_maze_commongain(ACT_BENIFIT)
end

function wnd_mazeBattleInfo:onCloseAnisBtn(sender)
	local widgets = self._layout.vars
	widgets.closeBtn:hide()
	self._layout.anis.c_ru.play(
	function()
		widgets.openBtn:show()
	end)
end

function wnd_mazeBattleInfo:onOpenAnisBtn(sender)
	local widgets = self._layout.vars
	widgets.openBtn:hide()
	self._layout.anis.c_chu.play(
	function()
		widgets.closeBtn:show()
	end)
end

function wnd_create(layout, ...)
	local wnd = wnd_mazeBattleInfo.new()
	wnd:create(layout, ...)
	return wnd
end