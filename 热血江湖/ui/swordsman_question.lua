-------------------------------------------------------
module(..., package.seeall)

local require = require;
require("ui/ui_funcs")
local ui = require("ui/base");
-------------------------------------------------------
wnd_swordsman_question = i3k_class("wnd_swordsman_question", ui.wnd_base)

function wnd_swordsman_question:ctor()
	self.rightTotalCount = 0
	self.callFunc = nil
	self.qIndex = 1
	self.questionCfg = nil
	self.questions = {}
	self._taskType = 1
	self._cfg = {}
end

function wnd_swordsman_question:configure()
	local widgets = self._layout.vars
	self.options = {
	[1] = widgets.option_a,
	[2] = widgets.option_b,
	[3] = widgets.option_c,
	[4] = widgets.option_d,
	}
	for k,v in ipairs(self.options) do
		self.options[k]:onClick(self,self.option,k)
	end

	self.contents = {
	[1] = widgets.content_a,
	[2] = widgets.content_b,
	[3] = widgets.content_c,
	[4] = widgets.content_d,
	}
	self.content = widgets.content
	self._layout.vars.closeBtn:onClick(self, self.onCloseUI)
end

function wnd_swordsman_question:option(sender, tag)
	local question = i3k_db_task_question.questions[self.questions[self.qIndex]]
	if tag == question.correct then
		self.rightTotalCount = self.rightTotalCount + 1
	end
	for i = 1 , #self.options do
		self.options[i]:disableWithChildren()
	end
	local count = 0
	if self._taskType == TASK_CATEGORY_MAIN then
		count = 3
	else
		count = self._cfg.arg3
	end
	local seq = cc.Sequence:create(cc.DelayTime:create(2) ,cc.CallFunc:create(function ()
	 	if self.qIndex == count then
			self:Quit()
			return
		end
		for i = 1 , #self.options do
			self.options[i]:enableWithChildren()
		end
		self.qIndex = self.qIndex + 1
	 	self:setContets(self.questions[self.qIndex])
	end))
	self:runAction(seq)
end

function wnd_swordsman_question:Quit()
	if self.callFunc then
		self.callFunc(self.rightTotalCount)
	end
	g_i3k_ui_mgr:CloseUI(eUIID_SwordsmanQuestion)
end

function wnd_swordsman_question:setRandom()
	math.randomseed(tonumber(tostring(os.time()):reverse():sub(1, 6)))
	local temp = {}
	local idx = 0
	local count = 0
	if self._taskType == TASK_CATEGORY_MAIN then
		count = 3
	else
		count = self._cfg.arg3
	end
	while true do
		if idx == count then
			break
		end
		local rand = "qId".. math.random(1, 6)
		if not temp[rand] then
			idx = idx + 1
			temp[rand] = self.questionCfg[rand]
			table.insert(self.questions, self.questionCfg[rand])
		end
	end
end

function wnd_swordsman_question:setContets(whichRandom)
	local question = i3k_db_task_question.questions[whichRandom]
	if question.iconId ~= 0 then
		self._layout.vars.questionIcon:setImage(g_i3k_db.i3k_db_get_icon_path(question.iconId))
		self._layout.vars.questionIcon:show()
	else
		self._layout.vars.questionIcon:hide()
	end
	self.content:setText(question.content)
	for i = 1 , 4 do
		self.contents[i]:setText(question[string.format("select%d",i)])
	end
end

function wnd_swordsman_question:refresh(cfg, CallFunc, taskType)
	self._taskType = taskType
	self._cfg = cfg
	local count = 0
	if self._taskType == TASK_CATEGORY_MAIN then
		count = 3
	else
		count = self._cfg.arg3
	end
	local questionId = cfg.arg2
	self.questionCfg = i3k_db_task_question.taskCfg[questionId]
	self.callFunc = CallFunc
	self:setRandom()
	self:setContets(self.questions[1])
end

function wnd_create(layout)
	local wnd = wnd_swordsman_question.new();
	wnd:create(layout);
	return wnd;
end
