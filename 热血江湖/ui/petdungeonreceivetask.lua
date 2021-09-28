-------------------------------------------------------
module(..., package.seeall)

local require = require;

local ui = require("ui/base");

-------------------------------------------------------
wnd_petDungeonReceiveTask = i3k_class("wnd_petDungeonReceiveTask", ui.wnd_base)

function wnd_petDungeonReceiveTask:ctor()

end

function wnd_petDungeonReceiveTask:configure()
	local widgets = self._layout.vars
	widgets.close_btn:onClick(self, self.onCloseUI)
end

function wnd_petDungeonReceiveTask:onShow()

end

function wnd_petDungeonReceiveTask:refresh(npcID)
	self._npcID = npcID
	self._taskID = g_i3k_db.i3k_db_get_TaskID_By_NpcID(npcID)
	local taskCfg = i3k_db_PetDungeonTasks[self._taskID]
	self:setUI(taskCfg)
	self:setScroll(taskCfg)
end


function wnd_petDungeonReceiveTask:setUI(taskCfg)
	local widgets = self._layout.vars
	widgets.taskName:setText(taskCfg.name)
	widgets.taskDesc:setText(taskCfg.des)
	local state, value = g_i3k_game_context:getPetDungeonTaskState(self._taskID)
	local desc = g_i3k_db.i3k_db_get_task_desc(taskCfg.type, taskCfg.arg1, taskCfg.arg2, value, value >= taskCfg.arg2)
	widgets.taskKill:setText(desc)

	widgets.go_btn:onClick(self, self.onAcceptBtn)
	widgets.abandonBtn:onClick(self, self.onGiveUpBtn)
	widgets.help:setText(i3k_get_string(1507))
end

function wnd_petDungeonReceiveTask:setScroll(taskCfg)
	local widgets = self._layout.vars
	local scroll = widgets.scroll
	scroll:removeAllChildren()
	local list =  {}
	
	for k, v in ipairs(taskCfg.rewards) do
		if v.count ~= 0 then
			table.insert(list, v)
		end
	end
	
	if taskCfg.exp ~= 0 then
		table.insert(list, {id = 1000, count = taskCfg.exp})
	end
	
	for k, v in ipairs(list) do
		local ui = require("ui/widgets/shengwangrwt")()
		local weight = ui.vars
		local itemID = v.id
		local haveCount = g_i3k_game_context:GetCommonItemCanUseCount(itemID)
		weight.count:setText("x"..v.count)
		weight.icon:setImage(g_i3k_db.i3k_db_get_common_item_icon_path(itemID))
		weight.bg:setImage(g_i3k_db.i3k_db_get_common_item_rank_frame_icon_path(itemID))
		weight.lock:setVisible(g_i3k_db.i3k_db_get_reward_lock_visible(itemID))
		weight.btn:onClick(self, self.onItemTip, itemID)
		scroll:addItem(ui)
	end
end

function wnd_petDungeonReceiveTask:onAcceptBtn(sender)
	i3k_sbean.acceptPetDungeonTask(self._taskID)
	self:onCloseUI()
end


function wnd_petDungeonReceiveTask:onItemTip(sender, itemID)
	g_i3k_ui_mgr:ShowCommonItemInfo(itemID)
end

function wnd_petDungeonReceiveTask:onGiveUpBtn(sender)
	self:onCloseUI()
end

function wnd_create(layout, ...)
	local wnd = wnd_petDungeonReceiveTask.new()
	wnd:create(layout, ...)
	return wnd;
end
