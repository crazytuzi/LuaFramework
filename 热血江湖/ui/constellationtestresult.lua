-------------------------------------------------------
module(..., package.seeall)

local require = require;

local ui = require("ui/base");

-------------------------------------------------------

wnd_constellationTestResult = i3k_class("wnd_constellationTestResult", ui.wnd_base)

function wnd_constellationTestResult:ctor()
	self.groupID = 0
end

function wnd_constellationTestResult:configure()
	local widgets = self._layout.vars
	widgets.close_btn:onClick(self, self.onCloseUI)
	widgets.share_btn:onClick(self, self.onShare)
	
end

function wnd_constellationTestResult:refresh(score, sex, groupID, role_name, isShareOpen)
	self.groupID = groupID
	self:setResult(score, sex, groupID, role_name, isShareOpen)
end

function wnd_constellationTestResult:setResult(score, sex, groupID, role_name, isShareOpen)
	local widgets = self._layout.vars
	for k,v in ipairs(i3k_db_mood_diary_constellation_test_result) do
		if v.testResultGroupID == groupID and v.matchType == sex and score >= v.countFloor and score <= v.countCelling then
			widgets.des:setText(v.resultDes)
			widgets.result_pic:setImage(g_i3k_db.i3k_db_get_icon_path(v.resultIcon))
		end
	end
	widgets.result_des:setText(role_name .. "的" .. i3k_db_mood_diary_constellation_test_name[groupID].testName)
	if isShareOpen then
		widgets.share_btn:setVisible(false)
	end
end

function wnd_constellationTestResult:onShare(sender)
	g_i3k_ui_mgr:OpenUI(eUIID_ConstellationTestShare)
	g_i3k_ui_mgr:RefreshUI(eUIID_ConstellationTestShare, self.groupID)
end

function wnd_create(layout)
	local wnd = wnd_constellationTestResult.new()
	wnd:create(layout)
	return wnd
end
