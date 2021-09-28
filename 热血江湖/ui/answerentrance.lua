-------------------------------------------------------
module(..., package.seeall)

local require = require;

local ui = require("ui/base");

-------------------------------------------------------
wnd_answerEntrance = i3k_class("wnd_answerEntrance", ui.wnd_base)



function wnd_answerEntrance:ctor()

end

--级别
local openTable = {

	[g_ANSWER_TYPE_KEJU] = {test = g_i3k_game_context.GetKeJuOpenAndRed, openLevel = i3k_db_answer_questions_activity.needLvl},
	[g_ANSWER_TYPE_MILLIONS] = {test = g_i3k_game_context.GetMillionsAnswerState, openLevel = i3k_db_millions_answer_cfg.needLvl},	
	[g_ANSWER_TYPE_HEGEMONY] = {test = g_i3k_game_context.GetFiveHegemonyState, openLevel = i3k_db_five_contend_hegemony.cfg.needLvl},
}


function wnd_answerEntrance:configure()
	local widgets = self._layout.vars
	widgets.close_btn:onClick(self, self.onCloseUI)
	self._oldTime = i3k_game_get_time()
	--self._scroll = widgets.scroll
end

function wnd_answerEntrance:refresh()
	self:setAllItems()
end

function wnd_answerEntrance:onUpdate(Time)

	if i3k_game_get_time() - self._oldTime > 1 then		
		self:updateItems()
		self._oldTime = i3k_game_get_time()
	end
end

function wnd_answerEntrance:setAllItems()
	local widgets = self._layout.vars
	for i, cfg in ipairs(openTable) do
		widgets["btn"..i]:onClick(self, self.onSelectActivity, i)
		self:setItem(cfg, i)
	end
end

function wnd_answerEntrance:onSelectActivity(sender, gameType)
	local cfg = openTable[gameType]
	local curLevel = g_i3k_game_context:GetLevel()
	local openTime = cfg.test(g_i3k_game_context)
	if not openTime then
		g_i3k_ui_mgr:PopupTipMessage(i3k_get_string(16405))
	elseif curLevel < cfg.openLevel then
		g_i3k_ui_mgr:PopupTipMessage(i3k_get_string(3205, cfg.openLevel))
	else
		if gameType == g_ANSWER_TYPE_KEJU then		
			g_i3k_logic:OpenAnswerQuestionsUI()
			
		elseif gameType == g_ANSWER_TYPE_MILLIONS then
			i3k_sbean.million_answer_sync()
		elseif gameType == g_ANSWER_TYPE_HEGEMONY then		
			i3k_sbean.five_hegemony_sync(g_HEGEMONY_PROTOCOL_STATE_SYNC)
		end
		g_i3k_ui_mgr:CloseUI(eUIID_XingJun)
	end
	
end

--更新红点
function wnd_answerEntrance:updateItems()
	local widgets = self._layout.vars
	for i, cfg in ipairs(openTable) do
		self:setItem(cfg, i)
	end
end

--设置items
function wnd_answerEntrance:setItem(cfg,index)
	local widgets = self._layout.vars
	local open, red = cfg.test(g_i3k_game_context)
	widgets["red"..index]:setVisible(red)
	if open then
		widgets["btn"..index]:enableWithChildren()
	else
		widgets["btn"..index]:disableWithChildren()
	end
end

function wnd_create(layout)
	local wnd = wnd_answerEntrance.new();
		wnd:create(layout);
	return wnd;
end

