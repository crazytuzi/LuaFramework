-------------------------------------------------------
module(..., package.seeall)

local require = require;

local ui = require("ui/base");

-------------------------------------------------------
wnd_knightly_detective_survey = i3k_class("wnd_knightly_detective_survey", ui.wnd_base)

function wnd_knightly_detective_survey:ctor()
	self._memberId = 0
end

function wnd_knightly_detective_survey:configure()
	self._layout.vars.close:onClick(self, self.onCloseUI)
	self._layout.vars.surveyBtn:onClick(self, self.onSurveyBtn)
end

function wnd_knightly_detective_survey:refresh(memberId)
	self._memberId = memberId
	local spyData = g_i3k_game_context:getKnightlyDetectiveData()
	if memberId == 0 then
		self._layout.vars.surveyBtn:disableWithChildren()
		self._layout.vars.scroll:removeAllChildren()
		g_i3k_ui_mgr:AddTask(self, {}, function(ui)
			local textNode = require("ui/widgets/guiyingwangluo2t")()
			textNode.vars.desc:setText(i3k_db_knightly_detective_ringleader[spyData.boss].ringleaderDesc)
			ui._layout.vars.scroll:addItem(textNode)
			g_i3k_ui_mgr:AddTask(self, {textNode}, function(ui)
				local textUI = textNode.vars.desc
				local size = textNode.rootVar:getContentSize()
				local height = textUI:getInnerSize().height
				local width = size.width
				height = size.height > height and size.height or height
				textNode.rootVar:changeSizeInScroll(ui._layout.vars.scroll, width, height, true)
			end, 1)
		end, 1)
		--self._layout.vars.desc:setText(i3k_db_knightly_detective_ringleader[spyData.boss].ringleaderDesc)
	else
		--self._layout.vars.desc:setText(i3k_db_knightly_detective_members[memberId].memberDescription)
		self._layout.vars.scroll:removeAllChildren()
		g_i3k_ui_mgr:AddTask(self, {}, function(ui)
			local textNode = require("ui/widgets/guiyingwangluo2t")()
			textNode.vars.desc:setText(i3k_db_knightly_detective_members[memberId].memberDescription)
			ui._layout.vars.scroll:addItem(textNode)
			g_i3k_ui_mgr:AddTask(self, {textNode}, function(ui)
				local textUI = textNode.vars.desc
				local size = textNode.rootVar:getContentSize()
				local height = textUI:getInnerSize().height
				local width = size.width
				height = size.height > height and size.height or height
				textNode.rootVar:changeSizeInScroll(ui._layout.vars.scroll, width, height, true)
			end, 1)
		end, 1)
		if (spyData.surveyMembers and (table.indexof(spyData.surveyMembers, self._memberId) or #spyData.surveyMembers >= i3k_db_knightly_detective_common.surveyTimes)) or (spyData.finishedMembers and table.indexof(spyData.finishedMembers, self._memberId)) or spyData.chasingCnt >= i3k_db_knightly_detective_common.receiveTimes then
			self._layout.vars.surveyBtn:disableWithChildren()
		end
	end
end

function wnd_knightly_detective_survey:onSurveyBtn(sender)
	local spyData = g_i3k_game_context:getKnightlyDetectiveData()
	if self._memberId == 0 then
		
	else
		if not (spyData.surveyMembers and table.indexof(spyData.surveyMembers, self._memberId)) then
			local memberId = self._memberId
			local callback = function (isOk)
				if isOk then
					i3k_sbean.spy_survey(memberId)
				end
			end
			g_i3k_ui_mgr:ShowMessageBox2(i3k_get_string(18189), callback)
		end
	end
end

function wnd_create(layout)
	local wnd = wnd_knightly_detective_survey.new()
	wnd:create(layout)
	return wnd
end