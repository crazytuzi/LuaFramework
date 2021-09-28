-------------------------------------------------------
module(..., package.seeall)

local require = require;

local ui = require("ui/base");

-------------------------------------------------------
wnd_knightly_detective_leader = i3k_class("wnd_knightly_detective_leader", ui.wnd_base)

local clueTextWidget = "ui/widgets/guiyingwangluo3t"

function wnd_knightly_detective_leader:ctor()
	self._spyData = nil
	self._collectClue = {}
end

function wnd_knightly_detective_leader:configure()
	self._layout.vars.close:onClick(self, self.onCloseUI)
	self._layout.vars.showLeaderBtn:onClick(self, self.onShowLeaderBtn)
end

function wnd_knightly_detective_leader:refresh()
	self._layout.vars.clueScroll:removeAllChildren()
	self._spyData = g_i3k_game_context:getKnightlyDetectiveData()
	self:getCollectClue()
	local haveAllClue = true
	for k, v in ipairs(i3k_db_knightly_detective_common.clue) do
		local node = require(clueTextWidget)()
		node.vars.clueType:setText(i3k_get_string(18263, k))
		if self._collectClue[k] then
			node.vars.clueDetail:setText(i3k_db_knightly_detective_ringleader[self._spyData.boss].description[v].brief)
			node.vars.trueIcon:show()
			node.vars.falseIcon:hide()
		else
			haveAllClue = false
			node.vars.clueDetail:setText(i3k_get_string(18195))
			node.vars.trueIcon:hide()
			node.vars.falseIcon:show()
		end
		self._layout.vars.clueScroll:addItem(node)
	end
	if haveAllClue then
		self._layout.vars.ownClue:setText(i3k_get_string(18196))
	else
		self._layout.vars.ownClue:setText(i3k_get_string(18193))
	end
	if next(self._collectClue) then
		self._layout.vars.successRate:setText(string.format("%s%%", i3k_db_knightly_detective_common.successRate[table.nums(self._collectClue)]/100))
	else
		self._layout.vars.successRate:setText("0%")
	end
end

function wnd_knightly_detective_leader:getCollectClue()
	self._collectClue = {}
	if self._spyData and self._spyData.finishedMembers then
		if self._spyData.finishedMembers then
			for k, v in ipairs(self._spyData.finishedMembers) do
				local clueType = i3k_db_knightly_detective_members[v].clueType
				if clueType ~= 0 then
					self._collectClue[clueType] = true
				end
			end
		end
	end
end

function wnd_knightly_detective_leader:onShowLeaderBtn(sender)
	local surveyMembers = (not self._spyData.surveyMembers) and 0 or #self._spyData.surveyMembers
	if self._spyData.chasingCnt == #i3k_db_knightly_detective_common.clue then
		i3k_sbean.spy_finding_boss()
	else
		g_i3k_ui_mgr:PopupTipMessage(i3k_get_string(18197))
	end
end

function wnd_create(layout)
	local wnd = wnd_knightly_detective_leader.new()
	wnd:create(layout)
	return wnd
end