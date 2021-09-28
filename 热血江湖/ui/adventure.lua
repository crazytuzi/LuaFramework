
-------------------------------------------------------
module(..., package.seeall)
local require = require;
local ui = require("ui/base");
-------------------------------------------------------
wnd_adventure = i3k_class("wnd_adventure",ui.wnd_base)

function wnd_adventure:ctor()
	self._showTick = 0
	self.endTime = 0
end

function wnd_adventure:configure()
	local widgets = self._layout.vars
	widgets.close:onClick(self, self.closeUI)
	self.time = widgets.time
end

function wnd_adventure:refresh(trigID, force)
	local widgets = self._layout.vars
	local context = g_i3k_game_context:getAdventure()
	local db = i3k_db_adventure
	local taskId = context.task.id
	if trigID then
		local head = db.head[trigID]
		ui_set_hero_model(widgets.icon, head.popIconId)
		widgets.desc:setText(head.startDesc)

		if force == 0 then
			self.endTime = context.trigEndTime - i3k_game_get_time()
			local min = math.modf(self.endTime/60)
			widgets.time:show():setText(string.format("剩余时间%d分%d秒", min, self.endTime%60))
			widgets.yes_btn:onClick(self, self.chooseHeadTask, head.firstTaskId)
			widgets.no_btn:onClick(self, self.chooseHeadTask, 0)
			self:setYesOrNo(head.yesTxt, head.noTxt)
		else
			widgets.yes_btn:hide()
			widgets.no_btn:hide()
			widgets.time:hide()
		end
	else
		widgets.time:hide()
		local circuit = db.circuit[taskId]
		local choose = db.choose[taskId]
		ui_set_hero_model(widgets.icon, choose.iconId)
		widgets.desc:setText(choose.desc)
		widgets.yes_btn:onClick(self, self.chooseTask, circuit.nextId[1])
		widgets.no_btn:onClick(self, self.chooseTask, circuit.nextId[2])
		self:setYesOrNo(choose.yesTxt, choose.noTxt)
	end
end

function wnd_adventure:chooseTask(sender, taskId)
	i3k_sbean.adtask_selectReq(taskId)
	self:onCloseUI()
end

function wnd_adventure:chooseHeadTask(sender, taskId)
	if taskId == 0 then
		g_i3k_ui_mgr:ShowMessageBox2(i3k_get_string(17137), function(ok)
			if ok then
				i3k_sbean.adtask_acceptReq(taskId)
				g_i3k_ui_mgr:InvokeUIFunction(eUIID_Adventure, "closeUI")
			end
		end)
	else
		i3k_sbean.adtask_acceptReq(taskId)
		g_i3k_ui_mgr:InvokeUIFunction(eUIID_Adventure, "closeUI")
	end
end

function wnd_adventure:setYesOrNo(yesTxt, noTxt)
	local widgets = self._layout.vars
	widgets.yes_desc:setText(yesTxt)
	widgets.no_desc:setText(noTxt)
end

function wnd_adventure:closeUI(sender)
	g_i3k_ui_mgr:CloseUI(eUIID_Adventure)
end

function wnd_adventure:onUpdate(dTime)
	self._showTick = self._showTick + dTime
	if self._showTick >= 1 and self.endTime > 0 then
		self._showTick = 0
		self.endTime = self.endTime - 1
		local min = math.modf(self.endTime/60)
		self.time:show():setText(string.format("剩余时间%d分%d秒", min, self.endTime%60))
		if self.endTime == 0 then
			g_i3k_game_context:removeAdventureTask()
			g_i3k_ui_mgr:InvokeUIFunction(eUIID_Adventure, "closeUI")
		end
	end
end

function wnd_create(layout, ...)
	local wnd = wnd_adventure.new()
	wnd:create(layout, ...)
	return wnd;
end

