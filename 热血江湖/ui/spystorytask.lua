module(..., package.seeall)

local require = require

local ui = require("ui/base")

wnd_spyStoryTask = i3k_class("wnd_spyStoryTask", ui.wnd_base)

local SPY_STORY_TASK_WIDGET = "ui/widgets/mitanfengyunrwt"

local numEnum = {"目标一:", "目标二:", "目标三:", "目标四:", "目标五:", "目标六:", "目标七:", "目标八:", "目标九:", "目标十:"}

local greenColor = "FF029133"

function wnd_spyStoryTask:ctor()
	self._tasks = {}
end

function wnd_spyStoryTask:configure()
	local widget = self._layout.vars

	self.openBtn = widget.openBtn
	self.openBtn:onClick(self, self.onOpenAnisBtn)
	self.openBtn:setVisible(false)
	
	self.closeBtn = widget.closeBtn
	self.closeBtn:onClick(self, self.onCloseAnisBtn)
	self.closeBtn:setVisible(true)
	
	self.exitPanel = widget.exitPanel
	self.exitPanel:setVisible(false)
	
	self.exit_btn = widget.exit_btn
	self.exit_btn:onClick(self, self.onExitBtnClick)
	
	self.change_btn = widget.change_btn
	self.change_btn:onClick(self, self.onChangeBtn)
	
	self.scroll = widget.scroll
	self.score_text = widget.score_text
	
	self.desc = widget.desc
	self.desc:setText(i3k_get_string(18661))
end

function wnd_spyStoryTask:refresh()
	self.scroll:removeAllChildren()
	local tasks = g_i3k_game_context:getSpyStoryTasks()
	local camp = g_i3k_game_context:getSpyStoryCampType()
	self.score_text:setText(g_i3k_game_context:getSpyStoryScore())
	local index = 0
	for k, v in pairs(tasks) do
		if i3k_db_spy_story_task[camp][k] ~= nil then
			index = index + 1
			local node = require(SPY_STORY_TASK_WIDGET)()
			node.vars.title:setText(numEnum[index])
			node.vars.desc:setText(i3k_db_spy_story_task[camp][k].taskDesc)
			if v > 0 then
				node.vars.desc:setTextColor(greenColor)
			end
			node.vars.taskBtn:onClick(sender, self.onTaskBtnClick, k)
			node.vars.taskBtn:setVisible(v == 0)
			self.scroll:addItem(node)
			self._tasks[k] = node	
		end
	end
	self:checkCanFinished()
end

function wnd_spyStoryTask:onExitBtnClick(sender)
	local function mulHorseCB()
		i3k_sbean.mapcopy_leave()
	end
	g_i3k_game_context:CheckMulHorse(mulHorseCB)
end

function wnd_spyStoryTask:onChangeBtn(sender)
	local state = g_i3k_game_context:getSpyStoryTransformState()
	local hero = i3k_game_get_player_hero()
	if hero:IsDead() then
		return
	end
	if state == 0 then
		local count = g_i3k_game_context:getSpyStoryTransformTimes()
		if count < i3k_db_spy_story_base.transformationTimes then
			local id = i3k_db_spy_story_base.transformationID
			i3k_sbean.spy_world_alter(id)
		else
			g_i3k_ui_mgr:PopupTipMessage(i3k_get_string(18662))
		end
		
	else
		i3k_sbean.spy_world_alter_quit()
	end
end

function wnd_spyStoryTask:updateChangeState()
	local state = g_i3k_game_context:getSpyStoryTransformState()
	if state == 0 then
		self.change_btn:setImage(i3k_db.i3k_db_get_icon_path(9887))
	else
		self.change_btn:setImage(i3k_db.i3k_db_get_icon_path(9888))
	end
end

function wnd_spyStoryTask:onCloseAnisBtn()
	local widget = self._layout.vars	
	widget.closeBtn:hide()
	self._layout.anis.c_ru.play(
	function()
		widget.openBtn:show()
	end)
end

function wnd_spyStoryTask:onOpenAnisBtn()
	local widget = self._layout.vars
	widget.openBtn:hide()
	self._layout.anis.c_chu.play(
	function()
		widget.closeBtn:show()
	end)
end

function wnd_spyStoryTask:onTaskBtnClick(sender, taskID)
	local state = g_i3k_game_context:getSpyStoryTransformState()
	if state == 0 then
		local camp = g_i3k_game_context:getSpyStoryCampType()
		local cfg = i3k_db_spy_story_task[camp][taskID]
		g_i3k_game_context:GoingToDoTask(TASK_CATEGORY_SPYSTORY, cfg, taskID)
	end
end

function wnd_spyStoryTask:updateTaskByID(taskID, taskValue)
	if self._tasks[taskID] == nil then
		return
	end
	local node = self._tasks[taskID]
	node.vars.desc:setTextColor(greenColor)
	node.vars.taskBtn:setVisible(false)
	self:checkCanFinished()
end

function wnd_spyStoryTask:checkCanFinished()
	local tasks = g_i3k_game_context:getSpyStoryTasks()
	local isFinished = true
	for k, v in pairs(tasks) do
		if v == 0 then
			isFinished = false
		end
	end
	self.exitPanel:setVisible(isFinished)
end

function wnd_create(layout, ...)
	local wnd = wnd_spyStoryTask.new()
	wnd:create(layout)
	return wnd
end
