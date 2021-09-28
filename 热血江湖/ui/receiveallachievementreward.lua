
module(..., package.seeall)

local require = require;

require("ui/ui_funcs")
local ui = require("ui/base");

local ONE_REWARD = 1 --一次 
local ALL_REWARD = 2 -- 一键

-------------------------------------------------------
wnd_receiveAllAchievementReward = i3k_class("wnd_receiveAllAchievementReward", ui.wnd_base)

function wnd_receiveAllAchievementReward:ctor()
	self.isShow = false
end
function wnd_receiveAllAchievementReward:configure()
	local useItemBtn = self._layout.vars.useItemBtn--圆钮
	useItemBtn:onClick(self,self.onRadioBtn)
	self._layout.vars.useItem:setVisible(false)--对勾
	
end

function wnd_receiveAllAchievementReward:refresh(callFunOne, callFuncOnekey, args, items)
	local widgets =  self._layout.vars
	widgets.onlyReward:onClick(self, self.onReward, {callFunc = callFunOne, args = args})
	widgets.allReward:onClick(self, self.onAllReward, {callFunc = callFuncOnekey, args = items})
end 

function wnd_receiveAllAchievementReward:onRadioBtn(sender)
	if self.isShow then
		self.isShow = false
		self._layout.vars.useItem:setVisible(false)
	else
		self.isShow = true
		self._layout.vars.useItem:setVisible(true)
	end
end

function wnd_receiveAllAchievementReward:onReward(sender, callBack)
	if callBack then
		callBack.callFunc(callBack.args)
	end
	g_i3k_game_context:setShowAchievementRewardTips(self.isShow and ONE_REWARD)
	g_i3k_ui_mgr:CloseUI(eUIID_ReceiveAchievementReward)
end

function wnd_receiveAllAchievementReward:onAllReward(sender, callBack)
	if callBack then
		callBack.callFunc(callBack.args)
	end
	g_i3k_game_context:setShowAchievementRewardTips(self.isShow and ALL_REWARD)
	g_i3k_ui_mgr:CloseUI(eUIID_ReceiveAchievementReward)
end


function wnd_receiveAllAchievementReward:onCloseUI(sender)
	g_i3k_ui_mgr:CloseUI(eUIID_TournamentWeekReward)
end


function wnd_create(layout)
	local wnd = wnd_receiveAllAchievementReward.new();
	wnd:create(layout);
	return wnd;
end
