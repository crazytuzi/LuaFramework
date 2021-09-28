module(..., package.seeall)
local require = require;
local ui = require("ui/base");
-------------------------------------------------------
wnd_quitShowExp = i3k_class("wnd_quitShowExp", ui.wnd_base)
function wnd_quitShowExp:ctor()
	self._explist = 0
	
end
function wnd_quitShowExp:configure()
	
	local explist = {}
	explist.root = 	self._layout.vars.exproot
	local expbg2 =  self._layout.vars.expbg2
	local expbg3 =  self._layout.vars.expbg3
	local expbg4 =  self._layout.vars.expbg4
	local expbg5 =  self._layout.vars.expbg5
	local expbg6 =  self._layout.vars.expbg6
	local expbg7 =  self._layout.vars.expbg7
	explist.expbg = {expbg2,expbg3,expbg4,expbg5,expbg6,expbg7}
	for k,v in pairs(explist.expbg) do
		v:setVisible(false)
	end
end

function wnd_quitShowExp:refresh(addExp)
	self:addExpShow(addExp)
end

function wnd_quitShowExp:onUpdate(dTime)
	
end

function wnd_quitShowExp:addExpShow(iexp)-- InvokeUIFunction
	self._explist = iexp
	self:onUpdateExpShow(0.1)
end

function wnd_quitShowExp:onUpdateExpShow(dTime)
	
	
	
	self._layout.vars.expbg1:setOpacity(255)
	
	self._layout.vars.exp1:setText("+"..self._explist)
	local callbackFunc = function ()
		g_i3k_ui_mgr:CloseUI(eUIID_QuizShowExp)
		
	end
	
	local fadeOut = cc.FadeOut:create(0.8 )
	local spawn = cc.Sequence:create(fadeOut, cc.CallFunc:create(callbackFunc))
	self._layout.vars.expbg1:runAction(spawn)
	
end

function wnd_create(layout)
	local wnd = wnd_quitShowExp.new();
	wnd:create(layout);
	return wnd;
end
