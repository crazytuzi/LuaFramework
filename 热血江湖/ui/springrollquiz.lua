module(..., package.seeall)

local require = require

local ui = require("ui/base")

wnd_springRollQuiz = i3k_class("wnd_springRollQuiz", ui.wnd_base)

function wnd_springRollQuiz:ctor()
	self._answer = nil
	self._npcID = nil
end

function wnd_springRollQuiz:configure()
	local widgets = self._layout.vars
	
	self.close_btn = widgets.close_btn
	self.close_btn:onClick(self, self.onCloseUI)
	
	self.btn = widgets.btn
	self.btn:onClick(self, self.onBtnClick)
	
	self.quiz = widgets.quiz
	self.answer = widgets.answer
end

function wnd_springRollQuiz:refresh(npcID)
	self._npcID = npcID
	local groupID = g_i3k_game_context:getSpringRollGroupID()
	local quizCfg = i3k_db_spring_roll.npcConfig[groupID][npcID]
	local quizGroupID = quizCfg.args3
	local cfg = i3k_db_spring_roll.puzzle[quizGroupID]
	local userCfg = g_i3k_game_context:GetUserCfg()
	local quizID = userCfg:GetSpringRollQuizByID(npcID)
	if quizID == nil or cfg[quizID] == nil then
		quizID = math.random(1, #cfg)
		userCfg:SetSpringRollQuiz(npcID, quizID)
	end
	self.quiz:setText(cfg[quizID].question)
	self.answer:setText("")
	self._answer = cfg[quizID].answer
end

function wnd_springRollQuiz:onBtnClick(sender)
	local isSpringRollOpen = g_i3k_game_context:checkSpringRollOpen()
	if not isSpringRollOpen then
		g_i3k_ui_mgr:PopupTipMessage(i3k_get_string(19167))
		g_i3k_ui_mgr:CloseUI(eUIID_SpringRollQuiz)
		return
	end
	local answer = self.answer:getText()
	if answer == "" then
		g_i3k_ui_mgr:PopupTipMessage(i3k_get_string(19039))
		return
	end
	if answer ~= self._answer then
		g_i3k_ui_mgr:PopupTipMessage(i3k_get_string(19040))
		return
	end
	local times = g_i3k_game_context:getSpringRollNPCTimes(self._npcID)
	local npcInfo = g_i3k_game_context:getSpringRollNPCInfo(self._npcID)
	local maxTimes = npcInfo and npcInfo.args1 or 0
	if maxTimes == 0 then
		g_i3k_ui_mgr:PopupTipMessage(i3k_get_string(19052))
		return
	end
	if times >= maxTimes then
		g_i3k_ui_mgr:PopupTipMessage(i3k_get_string(19041))
		return
	end
	local totalTimes = g_i3k_game_context:getSpringRollTotalTimes()
	if totalTimes >= i3k_db_spring_roll.rollConfig.dayTotalTimes then
		g_i3k_ui_mgr:PopupTipMessage(i3k_get_string(19042))
		return
	end
	i3k_sbean.spring_lantern_join(self._npcID)
end

function wnd_create(layout, ...)
	local wnd = wnd_springRollQuiz.new()
	wnd:create(layout, ...)
	return wnd
end