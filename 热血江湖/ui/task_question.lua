-------------------------------------------------------
module(..., package.seeall)

local require = require;
require("ui/ui_funcs")
local ui = require("ui/base");
-------------------------------------------------------
wnd_task_question = i3k_class("wnd_task_question", ui.wnd_base)
function wnd_task_question:ctor()
	self.rightTotalCount = 0
	self.callFunc = nil
	self.qIndex = 1
	self.questionCfg = nil
	self.questions = {}
	self._taskType = 1
	self._cfg = {}
end
function wnd_task_question:configure()
	self._JQRWDTT = require("ui/widgets/jqrwdtt")()
	self._layout.vars.answerSheet:addChild(self._JQRWDTT)
	self._JQRWDTT.root:setSizePercent(cc.p(1, 1))

	local widgets = self._JQRWDTT.vars

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

	self.trues = {
	[1] = widgets.true_a,
	[2] = widgets.true_b,
	[3] = widgets.true_c,
	[4] = widgets.true_d,
	}
	
	self.falses = {
	[1] = widgets.false_a,
	[2] = widgets.false_b,
	[3] = widgets.false_c,
	[4] = widgets.false_d,
	}

	self.content = widgets.content
	self.right_count = widgets.right_count
	self.finish_count = widgets.finish_count
end

function wnd_task_question:option(sender,tag)
	local question = i3k_db_task_question.questions[self.questions[self.qIndex]]
	
	if tag == question.correct then
		self.trues[tag]:setVisible(true)
		self.rightTotalCount = self.rightTotalCount + 1
	else
		self.falses[tag]:setVisible(true)
	end

	for i = 1 , #self.options do
		self.options[i]:hide()
	end
	local count = 0
	if self._taskType == TASK_CATEGORY_MAIN then
		count = 3
	else
		count = self._cfg.arg3
	end
	self.finish_count:setText(self.qIndex.."/"..count)
	self.right_count:setText(tostring(self.rightTotalCount))

	local seq = cc.Sequence:create(cc.DelayTime:create(2) ,cc.CallFunc:create(function ()
	 	if self.qIndex == count then
			self:Quit()
			return
		end

		if tag == question.correct then
			self.trues[tag]:setVisible(false)
		else
			self.falses[tag]:setVisible(false)
		end
		for i = 1 , #self.options do
			self.options[i]:show()
		end
		self.qIndex = self.qIndex + 1
	 	self:setContets(self.questions[self.qIndex])
	end))
	self:runAction(seq)
end

function wnd_task_question:Quit()
	if self.callFunc then
		self.callFunc(self.rightTotalCount)
	end
	g_i3k_ui_mgr:CloseUI(eUIID_Task_Question)
end

function wnd_task_question:setRandom()
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

function wnd_task_question:setContets(whichRandom)
	local question = i3k_db_task_question.questions[whichRandom]
	if question.iconId ~= 0 then
		self._JQRWDTT.vars.questionIcon:setImage(g_i3k_db.i3k_db_get_icon_path(question.iconId))
		self._JQRWDTT.vars.questionIcon:show()
		self.content:hide()
	else
		self._JQRWDTT.vars.questionIcon:hide()
		self.content:show()
	self.content:setText(question.content)
	end
	for i = 1 , 4 do
		self.contents[i]:setText(question[string.format("select%d",i)])
	end
end

function wnd_task_question:refresh(cfg, CallFunc, taskType)
	self._taskType = taskType
	self._cfg = cfg
	local count = 0
	if self._taskType == TASK_CATEGORY_MAIN then
		count = 3
	else
		count = self._cfg.arg3
	end
	self.finish_count:setText("0/"..count)
	local questionId = cfg.arg2
	self.questionCfg = i3k_db_task_question.taskCfg[questionId]
	self.callFunc = CallFunc
	self._layout.vars.talkTxt:setText(self.questionCfg.talkAbout)
	self._layout.vars.model:show()
	ui_set_hero_model(self._layout.vars.model, self.questionCfg.npcModelId)
	self:setRandom()
	self:setContets(self.questions[1])
end

function wnd_create(layout)
	local wnd = wnd_task_question.new();
	wnd:create(layout);
	return wnd;
end
